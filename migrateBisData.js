const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");
const { ensureTenantId } = require("./tenantUtils");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "string") {
    const trimmed = value.trim();
    return trimmed.length ? trimmed : null;
  }
  if (Buffer.isBuffer(value)) {
    return cleanText(value.toString("utf8"));
  }
  return cleanText(String(value));
}

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  if (typeof value === "bigint") return Number(value);
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function asNumeric(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? value : null;
  }
  if (typeof value === "bigint") return Number(value);
  const trimmed = String(value).trim().replace(/,/g, ".");
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? parsed : null;
}

async function migrateBisData(tenantId = "tenant_1", branchId = null) {
  tenantId = ensureTenantId(tenantId, "tenant_1");

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;
  let skippedMissingKey = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT BisId, BisNum, BisName, Phone, Fax, Email, Address,
                ZipCode, CreditMode, CreditDays, CreditFactor
           FROM tblBisData
          WHERE BisId > ?
          ORDER BY BisId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();

        for (const row of chunk) {
          const bisId = asInteger(row.BisId);
          if (bisId === null) {
            skippedMissingKey += 1;
            continue;
          }

          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8}, $${offset + 9}, $${offset + 10}, $${offset + 11}, $${offset + 12}, $${offset + 13}, $${offset + 14}, $${offset + 15}, $${offset + 16})`
          );

          params.push(
            uuidv4(),                 // id
            tenantId,                 // tenantId
            branchId,                 // branchId
            bisId,                    // bisId
            cleanText(row.BisNum),    // bisNum
            cleanText(row.BisName),   // bisName
            cleanText(row.Phone),     // phone
            cleanText(row.Fax),       // fax
            cleanText(row.Email),     // email
            cleanText(row.Address),   // address
            asInteger(row.ZipCode),   // zipCode
            asInteger(row.CreditMode),// creditMode
            asInteger(row.CreditDays),// creditDays
            asNumeric(row.CreditFactor), // creditFactor
            timestamp,                // createdAt
            timestamp                 // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "BisData" (
              id,
              "tenantId",
              "branchId",
              "bisId",
              "bisNum",
              "bisName",
              phone,
              fax,
              email,
              address,
              "zipCode",
              "creditMode",
              "creditDays",
              "creditFactor",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "bisId")
            DO UPDATE SET
              "branchId" = EXCLUDED."branchId",
              "bisNum" = EXCLUDED."bisNum",
              "bisName" = EXCLUDED."bisName",
              phone = EXCLUDED.phone,
              fax = EXCLUDED.fax,
              email = EXCLUDED.email,
              address = EXCLUDED.address,
              "zipCode" = EXCLUDED."zipCode",
              "creditMode" = EXCLUDED."creditMode",
              "creditDays" = EXCLUDED."creditDays",
              "creditFactor" = EXCLUDED."creditFactor",
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

      const maxId = asInteger(rows[rows.length - 1].BisId);
      if (maxId !== null && maxId > lastId) {
        lastId = maxId;
      }
      console.log(`BisData migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ BisData migration completed. Total processed: ${total}`);
    if (skippedMissingKey) {
      console.warn(`⚠️ Skipped ${skippedMissingKey} rows due to invalid BisId.`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateBisData;
