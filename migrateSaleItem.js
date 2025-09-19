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
  const str = String(value).trim().replace(/,/g, ".");
  if (!str) return null;
  const num = Number(str);
  return Number.isFinite(num) ? num : null;
}

function asInteger(value) {
  const num = asNumber(value);
  return num === null ? null : Math.round(num);
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

async function migrateSaleItem(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;

  try {
    const existingSales = new Set();
    const { rows: saleRows } = await pg.query(
      `SELECT id FROM "Sale" WHERE "tenantId" = $1`,
      [tenantId]
    );
    for (const row of saleRows) {
      existingSales.add(row.id);
    }

    const productIdMap = new Map();
    const { rows: productRows } = await pg.query(
      `SELECT id, "productId" FROM "Product" WHERE "tenantId" = $1`,
      [tenantId]
    );
    for (const row of productRows) {
      const key = normalizeLegacyId(row.productId);
      if (key && !productIdMap.has(key)) {
        productIdMap.set(key, row.id);
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT CatId, BuyId, CatNum, Quantity, Price, Discount, CatLeft, ItemId
           FROM tblCrdBuysCatNums
          WHERE CatId > ?
          ORDER BY CatId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();

        for (const r of chunk) {
          const saleId = `${tenantId}-sale-${r.BuyId}`;
          if (!existingSales.has(saleId)) {
            continue;
          }

          const quantity = asInteger(r.Quantity) ?? 0;
          const unitPrice = asNumber(r.Price) ?? 0;
          const discountAmount = asNumber(r.Discount) ?? 0;
          const lineTotal = quantity * unitPrice - discountAmount;

          const id = `${tenantId}-sale-item-${r.CatId}`;
          const legacyProductKey = normalizeLegacyId(r.ItemId);
          let productId = null;
          if (legacyProductKey) {
            productId = productIdMap.get(legacyProductKey) || null;
          }
          const productName = cleanText(r.CatNum) || "Legacy item";

          const notesParts = [];
          const legacyCatLeft = cleanText(r.CatLeft);
          if (legacyCatLeft) notesParts.push(`Legacy CatLeft: ${legacyCatLeft}`);
          if (!productId && legacyProductKey) {
            notesParts.push(`Legacy ItemId: ${legacyProductKey}`);
          }
          const notes = notesParts.length ? notesParts.join("\n") : null;

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5},
               $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10},
               $${params.length + 11}, $${params.length + 12}, $${params.length + 13}, $${params.length + 14})`
          );

          params.push(
            id,
            saleId,
            productId,
            productName,
            null,
            cleanText(r.CatNum),
            quantity,
            unitPrice,
            0,
            discountAmount,
            lineTotal,
            null,
            notes,
            now
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "SaleItem" (
              id, "saleId", "productId", "productName", category, sku, quantity, "unitPrice",
              "discountPercent", "discountAmount", "lineTotal", "prescriptionData", notes,
              "createdAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              "productId" = EXCLUDED."productId",
              "productName" = EXCLUDED."productName",
              category = EXCLUDED.category,
              sku = EXCLUDED.sku,
              quantity = EXCLUDED.quantity,
              "unitPrice" = EXCLUDED."unitPrice",
              "discountPercent" = EXCLUDED."discountPercent",
              "discountAmount" = EXCLUDED."discountAmount",
              "lineTotal" = EXCLUDED."lineTotal",
              "prescriptionData" = EXCLUDED."prescriptionData",
              notes = EXCLUDED.notes,
              "createdAt" = EXCLUDED."createdAt"
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

      lastId = rows[rows.length - 1].CatId;
      console.log(`Sale items migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ SaleItem migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateSaleItem;
