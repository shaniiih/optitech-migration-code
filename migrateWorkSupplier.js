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

function resolveItemCode(supplierId, idCount) {
  const idCountText = idCount === null || idCount === undefined ? null : cleanText(idCount);
  if (idCountText && idCountText !== "0") {
    return idCountText;
  }
  return `SUP-${supplierId}`;
}

async function migrateWorkSupplier(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastSupplierId = -1;
  let totalProcessed = 0;
  let skippedInvalidSupplierId = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT SapakID, SapakName, IdCount
           FROM sqlWorkSapak
          WHERE SapakID > ?
          ORDER BY SapakID
          LIMIT ${WINDOW_SIZE}`,
        [lastSupplierId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();
        let insertedInChunk = 0;

        for (const row of chunk) {
          const supplierId = asInteger(row.SapakID);
          if (supplierId === null) {
            skippedInvalidSupplierId += 1;
            continue;
          }

          const name = cleanText(row.SapakName) || `Work Supplier ${supplierId}`;
          const itemCode = resolveItemCode(supplierId, row.IdCount);
          const id = `${tenantId}-work-supplier-${supplierId}`;

          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8})`
          );
          params.push(
            id,
            tenantId,
            supplierId,
            name,
            itemCode,
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
            `
            INSERT INTO "WorkSupplier" (
              id,
              "tenantId",
              "supplierId",
              name,
              "itemCode",
              "isActive",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("supplierId")
            DO UPDATE SET
              id = EXCLUDED.id,
              "tenantId" = EXCLUDED."tenantId",
              name = EXCLUDED.name,
              "itemCode" = EXCLUDED."itemCode",
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
      lastSupplierId = asInteger(lastRow.SapakID) ?? lastSupplierId;
      console.log(`WorkSupplier migrated so far: ${totalProcessed} (lastSapakId=${lastSupplierId})`);
    }

    console.log(`✅ WorkSupplier migration completed. Total rows processed: ${totalProcessed}`);
    if (skippedInvalidSupplierId) {
      console.warn(`⚠️ Skipped ${skippedInvalidSupplierId} records due to invalid supplier id`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateWorkSupplier;
