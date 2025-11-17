const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");
const { ensureTenantId } = require("./tenantUtils");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

async function migrateContact(tenantId, branchId) {
  tenantId = ensureTenantId(tenantId);

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.execute(
        `SELECT CntID, LastName, FirstName, WorkPhone, HomePhone, CellPhone, Fax,
                Address, ZipCode, CityID, EMail, WebSite, Comment, HidCom, IsSapak,
                CreditCon, RemDate, SapakID
           FROM tblContacts
          WHERE CntID > ?
          ORDER BY CntID
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const r of chunk) {
          const id = uuidv4();
          const now = new Date();

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10}, $${params.length + 11}, $${params.length + 12}, $${params.length + 13}, $${params.length + 14}, $${params.length + 15}, $${params.length + 16}, $${params.length + 17}, $${params.length + 18}, $${params.length + 19}, $${params.length + 20}, $${params.length + 21}, $${params.length + 22}, $${params.length + 23})`
          );

          params.push(
            id,                    // id (uuid)
            tenantId,              // tenantId
            branchId || null,      // branchId
            r.CntID != null ? String(r.CntID) : null,               // cntId
            r.LastName || null,                                    // lastName
            r.FirstName || null,                                   // firstName
            r.WorkPhone || null,                                   // workPhone
            r.HomePhone || null,                                   // homePhone
            r.CellPhone || null,                                   // cellPhone
            r.Fax || null,                                         // fax
            r.Address || null,                                     // address
            r.ZipCode != null ? String(r.ZipCode) : null,          // zipCode
            r.CityID != null ? String(r.CityID) : null,            // cityId (required in schema; ensure not null)
            r.EMail || null,                                       // email
            r.WebSite || null,                                     // website
            r.Comment || null,                                     // comment
            r.HidCom || null,                                      // hidCom
            !!r.IsSapak,                                           // isSapak
            r.CreditCon != null ? String(r.CreditCon) : null,      // creditCon
            normalizeDate(r.RemDate),                              // remDate
            r.SapakID != null ? String(r.SapakID) : null,          // supplierId (SapakID)
            now,                                                   // createdAt
            now                                                    // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          const sql = `
            INSERT INTO "Contact" (
              id, "tenantId", "branchId", "cntId", "lastName", "firstName", "workPhone", "homePhone",
              "cellPhone", fax, address, "zipCode", "cityId", email, website, comment, "hidCom",
              "isSapak", "creditCon", "remDate", "supplierId", "createdAt", "updatedAt"
            ) VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "cntId") DO UPDATE SET
              "branchId" = EXCLUDED."branchId",
              "cntId" = EXCLUDED."cntId",
              "lastName" = EXCLUDED."lastName",
              "firstName" = EXCLUDED."firstName",
              "workPhone" = EXCLUDED."workPhone",
              "homePhone" = EXCLUDED."homePhone",
              "cellPhone" = EXCLUDED."cellPhone",
              fax = EXCLUDED.fax,
              address = EXCLUDED.address,
              "zipCode" = EXCLUDED."zipCode",
              "cityId" = EXCLUDED."cityId",
              email = EXCLUDED.email,
              website = EXCLUDED.website,
              comment = EXCLUDED.comment,
              "hidCom" = EXCLUDED."hidCom",
              "isSapak" = EXCLUDED."isSapak",
              "creditCon" = EXCLUDED."creditCon",
              "remDate" = EXCLUDED."remDate",
              "supplierId" = EXCLUDED."supplierId",
              "updatedAt" = EXCLUDED."updatedAt";
          `;
          await pg.query(sql, params);
          await pg.query("COMMIT");
        } catch (e) {
          await pg.query("ROLLBACK");
          throw e;
        }

        total += chunk.length;
      }

      lastId = rows[rows.length - 1].CntID;
      console.log(`Contacts migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ Contact migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

function normalizeDate(value) {
  if (value === null || value === undefined) return null;
  if (value instanceof Date) return isNaN(value.getTime()) ? null : value;
  if (typeof value === 'string') {
    const trimmed = value.trim();
    if (!trimmed) return null;
    const d = new Date(trimmed);
    return isNaN(d.getTime()) ? null : d;
  }
  if (typeof value === 'number') {
    const d = new Date(value);
    return isNaN(d.getTime()) ? null : d;
  }
  return null;
}

module.exports = migrateContact;
