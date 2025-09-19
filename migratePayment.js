const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function asNumber(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? value : null;
  }
  const trimmed = String(value).trim().replace(/,/g, ".");
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? parsed : null;
}

function normalizeDate(value) {
  if (value === null || value === undefined) return null;

  if (typeof value === "string") {
    const trimmed = value.trim();
    if (!trimmed) return null;
    if (/^0{4}-0{2}-0{2}/.test(trimmed)) return null;
    const parsed = new Date(trimmed);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value;
  }

  if (typeof value === "number") {
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  return null;
}

function normalizeLegacyId(value) {
  if (value === null || value === undefined) return null;

  if (typeof value === "number" && Number.isFinite(value)) {
    return String(value);
  }

  if (typeof value === "bigint") {
    return value.toString();
  }

  if (Buffer.isBuffer(value)) {
    return normalizeLegacyId(value.toString("utf8"));
  }

  const trimmed = String(value).trim();
  if (!trimmed) return null;

  if (/^[+-]?\d+(?:\.0+)?$/.test(trimmed)) {
    return String(parseInt(trimmed, 10));
  }

  return trimmed.toLowerCase();
}

async function migratePayment(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  let skippedMissingSale = 0;

  try {
    const { rows: saleRows } = await pg.query(
      `SELECT id, "saleId", "customerId", "branchId", "sellerId" FROM "Sale" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const saleMap = new Map();
    for (const row of saleRows) {
      saleMap.set(String(row.saleId), row);
    }

    const payTypeMap = new Map();
    const [payTypeRows] = await mysql.query(
      `SELECT PayTypeId, PayTypeName FROM tblPayTypes`
    );
    for (const row of payTypeRows) {
      const key = normalizeLegacyId(row.PayTypeId);
      if (key) {
        payTypeMap.set(key, cleanText(row.PayTypeName) || `TYPE-${row.PayTypeId}`);
      }
    }

    const creditCardMap = new Map();
    const [creditCardRows] = await mysql.query(
      `SELECT CreditCardId, CreditCardName FROM tblCreditCards`
    );
    for (const row of creditCardRows) {
      const key = normalizeLegacyId(row.CreditCardId);
      if (key) {
        creditCardMap.set(key, cleanText(row.CreditCardName) || `CARD-${row.CreditCardId}`);
      }
    }

    const creditTypeMap = new Map();
    const [creditTypeRows] = await mysql.query(
      `SELECT CreditTypeId, CreditTypeName FROM tblCreditTypes`
    );
    for (const row of creditTypeRows) {
      const key = normalizeLegacyId(row.CreditTypeId);
      if (key) {
        creditTypeMap.set(key, cleanText(row.CreditTypeName) || `TYPE-${row.CreditTypeId}`);
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT BuyPayId, BuyId, InvId, PayTypeId, PayDate, PaySum, CreditId, CreditCardId, CreditTypeId, CreditPayNum
           FROM tblCrdBuysPays
          WHERE BuyPayId > ?
          ORDER BY BuyPayId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const r of chunk) {
          const saleEntry = saleMap.get(String(r.BuyId)) || null;
          if (!saleEntry) {
            skippedMissingSale += 1;
            continue;
          }

          const saleId = saleEntry.id;
          const customerId = saleEntry.customerId;
          const branchId = saleEntry.branchId;
          const createdBy = saleEntry.sellerId || "system";

          const paymentDate = normalizeDate(r.PayDate) || new Date();
          const amount = asNumber(r.PaySum) ?? 0;

          const paymentType = payTypeMap.get(normalizeLegacyId(r.PayTypeId)) || "UNKNOWN";
          const cardType = creditTypeMap.get(normalizeLegacyId(r.CreditTypeId)) || null;
          const cardBrand = creditCardMap.get(normalizeLegacyId(r.CreditCardId)) || null;

          const paymentNumber = `${tenantId}-payment-${r.BuyPayId}`;
          const invoiceId = cleanText(r.InvId);
          const receiptIssued = Boolean(invoiceId);

          const authCode = cleanText(r.CreditId);
          let cardLastFour = null;
          if (authCode && /\d{4,}$/.test(authCode)) {
            cardLastFour = authCode.slice(-4);
          }

          const notesParts = [];
          if (cardBrand) notesParts.push(`Card brand: ${cardBrand}`);
          if (r.CreditPayNum) notesParts.push(`Installments: ${r.CreditPayNum}`);
          if (authCode) notesParts.push(`Legacy reference: ${authCode}`);
          const notes = notesParts.length ? notesParts.join("\n") : null;

          const paramsBase = params.length;
          values.push(
            `($${paramsBase + 1}, $${paramsBase + 2}, $${paramsBase + 3}, $${paramsBase + 4}, $${paramsBase + 5},
               $${paramsBase + 6}, $${paramsBase + 7}, $${paramsBase + 8}, $${paramsBase + 9}, $${paramsBase + 10},
               $${paramsBase + 11}, $${paramsBase + 12}, $${paramsBase + 13}, $${paramsBase + 14}, $${paramsBase + 15},
               $${paramsBase + 16}, $${paramsBase + 17}, $${paramsBase + 18}, $${paramsBase + 19}, $${paramsBase + 20},
               $${paramsBase + 21}, $${paramsBase + 22}, $${paramsBase + 23}, $${paramsBase + 24}, $${paramsBase + 25},
               $${paramsBase + 26})`
          );

          params.push(
            `${tenantId}-payment-${r.BuyPayId}`,
            tenantId,
            branchId,
            paymentNumber,
            paymentDate,
            saleId,
            invoiceId,
            customerId,
            paymentType,
            amount,
            "ILS",
            cardLastFour,
            cardType,
            authCode,
            null,
            null,
            null,
            null,
            null,
            "COMPLETED",
            invoiceId,
            receiptIssued,
            notes,
            createdBy,
            paymentDate,
            paymentDate
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "Payment" (
              id, "tenantId", "branchId", "paymentNumber", "paymentDate", "saleId", "invoiceId",
              "customerId", "paymentType", amount, currency, "cardLastFour", "cardType", "authCode",
              "checkNumber", "checkDate", "bankName", "bankBranch", "transferRef", status,
              "receiptNumber", "receiptIssued", notes, "createdBy", "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              "branchId" = EXCLUDED."branchId",
              "paymentNumber" = EXCLUDED."paymentNumber",
              "paymentDate" = EXCLUDED."paymentDate",
              "saleId" = EXCLUDED."saleId",
              "invoiceId" = EXCLUDED."invoiceId",
              "customerId" = EXCLUDED."customerId",
              "paymentType" = EXCLUDED."paymentType",
              amount = EXCLUDED.amount,
              currency = EXCLUDED.currency,
              "cardLastFour" = EXCLUDED."cardLastFour",
              "cardType" = EXCLUDED."cardType",
              "authCode" = EXCLUDED."authCode",
              status = EXCLUDED.status,
              "receiptNumber" = EXCLUDED."receiptNumber",
              "receiptIssued" = EXCLUDED."receiptIssued",
              notes = EXCLUDED.notes,
              "createdBy" = EXCLUDED."createdBy",
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }

        total += values.length;
      }

      lastId = rows[rows.length - 1].BuyPayId;
      console.log(`Payments migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ Payment migration completed. Total inserted/updated: ${total}`);
    if (skippedMissingSale) {
      console.warn(`⚠️ Skipped ${skippedMissingSale} payments because related sales were not found`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migratePayment;
