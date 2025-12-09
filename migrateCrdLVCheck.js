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
  "lvId", "legacyPerId", "perId", "checkDate", "glassCheckRecordId",
  "legacyEyeId", "eyeId",
  "pdR", "pdL",
  "legacyManufId", "manufId",
  "legacyFrameId", "frameId",
  "legacyAreaId", "areaId",
  "legacyCapId", "capId",
  "vad", "van", "vadL", "vanL",
  "com",
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

async function buildGlassCheckMap(pg, tenantId, branchId) {
  const map = new Map();
  const { rows } = await pg.query(
    `SELECT id, "perId", "checkDate", "legacyPerId" FROM "CrdGlassCheck" WHERE "tenantId" = $1 AND "branchId" = $2`,
    [tenantId, branchId]
  );
  for (const r of rows) {
    const legacy = normalizeInt(r.legacyPerId);
    if (legacy === null || !r.checkDate) continue;
    const dateKey = r.checkDate.toISOString().split("T")[0];
    map.set(`${legacy}|${dateKey}`, { id: r.id, perId: r.perId, checkDate: r.checkDate });
  }
  return map;
}

async function migrateCrdLVCheck(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();
  let offset = 0;
  let total = 0;

  try {
    const manufMap = await buildMap(pg, "CrdLVManuf", "LVManufId", tenantId, branchId);
    const frameMap = await buildMap(pg, "CrdLVFrame", "LVFrameId", tenantId, branchId);
    const areaMap = await buildMap(pg, "CrdLVArea", "LVAreaId", tenantId, branchId);
    const capMap = await buildMap(pg, "CrdLVCap", "lVCapId", tenantId, branchId);
    const eyeMap = await buildMap(pg, "Eye", "eyeId", tenantId, branchId); 
    const glassCheckMap = await buildGlassCheckMap(pg, tenantId, branchId);

    while (true) {
      const [rows] = await mysql.query(
        `SELECT * FROM tblCrdLVChecks ORDER BY PerId, CheckDate, LVId LIMIT ? OFFSET ?`,
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
          const lvId = normalizeInt(row.LVId);
          const checkDateObj = row.CheckDate ? new Date(row.CheckDate) : null;
          const dateKey = checkDateObj ? checkDateObj.toISOString().split("T")[0] : null;
          const parentKey = (legacyPerId !== null && dateKey) ? `${legacyPerId}|${dateKey}` : null;
          const parent = parentKey ? glassCheckMap.get(parentKey) : null;

          const legacyManufId = normalizeInt(row.ManufId);
          const legacyFrameId = normalizeInt(row.FrameId);
          const legacyAreaId = normalizeInt(row.AreaId);
          const legacyCapId = normalizeInt(row.CapId);
          const legacyEyeId = normalizeInt(row.EyeId);

          const manufId = manufMap.get(legacyManufId) || null;
          const frameId = frameMap.get(legacyFrameId) || null;
          const areaId = areaMap.get(legacyAreaId) || null;
          const capId = capMap.get(legacyCapId) || null;
          const eyeId = eyeMap.get(legacyEyeId) || null;
          const rowValues = [
            createId(),
            tenantId,
            branchId,
            lvId,
            legacyPerId,
            parent ? parent.perId : null,
            checkDateObj,
            parent ? parent.id : null,
            legacyEyeId,
            eyeId,
            normalizeDecimal(row.PDR),
            normalizeDecimal(row.PDL),
            legacyManufId,
            manufId,
            legacyFrameId,
            frameId,
            legacyAreaId,
            areaId,
            legacyCapId,
            capId,
            cleanText(row.VAD),
            cleanText(row.VAN),
            cleanText(row.VADL),
            cleanText(row.VANL),
            cleanText(row.Com),
            now, now
          ];

          const placeholders = rowValues.map(() => `$${p++}`);
          values.push(`(${placeholders.join(",")})`);
          params.push(...rowValues);
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "CrdLVCheck"
              (${COLUMNS.map(c => `"${c}"`).join(",")})
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId","branchId","lvId","legacyPerId","checkDate")
            DO UPDATE SET
              ${COLUMNS
                .filter(c => !["id","tenantId","branchId","lvId","legacyPerId","checkDate","createdAt","updatedAt"].includes(c))
                .map(c => `"${c}" = EXCLUDED."${c}"`)
                .join(",")},
              "updatedAt" = NOW()
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

      offset += rows.length;
    }
  } finally {
    await mysql.end();
    await pg.end();
  }

  console.log("CrdLVCheck migration completed:", total);
}

module.exports = migrateCrdLVCheck;
