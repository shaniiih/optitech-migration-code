const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
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

async function migrateCrdLVCap(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;
  let skippedInvalidId = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT LVCapId, LVCapName
           FROM tblCrdLVCap
          WHERE LVCapId > ?
          ORDER BY LVCapId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();
        const seenIds = new Set(); // avoid duplicates per statement

        for (const row of chunk) {
          const capId = asInteger(row.LVCapId);
          if (capId === null) {
            skippedInvalidId += 1;
            continue;
          }
          if (seenIds.has(capId)) continue;
          seenIds.add(capId);

          const name = cleanText(row.LVCapName) || `Crd LV Cap ${capId}`;
          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7})`
          );
          params.push(
            uuidv4(),   // id
            tenantId,   // tenantId
            branchId,   // branchId
            capId,      // lVCapId
            name,       // lVCapName
            timestamp,  // createdAt
            timestamp   // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "CrdLVCap" (
               id,
               "tenantId",
               "branchId",
               "lVCapId",
               "lVCapName",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "lVCapId") DO UPDATE SET
               "lVCapName" = EXCLUDED."lVCapName",
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

      const latestId = asInteger(rows[rows.length - 1]?.LVCapId);
      if (latestId !== null) {
        lastId = latestId;
      }
      console.log(`CrdLVCap migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ CrdLVCap migration completed. Total rows processed: ${total}`);
    if (skippedInvalidId) {
      console.warn(`⚠️ CrdLVCap: skipped ${skippedInvalidId} records due to invalid LVCapId`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCrdLVCap;
