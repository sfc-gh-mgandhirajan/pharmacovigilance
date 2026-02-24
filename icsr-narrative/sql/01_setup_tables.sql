-- ============================================================================
-- ICSR Narrative Generator - Database Setup
-- AI-powered Individual Case Safety Report narrative generation
-- ============================================================================

-- Step 1: Create Database and Schema
CREATE DATABASE IF NOT EXISTS HCLS_DEMO;
CREATE SCHEMA IF NOT EXISTS HCLS_DEMO.PHARMACOVIGILANCE;
CREATE SCHEMA IF NOT EXISTS HCLS_DEMO.STREAMLIT_APPS;

USE DATABASE HCLS_DEMO;
USE SCHEMA PHARMACOVIGILANCE;

-- ============================================================================
-- Step 2: Create ICSR Cases Table (Extended for Narrative Generation)
-- ============================================================================

CREATE TABLE IF NOT EXISTS ICSR_CASES_NARRATIVE (
    CASE_ID VARCHAR(50) PRIMARY KEY,
    REPORT_DATE DATE,
    REPORT_SOURCE VARCHAR(50),              -- SPONTANEOUS, CLINICAL_TRIAL, LITERATURE
    REPORTER_TYPE VARCHAR(50),              -- PHYSICIAN, PHARMACIST, CONSUMER, OTHER_HCP
    REPORTER_COUNTRY VARCHAR(50),
    
    -- Patient Information
    PATIENT_AGE INT,
    PATIENT_AGE_UNIT VARCHAR(20),           -- YEARS, MONTHS, DAYS
    PATIENT_SEX VARCHAR(20),
    PATIENT_WEIGHT_KG DECIMAL(5,2),
    MEDICAL_HISTORY TEXT,
    
    -- Suspect Drug Information
    SUSPECT_DRUG_NAME VARCHAR(200),
    DRUG_INDICATION VARCHAR(200),
    DOSE VARCHAR(100),
    ROUTE_OF_ADMIN VARCHAR(50),
    THERAPY_START_DATE DATE,
    THERAPY_END_DATE DATE,
    ACTION_TAKEN VARCHAR(100),              -- WITHDRAWN, DOSE_REDUCED, DOSE_NOT_CHANGED, UNKNOWN
    
    -- Adverse Event Information
    EVENT_TERM VARCHAR(200),
    MEDDRA_PT VARCHAR(200),
    MEDDRA_SOC VARCHAR(200),
    EVENT_ONSET_DATE DATE,
    EVENT_OUTCOME VARCHAR(50),              -- RECOVERED, RECOVERING, NOT_RECOVERED, FATAL, UNKNOWN
    EVENT_DESCRIPTION TEXT,
    
    -- Assessment
    SERIOUSNESS VARCHAR(20),                -- SERIOUS, NON_SERIOUS
    SERIOUSNESS_CRITERIA VARCHAR(200),
    CAUSALITY_ASSESSMENT VARCHAR(50),       -- CERTAIN, PROBABLE, POSSIBLE, UNLIKELY, UNASSESSABLE
    
    -- Narrative
    GENERATED_NARRATIVE TEXT,
    NARRATIVE_GENERATED_AT TIMESTAMP_NTZ,
    
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- Step 3: Create Views for Narrative Generation Dashboard
-- ============================================================================

-- View: Cases pending narrative
CREATE OR REPLACE VIEW V_ICSR_PENDING_NARRATIVE AS
SELECT 
    CASE_ID,
    SUSPECT_DRUG_NAME,
    EVENT_TERM,
    SERIOUSNESS,
    REPORT_DATE,
    PATIENT_AGE || ' ' || PATIENT_AGE_UNIT AS PATIENT_AGE_DISPLAY,
    PATIENT_SEX,
    CAUSALITY_ASSESSMENT
FROM ICSR_CASES_NARRATIVE
WHERE GENERATED_NARRATIVE IS NULL
ORDER BY 
    CASE WHEN SERIOUSNESS = 'SERIOUS' THEN 0 ELSE 1 END,
    REPORT_DATE DESC;

-- View: Narrative generation statistics
CREATE OR REPLACE VIEW V_ICSR_NARRATIVE_STATS AS
SELECT 
    COUNT(*) AS TOTAL_CASES,
    SUM(CASE WHEN GENERATED_NARRATIVE IS NOT NULL THEN 1 ELSE 0 END) AS NARRATIVES_GENERATED,
    SUM(CASE WHEN GENERATED_NARRATIVE IS NULL THEN 1 ELSE 0 END) AS PENDING_NARRATIVES,
    COUNT(DISTINCT SUSPECT_DRUG_NAME) AS UNIQUE_DRUGS,
    SUM(CASE WHEN SERIOUSNESS = 'SERIOUS' THEN 1 ELSE 0 END) AS SERIOUS_CASES
FROM ICSR_CASES_NARRATIVE;

-- ============================================================================
-- Step 4: Create Stage
-- ============================================================================

CREATE STAGE IF NOT EXISTS HCLS_DEMO.STREAMLIT_APPS.ICSR_NARRATIVE_STAGE
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage for ICSR Narrative Generator Streamlit app';
