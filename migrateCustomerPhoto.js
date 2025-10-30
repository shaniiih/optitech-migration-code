const path = require("path");
const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");
const { ensureTenantId } = require("./tenantUtils");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

async function migrateCustomerPhoto(tenantId = "tenant_1", branchId = "branch_1") {
  tenantId = ensureTenantId(tenantId, "tenant_1");

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;
  const missingCustomers = new Set();

  try {
    const { rows: customerRows } = await pg.query(
      `SELECT id, "customerId" FROM "Customer" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const customerMap = new Map(
      customerRows.map((row) => [String(row.customerId), String(row.id)])
    );

    while (true) {
      const [rows] = await mysql.execute(
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

        for (const row of chunk) {
          const legacyCustomerId =
            row.PerId !== null && row.PerId !== undefined ? String(row.PerId) : null;
          if (!legacyCustomerId) {
            missingCustomers.add("UNKNOWN");
            continue;
          }

          const customerId = customerMap.get(legacyCustomerId);
          if (!customerId) {
            missingCustomers.add(legacyCustomerId);
            continue;
          }

          const perPicId = Number(row.PerPicId);
          const fileName = normalizeFileName(row.PicFileName, perPicId);
          const photoType = "PROFILE";
          const scanDate = normalizeDate(row.ScanDate);
          const timestamp = scanDate ?? new Date();
          

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10}, $${params.length + 11}, $${params.length + 12}, $${params.length + 13}, $${params.length + 14}, $${params.length + 15}, $${params.length + 16}, $${params.length + 17})`
          );

          params.push(
            uuidv4(), // id
            tenantId, // tenantId
            customerId, // customerId (FK to Customer.id)
            branchId, // branchId
            photoType, // photoType
            fileName, // fileName
            fileName, // filePath
            null, // fileSize (unknown in legacy)
            guessMimeType(fileName), // mimeType
            row.Description || null, // description
            true, // isActive
            timestamp, // createdAt
            timestamp, // updatedAt
            row.IsCon, // isCon stored as text
            row.Notes || null, // notes
            perPicId, // perPicId
            scanDate // scanDate
          );
        }

        if (!values.length) {
          continue;
        }

        await pg.query("BEGIN");
        try {
          const sql = `
            INSERT INTO "CustomerPhoto" (
              id, "tenantId", "customerId", "branchId", "photoType", "fileName", "filePath",
              "fileSize", "mimeType", description, "isActive", "createdAt", "updatedAt",
              "isCon", notes, "perPicId", "scanDate"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              "customerId" = EXCLUDED."customerId",
              "branchId" = EXCLUDED."branchId",
              "photoType" = EXCLUDED."photoType",
              "fileName" = EXCLUDED."fileName",
              "filePath" = EXCLUDED."filePath",
              "mimeType" = EXCLUDED."mimeType",
              description = EXCLUDED.description,
              "isActive" = EXCLUDED."isActive",
              "updatedAt" = EXCLUDED."updatedAt",
              "isCon" = EXCLUDED."isCon",
              notes = EXCLUDED.notes,
              "scanDate" = EXCLUDED."scanDate"
          `;
          await pg.query(sql, params);
          await pg.query("COMMIT");
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }

        total += chunk.length;
      }

      lastId = rows[rows.length - 1].PerPicId;
      console.log(`Customer photos migrated: ${total} (lastId=${lastId})`);
    }

    if (missingCustomers.size) {
      const sample = Array.from(missingCustomers).slice(0, 10);
      const suffix = missingCustomers.size > sample.length ? " ..." : "";
      console.log(
        `⚠️ Missing customer mappings for ${missingCustomers.size} photo records. Sample legacy IDs: ${sample.join(", ")}${suffix}`
      );
    }

    console.log(`✅ CustomerPhoto migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

function normalizeFileName(fileName, perPicId) {
  const trimmed = typeof fileName === "string" ? fileName.trim() : "";
  if (trimmed) return trimmed;
  return `legacy_photo_${perPicId}.bin`;
}

function buildLegacyPath(tenantId, legacyCustomerId, fileName) {
  const safeTenant = sanitizePathSegment(tenantId);
  const safeCustomer = sanitizePathSegment(legacyCustomerId);
  return path.join("/legacy", safeTenant, safeCustomer, fileName);
}

function sanitizePathSegment(value) {
  return String(value ?? "")
    .replace(/[^a-zA-Z0-9._-]/g, "_")
    .replace(/_{2,}/g, "_")
    .replace(/^_+|_+$/g, "") || "unknown";
}

function guessMimeType(fileName) {
  const ext = path.extname(fileName || "").toLowerCase();
  switch (ext) {
    case ".jpg":
    case ".jpeg":
      return "image/jpeg";
    case ".png":
      return "image/png";
    case ".gif":
      return "image/gif";
    case ".bmp":
      return "image/bmp";
    case ".tif":
    case ".tiff":
      return "image/tiff";
    case ".webp":
      return "image/webp";
    default:
      return null;
  }
}

function normalizeDate(value) {
  if (value === null || value === undefined) return null;
  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value;
  }
  if (typeof value === "string") {
    const trimmed = value.trim();
    if (!trimmed || /^0{4}-0{2}-0{2}/.test(trimmed)) return null;
    const parsed = new Date(trimmed);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }
  if (typeof value === "number") {
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }
  return null;
}

module.exports = migrateCustomerPhoto;
