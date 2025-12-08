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

function cleanText(value) {
    if (value === null || value === undefined) return null;
    const t = String(value).trim();
    return t.length ? t : null;
}

function toBoolean(value) {
    if (value === null || value === undefined) return null;
    if (typeof value === "boolean") return value;
    if (typeof value === "number") return value !== 0;
    const v = String(value).trim().toLowerCase();
    if (["1", "true", "t", "yes", "y"].includes(v)) return true;
    if (["0", "false", "f", "no", "n"].includes(v)) return false;
    return null;
}

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 500;

// MUST match model order
const COLUMNS = [
    "id", "tenantId", "branchId",
    "glassPId",
    "legacyPerId", "perId", "checkDate", "glassCheckRecordId",
    "legacyUseId", "useId",
    "legacySapakId", "sapakId",
    "legacyLensTypeId", "lensTypeId",
    "legacyLensMaterId", "lensMaterId",
    "legacyLensCharId", "lensCharId",
    "legacyTreatCharId", "treatCharId",
    "treatCharId1", "treatCharId2", "treatCharId3",
    "legacyEyeId", "eyeId",
    "diam", "com",
    "saleAdd",
    "createdAt", "updatedAt"
];

async function migrateCrdGlassCheckGlassP(tenantId = "tenant_1", branchId = null) {
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

        const useMap = await buildMap("CrdGlassUse", "glassUseId");
        const sapakMap = await buildMap("Sapak", "SapakID");
        const lensTypeMap = await buildMap("LnsType", "lensTypeId");
        const lensMaterMap = await buildMap("LnsMaterial", "lensMaterId");
        const lensCharMap = await buildMap("LnsChar", "lensCharId");
        const treatCharMap = await buildMap("LnsTreatChar", "treatCharId");
        const eyeMap = await buildMap("Eye", "eyeId");

        const perCheckMap = new Map();
        const { rows: crdRows } = await pg.query(
            `SELECT id, "perId", "checkDate", "legacyPerId"
             FROM "CrdGlassCheck"
             WHERE "tenantId" = $1 AND "branchId" = $2`,
            [tenantId, branchId]
        );

        for (const r of crdRows) {
            const legacy = normalizeInt(r.legacyPerId);
            const cd = r.checkDate ? r.checkDate.toISOString().split("T")[0] : null;
            if (legacy && cd) {
                perCheckMap.set(`${legacy}-${cd}`, {
                    perId: r.perId,
                    checkDate: r.checkDate,
                    glassCheckRecordId: r.id
                });
            }
        }

        while (true) {
            const [rows] = await mysql.query(
                `SELECT * FROM tblCrdGlassChecksGlassesP
                 ORDER BY PerId, CheckDate, GlassPId
                 LIMIT ? OFFSET ?`,
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
                    const cd = row.CheckDate ? new Date(row.CheckDate) : null;
                    const cdKey = `${legacyPerId}-${cd.toISOString().split("T")[0]}`;

                    const perCheck = perCheckMap.get(cdKey) || {};

                    const rowValues = [
                        createId(),
                        tenantId,
                        branchId,

                        normalizeInt(row.GlassPId),

                        legacyPerId,
                        perCheck.perId || null,
                        perCheck.checkDate || cd,
                        perCheck.glassCheckRecordId || null,

                        normalizeInt(row.UseId),
                        useMap.get(normalizeInt(row.UseId)) || null,

                        normalizeInt(row.SapakId),
                        sapakMap.get(normalizeInt(row.SapakId)) || null,

                        normalizeInt(row.LensTypeId),
                        lensTypeMap.get(normalizeInt(row.LensTypeId)) || null,

                        normalizeInt(row.LensMaterId),
                        lensMaterMap.get(normalizeInt(row.LensMaterId)) || null,

                        normalizeInt(row.LensCharId),
                        lensCharMap.get(normalizeInt(row.LensCharId)) || null,

                        normalizeInt(row.TreatCharId),
                        treatCharMap.get(normalizeInt(row.TreatCharId)) || null,

                        normalizeInt(row.TreatCharId1),
                        normalizeInt(row.TreatCharId2),
                        normalizeInt(row.TreatCharId3),

                        normalizeInt(row.EyeId),
                        eyeMap.get(normalizeInt(row.EyeId)) || null,

                        cleanText(row.Diam),
                        cleanText(row.Com),

                        toBoolean(row.SaleAdd) ?? false,

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
                        INSERT INTO "CrdGlassCheckGlassP"
                        (${COLUMNS.map(c => `"${c}"`).join(",")})
                        VALUES ${values.join(",")}
                        ON CONFLICT ("tenantId","branchId","legacyPerId","checkDate","glassPId")
                        DO UPDATE SET
                        ${COLUMNS
                            .filter(c =>
                                !["id", "tenantId", "legacyPerId", "glassPId", "createdAt"].includes(c)
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

    console.log("CrdGlassCheckGlassP migration completed:", total);
}

module.exports = migrateCrdGlassCheckGlassP;
