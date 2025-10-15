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
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function normalizeBarcode(value) {
  if (value === null || value === undefined) return null;

  if (Buffer.isBuffer(value)) {
    return normalizeBarcode(value.toString("utf8"));
  }

  if (typeof value === "number") {
    if (!Number.isFinite(value)) return null;
    const asString = value.toString();
    return asString.endsWith(".0") ? asString.slice(0, -2) : asString;
  }

  if (typeof value === "bigint") {
    return value.toString();
  }

  const trimmed = String(value).trim();
  if (!trimmed) return null;

  if (/^[+-]?\d+(?:\.0+)?$/.test(trimmed)) {
    return trimmed.replace(/\.0+$/, "");
  }

  return trimmed;
}

async function migrateBarcodeManagement(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  let skippedInvalidId = 0;
  let skippedMissingBarcode = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT BarCodeId,
                CatNum,
                BarCodeName,
                CAST(BarCodeName AS CHAR(64)) AS BarCodeValue
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
        const timestamp = new Date();

        for (const row of chunk) {
          const legacyId = asInteger(row.BarCodeId);
          if (legacyId === null) {
            skippedInvalidId += 1;
            continue;
          }

          const rawBarcode = row.BarCodeValue ?? row.BarCodeName;
          const barcode = normalizeBarcode(rawBarcode);
          if (!barcode) {
            skippedMissingBarcode += 1;
            continue;
          }

          const catNum = cleanText(row.CatNum);

          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8}, $${offset + 9})`
          );

          params.push(
            uuidv4(),
            tenantId,
            null,
            barcode,
            catNum,
            "EAN13",
            true,
            timestamp,
            timestamp
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "BarcodeManagement" (
              id,
              "tenantId",
              "productId",
              barcode,
              "CatNum",
              "barcodeType",
              "isActive",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (barcode)
            DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              "productId" = EXCLUDED."productId",
              "CatNum" = EXCLUDED."CatNum",
              "barcodeType" = EXCLUDED."barcodeType",
              "isActive" = EXCLUDED."isActive",
              "updatedAt" = EXCLUDED."updatedAt"
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

      lastId = asInteger(rows[rows.length - 1].BarCodeId) ?? lastId;
      console.log(`BarcodeManagement migrated so far: ${total} (lastBarCodeId=${lastId})`);
    }

    console.log(`✅ BarcodeManagement migration completed. Total inserted/updated: ${total}`);
    if (skippedInvalidId) {
      console.warn(`⚠️ Skipped ${skippedInvalidId} rows due to invalid BarCodeId.`);
    }
    if (skippedMissingBarcode) {
      console.warn(`⚠️ Skipped ${skippedMissingBarcode} rows due to missing or invalid barcode.`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateBarcodeManagement;

