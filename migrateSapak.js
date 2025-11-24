const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
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

async function migrateSapak(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    await pg.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1
          FROM pg_indexes
          WHERE schemaname = 'public'
            AND indexname = 'sapak_tenant_id_ux'
        ) THEN
          CREATE UNIQUE INDEX sapak_tenant_id_ux
          ON "Sapak" ("tenantId","SapakID");
        END IF;
      END$$;
    `);

    while (true) {
      const [rows] = await mysql.query(
        `SELECT SapakID, SapakName
           FROM tblSapaks
          WHERE SapakID > ?
          ORDER BY SapakID
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();
        const seenIds = new Set(); // avoid duplicates in same statement

        for (const row of chunk) {
          const sapakId = asInteger(row.SapakID);
          if (sapakId === null) continue;
          if (seenIds.has(sapakId)) continue;
          seenIds.add(sapakId);

          const sapakName = cleanText(row.SapakName) || `Sapak ${sapakId}`;

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7})`
          );
          params.push(
            uuidv4(),     // id
            tenantId,     // tenantId
            branchId,     // branchId
            sapakId,      // SapakID
            sapakName,    // SapakName
            timestamp,    // createdAt
            timestamp     // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "Sapak" (
               id,
               "tenantId",
               "branchId",
               "SapakID",
               "SapakName",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "SapakID") DO UPDATE SET
               "SapakName" = EXCLUDED."SapakName",
               "updatedAt" = EXCLUDED."updatedAt"`,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      const latestId = asInteger(rows[rows.length - 1]?.SapakID);
      if (latestId !== null) {
        lastId = latestId;
      }
      console.log(`Sapak migrated so far: ${total} (lastSapakID=${lastId})`);
    }

    console.log(`✅ Sapak migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateSapak;
