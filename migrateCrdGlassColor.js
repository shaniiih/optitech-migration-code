const { createId } = require("@paralleldrive/cuid2");
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

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

async function migrateCrdGlassColor(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT GlassColorId, GlassColorName
           FROM tblCrdGlassColor
          WHERE GlassColorId > ?
          ORDER BY GlassColorId
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
          const glassColorId = asInteger(row.GlassColorId);
          if (glassColorId === null) continue;

          const name = cleanText(row.GlassColorName) || `Glass Color ${glassColorId}`;
          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7})`
          );
          params.push(
            createId(),    // id
            tenantId,      // tenantId
            branchId,      // branchId
            glassColorId,  // glassColorId
            name,          // name
            timestamp,     // createdAt
            timestamp      // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "CrdGlassColor" (
               id,
               "tenantId",
               "branchId",
               "glassColorId",
               "name",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "glassColorId") DO UPDATE SET
               "name" = EXCLUDED."name",
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

      const latestId = asInteger(rows[rows.length - 1]?.GlassColorId);
      if (latestId !== null) {
        lastId = latestId;
      }
      console.log(`CrdGlassColor migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ CrdGlassColor migration completed. Total rows processed: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCrdGlassColor;
