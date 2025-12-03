const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");
const { ensureTenantId } = require("./tenantUtils");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function normalizeInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  if (typeof value === "bigint") {
    return Number(value);
  }
  if (Buffer.isBuffer(value)) {
    return normalizeInt(value.toString("utf8"));
  }
  const trimmed = cleanText(value);
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function normalizeDate(value) {
  if (value === null || value === undefined) return null;
  if (value instanceof Date) return Number.isNaN(value.getTime()) ? null : value;
  const trimmed = cleanText(value);
  if (!trimmed) return null;
  if (/^0{4}-0{2}-0{2}/.test(trimmed)) return null;
  const parsed = new Date(trimmed);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

async function migrateContact(tenantId, branchId) {
  tenantId = ensureTenantId(tenantId);
  const normalizedBranchId = cleanText(branchId);

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;
  let skippedInvalidId = 0;
  let skippedMissingCity = 0;
  const missingCities = new Set();
  const missingSuppliers = new Set();

  try {
    const { rows: contactColumns } = await pg.query(
      `
      SELECT column_name
      FROM information_schema.columns
      WHERE table_name = 'Contact' AND column_name IN ('supplierId', 'sapakId')
      `
    );
    const supplierColumn =
      contactColumns.find((c) => c.column_name === "supplierId")?.column_name ||
      contactColumns.find((c) => c.column_name === "sapakId")?.column_name ||
      null;
    const includeSupplierId = Boolean(supplierColumn);

    const { rows: cityRows } = await pg.query(
      `SELECT id, "cityId"
         FROM "City"
        WHERE "tenantId" = $1`,
      [tenantId]
    );
    const cityMap = new Map(cityRows.map((row) => [String(row.cityId), row.id]));

    const sapakMap = new Map();
    if (includeSupplierId) {
      const { rows: sapakRows } = await pg.query(
        `SELECT id, "sapakId", "branchId"
           FROM "CrdBuysWorkSapak"
          WHERE "tenantId" = $1`,
        [tenantId]
      );
      for (const row of sapakRows) {
        const key = String(row.sapakId);
        const current = sapakMap.get(key);
        if (!current) {
          sapakMap.set(key, row);
        } else if (normalizedBranchId && row.branchId === normalizedBranchId) {
          sapakMap.set(key, row);
        }
      }
    }

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
          const cntId = normalizeInt(r.CntID);
          if (cntId === null) {
            skippedInvalidId += 1;
            continue;
          }

          const cityKey = normalizeInt(r.CityID);
          const cityId = cityKey !== null ? cityMap.get(String(cityKey)) ?? null : null;
          if (!cityId) {
            missingCities.add(String(r.CityID));
            skippedMissingCity += 1;
            continue;
          }

          let supplierId = null;
          if (includeSupplierId) {
            const supplierKey = normalizeInt(r.SapakID);
            const supplier =
              supplierKey !== null ? sapakMap.get(String(supplierKey)) ?? null : null;
            supplierId = supplier ? supplier.id : null;
            if (supplierKey !== null && !supplierId) {
              missingSuppliers.add(String(supplierKey));
            }
          }

          const remDate = normalizeDate(r.RemDate);
          const now = new Date();

          const columns = [
            "id",
            "tenantId",
            "branchId",
            "cntId",
            "lastName",
            "firstName",
            "workPhone",
            "homePhone",
            "cellPhone",
            "fax",
            "address",
            "zipCode",
            "cityId",
            "email",
            "website",
            "comment",
            "hidCom",
            "isSapak",
            "creditCon",
            "remDate",
          ];
          if (includeSupplierId) {
            columns.push(supplierColumn);
          }
          columns.push("createdAt", "updatedAt");

          const valueArray = [
            createId(), // id (uuid)
            tenantId, // tenantId
            normalizedBranchId || null, // branchId
            String(cntId), // cntId
            cleanText(r.LastName), // lastName
            cleanText(r.FirstName), // firstName
            cleanText(r.WorkPhone), // workPhone
            cleanText(r.HomePhone), // homePhone
            cleanText(r.CellPhone), // cellPhone
            cleanText(r.Fax), // fax
            cleanText(r.Address), // address
            r.ZipCode != null ? String(r.ZipCode) : null, // zipCode
            cityId, // cityId (uuid from City)
            cleanText(r.EMail), // email
            cleanText(r.WebSite), // website
            cleanText(r.Comment), // comment
            cleanText(r.HidCom), // hidCom
            Boolean(r.IsSapak), // isSapak
            r.CreditCon != null ? String(r.CreditCon) : null, // creditCon
            remDate, // remDate
          ];
          if (includeSupplierId) {
            valueArray.push(supplierId); // supplierId (uuid from CrdBuysWorkSapak)
          }
          valueArray.push(now, now); // createdAt, updatedAt

          const base = params.length;
          const placeholders = columns.map((_, idx) => `$${base + idx + 1}`).join(", ");
          values.push(`(${placeholders})`);
          params.push(...valueArray);
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          const insertColumns = [
            `"id"`,
            `"tenantId"`,
            `"branchId"`,
            `"cntId"`,
            `"lastName"`,
            `"firstName"`,
            `"workPhone"`,
            `"homePhone"`,
            `"cellPhone"`,
            `"fax"`,
            `"address"`,
            `"zipCode"`,
            `"cityId"`,
            `"email"`,
            `"website"`,
            `"comment"`,
            `"hidCom"`,
            `"isSapak"`,
            `"creditCon"`,
            `"remDate"`,
          ];
          if (includeSupplierId) {
            insertColumns.push(`"${supplierColumn}"`);
          }
          insertColumns.push(`"createdAt"`, `"updatedAt"`);

          const updates = [
            `"branchId" = EXCLUDED."branchId"`,
            `"lastName" = EXCLUDED."lastName"`,
            `"firstName" = EXCLUDED."firstName"`,
            `"workPhone" = EXCLUDED."workPhone"`,
            `"homePhone" = EXCLUDED."homePhone"`,
            `"cellPhone" = EXCLUDED."cellPhone"`,
            `fax = EXCLUDED.fax`,
            `address = EXCLUDED.address`,
            `"zipCode" = EXCLUDED."zipCode"`,
            `"cityId" = EXCLUDED."cityId"`,
            `email = EXCLUDED.email`,
            `website = EXCLUDED.website`,
            `comment = EXCLUDED.comment`,
            `"hidCom" = EXCLUDED."hidCom"`,
            `"isSapak" = EXCLUDED."isSapak"`,
            `"creditCon" = EXCLUDED."creditCon"`,
            `"remDate" = EXCLUDED."remDate"`,
            `"updatedAt" = EXCLUDED."updatedAt"`,
          ];
          if (includeSupplierId) {
            updates.push(`"${supplierColumn}" = EXCLUDED."${supplierColumn}"`);
          }

          const sql = `
            INSERT INTO "Contact" (
              ${insertColumns.join(", ")}
            ) VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "cntId") DO UPDATE SET
              ${updates.join(", ")}
          `;
          await pg.query(sql, params);
          await pg.query("COMMIT");
        } catch (e) {
          await pg.query("ROLLBACK");
          throw e;
        }

        total += values.length;
      }

      lastId = rows[rows.length - 1].CntID;
      console.log(`Contacts migrated: ${total} (lastId=${lastId})`);
    }

    if (missingCities.size) {
      const sample = Array.from(missingCities).slice(0, 10);
      const suffix = missingCities.size > sample.length ? " ..." : "";
      console.log(
        `⚠️ Missing City mappings for ${missingCities.size} contacts. Sample legacy IDs: ${sample.join(", ")}${suffix}`
      );
    }
    if (missingSuppliers.size) {
      const sample = Array.from(missingSuppliers).slice(0, 10);
      const suffix = missingSuppliers.size > sample.length ? " ..." : "";
      console.log(
        `⚠️ Missing supplier mappings for ${missingSuppliers.size} contacts. Sample SapakID values: ${sample.join(", ")}${suffix}`
      );
    }

    if (skippedInvalidId) {
      console.log(`⚠️ Skipped ${skippedInvalidId} contacts due to invalid CntID`);
    }
    if (skippedMissingCity) {
      console.log(`⚠️ Skipped ${skippedMissingCity} contacts due to missing City mapping`);
    }

    console.log(`✅ Contact migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateContact;
