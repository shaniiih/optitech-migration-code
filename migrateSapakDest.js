const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

async function migrateSapakDest(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT SapakDestId, SapakDestName, SapakId, Fax1, Fax2, Email1, Email2, ClientId
           FROM tblSapakDests
          ORDER BY SapakDestId
          LIMIT ${WINDOW_SIZE}
         OFFSET ${offset}`
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const r of chunk) {
          const sapakDestId = r.SapakDestId;
          const sapakDestName = cleanText(r.SapakDestName);
          const mysqlSapakId = r.SapakId;
          const fax1 = cleanText(r.Fax1);
          const fax2 = cleanText(r.Fax2);
          const email1 = cleanText(r.Email1);
          const email2 = cleanText(r.Email2);
          const clientId = cleanText(r.ClientId);
          const timestamp = new Date();

          let pgSapakId = null;
          if (mysqlSapakId) {
            const res = await pg.query(`SELECT "supplierId" FROM "Supplier" WHERE "supplierId" = $1 AND "tenantId" = $2`, [String(mysqlSapakId), tenantId]);
            if (res.rows.length > 0) {
              pgSapakId = parseInt(res.rows[0].supplierId, 10);
            }
          }

          const paramBase = params.length;
          values.push(
            `($${paramBase + 1}, $${paramBase + 2}, $${paramBase + 3}, $${paramBase + 4}, $${paramBase + 5}, $${paramBase + 6}, $${paramBase + 7}, $${paramBase + 8}, $${paramBase + 9}, $${paramBase + 10}, $${paramBase + 11}, $${paramBase + 12}, $${paramBase + 13})`
          );

          params.push(
            uuidv4(),
            tenantId,
            branchId,
            sapakDestId,
            sapakDestName,
            pgSapakId,
            fax1,
            fax2,
            email1,
            email2,
            clientId,
            timestamp,
            timestamp
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "SapakDest" (
              id, "tenantId", "branchId", "sapakDestId", "sapakDestName", "sapakId", fax1, fax2, email1, email2, "clientId", "createdAt", "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id) DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              "branchId" = EXCLUDED."branchId",
              "sapakDestId" = EXCLUDED."sapakDestId",
              "sapakDestName" = EXCLUDED."sapakDestName",
              "sapakId" = EXCLUDED."sapakId",
              fax1 = EXCLUDED.fax1,
              fax2 = EXCLUDED.fax2,
              email1 = EXCLUDED.email1,
              email2 = EXCLUDED.email2,
              "clientId" = EXCLUDED."clientId",
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }

        total += chunk.length;
      }

      offset += rows.length;
      console.log(`SapakDest migrated: ${total} (offset=${offset})`);

      if (rows.length < WINDOW_SIZE) {
        break;
      }
    }

    console.log(`✅ SapakDest migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateSapakDest;
