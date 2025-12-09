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
  const t = String(value).trim();
  return t.length ? t : null;
}

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 500;

const COLUMNS = [
  "id", "tenantId", "branchId",
  "fitId", "legacyPerId", "perId", "checkDate", "clensCheckRecordId",
  "diamR", "diamL",
  "bc1R", "bc1L", "bc2R", "bc2L",
  "sphR", "sphL",
  "cylR", "cylL", "axR", "axL",
  "var", "val", "va", "phr", "phl",
  "clensTypeIdR", "legacyClensTypeIdR", "clensTypeIdL", "legacyClensTypeIdL",
  "clensManufIdR", "legacyClensManufIdR", "clensManufIdL", "legacyClensManufIdL",
  "clensBrandIdR", "legacyClensBrandIdR", "clensBrandIdL", "legacyClensBrandIdL",
  "comR", "comL",
  "createdAt", "updatedAt"
];

async function buildMap(pg, table, legacyField, tenantId, branchId) {
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
}

async function buildCrdClensCheckMap(pg, tenantId, branchId) {
  const map = new Map();
  const { rows } = await pg.query(
    `SELECT id, "perId", "checkDate", "legacyPerId" 
     FROM "CrdClensCheck" 
     WHERE "tenantId" = $1 AND "branchId" = $2`,
    [tenantId, branchId]
  );

  for (const r of rows) {
    const legacy = normalizeInt(r.legacyPerId);
    if (legacy === null || !r.checkDate) continue;

    const dateKey = r.checkDate.toISOString().split("T")[0];

    map.set(`${legacy}|${dateKey}`, {
      id: r.id,
      perId: r.perId,
      checkDate: r.checkDate
    });
  }

  return map;
}


async function migrateCrdClensFit(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    const clensTypeMap = await buildMap(pg, "CrdClensType", "clensTypeId", tenantId, branchId);
    const clensManufMap = await buildMap(pg, "CrdClensManuf", "clensManufId", tenantId, branchId);
    const clensBrandMap = await buildMap(pg, "CrdClensBrand", "clensBrandId", tenantId, branchId);

    const clensCheckMap = await buildCrdClensCheckMap(pg, tenantId, branchId);

    while (true) {
      const [rows] = await mysql.query(
        `SELECT * FROM tblCrdClensFits ORDER BY PerId, CheckDate, FitId LIMIT ? OFFSET ?`,
        [WINDOW_SIZE, offset]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();

        const values = [];
        const params = [];
        let p = 1;

        for (const row of chunk) {
          const legacyPerId = normalizeInt(row.PerId);
          const legacyFitId = normalizeInt(row.FitId);
          const checkDateObj = row.CheckDate ? new Date(row.CheckDate) : null;
          const dateKey = checkDateObj ? checkDateObj.toISOString().split("T")[0] : null;
          const parentKey = (legacyPerId !== null && dateKey) ? `${legacyPerId}|${dateKey}` : null;
          const parent = parentKey ? clensCheckMap.get(parentKey) : null;

          const legacyClensTypeIdR = normalizeInt(row.ClensTypeIdR);
          const legacyClensTypeIdL = normalizeInt(row.ClensTypeIdL);
          const legacyClensManufIdR = normalizeInt(row.ClensManufIdR);
          const legacyClensManufIdL = normalizeInt(row.ClensManufIdL);
          const legacyClensBrandIdR = normalizeInt(row.ClensBrandIdR);
          const legacyClensBrandIdL = normalizeInt(row.ClensBrandIdL);

          const clensTypeIdR = clensTypeMap.get(legacyClensTypeIdR) || null;
          const clensTypeIdL = clensTypeMap.get(legacyClensTypeIdL) || null;
          const clensManufIdR = clensManufMap.get(legacyClensManufIdR) || null;
          const clensManufIdL = clensManufMap.get(legacyClensManufIdL) || null;
          const clensBrandIdR = clensBrandMap.get(legacyClensBrandIdR) || null;
          const clensBrandIdL = clensBrandMap.get(legacyClensBrandIdL) || null;

          const rowValues = [
            createId(),
            tenantId,
            branchId,

            legacyFitId,                    
            legacyPerId,
            parent ? parent.perId : null,   
            parent ? parent.checkDate : (checkDateObj || null), 
            parent ? parent.id : null,       

            normalizeDecimal(row.DiamR),
            normalizeDecimal(row.DiamL),

            cleanText(row.BC1R),
            cleanText(row.BC1L),
            normalizeDecimal(row.BC2R),
            normalizeDecimal(row.BC2L),

            cleanText(row.SphR),
            cleanText(row.SphL),

            normalizeDecimal(row.CylR),
            normalizeDecimal(row.CylL),
            normalizeInt(row.AxR),
            normalizeInt(row.AxL),

            cleanText(row.VAR),
            cleanText(row.VAL),
            cleanText(row.VA),
            cleanText(row.PHR),
            cleanText(row.PHL),

            clensTypeIdR, legacyClensTypeIdR, clensTypeIdL, legacyClensTypeIdL,
            clensManufIdR, legacyClensManufIdR, clensManufIdL, legacyClensManufIdL,
            clensBrandIdR, legacyClensBrandIdR, clensBrandIdL, legacyClensBrandIdL,

            cleanText(row.ComR),
            cleanText(row.ComL),

            now,
            now
          ];

          const placeholders = rowValues.map(() => `$${p++}`);
          values.push(`(${placeholders.join(",")})`);
          params.push(...rowValues);
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          const queryText = `
            INSERT INTO "CrdClensFit"
              (${COLUMNS.map(c => `"${c}"`).join(",")})
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId","branchId","legacyPerId","checkDate","fitId")
            DO UPDATE SET
              ${COLUMNS
                .filter(c =>
                  !["id","tenantId","legacyPerId","checkDate","fitId","createdAt", "updatedAt"].includes(c)
                )
                .map(c => `"${c}" = EXCLUDED."${c}"`)
                .join(",")},
              "updatedAt" = NOW()
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

  console.log("CrdClensFit migration completed:", total);
}

module.exports = migrateCrdClensFit;
