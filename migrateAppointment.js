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

  const trimmed = String(value).trim();
  if (!trimmed) return null;

  if (/^[+-]?\d+(?:\.0+)?$/.test(trimmed)) {
    return String(parseInt(trimmed, 10));
  }

  return trimmed;
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

function asBool(value) {
  if (value === null || value === undefined) return false;
  if (Buffer.isBuffer(value)) return value.some((b) => b !== 0);
  if (typeof value === "string") {
    const trimmed = value.trim().toLowerCase();
    if (!trimmed) return false;
    return ["1", "true", "yes", "y"].includes(trimmed);
  }
  return Boolean(value);
}

async function migrateAppointment(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastAptNum = 0;
  let total = 0;
  let skippedMissingCustomer = 0;
  let skippedInvalidId = 0;
  let skippedMissingDate = 0;
  let missingUserCount = 0;

  try {
    const { rows: customerRows } = await pg.query(
      `SELECT id, "customerId"
         FROM "Customer"
        WHERE "tenantId" = $1`,
      [tenantId]
    );
    const customerMap = new Map();
    for (const row of customerRows) {
      const key = normalizeLegacyId(row.customerId);
      if (key && !customerMap.has(key)) {
        customerMap.set(key, row.id);
      }
    }

    const { rows: userRows } = await pg.query(
      `SELECT id, email
         FROM "User"
        WHERE "tenantId" = $1`,
      [tenantId]
    );
    const userEmailMap = new Map(
      userRows
        .filter((u) => cleanText(u.email))
        .map((u) => [u.email.toLowerCase(), u.id])
    );

    const [legacyUsers] = await mysql.query(
      `SELECT UserId, CellPhone, HomePhone
         FROM tblUsers`
    );
    const userMap = new Map();
    for (const user of legacyUsers) {
      const legacyId = normalizeLegacyId(user.UserId);
      if (!legacyId || userMap.has(legacyId)) continue;

      const cell = cleanText(user.CellPhone);
      const home = cleanText(user.HomePhone);
      const emailCandidate =
        (cell && `${cell}@legacy.local`) ||
        (home && `${home}@legacy.local`) ||
        `user-${legacyId}@legacy.local`;
      const normalizedEmail = emailCandidate.toLowerCase();
      const userId = userEmailMap.get(normalizedEmail) || null;
      if (userId) {
        userMap.set(legacyId, userId);
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT AptNum, PerID, UserID, AptDate, StarTime, EndTime, AptDesc, TookPlace, Reminder, SMSSent
           FROM tblClndrApt
          WHERE AptNum > ?
          ORDER BY AptNum
          LIMIT ${WINDOW_SIZE}`,
        [lastAptNum]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const row of chunk) {
          const aptNum = normalizeLegacyId(row.AptNum);
          if (!aptNum) {
            skippedInvalidId += 1;
            continue;
          }

          const customerKey = normalizeLegacyId(row.PerID);
          if (!customerKey) {
            skippedMissingCustomer += 1;
            continue;
          }
          const customerId = customerMap.get(customerKey);
          if (!customerId) {
            skippedMissingCustomer += 1;
            continue;
          }

          const startTime = normalizeDateTime(row.StarTime) || normalizeDateTime(row.AptDate);
          if (!startTime) {
            skippedMissingDate += 1;
            continue;
          }
          const endTime = normalizeDateTime(row.EndTime);
          let durationMinutes = 30;
          if (endTime) {
            const diffMinutes = Math.round((endTime.getTime() - startTime.getTime()) / 60000);
            if (Number.isFinite(diffMinutes) && diffMinutes > 0) {
              durationMinutes = diffMinutes;
            }
          }

          const userKey = normalizeLegacyId(row.UserID);
          let userId = null;
          if (userKey) {
            userId = userMap.get(userKey) || null;
            if (!userId) {
              missingUserCount += 1;
            }
          }

          const notes = cleanText(row.AptDesc);
          const reminderSent = asBool(row.Reminder);
          const smsSent = asBool(row.SMSSent);
          const tookPlace = asBool(row.TookPlace);
          const status = tookPlace ? "COMPLETED" : "SCHEDULED";
          const createdAt = startTime;
          const updatedAt = startTime;

          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8}, $${offset + 9}, $${offset + 10}, $${offset + 11}, $${offset + 12}, $${offset + 13}, $${offset + 14}, $${offset + 15})`
          );
          params.push(
            uuidv4(),
            tenantId,
            customerId,
            userId,
            startTime,
            durationMinutes,
            "EXAM",
            status,
            notes,
            reminderSent,
            smsSent,
            tookPlace ? 1 : 0,
            createdAt,
            updatedAt,
            null
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "Appointment" (
              id,
              "tenantId",
              "customerId",
              "userId",
              date,
              duration,
              type,
              status,
              notes,
              "reminderSent",
              "SMSSent",
              "TookPlace",
              "createdAt",
              "updatedAt",
              "branchId"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              "customerId" = EXCLUDED."customerId",
              "userId" = EXCLUDED."userId",
              date = EXCLUDED.date,
              duration = EXCLUDED.duration,
              type = EXCLUDED.type,
              status = EXCLUDED.status,
              notes = EXCLUDED.notes,
              "reminderSent" = EXCLUDED."reminderSent",
              "SMSSent" = EXCLUDED."SMSSent",
              "TookPlace" = EXCLUDED."TookPlace",
              "updatedAt" = EXCLUDED."updatedAt",
              "branchId" = EXCLUDED."branchId"
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

      lastAptNum = Number(rows[rows.length - 1].AptNum) || lastAptNum;
      console.log(`Appointment migrated so far: ${total} (lastAptNum=${lastAptNum})`);
    }

    console.log(`✅ Appointment migration completed. Total inserted/updated: ${total}`);
    if (skippedInvalidId) {
      console.warn(`⚠️ Skipped ${skippedInvalidId} appointments due to invalid AptNum.`);
    }
    if (skippedMissingCustomer) {
      console.warn(`⚠️ Skipped ${skippedMissingCustomer} appointments due to missing customer mapping.`);
    }
    if (skippedMissingDate) {
      console.warn(`⚠️ Skipped ${skippedMissingDate} appointments due to invalid start date.`);
    }
    if (missingUserCount) {
      console.warn(`⚠️ Unable to resolve ${missingUserCount} appointments to a user; inserted with null userId.`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateAppointment;

