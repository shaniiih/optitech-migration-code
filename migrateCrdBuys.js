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

function toBoolean(value) {
    if (value === null || value === undefined) return null;
    if (typeof value === "boolean") return value;
    if (typeof value === "number") return Number.isFinite(value) ? value !== 0 : null;
    const trimmed = String(value).trim().toLowerCase();
    if (!trimmed) return null;
    if (["1", "true", "t", "yes", "y"].includes(trimmed)) return true;
    if (["0", "false", "f", "no", "n"].includes(trimmed)) return false;
    return null;
}

async function migrateCrdBuys(tenantId = "tenant_1", branchId = null) {
    const mysql = await getMySQLConnection();
    const pg = await getPostgresConnection();

    let offset = 0;
    let total = 0;

    try {
        const userMap = new Map();
        const branchMap = new Map();
        const perMap = new Map();
        const groupMap = new Map();
        const glassMap = new Map();

        const { rows: userRows } = await pg.query(
            `SELECT id, "userId"
             FROM "User"
             WHERE "tenantId" = $1 AND "branchId" = $2`,
            [tenantId, branchId]
        );
        for (const row of userRows) {
            const legacy = normalizeInt(row.userId);
            if (legacy !== null) userMap.set(legacy, row.id);
        }

        const { rows: branchRows } = await pg.query(
            `SELECT id, "branchId"
             FROM "Branch"
             WHERE "tenantId" = $1`,
            [tenantId]
        );
        for (const row of branchRows) {
            const legacy = normalizeInt(row.branchId);
            if (legacy !== null) branchMap.set(legacy, row.id);
        }

        const { rows: perRows } = await pg.query(
            `SELECT id, "perId"
             FROM "PerData"
             WHERE "tenantId" = $1 AND "branchId" = $2`,
            [tenantId, branchId]
        );
        for (const row of perRows) {
            const legacy = normalizeInt(row.perId);
            if (legacy !== null) perMap.set(legacy, row.id);
        }

        const { rows: groupRows } = await pg.query(
            `SELECT id, "groupId"
             FROM "Group"
             WHERE "tenantId" = $1 AND "branchId" = $2`,
            [tenantId, branchId]
        );
        for (const row of groupRows) {
            const legacy = normalizeInt(row.groupId);
            if (legacy !== null) groupMap.set(legacy, row.id);
        }
        const { rows: glassRows } = await pg.query(
            `SELECT id, "glassCId"
            FROM "CrdGlassCheck"
            WHERE "tenantId" = $1 AND "branchId" = $2`,
            [tenantId, branchId]
        );
        for (const row of glassRows) {
            const legacy = normalizeInt(row.glassCId);
            if (legacy !== null) glassMap.set(legacy, row.id);
        }

        while (true) {
            const [rows] = await mysql.query(
                `
                SELECT BuyId, BuyDate, GroupId, PerId, UserId,
                       PayedFor, BuyType, BuySrcId, BranchId, Canceled
                FROM tblCrdBuys
                ORDER BY BuyId
                LIMIT ? OFFSET ?`,
                [WINDOW_SIZE, offset]
            );

            if (!rows.length) break;

            for (let i = 0; i < rows.length; i += BATCH_SIZE) {
                const chunk = rows.slice(i, i + BATCH_SIZE);
                const now = new Date();
                const values = [];
                const params = [];

                for (const row of chunk) {
                    const legacyBuyId = normalizeInt(row.BuyId);
                    const legacyUserId = normalizeInt(row.UserId);
                    const legacyBranchId = normalizeInt(row.BranchId);
                    const legacyPerId = normalizeInt(row.PerId);
                    const legacyGroupId = normalizeInt(row.GroupId);

                    const userId = userMap.get(legacyUserId) || null;
                    const branchNewRefId = branchMap.get(legacyBranchId) || null;
                    const perId = perMap.get(legacyPerId) || null;
                    const groupId = groupMap.get(legacyGroupId) || null;
                    const legacyBuySrcId = normalizeInt(row.BuySrcId);
                    const buySrcId = glassMap.get(legacyBuySrcId) || null;
                    const base = params.length;

                    values.push(
                        `(
                            $${base + 1}, $${base + 2}, $${base + 3}, $${base + 4},
                            $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8},
                            $${base + 9}, $${base + 10}, $${base + 11}, $${base + 12},
                            $${base + 13}, $${base + 14}, $${base + 15}, $${base + 16},
                            $${base + 17}, $${base + 18}, $${base + 19}, $${base + 20}
                        )`
                    );

                    params.push(
                        createId(),
                        tenantId,
                        branchId,
                        legacyBuyId,
                        row.BuyDate ? new Date(row.BuyDate) : null,
                        groupId,
                        legacyGroupId,
                        perId,
                        legacyPerId,
                        userId,
                        legacyUserId,
                        cleanNumber(row.PayedFor),
                        normalizeInt(row.BuyType),
                        buySrcId,
                        legacyBuySrcId,
                        legacyBranchId,
                        branchNewRefId,
                        toBoolean(row.Canceled),
                        now,
                        now
                    );
                }

                if (!values.length) continue;

                await pg.query("BEGIN");
                try {
                    await pg.query(
                        `
                        INSERT INTO "CrdBuy" (
                            id, "tenantId", "branchId", "buyId", "buyDate",
                            "groupId", "legacyGroupId",
                            "perId", "legacyPerId",
                            "userId", "legacyUserId",
                            "payedFor", "buyType", "buySrcId","legacyBuySrcId",
                            "legacyBranchId", "legacyBranchNewRefId",
                            "canceled", "createdAt", "updatedAt"
                        )
                        VALUES ${values.join(",")}
                        ON CONFLICT ("tenantId", "branchId", "buyId")
                        DO UPDATE SET
                            "buyDate" = EXCLUDED."buyDate",
                            "groupId" = EXCLUDED."groupId",
                            "legacyGroupId" = EXCLUDED."legacyGroupId",
                            "perId" = EXCLUDED."perId",
                            "legacyPerId" = EXCLUDED."legacyPerId",
                            "userId" = EXCLUDED."userId",
                            "legacyUserId" = EXCLUDED."legacyUserId",
                            "payedFor" = EXCLUDED."payedFor",
                            "buyType" = EXCLUDED."buyType",
                            "buySrcId" = EXCLUDED."buySrcId",
                            "legacyBuySrcId" = EXCLUDED."legacyBuySrcId",
                            "legacyBranchId" = EXCLUDED."legacyBranchId",
                            "legacyBranchNewRefId" = EXCLUDED."legacyBranchNewRefId",
                            "canceled" = EXCLUDED."canceled",
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
        }
    } finally {
        await mysql.end();
        await pg.end();
    }
}

module.exports = migrateCrdBuys;
