const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function normalizeInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  if (typeof value === "bigint") return Number(value);
  const n = Number(String(value).trim());
  return Number.isFinite(n) ? Math.trunc(n) : null;
}

async function migrateLnsTreatTypeConnect(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    // Build maps from legacy IDs to new IDs in Postgres
    const buildMap = async (table, legacyField) => {
      const map = new Map();
      const { rows } = await pg.query(
        `SELECT id, "${legacyField}" FROM "${table}" WHERE "tenantId" = $1 AND "branchId" = $2`,
        [tenantId, branchId]
      );
      for (const r of rows) {
        const legacy = normalizeInt(r[legacyField]);
        if (legacy !== null && !map.has(legacy)) {
          map.set(legacy, r.id);
        }
      }
      return map;
    };

    const treatTypeMap = await buildMap("LnsTreatType", "treatId");
    const lensTypeMap = await buildMap("LnsType", "lensTypeId");
    const lensMaterMap = await buildMap("LnsMaterial", "lensMaterId");

    while (true) {
      const [rows] = await mysql.query(
        `
        SELECT TreatId, LensTypeID, LensMaterID
          FROM tblLnsTreatTypesConnect
         ORDER BY TreatId, LensTypeID, LensMaterID
         LIMIT ? OFFSET ?
        `,
        [WINDOW_SIZE, offset]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();

        for (const r of chunk) {
          const legacyTreatId = normalizeInt(r.TreatId);
          const legacyLensTypeId = normalizeInt(r.LensTypeID);
          const legacyLensMaterId = normalizeInt(r.LensMaterID);

          if (legacyTreatId === null || legacyLensTypeId === null || legacyLensMaterId === null) continue;

          const newTreatId = treatTypeMap.get(legacyTreatId) || null;
          const newLensTypeId = lensTypeMap.get(legacyLensTypeId) || null;
          const newLensMaterId = lensMaterMap.get(legacyLensMaterId) || null;

          if (!newTreatId || !newLensTypeId || !newLensMaterId) {
            throw new Error(
              `Missing mapped ID for LnsTreatTypeConnect: ` +
              `legacyTreatId=${legacyTreatId}, legacyLensTypeId=${legacyLensTypeId}, legacyLensMaterId=${legacyLensMaterId}`
            );
          }

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9}, $${base + 10}, $${base + 11})`
          );
          params.push(
            createId(),          // id
            tenantId,            // tenantId
            branchId,            // branchId
            legacyTreatId,       // legasyTreatId
            newTreatId,          // treatId (FK to new LnsTreatType)
            legacyLensTypeId,    // legasyLensTypeId
            newLensTypeId,       // lensTypeId (FK to new LnsType)
            legacyLensMaterId,   // legasyLensMaterId
            newLensMaterId,      // lensMaterId (FK to new LnsMaterial)
            now,                 // createdAt
            now                  // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "LnsTreatTypeConnect" (
              id,
              "tenantId",
              "branchId",
              "legasyTreatId",
              "treatId",
              "legasyLensTypeId",
              "lensTypeId",
              "legasyLensMaterId",
              "lensMaterId",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "legasyTreatId", "legasyLensTypeId", "legasyLensMaterId") DO UPDATE SET
              "treatId" = EXCLUDED."treatId",
              "lensTypeId" = EXCLUDED."lensTypeId",
              "lensMaterId" = EXCLUDED."lensMaterId",
              "updatedAt" = EXCLUDED."updatedAt"
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
      console.log(
        `LnsTreatTypeConnect migrated so far: ${total} (offset=${offset})`
      );
    }

    console.log(`✅ LnsTreatTypeConnect migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateLnsTreatTypeConnect;
