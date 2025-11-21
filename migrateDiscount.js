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
          const placeholderStart = params.length + 1;
          const tuple = Array.from({ length: 40 }, (_, idx) => {
            const pos = placeholderStart + idx;
            return `$${pos}`;
          }).join(", ");
          values.push(`(${tuple})`);

          const legacyId = String(r.DiscountId);
          const legacyName = r.DiscountName || null;

          const name = legacyName || `Legacy Discount ${legacyId}`;
          const code = `${tenantId}:${legacyId}`;

          params.push(
            uuidv4(),              // id
            tenantId,              // tenantId
            name,                  // name
            code,                  // code (globally unique)
            "PERCENTAGE",          // type
            0.0,                   // value
            "LEGACY_TABLE",        // appliesTo
            [],                    // productIds
            null,                  // minimumPurchase
            null,                  // maximumDiscount
            [],                    // customerGroupIds
            [],                    // customerIds
            null,                  // validFrom
            null,                  // validTo
            null,                  // usageLimit
            0,                     // usageCount
            null,                  // perCustomerLimit
            false,                 // combinable
            0,                     // priority
            true,                  // active
            false,                 // requiresApproval
            null,                  // notes
            legacyId,              // discountId (legacy)
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
            branchId,              // branchId
            now,                   // createdAt
            now                    // updatedAt
          );
        });

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          const sql = `
            INSERT INTO "Discount" (
              id,
              "tenantId",
              name,
              code,
              type,
              value,
              "appliesTo",
              "productIds",
              "minimumPurchase",
              "maximumDiscount",
              "customerGroupIds",
              "customerIds",
              "validFrom",
              "validTo",
              "usageLimit",
              "usageCount",
              "perCustomerLimit",
              combinable,
              priority,
              active,
              "requiresApproval",
              notes,
              "discountId",
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
              "branchId",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "discountId")
            DO UPDATE SET
              name = EXCLUDED.name,
              type = EXCLUDED.type,
              value = EXCLUDED.value,
              "appliesTo" = EXCLUDED."appliesTo",
              "productIds" = EXCLUDED."productIds",
              "minimumPurchase" = EXCLUDED."minimumPurchase",
              "maximumDiscount" = EXCLUDED."maximumDiscount",
              "customerGroupIds" = EXCLUDED."customerGroupIds",
              "customerIds" = EXCLUDED."customerIds",
              "validFrom" = EXCLUDED."validFrom",
              "validTo" = EXCLUDED."validTo",
              "usageLimit" = EXCLUDED."usageLimit",
              "usageCount" = EXCLUDED."usageCount",
              "perCustomerLimit" = EXCLUDED."perCustomerLimit",
              combinable = EXCLUDED.combinable,
              priority = EXCLUDED.priority,
              active = EXCLUDED.active,
              "requiresApproval" = EXCLUDED."requiresApproval",
              notes = EXCLUDED.notes,
              "discountId" = EXCLUDED."discountId",
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
