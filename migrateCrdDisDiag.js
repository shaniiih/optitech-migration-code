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
  "id", "tenantId", "branchId",
  "perId", "legacyPerId",
  "checkDate",
  "pushUp", "minusLens",
  "monAccFac6", "monAccFac7", "monAccFac8", "monAccFac13",
  "binAccFac6", "binAccFac7", "binAccFac8", "binAccFac13",
  "memRet", "fusedXCyl", "nra", "pra",
  "coverDist", "coverNear",
  "distLatFor", "distVerFor",
  "nearLatFor", "nearVerFor",
  "acaRatio",
  "smverBo6M", "smverBi6M", "smverBo40CM", "smverBi40CM",
  "stverBo7", "stverBi7", "stverBo6M", "stverBi6M",
  "stverBo40CM", "stverBi40CM",
  "jmpVer5", "jmpVer8",
  "accTarget", "penlight", "penLightRG",
  "summary",
  "userId", "legacyUserId",
  "createdAt", "updatedAt"
];


async function migrateCrdDisDiag(tenantId = "tenant_1", branchId = null) {
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

    while (true) {
      const [rows] = await mysql.query(
        `SELECT * FROM tblCrdDisDiags ORDER BY PerId, CheckDate LIMIT ? OFFSET ?`,
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
          const rowValues = [
            createId(), tenantId, branchId,
            perId, legacyPerId,
            row.CheckDate ? new Date(row.CheckDate) : null,
            normalizeInt(row.PushUp),
            normalizeInt(row.MinusLens),
            normalizeDecimal(row.MonAccFac6),
            normalizeDecimal(row.MonAccFac7),
            normalizeDecimal(row.MonAccFac8),
            normalizeDecimal(row.MonAccFac13),
            normalizeDecimal(row.BinAccFac6),
            normalizeDecimal(row.BinAccFac7),
            normalizeDecimal(row.BinAccFac8),
            normalizeDecimal(row.BinAccFac13),
            normalizeDecimal(row.MemRet),
            normalizeDecimal(row.FusedXCyl),
            normalizeDecimal(row.NRA),
            normalizeDecimal(row.PRA),
            cleanText(row.CoverDist),
            cleanText(row.CoverNear),
            cleanText(row.DistLatFor),
            cleanText(row.DistVerFor),
            cleanText(row.NearLatFor),
            cleanText(row.NearVerFor),
            cleanText(row.AcaRatio),
            cleanText(row.SMVERBO6M),
            cleanText(row.SMVERBI6M),
            cleanText(row.SMVERBO40CM),
            cleanText(row.SMVERBI40CM),
            cleanText(row.STVERBO7),
            cleanText(row.STVERBI7),
            cleanText(row.STVER_BO6M),
            cleanText(row.STVERBI_6M),
            cleanText(row.STVERBO40CM),
            cleanText(row.STVERBI40CM),
            normalizeDecimal(row.JmpVer5),
            normalizeDecimal(row.JmpVer8),
            cleanText(row.AccTarget),
            cleanText(row.PenLight),
            cleanText(row.PenLightRG),
            cleanText(row.Summary),
            userId, legacyUserId,
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
            INSERT INTO "CrdDisDiag" (${COLUMNS.map(c => `"${c}"`).join(", ")})
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "legacyPerId", "checkDate")
            DO UPDATE SET
              ${COLUMNS
                .filter(c => !["id", "tenantId", "legacyPerId", "checkDate", "createdAt", "updatedAt",].includes(c))
                .map(c => `"${c}" = EXCLUDED."${c}"`)
                .join(",")},
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

  console.log("CrdDisDiag migration completed:", total);
}

module.exports = migrateCrdDisDiag;
