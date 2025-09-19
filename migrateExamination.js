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
  const n = Number(value);
  return Number.isFinite(n) ? n : null;
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

function makeLegacyUserEmail(userRow) {
  const email = cleanText(userRow.Email);
  if (email) return email.toLowerCase();

  const cell = cleanText(userRow.CellPhone);
  if (cell) return `${cell}@legacy.local`.toLowerCase();

  const home = cleanText(userRow.HomePhone);
  if (home) return `${home}@legacy.local`.toLowerCase();

  return `user-${userRow.UserId}@legacy.local`.toLowerCase();
}

function averageNumbers(...values) {
  const nums = values.map(asNumber).filter((n) => n !== null);
  if (!nums.length) return null;
  const sum = nums.reduce((acc, val) => acc + val, 0);
  return sum / nums.length;
}

function buildRefractionData(row) {
  return {
    distance: {
      sphere: { right: cleanText(row.SphR), left: cleanText(row.SphL) },
      cylinder: { right: asNumber(row.CylR), left: asNumber(row.CylL) },
      axis: { right: asNumber(row.AxR), left: asNumber(row.AxL) },
      prism: {
        right: asNumber(row.PrisR),
        left: asNumber(row.PrisL),
        baseRight: asNumber(row.BaseR),
        baseLeft: asNumber(row.BaseL),
      },
      va: { right: cleanText(row.FVR), left: cleanText(row.FVL) },
      pinhole: { right: cleanText(row.PHR), left: cleanText(row.PHL) },
      readingAddition: { right: asNumber(row.ReadR), left: asNumber(row.ReadL) },
      intermediate: { right: asNumber(row.IntR), left: asNumber(row.IntL) },
      bifocal: { right: asNumber(row.BifR), left: asNumber(row.BifL) },
      multifocal: { right: asNumber(row.MulR), left: asNumber(row.MulL) },
      highAddition: { right: asNumber(row.HighR), left: asNumber(row.HighL) },
    },
    pupillaryDistance: {
      distance: {
        right: asNumber(row.PDDistR),
        left: asNumber(row.PDDistL),
        average: asNumber(row.PDDistA),
      },
      near: {
        right: asNumber(row.PDReadR),
        left: asNumber(row.PDReadL),
        average: asNumber(row.PDReadA),
      },
    },
    additions: {
      base: { right: asNumber(row.AddBaseR), left: asNumber(row.AddBaseL) },
      prism: { right: asNumber(row.AddPrisR), left: asNumber(row.AddPrisL) },
      externalPrism: { right: asNumber(row.ExtPrisR), left: asNumber(row.ExtPrisL) },
      externalBase: { right: asNumber(row.ExtBaseR), left: asNumber(row.ExtBaseL) },
      extraPrism: { right: asNumber(row.AddExtPrisR), left: asNumber(row.AddExtPrisL) },
      extraBase: { right: asNumber(row.AddExtBaseR), left: asNumber(row.AddExtBaseL) },
    },
    dominance: cleanText(row.DominEye),
  };
}

function buildCurrentRxData(row) {
  return {
    distance: {
      sphere: { right: cleanText(row.PSphR), left: cleanText(row.PSphL) },
      cylinder: { right: asNumber(row.PCylR), left: asNumber(row.PCylL) },
      axis: { right: asNumber(row.PAxR), left: asNumber(row.PAxL) },
      prism: {
        right: asNumber(row.PPrisR),
        left: asNumber(row.PPrisL),
        baseRight: asNumber(row.PBaseR),
        baseLeft: asNumber(row.PBaseL),
      },
      va: { right: cleanText(row.PVAR), left: cleanText(row.PVAL), binocular: cleanText(row.PVA) },
      pinhole: { right: cleanText(row.PPHR), left: cleanText(row.PPHL) },
      readingAddition: { right: asNumber(row.PReadR), left: asNumber(row.PReadL) },
      intermediate: { right: asNumber(row.PIntR), left: asNumber(row.PIntL) },
      bifocal: { right: asNumber(row.PBifR), left: asNumber(row.PBifL) },
      multifocal: { right: asNumber(row.PMulR), left: asNumber(row.PMulL) },
      highAddition: { right: asNumber(row.PHighR), left: asNumber(row.PHighL) },
    },
    pupillaryDistance: {
      distance: {
        right: asNumber(row.PPDDistR),
        left: asNumber(row.PPDDistL),
        average: asNumber(row.PPDDistA),
      },
      near: {
        right: asNumber(row.PPDReadR),
        left: asNumber(row.PPDReadL),
        average: asNumber(row.PPDReadA),
      },
    },
    junior: { right: cleanText(row.PJR), left: cleanText(row.PJL) },
  };
}

function buildSupplementalData(row) {
  return {
    contrastSensitivity: { right: cleanText(row.CSR), left: cleanText(row.CSL) },
    junior: { right: cleanText(row.JR), left: cleanText(row.JL) },
    finalVA: { right: cleanText(row.PFVR), left: cleanText(row.PFVL) },
    readingValues: {
      distance: { right: cleanText(row.ReadDR), left: cleanText(row.ReadDL) },
      intermediate: { right: cleanText(row.IntDR), left: cleanText(row.IntDL) },
      bifocal: { right: cleanText(row.BifDR), left: cleanText(row.BifDL) },
    },
    contactLens: {
      current: {
        distance: cleanText(row.CTD),
        near: cleanText(row.CTN),
      },
      comments: {
        distance: cleanText(row.CCD),
        near: cleanText(row.CCN),
      },
    },
    hiddenComments: cleanText(row.HidCom),
    np: {
      right: cleanText(row.NPCR),
      nearPointAccommodationRight: asNumber(row.NPAR),
      nearPointAccommodationLeft: asNumber(row.NPAL),
    },
  };
}

async function migrateExamination(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  let skippedMissingCustomer = 0;
  let skippedMissingDoctor = 0;

  try {
    const { rows: customerRows } = await pg.query(
      `SELECT id, "customerId" FROM "Customer" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const customerMap = new Map(customerRows.map((c) => [c.customerId, c.id]));

    const { rows: userRows } = await pg.query(
      `SELECT id, email FROM "User" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const userEmailMap = new Map(userRows.map((u) => [u.email.toLowerCase(), u.id]));

    const [legacyUsers] = await mysql.query(
      `SELECT UserId, CellPhone, HomePhone, UserTz FROM tblUsers`
    );
    const doctorMap = new Map();
    for (const user of legacyUsers) {
      const key = makeLegacyUserEmail(user);
      const mapped = userEmailMap.get(key);
      if (mapped) {
        doctorMap.set(String(user.UserId), mapped);
      }
    }

    while (true) {
      const [rows] = await mysql.query(
        `SELECT GlassCId, PerId, CheckDate, UserId, ReCheckDate, FVR, FVL, SphR, SphL, CylR, CylL,
                AxR, AxL, PrisR, PrisL, BaseR, BaseL, VAR, VAL, VA, PHR, PHL, ReadR, ReadL,
                AddBaseR, AddBaseL, AddPrisR, AddPrisL, IntR, IntL, BifR, BifL, MulR, MulL,
                HighR, HighL, PDDistR, PDDistL, PDReadR, PDReadL, DominEye, IOPL, IOPR, IOPInstId,
                IOPTime, JR, JL, Comments, PDDistA, PDReadA, PFVR, PFVL, PSphR, PSphL, PCylR, PCylL,
                PAxR, PAxL, PPrisR, PPrisL, PBaseR, PBaseL, PVAR, PVAL, PVA, PPHR, PPHL, PReadR,
                PReadL, PAddBaseR, PAddBaseL, PAddPrisR, PAddPrisL, PIntR, PIntL, PBifR, PBifL,
                PMulR, PMulL, PHighR, PHighL, PPDDistR, PPDDistL, PPDReadR, PPDReadL, PPDDistA,
                PPDReadA, PJR, PJL, CSR, CSL, ExtPrisR, ExtPrisL, ExtBaseR, ExtBaseL, AddExtPrisR,
                AddExtPrisL, AddExtBaseR, AddExtBaseL, ReadDR, ReadDL, IntDR, IntDL, BifDR, BifDL,
                CTD, CTN, CCD, CCN, HidCom, AmslerR, AmslerL, NPCR, NPAL, NPAR
           FROM tblCrdGlassChecks
          WHERE GlassCId > ?
          ORDER BY GlassCId
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
          const legacyCustomerKey = String(r.PerId);
          const customerId = customerMap.get(legacyCustomerKey);
          if (!customerId) {
            skippedMissingCustomer += 1;
            continue;
          }

          const doctorId = doctorMap.get(String(r.UserId));
          if (!doctorId) {
            skippedMissingDoctor += 1;
            continue;
          }

          const examDate = normalizeDate(r.CheckDate) || now;
          const nextExamDate = normalizeDate(r.ReCheckDate);
          const followUpRequired = nextExamDate !== null;
          const iopTime = normalizeDate(r.IOPTime);

          const refractionData = buildRefractionData(r);
          const currentRxData = buildCurrentRxData(r);
          const supplemental = buildSupplementalData(r);

          const recParts = [];
          const ctd = cleanText(r.CTD);
          const ctn = cleanText(r.CTN);
          const ccd = cleanText(r.CCD);
          const ccn = cleanText(r.CCN);
          if (ctd) recParts.push(`Contact lens distance: ${ctd}`);
          if (ctn) recParts.push(`Contact lens near: ${ctn}`);
          if (ccd) recParts.push(`Contact comments distance: ${ccd}`);
          if (ccn) recParts.push(`Contact comments near: ${ccn}`);
          const recommendations = recParts.length ? recParts.join("\n") : null;

          const pdAverage = refractionData.pupillaryDistance.distance.average;
          const pdNear = refractionData.pupillaryDistance.near.average;
          const npcDistance = averageNumbers(r.NPAL, r.NPAR);

          const examId = `${tenantId}-glass-${r.GlassCId}`;

          const columns = [
            examId,
            tenantId,
            customerId,
            doctorId,
            examDate,
            "GLASS_CHECK",
            cleanText(r.FVR),
            cleanText(r.FVL),
            cleanText(r.VAR),
            cleanText(r.VAL),
            refractionData,
            currentRxData,
            cleanText(r.Comments),
            recommendations,
            cleanText(r.HidCom),
            supplemental,
            nextExamDate,
            followUpRequired,
            examDate,
            examDate,
            asNumber(r.IOPR),
            asNumber(r.IOPL),
            iopTime,
            cleanText(r.IOPInstId ? `Instrument ${r.IOPInstId}` : null),
            cleanText(r.VA),
            cleanText(r.AmslerR),
            cleanText(r.AmslerL),
            npcDistance,
            pdNear,
            pdAverage,
            null,
          ];

          values.push(
            `($${params.length + 1}, $${params.length + 2}, $${params.length + 3}, $${params.length + 4}, $${params.length + 5}, $${params.length + 6}, $${params.length + 7}, $${params.length + 8}, $${params.length + 9}, $${params.length + 10}, $${params.length + 11}, $${params.length + 12}, $${params.length + 13}, $${params.length + 14}, $${params.length + 15}, $${params.length + 16}, $${params.length + 17}, $${params.length + 18}, $${params.length + 19}, $${params.length + 20}, $${params.length + 21}, $${params.length + 22}, $${params.length + 23}, $${params.length + 24}, $${params.length + 25}, $${params.length + 26}, $${params.length + 27}, $${params.length + 28}, $${params.length + 29}, $${params.length + 30}, $${params.length + 31})`
          );

          params.push(...columns);
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "Examination" (
              id, "tenantId", "customerId", "doctorId", "examDate", "examType",
              "vaRightDist", "vaLeftDist", "vaRightNear", "vaLeftNear", "refractionData",
              "currentRxData", "clinicalNotes", recommendations, "internalNotes",
              "prescriptionData", "nextExamDate", "followUpRequired", "createdAt", "updatedAt",
              "iopRight", "iopLeft", "iopTime", "iopMethod", "vaBinocular", "amslergridOd",
              "amslergridOs", "npcDistance", "pdNear", "pupilDistance", "branchId"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              "examDate" = EXCLUDED."examDate",
              "doctorId" = EXCLUDED."doctorId",
              "vaRightDist" = EXCLUDED."vaRightDist",
              "vaLeftDist" = EXCLUDED."vaLeftDist",
              "vaRightNear" = EXCLUDED."vaRightNear",
              "vaLeftNear" = EXCLUDED."vaLeftNear",
              "refractionData" = EXCLUDED."refractionData",
              "currentRxData" = EXCLUDED."currentRxData",
              "clinicalNotes" = EXCLUDED."clinicalNotes",
              recommendations = EXCLUDED.recommendations,
              "internalNotes" = EXCLUDED."internalNotes",
              "prescriptionData" = EXCLUDED."prescriptionData",
              "nextExamDate" = EXCLUDED."nextExamDate",
              "followUpRequired" = EXCLUDED."followUpRequired",
              "iopRight" = EXCLUDED."iopRight",
              "iopLeft" = EXCLUDED."iopLeft",
              "iopTime" = EXCLUDED."iopTime",
              "iopMethod" = EXCLUDED."iopMethod",
              "vaBinocular" = EXCLUDED."vaBinocular",
              "amslergridOd" = EXCLUDED."amslergridOd",
              "amslergridOs" = EXCLUDED."amslergridOs",
              "npcDistance" = EXCLUDED."npcDistance",
              "pdNear" = EXCLUDED."pdNear",
              "pupilDistance" = EXCLUDED."pupilDistance",
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

      lastId = rows[rows.length - 1].GlassCId;
      console.log(`Examinations migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ Examination migration completed. Total inserted/updated: ${total}`);
    if (skippedMissingCustomer) {
      console.warn(`⚠️ Skipped ${skippedMissingCustomer} examinations due to missing customers`);
    }
    if (skippedMissingDoctor) {
      console.warn(`⚠️ Skipped ${skippedMissingDoctor} examinations due to missing doctors`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateExamination;
