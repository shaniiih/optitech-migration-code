const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

// Legacy category -> friendly label mapping
const CATEGORY_COLUMNS = [
  { column: "prlGlass", label: "glass" },
  { column: "prlTreat", label: "treatment" },
  { column: "prlClens", label: "contactLens" },
  { column: "prlFrame", label: "frame" },
  { column: "prlSunGlass", label: "sunGlass" },
  { column: "prlProp", label: "property" },
  { column: "prlSolution", label: "solution" },
  { column: "prlService", label: "service" },
  { column: "prlCheck", label: "check" },
  { column: "prlMisc", label: "misc" },
  { column: "prlGlassOneS", label: "glassOneS" },
  { column: "prlGlassOneP", label: "glassOneP" },
  { column: "prlGlassBif", label: "glassBifocal" },
  { column: "prlGlassMul", label: "glassMultifocal" }
];

function asNumber(value) {
  if (value === null || value === undefined) return null;
  const num = Number(value);
  return Number.isFinite(num) ? num : null;
}

function round(value, digits = 2) {
  const factor = 10 ** digits;
  return Math.round(value * factor) / factor;
}

function extractLegacyRates(row) {
  const rates = {};
  let maxPercent = 0;

  for (const { column, label } of CATEGORY_COLUMNS) {
    const raw = asNumber(row[column]);
    if (raw === null) continue;

    const percentLike = Math.abs(raw) <= 1 ? raw * 100 : raw;
    const percent = round(percentLike, 2);
    rates[label] = {
      percent,
      raw: round(raw, 4)
    };
    if (percent > maxPercent) {
      maxPercent = percent;
    }
  }

  return { rates, maxPercent: round(maxPercent, 2) };
}

function generateCode(name, discountId, usedCodes) {
  const fallback = `LEGACY_${discountId}`;
  if (!name || !name.trim()) {
    const code = ensureUniqueCode(fallback, usedCodes);
    usedCodes.add(code);
    return code;
  }

  const sanitized = name
    .trim()
    .toUpperCase()
    .replace(/[^A-Z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
  const base = sanitized.length ? sanitized.slice(0, 48) : fallback;
  const code = ensureUniqueCode(base, usedCodes, fallback);
  usedCodes.add(code);
  return code;
}

function ensureUniqueCode(base, usedCodes, fallback) {
  let candidate = base && base.length ? base : fallback;
  if (!candidate || !candidate.length) {
    candidate = fallback;
  }

  if (!usedCodes.has(candidate)) {
    return candidate;
  }

  let suffix = 1;
  while (true) {
    const attemptBase = candidate.slice(0, Math.max(1, 60 - String(suffix).length - 1));
    const attempt = `${attemptBase}_${suffix}`;
    if (!usedCodes.has(attempt)) {
      return attempt;
    }
    suffix += 1;
  }
}

async function migrateDiscount(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  const usedCodes = new Set();
  const existingCodeById = new Map();

  try {
    const existingCodes = await pg.query('SELECT id, code FROM "Discount"');
    for (const row of existingCodes.rows) {
      if (row.code) {
        usedCodes.add(row.code);
      }
      if (row.id) {
        existingCodeById.set(String(row.id), row.code || null);
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT DiscountId, DiscountName,
                prlGlass, prlTreat, prlClens, prlFrame, prlSunGlass, prlProp,
                prlSolution, prlService, prlCheck, prlMisc,
                prlGlassOneS, prlGlassOneP, prlGlassBif, prlGlassMul
           FROM tblDiscounts
          WHERE DiscountId > ?
          ORDER BY DiscountId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const r of chunk) {
          const discountId = String(r.DiscountId);
          const name = r.DiscountName && r.DiscountName.trim()
            ? r.DiscountName.trim()
            : `Legacy Discount ${discountId}`;
          let code;
          const existingCode = existingCodeById.get(discountId);
          if (existingCode && existingCode.trim()) {
            code = existingCode.trim();
            if (!usedCodes.has(code)) {
              usedCodes.add(code);
            }
          } else {
            code = generateCode(name, discountId, usedCodes);
          }
          existingCodeById.set(discountId, code);
          const { rates, maxPercent } = extractLegacyRates(r);
          const notes = Object.keys(rates).length
            ? JSON.stringify({ sourceTable: "tblDiscounts", rates })
            : null;
          const now = new Date();

          const rowParams = [
            discountId, // id
            tenantId, // tenantId
            name, // name
            code, // code
            "PERCENTAGE", // type
            maxPercent, // value
            "CATEGORY", // appliesTo
            null, // productIds
            null, // minimumPurchase
            null, // maximumDiscount
            null, // customerGroupIds
            null, // customerIds
            null, // validFrom
            null, // validTo
            null, // usageLimit
            null, // perCustomerLimit
            false, // combinable
            0, // priority
            true, // active
            false, // requiresApproval
            notes, // notes
            now, // createdAt
            now // updatedAt
          ];

          const placeholderStart = params.length + 1;
          const placeholders = Array.from(
            { length: rowParams.length },
            (_, idx) => `$${placeholderStart + idx}`
          );
          values.push(`(${placeholders.join(", ")})`);
          params.push(...rowParams);
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "Discount" (
              id, "tenantId", name, code, type, value, "appliesTo",
              "productIds", "minimumPurchase", "maximumDiscount", "customerGroupIds",
              "customerIds", "validFrom", "validTo", "usageLimit", "perCustomerLimit",
              combinable, priority, active, "requiresApproval", notes, "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (code)
            DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              name = EXCLUDED.name,
              code = EXCLUDED.code,
              type = EXCLUDED.type,
              value = EXCLUDED.value,
              "appliesTo" = EXCLUDED."appliesTo",
              "productIds" = EXCLUDED."productIds",
              "minimumPurchase" = EXCLUDED."minimumPurchase",
              "maximumDiscount" = EXCLUDED."maximumDiscount",
              "customerGroupIds" = EXCLUDED."customerGroupIds",
              "customerIds" = EXCLUDED."customerIds",
              "validFrom" = EXCLUDED."validFrom",
              "validTo" = EXCLUDED."validTo",
              "usageLimit" = EXCLUDED."usageLimit",
              "perCustomerLimit" = EXCLUDED."perCustomerLimit",
              combinable = EXCLUDED.combinable,
              priority = EXCLUDED.priority,
              active = EXCLUDED.active,
              "requiresApproval" = EXCLUDED."requiresApproval",
              notes = EXCLUDED.notes,
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }

        total += chunk.length;
      }

      lastId = rows[rows.length - 1].DiscountId;
      console.log(`Discounts migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ Discount migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateDiscount;
