const { createId } = require("@paralleldrive/cuid2");
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

async function migrateSMS(tenantId = "tenant_1", branchId) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  // Start from -1 so IDs that begin at 0 are included
  let lastId = -1;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT SMSId, SMSName, SMSText, SMSLang, SMSDelDate
           FROM tblSMS
          WHERE SMSId > ?
          ORDER BY SMSId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const r of chunk) {
          const sMSId = normalizeInt(r.SMSId);
          const sMSName = cleanText(r.SMSName);
          const sMSText = cleanText(r.SMSText);
          const sMSLang = cleanText(r.SMSLang);
          const sMSDelDate = cleanText(r.SMSDelDate);
          const timestamp = new Date();
          const message = "";
          const phone = "";
          const type = "GENERAL";
          const status = "SENT";

          const paramsBase = params.length;
          values.push(
            `($${paramsBase + 1}, $${paramsBase + 2}, $${paramsBase + 3}, $${paramsBase + 4}, $${paramsBase + 5}, $${paramsBase + 6}, $${paramsBase + 7}, $${paramsBase + 8}, $${paramsBase + 9}, $${paramsBase + 10}, $${paramsBase + 11}, $${paramsBase + 12}, $${paramsBase + 13}, $${paramsBase + 14})`
          );

          params.push(
            createId(),
            tenantId,
            branchId || null,
            message,
            type,
            status,
            phone,
            sMSId,
            sMSName,
            sMSText,
            sMSLang,
            sMSDelDate,
            timestamp,
            timestamp
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "SMS" (
              id,
              "tenantId",
              "branchId",
              message,
              type,
              status,
              phone,
              "sMSId",
              "sMSName",
              "sMSText",
              "sMSLang",
              "sMSDelDate",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "sMSId")
            DO UPDATE SET
              message = EXCLUDED.message,
              type = EXCLUDED.type,
              status = EXCLUDED.status,
              phone = EXCLUDED.phone,
              "sMSName" = EXCLUDED."sMSName",
              "sMSText" = EXCLUDED."sMSText",
              "sMSLang" = EXCLUDED."sMSLang",
              "sMSDelDate" = EXCLUDED."sMSDelDate",
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }

        total += chunk.length;
      }

      lastId = rows[rows.length - 1].SMSId;
      console.log(`SMS migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ SMS migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateSMS;
