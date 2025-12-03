const { createId } = require("@paralleldrive/cuid2");
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

async function migrateLnsChar(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT LensCharId, LensCharName, Fav
           FROM tblLnsChars
          WHERE LensCharId > ?
          ORDER BY LensCharId
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
          const idVal = normalizeInt(r.LensCharId);
          if (idVal === null) {
            continue;
          }

          const nameVal = cleanText(r.LensCharName);
          const favVal = r.Fav === null || r.Fav === undefined ? null : !!r.Fav;

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8})`
          );
          params.push(
            createId(),      // id
            tenantId,      // tenantId
            branchId,      // branchId
            idVal,         // lensCharId
            nameVal,       // lensCharName
            favVal,        // fav
            now,           // createdAt
            now            // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
          `INSERT INTO "LnsChar" (
               id,
               "tenantId",
               "branchId",
               "lensCharId",
               "lensCharName",
               fav,
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "lensCharId") DO UPDATE SET
               "lensCharName" = EXCLUDED."lensCharName",
               fav = EXCLUDED.fav,
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

      const maxId = normalizeInt(rows[rows.length - 1].LensCharId);
      if (maxId !== null && maxId > lastId) {
        lastId = maxId;
      }
      console.log(`LnsChar migrated so far: ${total} (lastLensCharId=${lastId})`);
    }

    console.log(`✅ LnsChar migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateLnsChar;

