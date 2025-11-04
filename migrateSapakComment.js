
const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

async function migrateSapakComment(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;

  try {
    const now = () => new Date();

    while (true) {
      const [rows] = await mysql.query(
        `SELECT SapakId, prlType, Comments, PrlSp
           FROM tblSapakComments
          WHERE SapakId > ?
          ORDER BY SapakId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const r of chunk) {
          const sapakId = r.SapakId;
          const prlType = r.prlType;
          const comments = cleanText(r.Comments);
          const prlSp = r.PrlSp;
          const timestamp = now();

          const paramBase = params.length;
          values.push(
            `($${paramBase + 1}, $${paramBase + 2}, $${paramBase + 3}, $${paramBase + 4}, $${paramBase + 5}, $${paramBase + 6}, $${paramBase + 7}, $${paramBase + 8}, $${paramBase + 9})`
          );

          params.push(
            uuidv4(),
            tenantId,
            branchId,
            sapakId,
            prlType,
            comments,
            prlSp,
            timestamp,
            timestamp
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "SapakComment" (
              id, "tenantId", "branchId", "sapakId", "prlType", comments, "prlSp", "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id) DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              "branchId" = EXCLUDED."branchId",
              "sapakId" = EXCLUDED."sapakId",
              "prlType" = EXCLUDED."prlType",
              comments = EXCLUDED.comments,
              "prlSp" = EXCLUDED."prlSp",
              "updatedAt" = EXCLUDED."updatedAt"`,
            params
          );
          await pg.query("COMMIT");
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }

        total += chunk.length;
      }

      lastId = rows[rows.length - 1].SapakId;
      console.log(`SapakComment migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ SapakComment migration completed. Total inserted: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateSapakComment;
