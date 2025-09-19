const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function asNumber(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? value : null;
  }
  const str = String(value).trim().replace(/,/g, ".");
  if (!str) return null;
  const num = Number(str);
  return Number.isFinite(num) ? num : null;
}

function asInteger(value) {
  const num = asNumber(value);
  return num === null ? null : Math.round(num);
}

function normalizeDate(value) {
  if (value === null || value === undefined) return null;

  if (typeof value === "string") {
    const trimmed = value.trim();
    if (!trimmed) return null;
    if (/^0{4}-0{2}-0{2}/.test(trimmed)) return null;
    const parsed = new Date(trimmed);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value;
  }

  if (typeof value === "number") {
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  return null;
}

function normalizeLegacyId(value) {
  if (value === null || value === undefined) return null;

  if (typeof value === "number" && Number.isFinite(value)) {
    return String(value);
  }

  if (typeof value === "bigint") {
    return value.toString();
  }

  if (Buffer.isBuffer(value)) {
    return normalizeLegacyId(value.toString("utf8"));
  }

  const trimmed = String(value).trim();
  if (!trimmed) return null;

  if (/^[+-]?\d+(?:\.0+)?$/.test(trimmed)) {
    return String(parseInt(trimmed, 10));
  }

  return trimmed.toLowerCase();
}

function legacyIdCandidates(value) {
  const normalized = normalizeLegacyId(value);
  if (!normalized) return [];

  const candidates = new Set([normalized]);
  if (/\D/.test(normalized)) {
    const digitsOnly = normalized.replace(/\D+/g, "");
    if (digitsOnly) {
      const numericCandidate = normalizeLegacyId(digitsOnly);
      if (numericCandidate) {
        candidates.add(numericCandidate);
      }
    }
  }

  return Array.from(candidates);
}

function pruneObject(value) {
  if (value === null || value === undefined) return null;
  if (Array.isArray(value)) {
    const arr = value
      .map(pruneObject)
      .filter((entry) => entry !== null && !(typeof entry === "object" && !Array.isArray(entry) && Object.keys(entry).length === 0));
    return arr.length ? arr : null;
  }
  if (typeof value === "object") {
    const entries = Object.entries(value)
      .map(([key, val]) => [key, pruneObject(val)])
      .filter(([, val]) => val !== null && !(typeof val === "object" && !Array.isArray(val) && Object.keys(val).length === 0));
    if (!entries.length) return null;
    return Object.fromEntries(entries);
  }
  return value;
}

function toJsonText(obj) {
  const pruned = pruneObject(obj);
  if (!pruned) return null;
  return JSON.stringify(pruned);
}

async function migrateOrthokeratology(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  let skippedMissingCustomer = 0;
  let missingPrescriberCount = 0;
  const missingCustomerSamples = new Set();

  try {
    const { rows: customerRows } = await pg.query(
      `SELECT id, "customerId" FROM "Customer" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const customerMap = new Map();
    for (const c of customerRows) {
      for (const key of legacyIdCandidates(c.customerId)) {
        if (!customerMap.has(key)) {
          customerMap.set(key, c.id);
        }
      }
    }

    const { rows: userRows } = await pg.query(
      `SELECT id, email FROM "User" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const userEmailMap = new Map(
      userRows
        .filter((u) => u.email)
        .map((u) => [u.email.toLowerCase(), u.id])
    );

    const [legacyUsers] = await mysql.query(
      `SELECT UserId, CellPhone, HomePhone, UserTz FROM tblUsers`
    );
    const legacyUserMap = new Map();
    for (const user of legacyUsers) {
      for (const key of legacyIdCandidates(user.UserId)) {
        if (!legacyUserMap.has(key)) {
          legacyUserMap.set(key, user);
        }
      }
    }

    const [materialRows] = await mysql.query(
      `SELECT MaterId, MaterName FROM tblCrdClensChecksMater`
    );
    const materialMap = new Map();
    for (const row of materialRows) {
      const id = normalizeLegacyId(row.MaterId);
      const name = cleanText(row.MaterName);
      if (id && !materialMap.has(id)) {
        materialMap.set(id, name);
      }
    }

    const [tintRows] = await mysql.query(
      `SELECT TintId, TintName FROM tblCrdClensChecksTint`
    );
    const tintMap = new Map();
    for (const row of tintRows) {
      const id = normalizeLegacyId(row.TintId);
      const name = cleanText(row.TintName);
      if (id && !tintMap.has(id)) {
        tintMap.set(id, name);
      }
    }

    const [brandRows] = await mysql.query(
      `SELECT ClensBrandId, ClensBrandName FROM tblCrdClensBrands`
    );
    const brandMap = new Map();
    for (const row of brandRows) {
      const id = normalizeLegacyId(row.ClensBrandId);
      const name = cleanText(row.ClensBrandName);
      if (id && !brandMap.has(id)) {
        brandMap.set(id, name);
      }
    }

    const [typeRows] = await mysql.query(
      `SELECT ClensTypeId, ClensTypeName FROM tblCrdClensTypes`
    );
    const typeMap = new Map();
    for (const row of typeRows) {
      const id = normalizeLegacyId(row.ClensTypeId);
      const name = cleanText(row.ClensTypeName);
      if (id && !typeMap.has(id)) {
        typeMap.set(id, name);
      }
    }

    const [manufRows] = await mysql.query(
      `SELECT ClensManufId, ClensManufName FROM tblCrdClensManuf`
    );
    const manufacturerMap = new Map();
    for (const row of manufRows) {
      const id = normalizeLegacyId(row.ClensManufId);
      const name = cleanText(row.ClensManufName);
      if (id && !manufacturerMap.has(id)) {
        manufacturerMap.set(id, name);
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT OrthokId, PerId, CheckDate, ReCheckDate, UserId, rHR, rHL, rVR, rVL, AxHR, AxHL,
                rTR, rTL, rNR, rNL, rIR, rIL, rSR, rSL, DiamR, DiamL, BC1R, BC1L, OZR, OZL,
                SphR, SphL, FCR, FCL, ACR, ACL, AC2R, AC2L, SBR, SBL, EGR, EGL, FCRCT, FCLCT,
                ACRCT, ACLCT, AC2RCT, AC2LCT, EGRCT, EGLCT, MaterR, MaterL, TintR, TintL, VAR,
                VAL, ClensTypeIdR, ClensTypeIdL, ClensManufIdR, ClensManufIdL, ClensBrandIdR,
                ClensBrandIdL, ComR, ComL, PICL, PICR, OZRCT, OZLCT, OrderId, CustId, PupDiam,
                CornDiam, EyeLidKey, CheckType, VA, EHR, EHL, EVR, EVL, EAR, EAL
           FROM tblCrdOrthoks
          WHERE OrthokId > ?
          ORDER BY OrthokId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();

        for (const r of chunk) {
          const customerId = legacyIdCandidates(r.PerId)
            .map((candidate) => customerMap.get(candidate))
            .find((value) => value) || null;
          if (!customerId) {
            skippedMissingCustomer += 1;
            const legacyIds = legacyIdCandidates(r.PerId);
            if (legacyIds.length && missingCustomerSamples.size < 10) {
              missingCustomerSamples.add(legacyIds[0]);
            }
            continue;
          }

          let prescriberId = null;
          if (r.UserId !== null && r.UserId !== undefined) {
            const legacyUser = legacyIdCandidates(r.UserId)
              .map((candidate) => legacyUserMap.get(candidate))
              .find((value) => value) || null;
            if (legacyUser) {
              const candidates = [
                cleanText(legacyUser.CellPhone)
                  ? `${legacyUser.CellPhone}@legacy.local`.toLowerCase()
                  : null,
                cleanText(legacyUser.HomePhone)
                  ? `${legacyUser.HomePhone}@legacy.local`.toLowerCase()
                  : null,
                cleanText(legacyUser.UserTz)
                  ? `${legacyUser.UserTz}@legacy.local`.toLowerCase()
                  : null,
                `user-${legacyUser.UserId}@legacy.local`,
              ].filter(Boolean);
              prescriberId = candidates.map((c) => userEmailMap.get(c)).find((v) => v) || null;
            }
            if (!prescriberId) {
              missingPrescriberCount += 1;
            }
          }

          const startDate = normalizeDate(r.CheckDate) || now;

          const rightEyeData = toJsonText({
            keratometry: {
              horizontal: asNumber(r.rHR),
              vertical: asNumber(r.rVR),
              temporal: asNumber(r.rTR),
              nasal: asNumber(r.rNR),
              inferior: asNumber(r.rIR),
              superior: asNumber(r.rSR),
              axisHorizontal: asInteger(r.AxHR),
            },
            lens: {
              diameter: asNumber(r.DiamR),
              baseCurve: asNumber(r.BC1R),
              opticalZone: cleanText(r.OZR),
              sphere: asNumber(r.SphR),
              flatteningCurve: asNumber(r.FCR),
              alignmentCurve: asNumber(r.ACR),
              secondaryAlignmentCurve: asNumber(r.AC2R),
              peripheralCurve: asNumber(r.SBR),
              edgeLift: cleanText(r.EGR),
              opticalZoneThickness: asNumber(r.OZRCT),
              flatteningCurveThickness: asNumber(r.FCRCT),
              alignmentCurveThickness: asNumber(r.ACRCT),
              secondaryAlignmentCurveThickness: asNumber(r.AC2RCT),
              edgeLiftThickness: asNumber(r.EGRCT),
            },
            evaluation: {
              eccentricity: {
                horizontal: asNumber(r.EHR),
                vertical: asNumber(r.EVR),
                axial: asNumber(r.EAR),
              },
              pupilDiameter: cleanText(r.PupDiam),
              corneaDiameter: asNumber(r.CornDiam),
              eyelidKey: asNumber(r.EyeLidKey),
            },
            material: {
              id: asInteger(r.MaterR),
              name: materialMap.get(normalizeLegacyId(r.MaterR)) || null,
            },
            tint: {
              id: asInteger(r.TintR),
              name: tintMap.get(normalizeLegacyId(r.TintR)) || null,
            },
            contactLens: {
              typeId: asInteger(r.ClensTypeIdR),
              typeName: typeMap.get(normalizeLegacyId(r.ClensTypeIdR)) || null,
              manufacturerId: asInteger(r.ClensManufIdR),
              manufacturerName: manufacturerMap.get(normalizeLegacyId(r.ClensManufIdR)) || null,
              brandId: asInteger(r.ClensBrandIdR),
              brandName: brandMap.get(normalizeLegacyId(r.ClensBrandIdR)) || null,
            },
            comments: cleanText(r.ComR),
            photo: cleanText(r.PICR),
          });

          const leftEyeData = toJsonText({
            keratometry: {
              horizontal: asNumber(r.rHL),
              vertical: asNumber(r.rVL),
              temporal: asNumber(r.rTL),
              nasal: asNumber(r.rNL),
              inferior: asNumber(r.rIL),
              superior: asNumber(r.rSL),
              axisHorizontal: asInteger(r.AxHL),
            },
            lens: {
              diameter: asNumber(r.DiamL),
              baseCurve: asNumber(r.BC1L),
              opticalZone: cleanText(r.OZL),
              sphere: asNumber(r.SphL),
              flatteningCurve: asNumber(r.FCL),
              alignmentCurve: asNumber(r.ACL),
              secondaryAlignmentCurve: asNumber(r.AC2L),
              peripheralCurve: asNumber(r.SBL),
              edgeLift: cleanText(r.EGL),
              opticalZoneThickness: asNumber(r.OZLCT),
              flatteningCurveThickness: asNumber(r.FCLCT),
              alignmentCurveThickness: asNumber(r.ACLCT),
              secondaryAlignmentCurveThickness: asNumber(r.AC2LCT),
              edgeLiftThickness: asNumber(r.EGLCT),
            },
            evaluation: {
              eccentricity: {
                horizontal: asNumber(r.EHL),
                vertical: asNumber(r.EVL),
                axial: asNumber(r.EAL),
              },
              pupilDiameter: cleanText(r.PupDiam),
              corneaDiameter: asNumber(r.CornDiam),
              eyelidKey: asNumber(r.EyeLidKey),
            },
            material: {
              id: asInteger(r.MaterL),
              name: materialMap.get(normalizeLegacyId(r.MaterL)) || null,
            },
            tint: {
              id: asInteger(r.TintL),
              name: tintMap.get(normalizeLegacyId(r.TintL)) || null,
            },
            contactLens: {
              typeId: asInteger(r.ClensTypeIdL),
              typeName: typeMap.get(normalizeLegacyId(r.ClensTypeIdL)) || null,
              manufacturerId: asInteger(r.ClensManufIdL),
              manufacturerName: manufacturerMap.get(normalizeLegacyId(r.ClensManufIdL)) || null,
              brandId: asInteger(r.ClensBrandIdL),
              brandName: brandMap.get(normalizeLegacyId(r.ClensBrandIdL)) || null,
            },
            comments: cleanText(r.ComL),
            photo: cleanText(r.PICL),
          });

          const treatmentPlanParts = [];
          if (cleanText(r.OrderId)) treatmentPlanParts.push(`Order ID: ${cleanText(r.OrderId)}`);
          if (cleanText(r.CustId)) treatmentPlanParts.push(`Legacy customer ref: ${cleanText(r.CustId)}`);
          if (cleanText(r.CheckType)) treatmentPlanParts.push(`Check type: ${cleanText(r.CheckType)}`);
          const treatmentPlan = treatmentPlanParts.length ? treatmentPlanParts.join("\n") : null;

          const progressNotesParts = [];
          if (cleanText(r.VA)) progressNotesParts.push(`Visual acuity: ${cleanText(r.VA)}`);
          if (cleanText(r.VAR)) progressNotesParts.push(`Right VA: ${cleanText(r.VAR)}`);
          if (cleanText(r.VAL)) progressNotesParts.push(`Left VA: ${cleanText(r.VAL)}`);
          const progressNotes = progressNotesParts.length ? progressNotesParts.join("\n") : null;

          let status = "ACTIVE";
          const checkType = asInteger(r.CheckType);
          if (checkType !== null) {
            if (checkType === 0) status = "PLANNED";
            else if (checkType === 2) status = "COMPLETED";
          }

          const id = `${tenantId}-orthok-${r.OrthokId}`;
          const createdAt = startDate;
          const updatedAt = startDate;

          const columns = [
            id,
            tenantId,
            customerId,
            prescriberId,
            startDate,
            rightEyeData,
            leftEyeData,
            treatmentPlan,
            progressNotes,
            status,
            createdAt,
            updatedAt,
            null,
          ];

          const placeholderOffset = params.length;
          const placeholders = columns
            .map((_, idx) => `$${placeholderOffset + idx + 1}`)
            .join(", ");
          values.push(`(${placeholders})`);
          params.push(...columns);
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "Orthokeratology" (
              id, "tenantId", "customerId", "prescriberId", "startDate", "rightEyeData",
              "leftEyeData", "treatmentPlan", "progressNotes", status, "createdAt",
              "updatedAt", "branchId"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              "customerId" = EXCLUDED."customerId",
              "prescriberId" = EXCLUDED."prescriberId",
              "startDate" = EXCLUDED."startDate",
              "rightEyeData" = EXCLUDED."rightEyeData",
              "leftEyeData" = EXCLUDED."leftEyeData",
              "treatmentPlan" = EXCLUDED."treatmentPlan",
              "progressNotes" = EXCLUDED."progressNotes",
              status = EXCLUDED.status,
              "updatedAt" = EXCLUDED."updatedAt",
              "branchId" = EXCLUDED."branchId"
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }

        total += values.length;
      }

      lastId = rows[rows.length - 1].OrthokId;
      console.log(`Orthokeratology treatments migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ Orthokeratology migration completed. Total inserted/updated: ${total}`);
    if (skippedMissingCustomer) {
      console.warn(`⚠️ Skipped ${skippedMissingCustomer} orthokeratology records due to missing customers`);
      if (missingCustomerSamples.size) {
        console.warn(
          `⚠️ Example legacy customer IDs with no match: ${Array.from(missingCustomerSamples).join(", ")}`
        );
      }
    }
    if (missingPrescriberCount) {
      console.warn(`⚠️ Unable to match ${missingPrescriberCount} orthokeratology records to a prescriber`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateOrthokeratology;
