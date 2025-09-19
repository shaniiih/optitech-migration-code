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

async function migrateContactLensPrescription(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  let skippedMissingCustomer = 0;
  let missingDoctorCount = 0;
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

    const buildLookup = (rows, idField, nameField) => {
      const map = new Map();
      for (const row of rows) {
        const key = normalizeLegacyId(row[idField]);
        const name = cleanText(row[nameField]);
        if (key && !map.has(key)) {
          map.set(key, name || null);
        }
      }
      return map;
    };

    const [brandRows] = await mysql.query(
      `SELECT ClensBrandId, ClensBrandName FROM tblCrdClensBrands`
    );
    const brandMap = buildLookup(brandRows, "ClensBrandId", "ClensBrandName");

    const [typeRows] = await mysql.query(
      `SELECT ClensTypeId, ClensTypeName FROM tblCrdClensTypes`
    );
    const typeMap = buildLookup(typeRows, "ClensTypeId", "ClensTypeName");

    const [manufRows] = await mysql.query(
      `SELECT ClensManufId, ClensManufName FROM tblCrdClensManuf`
    );
    const manufacturerMap = buildLookup(manufRows, "ClensManufId", "ClensManufName");

    const [materialRows] = await mysql.query(
      `SELECT MaterId, MaterName FROM tblCrdClensChecksMater`
    );
    const materialMap = buildLookup(materialRows, "MaterId", "MaterName");

    const [tintRows] = await mysql.query(
      `SELECT TintId, TintName FROM tblCrdClensChecksTint`
    );
    const tintMap = buildLookup(tintRows, "TintId", "TintName");

    const [solutionCleanRows] = await mysql.query(
      `SELECT ClensSolCleanId, ClensSolCleanName FROM tblCrdClensSolClean`
    );
    const cleanSolutionMap = buildLookup(solutionCleanRows, "ClensSolCleanId", "ClensSolCleanName");

    const [solutionDisinfectRows] = await mysql.query(
      `SELECT ClensSolDisinfectId, ClensSolDisinfectName FROM tblCrdClensSolDisinfect`
    );
    const disinfectSolutionMap = buildLookup(solutionDisinfectRows, "ClensSolDisinfectId", "ClensSolDisinfectName");

    const [solutionRinseRows] = await mysql.query(
      `SELECT ClensSolRinseId, ClensSolRinseName FROM tblCrdClensSolRinse`
    );
    const rinseSolutionMap = buildLookup(solutionRinseRows, "ClensSolRinseId", "ClensSolRinseName");

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
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();

        for (const r of chunk) {
          const legacyCustomerCandidates = legacyIdCandidates(r.PerId);
          const customerId = legacyCustomerCandidates
            .map((candidate) => customerMap.get(candidate))
            .find((value) => value) || null;
          if (!customerId) {
            skippedMissingCustomer += 1;
            if (legacyCustomerCandidates.length && missingCustomerSamples.size < 10) {
              missingCustomerSamples.add(legacyCustomerCandidates[0]);
            }
            continue;
          }

          let doctorId = null;
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
              doctorId = candidates.map((c) => userEmailMap.get(c)).find((v) => v) || null;
            }
            if (!doctorId) {
              missingDoctorCount += 1;
            }
          }

          const prescriptionDate = normalizeDate(r.CheckDate) || now;
          const validUntil = normalizeDate(r.ReCheckDate);

          const brandRight = brandMap.get(normalizeLegacyId(r.ClensBrandIdR)) || null;
          const brandLeft = brandMap.get(normalizeLegacyId(r.ClensBrandIdL)) || null;
          const typeRight = typeMap.get(normalizeLegacyId(r.ClensTypeIdR)) || null;
          const typeLeft = typeMap.get(normalizeLegacyId(r.ClensTypeIdL)) || null;
          const manufacturerRight = manufacturerMap.get(normalizeLegacyId(r.ClensManufIdR)) || null;
          const manufacturerLeft = manufacturerMap.get(normalizeLegacyId(r.ClensManufIdL)) || null;
          const materialRight = materialMap.get(normalizeLegacyId(r.MaterR)) || null;
          const materialLeft = materialMap.get(normalizeLegacyId(r.MaterL)) || null;
          const tintRight = tintMap.get(normalizeLegacyId(r.TintR)) || null;
          const tintLeft = tintMap.get(normalizeLegacyId(r.TintL)) || null;
          const cleanSolution = cleanSolutionMap.get(normalizeLegacyId(r.ClensSolCleanId)) || null;
          const disinfectSolution = disinfectSolutionMap.get(normalizeLegacyId(r.ClensSolDisinfectId)) || null;
          const rinseSolution = rinseSolutionMap.get(normalizeLegacyId(r.ClensSolRinseId)) || null;

          const rightPower = asNumber(r.SphR);
          const rightBC = asNumber(r.BC2R) ?? asNumber(r.BC1R);
          const rightDiameter = asNumber(r.DiamR);
          const rightCylinder = asNumber(r.CylR);
          const rightAxis = asInteger(r.AxR);
          const rightAdd = asNumber(r.AddR);
          const rightColor = tintRight || cleanText(r.Ecolor);

          const leftPower = asNumber(r.SphL);
          const leftBC = asNumber(r.BC2L) ?? asNumber(r.BC1L);
          const leftDiameter = asNumber(r.DiamL);
          const leftCylinder = asNumber(r.CylL);
          const leftAxis = asInteger(r.AxL);
          const leftAdd = asNumber(r.AddL);
          const leftColor = tintLeft || cleanText(r.Ecolor);

          let wearingSchedule = null;
          if (typeRight && typeLeft && typeRight === typeLeft) {
            wearingSchedule = typeRight;
          } else if (typeRight && !typeLeft) {
            wearingSchedule = typeRight;
          } else if (!typeRight && typeLeft) {
            wearingSchedule = typeLeft;
          }

          const recommendationParts = [];
          const blinkFreq = cleanText(r.BlinkFreq);
          const blinkQual = cleanText(r.BlinkQual);
          if (blinkFreq) recommendationParts.push(`Blink frequency: ${blinkFreq}`);
          if (blinkQual) recommendationParts.push(`Blink quality: ${blinkQual}`);
          if (cleanSolution) recommendationParts.push(`Cleaning solution: ${cleanSolution}`);
          if (disinfectSolution) recommendationParts.push(`Disinfecting solution: ${disinfectSolution}`);
          if (rinseSolution) recommendationParts.push(`Rinsing solution: ${rinseSolution}`);
          const recommendations = recommendationParts.length ? recommendationParts.join("\n") : null;

          const noteParts = [];
          const comments = cleanText(r.Comments);
          const fittingComments = cleanText(r.FitCom);
          if (comments) noteParts.push(comments);
          if (fittingComments) noteParts.push(fittingComments);
          const notes = noteParts.length ? noteParts.join("\n") : null;

          const additionalData = pruneObject({
            pupilDiameter: asNumber(r.PupDiam),
            corneaDiameter: asNumber(r.CornDiam),
            eyelidKey: asNumber(r.EyeLidKey),
            tearBreakUpTime: {
              right: asInteger(r.BUT),
              left: asInteger(r.BUTL),
            },
            schirmer: {
              right: cleanText(r.ShirR),
              left: cleanText(r.ShirL),
            },
            evaluation: {
              horizontal: { right: asNumber(r.rHR), left: asNumber(r.rHL), axisRight: asInteger(r.AxHR), axisLeft: asInteger(r.AxHL) },
              vertical: { right: asNumber(r.rVR), left: asNumber(r.rVL) },
              temporal: { right: asNumber(r.rTR), left: asNumber(r.rTL) },
              nasal: { right: asNumber(r.rNR), left: asNumber(r.rNL) },
              inferior: { right: asNumber(r.rIR), left: asNumber(r.rIL) },
              superior: { right: asNumber(r.rSR), left: asNumber(r.rSL) },
            },
            opticalZone: { right: cleanText(r.OZR), left: cleanText(r.OZL) },
            baseCurveLegacy: { right: cleanText(r.BC1R), left: cleanText(r.BC1L) },
            baseCurveSecondary: { right: asNumber(r.BC2R), left: asNumber(r.BC2L) },
            prescriptionNumbers: { right: asInteger(r.PrR), left: asInteger(r.PrL) },
            type: {
              rightId: asInteger(r.ClensTypeIdR),
              rightName: typeRight,
              leftId: asInteger(r.ClensTypeIdL),
              leftName: typeLeft,
            },
            manufacturer: {
              rightId: asInteger(r.ClensManufIdR),
              rightName: manufacturerRight,
              leftId: asInteger(r.ClensManufIdL),
              leftName: manufacturerLeft,
            },
            material: {
              rightId: asInteger(r.MaterR),
              rightName: materialRight,
              leftId: asInteger(r.MaterL),
              leftName: materialLeft,
            },
            tint: {
              rightId: asInteger(r.TintR),
              rightName: tintRight,
              leftId: asInteger(r.TintL),
              leftName: tintLeft,
              baseColor: cleanText(r.Ecolor),
            },
            solutions: {
              cleaningId: asInteger(r.ClensSolCleanId),
              cleaningName: cleanSolution,
              disinfectingId: asInteger(r.ClensSolDisinfectId),
              disinfectingName: disinfectSolution,
              rinsingId: asInteger(r.ClensSolRinseId),
              rinsingName: rinseSolution,
            },
            pinhole: { right: cleanText(r.PHR), left: cleanText(r.PHL), binocular: cleanText(r.VA) },
            va: { right: cleanText(r.VAR), left: cleanText(r.VAL) },
            blinkAssessment: { frequency: blinkFreq, quality: blinkQual },
          });

          const id = `${tenantId}-clens-${r.ClensId}`;
          const createdAt = prescriptionDate;
          const updatedAt = prescriptionDate;

          const columns = [
            id,
            tenantId,
            customerId,
            doctorId,
            prescriptionDate,
            validUntil,
            brandRight,
            rightPower,
            rightBC,
            rightDiameter,
            rightCylinder,
            rightAxis,
            rightAdd,
            rightColor,
            brandLeft,
            leftPower,
            leftBC,
            leftDiameter,
            leftCylinder,
            leftAxis,
            leftAdd,
            leftColor,
            wearingSchedule,
            null,
            notes,
            recommendations,
            false,
            createdAt,
            updatedAt,
            additionalData,
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
            INSERT INTO "ContactLensPrescription" (
              id, "tenantId", "customerId", "doctorId", "prescriptionDate", "validUntil",
              "rightBrand", "rightPower", "rightBC", "rightDiameter", "rightCylinder",
              "rightAxis", "rightAdd", "rightColor", "leftBrand", "leftPower", "leftBC",
              "leftDiameter", "leftCylinder", "leftAxis", "leftAdd", "leftColor",
              "wearingSchedule", "replacementSchedule", notes, recommendations,
              "trialLensUsed", "createdAt", "updatedAt", "additionalData", "branchId"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              "customerId" = EXCLUDED."customerId",
              "doctorId" = EXCLUDED."doctorId",
              "prescriptionDate" = EXCLUDED."prescriptionDate",
              "validUntil" = EXCLUDED."validUntil",
              "rightBrand" = EXCLUDED."rightBrand",
              "rightPower" = EXCLUDED."rightPower",
              "rightBC" = EXCLUDED."rightBC",
              "rightDiameter" = EXCLUDED."rightDiameter",
              "rightCylinder" = EXCLUDED."rightCylinder",
              "rightAxis" = EXCLUDED."rightAxis",
              "rightAdd" = EXCLUDED."rightAdd",
              "rightColor" = EXCLUDED."rightColor",
              "leftBrand" = EXCLUDED."leftBrand",
              "leftPower" = EXCLUDED."leftPower",
              "leftBC" = EXCLUDED."leftBC",
              "leftDiameter" = EXCLUDED."leftDiameter",
              "leftCylinder" = EXCLUDED."leftCylinder",
              "leftAxis" = EXCLUDED."leftAxis",
              "leftAdd" = EXCLUDED."leftAdd",
              "leftColor" = EXCLUDED."leftColor",
              "wearingSchedule" = EXCLUDED."wearingSchedule",
              "replacementSchedule" = EXCLUDED."replacementSchedule",
              notes = EXCLUDED.notes,
              recommendations = EXCLUDED.recommendations,
              "trialLensUsed" = EXCLUDED."trialLensUsed",
              "updatedAt" = EXCLUDED."updatedAt",
              "additionalData" = EXCLUDED."additionalData",
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

      lastId = rows[rows.length - 1].ClensId;
      console.log(`Contact lens prescriptions migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ Contact lens prescription migration completed. Total inserted/updated: ${total}`);
    if (skippedMissingCustomer) {
      console.warn(`⚠️ Skipped ${skippedMissingCustomer} contact lens prescriptions due to missing customers`);
      if (missingCustomerSamples.size) {
        console.warn(
          `⚠️ Example legacy customer IDs with no match: ${Array.from(missingCustomerSamples).join(", ")}`
        );
      }
    }
    if (missingDoctorCount) {
      console.warn(`⚠️ Unable to match ${missingDoctorCount} contact lens prescriptions to a doctor/user`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateContactLensPrescription;
