const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");
const { ensureTenantId } = require("./tenantUtils");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function asInteger(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
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

async function migrateLetter(tenantId, branchId) {
  tenantId = ensureTenantId(tenantId);

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = -1;
  let total = 0;

  try {
    while (true) {
      const [rows] = await mysql.execute(
        `SELECT LetterId, LetterName, Text1, Text2, Text3, Text4,
                Text1Style, Text2Style, Text3Style, Text4Style,
                Text1Font, Text2Font, Text3Font, Text4Font,
                Text1Size, Text2Size, Text3Size, Text4Size
           FROM tblLetters
          WHERE LetterId > ?
          ORDER BY LetterId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);

        const values = [];
        const params = [];
        const timestamp = new Date();

        for (const r of chunk) {
          const letterId = asInteger(r.LetterId);
          if (letterId === null) continue;

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9}, $${base + 10}, $${base + 11}, $${base + 12}, $${base + 13}, $${base + 14}, $${base + 15}, $${base + 16}, $${base + 17}, $${base + 18}, $${base + 19}, $${base + 20}, $${base + 21}, $${base + 22}, $${base + 23})`
          );

          params.push(
            uuidv4(),                      // id
            tenantId,                      // tenantId
            branchId,                      // branchId
            letterId,                      // letterId
            cleanText(r.LetterName) || null, // letterName
            r.Text1 || null,               // text1
            r.Text2 || null,               // text2
            r.Text3 || null,               // text3
            r.Text4 || null,               // text4
            asInteger(r.Text1Style),       // text1Style
            asInteger(r.Text2Style),       // text2Style
            asInteger(r.Text3Style),       // text3Style
            asInteger(r.Text4Style),       // text4Style
            r.Text1Font || null,           // text1Font
            r.Text2Font || null,           // text2Font
            r.Text3Font || null,           // text3Font
            r.Text4Font || null,           // text4Font
            asInteger(r.Text1Size),        // text1Size
            asInteger(r.Text2Size),        // text2Size
            asInteger(r.Text3Size),        // text3Size
            asInteger(r.Text4Size),        // text4Size
            timestamp,                     // createdAt
            timestamp                      // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          const sql = `
            INSERT INTO "Letter" (
              id,
              "tenantId",
              "branchId",
              "letterId",
              "letterName",
              "text1",
              "text2",
              "text3",
              "text4",
              "text1Style",
              "text2Style",
              "text3Style",
              "text4Style",
              "text1Font",
              "text2Font",
              "text3Font",
              "text4Font",
              "text1Size",
              "text2Size",
              "text3Size",
              "text4Size",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "letterId") DO UPDATE SET
              "letterName" = EXCLUDED."letterName",
              "text1" = EXCLUDED."text1",
              "text2" = EXCLUDED."text2",
              "text3" = EXCLUDED."text3",
              "text4" = EXCLUDED."text4",
              "text1Style" = EXCLUDED."text1Style",
              "text2Style" = EXCLUDED."text2Style",
              "text3Style" = EXCLUDED."text3Style",
              "text4Style" = EXCLUDED."text4Style",
              "text1Font" = EXCLUDED."text1Font",
              "text2Font" = EXCLUDED."text2Font",
              "text3Font" = EXCLUDED."text3Font",
              "text4Font" = EXCLUDED."text4Font",
              "text1Size" = EXCLUDED."text1Size",
              "text2Size" = EXCLUDED."text2Size",
              "text3Size" = EXCLUDED."text3Size",
              "text4Size" = EXCLUDED."text4Size",
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

      lastId = rows[rows.length - 1].LetterId;
      console.log(`Letters migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ Letter migration completed. Total: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateLetter;
