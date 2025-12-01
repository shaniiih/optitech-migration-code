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

function asBool(value) {
  if (value === null || value === undefined) return false;
  if (Buffer.isBuffer(value)) return value.some((b) => b !== 0);
  if (typeof value === "string") {
    const normalized = value.trim().toLowerCase();
    if (!normalized) return false;
    return ["1", "true", "yes", "y"].includes(normalized);
  }
  return Boolean(value);
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

function normalizeNumber(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? value : null;
  }
  if (typeof value === "bigint") {
    return Number(value);
  }
  if (Buffer.isBuffer(value)) {
    return normalizeNumber(value.toString("utf8"));
  }
  const trimmed = cleanText(String(value).replace(/,/g, "."));
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? parsed : null;
}

function normalizeDate(value) {
  if (value === null || value === undefined) return null;

  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value;
  }

  const trimmed = cleanText(value);
  if (!trimmed) return null;
  if (/^0{4}-0{2}-0{2}/.test(trimmed)) return null;

  const parsed = new Date(trimmed);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

async function migrateUser(tenantId = "tenant_1", branchId = null) {
  tenantId = ensureTenantId(tenantId, "tenant_1");
  const normalizedBranchId = cleanText(branchId);

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;
  let skippedInvalidId = 0;
  const missingCities = new Set();
  const missingLevels = new Set();

  try {
    const { rows: sysLevelRows } = await pg.query(
      `SELECT id, "levelId"
         FROM "SysLevel"
        WHERE "tenantId" = $1`,
      [tenantId]
    );
    const sysLevelMap = new Map(
      sysLevelRows
        .filter((row) => row.levelId !== null && row.levelId !== undefined)
        .map((row) => [String(row.levelId), row.id])
    );

    const { rows: cityRows } = await pg.query(
      `SELECT id, "cityId"
         FROM "City"
        WHERE "tenantId" = $1`,
      [tenantId]
    );
    const cityMap = new Map(cityRows.map((row) => [String(row.cityId), row.id]));

    while (true) {
      const [rows] = await mysql.query(
        `SELECT UserId, LastName, FirstName, HomePhone, CellPhone, Fax, Address, ZipCode, Diag, Emp,
                CityId, BirthDate, Salary, Pass, LevelId, Comment, UserTz, PrivType, Active, BranchId
           FROM tblUsers
          WHERE UserId > ?
          ORDER BY UserId
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
          const legacyId = normalizeInt(r.UserId);
          if (legacyId === null) {
            skippedInvalidId += 1;
            continue;
          }

          const safeLegacyId = legacyId !== null ? legacyId : uuidv4();
          const email =
            cleanText(r.Email)?.toLowerCase() ||
            `${tenantId}_${safeLegacyId}@optitech.com`.toLowerCase();
          const legacyPass = cleanText(r.Pass);
          const password = legacyPass || "";
          const birthDate = normalizeDate(r.BirthDate);
          const salary = normalizeNumber(r.Salary);
          const zipCode =
            r.ZipCode === null || r.ZipCode === undefined ? null : String(r.ZipCode);

          const cityKey = normalizeInt(r.CityId);
          const mappedCityId = cityKey !== null ? cityMap.get(String(cityKey)) ?? null : null;
          if (cityKey !== null && !mappedCityId) {
            missingCities.add(String(cityKey));
          }

          const levelId = normalizeInt(r.LevelId);
          const mappedLevelId = levelId !== null ? sysLevelMap.get(String(levelId)) ?? null : null;
          if (levelId !== null && !mappedLevelId) {
            missingLevels.add(String(levelId));
          }
          const privType = normalizeInt(r.PrivType);
          const oldBranchId = normalizeInt(r.BranchId);

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10}, $${params.length + 11}, $${params.length + 12}, $${params.length + 13}, $${params.length + 14}, $${params.length + 15}, $${params.length + 16}, $${params.length + 17}, $${params.length + 18}, $${params.length + 19}, $${params.length + 20}, $${params.length + 21}, $${params.length + 22}, $${params.length + 23}, $${params.length + 24}, $${params.length + 25}, $${params.length + 26}, $${params.length + 27}, $${params.length + 28}, $${params.length + 29}, $${params.length + 30})`
          );

          params.push(
            uuidv4(), // id
            tenantId, // tenantId
            email, // email
            password, // password
            cleanText(r.FirstName) || "", // firstName
            cleanText(r.LastName) || "", // lastName
            cleanText(r.FirstName), // firstNameHe
            cleanText(r.LastName), // lastNameHe
            String(legacyId), // userId (legacy)
            "EMPLOYEE", // role
            asBool(r.Active), // active
            now, // createdAt
            now, // updatedAt
            null, // lastLoginAt
            normalizedBranchId || null, // branchId (new)
            cleanText(r.Address), // Address
            birthDate, // BirthDate
            cleanText(r.CellPhone), // CellPhone
            asBool(r.Diag), // Diag
            asBool(r.Emp), // Emp
            cleanText(r.Fax), // Fax
            cleanText(r.HomePhone), // HomePhone
            legacyPass || password, // Pass (legacy)
            privType, // PrivType
            salary, // Salary
            cleanText(r.UserTz), // UserTz
            zipCode, // ZipCode
            mappedCityId, // cityId (mapped from City table)
            mappedLevelId, // levelId (maps to SysLevel.id)
            oldBranchId // oldBranchId
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "User" (
              id, "tenantId", email, password, "firstName", "lastName", "firstNameHe", "lastNameHe",
              "userId", role, active, "createdAt", "updatedAt", "lastLoginAt", "branchId", "Address",
              "BirthDate", "CellPhone", "Diag", "Emp", "Fax", "HomePhone", "Pass", "PrivType",
              "Salary", "UserTz", "ZipCode", "cityId", "levelId", "oldBranchId"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "userId")
            DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              password = EXCLUDED.password,
              email = EXCLUDED.email,
              "firstName" = EXCLUDED."firstName",
              "lastName" = EXCLUDED."lastName",
              "firstNameHe" = EXCLUDED."firstNameHe",
              "lastNameHe" = EXCLUDED."lastNameHe",
              "userId" = EXCLUDED."userId",
              role = EXCLUDED.role,
              active = EXCLUDED.active,
              "updatedAt" = EXCLUDED."updatedAt",
              "branchId" = EXCLUDED."branchId",
              "Address" = EXCLUDED."Address",
              "BirthDate" = EXCLUDED."BirthDate",
              "CellPhone" = EXCLUDED."CellPhone",
              "Diag" = EXCLUDED."Diag",
              "Emp" = EXCLUDED."Emp",
              "Fax" = EXCLUDED."Fax",
              "HomePhone" = EXCLUDED."HomePhone",
              "Pass" = EXCLUDED."Pass",
              "PrivType" = EXCLUDED."PrivType",
              "Salary" = EXCLUDED."Salary",
              "UserTz" = EXCLUDED."UserTz",
              "ZipCode" = EXCLUDED."ZipCode",
              "cityId" = EXCLUDED."cityId",
              "levelId" = EXCLUDED."levelId",
              "oldBranchId" = EXCLUDED."oldBranchId",
              "lastLoginAt" = COALESCE(EXCLUDED."lastLoginAt", "User"."lastLoginAt")
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

      lastId = rows[rows.length - 1].UserId ?? lastId;
      console.log(`Users migrated so far: ${total} (lastId=${lastId})`);
    }

    if (missingCities.size) {
      const sample = Array.from(missingCities).slice(0, 10);
      const suffix = missingCities.size > sample.length ? " ..." : "";
      console.log(
        `⚠️ Missing City mappings for ${missingCities.size} legacy IDs. Sample: ${sample.join(", ")}${suffix}`
      );
    }

    if (missingLevels.size) {
      const sample = Array.from(missingLevels).slice(0, 10);
      const suffix = missingLevels.size > sample.length ? " ..." : "";
      console.log(
        `⚠️ Missing SysLevel mappings for ${missingLevels.size} legacy IDs. Sample: ${sample.join(", ")}${suffix}`
      );
    }

    if (skippedInvalidId) {
      console.log(`⚠️ Skipped ${skippedInvalidId} users due to invalid UserId`);
    }

    console.log(`✅ User migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateUser;
