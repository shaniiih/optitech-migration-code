const { createId } = require("@paralleldrive/cuid2");
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
  if (Buffer.isBuffer(value)) return asInteger(value.toString("utf8"));
  const trimmed = cleanText(value);
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

async function migrateFrmColor(tenantId = "tenant_1", branchId = null) {
  tenantId = ensureTenantId(tenantId, "tenant_1");
  const normalizedBranchId = cleanText(branchId);

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;
  const missingLabels = new Set();
  let skippedInvalidId = 0;

  try {
    const { rows: labelRows } = await pg.query(
      `SELECT id, "LabelId", "branchId"
         FROM "FrmLabelType"
        WHERE "tenantId" = $1
          AND "branchId" = $2`,
      [tenantId, normalizedBranchId]
    );
    const labelMap = new Map();
    for (const row of labelRows) {
      const key = String(row.LabelId);
      const existing = labelMap.get(key);
      if (!existing) {
        labelMap.set(key, row);
      } else if (normalizedBranchId && row.branchId === normalizedBranchId) {
        labelMap.set(key, row);
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT LabelId, FrameColorId, FrameColorName
           FROM tblFrmColors
          ORDER BY LabelId, FrameColorId
          LIMIT ? OFFSET ?`,
        [WINDOW_SIZE, offset]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();

        for (const row of chunk) {
          const legacyLabelId = asInteger(row.LabelId);
          if (legacyLabelId === null) {
            skippedInvalidId += 1;
            continue;
          }

          const label = labelMap.get(String(legacyLabelId)) ?? null;
          const mappedLabelId = label ? label.id : null;
          if (!mappedLabelId) {
            missingLabels.add(String(legacyLabelId));
            continue;
          }

          const frameColorId = cleanText(row.FrameColorId);
          if (!frameColorId) {
            skippedInvalidId += 1;
            continue;
          }

          const frameColorName = cleanText(row.FrameColorName) || frameColorId;

          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8}, $${offset + 9})`
          );
          params.push(
            createId(), // id
            tenantId, // tenantId
            normalizedBranchId || null, // branchId
            mappedLabelId, // labelId (uuid)
            legacyLabelId, // legacyLabelId
            frameColorId, // frameColorId
            frameColorName, // frameColorName
            now, // createdAt
            now // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "FrmColor" (
              id,
              "tenantId",
              "branchId",
              "labelId",
              "legacyLabelId",
              "frameColorId",
              "frameColorName",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "legacyLabelId", "frameColorId")
            DO UPDATE SET
              "frameColorName" = EXCLUDED."frameColorName",
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

      offset += rows.length;
      console.log(`FrmColor migrated: ${total} (offset=${offset})`);
    }

    if (missingLabels.size) {
      const sample = Array.from(missingLabels).slice(0, 10);
      const suffix = missingLabels.size > sample.length ? " ..." : "";
      console.log(
        `⚠️ Missing FrmLabelType mapping for ${missingLabels.size} legacy LabelId values. Sample: ${sample.join(", ")}${suffix}`
      );
    }
    if (skippedInvalidId) {
      console.log(`⚠️ Skipped ${skippedInvalidId} colors due to invalid LabelId/FrameColorId`);
    }

    console.log(`✅ FrmColor migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateFrmColor;
