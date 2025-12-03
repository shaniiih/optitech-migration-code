const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function normalizeId(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  if (typeof value === "bigint") {
    return Number(value);
  }
  if (Buffer.isBuffer(value)) {
    return normalizeId(value.toString("utf8"));
  }
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function cleanBoolean(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "boolean") return value;
  if (typeof value === "number") return value !== 0;
  const trimmed = String(value).trim().toLowerCase();
  if (!trimmed) return null;
  if (["1", "true", "t", "yes", "y"].includes(trimmed)) return true;
  if (["0", "false", "f", "no", "n"].includes(trimmed)) return false;
  return null;
}

function cleanFloat(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? value : null;
  if (typeof value === "bigint") return Number(value);
  if (Buffer.isBuffer(value)) {
    return cleanFloat(value.toString("utf8"));
  }
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? parsed : null;
}

async function migrateItem(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    // Build a map: legacy ItemStatId (int) -> ItemStat PK (string) for this tenant/branch
    const itemStatMap = new Map();
    {
      const { rows } = await pg.query(
        `
        SELECT id, "itemStatId"
        FROM "ItemStat"
        WHERE "tenantId" = $1
          AND "branchId" = $2
        `,
        [tenantId, branchId]
      );

      for (const row of rows) {
        const legacyId = normalizeId(row.itemStatId);
        if (legacyId !== null && !itemStatMap.has(legacyId)) {
          itemStatMap.set(legacyId, row.id);
        }
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT ItemId, ExCatNum, BarCode, ItemStatId, Active, SapakBC, SalePrice
           FROM tblItems
          WHERE ItemId > ?
          ORDER BY ItemId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        for (const row of chunk) {
          const itemId = normalizeId(row.ItemId);
          if (itemId === null) continue;

          const exCatNum = cleanText(row.ExCatNum);
          const barCode = cleanText(row.BarCode);
          const legacyItemStatId = normalizeId(row.ItemStatId);
          const itemStatPk =
            legacyItemStatId !== null
              ? itemStatMap.get(legacyItemStatId) || null
              : null;
          const active = cleanBoolean(row.Active);
          const sapakBC = cleanText(row.SapakBC);
          const salePrice = cleanFloat(row.SalePrice);

          // Active and ExCatNum are NOT NULL in the legacy schema,
          // so we skip rows where cleaning produces null.
          if (exCatNum === null || active === null) continue;

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10}, $${params.length + 11}, $${params.length + 12}, $${params.length + 13})`
          );
          params.push(
            createId(), // id
            tenantId,
            branchId,
            itemId,
            exCatNum,
            barCode,
            legacyItemStatId,
            itemStatPk,
            active,
            sapakBC,
            salePrice,
            now, // createdAt
            now  // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "Item" (
              id,
              "tenantId",
              "branchId",
              "itemId",
              "exCatNum",
              "barCode",
              "legacyItemStatId",
              "itemStatId",
              "active",
              "sapakBC",
              "salePrice",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "itemId")
            DO UPDATE SET
              "exCatNum" = EXCLUDED."exCatNum",
              "barCode" = EXCLUDED."barCode",
              "legacyItemStatId" = EXCLUDED."legacyItemStatId",
              "active" = EXCLUDED."active",
              "sapakBC" = EXCLUDED."sapakBC",
              "salePrice" = EXCLUDED."salePrice",
              "updatedAt" = NOW()
            `,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      lastId = rows[rows.length - 1].ItemId ?? lastId;
      console.log(`Item migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ Item migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateItem;
