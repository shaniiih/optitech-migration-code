const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function normalizeLegacyId(value) {
  if (value === null || value === undefined) return null;

  if (typeof value === "number" && Number.isFinite(value)) {
    return String(Math.trunc(value));
  }

  if (typeof value === "bigint") {
    return value.toString();
  }

  if (Buffer.isBuffer(value)) {
    return normalizeLegacyId(value.toString("utf8"));
  }

  const trimmed = cleanText(value);
  if (!trimmed) return null;

  if (/^[+-]?\d+(?:\.0+)?$/.test(trimmed)) {
    return String(parseInt(trimmed, 10));
  }

  return trimmed;
}

function legacyIdCandidates(value) {
  const normalized = normalizeLegacyId(value);
  if (!normalized) return [];
  const variants = new Set([normalized]);
  if (/\D/.test(normalized)) {
    const digitsOnly = normalized.replace(/\D+/g, "");
    if (digitsOnly) {
      const numericCandidate = normalizeLegacyId(digitsOnly);
      if (numericCandidate) {
        variants.add(numericCandidate);
      }
    }
  }
  return Array.from(variants);
}

function normalizeDateTime(value) {
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

function asNumber(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? value : null;
  }
  if (typeof value === "bigint") {
    return Number(value);
  }
  if (Buffer.isBuffer(value)) {
    return asNumber(value.toString("utf8"));
  }
  const trimmed = cleanText(String(value).replace(/,/g, "."));
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? parsed : null;
}

function asInteger(value) {
  const num = asNumber(value);
  return num === null ? null : Math.trunc(num);
}

function chooseTimestamp(primary, secondary) {
  return primary || secondary || new Date();
}

async function migrateClndrApt(tenantId = "tenant_1", rawDefaultBranchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;
  let skippedInvalidAptNum = 0;
  let skippedMissingUser = 0;
  let skippedMissingDate = 0;

  try {
    const defaultBranchId = cleanText(rawDefaultBranchId);

    const { rows: userRows } = await pg.query(
      `SELECT id, "branchId", "userId"
         FROM "User"
       WHERE "tenantId" = $1 AND "branchId" = $2`,
        [tenantId, branchId]
    );
    const userIdMap = new Map();
    for (const user of userRows) {
      const candidates = legacyIdCandidates(user.userId);
      if (!candidates.length) continue;
      for (const key of candidates) {
        if (!userIdMap.has(key) && user.id) {
          userIdMap.set(key, {
            id: user.id,
            branchId: user.branchId || defaultBranchId || null,
          });
        }
      }
    }

    const { rows: perDataRows } = await pg.query(
      `SELECT id, "branchId", "perId"
         FROM "PerData"
       WHERE "tenantId" = $1 AND "branchId" = $2`,
        [tenantId, branchId]
    );
    const perDataMap = new Map();
    for (const per of perDataRows) {
      if (per.perId == null) continue;
      const key = String(per.perId);
      if (!perDataMap.has(key) && per.id) {
        perDataMap.set(key, {
          id: per.id,
          branchId: per.branchId || null,
        });
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT AptNum, UserID, AptDate, StarTime, EndTime, AptDesc, PerID, TookPlace, Reminder, SMSSent
           FROM tblClndrApt
          ORDER BY AptNum
          LIMIT ${WINDOW_SIZE}
          OFFSET ?`,
        [offset]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const row of chunk) {
          const aptNumInt = asInteger(row.AptNum);
          if (aptNumInt === null) {
            skippedInvalidAptNum += 1;
            continue;
          }

          const aptDate = normalizeDateTime(row.AptDate);
          if (!aptDate) {
            skippedMissingDate += 1;
            continue;
          }

          const userLegacyId = asInteger(row.UserID);
          let userInfo = null;
          if (userLegacyId !== null) {
            for (const candidate of legacyIdCandidates(userLegacyId)) {
              const found = userIdMap.get(candidate);
              if (found) {
                userInfo = found;
                break;
              }
            }
          }
          if (!userInfo || !userInfo.id) {
            skippedMissingUser += 1;
            continue;
          }

          const legacyPerId = asInteger(row.PerID);
          let perDataInfo = null;
          let perDataId = null;
          if (legacyPerId !== null) {
            const perKey = String(legacyPerId);
            perDataInfo = perDataMap.get(perKey) || null;
            perDataId = perDataInfo ? perDataInfo.id : null;
          }

          const startTime = normalizeDateTime(row.StarTime);
          const endTime = normalizeDateTime(row.EndTime);
          const tookPlace =
            row.TookPlace === true ||
            row.TookPlace === 1 ||
            String(row.TookPlace).toLowerCase() === "true";
          const reminder = asInteger(row.Reminder);
          const smsSent =
            row.SMSSent === true ||
            row.SMSSent === 1 ||
            String(row.SMSSent).toLowerCase() === "true";

          const createdAt = chooseTimestamp(startTime, aptDate);
          const updatedAt = chooseTimestamp(endTime, createdAt);

          const branchId =
            userInfo.branchId ||
            (perDataInfo && perDataInfo.branchId) ||
            defaultBranchId ||
            null;

          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8}, $${offset + 9}, $${offset + 10}, $${offset + 11}, $${offset + 12}, $${offset + 13}, $${offset + 14}, $${offset + 15}, $${offset + 16}, $${offset + 17})`
          );

          params.push(
            uuidv4(), // id
            tenantId,
            branchId,
            aptNumInt,
            aptDate,
            userLegacyId,
            userInfo.id,
            startTime,
            endTime,
            cleanText(row.AptDesc),
            legacyPerId,
            perDataId,
            tookPlace,
            reminder !== null ? reminder : null,
            smsSent,
            createdAt,
            updatedAt
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
              "branchId"   = EXCLUDED."branchId",
              "aptDate"    = EXCLUDED."aptDate",
              "legacyUserId" = EXCLUDED."legacyUserId",
              "userId"     = EXCLUDED."userId",
              "startTime"  = EXCLUDED."startTime",
              "endTime"    = EXCLUDED."endTime",
              "aptDesc"    = EXCLUDED."aptDesc",
              "legacyPerId"= EXCLUDED."legacyPerId",
              "perId"      = EXCLUDED."perId",
              "tookPlace"  = EXCLUDED."tookPlace",
              "reminder"   = EXCLUDED."reminder",
              "smsSent"    = EXCLUDED."smsSent",
              "updatedAt"  = EXCLUDED."updatedAt"
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

      offset += rows.length;
      console.log(`ClndrApt migrated: ${total} (offset=${offset})`);
    }

    console.log(`✅ ClndrApt migration completed. Total inserted/updated: ${total}`);
    if (skippedInvalidAptNum) {
      console.log(`⚠️ Skipped ${skippedInvalidAptNum} records due to invalid AptNum.`);
    }
    if (skippedMissingUser) {
      console.log(`⚠️ Skipped ${skippedMissingUser} records because corresponding user could not be resolved.`);
    }
    if (skippedMissingDate) {
      console.log(`⚠️ Skipped ${skippedMissingDate} records due to missing appointment date.`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateClndrApt;
