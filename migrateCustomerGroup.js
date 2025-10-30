const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");
const { ensureTenantId } = require("./tenantUtils");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

async function migrateCustomerGroup(tenantId = "tenant_1", branchId = null) {
  tenantId = ensureTenantId(tenantId, "tenant_1");

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;
  const missingCities = new Set();
  const missingDiscounts = new Set();

  try {
    await pg.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_indexes WHERE indexname = 'customer_group_tenant_groupcode_ux'
        ) THEN
          CREATE UNIQUE INDEX customer_group_tenant_groupcode_ux
            ON "CustomerGroup" ("tenantId", "groupCode");
        END IF;
      END$$;
    `);

    const { rows: cityRows } = await pg.query(
      `SELECT id, "cityId" FROM "City" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const cityMap = new Map(cityRows.map((row) => [String(row.cityId), row.id]));

    const { rows: discountRows } = await pg.query(
      `SELECT id, "discountId" FROM "Discount" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const discountMap = new Map(discountRows.map((row) => [String(row.discountId), row.id]));

    while (true) {
      const [rows] = await mysql.execute(
        `SELECT GroupId, GroupName, Phone, Fax, Email, Address, CityId, ZipCode, Comment, DiscountId
           FROM tblGroups
          WHERE GroupId > ?
          ORDER BY GroupId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        for (const row of chunk) {
          const groupId = String(row.GroupId);
          const groupName = row.GroupName && row.GroupName.trim().length
            ? row.GroupName.trim()
            : `Group ${groupId}`;

          const cityKey =
            row.CityId !== null && row.CityId !== undefined ? String(row.CityId) : null;
          const cityId = cityKey ? cityMap.get(cityKey) ?? null : null;
          if (cityKey && !cityId) {
            missingCities.add(cityKey);
          }

          const discountKey =
            row.DiscountId !== null && row.DiscountId !== undefined
              ? String(row.DiscountId)
              : null;
          const discountId = discountKey ? discountMap.get(discountKey) ?? null : null;
          if (discountKey && !discountId) {
            missingDiscounts.add(discountKey);
          }

          const zipCode =
            row.ZipCode !== null && row.ZipCode !== undefined ? String(row.ZipCode) : null;

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10}, $${params.length + 11}, $${params.length + 12}, $${params.length + 13}, $${params.length + 14}, $${params.length + 15}, $${params.length + 16}, $${params.length + 17}, $${params.length + 18}, $${params.length + 19})`
          );

          params.push(
            uuidv4(), // id
            tenantId, // tenantId
            groupId, // groupCode
            groupName, // name
            groupName, // nameHe
            0, // discount (legacy table has no explicit value)
            true, // isActive
            now, // createdAt
            now, // updatedAt
            row.Address || null, // address
            branchId, // branchId (provided by caller; null when unavailable)
            cityId, // cityId (uuid from City table)
            row.Comment || null, // comment
            discountId, // discountId (uuid from Discount table)
            row.Email || null, // email
            row.Fax || null, // fax
            groupId, // groupId (legacy identifier)
            row.Phone || null, // phone
            zipCode // zipCode
          );
        }

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "CustomerGroup" (
              id, "tenantId", "groupCode", name, "nameHe", discount, "isActive", "createdAt",
              "updatedAt", address, "branchId", "cityId", comment, "discountId", email, fax,
              "groupId", phone, "zipCode"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "groupCode")
            DO UPDATE SET
              name = EXCLUDED.name,
              "nameHe" = EXCLUDED."nameHe",
              discount = EXCLUDED.discount,
              "isActive" = EXCLUDED."isActive",
              "updatedAt" = EXCLUDED."updatedAt",
              address = EXCLUDED.address,
              "branchId" = EXCLUDED."branchId",
              "cityId" = EXCLUDED."cityId",
              comment = EXCLUDED.comment,
              "discountId" = EXCLUDED."discountId",
              email = EXCLUDED.email,
              fax = EXCLUDED.fax,
              "groupId" = EXCLUDED."groupId",
              phone = EXCLUDED.phone,
              "zipCode" = EXCLUDED."zipCode"
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
      console.log(`CustomerGroups migrated: ${total} (lastId=${lastId})`);
    }

    if (missingCities.size) {
      const sample = Array.from(missingCities).slice(0, 10);
      const suffix = missingCities.size > sample.length ? " ..." : "";
      console.log(
        `⚠️ Missing City mappings for ${missingCities.size} legacy IDs. Sample: ${sample.join(", ")}${suffix}`
      );
    }

    if (missingDiscounts.size) {
      const sample = Array.from(missingDiscounts).slice(0, 10);
      const suffix = missingDiscounts.size > sample.length ? " ..." : "";
      console.log(
        `⚠️ Missing Discount mappings for ${missingDiscounts.size} legacy IDs. Sample: ${sample.join(", ")}${suffix}`
      );
    }

    console.log(`✅ CustomerGroup migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCustomerGroup;
