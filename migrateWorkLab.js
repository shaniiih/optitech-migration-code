const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE  = 1000;

async function migrateWorkLab(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;

  try {
    await pg.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_indexes WHERE indexname = 'worklab_tenant_labid_ux'
        ) THEN
          CREATE UNIQUE INDEX worklab_tenant_labid_ux
          ON "WorkLab" ("tenantId","labId");
        END IF;
      END$$;
    `);

    while (true) {
      const [rows] = await mysql.execute(
        `SELECT LabID, LabName, IdCount
           FROM sqlWorkLab
          WHERE LabID > ?
          ORDER BY LabID
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );
      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        for (const r of chunk) {
          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7})`
          );
          params.push(
            uuidv4(),        // id
            tenantId,        // tenantId
            r.LabID,         // labId
            r.LabName,       // name
            null,            // description
            true,            // isActive
            now              // updatedAt
          );
        }

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "WorkLab" (
              id, "tenantId", "labId", name, description, "isActive", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("labId")
            DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              name = EXCLUDED.name,
              description = COALESCE(EXCLUDED.description, "WorkLab".description),
              "isActive" = EXCLUDED."isActive",
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (e) {
          await pg.query("ROLLBACK");
          throw e;
        }

        total += chunk.length;
      }

      lastId = rows[rows.length - 1].LabID;
      console.log(`WorkLabs migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ WorkLab migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateWorkLab;
