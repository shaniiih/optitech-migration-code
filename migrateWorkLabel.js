const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

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

async function migrateWorkLabel(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastLabelId = -1;
  let total = 0;
  let skippedMissingSupplier = 0;
  let skippedMissingItemCode = 0;

  try {
    const { rows: supplierRows } = await pg.query(
      `SELECT "supplierId" FROM "Supplier" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const supplierIds = new Set(
      supplierRows
        .map((row) => asInteger(row.supplierId))
        .filter((val) => val !== null)
    );

    while (true) {
      const [rows] = await mysql.query(
        `SELECT LabelId, LabelName, ItemCode, SapakId
           FROM tblCrdBuysWorkLabels
          WHERE LabelId > ?
          ORDER BY LabelId
          LIMIT ${WINDOW_SIZE}`,
        [lastLabelId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();

        for (const row of chunk) {
          const labelId = asInteger(row.LabelId);
          const itemCodeRaw = cleanText(row.ItemCode);
          const supplierLegacyId = asInteger(row.SapakId);

          if (!itemCodeRaw) {
            skippedMissingItemCode += 1;
            continue;
          }

          if (supplierLegacyId === null) {
            skippedMissingSupplier += 1;
            continue;
          }

          if (!supplierIds.has(supplierLegacyId)) {
            skippedMissingSupplier += 1;
            continue;
          }

          const name = cleanText(row.LabelName) || `Work Label ${labelId}`;
          const itemCode = String(itemCodeRaw);
          const id = `${tenantId}-work-label-${labelId}`;

          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8}, $${offset + 9})`
          );

          params.push(
            id,
            tenantId,
            labelId,
            name,
            itemCode,
            supplierLegacyId,
            true,
            timestamp,
            timestamp
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "WorkLabel" (
              id,
              "tenantId",
              "labelId",
              name,
              "itemCode",
              "supplierId",
              "isActive",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("labelId")
            DO UPDATE SET
              id = EXCLUDED.id,
              "tenantId" = EXCLUDED."tenantId",
              name = EXCLUDED.name,
              "itemCode" = EXCLUDED."itemCode",
              "supplierId" = EXCLUDED."supplierId",
              "isActive" = EXCLUDED."isActive",
              "updatedAt" = EXCLUDED."updatedAt"
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

      lastLabelId = rows[rows.length - 1].LabelId;
      console.log(`WorkLabel migrated: ${total} (lastLabelId=${lastLabelId})`);
    }

    console.log(`✅ WorkLabel migration completed. Total inserted/updated: ${total}`);
    if (skippedMissingSupplier) {
      console.log(`⚠️ Skipped ${skippedMissingSupplier} labels due to missing supplier mapping.`);
    }
    if (skippedMissingItemCode) {
      console.log(`⚠️ Skipped ${skippedMissingItemCode} labels due to missing item code.`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateWorkLabel;
