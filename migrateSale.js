const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function asNumber(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? value : null;
  }
  const str = String(value).trim().replace(/,/g, ".");
  if (!str) return null;
  const num = Number(str);
  return Number.isFinite(num) ? num : null;
}

function asInteger(value) {
  const num = asNumber(value);
  return num === null ? null : Math.round(num);
}

function asBool(value) {
  if (value === null || value === undefined) return false;
  if (typeof value === "boolean") return value;
  if (typeof value === "number") return value !== 0;
  const str = String(value).trim().toLowerCase();
  return str === "1" || str === "true" || str === "y";
}

function normalizeDate(value) {
  if (value === null || value === undefined) return null;

  if (typeof value === "string") {
    const trimmed = value.trim();
    if (!trimmed) return null;
    if (/^0{4}-0{2}-0{2}/.test(trimmed)) return null;
    const parsed = new Date(trimmed);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value;
  }

  if (typeof value === "number") {
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  return null;
}

function normalizeLegacyId(value) {
  if (value === null || value === undefined) return null;

  if (typeof value === "number" && Number.isFinite(value)) {
    return String(value);
  }

  if (typeof value === "bigint") {
    return value.toString();
  }

  if (Buffer.isBuffer(value)) {
    return normalizeLegacyId(value.toString("utf8"));
  }

  const trimmed = String(value).trim();
  if (!trimmed) return null;

  if (/^[+-]?\d+(?:\.0+)?$/.test(trimmed)) {
    return String(parseInt(trimmed, 10));
  }

  return trimmed.toLowerCase();
}

function legacyIdCandidates(value) {
  const normalized = normalizeLegacyId(value);
  if (!normalized) return [];

  const candidates = new Set([normalized]);
  if (/\D/.test(normalized)) {
    const digitsOnly = normalized.replace(/\D+/g, "");
    if (digitsOnly) {
      const numericCandidate = normalizeLegacyId(digitsOnly);
      if (numericCandidate) {
        candidates.add(numericCandidate);
      }
    }
  }

  return Array.from(candidates);
}

function splitList(value) {
  if (!value) return [];
  return String(value)
    .split(",")
    .map((part) => {
      const text = cleanText(part);
      if (!text) return null;
      if (text.toLowerCase() === "null") return null;
      return text;
    })
    .filter(Boolean);
}

async function migrateSale(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  let skippedMissingSeller = 0;
  let missingCustomerCount = 0;

  try {
    const { rows: customerRows } = await pg.query(
      `SELECT id, "customerId" FROM "Customer" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const customerMap = new Map();
    for (const c of customerRows) {
      for (const key of legacyIdCandidates(c.customerId)) {
        if (!customerMap.has(key)) {
          customerMap.set(key, c.id);
        }
      }
    }

    const { rows: userRows } = await pg.query(
      `SELECT id, email FROM "User" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const userEmailMap = new Map(
      userRows
        .filter((u) => u.email)
        .map((u) => [u.email.toLowerCase(), u.id])
    );

    const [legacyUsers] = await mysql.query(
      `SELECT UserId, CellPhone, HomePhone, UserTz FROM tblUsers`
    );
    const legacyUserMap = new Map();
    for (const u of legacyUsers) {
      for (const key of legacyIdCandidates(u.UserId)) {
        if (!legacyUserMap.has(key)) {
          legacyUserMap.set(key, u);
        }
      }
    }

    const { rows: branchRows } = await pg.query(
      `SELECT id, code FROM "Branch" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const branchMap = new Map(branchRows.map((b) => [b.code, b.id]));

    const [payTypeRows] = await mysql.query(
      `SELECT PayTypeId, PayTypeName FROM tblPayTypes`
    );
    const payTypeMap = new Map(
      payTypeRows.map((row) => [normalizeLegacyId(row.PayTypeId), cleanText(row.PayTypeName) || `TYPE-${row.PayTypeId}`])
    );

    while (true) {
      const [rows] = await mysql.query(
        `SELECT BuyId, BuyDate, GroupId, PerId, UserId, Comment, PayedFor,
                BuyType, BuySrcId, BranchId, Canceled
           FROM tblCrdBuys
          WHERE BuyId > ?
          ORDER BY BuyId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const buyIds = chunk.map((r) => r.BuyId);

        const itemSummaryMap = new Map();
        if (buyIds.length) {
          const placeholders = buyIds.map(() => "?").join(",");
          const [itemRows] = await mysql.query(
            `SELECT BuyId,
                    SUM(COALESCE(Quantity, 0) * COALESCE(Price, 0)) AS subtotal,
                    SUM(COALESCE(Discount, 0)) AS discount
               FROM tblCrdBuysCatNums
              WHERE BuyId IN (${placeholders})
              GROUP BY BuyId`,
            buyIds
          );
          for (const row of itemRows) {
            itemSummaryMap.set(row.BuyId, {
              subtotal: asNumber(row.subtotal) ?? 0,
              discount: asNumber(row.discount) ?? 0,
            });
          }
        }

        const paymentSummaryMap = new Map();
        if (buyIds.length) {
          const placeholders = buyIds.map(() => "?").join(",");
          const [paymentRows] = await mysql.query(
            `SELECT BuyId,
                    GROUP_CONCAT(PayTypeId ORDER BY BuyPayId) AS payTypes,
                    SUM(COALESCE(PaySum, 0)) AS payTotal
               FROM tblCrdBuysPays
              WHERE BuyId IN (${placeholders})
              GROUP BY BuyId`,
            buyIds
          );
          for (const row of paymentRows) {
            paymentSummaryMap.set(row.BuyId, {
              payTypes: splitList(row.payTypes),
              payTotal: asNumber(row.payTotal) ?? 0,
            });
          }
        }

        const values = [];
        const params = [];

        for (const r of chunk) {
          const saleDate = normalizeDate(r.BuyDate) || new Date();

          const seller = legacyIdCandidates(r.UserId)
            .map((candidate) => legacyUserMap.get(candidate))
            .find((value) => value) || null;
          let sellerId = null;
          if (seller) {
            const candidates = [
              cleanText(seller.CellPhone) ? `${seller.CellPhone}@legacy.local`.toLowerCase() : null,
              cleanText(seller.HomePhone) ? `${seller.HomePhone}@legacy.local`.toLowerCase() : null,
              cleanText(seller.UserTz) ? `${seller.UserTz}@legacy.local`.toLowerCase() : null,
              `user-${seller.UserId}@legacy.local`,
            ].filter(Boolean);
            sellerId = candidates.map((c) => userEmailMap.get(c)).find((v) => v) || null;
          }

          if (!sellerId) {
            skippedMissingSeller += 1;
            continue;
          }

          const customerId = legacyIdCandidates(r.PerId)
            .map((candidate) => customerMap.get(candidate))
            .find((value) => value) || null;
          if (!customerId) {
            missingCustomerCount += 1;
          }

          const branchId = branchMap.get(String(r.BranchId)) || null;

          const itemSummary = itemSummaryMap.get(r.BuyId) || { subtotal: 0, discount: 0 };
          const subtotal = itemSummary.subtotal ?? 0;
          const discountAmount = itemSummary.discount ?? 0;
          const computedTotal = subtotal - discountAmount;
          const payedFor = asNumber(r.PayedFor);
          const totalAmount = payedFor !== null ? payedFor : computedTotal;

          const paymentSummary = paymentSummaryMap.get(r.BuyId);
          const paymentMethod = paymentSummary
            ? paymentSummary.payTypes
                .map((typeId) => payTypeMap.get(normalizeLegacyId(typeId)) || `TYPE-${typeId}`)
                .join(", ") || null
            : null;

          const status = asBool(r.Canceled) ? "CANCELED" : "COMPLETED";
          const paymentStatus = asBool(r.Canceled) ? "VOID" : "PAID";

          const notesParts = [];
          const comment = cleanText(r.Comment);
          if (comment) notesParts.push(comment);
          if (paymentSummary && paymentSummary.payTotal !== null) {
            notesParts.push(`Total paid: ${paymentSummary.payTotal}`);
          }
          if (asInteger(r.BuyType) !== null) {
            notesParts.push(`Legacy buy type: ${asInteger(r.BuyType)}`);
          }
          if (cleanText(r.BuySrcId)) {
            notesParts.push(`Source ID: ${cleanText(r.BuySrcId)}`);
          }
          const notes = notesParts.length ? notesParts.join("\n") : null;

          const createdAt = new Date();
          const updatedAt = createdAt;
          const deletedAt = asBool(r.Canceled) ? saleDate : null;

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5},
               $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10},
               $${params.length + 11}, $${params.length + 12}, $${params.length + 13}, $${params.length + 14}, $${params.length + 15},
               $${params.length + 16}, $${params.length + 17}, $${params.length + 18}, $${params.length + 19}, $${params.length + 20})`
          );

          params.push(
            createId(),
            tenantId,
            String(r.BuyId),
            customerId,
            sellerId,
            saleDate,
            status,
            subtotal,
            discountAmount,
            0,
            totalAmount ?? 0,
            paymentMethod,
            paymentStatus,
            null,
            notes,
            createdAt,
            updatedAt,
            deletedAt,
            branchId,
            null
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "Sale" (
              id, "tenantId", "saleId", "customerId", "sellerId", "saleDate", status,
              subtotal, "discountAmount", "taxAmount", total, "paymentMethod",
              "paymentStatus", "prescriptionId", notes, "createdAt", "updatedAt",
              "deletedAt", "branchId", "cashierShiftId"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("saleId")
            DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              "customerId" = EXCLUDED."customerId",
              "sellerId" = EXCLUDED."sellerId",
              "saleDate" = EXCLUDED."saleDate",
              status = EXCLUDED.status,
              subtotal = EXCLUDED.subtotal,
              "discountAmount" = EXCLUDED."discountAmount",
              "taxAmount" = EXCLUDED."taxAmount",
              total = EXCLUDED.total,
              "paymentMethod" = EXCLUDED."paymentMethod",
              "paymentStatus" = EXCLUDED."paymentStatus",
              notes = EXCLUDED.notes,
              "updatedAt" = EXCLUDED."updatedAt",
              "deletedAt" = EXCLUDED."deletedAt",
              "branchId" = EXCLUDED."branchId",
              "cashierShiftId" = EXCLUDED."cashierShiftId"
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }

        total += values.length;
      }

      lastId = rows[rows.length - 1].BuyId;
      console.log(`Sales migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ Sale migration completed. Total inserted/updated: ${total}`);
    if (skippedMissingSeller) {
      console.warn(`⚠️ Skipped ${skippedMissingSeller} sales due to missing seller mapping`);
    }
    if (missingCustomerCount) {
      console.warn(`⚠️ Unable to link ${missingCustomerCount} sales to a customer`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateSale;
