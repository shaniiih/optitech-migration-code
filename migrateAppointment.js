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
    return String(value);
  }

  if (typeof value === "bigint") {
    return value.toString();
  }

  if (Buffer.isBuffer(value)) {
    return normalizeLegacyId(value.toString("utf8"));
  }

  const trimmed = String(value).trim();
  if (!trimmed) return null;

  // Treat numeric-looking identifiers uniformly (handles 000123, 123.0, etc.)
  if (/^[+-]?\d+(?:\.0+)?$/.test(trimmed)) {
    return String(parseInt(trimmed, 10));
  }

  return trimmed.toLowerCase();
}

function legacyIdCandidates(value) {
  const normalized = normalizeLegacyId(value);
  if (!normalized) return [];

  const candidates = new Set([normalized]);
  if (/\D/.test(normalized)) {
    const digitsOnly = normalized.replace(/\D+/g, "");
    if (digitsOnly) {
      const numericCandidate = normalizeLegacyId(digitsOnly);
      if (numericCandidate) {
        candidates.add(numericCandidate);
      }
    }
  }

  return Array.from(candidates);
}

function normalizeDate(value) {
  if (value === null || value === undefined) return null;

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

  if (typeof value === "number") {
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  return null;
}

function durationInMinutes(start, end) {
  if (!start || !end) return null;
  const diffMs = end.getTime() - start.getTime();
  if (!Number.isFinite(diffMs) || diffMs <= 0) return null;
  return Math.round(diffMs / 60000);
}

async function migrateAppointment(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  let skippedMissingCustomer = 0;
  let skippedMissingUser = 0;
  const missingCustomerSamples = new Set();

  const customerLoaderCache = new Map();

  try {
    await pg.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_indexes WHERE indexname = 'appointment_tenant_apt_ux'
        ) THEN
          CREATE UNIQUE INDEX appointment_tenant_apt_ux
          ON "Appointment" ("tenantId", id);
        END IF;
      END$$;
    `);

    const { rows: customerRows } = await pg.query(
      `SELECT id, "customerId" FROM "Customer" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const customerMap = new Map();
    for (const c of customerRows) {
      for (const key of legacyIdCandidates(c.customerId)) {
        if (!customerMap.has(key)) {
          customerMap.set(key, c.id);
        }
      }
    }

    async function ensureCustomer(legacyPerIdCandidates) {
      const existing = legacyPerIdCandidates
        .map((candidate) => customerMap.get(candidate))
        .find((value) => value);
      if (existing) return existing;

      const canonicalId =
        legacyPerIdCandidates.find((id) => /^\d+$/.test(id)) ||
        legacyPerIdCandidates.find((id) => id) ||
        null;
      if (!canonicalId) return null;

      if (!customerLoaderCache.has(canonicalId)) {
        customerLoaderCache.set(
          canonicalId,
          (async () => {
            const { rows: existingRows } = await pg.query(
              `SELECT id FROM "Customer" WHERE "tenantId" = $1 AND "customerId" = $2 LIMIT 1`,
              [tenantId, canonicalId]
            );
            if (existingRows.length) {
              const foundId = existingRows[0].id;
              for (const candidate of legacyPerIdCandidates) {
                if (candidate) customerMap.set(candidate, foundId);
              }
              customerMap.set(canonicalId, foundId);
              return foundId;
            }

            return null;
          })()
        );
      }

      const resolvedId = await customerLoaderCache.get(canonicalId);
      if (resolvedId) {
        for (const candidate of legacyPerIdCandidates) {
          if (candidate) customerMap.set(candidate, resolvedId);
        }
        customerMap.set(canonicalId, resolvedId);
      }
      return resolvedId;
    }

    const { rows: userRows } = await pg.query(
      `SELECT id, email FROM "User" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const userEmailMap = new Map(
      userRows
        .filter((u) => u.email)
        .map((u) => [u.email.toLowerCase(), u.id])
    );

    const [legacyUsers] = await mysql.query(
      `SELECT UserId, CellPhone, HomePhone, UserTz
         FROM tblUsers`
    );
    const legacyUserMap = new Map();
    for (const u of legacyUsers) {
      for (const key of legacyIdCandidates(u.UserId)) {
        if (!legacyUserMap.has(key)) {
          legacyUserMap.set(key, u);
        }
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT UserID, AptDate, AptNum, StarTime, EndTime, AptDesc, PerID, TookPlace, Reminder, SMSSent
           FROM tblClndrApt
          WHERE AptNum > ?
          ORDER BY AptNum
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
          const legacyPerIdCandidates = legacyIdCandidates(r.PerID);
          if (!legacyPerIdCandidates.length) {
            skippedMissingCustomer += 1;
            continue;
          }

          const customerId = await ensureCustomer(legacyPerIdCandidates);
          if (!customerId) {
            skippedMissingCustomer += 1;
            if (legacyPerIdCandidates.length && missingCustomerSamples.size < 10) {
              missingCustomerSamples.add(legacyPerIdCandidates[0]);
            }
            continue;
          }

          let userId = null;
          if (r.UserID != null && r.UserID != 0) {
            const legacyUser = legacyIdCandidates(r.UserID)
              .map((candidate) => legacyUserMap.get(candidate))
              .find((value) => value) || null;
            if (legacyUser) {
              const candidates = [
                cleanText(legacyUser.CellPhone)
                  ? `${legacyUser.CellPhone}@legacy.local`.toLowerCase()
                  : null,
                cleanText(legacyUser.HomePhone)
                  ? `${legacyUser.HomePhone}@legacy.local`.toLowerCase()
                  : null,
                cleanText(legacyUser.UserTz) ? `${legacyUser.UserTz}@legacy.local`.toLowerCase() : null,
                `user-${legacyUser.UserId}@legacy.local`,
              ].filter(Boolean);
              userId = candidates.map((c) => userEmailMap.get(c)).find((v) => v) || null;
            }
            if (!userId) {
              skippedMissingUser += 1;
            }
          }

          const startTime = normalizeDate(r.StarTime) || normalizeDate(r.AptDate);
          const endTime = normalizeDate(r.EndTime);
          const appointmentDate = normalizeDate(r.AptDate);
          const duration = durationInMinutes(startTime, endTime) || 30;
          const status = r.TookPlace ? "COMPLETED" : "SCHEDULED";
          const reminderSent = Boolean(r.SMSSent);
          
          const createdAt = appointmentDate;
          const updatedAt = appointmentDate;

          const columns = [
            uuidv4(),
            tenantId,
            customerId,
            userId,
            appointmentDate,
            duration,
            "EXAM",
            status,
            cleanText(r.AptDesc),
            reminderSent,
            createdAt,
            updatedAt,
            null,
          ];

          const offset = params.length;
          const placeholders = columns.map((_, idx) => `$${offset + idx + 1}`).join(", ");
          values.push(`(${placeholders})`);
          params.push(...columns);
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "Appointment" (
              id, "tenantId", "customerId", "userId", date, duration, type, status, notes,
              "reminderSent", "createdAt", "updatedAt", "branchId"
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
              "updatedAt" = EXCLUDED."updatedAt",
              "branchId" = EXCLUDED."branchId"
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }

        total += values.length;
      }

      lastId = rows[rows.length - 1].AptNum;
      console.log(`Appointments migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ Appointment migration completed. Total inserted/updated: ${total}`);
    if (skippedMissingCustomer) {
      console.warn(`⚠️ Skipped ${skippedMissingCustomer} appointments due to missing customers`);
      if (missingCustomerSamples.size) {
        console.warn(
          `⚠️ Example legacy customer IDs with no match: ${Array.from(missingCustomerSamples).join(", ")}`
        );
      }
    }
    if (skippedMissingUser) {
      console.warn(`⚠️ Unable to match ${skippedMissingUser} appointments to a doctor/user`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateAppointment;
