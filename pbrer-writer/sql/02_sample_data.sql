-- ============================================================================
-- PBRER Medical Writing Assistant - Sample Data
-- Synthetic pharmacovigilance data for demonstration purposes
-- ============================================================================

USE DATABASE HCLS_DEMO;
USE SCHEMA PHARMACOVIGILANCE;

-- ============================================================================
-- Product Registry Data
-- ============================================================================

INSERT INTO PRODUCT_REGISTRY (PRODUCT_ID, PRODUCT_NAME, ACTIVE_INGREDIENT, THERAPEUTIC_CLASS, MARKETING_AUTHORIZATION_DATE, AUTHORIZATION_HOLDER, LAST_PSUR_DATE, NEXT_PSUR_DUE, REFERENCE_SAFETY_INFO)
VALUES 
('PROD-001', 'CARDIOMAX 100mg', 'Cardimaxolol', 'Cardiovascular - Antiarrhythmic', '2020-03-15', 'Demo Pharmaceuticals Inc.', '2024-06-30', '2025-06-30', 'Known risks: Bradycardia, Hypotension, Dizziness. Contraindicated in severe bradycardia and heart block.'),
('PROD-002', 'NEUROBALANCE 50mg', 'Neurobalazine', 'Central Nervous System - Antidepressant', '2019-09-01', 'Demo Pharmaceuticals Inc.', '2024-06-30', '2025-06-30', 'Known risks: Somnolence, Weight gain, Sexual dysfunction. Monitor for suicidal ideation in young adults.'),
('PROD-003', 'DERMACLEAR 0.1%', 'Dermazolone', 'Dermatological - Topical Corticosteroid', '2021-01-20', 'Demo Pharmaceuticals Inc.', '2024-06-30', '2025-06-30', 'Known risks: Skin atrophy, Contact dermatitis. Avoid prolonged use on face.');

-- ============================================================================
-- ICSR Cases - CARDIOMAX (Cardiovascular)
-- ============================================================================

INSERT INTO ICSR_CASES (CASE_ID, SUSPECT_DRUG_NAME, SUSPECT_DRUG_ID, PATIENT_AGE, PATIENT_SEX, PATIENT_WEIGHT, REPORTER_COUNTRY, REPORT_SOURCE, REPORT_DATE, RECEIPT_DATE, MEDDRA_SOC, MEDDRA_PT, SERIOUSNESS, SERIOUSNESS_CRITERIA, EVENT_OUTCOME, EVENT_DESCRIPTION, CAUSALITY_ASSESSMENT, ACTION_TAKEN, CONCOMITANT_MEDICATIONS, MEDICAL_HISTORY, NARRATIVE)
VALUES
('US-2024-CM-001', 'CARDIOMAX 100mg', 'PROD-001', 65, 'Male', 82.5, 'US', 'SPONTANEOUS', '2024-07-15', '2024-07-18', 'Cardiac disorders', 'Bradycardia', 'SERIOUS', 'Hospitalization', 'RECOVERED', 'Severe bradycardia requiring hospitalization', 'PROBABLE', 'Drug withdrawn', 'Lisinopril, Metformin', 'Hypertension, Type 2 DM', 'A 65-year-old male developed severe bradycardia (HR 38 bpm) after 8 weeks on CARDIOMAX. Hospitalized for 3 days. Recovered after drug discontinuation.'),

('US-2024-CM-002', 'CARDIOMAX 100mg', 'PROD-001', 58, 'Female', 68.0, 'US', 'SPONTANEOUS', '2024-08-02', '2024-08-05', 'Cardiac disorders', 'Syncope', 'SERIOUS', 'Medically significant', 'RECOVERED', 'Syncopal episode while standing', 'PROBABLE', 'Drug withdrawn', 'Aspirin', 'Atrial fibrillation', 'A 58-year-old female experienced syncope 6 weeks after starting CARDIOMAX. ECG showed sinus bradycardia. Drug discontinued with full recovery.'),

('DE-2024-CM-003', 'CARDIOMAX 100mg', 'PROD-001', 72, 'Male', 78.0, 'DE', 'CLINICAL TRIAL', '2024-08-20', '2024-08-22', 'Nervous system disorders', 'Dizziness', 'NON-SERIOUS', NULL, 'RECOVERED', 'Mild dizziness reported during titration', 'POSSIBLE', 'Dose reduced', 'Warfarin, Digoxin', 'AF, CHF', 'A 72-year-old male in Phase IV study reported mild dizziness during dose titration. Resolved with dose reduction.'),

('UK-2024-CM-004', 'CARDIOMAX 100mg', 'PROD-001', 55, 'Female', 65.5, 'UK', 'SPONTANEOUS', '2024-09-10', '2024-09-12', 'Vascular disorders', 'Hypotension', 'NON-SERIOUS', NULL, 'RECOVERED', 'Orthostatic hypotension on standing', 'PROBABLE', 'Dose reduced', 'Amlodipine', 'Hypertension', 'A 55-year-old female developed orthostatic hypotension. Blood pressure normalized after dose reduction.'),

('FR-2024-CM-005', 'CARDIOMAX 100mg', 'PROD-001', 68, 'Male', 90.0, 'FR', 'LITERATURE', '2024-10-01', '2024-10-05', 'Cardiac disorders', 'Atrioventricular block', 'SERIOUS', 'Hospitalization', 'RECOVERED', 'Second-degree AV block reported in literature', 'POSSIBLE', 'Drug withdrawn', 'Beta-blocker (prior)', 'Prior beta-blocker use', 'Literature case report of 68-year-old male who developed 2nd degree AV block. Had prior beta-blocker exposure.');

-- ============================================================================
-- ICSR Cases - NEUROBALANCE (CNS)
-- ============================================================================

INSERT INTO ICSR_CASES (CASE_ID, SUSPECT_DRUG_NAME, SUSPECT_DRUG_ID, PATIENT_AGE, PATIENT_SEX, PATIENT_WEIGHT, REPORTER_COUNTRY, REPORT_SOURCE, REPORT_DATE, RECEIPT_DATE, MEDDRA_SOC, MEDDRA_PT, SERIOUSNESS, SERIOUSNESS_CRITERIA, EVENT_OUTCOME, EVENT_DESCRIPTION, CAUSALITY_ASSESSMENT, ACTION_TAKEN, CONCOMITANT_MEDICATIONS, MEDICAL_HISTORY, NARRATIVE)
VALUES
('US-2024-NB-001', 'NEUROBALANCE 50mg', 'PROD-002', 34, 'Female', 62.0, 'US', 'SPONTANEOUS', '2024-07-22', '2024-07-25', 'Psychiatric disorders', 'Somnolence', 'NON-SERIOUS', NULL, 'RECOVERING', 'Excessive daytime sleepiness affecting work', 'PROBABLE', 'Dose reduced', 'Oral contraceptive', 'Major depressive disorder', 'A 34-year-old female reported significant daytime somnolence interfering with work. Symptoms improving with dose reduction.'),

('US-2024-NB-002', 'NEUROBALANCE 50mg', 'PROD-002', 28, 'Male', 75.0, 'US', 'SPONTANEOUS', '2024-08-15', '2024-08-18', 'Metabolism disorders', 'Weight increased', 'NON-SERIOUS', NULL, 'NOT RECOVERED', '8kg weight gain over 4 months', 'PROBABLE', 'Drug continued', NULL, 'Depression, Anxiety', 'A 28-year-old male gained 8kg over 4 months on NEUROBALANCE. Patient elected to continue due to good efficacy.'),

('CA-2024-NB-003', 'NEUROBALANCE 50mg', 'PROD-002', 45, 'Female', 70.0, 'CA', 'CLINICAL TRIAL', '2024-09-05', '2024-09-08', 'Nervous system disorders', 'Headache', 'NON-SERIOUS', NULL, 'RECOVERED', 'Tension-type headache during first week', 'UNLIKELY', 'Drug continued', 'Ibuprofen PRN', 'MDD', 'A 45-year-old female in Phase IV study reported mild headache in week 1. Resolved spontaneously.'),

('JP-2024-NB-004', 'NEUROBALANCE 50mg', 'PROD-002', 52, 'Male', 68.0, 'JP', 'SPONTANEOUS', '2024-09-28', '2024-10-02', 'Reproductive disorders', 'Sexual dysfunction', 'NON-SERIOUS', NULL, 'NOT RECOVERED', 'Decreased libido and erectile dysfunction', 'PROBABLE', 'Drug continued', 'Omeprazole', 'Depression', 'A 52-year-old male reported sexual dysfunction. Patient continues therapy due to psychiatric benefit.'),

('AU-2024-NB-005', 'NEUROBALANCE 50mg', 'PROD-002', 19, 'Female', 55.0, 'AU', 'SPONTANEOUS', '2024-10-12', '2024-10-15', 'Psychiatric disorders', 'Suicidal ideation', 'SERIOUS', 'Life-threatening', 'RECOVERED', 'New onset suicidal thoughts in young adult', 'POSSIBLE', 'Drug withdrawn', NULL, 'Depression first episode', 'A 19-year-old female developed suicidal ideation 3 weeks after starting NEUROBALANCE. Hospitalized, drug discontinued, recovered with alternative therapy.');

-- ============================================================================
-- ICSR Cases - DERMACLEAR (Dermatological)
-- ============================================================================

INSERT INTO ICSR_CASES (CASE_ID, SUSPECT_DRUG_NAME, SUSPECT_DRUG_ID, PATIENT_AGE, PATIENT_SEX, PATIENT_WEIGHT, REPORTER_COUNTRY, REPORT_SOURCE, REPORT_DATE, RECEIPT_DATE, MEDDRA_SOC, MEDDRA_PT, SERIOUSNESS, SERIOUSNESS_CRITERIA, EVENT_OUTCOME, EVENT_DESCRIPTION, CAUSALITY_ASSESSMENT, ACTION_TAKEN, CONCOMITANT_MEDICATIONS, MEDICAL_HISTORY, NARRATIVE)
VALUES
('US-2024-DC-001', 'DERMACLEAR 0.1%', 'PROD-003', 42, 'Female', 68.0, 'US', 'SPONTANEOUS', '2024-07-28', '2024-07-30', 'Skin disorders', 'Dermatitis contact', 'NON-SERIOUS', NULL, 'RECOVERING', 'Contact dermatitis at application site', 'PROBABLE', 'Drug withdrawn', NULL, 'Eczema', 'A 42-year-old female developed contact dermatitis after 5 weeks of DERMACLEAR use. Improving after discontinuation.'),

('UK-2024-DC-002', 'DERMACLEAR 0.1%', 'PROD-003', 35, 'Male', 80.0, 'UK', 'SPONTANEOUS', '2024-08-18', '2024-08-20', 'Skin disorders', 'Skin burning sensation', 'NON-SERIOUS', NULL, 'RECOVERED', 'Burning sensation on application', 'CERTAIN', 'Drug withdrawn', 'Emollient', 'Psoriasis', 'A 35-year-old male reported immediate burning sensation upon application. Resolved after switching to alternative.'),

('DE-2024-DC-003', 'DERMACLEAR 0.1%', 'PROD-003', 28, 'Female', 58.0, 'DE', 'CLINICAL TRIAL', '2024-09-15', '2024-09-18', 'Skin disorders', 'Skin atrophy', 'NON-SERIOUS', NULL, 'RECOVERING', 'Mild skin thinning at application sites', 'PROBABLE', 'Drug withdrawn', NULL, 'Atopic dermatitis', 'A 28-year-old female in Phase IV study developed skin thinning after 12 weeks of use. Improving after discontinuation.'),

('FR-2024-DC-004', 'DERMACLEAR 0.1%', 'PROD-003', 55, 'Male', 85.0, 'FR', 'LITERATURE', '2024-10-05', '2024-10-08', 'Skin disorders', 'Skin hypopigmentation', 'NON-SERIOUS', NULL, 'NOT RECOVERED', 'Localized hypopigmentation reported', 'POSSIBLE', 'Drug withdrawn', 'Tacrolimus', 'Vitiligo history', 'Literature case of 55-year-old male with hypopigmentation at application sites. History of vitiligo noted.');

-- ============================================================================
-- Verify Data Load
-- ============================================================================

SELECT 'PRODUCT_REGISTRY' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM PRODUCT_REGISTRY
UNION ALL
SELECT 'ICSR_CASES', COUNT(*) FROM ICSR_CASES;

-- Show product summary
SELECT * FROM V_PSUR_PRODUCT_SUMMARY;
