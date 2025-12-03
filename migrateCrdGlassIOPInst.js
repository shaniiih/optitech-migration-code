const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function normalizeId(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  if (typeof value === "bigint") {
    return Number(value);
  }
  if (Buffer.isBuffer(value)) {
    return normalizeId(value.toString("utf8"));
  }
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

async function migrateCrdGlassIOPInst(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT IOPInstId, IOPInstName
           FROM tblCrdGlassIOPInsts
          WHERE IOPInstId > ?
          ORDER BY IOPInstId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        for (const row of chunk) {
          const iopInstId = normalizeId(row.IOPInstId);
          if (iopInstId === null) continue;

          const displayName = cleanText(row.IOPInstName);

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7})`
          );
          params.push(
            createId(),
            tenantId,
            branchId,
            iopInstId,
            displayName,
            now,
            now
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "CrdGlassIOPInst" (
              id,
              "tenantId",
              "branchId",
              "iOPInstId",
              "iOPInstName",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId","branchId", "iOPInstId")
            DO UPDATE SET
              "iOPInstName" = EXCLUDED."iOPInstName",
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      lastId = rows[rows.length - 1].IOPInstId;
      console.log(
        `CrdGlassIOPInst migrated so far: ${total} (lastId=${lastId})`
      );
    }

    console.log(
      `✅ CrdGlassIOPInst migration completed. Total inserted/updated: ${total}`
    );
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCrdGlassIOPInst;
