const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

async function migrateSolutionName(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1; // include potential zero id
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.execute(
        `SELECT SolutionId, SolutionName
         FROM tblSolutionNames
         WHERE SolutionId > ?
         ORDER BY SolutionId
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
          const solutionId = Number(row.SolutionId);
          if (!Number.isFinite(solutionId)) continue;

          const rawName =
            typeof row.SolutionName === "string" ? row.SolutionName.trim() : "";
          const solutionName = rawName || `Solution ${solutionId}`;

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7})`
          );
          params.push(
            uuidv4(),       // id
            tenantId,       // tenantId
            branchId,       // branchId
            solutionId,     // solutionId
            solutionName,   // solutionName
            now,            // createdAt
            now             // updatedAt
          );
        }

        const insertCount = values.length;
        if (!insertCount) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "SolutionName" (
              id, "tenantId", "branchId", "solutionId", "solutionName",
              "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "solutionId")
            DO UPDATE SET
              "solutionName" = EXCLUDED."solutionName",
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }

        total += insertCount;
      }

      const latestId = Number(rows[rows.length - 1].SolutionId);
      if (Number.isFinite(latestId)) {
        lastId = latestId;
      }
      console.log(`SolutionNames migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ SolutionName migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateSolutionName;
