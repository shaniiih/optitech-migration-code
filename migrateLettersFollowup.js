const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

function normalizeInt(value) {
    if (value === null || value === undefined) return null;
    const n = Number(value);
    return Number.isFinite(n) ? Math.trunc(n) : null;
}



const WINDOW_SIZE = 5000;
const BATCH_SIZE = 500;

const COLUMNS = [
    "id", "tenantId", "branchId", "followUpId", "legacyPerId", "perId",
    "letterId", "letterDate", "serviceType", "createdAt", "updatedAt"
];

async function migrateLettersFollowup(tenantId = "tenant_1", branchId = null) {
    const mysql = await getMySQLConnection();
    const pg = await getPostgresConnection();
    let offset = 0;
    let total = 0;

    try {
        while (true) {
            const [rows] = await mysql.query(
                `SELECT * FROM tblLettersFollowup ORDER BY FollowUpId LIMIT ? OFFSET ?`,
                [WINDOW_SIZE, offset]
            );
            if (!rows.length) break;

            for (let i = 0; i < rows.length; i += BATCH_SIZE) {
                const chunk = rows.slice(i, i + BATCH_SIZE);

                const values = [];
                const params = [];
                let p = 1;
                const now = new Date();

                for (const row of chunk) {
                    const legacyPerId = normalizeInt(row.PerId);
                     const perId = perMap.get(legacyPerId) || null;
                    const rowValues = [
                        createId(),
                        tenantId,
                        branchId,
                        normalizeInt(row.FollowUpId),
                        legacyPerId,
                        perId, 
                        normalizeInt(row.LetterId),
                        row.LetterDate ? new Date(row.LetterDate) : null,
                        normalizeInt(row.ServiceType),
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
                    INSERT INTO "LettersFollowup" (${COLUMNS.map(c => `"${c}"`).join(",")})
                    VALUES ${values.join(",")}
                    ON CONFLICT ("tenantId","branchId","followUpId")
                    DO UPDATE SET
                      ${COLUMNS.filter(c => !["id", "tenantId", "branchId", "followUpId", "createdAt"].includes(c))
                            .map(c => `"${c}" = EXCLUDED."${c}"`).join(",")}
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

    console.log("LettersFollowup migration completed:", total);


}

module.exports = migrateLettersFollowup;