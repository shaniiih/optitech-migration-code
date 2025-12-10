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

const COLUMNS = [
  "id",
  "tenantId",
  "branchId",
  "glassId",
  "legacyPerId",
  "perId",
  "checkDate",
  "glassCheckRecordId",
  "legacyRoleId",
  "roleId",
  "legacyMaterId",
  "materId",
  "legacyBrandId",
  "brandId",
  "legacyCoatId",
  "coatId",
  "legacyModelId",
  "modelId",
  "legacyColorId",
  "colorId",
  "diam",
  "segment",
  "com",
  "saleAdd",
  "createdAt",
  "updatedAt",
];

async function migrateCrdGlassChecksGlass(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    // Build lookup maps for new FK ids
    const buildMap = async (table, legacyField) => {
      const map = new Map();
      const { rows } = await pg.query(
        `SELECT id, "${legacyField}" FROM "${table}" WHERE "tenantId" = $1 AND "branchId" = $2`,
        [tenantId, branchId]
      );
      for (const r of rows) {
        const legacy = normalizeInt(r[legacyField]);
        if (legacy !== null && !map.has(legacy)) {
          map.set(legacy, r.id);
        }
      }
      return map;
    };

    const roleMap   = await buildMap("CrdGlassRole", "GlassRoleId");
    const materMap  = await buildMap("CrdGlassMater", "glassMaterId");
    const brandMap  = await buildMap("CrdGlassBrand", "glassBrandId");
    const coatMap   = await buildMap("CrdGlassCoat", "glassCoatId");
    const modelMap  = await buildMap("CrdGlassModel", "glassModelId");
    const colorMap  = await buildMap("CrdGlassColor", "glassColorId");

    // Build lookup for CrdGlassCheck by (legacyPerId, checkDate)
    const perCheckMap = new Map();
    {
      const { rows } = await pg.query(
        `
        SELECT id, "legacyPerId", "perId", "checkDate"
        FROM "CrdGlassCheck"
        WHERE "tenantId" = $1
          AND "branchId" = $2
        `,
        [tenantId, branchId]
      );

      for (const r of rows) {
        const legacy = normalizeInt(r.legacyPerId);
        const cd = r.checkDate ? r.checkDate.toISOString().split("T")[0] : null;
        if (legacy !== null && cd) {
          perCheckMap.set(`${legacy}-${cd}`, {
            perId: r.perId,
            checkDate: r.checkDate,
            glassCheckRecordId: r.id,
          });
        }
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `
        SELECT PerId, CheckDate, GlassId,
               RoleId, MaterId, BrandId, CoatId, ModelId, ColorId,
               Diam, Segment, Com, SaleAdd
        FROM tblCrdGlassChecksGlasses
        ORDER BY PerId, CheckDate, GlassId
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
        let p = 1;

        for (const row of chunk) {
          const legacyPerId = normalizeInt(row.PerId);
          const cd = row.CheckDate ? new Date(row.CheckDate) : null;
          const cdKey = legacyPerId !== null && cd ? `${legacyPerId}-${cd.toISOString().split("T")[0]}` : null;
          const perCheck = cdKey ? perCheckMap.get(cdKey) : undefined;

          const rowValues = [
            createId(), // id
            tenantId,
            branchId,

            normalizeInt(row.GlassId), // glassId

            legacyPerId, // legacyPerId
            perCheck?.perId || null, // perId (new FK to PerData)
            perCheck?.checkDate || cd, // checkDate
            perCheck?.glassCheckRecordId || null, // glassCheckRecordId

            normalizeInt(row.RoleId), // legacyRoleId
            roleMap.get(normalizeInt(row.RoleId)) || null, // roleId (FK to CrdGlassRole.id)

            normalizeInt(row.MaterId), // legacyMaterId
            materMap.get(normalizeInt(row.MaterId)) || null, // materId

            normalizeInt(row.BrandId), // legacyBrandId
            brandMap.get(normalizeInt(row.BrandId)) || null, // brandId

            normalizeInt(row.CoatId), // legacyCoatId
            coatMap.get(normalizeInt(row.CoatId)) || null, // coatId

            normalizeInt(row.ModelId), // legacyModelId
            modelMap.get(normalizeInt(row.ModelId)) || null, // modelId

            normalizeInt(row.ColorId), // legacyColorId
            colorMap.get(normalizeInt(row.ColorId)) || null, // colorId

            cleanText(row.Diam),
            normalizeInt(row.Segment),
            cleanText(row.Com),
            toBoolean(row.SaleAdd) ?? false,

            now,
            now,
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
            INSERT INTO "CrdGlassChecksGlass" (
              ${COLUMNS.map((c) => `"${c}"`).join(",")}
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId","branchId","glassId","legacyPerId","checkDate")
            DO UPDATE SET
              "diam" = EXCLUDED."diam",
              "segment" = EXCLUDED."segment",
              "com" = EXCLUDED."com",
              "saleAdd" = EXCLUDED."saleAdd",
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
          total += chunk.length;
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }
      }

      offset += rows.length;
      console.log(`CrdGlassChecksGlass migrated: ${total} (offset=${offset})`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateCrdGlassChecksGlass;
