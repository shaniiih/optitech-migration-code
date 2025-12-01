const { v4: uuidv4 } = require("uuid");
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

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

async function migrateSpecial(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    // Maps from legacy IDs to new PKs for this tenant/branch
    const sapakMap = new Map();
    const specialNameMap = new Map();
    const prlTypeMap = new Map();

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
        SELECT id, "specialId"
        FROM "SpecialName"
        WHERE "tenantId" = $1
          AND "branchId" = $2
        `,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const legacyId = normalizeInt(row.specialId);
        if (legacyId !== null && !specialNameMap.has(legacyId)) {
          specialNameMap.set(legacyId, row.id);
        }
      }
    }

    {
      const { rows } = await pg.query(
        `
        SELECT id, "prlType"
        FROM "PrlType"
        WHERE "tenantId" = $1
          AND "branchId" = $2
        `,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const legacyId = normalizeInt(row.prlType);
        if (legacyId !== null && !prlTypeMap.has(legacyId)) {
          prlTypeMap.set(legacyId, row.id);
        }
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT SapakID, SpecialId, PrlType, Priority, Price, PubPrice, RecPrice, PrivPrice, Formula, data, RLOnly, Active
           FROM tblSpecials
          ORDER BY SapakID, SpecialId
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
          const legacySpecialId = normalizeInt(row.SpecialId);
          const legacyPrlTypeId = normalizeInt(row.PrlType);

          const sapakId = sapakMap.get(legacySapakId) || null;
          const specialId = specialNameMap.get(legacySpecialId) || null;
          const prlTypeId = legacyPrlTypeId !== null ? prlTypeMap.get(legacyPrlTypeId) || null : null;

          const priority = normalizeInt(row.Priority);
          const price = cleanNumber(row.Price);
          const pubPrice = cleanNumber(row.PubPrice);
          const recPrice = cleanNumber(row.RecPrice);
          const privPrice = cleanNumber(row.PrivPrice);
          const formula = cleanText(row.Formula);
          const data = cleanText(row.data);
          const rLOnly = cleanBoolean(row.RLOnly);
          const active = cleanBoolean(row.Active);

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9}, $${base + 10}, $${base + 11}, $${base + 12}, $${base + 13}, $${base + 14}, $${base + 15}, $${base + 16}, $${base + 17}, $${base + 18}, $${base + 19}, $${base + 20})`
          );
          params.push(
            uuidv4(),        // id
            tenantId,
            branchId,
            legacySapakId,
            sapakId,
            legacySpecialId,
            specialId,
            legacyPrlTypeId,
            prlTypeId,
            priority,
            price,
            pubPrice,
            recPrice,
            privPrice,
            formula,
            data,
            rLOnly,
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
            INSERT INTO "Special" (
              id,
              "tenantId",
              "branchId",
              "legacySapakId",
              "sapakId",
              "legacySpecialId",
              "specialId",
              "legacyPrlTypeId",
              "prlTypeId",
              "priority",
              "price",
              "pubPrice",
              "recPrice",
              "privPrice",
              "formula",
              "data",
              "rLOnly",
              "active",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "sapakId", "specialId")
            DO UPDATE SET
              "priority"        = EXCLUDED."priority",
              "price"           = EXCLUDED."price",
              "pubPrice"        = EXCLUDED."pubPrice",
              "recPrice"        = EXCLUDED."recPrice",
              "privPrice"       = EXCLUDED."privPrice",
              "formula"         = EXCLUDED."formula",
              "data"            = EXCLUDED."data",
              "rLOnly"          = EXCLUDED."rLOnly",
              "active"          = EXCLUDED."active",
              "updatedAt"       = NOW()
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
      console.log(`Special migrated so far: ${total} (offset=${offset})`);
    }

    console.log(`✅ Special migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateSpecial;
