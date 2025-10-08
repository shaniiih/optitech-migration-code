// main.js
require("dotenv").config();

const migrateBranch = require("./migrateBranch");
const migrateCity = require("./migrateCity"); 
const migrateWorkLab = require("./migrateWorkLab");
const migrateZipCode = require("./migrateZipCode");
const migrateInvoiceCredits = require("./migrateInvoiceCredits");
const migrateContactAgents = require("./migrateContactAgents");
const migrateCheckType = require("./migrateCheckType");
const migrateUser = require("./migrateUser");
const migrateCustomer = require("./migrateCustomer");
const migrateDiscount = require("./migrateDiscount");
const migrateCustomerGroup = require("./migrateCustomerGroup");
const migrateCustomerPhoto = require("./migrateCustomerPhoto");
const migrateExamination = require("./migrateExamination");
const migratePrescription = require("./migratePrescription");
const migrateAppointment = require("./migrateAppointment");
const migrateClinicalExamination = require("./migrateClinicalExamination");
const migrateContactLensPrescription = require("./migrateContactLensPrescription");
const migrateContactLensFittingDetail = require("./migrateContactLensFittingDetail");
const migrateBrand = require("./migrateBrand");
const migrateContactLensType = require("./migrateContactLensType");
const migrateContactLensMaterial = require("./migrateContactLensMaterial");
const migrateContactLensCleaningSolution = require("./migrateContactLensCleaningSolution");
const migrateGlassModel = require("./migrateGlassModel");
const migrateLensType = require("./migrateLensType");
const migrateGlassPrescriptionDetail = require("./migrateGlassPrescriptionDetail");
const migrateLensCharacteristic = require("./migrateLensCharacteristic");
const migrateLensCatalog = require("./migrateLensCatalog");
const migrateLensTreatmentCharacteristic = require("./migrateLensTreatmentCharacteristic");
const migrateExaminationOverview = require("./migrateExaminationOverview");
const migrateWorkLabel = require("./migrateWorkLabel");
const migrateWorkSupplier = require("./migrateWorkSupplier");
const migrateFRPLine = require("./migrateFRPLine");
const migrateFrequentReplacementProgram = require("./migrateFrequentReplacementProgram");
const migrateOrthokeratology = require("./migrateOrthokeratology");
const migrateLowVisionCheck = require("./migrateLowVisionCheck");
const migrateSale = require("./migrateSale");
const migrateSaleItem = require("./migrateSaleItem");
const migrateOrder = require("./migrateOrder");
const migratePayment = require("./migratePayment");
const migrateStockMovement = require("./migrateStockMovement");
const migrateSupplier = require("./migrateSupplier");
const migrateInvoice = require("./migrateInvoice");
const migrateSMS = require("./migrateSMS");
const migrateOpticalBase = require("./migrateOpticalBase");
const migrateContactLensTint = require("./migrateContactLensTint");
const migrateContactLensManufacturer = require("./migrateContactLensManufacturer");
const migrateContactLensDisinfectingSolution = require("./migrateContactLensDisinfectingSolution");
const migrateContactLensRinsingSolution = require("./migrateContactLensRinsingSolution");
const migrateProduct = require("./migrateProduct");
const migratePurchase = require("./migratePurchase");
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
    await runStep("InvoiceCredits", () => migrateInvoiceCredits(tenantId)); // Verified
    await runStep("CheckType", () => migrateCheckType(tenantId)); // Verified
    await runStep("Supplier", () => migrateSupplier(tenantId)); // Verified
    await runStep("Users", () => migrateUser(tenantId)); // Verified
    await runStep("CustomerGroup", () => migrateCustomerGroup(tenantId)); // Verified
    await runStep("Customer", () => migrateCustomer(tenantId)); // Verified
    // await runStep("ContactAgents", () => migrateContactAgents(tenantId)); // (Not found reference to tblContacts table in postgresql )
    await runStep("Examination", () => migrateExamination(tenantId));
    await runStep("ClinicalExamination", () => migrateClinicalExamination(tenantId));
    await runStep("ContactLensPrescription", () => migrateContactLensPrescription(tenantId)); // Verified
    await runStep("ContactLensFittingDetail", () => migrateContactLensFittingDetail(tenantId));
    await runStep("Brand", () => migrateBrand(tenantId)); // Verified
    await runStep("FrequentReplacementProgram", () => migrateFrequentReplacementProgram(tenantId));
    await runStep("Orthokeratology", () => migrateOrthokeratology(tenantId));
    await runStep("LowVisionCheck", () => migrateLowVisionCheck(tenantId));
    await runStep("Sale", () => migrateSale(tenantId)); // Verified
    await runStep("SaleItem", () => migrateSaleItem(tenantId)); // Verified
    await runStep("Order", () => migrateOrder(tenantId));
    await runStep("Payment", () => migratePayment(tenantId));
    await runStep("StockMovement", () => migrateStockMovement(tenantId)); // Done
    await runStep("Invoice", () => migrateInvoice(tenantId));
    await runStep("SMS", () => migrateSMS(tenantId));
    await runStep("Prescription", () => migratePrescription(tenantId)); // Verified
    await runStep("Appointment", () => migrateAppointment(tenantId)); // Verified
    await runStep("ClinicalExamination", () => migrateClinicalExamination(tenantId));
    await runStep("ContactLensFittingDetail", () => migrateContactLensFittingDetail(tenantId));
    await runStep("FrequentReplacementProgram", () => migrateFrequentReplacementProgram(tenantId));
    await runStep("Orthokeratology", () => migrateOrthokeratology(tenantId));
    await runStep("FRPLine", () => migrateFRPLine(tenantId));
    await runStep("LowVisionCheck", () => migrateLowVisionCheck(tenantId));
    await runStep("Invoice", () => migrateInvoice(tenantId));
    await runStep("Discount", () => migrateDiscount(tenantId));
    await runStep("CustomerPhoto", () => migrateCustomerPhoto(tenantId)); // Verified
    await runStep("ExaminationOverview", () => migrateExaminationOverview(tenantId)); // Verified
    await runStep("GlassPrescriptionDetail", () => migrateGlassPrescriptionDetail(tenantId)); // Verified
    await runStep("LensCharacteristic", () => migrateLensCharacteristic(tenantId));
    await runStep("LensCatalog", () => migrateLensCatalog(tenantId));
    await runStep("LensTreatmentCharacteristic", () => migrateLensTreatmentCharacteristic(tenantId));
    await runStep("WorkLabel", () => migrateWorkLabel(tenantId)); // Verified
    await runStep("WorkSupplier", () => migrateWorkSupplier(tenantId)); // Verified
    await runStep("ContactLensType", () => migrateContactLensType(tenantId)); // Verified
    await runStep("ContactLensMaterial", () => migrateContactLensMaterial(tenantId)); // Verified
    await runStep("GlassModel", () => migrateGlassModel(tenantId)); // Verified
    await runStep("LensType", () => migrateLensType(tenantId)); // Verified
    await runStep("ContactLensCleaningSolution", () => migrateContactLensCleaningSolution(tenantId)); // Verified
    await runStep("OpticalBase", () => migrateOpticalBase(tenantId)); // Verified
    await runStep("ContactLensTint", () => migrateContactLensTint(tenantId)); //  Verified
    await runStep("ContactLensManufacturer", () => migrateContactLensManufacturer(tenantId)); // Verified
    await runStep("ContactLensDisinfectingSolution", () => migrateContactLensDisinfectingSolution(tenantId)); // Verified
    await runStep("ContactLensRinsingSolution", () => migrateContactLensRinsingSolution(tenantId));  // Verified
    await runStep("Purchase", () => migratePurchase(tenantId)); // Verified
    await runStep("Product", () => migrateProduct(tenantId)); // Verified
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
