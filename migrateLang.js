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

async function migrateLang(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1; // last LangId processed
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT LangId, LangName
           FROM tblLangs
          WHERE LangId > ?
          ORDER BY LangId
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
          const langId = normalizeInt(r.LangId);
          const langName = cleanText(r.LangName);

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7})`
          );
          params.push(
            uuidv4(),  // id
            tenantId,  // tenantId
            branchId,  // branchId
            langId,    // langId
            langName,  // langName
            now,       // createdAt
            now        // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "Lang" (
               id, "tenantId", "branchId", "langId", "langName", "createdAt", "updatedAt"
             ) VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId" ,"langId") DO UPDATE SET
               "branchId" = EXCLUDED."branchId",
               "langName" = EXCLUDED."langName",
               "updatedAt" = EXCLUDED."updatedAt"`,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (e) {
          await pg.query("ROLLBACK");
          throw e;
        }
      }

      lastId = rows[rows.length - 1].LangId;
      console.log(`Lang migrated so far: ${total} (lastLangId=${lastId})`);
    }

    console.log(`✅ Lang migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateLang;

