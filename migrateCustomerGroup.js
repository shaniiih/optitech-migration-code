const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

async function migrateCustomerGroup(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;

  try {
    await pg.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_indexes WHERE indexname = 'customer_group_tenant_code_ux'
        ) THEN
          CREATE UNIQUE INDEX customer_group_tenant_code_ux
          ON "CustomerGroup" ("tenantId", "groupCode");
        END IF;
      END$$;
    `);

    while (true) {
      const [rows] = await mysql.query(
        `SELECT GroupId, GroupName, Comment
           FROM tblGroups
          WHERE GroupId > ?
          ORDER BY GroupId
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
          const groupCode = String(r.GroupId);
          const name = r.GroupName && r.GroupName.trim()
            ? r.GroupName.trim()
            : `Group ${groupCode}`;

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8})`
          );

          params.push(
            uuidv4(),      // id
            tenantId,      // tenantId
            groupCode,     // groupCode
            name,          // name
            null,          // nameHe
            0,             // discount (no direct legacy equivalent)
            true,          // isActive
            now            // updatedAt (createdAt handled by default)
          );
        }

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "CustomerGroup" (
              id, "tenantId", "groupCode", name, "nameHe", discount, "isActive", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "groupCode")
            DO UPDATE SET
              name = EXCLUDED.name,
              "nameHe" = EXCLUDED."nameHe",
              discount = EXCLUDED.discount,
              "isActive" = EXCLUDED."isActive",
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }

        total += chunk.length;
      }

      lastId = rows[rows.length - 1].GroupId;
      console.log(`Customer groups migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ CustomerGroup migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCustomerGroup;
