--
-- PostgreSQL database dump
--

\restrict ApOtFFJEBBr3YigQMF2pAKnMKxJJvIP5nzTpjbtsMrNSWXQyxDEzYv2LCw1aq6G

-- Dumped from database version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)

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

--
-- Name: ChatChannelType; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."ChatChannelType" AS ENUM (
    'GENERAL',
    'URGENT',
    'VISIT',
    'DIRECT',
    'SYSTEM'
);


ALTER TYPE public."ChatChannelType" OWNER TO postgres;

--
-- Name: ChatMessageType; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."ChatMessageType" AS ENUM (
    'TEXT',
    'QUICK_ACTION',
    'CHECKLIST',
    'STATUS',
    'ALERT',
    'SYSTEM',
    'TEMPLATE'
);


ALTER TYPE public."ChatMessageType" OWNER TO postgres;

--
-- Name: ChatNotificationType; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."ChatNotificationType" AS ENUM (
    'MESSAGE',
    'MENTION',
    'REACTION',
    'SYSTEM',
    'URGENT'
);


ALTER TYPE public."ChatNotificationType" OWNER TO postgres;

--
-- Name: ChatRole; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."ChatRole" AS ENUM (
    'ADMIN',
    'MODERATOR',
    'MEMBER',
    'OBSERVER'
);


ALTER TYPE public."ChatRole" OWNER TO postgres;

--
-- Name: ChatRoomType; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."ChatRoomType" AS ENUM (
    'ROOM',
    'LOBBY',
    'VISIT',
    'DIRECT'
);


ALTER TYPE public."ChatRoomType" OWNER TO postgres;

--
-- Name: MigrationPhase; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."MigrationPhase" AS ENUM (
    'UPLOAD',
    'EXTRACTION',
    'MIGRATION',
    'VERIFICATION',
    'CLEANUP'
);


ALTER TYPE public."MigrationPhase" OWNER TO postgres;

--
-- Name: MigrationStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."MigrationStatus" AS ENUM (
    'PENDING',
    'UPLOADING',
    'UPLOADED',
    'EXTRACTING',
    'EXTRACTED',
    'MIGRATING',
    'VERIFYING',
    'COMPLETED',
    'FAILED',
    'CANCELLED'
);


ALTER TYPE public."MigrationStatus" OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: AISuggestion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."AISuggestion" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "examinationId" text NOT NULL,
    "suggestionType" text NOT NULL,
    suggestion jsonb NOT NULL,
    reasoning text,
    confidence double precision,
    accepted boolean,
    "acceptedAt" timestamp(3) without time zone,
    "rejectedReason" text,
    "modifiedSuggestion" jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."AISuggestion" OWNER TO postgres;

--
-- Name: AddressLookup; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."AddressLookup" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "cityCode" integer,
    "streetCode" text,
    "startingHouseNumber" integer,
    "endingHouseNumber" integer,
    "streetZipcode" integer,
    "streetName" text,
    "alternateStreetName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."AddressLookup" OWNER TO postgres;

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
-- Name: ApplicationSetting; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ApplicationSetting" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "setId" integer,
    "setVal" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ApplicationSetting" OWNER TO postgres;

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
    "branchId" text,
    "SMSSent" boolean DEFAULT false NOT NULL,
    "TookPlace" text NOT NULL
);


ALTER TABLE public."Appointment" OWNER TO postgres;

--
-- Name: AuditLog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."AuditLog" (
    id text NOT NULL,
    "tenantId" text,
    "userId" text NOT NULL,
    action text NOT NULL,
    resource text NOT NULL,
    "resourceId" text,
    details text,
    "oldValues" jsonb,
    "newValues" jsonb,
    "ipAddress" text,
    "userAgent" text,
    metadata jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."AuditLog" OWNER TO postgres;

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
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "branchId" text
);


ALTER TABLE public."BarcodeManagement" OWNER TO postgres;

--
-- Name: Base; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Base" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "baseId" integer,
    "baseName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Base" OWNER TO postgres;

--
-- Name: BisData; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."BisData" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "bisId" integer,
    "bisNum" text,
    "bisName" text,
    phone text,
    fax text,
    email text,
    address text,
    "zipCode" integer,
    "creditMode" integer,
    "creditDays" integer,
    "creditFactor" numeric(65,30),
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."BisData" OWNER TO postgres;

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
-- Name: BusinessContact; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."BusinessContact" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "cntID" integer,
    "lastName" text,
    "firstName" text,
    "workPhone" text,
    "homePhone" text,
    "cellPhone" text,
    fax text,
    address text,
    "zipCode" integer,
    "cityID" integer,
    "eMail" text,
    "webSite" text,
    comment text,
    "hidCom" text,
    "isSapak" integer,
    "creditCon" integer,
    "remDate" timestamp(3) without time zone,
    "sapakID" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."BusinessContact" OWNER TO postgres;

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
-- Name: ChatChannel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ChatChannel" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "roomId" text NOT NULL,
    name text NOT NULL,
    "displayName" text NOT NULL,
    type public."ChatChannelType" DEFAULT 'GENERAL'::public."ChatChannelType" NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "isArchived" boolean DEFAULT false NOT NULL,
    "archivedAt" timestamp(3) without time zone,
    "archivedBy" text,
    "visitId" text,
    "patientId" text,
    settings jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ChatChannel" OWNER TO postgres;

--
-- Name: ChatChannelMember; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ChatChannelMember" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "channelId" text NOT NULL,
    "userId" text NOT NULL,
    "userType" text NOT NULL,
    role public."ChatRole" DEFAULT 'MEMBER'::public."ChatRole" NOT NULL,
    permissions jsonb,
    "muteNotifications" boolean DEFAULT false NOT NULL,
    "mutedUntil" timestamp(3) without time zone,
    "lastSeenAt" timestamp(3) without time zone,
    "unreadCount" integer DEFAULT 0 NOT NULL,
    "joinedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "leftAt" timestamp(3) without time zone
);


ALTER TABLE public."ChatChannelMember" OWNER TO postgres;

--
-- Name: ChatMessage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ChatMessage" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "channelId" text NOT NULL,
    "senderId" text NOT NULL,
    "senderType" text NOT NULL,
    "senderName" text,
    content text NOT NULL,
    "messageType" public."ChatMessageType" DEFAULT 'TEXT'::public."ChatMessageType" NOT NULL,
    "structuredData" jsonb,
    attachments jsonb,
    "readAt" timestamp(3) without time zone,
    "readBy" text,
    "pinnedAt" timestamp(3) without time zone,
    "pinnedBy" text,
    reactions jsonb,
    "replyToId" text,
    "threadId" text,
    "quickActions" jsonb,
    metadata jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "deletedAt" timestamp(3) without time zone
);


ALTER TABLE public."ChatMessage" OWNER TO postgres;

--
-- Name: ChatMessageTemplate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ChatMessageTemplate" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    name text NOT NULL,
    content text NOT NULL,
    type public."ChatMessageType" DEFAULT 'TEXT'::public."ChatMessageType" NOT NULL,
    category text,
    variables jsonb,
    "quickActions" jsonb,
    "isActive" boolean DEFAULT true NOT NULL,
    "isSystem" boolean DEFAULT false NOT NULL,
    "usageCount" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ChatMessageTemplate" OWNER TO postgres;

--
-- Name: ChatNotification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ChatNotification" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "userId" text NOT NULL,
    "channelId" text NOT NULL,
    "messageId" text,
    type public."ChatNotificationType" NOT NULL,
    title text NOT NULL,
    content text NOT NULL,
    data jsonb,
    "isRead" boolean DEFAULT false NOT NULL,
    "readAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."ChatNotification" OWNER TO postgres;

--
-- Name: ChatRoom; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ChatRoom" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    name text NOT NULL,
    "displayName" text NOT NULL,
    type public."ChatRoomType" DEFAULT 'ROOM'::public."ChatRoomType" NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    settings jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ChatRoom" OWNER TO postgres;

--
-- Name: ChatRoomMember; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ChatRoomMember" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "roomId" text NOT NULL,
    "userId" text NOT NULL,
    "userType" text NOT NULL,
    role public."ChatRole" DEFAULT 'MEMBER'::public."ChatRole" NOT NULL,
    permissions jsonb,
    "joinedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "leftAt" timestamp(3) without time zone
);


ALTER TABLE public."ChatRoomMember" OWNER TO postgres;

--
-- Name: ChatSearch; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ChatSearch" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "userId" text NOT NULL,
    query text NOT NULL,
    filters jsonb,
    results jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."ChatSearch" OWNER TO postgres;

--
-- Name: ChatTyping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ChatTyping" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "channelId" text NOT NULL,
    "userId" text NOT NULL,
    "userType" text NOT NULL,
    "userName" text,
    "startedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."ChatTyping" OWNER TO postgres;

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
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "branchId" text
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
-- Name: ClinicalData; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ClinicalData" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "eyeCheckCharId" integer,
    "eyeCheckCharName" text,
    "eyeCheckCharType" integer,
    "clinicCheckId" integer,
    "perId" integer,
    "userId" integer,
    "checkDate" timestamp(3) without time zone,
    "reCheckDate" timestamp(3) without time zone,
    "glassCheckDate" timestamp(3) without time zone,
    "yN1" integer,
    "yN2" integer,
    "yN3" integer,
    "yN4" integer,
    "yN5" integer,
    "yN6" integer,
    "yN7" integer,
    "yN8" integer,
    "yN9" integer,
    "yN10" integer,
    "yN11" integer,
    "yN12" integer,
    "yN13" integer,
    "yN14" integer,
    "yN15" integer,
    "yN16" integer,
    "yN17" integer,
    "yN18" integer,
    "yN19" integer,
    "yN20" integer,
    "yN21" integer,
    "yN22" integer,
    "yN23" integer,
    "yN24" integer,
    "yN25" integer,
    "yN26" integer,
    "yN27" integer,
    "yN28" integer,
    "yN29" integer,
    "yN30" integer,
    "yN31" integer,
    "yN32" integer,
    "yN33" integer,
    "yN34" integer,
    "yN35" integer,
    "yN36" integer,
    "yN37" integer,
    "yN38" integer,
    "yN39" integer,
    "yN40" integer,
    "yN41" integer,
    "yN42" integer,
    "yN43" integer,
    "yN44" integer,
    "yN45" integer,
    "yN46" integer,
    "yN47" integer,
    "yN48" integer,
    "yN49" integer,
    "yN50" integer,
    "yN51" integer,
    "yN52" integer,
    "yN53" integer,
    "yN54" integer,
    "yN55" integer,
    "yN56" integer,
    "yN57" integer,
    "yN58" integer,
    meds text,
    "medsEye" text,
    "prevTreat" text,
    com text,
    other1 text,
    other2 text,
    other3 text,
    other4 text,
    "eyeLidR" text,
    "eyeLidL" text,
    "tearWayR" text,
    "tearWayL" text,
    "choroidR" text,
    "choroidL" text,
    "limitR" text,
    "limitL" text,
    "cornR" text,
    "cornL" text,
    "chamberR" text,
    "chamberL" text,
    "angleR" text,
    "angleL" text,
    "iOPR" text,
    "iOPL" text,
    "irisR" text,
    "irisL" text,
    "pupilR" text,
    "pupilL" text,
    "lensR" text,
    "lensL" text,
    "enamelR" text,
    "enamelL" text,
    "diskR" text,
    "diskL" text,
    "cDAVR" text,
    "cDAVL" text,
    "maculaR" text,
    "maculaL" text,
    "perimeterR" text,
    "perimeterL" text,
    "amslaR" text,
    "amslaL" text,
    "vFieldR" text,
    "vFieldL" text,
    pic3 text,
    pic4 text,
    "cSR" text,
    "cSL" text,
    "fldId" integer,
    "fldName" text,
    "fVal" text,
    "iCount" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ClinicalData" OWNER TO postgres;

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
    "branchId" text,
    "choroidLeft" text,
    "choroidRight" text,
    "limitLeft" text,
    "limitRight" text,
    "perimeterLeft" text,
    "perimeterRight" text
);


ALTER TABLE public."ClinicalExamination" OWNER TO postgres;

--
-- Name: ClinicalImage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ClinicalImage" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "examinationId" text,
    "customerId" text NOT NULL,
    "imageType" text NOT NULL,
    eye text,
    "imageUrl" text NOT NULL,
    "thumbnailUrl" text,
    "fileName" text NOT NULL,
    "fileSize" integer NOT NULL,
    "mimeType" text NOT NULL,
    width integer,
    height integer,
    "captureDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "captureDevice" text,
    annotations jsonb,
    metadata jsonb,
    notes text,
    tags text[],
    diagnosis text,
    findings text,
    "aiAnalysis" jsonb,
    "aiConfidence" double precision,
    "uploadedBy" text NOT NULL,
    "isPrivate" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "deletedAt" timestamp(3) without time zone
);


ALTER TABLE public."ClinicalImage" OWNER TO postgres;

--
-- Name: ClinicalProtocol; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ClinicalProtocol" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    name text NOT NULL,
    "nameHe" text,
    description text,
    "protocolType" text NOT NULL,
    "triggerConditions" jsonb NOT NULL,
    "recommendedTests" jsonb,
    "mandatoryFields" jsonb,
    "followUpRules" jsonb,
    "referralRules" jsonb,
    "isActive" boolean DEFAULT true NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    "createdBy" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ClinicalProtocol" OWNER TO postgres;

--
-- Name: ClinicalReferral; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ClinicalReferral" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "examinationId" text,
    "referralType" text NOT NULL,
    specialty text,
    reason text NOT NULL,
    "reasonHe" text,
    urgency text DEFAULT 'ROUTINE'::text NOT NULL,
    "specialistName" text,
    "specialistPhone" text,
    "specialistEmail" text,
    "clinicName" text,
    "referralDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "letterSent" boolean DEFAULT false NOT NULL,
    "letterSentAt" timestamp(3) without time zone,
    "appointmentDate" timestamp(3) without time zone,
    "appointmentConfirmed" boolean DEFAULT false NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    "resultsReceived" boolean DEFAULT false NOT NULL,
    "resultsDate" timestamp(3) without time zone,
    "resultsSummary" text,
    "referralLetter" text,
    "resultsDocument" text,
    notes text,
    "createdBy" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ClinicalReferral" OWNER TO postgres;

--
-- Name: ClinicalRule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ClinicalRule" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "ruleName" text NOT NULL,
    "ruleNameHe" text,
    description text,
    "ruleType" text NOT NULL,
    "triggerConditions" jsonb NOT NULL,
    action jsonb NOT NULL,
    priority text DEFAULT 'MEDIUM'::text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "autoExecute" boolean DEFAULT false NOT NULL,
    "createdBy" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ClinicalRule" OWNER TO postgres;

--
-- Name: ClinicalRuleTrigger; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ClinicalRuleTrigger" (
    id text NOT NULL,
    "ruleId" text NOT NULL,
    "tenantId" text NOT NULL,
    "examinationId" text,
    "customerId" text,
    "triggeredAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "triggeredBy" text,
    "conditionsMet" jsonb NOT NULL,
    "actionTaken" jsonb,
    status text NOT NULL,
    "resultMessage" text,
    "completedAt" timestamp(3) without time zone
);


ALTER TABLE public."ClinicalRuleTrigger" OWNER TO postgres;

--
-- Name: ClndrSal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ClndrSal" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "userID" integer,
    month timestamp(3) without time zone,
    salery numeric(65,30),
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ClndrSal" OWNER TO postgres;

--
-- Name: ClndrTasksPriority; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ClndrTasksPriority" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "priorityId" integer,
    "priorityName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ClndrTasksPriority" OWNER TO postgres;

--
-- Name: ClndrWrk; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ClndrWrk" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "wrkId" integer,
    "userID" integer,
    "wrkDate" timestamp(3) without time zone,
    "wrkTime" numeric(65,30),
    "startTime" timestamp(3) without time zone,
    "endTime" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ClndrWrk" OWNER TO postgres;

--
-- Name: CollectionItem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CollectionItem" (
    id text NOT NULL,
    "collectionId" text NOT NULL,
    type text NOT NULL,
    "frameCatalogId" text,
    "lensCatalogId" text,
    "supplierCode" text,
    "priceOverride" numeric(10,2),
    stock integer,
    description text,
    "isPublished" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CollectionItem" OWNER TO postgres;

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
    "trialLenses" text,
    "finalSelection" text,
    "wearSchedule" text,
    "careSystem" text,
    "followUpDate" timestamp(3) without time zone,
    notes text,
    status text DEFAULT 'TRIAL'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "branchId" text,
    "cleaningSolution" text,
    complications text,
    "dailyWearHours" integer,
    "disinfectingSolution" text,
    "enzymaticCleaner" text,
    "kReadingOdAxis" integer,
    "kReadingOdFlat" double precision,
    "kReadingOdSteep" double precision,
    "kReadingOsAxis" integer,
    "kReadingOsFlat" double precision,
    "kReadingOsSteep" double precision,
    "leftEyeAddPower" double precision,
    "leftEyeAxis" integer,
    "leftEyeBaseCurve" double precision,
    "leftEyeBrand" text,
    "leftEyeCentering" text,
    "leftEyeColor" text,
    "leftEyeCylinder" double precision,
    "leftEyeDiameter" double precision,
    "leftEyeFitQuality" text,
    "leftEyeMaterial" text,
    "leftEyeMovement" text,
    "leftEyePower" double precision,
    "leftEyeType" text,
    "patientEducation" text,
    "replacementSchedule" text,
    "rewettingDrops" text,
    "rightEyeAddPower" double precision,
    "rightEyeAxis" integer,
    "rightEyeBaseCurve" double precision,
    "rightEyeBrand" text,
    "rightEyeCentering" text,
    "rightEyeColor" text,
    "rightEyeCylinder" double precision,
    "rightEyeDiameter" double precision,
    "rightEyeFitQuality" text,
    "rightEyeMaterial" text,
    "rightEyeMovement" text,
    "rightEyePower" double precision,
    "rightEyeType" text,
    "trialResults" text
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
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "pupilHeightL" double precision,
    "pupilHeightR" double precision
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
-- Name: ContactLensPricing; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ContactLensPricing" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "sapakID" integer,
    "cLensTypeID" integer,
    "clensCharID" integer,
    price numeric(65,30),
    "pubPrice" numeric(65,30),
    "recPrice" numeric(65,30),
    "privPrice" numeric(65,30),
    active integer,
    quantity integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ContactLensPricing" OWNER TO postgres;

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
-- Name: Conversation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Conversation" (
    id text NOT NULL,
    "supplierId" text NOT NULL,
    "tenantId" text NOT NULL,
    "relatedToType" text,
    "relatedToId" text,
    "lastMessageAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "isArchived" boolean DEFAULT false NOT NULL,
    "archivedBy" text,
    "archivedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Conversation" OWNER TO postgres;

--
-- Name: ConversationParticipant; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ConversationParticipant" (
    id text NOT NULL,
    "conversationId" text NOT NULL,
    "participantId" text NOT NULL,
    "participantType" text NOT NULL,
    "muteNotifications" boolean DEFAULT false NOT NULL,
    "mutedUntil" timestamp(3) without time zone,
    "lastSeenAt" timestamp(3) without time zone,
    "unreadCount" integer DEFAULT 0 NOT NULL,
    "joinedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "leftAt" timestamp(3) without time zone
);


ALTER TABLE public."ConversationParticipant" OWNER TO postgres;

--
-- Name: ConversationTyping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ConversationTyping" (
    id text NOT NULL,
    "conversationId" text NOT NULL,
    "typingUserId" text NOT NULL,
    "typingUserType" text NOT NULL,
    "typingUserName" text,
    "startedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."ConversationTyping" OWNER TO postgres;

--
-- Name: CrdBuysWorkLab; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CrdBuysWorkLab" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "labID" integer,
    "labName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CrdBuysWorkLab" OWNER TO postgres;

--
-- Name: CrdBuysWorkSapak; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CrdBuysWorkSapak" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "sapakID" integer,
    "sapakName" text,
    "itemCode" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CrdBuysWorkSapak" OWNER TO postgres;

--
-- Name: CrdBuysWorkStat; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CrdBuysWorkStat" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "workStatId" integer,
    "workStatName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CrdBuysWorkStat" OWNER TO postgres;

--
-- Name: CrdBuysWorkSupply; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CrdBuysWorkSupply" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "workSupplyId" integer,
    "workSupplyName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CrdBuysWorkSupply" OWNER TO postgres;

--
-- Name: CrdBuysWorkType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CrdBuysWorkType" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "workTypeId" integer,
    "workTypeName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CrdBuysWorkType" OWNER TO postgres;

--
-- Name: CrdClensChecksMater; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CrdClensChecksMater" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "materId" integer,
    "materName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CrdClensChecksMater" OWNER TO postgres;

--
-- Name: CrdClensChecksPr; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CrdClensChecksPr" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "prId" integer,
    "prName" text,
    "idCount" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CrdClensChecksPr" OWNER TO postgres;

--
-- Name: CrdClensChecksTint; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CrdClensChecksTint" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "tintId" integer,
    "tintName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CrdClensChecksTint" OWNER TO postgres;

--
-- Name: CrdClensManuf; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CrdClensManuf" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "clensManufId" integer,
    "clensManufName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CrdClensManuf" OWNER TO postgres;

--
-- Name: CrdClensSolClean; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CrdClensSolClean" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "clensSolCleanId" integer,
    "clensSolCleanName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CrdClensSolClean" OWNER TO postgres;

--
-- Name: CrdClensSolDisinfect; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CrdClensSolDisinfect" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "clensSolDisinfectId" integer,
    "clensSolDisinfectName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CrdClensSolDisinfect" OWNER TO postgres;

--
-- Name: CrdClensSolRinse; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CrdClensSolRinse" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "clensSolRinseId" integer,
    "clensSolRinseName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CrdClensSolRinse" OWNER TO postgres;

--
-- Name: CrdClensType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CrdClensType" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "clensTypeId" integer,
    "clensTypeName" text,
    "idCount" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CrdClensType" OWNER TO postgres;

--
-- Name: CrdGlassIOPInst; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CrdGlassIOPInst" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "iOPInstId" integer,
    "iOPInstName" text,
    "idCount" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CrdGlassIOPInst" OWNER TO postgres;

--
-- Name: CrdGlassRetDist; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CrdGlassRetDist" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "retDistId" integer,
    "retDistName" text,
    "idCount" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CrdGlassRetDist" OWNER TO postgres;

--
-- Name: CrdGlassRetType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CrdGlassRetType" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "retTypeId" integer,
    "retTypeName" text,
    "idCount" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CrdGlassRetType" OWNER TO postgres;

--
-- Name: CrdGlassUse; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CrdGlassUse" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "glassUseId" integer,
    "glassUseName" text,
    "idCount" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CrdGlassUse" OWNER TO postgres;

--
-- Name: CreditCard; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CreditCard" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "creditCardId" integer,
    "creditCardName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CreditCard" OWNER TO postgres;

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
-- Name: CreditType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CreditType" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "creditTypeId" integer,
    "creditTypeName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CreditType" OWNER TO postgres;

--
-- Name: CustomReport; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CustomReport" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "oRepId" integer,
    "oRepHeader" text,
    "oRepName" text,
    "oRepType" integer,
    "oRPTPara" text,
    "secLevel" integer,
    "inExe" integer,
    "oRepSql" text,
    "uRepId" integer,
    "uRepSql" text,
    "uRepHeader" text,
    "uRepName" text,
    "uRepType" integer,
    "uRPTPara" text,
    "loadedForm" text,
    "firstCtl" text,
    "firstIndex" integer,
    "secCtl" text,
    "secIndex" integer,
    "shortCutNum" integer,
    trans text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CustomReport" OWNER TO postgres;

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
    "updatedAt" timestamp(3) without time zone NOT NULL,
    address text,
    "branchId" text,
    "cityId" text,
    comment text,
    "discountId" text,
    email text,
    fax text,
    "groupId" text NOT NULL,
    phone text,
    "zipCode" text
);


ALTER TABLE public."CustomerGroup" OWNER TO postgres;

--
-- Name: CustomerLastVisit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CustomerLastVisit" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "customerNumber" integer,
    "lastVisitDate" timestamp(3) without time zone,
    "lastVisitType" text,
    "lastAppointmentDate" timestamp(3) without time zone,
    "lastPurchaseDate" timestamp(3) without time zone,
    "lastExaminationDate" timestamp(3) without time zone,
    "visitCount" integer DEFAULT 0 NOT NULL,
    "purchaseCount" integer DEFAULT 0 NOT NULL,
    "examinationCount" integer DEFAULT 0 NOT NULL,
    "totalSpent" double precision DEFAULT 0 NOT NULL,
    "lastUpdated" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."CustomerLastVisit" OWNER TO postgres;

--
-- Name: CustomerOrder; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CustomerOrder" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "itemData" integer,
    "listIndex" integer,
    "desc" text,
    deaf integer,
    "lblWiz" integer,
    "lblWizType" integer,
    "lblWizFld" text,
    "letterFld" text,
    "letterWiz" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CustomerOrder" OWNER TO postgres;

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
-- Name: DataMigrationError; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."DataMigrationError" (
    id text NOT NULL,
    "migrationId" text NOT NULL,
    "timestamp" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    phase public."MigrationPhase" NOT NULL,
    "table" text,
    "recordIndex" integer,
    "recordData" jsonb,
    "errorType" text NOT NULL,
    "errorMessage" text NOT NULL,
    "stackTrace" text,
    context jsonb
);


ALTER TABLE public."DataMigrationError" OWNER TO postgres;

--
-- Name: DataMigrationRun; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."DataMigrationRun" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    status public."MigrationStatus" DEFAULT 'PENDING'::public."MigrationStatus" NOT NULL,
    phase public."MigrationPhase" DEFAULT 'UPLOAD'::public."MigrationPhase" NOT NULL,
    "fileName" text NOT NULL,
    "fileSize" integer NOT NULL,
    "filePath" text NOT NULL,
    "totalTables" integer DEFAULT 186 NOT NULL,
    "tablesProcessed" integer DEFAULT 0 NOT NULL,
    "totalRecords" integer DEFAULT 0 NOT NULL,
    "recordsProcessed" integer DEFAULT 0 NOT NULL,
    "currentTable" text,
    "startTime" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "endTime" timestamp(3) without time zone,
    duration integer,
    "recordsInserted" integer DEFAULT 0 NOT NULL,
    "recordsSkipped" integer DEFAULT 0 NOT NULL,
    "errorCount" integer DEFAULT 0 NOT NULL,
    "warningCount" integer DEFAULT 0 NOT NULL,
    "verificationResults" jsonb,
    "auditReport" jsonb,
    "extractedDataPath" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."DataMigrationRun" OWNER TO postgres;

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
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "discountId" text,
    "prlCheck" numeric(2,2) NOT NULL,
    "prlClens" numeric(2,2) NOT NULL,
    "prlFrame" numeric(2,2) NOT NULL,
    "prlGlass" numeric(2,2) NOT NULL,
    "prlGlassBif" numeric(2,2) NOT NULL,
    "prlGlassMul" numeric(2,2) NOT NULL,
    "prlGlassOneP" numeric(2,2) NOT NULL,
    "prlGlassOneS" numeric(2,2) NOT NULL,
    "prlMisc" numeric(2,2) NOT NULL,
    "prlProp" numeric(2,2) NOT NULL,
    "prlService" numeric(2,2) NOT NULL,
    "prlSolution" numeric(2,2) NOT NULL,
    "prlSunGlass" numeric(2,2) NOT NULL,
    "prlTreat" numeric(2,2) NOT NULL
);


ALTER TABLE public."Discount" OWNER TO postgres;

--
-- Name: DiseaseDiagnosis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."DiseaseDiagnosis" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "perId" integer,
    "checkDate" timestamp(3) without time zone,
    "pushUp" integer,
    "minusLens" integer,
    "monAccFac6" numeric(65,30),
    "monAccFac7" numeric(65,30),
    "monAccFac8" numeric(65,30),
    "monAccFac13" numeric(65,30),
    "binAccFac6" numeric(65,30),
    "binAccFac7" numeric(65,30),
    "binAccFac8" numeric(65,30),
    "binAccFac13" numeric(65,30),
    "mEMRet" numeric(65,30),
    "fusedXCyl" numeric(65,30),
    "nRA" numeric(65,30),
    "pRA" numeric(65,30),
    "coverDist" text,
    "coverNear" text,
    "distLatFor" text,
    "distVerFor" text,
    "nearLatFor" text,
    "nearVerFor" text,
    "aCARatio" text,
    "smverBo6M" text,
    "smverBi6M" text,
    "smverBo40CM" text,
    "smverBi40CM" text,
    "stverBo7" text,
    "stverBi7" text,
    "stverBo6M" text,
    "stverBi6M" text,
    "stverBo40CM" text,
    "stverBi40CM" text,
    "jmpVer5" numeric(65,30),
    "jmpVer8" numeric(65,30),
    "accTarget" text,
    penlight text,
    "penLightRG" text,
    summary text,
    "userId" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."DiseaseDiagnosis" OWNER TO postgres;

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
-- Name: Dummy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Dummy" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    dummy integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Dummy" OWNER TO postgres;

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
-- Name: EquipmentConfig; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."EquipmentConfig" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "equipmentType" text NOT NULL,
    manufacturer text NOT NULL,
    model text NOT NULL,
    "serialNumber" text,
    "connectionType" text NOT NULL,
    "connectionConfig" jsonb NOT NULL,
    "mappingRules" jsonb,
    "isActive" boolean DEFAULT true NOT NULL,
    "autoImport" boolean DEFAULT false NOT NULL,
    notes text,
    "installedDate" timestamp(3) without time zone,
    "lastCalibration" timestamp(3) without time zone,
    "createdBy" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."EquipmentConfig" OWNER TO postgres;

--
-- Name: EquipmentImportLog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."EquipmentImportLog" (
    id text NOT NULL,
    "equipmentId" text NOT NULL,
    "tenantId" text NOT NULL,
    "examinationId" text,
    "importDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "dataType" text NOT NULL,
    "rawData" jsonb NOT NULL,
    "mappedData" jsonb,
    status text NOT NULL,
    "errorMessage" text,
    "recordsImported" integer DEFAULT 0 NOT NULL,
    "importedBy" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."EquipmentImportLog" OWNER TO postgres;

--
-- Name: ExamTemplate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ExamTemplate" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    name text NOT NULL,
    "nameHe" text,
    description text,
    "templateType" text NOT NULL,
    sections jsonb NOT NULL,
    "requiredFields" jsonb NOT NULL,
    "conditionalRules" jsonb,
    "defaultValues" jsonb,
    "isDefault" boolean DEFAULT false NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "isPublic" boolean DEFAULT false NOT NULL,
    "createdBy" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ExamTemplate" OWNER TO postgres;

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
    "branchId" text,
    "bifocalAddOd" double precision,
    "bifocalAddOs" double precision,
    "intermediateAddOd" double precision,
    "intermediateAddOs" double precision,
    "multifocalAddOd" double precision,
    "multifocalAddOs" double precision,
    "pdNearOd" double precision,
    "pdNearOs" double precision,
    "pdOd" double precision,
    "pdOs" double precision,
    "protocolId" text,
    "templateId" text
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
-- Name: Eye; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Eye" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "eyeId" integer,
    "eyeName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Eye" OWNER TO postgres;

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
-- Name: FamilyAuditLog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."FamilyAuditLog" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "relationshipId" text,
    "customerId" text NOT NULL,
    action text NOT NULL,
    "actionType" text NOT NULL,
    "oldValue" jsonb,
    "newValue" jsonb,
    "userId" text NOT NULL,
    reason text,
    "ipAddress" text,
    "userAgent" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."FamilyAuditLog" OWNER TO postgres;

--
-- Name: FamilyRelationship; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."FamilyRelationship" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "relatedCustomerId" text NOT NULL,
    "relationshipType" text NOT NULL,
    "isPrimary" boolean DEFAULT false NOT NULL,
    verified boolean DEFAULT false NOT NULL,
    "verifiedBy" text,
    "verifiedAt" timestamp(3) without time zone,
    "confidenceScore" double precision,
    notes text,
    tags text[] DEFAULT ARRAY[]::text[],
    "createdBy" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "deletedAt" timestamp(3) without time zone
);


ALTER TABLE public."FamilyRelationship" OWNER TO postgres;

--
-- Name: FaxCommunication; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."FaxCommunication" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "faxId" integer,
    "sapakDestId" integer,
    "sendTime" timestamp(3) without time zone,
    "jobInfo" text,
    "faxStatId" integer,
    "faxStatName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."FaxCommunication" OWNER TO postgres;

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
-- Name: FollowUpReminder; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."FollowUpReminder" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "examinationId" text,
    "reminderType" text NOT NULL,
    "dueDate" timestamp(3) without time zone NOT NULL,
    reason text NOT NULL,
    "reasonHe" text,
    notes text,
    status text DEFAULT 'PENDING'::text NOT NULL,
    priority text DEFAULT 'NORMAL'::text NOT NULL,
    "sentAt" timestamp(3) without time zone,
    "sentVia" text,
    "completedAt" timestamp(3) without time zone,
    "scheduledAppointmentId" text,
    "createdBy" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."FollowUpReminder" OWNER TO postgres;

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
-- Name: FrameData; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."FrameData" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "sapakId" integer,
    "labelId" integer,
    "modelId" integer,
    price numeric(65,30),
    "pubPrice" numeric(65,30),
    "recPrice" numeric(65,30),
    "privPrice" numeric(65,30),
    active integer,
    quantity integer,
    "modelName" text,
    "iSG" integer,
    sizes text,
    "labelName" text,
    "privColorId" integer,
    "privColorName" text,
    "frameColorId" text,
    "frameColorName" text,
    "framePic" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."FrameData" OWNER TO postgres;

--
-- Name: FrameTrial; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."FrameTrial" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "customerId" text NOT NULL,
    "examinationId" text,
    "checkDate" timestamp(3) without time zone NOT NULL,
    "frameSupplierId" text,
    "frameBrandId" text,
    "frameModel" text,
    "frameColor" text,
    "frameSize" text,
    "triedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    selected boolean DEFAULT false NOT NULL,
    notes text,
    "createdBy" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."FrameTrial" OWNER TO postgres;

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
-- Name: Household; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Household" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "householdHash" text NOT NULL,
    "displayName" text,
    "primaryContactId" text,
    "memberCount" integer DEFAULT 1 NOT NULL,
    "lifetimeValue" numeric(12,2) DEFAULT 0 NOT NULL,
    "lastActivityDate" timestamp(3) without time zone,
    address text,
    city text,
    "zipCode" text,
    notes text,
    tags text[] DEFAULT ARRAY[]::text[],
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "deletedAt" timestamp(3) without time zone
);


ALTER TABLE public."Household" OWNER TO postgres;

--
-- Name: InvMoveType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."InvMoveType" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "invMoveTypeId" integer,
    "invMoveTypeName" text,
    "moveAction" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."InvMoveType" OWNER TO postgres;

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
    "tenantId" text NOT NULL,
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
-- Name: InventoryReference; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."InventoryReference" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "itemColorId" integer,
    "itemColorName" text,
    "itemCode" integer,
    "itemStatId" integer,
    "itemStatName" text,
    "itemLineId" integer,
    "catId" integer,
    sold integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."InventoryReference" OWNER TO postgres;

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
    "tenantId" text NOT NULL,
    "invoiceId" text NOT NULL,
    "paymentDate" timestamp(3) without time zone NOT NULL,
    amount double precision NOT NULL,
    "paymentMethod" text NOT NULL,
    reference text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."InvoicePayment" OWNER TO postgres;

--
-- Name: InvoiceType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."InvoiceType" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "invoiceTypeId" integer,
    "invoiceTypeName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."InvoiceType" OWNER TO postgres;

--
-- Name: InvoiceVerification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."InvoiceVerification" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "invoiceCheckId" integer,
    "invoicePayId" integer,
    "checkId" text,
    "checkDate" timestamp(3) without time zone,
    "checkSum" numeric(65,30),
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."InvoiceVerification" OWNER TO postgres;

--
-- Name: ItemCountsYear; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ItemCountsYear" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "countYear" integer,
    "countDate" timestamp(3) without time zone,
    closed integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ItemCountsYear" OWNER TO postgres;

--
-- Name: ItemStatus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ItemStatus" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "productId" text NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    opening double precision DEFAULT 0 NOT NULL,
    purchases double precision DEFAULT 0 NOT NULL,
    sales double precision DEFAULT 0 NOT NULL,
    removals double precision DEFAULT 0 NOT NULL,
    closing double precision DEFAULT 0 NOT NULL,
    "costValue" double precision DEFAULT 0 NOT NULL,
    "saleValue" double precision DEFAULT 0 NOT NULL,
    revenue double precision DEFAULT 0 NOT NULL,
    cogs double precision DEFAULT 0 NOT NULL,
    "grossProfit" double precision DEFAULT 0 NOT NULL,
    "profitPct" double precision DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ItemStatus" OWNER TO postgres;

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
-- Name: Lang; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Lang" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "langId" integer,
    "langName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Lang" OWNER TO postgres;

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
-- Name: LensSolution; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."LensSolution" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "solutionId" integer,
    "solutionName" text,
    "sapakID" integer,
    price numeric(65,30),
    "pubPrice" numeric(65,30),
    "recPrice" numeric(65,30),
    "privPrice" numeric(65,30),
    active integer,
    quantity integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."LensSolution" OWNER TO postgres;

--
-- Name: LensTreatment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."LensTreatment" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "sapakID" integer,
    "lensTypeID" integer,
    "lensMaterID" integer,
    "treatCharID" integer,
    "treatCharName" text,
    "idCount" integer,
    "treatCharId" integer,
    "treatId" integer,
    "treatName" text,
    "fldName" text,
    "treatRule" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."LensTreatment" OWNER TO postgres;

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
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "idCount" integer DEFAULT 0 NOT NULL
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
-- Name: Message; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Message" (
    id text NOT NULL,
    "conversationId" text NOT NULL,
    "senderId" text NOT NULL,
    "senderType" text NOT NULL,
    "senderName" text,
    content text NOT NULL,
    attachments jsonb,
    "readAt" timestamp(3) without time zone,
    "readBy" text,
    "messageType" text DEFAULT 'TEXT'::text NOT NULL,
    metadata jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "deletedAt" timestamp(3) without time zone
);


ALTER TABLE public."Message" OWNER TO postgres;

--
-- Name: MessageAttachment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."MessageAttachment" (
    id text NOT NULL,
    "messageId" text,
    "fileName" text NOT NULL,
    "fileUrl" text NOT NULL,
    "fileSize" integer NOT NULL,
    "mimeType" text NOT NULL,
    "uploaderId" text NOT NULL,
    "uploaderType" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."MessageAttachment" OWNER TO postgres;

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
-- Name: MigrationLog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."MigrationLog" (
    id text NOT NULL,
    "migrationId" text NOT NULL,
    "timestamp" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    level text NOT NULL,
    step text NOT NULL,
    message text NOT NULL,
    details jsonb DEFAULT '{}'::jsonb NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."MigrationLog" OWNER TO postgres;

--
-- Name: MigrationRun; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."MigrationRun" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "fileName" text NOT NULL,
    "filePath" text NOT NULL,
    "fileSize" bigint NOT NULL,
    status text NOT NULL,
    progress integer DEFAULT 0 NOT NULL,
    "currentStep" text,
    "startedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "completedAt" timestamp(3) without time zone,
    "errorMessage" text,
    "tablesProcessed" integer DEFAULT 0 NOT NULL,
    "recordsImported" integer DEFAULT 0 NOT NULL,
    "recordsSkipped" integer DEFAULT 0 NOT NULL,
    "recordsFailed" integer DEFAULT 0 NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    "createdBy" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "branchId" text
);


ALTER TABLE public."MigrationRun" OWNER TO postgres;

--
-- Name: MigrationTableResult; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."MigrationTableResult" (
    id text NOT NULL,
    "migrationId" text NOT NULL,
    "tableName" text NOT NULL,
    "sourceTable" text NOT NULL,
    "recordsSource" integer DEFAULT 0 NOT NULL,
    "recordsImported" integer DEFAULT 0 NOT NULL,
    "recordsSkipped" integer DEFAULT 0 NOT NULL,
    "recordsFailed" integer DEFAULT 0 NOT NULL,
    "successRate" numeric(5,2) DEFAULT 0 NOT NULL,
    status text NOT NULL,
    "errorMessage" text,
    "startedAt" timestamp(3) without time zone,
    "completedAt" timestamp(3) without time zone,
    duration integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."MigrationTableResult" OWNER TO postgres;

--
-- Name: MovementProperty; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."MovementProperty" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "movementPropertyId" integer NOT NULL,
    name text NOT NULL,
    "nameHe" text,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."MovementProperty" OWNER TO postgres;

--
-- Name: MovementType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."MovementType" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "movementTypeId" integer NOT NULL,
    name text NOT NULL,
    "nameHe" text,
    action integer NOT NULL,
    category text NOT NULL,
    "requiresInvoice" boolean DEFAULT false NOT NULL,
    "requiresReason" boolean DEFAULT false NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."MovementType" OWNER TO postgres;

--
-- Name: NewProduct; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."NewProduct" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "productId" text,
    name text NOT NULL,
    "nameHe" text,
    description text,
    "descriptionHe" text,
    "imageUrl" text,
    "isActive" boolean DEFAULT true NOT NULL,
    "displayFrom" timestamp(3) without time zone NOT NULL,
    "displayUntil" timestamp(3) without time zone,
    "displayOrder" integer DEFAULT 0 NOT NULL,
    category text,
    tags text[],
    "createdBy" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."NewProduct" OWNER TO postgres;

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
    "tenantId" text NOT NULL,
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
-- Name: POSAuditLog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."POSAuditLog" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "terminalId" text,
    "userId" text NOT NULL,
    action text NOT NULL,
    "entityType" text NOT NULL,
    "entityId" text,
    "beforeState" jsonb,
    "afterState" jsonb,
    changes jsonb,
    "ipAddress" text,
    "userAgent" text,
    metadata jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."POSAuditLog" OWNER TO postgres;

--
-- Name: POSCashDrop; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."POSCashDrop" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "shiftId" text NOT NULL,
    "dropNumber" text NOT NULL,
    amount numeric(12,2) NOT NULL,
    "billBreakdown" jsonb,
    reason text,
    "depositedBy" text NOT NULL,
    "verifiedBy" text,
    "verifiedAt" timestamp(3) without time zone,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."POSCashDrop" OWNER TO postgres;

--
-- Name: POSCashPickup; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."POSCashPickup" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "shiftId" text NOT NULL,
    "pickupNumber" text NOT NULL,
    amount numeric(12,2) NOT NULL,
    "billBreakdown" jsonb,
    reason text,
    "pickedUpBy" text NOT NULL,
    "approvedBy" text,
    "approvedAt" timestamp(3) without time zone,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."POSCashPickup" OWNER TO postgres;

--
-- Name: POSInventoryMovement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."POSInventoryMovement" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "transactionId" text,
    "productId" text NOT NULL,
    "branchId" text NOT NULL,
    "movementType" text NOT NULL,
    quantity numeric(12,3) NOT NULL,
    "previousQuantity" numeric(12,3),
    "newQuantity" numeric(12,3),
    reason text,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."POSInventoryMovement" OWNER TO postgres;

--
-- Name: POSPayment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."POSPayment" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "transactionId" text NOT NULL,
    "paymentNumber" text NOT NULL,
    "paymentMethod" text NOT NULL,
    amount numeric(12,2) NOT NULL,
    currency text DEFAULT 'ILS'::text NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    "cardToken" text,
    "cardLastFour" text,
    "cardBrand" text,
    "cardType" text,
    "cardholderName" text,
    "expiryMonth" integer,
    "expiryYear" integer,
    "authorizationCode" text,
    "processorTransactionId" text,
    "gatewayResponse" jsonb,
    "processorName" text,
    "installmentPlan" text,
    "installmentCount" integer,
    "installmentAmount" numeric(12,2),
    "firstPayment" numeric(12,2),
    "checkNumber" text,
    "checkDate" timestamp(3) without time zone,
    "bankName" text,
    "bankBranch" text,
    "accountNumber" text,
    "transferReference" text,
    "transferDate" timestamp(3) without time zone,
    "voucherCode" text,
    "voucherType" text,
    notes text,
    metadata jsonb,
    "processedAt" timestamp(3) without time zone,
    "failedAt" timestamp(3) without time zone,
    "failureReason" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."POSPayment" OWNER TO postgres;

--
-- Name: POSPaymentRefund; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."POSPaymentRefund" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "paymentId" text NOT NULL,
    "refundNumber" text NOT NULL,
    amount numeric(12,2) NOT NULL,
    reason text,
    status text DEFAULT 'PENDING'::text NOT NULL,
    "processorRefundId" text,
    "createdBy" text NOT NULL,
    "approvedBy" text,
    "approvedAt" timestamp(3) without time zone,
    "processedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."POSPaymentRefund" OWNER TO postgres;

--
-- Name: POSPriceList; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."POSPriceList" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    name text NOT NULL,
    description text,
    "priceListType" text NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "validFrom" timestamp(3) without time zone,
    "validTo" timestamp(3) without time zone,
    "applicableTerminals" text[],
    "applicableCustomerGroups" text[],
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."POSPriceList" OWNER TO postgres;

--
-- Name: POSPriceListItem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."POSPriceListItem" (
    id text NOT NULL,
    "priceListId" text NOT NULL,
    "productId" text NOT NULL,
    price numeric(12,2) NOT NULL,
    "discountPercent" numeric(5,2),
    "minQuantity" integer DEFAULT 1,
    "maxQuantity" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."POSPriceListItem" OWNER TO postgres;

--
-- Name: POSReceipt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."POSReceipt" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text NOT NULL,
    "terminalId" text NOT NULL,
    "transactionId" text,
    "receiptNumber" text NOT NULL,
    "receiptType" text NOT NULL,
    "customerId" text,
    "customerName" text,
    "customerEmail" text,
    "customerPhone" text,
    "totalAmount" numeric(12,2) NOT NULL,
    currency text DEFAULT 'ILS'::text NOT NULL,
    "receiptTemplate" text DEFAULT 'DEFAULT'::text,
    "receiptData" jsonb NOT NULL,
    "qrCode" text,
    signature text,
    "printCount" integer DEFAULT 0 NOT NULL,
    "emailSent" boolean DEFAULT false NOT NULL,
    "emailSentAt" timestamp(3) without time zone,
    "printedAt" timestamp(3) without time zone,
    "voidedAt" timestamp(3) without time zone,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."POSReceipt" OWNER TO postgres;

--
-- Name: POSReportSnapshot; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."POSReportSnapshot" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "reportType" text NOT NULL,
    "reportNumber" text NOT NULL,
    "reportData" jsonb NOT NULL,
    "periodStart" timestamp(3) without time zone NOT NULL,
    "periodEnd" timestamp(3) without time zone NOT NULL,
    "generatedBy" text NOT NULL,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."POSReportSnapshot" OWNER TO postgres;

--
-- Name: POSSession; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."POSSession" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "terminalId" text NOT NULL,
    "userId" text NOT NULL,
    "sessionNumber" text NOT NULL,
    "startTime" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "endTime" timestamp(3) without time zone,
    status text DEFAULT 'ACTIVE'::text NOT NULL,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."POSSession" OWNER TO postgres;

--
-- Name: POSSyncQueue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."POSSyncQueue" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "terminalId" text NOT NULL,
    operation text NOT NULL,
    "entityType" text NOT NULL,
    "entityId" text NOT NULL,
    payload jsonb NOT NULL,
    priority integer DEFAULT 5 NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    "maxAttempts" integer DEFAULT 3 NOT NULL,
    "lastError" text,
    "syncedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."POSSyncQueue" OWNER TO postgres;

--
-- Name: POSTerminal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."POSTerminal" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text NOT NULL,
    "terminalNumber" text NOT NULL,
    "terminalName" text NOT NULL,
    "terminalType" text NOT NULL,
    status text DEFAULT 'ACTIVE'::text NOT NULL,
    "ipAddress" text,
    "macAddress" text,
    "deviceInfo" jsonb,
    configuration jsonb,
    "lastHeartbeat" timestamp(3) without time zone,
    "lastSyncedAt" timestamp(3) without time zone,
    "receiptPrinter" text,
    "fiscalPrinter" text,
    "isOnline" boolean DEFAULT true NOT NULL,
    "allowOffline" boolean DEFAULT true NOT NULL,
    "maxOfflineHours" integer DEFAULT 24 NOT NULL,
    "enableBarcode" boolean DEFAULT true NOT NULL,
    "enableScale" boolean DEFAULT false NOT NULL,
    "enableCardReader" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "activatedAt" timestamp(3) without time zone,
    "deactivatedAt" timestamp(3) without time zone
);


ALTER TABLE public."POSTerminal" OWNER TO postgres;

--
-- Name: POSTransaction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."POSTransaction" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text NOT NULL,
    "terminalId" text NOT NULL,
    "sessionId" text,
    "shiftId" text,
    "transactionNumber" text NOT NULL,
    "transactionType" text NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    "customerId" text,
    "cashierId" text NOT NULL,
    "supervisorId" text,
    subtotal numeric(12,2) DEFAULT 0 NOT NULL,
    "discountAmount" numeric(12,2) DEFAULT 0 NOT NULL,
    "taxAmount" numeric(12,2) DEFAULT 0 NOT NULL,
    "totalAmount" numeric(12,2) DEFAULT 0 NOT NULL,
    "paidAmount" numeric(12,2) DEFAULT 0 NOT NULL,
    "changeAmount" numeric(12,2) DEFAULT 0 NOT NULL,
    "roundingAdjustment" numeric(12,2) DEFAULT 0 NOT NULL,
    currency text DEFAULT 'ILS'::text NOT NULL,
    "exchangeRate" numeric(12,6) DEFAULT 1.0,
    "originalTransactionId" text,
    "refundedTransactionId" text,
    "receiptId" text,
    "saleId" text,
    notes text,
    signature text,
    "hashField" text,
    metadata jsonb,
    "isOffline" boolean DEFAULT false NOT NULL,
    "syncStatus" text DEFAULT 'SYNCED'::text,
    "lastSyncedAt" timestamp(3) without time zone,
    "transactionDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "completedAt" timestamp(3) without time zone,
    "voidedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."POSTransaction" OWNER TO postgres;

--
-- Name: POSTransactionDiscount; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."POSTransactionDiscount" (
    id text NOT NULL,
    "transactionId" text NOT NULL,
    "discountCode" text,
    "discountType" text NOT NULL,
    "discountValue" numeric(12,2) NOT NULL,
    "discountPercent" numeric(5,2),
    amount numeric(12,2) NOT NULL,
    reason text,
    "requiresApproval" boolean DEFAULT false NOT NULL,
    "approvedBy" text,
    "approvedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."POSTransactionDiscount" OWNER TO postgres;

--
-- Name: POSTransactionEvent; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."POSTransactionEvent" (
    id text NOT NULL,
    "transactionId" text NOT NULL,
    "eventType" text NOT NULL,
    "eventData" jsonb,
    "timestamp" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."POSTransactionEvent" OWNER TO postgres;

--
-- Name: POSTransactionItem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."POSTransactionItem" (
    id text NOT NULL,
    "transactionId" text NOT NULL,
    "productId" text,
    "lineNumber" integer NOT NULL,
    "productName" text NOT NULL,
    sku text,
    barcode text,
    description text,
    category text,
    quantity numeric(12,3) DEFAULT 1 NOT NULL,
    "unitPrice" numeric(12,2) NOT NULL,
    "originalPrice" numeric(12,2),
    "discountAmount" numeric(12,2) DEFAULT 0 NOT NULL,
    "discountPercent" numeric(5,2),
    "taxRate" numeric(5,2) DEFAULT 0 NOT NULL,
    "taxAmount" numeric(12,2) DEFAULT 0 NOT NULL,
    subtotal numeric(12,2) NOT NULL,
    "totalAmount" numeric(12,2) NOT NULL,
    notes text,
    metadata jsonb,
    "isRefunded" boolean DEFAULT false NOT NULL,
    "refundedQuantity" numeric(12,3) DEFAULT 0,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."POSTransactionItem" OWNER TO postgres;

--
-- Name: POSTransactionTax; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."POSTransactionTax" (
    id text NOT NULL,
    "transactionId" text NOT NULL,
    "taxName" text NOT NULL,
    "taxRate" numeric(5,2) NOT NULL,
    "taxableAmount" numeric(12,2) NOT NULL,
    "taxAmount" numeric(12,2) NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."POSTransactionTax" OWNER TO postgres;

--
-- Name: PayType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."PayType" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "payTypeId" integer,
    "payTypeName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."PayType" OWNER TO postgres;

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
    "branchId" text,
    "retinoscopyDist" text,
    "retinoscopyNotes" text,
    "retinoscopyType" text
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
-- Name: PrintLabel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."PrintLabel" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "labelId" integer,
    "labelName" text,
    "margRight" numeric(65,30),
    "margLeft" numeric(65,30),
    "labelWidth" numeric(65,30),
    "labelHeight" numeric(65,30),
    "horSpace" numeric(65,30),
    "verSpace" numeric(65,30),
    "margTop" numeric(65,30),
    "margBot" numeric(65,30),
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."PrintLabel" OWNER TO postgres;

--
-- Name: PrlType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."PrlType" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "prlType" integer,
    "prlName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."PrlType" OWNER TO postgres;

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
-- Name: ProductProperty; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ProductProperty" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "propId" integer,
    "propName" text,
    "sapakID" integer,
    price numeric(65,30),
    "pubPrice" numeric(65,30),
    "recPrice" numeric(65,30),
    "privPrice" numeric(65,30),
    active integer,
    quantity integer,
    "invMovePropId" integer,
    "invMovePropName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ProductProperty" OWNER TO postgres;

--
-- Name: ProductReview; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ProductReview" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "userId" text NOT NULL,
    "userName" text,
    "itemType" text NOT NULL,
    "itemId" text NOT NULL,
    "collectionId" text,
    "supplierId" text NOT NULL,
    rating integer NOT NULL,
    title text NOT NULL,
    comment text NOT NULL,
    images text[],
    verified boolean DEFAULT false NOT NULL,
    "orderReference" text,
    "helpfulCount" integer DEFAULT 0 NOT NULL,
    "notHelpfulCount" integer DEFAULT 0 NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    "moderatedBy" text,
    "moderatedAt" timestamp(3) without time zone,
    "supplierResponse" text,
    "supplierResponseBy" text,
    "supplierResponseAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "deletedAt" timestamp(3) without time zone
);


ALTER TABLE public."ProductReview" OWNER TO postgres;

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
-- Name: Profile; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Profile" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "profileId" integer,
    "profileName" text,
    "profileSql" text,
    "profileDesc" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Profile" OWNER TO postgres;

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
    "tenantId" text NOT NULL,
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
    "tenantId" text NOT NULL,
    "purchaseId" text NOT NULL,
    "paymentDate" timestamp(3) without time zone NOT NULL,
    amount double precision NOT NULL,
    "paymentMethod" text NOT NULL,
    reference text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."PurchasePayment" OWNER TO postgres;

--
-- Name: ReferralSource; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ReferralSource" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "refsSub2Id" integer,
    "refsSub2Name" text,
    "subRefId" integer,
    "refsSub1Id" integer,
    "refsSub1Name" text,
    "refId" integer,
    "refName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ReferralSource" OWNER TO postgres;

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
-- Name: ReviewHelpful; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ReviewHelpful" (
    id text NOT NULL,
    "reviewId" text NOT NULL,
    "userId" text NOT NULL,
    helpful boolean NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."ReviewHelpful" OWNER TO postgres;

--
-- Name: ReviewReport; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ReviewReport" (
    id text NOT NULL,
    "reviewId" text NOT NULL,
    "reportedBy" text NOT NULL,
    reason text NOT NULL,
    details text,
    status text DEFAULT 'PENDING'::text NOT NULL,
    "reviewedBy" text,
    "reviewedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."ReviewReport" OWNER TO postgres;

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
-- Name: SMSLen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SMSLen" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "sMSProviderPrefix" text,
    "sMSLang" text,
    "sMSProviderName" text,
    "sMSLen" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SMSLen" OWNER TO postgres;

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
    "cashierShiftId" text,
    "groupReference" text,
    "invoiceType" text DEFAULT 'NORMAL'::text,
    "receiptDate" timestamp(3) without time zone,
    "receiptNumber" text,
    "sourceReference" text
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
    "barcodeId" text,
    "tenantId" text NOT NULL
);


ALTER TABLE public."SaleItem" OWNER TO postgres;

--
-- Name: SapakComment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SapakComment" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "sapakId" integer,
    "prlType" integer,
    comments text,
    "prlSp" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SapakComment" OWNER TO postgres;

--
-- Name: SapakDest; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SapakDest" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "sapakDestId" integer,
    "sapakDestName" text,
    "sapakId" integer,
    fax1 text,
    fax2 text,
    email1 text,
    email2 text,
    "clientId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SapakDest" OWNER TO postgres;

--
-- Name: SapakPerComment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SapakPerComment" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "sapakId" integer,
    "prlType" integer,
    comments text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SapakPerComment" OWNER TO postgres;

--
-- Name: SearchOrder; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SearchOrder" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "itemData" integer,
    "listIndex" integer,
    "desc" text,
    deaf integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SearchOrder" OWNER TO postgres;

--
-- Name: ServiceType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ServiceType" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "serviceId" integer,
    "serviceName" text,
    "servicePrice" numeric(65,30),
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ServiceType" OWNER TO postgres;

--
-- Name: ShortCut; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ShortCut" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "prKey" integer,
    "shKey" text,
    "desc" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ShortCut" OWNER TO postgres;

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
-- Name: Special; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Special" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "sapakID" integer,
    "specialId" integer,
    "prlType" integer,
    priority integer,
    price numeric(65,30),
    "pubPrice" numeric(65,30),
    "recPrice" numeric(65,30),
    "privPrice" numeric(65,30),
    formula text,
    data text,
    "rLOnly" integer,
    active integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Special" OWNER TO postgres;

--
-- Name: SpecialName; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SpecialName" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "specialId" integer,
    "specialName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SpecialName" OWNER TO postgres;

--
-- Name: StaffSchedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."StaffSchedule" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "userId" text NOT NULL,
    "workDate" timestamp(3) without time zone NOT NULL,
    "scheduleType" text NOT NULL,
    "startTime" timestamp(3) without time zone,
    "endTime" timestamp(3) without time zone,
    notes text,
    "createdBy" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."StaffSchedule" OWNER TO postgres;

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
    "branchId" text,
    "exCatNum" integer,
    "invoiceId" text,
    "movementPropertyId" text,
    "movementTypeId" text,
    "salePrice" double precision,
    "totalCost" double precision,
    "totalSale" double precision
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
-- Name: SupplierAccountTransaction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierAccountTransaction" (
    id text NOT NULL,
    "accountId" text NOT NULL,
    type text NOT NULL,
    amount numeric(12,2) NOT NULL,
    "orderId" text,
    "invoiceId" text,
    "paymentId" text,
    "balanceBefore" numeric(12,2) NOT NULL,
    "balanceAfter" numeric(12,2) NOT NULL,
    description text,
    notes text,
    "referenceNumber" text,
    "paymentMethod" text,
    "transactionDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "createdBy" text
);


ALTER TABLE public."SupplierAccountTransaction" OWNER TO postgres;

--
-- Name: SupplierAnalytics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierAnalytics" (
    id text NOT NULL,
    "supplierId" text NOT NULL,
    "periodType" text NOT NULL,
    "periodStart" timestamp(3) without time zone NOT NULL,
    "periodEnd" timestamp(3) without time zone NOT NULL,
    "totalOrders" integer NOT NULL,
    "totalRevenue" numeric(12,2) NOT NULL,
    "totalUnits" integer NOT NULL,
    "averageOrderValue" numeric(10,2) NOT NULL,
    "topSellingItemId" text,
    "topSellingItemUnits" integer,
    "lowStockItems" integer NOT NULL,
    "outOfStockItems" integer NOT NULL,
    "activeTenants" integer NOT NULL,
    "newTenants" integer NOT NULL,
    "topTenantId" text,
    "topTenantRevenue" numeric(12,2),
    "rfqsReceived" integer NOT NULL,
    "rfqsQuoted" integer NOT NULL,
    "rfqsConverted" integer NOT NULL,
    "conversionRate" numeric(5,2),
    "inventoryValue" numeric(12,2) NOT NULL,
    "inventoryTurnover" numeric(5,2),
    "grossProfit" numeric(12,2),
    "profitMargin" numeric(5,2),
    "calculatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."SupplierAnalytics" OWNER TO postgres;

--
-- Name: SupplierCatalogCategory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierCatalogCategory" (
    id text NOT NULL,
    "supplierId" text NOT NULL,
    name text NOT NULL,
    "nameHe" text,
    description text,
    "parentId" text,
    "displayOrder" integer DEFAULT 0 NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "imageUrl" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SupplierCatalogCategory" OWNER TO postgres;

--
-- Name: SupplierCatalogItem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierCatalogItem" (
    id text NOT NULL,
    "supplierId" text NOT NULL,
    "categoryId" text,
    sku text NOT NULL,
    name text NOT NULL,
    "nameHe" text,
    description text,
    "descriptionHe" text,
    type text NOT NULL,
    brand text,
    model text,
    material text,
    shape text,
    color text,
    "eyeSize" integer,
    "bridgeSize" integer,
    "templeLength" integer,
    gender text,
    "lensType" text,
    material_lens text,
    coating text,
    "indexValue" numeric(3,2),
    "basePrice" numeric(10,2) NOT NULL,
    cost numeric(10,2),
    msrp numeric(10,2),
    currency text DEFAULT 'ILS'::text NOT NULL,
    "stockQuantity" integer DEFAULT 0 NOT NULL,
    "lowStockAlert" integer DEFAULT 10 NOT NULL,
    "inStock" boolean DEFAULT true NOT NULL,
    "backorderAllowed" boolean DEFAULT false NOT NULL,
    "leadTimeDays" integer DEFAULT 7 NOT NULL,
    images text[],
    "primaryImage" text,
    "catalogPdf" text,
    "isActive" boolean DEFAULT true NOT NULL,
    "isFeatured" boolean DEFAULT false NOT NULL,
    "isNewArrival" boolean DEFAULT false NOT NULL,
    "publishedAt" timestamp(3) without time zone,
    barcode text,
    upc text,
    weight numeric(8,2),
    dimensions jsonb,
    tags text[],
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SupplierCatalogItem" OWNER TO postgres;

--
-- Name: SupplierCatalogVariant; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierCatalogVariant" (
    id text NOT NULL,
    "itemId" text NOT NULL,
    name text NOT NULL,
    sku text NOT NULL,
    "variantType" text NOT NULL,
    attributes jsonb NOT NULL,
    "priceModifier" numeric(10,2),
    price numeric(10,2),
    "stockQuantity" integer DEFAULT 0 NOT NULL,
    "isAvailable" boolean DEFAULT true NOT NULL,
    images text[],
    "primaryImage" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SupplierCatalogVariant" OWNER TO postgres;

--
-- Name: SupplierCollection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierCollection" (
    id text NOT NULL,
    "supplierId" text NOT NULL,
    name text NOT NULL,
    season text,
    description text,
    "coverImage" text,
    published boolean DEFAULT false NOT NULL,
    "tenantScope" text DEFAULT 'SELECTIVE'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SupplierCollection" OWNER TO postgres;

--
-- Name: SupplierCollectionVisibility; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierCollectionVisibility" (
    id text NOT NULL,
    "collectionId" text NOT NULL,
    "tenantId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."SupplierCollectionVisibility" OWNER TO postgres;

--
-- Name: SupplierDiscount; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierDiscount" (
    id text NOT NULL,
    "supplierId" text NOT NULL,
    name text NOT NULL,
    "nameHe" text,
    description text,
    code text,
    type text NOT NULL,
    value numeric(10,2) NOT NULL,
    tiers jsonb,
    "applyToAll" boolean DEFAULT false NOT NULL,
    "itemIds" text[],
    "categoryIds" text[],
    "tenantScope" text DEFAULT 'ALL'::text NOT NULL,
    "tenantIds" text[],
    "minPurchaseAmount" numeric(10,2),
    "minQuantity" integer,
    "maxUsesPerTenant" integer,
    "maxTotalUses" integer,
    "currentUses" integer DEFAULT 0 NOT NULL,
    "startDate" timestamp(3) without time zone NOT NULL,
    "endDate" timestamp(3) without time zone,
    "isActive" boolean DEFAULT true NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    stackable boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SupplierDiscount" OWNER TO postgres;

--
-- Name: SupplierDiscountUsage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierDiscountUsage" (
    id text NOT NULL,
    "discountId" text NOT NULL,
    "tenantId" text NOT NULL,
    "orderId" text,
    "discountAmount" numeric(10,2) NOT NULL,
    "orderAmount" numeric(10,2) NOT NULL,
    "itemCount" integer NOT NULL,
    "usedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."SupplierDiscountUsage" OWNER TO postgres;

--
-- Name: SupplierInventoryLog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierInventoryLog" (
    id text NOT NULL,
    "itemId" text NOT NULL,
    type text NOT NULL,
    quantity integer NOT NULL,
    "quantityBefore" integer NOT NULL,
    "quantityAfter" integer NOT NULL,
    "orderId" text,
    "rfqId" text,
    reason text,
    notes text,
    "locationCode" text,
    "batchNumber" text,
    "expiryDate" timestamp(3) without time zone,
    cost numeric(10,2),
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "createdBy" text
);


ALTER TABLE public."SupplierInventoryLog" OWNER TO postgres;

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
    subtotal double precision DEFAULT 0 NOT NULL,
    "accountId" text
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
-- Name: SupplierPriceAlert; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierPriceAlert" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "userId" text,
    "frameCatalogId" text,
    "lensCatalogId" text,
    "itemType" text NOT NULL,
    "alertType" text NOT NULL,
    "targetPrice" numeric(10,2),
    "percentChange" integer,
    "isActive" boolean DEFAULT true NOT NULL,
    "notifyEmail" text,
    "notifyInApp" boolean DEFAULT true NOT NULL,
    "lastTriggered" timestamp(3) without time zone,
    "triggerCount" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SupplierPriceAlert" OWNER TO postgres;

--
-- Name: SupplierPriceCache; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierPriceCache" (
    id text NOT NULL,
    "frameCatalogId" text,
    "lensCatalogId" text,
    "itemType" text NOT NULL,
    "lowestPrice" numeric(10,2) NOT NULL,
    "lowestSupplierId" text NOT NULL,
    "highestPrice" numeric(10,2) NOT NULL,
    "averagePrice" numeric(10,2) NOT NULL,
    "supplierCount" integer NOT NULL,
    "priceRange" jsonb NOT NULL,
    "supplierPrices" jsonb NOT NULL,
    "lastCalculated" timestamp(3) without time zone NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SupplierPriceCache" OWNER TO postgres;

--
-- Name: SupplierPriceHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierPriceHistory" (
    id text NOT NULL,
    "supplierId" text NOT NULL,
    "frameCatalogId" text,
    "lensCatalogId" text,
    "itemType" text NOT NULL,
    price numeric(10,2) NOT NULL,
    currency text DEFAULT 'ILS'::text NOT NULL,
    "minQuantity" integer DEFAULT 1 NOT NULL,
    "maxQuantity" integer,
    "validFrom" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "validTo" timestamp(3) without time zone,
    "isActive" boolean DEFAULT true NOT NULL,
    "priceType" text DEFAULT 'REGULAR'::text NOT NULL,
    notes text,
    source text DEFAULT 'MANUAL'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "createdBy" text
);


ALTER TABLE public."SupplierPriceHistory" OWNER TO postgres;

--
-- Name: SupplierPriceList; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierPriceList" (
    id text NOT NULL,
    "supplierId" text NOT NULL,
    name text NOT NULL,
    "nameHe" text,
    description text,
    type text NOT NULL,
    "startDate" timestamp(3) without time zone NOT NULL,
    "endDate" timestamp(3) without time zone,
    "isActive" boolean DEFAULT true NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    "tenantIds" text[],
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SupplierPriceList" OWNER TO postgres;

--
-- Name: SupplierPriceListItem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierPriceListItem" (
    id text NOT NULL,
    "priceListId" text NOT NULL,
    "itemId" text NOT NULL,
    price numeric(10,2) NOT NULL,
    "volumePricing" jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SupplierPriceListItem" OWNER TO postgres;

--
-- Name: SupplierRFQ; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierRFQ" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "supplierId" text NOT NULL,
    status text DEFAULT 'OPEN'::text NOT NULL,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SupplierRFQ" OWNER TO postgres;

--
-- Name: SupplierRFQItem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierRFQItem" (
    id text NOT NULL,
    "rfqId" text NOT NULL,
    type text NOT NULL,
    "frameCatalogId" text,
    "lensCatalogId" text,
    quantity integer NOT NULL,
    "targetPrice" numeric(10,2)
);


ALTER TABLE public."SupplierRFQItem" OWNER TO postgres;

--
-- Name: SupplierShipment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierShipment" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "sapakSendId" integer,
    "perId" integer,
    "glassPId" integer,
    "workId" integer,
    "clensId" integer,
    "sapakDestId" integer,
    "userId" integer,
    "sendTime" timestamp(3) without time zone,
    recived integer,
    "privPrice" numeric(65,30),
    "shipmentId" text,
    "shipmentDate" timestamp(3) without time zone,
    sent integer,
    com text,
    "spsStatId" integer,
    "spsType" integer,
    "spsSendType" integer,
    "faxId" integer,
    "shFrame" integer,
    "shLab" integer,
    "treatBlock" integer,
    "treatWSec" integer,
    "treatWScrew" integer,
    "treatWNylon" integer,
    "treatWKnife" integer,
    "lensColor" text,
    "lensLevel" text,
    "eyeWidth" numeric(65,30),
    "eyeHeight" numeric(65,30),
    "bridgeWidth" numeric(65,30),
    "centerHeightR" numeric(65,30),
    "centerHeightL" numeric(65,30),
    "segHeightR" numeric(65,30),
    "segHeightL" numeric(65,30),
    "picNum" text,
    "pCom" text,
    basis integer,
    pent numeric(65,30),
    "vD" numeric(65,30),
    "spsStatName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SupplierShipment" OWNER TO postgres;

--
-- Name: SupplierStockAlert; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierStockAlert" (
    id text NOT NULL,
    "supplierId" text NOT NULL,
    "itemId" text NOT NULL,
    type text NOT NULL,
    severity text NOT NULL,
    message text NOT NULL,
    "currentStock" integer NOT NULL,
    "thresholdValue" integer NOT NULL,
    "isRead" boolean DEFAULT false NOT NULL,
    "isResolved" boolean DEFAULT false NOT NULL,
    "resolvedAt" timestamp(3) without time zone,
    "resolvedBy" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."SupplierStockAlert" OWNER TO postgres;

--
-- Name: SupplierTenantAccount; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierTenantAccount" (
    id text NOT NULL,
    "supplierId" text NOT NULL,
    "tenantId" text NOT NULL,
    "accountNumber" text NOT NULL,
    "accountStatus" text DEFAULT 'ACTIVE'::text NOT NULL,
    "creditLimit" numeric(12,2),
    "currentBalance" numeric(12,2) DEFAULT 0 NOT NULL,
    "availableCredit" numeric(12,2) DEFAULT 0 NOT NULL,
    "paymentTerms" text DEFAULT 'NET_30'::text NOT NULL,
    "paymentTermsDays" integer DEFAULT 30 NOT NULL,
    "defaultDiscount" numeric(5,2),
    "priceListId" text,
    "totalOrders" integer DEFAULT 0 NOT NULL,
    "totalRevenue" numeric(12,2) DEFAULT 0 NOT NULL,
    "averageOrderValue" numeric(10,2) DEFAULT 0 NOT NULL,
    "lastOrderDate" timestamp(3) without time zone,
    "firstOrderDate" timestamp(3) without time zone,
    "billingContactName" text,
    "billingEmail" text,
    "billingPhone" text,
    "shippingAddress" jsonb,
    "billingAddress" jsonb,
    "allowBackorders" boolean DEFAULT false NOT NULL,
    "requirePO" boolean DEFAULT false NOT NULL,
    "autoApproveOrders" boolean DEFAULT true NOT NULL,
    "internalNotes" text,
    "creditHold" boolean DEFAULT false NOT NULL,
    "creditHoldReason" text,
    "accountManager" text,
    rating integer,
    tags text[],
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "lastActivityAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."SupplierTenantAccount" OWNER TO postgres;

--
-- Name: SupplierTenantActivity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierTenantActivity" (
    id text NOT NULL,
    "supplierId" text NOT NULL,
    "tenantId" text NOT NULL,
    type text NOT NULL,
    description text NOT NULL,
    "referenceId" text,
    "referenceType" text,
    metadata jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."SupplierTenantActivity" OWNER TO postgres;

--
-- Name: SupplierTenantNote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierTenantNote" (
    id text NOT NULL,
    "supplierId" text NOT NULL,
    "tenantId" text NOT NULL,
    title text,
    content text NOT NULL,
    type text NOT NULL,
    status text DEFAULT 'OPEN'::text,
    priority text,
    "dueDate" timestamp(3) without time zone,
    attachments text[],
    "isPrivate" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "createdBy" text NOT NULL
);


ALTER TABLE public."SupplierTenantNote" OWNER TO postgres;

--
-- Name: SupplierUser; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SupplierUser" (
    id text NOT NULL,
    "supplierId" text NOT NULL,
    email text NOT NULL,
    "passwordHash" text NOT NULL,
    role text DEFAULT 'SUPPLIER'::text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SupplierUser" OWNER TO postgres;

--
-- Name: SysLevel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SysLevel" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text,
    "levelId" integer,
    "levelName" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SysLevel" OWNER TO postgres;

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
    "tenantId" text NOT NULL,
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
    "tenantId" text NOT NULL,
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
    "tenantId" text NOT NULL,
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
-- Name: VATRate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."VATRate" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "effectiveFrom" timestamp(3) without time zone NOT NULL,
    "effectiveTo" timestamp(3) without time zone,
    rate double precision NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."VATRate" OWNER TO postgres;

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
-- Name: Wishlist; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Wishlist" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "userId" text NOT NULL,
    name text DEFAULT 'My Wishlist'::text NOT NULL,
    description text,
    "isDefault" boolean DEFAULT false NOT NULL,
    "isPublic" boolean DEFAULT false NOT NULL,
    "shareToken" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Wishlist" OWNER TO postgres;

--
-- Name: WishlistItem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."WishlistItem" (
    id text NOT NULL,
    "wishlistId" text NOT NULL,
    "itemType" text NOT NULL,
    "itemId" text NOT NULL,
    "collectionId" text,
    "supplierId" text NOT NULL,
    "productName" text,
    "productBrand" text,
    "productPrice" double precision,
    "productImage" text,
    "notifyOnSale" boolean DEFAULT false NOT NULL,
    "notifyOnStock" boolean DEFAULT false NOT NULL,
    notes text,
    priority integer DEFAULT 0 NOT NULL,
    "addedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."WishlistItem" OWNER TO postgres;

--
-- Name: WishlistShare; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."WishlistShare" (
    id text NOT NULL,
    "wishlistId" text NOT NULL,
    "sharedWith" text,
    "sharedBy" text NOT NULL,
    "accessLevel" text DEFAULT 'VIEW'::text NOT NULL,
    "viewCount" integer DEFAULT 0 NOT NULL,
    "lastViewedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "expiresAt" timestamp(3) without time zone
);


ALTER TABLE public."WishlistShare" OWNER TO postgres;

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
    "tenantId" text NOT NULL,
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
-- Name: _DiscountToItems; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."_DiscountToItems" (
    "A" text NOT NULL,
    "B" text NOT NULL
);


ALTER TABLE public."_DiscountToItems" OWNER TO postgres;

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
-- Data for Name: AISuggestion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."AISuggestion" (id, "tenantId", "examinationId", "suggestionType", suggestion, reasoning, confidence, accepted, "acceptedAt", "rejectedReason", "modifiedSuggestion", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: AddressLookup; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."AddressLookup" (id, "tenantId", "branchId", "cityCode", "streetCode", "startingHouseNumber", "endingHouseNumber", "streetZipcode", "streetName", "alternateStreetName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: AdvancedExamination; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."AdvancedExamination" (id, "tenantId", "branchId", "customerId", "examinationId", "examDate", "examinerId", "autorefSphereOD", "autorefCylinderOD", "autorefAxisOD", "autorefSphereOS", "autorefCylinderOS", "autorefAxisOS", "autorefConfidence", "keratometryK1OD", "keratometryK1AxisOD", "keratometryK2OD", "keratometryK2AxisOD", "keratometryK1OS", "keratometryK1AxisOS", "keratometryK2OS", "keratometryK2AxisOS", "keratometryAvgOD", "keratometryAvgOS", "keratometryType", "retinoscopySphereOD", "retinoscopyCylinderOD", "retinoscopyAxisOD", "retinoscopySphereOS", "retinoscopyCylinderOS", "retinoscopyAxisOS", "retinoscopyMethod", "subjSphereOD", "subjCylinderOD", "subjAxisOD", "subjSphereOS", "subjCylinderOS", "subjAxisOS", "subjVAOD", "subjVAOS", "subjVAOU", "nearAddOD", "nearAddOS", "nearVAOD", "nearVAOS", "nearVAOU", "nearWorkingDistance", "coverTestDistance", "coverTestNear", "npcBreak", "npcRecovery", stereopsis, "worthFourDot", "maddoxRodH", "maddoxRodV", "accommodativeAmpOD", "accommodativeAmpOS", "accommodativeFacility", "vergenceNBI", "vergenceNBO", "vergencePBI", "vergencePBO", "pupilSizeOD", "pupilSizeOS", "pupilReactionOD", "pupilReactionOS", "pupilShape", "iopOD", "iopOS", "iopTime", "iopMethod", "cctOD", "cctOS", "colorVisionTest", "colorVisionResult", "colorVisionDetails", "visualFieldOD", "visualFieldOS", "visualFieldMethod", "visualFieldNotes", "lidsOD", "lidsOS", "conjunctivaOD", "conjunctivaOS", "corneaOD", "corneaOS", "anteriorChamberOD", "anteriorChamberOS", "irisOD", "irisOS", "lensOD", "lensOS", "lensOpacityOD", "lensOpacityOS", "vitreousOD", "vitreousOS", "discOD", "discOS", "cdRatioOD", "cdRatioOS", "maculaOD", "maculaOS", "vesselsOD", "vesselsOS", "peripheryOD", "peripheryOS", "tearBreakUpTimeOD", "tearBreakUpTimeOS", "schirmerTestOD", "schirmerTestOS", "primaryDiagnosis", "secondaryDiagnosis", "assessmentNotes", "treatmentPlan", "followUpPeriod", "referralNeeded", "referralTo", "referralReason", "isComplete", "completedAt", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ApplicationSetting; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ApplicationSetting" (id, "tenantId", "branchId", "setId", "setVal", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Appointment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Appointment" (id, "tenantId", "customerId", "userId", date, duration, type, status, notes, "reminderSent", "createdAt", "updatedAt", "branchId", "SMSSent", "TookPlace") FROM stdin;
\.


--
-- Data for Name: AuditLog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."AuditLog" (id, "tenantId", "userId", action, resource, "resourceId", details, "oldValues", "newValues", "ipAddress", "userAgent", metadata, "createdAt") FROM stdin;
\.


--
-- Data for Name: BarcodeManagement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."BarcodeManagement" (id, "tenantId", "productId", barcode, "barcodeType", "isActive", "createdAt", "updatedAt", "branchId") FROM stdin;
\.


--
-- Data for Name: Base; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Base" (id, "tenantId", "branchId", "baseId", "baseName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: BisData; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."BisData" (id, "tenantId", "branchId", "bisId", "bisNum", "bisName", phone, fax, email, address, "zipCode", "creditMode", "creditDays", "creditFactor", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Branch; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Branch" (id, "tenantId", name, "nameHe", code, "isMain", address, city, "zipCode", phone, fax, email, active, "managerId", "operatingHours", "shareInventory", "shareCustomers", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Brand; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Brand" (id, "tenantId", name, type, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: BusinessContact; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."BusinessContact" (id, "tenantId", "branchId", "cntID", "lastName", "firstName", "workPhone", "homePhone", "cellPhone", fax, address, "zipCode", "cityID", "eMail", "webSite", comment, "hidCom", "isSapak", "creditCon", "remDate", "sapakID", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CashDrawerEvent; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CashDrawerEvent" (id, "tenantId", "branchId", "userId", "shiftId", "eventType", reason, amount, "timestamp") FROM stdin;
\.


--
-- Data for Name: CashReconciliation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CashReconciliation" (id, "tenantId", "shiftId", "reconciliationType", "performedBy", "performedAt", "expectedAmount", "totalCounted", difference, bills1, bills5, bills10, bills20, bills50, bills100, bills200, coins010, coins050, coins1, coins2, coins5, coins10, notes, "createdAt") FROM stdin;
\.


--
-- Data for Name: CashierShift; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CashierShift" (id, "tenantId", "branchId", "userId", "shiftNumber", "startTime", "endTime", status, "openingCash", "closingCash", "expectedCash", "actualCash", "cashDifference", "totalSales", "totalCashPayments", "totalCardPayments", "totalOtherPayments", notes, "terminalId", "closedBy", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ChatChannel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ChatChannel" (id, "tenantId", "roomId", name, "displayName", type, description, "isActive", "isArchived", "archivedAt", "archivedBy", "visitId", "patientId", settings, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ChatChannelMember; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ChatChannelMember" (id, "tenantId", "channelId", "userId", "userType", role, permissions, "muteNotifications", "mutedUntil", "lastSeenAt", "unreadCount", "joinedAt", "leftAt") FROM stdin;
\.


--
-- Data for Name: ChatMessage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ChatMessage" (id, "tenantId", "channelId", "senderId", "senderType", "senderName", content, "messageType", "structuredData", attachments, "readAt", "readBy", "pinnedAt", "pinnedBy", reactions, "replyToId", "threadId", "quickActions", metadata, "createdAt", "updatedAt", "deletedAt") FROM stdin;
\.


--
-- Data for Name: ChatMessageTemplate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ChatMessageTemplate" (id, "tenantId", name, content, type, category, variables, "quickActions", "isActive", "isSystem", "usageCount", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ChatNotification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ChatNotification" (id, "tenantId", "userId", "channelId", "messageId", type, title, content, data, "isRead", "readAt", "createdAt") FROM stdin;
\.


--
-- Data for Name: ChatRoom; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ChatRoom" (id, "tenantId", "branchId", name, "displayName", type, description, "isActive", settings, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ChatRoomMember; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ChatRoomMember" (id, "tenantId", "roomId", "userId", "userType", role, permissions, "joinedAt", "leftAt") FROM stdin;
\.


--
-- Data for Name: ChatSearch; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ChatSearch" (id, "tenantId", "userId", query, filters, results, "createdAt") FROM stdin;
\.


--
-- Data for Name: ChatTyping; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ChatTyping" (id, "tenantId", "channelId", "userId", "userType", "userName", "startedAt") FROM stdin;
\.


--
-- Data for Name: CheckType; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CheckType" (id, "tenantId", "checkId", name, price, description, "isActive", "createdAt", "updatedAt", "branchId") FROM stdin;
\.


--
-- Data for Name: City; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."City" (id, "tenantId", "cityId", name, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ClinicalData; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ClinicalData" (id, "tenantId", "branchId", "eyeCheckCharId", "eyeCheckCharName", "eyeCheckCharType", "clinicCheckId", "perId", "userId", "checkDate", "reCheckDate", "glassCheckDate", "yN1", "yN2", "yN3", "yN4", "yN5", "yN6", "yN7", "yN8", "yN9", "yN10", "yN11", "yN12", "yN13", "yN14", "yN15", "yN16", "yN17", "yN18", "yN19", "yN20", "yN21", "yN22", "yN23", "yN24", "yN25", "yN26", "yN27", "yN28", "yN29", "yN30", "yN31", "yN32", "yN33", "yN34", "yN35", "yN36", "yN37", "yN38", "yN39", "yN40", "yN41", "yN42", "yN43", "yN44", "yN45", "yN46", "yN47", "yN48", "yN49", "yN50", "yN51", "yN52", "yN53", "yN54", "yN55", "yN56", "yN57", "yN58", meds, "medsEye", "prevTreat", com, other1, other2, other3, other4, "eyeLidR", "eyeLidL", "tearWayR", "tearWayL", "choroidR", "choroidL", "limitR", "limitL", "cornR", "cornL", "chamberR", "chamberL", "angleR", "angleL", "iOPR", "iOPL", "irisR", "irisL", "pupilR", "pupilL", "lensR", "lensL", "enamelR", "enamelL", "diskR", "diskL", "cDAVR", "cDAVL", "maculaR", "maculaL", "perimeterR", "perimeterL", "amslaR", "amslaL", "vFieldR", "vFieldL", pic3, pic4, "cSR", "cSL", "fldId", "fldName", "fVal", "iCount", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ClinicalDiagnosis; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ClinicalDiagnosis" (id, "tenantId", "branchId", "customerId", "checkDate", "examinerId", complaints, illnesses, "optometricDiagnosis", "doctorReferral", summary, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ClinicalExamination; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ClinicalExamination" (id, "tenantId", "customerId", "examinerId", "examDate", "recheckDate", symptom1, symptom2, symptom3, symptom4, symptom5, symptom6, symptom7, symptom8, symptom9, symptom10, symptom11, symptom12, symptom13, symptom14, symptom15, symptom16, symptom17, symptom18, symptom19, symptom20, symptom21, symptom22, symptom23, symptom24, symptom25, symptom26, symptom27, symptom28, symptom29, symptom30, symptom31, symptom32, symptom33, symptom34, symptom35, symptom36, symptom37, symptom38, symptom39, symptom40, symptom41, symptom42, symptom43, symptom44, symptom45, symptom46, symptom47, symptom48, symptom49, symptom50, symptom51, symptom52, symptom53, symptom54, symptom55, symptom56, symptom57, symptom58, medications, "eyeMedications", "previousTreatment", comments, "eyeLidRight", "eyeLidLeft", "tearDuctRight", "tearDuctLeft", "corneaRight", "corneaLeft", "irisRight", "irisLeft", "lensRight", "lensLeft", "createdAt", "updatedAt", "branchId", "choroidLeft", "choroidRight", "limitLeft", "limitRight", "perimeterLeft", "perimeterRight") FROM stdin;
\.


--
-- Data for Name: ClinicalImage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ClinicalImage" (id, "tenantId", "examinationId", "customerId", "imageType", eye, "imageUrl", "thumbnailUrl", "fileName", "fileSize", "mimeType", width, height, "captureDate", "captureDevice", annotations, metadata, notes, tags, diagnosis, findings, "aiAnalysis", "aiConfidence", "uploadedBy", "isPrivate", "createdAt", "updatedAt", "deletedAt") FROM stdin;
\.


--
-- Data for Name: ClinicalProtocol; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ClinicalProtocol" (id, "tenantId", name, "nameHe", description, "protocolType", "triggerConditions", "recommendedTests", "mandatoryFields", "followUpRules", "referralRules", "isActive", priority, "createdBy", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ClinicalReferral; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ClinicalReferral" (id, "tenantId", "customerId", "examinationId", "referralType", specialty, reason, "reasonHe", urgency, "specialistName", "specialistPhone", "specialistEmail", "clinicName", "referralDate", "letterSent", "letterSentAt", "appointmentDate", "appointmentConfirmed", status, "resultsReceived", "resultsDate", "resultsSummary", "referralLetter", "resultsDocument", notes, "createdBy", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ClinicalRule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ClinicalRule" (id, "tenantId", "ruleName", "ruleNameHe", description, "ruleType", "triggerConditions", action, priority, "isActive", "autoExecute", "createdBy", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ClinicalRuleTrigger; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ClinicalRuleTrigger" (id, "ruleId", "tenantId", "examinationId", "customerId", "triggeredAt", "triggeredBy", "conditionsMet", "actionTaken", status, "resultMessage", "completedAt") FROM stdin;
\.


--
-- Data for Name: ClndrSal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ClndrSal" (id, "tenantId", "branchId", "userID", month, salery, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ClndrTasksPriority; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ClndrTasksPriority" (id, "tenantId", "branchId", "priorityId", "priorityName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ClndrWrk; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ClndrWrk" (id, "tenantId", "branchId", "wrkId", "userID", "wrkDate", "wrkTime", "startTime", "endTime", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CollectionItem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CollectionItem" (id, "collectionId", type, "frameCatalogId", "lensCatalogId", "supplierCode", "priceOverride", stock, description, "isPublished", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Commission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Commission" (id, "tenantId", "branchId", "employeeId", "saleId", "examinationId", "ruleId", "baseAmount", "commissionRate", "commissionAmount", period, "periodStart", "periodEnd", status, "paidAmount", "paidAt", "paymentRef", notes, "approvedBy", "approvedAt", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CommissionRule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CommissionRule" (id, "tenantId", "branchId", name, description, "isActive", "ruleType", percentage, "fixedAmount", tiers, "categoryFilter", "brandFilter", "minimumSaleAmount", "validFrom", "validUntil", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CommunicationCampaign; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CommunicationCampaign" (id, "tenantId", "branchId", name, description, type, status, "targetType", "targetFilter", "targetCustomers", "templateId", subject, content, "scheduledAt", "sendAt", "completedAt", "totalRecipients", "sentCount", "deliveredCount", "failedCount", "openedCount", "clickedCount", "unsubscribedCount", "estimatedCost", "actualCost", "respectOptOut", "testMode", priority, "createdBy", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CommunicationLog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CommunicationLog" (id, "tenantId", "customerId", "recipientEmail", "recipientPhone", "recipientName", type, template, subject, content, status, "sentAt", "deliveredAt", "failedAt", error, provider, "providerMessageId", cost, context, "contextId", "createdAt", "updatedAt", "branchId", "campaignId") FROM stdin;
\.


--
-- Data for Name: CommunicationSchedule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CommunicationSchedule" (id, "tenantId", name, description, active, "scheduleType", "triggerType", "triggerDays", "triggerTime", "recurrencePattern", "recurrenceDays", "templateId", "customerFilter", "respectOptOut", "includeInactive", "maxSendsPerDay", "lastRunAt", "nextRunAt", "totalSent", "totalFailed", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ContactAgent; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ContactAgent" (id, "tenantId", "customerId", "agentType", relationship, "firstName", "lastName", phone, email, address, city, "policyNumber", "groupNumber", "isPrimary", "isActive", notes, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ContactLensBrand; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ContactLensBrand" (id, "tenantId", "brandId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ContactLensCleaningSolution; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ContactLensCleaningSolution" (id, "tenantId", "solutionId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ContactLensDisinfectingSolution; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ContactLensDisinfectingSolution" (id, "tenantId", "solutionId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ContactLensExamination; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ContactLensExamination" (id, "tenantId", "branchId", "customerId", "checkDate", "reCheckDate", "examinerId", "pupilDiameter", "cornealDiameter", "eyelidKey", "breakUpTime", "schirmerRight", "schirmerLeft", "eyeColor", "keratometryHR", "keratometryHL", "axisHR", "axisHL", "keratometryVR", "keratometryVL", "keratometryTR", "keratometryTL", "keratometryNR", "keratometryNL", "keratometryIR", "keratometryIL", "keratometrySR", "keratometrySL", "diameterRight", "diameterLeft", "baseCurve1R", "baseCurve1L", "baseCurve2R", "baseCurve2L", "opticalZoneR", "opticalZoneL", "powerR", "powerL", "sphereR", "sphereL", "cylinderR", "cylinderL", "axisR", "axisL", "addR", "addL", "materialR", "materialL", "tintR", "tintL", "visualAcuityR", "visualAcuityL", "visualAcuity", "pinHoleR", "pinHoleL", "lensTypeIdR", "lensTypeIdL", "manufacturerIdR", "manufacturerIdL", "brandIdR", "brandIdL", "cleaningSolutionId", "disinfectingSolutionId", "rinsingSolutionId", "blinkFrequency", "blinkQuality", "lensId", comments, "fittingComment", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ContactLensFitting; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ContactLensFitting" (id, "tenantId", "customerId", "fitterId", "fittingDate", "trialLenses", "finalSelection", "wearSchedule", "careSystem", "followUpDate", notes, status, "createdAt", "updatedAt", "branchId", "cleaningSolution", complications, "dailyWearHours", "disinfectingSolution", "enzymaticCleaner", "kReadingOdAxis", "kReadingOdFlat", "kReadingOdSteep", "kReadingOsAxis", "kReadingOsFlat", "kReadingOsSteep", "leftEyeAddPower", "leftEyeAxis", "leftEyeBaseCurve", "leftEyeBrand", "leftEyeCentering", "leftEyeColor", "leftEyeCylinder", "leftEyeDiameter", "leftEyeFitQuality", "leftEyeMaterial", "leftEyeMovement", "leftEyePower", "leftEyeType", "patientEducation", "replacementSchedule", "rewettingDrops", "rightEyeAddPower", "rightEyeAxis", "rightEyeBaseCurve", "rightEyeBrand", "rightEyeCentering", "rightEyeColor", "rightEyeCylinder", "rightEyeDiameter", "rightEyeFitQuality", "rightEyeMaterial", "rightEyeMovement", "rightEyePower", "rightEyeType", "trialResults") FROM stdin;
\.


--
-- Data for Name: ContactLensFittingDetail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ContactLensFittingDetail" (id, "tenantId", "branchId", "customerId", "checkDate", "fittingId", "diameterRight", "diameterLeft", "baseCurve1R", "baseCurve1L", "baseCurve2R", "baseCurve2L", "sphereR", "sphereL", "cylinderR", "cylinderL", "axisR", "axisL", "visualAcuityR", "visualAcuityL", "visualAcuity", "pinHoleR", "pinHoleL", "lensTypeIdR", "lensTypeIdL", "manufacturerIdR", "manufacturerIdL", "brandIdR", "brandIdL", "commentR", "commentL", "createdAt", "updatedAt", "pupilHeightL", "pupilHeightR") FROM stdin;
\.


--
-- Data for Name: ContactLensManufacturer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ContactLensManufacturer" (id, "tenantId", "manufacturerId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ContactLensMaterial; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ContactLensMaterial" (id, "tenantId", "materialId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ContactLensPrescription; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ContactLensPrescription" (id, "tenantId", "customerId", "doctorId", "prescriptionDate", "validUntil", "rightBrand", "rightPower", "rightBC", "rightDiameter", "rightCylinder", "rightAxis", "rightAdd", "rightColor", "leftBrand", "leftPower", "leftBC", "leftDiameter", "leftCylinder", "leftAxis", "leftAdd", "leftColor", "wearingSchedule", "replacementSchedule", notes, recommendations, "trialLensUsed", "createdAt", "updatedAt", "additionalData", "branchId") FROM stdin;
\.


--
-- Data for Name: ContactLensPricing; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ContactLensPricing" (id, "tenantId", "branchId", "sapakID", "cLensTypeID", "clensCharID", price, "pubPrice", "recPrice", "privPrice", active, quantity, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ContactLensRinsingSolution; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ContactLensRinsingSolution" (id, "tenantId", "solutionId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ContactLensTint; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ContactLensTint" (id, "tenantId", "tintId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ContactLensType; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ContactLensType" (id, "tenantId", "lensTypeId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Conversation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Conversation" (id, "supplierId", "tenantId", "relatedToType", "relatedToId", "lastMessageAt", "isArchived", "archivedBy", "archivedAt", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ConversationParticipant; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ConversationParticipant" (id, "conversationId", "participantId", "participantType", "muteNotifications", "mutedUntil", "lastSeenAt", "unreadCount", "joinedAt", "leftAt") FROM stdin;
\.


--
-- Data for Name: ConversationTyping; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ConversationTyping" (id, "conversationId", "typingUserId", "typingUserType", "typingUserName", "startedAt") FROM stdin;
\.


--
-- Data for Name: CrdBuysWorkLab; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CrdBuysWorkLab" (id, "tenantId", "branchId", "labID", "labName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CrdBuysWorkSapak; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CrdBuysWorkSapak" (id, "tenantId", "branchId", "sapakID", "sapakName", "itemCode", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CrdBuysWorkStat; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CrdBuysWorkStat" (id, "tenantId", "branchId", "workStatId", "workStatName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CrdBuysWorkSupply; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CrdBuysWorkSupply" (id, "tenantId", "branchId", "workSupplyId", "workSupplyName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CrdBuysWorkType; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CrdBuysWorkType" (id, "tenantId", "branchId", "workTypeId", "workTypeName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CrdClensChecksMater; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CrdClensChecksMater" (id, "tenantId", "branchId", "materId", "materName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CrdClensChecksPr; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CrdClensChecksPr" (id, "tenantId", "branchId", "prId", "prName", "idCount", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CrdClensChecksTint; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CrdClensChecksTint" (id, "tenantId", "branchId", "tintId", "tintName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CrdClensManuf; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CrdClensManuf" (id, "tenantId", "branchId", "clensManufId", "clensManufName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CrdClensSolClean; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CrdClensSolClean" (id, "tenantId", "branchId", "clensSolCleanId", "clensSolCleanName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CrdClensSolDisinfect; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CrdClensSolDisinfect" (id, "tenantId", "branchId", "clensSolDisinfectId", "clensSolDisinfectName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CrdClensSolRinse; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CrdClensSolRinse" (id, "tenantId", "branchId", "clensSolRinseId", "clensSolRinseName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CrdClensType; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CrdClensType" (id, "tenantId", "branchId", "clensTypeId", "clensTypeName", "idCount", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CrdGlassIOPInst; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CrdGlassIOPInst" (id, "tenantId", "branchId", "iOPInstId", "iOPInstName", "idCount", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CrdGlassRetDist; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CrdGlassRetDist" (id, "tenantId", "branchId", "retDistId", "retDistName", "idCount", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CrdGlassRetType; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CrdGlassRetType" (id, "tenantId", "branchId", "retTypeId", "retTypeName", "idCount", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CrdGlassUse; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CrdGlassUse" (id, "tenantId", "branchId", "glassUseId", "glassUseName", "idCount", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CreditCard; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CreditCard" (id, "tenantId", "branchId", "creditCardId", "creditCardName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CreditCardTransaction; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CreditCardTransaction" (id, "tenantId", "saleId", "invoiceId", "cardType", "last4Digits", "cardHolderName", "expiryMonth", "expiryYear", "transactionId", amount, currency, status, "processorName", "authorizationCode", "referenceNumber", "processedAt", "createdAt", "updatedAt", "branchId") FROM stdin;
\.


--
-- Data for Name: CreditType; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CreditType" (id, "tenantId", "branchId", "creditTypeId", "creditTypeName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CustomReport; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CustomReport" (id, "tenantId", "branchId", "oRepId", "oRepHeader", "oRepName", "oRepType", "oRPTPara", "secLevel", "inExe", "oRepSql", "uRepId", "uRepSql", "uRepHeader", "uRepName", "uRepType", "uRPTPara", "loadedForm", "firstCtl", "firstIndex", "secCtl", "secIndex", "shortCutNum", trans, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Customer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Customer" (id, "tenantId", "customerId", "firstName", "lastName", "firstNameHe", "lastNameHe", "idNumber", "birthDate", gender, occupation, "cellPhone", "homePhone", "workPhone", fax, email, address, city, "zipCode", "customerType", "groupId", "discountId", "referralId", "familyId", "preferredLanguage", "mailList", "smsConsent", notes, tags, rating, "wantsLaser", "laserDate", "didOperation", "createdAt", "updatedAt", "deletedAt", "branchId", allergies, "healthFund", "medicalConditions", medications) FROM stdin;
\.


--
-- Data for Name: CustomerGroup; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CustomerGroup" (id, "tenantId", "groupCode", name, "nameHe", discount, "isActive", "createdAt", "updatedAt", address, "branchId", "cityId", comment, "discountId", email, fax, "groupId", phone, "zipCode") FROM stdin;
\.


--
-- Data for Name: CustomerLastVisit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CustomerLastVisit" (id, "tenantId", "customerId", "customerNumber", "lastVisitDate", "lastVisitType", "lastAppointmentDate", "lastPurchaseDate", "lastExaminationDate", "visitCount", "purchaseCount", "examinationCount", "totalSpent", "lastUpdated", "createdAt") FROM stdin;
\.


--
-- Data for Name: CustomerOrder; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CustomerOrder" (id, "tenantId", "branchId", "itemData", "listIndex", "desc", deaf, "lblWiz", "lblWizType", "lblWizFld", "letterFld", "letterWiz", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CustomerPhoto; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CustomerPhoto" (id, "tenantId", "customerId", "photoType", "fileName", "filePath", "fileSize", "mimeType", description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: DataMigrationError; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."DataMigrationError" (id, "migrationId", "timestamp", phase, "table", "recordIndex", "recordData", "errorType", "errorMessage", "stackTrace", context) FROM stdin;
\.


--
-- Data for Name: DataMigrationRun; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."DataMigrationRun" (id, "tenantId", "branchId", status, phase, "fileName", "fileSize", "filePath", "totalTables", "tablesProcessed", "totalRecords", "recordsProcessed", "currentTable", "startTime", "endTime", duration, "recordsInserted", "recordsSkipped", "errorCount", "warningCount", "verificationResults", "auditReport", "extractedDataPath", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: DetailedWorkOrder; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."DetailedWorkOrder" (id, "tenantId", "branchId", "workId", "workDate", "customerId", "examinerId", "workTypeId", "checkDate", "workStatusId", "workSupplyId", "labId", "supplierId", "bagNumber", "promiseDate", "deliveryDate", "frameSupplierId", "frameLabelId", "frameModel", "frameColor", "frameSize", "frameSold", "lensSupplierId", "glassSupplierId", "lensCleanSupplierId", "glassId", "workType", "smsSent", "itemId", "tailId", canceled, comments, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Diagnosis; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Diagnosis" (id, "tenantId", "customerId", "examinerId", "diagnosisDate", complaints, illnesses, "doctorReferral", summary, "icdCode", "createdAt", "updatedAt", "optometricDiagnosis", "branchId") FROM stdin;
\.


--
-- Data for Name: DiagnosticProtocol; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."DiagnosticProtocol" (id, "tenantId", name, category, description, "requiredTests", "alertConditions", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Discount; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Discount" (id, "tenantId", name, code, type, value, "appliesTo", "productIds", "minimumPurchase", "maximumDiscount", "customerGroupIds", "customerIds", "validFrom", "validTo", "usageLimit", "usageCount", "perCustomerLimit", combinable, priority, active, "requiresApproval", notes, "createdAt", "updatedAt", "discountId", "prlCheck", "prlClens", "prlFrame", "prlGlass", "prlGlassBif", "prlGlassMul", "prlGlassOneP", "prlGlassOneS", "prlMisc", "prlProp", "prlService", "prlSolution", "prlSunGlass", "prlTreat") FROM stdin;
\.


--
-- Data for Name: DiseaseDiagnosis; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."DiseaseDiagnosis" (id, "tenantId", "branchId", "perId", "checkDate", "pushUp", "minusLens", "monAccFac6", "monAccFac7", "monAccFac8", "monAccFac13", "binAccFac6", "binAccFac7", "binAccFac8", "binAccFac13", "mEMRet", "fusedXCyl", "nRA", "pRA", "coverDist", "coverNear", "distLatFor", "distVerFor", "nearLatFor", "nearVerFor", "aCARatio", "smverBo6M", "smverBi6M", "smverBo40CM", "smverBi40CM", "stverBo7", "stverBi7", "stverBo6M", "stverBi6M", "stverBo40CM", "stverBi40CM", "jmpVer5", "jmpVer8", "accTarget", penlight, "penLightRG", summary, "userId", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Document; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Document" (id, "tenantId", "branchId", "documentNumber", title, type, category, "templateId", "generatedFrom", content, "contentType", "fileUrl", "customerId", "appointmentId", "examinationId", "prescriptionId", "saleId", metadata, variables, status, "sentAt", "sentTo", "sentMethod", "createdById", version, "previousVersionId", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: DocumentTemplate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."DocumentTemplate" (id, "tenantId", "branchId", name, description, category, type, language, subject, content, variables, metadata, "isActive", "isSystem", "paperSize", orientation, margins, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Dummy; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Dummy" (id, "tenantId", "branchId", dummy, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: EmployeeCommissionRule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."EmployeeCommissionRule" (id, "tenantId", "employeeId", "ruleId", "customPercentage", "customAmount", "isActive", "validFrom", "validUntil", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: EquipmentConfig; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."EquipmentConfig" (id, "tenantId", "branchId", "equipmentType", manufacturer, model, "serialNumber", "connectionType", "connectionConfig", "mappingRules", "isActive", "autoImport", notes, "installedDate", "lastCalibration", "createdBy", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: EquipmentImportLog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."EquipmentImportLog" (id, "equipmentId", "tenantId", "examinationId", "importDate", "dataType", "rawData", "mappedData", status, "errorMessage", "recordsImported", "importedBy", "createdAt") FROM stdin;
\.


--
-- Data for Name: ExamTemplate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ExamTemplate" (id, "tenantId", name, "nameHe", description, "templateType", sections, "requiredFields", "conditionalRules", "defaultValues", "isDefault", "isActive", "isPublic", "createdBy", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Examination; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Examination" (id, "tenantId", "customerId", "doctorId", "examDate", "examType", "vaRightDist", "vaLeftDist", "vaRightNear", "vaLeftNear", "refractionData", "currentRxData", "autoRxData", "coverTest", "npcDistance", "accommodationAmp", "pupilDistance", "iopRight", "iopLeft", "iopTime", "iopMethod", "slitLampData", "clinicalNotes", recommendations, "internalNotes", "prescriptionData", "nextExamDate", "followUpRequired", "createdAt", "updatedAt", "accommodativeFunction", allergies, "amslergridOd", "amslergridOs", "anteriorOdAc", "anteriorOdConjunctiva", "anteriorOdCornea", "anteriorOdIris", "anteriorOdLens", "anteriorOdLids", "anteriorOdVitreous", "anteriorOsAc", "anteriorOsConjunctiva", "anteriorOsCornea", "anteriorOsIris", "anteriorOsLens", "anteriorOsLids", "anteriorOsVitreous", "binocularFunction", "colorVisionResult", "colorVisionTest", complaints, "contactLensComfort", "contactLensFit", "contactLensHygiene", "contactLensWear", "contrastSensitivity", "deletedAt", "dilationDone", "dilationDrop", "dilationTime", "eomDiplopia", "eomFull", "eomRestrictions", "familyHistory", "followUpReason", "fusionalAmplitudes", "imageIds", "imageNotes", lifestyle, "medicalHistory", medications, "pdNear", "posteriorOdCdRatio", "posteriorOdMacula", "posteriorOdOpticDisc", "posteriorOdPeriphery", "posteriorOdVessels", "posteriorOsCdRatio", "posteriorOsMacula", "posteriorOsOpticDisc", "posteriorOsPeriphery", "posteriorOsVessels", "pupilsOdReaction", "pupilsOdSize", "pupilsOsReaction", "pupilsOsSize", "pupilsRapd", "reviewDate", "reviewNotes", "reviewRequired", "reviewedBy", stereopsis, "treatmentPlan", "vaBinocular", "visualFieldsDefects", "visualFieldsMethod", "visualFieldsOd", "visualFieldsOs", "branchId", "bifocalAddOd", "bifocalAddOs", "intermediateAddOd", "intermediateAddOs", "multifocalAddOd", "multifocalAddOs", "pdNearOd", "pdNearOs", "pdOd", "pdOs", "protocolId", "templateId") FROM stdin;
\.


--
-- Data for Name: ExaminationOverview; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ExaminationOverview" (id, "tenantId", "branchId", "customerId", "checkDate", "examinerId", comments, "visualAcuityR", "visualAcuityL", picture, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Expense; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Expense" (id, "tenantId", "branchId", "employeeId", title, description, category, subcategory, amount, currency, "receiptUrl", "receiptNumber", "vendorName", "expenseDate", period, status, "approvedBy", "approvedAt", "rejectedBy", "rejectedAt", "rejectionReason", reimbursed, "reimbursedAt", "reimbursementRef", "isDeductible", "taxRate", notes, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Eye; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Eye" (id, "tenantId", "branchId", "eyeId", "eyeName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: FRPLine; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."FRPLine" (id, "tenantId", "frpLineId", "frpId", "lineDate", quantity, "createdAt") FROM stdin;
\.


--
-- Data for Name: FamilyAuditLog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."FamilyAuditLog" (id, "tenantId", "relationshipId", "customerId", action, "actionType", "oldValue", "newValue", "userId", reason, "ipAddress", "userAgent", "createdAt") FROM stdin;
\.


--
-- Data for Name: FamilyRelationship; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."FamilyRelationship" (id, "tenantId", "customerId", "relatedCustomerId", "relationshipType", "isPrimary", verified, "verifiedBy", "verifiedAt", "confidenceScore", notes, tags, "createdBy", "createdAt", "updatedAt", "deletedAt") FROM stdin;
\.


--
-- Data for Name: FaxCommunication; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."FaxCommunication" (id, "tenantId", "branchId", "faxId", "sapakDestId", "sendTime", "jobInfo", "faxStatId", "faxStatName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: FollowUp; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."FollowUp" (id, "tenantId", "customerId", "scheduledDate", type, reason, priority, status, "completedDate", "completedBy", outcome, notes, "createdAt", "updatedAt", "branchId") FROM stdin;
\.


--
-- Data for Name: FollowUpReminder; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."FollowUpReminder" (id, "tenantId", "customerId", "examinationId", "reminderType", "dueDate", reason, "reasonHe", notes, status, priority, "sentAt", "sentVia", "completedAt", "scheduledAppointmentId", "createdBy", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Frame; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Frame" (id, "tenantId", "frameId", brand, model, color, size, material, style, gender, "eyeSize", "bridgeSize", "templeLength", "costPrice", "retailPrice", sku, barcode, supplier, "supplierCode", "inStock", discontinued, notes, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: FrameCatalog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."FrameCatalog" (id, "tenantId", "catalogNumber", barcode, brand, "brandCode", model, "modelCode", collection, material, "rimType", shape, "eyeSize", "bridgeSize", "templeLength", "totalWidth", "lensHeight", "frontColor", "templeColor", "colorCode", "colorFamily", gender, "ageGroup", features, cost, "retailPrice", "salePrice", "supplierId", "supplierCode", active, discontinued, "launchDate", "imageUrls", tags, notes, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: FrameData; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."FrameData" (id, "tenantId", "branchId", "sapakId", "labelId", "modelId", price, "pubPrice", "recPrice", "privPrice", active, quantity, "modelName", "iSG", sizes, "labelName", "privColorId", "privColorName", "frameColorId", "frameColorName", "framePic", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: FrameTrial; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."FrameTrial" (id, "tenantId", "customerId", "examinationId", "checkDate", "frameSupplierId", "frameBrandId", "frameModel", "frameColor", "frameSize", "triedAt", selected, notes, "createdBy", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: FrequentReplacementProgram; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."FrequentReplacementProgram" (id, "tenantId", "programId", "customerId", "startDate", "endDate", "rightEyeBrand", "rightEyeType", "rightEyePower", "leftEyeBrand", "leftEyeType", "leftEyePower", "replacementSchedule", "quantityPerBox", "boxesPerYear", "pricePerBox", "annualSupply", status, notes, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: FrequentReplacementProgramDetail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."FrequentReplacementProgramDetail" (id, "tenantId", "branchId", "frpId", "customerId", "brandId", "frpDate", "totalFrp", "exchangeNumber", "dayInterval", supply, "saleAdd", comments, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: FrpDelivery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."FrpDelivery" (id, "programId", "scheduledDate", "deliveredDate", quantity, status, "trackingNumber", notes, "createdAt") FROM stdin;
\.


--
-- Data for Name: GlassBrand; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."GlassBrand" (id, "tenantId", "brandId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: GlassCoating; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."GlassCoating" (id, "tenantId", "coatingId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: GlassColor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."GlassColor" (id, "tenantId", "colorId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: GlassExamination; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."GlassExamination" (id, "tenantId", "branchId", "customerId", "checkDate", "glassId", "roleId", "materialId", "brandId", "coatId", "modelId", "colorId", diameter, segment, "saleAdd", comments, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: GlassMaterial; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."GlassMaterial" (id, "tenantId", "materialId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: GlassModel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."GlassModel" (id, "tenantId", "modelId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: GlassPrescription; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."GlassPrescription" (id, "tenantId", "branchId", "customerId", "checkDate", "prevId", "refractiveSphereR", "refractiveSphereL", "refractiveCylinderR", "refractiveCylinderL", "refractiveAxisR", "refractiveAxisL", "retTypeId1", "retDistId1", "retComment1", "refractiveSphereR2", "refractiveSphereL2", "refractiveCylinderR2", "refractiveCylinderL2", "refractiveAxisR2", "refractiveAxisL2", "retTypeId2", "retDistId2", "retComment2", "sphereR", "sphereL", "cylinderR", "cylinderL", "axisR", "axisL", "prismR", "prismL", "baseR", "baseL", "visualAcuityR", "visualAcuityL", "visualAcuity", "pinHoleR", "pinHoleL", "externalPrismR", "externalPrismL", "externalBaseR", "externalBaseL", "pupillaryDistanceR", "pupillaryDistanceL", "pupillaryDistanceA", "additionR", "additionL", comments, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: GlassPrescriptionDetail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."GlassPrescriptionDetail" (id, "tenantId", "branchId", "customerId", "checkDate", "glassPId", "useId", "supplierId", "lensTypeId", "lensMaterialId", "lensCharId", "treatmentCharId", "treatmentCharId1", "treatmentCharId2", "treatmentCharId3", diameter, "eyeId", "saleAdd", comments, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: GlassRole; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."GlassRole" (id, "tenantId", "roleId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: GlassUse; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."GlassUse" (id, "tenantId", "useId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Household; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Household" (id, "tenantId", "householdHash", "displayName", "primaryContactId", "memberCount", "lifetimeValue", "lastActivityDate", address, city, "zipCode", notes, tags, "createdAt", "updatedAt", "deletedAt") FROM stdin;
\.


--
-- Data for Name: InvMoveType; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."InvMoveType" (id, "tenantId", "branchId", "invMoveTypeId", "invMoveTypeName", "moveAction", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: InventoryAdjustment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."InventoryAdjustment" (id, "tenantId", "adjustmentDate", "adjustmentType", reason, notes, "adjustedBy", "approvedBy", "approvedAt", "physicalCountId", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: InventoryAdjustmentItem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."InventoryAdjustmentItem" (id, "tenantId", "adjustmentId", "productId", "oldQuantity", "newQuantity", "adjustmentAmount", "unitCost", "totalCostImpact", notes) FROM stdin;
\.


--
-- Data for Name: InventoryReference; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."InventoryReference" (id, "tenantId", "branchId", "itemColorId", "itemColorName", "itemCode", "itemStatId", "itemStatName", "itemLineId", "catId", sold, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Invoice; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Invoice" (id, "tenantId", "invoiceId", "invoiceNumber", "supplierId", "invoiceDate", "dueDate", "totalAmount", "paidAmount", "invoiceType", comment, status, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: InvoiceCredit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."InvoiceCredit" (id, "invoiceId", "creditDate", amount, reason, reference, "createdAt") FROM stdin;
\.


--
-- Data for Name: InvoicePayment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."InvoicePayment" (id, "tenantId", "invoiceId", "paymentDate", amount, "paymentMethod", reference, "createdAt") FROM stdin;
\.


--
-- Data for Name: InvoiceType; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."InvoiceType" (id, "tenantId", "branchId", "invoiceTypeId", "invoiceTypeName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: InvoiceVerification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."InvoiceVerification" (id, "tenantId", "branchId", "invoiceCheckId", "invoicePayId", "checkId", "checkDate", "checkSum", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ItemCountsYear; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ItemCountsYear" (id, "tenantId", "branchId", "countYear", "countDate", closed, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ItemStatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ItemStatus" (id, "tenantId", "productId", month, year, opening, purchases, sales, removals, closing, "costValue", "saleValue", revenue, cogs, "grossProfit", "profitPct", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: LabelPrintJob; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."LabelPrintJob" (id, "tenantId", "branchId", "templateId", "jobNumber", status, "dataSource", "dataQuery", labels, quantity, "totalLabels", "printerName", "outputFormat", "outputUrl", error, "errorDetails", "createdBy", "printedBy", "createdAt", "printedAt", "completedAt") FROM stdin;
\.


--
-- Data for Name: LabelTemplate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."LabelTemplate" (id, "tenantId", "branchId", name, description, category, width, height, orientation, "pageSize", "pageWidth", "pageHeight", "labelsPerRow", "labelsPerColumn", "marginTop", "marginLeft", "labelSpacingX", "labelSpacingY", design, "defaultFields", "isDefault", "isActive", "printerName", copies, "createdAt", "updatedAt", "createdById") FROM stdin;
\.


--
-- Data for Name: Lang; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Lang" (id, "tenantId", "branchId", "langId", "langName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Lens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Lens" (id, "tenantId", "lensId", type, material, index, "sphereMin", "sphereMax", "cylinderMin", "cylinderMax", "addMin", "addMax", diameter, coating, tint, photochromic, polarized, "baseCost", "basePrice", supplier, "supplierCode", "labCode", available, notes, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: LensCatalog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."LensCatalog" (id, "tenantId", "catalogNumber", "productCode", manufacturer, brand, series, "lensType", design, material, "refractiveIndex", "abbeValue", "specificGravity", "sphereMin", "sphereMax", "cylinderMin", "cylinderMax", "addMin", "addMax", "baseCurves", diameters, "centerThickness", coatings, "corridorLengths", "pricingMatrix", "supplierId", "supplierCode", "labProcessing", "surfacingRequired", active, "stockItem", "leadTime", "uvProtection", impact, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: LensCharacteristic; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."LensCharacteristic" (id, "tenantId", "supplierId", "lensTypeId", "lensMaterialId", "characteristicId", name, "idCount", "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: LensMaterial; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."LensMaterial" (id, "tenantId", "materialId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: LensSolution; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."LensSolution" (id, "tenantId", "branchId", "solutionId", "solutionName", "sapakID", price, "pubPrice", "recPrice", "privPrice", active, quantity, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: LensTreatment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."LensTreatment" (id, "tenantId", "branchId", "sapakID", "lensTypeID", "lensMaterID", "treatCharID", "treatCharName", "idCount", "treatCharId", "treatId", "treatName", "fldName", "treatRule", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: LensTreatmentCharacteristic; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."LensTreatmentCharacteristic" (id, "tenantId", "supplierId", "lensTypeId", "lensMaterialId", "treatmentCharId", name, "isActive", "createdAt", "updatedAt", "idCount") FROM stdin;
\.


--
-- Data for Name: LensType; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."LensType" (id, "tenantId", "lensTypeId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Letter; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Letter" (id, "tenantId", "templateName", subject, content, category, "mergeFields", "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: LowVisionArea; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."LowVisionArea" (id, "tenantId", "areaId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: LowVisionCap; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."LowVisionCap" (id, "tenantId", "capId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: LowVisionCheck; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."LowVisionCheck" (id, "tenantId", "customerId", "examinerId", "examDate", "visualAcuity", "contrastSensitivity", "visualField", "aidsRecommended", notes, "createdAt", "branchId") FROM stdin;
\.


--
-- Data for Name: LowVisionExamination; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."LowVisionExamination" (id, "tenantId", "branchId", "customerId", "checkDate", "lowVisionId", "eyeId", "pupillaryDistanceR", "pupillaryDistanceL", "manufacturerId", "frameId", "areaId", "capId", "visualAcuityDistance", "visualAcuityNear", "visualAcuityDistanceLeft", "visualAcuityNearLeft", comments, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: LowVisionFrame; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."LowVisionFrame" (id, "tenantId", "frameId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: LowVisionManufacturer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."LowVisionManufacturer" (id, "tenantId", "manufacturerId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Message; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Message" (id, "conversationId", "senderId", "senderType", "senderName", content, attachments, "readAt", "readBy", "messageType", metadata, "createdAt", "updatedAt", "deletedAt") FROM stdin;
\.


--
-- Data for Name: MessageAttachment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."MessageAttachment" (id, "messageId", "fileName", "fileUrl", "fileSize", "mimeType", "uploaderId", "uploaderType", "createdAt") FROM stdin;
\.


--
-- Data for Name: MessageTemplate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."MessageTemplate" (id, "tenantId", name, type, language, subject, content, active, "isSystem", variables, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: MigrationLog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."MigrationLog" (id, "migrationId", "timestamp", level, step, message, details, "createdAt") FROM stdin;
\.


--
-- Data for Name: MigrationRun; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."MigrationRun" (id, "tenantId", "fileName", "filePath", "fileSize", status, progress, "currentStep", "startedAt", "completedAt", "errorMessage", "tablesProcessed", "recordsImported", "recordsSkipped", "recordsFailed", metadata, "createdBy", "createdAt", "updatedAt", "branchId") FROM stdin;
\.


--
-- Data for Name: MigrationTableResult; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."MigrationTableResult" (id, "migrationId", "tableName", "sourceTable", "recordsSource", "recordsImported", "recordsSkipped", "recordsFailed", "successRate", status, "errorMessage", "startedAt", "completedAt", duration, "createdAt") FROM stdin;
\.


--
-- Data for Name: MovementProperty; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."MovementProperty" (id, "tenantId", "movementPropertyId", name, "nameHe", description, "isActive", "sortOrder", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: MovementType; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."MovementType" (id, "tenantId", "movementTypeId", name, "nameHe", action, category, "requiresInvoice", "requiresReason", "isActive", "sortOrder", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: NewProduct; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."NewProduct" (id, "tenantId", "productId", name, "nameHe", description, "descriptionHe", "imageUrl", "isActive", "displayFrom", "displayUntil", "displayOrder", category, tags, "createdBy", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: OpticalBase; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."OpticalBase" (id, "tenantId", "baseId", name, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Order; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Order" (id, "tenantId", "customerId", "orderNumber", "orderDate", "deliveryDate", status, "paymentStatus", "workType", "labId", "supplierId", "prescriptionId", subtotal, discount, "taxAmount", "totalAmount", "paidAmount", "depositAmount", notes, "internalNotes", "createdAt", "updatedAt", "branchId") FROM stdin;
\.


--
-- Data for Name: OrderItem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."OrderItem" (id, "tenantId", "orderId", "productId", "productType", description, quantity, "unitPrice", discount, "totalPrice", "lensData", status, notes, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Orthokeratology; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Orthokeratology" (id, "tenantId", "customerId", "prescriberId", "startDate", "rightEyeData", "leftEyeData", "treatmentPlan", "progressNotes", status, "createdAt", "updatedAt", "branchId") FROM stdin;
\.


--
-- Data for Name: OrthokeratologyTreatment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."OrthokeratologyTreatment" (id, "tenantId", "branchId", "customerId", "orthokId", "checkDate", "reCheckDate", "examinerId", "keratometryHR", "keratometryHL", "axisHR", "axisHL", "keratometryVR", "keratometryVL", "keratometryTR", "keratometryTL", "keratometryNR", "keratometryNL", "keratometryIR", "keratometryIL", "keratometrySR", "keratometrySL", "diameterR", "diameterL", "baseCurve1R", "baseCurve1L", "opticalZoneR", "opticalZoneL", "sphereR", "sphereL", "fittingCurveR", "fittingCurveL", "alignmentCurveR", "alignmentCurveL", "alignment2CurveR", "alignment2CurveL", "secondaryR", "secondaryL", "edgeR", "edgeL", "fittingCurveThicknessR", "fittingCurveThicknessL", "alignmentCurveThicknessR", "alignmentCurveThicknessL", "alignment2CurveThicknessR", "alignment2CurveThicknessL", "edgeThicknessR", "edgeThicknessL", "opticalZoneThicknessR", "opticalZoneThicknessL", "materialR", "materialL", "tintR", "tintL", "visualAcuityR", "visualAcuityL", "visualAcuity", "lensTypeIdR", "lensTypeIdL", "manufacturerIdR", "manufacturerIdL", "brandIdR", "brandIdL", "commentR", "commentL", "pictureL", "pictureR", "orderId", "customerId2", "pupilDiameter", "cornealDiameter", "eyelidKey", "checkType", "eccentricityHR", "eccentricityHL", "eccentricityVR", "eccentricityVL", "eccentricityAR", "eccentricityAL", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: POSAuditLog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."POSAuditLog" (id, "tenantId", "terminalId", "userId", action, "entityType", "entityId", "beforeState", "afterState", changes, "ipAddress", "userAgent", metadata, "createdAt") FROM stdin;
\.


--
-- Data for Name: POSCashDrop; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."POSCashDrop" (id, "tenantId", "shiftId", "dropNumber", amount, "billBreakdown", reason, "depositedBy", "verifiedBy", "verifiedAt", notes, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: POSCashPickup; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."POSCashPickup" (id, "tenantId", "shiftId", "pickupNumber", amount, "billBreakdown", reason, "pickedUpBy", "approvedBy", "approvedAt", notes, "createdAt") FROM stdin;
\.


--
-- Data for Name: POSInventoryMovement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."POSInventoryMovement" (id, "tenantId", "transactionId", "productId", "branchId", "movementType", quantity, "previousQuantity", "newQuantity", reason, notes, "createdAt") FROM stdin;
\.


--
-- Data for Name: POSPayment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."POSPayment" (id, "tenantId", "transactionId", "paymentNumber", "paymentMethod", amount, currency, status, "cardToken", "cardLastFour", "cardBrand", "cardType", "cardholderName", "expiryMonth", "expiryYear", "authorizationCode", "processorTransactionId", "gatewayResponse", "processorName", "installmentPlan", "installmentCount", "installmentAmount", "firstPayment", "checkNumber", "checkDate", "bankName", "bankBranch", "accountNumber", "transferReference", "transferDate", "voucherCode", "voucherType", notes, metadata, "processedAt", "failedAt", "failureReason", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: POSPaymentRefund; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."POSPaymentRefund" (id, "tenantId", "paymentId", "refundNumber", amount, reason, status, "processorRefundId", "createdBy", "approvedBy", "approvedAt", "processedAt", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: POSPriceList; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."POSPriceList" (id, "tenantId", name, description, "priceListType", priority, "isActive", "validFrom", "validTo", "applicableTerminals", "applicableCustomerGroups", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: POSPriceListItem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."POSPriceListItem" (id, "priceListId", "productId", price, "discountPercent", "minQuantity", "maxQuantity", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: POSReceipt; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."POSReceipt" (id, "tenantId", "branchId", "terminalId", "transactionId", "receiptNumber", "receiptType", "customerId", "customerName", "customerEmail", "customerPhone", "totalAmount", currency, "receiptTemplate", "receiptData", "qrCode", signature, "printCount", "emailSent", "emailSentAt", "printedAt", "voidedAt", notes, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: POSReportSnapshot; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."POSReportSnapshot" (id, "tenantId", "branchId", "reportType", "reportNumber", "reportData", "periodStart", "periodEnd", "generatedBy", notes, "createdAt") FROM stdin;
\.


--
-- Data for Name: POSSession; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."POSSession" (id, "tenantId", "terminalId", "userId", "sessionNumber", "startTime", "endTime", status, notes, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: POSSyncQueue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."POSSyncQueue" (id, "tenantId", "terminalId", operation, "entityType", "entityId", payload, priority, status, attempts, "maxAttempts", "lastError", "syncedAt", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: POSTerminal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."POSTerminal" (id, "tenantId", "branchId", "terminalNumber", "terminalName", "terminalType", status, "ipAddress", "macAddress", "deviceInfo", configuration, "lastHeartbeat", "lastSyncedAt", "receiptPrinter", "fiscalPrinter", "isOnline", "allowOffline", "maxOfflineHours", "enableBarcode", "enableScale", "enableCardReader", "createdAt", "updatedAt", "activatedAt", "deactivatedAt") FROM stdin;
\.


--
-- Data for Name: POSTransaction; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."POSTransaction" (id, "tenantId", "branchId", "terminalId", "sessionId", "shiftId", "transactionNumber", "transactionType", status, "customerId", "cashierId", "supervisorId", subtotal, "discountAmount", "taxAmount", "totalAmount", "paidAmount", "changeAmount", "roundingAdjustment", currency, "exchangeRate", "originalTransactionId", "refundedTransactionId", "receiptId", "saleId", notes, signature, "hashField", metadata, "isOffline", "syncStatus", "lastSyncedAt", "transactionDate", "completedAt", "voidedAt", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: POSTransactionDiscount; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."POSTransactionDiscount" (id, "transactionId", "discountCode", "discountType", "discountValue", "discountPercent", amount, reason, "requiresApproval", "approvedBy", "approvedAt", "createdAt") FROM stdin;
\.


--
-- Data for Name: POSTransactionEvent; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."POSTransactionEvent" (id, "transactionId", "eventType", "eventData", "timestamp") FROM stdin;
\.


--
-- Data for Name: POSTransactionItem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."POSTransactionItem" (id, "transactionId", "productId", "lineNumber", "productName", sku, barcode, description, category, quantity, "unitPrice", "originalPrice", "discountAmount", "discountPercent", "taxRate", "taxAmount", subtotal, "totalAmount", notes, metadata, "isRefunded", "refundedQuantity", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: POSTransactionTax; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."POSTransactionTax" (id, "transactionId", "taxName", "taxRate", "taxableAmount", "taxAmount", "createdAt") FROM stdin;
\.


--
-- Data for Name: PayType; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."PayType" (id, "tenantId", "branchId", "payTypeId", "payTypeName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Payment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Payment" (id, "tenantId", "branchId", "paymentNumber", "paymentDate", "saleId", "invoiceId", "customerId", "paymentType", amount, currency, "cardLastFour", "cardType", "authCode", "checkNumber", "checkDate", "bankName", "bankBranch", "transferRef", status, "receiptNumber", "receiptIssued", notes, "createdBy", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Payroll; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Payroll" (id, "tenantId", "branchId", "employeeId", period, "periodStart", "periodEnd", "payDate", "baseSalary", "hourlyRate", "hoursWorked", "overtimeHours", "overtimeRate", "commissionAmount", "bonusAmount", "taxDeduction", "socialSecurity", "healthInsurance", "otherDeductions", "deductionNotes", "grossPay", "netPay", status, "approvedBy", "approvedAt", "paidAt", "paymentMethod", "paymentRef", notes, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: PhysicalInventoryCount; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."PhysicalInventoryCount" (id, "tenantId", status, "createdAt", "updatedAt", "completedAt", "countName", "createdByUserId", description, "startDate") FROM stdin;
\.


--
-- Data for Name: PhysicalInventoryCountItem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."PhysicalInventoryCountItem" (id, "productId", "countedQuantity", "createdAt", "physicalCountId", "systemQuantity", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Prescription; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Prescription" (id, "tenantId", "customerId", "doctorId", "prescriptionDate", "validUntil", "rightSphere", "rightCylinder", "rightAxis", "rightAdd", "rightPrism", "rightBase", "rightPd", "rightVa", "leftSphere", "leftCylinder", "leftAxis", "leftAdd", "leftPrism", "leftBase", "leftPd", "leftVa", pd, "pdNear", "fittingHeight", "prescriptionType", notes, recommendations, "createdAt", "updatedAt", "additionalData", "branchId", "retinoscopyDist", "retinoscopyNotes", "retinoscopyType") FROM stdin;
\.


--
-- Data for Name: PrescriptionGlassDetail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."PrescriptionGlassDetail" (id, "tenantId", "prescriptionId", "glassId", "roleId", "materialId", "brandId", "coatingId", "modelId", "colorId", diameter, segment, comments, "saleAddition", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: PrescriptionHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."PrescriptionHistory" (id, "tenantId", "customerId", "prescriptionDate", "previousId", "refRightSphere", "refLeftSphere", "refRightCylinder", "refLeftCylinder", "refRightAxis", "refLeftAxis", "refRightSphere2", "refLeftSphere2", "refRightCylinder2", "refLeftCylinder2", "refRightAxis2", "refLeftAxis2", "rightSphere", "leftSphere", "rightCylinder", "leftCylinder", "rightAxis", "leftAxis", "rightPrism", "leftPrism", "rightBase", "leftBase", "rightVa", "leftVa", "binocularVa", "rightPd", "leftPd", pd, "rightAdd", "leftAdd", "extRightPrism", "extLeftPrism", "extRightBase", "extLeftBase", comments, "retTypeId1", "retDistId1", "retComment1", "retTypeId2", "retDistId2", "retComment2", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: PriceHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."PriceHistory" (id, "tenantId", "productId", "oldPrice", "newPrice", "oldCost", "newCost", "changedBy", "changedAt", "priceUpdateId", reason) FROM stdin;
\.


--
-- Data for Name: PriceUpdate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."PriceUpdate" (id, "tenantId", name, description, "updateType", scope, value, "roundTo", filters, status, "scheduledFor", "appliedAt", "productsUpdated", "totalValue", notes, "createdBy", "appliedBy", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: PrintLabel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."PrintLabel" (id, "tenantId", "branchId", "labelId", "labelName", "margRight", "margLeft", "labelWidth", "labelHeight", "horSpace", "verSpace", "margTop", "margBot", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: PrlType; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."PrlType" (id, "tenantId", "branchId", "prlType", "prlName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Product; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Product" (id, "tenantId", "productId", name, description, sku, barcode, category, subcategory, brand, model, "costPrice", "sellPrice", "wholeSalePrice", quantity, "minQuantity", unit, location, supplier, "supplierProductCode", "isActive", "trackQuantity", tags, notes, "lensType", material, coating, "sphereMin", "sphereMax", "cylinderMin", "cylinderMax", "frameSize", "frameColor", "frameShape", "frameMaterial", prescription, "createdAt", "updatedAt", "deletedAt", "branchId", "supplierId", "requiresSerial") FROM stdin;
\.


--
-- Data for Name: ProductProperty; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ProductProperty" (id, "tenantId", "branchId", "propId", "propName", "sapakID", price, "pubPrice", "recPrice", "privPrice", active, quantity, "invMovePropId", "invMovePropName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ProductReview; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ProductReview" (id, "tenantId", "userId", "userName", "itemType", "itemId", "collectionId", "supplierId", rating, title, comment, images, verified, "orderReference", "helpfulCount", "notHelpfulCount", status, "moderatedBy", "moderatedAt", "supplierResponse", "supplierResponseBy", "supplierResponseAt", "createdAt", "updatedAt", "deletedAt") FROM stdin;
\.


--
-- Data for Name: ProductSerial; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ProductSerial" (id, "tenantId", "productId", "serialNumber", status, "saleItemId", notes, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Profile; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Profile" (id, "tenantId", "branchId", "profileId", "profileName", "profileSql", "profileDesc", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Purchase; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Purchase" (id, "tenantId", "purchaseId", "purchaseDate", "customerId", "userId", "purchaseType", "totalAmount", "paidAmount", comment, status, "createdAt", "updatedAt", "branchId") FROM stdin;
\.


--
-- Data for Name: PurchaseCheck; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."PurchaseCheck" (id, "tenantId", "purchaseId", "checkNumber", "bankName", "checkDate", amount, status, "createdAt") FROM stdin;
\.


--
-- Data for Name: PurchasePayment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."PurchasePayment" (id, "tenantId", "purchaseId", "paymentDate", amount, "paymentMethod", reference, "createdAt") FROM stdin;
\.


--
-- Data for Name: ReferralSource; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ReferralSource" (id, "tenantId", "branchId", "refsSub2Id", "refsSub2Name", "subRefId", "refsSub1Id", "refsSub1Name", "refId", "refName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: RefractionProtocol; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."RefractionProtocol" (id, "tenantId", name, description, "isDefault", steps, "includeAutoref", "includeRetino", "includeSubj", "includeBino", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: RetinoscopyDistance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."RetinoscopyDistance" (id, "tenantId", "retDistId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: RetinoscopyType; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."RetinoscopyType" (id, "tenantId", "retTypeId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ReviewHelpful; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ReviewHelpful" (id, "reviewId", "userId", helpful, "createdAt") FROM stdin;
\.


--
-- Data for Name: ReviewReport; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ReviewReport" (id, "reviewId", "reportedBy", reason, details, status, "reviewedBy", "reviewedAt", "createdAt") FROM stdin;
\.


--
-- Data for Name: SMS; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SMS" (id, "tenantId", "customerId", message, type, status, "errorMessage", "createdAt", "branchId", cost, credits, "messageId", phone, "sentAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: SMSLen; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SMSLen" (id, "tenantId", "branchId", "sMSProviderPrefix", "sMSLang", "sMSProviderName", "sMSLen", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Sale; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Sale" (id, "tenantId", "saleId", "customerId", "sellerId", "saleDate", status, subtotal, "discountAmount", "taxAmount", total, "paymentMethod", "paymentStatus", "prescriptionId", notes, "createdAt", "updatedAt", "deletedAt", "branchId", "cashierShiftId", "groupReference", "invoiceType", "receiptDate", "receiptNumber", "sourceReference") FROM stdin;
\.


--
-- Data for Name: SaleItem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SaleItem" (id, "saleId", "productId", "productName", category, sku, quantity, "unitPrice", "discountPercent", "discountAmount", "lineTotal", "prescriptionData", notes, "createdAt", "barcodeId", "tenantId") FROM stdin;
\.


--
-- Data for Name: SapakComment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SapakComment" (id, "tenantId", "branchId", "sapakId", "prlType", comments, "prlSp", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: SapakDest; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SapakDest" (id, "tenantId", "branchId", "sapakDestId", "sapakDestName", "sapakId", fax1, fax2, email1, email2, "clientId", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: SapakPerComment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SapakPerComment" (id, "tenantId", "branchId", "sapakId", "prlType", comments, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: SearchOrder; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SearchOrder" (id, "tenantId", "branchId", "itemData", "listIndex", "desc", deaf, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ServiceType; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ServiceType" (id, "tenantId", "branchId", "serviceId", "serviceName", "servicePrice", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ShortCut; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ShortCut" (id, "tenantId", "branchId", "prKey", "shKey", "desc", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: SlitLampExam; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SlitLampExam" (id, "tenantId", "customerId", "examinerId", "examDate", "rightEyeFindings", "leftEyeFindings", "additionalNotes", images, "createdAt", "branchId") FROM stdin;
\.


--
-- Data for Name: Special; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Special" (id, "tenantId", "branchId", "sapakID", "specialId", "prlType", priority, price, "pubPrice", "recPrice", "privPrice", formula, data, "rLOnly", active, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: SpecialName; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SpecialName" (id, "tenantId", "branchId", "specialId", "specialName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: StaffSchedule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."StaffSchedule" (id, "tenantId", "userId", "workDate", "scheduleType", "startTime", "endTime", notes, "createdBy", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: StockMovement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."StockMovement" (id, "tenantId", "productId", "userId", type, quantity, "previousQuantity", "newQuantity", reason, notes, "referenceId", "costPrice", "createdAt", "branchId", "exCatNum", "invoiceId", "movementPropertyId", "movementTypeId", "salePrice", "totalCost", "totalSale") FROM stdin;
\.


--
-- Data for Name: Supplier; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Supplier" (id, "tenantId", "supplierId", name, "contactPerson", phone, email, address, website, "taxId", "paymentTerms", "creditLimit", "accountNumber", "suppliesFrames", "suppliesLenses", "suppliesContactLenses", "suppliesAccessories", "isActive", notes, "createdAt", "updatedAt", "bankDetails", city, country, "creditTerms", fax, "leadTimeDays", "minimumOrderAmount", "nameHe", "specialInstructions", "supplierType", "vatNumber", "zipCode") FROM stdin;
\.


--
-- Data for Name: SupplierAccountTransaction; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierAccountTransaction" (id, "accountId", type, amount, "orderId", "invoiceId", "paymentId", "balanceBefore", "balanceAfter", description, notes, "referenceNumber", "paymentMethod", "transactionDate", "createdAt", "createdBy") FROM stdin;
\.


--
-- Data for Name: SupplierAnalytics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierAnalytics" (id, "supplierId", "periodType", "periodStart", "periodEnd", "totalOrders", "totalRevenue", "totalUnits", "averageOrderValue", "topSellingItemId", "topSellingItemUnits", "lowStockItems", "outOfStockItems", "activeTenants", "newTenants", "topTenantId", "topTenantRevenue", "rfqsReceived", "rfqsQuoted", "rfqsConverted", "conversionRate", "inventoryValue", "inventoryTurnover", "grossProfit", "profitMargin", "calculatedAt") FROM stdin;
\.


--
-- Data for Name: SupplierCatalogCategory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierCatalogCategory" (id, "supplierId", name, "nameHe", description, "parentId", "displayOrder", "isActive", "imageUrl", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: SupplierCatalogItem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierCatalogItem" (id, "supplierId", "categoryId", sku, name, "nameHe", description, "descriptionHe", type, brand, model, material, shape, color, "eyeSize", "bridgeSize", "templeLength", gender, "lensType", material_lens, coating, "indexValue", "basePrice", cost, msrp, currency, "stockQuantity", "lowStockAlert", "inStock", "backorderAllowed", "leadTimeDays", images, "primaryImage", "catalogPdf", "isActive", "isFeatured", "isNewArrival", "publishedAt", barcode, upc, weight, dimensions, tags, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: SupplierCatalogVariant; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierCatalogVariant" (id, "itemId", name, sku, "variantType", attributes, "priceModifier", price, "stockQuantity", "isAvailable", images, "primaryImage", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: SupplierCollection; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierCollection" (id, "supplierId", name, season, description, "coverImage", published, "tenantScope", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: SupplierCollectionVisibility; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierCollectionVisibility" (id, "collectionId", "tenantId", "createdAt") FROM stdin;
\.


--
-- Data for Name: SupplierDiscount; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierDiscount" (id, "supplierId", name, "nameHe", description, code, type, value, tiers, "applyToAll", "itemIds", "categoryIds", "tenantScope", "tenantIds", "minPurchaseAmount", "minQuantity", "maxUsesPerTenant", "maxTotalUses", "currentUses", "startDate", "endDate", "isActive", priority, stackable, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: SupplierDiscountUsage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierDiscountUsage" (id, "discountId", "tenantId", "orderId", "discountAmount", "orderAmount", "itemCount", "usedAt") FROM stdin;
\.


--
-- Data for Name: SupplierInventoryLog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierInventoryLog" (id, "itemId", type, quantity, "quantityBefore", "quantityAfter", "orderId", "rfqId", reason, notes, "locationCode", "batchNumber", "expiryDate", cost, "createdAt", "createdBy") FROM stdin;
\.


--
-- Data for Name: SupplierOrder; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierOrder" (id, "supplierId", "orderNumber", "orderDate", "expectedDate", "receivedDate", "totalAmount", status, items, notes, "createdAt", "updatedAt", "branchId", "tenantId", "cancelReason", "cancelledDate", "discountAmount", "lastReceivedDate", "paymentTerms", "receiveNotes", "receivedBy", "referenceNumber", "sentDate", "shippingCost", "shippingMethod", subtotal, "accountId") FROM stdin;
\.


--
-- Data for Name: SupplierOrderItem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierOrderItem" (id, "orderId", "productId", "itemCode", "itemDescription", "quantityOrdered", "quantityReceived", "quantityBackordered", "unitCost", discount, "totalCost", status, "receivedDate", "receivedBy", notes) FROM stdin;
\.


--
-- Data for Name: SupplierPriceAlert; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierPriceAlert" (id, "tenantId", "userId", "frameCatalogId", "lensCatalogId", "itemType", "alertType", "targetPrice", "percentChange", "isActive", "notifyEmail", "notifyInApp", "lastTriggered", "triggerCount", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: SupplierPriceCache; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierPriceCache" (id, "frameCatalogId", "lensCatalogId", "itemType", "lowestPrice", "lowestSupplierId", "highestPrice", "averagePrice", "supplierCount", "priceRange", "supplierPrices", "lastCalculated", "expiresAt") FROM stdin;
\.


--
-- Data for Name: SupplierPriceHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierPriceHistory" (id, "supplierId", "frameCatalogId", "lensCatalogId", "itemType", price, currency, "minQuantity", "maxQuantity", "validFrom", "validTo", "isActive", "priceType", notes, source, "createdAt", "updatedAt", "createdBy") FROM stdin;
\.


--
-- Data for Name: SupplierPriceList; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierPriceList" (id, "supplierId", name, "nameHe", description, type, "startDate", "endDate", "isActive", priority, "tenantIds", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: SupplierPriceListItem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierPriceListItem" (id, "priceListId", "itemId", price, "volumePricing", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: SupplierRFQ; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierRFQ" (id, "tenantId", "supplierId", status, notes, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: SupplierRFQItem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierRFQItem" (id, "rfqId", type, "frameCatalogId", "lensCatalogId", quantity, "targetPrice") FROM stdin;
\.


--
-- Data for Name: SupplierShipment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierShipment" (id, "tenantId", "branchId", "sapakSendId", "perId", "glassPId", "workId", "clensId", "sapakDestId", "userId", "sendTime", recived, "privPrice", "shipmentId", "shipmentDate", sent, com, "spsStatId", "spsType", "spsSendType", "faxId", "shFrame", "shLab", "treatBlock", "treatWSec", "treatWScrew", "treatWNylon", "treatWKnife", "lensColor", "lensLevel", "eyeWidth", "eyeHeight", "bridgeWidth", "centerHeightR", "centerHeightL", "segHeightR", "segHeightL", "picNum", "pCom", basis, pent, "vD", "spsStatName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: SupplierStockAlert; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierStockAlert" (id, "supplierId", "itemId", type, severity, message, "currentStock", "thresholdValue", "isRead", "isResolved", "resolvedAt", "resolvedBy", "createdAt") FROM stdin;
\.


--
-- Data for Name: SupplierTenantAccount; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierTenantAccount" (id, "supplierId", "tenantId", "accountNumber", "accountStatus", "creditLimit", "currentBalance", "availableCredit", "paymentTerms", "paymentTermsDays", "defaultDiscount", "priceListId", "totalOrders", "totalRevenue", "averageOrderValue", "lastOrderDate", "firstOrderDate", "billingContactName", "billingEmail", "billingPhone", "shippingAddress", "billingAddress", "allowBackorders", "requirePO", "autoApproveOrders", "internalNotes", "creditHold", "creditHoldReason", "accountManager", rating, tags, "createdAt", "updatedAt", "lastActivityAt") FROM stdin;
\.


--
-- Data for Name: SupplierTenantActivity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierTenantActivity" (id, "supplierId", "tenantId", type, description, "referenceId", "referenceType", metadata, "createdAt") FROM stdin;
\.


--
-- Data for Name: SupplierTenantNote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierTenantNote" (id, "supplierId", "tenantId", title, content, type, status, priority, "dueDate", attachments, "isPrivate", "createdAt", "updatedAt", "createdBy") FROM stdin;
\.


--
-- Data for Name: SupplierUser; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SupplierUser" (id, "supplierId", email, "passwordHash", role, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: SysLevel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SysLevel" (id, "tenantId", "branchId", "levelId", "levelName", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Task; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Task" (id, "tenantId", "branchId", title, description, priority, status, "assignedToId", "createdById", "dueDate", "completedAt", "customerId", "relatedType", "relatedId", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: TaskAttachment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."TaskAttachment" (id, "tenantId", "taskId", "fileName", "fileUrl", "fileSize", "mimeType", "uploadedById", "createdAt") FROM stdin;
\.


--
-- Data for Name: TaskComment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."TaskComment" (id, "tenantId", "taskId", "userId", comment, "createdAt") FROM stdin;
\.


--
-- Data for Name: TaxRate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."TaxRate" (id, "tenantId", name, code, rate, "appliesTo", region, "exemptCategories", active, "isDefault", "validFrom", "validTo", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Tenant; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Tenant" (id, name, "nameHe", subdomain, plan, active, "primaryLanguage", timezone, "createdAt", "updatedAt", "ownerId") FROM stdin;
\.


--
-- Data for Name: TenantSettings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."TenantSettings" (id, "tenantId", "businessAddress", "businessPhone", "businessEmail", "businessLicense", "vatNumber", "defaultTaxRate", currency, "enableSmsReminders", "enableEmailReminders", "reminderHoursBefore", "defaultAppointmentDuration", "workingHoursStart", "workingHoursEnd", "workingDays", "enableOnlineBooking", "receiptTemplate", "prescriptionTemplate", "createdAt", "updatedAt", "communicationCredits", "emailCostPerMessage", "monthlyEmailBudget", "monthlySmsBudget", "smsCostPerMessage", "businessTaxId") FROM stdin;
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."User" (id, "tenantId", email, password, "firstName", "lastName", "firstNameHe", "lastNameHe", role, active, "createdAt", "updatedAt", "lastLoginAt", "branchId") FROM stdin;
\.


--
-- Data for Name: UserSettings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."UserSettings" (id, "tenantId", "userId", phone, "preferredLanguage", theme, "emailNotifications", "smsNotifications", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: VATRate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."VATRate" (id, "tenantId", "effectiveFrom", "effectiveTo", rate, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: VisionTest; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."VisionTest" (id, "tenantId", "customerId", "examinerId", "testDate", "testType", "rightEye", "leftEye", binocular, notes, "createdAt", "branchId") FROM stdin;
\.


--
-- Data for Name: Wishlist; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Wishlist" (id, "tenantId", "userId", name, description, "isDefault", "isPublic", "shareToken", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: WishlistItem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."WishlistItem" (id, "wishlistId", "itemType", "itemId", "collectionId", "supplierId", "productName", "productBrand", "productPrice", "productImage", "notifyOnSale", "notifyOnStock", notes, priority, "addedAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: WishlistShare; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."WishlistShare" (id, "wishlistId", "sharedWith", "sharedBy", "accessLevel", "viewCount", "lastViewedAt", "createdAt", "expiresAt") FROM stdin;
\.


--
-- Data for Name: WorkLab; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."WorkLab" (id, "tenantId", "labId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: WorkLabel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."WorkLabel" (id, "tenantId", "labelId", name, "itemCode", "supplierId", "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: WorkOrder; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."WorkOrder" (id, "tenantId", "branchId", "workOrderNumber", "orderDate", "dueDate", "customerId", "saleId", "prescriptionId", "orderType", priority, status, "labStatus", "labOrderNumber", "labId", "supplierId", "sentToLabDate", "receivedDate", "deliveredDate", "frameId", "frameModel", "frameColor", "frameSize", "rightLensId", "rightLensType", "rightLensMaterial", "rightLensCoating", "rightLensTint", "rightLensDetails", "leftLensId", "leftLensType", "leftLensMaterial", "leftLensCoating", "leftLensTint", "leftLensDetails", "rightSphere", "rightCylinder", "rightAxis", "rightAdd", "rightPrism", "rightPrismBase", "leftSphere", "leftCylinder", "leftAxis", "leftAdd", "leftPrism", "leftPrismBase", pd, "specialInstructions", "internalNotes", "labNotes", "qcCheckedBy", "qcCheckedDate", "qcNotes", remake, "remakeReason", "originalOrderId", "frameCost", "rightLensCost", "leftLensCost", "labCharges", "totalCost", "createdBy", "updatedBy", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: WorkOrderStatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."WorkOrderStatus" (id, "tenantId", "workOrderId", status, notes, "changedBy", "changedAt") FROM stdin;
\.


--
-- Data for Name: WorkStatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."WorkStatus" (id, "tenantId", "statusId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: WorkSupplier; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."WorkSupplier" (id, "tenantId", "supplierId", name, "itemCode", "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: WorkSupplyType; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."WorkSupplyType" (id, "tenantId", "supplyTypeId", name, description, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ZipCode; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ZipCode" (id, "zipCode", city, "cityHe", street, "streetHe", region, "createdAt") FROM stdin;
\.


--
-- Data for Name: _DiscountToItems; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."_DiscountToItems" ("A", "B") FROM stdin;
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
354fd889-6fb4-4c41-bd21-05a529feb642	1cf22414bda7f121d26ce6e06e2781f0d3891df7b4dec4e451fdf61520bfedd8	2025-10-30 16:20:40.256368+05:30	20251007092122_new_optitech_dev	\N	\N	2025-10-30 16:20:39.579708+05:30	1
7b4b1c34-d927-4b3f-a176-738aaf71dc46	a4ae0dec75453db35ad5455f22c0bd3431a82e3ce9fce5f9b591491aec35b024	2025-10-30 16:20:40.259855+05:30	20251013094912_dev1	\N	\N	2025-10-30 16:20:40.257212+05:30	1
64f9f1e6-cc42-47d7-a48b-ed16e379bb84	63fea5c9c8c28d224c628d23292ac7f29611b0a32991a8d8662f1cd74be4cca9	2025-10-30 16:20:40.263412+05:30	20251013102810_dev3	\N	\N	2025-10-30 16:20:40.26046+05:30	1
51760d62-e4fe-494f-9075-8eb4700b7006	0a0d3f46598f4ca41fb30f044050b25f87bd5dd8b7b742d73a05f4fa24dbf758	2025-10-30 16:20:40.411142+05:30	20251015054111_dev2	\N	\N	2025-10-30 16:20:40.264101+05:30	1
4df89315-97aa-4e2d-9221-32d17165c99a	ff03d8d18d705df8baa75523c024b38a5b4d3a92d7c6d251ca25dac2faec5938	2025-10-30 16:20:40.416485+05:30	20251015054232_dev2	\N	\N	2025-10-30 16:20:40.41186+05:30	1
8d581f40-a6c6-499b-8ffa-fa7972e42d02	aaa994fa7254572c4332621c5b68fd3edfacc59bc2c4868b86ccf8b2af35d77a	2025-10-30 16:20:40.420964+05:30	20251015064316_dev2	\N	\N	2025-10-30 16:20:40.417419+05:30	1
632515f8-87bd-42ec-bf7a-873403237d5e	d2e432029ee8d89d8c00e2c13b5cc2ce5f97803b559fd5d7469785312ba77368	2025-10-30 16:20:41.008987+05:30	20251016070738_dev2	\N	\N	2025-10-30 16:20:40.423936+05:30	1
d593ab93-e2d2-4901-ab3f-19bb8fbabab6	d788f8596ffbec4a3722e163552e224e9bea7cd346e91e66728b4f4a71635bc3	2025-10-30 16:20:41.068999+05:30	20251027074717_dev4	\N	\N	2025-10-30 16:20:41.009958+05:30	1
5ebd5bae-961c-4b50-add9-9a4b2968c9e2	6b77e9230bf52b231bfef720839ced0de8e34073b37481a437a2bce18b43b846	2025-10-30 16:20:41.071065+05:30	20251027093716_dev1	\N	\N	2025-10-30 16:20:41.069473+05:30	1
06a4beb9-14b5-4ba1-83b2-55c7cd8d4869	48f87fe353797c24c506d62fb7de54fb0656d4bb225204c5f52e2b9ba1a4a8d8	2025-10-30 16:20:41.073782+05:30	20251030055314_dev5	\N	\N	2025-10-30 16:20:41.071597+05:30	1
270a3464-a223-4e88-abc4-088651f7a6a6	e4b0a3baf8438ae291341cd7ca21ab20b87d6d9f3958ee5eb3079df3a5eb3cb8	2025-10-30 16:20:46.804841+05:30	20251030105046_dev6	\N	\N	2025-10-30 16:20:46.802783+05:30	1
\.


--
-- Name: AISuggestion AISuggestion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AISuggestion"
    ADD CONSTRAINT "AISuggestion_pkey" PRIMARY KEY (id);


--
-- Name: AddressLookup AddressLookup_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AddressLookup"
    ADD CONSTRAINT "AddressLookup_pkey" PRIMARY KEY (id);


--
-- Name: AdvancedExamination AdvancedExamination_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AdvancedExamination"
    ADD CONSTRAINT "AdvancedExamination_pkey" PRIMARY KEY (id);


--
-- Name: ApplicationSetting ApplicationSetting_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ApplicationSetting"
    ADD CONSTRAINT "ApplicationSetting_pkey" PRIMARY KEY (id);


--
-- Name: Appointment Appointment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Appointment"
    ADD CONSTRAINT "Appointment_pkey" PRIMARY KEY (id);


--
-- Name: AuditLog AuditLog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AuditLog"
    ADD CONSTRAINT "AuditLog_pkey" PRIMARY KEY (id);


--
-- Name: BarcodeManagement BarcodeManagement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BarcodeManagement"
    ADD CONSTRAINT "BarcodeManagement_pkey" PRIMARY KEY (id);


--
-- Name: Base Base_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Base"
    ADD CONSTRAINT "Base_pkey" PRIMARY KEY (id);


--
-- Name: BisData BisData_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BisData"
    ADD CONSTRAINT "BisData_pkey" PRIMARY KEY (id);


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
-- Name: BusinessContact BusinessContact_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BusinessContact"
    ADD CONSTRAINT "BusinessContact_pkey" PRIMARY KEY (id);


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
-- Name: ChatChannelMember ChatChannelMember_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatChannelMember"
    ADD CONSTRAINT "ChatChannelMember_pkey" PRIMARY KEY (id);


--
-- Name: ChatChannel ChatChannel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatChannel"
    ADD CONSTRAINT "ChatChannel_pkey" PRIMARY KEY (id);


--
-- Name: ChatMessageTemplate ChatMessageTemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatMessageTemplate"
    ADD CONSTRAINT "ChatMessageTemplate_pkey" PRIMARY KEY (id);


--
-- Name: ChatMessage ChatMessage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatMessage"
    ADD CONSTRAINT "ChatMessage_pkey" PRIMARY KEY (id);


--
-- Name: ChatNotification ChatNotification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatNotification"
    ADD CONSTRAINT "ChatNotification_pkey" PRIMARY KEY (id);


--
-- Name: ChatRoomMember ChatRoomMember_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatRoomMember"
    ADD CONSTRAINT "ChatRoomMember_pkey" PRIMARY KEY (id);


--
-- Name: ChatRoom ChatRoom_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatRoom"
    ADD CONSTRAINT "ChatRoom_pkey" PRIMARY KEY (id);


--
-- Name: ChatSearch ChatSearch_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatSearch"
    ADD CONSTRAINT "ChatSearch_pkey" PRIMARY KEY (id);


--
-- Name: ChatTyping ChatTyping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatTyping"
    ADD CONSTRAINT "ChatTyping_pkey" PRIMARY KEY (id);


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
-- Name: ClinicalData ClinicalData_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalData"
    ADD CONSTRAINT "ClinicalData_pkey" PRIMARY KEY (id);


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
-- Name: ClinicalImage ClinicalImage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalImage"
    ADD CONSTRAINT "ClinicalImage_pkey" PRIMARY KEY (id);


--
-- Name: ClinicalProtocol ClinicalProtocol_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalProtocol"
    ADD CONSTRAINT "ClinicalProtocol_pkey" PRIMARY KEY (id);


--
-- Name: ClinicalReferral ClinicalReferral_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalReferral"
    ADD CONSTRAINT "ClinicalReferral_pkey" PRIMARY KEY (id);


--
-- Name: ClinicalRuleTrigger ClinicalRuleTrigger_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalRuleTrigger"
    ADD CONSTRAINT "ClinicalRuleTrigger_pkey" PRIMARY KEY (id);


--
-- Name: ClinicalRule ClinicalRule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalRule"
    ADD CONSTRAINT "ClinicalRule_pkey" PRIMARY KEY (id);


--
-- Name: ClndrSal ClndrSal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClndrSal"
    ADD CONSTRAINT "ClndrSal_pkey" PRIMARY KEY (id);


--
-- Name: ClndrTasksPriority ClndrTasksPriority_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClndrTasksPriority"
    ADD CONSTRAINT "ClndrTasksPriority_pkey" PRIMARY KEY (id);


--
-- Name: ClndrWrk ClndrWrk_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClndrWrk"
    ADD CONSTRAINT "ClndrWrk_pkey" PRIMARY KEY (id);


--
-- Name: CollectionItem CollectionItem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CollectionItem"
    ADD CONSTRAINT "CollectionItem_pkey" PRIMARY KEY (id);


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
-- Name: ContactLensPricing ContactLensPricing_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensPricing"
    ADD CONSTRAINT "ContactLensPricing_pkey" PRIMARY KEY (id);


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
-- Name: ConversationParticipant ConversationParticipant_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ConversationParticipant"
    ADD CONSTRAINT "ConversationParticipant_pkey" PRIMARY KEY (id);


--
-- Name: ConversationTyping ConversationTyping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ConversationTyping"
    ADD CONSTRAINT "ConversationTyping_pkey" PRIMARY KEY (id);


--
-- Name: Conversation Conversation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Conversation"
    ADD CONSTRAINT "Conversation_pkey" PRIMARY KEY (id);


--
-- Name: CrdBuysWorkLab CrdBuysWorkLab_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdBuysWorkLab"
    ADD CONSTRAINT "CrdBuysWorkLab_pkey" PRIMARY KEY (id);


--
-- Name: CrdBuysWorkSapak CrdBuysWorkSapak_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdBuysWorkSapak"
    ADD CONSTRAINT "CrdBuysWorkSapak_pkey" PRIMARY KEY (id);


--
-- Name: CrdBuysWorkStat CrdBuysWorkStat_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdBuysWorkStat"
    ADD CONSTRAINT "CrdBuysWorkStat_pkey" PRIMARY KEY (id);


--
-- Name: CrdBuysWorkSupply CrdBuysWorkSupply_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdBuysWorkSupply"
    ADD CONSTRAINT "CrdBuysWorkSupply_pkey" PRIMARY KEY (id);


--
-- Name: CrdBuysWorkType CrdBuysWorkType_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdBuysWorkType"
    ADD CONSTRAINT "CrdBuysWorkType_pkey" PRIMARY KEY (id);


--
-- Name: CrdClensChecksMater CrdClensChecksMater_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensChecksMater"
    ADD CONSTRAINT "CrdClensChecksMater_pkey" PRIMARY KEY (id);


--
-- Name: CrdClensChecksPr CrdClensChecksPr_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensChecksPr"
    ADD CONSTRAINT "CrdClensChecksPr_pkey" PRIMARY KEY (id);


--
-- Name: CrdClensChecksTint CrdClensChecksTint_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensChecksTint"
    ADD CONSTRAINT "CrdClensChecksTint_pkey" PRIMARY KEY (id);


--
-- Name: CrdClensManuf CrdClensManuf_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensManuf"
    ADD CONSTRAINT "CrdClensManuf_pkey" PRIMARY KEY (id);


--
-- Name: CrdClensSolClean CrdClensSolClean_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensSolClean"
    ADD CONSTRAINT "CrdClensSolClean_pkey" PRIMARY KEY (id);


--
-- Name: CrdClensSolDisinfect CrdClensSolDisinfect_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensSolDisinfect"
    ADD CONSTRAINT "CrdClensSolDisinfect_pkey" PRIMARY KEY (id);


--
-- Name: CrdClensSolRinse CrdClensSolRinse_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensSolRinse"
    ADD CONSTRAINT "CrdClensSolRinse_pkey" PRIMARY KEY (id);


--
-- Name: CrdClensType CrdClensType_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensType"
    ADD CONSTRAINT "CrdClensType_pkey" PRIMARY KEY (id);


--
-- Name: CrdGlassIOPInst CrdGlassIOPInst_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdGlassIOPInst"
    ADD CONSTRAINT "CrdGlassIOPInst_pkey" PRIMARY KEY (id);


--
-- Name: CrdGlassRetDist CrdGlassRetDist_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdGlassRetDist"
    ADD CONSTRAINT "CrdGlassRetDist_pkey" PRIMARY KEY (id);


--
-- Name: CrdGlassRetType CrdGlassRetType_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdGlassRetType"
    ADD CONSTRAINT "CrdGlassRetType_pkey" PRIMARY KEY (id);


--
-- Name: CrdGlassUse CrdGlassUse_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdGlassUse"
    ADD CONSTRAINT "CrdGlassUse_pkey" PRIMARY KEY (id);


--
-- Name: CreditCardTransaction CreditCardTransaction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CreditCardTransaction"
    ADD CONSTRAINT "CreditCardTransaction_pkey" PRIMARY KEY (id);


--
-- Name: CreditCard CreditCard_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CreditCard"
    ADD CONSTRAINT "CreditCard_pkey" PRIMARY KEY (id);


--
-- Name: CreditType CreditType_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CreditType"
    ADD CONSTRAINT "CreditType_pkey" PRIMARY KEY (id);


--
-- Name: CustomReport CustomReport_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CustomReport"
    ADD CONSTRAINT "CustomReport_pkey" PRIMARY KEY (id);


--
-- Name: CustomerGroup CustomerGroup_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CustomerGroup"
    ADD CONSTRAINT "CustomerGroup_pkey" PRIMARY KEY (id);


--
-- Name: CustomerLastVisit CustomerLastVisit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CustomerLastVisit"
    ADD CONSTRAINT "CustomerLastVisit_pkey" PRIMARY KEY (id);


--
-- Name: CustomerOrder CustomerOrder_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CustomerOrder"
    ADD CONSTRAINT "CustomerOrder_pkey" PRIMARY KEY (id);


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
-- Name: DataMigrationError DataMigrationError_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DataMigrationError"
    ADD CONSTRAINT "DataMigrationError_pkey" PRIMARY KEY (id);


--
-- Name: DataMigrationRun DataMigrationRun_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DataMigrationRun"
    ADD CONSTRAINT "DataMigrationRun_pkey" PRIMARY KEY (id);


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
-- Name: DiseaseDiagnosis DiseaseDiagnosis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DiseaseDiagnosis"
    ADD CONSTRAINT "DiseaseDiagnosis_pkey" PRIMARY KEY (id);


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
-- Name: Dummy Dummy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Dummy"
    ADD CONSTRAINT "Dummy_pkey" PRIMARY KEY (id);


--
-- Name: EmployeeCommissionRule EmployeeCommissionRule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EmployeeCommissionRule"
    ADD CONSTRAINT "EmployeeCommissionRule_pkey" PRIMARY KEY (id);


--
-- Name: EquipmentConfig EquipmentConfig_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EquipmentConfig"
    ADD CONSTRAINT "EquipmentConfig_pkey" PRIMARY KEY (id);


--
-- Name: EquipmentImportLog EquipmentImportLog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EquipmentImportLog"
    ADD CONSTRAINT "EquipmentImportLog_pkey" PRIMARY KEY (id);


--
-- Name: ExamTemplate ExamTemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ExamTemplate"
    ADD CONSTRAINT "ExamTemplate_pkey" PRIMARY KEY (id);


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
-- Name: Eye Eye_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Eye"
    ADD CONSTRAINT "Eye_pkey" PRIMARY KEY (id);


--
-- Name: FRPLine FRPLine_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FRPLine"
    ADD CONSTRAINT "FRPLine_pkey" PRIMARY KEY (id);


--
-- Name: FamilyAuditLog FamilyAuditLog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FamilyAuditLog"
    ADD CONSTRAINT "FamilyAuditLog_pkey" PRIMARY KEY (id);


--
-- Name: FamilyRelationship FamilyRelationship_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FamilyRelationship"
    ADD CONSTRAINT "FamilyRelationship_pkey" PRIMARY KEY (id);


--
-- Name: FaxCommunication FaxCommunication_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FaxCommunication"
    ADD CONSTRAINT "FaxCommunication_pkey" PRIMARY KEY (id);


--
-- Name: FollowUpReminder FollowUpReminder_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FollowUpReminder"
    ADD CONSTRAINT "FollowUpReminder_pkey" PRIMARY KEY (id);


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
-- Name: FrameData FrameData_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FrameData"
    ADD CONSTRAINT "FrameData_pkey" PRIMARY KEY (id);


--
-- Name: FrameTrial FrameTrial_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FrameTrial"
    ADD CONSTRAINT "FrameTrial_pkey" PRIMARY KEY (id);


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
-- Name: Household Household_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Household"
    ADD CONSTRAINT "Household_pkey" PRIMARY KEY (id);


--
-- Name: InvMoveType InvMoveType_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InvMoveType"
    ADD CONSTRAINT "InvMoveType_pkey" PRIMARY KEY (id);


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
-- Name: InventoryReference InventoryReference_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InventoryReference"
    ADD CONSTRAINT "InventoryReference_pkey" PRIMARY KEY (id);


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
-- Name: InvoiceType InvoiceType_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InvoiceType"
    ADD CONSTRAINT "InvoiceType_pkey" PRIMARY KEY (id);


--
-- Name: InvoiceVerification InvoiceVerification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InvoiceVerification"
    ADD CONSTRAINT "InvoiceVerification_pkey" PRIMARY KEY (id);


--
-- Name: Invoice Invoice_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Invoice"
    ADD CONSTRAINT "Invoice_pkey" PRIMARY KEY (id);


--
-- Name: ItemCountsYear ItemCountsYear_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ItemCountsYear"
    ADD CONSTRAINT "ItemCountsYear_pkey" PRIMARY KEY (id);


--
-- Name: ItemStatus ItemStatus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ItemStatus"
    ADD CONSTRAINT "ItemStatus_pkey" PRIMARY KEY (id);


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
-- Name: Lang Lang_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Lang"
    ADD CONSTRAINT "Lang_pkey" PRIMARY KEY (id);


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
-- Name: LensSolution LensSolution_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LensSolution"
    ADD CONSTRAINT "LensSolution_pkey" PRIMARY KEY (id);


--
-- Name: LensTreatmentCharacteristic LensTreatmentCharacteristic_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LensTreatmentCharacteristic"
    ADD CONSTRAINT "LensTreatmentCharacteristic_pkey" PRIMARY KEY (id);


--
-- Name: LensTreatment LensTreatment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LensTreatment"
    ADD CONSTRAINT "LensTreatment_pkey" PRIMARY KEY (id);


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
-- Name: MessageAttachment MessageAttachment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MessageAttachment"
    ADD CONSTRAINT "MessageAttachment_pkey" PRIMARY KEY (id);


--
-- Name: MessageTemplate MessageTemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MessageTemplate"
    ADD CONSTRAINT "MessageTemplate_pkey" PRIMARY KEY (id);


--
-- Name: Message Message_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Message"
    ADD CONSTRAINT "Message_pkey" PRIMARY KEY (id);


--
-- Name: MigrationLog MigrationLog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MigrationLog"
    ADD CONSTRAINT "MigrationLog_pkey" PRIMARY KEY (id);


--
-- Name: MigrationRun MigrationRun_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MigrationRun"
    ADD CONSTRAINT "MigrationRun_pkey" PRIMARY KEY (id);


--
-- Name: MigrationTableResult MigrationTableResult_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MigrationTableResult"
    ADD CONSTRAINT "MigrationTableResult_pkey" PRIMARY KEY (id);


--
-- Name: MovementProperty MovementProperty_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MovementProperty"
    ADD CONSTRAINT "MovementProperty_pkey" PRIMARY KEY (id);


--
-- Name: MovementType MovementType_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MovementType"
    ADD CONSTRAINT "MovementType_pkey" PRIMARY KEY (id);


--
-- Name: NewProduct NewProduct_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."NewProduct"
    ADD CONSTRAINT "NewProduct_pkey" PRIMARY KEY (id);


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
-- Name: POSAuditLog POSAuditLog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POSAuditLog"
    ADD CONSTRAINT "POSAuditLog_pkey" PRIMARY KEY (id);


--
-- Name: POSCashDrop POSCashDrop_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POSCashDrop"
    ADD CONSTRAINT "POSCashDrop_pkey" PRIMARY KEY (id);


--
-- Name: POSCashPickup POSCashPickup_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POSCashPickup"
    ADD CONSTRAINT "POSCashPickup_pkey" PRIMARY KEY (id);


--
-- Name: POSInventoryMovement POSInventoryMovement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POSInventoryMovement"
    ADD CONSTRAINT "POSInventoryMovement_pkey" PRIMARY KEY (id);


--
-- Name: POSPaymentRefund POSPaymentRefund_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POSPaymentRefund"
    ADD CONSTRAINT "POSPaymentRefund_pkey" PRIMARY KEY (id);


--
-- Name: POSPayment POSPayment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POSPayment"
    ADD CONSTRAINT "POSPayment_pkey" PRIMARY KEY (id);


--
-- Name: POSPriceListItem POSPriceListItem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POSPriceListItem"
    ADD CONSTRAINT "POSPriceListItem_pkey" PRIMARY KEY (id);


--
-- Name: POSPriceList POSPriceList_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POSPriceList"
    ADD CONSTRAINT "POSPriceList_pkey" PRIMARY KEY (id);


--
-- Name: POSReceipt POSReceipt_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POSReceipt"
    ADD CONSTRAINT "POSReceipt_pkey" PRIMARY KEY (id);


--
-- Name: POSReportSnapshot POSReportSnapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POSReportSnapshot"
    ADD CONSTRAINT "POSReportSnapshot_pkey" PRIMARY KEY (id);


--
-- Name: POSSession POSSession_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POSSession"
    ADD CONSTRAINT "POSSession_pkey" PRIMARY KEY (id);


--
-- Name: POSSyncQueue POSSyncQueue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POSSyncQueue"
    ADD CONSTRAINT "POSSyncQueue_pkey" PRIMARY KEY (id);


--
-- Name: POSTerminal POSTerminal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POSTerminal"
    ADD CONSTRAINT "POSTerminal_pkey" PRIMARY KEY (id);


--
-- Name: POSTransactionDiscount POSTransactionDiscount_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POSTransactionDiscount"
    ADD CONSTRAINT "POSTransactionDiscount_pkey" PRIMARY KEY (id);


--
-- Name: POSTransactionEvent POSTransactionEvent_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POSTransactionEvent"
    ADD CONSTRAINT "POSTransactionEvent_pkey" PRIMARY KEY (id);


--
-- Name: POSTransactionItem POSTransactionItem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POSTransactionItem"
    ADD CONSTRAINT "POSTransactionItem_pkey" PRIMARY KEY (id);


--
-- Name: POSTransactionTax POSTransactionTax_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POSTransactionTax"
    ADD CONSTRAINT "POSTransactionTax_pkey" PRIMARY KEY (id);


--
-- Name: POSTransaction POSTransaction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POSTransaction"
    ADD CONSTRAINT "POSTransaction_pkey" PRIMARY KEY (id);


--
-- Name: PayType PayType_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PayType"
    ADD CONSTRAINT "PayType_pkey" PRIMARY KEY (id);


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
-- Name: PrintLabel PrintLabel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PrintLabel"
    ADD CONSTRAINT "PrintLabel_pkey" PRIMARY KEY (id);


--
-- Name: PrlType PrlType_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PrlType"
    ADD CONSTRAINT "PrlType_pkey" PRIMARY KEY (id);


--
-- Name: ProductProperty ProductProperty_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductProperty"
    ADD CONSTRAINT "ProductProperty_pkey" PRIMARY KEY (id);


--
-- Name: ProductReview ProductReview_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductReview"
    ADD CONSTRAINT "ProductReview_pkey" PRIMARY KEY (id);


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
-- Name: Profile Profile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Profile"
    ADD CONSTRAINT "Profile_pkey" PRIMARY KEY (id);


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
-- Name: ReferralSource ReferralSource_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ReferralSource"
    ADD CONSTRAINT "ReferralSource_pkey" PRIMARY KEY (id);


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
-- Name: ReviewHelpful ReviewHelpful_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ReviewHelpful"
    ADD CONSTRAINT "ReviewHelpful_pkey" PRIMARY KEY (id);


--
-- Name: ReviewReport ReviewReport_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ReviewReport"
    ADD CONSTRAINT "ReviewReport_pkey" PRIMARY KEY (id);


--
-- Name: SMSLen SMSLen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SMSLen"
    ADD CONSTRAINT "SMSLen_pkey" PRIMARY KEY (id);


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
-- Name: SapakComment SapakComment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SapakComment"
    ADD CONSTRAINT "SapakComment_pkey" PRIMARY KEY (id);


--
-- Name: SapakDest SapakDest_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SapakDest"
    ADD CONSTRAINT "SapakDest_pkey" PRIMARY KEY (id);


--
-- Name: SapakPerComment SapakPerComment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SapakPerComment"
    ADD CONSTRAINT "SapakPerComment_pkey" PRIMARY KEY (id);


--
-- Name: SearchOrder SearchOrder_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SearchOrder"
    ADD CONSTRAINT "SearchOrder_pkey" PRIMARY KEY (id);


--
-- Name: ServiceType ServiceType_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ServiceType"
    ADD CONSTRAINT "ServiceType_pkey" PRIMARY KEY (id);


--
-- Name: ShortCut ShortCut_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShortCut"
    ADD CONSTRAINT "ShortCut_pkey" PRIMARY KEY (id);


--
-- Name: SlitLampExam SlitLampExam_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SlitLampExam"
    ADD CONSTRAINT "SlitLampExam_pkey" PRIMARY KEY (id);


--
-- Name: SpecialName SpecialName_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SpecialName"
    ADD CONSTRAINT "SpecialName_pkey" PRIMARY KEY (id);


--
-- Name: Special Special_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Special"
    ADD CONSTRAINT "Special_pkey" PRIMARY KEY (id);


--
-- Name: StaffSchedule StaffSchedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."StaffSchedule"
    ADD CONSTRAINT "StaffSchedule_pkey" PRIMARY KEY (id);


--
-- Name: StockMovement StockMovement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."StockMovement"
    ADD CONSTRAINT "StockMovement_pkey" PRIMARY KEY (id);


--
-- Name: SupplierAccountTransaction SupplierAccountTransaction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierAccountTransaction"
    ADD CONSTRAINT "SupplierAccountTransaction_pkey" PRIMARY KEY (id);


--
-- Name: SupplierAnalytics SupplierAnalytics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierAnalytics"
    ADD CONSTRAINT "SupplierAnalytics_pkey" PRIMARY KEY (id);


--
-- Name: SupplierCatalogCategory SupplierCatalogCategory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierCatalogCategory"
    ADD CONSTRAINT "SupplierCatalogCategory_pkey" PRIMARY KEY (id);


--
-- Name: SupplierCatalogItem SupplierCatalogItem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierCatalogItem"
    ADD CONSTRAINT "SupplierCatalogItem_pkey" PRIMARY KEY (id);


--
-- Name: SupplierCatalogVariant SupplierCatalogVariant_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierCatalogVariant"
    ADD CONSTRAINT "SupplierCatalogVariant_pkey" PRIMARY KEY (id);


--
-- Name: SupplierCollectionVisibility SupplierCollectionVisibility_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierCollectionVisibility"
    ADD CONSTRAINT "SupplierCollectionVisibility_pkey" PRIMARY KEY (id);


--
-- Name: SupplierCollection SupplierCollection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierCollection"
    ADD CONSTRAINT "SupplierCollection_pkey" PRIMARY KEY (id);


--
-- Name: SupplierDiscountUsage SupplierDiscountUsage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierDiscountUsage"
    ADD CONSTRAINT "SupplierDiscountUsage_pkey" PRIMARY KEY (id);


--
-- Name: SupplierDiscount SupplierDiscount_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierDiscount"
    ADD CONSTRAINT "SupplierDiscount_pkey" PRIMARY KEY (id);


--
-- Name: SupplierInventoryLog SupplierInventoryLog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierInventoryLog"
    ADD CONSTRAINT "SupplierInventoryLog_pkey" PRIMARY KEY (id);


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
-- Name: SupplierPriceAlert SupplierPriceAlert_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierPriceAlert"
    ADD CONSTRAINT "SupplierPriceAlert_pkey" PRIMARY KEY (id);


--
-- Name: SupplierPriceCache SupplierPriceCache_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierPriceCache"
    ADD CONSTRAINT "SupplierPriceCache_pkey" PRIMARY KEY (id);


--
-- Name: SupplierPriceHistory SupplierPriceHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierPriceHistory"
    ADD CONSTRAINT "SupplierPriceHistory_pkey" PRIMARY KEY (id);


--
-- Name: SupplierPriceListItem SupplierPriceListItem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierPriceListItem"
    ADD CONSTRAINT "SupplierPriceListItem_pkey" PRIMARY KEY (id);


--
-- Name: SupplierPriceList SupplierPriceList_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierPriceList"
    ADD CONSTRAINT "SupplierPriceList_pkey" PRIMARY KEY (id);


--
-- Name: SupplierRFQItem SupplierRFQItem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierRFQItem"
    ADD CONSTRAINT "SupplierRFQItem_pkey" PRIMARY KEY (id);


--
-- Name: SupplierRFQ SupplierRFQ_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierRFQ"
    ADD CONSTRAINT "SupplierRFQ_pkey" PRIMARY KEY (id);


--
-- Name: SupplierShipment SupplierShipment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierShipment"
    ADD CONSTRAINT "SupplierShipment_pkey" PRIMARY KEY (id);


--
-- Name: SupplierStockAlert SupplierStockAlert_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierStockAlert"
    ADD CONSTRAINT "SupplierStockAlert_pkey" PRIMARY KEY (id);


--
-- Name: SupplierTenantAccount SupplierTenantAccount_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierTenantAccount"
    ADD CONSTRAINT "SupplierTenantAccount_pkey" PRIMARY KEY (id);


--
-- Name: SupplierTenantActivity SupplierTenantActivity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierTenantActivity"
    ADD CONSTRAINT "SupplierTenantActivity_pkey" PRIMARY KEY (id);


--
-- Name: SupplierTenantNote SupplierTenantNote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierTenantNote"
    ADD CONSTRAINT "SupplierTenantNote_pkey" PRIMARY KEY (id);


--
-- Name: SupplierUser SupplierUser_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierUser"
    ADD CONSTRAINT "SupplierUser_pkey" PRIMARY KEY (id);


--
-- Name: Supplier Supplier_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Supplier"
    ADD CONSTRAINT "Supplier_pkey" PRIMARY KEY (id);


--
-- Name: SysLevel SysLevel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SysLevel"
    ADD CONSTRAINT "SysLevel_pkey" PRIMARY KEY (id);


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
-- Name: VATRate VATRate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."VATRate"
    ADD CONSTRAINT "VATRate_pkey" PRIMARY KEY (id);


--
-- Name: VisionTest VisionTest_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."VisionTest"
    ADD CONSTRAINT "VisionTest_pkey" PRIMARY KEY (id);


--
-- Name: WishlistItem WishlistItem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WishlistItem"
    ADD CONSTRAINT "WishlistItem_pkey" PRIMARY KEY (id);


--
-- Name: WishlistShare WishlistShare_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WishlistShare"
    ADD CONSTRAINT "WishlistShare_pkey" PRIMARY KEY (id);


--
-- Name: Wishlist Wishlist_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Wishlist"
    ADD CONSTRAINT "Wishlist_pkey" PRIMARY KEY (id);


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
-- Name: _DiscountToItems _DiscountToItems_AB_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_DiscountToItems"
    ADD CONSTRAINT "_DiscountToItems_AB_pkey" PRIMARY KEY ("A", "B");


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: AISuggestion_examinationId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "AISuggestion_examinationId_idx" ON public."AISuggestion" USING btree ("examinationId");


--
-- Name: AISuggestion_tenantId_accepted_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "AISuggestion_tenantId_accepted_idx" ON public."AISuggestion" USING btree ("tenantId", accepted);


--
-- Name: AISuggestion_tenantId_suggestionType_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "AISuggestion_tenantId_suggestionType_createdAt_idx" ON public."AISuggestion" USING btree ("tenantId", "suggestionType", "createdAt");


--
-- Name: AddressLookup_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "AddressLookup_branchId_idx" ON public."AddressLookup" USING btree ("branchId");


--
-- Name: AddressLookup_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "AddressLookup_tenantId_idx" ON public."AddressLookup" USING btree ("tenantId");


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
-- Name: ApplicationSetting_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ApplicationSetting_branchId_idx" ON public."ApplicationSetting" USING btree ("branchId");


--
-- Name: ApplicationSetting_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ApplicationSetting_tenantId_idx" ON public."ApplicationSetting" USING btree ("tenantId");


--
-- Name: Appointment_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Appointment_customerId_idx" ON public."Appointment" USING btree ("customerId");


--
-- Name: Appointment_tenantId_branchId_date_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Appointment_tenantId_branchId_date_status_idx" ON public."Appointment" USING btree ("tenantId", "branchId", date, status);


--
-- Name: Appointment_tenantId_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Appointment_tenantId_date_idx" ON public."Appointment" USING btree ("tenantId", date);


--
-- Name: Appointment_tenantId_status_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Appointment_tenantId_status_date_idx" ON public."Appointment" USING btree ("tenantId", status, date);


--
-- Name: Appointment_tenantId_userId_date_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Appointment_tenantId_userId_date_status_idx" ON public."Appointment" USING btree ("tenantId", "userId", date, status);


--
-- Name: AuditLog_action_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "AuditLog_action_createdAt_idx" ON public."AuditLog" USING btree (action, "createdAt");


--
-- Name: AuditLog_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "AuditLog_createdAt_idx" ON public."AuditLog" USING btree ("createdAt");


--
-- Name: AuditLog_resource_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "AuditLog_resource_createdAt_idx" ON public."AuditLog" USING btree (resource, "createdAt");


--
-- Name: AuditLog_tenantId_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "AuditLog_tenantId_createdAt_idx" ON public."AuditLog" USING btree ("tenantId", "createdAt");


--
-- Name: AuditLog_userId_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "AuditLog_userId_createdAt_idx" ON public."AuditLog" USING btree ("userId", "createdAt");


--
-- Name: BarcodeManagement_barcode_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "BarcodeManagement_barcode_idx" ON public."BarcodeManagement" USING btree (barcode);


--
-- Name: BarcodeManagement_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "BarcodeManagement_branchId_idx" ON public."BarcodeManagement" USING btree ("branchId");


--
-- Name: BarcodeManagement_tenantId_barcode_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "BarcodeManagement_tenantId_barcode_key" ON public."BarcodeManagement" USING btree ("tenantId", barcode);


--
-- Name: BarcodeManagement_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "BarcodeManagement_tenantId_idx" ON public."BarcodeManagement" USING btree ("tenantId");


--
-- Name: Base_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Base_branchId_idx" ON public."Base" USING btree ("branchId");


--
-- Name: Base_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Base_tenantId_idx" ON public."Base" USING btree ("tenantId");


--
-- Name: BisData_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "BisData_branchId_idx" ON public."BisData" USING btree ("branchId");


--
-- Name: BisData_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "BisData_tenantId_idx" ON public."BisData" USING btree ("tenantId");


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
-- Name: BusinessContact_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "BusinessContact_branchId_idx" ON public."BusinessContact" USING btree ("branchId");


--
-- Name: BusinessContact_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "BusinessContact_tenantId_idx" ON public."BusinessContact" USING btree ("tenantId");


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
-- Name: ChatChannelMember_channelId_userId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ChatChannelMember_channelId_userId_key" ON public."ChatChannelMember" USING btree ("channelId", "userId");


--
-- Name: ChatChannelMember_tenantId_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ChatChannelMember_tenantId_userId_idx" ON public."ChatChannelMember" USING btree ("tenantId", "userId");


--
-- Name: ChatChannel_patientId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ChatChannel_patientId_idx" ON public."ChatChannel" USING btree ("patientId");


--
-- Name: ChatChannel_tenantId_roomId_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ChatChannel_tenantId_roomId_name_key" ON public."ChatChannel" USING btree ("tenantId", "roomId", name);


--
-- Name: ChatChannel_tenantId_type_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ChatChannel_tenantId_type_idx" ON public."ChatChannel" USING btree ("tenantId", type);


--
-- Name: ChatChannel_visitId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ChatChannel_visitId_idx" ON public."ChatChannel" USING btree ("visitId");


--
-- Name: ChatMessageTemplate_tenantId_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ChatMessageTemplate_tenantId_category_idx" ON public."ChatMessageTemplate" USING btree ("tenantId", category);


--
-- Name: ChatMessageTemplate_tenantId_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ChatMessageTemplate_tenantId_name_key" ON public."ChatMessageTemplate" USING btree ("tenantId", name);


--
-- Name: ChatMessage_channelId_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ChatMessage_channelId_createdAt_idx" ON public."ChatMessage" USING btree ("channelId", "createdAt");


--
-- Name: ChatMessage_readAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ChatMessage_readAt_idx" ON public."ChatMessage" USING btree ("readAt");


--
-- Name: ChatMessage_senderId_senderType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ChatMessage_senderId_senderType_idx" ON public."ChatMessage" USING btree ("senderId", "senderType");


--
-- Name: ChatMessage_threadId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ChatMessage_threadId_idx" ON public."ChatMessage" USING btree ("threadId");


--
-- Name: ChatNotification_tenantId_type_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ChatNotification_tenantId_type_idx" ON public."ChatNotification" USING btree ("tenantId", type);


--
-- Name: ChatNotification_userId_isRead_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ChatNotification_userId_isRead_idx" ON public."ChatNotification" USING btree ("userId", "isRead");


--
-- Name: ChatRoomMember_roomId_userId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ChatRoomMember_roomId_userId_key" ON public."ChatRoomMember" USING btree ("roomId", "userId");


--
-- Name: ChatRoomMember_tenantId_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ChatRoomMember_tenantId_userId_idx" ON public."ChatRoomMember" USING btree ("tenantId", "userId");


--
-- Name: ChatRoom_tenantId_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ChatRoom_tenantId_name_key" ON public."ChatRoom" USING btree ("tenantId", name);


--
-- Name: ChatRoom_tenantId_type_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ChatRoom_tenantId_type_idx" ON public."ChatRoom" USING btree ("tenantId", type);


--
-- Name: ChatSearch_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ChatSearch_createdAt_idx" ON public."ChatSearch" USING btree ("createdAt");


--
-- Name: ChatSearch_tenantId_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ChatSearch_tenantId_userId_idx" ON public."ChatSearch" USING btree ("tenantId", "userId");


--
-- Name: ChatTyping_channelId_userId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ChatTyping_channelId_userId_key" ON public."ChatTyping" USING btree ("channelId", "userId");


--
-- Name: ChatTyping_tenantId_channelId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ChatTyping_tenantId_channelId_idx" ON public."ChatTyping" USING btree ("tenantId", "channelId");


--
-- Name: CheckType_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CheckType_branchId_idx" ON public."CheckType" USING btree ("branchId");


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
-- Name: ClinicalData_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalData_branchId_idx" ON public."ClinicalData" USING btree ("branchId");


--
-- Name: ClinicalData_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalData_tenantId_idx" ON public."ClinicalData" USING btree ("tenantId");


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
-- Name: ClinicalImage_examinationId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalImage_examinationId_idx" ON public."ClinicalImage" USING btree ("examinationId");


--
-- Name: ClinicalImage_tenantId_customerId_captureDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalImage_tenantId_customerId_captureDate_idx" ON public."ClinicalImage" USING btree ("tenantId", "customerId", "captureDate");


--
-- Name: ClinicalImage_tenantId_deletedAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalImage_tenantId_deletedAt_idx" ON public."ClinicalImage" USING btree ("tenantId", "deletedAt");


--
-- Name: ClinicalImage_tenantId_imageType_captureDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalImage_tenantId_imageType_captureDate_idx" ON public."ClinicalImage" USING btree ("tenantId", "imageType", "captureDate");


--
-- Name: ClinicalProtocol_tenantId_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalProtocol_tenantId_isActive_idx" ON public."ClinicalProtocol" USING btree ("tenantId", "isActive");


--
-- Name: ClinicalProtocol_tenantId_protocolType_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalProtocol_tenantId_protocolType_isActive_idx" ON public."ClinicalProtocol" USING btree ("tenantId", "protocolType", "isActive");


--
-- Name: ClinicalReferral_customerId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalReferral_customerId_status_idx" ON public."ClinicalReferral" USING btree ("customerId", status);


--
-- Name: ClinicalReferral_tenantId_referralType_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalReferral_tenantId_referralType_status_idx" ON public."ClinicalReferral" USING btree ("tenantId", "referralType", status);


--
-- Name: ClinicalReferral_tenantId_status_referralDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalReferral_tenantId_status_referralDate_idx" ON public."ClinicalReferral" USING btree ("tenantId", status, "referralDate");


--
-- Name: ClinicalReferral_tenantId_urgency_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalReferral_tenantId_urgency_status_idx" ON public."ClinicalReferral" USING btree ("tenantId", urgency, status);


--
-- Name: ClinicalRuleTrigger_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalRuleTrigger_customerId_idx" ON public."ClinicalRuleTrigger" USING btree ("customerId");


--
-- Name: ClinicalRuleTrigger_examinationId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalRuleTrigger_examinationId_idx" ON public."ClinicalRuleTrigger" USING btree ("examinationId");


--
-- Name: ClinicalRuleTrigger_ruleId_triggeredAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalRuleTrigger_ruleId_triggeredAt_idx" ON public."ClinicalRuleTrigger" USING btree ("ruleId", "triggeredAt");


--
-- Name: ClinicalRuleTrigger_tenantId_status_triggeredAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalRuleTrigger_tenantId_status_triggeredAt_idx" ON public."ClinicalRuleTrigger" USING btree ("tenantId", status, "triggeredAt");


--
-- Name: ClinicalRule_tenantId_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalRule_tenantId_isActive_idx" ON public."ClinicalRule" USING btree ("tenantId", "isActive");


--
-- Name: ClinicalRule_tenantId_ruleType_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClinicalRule_tenantId_ruleType_isActive_idx" ON public."ClinicalRule" USING btree ("tenantId", "ruleType", "isActive");


--
-- Name: ClndrSal_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClndrSal_branchId_idx" ON public."ClndrSal" USING btree ("branchId");


--
-- Name: ClndrSal_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClndrSal_tenantId_idx" ON public."ClndrSal" USING btree ("tenantId");


--
-- Name: ClndrTasksPriority_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClndrTasksPriority_branchId_idx" ON public."ClndrTasksPriority" USING btree ("branchId");


--
-- Name: ClndrTasksPriority_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClndrTasksPriority_tenantId_idx" ON public."ClndrTasksPriority" USING btree ("tenantId");


--
-- Name: ClndrWrk_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClndrWrk_branchId_idx" ON public."ClndrWrk" USING btree ("branchId");


--
-- Name: ClndrWrk_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ClndrWrk_tenantId_idx" ON public."ClndrWrk" USING btree ("tenantId");


--
-- Name: CollectionItem_collectionId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CollectionItem_collectionId_idx" ON public."CollectionItem" USING btree ("collectionId");


--
-- Name: CollectionItem_frameCatalogId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CollectionItem_frameCatalogId_idx" ON public."CollectionItem" USING btree ("frameCatalogId");


--
-- Name: CollectionItem_lensCatalogId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CollectionItem_lensCatalogId_idx" ON public."CollectionItem" USING btree ("lensCatalogId");


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
-- Name: ContactLensPricing_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactLensPricing_branchId_idx" ON public."ContactLensPricing" USING btree ("branchId");


--
-- Name: ContactLensPricing_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ContactLensPricing_tenantId_idx" ON public."ContactLensPricing" USING btree ("tenantId");


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
-- Name: ConversationParticipant_conversationId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ConversationParticipant_conversationId_idx" ON public."ConversationParticipant" USING btree ("conversationId");


--
-- Name: ConversationParticipant_conversationId_participantId_partic_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ConversationParticipant_conversationId_participantId_partic_key" ON public."ConversationParticipant" USING btree ("conversationId", "participantId", "participantType");


--
-- Name: ConversationParticipant_participantId_participantType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ConversationParticipant_participantId_participantType_idx" ON public."ConversationParticipant" USING btree ("participantId", "participantType");


--
-- Name: ConversationTyping_conversationId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ConversationTyping_conversationId_idx" ON public."ConversationTyping" USING btree ("conversationId");


--
-- Name: ConversationTyping_conversationId_typingUserId_typingUserTy_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ConversationTyping_conversationId_typingUserId_typingUserTy_key" ON public."ConversationTyping" USING btree ("conversationId", "typingUserId", "typingUserType");


--
-- Name: Conversation_lastMessageAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Conversation_lastMessageAt_idx" ON public."Conversation" USING btree ("lastMessageAt");


--
-- Name: Conversation_relatedToType_relatedToId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Conversation_relatedToType_relatedToId_idx" ON public."Conversation" USING btree ("relatedToType", "relatedToId");


--
-- Name: Conversation_supplierId_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Conversation_supplierId_tenantId_idx" ON public."Conversation" USING btree ("supplierId", "tenantId");


--
-- Name: CrdBuysWorkLab_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdBuysWorkLab_branchId_idx" ON public."CrdBuysWorkLab" USING btree ("branchId");


--
-- Name: CrdBuysWorkLab_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdBuysWorkLab_tenantId_idx" ON public."CrdBuysWorkLab" USING btree ("tenantId");


--
-- Name: CrdBuysWorkSapak_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdBuysWorkSapak_branchId_idx" ON public."CrdBuysWorkSapak" USING btree ("branchId");


--
-- Name: CrdBuysWorkSapak_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdBuysWorkSapak_tenantId_idx" ON public."CrdBuysWorkSapak" USING btree ("tenantId");


--
-- Name: CrdBuysWorkStat_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdBuysWorkStat_branchId_idx" ON public."CrdBuysWorkStat" USING btree ("branchId");


--
-- Name: CrdBuysWorkStat_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdBuysWorkStat_tenantId_idx" ON public."CrdBuysWorkStat" USING btree ("tenantId");


--
-- Name: CrdBuysWorkSupply_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdBuysWorkSupply_branchId_idx" ON public."CrdBuysWorkSupply" USING btree ("branchId");


--
-- Name: CrdBuysWorkSupply_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdBuysWorkSupply_tenantId_idx" ON public."CrdBuysWorkSupply" USING btree ("tenantId");


--
-- Name: CrdBuysWorkType_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdBuysWorkType_branchId_idx" ON public."CrdBuysWorkType" USING btree ("branchId");


--
-- Name: CrdBuysWorkType_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdBuysWorkType_tenantId_idx" ON public."CrdBuysWorkType" USING btree ("tenantId");


--
-- Name: CrdClensChecksMater_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdClensChecksMater_branchId_idx" ON public."CrdClensChecksMater" USING btree ("branchId");


--
-- Name: CrdClensChecksMater_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdClensChecksMater_tenantId_idx" ON public."CrdClensChecksMater" USING btree ("tenantId");


--
-- Name: CrdClensChecksPr_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdClensChecksPr_branchId_idx" ON public."CrdClensChecksPr" USING btree ("branchId");


--
-- Name: CrdClensChecksPr_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdClensChecksPr_tenantId_idx" ON public."CrdClensChecksPr" USING btree ("tenantId");


--
-- Name: CrdClensChecksTint_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdClensChecksTint_branchId_idx" ON public."CrdClensChecksTint" USING btree ("branchId");


--
-- Name: CrdClensChecksTint_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdClensChecksTint_tenantId_idx" ON public."CrdClensChecksTint" USING btree ("tenantId");


--
-- Name: CrdClensManuf_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdClensManuf_branchId_idx" ON public."CrdClensManuf" USING btree ("branchId");


--
-- Name: CrdClensManuf_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdClensManuf_tenantId_idx" ON public."CrdClensManuf" USING btree ("tenantId");


--
-- Name: CrdClensSolClean_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdClensSolClean_branchId_idx" ON public."CrdClensSolClean" USING btree ("branchId");


--
-- Name: CrdClensSolClean_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdClensSolClean_tenantId_idx" ON public."CrdClensSolClean" USING btree ("tenantId");


--
-- Name: CrdClensSolDisinfect_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdClensSolDisinfect_branchId_idx" ON public."CrdClensSolDisinfect" USING btree ("branchId");


--
-- Name: CrdClensSolDisinfect_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdClensSolDisinfect_tenantId_idx" ON public."CrdClensSolDisinfect" USING btree ("tenantId");


--
-- Name: CrdClensSolRinse_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdClensSolRinse_branchId_idx" ON public."CrdClensSolRinse" USING btree ("branchId");


--
-- Name: CrdClensSolRinse_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdClensSolRinse_tenantId_idx" ON public."CrdClensSolRinse" USING btree ("tenantId");


--
-- Name: CrdClensType_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdClensType_branchId_idx" ON public."CrdClensType" USING btree ("branchId");


--
-- Name: CrdClensType_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdClensType_tenantId_idx" ON public."CrdClensType" USING btree ("tenantId");


--
-- Name: CrdGlassIOPInst_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdGlassIOPInst_branchId_idx" ON public."CrdGlassIOPInst" USING btree ("branchId");


--
-- Name: CrdGlassIOPInst_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdGlassIOPInst_tenantId_idx" ON public."CrdGlassIOPInst" USING btree ("tenantId");


--
-- Name: CrdGlassRetDist_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdGlassRetDist_branchId_idx" ON public."CrdGlassRetDist" USING btree ("branchId");


--
-- Name: CrdGlassRetDist_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdGlassRetDist_tenantId_idx" ON public."CrdGlassRetDist" USING btree ("tenantId");


--
-- Name: CrdGlassRetType_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdGlassRetType_branchId_idx" ON public."CrdGlassRetType" USING btree ("branchId");


--
-- Name: CrdGlassRetType_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdGlassRetType_tenantId_idx" ON public."CrdGlassRetType" USING btree ("tenantId");


--
-- Name: CrdGlassUse_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdGlassUse_branchId_idx" ON public."CrdGlassUse" USING btree ("branchId");


--
-- Name: CrdGlassUse_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CrdGlassUse_tenantId_idx" ON public."CrdGlassUse" USING btree ("tenantId");


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
-- Name: CreditCard_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CreditCard_branchId_idx" ON public."CreditCard" USING btree ("branchId");


--
-- Name: CreditCard_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CreditCard_tenantId_idx" ON public."CreditCard" USING btree ("tenantId");


--
-- Name: CreditType_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CreditType_branchId_idx" ON public."CreditType" USING btree ("branchId");


--
-- Name: CreditType_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CreditType_tenantId_idx" ON public."CreditType" USING btree ("tenantId");


--
-- Name: CustomReport_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CustomReport_branchId_idx" ON public."CustomReport" USING btree ("branchId");


--
-- Name: CustomReport_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CustomReport_tenantId_idx" ON public."CustomReport" USING btree ("tenantId");


--
-- Name: CustomerGroup_tenantId_groupCode_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "CustomerGroup_tenantId_groupCode_key" ON public."CustomerGroup" USING btree ("tenantId", "groupCode");


--
-- Name: CustomerLastVisit_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CustomerLastVisit_customerId_idx" ON public."CustomerLastVisit" USING btree ("customerId");


--
-- Name: CustomerLastVisit_customerId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "CustomerLastVisit_customerId_key" ON public."CustomerLastVisit" USING btree ("customerId");


--
-- Name: CustomerLastVisit_lastVisitDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CustomerLastVisit_lastVisitDate_idx" ON public."CustomerLastVisit" USING btree ("lastVisitDate");


--
-- Name: CustomerLastVisit_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CustomerLastVisit_tenantId_idx" ON public."CustomerLastVisit" USING btree ("tenantId");


--
-- Name: CustomerLastVisit_tenantId_lastVisitDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CustomerLastVisit_tenantId_lastVisitDate_idx" ON public."CustomerLastVisit" USING btree ("tenantId", "lastVisitDate");


--
-- Name: CustomerOrder_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CustomerOrder_branchId_idx" ON public."CustomerOrder" USING btree ("branchId");


--
-- Name: CustomerOrder_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CustomerOrder_tenantId_idx" ON public."CustomerOrder" USING btree ("tenantId");


--
-- Name: CustomerPhoto_tenantId_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "CustomerPhoto_tenantId_customerId_idx" ON public."CustomerPhoto" USING btree ("tenantId", "customerId");


--
-- Name: Customer_customerId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Customer_customerId_key" ON public."Customer" USING btree ("customerId");


--
-- Name: Customer_tenantId_birthDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Customer_tenantId_birthDate_idx" ON public."Customer" USING btree ("tenantId", "birthDate");


--
-- Name: Customer_tenantId_branchId_deletedAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Customer_tenantId_branchId_deletedAt_idx" ON public."Customer" USING btree ("tenantId", "branchId", "deletedAt");


--
-- Name: Customer_tenantId_cellPhone_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Customer_tenantId_cellPhone_idx" ON public."Customer" USING btree ("tenantId", "cellPhone");


--
-- Name: Customer_tenantId_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Customer_tenantId_customerId_idx" ON public."Customer" USING btree ("tenantId", "customerId");


--
-- Name: Customer_tenantId_deletedAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Customer_tenantId_deletedAt_idx" ON public."Customer" USING btree ("tenantId", "deletedAt");


--
-- Name: Customer_tenantId_email_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Customer_tenantId_email_idx" ON public."Customer" USING btree ("tenantId", email);


--
-- Name: Customer_tenantId_lastNameHe_firstNameHe_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Customer_tenantId_lastNameHe_firstNameHe_idx" ON public."Customer" USING btree ("tenantId", "lastNameHe", "firstNameHe");


--
-- Name: Customer_tenantId_lastName_firstName_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Customer_tenantId_lastName_firstName_idx" ON public."Customer" USING btree ("tenantId", "lastName", "firstName");


--
-- Name: DataMigrationError_migrationId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "DataMigrationError_migrationId_idx" ON public."DataMigrationError" USING btree ("migrationId");


--
-- Name: DataMigrationError_timestamp_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "DataMigrationError_timestamp_idx" ON public."DataMigrationError" USING btree ("timestamp");


--
-- Name: DataMigrationRun_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "DataMigrationRun_createdAt_idx" ON public."DataMigrationRun" USING btree ("createdAt");


--
-- Name: DataMigrationRun_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "DataMigrationRun_status_idx" ON public."DataMigrationRun" USING btree (status);


--
-- Name: DataMigrationRun_tenantId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "DataMigrationRun_tenantId_status_idx" ON public."DataMigrationRun" USING btree ("tenantId", status);


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
-- Name: DiseaseDiagnosis_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "DiseaseDiagnosis_branchId_idx" ON public."DiseaseDiagnosis" USING btree ("branchId");


--
-- Name: DiseaseDiagnosis_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "DiseaseDiagnosis_tenantId_idx" ON public."DiseaseDiagnosis" USING btree ("tenantId");


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
-- Name: Dummy_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Dummy_branchId_idx" ON public."Dummy" USING btree ("branchId");


--
-- Name: Dummy_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Dummy_tenantId_idx" ON public."Dummy" USING btree ("tenantId");


--
-- Name: EmployeeCommissionRule_employeeId_ruleId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "EmployeeCommissionRule_employeeId_ruleId_key" ON public."EmployeeCommissionRule" USING btree ("employeeId", "ruleId");


--
-- Name: EmployeeCommissionRule_tenantId_employeeId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "EmployeeCommissionRule_tenantId_employeeId_idx" ON public."EmployeeCommissionRule" USING btree ("tenantId", "employeeId");


--
-- Name: EquipmentConfig_equipmentType_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "EquipmentConfig_equipmentType_isActive_idx" ON public."EquipmentConfig" USING btree ("equipmentType", "isActive");


--
-- Name: EquipmentConfig_tenantId_branchId_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "EquipmentConfig_tenantId_branchId_isActive_idx" ON public."EquipmentConfig" USING btree ("tenantId", "branchId", "isActive");


--
-- Name: EquipmentConfig_tenantId_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "EquipmentConfig_tenantId_isActive_idx" ON public."EquipmentConfig" USING btree ("tenantId", "isActive");


--
-- Name: EquipmentImportLog_equipmentId_importDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "EquipmentImportLog_equipmentId_importDate_idx" ON public."EquipmentImportLog" USING btree ("equipmentId", "importDate");


--
-- Name: EquipmentImportLog_examinationId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "EquipmentImportLog_examinationId_idx" ON public."EquipmentImportLog" USING btree ("examinationId");


--
-- Name: EquipmentImportLog_tenantId_importDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "EquipmentImportLog_tenantId_importDate_idx" ON public."EquipmentImportLog" USING btree ("tenantId", "importDate");


--
-- Name: ExamTemplate_tenantId_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ExamTemplate_tenantId_isActive_idx" ON public."ExamTemplate" USING btree ("tenantId", "isActive");


--
-- Name: ExamTemplate_tenantId_isDefault_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ExamTemplate_tenantId_isDefault_idx" ON public."ExamTemplate" USING btree ("tenantId", "isDefault");


--
-- Name: ExamTemplate_tenantId_templateType_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ExamTemplate_tenantId_templateType_isActive_idx" ON public."ExamTemplate" USING btree ("tenantId", "templateType", "isActive");


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
-- Name: Examination_protocolId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Examination_protocolId_idx" ON public."Examination" USING btree ("protocolId");


--
-- Name: Examination_templateId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Examination_templateId_idx" ON public."Examination" USING btree ("templateId");


--
-- Name: Examination_tenantId_customerId_examDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Examination_tenantId_customerId_examDate_idx" ON public."Examination" USING btree ("tenantId", "customerId", "examDate");


--
-- Name: Examination_tenantId_deletedAt_examDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Examination_tenantId_deletedAt_examDate_idx" ON public."Examination" USING btree ("tenantId", "deletedAt", "examDate");


--
-- Name: Examination_tenantId_doctorId_examDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Examination_tenantId_doctorId_examDate_idx" ON public."Examination" USING btree ("tenantId", "doctorId", "examDate");


--
-- Name: Examination_tenantId_examType_examDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Examination_tenantId_examType_examDate_idx" ON public."Examination" USING btree ("tenantId", "examType", "examDate");


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
-- Name: Eye_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Eye_branchId_idx" ON public."Eye" USING btree ("branchId");


--
-- Name: Eye_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Eye_tenantId_idx" ON public."Eye" USING btree ("tenantId");


--
-- Name: FRPLine_frpId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FRPLine_frpId_idx" ON public."FRPLine" USING btree ("frpId");


--
-- Name: FRPLine_lineDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FRPLine_lineDate_idx" ON public."FRPLine" USING btree ("lineDate");


--
-- Name: FamilyRelationship_tenantId_customerId_relatedCustomerId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "FamilyRelationship_tenantId_customerId_relatedCustomerId_key" ON public."FamilyRelationship" USING btree ("tenantId", "customerId", "relatedCustomerId");


--
-- Name: FaxCommunication_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FaxCommunication_branchId_idx" ON public."FaxCommunication" USING btree ("branchId");


--
-- Name: FaxCommunication_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FaxCommunication_tenantId_idx" ON public."FaxCommunication" USING btree ("tenantId");


--
-- Name: FollowUpReminder_customerId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FollowUpReminder_customerId_status_idx" ON public."FollowUpReminder" USING btree ("customerId", status);


--
-- Name: FollowUpReminder_tenantId_reminderType_dueDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FollowUpReminder_tenantId_reminderType_dueDate_idx" ON public."FollowUpReminder" USING btree ("tenantId", "reminderType", "dueDate");


--
-- Name: FollowUpReminder_tenantId_status_dueDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FollowUpReminder_tenantId_status_dueDate_idx" ON public."FollowUpReminder" USING btree ("tenantId", status, "dueDate");


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
-- Name: FrameData_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FrameData_branchId_idx" ON public."FrameData" USING btree ("branchId");


--
-- Name: FrameData_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FrameData_tenantId_idx" ON public."FrameData" USING btree ("tenantId");


--
-- Name: FrameTrial_checkDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FrameTrial_checkDate_idx" ON public."FrameTrial" USING btree ("checkDate");


--
-- Name: FrameTrial_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FrameTrial_customerId_idx" ON public."FrameTrial" USING btree ("customerId");


--
-- Name: FrameTrial_tenantId_customerId_checkDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FrameTrial_tenantId_customerId_checkDate_idx" ON public."FrameTrial" USING btree ("tenantId", "customerId", "checkDate");


--
-- Name: FrameTrial_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FrameTrial_tenantId_idx" ON public."FrameTrial" USING btree ("tenantId");


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
-- Name: Household_tenantId_householdHash_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Household_tenantId_householdHash_key" ON public."Household" USING btree ("tenantId", "householdHash");


--
-- Name: IDX_POSAuditLog_tenant_action_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSAuditLog_tenant_action_date" ON public."POSAuditLog" USING btree ("tenantId", action, "createdAt");


--
-- Name: IDX_POSAuditLog_tenant_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSAuditLog_tenant_date" ON public."POSAuditLog" USING btree ("tenantId", "createdAt");


--
-- Name: IDX_POSAuditLog_tenant_entity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSAuditLog_tenant_entity" ON public."POSAuditLog" USING btree ("tenantId", "entityType", "entityId");


--
-- Name: IDX_POSAuditLog_tenant_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSAuditLog_tenant_user_date" ON public."POSAuditLog" USING btree ("tenantId", "userId", "createdAt");


--
-- Name: IDX_POSCashDrop_tenant_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSCashDrop_tenant_date" ON public."POSCashDrop" USING btree ("tenantId", "createdAt");


--
-- Name: IDX_POSCashDrop_tenant_shift; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSCashDrop_tenant_shift" ON public."POSCashDrop" USING btree ("tenantId", "shiftId");


--
-- Name: IDX_POSCashPickup_tenant_shift; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSCashPickup_tenant_shift" ON public."POSCashPickup" USING btree ("tenantId", "shiftId");


--
-- Name: IDX_POSInventoryMovement_tenant_branch_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSInventoryMovement_tenant_branch_date" ON public."POSInventoryMovement" USING btree ("tenantId", "branchId", "createdAt");


--
-- Name: IDX_POSInventoryMovement_tenant_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSInventoryMovement_tenant_product" ON public."POSInventoryMovement" USING btree ("tenantId", "productId");


--
-- Name: IDX_POSInventoryMovement_transaction; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSInventoryMovement_transaction" ON public."POSInventoryMovement" USING btree ("transactionId");


--
-- Name: IDX_POSPaymentRefund_payment; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSPaymentRefund_payment" ON public."POSPaymentRefund" USING btree ("paymentId");


--
-- Name: IDX_POSPayment_tenant_method_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSPayment_tenant_method_date" ON public."POSPayment" USING btree ("tenantId", "paymentMethod", "createdAt");


--
-- Name: IDX_POSPayment_tenant_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSPayment_tenant_status" ON public."POSPayment" USING btree ("tenantId", status);


--
-- Name: IDX_POSPayment_tenant_transaction; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSPayment_tenant_transaction" ON public."POSPayment" USING btree ("tenantId", "transactionId");


--
-- Name: IDX_POSPriceListItem_priceList; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSPriceListItem_priceList" ON public."POSPriceListItem" USING btree ("priceListId");


--
-- Name: IDX_POSPriceListItem_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSPriceListItem_product" ON public."POSPriceListItem" USING btree ("productId");


--
-- Name: IDX_POSPriceList_tenant_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSPriceList_tenant_active" ON public."POSPriceList" USING btree ("tenantId", "isActive");


--
-- Name: IDX_POSReceipt_tenant_branch_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSReceipt_tenant_branch_date" ON public."POSReceipt" USING btree ("tenantId", "branchId", "createdAt");


--
-- Name: IDX_POSReceipt_tenant_customer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSReceipt_tenant_customer" ON public."POSReceipt" USING btree ("tenantId", "customerId");


--
-- Name: IDX_POSReceipt_tenant_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSReceipt_tenant_date" ON public."POSReceipt" USING btree ("tenantId", "createdAt");


--
-- Name: IDX_POSReportSnapshot_tenant_branch_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSReportSnapshot_tenant_branch_date" ON public."POSReportSnapshot" USING btree ("tenantId", "branchId", "createdAt");


--
-- Name: IDX_POSReportSnapshot_tenant_type_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSReportSnapshot_tenant_type_date" ON public."POSReportSnapshot" USING btree ("tenantId", "reportType", "createdAt");


--
-- Name: IDX_POSSession_tenant_terminal_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSSession_tenant_terminal_status" ON public."POSSession" USING btree ("tenantId", "terminalId", status);


--
-- Name: IDX_POSSession_tenant_user_start; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSSession_tenant_user_start" ON public."POSSession" USING btree ("tenantId", "userId", "startTime");


--
-- Name: IDX_POSSyncQueue_status_priority; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSSyncQueue_status_priority" ON public."POSSyncQueue" USING btree (status, priority, "createdAt");


--
-- Name: IDX_POSSyncQueue_tenant_terminal_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSSyncQueue_tenant_terminal_status" ON public."POSSyncQueue" USING btree ("tenantId", "terminalId", status);


--
-- Name: IDX_POSTerminal_tenant_branch_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSTerminal_tenant_branch_status" ON public."POSTerminal" USING btree ("tenantId", "branchId", status);


--
-- Name: IDX_POSTerminal_tenant_online; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSTerminal_tenant_online" ON public."POSTerminal" USING btree ("tenantId", status, "isOnline");


--
-- Name: IDX_POSTransactionDiscount_transaction; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSTransactionDiscount_transaction" ON public."POSTransactionDiscount" USING btree ("transactionId");


--
-- Name: IDX_POSTransactionEvent_transaction; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSTransactionEvent_transaction" ON public."POSTransactionEvent" USING btree ("transactionId");


--
-- Name: IDX_POSTransactionItem_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSTransactionItem_product" ON public."POSTransactionItem" USING btree ("productId");


--
-- Name: IDX_POSTransactionItem_transaction; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSTransactionItem_transaction" ON public."POSTransactionItem" USING btree ("transactionId");


--
-- Name: IDX_POSTransactionTax_transaction; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSTransactionTax_transaction" ON public."POSTransactionTax" USING btree ("transactionId");


--
-- Name: IDX_POSTransaction_tenant_branch_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSTransaction_tenant_branch_date" ON public."POSTransaction" USING btree ("tenantId", "branchId", "transactionDate");


--
-- Name: IDX_POSTransaction_tenant_cashier_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSTransaction_tenant_cashier_date" ON public."POSTransaction" USING btree ("tenantId", "cashierId", "transactionDate");


--
-- Name: IDX_POSTransaction_tenant_customer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSTransaction_tenant_customer" ON public."POSTransaction" USING btree ("tenantId", "customerId");


--
-- Name: IDX_POSTransaction_tenant_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSTransaction_tenant_date" ON public."POSTransaction" USING btree ("tenantId", "transactionDate");


--
-- Name: IDX_POSTransaction_tenant_session; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSTransaction_tenant_session" ON public."POSTransaction" USING btree ("tenantId", "sessionId");


--
-- Name: IDX_POSTransaction_tenant_shift; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSTransaction_tenant_shift" ON public."POSTransaction" USING btree ("tenantId", "shiftId");


--
-- Name: IDX_POSTransaction_tenant_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSTransaction_tenant_status" ON public."POSTransaction" USING btree ("tenantId", status);


--
-- Name: IDX_POSTransaction_tenant_terminal_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_POSTransaction_tenant_terminal_date" ON public."POSTransaction" USING btree ("tenantId", "terminalId", "transactionDate");


--
-- Name: InvMoveType_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InvMoveType_branchId_idx" ON public."InvMoveType" USING btree ("branchId");


--
-- Name: InvMoveType_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InvMoveType_tenantId_idx" ON public."InvMoveType" USING btree ("tenantId");


--
-- Name: InventoryAdjustmentItem_adjustmentId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InventoryAdjustmentItem_adjustmentId_idx" ON public."InventoryAdjustmentItem" USING btree ("adjustmentId");


--
-- Name: InventoryAdjustmentItem_productId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InventoryAdjustmentItem_productId_idx" ON public."InventoryAdjustmentItem" USING btree ("productId");


--
-- Name: InventoryAdjustmentItem_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InventoryAdjustmentItem_tenantId_idx" ON public."InventoryAdjustmentItem" USING btree ("tenantId");


--
-- Name: InventoryAdjustment_adjustmentType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InventoryAdjustment_adjustmentType_idx" ON public."InventoryAdjustment" USING btree ("adjustmentType");


--
-- Name: InventoryAdjustment_tenantId_adjustmentDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InventoryAdjustment_tenantId_adjustmentDate_idx" ON public."InventoryAdjustment" USING btree ("tenantId", "adjustmentDate");


--
-- Name: InventoryReference_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InventoryReference_branchId_idx" ON public."InventoryReference" USING btree ("branchId");


--
-- Name: InventoryReference_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InventoryReference_tenantId_idx" ON public."InventoryReference" USING btree ("tenantId");


--
-- Name: InvoiceCredit_invoiceId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InvoiceCredit_invoiceId_idx" ON public."InvoiceCredit" USING btree ("invoiceId");


--
-- Name: InvoicePayment_invoiceId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InvoicePayment_invoiceId_idx" ON public."InvoicePayment" USING btree ("invoiceId");


--
-- Name: InvoicePayment_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InvoicePayment_tenantId_idx" ON public."InvoicePayment" USING btree ("tenantId");


--
-- Name: InvoiceType_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InvoiceType_branchId_idx" ON public."InvoiceType" USING btree ("branchId");


--
-- Name: InvoiceType_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InvoiceType_tenantId_idx" ON public."InvoiceType" USING btree ("tenantId");


--
-- Name: InvoiceVerification_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InvoiceVerification_branchId_idx" ON public."InvoiceVerification" USING btree ("branchId");


--
-- Name: InvoiceVerification_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InvoiceVerification_tenantId_idx" ON public."InvoiceVerification" USING btree ("tenantId");


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
-- Name: ItemCountsYear_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ItemCountsYear_branchId_idx" ON public."ItemCountsYear" USING btree ("branchId");


--
-- Name: ItemCountsYear_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ItemCountsYear_tenantId_idx" ON public."ItemCountsYear" USING btree ("tenantId");


--
-- Name: ItemStatus_tenantId_productId_year_month_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ItemStatus_tenantId_productId_year_month_idx" ON public."ItemStatus" USING btree ("tenantId", "productId", year, month);


--
-- Name: ItemStatus_tenantId_productId_year_month_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ItemStatus_tenantId_productId_year_month_key" ON public."ItemStatus" USING btree ("tenantId", "productId", year, month);


--
-- Name: ItemStatus_tenantId_year_month_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ItemStatus_tenantId_year_month_idx" ON public."ItemStatus" USING btree ("tenantId", year, month);


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
-- Name: Lang_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Lang_branchId_idx" ON public."Lang" USING btree ("branchId");


--
-- Name: Lang_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Lang_tenantId_idx" ON public."Lang" USING btree ("tenantId");


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
-- Name: LensSolution_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LensSolution_branchId_idx" ON public."LensSolution" USING btree ("branchId");


--
-- Name: LensSolution_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LensSolution_tenantId_idx" ON public."LensSolution" USING btree ("tenantId");


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
-- Name: LensTreatment_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LensTreatment_branchId_idx" ON public."LensTreatment" USING btree ("branchId");


--
-- Name: LensTreatment_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "LensTreatment_tenantId_idx" ON public."LensTreatment" USING btree ("tenantId");


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
-- Name: MessageAttachment_messageId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "MessageAttachment_messageId_idx" ON public."MessageAttachment" USING btree ("messageId");


--
-- Name: MessageAttachment_uploaderId_uploaderType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "MessageAttachment_uploaderId_uploaderType_idx" ON public."MessageAttachment" USING btree ("uploaderId", "uploaderType");


--
-- Name: MessageTemplate_tenantId_name_language_type_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "MessageTemplate_tenantId_name_language_type_key" ON public."MessageTemplate" USING btree ("tenantId", name, language, type);


--
-- Name: Message_conversationId_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Message_conversationId_createdAt_idx" ON public."Message" USING btree ("conversationId", "createdAt");


--
-- Name: Message_readAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Message_readAt_idx" ON public."Message" USING btree ("readAt");


--
-- Name: Message_senderId_senderType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Message_senderId_senderType_idx" ON public."Message" USING btree ("senderId", "senderType");


--
-- Name: MigrationLog_level_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "MigrationLog_level_idx" ON public."MigrationLog" USING btree (level);


--
-- Name: MigrationLog_migrationId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "MigrationLog_migrationId_idx" ON public."MigrationLog" USING btree ("migrationId");


--
-- Name: MigrationLog_timestamp_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "MigrationLog_timestamp_idx" ON public."MigrationLog" USING btree ("timestamp" DESC);


--
-- Name: MigrationRun_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "MigrationRun_branchId_idx" ON public."MigrationRun" USING btree ("branchId");


--
-- Name: MigrationRun_createdBy_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "MigrationRun_createdBy_idx" ON public."MigrationRun" USING btree ("createdBy");


--
-- Name: MigrationRun_startedAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "MigrationRun_startedAt_idx" ON public."MigrationRun" USING btree ("startedAt" DESC);


--
-- Name: MigrationRun_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "MigrationRun_status_idx" ON public."MigrationRun" USING btree (status);


--
-- Name: MigrationRun_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "MigrationRun_tenantId_idx" ON public."MigrationRun" USING btree ("tenantId");


--
-- Name: MigrationTableResult_migrationId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "MigrationTableResult_migrationId_idx" ON public."MigrationTableResult" USING btree ("migrationId");


--
-- Name: MigrationTableResult_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "MigrationTableResult_status_idx" ON public."MigrationTableResult" USING btree (status);


--
-- Name: MigrationTableResult_tableName_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "MigrationTableResult_tableName_idx" ON public."MigrationTableResult" USING btree ("tableName");


--
-- Name: MovementProperty_movementPropertyId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "MovementProperty_movementPropertyId_key" ON public."MovementProperty" USING btree ("movementPropertyId");


--
-- Name: MovementProperty_tenantId_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "MovementProperty_tenantId_isActive_idx" ON public."MovementProperty" USING btree ("tenantId", "isActive");


--
-- Name: MovementProperty_tenantId_movementPropertyId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "MovementProperty_tenantId_movementPropertyId_key" ON public."MovementProperty" USING btree ("tenantId", "movementPropertyId");


--
-- Name: MovementType_movementTypeId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "MovementType_movementTypeId_key" ON public."MovementType" USING btree ("movementTypeId");


--
-- Name: MovementType_tenantId_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "MovementType_tenantId_category_idx" ON public."MovementType" USING btree ("tenantId", category);


--
-- Name: MovementType_tenantId_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "MovementType_tenantId_isActive_idx" ON public."MovementType" USING btree ("tenantId", "isActive");


--
-- Name: MovementType_tenantId_movementTypeId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "MovementType_tenantId_movementTypeId_key" ON public."MovementType" USING btree ("tenantId", "movementTypeId");


--
-- Name: NewProduct_displayFrom_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "NewProduct_displayFrom_idx" ON public."NewProduct" USING btree ("displayFrom");


--
-- Name: NewProduct_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "NewProduct_isActive_idx" ON public."NewProduct" USING btree ("isActive");


--
-- Name: NewProduct_productId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "NewProduct_productId_idx" ON public."NewProduct" USING btree ("productId");


--
-- Name: NewProduct_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "NewProduct_tenantId_idx" ON public."NewProduct" USING btree ("tenantId");


--
-- Name: NewProduct_tenantId_isActive_displayFrom_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "NewProduct_tenantId_isActive_displayFrom_idx" ON public."NewProduct" USING btree ("tenantId", "isActive", "displayFrom");


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
-- Name: OrderItem_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "OrderItem_tenantId_idx" ON public."OrderItem" USING btree ("tenantId");


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
-- Name: POSCashDrop_dropNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "POSCashDrop_dropNumber_key" ON public."POSCashDrop" USING btree ("dropNumber");


--
-- Name: POSCashPickup_pickupNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "POSCashPickup_pickupNumber_key" ON public."POSCashPickup" USING btree ("pickupNumber");


--
-- Name: POSPaymentRefund_refundNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "POSPaymentRefund_refundNumber_key" ON public."POSPaymentRefund" USING btree ("refundNumber");


--
-- Name: POSPayment_paymentNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "POSPayment_paymentNumber_key" ON public."POSPayment" USING btree ("paymentNumber");


--
-- Name: POSReceipt_receiptNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "POSReceipt_receiptNumber_key" ON public."POSReceipt" USING btree ("receiptNumber");


--
-- Name: POSReportSnapshot_reportNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "POSReportSnapshot_reportNumber_key" ON public."POSReportSnapshot" USING btree ("reportNumber");


--
-- Name: POSSession_sessionNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "POSSession_sessionNumber_key" ON public."POSSession" USING btree ("sessionNumber");


--
-- Name: POSTransaction_transactionNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "POSTransaction_transactionNumber_key" ON public."POSTransaction" USING btree ("transactionNumber");


--
-- Name: PayType_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PayType_branchId_idx" ON public."PayType" USING btree ("branchId");


--
-- Name: PayType_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PayType_tenantId_idx" ON public."PayType" USING btree ("tenantId");


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
-- Name: PrintLabel_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PrintLabel_branchId_idx" ON public."PrintLabel" USING btree ("branchId");


--
-- Name: PrintLabel_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PrintLabel_tenantId_idx" ON public."PrintLabel" USING btree ("tenantId");


--
-- Name: PrlType_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PrlType_branchId_idx" ON public."PrlType" USING btree ("branchId");


--
-- Name: PrlType_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PrlType_tenantId_idx" ON public."PrlType" USING btree ("tenantId");


--
-- Name: ProductProperty_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ProductProperty_branchId_idx" ON public."ProductProperty" USING btree ("branchId");


--
-- Name: ProductProperty_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ProductProperty_tenantId_idx" ON public."ProductProperty" USING btree ("tenantId");


--
-- Name: ProductReview_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ProductReview_createdAt_idx" ON public."ProductReview" USING btree ("createdAt");


--
-- Name: ProductReview_itemType_itemId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ProductReview_itemType_itemId_idx" ON public."ProductReview" USING btree ("itemType", "itemId");


--
-- Name: ProductReview_rating_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ProductReview_rating_idx" ON public."ProductReview" USING btree (rating);


--
-- Name: ProductReview_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ProductReview_status_idx" ON public."ProductReview" USING btree (status);


--
-- Name: ProductReview_supplierId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ProductReview_supplierId_idx" ON public."ProductReview" USING btree ("supplierId");


--
-- Name: ProductReview_tenantId_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ProductReview_tenantId_userId_idx" ON public."ProductReview" USING btree ("tenantId", "userId");


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
-- Name: Product_tenantId_barcode_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Product_tenantId_barcode_idx" ON public."Product" USING btree ("tenantId", barcode);


--
-- Name: Product_tenantId_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Product_tenantId_category_idx" ON public."Product" USING btree ("tenantId", category);


--
-- Name: Product_tenantId_isActive_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Product_tenantId_isActive_category_idx" ON public."Product" USING btree ("tenantId", "isActive", category);


--
-- Name: Product_tenantId_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Product_tenantId_isActive_idx" ON public."Product" USING btree ("tenantId", "isActive");


--
-- Name: Product_tenantId_isActive_quantity_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Product_tenantId_isActive_quantity_idx" ON public."Product" USING btree ("tenantId", "isActive", quantity);


--
-- Name: Product_tenantId_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Product_tenantId_name_idx" ON public."Product" USING btree ("tenantId", name);


--
-- Name: Product_tenantId_productId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Product_tenantId_productId_key" ON public."Product" USING btree ("tenantId", "productId");


--
-- Name: Product_tenantId_sku_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Product_tenantId_sku_idx" ON public."Product" USING btree ("tenantId", sku);


--
-- Name: Product_tenantId_sku_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Product_tenantId_sku_key" ON public."Product" USING btree ("tenantId", sku);


--
-- Name: Product_tenantId_trackQuantity_quantity_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Product_tenantId_trackQuantity_quantity_idx" ON public."Product" USING btree ("tenantId", "trackQuantity", quantity);


--
-- Name: Profile_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Profile_branchId_idx" ON public."Profile" USING btree ("branchId");


--
-- Name: Profile_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Profile_tenantId_idx" ON public."Profile" USING btree ("tenantId");


--
-- Name: PurchaseCheck_purchaseId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PurchaseCheck_purchaseId_idx" ON public."PurchaseCheck" USING btree ("purchaseId");


--
-- Name: PurchaseCheck_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PurchaseCheck_tenantId_idx" ON public."PurchaseCheck" USING btree ("tenantId");


--
-- Name: PurchasePayment_purchaseId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PurchasePayment_purchaseId_idx" ON public."PurchasePayment" USING btree ("purchaseId");


--
-- Name: PurchasePayment_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PurchasePayment_tenantId_idx" ON public."PurchasePayment" USING btree ("tenantId");


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
-- Name: ReferralSource_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ReferralSource_branchId_idx" ON public."ReferralSource" USING btree ("branchId");


--
-- Name: ReferralSource_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ReferralSource_tenantId_idx" ON public."ReferralSource" USING btree ("tenantId");


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
-- Name: ReviewHelpful_reviewId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ReviewHelpful_reviewId_idx" ON public."ReviewHelpful" USING btree ("reviewId");


--
-- Name: ReviewHelpful_reviewId_userId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ReviewHelpful_reviewId_userId_key" ON public."ReviewHelpful" USING btree ("reviewId", "userId");


--
-- Name: ReviewHelpful_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ReviewHelpful_userId_idx" ON public."ReviewHelpful" USING btree ("userId");


--
-- Name: ReviewReport_reportedBy_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ReviewReport_reportedBy_idx" ON public."ReviewReport" USING btree ("reportedBy");


--
-- Name: ReviewReport_reviewId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ReviewReport_reviewId_idx" ON public."ReviewReport" USING btree ("reviewId");


--
-- Name: ReviewReport_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ReviewReport_status_idx" ON public."ReviewReport" USING btree (status);


--
-- Name: SMSLen_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SMSLen_branchId_idx" ON public."SMSLen" USING btree ("branchId");


--
-- Name: SMSLen_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SMSLen_tenantId_idx" ON public."SMSLen" USING btree ("tenantId");


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
-- Name: SaleItem_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SaleItem_tenantId_idx" ON public."SaleItem" USING btree ("tenantId");


--
-- Name: SaleItem_tenantId_saleId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SaleItem_tenantId_saleId_idx" ON public."SaleItem" USING btree ("tenantId", "saleId");


--
-- Name: Sale_deletedAt_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Sale_deletedAt_tenantId_idx" ON public."Sale" USING btree ("deletedAt", "tenantId");


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
-- Name: Sale_tenantId_invoiceType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Sale_tenantId_invoiceType_idx" ON public."Sale" USING btree ("tenantId", "invoiceType");


--
-- Name: Sale_tenantId_paymentStatus_saleDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Sale_tenantId_paymentStatus_saleDate_idx" ON public."Sale" USING btree ("tenantId", "paymentStatus", "saleDate");


--
-- Name: Sale_tenantId_receiptNumber_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Sale_tenantId_receiptNumber_idx" ON public."Sale" USING btree ("tenantId", "receiptNumber");


--
-- Name: Sale_tenantId_saleDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Sale_tenantId_saleDate_idx" ON public."Sale" USING btree ("tenantId", "saleDate");


--
-- Name: Sale_tenantId_sellerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Sale_tenantId_sellerId_idx" ON public."Sale" USING btree ("tenantId", "sellerId");


--
-- Name: Sale_tenantId_sellerId_status_saleDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Sale_tenantId_sellerId_status_saleDate_idx" ON public."Sale" USING btree ("tenantId", "sellerId", status, "saleDate");


--
-- Name: Sale_tenantId_status_saleDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Sale_tenantId_status_saleDate_idx" ON public."Sale" USING btree ("tenantId", status, "saleDate");


--
-- Name: SapakComment_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SapakComment_branchId_idx" ON public."SapakComment" USING btree ("branchId");


--
-- Name: SapakComment_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SapakComment_tenantId_idx" ON public."SapakComment" USING btree ("tenantId");


--
-- Name: SapakDest_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SapakDest_branchId_idx" ON public."SapakDest" USING btree ("branchId");


--
-- Name: SapakDest_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SapakDest_tenantId_idx" ON public."SapakDest" USING btree ("tenantId");


--
-- Name: SapakPerComment_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SapakPerComment_branchId_idx" ON public."SapakPerComment" USING btree ("branchId");


--
-- Name: SapakPerComment_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SapakPerComment_tenantId_idx" ON public."SapakPerComment" USING btree ("tenantId");


--
-- Name: SearchOrder_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SearchOrder_branchId_idx" ON public."SearchOrder" USING btree ("branchId");


--
-- Name: SearchOrder_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SearchOrder_tenantId_idx" ON public."SearchOrder" USING btree ("tenantId");


--
-- Name: ServiceType_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ServiceType_branchId_idx" ON public."ServiceType" USING btree ("branchId");


--
-- Name: ServiceType_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ServiceType_tenantId_idx" ON public."ServiceType" USING btree ("tenantId");


--
-- Name: ShortCut_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ShortCut_branchId_idx" ON public."ShortCut" USING btree ("branchId");


--
-- Name: ShortCut_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ShortCut_tenantId_idx" ON public."ShortCut" USING btree ("tenantId");


--
-- Name: SlitLampExam_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SlitLampExam_customerId_idx" ON public."SlitLampExam" USING btree ("customerId");


--
-- Name: SlitLampExam_examDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SlitLampExam_examDate_idx" ON public."SlitLampExam" USING btree ("examDate");


--
-- Name: SpecialName_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SpecialName_branchId_idx" ON public."SpecialName" USING btree ("branchId");


--
-- Name: SpecialName_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SpecialName_tenantId_idx" ON public."SpecialName" USING btree ("tenantId");


--
-- Name: Special_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Special_branchId_idx" ON public."Special" USING btree ("branchId");


--
-- Name: Special_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Special_tenantId_idx" ON public."Special" USING btree ("tenantId");


--
-- Name: StaffSchedule_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "StaffSchedule_tenantId_idx" ON public."StaffSchedule" USING btree ("tenantId");


--
-- Name: StaffSchedule_tenantId_workDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "StaffSchedule_tenantId_workDate_idx" ON public."StaffSchedule" USING btree ("tenantId", "workDate");


--
-- Name: StaffSchedule_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "StaffSchedule_userId_idx" ON public."StaffSchedule" USING btree ("userId");


--
-- Name: StaffSchedule_workDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "StaffSchedule_workDate_idx" ON public."StaffSchedule" USING btree ("workDate");


--
-- Name: StockMovement_tenantId_exCatNum_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "StockMovement_tenantId_exCatNum_idx" ON public."StockMovement" USING btree ("tenantId", "exCatNum");


--
-- Name: StockMovement_tenantId_invoiceId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "StockMovement_tenantId_invoiceId_idx" ON public."StockMovement" USING btree ("tenantId", "invoiceId");


--
-- Name: StockMovement_tenantId_movementTypeId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "StockMovement_tenantId_movementTypeId_idx" ON public."StockMovement" USING btree ("tenantId", "movementTypeId");


--
-- Name: StockMovement_tenantId_productId_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "StockMovement_tenantId_productId_createdAt_idx" ON public."StockMovement" USING btree ("tenantId", "productId", "createdAt");


--
-- Name: StockMovement_tenantId_type_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "StockMovement_tenantId_type_createdAt_idx" ON public."StockMovement" USING btree ("tenantId", type, "createdAt");


--
-- Name: SupplierAccountTransaction_accountId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierAccountTransaction_accountId_idx" ON public."SupplierAccountTransaction" USING btree ("accountId");


--
-- Name: SupplierAccountTransaction_orderId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierAccountTransaction_orderId_idx" ON public."SupplierAccountTransaction" USING btree ("orderId");


--
-- Name: SupplierAccountTransaction_transactionDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierAccountTransaction_transactionDate_idx" ON public."SupplierAccountTransaction" USING btree ("transactionDate");


--
-- Name: SupplierAnalytics_supplierId_periodType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierAnalytics_supplierId_periodType_idx" ON public."SupplierAnalytics" USING btree ("supplierId", "periodType");


--
-- Name: SupplierAnalytics_supplierId_periodType_periodStart_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "SupplierAnalytics_supplierId_periodType_periodStart_key" ON public."SupplierAnalytics" USING btree ("supplierId", "periodType", "periodStart");


--
-- Name: SupplierCatalogCategory_supplierId_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierCatalogCategory_supplierId_isActive_idx" ON public."SupplierCatalogCategory" USING btree ("supplierId", "isActive");


--
-- Name: SupplierCatalogCategory_supplierId_parentId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierCatalogCategory_supplierId_parentId_idx" ON public."SupplierCatalogCategory" USING btree ("supplierId", "parentId");


--
-- Name: SupplierCatalogItem_barcode_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierCatalogItem_barcode_idx" ON public."SupplierCatalogItem" USING btree (barcode);


--
-- Name: SupplierCatalogItem_sku_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierCatalogItem_sku_idx" ON public."SupplierCatalogItem" USING btree (sku);


--
-- Name: SupplierCatalogItem_supplierId_categoryId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierCatalogItem_supplierId_categoryId_idx" ON public."SupplierCatalogItem" USING btree ("supplierId", "categoryId");


--
-- Name: SupplierCatalogItem_supplierId_sku_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "SupplierCatalogItem_supplierId_sku_key" ON public."SupplierCatalogItem" USING btree ("supplierId", sku);


--
-- Name: SupplierCatalogItem_supplierId_type_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierCatalogItem_supplierId_type_isActive_idx" ON public."SupplierCatalogItem" USING btree ("supplierId", type, "isActive");


--
-- Name: SupplierCatalogVariant_itemId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierCatalogVariant_itemId_idx" ON public."SupplierCatalogVariant" USING btree ("itemId");


--
-- Name: SupplierCatalogVariant_itemId_sku_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "SupplierCatalogVariant_itemId_sku_key" ON public."SupplierCatalogVariant" USING btree ("itemId", sku);


--
-- Name: SupplierCollectionVisibility_collectionId_tenantId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "SupplierCollectionVisibility_collectionId_tenantId_key" ON public."SupplierCollectionVisibility" USING btree ("collectionId", "tenantId");


--
-- Name: SupplierCollectionVisibility_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierCollectionVisibility_tenantId_idx" ON public."SupplierCollectionVisibility" USING btree ("tenantId");


--
-- Name: SupplierCollection_supplierId_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierCollection_supplierId_name_idx" ON public."SupplierCollection" USING btree ("supplierId", name);


--
-- Name: SupplierCollection_supplierId_published_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierCollection_supplierId_published_idx" ON public."SupplierCollection" USING btree ("supplierId", published);


--
-- Name: SupplierDiscountUsage_discountId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierDiscountUsage_discountId_idx" ON public."SupplierDiscountUsage" USING btree ("discountId");


--
-- Name: SupplierDiscountUsage_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierDiscountUsage_tenantId_idx" ON public."SupplierDiscountUsage" USING btree ("tenantId");


--
-- Name: SupplierDiscount_code_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierDiscount_code_idx" ON public."SupplierDiscount" USING btree (code);


--
-- Name: SupplierDiscount_code_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "SupplierDiscount_code_key" ON public."SupplierDiscount" USING btree (code);


--
-- Name: SupplierDiscount_supplierId_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierDiscount_supplierId_isActive_idx" ON public."SupplierDiscount" USING btree ("supplierId", "isActive");


--
-- Name: SupplierDiscount_supplierId_startDate_endDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierDiscount_supplierId_startDate_endDate_idx" ON public."SupplierDiscount" USING btree ("supplierId", "startDate", "endDate");


--
-- Name: SupplierInventoryLog_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierInventoryLog_createdAt_idx" ON public."SupplierInventoryLog" USING btree ("createdAt");


--
-- Name: SupplierInventoryLog_itemId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierInventoryLog_itemId_idx" ON public."SupplierInventoryLog" USING btree ("itemId");


--
-- Name: SupplierInventoryLog_type_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierInventoryLog_type_idx" ON public."SupplierInventoryLog" USING btree (type);


--
-- Name: SupplierOrderItem_orderId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierOrderItem_orderId_idx" ON public."SupplierOrderItem" USING btree ("orderId");


--
-- Name: SupplierOrder_accountId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierOrder_accountId_idx" ON public."SupplierOrder" USING btree ("accountId");


--
-- Name: SupplierOrder_orderDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierOrder_orderDate_idx" ON public."SupplierOrder" USING btree ("orderDate");


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
-- Name: SupplierOrder_tenantId_orderNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "SupplierOrder_tenantId_orderNumber_key" ON public."SupplierOrder" USING btree ("tenantId", "orderNumber");


--
-- Name: SupplierPriceAlert_frameCatalogId_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierPriceAlert_frameCatalogId_isActive_idx" ON public."SupplierPriceAlert" USING btree ("frameCatalogId", "isActive");


--
-- Name: SupplierPriceAlert_lensCatalogId_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierPriceAlert_lensCatalogId_isActive_idx" ON public."SupplierPriceAlert" USING btree ("lensCatalogId", "isActive");


--
-- Name: SupplierPriceAlert_tenantId_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierPriceAlert_tenantId_isActive_idx" ON public."SupplierPriceAlert" USING btree ("tenantId", "isActive");


--
-- Name: SupplierPriceAlert_userId_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierPriceAlert_userId_isActive_idx" ON public."SupplierPriceAlert" USING btree ("userId", "isActive");


--
-- Name: SupplierPriceCache_expiresAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierPriceCache_expiresAt_idx" ON public."SupplierPriceCache" USING btree ("expiresAt");


--
-- Name: SupplierPriceCache_frameCatalogId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierPriceCache_frameCatalogId_idx" ON public."SupplierPriceCache" USING btree ("frameCatalogId");


--
-- Name: SupplierPriceCache_frameCatalogId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "SupplierPriceCache_frameCatalogId_key" ON public."SupplierPriceCache" USING btree ("frameCatalogId");


--
-- Name: SupplierPriceCache_lensCatalogId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierPriceCache_lensCatalogId_idx" ON public."SupplierPriceCache" USING btree ("lensCatalogId");


--
-- Name: SupplierPriceCache_lensCatalogId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "SupplierPriceCache_lensCatalogId_key" ON public."SupplierPriceCache" USING btree ("lensCatalogId");


--
-- Name: SupplierPriceHistory_frameCatalogId_validFrom_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierPriceHistory_frameCatalogId_validFrom_isActive_idx" ON public."SupplierPriceHistory" USING btree ("frameCatalogId", "validFrom", "isActive");


--
-- Name: SupplierPriceHistory_isActive_validFrom_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierPriceHistory_isActive_validFrom_idx" ON public."SupplierPriceHistory" USING btree ("isActive", "validFrom");


--
-- Name: SupplierPriceHistory_itemType_validFrom_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierPriceHistory_itemType_validFrom_idx" ON public."SupplierPriceHistory" USING btree ("itemType", "validFrom");


--
-- Name: SupplierPriceHistory_lensCatalogId_validFrom_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierPriceHistory_lensCatalogId_validFrom_isActive_idx" ON public."SupplierPriceHistory" USING btree ("lensCatalogId", "validFrom", "isActive");


--
-- Name: SupplierPriceHistory_supplierId_validFrom_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierPriceHistory_supplierId_validFrom_idx" ON public."SupplierPriceHistory" USING btree ("supplierId", "validFrom");


--
-- Name: SupplierPriceListItem_itemId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierPriceListItem_itemId_idx" ON public."SupplierPriceListItem" USING btree ("itemId");


--
-- Name: SupplierPriceListItem_priceListId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierPriceListItem_priceListId_idx" ON public."SupplierPriceListItem" USING btree ("priceListId");


--
-- Name: SupplierPriceListItem_priceListId_itemId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "SupplierPriceListItem_priceListId_itemId_key" ON public."SupplierPriceListItem" USING btree ("priceListId", "itemId");


--
-- Name: SupplierPriceList_supplierId_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierPriceList_supplierId_isActive_idx" ON public."SupplierPriceList" USING btree ("supplierId", "isActive");


--
-- Name: SupplierRFQItem_frameCatalogId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierRFQItem_frameCatalogId_idx" ON public."SupplierRFQItem" USING btree ("frameCatalogId");


--
-- Name: SupplierRFQItem_lensCatalogId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierRFQItem_lensCatalogId_idx" ON public."SupplierRFQItem" USING btree ("lensCatalogId");


--
-- Name: SupplierRFQItem_rfqId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierRFQItem_rfqId_idx" ON public."SupplierRFQItem" USING btree ("rfqId");


--
-- Name: SupplierRFQ_supplierId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierRFQ_supplierId_status_idx" ON public."SupplierRFQ" USING btree ("supplierId", status);


--
-- Name: SupplierRFQ_tenantId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierRFQ_tenantId_status_idx" ON public."SupplierRFQ" USING btree ("tenantId", status);


--
-- Name: SupplierShipment_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierShipment_branchId_idx" ON public."SupplierShipment" USING btree ("branchId");


--
-- Name: SupplierShipment_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierShipment_tenantId_idx" ON public."SupplierShipment" USING btree ("tenantId");


--
-- Name: SupplierStockAlert_itemId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierStockAlert_itemId_idx" ON public."SupplierStockAlert" USING btree ("itemId");


--
-- Name: SupplierStockAlert_supplierId_isResolved_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierStockAlert_supplierId_isResolved_idx" ON public."SupplierStockAlert" USING btree ("supplierId", "isResolved");


--
-- Name: SupplierTenantAccount_accountNumber_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierTenantAccount_accountNumber_idx" ON public."SupplierTenantAccount" USING btree ("accountNumber");


--
-- Name: SupplierTenantAccount_accountNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "SupplierTenantAccount_accountNumber_key" ON public."SupplierTenantAccount" USING btree ("accountNumber");


--
-- Name: SupplierTenantAccount_supplierId_accountStatus_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierTenantAccount_supplierId_accountStatus_idx" ON public."SupplierTenantAccount" USING btree ("supplierId", "accountStatus");


--
-- Name: SupplierTenantAccount_supplierId_tenantId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "SupplierTenantAccount_supplierId_tenantId_key" ON public."SupplierTenantAccount" USING btree ("supplierId", "tenantId");


--
-- Name: SupplierTenantActivity_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierTenantActivity_createdAt_idx" ON public."SupplierTenantActivity" USING btree ("createdAt");


--
-- Name: SupplierTenantActivity_supplierId_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierTenantActivity_supplierId_tenantId_idx" ON public."SupplierTenantActivity" USING btree ("supplierId", "tenantId");


--
-- Name: SupplierTenantNote_createdBy_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierTenantNote_createdBy_idx" ON public."SupplierTenantNote" USING btree ("createdBy");


--
-- Name: SupplierTenantNote_supplierId_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierTenantNote_supplierId_tenantId_idx" ON public."SupplierTenantNote" USING btree ("supplierId", "tenantId");


--
-- Name: SupplierUser_email_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "SupplierUser_email_key" ON public."SupplierUser" USING btree (email);


--
-- Name: SupplierUser_supplierId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SupplierUser_supplierId_idx" ON public."SupplierUser" USING btree ("supplierId");


--
-- Name: Supplier_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Supplier_name_idx" ON public."Supplier" USING btree (name);


--
-- Name: Supplier_supplierId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Supplier_supplierId_key" ON public."Supplier" USING btree ("supplierId");


--
-- Name: SysLevel_branchId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SysLevel_branchId_idx" ON public."SysLevel" USING btree ("branchId");


--
-- Name: SysLevel_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SysLevel_tenantId_idx" ON public."SysLevel" USING btree ("tenantId");


--
-- Name: TaskAttachment_taskId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "TaskAttachment_taskId_idx" ON public."TaskAttachment" USING btree ("taskId");


--
-- Name: TaskAttachment_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "TaskAttachment_tenantId_idx" ON public."TaskAttachment" USING btree ("tenantId");


--
-- Name: TaskComment_taskId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "TaskComment_taskId_idx" ON public."TaskComment" USING btree ("taskId");


--
-- Name: TaskComment_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "TaskComment_tenantId_idx" ON public."TaskComment" USING btree ("tenantId");


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
-- Name: UQ_POSTerminal_terminalNumber; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "UQ_POSTerminal_terminalNumber" ON public."POSTerminal" USING btree ("tenantId", "terminalNumber");


--
-- Name: UserSettings_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "UserSettings_tenantId_idx" ON public."UserSettings" USING btree ("tenantId");


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
-- Name: VATRate_tenantId_effectiveFrom_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "VATRate_tenantId_effectiveFrom_idx" ON public."VATRate" USING btree ("tenantId", "effectiveFrom");


--
-- Name: VATRate_tenantId_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "VATRate_tenantId_isActive_idx" ON public."VATRate" USING btree ("tenantId", "isActive");


--
-- Name: VisionTest_customerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "VisionTest_customerId_idx" ON public."VisionTest" USING btree ("customerId");


--
-- Name: VisionTest_testDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "VisionTest_testDate_idx" ON public."VisionTest" USING btree ("testDate");


--
-- Name: WishlistItem_itemType_itemId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "WishlistItem_itemType_itemId_idx" ON public."WishlistItem" USING btree ("itemType", "itemId");


--
-- Name: WishlistItem_supplierId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "WishlistItem_supplierId_idx" ON public."WishlistItem" USING btree ("supplierId");


--
-- Name: WishlistItem_wishlistId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "WishlistItem_wishlistId_idx" ON public."WishlistItem" USING btree ("wishlistId");


--
-- Name: WishlistItem_wishlistId_itemType_itemId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "WishlistItem_wishlistId_itemType_itemId_key" ON public."WishlistItem" USING btree ("wishlistId", "itemType", "itemId");


--
-- Name: WishlistShare_sharedWith_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "WishlistShare_sharedWith_idx" ON public."WishlistShare" USING btree ("sharedWith");


--
-- Name: WishlistShare_wishlistId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "WishlistShare_wishlistId_idx" ON public."WishlistShare" USING btree ("wishlistId");


--
-- Name: Wishlist_shareToken_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Wishlist_shareToken_idx" ON public."Wishlist" USING btree ("shareToken");


--
-- Name: Wishlist_shareToken_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Wishlist_shareToken_key" ON public."Wishlist" USING btree ("shareToken");


--
-- Name: Wishlist_tenantId_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Wishlist_tenantId_userId_idx" ON public."Wishlist" USING btree ("tenantId", "userId");


--
-- Name: Wishlist_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Wishlist_userId_idx" ON public."Wishlist" USING btree ("userId");


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
-- Name: WorkOrderStatus_tenantId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "WorkOrderStatus_tenantId_idx" ON public."WorkOrderStatus" USING btree ("tenantId");


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
-- Name: _DiscountToItems_B_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "_DiscountToItems_B_index" ON public."_DiscountToItems" USING btree ("B");


--
-- Name: appointment_tenant_apt_ux; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX appointment_tenant_apt_ux ON public."Appointment" USING btree ("tenantId", id);


--
-- Name: checktype_tenant_checkid_ux; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX checktype_tenant_checkid_ux ON public."CheckType" USING btree ("tenantId", "checkId");


--
-- Name: city_tenant_cityid_ux; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX city_tenant_cityid_ux ON public."City" USING btree ("tenantId", "cityId");


--
-- Name: contactagent_natkey_ux; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX contactagent_natkey_ux ON public."ContactAgent" USING btree ("tenantId", "customerId", "firstName", "lastName");


--
-- Name: customer_tenant_customerid_ux; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX customer_tenant_customerid_ux ON public."Customer" USING btree ("tenantId", "customerId");


--
-- Name: idx_audit_customer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_customer ON public."FamilyAuditLog" USING btree ("tenantId", "customerId");


--
-- Name: idx_audit_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_date ON public."FamilyAuditLog" USING btree ("tenantId", "createdAt");


--
-- Name: idx_audit_relationship; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_relationship ON public."FamilyAuditLog" USING btree ("relationshipId");


--
-- Name: idx_audit_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_user ON public."FamilyAuditLog" USING btree ("userId");


--
-- Name: idx_family_confidence; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_family_confidence ON public."FamilyRelationship" USING btree ("confidenceScore");


--
-- Name: idx_family_customer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_family_customer ON public."FamilyRelationship" USING btree ("tenantId", "customerId");


--
-- Name: idx_family_deleted; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_family_deleted ON public."FamilyRelationship" USING btree ("deletedAt");


--
-- Name: idx_family_related; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_family_related ON public."FamilyRelationship" USING btree ("tenantId", "relatedCustomerId");


--
-- Name: idx_family_verified; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_family_verified ON public."FamilyRelationship" USING btree ("tenantId", verified);


--
-- Name: idx_household_activity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_household_activity ON public."Household" USING btree ("tenantId", "lastActivityDate");


--
-- Name: idx_household_tenant; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_household_tenant ON public."Household" USING btree ("tenantId");


--
-- Name: idx_household_value; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_household_value ON public."Household" USING btree ("tenantId", "lifetimeValue");


--
-- Name: invoicecredit_natkey_ux; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX invoicecredit_natkey_ux ON public."InvoiceCredit" USING btree ("invoiceId", "creditDate", amount);


--
-- Name: prescription_tenant_customer_prev_ux; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX prescription_tenant_customer_prev_ux ON public."Prescription" USING btree ("tenantId", id);


--
-- Name: staffschedule_user_date_ux; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX staffschedule_user_date_ux ON public."StaffSchedule" USING btree ("tenantId", "userId", "workDate");


--
-- Name: user_tenant_email_ux; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX user_tenant_email_ux ON public."User" USING btree ("tenantId", email);


--
-- Name: worklab_tenant_labid_ux; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX worklab_tenant_labid_ux ON public."WorkLab" USING btree ("tenantId", "labId");


--
-- Name: AISuggestion AISuggestion_examinationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AISuggestion"
    ADD CONSTRAINT "AISuggestion_examinationId_fkey" FOREIGN KEY ("examinationId") REFERENCES public."Examination"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: AISuggestion AISuggestion_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AISuggestion"
    ADD CONSTRAINT "AISuggestion_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: AddressLookup AddressLookup_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AddressLookup"
    ADD CONSTRAINT "AddressLookup_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: AddressLookup AddressLookup_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AddressLookup"
    ADD CONSTRAINT "AddressLookup_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: ApplicationSetting ApplicationSetting_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ApplicationSetting"
    ADD CONSTRAINT "ApplicationSetting_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ApplicationSetting ApplicationSetting_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ApplicationSetting"
    ADD CONSTRAINT "ApplicationSetting_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: AuditLog AuditLog_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AuditLog"
    ADD CONSTRAINT "AuditLog_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AuditLog AuditLog_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AuditLog"
    ADD CONSTRAINT "AuditLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BarcodeManagement BarcodeManagement_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BarcodeManagement"
    ADD CONSTRAINT "BarcodeManagement_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


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
-- Name: Base Base_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Base"
    ADD CONSTRAINT "Base_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Base Base_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Base"
    ADD CONSTRAINT "Base_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: BisData BisData_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BisData"
    ADD CONSTRAINT "BisData_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: BisData BisData_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BisData"
    ADD CONSTRAINT "BisData_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: BusinessContact BusinessContact_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BusinessContact"
    ADD CONSTRAINT "BusinessContact_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: BusinessContact BusinessContact_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BusinessContact"
    ADD CONSTRAINT "BusinessContact_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: ChatChannelMember ChatChannelMember_channelId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatChannelMember"
    ADD CONSTRAINT "ChatChannelMember_channelId_fkey" FOREIGN KEY ("channelId") REFERENCES public."ChatChannel"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatChannelMember ChatChannelMember_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatChannelMember"
    ADD CONSTRAINT "ChatChannelMember_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatChannelMember ChatChannelMember_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatChannelMember"
    ADD CONSTRAINT "ChatChannelMember_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatChannel ChatChannel_patientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatChannel"
    ADD CONSTRAINT "ChatChannel_patientId_fkey" FOREIGN KEY ("patientId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ChatChannel ChatChannel_roomId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatChannel"
    ADD CONSTRAINT "ChatChannel_roomId_fkey" FOREIGN KEY ("roomId") REFERENCES public."ChatRoom"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatChannel ChatChannel_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatChannel"
    ADD CONSTRAINT "ChatChannel_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatChannel ChatChannel_visitId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatChannel"
    ADD CONSTRAINT "ChatChannel_visitId_fkey" FOREIGN KEY ("visitId") REFERENCES public."Appointment"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ChatMessageTemplate ChatMessageTemplate_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatMessageTemplate"
    ADD CONSTRAINT "ChatMessageTemplate_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatMessage ChatMessage_channelId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatMessage"
    ADD CONSTRAINT "ChatMessage_channelId_fkey" FOREIGN KEY ("channelId") REFERENCES public."ChatChannel"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatMessage ChatMessage_replyToId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatMessage"
    ADD CONSTRAINT "ChatMessage_replyToId_fkey" FOREIGN KEY ("replyToId") REFERENCES public."ChatMessage"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ChatMessage ChatMessage_senderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatMessage"
    ADD CONSTRAINT "ChatMessage_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatMessage ChatMessage_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatMessage"
    ADD CONSTRAINT "ChatMessage_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatNotification ChatNotification_channelId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatNotification"
    ADD CONSTRAINT "ChatNotification_channelId_fkey" FOREIGN KEY ("channelId") REFERENCES public."ChatChannel"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatNotification ChatNotification_messageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatNotification"
    ADD CONSTRAINT "ChatNotification_messageId_fkey" FOREIGN KEY ("messageId") REFERENCES public."ChatMessage"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatNotification ChatNotification_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatNotification"
    ADD CONSTRAINT "ChatNotification_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatNotification ChatNotification_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatNotification"
    ADD CONSTRAINT "ChatNotification_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatRoomMember ChatRoomMember_roomId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatRoomMember"
    ADD CONSTRAINT "ChatRoomMember_roomId_fkey" FOREIGN KEY ("roomId") REFERENCES public."ChatRoom"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatRoomMember ChatRoomMember_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatRoomMember"
    ADD CONSTRAINT "ChatRoomMember_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatRoomMember ChatRoomMember_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatRoomMember"
    ADD CONSTRAINT "ChatRoomMember_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatRoom ChatRoom_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatRoom"
    ADD CONSTRAINT "ChatRoom_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatRoom ChatRoom_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatRoom"
    ADD CONSTRAINT "ChatRoom_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatSearch ChatSearch_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatSearch"
    ADD CONSTRAINT "ChatSearch_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatSearch ChatSearch_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatSearch"
    ADD CONSTRAINT "ChatSearch_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatTyping ChatTyping_channelId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatTyping"
    ADD CONSTRAINT "ChatTyping_channelId_fkey" FOREIGN KEY ("channelId") REFERENCES public."ChatChannel"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatTyping ChatTyping_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatTyping"
    ADD CONSTRAINT "ChatTyping_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChatTyping ChatTyping_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ChatTyping"
    ADD CONSTRAINT "ChatTyping_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CheckType CheckType_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CheckType"
    ADD CONSTRAINT "CheckType_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


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
-- Name: ClinicalData ClinicalData_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalData"
    ADD CONSTRAINT "ClinicalData_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ClinicalData ClinicalData_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalData"
    ADD CONSTRAINT "ClinicalData_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: ClinicalImage ClinicalImage_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalImage"
    ADD CONSTRAINT "ClinicalImage_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClinicalImage ClinicalImage_examinationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalImage"
    ADD CONSTRAINT "ClinicalImage_examinationId_fkey" FOREIGN KEY ("examinationId") REFERENCES public."Examination"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ClinicalImage ClinicalImage_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalImage"
    ADD CONSTRAINT "ClinicalImage_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClinicalImage ClinicalImage_uploadedBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalImage"
    ADD CONSTRAINT "ClinicalImage_uploadedBy_fkey" FOREIGN KEY ("uploadedBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClinicalProtocol ClinicalProtocol_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalProtocol"
    ADD CONSTRAINT "ClinicalProtocol_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClinicalProtocol ClinicalProtocol_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalProtocol"
    ADD CONSTRAINT "ClinicalProtocol_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClinicalReferral ClinicalReferral_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalReferral"
    ADD CONSTRAINT "ClinicalReferral_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClinicalReferral ClinicalReferral_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalReferral"
    ADD CONSTRAINT "ClinicalReferral_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClinicalReferral ClinicalReferral_examinationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalReferral"
    ADD CONSTRAINT "ClinicalReferral_examinationId_fkey" FOREIGN KEY ("examinationId") REFERENCES public."Examination"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ClinicalReferral ClinicalReferral_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalReferral"
    ADD CONSTRAINT "ClinicalReferral_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClinicalRuleTrigger ClinicalRuleTrigger_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalRuleTrigger"
    ADD CONSTRAINT "ClinicalRuleTrigger_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ClinicalRuleTrigger ClinicalRuleTrigger_examinationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalRuleTrigger"
    ADD CONSTRAINT "ClinicalRuleTrigger_examinationId_fkey" FOREIGN KEY ("examinationId") REFERENCES public."Examination"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ClinicalRuleTrigger ClinicalRuleTrigger_ruleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalRuleTrigger"
    ADD CONSTRAINT "ClinicalRuleTrigger_ruleId_fkey" FOREIGN KEY ("ruleId") REFERENCES public."ClinicalRule"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClinicalRuleTrigger ClinicalRuleTrigger_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalRuleTrigger"
    ADD CONSTRAINT "ClinicalRuleTrigger_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClinicalRule ClinicalRule_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalRule"
    ADD CONSTRAINT "ClinicalRule_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClinicalRule ClinicalRule_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClinicalRule"
    ADD CONSTRAINT "ClinicalRule_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClndrSal ClndrSal_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClndrSal"
    ADD CONSTRAINT "ClndrSal_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ClndrSal ClndrSal_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClndrSal"
    ADD CONSTRAINT "ClndrSal_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClndrTasksPriority ClndrTasksPriority_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClndrTasksPriority"
    ADD CONSTRAINT "ClndrTasksPriority_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ClndrTasksPriority ClndrTasksPriority_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClndrTasksPriority"
    ADD CONSTRAINT "ClndrTasksPriority_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClndrWrk ClndrWrk_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClndrWrk"
    ADD CONSTRAINT "ClndrWrk_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ClndrWrk ClndrWrk_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ClndrWrk"
    ADD CONSTRAINT "ClndrWrk_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CollectionItem CollectionItem_collectionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CollectionItem"
    ADD CONSTRAINT "CollectionItem_collectionId_fkey" FOREIGN KEY ("collectionId") REFERENCES public."SupplierCollection"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CollectionItem CollectionItem_frameCatalogId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CollectionItem"
    ADD CONSTRAINT "CollectionItem_frameCatalogId_fkey" FOREIGN KEY ("frameCatalogId") REFERENCES public."FrameCatalog"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CollectionItem CollectionItem_lensCatalogId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CollectionItem"
    ADD CONSTRAINT "CollectionItem_lensCatalogId_fkey" FOREIGN KEY ("lensCatalogId") REFERENCES public."LensCatalog"(id) ON UPDATE CASCADE ON DELETE SET NULL;


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
-- Name: ContactLensPricing ContactLensPricing_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensPricing"
    ADD CONSTRAINT "ContactLensPricing_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ContactLensPricing ContactLensPricing_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactLensPricing"
    ADD CONSTRAINT "ContactLensPricing_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: Conversation Conversation_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Conversation"
    ADD CONSTRAINT "Conversation_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Conversation Conversation_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Conversation"
    ADD CONSTRAINT "Conversation_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CrdBuysWorkLab CrdBuysWorkLab_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdBuysWorkLab"
    ADD CONSTRAINT "CrdBuysWorkLab_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CrdBuysWorkLab CrdBuysWorkLab_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdBuysWorkLab"
    ADD CONSTRAINT "CrdBuysWorkLab_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CrdBuysWorkSapak CrdBuysWorkSapak_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdBuysWorkSapak"
    ADD CONSTRAINT "CrdBuysWorkSapak_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CrdBuysWorkSapak CrdBuysWorkSapak_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdBuysWorkSapak"
    ADD CONSTRAINT "CrdBuysWorkSapak_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CrdBuysWorkStat CrdBuysWorkStat_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdBuysWorkStat"
    ADD CONSTRAINT "CrdBuysWorkStat_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CrdBuysWorkStat CrdBuysWorkStat_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdBuysWorkStat"
    ADD CONSTRAINT "CrdBuysWorkStat_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CrdBuysWorkSupply CrdBuysWorkSupply_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdBuysWorkSupply"
    ADD CONSTRAINT "CrdBuysWorkSupply_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CrdBuysWorkSupply CrdBuysWorkSupply_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdBuysWorkSupply"
    ADD CONSTRAINT "CrdBuysWorkSupply_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CrdBuysWorkType CrdBuysWorkType_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdBuysWorkType"
    ADD CONSTRAINT "CrdBuysWorkType_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CrdBuysWorkType CrdBuysWorkType_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdBuysWorkType"
    ADD CONSTRAINT "CrdBuysWorkType_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CrdClensChecksMater CrdClensChecksMater_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensChecksMater"
    ADD CONSTRAINT "CrdClensChecksMater_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CrdClensChecksMater CrdClensChecksMater_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensChecksMater"
    ADD CONSTRAINT "CrdClensChecksMater_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CrdClensChecksPr CrdClensChecksPr_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensChecksPr"
    ADD CONSTRAINT "CrdClensChecksPr_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CrdClensChecksPr CrdClensChecksPr_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensChecksPr"
    ADD CONSTRAINT "CrdClensChecksPr_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CrdClensChecksTint CrdClensChecksTint_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensChecksTint"
    ADD CONSTRAINT "CrdClensChecksTint_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CrdClensChecksTint CrdClensChecksTint_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensChecksTint"
    ADD CONSTRAINT "CrdClensChecksTint_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CrdClensManuf CrdClensManuf_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensManuf"
    ADD CONSTRAINT "CrdClensManuf_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CrdClensManuf CrdClensManuf_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensManuf"
    ADD CONSTRAINT "CrdClensManuf_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CrdClensSolClean CrdClensSolClean_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensSolClean"
    ADD CONSTRAINT "CrdClensSolClean_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CrdClensSolClean CrdClensSolClean_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensSolClean"
    ADD CONSTRAINT "CrdClensSolClean_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CrdClensSolDisinfect CrdClensSolDisinfect_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensSolDisinfect"
    ADD CONSTRAINT "CrdClensSolDisinfect_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CrdClensSolDisinfect CrdClensSolDisinfect_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensSolDisinfect"
    ADD CONSTRAINT "CrdClensSolDisinfect_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CrdClensSolRinse CrdClensSolRinse_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensSolRinse"
    ADD CONSTRAINT "CrdClensSolRinse_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CrdClensSolRinse CrdClensSolRinse_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensSolRinse"
    ADD CONSTRAINT "CrdClensSolRinse_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CrdClensType CrdClensType_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensType"
    ADD CONSTRAINT "CrdClensType_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CrdClensType CrdClensType_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdClensType"
    ADD CONSTRAINT "CrdClensType_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CrdGlassIOPInst CrdGlassIOPInst_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdGlassIOPInst"
    ADD CONSTRAINT "CrdGlassIOPInst_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CrdGlassIOPInst CrdGlassIOPInst_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdGlassIOPInst"
    ADD CONSTRAINT "CrdGlassIOPInst_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CrdGlassRetDist CrdGlassRetDist_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdGlassRetDist"
    ADD CONSTRAINT "CrdGlassRetDist_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CrdGlassRetDist CrdGlassRetDist_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdGlassRetDist"
    ADD CONSTRAINT "CrdGlassRetDist_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CrdGlassRetType CrdGlassRetType_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdGlassRetType"
    ADD CONSTRAINT "CrdGlassRetType_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CrdGlassRetType CrdGlassRetType_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdGlassRetType"
    ADD CONSTRAINT "CrdGlassRetType_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CrdGlassUse CrdGlassUse_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdGlassUse"
    ADD CONSTRAINT "CrdGlassUse_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CrdGlassUse CrdGlassUse_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrdGlassUse"
    ADD CONSTRAINT "CrdGlassUse_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: CreditCard CreditCard_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CreditCard"
    ADD CONSTRAINT "CreditCard_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CreditCard CreditCard_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CreditCard"
    ADD CONSTRAINT "CreditCard_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CreditType CreditType_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CreditType"
    ADD CONSTRAINT "CreditType_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CreditType CreditType_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CreditType"
    ADD CONSTRAINT "CreditType_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CustomReport CustomReport_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CustomReport"
    ADD CONSTRAINT "CustomReport_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CustomReport CustomReport_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CustomReport"
    ADD CONSTRAINT "CustomReport_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CustomerGroup CustomerGroup_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CustomerGroup"
    ADD CONSTRAINT "CustomerGroup_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CustomerLastVisit CustomerLastVisit_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CustomerLastVisit"
    ADD CONSTRAINT "CustomerLastVisit_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CustomerLastVisit CustomerLastVisit_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CustomerLastVisit"
    ADD CONSTRAINT "CustomerLastVisit_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CustomerOrder CustomerOrder_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CustomerOrder"
    ADD CONSTRAINT "CustomerOrder_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CustomerOrder CustomerOrder_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CustomerOrder"
    ADD CONSTRAINT "CustomerOrder_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: DataMigrationError DataMigrationError_migrationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DataMigrationError"
    ADD CONSTRAINT "DataMigrationError_migrationId_fkey" FOREIGN KEY ("migrationId") REFERENCES public."DataMigrationRun"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DataMigrationRun DataMigrationRun_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DataMigrationRun"
    ADD CONSTRAINT "DataMigrationRun_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: DataMigrationRun DataMigrationRun_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DataMigrationRun"
    ADD CONSTRAINT "DataMigrationRun_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: DiseaseDiagnosis DiseaseDiagnosis_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DiseaseDiagnosis"
    ADD CONSTRAINT "DiseaseDiagnosis_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: DiseaseDiagnosis DiseaseDiagnosis_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DiseaseDiagnosis"
    ADD CONSTRAINT "DiseaseDiagnosis_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: Dummy Dummy_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Dummy"
    ADD CONSTRAINT "Dummy_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Dummy Dummy_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Dummy"
    ADD CONSTRAINT "Dummy_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: EquipmentConfig EquipmentConfig_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EquipmentConfig"
    ADD CONSTRAINT "EquipmentConfig_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: EquipmentConfig EquipmentConfig_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EquipmentConfig"
    ADD CONSTRAINT "EquipmentConfig_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: EquipmentConfig EquipmentConfig_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EquipmentConfig"
    ADD CONSTRAINT "EquipmentConfig_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: EquipmentImportLog EquipmentImportLog_equipmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EquipmentImportLog"
    ADD CONSTRAINT "EquipmentImportLog_equipmentId_fkey" FOREIGN KEY ("equipmentId") REFERENCES public."EquipmentConfig"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: EquipmentImportLog EquipmentImportLog_examinationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EquipmentImportLog"
    ADD CONSTRAINT "EquipmentImportLog_examinationId_fkey" FOREIGN KEY ("examinationId") REFERENCES public."Examination"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: EquipmentImportLog EquipmentImportLog_importedBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EquipmentImportLog"
    ADD CONSTRAINT "EquipmentImportLog_importedBy_fkey" FOREIGN KEY ("importedBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: EquipmentImportLog EquipmentImportLog_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EquipmentImportLog"
    ADD CONSTRAINT "EquipmentImportLog_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ExamTemplate ExamTemplate_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ExamTemplate"
    ADD CONSTRAINT "ExamTemplate_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ExamTemplate ExamTemplate_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ExamTemplate"
    ADD CONSTRAINT "ExamTemplate_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: Examination Examination_protocolId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Examination"
    ADD CONSTRAINT "Examination_protocolId_fkey" FOREIGN KEY ("protocolId") REFERENCES public."ClinicalProtocol"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Examination Examination_templateId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Examination"
    ADD CONSTRAINT "Examination_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES public."ExamTemplate"(id) ON UPDATE CASCADE ON DELETE SET NULL;


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
-- Name: Eye Eye_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Eye"
    ADD CONSTRAINT "Eye_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Eye Eye_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Eye"
    ADD CONSTRAINT "Eye_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: FamilyAuditLog FamilyAuditLog_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FamilyAuditLog"
    ADD CONSTRAINT "FamilyAuditLog_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: FamilyAuditLog FamilyAuditLog_relationshipId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FamilyAuditLog"
    ADD CONSTRAINT "FamilyAuditLog_relationshipId_fkey" FOREIGN KEY ("relationshipId") REFERENCES public."FamilyRelationship"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: FamilyAuditLog FamilyAuditLog_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FamilyAuditLog"
    ADD CONSTRAINT "FamilyAuditLog_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: FamilyAuditLog FamilyAuditLog_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FamilyAuditLog"
    ADD CONSTRAINT "FamilyAuditLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FamilyRelationship FamilyRelationship_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FamilyRelationship"
    ADD CONSTRAINT "FamilyRelationship_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FamilyRelationship FamilyRelationship_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FamilyRelationship"
    ADD CONSTRAINT "FamilyRelationship_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: FamilyRelationship FamilyRelationship_relatedCustomerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FamilyRelationship"
    ADD CONSTRAINT "FamilyRelationship_relatedCustomerId_fkey" FOREIGN KEY ("relatedCustomerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: FamilyRelationship FamilyRelationship_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FamilyRelationship"
    ADD CONSTRAINT "FamilyRelationship_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: FamilyRelationship FamilyRelationship_verifiedBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FamilyRelationship"
    ADD CONSTRAINT "FamilyRelationship_verifiedBy_fkey" FOREIGN KEY ("verifiedBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: FaxCommunication FaxCommunication_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FaxCommunication"
    ADD CONSTRAINT "FaxCommunication_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: FaxCommunication FaxCommunication_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FaxCommunication"
    ADD CONSTRAINT "FaxCommunication_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FollowUpReminder FollowUpReminder_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FollowUpReminder"
    ADD CONSTRAINT "FollowUpReminder_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FollowUpReminder FollowUpReminder_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FollowUpReminder"
    ADD CONSTRAINT "FollowUpReminder_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FollowUpReminder FollowUpReminder_examinationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FollowUpReminder"
    ADD CONSTRAINT "FollowUpReminder_examinationId_fkey" FOREIGN KEY ("examinationId") REFERENCES public."Examination"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: FollowUpReminder FollowUpReminder_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FollowUpReminder"
    ADD CONSTRAINT "FollowUpReminder_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: FrameData FrameData_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FrameData"
    ADD CONSTRAINT "FrameData_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: FrameData FrameData_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FrameData"
    ADD CONSTRAINT "FrameData_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FrameTrial FrameTrial_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FrameTrial"
    ADD CONSTRAINT "FrameTrial_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: FrameTrial FrameTrial_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FrameTrial"
    ADD CONSTRAINT "FrameTrial_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FrameTrial FrameTrial_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FrameTrial"
    ADD CONSTRAINT "FrameTrial_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: Household Household_primaryContactId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Household"
    ADD CONSTRAINT "Household_primaryContactId_fkey" FOREIGN KEY ("primaryContactId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Household Household_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Household"
    ADD CONSTRAINT "Household_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: InvMoveType InvMoveType_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InvMoveType"
    ADD CONSTRAINT "InvMoveType_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: InvMoveType InvMoveType_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InvMoveType"
    ADD CONSTRAINT "InvMoveType_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: InventoryReference InventoryReference_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InventoryReference"
    ADD CONSTRAINT "InventoryReference_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: InventoryReference InventoryReference_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InventoryReference"
    ADD CONSTRAINT "InventoryReference_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: InvoiceType InvoiceType_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InvoiceType"
    ADD CONSTRAINT "InvoiceType_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: InvoiceType InvoiceType_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InvoiceType"
    ADD CONSTRAINT "InvoiceType_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: InvoiceVerification InvoiceVerification_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InvoiceVerification"
    ADD CONSTRAINT "InvoiceVerification_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: InvoiceVerification InvoiceVerification_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InvoiceVerification"
    ADD CONSTRAINT "InvoiceVerification_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: ItemCountsYear ItemCountsYear_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ItemCountsYear"
    ADD CONSTRAINT "ItemCountsYear_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ItemCountsYear ItemCountsYear_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ItemCountsYear"
    ADD CONSTRAINT "ItemCountsYear_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ItemStatus ItemStatus_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ItemStatus"
    ADD CONSTRAINT "ItemStatus_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: Lang Lang_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Lang"
    ADD CONSTRAINT "Lang_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Lang Lang_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Lang"
    ADD CONSTRAINT "Lang_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: LensSolution LensSolution_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LensSolution"
    ADD CONSTRAINT "LensSolution_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: LensSolution LensSolution_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LensSolution"
    ADD CONSTRAINT "LensSolution_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LensTreatmentCharacteristic LensTreatmentCharacteristic_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LensTreatmentCharacteristic"
    ADD CONSTRAINT "LensTreatmentCharacteristic_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LensTreatment LensTreatment_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LensTreatment"
    ADD CONSTRAINT "LensTreatment_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: LensTreatment LensTreatment_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LensTreatment"
    ADD CONSTRAINT "LensTreatment_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: Message Message_conversationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Message"
    ADD CONSTRAINT "Message_conversationId_fkey" FOREIGN KEY ("conversationId") REFERENCES public."Conversation"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: MigrationLog MigrationLog_migrationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MigrationLog"
    ADD CONSTRAINT "MigrationLog_migrationId_fkey" FOREIGN KEY ("migrationId") REFERENCES public."MigrationRun"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: MigrationRun MigrationRun_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MigrationRun"
    ADD CONSTRAINT "MigrationRun_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: MigrationRun MigrationRun_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MigrationRun"
    ADD CONSTRAINT "MigrationRun_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: MigrationRun MigrationRun_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MigrationRun"
    ADD CONSTRAINT "MigrationRun_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: MigrationTableResult MigrationTableResult_migrationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MigrationTableResult"
    ADD CONSTRAINT "MigrationTableResult_migrationId_fkey" FOREIGN KEY ("migrationId") REFERENCES public."MigrationRun"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: MovementProperty MovementProperty_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MovementProperty"
    ADD CONSTRAINT "MovementProperty_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: MovementType MovementType_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MovementType"
    ADD CONSTRAINT "MovementType_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: NewProduct NewProduct_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."NewProduct"
    ADD CONSTRAINT "NewProduct_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: NewProduct NewProduct_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."NewProduct"
    ADD CONSTRAINT "NewProduct_productId_fkey" FOREIGN KEY ("productId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: NewProduct NewProduct_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."NewProduct"
    ADD CONSTRAINT "NewProduct_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: PayType PayType_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PayType"
    ADD CONSTRAINT "PayType_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: PayType PayType_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PayType"
    ADD CONSTRAINT "PayType_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: PrintLabel PrintLabel_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PrintLabel"
    ADD CONSTRAINT "PrintLabel_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: PrintLabel PrintLabel_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PrintLabel"
    ADD CONSTRAINT "PrintLabel_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PrlType PrlType_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PrlType"
    ADD CONSTRAINT "PrlType_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: PrlType PrlType_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PrlType"
    ADD CONSTRAINT "PrlType_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ProductProperty ProductProperty_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductProperty"
    ADD CONSTRAINT "ProductProperty_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ProductProperty ProductProperty_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductProperty"
    ADD CONSTRAINT "ProductProperty_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ProductReview ProductReview_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductReview"
    ADD CONSTRAINT "ProductReview_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ProductReview ProductReview_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductReview"
    ADD CONSTRAINT "ProductReview_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ProductReview ProductReview_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductReview"
    ADD CONSTRAINT "ProductReview_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: Profile Profile_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Profile"
    ADD CONSTRAINT "Profile_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Profile Profile_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Profile"
    ADD CONSTRAINT "Profile_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: ReferralSource ReferralSource_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ReferralSource"
    ADD CONSTRAINT "ReferralSource_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ReferralSource ReferralSource_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ReferralSource"
    ADD CONSTRAINT "ReferralSource_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: SMSLen SMSLen_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SMSLen"
    ADD CONSTRAINT "SMSLen_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SMSLen SMSLen_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SMSLen"
    ADD CONSTRAINT "SMSLen_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: SaleItem SaleItem_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SaleItem"
    ADD CONSTRAINT "SaleItem_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


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
-- Name: SapakComment SapakComment_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SapakComment"
    ADD CONSTRAINT "SapakComment_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SapakComment SapakComment_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SapakComment"
    ADD CONSTRAINT "SapakComment_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SapakDest SapakDest_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SapakDest"
    ADD CONSTRAINT "SapakDest_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SapakDest SapakDest_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SapakDest"
    ADD CONSTRAINT "SapakDest_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SapakPerComment SapakPerComment_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SapakPerComment"
    ADD CONSTRAINT "SapakPerComment_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SapakPerComment SapakPerComment_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SapakPerComment"
    ADD CONSTRAINT "SapakPerComment_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SearchOrder SearchOrder_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SearchOrder"
    ADD CONSTRAINT "SearchOrder_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SearchOrder SearchOrder_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SearchOrder"
    ADD CONSTRAINT "SearchOrder_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ServiceType ServiceType_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ServiceType"
    ADD CONSTRAINT "ServiceType_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ServiceType ServiceType_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ServiceType"
    ADD CONSTRAINT "ServiceType_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ShortCut ShortCut_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShortCut"
    ADD CONSTRAINT "ShortCut_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ShortCut ShortCut_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShortCut"
    ADD CONSTRAINT "ShortCut_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: SpecialName SpecialName_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SpecialName"
    ADD CONSTRAINT "SpecialName_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SpecialName SpecialName_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SpecialName"
    ADD CONSTRAINT "SpecialName_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Special Special_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Special"
    ADD CONSTRAINT "Special_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Special Special_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Special"
    ADD CONSTRAINT "Special_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: StaffSchedule StaffSchedule_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."StaffSchedule"
    ADD CONSTRAINT "StaffSchedule_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: StaffSchedule StaffSchedule_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."StaffSchedule"
    ADD CONSTRAINT "StaffSchedule_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: StaffSchedule StaffSchedule_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."StaffSchedule"
    ADD CONSTRAINT "StaffSchedule_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: StockMovement StockMovement_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."StockMovement"
    ADD CONSTRAINT "StockMovement_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: StockMovement StockMovement_invoiceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."StockMovement"
    ADD CONSTRAINT "StockMovement_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES public."Invoice"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: StockMovement StockMovement_movementPropertyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."StockMovement"
    ADD CONSTRAINT "StockMovement_movementPropertyId_fkey" FOREIGN KEY ("movementPropertyId") REFERENCES public."MovementProperty"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: StockMovement StockMovement_movementTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."StockMovement"
    ADD CONSTRAINT "StockMovement_movementTypeId_fkey" FOREIGN KEY ("movementTypeId") REFERENCES public."MovementType"(id) ON UPDATE CASCADE ON DELETE SET NULL;


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
-- Name: SupplierAccountTransaction SupplierAccountTransaction_accountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierAccountTransaction"
    ADD CONSTRAINT "SupplierAccountTransaction_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES public."SupplierTenantAccount"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierAnalytics SupplierAnalytics_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierAnalytics"
    ADD CONSTRAINT "SupplierAnalytics_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierCatalogCategory SupplierCatalogCategory_parentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierCatalogCategory"
    ADD CONSTRAINT "SupplierCatalogCategory_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES public."SupplierCatalogCategory"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SupplierCatalogCategory SupplierCatalogCategory_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierCatalogCategory"
    ADD CONSTRAINT "SupplierCatalogCategory_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierCatalogItem SupplierCatalogItem_categoryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierCatalogItem"
    ADD CONSTRAINT "SupplierCatalogItem_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES public."SupplierCatalogCategory"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SupplierCatalogItem SupplierCatalogItem_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierCatalogItem"
    ADD CONSTRAINT "SupplierCatalogItem_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierCatalogVariant SupplierCatalogVariant_itemId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierCatalogVariant"
    ADD CONSTRAINT "SupplierCatalogVariant_itemId_fkey" FOREIGN KEY ("itemId") REFERENCES public."SupplierCatalogItem"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SupplierCollectionVisibility SupplierCollectionVisibility_collectionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierCollectionVisibility"
    ADD CONSTRAINT "SupplierCollectionVisibility_collectionId_fkey" FOREIGN KEY ("collectionId") REFERENCES public."SupplierCollection"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierCollectionVisibility SupplierCollectionVisibility_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierCollectionVisibility"
    ADD CONSTRAINT "SupplierCollectionVisibility_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierCollection SupplierCollection_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierCollection"
    ADD CONSTRAINT "SupplierCollection_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierDiscountUsage SupplierDiscountUsage_discountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierDiscountUsage"
    ADD CONSTRAINT "SupplierDiscountUsage_discountId_fkey" FOREIGN KEY ("discountId") REFERENCES public."SupplierDiscount"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierDiscount SupplierDiscount_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierDiscount"
    ADD CONSTRAINT "SupplierDiscount_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierInventoryLog SupplierInventoryLog_itemId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierInventoryLog"
    ADD CONSTRAINT "SupplierInventoryLog_itemId_fkey" FOREIGN KEY ("itemId") REFERENCES public."SupplierCatalogItem"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: SupplierOrder SupplierOrder_accountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierOrder"
    ADD CONSTRAINT "SupplierOrder_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES public."SupplierTenantAccount"(id) ON UPDATE CASCADE ON DELETE SET NULL;


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
-- Name: SupplierPriceAlert SupplierPriceAlert_frameCatalogId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierPriceAlert"
    ADD CONSTRAINT "SupplierPriceAlert_frameCatalogId_fkey" FOREIGN KEY ("frameCatalogId") REFERENCES public."FrameCatalog"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SupplierPriceAlert SupplierPriceAlert_lensCatalogId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierPriceAlert"
    ADD CONSTRAINT "SupplierPriceAlert_lensCatalogId_fkey" FOREIGN KEY ("lensCatalogId") REFERENCES public."LensCatalog"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SupplierPriceAlert SupplierPriceAlert_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierPriceAlert"
    ADD CONSTRAINT "SupplierPriceAlert_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierPriceAlert SupplierPriceAlert_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierPriceAlert"
    ADD CONSTRAINT "SupplierPriceAlert_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SupplierPriceHistory SupplierPriceHistory_frameCatalogId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierPriceHistory"
    ADD CONSTRAINT "SupplierPriceHistory_frameCatalogId_fkey" FOREIGN KEY ("frameCatalogId") REFERENCES public."FrameCatalog"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SupplierPriceHistory SupplierPriceHistory_lensCatalogId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierPriceHistory"
    ADD CONSTRAINT "SupplierPriceHistory_lensCatalogId_fkey" FOREIGN KEY ("lensCatalogId") REFERENCES public."LensCatalog"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SupplierPriceHistory SupplierPriceHistory_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierPriceHistory"
    ADD CONSTRAINT "SupplierPriceHistory_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierPriceListItem SupplierPriceListItem_priceListId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierPriceListItem"
    ADD CONSTRAINT "SupplierPriceListItem_priceListId_fkey" FOREIGN KEY ("priceListId") REFERENCES public."SupplierPriceList"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SupplierPriceList SupplierPriceList_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierPriceList"
    ADD CONSTRAINT "SupplierPriceList_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierRFQItem SupplierRFQItem_frameCatalogId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierRFQItem"
    ADD CONSTRAINT "SupplierRFQItem_frameCatalogId_fkey" FOREIGN KEY ("frameCatalogId") REFERENCES public."FrameCatalog"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SupplierRFQItem SupplierRFQItem_lensCatalogId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierRFQItem"
    ADD CONSTRAINT "SupplierRFQItem_lensCatalogId_fkey" FOREIGN KEY ("lensCatalogId") REFERENCES public."LensCatalog"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SupplierRFQItem SupplierRFQItem_rfqId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierRFQItem"
    ADD CONSTRAINT "SupplierRFQItem_rfqId_fkey" FOREIGN KEY ("rfqId") REFERENCES public."SupplierRFQ"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierRFQ SupplierRFQ_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierRFQ"
    ADD CONSTRAINT "SupplierRFQ_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierRFQ SupplierRFQ_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierRFQ"
    ADD CONSTRAINT "SupplierRFQ_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierShipment SupplierShipment_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierShipment"
    ADD CONSTRAINT "SupplierShipment_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SupplierShipment SupplierShipment_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierShipment"
    ADD CONSTRAINT "SupplierShipment_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierStockAlert SupplierStockAlert_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierStockAlert"
    ADD CONSTRAINT "SupplierStockAlert_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierTenantAccount SupplierTenantAccount_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierTenantAccount"
    ADD CONSTRAINT "SupplierTenantAccount_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierTenantActivity SupplierTenantActivity_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierTenantActivity"
    ADD CONSTRAINT "SupplierTenantActivity_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierTenantNote SupplierTenantNote_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierTenantNote"
    ADD CONSTRAINT "SupplierTenantNote_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SupplierUser SupplierUser_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SupplierUser"
    ADD CONSTRAINT "SupplierUser_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Supplier Supplier_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Supplier"
    ADD CONSTRAINT "Supplier_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SysLevel SysLevel_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SysLevel"
    ADD CONSTRAINT "SysLevel_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SysLevel SysLevel_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SysLevel"
    ADD CONSTRAINT "SysLevel_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: VATRate VATRate_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."VATRate"
    ADD CONSTRAINT "VATRate_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: WishlistItem WishlistItem_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WishlistItem"
    ADD CONSTRAINT "WishlistItem_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WishlistItem WishlistItem_wishlistId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."WishlistItem"
    ADD CONSTRAINT "WishlistItem_wishlistId_fkey" FOREIGN KEY ("wishlistId") REFERENCES public."Wishlist"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Wishlist Wishlist_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Wishlist"
    ADD CONSTRAINT "Wishlist_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Wishlist Wishlist_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Wishlist"
    ADD CONSTRAINT "Wishlist_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
-- Name: _DiscountToItems _DiscountToItems_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_DiscountToItems"
    ADD CONSTRAINT "_DiscountToItems_A_fkey" FOREIGN KEY ("A") REFERENCES public."SupplierCatalogItem"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _DiscountToItems _DiscountToItems_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_DiscountToItems"
    ADD CONSTRAINT "_DiscountToItems_B_fkey" FOREIGN KEY ("B") REFERENCES public."SupplierDiscount"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict ApOtFFJEBBr3YigQMF2pAKnMKxJJvIP5nzTpjbtsMrNSWXQyxDEzYv2LCw1aq6G
