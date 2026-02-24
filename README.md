# Pharmacovigilance AI Demos

AI-powered pharmacovigilance tools using Snowflake Cortex for medical writing and safety narrative generation.

## Applications

### 1. PBRER Medical Writing Assistant (`pbrer_app.py`)
ICH E2C(R2) compliant Periodic Benefit-Risk Evaluation Report generator with all 19 sections:
- Sections 1-4: Introduction & Authorization
- Section 5-6: Exposure & Use Patterns
- Sections 7-14: Clinical Data & Findings
- Sections 15-16: Signal Evaluation
- Sections 17-19: Benefit-Risk Analysis & Conclusions

### 2. ICSR Narrative Generator (`streamlit_app.py`)
Generates individual case safety report narratives from structured ICSR data.

### 3. E2B(R2) ICSR Ingestion (`e2b-ingestion/`)
ICH E2B(R2) compliant XML parser and Snowflake loader for Individual Case Safety Reports:
- Parses E2B(R2) XML files (FDA FAERS / EMA EudraVigilance compatible)
- Extracts safety report metadata, patient demographics, drugs, and reactions
- Loads into normalized Snowflake tables (E2B_ICSR_CASES, E2B_ICSR_DRUGS, E2B_ICSR_REACTIONS)
- Includes sample E2B XML for testing

## Technology Stack
- **Snowflake Cortex**: LLM inference (Llama 3.1 70B)
- **Streamlit in Snowflake**: UI deployment
- **MedDRA**: Medical terminology (SOC, PT)

## Deployment
Deploy as Streamlit in Snowflake apps:

```sql
-- PBRER Medical Writing Assistant
CREATE STREAMLIT HCLS_DEMO.STREAMLIT_APPS.PSUR_MEDICAL_WRITER
    ROOT_LOCATION = '@HCLS_DEMO.STREAMLIT_APPS.PSUR_WRITER_STAGE'
    MAIN_FILE = 'pbrer_app.py'
    QUERY_WAREHOUSE = 'BI_WH';

-- ICSR Narrative Generator
CREATE STREAMLIT HCLS_DEMO.STREAMLIT_APPS.SAFETY_NARRATIVE_GENERATOR
    ROOT_LOCATION = '@HCLS_DEMO.STREAMLIT_APPS.SAFETY_NARRATIVE_STAGE'
    MAIN_FILE = 'streamlit_app.py'
    QUERY_WAREHOUSE = 'BI_WH';

-- E2B(R2) ICSR Ingestion
CREATE STREAMLIT HCLS_DEMO.STREAMLIT_APPS.E2B_ICSR_INGESTION
    ROOT_LOCATION = '@HCLS_DEMO.STREAMLIT_APPS.E2B_INGESTION_STAGE'
    MAIN_FILE = 'e2b_ingestion_app.py'
    QUERY_WAREHOUSE = 'BI_WH';
```

## License
MIT
