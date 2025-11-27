const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function normalizeInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  if (typeof value === "bigint") return Number(value);
  const n = Number(String(value).trim());
  return Number.isFinite(n) ? Math.trunc(n) : null;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  return String(value).trim();
}

async function migrateZipcodeStreetsZipcode(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT CityCode, StreetCode, StartingHouseNumber, EndingHouseNumber, StreetZipcode
           FROM tblZipcodeStreetsZipcode
          ORDER BY CityCode, StreetCode, StartingHouseNumber, EndingHouseNumber
          LIMIT ${WINDOW_SIZE} OFFSET ${offset}`
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        for (const r of chunk) {
          const cityCode = normalizeInt(r.CityCode);
          const streetCode = cleanText(r.StreetCode);
          const startingHouseNumber = normalizeInt(r.StartingHouseNumber);
          const endingHouseNumber = normalizeInt(r.EndingHouseNumber);
          const streetZipcode = normalizeInt(r.StreetZipcode);

          if (streetCode === null || startingHouseNumber === null || endingHouseNumber === null) {
            continue;
          }

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9}, $${base + 10})`
          );

          params.push(
            uuidv4(),                         // id
            tenantId,                         // tenantId
            branchId,                         // branchId
            cityCode,                         // cityCode
            streetCode,                       // streetCode
            startingHouseNumber,              // startingHouseNumber
            endingHouseNumber,                // endingHouseNumber
            streetZipcode,                    // streetZipcode
            now,                              // createdAt
            now                               // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "ZipcodeStreetsZipcode" (
               id,
               "tenantId",
               "branchId",
               "cityCode",
               "streetCode",
               "startingHouseNumber",
               "endingHouseNumber",
               "streetZipcode",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "cityCode", "streetCode", "startingHouseNumber", "endingHouseNumber") DO UPDATE SET
               "streetZipcode" = EXCLUDED."streetZipcode",
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

      offset += rows.length;
      console.log(`ZipcodeStreetsZipcode migrated so far: ${total} (offset=${offset})`);
    }

    console.log(`✅ ZipcodeStreetsZipcode migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateZipcodeStreetsZipcode;

