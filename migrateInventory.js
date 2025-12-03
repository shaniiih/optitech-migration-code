const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");
const { createId } = require("@paralleldrive/cuid2");

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

async function migrateInventory(tenantId = "tenant_1", branchId = null) {
    const mysql = await getMySQLConnection();
    const pg = await getPostgresConnection();

    let offset = 0;
    let total = 0;

    try {
        const userMap = new Map();
        const moveTypeMap = new Map();
        const movePropMap = new Map();
        const sapakMap = new Map();
        const branchNewTableRefMap = new Map();
        {
            const { rows } = await pg.query(
                `SELECT id, "branchId" FROM "Branch"
                 WHERE "tenantId" = $1`,
                [tenantId]
            );

            for (const row of rows) {
                const legacyId = normalizeInt(row.branchId);
                if (legacyId !== null && !branchNewTableRefMap.has(legacyId)) {
                    branchNewTableRefMap.set(legacyId, row.id);
                }
            }
        }
        {
            const { rows } = await pg.query(
                `SELECT id, "userId" FROM "User"
                 WHERE "tenantId" = $1 AND "branchId" = $2`,
                [tenantId, branchId]
            );

            for (const row of rows) {
                const legacyId = normalizeInt(row.userId);
                if (legacyId !== null && !userMap.has(legacyId)) {
                    userMap.set(legacyId, row.id);
                }
            }
        }

        {
            const { rows } = await pg.query(
                `SELECT id, "invMoveTypeId" FROM "InvMoveType"
                 WHERE "tenantId" = $1 AND "branchId" = $2`,
                [tenantId, branchId]
            );
            for (const row of rows) {
                const legacyId = normalizeInt(row.invMoveTypeId);
                if (legacyId !== null && !moveTypeMap.has(legacyId)) {
                    moveTypeMap.set(legacyId, row.id);
                }
            }
        }

        {
            const { rows } = await pg.query(
                `SELECT id, "InvMovePropId" FROM "InvMoveProp"
                 WHERE "tenantId" = $1 AND "branchId" = $2`,
                [tenantId, branchId]
            );
            for (const row of rows) {
                const legacyId = normalizeInt(row.InvMovePropId);
                if (legacyId !== null && !movePropMap.has(legacyId)) {
                    movePropMap.set(legacyId, row.id);
                }
            }
        }

        {
            const { rows } = await pg.query(
                `SELECT id, "sapakId" FROM "CrdBuysWorkSapak"
                 WHERE "tenantId" = $1 AND "branchId" = $2`,
                [tenantId, branchId]
            );
            for (const row of rows) {
                const legacyId = normalizeInt(row.sapakId);
                if (legacyId !== null && !sapakMap.has(legacyId)) {
                    sapakMap.set(legacyId, row.id);
                }
            }
        }

        while (true) {
            const [rows] = await mysql.query(
                `
                SELECT 
                    InvId, InvDate, UserId, InvoiceId, InvInDate, 
                    PInvoiceId, InvMoveTypeId, InvMovePropId, InvSapakId,
                    BranchId, Com, SrcInvId
                FROM tblInventory
                ORDER BY InvId
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
                    const invId = normalizeInt(row.InvId);
                    const legacyUserId = normalizeInt(row.UserId);

                    const invDate = row.InvDate ? new Date(row.InvDate) : null;
                    const invInDate = row.InvInDate ? new Date(row.InvInDate) : null;

                    const legacyInvMoveTypeId = normalizeInt(row.InvMoveTypeId);
                    const legacyInvMovePropId = normalizeInt(row.InvMovePropId);
                    const legacyInvSapakId = normalizeInt(row.InvSapakId);
                    const legacyBranchId = normalizeInt(row.BranchId);
                    const srcInvId = normalizeInt(row.SrcInvId);

                    const userId = userMap.get(legacyUserId) || null;
                    const invMoveTypeId = moveTypeMap.get(legacyInvMoveTypeId) || null;
                    const invMovePropId = movePropMap.get(legacyInvMovePropId) || null;
                    const invSapakId = sapakMap.get(legacyInvSapakId) || null;
                    const legacyBranchNewRefId = branchNewTableRefMap.get(legacyBranchId) || null;


                    const base = params.length;

                    values.push(
                        `(
                            $${base + 1},  $${base + 2},  $${base + 3},  $${base + 4}, 
                            $${base + 5},  $${base + 6},  $${base + 7},  $${base + 8},
                            $${base + 9},  $${base + 10}, $${base + 11}, $${base + 12},
                            $${base + 13}, $${base + 14}, $${base + 15}, $${base + 16},
                            $${base + 17}, $${base + 18}, $${base + 19}, $${base + 20},
                            $${base + 21}, $${base + 22}
                        )`
                    );

                    params.push(
                        createId(),
                        tenantId,
                        branchId,
                        invId,
                        legacyUserId,
                        userId,
                        invDate,
                        row.InvoiceId,
                        invInDate,
                        row.PInvoiceId,
                        legacyInvMoveTypeId,
                        legacyInvMovePropId,
                        legacyInvSapakId,
                        legacyBranchId,
                        legacyBranchNewRefId,
                        invMoveTypeId,
                        invMovePropId,
                        invSapakId,
                        row.Com || null,
                        srcInvId,
                        now,
                        now

                    );
                }

                if (!values.length) continue;
                await pg.query("BEGIN");
                try {
                    await pg.query(
                        `
                        INSERT INTO "Inventory" (
                            id,
                            "tenantId",
                            "branchId",
                            "invId",
                            "legacyUserId",
                            "userId",
                            "invDate",
                            "invoiceId",
                            "invInDate",
                            "pInvoiceId",
                            "legacyInvMoveTypeId",
                            "legacyInvMovePropId",
                            "legacyInvSapakId",
                            "legacyBranchId",
                            "legacyBranchNewRefId",
                            "invMoveTypeId",
                            "invMovePropId",
                            "invSapakId",
                            "com",
                            "srcInvId",
                            "createdAt",
                            "updatedAt"
                        )
                        VALUES ${values.join(",")}
                        ON CONFLICT ("tenantId", "branchId", "invId")
                        DO UPDATE SET
                            "legacyUserId" = EXCLUDED."legacyUserId",
                            "userId" = EXCLUDED."userId",
                            "invDate" = EXCLUDED."invDate",
                            "invoiceId" = EXCLUDED."invoiceId",
                            "invInDate" = EXCLUDED."invInDate",
                            "pInvoiceId" = EXCLUDED."pInvoiceId",
                            "legacyInvMoveTypeId" = EXCLUDED."legacyInvMoveTypeId",
                            "legacyInvMovePropId" = EXCLUDED."legacyInvMovePropId",
                            "legacyInvSapakId" = EXCLUDED."legacyInvSapakId",
                            "legacyBranchId" = EXCLUDED."legacyBranchId",
                            "legacyBranchNewRefId" = EXCLUDED."legacyBranchNewRefId",
                            "invMoveTypeId" = EXCLUDED."invMoveTypeId",
                            "invMovePropId" = EXCLUDED."invMovePropId",
                            "invSapakId" = EXCLUDED."invSapakId",
                            "com" = EXCLUDED."com",
                            "srcInvId" = EXCLUDED."srcInvId",
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
            console.log(`Inventory migrated so far: ${total} (offset=${offset})`);
        }

        console.log(`Inventory migration completed. Total inserted/updated: ${total}`);
    } finally {
        await mysql.end();
        await pg.end();
    }
}

module.exports = migrateInventory;
