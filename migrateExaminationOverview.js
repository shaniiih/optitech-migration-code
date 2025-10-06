const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function asNumber(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? value : null;
  }
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const normalized = trimmed.replace(/,/g, ".");
  const parsed = Number(normalized);
  return Number.isFinite(parsed) ? parsed : null;
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

async function migrateExaminationOverview(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastCheckDate = new Date(0);
  let lastPerId = -1;
  let total = 0;
  let skippedMissingCustomer = 0;

  try {
    const { rows: customerRows } = await pg.query(
      `SELECT id, "customerId" FROM "Customer" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const customerMap = new Map();
    for (const row of customerRows) {
      for (const key of legacyIdCandidates(row.customerId)) {
        if (!customerMap.has(key)) {
          customerMap.set(key, row.id);
        }
      }
    }

    const examinerMap = new Map();

    while (true) {
      const [rows] = await mysql.query(
        `SELECT PerId, CheckDate, Comments, VAR, VAL, UserId, Pic
           FROM tblCrdOverViews
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
          const date = normalizeDate(row.CheckDate);
          if (!date) {
            continue;
          }

          const candidateIds = legacyIdCandidates(row.PerId);
          let customerId = null;
          for (const key of candidateIds) {
            const mapped = customerMap.get(key);
            if (mapped) {
              customerId = mapped;
              break;
            }
          }

          if (!customerId) {
            skippedMissingCustomer += 1;
            continue;
          }

          const visualAcuityR = asNumber(row.VAR);
          const visualAcuityL = asNumber(row.VAL);

          const examinerId = (() => {
            const candidates = legacyIdCandidates(row.UserId);
            for (const key of candidates) {
              const mapped = examinerMap.get(key);
              if (mapped) return mapped;
            }
            return null;
          })();

          const paramsOffset = params.length;
          values.push(
            `($${paramsOffset + 1}, $${paramsOffset + 2}, $${paramsOffset + 3}, $${paramsOffset + 4}, $${paramsOffset + 5}, $${paramsOffset + 6}, $${paramsOffset + 7}, $${paramsOffset + 8}, $${paramsOffset + 9}, $${paramsOffset + 10}, $${paramsOffset + 11}, $${paramsOffset + 12})`
          );

          params.push(
            uuidv4(),
            tenantId,
            null,
            customerId,
            date,
            examinerId,
            cleanText(row.Comments),
            visualAcuityR,
            visualAcuityL,
            cleanText(row.Pic),
            now,
            now
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "ExaminationOverview" (
              id,
              "tenantId",
              "branchId",
              "customerId",
              "checkDate",
              "examinerId",
              comments,
              "visualAcuityR",
              "visualAcuityL",
              picture,
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              "branchId" = EXCLUDED."branchId",
              "customerId" = EXCLUDED."customerId",
              "checkDate" = EXCLUDED."checkDate",
              "examinerId" = EXCLUDED."examinerId",
              comments = EXCLUDED.comments,
              "visualAcuityR" = EXCLUDED."visualAcuityR",
              "visualAcuityL" = EXCLUDED."visualAcuityL",
              picture = EXCLUDED.picture,
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

      const lastRow = rows[rows.length - 1];
      lastCheckDate = normalizeDate(lastRow.CheckDate) || lastCheckDate;
      lastPerId = lastRow.PerId ?? lastPerId;
      console.log(`ExaminationOverview migrated: ${total} (lastCheckDate=${lastCheckDate.toISOString()}, lastPerId=${lastPerId})`);
    }

    console.log(`✅ ExaminationOverview migration completed. Total inserted/updated: ${total}`);
    if (skippedMissingCustomer) {
      console.log(`⚠️ Skipped ${skippedMissingCustomer} overview rows due to missing customer mapping.`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateExaminationOverview;
