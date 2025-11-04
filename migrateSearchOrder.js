const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function normalizeInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  if (typeof value === "bigint") {
    return Number(value);
  }
  if (Buffer.isBuffer(value)) {
    return normalizeInt(value.toString("utf8"));
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

async function migrateSearchOrder(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastItemData = -1;
  let total = 0;

  try {
    // Unique index creation moved to Prisma schema/migrations. Leaving disabled to avoid conflicts.
    // await pg.query(`
    //   DO $$
    //   BEGIN
    //     IF NOT EXISTS (
    //       SELECT 1
    //       FROM pg_indexes
    //       WHERE indexname = 'search_order_tenant_item_list_ux'
    //     ) THEN
    //       CREATE UNIQUE INDEX search_order_tenant_item_list_ux
    //       ON "SearchOrder" ("tenantId", "itemData", "listIndex");
    //     END IF;
    //   END$$;
    // `);

    while (true) {
      const [rows] = await mysql.query(
        `SELECT ItemData, ListIndex, \`Desc\`, Deaf
           FROM tblSearchOrder
          WHERE ItemData > ?
          ORDER BY ItemData
          LIMIT ${WINDOW_SIZE}`,
        [lastItemData]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        for (const row of chunk) {
          const itemData = normalizeInt(row.ItemData);
          if (itemData === null) continue;

          const listIndex = normalizeInt(row.ListIndex);
          const desc = cleanText(row.Desc);
          const deaf = normalizeInt(row.Deaf);

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9})`
          );
          params.push(
            uuidv4(),
            tenantId,
            branchId,
            itemData,
            listIndex,
            desc,
            deaf,
            now,
            now
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "SearchOrder" (
              id,
              "tenantId",
              "branchId",
              "itemData",
              "listIndex",
              "desc",
              "deaf",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "itemData", "listIndex")
            DO UPDATE SET
              "branchId" = EXCLUDED."branchId",
              "desc" = EXCLUDED."desc",
              "deaf" = EXCLUDED."deaf",
              "updatedAt" = EXCLUDED."updatedAt"
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

      lastItemData = rows[rows.length - 1].ItemData ?? lastItemData;
      console.log(
        `SearchOrder migrated so far: ${total} (lastItemData=${lastItemData})`
      );
    }

    console.log(`✅ SearchOrder migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateSearchOrder;
