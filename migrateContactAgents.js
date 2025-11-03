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

function splitFullName(name) {
  const fallback = { firstName: "Agent", lastName: "Contact" };
  const cleaned = cleanText(name);
  if (!cleaned) return fallback;

  const normalized = cleaned.replace(/\s+/g, " ");
  const parts = normalized.split(" ");
  if (parts.length === 1) {
    return { firstName: parts[0], lastName: "Contact" };
  }

  const firstName = parts.shift();
  const lastName = parts.join(" ").trim() || "Contact";
  return { firstName, lastName };
}

function pickPhone(cell, work) {
  return cleanText(cell) || cleanText(work) || null;
}

async function migrateContactAgents(tenantId = "tenant_1", branchId = null) {
  tenantId = ensureTenantId(tenantId, "tenant_1");

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let totalInserted = 0;
  let skippedMissingCustomer = 0;
  let skippedMissingContact = 0;
  let skippedInvalidLegacyId = 0;

  try {
    await pg.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1
          FROM pg_indexes
          WHERE indexname = 'contactagent_natkey_ux'
        ) THEN
          CREATE UNIQUE INDEX contactagent_natkey_ux
          ON "ContactAgent" ("tenantId", "customerId", "firstName", "lastName");
        END IF;
      END$$;
    `);

    const { rows: customerRows } = await pg.query(
      `SELECT id, "customerId", "branchId"
         FROM "Customer"
        WHERE "tenantId" = $1`,
      [tenantId]
    );

    const customerMap = new Map();
    for (const row of customerRows) {
      if (row.customerId !== null && row.customerId !== undefined) {
        customerMap.set(String(row.customerId), {
          id: row.id,
          branchId: row.branchId || null,
        });
      }
    }

    const { rows: contactRows } = await pg.query(
      `SELECT id, "cntId"
         FROM "Contact"
        WHERE "tenantId" = $1`,
      [tenantId]
    );

    const contactMap = new Map();
    for (const row of contactRows) {
      if (row.cntId !== null && row.cntId !== undefined) {
        contactMap.set(String(row.cntId), row.id);
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT AgentId, CntID, AgentName, WorkPhone, CellPhone, Com
           FROM tblContactAgents
          WHERE AgentId > ?
          ORDER BY AgentId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const deduped = new Map();

        for (const row of chunk) {
          const legacyCustomerId =
            row.CntID === null || row.CntID === undefined ? null : String(row.CntID);

          if (!legacyCustomerId) {
            skippedInvalidLegacyId += 1;
            continue;
          }

          const customer = customerMap.get(legacyCustomerId);
          if (!customer) {
            skippedMissingCustomer += 1;
            continue;
          }

          const contactId = contactMap.get(legacyCustomerId);
          if (!contactId) {
            skippedMissingContact += 1;
            continue;
          }

          const { firstName, lastName } = splitFullName(row.AgentName);
          const key = `${customer.id}::${firstName.toLowerCase()}::${lastName.toLowerCase()}`;
          deduped.set(key, {
            row,
            customer,
            contactId,
            legacyCustomerId,
            firstName,
            lastName,
          });
        }

        if (!deduped.size) continue;

        const values = [];
        const params = [];
        const timestamp = new Date();

        for (const entry of deduped.values()) {
          const { row, customer, contactId, legacyCustomerId, firstName, lastName } = entry;
          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8}, $${offset + 9}, $${offset + 10}, $${offset + 11}, $${offset + 12}, $${offset + 13}, $${offset + 14}, $${offset + 15}, $${offset + 16}, $${offset + 17}, $${offset + 18}, $${offset + 19}, $${offset + 20})`
          );
          params.push(
            uuidv4(),                     // id
            tenantId,                     // tenantId
            customer.id,                  // customerId (UUID)
            "GENERAL",                    // agentType
            null,                         // relationship
            firstName,                    // firstName
            lastName,                     // lastName
            pickPhone(row.CellPhone, row.WorkPhone), // phone
            null,                         // email
            null,                         // address
            null,                         // city
            null,                         // policyNumber
            null,                         // groupNumber
            false,                        // isPrimary
            true,                         // isActive
            cleanText(row.Com),           // notes
            timestamp,                    // createdAt
            timestamp,                    // updatedAt
            contactId,                    // CntID (linked Contact id)
            branchId                      // branchId (shared value)
          );
        }

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "ContactAgent" (
              id,
              "tenantId",
              "customerId",
              "agentType",
              relationship,
              "firstName",
              "lastName",
              phone,
              email,
              address,
              city,
              "policyNumber",
              "groupNumber",
              "isPrimary",
              "isActive",
              notes,
              "createdAt",
              "updatedAt",
              "CntID",
              "branchId"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "customerId", "firstName", "lastName")
            DO UPDATE SET
              "agentType" = EXCLUDED."agentType",
              relationship = EXCLUDED.relationship,
              phone = EXCLUDED.phone,
              email = EXCLUDED.email,
              address = EXCLUDED.address,
              city = EXCLUDED.city,
              "policyNumber" = EXCLUDED."policyNumber",
              "groupNumber" = EXCLUDED."groupNumber",
              "isPrimary" = EXCLUDED."isPrimary",
              "isActive" = EXCLUDED."isActive",
              notes = EXCLUDED.notes,
              "updatedAt" = EXCLUDED."updatedAt",
              "CntID" = EXCLUDED."CntID",
              "branchId" = EXCLUDED."branchId"
            `,
            params
          );
          await pg.query("COMMIT");
          totalInserted += values.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      const lastRow = rows[rows.length - 1];
      lastId = Number(lastRow.AgentId) || lastId;
      console.log(`ContactAgents migrated so far: ${totalInserted} (lastId=${lastId})`);
    }

    console.log(`✅ ContactAgents migration completed. Total processed: ${totalInserted}`);
    if (skippedInvalidLegacyId) {
      console.warn(`⚠️ Skipped ${skippedInvalidLegacyId} contact agents due to missing legacy customer id (CntID).`);
    }
    if (skippedMissingCustomer) {
      console.warn(`⚠️ Skipped ${skippedMissingCustomer} contact agents because matching customers were not found in Postgres.`);
    }
    if (skippedMissingContact) {
      console.warn(`⚠️ Skipped ${skippedMissingContact} contact agents because matching contacts were not found in Postgres.`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateContactAgents;
