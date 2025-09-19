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

async function migrateFrequentReplacementProgram(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  let skippedMissingCustomer = 0;
  let missingBrandCount = 0;
  const missingCustomerSamples = new Set();
  const missingBrandSamples = new Set();

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

    const [brandRows] = await mysql.query(
      `SELECT ClensBrandId, ClensBrandName FROM tblCrdClensBrands`
    );
    const brandMap = new Map();
    for (const row of brandRows) {
      const id = normalizeLegacyId(row.ClensBrandId);
      const name = cleanText(row.ClensBrandName);
      if (id && !brandMap.has(id)) {
        brandMap.set(id, name);
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT FrpId, PerId, ClensBrandId, FrpDate, TotalFrp, ExchangeNum, DayInterval, Supply,
                Comments, SaleAdd
           FROM tblCrdFrps
          WHERE FrpId > ?
          ORDER BY FrpId
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
          const customerId = legacyIdCandidates(r.PerId)
            .map((candidate) => customerMap.get(candidate))
            .find((value) => value) || null;
          if (!customerId) {
            skippedMissingCustomer += 1;
            const legacyIds = legacyIdCandidates(r.PerId);
            if (legacyIds.length && missingCustomerSamples.size < 10) {
              missingCustomerSamples.add(legacyIds[0]);
            }
            continue;
          }

          const brandId = normalizeLegacyId(r.ClensBrandId);
          const brandName = brandId ? brandMap.get(brandId) : null;
          if (!brandName) {
            missingBrandCount += 1;
            if (brandId && missingBrandSamples.size < 10) {
              missingBrandSamples.add(brandId);
            }
          }

          const startDate = normalizeDate(r.FrpDate) || now;
          const quantityPerBox = asInteger(r.TotalFrp) ?? 0;
          const boxesPerYear = asInteger(r.ExchangeNum) ?? 0;
          const replacementSchedule = asInteger(r.DayInterval) ?? 0;
          const annualSupply = Boolean(r.Supply);
          const notesParts = [];
          const comments = cleanText(r.Comments);
          if (comments) notesParts.push(comments);
          if (r.SaleAdd) notesParts.push("Includes additional sale items");
          const notes = notesParts.length ? notesParts.join("\n") : null;

          const id = `${tenantId}-frp-${r.FrpId}`;
          const createdAt = startDate;
          const updatedAt = startDate;

          const columns = [
            id,
            tenantId,
            String(r.FrpId),
            customerId,
            startDate,
            null,
            brandName,
            null,
            null,
            null,
            null,
            null,
            replacementSchedule ? `${replacementSchedule}-day` : "UNKNOWN",
            quantityPerBox || 0,
            boxesPerYear || 0,
            0,
            annualSupply,
            annualSupply ? "ACTIVE" : "PAUSED",
            notes,
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
            INSERT INTO "FrequentReplacementProgram" (
              id, "tenantId", "programId", "customerId", "startDate", "endDate",
              "rightEyeBrand", "rightEyeType", "rightEyePower", "leftEyeBrand",
              "leftEyeType", "leftEyePower", "replacementSchedule", "quantityPerBox",
              "boxesPerYear", "pricePerBox", "annualSupply", status, notes,
              "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              "customerId" = EXCLUDED."customerId",
              "startDate" = EXCLUDED."startDate",
              "rightEyeBrand" = EXCLUDED."rightEyeBrand",
              "replacementSchedule" = EXCLUDED."replacementSchedule",
              "quantityPerBox" = EXCLUDED."quantityPerBox",
              "boxesPerYear" = EXCLUDED."boxesPerYear",
              "pricePerBox" = EXCLUDED."pricePerBox",
              "annualSupply" = EXCLUDED."annualSupply",
              status = EXCLUDED.status,
              notes = EXCLUDED.notes,
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

      lastId = rows[rows.length - 1].FrpId;
      console.log(`Frequent replacement programs migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ FrequentReplacementProgram migration completed. Total inserted/updated: ${total}`);
    if (skippedMissingCustomer) {
      console.warn(`⚠️ Skipped ${skippedMissingCustomer} programs due to missing customers`);
      if (missingCustomerSamples.size) {
        console.warn(
          `⚠️ Example legacy customer IDs with no match: ${Array.from(missingCustomerSamples).join(", ")}`
        );
      }
    }
    if (missingBrandCount) {
      console.warn(
        `⚠️ ${missingBrandCount} programs referenced unknown contact lens brands`
      );
      if (missingBrandSamples.size) {
        console.warn(
          `⚠️ Example legacy brand IDs with no match: ${Array.from(missingBrandSamples).join(", ")}`
        );
      }
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateFrequentReplacementProgram;
