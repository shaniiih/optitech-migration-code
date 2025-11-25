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

function normalizeFloat(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? value : null;
  if (typeof value === "bigint") return Number(value);
  const n = Number(String(value).trim());
  return Number.isFinite(n) ? n : null;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const s = String(value).trim();
  return s.length ? s : null;
}

async function migrateBarCode(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT BarCodeId, BarCodeName, CatNum
           FROM tblBarCodes
          WHERE BarCodeId > ?
          ORDER BY BarCodeId
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
          const barCodeId = normalizeInt(r.BarCodeId);
          if (barCodeId === null) continue;

          const barCodeName = normalizeFloat(r.BarCodeName);
          const catNum = cleanText(r.CatNum);

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8})`
          );

          params.push(
            uuidv4(),     // id
            tenantId,     // tenantId
            branchId,     // branchId
            barCodeId,    // barCodeId
            barCodeName,  // barCodeName
            catNum,       // catNum
            now,          // createdAt
            now           // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "BarCode" (
               id,
               "tenantId",
               "branchId",
               "barCodeId",
               "barCodeName",
               "catNum",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "barCodeId") DO UPDATE SET
               "barCodeName" = EXCLUDED."barCodeName",
               "catNum" = EXCLUDED."catNum",
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

      const maxId = normalizeInt(rows[rows.length - 1].BarCodeId);
      if (maxId !== null && maxId > lastId) {
        lastId = maxId;
      }
      console.log(`BarCode migrated so far: ${total} (lastBarCodeId=${lastId})`);
    }

    console.log(`✅ BarCode migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateBarCode;

