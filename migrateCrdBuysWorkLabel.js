const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");
const { ensureTenantId } = require("./tenantUtils");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  if (typeof value === "bigint") return Number(value);
  if (Buffer.isBuffer(value)) return asInteger(value.toString("utf8"));
  const trimmed = cleanText(value);
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

async function migrateCrdBuysWorkLabel(tenantId = "tenant_1", branchId = null) {
  tenantId = ensureTenantId(tenantId, "tenant_1");
  const normalizedBranchId = cleanText(branchId);

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;
  let skippedInvalidId = 0;
  let skippedMissingItem = 0;
  const missingSuppliers = new Set();

  try {
    const { rows: sapakRows } = await pg.query(
      `SELECT id, "sapakId", "branchId"
         FROM "CrdBuysWorkSapak"
        WHERE "tenantId" = $1`,
      [tenantId]
    );
    const sapakMap = new Map();
    for (const row of sapakRows) {
      const key = String(row.sapakId);
      const existing = sapakMap.get(key);
      if (!existing) {
        sapakMap.set(key, row);
      } else if (normalizedBranchId && row.branchId === normalizedBranchId) {
        sapakMap.set(key, row);
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT LabelId, LabelName, ItemCode, SapakId
           FROM tblCrdBuysWorkLabels
          WHERE LabelId > ?
          ORDER BY LabelId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();

        for (const r of chunk) {
          const labelId = asInteger(r.LabelId);
          if (labelId === null) {
            skippedInvalidId += 1;
            continue;
          }

          const itemCode = asInteger(r.ItemCode);
          if (itemCode === null) {
            skippedMissingItem += 1;
            continue;
          }

          const sapakKey = asInteger(r.SapakId);
          const sapak =
            sapakKey !== null ? sapakMap.get(String(sapakKey)) ?? null : null;
          const sapakId = sapak ? sapak.id : null;
          if (sapakKey !== null && !sapakId) {
            missingSuppliers.add(String(sapakKey));
          }

          const name = cleanText(r.LabelName) || `Label ${labelId}`;

          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8}, $${offset + 9})`
          );
          params.push(
            uuidv4(), // id
            tenantId, // tenantId
            normalizedBranchId || null, // branchId
            labelId, // labelId
            name, // labelName
            itemCode, // ItemCode
            sapakId, // sapakId (uuid from CrdBuysWorkSapak)
            now, // createdAt
            now // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "CrdBuysWorkLabel" (
              id,
              "tenantId",
              "branchId",
              "labelId",
              "labelName",
              "itemCode",
              "sapakId",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "labelId")
            DO UPDATE SET
              "labelName" = EXCLUDED."labelName",
              "itemCode" = EXCLUDED."itemCode",
              "sapakId" = EXCLUDED."sapakId",
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
      console.log(`CrdBuysWorkLabel migrated: ${total} (lastId=${lastId})`);
    }

    if (missingSuppliers.size) {
      const sample = Array.from(missingSuppliers).slice(0, 10);
      const suffix = missingSuppliers.size > sample.length ? " ..." : "";
      console.log(
        `⚠️ Missing supplier mappings for ${missingSuppliers.size} records. Sample SapakId values: ${sample.join(", ")}${suffix}`
      );
    }
    if (skippedInvalidId) {
      console.log(`⚠️ Skipped ${skippedInvalidId} labels due to invalid LabelId`);
    }
    if (skippedMissingItem) {
      console.log(`⚠️ Skipped ${skippedMissingItem} labels due to missing itemCode`);
    }

    console.log(`✅ CrdBuysWorkLabel migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCrdBuysWorkLabel;
