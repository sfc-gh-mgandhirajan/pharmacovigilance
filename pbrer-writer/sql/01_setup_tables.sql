-- ============================================================================
-- PBRER Medical Writing Assistant - Database Setup
-- ICH E2C(R2) Compliant Periodic Benefit-Risk Evaluation Report Generator
-- ============================================================================
-- Run this script to create all required database objects
-- Usage: Execute in Snowflake with appropriate privileges
-- ============================================================================

-- Step 1: Create Database and Schema (modify names as needed)
CREATE DATABASE IF NOT EXISTS HCLS_DEMO;
CREATE SCHEMA IF NOT EXISTS HCLS_DEMO.PHARMACOVIGILANCE;
CREATE SCHEMA IF NOT EXISTS HCLS_DEMO.STREAMLIT_APPS;

-- Set context
USE DATABASE HCLS_DEMO;
USE SCHEMA PHARMACOVIGILANCE;

-- ============================================================================
-- Step 2: Create Core Tables
-- ============================================================================

-- Product Registry: Contains products for PBRER reporting
CREATE TABLE IF NOT EXISTS PRODUCT_REGISTRY (
    PRODUCT_ID VARCHAR(50) PRIMARY KEY,
    PRODUCT_NAME VARCHAR(200) NOT NULL,
    ACTIVE_INGREDIENT VARCHAR(200),
    THERAPEUTIC_CLASS VARCHAR(100),
    MARKETING_AUTHORIZATION_DATE DATE,
    AUTHORIZATION_HOLDER VARCHAR(200),
    LAST_PSUR_DATE DATE,
    NEXT_PSUR_DUE DATE,
    REFERENCE_SAFETY_INFO TEXT,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ICSR Cases: Individual Case Safety Reports
CREATE TABLE IF NOT EXISTS ICSR_CASES (
    CASE_ID VARCHAR(50) PRIMARY KEY,
    SUSPECT_DRUG_NAME VARCHAR(200) NOT NULL,
    SUSPECT_DRUG_ID VARCHAR(50),
    PATIENT_AGE INT,
    PATIENT_SEX VARCHAR(20),
    PATIENT_WEIGHT DECIMAL(5,2),
    REPORTER_COUNTRY VARCHAR(50),
    REPORT_SOURCE VARCHAR(50),              -- SPONTANEOUS, CLINICAL TRIAL, LITERATURE
    REPORT_DATE DATE,
    RECEIPT_DATE DATE,
    MEDDRA_SOC VARCHAR(200),                -- System Organ Class
    MEDDRA_PT VARCHAR(200),                 -- Preferred Term
    MEDDRA_LLT VARCHAR(200),                -- Lowest Level Term
    SERIOUSNESS VARCHAR(20),                -- SERIOUS, NON-SERIOUS
    SERIOUSNESS_CRITERIA VARCHAR(200),      -- Death, Life-threatening, Hospitalization, etc.
    EVENT_OUTCOME VARCHAR(50),              -- RECOVERED, RECOVERING, NOT RECOVERED, FATAL, UNKNOWN
    EVENT_DESCRIPTION TEXT,
    CAUSALITY_ASSESSMENT VARCHAR(50),       -- CERTAIN, PROBABLE, POSSIBLE, UNLIKELY, UNASSESSABLE
    ACTION_TAKEN VARCHAR(100),
    RECHALLENGE VARCHAR(50),
    DECHALLENGE VARCHAR(50),
    CONCOMITANT_MEDICATIONS TEXT,
    MEDICAL_HISTORY TEXT,
    NARRATIVE TEXT,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- Step 3: Create Analytics Views for PBRER Sections
-- ============================================================================

-- View: Product Summary Statistics (for Section 5: Exposure)
CREATE OR REPLACE VIEW V_PSUR_PRODUCT_SUMMARY AS
SELECT 
    SUSPECT_DRUG_NAME AS PRODUCT,
    COUNT(*) AS TOTAL_CASES,
    SUM(CASE WHEN SERIOUSNESS = 'SERIOUS' THEN 1 ELSE 0 END) AS SERIOUS_CASES,
    SUM(CASE WHEN SERIOUSNESS = 'NON-SERIOUS' THEN 1 ELSE 0 END) AS NON_SERIOUS_CASES,
    COUNT(DISTINCT REPORTER_COUNTRY) AS COUNTRIES_REPORTING,
    COUNT(DISTINCT MEDDRA_SOC) AS UNIQUE_SOCS,
    COUNT(DISTINCT MEDDRA_PT) AS UNIQUE_PTS,
    SUM(CASE WHEN REPORT_SOURCE = 'SPONTANEOUS' THEN 1 ELSE 0 END) AS SPONTANEOUS_REPORTS,
    SUM(CASE WHEN REPORT_SOURCE = 'CLINICAL TRIAL' THEN 1 ELSE 0 END) AS CLINICAL_TRIAL_REPORTS,
    SUM(CASE WHEN REPORT_SOURCE = 'LITERATURE' THEN 1 ELSE 0 END) AS LITERATURE_REPORTS,
    SUM(CASE WHEN CAUSALITY_ASSESSMENT IN ('CERTAIN', 'PROBABLE') THEN 1 ELSE 0 END) AS HIGH_CAUSALITY_CASES,
    MIN(REPORT_DATE) AS EARLIEST_REPORT,
    MAX(REPORT_DATE) AS LATEST_REPORT
FROM ICSR_CASES
GROUP BY SUSPECT_DRUG_NAME;

-- View: Cases by System Organ Class (for Section 7-14: Clinical Data)
CREATE OR REPLACE VIEW V_PSUR_CASES_BY_SOC AS
SELECT 
    SUSPECT_DRUG_NAME AS PRODUCT,
    MEDDRA_SOC,
    MEDDRA_PT,
    COUNT(*) AS CASE_COUNT,
    SUM(CASE WHEN SERIOUSNESS = 'SERIOUS' THEN 1 ELSE 0 END) AS SERIOUS_COUNT,
    SUM(CASE WHEN SERIOUSNESS = 'NON-SERIOUS' THEN 1 ELSE 0 END) AS NON_SERIOUS_COUNT,
    SUM(CASE WHEN EVENT_OUTCOME = 'RECOVERED' THEN 1 ELSE 0 END) AS RECOVERED,
    SUM(CASE WHEN EVENT_OUTCOME = 'RECOVERING' THEN 1 ELSE 0 END) AS RECOVERING,
    SUM(CASE WHEN EVENT_OUTCOME = 'NOT RECOVERED' THEN 1 ELSE 0 END) AS NOT_RECOVERED
FROM ICSR_CASES
GROUP BY SUSPECT_DRUG_NAME, MEDDRA_SOC, MEDDRA_PT;

-- View: Monthly Trend Analysis (for Section 15-16: Signal Evaluation)
CREATE OR REPLACE VIEW V_PSUR_MONTHLY_TREND AS
SELECT 
    SUSPECT_DRUG_NAME AS PRODUCT,
    DATE_TRUNC('MONTH', REPORT_DATE) AS REPORT_MONTH,
    COUNT(*) AS CASE_COUNT,
    SUM(CASE WHEN SERIOUSNESS = 'SERIOUS' THEN 1 ELSE 0 END) AS SERIOUS_COUNT
FROM ICSR_CASES
GROUP BY SUSPECT_DRUG_NAME, DATE_TRUNC('MONTH', REPORT_DATE)
ORDER BY PRODUCT, REPORT_MONTH;

-- View: Causality Assessment Distribution (for Section 16: Risk Evaluation)
CREATE OR REPLACE VIEW V_PSUR_CAUSALITY AS
SELECT 
    SUSPECT_DRUG_NAME AS PRODUCT,
    CAUSALITY_ASSESSMENT,
    COUNT(*) AS CASE_COUNT,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY SUSPECT_DRUG_NAME), 1) AS PERCENTAGE
FROM ICSR_CASES
GROUP BY SUSPECT_DRUG_NAME, CAUSALITY_ASSESSMENT;

-- ============================================================================
-- Step 4: Create Stage for Streamlit App
-- ============================================================================

CREATE STAGE IF NOT EXISTS HCLS_DEMO.STREAMLIT_APPS.PBRER_WRITER_STAGE
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage for PBRER Medical Writing Assistant Streamlit app';

-- ============================================================================
-- Setup Complete!
-- Next steps:
-- 1. Run 02_sample_data.sql to load sample data
-- 2. Run 03_deploy_app.sql to deploy the Streamlit app
-- ============================================================================
