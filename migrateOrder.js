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
      const numeric = normalizeLegacyId(digitsOnly);
      if (numeric) {
        candidates.add(numeric);
      }
    }
  }
  return Array.from(candidates);
}

async function migrateOrder(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  let skippedMissingCustomer = 0;
  let skippedMissingSeller = 0; // remains for logging but we will not skip orders; kept for compatibility

  try {
    const existingOrderNumbers = new Set();
    const existingOrderMap = new Map();

    const { rows: existingOrderRows } = await pg.query(
      `SELECT id, "orderNumber" FROM "Order" WHERE "tenantId" = $1`,
      [tenantId]
    );
    for (const row of existingOrderRows) {
      if (row.orderNumber) {
        existingOrderNumbers.add(row.orderNumber);
      }
      existingOrderMap.set(row.id, row.orderNumber || null);
    }

    const allocateOrderNumber = (bagNum, workId) => {
      const fallbackBase = `LEGACY-${workId}`;
      const base = cleanText(bagNum) || fallbackBase;

      const claim = (candidate) => {
        if (!existingOrderNumbers.has(candidate)) {
          existingOrderNumbers.add(candidate);
          return candidate;
        }
        return null;
      };

      let candidate = claim(base);
      if (candidate) {
        return candidate;
      }

      candidate = claim(`${base}-${workId}`);
      if (candidate) {
        return candidate;
      }

      let suffix = 1;
      while (true) {
        candidate = `${base}-${workId}-${suffix}`;
        if (!existingOrderNumbers.has(candidate)) {
          existingOrderNumbers.add(candidate);
          return candidate;
        }
        suffix += 1;
      }
    };

    const { rows: customerRows } = await pg.query(
      `SELECT id, "customerId" FROM "Customer" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const customerMap = new Map();
    for (const row of customerRows) {
      for (const key of legacyIdCandidates(row.customerId)) {
        if (!customerMap.has(key)) {
          customerMap.set(key, row.id);
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
    for (const user of legacyUsers) {
      for (const key of legacyIdCandidates(user.UserId)) {
        if (!legacyUserMap.has(key)) {
          legacyUserMap.set(key, user);
        }
      }
    }

    const { rows: workLabRows } = await pg.query(
      `SELECT id, "labId" FROM "WorkLab" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const labMap = new Map(workLabRows.map((row) => [String(row.labId), row.id]));

    const buildLookup = (rows, idField, nameField) => {
      const map = new Map();
      for (const row of rows) {
        const key = normalizeLegacyId(row[idField]);
        const name = cleanText(row[nameField]);
        if (key && !map.has(key)) {
          map.set(key, name);
        }
      }
      return map;
    };

    const [workTypeRows] = await mysql.query(
      `SELECT WorkTypeId, WorkTypeName FROM tblCrdBuysWorkTypes`
    );
    const workTypeMap = buildLookup(workTypeRows, "WorkTypeId", "WorkTypeName");

    const [workStatRows] = await mysql.query(
      `SELECT WorkStatId, WorkStatName FROM tblCrdBuysWorkStats`
    );
    const workStatMap = buildLookup(workStatRows, "WorkStatId", "WorkStatName");

    const [workSupplyRows] = await mysql.query(
      `SELECT WorkSupplyId, WorkSupplyName FROM tblCrdBuysWorkSupply`
    );
    const workSupplyMap = buildLookup(workSupplyRows, "WorkSupplyId", "WorkSupplyName");

    const [workSapakRows] = await mysql.query(
      `SELECT SapakID, SapakName FROM tblCrdBuysWorkSapaks`
    );
    const workSapakMap = buildLookup(workSapakRows, "SapakID", "SapakName");

    while (true) {
      const [rows] = await mysql.query(
        `SELECT WorkId, WorkDate, PerId, UserId, WorkTypeId, CheckDate, WorkStatId, WorkSupplyId,
                LabId, SapakId, BagNum, PromiseDate, DeliverDate, Comment, FSapakId, FLabelId,
                FModel, FColor, FSize, FrameSold, LnsSapakId, GlassSapakId, ClensSapakId,
                GlassId, Wtype, SMSSent, ItemId, TailId, Canceled
           FROM tblCrdBuysWorks
          WHERE WorkId > ?
          ORDER BY WorkId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const r of chunk) {
          const customerId = legacyIdCandidates(r.PerId)
            .map((candidate) => customerMap.get(candidate))
            .find((value) => value) || null;
          if (!customerId) {
            skippedMissingCustomer += 1;
            continue;
          }

          const sellerLegacy = legacyIdCandidates(r.UserId)
            .map((candidate) => legacyUserMap.get(candidate))
            .find((value) => value) || null;
          if (!sellerLegacy) {
            skippedMissingSeller += 1;
          }

          const orderDate = normalizeDate(r.WorkDate) || normalizeDate(r.CheckDate) || new Date();
          const deliveryDate = normalizeDate(r.DeliverDate);
          const promiseDate = normalizeDate(r.PromiseDate);

          const orderId = `${tenantId}-order-${r.WorkId}`;
          let orderNumber = existingOrderMap.get(orderId);
          if (!orderNumber) {
            orderNumber = allocateOrderNumber(r.BagNum, r.WorkId);
            existingOrderMap.set(orderId, orderNumber);
          }

          const workType = workTypeMap.get(normalizeLegacyId(r.WorkTypeId)) || null;
          const workStatusRaw = workStatMap.get(normalizeLegacyId(r.WorkStatId)) || null;
          const workSupply = workSupplyMap.get(normalizeLegacyId(r.WorkSupplyId)) || null;

          let status = "PENDING";
          if (r.Canceled) {
            status = "CANCELLED";
          } else if (workStatusRaw) {
            status = workStatusRaw.toUpperCase();
          } else if (deliveryDate) {
            status = "COMPLETED";
          }

          const paymentStatus = r.Canceled ? "VOID" : deliveryDate ? "PAID" : "PENDING";

          const labId = r.LabId != null ? labMap.get(String(r.LabId)) || null : null;

          const supplierNames = [];
          const primarySupplier = workSapakMap.get(normalizeLegacyId(r.SapakId));
          if (primarySupplier) supplierNames.push(`Primary: ${primarySupplier}`);
          const frameSupplier = workSapakMap.get(normalizeLegacyId(r.FSapakId));
          if (frameSupplier) supplierNames.push(`Frame: ${frameSupplier}`);
          const lensSupplier = workSapakMap.get(normalizeLegacyId(r.LnsSapakId));
          if (lensSupplier) supplierNames.push(`Lens: ${lensSupplier}`);
          const glassSupplier = workSapakMap.get(normalizeLegacyId(r.GlassSapakId));
          if (glassSupplier) supplierNames.push(`Glass: ${glassSupplier}`);
          const clensSupplier = workSapakMap.get(normalizeLegacyId(r.ClensSapakId));
          if (clensSupplier) supplierNames.push(`CLens: ${clensSupplier}`);

          const notesParts = [];
          const comment = cleanText(r.Comment);
          if (comment) notesParts.push(comment);
          if (cleanText(r.BagNum)) notesParts.push(`Bag #: ${cleanText(r.BagNum)}`);
          if (cleanText(r.FModel) || cleanText(r.FColor) || cleanText(r.FSize)) {
            const frameBits = [cleanText(r.FModel), cleanText(r.FColor), cleanText(r.FSize)].filter(Boolean).join(" / ");
            if (frameBits) notesParts.push(`Frame details: ${frameBits}`);
          }
          if (r.FrameSold) notesParts.push(`Frame sold flag: ${r.FrameSold}`);
          if (r.SMSSent) notesParts.push(`SMS sent to customer`);
          const notes = notesParts.length ? notesParts.join("\n") : null;

          const internalBits = [];
          if (workType) internalBits.push(`Work type: ${workType}`);
          if (workStatusRaw) internalBits.push(`Work status: ${workStatusRaw}`);
          if (workSupply) internalBits.push(`Work supply: ${workSupply}`);
          if (sellerLegacy) {
            const sellerDescriptor = [
              cleanText(sellerLegacy.CellPhone),
              cleanText(sellerLegacy.HomePhone),
              cleanText(sellerLegacy.UserTz),
            ]
              .filter(Boolean)
              .join(" / ");
            internalBits.push(`Seller legacy ID ${sellerLegacy.UserId}${sellerDescriptor ? ` (${sellerDescriptor})` : ""}`);
          }
          if (supplierNames.length) internalBits.push(`Suppliers: ${supplierNames.join(", ")}`);
          if (promiseDate) internalBits.push(`Promised date: ${promiseDate.toISOString()}`);
          if (r.ItemId) internalBits.push(`ItemId: ${r.ItemId}`);
          if (r.TailId) internalBits.push(`TailId: ${r.TailId}`);
          if (r.GlassId) internalBits.push(`GlassId: ${r.GlassId}`);
          const internalNotes = internalBits.length ? internalBits.join("\n") : null;

          const paramsBase = params.length;
          values.push(
            `($${paramsBase + 1}, $${paramsBase + 2}, $${paramsBase + 3}, $${paramsBase + 4}, $${paramsBase + 5},
               $${paramsBase + 6}, $${paramsBase + 7}, $${paramsBase + 8}, $${paramsBase + 9}, $${paramsBase + 10},
               $${paramsBase + 11}, $${paramsBase + 12}, $${paramsBase + 13}, $${paramsBase + 14}, $${paramsBase + 15},
               $${paramsBase + 16}, $${paramsBase + 17}, $${paramsBase + 18}, $${paramsBase + 19}, $${paramsBase + 20},
               $${paramsBase + 21}, $${paramsBase + 22}, $${paramsBase + 23})`
          );

          params.push(
            orderId,
            tenantId,
            customerId,
            orderNumber,
            orderDate,
            deliveryDate,
            status,
            paymentStatus,
            workType,
            labId,
            null,
            null,
            0,
            0,
            0,
            0,
            0,
            0,
            notes,
            internalNotes,
            orderDate,
            orderDate,
            null
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "Order" (
              id, "tenantId", "customerId", "orderNumber", "orderDate", "deliveryDate",
              status, "paymentStatus", "workType", "labId", "supplierId", "prescriptionId",
              subtotal, discount, "taxAmount", "totalAmount", "paidAmount", "depositAmount",
              notes, "internalNotes", "createdAt", "updatedAt", "branchId"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("orderNumber")
            DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              "customerId" = EXCLUDED."customerId",
              "orderNumber" = EXCLUDED."orderNumber",
              "orderDate" = EXCLUDED."orderDate",
              "deliveryDate" = EXCLUDED."deliveryDate",
              status = EXCLUDED.status,
              "paymentStatus" = EXCLUDED."paymentStatus",
              "workType" = EXCLUDED."workType",
              "labId" = EXCLUDED."labId",
              subtotal = EXCLUDED.subtotal,
              discount = EXCLUDED.discount,
              "taxAmount" = EXCLUDED."taxAmount",
              "totalAmount" = EXCLUDED."totalAmount",
              "paidAmount" = EXCLUDED."paidAmount",
              "depositAmount" = EXCLUDED."depositAmount",
              notes = EXCLUDED.notes,
              "internalNotes" = EXCLUDED."internalNotes",
              "updatedAt" = EXCLUDED."updatedAt",
              "branchId" = EXCLUDED."branchId"
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

      lastId = rows[rows.length - 1].WorkId;
      console.log(`Orders migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ Order migration completed. Total inserted/updated: ${total}`);
    if (skippedMissingCustomer) {
      console.warn(`⚠️ Skipped ${skippedMissingCustomer} orders due to missing customers`);
    }
    if (skippedMissingSeller) {
      console.warn(`⚠️ Skipped ${skippedMissingSeller} orders due to missing sellers`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateOrder;
