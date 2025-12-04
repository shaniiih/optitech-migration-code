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

async function migrateCrdClinicCheck(tenantId = "tenant_1", branchId = null) {
    const mysql = await getMySQLConnection();
    const pg = await getPostgresConnection();

    let offset = 0;
    let total = 0;

    try {
        const userMap = new Map();
        const perMap = new Map();

        const { rows: userRows } = await pg.query(
            `SELECT id, "userId" FROM "User" WHERE "tenantId" = $1 AND "branchId" = $2`,
            [tenantId, branchId]
        );
        for (const row of userRows) {
            const legacy = normalizeInt(row.userId);
            if (legacy !== null) userMap.set(legacy, row.id);
        }


        const { rows: perRows } = await pg.query(
            `SELECT id, "perId" FROM "PerData" WHERE "tenantId" = $1 AND "branchId" = $2`,
            [tenantId, branchId]
        );
        for (const row of perRows) {
            const legacy = normalizeInt(row.perId);
            if (legacy !== null) perMap.set(legacy, row.id);
        }

        while (true) {
            const [rows] = await mysql.query(
                `
                SELECT *
                FROM tblCrdClinicChecks
                ORDER BY ClinicCheckId
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
                    const legacyClinicCheckId = normalizeInt(row.ClinicCheckId);
                    const legacyUserId = normalizeInt(row.UserId);
                    const legacyPerId = normalizeInt(row.PerId);

                    const userId = userMap.get(legacyUserId) || null;
                    const perId = perMap.get(legacyPerId) || null;

                    const base = params.length;
                    const ynCount = 58;
                    const ynFields = [];
                    for (let j = 1; j <= ynCount; j++) {
                        ynFields.push(toBoolean(row[`YN${j}`]) ?? null);
                    }

                    const columns = [
                        "id", "tenantId", "branchId", "clinicCheckId",
                        "legacyPerId", "perId", "legacyUserId", "userId",
                        "checkDate", "reCheckDate", "glassCheckDate",
                        ...Array.from({ length: ynCount }, (_, i) => `yn${i + 1}`),
                        "meds", "medsEye", "prevTreat", "com",
                        "other1", "other2", "other3", "other4",
                        "eyeLidR", "eyeLidL", "tearWayR", "tearWayL",
                        "choroidR", "choroidL", "limitR", "limitL",
                        "cornR", "cornL", "chamberR", "chamberL",
                        "angleR", "angleL", "iopR", "iopL",
                        "irisR", "irisL", "pupilR", "pupilL",
                        "lensR", "lensL", "enamelR", "enamelL",
                        "diskR", "diskL", "cdavR", "cdavL",
                        "maculaR", "maculaL", "perimeterR", "perimeterL",
                        "amslaR", "amslaL", "vFieldR", "vFieldL",
                        "pic3", "pic4", "csr", "csl",
                        "createdAt", "updatedAt"
                    ];
                    values.push(`(${columns.map((_, idx) => `$${base + idx + 1}`).join(",")})`);


                    params.push(
                        createId(),
                        tenantId,
                        branchId,
                        legacyClinicCheckId,
                        legacyPerId,
                        perId,
                        legacyUserId,
                        userId,
                        row.CheckDate ? new Date(row.CheckDate) : null,
                        row.ReCheckDate ? new Date(row.ReCheckDate) : null,
                        row.GlassCheckDate ? new Date(row.GlassCheckDate) : null,
                        ...ynFields,
                        row.Meds || null,
                        row.MedsEye || null,
                        row.PrevTreat || null,
                        row.Com || null,
                        row.Other1 || null,
                        row.Other2 || null,
                        row.Other3 || null,
                        row.Other4 || null,
                        row.EyeLidR || null,
                        row.EyeLidL || null,
                        row.TearWayR || null,
                        row.TearWayL || null,
                        row.ChoroidR || null,
                        row.ChoroidL || null,
                        row.LimitR || null,
                        row.LimitL || null,
                        row.CornR || null,
                        row.CornL || null,
                        row.ChamberR || null,
                        row.ChamberL || null,
                        row.AngleR || null,
                        row.AngleL || null,
                        row.IOPR || null,
                        row.IOPL || null,
                        row.IrisR || null,
                        row.IrisL || null,
                        row.PupilR || null,
                        row.PupilL || null,
                        row.LensR || null,
                        row.LensL || null,
                        row.EnamelR || null,
                        row.EnamelL || null,
                        row.DiskR || null,
                        row.DiskL || null,
                        row.CdavR || null,
                        row.CdavL || null,
                        row.MaculaR || null,
                        row.MaculaL || null,
                        row.PerimeterR || null,
                        row.PerimeterL || null,
                        row.AmslaR || null,
                        row.AmslaL || null,
                        row.VFieldR || null,
                        row.VFieldL || null,
                        row.Pic3 || null,
                        row.Pic4 || null,
                        row.CSR || null,
                        row.CSL || null,
                        now,
                        now
                    );
                }

                if (!values.length) continue;

                await pg.query("BEGIN");
                try {
                    await pg.query(
                        `
                        INSERT INTO "CrdClinicCheck" (
                            id, "tenantId", "branchId", "clinicCheckId",
                            "legacyPerId", "perId", "legacyUserId", "userId",
                            "checkDate", "reCheckDate", "glassCheckDate",
                            ${Array.from({ length: 58 }, (_, i) => `"yn${i + 1}"`).join(",")},
                            "meds","medsEye","prevTreat","com",
                            "other1","other2","other3","other4",
                            "eyeLidR","eyeLidL","tearWayR","tearWayL",
                            "choroidR","choroidL","limitR","limitL",
                            "cornR","cornL","chamberR","chamberL",
                            "angleR","angleL","iopR","iopL",
                            "irisR","irisL","pupilR","pupilL",
                            "lensR","lensL","enamelR","enamelL",
                            "diskR","diskL","cdavR","cdavL",
                            "maculaR","maculaL","perimeterR","perimeterL",
                            "amslaR","amslaL","vFieldR","vFieldL",
                            "pic3","pic4","csr","csl",
                            "createdAt","updatedAt"
                        )
                        VALUES ${values.join(",")}
                        ON CONFLICT ("tenantId", "branchId", "clinicCheckId")
                        DO UPDATE SET
                            "legacyPerId" = EXCLUDED."legacyPerId",
                            "perId" = EXCLUDED."perId",
                            "legacyUserId" = EXCLUDED."legacyUserId",
                            "userId" = EXCLUDED."userId",
                            "checkDate" = EXCLUDED."checkDate",
                            "reCheckDate" = EXCLUDED."reCheckDate",
                            "glassCheckDate" = EXCLUDED."glassCheckDate",
                            ${Array.from({ length: 58 }, (_, i) => `"yn${i + 1}" = EXCLUDED."yn${i + 1}"`).join(",")},
                            "meds" = EXCLUDED."meds",
                            "medsEye" = EXCLUDED."medsEye",
                            "prevTreat" = EXCLUDED."prevTreat",
                            "com" = EXCLUDED."com",
                            "other1" = EXCLUDED."other1",
                            "other2" = EXCLUDED."other2",
                            "other3" = EXCLUDED."other3",
                            "other4" = EXCLUDED."other4",
                            "eyeLidR" = EXCLUDED."eyeLidR",
                            "eyeLidL" = EXCLUDED."eyeLidL",
                            "tearWayR" = EXCLUDED."tearWayR",
                            "tearWayL" = EXCLUDED."tearWayL",
                            "choroidR" = EXCLUDED."choroidR",
                            "choroidL" = EXCLUDED."choroidL",
                            "limitR" = EXCLUDED."limitR",
                            "limitL" = EXCLUDED."limitL",
                            "cornR" = EXCLUDED."cornR",
                            "cornL" = EXCLUDED."cornL",
                            "chamberR" = EXCLUDED."chamberR",
                            "chamberL" = EXCLUDED."chamberL",
                            "angleR" = EXCLUDED."angleR",
                            "angleL" = EXCLUDED."angleL",
                            "iopR" = EXCLUDED."iopR",
                            "iopL" = EXCLUDED."iopL",
                            "irisR" = EXCLUDED."irisR",
                            "irisL" = EXCLUDED."irisL",
                            "pupilR" = EXCLUDED."pupilR",
                            "pupilL" = EXCLUDED."pupilL",
                            "lensR" = EXCLUDED."lensR",
                            "lensL" = EXCLUDED."lensL",
                            "enamelR" = EXCLUDED."enamelR",
                            "enamelL" = EXCLUDED."enamelL",
                            "diskR" = EXCLUDED."diskR",
                            "diskL" = EXCLUDED."diskL",
                            "cdavR" = EXCLUDED."cdavR",
                            "cdavL" = EXCLUDED."cdavL",
                            "maculaR" = EXCLUDED."maculaR",
                            "maculaL" = EXCLUDED."maculaL",
                            "perimeterR" = EXCLUDED."perimeterR",
                            "perimeterL" = EXCLUDED."perimeterL",
                            "amslaR" = EXCLUDED."amslaR",
                            "amslaL" = EXCLUDED."amslaL",
                            "vFieldR" = EXCLUDED."vFieldR",
                            "vFieldL" = EXCLUDED."vFieldL",
                            "pic3" = EXCLUDED."pic3",
                            "pic4" = EXCLUDED."pic4",
                            "csr" = EXCLUDED."csr",
                            "csl" = EXCLUDED."csl",
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
    console.log("CrdClinicCheck migration completed:", total);

}

module.exports = migrateCrdClinicCheck;
