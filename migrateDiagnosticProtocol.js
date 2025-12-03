const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

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
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function buildRecordId(tenantId, protocolId, occurrence) {
  return occurrence === 0
    ? `${tenantId}-diagnostic-protocol-${protocolId}`
    : `${tenantId}-diagnostic-protocol-${protocolId}-${occurrence}`;
}

function resolveUniqueName(baseName, protocolId, occurrence, usedNames) {
  let attempt = 0;
  while (true) {
    let candidate;
    if (attempt === 0) {
      candidate = baseName;
    } else if (attempt === 1) {
      candidate = `${baseName} (${protocolId}${occurrence > 0 ? `-${occurrence}` : ""})`;
    } else {
      candidate = `${baseName} (${protocolId}${occurrence > 0 ? `-${occurrence}` : ""}-${attempt - 1})`;
    }
    if (!usedNames.has(candidate)) {
      return candidate;
    }
    attempt += 1;
  }
}

function parseExistingRecordId(tenantId, recordId) {
  if (!recordId || typeof recordId !== "string") return null;
  if (!recordId.startsWith(`${tenantId}-diagnostic-protocol-`)) return null;
  const suffix = recordId.slice(`${tenantId}-diagnostic-protocol-`.length);
  if (!suffix) return null;
  const parts = suffix.split("-");
  const protocolId = Number(parts[0]);
  if (!Number.isFinite(protocolId)) return null;
  const occurrence = parts.length > 1 ? Number(parts[1]) : 0;
  if (parts.length > 1 && !Number.isFinite(occurrence)) return null;
  return { protocolId, occurrence: Math.max(0, occurrence) };
}

async function loadCategoryMap(pg, tenantId) {
  const res = await pg.query(
    `SELECT id, "lensTypeId"
       FROM "ContactLensType"
      WHERE "tenantId" = $1`,
    [tenantId]
  );

  const map = new Map();
  for (const row of res.rows) {
    if (row.lensTypeId === null || row.id === null) continue;
    map.set(Number(row.lensTypeId), row.id);
  }
  return map;
}

async function loadExistingProtocols(pg, tenantId) {
  const res = await pg.query(
    `SELECT id, name
       FROM "DiagnosticProtocol"
      WHERE "tenantId" = $1`,
    [tenantId]
  );

  const usedNames = new Set();
  const existingQueues = new Map(); // protocolId -> [{ occurrence, id, name }]
  const nextOccurrence = new Map(); // protocolId -> next occurrence index for new records

  for (const row of res.rows) {
    if (row.name) {
      usedNames.add(row.name);
    }
    const parsed = parseExistingRecordId(tenantId, row.id);
    if (!parsed) continue;

    const list = existingQueues.get(parsed.protocolId) ?? [];
    list.push({
      occurrence: parsed.occurrence,
      id: row.id,
      name: row.name ?? null,
    });
    existingQueues.set(parsed.protocolId, list);

    const next = Math.max(nextOccurrence.get(parsed.protocolId) ?? 0, parsed.occurrence + 1);
    nextOccurrence.set(parsed.protocolId, next);
  }

  for (const list of existingQueues.values()) {
    list.sort((a, b) => a.occurrence - b.occurrence);
  }

  return { usedNames, existingQueues, nextOccurrence };
}

async function migrateDiagnosticProtocol(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;
  let skippedInvalidId = 0;
  let skippedNoCategory = 0;

  try {
    const categoryMap = await loadCategoryMap(pg, tenantId);
    if (!categoryMap.size) {
      console.warn(
        `⚠️ ContactLensType records not found for tenant ${tenantId}. DiagnosticProtocol migration will skip all rows.`
      );
    }

    const { usedNames, existingQueues, nextOccurrence } = await loadExistingProtocols(
      pg,
      tenantId
    );

    while (true) {
      const [rows] = await mysql.query(
        `SELECT EyeCheckCharId, EyeCheckCharName, EyeCheckCharType
           FROM tblCrdClinicChars
          WHERE EyeCheckCharId > ?
          ORDER BY EyeCheckCharId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();

        for (const row of chunk) {
          const protocolId = asInteger(row.EyeCheckCharId);
          if (protocolId === null) {
            skippedInvalidId += 1;
            continue;
          }

          const typeId = asInteger(row.EyeCheckCharType);
          const categoryId = typeId !== null ? categoryMap.get(typeId) : null;
          if (!categoryId) {
            skippedNoCategory += 1;
            continue;
          }

          let recordId;
          let occurrence;
          let existingName = null;

          const queue = existingQueues.get(protocolId);
          if (queue && queue.length) {
            const existing = queue.shift();
            recordId = existing.id;
            occurrence = existing.occurrence;
            existingName = existing.name;
          } else {
            occurrence = nextOccurrence.get(protocolId) ?? 0;
            recordId = buildRecordId(tenantId, protocolId, occurrence);
            nextOccurrence.set(protocolId, occurrence + 1);
          }

          const baseName =
            cleanText(row.EyeCheckCharName) || `Diagnostic Protocol ${protocolId}`;
          const finalName =
            existingName ?? resolveUniqueName(baseName, protocolId, occurrence, usedNames);
          usedNames.add(finalName);

          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}::jsonb, $${offset + 7}::jsonb, $${offset + 8}, $${offset + 9})`
          );
          params.push(
            createId(),
            tenantId,
            finalName,
            categoryId,
            null,
            JSON.stringify([]),
            JSON.stringify([]),
            timestamp,
            timestamp
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "DiagnosticProtocol" (
              id,
              "tenantId",
              name,
              category,
              description,
              "requiredTests",
              "alertConditions",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              name = EXCLUDED.name,
              category = EXCLUDED.category,
              description = EXCLUDED.description,
              "requiredTests" = EXCLUDED."requiredTests",
              "alertConditions" = EXCLUDED."alertConditions",
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      const lastRow = rows[rows.length - 1];
      lastId = asInteger(lastRow.EyeCheckCharId) ?? lastId;
      console.log(`DiagnosticProtocol migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ DiagnosticProtocol migration completed. Total inserted/updated: ${total}`);
    if (skippedInvalidId) {
      console.warn(`⚠️ Skipped ${skippedInvalidId} rows due to invalid EyeCheckCharId.`);
    }
    if (skippedNoCategory) {
      console.warn(
        `⚠️ Skipped ${skippedNoCategory} rows because no matching ContactLensType category was found.`
      );
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateDiagnosticProtocol;

