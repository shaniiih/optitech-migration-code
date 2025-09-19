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
  const str = String(value).trim().replace(/,/g, ".");
  if (!str) return null;
  const num = Number(str);
  return Number.isFinite(num) ? num : null;
}

function asInteger(value) {
  const num = asNumber(value);
  return num === null ? null : Math.round(num);
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

function legacyIdCandidates(value) {
  const normalized = normalizeLegacyId(value);
  if (!normalized) return [];

  const candidates = new Set([normalized]);
  if (/\D/.test(normalized)) {
    const digitsOnly = normalized.replace(/\D+/g, "");
    if (digitsOnly) {
      const numericCandidate = normalizeLegacyId(digitsOnly);
      if (numericCandidate) {
        candidates.add(numericCandidate);
      }
    }
  }

  return Array.from(candidates);
}

async function migrateContactLensFittingDetail(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  let skippedMissingCustomer = 0;
  const missingCustomerSamples = new Set();

  try {
    const { rows: customerRows } = await pg.query(
      `SELECT id, "customerId" FROM "Customer" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const customerMap = new Map();
    for (const c of customerRows) {
      for (const key of legacyIdCandidates(c.customerId)) {
        if (!customerMap.has(key)) {
          customerMap.set(key, c.id);
        }
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT PerId, CheckDate, FitId, DiamR, DiamL, BC1R, BC1L, BC2R, BC2L, SphR, SphL,
                CylR, CylL, AxR, AxL, VAR, VAL, VA, PHR, PHL, ClensTypeIdR, ClensTypeIdL,
                ClensManufIdR, ClensManufIdL, ClensBrandIdR, ClensBrandIdL, ComR, ComL
           FROM tblCrdClensFits
          WHERE FitId > ?
          ORDER BY FitId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();

        for (const r of chunk) {
          const legacyCustomerCandidates = legacyIdCandidates(r.PerId);
          const customerId = legacyCustomerCandidates
            .map((candidate) => customerMap.get(candidate))
            .find((value) => value) || null;
          if (!customerId) {
            skippedMissingCustomer += 1;
            if (legacyCustomerCandidates.length && missingCustomerSamples.size < 10) {
              missingCustomerSamples.add(legacyCustomerCandidates[0]);
            }
            continue;
          }

          const checkDate = normalizeDate(r.CheckDate) || now;

          const id = `${tenantId}-clfit-${r.FitId}`;
          const createdAt = checkDate;
          const updatedAt = checkDate;

          const columns = [
            id,
            tenantId,
            null,
            customerId,
            checkDate,
            Number(r.FitId),
            asNumber(r.DiamR),
            asNumber(r.DiamL),
            asNumber(r.BC1R),
            asNumber(r.BC1L),
            asNumber(r.BC2R),
            asNumber(r.BC2L),
            asNumber(r.SphR),
            asNumber(r.SphL),
            asNumber(r.CylR),
            asNumber(r.CylL),
            asInteger(r.AxR),
            asInteger(r.AxL),
            asNumber(r.VAR),
            asNumber(r.VAL),
            asNumber(r.VA),
            asNumber(r.PHR),
            asNumber(r.PHL),
            asInteger(r.ClensTypeIdR),
            asInteger(r.ClensTypeIdL),
            asInteger(r.ClensManufIdR),
            asInteger(r.ClensManufIdL),
            asInteger(r.ClensBrandIdR),
            asInteger(r.ClensBrandIdL),
            cleanText(r.ComR),
            cleanText(r.ComL),
            createdAt,
            updatedAt,
          ];

          const placeholderOffset = params.length;
          const placeholders = columns
            .map((_, idx) => `$${placeholderOffset + idx + 1}`)
            .join(", ");
          values.push(`(${placeholders})`);
          params.push(...columns);
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "ContactLensFittingDetail" (
              id, "tenantId", "branchId", "customerId", "checkDate", "fittingId",
              "diameterRight", "diameterLeft", "baseCurve1R", "baseCurve1L", "baseCurve2R",
              "baseCurve2L", "sphereR", "sphereL", "cylinderR", "cylinderL", "axisR",
              "axisL", "visualAcuityR", "visualAcuityL", "visualAcuity", "pinHoleR",
              "pinHoleL", "lensTypeIdR", "lensTypeIdL", "manufacturerIdR", "manufacturerIdL",
              "brandIdR", "brandIdL", "commentR", "commentL", "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              "customerId" = EXCLUDED."customerId",
              "checkDate" = EXCLUDED."checkDate",
              "fittingId" = EXCLUDED."fittingId",
              "diameterRight" = EXCLUDED."diameterRight",
              "diameterLeft" = EXCLUDED."diameterLeft",
              "baseCurve1R" = EXCLUDED."baseCurve1R",
              "baseCurve1L" = EXCLUDED."baseCurve1L",
              "baseCurve2R" = EXCLUDED."baseCurve2R",
              "baseCurve2L" = EXCLUDED."baseCurve2L",
              "sphereR" = EXCLUDED."sphereR",
              "sphereL" = EXCLUDED."sphereL",
              "cylinderR" = EXCLUDED."cylinderR",
              "cylinderL" = EXCLUDED."cylinderL",
              "axisR" = EXCLUDED."axisR",
              "axisL" = EXCLUDED."axisL",
              "visualAcuityR" = EXCLUDED."visualAcuityR",
              "visualAcuityL" = EXCLUDED."visualAcuityL",
              "visualAcuity" = EXCLUDED."visualAcuity",
              "pinHoleR" = EXCLUDED."pinHoleR",
              "pinHoleL" = EXCLUDED."pinHoleL",
              "lensTypeIdR" = EXCLUDED."lensTypeIdR",
              "lensTypeIdL" = EXCLUDED."lensTypeIdL",
              "manufacturerIdR" = EXCLUDED."manufacturerIdR",
              "manufacturerIdL" = EXCLUDED."manufacturerIdL",
              "brandIdR" = EXCLUDED."brandIdR",
              "brandIdL" = EXCLUDED."brandIdL",
              "commentR" = EXCLUDED."commentR",
              "commentL" = EXCLUDED."commentL",
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

      lastId = rows[rows.length - 1].FitId;
      console.log(`Contact lens fitting details migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ ContactLensFittingDetail migration completed. Total inserted/updated: ${total}`);
    if (skippedMissingCustomer) {
      console.warn(`⚠️ Skipped ${skippedMissingCustomer} contact lens fittings due to missing customers`);
      if (missingCustomerSamples.size) {
        console.warn(
          `⚠️ Example legacy customer IDs with no match: ${Array.from(missingCustomerSamples).join(", ")}`
        );
      }
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateContactLensFittingDetail;
