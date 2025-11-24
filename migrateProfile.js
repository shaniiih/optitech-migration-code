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

async function migrateProfile(tenantId, branchId) {
  tenantId = ensureTenantId(tenantId);

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT ProfileId, ProfileName, ProfileSql, ProfileDesc
           FROM tblProfiles
          WHERE ProfileId > ?
          ORDER BY ProfileId
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
          const profileIdVal = normalizeInt(r.ProfileId);
          if (profileIdVal === null) continue;

          const nameVal = cleanText(r.ProfileName);
          const sqlVal = cleanText(r.ProfileSql);
          const descVal = cleanText(r.ProfileDesc);

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9})`
          );

          params.push(
            uuidv4(),          // id
            tenantId,          // tenantId
            branchId || null,  // branchId
            profileIdVal,      // profileId
            nameVal,           // profileName
            sqlVal,            // profileSql
            descVal,           // profileDesc
            now,               // createdAt
            now                // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "Profile" (
               id,
               "tenantId",
               "branchId",
               "profileId",
               "profileName",
               "profileSql",
               "profileDesc",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "profileId") DO UPDATE SET
               "profileName" = EXCLUDED."profileName",
               "profileSql" = EXCLUDED."profileSql",
               "profileDesc" = EXCLUDED."profileDesc",
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

      const maxId = normalizeInt(rows[rows.length - 1].ProfileId);
      if (maxId !== null && maxId > lastId) {
        lastId = maxId;
      }
      console.log(`Profile migrated so far: ${total} (lastProfileId=${lastId})`);
    }

    console.log(`✅ Profile migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateProfile;

