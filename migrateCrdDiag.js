const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

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

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

async function migrateCrdDiag(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    const perMap = new Map();
    const { rows: perRows } = await pg.query(
      `SELECT id, "perId" FROM "PerData" WHERE "tenantId" = $1 AND "branchId" = $2`,
      [tenantId, branchId]
    );
    for (const row of perRows) {
      const legacy = normalizeInt(row.perId);
      if (legacy !== null) perMap.set(legacy, row.id);
    }

    const userMap = new Map();
    const { rows: userRows } = await pg.query(
      `SELECT id, "userId" FROM "User" WHERE "tenantId" = $1 AND "branchId" = $2`,
      [tenantId, branchId]
    );
    for (const row of userRows) {
      const legacy = normalizeInt(row.userId);
      if (legacy !== null) userMap.set(legacy, row.id);
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT * FROM tblCrdDiags ORDER BY PerId, CheckDate LIMIT ? OFFSET ?`,
        [WINDOW_SIZE, offset]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const now = new Date();
        const values = [];
        const params = [];

        for (const row of chunk) {
          const legacyPerId = normalizeInt(row.PerId);
          const legacyUserId = normalizeInt(row.UserId);

          const perId = perMap.get(legacyPerId) || null;
          const userId = userMap.get(legacyUserId) || null;

          const base = params.length;

          const columns = [
            "id", "tenantId", "branchId",
            "perId", "legacyPerId",
            "checkDate",
            "userId", "legacyUserId",
            "complaints", "illnesses", "optDiag", "docRef", "summary",
            "createdAt", "updatedAt"
          ];

          values.push(`(${columns.map((_, idx) => `$${base + idx + 1}`).join(",")})`);

          params.push(
            createId(),
            tenantId,
            branchId,
            perId,
            legacyPerId,
            row.CheckDate ? new Date(row.CheckDate) : null,
            userId,
            legacyUserId,
            cleanText(row.Complaints),
            cleanText(row.illnesses),
            cleanText(row.OptDiag),
            cleanText(row.DocRef),
            cleanText(row.Summary),
            now,
            now
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "CrdDiag" (
              id, "tenantId", "branchId",
              "perId", "legacyPerId",
              "checkDate",
              "userId", "legacyUserId",
              "complaints", "illnesses", "optDiag", "docRef", "summary",
              "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "legacyPerId", "checkDate")
            DO UPDATE SET
              "perId" = EXCLUDED."perId",
              "userId" = EXCLUDED."userId",
              "legacyUserId" = EXCLUDED."legacyUserId",
              "complaints" = EXCLUDED."complaints",
              "illnesses" = EXCLUDED."illnesses",
              "optDiag" = EXCLUDED."optDiag",
              "docRef" = EXCLUDED."docRef",
              "summary" = EXCLUDED."summary",
              "updatedAt" = NOW();
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
    }
  } finally {
    await mysql.end();
    await pg.end();
  }

  console.log("CrdDiag migration completed:", total);
}

module.exports = migrateCrdDiag;
