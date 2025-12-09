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
  "prevId", "legacyPerId", "perId", "checkDate", "glassCheckRecordId",
  "refSphR","refSphL","refCylR","refCylL","refAxR","refAxL",
  "legacyRetTypeId1","retTypeId1","legacyRetDistId1","retDistId1","retCom1",
  "refSphR2","refSphL2","refCylR2","refCylL2","refAxR2","refAxL2",
  "legacyRetTypeId2","retTypeId2","legacyRetDistId2","retDistId2","retCom2",
  "sphR1","sphL1","cylR1","cylL1","axR1","axL1","prisR1","prisL1","baseR1","baseL1",
  "var1","val1","va1","phr1","phl1","extPrisR1","extPrisL1","extBaseR1","extBaseL1",
  "comments1","pdDistR1","pdDistL1","pdDistA1","addR1","addL1",
  "createdAt","updatedAt"
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

async function migrateCrdGlassCheckPrev(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();
  let offset = 0;
  let total = 0;

  try {
    const retTypeMap = await buildMap(pg, "CrdGlassRetType", "retTypeId", tenantId, branchId);
    const retDistMap = await buildMap(pg, "CrdGlassRetDist", "retDistId", tenantId, branchId);
    const glassCheckMap = await buildGlassCheckMap(pg, tenantId, branchId);

    while (true) {
      const [rows] = await mysql.query(
        `SELECT * FROM tblCrdGlassChecksPrevs ORDER BY PerId, CheckDate, PrevId LIMIT ? OFFSET ?`,
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
          const prevId = normalizeInt(row.PrevId);
          const checkDateObj = row.CheckDate ? new Date(row.CheckDate) : null;
          const dateKey = checkDateObj ? checkDateObj.toISOString().split("T")[0] : null;
          const parentKey = (legacyPerId !== null && dateKey) ? `${legacyPerId}|${dateKey}` : null;
          const parent = parentKey ? glassCheckMap.get(parentKey) : null;

          const legacyRetTypeId1 = normalizeInt(row.RetTypeId1);
          const legacyRetTypeId2 = normalizeInt(row.RetTypeId2);
          const legacyRetDistId1 = normalizeInt(row.RetDistId1);
          const legacyRetDistId2 = normalizeInt(row.RetDistId2);

          const retTypeId1 = retTypeMap.get(legacyRetTypeId1) || null;
          const retTypeId2 = retTypeMap.get(legacyRetTypeId2) || null;
          const retDistId1 = retDistMap.get(legacyRetDistId1) || null;
          const retDistId2 = retDistMap.get(legacyRetDistId2) || null;

          const rowValues = [
            createId(),
            tenantId,
            branchId,
            prevId,
            legacyPerId,
            parent ? parent.perId : null,
            checkDateObj,
            parent ? parent.id : null,
            cleanText(row.RefSphR),
            cleanText(row.RefSphL),
            normalizeDecimal(row.RefCylR),
            normalizeDecimal(row.RefCylL),
            normalizeInt(row.RefAxR),
            normalizeInt(row.RefAxL),
            legacyRetTypeId1,
            retTypeId1,
            legacyRetDistId1,
            retDistId1,
            cleanText(row.RetCom1),
            cleanText(row.RefSphR2),
            cleanText(row.RefSphL2),
            normalizeDecimal(row.RefCylR2),
            normalizeDecimal(row.RefCylL2),
            normalizeInt(row.RefAxR2),
            normalizeInt(row.RefAxL2),
            legacyRetTypeId2,
            retTypeId2,
            legacyRetDistId2,
            retDistId2,
            cleanText(row.RetCom2),
            cleanText(row.SphR1),
            cleanText(row.SphL1),
            normalizeDecimal(row.CylR1),
            normalizeDecimal(row.CylL1),
            normalizeInt(row.AxR1),
            normalizeInt(row.AxL1),
            normalizeDecimal(row.PrisR1),
            normalizeDecimal(row.PrisL1),
            normalizeInt(row.BaseR1),
            normalizeInt(row.BaseL1),
            cleanText(row.VAR1),
            cleanText(row.VAL1),
            cleanText(row.VA1),
            cleanText(row.PHR1),
            cleanText(row.PHL1),
            normalizeDecimal(row.ExtPrisR1),
            normalizeDecimal(row.ExtPrisL1),
            normalizeInt(row.ExtBaseR1),
            normalizeInt(row.ExtBaseL1),
            cleanText(row.Comments1),
            normalizeDecimal(row.PDDistR1),
            normalizeDecimal(row.PDDistL1),
            normalizeDecimal(row.PDDistA1),
            normalizeDecimal(row.AddR1),
            normalizeDecimal(row.AddL1),
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
            INSERT INTO "CrdGlassCheckPrev"
              (${COLUMNS.map(c => `"${c}"`).join(",")})
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId","branchId","prevId", "legacyPerId", "checkDate")
            DO UPDATE SET
              ${COLUMNS
                .filter(c => !["id","tenantId","branchId","prevId","createdAt", "updatedAt"].includes(c))
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

  console.log("CrdGlassCheckPrev migration completed:", total);
}

module.exports = migrateCrdGlassCheckPrev;
