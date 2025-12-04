const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function normalizeInt(v) {
  if (v === null || v === undefined) return null;
  if (typeof v === "number") return Number.isFinite(v) ? Math.trunc(v) : null;
  if (typeof v === "bigint") return Number(v);
  if (Buffer.isBuffer(v)) return normalizeInt(v.toString("utf8"));
  const t = String(v).trim();
  if (!t) return null;
  const n = Number(t);
  return Number.isFinite(n) ? Math.trunc(n) : null;
}

function cleanNumber(v) {
  if (v === null || v === undefined) return null;
  if (typeof v === "number") return Number.isFinite(v) ? v : null;
  if (typeof v === "bigint") return Number(v);
  if (Buffer.isBuffer(v)) return cleanNumber(v.toString("utf8"));
  const t = String(v).trim();
  if (!t) return null;
  const n = Number(t);
  return Number.isFinite(n) ? n : null;
}

async function migrateCrdBuysPay(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    const buyMap = new Map();
    const { rows: buyRows } = await pg.query(
      `SELECT id, "buyId", "branchId" FROM "CrdBuy" WHERE "tenantId" = $1`,
      [tenantId]
    );
    for (const r of buyRows) {
      const v = normalizeInt(r.buyId);
      if (v !== null) buyMap.set(`${r.branchId}_${v}`, r.id);
    }

    const payTypeMap = new Map();
    const { rows: payTypeRows } = await pg.query(
      `SELECT id, "payTypeId" FROM "PayType" WHERE "tenantId" = $1`,
      [tenantId]
    );
    for (const r of payTypeRows) {
      const v = normalizeInt(r.payTypeId);
      if (v !== null) payTypeMap.set(v, r.id);
    }

    const creditCardMap = new Map();
    const { rows: cardRows } = await pg.query(
      `SELECT id, "creditCardId" FROM "CreditCard" WHERE "tenantId" = $1`,
      [tenantId]
    );
    for (const r of cardRows) {
      const v = normalizeInt(r.creditCardId);
      if (v !== null) creditCardMap.set(v, r.id);
    }

    const creditTypeMap = new Map();
    const { rows: creditTypeRows } = await pg.query(
      `SELECT id, "creditTypeId" FROM "CreditType" WHERE "tenantId" = $1`,
      [tenantId]
    );
    for (const r of creditTypeRows) {
      const v = normalizeInt(r.creditTypeId);
      if (v !== null) creditTypeMap.set(v, r.id);
    }

    while (true) {
      const [rows] = await mysql.query(
        `
        SELECT 
          BuyPayId,
          BuyId,
          PayTypeId,
          PayDate,
          PaySum,
          CreditId,
          CreditCardId,
          CreditTypeId,
          CreditPayNum
        FROM tblCrdBuysPays
        ORDER BY BuyPayId
        LIMIT ? OFFSET ?
        `,
        [WINDOW_SIZE, offset]
      );
      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();

        for (const row of chunk) {
          const legacyBuyPayId = normalizeInt(row.BuyPayId);
          const legacyBuyId = normalizeInt(row.BuyId);
          const legacyPayTypeId = normalizeInt(row.PayTypeId);
          const legacyCreditCardId = normalizeInt(row.CreditCardId);
          const legacyCreditTypeId = normalizeInt(row.CreditTypeId);

          const newBuyId = buyMap.get(`${branchId}_${legacyBuyId}`) || null;
          const newPayTypeId = payTypeMap.get(legacyPayTypeId) || null;
          const newCreditCardId = creditCardMap.get(legacyCreditCardId) || null;
          const newCreditTypeId = creditTypeMap.get(legacyCreditTypeId) || null;

          const base = params.length;

          values.push(
            `(
              $${base + 1},  $${base + 2},  $${base + 3},
              $${base + 4},  $${base + 5},  $${base + 6},
              $${base + 7},  $${base + 8},  $${base + 9},
              $${base + 10}, $${base + 11}, $${base + 12},
              $${base + 13}, $${base + 14}, $${base + 15},
              $${base + 16}, $${base + 17}, $${base + 18},
              $${base + 19}
            )`
          );


          params.push(
            createId(),               
            tenantId,                
            branchId,                 
            legacyBuyPayId,           
            legacyBuyId,               
            newBuyId,                 
            legacyPayTypeId,          
            newPayTypeId,             
            legacyCreditCardId,        
            newCreditCardId,          
            legacyCreditTypeId,        
            newCreditTypeId,           
            row.invId || null,        
            row.PayDate ? new Date(row.PayDate) : null, 
            cleanNumber(row.PaySum),   
            row.CreditId || null,     
            normalizeInt(row.CreditPayNum), 
            now,
            now                        
          );

        }

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "CrdBuysPay" (
              id, "tenantId", "branchId",
              "buyPayId", "legacyBuyId", "buyId",
              "legacyPayTypeId", "payTypeId",
              "legacyCreditCardId", "creditCardId",
              "legacyCreditTypeId", "creditTypeId",
              "invId",
              "payDate", "paySum",
              "creditId", "creditPayNum",
              "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId","branchId","buyPayId")
            DO UPDATE SET
              "legacyBuyId" = EXCLUDED."legacyBuyId",
              "buyId" = EXCLUDED."buyId",
              "legacyPayTypeId" = EXCLUDED."legacyPayTypeId",
              "payTypeId" = EXCLUDED."payTypeId",
              "legacyCreditCardId" = EXCLUDED."legacyCreditCardId",
              "creditCardId" = EXCLUDED."creditCardId",
              "legacyCreditTypeId" = EXCLUDED."legacyCreditTypeId",
              "creditTypeId" = EXCLUDED."creditTypeId",
              "invId" = EXCLUDED."invId",
              "payDate" = EXCLUDED."payDate",
              "paySum" = EXCLUDED."paySum",
              "creditId" = EXCLUDED."creditId",
              "creditPayNum" = EXCLUDED."creditPayNum",
              "updatedAt" = NOW()
            `,
            params
          );
          await pg.query("COMMIT");
          total += chunk.length;
        } catch (e) {
          await pg.query("ROLLBACK");
          throw e;
        }
      }

      offset += rows.length;
    }
  } finally {
    await mysql.end();
    await pg.end();
  }

  console.log("CrdBuysPay migration completed:", total);
}

module.exports = migrateCrdBuysPay;
