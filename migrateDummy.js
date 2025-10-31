const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

async function migrateDummy(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    await pg.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1
          FROM pg_indexes
          WHERE indexname = 'dummy_tenant_dummy_ux'
        ) THEN
          CREATE UNIQUE INDEX dummy_tenant_dummy_ux
          ON "Dummy" ("tenantId","dummy");
        END IF;
      END$$;
    `);

    while (true) {
      const [rows] = await mysql.query(
        `SELECT Dummy
         FROM tblDummy
         ORDER BY Dummy
         LIMIT ${WINDOW_SIZE}
         OFFSET ${offset}`
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        for (const row of chunk) {
          const dummyValue = toDummyInt(row.Dummy);
          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6})`
          );
          params.push(
            uuidv4(),    // id
            tenantId,    // tenantId
            branchId,    // branchId
            dummyValue,  // dummy
            now,         // createdAt
            now          // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "Dummy" (
              id, "tenantId", "branchId", dummy, "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", dummy)
            DO UPDATE SET
              "branchId" = EXCLUDED."branchId",
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }

        total += chunk.length;
      }

      offset += rows.length;
      console.log(`Dummy rows migrated so far: ${total} (offset=${offset})`);

      if (rows.length < WINDOW_SIZE) {
        break;
      }
    }

    console.log(`✅ Dummy migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

function toDummyInt(value) {
  if (value === null || value === undefined) return 0;
  if (typeof value === "boolean") return value ? 1 : 0;
  if (typeof value === "number") return value !== 0 ? 1 : 0;
  const normalized = String(value).trim().toLowerCase();
  if (["1", "true", "yes", "y"].includes(normalized)) return 1;
  return 0;
}

module.exports = migrateDummy;
