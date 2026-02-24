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
```

## License
MIT
