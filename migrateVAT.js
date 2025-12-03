const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanDate(value) {
  if (!value) return null;
  const d = value instanceof Date ? value : new Date(value);
  return Number.isNaN(d.getTime()) ? null : d;
}

function normalizeFloat(value) {
  if (value === null || value === undefined) return null;
  const n = typeof value === "number" ? value : Number(String(value).trim());
  return Number.isFinite(n) ? n : null;
}

async function migrateVAT(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let total = 0;

  try {
    const [rows] = await mysql.query(
      `SELECT VStart, VEnd, VAT
         FROM tblVAT
        ORDER BY VStart, VEnd, VAT`
    );

    if (!rows.length) {
      console.log("VAT: no rows to migrate");
      return;
    }

    for (let i = 0; i < rows.length; i += BATCH_SIZE) {
      const chunk = rows.slice(i, i + BATCH_SIZE);
      const now = new Date();
      const values = [];
      const params = [];

      for (const r of chunk) {
        const vStart = cleanDate(r.VStart);
        const vEnd = cleanDate(r.VEnd);
        const vatValue = normalizeFloat(r.VAT);

        if (!vStart || !vEnd || vatValue === null) continue;

        const base = params.length;
        values.push(
          `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8})`
        );

        params.push(
          createId(),      // id
          tenantId,      // tenantId
          branchId,      // branchId
          vStart,        // vStart
          vEnd,          // vEnd
          vatValue,      // VAT
          now,           // createdAt
          now            // updatedAt
        );
      }

      if (!values.length) continue;

      await pg.query("BEGIN");
      try {
        await pg.query(
          `INSERT INTO "VAT" (
             id,
             "tenantId",
             "branchId",
             "vStart",
             "vEnd",
             "VAT",
             "createdAt",
             "updatedAt"
           )
           VALUES ${values.join(",")}
           ON CONFLICT ("tenantId", "branchId", "vStart", "vEnd", "VAT") DO UPDATE SET
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

    console.log(`✅ VAT migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateVAT;
