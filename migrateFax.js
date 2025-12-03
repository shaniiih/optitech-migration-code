const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");
const { ensureTenantId } = require("./tenantUtils");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const s = String(value).trim();
  return s.length ? s : null;
}

function asInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  const s = String(value).trim();
  if (!s) return null;
  const n = Number(s);
  return Number.isFinite(n) ? Math.trunc(n) : null;
}

async function migrateFax(tenantId = "tenant_1", branchId) {
  tenantId = ensureTenantId(tenantId, "tenant_1");
  if (!branchId) {
    throw new Error("migrateFax requires a non-null BRANCH_ID");
  }

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    // Build maps from legacy ids to new UUIDs for this tenant+branch
    const faxStatMap = new Map(); // legacy faxStatId -> FaxStat.id
    {
      const { rows } = await pg.query(
        `SELECT id, "faxStatId"
           FROM "FaxStat"
          WHERE "tenantId" = $1 AND "branchId" = $2`,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const legacyId = asInt(row.faxStatId);
        if (legacyId !== null && !faxStatMap.has(legacyId)) {
          faxStatMap.set(legacyId, row.id);
        }
      }
    }

    const sapakDestMap = new Map(); // legacy SapakDestId -> SapakDest.id
    {
      const { rows } = await pg.query(
        `SELECT id, "sapakDestId"
           FROM "SapakDest"
          WHERE "tenantId" = $1 AND "branchId" = $2`,
        [tenantId, branchId]
      );
      for (const row of rows) {
        const legacyId = asInt(row.sapakDestId);
        if (legacyId !== null && !sapakDestMap.has(legacyId)) {
          sapakDestMap.set(legacyId, row.id);
        }
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT FaxId, SapakDestId, SendTime, JobInfo, faxStatId
           FROM tblFaxes
          ORDER BY FaxId
          LIMIT ${WINDOW_SIZE}
          OFFSET ${offset}`
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();

        for (const r of chunk) {
          const faxId = asInt(r.FaxId);
          if (faxId === null) {
            throw new Error(`Fax: invalid FaxId '${r.FaxId}'`);
          }

          const legacySapakDestId = asInt(r.SapakDestId);
          const legacyFaxStatId = asInt(r.faxStatId);

          const sapakDestId =
            legacySapakDestId !== null ? sapakDestMap.get(legacySapakDestId) || null : null;
          const faxStatId =
            legacyFaxStatId !== null ? faxStatMap.get(legacyFaxStatId) || null : null;

          const sendTime =
            r.SendTime != null ? new Date(r.SendTime) : null;

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9}, $${base + 10}, $${base + 11}, $${base + 12})`
          );
          params.push(
            createId(),                         // id
            tenantId,                         // tenantId
            branchId,                         // branchId
            faxId,                            // faxId
            legacySapakDestId,                // legacySapakDestId
            sapakDestId,                      // sapakDestId (UUID)
            sendTime,                         // sendTime
            cleanText(r.JobInfo),             // jobInfo
            legacyFaxStatId,                  // legacyFaxStatId
            faxStatId,                        // faxStatId (UUID)
            now,                              // createdAt
            now                               // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "Fax" (
              id,
              "tenantId",
              "branchId",
              "faxId",
              "legacySapakDestId",
              "sapakDestId",
              "sendTime",
              "jobInfo",
              "legacyFaxStatId",
              "faxStatId",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "faxId")
            DO UPDATE SET
              "legacySapakDestId" = EXCLUDED."legacySapakDestId",
              "sapakDestId"       = EXCLUDED."sapakDestId",
              "sendTime"          = EXCLUDED."sendTime",
              "jobInfo"           = EXCLUDED."jobInfo",
              "legacyFaxStatId"   = EXCLUDED."legacyFaxStatId",
              "faxStatId"         = EXCLUDED."faxStatId",
              "updatedAt"         = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (e) {
          await pg.query("ROLLBACK");
          throw e;
        }
      }

      offset += rows.length;
      console.log(`Fax migrated so far: ${total} (offset=${offset})`);
    }

    console.log(`✅ Fax migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateFax;
