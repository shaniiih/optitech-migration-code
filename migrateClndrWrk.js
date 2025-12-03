const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

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

function cleanNumber(value) {
    if (value === null || value === undefined) return null;
    if (typeof value === "number") return Number.isFinite(value) ? value : null;
    if (typeof value === "bigint") return Number(value);
    if (Buffer.isBuffer(value)) return cleanNumber(value.toString("utf8"));
    const trimmed = String(value).trim();
    if (!trimmed) return null;
    const parsed = Number(trimmed);
    return Number.isFinite(parsed) ? parsed : null;
}

async function migrateClndrWrk(tenantId = "tenant_1", branchId = null) {
    const mysql = await getMySQLConnection();
    const pg = await getPostgresConnection();

    let offset = 0;
    let total = 0;

    try {
        const userMap = new Map();
        {
            const { rows } = await pg.query(
                `SELECT id, "userId" FROM "User"
                 WHERE "tenantId" = $1 AND "branchId" = $2`,
                [tenantId, branchId]
            );

            for (const row of rows) {
                const legacyId = normalizeInt(row.userId);
                if (legacyId !== null && !userMap.has(legacyId)) {
                    userMap.set(legacyId, row.id);
                }
            }
        }

        while (true) {
            const [rows] = await mysql.query(
                `
                SELECT WrkId, UserID, WrkDate, WrkTime, StartTime, EndTime
                FROM tblClndrWrk
                ORDER BY WrkId
                LIMIT ? OFFSET ?
                `,
                [WINDOW_SIZE, offset]
            );

            if (!rows.length) break;

            for (let i = 0; i < rows.length; i += BATCH_SIZE) {
                const chunk = rows.slice(i, i + BATCH_SIZE);

                const now = new Date();
                const values = [];
                const params = [];

                for (const row of chunk) {
                    const wrkId = normalizeInt(row.WrkId);
                    const legacyUserId = normalizeInt(row.UserID);
                    const wrkDate = row.WrkDate ? new Date(row.WrkDate) : null;
                    const wrkTime = cleanNumber(row.WrkTime);
                    const startTime = row.StartTime ? new Date(row.StartTime) : null;
                    const endTime = row.EndTime ? new Date(row.EndTime) : null;
                    const userId = userMap.get(legacyUserId) || null;

                    const base = params.length;
                    values.push(
                        `(
                            $${base + 1}, $${base + 2}, $${base + 3}, $${base + 4},
                            $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8},
                            $${base + 9}, $${base + 10}, $${base + 11}, $${base + 12}
                        )`
                    );

                    params.push(
                        createId(),
                        tenantId,
                        branchId,
                        wrkId,
                        legacyUserId,
                        wrkDate,
                        wrkTime,
                        startTime,
                        endTime,
                        userId,
                        now,
                        now
                    );
                }

                if (!values.length) continue;

                await pg.query("BEGIN");
                try {
                    await pg.query(
                        `
                        INSERT INTO "ClndrWrk" (
                            id,
                            "tenantId",
                            "branchId",
                            "wrkId",
                            "legacyUserId",
                            "wrkDate",
                            "wrkTime",
                            "startTime",
                            "endTime",
                            "userId",
                            "createdAt",
                            "updatedAt"
                        )
                        VALUES ${values.join(",")}
                        ON CONFLICT ("tenantId", "branchId", "wrkId")
                        DO UPDATE SET
                            "legacyUserId" = EXCLUDED."legacyUserId",
                            "wrkDate" = EXCLUDED."wrkDate",
                            "wrkTime" = EXCLUDED."wrkTime",
                            "startTime" = EXCLUDED."startTime",
                            "endTime" = EXCLUDED."endTime",
                            "userId" = EXCLUDED."userId",
                            "updatedAt" = NOW();
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
            console.log(`ClndrWrk migrated so far: ${total} (offset=${offset})`);
        }

        console.log(`✅ ClndrWrk migration completed. Total inserted/updated: ${total}`);
    } finally {
        await mysql.end();
        await pg.end();
    }
}

module.exports = migrateClndrWrk;
