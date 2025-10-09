const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
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
    if (!trimmed) return null;
    if (/^0{4}-0{2}-0{2}/.test(trimmed)) return null;
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

function normalizeLegacyId(value) {
  if (value === null || value === undefined) return null;

  if (typeof value === "number" && Number.isFinite(value)) {
    return String(value);
  }

  if (typeof value === "bigint") {
    return value.toString();
  }

  if (Buffer.isBuffer(value)) {
    return normalizeLegacyId(value.toString("utf8"));
  }

  const trimmed = String(value).trim();
  if (!trimmed) return null;

  if (/^[+-]?\d+(?:\.0+)?$/.test(trimmed)) {
    return String(parseInt(trimmed, 10));
  }

  return trimmed.toLowerCase();
}

async function migrateInvoice(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  let skippedMissingSupplier = 0;

  try {
    const supplierMap = new Map();
    const supplierCache = new Map();
    const { rows: supplierRows } = await pg.query(
      `SELECT id, "supplierId" FROM "Supplier" WHERE "tenantId" = $1`,
      [tenantId]
    );
    for (const row of supplierRows) {
      supplierMap.set(normalizeLegacyId(row.supplierId), row.id);
    }

    const supplierNameMap = new Map();
    const [sapakRows] = await mysql.query(
      `SELECT SapakID, SapakName FROM tblSapaks`
    );
    for (const row of sapakRows) {
      const key = normalizeLegacyId(row.SapakID);
      if (key && !supplierNameMap.has(key)) {
        supplierNameMap.set(key, cleanText(row.SapakName));
      }
    }

    const [workSapakRows] = await mysql.query(
      `SELECT SapakID, SapakName FROM tblCrdBuysWorkSapaks`
    );
    for (const row of workSapakRows) {
      const key = normalizeLegacyId(row.SapakID);
      if (key && !supplierNameMap.has(key)) {
        supplierNameMap.set(key, cleanText(row.SapakName));
      }
    }

    async function ensureSupplier(legacyId) {
      const key = normalizeLegacyId(legacyId);
      if (!key) return null;
      if (supplierMap.has(key)) {
        return supplierMap.get(key);
      }

      if (!supplierCache.has(key)) {
        supplierCache.set(
          key,
          (async () => {
            const supplierRecordId = `${tenantId}-supplier-${key}`;
            const name = supplierNameMap.get(key) || `Legacy Supplier ${key}`;
            const timestamp = new Date();
            const { rows } = await pg.query(
              `
              INSERT INTO "Supplier" (id, "tenantId", "supplierId", name, "createdAt", "updatedAt")
              VALUES ($1, $2, $3, $4, $5, $5)
              ON CONFLICT ("supplierId")
              DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
                "supplierId" = EXCLUDED."supplierId",
                name = EXCLUDED.name,
                "updatedAt" = EXCLUDED."updatedAt"
              RETURNING id
              `,
              [supplierRecordId, tenantId, key, name, timestamp]
            );
            const dbId = rows[0].id;
            supplierMap.set(key, dbId);
            return dbId;
          })()
        );
      }

      return supplierCache.get(key);
    }

    const invoiceTypeMap = new Map();
    const [invoiceTypeRows] = await mysql.query(
      `SELECT InvoiceTypeId, InvoiceTypeName FROM tblInvoiceTypes`
    );
    for (const row of invoiceTypeRows) {
      const key = normalizeLegacyId(row.InvoiceTypeId);
      if (key) {
        invoiceTypeMap.set(key, cleanText(row.InvoiceTypeName) || `TYPE-${row.InvoiceTypeId}`);
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT InvoiceId, SapakID, InvoicePayId, InvoiceTypeId, InvId, InvDate, InvSum, Com
           FROM tblInvoices
          WHERE InvoiceId > ?
          ORDER BY InvoiceId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const r of chunk) {
          const supplierId = await ensureSupplier(r.SapakID);
          if (!supplierId) {
            skippedMissingSupplier += 1;
            continue;
          }

          const invoiceNumber = cleanText(r.InvId) || String(r.InvoiceId);
          const invoiceDate = normalizeDate(r.InvDate) || new Date();
          const amount = asNumber(r.InvSum) ?? 0;
          const invoiceType = invoiceTypeMap.get(normalizeLegacyId(r.InvoiceTypeId)) || "UNKNOWN";
          const comment = cleanText(r.Com);
          const status = amount > 0 ? "PENDING" : "PAID";

          const paramsBase = params.length;
          values.push(
            `($${paramsBase + 1}, $${paramsBase + 2}, $${paramsBase + 3}, $${paramsBase + 4}, $${paramsBase + 5},
               $${paramsBase + 6}, $${paramsBase + 7}, $${paramsBase + 8}, $${paramsBase + 9}, $${paramsBase + 10},
               $${paramsBase + 11}, $${paramsBase + 12}, $${paramsBase + 13}, $${paramsBase + 14})`
          );

          params.push(
            uuidv4(),
            tenantId,
            String(r.InvoiceId),
            invoiceNumber,
            supplierId,
            invoiceDate,
            null,
            amount,
            0,
            invoiceType,
            comment,
            status,
            invoiceDate,
            invoiceDate
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "Invoice" (
              id, "tenantId", "invoiceId", "invoiceNumber", "supplierId", "invoiceDate", "dueDate",
              "totalAmount", "paidAmount", "invoiceType", comment, status, "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("invoiceId")
            DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              "invoiceNumber" = EXCLUDED."invoiceNumber",
              "supplierId" = EXCLUDED."supplierId",
              "invoiceDate" = EXCLUDED."invoiceDate",
              "dueDate" = EXCLUDED."dueDate",
              "totalAmount" = EXCLUDED."totalAmount",
              "paidAmount" = EXCLUDED."paidAmount",
              "invoiceType" = EXCLUDED."invoiceType",
              comment = EXCLUDED.comment,
              status = EXCLUDED.status,
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }

        total += values.length;
      }

      lastId = rows[rows.length - 1].InvoiceId;
      console.log(`Invoices migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ Invoice migration completed. Total inserted/updated: ${total}`);
    if (skippedMissingSupplier) {
      console.warn(`⚠️ Skipped ${skippedMissingSupplier} invoices because related suppliers were not found`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateInvoice;
