const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");
const { ensureTenantId } = require("./tenantUtils");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function normalizeInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  if (typeof value === "bigint") {
    return Number(value);
  }
  if (Buffer.isBuffer(value)) {
    return normalizeInt(value.toString("utf8"));
  }
  const trimmed = cleanText(value);
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

async function migrateGroup(tenantId = "tenant_1", branchId = null) {
  tenantId = ensureTenantId(tenantId, "tenant_1");
  const normalizedBranchId = cleanText(branchId);

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;
  const missingCities = new Set();
  const missingDiscounts = new Set();

  try {
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
        const values = [];
        const params = [];
        const now = new Date();

        for (const row of chunk) {
          const groupId = normalizeInt(row.GroupId);
          if (groupId === null) continue;

          const groupName =
            cleanText(row.GroupName) || `Group ${groupId}`;

          const cityKey = normalizeInt(row.CityId);
          const cityId = cityKey !== null ? cityMap.get(String(cityKey)) ?? null : null;
          if (cityKey !== null && !cityId) {
            missingCities.add(String(cityKey));
          }

          const discountKey = normalizeInt(row.DiscountId);
          const discountId = discountKey !== null ? discountMap.get(String(discountKey)) ?? null : null;
          if (discountKey !== null && !discountId) {
            missingDiscounts.add(String(discountKey));
          }

          const phone = normalizeInt(row.Phone);
          const zipCode =
            row.ZipCode !== null && row.ZipCode !== undefined ? String(row.ZipCode) : null;

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9}, $${base + 10}, $${base + 11}, $${base + 12}, $${base + 13}, $${base + 14}, $${base + 15})`
          );
          params.push(
            uuidv4(), // id
            tenantId, // tenantId
            normalizedBranchId || null, // branchId
            groupId, // groupId
            groupName, // groupName
            phone, // Phone
            cleanText(row.Fax), // fax
            cleanText(row.Email), // email
            cleanText(row.Address), // Address
            cityId, // cityId (uuid)
            zipCode, // zipCode
            cleanText(row.Comment), // comment
            discountId, // discountId (uuid)
            now, // createdAt
            now // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "Group" (
              id,
              "tenantId",
              "branchId",
              "groupId",
              "groupName",
              "Phone",
              fax,
              email,
              "Address",
              "cityId",
              "zipCode",
              comment,
              "discountId",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "groupId")
            DO UPDATE SET
              "groupName" = EXCLUDED."groupName",
              "Phone" = EXCLUDED."Phone",
              fax = EXCLUDED.fax,
              email = EXCLUDED.email,
              "Address" = EXCLUDED."Address",
              "cityId" = EXCLUDED."cityId",
              "zipCode" = EXCLUDED."zipCode",
              comment = EXCLUDED.comment,
              "discountId" = EXCLUDED."discountId",
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      lastId = rows[rows.length - 1].GroupId ?? lastId;
      console.log(`Groups migrated: ${total} (lastId=${lastId})`);
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

    console.log(`✅ Group migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateGroup;
