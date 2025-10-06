const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

async function migrateSupplier(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;

  try {
    const now = () => new Date();

    while (true) {
      const [rows] = await mysql.query(
        `SELECT SapakID, SapakName
           FROM tblSapaks
          WHERE SapakID > ?
          ORDER BY SapakID
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const r of chunk) {
          const supplierLegacyId = cleanText(r.SapakID) || String(r.SapakID);
          const id = `${tenantId}-supplier-${supplierLegacyId}`;
          const name = cleanText(r.SapakName) || `Legacy Supplier ${supplierLegacyId}`;
          const timestamp = now();

          const paramBase = params.length;
          values.push(
            `($${paramBase + 1}, $${paramBase + 2}, $${paramBase + 3}, $${paramBase + 4}, $${paramBase + 5}, $${paramBase + 6})`
          );

          params.push(
            uuidv4(),
            tenantId,
            supplierLegacyId,
            name,
            timestamp,
            timestamp
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "Supplier" (
              id, "tenantId", "supplierId", name, "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("supplierId")
            DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              "supplierId" = EXCLUDED."supplierId",
              name = EXCLUDED.name,
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }

        total += chunk.length;
      }

      lastId = rows[rows.length - 1].SapakID;
      console.log(`Suppliers migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ Supplier migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateSupplier;
