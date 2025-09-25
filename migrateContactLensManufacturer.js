const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  const str = String(value).trim();
  if (!str) return null;
  const num = Number(str);
  return Number.isFinite(num) ? Math.trunc(num) : null;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

async function migrateContactLensManufacturer(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let totalProcessed = 0;
  let skippedInvalidManufacturerId = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT ClensManufId, ClensManufName
           FROM sqlCrdClensManuf
          WHERE ClensManufId > ?
          ORDER BY ClensManufId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) {
        break;
      }

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();
        let insertedInChunk = 0;

        for (const row of chunk) {
          const manufacturerId = asInteger(row.ClensManufId);
          if (manufacturerId === null) {
            skippedInvalidManufacturerId += 1;
            continue;
          }

          const name = cleanText(row.ClensManufName) || `Contact Lens Manufacturer ${manufacturerId}`;
          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8})`
          );
          params.push(
            uuidv4(),
            tenantId,
            manufacturerId,
            name,
            null,
            true,
            timestamp,
            timestamp
          );
          insertedInChunk += 1;
        }

        if (!values.length) {
          continue;
        }

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "ContactLensManufacturer" (
              id,
              "tenantId",
              "manufacturerId",
              name,
              description,
              "isActive",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("manufacturerId") DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              name = EXCLUDED.name,
              description = EXCLUDED.description,
              "isActive" = EXCLUDED."isActive",
              "updatedAt" = EXCLUDED."updatedAt"`,
            params
          );
          await pg.query("COMMIT");
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }

        totalProcessed += insertedInChunk;
      }

      lastId = asInteger(rows[rows.length - 1].ClensManufId) ?? lastId;
      console.log(`ContactLensManufacturer migrated so far: ${totalProcessed} (lastId=${lastId})`);
    }

    console.log(`✅ ContactLensManufacturer migration completed. Total rows processed: ${totalProcessed}`);
    if (skippedInvalidManufacturerId) {
      console.warn(`⚠️ Skipped ${skippedInvalidManufacturerId} rows due to invalid manufacturer id`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateContactLensManufacturer;
