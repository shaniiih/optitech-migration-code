const { v4: uuidv4 } = require("uuid");
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

async function migrateItemCount(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    // Build maps from legacy IDs to new UUIDs
    const itemMap = new Map();
    const yearMap = new Map();

    {
      const { rows } = await pg.query(
        `SELECT id, "itemId" FROM "Item" WHERE "tenantId" = $1 AND "branchId" = $2`,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const legacyId = normalizeInt(row.itemId);
        if (legacyId !== null && !itemMap.has(legacyId)) {
          itemMap.set(legacyId, row.id);
        }
      }
    }

    {
      const { rows } = await pg.query(
        `SELECT id, "countYear" FROM "ItemCountsYear" WHERE "tenantId" = $1 AND "branchId" = $2`,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const legacyId = normalizeInt(row.countYear);
        if (legacyId !== null && !yearMap.has(legacyId)) {
          yearMap.set(legacyId, row.id);
        }
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT ItemCountId, CountYear, ItemId, CalcQuantity, CountQuantity, CalcValue, BuyPrice
           FROM tblItemCounts
          ORDER BY ItemCountId
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
          const itemCountId = normalizeInt(row.ItemCountId);
          const legacyCountYear = normalizeInt(row.CountYear);
          const legacyItemId = normalizeInt(row.ItemId);
          const calcQuantity = normalizeInt(row.CalcQuantity);
          const countQuantity = normalizeInt(row.CountQuantity);
          const calcValue = cleanNumber(row.CalcValue);
          const buyPrice = cleanNumber(row.BuyPrice);

          const countYear = yearMap.get(legacyCountYear) || null;
          const itemId = itemMap.get(legacyItemId) || null;

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9}, $${base + 10}, $${base + 11}, $${base + 12}, $${base + 13}, $${base + 14})`
          );

          params.push(
            uuidv4(),          // id
            tenantId,          // tenantId
            branchId,          // branchId
            itemCountId,       // itemCountId
            legacyCountYear,   // legacyCountYear
            legacyItemId,      // legacyItemId
            countYear,         // countYear (UUID)
            itemId,            // itemId (UUID)
            calcQuantity,      // calcQuantity
            countQuantity,     // countQuantity
            calcValue,         // calcValue
            buyPrice,          // buyPrice
            now,               // createdAt
            now                // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "ItemCount" (
              id,
              "tenantId",
              "branchId",
              "itemCountId",
              "legacyCountYear",
              "legacyItemId",
              "countYear",
              "itemId",
              "calcQuantity",
              "countQuantity",
              "calcValue",
              "buyPrice",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "itemCountId")
            DO UPDATE SET
              "legacyCountYear" = EXCLUDED."legacyCountYear",
              "legacyItemId" = EXCLUDED."legacyItemId",
              "countYear" = EXCLUDED."countYear",
              "itemId" = EXCLUDED."itemId",
              "calcQuantity" = EXCLUDED."calcQuantity",
              "countQuantity" = EXCLUDED."countQuantity",
              "calcValue" = EXCLUDED."calcValue",
              "buyPrice" = EXCLUDED."buyPrice",
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
      console.log(`ItemCount migrated so far: ${total} (offset=${offset})`);
    }

    console.log(`✅ ItemCount migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateItemCount;
