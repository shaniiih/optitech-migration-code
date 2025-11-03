// migrateUser.js (batched/resumable/idempotent)
const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function asBool(value) {
  if (value === null || value === undefined) return false;
  if (Buffer.isBuffer(value)) return value.some((b) => b !== 0);
  return value === true || value === 1 || value === "1";
}

async function migrateUser(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  const branchIdValue =
    branchId !== undefined && branchId !== null ? String(branchId) : null;

  try {
    await pg.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_indexes WHERE indexname = 'user_tenant_email_ux'
        ) THEN
          CREATE UNIQUE INDEX user_tenant_email_ux
          ON "User" ("tenantId", email);
        END IF;
      END$$;
    `);

    while (true) {
      const [rows] = await mysql.query(
        `SELECT UserId, LastName, FirstName, HomePhone, CellPhone, Fax, Address, ZipCode,
                Diag, Emp, CityId, BirthDate, Salary, Pass, LevelId, Comment, UserTz,
                PrivType, Active
           FROM tblUsers
          WHERE UserId > ?
          ORDER BY UserId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        for (const r of chunk) {
          const email =
            (r.Email /* optional future field */) ||
            (r.CellPhone && `${r.CellPhone}@legacy.local`) ||
            (r.HomePhone && `${r.HomePhone}@legacy.local`) ||
            `user-${r.UserId}@legacy.local`;

          const password = r.Pass || "";
          const firstName = r.FirstName || "";
          const lastName = r.LastName || "";
          const legacyUserId =
            r.UserId !== null && r.UserId !== undefined
              ? String(r.UserId)
              : null;

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10}, $${params.length + 11}, $${params.length + 12}, $${params.length + 13}, $${params.length + 14})`
          );

          params.push(
            uuidv4(),
            tenantId,
            email,
            password,
            firstName,
            lastName,
            null,
            null,
            "EMPLOYEE",
            asBool(r.Active),
            now,
            now,
            legacyUserId,
            branchIdValue
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "User" (
              id, "tenantId", email, password, "firstName", "lastName",
              "firstNameHe", "lastNameHe", role, active, "createdAt", "updatedAt",
              "userId", "branchId"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (email)
            DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              password = EXCLUDED.password,
              "firstName" = EXCLUDED."firstName",
              "lastName" = EXCLUDED."lastName",
              role = EXCLUDED.role,
              active = EXCLUDED.active,
              "updatedAt" = EXCLUDED."updatedAt",
              "userId" = EXCLUDED."userId",
              "branchId" = EXCLUDED."branchId"
            `,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }
      }

      lastId = rows[rows.length - 1].UserId;
      console.log(`Users migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ User migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateUser;
