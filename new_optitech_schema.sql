--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: AdvancedExamination; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."AdvancedExamination" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "customerId" text NOT NULL,
    "examinationId" text,
    "examDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "examinerId" text NOT NULL,
    "autorefSphereOD" double precision,
    "autorefCylinderOD" double precision,
    "autorefAxisOD" integer,
    "autorefSphereOS" double precision,
    "autorefCylinderOS" double precision,
    "autorefAxisOS" integer,
    "autorefConfidence" text,
    "keratometryK1OD" double precision,
    "keratometryK1AxisOD" integer,
    "keratometryK2OD" double precision,
    "keratometryK2AxisOD" integer,
    "keratometryK1OS" double precision,
    "keratometryK1AxisOS" integer,
    "keratometryK2OS" double precision,
    "keratometryK2AxisOS" integer,
    "keratometryAvgOD" double precision,
    "keratometryAvgOS" double precision,
    "keratometryType" text,
    "retinoscopySphereOD" double precision,
    "retinoscopyCylinderOD" double precision,
    "retinoscopyAxisOD" integer,
    "retinoscopySphereOS" double precision,
    "retinoscopyCylinderOS" double precision,
    "retinoscopyAxisOS" integer,
    "retinoscopyMethod" text,
    "subjSphereOD" double precision,
    "subjCylinderOD" double precision,
    "subjAxisOD" integer,
    "subjSphereOS" double precision,
    "subjCylinderOS" double precision,
    "subjAxisOS" integer,
    "subjVAOD" text,
    "subjVAOS" text,
    "subjVAOU" text,
    "nearAddOD" double precision,
    "nearAddOS" double precision,
    "nearVAOD" text,
    "nearVAOS" text,
    "nearVAOU" text,
    "nearWorkingDistance" double precision,
    "coverTestDistance" text,
    "coverTestNear" text,
    "npcBreak" double precision,
    "npcRecovery" double precision,
    stereopsis integer,
    "worthFourDot" text,
    "maddoxRodH" text,
    "maddoxRodV" text,
    "accommodativeAmpOD" double precision,
    "accommodativeAmpOS" double precision,
    "accommodativeFacility" text,
    "vergenceNBI" double precision,
    "vergenceNBO" double precision,
    "vergencePBI" double precision,
    "vergencePBO" double precision,
    "pupilSizeOD" double precision,
    "pupilSizeOS" double precision,
    "pupilReactionOD" text,
    "pupilReactionOS" text,
    "pupilShape" text,
    "iopOD" double precision,
    "iopOS" double precision,
    "iopTime" text,
    "iopMethod" text,
    "cctOD" double precision,
    "cctOS" double precision,
    "colorVisionTest" text,
    "colorVisionResult" text,
    "colorVisionDetails" text,
    "visualFieldOD" text,
    "visualFieldOS" text,
    "visualFieldMethod" text,
    "visualFieldNotes" text,
    "lidsOD" text,
    "lidsOS" text,
    "conjunctivaOD" text,
    "conjunctivaOS" text,
    "corneaOD" text,
    "corneaOS" text,
    "anteriorChamberOD" text,
    "anteriorChamberOS" text,
    "irisOD" text,
    "irisOS" text,
    "lensOD" text,
    "lensOS" text,
    "lensOpacityOD" text,
    "lensOpacityOS" text,
    "vitreousOD" text,
    "vitreousOS" text,
    "discOD" text,
    "discOS" text,
    "cdRatioOD" double precision,
    "cdRatioOS" double precision,
    "maculaOD" text,
    "maculaOS" text,
    "vesselsOD" text,
    "vesselsOS" text,
    "peripheryOD" text,
    "peripheryOS" text,
    "tearBreakUpTimeOD" integer,
    "tearBreakUpTimeOS" integer,
    "schirmerTestOD" integer,
    "schirmerTestOS" integer,
    "primaryDiagnosis" text,
    "secondaryDiagnosis" text,
    "assessmentNotes" text,
    "treatmentPlan" text,
    "followUpPeriod" text,
    "referralNeeded" boolean DEFAULT false NOT NULL,
    "referralTo" text,
    "referralReason" text,
    "isComplete" boolean DEFAULT false NOT NULL,
    "completedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."AdvancedExamination" OWNER TO postgres;

--
-- Name: Appointment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Appointment" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "userId" text,
    date timestamp(3) without time zone NOT NULL,
    duration integer DEFAULT 30 NOT NULL,
    type text DEFAULT 'EXAM'::text NOT NULL,
    status text DEFAULT 'SCHEDULED'::text NOT NULL,
    notes text,
    "reminderSent" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "branchId" text
);


ALTER TABLE public."Appointment" OWNER TO postgres;

--
-- Name: BarcodeManagement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."BarcodeManagement" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "productId" text,
    barcode text NOT NULL,
    "barcodeType" text DEFAULT 'EAN13'::text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."BarcodeManagement" OWNER TO postgres;

--
-- Name: Branch; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Branch" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    name text NOT NULL,
    "nameHe" text,
    code text NOT NULL,
    "isMain" boolean DEFAULT false NOT NULL,
    address text,
    city text,
    "zipCode" text,
    phone text,
    fax text,
    email text,
    active boolean DEFAULT true NOT NULL,
    "managerId" text,
    "operatingHours" jsonb,
    "shareInventory" boolean DEFAULT false NOT NULL,
    "shareCustomers" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Branch" OWNER TO postgres;

--
-- Name: Brand; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Brand" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Brand" OWNER TO postgres;

--
-- Name: CashDrawerEvent; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CashDrawerEvent" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text NOT NULL,
    "userId" text NOT NULL,
    "shiftId" text,
    "eventType" text NOT NULL,
    reason text,
    amount double precision,
    "timestamp" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."CashDrawerEvent" OWNER TO postgres;

--
-- Name: CashReconciliation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CashReconciliation" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "shiftId" text NOT NULL,
    "reconciliationType" text NOT NULL,
    "performedBy" text NOT NULL,
    "performedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "expectedAmount" double precision NOT NULL,
    "totalCounted" double precision NOT NULL,
    difference double precision NOT NULL,
    bills1 integer DEFAULT 0 NOT NULL,
    bills5 integer DEFAULT 0 NOT NULL,
    bills10 integer DEFAULT 0 NOT NULL,
    bills20 integer DEFAULT 0 NOT NULL,
    bills50 integer DEFAULT 0 NOT NULL,
    bills100 integer DEFAULT 0 NOT NULL,
    bills200 integer DEFAULT 0 NOT NULL,
    coins010 integer DEFAULT 0 NOT NULL,
    coins050 integer DEFAULT 0 NOT NULL,
    coins1 integer DEFAULT 0 NOT NULL,
    coins2 integer DEFAULT 0 NOT NULL,
    coins5 integer DEFAULT 0 NOT NULL,
    coins10 integer DEFAULT 0 NOT NULL,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."CashReconciliation" OWNER TO postgres;

--
-- Name: CashierShift; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CashierShift" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text NOT NULL,
    "userId" text NOT NULL,
    "shiftNumber" text NOT NULL,
    "startTime" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "endTime" timestamp(3) without time zone,
    status text DEFAULT 'ACTIVE'::text NOT NULL,
    "openingCash" double precision DEFAULT 0 NOT NULL,
    "closingCash" double precision,
    "expectedCash" double precision,
    "actualCash" double precision,
    "cashDifference" double precision,
    "totalSales" double precision DEFAULT 0 NOT NULL,
    "totalCashPayments" double precision DEFAULT 0 NOT NULL,
    "totalCardPayments" double precision DEFAULT 0 NOT NULL,
    "totalOtherPayments" double precision DEFAULT 0 NOT NULL,
    notes text,
    "terminalId" text,
    "closedBy" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CashierShift" OWNER TO postgres;

--
-- Name: CheckType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CheckType" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "checkId" integer NOT NULL,
    name text NOT NULL,
    price double precision NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CheckType" OWNER TO postgres;

--
-- Name: City; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."City" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "cityId" integer NOT NULL,
    name text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."City" OWNER TO postgres;

--
-- Name: ClinicalDiagnosis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ClinicalDiagnosis" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "customerId" text NOT NULL,
    "checkDate" timestamp(3) without time zone NOT NULL,
    "examinerId" text,
    complaints text,
    illnesses text,
    "optometricDiagnosis" text,
    "doctorReferral" text,
    summary text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ClinicalDiagnosis" OWNER TO postgres;

--
-- Name: ClinicalExamination; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ClinicalExamination" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "examinerId" text,
    "examDate" timestamp(3) without time zone NOT NULL,
    "recheckDate" timestamp(3) without time zone,
    symptom1 boolean DEFAULT false NOT NULL,
    symptom2 boolean DEFAULT false NOT NULL,
    symptom3 boolean DEFAULT false NOT NULL,
    symptom4 boolean DEFAULT false NOT NULL,
    symptom5 boolean DEFAULT false NOT NULL,
    symptom6 boolean DEFAULT false NOT NULL,
    symptom7 boolean DEFAULT false NOT NULL,
    symptom8 boolean DEFAULT false NOT NULL,
    symptom9 boolean DEFAULT false NOT NULL,
    symptom10 boolean DEFAULT false NOT NULL,
    symptom11 boolean DEFAULT false NOT NULL,
    symptom12 boolean DEFAULT false NOT NULL,
    symptom13 boolean DEFAULT false NOT NULL,
    symptom14 boolean DEFAULT false NOT NULL,
    symptom15 boolean DEFAULT false NOT NULL,
    symptom16 boolean DEFAULT false NOT NULL,
    symptom17 boolean DEFAULT false NOT NULL,
    symptom18 boolean DEFAULT false NOT NULL,
    symptom19 boolean DEFAULT false NOT NULL,
    symptom20 boolean DEFAULT false NOT NULL,
    symptom21 boolean DEFAULT false NOT NULL,
    symptom22 boolean DEFAULT false NOT NULL,
    symptom23 boolean DEFAULT false NOT NULL,
    symptom24 boolean DEFAULT false NOT NULL,
    symptom25 boolean DEFAULT false NOT NULL,
    symptom26 boolean DEFAULT false NOT NULL,
    symptom27 boolean DEFAULT false NOT NULL,
    symptom28 boolean DEFAULT false NOT NULL,
    symptom29 boolean DEFAULT false NOT NULL,
    symptom30 boolean DEFAULT false NOT NULL,
    symptom31 boolean DEFAULT false NOT NULL,
    symptom32 boolean DEFAULT false NOT NULL,
    symptom33 boolean DEFAULT false NOT NULL,
    symptom34 boolean DEFAULT false NOT NULL,
    symptom35 boolean DEFAULT false NOT NULL,
    symptom36 boolean DEFAULT false NOT NULL,
    symptom37 boolean DEFAULT false NOT NULL,
    symptom38 boolean DEFAULT false NOT NULL,
    symptom39 boolean DEFAULT false NOT NULL,
    symptom40 boolean DEFAULT false NOT NULL,
    symptom41 boolean DEFAULT false NOT NULL,
    symptom42 boolean DEFAULT false NOT NULL,
    symptom43 boolean DEFAULT false NOT NULL,
    symptom44 boolean DEFAULT false NOT NULL,
    symptom45 boolean DEFAULT false NOT NULL,
    symptom46 boolean DEFAULT false NOT NULL,
    symptom47 boolean DEFAULT false NOT NULL,
    symptom48 boolean DEFAULT false NOT NULL,
    symptom49 boolean DEFAULT false NOT NULL,
    symptom50 boolean DEFAULT false NOT NULL,
    symptom51 boolean DEFAULT false NOT NULL,
    symptom52 boolean DEFAULT false NOT NULL,
    symptom53 boolean DEFAULT false NOT NULL,
    symptom54 boolean DEFAULT false NOT NULL,
    symptom55 boolean DEFAULT false NOT NULL,
    symptom56 boolean DEFAULT false NOT NULL,
    symptom57 boolean DEFAULT false NOT NULL,
    symptom58 boolean DEFAULT false NOT NULL,
    medications text,
    "eyeMedications" text,
    "previousTreatment" text,
    comments text,
    "eyeLidRight" text,
    "eyeLidLeft" text,
    "tearDuctRight" text,
    "tearDuctLeft" text,
    "corneaRight" text,
    "corneaLeft" text,
    "irisRight" text,
    "irisLeft" text,
    "lensRight" text,
    "lensLeft" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "branchId" text
);


ALTER TABLE public."ClinicalExamination" OWNER TO postgres;

--
-- Name: Commission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Commission" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "employeeId" text NOT NULL,
    "saleId" text,
    "examinationId" text,
    "ruleId" text,
    "baseAmount" double precision NOT NULL,
    "commissionRate" double precision NOT NULL,
    "commissionAmount" double precision NOT NULL,
    period text NOT NULL,
    "periodStart" timestamp(3) without time zone NOT NULL,
    "periodEnd" timestamp(3) without time zone NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    "paidAmount" double precision DEFAULT 0,
    "paidAt" timestamp(3) without time zone,
    "paymentRef" text,
    notes text,
    "approvedBy" text,
    "approvedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Commission" OWNER TO postgres;

--
-- Name: CommissionRule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CommissionRule" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "ruleType" text NOT NULL,
    percentage double precision,
    "fixedAmount" double precision,
    tiers jsonb,
    "categoryFilter" text,
    "brandFilter" text,
    "minimumSaleAmount" double precision DEFAULT 0,
    "validFrom" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "validUntil" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CommissionRule" OWNER TO postgres;

--
-- Name: CommunicationCampaign; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CommunicationCampaign" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    name text NOT NULL,
    description text,
    type text NOT NULL,
    status text DEFAULT 'DRAFT'::text NOT NULL,
    "targetType" text NOT NULL,
    "targetFilter" jsonb,
    "targetCustomers" text[],
    "templateId" text,
    subject text,
    content text NOT NULL,
    "scheduledAt" timestamp(3) without time zone,
    "sendAt" timestamp(3) without time zone,
    "completedAt" timestamp(3) without time zone,
    "totalRecipients" integer DEFAULT 0 NOT NULL,
    "sentCount" integer DEFAULT 0 NOT NULL,
    "deliveredCount" integer DEFAULT 0 NOT NULL,
    "failedCount" integer DEFAULT 0 NOT NULL,
    "openedCount" integer DEFAULT 0 NOT NULL,
    "clickedCount" integer DEFAULT 0 NOT NULL,
    "unsubscribedCount" integer DEFAULT 0 NOT NULL,
    "estimatedCost" double precision DEFAULT 0 NOT NULL,
    "actualCost" double precision DEFAULT 0 NOT NULL,
    "respectOptOut" boolean DEFAULT true NOT NULL,
    "testMode" boolean DEFAULT false NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    "createdBy" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CommunicationCampaign" OWNER TO postgres;

--
-- Name: CommunicationLog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CommunicationLog" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text,
    "recipientEmail" text,
    "recipientPhone" text,
    "recipientName" text,
    type text NOT NULL,
    template text,
    subject text,
    content text NOT NULL,
    status text NOT NULL,
    "sentAt" timestamp(3) without time zone,
    "deliveredAt" timestamp(3) without time zone,
    "failedAt" timestamp(3) without time zone,
    error text,
    provider text,
    "providerMessageId" text,
    cost double precision,
    context text,
    "contextId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "branchId" text,
    "campaignId" text
);


ALTER TABLE public."CommunicationLog" OWNER TO postgres;

--
-- Name: CommunicationSchedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CommunicationSchedule" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    name text NOT NULL,
    description text,
    active boolean DEFAULT true NOT NULL,
    "scheduleType" text NOT NULL,
    "triggerType" text NOT NULL,
    "triggerDays" integer,
    "triggerTime" text NOT NULL,
    "recurrencePattern" text,
    "recurrenceDays" integer[],
    "templateId" text NOT NULL,
    "customerFilter" jsonb,
    "respectOptOut" boolean DEFAULT true NOT NULL,
    "includeInactive" boolean DEFAULT false NOT NULL,
    "maxSendsPerDay" integer,
    "lastRunAt" timestamp(3) without time zone,
    "nextRunAt" timestamp(3) without time zone,
    "totalSent" integer DEFAULT 0 NOT NULL,
    "totalFailed" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CommunicationSchedule" OWNER TO postgres;

--
-- Name: ContactAgent; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ContactAgent" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "agentType" text NOT NULL,
    relationship text,
    "firstName" text NOT NULL,
    "lastName" text NOT NULL,
    phone text,
    email text,
    address text,
    city text,
    "policyNumber" text,
    "groupNumber" text,
    "isPrimary" boolean DEFAULT false NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ContactAgent" OWNER TO postgres;

--
-- Name: ContactLensBrand; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ContactLensBrand" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "brandId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ContactLensBrand" OWNER TO postgres;

--
-- Name: ContactLensCleaningSolution; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ContactLensCleaningSolution" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "solutionId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ContactLensCleaningSolution" OWNER TO postgres;

--
-- Name: ContactLensDisinfectingSolution; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ContactLensDisinfectingSolution" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "solutionId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ContactLensDisinfectingSolution" OWNER TO postgres;

--
-- Name: ContactLensExamination; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ContactLensExamination" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "customerId" text NOT NULL,
    "checkDate" timestamp(3) without time zone NOT NULL,
    "reCheckDate" timestamp(3) without time zone,
    "examinerId" text,
    "pupilDiameter" double precision,
    "cornealDiameter" double precision,
    "eyelidKey" double precision,
    "breakUpTime" double precision,
    "schirmerRight" double precision,
    "schirmerLeft" double precision,
    "eyeColor" text,
    "keratometryHR" double precision,
    "keratometryHL" double precision,
    "axisHR" double precision,
    "axisHL" double precision,
    "keratometryVR" double precision,
    "keratometryVL" double precision,
    "keratometryTR" double precision,
    "keratometryTL" double precision,
    "keratometryNR" double precision,
    "keratometryNL" double precision,
    "keratometryIR" double precision,
    "keratometryIL" double precision,
    "keratometrySR" double precision,
    "keratometrySL" double precision,
    "diameterRight" double precision,
    "diameterLeft" double precision,
    "baseCurve1R" double precision,
    "baseCurve1L" double precision,
    "baseCurve2R" double precision,
    "baseCurve2L" double precision,
    "opticalZoneR" double precision,
    "opticalZoneL" double precision,
    "powerR" integer,
    "powerL" integer,
    "sphereR" double precision,
    "sphereL" double precision,
    "cylinderR" double precision,
    "cylinderL" double precision,
    "axisR" double precision,
    "axisL" double precision,
    "addR" double precision,
    "addL" double precision,
    "materialR" integer,
    "materialL" integer,
    "tintR" integer,
    "tintL" integer,
    "visualAcuityR" double precision,
    "visualAcuityL" double precision,
    "visualAcuity" double precision,
    "pinHoleR" double precision,
    "pinHoleL" double precision,
    "lensTypeIdR" integer,
    "lensTypeIdL" integer,
    "manufacturerIdR" integer,
    "manufacturerIdL" integer,
    "brandIdR" integer,
    "brandIdL" integer,
    "cleaningSolutionId" integer,
    "disinfectingSolutionId" integer,
    "rinsingSolutionId" integer,
    "blinkFrequency" integer,
    "blinkQuality" integer,
    "lensId" integer,
    comments text,
    "fittingComment" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ContactLensExamination" OWNER TO postgres;

--
-- Name: ContactLensFitting; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ContactLensFitting" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "fitterId" text,
    "fittingDate" timestamp(3) without time zone NOT NULL,
    "rightEyeParams" text,
    "leftEyeParams" text,
    "trialLenses" text,
    "finalSelection" text,
    "wearSchedule" text,
    "careSystem" text,
    "followUpDate" timestamp(3) without time zone,
    notes text,
    status text DEFAULT 'TRIAL'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "branchId" text
);


ALTER TABLE public."ContactLensFitting" OWNER TO postgres;

--
-- Name: ContactLensFittingDetail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ContactLensFittingDetail" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "customerId" text NOT NULL,
    "checkDate" timestamp(3) without time zone NOT NULL,
    "fittingId" integer NOT NULL,
    "diameterRight" double precision,
    "diameterLeft" double precision,
    "baseCurve1R" double precision,
    "baseCurve1L" double precision,
    "baseCurve2R" double precision,
    "baseCurve2L" double precision,
    "sphereR" double precision,
    "sphereL" double precision,
    "cylinderR" double precision,
    "cylinderL" double precision,
    "axisR" double precision,
    "axisL" double precision,
    "visualAcuityR" double precision,
    "visualAcuityL" double precision,
    "visualAcuity" double precision,
    "pinHoleR" double precision,
    "pinHoleL" double precision,
    "lensTypeIdR" integer,
    "lensTypeIdL" integer,
    "manufacturerIdR" integer,
    "manufacturerIdL" integer,
    "brandIdR" integer,
    "brandIdL" integer,
    "commentR" text,
    "commentL" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ContactLensFittingDetail" OWNER TO postgres;

--
-- Name: ContactLensManufacturer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ContactLensManufacturer" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "manufacturerId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ContactLensManufacturer" OWNER TO postgres;

--
-- Name: ContactLensMaterial; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ContactLensMaterial" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "materialId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ContactLensMaterial" OWNER TO postgres;

--
-- Name: ContactLensPrescription; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ContactLensPrescription" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "doctorId" text,
    "prescriptionDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "validUntil" timestamp(3) without time zone,
    "rightBrand" text,
    "rightPower" double precision,
    "rightBC" double precision,
    "rightDiameter" double precision,
    "rightCylinder" double precision,
    "rightAxis" integer,
    "rightAdd" double precision,
    "rightColor" text,
    "leftBrand" text,
    "leftPower" double precision,
    "leftBC" double precision,
    "leftDiameter" double precision,
    "leftCylinder" double precision,
    "leftAxis" integer,
    "leftAdd" double precision,
    "leftColor" text,
    "wearingSchedule" text,
    "replacementSchedule" text,
    notes text,
    recommendations text,
    "trialLensUsed" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "additionalData" jsonb,
    "branchId" text
);


ALTER TABLE public."ContactLensPrescription" OWNER TO postgres;

--
-- Name: ContactLensRinsingSolution; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ContactLensRinsingSolution" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "solutionId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ContactLensRinsingSolution" OWNER TO postgres;

--
-- Name: ContactLensTint; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ContactLensTint" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "tintId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ContactLensTint" OWNER TO postgres;

--
-- Name: ContactLensType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ContactLensType" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "lensTypeId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ContactLensType" OWNER TO postgres;

--
-- Name: CreditCardTransaction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CreditCardTransaction" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "saleId" text,
    "invoiceId" text,
    "cardType" text NOT NULL,
    "last4Digits" text NOT NULL,
    "cardHolderName" text,
    "expiryMonth" integer,
    "expiryYear" integer,
    "transactionId" text NOT NULL,
    amount double precision NOT NULL,
    currency text DEFAULT 'ILS'::text NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    "processorName" text,
    "authorizationCode" text,
    "referenceNumber" text,
    "processedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "branchId" text
);


ALTER TABLE public."CreditCardTransaction" OWNER TO postgres;

--
-- Name: Customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Customer" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "firstName" text NOT NULL,
    "lastName" text NOT NULL,
    "firstNameHe" text,
    "lastNameHe" text,
    "idNumber" text,
    "birthDate" timestamp(3) without time zone,
    gender text,
    occupation text,
    "cellPhone" text,
    "homePhone" text,
    "workPhone" text,
    fax text,
    email text,
    address text,
    city text,
    "zipCode" text,
    "customerType" text,
    "groupId" text,
    "discountId" text,
    "referralId" text,
    "familyId" text,
    "preferredLanguage" text DEFAULT 'he'::text NOT NULL,
    "mailList" boolean DEFAULT true NOT NULL,
    "smsConsent" boolean DEFAULT true NOT NULL,
    notes text,
    tags text[],
    rating integer,
    "wantsLaser" boolean DEFAULT false NOT NULL,
    "laserDate" timestamp(3) without time zone,
    "didOperation" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "branchId" text,
    allergies text,
    "healthFund" text,
    "medicalConditions" text,
    medications text
);


ALTER TABLE public."Customer" OWNER TO postgres;

--
-- Name: CustomerGroup; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CustomerGroup" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "groupCode" text NOT NULL,
    name text NOT NULL,
    "nameHe" text,
    discount double precision DEFAULT 0,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CustomerGroup" OWNER TO postgres;

--
-- Name: CustomerPhoto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CustomerPhoto" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "photoType" text NOT NULL,
    "fileName" text NOT NULL,
    "filePath" text NOT NULL,
    "fileSize" integer,
    "mimeType" text,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CustomerPhoto" OWNER TO postgres;

--
-- Name: DetailedWorkOrder; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."DetailedWorkOrder" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "workId" integer NOT NULL,
    "workDate" timestamp(3) without time zone NOT NULL,
    "customerId" text NOT NULL,
    "examinerId" text,
    "workTypeId" integer,
    "checkDate" timestamp(3) without time zone,
    "workStatusId" integer,
    "workSupplyId" integer,
    "labId" integer,
    "supplierId" integer,
    "bagNumber" text,
    "promiseDate" timestamp(3) without time zone,
    "deliveryDate" timestamp(3) without time zone,
    "frameSupplierId" integer,
    "frameLabelId" integer,
    "frameModel" text,
    "frameColor" text,
    "frameSize" text,
    "frameSold" boolean DEFAULT false NOT NULL,
    "lensSupplierId" integer,
    "glassSupplierId" integer,
    "lensCleanSupplierId" integer,
    "glassId" double precision,
    "workType" integer,
    "smsSent" boolean DEFAULT false NOT NULL,
    "itemId" double precision,
    "tailId" text,
    canceled boolean DEFAULT false NOT NULL,
    comments text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."DetailedWorkOrder" OWNER TO postgres;

--
-- Name: Diagnosis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Diagnosis" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "examinerId" text,
    "diagnosisDate" timestamp(3) without time zone NOT NULL,
    complaints text,
    illnesses text,
    "doctorReferral" text,
    summary text,
    "icdCode" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "optometricDiagnosis" text,
    "branchId" text
);


ALTER TABLE public."Diagnosis" OWNER TO postgres;

--
-- Name: DiagnosticProtocol; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."DiagnosticProtocol" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    name text NOT NULL,
    category text NOT NULL,
    description text,
    "requiredTests" jsonb NOT NULL,
    "alertConditions" jsonb NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."DiagnosticProtocol" OWNER TO postgres;

--
-- Name: Discount; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Discount" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    name text NOT NULL,
    code text NOT NULL,
    type text NOT NULL,
    value numeric(10,2) NOT NULL,
    "appliesTo" text NOT NULL,
    "productIds" text[],
    "minimumPurchase" numeric(10,2),
    "maximumDiscount" numeric(10,2),
    "customerGroupIds" text[],
    "customerIds" text[],
    "validFrom" timestamp(3) without time zone,
    "validTo" timestamp(3) without time zone,
    "usageLimit" integer,
    "usageCount" integer DEFAULT 0 NOT NULL,
    "perCustomerLimit" integer,
    combinable boolean DEFAULT false NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    active boolean DEFAULT true NOT NULL,
    "requiresApproval" boolean DEFAULT false NOT NULL,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Discount" OWNER TO postgres;

--
-- Name: Document; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Document" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "documentNumber" text NOT NULL,
    title text NOT NULL,
    type text NOT NULL,
    category text NOT NULL,
    "templateId" text,
    "generatedFrom" text,
    content text NOT NULL,
    "contentType" text DEFAULT 'html'::text NOT NULL,
    "fileUrl" text,
    "customerId" text,
    "appointmentId" text,
    "examinationId" text,
    "prescriptionId" text,
    "saleId" text,
    metadata jsonb,
    variables jsonb,
    status text DEFAULT 'DRAFT'::text NOT NULL,
    "sentAt" timestamp(3) without time zone,
    "sentTo" text,
    "sentMethod" text,
    "createdById" text NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    "previousVersionId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Document" OWNER TO postgres;

--
-- Name: DocumentTemplate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."DocumentTemplate" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    name text NOT NULL,
    description text,
    category text NOT NULL,
    type text NOT NULL,
    language text DEFAULT 'he'::text NOT NULL,
    subject text,
    content text NOT NULL,
    variables jsonb NOT NULL,
    metadata jsonb,
    "isActive" boolean DEFAULT true NOT NULL,
    "isSystem" boolean DEFAULT false NOT NULL,
    "paperSize" text DEFAULT 'A4'::text NOT NULL,
    orientation text DEFAULT 'portrait'::text NOT NULL,
    margins jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."DocumentTemplate" OWNER TO postgres;

--
-- Name: EmployeeCommissionRule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."EmployeeCommissionRule" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "employeeId" text NOT NULL,
    "ruleId" text NOT NULL,
    "customPercentage" double precision,
    "customAmount" double precision,
    "isActive" boolean DEFAULT true NOT NULL,
    "validFrom" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "validUntil" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."EmployeeCommissionRule" OWNER TO postgres;

--
-- Name: Examination; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Examination" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "doctorId" text NOT NULL,
    "examDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "examType" text DEFAULT 'COMPREHENSIVE'::text NOT NULL,
    "vaRightDist" text,
    "vaLeftDist" text,
    "vaRightNear" text,
    "vaLeftNear" text,
    "refractionData" jsonb,
    "currentRxData" jsonb,
    "autoRxData" jsonb,
    "coverTest" jsonb,
    "npcDistance" double precision,
    "accommodationAmp" double precision,
    "pupilDistance" double precision,
    "iopRight" double precision,
    "iopLeft" double precision,
    "iopTime" timestamp(3) without time zone,
    "iopMethod" text,
    "slitLampData" jsonb,
    "clinicalNotes" text,
    recommendations text,
    "internalNotes" text,
    "prescriptionData" jsonb,
    "nextExamDate" timestamp(3) without time zone,
    "followUpRequired" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "accommodativeFunction" text,
    allergies text,
    "amslergridOd" text,
    "amslergridOs" text,
    "anteriorOdAc" text,
    "anteriorOdConjunctiva" text,
    "anteriorOdCornea" text,
    "anteriorOdIris" text,
    "anteriorOdLens" text,
    "anteriorOdLids" text,
    "anteriorOdVitreous" text,
    "anteriorOsAc" text,
    "anteriorOsConjunctiva" text,
    "anteriorOsCornea" text,
    "anteriorOsIris" text,
    "anteriorOsLens" text,
    "anteriorOsLids" text,
    "anteriorOsVitreous" text,
    "binocularFunction" text,
    "colorVisionResult" text,
    "colorVisionTest" text,
    complaints text,
    "contactLensComfort" text,
    "contactLensFit" text,
    "contactLensHygiene" text,
    "contactLensWear" boolean,
    "contrastSensitivity" text,
    "deletedAt" timestamp(3) without time zone,
    "dilationDone" boolean DEFAULT false,
    "dilationDrop" text,
    "dilationTime" timestamp(3) without time zone,
    "eomDiplopia" boolean,
    "eomFull" boolean,
    "eomRestrictions" text,
    "familyHistory" text,
    "followUpReason" text,
    "fusionalAmplitudes" jsonb,
    "imageIds" text[],
    "imageNotes" jsonb,
    lifestyle text,
    "medicalHistory" text,
    medications text,
    "pdNear" double precision,
    "posteriorOdCdRatio" text,
    "posteriorOdMacula" text,
    "posteriorOdOpticDisc" text,
    "posteriorOdPeriphery" text,
    "posteriorOdVessels" text,
    "posteriorOsCdRatio" text,
    "posteriorOsMacula" text,
    "posteriorOsOpticDisc" text,
    "posteriorOsPeriphery" text,
    "posteriorOsVessels" text,
    "pupilsOdReaction" text,
    "pupilsOdSize" double precision,
    "pupilsOsReaction" text,
    "pupilsOsSize" double precision,
    "pupilsRapd" boolean,
    "reviewDate" timestamp(3) without time zone,
    "reviewNotes" text,
    "reviewRequired" boolean DEFAULT false,
    "reviewedBy" text,
    stereopsis text,
    "treatmentPlan" text,
    "vaBinocular" text,
    "visualFieldsDefects" text,
    "visualFieldsMethod" text,
    "visualFieldsOd" text,
    "visualFieldsOs" text,
    "branchId" text
);


ALTER TABLE public."Examination" OWNER TO postgres;

--
-- Name: ExaminationOverview; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ExaminationOverview" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "customerId" text NOT NULL,
    "checkDate" timestamp(3) without time zone NOT NULL,
    "examinerId" text,
    comments text,
    "visualAcuityR" double precision,
    "visualAcuityL" double precision,
    picture text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ExaminationOverview" OWNER TO postgres;

--
-- Name: Expense; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Expense" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "employeeId" text,
    title text NOT NULL,
    description text,
    category text NOT NULL,
    subcategory text,
    amount double precision NOT NULL,
    currency text DEFAULT 'ILS'::text NOT NULL,
    "receiptUrl" text,
    "receiptNumber" text,
    "vendorName" text,
    "expenseDate" timestamp(3) without time zone NOT NULL,
    period text NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    "approvedBy" text,
    "approvedAt" timestamp(3) without time zone,
    "rejectedBy" text,
    "rejectedAt" timestamp(3) without time zone,
    "rejectionReason" text,
    reimbursed boolean DEFAULT false NOT NULL,
    "reimbursedAt" timestamp(3) without time zone,
    "reimbursementRef" text,
    "isDeductible" boolean DEFAULT true NOT NULL,
    "taxRate" double precision DEFAULT 0,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Expense" OWNER TO postgres;

--
-- Name: FRPLine; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."FRPLine" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "frpLineId" integer NOT NULL,
    "frpId" integer NOT NULL,
    "lineDate" timestamp(3) without time zone NOT NULL,
    quantity integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."FRPLine" OWNER TO postgres;

--
-- Name: FollowUp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."FollowUp" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "scheduledDate" timestamp(3) without time zone NOT NULL,
    type text NOT NULL,
    reason text,
    priority text DEFAULT 'NORMAL'::text NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    "completedDate" timestamp(3) without time zone,
    "completedBy" text,
    outcome text,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "branchId" text
);


ALTER TABLE public."FollowUp" OWNER TO postgres;

--
-- Name: Frame; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Frame" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "frameId" text NOT NULL,
    brand text NOT NULL,
    model text NOT NULL,
    color text,
    size text,
    material text,
    style text,
    gender text,
    "eyeSize" integer,
    "bridgeSize" integer,
    "templeLength" integer,
    "costPrice" double precision DEFAULT 0 NOT NULL,
    "retailPrice" double precision DEFAULT 0 NOT NULL,
    sku text,
    barcode text,
    supplier text,
    "supplierCode" text,
    "inStock" boolean DEFAULT true NOT NULL,
    discontinued boolean DEFAULT false NOT NULL,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Frame" OWNER TO postgres;

--
-- Name: FrameCatalog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."FrameCatalog" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "catalogNumber" text NOT NULL,
    barcode text,
    brand text NOT NULL,
    "brandCode" text NOT NULL,
    model text NOT NULL,
    "modelCode" text NOT NULL,
    collection text,
    material text NOT NULL,
    "rimType" text NOT NULL,
    shape text NOT NULL,
    "eyeSize" integer NOT NULL,
    "bridgeSize" integer NOT NULL,
    "templeLength" integer NOT NULL,
    "totalWidth" integer,
    "lensHeight" integer,
    "frontColor" text NOT NULL,
    "templeColor" text,
    "colorCode" text,
    "colorFamily" text,
    gender text NOT NULL,
    "ageGroup" text,
    features text[],
    cost numeric(10,2) NOT NULL,
    "retailPrice" numeric(10,2) NOT NULL,
    "salePrice" numeric(10,2),
    "supplierId" text,
    "supplierCode" text,
    active boolean DEFAULT true NOT NULL,
    discontinued boolean DEFAULT false NOT NULL,
    "launchDate" timestamp(3) without time zone,
    "imageUrls" text[],
    tags text[],
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."FrameCatalog" OWNER TO postgres;

--
-- Name: FrequentReplacementProgram; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."FrequentReplacementProgram" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "programId" text NOT NULL,
    "customerId" text NOT NULL,
    "startDate" timestamp(3) without time zone NOT NULL,
    "endDate" timestamp(3) without time zone,
    "rightEyeBrand" text,
    "rightEyeType" text,
    "rightEyePower" text,
    "leftEyeBrand" text,
    "leftEyeType" text,
    "leftEyePower" text,
    "replacementSchedule" text NOT NULL,
    "quantityPerBox" integer NOT NULL,
    "boxesPerYear" integer NOT NULL,
    "pricePerBox" double precision NOT NULL,
    "annualSupply" boolean DEFAULT false NOT NULL,
    status text DEFAULT 'ACTIVE'::text NOT NULL,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."FrequentReplacementProgram" OWNER TO postgres;

--
-- Name: FrequentReplacementProgramDetail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."FrequentReplacementProgramDetail" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "frpId" integer NOT NULL,
    "customerId" text NOT NULL,
    "brandId" integer,
    "frpDate" timestamp(3) without time zone NOT NULL,
    "totalFrp" integer,
    "exchangeNumber" integer,
    "dayInterval" integer,
    supply integer,
    "saleAdd" integer DEFAULT 0 NOT NULL,
    comments text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."FrequentReplacementProgramDetail" OWNER TO postgres;

--
-- Name: FrpDelivery; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."FrpDelivery" (
    id text NOT NULL,
    "programId" text NOT NULL,
    "scheduledDate" timestamp(3) without time zone NOT NULL,
    "deliveredDate" timestamp(3) without time zone,
    quantity integer NOT NULL,
    status text DEFAULT 'SCHEDULED'::text NOT NULL,
    "trackingNumber" text,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."FrpDelivery" OWNER TO postgres;

--
-- Name: GlassBrand; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."GlassBrand" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "brandId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."GlassBrand" OWNER TO postgres;

--
-- Name: GlassCoating; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."GlassCoating" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "coatingId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."GlassCoating" OWNER TO postgres;

--
-- Name: GlassColor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."GlassColor" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "colorId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."GlassColor" OWNER TO postgres;

--
-- Name: GlassExamination; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."GlassExamination" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "customerId" text NOT NULL,
    "checkDate" timestamp(3) without time zone NOT NULL,
    "glassId" integer NOT NULL,
    "roleId" integer,
    "materialId" integer,
    "brandId" integer,
    "coatId" integer,
    "modelId" integer,
    "colorId" integer,
    diameter double precision,
    segment double precision,
    "saleAdd" integer DEFAULT 0 NOT NULL,
    comments text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."GlassExamination" OWNER TO postgres;

--
-- Name: GlassMaterial; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."GlassMaterial" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "materialId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."GlassMaterial" OWNER TO postgres;

--
-- Name: GlassModel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."GlassModel" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "modelId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."GlassModel" OWNER TO postgres;

--
-- Name: GlassPrescription; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."GlassPrescription" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "customerId" text NOT NULL,
    "checkDate" timestamp(3) without time zone NOT NULL,
    "prevId" integer NOT NULL,
    "refractiveSphereR" double precision,
    "refractiveSphereL" double precision,
    "refractiveCylinderR" double precision,
    "refractiveCylinderL" double precision,
    "refractiveAxisR" double precision,
    "refractiveAxisL" double precision,
    "retTypeId1" integer,
    "retDistId1" integer,
    "retComment1" text,
    "refractiveSphereR2" double precision,
    "refractiveSphereL2" double precision,
    "refractiveCylinderR2" double precision,
    "refractiveCylinderL2" double precision,
    "refractiveAxisR2" double precision,
    "refractiveAxisL2" double precision,
    "retTypeId2" integer,
    "retDistId2" integer,
    "retComment2" text,
    "sphereR" double precision,
    "sphereL" double precision,
    "cylinderR" double precision,
    "cylinderL" double precision,
    "axisR" double precision,
    "axisL" double precision,
    "prismR" double precision,
    "prismL" double precision,
    "baseR" integer,
    "baseL" integer,
    "visualAcuityR" double precision,
    "visualAcuityL" double precision,
    "visualAcuity" double precision,
    "pinHoleR" double precision,
    "pinHoleL" double precision,
    "externalPrismR" double precision,
    "externalPrismL" double precision,
    "externalBaseR" integer,
    "externalBaseL" integer,
    "pupillaryDistanceR" double precision,
    "pupillaryDistanceL" double precision,
    "pupillaryDistanceA" double precision,
    "additionR" double precision,
    "additionL" double precision,
    comments text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."GlassPrescription" OWNER TO postgres;

--
-- Name: GlassPrescriptionDetail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."GlassPrescriptionDetail" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "customerId" text NOT NULL,
    "checkDate" timestamp(3) without time zone NOT NULL,
    "glassPId" integer NOT NULL,
    "useId" integer,
    "supplierId" integer,
    "lensTypeId" integer,
    "lensMaterialId" integer,
    "lensCharId" integer,
    "treatmentCharId" integer,
    "treatmentCharId1" double precision,
    "treatmentCharId2" double precision,
    "treatmentCharId3" double precision,
    diameter double precision,
    "eyeId" integer,
    "saleAdd" integer DEFAULT 0 NOT NULL,
    comments text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."GlassPrescriptionDetail" OWNER TO postgres;

--
-- Name: GlassRole; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."GlassRole" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "roleId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."GlassRole" OWNER TO postgres;

--
-- Name: GlassUse; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."GlassUse" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "useId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."GlassUse" OWNER TO postgres;

--
-- Name: InventoryAdjustment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."InventoryAdjustment" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "adjustmentDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "adjustmentType" text NOT NULL,
    reason text NOT NULL,
    notes text,
    "adjustedBy" text,
    "approvedBy" text,
    "approvedAt" timestamp(3) without time zone,
    "physicalCountId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."InventoryAdjustment" OWNER TO postgres;

--
-- Name: InventoryAdjustmentItem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."InventoryAdjustmentItem" (
    id text NOT NULL,
    "adjustmentId" text NOT NULL,
    "productId" text NOT NULL,
    "oldQuantity" integer NOT NULL,
    "newQuantity" integer NOT NULL,
    "adjustmentAmount" integer NOT NULL,
    "unitCost" double precision,
    "totalCostImpact" double precision,
    notes text
);


ALTER TABLE public."InventoryAdjustmentItem" OWNER TO postgres;

--
-- Name: Invoice; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Invoice" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "invoiceId" text NOT NULL,
    "invoiceNumber" text,
    "supplierId" text NOT NULL,
    "invoiceDate" timestamp(3) without time zone NOT NULL,
    "dueDate" timestamp(3) without time zone,
    "totalAmount" double precision NOT NULL,
    "paidAmount" double precision DEFAULT 0 NOT NULL,
    "invoiceType" text NOT NULL,
    comment text,
    status text DEFAULT 'PENDING'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Invoice" OWNER TO postgres;

--
-- Name: InvoiceCredit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."InvoiceCredit" (
    id text NOT NULL,
    "invoiceId" text NOT NULL,
    "creditDate" timestamp(3) without time zone NOT NULL,
    amount double precision NOT NULL,
    reason text,
    reference text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."InvoiceCredit" OWNER TO postgres;

--
-- Name: InvoicePayment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."InvoicePayment" (
    id text NOT NULL,
    "invoiceId" text NOT NULL,
    "paymentDate" timestamp(3) without time zone NOT NULL,
    amount double precision NOT NULL,
    "paymentMethod" text NOT NULL,
    reference text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."InvoicePayment" OWNER TO postgres;

--
-- Name: LabelPrintJob; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."LabelPrintJob" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "templateId" text NOT NULL,
    "jobNumber" text NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    "dataSource" text NOT NULL,
    "dataQuery" jsonb,
    labels jsonb NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    "totalLabels" integer NOT NULL,
    "printerName" text,
    "outputFormat" text DEFAULT 'PDF'::text NOT NULL,
    "outputUrl" text,
    error text,
    "errorDetails" jsonb,
    "createdBy" text NOT NULL,
    "printedBy" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "printedAt" timestamp(3) without time zone,
    "completedAt" timestamp(3) without time zone
);


ALTER TABLE public."LabelPrintJob" OWNER TO postgres;

--
-- Name: LabelTemplate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."LabelTemplate" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    name text NOT NULL,
    description text,
    category text NOT NULL,
    width double precision NOT NULL,
    height double precision NOT NULL,
    orientation text DEFAULT 'portrait'::text NOT NULL,
    "pageSize" text DEFAULT 'A4'::text NOT NULL,
    "pageWidth" double precision,
    "pageHeight" double precision,
    "labelsPerRow" integer DEFAULT 1 NOT NULL,
    "labelsPerColumn" integer DEFAULT 1 NOT NULL,
    "marginTop" double precision DEFAULT 0 NOT NULL,
    "marginLeft" double precision DEFAULT 0 NOT NULL,
    "labelSpacingX" double precision DEFAULT 0 NOT NULL,
    "labelSpacingY" double precision DEFAULT 0 NOT NULL,
    design jsonb NOT NULL,
    "defaultFields" jsonb,
    "isDefault" boolean DEFAULT false NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "printerName" text,
    copies integer DEFAULT 1 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "createdById" text
);


ALTER TABLE public."LabelTemplate" OWNER TO postgres;

--
-- Name: Lens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Lens" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "lensId" text NOT NULL,
    type text NOT NULL,
    material text NOT NULL,
    index text,
    "sphereMin" double precision,
    "sphereMax" double precision,
    "cylinderMin" double precision,
    "cylinderMax" double precision,
    "addMin" double precision,
    "addMax" double precision,
    diameter integer,
    coating text,
    tint text,
    photochromic boolean DEFAULT false NOT NULL,
    polarized boolean DEFAULT false NOT NULL,
    "baseCost" double precision DEFAULT 0 NOT NULL,
    "basePrice" double precision DEFAULT 0 NOT NULL,
    supplier text,
    "supplierCode" text,
    "labCode" text,
    available boolean DEFAULT true NOT NULL,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Lens" OWNER TO postgres;

--
-- Name: LensCatalog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."LensCatalog" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "catalogNumber" text NOT NULL,
    "productCode" text NOT NULL,
    manufacturer text NOT NULL,
    brand text NOT NULL,
    series text,
    "lensType" text NOT NULL,
    design text NOT NULL,
    material text NOT NULL,
    "refractiveIndex" numeric(3,2) NOT NULL,
    "abbeValue" integer,
    "specificGravity" numeric(3,2),
    "sphereMin" numeric(5,2) NOT NULL,
    "sphereMax" numeric(5,2) NOT NULL,
    "cylinderMin" numeric(5,2) NOT NULL,
    "cylinderMax" numeric(5,2) NOT NULL,
    "addMin" numeric(4,2),
    "addMax" numeric(4,2),
    "baseCurves" numeric(4,2)[],
    diameters integer[],
    "centerThickness" numeric(3,1),
    coatings text[],
    "corridorLengths" integer[],
    "pricingMatrix" jsonb NOT NULL,
    "supplierId" text,
    "supplierCode" text,
    "labProcessing" boolean DEFAULT true NOT NULL,
    "surfacingRequired" boolean DEFAULT false NOT NULL,
    active boolean DEFAULT true NOT NULL,
    "stockItem" boolean DEFAULT false NOT NULL,
    "leadTime" integer,
    "uvProtection" integer,
    impact text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."LensCatalog" OWNER TO postgres;

--
-- Name: LensCharacteristic; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."LensCharacteristic" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "supplierId" double precision NOT NULL,
    "lensTypeId" double precision NOT NULL,
    "lensMaterialId" double precision NOT NULL,
    "characteristicId" integer NOT NULL,
    name text NOT NULL,
    "idCount" integer DEFAULT 0 NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."LensCharacteristic" OWNER TO postgres;

--
-- Name: LensMaterial; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."LensMaterial" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "materialId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."LensMaterial" OWNER TO postgres;

--
-- Name: LensTreatmentCharacteristic; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."LensTreatmentCharacteristic" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "supplierId" double precision NOT NULL,
    "lensTypeId" double precision NOT NULL,
    "lensMaterialId" double precision NOT NULL,
    "treatmentCharId" integer NOT NULL,
    name text NOT NULL,
    "idCount" integer DEFAULT 0 NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."LensTreatmentCharacteristic" OWNER TO postgres;

--
-- Name: LensType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."LensType" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "lensTypeId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."LensType" OWNER TO postgres;

--
-- Name: Letter; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Letter" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "templateName" text NOT NULL,
    subject text NOT NULL,
    content text NOT NULL,
    category text NOT NULL,
    "mergeFields" text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Letter" OWNER TO postgres;

--
-- Name: LowVisionArea; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."LowVisionArea" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "areaId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."LowVisionArea" OWNER TO postgres;

--
-- Name: LowVisionCap; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."LowVisionCap" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "capId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."LowVisionCap" OWNER TO postgres;

--
-- Name: LowVisionCheck; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."LowVisionCheck" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "examinerId" text,
    "examDate" timestamp(3) without time zone NOT NULL,
    "visualAcuity" text,
    "contrastSensitivity" text,
    "visualField" text,
    "aidsRecommended" text,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "branchId" text
);


ALTER TABLE public."LowVisionCheck" OWNER TO postgres;

--
-- Name: LowVisionExamination; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."LowVisionExamination" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "customerId" text NOT NULL,
    "checkDate" timestamp(3) without time zone NOT NULL,
    "lowVisionId" integer NOT NULL,
    "eyeId" integer,
    "pupillaryDistanceR" double precision,
    "pupillaryDistanceL" double precision,
    "manufacturerId" integer,
    "frameId" integer,
    "areaId" integer,
    "capId" integer,
    "visualAcuityDistance" double precision,
    "visualAcuityNear" double precision,
    "visualAcuityDistanceLeft" double precision,
    "visualAcuityNearLeft" double precision,
    comments text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."LowVisionExamination" OWNER TO postgres;

--
-- Name: LowVisionFrame; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."LowVisionFrame" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "frameId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."LowVisionFrame" OWNER TO postgres;

--
-- Name: LowVisionManufacturer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."LowVisionManufacturer" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "manufacturerId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."LowVisionManufacturer" OWNER TO postgres;

--
-- Name: MessageTemplate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."MessageTemplate" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    language text DEFAULT 'he'::text NOT NULL,
    subject text,
    content text NOT NULL,
    active boolean DEFAULT true NOT NULL,
    "isSystem" boolean DEFAULT false NOT NULL,
    variables jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."MessageTemplate" OWNER TO postgres;

--
-- Name: OpticalBase; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."OpticalBase" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "baseId" integer NOT NULL,
    name text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."OpticalBase" OWNER TO postgres;

--
-- Name: Order; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Order" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "orderNumber" text NOT NULL,
    "orderDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "deliveryDate" timestamp(3) without time zone,
    status text DEFAULT 'PENDING'::text NOT NULL,
    "paymentStatus" text DEFAULT 'PENDING'::text NOT NULL,
    "workType" text,
    "labId" text,
    "supplierId" text,
    "prescriptionId" text,
    subtotal double precision DEFAULT 0 NOT NULL,
    discount double precision DEFAULT 0 NOT NULL,
    "taxAmount" double precision DEFAULT 0 NOT NULL,
    "totalAmount" double precision DEFAULT 0 NOT NULL,
    "paidAmount" double precision DEFAULT 0 NOT NULL,
    "depositAmount" double precision DEFAULT 0 NOT NULL,
    notes text,
    "internalNotes" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "branchId" text
);


ALTER TABLE public."Order" OWNER TO postgres;

--
-- Name: OrderItem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."OrderItem" (
    id text NOT NULL,
    "orderId" text NOT NULL,
    "productId" text,
    "productType" text,
    description text NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    "unitPrice" double precision NOT NULL,
    discount double precision DEFAULT 0 NOT NULL,
    "totalPrice" double precision NOT NULL,
    "lensData" jsonb,
    status text DEFAULT 'PENDING'::text NOT NULL,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."OrderItem" OWNER TO postgres;

--
-- Name: Orthokeratology; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Orthokeratology" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "prescriberId" text,
    "startDate" timestamp(3) without time zone NOT NULL,
    "rightEyeData" text,
    "leftEyeData" text,
    "treatmentPlan" text,
    "progressNotes" text,
    status text DEFAULT 'ACTIVE'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "branchId" text
);


ALTER TABLE public."Orthokeratology" OWNER TO postgres;

--
-- Name: OrthokeratologyTreatment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."OrthokeratologyTreatment" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "customerId" text NOT NULL,
    "orthokId" integer NOT NULL,
    "checkDate" timestamp(3) without time zone NOT NULL,
    "reCheckDate" timestamp(3) without time zone,
    "examinerId" text,
    "keratometryHR" double precision,
    "keratometryHL" double precision,
    "axisHR" double precision,
    "axisHL" double precision,
    "keratometryVR" double precision,
    "keratometryVL" double precision,
    "keratometryTR" double precision,
    "keratometryTL" double precision,
    "keratometryNR" double precision,
    "keratometryNL" double precision,
    "keratometryIR" double precision,
    "keratometryIL" double precision,
    "keratometrySR" double precision,
    "keratometrySL" double precision,
    "diameterR" double precision,
    "diameterL" double precision,
    "baseCurve1R" double precision,
    "baseCurve1L" double precision,
    "opticalZoneR" double precision,
    "opticalZoneL" double precision,
    "sphereR" double precision,
    "sphereL" double precision,
    "fittingCurveR" double precision,
    "fittingCurveL" double precision,
    "alignmentCurveR" double precision,
    "alignmentCurveL" double precision,
    "alignment2CurveR" double precision,
    "alignment2CurveL" double precision,
    "secondaryR" double precision,
    "secondaryL" double precision,
    "edgeR" double precision,
    "edgeL" double precision,
    "fittingCurveThicknessR" double precision,
    "fittingCurveThicknessL" double precision,
    "alignmentCurveThicknessR" double precision,
    "alignmentCurveThicknessL" double precision,
    "alignment2CurveThicknessR" double precision,
    "alignment2CurveThicknessL" double precision,
    "edgeThicknessR" double precision,
    "edgeThicknessL" double precision,
    "opticalZoneThicknessR" double precision,
    "opticalZoneThicknessL" double precision,
    "materialR" integer,
    "materialL" integer,
    "tintR" integer,
    "tintL" integer,
    "visualAcuityR" double precision,
    "visualAcuityL" double precision,
    "visualAcuity" double precision,
    "lensTypeIdR" integer,
    "lensTypeIdL" integer,
    "manufacturerIdR" integer,
    "manufacturerIdL" integer,
    "brandIdR" integer,
    "brandIdL" integer,
    "commentR" text,
    "commentL" text,
    "pictureL" text,
    "pictureR" text,
    "orderId" text,
    "customerId2" text,
    "pupilDiameter" text,
    "cornealDiameter" double precision,
    "eyelidKey" double precision,
    "checkType" integer,
    "eccentricityHR" double precision,
    "eccentricityHL" double precision,
    "eccentricityVR" double precision,
    "eccentricityVL" double precision,
    "eccentricityAR" double precision,
    "eccentricityAL" double precision,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."OrthokeratologyTreatment" OWNER TO postgres;

--
-- Name: Payment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Payment" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "paymentNumber" text NOT NULL,
    "paymentDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "saleId" text,
    "invoiceId" text,
    "customerId" text,
    "paymentType" text NOT NULL,
    amount numeric(10,2) NOT NULL,
    currency text DEFAULT 'ILS'::text NOT NULL,
    "cardLastFour" text,
    "cardType" text,
    "authCode" text,
    "checkNumber" text,
    "checkDate" timestamp(3) without time zone,
    "bankName" text,
    "bankBranch" text,
    "transferRef" text,
    status text DEFAULT 'COMPLETED'::text NOT NULL,
    "receiptNumber" text,
    "receiptIssued" boolean DEFAULT false NOT NULL,
    notes text,
    "createdBy" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Payment" OWNER TO postgres;

--
-- Name: Payroll; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Payroll" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "employeeId" text NOT NULL,
    period text NOT NULL,
    "periodStart" timestamp(3) without time zone NOT NULL,
    "periodEnd" timestamp(3) without time zone NOT NULL,
    "payDate" timestamp(3) without time zone,
    "baseSalary" double precision NOT NULL,
    "hourlyRate" double precision,
    "hoursWorked" double precision DEFAULT 0,
    "overtimeHours" double precision DEFAULT 0,
    "overtimeRate" double precision,
    "commissionAmount" double precision DEFAULT 0 NOT NULL,
    "bonusAmount" double precision DEFAULT 0 NOT NULL,
    "taxDeduction" double precision DEFAULT 0 NOT NULL,
    "socialSecurity" double precision DEFAULT 0 NOT NULL,
    "healthInsurance" double precision DEFAULT 0 NOT NULL,
    "otherDeductions" double precision DEFAULT 0 NOT NULL,
    "deductionNotes" text,
    "grossPay" double precision NOT NULL,
    "netPay" double precision NOT NULL,
    status text DEFAULT 'DRAFT'::text NOT NULL,
    "approvedBy" text,
    "approvedAt" timestamp(3) without time zone,
    "paidAt" timestamp(3) without time zone,
    "paymentMethod" text,
    "paymentRef" text,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Payroll" OWNER TO postgres;

--
-- Name: PhysicalInventoryCount; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."PhysicalInventoryCount" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    status text DEFAULT 'IN_PROGRESS'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "completedAt" timestamp(3) without time zone,
    "countName" text NOT NULL,
    "createdByUserId" text NOT NULL,
    description text,
    "startDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."PhysicalInventoryCount" OWNER TO postgres;

--
-- Name: PhysicalInventoryCountItem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."PhysicalInventoryCountItem" (
    id text NOT NULL,
    "productId" text NOT NULL,
    "countedQuantity" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "physicalCountId" text NOT NULL,
    "systemQuantity" integer DEFAULT 0 NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."PhysicalInventoryCountItem" OWNER TO postgres;

--
-- Name: Prescription; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Prescription" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "doctorId" text,
    "prescriptionDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "validUntil" timestamp(3) without time zone,
    "rightSphere" double precision,
    "rightCylinder" double precision,
    "rightAxis" integer,
    "rightAdd" double precision,
    "rightPrism" double precision,
    "rightBase" text,
    "rightPd" double precision,
    "rightVa" text,
    "leftSphere" double precision,
    "leftCylinder" double precision,
    "leftAxis" integer,
    "leftAdd" double precision,
    "leftPrism" double precision,
    "leftBase" text,
    "leftPd" double precision,
    "leftVa" text,
    pd double precision,
    "pdNear" double precision,
    "fittingHeight" double precision,
    "prescriptionType" text DEFAULT 'DISTANCE'::text NOT NULL,
    notes text,
    recommendations text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "additionalData" jsonb,
    "branchId" text
);


ALTER TABLE public."Prescription" OWNER TO postgres;

--
-- Name: PrescriptionGlassDetail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."PrescriptionGlassDetail" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "prescriptionId" text NOT NULL,
    "glassId" text,
    "roleId" integer,
    "materialId" integer,
    "brandId" integer,
    "coatingId" integer,
    "modelId" integer,
    "colorId" integer,
    diameter double precision,
    segment text,
    comments text,
    "saleAddition" double precision,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."PrescriptionGlassDetail" OWNER TO postgres;

--
-- Name: PrescriptionHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."PrescriptionHistory" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "prescriptionDate" timestamp(3) without time zone NOT NULL,
    "previousId" integer,
    "refRightSphere" double precision,
    "refLeftSphere" double precision,
    "refRightCylinder" double precision,
    "refLeftCylinder" double precision,
    "refRightAxis" integer,
    "refLeftAxis" integer,
    "refRightSphere2" double precision,
    "refLeftSphere2" double precision,
    "refRightCylinder2" double precision,
    "refLeftCylinder2" double precision,
    "refRightAxis2" integer,
    "refLeftAxis2" integer,
    "rightSphere" double precision,
    "leftSphere" double precision,
    "rightCylinder" double precision,
    "leftCylinder" double precision,
    "rightAxis" integer,
    "leftAxis" integer,
    "rightPrism" double precision,
    "leftPrism" double precision,
    "rightBase" text,
    "leftBase" text,
    "rightVa" text,
    "leftVa" text,
    "binocularVa" text,
    "rightPd" double precision,
    "leftPd" double precision,
    pd double precision,
    "rightAdd" double precision,
    "leftAdd" double precision,
    "extRightPrism" double precision,
    "extLeftPrism" double precision,
    "extRightBase" text,
    "extLeftBase" text,
    comments text,
    "retTypeId1" integer,
    "retDistId1" integer,
    "retComment1" text,
    "retTypeId2" integer,
    "retDistId2" integer,
    "retComment2" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."PrescriptionHistory" OWNER TO postgres;

--
-- Name: PriceHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."PriceHistory" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "productId" text NOT NULL,
    "oldPrice" double precision NOT NULL,
    "newPrice" double precision NOT NULL,
    "oldCost" double precision,
    "newCost" double precision,
    "changedBy" text NOT NULL,
    "changedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "priceUpdateId" text,
    reason text
);


ALTER TABLE public."PriceHistory" OWNER TO postgres;

--
-- Name: PriceUpdate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."PriceUpdate" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    name text NOT NULL,
    description text,
    "updateType" text NOT NULL,
    scope text NOT NULL,
    value double precision,
    "roundTo" double precision,
    filters jsonb NOT NULL,
    status text DEFAULT 'DRAFT'::text NOT NULL,
    "scheduledFor" timestamp(3) without time zone,
    "appliedAt" timestamp(3) without time zone,
    "productsUpdated" integer,
    "totalValue" double precision,
    notes text,
    "createdBy" text NOT NULL,
    "appliedBy" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."PriceUpdate" OWNER TO postgres;

--
-- Name: Product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Product" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "productId" text NOT NULL,
    name text NOT NULL,
    description text,
    sku text NOT NULL,
    barcode text,
    category text NOT NULL,
    subcategory text,
    brand text NOT NULL,
    model text,
    "costPrice" double precision DEFAULT 0 NOT NULL,
    "sellPrice" double precision DEFAULT 0 NOT NULL,
    "wholeSalePrice" double precision,
    quantity integer DEFAULT 0 NOT NULL,
    "minQuantity" integer DEFAULT 5,
    unit text DEFAULT 'יחידה'::text NOT NULL,
    location text,
    supplier text,
    "supplierProductCode" text,
    "isActive" boolean DEFAULT true NOT NULL,
    "trackQuantity" boolean DEFAULT true NOT NULL,
    tags text[],
    notes text,
    "lensType" text,
    material text,
    coating text,
    "sphereMin" double precision,
    "sphereMax" double precision,
    "cylinderMin" double precision,
    "cylinderMax" double precision,
    "frameSize" text,
    "frameColor" text,
    "frameShape" text,
    "frameMaterial" text,
    prescription boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "branchId" text,
    "supplierId" text,
    "requiresSerial" boolean DEFAULT false NOT NULL
);


ALTER TABLE public."Product" OWNER TO postgres;

--
-- Name: ProductSerial; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ProductSerial" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "productId" text NOT NULL,
    "serialNumber" text NOT NULL,
    status text NOT NULL,
    "saleItemId" text,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ProductSerial" OWNER TO postgres;

--
-- Name: Purchase; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Purchase" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "purchaseId" text NOT NULL,
    "purchaseDate" timestamp(3) without time zone NOT NULL,
    "customerId" text NOT NULL,
    "userId" text,
    "purchaseType" text,
    "totalAmount" double precision DEFAULT 0 NOT NULL,
    "paidAmount" double precision DEFAULT 0 NOT NULL,
    comment text,
    status text DEFAULT 'PENDING'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "branchId" text
);


ALTER TABLE public."Purchase" OWNER TO postgres;

--
-- Name: PurchaseCheck; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."PurchaseCheck" (
    id text NOT NULL,
    "purchaseId" text NOT NULL,
    "checkNumber" text NOT NULL,
    "bankName" text,
    "checkDate" timestamp(3) without time zone NOT NULL,
    amount double precision NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."PurchaseCheck" OWNER TO postgres;

--
-- Name: PurchasePayment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."PurchasePayment" (
    id text NOT NULL,
    "purchaseId" text NOT NULL,
    "paymentDate" timestamp(3) without time zone NOT NULL,
    amount double precision NOT NULL,
    "paymentMethod" text NOT NULL,
    reference text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."PurchasePayment" OWNER TO postgres;

--
-- Name: RefractionProtocol; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."RefractionProtocol" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    name text NOT NULL,
    description text,
    "isDefault" boolean DEFAULT false NOT NULL,
    steps jsonb NOT NULL,
    "includeAutoref" boolean DEFAULT true NOT NULL,
    "includeRetino" boolean DEFAULT true NOT NULL,
    "includeSubj" boolean DEFAULT true NOT NULL,
    "includeBino" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."RefractionProtocol" OWNER TO postgres;

--
-- Name: RetinoscopyDistance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."RetinoscopyDistance" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "retDistId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."RetinoscopyDistance" OWNER TO postgres;

--
-- Name: RetinoscopyType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."RetinoscopyType" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "retTypeId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."RetinoscopyType" OWNER TO postgres;

--
-- Name: SMS; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SMS" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text,
    message text NOT NULL,
    type text NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    "errorMessage" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "branchId" text,
    cost double precision DEFAULT 0,
    credits integer DEFAULT 1,
    "messageId" text,
    phone text NOT NULL,
    "sentAt" timestamp(3) without time zone,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SMS" OWNER TO postgres;

--
-- Name: Sale; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Sale" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "saleId" text NOT NULL,
    "customerId" text,
    "sellerId" text NOT NULL,
    "saleDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status text DEFAULT 'COMPLETED'::text NOT NULL,
    subtotal double precision DEFAULT 0 NOT NULL,
    "discountAmount" double precision DEFAULT 0 NOT NULL,
    "taxAmount" double precision DEFAULT 0 NOT NULL,
    total double precision DEFAULT 0 NOT NULL,
    "paymentMethod" text,
    "paymentStatus" text DEFAULT 'PAID'::text NOT NULL,
    "prescriptionId" text,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "branchId" text,
    "cashierShiftId" text
);


ALTER TABLE public."Sale" OWNER TO postgres;

--
-- Name: SaleItem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SaleItem" (
    id text NOT NULL,
    "saleId" text NOT NULL,
    "productId" text,
    "productName" text NOT NULL,
    category text,
    sku text,
    quantity integer DEFAULT 1 NOT NULL,
    "unitPrice" double precision NOT NULL,
    "discountPercent" double precision DEFAULT 0 NOT NULL,
    "discountAmount" double precision DEFAULT 0 NOT NULL,
    "lineTotal" double precision NOT NULL,
    "prescriptionData" jsonb,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "barcodeId" text
);


ALTER TABLE public."SaleItem" OWNER TO postgres;

--
-- Name: SlitLampExam; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SlitLampExam" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "examinerId" text,
    "examDate" timestamp(3) without time zone NOT NULL,
    "rightEyeFindings" text,
    "leftEyeFindings" text,
    "additionalNotes" text,
    images text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "branchId" text
);


ALTER TABLE public."SlitLampExam" OWNER TO postgres;

--
-- Name: StockMovement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."StockMovement" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "productId" text NOT NULL,
    "userId" text NOT NULL,
    type text NOT NULL,
    quantity integer NOT NULL,
    "previousQuantity" integer NOT NULL,
    "newQuantity" integer NOT NULL,
    reason text,
    notes text,
    "referenceId" text,
    "costPrice" double precision,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "branchId" text
);


ALTER TABLE public."StockMovement" OWNER TO postgres;

--
-- Name: Supplier; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Supplier" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "supplierId" text NOT NULL,
    name text NOT NULL,
    "contactPerson" text,
    phone text,
    email text,
    address text,
    website text,
    "taxId" text,
    "paymentTerms" text DEFAULT 'NET_30'::text,
    "creditLimit" double precision,
    "accountNumber" text,
    "suppliesFrames" boolean DEFAULT false NOT NULL,
    "suppliesLenses" boolean DEFAULT false NOT NULL,
    "suppliesContactLenses" boolean DEFAULT false NOT NULL,
    "suppliesAccessories" boolean DEFAULT false NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "bankDetails" text,
    city text,
    country text,
    "creditTerms" integer DEFAULT 30,
    fax text,
    "leadTimeDays" integer DEFAULT 7,
    "minimumOrderAmount" double precision DEFAULT 0,
    "nameHe" text,
    "specialInstructions" text,
    "supplierType" text DEFAULT 'OTHER'::text,
    "vatNumber" text,
    "zipCode" text
);


ALTER TABLE public."Supplier" OWNER TO postgres;

--
-- Name: SupplierOrder; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierOrder" (
    id text NOT NULL,
    "supplierId" text NOT NULL,
    "orderNumber" text NOT NULL,
    "orderDate" timestamp(3) without time zone NOT NULL,
    "expectedDate" timestamp(3) without time zone,
    "receivedDate" timestamp(3) without time zone,
    "totalAmount" double precision NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    items text,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "branchId" text,
    "tenantId" text NOT NULL,
    "cancelReason" text,
    "cancelledDate" timestamp(3) without time zone,
    "discountAmount" double precision DEFAULT 0 NOT NULL,
    "lastReceivedDate" timestamp(3) without time zone,
    "paymentTerms" text,
    "receiveNotes" text,
    "receivedBy" text,
    "referenceNumber" text,
    "sentDate" timestamp(3) without time zone,
    "shippingCost" double precision DEFAULT 0 NOT NULL,
    "shippingMethod" text,
    subtotal double precision DEFAULT 0 NOT NULL
);


ALTER TABLE public."SupplierOrder" OWNER TO postgres;

--
-- Name: SupplierOrderItem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierOrderItem" (
    id text NOT NULL,
    "orderId" text NOT NULL,
    "productId" text,
    "itemCode" text NOT NULL,
    "itemDescription" text NOT NULL,
    "quantityOrdered" integer NOT NULL,
    "quantityReceived" integer DEFAULT 0 NOT NULL,
    "quantityBackordered" integer DEFAULT 0 NOT NULL,
    "unitCost" numeric(10,2) NOT NULL,
    discount numeric(5,2) DEFAULT 0 NOT NULL,
    "totalCost" numeric(10,2) NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    "receivedDate" timestamp(3) without time zone,
    "receivedBy" text,
    notes text
);


ALTER TABLE public."SupplierOrderItem" OWNER TO postgres;

--
-- Name: Task; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Task" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    title text NOT NULL,
    description text,
    priority text NOT NULL,
    status text NOT NULL,
    "assignedToId" text,
    "createdById" text NOT NULL,
    "dueDate" timestamp(3) without time zone,
    "completedAt" timestamp(3) without time zone,
    "customerId" text,
    "relatedType" text,
    "relatedId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Task" OWNER TO postgres;

--
-- Name: TaskAttachment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."TaskAttachment" (
    id text NOT NULL,
    "taskId" text NOT NULL,
    "fileName" text NOT NULL,
    "fileUrl" text NOT NULL,
    "fileSize" integer NOT NULL,
    "mimeType" text NOT NULL,
    "uploadedById" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."TaskAttachment" OWNER TO postgres;

--
-- Name: TaskComment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."TaskComment" (
    id text NOT NULL,
    "taskId" text NOT NULL,
    "userId" text NOT NULL,
    comment text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."TaskComment" OWNER TO postgres;

--
-- Name: TaxRate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."TaxRate" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    name text NOT NULL,
    code text NOT NULL,
    rate numeric(5,2) NOT NULL,
    "appliesTo" text[],
    region text,
    "exemptCategories" text[],
    active boolean DEFAULT true NOT NULL,
    "isDefault" boolean DEFAULT false NOT NULL,
    "validFrom" timestamp(3) without time zone,
    "validTo" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."TaxRate" OWNER TO postgres;

--
-- Name: Tenant; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Tenant" (
    id text NOT NULL,
    name text NOT NULL,
    "nameHe" text,
    subdomain text NOT NULL,
    plan text DEFAULT 'professional'::text NOT NULL,
    active boolean DEFAULT true NOT NULL,
    "primaryLanguage" text DEFAULT 'he'::text NOT NULL,
    timezone text DEFAULT 'Asia/Jerusalem'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "ownerId" text
);


ALTER TABLE public."Tenant" OWNER TO postgres;

--
-- Name: TenantSettings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."TenantSettings" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "businessAddress" text,
    "businessPhone" text,
    "businessEmail" text,
    "businessLicense" text,
    "vatNumber" text,
    "defaultTaxRate" double precision DEFAULT 17,
    currency text DEFAULT 'ILS'::text,
    "enableSmsReminders" boolean DEFAULT true,
    "enableEmailReminders" boolean DEFAULT true,
    "reminderHoursBefore" integer DEFAULT 24,
    "defaultAppointmentDuration" integer DEFAULT 30,
    "workingHoursStart" text DEFAULT '09:00'::text,
    "workingHoursEnd" text DEFAULT '18:00'::text,
    "workingDays" text[] DEFAULT ARRAY['sunday'::text, 'monday'::text, 'tuesday'::text, 'wednesday'::text, 'thursday'::text],
    "enableOnlineBooking" boolean DEFAULT false,
    "receiptTemplate" text,
    "prescriptionTemplate" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "communicationCredits" double precision DEFAULT 0,
    "emailCostPerMessage" double precision DEFAULT 0.01,
    "monthlyEmailBudget" double precision,
    "monthlySmsBudget" double precision,
    "smsCostPerMessage" double precision DEFAULT 0.10,
    "businessTaxId" text
);


ALTER TABLE public."TenantSettings" OWNER TO postgres;

--
-- Name: User; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."User" (
    id text NOT NULL,
    "tenantId" text,
    email text NOT NULL,
    password text NOT NULL,
    "firstName" text NOT NULL,
    "lastName" text NOT NULL,
    "firstNameHe" text,
    "lastNameHe" text,
    role text DEFAULT 'EMPLOYEE'::text NOT NULL,
    active boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "lastLoginAt" timestamp(3) without time zone,
    "branchId" text
);


ALTER TABLE public."User" OWNER TO postgres;

--
-- Name: UserSettings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."UserSettings" (
    id text NOT NULL,
    "userId" text NOT NULL,
    phone text,
    "preferredLanguage" text DEFAULT 'he'::text,
    theme text DEFAULT 'light'::text,
    "emailNotifications" boolean DEFAULT true,
    "smsNotifications" boolean DEFAULT true,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."UserSettings" OWNER TO postgres;

--
-- Name: VisionTest; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."VisionTest" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "examinerId" text,
    "testDate" timestamp(3) without time zone NOT NULL,
    "testType" text NOT NULL,
    "rightEye" text,
    "leftEye" text,
    binocular text,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "branchId" text
);


ALTER TABLE public."VisionTest" OWNER TO postgres;

--
-- Name: WorkLab; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."WorkLab" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "labId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."WorkLab" OWNER TO postgres;

--
-- Name: WorkLabel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."WorkLabel" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "labelId" integer NOT NULL,
    name text NOT NULL,
    "itemCode" text NOT NULL,
    "supplierId" integer NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."WorkLabel" OWNER TO postgres;

--
-- Name: WorkOrder; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."WorkOrder" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "workOrderNumber" text NOT NULL,
    "orderDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "dueDate" timestamp(3) without time zone,
    "customerId" text NOT NULL,
    "saleId" text,
    "prescriptionId" text,
    "orderType" text NOT NULL,
    priority text DEFAULT 'NORMAL'::text NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    "labStatus" text,
    "labOrderNumber" text,
    "labId" text,
    "supplierId" text,
    "sentToLabDate" timestamp(3) without time zone,
    "receivedDate" timestamp(3) without time zone,
    "deliveredDate" timestamp(3) without time zone,
    "frameId" text,
    "frameModel" text,
    "frameColor" text,
    "frameSize" text,
    "rightLensId" text,
    "rightLensType" text,
    "rightLensMaterial" text,
    "rightLensCoating" text,
    "rightLensTint" text,
    "rightLensDetails" jsonb,
    "leftLensId" text,
    "leftLensType" text,
    "leftLensMaterial" text,
    "leftLensCoating" text,
    "leftLensTint" text,
    "leftLensDetails" jsonb,
    "rightSphere" numeric(5,2),
    "rightCylinder" numeric(5,2),
    "rightAxis" integer,
    "rightAdd" numeric(4,2),
    "rightPrism" numeric(4,2),
    "rightPrismBase" text,
    "leftSphere" numeric(5,2),
    "leftCylinder" numeric(5,2),
    "leftAxis" integer,
    "leftAdd" numeric(4,2),
    "leftPrism" numeric(4,2),
    "leftPrismBase" text,
    pd numeric(4,1),
    "specialInstructions" text,
    "internalNotes" text,
    "labNotes" text,
    "qcCheckedBy" text,
    "qcCheckedDate" timestamp(3) without time zone,
    "qcNotes" text,
    remake boolean DEFAULT false NOT NULL,
    "remakeReason" text,
    "originalOrderId" text,
    "frameCost" numeric(10,2),
    "rightLensCost" numeric(10,2),
    "leftLensCost" numeric(10,2),
    "labCharges" numeric(10,2),
    "totalCost" numeric(10,2),
    "createdBy" text NOT NULL,
    "updatedBy" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."WorkOrder" OWNER TO postgres;

--
-- Name: WorkOrderStatus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."WorkOrderStatus" (
    id text NOT NULL,
    "workOrderId" text NOT NULL,
    status text NOT NULL,
    notes text,
    "changedBy" text NOT NULL,
    "changedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."WorkOrderStatus" OWNER TO postgres;

--
-- Name: WorkStatus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."WorkStatus" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "statusId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."WorkStatus" OWNER TO postgres;

--
-- Name: WorkSupplier; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."WorkSupplier" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "supplierId" integer NOT NULL,
    name text NOT NULL,
    "itemCode" text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."WorkSupplier" OWNER TO postgres;

--
-- Name: WorkSupplyType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."WorkSupplyType" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "supplyTypeId" integer NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."WorkSupplyType" OWNER TO postgres;

--
-- Name: ZipCode; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ZipCode" (
    id text NOT NULL,
    "zipCode" text NOT NULL,
    city text NOT NULL,
    "cityHe" text,
    street text,
    "streetHe" text,
    region text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."ZipCode" OWNER TO postgres;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO postgres;

--
-- Name: AdvancedExamination AdvancedExamination_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AdvancedExamination"
    ADD CONSTRAINT "AdvancedExamination_pkey" PRIMARY KEY (id);


--
-- Name: Appointment Appointment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Appointment"
    ADD CONSTRAINT "Appointment_pkey" PRIMARY KEY (id);


--
-- Name: BarcodeManagement BarcodeManagement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BarcodeManagement"
    ADD CONSTRAINT "BarcodeManagement_pkey" PRIMARY KEY (id);


--
-- Name: Branch Branch_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Branch"
    ADD CONSTRAINT "Branch_pkey" PRIMARY KEY (id);


--
-- Name: Brand Brand_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Brand"
    ADD CONSTRAINT "Brand_pkey" PRIMARY KEY (id);


--
-- Name: CashDrawerEvent CashDrawerEvent_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CashDrawerEvent"
    ADD CONSTRAINT "CashDrawerEvent_pkey" PRIMARY KEY (id);


--
-- Name: CashReconciliation CashReconciliation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CashReconciliation"
    ADD CONSTRAINT "CashReconciliation_pkey" PRIMARY KEY (id);


--
-- Name: CashierShift CashierShift_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CashierShift"
    ADD CONSTRAINT "CashierShift_pkey" PRIMARY KEY (id);


--
-- Name: CheckType CheckType_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CheckType"
    ADD CONSTRAINT "CheckType_pkey" PRIMARY KEY (id);


--
-- Name: City City_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."City"
    ADD CONSTRAINT "City_pkey" PRIMARY KEY (id);


--
-- Name: ClinicalDiagnosis ClinicalDiagnosis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalDiagnosis"
    ADD CONSTRAINT "ClinicalDiagnosis_pkey" PRIMARY KEY (id);


--
-- Name: ClinicalExamination ClinicalExamination_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalExamination"
    ADD CONSTRAINT "ClinicalExamination_pkey" PRIMARY KEY (id);


--
-- Name: CommissionRule CommissionRule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CommissionRule"
    ADD CONSTRAINT "CommissionRule_pkey" PRIMARY KEY (id);


--
-- Name: Commission Commission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Commission"
    ADD CONSTRAINT "Commission_pkey" PRIMARY KEY (id);


--
-- Name: CommunicationCampaign CommunicationCampaign_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CommunicationCampaign"
    ADD CONSTRAINT "CommunicationCampaign_pkey" PRIMARY KEY (id);


--
-- Name: CommunicationLog CommunicationLog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CommunicationLog"
    ADD CONSTRAINT "CommunicationLog_pkey" PRIMARY KEY (id);


--
-- Name: CommunicationSchedule CommunicationSchedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CommunicationSchedule"
    ADD CONSTRAINT "CommunicationSchedule_pkey" PRIMARY KEY (id);


--
-- Name: ContactAgent ContactAgent_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactAgent"
    ADD CONSTRAINT "ContactAgent_pkey" PRIMARY KEY (id);


--
-- Name: ContactLensBrand ContactLensBrand_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensBrand"
    ADD CONSTRAINT "ContactLensBrand_pkey" PRIMARY KEY (id);


--
-- Name: ContactLensCleaningSolution ContactLensCleaningSolution_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensCleaningSolution"
    ADD CONSTRAINT "ContactLensCleaningSolution_pkey" PRIMARY KEY (id);


--
-- Name: ContactLensDisinfectingSolution ContactLensDisinfectingSolution_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensDisinfectingSolution"
    ADD CONSTRAINT "ContactLensDisinfectingSolution_pkey" PRIMARY KEY (id);


--
-- Name: ContactLensExamination ContactLensExamination_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensExamination"
    ADD CONSTRAINT "ContactLensExamination_pkey" PRIMARY KEY (id);


--
-- Name: ContactLensFittingDetail ContactLensFittingDetail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensFittingDetail"
    ADD CONSTRAINT "ContactLensFittingDetail_pkey" PRIMARY KEY (id);


--
-- Name: ContactLensFitting ContactLensFitting_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensFitting"
    ADD CONSTRAINT "ContactLensFitting_pkey" PRIMARY KEY (id);


--
-- Name: ContactLensManufacturer ContactLensManufacturer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensManufacturer"
    ADD CONSTRAINT "ContactLensManufacturer_pkey" PRIMARY KEY (id);


--
-- Name: ContactLensMaterial ContactLensMaterial_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensMaterial"
    ADD CONSTRAINT "ContactLensMaterial_pkey" PRIMARY KEY (id);


--
-- Name: ContactLensPrescription ContactLensPrescription_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensPrescription"
    ADD CONSTRAINT "ContactLensPrescription_pkey" PRIMARY KEY (id);


--
-- Name: ContactLensRinsingSolution ContactLensRinsingSolution_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensRinsingSolution"
    ADD CONSTRAINT "ContactLensRinsingSolution_pkey" PRIMARY KEY (id);


--
-- Name: ContactLensTint ContactLensTint_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensTint"
    ADD CONSTRAINT "ContactLensTint_pkey" PRIMARY KEY (id);


--
-- Name: ContactLensType ContactLensType_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensType"
    ADD CONSTRAINT "ContactLensType_pkey" PRIMARY KEY (id);


--
-- Name: CreditCardTransaction CreditCardTransaction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CreditCardTransaction"
    ADD CONSTRAINT "CreditCardTransaction_pkey" PRIMARY KEY (id);


--
-- Name: CustomerGroup CustomerGroup_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CustomerGroup"
    ADD CONSTRAINT "CustomerGroup_pkey" PRIMARY KEY (id);


--
-- Name: CustomerPhoto CustomerPhoto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CustomerPhoto"
    ADD CONSTRAINT "CustomerPhoto_pkey" PRIMARY KEY (id);


--
-- Name: Customer Customer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Customer"
    ADD CONSTRAINT "Customer_pkey" PRIMARY KEY (id);


--
-- Name: DetailedWorkOrder DetailedWorkOrder_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DetailedWorkOrder"
    ADD CONSTRAINT "DetailedWorkOrder_pkey" PRIMARY KEY (id);


--
-- Name: Diagnosis Diagnosis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Diagnosis"
    ADD CONSTRAINT "Diagnosis_pkey" PRIMARY KEY (id);


--
-- Name: DiagnosticProtocol DiagnosticProtocol_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DiagnosticProtocol"
    ADD CONSTRAINT "DiagnosticProtocol_pkey" PRIMARY KEY (id);


--
-- Name: Discount Discount_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Discount"
    ADD CONSTRAINT "Discount_pkey" PRIMARY KEY (id);


--
-- Name: DocumentTemplate DocumentTemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DocumentTemplate"
    ADD CONSTRAINT "DocumentTemplate_pkey" PRIMARY KEY (id);


--
-- Name: Document Document_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Document"
    ADD CONSTRAINT "Document_pkey" PRIMARY KEY (id);


--
-- Name: EmployeeCommissionRule EmployeeCommissionRule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EmployeeCommissionRule"
    ADD CONSTRAINT "EmployeeCommissionRule_pkey" PRIMARY KEY (id);


--
-- Name: ExaminationOverview ExaminationOverview_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ExaminationOverview"
    ADD CONSTRAINT "ExaminationOverview_pkey" PRIMARY KEY (id);


--
-- Name: Examination Examination_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Examination"
    ADD CONSTRAINT "Examination_pkey" PRIMARY KEY (id);


--
-- Name: Expense Expense_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Expense"
    ADD CONSTRAINT "Expense_pkey" PRIMARY KEY (id);


--
-- Name: FRPLine FRPLine_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FRPLine"
    ADD CONSTRAINT "FRPLine_pkey" PRIMARY KEY (id);


--
-- Name: FollowUp FollowUp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FollowUp"
    ADD CONSTRAINT "FollowUp_pkey" PRIMARY KEY (id);


--
-- Name: FrameCatalog FrameCatalog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FrameCatalog"
    ADD CONSTRAINT "FrameCatalog_pkey" PRIMARY KEY (id);


--
-- Name: Frame Frame_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Frame"
    ADD CONSTRAINT "Frame_pkey" PRIMARY KEY (id);


--
-- Name: FrequentReplacementProgramDetail FrequentReplacementProgramDetail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FrequentReplacementProgramDetail"
    ADD CONSTRAINT "FrequentReplacementProgramDetail_pkey" PRIMARY KEY (id);


--
-- Name: FrequentReplacementProgram FrequentReplacementProgram_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FrequentReplacementProgram"
    ADD CONSTRAINT "FrequentReplacementProgram_pkey" PRIMARY KEY (id);


--
-- Name: FrpDelivery FrpDelivery_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FrpDelivery"
    ADD CONSTRAINT "FrpDelivery_pkey" PRIMARY KEY (id);


--
-- Name: GlassBrand GlassBrand_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassBrand"
    ADD CONSTRAINT "GlassBrand_pkey" PRIMARY KEY (id);


--
-- Name: GlassCoating GlassCoating_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassCoating"
    ADD CONSTRAINT "GlassCoating_pkey" PRIMARY KEY (id);


--
-- Name: GlassColor GlassColor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassColor"
    ADD CONSTRAINT "GlassColor_pkey" PRIMARY KEY (id);


--
-- Name: GlassExamination GlassExamination_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassExamination"
    ADD CONSTRAINT "GlassExamination_pkey" PRIMARY KEY (id);


--
-- Name: GlassMaterial GlassMaterial_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassMaterial"
    ADD CONSTRAINT "GlassMaterial_pkey" PRIMARY KEY (id);


--
-- Name: GlassModel GlassModel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassModel"
    ADD CONSTRAINT "GlassModel_pkey" PRIMARY KEY (id);


--
-- Name: GlassPrescriptionDetail GlassPrescriptionDetail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassPrescriptionDetail"
    ADD CONSTRAINT "GlassPrescriptionDetail_pkey" PRIMARY KEY (id);


--
-- Name: GlassPrescription GlassPrescription_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassPrescription"
    ADD CONSTRAINT "GlassPrescription_pkey" PRIMARY KEY (id);


--
-- Name: GlassRole GlassRole_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassRole"
    ADD CONSTRAINT "GlassRole_pkey" PRIMARY KEY (id);


--
-- Name: GlassUse GlassUse_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassUse"
    ADD CONSTRAINT "GlassUse_pkey" PRIMARY KEY (id);


--
-- Name: InventoryAdjustmentItem InventoryAdjustmentItem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InventoryAdjustmentItem"
    ADD CONSTRAINT "InventoryAdjustmentItem_pkey" PRIMARY KEY (id);


--
-- Name: InventoryAdjustment InventoryAdjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InventoryAdjustment"
    ADD CONSTRAINT "InventoryAdjustment_pkey" PRIMARY KEY (id);


--
-- Name: InvoiceCredit InvoiceCredit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InvoiceCredit"
    ADD CONSTRAINT "InvoiceCredit_pkey" PRIMARY KEY (id);


--
-- Name: InvoicePayment InvoicePayment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InvoicePayment"
    ADD CONSTRAINT "InvoicePayment_pkey" PRIMARY KEY (id);


--
-- Name: Invoice Invoice_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Invoice"
    ADD CONSTRAINT "Invoice_pkey" PRIMARY KEY (id);


--
-- Name: LabelPrintJob LabelPrintJob_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LabelPrintJob"
    ADD CONSTRAINT "LabelPrintJob_pkey" PRIMARY KEY (id);


--
-- Name: LabelTemplate LabelTemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LabelTemplate"
    ADD CONSTRAINT "LabelTemplate_pkey" PRIMARY KEY (id);


--
-- Name: LensCatalog LensCatalog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LensCatalog"
    ADD CONSTRAINT "LensCatalog_pkey" PRIMARY KEY (id);


--
-- Name: LensCharacteristic LensCharacteristic_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LensCharacteristic"
    ADD CONSTRAINT "LensCharacteristic_pkey" PRIMARY KEY (id);


--
-- Name: LensMaterial LensMaterial_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LensMaterial"
    ADD CONSTRAINT "LensMaterial_pkey" PRIMARY KEY (id);


--
-- Name: LensTreatmentCharacteristic LensTreatmentCharacteristic_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LensTreatmentCharacteristic"
    ADD CONSTRAINT "LensTreatmentCharacteristic_pkey" PRIMARY KEY (id);


--
-- Name: LensType LensType_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LensType"
    ADD CONSTRAINT "LensType_pkey" PRIMARY KEY (id);


--
-- Name: Lens Lens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Lens"
    ADD CONSTRAINT "Lens_pkey" PRIMARY KEY (id);


--
-- Name: Letter Letter_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Letter"
    ADD CONSTRAINT "Letter_pkey" PRIMARY KEY (id);


--
-- Name: LowVisionArea LowVisionArea_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LowVisionArea"
    ADD CONSTRAINT "LowVisionArea_pkey" PRIMARY KEY (id);


--
-- Name: LowVisionCap LowVisionCap_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LowVisionCap"
    ADD CONSTRAINT "LowVisionCap_pkey" PRIMARY KEY (id);


--
-- Name: LowVisionCheck LowVisionCheck_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LowVisionCheck"
    ADD CONSTRAINT "LowVisionCheck_pkey" PRIMARY KEY (id);


--
-- Name: LowVisionExamination LowVisionExamination_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LowVisionExamination"
    ADD CONSTRAINT "LowVisionExamination_pkey" PRIMARY KEY (id);


--
-- Name: LowVisionFrame LowVisionFrame_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LowVisionFrame"
    ADD CONSTRAINT "LowVisionFrame_pkey" PRIMARY KEY (id);


--
-- Name: LowVisionManufacturer LowVisionManufacturer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LowVisionManufacturer"
    ADD CONSTRAINT "LowVisionManufacturer_pkey" PRIMARY KEY (id);


--
-- Name: MessageTemplate MessageTemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MessageTemplate"
    ADD CONSTRAINT "MessageTemplate_pkey" PRIMARY KEY (id);


--
-- Name: OpticalBase OpticalBase_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OpticalBase"
    ADD CONSTRAINT "OpticalBase_pkey" PRIMARY KEY (id);


--
-- Name: OrderItem OrderItem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderItem"
    ADD CONSTRAINT "OrderItem_pkey" PRIMARY KEY (id);


--
-- Name: Order Order_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order"
    ADD CONSTRAINT "Order_pkey" PRIMARY KEY (id);


--
-- Name: OrthokeratologyTreatment OrthokeratologyTreatment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrthokeratologyTreatment"
    ADD CONSTRAINT "OrthokeratologyTreatment_pkey" PRIMARY KEY (id);


--
-- Name: Orthokeratology Orthokeratology_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Orthokeratology"
    ADD CONSTRAINT "Orthokeratology_pkey" PRIMARY KEY (id);


--
-- Name: Payment Payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_pkey" PRIMARY KEY (id);


--
-- Name: Payroll Payroll_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payroll"
    ADD CONSTRAINT "Payroll_pkey" PRIMARY KEY (id);


--
-- Name: PhysicalInventoryCountItem PhysicalInventoryCountItem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PhysicalInventoryCountItem"
    ADD CONSTRAINT "PhysicalInventoryCountItem_pkey" PRIMARY KEY (id);


--
-- Name: PhysicalInventoryCount PhysicalInventoryCount_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PhysicalInventoryCount"
    ADD CONSTRAINT "PhysicalInventoryCount_pkey" PRIMARY KEY (id);


--
-- Name: PrescriptionGlassDetail PrescriptionGlassDetail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PrescriptionGlassDetail"
    ADD CONSTRAINT "PrescriptionGlassDetail_pkey" PRIMARY KEY (id);


--
-- Name: PrescriptionHistory PrescriptionHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PrescriptionHistory"
    ADD CONSTRAINT "PrescriptionHistory_pkey" PRIMARY KEY (id);


--
-- Name: Prescription Prescription_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Prescription"
    ADD CONSTRAINT "Prescription_pkey" PRIMARY KEY (id);


--
-- Name: PriceHistory PriceHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PriceHistory"
    ADD CONSTRAINT "PriceHistory_pkey" PRIMARY KEY (id);


--
-- Name: PriceUpdate PriceUpdate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PriceUpdate"
    ADD CONSTRAINT "PriceUpdate_pkey" PRIMARY KEY (id);


--
-- Name: ProductSerial ProductSerial_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductSerial"
    ADD CONSTRAINT "ProductSerial_pkey" PRIMARY KEY (id);


--
-- Name: Product Product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Product"
    ADD CONSTRAINT "Product_pkey" PRIMARY KEY (id);


--
-- Name: PurchaseCheck PurchaseCheck_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PurchaseCheck"
    ADD CONSTRAINT "PurchaseCheck_pkey" PRIMARY KEY (id);


--
-- Name: PurchasePayment PurchasePayment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PurchasePayment"
    ADD CONSTRAINT "PurchasePayment_pkey" PRIMARY KEY (id);


--
-- Name: Purchase Purchase_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Purchase"
    ADD CONSTRAINT "Purchase_pkey" PRIMARY KEY (id);


--
-- Name: RefractionProtocol RefractionProtocol_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."RefractionProtocol"
    ADD CONSTRAINT "RefractionProtocol_pkey" PRIMARY KEY (id);


--
-- Name: RetinoscopyDistance RetinoscopyDistance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."RetinoscopyDistance"
    ADD CONSTRAINT "RetinoscopyDistance_pkey" PRIMARY KEY (id);


--
-- Name: RetinoscopyType RetinoscopyType_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."RetinoscopyType"
    ADD CONSTRAINT "RetinoscopyType_pkey" PRIMARY KEY (id);


--
-- Name: SMS SMS_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SMS"
    ADD CONSTRAINT "SMS_pkey" PRIMARY KEY (id);


--
-- Name: SaleItem SaleItem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SaleItem"
    ADD CONSTRAINT "SaleItem_pkey" PRIMARY KEY (id);


--
-- Name: Sale Sale_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sale"
    ADD CONSTRAINT "Sale_pkey" PRIMARY KEY (id);


--
-- Name: SlitLampExam SlitLampExam_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SlitLampExam"
    ADD CONSTRAINT "SlitLampExam_pkey" PRIMARY KEY (id);


--
-- Name: StockMovement StockMovement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."StockMovement"
    ADD CONSTRAINT "StockMovement_pkey" PRIMARY KEY (id);


--
-- Name: SupplierOrderItem SupplierOrderItem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierOrderItem"
    ADD CONSTRAINT "SupplierOrderItem_pkey" PRIMARY KEY (id);


--
-- Name: SupplierOrder SupplierOrder_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierOrder"
    ADD CONSTRAINT "SupplierOrder_pkey" PRIMARY KEY (id);


--
-- Name: Supplier Supplier_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Supplier"
    ADD CONSTRAINT "Supplier_pkey" PRIMARY KEY (id);


--
-- Name: TaskAttachment TaskAttachment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TaskAttachment"
    ADD CONSTRAINT "TaskAttachment_pkey" PRIMARY KEY (id);


--
-- Name: TaskComment TaskComment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TaskComment"
    ADD CONSTRAINT "TaskComment_pkey" PRIMARY KEY (id);


--
-- Name: Task Task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Task"
    ADD CONSTRAINT "Task_pkey" PRIMARY KEY (id);


--
-- Name: TaxRate TaxRate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TaxRate"
    ADD CONSTRAINT "TaxRate_pkey" PRIMARY KEY (id);


--
-- Name: TenantSettings TenantSettings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TenantSettings"
    ADD CONSTRAINT "TenantSettings_pkey" PRIMARY KEY (id);


--
-- Name: Tenant Tenant_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Tenant"
    ADD CONSTRAINT "Tenant_pkey" PRIMARY KEY (id);


--
-- Name: UserSettings UserSettings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."UserSettings"
    ADD CONSTRAINT "UserSettings_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: VisionTest VisionTest_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."VisionTest"
    ADD CONSTRAINT "VisionTest_pkey" PRIMARY KEY (id);


--
-- Name: WorkLab WorkLab_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkLab"
    ADD CONSTRAINT "WorkLab_pkey" PRIMARY KEY (id);


--
-- Name: WorkLabel WorkLabel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkLabel"
    ADD CONSTRAINT "WorkLabel_pkey" PRIMARY KEY (id);


--
-- Name: WorkOrderStatus WorkOrderStatus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkOrderStatus"
    ADD CONSTRAINT "WorkOrderStatus_pkey" PRIMARY KEY (id);


--
-- Name: WorkOrder WorkOrder_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkOrder"
    ADD CONSTRAINT "WorkOrder_pkey" PRIMARY KEY (id);


--
-- Name: WorkStatus WorkStatus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkStatus"
    ADD CONSTRAINT "WorkStatus_pkey" PRIMARY KEY (id);


--
-- Name: WorkSupplier WorkSupplier_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkSupplier"
    ADD CONSTRAINT "WorkSupplier_pkey" PRIMARY KEY (id);


--
-- Name: WorkSupplyType WorkSupplyType_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkSupplyType"
    ADD CONSTRAINT "WorkSupplyType_pkey" PRIMARY KEY (id);


--
-- Name: ZipCode ZipCode_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ZipCode"
    ADD CONSTRAINT "ZipCode_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: AdvancedExamination_examinationId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "AdvancedExamination_examinationId_key" ON public."AdvancedExamination" USING btree ("examinationId");


--
-- Name: AdvancedExamination_tenantId_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "AdvancedExamination_tenantId_customerId_idx" ON public."AdvancedExamination" USING btree ("tenantId", "customerId");


--
-- Name: AdvancedExamination_tenantId_examDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "AdvancedExamination_tenantId_examDate_idx" ON public."AdvancedExamination" USING btree ("tenantId", "examDate");


--
-- Name: AdvancedExamination_tenantId_examinerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "AdvancedExamination_tenantId_examinerId_idx" ON public."AdvancedExamination" USING btree ("tenantId", "examinerId");


--
-- Name: Appointment_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Appointment_customerId_idx" ON public."Appointment" USING btree ("customerId");


--
-- Name: Appointment_tenantId_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Appointment_tenantId_date_idx" ON public."Appointment" USING btree ("tenantId", date);


--
-- Name: BarcodeManagement_barcode_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "BarcodeManagement_barcode_idx" ON public."BarcodeManagement" USING btree (barcode);


--
-- Name: BarcodeManagement_barcode_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "BarcodeManagement_barcode_key" ON public."BarcodeManagement" USING btree (barcode);


--
-- Name: BarcodeManagement_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "BarcodeManagement_tenantId_idx" ON public."BarcodeManagement" USING btree ("tenantId");


--
-- Name: Branch_managerId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Branch_managerId_key" ON public."Branch" USING btree ("managerId");


--
-- Name: Branch_tenantId_code_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Branch_tenantId_code_key" ON public."Branch" USING btree ("tenantId", code);


--
-- Name: Branch_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Branch_tenantId_idx" ON public."Branch" USING btree ("tenantId");


--
-- Name: Brand_tenantId_name_type_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Brand_tenantId_name_type_key" ON public."Brand" USING btree ("tenantId", name, type);


--
-- Name: CashDrawerEvent_tenantId_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CashDrawerEvent_tenantId_branchId_idx" ON public."CashDrawerEvent" USING btree ("tenantId", "branchId");


--
-- Name: CashDrawerEvent_tenantId_shiftId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CashDrawerEvent_tenantId_shiftId_idx" ON public."CashDrawerEvent" USING btree ("tenantId", "shiftId");


--
-- Name: CashReconciliation_tenantId_shiftId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CashReconciliation_tenantId_shiftId_idx" ON public."CashReconciliation" USING btree ("tenantId", "shiftId");


--
-- Name: CashierShift_tenantId_branchId_shiftNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "CashierShift_tenantId_branchId_shiftNumber_key" ON public."CashierShift" USING btree ("tenantId", "branchId", "shiftNumber");


--
-- Name: CashierShift_tenantId_branchId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CashierShift_tenantId_branchId_status_idx" ON public."CashierShift" USING btree ("tenantId", "branchId", status);


--
-- Name: CashierShift_tenantId_branchId_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CashierShift_tenantId_branchId_userId_idx" ON public."CashierShift" USING btree ("tenantId", "branchId", "userId");


--
-- Name: CheckType_checkId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "CheckType_checkId_key" ON public."CheckType" USING btree ("checkId");


--
-- Name: CheckType_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CheckType_tenantId_idx" ON public."CheckType" USING btree ("tenantId");


--
-- Name: City_cityId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "City_cityId_key" ON public."City" USING btree ("cityId");


--
-- Name: City_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "City_tenantId_idx" ON public."City" USING btree ("tenantId");


--
-- Name: ClinicalDiagnosis_checkDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalDiagnosis_checkDate_idx" ON public."ClinicalDiagnosis" USING btree ("checkDate");


--
-- Name: ClinicalDiagnosis_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalDiagnosis_customerId_idx" ON public."ClinicalDiagnosis" USING btree ("customerId");


--
-- Name: ClinicalDiagnosis_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalDiagnosis_tenantId_idx" ON public."ClinicalDiagnosis" USING btree ("tenantId");


--
-- Name: ClinicalExamination_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalExamination_customerId_idx" ON public."ClinicalExamination" USING btree ("customerId");


--
-- Name: ClinicalExamination_examDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalExamination_examDate_idx" ON public."ClinicalExamination" USING btree ("examDate");


--
-- Name: CommissionRule_tenantId_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CommissionRule_tenantId_isActive_idx" ON public."CommissionRule" USING btree ("tenantId", "isActive");


--
-- Name: Commission_saleId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Commission_saleId_idx" ON public."Commission" USING btree ("saleId");


--
-- Name: Commission_tenantId_employeeId_period_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Commission_tenantId_employeeId_period_idx" ON public."Commission" USING btree ("tenantId", "employeeId", period);


--
-- Name: Commission_tenantId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Commission_tenantId_status_idx" ON public."Commission" USING btree ("tenantId", status);


--
-- Name: CommunicationCampaign_tenantId_scheduledAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CommunicationCampaign_tenantId_scheduledAt_idx" ON public."CommunicationCampaign" USING btree ("tenantId", "scheduledAt");


--
-- Name: CommunicationCampaign_tenantId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CommunicationCampaign_tenantId_status_idx" ON public."CommunicationCampaign" USING btree ("tenantId", status);


--
-- Name: CommunicationLog_campaignId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CommunicationLog_campaignId_idx" ON public."CommunicationLog" USING btree ("campaignId");


--
-- Name: CommunicationLog_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CommunicationLog_customerId_idx" ON public."CommunicationLog" USING btree ("customerId");


--
-- Name: CommunicationLog_tenantId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CommunicationLog_tenantId_status_idx" ON public."CommunicationLog" USING btree ("tenantId", status);


--
-- Name: CommunicationLog_type_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CommunicationLog_type_status_idx" ON public."CommunicationLog" USING btree (type, status);


--
-- Name: CommunicationSchedule_nextRunAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CommunicationSchedule_nextRunAt_idx" ON public."CommunicationSchedule" USING btree ("nextRunAt");


--
-- Name: CommunicationSchedule_tenantId_active_scheduleType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CommunicationSchedule_tenantId_active_scheduleType_idx" ON public."CommunicationSchedule" USING btree ("tenantId", active, "scheduleType");


--
-- Name: ContactAgent_customerId_agentType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactAgent_customerId_agentType_idx" ON public."ContactAgent" USING btree ("customerId", "agentType");


--
-- Name: ContactAgent_tenantId_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactAgent_tenantId_customerId_idx" ON public."ContactAgent" USING btree ("tenantId", "customerId");


--
-- Name: ContactLensBrand_brandId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ContactLensBrand_brandId_key" ON public."ContactLensBrand" USING btree ("brandId");


--
-- Name: ContactLensBrand_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactLensBrand_tenantId_idx" ON public."ContactLensBrand" USING btree ("tenantId");


--
-- Name: ContactLensCleaningSolution_solutionId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ContactLensCleaningSolution_solutionId_key" ON public."ContactLensCleaningSolution" USING btree ("solutionId");


--
-- Name: ContactLensCleaningSolution_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactLensCleaningSolution_tenantId_idx" ON public."ContactLensCleaningSolution" USING btree ("tenantId");


--
-- Name: ContactLensDisinfectingSolution_solutionId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ContactLensDisinfectingSolution_solutionId_key" ON public."ContactLensDisinfectingSolution" USING btree ("solutionId");


--
-- Name: ContactLensDisinfectingSolution_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactLensDisinfectingSolution_tenantId_idx" ON public."ContactLensDisinfectingSolution" USING btree ("tenantId");


--
-- Name: ContactLensExamination_checkDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactLensExamination_checkDate_idx" ON public."ContactLensExamination" USING btree ("checkDate");


--
-- Name: ContactLensExamination_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactLensExamination_customerId_idx" ON public."ContactLensExamination" USING btree ("customerId");


--
-- Name: ContactLensExamination_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactLensExamination_tenantId_idx" ON public."ContactLensExamination" USING btree ("tenantId");


--
-- Name: ContactLensFittingDetail_checkDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactLensFittingDetail_checkDate_idx" ON public."ContactLensFittingDetail" USING btree ("checkDate");


--
-- Name: ContactLensFittingDetail_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactLensFittingDetail_customerId_idx" ON public."ContactLensFittingDetail" USING btree ("customerId");


--
-- Name: ContactLensFittingDetail_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactLensFittingDetail_tenantId_idx" ON public."ContactLensFittingDetail" USING btree ("tenantId");


--
-- Name: ContactLensFitting_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactLensFitting_customerId_idx" ON public."ContactLensFitting" USING btree ("customerId");


--
-- Name: ContactLensFitting_fittingDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactLensFitting_fittingDate_idx" ON public."ContactLensFitting" USING btree ("fittingDate");


--
-- Name: ContactLensManufacturer_manufacturerId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ContactLensManufacturer_manufacturerId_key" ON public."ContactLensManufacturer" USING btree ("manufacturerId");


--
-- Name: ContactLensManufacturer_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactLensManufacturer_tenantId_idx" ON public."ContactLensManufacturer" USING btree ("tenantId");


--
-- Name: ContactLensMaterial_materialId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ContactLensMaterial_materialId_key" ON public."ContactLensMaterial" USING btree ("materialId");


--
-- Name: ContactLensMaterial_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactLensMaterial_tenantId_idx" ON public."ContactLensMaterial" USING btree ("tenantId");


--
-- Name: ContactLensPrescription_tenantId_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactLensPrescription_tenantId_customerId_idx" ON public."ContactLensPrescription" USING btree ("tenantId", "customerId");


--
-- Name: ContactLensPrescription_tenantId_prescriptionDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactLensPrescription_tenantId_prescriptionDate_idx" ON public."ContactLensPrescription" USING btree ("tenantId", "prescriptionDate");


--
-- Name: ContactLensRinsingSolution_solutionId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ContactLensRinsingSolution_solutionId_key" ON public."ContactLensRinsingSolution" USING btree ("solutionId");


--
-- Name: ContactLensRinsingSolution_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactLensRinsingSolution_tenantId_idx" ON public."ContactLensRinsingSolution" USING btree ("tenantId");


--
-- Name: ContactLensTint_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactLensTint_tenantId_idx" ON public."ContactLensTint" USING btree ("tenantId");


--
-- Name: ContactLensTint_tintId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ContactLensTint_tintId_key" ON public."ContactLensTint" USING btree ("tintId");


--
-- Name: ContactLensType_lensTypeId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ContactLensType_lensTypeId_key" ON public."ContactLensType" USING btree ("lensTypeId");


--
-- Name: ContactLensType_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactLensType_tenantId_idx" ON public."ContactLensType" USING btree ("tenantId");


--
-- Name: CreditCardTransaction_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CreditCardTransaction_status_idx" ON public."CreditCardTransaction" USING btree (status);


--
-- Name: CreditCardTransaction_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CreditCardTransaction_tenantId_idx" ON public."CreditCardTransaction" USING btree ("tenantId");


--
-- Name: CreditCardTransaction_transactionId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CreditCardTransaction_transactionId_idx" ON public."CreditCardTransaction" USING btree ("transactionId");


--
-- Name: CreditCardTransaction_transactionId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "CreditCardTransaction_transactionId_key" ON public."CreditCardTransaction" USING btree ("transactionId");


--
-- Name: CustomerGroup_tenantId_groupCode_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "CustomerGroup_tenantId_groupCode_key" ON public."CustomerGroup" USING btree ("tenantId", "groupCode");


--
-- Name: CustomerPhoto_tenantId_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CustomerPhoto_tenantId_customerId_idx" ON public."CustomerPhoto" USING btree ("tenantId", "customerId");


--
-- Name: Customer_customerId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Customer_customerId_key" ON public."Customer" USING btree ("customerId");


--
-- Name: Customer_tenantId_cellPhone_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Customer_tenantId_cellPhone_idx" ON public."Customer" USING btree ("tenantId", "cellPhone");


--
-- Name: Customer_tenantId_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Customer_tenantId_customerId_idx" ON public."Customer" USING btree ("tenantId", "customerId");


--
-- Name: Customer_tenantId_email_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Customer_tenantId_email_idx" ON public."Customer" USING btree ("tenantId", email);


--
-- Name: Customer_tenantId_lastName_firstName_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Customer_tenantId_lastName_firstName_idx" ON public."Customer" USING btree ("tenantId", "lastName", "firstName");


--
-- Name: DetailedWorkOrder_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "DetailedWorkOrder_customerId_idx" ON public."DetailedWorkOrder" USING btree ("customerId");


--
-- Name: DetailedWorkOrder_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "DetailedWorkOrder_tenantId_idx" ON public."DetailedWorkOrder" USING btree ("tenantId");


--
-- Name: DetailedWorkOrder_workDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "DetailedWorkOrder_workDate_idx" ON public."DetailedWorkOrder" USING btree ("workDate");


--
-- Name: DetailedWorkOrder_workStatusId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "DetailedWorkOrder_workStatusId_idx" ON public."DetailedWorkOrder" USING btree ("workStatusId");


--
-- Name: Diagnosis_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Diagnosis_customerId_idx" ON public."Diagnosis" USING btree ("customerId");


--
-- Name: Diagnosis_diagnosisDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Diagnosis_diagnosisDate_idx" ON public."Diagnosis" USING btree ("diagnosisDate");


--
-- Name: DiagnosticProtocol_tenantId_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "DiagnosticProtocol_tenantId_name_key" ON public."DiagnosticProtocol" USING btree ("tenantId", name);


--
-- Name: Discount_code_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Discount_code_key" ON public."Discount" USING btree (code);


--
-- Name: Discount_tenantId_active_validFrom_validTo_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Discount_tenantId_active_validFrom_validTo_idx" ON public."Discount" USING btree ("tenantId", active, "validFrom", "validTo");


--
-- Name: Discount_tenantId_code_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Discount_tenantId_code_idx" ON public."Discount" USING btree ("tenantId", code);


--
-- Name: DocumentTemplate_tenantId_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "DocumentTemplate_tenantId_category_idx" ON public."DocumentTemplate" USING btree ("tenantId", category);


--
-- Name: DocumentTemplate_tenantId_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "DocumentTemplate_tenantId_name_key" ON public."DocumentTemplate" USING btree ("tenantId", name);


--
-- Name: DocumentTemplate_tenantId_type_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "DocumentTemplate_tenantId_type_idx" ON public."DocumentTemplate" USING btree ("tenantId", type);


--
-- Name: Document_documentNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Document_documentNumber_key" ON public."Document" USING btree ("documentNumber");


--
-- Name: Document_tenantId_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Document_tenantId_category_idx" ON public."Document" USING btree ("tenantId", category);


--
-- Name: Document_tenantId_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Document_tenantId_customerId_idx" ON public."Document" USING btree ("tenantId", "customerId");


--
-- Name: Document_tenantId_documentNumber_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Document_tenantId_documentNumber_idx" ON public."Document" USING btree ("tenantId", "documentNumber");


--
-- Name: Document_tenantId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Document_tenantId_status_idx" ON public."Document" USING btree ("tenantId", status);


--
-- Name: EmployeeCommissionRule_employeeId_ruleId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "EmployeeCommissionRule_employeeId_ruleId_key" ON public."EmployeeCommissionRule" USING btree ("employeeId", "ruleId");


--
-- Name: EmployeeCommissionRule_tenantId_employeeId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "EmployeeCommissionRule_tenantId_employeeId_idx" ON public."EmployeeCommissionRule" USING btree ("tenantId", "employeeId");


--
-- Name: ExaminationOverview_checkDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ExaminationOverview_checkDate_idx" ON public."ExaminationOverview" USING btree ("checkDate");


--
-- Name: ExaminationOverview_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ExaminationOverview_customerId_idx" ON public."ExaminationOverview" USING btree ("customerId");


--
-- Name: ExaminationOverview_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ExaminationOverview_tenantId_idx" ON public."ExaminationOverview" USING btree ("tenantId");


--
-- Name: Examination_tenantId_customerId_examDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Examination_tenantId_customerId_examDate_idx" ON public."Examination" USING btree ("tenantId", "customerId", "examDate");


--
-- Name: Examination_tenantId_doctorId_examDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Examination_tenantId_doctorId_examDate_idx" ON public."Examination" USING btree ("tenantId", "doctorId", "examDate");


--
-- Name: Expense_tenantId_category_period_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Expense_tenantId_category_period_idx" ON public."Expense" USING btree ("tenantId", category, period);


--
-- Name: Expense_tenantId_employeeId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Expense_tenantId_employeeId_idx" ON public."Expense" USING btree ("tenantId", "employeeId");


--
-- Name: Expense_tenantId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Expense_tenantId_status_idx" ON public."Expense" USING btree ("tenantId", status);


--
-- Name: FRPLine_frpId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FRPLine_frpId_idx" ON public."FRPLine" USING btree ("frpId");


--
-- Name: FRPLine_lineDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FRPLine_lineDate_idx" ON public."FRPLine" USING btree ("lineDate");


--
-- Name: FollowUp_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FollowUp_customerId_idx" ON public."FollowUp" USING btree ("customerId");


--
-- Name: FollowUp_scheduledDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FollowUp_scheduledDate_idx" ON public."FollowUp" USING btree ("scheduledDate");


--
-- Name: FollowUp_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FollowUp_status_idx" ON public."FollowUp" USING btree (status);


--
-- Name: FrameCatalog_catalogNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "FrameCatalog_catalogNumber_key" ON public."FrameCatalog" USING btree ("catalogNumber");


--
-- Name: FrameCatalog_tenantId_active_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FrameCatalog_tenantId_active_idx" ON public."FrameCatalog" USING btree ("tenantId", active);


--
-- Name: FrameCatalog_tenantId_brand_model_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FrameCatalog_tenantId_brand_model_idx" ON public."FrameCatalog" USING btree ("tenantId", brand, model);


--
-- Name: FrameCatalog_tenantId_catalogNumber_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FrameCatalog_tenantId_catalogNumber_idx" ON public."FrameCatalog" USING btree ("tenantId", "catalogNumber");


--
-- Name: Frame_brand_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Frame_brand_idx" ON public."Frame" USING btree (brand);


--
-- Name: Frame_frameId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Frame_frameId_key" ON public."Frame" USING btree ("frameId");


--
-- Name: Frame_model_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Frame_model_idx" ON public."Frame" USING btree (model);


--
-- Name: Frame_tenantId_brand_model_color_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Frame_tenantId_brand_model_color_key" ON public."Frame" USING btree ("tenantId", brand, model, color);


--
-- Name: FrequentReplacementProgramDetail_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FrequentReplacementProgramDetail_customerId_idx" ON public."FrequentReplacementProgramDetail" USING btree ("customerId");


--
-- Name: FrequentReplacementProgramDetail_frpDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FrequentReplacementProgramDetail_frpDate_idx" ON public."FrequentReplacementProgramDetail" USING btree ("frpDate");


--
-- Name: FrequentReplacementProgramDetail_frpId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "FrequentReplacementProgramDetail_frpId_key" ON public."FrequentReplacementProgramDetail" USING btree ("frpId");


--
-- Name: FrequentReplacementProgramDetail_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FrequentReplacementProgramDetail_tenantId_idx" ON public."FrequentReplacementProgramDetail" USING btree ("tenantId");


--
-- Name: FrequentReplacementProgram_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FrequentReplacementProgram_customerId_idx" ON public."FrequentReplacementProgram" USING btree ("customerId");


--
-- Name: FrequentReplacementProgram_programId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "FrequentReplacementProgram_programId_key" ON public."FrequentReplacementProgram" USING btree ("programId");


--
-- Name: FrequentReplacementProgram_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FrequentReplacementProgram_status_idx" ON public."FrequentReplacementProgram" USING btree (status);


--
-- Name: FrpDelivery_programId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FrpDelivery_programId_idx" ON public."FrpDelivery" USING btree ("programId");


--
-- Name: FrpDelivery_scheduledDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FrpDelivery_scheduledDate_idx" ON public."FrpDelivery" USING btree ("scheduledDate");


--
-- Name: GlassBrand_brandId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "GlassBrand_brandId_key" ON public."GlassBrand" USING btree ("brandId");


--
-- Name: GlassBrand_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GlassBrand_tenantId_idx" ON public."GlassBrand" USING btree ("tenantId");


--
-- Name: GlassCoating_coatingId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "GlassCoating_coatingId_key" ON public."GlassCoating" USING btree ("coatingId");


--
-- Name: GlassCoating_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GlassCoating_tenantId_idx" ON public."GlassCoating" USING btree ("tenantId");


--
-- Name: GlassColor_colorId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "GlassColor_colorId_key" ON public."GlassColor" USING btree ("colorId");


--
-- Name: GlassColor_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GlassColor_tenantId_idx" ON public."GlassColor" USING btree ("tenantId");


--
-- Name: GlassExamination_checkDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GlassExamination_checkDate_idx" ON public."GlassExamination" USING btree ("checkDate");


--
-- Name: GlassExamination_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GlassExamination_customerId_idx" ON public."GlassExamination" USING btree ("customerId");


--
-- Name: GlassExamination_glassId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GlassExamination_glassId_idx" ON public."GlassExamination" USING btree ("glassId");


--
-- Name: GlassExamination_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GlassExamination_tenantId_idx" ON public."GlassExamination" USING btree ("tenantId");


--
-- Name: GlassMaterial_materialId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "GlassMaterial_materialId_key" ON public."GlassMaterial" USING btree ("materialId");


--
-- Name: GlassMaterial_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GlassMaterial_tenantId_idx" ON public."GlassMaterial" USING btree ("tenantId");


--
-- Name: GlassModel_modelId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "GlassModel_modelId_key" ON public."GlassModel" USING btree ("modelId");


--
-- Name: GlassModel_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GlassModel_tenantId_idx" ON public."GlassModel" USING btree ("tenantId");


--
-- Name: GlassPrescriptionDetail_checkDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GlassPrescriptionDetail_checkDate_idx" ON public."GlassPrescriptionDetail" USING btree ("checkDate");


--
-- Name: GlassPrescriptionDetail_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GlassPrescriptionDetail_customerId_idx" ON public."GlassPrescriptionDetail" USING btree ("customerId");


--
-- Name: GlassPrescriptionDetail_glassPId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GlassPrescriptionDetail_glassPId_idx" ON public."GlassPrescriptionDetail" USING btree ("glassPId");


--
-- Name: GlassPrescriptionDetail_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GlassPrescriptionDetail_tenantId_idx" ON public."GlassPrescriptionDetail" USING btree ("tenantId");


--
-- Name: GlassPrescription_checkDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GlassPrescription_checkDate_idx" ON public."GlassPrescription" USING btree ("checkDate");


--
-- Name: GlassPrescription_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GlassPrescription_customerId_idx" ON public."GlassPrescription" USING btree ("customerId");


--
-- Name: GlassPrescription_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GlassPrescription_tenantId_idx" ON public."GlassPrescription" USING btree ("tenantId");


--
-- Name: GlassRole_roleId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "GlassRole_roleId_key" ON public."GlassRole" USING btree ("roleId");


--
-- Name: GlassRole_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GlassRole_tenantId_idx" ON public."GlassRole" USING btree ("tenantId");


--
-- Name: GlassUse_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GlassUse_tenantId_idx" ON public."GlassUse" USING btree ("tenantId");


--
-- Name: GlassUse_useId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "GlassUse_useId_key" ON public."GlassUse" USING btree ("useId");


--
-- Name: InventoryAdjustmentItem_adjustmentId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InventoryAdjustmentItem_adjustmentId_idx" ON public."InventoryAdjustmentItem" USING btree ("adjustmentId");


--
-- Name: InventoryAdjustmentItem_productId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InventoryAdjustmentItem_productId_idx" ON public."InventoryAdjustmentItem" USING btree ("productId");


--
-- Name: InventoryAdjustment_adjustmentType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InventoryAdjustment_adjustmentType_idx" ON public."InventoryAdjustment" USING btree ("adjustmentType");


--
-- Name: InventoryAdjustment_tenantId_adjustmentDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InventoryAdjustment_tenantId_adjustmentDate_idx" ON public."InventoryAdjustment" USING btree ("tenantId", "adjustmentDate");


--
-- Name: InvoiceCredit_invoiceId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InvoiceCredit_invoiceId_idx" ON public."InvoiceCredit" USING btree ("invoiceId");


--
-- Name: InvoicePayment_invoiceId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InvoicePayment_invoiceId_idx" ON public."InvoicePayment" USING btree ("invoiceId");


--
-- Name: Invoice_invoiceDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Invoice_invoiceDate_idx" ON public."Invoice" USING btree ("invoiceDate");


--
-- Name: Invoice_invoiceId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Invoice_invoiceId_key" ON public."Invoice" USING btree ("invoiceId");


--
-- Name: Invoice_supplierId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Invoice_supplierId_idx" ON public."Invoice" USING btree ("supplierId");


--
-- Name: LabelPrintJob_jobNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "LabelPrintJob_jobNumber_key" ON public."LabelPrintJob" USING btree ("jobNumber");


--
-- Name: LabelPrintJob_tenantId_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LabelPrintJob_tenantId_createdAt_idx" ON public."LabelPrintJob" USING btree ("tenantId", "createdAt");


--
-- Name: LabelPrintJob_tenantId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LabelPrintJob_tenantId_status_idx" ON public."LabelPrintJob" USING btree ("tenantId", status);


--
-- Name: LabelTemplate_tenantId_category_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LabelTemplate_tenantId_category_isActive_idx" ON public."LabelTemplate" USING btree ("tenantId", category, "isActive");


--
-- Name: LabelTemplate_tenantId_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "LabelTemplate_tenantId_name_key" ON public."LabelTemplate" USING btree ("tenantId", name);


--
-- Name: LensCatalog_catalogNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "LensCatalog_catalogNumber_key" ON public."LensCatalog" USING btree ("catalogNumber");


--
-- Name: LensCatalog_tenantId_lensType_material_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LensCatalog_tenantId_lensType_material_idx" ON public."LensCatalog" USING btree ("tenantId", "lensType", material);


--
-- Name: LensCatalog_tenantId_manufacturer_series_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LensCatalog_tenantId_manufacturer_series_idx" ON public."LensCatalog" USING btree ("tenantId", manufacturer, series);


--
-- Name: LensCharacteristic_characteristicId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "LensCharacteristic_characteristicId_key" ON public."LensCharacteristic" USING btree ("characteristicId");


--
-- Name: LensCharacteristic_lensTypeId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LensCharacteristic_lensTypeId_idx" ON public."LensCharacteristic" USING btree ("lensTypeId");


--
-- Name: LensCharacteristic_supplierId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LensCharacteristic_supplierId_idx" ON public."LensCharacteristic" USING btree ("supplierId");


--
-- Name: LensCharacteristic_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LensCharacteristic_tenantId_idx" ON public."LensCharacteristic" USING btree ("tenantId");


--
-- Name: LensMaterial_materialId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "LensMaterial_materialId_key" ON public."LensMaterial" USING btree ("materialId");


--
-- Name: LensMaterial_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LensMaterial_tenantId_idx" ON public."LensMaterial" USING btree ("tenantId");


--
-- Name: LensTreatmentCharacteristic_lensTypeId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LensTreatmentCharacteristic_lensTypeId_idx" ON public."LensTreatmentCharacteristic" USING btree ("lensTypeId");


--
-- Name: LensTreatmentCharacteristic_supplierId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LensTreatmentCharacteristic_supplierId_idx" ON public."LensTreatmentCharacteristic" USING btree ("supplierId");


--
-- Name: LensTreatmentCharacteristic_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LensTreatmentCharacteristic_tenantId_idx" ON public."LensTreatmentCharacteristic" USING btree ("tenantId");


--
-- Name: LensTreatmentCharacteristic_treatmentCharId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "LensTreatmentCharacteristic_treatmentCharId_key" ON public."LensTreatmentCharacteristic" USING btree ("treatmentCharId");


--
-- Name: LensType_lensTypeId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "LensType_lensTypeId_key" ON public."LensType" USING btree ("lensTypeId");


--
-- Name: LensType_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LensType_tenantId_idx" ON public."LensType" USING btree ("tenantId");


--
-- Name: Lens_lensId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Lens_lensId_key" ON public."Lens" USING btree ("lensId");


--
-- Name: Lens_material_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Lens_material_idx" ON public."Lens" USING btree (material);


--
-- Name: Lens_type_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Lens_type_idx" ON public."Lens" USING btree (type);


--
-- Name: Letter_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Letter_category_idx" ON public."Letter" USING btree (category);


--
-- Name: LowVisionArea_areaId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "LowVisionArea_areaId_key" ON public."LowVisionArea" USING btree ("areaId");


--
-- Name: LowVisionArea_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LowVisionArea_tenantId_idx" ON public."LowVisionArea" USING btree ("tenantId");


--
-- Name: LowVisionCap_capId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "LowVisionCap_capId_key" ON public."LowVisionCap" USING btree ("capId");


--
-- Name: LowVisionCap_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LowVisionCap_tenantId_idx" ON public."LowVisionCap" USING btree ("tenantId");


--
-- Name: LowVisionCheck_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LowVisionCheck_customerId_idx" ON public."LowVisionCheck" USING btree ("customerId");


--
-- Name: LowVisionCheck_examDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LowVisionCheck_examDate_idx" ON public."LowVisionCheck" USING btree ("examDate");


--
-- Name: LowVisionExamination_checkDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LowVisionExamination_checkDate_idx" ON public."LowVisionExamination" USING btree ("checkDate");


--
-- Name: LowVisionExamination_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LowVisionExamination_customerId_idx" ON public."LowVisionExamination" USING btree ("customerId");


--
-- Name: LowVisionExamination_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LowVisionExamination_tenantId_idx" ON public."LowVisionExamination" USING btree ("tenantId");


--
-- Name: LowVisionFrame_frameId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "LowVisionFrame_frameId_key" ON public."LowVisionFrame" USING btree ("frameId");


--
-- Name: LowVisionFrame_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LowVisionFrame_tenantId_idx" ON public."LowVisionFrame" USING btree ("tenantId");


--
-- Name: LowVisionManufacturer_manufacturerId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "LowVisionManufacturer_manufacturerId_key" ON public."LowVisionManufacturer" USING btree ("manufacturerId");


--
-- Name: LowVisionManufacturer_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LowVisionManufacturer_tenantId_idx" ON public."LowVisionManufacturer" USING btree ("tenantId");


--
-- Name: MessageTemplate_tenantId_name_language_type_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "MessageTemplate_tenantId_name_language_type_key" ON public."MessageTemplate" USING btree ("tenantId", name, language, type);


--
-- Name: OpticalBase_baseId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "OpticalBase_baseId_key" ON public."OpticalBase" USING btree ("baseId");


--
-- Name: OpticalBase_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "OpticalBase_tenantId_idx" ON public."OpticalBase" USING btree ("tenantId");


--
-- Name: OrderItem_orderId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "OrderItem_orderId_idx" ON public."OrderItem" USING btree ("orderId");


--
-- Name: Order_orderNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Order_orderNumber_key" ON public."Order" USING btree ("orderNumber");


--
-- Name: Order_tenantId_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Order_tenantId_customerId_idx" ON public."Order" USING btree ("tenantId", "customerId");


--
-- Name: Order_tenantId_orderNumber_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Order_tenantId_orderNumber_idx" ON public."Order" USING btree ("tenantId", "orderNumber");


--
-- Name: Order_tenantId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Order_tenantId_status_idx" ON public."Order" USING btree ("tenantId", status);


--
-- Name: OrthokeratologyTreatment_checkDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "OrthokeratologyTreatment_checkDate_idx" ON public."OrthokeratologyTreatment" USING btree ("checkDate");


--
-- Name: OrthokeratologyTreatment_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "OrthokeratologyTreatment_customerId_idx" ON public."OrthokeratologyTreatment" USING btree ("customerId");


--
-- Name: OrthokeratologyTreatment_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "OrthokeratologyTreatment_tenantId_idx" ON public."OrthokeratologyTreatment" USING btree ("tenantId");


--
-- Name: Orthokeratology_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Orthokeratology_customerId_idx" ON public."Orthokeratology" USING btree ("customerId");


--
-- Name: Payment_paymentNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Payment_paymentNumber_key" ON public."Payment" USING btree ("paymentNumber");


--
-- Name: Payment_tenantId_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Payment_tenantId_customerId_idx" ON public."Payment" USING btree ("tenantId", "customerId");


--
-- Name: Payment_tenantId_paymentDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Payment_tenantId_paymentDate_idx" ON public."Payment" USING btree ("tenantId", "paymentDate");


--
-- Name: Payroll_tenantId_employeeId_period_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Payroll_tenantId_employeeId_period_key" ON public."Payroll" USING btree ("tenantId", "employeeId", period);


--
-- Name: Payroll_tenantId_period_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Payroll_tenantId_period_idx" ON public."Payroll" USING btree ("tenantId", period);


--
-- Name: Payroll_tenantId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Payroll_tenantId_status_idx" ON public."Payroll" USING btree ("tenantId", status);


--
-- Name: PhysicalInventoryCountItem_physicalCountId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PhysicalInventoryCountItem_physicalCountId_idx" ON public."PhysicalInventoryCountItem" USING btree ("physicalCountId");


--
-- Name: PhysicalInventoryCountItem_productId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PhysicalInventoryCountItem_productId_idx" ON public."PhysicalInventoryCountItem" USING btree ("productId");


--
-- Name: PhysicalInventoryCount_tenantId_startDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PhysicalInventoryCount_tenantId_startDate_idx" ON public."PhysicalInventoryCount" USING btree ("tenantId", "startDate");


--
-- Name: PhysicalInventoryCount_tenantId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PhysicalInventoryCount_tenantId_status_idx" ON public."PhysicalInventoryCount" USING btree ("tenantId", status);


--
-- Name: PrescriptionGlassDetail_tenantId_prescriptionId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PrescriptionGlassDetail_tenantId_prescriptionId_idx" ON public."PrescriptionGlassDetail" USING btree ("tenantId", "prescriptionId");


--
-- Name: PrescriptionHistory_tenantId_customerId_prescriptionDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PrescriptionHistory_tenantId_customerId_prescriptionDate_idx" ON public."PrescriptionHistory" USING btree ("tenantId", "customerId", "prescriptionDate");


--
-- Name: Prescription_tenantId_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Prescription_tenantId_customerId_idx" ON public."Prescription" USING btree ("tenantId", "customerId");


--
-- Name: Prescription_tenantId_prescriptionDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Prescription_tenantId_prescriptionDate_idx" ON public."Prescription" USING btree ("tenantId", "prescriptionDate");


--
-- Name: PriceHistory_tenantId_changedAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PriceHistory_tenantId_changedAt_idx" ON public."PriceHistory" USING btree ("tenantId", "changedAt");


--
-- Name: PriceHistory_tenantId_productId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PriceHistory_tenantId_productId_idx" ON public."PriceHistory" USING btree ("tenantId", "productId");


--
-- Name: PriceUpdate_tenantId_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PriceUpdate_tenantId_createdAt_idx" ON public."PriceUpdate" USING btree ("tenantId", "createdAt");


--
-- Name: PriceUpdate_tenantId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PriceUpdate_tenantId_status_idx" ON public."PriceUpdate" USING btree ("tenantId", status);


--
-- Name: ProductSerial_saleItemId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ProductSerial_saleItemId_key" ON public."ProductSerial" USING btree ("saleItemId");


--
-- Name: ProductSerial_tenantId_productId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ProductSerial_tenantId_productId_idx" ON public."ProductSerial" USING btree ("tenantId", "productId");


--
-- Name: ProductSerial_tenantId_serialNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ProductSerial_tenantId_serialNumber_key" ON public."ProductSerial" USING btree ("tenantId", "serialNumber");


--
-- Name: ProductSerial_tenantId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ProductSerial_tenantId_status_idx" ON public."ProductSerial" USING btree ("tenantId", status);


--
-- Name: Product_productId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Product_productId_key" ON public."Product" USING btree ("productId");


--
-- Name: Product_tenantId_barcode_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Product_tenantId_barcode_idx" ON public."Product" USING btree ("tenantId", barcode);


--
-- Name: Product_tenantId_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Product_tenantId_category_idx" ON public."Product" USING btree ("tenantId", category);


--
-- Name: Product_tenantId_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Product_tenantId_isActive_idx" ON public."Product" USING btree ("tenantId", "isActive");


--
-- Name: Product_tenantId_sku_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Product_tenantId_sku_idx" ON public."Product" USING btree ("tenantId", sku);


--
-- Name: Product_tenantId_sku_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Product_tenantId_sku_key" ON public."Product" USING btree ("tenantId", sku);


--
-- Name: PurchaseCheck_purchaseId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PurchaseCheck_purchaseId_idx" ON public."PurchaseCheck" USING btree ("purchaseId");


--
-- Name: PurchasePayment_purchaseId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PurchasePayment_purchaseId_idx" ON public."PurchasePayment" USING btree ("purchaseId");


--
-- Name: Purchase_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Purchase_customerId_idx" ON public."Purchase" USING btree ("customerId");


--
-- Name: Purchase_purchaseDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Purchase_purchaseDate_idx" ON public."Purchase" USING btree ("purchaseDate");


--
-- Name: Purchase_purchaseId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Purchase_purchaseId_key" ON public."Purchase" USING btree ("purchaseId");


--
-- Name: RefractionProtocol_tenantId_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "RefractionProtocol_tenantId_name_key" ON public."RefractionProtocol" USING btree ("tenantId", name);


--
-- Name: RetinoscopyDistance_retDistId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "RetinoscopyDistance_retDistId_key" ON public."RetinoscopyDistance" USING btree ("retDistId");


--
-- Name: RetinoscopyDistance_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "RetinoscopyDistance_tenantId_idx" ON public."RetinoscopyDistance" USING btree ("tenantId");


--
-- Name: RetinoscopyType_retTypeId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "RetinoscopyType_retTypeId_key" ON public."RetinoscopyType" USING btree ("retTypeId");


--
-- Name: RetinoscopyType_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "RetinoscopyType_tenantId_idx" ON public."RetinoscopyType" USING btree ("tenantId");


--
-- Name: SMS_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SMS_customerId_idx" ON public."SMS" USING btree ("customerId");


--
-- Name: SMS_sentAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SMS_sentAt_idx" ON public."SMS" USING btree ("sentAt");


--
-- Name: SMS_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SMS_status_idx" ON public."SMS" USING btree (status);


--
-- Name: SMS_tenantId_sentAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SMS_tenantId_sentAt_idx" ON public."SMS" USING btree ("tenantId", "sentAt");


--
-- Name: SaleItem_productId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SaleItem_productId_idx" ON public."SaleItem" USING btree ("productId");


--
-- Name: SaleItem_saleId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SaleItem_saleId_idx" ON public."SaleItem" USING btree ("saleId");


--
-- Name: Sale_saleId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Sale_saleId_key" ON public."Sale" USING btree ("saleId");


--
-- Name: Sale_tenantId_cashierShiftId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Sale_tenantId_cashierShiftId_idx" ON public."Sale" USING btree ("tenantId", "cashierShiftId");


--
-- Name: Sale_tenantId_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Sale_tenantId_customerId_idx" ON public."Sale" USING btree ("tenantId", "customerId");


--
-- Name: Sale_tenantId_saleDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Sale_tenantId_saleDate_idx" ON public."Sale" USING btree ("tenantId", "saleDate");


--
-- Name: Sale_tenantId_sellerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Sale_tenantId_sellerId_idx" ON public."Sale" USING btree ("tenantId", "sellerId");


--
-- Name: SlitLampExam_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SlitLampExam_customerId_idx" ON public."SlitLampExam" USING btree ("customerId");


--
-- Name: SlitLampExam_examDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SlitLampExam_examDate_idx" ON public."SlitLampExam" USING btree ("examDate");


--
-- Name: StockMovement_tenantId_productId_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "StockMovement_tenantId_productId_createdAt_idx" ON public."StockMovement" USING btree ("tenantId", "productId", "createdAt");


--
-- Name: StockMovement_tenantId_type_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "StockMovement_tenantId_type_createdAt_idx" ON public."StockMovement" USING btree ("tenantId", type, "createdAt");


--
-- Name: SupplierOrderItem_orderId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierOrderItem_orderId_idx" ON public."SupplierOrderItem" USING btree ("orderId");


--
-- Name: SupplierOrder_orderDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierOrder_orderDate_idx" ON public."SupplierOrder" USING btree ("orderDate");


--
-- Name: SupplierOrder_orderNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "SupplierOrder_orderNumber_key" ON public."SupplierOrder" USING btree ("orderNumber");


--
-- Name: SupplierOrder_supplierId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierOrder_supplierId_idx" ON public."SupplierOrder" USING btree ("supplierId");


--
-- Name: SupplierOrder_tenantId_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierOrder_tenantId_branchId_idx" ON public."SupplierOrder" USING btree ("tenantId", "branchId");


--
-- Name: SupplierOrder_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierOrder_tenantId_idx" ON public."SupplierOrder" USING btree ("tenantId");


--
-- Name: Supplier_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Supplier_name_idx" ON public."Supplier" USING btree (name);


--
-- Name: Supplier_supplierId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Supplier_supplierId_key" ON public."Supplier" USING btree ("supplierId");


--
-- Name: TaskAttachment_taskId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "TaskAttachment_taskId_idx" ON public."TaskAttachment" USING btree ("taskId");


--
-- Name: TaskComment_taskId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "TaskComment_taskId_idx" ON public."TaskComment" USING btree ("taskId");


--
-- Name: Task_tenantId_assignedToId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Task_tenantId_assignedToId_idx" ON public."Task" USING btree ("tenantId", "assignedToId");


--
-- Name: Task_tenantId_dueDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Task_tenantId_dueDate_idx" ON public."Task" USING btree ("tenantId", "dueDate");


--
-- Name: Task_tenantId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Task_tenantId_status_idx" ON public."Task" USING btree ("tenantId", status);


--
-- Name: TaxRate_code_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "TaxRate_code_key" ON public."TaxRate" USING btree (code);


--
-- Name: TaxRate_tenantId_active_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "TaxRate_tenantId_active_idx" ON public."TaxRate" USING btree ("tenantId", active);


--
-- Name: TenantSettings_tenantId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "TenantSettings_tenantId_key" ON public."TenantSettings" USING btree ("tenantId");


--
-- Name: Tenant_subdomain_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Tenant_subdomain_key" ON public."Tenant" USING btree (subdomain);


--
-- Name: UserSettings_userId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "UserSettings_userId_key" ON public."UserSettings" USING btree ("userId");


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: User_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "User_tenantId_idx" ON public."User" USING btree ("tenantId");


--
-- Name: VisionTest_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "VisionTest_customerId_idx" ON public."VisionTest" USING btree ("customerId");


--
-- Name: VisionTest_testDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "VisionTest_testDate_idx" ON public."VisionTest" USING btree ("testDate");


--
-- Name: WorkLab_labId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "WorkLab_labId_key" ON public."WorkLab" USING btree ("labId");


--
-- Name: WorkLab_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "WorkLab_tenantId_idx" ON public."WorkLab" USING btree ("tenantId");


--
-- Name: WorkLabel_labelId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "WorkLabel_labelId_key" ON public."WorkLabel" USING btree ("labelId");


--
-- Name: WorkLabel_supplierId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "WorkLabel_supplierId_idx" ON public."WorkLabel" USING btree ("supplierId");


--
-- Name: WorkLabel_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "WorkLabel_tenantId_idx" ON public."WorkLabel" USING btree ("tenantId");


--
-- Name: WorkOrderStatus_workOrderId_changedAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "WorkOrderStatus_workOrderId_changedAt_idx" ON public."WorkOrderStatus" USING btree ("workOrderId", "changedAt");


--
-- Name: WorkOrder_tenantId_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "WorkOrder_tenantId_customerId_idx" ON public."WorkOrder" USING btree ("tenantId", "customerId");


--
-- Name: WorkOrder_tenantId_orderDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "WorkOrder_tenantId_orderDate_idx" ON public."WorkOrder" USING btree ("tenantId", "orderDate");


--
-- Name: WorkOrder_tenantId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "WorkOrder_tenantId_status_idx" ON public."WorkOrder" USING btree ("tenantId", status);


--
-- Name: WorkOrder_tenantId_workOrderNumber_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "WorkOrder_tenantId_workOrderNumber_idx" ON public."WorkOrder" USING btree ("tenantId", "workOrderNumber");


--
-- Name: WorkOrder_workOrderNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "WorkOrder_workOrderNumber_key" ON public."WorkOrder" USING btree ("workOrderNumber");


--
-- Name: WorkStatus_statusId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "WorkStatus_statusId_key" ON public."WorkStatus" USING btree ("statusId");


--
-- Name: WorkStatus_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "WorkStatus_tenantId_idx" ON public."WorkStatus" USING btree ("tenantId");


--
-- Name: WorkSupplier_supplierId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "WorkSupplier_supplierId_key" ON public."WorkSupplier" USING btree ("supplierId");


--
-- Name: WorkSupplier_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "WorkSupplier_tenantId_idx" ON public."WorkSupplier" USING btree ("tenantId");


--
-- Name: WorkSupplyType_supplyTypeId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "WorkSupplyType_supplyTypeId_key" ON public."WorkSupplyType" USING btree ("supplyTypeId");


--
-- Name: WorkSupplyType_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "WorkSupplyType_tenantId_idx" ON public."WorkSupplyType" USING btree ("tenantId");


--
-- Name: ZipCode_city_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ZipCode_city_idx" ON public."ZipCode" USING btree (city);


--
-- Name: ZipCode_zipCode_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ZipCode_zipCode_idx" ON public."ZipCode" USING btree ("zipCode");


--
-- Name: ZipCode_zipCode_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ZipCode_zipCode_key" ON public."ZipCode" USING btree ("zipCode");


--
-- Name: AdvancedExamination AdvancedExamination_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AdvancedExamination"
    ADD CONSTRAINT "AdvancedExamination_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: AdvancedExamination AdvancedExamination_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AdvancedExamination"
    ADD CONSTRAINT "AdvancedExamination_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: AdvancedExamination AdvancedExamination_examinationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AdvancedExamination"
    ADD CONSTRAINT "AdvancedExamination_examinationId_fkey" FOREIGN KEY ("examinationId") REFERENCES public."Examination"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: AdvancedExamination AdvancedExamination_examinerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AdvancedExamination"
    ADD CONSTRAINT "AdvancedExamination_examinerId_fkey" FOREIGN KEY ("examinerId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: AdvancedExamination AdvancedExamination_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AdvancedExamination"
    ADD CONSTRAINT "AdvancedExamination_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Appointment Appointment_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Appointment"
    ADD CONSTRAINT "Appointment_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Appointment Appointment_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Appointment"
    ADD CONSTRAINT "Appointment_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Appointment Appointment_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Appointment"
    ADD CONSTRAINT "Appointment_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Appointment Appointment_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Appointment"
    ADD CONSTRAINT "Appointment_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: BarcodeManagement BarcodeManagement_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BarcodeManagement"
    ADD CONSTRAINT "BarcodeManagement_productId_fkey" FOREIGN KEY ("productId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: BarcodeManagement BarcodeManagement_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BarcodeManagement"
    ADD CONSTRAINT "BarcodeManagement_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Branch Branch_managerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Branch"
    ADD CONSTRAINT "Branch_managerId_fkey" FOREIGN KEY ("managerId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Branch Branch_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Branch"
    ADD CONSTRAINT "Branch_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Brand Brand_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Brand"
    ADD CONSTRAINT "Brand_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CashDrawerEvent CashDrawerEvent_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CashDrawerEvent"
    ADD CONSTRAINT "CashDrawerEvent_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CashDrawerEvent CashDrawerEvent_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CashDrawerEvent"
    ADD CONSTRAINT "CashDrawerEvent_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CashDrawerEvent CashDrawerEvent_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CashDrawerEvent"
    ADD CONSTRAINT "CashDrawerEvent_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CashReconciliation CashReconciliation_performedBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CashReconciliation"
    ADD CONSTRAINT "CashReconciliation_performedBy_fkey" FOREIGN KEY ("performedBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CashReconciliation CashReconciliation_shiftId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CashReconciliation"
    ADD CONSTRAINT "CashReconciliation_shiftId_fkey" FOREIGN KEY ("shiftId") REFERENCES public."CashierShift"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CashReconciliation CashReconciliation_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CashReconciliation"
    ADD CONSTRAINT "CashReconciliation_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CashierShift CashierShift_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CashierShift"
    ADD CONSTRAINT "CashierShift_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CashierShift CashierShift_closedBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CashierShift"
    ADD CONSTRAINT "CashierShift_closedBy_fkey" FOREIGN KEY ("closedBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CashierShift CashierShift_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CashierShift"
    ADD CONSTRAINT "CashierShift_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CashierShift CashierShift_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CashierShift"
    ADD CONSTRAINT "CashierShift_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CheckType CheckType_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CheckType"
    ADD CONSTRAINT "CheckType_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: City City_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."City"
    ADD CONSTRAINT "City_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClinicalDiagnosis ClinicalDiagnosis_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalDiagnosis"
    ADD CONSTRAINT "ClinicalDiagnosis_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ClinicalDiagnosis ClinicalDiagnosis_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalDiagnosis"
    ADD CONSTRAINT "ClinicalDiagnosis_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClinicalDiagnosis ClinicalDiagnosis_examinerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalDiagnosis"
    ADD CONSTRAINT "ClinicalDiagnosis_examinerId_fkey" FOREIGN KEY ("examinerId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ClinicalDiagnosis ClinicalDiagnosis_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalDiagnosis"
    ADD CONSTRAINT "ClinicalDiagnosis_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClinicalExamination ClinicalExamination_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalExamination"
    ADD CONSTRAINT "ClinicalExamination_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ClinicalExamination ClinicalExamination_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalExamination"
    ADD CONSTRAINT "ClinicalExamination_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClinicalExamination ClinicalExamination_examinerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalExamination"
    ADD CONSTRAINT "ClinicalExamination_examinerId_fkey" FOREIGN KEY ("examinerId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ClinicalExamination ClinicalExamination_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalExamination"
    ADD CONSTRAINT "ClinicalExamination_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CommissionRule CommissionRule_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CommissionRule"
    ADD CONSTRAINT "CommissionRule_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CommissionRule CommissionRule_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CommissionRule"
    ADD CONSTRAINT "CommissionRule_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Commission Commission_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Commission"
    ADD CONSTRAINT "Commission_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Commission Commission_employeeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Commission"
    ADD CONSTRAINT "Commission_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Commission Commission_examinationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Commission"
    ADD CONSTRAINT "Commission_examinationId_fkey" FOREIGN KEY ("examinationId") REFERENCES public."Examination"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Commission Commission_ruleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Commission"
    ADD CONSTRAINT "Commission_ruleId_fkey" FOREIGN KEY ("ruleId") REFERENCES public."CommissionRule"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Commission Commission_saleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Commission"
    ADD CONSTRAINT "Commission_saleId_fkey" FOREIGN KEY ("saleId") REFERENCES public."Sale"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Commission Commission_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Commission"
    ADD CONSTRAINT "Commission_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CommunicationCampaign CommunicationCampaign_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CommunicationCampaign"
    ADD CONSTRAINT "CommunicationCampaign_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CommunicationCampaign CommunicationCampaign_templateId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CommunicationCampaign"
    ADD CONSTRAINT "CommunicationCampaign_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES public."MessageTemplate"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CommunicationCampaign CommunicationCampaign_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CommunicationCampaign"
    ADD CONSTRAINT "CommunicationCampaign_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CommunicationLog CommunicationLog_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CommunicationLog"
    ADD CONSTRAINT "CommunicationLog_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CommunicationLog CommunicationLog_campaignId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CommunicationLog"
    ADD CONSTRAINT "CommunicationLog_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES public."CommunicationCampaign"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CommunicationLog CommunicationLog_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CommunicationLog"
    ADD CONSTRAINT "CommunicationLog_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CommunicationLog CommunicationLog_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CommunicationLog"
    ADD CONSTRAINT "CommunicationLog_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CommunicationSchedule CommunicationSchedule_templateId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CommunicationSchedule"
    ADD CONSTRAINT "CommunicationSchedule_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES public."MessageTemplate"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CommunicationSchedule CommunicationSchedule_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CommunicationSchedule"
    ADD CONSTRAINT "CommunicationSchedule_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContactAgent ContactAgent_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactAgent"
    ADD CONSTRAINT "ContactAgent_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContactAgent ContactAgent_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactAgent"
    ADD CONSTRAINT "ContactAgent_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContactLensBrand ContactLensBrand_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensBrand"
    ADD CONSTRAINT "ContactLensBrand_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContactLensCleaningSolution ContactLensCleaningSolution_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensCleaningSolution"
    ADD CONSTRAINT "ContactLensCleaningSolution_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContactLensDisinfectingSolution ContactLensDisinfectingSolution_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensDisinfectingSolution"
    ADD CONSTRAINT "ContactLensDisinfectingSolution_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContactLensExamination ContactLensExamination_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensExamination"
    ADD CONSTRAINT "ContactLensExamination_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ContactLensExamination ContactLensExamination_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensExamination"
    ADD CONSTRAINT "ContactLensExamination_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContactLensExamination ContactLensExamination_examinerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensExamination"
    ADD CONSTRAINT "ContactLensExamination_examinerId_fkey" FOREIGN KEY ("examinerId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ContactLensExamination ContactLensExamination_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensExamination"
    ADD CONSTRAINT "ContactLensExamination_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContactLensFittingDetail ContactLensFittingDetail_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensFittingDetail"
    ADD CONSTRAINT "ContactLensFittingDetail_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ContactLensFittingDetail ContactLensFittingDetail_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensFittingDetail"
    ADD CONSTRAINT "ContactLensFittingDetail_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContactLensFittingDetail ContactLensFittingDetail_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensFittingDetail"
    ADD CONSTRAINT "ContactLensFittingDetail_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContactLensFitting ContactLensFitting_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensFitting"
    ADD CONSTRAINT "ContactLensFitting_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ContactLensFitting ContactLensFitting_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensFitting"
    ADD CONSTRAINT "ContactLensFitting_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContactLensFitting ContactLensFitting_fitterId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensFitting"
    ADD CONSTRAINT "ContactLensFitting_fitterId_fkey" FOREIGN KEY ("fitterId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ContactLensFitting ContactLensFitting_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensFitting"
    ADD CONSTRAINT "ContactLensFitting_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContactLensManufacturer ContactLensManufacturer_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensManufacturer"
    ADD CONSTRAINT "ContactLensManufacturer_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContactLensMaterial ContactLensMaterial_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensMaterial"
    ADD CONSTRAINT "ContactLensMaterial_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContactLensPrescription ContactLensPrescription_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensPrescription"
    ADD CONSTRAINT "ContactLensPrescription_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ContactLensPrescription ContactLensPrescription_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensPrescription"
    ADD CONSTRAINT "ContactLensPrescription_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContactLensPrescription ContactLensPrescription_doctorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensPrescription"
    ADD CONSTRAINT "ContactLensPrescription_doctorId_fkey" FOREIGN KEY ("doctorId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ContactLensPrescription ContactLensPrescription_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensPrescription"
    ADD CONSTRAINT "ContactLensPrescription_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContactLensRinsingSolution ContactLensRinsingSolution_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensRinsingSolution"
    ADD CONSTRAINT "ContactLensRinsingSolution_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContactLensTint ContactLensTint_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensTint"
    ADD CONSTRAINT "ContactLensTint_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContactLensType ContactLensType_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensType"
    ADD CONSTRAINT "ContactLensType_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CreditCardTransaction CreditCardTransaction_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CreditCardTransaction"
    ADD CONSTRAINT "CreditCardTransaction_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CreditCardTransaction CreditCardTransaction_invoiceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CreditCardTransaction"
    ADD CONSTRAINT "CreditCardTransaction_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES public."Invoice"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CreditCardTransaction CreditCardTransaction_saleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CreditCardTransaction"
    ADD CONSTRAINT "CreditCardTransaction_saleId_fkey" FOREIGN KEY ("saleId") REFERENCES public."Sale"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CreditCardTransaction CreditCardTransaction_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CreditCardTransaction"
    ADD CONSTRAINT "CreditCardTransaction_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CustomerGroup CustomerGroup_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CustomerGroup"
    ADD CONSTRAINT "CustomerGroup_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CustomerPhoto CustomerPhoto_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CustomerPhoto"
    ADD CONSTRAINT "CustomerPhoto_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CustomerPhoto CustomerPhoto_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CustomerPhoto"
    ADD CONSTRAINT "CustomerPhoto_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Customer Customer_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Customer"
    ADD CONSTRAINT "Customer_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Customer Customer_groupId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Customer"
    ADD CONSTRAINT "Customer_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES public."CustomerGroup"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Customer Customer_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Customer"
    ADD CONSTRAINT "Customer_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: DetailedWorkOrder DetailedWorkOrder_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DetailedWorkOrder"
    ADD CONSTRAINT "DetailedWorkOrder_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: DetailedWorkOrder DetailedWorkOrder_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DetailedWorkOrder"
    ADD CONSTRAINT "DetailedWorkOrder_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: DetailedWorkOrder DetailedWorkOrder_examinerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DetailedWorkOrder"
    ADD CONSTRAINT "DetailedWorkOrder_examinerId_fkey" FOREIGN KEY ("examinerId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: DetailedWorkOrder DetailedWorkOrder_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DetailedWorkOrder"
    ADD CONSTRAINT "DetailedWorkOrder_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Diagnosis Diagnosis_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Diagnosis"
    ADD CONSTRAINT "Diagnosis_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Diagnosis Diagnosis_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Diagnosis"
    ADD CONSTRAINT "Diagnosis_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Diagnosis Diagnosis_examinerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Diagnosis"
    ADD CONSTRAINT "Diagnosis_examinerId_fkey" FOREIGN KEY ("examinerId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Diagnosis Diagnosis_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Diagnosis"
    ADD CONSTRAINT "Diagnosis_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: DiagnosticProtocol DiagnosticProtocol_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DiagnosticProtocol"
    ADD CONSTRAINT "DiagnosticProtocol_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Discount Discount_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Discount"
    ADD CONSTRAINT "Discount_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: DocumentTemplate DocumentTemplate_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DocumentTemplate"
    ADD CONSTRAINT "DocumentTemplate_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: DocumentTemplate DocumentTemplate_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DocumentTemplate"
    ADD CONSTRAINT "DocumentTemplate_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Document Document_appointmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Document"
    ADD CONSTRAINT "Document_appointmentId_fkey" FOREIGN KEY ("appointmentId") REFERENCES public."Appointment"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Document Document_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Document"
    ADD CONSTRAINT "Document_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Document Document_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Document"
    ADD CONSTRAINT "Document_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Document Document_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Document"
    ADD CONSTRAINT "Document_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Document Document_examinationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Document"
    ADD CONSTRAINT "Document_examinationId_fkey" FOREIGN KEY ("examinationId") REFERENCES public."Examination"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Document Document_prescriptionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Document"
    ADD CONSTRAINT "Document_prescriptionId_fkey" FOREIGN KEY ("prescriptionId") REFERENCES public."Prescription"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Document Document_saleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Document"
    ADD CONSTRAINT "Document_saleId_fkey" FOREIGN KEY ("saleId") REFERENCES public."Sale"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Document Document_templateId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Document"
    ADD CONSTRAINT "Document_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES public."DocumentTemplate"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Document Document_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Document"
    ADD CONSTRAINT "Document_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: EmployeeCommissionRule EmployeeCommissionRule_employeeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EmployeeCommissionRule"
    ADD CONSTRAINT "EmployeeCommissionRule_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: EmployeeCommissionRule EmployeeCommissionRule_ruleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EmployeeCommissionRule"
    ADD CONSTRAINT "EmployeeCommissionRule_ruleId_fkey" FOREIGN KEY ("ruleId") REFERENCES public."CommissionRule"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: EmployeeCommissionRule EmployeeCommissionRule_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EmployeeCommissionRule"
    ADD CONSTRAINT "EmployeeCommissionRule_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ExaminationOverview ExaminationOverview_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ExaminationOverview"
    ADD CONSTRAINT "ExaminationOverview_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ExaminationOverview ExaminationOverview_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ExaminationOverview"
    ADD CONSTRAINT "ExaminationOverview_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ExaminationOverview ExaminationOverview_examinerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ExaminationOverview"
    ADD CONSTRAINT "ExaminationOverview_examinerId_fkey" FOREIGN KEY ("examinerId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ExaminationOverview ExaminationOverview_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ExaminationOverview"
    ADD CONSTRAINT "ExaminationOverview_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Examination Examination_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Examination"
    ADD CONSTRAINT "Examination_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Examination Examination_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Examination"
    ADD CONSTRAINT "Examination_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Examination Examination_doctorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Examination"
    ADD CONSTRAINT "Examination_doctorId_fkey" FOREIGN KEY ("doctorId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Examination Examination_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Examination"
    ADD CONSTRAINT "Examination_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Expense Expense_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Expense"
    ADD CONSTRAINT "Expense_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Expense Expense_employeeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Expense"
    ADD CONSTRAINT "Expense_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Expense Expense_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Expense"
    ADD CONSTRAINT "Expense_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FRPLine FRPLine_frpId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FRPLine"
    ADD CONSTRAINT "FRPLine_frpId_fkey" FOREIGN KEY ("frpId") REFERENCES public."FrequentReplacementProgramDetail"("frpId") ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FRPLine FRPLine_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FRPLine"
    ADD CONSTRAINT "FRPLine_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FollowUp FollowUp_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FollowUp"
    ADD CONSTRAINT "FollowUp_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: FollowUp FollowUp_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FollowUp"
    ADD CONSTRAINT "FollowUp_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FollowUp FollowUp_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FollowUp"
    ADD CONSTRAINT "FollowUp_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FrameCatalog FrameCatalog_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FrameCatalog"
    ADD CONSTRAINT "FrameCatalog_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: FrameCatalog FrameCatalog_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FrameCatalog"
    ADD CONSTRAINT "FrameCatalog_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Frame Frame_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Frame"
    ADD CONSTRAINT "Frame_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FrequentReplacementProgramDetail FrequentReplacementProgramDetail_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FrequentReplacementProgramDetail"
    ADD CONSTRAINT "FrequentReplacementProgramDetail_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: FrequentReplacementProgramDetail FrequentReplacementProgramDetail_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FrequentReplacementProgramDetail"
    ADD CONSTRAINT "FrequentReplacementProgramDetail_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FrequentReplacementProgramDetail FrequentReplacementProgramDetail_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FrequentReplacementProgramDetail"
    ADD CONSTRAINT "FrequentReplacementProgramDetail_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FrequentReplacementProgram FrequentReplacementProgram_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FrequentReplacementProgram"
    ADD CONSTRAINT "FrequentReplacementProgram_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FrequentReplacementProgram FrequentReplacementProgram_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FrequentReplacementProgram"
    ADD CONSTRAINT "FrequentReplacementProgram_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FrpDelivery FrpDelivery_programId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FrpDelivery"
    ADD CONSTRAINT "FrpDelivery_programId_fkey" FOREIGN KEY ("programId") REFERENCES public."FrequentReplacementProgram"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: GlassBrand GlassBrand_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassBrand"
    ADD CONSTRAINT "GlassBrand_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: GlassCoating GlassCoating_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassCoating"
    ADD CONSTRAINT "GlassCoating_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: GlassColor GlassColor_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassColor"
    ADD CONSTRAINT "GlassColor_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: GlassExamination GlassExamination_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassExamination"
    ADD CONSTRAINT "GlassExamination_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: GlassExamination GlassExamination_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassExamination"
    ADD CONSTRAINT "GlassExamination_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: GlassExamination GlassExamination_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassExamination"
    ADD CONSTRAINT "GlassExamination_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: GlassMaterial GlassMaterial_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassMaterial"
    ADD CONSTRAINT "GlassMaterial_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: GlassModel GlassModel_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassModel"
    ADD CONSTRAINT "GlassModel_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: GlassPrescriptionDetail GlassPrescriptionDetail_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassPrescriptionDetail"
    ADD CONSTRAINT "GlassPrescriptionDetail_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: GlassPrescriptionDetail GlassPrescriptionDetail_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassPrescriptionDetail"
    ADD CONSTRAINT "GlassPrescriptionDetail_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: GlassPrescriptionDetail GlassPrescriptionDetail_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassPrescriptionDetail"
    ADD CONSTRAINT "GlassPrescriptionDetail_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: GlassPrescription GlassPrescription_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassPrescription"
    ADD CONSTRAINT "GlassPrescription_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: GlassPrescription GlassPrescription_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassPrescription"
    ADD CONSTRAINT "GlassPrescription_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: GlassPrescription GlassPrescription_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassPrescription"
    ADD CONSTRAINT "GlassPrescription_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: GlassRole GlassRole_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassRole"
    ADD CONSTRAINT "GlassRole_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: GlassUse GlassUse_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GlassUse"
    ADD CONSTRAINT "GlassUse_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: InventoryAdjustmentItem InventoryAdjustmentItem_adjustmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InventoryAdjustmentItem"
    ADD CONSTRAINT "InventoryAdjustmentItem_adjustmentId_fkey" FOREIGN KEY ("adjustmentId") REFERENCES public."InventoryAdjustment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: InventoryAdjustmentItem InventoryAdjustmentItem_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InventoryAdjustmentItem"
    ADD CONSTRAINT "InventoryAdjustmentItem_productId_fkey" FOREIGN KEY ("productId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: InventoryAdjustment InventoryAdjustment_physicalCountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InventoryAdjustment"
    ADD CONSTRAINT "InventoryAdjustment_physicalCountId_fkey" FOREIGN KEY ("physicalCountId") REFERENCES public."PhysicalInventoryCount"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: InventoryAdjustment InventoryAdjustment_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InventoryAdjustment"
    ADD CONSTRAINT "InventoryAdjustment_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: InvoiceCredit InvoiceCredit_invoiceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InvoiceCredit"
    ADD CONSTRAINT "InvoiceCredit_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES public."Invoice"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: InvoicePayment InvoicePayment_invoiceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InvoicePayment"
    ADD CONSTRAINT "InvoicePayment_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES public."Invoice"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Invoice Invoice_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Invoice"
    ADD CONSTRAINT "Invoice_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Invoice Invoice_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Invoice"
    ADD CONSTRAINT "Invoice_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LabelPrintJob LabelPrintJob_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LabelPrintJob"
    ADD CONSTRAINT "LabelPrintJob_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: LabelPrintJob LabelPrintJob_templateId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LabelPrintJob"
    ADD CONSTRAINT "LabelPrintJob_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES public."LabelTemplate"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LabelPrintJob LabelPrintJob_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LabelPrintJob"
    ADD CONSTRAINT "LabelPrintJob_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LabelTemplate LabelTemplate_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LabelTemplate"
    ADD CONSTRAINT "LabelTemplate_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: LabelTemplate LabelTemplate_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LabelTemplate"
    ADD CONSTRAINT "LabelTemplate_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: LabelTemplate LabelTemplate_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LabelTemplate"
    ADD CONSTRAINT "LabelTemplate_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LensCatalog LensCatalog_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LensCatalog"
    ADD CONSTRAINT "LensCatalog_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: LensCatalog LensCatalog_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LensCatalog"
    ADD CONSTRAINT "LensCatalog_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LensCharacteristic LensCharacteristic_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LensCharacteristic"
    ADD CONSTRAINT "LensCharacteristic_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LensMaterial LensMaterial_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LensMaterial"
    ADD CONSTRAINT "LensMaterial_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LensTreatmentCharacteristic LensTreatmentCharacteristic_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LensTreatmentCharacteristic"
    ADD CONSTRAINT "LensTreatmentCharacteristic_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LensType LensType_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LensType"
    ADD CONSTRAINT "LensType_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Lens Lens_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Lens"
    ADD CONSTRAINT "Lens_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Letter Letter_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Letter"
    ADD CONSTRAINT "Letter_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LowVisionArea LowVisionArea_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LowVisionArea"
    ADD CONSTRAINT "LowVisionArea_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LowVisionCap LowVisionCap_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LowVisionCap"
    ADD CONSTRAINT "LowVisionCap_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LowVisionCheck LowVisionCheck_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LowVisionCheck"
    ADD CONSTRAINT "LowVisionCheck_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: LowVisionCheck LowVisionCheck_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LowVisionCheck"
    ADD CONSTRAINT "LowVisionCheck_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LowVisionCheck LowVisionCheck_examinerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LowVisionCheck"
    ADD CONSTRAINT "LowVisionCheck_examinerId_fkey" FOREIGN KEY ("examinerId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: LowVisionCheck LowVisionCheck_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LowVisionCheck"
    ADD CONSTRAINT "LowVisionCheck_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LowVisionExamination LowVisionExamination_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LowVisionExamination"
    ADD CONSTRAINT "LowVisionExamination_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: LowVisionExamination LowVisionExamination_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LowVisionExamination"
    ADD CONSTRAINT "LowVisionExamination_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LowVisionExamination LowVisionExamination_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LowVisionExamination"
    ADD CONSTRAINT "LowVisionExamination_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LowVisionFrame LowVisionFrame_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LowVisionFrame"
    ADD CONSTRAINT "LowVisionFrame_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LowVisionManufacturer LowVisionManufacturer_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LowVisionManufacturer"
    ADD CONSTRAINT "LowVisionManufacturer_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: MessageTemplate MessageTemplate_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MessageTemplate"
    ADD CONSTRAINT "MessageTemplate_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: OpticalBase OpticalBase_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OpticalBase"
    ADD CONSTRAINT "OpticalBase_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: OrderItem OrderItem_orderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderItem"
    ADD CONSTRAINT "OrderItem_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES public."Order"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: OrderItem OrderItem_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderItem"
    ADD CONSTRAINT "OrderItem_productId_fkey" FOREIGN KEY ("productId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Order Order_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order"
    ADD CONSTRAINT "Order_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Order Order_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order"
    ADD CONSTRAINT "Order_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Order Order_prescriptionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order"
    ADD CONSTRAINT "Order_prescriptionId_fkey" FOREIGN KEY ("prescriptionId") REFERENCES public."Prescription"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Order Order_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order"
    ADD CONSTRAINT "Order_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Order Order_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order"
    ADD CONSTRAINT "Order_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: OrthokeratologyTreatment OrthokeratologyTreatment_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrthokeratologyTreatment"
    ADD CONSTRAINT "OrthokeratologyTreatment_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: OrthokeratologyTreatment OrthokeratologyTreatment_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrthokeratologyTreatment"
    ADD CONSTRAINT "OrthokeratologyTreatment_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: OrthokeratologyTreatment OrthokeratologyTreatment_examinerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrthokeratologyTreatment"
    ADD CONSTRAINT "OrthokeratologyTreatment_examinerId_fkey" FOREIGN KEY ("examinerId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: OrthokeratologyTreatment OrthokeratologyTreatment_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrthokeratologyTreatment"
    ADD CONSTRAINT "OrthokeratologyTreatment_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Orthokeratology Orthokeratology_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Orthokeratology"
    ADD CONSTRAINT "Orthokeratology_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Orthokeratology Orthokeratology_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Orthokeratology"
    ADD CONSTRAINT "Orthokeratology_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Orthokeratology Orthokeratology_prescriberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Orthokeratology"
    ADD CONSTRAINT "Orthokeratology_prescriberId_fkey" FOREIGN KEY ("prescriberId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Orthokeratology Orthokeratology_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Orthokeratology"
    ADD CONSTRAINT "Orthokeratology_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Payment Payment_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Payment Payment_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Payment Payment_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Payment Payment_invoiceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES public."Invoice"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Payment Payment_saleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_saleId_fkey" FOREIGN KEY ("saleId") REFERENCES public."Sale"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Payment Payment_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Payroll Payroll_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payroll"
    ADD CONSTRAINT "Payroll_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Payroll Payroll_employeeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payroll"
    ADD CONSTRAINT "Payroll_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Payroll Payroll_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payroll"
    ADD CONSTRAINT "Payroll_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PhysicalInventoryCountItem PhysicalInventoryCountItem_physicalCountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PhysicalInventoryCountItem"
    ADD CONSTRAINT "PhysicalInventoryCountItem_physicalCountId_fkey" FOREIGN KEY ("physicalCountId") REFERENCES public."PhysicalInventoryCount"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PhysicalInventoryCountItem PhysicalInventoryCountItem_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PhysicalInventoryCountItem"
    ADD CONSTRAINT "PhysicalInventoryCountItem_productId_fkey" FOREIGN KEY ("productId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PhysicalInventoryCount PhysicalInventoryCount_createdByUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PhysicalInventoryCount"
    ADD CONSTRAINT "PhysicalInventoryCount_createdByUserId_fkey" FOREIGN KEY ("createdByUserId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PhysicalInventoryCount PhysicalInventoryCount_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PhysicalInventoryCount"
    ADD CONSTRAINT "PhysicalInventoryCount_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PrescriptionGlassDetail PrescriptionGlassDetail_prescriptionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PrescriptionGlassDetail"
    ADD CONSTRAINT "PrescriptionGlassDetail_prescriptionId_fkey" FOREIGN KEY ("prescriptionId") REFERENCES public."Prescription"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PrescriptionGlassDetail PrescriptionGlassDetail_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PrescriptionGlassDetail"
    ADD CONSTRAINT "PrescriptionGlassDetail_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PrescriptionHistory PrescriptionHistory_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PrescriptionHistory"
    ADD CONSTRAINT "PrescriptionHistory_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PrescriptionHistory PrescriptionHistory_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PrescriptionHistory"
    ADD CONSTRAINT "PrescriptionHistory_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Prescription Prescription_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Prescription"
    ADD CONSTRAINT "Prescription_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Prescription Prescription_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Prescription"
    ADD CONSTRAINT "Prescription_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Prescription Prescription_doctorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Prescription"
    ADD CONSTRAINT "Prescription_doctorId_fkey" FOREIGN KEY ("doctorId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Prescription Prescription_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Prescription"
    ADD CONSTRAINT "Prescription_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PriceHistory PriceHistory_changedBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PriceHistory"
    ADD CONSTRAINT "PriceHistory_changedBy_fkey" FOREIGN KEY ("changedBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PriceHistory PriceHistory_priceUpdateId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PriceHistory"
    ADD CONSTRAINT "PriceHistory_priceUpdateId_fkey" FOREIGN KEY ("priceUpdateId") REFERENCES public."PriceUpdate"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: PriceHistory PriceHistory_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PriceHistory"
    ADD CONSTRAINT "PriceHistory_productId_fkey" FOREIGN KEY ("productId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PriceHistory PriceHistory_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PriceHistory"
    ADD CONSTRAINT "PriceHistory_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PriceUpdate PriceUpdate_appliedBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PriceUpdate"
    ADD CONSTRAINT "PriceUpdate_appliedBy_fkey" FOREIGN KEY ("appliedBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: PriceUpdate PriceUpdate_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PriceUpdate"
    ADD CONSTRAINT "PriceUpdate_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PriceUpdate PriceUpdate_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PriceUpdate"
    ADD CONSTRAINT "PriceUpdate_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ProductSerial ProductSerial_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductSerial"
    ADD CONSTRAINT "ProductSerial_productId_fkey" FOREIGN KEY ("productId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ProductSerial ProductSerial_saleItemId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductSerial"
    ADD CONSTRAINT "ProductSerial_saleItemId_fkey" FOREIGN KEY ("saleItemId") REFERENCES public."SaleItem"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ProductSerial ProductSerial_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductSerial"
    ADD CONSTRAINT "ProductSerial_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Product Product_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Product"
    ADD CONSTRAINT "Product_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Product Product_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Product"
    ADD CONSTRAINT "Product_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Product Product_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Product"
    ADD CONSTRAINT "Product_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PurchaseCheck PurchaseCheck_purchaseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PurchaseCheck"
    ADD CONSTRAINT "PurchaseCheck_purchaseId_fkey" FOREIGN KEY ("purchaseId") REFERENCES public."Purchase"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PurchasePayment PurchasePayment_purchaseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PurchasePayment"
    ADD CONSTRAINT "PurchasePayment_purchaseId_fkey" FOREIGN KEY ("purchaseId") REFERENCES public."Purchase"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Purchase Purchase_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Purchase"
    ADD CONSTRAINT "Purchase_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Purchase Purchase_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Purchase"
    ADD CONSTRAINT "Purchase_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Purchase Purchase_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Purchase"
    ADD CONSTRAINT "Purchase_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Purchase Purchase_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Purchase"
    ADD CONSTRAINT "Purchase_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: RefractionProtocol RefractionProtocol_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."RefractionProtocol"
    ADD CONSTRAINT "RefractionProtocol_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: RetinoscopyDistance RetinoscopyDistance_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."RetinoscopyDistance"
    ADD CONSTRAINT "RetinoscopyDistance_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: RetinoscopyType RetinoscopyType_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."RetinoscopyType"
    ADD CONSTRAINT "RetinoscopyType_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SMS SMS_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SMS"
    ADD CONSTRAINT "SMS_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SMS SMS_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SMS"
    ADD CONSTRAINT "SMS_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SMS SMS_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SMS"
    ADD CONSTRAINT "SMS_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SaleItem SaleItem_barcodeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SaleItem"
    ADD CONSTRAINT "SaleItem_barcodeId_fkey" FOREIGN KEY ("barcodeId") REFERENCES public."BarcodeManagement"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SaleItem SaleItem_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SaleItem"
    ADD CONSTRAINT "SaleItem_productId_fkey" FOREIGN KEY ("productId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SaleItem SaleItem_saleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SaleItem"
    ADD CONSTRAINT "SaleItem_saleId_fkey" FOREIGN KEY ("saleId") REFERENCES public."Sale"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Sale Sale_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sale"
    ADD CONSTRAINT "Sale_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Sale Sale_cashierShiftId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sale"
    ADD CONSTRAINT "Sale_cashierShiftId_fkey" FOREIGN KEY ("cashierShiftId") REFERENCES public."CashierShift"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Sale Sale_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sale"
    ADD CONSTRAINT "Sale_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Sale Sale_sellerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sale"
    ADD CONSTRAINT "Sale_sellerId_fkey" FOREIGN KEY ("sellerId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Sale Sale_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sale"
    ADD CONSTRAINT "Sale_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SlitLampExam SlitLampExam_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SlitLampExam"
    ADD CONSTRAINT "SlitLampExam_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SlitLampExam SlitLampExam_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SlitLampExam"
    ADD CONSTRAINT "SlitLampExam_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SlitLampExam SlitLampExam_examinerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SlitLampExam"
    ADD CONSTRAINT "SlitLampExam_examinerId_fkey" FOREIGN KEY ("examinerId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SlitLampExam SlitLampExam_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SlitLampExam"
    ADD CONSTRAINT "SlitLampExam_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: StockMovement StockMovement_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."StockMovement"
    ADD CONSTRAINT "StockMovement_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: StockMovement StockMovement_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."StockMovement"
    ADD CONSTRAINT "StockMovement_productId_fkey" FOREIGN KEY ("productId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: StockMovement StockMovement_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."StockMovement"
    ADD CONSTRAINT "StockMovement_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierOrderItem SupplierOrderItem_orderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierOrderItem"
    ADD CONSTRAINT "SupplierOrderItem_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES public."SupplierOrder"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierOrderItem SupplierOrderItem_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierOrderItem"
    ADD CONSTRAINT "SupplierOrderItem_productId_fkey" FOREIGN KEY ("productId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SupplierOrder SupplierOrder_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierOrder"
    ADD CONSTRAINT "SupplierOrder_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SupplierOrder SupplierOrder_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierOrder"
    ADD CONSTRAINT "SupplierOrder_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierOrder SupplierOrder_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierOrder"
    ADD CONSTRAINT "SupplierOrder_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Supplier Supplier_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Supplier"
    ADD CONSTRAINT "Supplier_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: TaskAttachment TaskAttachment_taskId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TaskAttachment"
    ADD CONSTRAINT "TaskAttachment_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES public."Task"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: TaskAttachment TaskAttachment_uploadedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TaskAttachment"
    ADD CONSTRAINT "TaskAttachment_uploadedById_fkey" FOREIGN KEY ("uploadedById") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: TaskComment TaskComment_taskId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TaskComment"
    ADD CONSTRAINT "TaskComment_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES public."Task"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: TaskComment TaskComment_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TaskComment"
    ADD CONSTRAINT "TaskComment_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Task Task_assignedToId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Task"
    ADD CONSTRAINT "Task_assignedToId_fkey" FOREIGN KEY ("assignedToId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Task Task_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Task"
    ADD CONSTRAINT "Task_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Task Task_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Task"
    ADD CONSTRAINT "Task_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Task Task_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Task"
    ADD CONSTRAINT "Task_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Task Task_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Task"
    ADD CONSTRAINT "Task_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: TaxRate TaxRate_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TaxRate"
    ADD CONSTRAINT "TaxRate_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: TenantSettings TenantSettings_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TenantSettings"
    ADD CONSTRAINT "TenantSettings_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Tenant Tenant_ownerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Tenant"
    ADD CONSTRAINT "Tenant_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: UserSettings UserSettings_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."UserSettings"
    ADD CONSTRAINT "UserSettings_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: User User_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: User User_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: VisionTest VisionTest_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."VisionTest"
    ADD CONSTRAINT "VisionTest_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: VisionTest VisionTest_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."VisionTest"
    ADD CONSTRAINT "VisionTest_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: VisionTest VisionTest_examinerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."VisionTest"
    ADD CONSTRAINT "VisionTest_examinerId_fkey" FOREIGN KEY ("examinerId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: VisionTest VisionTest_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."VisionTest"
    ADD CONSTRAINT "VisionTest_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkLab WorkLab_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkLab"
    ADD CONSTRAINT "WorkLab_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkLabel WorkLabel_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkLabel"
    ADD CONSTRAINT "WorkLabel_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkOrderStatus WorkOrderStatus_changedBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkOrderStatus"
    ADD CONSTRAINT "WorkOrderStatus_changedBy_fkey" FOREIGN KEY ("changedBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkOrderStatus WorkOrderStatus_workOrderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkOrderStatus"
    ADD CONSTRAINT "WorkOrderStatus_workOrderId_fkey" FOREIGN KEY ("workOrderId") REFERENCES public."WorkOrder"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkOrder WorkOrder_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkOrder"
    ADD CONSTRAINT "WorkOrder_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: WorkOrder WorkOrder_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkOrder"
    ADD CONSTRAINT "WorkOrder_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkOrder WorkOrder_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkOrder"
    ADD CONSTRAINT "WorkOrder_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkOrder WorkOrder_frameId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkOrder"
    ADD CONSTRAINT "WorkOrder_frameId_fkey" FOREIGN KEY ("frameId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: WorkOrder WorkOrder_labId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkOrder"
    ADD CONSTRAINT "WorkOrder_labId_fkey" FOREIGN KEY ("labId") REFERENCES public."WorkLab"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: WorkOrder WorkOrder_leftLensId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkOrder"
    ADD CONSTRAINT "WorkOrder_leftLensId_fkey" FOREIGN KEY ("leftLensId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: WorkOrder WorkOrder_prescriptionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkOrder"
    ADD CONSTRAINT "WorkOrder_prescriptionId_fkey" FOREIGN KEY ("prescriptionId") REFERENCES public."Prescription"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: WorkOrder WorkOrder_rightLensId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkOrder"
    ADD CONSTRAINT "WorkOrder_rightLensId_fkey" FOREIGN KEY ("rightLensId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: WorkOrder WorkOrder_saleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkOrder"
    ADD CONSTRAINT "WorkOrder_saleId_fkey" FOREIGN KEY ("saleId") REFERENCES public."Sale"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: WorkOrder WorkOrder_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkOrder"
    ADD CONSTRAINT "WorkOrder_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: WorkOrder WorkOrder_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkOrder"
    ADD CONSTRAINT "WorkOrder_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkOrder WorkOrder_updatedBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkOrder"
    ADD CONSTRAINT "WorkOrder_updatedBy_fkey" FOREIGN KEY ("updatedBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: WorkStatus WorkStatus_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkStatus"
    ADD CONSTRAINT "WorkStatus_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkSupplier WorkSupplier_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkSupplier"
    ADD CONSTRAINT "WorkSupplier_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkSupplyType WorkSupplyType_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WorkSupplyType"
    ADD CONSTRAINT "WorkSupplyType_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

