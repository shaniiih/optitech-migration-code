const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

const BRAND_SOURCES = [
  {
    table: "tblCrdClensBrands",
    idColumn: "ClensBrandId",
    nameColumn: "ClensBrandName",
    type: "CONTACT_LENS",
    fallbackLabel: "Contact Lens",
  },
  {
    table: "tblCrdGlassBrand",
    idColumn: "GlassBrandId",
    nameColumn: "GlassBrandName",
    type: "GLASS",
    fallbackLabel: "Glass",
  },
];

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  const str = String(value).trim();
  if (!str) return null;
  const num = Number(str);
  return Number.isFinite(num) ? Math.trunc(num) : null;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

async function migrateBrand(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  try {
    for (const source of BRAND_SOURCES) {
      await migrateFromSource(mysql, pg, tenantId, source);
    }
    console.log(`✅ Brand migration completed for tenant ${tenantId}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

async function migrateFromSource(mysql, pg, tenantId, source) {
  let lastId = -1;
  let processed = 0;
  let skippedInvalidId = 0;

  while (true) {
    const [rows] = await mysql.query(
      `SELECT ${source.idColumn} AS id, ${source.nameColumn} AS name
         FROM ${source.table}
        WHERE ${source.idColumn} > ?
        ORDER BY ${source.idColumn}
        LIMIT ${WINDOW_SIZE}`,
      [lastId]
    );

    if (!rows.length) {
      break;
    }

    for (let i = 0; i < rows.length; i += BATCH_SIZE) {
      const chunk = rows.slice(i, i + BATCH_SIZE);
      const values = [];
      const params = [];
      const timestamp = new Date();

      for (const row of chunk) {
        const brandId = asInteger(row.id);
        if (brandId === null) {
          skippedInvalidId += 1;
          continue;
        }

        const name =
          cleanText(row.name) || `${source.fallbackLabel} Brand ${brandId}`;
        const idCount = String(brandId);

        const offset = params.length;
        values.push(
          `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8})`
        );
        params.push(
          uuidv4(),
          tenantId,
          name,
          source.type,
          idCount,
          true,
          timestamp,
          timestamp
        );
      }

      if (!values.length) continue;

      await pg.query("BEGIN");
      try {
        await pg.query(
          `INSERT INTO "Brand" (
              id,
              "tenantId",
              name,
              type,
              "IdCount",
              "isActive",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", name, type) DO UPDATE SET
              "IdCount" = EXCLUDED."IdCount",
              "isActive" = EXCLUDED."isActive",
              "updatedAt" = EXCLUDED."updatedAt"`,
          params
        );
        await pg.query("COMMIT");
        processed += values.length;
      } catch (error) {
        await pg.query("ROLLBACK");
        throw error;
      }
    }

    lastId = asInteger(rows[rows.length - 1].id) ?? lastId;
    console.log(
      `Brand migration (${source.type}) processed so far: ${processed} (lastId=${lastId})`
    );
  }

  if (skippedInvalidId) {
    console.warn(
      `⚠️ Skipped ${skippedInvalidId} rows from ${source.table} due to invalid id`
    );
  }

  console.log(
    `✅ Brand migration (${source.type}) finished. Total processed from ${source.table}: ${processed}`
  );
}

module.exports = migrateBrand;
