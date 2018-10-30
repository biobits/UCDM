/*********************************************************
*         SQL Server scripts to create ucdm data model tables
*           Stefan Bartels - 26-10-2018
**********************************************************/


/*
-------------------------------------------------------------------------------------------
-- create ENCOUNTER_MAPPING table with clustered PK on ENCOUNTER_IDE, ENCOUNTER_IDE_SOURCE 
-------------------------------------------------------------------------------------------

CREATE TABLE ENCOUNTER_MAPPING ( 
    ENCOUNTER_IDE       	VARCHAR(200)  NOT NULL,
    ENCOUNTER_IDE_SOURCE	VARCHAR(50)  NOT NULL,
    PROJECT_ID              VARCHAR(50) NOT NULL,
    ENCOUNTER_NUM			INT NOT NULL,
    PATIENT_IDE         	VARCHAR(200) NOT NULL,
    PATIENT_IDE_SOURCE  	VARCHAR(50) NOT NULL,
    ENCOUNTER_IDE_STATUS	VARCHAR(50) NULL,
    UPLOAD_DATE         	DATETIME NULL,
    UPDATE_DATE             DATETIME NULL,
    DOWNLOAD_DATE       	DATETIME NULL,
    IMPORT_DATE             DATETIME NULL,
    SOURCESYSTEM_CD         VARCHAR(50) NULL,
    UPLOAD_ID               INT NULL,
    CONSTRAINT ENCOUNTER_MAPPING_PK PRIMARY KEY(ENCOUNTER_IDE, ENCOUNTER_IDE_SOURCE, PROJECT_ID, PATIENT_IDE, PATIENT_IDE_SOURCE)
 )
;
CREATE  INDEX EM_IDX_ENCPATH ON ENCOUNTER_MAPPING(ENCOUNTER_IDE, ENCOUNTER_IDE_SOURCE, PATIENT_IDE, PATIENT_IDE_SOURCE, ENCOUNTER_NUM)
;
CREATE  INDEX EM_IDX_UPLOADID ON ENCOUNTER_MAPPING(UPLOAD_ID)
;
CREATE INDEX EM_ENCNUM_IDX ON ENCOUNTER_MAPPING(ENCOUNTER_NUM)
;


-------------------------------------------------------------------------------------
-- create PATIENT_MAPPING table with clustered PK on PATIENT_IDE, PATIENT_IDE_SOURCE
-------------------------------------------------------------------------------------

CREATE TABLE PATIENT_MAPPING ( 
    PATIENT_IDE         VARCHAR(200)  NOT NULL,
    PATIENT_IDE_SOURCE	VARCHAR(50)  NOT NULL,
    PATIENT_NUM       	INT NOT NULL,
    PATIENT_IDE_STATUS	VARCHAR(50) NULL,
    PROJECT_ID          VARCHAR(50) NOT NULL,
    UPLOAD_DATE       	DATETIME NULL,
    UPDATE_DATE       	DATETIME NULL,
    DOWNLOAD_DATE     	DATETIME NULL,
    IMPORT_DATE         DATETIME NULL,
    SOURCESYSTEM_CD   	VARCHAR(50) NULL,
    UPLOAD_ID         	INT NULL,
    CONSTRAINT PATIENT_MAPPING_PK PRIMARY KEY(PATIENT_IDE, PATIENT_IDE_SOURCE, PROJECT_ID)
 )
;
CREATE  INDEX PM_IDX_UPLOADID ON PATIENT_MAPPING(UPLOAD_ID)
;
CREATE INDEX PM_PATNUM_IDX ON PATIENT_MAPPING(PATIENT_NUM)
;
CREATE INDEX PM_ENCPNUM_IDX ON 
PATIENT_MAPPING(PATIENT_IDE,PATIENT_IDE_SOURCE,PATIENT_NUM) ;
*/

------------------------------------------------------------------------------
-- create CODE_LOOKUP table with clustered PK on TABLE_CD, COLUMN_CD, CODE_CD 
------------------------------------------------------------------------------

CREATE TABLE CODE_LOOKUP ( 
    TABLE_CD            VARCHAR(100) NOT NULL,
    COLUMN_CD           VARCHAR(100) NOT NULL,
    CODE_CD             VARCHAR(50) NOT NULL,
    NAME_CHAR           VARCHAR(650) NULL,
    LOOKUP_BLOB         VARCHAR(MAX) NULL, 
    UPLOAD_DATE       	DATETIME NULL,
    UPDATE_DATE         DATETIME NULL,
    DOWNLOAD_DATE     	DATETIME NULL,
    IMPORT_DATE         DATETIME NULL,
    SOURCESYSTEM_CD   	VARCHAR(50) NULL,
    UPLOAD_ID         	INT NULL,
	CONSTRAINT CODE_LOOKUP_PK PRIMARY KEY(TABLE_CD, COLUMN_CD, CODE_CD)
	)
;

/* add index on name_char field */
CREATE INDEX CL_IDX_NAME_CHAR ON CODE_LOOKUP(NAME_CHAR)
;
CREATE INDEX CL_IDX_UPLOADID ON CODE_LOOKUP(UPLOAD_ID)
;


--------------------------------------------------------------------
-- create DimConcept table with clustered PK on ConceptPath 
--------------------------------------------------------------------

CREATE TABLE DimConcept ( 
	ConceptKey			INT NOT NULL,
	ConceptPath   		VARCHAR(700) NOT NULL,
	ConceptCode    		VARCHAR(50) NULL,
	Name				VARCHAR(2000) NULL,
	SourceSystemId   	VARCHAR(50) NULL,
	CreateDate    		DATETIME NULL,
	ModifyDate  		DATETIME NULL
    CONSTRAINT CONCEPT_DIMENSION_PK PRIMARY KEY(ConceptPath)
	)
;



---------------------------------------------------------------------------------------------------------------------------------------
-- create FactObervation table with NONclustered PK on PatientKey, ConceptKey,  ModifierKey, DateKey, EventKey, InstanceKey, ProviderKey,ItemInstanceNumber 
---------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE FactObservation ( 
	
	PatientKey    		INT NOT NULL,
	ContextKey     		INT NOT NULL,
	EventKey 			INT NOT NULL,
	ProviderKey    		INT NOT NULL,
	ModifierKey    		INT default -1 NOT NULL,
	ConceptKey 			INT NOT NULL,
	StartDateKey     	INT NOT NULL,
	ItemInstanceNumber	INT default (1) NOT NULL,
	ValueTypeCode     	VARCHAR(50) NULL,
	TextValue      		VARCHAR(255) NULL,
	NumberValue    		DECIMAL(18,5) NULL,
	ValueFlag   		VARCHAR(50) NULL,
	Quantity   			DECIMAL(18,5) NULL,
	Units       		VARCHAR(50) NULL,
	EndDate       		DATETIME NULL,
	ObservationBlob		VARCHAR(MAX) NULL,
	ConfidenceLevel		VARCHAR(10) NULL,
	SourceSystemId		VARCHAR(50) NULL, 
	CreateDate  		DATETIME NULL,
	ModifyDate   		DATETIME NULL
    CONSTRAINT FactObservation_PK PRIMARY KEY nonclustered (PatientKey, ConceptKey,  ModifierKey, StartDateKey, EventKey, ContextKey, ProviderKey,ItemInstanceNumber)
	)
;

/* add index on ConceptKey */
CREATE CLUSTERED INDEX OF_IDX_ClusteredConcept ON FactObservation
(
	ConceptKey 
)
;

/* add an index on most of the FactObservation fields */
CREATE INDEX OF_IDX_ALLFactObservation ON FactObservation
(
	PatientKey ,
	EventKey ,
	ConceptKey ,
	StartDateKey ,
	ProviderKey ,
	ModifierKey ,
	ContextKey,
	ItemInstanceNumber,
	ValueTypeCode ,
	TextValue ,
	NumberValue ,
	ValueFlag ,
	Quantity ,
	Units ,
	EndDate ,
	ConfidenceLevel
)
;
/* add additional indexes on FactObservation fields */
CREATE INDEX OF_IDX_Start_Date ON FactObservation(StartDateKey, PatientKey,ContextKey)
;
CREATE INDEX OF_IDX_Modifier ON FactObservation(ModifierKey)
;
CREATE INDEX OF_IDX_Encounter_Patient ON FactObservation(EventKey, PatientKey,ContextKey, ItemInstanceNumber)
;
--CREATE INDEX OF_IDX_UPLOADID ON FactObservation(UPLOAD_ID)
--;
CREATE INDEX OF_IDX_SOURCESYSTEM_CD ON FactObservation(SourceSystemId)
;
--CREATE UNIQUE INDEX OF_TEXT_SEARCH_UNIQUE ON FactObservation(TEXT_SEARCH_INDEX)
--;
EXEC SP_FULLTEXT_DATABASE 'ENABLE'
;
CREATE FULLTEXT CATALOG FTCATALOG AS DEFAULT
;
CREATE FULLTEXT INDEX ON FactObservation(ObservationBlob)
 KEY INDEX OF_TEXT_SEARCH_UNIQUE 
;



-------------------------------------------------------------------
-- create DimPatient table with clustered PK on PatientKey 
-------------------------------------------------------------------

CREATE TABLE DimPatient ( 
	PatientKey      	INT NOT NULL,
	PatientFK			VARCHAR(50) NULL,
	BirthDate       	DATETIME NULL,
	Sex	       			VARCHAR(50) NULL,
	VitalStatus			VARCHAR(50) NULL,
	DeathDate       	DATETIME NULL,
	Zip					VARCHAR(10) NULL,
	Latitude			DECIMAL(3,6) NULL 
	Longitude			DECIMAL(3,6)NULL,
	PATIENT_BLOB     	VARCHAR(MAX) NULL,
	UPDATE_DATE      	DATETIME NULL,
	DOWNLOAD_DATE    	DATETIME NULL,
	IMPORT_DATE      	DATETIME NULL,
	SOURCESYSTEM_CD  	VARCHAR(50) NULL,
    UPLOAD_ID         	INT NULL, 
    CONSTRAINT DimPatient_PK PRIMARY KEY(PATIENT_NUM)
	)
;

/* add indexes on additional DimPatient fields */
CREATE  INDEX PD_IDX_DATES ON DimPatient(PATIENT_NUM, VITAL_STATUS_CD, BIRTH_DATE, DEATH_DATE)
;
CREATE  INDEX PD_IDX_AllPatientDim ON DimPatient(PATIENT_NUM, VITAL_STATUS_CD, BIRTH_DATE, DEATH_DATE, SEX_CD, AGE_IN_YEARS_NUM, LANGUAGE_CD, RACE_CD, MARITAL_STATUS_CD, INCOME_CD, RELIGION_CD, ZIP_CD)
;
CREATE  INDEX PD_IDX_StateCityZip ON DimPatient (STATECITYZIP_PATH, PATIENT_NUM)
;
CREATE INDEX PA_IDX_UPLOADID ON DimPatient(UPLOAD_ID)
;


-----------------------------------------------------------------------------------
-- create PROVIDER_DIMENSION table with clustered PK on PROVIDER_PATH, PROVIDER_ID 
-----------------------------------------------------------------------------------

CREATE TABLE PROVIDER_DIMENSION ( 
	PROVIDER_ID    		VARCHAR(50) NOT NULL,
	PROVIDER_PATH  		VARCHAR(700) NOT NULL,
	NAME_CHAR      		VARCHAR(850) NULL,
	PROVIDER_BLOB  		VARCHAR(MAX) NULL,
	UPDATE_DATE    		DATETIME NULL,
	DOWNLOAD_DATE  		DATETIME NULL,
	IMPORT_DATE    		DATETIME NULL,
	SOURCESYSTEM_CD		VARCHAR(50) NULL ,
    UPLOAD_ID         	INT NULL,
    CONSTRAINT PROVIDER_DIMENSION_PK PRIMARY KEY(PROVIDER_PATH, PROVIDER_ID)
	)
;

/* add index on PROVIDER_ID, NAME_CHAR */
CREATE INDEX PD_IDX_NAME_CHAR ON PROVIDER_DIMENSION(PROVIDER_ID, NAME_CHAR)
;
CREATE INDEX PD_IDX_UPLOADID ON PROVIDER_DIMENSION(UPLOAD_ID)
;


-------------------------------------------------------------------
-- create VISIT_DIMENSION table with clustered PK on ENCOUNTER_NUM 
-------------------------------------------------------------------

CREATE TABLE VISIT_DIMENSION ( 
	ENCOUNTER_NUM  		INT NOT NULL,
	PATIENT_NUM    		INT NOT NULL,
	ACTIVE_STATUS_CD	VARCHAR(50) NULL,
	START_DATE     		DATETIME NULL,
	END_DATE       		DATETIME NULL,
	INOUT_CD       		VARCHAR(50) NULL,
	LOCATION_CD    		VARCHAR(50) NULL,
    LOCATION_PATH  		VARCHAR(900) NULL,
	LENGTH_OF_STAY		INT NULL,
	VISIT_BLOB     		VARCHAR(MAX) NULL,
	UPDATE_DATE    		DATETIME NULL,
	DOWNLOAD_DATE  		DATETIME NULL,
	IMPORT_DATE    		DATETIME NULL,
	SOURCESYSTEM_CD		VARCHAR(50) NULL ,
    UPLOAD_ID         	INT NULL, 
    CONSTRAINT VISIT_DIMENSION_PK PRIMARY KEY(ENCOUNTER_NUM, PATIENT_NUM)
	)
;

/* add indexes on addtional visit_dimension fields */
CREATE  INDEX VD_IDX_DATES ON VISIT_DIMENSION(ENCOUNTER_NUM, START_DATE, END_DATE)
;
CREATE  INDEX VD_IDX_AllVisitDim ON VISIT_DIMENSION(ENCOUNTER_NUM, PATIENT_NUM, INOUT_CD, LOCATION_CD, START_DATE, LENGTH_OF_STAY, END_DATE)
;
CREATE  INDEX VD_IDX_UPLOADID ON VISIT_DIMENSION(UPLOAD_ID)
;


------------------------------------------------------------
-- create MODIFIER_DIMENSION table with PK on MODIFIER_PATH 
------------------------------------------------------------

CREATE TABLE MODIFIER_DIMENSION ( 
	MODIFIER_PATH   	VARCHAR(700) NOT NULL,
	MODIFIER_CD     	VARCHAR(50) NULL,
	NAME_CHAR      		VARCHAR(2000) NULL,
	MODIFIER_BLOB   	VARCHAR(MAX) NULL,
	UPDATE_DATE    		DATETIME NULL,
	DOWNLOAD_DATE  		DATETIME NULL,
	IMPORT_DATE    		DATETIME NULL,
	SOURCESYSTEM_CD		VARCHAR(50) NULL,
    UPLOAD_ID			INT NULL,
    CONSTRAINT MODIFIER_DIMENSION_PK PRIMARY KEY(modifier_path)
	)
;
CREATE INDEX MD_IDX_UPLOADID ON MODIFIER_DIMENSION(UPLOAD_ID)
;
------------------------------------------------------------
-- create Calendar Dimension table with PK on DateKey 
------------------------------------------------------------

CREATE TABLE [dbo].[DimDate](
	[DateKey] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[DateDE] [nvarchar](10) NOT NULL,
	[WeekdayNumber] [tinyint] NOT NULL,
	[WeekDayName] [nvarchar](10) NOT NULL,
	[DayOfMonthNumber] [tinyint] NOT NULL,
	[MonthNumber] [tinyint] NOT NULL,
	[Quarter] [tinyint] NOT NULL,
	[QuarterName] [nvarchar](20) NOT NULL,
	[Year] [smallint] NOT NULL,
	[Semester] [tinyint] NOT NULL,
	[QuarterWithYear] [nvarchar](30) NOT NULL,
	[WeekOfYear] [tinyint] NOT NULL,
	[WeekOfYearNameDE] [nvarchar](20) NOT NULL,
	[MonthOfYearFullName] [nvarchar](20) NOT NULL,
	[WeekOfYearFullname] [nvarchar](20) NOT NULL,
	[MonthName] [nvarchar](30) NOT NULL,
	[SemesterWithYear] [nvarchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
