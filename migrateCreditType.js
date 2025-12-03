const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

async function migrateCreditType(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1; // include zero if present
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.execute(
        `SELECT CreditTypeId, CreditTypeName
         FROM tblCreditTypes
         WHERE CreditTypeId > ?
         ORDER BY CreditTypeId
         LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();

        for (const row of chunk) {
          const creditTypeId = Number(row.CreditTypeId);
          if (!Number.isFinite(creditTypeId)) {
            continue;
          }

          const rawName =
            typeof row.CreditTypeName === "string" ? row.CreditTypeName.trim() : "";
          const creditTypeName = rawName || `Credit Type ${creditTypeId}`;

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7})`
          );
          params.push(
            createId(),         // id
            tenantId,         // tenantId
            branchId,         // branchId
            creditTypeId,     // creditTypeId
            creditTypeName,   // creditTypeName
            now,              // createdAt
            now               // updatedAt
          );
        }

        const insertCount = values.length;
        if (!insertCount) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "CreditType" (
              id, "tenantId", "branchId", "creditTypeId", "creditTypeName",
              "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId" ,"creditTypeId")
            DO UPDATE SET
              "creditTypeName" = EXCLUDED."creditTypeName",
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

      const latestId = Number(rows[rows.length - 1].CreditTypeId);
      if (Number.isFinite(latestId)) {
        lastId = latestId;
      }
      console.log(`CreditTypes migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ CreditType migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCreditType;
