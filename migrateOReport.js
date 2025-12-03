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

async function migrateOReport(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT ORepId, ORepHeader, ORepName, ORepType, ORPTPara, secLevel, InExe, ORepSql
           FROM tblOReports
          WHERE ORepId > ?
          ORDER BY ORepId
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
          const idVal = normalizeInt(r.ORepId);
          if (idVal === null) continue;

          const headerVal = cleanText(r.ORepHeader);
          const nameVal = cleanText(r.ORepName);
          const typeVal = normalizeInt(r.ORepType);
          const paraVal = cleanText(r.ORPTPara);
          const secLevelVal = normalizeInt(r.secLevel);
          const inExeVal =
            r.InExe === null || r.InExe === undefined
              ? null
              : Boolean(r.InExe);
          const sqlVal = cleanText(r.ORepSql);

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9}, $${base + 10}, $${base + 11}, $${base + 12}, $${base + 13})`
          );
          params.push(
            createId(),    // id
            tenantId,    // tenantId
            branchId,    // branchId
            idVal,       // oRepId
            headerVal,   // oRepHeader
            nameVal,     // oRepName
            typeVal,     // oRepType
            paraVal,     // oRPTPara
            secLevelVal, // secLevel
            inExeVal,    // InExe
            sqlVal,      // ORepSql
            now,         // createdAt
            now          // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "OReport" (
               id,
               "tenantId",
               "branchId",
               "oRepId",
               "oRepHeader",
               "oRepName",
               "oRepType",
               "oRPTPara",
               "secLevel",
               "InExe",
               "ORepSql",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "oRepId") DO UPDATE SET
               "oRepHeader" = EXCLUDED."oRepHeader",
               "oRepName" = EXCLUDED."oRepName",
               "oRepType" = EXCLUDED."oRepType",
               "oRPTPara" = EXCLUDED."oRPTPara",
               "secLevel" = EXCLUDED."secLevel",
               "InExe" = EXCLUDED."InExe",
               "ORepSql" = EXCLUDED."ORepSql",
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

      const maxId = normalizeInt(rows[rows.length - 1].ORepId);
      if (maxId !== null && maxId > lastId) {
        lastId = maxId;
      }
      console.log(`OReport migrated so far: ${total} (lastORepId=${lastId})`);
    }

    console.log(`✅ OReport migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateOReport;
