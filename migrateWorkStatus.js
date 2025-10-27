const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  if (typeof value === "bigint") {
    return Number(value);
  }
  if (Buffer.isBuffer(value)) {
    return asInteger(value.toString("utf8"));
  }
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

async function migrateWorkStatus(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastStatusId = -1;
  let total = 0;
  let skippedInvalidId = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT WorkStatId, WorkStatName
           FROM tblCrdBuysWorkStats
          WHERE WorkStatId > ?
          ORDER BY WorkStatId
          LIMIT ${WINDOW_SIZE}`,
        [lastStatusId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();

        for (const row of chunk) {
          const statusId = asInteger(row.WorkStatId);
          if (statusId === null) {
            skippedInvalidId += 1;
            continue;
          }

          const name = cleanText(row.WorkStatName) || `Work Status ${statusId}`;
          const recordId = `${tenantId}-work-status-${statusId}`;

          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8})`
          );
          params.push(
            recordId,
            tenantId,
            statusId,
            name,
            null,
            true,
            timestamp,
            timestamp
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "WorkStatus" (
              id,
              "tenantId",
              "statusId",
              name,
              description,
              "isActive",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("statusId")
            DO UPDATE SET
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
          total += values.length;
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }
      }

      const lastRow = rows[rows.length - 1];
      lastStatusId = asInteger(lastRow.WorkStatId) ?? lastStatusId;
      console.log(`WorkStatus migrated so far: ${total} (lastStatusId=${lastStatusId})`);
    }

    console.log(`✅ WorkStatus migration completed. Total inserted/updated: ${total}`);
    if (skippedInvalidId) {
      console.warn(`⚠️ Skipped ${skippedInvalidId} work statuses due to invalid WorkStatId.`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateWorkStatus;

