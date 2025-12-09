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


const WINDOW_SIZE = 5000;
const BATCH_SIZE = 500;

async function migrateLettersFollowup(tenantId = "tenant_1", branchId = null) {
    const mysql = await getMySQLConnection();
    const pg = await getPostgresConnection();
    let offset = 0;
    let total = 0;

    try {
        const buildMap = async (table, legacyColumn) => {
            const map = new Map();
            const { rows } = await pg.query(
                `SELECT id, "${legacyColumn}" 
                 FROM "${table}" 
                 WHERE "tenantId" = $1 
                 AND ("branchId" = $2 OR $2 IS NULL)`,
                [tenantId, branchId]
            );
            for (const r of rows) {
                const legacy = normalizeInt(r[legacyColumn]);
                if (legacy !== null) map.set(legacy, r.id);
            }
            return map;
        };

        const perMap = await buildMap("PerData", "perId");
        const serviceTypeMap = await buildMap("ServiceType", "serviceId");

        while (true) {
            const [rows] = await mysql.query(
                `SELECT * FROM tblLettersFollowup ORDER BY FollowUpId LIMIT ? OFFSET ?`,
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

                    const legacyServiceType = normalizeInt(row.ServiceType);
                    const serviceType =
                        legacyServiceType != null ? serviceTypeMap.get(legacyServiceType) || null : null;

                    const rowValues = [
                        createId(),
                        tenantId,
                        branchId,
                        normalizeInt(row.FollowUpId),
                        perId,
                        legacyPerId,
                        normalizeInt(row.LetterId),
                        row.LetterDate ? new Date(row.LetterDate) : null,
                        serviceType,       
                        legacyServiceType,   
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
                        INSERT INTO "LettersFollowup"
                        ("id","tenantId","branchId","followUpId","perId","legacyPerId",
                         "letterId","letterDate","serviceType","legacyServiceType",
                         "createdAt","updatedAt")
                        VALUES ${values.join(",")}
                        ON CONFLICT ("tenantId","branchId","followUpId")
                        DO UPDATE SET
                            "perId"              = EXCLUDED."perId",
                            "legacyPerId"        = EXCLUDED."legacyPerId",
                            "letterId"           = EXCLUDED."letterId",
                            "letterDate"         = EXCLUDED."letterDate",
                            "serviceType"        = EXCLUDED."serviceType",
                            "legacyServiceType"  = EXCLUDED."legacyServiceType",
                            "updatedAt"          = EXCLUDED."updatedAt"
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

module.exports =  migrateLettersFollowup ;
