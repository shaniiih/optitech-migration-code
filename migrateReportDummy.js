const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 2000;
const BATCH_SIZE = 500;

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function formatDecimal(value, scale) {
  if (value === null || value === undefined) return null;
  const num = typeof value === "number" ? value : Number(String(value).trim());
  if (!Number.isFinite(num)) return null;
  const fixed = num.toFixed(scale);
  // Remove trailing zeros and possible trailing dot
  return fixed.replace(/\.?0+$/, "");
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function safeDate(value) {
  if (!value) return null;
  const d = new Date(value);
  return Number.isFinite(d.getTime()) ? d : null;
}

async function migrateReportDummy(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT * FROM tblReportDummy
          WHERE XId > ?
          ORDER BY XId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();
        const seen = new Set();

        for (const r of chunk) {
          const xId = asInteger(r.XId);
          if (xId === null || seen.has(xId)) continue;
          seen.add(xId);

          const base = params.length;
          const placeholders = Array.from({ length: 76 }, (_, idx) => `$${base + idx + 1}`).join(
            ", "
          );
          values.push(`(${placeholders})`);

          params.push(
            createId(),                 // id
            tenantId,                 // tenantId
            branchId,                 // branchId
            cleanText(r.Address),     // address
            cleanText(r.CellPhone),   // cellPhone
            cleanText(r.HomePhone),   // homePhone
            safeDate(r.BirthDate),    // birthDate
            cleanText(r.CityName),    // cityName
            cleanText(r.PLastName),   // pLastName
            cleanText(r.PFirstName),  // pFirstName
            cleanText(r.ULastName),   // uLastName
            cleanText(r.UFirstName),  // uFirstName
            safeDate(r.CheckDate),    // checkDate
            safeDate(r.ReCheckDate),  // reCheckDate
            cleanText(r.PupDiam),     // pupDiam
            formatDecimal(r.CornDiam, 1),    // cornDiam
            formatDecimal(r.EyeLidKey, 1),   // eyeLidKey
            asInteger(r.BUT),         // butValue
            cleanText(r.ShirR),       // shirR
            cleanText(r.ShirL),       // shirL
            cleanText(r.Ecolor),      // ecolor
            formatDecimal(r.rHR, 2),         // rHR
            formatDecimal(r.rHL, 2),         // rHL
            formatDecimal(r.rVR, 2),         // rVR
            formatDecimal(r.rVL, 2),         // rVL
            asInteger(r.AxHR),        // axHR
            asInteger(r.AxHL),        // axHL
            formatDecimal(r.rTR, 2),         // rTR
            formatDecimal(r.rTL, 2),         // rTL
            formatDecimal(r.rNR, 2),         // rNR
            formatDecimal(r.rNL, 2),         // rNL
            formatDecimal(r.rIR, 2),         // rIR
            formatDecimal(r.rIL, 2),         // rIL
            formatDecimal(r.rSR, 2),         // rSR
            formatDecimal(r.rSL, 2),         // rSL
            formatDecimal(r.diamR, 1),       // diamR
            formatDecimal(r.diamL, 1),       // diamL
            cleanText(r.BC1R),        // bc1R
            cleanText(r.BC1L),        // bc1L
            formatDecimal(r.BC2R, 2),        // bc2R
            formatDecimal(r.BC2L, 2),        // bc2L
            cleanText(r.OZR),         // ozR
            cleanText(r.OZL),         // ozL
            cleanText(r.PrR),         // prR
            cleanText(r.PrL),         // prL
            cleanText(r.SphR),        // sphR
            cleanText(r.SphL),        // sphL
            formatDecimal(r.CylR, 2),        // cylR
            formatDecimal(r.CylL, 2),        // cylL
            asInteger(r.AxR),         // axR
            asInteger(r.AxL),         // axL
            cleanText(r.ClensTypeIdR),// clensTypeIdR
            cleanText(r.ClensTypeIdL),// clensTypeIdL
            cleanText(r.ClensManufIdR),// clensManufIdR
            cleanText(r.ClensManufIdL),// clensManufIdL
            cleanText(r.ClensBrandIdR),// clensBrandIdR
            cleanText(r.ClensBrandIdL),// clensBrandIdL
            cleanText(r.ClensSolCleanName),     // clensSolCleanName
            cleanText(r.ClensSolDisinfectName), // clensSolDisinfectName
            cleanText(r.ClensSolRinseName),     // clensSolRinseName
            cleanText(r.Comments),    // comments
            asInteger(r.PerId),       // legacyPerId
            null,                     // perId
            cleanText(r.MaterR),      // materR
            cleanText(r.MaterL),      // materL
            cleanText(r.TintR),       // tintR
            cleanText(r.TintL),       // tintL
            cleanText(r.VAR),         // vaR
            cleanText(r.VAL),         // vaL
            cleanText(r.VA),          // va
            cleanText(r.PHR),         // phR
            cleanText(r.PHL),         // phL
            asInteger(r.BUTL),        // butL
            xId,                      // xId
            now,                      // createdAt
            now                       // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "ReportDummy" (
               id,
               "tenantId",
               "branchId",
               address,
               "cellPhone",
               "homePhone",
               "birthDate",
               "cityName",
               "pLastName",
               "pFirstName",
               "uLastName",
               "uFirstName",
               "checkDate",
               "reCheckDate",
               "pupDiam",
               "cornDiam",
               "eyeLidKey",
               "butValue",
               "shirR",
               "shirL",
               ecolor,
               "rHR",
               "rHL",
               "rVR",
               "rVL",
               "axHR",
               "axHL",
               "rTR",
               "rTL",
               "rNR",
               "rNL",
               "rIR",
               "rIL",
               "rSR",
               "rSL",
               "diamR",
               "diamL",
               "bc1R",
               "bc1L",
               "bc2R",
               "bc2L",
               "ozR",
               "ozL",
               "prR",
               "prL",
               "sphR",
               "sphL",
               "cylR",
               "cylL",
               "axR",
               "axL",
               "clensTypeIdR",
               "clensTypeIdL",
               "clensManufIdR",
               "clensManufIdL",
               "clensBrandIdR",
               "clensBrandIdL",
               "clensSolCleanName",
               "clensSolDisinfectName",
               "clensSolRinseName",
               "comments",
               "legacyPerId",
               "perId",
               "materR",
               "materL",
               "tintR",
               "tintL",
               "vaR",
               "vaL",
               "va",
               "phR",
               "phL",
               "butL",
               "xId",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "xId") DO NOTHING`,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      const latestId = asInteger(rows[rows.length - 1]?.XId);
      if (latestId !== null) {
        lastId = latestId;
      }
      console.log(`ReportDummy migrated so far: ${total} (lastXId=${lastId})`);
    }

    console.log(`✅ ReportDummy migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateReportDummy;
