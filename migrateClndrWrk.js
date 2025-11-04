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

async function migrateClndrWrk(tenantId = "tenant_1", rawDefaultBranchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastWrkId = 0;
  let total = 0;
  let skippedInvalidWrkId = 0;
  let skippedMissingUser = 0;
  let skippedMissingDate = 0;

  try {
    // Unique index creation moved to Prisma schema/migrations. Leaving disabled to avoid conflicts.
    // await pg.query(`
    //   DO $$
    //   BEGIN
    //     IF NOT EXISTS (
    //       SELECT 1
    //       FROM pg_indexes
    //       WHERE indexname = 'clndrwrk_tenant_wrkid_ux'
    //     ) THEN
    //       CREATE UNIQUE INDEX clndrwrk_tenant_wrkid_ux
    //       ON "ClndrWrk" ("tenantId", "wrkId");
    //     END IF;
    //   END$$;
    // `);

    const defaultBranchId = cleanText(rawDefaultBranchId);

    const { rows: userRows } = await pg.query(
      `SELECT id, email, "branchId", "userId"
         FROM "User"
        WHERE "tenantId" = $1`,
      [tenantId]
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

    while (true) {
      const [rows] = await mysql.query(
        `SELECT WrkId, UserID, WrkDate, WrkTime, StartTime, EndTime
           FROM tblClndrWrk
          WHERE WrkId > ?
          ORDER BY WrkId
          LIMIT ${WINDOW_SIZE}`,
        [lastWrkId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const row of chunk) {
          const wrkIdInt = asInteger(row.WrkId);
          if (wrkIdInt === null) {
            skippedInvalidWrkId += 1;
            continue;
          }

          const wrkDate = normalizeDateTime(row.WrkDate);
          if (!wrkDate) {
            skippedMissingDate += 1;
            continue;
          }

          const userLegacyId = asInteger(row.UserID);
          if (userLegacyId === null) {
            skippedMissingUser += 1;
            continue;
          }

          let userInfo = null;
          for (const candidate of legacyIdCandidates(userLegacyId)) {
            const found = userIdMap.get(candidate);
            if (found) {
              userInfo = found;
              break;
            }
          }
          if (!userInfo) {
            skippedMissingUser += 1;
            continue;
          }
          if (!userInfo.id) {
            skippedMissingUser += 1;
            continue;
          }

          const startTime = normalizeDateTime(row.StartTime);
          const endTime = normalizeDateTime(row.EndTime);
          const wrkTime = asNumber(row.WrkTime);
          const createdAt = chooseTimestamp(startTime, wrkDate);
          const updatedAt = chooseTimestamp(endTime, createdAt);

          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8}, $${offset + 9}, $${offset + 10}, $${offset + 11})`
          );

          params.push(
            uuidv4(), // id
            tenantId,
            userInfo.branchId || defaultBranchId || null,
            wrkIdInt,
            userInfo.id,
            wrkDate,
            wrkTime !== null ? wrkTime : null,
            startTime,
            endTime,
            createdAt,
            updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "ClndrWrk" (
              id,
              "tenantId",
              "branchId",
              "wrkId",
              "userId",
              "wrkDate",
              "wrkTime",
              "startTime",
              "endTime",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "wrkId")
            DO UPDATE SET
              "branchId" = EXCLUDED."branchId",
              "userId" = EXCLUDED."userId",
              "wrkDate" = EXCLUDED."wrkDate",
              "wrkTime" = EXCLUDED."wrkTime",
              "startTime" = EXCLUDED."startTime",
              "endTime" = EXCLUDED."endTime",
              "updatedAt" = EXCLUDED."updatedAt"
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

      lastWrkId = rows[rows.length - 1].WrkId;
      console.log(
        `ClndrWrk migrated: ${total} (lastWrkId=${lastWrkId})`
      );
    }

    console.log(`✅ ClndrWrk migration completed. Total inserted/updated: ${total}`);
    if (skippedInvalidWrkId) {
      console.log(`⚠️ Skipped ${skippedInvalidWrkId} records due to invalid WrkId.`);
    }
    if (skippedMissingUser) {
      console.log(`⚠️ Skipped ${skippedMissingUser} records because corresponding user could not be resolved.`);
    }
    if (skippedMissingDate) {
      console.log(`⚠️ Skipped ${skippedMissingDate} records due to missing work date.`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateClndrWrk;
