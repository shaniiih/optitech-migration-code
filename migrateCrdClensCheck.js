const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

function normalizeInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  if (typeof value === "bigint") return Number(value);
  if (Buffer.isBuffer(value)) return normalizeInt(value.toString("utf8"));
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function normalizeDecimal(value) {
  if (value === null || value === undefined) return null;
  const num = Number(String(value).trim());
  return Number.isFinite(num) ? num : null;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 500; 

const COLUMNS = [
  "id", "tenantId", "branchId", "clensId",
  "perId", "legacyPerId", "checkDate",
  "userId", "legacyUserId",
  "reCheckDate", "pupDiam", "cornDiam", "eyeLidKey", "but",
  "shirR", "shirL", "ecolor",
  "rHR", "rHL", "rVR", "rVL",
  "axHR", "axHL", "rTR", "rTL", "rNR", "rNL", "rIR", "rIL", "rSR", "rSL",
  "diamR", "diamL",
  "bc1R", "bc1L", "bc2R", "bc2L",
  "ozR", "ozL",
  "prR", "legacyPrR",
  "prL", "legacyPrL",
  "sphR", "sphL", "cylR", "cylL", "axR", "axL",
  "materR", "legacyMaterR",
  "materL", "legacyMaterL",
  "tintR", "legacyTintR",
  "tintL", "legacyTintL",
  "varR", "varL", "va", "phr", "phl",
  "clensTypeIdR", "legacyClensTypeIdR",
  "clensTypeIdL", "legacyClensTypeIdL",
  "clensManufIdR", "legacyClensManufIdR",
  "clensManufIdL", "legacyClensManufIdL",
  "clensBrandIdR", "legacyClensBrandIdR",
  "clensBrandIdL", "legacyClensBrandIdL",
  "clensSolCleanId", "legacyClensSolCleanId",
  "clensSolDisinfectId", "legacyClensSolDisinfectId",
  "clensSolRinseId", "legacyClensSolRinseId",
  "comments", "addR", "addL", "butL", "blinkFreq", "blinkQual", "fitCom",
  "createdAt", "updatedAt"
];

async function migrateCrdClensCheck(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    const buildMap = async (table, legacyField) => {
      const map = new Map();
      const { rows } = await pg.query(
        `SELECT id, "${legacyField}" FROM "${table}" WHERE "tenantId" = $1 AND "branchId" = $2`,
        [tenantId, branchId]
      );
      for (const r of rows) {
        const legacy = normalizeInt(r[legacyField]);
        if (legacy !== null) map.set(legacy, r.id);
      }
      return map;
    };

    const perMap = await buildMap("PerData", "perId");
    const userMap = await buildMap("User", "userId");
    const prMap = await buildMap("CrdClensChecksPr", "prId");
    const materMap = await buildMap("CrdClensChecksMater", "materId");
    const tintMap = await buildMap("CrdClensChecksTint", "tintId");
    const typeMap = await buildMap("CrdClensType", "clensTypeId");
    const manufMap = await buildMap("CrdClensManuf", "clensManufId");
    const brandMap = await buildMap("CrdClensBrand", "clensBrandId");
    const solCleanMap = await buildMap("CrdClensSolClean", "clensSolCleanId");
    const solDisMap = await buildMap("CrdClensSolDisinfect", "clensSolDisinfectId");
    const solRinseMap = await buildMap("CrdClensSolRinse", "clensSolRinseId");

    while (true) {
      const [rows] = await mysql.query(
        `SELECT * FROM tblCrdClensChecks ORDER BY PerId, CheckDate LIMIT ? OFFSET ?`,
        [WINDOW_SIZE, offset]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        for (const row of chunk) {

          const legacyPerId = normalizeInt(row.PerId);
          const legacyUserId = normalizeInt(row.UserId);

          const perId = perMap.get(legacyPerId) || null;
          const userId = userMap.get(legacyUserId) || null;

          const prR = normalizeInt(row.PrR);
          const prL = normalizeInt(row.PrL);
          const materR = normalizeInt(row.MaterR);
          const materL = normalizeInt(row.MaterL);
          const tintR = normalizeInt(row.TintR);
          const tintL = normalizeInt(row.TintL);
          const typeR = normalizeInt(row.ClensTypeIdR);
          const typeL = normalizeInt(row.ClensTypeIdL);
          const manufR = normalizeInt(row.ClensManufIdR);
          const manufL = normalizeInt(row.ClensManufIdL);
          const brandR = normalizeInt(row.ClensBrandIdR);
          const brandL = normalizeInt(row.ClensBrandIdL);
          const solClean = normalizeInt(row.ClensSolCleanId);
          const solDisinfect = normalizeInt(row.ClensSolDisinfectId);
          const solRinse = normalizeInt(row.ClensSolRinseId);

          const rowValues = [
            createId(), tenantId, branchId,row.ClensId || null,
            perId, legacyPerId, row.CheckDate ? new Date(row.CheckDate) : null,
            userId, legacyUserId,
            row.ReChkDate ? new Date(row.ReChkDate) : null,
            cleanText(row.PupDiam), normalizeDecimal(row.CornDiam), normalizeDecimal(row.EyeLidKey),
            normalizeInt(row.BUT), cleanText(row.ShirR), cleanText(row.ShirL), cleanText(row.Ecolor),
            normalizeDecimal(row.RHR), normalizeDecimal(row.RHL), normalizeDecimal(row.RVR), normalizeDecimal(row.RVL),
            normalizeInt(row.AxHR), normalizeInt(row.AxHL), normalizeDecimal(row.RTR), normalizeDecimal(row.RTL),
            normalizeDecimal(row.RNR), normalizeDecimal(row.RNL), normalizeDecimal(row.RIR), normalizeDecimal(row.RIL),
            normalizeDecimal(row.RSR), normalizeDecimal(row.RSL), normalizeDecimal(row.DiamR), normalizeDecimal(row.DiamL),
            cleanText(row.Bc1R), cleanText(row.Bc1L), normalizeDecimal(row.Bc2R), normalizeDecimal(row.Bc2L),
            cleanText(row.OzR), cleanText(row.OzL),
            prMap.get(prR) || null, prR, prMap.get(prL) || null, prL,
            cleanText(row.SphR), cleanText(row.SphL), normalizeDecimal(row.CylR), normalizeDecimal(row.CylL),
            normalizeInt(row.AxR), normalizeInt(row.AxL),
            materMap.get(materR) || null, materR, materMap.get(materL) || null, materL,
            tintMap.get(tintR) || null, tintR, tintMap.get(tintL) || null, tintL,
            cleanText(row.VarR), cleanText(row.VarL), cleanText(row.VA), cleanText(row.PHR), cleanText(row.PHL),
            typeMap.get(typeR) || null, typeR, typeMap.get(typeL) || null, typeL,
            manufMap.get(manufR) || null, manufR, manufMap.get(manufL) || null, manufL,
            brandMap.get(brandR) || null, brandR, brandMap.get(brandL) || null, brandL,
            solCleanMap.get(solClean) || null, solClean, solDisMap.get(solDisinfect) || null, solDisinfect,
            solRinseMap.get(solRinse) || null, solRinse,
            cleanText(row.Comments), cleanText(row.AddR), cleanText(row.AddL), normalizeInt(row.BUTL),
            cleanText(row.BlinkFreq), cleanText(row.BlinkQual), cleanText(row.FitCom),
            now, now
          ];

          const base = params.length;
          const placeholders = rowValues.map((_, idx) => `$${base + idx + 1}`);
          values.push(`(${placeholders.join(",")})`);
          params.push(...rowValues);
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          const queryText = `
            INSERT INTO "CrdClensCheck" (${COLUMNS.map(c => `"${c}"`).join(", ")})
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "legacyPerId", "checkDate")
            DO UPDATE SET
              ${COLUMNS
                .filter(c => !["id", "tenantId", "createdAt", "legacyPerId", "checkDate", "updatedAt"].includes(c))
                .map(c => `"${c}" = EXCLUDED."${c}"`)
                .join(",\n")},
              "updatedAt" = NOW();
          `;
          await pg.query(queryText, params);
          await pg.query("COMMIT");
          total += values.length;
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }
      }

      offset += rows.length;
    }
  } finally {
    await mysql.end();
    await pg.end();
  }

  console.log("CrdClensCheck migration completed:", total);
}

module.exports = migrateCrdClensCheck;
