const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
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

function toBoolean(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "boolean") return value;
  if (typeof value === "number") {
    if (!Number.isFinite(value)) return null;
    return value !== 0;
  }
  const trimmed = String(value).trim().toLowerCase();
  if (!trimmed) return null;
  if (["1", "true", "t", "yes", "y"].includes(trimmed)) return true;
  if (["0", "false", "f", "no", "n"].includes(trimmed)) return false;
  return null;
}

async function migrateFrmModelTypes(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;
  let skippedInvalidId = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT ModelId, ModelName, ISG, Sizes
           FROM tblFrmModelTypes
          WHERE ModelId > ?
          ORDER BY ModelId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();
        const seenIds = new Set(); // avoid duplicates in the same batch

        for (const row of chunk) {
          const modelId = asInteger(row.ModelId);
          if (modelId === null) {
            skippedInvalidId += 1;
            continue;
          }
          if (seenIds.has(modelId)) continue;
          seenIds.add(modelId);

          const modelName = cleanText(row.ModelName) || `Frm Model Type ${modelId}`;
          const isg = toBoolean(row.ISG);
          const sizes = cleanText(row.Sizes);

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9})`
          );
          params.push(
            uuidv4(),    // id
            tenantId,    // tenantId
            branchId,    // branchId
            modelId,     // ModelId
            modelName,   // LabelName (per schema)
            isg,         // ISG
            sizes,       // Sizes
            timestamp,   // createdAt
            timestamp    // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "FrmModelType" (
               id,
               "tenantId",
               "branchId",
               "ModelId",
               "LabelName",
               "ISG",
               "Sizes",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "ModelId") DO UPDATE SET
               "LabelName" = EXCLUDED."LabelName",
               "ISG" = EXCLUDED."ISG",
               "Sizes" = EXCLUDED."Sizes",
               "updatedAt" = EXCLUDED."updatedAt"`,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      const latestId = asInteger(rows[rows.length - 1]?.ModelId);
      if (latestId !== null) {
        lastId = latestId;
      }
      console.log(`FrmModelTypes migrated so far: ${total} (lastModelId=${lastId})`);
    }

    console.log(`✅ FrmModelTypes migration completed. Total rows processed: ${total}`);
    if (skippedInvalidId) {
      console.warn(`⚠️ FrmModelTypes: skipped ${skippedInvalidId} records due to invalid ModelId`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateFrmModelTypes;
