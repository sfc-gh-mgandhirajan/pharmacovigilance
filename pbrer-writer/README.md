# PBRER Medical Writing Assistant

AI-powered ICH E2C(R2) compliant Periodic Benefit-Risk Evaluation Report generator using Snowflake Cortex.

## Overview

This package provides a complete solution for generating PBRER sections using AI, including:
- All 19 ICH E2C(R2) PBRER sections
- Database schema for pharmacovigilance data
- Sample synthetic ICSR data
- Streamlit in Snowflake application

## Installation

### Prerequisites
- Snowflake account with Cortex LLM access
- ACCOUNTADMIN or appropriate privileges
- A warehouse for running queries

### Step 1: Create Database Objects

Run the setup script to create tables and views:

```sql
-- Execute in Snowflake
@sql/01_setup_tables.sql
```

This creates:
- `PRODUCT_REGISTRY` - Products for PBRER reporting
- `ICSR_CASES` - Individual Case Safety Reports
- `V_PSUR_PRODUCT_SUMMARY` - Product statistics view
- `V_PSUR_CASES_BY_SOC` - Cases by System Organ Class
- `V_PSUR_MONTHLY_TREND` - Monthly trend analysis
- `V_PSUR_CAUSALITY` - Causality distribution

### Step 2: Load Sample Data

```sql
@sql/02_sample_data.sql
```

Includes synthetic data for 3 products:
- CARDIOMAX 100mg (Cardiovascular)
- NEUROBALANCE 50mg (CNS)
- DERMACLEAR 0.1% (Dermatological)

### Step 3: Deploy Streamlit App

Upload app files to stage:
```sql
PUT file:///path/to/pbrer_app.py @HCLS_DEMO.STREAMLIT_APPS.PBRER_WRITER_STAGE OVERWRITE=TRUE AUTO_COMPRESS=FALSE;
PUT file:///path/to/environment.yml @HCLS_DEMO.STREAMLIT_APPS.PBRER_WRITER_STAGE OVERWRITE=TRUE AUTO_COMPRESS=FALSE;
```

Create the Streamlit app:
```sql
@sql/03_deploy_app.sql
```

## PBRER Sections Covered

| Section | Title | Description |
|---------|-------|-------------|
| 1 | Introduction | Background, scope, reporting period |
| 2 | Worldwide Marketing Authorization Status | Approval status by country |
| 3 | Actions Taken for Safety Reasons | Regulatory actions during interval |
| 4 | Changes to Reference Safety Information | CCDS updates |
| 5 | Estimated Exposure and Use Patterns | Patient exposure data |
| 6 | Data in Summary Tabulations | Clinical trial summaries |
| 7 | Summaries of Significant Findings | New trial findings |
| 8 | Findings from Non-Interventional Studies | Observational data |
| 9 | Information from Other Sources | Compassionate use, literature |
| 10 | Non-Clinical Data | Preclinical findings |
| 11 | Literature | Published safety information |
| 12 | Other Periodic Reports | Cross-references |
| 13 | Lack of Efficacy | Efficacy failures |
| 14 | Late-Breaking Information | Post-DLP data |
| 15 | Overview of Signals | Signal evaluation |
| 16 | Signal and Risk Evaluation | Risk analysis |
| 17 | Benefit Evaluation | Efficacy summary |
| 18 | Integrated Benefit-Risk Analysis | B-R balance |
| 19 | Conclusions and Actions | Recommendations |

## File Structure

```
pbrer-writer/
├── README.md                 # This file
├── pbrer_app.py             # Streamlit application
├── environment.yml          # Snowflake dependencies
└── sql/
    ├── 01_setup_tables.sql  # Database schema
    ├── 02_sample_data.sql   # Sample ICSR data
    └── 03_deploy_app.sql    # App deployment
```

## Technology Stack

- **Snowflake Cortex**: Llama 3.1 70B for content generation
- **Streamlit in Snowflake**: Native app deployment
- **MedDRA**: Medical terminology (SOC, PT)

## Customization

### Using Your Own Data

1. Modify `01_setup_tables.sql` to match your schema
2. Load your ICSR data into `ICSR_CASES` table
3. Update product information in `PRODUCT_REGISTRY`
4. Views will automatically aggregate your data

### Changing the LLM Model

Edit `pbrer_app.py` and change the model in the `generate_pbrer_section` function:
```python
# Change from llama3.1-70b to another supported model
result = session.sql(f"""
    SELECT SNOWFLAKE.CORTEX.COMPLETE('mistral-large', ...)
""")
```

## License

MIT
