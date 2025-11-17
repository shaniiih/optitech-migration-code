const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

async function migrateClndrTasksPriority(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1; // include zero if present
  let total = 0;

  try {
    await pg.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_indexes WHERE indexname = 'clndr_tasks_priority_tenant_priorityid_ux'
        ) THEN
          CREATE UNIQUE INDEX clndr_tasks_priority_tenant_priorityid_ux
          ON "ClndrTasksPriority" ("tenantId","priorityId");
        END IF;
      END$$;
    `);

    while (true) {
      const [rows] = await mysql.execute(
        `SELECT PriorityId, PriorityName
           FROM tblClndrTasksPriority
          WHERE PriorityId > ?
          ORDER BY PriorityId
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
          const priorityId = Number(row.PriorityId);
          if (!Number.isFinite(priorityId)) continue;

          const rawName =
            typeof row.PriorityName === "string" ? row.PriorityName.trim() : "";
          const priorityName = rawName || `Priority ${priorityId}`;

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7})`
          );
          params.push(
            uuidv4(),        // id
            tenantId,        // tenantId
            branchId,        // branchId
            priorityId,      // priorityId
            priorityName,    // priorityName
            now,             // createdAt
            now              // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "ClndrTasksPriority" (
              id, "tenantId", "branchId", "priorityId", "priorityName", "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "priorityId")
            DO UPDATE SET
              "branchId" = EXCLUDED."branchId",
              "priorityName" = EXCLUDED."priorityName",
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }

        total += values.length;
      }

      const latestId = Number(rows[rows.length - 1].PriorityId);
      if (Number.isFinite(latestId)) {
        lastId = latestId;
      }
      console.log(`ClndrTasksPriority migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ ClndrTasksPriority migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateClndrTasksPriority;
