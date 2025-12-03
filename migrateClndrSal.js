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

async function migrateClndrSal(tenantId = "tenant_1", branchId = null) {
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
                SELECT UserID, Month, Salery
                FROM tblClndrSal
                ORDER BY UserID, Month
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
                    const legacyUserId = normalizeInt(row.UserID);
                    const month = row.Month ? new Date(row.Month) : null;
                    const salery = cleanNumber(row.Salery);
                    const userId = userMap.get(legacyUserId) || null;

                    const base = params.length;
                    values.push(
                        `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9})`
                    );

                    params.push(
                        createId(),
                        tenantId,      
                        branchId,      
                        legacyUserId,   
                        month,         
                        salery,         
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
                        INSERT INTO "ClndrSal" (
                            id,
                            "tenantId",
                            "branchId",
                            "legacyUserId",
                            "month",
                            "salery",
                            "userId",
                            "createdAt",
                            "updatedAt"
                        )
                        VALUES ${values.join(",")}
                        ON CONFLICT ("tenantId", "branchId", "legacyUserId", "month")
                        DO UPDATE SET
                            "salery" = EXCLUDED."salery",
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
            console.log(`ClndrSal migrated so far: ${total} (offset=${offset})`);
        }

        console.log(`✅ ClndrSal migration completed. Total inserted/updated: ${total}`);
    } finally {
        await mysql.end();
        await pg.end();
    }
}

module.exports = migrateClndrSal;
