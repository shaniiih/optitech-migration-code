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

async function migrateLnsTreatRule(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    // Maps from legacy IDs to new PKs for this tenant/branch
    const sapakMap = new Map();
    const treatTypeMap = new Map();
    const treatCharMap = new Map();

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
        SELECT id, "treatId"
        FROM "LnsTreatType"
        WHERE "tenantId" = $1
          AND "branchId" = $2
        `,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const legacyId = normalizeInt(row.treatId);
        if (legacyId !== null && !treatTypeMap.has(legacyId)) {
          treatTypeMap.set(legacyId, row.id);
        }
      }
    }

    {
      const { rows } = await pg.query(
        `
        SELECT id, "treatCharId"
        FROM "LnsTreatChar"
        WHERE "tenantId" = $1
          AND "branchId" = $2
        `,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const legacyId = normalizeInt(row.treatCharId);
        if (legacyId !== null && !treatCharMap.has(legacyId)) {
          treatCharMap.set(legacyId, row.id);
        }
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT SapakID, TreatId, TreatCharID, FldName, TreatRule
           FROM tblLnsTreatRules
          ORDER BY SapakID, TreatId, TreatCharID
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
          const legacyTreatId = normalizeInt(row.TreatId);
          const legacyTreatCharId = normalizeInt(row.TreatCharID);

          const sapakId = sapakMap.get(legacySapakId) || null;
          const treatId = treatTypeMap.get(legacyTreatId) || null;
          const treatCharId = treatCharMap.get(legacyTreatCharId) || null;

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10}, $${params.length + 11}, $${params.length + 12}, $${params.length + 13})`
          );
          params.push(
            createId(),        // id
            tenantId,
            branchId,
            legacySapakId,
            sapakId,
            legacyTreatId,
            treatId,
            legacyTreatCharId,
            treatCharId,
            row.FldName || null,
            row.TreatRule || null,
            now, // createdAt
            now  // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "LnsTreatRule" (
              id,
              "tenantId",
              "branchId",
              "legacySapakId",
              "sapakId",
              "legacyTreatId",
              "treatId",
              "legacyTreatCharId",
              "treatCharId",
              "fldName",
              "treatRule",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "legacySapakId", "legacyTreatId", "legacyTreatCharId")
            DO UPDATE SET
              "fldName"           = EXCLUDED."fldName",
              "treatRule"         = EXCLUDED."treatRule",
              "updatedAt"         = NOW()
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
      console.log(`LnsTreatRule migrated so far: ${total} (offset=${offset})`);
    }

    console.log(`✅ LnsTreatRule migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateLnsTreatRule;
