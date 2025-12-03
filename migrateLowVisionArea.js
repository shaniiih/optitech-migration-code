const { createId } = require("@paralleldrive/cuid2");
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
  const trimmed = cleanText(value);
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

async function migrateLowVisionArea(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;
  let skippedInvalidId = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT LVAreaId, LVAreaName
           FROM tblCrdLVArea
          WHERE LVAreaId > ?
          ORDER BY LVAreaId
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
          const areaId = asInteger(row.LVAreaId);
          if (areaId === null) {
            skippedInvalidId += 1;
            continue;
          }

          const name = cleanText(row.LVAreaName) || `Low Vision Area ${areaId}`;

          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8})`
          );
          params.push(
            createId(),
            tenantId,
            areaId,
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
            INSERT INTO "LowVisionArea" (
              id,
              "tenantId",
              "areaId",
              name,
              description,
              "isActive",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("areaId")
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
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      const lastRow = rows[rows.length - 1];
      lastId = asInteger(lastRow.LVAreaId) ?? lastId;
      console.log(`LowVisionArea migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ LowVisionArea migration completed. Total inserted/updated: ${total}`);
    if (skippedInvalidId) {
      console.warn(`⚠️ Skipped ${skippedInvalidId} rows due to invalid LVAreaId.`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateLowVisionArea;
