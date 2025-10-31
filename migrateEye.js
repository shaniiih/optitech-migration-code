const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

async function migrateEye(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1; // include potential zero id
  let total = 0;

  try {
    await pg.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1
          FROM pg_indexes
          WHERE indexname = 'eye_tenant_eyeid_ux'
        ) THEN
          CREATE UNIQUE INDEX eye_tenant_eyeid_ux
          ON "Eye" ("tenantId","eyeId");
        END IF;
      END$$;
    `);

    while (true) {
      const [rows] = await mysql.execute(
        `SELECT EyeId, EyeName
         FROM tblEyes
         WHERE EyeId > ?
         ORDER BY EyeId
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
          const eyeId = Number(row.EyeId);
          if (!Number.isFinite(eyeId)) continue;

          const rawName = typeof row.EyeName === "string" ? row.EyeName.trim() : "";
          const eyeName = rawName || `Eye ${eyeId}`;

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7})`
          );
          params.push(
            uuidv4(),    // id
            tenantId,    // tenantId
            branchId,    // branchId
            eyeId,       // eyeId
            eyeName,     // eyeName
            now,         // createdAt
            now          // updatedAt
          );
        }

        const insertCount = values.length;
        if (!insertCount) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "Eye" (
              id, "tenantId", "branchId", "eyeId", "eyeName", "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "eyeId")
            DO UPDATE SET
              "eyeName" = EXCLUDED."eyeName",
              "branchId" = EXCLUDED."branchId",
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }

        total += insertCount;
      }

      const latestId = Number(rows[rows.length - 1].EyeId);
      if (Number.isFinite(latestId)) {
        lastId = latestId;
      }
      console.log(`Eye rows migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ Eye migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateEye;
