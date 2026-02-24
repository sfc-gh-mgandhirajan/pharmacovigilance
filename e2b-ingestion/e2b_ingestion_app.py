"""
Snowflake E2B(R2) ICSR Ingestion Pipeline
Loads E2B XML files from stage into normalized Snowflake tables.
"""

import streamlit as st
from snowflake.snowpark.context import get_active_session
import xml.etree.ElementTree as ET
from datetime import datetime

st.set_page_config(page_title="E2B(R2) ICSR Ingestion", page_icon="📥", layout="wide")

session = get_active_session()

DRUG_CHARACTERIZATION = {"1": "Suspect", "2": "Concomitant", "3": "Interacting"}
REACTION_OUTCOME = {"1": "Recovered/Resolved", "2": "Recovering/Resolving", "3": "Not Recovered/Not Resolved", "4": "Recovered with Sequelae", "5": "Fatal", "6": "Unknown"}
SEX_MAP = {"1": "Male", "2": "Female"}
REPORT_TYPE = {"1": "Spontaneous", "2": "Report from Study", "3": "Other", "4": "Not available"}

def get_text(elem, path):
    found = elem.find(path)
    return found.text if found is not None and found.text else None

def parse_e2b_xml(xml_content):
    """Parse E2B(R2) XML and return structured records"""
    root = ET.fromstring(xml_content)
    icsr_cases, icsr_drugs, icsr_reactions = [], [], []
    
    for sr in root.findall('.//safetyreport'):
        case_id = get_text(sr, 'safetyreportid') or f"CASE_{datetime.now().strftime('%Y%m%d%H%M%S')}"
        
        patient_elem = sr.find('.//patient')
        patient_age = get_text(patient_elem, 'patientonsetage') if patient_elem else None
        patient_sex = SEX_MAP.get(get_text(patient_elem, 'patientsex'), None) if patient_elem else None
        
        medical_history_parts = []
        if patient_elem:
            for mh in patient_elem.findall('.//medicalhistoryepisode'):
                mh_text = get_text(mh, 'patientmedicalhistorytext')
                if mh_text:
                    medical_history_parts.append(mh_text)
        
        report_type_code = get_text(sr, 'reporttype')
        
        icsr_cases.append({
            'CASE_ID': case_id,
            'SAFETY_REPORT_VERSION': get_text(sr, 'safetyreportversion'),
            'TRANSMISSION_DATE': get_text(sr, 'transmissiondate'),
            'REPORT_TYPE': REPORT_TYPE.get(report_type_code, report_type_code),
            'SERIOUS': get_text(sr, 'serious'),
            'SERIOUSNESS_DEATH': get_text(sr, 'seriousnessdeath'),
            'SERIOUSNESS_LIFE_THREATENING': get_text(sr, 'seriousnesslifethreatening'),
            'SERIOUSNESS_HOSPITALIZATION': get_text(sr, 'seriousnesshospitalization'),
            'SERIOUSNESS_DISABILITY': get_text(sr, 'seriousnessdisabling'),
            'SERIOUSNESS_CONGENITAL': get_text(sr, 'seriousnesscongenitalanomali'),
            'SERIOUSNESS_OTHER': get_text(sr, 'seriousnessother'),
            'RECEIVE_DATE': get_text(sr, 'receivedate'),
            'RECEIPT_DATE': get_text(sr, 'receiptdate'),
            'SENDER_ORGANIZATION': get_text(sr, './/sender/senderorganization'),
            'RECEIVER_ORGANIZATION': get_text(sr, './/receiver/receiverorganization'),
            'CASE_NARRATIVE': get_text(sr, './/narrativeincludeclinical'),
            'REPORTER_COUNTRY': get_text(sr, './/primarysource/reportercountry'),
            'QUALIFICATION': get_text(sr, './/primarysource/qualification'),
            'PATIENT_AGE': patient_age,
            'PATIENT_SEX': patient_sex,
            'PATIENT_WEIGHT': get_text(patient_elem, 'patientweight') if patient_elem else None,
            'PATIENT_MEDICAL_HISTORY': '; '.join(medical_history_parts) if medical_history_parts else None,
            'PATIENT_DEATH_DATE': get_text(patient_elem, 'patientdeathdate') if patient_elem else None
        })
        
        if patient_elem:
            for idx, drug_elem in enumerate(patient_elem.findall('.//drug'), 1):
                char_code = get_text(drug_elem, 'drugcharacterization')
                icsr_drugs.append({
                    'CASE_ID': case_id,
                    'DRUG_SEQ': idx,
                    'DRUG_CHARACTERIZATION': DRUG_CHARACTERIZATION.get(char_code, char_code),
                    'MEDICINAL_PRODUCT': get_text(drug_elem, 'medicinalproduct'),
                    'GENERIC_NAME': get_text(drug_elem, 'activesubstancename'),
                    'BATCH_NUMBER': get_text(drug_elem, 'drugbatchnumb'),
                    'AUTHORIZATION_HOLDER': get_text(drug_elem, 'drugauthorizationholder'),
                    'DOSAGE_TEXT': get_text(drug_elem, 'drugstructuredosagenumb'),
                    'DOSAGE_FORM': get_text(drug_elem, 'drugdosageform'),
                    'ROUTE_OF_ADMIN': get_text(drug_elem, 'drugadministrationroute'),
                    'INDICATION': get_text(drug_elem, 'drugindication'),
                    'START_DATE': get_text(drug_elem, 'drugstartdate'),
                    'END_DATE': get_text(drug_elem, 'drugenddate'),
                    'ACTION_TAKEN': get_text(drug_elem, 'actiondrug')
                })
            
            for idx, reaction_elem in enumerate(patient_elem.findall('.//reaction'), 1):
                outcome_code = get_text(reaction_elem, 'reactionoutcome')
                icsr_reactions.append({
                    'CASE_ID': case_id,
                    'REACTION_SEQ': idx,
                    'MEDDRA_PT': get_text(reaction_elem, 'primarysourcereaction') or get_text(reaction_elem, 'reactionmeddrapt'),
                    'MEDDRA_PT_CODE': get_text(reaction_elem, 'reactionmeddraversionpt'),
                    'MEDDRA_LLT': get_text(reaction_elem, 'reactionmeddrallt'),
                    'START_DATE': get_text(reaction_elem, 'reactionstartdate'),
                    'END_DATE': get_text(reaction_elem, 'reactionenddate'),
                    'OUTCOME': REACTION_OUTCOME.get(outcome_code, outcome_code)
                })
    
    return icsr_cases, icsr_drugs, icsr_reactions

st.title("📥 E2B(R2) ICSR XML Ingestion")
st.caption("ICH E2B(R2) compliant Individual Case Safety Report XML parser and loader")

tab1, tab2, tab3 = st.tabs(["📤 Upload & Parse", "🗄️ Database Setup", "📊 View Data"])

with tab1:
    st.markdown("### Upload E2B(R2) XML File")
    
    col1, col2 = st.columns([2, 1])
    with col1:
        target_db = st.text_input("Target Database", value="HCLS_DEMO")
        target_schema = st.text_input("Target Schema", value="PHARMACOVIGILANCE")
    with col2:
        st.markdown("**E2B(R2) Elements Parsed:**")
        st.markdown("- Safety Report metadata")
        st.markdown("- Patient demographics")
        st.markdown("- Drug information")
        st.markdown("- Reactions (MedDRA)")
    
    uploaded_file = st.file_uploader("Upload E2B(R2) XML file", type=['xml'])
    
    if uploaded_file:
        xml_content = uploaded_file.read().decode('utf-8')
        st.success(f"Loaded: {uploaded_file.name} ({len(xml_content):,} bytes)")
        
        with st.expander("Preview XML"):
            st.code(xml_content[:2000] + "..." if len(xml_content) > 2000 else xml_content, language="xml")
        
        if st.button("🔍 Parse E2B XML", type="primary"):
            with st.spinner("Parsing E2B(R2) XML..."):
                try:
                    cases, drugs, reactions = parse_e2b_xml(xml_content)
                    
                    st.session_state['parsed_cases'] = cases
                    st.session_state['parsed_drugs'] = drugs
                    st.session_state['parsed_reactions'] = reactions
                    
                    st.success(f"Parsed: {len(cases)} cases, {len(drugs)} drugs, {len(reactions)} reactions")
                    
                    col1, col2, col3 = st.columns(3)
                    with col1:
                        st.metric("ICSR Cases", len(cases))
                    with col2:
                        st.metric("Drug Records", len(drugs))
                    with col3:
                        st.metric("Reaction Records", len(reactions))
                    
                    if cases:
                        st.markdown("**Sample Case:**")
                        st.json(cases[0])
                except Exception as e:
                    st.error(f"Parse error: {str(e)}")
    
    if 'parsed_cases' in st.session_state and st.session_state['parsed_cases']:
        st.divider()
        st.markdown("### Load to Snowflake")
        
        if st.button("📥 Insert into Snowflake Tables", type="primary", key="btn_insert"):
            with st.spinner("Inserting records..."):
                try:
                    cases = st.session_state['parsed_cases']
                    drugs = st.session_state['parsed_drugs']
                    reactions = st.session_state['parsed_reactions']
                    
                    case_count = 0
                    for case in cases:
                        cols = ', '.join(case.keys())
                        vals = ', '.join([f"'{str(v).replace(chr(39), chr(39)+chr(39))}'" if v else 'NULL' for v in case.values()])
                        sql = f"INSERT INTO {target_db}.{target_schema}.E2B_ICSR_CASES ({cols}) VALUES ({vals})"
                        session.sql(sql).collect()
                        case_count += 1
                    
                    drug_count = 0
                    for drug in drugs:
                        cols = ', '.join(drug.keys())
                        vals = ', '.join([f"'{str(v).replace(chr(39), chr(39)+chr(39))}'" if v else 'NULL' for v in drug.values()])
                        sql = f"INSERT INTO {target_db}.{target_schema}.E2B_ICSR_DRUGS ({cols}) VALUES ({vals})"
                        session.sql(sql).collect()
                        drug_count += 1
                    
                    reaction_count = 0
                    for reaction in reactions:
                        cols = ', '.join(reaction.keys())
                        vals = ', '.join([f"'{str(v).replace(chr(39), chr(39)+chr(39))}'" if v else 'NULL' for v in reaction.values()])
                        sql = f"INSERT INTO {target_db}.{target_schema}.E2B_ICSR_REACTIONS ({cols}) VALUES ({vals})"
                        session.sql(sql).collect()
                        reaction_count += 1
                    
                    st.success(f"Inserted: {case_count} cases, {drug_count} drugs, {reaction_count} reactions")
                    
                    st.session_state.pop('parsed_cases', None)
                    st.session_state.pop('parsed_drugs', None)
                    st.session_state.pop('parsed_reactions', None)
                    
                except Exception as e:
                    st.error(f"Insert error: {str(e)}")

with tab2:
    st.markdown("### Create E2B ICSR Tables")
    st.info("Run this once to create the required tables for E2B(R2) data storage.")
    
    db_name = st.text_input("Database", value="HCLS_DEMO", key="setup_db")
    schema_name = st.text_input("Schema", value="PHARMACOVIGILANCE", key="setup_schema")
    
    ddl_cases = f"""
CREATE TABLE IF NOT EXISTS {db_name}.{schema_name}.E2B_ICSR_CASES (
    CASE_ID VARCHAR(100) PRIMARY KEY,
    SAFETY_REPORT_VERSION VARCHAR(10),
    TRANSMISSION_DATE VARCHAR(20),
    REPORT_TYPE VARCHAR(50),
    SERIOUS VARCHAR(5),
    SERIOUSNESS_DEATH VARCHAR(5),
    SERIOUSNESS_LIFE_THREATENING VARCHAR(5),
    SERIOUSNESS_HOSPITALIZATION VARCHAR(5),
    SERIOUSNESS_DISABILITY VARCHAR(5),
    SERIOUSNESS_CONGENITAL VARCHAR(5),
    SERIOUSNESS_OTHER VARCHAR(5),
    RECEIVE_DATE VARCHAR(20),
    RECEIPT_DATE VARCHAR(20),
    SENDER_ORGANIZATION VARCHAR(200),
    RECEIVER_ORGANIZATION VARCHAR(200),
    CASE_NARRATIVE TEXT,
    REPORTER_COUNTRY VARCHAR(10),
    QUALIFICATION VARCHAR(50),
    PATIENT_AGE VARCHAR(20),
    PATIENT_SEX VARCHAR(20),
    PATIENT_WEIGHT VARCHAR(20),
    PATIENT_MEDICAL_HISTORY TEXT,
    PATIENT_DEATH_DATE VARCHAR(20),
    INGESTION_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);"""

    ddl_drugs = f"""
CREATE TABLE IF NOT EXISTS {db_name}.{schema_name}.E2B_ICSR_DRUGS (
    CASE_ID VARCHAR(100),
    DRUG_SEQ INT,
    DRUG_CHARACTERIZATION VARCHAR(50),
    MEDICINAL_PRODUCT VARCHAR(500),
    GENERIC_NAME VARCHAR(500),
    BATCH_NUMBER VARCHAR(100),
    AUTHORIZATION_HOLDER VARCHAR(200),
    DOSAGE_TEXT VARCHAR(200),
    DOSAGE_FORM VARCHAR(100),
    ROUTE_OF_ADMIN VARCHAR(100),
    INDICATION VARCHAR(500),
    START_DATE VARCHAR(20),
    END_DATE VARCHAR(20),
    ACTION_TAKEN VARCHAR(100),
    PRIMARY KEY (CASE_ID, DRUG_SEQ),
    FOREIGN KEY (CASE_ID) REFERENCES {db_name}.{schema_name}.E2B_ICSR_CASES(CASE_ID)
);"""

    ddl_reactions = f"""
CREATE TABLE IF NOT EXISTS {db_name}.{schema_name}.E2B_ICSR_REACTIONS (
    CASE_ID VARCHAR(100),
    REACTION_SEQ INT,
    MEDDRA_PT VARCHAR(500),
    MEDDRA_PT_CODE VARCHAR(20),
    MEDDRA_LLT VARCHAR(500),
    START_DATE VARCHAR(20),
    END_DATE VARCHAR(20),
    OUTCOME VARCHAR(100),
    PRIMARY KEY (CASE_ID, REACTION_SEQ),
    FOREIGN KEY (CASE_ID) REFERENCES {db_name}.{schema_name}.E2B_ICSR_CASES(CASE_ID)
);"""
    
    with st.expander("View DDL Statements"):
        st.code(ddl_cases, language="sql")
        st.code(ddl_drugs, language="sql")
        st.code(ddl_reactions, language="sql")
    
    if st.button("🔨 Create Tables", type="primary", key="btn_create"):
        with st.spinner("Creating tables..."):
            try:
                session.sql(ddl_cases).collect()
                st.success("Created E2B_ICSR_CASES")
                
                session.sql(ddl_drugs).collect()
                st.success("Created E2B_ICSR_DRUGS")
                
                session.sql(ddl_reactions).collect()
                st.success("Created E2B_ICSR_REACTIONS")
                
                st.balloons()
            except Exception as e:
                st.error(f"Error: {str(e)}")

with tab3:
    st.markdown("### View Ingested E2B Data")
    
    view_db = st.text_input("Database", value="HCLS_DEMO", key="view_db")
    view_schema = st.text_input("Schema", value="PHARMACOVIGILANCE", key="view_schema")
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        if st.button("📋 View Cases"):
            try:
                df = session.sql(f"SELECT * FROM {view_db}.{view_schema}.E2B_ICSR_CASES LIMIT 100").to_pandas()
                st.dataframe(df, use_container_width=True)
            except Exception as e:
                st.error(str(e))
    
    with col2:
        if st.button("💊 View Drugs"):
            try:
                df = session.sql(f"SELECT * FROM {view_db}.{view_schema}.E2B_ICSR_DRUGS LIMIT 100").to_pandas()
                st.dataframe(df, use_container_width=True)
            except Exception as e:
                st.error(str(e))
    
    with col3:
        if st.button("⚠️ View Reactions"):
            try:
                df = session.sql(f"SELECT * FROM {view_db}.{view_schema}.E2B_ICSR_REACTIONS LIMIT 100").to_pandas()
                st.dataframe(df, use_container_width=True)
            except Exception as e:
                st.error(str(e))

st.divider()
col1, col2, col3, col4 = st.columns(4)
with col1:
    st.metric("Standard", "ICH E2B(R2)")
with col2:
    st.metric("Format", "XML")
with col3:
    st.metric("Tables", "3")
with col4:
    st.metric("Compliance", "FDA/EMA")

st.caption("E2B(R2) ICSR Ingestion Pipeline | ICH Compliant XML Parser for Pharmacovigilance")
