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

async function migrateCrdClensChecksPr(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;
  let skippedInvalidId = 0;

  try {

    while (true) {
      const [rows] = await mysql.query(
        `SELECT PrId, PrName
           FROM tblCrdClensChecksPr
          WHERE PrId > ?
          ORDER BY PrId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();
        const seenPrIds = new Set(); // avoid duplicates in same statement
        let processedInChunk = 0;

        for (const row of chunk) {
          const prId = asInteger(row.PrId);
          if (prId === null) {
            skippedInvalidId += 1;
            continue;
          }
          if (seenPrIds.has(prId)) continue;
          seenPrIds.add(prId);

          const prName = cleanText(row.PrName) || `Crd Clens Checks Pr ${prId}`;
          const offset = params.length;

          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8})`
          );

          params.push(
            uuidv4(),     // id
            tenantId,     // tenantId
            branchId,     // branchId
            prId,         // prId
            prName,       // prName
            null,         // idCount
            timestamp,    // createdAt
            timestamp     // updatedAt
          );

          processedInChunk += 1;
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "CrdClensChecksPr" (
              id,
              "tenantId",
              "branchId",
              "prId",
              "prName",
              "idCount",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "prId")
            DO UPDATE SET
              "prName" = EXCLUDED."prName",
              "idCount" = COALESCE(EXCLUDED."idCount", "CrdClensChecksPr"."idCount"),
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
          total += processedInChunk;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      const latestId = asInteger(rows[rows.length - 1]?.PrId);
      if (latestId !== null) {
        lastId = latestId;
      }
      console.log(`CrdClensChecksPr migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ CrdClensChecksPr migration completed. Total rows processed: ${total}`);
    if (skippedInvalidId) {
      console.warn(`⚠️ Skipped ${skippedInvalidId} rows due to invalid PrId.`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCrdClensChecksPr;
