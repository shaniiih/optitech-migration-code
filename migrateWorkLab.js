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

function toIdCountText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

async function migrateWorkLab(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastLabId = -1;
  let totalProcessed = 0;
  let skippedInvalidLabId = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT LabID, LabName, IdCount
           FROM sqlWorkLab
          WHERE LabID > ?
          ORDER BY LabID
          LIMIT ${WINDOW_SIZE}`,
        [lastLabId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();
        let insertedInChunk = 0;

        for (const row of chunk) {
          const labId = asInteger(row.LabID);
          if (labId === null) {
            skippedInvalidLabId += 1;
            continue;
          }

          const name = cleanText(row.LabName) || `Work Lab ${labId}`;
          const description = null;
          const idCountText = toIdCountText(row.IdCount);
          const recordId = `${tenantId}-work-lab-${labId}`;

          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8}, $${offset + 9})`
          );
          params.push(
            recordId,
            tenantId,
            labId,
            name,
            description,
            idCountText,
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
            `INSERT INTO "WorkLab" (
              id,
              "tenantId",
              "labId",
              name,
              description,
              "IdCount",
              "isActive",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("labId") DO UPDATE SET
              id = EXCLUDED.id,
              "tenantId" = EXCLUDED."tenantId",
              name = EXCLUDED.name,
              description = COALESCE(EXCLUDED.description, "WorkLab".description),
              "IdCount" = EXCLUDED."IdCount",
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
      lastLabId = asInteger(lastRow.LabID) ?? lastLabId;
      console.log(`WorkLab migrated so far: ${totalProcessed} (lastLabId=${lastLabId})`);
    }

    console.log(`✅ WorkLab migration completed. Total rows processed: ${totalProcessed}`);
    if (skippedInvalidLabId) {
      console.warn(`⚠️ Skipped ${skippedInvalidLabId} records due to invalid lab id`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateWorkLab;
