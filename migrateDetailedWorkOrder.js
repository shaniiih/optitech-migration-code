const { createId } = require("@paralleldrive/cuid2");
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
  if (typeof value === "bigint") {
    return Number(value);
  }
  if (Buffer.isBuffer(value)) {
    return asNumber(value.toString("utf8"));
  }
  const trimmed = String(value).trim().replace(/,/g, ".");
  if (!trimmed) return null;
  const num = Number(trimmed);
  return Number.isFinite(num) ? num : null;
}

function asInteger(value) {
  const num = asNumber(value);
  return num === null ? null : Math.trunc(num);
}

function asBool(value) {
  if (value === null || value === undefined) return false;
  if (Buffer.isBuffer(value)) return value.some((b) => b !== 0);
  if (typeof value === "string") {
    const trimmed = value.trim().toLowerCase();
    if (!trimmed) return false;
    return ["1", "true", "yes", "y", "t", "on"].includes(trimmed);
  }
  if (typeof value === "number") {
    return Number.isFinite(value) ? value !== 0 : false;
  }
  return Boolean(value);
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

async function migrateDetailedWorkOrder(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastWorkId = 0;
  let total = 0;
  let skippedInvalidWorkId = 0;
  let skippedMissingCustomer = 0;
  let skippedMissingWorkDate = 0;
  let missingExaminerCount = 0;

  try {
    const { rows: customerRows } = await pg.query(
      `SELECT id, "customerId"
         FROM "Customer"
        WHERE "tenantId" = $1`,
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
      `SELECT UserId, CellPhone, HomePhone, UserTz
         FROM tblUsers`
    );
    const legacyUserMap = new Map();
    for (const user of legacyUsers) {
      const candidates = legacyIdCandidates(user.UserId);
      if (!candidates.length) continue;

      const emailCandidates = [
        cleanText(user.CellPhone) && `${cleanText(user.CellPhone)}@legacy.local`,
        cleanText(user.HomePhone) && `${cleanText(user.HomePhone)}@legacy.local`,
        cleanText(user.UserTz) && `${cleanText(user.UserTz)}@legacy.local`,
        `user-${normalizeLegacyId(user.UserId)}@legacy.local`,
      ]
        .filter(Boolean)
        .map((email) => email.toLowerCase());

      let mappedUserId = null;
      for (const email of emailCandidates) {
        const found = userEmailMap.get(email);
        if (found) {
          mappedUserId = found;
          break;
        }
      }

      if (mappedUserId) {
        for (const candidate of candidates) {
          if (!legacyUserMap.has(candidate)) {
            legacyUserMap.set(candidate, mappedUserId);
          }
        }
      }
    }

    const { rows: branchRows } = await pg.query(
      `SELECT id, code
         FROM "Branch"
        WHERE "tenantId" = $1`,
      [tenantId]
    );
    const branchMap = new Map();
    for (const branch of branchRows) {
      const code = cleanText(branch.code);
      if (!code) continue;
      if (!branchMap.has(code)) {
        branchMap.set(code, branch.id);
      }
      const normalized = normalizeLegacyId(code);
      if (normalized && !branchMap.has(normalized)) {
        branchMap.set(normalized, branch.id);
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT WorkId, WorkDate, PerId, UserId, WorkTypeId, CheckDate, WorkStatId, WorkSupplyId,
                LabId, SapakId, BagNum, PromiseDate, DeliverDate, Comment, FSapakId, FLabelId,
                FModel, FColor, FSize, FrameSold, LnsSapakId, GlassSapakId, ClensSapakId,
                GlassId, Wtype, SMSSent, ItemId, TailId, Canceled
           FROM tblCrdBuysWorks
          WHERE WorkId > ?
          ORDER BY WorkId
          LIMIT ${WINDOW_SIZE}`,
        [lastWorkId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const row of chunk) {
          const workId = asInteger(row.WorkId);
          if (workId === null) {
            skippedInvalidWorkId += 1;
            continue;
          }

          const customerId =
            legacyIdCandidates(row.PerId)
              .map((candidate) => customerMap.get(candidate))
              .find((value) => value) || null;
          if (!customerId) {
            skippedMissingCustomer += 1;
            continue;
          }

          const workDate =
            normalizeDateTime(row.WorkDate) ||
            normalizeDateTime(row.CheckDate) ||
            normalizeDateTime(row.PromiseDate) ||
            normalizeDateTime(row.DeliverDate);
          if (!workDate) {
            skippedMissingWorkDate += 1;
            continue;
          }

          const checkDate = normalizeDateTime(row.CheckDate);
          const promiseDate = normalizeDateTime(row.PromiseDate);
          const deliveryDate = normalizeDateTime(row.DeliverDate);

          const examinerId =
            legacyIdCandidates(row.UserId)
              .map((candidate) => legacyUserMap.get(candidate))
              .find((value) => value) || null;
          if (!examinerId) {
            missingExaminerCount += 1;
          }

          const tailKey = normalizeLegacyId(row.TailId);
          const branchId = tailKey ? branchMap.get(tailKey) || null : null;

          let tailId = null;
          if (row.TailId !== null && row.TailId !== undefined) {
            const tailText = String(row.TailId).trim();
            tailId = tailText.length ? tailText : null;
          }

          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8}, $${offset + 9}, $${offset + 10}, $${offset + 11}, $${offset + 12}, $${offset + 13}, $${offset + 14}, $${offset + 15}, $${offset + 16}, $${offset + 17}, $${offset + 18}, $${offset + 19}, $${offset + 20}, $${offset + 21}, $${offset + 22}, $${offset + 23}, $${offset + 24}, $${offset + 25}, $${offset + 26}, $${offset + 27}, $${offset + 28}, $${offset + 29}, $${offset + 30}, $${offset + 31}, $${offset + 32}, $${offset + 33}, $${offset + 34})`
          );

          params.push(
            createId(),
            tenantId,
            branchId,
            workId,
            workDate,
            customerId,
            examinerId,
            asInteger(row.WorkTypeId),
            checkDate,
            asInteger(row.WorkStatId),
            asInteger(row.WorkSupplyId),
            asInteger(row.LabId),
            asInteger(row.SapakId),
            cleanText(row.BagNum),
            promiseDate,
            deliveryDate,
            asInteger(row.FSapakId),
            asInteger(row.FLabelId),
            cleanText(row.FModel),
            cleanText(row.FColor),
            cleanText(row.FSize),
            asBool(row.FrameSold),
            asInteger(row.LnsSapakId),
            asInteger(row.GlassSapakId),
            asInteger(row.ClensSapakId),
            asNumber(row.GlassId),
            asInteger(row.Wtype),
            asBool(row.SMSSent),
            asNumber(row.ItemId),
            tailId,
            asBool(row.Canceled),
            cleanText(row.Comment),
            workDate,
            deliveryDate || promiseDate || checkDate || workDate
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "DetailedWorkOrder" (
              id,
              "tenantId",
              "branchId",
              "workId",
              "workDate",
              "customerId",
              "examinerId",
              "workTypeId",
              "checkDate",
              "workStatusId",
              "workSupplyId",
              "labId",
              "supplierId",
              "bagNumber",
              "promiseDate",
              "deliveryDate",
              "frameSupplierId",
              "frameLabelId",
              "frameModel",
              "frameColor",
              "frameSize",
              "frameSold",
              "lensSupplierId",
              "glassSupplierId",
              "lensCleanSupplierId",
              "glassId",
              "workType",
              "smsSent",
              "itemId",
              "tailId",
              canceled,
              comments,
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              "branchId" = EXCLUDED."branchId",
              "workId" = EXCLUDED."workId",
              "workDate" = EXCLUDED."workDate",
              "customerId" = EXCLUDED."customerId",
              "examinerId" = EXCLUDED."examinerId",
              "workTypeId" = EXCLUDED."workTypeId",
              "checkDate" = EXCLUDED."checkDate",
              "workStatusId" = EXCLUDED."workStatusId",
              "workSupplyId" = EXCLUDED."workSupplyId",
              "labId" = EXCLUDED."labId",
              "supplierId" = EXCLUDED."supplierId",
              "bagNumber" = EXCLUDED."bagNumber",
              "promiseDate" = EXCLUDED."promiseDate",
              "deliveryDate" = EXCLUDED."deliveryDate",
              "frameSupplierId" = EXCLUDED."frameSupplierId",
              "frameLabelId" = EXCLUDED."frameLabelId",
              "frameModel" = EXCLUDED."frameModel",
              "frameColor" = EXCLUDED."frameColor",
              "frameSize" = EXCLUDED."frameSize",
              "frameSold" = EXCLUDED."frameSold",
              "lensSupplierId" = EXCLUDED."lensSupplierId",
              "glassSupplierId" = EXCLUDED."glassSupplierId",
              "lensCleanSupplierId" = EXCLUDED."lensCleanSupplierId",
              "glassId" = EXCLUDED."glassId",
              "workType" = EXCLUDED."workType",
              "smsSent" = EXCLUDED."smsSent",
              "itemId" = EXCLUDED."itemId",
              "tailId" = EXCLUDED."tailId",
              canceled = EXCLUDED.canceled,
              comments = EXCLUDED.comments,
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

      lastWorkId = rows[rows.length - 1].WorkId;
      console.log(`DetailedWorkOrder migrated so far: ${total} (lastWorkId=${lastWorkId})`);
    }

    console.log(`✅ DetailedWorkOrder migration completed. Total inserted/updated: ${total}`);
    if (skippedInvalidWorkId) {
      console.warn(`⚠️ Skipped ${skippedInvalidWorkId} rows due to invalid WorkId.`);
    }
    if (skippedMissingCustomer) {
      console.warn(`⚠️ Skipped ${skippedMissingCustomer} rows due to missing customer mapping.`);
    }
    if (skippedMissingWorkDate) {
      console.warn(`⚠️ Skipped ${skippedMissingWorkDate} rows due to missing work date.`);
    }
    if (missingExaminerCount) {
      console.warn(`⚠️ Unable to resolve ${missingExaminerCount} work orders to a user; inserted with null examinerId.`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateDetailedWorkOrder;
