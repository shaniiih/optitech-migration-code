const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  return String(value).trim();
}

function normalizeInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  if (typeof value === "bigint") return Number(value);
  const n = Number(String(value).trim());
  return Number.isFinite(n) ? Math.trunc(n) : null;
}

async function migrateZipcodeStreet(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT CityCode, StreetCode, StreetName, AlternateStreetName
           FROM tblZipcodeStreets
          ORDER BY CityCode, StreetCode, StreetName, AlternateStreetName
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
          const streetName = cleanText(r.StreetName);
          const alternateStreetName = cleanText(r.AlternateStreetName);

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9})`
          );

          params.push(
            createId(),          // id
            tenantId,          // tenantId
            branchId,          // branchId
            cityCode,          // cityCode (legacy backup)
            streetCode,        // streetCode
            streetName,        // streetName
            alternateStreetName, // alternateStreetName
            now,               // createdAt
            now                // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "ZipcodeStreet" (
               id,
               "tenantId",
               "branchId",
               "cityCode",
               "streetCode",
               "streetName",
               "alternateStreetName",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "streetCode", "streetName", "alternateStreetName") DO UPDATE SET
               "cityCode" = EXCLUDED."cityCode",
               "streetName" = EXCLUDED."streetName",
               "alternateStreetName" = EXCLUDED."alternateStreetName",
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
      console.log(`ZipcodeStreet migrated so far: ${total} (offset=${offset})`);
    }

    console.log(`✅ ZipcodeStreet migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateZipcodeStreet;
