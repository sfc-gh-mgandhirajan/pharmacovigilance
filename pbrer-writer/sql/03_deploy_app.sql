-- ============================================================================
-- PBRER Medical Writing Assistant - Deploy Streamlit App
-- Run after uploading pbrer_app.py and environment.yml to stage
-- ============================================================================

USE DATABASE HCLS_DEMO;

-- ============================================================================
-- Option 1: Deploy from local files (run from SnowSQL or Snowsight)
-- ============================================================================

-- Upload files to stage (run these PUT commands from SnowSQL CLI)
-- PUT file:///path/to/pbrer_app.py @HCLS_DEMO.STREAMLIT_APPS.PBRER_WRITER_STAGE OVERWRITE=TRUE AUTO_COMPRESS=FALSE;
-- PUT file:///path/to/environment.yml @HCLS_DEMO.STREAMLIT_APPS.PBRER_WRITER_STAGE OVERWRITE=TRUE AUTO_COMPRESS=FALSE;

-- ============================================================================
-- Option 2: Create Streamlit app after files are staged
-- ============================================================================

CREATE OR REPLACE STREAMLIT HCLS_DEMO.STREAMLIT_APPS.PBRER_MEDICAL_WRITER
    ROOT_LOCATION = '@HCLS_DEMO.STREAMLIT_APPS.PBRER_WRITER_STAGE'
    MAIN_FILE = 'pbrer_app.py'
    QUERY_WAREHOUSE = 'COMPUTE_WH'  -- Change to your warehouse name
    TITLE = 'PBRER Medical Writing Assistant';

-- ============================================================================
-- Grant access (modify role names as needed)
-- ============================================================================

-- Grant usage to specific roles
-- GRANT USAGE ON STREAMLIT HCLS_DEMO.STREAMLIT_APPS.PBRER_MEDICAL_WRITER TO ROLE <your_role>;

-- ============================================================================
-- Verify deployment
-- ============================================================================

SHOW STREAMLITS IN SCHEMA HCLS_DEMO.STREAMLIT_APPS;

-- Get the app URL
SELECT SYSTEM$GET_STREAMLIT_URL('HCLS_DEMO.STREAMLIT_APPS.PBRER_MEDICAL_WRITER');
