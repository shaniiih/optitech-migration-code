const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function normalizeInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  if (typeof value === "bigint") return Number(value);
  if (Buffer.isBuffer(value)) return normalizeInt(value.toString("utf8"));
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function cleanNumber(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? value : null;
  if (typeof value === "bigint") return Number(value);
  if (Buffer.isBuffer(value)) return cleanNumber(value.toString("utf8"));
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? parsed : null;
}

async function migrateItemLines(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    const invMap = new Map();
    const itemMap = new Map();

    const { rows: invRows } = await pg.query(
      `SELECT id, "invId" FROM "Inventory" WHERE "tenantId" = $1 AND "branchId" = $2`,
      [tenantId, branchId]
    );
    for (const row of invRows) {
      const legacyId = normalizeInt(row.invId);
      if (legacyId !== null) invMap.set(legacyId, row.id);
    }

    const { rows: itemRows } = await pg.query(
      `SELECT id, "itemId" FROM "Item" WHERE "tenantId" = $1 AND "branchId" = $2`,
      [tenantId, branchId]
    );
    for (const row of itemRows) {
      const legacyId = normalizeInt(row.itemId);
      if (legacyId !== null) itemMap.set(legacyId, row.id);
    }

    while (true) {
      const [rows] = await mysql.query(
        `
        SELECT ItemLineId, InvId, ItemId, Quantity, BuyPrice, SalePrice, Removed, Sold
        FROM tblItemLines
        ORDER BY ItemLineId
        LIMIT ? OFFSET ?`,
        [WINDOW_SIZE, offset]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        for (const row of chunk) {
          const itemLineId = normalizeInt(row.ItemLineId);
          const legacyInvId = normalizeInt(row.InvId);
          const legacyItemId = normalizeInt(row.ItemId);

          const invId = invMap.get(legacyInvId) || null;
          const itemId = itemMap.get(legacyItemId) || null;

          const base = params.length;

          values.push(
            `(
              $${base + 1}, $${base + 2}, $${base + 3}, $${base + 4},
              $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8},
              $${base + 9}, $${base + 10}, $${base + 11}, $${base + 12},
              $${base + 13}, $${base + 14}, $${base + 15}
            )`
          );

          params.push(
            createId(),        
            tenantId,         
            branchId,         
            itemLineId,        
            legacyInvId,       
            invId,            
            legacyItemId,     
            itemId,            
            normalizeInt(row.Quantity),
            cleanNumber(row.BuyPrice),
            cleanNumber(row.SalePrice),
            normalizeInt(row.Removed),
            normalizeInt(row.Sold),
            now,
            now
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "ItemLine" (
              id, "tenantId", "branchId", "itemLineId", "legacyInvId", "invId",
              "legacyItemId", "itemId", quantity, "buyPrice", "salePrice",
              removed, sold, "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "itemLineId")
            DO UPDATE SET
              "legacyInvId" = EXCLUDED."legacyInvId",
              "invId" = EXCLUDED."invId",
              "legacyItemId" = EXCLUDED."legacyItemId",
              "itemId" = EXCLUDED."itemId",
              "quantity" = EXCLUDED."quantity",
              "buyPrice" = EXCLUDED."buyPrice",
              "salePrice" = EXCLUDED."salePrice",
              "removed" = EXCLUDED."removed",
              "sold" = EXCLUDED."sold",
              "updatedAt" = NOW();
            `,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }
      }

      offset += rows.length;
    }

    console.log(`ItemLines migrated. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateItemLines;
