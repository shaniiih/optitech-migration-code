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

async function migrateCrdBuysCatNum(tenantId = "tenant_1", branchId = null) {
    const mysql = await getMySQLConnection();
    const pg = await getPostgresConnection();

    let offset = 0;
    let total = 0;

    try {
        const buyMap = new Map();
        const { rows: buyRows } = await pg.query(
            `SELECT id, "buyId", "branchId" FROM "CrdBuy" WHERE "tenantId" = $1`,
            [tenantId]
        );
        for (const row of buyRows) {
            const legacy = normalizeInt(row.buyId);
            if (legacy !== null) buyMap.set(`${row.branchId}_${legacy}`, row.id);
        }

        const itemMap = new Map();
        const { rows: itemRows } = await pg.query(
            `SELECT id, "itemId" FROM "Item" WHERE "tenantId" = $1`,
            [tenantId]
        );
        for (const row of itemRows) {
            const legacy = normalizeInt(row.itemId);
            if (legacy !== null) itemMap.set(legacy, row.id);
        }

        while (true) {
            const [rows] = await mysql.query(
                `
                SELECT CatId, BuyId, CatNum, Quantity, Price, Discount, CatLeft, ItemId
                FROM tblCrdBuysCatNums
                ORDER BY CatId
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
                    const legacyCatId = normalizeInt(row.CatId);
                    const legacyBuyId = normalizeInt(row.BuyId);
                    const legacyItemId = normalizeInt(row.ItemId);
                    const newBuyId = buyMap.get(`${branchId}_${legacyBuyId}`) || null;
                    const newItemId = itemMap.get(legacyItemId) || null;
                    const base = params.length;

                    values.push(
                        `(
                          $${base + 1}, $${base + 2}, $${base + 3},
                          $${base + 4}, $${base + 5}, $${base + 6},
                          $${base + 7}, $${base + 8}, $${base + 9},
                          $${base + 10}, $${base + 11}, $${base + 12},
                          $${base + 13}, $${base + 14}, $${base + 15}
                        )`
                    );

                    params.push(
                        createId(),
                        tenantId,
                        branchId,
                        legacyCatId,
                        legacyBuyId,
                        newBuyId,
                        row.CatNum,
                        normalizeInt(row.Quantity),
                        cleanNumber(row.Price),
                        cleanNumber(row.Discount),
                        normalizeInt(row.CatLeft),
                        legacyItemId,
                        newItemId,
                        now,
                        now
                    );
                }

                if (!values.length) continue;

                await pg.query("BEGIN");
                try {
                    await pg.query(
                        `
                        INSERT INTO "CrdBuysCatNum" (
                            id, "tenantId", "branchId", "catId",
                            "legacyBuyId", "buyId",
                            "catNum", quantity, price,
                            discount, "catLeft",
                            "legacyItemId", "itemId",
                            "createdAt", "updatedAt"
                        )
                        VALUES ${values.join(",")}
                        ON CONFLICT ("tenantId", "branchId", "catId")
                        DO UPDATE SET
                            "legacyBuyId" = EXCLUDED."legacyBuyId",
                            "buyId" = EXCLUDED."buyId",
                            "catNum" = EXCLUDED."catNum",
                            quantity = EXCLUDED.quantity,
                            price = EXCLUDED.price,
                            discount = EXCLUDED.discount,
                            "catLeft" = EXCLUDED."catLeft",
                            "legacyItemId" = EXCLUDED."legacyItemId",
                            "itemId" = EXCLUDED."itemId",
                            "updatedAt" = NOW()
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

    console.log("Migration completed:", total, "records migrated.");
}

module.exports = migrateCrdBuysCatNum;
