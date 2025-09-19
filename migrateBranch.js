const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const BATCH_SIZE = 1000;            // tune: 1k–5k is usually sweet
const WINDOW_SIZE = 5000;           // how many rows to pull from MySQL per window

async function migrateBranch(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  // Ensure a unique constraint for idempotency, for example on ("tenantId", "code")
  // CREATE UNIQUE INDEX IF NOT EXISTS "Branch_tenant_code_ux" ON "Branch"("tenantId", "code");

  let lastId = 0;
  let total = 0;

  try {
    while (true) {
      // Stream/window by PK—resumable and avoids OFFSET cost
      const [rows] = await mysql.execute(
        `SELECT BranchId, BranchName
         FROM tblBranchs
         WHERE BranchId > ?
         ORDER BY BranchId
         LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      // Chunk into insert batches
      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);

        // Build a single multi-row insert with placeholders
        const now = new Date();
        const values = [];
        const params = [];

        chunk.forEach((r) => {
          // You can use deterministic UUIDs if you want true idempotency even when re-running
          // For now we derive 'code' from BranchId and rely on tenantId+code unique
          values.push(`($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7})`);
          params.push(
            uuidv4(),                  // id (or keep a deterministic mapping if needed)
            tenantId,                  // "tenantId"
            r.BranchName ?? null,      // name
            String(r.BranchId),        // code
            false,                     // "isMain"
            now,                       // "createdAt"
            now                        // "updatedAt"
          );
        });

        await pg.query("BEGIN");
        try {
          const sql = `
            INSERT INTO "Branch" (
              id, "tenantId", name, code, "isMain", "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", code)
            DO UPDATE SET
              name = EXCLUDED.name,
              "updatedAt" = EXCLUDED."updatedAt"
          `;
          await pg.query(sql, params);
          await pg.query("COMMIT");
        } catch (e) {
          await pg.query("ROLLBACK");
          throw e;
        }

        total += chunk.length;
      }

      // Advance window
      lastId = rows[rows.length - 1].BranchId;
      console.log(`✔ Migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ Branch migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateBranch;
