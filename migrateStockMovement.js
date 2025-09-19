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

async function migrateStockMovement(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  let skippedMissingProduct = 0;
  let skippedMissingUser = 0;

  try {
    const productMap = new Map();
    const { rows: productRows } = await pg.query(
      `SELECT id, "productId" FROM "Product" WHERE "tenantId" = $1`,
      [tenantId]
    );
    for (const row of productRows) {
      const key = normalizeLegacyId(row.productId);
      if (key && !productMap.has(key)) {
        productMap.set(key, row.id);
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

    const { rows: branchRows } = await pg.query(
      `SELECT id, code FROM "Branch" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const branchMap = new Map(branchRows.map((row) => [row.code, row.id]));

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

    const [moveTypeRows] = await mysql.query(
      `SELECT InvMoveTypeId, InvMoveTypeName, MoveAction FROM tblInvMoveTypes`
    );
    const moveTypeMap = new Map();
    for (const row of moveTypeRows) {
      const key = normalizeLegacyId(row.InvMoveTypeId);
      if (key && !moveTypeMap.has(key)) {
        moveTypeMap.set(key, {
          name: cleanText(row.InvMoveTypeName) || "UNKNOWN",
          action: asInteger(row.MoveAction) ?? 0,
        });
      }
    }

    const [movePropRows] = await mysql.query(
      `SELECT InvMovePropId, InvMovePropName FROM tblInvMoveProps`
    );
    const movePropMap = buildLookup(movePropRows, "InvMovePropId", "InvMovePropName");

    while (true) {
      const [rows] = await mysql.query(
        `SELECT il.ItemLineId, il.InvId, il.ItemId, il.Quantity, il.BuyPrice, il.SalePrice, il.Removed, il.Sold,
                inv.InvDate, inv.UserId, inv.InvMoveTypeId, inv.InvMovePropId, inv.InvSapakId, inv.BranchId, inv.Com
           FROM tblItemLines AS il
           JOIN tblInventory AS inv ON inv.InvId = il.InvId
          WHERE il.ItemLineId > ?
          ORDER BY il.ItemLineId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const r of chunk) {
          const productKey = normalizeLegacyId(r.ItemId);
          const productId = productKey ? productMap.get(productKey) || null : null;
          if (!productId) {
            skippedMissingProduct += 1;
            continue;
          }

          const legacyUser = legacyIdCandidates(r.UserId)
            .map((candidate) => legacyUserMap.get(candidate))
            .find((value) => value) || null;
          let userId = null;
          if (legacyUser) {
            const candidates = [
              cleanText(legacyUser.CellPhone) ? `${legacyUser.CellPhone}@legacy.local`.toLowerCase() : null,
              cleanText(legacyUser.HomePhone) ? `${legacyUser.HomePhone}@legacy.local`.toLowerCase() : null,
              cleanText(legacyUser.UserTz) ? `${legacyUser.UserTz}@legacy.local`.toLowerCase() : null,
              `user-${legacyUser.UserId}@legacy.local`,
            ].filter(Boolean);
            userId = candidates.map((c) => userEmailMap.get(c)).find((v) => v) || null;
          }

          if (!userId) {
            skippedMissingUser += 1;
            continue;
          }

          const quantity = asInteger(r.Quantity) ?? 0;
          const costPrice = asNumber(r.BuyPrice);
          const referenceId = r.InvId != null ? String(r.InvId) : null;

          const moveType = moveTypeMap.get(normalizeLegacyId(r.InvMoveTypeId));
          const moveProp = movePropMap.get(normalizeLegacyId(r.InvMovePropId)) || null;

          const typeLabel = moveType ? moveType.name : "UNKNOWN";
          const previousQuantity = 0;
          const newQuantity = previousQuantity + quantity;

          const notesParts = [];
          if (moveProp) notesParts.push(`Movement property: ${moveProp}`);
          if (cleanText(r.Com)) notesParts.push(`Comment: ${cleanText(r.Com)}`);
          if (r.Removed) notesParts.push(`Removed count: ${r.Removed}`);
          if (r.Sold) notesParts.push(`Sold count: ${r.Sold}`);
          if (asNumber(r.SalePrice) !== null) notesParts.push(`Legacy sale price: ${asNumber(r.SalePrice)}`);
          const notes = notesParts.length ? notesParts.join("\n") : null;

          const createdAt = normalizeDate(r.InvDate) || new Date();
          const branchId = r.BranchId != null ? branchMap.get(String(r.BranchId)) || null : null;

          const paramsBase = params.length;
          values.push(
            `($${paramsBase + 1}, $${paramsBase + 2}, $${paramsBase + 3}, $${paramsBase + 4}, $${paramsBase + 5},
               $${paramsBase + 6}, $${paramsBase + 7}, $${paramsBase + 8}, $${paramsBase + 9}, $${paramsBase + 10},
               $${paramsBase + 11}, $${paramsBase + 12}, $${paramsBase + 13})`
          );

          params.push(
            `${tenantId}-stock-${r.ItemLineId}`,
            tenantId,
            productId,
            userId,
            typeLabel,
            quantity,
            previousQuantity,
            newQuantity,
            moveProp,
            notes,
            referenceId,
            costPrice,
            createdAt,
            branchId
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "StockMovement" (
              id, "tenantId", "productId", "userId", type, quantity, "previousQuantity", "newQuantity",
              reason, notes, "referenceId", "costPrice", "createdAt", "branchId"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              "productId" = EXCLUDED."productId",
              "userId" = EXCLUDED."userId",
              type = EXCLUDED.type,
              quantity = EXCLUDED.quantity,
              "previousQuantity" = EXCLUDED."previousQuantity",
              "newQuantity" = EXCLUDED."newQuantity",
              reason = EXCLUDED.reason,
              notes = EXCLUDED.notes,
              "referenceId" = EXCLUDED."referenceId",
              "costPrice" = EXCLUDED."costPrice",
              "createdAt" = EXCLUDED."createdAt",
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

      lastId = rows[rows.length - 1].ItemLineId;
      console.log(`Stock movements migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ StockMovement migration completed. Total inserted/updated: ${total}`);
    if (skippedMissingProduct) {
      console.warn(`⚠️ Skipped ${skippedMissingProduct} stock movements due to missing products`);
    }
    if (skippedMissingUser) {
      console.warn(`⚠️ Skipped ${skippedMissingUser} stock movements due to missing users`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateStockMovement;
