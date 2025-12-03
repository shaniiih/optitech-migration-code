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

async function migrateCrdBuysWorkLab(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastLabId = -1;
  let totalProcessed = 0;
  let skippedInvalidLabId = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT LabID, LabName
           FROM tblCrdBuysWorkLabs
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

        for (const row of chunk) {
          const labId = asInteger(row.LabID);
          if (labId === null) {
            skippedInvalidLabId += 1;
            continue;
          }

          const name = cleanText(row.LabName) || `Work Lab ${labId}`;
          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7})`
          );
          params.push(
            createId(),    // id
            tenantId,      // tenantId
            branchId,      // branchId
            labId,         // labId
            name,          // name
            timestamp,     // createdAt
            timestamp      // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "CrdBuysWorkLab" (
               id,
               "tenantId",
               "branchId",
               "labId",
               name,
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "labId") DO UPDATE SET
               name = EXCLUDED.name,
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
      lastLabId = asInteger(lastRow.LabID) ?? lastLabId;
      console.log(`CrdBuysWorkLab migrated so far: ${totalProcessed} (lastLabId=${lastLabId})`);
    }

    console.log(`✅ CrdBuysWorkLab migration completed. Total rows processed: ${totalProcessed}`);
    if (skippedInvalidLabId) {
      console.warn(`⚠️ CrdBuysWorkLab: skipped ${skippedInvalidLabId} records due to invalid LabID`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCrdBuysWorkLab;
