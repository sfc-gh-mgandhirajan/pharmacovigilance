-- ============================================================================
-- ICSR Narrative Generator - Deploy Streamlit App
-- ============================================================================

USE DATABASE HCLS_DEMO;

-- Upload files to stage (run from SnowSQL CLI)
-- PUT file:///path/to/icsr_narrative_app.py @HCLS_DEMO.STREAMLIT_APPS.ICSR_NARRATIVE_STAGE OVERWRITE=TRUE AUTO_COMPRESS=FALSE;
-- PUT file:///path/to/environment.yml @HCLS_DEMO.STREAMLIT_APPS.ICSR_NARRATIVE_STAGE OVERWRITE=TRUE AUTO_COMPRESS=FALSE;

-- Create Streamlit app
CREATE OR REPLACE STREAMLIT HCLS_DEMO.STREAMLIT_APPS.ICSR_NARRATIVE_GENERATOR
    ROOT_LOCATION = '@HCLS_DEMO.STREAMLIT_APPS.ICSR_NARRATIVE_STAGE'
    MAIN_FILE = 'icsr_narrative_app.py'
    QUERY_WAREHOUSE = 'COMPUTE_WH'  -- Change to your warehouse
    TITLE = 'ICSR Narrative Generator';

-- Verify deployment
SHOW STREAMLITS IN SCHEMA HCLS_DEMO.STREAMLIT_APPS;
