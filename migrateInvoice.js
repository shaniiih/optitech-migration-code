const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  const trimmed = cleanText(value);
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function asNumber(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? value : null;
  const trimmed = cleanText(value);
  if (!trimmed) return null;
  const parsed = Number(trimmed.replace(/,/g, "."));
  return Number.isFinite(parsed) ? parsed : null;
}

function safeDate(value) {
  if (!value) return null;
  if (value instanceof Date) return Number.isNaN(value.getTime()) ? null : value;
  const d = new Date(value);
  return Number.isFinite(d.getTime()) ? d : null;
}

async function migrateInvoice(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  // preload mappings
  const supplierMap = new Map(); // legacy SapakID -> Supplier.id (optional)
  const sapakMap = new Map(); // legacy SapakID -> Sapak.id
  const invoicePayMap = new Map(); // legacy InvoicePayId -> InvoicePay.id
  const invoiceTypeMap = new Map(); // legacy InvoiceTypeId -> {id,name}
  const missingSapak = new Set();
  const missingType = new Set();
  const sapakNameMap = new Map(); // legacy SapakID -> SapakName (from Sapak table)

  try {
    // Preload Sapak from "Sapak" table
    try {
      const { rows } = await pg.query(
        `SELECT id, "SapakID", "SapakName"
           FROM "Sapak"
          WHERE "tenantId" = $1
            AND "branchId" = $2`,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const key = cleanText(row.SapakID);
        if (!key) continue;
        if (!sapakNameMap.has(key)) {
          sapakNameMap.set(key, cleanText(row.SapakName) || `Sapak ${key}`);
        }
        if (!sapakMap.has(key)) sapakMap.set(key, row.id);
        const asInt = asInteger(row.SapakID);
        if (asInt !== null && !sapakMap.has(String(asInt))) sapakMap.set(String(asInt), row.id);
      }
    } catch (err) {
      console.warn("⚠️ Invoice: failed to preload Sapak mapping.", err.message);
    }

    // Also pull Sapak IDs from CrdBuysWorkSapak and ensure Sapak table has them.
    try {
      const { rows } = await pg.query(
        `SELECT "sapakID" AS "legacySapakId", "sapakName"
           FROM "CrdBuysWorkSapak"
          WHERE "tenantId" = $1
            AND "branchId" = $2`,
        [tenantId, branchId]
      );

      const insertValues = [];
      const insertParams = [];
      for (const row of rows) {
        const key = cleanText(row.legacySapakId);
        if (!key) continue;
        if (!sapakNameMap.has(key)) {
          sapakNameMap.set(key, cleanText(row.sapakName) || `Sapak ${key}`);
        }
        if (!sapakMap.has(key)) {
          const base = insertParams.length;
          insertValues.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7})`
          );
          insertParams.push(uuidv4(), tenantId, branchId, key, sapakNameMap.get(key), new Date(), new Date());
        }
      }

      if (insertValues.length) {
        try {
          await pg.query(
            `INSERT INTO "Sapak" (
               id, "tenantId", "branchId", "SapakID", "SapakName", "createdAt", "updatedAt"
             )
             VALUES ${insertValues.join(",")}
             ON CONFLICT ("tenantId", "branchId", "SapakID") DO NOTHING`,
            insertParams
          );
        } catch (err) {
          console.warn("⚠️ Invoice: failed to insert missing Sapak rows from CrdBuysWorkSapak.", err.message);
        }
      }

      // Reload Sapak mapping after potential inserts
      try {
        const { rows: sapakRows } = await pg.query(
          `SELECT id, "SapakID", "SapakName"
             FROM "Sapak"
            WHERE "tenantId" = $1
              AND "branchId" = $2`,
          [tenantId, branchId]
        );
        for (const row of sapakRows) {
          const key = cleanText(row.SapakID);
          if (!key) continue;
          sapakMap.set(key, row.id);
          const asInt = asInteger(row.SapakID);
          if (asInt !== null) sapakMap.set(String(asInt), row.id);
          if (!sapakNameMap.has(key)) {
            sapakNameMap.set(key, cleanText(row.SapakName) || `Sapak ${key}`);
          }
        }
      } catch (err) {
        console.warn("⚠️ Invoice: failed to refresh Sapak mapping after inserts.", err.message);
      }
    } catch (err) {
      console.warn("⚠️ Invoice: failed to process CrdBuysWorkSapak for Sapak mapping.", err.message);
    }

    // Optional Supplier mapping (if Supplier table populated)
    try {
      const { rows } = await pg.query(
        `SELECT id, "supplierId" FROM "Supplier" WHERE "tenantId" = $1`,
        [tenantId]
      );
      for (const row of rows) {
        const key = cleanText(row.supplierId);
        if (key && !supplierMap.has(key)) supplierMap.set(key, row.id);
        const asInt = asInteger(row.supplierId);
        if (asInt !== null && !supplierMap.has(String(asInt))) supplierMap.set(String(asInt), row.id);
      }
    } catch (err) {
      console.warn("⚠️ Invoice: failed to preload Supplier mapping (optional).", err.message);
    }

    try {
      const { rows } = await pg.query(
        `SELECT id, "invoicePayId" FROM "InvoicePay" WHERE "tenantId" = $1 AND "branchId" = $2`,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const key = cleanText(row.invoicePayId);
        if (key && !invoicePayMap.has(key)) invoicePayMap.set(key, row.id);
        const asInt = asInteger(row.invoicePayId);
        if (asInt !== null && !invoicePayMap.has(String(asInt))) invoicePayMap.set(String(asInt), row.id);
      }
    } catch (err) {
      console.warn("⚠️ Invoice: failed to preload InvoicePay mapping.", err.message);
    }

    try {
      const { rows } = await pg.query(
        `SELECT id, "invoiceTypeId", "invoiceTypeName" FROM "InvoiceType" WHERE "tenantId" = $1 AND "branchId" = $2`,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const key = cleanText(row.invoiceTypeId);
        if (key && !invoiceTypeMap.has(key)) {
          invoiceTypeMap.set(key, { id: row.id, name: cleanText(row.invoiceTypeName) });
        }
        const asInt = asInteger(row.invoiceTypeId);
        if (asInt !== null && !invoiceTypeMap.has(String(asInt))) {
          invoiceTypeMap.set(String(asInt), { id: row.id, name: cleanText(row.invoiceTypeName) });
        }
      }
    } catch (err) {
      console.warn("⚠️ Invoice: failed to preload InvoiceType mapping.", err.message);
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
        const now = new Date();
        const seen = new Set();

        for (const row of chunk) {
          const legacyInvoiceId = asInteger(row.InvoiceId);
          if (legacyInvoiceId === null || seen.has(legacyInvoiceId)) continue;
          seen.add(legacyInvoiceId);

          const legacySapakIdRaw = cleanText(row.SapakID);
          const legacyInvoicePayIdRaw = cleanText(row.InvoicePayId);
          const legacyInvoiceTypeIdRaw = cleanText(row.InvoiceTypeId);

          let resolvedSapakId =
            legacySapakIdRaw !== null && legacySapakIdRaw !== undefined
              ? sapakMap.get(legacySapakIdRaw) || sapakMap.get(String(asInteger(legacySapakIdRaw))) || null
              : null;
          const resolvedSupplierId =
            legacySapakIdRaw !== null && legacySapakIdRaw !== undefined
              ? supplierMap.get(legacySapakIdRaw) || supplierMap.get(String(asInteger(legacySapakIdRaw))) || null
              : null;
          const invoicePayId =
            legacyInvoicePayIdRaw !== null && legacyInvoicePayIdRaw !== undefined
              ? invoicePayMap.get(legacyInvoicePayIdRaw) ||
                invoicePayMap.get(String(asInteger(legacyInvoicePayIdRaw))) ||
                null
              : null;
          const invoiceType =
            legacyInvoiceTypeIdRaw !== null && legacyInvoiceTypeIdRaw !== undefined
              ? invoiceTypeMap.get(legacyInvoiceTypeIdRaw) ||
                invoiceTypeMap.get(String(asInteger(legacyInvoiceTypeIdRaw))) ||
                null
              : null;

          if (!resolvedSapakId && legacySapakIdRaw) {
            // Create a placeholder Sapak entry to satisfy FK and continue migration.
            try {
              const placeholderId = uuidv4();
              const name = sapakNameMap.get(legacySapakIdRaw) || `Sapak ${legacySapakIdRaw}`;
              await pg.query(
                `INSERT INTO "Sapak" (
                   id, "tenantId", "branchId", "SapakID", "SapakName", "createdAt", "updatedAt"
                 )
                 VALUES ($1, $2, $3, $4, $5, $6, $6)
                 ON CONFLICT ("tenantId", "branchId", "SapakID") DO NOTHING`,
                [placeholderId, tenantId, branchId, legacySapakIdRaw, name, now]
              );
              sapakMap.set(legacySapakIdRaw, placeholderId);
              const asIntKey = asInteger(legacySapakIdRaw);
              if (asIntKey !== null) sapakMap.set(String(asIntKey), placeholderId);
              resolvedSapakId = placeholderId;
            } catch (e) {
              console.warn(
                `⚠️ Invoice: failed to create placeholder Sapak for legacySapakId=${legacySapakIdRaw}`,
                e.message
              );
            }
          }
          if (!resolvedSapakId) {
            if (legacySapakIdRaw) missingSapak.add(legacySapakIdRaw);
            continue; // still cannot insert without valid sapakId (FK)
          }
          if (!invoiceType && legacyInvoiceTypeIdRaw) {
            missingType.add(legacyInvoiceTypeIdRaw);
          }

          const invoiceNumber = cleanText(row.InvId) || String(legacyInvoiceId);
          const invoiceDate = safeDate(row.InvDate) || now;
          const totalAmount = asNumber(row.InvSum) ?? 0;
          const comment = cleanText(row.Com);

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9}, $${base + 10}, $${base + 11}, $${base + 12}, $${base + 13}, $${base + 14}, $${base + 15}, $${base + 16}, $${base + 17}, $${base + 18}, $${base + 19}, $${base + 20}, $${base + 21}, $${base + 22}, $${base + 23}, $${base + 24})`
          );

          params.push(
            uuidv4(),                            // id
            tenantId,                            // tenantId
            branchId,                            // branchId
            String(legacyInvoiceId),             // invoiceId
            invoiceNumber,                       // invoiceNumber
            resolvedSupplierId || null,         // supplierId (nullable if missing)
            invoiceDate,                         // invoiceDate
            invoiceDate,                       // dueDate
            totalAmount,                         // totalAmount
            0,                                   // paidAmount
            invoiceType?.name || (legacyInvoiceTypeIdRaw ? legacyInvoiceTypeIdRaw : "UNKNOWN"), // invoiceType
            comment,                             // comment
            "PENDING",                           // status
            now,                                 // createdAt
            now,                                 // updatedAt
            invoiceDate,                         // InvDate
            totalAmount,                         // InvSum
            comment,                             // com
            invoicePayId,                        // invoicePayId (FK)
            invoiceType?.id || null,             // invoiceTypeId (FK)
            legacyInvoicePayIdRaw ? asInteger(legacyInvoicePayIdRaw) : null, // legacyInvoicePayId
            legacyInvoiceTypeIdRaw ? asInteger(legacyInvoiceTypeIdRaw) : null, // legacyInvoiceTypeId
            legacySapakIdRaw ? asInteger(legacySapakIdRaw) : null, // legacySapakId
            resolvedSapakId                      // sapakId (FK, nullable)
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "Invoice" (
               id,
               "tenantId",
               "branchId",
               "invoiceId",
               "invoiceNumber",
               "supplierId",
               "invoiceDate",
               "dueDate",
               "totalAmount",
               "paidAmount",
               "invoiceType",
               comment,
               status,
               "createdAt",
               "updatedAt",
               "InvDate",
               "InvSum",
               com,
               "invoicePayId",
               "invoiceTypeId",
               "legacyInvoicePayId",
               "legacyInvoiceTypeId",
               "legacySapakId",
               "sapakId"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "invoiceId") DO UPDATE SET
               "invoiceNumber" = EXCLUDED."invoiceNumber",
               "supplierId" = EXCLUDED."supplierId",
               "invoiceDate" = EXCLUDED."invoiceDate",
               "dueDate" = EXCLUDED."dueDate",
               "totalAmount" = EXCLUDED."totalAmount",
               "paidAmount" = EXCLUDED."paidAmount",
               "invoiceType" = EXCLUDED."invoiceType",
               comment = EXCLUDED.comment,
               status = EXCLUDED.status,
               "updatedAt" = EXCLUDED."updatedAt",
               "InvDate" = EXCLUDED."InvDate",
               "InvSum" = EXCLUDED."InvSum",
               com = EXCLUDED.com,
               "invoicePayId" = EXCLUDED."invoicePayId",
               "invoiceTypeId" = EXCLUDED."invoiceTypeId",
               "legacyInvoicePayId" = EXCLUDED."legacyInvoicePayId",
               "legacyInvoiceTypeId" = EXCLUDED."legacyInvoiceTypeId",
               "legacySapakId" = EXCLUDED."legacySapakId",
               "sapakId" = EXCLUDED."sapakId"`,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      const latest = asInteger(rows[rows.length - 1]?.InvoiceId);
      if (latest !== null) {
        lastId = latest;
      }
      console.log(`Invoice migrated so far: ${total} (lastInvoiceId=${lastId})`);
    }

    console.log(`✅ Invoice migration completed. Total inserted/updated: ${total}`);
    if (missingSapak.size) {
      const sample = Array.from(missingSapak).slice(0, 10);
      console.warn(
        `⚠️ Invoice: missing Sapak mapping for ${missingSapak.size} legacy SapakIDs. Sample: ${sample.join(", ")}`
      );
    }
    if (missingType.size) {
      const sample = Array.from(missingType).slice(0, 10);
      console.warn(
        `⚠️ Invoice: missing InvoiceType mapping for ${missingType.size} legacy InvoiceTypeIds. Sample: ${sample.join(", ")}`
      );
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateInvoice;
