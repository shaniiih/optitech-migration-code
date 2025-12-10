// main.js
require("dotenv").config();

const migrateBranch = require("./migrateBranch");
const migrateCity = require("./migrateCity");
const migrateWorkLab = require("./migrateWorkLab");
const migrateZipCode = require("./migrateZipCode");
const migrateZipcodeCity = require("./migrateZipcodeCity");
const migrateCheckType = require("./migrateCheckType");
const migrateCreditType = require("./migrateCreditType");
const migrateEye = require("./migrateEye");
const migratePrlType = require("./migratePrlType");
const migrateSolutionName = require("./migrateSolutionName");
const migrateSpecialName = require("./migrateSpecialName");
const migrateUser = require("./migrateUser");
const migrateCustomerGroup = require("./migrateCustomerGroup");
const migrateGroup = require("./migrateGroup");
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
const migrateFrmLabelTypes = require("./migrateFrmLabelTypes");
const migrateFrmModelTypes = require("./migrateFrmModelTypes");
const migrateFrmPrivColors = require("./migrateFrmPrivColors");
const migrateFrmColor = require("./migrateFrmColor");
const migrateCrdBuysWorkLab = require("./migrateCrdBuysWorkLab");
const migrateCrdBuysWorkSapak = require("./migrateCrdBuysWorkSapak");
const migrateCrdBuysWorkStat = require("./migrateCrdBuysWorkStat");
const migrateWorkStatus = require("./migrateWorkStatus");
const migrateCrdBuysWorkType = require("./migrateCrdBuysWorkType");
const migrateBisData = require("./migrateBisData");
const migrateWorkSupplier = require("./migrateWorkSupplier");
const migrateCrdBuysWorkSupply = require("./migrateCrdBuysWorkSupply");
const migrateCrdClensBrand = require("./migrateCrdClensBrand");
const migrateFRPLine = require("./migrateFRPLine");
const migrateLowVisionCheck = require("./migrateLowVisionCheck");
const migrateLowVisionFrame = require("./migrateLowVisionFrame");
const migrateLowVisionArea = require("./migrateLowVisionArea");
const migrateLowVisionCap = require("./migrateLowVisionCap");
const migrateLowVisionManufacturer = require("./migrateLowVisionManufacturer");
const migrateCrdLVArea = require("./migrateCrdLVArea");
const migrateCrdLVFrame = require("./migrateCrdLVFrame");
const migrateCrdLVManuf = require("./migrateCrdLVManuf");
const migrateCrdLVCap = require("./migrateCrdLVCap");
const migrateSupplier = require("./migrateSupplier");
const migrateSapakComment = require("./migrateSapakComment");
const migrateSapakDest = require("./migrateSapakDest");
const migrateInvoice = require("./migrateInvoice");
const migrateInvoicePay = require("./migrateInvoicePay");
const migrateInvoiceCredit = require("./migrateInvoiceCredit");
const migrateSMS = require("./migrateSMS");
const migrateFrmModelColor = require("./migrateFrmModelColor");
const migrateOpticalBase = require("./migrateOpticalBase");
const migrateSapakSendStat = require("./migrateSapakSendStat");
const migrateVAT = require("./migrateVAT");
const migrateContactLensTint = require("./migrateContactLensTint");
const migrateCrdClensChecksPr = require("./migrateCrdClensChecksPr");
const migrateCrdClensChecksMater = require("./migrateCrdClensChecksMater");
const migrateCrdClensChecksTint = require("./migrateCrdClensChecksTint");
const migrateCrdClensManuf = require("./migrateCrdClensManuf");
const migrateCrdClensSolRinse = require("./migrateCrdClensSolRinse");
const migrateCrdClensSolClean = require("./migrateCrdClensSolClean");
const migrateCrdClinicChar = require("./migrateCrdClinicChar");
const migrateCrdClensType = require("./migrateCrdClensType");
const migrateContactLensManufacturer = require("./migrateContactLensManufacturer");
const migrateContactLensDisinfectingSolution = require("./migrateContactLensDisinfectingSolution");
const migrateCrdClensSolDisinfect = require("./migrateCrdClensSolDisinfect");
const migrateContactLensRinsingSolution = require("./migrateContactLensRinsingSolution");
const migrateContactLensExamination = require("./migrateContactLensExamination");
const migrateClndrTasksPriority = require("./migrateClndrTasksPriority");
const migrateCLnsChar = require("./migrateCLnsChar");
const migrateCLnsType = require("./migrateCLnsType");
const migrateClndrApt = require("./migrateClndrApt");
const migrateProduct = require("./migrateProduct");
const migrateBarcodeManagement = require("./migrateBarcodeManagement");
const migrateBarCode = require("./migrateBarCode");
const migrateCrdBuysWorkLabel = require("./migrateCrdBuysWorkLabel");
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
const migrateCrdGlassRole = require("./migrateCrdGlassRole");
const migrateCrdGlassRetDist = require("./migrateCrdGlassRetDist");
const migrateCrdGlassRetType = require("./migrateCrdGlassRetType");
const migrateCrdGlassUse = require("./migrateCrdGlassUse");
const migrateMovementProperty = require("./migrateMovementProperty");
const migrateMovementType = require("./migrateMovementType");
const migrateCrdOrder = require("./migrateCrdOrder");
const migrateInvMoveProps = require("./migrateInvMoveProps");
const migrateInvMoveType = require("./migrateInvMoveType");
const migrateSapak = require("./migrateSapak");
const migrateCustomerPhoto = require("./migrateCustomerPhoto");
const migrateUserSettings = require("./migrateUserSettings");
const migrateProfile = require("./migrateProfile");
const migratePropsName = require("./migratePropsName");
const migrateRef = require("./migrateRef");
const migrateRefsSub1 = require("./migrateRefsSub1");
const migrateRefsSub2 = require("./migrateRefsSub2");
const migrateCreditCard = require("./migrateCreditCard");
const migrateDummy = require("./migrateDummy");
const migrateFixExpense = require("./migrateFixExpense");
const migrateFaxStat = require("./migrateFaxStat");
const migrateFax = require("./migrateFax");
const migratePerData = require("./migratePerData");
const migratePerPicture = require("./migratePerPicture");
const migrateReportDummy = require("./migrateReportDummy");
const migrateContact = require("./migrateContact");
const migrateContactAgent = require("./migrateContactAgent");
const migrateLetter = require("./migrateLetter");
const migrateServiceType = require("./migrateServiceType");
const migrateInvoiceType = require("./migrateInvoiceType");
const migratePayType = require("./migratePayType");
const migrateItemColor = require("./migrateItemColor");
const migrateItemsAdd = require("./migrateItemsAdd");
const migrateItemStat = require("./migrateItemStat");
const migrateItem = require("./migrateItem");
const migrateCLnsPrice = require("./migrateCLnsPrice");
const migrateLnsPrice = require("./migrateLnsPrice");
const migratePropsPrice = require("./migratePropsPrice");
const migrateFrmPrice = require("./migrateFrmPrice");
const migrateLnsTreatmen = require("./migrateLnsTreatmen");
const migrateLnsTreatRule = require("./migrateLnsTreatRule");
const migrateLabel = require("./migrateLabel");
const migrateLnsChar = require("./migrateLnsChar");
const migrateLnsTreatChar = require("./migrateLnsTreatChar");
const migrateLnsMaterial = require("./migrateLnsMaterial");
const migrateLnsTreatType = require("./migrateLnsTreatType");
const migrateLnsType = require("./migrateLnsType");
const migrateSearchOrder = require("./migrateSearchOrder");
const migrateSysLevel = require("./migrateSysLevel");
const migrateLang = require("./migrateLang");
const migrateShortCut = require("./migrateShortCut");
const migrateSMSLen = require("./migrateSMSLen");
const migrateCrdGlassIOPInst = require("./migrateCrdGlassIOPInst");
const migrateItemCountsYear = require("./migrateItemCountsYear");
const migrateCrdClinicFld = require("./migrateCrdClinicFld");
const migrateCrdGlassBrand = require("./migrateCrdGlassBrand");
const migrateCrdGlassChecksFrm = require("./migrateCrdGlassChecksFrm");
const migrateCrdGlassCoat = require("./migrateCrdGlassCoat");
const migrateCrdGlassColor = require("./migrateCrdGlassColor");
const migrateCrdGlassMater = require("./migrateCrdGlassMater");
const migrateCrdGlassModel = require("./migrateCrdGlassModel");
const migrateNewProd = require("./migrateNewProd");
const migrateOReport = require("./migrateOReport");
const migrateUReport = require("./migrateUReport");
const migrateSetting = require("./migrateSetting");
const { getPostgresConnection } = require("./dbConfig");
const { ensureTenantId, cleanTenantId } = require("./tenantUtils");
const migrateZipcodeStreet = require("./migrateZipcodeStreet");
const migrateZipcodeStreetsZipcode = require("./migrateZipcodeStreetsZipcode");
const migrateSapakPerComment = require("./migrateSapakPerComment");
const migrateSolutionPrice = require("./migrateSolutionPrice");
const migrateSpecial = require("./migrateSpecial");
const migrateItemCount = require("./migrateItemCount");
const migrateClndrSal = require("./migrateClndrSal");
const migrateClndrWrk = require("./migrateClndrWrk");
const migrateClndrWrkFD = require("./migrateClndrWrkFD");
const migrateClndrTasks = require("./migrateClndrTasks");
const migrateInventory = require("./migrateInventory");
const migrateCrdBuys = require("./migrateCrdBuys");
const migrateItemLines = require("./migrateItemLines");
const migrateInvoiceCheck = require("./migrateInvoiceCheck");
const migrateCrdBuysCatNum = require("./migrateCrdBuysCatNum");
const migrateCrdBuysPay = require("./migrateCrdBuysPay");
const migrateSapakSendsLensPlan = require("./migrateSapakSendsLensPlan");
const migrateCrdClinicCheck = require("./migrateCrdClinicCheck");
const migrateCrdDiag = require("./migrateCrdDiag");
const migrateCrdOrthok = require("./migrateCrdOrthok");
const migrateInvoicesInv = require("./migrateInvoicesInv");
const migrateCrdClensCheck = require("./migrateCrdClensCheck");
const migrateCrdDisDiag = require("./migrateCrdDisDiag");
const migrateCrdGlassCheck = require("./migrateCrdGlassCheck");
const migrateCrdGlassCheckGlassP = require("./migrateCrdGlassCheckGlassP");
const migrateCrdGlassChecksGlass = require("./migrateCrdGlassChecksGlass");
const { migrateCrdOverView } = require("./migrateCrdOverView");
const migrateLettersFollowup = require("./migrateLettersFollowup");
const migratePerLast = require("./migratePerLast");
const migrateCrdBuysCheck = require("./migrateCrdBuysCheck");
const migrateItemLineBuy = require("./migrateItemLineBuy");
const migrateCrdClensFit = require("./migrateCrdClensFit");
const migrateCrdFrp = require("./migrateCrdFrp");
const migrateCrdFrpLine = require("./migrateCrdFrpLine");
const migrateCrdGlassCheckPrev = require("./migrateCrdGlassCheckPrev");
const migrateCrdLVCheck = require("./migrateCrdLVCheck");
const migrateCrdBuyWork = require("./migrateCrdBuyWork");
const migrateFaxLine = require("./migrateFaxLine");


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
    await runStep("OpticalBase", () => migrateOpticalBase(tenantId, branchId)); // Verified
    await runStep("BisData", () => migrateBisData(tenantId, branchId)); // Verified
    await runStep("Branch", () => migrateBranch(tenantId)); // Verified
    await runStep("CheckType", () => migrateCheckType(tenantId, branchId)); // Verified
    await runStep("City", () => migrateCity(tenantId, branchId)); // Verified
    await runStep("Users", () => migrateUser(tenantId, branchId)); // Verified
    await runStep("ClndrTasksPriority", () => migrateClndrTasksPriority(tenantId, branchId)); // Verified
    await runStep("CLnsChar", () => migrateCLnsChar(tenantId, branchId)); // Verified
    await runStep("CLnsType", () => migrateCLnsType(tenantId, branchId)); // Verified
    await runStep("CrdBuysWorkLab", () => migrateCrdBuysWorkLab(tenantId, branchId)); // Verified
    await runStep("CrdBuysWorkSapak", () => migrateCrdBuysWorkSapak(tenantId, branchId)); // Verified
    await runStep("CrdBuysWorkStat", () => migrateCrdBuysWorkStat(tenantId, branchId)); // Verified
    await runStep("CrdBuysWorkSupply", () => migrateCrdBuysWorkSupply(tenantId, branchId)); // Verified
    await runStep("CrdClensBrand", () => migrateCrdClensBrand(tenantId, branchId)); // Verified
    await runStep("CrdClensChecksMater", () => migrateCrdClensChecksMater(tenantId, branchId)); // Verified
    await runStep("CrdClensChecksPr", () => migrateCrdClensChecksPr(tenantId, branchId)); // Verified
    await runStep("CrdClensChecksTint", () => migrateCrdClensChecksTint(tenantId, branchId)); // Verified
    await runStep("CrdClensManuf", () => migrateCrdClensManuf(tenantId, branchId)); // Verified
    await runStep("CrdClensSolDisinfect", () => migrateCrdClensSolDisinfect(tenantId, branchId)); // Verified
    await runStep("CrdClensSolRinse", () => migrateCrdClensSolRinse(tenantId, branchId)); // Verified
    await runStep("CrdClensType", () => migrateCrdClensType(tenantId, branchId)); // Verified
    await runStep("CrdClinicFld", () => migrateCrdClinicFld(tenantId, branchId)); // Verified
    await runStep("CrdGlassBrand", () => migrateCrdGlassBrand(tenantId, branchId)); // Verified
    await runStep("CrdGlassChecksFrm", () => migrateCrdGlassChecksFrm(tenantId, branchId)); // Verified (No data present in old DB)
    await runStep("CrdGlassCoat", () => migrateCrdGlassCoat(tenantId, branchId)); // Verified
    await runStep("CrdGlassColor", () => migrateCrdGlassColor(tenantId, branchId)); // Verified
    await runStep("CrdGlassMater", () => migrateCrdGlassMater(tenantId, branchId)); // Verified
    await runStep("CrdGlassModel", () => migrateCrdGlassModel(tenantId, branchId)); // Verified
    await runStep("CrdGlassRetDist", () => migrateCrdGlassRetDist(tenantId, branchId)); // Verified
    await runStep("CrdGlassRetType", () => migrateCrdGlassRetType(tenantId, branchId)); // Verified
    await runStep("CrdGlassRole", () => migrateCrdGlassRole(tenantId, branchId)); // Verified
    await runStep("CrdLVArea", () => migrateCrdLVArea(tenantId, branchId)); // Verified
    await runStep("CrdLVFrame", () => migrateCrdLVFrame(tenantId, branchId)); // Verified
    await runStep("CrdGlassUse", () => migrateCrdGlassUse(tenantId, branchId)); // Verified
    await runStep("CrdLVManuf", () => migrateCrdLVManuf(tenantId, branchId)); // Verified
    await runStep("CrdOrder", () => migrateCrdOrder(tenantId, branchId)); // Verified
    await runStep("CreditType", () => migrateCreditType(tenantId, branchId)); // Verified
    await runStep("Discount", () => migrateDiscount(tenantId, branchId)); // Verified
    await runStep("Dummy", () => migrateDummy(tenantId, branchId)); // Verified
    await runStep("Eye", () => migrateEye(tenantId, branchId)); // Verified
    await runStep("FixExpense", () => migrateFixExpense(tenantId, branchId)); // Verified
    await runStep("FrmLabelType", () => migrateFrmLabelTypes(tenantId, branchId)); // Verified
    await runStep("FrmModelType", () => migrateFrmModelTypes(tenantId, branchId)); // Verified
    await runStep("FrmPrivColor", () => migrateFrmPrivColors(tenantId, branchId)); // Verified
    await runStep("InvMoveProp", () => migrateInvMoveProps(tenantId, branchId)); // Verified
    await runStep("InvMoveType", () => migrateInvMoveType(tenantId, branchId)); // Verified
    await runStep("InvoiceType", () => migrateInvoiceType(tenantId, branchId)); // Verified
    await runStep("ItemColor", () => migrateItemColor(tenantId, branchId)); // Verified
    await runStep("ItemsAdd", () => migrateItemsAdd(tenantId, branchId));
    await runStep("Label", () => migrateLabel(tenantId, branchId)); // Verified
    await runStep("Lang", () => migrateLang(tenantId, branchId)); // Verified
    await runStep("LnsChar", () => migrateLnsChar(tenantId, branchId)); // Verified
    await runStep("LnsMaterial", () => migrateLnsMaterial(tenantId, branchId)); // Verified
    await runStep("LnsTreatChar", () => migrateLnsTreatChar(tenantId, branchId)); // Verified
    await runStep("LnsTreatType", () => migrateLnsTreatType(tenantId, branchId));
    await runStep("LnsTreatRule", () => migrateLnsTreatRule(tenantId, branchId));
    // #tblLnsTreatTypesConnect
    await runStep("LnsType", () => migrateLnsType(tenantId, branchId)); // Verified
    await runStep("NewProd", () => migrateNewProd(tenantId, branchId)); // Verified
    await runStep("OReport", () => migrateOReport(tenantId, branchId)); // Verified
    await runStep("PrlType", () => migratePrlType(tenantId, branchId)); // Verified
    await runStep("Profile", () => migrateProfile(tenantId, branchId)); // Verified
    await runStep("PropsName", () => migratePropsName(tenantId, branchId)); // Verified
    await runStep("Ref", () => migrateRef(tenantId, branchId)); // Verified
    await runStep("RefsSub1", () => migrateRefsSub1(tenantId, branchId)); // Verified
    await runStep("RefsSub2", () => migrateRefsSub2(tenantId, branchId)); // Verified
    await runStep("SysLevel", () => migrateSysLevel(tenantId, branchId)); // Verified
    await runStep("Sapak", () => migrateSapak(tenantId, branchId)); // Verified
    // #tblReportDummy
    await runStep("SapakSendStat", () => migrateSapakSendStat(tenantId, branchId)); // Verified
    // #tblSearchOrder
    await runStep("SearchOrder", () => migrateSearchOrder(tenantId, branchId)); // Verified
    await runStep("ServiceType", () => migrateServiceType(tenantId, branchId)); // Verified
    await runStep("ShortCut", () => migrateShortCut(tenantId, branchId));  // Verified
    await runStep("SMS", () => migrateSMS(tenantId, branchId)); // Verified
    await runStep("SMSLen", () => migrateSMSLen(tenantId, branchId));  // Verified
    await runStep("SolutionName", () => migrateSolutionName(tenantId, branchId)); // Verified
    await runStep("SpecialName", () => migrateSpecialName(tenantId, branchId)); // Verified
    await runStep("UReport", () => migrateUReport(tenantId, branchId)); // Verified
    await runStep("VAT", () => migrateVAT(tenantId, branchId)); // Verified
    await runStep("BarCode", () => migrateBarCode(tenantId, branchId)); // Verified
    await runStep("CrdBuysWorkType", () => migrateCrdBuysWorkType(tenantId, branchId)); // Verified
    await runStep("CrdClensSolClean", () => migrateCrdClensSolClean(tenantId, branchId)); // Verified
    await runStep("CrdClinicChar", () => migrateCrdClinicChar(tenantId, branchId)); // Verified
    await runStep("CrdGlassIOPInst", () => migrateCrdGlassIOPInst(tenantId, branchId)); // Verified
    await runStep("CrdLVCap", () => migrateCrdLVCap(tenantId, branchId)); // Verified
    await runStep("CreditCard", () => migrateCreditCard(tenantId, branchId)); // Verified
    await runStep("FaxStat", () => migrateFaxStat(tenantId, branchId)); // Verified
    await runStep("ItemCountsYear", () => migrateItemCountsYear(tenantId, branchId)); // Verified
    await runStep("Letter", () => migrateLetter(tenantId, branchId)); // Verified
    await runStep("PayType", () => migratePayType(tenantId, branchId)); // Verified
    await runStep("Setting", () => migrateSetting(tenantId, branchId)); // Verified
    await runStep("ZipcodeCity", () => migrateZipcodeCity(tenantId, branchId)); // Verified
    await runStep("ZipcodeStreet", () => migrateZipcodeStreet(tenantId, branchId)); // Verified
    await runStep("ZipcodeStreetsZipcode", () => migrateZipcodeStreetsZipcode(tenantId, branchId)); // Verified
    await runStep("Contact", () => migrateContact(tenantId, branchId)); // Verified
    await runStep("CrdBuysWorkLabel", () => migrateCrdBuysWorkLabel(tenantId, branchId)); // Verified
    await runStep("Group", () => migrateGroup(tenantId, branchId)); // Verified
    await runStep("FrmColor", () => migrateFrmColor(tenantId, branchId)); // Verified
    await runStep("ItemStat", () => migrateItemStat(tenantId, branchId)); // Verified
    await runStep("Item", () => migrateItem(tenantId, branchId)); // Verified
    await runStep("CLnsPrice", () => migrateCLnsPrice(tenantId, branchId)); // Verified
    await runStep("LnsPrice", () => migrateLnsPrice(tenantId, branchId)); // Verified
    await runStep("LnsTreatmen", () => migrateLnsTreatmen(tenantId, branchId)); // Verified
    await runStep("PropsPrice", () => migratePropsPrice(tenantId, branchId)); // Verified
    await runStep("FrmPrice", () => migrateFrmPrice(tenantId, branchId)); // Verified
    await runStep("SapakComment", () => migrateSapakComment(tenantId, branchId)); // Verified
    await runStep("SapakDest", () => migrateSapakDest(tenantId, branchId)); // Verified
    await runStep("SapakPerComment", () => migrateSapakPerComment(tenantId, branchId)); // Verified
    await runStep("SolutionPrice", () => migrateSolutionPrice(tenantId, branchId)); // Verified
    await runStep("Special", () => migrateSpecial(tenantId, branchId)); // Verified
    await runStep("InvoicePay", () => migrateInvoicePay(tenantId, branchId)); // Verified
    await runStep("ContactAgent", () => migrateContactAgent(tenantId, branchId)); // Verified
    await runStep("Fax", () => migrateFax(tenantId, branchId)); // Verified
    await runStep("PerData", () => migratePerData(tenantId, branchId)); // Verified
    await runStep("ReportDummy", () => migrateReportDummy(tenantId, branchId)); // Verified
    // #tblFrmModelColors
    await runStep("ItemCount", () => migrateItemCount(tenantId, branchId));  // Verified
    await runStep("ClndrSal", () => migrateClndrSal(tenantId, branchId)); // Verified
    await runStep("ClndrApt", () => migrateClndrApt(tenantId, branchId)); // Verified
    await runStep("ClndrWrk", () => migrateClndrWrk(tenantId, branchId)); // Verified
    await runStep("ClndrWrkFD", () => migrateClndrWrkFD(tenantId, branchId)); // Verified
    await runStep("Inventory", () => migrateInventory(tenantId, branchId)); // Verified
    await runStep("PerPicture", () => migratePerPicture(tenantId, branchId)); // Verified
    await runStep("ItemLine", () => migrateItemLines(tenantId, branchId)); // Verified
    await runStep("Invoice", () => migrateInvoice(tenantId, branchId)); // Verified
    await runStep("InvoiceCheck", () => migrateInvoiceCheck(tenantId, branchId)); // Verified
    await runStep("FrmModelColor", () => migrateFrmModelColor(tenantId, branchId));
    await runStep("CrdBuysCatNum", () => migrateCrdBuysCatNum(tenantId, branchId)); // Verified
    await runStep("CrdBuysPay", () => migrateCrdBuysPay(tenantId, branchId)); // Verifies
    await runStep("CrdClinicCheck", () => migrateCrdClinicCheck(tenantId, branchId)); //Verified
    await runStep("InvoicesInv", () => migrateInvoicesInv(tenantId, branchId)); // Verified
    await runStep("CrdClensCheck", () => migrateCrdClensCheck(tenantId, branchId)); // Verified
    await runStep("CrdDiag", () => migrateCrdDiag(tenantId, branchId)); // Verified
    await runStep("ClndrTasks", () => migrateClndrTasks(tenantId, branchId)); // Verified
    await runStep("CrdDisDiag", () => migrateCrdDisDiag(tenantId, branchId)); // Verified
    await runStep("CrdGlassCheck", () => migrateCrdGlassCheck(tenantId, branchId)); // Verified
    await runStep("CrdBuys", () => migrateCrdBuys(tenantId, branchId)); // Verified
    await runStep("CrdGlassCheckGlassP", () => migrateCrdGlassCheckGlassP(tenantId, branchId)); // Verified
    await runStep("CrdGlassChecksGlass", () => migrateCrdGlassChecksGlass(tenantId, branchId));
    await runStep("CrdBuyWork", () => migrateCrdBuyWork(tenantId, branchId)); // Verified
    // #tblSapakSends
    await runStep("SapakSendsLensPlan", () => migrateSapakSendsLensPlan(tenantId, branchId)); // Verified
    await runStep("FaxLine", () => migrateFaxLine(tenantId, branchId)); // Verified
    await runStep("InvoiceCredit", () => migrateInvoiceCredit(tenantId, branchId)); // Verified
    await runStep("CrdFrp", () => migrateCrdFrp(tenantId, branchId)); // Verified
    await runStep("CrdOverView", () => migrateCrdOverView(tenantId, branchId)); // Verified
    await runStep("LettersFollowup", () => migrateLettersFollowup(tenantId, branchId)); // Verified
    await runStep("PerLast", () => migratePerLast(tenantId, branchId)); // Verified
    await runStep("CrdBuysCheck", () => migrateCrdBuysCheck(tenantId, branchId)); // Verified
    await runStep("ItemLineBuy", () => migrateItemLineBuy(tenantId, branchId)); // Verified
    await runStep("CrdClensFit", () => migrateCrdClensFit(tenantId, branchId)); // Verified
    await runStep("CrdFrpLine", () => migrateCrdFrpLine(tenantId, branchId)); // Verified
    await runStep("CrdGlassCheckPrev", () => migrateCrdGlassCheckPrev(tenantId, branchId)); // Verified
    await runStep("CrdLVCheck", () => migrateCrdLVCheck(tenantId, branchId)); // Verified
    await runStep("CrdOrthok", () => migrateCrdOrthok(tenantId, branchId)); // Verified


    /* // await runStep("WorkLab", () => migrateWorkLab(tenantId)); // Verified
     await runStep("ZipCode", () => migrateZipCode(tenantId)); // Verified
     await runStep("Supplier", () => migrateSupplier(tenantId)); // Verified
     await runStep("Users", () => migrateUser(tenantId)); // Verified
     await runStep("CustomerGroup", () => migrateCustomerGroup(tenantId, branchId)); // Verified
     await runStep("Customer", () => migrateCustomer(tenantId)); // Verified
     //await runStep("Examination", () => migrateExamination(tenantId));
     //await runStep("ClinicalExamination", () => migrateClinicalExamination(tenantId));
     //await runStep("ContactLensFittingDetail", () => migrateContactLensFittingDetail(tenantId));
     await runStep("Brand", () => migrateBrand(tenantId)); // Verified
     //await runStep("LowVisionFrame", () => migrateLowVisionFrame(tenantId));
     //await runStep("LowVisionCheck", () => migrateLowVisionCheck(tenantId));
     //await runStep("Invoice", () => migrateInvoice(tenantId));
     await runStep("Appointment", () => migrateAppointment(tenantId)); // Verified
     await runStep("ClndrWrk", () => migrateClndrWrk(tenantId, branchId)); // Verified
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
     // await runStep("ContactLensMaterial", () => migrateContactLensMaterial(tenantId)); // Verified
     await runStep("GlassModel", () => migrateGlassModel(tenantId)); // Verified
     await runStep("LensType", () => migrateLensType(tenantId)); // Verified
     await runStep("ContactLensCleaningSolution", () => migrateContactLensCleaningSolution(tenantId)); // Verified
     
     // await runStep("ContactLensTint", () => migrateContactLensTint(tenantId)); //  Verified
     await runStep("ContactLensManufacturer", () => migrateContactLensManufacturer(tenantId)); // Verified
     // await runStep("ContactLensDisinfectingSolution", () => migrateContactLensDisinfectingSolution(tenantId)); // Verified
     // await runStep("ContactLensRinsingSolution", () => migrateContactLensRinsingSolution(tenantId));  // Verified
     //await runStep("ContactLensType", () => migrateContactLensType(tenantId)); // Verified
     await runStep("ContactLensExamination", () => migrateContactLensExamination(tenantId, branchId)); // Verified
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
     await runStep("UserSettings", () => migrateUserSettings(tenantId, branchId)); // Verified
     await runStep("GlassMaterial", () => migrateGlassMaterial(tenantId)); // Verified
     await runStep("Diagnosis", () => migrateDiagnosis(tenantId)); // Verified
     await runStep("OrthokeratologyTreatment", () => migrateOrthokeratologyTreatment(tenantId)); // Verified
     await runStep("SysLevel", () => migrateSysLevel(tenantId, branchId)); // Verified
     await runStep("CustomerPhoto", () => migrateCustomerPhoto(tenantId, branchId)); // Verified
     */
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
