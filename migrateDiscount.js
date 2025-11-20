const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const BATCH_SIZE = 1000;
const WINDOW_SIZE = 5000;

async function migrateDiscount(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1; // include DiscountId = 0 in first window
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.execute(
        `SELECT DiscountId, DiscountName,
                prlGlass, prlTreat, prlClens, prlFrame, prlSunGlass, prlProp,
                prlSolution, prlService, prlCheck, prlMisc,
                prlGlassOneS, prlGlassOneP, prlGlassBif, prlGlassMul
         FROM tblDiscounts
         WHERE DiscountId > ?
         ORDER BY DiscountId
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
          // We insert 21 columns per row
          const placeholderStart = params.length + 1;
          const tuple = Array.from({ length: 21 }, (_, idx) => {
            const pos = placeholderStart + idx;
            return `$${pos}`;
          }).join(', ');
          values.push(`(${tuple})`);

          params.push(
            uuidv4(),                // id
            tenantId,                // tenantId
            branchId,                // branchId
            String(r.DiscountId),    // discountId (legacy id as text)
            r.DiscountName || null,  // daiscountName
            num(r.prlGlass),
            num(r.prlTreat),
            num(r.prlClens),
            num(r.prlFrame),
            num(r.prlSunGlass),
            num(r.prlProp),
            num(r.prlSolution),
            num(r.prlService),
            num(r.prlCheck),
            num(r.prlMisc),
            num(r.prlGlassOneS),
            num(r.prlGlassOneP),
            num(r.prlGlassBif),
            num(r.prlGlassMul),
            now,                     // createdAt
            now                      // updatedAt
          );
        });

        await pg.query("BEGIN");
        try {
          const sql = `
            INSERT INTO "Discount" (
              id,
              "tenantId",
              "branchId",
              "discountId",
              "daiscountName",
              "prlGlass",
              "prlTreat",
              "prlClens",
              "prlFrame",
              "prlSunGlass",
              "prlProp",
              "prlSolution",
              "prlService",
              "prlCheck",
              "prlMisc",
              "prlGlassOneS",
              "prlGlassOneP",
              "prlGlassBif",
              "prlGlassMul",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values
              .map(v => v)
              .join(",")}
            ON CONFLICT ("tenantId", "branchId", "discountId")
            DO UPDATE SET
              "daiscountName" = EXCLUDED."daiscountName",
              "prlGlass" = EXCLUDED."prlGlass",
              "prlTreat" = EXCLUDED."prlTreat",
              "prlClens" = EXCLUDED."prlClens",
              "prlFrame" = EXCLUDED."prlFrame",
              "prlSunGlass" = EXCLUDED."prlSunGlass",
              "prlProp" = EXCLUDED."prlProp",
              "prlSolution" = EXCLUDED."prlSolution",
              "prlService" = EXCLUDED."prlService",
              "prlCheck" = EXCLUDED."prlCheck",
              "prlMisc" = EXCLUDED."prlMisc",
              "prlGlassOneS" = EXCLUDED."prlGlassOneS",
              "prlGlassOneP" = EXCLUDED."prlGlassOneP",
              "prlGlassBif" = EXCLUDED."prlGlassBif",
              "prlGlassMul" = EXCLUDED."prlGlassMul",
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

      lastId = rows[rows.length - 1].DiscountId;
      console.log(`✔ Migrated discounts so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ Discount migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

function num(v) {
  if (v === null || v === undefined) return 0.0;
  const n = Number(v);
  return Number.isFinite(n) ? n : 0.0;
}

module.exports = migrateDiscount;
