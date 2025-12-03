const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function normalizeInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  if (typeof value === "bigint") return Number(value);
  const n = Number(String(value).trim());
  return Number.isFinite(n) ? Math.trunc(n) : null;
}

function normalizeDate(value) {
  if (!value) return null;
  const d = new Date(value);
  return isNaN(d.getTime()) ? null : d;
}

function normalizeBoolToInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "boolean") return value ? 1 : 0;
  const n = normalizeInt(value);
  if (n === null) return null;
  return n !== 0 ? 1 : 0;
}

async function migrateItemCountsYear(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastKey = -1; // last CountYear processed
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT CountYear, CountDate, Closed
           FROM tblItemCountsYears
          WHERE CountYear > ?
          ORDER BY CountYear
          LIMIT ${WINDOW_SIZE}`,
        [lastKey]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();

        for (const r of chunk) {
          const countYear = normalizeInt(r.CountYear);
          const countDate = normalizeDate(r.CountDate);
          const closed = normalizeBoolToInt(r.Closed);

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8})`
          );
          params.push(
            createId(),          // id
            tenantId,          // tenantId
            branchId,          // branchId
            countYear,         // countYear
            countDate,         // countDate
            closed,            // closed (as int 0/1)
            now,               // createdAt
            now                // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "ItemCountsYear" (
               id, "tenantId", "branchId", "countYear", "countDate", closed, "createdAt", "updatedAt"
             ) VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "countYear") DO UPDATE SET
               "countDate" = EXCLUDED."countDate",
               closed = EXCLUDED.closed,
               "updatedAt" = EXCLUDED."updatedAt"`,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (e) {
          await pg.query("ROLLBACK");
          throw e;
        }
      }

      lastKey = rows[rows.length - 1].CountYear;
      console.log(`ItemCountsYear migrated so far: ${total} (lastCountYear=${lastKey})`);
    }

    console.log(`✅ ItemCountsYear migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateItemCountsYear;

