const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

async function migrateCrdBuysWorkStat(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let totalProcessed = 0;
  let skippedInvalidId = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT WorkStatId, WorkStatName
           FROM tblCrdBuysWorkStats
          WHERE WorkStatId > ?
          ORDER BY WorkStatId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();

        for (const row of chunk) {
          const workStatId = asInteger(row.WorkStatId);
          if (workStatId === null) {
            skippedInvalidId += 1;
            continue;
          }

          const workStatName = cleanText(row.WorkStatName);

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7})`
          );
          params.push(
            uuidv4(),       // id
            tenantId,       // tenantId
            branchId,       // branchId
            workStatId,     // workStatId
            workStatName,   // workStatName
            timestamp,      // createdAt
            timestamp       // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "CrdBuysWorkStat" (
               id,
               "tenantId",
               "branchId",
               "workStatId",
               "workStatName",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "workStatId") DO UPDATE SET
               "workStatName" = EXCLUDED."workStatName",
               "updatedAt" = EXCLUDED."updatedAt"`,
            params
          );
          await pg.query("COMMIT");
          totalProcessed += values.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      const lastRow = rows[rows.length - 1];
      lastId = asInteger(lastRow.WorkStatId) ?? lastId;
      console.log(`CrdBuysWorkStat migrated so far: ${totalProcessed} (lastWorkStatId=${lastId})`);
    }

    console.log(`✅ CrdBuysWorkStat migration completed. Total rows processed: ${totalProcessed}`);
    if (skippedInvalidId) {
      console.warn(`⚠️ CrdBuysWorkStat: skipped ${skippedInvalidId} records due to invalid WorkStatId`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCrdBuysWorkStat;

