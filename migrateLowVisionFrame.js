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

async function migrateLowVisionFrame(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastFrameId = -1;
  let totalProcessed = 0;
  let skippedInvalidFrameId = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT LVFrameId, LVFrameName
           FROM tblCrdLVFrame
          WHERE LVFrameId > ?
          ORDER BY LVFrameId
          LIMIT ${WINDOW_SIZE}`,
        [lastFrameId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();
        let insertedInChunk = 0;

        for (const row of chunk) {
          const frameId = asInteger(row.LVFrameId);
          if (frameId === null) {
            skippedInvalidFrameId += 1;
            continue;
          }

          const name = cleanText(row.LVFrameName) || `Low Vision Frame ${frameId}`;
          const description = null;
          const recordId = `${tenantId}-lowvision-frame-${frameId}`;

          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8})`
          );
          params.push(
            recordId,
            tenantId,
            frameId,
            name,
            description,
            true,
            timestamp,
            timestamp
          );
          insertedInChunk += 1;
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "LowVisionFrame" (
              id,
              "tenantId",
              "frameId",
              name,
              description,
              "isActive",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("frameId") DO UPDATE SET
              id = EXCLUDED.id,
              "tenantId" = EXCLUDED."tenantId",
              name = EXCLUDED.name,
              description = EXCLUDED.description,
              "isActive" = EXCLUDED."isActive",
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
          totalProcessed += insertedInChunk;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      const lastRow = rows[rows.length - 1];
      lastFrameId = asInteger(lastRow.LVFrameId) ?? lastFrameId;
      console.log(`LowVisionFrame migrated so far: ${totalProcessed} (lastFrameId=${lastFrameId})`);
    }

    console.log(`✅ LowVisionFrame migration completed. Total rows processed: ${totalProcessed}`);
    if (skippedInvalidFrameId) {
      console.warn(`⚠️ Skipped ${skippedInvalidFrameId} records due to invalid frame id`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateLowVisionFrame;
