const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function normalizeInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  if (typeof value === "bigint") return Number(value);
  if (Buffer.isBuffer(value)) return normalizeInt(value.toString("utf8"));
  const n = Number(String(value).trim());
  return Number.isFinite(n) ? Math.trunc(n) : null;
}

async function migrateSMSLen(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastPrefix = ""; // smallest string
  let lastLang = "";
  let total = 0;

  try {
    // Ensure unique index for upsert per tenant by (prefix, lang)
    await pg.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_indexes WHERE indexname = 'smslen_tenant_prefix_lang_ux'
        ) THEN
          CREATE UNIQUE INDEX smslen_tenant_prefix_lang_ux
          ON "SMSLen" ("tenantId", "sMSProviderPrefix", "sMSLang");
        END IF;
      END$$;
    `);

    // Window through the composite PK using tuple comparison
    /* MySQL supports row constructor comparisons: (a,b) > (?, ?) with ORDER BY a,b */
    // Loop until no rows returned
    while (true) {
      const [rows] = await mysql.query(
        `SELECT SMSProviderPrefix, SMSLang, SMSProviderName, SMSLen
           FROM tblSMSLens
          WHERE (SMSProviderPrefix, SMSLang) > (?, ?)
          ORDER BY SMSProviderPrefix, SMSLang
          LIMIT ${WINDOW_SIZE}`,
        [lastPrefix, lastLang]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        for (const row of chunk) {
          const prefix = cleanText(row.SMSProviderPrefix);
          const lang = cleanText(row.SMSLang);
          if (!prefix || !lang) continue; // both are part of PK; skip invalid

          const name = cleanText(row.SMSProviderName);
          const lenVal = normalizeInt(row.SMSLen);

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9})`
          );
          params.push(
            uuidv4(),
            tenantId,
            branchId,
            prefix,
            lang,
            name,
            lenVal,
            now,
            now
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "SMSLen" (
              id,
              "tenantId",
              "branchId",
              "sMSProviderPrefix",
              "sMSLang",
              "sMSProviderName",
              "sMSLen",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "sMSProviderPrefix", "sMSLang")
            DO UPDATE SET
              "branchId" = EXCLUDED."branchId",
              "sMSProviderName" = EXCLUDED."sMSProviderName",
              "sMSLen" = EXCLUDED."sMSLen",
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

      const last = rows[rows.length - 1];
      lastPrefix = last.SMSProviderPrefix || lastPrefix;
      lastLang = last.SMSLang || lastLang;
      console.log(`SMSLen migrated so far: ${total} (last=(${lastPrefix}, ${lastLang}))`);
    }

    console.log(`✅ SMSLen migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateSMSLen;
