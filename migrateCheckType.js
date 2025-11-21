const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE  = 1000;

async function migrateCheckType(tenantId = "tenant_1", branchId) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.execute(
        `SELECT CheckId, CheckName, CheckPrice
         FROM tblCheckTypes
         WHERE CheckId > ?
         ORDER BY CheckId
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
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10})`
          );
          params.push(
            uuidv4(),                  // id
            tenantId,                  // tenantId
            branchId || null,          // branchId
            r.CheckId,                 // checkId
            r.CheckName,               // name
            r.CheckPrice || 0,         // price
            null,                      // description
            true,                      // isActive
            now,                       // createdAt
            now                        // updatedAt
          );
        }

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "CheckType" (
              id,
              "tenantId",
              "branchId",
              "checkId",
              name,
              price,
              description,
              "isActive",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "checkId")
            DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              name = EXCLUDED.name,
              price = EXCLUDED.price,
              description = EXCLUDED.description,
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

      lastId = rows[rows.length - 1].CheckId;
      console.log(`CheckTypes migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ CheckType migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCheckType;
