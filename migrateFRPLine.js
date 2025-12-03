const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function normalizeDate(value) {
  if (value === null || value === undefined) return null;
  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value;
  }
  if (typeof value === "number") {
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? null : date;
  }
  const str = String(value).trim();
  if (!str) return null;
  if (/^0{4}-0{2}-0{2}/.test(str)) return null;
  const date = new Date(str);
  return Number.isNaN(date.getTime()) ? null : date;
}

function asInteger(value, fallback = null) {
  if (value === null || value === undefined) return fallback;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : fallback;
  }
  const str = String(value).trim();
  if (!str) return fallback;
  const num = Number(str);
  return Number.isFinite(num) ? Math.trunc(num) : fallback;
}

async function migrateFRPLine(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  let skippedInvalidDate = 0;
  let skippedMissingFrp = 0;

  try {
    const { rows: frpRows } = await pg.query(
      `SELECT id, "frpId" FROM "FrequentReplacementProgramDetail" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const frpMap = new Map();
    for (const row of frpRows) {
      const key = asInteger(row.frpId);
      if (key !== null && !frpMap.has(key)) {
        frpMap.set(key, row.id);
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT FrpLineId, FrpId, LineDate, Quantity
           FROM tblCrdFrpsLines
          WHERE FrpLineId > ?
          ORDER BY FrpLineId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();

        for (const row of chunk) {
          const frpLineId = asInteger(row.FrpLineId);
          const frpIdLegacy = asInteger(row.FrpId);
          const frpDetailId = frpIdLegacy !== null ? frpMap.get(frpIdLegacy) : null;
          if (!frpDetailId) {
            skippedMissingFrp += 1;
            continue;
          }

          const lineDate = normalizeDate(row.LineDate);
          if (!lineDate) {
            skippedInvalidDate += 1;
            continue;
          }

          const quantity = asInteger(row.Quantity, 0);

          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7})`
          );

          params.push(
            createId(),
            tenantId,
            frpLineId,
            frpDetailId,
            lineDate,
            quantity,
            timestamp
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "FRPLine" (
              id,
              "tenantId",
              "frpLineId",
              "frpId",
              "lineDate",
              quantity,
              "createdAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              "frpId" = EXCLUDED."frpId",
              "lineDate" = EXCLUDED."lineDate",
              quantity = EXCLUDED.quantity,
              "createdAt" = EXCLUDED."createdAt"
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

      lastId = rows[rows.length - 1].FrpLineId;
      console.log(`FRPLine migrated: ${total} (lastFrpLineId=${lastId})`);
    }

    console.log(`✅ FRPLine migration completed. Total inserted/updated: ${total}`);
    if (skippedMissingFrp) {
      console.log(`⚠️ Skipped ${skippedMissingFrp} FRP lines because matching FRP detail records were not found.`);
    }
    if (skippedInvalidDate) {
      console.log(`⚠️ Skipped ${skippedInvalidDate} FRP lines due to invalid dates.`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateFRPLine;
