const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 500;

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
  if (typeof value === "bigint") {
    return Number(value);
  }
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const normalized = trimmed.replace(/,/g, ".");
  const parsed = Number(normalized);
  return Number.isFinite(parsed) ? parsed : null;
}

function asInteger(value) {
  const num = asNumber(value);
  return num === null ? null : Math.trunc(num);
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

async function migrateLensCatalog(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let total = 0;
  let missingSupplierLink = 0;

  let cursor = {
    LensCharID: -1,
    LensTypeID: -1,
    LensMaterID: -1,
    LensRng: -1,
    LensInt: -1,
    LensDiam: -1,
    LensPM: -1,
  };

  try {
    const { rows: supplierRows } = await pg.query(
      `SELECT id, "supplierId" FROM "Supplier" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const supplierMap = new Map(supplierRows.map((row) => [row.supplierId, row.id]));

    const [legacySupplierRows] = await mysql.query(
      `SELECT SapakID, SapakName FROM tblSapaks`
    );
    const legacySupplierNameMap = new Map(
      legacySupplierRows.map((row) => [normalizeLegacyId(row.SapakID), cleanText(row.SapakName)])
    );

    const [typeRows] = await mysql.query(
      `SELECT LensTypeId, LensTypeName FROM tblLnsTypes`
    );
    const lensTypeNameMap = new Map(
      typeRows.map((row) => [asInteger(row.LensTypeId), cleanText(row.LensTypeName)])
    );

    const [materialRows] = await mysql.query(
      `SELECT LensMaterId, LensMaterName FROM tblLnsMaterials`
    );
    const lensMaterialNameMap = new Map(
      materialRows.map((row) => [asInteger(row.LensMaterId), cleanText(row.LensMaterName)])
    );

    const [charRows] = await mysql.query(
      `SELECT LensCharId, LensCharName FROM tblLnsChars`
    );
    const lensCharNameMap = new Map(
      charRows.map((row) => [asInteger(row.LensCharId), cleanText(row.LensCharName)])
    );

    while (true) {
      const [rows] = await mysql.query(
        `SELECT SapakID, LensTypeID, LensMaterID, LensCharID, LensRng, LensInt, LensDiam,
                LensPM, Price, PubPrice, RecPrice, PrivPrice, Active
           FROM tblLnsPrices
          WHERE (LensCharID, LensTypeID, LensMaterID, LensRng, LensInt, LensDiam, LensPM) > (?, ?, ?, ?, ?, ?, ?)
          ORDER BY LensCharID, LensTypeID, LensMaterID, LensRng, LensInt, LensDiam, LensPM
          LIMIT ${WINDOW_SIZE}`,
        [
          cursor.LensCharID,
          cursor.LensTypeID,
          cursor.LensMaterID,
          cursor.LensRng,
          cursor.LensInt,
          cursor.LensDiam,
          cursor.LensPM,
        ]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();

        for (const row of chunk) {
          const supplierLegacyId = normalizeLegacyId(row.SapakID);
          const supplierId = supplierLegacyId ? supplierMap.get(supplierLegacyId) || null : null;
          if (!supplierId) {
            missingSupplierLink += 1;
          }

          const lensCharId = asInteger(row.LensCharID);
          const lensTypeId = asInteger(row.LensTypeID);
          const lensMaterialId = asInteger(row.LensMaterID);

          const lensCharName = lensCharNameMap.get(lensCharId) || `Lens Characteristic ${lensCharId}`;
          const lensTypeName = lensTypeNameMap.get(lensTypeId) || `Lens Type ${lensTypeId}`;
          const lensMaterialName =
            lensMaterialNameMap.get(lensMaterialId) || `Lens Material ${lensMaterialId}`;
          const supplierName =
            legacySupplierNameMap.get(supplierLegacyId) || `Supplier ${supplierLegacyId}`;

          const id = `${tenantId}-lens-catalog-${supplierLegacyId}-${lensTypeId}-${lensMaterialId}-${lensCharId}-${row.LensRng}-${row.LensInt}-${row.LensDiam}-${row.LensPM}`;
          const catalogNumber = `${tenantId}-LC-${supplierLegacyId}-${lensTypeId}-${lensMaterialId}-${lensCharId}-${row.LensRng}-${row.LensInt}-${row.LensDiam}-${row.LensPM}`;
          const productCode = `LC-${lensCharId}-${row.LensRng}-${row.LensInt}-${row.LensDiam}`;

          const pricingMatrix = {
            price: asNumber(row.Price),
            publicPrice: asNumber(row.PubPrice),
            recommendedPrice: asNumber(row.RecPrice),
            privatePrice: asNumber(row.PrivPrice),
            parameters: {
              lensRange: asInteger(row.LensRng),
              lensInterval: asInteger(row.LensInt),
              lensDiameter: asInteger(row.LensDiam),
              lensPm: asInteger(row.LensPM),
            },
          };

          const paramsOffset = params.length;
          values.push(
            `($${paramsOffset + 1}, $${paramsOffset + 2}, $${paramsOffset + 3}, $${paramsOffset + 4}, $${paramsOffset + 5}, $${paramsOffset + 6}, $${paramsOffset + 7}, $${paramsOffset + 8}, $${paramsOffset + 9}, $${paramsOffset + 10}, $${paramsOffset + 11}, $${paramsOffset + 12}, $${paramsOffset + 13}, $${paramsOffset + 14}, $${paramsOffset + 15}, $${paramsOffset + 16}, $${paramsOffset + 17}, $${paramsOffset + 18}, $${paramsOffset + 19}, $${paramsOffset + 20}, $${paramsOffset + 21}, $${paramsOffset + 22}, $${paramsOffset + 23}, $${paramsOffset + 24}, $${paramsOffset + 25}, $${paramsOffset + 26}, $${paramsOffset + 27}, $${paramsOffset + 28}, $${paramsOffset + 29}, $${paramsOffset + 30}, $${paramsOffset + 31}, $${paramsOffset + 32}, $${paramsOffset + 33}, $${paramsOffset + 34}, $${paramsOffset + 35}, $${paramsOffset + 36})`
          );

          params.push(
            id,                                 // id
            tenantId,                           // tenantId
            catalogNumber,                      // catalogNumber
            productCode,                        // productCode
            supplierName || "Unknown Manufacturer", // manufacturer
            lensCharName,                       // brand
            null,                               // series
            lensTypeName,                       // lensType
            `Legacy design ${row.LensRng ?? "?"}`, // design
            lensMaterialName,                   // material
            1.5,                                // refractiveIndex (legacy default)
            null,                               // abbeValue
            null,                               // specificGravity
            0,                                  // sphereMin
            0,                                  // sphereMax
            0,                                  // cylinderMin
            0,                                  // cylinderMax
            null,                               // addMin
            null,                               // addMax
            null,                               // baseCurves
            null,                               // diameters
            null,                               // centerThickness
            null,                               // coatings
            null,                               // corridorLengths
            pricingMatrix,                      // pricingMatrix
            supplierId,                         // supplierId (may be null)
            supplierLegacyId || catalogNumber,  // supplierCode fallback
            true,                               // labProcessing
            Boolean(asInteger(row.LensPM)),     // surfacingRequired heuristic
            Boolean(row.Active),                // active
            false,                              // stockItem
            null,                               // leadTime
            null,                               // uvProtection
            null,                               // impact
            timestamp,                          // createdAt
            timestamp                           // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "LensCatalog" (
              id,
              "tenantId",
              "catalogNumber",
              "productCode",
              manufacturer,
              brand,
              series,
              "lensType",
              design,
              material,
              "refractiveIndex",
              "abbeValue",
              "specificGravity",
              "sphereMin",
              "sphereMax",
              "cylinderMin",
              "cylinderMax",
              "addMin",
              "addMax",
              "baseCurves",
              diameters,
              "centerThickness",
              coatings,
              "corridorLengths",
              "pricingMatrix",
              "supplierId",
              "supplierCode",
              "labProcessing",
              "surfacingRequired",
              active,
              "stockItem",
              "leadTime",
              "uvProtection",
              impact,
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("catalogNumber")
            DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              "catalogNumber" = EXCLUDED."catalogNumber",
              "productCode" = EXCLUDED."productCode",
              manufacturer = EXCLUDED.manufacturer,
              brand = EXCLUDED.brand,
              series = EXCLUDED.series,
              "lensType" = EXCLUDED."lensType",
              design = EXCLUDED.design,
              material = EXCLUDED.material,
              "refractiveIndex" = EXCLUDED."refractiveIndex",
              "abbeValue" = EXCLUDED."abbeValue",
              "specificGravity" = EXCLUDED."specificGravity",
              "sphereMin" = EXCLUDED."sphereMin",
              "sphereMax" = EXCLUDED."sphereMax",
              "cylinderMin" = EXCLUDED."cylinderMin",
              "cylinderMax" = EXCLUDED."cylinderMax",
              "addMin" = EXCLUDED."addMin",
              "addMax" = EXCLUDED."addMax",
              "baseCurves" = EXCLUDED."baseCurves",
              diameters = EXCLUDED.diameters,
              "centerThickness" = EXCLUDED."centerThickness",
              coatings = EXCLUDED.coatings,
              "corridorLengths" = EXCLUDED."corridorLengths",
              "pricingMatrix" = EXCLUDED."pricingMatrix",
              "supplierId" = EXCLUDED."supplierId",
              "supplierCode" = EXCLUDED."supplierCode",
              "labProcessing" = EXCLUDED."labProcessing",
              "surfacingRequired" = EXCLUDED."surfacingRequired",
              active = EXCLUDED.active,
              "stockItem" = EXCLUDED."stockItem",
              "leadTime" = EXCLUDED."leadTime",
              "uvProtection" = EXCLUDED."uvProtection",
              impact = EXCLUDED.impact,
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

      const lastRow = rows[rows.length - 1];
      cursor = {
        LensCharID: asInteger(lastRow.LensCharID) ?? cursor.LensCharID,
        LensTypeID: asInteger(lastRow.LensTypeID) ?? cursor.LensTypeID,
        LensMaterID: asInteger(lastRow.LensMaterID) ?? cursor.LensMaterID,
        LensRng: asInteger(lastRow.LensRng) ?? cursor.LensRng,
        LensInt: asInteger(lastRow.LensInt) ?? cursor.LensInt,
        LensDiam: asInteger(lastRow.LensDiam) ?? cursor.LensDiam,
        LensPM: asInteger(lastRow.LensPM) ?? cursor.LensPM,
      };

      console.log(`LensCatalog migrated: ${total} (cursor=${JSON.stringify(cursor)})`);
    }

    console.log(`✅ LensCatalog migration completed. Total inserted/updated: ${total}`);
    if (missingSupplierLink) {
      console.log(`⚠️ ${missingSupplierLink} rows used null supplier references because Supplier migration was not found for those SapakIDs.`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateLensCatalog;
