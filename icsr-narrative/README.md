# ICSR Narrative Generator

AI-powered Individual Case Safety Report (ICSR) narrative generation using Snowflake Cortex.

## Overview

This module automatically generates professional case narratives from structured ICSR data, suitable for regulatory submissions (FDA, EMA).

## Features

- **AI-Powered Narratives**: Uses Snowflake Cortex (Llama 3.1 70B) to generate medically appropriate narratives
- **ICH E2B(R3) Compliant**: Follows regulatory guidelines for case narrative structure
- **Save & Track**: Stores generated narratives with timestamps
- **Export**: Download narratives as text files
- **Dashboard**: View case statistics and pending narratives

## Installation

### Step 1: Create Database Objects

```sql
@sql/01_setup_tables.sql
```

Creates:
- `ICSR_CASES_NARRATIVE` - Extended ICSR table with narrative fields
- `V_ICSR_PENDING_NARRATIVE` - View of cases needing narratives
- `V_ICSR_NARRATIVE_STATS` - Generation statistics

### Step 2: Load Sample Data

```sql
@sql/02_sample_data.sql
```

Includes 10 sample cases across therapeutic areas:
- Cardiovascular (CARDIOMAX)
- CNS (NEUROBALANCE)
- Dermatological (DERMACLEAR)
- GI (INFLAMMEX)
- Respiratory (BREATHEASY)
- Hepatic (GLUCONORM)
- Musculoskeletal (LIPIDCLEAR)
- Renal (PRESSUREDOWN)
- Neurological (MIGRANIL)

### Step 3: Deploy Streamlit App

```sql
-- Upload files
PUT file:///path/to/icsr_narrative_app.py @HCLS_DEMO.STREAMLIT_APPS.ICSR_NARRATIVE_STAGE OVERWRITE=TRUE AUTO_COMPRESS=FALSE;
PUT file:///path/to/environment.yml @HCLS_DEMO.STREAMLIT_APPS.ICSR_NARRATIVE_STAGE OVERWRITE=TRUE AUTO_COMPRESS=FALSE;

-- Deploy
@sql/03_deploy_app.sql
```

## Narrative Structure

Generated narratives follow this structure:

1. **Patient Demographics** - Age, sex, weight, relevant medical history
2. **Drug Therapy** - Drug name, indication, dose, route, duration
3. **Adverse Event** - Onset, symptoms, clinical findings, management
4. **Outcome** - Resolution, sequelae, dechallenge/rechallenge
5. **Causality** - Assessment rationale

## File Structure

```
icsr-narrative/
├── README.md
├── icsr_narrative_app.py   # Streamlit app
├── environment.yml         # Snowflake dependencies
└── sql/
    ├── 01_setup_tables.sql # Database schema
    ├── 02_sample_data.sql  # 10 sample ICSR cases
    └── 03_deploy_app.sql   # App deployment
```

## Data Fields

| Field | Description |
|-------|-------------|
| CASE_ID | Unique case identifier |
| REPORT_SOURCE | Spontaneous, Clinical Trial, Literature |
| REPORTER_TYPE | Physician, Pharmacist, Consumer, Other HCP |
| PATIENT_* | Demographics (age, sex, weight) |
| MEDICAL_HISTORY | Relevant patient history |
| SUSPECT_DRUG_* | Drug details (name, dose, route) |
| EVENT_* | Adverse event details (term, MedDRA, outcome) |
| CAUSALITY_ASSESSMENT | Certain, Probable, Possible, Unlikely |
| GENERATED_NARRATIVE | AI-generated text |

## License

MIT
