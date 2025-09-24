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
  if (typeof value === "bigint") {
    return Number(value);
  }
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

async function migrateLensCharacteristic(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let total = 0;
  let skippedMissingSupplier = 0;
  let skippedMissingLensInfo = 0;
  let skippedDuplicateCharacteristic = 0;

  let cursor = {
    LensCharID: -1,
    SapakID: -1,
    LensTypeID: -1,
    LensMaterID: -1,
  };

  try {
    const seenCharacteristics = new Set();

    while (true) {
      const [rows] = await mysql.query(
        `SELECT SapakID, LensTypeID, LensMaterID, LensCharID, LensCharName, IdCount
           FROM sqlLnsChars
          WHERE (LensCharID, SapakID, LensTypeID, LensMaterID) > (?, ?, ?, ?)
          ORDER BY LensCharID, SapakID, LensTypeID, LensMaterID
          LIMIT ${WINDOW_SIZE}`,
        [
          cursor.LensCharID,
          cursor.SapakID,
          cursor.LensTypeID,
          cursor.LensMaterID,
        ]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();

        for (const row of chunk) {
          const supplierId = asInteger(row.SapakID);
          const lensTypeId = asInteger(row.LensTypeID);
          const lensMaterialId = asInteger(row.LensMaterID);
          const characteristicId = asInteger(row.LensCharID);

          if (supplierId === null) {
            skippedMissingSupplier += 1;
            continue;
          }

          if (
            lensTypeId === null ||
            lensMaterialId === null ||
            characteristicId === null
          ) {
            skippedMissingLensInfo += 1;
            continue;
          }

          if (seenCharacteristics.has(characteristicId)) {
            skippedDuplicateCharacteristic += 1;
            continue;
          }

          seenCharacteristics.add(characteristicId);

          const id = `${tenantId}-lens-characteristic-${characteristicId}`;
          const name = cleanText(row.LensCharName) || `Lens Characteristic ${characteristicId}`;
          const idCount = asInteger(row.IdCount) ?? 0;

          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8}, $${offset + 9}, $${offset + 10}, $${offset + 11})`
          );

          params.push(
            id,
            tenantId,
            supplierId,
            lensTypeId,
            lensMaterialId,
            characteristicId,
            name,
            idCount,
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
            INSERT INTO "LensCharacteristic" (
              id,
              "tenantId",
              "supplierId",
              "lensTypeId",
              "lensMaterialId",
              "characteristicId",
              name,
              "idCount",
              "isActive",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("characteristicId")
            DO UPDATE SET
              id = EXCLUDED.id,
              "tenantId" = EXCLUDED."tenantId",
              "supplierId" = EXCLUDED."supplierId",
              "lensTypeId" = EXCLUDED."lensTypeId",
              "lensMaterialId" = EXCLUDED."lensMaterialId",
              name = EXCLUDED.name,
              "idCount" = EXCLUDED."idCount",
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

      const lastRow = rows[rows.length - 1];
      cursor = {
        LensCharID: asInteger(lastRow.LensCharID) ?? cursor.LensCharID,
        SapakID: asInteger(lastRow.SapakID) ?? cursor.SapakID,
        LensTypeID: asInteger(lastRow.LensTypeID) ?? cursor.LensTypeID,
        LensMaterID: asInteger(lastRow.LensMaterID) ?? cursor.LensMaterID,
      };

      console.log(`LensCharacteristic migrated: ${total} (cursor=${JSON.stringify(cursor)})`);
    }

    console.log(`✅ LensCharacteristic migration completed. Total inserted/updated: ${total}`);
    if (skippedMissingSupplier) {
      console.log(`⚠️ Skipped ${skippedMissingSupplier} rows due to missing supplierId.`);
    }
    if (skippedMissingLensInfo) {
      console.log(`⚠️ Skipped ${skippedMissingLensInfo} rows due to missing lens type/material/characteristic identifiers.`);
    }
    if (skippedDuplicateCharacteristic) {
      console.log(`ℹ️ Ignored ${skippedDuplicateCharacteristic} duplicate characteristic rows (already processed).`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateLensCharacteristic;
