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

async function migrateFrmLabelTypes(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;
  let skippedInvalidId = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT LabelId, LabelName
           FROM tblFrmLabelTypes
          WHERE LabelId > ?
          ORDER BY LabelId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();
        const seenIds = new Set(); // avoid duplicates within the same insert

        for (const row of chunk) {
          const labelId = asInteger(row.LabelId);
          if (labelId === null) {
            skippedInvalidId += 1;
            continue;
          }
          if (seenIds.has(labelId)) continue;
          seenIds.add(labelId);

          const labelName = cleanText(row.LabelName) || `Frm Label Type ${labelId}`;
          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7})`
          );
          params.push(
            uuidv4(),    // id
            tenantId,    // tenantId
            branchId,    // branchId
            labelId,     // LabelId
            labelName,   // LabelName
            timestamp,   // createdAt
            timestamp    // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "FrmLabelTypes" (
               id,
               "tenantId",
               "branchId",
               "LabelId",
               "LabelName",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "LabelId") DO UPDATE SET
               "LabelName" = EXCLUDED."LabelName",
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

      const latestId = asInteger(rows[rows.length - 1]?.LabelId);
      if (latestId !== null) {
        lastId = latestId;
      }
      console.log(`FrmLabelTypes migrated so far: ${total} (lastLabelId=${lastId})`);
    }

    console.log(`✅ FrmLabelTypes migration completed. Total rows processed: ${total}`);
    if (skippedInvalidId) {
      console.warn(`⚠️ FrmLabelTypes: skipped ${skippedInvalidId} records due to invalid LabelId`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateFrmLabelTypes;
