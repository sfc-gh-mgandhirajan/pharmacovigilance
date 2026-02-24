# Pharmacovigilance AI Tools for Snowflake

AI-powered pharmacovigilance tools using Snowflake Cortex for medical writing, safety reporting, and ICSR management.

## Quick Start

Each module is a self-contained package with SQL setup scripts, sample data, and Streamlit apps.

```bash
# Clone the repo
git clone https://github.com/sfc-gh-mgandhirajan/pharmacovigilance.git
cd pharmacovigilance

# Install a module (e.g., PBRER Writer)
cd pbrer-writer
# Run SQL scripts in order: 01_setup_tables.sql, 02_sample_data.sql, 03_deploy_app.sql
```

## Modules

### 1. PBRER Medical Writing Assistant (`pbrer-writer/`)

ICH E2C(R2) compliant Periodic Benefit-Risk Evaluation Report generator with all 19 sections.

**Features:**
- AI-generated content for all 19 PBRER sections
- Uses Snowflake Cortex (Llama 3.1 70B)
- Includes database schema, views, and sample data

**Installation:**
```sql
-- Run in order:
@pbrer-writer/sql/01_setup_tables.sql  -- Create schema
@pbrer-writer/sql/02_sample_data.sql   -- Load sample data
@pbrer-writer/sql/03_deploy_app.sql    -- Deploy Streamlit app
```

[Full documentation](pbrer-writer/README.md)

---

### 2. ICSR Narrative Generator (`icsr-narrative/`)

AI-powered Individual Case Safety Report narrative generation for regulatory submissions.

**Features:**
- Generates professional case narratives from structured ICSR data
- ICH E2B(R3) compliant narrative structure
- Save narratives to database with timestamps
- Export as downloadable text files

**Installation:**
```sql
@icsr-narrative/sql/01_setup_tables.sql
@icsr-narrative/sql/02_sample_data.sql
@icsr-narrative/sql/03_deploy_app.sql
```

[Full documentation](icsr-narrative/README.md)

---

### 3. E2B(R2) ICSR Ingestion (`e2b-ingestion/`)

ICH E2B(R2) compliant XML parser and Snowflake loader for Individual Case Safety Reports.

**Features:**
- Parses E2B(R2) XML files (FDA FAERS / EMA EudraVigilance compatible)
- Extracts safety reports, patient data, drugs, reactions (MedDRA)
- Loads into normalized tables
- Includes sample E2B XML for testing

**Installation:**
```sql
@e2b-ingestion/sql/01_setup_tables.sql
@e2b-ingestion/sql/02_deploy_app.sql
```

[Full documentation](e2b-ingestion/README.md)

---

### 4. Legacy Files

Original prototype files - use the packaged modules above instead.

**Files:** `streamlit_app.py`, `app.py`, `psur_app.py`

---

## Technology Stack

| Component | Technology |
|-----------|------------|
| AI/LLM | Snowflake Cortex (Llama 3.1 70B) |
| UI | Streamlit in Snowflake |
| Terminology | MedDRA (SOC, PT, LLT) |
| Data Format | ICH E2B(R2) XML |
| Reporting Standard | ICH E2C(R2) PBRER |

## Database Schema

```
HCLS_DEMO
├── PHARMACOVIGILANCE
│   ├── PRODUCT_REGISTRY        -- Products for PBRER
│   ├── ICSR_CASES             -- Individual case safety reports (PBRER)
│   ├── ICSR_CASES_NARRATIVE   -- ICSR cases with narratives
│   ├── E2B_ICSR_CASES         -- E2B imported cases
│   ├── E2B_ICSR_DRUGS         -- E2B imported drugs
│   ├── E2B_ICSR_REACTIONS     -- E2B imported reactions
│   ├── V_PSUR_PRODUCT_SUMMARY -- Product statistics
│   ├── V_PSUR_CASES_BY_SOC    -- Cases by System Organ Class
│   ├── V_PSUR_MONTHLY_TREND   -- Monthly trends
│   ├── V_PSUR_CAUSALITY       -- Causality distribution
│   └── V_E2B_CASE_SUMMARY     -- E2B case overview
└── STREAMLIT_APPS
    ├── PBRER_WRITER_STAGE      -- PBRER app files
    ├── ICSR_NARRATIVE_STAGE    -- ICSR Narrative app files
    └── E2B_INGESTION_STAGE     -- E2B app files
```

## Requirements

- Snowflake account with Cortex LLM access
- Warehouse for query execution
- ACCOUNTADMIN or appropriate privileges for setup

## License

MIT
