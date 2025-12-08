const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

function normalizeInt(value) {
    if (value === null || value === undefined) return null;
    if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
    if (typeof value === "bigint") return Number(value);
    if (Buffer.isBuffer(value)) return normalizeInt(value.toString("utf8"));
    const trimmed = String(value).trim();
    if (!trimmed) return null;
    const parsed = Number(trimmed);
    return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function cleanText(value) {
    if (value === null || value === undefined) return null;
    const t = String(value).trim();
    return t.length ? t : null;
}

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 500;

async function migrateCrdOverView(tenantId = "tenant_1", branchId = null) {
    const mysql = await getMySQLConnection();
    const pg = await getPostgresConnection();
    let offset = 0;
    let total = 0;

    try {
        const buildMap = async (table, legacyField) => {
            const map = new Map();
            const { rows } = await pg.query(
                `SELECT id, "${legacyField}" FROM "${table}" WHERE "tenantId" = $1 AND "branchId" IS NOT DISTINCT FROM $2`,
                [tenantId, branchId]
            );
            for (const r of rows) {
                const legacy = normalizeInt(r[legacyField]);
                if (legacy !== null) map.set(legacy, r.id);
            }
            return map;
        };
        const perMap = await buildMap("PerData", "perId");
        const userMap = await buildMap("User", "userId");

        while (true) {
            const [rows] = await mysql.query(
                `SELECT * FROM tblCrdOverViews ORDER BY PerId, CheckDate LIMIT ? OFFSET ?`,
                [WINDOW_SIZE, offset]
            );
            if (!rows.length) break;

            for (let i = 0; i < rows.length; i += BATCH_SIZE) {
                const chunk = rows.slice(i, i + BATCH_SIZE);
                const now = new Date();
                const values = [];
                const params = [];
                let p = 1;

                for (const row of chunk) {
                    const legacyPerId = normalizeInt(row.PerId);
                    const perId = perMap.get(legacyPerId) || null;

                    const legacyUserId = normalizeInt(row.UserId);
                    const userId = userMap.get(legacyUserId) || null;

                    const rowValues = [
                        createId(),
                        tenantId,
                        branchId,
                        perId,
                        legacyPerId,
                        row.CheckDate ? new Date(row.CheckDate) : null,
                        cleanText(row.Comments),
                        cleanText(row.VAR),
                        cleanText(row.VAL),
                        userId,
                        legacyUserId,
                        cleanText(row.Pic),
                        now,
                        now
                    ];

                    const placeholders = rowValues.map(() => `$${p++}`);
                    values.push(`(${placeholders.join(",")})`);
                    params.push(...rowValues);
                }

                if (!values.length) continue;

                await pg.query("BEGIN");
                try {
                    await pg.query(
                        `
                    INSERT INTO "CrdOverView"
                    ("id","tenantId","branchId","perId","legacyPerId","checkDate","comments","var","val","userId","legacyUserId","pic","createdAt","updatedAt")
                    VALUES ${values.join(",")}
                    ON CONFLICT ("tenantId","branchId","legacyPerId","checkDate")
                    DO UPDATE SET
                    "perId" = EXCLUDED."perId",
                    "comments" = EXCLUDED."comments",
                    "var" = EXCLUDED."var",
                    "val" = EXCLUDED."val",
                    "userId" = EXCLUDED."userId",
                    "pic" = EXCLUDED."pic",
                    "updatedAt" = EXCLUDED."updatedAt"
                    `,
                        params
                    );
                    await pg.query("COMMIT");
                    total += values.length;
                } catch (err) {
                    await pg.query("ROLLBACK");
                    throw err;
                }
            }


            offset += rows.length;
        }

    }
    finally {
        await mysql.end();
        await pg.end();
    }
}

module.exports={migrateCrdOverView}