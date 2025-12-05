const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");
const { ensureTenantId } = require("./tenantUtils");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const s = String(value).trim();
  return s.length ? s : null;
}

function asInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? Math.trunc(value) : null;
  }
  const s = String(value).trim();
  if (!s) return null;
  const n = Number(s);
  return Number.isFinite(n) ? Math.trunc(n) : null;
}

function asBool(value) {
  if (value === null || value === undefined) return false;
  if (value === true || value === false) return value;
  if (typeof value === "number") return value !== 0;
  const s = String(value).trim().toLowerCase();
  if (!s) return false;
  return s === "1" || s === "true" || s === "yes";
}

function asDate(value) {
  if (value === null || value === undefined) return null;
  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value;
  }
  const s = cleanText(value);
  if (!s) return null;
  const d = new Date(s);
  return Number.isNaN(d.getTime()) ? null : d;
}

async function migrateClndrTasks(tenantId = "tenant_1", branchId) {
  tenantId = ensureTenantId(tenantId, "tenant_1");
  if (!branchId) {
    throw new Error("migrateClndrTasks requires a non-null BRANCH_ID");
  }

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    // Map legacy UserId -> User.id for this tenant+branch
    const { rows: userRows } = await pg.query(
      `SELECT id, "userId"
         FROM "User"
        WHERE "tenantId" = $1 AND "branchId" = $2`,
      [tenantId, branchId]
    );
    const userMap = new Map();
    for (const row of userRows) {
      const legacyUserId = asInt(row.userId);
      if (legacyUserId === null) continue;
      if (!userMap.has(legacyUserId)) {
        userMap.set(legacyUserId, row.id);
      }
    }

    // Map legacy PriorityId -> ClndrTasksPriority.id for this tenant+branch
    const { rows: priorityRows } = await pg.query(
      `SELECT id, "priorityId"
         FROM "ClndrTasksPriority"
        WHERE "tenantId" = $1 AND "branchId" = $2`,
      [tenantId, branchId]
    );
    const priorityMap = new Map();
    for (const row of priorityRows) {
      const legacyPriorityId = asInt(row.priorityId);
      if (legacyPriorityId === null) continue;
      if (!priorityMap.has(legacyPriorityId)) {
        priorityMap.set(legacyPriorityId, row.id);
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT UserId, TaskId, PriorityId, TaskDesc, Done, TaskDate
           FROM tblClndrTasks
          ORDER BY UserId, TaskId
          LIMIT ${WINDOW_SIZE}
          OFFSET ${offset}`
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const r of chunk) {
          const legacyUserId = asInt(r.UserId);
          const legacyTaskId = asInt(r.TaskId);
          if (legacyTaskId === null) {
            continue;
          }

          const userId =
            legacyUserId !== null ? userMap.get(legacyUserId) || null : null;

          const legacyPriorityId = asInt(r.PriorityId);
          const priorityId =
            legacyPriorityId !== null
              ? priorityMap.get(legacyPriorityId) || null
              : null;

          const taskDesc = cleanText(r.TaskDesc);
          const done = asBool(r.Done);
          const taskDate = asDate(r.TaskDate);

          const createdAt = new Date();
          const updatedAt = createdAt;

          const base = params.length;
          values.push(
            `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6}, $${base + 7}, $${base + 8}, $${base + 9}, $${base + 10}, $${base + 11}, $${base + 12}, $${base + 13})`
          );

          params.push(
            createId(),        // id
            tenantId,          // tenantId
            branchId,          // branchId
            legacyUserId,      // legacyUserId
            userId,            // userId
            legacyTaskId,      // legacyTaskId
            legacyPriorityId,  // legacyPriorityId
            priorityId,        // priorityId (nullable, FK)
            taskDesc,          // taskDesc
            done,              // done
            taskDate,          // taskDate
            createdAt,         // createdAt
            updatedAt          // updatedAt
          );
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "ClndrTask" (
              id,
              "tenantId",
              "branchId",
              "legacyUserId",
              "userId",
              "legacyTaskId",
              "legacyPriorityId",
              "priorityId",
              "taskDesc",
              "done",
              "taskDate",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "legacyUserId", "legacyTaskId")
            DO UPDATE SET
              "taskDesc"         = EXCLUDED."taskDesc",
              "done"             = EXCLUDED."done",
              "taskDate"         = EXCLUDED."taskDate",
              "updatedAt"        = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (e) {
          await pg.query("ROLLBACK");
          throw e;
        }
      }

      offset += rows.length;
      console.log(`ClndrTask migrated: ${total} (offset=${offset})`);
    }

    console.log(`✅ ClndrTask migration completed. Total inserted/updated: ${total}`);
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateClndrTasks;
