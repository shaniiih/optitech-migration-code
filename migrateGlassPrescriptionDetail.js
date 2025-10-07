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

function normalizeDate(value) {
  if (value === null || value === undefined) return null;

  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value;
  }

  if (typeof value === "number") {
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? null : date;
  }

  const str = String(value).trim();
  if (!str) return null;
  if (/^0{4}-0{2}-0{2}/.test(str)) return null;
  const date = new Date(str);
  return Number.isNaN(date.getTime()) ? null : date;
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

function legacyIdCandidates(value) {
  const normalized = normalizeLegacyId(value);
  if (!normalized) return [];
  const candidates = new Set([normalized]);
  if (/\D/.test(normalized)) {
    const digits = normalized.replace(/\D+/g, "");
    if (digits) {
      const numericCandidate = normalizeLegacyId(digits);
      if (numericCandidate) {
        candidates.add(numericCandidate);
      }
    }
  }
  return Array.from(candidates);
}

async function migrateGlassPrescriptionDetail(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  let skippedMissingCustomer = 0;
  let skippedInvalidDate = 0;

  try {
    const { rows: customerRows } = await pg.query(
      `SELECT id, "customerId" FROM "Customer" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const customerMap = new Map();
    for (const row of customerRows) {
      for (const legacyKey of legacyIdCandidates(row.customerId)) {
        if (!customerMap.has(legacyKey)) {
          customerMap.set(legacyKey, row.id);
        }
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT GlassPId, PerId, CheckDate, UseId, SapakId, LensTypeId, LensMaterId,
                LensCharId, TreatCharId, TreatCharId1, TreatCharId2, TreatCharId3,
                Diam, Com, EyeId, SaleAdd
           FROM tblCrdGlassChecksGlassesP
          WHERE GlassPId > ?
          ORDER BY GlassPId
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
          const customerCandidates = legacyIdCandidates(row.PerId);
          let customerId = null;
          for (const key of customerCandidates) {
            const found = customerMap.get(key);
            if (found) {
              customerId = found;
              break;
            }
          }

          if (!customerId) {
            skippedMissingCustomer += 1;
            continue;
          }

          const checkDate = normalizeDate(row.CheckDate);
          if (!checkDate) {
            skippedInvalidDate += 1;
            continue;
          }

          
          const paramsOffset = params.length;
          values.push(
            `($${paramsOffset + 1}, $${paramsOffset + 2}, $${paramsOffset + 3}, $${paramsOffset + 4}, $${paramsOffset + 5}, $${paramsOffset + 6}, $${paramsOffset + 7}, $${paramsOffset + 8}, $${paramsOffset + 9}, $${paramsOffset + 10}, $${paramsOffset + 11}, $${paramsOffset + 12}, $${paramsOffset + 13}, $${paramsOffset + 14}, $${paramsOffset + 15}, $${paramsOffset + 16}, $${paramsOffset + 17}, $${paramsOffset + 18}, $${paramsOffset + 19}, $${paramsOffset + 20}, $${paramsOffset + 21})`
          );

          params.push(
            uuidv4(),
            tenantId,
            null, // branchId is unavailable in the legacy source
            customerId,
            checkDate,
            asInteger(row.GlassPId) ?? 0,
            asInteger(row.UseId),
            asInteger(row.SapakId),
            asInteger(row.LensTypeId),
            asInteger(row.LensMaterId),
            asInteger(row.LensCharId),
            asInteger(row.TreatCharId),
            asNumber(row.TreatCharId1),
            asNumber(row.TreatCharId2),
            asNumber(row.TreatCharId3),
            asNumber(row.Diam),
            asInteger(row.EyeId),
            row.SaleAdd ? 1 : 0,
            cleanText(row.Com),
            timestamp,
            timestamp
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "GlassPrescriptionDetail" (
              id, "tenantId", "branchId", "customerId", "checkDate", "glassPId",
              "useId", "supplierId", "lensTypeId", "lensMaterialId", "lensCharId",
              "treatmentCharId", "treatmentCharId1", "treatmentCharId2", "treatmentCharId3",
              diameter, "eyeId", "saleAdd", comments, "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              "customerId" = EXCLUDED."customerId",
              "checkDate" = EXCLUDED."checkDate",
              "useId" = EXCLUDED."useId",
              "supplierId" = EXCLUDED."supplierId",
              "lensTypeId" = EXCLUDED."lensTypeId",
              "lensMaterialId" = EXCLUDED."lensMaterialId",
              "lensCharId" = EXCLUDED."lensCharId",
              "treatmentCharId" = EXCLUDED."treatmentCharId",
              "treatmentCharId1" = EXCLUDED."treatmentCharId1",
              "treatmentCharId2" = EXCLUDED."treatmentCharId2",
              "treatmentCharId3" = EXCLUDED."treatmentCharId3",
              diameter = EXCLUDED.diameter,
              "eyeId" = EXCLUDED."eyeId",
              "saleAdd" = EXCLUDED."saleAdd",
              comments = EXCLUDED.comments,
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

      lastId = rows[rows.length - 1].GlassPId;
      console.log(`GlassPrescriptionDetail migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ GlassPrescriptionDetail migration completed. Total inserted/updated: ${total}`);
    if (skippedMissingCustomer) {
      console.log(`⚠️ Skipped ${skippedMissingCustomer} rows due to missing customer mapping.`);
    }
    if (skippedInvalidDate) {
      console.log(`⚠️ Skipped ${skippedInvalidDate} rows due to invalid checkDate.`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateGlassPrescriptionDetail;
