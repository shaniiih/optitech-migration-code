const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function normalizeInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  if (typeof value === "bigint") return Number(value);
  if (Buffer.isBuffer(value)) return normalizeInt(value.toString("utf8"));
  const n = Number(String(value).trim());
  return Number.isFinite(n) ? Math.trunc(n) : null;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

async function migrateSpecialName(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1; // SpecialId can start at 0
  let total = 0;

  try {
    await pg.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_indexes WHERE indexname = 'specialname_tenant_specialid_ux'
        ) THEN
          CREATE UNIQUE INDEX specialname_tenant_specialid_ux
          ON "SpecialName" ("tenantId", "specialId");
        END IF;
      END$$;
    `);

    while (true) {
      const [rows] = await mysql.query(
        `SELECT SpecialId, SpecialName
           FROM tblSpecialNames
          WHERE SpecialId > ?
          ORDER BY SpecialId
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
          const specialId = normalizeInt(row.SpecialId);
          if (specialId === null) continue;
          const specialName = cleanText(row.SpecialName);

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7})`
          );
          params.push(
            uuidv4(),      // id
            tenantId,      // tenantId
            branchId,      // branchId
            specialId,     // specialId
            specialName,   // specialName
            now,           // createdAt
            now            // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "SpecialName" (
              id,
              "tenantId",
              "branchId",
              "specialId",
              "specialName",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "specialId")
            DO UPDATE SET
              "branchId" = EXCLUDED."branchId",
              "specialName" = EXCLUDED."specialName",
              "updatedAt" = EXCLUDED."updatedAt"
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

      const last = rows[rows.length - 1];
      const latestId = normalizeInt(last.SpecialId);
      if (latestId !== null) lastId = latestId;
      console.log(`SpecialName migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ SpecialName migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateSpecialName;
