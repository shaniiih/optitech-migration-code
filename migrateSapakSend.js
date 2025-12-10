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

function toBoolean(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "boolean") return value;
  if (typeof value === "number") return Number.isFinite(value) ? value !== 0 : null;
  const v = String(value).trim().toLowerCase();
  if (!v) return null;
  if (["1", "true", "t", "yes", "y"].includes(v)) return true;
  if (["0", "false", "f", "no", "n"].includes(v)) return false;
  return null;
}

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 500;

const COLUMNS = [
  "id", "tenantId", "branchId",
  "sapakSendId",
  "legacyPerId", "perId",
  "legacyGlassPId", "glassPId",
  "legacyWorkId", "workId",
  "legacyClensId", "clensId",
  "legacySapakDestId", "sapakDestId",
  "legacyUserId", "userId",
  "sendTime", "received", "privPrice", "shipmentId", "shipmentDate",
  "sent", "com",
  "legacySpsStatId", "spsStatId",
  "spsType", "spsSendType",
  "legacyFaxId", "faxId",
  "shFrame", "shLab",
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

async function migrateSapakSend(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    const perMap = await buildMap(pg, "PerData", "perId", tenantId, branchId);
    const glassPMap = await buildMap(pg, "CrdGlassCheckGlassP", "glassPId", tenantId, branchId);
    const workMap = await buildMap(pg, "CrdBuyWork", "workId", tenantId, branchId);
    const clensMap = await buildMap(pg, "CrdClensCheck", "clensId", tenantId, branchId);
    const sapakDestMap = await buildMap(pg, "SapakDest", "sapakDestId", tenantId, branchId);
    const userMap = await buildMap(pg, "User", "userId", tenantId, branchId);
    const spsStatMap = await buildMap(pg, "SapakSendStat", "spsStatId", tenantId, branchId);
    const faxMap = await buildMap(pg, "Fax", "faxId", tenantId, branchId); 
    while (true) {
      const [rows] = await mysql.query(
        `SELECT * FROM tblSapakSends ORDER BY SapakSendId LIMIT ? OFFSET ?`,
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
          const legacySapakSendId = normalizeInt(row.SapakSendId);
          const legacyPerId = normalizeInt(row.PerId);
          const legacyGlassPId = normalizeInt(row.GlassPId);
          const legacyWorkId = normalizeInt(row.WorkId);
          const legacyClensId = normalizeInt(row.ClensId);
          const legacySapakDestId = normalizeInt(row.SapakDestId);
          const legacyUserId = normalizeInt(row.UserId);
          const legacySpsStatId = normalizeInt(row.spsStatId);
          const legacyFaxId = normalizeInt(row.FaxId);
          const shFrame = toBoolean(row.ShFrame);
          const shLab = toBoolean(row.ShLab);

          const rowValues = [
            createId(),
            tenantId,
            branchId,
            legacySapakSendId,
            legacyPerId,
            perMap.get(legacyPerId) || null,
            legacyGlassPId,
            glassPMap.get(legacyGlassPId) || null,
            legacyWorkId,
            workMap.get(legacyWorkId) || null,
            legacyClensId,
            clensMap.get(legacyClensId) || null,
            legacySapakDestId,
            sapakDestMap.get(legacySapakDestId) || null,
            legacyUserId,
            userMap.get(legacyUserId) || null,
            row.SendTime ? new Date(row.SendTime) : null,
            toBoolean(row.Recived) ?? null,
            normalizeDecimal(row.PrivPrice),
            cleanText(row.ShipmentId),
            row.ShipmentDate ? new Date(row.ShipmentDate) : null,
            toBoolean(row.Sent) ?? null,
            cleanText(row.Com),
            legacySpsStatId,
            spsStatMap.get(legacySpsStatId) || null,
            normalizeInt(row.spsType),
            normalizeInt(row.spsSendType),
            legacyFaxId,
            faxMap.get(legacyFaxId) || null,
            shFrame,
            shLab,
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
            INSERT INTO "SapakSend"
              (${COLUMNS.map(c => `"${c}"`).join(",")})
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId","branchId","sapakSendId")
            DO UPDATE SET
              ${COLUMNS
                .filter(c =>
                  ![
                    "id", "tenantId", "branchId", "sapakSendId",
                    "createdAt", "updatedAt"
                  ].includes(c)
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

  console.log("SapakSend migration completed:", total);
}

module.exports = migrateSapakSend;
