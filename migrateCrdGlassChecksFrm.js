const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function asDate(value) {
  if (!value) return null;
  const d = new Date(value);
  return Number.isNaN(d.getTime()) ? null : d;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

async function migrateCrdGlassChecksFrm(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastPerId = -1;
  let lastCheckDate = null;
  let lastGlassId = -1;
  let total = 0;

  try {
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
        const timestamp = new Date();

        for (const row of chunk) {
          const perId = asInteger(row.PerId);
          const glassId = asInteger(row.GlassId);
          const checkDate = asDate(row.CheckDate);

          const fSapakId = asInteger(row.FSapakId);
          const fLabelId = asInteger(row.FLabelId);
          const fModel = cleanText(row.FModel);
          const fColor = cleanText(row.FColor);
          const fSize = cleanText(row.FSize);
          const comments = cleanText(row.Comments);

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9}, $${base + 10}, $${base + 11}, $${base + 12}, $${base + 13}, $${base + 14})`
          );
          params.push(
            uuidv4(),      // id
            tenantId,      // tenantId
            branchId,      // branchId
            perId,         // perId
            checkDate,     // checkDate
            glassId,       // glassId
            fSapakId,      // fSapakId
            fLabelId,      // fLabelId
            fModel,        // fModel
            fColor,        // fColor
            fSize,         // fSize
            comments,      // comments
            timestamp,     // createdAt
            timestamp      // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "CrdGlassChecksFrm" (
               id,
               "tenantId",
               "branchId",
               "perId",
               "checkDate",
               "glassId",
               "fSapakId",
               "fLabelId",
               "fModel",
               "fColor",
               "fSize",
               "comments",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "perId", "checkDate", "glassId") DO UPDATE SET
               "fSapakId" = EXCLUDED."fSapakId",
               "fLabelId" = EXCLUDED."fLabelId",
               "fModel"   = EXCLUDED."fModel",
               "fColor"   = EXCLUDED."fColor",
               "fSize"    = EXCLUDED."fSize",
               "comments" = EXCLUDED."comments",
               "updatedAt" = EXCLUDED."updatedAt"`,
            params
          );
          await pg.query("COMMIT");
          total += chunk.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      const last = rows[rows.length - 1];
      lastPerId = asInteger(last.PerId) ?? lastPerId;
      lastCheckDate = asDate(last.CheckDate) ?? lastCheckDate;
      lastGlassId = asInteger(last.GlassId) ?? lastGlassId;

      console.log(
        `CrdGlassChecksFrm migrated so far: ${total} (lastPerId=${lastPerId}, lastCheckDate=${lastCheckDate}, lastGlassId=${lastGlassId})`
      );
    }

    console.log(`✅ CrdGlassChecksFrm migration completed. Total rows processed: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCrdGlassChecksFrm;
