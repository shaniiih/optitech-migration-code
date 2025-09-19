-- ----------------------------------------------------------
-- MDB Tools - A library for reading MS Access database files
-- Copyright (C) 2000-2011 Brian Bruns and others.
-- Files in libmdb are licensed under LGPL and the utilities under
-- the GPL, see COPYING.LIB and COPYING files respectively.
-- Check out http://mdbtools.sourceforge.net
-- ----------------------------------------------------------

-- That file uses encoding UTF-8

CREATE TABLE `sqlBases`
 (
	`BaseId`			smallint, 
	`BaseName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdClensBrands`
 (
	`ClensBrandId`			smallint, 
	`ClensBrandName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdClensChecksMater`
 (
	`MaterId`			smallint, 
	`MaterName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdClensChecksPr`
 (
	`PrId`			smallint, 
	`PrName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdClensChecksTint`
 (
	`TintId`			smallint, 
	`TintName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdClensManuf`
 (
	`ClensManufId`			smallint, 
	`ClensManufName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdClensSolClean`
 (
	`ClensSolCleanId`			smallint, 
	`ClensSolCleanName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdClensSolDisinfect`
 (
	`ClensSolDisinfectId`			smallint, 
	`ClensSolDisinfectName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdClensSolRinse`
 (
	`ClensSolRinseId`			smallint, 
	`ClensSolRinseName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdClensTypes`
 (
	`ClensTypeId`			smallint, 
	`ClensTypeName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdGlassBrand`
 (
	`GlassBrandId`			smallint, 
	`GlassBrandName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdGlassCoat`
 (
	`GlassCoatId`			smallint, 
	`GlassCoatName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdGlassColor`
 (
	`GlassColorId`			smallint, 
	`GlassColorName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdGlassIOPInst`
 (
	`IOPInstId`			smallint, 
	`IOPInstName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdGlassMater`
 (
	`GlassMaterId`			smallint, 
	`GlassMaterName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdGlassModel`
 (
	`GlassModelId`			smallint, 
	`GlassModelName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdGlassRetDist`
 (
	`RetDistId`			smallint, 
	`RetDistName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdGlassRetType`
 (
	`RetTypeId`			smallint, 
	`RetTypeName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdGlassRole`
 (
	`GlassRoleId`			smallint, 
	`GlassRoleName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdGlassUse`
 (
	`GlassUseId`			smallint, 
	`GlassUseName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdLVArea`
 (
	`LVAreaId`			smallint, 
	`LVAreaName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdLVCap`
 (
	`LVCapId`			smallint, 
	`LVCapName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdLVFrame`
 (
	`LVFrameId`			smallint, 
	`LVFrameName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlCrdLVManuf`
 (
	`LVManufId`			smallint, 
	`LVManufName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlLnsChars`
 (
	`SapakID`			smallint, 
	`LensTypeID`			smallint, 
	`LensMaterID`			smallint, 
	`LensCharID`			int, 
	`LensCharName`			varchar (50), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlLnsMaterials`
 (
	`LensMaterID`			smallint, 
	`LensMaterName`			varchar (20), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlLnsTreatChars`
 (
	`SapakID`			smallint, 
	`LensTypeID`			smallint, 
	`LensMaterID`			smallint, 
	`TreatCharID`			smallint, 
	`TreatCharName`			varchar (50), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlLnsTypes`
 (
	`LensTypeID`			smallint, 
	`LensTypeName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlSapaks`
 (
	`SapakID`			smallint, 
	`SapakName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlWorkLab`
 (
	`LabID`			smallint, 
	`LabName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlWorkLabel`
 (
	`LabelId`			smallint, 
	`LabelName`			varchar (35), 
	`SapakId`			smallint, 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `sqlWorkSapak`
 (
	`SapakID`			smallint, 
	`SapakName`			varchar (35), 
	`IdCount`			int
);

-- CREATE INDEXES ...

CREATE TABLE `tblBarCodes`
 (
	`BarCodeId`			int not null auto_increment unique, 
	`BarCodeName`			float NOT NULL, 
	`CatNum`			varchar (50) NOT NULL
);

-- CREATE INDEXES ...
ALTER TABLE `tblBarCodes` ADD UNIQUE INDEX `BarCodeName` (`BarCodeName`);
ALTER TABLE `tblBarCodes` ADD UNIQUE INDEX `CatNum` (`CatNum`);
ALTER TABLE `tblBarCodes` ADD PRIMARY KEY (`BarCodeId`);

CREATE TABLE `tblBases`
 (
	`BaseId`			smallint NOT NULL, 
	`BaseName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblBases` ADD UNIQUE INDEX `BaseName` (`BaseName`);
ALTER TABLE `tblBases` ADD PRIMARY KEY (`BaseId`);

CREATE TABLE `tblBisData`
 (
	`BisId`			tinyint NOT NULL, 
	`BisNum`			varchar (20), 
	`BisName`			varchar (25), 
	`Phone`			varchar (12), 
	`Fax`			varchar (12), 
	`Email`			varchar (40), 
	`Address`			varchar (105), 
	`ZipCode`			int, 
	`CreditMode`			tinyint, 
	`CreditDays`			tinyint, 
	`CreditFactor`			float
);

-- CREATE INDEXES ...
ALTER TABLE `tblBisData` ADD PRIMARY KEY (`BisId`);

CREATE TABLE `tblBranchs`
 (
	`BranchId`			smallint, 
	`BranchName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblBranchs` ADD PRIMARY KEY (`BranchId`);

CREATE TABLE `tblCitys`
 (
	`CityId`			smallint NOT NULL, 
	`CityName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCitys` ADD UNIQUE INDEX `CityName` (`CityName`);
ALTER TABLE `tblCitys` ADD PRIMARY KEY (`CityId`);

CREATE TABLE `tblClndrApt`
 (
	`UserID`			int NOT NULL, 
	`AptDate`			datetime NOT NULL, 
	`AptNum`			int not null auto_increment unique, 
	`StarTime`			datetime NOT NULL, 
	`EndTime`			datetime, 
	`AptDesc`			varchar (255), 
	`PerID`			int, 
	`TookPlace`			boolean NOT NULL, 
	`Reminder`			int, 
	`SMSSent`			boolean NOT NULL
);

-- CREATE INDEXES ...
ALTER TABLE `tblClndrApt` ADD PRIMARY KEY (`AptNum`);

CREATE TABLE `tblClndrSal`
 (
	`UserID`			int NOT NULL, 
	`Month`			datetime NOT NULL, 
	`Salery`			float
);

-- CREATE INDEXES ...
ALTER TABLE `tblClndrSal` ADD PRIMARY KEY (`UserID`, `Month`);

CREATE TABLE `tblClndrTasks`
 (
	`UserId`			int, 
	`TaskId`			smallint, 
	`PriorityId`			tinyint, 
	`TaskDesc`			varchar (255), 
	`Done`			boolean NOT NULL, 
	`TaskDate`			datetime
);

-- CREATE INDEXES ...
ALTER TABLE `tblClndrTasks` ADD PRIMARY KEY (`UserId`, `TaskId`);

CREATE TABLE `tblClndrTasksPriority`
 (
	`PriorityId`			tinyint, 
	`PriorityName`			varchar (6)
);

-- CREATE INDEXES ...
ALTER TABLE `tblClndrTasksPriority` ADD PRIMARY KEY (`PriorityId`);

CREATE TABLE `tblClndrWrk`
 (
	`WrkId`			int not null auto_increment unique, 
	`UserID`			int NOT NULL, 
	`WrkDate`			datetime NOT NULL, 
	`WrkTime`			numeric (4, 2), 
	`StartTime`			datetime, 
	`EndTime`			datetime
);

-- CREATE INDEXES ...
ALTER TABLE `tblClndrWrk` ADD PRIMARY KEY (`WrkId`);

CREATE TABLE `tblCLnsChars`
 (
	`CLensCharId`			int NOT NULL, 
	`CLensCharName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCLnsChars` ADD PRIMARY KEY (`CLensCharId`);

CREATE TABLE `tblCLnsPrices`
 (
	`SapakID`			smallint NOT NULL, 
	`CLensTypeID`			smallint NOT NULL, 
	`ClensCharID`			int NOT NULL, 
	`Price`			float, 
	`PubPrice`			float, 
	`RecPrice`			float, 
	`PrivPrice`			float, 
	`Active`			boolean NOT NULL, 
	`Quantity`			int
);

-- CREATE INDEXES ...
ALTER TABLE `tblCLnsPrices` ADD PRIMARY KEY (`SapakID`, `CLensTypeID`, `ClensCharID`);

CREATE TABLE `tblCLnsTypes`
 (
	`CLensTypeID`			smallint NOT NULL, 
	`CLensTypeName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCLnsTypes` ADD PRIMARY KEY (`CLensTypeID`);

CREATE TABLE `tblContactAgents`
 (
	`AgentId`			int not null auto_increment unique, 
	`CntID`			smallint NOT NULL, 
	`AgentName`			varchar (35), 
	`WorkPhone`			varchar (12), 
	`CellPhone`			varchar (12), 
	`Com`			varchar (100)
);

-- CREATE INDEXES ...
ALTER TABLE `tblContactAgents` ADD INDEX `CntId` (`CntID`);
ALTER TABLE `tblContactAgents` ADD PRIMARY KEY (`AgentId`);

CREATE TABLE `tblContacts`
 (
	`CntID`			smallint NOT NULL, 
	`LastName`			varchar (35), 
	`FirstName`			varchar (15), 
	`WorkPhone`			varchar (12), 
	`HomePhone`			varchar (12), 
	`CellPhone`			varchar (12), 
	`Fax`			varchar (12), 
	`Address`			varchar (50), 
	`ZipCode`			int, 
	`CityID`			smallint NOT NULL, 
	`EMail`			varchar (40), 
	`WebSite`			varchar (100), 
	`Comment`			text, 
	`HidCom`			text, 
	`IsSapak`			boolean NOT NULL, 
	`CreditCon`			smallint, 
	`RemDate`			date, 
	`SapakID`			smallint
);

-- CREATE INDEXES ...
ALTER TABLE `tblContacts` ADD PRIMARY KEY (`CntID`);
ALTER TABLE `tblContacts` ADD UNIQUE INDEX `SapakID` (`SapakID`);

CREATE TABLE `tblCrdBuys`
 (
	`BuyId`			int not null auto_increment unique, 
	`BuyDate`			datetime, 
	`GroupId`			int, 
	`PerId`			int, 
	`UserId`			int NOT NULL, 
	`Comment`			varchar (255), 
	`PayedFor`			float, 
	`BuyType`			tinyint, 
	`BuySrcId`			int, 
	`BranchId`			smallint NOT NULL, 
	`Canceled`			boolean NOT NULL
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdBuys` ADD INDEX `BuySrcId` (`BuySrcId`);
ALTER TABLE `tblCrdBuys` ADD PRIMARY KEY (`BuyId`);
ALTER TABLE `tblCrdBuys` ADD INDEX `tblCrdBuysPerId` (`PerId`);

CREATE TABLE `tblCrdBuysChecks`
 (
	`BuyCheckId`			int not null auto_increment unique, 
	`BuyPayId`			int NOT NULL, 
	`CheckId`			varchar (10), 
	`CheckDate`			date, 
	`CheckSum`			float
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdBuysChecks` ADD PRIMARY KEY (`BuyCheckId`);

CREATE TABLE `tblCrdBuysPays`
 (
	`BuyPayId`			int not null auto_increment unique, 
	`BuyId`			int NOT NULL, 
	`InvId`			varchar (25), 
	`PayTypeId`			smallint, 
	`PayDate`			date, 
	`PaySum`			float, 
	`CreditId`			varchar (25), 
	`CreditCardId`			smallint, 
	`CreditTypeId`			tinyint, 
	`CreditPayNum`			tinyint
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdBuysPays` ADD PRIMARY KEY (`BuyPayId`);

CREATE TABLE `tblCrdBuysWorkLabels`
 (
	`LabelId`			smallint NOT NULL, 
	`LabelName`			varchar (35), 
	`ItemCode`			smallint NOT NULL, 
	`SapakId`			smallint NOT NULL
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdBuysWorkLabels` ADD PRIMARY KEY (`LabelId`);

CREATE TABLE `tblCrdBuysWorkLabs`
 (
	`LabID`			smallint NOT NULL, 
	`LabName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdBuysWorkLabs` ADD PRIMARY KEY (`LabID`);

CREATE TABLE `tblCrdBuysWorks`
 (
	`WorkId`			int not null auto_increment unique, 
	`WorkDate`			datetime, 
	`PerId`			int NOT NULL, 
	`UserId`			int NOT NULL, 
	`WorkTypeId`			smallint NOT NULL, 
	`CheckDate`			datetime, 
	`WorkStatId`			smallint NOT NULL, 
	`WorkSupplyId`			smallint NOT NULL, 
	`LabId`			smallint, 
	`SapakId`			smallint, 
	`BagNum`			varchar (8), 
	`PromiseDate`			datetime, 
	`DeliverDate`			datetime, 
	`Comment`			text, 
	`FSapakId`			smallint, 
	`FLabelId`			smallint, 
	`FModel`			varchar (20), 
	`FColor`			varchar (20), 
	`FSize`			varchar (5), 
	`FrameSold`			smallint, 
	`LnsSapakId`			smallint, 
	`GlassSapakId`			smallint, 
	`ClensSapakId`			smallint, 
	`GlassId`			int, 
	`Wtype`			tinyint, 
	`SMSSent`			boolean NOT NULL, 
	`ItemId`			int, 
	`TailId`			int, 
	`Canceled`			boolean NOT NULL
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdBuysWorks` ADD PRIMARY KEY (`WorkId`);

CREATE TABLE `tblCrdBuysWorkSapaks`
 (
	`SapakID`			smallint NOT NULL, 
	`SapakName`			varchar (35), 
	`ItemCode`			smallint NOT NULL
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdBuysWorkSapaks` ADD UNIQUE INDEX `ItemCode` (`ItemCode`);
ALTER TABLE `tblCrdBuysWorkSapaks` ADD PRIMARY KEY (`SapakID`);

CREATE TABLE `tblCrdBuysWorkStats`
 (
	`WorkStatId`			smallint NOT NULL, 
	`WorkStatName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdBuysWorkStats` ADD PRIMARY KEY (`WorkStatId`);

CREATE TABLE `tblCrdBuysWorkTypes`
 (
	`WorkTypeId`			smallint NOT NULL, 
	`WorkTypeName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdBuysWorkTypes` ADD PRIMARY KEY (`WorkTypeId`);

CREATE TABLE `tblCrdClensBrands`
 (
	`ClensBrandId`			smallint, 
	`ClensBrandName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdClensBrands` ADD UNIQUE INDEX `ClensBrandName` (`ClensBrandName`);
ALTER TABLE `tblCrdClensBrands` ADD PRIMARY KEY (`ClensBrandId`);

CREATE TABLE `tblCrdClensChecks`
 (
	`PerId`			int NOT NULL, 
	`CheckDate`			datetime NOT NULL, 
	`UserId`			int NOT NULL, 
	`ReCheckDate`			datetime, 
	`PupDiam`			varchar (4), 
	`CornDiam`			numeric (3, 1), 
	`EyeLidKey`			numeric (3, 1), 
	`BUT`			tinyint, 
	`ShirR`			varchar (4), 
	`ShirL`			varchar (4), 
	`Ecolor`			varchar (15), 
	`rHR`			numeric (3, 2), 
	`rHL`			numeric (3, 2), 
	`rVR`			numeric (3, 2), 
	`rVL`			numeric (3, 2), 
	`AxHR`			tinyint, 
	`AxHL`			tinyint, 
	`rTR`			numeric (3, 2), 
	`rTL`			numeric (3, 2), 
	`rNR`			numeric (3, 2), 
	`rNL`			numeric (3, 2), 
	`rIR`			numeric (3, 2), 
	`rIL`			numeric (3, 2), 
	`rSR`			numeric (3, 2), 
	`rSL`			numeric (3, 2), 
	`DiamR`			numeric (3, 1), 
	`DiamL`			numeric (3, 1), 
	`BC1R`			varchar (5), 
	`BC1L`			varchar (5), 
	`BC2R`			numeric (3, 2), 
	`BC2L`			numeric (3, 2), 
	`OZR`			varchar (3), 
	`OZL`			varchar (3), 
	`PrR`			smallint NOT NULL, 
	`PrL`			smallint NOT NULL, 
	`SphR`			varchar (6), 
	`SphL`			varchar (6), 
	`CylR`			numeric (4, 2), 
	`CylL`			numeric (4, 2), 
	`AxR`			tinyint, 
	`AxL`			tinyint, 
	`MaterR`			smallint NOT NULL, 
	`MaterL`			smallint NOT NULL, 
	`TintR`			smallint NOT NULL, 
	`TintL`			smallint NOT NULL, 
	`VAR`			varchar (5), 
	`VAL`			varchar (5), 
	`VA`			varchar (5), 
	`PHR`			varchar (5), 
	`PHL`			varchar (5), 
	`ClensTypeIdR`			smallint, 
	`ClensTypeIdL`			smallint, 
	`ClensManufIdR`			smallint, 
	`ClensManufIdL`			smallint, 
	`ClensBrandIdR`			smallint, 
	`ClensBrandIdL`			smallint, 
	`ClensSolCleanId`			smallint, 
	`ClensSolDisinfectId`			smallint, 
	`ClensSolRinseId`			smallint, 
	`Comments`			text, 
	`AddR`			varchar (4), 
	`AddL`			varchar (4), 
	`BUTL`			tinyint, 
	`BlinkFreq`			varchar (15), 
	`BlinkQual`			varchar (15), 
	`ClensId`			int not null auto_increment unique, 
	`FitCom`			text
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdClensChecks` ADD PRIMARY KEY (`PerId`, `CheckDate`);

CREATE TABLE `tblCrdClensChecksMater`
 (
	`MaterId`			smallint NOT NULL, 
	`MaterName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdClensChecksMater` ADD UNIQUE INDEX `MaterName` (`MaterName`);
ALTER TABLE `tblCrdClensChecksMater` ADD PRIMARY KEY (`MaterId`);

CREATE TABLE `tblCrdClensChecksPr`
 (
	`PrId`			smallint NOT NULL, 
	`PrName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdClensChecksPr` ADD PRIMARY KEY (`PrId`);
ALTER TABLE `tblCrdClensChecksPr` ADD UNIQUE INDEX `PrName` (`PrName`);

CREATE TABLE `tblCrdClensChecksTint`
 (
	`TintId`			smallint NOT NULL, 
	`TintName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdClensChecksTint` ADD PRIMARY KEY (`TintId`);
ALTER TABLE `tblCrdClensChecksTint` ADD UNIQUE INDEX `TintName` (`TintName`);

CREATE TABLE `tblCrdClensManuf`
 (
	`ClensManufId`			smallint, 
	`ClensManufName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdClensManuf` ADD PRIMARY KEY (`ClensManufId`);

CREATE TABLE `tblCrdClensSolClean`
 (
	`ClensSolCleanId`			smallint, 
	`ClensSolCleanName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdClensSolClean` ADD UNIQUE INDEX `ClensSolCleanName` (`ClensSolCleanName`);
ALTER TABLE `tblCrdClensSolClean` ADD PRIMARY KEY (`ClensSolCleanId`);

CREATE TABLE `tblCrdClensSolDisinfect`
 (
	`ClensSolDisinfectId`			smallint, 
	`ClensSolDisinfectName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdClensSolDisinfect` ADD UNIQUE INDEX `ClensSolDisinfectName` (`ClensSolDisinfectName`);
ALTER TABLE `tblCrdClensSolDisinfect` ADD PRIMARY KEY (`ClensSolDisinfectId`);

CREATE TABLE `tblCrdClensSolRinse`
 (
	`ClensSolRinseId`			smallint, 
	`ClensSolRinseName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdClensSolRinse` ADD UNIQUE INDEX `ClensSolRinseName` (`ClensSolRinseName`);
ALTER TABLE `tblCrdClensSolRinse` ADD PRIMARY KEY (`ClensSolRinseId`);

CREATE TABLE `tblCrdClensTypes`
 (
	`ClensTypeId`			smallint, 
	`ClensTypeName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdClensTypes` ADD UNIQUE INDEX `ClensTypeName` (`ClensTypeName`);
ALTER TABLE `tblCrdClensTypes` ADD PRIMARY KEY (`ClensTypeId`);

CREATE TABLE `tblCrdClinicChars`
 (
	`EyeCheckCharId`			smallint, 
	`EyeCheckCharName`			varchar (20), 
	`EyeCheckCharType`			tinyint
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdClinicChars` ADD PRIMARY KEY (`EyeCheckCharId`);

CREATE TABLE `tblCrdClinicChecks`
 (
	`ClinicCheckId`			int not null auto_increment unique, 
	`PerId`			int NOT NULL, 
	`UserId`			int NOT NULL, 
	`CheckDate`			datetime NOT NULL, 
	`ReCheckDate`			datetime, 
	`GlassCheckDate`			datetime, 
	`YN1`			boolean NOT NULL, 
	`YN2`			boolean NOT NULL, 
	`YN3`			boolean NOT NULL, 
	`YN4`			boolean NOT NULL, 
	`YN5`			boolean NOT NULL, 
	`YN6`			boolean NOT NULL, 
	`YN7`			boolean NOT NULL, 
	`YN8`			boolean NOT NULL, 
	`YN9`			boolean NOT NULL, 
	`YN10`			boolean NOT NULL, 
	`YN11`			boolean NOT NULL, 
	`YN12`			boolean NOT NULL, 
	`YN13`			boolean NOT NULL, 
	`YN14`			boolean NOT NULL, 
	`YN15`			boolean NOT NULL, 
	`YN16`			boolean NOT NULL, 
	`YN17`			boolean NOT NULL, 
	`YN18`			boolean NOT NULL, 
	`YN19`			boolean NOT NULL, 
	`YN20`			boolean NOT NULL, 
	`YN21`			boolean NOT NULL, 
	`YN22`			boolean NOT NULL, 
	`YN23`			boolean NOT NULL, 
	`YN24`			boolean NOT NULL, 
	`YN25`			boolean NOT NULL, 
	`YN26`			boolean NOT NULL, 
	`YN27`			boolean NOT NULL, 
	`YN28`			boolean NOT NULL, 
	`YN29`			boolean NOT NULL, 
	`YN30`			boolean NOT NULL, 
	`YN31`			boolean NOT NULL, 
	`YN32`			boolean NOT NULL, 
	`YN33`			boolean NOT NULL, 
	`YN34`			boolean NOT NULL, 
	`YN35`			boolean NOT NULL, 
	`YN36`			boolean NOT NULL, 
	`YN37`			boolean NOT NULL, 
	`YN38`			boolean NOT NULL, 
	`YN39`			boolean NOT NULL, 
	`YN40`			boolean NOT NULL, 
	`YN41`			boolean NOT NULL, 
	`YN42`			boolean NOT NULL, 
	`YN43`			boolean NOT NULL, 
	`YN44`			boolean NOT NULL, 
	`YN45`			boolean NOT NULL, 
	`YN46`			boolean NOT NULL, 
	`YN47`			boolean NOT NULL, 
	`YN48`			boolean NOT NULL, 
	`YN49`			boolean NOT NULL, 
	`YN50`			boolean NOT NULL, 
	`YN51`			boolean NOT NULL, 
	`YN52`			boolean NOT NULL, 
	`YN53`			boolean NOT NULL, 
	`YN54`			boolean NOT NULL, 
	`YN55`			boolean NOT NULL, 
	`YN56`			boolean NOT NULL, 
	`YN57`			boolean NOT NULL, 
	`YN58`			boolean NOT NULL, 
	`Meds`			varchar (120), 
	`MedsEye`			varchar (120), 
	`PrevTreat`			varchar (255), 
	`Com`			varchar (120), 
	`Other1`			varchar (60), 
	`Other2`			varchar (60), 
	`Other3`			varchar (60), 
	`Other4`			varchar (60), 
	`EyeLidR`			varchar (60), 
	`EyeLidL`			varchar (60), 
	`TearWayR`			varchar (60), 
	`TearWayL`			varchar (60), 
	`ChoroidR`			varchar (60), 
	`ChoroidL`			varchar (60), 
	`LimitR`			varchar (60), 
	`LimitL`			varchar (60), 
	`CornR`			varchar (60), 
	`CornL`			varchar (60), 
	`ChamberR`			varchar (60), 
	`ChamberL`			varchar (60), 
	`AngleR`			varchar (60), 
	`AngleL`			varchar (60), 
	`IOPR`			varchar (60), 
	`IOPL`			varchar (60), 
	`IrisR`			varchar (60), 
	`IrisL`			varchar (60), 
	`PupilR`			varchar (60), 
	`PupilL`			varchar (60), 
	`LensR`			varchar (60), 
	`LensL`			varchar (60), 
	`EnamelR`			varchar (60), 
	`EnamelL`			varchar (60), 
	`DiskR`			varchar (60), 
	`DiskL`			varchar (60), 
	`CDAVR`			varchar (60), 
	`CDAVL`			varchar (60), 
	`MaculaR`			varchar (60), 
	`MaculaL`			varchar (60), 
	`PerimeterR`			varchar (60), 
	`PerimeterL`			varchar (60), 
	`AmslaR`			varchar (60), 
	`AmslaL`			varchar (60), 
	`VFieldR`			varchar (60), 
	`VFieldL`			varchar (60), 
	`Pic3`			varchar (255), 
	`Pic4`			varchar (255), 
	`CSR`			varchar (10), 
	`CSL`			varchar (10)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdClinicChecks` ADD PRIMARY KEY (`ClinicCheckId`);

CREATE TABLE `tblCrdDiags`
 (
	`PerId`			int NOT NULL, 
	`CheckDate`			datetime NOT NULL, 
	`UserId`			int, 
	`Complaints`			text, 
	`illnesses`			text, 
	`OptDiag`			text, 
	`DocRef`			varchar (255), 
	`Summary`			text
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdDiags` ADD PRIMARY KEY (`PerId`, `CheckDate`);

CREATE TABLE `tblCrdDisDiags`
 (
	`PerId`			int NOT NULL, 
	`CheckDate`			datetime NOT NULL, 
	`PushUp`			smallint, 
	`MinusLens`			smallint, 
	`MonAccFac6`			float, 
	`MonAccFac7`			float, 
	`MonAccFac8`			float, 
	`MonAccFac13`			float, 
	`BinAccFac6`			float, 
	`BinAccFac7`			float, 
	`BinAccFac8`			float, 
	`BinAccFac13`			float, 
	`MEMRet`			float, 
	`FusedXCyl`			float, 
	`NRA`			float, 
	`PRA`			float, 
	`CoverDist`			varchar (7), 
	`CoverNear`			varchar (7), 
	`DistLatFor`			varchar (7), 
	`DistVerFor`			varchar (7), 
	`NearLatFor`			varchar (7), 
	`NearVerFor`			varchar (7), 
	`ACARatio`			varchar (6), 
	`SmverBo6M`			varchar (9), 
	`SmverBi6M`			varchar (9), 
	`SmverBo40CM`			varchar (9), 
	`SmverBi40CM`			varchar (9), 
	`StverBo7`			varchar (5), 
	`StverBi7`			varchar (5), 
	`StverBo6M`			varchar (5), 
	`StverBi6M`			varchar (5), 
	`StverBo40CM`			varchar (5), 
	`StverBi40CM`			varchar (5), 
	`JmpVer5`			float, 
	`JmpVer8`			float, 
	`AccTarget`			varchar (12), 
	`Penlight`			varchar (12), 
	`PenLightRG`			varchar (12), 
	`Summary`			text, 
	`UserId`			int
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdDisDiags` ADD PRIMARY KEY (`PerId`, `CheckDate`);

CREATE TABLE `tblCrdFrps`
 (
	`FrpId`			int not null auto_increment unique, 
	`PerId`			int NOT NULL, 
	`ClensBrandId`			smallint NOT NULL, 
	`FrpDate`			datetime, 
	`TotalFrp`			smallint, 
	`ExchangeNum`			tinyint, 
	`DayInterval`			smallint, 
	`Supply`			boolean NOT NULL, 
	`Comments`			text, 
	`SaleAdd`			boolean NOT NULL
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdFrps` ADD PRIMARY KEY (`FrpId`);

CREATE TABLE `tblCrdFrpsLines`
 (
	`FrpLineId`			int not null auto_increment unique, 
	`FrpId`			int, 
	`LineDate`			datetime, 
	`Quantity`			smallint
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdFrpsLines` ADD PRIMARY KEY (`FrpLineId`);

CREATE TABLE `tblCrdGlassChecks`
 (
	`PerId`			int NOT NULL, 
	`CheckDate`			datetime NOT NULL, 
	`UserId`			int NOT NULL, 
	`ReCheckDate`			datetime, 
	`FVR`			varchar (4), 
	`FVL`			varchar (4), 
	`SphR`			varchar (6), 
	`SphL`			varchar (6), 
	`CylR`			numeric (4, 2), 
	`CylL`			numeric (4, 2), 
	`AxR`			tinyint, 
	`AxL`			tinyint, 
	`PrisR`			numeric (4, 2), 
	`PrisL`			numeric (4, 2), 
	`BaseR`			smallint NOT NULL, 
	`BaseL`			smallint NOT NULL, 
	`VAR`			varchar (6), 
	`VAL`			varchar (6), 
	`VA`			varchar (6), 
	`PHR`			varchar (5), 
	`PHL`			varchar (5), 
	`ReadR`			numeric (4, 2), 
	`ReadL`			numeric (4, 2), 
	`AddBaseR`			smallint NOT NULL, 
	`AddBaseL`			smallint NOT NULL, 
	`AddPrisR`			numeric (4, 2), 
	`AddPrisL`			numeric (4, 2), 
	`IntR`			numeric (3, 2), 
	`IntL`			numeric (3, 2), 
	`BifR`			numeric (3, 2), 
	`BifL`			numeric (3, 2), 
	`MulR`			numeric (3, 2), 
	`MulL`			numeric (3, 2), 
	`HighR`			numeric (4, 2), 
	`HighL`			numeric (4, 2), 
	`PDDistR`			numeric (4, 1), 
	`PDDistL`			numeric (4, 1), 
	`PDReadR`			numeric (4, 1), 
	`PDReadL`			numeric (4, 1), 
	`DominEye`			varchar (1), 
	`IOPL`			tinyint, 
	`IOPR`			tinyint, 
	`IOPInstId`			smallint NOT NULL, 
	`IOPTime`			datetime, 
	`JR`			varchar (4), 
	`JL`			varchar (4), 
	`Comments`			text, 
	`PDDistA`			numeric (4, 1), 
	`PDReadA`			numeric (4, 1), 
	`PFVR`			varchar (4), 
	`PFVL`			varchar (4), 
	`PSphR`			varchar (6), 
	`PSphL`			varchar (6), 
	`PCylR`			numeric (4, 2), 
	`PCylL`			numeric (4, 2), 
	`PAxR`			tinyint, 
	`PAxL`			tinyint, 
	`PPrisR`			numeric (4, 2), 
	`PPrisL`			numeric (4, 2), 
	`PBaseR`			smallint NOT NULL, 
	`PBaseL`			smallint NOT NULL, 
	`PVAR`			varchar (6), 
	`PVAL`			varchar (6), 
	`PVA`			varchar (6), 
	`PPHR`			varchar (5), 
	`PPHL`			varchar (5), 
	`PReadR`			numeric (4, 2), 
	`PReadL`			numeric (4, 2), 
	`PAddBaseR`			smallint NOT NULL, 
	`PAddBaseL`			smallint NOT NULL, 
	`PAddPrisR`			numeric (4, 2), 
	`PAddPrisL`			numeric (4, 2), 
	`PIntR`			numeric (3, 2), 
	`PIntL`			numeric (3, 2), 
	`PBifR`			numeric (3, 2), 
	`PBifL`			numeric (3, 2), 
	`PMulR`			numeric (3, 2), 
	`PMulL`			numeric (3, 2), 
	`PHighR`			numeric (4, 2), 
	`PHighL`			numeric (4, 2), 
	`PPDDistR`			numeric (4, 1), 
	`PPDDistL`			numeric (4, 1), 
	`PPDReadR`			numeric (4, 1), 
	`PPDReadL`			numeric (4, 1), 
	`PPDDistA`			numeric (4, 1), 
	`PPDReadA`			numeric (4, 1), 
	`PJR`			varchar (4), 
	`PJL`			varchar (4), 
	`CSR`			varchar (10), 
	`CSL`			varchar (10), 
	`ExtPrisR`			numeric (4, 2), 
	`ExtPrisL`			numeric (4, 2), 
	`ExtBaseR`			smallint NOT NULL, 
	`ExtBaseL`			smallint NOT NULL, 
	`AddExtPrisR`			numeric (4, 2), 
	`AddExtPrisL`			numeric (4, 2), 
	`AddExtBaseR`			smallint NOT NULL, 
	`AddExtBaseL`			smallint NOT NULL, 
	`ReadDR`			varchar (5), 
	`ReadDL`			varchar (5), 
	`IntDR`			varchar (5), 
	`IntDL`			varchar (5), 
	`BifDR`			varchar (5), 
	`BifDL`			varchar (5), 
	`CTD`			varchar (100), 
	`CTN`			varchar (100), 
	`CCD`			varchar (50), 
	`CCN`			varchar (50), 
	`HidCom`			text, 
	`AmslerR`			varchar (100), 
	`AmslerL`			varchar (100), 
	`NPCR`			varchar (10), 
	`NPAL`			numeric (3, 1), 
	`NPAR`			numeric (3, 1), 
	`GlassCId`			int not null auto_increment unique
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdGlassChecks` ADD PRIMARY KEY (`PerId`, `CheckDate`);

CREATE TABLE `tblCrdGlassChecksFrm`
 (
	`PerId`			int, 
	`CheckDate`			datetime, 
	`GlassId`			int, 
	`FSapakId`			smallint, 
	`FLabelId`			smallint, 
	`FModel`			varchar (20), 
	`FColor`			varchar (20), 
	`FSize`			varchar (5), 
	`Comments`			varchar (25)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdGlassChecksFrm` ADD PRIMARY KEY (`PerId`, `CheckDate`, `GlassId`);

CREATE TABLE `tblCrdGlassChecksGlasses`
 (
	`PerId`			int, 
	`CheckDate`			datetime, 
	`GlassId`			int not null auto_increment unique, 
	`RoleId`			smallint, 
	`MaterId`			smallint, 
	`BrandId`			smallint, 
	`CoatId`			smallint, 
	`ModelId`			smallint, 
	`ColorId`			smallint, 
	`Diam`			varchar (5), 
	`Segment`			smallint, 
	`Com`			varchar (25), 
	`SaleAdd`			boolean NOT NULL
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdGlassChecksGlasses` ADD PRIMARY KEY (`PerId`, `CheckDate`, `GlassId`);

CREATE TABLE `tblCrdGlassChecksGlassesP`
 (
	`PerId`			int, 
	`CheckDate`			datetime, 
	`GlassPId`			int not null auto_increment unique, 
	`UseId`			smallint, 
	`SapakId`			smallint, 
	`LensTypeId`			smallint, 
	`LensMaterId`			smallint, 
	`LensCharId`			int, 
	`TreatCharId`			smallint, 
	`TreatCharId1`			smallint, 
	`TreatCharId2`			smallint, 
	`TreatCharId3`			smallint, 
	`Diam`			varchar (5), 
	`Com`			varchar (255), 
	`EyeId`			tinyint, 
	`SaleAdd`			boolean NOT NULL
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdGlassChecksGlassesP` ADD PRIMARY KEY (`PerId`, `CheckDate`, `GlassPId`);

CREATE TABLE `tblCrdGlassChecksPrevs`
 (
	`PerId`			int, 
	`CheckDate`			datetime, 
	`PrevId`			int not null auto_increment unique, 
	`RefSphR`			varchar (6), 
	`RefSphL`			varchar (6), 
	`RefCylR`			numeric (4, 2), 
	`RefCylL`			numeric (4, 2), 
	`RefAxR`			tinyint, 
	`RefAxL`			tinyint, 
	`RetTypeId1`			smallint NOT NULL, 
	`RetDistId1`			smallint NOT NULL, 
	`RetCom1`			text, 
	`RefSphR2`			varchar (6), 
	`RefSphL2`			varchar (6), 
	`RefCylR2`			numeric (4, 2), 
	`RefCylL2`			numeric (4, 2), 
	`RefAxR2`			tinyint, 
	`RefAxL2`			tinyint, 
	`RetTypeId2`			smallint NOT NULL, 
	`RetDistId2`			smallint NOT NULL, 
	`RetCom2`			text, 
	`SphR1`			varchar (6), 
	`SphL1`			varchar (6), 
	`CylR1`			numeric (4, 2), 
	`CylL1`			numeric (4, 2), 
	`AxR1`			tinyint, 
	`AxL1`			tinyint, 
	`PrisR1`			numeric (4, 2), 
	`PrisL1`			numeric (4, 2), 
	`BaseR1`			smallint NOT NULL, 
	`BaseL1`			smallint NOT NULL, 
	`VAR1`			varchar (6), 
	`VAL1`			varchar (6), 
	`VA1`			varchar (6), 
	`PHR1`			varchar (5), 
	`PHL1`			varchar (5), 
	`ExtPrisR1`			numeric (4, 2), 
	`ExtPrisL1`			numeric (4, 2), 
	`ExtBaseR1`			smallint NOT NULL, 
	`ExtBaseL1`			smallint NOT NULL, 
	`Comments1`			text, 
	`PDDistR1`			numeric (4, 1), 
	`PDDistL1`			numeric (4, 1), 
	`PDDistA1`			numeric (4, 1), 
	`AddR1`			numeric (3, 2), 
	`AddL1`			numeric (3, 2)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdGlassChecksPrevs` ADD PRIMARY KEY (`PerId`, `CheckDate`, `PrevId`);

CREATE TABLE `tblCrdGlassCoat`
 (
	`GlassCoatId`			smallint, 
	`GlassCoatName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdGlassCoat` ADD UNIQUE INDEX `GlassCoatName` (`GlassCoatName`);
ALTER TABLE `tblCrdGlassCoat` ADD PRIMARY KEY (`GlassCoatId`);

CREATE TABLE `tblCrdGlassIOPInsts`
 (
	`IOPInstId`			smallint NOT NULL, 
	`IOPInstName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdGlassIOPInsts` ADD UNIQUE INDEX `BaseName` (`IOPInstName`);
ALTER TABLE `tblCrdGlassIOPInsts` ADD PRIMARY KEY (`IOPInstId`);

CREATE TABLE `tblCrdGlassMater`
 (
	`GlassMaterId`			smallint, 
	`GlassMaterName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdGlassMater` ADD UNIQUE INDEX `GlassMaterName` (`GlassMaterName`);
ALTER TABLE `tblCrdGlassMater` ADD PRIMARY KEY (`GlassMaterId`);

CREATE TABLE `tblCrdGlassModel`
 (
	`GlassModelId`			smallint, 
	`GlassModelName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdGlassModel` ADD UNIQUE INDEX `GlassBrandName` (`GlassModelName`);
ALTER TABLE `tblCrdGlassModel` ADD PRIMARY KEY (`GlassModelId`);

CREATE TABLE `tblCrdGlassRetDists`
 (
	`RetDistId`			smallint NOT NULL, 
	`RetDistName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdGlassRetDists` ADD UNIQUE INDEX `BaseName` (`RetDistName`);
ALTER TABLE `tblCrdGlassRetDists` ADD PRIMARY KEY (`RetDistId`);

CREATE TABLE `tblCrdGlassRetTypes`
 (
	`RetTypeId`			smallint NOT NULL, 
	`RetTypeName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdGlassRetTypes` ADD UNIQUE INDEX `BaseName` (`RetTypeName`);
ALTER TABLE `tblCrdGlassRetTypes` ADD PRIMARY KEY (`RetTypeId`);

CREATE TABLE `tblCrdGlassRole`
 (
	`GlassRoleId`			smallint, 
	`GlassRoleName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdGlassRole` ADD UNIQUE INDEX `GlassRoleName` (`GlassRoleName`);
ALTER TABLE `tblCrdGlassRole` ADD PRIMARY KEY (`GlassRoleId`);

CREATE TABLE `tblCrdLVArea`
 (
	`LVAreaId`			smallint, 
	`LVAreaName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdLVArea` ADD UNIQUE INDEX `GlassBrandName` (`LVAreaName`);
ALTER TABLE `tblCrdLVArea` ADD PRIMARY KEY (`LVAreaId`);

CREATE TABLE `tblCrdLVCap`
 (
	`LVCapId`			smallint, 
	`LVCapName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdLVCap` ADD UNIQUE INDEX `GlassBrandName` (`LVCapName`);
ALTER TABLE `tblCrdLVCap` ADD PRIMARY KEY (`LVCapId`);

CREATE TABLE `tblCrdLVChecks`
 (
	`PerId`			int, 
	`CheckDate`			datetime, 
	`LVId`			int not null auto_increment unique, 
	`EyeId`			tinyint, 
	`PDR`			numeric (4, 1), 
	`PDL`			numeric (4, 1), 
	`ManufId`			smallint, 
	`FrameId`			smallint, 
	`AreaId`			smallint, 
	`CapId`			smallint, 
	`VAD`			varchar (6), 
	`VAN`			varchar (6), 
	`VADL`			varchar (6), 
	`VANL`			varchar (6), 
	`Com`			text
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdLVChecks` ADD PRIMARY KEY (`PerId`, `CheckDate`, `LVId`);

CREATE TABLE `tblCrdLVFrame`
 (
	`LVFrameId`			smallint, 
	`LVFrameName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdLVFrame` ADD UNIQUE INDEX `GlassBrandName` (`LVFrameName`);
ALTER TABLE `tblCrdLVFrame` ADD PRIMARY KEY (`LVFrameId`);

CREATE TABLE `tblCrdLVManuf`
 (
	`LVManufId`			smallint, 
	`LVManufName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdLVManuf` ADD UNIQUE INDEX `GlassBrandName` (`LVManufName`);
ALTER TABLE `tblCrdLVManuf` ADD PRIMARY KEY (`LVManufId`);

CREATE TABLE `tblCrdOrder`
 (
	`ItemData`			smallint, 
	`ListIndex`			smallint, 
	`Desc`			varchar (50), 
	`Deaf`			smallint, 
	`LblWiz`			boolean NOT NULL, 
	`LblWizType`			tinyint, 
	`LblWizFld`			text, 
	`LetterFld`			text, 
	`LetterWiz`			boolean NOT NULL
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdOrder` ADD PRIMARY KEY (`ItemData`);

CREATE TABLE `tblCrdOrthoks`
 (
	`OrthokId`			int not null auto_increment unique, 
	`PerId`			int NOT NULL, 
	`CheckDate`			datetime NOT NULL, 
	`ReCheckDate`			datetime, 
	`UserId`			int NOT NULL, 
	`rHR`			numeric (3, 2), 
	`rHL`			numeric (3, 2), 
	`rVR`			numeric (3, 2), 
	`rVL`			numeric (3, 2), 
	`AxHR`			tinyint, 
	`AxHL`			tinyint, 
	`rTR`			numeric (3, 2), 
	`rTL`			numeric (3, 2), 
	`rNR`			numeric (3, 2), 
	`rNL`			numeric (3, 2), 
	`rIR`			numeric (3, 2), 
	`rIL`			numeric (3, 2), 
	`rSR`			numeric (3, 2), 
	`rSL`			numeric (3, 2), 
	`DiamR`			numeric (3, 1), 
	`DiamL`			numeric (3, 1), 
	`BC1R`			varchar (5), 
	`BC1L`			varchar (5), 
	`OZR`			varchar (5), 
	`OZL`			varchar (5), 
	`SphR`			varchar (6), 
	`SphL`			varchar (6), 
	`FCR`			numeric (4, 2), 
	`FCL`			numeric (4, 2), 
	`ACR`			numeric (4, 2), 
	`ACL`			numeric (4, 2), 
	`AC2R`			numeric (4, 2), 
	`AC2L`			numeric (4, 2), 
	`SBR`			numeric (4, 2), 
	`SBL`			numeric (4, 2), 
	`EGR`			varchar (8), 
	`EGL`			varchar (8), 
	`FCRCT`			numeric (4, 2), 
	`FCLCT`			numeric (4, 2), 
	`ACRCT`			numeric (4, 2), 
	`ACLCT`			numeric (4, 2), 
	`AC2RCT`			numeric (4, 2), 
	`AC2LCT`			numeric (4, 2), 
	`EGRCT`			numeric (4, 2), 
	`EGLCT`			numeric (4, 2), 
	`MaterR`			smallint NOT NULL, 
	`MaterL`			smallint NOT NULL, 
	`TintR`			smallint NOT NULL, 
	`TintL`			smallint NOT NULL, 
	`VAR`			varchar (5), 
	`VAL`			varchar (5), 
	`ClensTypeIdR`			smallint, 
	`ClensTypeIdL`			smallint, 
	`ClensManufIdR`			smallint, 
	`ClensManufIdL`			smallint, 
	`ClensBrandIdR`			smallint, 
	`ClensBrandIdL`			smallint, 
	`ComR`			text, 
	`ComL`			text, 
	`PICL`			varchar (255), 
	`PICR`			varchar (255), 
	`OZRCT`			numeric (4, 2), 
	`OZLCT`			numeric (4, 2), 
	`OrderId`			varchar (10), 
	`CustId`			varchar (10), 
	`PupDiam`			varchar (4), 
	`CornDiam`			numeric (3, 1), 
	`EyeLidKey`			numeric (3, 1), 
	`CheckType`			tinyint, 
	`VA`			varchar (5), 
	`EHR`			numeric (4, 3), 
	`EHL`			numeric (4, 3), 
	`EVR`			numeric (4, 3), 
	`EVL`			numeric (4, 3), 
	`EAR`			numeric (4, 3), 
	`EAL`			numeric (4, 3)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdOrthoks` ADD PRIMARY KEY (`OrthokId`);

CREATE TABLE `tblCreditCards`
 (
	`CreditCardId`			smallint, 
	`CreditCardName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCreditCards` ADD PRIMARY KEY (`CreditCardId`);

CREATE TABLE `tblCreditTypes`
 (
	`CreditTypeId`			tinyint, 
	`CreditTypeName`			varchar (20)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCreditTypes` ADD PRIMARY KEY (`CreditTypeId`);

CREATE TABLE `tblDiscounts`
 (
	`DiscountId`			smallint NOT NULL, 
	`DiscountName`			varchar (35), 
	`prlGlass`			numeric (2, 2), 
	`prlTreat`			numeric (2, 2), 
	`prlClens`			numeric (2, 2), 
	`prlFrame`			numeric (2, 2), 
	`prlSunGlass`			numeric (2, 2), 
	`prlProp`			numeric (2, 2), 
	`prlSolution`			numeric (2, 2), 
	`prlService`			numeric (2, 2), 
	`prlCheck`			numeric (2, 2), 
	`prlMisc`			numeric (2, 2), 
	`prlGlassOneS`			numeric (2, 2), 
	`prlGlassOneP`			numeric (2, 2), 
	`prlGlassBif`			numeric (2, 2), 
	`prlGlassMul`			numeric (2, 2)
);

-- CREATE INDEXES ...
ALTER TABLE `tblDiscounts` ADD UNIQUE INDEX `DiscountName` (`DiscountName`);
ALTER TABLE `tblDiscounts` ADD PRIMARY KEY (`DiscountId`);

CREATE TABLE `tblDummy`
 (
	`Dummy`			boolean NOT NULL
);

-- CREATE INDEXES ...

CREATE TABLE `tblEyes`
 (
	`EyeId`			tinyint, 
	`EyeName`			varchar (5)
);

-- CREATE INDEXES ...
ALTER TABLE `tblEyes` ADD PRIMARY KEY (`EyeId`);

CREATE TABLE `tblFaxes`
 (
	`FaxId`			int not null auto_increment unique, 
	`SapakDestId`			int, 
	`SendTime`			datetime, 
	`JobInfo`			varchar (255), 
	`faxStatId`			smallint
);

-- CREATE INDEXES ...
ALTER TABLE `tblFaxes` ADD PRIMARY KEY (`FaxId`);

CREATE TABLE `tblFaxStats`
 (
	`faxStatId`			smallint, 
	`faxStatName`			varchar (15)
);

-- CREATE INDEXES ...
ALTER TABLE `tblFaxStats` ADD PRIMARY KEY (`faxStatId`);

CREATE TABLE `tblFixExpenses`
 (
	`FixExpenseId`			int not null auto_increment unique, 
	`FixExpenseName`			varchar (25), 
	`FixSum`			float, 
	`StartDate`			datetime, 
	`EndDate`			datetime, 
	`IntervalType`			varchar (4), 
	`IntervalNum`			smallint
);

-- CREATE INDEXES ...
ALTER TABLE `tblFixExpenses` ADD PRIMARY KEY (`FixExpenseId`);

CREATE TABLE `tblFrmColors`
 (
	`LabelId`			smallint NOT NULL, 
	`FrameColorId`			varchar (10) NOT NULL, 
	`FrameColorName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblFrmColors` ADD PRIMARY KEY (`LabelId`, `FrameColorId`);

CREATE TABLE `tblFrmLabelTypes`
 (
	`LabelId`			smallint NOT NULL, 
	`LabelName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblFrmLabelTypes` ADD PRIMARY KEY (`LabelId`);

CREATE TABLE `tblFrmModelColors`
 (
	`LabelId`			smallint NOT NULL, 
	`ModelId`			int NOT NULL, 
	`FrameColorId`			varchar (10) NOT NULL, 
	`FramePic`			varchar (50)
);

-- CREATE INDEXES ...
ALTER TABLE `tblFrmModelColors` ADD PRIMARY KEY (`LabelId`, `ModelId`, `FrameColorId`);

CREATE TABLE `tblFrmPrices`
 (
	`SapakId`			smallint NOT NULL, 
	`LabelId`			smallint NOT NULL, 
	`ModelId`			int NOT NULL, 
	`Price`			float, 
	`PubPrice`			float, 
	`RecPrice`			float, 
	`PrivPrice`			float, 
	`Active`			boolean NOT NULL, 
	`Quantity`			int
);

-- CREATE INDEXES ...
ALTER TABLE `tblFrmPrices` ADD PRIMARY KEY (`SapakId`, `LabelId`, `ModelId`);

CREATE TABLE `tblFrmPrivColors`
 (
	`PrivColorId`			smallint NOT NULL, 
	`PrivColorName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblFrmPrivColors` ADD PRIMARY KEY (`PrivColorId`);

CREATE TABLE `tblGroups`
 (
	`GroupId`			int NOT NULL, 
	`GroupName`			varchar (15), 
	`Phone`			varchar (12), 
	`Fax`			varchar (12), 
	`Email`			varchar (40), 
	`Address`			varchar (50), 
	`CityId`			smallint NOT NULL, 
	`ZipCode`			int, 
	`Comment`			text, 
	`DiscountId`			smallint
);

-- CREATE INDEXES ...
ALTER TABLE `tblGroups` ADD PRIMARY KEY (`GroupId`);

CREATE TABLE `tblInventory`
 (
	`InvId`			int not null auto_increment unique, 
	`InvDate`			date, 
	`UserId`			int NOT NULL, 
	`InvoiceId`			varchar (25), 
	`InvInDate`			date, 
	`PInvoiceId`			varchar (25), 
	`InvMoveTypeId`			tinyint, 
	`InvMovePropId`			smallint, 
	`InvSapakId`			smallint, 
	`BranchId`			smallint, 
	`Com`			varchar (255), 
	`SrcInvId`			int
);

-- CREATE INDEXES ...
ALTER TABLE `tblInventory` ADD PRIMARY KEY (`InvId`);

CREATE TABLE `tblInvMoveProps`
 (
	`InvMovePropId`			smallint NOT NULL, 
	`InvMovePropName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblInvMoveProps` ADD UNIQUE INDEX `BaseName` (`InvMovePropName`);
ALTER TABLE `tblInvMoveProps` ADD PRIMARY KEY (`InvMovePropId`);

CREATE TABLE `tblInvMoveTypes`
 (
	`InvMoveTypeId`			tinyint, 
	`InvMoveTypeName`			varchar (15), 
	`MoveAction`			smallint
);

-- CREATE INDEXES ...
ALTER TABLE `tblInvMoveTypes` ADD PRIMARY KEY (`InvMoveTypeId`);

CREATE TABLE `tblInvoiceChecks`
 (
	`InvoiceCheckId`			int not null auto_increment unique, 
	`InvoicePayId`			int, 
	`CheckId`			varchar (10), 
	`CheckDate`			date, 
	`CheckSum`			float
);

-- CREATE INDEXES ...
ALTER TABLE `tblInvoiceChecks` ADD PRIMARY KEY (`InvoiceCheckId`);

CREATE TABLE `tblInvoiceCredits`
 (
	`InvoiceCreditId`			int not null auto_increment unique, 
	`InvoicePayId`			int, 
	`CreditDate`			date, 
	`CreditSum`			float
);

-- CREATE INDEXES ...
ALTER TABLE `tblInvoiceCredits` ADD PRIMARY KEY (`InvoiceCreditId`);

CREATE TABLE `tblInvoicePays`
 (
	`InvoicePayId`			int not null auto_increment unique, 
	`SapakID`			smallint NOT NULL, 
	`ReceiptId`			varchar (25), 
	`PayTypeId`			smallint, 
	`CashSum`			float, 
	`CreditId`			varchar (25), 
	`CashDate`			date, 
	`CreditCardId`			smallint
);

-- CREATE INDEXES ...
ALTER TABLE `tblInvoicePays` ADD PRIMARY KEY (`InvoicePayId`);

CREATE TABLE `tblInvoices`
 (
	`InvoiceId`			int not null auto_increment unique, 
	`SapakID`			smallint NOT NULL, 
	`InvoicePayId`			int, 
	`InvoiceTypeId`			smallint NOT NULL, 
	`InvId`			varchar (25), 
	`InvDate`			date, 
	`InvSum`			float, 
	`Com`			varchar (50)
);

-- CREATE INDEXES ...
ALTER TABLE `tblInvoices` ADD PRIMARY KEY (`InvoiceId`);

CREATE TABLE `tblInvoicesInvs`
 (
	`InvoiceId`			int, 
	`InvId`			int
);

-- CREATE INDEXES ...
ALTER TABLE `tblInvoicesInvs` ADD PRIMARY KEY (`InvoiceId`);

CREATE TABLE `tblItemColors`
 (
	`ItemColorId`			smallint, 
	`ItemColorName`			varchar (35), 
	`ItemCode`			smallint
);

-- CREATE INDEXES ...
ALTER TABLE `tblItemColors` ADD UNIQUE INDEX `ItemCode` (`ItemCode`);
ALTER TABLE `tblItemColors` ADD PRIMARY KEY (`ItemColorId`);

CREATE TABLE `tblItemCounts`
 (
	`ItemCountId`			int not null auto_increment unique, 
	`CountYear`			int NOT NULL, 
	`ItemId`			int NOT NULL, 
	`CalcQuantity`			smallint, 
	`CountQuantity`			smallint, 
	`CalcValue`			float, 
	`BuyPrice`			float
);

-- CREATE INDEXES ...
ALTER TABLE `tblItemCounts` ADD UNIQUE INDEX `ItemIdYear` (`CountYear` DESC, `ItemId`);
ALTER TABLE `tblItemCounts` ADD PRIMARY KEY (`ItemCountId`);

CREATE TABLE `tblItemCountsYears`
 (
	`CountYear`			int not null auto_increment unique, 
	`CountDate`			datetime, 
	`Closed`			boolean NOT NULL
);

-- CREATE INDEXES ...
ALTER TABLE `tblItemCountsYears` ADD UNIQUE INDEX `CountDate` (`CountDate`);
ALTER TABLE `tblItemCountsYears` ADD PRIMARY KEY (`CountYear`);

CREATE TABLE `tblItemLineBuys`
 (
	`ItemLineId`			int, 
	`CatId`			int NOT NULL, 
	`Sold`			smallint
);

-- CREATE INDEXES ...
ALTER TABLE `tblItemLineBuys` ADD PRIMARY KEY (`ItemLineId`, `CatId`);

CREATE TABLE `tblItemLines`
 (
	`ItemLineId`			int not null auto_increment unique, 
	`InvId`			int, 
	`ItemId`			int, 
	`Quantity`			smallint, 
	`BuyPrice`			float, 
	`SalePrice`			float, 
	`Removed`			smallint, 
	`Sold`			smallint
);

-- CREATE INDEXES ...
ALTER TABLE `tblItemLines` ADD PRIMARY KEY (`ItemLineId`);

CREATE TABLE `tblItems`
 (
	`ItemId`			int not null auto_increment unique, 
	`ExCatNum`			varchar (50) NOT NULL, 
	`BarCode`			varchar (50), 
	`ItemStatId`			smallint, 
	`Active`			boolean NOT NULL, 
	`SapakBC`			varchar (50), 
	`SalePrice`			float
);

-- CREATE INDEXES ...
ALTER TABLE `tblItems` ADD UNIQUE INDEX `BarCode` (`BarCode`);
ALTER TABLE `tblItems` ADD UNIQUE INDEX `ExCatNum` (`ExCatNum`);
ALTER TABLE `tblItems` ADD PRIMARY KEY (`ItemId`);

CREATE TABLE `tblItemStats`
 (
	`ItemStatId`			smallint, 
	`ItemStatName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblItemStats` ADD PRIMARY KEY (`ItemStatId`);

CREATE TABLE `tblLabels`
 (
	`LabelId`			int not null auto_increment unique, 
	`LabelName`			varchar (25), 
	`MargRight`			float, 
	`MargLeft`			float, 
	`LabelWidth`			float, 
	`LabelHeight`			float, 
	`HorSpace`			float, 
	`VerSpace`			float, 
	`MargTop`			float, 
	`MargBot`			float
);

-- CREATE INDEXES ...
ALTER TABLE `tblLabels` ADD PRIMARY KEY (`LabelId`);

CREATE TABLE `tblLangs`
 (
	`LangId`			tinyint, 
	`LangName`			varchar (15)
);

-- CREATE INDEXES ...
ALTER TABLE `tblLangs` ADD PRIMARY KEY (`LangId`);

CREATE TABLE `tblLetters`
 (
	`LetterId`			int not null auto_increment unique, 
	`LetterName`			varchar (120), 
	`Text1`			text, 
	`Text2`			text, 
	`Text3`			text, 
	`Text4`			text, 
	`Text1Style`			tinyint, 
	`Text2Style`			tinyint, 
	`Text3Style`			tinyint, 
	`Text4Style`			tinyint, 
	`Text1Font`			varchar (50), 
	`Text2Font`			varchar (50), 
	`Text3Font`			varchar (50), 
	`Text4Font`			varchar (50), 
	`Text1Size`			smallint, 
	`Text2Size`			smallint, 
	`Text3Size`			smallint, 
	`Text4Size`			smallint
);

-- CREATE INDEXES ...
ALTER TABLE `tblLetters` ADD PRIMARY KEY (`LetterId`);

CREATE TABLE `tblLettersFollowup`
 (
	`PerId`			int NOT NULL, 
	`LetterId`			tinyint, 
	`LetterDate`			datetime, 
	`ServiceType`			smallint, 
	`FollowUpId`			int not null auto_increment unique
);

-- CREATE INDEXES ...
ALTER TABLE `tblLettersFollowup` ADD PRIMARY KEY (`FollowUpId`);

CREATE TABLE `tblLnsChars`
 (
	`LensCharId`			int NOT NULL, 
	`LensCharName`			varchar (50), 
	`Fav`			boolean NOT NULL
);

-- CREATE INDEXES ...
ALTER TABLE `tblLnsChars` ADD PRIMARY KEY (`LensCharId`);

CREATE TABLE `tblLnsPrices`
 (
	`SapakID`			smallint NOT NULL, 
	`LensTypeID`			smallint NOT NULL, 
	`LensMaterID`			smallint NOT NULL, 
	`LensCharID`			int NOT NULL, 
	`LensRng`			tinyint NOT NULL, 
	`LensInt`			tinyint NOT NULL, 
	`LensDiam`			tinyint NOT NULL, 
	`LensPM`			tinyint NOT NULL, 
	`Price`			float, 
	`PubPrice`			float, 
	`RecPrice`			float, 
	`PrivPrice`			float, 
	`Active`			boolean NOT NULL
);

-- CREATE INDEXES ...
ALTER TABLE `tblLnsPrices` ADD PRIMARY KEY (`SapakID`, `LensTypeID`, `LensMaterID`, `LensCharID`, `LensRng`, `LensInt`, `LensDiam`);

CREATE TABLE `tblLnsTreatChars`
 (
	`TreatCharId`			smallint NOT NULL, 
	`TreatCharName`			varchar (50)
);

-- CREATE INDEXES ...
ALTER TABLE `tblLnsTreatChars` ADD PRIMARY KEY (`TreatCharId`);

CREATE TABLE `tblLnsTreatmens`
 (
	`SapakID`			smallint NOT NULL, 
	`TreatId`			smallint NOT NULL, 
	`TreatCharID`			smallint NOT NULL, 
	`Price`			float, 
	`PubPrice`			float, 
	`RecPrice`			float, 
	`PrivPrice`			float, 
	`Active`			boolean NOT NULL
);

-- CREATE INDEXES ...
ALTER TABLE `tblLnsTreatmens` ADD PRIMARY KEY (`SapakID`, `TreatId`, `TreatCharID`);

CREATE TABLE `tblLnsTreatRules`
 (
	`SapakID`			smallint NOT NULL, 
	`TreatId`			smallint NOT NULL, 
	`TreatCharID`			smallint NOT NULL, 
	`FldName`			varchar (7), 
	`TreatRule`			text
);

-- CREATE INDEXES ...
ALTER TABLE `tblLnsTreatRules` ADD PRIMARY KEY (`SapakID`, `TreatId`, `TreatCharID`);

CREATE TABLE `tblLnsTreatTypes`
 (
	`TreatId`			smallint NOT NULL, 
	`TreatName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblLnsTreatTypes` ADD PRIMARY KEY (`TreatId`);

CREATE TABLE `tblLnsTreatTypesConnect`
 (
	`TreatId`			smallint, 
	`LensTypeID`			smallint, 
	`LensMaterID`			smallint
);

-- CREATE INDEXES ...

CREATE TABLE `tblNewProds`
 (
	`NewProdId`			int not null auto_increment unique, 
	`NewProdName`			varchar (30), 
	`NewProdDesc`			text, 
	`NewProdPic`			varchar (255)
);

-- CREATE INDEXES ...
ALTER TABLE `tblNewProds` ADD PRIMARY KEY (`NewProdId`);

CREATE TABLE `tblOReports`
 (
	`ORepId`			smallint, 
	`ORepHeader`			varchar (50), 
	`ORepName`			varchar (40), 
	`ORepType`			tinyint, 
	`ORPTPara`			text, 
	`secLevel`			tinyint, 
	`InExe`			boolean NOT NULL, 
	`ORepSql`			text
);

-- CREATE INDEXES ...
ALTER TABLE `tblOReports` ADD PRIMARY KEY (`ORepId`);

CREATE TABLE `tblPayTypes`
 (
	`PayTypeId`			smallint, 
	`PayTypeName`			varchar (10)
);

-- CREATE INDEXES ...
ALTER TABLE `tblPayTypes` ADD PRIMARY KEY (`PayTypeId`);

CREATE TABLE `tblPerData`
 (
	`PerId`			int NOT NULL, 
	`LastName`			varchar (15), 
	`FirstName`			varchar (15), 
	`TzId`			varchar (10), 
	`BirthDate`			datetime, 
	`Sex`			boolean NOT NULL, 
	`HomePhone`			varchar (12), 
	`WorkPhone`			varchar (12), 
	`CellPhone`			varchar (12), 
	`Fax`			varchar (12), 
	`Email`			varchar (40), 
	`Address`			varchar (50), 
	`CityId`			smallint NOT NULL, 
	`ZipCode`			int, 
	`DiscountId`			smallint NOT NULL, 
	`GroupId`			int NOT NULL, 
	`PerType`			tinyint, 
	`RefId`			int NOT NULL, 
	`UserId`			int NOT NULL, 
	`Comment`			text, 
	`RefsSub1Id`			int NOT NULL, 
	`RefsSub2Id`			int NOT NULL, 
	`WantsLaser`			smallint, 
	`LaserDate`			date, 
	`DidOperation`			boolean NOT NULL, 
	`FamId`			int, 
	`MailList`			boolean NOT NULL, 
	`Ocup`			varchar (20), 
	`HidCom`			text, 
	`LangId`			tinyint, 
	`BranchId`			smallint NOT NULL
);

-- CREATE INDEXES ...
ALTER TABLE `tblPerData` ADD PRIMARY KEY (`PerId`);

CREATE TABLE `tblPerLast`
 (
	`PerNum`			int not null auto_increment unique, 
	`PerId`			int
);

-- CREATE INDEXES ...
ALTER TABLE `tblPerLast` ADD UNIQUE INDEX `PerId` (`PerId`);
ALTER TABLE `tblPerLast` ADD PRIMARY KEY (`PerNum`);

CREATE TABLE `tblPerPicture`
 (
	`PerPicId`			int not null auto_increment unique, 
	`PerId`			int, 
	`PicFileName`			varchar (35), 
	`Description`			varchar (25) NOT NULL, 
	`ScanDate`			datetime, 
	`Notes`			varchar (255), 
	`IsCon`			boolean NOT NULL
);

-- CREATE INDEXES ...
ALTER TABLE `tblPerPicture` ADD INDEX `PerId` (`PerId`);
ALTER TABLE `tblPerPicture` ADD PRIMARY KEY (`PerPicId`);

CREATE TABLE `tblProfiles`
 (
	`ProfileId`			int not null auto_increment unique, 
	`ProfileName`			varchar (35), 
	`ProfileSql`			text, 
	`ProfileDesc`			varchar (255)
);

-- CREATE INDEXES ...
ALTER TABLE `tblProfiles` ADD PRIMARY KEY (`ProfileId`);

CREATE TABLE `tblPropsNames`
 (
	`PropId`			int NOT NULL, 
	`PropName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblPropsNames` ADD PRIMARY KEY (`PropId`);

CREATE TABLE `tblPropsPrices`
 (
	`SapakID`			smallint NOT NULL, 
	`PropId`			int NOT NULL, 
	`Price`			float, 
	`PubPrice`			float, 
	`RecPrice`			float, 
	`PrivPrice`			float, 
	`Active`			boolean NOT NULL, 
	`Quantity`			int
);

-- CREATE INDEXES ...
ALTER TABLE `tblPropsPrices` ADD PRIMARY KEY (`SapakID`, `PropId`);

CREATE TABLE `tblRefs`
 (
	`RefId`			int, 
	`RefName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblRefs` ADD PRIMARY KEY (`RefId`);
ALTER TABLE `tblRefs` ADD UNIQUE INDEX `RefName` (`RefName`);

CREATE TABLE `tblRefsSub1`
 (
	`RefsSub1Id`			int not null auto_increment unique, 
	`RefsSub1Name`			varchar (35), 
	`RefId`			int
);

-- CREATE INDEXES ...
ALTER TABLE `tblRefsSub1` ADD PRIMARY KEY (`RefsSub1Id`);
ALTER TABLE `tblRefsSub1` ADD UNIQUE INDEX `RefsSub1` (`RefsSub1Name`, `RefId`);

CREATE TABLE `tblSapakComments`
 (
	`SapakId`			smallint NOT NULL, 
	`prlType`			tinyint, 
	`Comments`			text, 
	`PrlSp`			smallint
);

-- CREATE INDEXES ...
ALTER TABLE `tblSapakComments` ADD PRIMARY KEY (`SapakId`, `prlType`);

CREATE TABLE `tblSapakDests`
 (
	`SapakDestId`			int not null auto_increment unique, 
	`SapakDestName`			varchar (20), 
	`SapakId`			smallint, 
	`Fax1`			varchar (15), 
	`Fax2`			varchar (15), 
	`Email1`			varchar (50), 
	`Email2`			varchar (50), 
	`ClientId`			varchar (10)
);

-- CREATE INDEXES ...
ALTER TABLE `tblSapakDests` ADD PRIMARY KEY (`SapakDestId`);

CREATE TABLE `tblSapakPerComments`
 (
	`SapakId`			smallint NOT NULL, 
	`prlType`			tinyint, 
	`Comments`			text
);

-- CREATE INDEXES ...
ALTER TABLE `tblSapakPerComments` ADD PRIMARY KEY (`SapakId`, `prlType`);

CREATE TABLE `tblSapaks`
 (
	`SapakID`			smallint NOT NULL, 
	`SapakName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblSapaks` ADD PRIMARY KEY (`SapakID`);

CREATE TABLE `tblReportDummy`
 (
	`SapakID`			smallint, 
	`SapakName`			varchar (35), 
	`InSum`			float, 
	`InRem`			float
);

-- CREATE INDEXES ...

CREATE TABLE `tblSapakSends`
 (
	`SapakSendId`			int not null auto_increment unique, 
	`PerId`			int, 
	`GlassPId`			int, 
	`WorkId`			int, 
	`ClensId`			int, 
	`SapakDestId`			int, 
	`UserId`			int, 
	`SendTime`			datetime, 
	`Recived`			boolean NOT NULL, 
	`PrivPrice`			float, 
	`ShipmentId`			varchar (20), 
	`ShipmentDate`			date, 
	`Sent`			boolean NOT NULL, 
	`Com`			varchar (255), 
	`spsStatId`			smallint, 
	`spsType`			tinyint, 
	`spsSendType`			tinyint, 
	`FaxId`			int, 
	`ShFrame`			boolean NOT NULL, 
	`ShLab`			boolean NOT NULL
);

-- CREATE INDEXES ...
ALTER TABLE `tblSapakSends` ADD PRIMARY KEY (`SapakSendId`);

CREATE TABLE `tblSapakSendStats`
 (
	`spsStatId`			smallint NOT NULL, 
	`spsStatName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblSapakSendStats` ADD PRIMARY KEY (`spsStatId`);

CREATE TABLE `tblSearchOrder`
 (
	`ItemData`			smallint, 
	`ListIndex`			smallint, 
	`Desc`			varchar (50), 
	`Deaf`			smallint
);

-- CREATE INDEXES ...
ALTER TABLE `tblSearchOrder` ADD PRIMARY KEY (`ItemData`);

CREATE TABLE `tblServiceTypes`
 (
	`ServiceId`			smallint NOT NULL, 
	`ServiceName`			varchar (35), 
	`ServicePrice`			float
);

-- CREATE INDEXES ...
ALTER TABLE `tblServiceTypes` ADD PRIMARY KEY (`ServiceId`);
ALTER TABLE `tblServiceTypes` ADD UNIQUE INDEX `ServiceName` (`ServiceName`);

CREATE TABLE `tblSettings`
 (
	`SetId`			smallint, 
	`SetVal`			varchar (20)
);

-- CREATE INDEXES ...
ALTER TABLE `tblSettings` ADD PRIMARY KEY (`SetId`);

CREATE TABLE `tblShortCuts`
 (
	`PrKey`			smallint, 
	`ShKey`			varchar (255), 
	`Desc`			varchar (20)
);

-- CREATE INDEXES ...
ALTER TABLE `tblShortCuts` ADD PRIMARY KEY (`PrKey`);

CREATE TABLE `tblSMS`
 (
	`SMSId`			int not null auto_increment unique, 
	`SMSName`			varchar (120), 
	`SMSText`			text, 
	`SMSLang`			varchar (8), 
	`SMSDelDate`			text
);

-- CREATE INDEXES ...
ALTER TABLE `tblSMS` ADD PRIMARY KEY (`SMSId`);

CREATE TABLE `tblSMSLens`
 (
	`SMSProviderPrefix`			varchar (10), 
	`SMSLang`			varchar (8), 
	`SMSProviderName`			varchar (20), 
	`SMSLen`			smallint
);

-- CREATE INDEXES ...
ALTER TABLE `tblSMSLens` ADD PRIMARY KEY (`SMSProviderPrefix`, `SMSLang`);

CREATE TABLE `tblSolutionPrices`
 (
	`SapakID`			smallint NOT NULL, 
	`SolutionId`			smallint NOT NULL, 
	`Price`			float, 
	`PubPrice`			float, 
	`RecPrice`			float, 
	`PrivPrice`			float, 
	`Active`			boolean NOT NULL, 
	`Quantity`			int
);

-- CREATE INDEXES ...
ALTER TABLE `tblSolutionPrices` ADD PRIMARY KEY (`SapakID`, `SolutionId`);

CREATE TABLE `tblSpecialNames`
 (
	`SpecialId`			smallint NOT NULL, 
	`SpecialName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblSpecialNames` ADD PRIMARY KEY (`SpecialId`);

CREATE TABLE `tblSpecials`
 (
	`SapakID`			smallint NOT NULL, 
	`SpecialId`			smallint NOT NULL, 
	`PrlType`			tinyint, 
	`Priority`			smallint, 
	`Price`			float, 
	`PubPrice`			float, 
	`RecPrice`			float, 
	`PrivPrice`			float, 
	`Formula`			text, 
	`data`			varchar (2), 
	`RLOnly`			boolean NOT NULL, 
	`Active`			boolean NOT NULL
);

-- CREATE INDEXES ...
ALTER TABLE `tblSpecials` ADD PRIMARY KEY (`SapakID`, `SpecialId`);

CREATE TABLE `tblSysLevels`
 (
	`LevelId`			tinyint, 
	`LevelName`			varchar (7)
);

-- CREATE INDEXES ...
ALTER TABLE `tblSysLevels` ADD PRIMARY KEY (`LevelId`);

CREATE TABLE `tblUReports`
 (
	`URepId`			int not null auto_increment unique, 
	`URepSql`			text, 
	`URepHeader`			varchar (50), 
	`URepName`			varchar (20), 
	`URepType`			boolean NOT NULL, 
	`URPTPara`			varchar (255), 
	`LoadedForm`			varchar (30), 
	`FirstCtl`			varchar (80), 
	`FirstIndex`			smallint, 
	`SecCtl`			varchar (80), 
	`SecIndex`			smallint, 
	`ShortCutNum`			tinyint, 
	`secLevel`			tinyint, 
	`Trans`			varchar (255)
);

-- CREATE INDEXES ...
ALTER TABLE `tblUReports` ADD PRIMARY KEY (`URepId`);

CREATE TABLE `tblUsers`
 (
	`UserId`			int not null auto_increment unique, 
	`LastName`			varchar (15), 
	`FirstName`			varchar (10), 
	`HomePhone`			varchar (12), 
	`CellPhone`			varchar (12), 
	`Fax`			varchar (12), 
	`Address`			varchar (50), 
	`ZipCode`			int, 
	`Diag`			boolean NOT NULL, 
	`Emp`			boolean NOT NULL, 
	`CityId`			smallint, 
	`BirthDate`			datetime, 
	`Salary`			float, 
	`Pass`			varchar (8), 
	`LevelId`			tinyint, 
	`Comment`			text, 
	`UserTz`			varchar (10), 
	`PrivType`			tinyint, 
	`Active`			boolean NOT NULL, 
	`BranchId`			smallint NOT NULL
);

-- CREATE INDEXES ...
ALTER TABLE `tblUsers` ADD PRIMARY KEY (`UserId`);
ALTER TABLE `tblUsers` ADD UNIQUE INDEX `UserName` (`LastName`, `FirstName`);
ALTER TABLE `tblUsers` ADD UNIQUE INDEX `UserTz` (`UserTz`);

CREATE TABLE `tblVAT`
 (
	`VStart`			datetime, 
	`VEnd`			datetime, 
	`VAT`			float
);

-- CREATE INDEXES ...
ALTER TABLE `tblVAT` ADD PRIMARY KEY (`VStart`, `VEnd`, `VAT`);

CREATE TABLE `tblZipcodeStreets`
 (
	`CityCode`			int, 
	`StreetCode`			varchar (50), 
	`StreetName`			varchar (50), 
	`AlternateStreetName`			varchar (50)
);

-- CREATE INDEXES ...
ALTER TABLE `tblZipcodeStreets` ADD INDEX `CityCode` (`CityCode`);
ALTER TABLE `tblZipcodeStreets` ADD PRIMARY KEY (`StreetCode`, `StreetName`, `AlternateStreetName`);

CREATE TABLE `tblZipcodeStreetsZipcode`
 (
	`CityCode`			int, 
	`StreetCode`			varchar (50), 
	`StartingHouseNumber`			int, 
	`EndingHouseNumber`			int, 
	`StreetZipcode`			int
);

-- CREATE INDEXES ...
ALTER TABLE `tblZipcodeStreetsZipcode` ADD PRIMARY KEY (`CityCode`, `StreetCode`, `StartingHouseNumber`, `EndingHouseNumber`);
ALTER TABLE `tblZipcodeStreetsZipcode` ADD INDEX `STREETS_ZIP_CODECityCode` (`CityCode`);
ALTER TABLE `tblZipcodeStreetsZipcode` ADD INDEX `STREETS_ZIP_CODEStreetCode` (`StreetCode`);
ALTER TABLE `tblZipcodeStreetsZipcode` ADD INDEX `StreetZipcode` (`StreetZipcode`);

CREATE TABLE `tblCheckTypes`
 (
	`CheckId`			smallint NOT NULL, 
	`CheckName`			varchar (35), 
	`CheckPrice`			float
);

-- CREATE INDEXES ...
ALTER TABLE `tblCheckTypes` ADD UNIQUE INDEX `CheckName` (`CheckName`);
ALTER TABLE `tblCheckTypes` ADD PRIMARY KEY (`CheckId`);

CREATE TABLE `tblClndrWrkFD`
 (
	`WrkFDId`			int not null auto_increment unique, 
	`UserID`			int NOT NULL, 
	`WrkDate`			datetime NOT NULL, 
	`FDTypeId`			smallint NOT NULL
);

-- CREATE INDEXES ...
ALTER TABLE `tblClndrWrkFD` ADD PRIMARY KEY (`WrkFDId`);

CREATE TABLE `tblCrdBuysCatNums`
 (
	`CatId`			int not null auto_increment unique, 
	`BuyId`			int NOT NULL, 
	`CatNum`			varchar (60) NOT NULL, 
	`Quantity`			smallint, 
	`Price`			float, 
	`Discount`			float, 
	`CatLeft`			int, 
	`ItemId`			int
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdBuysCatNums` ADD INDEX `CatLeft` (`CatLeft`);
ALTER TABLE `tblCrdBuysCatNums` ADD UNIQUE INDEX `CatNum` (`BuyId`, `CatNum`);
ALTER TABLE `tblCrdBuysCatNums` ADD PRIMARY KEY (`CatId`);

CREATE TABLE `tblCrdBuysWorkSupply`
 (
	`WorkSupplyId`			smallint NOT NULL, 
	`WorkSupplyName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdBuysWorkSupply` ADD PRIMARY KEY (`WorkSupplyId`);

CREATE TABLE `tblCrdClensFits`
 (
	`PerId`			int, 
	`CheckDate`			datetime, 
	`FitId`			int not null auto_increment unique, 
	`DiamR`			numeric (3, 1), 
	`DiamL`			numeric (3, 1), 
	`BC1R`			varchar (5), 
	`BC1L`			varchar (5), 
	`BC2R`			numeric (3, 2), 
	`BC2L`			numeric (3, 2), 
	`SphR`			varchar (6), 
	`SphL`			varchar (6), 
	`CylR`			numeric (4, 2), 
	`CylL`			numeric (4, 2), 
	`AxR`			tinyint, 
	`AxL`			tinyint, 
	`VAR`			varchar (5), 
	`VAL`			varchar (5), 
	`VA`			varchar (5), 
	`PHR`			varchar (5), 
	`PHL`			varchar (5), 
	`ClensTypeIdR`			smallint, 
	`ClensTypeIdL`			smallint, 
	`ClensManufIdR`			smallint, 
	`ClensManufIdL`			smallint, 
	`ClensBrandIdR`			smallint, 
	`ClensBrandIdL`			smallint, 
	`ComR`			text, 
	`ComL`			text
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdClensFits` ADD PRIMARY KEY (`PerId`, `CheckDate`, `FitId`);

CREATE TABLE `tblCrdClinicFlds`
 (
	`FldId`			smallint, 
	`FldName`			varchar (10)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdClinicFlds` ADD PRIMARY KEY (`FldId`);

CREATE TABLE `tblCrdGlassBrand`
 (
	`GlassBrandId`			smallint, 
	`GlassBrandName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdGlassBrand` ADD UNIQUE INDEX `GlassBrandName` (`GlassBrandName`);
ALTER TABLE `tblCrdGlassBrand` ADD PRIMARY KEY (`GlassBrandId`);

CREATE TABLE `tblCrdGlassColor`
 (
	`GlassColorId`			smallint, 
	`GlassColorName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdGlassColor` ADD UNIQUE INDEX `GlassBrandName` (`GlassColorName`);
ALTER TABLE `tblCrdGlassColor` ADD PRIMARY KEY (`GlassColorId`);

CREATE TABLE `tblCrdGlassUses`
 (
	`GlassUseId`			smallint, 
	`GlassUseName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdGlassUses` ADD UNIQUE INDEX `GlassRoleName` (`GlassUseName`);
ALTER TABLE `tblCrdGlassUses` ADD PRIMARY KEY (`GlassUseId`);

CREATE TABLE `tblCrdOverViews`
 (
	`PerId`			int NOT NULL, 
	`CheckDate`			datetime NOT NULL, 
	`Comments`			text, 
	`VAR`			varchar (6), 
	`VAL`			varchar (6), 
	`UserId`			int, 
	`Pic`			varchar (2)
);

-- CREATE INDEXES ...
ALTER TABLE `tblCrdOverViews` ADD PRIMARY KEY (`PerId`, `CheckDate`);

CREATE TABLE `tblFaxLines`
 (
	`FaxId`			int, 
	`FldId`			int
);

-- CREATE INDEXES ...

CREATE TABLE `tblFrmModelTypes`
 (
	`ModelId`			int NOT NULL, 
	`ModelName`			varchar (35), 
	`ISG`			boolean NOT NULL, 
	`Sizes`			varchar (255)
);

-- CREATE INDEXES ...
ALTER TABLE `tblFrmModelTypes` ADD PRIMARY KEY (`ModelId`);

CREATE TABLE `tblInvoiceTypes`
 (
	`InvoiceTypeId`			smallint, 
	`InvoiceTypeName`			varchar (10)
);

-- CREATE INDEXES ...
ALTER TABLE `tblInvoiceTypes` ADD PRIMARY KEY (`InvoiceTypeId`);

CREATE TABLE `tblItemsAdd`
 (
	`ItemId`			int not null auto_increment unique, 
	`ExCatNum`			varchar (50) NOT NULL, 
	`BarCode`			varchar (50)
);

-- CREATE INDEXES ...
ALTER TABLE `tblItemsAdd` ADD UNIQUE INDEX `ExCatNum` (`ExCatNum`);
ALTER TABLE `tblItemsAdd` ADD PRIMARY KEY (`ItemId`);

CREATE TABLE `tblLnsMaterials`
 (
	`LensMaterId`			smallint NOT NULL, 
	`LensMaterName`			varchar (20)
);

-- CREATE INDEXES ...
ALTER TABLE `tblLnsMaterials` ADD PRIMARY KEY (`LensMaterId`);

CREATE TABLE `tblLnsTypes`
 (
	`LensTypeId`			smallint NOT NULL, 
	`LensTypeName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblLnsTypes` ADD PRIMARY KEY (`LensTypeId`);

CREATE TABLE `tblPrlTypes`
 (
	`prlType`			tinyint, 
	`prlName`			varchar (30)
);

-- CREATE INDEXES ...
ALTER TABLE `tblPrlTypes` ADD PRIMARY KEY (`prlType`);

CREATE TABLE `tblRefsSub2`
 (
	`RefsSub2Id`			int not null auto_increment unique, 
	`RefsSub2Name`			varchar (35), 
	`subRefId`			int
);

-- CREATE INDEXES ...
ALTER TABLE `tblRefsSub2` ADD PRIMARY KEY (`RefsSub2Id`);
ALTER TABLE `tblRefsSub2` ADD UNIQUE INDEX `RefsSub2` (`RefsSub2Name`, `subRefId`);

CREATE TABLE `tblSapakSendsLensPlan`
 (
	`SapakSendId`			int, 
	`TreatBlock`			boolean NOT NULL, 
	`TreatWSec`			boolean NOT NULL, 
	`TreatWScrew`			boolean NOT NULL, 
	`TreatWNylon`			boolean NOT NULL, 
	`TreatWKnife`			boolean NOT NULL, 
	`LensColor`			varchar (15), 
	`LensLevel`			varchar (15), 
	`EyeWidth`			numeric (3, 1), 
	`EyeHeight`			numeric (3, 1), 
	`BridgeWidth`			numeric (3, 1), 
	`CenterHeightR`			numeric (3, 1), 
	`CenterHeightL`			numeric (3, 1), 
	`SegHeightR`			numeric (3, 1), 
	`SegHeightL`			numeric (3, 1), 
	`PicNum`			varchar (2), 
	`PCom`			varchar (255), 
	`Basis`			tinyint, 
	`Pent`			numeric (4, 2), 
	`VD`			numeric (4, 2)
);

-- CREATE INDEXES ...
ALTER TABLE `tblSapakSendsLensPlan` ADD PRIMARY KEY (`SapakSendId`);

CREATE TABLE `tblSolutionNames`
 (
	`SolutionId`			smallint NOT NULL, 
	`SolutionName`			varchar (35)
);

-- CREATE INDEXES ...
ALTER TABLE `tblSolutionNames` ADD PRIMARY KEY (`SolutionId`);

CREATE TABLE `tblZipcodeCities`
 (
	`CityCode`			int, 
	`CityName`			varchar (50), 
	`CityDivided`			boolean NOT NULL, 
	`CityZipCode`			int
);

-- CREATE INDEXES ...
ALTER TABLE `tblZipcodeCities` ADD INDEX `CityZipCode` (`CityZipCode`);
ALTER TABLE `tblZipcodeCities` ADD PRIMARY KEY (`CityCode`);

CREATE TABLE `sqlCrdClinic`
 (
	`FVal`			varchar (60), 
	`ICount`			int, 
	`FldId`			smallint
);

-- CREATE INDEXES ...


-- CREATE Relationships ...
ALTER TABLE `tblCrdFrpsLines` ADD CONSTRAINT `tblCrdFrpsLines_FrpId_fk` FOREIGN KEY (`FrpId`) REFERENCES `tblCrdFrps`(`FrpId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblSapakSends` ADD CONSTRAINT `tblSapakSends_spsStatId_fk` FOREIGN KEY (`spsStatId`) REFERENCES `tblSapakSendStats`(`spsStatId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdLVChecks` ADD CONSTRAINT `tblCrdLVChecks_AreaId_fk` FOREIGN KEY (`AreaId`) REFERENCES `tblCrdLVArea`(`LVAreaId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdBuysChecks` ADD CONSTRAINT `tblCrdBuysChecks_BuyPayId_fk` FOREIGN KEY (`BuyPayId`) REFERENCES `tblCrdBuysPays`(`BuyPayId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblInvoices` ADD CONSTRAINT `tblInvoices_InvoicePayId_fk` FOREIGN KEY (`InvoicePayId`) REFERENCES `tblInvoicePays`(`InvoicePayId`) ON UPDATE CASCADE;
ALTER TABLE `tblItems` ADD CONSTRAINT `tblItems_ItemStatId_fk` FOREIGN KEY (`ItemStatId`) REFERENCES `tblItemStats`(`ItemStatId`) ON UPDATE CASCADE;
ALTER TABLE `tblInvoicePays` ADD CONSTRAINT `tblInvoicePays_PayTypeId_fk` FOREIGN KEY (`PayTypeId`) REFERENCES `tblPayTypes`(`PayTypeId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdLVChecks` ADD CONSTRAINT `tblCrdLVChecks_FrameId_fk` FOREIGN KEY (`FrameId`) REFERENCES `tblCrdLVFrame`(`LVFrameId`) ON UPDATE CASCADE;
ALTER TABLE `tblInventory` ADD CONSTRAINT `tblInventory_InvMoveTypeId_fk` FOREIGN KEY (`InvMoveTypeId`) REFERENCES `tblInvMoveTypes`(`InvMoveTypeId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdBuysWorks` ADD CONSTRAINT `tblCrdBuysWorks_SapakId_fk` FOREIGN KEY (`SapakId`) REFERENCES `tblCrdBuysWorkSapaks`(`SapakID`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdBuysWorks` ADD CONSTRAINT `tblCrdBuysWorks_WorkStatId_fk` FOREIGN KEY (`WorkStatId`) REFERENCES `tblCrdBuysWorkStats`(`WorkStatId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdBuysWorks` ADD CONSTRAINT `tblCrdBuysWorks_WorkSupplyId_fk` FOREIGN KEY (`WorkSupplyId`) REFERENCES `tblCrdBuysWorkSupply`(`WorkSupplyId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdBuysWorks` ADD CONSTRAINT `tblCrdBuysWorks_WorkTypeId_fk` FOREIGN KEY (`WorkTypeId`) REFERENCES `tblCrdBuysWorkTypes`(`WorkTypeId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdBuysWorks` ADD CONSTRAINT `tblCrdBuysWorks_LabId_fk` FOREIGN KEY (`LabId`) REFERENCES `tblCrdBuysWorkLabs`(`LabID`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdLVChecks` ADD CONSTRAINT `tblCrdLVChecks_ManufId_fk` FOREIGN KEY (`ManufId`) REFERENCES `tblCrdLVManuf`(`LVManufId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdBuysPays` ADD CONSTRAINT `tblCrdBuysPays_CreditCardId_fk` FOREIGN KEY (`CreditCardId`) REFERENCES `tblCreditCards`(`CreditCardId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdLVChecks` ADD CONSTRAINT `tblCrdLVChecks_CapId_fk` FOREIGN KEY (`CapId`) REFERENCES `tblCrdLVCap`(`LVCapId`) ON UPDATE CASCADE;
ALTER TABLE `tblSapakSends` ADD CONSTRAINT `tblSapakSends_SapakDestId_fk` FOREIGN KEY (`SapakDestId`) REFERENCES `tblSapakDests`(`SapakDestId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdBuysPays` ADD CONSTRAINT `tblCrdBuysPays_CreditTypeId_fk` FOREIGN KEY (`CreditTypeId`) REFERENCES `tblCreditTypes`(`CreditTypeId`) ON UPDATE CASCADE;
ALTER TABLE `tblItemLines` ADD CONSTRAINT `tblItemLines_ItemId_fk` FOREIGN KEY (`ItemId`) REFERENCES `tblItems`(`ItemId`) ON UPDATE CASCADE;
ALTER TABLE `tblInvoiceChecks` ADD CONSTRAINT `tblInvoiceChecks_InvoicePayId_fk` FOREIGN KEY (`InvoicePayId`) REFERENCES `tblInvoicePays`(`InvoicePayId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblItemLines` ADD CONSTRAINT `tblItemLines_InvId_fk` FOREIGN KEY (`InvId`) REFERENCES `tblInventory`(`InvId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCLnsPrices` ADD CONSTRAINT `tblCLnsPrices_SapakID_fk` FOREIGN KEY (`SapakID`) REFERENCES `tblSapaks`(`SapakID`) ON UPDATE CASCADE;
ALTER TABLE `tblLnsPrices` ADD CONSTRAINT `tblLnsPrices_SapakID_fk` FOREIGN KEY (`SapakID`) REFERENCES `tblSapaks`(`SapakID`) ON UPDATE CASCADE;
ALTER TABLE `tblLnsTreatmens` ADD CONSTRAINT `tblLnsTreatmens_SapakID_fk` FOREIGN KEY (`SapakID`) REFERENCES `tblSapaks`(`SapakID`) ON UPDATE CASCADE;
ALTER TABLE `tblPropsPrices` ADD CONSTRAINT `tblPropsPrices_SapakID_fk` FOREIGN KEY (`SapakID`) REFERENCES `tblSapaks`(`SapakID`) ON UPDATE CASCADE;
ALTER TABLE `tblSolutionPrices` ADD CONSTRAINT `tblSolutionPrices_SapakID_fk` FOREIGN KEY (`SapakID`) REFERENCES `tblSapaks`(`SapakID`) ON UPDATE CASCADE;
ALTER TABLE `tblCLnsPrices` ADD CONSTRAINT `tblCLnsPrices_ClensCharID_fk` FOREIGN KEY (`ClensCharID`) REFERENCES `tblCLnsChars`(`CLensCharId`) ON UPDATE CASCADE;
ALTER TABLE `tblFrmModelColors` ADD CONSTRAINT `tblFrmModelColors_LabelId_fk` FOREIGN KEY (`LabelId`) REFERENCES `tblFrmColors`(`LabelId`) ON UPDATE CASCADE;
ALTER TABLE `tblFrmModelColors` ADD CONSTRAINT `tblFrmModelColors_FrameColorId_fk` FOREIGN KEY (`FrameColorId`) REFERENCES `tblFrmColors`(`FrameColorId`) ON UPDATE CASCADE;
ALTER TABLE `tblFrmColors` ADD CONSTRAINT `tblFrmColors_LabelId_fk` FOREIGN KEY (`LabelId`) REFERENCES `tblFrmLabelTypes`(`LabelId`) ON UPDATE CASCADE;
ALTER TABLE `tblFrmPrices` ADD CONSTRAINT `tblFrmPrices_LabelId_fk` FOREIGN KEY (`LabelId`) REFERENCES `tblFrmLabelTypes`(`LabelId`) ON UPDATE CASCADE;
ALTER TABLE `tblFrmModelColors` ADD CONSTRAINT `tblFrmModelColors_ModelId_fk` FOREIGN KEY (`ModelId`) REFERENCES `tblFrmModelTypes`(`ModelId`) ON UPDATE CASCADE;
ALTER TABLE `tblFrmPrices` ADD CONSTRAINT `tblFrmPrices_ModelId_fk` FOREIGN KEY (`ModelId`) REFERENCES `tblFrmModelTypes`(`ModelId`) ON UPDATE CASCADE;
ALTER TABLE `tblLnsPrices` ADD CONSTRAINT `tblLnsPrices_LensCharID_fk` FOREIGN KEY (`LensCharID`) REFERENCES `tblLnsChars`(`LensCharId`) ON UPDATE CASCADE;
ALTER TABLE `tblLnsTreatmens` ADD CONSTRAINT `tblLnsTreatmens_TreatCharID_fk` FOREIGN KEY (`TreatCharID`) REFERENCES `tblLnsTreatChars`(`TreatCharId`) ON UPDATE CASCADE;
ALTER TABLE `tblSapakComments` ADD CONSTRAINT `tblSapakComments_prlType_fk` FOREIGN KEY (`prlType`) REFERENCES `tblPrlTypes`(`prlType`) ON UPDATE CASCADE;
ALTER TABLE `tblSpecials` ADD CONSTRAINT `tblSpecials_PrlType_fk` FOREIGN KEY (`PrlType`) REFERENCES `tblPrlTypes`(`prlType`) ON UPDATE CASCADE;
ALTER TABLE `tblFrmPrices` ADD CONSTRAINT `tblFrmPrices_SapakId_fk` FOREIGN KEY (`SapakId`) REFERENCES `tblSapaks`(`SapakID`) ON UPDATE CASCADE;
ALTER TABLE `tblSapakComments` ADD CONSTRAINT `tblSapakComments_SapakId_fk` FOREIGN KEY (`SapakId`) REFERENCES `tblSapaks`(`SapakID`) ON UPDATE CASCADE;
ALTER TABLE `tblSpecials` ADD CONSTRAINT `tblSpecials_SapakID_fk` FOREIGN KEY (`SapakID`) REFERENCES `tblSapaks`(`SapakID`) ON UPDATE CASCADE;
ALTER TABLE `tblSolutionPrices` ADD CONSTRAINT `tblSolutionPrices_SolutionId_fk` FOREIGN KEY (`SolutionId`) REFERENCES `tblSolutionNames`(`SolutionId`) ON UPDATE CASCADE;
ALTER TABLE `tblSpecials` ADD CONSTRAINT `tblSpecials_SpecialId_fk` FOREIGN KEY (`SpecialId`) REFERENCES `tblSpecialNames`(`SpecialId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecksGlassesP` ADD CONSTRAINT `tblCrdGlassChecksGlassesP_UseId_fk` FOREIGN KEY (`UseId`) REFERENCES `tblCrdGlassUses`(`GlassUseId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecksGlassesP` ADD CONSTRAINT `tblCrdGlassChecksGlassesP_EyeId_fk` FOREIGN KEY (`EyeId`) REFERENCES `tblEyes`(`EyeId`) ON UPDATE CASCADE;
ALTER TABLE `tblInvoiceCredits` ADD CONSTRAINT `tblInvoiceCredits_InvoicePayId_fk` FOREIGN KEY (`InvoicePayId`) REFERENCES `tblInvoicePays`(`InvoicePayId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdGlassChecks` ADD CONSTRAINT `tblCrdGlassChecks_BaseR_fk` FOREIGN KEY (`BaseR`) REFERENCES `tblBases`(`BaseId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecks` ADD CONSTRAINT `tblCrdGlassChecks_BaseL_fk` FOREIGN KEY (`BaseL`) REFERENCES `tblBases`(`BaseId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecks` ADD CONSTRAINT `tblCrdGlassChecks_AddBaseR_fk` FOREIGN KEY (`AddBaseR`) REFERENCES `tblBases`(`BaseId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecks` ADD CONSTRAINT `tblCrdGlassChecks_AddBaseL_fk` FOREIGN KEY (`AddBaseL`) REFERENCES `tblBases`(`BaseId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecks` ADD CONSTRAINT `tblCrdGlassChecks_PBaseR_fk` FOREIGN KEY (`PBaseR`) REFERENCES `tblBases`(`BaseId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecks` ADD CONSTRAINT `tblCrdGlassChecks_PBaseL_fk` FOREIGN KEY (`PBaseL`) REFERENCES `tblBases`(`BaseId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecks` ADD CONSTRAINT `tblCrdGlassChecks_PAddBaseR_fk` FOREIGN KEY (`PAddBaseR`) REFERENCES `tblBases`(`BaseId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecks` ADD CONSTRAINT `tblCrdGlassChecks_PAddBaseL_fk` FOREIGN KEY (`PAddBaseL`) REFERENCES `tblBases`(`BaseId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdBuys` ADD CONSTRAINT `tblCrdBuys_BranchId_fk` FOREIGN KEY (`BranchId`) REFERENCES `tblBranchs`(`BranchId`) ON UPDATE CASCADE;
ALTER TABLE `tblInventory` ADD CONSTRAINT `tblInventory_BranchId_fk` FOREIGN KEY (`BranchId`) REFERENCES `tblBranchs`(`BranchId`) ON UPDATE CASCADE;
ALTER TABLE `tblPerData` ADD CONSTRAINT `tblPerData_BranchId_fk` FOREIGN KEY (`BranchId`) REFERENCES `tblBranchs`(`BranchId`) ON UPDATE CASCADE;
ALTER TABLE `tblUsers` ADD CONSTRAINT `tblUsers_BranchId_fk` FOREIGN KEY (`BranchId`) REFERENCES `tblBranchs`(`BranchId`) ON UPDATE CASCADE;
ALTER TABLE `tblContacts` ADD CONSTRAINT `tblContacts_CityID_fk` FOREIGN KEY (`CityID`) REFERENCES `tblCitys`(`CityId`) ON UPDATE CASCADE;
ALTER TABLE `tblGroups` ADD CONSTRAINT `tblGroups_CityId_fk` FOREIGN KEY (`CityId`) REFERENCES `tblCitys`(`CityId`) ON UPDATE CASCADE;
ALTER TABLE `tblPerData` ADD CONSTRAINT `tblPerData_CityId_fk` FOREIGN KEY (`CityId`) REFERENCES `tblCitys`(`CityId`) ON UPDATE CASCADE;
ALTER TABLE `tblUsers` ADD CONSTRAINT `tblUsers_CityId_fk` FOREIGN KEY (`CityId`) REFERENCES `tblCitys`(`CityId`) ON UPDATE CASCADE;
ALTER TABLE `tblClndrTasks` ADD CONSTRAINT `tblClndrTasks_PriorityId_fk` FOREIGN KEY (`PriorityId`) REFERENCES `tblClndrTasksPriority`(`PriorityId`) ON UPDATE CASCADE;
ALTER TABLE `tblCLnsPrices` ADD CONSTRAINT `tblCLnsPrices_CLensTypeID_fk` FOREIGN KEY (`CLensTypeID`) REFERENCES `tblCLnsTypes`(`CLensTypeID`) ON UPDATE CASCADE;
ALTER TABLE `tblContactAgents` ADD CONSTRAINT `tblContactAgents_CntID_fk` FOREIGN KEY (`CntID`) REFERENCES `tblContacts`(`CntID`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdClensChecks` ADD CONSTRAINT `tblCrdClensChecks_TintR_fk` FOREIGN KEY (`TintR`) REFERENCES `tblCrdClensChecksTint`(`TintId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensChecks` ADD CONSTRAINT `tblCrdClensChecks_TintL_fk` FOREIGN KEY (`TintL`) REFERENCES `tblCrdClensChecksTint`(`TintId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdBuysWorks` ADD CONSTRAINT `tblCrdBuysWorks_ClensSapakId_fk` FOREIGN KEY (`ClensSapakId`) REFERENCES `tblCrdClensManuf`(`ClensManufId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensChecks` ADD CONSTRAINT `tblCrdClensChecks_ClensManufIdR_fk` FOREIGN KEY (`ClensManufIdR`) REFERENCES `tblCrdClensManuf`(`ClensManufId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensChecks` ADD CONSTRAINT `tblCrdClensChecks_ClensManufIdL_fk` FOREIGN KEY (`ClensManufIdL`) REFERENCES `tblCrdClensManuf`(`ClensManufId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensFits` ADD CONSTRAINT `tblCrdClensFits_ClensManufIdR_fk` FOREIGN KEY (`ClensManufIdR`) REFERENCES `tblCrdClensManuf`(`ClensManufId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensFits` ADD CONSTRAINT `tblCrdClensFits_ClensManufIdL_fk` FOREIGN KEY (`ClensManufIdL`) REFERENCES `tblCrdClensManuf`(`ClensManufId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensChecks` ADD CONSTRAINT `tblCrdClensChecks_ClensSolCleanId_fk` FOREIGN KEY (`ClensSolCleanId`) REFERENCES `tblCrdClensSolClean`(`ClensSolCleanId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensChecks` ADD CONSTRAINT `tblCrdClensChecks_ClensSolDisinfectId_fk` FOREIGN KEY (`ClensSolDisinfectId`) REFERENCES `tblCrdClensSolDisinfect`(`ClensSolDisinfectId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensChecks` ADD CONSTRAINT `tblCrdClensChecks_ClensSolRinseId_fk` FOREIGN KEY (`ClensSolRinseId`) REFERENCES `tblCrdClensSolRinse`(`ClensSolRinseId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensChecks` ADD CONSTRAINT `tblCrdClensChecks_ClensTypeIdR_fk` FOREIGN KEY (`ClensTypeIdR`) REFERENCES `tblCrdClensTypes`(`ClensTypeId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensChecks` ADD CONSTRAINT `tblCrdClensChecks_ClensTypeIdL_fk` FOREIGN KEY (`ClensTypeIdL`) REFERENCES `tblCrdClensTypes`(`ClensTypeId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensFits` ADD CONSTRAINT `tblCrdClensFits_ClensTypeIdR_fk` FOREIGN KEY (`ClensTypeIdR`) REFERENCES `tblCrdClensTypes`(`ClensTypeId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensFits` ADD CONSTRAINT `tblCrdClensFits_ClensTypeIdL_fk` FOREIGN KEY (`ClensTypeIdL`) REFERENCES `tblCrdClensTypes`(`ClensTypeId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdBuysWorks` ADD CONSTRAINT `tblCrdBuysWorks_GlassSapakId_fk` FOREIGN KEY (`GlassSapakId`) REFERENCES `tblCrdGlassBrand`(`GlassBrandId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecksGlasses` ADD CONSTRAINT `tblCrdGlassChecksGlasses_BrandId_fk` FOREIGN KEY (`BrandId`) REFERENCES `tblCrdGlassBrand`(`GlassBrandId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecksGlasses` ADD CONSTRAINT `tblCrdGlassChecksGlasses_PerId_fk` FOREIGN KEY (`PerId`) REFERENCES `tblCrdGlassChecks`(`PerId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdGlassChecksGlasses` ADD CONSTRAINT `tblCrdGlassChecksGlasses_CheckDate_fk` FOREIGN KEY (`CheckDate`) REFERENCES `tblCrdGlassChecks`(`CheckDate`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblItemLineBuys` ADD CONSTRAINT `tblItemLineBuys_CatId_fk` FOREIGN KEY (`CatId`) REFERENCES `tblCrdBuysCatNums`(`CatId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdBuysCatNums` ADD CONSTRAINT `tblCrdBuysCatNums_BuyId_fk` FOREIGN KEY (`BuyId`) REFERENCES `tblCrdBuys`(`BuyId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdBuysPays` ADD CONSTRAINT `tblCrdBuysPays_BuyId_fk` FOREIGN KEY (`BuyId`) REFERENCES `tblCrdBuys`(`BuyId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdBuysWorks` ADD CONSTRAINT `tblCrdBuysWorks_FLabelId_fk` FOREIGN KEY (`FLabelId`) REFERENCES `tblCrdBuysWorkLabels`(`LabelId`) ON UPDATE CASCADE;
ALTER TABLE `tblContacts` ADD CONSTRAINT `tblContacts_SapakID_fk` FOREIGN KEY (`SapakID`) REFERENCES `tblCrdBuysWorkSapaks`(`SapakID`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdBuysWorkLabels` ADD CONSTRAINT `tblCrdBuysWorkLabels_SapakId_fk` FOREIGN KEY (`SapakId`) REFERENCES `tblCrdBuysWorkSapaks`(`SapakID`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdBuysWorks` ADD CONSTRAINT `tblCrdBuysWorks_FSapakId_fk` FOREIGN KEY (`FSapakId`) REFERENCES `tblCrdBuysWorkSapaks`(`SapakID`) ON UPDATE CASCADE;
ALTER TABLE `tblInventory` ADD CONSTRAINT `tblInventory_InvSapakId_fk` FOREIGN KEY (`InvSapakId`) REFERENCES `tblCrdBuysWorkSapaks`(`SapakID`) ON UPDATE CASCADE;
ALTER TABLE `tblInvoicePays` ADD CONSTRAINT `tblInvoicePays_SapakID_fk` FOREIGN KEY (`SapakID`) REFERENCES `tblCrdBuysWorkSapaks`(`SapakID`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblInvoices` ADD CONSTRAINT `tblInvoices_SapakID_fk` FOREIGN KEY (`SapakID`) REFERENCES `tblCrdBuysWorkSapaks`(`SapakID`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdClensChecks` ADD CONSTRAINT `tblCrdClensChecks_ClensBrandIdR_fk` FOREIGN KEY (`ClensBrandIdR`) REFERENCES `tblCrdClensBrands`(`ClensBrandId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensChecks` ADD CONSTRAINT `tblCrdClensChecks_ClensBrandIdL_fk` FOREIGN KEY (`ClensBrandIdL`) REFERENCES `tblCrdClensBrands`(`ClensBrandId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensFits` ADD CONSTRAINT `tblCrdClensFits_ClensBrandIdR_fk` FOREIGN KEY (`ClensBrandIdR`) REFERENCES `tblCrdClensBrands`(`ClensBrandId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensFits` ADD CONSTRAINT `tblCrdClensFits_ClensBrandIdL_fk` FOREIGN KEY (`ClensBrandIdL`) REFERENCES `tblCrdClensBrands`(`ClensBrandId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensChecks` ADD CONSTRAINT `tblCrdClensChecks_MaterR_fk` FOREIGN KEY (`MaterR`) REFERENCES `tblCrdClensChecksMater`(`MaterId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensChecks` ADD CONSTRAINT `tblCrdClensChecks_MaterL_fk` FOREIGN KEY (`MaterL`) REFERENCES `tblCrdClensChecksMater`(`MaterId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensChecks` ADD CONSTRAINT `tblCrdClensChecks_PrR_fk` FOREIGN KEY (`PrR`) REFERENCES `tblCrdClensChecksPr`(`PrId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensChecks` ADD CONSTRAINT `tblCrdClensChecks_PrL_fk` FOREIGN KEY (`PrL`) REFERENCES `tblCrdClensChecksPr`(`PrId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensFits` ADD CONSTRAINT `tblCrdClensFits_PerId_fk` FOREIGN KEY (`PerId`) REFERENCES `tblCrdClensChecks`(`PerId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdClensFits` ADD CONSTRAINT `tblCrdClensFits_CheckDate_fk` FOREIGN KEY (`CheckDate`) REFERENCES `tblCrdClensChecks`(`CheckDate`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdGlassChecksGlassesP` ADD CONSTRAINT `tblCrdGlassChecksGlassesP_PerId_fk` FOREIGN KEY (`PerId`) REFERENCES `tblCrdGlassChecks`(`PerId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdGlassChecksGlassesP` ADD CONSTRAINT `tblCrdGlassChecksGlassesP_CheckDate_fk` FOREIGN KEY (`CheckDate`) REFERENCES `tblCrdGlassChecks`(`CheckDate`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdGlassChecksPrevs` ADD CONSTRAINT `tblCrdGlassChecksPrevs_PerId_fk` FOREIGN KEY (`PerId`) REFERENCES `tblCrdGlassChecks`(`PerId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdGlassChecksPrevs` ADD CONSTRAINT `tblCrdGlassChecksPrevs_CheckDate_fk` FOREIGN KEY (`CheckDate`) REFERENCES `tblCrdGlassChecks`(`CheckDate`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdLVChecks` ADD CONSTRAINT `tblCrdLVChecks_PerId_fk` FOREIGN KEY (`PerId`) REFERENCES `tblCrdGlassChecks`(`PerId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdLVChecks` ADD CONSTRAINT `tblCrdLVChecks_CheckDate_fk` FOREIGN KEY (`CheckDate`) REFERENCES `tblCrdGlassChecks`(`CheckDate`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdGlassChecksGlasses` ADD CONSTRAINT `tblCrdGlassChecksGlasses_CoatId_fk` FOREIGN KEY (`CoatId`) REFERENCES `tblCrdGlassCoat`(`GlassCoatId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecksGlasses` ADD CONSTRAINT `tblCrdGlassChecksGlasses_ColorId_fk` FOREIGN KEY (`ColorId`) REFERENCES `tblCrdGlassColor`(`GlassColorId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecks` ADD CONSTRAINT `tblCrdGlassChecks_IOPInstId_fk` FOREIGN KEY (`IOPInstId`) REFERENCES `tblCrdGlassIOPInsts`(`IOPInstId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecksGlasses` ADD CONSTRAINT `tblCrdGlassChecksGlasses_MaterId_fk` FOREIGN KEY (`MaterId`) REFERENCES `tblCrdGlassMater`(`GlassMaterId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecksGlasses` ADD CONSTRAINT `tblCrdGlassChecksGlasses_ModelId_fk` FOREIGN KEY (`ModelId`) REFERENCES `tblCrdGlassModel`(`GlassModelId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecksPrevs` ADD CONSTRAINT `tblCrdGlassChecksPrevs_RetDistId1_fk` FOREIGN KEY (`RetDistId1`) REFERENCES `tblCrdGlassRetDists`(`RetDistId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecksPrevs` ADD CONSTRAINT `tblCrdGlassChecksPrevs_RetDistId2_fk` FOREIGN KEY (`RetDistId2`) REFERENCES `tblCrdGlassRetDists`(`RetDistId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecksPrevs` ADD CONSTRAINT `tblCrdGlassChecksPrevs_RetTypeId1_fk` FOREIGN KEY (`RetTypeId1`) REFERENCES `tblCrdGlassRetTypes`(`RetTypeId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecksPrevs` ADD CONSTRAINT `tblCrdGlassChecksPrevs_RetTypeId2_fk` FOREIGN KEY (`RetTypeId2`) REFERENCES `tblCrdGlassRetTypes`(`RetTypeId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecksGlasses` ADD CONSTRAINT `tblCrdGlassChecksGlasses_RoleId_fk` FOREIGN KEY (`RoleId`) REFERENCES `tblCrdGlassRole`(`GlassRoleId`) ON UPDATE CASCADE;
ALTER TABLE `tblInvoicePays` ADD CONSTRAINT `tblInvoicePays_CreditCardId_fk` FOREIGN KEY (`CreditCardId`) REFERENCES `tblCreditCards`(`CreditCardId`) ON UPDATE CASCADE;
ALTER TABLE `tblGroups` ADD CONSTRAINT `tblGroups_DiscountId_fk` FOREIGN KEY (`DiscountId`) REFERENCES `tblDiscounts`(`DiscountId`) ON UPDATE CASCADE;
ALTER TABLE `tblPerData` ADD CONSTRAINT `tblPerData_DiscountId_fk` FOREIGN KEY (`DiscountId`) REFERENCES `tblDiscounts`(`DiscountId`) ON UPDATE CASCADE;
ALTER TABLE `tblFaxes` ADD CONSTRAINT `tblFaxes_faxStatId_fk` FOREIGN KEY (`faxStatId`) REFERENCES `tblFaxStats`(`faxStatId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblPerData` ADD CONSTRAINT `tblPerData_GroupId_fk` FOREIGN KEY (`GroupId`) REFERENCES `tblGroups`(`GroupId`) ON UPDATE CASCADE;
ALTER TABLE `tblInvoicesInvs` ADD CONSTRAINT `tblInvoicesInvs_InvId_fk` FOREIGN KEY (`InvId`) REFERENCES `tblInventory`(`InvId`) ON UPDATE CASCADE;
ALTER TABLE `tblInventory` ADD CONSTRAINT `tblInventory_InvMovePropId_fk` FOREIGN KEY (`InvMovePropId`) REFERENCES `tblInvMoveProps`(`InvMovePropId`) ON UPDATE CASCADE;
ALTER TABLE `tblInvoicesInvs` ADD CONSTRAINT `tblInvoicesInvs_InvoiceId_fk` FOREIGN KEY (`InvoiceId`) REFERENCES `tblInvoices`(`InvoiceId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblInvoices` ADD CONSTRAINT `tblInvoices_InvoiceTypeId_fk` FOREIGN KEY (`InvoiceTypeId`) REFERENCES `tblInvoiceTypes`(`InvoiceTypeId`) ON UPDATE CASCADE;
ALTER TABLE `tblItemCounts` ADD CONSTRAINT `tblItemCounts_CountYear_fk` FOREIGN KEY (`CountYear`) REFERENCES `tblItemCountsYears`(`CountYear`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblItemLineBuys` ADD CONSTRAINT `tblItemLineBuys_ItemLineId_fk` FOREIGN KEY (`ItemLineId`) REFERENCES `tblItemLines`(`ItemLineId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblItemCounts` ADD CONSTRAINT `tblItemCounts_ItemId_fk` FOREIGN KEY (`ItemId`) REFERENCES `tblItems`(`ItemId`) ON UPDATE CASCADE;
ALTER TABLE `tblPerData` ADD CONSTRAINT `tblPerData_LangId_fk` FOREIGN KEY (`LangId`) REFERENCES `tblLangs`(`LangId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecksGlassesP` ADD CONSTRAINT `tblCrdGlassChecksGlassesP_LensCharId_fk` FOREIGN KEY (`LensCharId`) REFERENCES `tblLnsChars`(`LensCharId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecksGlassesP` ADD CONSTRAINT `tblCrdGlassChecksGlassesP_LensMaterId_fk` FOREIGN KEY (`LensMaterId`) REFERENCES `tblLnsMaterials`(`LensMaterId`) ON UPDATE CASCADE;
ALTER TABLE `tblLnsPrices` ADD CONSTRAINT `tblLnsPrices_LensMaterID_fk` FOREIGN KEY (`LensMaterID`) REFERENCES `tblLnsMaterials`(`LensMaterId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecksGlassesP` ADD CONSTRAINT `tblCrdGlassChecksGlassesP_TreatCharId_fk` FOREIGN KEY (`TreatCharId`) REFERENCES `tblLnsTreatChars`(`TreatCharId`) ON UPDATE CASCADE;
ALTER TABLE `tblLnsTreatmens` ADD CONSTRAINT `tblLnsTreatmens_TreatId_fk` FOREIGN KEY (`TreatId`) REFERENCES `tblLnsTreatTypes`(`TreatId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecksGlassesP` ADD CONSTRAINT `tblCrdGlassChecksGlassesP_LensTypeId_fk` FOREIGN KEY (`LensTypeId`) REFERENCES `tblLnsTypes`(`LensTypeId`) ON UPDATE CASCADE;
ALTER TABLE `tblLnsPrices` ADD CONSTRAINT `tblLnsPrices_LensTypeID_fk` FOREIGN KEY (`LensTypeID`) REFERENCES `tblLnsTypes`(`LensTypeId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdBuysPays` ADD CONSTRAINT `tblCrdBuysPays_PayTypeId_fk` FOREIGN KEY (`PayTypeId`) REFERENCES `tblPayTypes`(`PayTypeId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdBuysWorks` ADD CONSTRAINT `tblCrdBuysWorks_PerId_fk` FOREIGN KEY (`PerId`) REFERENCES `tblPerData`(`PerId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdClensChecks` ADD CONSTRAINT `tblCrdClensChecks_PerId_fk` FOREIGN KEY (`PerId`) REFERENCES `tblPerData`(`PerId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdClinicChecks` ADD CONSTRAINT `tblCrdClinicChecks_PerId_fk` FOREIGN KEY (`PerId`) REFERENCES `tblPerData`(`PerId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdDiags` ADD CONSTRAINT `tblCrdDiags_PerId_fk` FOREIGN KEY (`PerId`) REFERENCES `tblPerData`(`PerId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdDisDiags` ADD CONSTRAINT `tblCrdDisDiags_PerId_fk` FOREIGN KEY (`PerId`) REFERENCES `tblPerData`(`PerId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdFrps` ADD CONSTRAINT `tblCrdFrps_PerId_fk` FOREIGN KEY (`PerId`) REFERENCES `tblPerData`(`PerId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdGlassChecks` ADD CONSTRAINT `tblCrdGlassChecks_PerId_fk` FOREIGN KEY (`PerId`) REFERENCES `tblPerData`(`PerId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdOverViews` ADD CONSTRAINT `tblCrdOverViews_PerId_fk` FOREIGN KEY (`PerId`) REFERENCES `tblPerData`(`PerId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblLettersFollowup` ADD CONSTRAINT `tblLettersFollowup_PerId_fk` FOREIGN KEY (`PerId`) REFERENCES `tblPerData`(`PerId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblPerLast` ADD CONSTRAINT `tblPerLast_PerId_fk` FOREIGN KEY (`PerId`) REFERENCES `tblPerData`(`PerId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblSapakPerComments` ADD CONSTRAINT `tblSapakPerComments_prlType_fk` FOREIGN KEY (`prlType`) REFERENCES `tblPrlTypes`(`prlType`) ON UPDATE CASCADE;
ALTER TABLE `tblPropsPrices` ADD CONSTRAINT `tblPropsPrices_PropId_fk` FOREIGN KEY (`PropId`) REFERENCES `tblPropsNames`(`PropId`) ON UPDATE CASCADE;
ALTER TABLE `tblPerData` ADD CONSTRAINT `tblPerData_RefsSub1Id_fk` FOREIGN KEY (`RefsSub1Id`) REFERENCES `tblRefsSub1`(`RefsSub1Id`) ON UPDATE CASCADE;
ALTER TABLE `tblRefsSub2` ADD CONSTRAINT `tblRefsSub2_subRefId_fk` FOREIGN KEY (`subRefId`) REFERENCES `tblRefsSub1`(`RefsSub1Id`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblPerData` ADD CONSTRAINT `tblPerData_RefsSub2Id_fk` FOREIGN KEY (`RefsSub2Id`) REFERENCES `tblRefsSub2`(`RefsSub2Id`) ON UPDATE CASCADE;
ALTER TABLE `tblPerData` ADD CONSTRAINT `tblPerData_RefId_fk` FOREIGN KEY (`RefId`) REFERENCES `tblRefs`(`RefId`) ON UPDATE CASCADE;
ALTER TABLE `tblRefsSub1` ADD CONSTRAINT `tblRefsSub1_RefId_fk` FOREIGN KEY (`RefId`) REFERENCES `tblRefs`(`RefId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblFaxes` ADD CONSTRAINT `tblFaxes_SapakDestId_fk` FOREIGN KEY (`SapakDestId`) REFERENCES `tblSapakDests`(`SapakDestId`) ON UPDATE CASCADE;
ALTER TABLE `tblSapakSendsLensPlan` ADD CONSTRAINT `tblSapakSendsLensPlan_SapakSendId_fk` FOREIGN KEY (`SapakSendId`) REFERENCES `tblSapakSends`(`SapakSendId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdBuysWorks` ADD CONSTRAINT `tblCrdBuysWorks_LnsSapakId_fk` FOREIGN KEY (`LnsSapakId`) REFERENCES `tblSapaks`(`SapakID`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecksGlassesP` ADD CONSTRAINT `tblCrdGlassChecksGlassesP_SapakId_fk` FOREIGN KEY (`SapakId`) REFERENCES `tblSapaks`(`SapakID`) ON UPDATE CASCADE;
ALTER TABLE `tblSapakDests` ADD CONSTRAINT `tblSapakDests_SapakId_fk` FOREIGN KEY (`SapakId`) REFERENCES `tblSapaks`(`SapakID`) ON UPDATE CASCADE;
ALTER TABLE `tblSapakPerComments` ADD CONSTRAINT `tblSapakPerComments_SapakId_fk` FOREIGN KEY (`SapakId`) REFERENCES `tblSapaks`(`SapakID`) ON UPDATE CASCADE;
ALTER TABLE `tblUsers` ADD CONSTRAINT `tblUsers_LevelId_fk` FOREIGN KEY (`LevelId`) REFERENCES `tblSysLevels`(`LevelId`) ON UPDATE CASCADE;
ALTER TABLE `tblClndrApt` ADD CONSTRAINT `tblClndrApt_UserID_fk` FOREIGN KEY (`UserID`) REFERENCES `tblUsers`(`UserId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblClndrSal` ADD CONSTRAINT `tblClndrSal_UserID_fk` FOREIGN KEY (`UserID`) REFERENCES `tblUsers`(`UserId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblClndrTasks` ADD CONSTRAINT `tblClndrTasks_UserId_fk` FOREIGN KEY (`UserId`) REFERENCES `tblUsers`(`UserId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblClndrWrk` ADD CONSTRAINT `tblClndrWrk_UserID_fk` FOREIGN KEY (`UserID`) REFERENCES `tblUsers`(`UserId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblClndrWrkFD` ADD CONSTRAINT `tblClndrWrkFD_UserID_fk` FOREIGN KEY (`UserID`) REFERENCES `tblUsers`(`UserId`) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE `tblCrdBuys` ADD CONSTRAINT `tblCrdBuys_UserId_fk` FOREIGN KEY (`UserId`) REFERENCES `tblUsers`(`UserId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdBuysWorks` ADD CONSTRAINT `tblCrdBuysWorks_UserId_fk` FOREIGN KEY (`UserId`) REFERENCES `tblUsers`(`UserId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdClensChecks` ADD CONSTRAINT `tblCrdClensChecks_UserId_fk` FOREIGN KEY (`UserId`) REFERENCES `tblUsers`(`UserId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdDiags` ADD CONSTRAINT `tblCrdDiags_UserId_fk` FOREIGN KEY (`UserId`) REFERENCES `tblUsers`(`UserId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdDisDiags` ADD CONSTRAINT `tblCrdDisDiags_UserId_fk` FOREIGN KEY (`UserId`) REFERENCES `tblUsers`(`UserId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdGlassChecks` ADD CONSTRAINT `tblCrdGlassChecks_UserId_fk` FOREIGN KEY (`UserId`) REFERENCES `tblUsers`(`UserId`) ON UPDATE CASCADE;
ALTER TABLE `tblCrdOverViews` ADD CONSTRAINT `tblCrdOverViews_UserId_fk` FOREIGN KEY (`UserId`) REFERENCES `tblUsers`(`UserId`) ON UPDATE CASCADE;
ALTER TABLE `tblInventory` ADD CONSTRAINT `tblInventory_UserId_fk` FOREIGN KEY (`UserId`) REFERENCES `tblUsers`(`UserId`) ON UPDATE CASCADE;
ALTER TABLE `tblPerData` ADD CONSTRAINT `tblPerData_UserId_fk` FOREIGN KEY (`UserId`) REFERENCES `tblUsers`(`UserId`) ON UPDATE CASCADE;
ALTER TABLE `tblSapakSends` ADD CONSTRAINT `tblSapakSends_UserId_fk` FOREIGN KEY (`UserId`) REFERENCES `tblUsers`(`UserId`) ON UPDATE CASCADE;
