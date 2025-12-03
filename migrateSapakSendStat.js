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

async function migrateSapakSendStat(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    const now = () => new Date();

    while (true) {
      const [rows] = await mysql.query(
        `SELECT spsStatId, spsStatName
           FROM tblSapakSendStats
          WHERE spsStatId > ?
          ORDER BY spsStatId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const r of chunk) {
          const spsStatId = normalizeInt(r.spsStatId);
          const spsStatName = cleanText(r.spsStatName);
          const timestamp = now();

          const paramBase = params.length;
          values.push(
            `($${paramBase + 1}, $${paramBase + 2}, $${paramBase + 3}, $${paramBase + 4}, $${paramBase + 5}, $${paramBase + 6}, $${paramBase + 7})`
          );

          params.push(
            createId(),
            tenantId,
            branchId,
            spsStatId,
            spsStatName,
            timestamp,
            timestamp
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "SapakSendStat" (
              id, "tenantId", "branchId", "spsStatId", "spsStatName", "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "spsStatId") DO UPDATE SET
              "spsStatName" = EXCLUDED."spsStatName",
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

      lastId = rows[rows.length - 1].spsStatId;
      console.log(`SapakSendStat migrated: ${total} (lastId=${lastId})`);

      if (rows.length < WINDOW_SIZE) {
        break;
      }
    }

    console.log(`✅ SapakSendStat migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateSapakSendStat;
