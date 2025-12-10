const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
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

/**
 * Migrate tblFaxLines → FaxLine
 * - Preserves legacy FaxId and FldId
 * - Does NOT yet resolve SapakSend FK (FLdId stays null)
 * - Fax FK (faxId) can be backfilled later once Fax rows are present
 */
async function migrateFaxLine(tenantId, branchId) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let total = 0;
  let offset = 0;

  try {
    // Build map: legacy FaxId (int) -> new Fax.id (string) for this tenant/branch
    const faxMap = new Map();
    {
      const { rows } = await pg.query(
        `
        SELECT id, "faxId"
        FROM "Fax"
        WHERE "tenantId" = $1
          AND "branchId" = $2
        `,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const legacy = asInteger(row.faxId);
        if (legacy !== null && !faxMap.has(legacy)) {
          faxMap.set(legacy, row.id);
        }
      }
    }
    const sapakSendMap = new Map();
    {
      const { rows } = await pg.query(
        `
        SELECT id, "sapakSendId"
        FROM "SapakSend"
        WHERE "tenantId" = $1 AND "branchId" = $2
        `,
        [tenantId, branchId]
      );

      for (const row of rows) {
        const legacy = asInteger(row.sapakSendId);
        if (legacy !== null && !sapakSendMap.has(legacy)) {
          sapakSendMap.set(legacy, row.id);
        }
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `
        SELECT FaxId, FldId
        FROM tblFaxLines
        ORDER BY FaxId, FldId
        LIMIT ${WINDOW_SIZE} OFFSET ?
        `,
        [offset]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        for (const row of chunk) {
          const legacyFaxId = asInteger(row.FaxId);
          const legacyFLdId = asInteger(row.FldId);
          const faxId =
            legacyFaxId !== null ? faxMap.get(legacyFaxId) || null : null;
          const fldId = legacyFLdId !== null ? sapakSendMap.get(legacyFLdId) || null : null;

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9})`
          );

          params.push(
            createId(),              // id
            tenantId,                // tenantId
            branchId,                // branchId
            legacyFaxId,             // legacyFaxId
            faxId,                   // faxId (FK to Fax.id)
            legacyFLdId,             // legacyFLdId
            fldId,                    // fldId (FK to SapakSend.id; future)
            now,                     // createdAt
            now                      // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "FaxLine" (
              id,
              "tenantId",
              "branchId",
              "legacyFaxId",
              "faxId",
              "legacyFLdId",
              "fldId",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId","branchId","legacyFaxId","legacyFLdId")
            DO UPDATE SET
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
          total += chunk.length;
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }
      }

      offset += rows.length;
      console.log(`FaxLine migrated: ${total} (offset=${offset})`);
    }

    console.log(`✅ FaxLine migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateFaxLine;
