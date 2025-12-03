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

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
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

async function migrateInvoicePay(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;

  try {
    // Build lookup maps from legacy numeric IDs to new UUID PKs
    const sapakMap = new Map();
    const payTypeMap = new Map();
    const creditCardMap = new Map();

    {
      const { rows } = await pg.query(
        `
        SELECT id, "SapakID"
        FROM "Sapak"
        WHERE "tenantId" = $1
          AND "branchId" = $2
        `,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const legacyId = asInteger(row.SapakID);
        if (legacyId !== null && !sapakMap.has(legacyId)) {
          sapakMap.set(legacyId, row.id);
        }
      }
    }

    {
      const { rows } = await pg.query(
        `
        SELECT id, "payTypeId"
        FROM "PayType"
        WHERE "tenantId" = $1
          AND "branchId" = $2
        `,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const legacyId = asInteger(row.payTypeId);
        if (legacyId !== null && !payTypeMap.has(legacyId)) {
          payTypeMap.set(legacyId, row.id);
        }
      }
    }

    {
      const { rows } = await pg.query(
        `
        SELECT id, "creditCardId"
        FROM "CreditCard"
        WHERE "tenantId" = $1
          AND "branchId" = $2
        `,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const legacyId = asInteger(row.creditCardId);
        if (legacyId !== null && !creditCardMap.has(legacyId)) {
          creditCardMap.set(legacyId, row.id);
        }
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT InvoicePayId, SapakID, ReceiptId, PayTypeId, CashSum, CreditId, CashDate, CreditCardId
           FROM tblInvoicePays
          WHERE InvoicePayId > ?
          ORDER BY InvoicePayId
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
          const invoicePayId = asInteger(row.InvoicePayId);
          if (invoicePayId === null) continue;

          const legacySapakId = asInteger(row.SapakID);
          const receiptId = cleanText(row.ReceiptId);
          const legacyPayTypeId = asInteger(row.PayTypeId);
          const cashSum = asNumber(row.CashSum);
          const creditId = cleanText(row.CreditId);
          const cashDate = normalizeDate(row.CashDate);
          const legacyCreditCardId = asInteger(row.CreditCardId);

          const sapakId = legacySapakId !== null ? sapakMap.get(legacySapakId) || null : null;
          const payTypeId = legacyPayTypeId !== null ? payTypeMap.get(legacyPayTypeId) || null : null;
          const creditCardId = legacyCreditCardId !== null ? creditCardMap.get(legacyCreditCardId) || null : null;

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9}, $${base + 10}, $${base + 11}, $${base + 12}, $${base + 13}, $${base + 14}, $${base + 15}, $${base + 16})`
          );

          params.push(
            createId(),           // id
            tenantId,           // tenantId
            branchId,           // branchId
            invoicePayId,       // invoicePayId
            legacySapakId,      // legacySapakId
            sapakId,            // sapakId (FK to Sapak)
            receiptId,          // receiptId
            legacyPayTypeId,    // legacyPayTypeId
            payTypeId,          // payTypeId (FK to PayType)
            cashSum,            // cashSum
            creditId,           // creditId
            cashDate,           // cashDate
            legacyCreditCardId, // legacyCreditCardId
            creditCardId,       // creditCardId (FK to CreditCard)
            now,                // createdAt
            now                 // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "InvoicePay" (
              id,
              "tenantId",
              "branchId",
              "invoicePayId",
              "legacySapakId",
              "sapakId",
              "receiptId",
              "legacyPayTypeId",
              "payTypeId",
              "cashSum",
              "creditId",
              "cashDate",
              "legacyCreditCardId",
              "creditCardId",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "invoicePayId")
            DO UPDATE SET
              "receiptId" = EXCLUDED."receiptId",
              "cashSum" = EXCLUDED."cashSum",
              "creditId" = EXCLUDED."creditId",
              "cashDate" = EXCLUDED."cashDate",
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

      lastId = rows[rows.length - 1].InvoicePayId;
      console.log(`InvoicePay migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ InvoicePay migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateInvoicePay;
