const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function normalizeInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  if (typeof value === "bigint") return Number(value);
  if (Buffer.isBuffer(value)) return normalizeInt(value.toString("utf8"));
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function cleanNumber(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? value : null;
  if (typeof value === "bigint") return Number(value);
  if (Buffer.isBuffer(value)) return cleanNumber(value.toString("utf8"));
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? parsed : null;
}

function cleanBoolean(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "boolean") return value;
  if (typeof value === "number") return value !== 0;
  const trimmed = String(value).trim().toLowerCase();
  if (!trimmed) return null;
  if (["1", "true", "t", "yes", "y"].includes(trimmed)) return true;
  if (["0", "false", "f", "no", "n"].includes(trimmed)) return false;
  return null;
}

async function migrateLnsPrice(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    // Maps from legacy IDs to new PKs for this tenant/branch
    const sapakMap = new Map();
    const lensTypeMap = new Map();
    const lensMaterMap = new Map();
    const lensCharMap = new Map();

    {
      const { rows } = await pg.query(
        `
        SELECT id, "SapakID"
        FROM "Sapak"
        WHERE "tenantId" = $1
          AND "branchId" = $2
        `,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const legacyId = normalizeInt(row.SapakID);
        if (legacyId !== null && !sapakMap.has(legacyId)) {
          sapakMap.set(legacyId, row.id);
        }
      }
    }

    {
      const { rows } = await pg.query(
        `
        SELECT id, "lensTypeId"
        FROM "LnsType"
        WHERE "tenantId" = $1
          AND "branchId" = $2
        `,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const legacyId = normalizeInt(row.lensTypeId);
        if (legacyId !== null && !lensTypeMap.has(legacyId)) {
          lensTypeMap.set(legacyId, row.id);
        }
      }
    }

    {
      const { rows } = await pg.query(
        `
        SELECT id, "lensMaterId"
        FROM "LnsMaterial"
        WHERE "tenantId" = $1
          AND "branchId" = $2
        `,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const legacyId = normalizeInt(row.lensMaterId);
        if (legacyId !== null && !lensMaterMap.has(legacyId)) {
          lensMaterMap.set(legacyId, row.id);
        }
      }
    }

    {
      const { rows } = await pg.query(
        `
        SELECT id, "lensCharId"
        FROM "LnsChar"
        WHERE "tenantId" = $1
          AND "branchId" = $2
        `,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const legacyId = normalizeInt(row.lensCharId);
        if (legacyId !== null && !lensCharMap.has(legacyId)) {
          lensCharMap.set(legacyId, row.id);
        }
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT SapakID, LensTypeID, LensMaterID, LensCharID, LensRng, LensInt, LensDiam, LensPM,
                Price, PubPrice, RecPrice, PrivPrice, Active
           FROM tblLnsPrices
          ORDER BY SapakID, LensTypeID, LensMaterID, LensCharID, LensRng, LensInt, LensDiam
          LIMIT ? OFFSET ?`,
        [WINDOW_SIZE, offset]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        for (const row of chunk) {
          const legacySapakId = normalizeInt(row.SapakID);
          const legacyLensTypeId = normalizeInt(row.LensTypeID);
          const legacyLensMaterId = normalizeInt(row.LensMaterID);
          const legacyLensCharId = normalizeInt(row.LensCharID);
          const lensRng = normalizeInt(row.LensRng);
          const lensInt = normalizeInt(row.LensInt);
          const lensDiam = normalizeInt(row.LensDiam);
          const lensPM = normalizeInt(row.LensPM);

         const sapakId = sapakMap.get(legacySapakId) || null;
         const lensTypeId = lensTypeMap.get(legacyLensTypeId) || null;
         const lensMaterId = lensMaterMap.get(legacyLensMaterId) || null;
          const lensCharId = lensCharMap.get(legacyLensCharId) || null;

          const price = cleanNumber(row.Price);
          const pubPrice = cleanNumber(row.PubPrice);
          const recPrice = cleanNumber(row.RecPrice);
          const privPrice = cleanNumber(row.PrivPrice);
          const active = cleanBoolean(row.Active);

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10}, $${params.length + 11}, $${params.length + 12}, $${params.length + 13}, $${params.length + 14}, $${params.length + 15}, $${params.length + 16}, $${params.length + 17}, $${params.length + 18}, $${params.length + 19}, $${params.length + 20}, $${params.length + 21}, $${params.length + 22})`
          );
          params.push(
            createId(),       // id
            tenantId,
            branchId,
            legacySapakId,
            sapakId,
            legacyLensTypeId,
            lensTypeId,
            legacyLensMaterId,
            lensMaterId,
            legacyLensCharId,
            lensCharId,
            lensRng,
            lensInt,
            lensDiam,
            lensPM,
            price,
            pubPrice,
            recPrice,
            privPrice,
            active,
            now, // createdAt
            now  // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "LnsPrice" (
              id,
              "tenantId",
              "branchId",
              "legacySapakId",
              "sapakId",
              "legacyLensTypeId",
              "lensTypeId",
              "legacyLensMaterId",
              "lensMaterId",
              "legacyLensCharId",
              "lensCharId",
              "lensRng",
              "lensInt",
              "lensDiam",
              "lensPM",
              "price",
              "pubPrice",
              "recPrice",
              "privPrice",
              "active",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "sapakId", "lensTypeId", "lensMaterId", "lensCharId", "lensRng", "lensInt", "lensDiam")
            DO UPDATE SET
              "legacySapakId"    = EXCLUDED."legacySapakId",
              "sapakId"          = EXCLUDED."sapakId",
              "legacyLensTypeId" = EXCLUDED."legacyLensTypeId",
              "lensTypeId"       = EXCLUDED."lensTypeId",
              "legacyLensMaterId"= EXCLUDED."legacyLensMaterId",
              "lensMaterId"      = EXCLUDED."lensMaterId",
              "legacyLensCharId" = EXCLUDED."legacyLensCharId",
              "lensCharId"       = EXCLUDED."lensCharId",
              "lensRng"          = EXCLUDED."lensRng",
              "lensInt"          = EXCLUDED."lensInt",
              "lensDiam"         = EXCLUDED."lensDiam",
              "lensPM"           = EXCLUDED."lensPM",
              "price"            = EXCLUDED."price",
              "pubPrice"         = EXCLUDED."pubPrice",
              "recPrice"         = EXCLUDED."recPrice",
              "privPrice"        = EXCLUDED."privPrice",
              "active"           = EXCLUDED."active",
              "updatedAt"        = NOW()
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

      offset += rows.length;
      console.log(`LnsPrice migrated so far: ${total} (offset=${offset})`);
    }

    console.log(`✅ LnsPrice migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateLnsPrice;
