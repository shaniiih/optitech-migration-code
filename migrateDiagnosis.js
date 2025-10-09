const { v4: uuidv4 } = require("uuid");
const { createHash } = require("crypto");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function normalizeDate(value) {
  if (value === null || value === undefined) return null;

  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value;
  }

  if (typeof value === "number") {
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? null : date;
  }

  const str = String(value).trim();
  if (!str) return null;
  if (/^0{4}-0{2}-0{2}/.test(str)) return null;
  const date = new Date(str);
  return Number.isNaN(date.getTime()) ? null : date;
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

async function migrateDiagnosis(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let totalProcessed = 0;
  let skippedMissingCustomer = 0;
  let skippedMissingDate = 0;
  let missingExaminerCount = 0;

  let lastCheckDate = new Date(0);
  let lastPerId = -1;

  try {
    const { rows: customerRows } = await pg.query(
      `SELECT id, "customerId" FROM "Customer" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const customerMap = new Map();
    for (const row of customerRows) {
      const candidates = legacyIdCandidates(row.customerId);
      for (const candidate of candidates) {
        if (!customerMap.has(candidate)) {
          customerMap.set(candidate, row.id);
        }
      }
    }

    const { rows: userRows } = await pg.query(
      `SELECT id, email FROM "User" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const userEmailMap = new Map();
    for (const row of userRows) {
      if (row.email) {
        userEmailMap.set(row.email.toLowerCase(), row.id);
      }
    }

    const [legacyUsers] = await mysql.query(
      `SELECT UserId, CellPhone, HomePhone, UserTz FROM tblUsers`
    );
    const legacyUserMap = new Map();
    for (const legacyUser of legacyUsers) {
      const candidates = legacyIdCandidates(legacyUser.UserId);
      for (const candidate of candidates) {
        if (!legacyUserMap.has(candidate)) {
          legacyUserMap.set(candidate, legacyUser);
        }
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT PerId, CheckDate, UserId, Complaints, illnesses, OptDiag, DocRef, Summary
           FROM tblCrdDiags
          WHERE (CheckDate > ?) OR (CheckDate = ? AND PerId > ?)
          ORDER BY CheckDate, PerId
          LIMIT ${WINDOW_SIZE}`,
        [lastCheckDate, lastCheckDate, lastPerId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();

        for (const row of chunk) {
          const perIdCandidates = legacyIdCandidates(row.PerId);
          if (!perIdCandidates.length) {
            skippedMissingCustomer += 1;
            continue;
          }

          const customerId = perIdCandidates
            .map((candidate) => customerMap.get(candidate))
            .find((value) => value) || null;
          if (!customerId) {
            skippedMissingCustomer += 1;
            continue;
          }

          const diagnosisDate = normalizeDate(row.CheckDate);
          if (!diagnosisDate) {
            skippedMissingDate += 1;
            continue;
          }

          let examinerId = null;
          if (row.UserId !== null && row.UserId !== undefined) {
            const userCandidates = legacyIdCandidates(row.UserId);
            const legacyUser = userCandidates
              .map((candidate) => legacyUserMap.get(candidate))
              .find((value) => value) || null;
            if (legacyUser) {
              const emailCandidates = [
                cleanText(legacyUser.CellPhone)
                  ? `${legacyUser.CellPhone}@legacy.local`.toLowerCase()
                  : null,
                cleanText(legacyUser.HomePhone)
                  ? `${legacyUser.HomePhone}@legacy.local`.toLowerCase()
                  : null,
                cleanText(legacyUser.UserTz)
                  ? `${legacyUser.UserTz}@legacy.local`.toLowerCase()
                  : null,
                `user-${legacyUser.UserId}@legacy.local`,
              ].filter(Boolean);
              examinerId =
                emailCandidates.map((candidate) => userEmailMap.get(candidate)).find((value) => value) ||
                null;
            }
            if (!examinerId) {
              missingExaminerCount += 1;
            }
          }

          const complaints = cleanText(row.Complaints);
          const illnesses = cleanText(row.illnesses);
          const optometricDiagnosis = cleanText(row.OptDiag);
          const doctorReferral = cleanText(row.DocRef);
          const summary = cleanText(row.Summary);

          const createdAt = diagnosisDate || now;
          const updatedAt = diagnosisDate || now;

          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8}, $${offset + 9}, $${offset + 10}, $${offset + 11}, $${offset + 12}, $${offset + 13}, $${offset + 14})`
          );
          params.push(
            uuidv4(),
            tenantId,
            customerId,
            examinerId,
            diagnosisDate,
            complaints,
            illnesses,
            doctorReferral,
            summary,
            null, // icdCode not provided in legacy source
            createdAt,
            updatedAt,
            optometricDiagnosis,
            null // branchId not available in legacy source
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "Diagnosis" (
              id,
              "tenantId",
              "customerId",
              "examinerId",
              "diagnosisDate",
              complaints,
              illnesses,
              "doctorReferral",
              summary,
              "icdCode",
              "createdAt",
              "updatedAt",
              "optometricDiagnosis",
              "branchId"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id) DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              "customerId" = EXCLUDED."customerId",
              "examinerId" = EXCLUDED."examinerId",
              "diagnosisDate" = EXCLUDED."diagnosisDate",
              complaints = EXCLUDED.complaints,
              illnesses = EXCLUDED.illnesses,
              "doctorReferral" = EXCLUDED."doctorReferral",
              summary = EXCLUDED.summary,
              "icdCode" = EXCLUDED."icdCode",
              "optometricDiagnosis" = EXCLUDED."optometricDiagnosis",
              "branchId" = EXCLUDED."branchId",
              "updatedAt" = EXCLUDED."updatedAt"`,
            params
          );
          await pg.query("COMMIT");
          totalProcessed += values.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      const lastRow = rows[rows.length - 1];
      lastCheckDate = lastRow.CheckDate instanceof Date ? lastRow.CheckDate : new Date(lastRow.CheckDate);
      lastPerId = lastRow.PerId ?? lastPerId;
      console.log(
        `Diagnosis migrated so far: ${totalProcessed} (lastCheckDate=${lastCheckDate.toISOString()}, lastPerId=${lastPerId})`
      );
    }

    console.log(`✅ Diagnosis migration completed. Total inserted/updated: ${totalProcessed}`);
    if (skippedMissingCustomer) {
      console.warn(`⚠️ Skipped ${skippedMissingCustomer} diagnosis rows because matching customer was not found.`);
    }
    if (skippedMissingDate) {
      console.warn(`⚠️ Skipped ${skippedMissingDate} diagnosis rows due to invalid or missing CheckDate.`);
    }
    if (missingExaminerCount) {
      console.warn(
        `⚠️ Could not resolve examiner for ${missingExaminerCount} diagnosis rows; they were imported without examiner.`
      );
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateDiagnosis;

