
const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function normalizeInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  if (typeof value === "bigint") return Number(value);
  if (Buffer.isBuffer(value)) return normalizeInt(value.toString("utf8"));
  const n = Number(String(value).trim());
  return Number.isFinite(n) ? Math.trunc(n) : null;
}

async function migrateSapakComment(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    // Map legacy SapakID -> Sapak.id for this tenant/branch
    const sapakMap = new Map();
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

    // Map legacy prlType (number) -> PrlType.id for this tenant/branch
    const prlTypeMap = new Map();
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
        const legacyType = normalizeInt(row.prlType);
        if (legacyType !== null && !prlTypeMap.has(legacyType)) {
          prlTypeMap.set(legacyType, row.id);
        }
      }
    }

    const now = () => new Date();

    while (true) {
      const [rows] = await mysql.query(
        `SELECT SapakId, prlType, Comments, PrlSp
           FROM tblSapakComments
          ORDER BY SapakId, prlType
          LIMIT ? OFFSET ?`,
        [WINDOW_SIZE, offset]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const r of chunk) {
          const legacySapakId = normalizeInt(r.SapakId);
          const prlTypeNumber = normalizeInt(r.prlType);
          const comments = cleanText(r.Comments);
          const prlSp = normalizeInt(r.PrlSp);
          const timestamp = now();

          const sapakId = sapakMap.get(legacySapakId) || null;
          const prlTypeId = prlTypeMap.get(prlTypeNumber) || null;

          const paramBase = params.length;
          values.push(
            `($${paramBase + 1}, $${paramBase + 2}, $${paramBase + 3}, $${paramBase + 4}, $${paramBase + 5}, $${paramBase + 6}, $${paramBase + 7}, $${paramBase + 8}, $${paramBase + 9}, $${paramBase + 10}, $${paramBase + 11})`
          );

          params.push(
            uuidv4(),       // id
            tenantId,       // tenantId
            branchId,       // branchId
            legacySapakId,  // legacySapakId
            prlTypeNumber,  // legacyPrlTypeId
            sapakId,        // sapakId (FK UUID)
            prlTypeId,      // prlTypeId (FK UUID)
            comments,       // comments
            prlSp,          // prlSp
            timestamp,      // createdAt
            timestamp       // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "SapakComment" (
              id,
              "tenantId",
              "branchId",
              "legacySapakId",
              "legacyPrlTypeId",
              "sapakId",
              "prlTypeId",
              comments,
              "prlSp",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "sapakId", "prlTypeId") DO UPDATE SET
              comments          = EXCLUDED.comments,
              "prlSp"           = EXCLUDED."prlSp",
              "updatedAt"       = EXCLUDED."updatedAt"`,
            params
          );
          await pg.query("COMMIT");
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }

        total += chunk.length;
      }

      offset += rows.length;
      console.log(`SapakComment migrated: ${total} (offset=${offset})`);
    }

    console.log(`✅ SapakComment migration completed. Total inserted: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateSapakComment;
