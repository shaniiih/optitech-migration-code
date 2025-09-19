const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE  = 1000;

async function migrateContactAgents(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  let skippedMissingCustomer = 0;

  try {
    // We don't have an explicit source "AgentId" column in the destination schema.
    // We'll treat ("tenantId","customerId","firstName","lastName") as a natural key for idempotency.
    await pg.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_indexes WHERE indexname = 'contactagent_natkey_ux'
        ) THEN
          CREATE UNIQUE INDEX contactagent_natkey_ux
          ON "ContactAgent" ("tenantId","customerId","firstName","lastName");
        END IF;
      END$$;
    `);

    const { rows: customerRows } = await pg.query(
      `SELECT id, "customerId" FROM "Customer" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const customerIdMap = new Map();
    for (const row of customerRows) {
      if (row.customerId !== null && row.customerId !== undefined) {
        customerIdMap.set(String(row.customerId), row.id);
      }
    }

    while (true) {
      const [rows] = await mysql.execute(
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
        const now = new Date();
        const deduped = new Map();

        for (const r of chunk) {
          const legacyCustomerId =
            r.CntID === null || r.CntID === undefined ? null : String(r.CntID);
          if (!legacyCustomerId) continue;
          const customerId = customerIdMap.get(legacyCustomerId);
          if (!customerId) {
            skippedMissingCustomer += 1;
            continue;
          }
          const agentName = (r.AgentName || "").trim();
          if (!agentName) continue;

          const [firstNameRaw, ...lastNamePartsRaw] = agentName.split(/\s+/);
          const firstName = firstNameRaw || "-";
          const lastName = lastNamePartsRaw.join(" ") || "-";

          const key = `${customerId}::${firstName.toLowerCase()}::${lastName.toLowerCase()}`;
          deduped.set(key, {
            record: r,
            customerId,
            firstName,
            lastName,
          });
        }

        if (!deduped.size) continue;

        const values = [];
        const params = [];

        for (const { record: r, customerId, firstName, lastName } of deduped.values()) {
          const phone = r.CellPhone || r.WorkPhone || null;

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10}, $${params.length + 11}, $${params.length + 12}, $${params.length + 13}, $${params.length + 14}, $${params.length + 15}, $${params.length + 16}, $${params.length + 17}, $${params.length + 18})`
          );
          params.push(
            uuidv4(),               // id
            tenantId,               // "tenantId"
            customerId,             // "customerId"
            "GENERAL",              // "agentType"
            null,                   // relationship
            firstName,              // "firstName"
            lastName,               // "lastName"
            phone,                  // phone
            null,                   // email
            null,                   // address
            null,                   // city
            null,                   // policyNumber
            null,                   // groupNumber
            false,                  // "isPrimary"
            true,                   // "isActive"
            r.Com || null,          // notes
            now,                    // "createdAt"
            now                     // "updatedAt"
          );
        }

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "ContactAgent" (
              id, "tenantId", "customerId", "agentType", relationship,
              "firstName", "lastName", phone, email, address, city,
              "policyNumber", "groupNumber", "isPrimary", "isActive",
              notes, "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId","customerId","firstName","lastName")
            DO UPDATE SET
              phone = COALESCE(EXCLUDED.phone, "ContactAgent".phone),
              notes = COALESCE(EXCLUDED.notes, "ContactAgent".notes),
              "agentType" = EXCLUDED."agentType",
              "isPrimary" = EXCLUDED."isPrimary",
              "isActive" = EXCLUDED."isActive",
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (e) {
          await pg.query("ROLLBACK");
          throw e;
        }

        total += deduped.size;
      }

      lastId = rows[rows.length - 1].AgentId;
      console.log(`ContactAgents migrated so far: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ ContactAgents migration completed. Total: ${total}`);
    if (skippedMissingCustomer) {
      console.warn(
        `⚠️ Skipped ${skippedMissingCustomer} contact agents because the related customer was not found in tenant ${tenantId}`
      );
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateContactAgents;
