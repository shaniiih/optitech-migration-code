const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;  // rows fetched from MySQL per window
const BATCH_SIZE  = 1000;  // rows inserted per Postgres txn

async function migrateProduct(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;

  try {
    // Ensure a unique index once (safe to keep here or run separately)
    await pg.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_indexes WHERE indexname = 'product_tenant_productid_ux'
        ) THEN
          CREATE UNIQUE INDEX product_tenant_productid_ux
          ON "Product" ("tenantId","productId");
        END IF;
      END$$;
    `);

    while (true) {
      const [rows] = await mysql.execute(
        `SELECT NewProdId, NewProdName, NewProdDesc, NewProdPic
         FROM tblNewProds
         WHERE NewProdId > ?
         ORDER BY NewProdId
         LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );
      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        for (const r of chunk) {
          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10}, $${params.length + 11}, $${params.length + 12}, $${params.length + 13}, $${params.length + 14}, $${params.length + 15})`
          );
          params.push(
            uuidv4(),                     // id
            tenantId,                     // "tenantId"
            String(r.NewProdId),          // "productId" (source PK)
            r.NewProdName || "",          // name
            r.NewProdDesc || "",          // description
            `SKU-${r.NewProdId}`,         // sku (generated)
            r.NewProdPic || null,         // barcode (placeholder)
            "General",                    // category
            "Unknown",                    // brand
            0,                            // costPrice
            0,                            // sellPrice
            0,                            // quantity
            true,                         // isActive
            now,                          // createdAt
            now                           // updatedAt
          );
        }

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "Product" (
              id, "tenantId", "productId", name, description,
              sku, barcode, category, brand,
              "costPrice", "sellPrice", quantity,
              "isActive", "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId","productId")
            DO UPDATE SET
              name = EXCLUDED.name,
              description = EXCLUDED.description,
              sku = EXCLUDED.sku,
              barcode = EXCLUDED.barcode,
              category = EXCLUDED.category,
              brand = EXCLUDED.brand,
              "costPrice" = EXCLUDED."costPrice",
              "sellPrice" = EXCLUDED."sellPrice",
              quantity = EXCLUDED.quantity,
              "isActive" = EXCLUDED."isActive",
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (e) {
          await pg.query("ROLLBACK");
          throw e;
        }

        total += chunk.length;
      }

      lastId = rows[rows.length - 1].NewProdId;
      console.log(`Products migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ Product migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateProduct;
