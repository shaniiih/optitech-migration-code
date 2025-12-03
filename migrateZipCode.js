const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;  // rows fetched from MySQL per window
const BATCH_SIZE  = 1000;  // rows inserted per Postgres txn

async function migrateZipCode(/* keep compatibility with main.js */ _tenantId) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastZip = 0;  // resume cursor
  let total = 0;

  try {
    // Ensure idempotency: one row per unique zipCode
    await pg.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_indexes WHERE indexname = 'zipcode_zipcode_ux'
        ) THEN
          CREATE UNIQUE INDEX zipcode_zipcode_ux ON "ZipCode" ("zipCode");
        END IF;
      END$$;
    `);

    while (true) {
      const [rows] = await mysql.execute(
        `SELECT CityCode, CityName, CityDivided, CityZipCode
           FROM tblZipcodeCities
          WHERE CityZipCode > ?
          ORDER BY CityZipCode
          LIMIT ${WINDOW_SIZE}`,
        [lastZip]
      );
      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();

        // Deduplicate repeated zip codes inside the chunk so a single INSERT
        // does not attempt to upsert the same key twice (Postgres 21000).
        const uniqueByZip = new Map();
        for (const r of chunk) {
          const zip = r.CityZipCode === null || r.CityZipCode === undefined ? null : String(r.CityZipCode);
          if (!zip) continue;
          uniqueByZip.set(zip, r); // keep latest record encountered in this chunk
        }

        if (!uniqueByZip.size) {
          continue;
        }

        const values = [];
        const params = [];

        for (const r of uniqueByZip.values()) {
          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8})`
          );
          params.push(
            createId(),                          // id
            String(r.CityZipCode),             // "zipCode"
            r.CityName ?? null,                // city
            null,                              // cityHe (unknown in source; keep null)
            null,                              // street
            null,                              // streetHe
            String(r.CityCode ?? ""),          // region (using CityCode as region)
            now                                // createdAt / updated timestamp
          );
        }

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "ZipCode" (
              id, "zipCode", city, "cityHe", street, "streetHe", region, "createdAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("zipCode")
            DO UPDATE SET
              city = COALESCE(EXCLUDED.city, "ZipCode".city),
              "cityHe" = COALESCE(EXCLUDED."cityHe", "ZipCode"."cityHe"),
              street = COALESCE(EXCLUDED.street, "ZipCode".street),
              "streetHe" = COALESCE(EXCLUDED."streetHe", "ZipCode"."streetHe"),
              region = COALESCE(EXCLUDED.region, "ZipCode".region),
              "createdAt" = LEAST(EXCLUDED."createdAt", "ZipCode"."createdAt")
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (e) {
          await pg.query("ROLLBACK");
          throw e;
        }

        total += chunk.length;
      }

      lastZip = rows[rows.length - 1].CityZipCode;
      console.log(`ZipCodes migrated so far: ${total} (lastZip=${lastZip})`);
    }

    console.log(`✅ ZipCode migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateZipCode;
