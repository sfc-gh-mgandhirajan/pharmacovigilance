-- ============================================================================
-- E2B(R2) ICSR Ingestion - Deploy Streamlit App
-- ============================================================================

USE DATABASE HCLS_DEMO;

-- Upload files to stage (run from SnowSQL CLI)
-- PUT file:///path/to/e2b_ingestion_app.py @HCLS_DEMO.STREAMLIT_APPS.E2B_INGESTION_STAGE OVERWRITE=TRUE AUTO_COMPRESS=FALSE;
-- PUT file:///path/to/environment.yml @HCLS_DEMO.STREAMLIT_APPS.E2B_INGESTION_STAGE OVERWRITE=TRUE AUTO_COMPRESS=FALSE;

-- Create Streamlit app
CREATE OR REPLACE STREAMLIT HCLS_DEMO.STREAMLIT_APPS.E2B_ICSR_INGESTION
    ROOT_LOCATION = '@HCLS_DEMO.STREAMLIT_APPS.E2B_INGESTION_STAGE'
    MAIN_FILE = 'e2b_ingestion_app.py'
    QUERY_WAREHOUSE = 'COMPUTE_WH'  -- Change to your warehouse
    TITLE = 'E2B(R2) ICSR Ingestion';

-- Verify deployment
SHOW STREAMLITS IN SCHEMA HCLS_DEMO.STREAMLIT_APPS;
