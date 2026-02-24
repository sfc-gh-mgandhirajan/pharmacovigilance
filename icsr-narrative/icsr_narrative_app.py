import streamlit as st
from snowflake.snowpark.context import get_active_session

st.set_page_config(
    page_title="ICSR Narrative Generator",
    page_icon="🏥",
    layout="wide"
)

session = get_active_session()

def get_cases():
    df = session.sql("""
        SELECT CASE_ID, SUSPECT_DRUG_NAME, EVENT_TERM, SERIOUSNESS, REPORT_DATE,
               PATIENT_AGE, PATIENT_AGE_UNIT, PATIENT_SEX, CAUSALITY_ASSESSMENT
        FROM HCLS_DEMO.PHARMACOVIGILANCE.ICSR_CASES_NARRATIVE
        ORDER BY 
            CASE WHEN SERIOUSNESS = 'SERIOUS' THEN 0 ELSE 1 END,
            REPORT_DATE DESC
    """).collect()
    return df

def get_case_details(case_id):
    df = session.sql(f"""
        SELECT * FROM HCLS_DEMO.PHARMACOVIGILANCE.ICSR_CASES_NARRATIVE
        WHERE CASE_ID = '{case_id}'
    """).collect()
    if df:
        return df[0].as_dict()
    return None

def get_stats():
    df = session.sql("""
        SELECT * FROM HCLS_DEMO.PHARMACOVIGILANCE.V_ICSR_NARRATIVE_STATS
    """).collect()
    return df[0].as_dict() if df else None

def generate_narrative(case_data):
    prompt = f"""You are a pharmacovigilance medical writer. Generate a professional ICSR case narrative for regulatory submission based on the following structured data. The narrative should be clear, concise, and follow ICH E2B(R3) guidelines.

CASE INFORMATION:
- Case ID: {case_data['CASE_ID']}
- Report Date: {case_data['REPORT_DATE']}
- Report Source: {case_data['REPORT_SOURCE']}
- Seriousness: {case_data['SERIOUSNESS']}
- Reporter: {case_data['REPORTER_TYPE']} from {case_data['REPORTER_COUNTRY']}

PATIENT INFORMATION:
- Age: {case_data['PATIENT_AGE']} {case_data['PATIENT_AGE_UNIT']}
- Sex: {case_data['PATIENT_SEX']}
- Weight: {case_data['PATIENT_WEIGHT_KG']} kg
- Medical History: {case_data['MEDICAL_HISTORY']}

SUSPECT DRUG:
- Drug Name: {case_data['SUSPECT_DRUG_NAME']}
- Indication: {case_data['DRUG_INDICATION']}
- Dose: {case_data['DOSE']}
- Route: {case_data['ROUTE_OF_ADMIN']}
- Therapy Start: {case_data['THERAPY_START_DATE']}
- Therapy End: {case_data['THERAPY_END_DATE'] or 'Ongoing'}
- Action Taken: {case_data['ACTION_TAKEN']}

ADVERSE EVENT:
- Event Term: {case_data['EVENT_TERM']}
- MedDRA PT: {case_data['MEDDRA_PT']}
- MedDRA SOC: {case_data['MEDDRA_SOC']}
- Onset Date: {case_data['EVENT_ONSET_DATE']}
- Outcome: {case_data['EVENT_OUTCOME']}
- Description: {case_data['EVENT_DESCRIPTION']}

CAUSALITY:
- Assessment: {case_data['CAUSALITY_ASSESSMENT']}

Generate a professional narrative that:
1. Starts with patient demographics and relevant medical history
2. Describes the drug therapy including indication, dose, and duration
3. Details the adverse event including onset, symptoms, clinical findings, and management
4. Includes the outcome and any dechallenge/rechallenge information
5. Concludes with the causality assessment rationale

Write in third person, past tense, using medical terminology appropriate for regulatory submission."""

    escaped_prompt = prompt.replace("'", "''")
    
    result = session.sql(f"""
        SELECT SNOWFLAKE.CORTEX.COMPLETE(
            'llama3.1-70b',
            '{escaped_prompt}'
        ) AS NARRATIVE
    """).collect()
    
    return result[0]['NARRATIVE'] if result else "Error generating narrative"

def save_narrative(case_id, narrative):
    escaped_narrative = narrative.replace("'", "''")
    session.sql(f"""
        UPDATE HCLS_DEMO.PHARMACOVIGILANCE.ICSR_CASES_NARRATIVE
        SET GENERATED_NARRATIVE = '{escaped_narrative}',
            NARRATIVE_GENERATED_AT = CURRENT_TIMESTAMP()
        WHERE CASE_ID = '{case_id}'
    """).collect()

st.title("🏥 AI-Powered ICSR Narrative Generator")
st.markdown("**Powered by Snowflake Cortex** | Automated case narrative generation for regulatory submissions")

stats = get_stats()
if stats:
    col1, col2, col3, col4, col5 = st.columns(5)
    with col1:
        st.metric("Total Cases", stats['TOTAL_CASES'])
    with col2:
        st.metric("Narratives Generated", stats['NARRATIVES_GENERATED'])
    with col3:
        st.metric("Pending", stats['PENDING_NARRATIVES'])
    with col4:
        st.metric("Serious Cases", stats['SERIOUS_CASES'])
    with col5:
        st.metric("Unique Drugs", stats['UNIQUE_DRUGS'])

st.divider()

col1, col2 = st.columns([1, 2])

with col1:
    st.subheader("📋 Select Case")
    cases = get_cases()
    
    case_options = {f"{'🔴' if c['SERIOUSNESS']=='SERIOUS' else '🟢'} {c['CASE_ID']} | {c['SUSPECT_DRUG_NAME']} | {c['EVENT_TERM']}": c['CASE_ID'] for c in cases}
    selected_display = st.selectbox(
        "Available ICSR Cases",
        options=list(case_options.keys())
    )
    selected_case_id = case_options[selected_display]
    
    case_data = None
    if selected_case_id:
        case_data = get_case_details(selected_case_id)
        
        if case_data:
            st.markdown("---")
            st.markdown("**Case Summary**")
            
            seriousness_color = "🔴" if case_data['SERIOUSNESS'] == 'SERIOUS' else "🟢"
            st.markdown(f"{seriousness_color} **Seriousness:** {case_data['SERIOUSNESS']}")
            if case_data.get('SERIOUSNESS_CRITERIA'):
                st.caption(f"Criteria: {case_data['SERIOUSNESS_CRITERIA']}")
            st.markdown(f"**Drug:** {case_data['SUSPECT_DRUG_NAME']}")
            st.markdown(f"**Event:** {case_data['EVENT_TERM']}")
            st.markdown(f"**Patient:** {case_data['PATIENT_AGE']} {case_data['PATIENT_AGE_UNIT']} {case_data['PATIENT_SEX']}")
            st.markdown(f"**Outcome:** {case_data['EVENT_OUTCOME']}")
            st.markdown(f"**Causality:** {case_data['CAUSALITY_ASSESSMENT']}")
            
            if case_data.get('GENERATED_NARRATIVE'):
                st.success("✅ Narrative exists")

with col2:
    st.subheader("📝 Narrative Generation")
    
    tab1, tab2, tab3 = st.tabs(["Structured Data", "Generate Narrative", "Saved Narrative"])
    
    with tab1:
        if case_data:
            col_a, col_b = st.columns(2)
            with col_a:
                st.markdown("**Patient Information**")
                st.json({
                    "Age": f"{case_data['PATIENT_AGE']} {case_data['PATIENT_AGE_UNIT']}",
                    "Sex": case_data['PATIENT_SEX'],
                    "Weight": f"{case_data['PATIENT_WEIGHT_KG']} kg",
                    "Medical History": case_data['MEDICAL_HISTORY']
                })
                
                st.markdown("**Drug Information**")
                st.json({
                    "Drug": case_data['SUSPECT_DRUG_NAME'],
                    "Indication": case_data['DRUG_INDICATION'],
                    "Dose": case_data['DOSE'],
                    "Route": case_data['ROUTE_OF_ADMIN'],
                    "Start": str(case_data['THERAPY_START_DATE']),
                    "End": str(case_data['THERAPY_END_DATE']) if case_data['THERAPY_END_DATE'] else 'Ongoing',
                    "Action": case_data['ACTION_TAKEN']
                })
            
            with col_b:
                st.markdown("**Event Information**")
                st.json({
                    "Event": case_data['EVENT_TERM'],
                    "MedDRA PT": case_data['MEDDRA_PT'],
                    "MedDRA SOC": case_data['MEDDRA_SOC'],
                    "Onset": str(case_data['EVENT_ONSET_DATE']),
                    "Outcome": case_data['EVENT_OUTCOME']
                })
                
                st.markdown("**Event Description (Source)**")
                st.info(case_data['EVENT_DESCRIPTION'])
                
                st.markdown("**Causality Assessment**")
                st.warning(case_data['CAUSALITY_ASSESSMENT'])
    
    with tab2:
        if case_data:
            if st.button("🚀 Generate Narrative with Cortex AI", type="primary", use_container_width=True):
                with st.spinner("Generating narrative using Snowflake Cortex LLM..."):
                    narrative = generate_narrative(case_data)
                    st.session_state['generated_narrative'] = narrative
                    st.session_state['current_case_id'] = selected_case_id
            
            if 'generated_narrative' in st.session_state and st.session_state.get('current_case_id') == selected_case_id:
                st.markdown("**Generated ICSR Narrative**")
                st.markdown(st.session_state['generated_narrative'])
                
                st.divider()
                col_btn1, col_btn2 = st.columns(2)
                with col_btn1:
                    if st.button("💾 Save to Database", use_container_width=True):
                        save_narrative(selected_case_id, st.session_state['generated_narrative'])
                        st.success("Narrative saved!")
                        st.rerun()
                with col_btn2:
                    st.download_button(
                        "📥 Download",
                        st.session_state['generated_narrative'],
                        file_name=f"narrative_{selected_case_id}.txt",
                        mime="text/plain",
                        use_container_width=True
                    )
    
    with tab3:
        if case_data and case_data.get('GENERATED_NARRATIVE'):
            st.markdown("**Saved Narrative**")
            st.caption(f"Generated: {case_data.get('NARRATIVE_GENERATED_AT')}")
            st.markdown(case_data['GENERATED_NARRATIVE'])
            
            st.download_button(
                "📥 Download Saved Narrative",
                case_data['GENERATED_NARRATIVE'],
                file_name=f"narrative_{selected_case_id}.txt",
                mime="text/plain"
            )
        else:
            st.info("No saved narrative for this case. Generate one in the 'Generate Narrative' tab.")

st.divider()
col_f1, col_f2, col_f3, col_f4 = st.columns(4)
with col_f1:
    st.metric("Model", "Llama 3.1 70B")
with col_f2:
    st.metric("Standard", "ICH E2B(R3)")
with col_f3:
    st.metric("Data Governance", "In-Snowflake")
with col_f4:
    st.metric("Compliance", "FDA/EMA Ready")

st.caption("ICSR Narrative Generator | Automated medical writing for pharmacovigilance regulatory submissions")
