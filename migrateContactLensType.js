const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

const SOURCE_TABLES = [
  { table: "tblCrdClensTypes", idColumn: "ClensTypeId", nameColumn: "ClensTypeName" },
  { table: "tblCLnsTypes", idColumn: "CLensTypeID", nameColumn: "CLensTypeName" },
];

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  if (typeof value === "bigint") {
    return Number(value);
  }
  if (Buffer.isBuffer(value)) {
    return asInteger(value.toString("utf8"));
  }
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

async function getAvailableSources(mysql) {
  const available = [];
  for (const candidate of SOURCE_TABLES) {
    try {
      await mysql.query(`SELECT 1 FROM \`${candidate.table}\` LIMIT 1`);
      available.push(candidate);
    } catch (err) {
      if (err?.code === "ER_NO_SUCH_TABLE" || err?.sqlState === "42S02") {
        continue;
      }
      throw err;
    }
  }
  return available;
}

async function migrateContactLensType(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let total = 0;
  let skippedInvalidId = 0;

  try {
    const sources = await getAvailableSources(mysql);
    if (!sources.length) {
      throw new Error(
        "Could not find either tblCrdClensTypes or tblCLnsTypes in the MySQL source database."
      );
    }

    for (const source of sources) {
      const { inserted, skipped } = await migrateFromSource(mysql, pg, tenantId, source);
      total += inserted;
      skippedInvalidId += skipped;
    }

    console.log(`✅ ContactLensType migration completed. Total inserted/updated: ${total}`);
    if (skippedInvalidId) {
      console.warn(`⚠️ Skipped ${skippedInvalidId} rows due to invalid lens type id.`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateContactLensType;

async function migrateFromSource(mysql, pg, tenantId, source) {
  let lastId = -1;
  let inserted = 0;
  let skippedInvalidId = 0;

  console.log(
    `ContactLensType migration reading from MySQL table '${source.table}' using columns ${source.idColumn}/${source.nameColumn}.`
  );

  while (true) {
    const [rows] = await mysql.query(
      `SELECT ${source.idColumn} AS id, ${source.nameColumn} AS name
         FROM \`${source.table}\`
        WHERE ${source.idColumn} > ?
        ORDER BY ${source.idColumn}
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
        const lensTypeId = asInteger(row.id);
        if (lensTypeId === null) {
          skippedInvalidId += 1;
          continue;
        }

        const name = cleanText(row.name) || `Contact Lens Type ${lensTypeId}`;

        const offset = params.length;
        values.push(
          `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5}, $${offset + 6}, $${offset + 7}, $${offset + 8})`
        );

        params.push(
          uuidv4(),
          tenantId,
          lensTypeId,
          name,
          null,
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
          INSERT INTO "ContactLensType" (
            id,
            "tenantId",
            "lensTypeId",
            name,
            description,
            "isActive",
            "createdAt",
            "updatedAt"
          )
          VALUES ${values.join(",")}
          ON CONFLICT ("lensTypeId")
          DO UPDATE SET
            id = EXCLUDED.id,
            "tenantId" = EXCLUDED."tenantId",
            name = EXCLUDED.name,
            description = EXCLUDED.description,
            "isActive" = EXCLUDED."isActive",
            "updatedAt" = EXCLUDED."updatedAt"
          `,
          params
        );
        await pg.query("COMMIT");
        inserted += values.length;
      } catch (err) {
        await pg.query("ROLLBACK");
        throw err;
      }
    }

    lastId = asInteger(rows[rows.length - 1].id) ?? lastId;
    console.log(
      `ContactLensType (${source.table}) migrated so far: ${inserted} (lastId=${lastId})`
    );
  }

  return { inserted, skipped: skippedInvalidId };
}
