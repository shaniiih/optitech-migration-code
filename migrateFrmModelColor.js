const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");
const { ensureTenantId } = require("./tenantUtils");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  if (typeof value === "bigint") return Number(value);
  const trimmed = cleanText(value);
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

async function migrateFrmModelColor(tenantId = "tenant_1", branchId = null) {
  tenantId = ensureTenantId(tenantId, "tenant_1");
  const normalizedBranchId = cleanText(branchId);

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;
  const missingLabels = new Set();
  const missingModels = new Set();
  const missingColors = new Set();

  try {
    // preload mappings for label, model, and color
    const labelMap = new Map();
    const modelMap = new Map();
    const colorMap = new Map(); // key: `${legacyLabelId}::${legacyFrameColorId}`

    try {
      const { rows } = await pg.query(
        `SELECT id, "LabelId" AS "legacyLabelId"
           FROM "FrmLabelType"
          WHERE "tenantId" = $1
            AND "branchId" = $2`,
        [tenantId, normalizedBranchId]
      );
      for (const row of rows) {
        const legacy = asInteger(row.legacyLabelId);
        if (legacy !== null && !labelMap.has(legacy)) {
          labelMap.set(legacy, row.id);
        }
      }
    } catch (err) {
      console.warn("⚠️ FrmModelColor: failed to preload FrmLabelType mapping.", err.message);
    }

    try {
      const { rows } = await pg.query(
        `SELECT id, "ModelId" AS "legacyModelId"
           FROM "FrmModelType"
          WHERE "tenantId" = $1
            AND "branchId" = $2`,
        [tenantId, normalizedBranchId]
      );
      for (const row of rows) {
        const legacy = asInteger(row.legacyModelId);
        if (legacy !== null && !modelMap.has(legacy)) {
          modelMap.set(legacy, row.id);
        }
      }
    } catch (err) {
      console.warn("⚠️ FrmModelColor: failed to preload FrmModelType mapping.", err.message);
    }

    try {
      const { rows } = await pg.query(
        `SELECT id, "legacyLabelId", "frameColorId"
           FROM "FrmColor"
          WHERE "tenantId" = $1
            AND "branchId" = $2`,
        [tenantId, normalizedBranchId]
      );
      for (const row of rows) {
        const legacyLabelId = asInteger(row.legacyLabelId);
        const legacyFrameColorId = cleanText(row.frameColorId);
        if (legacyLabelId === null || !legacyFrameColorId) continue;
        const key = `${legacyLabelId}::${legacyFrameColorId}`;
        if (!colorMap.has(key)) {
          colorMap.set(key, row.id);
        }
      }
    } catch (err) {
      console.warn("⚠️ FrmModelColor: failed to preload FrmColor mapping.", err.message);
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT LabelId, ModelId, FrameColorId, FramePic
           FROM tblFrmModelColors
          WHERE LabelId > ?
          ORDER BY LabelId, ModelId, FrameColorId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();
        const seen = new Set();

        for (const row of chunk) {
          const legacyLabelId = asInteger(row.LabelId);
          const legacyModelId = asInteger(row.ModelId);
          const legacyFrameColorId = cleanText(row.FrameColorId);

          if (legacyLabelId === null || legacyModelId === null || !legacyFrameColorId) continue;

          const dedupeKey = `${legacyLabelId}::${legacyModelId}::${legacyFrameColorId}`;
          if (seen.has(dedupeKey)) continue;
          seen.add(dedupeKey);

          const labelId = labelMap.get(legacyLabelId) || null;
          if (!labelId) missingLabels.add(String(legacyLabelId));

          const modelId = modelMap.get(legacyModelId) || null;
          if (!modelId) missingModels.add(String(legacyModelId));

          const colorKey = `${legacyLabelId}::${legacyFrameColorId}`;
          const frameColorId = colorMap.get(colorKey) || null;
          if (!frameColorId) missingColors.add(colorKey);

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9}, $${base + 10}, $${base + 11}, $${base + 12})`
          );
          params.push(
            uuidv4(),                       // id
            tenantId,                       // tenantId
            normalizedBranchId || null,     // branchId
            legacyLabelId,                  // legacyLabelId
            labelId,                        // labelId (FK -> FrmLabelType.id)
            legacyModelId,                  // legacyModelId
            modelId,                        // modelId (FK -> FrmModelType.id)
            legacyFrameColorId,             // legacyFrameColorId
            frameColorId,                   // frameColorId (FK -> FrmColor.id)
            cleanText(row.FramePic),        // framePic
            now,                            // createdAt
            now                             // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "FrmModelColor" (
               id,
               "tenantId",
               "branchId",
               "legacyLabelId",
               "labelId",
               "legacyModelId",
               "modelId",
               "legacyFrameColorId",
               "frameColorId",
               "framePic",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "legacyLabelId", "legacyModelId", "legacyFrameColorId") DO UPDATE SET
               "labelId" = EXCLUDED."labelId",
               "modelId" = EXCLUDED."modelId",
               "frameColorId" = EXCLUDED."frameColorId",
               "framePic" = EXCLUDED."framePic",
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

      const latestLabel = asInteger(rows[rows.length - 1]?.LabelId);
      if (latestLabel !== null) {
        lastId = latestLabel;
      }
      console.log(`FrmModelColor migrated so far: ${total} (lastLabelId=${lastId})`);
    }

    if (missingLabels.size) {
      const sample = Array.from(missingLabels).slice(0, 10);
      console.warn(
        `⚠️ FrmModelColor: missing label mapping for ${missingLabels.size} legacy LabelIds. Sample: ${sample.join(", ")}`
      );
    }
    if (missingModels.size) {
      const sample = Array.from(missingModels).slice(0, 10);
      console.warn(
        `⚠️ FrmModelColor: missing model mapping for ${missingModels.size} legacy ModelIds. Sample: ${sample.join(", ")}`
      );
    }
    if (missingColors.size) {
      const sample = Array.from(missingColors).slice(0, 10);
      console.warn(
        `⚠️ FrmModelColor: missing color mapping for ${missingColors.size} legacy pairs (LabelId::FrameColorId). Sample: ${sample.join(", ")}`
      );
    }

    console.log(`✅ FrmModelColor migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateFrmModelColor;
