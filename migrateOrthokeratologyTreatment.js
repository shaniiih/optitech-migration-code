const { v4: uuidv4 } = require("uuid");
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

  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value;
  }

  if (typeof value === "number") {
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? null : date;
  }

  const str = String(value).trim();
  if (!str) return null;
  if (/^0{4}-0{2}-0{2}/.test(str)) return null;
  const date = new Date(str);
  return Number.isNaN(date.getTime()) ? null : date;
}

function normalizeLegacyId(value) {
  if (value === null || value === undefined) return null;

  if (typeof value === "number" && Number.isFinite(value)) {
    return String(Math.trunc(value));
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

async function migrateOrthokeratologyTreatment(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastOrthokId = 0;
  let totalProcessed = 0;
  let skippedMissingCustomer = 0;
  let skippedMissingCheckDate = 0;
  let missingExaminerCount = 0;
  const missingCustomerSamples = new Set();

  try {
    const { rows: customerRows } = await pg.query(
      `SELECT id, "customerId" FROM "Customer" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const customerMap = new Map();
    for (const row of customerRows) {
      const candidates = legacyIdCandidates(row.customerId);
      for (const candidate of candidates) {
        if (!customerMap.has(candidate)) {
          customerMap.set(candidate, row.id);
        }
      }
    }

    const { rows: userRows } = await pg.query(
      `SELECT id, email FROM "User" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const userEmailMap = new Map();
    for (const row of userRows) {
      if (row.email) {
        userEmailMap.set(row.email.toLowerCase(), row.id);
      }
    }

    const [legacyUsers] = await mysql.query(
      `SELECT UserId, CellPhone, HomePhone, UserTz FROM tblUsers`
    );
    const legacyUserMap = new Map();
    for (const user of legacyUsers) {
      const candidates = legacyIdCandidates(user.UserId);
      for (const candidate of candidates) {
        if (!legacyUserMap.has(candidate)) {
          legacyUserMap.set(candidate, user);
        }
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT OrthokId, PerId, CheckDate, ReCheckDate, UserId,
                rHR, rHL, rVR, rVL, AxHR, AxHL, rTR, rTL, rNR, rNL, rIR, rIL, rSR, rSL,
                DiamR, DiamL, BC1R, BC1L, OZR, OZL, SphR, SphL,
                FCR, FCL, ACR, ACL, AC2R, AC2L, SBR, SBL, EGR, EGL,
                FCRCT, FCLCT, ACRCT, ACLCT, AC2RCT, AC2LCT, EGRCT, EGLCT, OZRCT, OZLCT,
                MaterR, MaterL, TintR, TintL, VAR, VAL, ClensTypeIdR, ClensTypeIdL,
                ClensManufIdR, ClensManufIdL, ClensBrandIdR, ClensBrandIdL,
                ComR, ComL, PICL, PICR, OrderId, CustId, PupDiam, CornDiam, EyeLidKey,
                CheckType, VA, EHR, EHL, EVR, EVL, EAR, EAL
           FROM tblCrdOrthoks
          WHERE OrthokId > ?
          ORDER BY OrthokId
          LIMIT ${WINDOW_SIZE}`,
        [lastOrthokId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const row of chunk) {
          const orthokId = asInteger(row.OrthokId);

          const customerId = legacyIdCandidates(row.PerId)
            .map((candidate) => customerMap.get(candidate))
            .find((value) => value) || null;
          if (!customerId) {
            skippedMissingCustomer += 1;
            const candidates = legacyIdCandidates(row.PerId);
            if (candidates.length && missingCustomerSamples.size < 10) {
              missingCustomerSamples.add(candidates[0]);
            }
            continue;
          }

          const checkDate = normalizeDate(row.CheckDate);
          if (!checkDate) {
            skippedMissingCheckDate += 1;
            continue;
          }

          const reCheckDate = normalizeDate(row.ReCheckDate);

          let examinerId = null;
          if (row.UserId !== null && row.UserId !== undefined) {
            const legacyUser = legacyIdCandidates(row.UserId)
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
              examinerId =
                candidates.map((candidate) => userEmailMap.get(candidate)).find((value) => value) ||
                null;
            }
            if (!examinerId) {
              missingExaminerCount += 1;
            }
          }

          const createdAt = checkDate;
          const updatedAt = checkDate;
          const id = `${tenantId}-orthok-treatment-${orthokId}`;

          const rowValues = [
            uuidv4(),
            tenantId,
            null,
            customerId,
            orthokId,
            checkDate,
            reCheckDate,
            examinerId,
            asNumber(row.rHR),
            asNumber(row.rHL),
            asNumber(row.AxHR),
            asNumber(row.AxHL),
            asNumber(row.rVR),
            asNumber(row.rVL),
            asNumber(row.rTR),
            asNumber(row.rTL),
            asNumber(row.rNR),
            asNumber(row.rNL),
            asNumber(row.rIR),
            asNumber(row.rIL),
            asNumber(row.rSR),
            asNumber(row.rSL),
            asNumber(row.DiamR),
            asNumber(row.DiamL),
            asNumber(row.BC1R),
            asNumber(row.BC1L),
            asNumber(row.OZR),
            asNumber(row.OZL),
            asNumber(row.SphR),
            asNumber(row.SphL),
            asNumber(row.FCR),
            asNumber(row.FCL),
            asNumber(row.ACR),
            asNumber(row.ACL),
            asNumber(row.AC2R),
            asNumber(row.AC2L),
            asNumber(row.SBR),
            asNumber(row.SBL),
            asNumber(row.EGR),
            asNumber(row.EGL),
            asNumber(row.FCRCT),
            asNumber(row.FCLCT),
            asNumber(row.ACRCT),
            asNumber(row.ACLCT),
            asNumber(row.AC2RCT),
            asNumber(row.AC2LCT),
            asNumber(row.EGRCT),
            asNumber(row.EGLCT),
            asNumber(row.OZRCT),
            asNumber(row.OZLCT),
            asInteger(row.MaterR),
            asInteger(row.MaterL),
            asInteger(row.TintR),
            asInteger(row.TintL),
            asNumber(row.VAR),
            asNumber(row.VAL),
            asNumber(row.VA),
            asInteger(row.ClensTypeIdR),
            asInteger(row.ClensTypeIdL),
            asInteger(row.ClensManufIdR),
            asInteger(row.ClensManufIdL),
            asInteger(row.ClensBrandIdR),
            asInteger(row.ClensBrandIdL),
            cleanText(row.ComR),
            cleanText(row.ComL),
            cleanText(row.PICL),
            cleanText(row.PICR),
            cleanText(row.OrderId),
            cleanText(row.CustId),
            cleanText(row.PupDiam),
            asNumber(row.CornDiam),
            asNumber(row.EyeLidKey),
            asInteger(row.CheckType),
            asNumber(row.EHR),
            asNumber(row.EHL),
            asNumber(row.EVR),
            asNumber(row.EVL),
            asNumber(row.EAR),
            asNumber(row.EAL),
            createdAt,
            updatedAt,
          ];
          if (rowValues.length !== 81) {
            throw new Error(`OrthokeratologyTreatment expected 81 values, got ${rowValues.length}`);
          }

          const offset = params.length;
          const placeholders = rowValues
            .map((_, index) => `$${offset + index + 1}`)
            .join(", ");
          values.push(`(${placeholders})`);
          params.push(...rowValues);
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          if (!params.length) {
            throw new Error("OrthokeratologyTreatment chunk generated empty params array");
          }
          await pg.query(
            `INSERT INTO "OrthokeratologyTreatment" (
              id,
              "tenantId",
              "branchId",
              "customerId",
              "orthokId",
              "checkDate",
              "reCheckDate",
              "examinerId",
              "keratometryHR",
              "keratometryHL",
              "axisHR",
              "axisHL",
              "keratometryVR",
              "keratometryVL",
              "keratometryTR",
              "keratometryTL",
              "keratometryNR",
              "keratometryNL",
              "keratometryIR",
              "keratometryIL",
              "keratometrySR",
              "keratometrySL",
              "diameterR",
              "diameterL",
              "baseCurve1R",
              "baseCurve1L",
              "opticalZoneR",
              "opticalZoneL",
              "sphereR",
              "sphereL",
              "fittingCurveR",
              "fittingCurveL",
              "alignmentCurveR",
              "alignmentCurveL",
              "alignment2CurveR",
              "alignment2CurveL",
              "secondaryR",
              "secondaryL",
              "edgeR",
              "edgeL",
              "fittingCurveThicknessR",
              "fittingCurveThicknessL",
              "alignmentCurveThicknessR",
              "alignmentCurveThicknessL",
              "alignment2CurveThicknessR",
              "alignment2CurveThicknessL",
              "edgeThicknessR",
              "edgeThicknessL",
              "opticalZoneThicknessR",
              "opticalZoneThicknessL",
              "materialR",
              "materialL",
              "tintR",
              "tintL",
              "visualAcuityR",
              "visualAcuityL",
              "visualAcuity",
              "lensTypeIdR",
              "lensTypeIdL",
              "manufacturerIdR",
              "manufacturerIdL",
              "brandIdR",
              "brandIdL",
              "commentR",
              "commentL",
              "pictureL",
              "pictureR",
              "orderId",
              "customerId2",
              "pupilDiameter",
              "cornealDiameter",
              "eyelidKey",
              "checkType",
              "eccentricityHR",
              "eccentricityHL",
              "eccentricityVR",
              "eccentricityVL",
              "eccentricityAR",
              "eccentricityAL",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id) DO UPDATE SET
              "customerId" = EXCLUDED."customerId",
              "orthokId" = EXCLUDED."orthokId",
              "checkDate" = EXCLUDED."checkDate",
              "reCheckDate" = EXCLUDED."reCheckDate",
              "examinerId" = EXCLUDED."examinerId",
              "keratometryHR" = EXCLUDED."keratometryHR",
              "keratometryHL" = EXCLUDED."keratometryHL",
              "axisHR" = EXCLUDED."axisHR",
              "axisHL" = EXCLUDED."axisHL",
              "keratometryVR" = EXCLUDED."keratometryVR",
              "keratometryVL" = EXCLUDED."keratometryVL",
              "keratometryTR" = EXCLUDED."keratometryTR",
              "keratometryTL" = EXCLUDED."keratometryTL",
              "keratometryNR" = EXCLUDED."keratometryNR",
              "keratometryNL" = EXCLUDED."keratometryNL",
              "keratometryIR" = EXCLUDED."keratometryIR",
              "keratometryIL" = EXCLUDED."keratometryIL",
              "keratometrySR" = EXCLUDED."keratometrySR",
              "keratometrySL" = EXCLUDED."keratometrySL",
              "diameterR" = EXCLUDED."diameterR",
              "diameterL" = EXCLUDED."diameterL",
              "baseCurve1R" = EXCLUDED."baseCurve1R",
              "baseCurve1L" = EXCLUDED."baseCurve1L",
              "opticalZoneR" = EXCLUDED."opticalZoneR",
              "opticalZoneL" = EXCLUDED."opticalZoneL",
              "sphereR" = EXCLUDED."sphereR",
              "sphereL" = EXCLUDED."sphereL",
              "fittingCurveR" = EXCLUDED."fittingCurveR",
              "fittingCurveL" = EXCLUDED."fittingCurveL",
              "alignmentCurveR" = EXCLUDED."alignmentCurveR",
              "alignmentCurveL" = EXCLUDED."alignmentCurveL",
              "alignment2CurveR" = EXCLUDED."alignment2CurveR",
              "alignment2CurveL" = EXCLUDED."alignment2CurveL",
              "secondaryR" = EXCLUDED."secondaryR",
              "secondaryL" = EXCLUDED."secondaryL",
              "edgeR" = EXCLUDED."edgeR",
              "edgeL" = EXCLUDED."edgeL",
              "fittingCurveThicknessR" = EXCLUDED."fittingCurveThicknessR",
              "fittingCurveThicknessL" = EXCLUDED."fittingCurveThicknessL",
              "alignmentCurveThicknessR" = EXCLUDED."alignmentCurveThicknessR",
              "alignmentCurveThicknessL" = EXCLUDED."alignmentCurveThicknessL",
              "alignment2CurveThicknessR" = EXCLUDED."alignment2CurveThicknessR",
              "alignment2CurveThicknessL" = EXCLUDED."alignment2CurveThicknessL",
              "edgeThicknessR" = EXCLUDED."edgeThicknessR",
              "edgeThicknessL" = EXCLUDED."edgeThicknessL",
              "opticalZoneThicknessR" = EXCLUDED."opticalZoneThicknessR",
              "opticalZoneThicknessL" = EXCLUDED."opticalZoneThicknessL",
              "materialR" = EXCLUDED."materialR",
              "materialL" = EXCLUDED."materialL",
              "tintR" = EXCLUDED."tintR",
              "tintL" = EXCLUDED."tintL",
              "visualAcuityR" = EXCLUDED."visualAcuityR",
              "visualAcuityL" = EXCLUDED."visualAcuityL",
              "visualAcuity" = EXCLUDED."visualAcuity",
              "lensTypeIdR" = EXCLUDED."lensTypeIdR",
              "lensTypeIdL" = EXCLUDED."lensTypeIdL",
              "manufacturerIdR" = EXCLUDED."manufacturerIdR",
              "manufacturerIdL" = EXCLUDED."manufacturerIdL",
              "brandIdR" = EXCLUDED."brandIdR",
              "brandIdL" = EXCLUDED."brandIdL",
              "commentR" = EXCLUDED."commentR",
              "commentL" = EXCLUDED."commentL",
              "pictureL" = EXCLUDED."pictureL",
              "pictureR" = EXCLUDED."pictureR",
              "orderId" = EXCLUDED."orderId",
              "customerId2" = EXCLUDED."customerId2",
              "pupilDiameter" = EXCLUDED."pupilDiameter",
              "cornealDiameter" = EXCLUDED."cornealDiameter",
              "eyelidKey" = EXCLUDED."eyelidKey",
              "checkType" = EXCLUDED."checkType",
              "eccentricityHR" = EXCLUDED."eccentricityHR",
              "eccentricityHL" = EXCLUDED."eccentricityHL",
              "eccentricityVR" = EXCLUDED."eccentricityVR",
              "eccentricityVL" = EXCLUDED."eccentricityVL",
              "eccentricityAR" = EXCLUDED."eccentricityAR",
              "eccentricityAL" = EXCLUDED."eccentricityAL",
              "updatedAt" = EXCLUDED."updatedAt"`
          , params);
          await pg.query("COMMIT");
          totalProcessed += values.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      lastOrthokId = rows[rows.length - 1].OrthokId;
      console.log(
        `OrthokeratologyTreatment migrated so far: ${totalProcessed} (lastOrthokId=${lastOrthokId})`
      );
    }

    console.log(
      `✅ OrthokeratologyTreatment migration completed. Total inserted/updated: ${totalProcessed}`
    );
    if (skippedMissingCustomer) {
      console.warn(
        `⚠️ Skipped ${skippedMissingCustomer} orthokeratology rows due to missing customers`
      );
      if (missingCustomerSamples.size) {
        console.warn(
          `⚠️ Example legacy customer IDs with no match: ${Array.from(
            missingCustomerSamples
          ).join(", ")}`
        );
      }
    }
    if (skippedMissingCheckDate) {
      console.warn(
        `⚠️ Skipped ${skippedMissingCheckDate} orthokeratology rows because CheckDate was invalid`
      );
    }
    if (missingExaminerCount) {
      console.warn(
        `⚠️ Could not resolve examiner for ${missingExaminerCount} orthokeratology rows`
      );
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateOrthokeratologyTreatment;
