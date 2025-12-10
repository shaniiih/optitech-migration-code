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
  "id", "branchId", "tenantId",
  "orthokId", "legacyPerId", "perId",
  "checkDate", "reCheckDate",
  "legacyUserId", "userId",
  "rHR", "rHL", "rVR", "rVL",
  "axHR", "axHL",
  "rTR", "rTL", "rNR", "rNL", "rIR", "rIL", "rSR", "rSL",
  "diamR", "diamL",
  "bc1R", "bc1L",
  "ozR", "ozL",
  "sphR", "sphL",
  "fCR", "fCL",
  "aCR", "aCL",
  "ac2R", "ac2L",
  "sBR", "sBL",
  "egR", "egL",
  "fCRCT", "fCLCT",
  "aCRCT", "aCLCT",
  "ac2RCT", "ac2LCT",
  "egRCT", "egLCT",
  "legacyMaterR", "materR",
  "legacyMaterL", "materL",
  "legacyTintR", "tintR",
  "legacyTintL", "tintL",
  "legacyClensTypeIdR", "clensTypeIdR",
  "legacyClensTypeIdL", "clensTypeIdL",
  "legacyClensManufIdR", "clensManufIdR",
  "legacyClensManufIdL", "clensManufIdL",
  "legacyClensBrandIdR", "clensBrandIdR",
  "legacyClensBrandIdL", "clensBrandIdL",
  "var", "val",
  "comR", "comL",
  "picL", "picR",
  "ozRCT", "ozLCT",
  "orderId", "custId",
  "pupDiam", "cornDiam",
  "eyeLidKey", "checkType",
  "va",
  "eHR", "eHL", "eVR", "eVL", "eAR", "eAL",
  "createdAt", "updatedAt"
];

async function migrateCrdOrthok(tenantId = "tenant_1", branchId = null) {
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
    const materMap = await buildMap("CrdClensChecksMater", "materId");
    const tintMap = await buildMap("CrdClensChecksTint", "tintId");
    const typeMap = await buildMap("CrdClensType", "clensTypeId");
    const manufMap = await buildMap("CrdClensManuf", "clensManufId");
    const brandMap = await buildMap("CrdClensBrand", "clensBrandId");

    while (true) {
      const [rows] = await mysql.query(
        `SELECT * FROM tblCrdOrthoks ORDER BY PerId, CheckDate LIMIT ? OFFSET ?`,
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
          if (perId === null) {
            throw new Error(
              `CrdOrthok migration: missing PerData mapping for legacy PerId=${legacyPerId} (OrthokId=${row.OrthokId})`
            );
          }
          const userId = userMap.get(legacyUserId) || null;

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

          const rowValues = [
            createId(), branchId, tenantId,
            normalizeInt(row.OrthokId), legacyPerId, perId,
            row.CheckDate ? new Date(row.CheckDate) : null,
            row.ReCheckDate ? new Date(row.ReCheckDate) : null,
            legacyUserId, userId,
            normalizeDecimal(row.rHR), normalizeDecimal(row.rHL),
            normalizeDecimal(row.rVR), normalizeDecimal(row.rVL),
            normalizeInt(row.AxHR), normalizeInt(row.AxHL),
            normalizeDecimal(row.rTR), normalizeDecimal(row.rTL),
            normalizeDecimal(row.rNR), normalizeDecimal(row.rNL),
            normalizeDecimal(row.rIR), normalizeDecimal(row.rIL),
            normalizeDecimal(row.rSR), normalizeDecimal(row.rSL),
            normalizeDecimal(row.DiamR), normalizeDecimal(row.DiamL),
            cleanText(row.BC1R), cleanText(row.BC1L),
            cleanText(row.OZR), cleanText(row.OZL),
            cleanText(row.SphR), cleanText(row.SphL),
            normalizeDecimal(row.FCR), normalizeDecimal(row.FCL),
            normalizeDecimal(row.ACR), normalizeDecimal(row.ACL),
            normalizeDecimal(row.AC2R), normalizeDecimal(row.AC2L),
            normalizeDecimal(row.SBR), normalizeDecimal(row.SBL),
            cleanText(row.EGR), cleanText(row.EGL),
            normalizeDecimal(row.FCRCT), normalizeDecimal(row.FCLCT),
            normalizeDecimal(row.ACRCT), normalizeDecimal(row.ACLCT),
            normalizeDecimal(row.AC2RCT), normalizeDecimal(row.AC2LCT),
            normalizeDecimal(row.EGRCT), normalizeDecimal(row.EGLCT),
            materR, materMap.get(materR) || null,
            materL, materMap.get(materL) || null,
            tintR, tintMap.get(tintR) || null,
            tintL, tintMap.get(tintL) || null,
            typeR, typeMap.get(typeR) || null,
            typeL, typeMap.get(typeL) || null,
            manufR, manufMap.get(manufR) || null,
            manufL, manufMap.get(manufL) || null,
            brandR, brandMap.get(brandR) || null,
            brandL, brandMap.get(brandL) || null,
            cleanText(row.VAR), cleanText(row.VAL),
            cleanText(row.ComR), cleanText(row.ComL),
            cleanText(row.PICL), cleanText(row.PICR),
            normalizeDecimal(row.OZRCT), normalizeDecimal(row.OZLCT),
            cleanText(row.OrderId), cleanText(row.CustId),
            cleanText(row.PupDiam), normalizeDecimal(row.CornDiam),
            normalizeDecimal(row.EyeLidKey), normalizeInt(row.CheckType),
            cleanText(row.VA),
            normalizeDecimal(row.EHR), normalizeDecimal(row.EHL),
            normalizeDecimal(row.EVR), normalizeDecimal(row.EVL),
            normalizeDecimal(row.EAR), normalizeDecimal(row.EAL),
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
          const nonIdColumns = COLUMNS.filter((c) => {
            const excluded = [
              "id",
              "tenantId",
              "branchId",
              "orthokId",
              "legacyPerId",
              "legacyUserId",
              "legacyMaterR",
              "materR",
              "legacyMaterL",
              "materL",
              "legacyTintR",
              "tintR",
              "legacyTintL",
              "tintL",
              "legacyClensTypeIdR",
              "clensTypeIdR",
              "legacyClensTypeIdL",
              "clensTypeIdL",
              "legacyClensManufIdR",
              "clensManufIdR",
              "legacyClensManufIdL",
              "clensManufIdL",
              "legacyClensBrandIdR",
              "clensBrandIdR",
              "legacyClensBrandIdL",
              "clensBrandIdL",
              "createdAt",
              "updatedAt",
            ];
            return !excluded.includes(c);
          });

          const queryText = `
            INSERT INTO "CrdOrthok" (${COLUMNS.map((c) => `"${c}"`).join(", ")})
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "orthokId")
            DO UPDATE SET
              ${nonIdColumns
                .map((c) => `"${c}" = EXCLUDED."${c}"`)
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

  console.log("CrdOrthok migration completed:", total);
}

module.exports = migrateCrdOrthok;
