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

async function migrateLnsTreatType(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT TreatId, TreatName
           FROM tblLnsTreatTypes
          WHERE TreatId > ?
          ORDER BY TreatId
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
          const idVal = normalizeInt(r.TreatId);
          if (idVal === null) continue;

          const nameVal = cleanText(r.TreatName);

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7})`
          );
          params.push(
            createId(),      // id
            tenantId,      // tenantId
            branchId,      // branchId
            idVal,         // treatId
            nameVal,       // treatName
            now,           // createdAt
            now            // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "LnsTreatType" (
               id,
               "tenantId",
               "branchId",
               "treatId",
               "treatName",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "treatId") DO UPDATE SET
               "treatName" = EXCLUDED."treatName",
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

      const maxId = normalizeInt(rows[rows.length - 1].TreatId);
      if (maxId !== null && maxId > lastId) {
        lastId = maxId;
      }
      console.log(`LnsTreatType migrated so far: ${total} (lastTreatId=${lastId})`);
    }

    console.log(`✅ LnsTreatType migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateLnsTreatType;

