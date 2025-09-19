const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function normalizeDate(value) {
  if (value === null || value === undefined) return null;

  if (typeof value === "string") {
    const trimmed = value.trim();
    if (!trimmed) return null;
    if (/^0{4}-0{2}-0{2}/.test(trimmed)) return null;
    const parsed = new Date(trimmed);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value;
  }

  if (typeof value === "number") {
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  return null;
}

async function migrateSMS(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
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
          const id = `${tenantId}-sms-${r.SMSId}`;
          const message = cleanText(r.SMSText) || "";
          const messageId = cleanText(r.SMSName);
          const smsLang = cleanText(r.SMSLang) || "UNKNOWN";
          const createdAt = normalizeDate(r.SMSDelDate) || new Date();

          const paramsBase = params.length;
          values.push(
            `($${paramsBase + 1}, $${paramsBase + 2}, $${paramsBase + 3}, $${paramsBase + 4}, $${paramsBase + 5},
               $${paramsBase + 6}, $${paramsBase + 7}, $${paramsBase + 8})`
          );

          params.push(
            id,
            tenantId,
            message,
            smsLang,
            "PENDING",
            messageId,
            createdAt,
            createdAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "SMS" (
              id, "tenantId", message, type, status, "messageId", "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              message = EXCLUDED.message,
              type = EXCLUDED.type,
              status = EXCLUDED.status,
              "messageId" = EXCLUDED."messageId",
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
