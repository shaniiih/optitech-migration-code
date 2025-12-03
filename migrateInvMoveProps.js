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

async function migrateInvMoveProps(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;
  let skippedInvalidId = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT InvMovePropId, InvMovePropName
           FROM tblInvMoveProps
          WHERE InvMovePropId > ?
          ORDER BY InvMovePropId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();
        const seenIds = new Set(); // avoid duplicates within one statement

        for (const row of chunk) {
          const propId = asInteger(row.InvMovePropId);
          if (propId === null) {
            skippedInvalidId += 1;
            continue;
          }
          if (seenIds.has(propId)) continue;
          seenIds.add(propId);

          const name = cleanText(row.InvMovePropName) || `Inv Move Prop ${propId}`;
          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7})`
          );
          params.push(
            createId(),  // id
            tenantId,  // tenantId
            branchId,  // branchId
            propId,    // InvMovePropId
            name,      // InvMovePropName
            timestamp, // createdAt
            timestamp  // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "InvMoveProp" (
               id,
               "tenantId",
               "branchId",
               "InvMovePropId",
               "InvMovePropName",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "InvMovePropId") DO UPDATE SET
               "InvMovePropName" = EXCLUDED."InvMovePropName",
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

      const latestId = asInteger(rows[rows.length - 1]?.InvMovePropId);
      if (latestId !== null) {
        lastId = latestId;
      }
      console.log(`InvMoveProps migrated so far: ${total} (lastInvMovePropId=${lastId})`);
    }

    console.log(`✅ InvMoveProps migration completed. Total rows processed: ${total}`);
    if (skippedInvalidId) {
      console.warn(`⚠️ InvMoveProps: skipped ${skippedInvalidId} records due to invalid InvMovePropId`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateInvMoveProps;
