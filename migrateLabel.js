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

function normalizeFloat(value) {
  if (value === null || value === undefined) return null;
  const n = Number(value);
  return Number.isFinite(n) ? n : null;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

async function migrateLabel(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT LabelId, LabelName,
                MargRight, MargLeft,
                LabelWidth, LabelHeight,
                HorSpace, VerSpace,
                MargTop, MargBot
           FROM tblLabels
          WHERE LabelId > ?
          ORDER BY LabelId
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
          const labelId = normalizeId(row.LabelId);
          if (labelId === null) continue;

          const labelName = cleanText(row.LabelName);

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10}, $${params.length + 11}, $${params.length + 12}, $${params.length + 13}, $${params.length + 14}, $${params.length + 15})`
          );

          params.push(
            createId(),                   // id
            tenantId,                   // tenantId
            branchId,                   // branchId
            labelId,                    // labelId
            labelName,                  // labelName
            normalizeFloat(row.MargRight),
            normalizeFloat(row.MargLeft),
            normalizeFloat(row.LabelWidth),
            normalizeFloat(row.LabelHeight),
            normalizeFloat(row.HorSpace),
            normalizeFloat(row.VerSpace),
            normalizeFloat(row.MargTop),
            normalizeFloat(row.MargBot),
            now,                        // createdAt
            now                         // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "Label" (
              id,
              "tenantId",
              "branchId",
              "labelId",
              "labelName",
              "margRight",
              "margLeft",
              "labelWidth",
              "labelHeight",
              "horSpace",
              "verSpace",
              "margTop",
              "margBot",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "labelId")
            DO UPDATE SET
              "labelName" = EXCLUDED."labelName",
              "margRight" = EXCLUDED."margRight",
              "margLeft" = EXCLUDED."margLeft",
              "labelWidth" = EXCLUDED."labelWidth",
              "labelHeight" = EXCLUDED."labelHeight",
              "horSpace" = EXCLUDED."horSpace",
              "verSpace" = EXCLUDED."verSpace",
              "margTop" = EXCLUDED."margTop",
              "margBot" = EXCLUDED."margBot",
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

      lastId = rows[rows.length - 1].LabelId ?? lastId;
      console.log(`Label migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(
      `✅ Label migration completed. Total inserted/updated: ${total}`
    );
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateLabel;
