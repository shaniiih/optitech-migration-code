const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");
const { ensureTenantId } = require("./tenantUtils");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;


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

        for (const r of chunk) {
          const id = uuidv4();
          const now = new Date();

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10}, $${params.length + 11}, $${params.length + 12}, $${params.length + 13}, $${params.length + 14}, $${params.length + 15}, $${params.length + 16}, $${params.length + 17}, $${params.length + 18}, $${params.length + 19}, $${params.length + 20}, $${params.length + 21}, $${params.length + 22}, $${params.length + 23}, $${params.length + 24}, $${params.length + 25}, $${params.length + 26}, $${params.length + 27}, $${params.length + 28}, $${params.length + 29})`
          );

          params.push(
            id, // id
            tenantId, // tenantId
            branchId, // branchId
            String(r.LetterName || ""), // templateName (use legacy LetterName)
            String(r.LetterName || ""), // subject (use legacy LetterName)
            r.Text2 || "", // content (fallback to Text2)
            "GENERAL", // category default
            null, // mergeFields
            true, // isActive
            now, // createdAt
            now, // updatedAt
            String(r.LetterName || null), // letterName
            r.Text1 || null, // text1
            r.Text2 || null, // text2
            r.Text3 || null, // text3
            r.Text4 || null, // text4
            r.Text1Style != null ? String(r.Text1Style) : null, // text1Style as string
            r.Text2Style != null ? String(r.Text2Style) : null, // text2Style as string
            r.Text3Style != null ? String(r.Text3Style) : null, // text3Style as string
            r.Text4Style != null ? String(r.Text4Style) : null, // text4Style as string
            r.Text1Font || null, // text1Font
            r.Text2Font || null, // text2Font
            r.Text3Font || null, // text3Font
            r.Text4Font || null, // text4Font
            r.Text1Size != null ? String(r.Text1Size) : null, // text1Size as string
            r.Text2Size != null ? String(r.Text2Size) : null, // text2Size as string
            r.Text3Size != null ? String(r.Text3Size) : null, // text3Size as string
            r.Text4Size != null ? String(r.Text4Size) : null, // text4Size as string
            String(r.LetterId) // LetterId as string
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          const sql = `
            INSERT INTO "Letter" (
              id, "tenantId", "branchId", "templateName", subject, content, category,
              "mergeFields", "isActive", "createdAt", "updatedAt",
              "letterName", "text1", "text2", "text3", "text4",
              "text1Style", "text2Style", "text3Style", "text4Style",
              "text1Font", "text2Font", "text3Font", "text4Font",
              "text1Size", "text2Size", "text3Size", "text4Size",
              "LetterId"
            ) VALUES ${values.join(",")}
            ON CONFLICT (id) DO UPDATE SET
              "templateName" = EXCLUDED."templateName",
              subject = EXCLUDED.subject,
              content = EXCLUDED.content,
              category = EXCLUDED.category,
              "mergeFields" = EXCLUDED."mergeFields",
              "isActive" = EXCLUDED."isActive",
              "updatedAt" = EXCLUDED."updatedAt",
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
              "branchId" = EXCLUDED."branchId",
              "LetterId" = EXCLUDED."LetterId";
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

function toSmallInt(v) {
  if (v === null || v === undefined) return null;
  const n = Number(v);
  return Number.isFinite(n) ? n : null;
}

module.exports = migrateLetter;
