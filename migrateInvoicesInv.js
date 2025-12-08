const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function normalizeInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  if (typeof value === "bigint") return Number(value);
  if (Buffer.isBuffer(value)) return normalizeInt(value.toString("utf8"));
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}



async function migrateInvoicesInv(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    const invoiceMap = new Map();
    const { rows: invoiceRows } = await pg.query(
      `SELECT id, "invoiceId"
       FROM "Invoice"
       WHERE "tenantId" = $1 AND "branchId" = $2`,
      [tenantId, branchId]
    );
    for (const row of invoiceRows) {
      const legacy = normalizeInt(row.invoiceId);
      if (legacy !== null) invoiceMap.set(legacy, row.id);
    }

    const inventoryMap = new Map();
    const { rows: invRows } = await pg.query(
      `SELECT id, "invId"
       FROM "Inventory"
       WHERE "tenantId" = $1 AND "branchId" = $2`,
      [tenantId, branchId]
    );
    for (const row of invRows) {
      const legacy = normalizeInt(row.invId);
      if (legacy !== null) inventoryMap.set(legacy, row.id);
    }

    while (true) {
      const [rows] = await mysql.query(
        `
        SELECT InvoiceId, InvId
        FROM tblInvoicesInvs
        ORDER BY InvoiceId
        LIMIT ? OFFSET ?
        `,
        [WINDOW_SIZE, offset]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const row of chunk) {
          const legacyInvoiceId = normalizeInt(row.InvoiceId);
          const legacyInvId = normalizeInt(row.InvId);

          const newInvoiceId = invoiceMap.get(legacyInvoiceId) || null;
          const newInvId = inventoryMap.get(legacyInvId) || null;

          const now = new Date();
          const base = params.length;

          values.push(
            `(
              $${base + 1}, $${base + 2}, $${base + 3},
              $${base + 4}, $${base + 5}, $${base + 6},
              $${base + 7}, $${base + 8}, $${base + 9}
            )`
          );

          params.push(
            createId(),
            tenantId,
            branchId,
            legacyInvoiceId,
            newInvoiceId,
            legacyInvId,
            newInvId,
            now,   
            now     
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "InvoicesInv" (
              id, "tenantId", "branchId",
              "legacyInvoiceId", "invoiceId",
              "legacyInvId", "invId",
              "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "legacyInvoiceId")
            DO UPDATE SET
              "invoiceId" = EXCLUDED."invoiceId",
              "legacyInvId" = EXCLUDED."legacyInvId",
              "invId" = EXCLUDED."invId",
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );

          await pg.query("COMMIT");
          total += values.length;
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }
      }

      offset += rows.length;
    }
  } finally {
    await mysql.end();
    await pg.end();
  }

  console.log("Migration completed:", total, "records migrated.");
}

module.exports = migrateInvoicesInv;
