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

async function migrateCrdGlassRetDist(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    // Unique index creation moved to Prisma schema/migrations. Leaving disabled to avoid conflicts.
    // await pg.query(`
    //   DO $$
    //   BEGIN
    //     IF NOT EXISTS (
    //       SELECT 1
    //       FROM pg_indexes
    //       WHERE indexname = 'crd_glass_retdist_tenant_ret_id_ux'
    //     ) THEN
    //       CREATE UNIQUE INDEX crd_glass_retdist_tenant_ret_id_ux
    //       ON "CrdGlassRetDist" ("tenantId","retDistId");
    //     END IF;
    //   END$$;
    // `);

    while (true) {
      const [rows] = await mysql.query(
        `SELECT RetDistId, RetDistName
           FROM tblCrdGlassRetDists
          WHERE RetDistId > ?
          ORDER BY RetDistId
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
          const retDistId = normalizeId(row.RetDistId);
          if (retDistId === null) continue;

          const retDistName = cleanText(row.RetDistName);

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8})`
          );
          params.push(
            uuidv4(),
            tenantId,
            branchId,
            retDistId,
            retDistName,
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
            INSERT INTO "CrdGlassRetDist" (
              id,
              "tenantId",
              "branchId",
              "retDistId",
              "retDistName",
              "idCount",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "retDistId")
            DO UPDATE SET
              "branchId" = EXCLUDED."branchId",
              "retDistName" = EXCLUDED."retDistName",
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

      lastId = rows[rows.length - 1].RetDistId;
      console.log(
        `CrdGlassRetDist migrated so far: ${total} (lastId=${lastId})`
      );
    }

    console.log(
      `✅ CrdGlassRetDist migration completed. Total inserted/updated: ${total}`
    );
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCrdGlassRetDist;
