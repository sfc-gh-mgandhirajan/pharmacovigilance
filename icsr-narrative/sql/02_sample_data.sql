-- ============================================================================
-- ICSR Narrative Generator - Sample Data
-- Synthetic ICSR cases for narrative generation demonstration
-- ============================================================================

USE DATABASE HCLS_DEMO;
USE SCHEMA PHARMACOVIGILANCE;

-- ============================================================================
-- Sample ICSR Cases - Various therapeutic areas
-- ============================================================================

INSERT INTO ICSR_CASES_NARRATIVE (CASE_ID, REPORT_DATE, REPORT_SOURCE, REPORTER_TYPE, REPORTER_COUNTRY, PATIENT_AGE, PATIENT_AGE_UNIT, PATIENT_SEX, PATIENT_WEIGHT_KG, MEDICAL_HISTORY, SUSPECT_DRUG_NAME, DRUG_INDICATION, DOSE, ROUTE_OF_ADMIN, THERAPY_START_DATE, THERAPY_END_DATE, ACTION_TAKEN, EVENT_TERM, MEDDRA_PT, MEDDRA_SOC, EVENT_ONSET_DATE, EVENT_OUTCOME, EVENT_DESCRIPTION, SERIOUSNESS, SERIOUSNESS_CRITERIA, CAUSALITY_ASSESSMENT)
VALUES

-- Case 1: Cardiovascular - Serious
('ICSR-2024-001', '2024-07-15', 'SPONTANEOUS', 'PHYSICIAN', 'US', 67, 'YEARS', 'Male', 85.5, 
'History of hypertension (10 years, controlled), hyperlipidemia, former smoker (quit 5 years ago). No known drug allergies.',
'CARDIOMAX 100mg', 'Atrial fibrillation', '100mg once daily', 'Oral', '2024-05-01', '2024-07-10',
'WITHDRAWN', 'Severe bradycardia with syncope', 'Bradycardia', 'Cardiac disorders',
'2024-07-08', 'RECOVERED',
'Patient presented to ER with heart rate of 35 bpm and syncopal episode while gardening. ECG confirmed sinus bradycardia. Patient was admitted for 48-hour monitoring. Heart rate normalized within 24 hours after drug discontinuation.',
'SERIOUS', 'Hospitalization', 'PROBABLE'),

-- Case 2: CNS - Serious  
('ICSR-2024-002', '2024-08-02', 'SPONTANEOUS', 'PHYSICIAN', 'UK', 23, 'YEARS', 'Female', 58.0,
'First episode major depressive disorder. No psychiatric history. No known drug allergies.',
'NEUROBALANCE 50mg', 'Major depressive disorder', '50mg once daily', 'Oral', '2024-06-15', '2024-07-28',
'WITHDRAWN', 'Suicidal ideation', 'Suicidal ideation', 'Psychiatric disorders',
'2024-07-25', 'RECOVERED',
'Patient reported new onset suicidal thoughts 6 weeks after starting therapy. No prior history of suicidal ideation. Patient was hospitalized for psychiatric evaluation. Drug was discontinued and patient was started on alternative therapy with close monitoring.',
'SERIOUS', 'Life-threatening', 'POSSIBLE'),

-- Case 3: Dermatological - Non-serious
('ICSR-2024-003', '2024-08-15', 'SPONTANEOUS', 'PHARMACIST', 'DE', 45, 'YEARS', 'Female', 72.0,
'Chronic eczema (15 years). Previous use of topical corticosteroids without issues. Allergic to penicillin.',
'DERMACLEAR 0.1% Cream', 'Eczema', 'Apply twice daily', 'Topical', '2024-07-01', '2024-08-10',
'WITHDRAWN', 'Contact dermatitis at application site', 'Dermatitis contact', 'Skin and subcutaneous tissue disorders',
'2024-08-05', 'RECOVERING',
'Patient developed erythema, vesicles, and intense pruritus at application sites after 5 weeks of use. Symptoms extended beyond original treatment areas. Dermatologist diagnosed delayed hypersensitivity reaction.',
'NON_SERIOUS', NULL, 'PROBABLE'),

-- Case 4: Cardiovascular - Non-serious
('ICSR-2024-004', '2024-08-20', 'CLINICAL_TRIAL', 'PHYSICIAN', 'FR', 55, 'YEARS', 'Male', 78.0,
'Hypertension (8 years), Type 2 diabetes (5 years, well-controlled on metformin). No known drug allergies.',
'CARDIOMAX 100mg', 'Atrial fibrillation', '100mg once daily', 'Oral', '2024-06-01', NULL,
'DOSE_REDUCED', 'Dizziness', 'Dizziness', 'Nervous system disorders',
'2024-08-15', 'RECOVERED',
'Phase IV study participant reported intermittent dizziness during first month of therapy. Symptoms were mild and did not interfere with daily activities. Dose was reduced to 50mg with resolution of symptoms.',
'NON_SERIOUS', NULL, 'PROBABLE'),

-- Case 5: GI - Serious
('ICSR-2024-005', '2024-09-01', 'SPONTANEOUS', 'PHYSICIAN', 'JP', 62, 'YEARS', 'Female', 55.0,
'Rheumatoid arthritis (12 years), osteoporosis. Previous GI bleed with NSAIDs 3 years ago. On PPI prophylaxis.',
'INFLAMMEX 400mg', 'Rheumatoid arthritis', '400mg twice daily', 'Oral', '2024-07-15', '2024-08-28',
'WITHDRAWN', 'Upper gastrointestinal hemorrhage', 'Gastrointestinal haemorrhage', 'Gastrointestinal disorders',
'2024-08-25', 'RECOVERED',
'Patient presented with hematemesis and melena. Endoscopy revealed multiple gastric ulcers with active bleeding. Required blood transfusion (2 units). History of previous GI bleed with NSAIDs noted.',
'SERIOUS', 'Hospitalization', 'PROBABLE'),

-- Case 6: Respiratory - Serious
('ICSR-2024-006', '2024-09-10', 'SPONTANEOUS', 'PHYSICIAN', 'AU', 48, 'YEARS', 'Male', 92.0,
'Moderate persistent asthma (20 years). Previous hospitalizations for asthma exacerbations. Allergic to aspirin.',
'BREATHEASY Inhaler', 'Asthma', '2 puffs twice daily', 'Inhalation', '2024-08-01', '2024-09-05',
'WITHDRAWN', 'Paradoxical bronchospasm', 'Bronchospasm paradoxical', 'Respiratory, thoracic and mediastinal disorders',
'2024-09-03', 'RECOVERED',
'Patient experienced acute worsening of dyspnea immediately after using inhaler. Required emergency department visit with nebulized bronchodilators. Spirometry showed 30% decrease in FEV1. Symptoms resolved within 2 hours of treatment.',
'SERIOUS', 'Medically significant', 'CERTAIN'),

-- Case 7: Hepatic - Serious
('ICSR-2024-007', '2024-09-18', 'SPONTANEOUS', 'PHYSICIAN', 'CA', 58, 'YEARS', 'Female', 68.0,
'Type 2 diabetes (10 years), obesity. No history of liver disease. Social alcohol use (1-2 drinks/week).',
'GLUCONORM 500mg', 'Type 2 diabetes mellitus', '500mg twice daily', 'Oral', '2024-06-01', '2024-09-10',
'WITHDRAWN', 'Drug-induced liver injury', 'Hepatocellular injury', 'Hepatobiliary disorders',
'2024-09-05', 'RECOVERING',
'Routine labs revealed ALT 450 U/L (10x ULN), AST 380 U/L (8x ULN), total bilirubin 3.2 mg/dL. Patient was asymptomatic. Viral hepatitis panel negative. Drug discontinued with gradual improvement in liver enzymes over 2 weeks.',
'SERIOUS', 'Medically significant', 'PROBABLE'),

-- Case 8: Musculoskeletal - Non-serious
('ICSR-2024-008', '2024-09-25', 'LITERATURE', 'OTHER_HCP', 'US', 72, 'YEARS', 'Male', 80.0,
'Hyperlipidemia (15 years), coronary artery disease with previous stent. On aspirin and clopidogrel.',
'LIPIDCLEAR 40mg', 'Hyperlipidemia', '40mg once daily at bedtime', 'Oral', '2024-03-01', NULL,
'DOSE_NOT_CHANGED', 'Myalgia', 'Myalgia', 'Musculoskeletal and connective tissue disorders',
'2024-08-15', 'NOT_RECOVERED',
'Published case report describing muscle pain in proximal muscle groups without CPK elevation. Pain rated 4/10, does not interfere with daily activities. Patient elected to continue therapy due to cardiovascular benefit.',
'NON_SERIOUS', NULL, 'POSSIBLE'),

-- Case 9: Renal - Serious
('ICSR-2024-009', '2024-10-01', 'SPONTANEOUS', 'PHYSICIAN', 'US', 65, 'YEARS', 'Female', 70.0,
'Hypertension (20 years), Type 2 diabetes with mild nephropathy (eGFR 55). ACE inhibitor use for 10 years.',
'PRESSUREDOWN 10mg', 'Hypertension', '10mg once daily', 'Oral', '2024-08-01', '2024-09-25',
'WITHDRAWN', 'Acute kidney injury', 'Acute kidney injury', 'Renal and urinary disorders',
'2024-09-20', 'RECOVERED',
'Patient developed acute kidney injury with creatinine rising from 1.4 to 3.8 mg/dL over 5 days. Presented with decreased urine output and peripheral edema. No nephrotoxic agents identified. Renal function recovered after drug discontinuation and IV fluids.',
'SERIOUS', 'Hospitalization', 'PROBABLE'),

-- Case 10: Neurological - Non-serious
('ICSR-2024-010', '2024-10-08', 'SPONTANEOUS', 'CONSUMER', 'UK', 35, 'YEARS', 'Female', 62.0,
'Migraine with aura (10 years, 4-5 episodes monthly). No other significant medical history.',
'MIGRANIL 100mg', 'Migraine prophylaxis', '100mg once daily', 'Oral', '2024-09-01', NULL,
'DOSE_NOT_CHANGED', 'Paraesthesia', 'Paraesthesia', 'Nervous system disorders',
'2024-09-15', 'NOT_RECOVERED',
'Patient reports tingling sensation in fingers and toes, described as mild and intermittent. Started approximately 2 weeks after initiating therapy. Does not interfere with daily activities. Patient wishes to continue due to significant reduction in migraine frequency.',
'NON_SERIOUS', NULL, 'PROBABLE');

-- ============================================================================
-- Verify Data Load
-- ============================================================================

SELECT 'ICSR_CASES_NARRATIVE' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM ICSR_CASES_NARRATIVE;

-- Show case summary
SELECT CASE_ID, SUSPECT_DRUG_NAME, EVENT_TERM, SERIOUSNESS, CAUSALITY_ASSESSMENT
FROM ICSR_CASES_NARRATIVE
ORDER BY SERIOUSNESS DESC, REPORT_DATE DESC;

-- Show statistics
SELECT * FROM V_ICSR_NARRATIVE_STATS;
