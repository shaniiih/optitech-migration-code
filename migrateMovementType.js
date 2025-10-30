const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const BATCH_SIZE = 1000;
const WINDOW_SIZE = 5000;

async function migrateMovementType(tenantId = "tenant_1", branchId = "branch_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1; // include 0 if present
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.execute(
        `SELECT InvMoveTypeId, InvMoveTypeName, MoveAction
         FROM tblInvMoveTypes
         WHERE InvMoveTypeId > ?
         ORDER BY InvMoveTypeId
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
          values.push(`($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10}, $${params.length + 11})`);
          const name = r.InvMoveTypeName || `Movement Type ${r.InvMoveTypeId}`;
          params.push(
            uuidv4(),                       // id
            tenantId,                       // tenantId
            Number(r.InvMoveTypeId),        // movementTypeId
            name,                           // name
            name,                           // nameHe (same as name per request)
            Number(r.MoveAction) || 0,      // action
            "PURCHASE",                      // category (no source; set default)
            false,                          // requiresInvoice
            false,                          // requiresReason
            now,                             // updatedAt
            branchId  // branchId
          );
        });

        await pg.query("BEGIN");
        try {
          const sql = `
            INSERT INTO "MovementType" (
              id, "tenantId", "movementTypeId", name, "nameHe", action, category, "requiresInvoice", "requiresReason", "updatedAt", "branchId"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "movementTypeId")
            DO UPDATE SET
              name = EXCLUDED.name,
              "nameHe" = EXCLUDED."nameHe",
              action = EXCLUDED.action,
              category = EXCLUDED.category,
              "requiresInvoice" = EXCLUDED."requiresInvoice",
              "requiresReason" = EXCLUDED."requiresReason",
              "updatedAt" = NOW(),
              "branchId" = EXCLUDED."branchId"
          `;
          await pg.query(sql, params);
          await pg.query("COMMIT");
        } catch (e) {
          await pg.query("ROLLBACK");
          throw e;
        }

        total += chunk.length;
      }

      lastId = rows[rows.length - 1].InvMoveTypeId;
      console.log(`✔ MovementType migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ MovementType migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateMovementType;
