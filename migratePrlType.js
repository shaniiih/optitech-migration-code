const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

async function migratePrlType(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1; // include potential zero
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.execute(
        `SELECT prlType, prlName
         FROM tblPrlTypes
         WHERE prlType > ?
         ORDER BY prlType
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
          const typeId = Number(row.prlType);
          if (!Number.isFinite(typeId)) continue;

          const rawName = typeof row.prlName === "string" ? row.prlName.trim() : "";
          const name = rawName || `PRL Type ${typeId}`;

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7})`
          );
          params.push(
            uuidv4(),  // id
            tenantId,  // tenantId
            branchId,  // branchId
            typeId,    // prlType
            name,      // prlName
            now,       // createdAt
            now        // updatedAt
          );
        }

        const insertCount = values.length;
        if (!insertCount) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "PrlType" (
              id, "tenantId", "branchId", "prlType", "prlName", "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "prlType")
            DO UPDATE SET
              "prlName" = EXCLUDED."prlName",
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

      const latestId = Number(rows[rows.length - 1].prlType);
      if (Number.isFinite(latestId)) {
        lastId = latestId;
      }
      console.log(`PrlTypes migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ PrlType migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migratePrlType;
