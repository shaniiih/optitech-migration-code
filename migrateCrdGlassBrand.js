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

async function migrateCrdGlassBrand(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;
  let skippedInvalidId = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT GlassBrandId, GlassBrandName
           FROM tblCrdGlassBrand
          WHERE GlassBrandId > ?
          ORDER BY GlassBrandId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();
        const seenIds = new Set();

        for (const row of chunk) {
          const glassBrandId = asInteger(row.GlassBrandId);
          if (glassBrandId === null) {
            skippedInvalidId += 1;
            continue;
          }
          if (seenIds.has(glassBrandId)) continue;
          seenIds.add(glassBrandId);

          const name = cleanText(row.GlassBrandName) || `Glass Brand ${glassBrandId}`;
          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7})`
          );
          params.push(
            uuidv4(),     // id
            tenantId,     // tenantId
            branchId,     // branchId
            glassBrandId, // glassBrandId
            name,         // name
            timestamp,    // createdAt
            timestamp     // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "CrdGlassBrand" (
               id,
               "tenantId",
               "branchId",
               "glassBrandId",
               "name",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "glassBrandId") DO UPDATE SET
               "name" = EXCLUDED."name",
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

      const latestId = asInteger(rows[rows.length - 1]?.GlassBrandId);
      if (latestId !== null) {
        lastId = latestId;
      }
      console.log(`CrdGlassBrand migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ CrdGlassBrand migration completed. Total rows processed: ${total}`);
    if (skippedInvalidId) {
      console.warn(`⚠️ CrdGlassBrand: skipped ${skippedInvalidId} records due to invalid GlassBrandId`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCrdGlassBrand;

