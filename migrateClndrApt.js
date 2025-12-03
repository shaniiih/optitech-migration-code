const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");
const { ensureTenantId } = require("./tenantUtils");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const s = String(value).trim();
  return s.length ? s : null;
}

function asInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  const s = String(value).trim();
  if (!s) return null;
  const n = Number(s);
  return Number.isFinite(n) ? Math.trunc(n) : null;
}

function asBool(value) {
  if (value === null || value === undefined) return false;
  if (value === true || value === false) return value;
  if (typeof value === "number") return value !== 0;
  const s = String(value).trim().toLowerCase();
  if (!s) return false;
  return s === "1" || s === "true" || s === "yes";
}

function asDate(value) {
  if (value === null || value === undefined) return null;
  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value;
  }
  const s = cleanText(value);
  if (!s) return null;
  const d = new Date(s);
  return Number.isNaN(d.getTime()) ? null : d;
}

async function migrateClndrApt(tenantId = "tenant_1", branchId) {
  tenantId = ensureTenantId(tenantId, "tenant_1");
  if (!branchId) {
    throw new Error("migrateClndrApt requires a non-null BRANCH_ID");
  }

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;
  try {
    // Map legacy UserID -> User.id for this tenant+branch
    const { rows: userRows } = await pg.query(
      `SELECT id, "userId"
         FROM "User"
        WHERE "tenantId" = $1 AND "branchId" = $2`,
      [tenantId, branchId]
    );
    const userMap = new Map(); // legacy userId (int) -> User.id
    for (const row of userRows) {
      const legacyUserId = asInt(row.userId);
      if (legacyUserId === null) continue;
      if (!userMap.has(legacyUserId)) {
        userMap.set(legacyUserId, row.id);
      }
    }

    // Map legacy PerID -> PerData.id for this tenant+branch
    const { rows: perDataRows } = await pg.query(
      `SELECT id, "perId"
         FROM "PerData"
        WHERE "tenantId" = $1 AND "branchId" = $2`,
      [tenantId, branchId]
    );
    const perDataMap = new Map(); // legacy PerID (int) -> PerData.id
    for (const row of perDataRows) {
      const legacyPerId = asInt(row.perId);
      if (legacyPerId === null) continue;
      if (!perDataMap.has(legacyPerId)) {
        perDataMap.set(legacyPerId, row.id);
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT AptNum, UserID, AptDate, StarTime, EndTime, AptDesc, PerID, TookPlace, Reminder, SMSSent
           FROM tblClndrApt
          ORDER BY AptNum
          LIMIT ${WINDOW_SIZE}
          OFFSET ${offset}`
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const r of chunk) {
          const aptNum = asInt(r.AptNum);
          if (aptNum === null) {
            throw new Error(`ClndrApt: invalid AptNum '${r.AptNum}' for tenant=${tenantId}, branch=${branchId}`);
          }

          const aptDate = asDate(r.AptDate);
          if (!aptDate) {
            throw new Error(`ClndrApt: missing or invalid AptDate for AptNum=${aptNum}, tenant=${tenantId}, branch=${branchId}`);
          }

          const legacyUserId = asInt(r.UserID);
          const userId = legacyUserId !== null ? userMap.get(legacyUserId) || null : null;

          const legacyPerId = asInt(r.PerID);
          const perId = legacyPerId !== null ? perDataMap.get(legacyPerId) || null : null;

          const startTime = asDate(r.StarTime);
          const endTime = asDate(r.EndTime);
          const tookPlace = asBool(r.TookPlace);
          const reminder = asInt(r.Reminder);
          const smsSent = asBool(r.SMSSent);

          const createdAt = startTime || aptDate || new Date();
          const updatedAt = endTime || createdAt;

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9}, $${base + 10}, $${base + 11}, $${base + 12}, $${base + 13}, $${base + 14}, $${base + 15}, $${base + 16}, $${base + 17})`
          );

          params.push(
            createId(),                 // id
            tenantId,                 // tenantId
            branchId,                 // branchId
            aptNum,                   // aptNum
            aptDate,                  // aptDate
            legacyUserId,             // legacyUserId
            userId,                   // userId (nullable)
            startTime,                // startTime
            endTime,                  // endTime
            cleanText(r.AptDesc),     // aptDesc
            legacyPerId,              // legacyPerId
            perId,                    // perId (nullable)
            tookPlace,                // tookPlace
            reminder,                 // reminder (nullable)
            smsSent,                  // smsSent
            createdAt,                // createdAt
            updatedAt                 // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "ClndrApt" (
              id,
              "tenantId",
              "branchId",
              "aptNum",
              "aptDate",
              "legacyUserId",
              "userId",
              "startTime",
              "endTime",
              "aptDesc",
              "legacyPerId",
              "perId",
              "tookPlace",
              "reminder",
              "smsSent",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "aptNum")
            DO UPDATE SET
              "aptDate"     = EXCLUDED."aptDate",
              "legacyUserId"= EXCLUDED."legacyUserId",
              "userId"      = EXCLUDED."userId",
              "startTime"   = EXCLUDED."startTime",
              "endTime"     = EXCLUDED."endTime",
              "aptDesc"     = EXCLUDED."aptDesc",
              "legacyPerId" = EXCLUDED."legacyPerId",
              "perId"       = EXCLUDED."perId",
              "tookPlace"   = EXCLUDED."tookPlace",
              "reminder"    = EXCLUDED."reminder",
              "smsSent"     = EXCLUDED."smsSent",
              "updatedAt"   = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (e) {
          await pg.query("ROLLBACK");
          throw e;
        }
      }

      offset += rows.length;
      console.log(`ClndrApt migrated: ${total} (offset=${offset})`);
    }

    console.log(`✅ ClndrApt migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateClndrApt;
