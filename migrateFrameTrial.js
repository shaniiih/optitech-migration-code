const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function normalizeDateTime(value) {
  if (value === null || value === undefined) return null;
  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value;
  }
  if (Buffer.isBuffer(value)) {
    return normalizeDateTime(value.toString("utf8"));
  }
  const trimmed = cleanText(value);
  if (!trimmed) return null;
  if (/^0{4}-0{2}-0{2}/.test(trimmed)) return null;
  const parsed = new Date(trimmed);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  if (typeof value === "bigint") {
    return Number(value);
  }
  if (Buffer.isBuffer(value)) {
    return asInteger(value.toString("utf8"));
  }
  const trimmed = cleanText(value);
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
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
  const set = new Set([normalized]);
  if (/\D/.test(normalized)) {
    const digitsOnly = normalized.replace(/\D+/g, "");
    if (digitsOnly) {
      const numericCandidate = normalizeLegacyId(digitsOnly);
      if (numericCandidate) {
        set.add(numericCandidate);
      }
    }
  }
  return Array.from(set);
}

async function loadCustomerMap(pg, tenantId) {
  const { rows } = await pg.query(
    `SELECT id, "customerId"
       FROM "Customer"
      WHERE "tenantId" = $1`,
    [tenantId]
  );

  const map = new Map();
  for (const row of rows) {
    const candidates = legacyIdCandidates(row.customerId);
    for (const candidate of candidates) {
      if (!map.has(candidate)) {
        map.set(candidate, row.id);
      }
    }
  }
  return map;
}

async function loadWorkSupplierMap(pg, tenantId) {
  const { rows } = await pg.query(
    `SELECT id, "supplierId"
       FROM "WorkSupplier"
      WHERE "tenantId" = $1`,
    [tenantId]
  );
  const map = new Map();
  for (const row of rows) {
    const supplierId = asInteger(row.supplierId);
    if (supplierId === null) continue;
    map.set(supplierId, row.id);
  }
  return map;
}

async function loadWorkLabelMap(pg, tenantId) {
  const { rows } = await pg.query(
    `SELECT id, "labelId"
       FROM "WorkLabel"
      WHERE "tenantId" = $1`,
    [tenantId]
  );
  const map = new Map();
  for (const row of rows) {
    const labelId = asInteger(row.labelId);
    if (labelId === null) continue;
    map.set(labelId, row.id);
  }
  return map;
}

async function migrateFrameTrial(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let totalProcessed = 0;
  let insertedOrUpdated = 0;
  let skippedInvalidCustomer = 0;
  let skippedInvalidDate = 0;

  let lastPerId = -1;
  let lastCheckDate = new Date(0);
  let lastGlassId = -1;

  try {
    const customerMap = await loadCustomerMap(pg, tenantId);
    if (!customerMap.size) {
      console.warn(
        `⚠️ No customers found for tenant ${tenantId}. FrameTrial migration will skip all rows.`
      );
    }
    const workSupplierMap = await loadWorkSupplierMap(pg, tenantId);
    const workLabelMap = await loadWorkLabelMap(pg, tenantId);

    while (true) {
      const [rows] = await mysql.query(
        `SELECT PerId, CheckDate, GlassId, FSapakId, FLabelId, FModel, FColor, FSize, Comments
           FROM tblCrdGlassChecksFrm
          WHERE (PerId, CheckDate, GlassId) > (?, ?, ?)
          ORDER BY PerId, CheckDate, GlassId
          LIMIT ${WINDOW_SIZE}`,
        [lastPerId, lastCheckDate, lastGlassId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const row of chunk) {
          totalProcessed += 1;

          const perId = row.PerId;
          const checkDate = normalizeDateTime(row.CheckDate);
          if (!checkDate) {
            skippedInvalidDate += 1;
            continue;
          }

          let customerId = null;
          const candidates = legacyIdCandidates(perId);
          for (const candidate of candidates) {
            customerId = customerMap.get(candidate);
            if (customerId) break;
          }
          if (!customerId) {
            skippedInvalidCustomer += 1;
            continue;
          }

          const frameSupplierLegacyId = asInteger(row.FSapakId);
          const frameSupplierId =
            frameSupplierLegacyId !== null
              ? workSupplierMap.get(frameSupplierLegacyId) ?? null
              : null;
          const frameLabelLegacyId = asInteger(row.FLabelId);
          const frameBrandId =
            frameLabelLegacyId !== null
              ? workLabelMap.get(frameLabelLegacyId) ?? null
              : null;
          const frameModel = cleanText(row.FModel);
          const frameColor = cleanText(row.FColor);
          const frameSize = cleanText(row.FSize);
          const notes = cleanText(row.Comments);
          const timestamp = new Date();

          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8}, $${offset + 9}, $${offset + 10}, $${offset + 11}, $${offset + 12}, $${offset + 13}, $${offset + 14}, $${offset + 15}, $${offset + 16})`
          );
          params.push(
            createId(),
            tenantId,
            customerId,
            null, // examinationId currently unavailable
            checkDate,
            frameSupplierId,
            frameBrandId,
            frameModel,
            frameColor,
            frameSize,
            checkDate, // triedAt
            false, // selected
            notes,
            null, // createdBy
            timestamp,
            timestamp
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "FrameTrial" (
              id,
              "tenantId",
              "customerId",
              "examinationId",
              "checkDate",
              "frameSupplierId",
              "frameBrandId",
              "frameModel",
              "frameColor",
              "frameSize",
              "triedAt",
              selected,
              notes,
              "createdBy",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              "customerId" = EXCLUDED."customerId",
              "examinationId" = EXCLUDED."examinationId",
              "checkDate" = EXCLUDED."checkDate",
              "frameSupplierId" = EXCLUDED."frameSupplierId",
              "frameBrandId" = EXCLUDED."frameBrandId",
              "frameModel" = EXCLUDED."frameModel",
              "frameColor" = EXCLUDED."frameColor",
              "frameSize" = EXCLUDED."frameSize",
              "triedAt" = EXCLUDED."triedAt",
              selected = EXCLUDED.selected,
              notes = EXCLUDED.notes,
              "createdBy" = EXCLUDED."createdBy",
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
          insertedOrUpdated += values.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      const lastRow = rows[rows.length - 1];
      lastPerId = lastRow.PerId ?? lastPerId;
      lastCheckDate = lastRow.CheckDate ?? lastCheckDate;
      lastGlassId = lastRow.GlassId ?? lastGlassId;
      console.log(
        `FrameTrial migrated so far: ${insertedOrUpdated} (lastKey=${lastPerId}/${lastCheckDate}/${lastGlassId})`
      );
    }

    console.log(
      `✅ FrameTrial migration completed. Total inserted/updated: ${insertedOrUpdated} (processed ${totalProcessed})`
    );
    if (skippedInvalidCustomer) {
      console.warn(
        `⚠️ Skipped ${skippedInvalidCustomer} frame trials because the customer could not be resolved.`
      );
    }
    if (skippedInvalidDate) {
      console.warn(
        `⚠️ Skipped ${skippedInvalidDate} frame trials due to missing or invalid CheckDate values.`
      );
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateFrameTrial;

