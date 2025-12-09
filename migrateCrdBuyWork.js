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

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const t = String(value).trim();
  return t.length ? t : null;
}

function toBoolean(value) {
    if (value === null || value === undefined) return null;
    if (typeof value === "boolean") return value;
    if (typeof value === "number") return Number.isFinite(value) ? value !== 0 : null;
    const trimmed = String(value).trim().toLowerCase();
    if (!trimmed) return null;
    if (["1", "true", "t", "yes", "y"].includes(trimmed)) return true;
    if (["0", "false", "f", "no", "n"].includes(trimmed)) return false;
    return null;
}

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 500;

// Prisma Columns
const COLUMNS = [
  "id", "tenantId", "branchId",
  "workId", "workDate",
  "legacyPerId", "perId",
  "legacyUserId", "userId",
  "legacyWorkTypeId", "workTypeId",
  "checkDate",
  "legacyWorkStatId", "workStatId",
  "legacyWorkSupplyId", "workSupplyId",
  "legacyLabId", "labId",
  "legacySapakId", "sapakId",
  "bagNum", "promiseDate", "deliverDate", "comment",
  "legacyFSapakId", "fSapakId",
  "legacyFLabelId", "fLabelId",
  "fModel", "fColor", "fSize",
  "frameSold",
  "legacyLnsSapakId", "lnsSapakId",
  "legacyGlassSapakId", "glassSapakId",
  "legacyClensSapakId", "clensSapakId",
  "glassId", "wType", "smsSent",
  "legacyItemId", "itemId",
  "legacyTailId", "tailId",
  "canceled",
  "createdAt", "updatedAt"
];

async function buildMap(pg, table, legacyField, tenantId, branchId) {
  const map = new Map();
  const sql = `
    SELECT id, "${legacyField}"
    FROM "${table}"
    WHERE "tenantId" = $1 AND "branchId" = $2
  `;
  const { rows } = await pg.query(sql, [tenantId, branchId]).catch(() => ({ rows: [] }));

  for (const r of rows) {
    const legacy = normalizeInt(r[legacyField]);
    if (legacy !== null) map.set(legacy, r.id);
  }
  return map;
}




async function migrateCrdBuyWork(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    const perMap = await buildMap(pg, "PerData", "perId", tenantId, branchId);
    const userMap = await buildMap(pg, "User", "userId", tenantId, branchId);
    const workTypeMap = await buildMap(pg, "CrdBuysWorkType", "workTypeId", tenantId, branchId);
    const workStatMap = await buildMap(pg, "CrdBuysWorkStat", "workStatId", tenantId, branchId);
    const workSupplyMap = await buildMap(pg, "CrdBuysWorkSupply", "workSupplyId", tenantId, branchId);
    const labMap = await buildMap(pg, "CrdBuysWorkLab", "labId", tenantId, branchId);
    const sapakMap = await buildMap(pg, "CrdBuysWorkSapak", "sapakId", tenantId, branchId);
    const frameSapakMap = sapakMap; 
    const labelMap = await buildMap(pg, "CrdBuysWorkLabel", "labelId", tenantId, branchId);
    const lnsSapakMap = await buildMap(pg, "Sapak", "SapakID", tenantId, branchId);
    const glassBrandMap = await buildMap(pg, "CrdGlassBrand", "glassBrandId", tenantId, branchId);
    const clensMap = await buildMap(pg, "CrdClensManuf", "clensManufId", tenantId, branchId);
    const itemMap = await buildMap(pg, "Item", "itemId", tenantId, branchId);
    const tailMap = await buildMap(pg, "CrdGlassCheckGlassP", "glassPId", tenantId, branchId); 
    while (true) {
      const [rows] = await mysql.query(
        `SELECT * FROM tblCrdBuysWorks ORDER BY WorkId LIMIT ? OFFSET ?`,
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
          const legacyUserId = normalizeInt(row.UserId);
          const legacyWorkTypeId = normalizeInt(row.WorkTypeId);
          const legacyWorkStatId = normalizeInt(row.WorkStatId);
          const legacyWorkSupplyId = normalizeInt(row.WorkSupplyId);
          const legacyLabId = normalizeInt(row.LabId);
          const legacySapakId = normalizeInt(row.SapakId);
          const legacyFSapakId = normalizeInt(row.FSapakId);
          const legacyFLabelId = normalizeInt(row.FLabelId);
          const legacyLnsSapakId = normalizeInt(row.LnsSapakId);
          const legacyGlassSapakId = normalizeInt(row.GlassSapakId);
          const legacyClensSapakId = normalizeInt(row.ClensSapakId);
          const legacyItemId = normalizeInt(row.ItemId);
          const legacyTailId = normalizeInt(row.TailId);

          const rowValues = [
            createId(),
            tenantId,
            branchId,
            normalizeInt(row.WorkId),
            row.WorkDate ? new Date(row.WorkDate) : null,
            legacyPerId,
            perMap.get(legacyPerId) || null,
            legacyUserId,
            userMap.get(legacyUserId) || null,
            legacyWorkTypeId,
            workTypeMap.get(legacyWorkTypeId) || null,
            row.CheckDate ? new Date(row.CheckDate) : null,
            legacyWorkStatId,
            workStatMap.get(legacyWorkStatId) || null,
            legacyWorkSupplyId,
            workSupplyMap.get(legacyWorkSupplyId) || null,
            legacyLabId,
            labMap.get(legacyLabId) || null,
            legacySapakId,
            sapakMap.get(legacySapakId) || null,
            cleanText(row.BagNum),
            row.PromiseDate ? new Date(row.PromiseDate) : null,
            row.DeliverDate ? new Date(row.DeliverDate) : null,
            cleanText(row.Comment),
            legacyFSapakId,
            frameSapakMap.get(legacyFSapakId) || null,
            legacyFLabelId,
            labelMap.get(legacyFLabelId) || null,
            cleanText(row.FModel),
            cleanText(row.FColor),
            cleanText(row.FSize),
            normalizeInt(row.FrameSold),
            legacyLnsSapakId,
            lnsSapakMap.get(legacyLnsSapakId) || null,
            legacyGlassSapakId,
            glassBrandMap.get(legacyGlassSapakId) || null,
            legacyClensSapakId,
            clensMap.get(legacyClensSapakId) || null,
            normalizeInt(row.GlassId),
            normalizeInt(row.WType),
            toBoolean(row.SMSSent),
            legacyItemId,
            itemMap.get(legacyItemId) || null,
            legacyTailId,
            tailMap.get(legacyTailId) || null,
            toBoolean(row.Canceled),
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
          await pg.query(
            `
            INSERT INTO "CrdBuyWork"
            (${COLUMNS.map(c => `"${c}"`).join(",")})
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId","branchId","workId")
            DO UPDATE SET
              ${COLUMNS
                .filter(c =>
                  ![
                    "id", "tenantId", "branchId", "workId",
                    "createdAt", "updatedAt"
                  ].includes(c)
                )
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

  console.log("CrdBuyWork migration completed:", total);
}

module.exports = migrateCrdBuyWork;
