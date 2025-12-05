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

function asInteger(value) {
  if (value === null || value === undefined) return null;
  const n = Number(value);
  return Number.isFinite(n) ? Math.round(n) : null;
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

async function migratePrescription(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  let skippedMissingCustomer = 0;

  try {
    await pg.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_indexes WHERE indexname = 'prescription_tenant_customer_prev_ux'
        ) THEN
          CREATE UNIQUE INDEX prescription_tenant_customer_prev_ux
          ON "Prescription" ("tenantId", id);
        END IF;
      END$$;
    `);

    const { rows: customerRows } = await pg.query(
      `SELECT id, "customerId" FROM "Customer" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const customerMap = new Map(customerRows.map((c) => [c.customerId, c.id]));

    while (true) {
      const [rows] = await mysql.query(
        `SELECT PerId, CheckDate, PrevId, RefSphR, RefSphL, RefCylR, RefCylL, RefAxR, RefAxL,
                RetTypeId1, RetDistId1, RetCom1, RefSphR2, RefSphL2, RefCylR2, RefCylL2, RefAxR2,
                RefAxL2, RetTypeId2, RetDistId2, RetCom2, SphR1, SphL1, CylR1, CylL1, AxR1, AxL1,
                PrisR1, PrisL1, BaseR1, BaseL1, VAR1, VAL1, VA1, PHR1, PHL1, ExtPrisR1, ExtPrisL1,
                ExtBaseR1, ExtBaseL1, Comments1, PDDistR1, PDDistL1, PDDistA1, AddR1, AddL1
           FROM tblCrdGlassChecksPrevs
          WHERE PrevId > ?
          ORDER BY PrevId
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

          const prescriptionDate = normalizeDate(r.CheckDate) || now;
          const createdAt = new Date();
          const updatedAt = createdAt;

          const recommendationsParts = [];
          const rec1 = cleanText(r.RetCom1);
          const rec2 = cleanText(r.RetCom2);
          if (rec1) recommendationsParts.push(rec1);
          if (rec2) recommendationsParts.push(rec2);
          const recommendations = recommendationsParts.length ? recommendationsParts.join("\n") : null;

          const additionalData = {
            retinoscopy: [
              {
                typeId: asInteger(r.RetTypeId1),
                distanceId: asInteger(r.RetDistId1),
                comment: cleanText(r.RetCom1),
                sphere: { right: cleanText(r.RefSphR), left: cleanText(r.RefSphL) },
                cylinder: { right: asNumber(r.RefCylR), left: asNumber(r.RefCylL) },
                axis: { right: asInteger(r.RefAxR), left: asInteger(r.RefAxL) },
              },
              {
                typeId: asInteger(r.RetTypeId2),
                distanceId: asInteger(r.RetDistId2),
                comment: cleanText(r.RetCom2),
                sphere: { right: cleanText(r.RefSphR2), left: cleanText(r.RefSphL2) },
                cylinder: { right: asNumber(r.RefCylR2), left: asNumber(r.RefCylL2) },
                axis: { right: asInteger(r.RefAxR2), left: asInteger(r.RefAxL2) },
              },
            ],
            pinhole: { right: cleanText(r.PHR1), left: cleanText(r.PHL1) },
            externalPrism: {
              right: asNumber(r.ExtPrisR1),
              left: asNumber(r.ExtPrisL1),
              baseRight: cleanText(r.ExtBaseR1),
              baseLeft: cleanText(r.ExtBaseL1),
            },
            visualAcuity: { binocular: cleanText(r.VA1) },
          };

          const prescriptionId = `${tenantId}-rx-${r.PrevId}`;

          const columns = [
            prescriptionId,             // id
            tenantId,                   // tenantId
            customerId,                 // customerId
            null,                       // doctorId (not available in legacy table)
            prescriptionDate,           // prescriptionDate
            null,                       // validUntil
            asNumber(r.RefSphR),          // rightSphere
            asNumber(r.RefCylR),          // rightCylinder
            asInteger(r.RefAxR),          // rightAxis
            asNumber(r.AddR1),          // rightAdd
            asNumber(r.PrisR1),         // rightPrism
            cleanText(r.BaseR1),        // rightBase
            asNumber(r.PDDistR1),       // rightPd
            cleanText(r.VAR1),          // rightVa
            asNumber(r.RefSphL),          // leftSphere
            asNumber(r.RefCylL),          // leftCylinder
            asInteger(r.RefAxL),          // leftAxis
            asNumber(r.AddL1),          // leftAdd
            asNumber(r.PrisL1),         // leftPrism
            cleanText(r.BaseL1),        // leftBase
            asNumber(r.PDDistL1),       // leftPd
            cleanText(r.VAL1),          // leftVa
            asNumber(r.PDDistA1),       // pd (binocular distance)
            null,                       // pdNear (not provided)
            null,                       // fittingHeight
            "DISTANCE",                // prescriptionType
            cleanText(r.Comments1),     // notes
            recommendations,            // recommendations
            createdAt,                  // createdAt
            updatedAt,                  // updatedAt
            additionalData,             // additionalData
            null,                       // branchId
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
            INSERT INTO "Prescription" (
              id, "tenantId", "customerId", "doctorId", "prescriptionDate", "validUntil",
              "rightSphere", "rightCylinder", "rightAxis", "rightAdd", "rightPrism", "rightBase",
              "rightPd", "rightVa", "leftSphere", "leftCylinder", "leftAxis", "leftAdd",
              "leftPrism", "leftBase", "leftPd", "leftVa", pd, "pdNear", "fittingHeight",
              "prescriptionType", notes, recommendations, "createdAt", "updatedAt", "additionalData",
              "branchId"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              "prescriptionDate" = EXCLUDED."prescriptionDate",
              "rightSphere" = EXCLUDED."rightSphere",
              "rightCylinder" = EXCLUDED."rightCylinder",
              "rightAxis" = EXCLUDED."rightAxis",
              "rightAdd" = EXCLUDED."rightAdd",
              "rightPrism" = EXCLUDED."rightPrism",
              "rightBase" = EXCLUDED."rightBase",
              "rightPd" = EXCLUDED."rightPd",
              "rightVa" = EXCLUDED."rightVa",
              "leftSphere" = EXCLUDED."leftSphere",
              "leftCylinder" = EXCLUDED."leftCylinder",
              "leftAxis" = EXCLUDED."leftAxis",
              "leftAdd" = EXCLUDED."leftAdd",
              "leftPrism" = EXCLUDED."leftPrism",
              "leftBase" = EXCLUDED."leftBase",
              "leftPd" = EXCLUDED."leftPd",
              "leftVa" = EXCLUDED."leftVa",
              pd = EXCLUDED.pd,
              "pdNear" = EXCLUDED."pdNear",
              "fittingHeight" = EXCLUDED."fittingHeight",
              "prescriptionType" = EXCLUDED."prescriptionType",
              notes = EXCLUDED.notes,
              recommendations = EXCLUDED.recommendations,
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

      lastId = rows[rows.length - 1].PrevId;
      console.log(`Prescriptions migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ Prescription migration completed. Total inserted/updated: ${total}`);
    if (skippedMissingCustomer) {
      console.warn(`⚠️ Skipped ${skippedMissingCustomer} prescriptions due to missing customers`);
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migratePrescription;
