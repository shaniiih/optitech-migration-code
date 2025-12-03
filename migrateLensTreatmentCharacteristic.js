const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 500;

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  const str = String(value).trim();
  if (!str) return null;
  const num = Number(str);
  return Number.isFinite(num) ? Math.trunc(num) : null;
}

function asBoolean(value) {
  if (value === null || value === undefined) return false;
  if (typeof value === "boolean") return value;
  if (typeof value === "number") return value !== 0;
  const str = String(value).trim().toLowerCase();
  if (!str) return false;
  return str === "1" || str === "true" || str === "y";
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

async function migrateLensTreatmentCharacteristic(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  const treatCharSelection = new Map();
  let totalProcessed = 0;
  let skippedMissingLensMapping = 0;
  let skippedMissingSupplier = 0;

  try {
    const [treatCharRows] = await mysql.query(
      `SELECT TreatCharId, TreatCharName FROM tblLnsTreatChars`
    );
    const treatCharNameMap = new Map();
    for (const row of treatCharRows) {
      const id = asInteger(row.TreatCharId);
      if (id === null || treatCharNameMap.has(id)) continue;
      treatCharNameMap.set(id, cleanText(row.TreatCharName));
    }

    const [connectRows] = await mysql.query(
      `SELECT TreatId, LensTypeID, LensMaterID FROM tblLnsTreatTypesConnect`
    );
    const treatToLensMap = new Map();
    for (const row of connectRows) {
      const treatId = asInteger(row.TreatId);
      if (treatId === null) continue;
      const lensTypeId = asInteger(row.LensTypeID);
      const lensMaterialId = asInteger(row.LensMaterID);
      const existing = treatToLensMap.get(treatId);
      if (!existing) {
        treatToLensMap.set(treatId, {
          lensTypeId,
          lensMaterialId,
        });
        continue;
      }
      if ((existing.lensTypeId === null || existing.lensMaterialId === null) &&
          (lensTypeId !== null || lensMaterialId !== null)) {
        treatToLensMap.set(treatId, {
          lensTypeId: lensTypeId !== null ? lensTypeId : existing.lensTypeId,
          lensMaterialId: lensMaterialId !== null ? lensMaterialId : existing.lensMaterialId,
        });
      }
    }

    let lastCharId = -1;
    let lastSapakId = -1;
    let lastTreatId = -1;

    while (true) {
      const [rows] = await mysql.query(
        `
        SELECT SapakID, TreatId, TreatCharID, Active
          FROM tblLnsTreatmens
         WHERE (TreatCharID > ?)
            OR (TreatCharID = ? AND SapakID > ?)
            OR (TreatCharID = ? AND SapakID = ? AND TreatId > ?)
         ORDER BY TreatCharID, SapakID, TreatId
         LIMIT ${WINDOW_SIZE}
        `,
        [lastCharId, lastCharId, lastSapakId, lastCharId, lastSapakId, lastTreatId]
      );

      if (!rows.length) break;

      for (const row of rows) {
        const treatCharId = asInteger(row.TreatCharID);
        if (treatCharId === null) continue;

        const supplierId = asInteger(row.SapakID);
        const treatId = asInteger(row.TreatId);
        const isActive = asBoolean(row.Active);

        const current = treatCharSelection.get(treatCharId);
        if (!current) {
          treatCharSelection.set(treatCharId, { supplierId, treatId, isActive });
        } else if (!current.isActive && isActive) {
          treatCharSelection.set(treatCharId, { supplierId, treatId, isActive });
        }
      }

      const lastRow = rows[rows.length - 1];
      lastCharId = asInteger(lastRow.TreatCharID) ?? lastCharId;
      lastSapakId = asInteger(lastRow.SapakID) ?? lastSapakId;
      lastTreatId = asInteger(lastRow.TreatId) ?? lastTreatId;
    }

    const records = [];
    for (const [treatCharId, info] of treatCharSelection.entries()) {
      const supplierId = asInteger(info.supplierId);
      if (supplierId === null) {
        skippedMissingSupplier += 1;
        continue;
      }

      const treatMapping = info.treatId !== null ? treatToLensMap.get(info.treatId) : null;
      const lensTypeId = treatMapping ? asInteger(treatMapping.lensTypeId) : null;
      const lensMaterialId = treatMapping ? asInteger(treatMapping.lensMaterialId) : null;

      if (lensTypeId === null || lensMaterialId === null) {
        skippedMissingLensMapping += 1;
        continue;
      }

      const name = treatCharNameMap.get(treatCharId) || `Treatment Characteristic ${treatCharId}`;
      const timestamp = new Date();

      records.push({
        id: createId(),
        tenantId,
        supplierId,
        lensTypeId,
        lensMaterialId,
        treatmentCharId: treatCharId,
        name,
        idCount: 0,
        isActive: !!info.isActive,
        createdAt: timestamp,
        updatedAt: timestamp,
      });
    }

    records.sort((a, b) => a.treatmentCharId - b.treatmentCharId);

    for (let i = 0; i < records.length; i += BATCH_SIZE) {
      const chunk = records.slice(i, i + BATCH_SIZE);
      const values = [];
      const params = [];

      for (const item of chunk) {
        const offset = params.length;
        values.push(
          `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8}, $${offset + 9}, $${offset + 10}, $${offset + 11})`
        );
        params.push(
          item.id,
          item.tenantId,
          item.supplierId,
          item.lensTypeId,
          item.lensMaterialId,
          item.treatmentCharId,
          item.name,
          item.idCount,
          item.isActive,
          item.createdAt,
          item.updatedAt
        );
      }

      if (!values.length) continue;

      await pg.query("BEGIN");
      try {
        await pg.query(
          `
          INSERT INTO "LensTreatmentCharacteristic" (
            id,
            "tenantId",
            "supplierId",
            "lensTypeId",
            "lensMaterialId",
            "treatmentCharId",
            name,
            "idCount",
            "isActive",
            "createdAt",
            "updatedAt"
          )
          VALUES ${values.join(",")}
          ON CONFLICT ("treatmentCharId")
          DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
            "supplierId" = EXCLUDED."supplierId",
            "lensTypeId" = EXCLUDED."lensTypeId",
            "lensMaterialId" = EXCLUDED."lensMaterialId",
            "treatmentCharId" = EXCLUDED."treatmentCharId",
            name = EXCLUDED.name,
            "idCount" = EXCLUDED."idCount",
            "isActive" = EXCLUDED."isActive",
            "updatedAt" = EXCLUDED."updatedAt"
          `,
          params
        );
        await pg.query("COMMIT");
        totalProcessed += chunk.length;
      } catch (err) {
        await pg.query("ROLLBACK");
        throw err;
      }
    }

    console.log(`✅ LensTreatmentCharacteristic migration completed. Total inserted/updated: ${totalProcessed}`);
    if (skippedMissingSupplier) {
      console.log(`⚠️ Skipped ${skippedMissingSupplier} characteristics due to missing supplierId.`);
    }
    if (skippedMissingLensMapping) {
      console.log(`⚠️ Skipped ${skippedMissingLensMapping} characteristics due to missing lens type/material mapping.`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateLensTreatmentCharacteristic;
