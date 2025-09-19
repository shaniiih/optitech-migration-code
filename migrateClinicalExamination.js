const { createHash } = require("crypto");
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

function buildClinicalId(tenantId, perIdCandidates, examDate, payloadParts) {
  const baseId = perIdCandidates.length ? perIdCandidates[0] : "unknown";
  const datePart = examDate ? examDate.toISOString() : "no-date";
  const fingerprint = [tenantId, baseId, datePart, ...payloadParts.map((p) => p || "")].join("|");
  const hash = createHash("sha1").update(fingerprint).digest("hex");
  return `${tenantId}-clinical-${hash.slice(0, 24)}`;
}

async function migrateClinicalExamination(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;
  let skippedMissingCustomer = 0;
  let missingExaminerCount = 0;

  try {
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
      `SELECT UserId, CellPhone, HomePhone, UserTz FROM tblUsers`
    );
    const legacyUserMap = new Map();
    for (const user of legacyUsers) {
      for (const key of legacyIdCandidates(user.UserId)) {
        if (!legacyUserMap.has(key)) {
          legacyUserMap.set(key, user);
        }
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT PerId, CheckDate, UserId, Complaints, illnesses, OptDiag, DocRef, Summary
           FROM tblCrdDiags
          ORDER BY CheckDate, PerId, UserId
          LIMIT ${WINDOW_SIZE}
          OFFSET ${offset}`
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();

        for (const r of chunk) {
          const perIdCandidates = legacyIdCandidates(r.PerId);
          const customerId = perIdCandidates
            .map((candidate) => customerMap.get(candidate))
            .find((value) => value) || null;
          if (!customerId) {
            skippedMissingCustomer += 1;
            continue;
          }

          let examinerId = null;
          if (r.UserId !== null && r.UserId !== undefined) {
            const legacyUser = legacyIdCandidates(r.UserId)
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
                cleanText(legacyUser.UserTz)
                  ? `${legacyUser.UserTz}@legacy.local`.toLowerCase()
                  : null,
                `user-${legacyUser.UserId}@legacy.local`,
              ].filter(Boolean);
              examinerId = candidates.map((c) => userEmailMap.get(c)).find((v) => v) || null;
            }
            if (!examinerId) {
              missingExaminerCount += 1;
            }
          }

          const examDate = normalizeDate(r.CheckDate) || now;
          const complaints = cleanText(r.Complaints);
          const medicalHistory = cleanText(r.illnesses);
          const optDiag = cleanText(r.OptDiag);
          const docRef = cleanText(r.DocRef);
          const summary = cleanText(r.Summary);

          const noteParts = [];
          if (complaints) noteParts.push(`Complaints: ${complaints}`);
          if (medicalHistory) noteParts.push(`Medical history: ${medicalHistory}`);
          if (optDiag) noteParts.push(`OptDiag: ${optDiag}`);
          if (docRef) noteParts.push(`DocRef: ${docRef}`);
          if (summary) noteParts.push(`Summary: ${summary}`);
          const comments = noteParts.length ? noteParts.join("\n") : null;

          const id = buildClinicalId(tenantId, perIdCandidates, examDate, [complaints, medicalHistory, summary, optDiag, docRef]);

          const columns = [
            id,
            tenantId,
            customerId,
            examinerId,
            examDate,
            comments,
            examDate,
            examDate,
            null,
          ];

          const offsetBase = params.length;
          const placeholders = columns
            .map((_, idx) => `$${offsetBase + idx + 1}`)
            .join(", ");
          values.push(`(${placeholders})`);
          params.push(...columns);
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "ClinicalExamination" (
              id, "tenantId", "customerId", "examinerId", "examDate",
              comments, "createdAt", "updatedAt", "branchId"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              "customerId" = EXCLUDED."customerId",
              "examinerId" = EXCLUDED."examinerId",
              "examDate" = EXCLUDED."examDate",
              comments = EXCLUDED.comments,
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

      offset += rows.length;
      console.log(`Clinical examinations migrated: ${total} (offset=${offset})`);
    }

    console.log(`✅ ClinicalExamination migration completed. Total inserted/updated: ${total}`);
    if (skippedMissingCustomer) {
      console.warn(`⚠️ Skipped ${skippedMissingCustomer} clinical examinations due to missing customers`);
    }
    if (missingExaminerCount) {
      console.warn(`⚠️ Unable to match ${missingExaminerCount} clinical examinations to an examiner`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateClinicalExamination;
