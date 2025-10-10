const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function normalizeBarcode(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    if (!Number.isFinite(value)) return null;
    return String(value);
  }
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  return trimmed;
}

function normalizeLegacyId(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number" && Number.isFinite(value)) {
    return String(Math.trunc(value));
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
  return trimmed;
}

async function migrateBarcodeManagement(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let totalProcessed = 0;
  let skippedMissingBarcode = 0;

  try {
    const { rows: productRows } = await pg.query(
      `SELECT id, "productId" FROM "Product" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const productMap = new Map();
    for (const row of productRows) {
      const key = normalizeLegacyId(row.productId);
      if (key && !productMap.has(key)) {
        productMap.set(key, row.id);
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT BarCodeId, BarCodeName, CatNum
           FROM tblBarCodes
          WHERE BarCodeId > ?
          ORDER BY BarCodeId
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
          const barcodeId = normalizeLegacyId(row.BarCodeId);
          const barcodeValue = normalizeBarcode(row.BarCodeName);
          if (!barcodeValue) {
            skippedMissingBarcode += 1;
            continue;
          }

          const productIdLegacy = normalizeLegacyId(row.CatNum);
          const productId = productIdLegacy ? productMap.get(productIdLegacy) || null : null;

          const rowValues = [
            `${tenantId}-barcode-${barcodeId}`,
            tenantId,
            productId,
            barcodeValue,
            "EAN13",
            true,
            now,
            now,
          ];

          const offset = params.length;
          const placeholders = rowValues
            .map((_, idx) => `$${offset + idx + 1}`)
            .join(", ");
          values.push(`(${placeholders})`);
          params.push(...rowValues);
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "BarcodeManagement" (
              id,
              "tenantId",
              "productId",
              barcode,
              "barcodeType",
              "isActive",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id) DO UPDATE SET
              "productId" = EXCLUDED."productId",
              barcode = EXCLUDED.barcode,
              "barcodeType" = EXCLUDED."barcodeType",
              "isActive" = EXCLUDED."isActive",
              "updatedAt" = EXCLUDED."updatedAt"`,
            params
          );
          await pg.query("COMMIT");
          totalProcessed += values.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      lastId = Number(rows[rows.length - 1].BarCodeId) || lastId;
      console.log(`BarcodeManagement migrated so far: ${totalProcessed} (lastId=${lastId})`);
    }

    console.log(`✅ BarcodeManagement migration completed. Total inserted/updated: ${totalProcessed}`);
    if (skippedMissingBarcode) {
      console.warn(`⚠️ Skipped ${skippedMissingBarcode} barcodes due to missing value.`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateBarcodeManagement;

