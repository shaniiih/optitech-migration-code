const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");
const { ensureTenantId } = require("./tenantUtils");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const s = String(value).trim();
  return s.length ? s : null;
}

function asInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  const s = String(value).trim();
  if (!s) return null;
  const n = Number(s);
  return Number.isFinite(n) ? Math.trunc(n) : null;
}

async function migrateContactAgent(tenantId = "tenant_1", branchId) {
  tenantId = ensureTenantId(tenantId, "tenant_1");
  if (!branchId) {
    throw new Error("migrateContactAgent requires a non-null BRANCH_ID");
  }

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    // Map legacy CntID -> Contact.id for this tenant+branch
    const { rows: contactRows } = await pg.query(
      `SELECT id, "cntId"
         FROM "Contact"
        WHERE "tenantId" = $1 AND "branchId" = $2`,
      [tenantId, branchId]
    );

    const contactMap = new Map(); // legacyCntId (number) -> contact UUID
    for (const row of contactRows) {
      if (row.cntId !== null && row.cntId !== undefined) {
        const legacyCntId = asInt(row.cntId);
        if (legacyCntId !== null) {
          contactMap.set(legacyCntId, row.id);
        }
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT AgentId, CntID, AgentName, WorkPhone, CellPhone, Com
           FROM tblContactAgents
          ORDER BY AgentId
          LIMIT ${WINDOW_SIZE}
          OFFSET ${offset}`
      );

      if (!rows.length) {
        break;
      }

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();

        for (const r of chunk) {
          const agentId = asInt(r.AgentId);
          const legacyCntId = asInt(r.CntID);

          if (agentId === null) {
            throw new Error(`ContactAgent: invalid AgentId '${r.AgentId}'`);
          }
          if (legacyCntId === null) {
            throw new Error(`ContactAgent: invalid CntID for AgentId=${agentId}`);
          }

          const contactId = contactMap.get(legacyCntId);
          if (!contactId) {
            throw new Error(
              `ContactAgent: no Contact found for tenant=${tenantId}, branch=${branchId}, CntID=${legacyCntId} (AgentId=${agentId})`
            );
          }

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9}, $${base + 10}, $${base + 11}, $${base + 12})`
          );
          params.push(
            uuidv4(),                  // id
            tenantId,                  // tenantId
            branchId,                  // branchId
            agentId,                   // agentId
            legacyCntId,               // legacyCntId
            contactId,                 // cntId (FK -> Contact.id)
            cleanText(r.AgentName),    // agentName
            cleanText(r.WorkPhone),    // workPhone
            cleanText(r.CellPhone),    // cellPhone
            cleanText(r.Com),          // com
            now,                       // createdAt
            now                        // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "ContactAgent" (
              id,
              "tenantId",
              "branchId",
              "agentId",
              "legacyCntId",
              "cntId",
              "agentName",
              "workPhone",
              "cellPhone",
              "com",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "agentId")
            DO UPDATE SET
              "legacyCntId" = EXCLUDED."legacyCntId",
              "cntId"       = EXCLUDED."cntId",
              "agentName"   = EXCLUDED."agentName",
              "workPhone"   = EXCLUDED."workPhone",
              "cellPhone"   = EXCLUDED."cellPhone",
              "com"         = EXCLUDED."com",
              "updatedAt"   = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (e) {
          await pg.query("ROLLBACK");
          throw e;
        }
      }

      offset += rows.length;
      console.log(`ContactAgent migrated so far: ${total} (offset=${offset})`);
    }

    console.log(`✅ ContactAgent migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateContactAgent;
