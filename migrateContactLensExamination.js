const { v4: uuidv4 } = require("uuid");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");
const { ensureTenantId } = require("./tenantUtils");

const WINDOW_SIZE = 5000;
// Keep batches modest because each row expands to many columns; Postgres limits
// the number of bind parameters per statement (int2). 400 * 73 columns ≈ 29k < 65k.
const BATCH_SIZE = 400;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "string") {
    const trimmed = value.trim();
    return trimmed.length ? trimmed : null;
  }
  if (Buffer.isBuffer(value)) {
    return cleanText(value.toString("utf8"));
  }
  return cleanText(String(value));
}

function asNumber(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? value : null;
  }
  if (typeof value === "bigint") {
    return Number(value);
  }
  const str = String(value).trim().replace(/,/g, ".");
  if (!str) return null;
  const num = Number(str);
  return Number.isFinite(num) ? num : null;
}

function asInteger(value) {
  const num = asNumber(value);
  if (num === null) return null;
  const rounded = Math.round(num);
  return Number.isFinite(rounded) ? rounded : null;
}

function firstNumber(...values) {
  for (const value of values) {
    const num = asNumber(value);
    if (num !== null) return num;
  }
  return null;
}

function normalizeDate(value) {
  if (value === null || value === undefined) return null;

  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value;
  }

  if (typeof value === "string") {
    const trimmed = value.trim();
    if (!trimmed) return null;
    if (/^0{4}-0{2}-0{2}/.test(trimmed)) return null;
    const parsed = new Date(trimmed);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
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

async function migrateContactLensExamination(tenantId = "tenant_1", branchId = null) {
  tenantId = ensureTenantId(tenantId, "tenant_1");

  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastLensId = 0;
  let total = 0;
  let skippedMissingCustomer = 0;
  let skippedMissingCheckDate = 0;
  let skippedMissingLensId = 0;
  let missingExaminerCount = 0;

  try {
    // Unique index creation moved to Prisma schema/migrations. Leaving disabled to avoid conflicts.
    // await pg.query(`
    //   DO $$
    //   BEGIN
    //     IF NOT EXISTS (
    //       SELECT 1
    //       FROM pg_indexes
    //       WHERE indexname = 'contactlens_exam_tenant_lensid_ux'
    //     ) THEN
    //       CREATE UNIQUE INDEX contactlens_exam_tenant_lensid_ux
    //       ON "ContactLensExamination" ("tenantId", "lensId");
    //     END IF;
    //   END$$;
    // `);

    const { rows: customerRows } = await pg.query(
      `SELECT id, "customerId"
         FROM "Customer"
        WHERE "tenantId" = $1`,
      [tenantId]
    );
    const customerMap = new Map();
    for (const row of customerRows) {
      for (const key of legacyIdCandidates(row.customerId)) {
        if (key && !customerMap.has(key)) {
          customerMap.set(key, row.id);
        }
      }
    }

    const { rows: userRows } = await pg.query(
      `SELECT id, email
         FROM "User"
        WHERE "tenantId" = $1`,
      [tenantId]
    );
    const userEmailMap = new Map(
      userRows
        .filter((u) => cleanText(u.email))
        .map((u) => [u.email.toLowerCase(), u.id])
    );

    const [legacyUsers] = await mysql.query(
      `SELECT UserId, CellPhone, HomePhone, UserTz
         FROM tblUsers`
    );
    const legacyUserMap = new Map();
    for (const user of legacyUsers) {
      for (const key of legacyIdCandidates(user.UserId)) {
        if (!legacyUserMap.has(key)) {
          legacyUserMap.set(key, user);
        }
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT PerId, CheckDate, UserId, ReCheckDate, PupDiam, CornDiam, EyeLidKey, BUT, ShirR, ShirL,
                Ecolor, rHR, rHL, rVR, rVL, AxHR, AxHL, rTR, rTL, rNR, rNL, rIR, rIL, rSR, rSL,
                DiamR, DiamL, BC1R, BC1L, BC2R, BC2L, OZR, OZL, PrR, PrL, SphR, SphL, CylR, CylL,
                AxR, AxL, MaterR, MaterL, TintR, TintL, VAR, VAL, VA, PHR, PHL, ClensTypeIdR,
                ClensTypeIdL, ClensManufIdR, ClensManufIdL, ClensBrandIdR, ClensBrandIdL,
                ClensSolCleanId, ClensSolDisinfectId, ClensSolRinseId, Comments, AddR, AddL,
                BUTL, BlinkFreq, BlinkQual, ClensId, FitCom
           FROM tblCrdClensChecks
          WHERE ClensId > ?
          ORDER BY ClensId
          LIMIT ${WINDOW_SIZE}`,
        [lastLensId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];

        for (const record of chunk) {
          const lensId = asInteger(record.ClensId);
          if (lensId === null) {
            skippedMissingLensId += 1;
            continue;
          }

          const customerCandidates = legacyIdCandidates(record.PerId);
          const customerId = customerCandidates
            .map((candidate) => customerMap.get(candidate))
            .find((value) => value) || null;
          if (!customerId) {
            skippedMissingCustomer += 1;
            continue;
          }

          const checkDate = normalizeDate(record.CheckDate);
          if (!checkDate) {
            skippedMissingCheckDate += 1;
            continue;
          }
          const reCheckDate = normalizeDate(record.ReCheckDate);

          let examinerId = null;
          if (record.UserId !== null && record.UserId !== undefined) {
            const legacyUser = legacyIdCandidates(record.UserId)
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
                `user-${normalizeLegacyId(legacyUser.UserId)}@legacy.local`,
              ].filter(Boolean);
              examinerId = candidates.map((c) => userEmailMap.get(c)).find((v) => v) || null;
            }
            if (!examinerId) {
              missingExaminerCount += 1;
            }
          }

          const createdAt = checkDate;
          const updatedAt = checkDate;

          const rowValues = [
            uuidv4(),                          // id
            tenantId,                          // tenantId
            branchId,                          // branchId
            customerId,                        // customerId
            checkDate,                         // checkDate
            reCheckDate,                       // reCheckDate
            examinerId,                        // examinerId
            asNumber(record.PupDiam),          // pupilDiameter
            asNumber(record.CornDiam),         // cornealDiameter
            asNumber(record.EyeLidKey),        // eyelidKey
            firstNumber(record.BUT, record.BUTL), // breakUpTime
            asNumber(record.ShirR),            // schirmerRight
            asNumber(record.ShirL),            // schirmerLeft
            cleanText(record.Ecolor),          // eyeColor
            asNumber(record.rHR),              // keratometryHR
            asNumber(record.rHL),              // keratometryHL
            asNumber(record.AxHR),             // axisHR
            asNumber(record.AxHL),             // axisHL
            asNumber(record.rVR),              // keratometryVR
            asNumber(record.rVL),              // keratometryVL
            asNumber(record.rTR),              // keratometryTR
            asNumber(record.rTL),              // keratometryTL
            asNumber(record.rNR),              // keratometryNR
            asNumber(record.rNL),              // keratometryNL
            asNumber(record.rIR),              // keratometryIR
            asNumber(record.rIL),              // keratometryIL
            asNumber(record.rSR),              // keratometrySR
            asNumber(record.rSL),              // keratometrySL
            asNumber(record.DiamR),            // diameterRight
            asNumber(record.DiamL),            // diameterLeft
            asNumber(record.BC1R),             // baseCurve1R
            asNumber(record.BC1L),             // baseCurve1L
            asNumber(record.BC2R),             // baseCurve2R
            asNumber(record.BC2L),             // baseCurve2L
            asNumber(record.OZR),              // opticalZoneR
            asNumber(record.OZL),              // opticalZoneL
            asInteger(record.PrR),             // powerR
            asInteger(record.PrL),             // powerL
            asNumber(record.SphR),             // sphereR
            asNumber(record.SphL),             // sphereL
            asNumber(record.CylR),             // cylinderR
            asNumber(record.CylL),             // cylinderL
            asNumber(record.AxR),              // axisR
            asNumber(record.AxL),              // axisL
            asNumber(record.AddR),             // addR
            asNumber(record.AddL),             // addL
            asInteger(record.MaterR),          // materialR
            asInteger(record.MaterL),          // materialL
            asInteger(record.TintR),           // tintR
            asInteger(record.TintL),           // tintL
            asNumber(record.VAR),              // visualAcuityR
            asNumber(record.VAL),              // visualAcuityL
            asNumber(record.VA),               // visualAcuity
            asNumber(record.PHR),              // pinHoleR
            asNumber(record.PHL),              // pinHoleL
            asInteger(record.ClensTypeIdR),    // lensTypeIdR
            asInteger(record.ClensTypeIdL),    // lensTypeIdL
            asInteger(record.ClensManufIdR),   // manufacturerIdR
            asInteger(record.ClensManufIdL),   // manufacturerIdL
            asInteger(record.ClensBrandIdR),   // brandIdR
            asInteger(record.ClensBrandIdL),   // brandIdL
            asInteger(record.ClensSolCleanId),      // cleaningSolutionId
            asInteger(record.ClensSolDisinfectId),  // disinfectingSolutionId
            asInteger(record.ClensSolRinseId),      // rinsingSolutionId
            asInteger(record.BlinkFreq),       // blinkFrequency
            asInteger(record.BlinkQual),       // blinkQuality
            lensId,                            // lensId
            cleanText(record.Comments),        // comments
            cleanText(record.FitCom),          // fittingComment
            createdAt,                         // createdAt
            updatedAt                          // updatedAt
          ];

          const offset = params.length;
          const placeholders = rowValues
            .map((_, idx) => `$${offset + idx + 1}`)
            .join(", ");
          values.push(`(${placeholders})`);
          params.push(...rowValues);
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "ContactLensExamination" (
              id,
              "tenantId",
              "branchId",
              "customerId",
              "checkDate",
              "reCheckDate",
              "examinerId",
              "pupilDiameter",
              "cornealDiameter",
              "eyelidKey",
              "breakUpTime",
              "schirmerRight",
              "schirmerLeft",
              "eyeColor",
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
              "diameterRight",
              "diameterLeft",
              "baseCurve1R",
              "baseCurve1L",
              "baseCurve2R",
              "baseCurve2L",
              "opticalZoneR",
              "opticalZoneL",
              "powerR",
              "powerL",
              "sphereR",
              "sphereL",
              "cylinderR",
              "cylinderL",
              "axisR",
              "axisL",
              "addR",
              "addL",
              "materialR",
              "materialL",
              "tintR",
              "tintL",
              "visualAcuityR",
              "visualAcuityL",
              "visualAcuity",
              "pinHoleR",
              "pinHoleL",
              "lensTypeIdR",
              "lensTypeIdL",
              "manufacturerIdR",
              "manufacturerIdL",
              "brandIdR",
              "brandIdL",
              "cleaningSolutionId",
              "disinfectingSolutionId",
              "rinsingSolutionId",
              "blinkFrequency",
              "blinkQuality",
              "lensId",
              comments,
              "fittingComment",
              "createdAt",
              "updatedAt"
            )
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "lensId")
            DO UPDATE SET
              "branchId" = EXCLUDED."branchId",
              "customerId" = EXCLUDED."customerId",
              "checkDate" = EXCLUDED."checkDate",
              "reCheckDate" = EXCLUDED."reCheckDate",
              "examinerId" = EXCLUDED."examinerId",
              "pupilDiameter" = EXCLUDED."pupilDiameter",
              "cornealDiameter" = EXCLUDED."cornealDiameter",
              "eyelidKey" = EXCLUDED."eyelidKey",
              "breakUpTime" = EXCLUDED."breakUpTime",
              "schirmerRight" = EXCLUDED."schirmerRight",
              "schirmerLeft" = EXCLUDED."schirmerLeft",
              "eyeColor" = EXCLUDED."eyeColor",
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
              "diameterRight" = EXCLUDED."diameterRight",
              "diameterLeft" = EXCLUDED."diameterLeft",
              "baseCurve1R" = EXCLUDED."baseCurve1R",
              "baseCurve1L" = EXCLUDED."baseCurve1L",
              "baseCurve2R" = EXCLUDED."baseCurve2R",
              "baseCurve2L" = EXCLUDED."baseCurve2L",
              "opticalZoneR" = EXCLUDED."opticalZoneR",
              "opticalZoneL" = EXCLUDED."opticalZoneL",
              "powerR" = EXCLUDED."powerR",
              "powerL" = EXCLUDED."powerL",
              "sphereR" = EXCLUDED."sphereR",
              "sphereL" = EXCLUDED."sphereL",
              "cylinderR" = EXCLUDED."cylinderR",
              "cylinderL" = EXCLUDED."cylinderL",
              "axisR" = EXCLUDED."axisR",
              "axisL" = EXCLUDED."axisL",
              "addR" = EXCLUDED."addR",
              "addL" = EXCLUDED."addL",
              "materialR" = EXCLUDED."materialR",
              "materialL" = EXCLUDED."materialL",
              "tintR" = EXCLUDED."tintR",
              "tintL" = EXCLUDED."tintL",
              "visualAcuityR" = EXCLUDED."visualAcuityR",
              "visualAcuityL" = EXCLUDED."visualAcuityL",
              "visualAcuity" = EXCLUDED."visualAcuity",
              "pinHoleR" = EXCLUDED."pinHoleR",
              "pinHoleL" = EXCLUDED."pinHoleL",
              "lensTypeIdR" = EXCLUDED."lensTypeIdR",
              "lensTypeIdL" = EXCLUDED."lensTypeIdL",
              "manufacturerIdR" = EXCLUDED."manufacturerIdR",
              "manufacturerIdL" = EXCLUDED."manufacturerIdL",
              "brandIdR" = EXCLUDED."brandIdR",
              "brandIdL" = EXCLUDED."brandIdL",
              "cleaningSolutionId" = EXCLUDED."cleaningSolutionId",
              "disinfectingSolutionId" = EXCLUDED."disinfectingSolutionId",
              "rinsingSolutionId" = EXCLUDED."rinsingSolutionId",
              "blinkFrequency" = EXCLUDED."blinkFrequency",
              "blinkQuality" = EXCLUDED."blinkQuality",
              comments = EXCLUDED.comments,
              "fittingComment" = EXCLUDED."fittingComment",
              "updatedAt" = EXCLUDED."updatedAt"
            `,
            params
          );
          await pg.query("COMMIT");
          total += values.length;
        } catch (error) {
          await pg.query("ROLLBACK");
          throw error;
        }
      }

      lastLensId = asInteger(rows[rows.length - 1].ClensId) ?? lastLensId;
      console.log(`ContactLensExamination migrated so far: ${total} (lastLensId=${lastLensId})`);
    }

    console.log(`✅ ContactLensExamination migration completed. Total processed: ${total}`);
    if (skippedMissingCustomer) {
      console.warn(`⚠️ Skipped ${skippedMissingCustomer} examinations due to missing customer mappings.`);
    }
    if (skippedMissingCheckDate) {
      console.warn(`⚠️ Skipped ${skippedMissingCheckDate} examinations due to invalid check date.`);
    }
    if (skippedMissingLensId) {
      console.warn(`⚠️ Skipped ${skippedMissingLensId} examinations due to invalid lens id.`);
    }
    if (missingExaminerCount) {
      console.warn(`⚠️ Unable to map examiner for ${missingExaminerCount} examinations; stored as null.`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateContactLensExamination;
