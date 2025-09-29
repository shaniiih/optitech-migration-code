const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  const parsed = Number(String(value).trim());
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function asNumber(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? value : null;
  const parsed = Number(String(value).trim());
  return Number.isFinite(parsed) ? parsed : null;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function normalizeLegacyId(value) {
  if (value === null || value === undefined) return null;

  if (typeof value === "number" && Number.isFinite(value)) {
    return String(value);
  }

  if (typeof value === "bigint") {
    return value.toString();
  }

  if (Buffer.isBuffer(value)) {
    return normalizeLegacyId(value.toString("utf8"));
  }

  const trimmed = String(value).trim();
  if (!trimmed) return null;

  if (/^[+-]?\d+(?:\.0+)?$/.test(trimmed)) {
    return String(parseInt(trimmed, 10));
  }

  return trimmed.toLowerCase();
}

function legacyIdCandidates(value) {
  const normalized = normalizeLegacyId(value);
  if (!normalized) return [];

  const candidates = new Set([normalized]);
  if (/\D/.test(normalized)) {
    const digitsOnly = normalized.replace(/\D+/g, "");
    if (digitsOnly) {
      const numericCandidate = normalizeLegacyId(digitsOnly);
      if (numericCandidate) {
        candidates.add(numericCandidate);
      }
    }
  }

  return Array.from(candidates);
}

async function ensureCustomer({
  tenantId,
  legacyValue,
  mysql,
  pg,
  customerMap,
  createdCustomers
}) {
  const candidates = legacyIdCandidates(legacyValue);
  if (!candidates.length) {
    return null;
  }

  for (const key of candidates) {
    if (customerMap.has(key)) {
      return customerMap.get(key);
    }
  }

  for (const key of candidates) {
    const { rows } = await pg.query(
      'SELECT id FROM "Customer" WHERE "tenantId" = $1 AND "customerId" = $2 LIMIT 1',
      [tenantId, key]
    );
    if (rows.length) {
      const resolvedId = rows[0].id;
      for (const candidate of candidates) {
        customerMap.set(candidate, resolvedId);
      }
      return resolvedId;
    }
  }

  const primaryKey = candidates[0];
  let firstName = "Legacy";
  let lastName = `Customer ${primaryKey}`;

  try {
    const [legacyRows] = await mysql.query(
      'SELECT FirstName, LastName FROM tblPerData WHERE PerId = ? LIMIT 1',
      [primaryKey]
    );
    if (legacyRows.length) {
      firstName = cleanText(legacyRows[0].FirstName) || firstName;
      lastName = cleanText(legacyRows[0].LastName) || lastName;
    }
  } catch (error) {
    console.warn(`⚠️ Failed to load legacy customer ${primaryKey}: ${error.message}`);
  }

  const now = new Date();
  const newId = uuidv4();

  await pg.query(
    `INSERT INTO "Customer" (
      id,
      "tenantId",
      "customerId",
      "firstName",
      "lastName",
      "createdAt",
      "updatedAt"
    )
    VALUES ($1, $2, $3, $4, $5, $6, $6)
    ON CONFLICT ("tenantId", "customerId") DO UPDATE SET
      "firstName" = EXCLUDED."firstName",
      "lastName" = EXCLUDED."lastName",
      "updatedAt" = EXCLUDED."updatedAt"`,
    [
      newId,
      tenantId,
      primaryKey,
      firstName || "Legacy",
      lastName || `Customer ${primaryKey}`,
      now
    ]
  );

  const { rows } = await pg.query(
    'SELECT id FROM "Customer" WHERE "tenantId" = $1 AND "customerId" = $2 LIMIT 1',
    [tenantId, primaryKey]
  );

  if (!rows.length) {
    return null;
  }

  const resolvedId = rows[0].id;
  for (const candidate of candidates) {
    customerMap.set(candidate, resolvedId);
  }

  if (createdCustomers) {
    createdCustomers.count += 1;
    if (createdCustomers.examples.size < 10) {
      createdCustomers.examples.add(primaryKey);
    }
  }

  return resolvedId;
}

async function ensureUser({
  tenantId,
  legacyUserId,
  mysql,
  pg,
  userMap,
  createdUsers
}) {
  const candidates = legacyIdCandidates(legacyUserId);
  if (!candidates.length) {
    return null;
  }

  for (const key of candidates) {
    if (userMap.has(key)) {
      return userMap.get(key);
    }
  }

  const emailCandidates = candidates.map((key) => `user-${key}@legacy.local`);
  const { rows: existingRows } = await pg.query(
    'SELECT id, email FROM "User" WHERE "tenantId" = $1 AND email = ANY($2::text[]) LIMIT 1',
    [tenantId, emailCandidates]
  );
  if (existingRows.length) {
    const resolvedId = existingRows[0].id;
    for (const candidate of candidates) {
      userMap.set(candidate, resolvedId);
    }
    return resolvedId;
  }

  const primaryKey = candidates[0];
  let firstName = "Legacy";
  let lastName = `User ${primaryKey}`;
  try {
    const [legacyRows] = await mysql.query(
      'SELECT FirstName, LastName FROM tblUsers WHERE UserId = ? LIMIT 1',
      [primaryKey]
    );
    if (legacyRows.length) {
      firstName = cleanText(legacyRows[0].FirstName) || firstName;
      lastName = cleanText(legacyRows[0].LastName) || lastName;
    }
  } catch (error) {
    console.warn(`⚠️ Failed to load legacy user ${primaryKey}: ${error.message}`);
  }

  const now = new Date();
  const newId = uuidv4();
  const email = `user-${primaryKey}@legacy.local`;

  await pg.query(
    `INSERT INTO "User" (
      id,
      "tenantId",
      email,
      password,
      "firstName",
      "lastName",
      "firstNameHe",
      "lastNameHe",
      role,
      active,
      "createdAt",
      "updatedAt",
      "branchId"
    )
    VALUES ($1, $2, $3, $4, $5, $6, NULL, NULL, 'EMPLOYEE', true, $7, $7, NULL)
    ON CONFLICT ("tenantId", email) DO UPDATE SET
      password = EXCLUDED.password,
      "firstName" = EXCLUDED."firstName",
      "lastName" = EXCLUDED."lastName",
      "updatedAt" = EXCLUDED."updatedAt"
    `,
    [newId, tenantId, email, "", firstName || "Legacy", lastName || `User ${primaryKey}`, now]
  );

  const { rows } = await pg.query(
    'SELECT id FROM "User" WHERE "tenantId" = $1 AND email = $2 LIMIT 1',
    [tenantId, email]
  );

  if (!rows.length) {
    return null;
  }

  const resolvedId = rows[0].id;
  for (const candidate of candidates) {
    userMap.set(candidate, resolvedId);
  }

  if (createdUsers) {
    createdUsers.count += 1;
    if (createdUsers.examples.size < 10) {
      createdUsers.examples.add(primaryKey);
    }
  }

  return resolvedId;
}

function asDate(value) {
  if (!value) return null;
  const date = value instanceof Date ? value : new Date(value);
  return Number.isFinite(date.getTime()) ? date : null;
}

function resolveStatus(canceled) {
  if (canceled === null || canceled === undefined) return "COMPLETED";
  if (typeof canceled === "boolean") return canceled ? "CANCELLED" : "COMPLETED";
  const str = String(canceled).trim().toLowerCase();
  if (!str) return "COMPLETED";
  return str === "1" || str === "true" || str === "yes" ? "CANCELLED" : "COMPLETED";
}

async function migratePurchase(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let totalProcessed = 0;
  let skippedMissingFields = 0;
  let skippedMissingBranch = 0;
  let skippedMissingCustomer = 0;
  const createdCustomers = { count: 0, examples: new Set() };
  const createdUsers = { count: 0, examples: new Set() };

  const branchIds = new Set();
  try {
    const { rows } = await pg.query('SELECT id FROM "Branch"');
    for (const row of rows) {
      if (row.id !== null && row.id !== undefined) {
        branchIds.add(String(row.id));
      }
    }
  } catch (error) {
    console.warn('⚠️ Could not load Branch ids, all purchases will be stored without branch reference.', error.message);
  }
  const customerMap = new Map();
  try {
    const { rows } = await pg.query(
      'SELECT id, "customerId" FROM "Customer" WHERE "tenantId" = $1',
      [tenantId]
    );
    for (const row of rows) {
      const candidates = legacyIdCandidates(row.customerId);
      if (!candidates.length) continue;
      for (const candidate of candidates) {
        if (!customerMap.has(candidate)) {
          customerMap.set(candidate, row.id);
        }
      }
    }
  } catch (error) {
    console.warn(
      '⚠️ Could not load existing customer mappings; placeholder customers will be created as needed.',
      error.message
    );
  }

  const userMap = new Map();
  try {
    const { rows } = await pg.query(
      'SELECT id, email FROM "User" WHERE "tenantId" = $1',
      [tenantId]
    );
    for (const row of rows) {
      const email = row.email ? row.email.toLowerCase() : null;
      if (!email) continue;
      const match = email.match(/^user-(.+)@legacy\.local$/);
      if (match) {
        const legacyKey = normalizeLegacyId(match[1]);
        if (legacyKey && !userMap.has(legacyKey)) {
          userMap.set(legacyKey, row.id);
        }
      }
      const digitsMatch = email.match(/^(\d+)@legacy\.local$/);
      if (digitsMatch) {
        const legacyKey = normalizeLegacyId(digitsMatch[1]);
        if (legacyKey && !userMap.has(legacyKey)) {
          userMap.set(legacyKey, row.id);
        }
      }
    }
  } catch (error) {
    console.warn(
      '⚠️ Could not load existing user mappings; placeholder users will be created as needed.',
      error.message
    );
  }

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT BuyId, BuyDate, PerId, UserId, Comment, PayedFor,
                BuyType, BranchId, Canceled
           FROM tblCrdBuys
          WHERE BuyId > ?
          ORDER BY BuyId
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
          const buyId = asInteger(row.BuyId);
          const legacyCustomerRaw = row.PerId;
          const userId = asInteger(row.UserId);
          const branchId = asInteger(row.BranchId);
          const purchaseDate = asDate(row.BuyDate) || timestamp;

          if (buyId === null) {
            skippedMissingFields += 1;
            continue;
          }

          if (legacyCustomerRaw === null || legacyCustomerRaw === undefined) {
            skippedMissingFields += 1;
            continue;
          }

          const purchaseId = String(buyId);
          const customerIdValue = await ensureCustomer({
            tenantId,
            legacyValue: legacyCustomerRaw,
            mysql,
            pg,
            customerMap,
            createdCustomers
          });

          if (!customerIdValue) {
            skippedMissingCustomer += 1;
            continue;
          }
          const userIdValue =
            userId !== null
              ? await ensureUser({
                  tenantId,
                  legacyUserId: userId,
                  mysql,
                  pg,
                  userMap,
                  createdUsers
                })
              : null;

          const purchaseType =
            cleanText(row.BuyType) ??
            (row.BuyType !== null && row.BuyType !== undefined ? String(row.BuyType) : null);
          const comment = cleanText(row.Comment);
          const totalAmount = asNumber(row.PayedFor) ?? 0;
          const status = resolveStatus(row.Canceled);
          const branchLegacyId = branchId !== null ? String(branchId) : null;
          const branchIdValue = branchLegacyId && branchIds.has(branchLegacyId) ? branchLegacyId : null;
          if (branchLegacyId && branchIdValue === null) {
            skippedMissingBranch += 1;
          }

          const offset = params.length;
          values.push(
            `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8}, $${offset + 9}, $${offset + 10}, $${offset + 11}, $${offset + 12}, $${offset + 13}, $${offset + 14})`
          );

          params.push(
            uuidv4(),
            tenantId,
            purchaseId,
            purchaseDate,
            customerIdValue,
            userIdValue,
            purchaseType,
            totalAmount,
            totalAmount,
            comment,
            status,
            timestamp,
            timestamp,
            branchIdValue
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "Purchase" (
              id,
              "tenantId",
              "purchaseId",
              "purchaseDate",
              "customerId",
              "userId",
              "purchaseType",
              "totalAmount",
              "paidAmount",
              comment,
              status,
              "createdAt",
              "updatedAt",
              "branchId"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("purchaseId") DO UPDATE SET
              "tenantId" = EXCLUDED."tenantId",
              "purchaseDate" = EXCLUDED."purchaseDate",
              "customerId" = EXCLUDED."customerId",
              "userId" = EXCLUDED."userId",
              "purchaseType" = EXCLUDED."purchaseType",
              "totalAmount" = EXCLUDED."totalAmount",
              "paidAmount" = EXCLUDED."paidAmount",
              comment = EXCLUDED.comment,
              status = EXCLUDED.status,
              "branchId" = EXCLUDED."branchId",
              "updatedAt" = EXCLUDED."updatedAt"`,
            params
          );
          await pg.query("COMMIT");
          totalProcessed += values.length;
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }
      }

      lastId = asInteger(rows[rows.length - 1].BuyId) ?? lastId;
      console.log(`Purchase migrated so far: ${totalProcessed} (lastId=${lastId})`);
    }

    console.log(`✅ Purchase migration completed. Total inserted/updated: ${totalProcessed}`);
    if (skippedMissingFields) {
      console.warn(`⚠️ Skipped ${skippedMissingFields} rows due to missing BuyId or PerId.`);
    }
    if (skippedMissingBranch) {
      console.warn(`⚠️ Cleared branch reference for ${skippedMissingBranch} purchases because matching Branch id was not found.`);
    }
    if (skippedMissingCustomer) {
      console.warn(`⚠️ Skipped ${skippedMissingCustomer} purchases because matching Customer id was not found.`);
    }
    if (createdCustomers.count) {
      const sampleText = createdCustomers.examples.size
        ? ` (examples: ${Array.from(createdCustomers.examples).join(", ")})`
        : "";
      console.warn(
        `⚠️ Created ${createdCustomers.count} placeholder customers while migrating purchases${sampleText}.`
      );
    }
    if (createdUsers.count) {
      const sampleText = createdUsers.examples.size
        ? ` (examples: ${Array.from(createdUsers.examples).join(", ")})`
        : "";
      console.warn(
        `⚠️ Created ${createdUsers.count} placeholder users while migrating purchases${sampleText}.`
      );
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migratePurchase;
