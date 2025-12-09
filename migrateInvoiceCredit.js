const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function asNumber(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? value : null;
  }
  const trimmed = String(value).trim().replace(/,/g, ".");
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? parsed : null;
}

function normalizeDate(value) {
  if (value === null || value === undefined) return null;

  if (typeof value === "string") {
    const trimmed = value.trim();
    if (!trimmed || /^0{4}-0{2}-0{2}/.test(trimmed)) return null;
    const parsed = new Date(trimmed);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value;
  }

  if (typeof value === "number") {
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  return null;
}

/**
 * Migrate tblInvoiceCredits → InvoiceCredit
 * - Preserves legacy InvoiceCreditId and InvoicePayId
 * - Resolves new InvoicePay.id (string) into InvoiceCredit.invoicePayId
 */
async function migrateInvoiceCredit(tenantId, branchId) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let total = 0;
  let offset = 0;

  try {
    // Build lookup map: legacy InvoicePayId (int) -> new InvoicePay.id (string)
    const invoicePayMap = new Map();
    {
      const { rows } = await pg.query(
        `
        SELECT id, "invoicePayId"
        FROM "InvoicePay"
        WHERE "tenantId" = $1
          AND "branchId" = $2
        `,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const legacy = asInteger(row.invoicePayId);
        if (legacy !== null && !invoicePayMap.has(legacy)) {
          invoicePayMap.set(legacy, row.id);
        }
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `
        SELECT InvoiceCreditId, InvoicePayId, CreditDate, CreditSum
        FROM tblInvoiceCredits
        ORDER BY InvoiceCreditId
        LIMIT ${WINDOW_SIZE} OFFSET ?
        `,
        [offset]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        for (const row of chunk) {
          const legacyInvoiceCreditId = asInteger(row.InvoiceCreditId);
          const legacyInvoicePayId = asInteger(row.InvoicePayId);
          const invoicePayId =
            legacyInvoicePayId !== null
              ? invoicePayMap.get(legacyInvoicePayId) || null
              : null;

          const creditDate = normalizeDate(row.CreditDate);
          const amount = asNumber(row.CreditSum) ?? 0;

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9}, $${base + 10})`
          );

          params.push(
            createId(),              // id
            tenantId,                // tenantId
            branchId,                // branchId
            legacyInvoiceCreditId,   // invoiceCreditId (legacy)
            legacyInvoicePayId,      // legacyInvoicePayId
            invoicePayId,            // invoicePayId (FK to InvoicePay.id)
            creditDate,              // creditDate
            amount,                  // amount (Decimal)
            now,                     // createdAt
            now                      // updatedAt
          );
        }

        if (!values.length) {
          continue;
        }

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "InvoiceCredit" (
              id,
              "tenantId",
              "branchId",
              "invoiceCreditId",
              "legacyInvoicePayId",
              "invoicePayId",
              "creditDate",
              amount,
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId","branchId","invoiceCreditId")
            DO UPDATE SET
              "creditDate" = EXCLUDED."creditDate",
              amount = EXCLUDED.amount,
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
          total += chunk.length;
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }
      }

      offset += rows.length;
      console.log(`InvoiceCredit migrated: ${total} (offset=${offset})`);
    }

    console.log(`✅ InvoiceCredit migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateInvoiceCredit;

