const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");
const { ensureTenantId } = require("./tenantUtils");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function asBool(value) {
  if (value === null || value === undefined) return false;
  if (Buffer.isBuffer(value)) return value.some((b) => b !== 0);
  if (typeof value === "string") return value === "1" || value.toLowerCase() === "true";
  return Boolean(value);
}

function languageFromLegacy(langId) {
  if (langId === null || langId === undefined) return "he";
  const code = Number(langId);
  switch (code) {
    case 1:
      return "he";
    case 2:
      return "en";
    case 3:
      return "ru";
    default:
      return "he";
  }
}

function normalizeDate(value) {
  if (value === null || value === undefined) return null;

  // MySQL zero dates ("0000-00-00" / "0000-00-00 00:00:00") should be treated as null
  if (typeof value === "string") {
    const trimmed = value.trim();
    if (!trimmed) return null;
    if (/^0{4}-0{2}-0{2}/.test(trimmed)) return null;

    const parsed = new Date(trimmed);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value;
  }

  // Handle numeric timestamps (unlikely here but harmless)
  if (typeof value === "number") {
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  return null;
}

async function migrateCustomer(tenantId = "tenant_1") {
  tenantId = ensureTenantId(tenantId, "tenant_1");

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;

  try {
    await pg.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_indexes WHERE indexname = 'customer_tenant_customerid_ux'
        ) THEN
          CREATE UNIQUE INDEX customer_tenant_customerid_ux
          ON "Customer" ("tenantId", "customerId");
        END IF;
      END$$;
    `);

    const { rows: branchRows } = await pg.query(
      `SELECT id, code FROM "Branch" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const branchMap = new Map(branchRows.map((b) => [b.code, b.id]));

    const { rows: customerGroupRows } = await pg.query(
      `SELECT id, "groupCode" FROM "CustomerGroup" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const groupMap = new Map(customerGroupRows.map((g) => [g.groupCode, g.id]));

    const { rows: cityRows } = await pg.query(
      `SELECT "cityId", name FROM "City" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const cityMap = new Map(cityRows.map((c) => [String(c.cityId), c.name]));

    while (true) {
      const [rows] = await mysql.query(
        `SELECT PerId, LastName, FirstName, TzId, BirthDate, Sex, HomePhone, WorkPhone, CellPhone,
                Fax, Email, Address, CityId, ZipCode, DiscountId, GroupId, PerType, RefId, Comment,
                WantsLaser, LaserDate, DidOperation, FamId, MailList, Ocup, HidCom, LangId, BranchId
           FROM tblPerData
          WHERE PerId > ?
          ORDER BY PerId
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
          const customerId = String(r.PerId);
          const branchId =
            r.BranchId !== null && r.BranchId !== undefined
              ? branchMap.get(String(r.BranchId)) ?? null
              : null;
          const city = cityMap.get(String(r.CityId)) ?? null;
          const birthDate = normalizeDate(r.BirthDate);
          const laserDate = normalizeDate(r.LaserDate);
          const zipCode = r.ZipCode !== null && r.ZipCode !== undefined ? String(r.ZipCode) : null;
          const groupId =
            r.GroupId !== null && r.GroupId !== undefined
              ? groupMap.get(String(r.GroupId)) ?? null
              : null;
          const discountId =
            r.DiscountId !== null && r.DiscountId !== undefined ? String(r.DiscountId) : null;
          const referralId = r.RefId !== null && r.RefId !== undefined ? String(r.RefId) : null;
          const familyId = r.FamId !== null && r.FamId !== undefined ? String(r.FamId) : null;
          const gender =
            r.Sex === null || r.Sex === undefined
              ? null
              : asBool(r.Sex)
              ? "MALE"
              : "FEMALE";
          const mailList = asBool(r.MailList);
          const wantsLaser = asBool(r.WantsLaser);
          const didOperation = asBool(r.DidOperation);

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10}, $${params.length + 11}, $${params.length + 12}, $${params.length + 13}, $${params.length + 14}, $${params.length + 15}, $${params.length + 16}, $${params.length + 17}, $${params.length + 18}, $${params.length + 19}, $${params.length + 20}, $${params.length + 21}, $${params.length + 22}, $${params.length + 23}, $${params.length + 24}, $${params.length + 25}, $${params.length + 26}, $${params.length + 27}, $${params.length + 28}, $${params.length + 29}, $${params.length + 30}, $${params.length + 31}, $${params.length + 32}, $${params.length + 33}, $${params.length + 34}, $${params.length + 35}, $${params.length + 36}, $${params.length + 37}, $${params.length + 38}, $${params.length + 39}, $${params.length + 40}, $${params.length + 41})`
          );

          params.push(
            createId(), // id
            tenantId, // tenantId
            customerId, // customerId
            r.FirstName || "", // firstName
            r.LastName || "", // lastName
            r.FirstName, // firstNameHe
            r.LastName, // lastNameHe
            r.TzId || null, // idNumber
            birthDate, // birthDate
            gender, // gender
            r.Ocup || null, // occupation
            r.CellPhone || null, // cellPhone
            r.HomePhone || null, // homePhone
            r.WorkPhone || null, // workPhone
            r.Fax || null, // fax
            r.Email || null, // email
            r.Address || null, // address
            city, // city
            zipCode, // zipCode
            r.PerType !== null && r.PerType !== undefined ? String(r.PerType) : null, // customerType
            groupId, // groupId
            discountId, // discountId
            referralId, // referralId
            familyId, // familyId
            languageFromLegacy(r.LangId), // preferredLanguage
            mailList, // mailList
            mailList, // smsConsent (legacy lacked explicit flag; mirror mailList)
            r.Comment || null, // notes
            null, // tags
            null, // rating
            wantsLaser, // wantsLaser
            laserDate, // laserDate
            didOperation, // didOperation
            now, // createdAt
            now, // updatedAt
            null, // deletedAt
            branchId, // branchId
            null, // allergies
            null, // healthFund
            r.HidCom || null, // medicalConditions
            null // medications
          );
        }

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "Customer" (
              id, "tenantId", "customerId", "firstName", "lastName", "firstNameHe", "lastNameHe",
              "idNumber", "birthDate", gender, occupation, "cellPhone", "homePhone", "workPhone",
              fax, email, address, city, "zipCode", "customerType", "groupId", "discountId",
              "referralId", "familyId", "preferredLanguage", "mailList", "smsConsent", notes, tags,
              rating, "wantsLaser", "laserDate", "didOperation", "createdAt", "updatedAt", "deletedAt",
              "branchId", allergies, "healthFund", "medicalConditions", medications
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("customerId")
            DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              "firstName" = EXCLUDED."firstName",
              "lastName" = EXCLUDED."lastName",
              "idNumber" = EXCLUDED."idNumber",
              "birthDate" = EXCLUDED."birthDate",
              gender = EXCLUDED.gender,
              occupation = EXCLUDED.occupation,
              "cellPhone" = EXCLUDED."cellPhone",
              "homePhone" = EXCLUDED."homePhone",
              "workPhone" = EXCLUDED."workPhone",
              fax = EXCLUDED.fax,
              email = EXCLUDED.email,
              address = EXCLUDED.address,
              city = EXCLUDED.city,
              "zipCode" = EXCLUDED."zipCode",
              "customerType" = EXCLUDED."customerType",
              "groupId" = EXCLUDED."groupId",
              "discountId" = EXCLUDED."discountId",
              "referralId" = EXCLUDED."referralId",
              "familyId" = EXCLUDED."familyId",
              "preferredLanguage" = EXCLUDED."preferredLanguage",
              "mailList" = EXCLUDED."mailList",
              "smsConsent" = EXCLUDED."smsConsent",
              notes = EXCLUDED.notes,
              tags = EXCLUDED.tags,
              rating = EXCLUDED.rating,
              "wantsLaser" = EXCLUDED."wantsLaser",
              "laserDate" = EXCLUDED."laserDate",
              "didOperation" = EXCLUDED."didOperation",
              "updatedAt" = EXCLUDED."updatedAt",
              "deletedAt" = EXCLUDED."deletedAt",
              "branchId" = EXCLUDED."branchId",
              allergies = EXCLUDED.allergies,
              "healthFund" = EXCLUDED."healthFund",
              "medicalConditions" = EXCLUDED."medicalConditions",
              medications = EXCLUDED.medications
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

      lastId = rows[rows.length - 1].PerId;
      console.log(`Customers migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ Customer migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCustomer;
