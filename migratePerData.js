const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function asNumber(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? value : null;
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? parsed : null;
}

function toBoolean(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "boolean") return value;
  if (typeof value === "number") {
    if (!Number.isFinite(value)) return null;
    return value !== 0;
  }
  const trimmed = String(value).trim().toLowerCase();
  if (!trimmed) return null;
  if (["1", "true", "t", "yes", "y"].includes(trimmed)) return true;
  if (["0", "false", "f", "no", "n"].includes(trimmed)) return false;
  return null;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function safeDate(value) {
  if (!value) return null;
  const d = new Date(value);
  return Number.isFinite(d.getTime()) ? d : null;
}

async function migratePerData(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    await pg.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1
          FROM pg_indexes
          WHERE schemaname = 'public'
            AND indexname = 'perdata_tenant_perid_ux'
        ) THEN
          CREATE UNIQUE INDEX perdata_tenant_perid_ux
          ON "PerData" ("tenantId","perId");
        END IF;
      END$$;
    `);

    while (true) {
      const [rows] = await mysql.query(
        `SELECT PerId, LastName, FirstName, TzId, BirthDate, Sex, HomePhone, WorkPhone,
                CellPhone, Fax, Email, Address, CityId, ZipCode, DiscountId, GroupId,
                PerType, RefId, UserId, Comment, RefsSub1Id, RefsSub2Id, WantsLaser,
                LaserDate, DidOperation, FamId, MailList, Ocup, HidCom, LangId, BranchId
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
        const seenIds = new Set();

        for (const row of chunk) {
          const perId = asInteger(row.PerId);
          if (perId === null) continue;
          if (seenIds.has(perId)) continue;
          seenIds.add(perId);

          const lastName = cleanText(row.LastName) || "Unknown";
          const firstName = cleanText(row.FirstName) || `Per ${perId}`;

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9}, $${base + 10}, $${base + 11}, $${base + 12}, $${base + 13}, $${base + 14}, $${base + 15}, $${base + 16}, $${base + 17}, $${base + 18}, $${base + 19}, $${base + 20}, $${base + 21}, $${base + 22}, $${base + 23}, $${base + 24}, $${base + 25}, $${base + 26}, $${base + 27}, $${base + 28}, $${base + 29}, $${base + 30}, $${base + 31}, $${base + 32}, $${base + 33}, $${base + 34}, $${base + 35}, $${base + 36}, $${base + 37}, $${base + 38}, $${base + 39}, $${base + 40}, $${base + 41}, $${base + 42}, $${base + 43}, $${base + 44}, $${base + 45})`
          );

          params.push(
            uuidv4(),                        // id
            tenantId,                        // tenantId
            branchId,                        // branchId
            asInteger(row.BranchId),         // legacyBranchId
            perId,                           // perId
            lastName,                        // lastName
            firstName,                       // firstName
            cleanText(row.TzId),             // tzId
            safeDate(row.BirthDate),         // birthDate
            toBoolean(row.Sex),              // sex
            cleanText(row.HomePhone),        // homePhone
            cleanText(row.WorkPhone),        // workPhone
            cleanText(row.CellPhone),        // cellPhone
            cleanText(row.Fax),              // fax
            cleanText(row.Email),            // email
            cleanText(row.Address),          // address
            null,                            // cityId (not mapped)
            asInteger(row.CityId),           // legacyCityId
            asInteger(row.ZipCode),          // zipCode
            asInteger(row.DiscountId),       // legacyDiscountId
            null,                            // discountId
            asInteger(row.GroupId),          // legacyGroupId
            null,                            // groupId
            asInteger(row.PerType),          // perType
            asInteger(row.RefId),            // legacyRefId
            null,                            // refId
            asInteger(row.UserId),           // legacyUserId
            null,                            // userId
            cleanText(row.Comment),          // comment
            asInteger(row.RefsSub1Id),       // legacyRefsSub1Id
            null,                            // refsSub1Id
            asInteger(row.RefsSub2Id),       // legacyRefsSub2Id
            null,                            // refsSub2Id
            asInteger(row.WantsLaser),       // wantsLaser
            safeDate(row.LaserDate),         // laserDate
            toBoolean(row.DidOperation),     // didOperation
            asInteger(row.FamId),            // legacyFamId
            null,                            // famId
            toBoolean(row.MailList),         // mailList
            cleanText(row.Ocup),             // ocup
            cleanText(row.HidCom),           // hidCom
            asInteger(row.LangId),           // legacyLangId
            null,                            // langId
            now,                             // createdAt
            now                              // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "PerData" (
               id,
               "tenantId",
               "branchId",
               "legacyBranchId",
               "perId",
               "lastName",
               "firstName",
               "tzId",
               "birthDate",
               "sex",
               "homePhone",
               "workPhone",
               "cellPhone",
               "fax",
               email,
               address,
               "cityId",
               "legacyCityId",
               "zipCode",
               "legacyDiscountId",
               "discountId",
               "legacyGroupId",
               "groupId",
               "perType",
               "legacyRefId",
               "refId",
               "legacyUserId",
               "userId",
               "comment",
               "legacyRefsSub1Id",
               "refsSub1Id",
               "legacyRefsSub2Id",
               "refsSub2Id",
               "wantsLaser",
               "laserDate",
               "didOperation",
               "legacyFamId",
               "famId",
               "mailList",
               "ocup",
               "hidCom",
               "legacyLangId",
               "langId",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT DO NOTHING`,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      const latestId = asInteger(rows[rows.length - 1]?.PerId);
      if (latestId !== null) {
        lastId = latestId;
      }
      console.log(`PerData migrated so far: ${total} (lastPerId=${lastId})`);
    }

    console.log(`✅ PerData migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migratePerData;
