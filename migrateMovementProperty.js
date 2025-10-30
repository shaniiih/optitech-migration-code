const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const BATCH_SIZE = 1000;
const WINDOW_SIZE = 5000;

async function migrateMovementProperty(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1; // include 0 if ever present
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.execute(
        `SELECT InvMovePropId, InvMovePropName
         FROM tblInvMoveProps
         WHERE InvMovePropId > ?
         ORDER BY InvMovePropId
         LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        chunk.forEach((r) => {
          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7})`
          );
          params.push(
            uuidv4(),                // id
            tenantId,                // tenantId
            Number(r.InvMovePropId), // movementPropertyId
            r.InvMovePropName || `Movement Property ${r.InvMovePropId}`, // name
            r.InvMovePropName || `Movement Property ${r.InvMovePropId}`, // nameHe
            now,                     // updatedAt
            branchId                 // branchId
          );
        });

        await pg.query("BEGIN");
        try {
          const sql = `
            INSERT INTO "MovementProperty" (
              id, "tenantId", "movementPropertyId", name, "nameHe", "updatedAt", "branchId"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "movementPropertyId")
            DO UPDATE SET
              name = EXCLUDED.name,
              "nameHe" = EXCLUDED."nameHe",
              "updatedAt" = EXCLUDED."updatedAt",
              "branchId" = EXCLUDED."branchId"
          `;
          await pg.query(sql, params);
          // Backfill createdAt for new rows where default wasn't set explicitly: not necessary; default applies.
          await pg.query("COMMIT");
        } catch (e) {
          await pg.query("ROLLBACK");
          throw e;
        }

        total += chunk.length;
      }

      lastId = rows[rows.length - 1].InvMovePropId;
      console.log(`✔ MovementProperty migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ MovementProperty migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateMovementProperty;
