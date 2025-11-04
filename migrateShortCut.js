const { v4: uuidv4 } = require("uuid");
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

async function migrateShortCut(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    // Ensure a deterministic upsert key per tenant
    await pg.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_indexes WHERE indexname = 'shortcut_tenant_prkey_ux'
        ) THEN
          CREATE UNIQUE INDEX shortcut_tenant_prkey_ux
          ON "ShortCut" ("tenantId", "prKey");
        END IF;
      END$$;
    `);

    while (true) {
      const [rows] = await mysql.query(
        `SELECT PrKey, ShKey, \`Desc\` AS DescVal
           FROM tblShortCuts
          WHERE PrKey > ?
          ORDER BY PrKey
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
          const prKey = normalizeId(row.PrKey);
          if (prKey === null) continue;

          const shKey = cleanText(row.ShKey);
          const desc = cleanText(row.DescVal);

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8})`
          );
          params.push(
            uuidv4(),
            tenantId,
            branchId,
            prKey,
            shKey,
            desc,
            now,
            now
          );
          // updatedAt provided for insert; also refreshed on conflict
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "ShortCut" (
              id,
              "tenantId",
              "branchId",
              "prKey",
              "shKey",
              "desc",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "prKey")
            DO UPDATE SET
              "branchId" = EXCLUDED."branchId",
              "shKey" = EXCLUDED."shKey",
              "desc" = EXCLUDED."desc",
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

      lastId = rows[rows.length - 1].PrKey ?? lastId;
      console.log(`ShortCut migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ ShortCut migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateShortCut;
