const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

async function migrateDummy(tenantId = "tenant_1", branchId) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let total = 0;

  try {
    if (!branchId) {
      throw new Error("migrateDummy requires a non-null branchId");
    }

    // For Dummy we always fully refresh per tenant/branch:
    // remove existing rows for this scope, then insert fresh.
    await pg.query(
      `DELETE FROM "Dummy" WHERE "tenantId" = $1 AND "branchId" = $2`,
      [tenantId, branchId]
    );

    const [rows] = await mysql.query(
      `SELECT Dummy
       FROM tblDummy`
    );

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        for (const row of chunk) {
          const dummyValue = toDummyBool(row.Dummy);
          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6})`
          );
          params.push(
            createId(),    // id
            tenantId,    // tenantId
            branchId,    // branchId
            dummyValue,  // dummy
            now,         // createdAt
            now          // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query(
          `
          INSERT INTO "Dummy" (
            id, "tenantId", "branchId", dummy, "createdAt", "updatedAt"
          )
          VALUES ${values.join(",")}
          `,
          params
        );

        total += chunk.length;
      }
    console.log(`✅ Dummy migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

function toDummyBool(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "boolean") return value;
  if (typeof value === "number") return value !== 0;

  const normalized = String(value).trim().toLowerCase();
  if (["1", "true", "yes", "y"].includes(normalized)) return true;
  if (["0", "false", "no", "n"].includes(normalized)) return false;

  return null;
}

module.exports = migrateDummy;
