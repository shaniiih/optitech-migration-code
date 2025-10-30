// main.js
require("dotenv").config();

const migrateBranch = require("./migrateBranch");
const migrateCity = require("./migrateCity"); 
const migrateWorkLab = require("./migrateWorkLab");
const migrateZipCode = require("./migrateZipCode");
const migrateContactAgents = require("./migrateContactAgents");
const migrateCheckType = require("./migrateCheckType");
const migrateUser = require("./migrateUser");
const migrateCustomerGroup = require("./migrateCustomerGroup");
const migrateCustomer = require("./migrateCustomer");
const migrateDiscount = require("./migrateDiscount");
const migrateExamination = require("./migrateExamination");
const migrateAppointment = require("./migrateAppointment");
const migrateClinicalExamination = require("./migrateClinicalExamination");
const migrateContactLensFittingDetail = require("./migrateContactLensFittingDetail");
const migrateBrand = require("./migrateBrand");
const migrateContactLensMaterial = require("./migrateContactLensMaterial");
const migrateContactLensCleaningSolution = require("./migrateContactLensCleaningSolution");
const migrateGlassModel = require("./migrateGlassModel");
const migrateLensType = require("./migrateLensType");
const migrateGlassPrescriptionDetail = require("./migrateGlassPrescriptionDetail");
const migrateLensCharacteristic = require("./migrateLensCharacteristic");
const migrateLensMaterial = require("./migrateLensMaterial");
const migrateLensTreatmentCharacteristic = require("./migrateLensTreatmentCharacteristic");
const migrateExaminationOverview = require("./migrateExaminationOverview");
const migrateWorkLabel = require("./migrateWorkLabel");
const migrateWorkStatus = require("./migrateWorkStatus");
const migrateWorkSupplier = require("./migrateWorkSupplier");
const migrateFRPLine = require("./migrateFRPLine");
const migrateLowVisionCheck = require("./migrateLowVisionCheck");
const migrateLowVisionFrame = require("./migrateLowVisionFrame");
const migrateLowVisionArea = require("./migrateLowVisionArea");
const migrateLowVisionCap = require("./migrateLowVisionCap");
const migrateLowVisionManufacturer = require("./migrateLowVisionManufacturer");
const migrateSupplier = require("./migrateSupplier");
const migrateInvoice = require("./migrateInvoice");
const migrateSMS = require("./migrateSMS");
const migrateOpticalBase = require("./migrateOpticalBase");
const migrateContactLensTint = require("./migrateContactLensTint");
const migrateContactLensManufacturer = require("./migrateContactLensManufacturer");
const migrateContactLensDisinfectingSolution = require("./migrateContactLensDisinfectingSolution");
const migrateContactLensRinsingSolution = require("./migrateContactLensRinsingSolution");
const migrateProduct = require("./migrateProduct");
const migrateBarcodeManagement = require("./migrateBarcodeManagement");
const migrateDetailedWorkOrder = require("./migrateDetailedWorkOrder");
const migrateFrameTrial = require("./migrateFrameTrial");
const migrateGlassMaterial = require("./migrateGlassMaterial");
const migratePurchase = require("./migratePurchase");
const migrateDiagnosis = require("./migrateDiagnosis");
const migrateOrthokeratologyTreatment = require("./migrateOrthokeratologyTreatment");
const migrateContactLensType = require("./migrateContactLensType");
const migrateDiagnosticProtocol = require("./migrateDiagnosticProtocol");
const migrateGlassCoating = require("./migrateGlassCoating");
const migrateGlassColor = require("./migrateGlassColor");
const migrateGlassRole = require("./migrateGlassRole");
const migrateMovementProperty = require("./migrateMovementProperty");
const migrateMovementType = require("./migrateMovementType");
const migrateCustomerPhoto = require("./migrateCustomerPhoto");
const { getPostgresConnection } = require("./dbConfig");
const { ensureTenantId, cleanTenantId } = require("./tenantUtils");

// ---- utils ---------------------------------------------------------------
function now() { return new Date().toISOString(); }

async function runStep(label, fn) {
  const t0 = Date.now();
  console.log(`[${now()}] ▶ ${label} - started`);
  await fn();
  const ms = Date.now() - t0;
  console.log(`[${now()}] ✅ ${label} - done in ${ms.toLocaleString()} ms`);
}

// Ensure a tenant exists before running per-tenant migrations
async function ensureTenant(tenantId) {
  const pg = await getPostgresConnection();
  try {
    const res = await pg.query(`SELECT id FROM "Tenant" WHERE id = $1`, [tenantId]);
    if (res.rows.length === 0) {
      console.log(`[${now()}] ⚠️ Tenant ${tenantId} not found. Creating...`);
      await pg.query(
        `INSERT INTO "Tenant" (id, name, subdomain, "createdAt", "updatedAt")
         VALUES ($1, $2, $3, NOW(), NOW())`,
        [tenantId, "Default Tenant", `${tenantId}.example.com`]
      );
      console.log(`[${now()}] ✅ Tenant ${tenantId} created`);
    } else {
      console.log(`[${now()}] ✅ Tenant ${tenantId} already exists`);
    }
  } finally {
    await pg.end();
  }
}

// ---- main runner ---------------------------------------------------------
(async () => {
  try {
    const rawTenantId = process.env.TENANT_ID;
    const tenantId = ensureTenantId(rawTenantId);
    const branchId =
      process.env.BRANCH_ID && process.env.BRANCH_ID.trim()
        ? process.env.BRANCH_ID.trim()
        : null;
    if (branchId) {
      console.log(`[${now()}] Using BRANCH_ID: ${branchId}`);
    } else {
      console.log(`[${now()}] ⚠️ BRANCH_ID not provided; branch-scoped migrations will default to null`);
    }
    if (rawTenantId && cleanTenantId(rawTenantId) !== rawTenantId) {
      console.log(
        `[${now()}] ℹ️ Normalized TENANT_ID from '${rawTenantId}' to '${tenantId}'`
      );
    }

    console.log(`[${now()}] 🚀 Starting migrations for tenant: ${tenantId}`);

    await runStep("Ensure tenant", () => ensureTenant(tenantId));

    // Order matters if there are FKs/assumptions; this keeps your current sequence.
    await runStep("Branch", () => migrateBranch(tenantId)); // Verified
    await runStep("City", () => migrateCity(tenantId)); // Verified
    await runStep("WorkLab", () => migrateWorkLab(tenantId)); // Verified
    await runStep("ZipCode", () => migrateZipCode(tenantId)); // Verified
    await runStep("CheckType", () => migrateCheckType(tenantId)); // Verified
    await runStep("Supplier", () => migrateSupplier(tenantId)); // Verified
    await runStep("Discount", () => migrateDiscount(tenantId, branchId)); // Verified
    await runStep("Users", () => migrateUser(tenantId)); // Verified
    await runStep("CustomerGroup", () => migrateCustomerGroup(tenantId, branchId)); // Verified
    await runStep("Customer", () => migrateCustomer(tenantId)); // Verified
    await runStep("ContactAgents", () => migrateContactAgents(tenantId)); // (Not found reference to tblContacts table in postgresql )
    //await runStep("Examination", () => migrateExamination(tenantId));
    //await runStep("ClinicalExamination", () => migrateClinicalExamination(tenantId));
    //await runStep("ContactLensFittingDetail", () => migrateContactLensFittingDetail(tenantId));
    await runStep("Brand", () => migrateBrand(tenantId)); // Verified
    //await runStep("LowVisionFrame", () => migrateLowVisionFrame(tenantId));
    //await runStep("LowVisionCheck", () => migrateLowVisionCheck(tenantId));
    //await runStep("Invoice", () => migrateInvoice(tenantId));
    //await runStep("SMS", () => migrateSMS(tenantId));
    await runStep("Appointment", () => migrateAppointment(tenantId)); // Verified
    //await runStep("ClinicalExamination", () => migrateClinicalExamination(tenantId));
    //await runStep("ContactLensFittingDetail", () => migrateContactLensFittingDetail(tenantId));
    //await runStep("FRPLine", () => migrateFRPLine(tenantId));
    //await runStep("LowVisionCheck", () => migrateLowVisionCheck(tenantId));
    //await runStep("Invoice", () => migrateInvoice(tenantId));
    await runStep("ExaminationOverview", () => migrateExaminationOverview(tenantId)); // Verified
    await runStep("GlassPrescriptionDetail", () => migrateGlassPrescriptionDetail(tenantId)); // Verified
    //await runStep("LensCharacteristic", () => migrateLensCharacteristic(tenantId));
    //await runStep("LensTreatmentCharacteristic", () => migrateLensTreatmentCharacteristic(tenantId));
    await runStep("WorkLabel", () => migrateWorkLabel(tenantId)); // Verified
    await runStep("WorkStatus", () => migrateWorkStatus(tenantId)); // Verified
    await runStep("WorkSupplier", () => migrateWorkSupplier(tenantId)); // Verified
    await runStep("ContactLensMaterial", () => migrateContactLensMaterial(tenantId)); // Verified
    await runStep("GlassModel", () => migrateGlassModel(tenantId)); // Verified
    await runStep("LensType", () => migrateLensType(tenantId)); // Verified
    await runStep("ContactLensCleaningSolution", () => migrateContactLensCleaningSolution(tenantId)); // Verified
    await runStep("OpticalBase", () => migrateOpticalBase(tenantId)); // Verified
    await runStep("ContactLensTint", () => migrateContactLensTint(tenantId)); //  Verified
    await runStep("ContactLensManufacturer", () => migrateContactLensManufacturer(tenantId)); // Verified
    await runStep("ContactLensDisinfectingSolution", () => migrateContactLensDisinfectingSolution(tenantId)); // Verified
    await runStep("ContactLensRinsingSolution", () => migrateContactLensRinsingSolution(tenantId));  // Verified
    await runStep("ContactLensType", () => migrateContactLensType(tenantId)); // Verified
    await runStep("DiagnosticProtocol", () => migrateDiagnosticProtocol(tenantId)); // Verified
    await runStep("Purchase", () => migratePurchase(tenantId)); // Verified
    await runStep("Product", () => migrateProduct(tenantId)); // Verified
    await runStep("LensMaterial", () => migrateLensMaterial(tenantId)); // Verified
    // await runStep("BarcodeManagement", () => migrateBarcodeManagement(tenantId));
    //await runStep("DetailedWorkOrder", () => migrateDetailedWorkOrder(tenantId));
    await runStep("FrameTrial", () => migrateFrameTrial(tenantId)); // Verified
    await runStep("LowVisionManufacturer", () => migrateLowVisionManufacturer(tenantId)); // Verified
    await runStep("LowVisionCap", () => migrateLowVisionCap(tenantId)); // Verified
    await runStep("LowVisionArea", () => migrateLowVisionArea(tenantId)); // Verified
    await runStep("GlassColor", () => migrateGlassColor(tenantId)); // Verified
    await runStep("GlassRole", () => migrateGlassRole(tenantId)); // Verified
    await runStep("MovementType", () => migrateMovementType(tenantId, branchId)); // Verified
    await runStep("MovementProperty", () => migrateMovementProperty(tenantId, branchId)); // Verified
    await runStep("GlassCoating", () => migrateGlassCoating(tenantId)); // Verified
    await runStep("GlassMaterial", () => migrateGlassMaterial(tenantId)); // Verified
    await runStep("Diagnosis", () => migrateDiagnosis(tenantId)); // Verified
    await runStep("OrthokeratologyTreatment", () => migrateOrthokeratologyTreatment(tenantId)); // Verified
    await runStep("CustomerPhoto", () => migrateCustomerPhoto(tenantId, branchId)); // Verified
    console.log(`[${now()}] 🎉 All migrations completed successfully!`);
    process.exit(0);
  } catch (err) {
    console.error(`[${now()}] ❌ Migration failed:`, err);
    process.exit(1);
  }
})();

// Optional: catch unhandled rejections thrown outside awaited code
process.on("unhandledRejection", (reason) => {
  console.error(`[${now()}] 🚨 Unhandled Rejection:`, reason);
  process.exit(1);
});
