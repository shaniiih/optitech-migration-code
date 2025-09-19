const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;  // rows fetched from MySQL per window
const BATCH_SIZE  = 1000;  // rows inserted per Postgres txn

async function migrateInvoiceCredits(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;

  try {
    // Natural key for idempotency: (invoiceId, creditDate, amount)
    // Adjust if you later add an externalId column.
    await pg.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_indexes WHERE indexname = 'invoicecredit_natkey_ux'
        ) THEN
          CREATE UNIQUE INDEX invoicecredit_natkey_ux
          ON "InvoiceCredit" ("invoiceId","creditDate","amount");
        END IF;
      END$$;
    `);

    while (true) {
      const [rows] = await mysql.execute(
        `SELECT InvoiceCreditId, InvoicePayId, CreditDate, CreditSum
           FROM tblInvoiceCredits
          WHERE InvoiceCreditId > ?
          ORDER BY InvoiceCreditId
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
          const invoiceId = r.InvoicePayId ? String(r.InvoicePayId) : uuidv4();
          const creditDate = r.CreditDate ? new Date(r.CreditDate) : now;
          const amount = Number(r.CreditSum || 0);

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7})`
          );
          params.push(
            uuidv4(),          // id
            invoiceId,         // "invoiceId"
            creditDate,        // "creditDate"
            amount,            // amount
            null,              // reason
            null,              // reference
            now                // "updatedAt"
          );
        }

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "InvoiceCredit" (
              id, "invoiceId", "creditDate", amount, reason, reference, "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("invoiceId","creditDate","amount")
            DO UPDATE SET
              reason = COALESCE(EXCLUDED.reason, "InvoiceCredit".reason),
              reference = COALESCE(EXCLUDED.reference, "InvoiceCredit".reference),
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

      lastId = rows[rows.length - 1].InvoiceCreditId;
      console.log(`InvoiceCredits migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ InvoiceCredits migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateInvoiceCredits;
