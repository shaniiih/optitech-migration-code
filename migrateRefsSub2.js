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

async function migrateRefsSub2(tenantId, branchId) {
  tenantId = ensureTenantId(tenantId);

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  // Build a map from legacy RefsSub1Id (int) to new RefsSub1 primary key (string),
  // filtered by tenant AND branch for performance and correctness.
  const sub1IdToPk = new Map();
  try {
    const sub1Rows = await pg.query(
      `SELECT "refsSub1Id", id
         FROM "RefsSub1"
        WHERE "tenantId" = $1
          AND "branchId" = $2`,
      [tenantId, branchId]
    );
    for (const row of sub1Rows.rows) {
      if (row.refsSub1Id !== null && row.refsSub1Id !== undefined) {
        sub1IdToPk.set(Number(row.refsSub1Id), row.id);
      }
    }
  } catch (e) {
    console.error("Failed to preload RefsSub1 mapping for RefsSub2:", e);
  }

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT RefsSub2Id, RefsSub2Name, subRefId
           FROM tblRefsSub2
          WHERE RefsSub2Id > ?
          ORDER BY RefsSub2Id
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
          const refsSub2IdVal = normalizeInt(r.RefsSub2Id);
          if (refsSub2IdVal === null) continue;

          const nameVal = cleanText(r.RefsSub2Name);
          const legacySubRefId = normalizeInt(r.subRefId);
          let subRefPk = null;
          if (legacySubRefId !== null) {
            subRefPk = sub1IdToPk.get(legacySubRefId) || null;
            if (!subRefPk) {
              throw new Error(
                `RefsSub2 migration error: could not resolve RefsSub1 PK for tenant=${tenantId}, branch=${branchId}, RefsSub1Id=${legacySubRefId}`
              );
            }
          }

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8})`
          );

          params.push(
            uuidv4(),           // id
            tenantId,           // tenantId
            branchId || null,   // branchId
            refsSub2IdVal,      // refsSub2Id
            nameVal,            // refsSub2Name
            subRefPk,           // subRefId (FK to RefsSub1.id)
            now,                // createdAt
            now                 // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "RefsSub2" (
               id,
               "tenantId",
               "branchId",
               "refsSub2Id",
               "refsSub2Name",
               "subRefId",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "refsSub2Id") DO UPDATE SET
               "refsSub2Name" = EXCLUDED."refsSub2Name",
               "subRefId" = EXCLUDED."subRefId",
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

      const maxId = normalizeInt(rows[rows.length - 1].RefsSub2Id);
      if (maxId !== null && maxId > lastId) {
        lastId = maxId;
      }
      console.log(`RefsSub2 migrated so far: ${total} (lastRefsSub2Id=${lastId})`);
    }

    console.log(`✅ RefsSub2 migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateRefsSub2;
