const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");
const { ensureTenantId } = require("./tenantUtils");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

async function migrateUserSettings(tenantId, branchId) {
  tenantId = ensureTenantId(tenantId);

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.execute(
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

        for (const r of chunk) {
          const id = uuidv4();
          const now = new Date();

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10}, $${params.length + 11}, $${params.length + 12}, $${params.length + 13}, $${params.length + 14}, $${params.length + 15})`
          );

          params.push(
            id,                  // id
            tenantId,            // tenantId
            null,                // userId
            null,                // phone
            'he',                // preferredLanguage default
            'light',             // theme default
            true,                // emailNotifications
            true,                // smsNotifications
            now,                 // createdAt
            now,                 // updatedAt
            branchId || null,    // branchId (added column)
            String(r.ProfileId), // ProfileId (legacy id)
            r.ProfileName || null, // profileName
            r.ProfileSql || null,  // profileSql
            r.ProfileDesc || null  // profileDesc
          );

        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          const insertSql = `
            INSERT INTO "UserSettings" (
              id, "tenantId", "userId", phone, "preferredLanguage", theme,
              "emailNotifications", "smsNotifications", "createdAt", "updatedAt",
              "branchId", "ProfileId", "profileName", "profileSql", "profileDesc"
            ) VALUES ${values.join(",")}
            ON CONFLICT (id) DO UPDATE SET
              phone = EXCLUDED.phone,
              "preferredLanguage" = EXCLUDED."preferredLanguage",
              theme = EXCLUDED.theme,
              "emailNotifications" = EXCLUDED."emailNotifications",
              "smsNotifications" = EXCLUDED."smsNotifications",
              "updatedAt" = EXCLUDED."updatedAt",
              "branchId" = EXCLUDED."branchId",
              "ProfileId" = EXCLUDED."ProfileId",
              "profileName" = EXCLUDED."profileName",
              "profileSql" = EXCLUDED."profileSql",
              "profileDesc" = EXCLUDED."profileDesc";
          `;
          await pg.query(insertSql, params);


          await pg.query("COMMIT");
        } catch (e) {
          await pg.query("ROLLBACK");
          throw e;
        }

        total += chunk.length;
      }

      lastId = rows[rows.length - 1].ProfileId;
      console.log(`UserSettings (profiles) migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ UserSettings (profiles) migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateUserSettings;
