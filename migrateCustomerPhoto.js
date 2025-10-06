const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function parseDateTime(value) {
  if (!value) return null;
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
}

function resolveFilePath(fileName, legacyId) {
  if (!fileName) {
    return `legacy/customer_photos/legacy_photo_${legacyId}`;
  }
  if (fileName.includes("/")) {
    return fileName;
  }
  return `legacy/customer_photos/${fileName}`;
}

function buildCustomerIdCandidates(rawId) {
  const normalized = cleanText(rawId);
  if (!normalized) return [];

  const candidates = new Set([normalized]);
  const numericValue = Number(normalized);
  if (Number.isFinite(numericValue)) {
    candidates.add(String(numericValue));
  }

  return Array.from(candidates);
}

async function ensureCustomerRecord({
  tenantId,
  legacyCustomerId,
  pg,
  customerIdMap,
  customerLookupCache
}) {
  if (legacyCustomerId === null || legacyCustomerId === undefined) {
    return null;
  }

  const candidates = buildCustomerIdCandidates(String(legacyCustomerId));
  if (!candidates.length) return null;

  for (const candidate of candidates) {
    if (customerIdMap.has(candidate)) {
      return customerIdMap.get(candidate);
    }
  }

  for (const candidate of candidates) {
    if (!customerLookupCache.has(candidate)) {
      customerLookupCache.set(
        candidate,
        (async () => {
          const { rows } = await pg.query(
            'SELECT id FROM "Customer" WHERE "tenantId" = $1 AND "customerId" = $2 LIMIT 1',
            [tenantId, candidate]
          );
          return rows.length ? rows[0].id : null;
        })()
      );
    }

    const resolved = await customerLookupCache.get(candidate);
    if (resolved) {
      for (const alias of candidates) {
        customerIdMap.set(alias, resolved);
      }
      return resolved;
    }
  }

  return null;
}

async function migrateCustomerPhoto(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  const skippedRecords = { count: 0, examples: new Set() };

  try {
    const customerRes = await pg.query(
      'SELECT id, "customerId" FROM "Customer" WHERE "tenantId" = $1',
      [tenantId]
    );
    const customerIdMap = new Map();
    const customerLookupCache = new Map();
    for (const row of customerRes.rows) {
      if (row.customerId === null || row.customerId === undefined) continue;
      const key = cleanText(String(row.customerId));
      if (!key) continue;
      customerIdMap.set(key, row.id);

      const numericKey = Number(key);
      if (Number.isFinite(numericKey)) {
        const normalizedNumericKey = String(numericKey);
        if (normalizedNumericKey !== key) {
          customerIdMap.set(normalizedNumericKey, row.id);
        }
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT PerPicId, PerId, PicFileName, Description, ScanDate, Notes, IsCon
           FROM tblPerPicture
          WHERE PerPicId > ?
          ORDER BY PerPicId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const r of chunk) {
          const legacyPhotoId = String(r.PerPicId);
          const legacyCustomerId =
            r.PerId !== null && r.PerId !== undefined ? String(r.PerId) : null;

          const customerId = await ensureCustomerRecord({
            tenantId,
            legacyCustomerId,
            pg,
            customerIdMap,
            customerLookupCache
          });

          if (!customerId) {
            skippedRecords.count += 1;
            const exampleKey =
              legacyCustomerId !== null && legacyCustomerId !== undefined
                ? cleanText(legacyCustomerId) || String(legacyCustomerId)
                : `PHOTO_${legacyPhotoId}`;
            if (skippedRecords.examples.size < 10) {
              skippedRecords.examples.add(exampleKey);
            }
            continue;
          }

          const fileName = cleanText(r.PicFileName) || `legacy_photo_${legacyPhotoId}`;
          const filePath = resolveFilePath(cleanText(r.PicFileName), legacyPhotoId);
          const photoType = cleanText(r.Description) || "LEGACY";
          const notes = cleanText(r.Notes);
          const scanDate = parseDateTime(r.ScanDate);
          const timestamp = scanDate || new Date();

          const descriptionParts = [];
          if (notes) descriptionParts.push(notes);
          if (r.IsCon !== null && r.IsCon !== undefined) {
            descriptionParts.push(`LegacyIsCon=${r.IsCon ? 1 : 0}`);
          }
          const description = descriptionParts.length ? descriptionParts.join(" | ") : null;

          const rowParams = [
            uuidv4(), // id
            tenantId, // tenantId
            customerId, // customerId
            photoType, // photoType
            fileName, // fileName
            filePath, // filePath
            null, // fileSize (not available)
            null, // mimeType (not tracked)
            description, // description
            true, // isActive
            timestamp, // createdAt
            timestamp // updatedAt
          ];

          const placeholderStart = params.length + 1;
          const placeholders = Array.from(
            { length: rowParams.length },
            (_, idx) => `$${placeholderStart + idx}`
          );
          values.push(`(${placeholders.join(", ")})`);
          params.push(...rowParams);
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "CustomerPhoto" (
              id, "tenantId", "customerId", "photoType", "fileName", "filePath",
              "fileSize", "mimeType", description, "isActive", "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              "customerId" = EXCLUDED."customerId",
              "photoType" = EXCLUDED."photoType",
              "fileName" = EXCLUDED."fileName",
              "filePath" = EXCLUDED."filePath",
              "fileSize" = EXCLUDED."fileSize",
              "mimeType" = EXCLUDED."mimeType",
              description = EXCLUDED.description,
              "isActive" = EXCLUDED."isActive",
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }

        total += values.length;
      }

      lastId = rows[rows.length - 1].PerPicId;
      console.log(`Customer photos migrated: ${total} (lastId=${lastId})`);
    }

    if (skippedRecords.count) {
      const skippedExamples = skippedRecords.examples.size
        ? Array.from(skippedRecords.examples).join(", ")
        : "n/a";
      console.warn(
        `⚠️ Skipped ${skippedRecords.count} photo(s) because no matching customer exists. Examples: ${skippedExamples}`
      );
    }

    console.log(
      `✅ CustomerPhoto migration completed. Total inserted/updated: ${total}`
    );
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCustomerPhoto;
