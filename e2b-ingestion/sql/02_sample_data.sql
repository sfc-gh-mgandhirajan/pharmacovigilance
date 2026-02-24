-- ============================================================================
-- E2B(R2) ICSR Ingestion - Sample Data
-- Sample E2B data for testing (matches sample_e2b_r2.xml)
-- ============================================================================

USE DATABASE HCLS_DEMO;
USE SCHEMA PHARMACOVIGILANCE;

-- ============================================================================
-- Sample Case 1: Cardiovascular - Bradycardia
-- ============================================================================

INSERT INTO E2B_ICSR_CASES (CASE_ID, SAFETY_REPORT_VERSION, TRANSMISSION_DATE, REPORT_TYPE, SERIOUS, SERIOUSNESS_DEATH, SERIOUSNESS_LIFE_THREATENING, SERIOUSNESS_HOSPITALIZATION, SERIOUSNESS_DISABILITY, SERIOUSNESS_CONGENITAL, SERIOUSNESS_OTHER, RECEIVE_DATE, RECEIPT_DATE, SENDER_ORGANIZATION, RECEIVER_ORGANIZATION, CASE_NARRATIVE, REPORTER_COUNTRY, QUALIFICATION, PATIENT_AGE, PATIENT_SEX, PATIENT_WEIGHT, PATIENT_MEDICAL_HISTORY)
VALUES 
('US-PHARMA-2024-00001', '1', '20240215', 'Spontaneous', '1', '2', '2', '1', '2', '2', '2', '20240210', '20240212', 'Demo Pharmaceuticals Inc.', 'FDA', 
'A 65-year-old male patient with a history of hypertension, type 2 diabetes mellitus, and hyperlipidemia was started on CARDIOMAX 100mg once daily for newly diagnosed atrial fibrillation on 15-Nov-2023. On 01-Feb-2024, the patient began experiencing episodes of dizziness. On 03-Feb-2024, the patient developed severe bradycardia with heart rate dropping to 38 bpm. On 05-Feb-2024, the patient experienced a syncopal episode and was admitted to City General Hospital. Upon admission, ECG showed sinus bradycardia at 35 bpm. CARDIOMAX was immediately discontinued. The patient was monitored in the cardiac care unit. Heart rate gradually improved over the following 48 hours without intervention. The patient was discharged on 07-Feb-2024 in stable condition with heart rate normalized to 72 bpm. All symptoms had resolved by the time of discharge. The treating physician assessed the bradycardia and syncope as probably related to CARDIOMAX therapy. The patient was advised to avoid beta-blockers in the future and was started on an alternative antiarrhythmic medication.',
'US', '1', '65', 'Male', '82', 'Hypertension diagnosed 2015, well-controlled on lisinopril; Type 2 Diabetes Mellitus diagnosed 2018; Hyperlipidemia');

INSERT INTO E2B_ICSR_DRUGS (CASE_ID, DRUG_SEQ, DRUG_CHARACTERIZATION, MEDICINAL_PRODUCT, GENERIC_NAME, BATCH_NUMBER, AUTHORIZATION_HOLDER, DOSAGE_TEXT, DOSAGE_FORM, ROUTE_OF_ADMIN, INDICATION, START_DATE, END_DATE, ACTION_TAKEN)
VALUES 
('US-PHARMA-2024-00001', 1, 'Suspect', 'CARDIOMAX 100mg tablets', 'cardimaxolol', 'BN2024-A123', 'Demo Pharmaceuticals Inc.', '100mg once daily', 'tablet', '048', 'Atrial fibrillation', '20231115', '20240205', '1'),
('US-PHARMA-2024-00001', 2, 'Concomitant', 'Lisinopril 10mg', 'lisinopril', NULL, NULL, '10mg once daily', 'tablet', '048', 'Hypertension', '2015', NULL, '4'),
('US-PHARMA-2024-00001', 3, 'Concomitant', 'Metformin 500mg', 'metformin hydrochloride', NULL, NULL, '500mg twice daily', 'tablet', '048', 'Type 2 Diabetes Mellitus', '2018', NULL, '4');

INSERT INTO E2B_ICSR_REACTIONS (CASE_ID, REACTION_SEQ, MEDDRA_PT, MEDDRA_PT_CODE, START_DATE, END_DATE, OUTCOME)
VALUES 
('US-PHARMA-2024-00001', 1, 'Bradycardia', '26.1', '20240203', '20240207', 'Recovered/Resolved'),
('US-PHARMA-2024-00001', 2, 'Syncope', '26.1', '20240205', '20240205', 'Recovered/Resolved'),
('US-PHARMA-2024-00001', 3, 'Dizziness', '26.1', '20240201', NULL, 'Recovered/Resolved');

-- ============================================================================
-- Sample Case 2: Dermatological - Contact Dermatitis
-- ============================================================================

INSERT INTO E2B_ICSR_CASES (CASE_ID, SAFETY_REPORT_VERSION, TRANSMISSION_DATE, REPORT_TYPE, SERIOUS, SERIOUSNESS_DEATH, SERIOUSNESS_LIFE_THREATENING, SERIOUSNESS_HOSPITALIZATION, SERIOUSNESS_DISABILITY, SERIOUSNESS_CONGENITAL, SERIOUSNESS_OTHER, RECEIVE_DATE, RECEIPT_DATE, SENDER_ORGANIZATION, RECEIVER_ORGANIZATION, CASE_NARRATIVE, REPORTER_COUNTRY, QUALIFICATION, PATIENT_AGE, PATIENT_SEX, PATIENT_WEIGHT, PATIENT_MEDICAL_HISTORY)
VALUES 
('US-PHARMA-2024-00002', '1', '20240218', 'Spontaneous', '1', '2', '2', '2', '2', '2', '1', '20240215', '20240216', 'Demo Pharmaceuticals Inc.', 'FDA', 
'A 42-year-old female patient started using DERMACLEAR Cream 0.1% on 01-Jan-2024 for treatment of chronic eczema on her forearms. After approximately 5 weeks of use, on 05-Feb-2024, the patient noticed a burning sensation at the application sites. By 08-Feb-2024, she developed a severe rash characterized by erythema, vesicles, and intense pruritus extending beyond the original application areas. The patient discontinued DERMACLEAR on 10-Feb-2024 and consulted her dermatologist. She was prescribed topical hydrocortisone and oral antihistamines. At the time of this report (15-Feb-2024), the symptoms were gradually improving but not fully resolved. The dermatologist suspected a delayed hypersensitivity reaction to one of the cream components.',
'US', '5', '42', 'Female', '68', NULL);

INSERT INTO E2B_ICSR_DRUGS (CASE_ID, DRUG_SEQ, DRUG_CHARACTERIZATION, MEDICINAL_PRODUCT, GENERIC_NAME, BATCH_NUMBER, AUTHORIZATION_HOLDER, DOSAGE_TEXT, DOSAGE_FORM, ROUTE_OF_ADMIN, INDICATION, START_DATE, END_DATE, ACTION_TAKEN)
VALUES 
('US-PHARMA-2024-00002', 1, 'Suspect', 'DERMACLEAR Cream 0.1%', 'dermazolone', 'DC-2024-B456', 'Demo Pharmaceuticals Inc.', 'Apply thin layer twice daily', 'cream', '028', 'Eczema', '20240101', '20240210', '1');

INSERT INTO E2B_ICSR_REACTIONS (CASE_ID, REACTION_SEQ, MEDDRA_PT, START_DATE, OUTCOME)
VALUES 
('US-PHARMA-2024-00002', 1, 'Dermatitis contact', '20240208', 'Recovering/Resolving'),
('US-PHARMA-2024-00002', 2, 'Skin burning sensation', '20240205', 'Recovering/Resolving');

-- ============================================================================
-- Verify Data Load
-- ============================================================================

SELECT 'E2B_ICSR_CASES' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM E2B_ICSR_CASES
UNION ALL
SELECT 'E2B_ICSR_DRUGS', COUNT(*) FROM E2B_ICSR_DRUGS
UNION ALL
SELECT 'E2B_ICSR_REACTIONS', COUNT(*) FROM E2B_ICSR_REACTIONS;

-- Show case summary
SELECT * FROM V_E2B_CASE_SUMMARY;
