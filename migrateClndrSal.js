const { v4: uuidv4 } = require("uuid");
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

    try {
        // Map legacy UserID to new UUIDs
        const userMap = new Map();
        {
            const { rows } = await pg.query(
                `SELECT id, "userId" FROM "User" WHERE "tenantId" = $1 AND "branchId" = $2`,
                [tenantId, branchId]
            );
            for (const row of rows) {
                const legacyId = normalizeInt(row.userId);
                if (legacyId !== null && !userMap.has(legacyId)) {
                    userMap.set(legacyId, row.id);
                }
            }
        }

        // Fetch all old data
        const [rows] = await mysql.query(
            `SELECT UserID, Month, Salery FROM tblClndrSal ORDER BY UserID, Month`
        );

        if (!rows.length) {
            console.log("No data found in tblClndrSal");
            return;
        }

        const now = new Date();
        const values = [];
        const params = [];

        for (const row of rows) {
            const legacyUserId = normalizeInt(row.UserID);
            const month = row.Month ? new Date(row.Month) : null;
            const salery = cleanNumber(row.Salery);
            const userId = userMap.get(legacyUserId) || null;

            const base = params.length;
            values.push(
                `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9})`
            );


            params.push(
                uuidv4(),       // id
                tenantId,       // tenantId
                branchId,       // branchId
                legacyUserId,   // legacyUserID
                month,          // Month
                salery,         // salery
                userId,         // FK to User
                now,            // createdAt
                now             // updatedAt
            );

        }

        await pg.query("BEGIN");
        try {
            await pg.query(
                `
        INSERT INTO "ClndrSal" (
          id,
          "tenantId",
          "branchId",
          "legacyUserId",
          "Month",
          "salery",
          "userId",
          "createdAt",
          "updatedAt"
        )
        VALUES ${values.join(",")}
        ON CONFLICT ("tenantId", "branchId", "legacyUserId", "Month")
        DO UPDATE SET
          "salery" = EXCLUDED."salery",
          "userId" = EXCLUDED."userId",
          "updatedAt" = NOW();
      `,
                params
            );
            await pg.query("COMMIT");
            console.log(`✅ ClndrSal migration completed. Total rows inserted/updated: ${rows.length}`);
        } catch (err) {
            await pg.query("ROLLBACK");
            throw err;
        }
    } finally {
        await mysql.end();
        await pg.end();
    }
}

module.exports = migrateClndrSal;
