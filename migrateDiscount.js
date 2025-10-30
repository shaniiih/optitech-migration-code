const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const BATCH_SIZE = 1000;
const WINDOW_SIZE = 5000;

async function migrateDiscount(tenantId = "tenant_1") {
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
          // Build placeholders programmatically to guarantee 39 placeholders
          const placeholderStart = params.length + 1;
          const casts = {
            8: '::text[]',   // productIds
            11: '::text[]',  // customerGroupIds
            12: '::text[]',  // customerIds
            13: '::timestamp', // validFrom
            14: '::timestamp', // validTo
          };
          const tuple = Array.from({ length: 39 }, (_, idx) => {
            const pos = placeholderStart + idx;
            const cast = casts[idx + 1] || '';
            return `$${pos}${cast}`;
          }).join(', ');
          values.push(`(${tuple})`);

          // Build code with pure random suffix for uniqueness
          const baseCode = `CODE_${String(r.DiscountId ?? "")}`;
          const rand6 = Math.random().toString(36).slice(2, 8).toUpperCase();
          const uniqueCode = `${baseCode}_${rand6}`;
          const code = String(r.DiscountId);
          params.push(
            uuidv4(),             // id
            tenantId,             // tenantId
            r.DiscountName || `Discount ${uniqueCode}`, // name
            uniqueCode,                 // code
            "percentage",         // type
            0.0,                  // value
            "category",           // appliesTo
            null,                 // productIds
            null,                 // minimumPurchase
            null,                 // maximumDiscount
            null,                 // customerGroupIds
            null,                 // customerIds
            null,                 // validFrom
            null,                 // validTo
            null,                 // usageLimit
            0,                    // usageCount
            null,                 // perCustomerLimit
            false,                // combinable
            0,                    // priority
            true,                 // active
            false,                // requiresApproval
            null,                 // notes
            now,                  // createdAt
            now,                  // updatedAt
            code,                 // discountId (legacy id as text)
            num(r.prlCheck),
            num(r.prlClens),
            num(r.prlFrame),
            num(r.prlGlass),
            num(r.prlGlassBif),
            num(r.prlGlassMul),
            num(r.prlGlassOneP),
            num(r.prlGlassOneS),
            num(r.prlMisc),
            num(r.prlProp),
            num(r.prlService),
            num(r.prlSolution),
            num(r.prlSunGlass),
            num(r.prlTreat)
          );
        });

        await pg.query("BEGIN");
        try {
          const sql = `
            INSERT INTO "Discount" (
              id, "tenantId", name, code, type, value, "appliesTo", "productIds", "minimumPurchase", "maximumDiscount",
              "customerGroupIds", "customerIds", "validFrom", "validTo", "usageLimit", "usageCount", "perCustomerLimit",
              combinable, priority, active, "requiresApproval", notes, "createdAt", "updatedAt", "discountId",
              "prlCheck", "prlClens", "prlFrame", "prlGlass", "prlGlassBif", "prlGlassMul", "prlGlassOneP", "prlGlassOneS",
              "prlMisc", "prlProp", "prlService", "prlSolution", "prlSunGlass", "prlTreat"
            )
            VALUES ${values
              .map(v => v)
              .join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              name = EXCLUDED.name,
              type = EXCLUDED.type,
              value = EXCLUDED.value,
              "appliesTo" = EXCLUDED."appliesTo",
              active = EXCLUDED.active,
              "updatedAt" = EXCLUDED."updatedAt",
              "prlCheck" = EXCLUDED."prlCheck",
              "prlClens" = EXCLUDED."prlClens",
              "prlFrame" = EXCLUDED."prlFrame",
              "prlGlass" = EXCLUDED."prlGlass",
              "prlGlassBif" = EXCLUDED."prlGlassBif",
              "prlGlassMul" = EXCLUDED."prlGlassMul",
              "prlGlassOneP" = EXCLUDED."prlGlassOneP",
              "prlGlassOneS" = EXCLUDED."prlGlassOneS",
              "prlMisc" = EXCLUDED."prlMisc",
              "prlProp" = EXCLUDED."prlProp",
              "prlService" = EXCLUDED."prlService",
              "prlSolution" = EXCLUDED."prlSolution",
              "prlSunGlass" = EXCLUDED."prlSunGlass",
              "prlTreat" = EXCLUDED."prlTreat"
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
