const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function normalizeInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  if (typeof value === "bigint") return Number(value);
  const n = Number(String(value).trim());
  return Number.isFinite(n) ? Math.trunc(n) : null;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const s = String(value).trim();
  return s.length ? s : null;
}

async function migrateUReport(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT URepId, URepSql, URepHeader, URepName, URepType, URPTPara, LoadedForm, FirstCtl, FirstIndex, SecCtl, SecIndex, ShortCutNum, secLevel, Trans
           FROM tblUReports
          WHERE URepId > ?
          ORDER BY URepId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();

        for (const r of chunk) {
          const uRepId = normalizeInt(r.URepId);
          if (uRepId === null) continue;

          const uRepSql = cleanText(r.URepSql);
          const uRepHeader = cleanText(r.URepHeader);
          const uRepName = cleanText(r.URepName);
          const uRepType =
            r.URepType === null || r.URepType === undefined ? null : Boolean(r.URepType);
          const uRPTPara = cleanText(r.URPTPara);
          const loadedForm = cleanText(r.LoadedForm);
          const firstCtl = cleanText(r.FirstCtl);
          const firstIndex = normalizeInt(r.FirstIndex);
          const secCtl = cleanText(r.SecCtl);
          const secIndex = normalizeInt(r.SecIndex);
          const shortCutNum = normalizeInt(r.ShortCutNum);
          const secLevel = normalizeInt(r.secLevel);
          const trans = cleanText(r.Trans);

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9}, $${base + 10}, $${base + 11}, $${base + 12}, $${base + 13}, $${base + 14}, $${base + 15}, $${base + 16}, $${base + 17}, $${base + 18}, $${base + 19})`
          );

          params.push(
            uuidv4(),
            tenantId,
            branchId,
            uRepId,
            uRepSql,
            uRepHeader,
            uRepName,
            uRepType,
            uRPTPara,
            loadedForm,
            firstCtl,
            firstIndex,
            secCtl,
            secIndex,
            shortCutNum,
            secLevel,
            trans,
            now,
            now
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "UReport" (
               id,
               "tenantId",
               "branchId",
               "uRepId",
               "uRepSql",
               "uRepHeader",
               "uRepName",
               "uRepType",
               "uRPTPara",
               "loadedForm",
               "firstCtl",
               "firstIndex",
               "secCtl",
               "secIndex",
               "shortCutNum",
               "secLevel",
               "trans",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "uRepId") DO UPDATE SET
               "uRepSql" = EXCLUDED."uRepSql",
               "uRepHeader" = EXCLUDED."uRepHeader",
               "uRepName" = EXCLUDED."uRepName",
               "uRepType" = EXCLUDED."uRepType",
               "uRPTPara" = EXCLUDED."uRPTPara",
               "loadedForm" = EXCLUDED."loadedForm",
               "firstCtl" = EXCLUDED."firstCtl",
               "firstIndex" = EXCLUDED."firstIndex",
               "secCtl" = EXCLUDED."secCtl",
               "secIndex" = EXCLUDED."secIndex",
               "shortCutNum" = EXCLUDED."shortCutNum",
               "secLevel" = EXCLUDED."secLevel",
               "trans" = EXCLUDED."trans",
               "updatedAt" = EXCLUDED."updatedAt"`,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      const maxId = normalizeInt(rows[rows.length - 1].URepId);
      if (maxId !== null && maxId > lastId) {
        lastId = maxId;
      }
      console.log(`UReport migrated so far: ${total} (lastURepId=${lastId})`);
    }

    console.log(`✅ UReport migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateUReport;

