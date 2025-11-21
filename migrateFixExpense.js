const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function normalizeInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  if (typeof value === "bigint") {
    return Number(value);
  }
  if (Buffer.isBuffer(value)) {
    return normalizeInt(value.toString("utf8"));
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

function toFloat(value) {
  if (value === null || value === undefined) return null;
  const n = Number(value);
  return Number.isFinite(n) ? n : null;
}

async function migrateFixExpense(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT FixExpenseId, FixExpenseName, FixSum, StartDate, EndDate, IntervalType, IntervalNum
           FROM tblFixExpenses
          WHERE FixExpenseId > ?
          ORDER BY FixExpenseId
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
          const fixExpenseId = normalizeInt(row.FixExpenseId);
          if (fixExpenseId === null) continue;

          const fixExpenseName = cleanText(row.FixExpenseName);
          const fixSum = toFloat(row.FixSum);
          const startDate = row.StartDate ? new Date(row.StartDate) : null;
          const endDate = row.EndDate ? new Date(row.EndDate) : null;
          const intervalType = cleanText(row.IntervalType);
          const intervalNum = normalizeInt(row.IntervalNum);

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10}, $${params.length + 11}, $${params.length + 12})`
          );
          params.push(
            uuidv4(),        // id
            tenantId,        // tenantId
            branchId,        // branchId
            fixExpenseId,    // fixExpenseId
            fixExpenseName,  // fixExpenseName
            fixSum,          // fixSum
            startDate,       // startDate
            endDate,         // endDate
            intervalType,    // intervalType
            intervalNum,     // intervalNum
            now,             // createdAt
            now              // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "FixExpense" (
              id,
              "tenantId",
              "branchId",
              "fixExpenseId",
              "fixExpenseName",
              "fixSum",
              "startDate",
              "endDate",
              "intervalType",
              "intervalNum",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "fixExpenseId")
            DO UPDATE SET
              "fixExpenseName" = EXCLUDED."fixExpenseName",
              "fixSum" = EXCLUDED."fixSum",
              "startDate" = EXCLUDED."startDate",
              "endDate" = EXCLUDED."endDate",
              "intervalType" = EXCLUDED."intervalType",
              "intervalNum" = EXCLUDED."intervalNum",
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

      lastId = rows[rows.length - 1].FixExpenseId ?? lastId;
      console.log(`FixExpense migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ FixExpense migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateFixExpense;
