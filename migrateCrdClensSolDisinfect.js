const { createId } = require("@paralleldrive/cuid2");
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

async function migrateCrdClensSolDisinfect(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;
  let skippedInvalidId = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT ClensSolDisinfectId, ClensSolDisinfectName
           FROM tblCrdClensSolDisinfect
          WHERE ClensSolDisinfectId > ?
          ORDER BY ClensSolDisinfectId
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
          const clensSolDisinfectId = asInteger(row.ClensSolDisinfectId);
          if (clensSolDisinfectId === null) {
            skippedInvalidId += 1;
            continue;
          }

          const name =
            cleanText(row.ClensSolDisinfectName) ||
            `Clens Sol Disinfect ${clensSolDisinfectId}`;

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7})`
          );
          params.push(
            createId(),         // id
            tenantId,           // tenantId
            branchId,           // branchId
            clensSolDisinfectId,// clensSolDisinfectId
            name,               // clensSolDisinfectName
            timestamp,          // createdAt
            timestamp           // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "CrdClensSolDisinfect" (
               id,
               "tenantId",
               "branchId",
               "clensSolDisinfectId",
               "clensSolDisinfectName",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "clensSolDisinfectId") DO UPDATE SET
               "clensSolDisinfectName" = EXCLUDED."clensSolDisinfectName",
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

      const latestId = asInteger(rows[rows.length - 1]?.ClensSolDisinfectId);
      if (latestId !== null) {
        lastId = latestId;
      }
      console.log(`CrdClensSolDisinfect migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ CrdClensSolDisinfect migration completed. Total rows processed: ${total}`);
    if (skippedInvalidId) {
      console.warn(
        `⚠️ CrdClensSolDisinfect: skipped ${skippedInvalidId} records due to invalid ClensSolDisinfectId`
      );
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCrdClensSolDisinfect;
