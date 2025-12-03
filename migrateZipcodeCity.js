const { createId } = require("@paralleldrive/cuid2");
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
  const s = String(value).trim();
  return s.length ? s : null;
}

async function migrateZipcodeCity(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastCode = -1;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT CityCode, CityName, CityDivided, CityZipCode
           FROM tblZipcodeCities
          WHERE CityCode > ?
          ORDER BY CityCode
          LIMIT ${WINDOW_SIZE}`,
        [lastCode]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        for (const r of chunk) {
          const cityCode = normalizeInt(r.CityCode);
          if (cityCode === null) continue;

          const cityName = cleanText(r.CityName);
          const cityDivided =
            r.CityDivided === null || r.CityDivided === undefined
              ? null
              : Boolean(r.CityDivided);
          const cityZipCode = normalizeInt(r.CityZipCode);

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9})`
          );

          params.push(
            createId(),      // id
            tenantId,      // tenantId
            branchId,      // branchId
            cityCode,      // cityCode
            cityName,      // cityName
            cityDivided,   // cityDivided
            cityZipCode,   // cityZipCode
            now,           // createdAt
            now            // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "ZipcodeCity" (
               id,
               "tenantId",
               "branchId",
               "cityCode",
               "cityName",
               "cityDivided",
               "cityZipCode",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "cityCode") DO UPDATE SET
               "cityName" = EXCLUDED."cityName",
               "cityDivided" = EXCLUDED."cityDivided",
               "cityZipCode" = EXCLUDED."cityZipCode",
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

      const maxCode = normalizeInt(rows[rows.length - 1].CityCode);
      if (maxCode !== null && maxCode > lastCode) {
        lastCode = maxCode;
      }
      console.log(`ZipcodeCity migrated so far: ${total} (lastCityCode=${lastCode})`);
    }

    console.log(`✅ ZipcodeCity migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateZipcodeCity;

