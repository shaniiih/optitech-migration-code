const { v4: uuidv4 } = require("uuid");
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

async function migrateRefsSub1(tenantId, branchId) {
  tenantId = ensureTenantId(tenantId);

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  // Build a map from legacy RefId (int) to new Ref primary key (string),
  // filtered by tenant AND branch for performance and correctness.
  const refIdToPk = new Map();
  try {
    const refRows = await pg.query(
      `SELECT "refId", id
         FROM "Ref"
        WHERE "tenantId" = $1
          AND "branchId" = $2`,
      [tenantId, branchId]
    );
    for (const row of refRows.rows) {
      if (row.refId !== null && row.refId !== undefined) {
        refIdToPk.set(Number(row.refId), row.id);
      }
    }
  } catch (e) {
    console.error("Failed to preload Ref mapping for RefsSub1:", e);
  }

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT RefsSub1Id, RefsSub1Name, RefId
           FROM tblRefsSub1
          WHERE RefsSub1Id > ?
          ORDER BY RefsSub1Id
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
          const refsSub1IdVal = normalizeInt(r.RefsSub1Id);
          if (refsSub1IdVal === null) continue;

          const nameVal = cleanText(r.RefsSub1Name);
          const legacyRefId = normalizeInt(r.RefId);
          if (legacyRefId === null) {
            throw new Error(
              `RefsSub1 migration error: missing or invalid RefId for RefsSub1Id=${refsSub1IdVal}`
            );
          }
          const refPk = refIdToPk.get(legacyRefId);
          if (!refPk) {
            throw new Error(
              `RefsSub1 migration error: could not resolve Ref PK for tenant=${tenantId}, branch=${branchId}, RefId=${legacyRefId}`
            );
          }

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8})`
          );

          params.push(
            uuidv4(),           // id
            tenantId,           // tenantId
            branchId || null,   // branchId
            refsSub1IdVal,      // refsSub1Id
            nameVal,            // refsSub1Name
            refPk,              // refId (FK to Ref.id) - required
            now,                // createdAt
            now                 // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "RefsSub1" (
               id,
               "tenantId",
               "branchId",
               "refsSub1Id",
               "refsSub1Name",
               "refId",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "refsSub1Id") DO UPDATE SET
               "refsSub1Name" = EXCLUDED."refsSub1Name",
               "refId" = EXCLUDED."refId",
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

      const maxId = normalizeInt(rows[rows.length - 1].RefsSub1Id);
      if (maxId !== null && maxId > lastId) {
        lastId = maxId;
      }
      console.log(`RefsSub1 migrated so far: ${total} (lastRefsSub1Id=${lastId})`);
    }

    console.log(`✅ RefsSub1 migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateRefsSub1;
