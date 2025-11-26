const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

async function migrateCreditCard(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1; // include potential zero id
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.execute(
        `SELECT CreditCardId, CreditCardName
         FROM tblCreditCards
         WHERE CreditCardId > ?
         ORDER BY CreditCardId
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
          const creditCardId = Number(row.CreditCardId);
          if (!Number.isFinite(creditCardId)) continue;

          const rawName =
            typeof row.CreditCardName === "string" ? row.CreditCardName.trim() : "";
          const creditCardName = rawName || `Credit Card ${creditCardId}`;

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7})`
          );
          params.push(
            uuidv4(),        // id
            tenantId,        // tenantId
            branchId,        // branchId
            creditCardId,    // creditCardId
            creditCardName,  // creditCardName
            now,             // createdAt
            now              // updatedAt
          );
        }

        const insertCount = values.length;
        if (!insertCount) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "CreditCard" (
              id, "tenantId", "branchId", "creditCardId", "creditCardName",
              "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "creditCardId")
            DO UPDATE SET
              "creditCardName" = EXCLUDED."creditCardName",
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

      const latestId = Number(rows[rows.length - 1].CreditCardId);
      if (Number.isFinite(latestId)) {
        lastId = latestId;
      }
      console.log(`CreditCards migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ CreditCard migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCreditCard;
