const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function normalizeInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
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

async function migrateSolutionPrice(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    // Maps from legacy IDs to new PKs for this tenant/branch
    const sapakMap = new Map();
    const solutionMap = new Map();

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
        SELECT id, "solutionId"
        FROM "SolutionName"
        WHERE "tenantId" = $1
          AND "branchId" = $2
        `,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const legacyId = normalizeInt(row.solutionId);
        if (legacyId !== null && !solutionMap.has(legacyId)) {
          solutionMap.set(legacyId, row.id);
        }
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT SapakID, SolutionId, Price, PubPrice, RecPrice, PrivPrice, Active, Quantity
           FROM tblSolutionPrices
          ORDER BY SapakID, SolutionId
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
          const legacySolutionId = normalizeInt(row.SolutionId);

          const sapakId = sapakMap.get(legacySapakId) || null;
          const solutionId = solutionMap.get(legacySolutionId) || null;

          const price = cleanNumber(row.Price);
          const pubPrice = cleanNumber(row.PubPrice);
          const recPrice = cleanNumber(row.RecPrice);
          const privPrice = cleanNumber(row.PrivPrice);
          const active = cleanBoolean(row.Active);
          const quantity = normalizeInt(row.Quantity);

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10}, $${params.length + 11}, $${params.length + 12}, $${params.length + 13}, $${params.length + 14}, $${params.length + 15})`
          );
          params.push(
            createId(),      // id
            tenantId,
            branchId,
            legacySapakId,
            sapakId,
            legacySolutionId,
            solutionId,
            price,
            pubPrice,
            recPrice,
            privPrice,
            active,
            quantity,
            now, // createdAt
            now  // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "SolutionPrice" (
              id,
              "tenantId",
              "branchId",
              "legacySapakId",
              "sapakId",
              "legacySolutionId",
              "solutionId",
              "price",
              "pubPrice",
              "recPrice",
              "privPrice",
              "active",
              "quantity",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "sapakId", "solutionId")
            DO UPDATE SET
              "price"         = EXCLUDED."price",
              "pubPrice"      = EXCLUDED."pubPrice",
              "recPrice"      = EXCLUDED."recPrice",
              "privPrice"     = EXCLUDED."privPrice",
              "active"        = EXCLUDED."active",
              "quantity"      = EXCLUDED."quantity",
              "updatedAt"     = NOW()
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
      console.log(`SolutionPrice migrated so far: ${total} (offset=${offset})`);
    }

    console.log(`✅ SolutionPrice migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateSolutionPrice;

