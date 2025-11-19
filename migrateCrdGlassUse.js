const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function normalizeId(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  if (typeof value === "bigint") {
    return Number(value);
  }
  if (Buffer.isBuffer(value)) {
    return normalizeId(value.toString("utf8"));
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

async function migrateCrdGlassUse(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    
    while (true) {
      const [rows] = await mysql.query(
        `SELECT GlassUseId, GlassUseName
           FROM tblCrdGlassUses
          WHERE GlassUseId > ?
          ORDER BY GlassUseId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        for (const row of chunk) {
          const glassUseId = normalizeId(row.GlassUseId);
          if (glassUseId === null) continue;

          const glassUseName = cleanText(row.GlassUseName);

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8})`
          );
          params.push(
            uuidv4(),
            tenantId,
            branchId,
            glassUseId,
            glassUseName,
            null,
            now,
            now
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "CrdGlassUse" (
              id,
              "tenantId",
              "branchId",
              "glassUseId",
              "glassUseName",
              "idCount",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "glassUseId")
            DO UPDATE SET
              "glassUseName" = EXCLUDED."glassUseName",
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

      lastId = rows[rows.length - 1].GlassUseId;
      console.log(
        `CrdGlassUse migrated so far: ${total} (lastId=${lastId})`
      );
    }

    console.log(
      `✅ CrdGlassUse migration completed. Total inserted/updated: ${total}`
    );
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCrdGlassUse;
