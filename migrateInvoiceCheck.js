const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function normalizeInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  if (typeof value === "bigint") return Number(value);
  if (Buffer.isBuffer(value)) return normalizeInt(value.toString("utf8"));
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function cleanNumber(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? value : null;
  if (typeof value === "bigint") return Number(value);
  if (Buffer.isBuffer(value)) return cleanNumber(value.toString("utf8"));
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? parsed : null;
}

async function migrateInvoiceCheck(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    const invoicePayMap = new Map();

    const { rows: invoicePayRows } = await pg.query(
      `SELECT id, "invoicePayId"
       FROM "InvoicePay"
       WHERE "tenantId" = $1 AND "branchId" = $2`,
      [tenantId, branchId]
    );

    for (const row of invoicePayRows) {
      const legacyId = normalizeInt(row.invoicePayId);
      if (legacyId !== null) invoicePayMap.set(legacyId, row.id);
    }

    while (true) {
      const [rows] = await mysql.query(
        `
        SELECT InvoiceCheckId, InvoicePayId, CheckId, CheckDate, CheckSum
        FROM tblInvoiceChecks
        ORDER BY InvoiceCheckId
        LIMIT ? OFFSET ?`,
        [WINDOW_SIZE, offset]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        for (const row of chunk) {
          const legacyInvoiceCheckId = normalizeInt(row.InvoiceCheckId);
          const legacyInvoicePayId = normalizeInt(row.InvoicePayId);

          const invoicePayId = invoicePayMap.get(legacyInvoicePayId) || null;

          const base = params.length;

          values.push(
            `(
              $${base + 1}, $${base + 2}, $${base + 3}, $${base + 4},
              $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8},
              $${base + 9}, $${base + 10}, $${base + 11}
            )`
          );

          params.push(
            createId(),                
            tenantId,                 
            branchId,                 
            legacyInvoiceCheckId,    
            legacyInvoicePayId,       
            invoicePayId,             
            row.CheckId || null,      
            row.CheckDate ? new Date(row.CheckDate) : null, 
            cleanNumber(row.CheckSum),
            now,
            now
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "InvoiceCheck" (
              id, "tenantId", "branchId", "invoiceCheckId", "legacyInvoicePayId",
              "invoicePayId", "checkId", "checkDate", "checkSum",
              "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "invoiceCheckId")
            DO UPDATE SET
              "legacyInvoicePayId" = EXCLUDED."legacyInvoicePayId",
              "invoicePayId" = EXCLUDED."invoicePayId",
              "checkId" = EXCLUDED."checkId",
              "checkDate" = EXCLUDED."checkDate",
              "checkSum" = EXCLUDED."checkSum",
              "updatedAt" = NOW();
            `,
            params
          );

          await pg.query("COMMIT");
          total += values.length;
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }
      }

      offset += rows.length;
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateInvoiceCheck;
