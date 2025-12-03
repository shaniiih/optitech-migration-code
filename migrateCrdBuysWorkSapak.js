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

async function migrateCrdBuysWorkSapak(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastSapakId = -1;
  let totalProcessed = 0;
  let skippedInvalidId = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT SapakID, SapakName, ItemCode
           FROM tblCrdBuysWorkSapaks
          WHERE SapakID > ?
          ORDER BY SapakID
          LIMIT ${WINDOW_SIZE}`,
        [lastSapakId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();

        for (const row of chunk) {
          const sapakId = asInteger(row.SapakID);
          if (sapakId === null) {
            skippedInvalidId += 1;
            continue;
          }

          const sapakName = cleanText(row.SapakName);
          const itemCode = asInteger(row.ItemCode);

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8})`
          );
          params.push(
            createId(),    // id
            tenantId,      // tenantId
            branchId,      // branchId
            sapakId,       // sapakId
            sapakName,     // sapakName
            itemCode,      // itemCode
            timestamp,     // createdAt
            timestamp      // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "CrdBuysWorkSapak" (
               id,
               "tenantId",
               "branchId",
               "sapakId",
               "sapakName",
               "itemCode",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "sapakId") DO UPDATE SET
               "sapakName" = EXCLUDED."sapakName",
               "itemCode" = EXCLUDED."itemCode",
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
      lastSapakId = asInteger(lastRow.SapakID) ?? lastSapakId;
      console.log(`CrdBuysWorkSapak migrated so far: ${totalProcessed} (lastSapakId=${lastSapakId})`);
    }

    console.log(`✅ CrdBuysWorkSapak migration completed. Total rows processed: ${totalProcessed}`);
    if (skippedInvalidId) {
      console.warn(`⚠️ CrdBuysWorkSapak: skipped ${skippedInvalidId} records due to invalid SapakID`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCrdBuysWorkSapak;
