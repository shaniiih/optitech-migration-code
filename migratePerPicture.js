const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  if (typeof value === "bigint") return Number(value);
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function safeDate(value) {
  if (!value) return null;
  const d = new Date(value);
  return Number.isFinite(d.getTime()) ? d : null;
}

function toBoolean(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "boolean") return value;
  if (typeof value === "number") return Number.isFinite(value) ? value !== 0 : null;
  const trimmed = String(value).trim().toLowerCase();
  if (!trimmed) return null;
  if (["1", "true", "t", "yes", "y"].includes(trimmed)) return true;
  if (["0", "false", "f", "no", "n"].includes(trimmed)) return false;
  return null;
}

async function migratePerPicture(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    // Preload PerData mapping (legacy PerId -> PerData.id) for branch; fallback to tenant-wide if empty.
    const perDataMap = new Map();
    try {
      let { rows } = await pg.query(
        `SELECT id, "perId"
           FROM "PerData"
          WHERE "tenantId" = $1
            AND "branchId" = $2`,
        [tenantId, branchId]
      );
      if (!rows.length) {
        console.warn(
          `⚠️ PerPicture: no PerData rows found for tenant=${tenantId} branchId=${branchId}; falling back to tenant-wide`
        );
        ({ rows } = await pg.query(`SELECT id, "perId" FROM "PerData" WHERE "tenantId" = $1`, [
          tenantId
        ]));
      }
      for (const row of rows) {
        const legacy = asInteger(row.perId);
        if (legacy !== null && !perDataMap.has(legacy)) {
          perDataMap.set(legacy, row.id);
        }
      }
    } catch (err) {
      console.warn("⚠️ PerPicture: failed to preload PerData mapping.", err.message);
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT PerPicId, PerId, PicFileName, Description, ScanDate, Notes, IsCon
           FROM tblPerPicture
          WHERE PerPicId > ?
          ORDER BY PerPicId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();
        const seen = new Set();

        for (const r of chunk) {
          const perPicId = asInteger(r.PerPicId);
          if (perPicId === null || seen.has(perPicId)) continue;
          seen.add(perPicId);

          const legacyPerId = asInteger(r.PerId);
          const perId = legacyPerId !== null ? perDataMap.get(legacyPerId) || null : null;
          const description =
            cleanText(r.Description) || (perPicId !== null ? `PerPic ${perPicId}` : "PerPic");

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9}, $${base + 10}, $${base + 11}, $${base + 12}, $${base + 13})`
          );

          params.push(
            uuidv4(),                     // id
            tenantId,                     // tenantId
            branchId,                     // branchId
            perPicId,                     // perPicId
            legacyPerId,                  // legacyPerId
            perId,                        // perId (FK -> PerData.id)
            cleanText(r.PicFileName),     // picFileName
            description,                  // description
            safeDate(r.ScanDate),         // scanDate
            cleanText(r.Notes),           // notes
            toBoolean(r.IsCon),           // isCon
            now,                          // createdAt
            now                           // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "PerPicture" (
               id,
               "tenantId",
               "branchId",
               "perPicId",
               "legacyPerId",
               "perId",
               "picFileName",
               description,
               "scanDate",
               notes,
               "isCon",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "perPicId") DO UPDATE SET
               "legacyPerId" = EXCLUDED."legacyPerId",
               "perId" = EXCLUDED."perId",
               "picFileName" = EXCLUDED."picFileName",
               description = EXCLUDED.description,
               "scanDate" = EXCLUDED."scanDate",
               notes = EXCLUDED.notes,
               "isCon" = EXCLUDED."isCon",
               "updatedAt" = EXCLUDED."updatedAt"`,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      const latest = asInteger(rows[rows.length - 1]?.PerPicId);
      if (latest !== null) lastId = latest;
      console.log(`PerPicture migrated so far: ${total} (lastPerPicId=${lastId})`);
    }

    console.log(`✅ PerPicture migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migratePerPicture;
