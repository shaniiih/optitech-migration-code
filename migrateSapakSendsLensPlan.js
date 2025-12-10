const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function normalizeInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  if (typeof value === "bigint") return Number(value);
  if (Buffer.isBuffer(value)) return normalizeInt(value.toString("utf8"));
  const t = String(value).trim();
  if (!t) return null;
  const parsed = Number(t);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function cleanNumber(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? value : null;
  if (typeof value === "bigint") return Number(value);
  if (Buffer.isBuffer(value)) return cleanNumber(value.toString("utf8"));
  const t = String(value).trim();
  if (!t) return null;
  const parsed = Number(t);
  return Number.isFinite(parsed) ? parsed : null;
}

function toBoolean(v) {
  if (v == null) return null;
  if (typeof v === "boolean") return v;
  if (typeof v === "number") return v !== 0;
  const t = String(v).trim().toLowerCase();
  if (!t) return null;
  if (["1","true","yes","y","t"].includes(t)) return true;
  if (["0","false","no","n","f"].includes(t)) return false;
  return null;
}

async function buildSapakSendMap(pg, tenantId, branchId) {
  const map = new Map();
  const sql = `
    SELECT id, "sapakSendId"
    FROM "SapakSend"
    WHERE "tenantId" = $1 AND "branchId" = $2
  `;
  const { rows } = await pg.query(sql, [tenantId, branchId]).catch(() => ({ rows: [] }));

  for (const r of rows) {
    const legacy = normalizeInt(r.sapakSendId);
    if (legacy !== null) map.set(legacy, r.id);
  }
  return map;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const t = String(value).trim();
  return t.length ? t : null;
}

async function migrateSapakSendsLensPlan(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    const sapakSendMap = await buildSapakSendMap(pg, tenantId, branchId);

    while (true) {
      const [rows] = await mysql.query(
        `SELECT * FROM tblSapakSendsLensPlan ORDER BY SapakSendId LIMIT ? OFFSET ?`,
        [WINDOW_SIZE, offset]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();

        const values = [];
        const params = [];

        for (const r of chunk) {
          const legacySapakSendId = normalizeInt(r.SapakSendId);
          const sapakSendId = sapakSendMap.get(legacySapakSendId) || null;
          const base = params.length;

          values.push(
            `(
              $${base + 1}, $${base + 2}, $${base + 3},
              $${base + 4}, $${base + 5}, $${base + 6},
              $${base + 7}, $${base + 8}, $${base + 9},
              $${base + 10}, $${base + 11}, $${base + 12},
              $${base + 13}, $${base + 14}, $${base + 15},
              $${base + 16}, $${base + 17}, $${base + 18},
              $${base + 19}, $${base + 20}, $${base + 21},
              $${base + 22}, $${base + 23}, $${base + 24},
              $${base + 25}, $${base + 26}
            )`
          );

          params.push(
            createId(),
            tenantId,
            branchId,
            legacySapakSendId,
            sapakSendId,
            toBoolean(r.TreatBlock),
            toBoolean(r.TreatWSec),
            toBoolean(r.TreatWScrew),
            toBoolean(r.TreatWNylon),
            toBoolean(r.TreatWKnife),
            r.LensColor ? cleanText(r.LensColor).trim() : null,
            r.LensLevel ? cleanText(r.LensLevel).trim() : null,
            cleanNumber(r.EyeWidth),
            cleanNumber(r.EyeHeight),
            cleanNumber(r.BridgeWidth),
            cleanNumber(r.CenterHeightR),
            cleanNumber(r.CenterHeightL),
            cleanNumber(r.SegHeightR),
            cleanNumber(r.SegHeightL),
            r.PicNum ? cleanText(r.PicNum).trim() : null,
            r.PCom ? cleanText(r.PCom).trim() : null,
            cleanNumber(r.Basis),
            cleanNumber(r.Pent),
            cleanNumber(r.VD),
            now,
            now
          );
        }

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "SapakSendsLensPlan" (
              id, "tenantId", "branchId",
              "legacySapakSendId", "sapakSendId",
              "treatBlock", "treatWSec", "treatWScrew",
              "treatWNylon", "treatWKnife",
              "lensColor", "lensLevel",
              "eyeWidth", "eyeHeight", "bridgeWidth",
              "centerHeightR", "centerHeightL",
              "segHeightR", "segHeightL",
              "picNum", "pCom",
              basis, pent, vd,
              "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "legacySapakSendId")
            DO UPDATE SET
              "sapakSendId" = EXCLUDED."sapakSendId",
              "treatBlock" = EXCLUDED."treatBlock",
              "treatWSec" = EXCLUDED."treatWSec",
              "treatWScrew" = EXCLUDED."treatWScrew",
              "treatWNylon" = EXCLUDED."treatWNylon",
              "treatWKnife" = EXCLUDED."treatWKnife",
              "lensColor" = EXCLUDED."lensColor",
              "lensLevel" = EXCLUDED."lensLevel",
              "eyeWidth" = EXCLUDED."eyeWidth",
              "eyeHeight" = EXCLUDED."eyeHeight",
              "bridgeWidth" = EXCLUDED."bridgeWidth",
              "centerHeightR" = EXCLUDED."centerHeightR",
              "centerHeightL" = EXCLUDED."centerHeightL",
              "segHeightR" = EXCLUDED."segHeightR",
              "segHeightL" = EXCLUDED."segHeightL",
              "picNum" = EXCLUDED."picNum",
              "pCom" = EXCLUDED."pCom",
              basis = EXCLUDED.basis,
              pent = EXCLUDED.pent,
              vd = EXCLUDED.vd,
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

  console.log("SapakSendsLensPlan migration completed:", total);
}

module.exports = migrateSapakSendsLensPlan;
