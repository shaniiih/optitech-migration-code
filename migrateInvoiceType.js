const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

async function migrateInvoiceType(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT InvoiceTypeId, InvoiceTypeName
           FROM tblInvoiceTypes
          WHERE InvoiceTypeId > ?
          ORDER BY InvoiceTypeId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();
        const seenIds = new Set();

        for (const row of chunk) {
          const invoiceTypeId = asInteger(row.InvoiceTypeId);
          if (invoiceTypeId === null) continue;
          if (seenIds.has(invoiceTypeId)) continue;
          seenIds.add(invoiceTypeId);

          const invoiceTypeName =
            cleanText(row.InvoiceTypeName) || `Invoice Type ${invoiceTypeId}`;

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7})`
          );
          params.push(
            createId(),       // id
            tenantId,       // tenantId
            branchId,       // branchId
            invoiceTypeId,  // invoiceTypeId
            invoiceTypeName,// invoiceTypeName
            now,            // createdAt
            now             // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "InvoiceType" (
               id,
               "tenantId",
               "branchId",
               "invoiceTypeId",
               "invoiceTypeName",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "invoiceTypeId") DO UPDATE SET
               "invoiceTypeName" = EXCLUDED."invoiceTypeName",
               "updatedAt" = EXCLUDED."updatedAt"`,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      lastId = asInteger(rows[rows.length - 1]?.InvoiceTypeId) ?? lastId;
      console.log(`InvoiceType migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ InvoiceType migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateInvoiceType;
