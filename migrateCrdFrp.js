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

function cleanText(value) {
    if (value === null || value === undefined) return null;
    const t = String(value).trim();
    return t.length ? t : null;
}

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

const COLUMNS = [
    "id", "tenantId", "branchId",
    "frpId",
    "legacyPerId", "perId",
    "frpDate",
    "totalFrp",
    "exchangeNum",
    "dayInterval",
    "supply",
    "comments",
    "saleAdd",
    "legacyClensBrandId", "clensBrandId",
    "createdAt", "updatedAt"
];

async function migrateCrdFrp(tenantId = "tenant_1", branchId = null) {
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

        const perMap = await buildMap("PerData", "perId");
        const brandMap = await buildMap("CrdClensBrand", "clensBrandId");

        while (true) {
            const [rows] = await mysql.query(
                `SELECT * FROM tblCrdFrps ORDER BY FrpId LIMIT ? OFFSET ?`,
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
                    const frpId = normalizeInt(row.FrpId);
                    const legacyPerId = normalizeInt(row.PerId);
                    const perId = perMap.get(legacyPerId) || null;

                    const legacyClensBrandId = normalizeInt(row.ClensBrandId);
                    const clensBrandId = brandMap.get(legacyClensBrandId) || null;

                    const rowValues = [
                        createId(),        
                        tenantId,
                        branchId,
                        frpId,       
                        legacyPerId,
                        perId,
                        row.FrpDate ? new Date(row.FrpDate) : null,
                        normalizeInt(row.TotalFrp),
                        normalizeInt(row.ExchangeNum),
                        normalizeInt(row.DayInterval),
                        toBoolean(row.Supply),
                        cleanText(row.Comments),
                        toBoolean(row.SaleAdd),
                        legacyClensBrandId,
                        clensBrandId,
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
                    INSERT INTO "CrdFrp"
                    (${COLUMNS.map(c => `"${c}"`).join(",")})
                    VALUES ${values.join(",")}
                    ON CONFLICT ("tenantId","branchId","frpId")
                    DO UPDATE SET
                    ${COLUMNS
                        .filter(c =>
                            !["id", "tenantId", "branchId", "frpId", "createdAt"].includes(c)
                        )
                        .map(c => `"${c}" = EXCLUDED."${c}"`)
                        .join(",")}
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

    console.log("CrdFrp migration completed:", total);
}

module.exports = migrateCrdFrp;
