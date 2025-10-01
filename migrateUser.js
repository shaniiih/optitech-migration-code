// migrateUser.js (batched/resumable/idempotent)
// Mirrors approach from migrateCity.js:contentReference[oaicite:2]{index=2}
const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE  = 1000;

function asBool(v) {
  // MySQL "boolean" is tinyint(1); also handle Buffer/bit fields defensively
  if (v === null || v === undefined) return false;
  if (Buffer.isBuffer(v)) return v.some(b => b !== 0);
  return v === true || v === 1 || v === "1";
}

async function migrateUser(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  let branchMap = new Map();

  try {
    // Ensure unique index on (tenantId, email)
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

    // Preload branch code -> id mapping so we can satisfy FK constraints
    const { rows: branchRows } = await pg.query(
      `SELECT id, code FROM "Branch" WHERE "tenantId" = $1`,
      [tenantId]
    );
    branchMap = new Map(branchRows.map((b) => [b.code, b.id]));

    while (true) {
      // ⚠️ Inline LIMIT to avoid ER_WRONG_ARGUMENTS with prepared statements
      const [rows] = await mysql.query(
        `SELECT UserId, LastName, FirstName, HomePhone, CellPhone, Fax, Address, ZipCode,
                Diag, Emp, CityId, BirthDate, Salary, Pass, LevelId, Comment, UserTz,
                PrivType, Active, BranchId
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
          // Email fallback: deterministic, unique per tenant+UserId
          const email =
            (r.Email /* if you later add it */) ||
            (r.CellPhone && `${r.CellPhone}@legacy.local`) ||
            (r.HomePhone && `${r.HomePhone}@legacy.local`) ||
            `user-${r.UserId}@legacy.local`;

          // Password (plain) migrated as-is; consider hashing if appropriate
          const password = r.Pass || "";

          // Names
          const firstName = r.FirstName || "";
          const lastName  = r.LastName  || "";

          // Branch (map legacy numeric id -> PG UUID; fall back to null if missing)
          const branchId =
            r.BranchId != null && r.BranchId !== ""
              ? branchMap.get(String(r.BranchId)) ?? null
              : null;

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10}, $${params.length + 11}, $${params.length + 12}, $${params.length + 13})`
          );

          params.push(
            uuidv4(),           // id (text)
            tenantId,           // tenantId
            email,              // email (text, NOT NULL)
            password,           // password (text, NOT NULL)
            firstName,          // firstName (text, NOT NULL)
            lastName,           // lastName  (text, NOT NULL)
            null,               // firstNameHe (missing in MySQL)
            null,               // lastNameHe  (missing in MySQL)
            "EMPLOYEE",         // role default
            asBool(r.Active),   // active (boolean)
            now,                // createdAt (timestamp, default NOW)
            now,                // updatedAt
            branchId             // branchId (uuid | null)
          );
        }

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "User" (
              id, "tenantId", email, password, "firstName", "lastName",
              "firstNameHe", "lastNameHe", role, active, "createdAt", "updatedAt", "branchId"
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
              "branchId" = EXCLUDED."branchId"
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (e) {
          await pg.query("ROLLBACK");
          throw e;
        }

        total += chunk.length;
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
