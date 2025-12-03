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
  let missingCity = 0;
  let missingDiscount = 0;
  let missingGroup = 0;
  let missingRef = 0;
  let missingUser = 0;
  let missingSub1 = 0;
  let missingSub2 = 0;
  let missingLang = 0;

  try {
    const cityMap = new Map();
    const discountMap = new Map();
    const groupMap = new Map();
    const refMap = new Map();
    const userMap = new Map();
    const refsSub1Map = new Map();
    const refsSub2Map = new Map();
    const langMap = new Map();

    const loadMap = async (query, map, keyName = "legacy", valueName = "id") => {
      const res = await pg.query(query, [tenantId]);
      for (const row of res.rows) {
        const key = row[keyName] !== null && row[keyName] !== undefined ? String(row[keyName]) : null;
        if (key) map.set(key, row[valueName]);
      }
    };

    try {
      // todo use branchId too
      await loadMap(`SELECT "cityId" AS legacy, id FROM "City" WHERE "tenantId" = $1`, cityMap);
      await loadMap(`SELECT "discountId" AS legacy, id FROM "Discount" WHERE "tenantId" = $1`, discountMap);
      await loadMap(`SELECT "groupId" AS legacy, id FROM "CustomerGroup" WHERE "tenantId" = $1`, groupMap);
      await loadMap(`SELECT "refId" AS legacy, id FROM "Ref" WHERE "tenantId" = $1`, refMap);
      await loadMap(`SELECT "userId" AS legacy, id FROM "User" WHERE "tenantId" = $1`, userMap);
      await loadMap(`SELECT "refsSub1Id" AS legacy, id FROM "RefsSub1" WHERE "tenantId" = $1`, refsSub1Map);
      await loadMap(`SELECT "refsSub2Id" AS legacy, id FROM "RefsSub2" WHERE "tenantId" = $1`, refsSub2Map);
      await loadMap(`SELECT "langId" AS legacy, id FROM "Lang" WHERE "tenantId" = $1`, langMap);
    } catch (err) {
      console.warn("⚠️ PerData: one or more mapping preloads failed; proceeding with null mappings.", err.message);
    }

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

          const legacyCityId = asInteger(row.CityId);
          const cityId =
            legacyCityId !== null ? cityMap.get(String(legacyCityId)) ?? (missingCity += 1, null) : null;

          const legacyDiscountId = asInteger(row.DiscountId);
          const discountId =
            legacyDiscountId !== null
              ? discountMap.get(String(legacyDiscountId)) ?? (missingDiscount += 1, null)
              : null;

          const legacyGroupId = asInteger(row.GroupId);
          const groupId =
            legacyGroupId !== null
              ? groupMap.get(String(legacyGroupId)) ?? (missingGroup += 1, null)
              : null;

          const legacyRefId = asInteger(row.RefId);
          const refId =
            legacyRefId !== null ? refMap.get(String(legacyRefId)) ?? (missingRef += 1, null) : null;

          const legacyUserId = asInteger(row.UserId);
          const userId =
            legacyUserId !== null
              ? userMap.get(String(legacyUserId)) ?? (missingUser += 1, null)
              : null;

          const legacyRefsSub1Id = asInteger(row.RefsSub1Id);
          const refsSub1Id =
            legacyRefsSub1Id !== null
              ? refsSub1Map.get(String(legacyRefsSub1Id)) ?? (missingSub1 += 1, null)
              : null;

          const legacyRefsSub2Id = asInteger(row.RefsSub2Id);
          const refsSub2Id =
            legacyRefsSub2Id !== null
              ? refsSub2Map.get(String(legacyRefsSub2Id)) ?? (missingSub2 += 1, null)
              : null;

          const legacyLangId = asInteger(row.LangId);
          const langId =
            legacyLangId !== null ? langMap.get(String(legacyLangId)) ?? (missingLang += 1, null) : null;

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
            cityId,                          // cityId (FK)
            asInteger(row.CityId),           // legacyCityId
            asInteger(row.ZipCode),          // zipCode
            asInteger(row.DiscountId),       // legacyDiscountId
            discountId,                      // discountId (FK)
            asInteger(row.GroupId),          // legacyGroupId
            groupId,                         // groupId (FK)
            asInteger(row.PerType),          // perType
            legacyRefId,                     // legacyRefId
            refId,                           // refId (FK)
            legacyUserId,                    // legacyUserId
            userId,                          // userId (FK)
            cleanText(row.Comment),          // comment
            legacyRefsSub1Id,                // legacyRefsSub1Id
            refsSub1Id,                      // refsSub1Id (FK)
            legacyRefsSub2Id,                // legacyRefsSub2Id
            refsSub2Id,                      // refsSub2Id (FK)
            asInteger(row.WantsLaser),       // wantsLaser
            safeDate(row.LaserDate),         // laserDate
            toBoolean(row.DidOperation),     // didOperation
            asInteger(row.FamId),            // legacyFamId
            row.FamId !== null && row.FamId !== undefined ? String(row.FamId) : null, // famId (legacy as string)
            toBoolean(row.MailList),         // mailList
            cleanText(row.Ocup),             // ocup
            cleanText(row.HidCom),           // hidCom
            legacyLangId,                    // legacyLangId
            langId,                          // langId (FK)
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
               ON CONFLICT ("tenantId", "branchId", "perId") DO NOTHING`,
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
    if (missingCity || missingDiscount || missingGroup || missingRef || missingUser || missingSub1 || missingSub2 || missingLang) {
      console.warn(
        `⚠️ PerData missing mappings -> city:${missingCity}, discount:${missingDiscount}, group:${missingGroup}, ref:${missingRef}, user:${missingUser}, refsSub1:${missingSub1}, refsSub2:${missingSub2}, lang:${missingLang}`
      );
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migratePerData;
