const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");
const { ensureTenantId } = require("./tenantUtils");

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

async function migrateRef(tenantId, branchId) {
  tenantId = ensureTenantId(tenantId);

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT RefId, RefName
           FROM tblRefs
          WHERE RefId > ?
          ORDER BY RefId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();

        for (const r of chunk) {
          const refIdVal = normalizeInt(r.RefId);
          if (refIdVal === null) continue;

          const nameVal = cleanText(r.RefName);

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7})`
          );

          params.push(
            createId(),          // id
            tenantId,          // tenantId
            branchId || null,  // branchId
            refIdVal,          // refId
            nameVal,           // refName
            now,               // createdAt
            now                // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "Ref" (
               id,
               "tenantId",
               "branchId",
               "refId",
               "refName",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "refId") DO UPDATE SET
               "refName" = EXCLUDED."refName",
               "updatedAt" = EXCLUDED."updatedAt"`,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (e) {
          await pg.query("ROLLBACK");
          throw e;
        }
      }

      const maxId = normalizeInt(rows[rows.length - 1].RefId);
      if (maxId !== null && maxId > lastId) {
        lastId = maxId;
      }
      console.log(`Ref migrated so far: ${total} (lastRefId=${lastId})`);
    }

    console.log(`✅ Ref migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateRef;

