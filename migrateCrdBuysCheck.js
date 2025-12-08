const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 500;

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

function normalizeDecimal(value) {
    if (value === null || value === undefined) return null;
    const num = Number(String(value).trim());
    return Number.isFinite(num) ? num : null;
}

async function migrateCrdBuysCheck(tenantId = "tenant_1", branchId = null) {
    const mysql = await getMySQLConnection();
    const pg = await getPostgresConnection();

    let offset = 0;
    let total = 0;

    try {
        const buildMap = async (table, legacyField) => {
            const map = new Map();
            const { rows } = await pg.query(
                `SELECT id, "${legacyField}" FROM "${table}" WHERE "tenantId" = $1 AND "branchId" = $2`,
                [tenantId, branchId]
            );
            for (const r of rows) {
                const legacy = normalizeInt(r[legacyField]);
                if (legacy !== null) map.set(legacy, r.id);
            }
            return map;
        };

        const buyPayMap = await buildMap("CrdBuysPay", "buyPayId");

        while (true) {
            const [rows] = await mysql.query(
                `SELECT * FROM tblCrdBuysChecks ORDER BY BuyCheckId LIMIT ? OFFSET ?`,
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
                    const legacyBuyCheckId = normalizeInt(row.BuyCheckId);
                    const legacyBuyPayId = normalizeInt(row.BuyPayId);
                    const buyPayId = buyPayMap.get(legacyBuyPayId) || null;

                    const rowValues = [
                        createId(), tenantId, branchId,
                        legacyBuyCheckId,
                        buyPayId,
                        legacyBuyPayId,
                        row.CheckId ? String(row.CheckId).trim() : null,
                        row.CheckDate ? new Date(row.CheckDate) : null,
                        normalizeDecimal(row.CheckSum),
                        now, now
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
                    INSERT INTO "CrdBuysCheck"
                      ("id","tenantId","branchId","buyCheckId","buyPayId","legacyBuyPayId","checkId","checkDate","checkSum","createdAt","updatedAt")
                    VALUES ${values.join(",")}
                    ON CONFLICT ("tenantId","branchId","buyCheckId")
                    DO UPDATE SET
                      "buyPayId" = EXCLUDED."buyPayId",
                      "legacyBuyPayId" = EXCLUDED."legacyBuyPayId",
                      "checkId" = EXCLUDED."checkId",
                      "checkDate" = EXCLUDED."checkDate",
                      "checkSum" = EXCLUDED."checkSum",
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
    } finally {
        await mysql.end();
        await pg.end();
    }

    console.log("CrdBuysCheck migration completed:", total);


}

module.exports = migrateCrdBuysCheck;