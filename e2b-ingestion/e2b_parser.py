"""
E2B(R2) ICSR XML Parser for Snowflake
Parses ICH E2B(R2) Individual Case Safety Report XML files and loads into Snowflake tables.
"""

import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from typing import List, Optional, Dict, Any
from datetime import datetime
import json


@dataclass
class Drug:
    characterization: Optional[str] = None
    medicinal_product: Optional[str] = None
    generic_name: Optional[str] = None
    brand_name: Optional[str] = None
    batch_number: Optional[str] = None
    authorization_number: Optional[str] = None
    authorization_country: Optional[str] = None
    authorization_holder: Optional[str] = None
    dosage_text: Optional[str] = None
    dosage_form: Optional[str] = None
    route_of_admin: Optional[str] = None
    indication: Optional[str] = None
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    action_taken: Optional[str] = None
    recurrence: Optional[str] = None


@dataclass
class Reaction:
    meddra_pt: Optional[str] = None
    meddra_pt_code: Optional[str] = None
    meddra_llt: Optional[str] = None
    meddra_llt_code: Optional[str] = None
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    duration: Optional[str] = None
    outcome: Optional[str] = None


@dataclass
class Patient:
    identifier: Optional[str] = None
    age: Optional[str] = None
    age_unit: Optional[str] = None
    birth_date: Optional[str] = None
    sex: Optional[str] = None
    weight: Optional[str] = None
    height: Optional[str] = None
    medical_history: Optional[str] = None
    death_date: Optional[str] = None
    autopsy: Optional[str] = None


@dataclass
class SafetyReport:
    safety_report_id: Optional[str] = None
    safety_report_version: Optional[str] = None
    transmission_date: Optional[str] = None
    report_type: Optional[str] = None
    serious: Optional[str] = None
    seriousness_death: Optional[str] = None
    seriousness_life_threatening: Optional[str] = None
    seriousness_hospitalization: Optional[str] = None
    seriousness_disability: Optional[str] = None
    seriousness_congenital: Optional[str] = None
    seriousness_other: Optional[str] = None
    receive_date: Optional[str] = None
    receipt_date: Optional[str] = None
    sender_type: Optional[str] = None
    sender_organization: Optional[str] = None
    receiver_type: Optional[str] = None
    receiver_organization: Optional[str] = None
    case_narrative: Optional[str] = None
    reporter_country: Optional[str] = None
    qualification: Optional[str] = None
    patient: Patient = field(default_factory=Patient)
    drugs: List[Drug] = field(default_factory=list)
    reactions: List[Reaction] = field(default_factory=list)


class E2BR2Parser:
    """Parser for ICH E2B(R2) ICSR XML format"""

    DRUG_CHARACTERIZATION = {
        "1": "Suspect",
        "2": "Concomitant", 
        "3": "Interacting"
    }

    REACTION_OUTCOME = {
        "1": "Recovered/Resolved",
        "2": "Recovering/Resolving",
        "3": "Not Recovered/Not Resolved",
        "4": "Recovered with Sequelae",
        "5": "Fatal",
        "6": "Unknown"
    }

    SEX_MAP = {
        "1": "Male",
        "2": "Female"
    }

    REPORT_TYPE = {
        "1": "Spontaneous",
        "2": "Report from Study",
        "3": "Other",
        "4": "Not available"
    }

    def __init__(self, xml_content: str):
        self.xml_content = xml_content
        self.root = None
        self.reports: List[SafetyReport] = []

    def parse(self) -> List[SafetyReport]:
        """Parse the E2B(R2) XML and return list of SafetyReport objects"""
        self.root = ET.fromstring(self.xml_content)
        
        for sr_elem in self.root.findall('.//safetyreport'):
            report = self._parse_safety_report(sr_elem)
            self.reports.append(report)
        
        return self.reports

    def _get_text(self, elem, path: str) -> Optional[str]:
        """Safely get text from element path"""
        found = elem.find(path)
        return found.text if found is not None and found.text else None

    def _parse_safety_report(self, sr_elem) -> SafetyReport:
        """Parse a single safetyreport element"""
        report = SafetyReport()
        
        report.safety_report_id = self._get_text(sr_elem, 'safetyreportid')
        report.safety_report_version = self._get_text(sr_elem, 'safetyreportversion')
        report.transmission_date = self._get_text(sr_elem, 'transmissiondate')
        
        report_type_code = self._get_text(sr_elem, 'reporttype')
        report.report_type = self.REPORT_TYPE.get(report_type_code, report_type_code)
        
        report.serious = self._get_text(sr_elem, 'serious')
        report.seriousness_death = self._get_text(sr_elem, 'seriousnessdeath')
        report.seriousness_life_threatening = self._get_text(sr_elem, 'seriousnesslifethreatening')
        report.seriousness_hospitalization = self._get_text(sr_elem, 'seriousnesshospitalization')
        report.seriousness_disability = self._get_text(sr_elem, 'seriousnessdisabling')
        report.seriousness_congenital = self._get_text(sr_elem, 'seriousnesscongenitalanomali')
        report.seriousness_other = self._get_text(sr_elem, 'seriousnessother')
        
        report.receive_date = self._get_text(sr_elem, 'receivedate')
        report.receipt_date = self._get_text(sr_elem, 'receiptdate')
        
        report.sender_type = self._get_text(sr_elem, './/sender/sendertype')
        report.sender_organization = self._get_text(sr_elem, './/sender/senderorganization')
        report.receiver_type = self._get_text(sr_elem, './/receiver/receivertype')
        report.receiver_organization = self._get_text(sr_elem, './/receiver/receiverorganization')
        
        report.case_narrative = self._get_text(sr_elem, './/narrativeincludeclinical')
        report.reporter_country = self._get_text(sr_elem, './/primarysource/reportercountry')
        report.qualification = self._get_text(sr_elem, './/primarysource/qualification')
        
        patient_elem = sr_elem.find('.//patient')
        if patient_elem is not None:
            report.patient = self._parse_patient(patient_elem)
            report.drugs = self._parse_drugs(patient_elem)
            report.reactions = self._parse_reactions(patient_elem)
        
        return report

    def _parse_patient(self, patient_elem) -> Patient:
        """Parse patient information"""
        patient = Patient()
        
        patient.identifier = self._get_text(patient_elem, 'patientidentification') or self._get_text(patient_elem, 'patientonsetage')
        patient.age = self._get_text(patient_elem, 'patientonsetage')
        patient.age_unit = self._get_text(patient_elem, 'patientonsetageunit')
        patient.birth_date = self._get_text(patient_elem, 'patientbirthdate')
        
        sex_code = self._get_text(patient_elem, 'patientsex')
        patient.sex = self.SEX_MAP.get(sex_code, sex_code)
        
        patient.weight = self._get_text(patient_elem, 'patientweight')
        patient.height = self._get_text(patient_elem, 'patientheight')
        
        medical_history_parts = []
        for mh in patient_elem.findall('.//medicalhistoryepisode'):
            mh_text = self._get_text(mh, 'patientmedicalhistorytext')
            if mh_text:
                medical_history_parts.append(mh_text)
        patient.medical_history = '; '.join(medical_history_parts) if medical_history_parts else None
        
        patient.death_date = self._get_text(patient_elem, 'patientdeathdate')
        patient.autopsy = self._get_text(patient_elem, 'patientautopsyyesno')
        
        return patient

    def _parse_drugs(self, patient_elem) -> List[Drug]:
        """Parse drug information"""
        drugs = []
        
        for drug_elem in patient_elem.findall('.//drug'):
            drug = Drug()
            
            char_code = self._get_text(drug_elem, 'drugcharacterization')
            drug.characterization = self.DRUG_CHARACTERIZATION.get(char_code, char_code)
            
            drug.medicinal_product = self._get_text(drug_elem, 'medicinalproduct')
            drug.generic_name = self._get_text(drug_elem, 'activesubstancename')
            drug.brand_name = self._get_text(drug_elem, 'obtaindrugcountry')
            drug.batch_number = self._get_text(drug_elem, 'drugbatchnumb')
            drug.authorization_number = self._get_text(drug_elem, 'drugauthorizationnumb')
            drug.authorization_country = self._get_text(drug_elem, 'drugauthorizationcountry')
            drug.authorization_holder = self._get_text(drug_elem, 'drugauthorizationholder')
            drug.dosage_text = self._get_text(drug_elem, 'drugstructuredosagenumb')
            drug.dosage_form = self._get_text(drug_elem, 'drugdosageform')
            drug.route_of_admin = self._get_text(drug_elem, 'drugadministrationroute')
            drug.indication = self._get_text(drug_elem, 'drugindication')
            drug.start_date = self._get_text(drug_elem, 'drugstartdate')
            drug.end_date = self._get_text(drug_elem, 'drugenddate')
            drug.action_taken = self._get_text(drug_elem, 'actiondrug')
            drug.recurrence = self._get_text(drug_elem, 'drugrecurreadministration')
            
            drugs.append(drug)
        
        return drugs

    def _parse_reactions(self, patient_elem) -> List[Reaction]:
        """Parse reaction/adverse event information"""
        reactions = []
        
        for reaction_elem in patient_elem.findall('.//reaction'):
            reaction = Reaction()
            
            reaction.meddra_pt = self._get_text(reaction_elem, 'primarysourcereaction') or self._get_text(reaction_elem, 'reactionmeddrapt')
            reaction.meddra_pt_code = self._get_text(reaction_elem, 'reactionmeddraversionpt')
            reaction.meddra_llt = self._get_text(reaction_elem, 'reactionmeddrallt')
            reaction.meddra_llt_code = self._get_text(reaction_elem, 'reactionmeddraversionllt')
            reaction.start_date = self._get_text(reaction_elem, 'reactionstartdate')
            reaction.end_date = self._get_text(reaction_elem, 'reactionenddate')
            reaction.duration = self._get_text(reaction_elem, 'reactionduration')
            
            outcome_code = self._get_text(reaction_elem, 'reactionoutcome')
            reaction.outcome = self.REACTION_OUTCOME.get(outcome_code, outcome_code)
            
            reactions.append(reaction)
        
        return reactions

    def to_snowflake_records(self) -> Dict[str, List[Dict]]:
        """Convert parsed reports to Snowflake-ready records"""
        icsr_cases = []
        icsr_drugs = []
        icsr_reactions = []
        
        for report in self.reports:
            case_id = report.safety_report_id or f"CASE_{datetime.now().strftime('%Y%m%d%H%M%S')}"
            
            icsr_cases.append({
                'CASE_ID': case_id,
                'SAFETY_REPORT_VERSION': report.safety_report_version,
                'TRANSMISSION_DATE': report.transmission_date,
                'REPORT_TYPE': report.report_type,
                'SERIOUS': report.serious,
                'SERIOUSNESS_DEATH': report.seriousness_death,
                'SERIOUSNESS_LIFE_THREATENING': report.seriousness_life_threatening,
                'SERIOUSNESS_HOSPITALIZATION': report.seriousness_hospitalization,
                'SERIOUSNESS_DISABILITY': report.seriousness_disability,
                'SERIOUSNESS_CONGENITAL': report.seriousness_congenital,
                'SERIOUSNESS_OTHER': report.seriousness_other,
                'RECEIVE_DATE': report.receive_date,
                'RECEIPT_DATE': report.receipt_date,
                'SENDER_TYPE': report.sender_type,
                'SENDER_ORGANIZATION': report.sender_organization,
                'RECEIVER_TYPE': report.receiver_type,
                'RECEIVER_ORGANIZATION': report.receiver_organization,
                'CASE_NARRATIVE': report.case_narrative,
                'REPORTER_COUNTRY': report.reporter_country,
                'QUALIFICATION': report.qualification,
                'PATIENT_AGE': report.patient.age,
                'PATIENT_AGE_UNIT': report.patient.age_unit,
                'PATIENT_SEX': report.patient.sex,
                'PATIENT_WEIGHT': report.patient.weight,
                'PATIENT_HEIGHT': report.patient.height,
                'PATIENT_MEDICAL_HISTORY': report.patient.medical_history,
                'PATIENT_DEATH_DATE': report.patient.death_date,
                'INGESTION_TIMESTAMP': datetime.now().isoformat()
            })
            
            for idx, drug in enumerate(report.drugs, 1):
                icsr_drugs.append({
                    'CASE_ID': case_id,
                    'DRUG_SEQ': idx,
                    'DRUG_CHARACTERIZATION': drug.characterization,
                    'MEDICINAL_PRODUCT': drug.medicinal_product,
                    'GENERIC_NAME': drug.generic_name,
                    'BATCH_NUMBER': drug.batch_number,
                    'AUTHORIZATION_NUMBER': drug.authorization_number,
                    'AUTHORIZATION_COUNTRY': drug.authorization_country,
                    'AUTHORIZATION_HOLDER': drug.authorization_holder,
                    'DOSAGE_TEXT': drug.dosage_text,
                    'DOSAGE_FORM': drug.dosage_form,
                    'ROUTE_OF_ADMIN': drug.route_of_admin,
                    'INDICATION': drug.indication,
                    'START_DATE': drug.start_date,
                    'END_DATE': drug.end_date,
                    'ACTION_TAKEN': drug.action_taken
                })
            
            for idx, reaction in enumerate(report.reactions, 1):
                icsr_reactions.append({
                    'CASE_ID': case_id,
                    'REACTION_SEQ': idx,
                    'MEDDRA_PT': reaction.meddra_pt,
                    'MEDDRA_PT_CODE': reaction.meddra_pt_code,
                    'MEDDRA_LLT': reaction.meddra_llt,
                    'MEDDRA_LLT_CODE': reaction.meddra_llt_code,
                    'START_DATE': reaction.start_date,
                    'END_DATE': reaction.end_date,
                    'DURATION': reaction.duration,
                    'OUTCOME': reaction.outcome
                })
        
        return {
            'ICSR_CASES': icsr_cases,
            'ICSR_DRUGS': icsr_drugs,
            'ICSR_REACTIONS': icsr_reactions
        }


def parse_e2b_xml(xml_content: str) -> Dict[str, List[Dict]]:
    """Main entry point for parsing E2B(R2) XML"""
    parser = E2BR2Parser(xml_content)
    parser.parse()
    return parser.to_snowflake_records()
