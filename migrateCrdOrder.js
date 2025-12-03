const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

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

function toBooleanInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "boolean") return value ? 1 : 0;
  if (typeof value === "number") {
    if (!Number.isFinite(value)) return null;
    return value !== 0 ? 1 : 0;
  }
  const trimmed = String(value).trim().toLowerCase();
  if (!trimmed) return null;
  if (["1", "true", "t", "yes", "y"].includes(trimmed)) return 1;
  if (["0", "false", "f", "no", "n"].includes(trimmed)) return 0;
  return null;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

async function migrateCrdOrder(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.query(
        `SELECT ItemData, ListIndex, \`Desc\`, LblWiz, LblWizType, LblWizFld, LetterFld, LetterWiz
           FROM tblCrdOrder
          WHERE ItemData > ?
          ORDER BY ItemData
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const timestamp = new Date();
        const seenKeys = new Set();

        for (const row of chunk) {
          const itemData = asInteger(row.ItemData);
          const listIndex = asInteger(row.ListIndex);
          if (itemData === null || listIndex === null) continue;

          const key = `${itemData}-${listIndex}`;
          if (seenKeys.has(key)) continue;
          seenKeys.add(key);

          const description = cleanText(row.Desc);
          const lblWiz = toBooleanInt(row.LblWiz);
          const lblWizType = asInteger(row.LblWizType);
          const lblWizFld = cleanText(row.LblWizFld);
          const letterFld = cleanText(row.LetterFld);
          const letterWiz = toBooleanInt(row.LetterWiz);

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9}, $${base + 10}, $${base + 11}, $${base + 12}, $${base + 13})`
          );
          params.push(
            createId(),       // id
            tenantId,       // tenantId
            branchId,       // branchId
            itemData,       // ItemData
            listIndex,      // ListIndex
            description,    // Desc
            lblWiz,         // LblWiz
            lblWizType,     // LblWizType
            lblWizFld,      // LblWizFld
            letterFld,      // LetterFld
            letterWiz,      // LetterWiz
            timestamp,      // createdAt
            timestamp       // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `INSERT INTO "CrdOrder" (
               id,
               "tenantId",
               "branchId",
               "ItemData",
               "ListIndex",
               "Desc",
               "LblWiz",
               "LblWizType",
               "LblWizFld",
               "LetterFld",
               "LetterWiz",
               "createdAt",
               "updatedAt"
             )
             VALUES ${values.join(",")}
             ON CONFLICT ("tenantId", "branchId", "ItemData") DO UPDATE SET
               "Desc" = EXCLUDED."Desc",
               "LblWiz" = COALESCE(EXCLUDED."LblWiz", "CrdOrder"."LblWiz"),
               "LblWizType" = COALESCE(EXCLUDED."LblWizType", "CrdOrder"."LblWizType"),
               "LblWizFld" = EXCLUDED."LblWizFld",
               "LetterFld" = EXCLUDED."LetterFld",
               "LetterWiz" = COALESCE(EXCLUDED."LetterWiz", "CrdOrder"."LetterWiz"),
               "updatedAt" = EXCLUDED."updatedAt"`,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      const latestId = asInteger(rows[rows.length - 1]?.ItemData);
      if (latestId !== null) {
        lastId = latestId;
      }
      console.log(`CrdOrder migrated so far: ${total} (lastItemData=${lastId})`);
    }

    console.log(`✅ CrdOrder migration completed. Total rows processed: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCrdOrder;
