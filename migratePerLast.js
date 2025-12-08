const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 500;

function normalizeInt(value) {
    if (value === null || value === undefined) return null;
    const parsed = Number(value);
    return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

async function migratePerLast(tenantId = "tenant_1", branchId = null) {
    const mysql = await getMySQLConnection();
    const pg = await getPostgresConnection();

    let offset = 0;
    let total = 0;

    try {
        while (true) {
            const [rows] = await mysql.query(
                `SELECT * FROM tblPerLast ORDER BY PerNum LIMIT ? OFFSET ?`,
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
                    const perNum = normalizeInt(row.PerNum);
                    const legacyPerId = normalizeInt(row.PerId);
                     const perId = perMap.get(legacyPerId) || null;

                    const rowValues = [
                        createId(), tenantId, branchId,
                        perNum,
                        perId,           
                        legacyPerId,
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
                    INSERT INTO "PerLast"
                    ("id", "tenantId", "branchId", "perNum", "perId", "legacyPerId", "createdAt", "updatedAt")
                    VALUES ${values.join(",")}
                    ON CONFLICT ("tenantId","branchId","perNum")
                    DO UPDATE SET
                    "legacyPerId" = EXCLUDED."legacyPerId",
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

    console.log("PerLast migration completed:", total);

}

module.exports = migratePerLast;