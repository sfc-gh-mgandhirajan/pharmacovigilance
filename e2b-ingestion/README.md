# E2B(R2) ICSR Ingestion Pipeline

ICH E2B(R2) compliant XML parser and Snowflake loader for Individual Case Safety Reports.

## Overview

This module parses E2B(R2) XML files (the standard format for FDA FAERS and EMA EudraVigilance submissions) and loads them into normalized Snowflake tables.

## Installation

### Step 1: Create Database Objects

```sql
@sql/01_setup_tables.sql
```

Creates:
- `E2B_ICSR_CASES` - Main safety report information
- `E2B_ICSR_DRUGS` - Drug information (suspect, concomitant, interacting)
- `E2B_ICSR_REACTIONS` - Adverse event information (MedDRA coded)
- `V_E2B_CASE_SUMMARY` - Joined summary view

### Step 2: Load Sample Data (Optional)

```sql
@sql/02_sample_data.sql
```

### Step 3: Deploy Streamlit App

```sql
-- Upload files
PUT file:///path/to/e2b_ingestion_app.py @HCLS_DEMO.STREAMLIT_APPS.E2B_INGESTION_STAGE OVERWRITE=TRUE AUTO_COMPRESS=FALSE;
PUT file:///path/to/environment.yml @HCLS_DEMO.STREAMLIT_APPS.E2B_INGESTION_STAGE OVERWRITE=TRUE AUTO_COMPRESS=FALSE;

-- Deploy
@sql/03_deploy_app.sql
```

## E2B(R2) Elements Parsed

| Element | Description |
|---------|-------------|
| `safetyreportid` | Unique case identifier |
| `reporttype` | Spontaneous, Clinical Trial, etc. |
| `serious` | Seriousness flag |
| `seriousness*` | Death, Life-threatening, Hospitalization, etc. |
| `patient` | Age, sex, weight, medical history |
| `drug` | Medicinal product, characterization, dosage |
| `reaction` | MedDRA PT, outcome, dates |
| `narrativeincludeclinical` | Case narrative |

## File Structure

```
e2b-ingestion/
├── README.md
├── e2b_ingestion_app.py    # Streamlit app
├── e2b_parser.py           # Standalone parser module
├── environment.yml         # Snowflake dependencies
├── sample_e2b_r2.xml       # Sample E2B XML (2 cases)
└── sql/
    ├── 01_setup_tables.sql # Database schema
    ├── 02_sample_data.sql  # Sample data
    └── 03_deploy_app.sql   # App deployment
```

## Using the Streamlit App

1. **Upload & Parse Tab**: Upload E2B XML file, preview, parse, and load to Snowflake
2. **Database Setup Tab**: Create required tables (run once)
3. **View Data Tab**: Query loaded E2B data

## Programmatic Usage

```python
from e2b_parser import E2BR2Parser

# Parse E2B XML
with open('sample_e2b_r2.xml', 'r') as f:
    xml_content = f.read()

parser = E2BR2Parser(xml_content)
reports = parser.parse()

# Get Snowflake-ready records
records = parser.to_snowflake_records()
# Returns: {'ICSR_CASES': [...], 'ICSR_DRUGS': [...], 'ICSR_REACTIONS': [...]}
```

## Compliance

- **ICH E2B(R2)**: Full compliance with ICH ICSR specification v2.1
- **FDA FAERS**: Compatible with FDA Adverse Event Reporting System
- **EMA EudraVigilance**: Compatible with European submissions

## License

MIT
