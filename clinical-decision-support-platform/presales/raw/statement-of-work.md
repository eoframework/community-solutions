---
document_title: Statement of Work
technology_provider: aws
project_name: MedCore Clinical Decision Support Platform
client_name: MedCore Health Systems
client_contact: Chief Information Officer | cio@medcorehealthsystems.org | +1 (615) 555-0100
consulting_company: Amatra
consultant_contact: Engagement Director | engagement@amatra.io | +1 (800) 555-0200
opportunity_no: OPP-2026-0047
document_date: June 18, 2025
version: 1.0
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Statement of Work (SOW) defines the scope, deliverables, roles, timeline, and commercial terms for the design, build, and enterprise rollout of an AWS-hosted AI/ML-powered Clinical Decision Support (CDS) Platform for MedCore Health Systems. This engagement will deliver a HIPAA-compliant, real-time risk intelligence platform that continuously analyzes patient vitals, lab results, medication history, and EHR events across all 18 MedCore hospitals and 60+ outpatient clinics to generate actionable risk alerts and LLM-powered clinical narratives for nursing and physician staff.

The engagement is structured across three phases: Phase 1 delivers the real-time data ingestion pipeline and sepsis risk model MVP by **2026-10-31**, ahead of MedCore's Joint Commission accreditation review. Phase 2 adds readmission and rapid-response models with a full clinical dashboard by **2027-02-28**. Phase 3 completes enterprise rollout across all facilities by **2027-06-30**, with general availability across all 18 hospitals in Q3 2027.

**Project Duration:** 14 months (May 2026 – June 2027 + 8-week hypercare)

**Key Outcomes:**
- Real-time patient risk scoring pipeline ingesting Epic FHIR R4 and HL7 v2.3 streams at < 3-second end-to-end latency
- Three production ML models: sepsis risk, 30-day readmission, and rapid-response / early deterioration
- LLM-powered plain-language clinical alert narratives via Amazon Bedrock for bedside staff
- Role-based clinical dashboard with SSO federated via Azure Active Directory
- HIPAA BAA, SOC 2 Type II, and HITECH-compliant platform with full PHI audit logging
- Phased rollout across all 18 hospitals with per-facility UAT sign-off and clinical adoption enablement

**Expected Benefits:**
- Reduce sepsis-related mortality by 15% within 12 months of go-live through earlier, more accurate detection
- Reduce 30-day readmission rates by 20% across all facilities within 18 months, lowering avoidable re-admission costs
- Decrease false-positive alert rate by 40% compared to the existing rule-based system, reducing nursing alert fatigue
- Platform availability of 99.95% via multi-AZ and multi-region active/passive architecture
- Clinical staff adoption rate ≥ 75% per facility within 90 days of rollout through structured training and UX investment
- Year 1 Total Investment (net of credits): **$1,117,432**; 3-Year Total: **$1,689,114**

---

# Background & Objectives

MedCore Health Systems is a $1.4B regional integrated delivery network (IDN) headquartered in Nashville, Tennessee, providing acute care, specialty services, and ambulatory care across 18 hospitals and 60+ outpatient clinics to approximately 2.1 million patients annually. As a HIPAA- and HITECH-covered entity, MedCore operates under Business Associate Agreements with its major cloud and software vendors. This engagement represents MedCore's strategic investment in AI-driven clinical intelligence as the cornerstone of its patient safety transformation program.

## Current State

MedCore's clinical teams currently rely on manual chart review and rule-based alerting systems to identify patients at risk of early deterioration, including sepsis events, rapid-response activations, and 30-day readmissions. This approach is inconsistent across facilities and creates significant operational and patient safety risks. Key challenges include:

- **Alert Fatigue:** The existing rule-based alerting system generates a high proportion of false-positive alerts, causing nursing staff to deprioritize or ignore notifications, increasing the risk of delayed intervention for genuinely deteriorating patients.
- **Inconsistency Across Facilities:** Manual chart review processes are not standardized, resulting in wide variation in early warning performance between MedCore's 18 hospitals and creating inequitable patient safety outcomes across the network.
- **Delayed Detection:** Risk identification occurs late in the deterioration cycle, after clinical signs have progressed, rather than at the earliest predictive window when intervention is most effective.
- **Lack of Explainability:** Existing rule-based triggers provide no insight into the contributing factors behind an alert, making it difficult for clinicians to quickly assess and act on warnings without additional chart review.
- **No Scalable Analytics Foundation:** MedCore has no enterprise-grade ML or real-time analytics infrastructure on AWS. The on-premises SQL Server data warehouse does not support real-time feature extraction or model serving at clinical scale.
- **Manual Compliance Overhead:** PHI audit logging, access control enforcement, and compliance evidence generation are largely manual processes, creating risk for the organization's HIPAA and HITECH obligations and upcoming SOC 2 Type II program.

## Business Objectives

The following strategic objectives define what this engagement must achieve for MedCore and are the primary measures of program success:

- **Modernize Clinical Risk Detection:** Replace rule-based alerting with continuously trained, evidence-based ML models that detect sepsis, rapid-response events, and 30-day readmission risk earlier and more accurately than current methods.
- **Reduce Patient Harm:** Deliver measurable improvements in sepsis mortality (−15% within 12 months) and readmission rates (−20% within 18 months) through earlier, more reliable clinical intervention triggers.
- **Improve Clinical Workflow Efficiency:** Reduce false-positive alert rates by 40% and provide LLM-generated plain-language clinical summaries so nursing and physician staff can assess and act on alerts in seconds, without separate chart review.
- **Establish HIPAA/SOC 2-Compliant AI Infrastructure:** Build a governed, auditable, PHI-compliant ML platform on AWS that satisfies all HIPAA, HITECH, and SOC 2 Type II requirements and establishes a reusable foundation for future clinical AI initiatives.
- **Enable Enterprise-Wide Adoption:** Execute a structured phased rollout across all 18 hospitals with per-facility UAT sign-off, train-the-trainer enablement, and adoption measurement to reach ≥ 75% clinical staff adoption within 90 days per facility.
- **Meet Regulatory Deadlines:** Deliver the Phase 1 sepsis MVP by **2026-10-31**, before the Joint Commission accreditation review in November 2026 where sepsis protocol outcomes will be audited.

## Success Metrics

The following SMART metrics define done for this engagement — each is measurable, time-bound, and directly traceable to a business objective above:

- Sepsis-related mortality reduction of ≥ 15% (facility-level measurement within 12 months of go-live)
- 30-day readmission rate reduction of ≥ 20% across all facilities within 18 months of GA
- False-positive alert rate reduced by ≥ 40% compared to the current rule-based system baseline
- Platform availability ≥ 99.95% (excluding planned maintenance windows), validated by automated uptime monitoring
- End-to-end inference latency < 3 seconds per patient record update at production load
- Sepsis model AUROC ≥ 0.85 against held-out clinical validation dataset (Clinical Informatics Lead sign-off required)
- Clinical staff adoption rate ≥ 75% per facility within 90 days of go-live, measured by active dashboard logins
- Phase 1 live in production by **2026-10-31** (hard deadline)
- Zero Critical or High unresolved security findings at go-live (CISO sign-off required)

---

# Scope of Work

This project will design, build, and deploy an enterprise-grade, AWS-hosted AI/ML Clinical Decision Support Platform for MedCore Health Systems, spanning real-time data ingestion, ML model development, clinical dashboard delivery, and a structured 18-hospital rollout. The following sections define the parameters, phased activities, and explicit boundaries of this engagement.

## In Scope

The following services and deliverables are included in this SOW:

- AWS infrastructure design and provisioning for a HIPAA-compliant, multi-AZ, multi-region CDS platform in a dedicated AWS account under MedCore's Clinical Applications OU
- Real-time data ingestion pipeline integrating Epic FHIR R4 API (HL7 FHIR R4) and Mirth Connect bedside monitor streams (HL7 v2.3) via Amazon Kinesis Data Streams and Amazon MSK
- Amazon HealthLake FHIR R4-compliant PHI datastore provisioning, configuration, and data governance controls
- Development and training of three custom ML risk models: sepsis prediction, 30-day readmission, and rapid-response / early deterioration using SageMaker Pipelines and Model Registry
- SHAP-based model explainability output bundled with every risk score alert
- Amazon Bedrock (Claude) integration for LLM-powered plain-language clinical alert narrative generation
- Role-based clinical dashboard (React/AWS Amplify) for risk score visualization and alert management, with mobile-responsive bedside view
- Azure Active Directory SSO federation via SAML 2.0 to Amazon Cognito for all clinical roles
- PHI encryption at rest and in transit using AWS KMS Customer Managed Keys (CMKs), with mandatory HIPAA audit logging via CloudTrail and Athena query layer
- SOC 2 Type II readiness: AWS Config rules, Security Hub, and evidence collection
- Amazon Redshift + Amazon QuickSight longitudinal outcome tracking and model performance monitoring
- CI/CD pipelines (CodePipeline/CodeBuild) with blue/green deployment for ML inference endpoints
- Infrastructure-as-Code (Terraform/CDK) for all environments (Dev, QA, Staging, Production)
- Structured phased rollout across all 18 hospitals and 60+ outpatient clinics with per-facility UAT
- Knowledge transfer sessions for MedCore IT and data engineering teams
- Train-the-trainer clinical staff enablement program
- Full as-built documentation, operational runbooks, and model cards
- 8-week post-GA hypercare support with 1-hour SLA for Critical incidents

### Scope Parameters

This engagement is sized for a **Large** implementation based on the following parameters:

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | ML Models | 3 custom models (sepsis, readmission, rapid-response) + LLM summarization via Bedrock |
| Solution Scope | Inference Volume | ~10M+ risk score updates/month across all active inpatients |
| Solution Scope | SageMaker Endpoints | 4 real-time endpoints (sepsis, readmission, rapid-response, ensemble) |
| Integration | EHR Integration | Epic FHIR R4 API (event-driven FHIR subscriptions); HL7 v2.3 Mirth Connect adapter |
| Integration | Identity | Azure AD SAML 2.0 federation to Amazon Cognito; 4 clinical role types |
| Integration | Downstream Export | Nightly readmission outcome export to on-premises SQL Server (out-of-scope system) |
| User Base | Clinical Staff | ~4,200 MAU across nurses, hospitalists, and administrators |
| User Base | Facilities | 18 hospitals + 60+ outpatient clinics (southeastern US) |
| Data Volume | Training Dataset | ≥ 1 TB labelled clinical data for model development |
| Data Volume | HealthLake Storage | 1 TB active FHIR store + 500 GB import/month |
| Data Volume | HL7 Event Throughput | 10 Kinesis shards; 1 Gbps Direct Connect |
| Technical Environment | AWS Regions | us-east-1 (primary) + us-west-2 (passive DR); all PHI remains in US regions |
| Technical Environment | Environments | Dev / QA / Staging / Production (4 environments); dedicated AWS account |
| Technical Environment | Concurrent Patients | > 2,500 simultaneously monitored inpatient records |
| Security & Compliance | Regulatory Frameworks | HIPAA BAA + HITECH + SOC 2 Type II |
| Security & Compliance | Availability Target | 99.95% (multi-AZ primary + active/passive multi-region DR) |
| Security & Compliance | Inference Latency SLA | < 3 seconds end-to-end from data arrival to risk score update |

Table: Engagement Scope Parameters

*Note: Changes to these parameters — including additional ML models, facility count increases, or added compliance frameworks — may require scope adjustment and additional investment via the change control process.*

## Out of Scope

The following items are explicitly excluded from this SOW unless formally added via the change control process:

- Modifications to MedCore's existing Epic EHR configuration, Epic FHIR API endpoint setup, or Epic licensing
- Migration or modification of the on-premises SQL Server 2016 data warehouse (retained system; only nightly export consumer)
- Mirth Connect platform upgrades, configuration changes beyond the HL7 v2.3 adapter integration, or server administration
- Bedside monitoring hardware procurement, Philips/GE device firmware, or network changes to clinical device networks
- Changes to MedCore's existing AWS Landing Zone, AWS Organizations structure, or SCPs outside the dedicated Clinical Applications OU account
- Azure Active Directory tenant configuration, user provisioning, or Azure AD licensing
- Data labelling, clinical annotation, or ground-truth curation services for ML training datasets beyond what MedCore's Clinical Informatics team provides
- Development of ML models beyond the three in scope (sepsis, readmission, rapid-response) — additional models require a separate SOW
- Third-party penetration testing fees (pen test firm engagement is coordinated but billed separately)
- Ongoing managed services post-hypercare (covered under a separate Managed Services Agreement if applicable)
- Custom mobile applications (alert delivery is web/responsive dashboard; native iOS/Android apps are out of scope)
- Revenue cycle system integration or claims data ingestion

## Activities

### Phase 1 — Discovery & Architecture Design (Weeks 1–5)

This phase establishes the clinical, technical, and compliance foundation for the entire program. Multi-stakeholder discovery sessions with CMO, CIO, CISO, Clinical Informatics Lead, and EHR Integration Lead will capture requirements, validate Epic FHIR API capabilities, and document PHI handling constraints. The output is an approved Assessment Report and detailed architecture design before any infrastructure is provisioned.

Key activities:
- Project kickoff and RACI alignment across all named stakeholders
- Clinical workflow discovery sessions with nursing staff and hospitalists
- Epic FHIR R4 API and Mirth Connect HL7 v2.3 topology assessment
- MedCore AWS Organization and Landing Zone documentation
- HIPAA BAA governance and PHI data-handling requirements workshops with CISO
- ML feature requirements workshops for sepsis model (Phase 1 priority)
- Model explainability and LLM narrative requirements capture
- Azure AD federation requirements for Cognito SAML 2.0
- Data quality and FHIR R4 resource completeness assessment
- Gap analysis for HIPAA-compliant ML workloads in existing AWS landing zone
- Risk identification (Joint Commission deadline, data privacy, clinical safety)
- Detailed architecture design: VPC, multi-region, Kinesis pipeline, SageMaker, Bedrock
- Security and compliance design: KMS, CloudTrail, RBAC, HIPAA audit logging
- Infrastructure-as-Code standards and CI/CD pipeline definition

**Deliverable:** Assessment Report (discovery findings, architecture approach, go/no-go recommendation) — approved by CMO and CIO.

### Phase 2 — Environment Build & Data Pipeline (Weeks 6–14)

This phase provisions the full four-environment AWS infrastructure via IaC, establishes secure connectivity to MedCore's on-premises systems, and delivers the real-time data ingestion pipeline. By the end of Phase 2, live HL7 FHIR and HL7 v2.3 data will be flowing into Amazon HealthLake and the SageMaker Feature Store, ready for model training.

Key activities:
- Provision Dev, QA, Staging, and Production AWS accounts and VPCs via Terraform/CDK
- Configure Transit Gateway and PrivateLink connectivity to on-premises Mirth Connect engine
- Develop Epic FHIR R4 API connector (SMART on FHIR OAuth 2.0; event-driven FHIR subscriptions)
- Develop HL7 v2.3 adapter for Mirth Connect bedside monitor streams (ADT and ORU message types)
- Build Kinesis Data Streams ingestion pipeline with schema validation and dead-letter queue
- Build SageMaker Feature Store pipelines for real-time and offline feature groups
- Provision and configure Amazon HealthLake FHIR data store
- Implement Azure AD SAML 2.0 federation with Amazon Cognito; configure role-based access
- Implement KMS CMK key policies and PHI encryption across all data stores
- Implement HIPAA audit logging (CloudTrail, CloudWatch, Athena query layer)
- Implement AWS Config rules and Security Hub findings for continuous compliance posture
- Build CI/CD pipelines with blue/green deployment capability for inference endpoints

**Deliverable:** Data ingestion pipeline operational; synthetic PHI flowing end-to-end through HealthLake and Feature Store. Environment provisioning complete.

### Phase 3 — ML Model Development & Integration (Weeks 8–20; overlaps Phase 2)

This phase covers the development and training of all three custom risk models, the LLM clinical narrative layer, the alert routing system, and the clinical dashboard. Phase 1 (sepsis model + ingestion pipeline) must reach production by Week 22 (2026-10-31). Phase 2 models (readmission and rapid-response) follow by 2027-02-28.

Key activities:
- Develop and train sepsis risk prediction model using SageMaker Pipelines (XGBoost/ensemble; AUROC ≥ 0.85)
- Develop SHAP-based model explainability pipeline outputting per-alert contributing factors
- Develop and train 30-day readmission prediction model (Phase 2)
- Develop and train rapid-response / early deterioration model (Phase 2)
- Implement Amazon Bedrock integration for clinical narrative generation with validated prompt templates
- Build real-time alert routing service (SNS/EventBridge) with role-based delivery and duplicate suppression
- Develop clinical staff dashboard (React/Amplify) with risk score visualization, alert management, mobile-responsive bedside view
- Build longitudinal outcome tracking and model performance monitoring dashboards (QuickSight)
- Implement infrastructure drift detection and automated compliance remediation (Config + Lambda)
- Complete all component configuration documentation

**Deliverable:** Sepsis model + full data pipeline in production (Phase 1 go-live ≤ 2026-10-31). Readmission and rapid-response models + clinical dashboard delivered by 2027-02-28.

### Phase 4 — Testing & Validation (Weeks 18–24)

This phase executes the full test program covering functional, integration, performance, security, compliance, model accuracy, and user acceptance testing. All critical and high findings must be resolved before production go-live. CISO sign-off on HIPAA security controls and CMO/CIO sign-off on model performance are gates to go-live.

Key activities:
- Develop comprehensive test plan (reviewed by Clinical Informatics Lead and CISO)
- Functional testing: data ingestion pipeline, feature store, inference endpoints, explainability output
- Integration testing: Epic FHIR R4 end-to-end with MedCore test environment using synthetic PHI
- Integration testing: HL7 v2.3 Mirth Connect adapter at production throughput
- End-to-end latency load test (< 3 seconds at 18-hospital peak load)
- Multi-region failover test (validate 99.95% SLA; simulate primary region outage)
- Model accuracy validation: sepsis AUROC, sensitivity, specificity against held-out clinical dataset
- LLM narrative quality assessment with clinical staff reviewers (≥ 5 nurses and hospitalists)
- HIPAA security controls validation (encryption, access controls, audit logs)
- External penetration testing (coordinated; firm billed separately)
- SOC 2 Type II readiness review and evidence collection
- UAT coordination and facilitation at pilot facility with clinical staff
- Defect triage and resolution (all Critical/High blockers resolved before go-live)

**Deliverable:** Test Results Report with model performance metrics and security validation summary; CMO/CIO go-live sign-off.

### Phase 5 — Production Rollout, Handover & Hypercare (Weeks 22–30+)

This phase executes the structured enterprise rollout across all 18 hospitals, delivers all knowledge transfer and training, completes as-built documentation, and provides 8 weeks of post-GA hypercare support. General Availability across all hospitals is targeted for Q3 2027.

Key activities:
- Phased per-facility cutover playbook execution (cohort-based rollout schedule)
- Phase 1 production deployment: sepsis model + ingestion pipeline (2026-10-31)
- Phase 2 production deployment: readmission and rapid-response models (2027-02-28)
- Phase 3 full facility rollout: all 18 hospitals + 60+ clinics (2027-06-30)
- Per-facility Epic integration validation and alert workflow activation
- Per-facility UAT sign-off before clinical activation
- Operational runbooks delivery (ingestion pipeline, ML inference, alert system)
- Architecture and operations knowledge transfer sessions for MedCore IT and data engineering
- Clinical staff train-the-trainer program (≥ 75% adoption target within 90 days per facility)
- Final as-built documentation package and IaC repository handover
- 8-week hypercare support (1-hour Critical response SLA; 4-hour High SLA)
- Project retrospective and outcomes report delivered to CMO and CIO

**Deliverable:** GA across all 18 hospitals (Q3 2027); final documentation package; hypercare period complete; outcomes report delivered.

---

# Deliverables & Timeline

This engagement spans approximately 14 months from commencement to General Availability, with a critical Phase 1 hard deadline tied to MedCore's Joint Commission accreditation review. The following tables define all contractual deliverables and project milestones.

## Deliverables

All deliverables listed below are formally accepted by the named authority before the corresponding milestone is closed. Acceptance criteria for each deliverable are defined in the Test Plan and phase kick-off documentation.

<!-- TABLE_CONFIG: widths=[5, 42, 13, 20, 20] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|-------------|------|----------|---------------|
| 1 | Project Kickoff Deck & RACI | Document | Week 1 | CIO / CMO |
| 2 | Current State Assessment Report | Document | Week 3 | CIO |
| 3 | Epic FHIR R4 & Mirth Connect Integration Specification | Document | Week 4 | EHR Integration Lead |
| 4 | HIPAA PHI Data-Handling Requirements Document | Document | Week 4 | CISO |
| 5 | Approved Architecture Assessment Report | Document | Week 5 | CMO / CIO |
| 6 | HLD & LLD Architecture Documents | Document | Week 7 | CIO / Solution Architect |
| 7 | Data Flow Diagrams & FHIR Resource Mapping Specification | Document | Week 7 | EHR Integration Lead |
| 8 | Security Architecture Document | Document | Week 7 | CISO |
| 9 | IaC Modules — All 4 Environments Provisioned | System | Week 10 | CIO / Cloud Engineer |
| 10 | Data Ingestion Pipeline (Kinesis + HealthLake + Feature Store) | System | Week 14 | CIO / Data Engineer |
| 11 | Epic FHIR R4 Connector & HL7 v2.3 Mirth Adapter | System | Week 14 | EHR Integration Lead |
| 12 | Azure AD / Cognito SSO Integration | System | Week 14 | CISO |
| 13 | HIPAA Audit Logging & KMS Encryption Implementation | System | Week 14 | CISO |
| 14 | Sepsis Risk Prediction Model v1.0 (AUROC ≥ 0.85) | System | Week 20 | Clinical Informatics Lead |
| 15 | SHAP Explainability Pipeline | System | Week 20 | Clinical Informatics Lead |
| 16 | Amazon Bedrock Clinical Narrative Integration | System | Week 20 | Clinical Informatics Lead |
| 17 | Phase 1 Production Go-Live (Sepsis + Pipeline) | System | **2026-10-31** | CMO / CIO |
| 18 | 30-Day Readmission Prediction Model | System | Week 30 | Clinical Informatics Lead |
| 19 | Rapid-Response / Early Deterioration Model | System | Week 30 | Clinical Informatics Lead |
| 20 | Clinical Staff Dashboard (React/Amplify) | System | Week 30 | CIO / Clinical Informatics Lead |
| 21 | Alert Routing & Notification System | System | Week 30 | CIO |
| 22 | Phase 2 Production Deployment | System | **2027-02-28** | CMO / CIO |
| 23 | Test Results Report & Model Performance Summary | Document | Week 36 | CMO / CIO / CISO |
| 24 | SOC 2 Type II Readiness Evidence Package | Document | Week 36 | CISO |
| 25 | Longitudinal Outcomes & Model Monitoring Dashboards | System | Week 38 | CIO / Quality & Safety |
| 26 | Phase 3 Full 18-Hospital Enterprise Rollout | System | **2027-06-30** | CMO / CIO |
| 27 | Operational Runbooks (Pipeline, Inference, Alert System) | Document | Week 44 | CIO / IT Operations |
| 28 | Architecture & Operations Knowledge Transfer Sessions | Training | Week 44 | CIO |
| 29 | Clinical Train-the-Trainer Enablement Program | Training | Week 44 | CMO / Clinical Informatics Lead |
| 30 | Final As-Built Documentation & IaC Repository Handover | Document | Week 44 | CIO |
| 31 | Project Closure Outcomes Report (KPI Baseline vs. Actual) | Document | Week 52+ | CMO / CIO |

## Project Milestones

The following milestones mark the completion of major program phases and serve as the gates for milestone-linked invoice triggers defined in the Investment Summary. Each milestone requires formal written acceptance from the named authority before the next phase commences.

<!-- TABLE_CONFIG: widths=[22, 53, 25] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 — Discovery Complete | Assessment Report approved by CMO and CIO; go/no-go for Architecture phase | Week 5 |
| M2 — Architecture Approved | HLD, LLD, Security Architecture, and FHIR mapping documents signed off | Week 7 |
| M3 — Infrastructure Ready | All 4 environments provisioned via IaC; connectivity to Mirth Connect validated | Week 10 |
| M4 — Data Pipeline Live | Real-time FHIR and HL7 ingestion flowing end-to-end to HealthLake and Feature Store | Week 14 |
| M5 — Phase 1 Go-Live | Sepsis model + pipeline live in production at pilot facility cohort | **2026-10-31** |
| M6 — Phase 2 Deployment | Readmission + rapid-response models and clinical dashboard in production | **2027-02-28** |
| M7 — Test Sign-Off | Test Results Report approved; CISO and CMO/CIO go-live clearance for enterprise rollout | Week 36 |
| M8 — Enterprise GA | Full 18-hospital rollout complete; all facilities clinically active | **2027-06-30** |
| M9 — Hypercare End | 8-week post-GA hypercare period complete; transition to BAU or Managed Services | Q3 2027 + 8 weeks |

---

# Roles & Responsibilities

The success of this program depends on clear accountability across Amatra's delivery team and MedCore's stakeholder organization. Given the clinical safety stakes, regulatory complexity, and 14-month engagement timeline, this section defines RACI responsibilities for all major work streams and the key personnel for each team.

## RACI Matrix

The following RACI matrix defines accountability across the major task categories for this engagement. Each row carries exactly one Accountable (A) party, and every task has at least one Responsible (R) assignee. This matrix should be reviewed at the start of each project phase and updated via the change control process if key personnel change.

<!-- TABLE_CONFIG: widths=[28, 10, 10, 10, 9, 10, 9, 8, 6] -->
| Task / Work Stream | Amatra PM | Amatra Arch | Amatra Eng | Amatra QA | Client CIO | Client CMO | Client CISO | SME |
|---|---|---|---|---|---|---|---|---|
| Project Governance & Reporting | A | C | I | I | R | C | I | I |
| Clinical Requirements & Feature Definition | C | R | C | I | I | A | I | R |
| AWS Architecture Design | C | A | R | I | C | I | C | I |
| Security & HIPAA Compliance Design | C | R | C | I | C | I | A | I |
| Infrastructure Provisioning (IaC) | I | C | A | I | R | I | C | I |
| Epic FHIR R4 & HL7 v2.3 Integration | I | C | A | C | R | I | I | R |
| ML Model Development & Training | I | A | R | C | I | C | I | C |
| Model Accuracy Clinical Validation | C | C | R | C | I | A | I | R |
| LLM Narrative Integration (Bedrock) | I | A | R | C | I | C | I | I |
| Clinical Dashboard Development | I | C | A | C | R | C | I | I |
| PHI Audit Logging & Encryption | I | C | R | C | C | I | A | I |
| CI/CD & DevOps Pipeline | I | C | A | C | R | I | I | I |
| Testing & Validation Execution | C | C | R | A | C | I | C | I |
| Security Testing & Pen Test Coordination | C | C | R | C | I | I | A | I |
| SOC 2 Type II Evidence Collection | I | C | R | C | I | I | A | I |
| Phased Facility Rollout | A | C | R | C | R | C | I | C |
| Per-Facility UAT Sign-Off | C | I | C | R | C | A | I | R |
| Knowledge Transfer & Training | R | A | R | I | C | C | I | C |
| As-Built Documentation | A | R | R | C | I | I | I | I |
| Hypercare Incident Response | A | C | R | I | R | C | I | I |

**Legend:** R = Responsible | A = Accountable | C = Consulted | I = Informed

## Key Personnel

**Amatra Delivery Team:**
- **Engagement Director / PM:** Overall program accountability, stakeholder communications, risk management, and milestone governance across all three phases
- **Lead Solutions Architect:** End-to-end technical ownership; architecture design, technical governance, cross-phase review, and escalation resolution
- **ML/AI Engineer (×2):** Custom model development (sepsis, readmission, rapid-response), SHAP explainability pipeline, and Amazon Bedrock LLM integration
- **Data Engineer (×2):** Kinesis ingestion pipeline, SageMaker Feature Store, HealthLake integration, and QuickSight analytics
- **Solutions Engineer (×2):** Epic FHIR R4 connector, HL7 v2.3 Mirth adapter, clinical dashboard, and alert routing system
- **Security Engineer:** HIPAA/SOC 2 compliance design, KMS encryption implementation, IAM/RBAC, CloudTrail audit logging, and security testing coordination
- **DevOps Engineer:** IaC (Terraform/CDK), CI/CD pipelines, observability stack, and compliance automation
- **QA Engineer:** Test plan development, functional/integration/performance/UAT coordination, and test results reporting
- **Technical Writer:** As-built documentation, runbooks, model cards, and FHIR specification documentation

**MedCore Stakeholder Team:**
- **Chief Medical Officer (CMO):** Executive sponsor; clinical outcomes accountability; Phase go/no-go approvals; model performance sign-off
- **Chief Information Officer (CIO):** Technical owner; infrastructure budget; IT and data engineering team resource commitment; environment access
- **Clinical Informatics Lead:** ML model feature definition, risk score threshold validation, alert workflow design, and clinical staff coordination
- **CISO / Privacy Officer:** HIPAA BAA governance, PHI data-handling sign-off, access controls review, and security testing gate approval
- **EHR Integration Lead:** Epic FHIR R4 API access provisioning, Mirth Connect adapter coordination, and real-time data feed validation
- **IT/Cloud Engineering Team:** AWS Organization access, account vending, network connectivity to on-premises Mirth Connect

---

# Architecture & Design

The MedCore Clinical Decision Support Platform is designed as a fully cloud-native, event-driven architecture on AWS, built to meet the strict latency, availability, and compliance requirements of a clinical-grade enterprise health system. The architecture prioritizes real-time data flow, model explainability, and defense-in-depth security across every layer.

## Architecture Overview

The platform is anchored on a real-time streaming pipeline that ingests clinical data from Epic via HL7 FHIR R4 subscription events and from Philips/GE bedside monitors via HL7 v2.3 over the existing Mirth Connect integration engine. Data flows through Amazon Kinesis Data Streams into a processing layer that normalizes, validates, and persists events to Amazon HealthLake (the HIPAA-eligible FHIR datastore) and the SageMaker Feature Store. From there, SageMaker real-time inference endpoints score each patient record as events arrive, with SHAP explainability values computed inline. Amazon Bedrock (Claude) generates a plain-language clinical narrative for every alert, which is then routed through Amazon SNS and EventBridge to the appropriate clinical role based on Cognito-enforced RBAC.

The platform deploys across two AWS regions — us-east-1 as the primary active region and us-west-2 as a passive disaster recovery region — with automated failover to meet the 99.95% availability SLA. All PHI data remains within US AWS regions at all times in compliance with HIPAA geographic data residency requirements. The deployment topology uses a dedicated AWS account under MedCore's Clinical Applications OU with network connectivity to on-premises Mirth Connect via a 1 Gbps AWS Direct Connect HA pair, backed by a site-to-site VPN for failover.

![Figure 1: Solution Architecture Diagram](../../assets/diagrams/architecture-diagram.png)

**Figure 1: MedCore CDS Platform — AWS Architecture** — End-to-end view of real-time clinical data ingestion, ML inference pipeline, LLM narrative generation, alert routing, and clinical dashboard layers with multi-AZ/multi-region HA topology.

## Component Architecture

The platform is composed of six functional layers, each implemented with AWS managed services to minimize operational overhead and maximize reliability:

**1. Ingestion Layer:** Amazon Kinesis Data Streams (10 shards) receives normalized HL7 events from two source adaptors — the Epic FHIR R4 API connector (OAuth 2.0 SMART on FHIR) and the HL7 v2.3 Mirth Connect adapter. Amazon MSK (3-broker cluster) provides internal event bus decoupling between the ingestion layer and downstream pipeline stages, with dead-letter queue handling for malformed messages.

**2. Storage & Feature Layer:** Amazon HealthLake provides the HIPAA-eligible FHIR R4-compliant PHI datastore with full-text search, longitudinal patient record storage, and native audit integration. SageMaker Feature Store maintains real-time online feature groups for inference (patient vitals, lab deltas, medication history) and offline feature groups for model retraining. Amazon RDS Aurora PostgreSQL (Multi-AZ) stores risk scores, alert history, and audit trails. Amazon ElastiCache Redis provides a sub-3-second patient context cache for the inference tier.

**3. ML Inference Layer:** Four SageMaker real-time inference endpoints serve the sepsis (Phase 1), 30-day readmission (Phase 2), rapid-response (Phase 2), and ensemble (Phase 3) models. SageMaker Pipelines orchestrate the weekly model retraining workflow from offline feature groups, with the SageMaker Model Registry governing version promotion. SHAP values are computed per inference call and included in every alert payload.

**4. LLM Narrative Layer:** Amazon Bedrock (Claude) receives structured alert payloads (risk score, model, SHAP factors, patient context) and returns a plain-language clinical narrative within the 3-second end-to-end SLA. Prompt templates are developed and validated by the Clinical Informatics Lead. Bedrock invocations are logged for quality monitoring and prompt version control.

**5. Alert & Application Layer:** Amazon EventBridge routes alert events to Amazon SNS for push notification delivery. AWS Lambda functions handle Epic FHIR write-back (posting CDS Hooks responses to the Epic workflow) and role-based alert suppression logic. The clinical dashboard is a React/AWS Amplify SPA serving risk score visualization, alert management, and model explanation views, with mobile-responsive design for bedside tablet use. Amazon Cognito enforces SAML 2.0 federation to Azure AD for SSO across all clinical roles.

**6. Analytics & Monitoring Layer:** Amazon Redshift (ra3.xlplus node) stores longitudinal patient outcomes for model performance tracking. Amazon QuickSight dashboards provide the Clinical Informatics Lead and Quality & Safety team with sepsis mortality trends, readmission rates, false-positive metrics, and model drift indicators. Amazon CloudWatch provides pipeline observability with latency alarms (3-second threshold), availability alarms (< 99.95%), and X-Ray distributed tracing for the inference path.

## Network Design

The platform's network topology is designed to ensure all PHI traffic travels exclusively over private, encrypted channels with no public internet traversal. The primary connectivity path is a 1 Gbps AWS Direct Connect hosted connection from MedCore's Nashville data center to AWS us-east-1, providing low-latency, dedicated bandwidth for Epic FHIR event streams and HL7 v2.3 Mirth Connect feeds. A site-to-site VPN serves as the secondary failover path to maintain connectivity during any Direct Connect disruption, supporting the 99.95% availability requirement.

Within AWS, all resources are deployed in private subnets within a multi-AZ VPC in us-east-1. AWS PrivateLink is used for communication between the application tier and AWS managed services (HealthLake, SageMaker, Bedrock, S3, Secrets Manager, KMS) to eliminate egress to the public internet for sensitive data paths. Two NAT Gateways (one per AZ) provide controlled outbound access for managed service control-plane calls. Application Load Balancers terminate HTTPS at the edge of the clinical dashboard and ML inference API tiers, with AWS WAF applying OWASP rulesets and healthcare-specific rules. The passive DR region (us-west-2) maintains replicated infrastructure via IaC-deployed standby, with Route 53 health checks driving automated DNS failover. Data egress between AWS and Epic's receiving endpoint uses TLS 1.2+ encryption.

## Security Design

The platform's security architecture implements defense-in-depth across three control planes aligned to HIPAA Security Rule Technical Safeguards:

**Preventative Controls:** All PHI data stores (HealthLake, RDS Aurora, S3, EBS, ElastiCache) are encrypted at rest using AWS KMS Customer Managed Keys (CMKs) owned and managed by MedCore. Separate CMKs are provisioned per data classification tier with annual automatic rotation enabled. All data in transit uses TLS 1.2+. IAM roles and Cognito user pools enforce least-privilege access per clinical role (nurse, physician, administrator, data scientist). AWS WAF protects ALBs and API Gateway endpoints with OWASP Top 10 and healthcare-specific rule groups. AWS Secrets Manager rotates RDS credentials, Epic API tokens, and integration keys automatically on a 30-day schedule, eliminating hardcoded credentials from any application code or IaC. Service Control Policies (SCPs) applied at the Clinical Applications OU level prevent accidental public exposure of S3 buckets or data stores.

**Detective Controls:** AWS CloudTrail provides an organization-level audit trail of all PHI access events with mandatory 7-year retention (per HIPAA). Amazon CloudWatch Logs aggregates application and infrastructure logs with sub-minute ingestion. Amazon GuardDuty provides continuous ML-driven threat detection across all accounts in the Clinical Applications OU. AWS Config with a custom HIPAA rule set monitors for configuration drift from the approved security baseline, with Security Hub aggregating findings. An Athena query layer on top of CloudTrail enables the CISO to perform ad-hoc PHI access audits within seconds.

**Responsive Controls:** Security Hub findings trigger automated remediation via AWS Config + Lambda for common drift scenarios (e.g., unencrypted storage volume creation, public S3 bucket policy). High and Critical GuardDuty findings trigger PagerDuty-integrated SNS notifications to the CISO team. The CI/CD pipeline blocks deployments that fail Snyk container security scans (container image scanning for ECS workloads) or AWS Config pre-deployment compliance checks.

## Data Architecture

Clinical data flows through four storage tiers, each optimized for its role in the pipeline:

**Hot Tier (Real-Time Inference):** Amazon ElastiCache Redis stores per-patient feature vectors and the most recent risk scores for sub-3-second inference. Cache TTL is set to the maximum clinical review window (4 hours for active inpatients). SageMaker Feature Store online feature groups provide the inference endpoint with pre-computed, normalized patient features.

**Warm Tier (Operational):** Amazon HealthLake is the system of record for all FHIR R4 patient data, supporting longitudinal record access and audit-compliant PHI storage. Amazon RDS Aurora PostgreSQL stores alert history, risk score timeseries, and operational metadata with Multi-AZ replication and daily automated snapshots (35-day retention). Amazon S3 (5 TB, us-east-1 + us-west-2 replication) stores raw HL7 event archives, ML model artefacts, and HIPAA audit exports, with S3 Object Lock (Compliance mode, 7-year WORM retention) for audit log immutability.

**Cold Tier (Analytics):** Amazon Redshift stores longitudinal patient outcomes (sepsis events, readmission instances, model predictions) for model performance monitoring and population health analytics. SageMaker Feature Store offline feature groups store historical feature snapshots for model retraining.

**Downstream Export:** A nightly Lambda-triggered ETL process exports readmission outcome data to MedCore's on-premises SQL Server 2016 data warehouse for operational reporting. This is a one-way, read-only export; no PHI is written back from the on-premises system.

All PHI is classified as restricted and governed by the HIPAA BAA with AWS. Data residency is enforced via SCP to prevent any PHI from leaving US AWS regions. PII/PHI de-identification for model development uses AWS-native tokenization and the HealthLake FHIR de-identification capability where applicable for research cohorts.

## Operational Design

**Observability:** Amazon CloudWatch provides the primary observability platform with custom dashboards tracking: (a) ingestion pipeline throughput and dead-letter queue depth; (b) SageMaker inference endpoint latency (P50/P95/P99 with 3-second alarm threshold); (c) Bedrock invocation latency; (d) ALB request rates and 5xx error rates; (e) GuardDuty and Config finding counts. AWS X-Ray provides distributed tracing across the entire inference path from Kinesis ingestion to Bedrock response, enabling root-cause analysis for latency breaches. Datadog APM and log management is deployed across all 20 ECS/SageMaker hosts for enhanced observability and real-time alerting, integrated with PagerDuty for on-call escalation.

**Backup and DR:** RDS Aurora automated snapshots run nightly with 35-day retention. S3 cross-region replication copies all critical data assets to us-west-2 in real time. HealthLake data is backed up via daily FHIR export to S3 (Object Lock). Redshift automated snapshots run nightly (7-day retention).

**Disaster Recovery:** The platform operates in an active/passive multi-region configuration. Route 53 health checks monitor primary region endpoint availability with a 30-second failover threshold. In the event of a primary region outage, Route 53 DNS failover promotes the us-west-2 passive standby within the RTO target. RTO target: ≤ 4 hours (clinical dashboard and inference restored). RPO target: ≤ 15 minutes (based on HealthLake export frequency and Aurora cross-region replication lag). The failover procedure is documented in the operational runbook and tested annually.

**Model Operations:** SageMaker Pipelines executes weekly model retraining from the offline Feature Store. Model drift is monitored via SageMaker Model Monitor, which triggers automated alerts when AUROC or alert precision fall below defined thresholds. The CI/CD pipeline enforces blue/green deployment for inference endpoint updates, with automated rollback triggered on latency breach (> 3 seconds P95) within the first 30 minutes post-deployment.

## Tooling Overview

The following table summarizes the primary tools used across all delivery and operational dimensions of the engagement. Tool selection is driven by HIPAA compliance requirements, native AWS integration, and MedCore's existing technology footprint.

<!-- TABLE_CONFIG: widths=[28, 37, 35] -->
| Category | Primary Tools | Purpose |
|----------|---------------|---------|
| Infrastructure as Code | Terraform / AWS CDK | All environment provisioning; enforces no manual console changes in production |
| CI/CD & Deployment | AWS CodePipeline / CodeBuild | Application and model deployment pipelines; blue/green inference endpoint rollout |
| ML Platform | SageMaker Pipelines, Feature Store, Model Registry | Model training orchestration, feature management, and model versioning |
| LLM Integration | Amazon Bedrock (Claude) | Clinical narrative generation for bedside alert summaries |
| Data Ingestion | Kinesis Data Streams, MSK (Kafka) | Real-time HL7 FHIR and HL7 v2.3 event streaming and internal event bus |
| PHI Datastore | Amazon HealthLake | HIPAA-eligible FHIR R4 datastore and audit-compliant PHI persistence |
| Application Runtime | Amazon ECS (Fargate), AWS Lambda | Containerised app tier and serverless alert dispatch |
| Observability | CloudWatch, X-Ray, Datadog APM | Pipeline latency monitoring, distributed tracing, and on-call alerting |
| Security & Compliance | GuardDuty, Config, Security Hub, Snyk | Threat detection, compliance posture, and container security scanning |
| Identity | Amazon Cognito, Azure AD (SAML 2.0) | SSO federation and RBAC enforcement for all clinical roles |
| Encryption & Secrets | AWS KMS, Secrets Manager | PHI encryption key management and credential rotation |
| Audit & Forensics | CloudTrail, CloudWatch Logs, Athena | HIPAA PHI access audit trail with 7-year retention and CISO query access |
| Analytics | Amazon Redshift, QuickSight | Longitudinal outcomes warehouse and model performance dashboards |

---

# Security & Compliance

MedCore Health Systems is a HIPAA-covered entity and HITECH-obligated organization with an active BAA with AWS. Every design decision in this platform is made with regulatory compliance as a first-class requirement. This section defines the operational security controls, compliance frameworks, and governance processes that the Amatra team will implement.

## Identity & Access Management

Access to the CDS platform is governed by a Cognito-based RBAC model federated to MedCore's existing Azure Active Directory via SAML 2.0. This ensures that all clinical staff authenticate with their existing MedCore SSO credentials and multi-factor authentication policy — no separate credentials are issued for the CDS platform. Four distinct clinical role types are enforced: **Nurse** (view risk scores and alerts for assigned patients only), **Physician/Hospitalist** (view risk scores and full model explanations for their patient panel), **Administrator** (alert management, threshold configuration, and reporting access), and **Data Scientist** (SageMaker and Feature Store access for model development; no direct PHI access in production).

IAM roles follow strict least-privilege design: each service (ECS task, Lambda function, SageMaker endpoint) is granted only the specific API permissions required for its function, with no wildcard actions or resource ARNs. Cross-account access for the CDS account within MedCore's AWS Organization uses IAM Roles with external ID conditions. AWS IAM Access Analyzer is enabled to continuously identify any overly permissive resource policies. Privileged access to production AWS console is restricted to break-glass IAM roles with CloudTrail logging of every action.

## Monitoring & Threat Detection

Amazon GuardDuty is enabled across all accounts in the Clinical Applications OU, providing continuous ML-driven threat detection for unusual API patterns, credential compromise indicators, and network-level anomalies. Findings are aggregated in AWS Security Hub alongside AWS Config compliance findings, Inspector vulnerability assessments, and Macie PHI data classification alerts. Security Hub findings at High and Critical severity trigger SNS notifications to the CISO's on-call rotation via PagerDuty. CloudWatch dashboards provide real-time visibility into authentication anomalies (failed Cognito logins, unusual access patterns), pipeline error rates, and model performance indicators. Datadog APM monitors all ECS tasks and SageMaker endpoints with APM-level traces, enabling detection of anomalous API call patterns or latency spikes that could indicate either operational or security events.

## Compliance & Auditing

The platform is designed to satisfy three regulatory frameworks: **HIPAA Security Rule** (Technical Safeguards §164.312), **HITECH Breach Notification requirements**, and **SOC 2 Type II** (Trust Services Criteria: CC6 Logical Access, CC7 System Operations, A1 Availability). An organization-level AWS CloudTrail trail records every API call — including all PHI access events — with immutable delivery to an S3 bucket with Object Lock (7-year WORM retention per HIPAA). An Athena query layer on top of CloudTrail enables the CISO and Privacy Officer to run ad-hoc PHI access reports (who accessed what PHI, when, from which IP) within seconds. AWS Config rules continuously evaluate over 30 HIPAA-specific configuration controls, generating compliance evidence automatically for SOC 2 Type II audits. Security Hub collects all findings in a single audit pane. A dedicated compliance evidence package (CloudTrail exports, Config snapshots, access control reports) is produced as a formal deliverable for MedCore's SOC 2 Type II program.

## Encryption & Key Management

All PHI at rest is encrypted using AWS KMS Customer Managed Keys (CMKs) owned and managed by MedCore. Separate CMKs are provisioned per data store (HealthLake, RDS Aurora, S3 audit bucket, S3 data lake, EBS volumes, ElastiCache), ensuring blast-radius isolation in the event of a key compromise. All CMKs have automatic annual rotation enabled. KMS key policies are scoped to the minimum set of IAM principals required, with MedCore's CISO holding administrative key access. All PHI in transit uses TLS 1.2+ on every communication path: Kinesis producers, HealthLake API, SageMaker endpoints, Bedrock API calls, ALB HTTPS listeners, and Direct Connect MACsec where supported. AWS Secrets Manager stores and automatically rotates all application secrets (RDS credentials, Epic OAuth tokens, Mirth Connect integration keys) on a 30-day rotation schedule, eliminating hardcoded credentials from any application code or IaC.

## Governance

Platform governance is enforced through three mechanisms: **Infrastructure as Code mandate** (all production changes must be deployed via CodePipeline from version-controlled Terraform/CDK; no manual console changes permitted, enforced via SCP denying direct resource modification in production accounts); **Continuous compliance monitoring** (AWS Config rules alert on any drift from the approved HIPAA configuration baseline within 15 minutes of detection); and **Change management process** (all production changes follow a documented change request process with CISO review for security-impacting changes and CIO approval for infrastructure changes).

A formal quarterly access review process (60-day cadence during the rollout period) ensures that clinical role assignments in Cognito and IAM policies remain accurate as staff changes occur. Separation of duties is enforced: the team building the platform (Amatra engineers) does not have standing production access — production deployments are executed via CI/CD with MedCore CIO approval gates. All AWS Config non-compliant findings must be remediated within defined SLAs: Critical within 24 hours, High within 7 days, Medium within 30 days.

## Environments & Access

### Environment Strategy

<!-- TABLE_CONFIG: widths=[15, 28, 27, 30] -->
| Environment | Purpose | Access Control | Data |
|-------------|---------|----------------|------|
| Development | Feature development and unit testing for all platform components | Amatra engineers (full access via IAM role); no PHI permitted | Synthetic/generated test data only; no real patient records |
| QA | Integration testing, regression testing, and FHIR API validation | Amatra QA + Security Engineers; MedCore EHR Integration Lead (read-only) | De-identified synthetic PHI from HealthLake FHIR de-identification tool |
| Staging | Full system integration testing, performance testing, and UAT | Amatra delivery team + MedCore Clinical Informatics Lead and CISO | De-identified PHI subset; volume representative of production load |
| Production | Live clinical workloads; active patient risk scoring | MedCore clinical roles (Cognito/Azure AD SSO); Amatra break-glass access only (CloudTrail logged) | Live PHI — full HIPAA controls enforced; encrypted at rest and in transit |

### Access Policies

Production access for Amatra engineers is restricted to a break-glass IAM role requiring MedCore CIO written approval, activated only for incident response or scheduled maintenance windows. All break-glass sessions are logged to CloudTrail with email notification to the CISO. Standing production console access is not granted to any Amatra team member post-go-live. MedCore IT operations team holds standard operational access to production via SSO-federated IAM roles with least-privilege policy. Cognito user pools enforce session token expiry (8-hour clinical shift alignment) and SAML assertion re-authentication for extended sessions.

---

# Testing & Validation

Clinical software validation requires a rigorous testing program that addresses not only standard software quality assurance but also ML model clinical accuracy, HIPAA security controls, and the specific patient safety stakes of a real-time clinical decision support system. All testing phases are governed by a formal Test Plan approved by the Clinical Informatics Lead and CISO before execution begins.

## Functional Validation

Functional testing validates that every component of the platform behaves correctly according to its specification. The Amatra QA team will execute functional test cases across three areas: (1) **Data Ingestion Pipeline** — validating that FHIR R4 events and HL7 v2.3 messages are correctly parsed, normalized, schema-validated, and stored in HealthLake and the Feature Store; (2) **ML Inference Endpoints** — validating that each model produces correctly structured risk score outputs, SHAP explanation values, and Bedrock narrative payloads within the 3-second SLA; and (3) **Clinical Dashboard** — validating that all four clinical role types (nurse, physician, administrator, data scientist) see the correct views, alert lists, and patient data scoped to their assigned patients. Acceptance criteria are defined per component in the Test Plan and signed off by the Clinical Informatics Lead. All functional test cases are automated where possible and version-controlled in the CI/CD pipeline.

## Performance & Load Testing

Performance testing validates that the platform meets its non-functional SLAs under realistic and peak production load conditions. Amatra will simulate the full 18-hospital concurrent patient event load using production-representative synthetic data — approximately 2,500+ concurrent active inpatient records, 10M+ Kinesis events/month, and peak vitals stream bursts from all bedside monitors simultaneously. The primary performance acceptance criterion is **end-to-end latency < 3 seconds** from Kinesis event arrival to risk score + Bedrock narrative delivery to the alert routing tier at P95 under peak load. Secondary metrics include Kinesis shard throughput headroom (≥ 30% spare capacity at peak), SageMaker endpoint CPU/memory utilization (< 70% at peak), and Bedrock invocation latency (< 1.5 seconds). Load testing tooling: AWS Distributed Load Testing solution and Locust for FHIR API simulation.

## Security Testing

Security testing validates that all HIPAA Technical Safeguard controls are correctly implemented before any production PHI is processed. Amatra's Security Engineer will execute the HIPAA security controls validation checklist, covering: encryption at rest (KMS CMK validation across all PHI stores), encryption in transit (TLS 1.2+ verification on all API paths), access control enforcement (validating that each Cognito role can only access its permitted data scope), audit logging completeness (validating that every PHI access event is captured in CloudTrail with the required fields), and secrets management (validating that no credentials are stored in plaintext in code, environment variables, or logs). Following internal validation, Amatra will coordinate a scoped **external penetration test** by an approved third-party firm. The pen test scope covers the CDS platform boundary: ALBs, Cognito endpoints, API Gateway, and the Kinesis ingestion endpoint. All Critical and High findings from the pen test must be fully remediated before the CISO grants production go-live approval.

## Disaster Recovery & Resilience Tests

To validate the 99.95% availability SLA, Amatra will execute two resilience tests: (1) **AZ Failover Test** — simulate the loss of one Availability Zone in us-east-1 by forcing a controlled AZ evacuation, validating that ALBs, RDS Aurora Multi-AZ, and ECS Fargate task replacement restore service within 5 minutes with no alert delivery gaps; and (2) **Region Failover Test** — simulate a full primary region (us-east-1) failure using Route 53 health check suppression, validating that DNS failover to the us-west-2 passive standby occurs within the target RTO of ≤ 4 hours and that the RPO of ≤ 15 minutes is achieved based on HealthLake export freshness and Aurora replication lag at time of failure. Both tests are executed in a staging environment and results are documented in the Test Results Report. Pass criteria require successful restoration within RTO/RPO targets with no permanent PHI data loss.

## User Acceptance Testing

User Acceptance Testing (UAT) is the clinical validation gate that confirms the platform meets the real-world workflow needs of MedCore's nursing and physician staff before any facility goes live. UAT is conducted at the designated Phase 1 pilot facility before the 2026-10-31 go-live, and the same process repeats facility-by-facility during Phase 3 enterprise rollout. The Amatra PM coordinates UAT sessions structured as facilitated clinical workflow walk-throughs with nurses, hospitalists, and administrators using the CDS dashboard in the staging environment with de-identified PHI. Test scenarios are defined jointly with the Clinical Informatics Lead and cover: alert receipt and review (from notification to patient context drill-down); risk score interpretation and SHAP explanation review; model narrative quality assessment; alert dismissal and acknowledgement workflows; and role-based access control (confirming nurses cannot access physician-tier views and vice versa). UAT feedback is captured in a structured scoring rubric. The Clinical Informatics Lead must sign off on UAT results before Phase 1 production activation.

## Go-Live Readiness

Before any facility is activated for live clinical use, the following readiness gate criteria must be met and formally documented:

- [ ] All Critical and High functional defects resolved and regression-tested
- [ ] End-to-end latency < 3 seconds validated at peak load (performance test pass)
- [ ] Multi-AZ failover test passed (< 5-minute recovery)
- [ ] HIPAA security controls validation checklist signed off by CISO
- [ ] All Critical and High pen test findings fully remediated and re-tested
- [ ] Sepsis model AUROC ≥ 0.85 validated on held-out clinical dataset and signed off by Clinical Informatics Lead
- [ ] LLM narrative quality signed off by ≥ 5 clinical reviewers
- [ ] UAT pilot facility sign-off obtained from CMO representative
- [ ] AWS CloudTrail audit logging validated end-to-end for all PHI access event types
- [ ] Operational runbooks reviewed and approved by MedCore IT Operations
- [ ] Rollback procedure tested and documented
- [ ] CMO and CIO formal go-live approval recorded

## Cutover Plan

Production cutover for Phase 1 (2026-10-31) will follow a blue/green deployment approach. On cutover day, the new sepsis model inference endpoint and ingestion pipeline will be promoted to "green" production while the existing rule-based alert system remains active in parallel ("blue") for a 48-hour shadow period. During shadow mode, the CDS platform generates alerts internally but does not deliver them to clinical staff — Amatra engineers and the Clinical Informatics Lead monitor alert volume, latency metrics, and model output quality against a pre-defined acceptance threshold. After 48-hour shadow validation, the Clinical Informatics Lead authorizes the flip of clinical alert delivery from the rule-based system to the CDS platform. The rule-based system remains available for a further 2-week standby period before formal decommission sign-off.

## Rollback Strategy

Rollback is triggered automatically by the CI/CD pipeline if the P95 inference latency exceeds 3 seconds within 30 minutes of a new endpoint deployment. Manual rollback can be initiated by the Amatra Tech Lead or MedCore CIO at any time during the cutover window by executing the documented rollback runbook. Rollback restores the previous SageMaker endpoint version (retained in the Model Registry) and reverts the Kinesis consumer Lambda configuration via a single CodePipeline execution. Target rollback time: ≤ 15 minutes. The rule-based alert system remains active in parallel during Phase 1 hypercare as the clinical safety backstop. Model rollback is a distinct procedure from infrastructure rollback and is documented separately in the ML Operations runbook.

---

# Handover & Support

A structured handover and enablement program ensures that MedCore's IT, data engineering, and clinical teams are fully equipped to operate, maintain, and evolve the CDS platform after Amatra's engagement concludes. Handover activities are integrated into the Phase 3 rollout timeline and are not a post-project afterthought.

## Handover Artifacts

The following documentation and asset packages will be formally transferred to MedCore at engagement completion:

- **As-Built Architecture Document** — final architecture diagrams, component inventory, VPC/subnet configuration, and infrastructure decision log
- **IaC Repository** — all Terraform/CDK modules, environment configuration files, and pipeline definitions committed to MedCore's version-controlled repository (GitHub or AWS CodeCommit)
- **ML Model Cards** — one model card per trained model (sepsis, readmission, rapid-response) documenting: training data, feature list, AUROC/sensitivity/specificity, known limitations, retraining schedule, and bias/fairness assessment
- **FHIR Resource Mapping Specification** — complete mapping of Epic FHIR R4 resource fields to SageMaker Feature Store schema
- **Data Flow Diagrams** — end-to-end data lineage from Epic/Mirth to HealthLake, Feature Store, Redshift, and downstream SQL Server export
- **Security Architecture Document** — KMS key inventory, IAM role catalogue, SCP list, Cognito configuration, and HIPAA control mapping
- **Operational Runbooks** — procedures for ingestion pipeline failure, SageMaker endpoint latency breach, Bedrock quota exhaustion, Direct Connect failover, and model rollback
- **HIPAA Compliance Evidence Package** — CloudTrail exports, Config snapshots, and access control reports for SOC 2 Type II audit
- **Test Results Report** — comprehensive test execution results, model validation metrics, pen test findings and remediation evidence
- **Training Materials** — recorded knowledge transfer sessions, clinical staff training slides, and facilitator guide for future train-the-trainer delivery

## Knowledge Transfer

Amatra will deliver a structured, two-track knowledge transfer program:

**Technical Track (MedCore IT & Data Engineering):** Four half-day sessions covering: (1) Platform architecture and IaC module walkthrough — how to modify and re-deploy infrastructure safely; (2) SageMaker pipeline operations — initiating ad-hoc retraining, promoting models via the Registry, and interpreting Model Monitor drift alerts; (3) Kinesis and MSK pipeline troubleshooting — dead-letter queue handling, shard scaling, and MSK broker health monitoring; and (4) Incident response procedures — using the operational runbooks for each major failure scenario, interpreting CloudWatch and Datadog dashboards, and executing the rollback procedures. All sessions are recorded and delivered to MedCore alongside session notes.

**Clinical Track (Clinical Staff Enablement):** A train-the-trainer model is used for all 18 facilities. Amatra delivers the master training program to a cohort of facility-level Clinical Champions (typically senior nurses and charge nurses nominated by each facility's Nursing Director) in a two-day facilitated session. Clinical Champions then deliver the training locally at their facility. Training content covers: dashboard navigation and risk score interpretation; understanding and acting on SHAP explanation factors; alert acknowledgement, escalation, and dismissal workflows; and feedback submission for model quality improvement.

## Hypercare Support

Following General Availability (Q3 2027), Amatra will provide **8 weeks of post-go-live hypercare support** with the following terms:

- **Coverage:** Extended business hours plus on-call support — Monday–Friday 7am–10pm ET, with on-call paging for Critical incidents outside hours
- **Response SLAs:** Critical (patient safety impact or platform unavailability) — 1-hour response, 4-hour resolution target; High (alert delivery degraded, model latency elevated) — 4-hour response, next-business-day resolution target; Medium/Low — 2-business-day response
- **Scope:** Defect resolution for issues originating from the delivered solution, configuration assistance, and model performance monitoring. Change requests (new features, additional models, scope additions) are out of hypercare scope and require a separate work order.
- **Team:** Senior Support Engineer (dedicated to MedCore); escalation path to Amatra Lead Solutions Architect for complex issues
- **Handover at Hypercare End:** Full transition to MedCore IT Operations with all escalation paths documented. Optionally transitions to an Amatra Managed Services Agreement if ongoing managed support is desired.

## Managed Services Transition

Ongoing managed services are not included in this engagement. Following hypercare, MedCore's IT and data engineering teams will operate the platform with the support of the delivered documentation and runbooks. Amatra offers an optional **Managed Services Agreement (MSA)** covering: 24/7 platform monitoring and incident response, monthly model retraining oversight, quarterly model performance reviews, AWS cost optimization recommendations, and security patching for ECS container images. MedCore should contact their Amatra Engagement Director to discuss MSA scope and pricing if ongoing managed support is desired.

## Assumptions

This engagement proceeds on the basis of the following assumptions. Material changes to these assumptions may require scope, timeline, or commercial adjustment via the change control process:

1. MedCore will provide Amatra with timely access to the Epic FHIR R4 API sandbox environment (within 2 weeks of project kickoff) and production Epic API credentials at least 4 weeks before Phase 1 go-live.
2. MedCore's IT team will complete AWS account vending for the dedicated CDS AWS account (within Clinical Applications OU) within 2 weeks of project kickoff.
3. MedCore will provide access to a representative de-identified clinical dataset (minimum 2 years of historical sepsis, readmission, and rapid-response events) for ML model training within 4 weeks of discovery phase completion.
4. The Clinical Informatics Lead will be available for at minimum 8 hours per week during the Discovery and ML Model Development phases to review feature definitions, validate risk thresholds, and sign off on model accuracy.
5. MedCore's CISO will complete BAA execution with AWS before the Development phase begins.
6. The 1 Gbps AWS Direct Connect circuit will be procured by MedCore and available for testing by Week 8 of the engagement. Direct Connect provisioning lead times are MedCore's responsibility.
7. MedCore's Mirth Connect integration engine will be accessible from the AWS environment via Direct Connect/PrivateLink during development and will be available for integration testing.
8. Per-facility Epic FHIR subscription configuration and Mirth adapter deployment at each of the 18 hospitals will be coordinated and executed by MedCore's EHR Integration Lead with Amatra guidance.
9. Clinical Champion nominations for the train-the-trainer program will be confirmed by MedCore at least 6 weeks before Phase 3 rollout commences.
10. The Joint Commission accreditation review timeline (November 2026) is firm; any client-side delays to the Phase 1 deliverable timeline will require a formal schedule re-baseline.
11. Azure Active Directory SAML 2.0 metadata and MedCore's identity administrator will be available for SSO configuration testing within 2 weeks of Environment Setup phase completion.
12. MedCore's IT security team will have budget approval for the AWS Business Support tier upgrade before the end of the Planning phase.
13. All MedCore stakeholder approvals (go/no-go gates, test sign-off, UAT acceptance) will be provided within 5 business days of deliverable submission.

## Dependencies

The following dependencies are on the critical path for this engagement. Each dependency has a designated owner and a required-by date; delays to any of these items will trigger a formal risk escalation and potential schedule re-baseline discussion with the MedCore CIO.

| Dependency | Owner | Required By |
|------------|-------|-------------|
| AWS account for Clinical Applications OU CDS platform provisioned | MedCore CIO / IT | Week 2 |
| Epic FHIR R4 API sandbox access granted to Amatra | EHR Integration Lead | Week 2 |
| AWS BAA executed between MedCore and AWS | CISO | Before Development phase (Week 6) |
| De-identified clinical training dataset (sepsis history) provided | Clinical Informatics Lead | Week 9 |
| 1 Gbps Direct Connect circuit provisioned and tested | MedCore IT / AWS | Week 8 |
| Mirth Connect server accessible from AWS (PrivateLink/Direct Connect) | MedCore IT / EHR Integration Lead | Week 10 |
| Azure AD SAML metadata and IDP configuration | MedCore IT / Identity Admin | Week 10 |
| Pilot facility selected and facility UAT champion named | CMO / Clinical Informatics Lead | Week 18 |
| Phase 3 facility rollout schedule and Clinical Champions confirmed | CMO / Nursing Directors | Week 30 |
| Pen test firm selected and scoping complete | CISO | Week 30 |

---

# Investment Summary

**Large-Scale Enterprise Implementation:** This pricing reflects a full-scope, three-phase clinical AI platform engagement — 18 hospitals, 4,200+ clinical staff users, three custom ML models, enterprise HIPAA/SOC 2 compliance, and phased enterprise rollout. This is a complex, regulated healthcare AI program with a hard regulatory deadline (Phase 1: Joint Commission accreditation, November 2026).

The investment covers all professional services across the full engagement lifecycle (Discovery through Hypercare), AWS cloud infrastructure for three years, software licenses, enterprise connectivity, and AWS Business Support. Professional services are Year 1 only (build engagement); infrastructure and support costs recur annually.

## Total Investment

The table below reconciles all cost categories across the three-year program horizon. Professional Services figures are derived from the Level of Effort Estimate (4,415 hours; list cost $928,100 before credits). Infrastructure, Software, Connectivity, and Support figures are derived from the Infrastructure Costs schedule (3-year total $803,514 before credits).

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[24, 12, 12, 12, 10, 10, 13] -->
| Cost Category | Year 1 List | Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------|------------|--------|--------|--------------|
| Professional Services | $928,100 | ($42,500) | $885,600 | $0 | $0 | $885,600 |
| Cloud Infrastructure | $233,280 | ($38,000) | $195,280 | $233,280 | $260,498 | $689,058 |
| Software Licenses | $7,920 | ($2,400) | $5,520 | $7,920 | $7,920 | $21,360 |
| Connectivity | $9,432 | $0 | $9,432 | $9,432 | $9,432 | $28,296 |
| Support & Maintenance | $21,600 | $0 | $21,600 | $21,600 | $21,600 | $64,800 |
| **TOTAL INVESTMENT** | **$1,200,332** | **($82,900)** | **$1,117,432** | **$272,232** | **$299,450** | **$1,689,114** |
<!-- END COST_SUMMARY_TABLE -->

*Note: Year 2 and Year 3 figures represent recurring infrastructure and software costs only. Professional services are a one-time Year 1 investment for the build engagement.*

## Partner Credits

A total of **$82,900 in credits** are applied in Year 1, delivering meaningful savings on the initial investment:

- **AWS MAP Credit ($15,000):** AWS Migration Acceleration Program credit applied to Year 1 cloud infrastructure consumption for this net-new AWS workload deployment.
- **AWS HealthLake Launch Credit ($5,000):** AWS healthcare sector program credit for HealthLake and Bedrock usage in Year 1, available to qualifying HIPAA-covered entity implementations.
- **Reserved Instance Savings ($18,000):** 1-year Reserved Instance commitment on SageMaker, RDS Aurora, ElastiCache, and MSK instances, providing approximately 30% discount on committed resources.
- **AWS Partner Services Credit ($15,000):** APN Advanced Tier services credit for solution architecture and ML platform implementation applied to professional services.
- **AWS Healthcare Competency Credit ($10,000):** Partner credit for HIPAA-compliant solution delivery under Amatra's AWS Healthcare Competency designation.
- **Implementation Volume Discount ($12,500):** ~5% professional services volume discount on engagements exceeding $1M total PS spend.
- **Datadog Partner Credit ($2,400):** Datadog AWS ISV partner program — 4 months free on the 20-host APM subscription.
- **Training & Enablement Credit ($5,000):** AWS Training credit applied toward MedCore IT and data engineering enablement sessions (SageMaker, Kinesis, HealthLake modules).

## Cost Components

**Professional Services — $885,600 net (4,415 hours)**
The professional services investment covers the complete engagement delivery team across all five phases: Discovery & Architecture Design (Weeks 1–5), Environment Build & Data Pipeline (Weeks 6–14), ML Model Development & Integration (Weeks 8–20), Testing & Validation (Weeks 18–24), and Production Rollout & Hypercare (Weeks 22+). The largest cost drivers are ML model development (~570 hours at ML/AI Engineer rates of $275/hr for three custom models + Bedrock integration) and EHR integration (~216 hours for Epic FHIR R4 and Mirth Connect adapters). The 8-week hypercare period (192 hours at Support Engineer rates) is included. Management overhead (PM + Solution Architect technical leadership) is applied at 10% of engineering hours per standard engagement practice.

**Cloud Infrastructure — $195,280 net Year 1 ($689,058 over 3 years)**
The largest infrastructure cost drivers are Amazon HealthLake ($21,600/yr), SageMaker inference endpoints ($20,160/yr), Amazon Bedrock ($16,800/yr growing to $19,320 in Year 3), SageMaker training jobs ($8,160/yr), Amazon MSK ($7,740/yr), and Amazon Redshift ($7,800/yr). Kinesis, RDS Aurora, ElastiCache, ECS Fargate, and supporting services account for the remainder. Year 3 infrastructure costs are higher than Year 2 due to SageMaker endpoint complexity growth, Bedrock token volume growth, and Kinesis/HealthLake throughput growth as all 18 facilities reach full utilization. The steady-state monthly run rate at full utilization is approximately $19,500/month, within MedCore's stated budget of $18,000–$24,000/month.

**Connectivity — $28,296 over 3 years**
The 1 Gbps Direct Connect hosted connection ($750/month) provides the dedicated private link from MedCore's Nashville data center to AWS us-east-1 for Epic FHIR event ingestion and HL7 v2.3 Mirth Connect feeds. A site-to-site VPN ($36/month) provides the secondary failover path. These are recurring annual costs.

**Software Licenses — $21,360 over 3 years**
Datadog APM and log management ($372/month for 20 hosts, net of Datadog partner credit in Year 1) provides enhanced observability beyond CloudWatch. Snyk container security scanning ($300/month) provides shift-left HIPAA security posture for ECS container images.

**AWS Business Support — $64,800 over 3 years**
AWS Business Support (~$1,800/month estimated at 10% of monthly infrastructure) provides 24/7 access to AWS Support Engineers with < 1-hour Critical response time — mandatory for a clinical production platform with 99.95% SLA obligations.

## Payment Terms

Professional services will be invoiced against the following milestone schedule:

| Milestone | Invoice Trigger | Amount |
|-----------|----------------|--------|
| Project Kickoff | Upon SOW execution and kickoff meeting completion | 20% — $177,120 |
| Architecture Approved (M2) | HLD/LLD/Security Architecture documents accepted | 20% — $177,120 |
| Data Pipeline Live (M4) | Real-time ingestion flowing to HealthLake and Feature Store | 20% — $177,120 |
| Phase 1 Go-Live (M5) | Sepsis model live in production (2026-10-31) | 20% — $177,120 |
| Enterprise GA (M8) | 18-hospital rollout complete (Q3 2027) | 15% — $132,840 |
| Hypercare End (M9) | 8-week hypercare period concluded | 5% — $44,280 |
| **Total Professional Services** | | **$885,600** |

Cloud infrastructure costs are invoiced directly by AWS to MedCore on the standard AWS billing cycle (monthly, arrears). Credits will be applied by AWS to MedCore's AWS account as per program terms.

## Invoicing & Expenses

Amatra invoices will be issued within 5 business days of each milestone acceptance, with payment terms of Net-30 from invoice date. All invoices will reference this SOW and the Opportunity Number (OPP-2026-0047). Reasonable and pre-approved travel expenses (for on-site discovery, UAT facilitation, and facility rollout coordination) will be reimbursed at cost without markup, subject to MedCore's standard travel policy. Amatra will submit expense receipts with each milestone invoice for the relevant period. All expense estimates above $500 will be pre-approved by the MedCore CIO before incurring the expenditure.

---

# Terms & Conditions

The terms governing this engagement provide the commercial and legal framework within which both parties will operate. These terms are intended to be read alongside MedCore Health Systems' Master Services Agreement (MSA) with Amatra, which takes precedence in the event of any conflict.

## General Terms

This Statement of Work is governed by and incorporated into the Master Services Agreement executed between MedCore Health Systems and Amatra ("MSA"). All general terms including liability, indemnification, insurance, and dispute resolution are defined in the MSA. This SOW defines the specific scope, deliverables, and commercial terms for the MedCore Clinical Decision Support Platform engagement (Opportunity OPP-2026-0047). In the event of any conflict between this SOW and the MSA, the MSA shall prevail unless this SOW explicitly states otherwise.

## Scope Changes

Any request to materially change the scope defined in this SOW — including additions to the ML model portfolio, expansion of the facility scope, changes to compliance framework requirements, or timeline acceleration — must be submitted as a formal Change Request (CR). Amatra will evaluate each CR and provide a written Change Order within 5 business days, specifying any impact to timeline, cost, and resource allocation. No out-of-scope work will be performed without a fully executed Change Order signed by the MedCore CIO (for technical scope changes) or CMO (for clinical scope changes). Minor clarifications that do not impact cost, timeline, or resource allocation may be accommodated informally at Amatra's discretion and documented in the weekly status report.

## Intellectual Property

All deliverables produced specifically for MedCore under this SOW — including custom ML models, trained model weights, FHIR connectors, clinical dashboard source code, IaC modules, and project documentation — are work-for-hire and become the property of MedCore Health Systems upon receipt of final payment. Amatra retains ownership of its pre-existing methodologies, frameworks, tools, accelerators, and the EO Framework used to structure and deliver this engagement. Any Amatra IP incorporated into deliverables is licensed to MedCore on a perpetual, royalty-free, non-exclusive basis for the purpose of operating and maintaining the CDS platform. Open-source components are governed by their respective licenses, which will be documented in the as-built documentation.

## Service Levels

Amatra warrants that the delivered platform will meet the performance specifications defined in this SOW (99.95% availability, < 3-second inference latency) for a period of **90 days** following the Phase 3 General Availability milestone. During this warranty period, Amatra will remedy any defects that cause the platform to materially fail the specified performance criteria at no additional cost. The 8-week hypercare support included in this SOW operates under the response SLAs defined in Section 9 (Handover & Support). Warranty and hypercare coverage apply to the software and configuration delivered by Amatra; issues caused by MedCore infrastructure changes, Epic API modifications, or AWS service outages are not covered.

## Liability

Each party's total aggregate liability arising from this SOW shall be limited to the total fees paid or payable by MedCore to Amatra in the twelve (12) months preceding the event giving rise to the claim, as specified in the MSA. Neither party shall be liable for any indirect, consequential, special, or punitive damages. These limitations do not apply to liability arising from: (i) a party's gross negligence or wilful misconduct; (ii) breach of confidentiality or data protection obligations; or (iii) intellectual property indemnification obligations. Amatra maintains professional liability (errors and omissions) insurance of no less than $2,000,000 per occurrence throughout the duration of this engagement.

## Confidentiality

All patient data, clinical workflows, business processes, and technical information shared by MedCore with Amatra under this engagement are considered Confidential Information and are subject to the non-disclosure obligations in the MSA and the HIPAA BAA. Amatra's access to PHI is strictly limited to the minimum necessary for the purposes of platform implementation and testing, as defined in the BAA. All Amatra personnel with access to PHI or MedCore confidential information are required to complete HIPAA awareness training before accessing MedCore systems or data. Confidentiality obligations survive termination of this SOW by a period of five (5) years, consistent with the MSA.

## Termination

Either party may terminate this SOW for material breach with 30 days' written notice, provided the breaching party has not cured the breach within that 30-day period. MedCore may terminate this SOW for convenience with 30 days' written notice, in which case MedCore shall pay Amatra for all work completed to the date of termination at the rates specified herein, plus reasonable and documented wind-down costs. Termination does not relieve either party of obligations already accrued as of the termination date. All MedCore-owned deliverables completed to the termination date will be transferred to MedCore within 10 business days of termination, subject to receipt of all outstanding payments.

## Governing Law

This SOW and all disputes arising from it shall be governed by the laws of the State of Tennessee, consistent with MedCore's headquarters jurisdiction, without regard to conflict of laws principles. The parties agree to submit to the exclusive jurisdiction of the courts located in Davidson County, Tennessee for any legal proceedings arising from this SOW that cannot be resolved through the dispute resolution process in the MSA.

---

# Sign-Off

By signing below, both parties confirm they have read and understood this Statement of Work and agree to be bound by its scope, deliverables, timeline, roles, terms, and commercial obligations. This SOW is effective as of the date of the last signature below.

**Client Authorized Signatory — MedCore Health Systems:**

Name: __________________________
Title: __________________________
Signature: ______________________
Date: __________________________

**Service Provider Authorized Signatory — Amatra:**

Name: __________________________
Title: __________________________
Signature: ______________________
Date: __________________________

---

*This Statement of Work, together with the Master Services Agreement between MedCore Health Systems and Amatra, constitutes the complete agreement between the parties for the professional services described herein and supersedes all prior negotiations, representations, proposals, or agreements relating to the subject matter of this engagement. Any amendments to this SOW must be made in writing and signed by authorized representatives of both parties.*
