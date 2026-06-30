---
document_title: Detailed Design Document
solution_name: MedCore Clinical Decision Support Platform
document_version: "1.0"
author: Amatra Lead Solutions Architect
last_updated: 2025-06-18
technology_provider: aws
client_name: MedCore Health Systems
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Detailed Design Document (DDD) defines the complete technical blueprint for the MedCore Clinical Decision Support (CDS) Platform — an AWS-hosted, event-driven AI/ML system that delivers real-time patient risk scoring, LLM-powered clinical narratives, and HIPAA-compliant alerting across all 18 MedCore hospitals and 60+ outpatient clinics. It expands the architecture committed in the Statement of Work (SOW, OPP-2026-0047) into implementation-ready specifications for every layer of the platform: data ingestion, ML inference, LLM integration, alert routing, clinical dashboard, security controls, and enterprise operations.

This document is the authoritative technical reference for the Amatra delivery team and MedCore stakeholders throughout the engagement. Every architecture decision, service selection, integration specification, and security control described herein traces directly to a commitment made in the SOW or a requirement discovered during the Phase 1 Discovery sessions. No services, regions, or capabilities beyond what was sold have been added. Where the SOW stated a design choice at a high level, this document expands that choice into specific configurations, sizing parameters, and implementation sequences required for clinical-grade production deployment.

The platform is designed to satisfy three non-negotiable constraints that shaped every architectural decision: (1) **end-to-end inference latency < 3 seconds** from data arrival at the ingestion layer to a risk score and Bedrock narrative reaching the alert routing tier; (2) **99.95% platform availability** via multi-AZ primary and active/passive multi-region disaster recovery; and (3) **full HIPAA, HITECH, and SOC 2 Type II compliance** with defense-in-depth PHI protection, immutable audit logging, and continuous compliance posture monitoring. Delivery is structured across three production milestones: Phase 1 (sepsis model + ingestion pipeline) by **2026-10-31** ahead of MedCore's Joint Commission accreditation review, Phase 2 (readmission and rapid-response models + clinical dashboard) by **2027-02-28**, and General Availability across all 18 hospitals by **2027-06-30**.

## Purpose

This document defines the target-state technical architecture, component specifications, security controls, data flows, integration designs, infrastructure topology, and implementation sequencing for the MedCore CDS Platform. It is intended for use by Amatra's delivery team (Solutions Architect, ML/AI Engineers, Data Engineers, Security Engineer, DevOps Engineer), MedCore's CIO and Clinical Informatics Lead for technical review and sign-off, and the CISO for security and compliance validation. This document, together with the SOW, governs all technical decisions made during the build engagement and serves as the baseline for any change control requests.

## Scope

**In-scope:**

- AWS multi-region infrastructure design and provisioning (us-east-1 primary, us-west-2 passive DR) for a HIPAA-compliant, multi-AZ CDS platform in a dedicated Clinical Applications OU account
- Real-time data ingestion pipeline: Amazon Kinesis Data Streams (10 shards), Amazon MSK (3-broker Kafka cluster), Epic FHIR R4 API connector, and HL7 v2.3 Mirth Connect adapter
- Amazon HealthLake FHIR R4-compliant PHI datastore with full-text search and audit integration
- Three custom ML risk models (sepsis, 30-day readmission, rapid-response / early deterioration) on SageMaker Pipelines with Model Registry governance
- SHAP-based per-inference explainability output for every risk score alert
- Amazon Bedrock (Claude) integration for LLM-powered plain-language clinical alert narrative generation
- SageMaker Feature Store (online and offline feature groups) for real-time inference and weekly model retraining
- Role-based clinical dashboard (React / AWS Amplify) for risk score visualization, alert management, and mobile-responsive bedside view
- Azure Active Directory SSO federation via SAML 2.0 to Amazon Cognito for all clinical roles
- PHI encryption at rest (AWS KMS Customer Managed Keys) and in transit (TLS 1.2+), with HIPAA audit logging via CloudTrail and Athena query layer
- SOC 2 Type II readiness: AWS Config rules, Security Hub evidence collection
- Amazon Redshift + Amazon QuickSight longitudinal outcome tracking and model performance monitoring dashboards
- CI/CD pipelines (CodePipeline / CodeBuild) with blue/green deployment for ML inference endpoints
- Infrastructure-as-Code (Terraform / CDK) for all four environments (Dev, QA, Staging, Production)
- Structured phased rollout across all 18 hospitals and 60+ outpatient clinics with per-facility UAT
- Knowledge transfer, operational runbooks, model cards, and clinical train-the-trainer program
- 8-week post-GA hypercare support

**Out-of-scope:**

- Modifications to MedCore's Epic EHR configuration, Epic FHIR API endpoint setup, or Epic licensing
- Migration or modification of the on-premises SQL Server 2016 data warehouse
- Mirth Connect platform upgrades, server administration, or configuration changes beyond the HL7 v2.3 adapter integration
- Bedside monitoring hardware procurement or device firmware
- Changes to MedCore's existing AWS Landing Zone or SCPs outside the dedicated Clinical Applications OU
- Azure Active Directory tenant configuration or user provisioning
- Data labelling or ground-truth curation services for ML training datasets beyond what MedCore's Clinical Informatics team provides
- Development of ML models beyond the three in scope
- Third-party penetration testing fees
- Ongoing managed services post-hypercare
- Custom native iOS/Android mobile applications
- Revenue cycle system integration or claims data ingestion

## Assumptions & Constraints

- MedCore will provide Epic FHIR R4 API sandbox access within 2 weeks of project kickoff and production credentials at least 4 weeks before Phase 1 go-live.
- MedCore's IT team will complete AWS account vending for the dedicated CDS account within 2 weeks of kickoff.
- A representative de-identified clinical dataset (minimum 2 years of historical sepsis, readmission, and rapid-response events; minimum 1 TB labelled data) will be provided within 4 weeks of discovery phase completion.
- The Clinical Informatics Lead will be available ≥ 8 hours/week during Discovery and ML Model Development phases.
- The 1 Gbps AWS Direct Connect circuit will be procured by MedCore and available for testing by Week 8.
- MedCore's CISO will complete AWS BAA execution before the Development phase begins (Week 6).
- All PHI data remains in US AWS regions (us-east-1 and us-west-2) at all times; no cross-border data transfer is permitted.
- The Phase 1 hard deadline of **2026-10-31** is firm; client-side delays will trigger a formal schedule re-baseline.
- Azure Active Directory SAML 2.0 metadata will be available for SSO configuration testing within 2 weeks of Environment Setup phase completion.
- MedCore's on-premises Mirth Connect engine will be accessible from AWS via Direct Connect / PrivateLink during development and testing.
- All stakeholder approvals (go/no-go gates, test sign-off, UAT acceptance) will be provided within 5 business days of deliverable submission.
- This document assumes four environments: Dev, QA, Staging, and Production, each in a dedicated AWS account under the Clinical Applications OU.

## References

- Statement of Work (SOW) — OPP-2026-0047, MedCore Clinical Decision Support Platform, Amatra, June 18, 2025, v1.0
- Solution Briefing — AWS AI/ML Clinical Decision Support Platform, Amatra
- HIPAA Security Rule — 45 CFR Part 164, Technical Safeguards §164.312
- HITECH Act — Subtitle D, Privacy and Security Provisions
- SOC 2 Type II Trust Services Criteria — AICPA TSC CC6, CC7, A1
- AWS HIPAA Eligible Services Reference — AWS Compliance Program
- Amazon HealthLake Service Documentation
- Epic FHIR R4 Integration Specification (to be produced as SOW Deliverable #3)
- Level of Effort Estimate — MedCore CDS Platform, Amatra (internal)
- Infrastructure Costs Schedule — MedCore CDS Platform, Amatra (internal)

---

# Business Context

MedCore Health Systems is a $1.4B regional integrated delivery network (IDN) headquartered in Nashville, Tennessee, serving approximately 2.1 million patients annually across 18 hospitals and 60+ outpatient clinics. As a HIPAA- and HITECH-covered entity operating Business Associate Agreements with its major cloud and software vendors, MedCore's investment in the CDS Platform represents its strategic commitment to AI-driven clinical intelligence as the cornerstone of a multi-year patient safety transformation program. The technical architecture defined in this document is shaped directly by the clinical outcomes MedCore must deliver and the regulatory obligations it must satisfy.

## Business Drivers

- **Sepsis Detection and Mortality Reduction:** MedCore's existing rule-based alerting system detects sepsis late in the deterioration cycle — after clinical signs have progressed to a point where intervention efficacy is reduced. The CDS Platform must replace this with continuously trained, real-time ML-based detection that identifies at-risk patients at the earliest predictive window, targeting a 15% reduction in sepsis-related mortality within 12 months of go-live.
- **Alert Fatigue Elimination:** The current system generates a high proportion of false-positive alerts, causing nursing staff to deprioritize or ignore notifications. The CDS Platform must reduce the false-positive alert rate by 40% compared to the rule-based baseline while maintaining or improving sensitivity, directly reducing clinical alert fatigue and the risk of missed genuine deterioration events.
- **30-Day Readmission Reduction:** MedCore aims to reduce 30-day readmission rates by 20% across all facilities within 18 months of General Availability, driven by the readmission prediction model triggering proactive care coordination before discharge.
- **Regulatory Compliance and Auditability:** As a HIPAA BAA counterparty with AWS and an active SOC 2 Type II program, MedCore requires a fully governed, auditable PHI platform. Every PHI access event must be logged, retained for 7 years, and queryable by the CISO for ad-hoc audit investigations. Compliance evidence must be generated automatically for SOC 2 Type II auditors.
- **Joint Commission Accreditation Deadline:** MedCore's Joint Commission review in November 2026 will audit sepsis protocol outcomes. The Phase 1 hard deadline of 2026-10-31 is a non-negotiable regulatory forcing function for the sepsis model MVP.
- **Enterprise AI Foundation:** Beyond the three models in scope, MedCore intends to use this engagement to establish a reusable, governed ML infrastructure on AWS that can support future clinical AI initiatives without requiring a ground-up rebuild.

## Workload Criticality & SLA Expectations

The CDS Platform is a life-safety system. Risk score alerts directly influence clinical decision-making for critically ill patients. The platform is classified as Mission Critical, and all SLA targets reflect that classification.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Metric | Target | Measurement | Priority |
|--------|--------|-------------|----------|
| Platform Availability | 99.95% | CloudWatch uptime monitoring (multi-AZ + multi-region) | Critical |
| End-to-End Inference Latency | < 3 seconds P95 | AWS X-Ray distributed trace from Kinesis ingestion to alert dispatch | Critical |
| RTO (Region Failover) | ≤ 4 hours | Annual DR drill; Route 53 health check + DNS failover timing | Critical |
| RPO (Data Loss Window) | ≤ 15 minutes | HealthLake FHIR export frequency + Aurora cross-region replication lag | Critical |
| AZ Failover Recovery | ≤ 5 minutes | ALB + ECS Fargate task replacement timing in AZ-loss scenario | High |
| Sepsis Model AUROC | ≥ 0.85 | Clinical Informatics Lead sign-off on held-out validation dataset | Critical |
| Bedrock Narrative Latency | < 1.5 seconds P95 | CloudWatch Bedrock invocation duration metric | High |
| False-Positive Alert Reduction | ≥ 40% vs. baseline | Nurse alert dismissal rate tracked in QuickSight dashboard | High |
| Clinical Staff Adoption | ≥ 75% per facility within 90 days | Active dashboard logins tracked in Cognito and QuickSight | High |
| SageMaker Endpoint CPU | < 70% at peak load | CloudWatch SageMaker CPUUtilization metric | Medium |
| KMS Key Rotation | Annual (automatic) | AWS KMS key rotation status; monthly Config compliance check | High |
| PHI Audit Log Retention | 7 years (WORM) | S3 Object Lock (Compliance mode) on CloudTrail delivery bucket | Critical |

## Compliance & Regulatory Factors

- **HIPAA Security Rule (45 CFR §164.312):** All Technical Safeguards are implemented as first-class design requirements. PHI at rest is encrypted using AWS KMS CMKs; PHI in transit uses TLS 1.2+. Access controls enforce minimum necessary access via Cognito RBAC. Audit logging captures every PHI access event in CloudTrail with 7-year immutable WORM retention.
- **HITECH Act (Subtitle D):** Breach notification obligations require rapid identification of unauthorized PHI access. Amazon GuardDuty and Macie provide continuous PHI data classification and anomaly detection. The Athena query layer on CloudTrail enables the CISO to identify and scope any potential breach within hours.
- **SOC 2 Type II — Trust Services Criteria CC6, CC7, A1:** The platform implements logical access controls (CC6), system operations monitoring (CC7), and availability engineering (A1) as auditable, evidence-generating controls. AWS Config rules continuously evaluate compliance with the SOC 2 control baseline, generating evidence artifacts automatically for auditors.
- **AWS HIPAA BAA:** MedCore holds an active Business Associate Agreement with AWS covering all HIPAA-eligible services used in this platform (HealthLake, SageMaker, Kinesis, RDS Aurora, ElastiCache, S3, KMS, CloudTrail, ECS, Lambda, Cognito, Bedrock).

## Success Criteria

- Sepsis model AUROC ≥ 0.85 on held-out clinical validation dataset, signed off by MedCore Clinical Informatics Lead before Phase 1 production go-live.
- End-to-end inference latency < 3 seconds P95 validated by load test simulating full 18-hospital concurrent patient event volume.
- Platform availability ≥ 99.95% validated by automated uptime monitoring during hypercare period.
- Phase 1 live in production by **2026-10-31** (hard deadline; Joint Commission accreditation gate).
- Phase 2 (readmission + rapid-response models + clinical dashboard) live by **2027-02-28**.
- General Availability across all 18 hospitals by **2027-06-30**.
- Zero Critical or High unresolved security findings at go-live (CISO sign-off required).
- False-positive alert rate reduced ≥ 40% compared to rule-based system baseline within 90 days of Phase 1 go-live at pilot facility.
- Clinical staff adoption rate ≥ 75% per facility within 90 days of go-live, measured by active dashboard logins.
- All PHI access events captured in CloudTrail with 7-year WORM retention validated before first PHI enters the production environment.

---

# Current-State Assessment

MedCore Health Systems operates a fragmented clinical alerting environment across its 18 hospitals, with no unified real-time analytics or ML infrastructure on AWS. Understanding the current state is essential to defining the migration path, integration architecture, and transition plan for the CDS Platform. This section documents the existing application landscape, infrastructure inventory, integration topology, and identified gaps that the CDS Platform must address.

## Application Landscape

MedCore's current clinical alerting capability is built entirely on rule-based logic embedded within the Epic EHR system and supplemented by manual chart review. There is no ML-based prediction, no real-time streaming analytics, and no centralized clinical intelligence platform. The following systems are relevant to the CDS Platform scope.

<!-- TABLE_CONFIG: widths=[25, 30, 25, 20] -->
| Application | Purpose | Technology | Status |
|-------------|---------|------------|--------|
| Epic EHR (18 hospitals) | Electronic health record, clinical workflow, and existing rule-based alerting | Epic (hosted by MedCore on-premises and Epic cloud) | Retained; FHIR R4 API integrated |
| Mirth Connect Integration Engine | HL7 v2.3 message routing from Philips/GE bedside monitors to Epic | Mirth Connect (on-premises, MedCore Nashville DC) | Retained; new HL7 v2.3 adapter integrated |
| SQL Server 2016 Data Warehouse | Longitudinal operational reporting for hospital administration | On-premises SQL Server 2016 (MedCore Nashville DC) | Retained; nightly readmission export consumer only |
| Rule-Based Alert System (Epic CDS Hooks) | Generates sepsis and deterioration alerts based on threshold rules (e.g., SIRS criteria) | Epic CDS Hooks (embedded) | Replaced by CDS Platform in production; retained as shadow/backup during Phase 1 hypercare |
| Bedside Monitor Feeds (Philips/GE) | Real-time vitals telemetry (HR, BP, SpO2, RR, temp) from ICU and acute care monitors | HL7 v2.3 ORU messages via Mirth Connect | Integrated via new HL7 v2.3 adapter |
| MedCore AWS Landing Zone | Existing AWS Organizations structure with Clinical Applications OU | AWS Organizations, AWS SSO | Retained; CDS platform deployed in new dedicated account under existing OU |

## Infrastructure Inventory

MedCore has no existing AWS ML or streaming analytics infrastructure relevant to the CDS Platform. The following inventory captures the on-premises and edge components that the platform must integrate with or connect to.

<!-- TABLE_CONFIG: widths=[22, 12, 36, 30] -->
| Component | Quantity | Specifications | Notes |
|-----------|----------|----------------|-------|
| Mirth Connect Integration Server | 1 cluster | On-premises, MedCore Nashville DC; handles ~50K HL7 messages/hour at peak | Primary gateway for bedside monitor HL7 v2.3 streams; requires PrivateLink / Direct Connect access from AWS |
| Epic FHIR R4 API | 1 (federated 18 hospitals) | Epic-managed; SMART on FHIR OAuth 2.0; HL7 FHIR R4 resources (Observation, Patient, Encounter, MedicationRequest, DiagnosticReport) | MedCore EHR Integration Lead responsible for provisioning API credentials and FHIR subscription configuration |
| SQL Server 2016 Data Warehouse | 1 instance | On-premises, Nashville DC; used for operational reporting | Out-of-scope for build; nightly readmission outcome export from CDS Platform consumed here |
| AWS Direct Connect (to be provisioned) | 1 HA pair | 1 Gbps hosted connection, MedCore Nashville DC to AWS us-east-1 | Must be procured and available for testing by Week 8; MedCore responsibility |
| Azure Active Directory | 1 tenant | Microsoft Azure AD tenant (MedCore managed); SAML 2.0 IdP for clinical staff SSO | Integrated via SAML 2.0 metadata exchange to Amazon Cognito; Azure AD configuration is out of scope |
| MedCore Clinical Applications OU | 1 AWS OU | AWS Organizations OU; existing Landing Zone with SCPs | New CDS Platform AWS account provisioned under this OU |
| Philips/GE Bedside Monitors | ~800 units (18 hospitals) | ICU and acute care monitors; HL7 v2.3 ORU message generation; connected to Mirth Connect via clinical device VLAN | Hardware out of scope; device feeds arrive via Mirth Connect |

## Dependencies & Integration Points

- **Epic FHIR R4 API:** Real-time FHIR subscription events (Observation, Patient, Encounter, MedicationRequest) are the primary source of structured clinical data for the ML feature pipeline. Epic FHIR R4 API access, sandbox environment, and production credentials are on the critical path for Phase 1 delivery.
- **Mirth Connect HL7 v2.3 Adapter:** ADT and ORU message types from Philips/GE bedside monitors are routed via Mirth Connect and consumed by the new HL7 v2.3 adapter. The adapter's primary data types are ADT A01/A03/A08 (admissions/discharges/updates) and ORU R01 (observation results: vitals).
- **Azure Active Directory (SAML 2.0 IdP):** All 4,200+ clinical staff authenticate via MedCore's existing Azure AD tenant federated to Amazon Cognito via SAML 2.0. Role assignments (Nurse, Physician, Administrator, Data Scientist) are managed in Azure AD and mapped to Cognito groups at authentication time.
- **On-Premises SQL Server 2016 Data Warehouse:** A nightly Lambda-triggered ETL export pushes readmission outcome data to the existing data warehouse. This is a one-way, append-only export; no PHI is ingested from the SQL Server.
- **AWS Direct Connect (1 Gbps):** The dedicated private link from Nashville DC to AWS us-east-1 carries all Epic FHIR event streams and HL7 v2.3 Mirth Connect feeds. A site-to-site VPN provides secondary failover connectivity.

## Network Topology

MedCore's current relevant network topology consists of a clinical device VLAN in each hospital that routes bedside monitor HL7 traffic to the Mirth Connect integration server in the Nashville data center. Epic EHR is accessed by clinical staff over MedCore's hospital network via HTTPS to Epic-hosted application servers. The Nashville data center connects to the internet via dual ISP links with no existing direct cloud connectivity. The CDS Platform introduces a new 1 Gbps AWS Direct Connect HA pair from Nashville to AWS us-east-1 as the primary private channel. A site-to-site VPN serves as the secondary failover path.

## Security Posture

MedCore currently operates under HIPAA BAA obligations with Epic and other clinical software vendors. PHI audit logging is largely manual, with access to audit records requiring direct engagement with the Epic system administrator. There is no automated continuous compliance monitoring or cloud-native threat detection. The CDS Platform introduces automated, continuous PHI audit logging (CloudTrail + Athena), ML-driven threat detection (GuardDuty), and configuration compliance monitoring (AWS Config + Security Hub) — addressing the primary identified gaps in MedCore's current security posture relevant to the new AWS workload.

## Performance Baseline

The following baseline measurements characterize current-state clinical alerting performance against which the CDS Platform's improvements will be measured:

- Sepsis alert false-positive rate: ~62% (estimated from nursing alert dismissal logs; varies by facility)
- Typical alert generation latency from observation to notification: 4–10 minutes (Epic rule-based triggers)
- Manual chart review time per alert: 3–8 minutes (nursing staff estimate)
- Bedside monitor data availability in Epic: typically delayed 2–5 minutes due to Mirth Connect batch intervals
- Active clinical staff (nurses, hospitalists, administrators) per facility: approximately 233 staff per hospital on average

## Gap Analysis

The following gap analysis identifies the delta between MedCore's current state and the target state delivered by the CDS Platform.

<!-- TABLE_CONFIG: widths=[33, 34, 33] -->
| Current State | Gap | Target State |
|---------------|-----|--------------|
| Rule-based SIRS criteria threshold alerts in Epic CDS Hooks; high false-positive rate (~62%) | No ML-based pattern recognition; no historical patient context; no continuous learning | SageMaker sepsis risk model (XGBoost/ensemble, AUROC ≥ 0.85); continuously retrained weekly; false-positive rate reduced ≥ 40% |
| No real-time streaming analytics; Mirth Connect data reaches Epic with 2–5 minute lag | No sub-3-second end-to-end data pipeline; no online feature store | Kinesis Data Streams (10 shards) + SageMaker Feature Store online groups; < 3-second end-to-end inference latency |
| No ML or predictive models for 30-day readmission or rapid-response events | No proactive care coordination trigger before discharge; no early deterioration signal | SageMaker readmission and rapid-response models (Phase 2); SHAP explainability per alert |
| No LLM-generated clinical summaries; clinicians must review charts manually per alert | Clinician time wasted on chart review after each alert; slows intervention decision | Amazon Bedrock (Claude) clinical narrative generation; plain-language summary per alert within 3-second SLA |
| Manual PHI audit logging; no automated HIPAA compliance monitoring | CISO cannot efficiently audit PHI access; compliance gaps for SOC 2 Type II program | CloudTrail organization-level trail; Athena query layer; AWS Config HIPAA rules; Security Hub; 7-year WORM retention |
| No enterprise AWS ML infrastructure; no reusable AI/ML platform | Each future clinical AI project requires ground-up infrastructure build | Reusable SageMaker Pipelines, Feature Store, Model Registry, and HealthLake foundation for future clinical AI initiatives |
| No centralized clinical dashboard; alerts delivered only within Epic workflow | No unified risk view across patient panel; no cross-facility analytics visibility | React/Amplify clinical dashboard with role-based views, QuickSight outcome dashboards, mobile-responsive bedside interface |
| Azure AD SSO not federated to clinical analytics tools; separate credentials for each system | Friction in clinical staff workflow; no centralized identity governance for analytics access | Amazon Cognito SAML 2.0 federation to Azure AD; SSO with MedCore credentials; RBAC enforced per clinical role |

---

# Solution Architecture

The MedCore CDS Platform is designed as a fully cloud-native, event-driven architecture on AWS, built to meet the strict latency, availability, and compliance requirements of a clinical-grade enterprise health system. The architecture is anchored on a real-time streaming ingestion pipeline that receives clinical events from two source systems — Epic via HL7 FHIR R4 subscription events and Philips/GE bedside monitors via HL7 v2.3 over Mirth Connect — and routes them through a multi-stage processing layer that normalizes, enriches, and persists data before triggering ML inference and LLM narrative generation. The end-to-end flow from data arrival at the Kinesis ingestion tier to a risk score, SHAP explanation, and Bedrock narrative reaching the alert routing tier is constrained to < 3 seconds at P95 under full production load.

The platform deploys across two AWS regions — us-east-1 (N. Virginia) as the active primary region and us-west-2 (Oregon) as a passive disaster recovery region — with Route 53 health-check-driven DNS failover to meet the 99.95% availability SLA. All PHI data remains within US AWS regions at all times. The deployment topology uses a dedicated AWS account under MedCore's Clinical Applications OU, connected to on-premises Mirth Connect via a 1 Gbps AWS Direct Connect HA pair backed by a site-to-site VPN for failover.

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

*Figure 1: MedCore CDS Platform — AWS Architecture. End-to-end view of real-time clinical data ingestion, ML inference pipeline, LLM narrative generation, alert routing, clinical dashboard layers, and multi-AZ / multi-region HA topology.*

## Architecture Principles

The following principles guided every design decision in the CDS Platform and must be applied consistently throughout the build engagement.

- **Latency First:** The < 3-second end-to-end inference constraint is the single most consequential design forcing function. Every component selection, sizing decision, and integration pattern was evaluated against its contribution to the end-to-end latency budget. ElastiCache Redis pre-caches patient feature vectors; SageMaker real-time endpoints are sized for P95 < 1.5 seconds; Bedrock invocations are targeted at < 1 second; Kinesis shard count is sized with ≥ 30% headroom at peak. Any proposed design change that risks latency budget must be escalated before implementation.
- **HIPAA by Design:** PHI protection is a design constraint, not a post-hoc control. Every service that stores, processes, or transmits PHI is covered by the AWS HIPAA BAA. Encryption at rest (KMS CMKs) and in transit (TLS 1.2+) is mandatory at all data paths. No PHI ever traverses the public internet; all service-to-service communication uses AWS PrivateLink. Audit logging is always-on and immutable.
- **Operational Simplicity via Managed Services:** Every infrastructure layer uses AWS managed services to minimize MedCore's operational overhead post-handover. SageMaker Pipelines, HealthLake, MSK, RDS Aurora Multi-AZ, ElastiCache, and ECS Fargate all offload patching, backup, and availability management to AWS, reducing the operational burden on MedCore's IT team.
- **Infrastructure as Code Everywhere:** All environments are provisioned exclusively via Terraform/CDK. No manual AWS console changes are permitted in any environment — enforced by an SCP at the Clinical Applications OU level. This ensures environment parity, enables rapid DR region provisioning, and provides a complete, auditable change history.
- **Defense-in-Depth Security:** Security controls are layered across every tier. Preventative controls (KMS encryption, WAF, PrivateLink, SCPs, IAM least-privilege) are complemented by detective controls (GuardDuty, CloudTrail, Config, Security Hub, Macie) and responsive controls (automated Lambda remediation, PagerDuty-integrated alerting, CI/CD security gates). No single control failure exposes PHI.
- **Clinical Safety Backstop:** The existing Epic rule-based alert system remains active in parallel during Phase 1 deployment and the hypercare period. This provides a clinical safety backstop while the ML-based system is validated in production. The Amatra team and Clinical Informatics Lead must jointly authorize the flip from shadow mode to live alert delivery.

## Architecture Patterns

The CDS Platform applies the following architectural patterns consistently across all six functional layers.

- **Primary Pattern:** Event-Driven Microservices — each functional layer (ingestion, feature extraction, inference, narrative generation, alert routing, dashboard) is decoupled via Kinesis Data Streams and Amazon MSK, enabling independent scaling and fault isolation.
- **Data Pattern:** Lambda Architecture — a real-time speed layer (Kinesis → SageMaker Feature Store online groups → SageMaker endpoints) operates in parallel with a batch layer (SageMaker Feature Store offline groups → SageMaker Pipelines weekly retraining → Redshift analytics), providing both low-latency inference and high-accuracy model improvement.
- **Integration Pattern:** API Gateway + Event Bus — Epic FHIR R4 events are delivered via subscription webhooks to an ALB-fronted API Gateway; HL7 v2.3 events arrive via the Mirth Connect adapter through PrivateLink. Amazon MSK provides the internal event bus between ingestion and downstream processing stages.
- **Deployment Pattern:** Blue/Green — all SageMaker inference endpoint updates and application tier deployments use blue/green promotion via CodePipeline, with automated rollback triggered on P95 latency breach (> 3 seconds) within 30 minutes of deployment. This eliminates deployment risk for a life-safety platform.
- **Security Pattern:** Zero Trust — no implicit trust is granted based on network location. Every service-to-service call uses IAM roles with least-privilege policies; all external integrations authenticate via OAuth 2.0 (Epic SMART on FHIR) or SAML 2.0 (Azure AD → Cognito); PrivateLink prevents any PHI traffic from traversing the public internet.

## Component Design

The platform is composed of six functional layers, each implemented with AWS managed services. The following table captures the primary components within each layer, their responsibilities, technology selections, key dependencies, and scaling strategy. Each component selection traces to a specific SOW commitment.

<!-- TABLE_CONFIG: widths=[18, 25, 22, 18, 17] -->
| Component | Purpose | Technology | Dependencies | Scaling |
|-----------|---------|------------|--------------|---------|
| Epic FHIR R4 Connector | Ingests real-time patient data (Observation, Encounter, MedicationRequest, DiagnosticReport) from Epic via FHIR subscription events | AWS Lambda + SMART on FHIR OAuth 2.0 | Epic FHIR R4 API, Direct Connect, Kinesis Data Streams | Scales to Lambda concurrency limit; no per-instance scaling required |
| HL7 v2.3 Mirth Connect Adapter | Parses and normalizes ADT and ORU messages from Philips/GE monitors and routes to Kinesis | AWS Lambda + PrivateLink to on-premises Mirth Connect | Mirth Connect, Direct Connect, Kinesis Data Streams | Lambda auto-scaling; shard capacity drives throughput ceiling |
| Kinesis Data Streams (10 shards) | Real-time event streaming hub for all ingested clinical events; decouples ingestion from downstream processing | Amazon Kinesis Data Streams | FHIR Connector, HL7 Adapter, MSK consumer Lambda | Horizontal shard scaling; provisioned at 10 shards with ≥ 30% headroom at peak |
| Amazon MSK (3-broker Kafka) | Internal event bus decoupling the ingestion layer from the Feature Store pipeline and inference layer | Amazon MSK (msk.m5.large × 3) | Kinesis consumer Lambda, Feature Store pipeline Lambda | MSK broker scaling; add brokers at > 60% throughput utilization |
| Amazon HealthLake | HIPAA-eligible FHIR R4-compliant PHI datastore; longitudinal patient record persistence and audit integration | Amazon HealthLake | Kinesis, Lambda, SageMaker Feature Store | Fully managed; auto-scales to 1 TB active storage + 500 GB/month import volume |
| SageMaker Feature Store (Online) | Real-time per-patient feature vector cache for sub-3-second inference; stores normalized vitals, lab deltas, medication history | SageMaker Feature Store (online feature group) | HealthLake, Kinesis consumer Lambda | Fully managed; auto-scales with patient record volume |
| SageMaker Feature Store (Offline) | Historical feature snapshots for weekly model retraining and batch analytics | SageMaker Feature Store (offline feature group → S3) | S3 data lake, SageMaker Pipelines | Fully managed; scales with S3 storage |
| SageMaker Inference Endpoints (×4) | Real-time risk scoring for sepsis (Phase 1), readmission, rapid-response, and ensemble (Phase 2–3) | SageMaker Real-Time Inference (ml.m5.xlarge × 4) | Feature Store, Model Registry, Lambda alert dispatcher | Auto-scaling policy on SageMakerVariantInvocationsPerInstance; scale out at 70% CPU |
| SageMaker Pipelines | Weekly model retraining orchestration; trains new model version from offline Feature Store | SageMaker Pipelines + SageMaker Model Registry | Offline Feature Store, S3 model artefacts, Model Registry | On-demand compute (ml.p3.2xlarge); no standing infrastructure |
| SHAP Explainability Pipeline | Computes SHAP feature importance values for every inference call; bundles output with alert payload | SageMaker Processing Jobs (inline with inference) | SageMaker Inference Endpoints | Executes within endpoint inference container; latency budget < 0.5 seconds |
| Amazon Bedrock (Claude) | Generates plain-language clinical narrative for every alert based on risk score, SHAP factors, and patient context | Amazon Bedrock (Claude 3 model) | Lambda alert dispatcher, SageMaker inference output | Fully managed; scales with invocation volume; targeted < 1 second P95 |
| Alert Routing Service | Routes scored alerts to the correct clinical role via SNS push notifications and Epic CDS Hooks write-back | AWS Lambda + Amazon EventBridge + Amazon SNS | Bedrock, SageMaker inference output, Cognito RBAC, Epic FHIR write-back API | Lambda auto-scaling; SNS fully managed |
| Amazon ElastiCache Redis | Patient context cache for sub-3-second inference; caches per-patient feature vectors and recent risk scores | Amazon ElastiCache (cache.r7g.large × 2, Multi-AZ) | Feature Store, Lambda inference orchestrator | Redis cluster mode; scale out if cache hit ratio falls below 90% |
| Amazon RDS Aurora PostgreSQL | Operational data store for risk scores, alert history, and audit metadata | Amazon RDS Aurora PostgreSQL (db.r6g.large × 2, Multi-AZ) | Lambda alert dispatcher, Clinical Dashboard API | Aurora auto-scaling read replicas; scales with QuickSight query load |
| Amazon Redshift | Longitudinal outcomes warehouse for model performance monitoring and population health analytics | Amazon Redshift (ra3.xlplus × 1) | RDS Aurora (ETL), HealthLake, S3 | Manual node scaling; single ra3.xlplus sufficient at current data volumes |
| Clinical Dashboard (React/Amplify) | Role-based risk score visualization, alert management, and model explanation views; mobile-responsive for bedside tablet use | React / AWS Amplify + ALB + ECS Fargate | Cognito RBAC, RDS Aurora, SageMaker inference API | ECS Fargate auto-scaling on ALB request count; scales per facility activation |
| Amazon Cognito | SAML 2.0 SSO federation to Azure AD; RBAC enforcement for all clinical roles (~4,200 MAU) | Amazon Cognito (User Pool + Identity Pool) | Azure AD SAML 2.0 IdP, ECS Fargate app tier | Fully managed; auto-scales to 4,200+ MAU |
| AWS CodePipeline / CodeBuild | CI/CD for application deployments and SageMaker model endpoint promotions; blue/green deployment | AWS CodePipeline, CodeBuild, Snyk | IaC repositories (Terraform/CDK), SageMaker Model Registry | Fully managed |
| Amazon CloudWatch + X-Ray | Infrastructure and application observability; distributed tracing for end-to-end inference path | CloudWatch, X-Ray, Datadog APM | All platform components | Fully managed; scales with log and metric volume |

## Technology Stack

The following table summarizes the technology selection for each platform layer, with rationale traceable to SOW commitments and clinical requirements.

<!-- TABLE_CONFIG: widths=[22, 38, 40] -->
| Layer | Technology | Rationale |
|-------|------------|-----------|
| Data Ingestion — EHR | Amazon Kinesis Data Streams (10 shards) + Lambda FHIR Connector | SOW mandate; sub-3-second latency requires real-time streaming; event-driven FHIR subscriptions eliminate polling lag |
| Data Ingestion — Bedside Monitors | AWS Lambda + HL7 v2.3 adapter + Amazon MSK | SOW mandate; Mirth Connect delivers HL7 v2.3 ORU/ADT messages; MSK decouples ingestion from downstream processing |
| PHI Datastore | Amazon HealthLake (FHIR R4) | SOW mandate; only AWS HIPAA-eligible managed FHIR R4 datastore; native audit integration and full-text FHIR search |
| Feature Engineering | SageMaker Feature Store (online + offline) | SOW mandate; online groups provide < 3-second feature retrieval for inference; offline groups enable weekly retraining |
| ML Inference | SageMaker Real-Time Endpoints (ml.m5.xlarge × 4) + Model Registry | SOW mandate; managed endpoint hosting with blue/green deployment, auto-scaling, and Model Registry governance |
| Model Explainability | SHAP (inline with SageMaker inference container) | SOW mandate; every alert must include per-feature importance values; inline computation minimizes latency impact |
| LLM Narrative Generation | Amazon Bedrock (Claude 3) | SOW mandate; managed LLM API within AWS HIPAA BAA coverage; no PHI leaves AWS boundary |
| Alert Routing | Amazon EventBridge + Amazon SNS + AWS Lambda | SOW mandate; EventBridge provides rule-based routing per clinical role; SNS delivers push notifications; Lambda handles Epic CDS Hooks write-back |
| Patient Context Cache | Amazon ElastiCache Redis (cache.r7g.large, Multi-AZ) | SOW mandate; sub-millisecond feature vector retrieval for inference latency budget |
| Operational Database | Amazon RDS Aurora PostgreSQL (db.r6g.large, Multi-AZ) | SOW mandate; risk scores, alert history, and audit metadata; Multi-AZ for 99.95% availability requirement |
| Analytics | Amazon Redshift (ra3.xlplus) + Amazon QuickSight | SOW mandate; longitudinal outcomes warehouse and model performance dashboards for Clinical Informatics Lead |
| Clinical Dashboard | React + AWS Amplify + ECS Fargate + ALB | SOW mandate; Amplify accelerates React SPA deployment; ECS Fargate eliminates server management; ALB provides HTTPS termination and WAF integration |
| Identity & Access | Amazon Cognito + Azure AD SAML 2.0 | SOW mandate; federates existing MedCore Azure AD credentials; Cognito enforces RBAC per clinical role |
| Infrastructure as Code | Terraform + AWS CDK | SOW mandate; all environments provisioned via IaC; no manual console changes enforced by SCP |
| CI/CD | AWS CodePipeline + CodeBuild + Snyk | SOW mandate; blue/green inference endpoint deployment; Snyk container security scanning for HIPAA posture |
| Observability | Amazon CloudWatch + AWS X-Ray + Datadog APM | SOW mandate; CloudWatch provides native AWS metrics and alarms; X-Ray traces end-to-end inference path; Datadog APM provides enhanced ECS/SageMaker observability with PagerDuty on-call integration |
| Encryption | AWS KMS (Customer Managed Keys) + TLS 1.2+ | HIPAA mandate; separate CMKs per data store; all data in transit encrypted; automatic annual key rotation |
| Audit Logging | AWS CloudTrail (organization-level) + Athena | HIPAA mandate; every PHI access event logged; 7-year WORM retention via S3 Object Lock; Athena for CISO ad-hoc queries |
| Threat Detection | Amazon GuardDuty + AWS Security Hub + Amazon Macie | HIPAA/SOC 2 mandate; continuous ML-driven threat detection; PHI data classification; findings aggregated in Security Hub |
| Connectivity | AWS Direct Connect (1 Gbps HA pair) + Site-to-Site VPN | SOW mandate; dedicated private connectivity from MedCore Nashville DC to AWS us-east-1; VPN as secondary failover path |

---

# Security & Compliance

MedCore Health Systems is a HIPAA-covered entity and HITECH-obligated organization with an active BAA with AWS. Every design decision in the CDS Platform treats regulatory compliance as a first-class requirement. This section defines the security architecture across identity and access management, secrets management, network security, data protection, compliance mappings, and audit logging — each of which must be implemented and validated before any PHI enters the production environment.

## Identity & Access Management

Access to the CDS Platform is governed by a Cognito-based RBAC model federated to MedCore's existing Azure Active Directory via SAML 2.0. This design ensures that all clinical staff authenticate with their existing MedCore SSO credentials and MFA policy — no separate credentials are issued for the CDS Platform. IAM roles throughout the platform follow strict least-privilege design with no wildcard actions or resource ARNs.

- **Authentication:** Azure Active Directory SAML 2.0 federation to Amazon Cognito User Pool; MedCore MFA policy enforced at Azure AD layer; Cognito session tokens expire after 8 hours (aligned to clinical shift length); SAML re-authentication required for sessions exceeding 8 hours.
- **Authorization:** Cognito user groups map to four clinical role types; each role is authorized only to the specific API endpoints, data scopes, and dashboard views required for its clinical function; implemented via Cognito-issued JWT claims consumed by the ECS Fargate application tier and enforced by Lambda authorizers on API Gateway.
- **MFA:** Enforced at Azure AD level per MedCore's existing MFA policy (Microsoft Authenticator); Amatra does not modify Azure AD MFA configuration.
- **Service Accounts:** Each AWS service (ECS task, Lambda function, SageMaker endpoint) operates under a dedicated IAM role granting only the specific API actions required; cross-service calls use IAM role assumption with external ID conditions; no long-lived IAM access keys are used in application code or IaC.
- **Privileged Access:** Production AWS console access for Amatra engineers is restricted to a break-glass IAM role requiring written CIO approval; activated only for incident response or scheduled maintenance; every break-glass session logged to CloudTrail with email notification to CISO.

### Role Definitions

The following four clinical role types govern all platform access. Role assignments are managed in Azure AD and propagated to Cognito at authentication time via SAML attribute mapping.

<!-- TABLE_CONFIG: widths=[20, 45, 35] -->
| Role | Permissions | Scope |
|------|-------------|-------|
| Nurse | View risk scores and active alerts for assigned patients only; acknowledge and dismiss alerts; access SHAP explanation summary | Patient panel scoped to assigned unit/facility; no cross-facility access; no raw model data access |
| Physician / Hospitalist | View risk scores, full SHAP explanation factors, Bedrock clinical narrative, and full model explanation for patient panel; alert management and escalation | Patient panel scoped to attending physician assignment; read-only access to historical alerts |
| Administrator | Alert threshold configuration, reporting access (QuickSight dashboards), alert management, and user activity reporting | All patients at assigned facility; no production ML configuration access |
| Data Scientist | SageMaker console access (dev/staging only), Feature Store read access, Model Registry access; no direct PHI access in production | Dev and staging environments only; production access restricted to model endpoint invocation metrics |
| IT Operations (MedCore) | CloudWatch dashboards, operational runbook execution, infrastructure monitoring; no PHI data access | All environments; read-only access to operational metrics; no access to patient-level data |
| CISO (Audit) | Read-only access to CloudTrail, Athena audit query layer, Config findings, Security Hub findings, GuardDuty findings | All environments; all audit and compliance data; no write access to any system |

## Secrets Management

All application secrets are stored in and rotated by AWS Secrets Manager. No credentials are stored in environment variables, application source code, IaC configuration files, or CloudWatch logs. Secrets Manager is integrated with the CI/CD pipeline via SecretString injection at deployment time.

- **Secrets stored:** RDS Aurora master credentials, Epic FHIR R4 OAuth 2.0 client secret and bearer token cache, Mirth Connect integration API key, Bedrock API endpoint configuration, Datadog API key.
- **Rotation policy:** All secrets rotate automatically on a 30-day schedule via Secrets Manager's rotation Lambda functions. RDS credential rotation uses the built-in RDS rotation Lambda. Epic API token rotation follows Epic's 90-day OAuth token expiry with automatic re-issuance.
- **Access logging:** Every Secrets Manager GetSecretValue API call is captured in CloudTrail with the IAM principal, timestamp, and secret ARN.

## Network Security

The platform's network topology eliminates public internet traversal for all PHI data paths by routing all service-to-service communication via AWS PrivateLink and all on-premises connectivity via Direct Connect.

- **Segmentation:** All resources deployed in private subnets (no public subnet resources except NAT Gateways and ALB). Three subnet tiers in each AZ: public (ALB, NAT Gateway), private application (ECS Fargate, Lambda, SageMaker), and private data (RDS Aurora, ElastiCache, HealthLake endpoint).
- **Firewall:** Security Groups enforce least-privilege port rules at the resource level; NACLs provide subnet-level boundary enforcement. Application tier Security Groups allow inbound only from ALB Security Group; data tier Security Groups allow inbound only from application tier Security Groups.
- **WAF:** AWS WAF is deployed on all ALBs and API Gateway endpoints with the AWS Managed Rules — Core Rule Set (OWASP Top 10), AWS Managed Rules — Amazon IP Reputation List, and a custom healthcare-specific rule set (blocking malformed FHIR payloads and oversized request bodies). WAF logs are delivered to CloudWatch Logs with 90-day retention.
- **DDoS Protection:** AWS Shield Standard is active on all ALBs and CloudFront distributions. Given the clinical nature of the workload and 99.95% SLA requirement, AWS Shield Advanced will be evaluated during the security design phase and recommended if MedCore's risk assessment warrants the additional investment.
- **PrivateLink:** All communication between application tier components and AWS managed services (HealthLake, SageMaker, Bedrock, S3, Secrets Manager, KMS, SSM, CloudWatch) uses VPC Endpoints (AWS PrivateLink). No PHI traffic exits the VPC to the public internet.

## Data Protection

Data protection controls ensure all PHI is encrypted at rest and in transit using keys owned and controlled exclusively by MedCore.

- **Encryption at Rest:** All PHI data stores encrypted using AWS KMS Customer Managed Keys (CMKs): HealthLake (dedicated CMK), RDS Aurora (dedicated CMK), S3 audit bucket (dedicated CMK), S3 data lake (dedicated CMK), EBS volumes (dedicated CMK), ElastiCache Redis (dedicated CMK). Blast-radius isolation ensures compromise of one CMK cannot decrypt another data store. All CMKs have automatic annual rotation enabled.
- **Encryption in Transit:** TLS 1.2+ enforced on all communication paths: Kinesis producer SDK, HealthLake API, SageMaker endpoint API calls, Bedrock API calls, ALB HTTPS listeners, Direct Connect MACsec (where supported by the hosted connection provider), site-to-site VPN (IKEv2 with AES-256 encryption). HTTP is not permitted on any ALB listener; HTTP requests are redirected to HTTPS with a 301 permanent redirect.
- **Key Management:** AWS KMS CMKs are owned by MedCore (CISO holds administrative key policy access). Key policies are scoped to the minimum set of IAM principals required for each data store. Key usage is logged to CloudTrail. Key deletion requires a 30-day waiting period and CISO-level approval.
- **Data Masking:** De-identified synthetic PHI (generated using HealthLake's FHIR de-identification capability and AWS-native tokenization) is used in all non-production environments (Dev, QA, Staging). No real patient PHI is used outside the Production environment.

## Compliance Mappings

The following table maps the three applicable regulatory frameworks to their specific implementation in the CDS Platform.

<!-- TABLE_CONFIG: widths=[20, 38, 42] -->
| Framework | Requirement | Implementation |
|-----------|-------------|----------------|
| HIPAA §164.312(a) — Access Controls | Unique user identification; emergency access; automatic logoff; encryption | Amazon Cognito (unique user IDs via Azure AD federation); break-glass IAM role for emergency access; 8-hour session expiry; KMS CMK encryption at rest |
| HIPAA §164.312(b) — Audit Controls | Record and examine activity in systems containing PHI | CloudTrail organization-level trail; every PHI API access logged; Athena query layer for CISO investigation; 7-year WORM retention via S3 Object Lock |
| HIPAA §164.312(c) — Integrity | Authenticate PHI; detect unauthorized alteration | S3 Object Lock (Compliance mode) for audit logs; RDS Aurora automated backups with point-in-time recovery; CloudTrail log file validation enabled |
| HIPAA §164.312(d) — Authentication | Verify user/entity identity before granting access | Azure AD SAML 2.0 MFA federation; IAM role external ID conditions; Cognito JWT validation on all API paths |
| HIPAA §164.312(e) — Transmission Security | Protect PHI in transit | TLS 1.2+ on all data paths; Direct Connect MACsec; VPN IKEv2/AES-256; PrivateLink for all service-to-service communication |
| HITECH Breach Notification | Rapid identification and notification of PHI breaches | GuardDuty continuous threat detection; Macie PHI data classification; CloudTrail + Athena for breach scoping; Security Hub aggregation for CISO |
| SOC 2 CC6 — Logical Access | Authentication, authorization, access removal | Cognito RBAC + Azure AD federation; quarterly access review process; IAM Access Analyzer; automated deprovisioning via Cognito and Azure AD sync |
| SOC 2 CC7 — System Operations | Change management; anomaly detection; incident response | CodePipeline IaC-only deployments; GuardDuty anomaly detection; Config drift alerts within 15 minutes; PagerDuty-integrated incident response |
| SOC 2 A1 — Availability | System availability commitments met | Multi-AZ primary (us-east-1) + passive DR (us-west-2); Route 53 health-check failover; 99.95% availability SLA; annual DR drill |

## Audit Logging & SIEM Integration

A complete, tamper-resistant PHI audit trail is maintained from the moment data enters the platform to the moment it is accessed or deleted. Audit logging is always-on and cannot be disabled without generating a Security Hub critical finding.

- **What is logged:** Every PHI access event (HealthLake reads/writes, RDS Aurora queries via Lambda, S3 data lake access, Bedrock invocations involving patient context, SageMaker endpoint inference calls) is captured in CloudTrail with the IAM principal ARN, source IP, user agent, timestamp, resource ARN, and action type. All Cognito authentication events (successful logins, failed logins, MFA challenges, session expirations) are logged to CloudWatch Logs.
- **Retention policy:** CloudTrail logs are delivered to a dedicated S3 audit bucket with S3 Object Lock enabled (Compliance mode, 7-year retention). CloudWatch Logs groups for application and infrastructure logs have a 90-day retention policy. Athena tables over CloudTrail S3 enable SQL-based PHI access audit queries without deleting or modifying log data.
- **SIEM integration approach:** Security Hub aggregates findings from GuardDuty, AWS Config, Amazon Inspector, and Amazon Macie into a single pane for the CISO. High and Critical severity findings trigger SNS notifications to the CISO's PagerDuty on-call rotation with a 1-hour acknowledgement SLA during hypercare. Datadog APM log management provides real-time log indexing and alerting for application-level security events (authentication failures, anomalous API call rates) alongside infrastructure metrics.

---

# Data Architecture

The CDS Platform's data architecture is designed to simultaneously satisfy two demanding constraints: sub-3-second real-time feature availability for ML inference, and compliant, longitudinal PHI persistence for model retraining, audit, and clinical analytics. These constraints drive a four-tier storage architecture — hot (ElastiCache), warm operational (HealthLake + RDS Aurora), cold analytics (Redshift), and archive (S3 Object Lock) — with distinct access patterns, retention policies, and encryption controls at each tier.

## Data Model

### Conceptual Model

The data model is organized around the FHIR R4 resource model as the canonical representation for all clinical entities. Patient records are the central aggregate root, with Observations (vitals, labs), MedicationRequests, Encounters, and DiagnosticReports as child resources. ML feature vectors are derived from FHIR resources and stored in the SageMaker Feature Store as flattened, time-windowed feature sets keyed by PatientID. Risk scores, SHAP values, and Bedrock narratives are derived artifacts persisted in RDS Aurora and linked back to the originating Patient and Encounter. Alert events are generated from risk scores and carry references to the source patient, encounter, model version, feature snapshot, and narrative.

### Logical Model

The following entities represent the core data structures in the CDS Platform.

<!-- TABLE_CONFIG: widths=[20, 30, 28, 22] -->
| Entity | Key Attributes | Relationships | Volume |
|--------|----------------|---------------|--------|
| Patient (FHIR) | PatientID (MRN), demographics, admission status | Parent of Observation, Encounter, MedicationRequest, DiagnosticReport | ~2.1M records in HealthLake; ~2,500 active inpatients at any time |
| Observation (FHIR) | ObservationID, PatientID, EncounterID, code (LOINC), value, unit, effectiveDateTime | Child of Patient; source for vitals and lab feature vectors | ~50M events/month (vitals + labs combined across 18 hospitals) |
| Encounter (FHIR) | EncounterID, PatientID, facilityID, admissionDate, status | Links Patient to clinical episode; scope for risk scoring window | ~150K active encounters/month |
| MedicationRequest (FHIR) | MedicationRequestID, PatientID, medicationCode (RxNorm), dosage, status | Child of Patient; medication history feature for ML models | ~800K active records |
| FeatureVector (SageMaker Feature Store) | PatientID, EncounterID, EventTime, vitals_delta_15min, lab_abnormality_score, medication_interaction_flag, 48+ derived features | Derived from FHIR Observations and MedicationRequests; keyed by PatientID | Online group: ~2,500 active records; Offline group: ~10M historical snapshots |
| RiskScore | RiskScoreID, PatientID, EncounterID, ModelID, ModelVersion, SepsisScore, ReadmissionScore, RapidResponseScore, ComputedAt, LatencyMs | Parent of Alert; child of Patient and Encounter; linked to FeatureVector snapshot | ~10M updates/month |
| Alert | AlertID, RiskScoreID, PatientID, ClinicalRoleTarget, SHAPPayload (JSON), BedrockNarrative, DeliveredAt, AcknowledgedAt, DismissedAt | Child of RiskScore; persisted in RDS Aurora | ~500K alerts/month (post false-positive filtering) |
| AuditEvent | AuditEventID, PrincipalARN, Action, ResourceARN, PatientID (if applicable), Timestamp, SourceIP | Derived from CloudTrail; queryable via Athena | ~100M events/month across all PHI access paths |
| ModelPerformanceMetric | MetricID, ModelID, ModelVersion, AUROC, Sensitivity, Specificity, FalsePositiveRate, EvaluationDate | Child of Model; persisted in Redshift | ~52 records/model/year (weekly evaluation) |

## Data Flow Design

Data in the CDS Platform flows through a well-defined, five-stage pipeline from clinical source systems to clinical staff dashboards. Each stage has explicit validation, error handling, and latency budgets that contribute to the < 3-second end-to-end SLA.

1. **Ingestion (Budget: < 0.3 seconds):** Epic FHIR R4 subscription events (Observation, Encounter, MedicationRequest) arrive at the Lambda FHIR Connector via HTTPS over Direct Connect. HL7 v2.3 ADT and ORU messages from Mirth Connect arrive at the Lambda HL7 adapter via PrivateLink. Both connectors validate message schema (FHIR resource structure or HL7 segment structure), normalize to a canonical internal JSON format, and produce records to Kinesis Data Streams. Malformed messages are routed to a Kinesis dead-letter queue (DLQ) for out-of-band investigation without blocking the main pipeline.
2. **Feature Extraction (Budget: < 0.5 seconds):** A Kinesis Consumer Lambda reads batches of normalized events from Kinesis, applies FHIR-to-feature mapping (vital sign delta calculations, lab abnormality scoring, medication interaction flagging), and writes derived feature vectors to the SageMaker Feature Store online feature group (sub-millisecond write latency) and caches the patient context in ElastiCache Redis. Simultaneously, raw events are persisted asynchronously to Amazon HealthLake and the SageMaker Feature Store offline feature group via an MSK consumer pipeline. Parallel persistence to HealthLake does not block the inference path.
3. **Inference (Budget: < 1.5 seconds):** An inference orchestrator Lambda retrieves the updated feature vector from ElastiCache Redis (sub-millisecond cache hit) and invokes the applicable SageMaker real-time endpoint(s) via the SageMaker Runtime API over PrivateLink. SHAP values are computed inline within the SageMaker inference container (< 0.5 seconds of the inference budget). The orchestrator assembles the risk score output and SHAP payload and passes it to the narrative generation stage.
4. **Narrative Generation (Budget: < 1 second):** The inference orchestrator Lambda invokes Amazon Bedrock (Claude 3) with a structured prompt containing the risk score, model type, top SHAP factors, patient context (age, current medications, key vitals delta), and the validated clinical prompt template. Bedrock returns a plain-language clinical narrative sentence suitable for bedside reading. Bedrock invocations are logged for quality monitoring. Prompt template versions are controlled in the Bedrock configuration parameter store.
5. **Alert Routing and Delivery:** An EventBridge rule evaluates the alert payload against routing rules (risk score threshold, clinical role mapping, duplicate suppression window) and routes qualifying alerts to Amazon SNS for push notification delivery. A separate Lambda function writes CDS Hooks responses back to the Epic workflow for alerts destined for the Epic clinical workflow. Delivered alerts are persisted to RDS Aurora. The alert is visible in the clinical dashboard within seconds of the triggering FHIR event.

## Data Migration Strategy

The CDS Platform is a greenfield build with no data migration required for the core operational platform. However, the following data preparation activities are required before ML model training can begin.

- **Approach:** Phased data preparation rather than a one-time migration. Historical PHI for model training is extracted from MedCore's existing Epic data store (via Epic's Clarity reporting database, out of scope for Amatra) by MedCore's Clinical Informatics team and delivered to the CDS Platform S3 data lake as de-identified CSV/FHIR NDJSON exports.
- **Validation:** Each training dataset batch is validated for completeness (minimum record counts per outcome label per model), schema conformance (FHIR R4 resource structure or agreed flat-file schema), and temporal integrity (no future-dated observations; correct encounter-to-outcome linkage) before being registered in the SageMaker Feature Store offline groups.
- **Rollback:** If training dataset quality issues are discovered after feature engineering begins, the Feature Store offline group can be rolled back to the previous snapshot. SageMaker Pipelines maintains a versioned history of all training runs.
- **Cutover:** No cutover is required for the training data pipeline. For the operational pipeline, the cutover from shadow mode (alerts generated but not delivered) to live clinical delivery is authorized by the Clinical Informatics Lead after 48-hour shadow validation. The rule-based Epic system remains the clinical backstop for 2 weeks post-cutover.

## Data Governance

Data governance controls ensure that PHI is handled consistently, classified appropriately, and subject to retention and quality policies throughout its lifecycle in the CDS Platform.

- **Classification:** PHI (Restricted): All HealthLake FHIR records, SageMaker Feature Store records containing patient identifiers, RDS Aurora risk scores and alert history, Bedrock narrative output, CloudTrail audit events referencing PatientIDs. De-identified data (Sensitive): SageMaker Feature Store offline training data (post-tokenization), Redshift outcome warehouse. Metadata (Internal): Model performance metrics, infrastructure logs (no patient data).
- **Retention:** HealthLake FHIR data: 7-year minimum retention per HIPAA; S3 Object Lock (Compliance mode) applied to HealthLake backup exports. RDS Aurora: 35-day automated snapshot retention; additional point-in-time recovery (PITR) enabled. Redshift: Indefinite retention for longitudinal outcomes analysis (7-year minimum). CloudTrail audit logs: 7-year WORM retention (S3 Object Lock, Compliance mode). Application logs (CloudWatch): 90-day retention. S3 raw event archive (HL7 event archive): 7-year WORM retention.
- **Quality:** Incoming FHIR events are validated against the FHIR R4 base profile using Lambda-based schema validation. LOINC code completeness for key lab and vital observations is checked; records with missing required features fall back to a simplified feature vector flagged as `low_confidence`. ML model inputs with feature completeness below a defined threshold (configurable per model) generate an `insufficient_data` flag and do not produce a risk score alert.
- **Access:** PHI access in the production environment is limited to: Lambda functions operating under least-privilege IAM roles (inference pipeline, alert routing, FHIR write-back); clinical staff authenticated via Cognito with role-appropriate scoping; and CISO (read-only audit via Athena). No direct database access to production RDS Aurora or HealthLake is granted to any human user in steady-state operations; all access is mediated by application-tier API.

---

# Integration Design

The CDS Platform integrates with four external systems: Epic EHR (inbound FHIR R4 events and outbound CDS Hooks responses), Mirth Connect (inbound HL7 v2.3 events), Azure Active Directory (identity federation), and the on-premises SQL Server data warehouse (nightly outbound readmission export). Each integration is designed to operate over private, encrypted channels with no PHI traversing the public internet.

## External System Integrations

The following table summarizes all external system integrations within the CDS Platform scope.

<!-- TABLE_CONFIG: widths=[16, 12, 14, 12, 22, 14, 10] -->
| System | Direction | Type | Protocol | Format | Error Handling | SLA |
|--------|-----------|------|----------|--------|----------------|-----|
| Epic EHR (FHIR R4 Inbound) | Inbound | Real-time event-driven | HTTPS (SMART on FHIR OAuth 2.0) | HL7 FHIR R4 JSON (Observation, Encounter, MedicationRequest, DiagnosticReport) | Schema validation; DLQ for malformed events; retry with exponential back-off (3 retries) | < 3 seconds ingestion to Feature Store |
| Epic EHR (CDS Hooks Outbound) | Outbound | Real-time event-driven | HTTPS (Epic CDS Hooks API) | CDS Hooks 2.0 JSON (cards with risk score and narrative) | Lambda retry (3 attempts); alerts persist in dashboard even if Epic write-back fails | Best-effort; dashboard delivery is primary SLA |
| Mirth Connect HL7 v2.3 | Inbound | Real-time streaming | HL7 v2.3 MLLP over TCP/IP via PrivateLink | HL7 v2.3 ADT and ORU message types | Dead-letter queue for parse failures; Mirth-side acknowledgement (ACK) protocol | < 3 seconds ingestion to Feature Store |
| Azure Active Directory | Inbound | Authentication event-driven | HTTPS SAML 2.0 | SAML 2.0 Assertion (XML) with role attribute mapping | Cognito handles IdP-initiated session; Cognito returns error page on SAML assertion failure | < 1 second authentication round-trip |
| SQL Server 2016 Data Warehouse | Outbound | Nightly batch | JDBC over Direct Connect | CSV / flat-file readmission outcome export | Lambda retry (3 attempts); CloudWatch alarm if export fails for > 1 day | Nightly by 02:00 ET |

## API Design

The CDS Platform exposes internal APIs between its tiers (inference orchestrator, alert routing, dashboard API). External-facing API surfaces are limited to the Epic CDS Hooks outbound callback and the FHIR R4 inbound subscription endpoint.

- **Style:** REST (JSON) for all external-facing endpoints; internal service-to-service calls use direct AWS SDK invocations (Lambda, SageMaker, Bedrock) via IAM-authenticated API calls rather than HTTP REST where possible to minimize latency.
- **Versioning:** URL path versioning (/api/v1/) for the clinical dashboard backend API; CDS Hooks API version locked to CDS Hooks 2.0 specification.
- **Authentication:** All external API endpoints (FHIR inbound webhook, dashboard API) protected by Amazon Cognito JWT authorizer on API Gateway. Internal Lambda-to-SageMaker and Lambda-to-Bedrock calls authenticated via IAM role; no API key management required.
- **Rate Limiting:** API Gateway throttling configured at 2,000 requests/second for the dashboard API and 500 requests/second for the FHIR inbound endpoint (sized for 10M+ events/month). SageMaker endpoint auto-scaling policy limits concurrent invocations below 70% endpoint CPU.

### API Endpoints

The following table documents the primary clinical dashboard backend API endpoints exposed by the ECS Fargate application tier.

<!-- TABLE_CONFIG: widths=[10, 38, 18, 34] -->
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | /api/v1/patients/{patientId}/risk-scores | Bearer (Cognito JWT) | Returns latest risk scores (sepsis, readmission, rapid-response) for the specified patient; scoped to authenticated user's role |
| GET | /api/v1/patients/{patientId}/alerts | Bearer (Cognito JWT) | Returns paginated alert history for the specified patient with SHAP payload and Bedrock narrative |
| POST | /api/v1/alerts/{alertId}/acknowledge | Bearer (Cognito JWT) | Records alert acknowledgement by the authenticated clinical user; updates RDS Aurora alert status |
| POST | /api/v1/alerts/{alertId}/dismiss | Bearer (Cognito JWT) | Records alert dismissal with optional reason code; used for false-positive tracking |
| GET | /api/v1/dashboard/summary | Bearer (Cognito JWT — Administrator role) | Returns facility-level alert volume, risk score distribution, and adoption metrics for the authenticated administrator's facility |
| GET | /api/v1/health | None (internal health check) | ALB target group health check endpoint; returns 200 OK with service version |
| POST | /api/v1/fhir/subscription | SMART on FHIR OAuth 2.0 Bearer | FHIR R4 subscription notification receiver; accepts FHIR event payloads from Epic and enqueues to Kinesis |

## Authentication & SSO Flows

The authentication and SSO flow for clinical staff accessing the CDS Platform dashboard is as follows: (1) Clinical staff navigate to the dashboard URL; (2) The ECS Fargate app tier detects no valid Cognito session and redirects to the Cognito Hosted UI SAML endpoint; (3) Cognito redirects the user to MedCore's Azure AD SAML 2.0 IdP; (4) Azure AD authenticates the user with MFA and issues a SAML 2.0 assertion containing the user's clinical role attributes; (5) Cognito validates the SAML assertion, maps role attributes to Cognito groups (Nurse/Physician/Administrator/Data Scientist), and issues a Cognito JWT (ID token + access token); (6) The JWT is passed as a Bearer token on all subsequent API Gateway calls; (7) The Lambda JWT authorizer validates the token signature and extracts role claims for scope enforcement.

For service-to-service authentication (Lambda → SageMaker, Lambda → Bedrock, Lambda → HealthLake), IAM role assumption is used exclusively. No API keys or long-lived credentials are used in any service-to-service communication path.

## Messaging & Event Patterns

The CDS Platform uses a combination of Amazon Kinesis Data Streams and Amazon MSK to implement the internal event bus, with Amazon EventBridge for alert routing decisions and Amazon SNS for push notification delivery.

- **Queue Service:** Amazon SQS dead-letter queues are used for failed event processing at both the Kinesis consumer Lambda (malformed FHIR events) and the alert routing Lambda (failed Epic CDS Hooks write-backs). DLQ messages are retained for 14 days and trigger CloudWatch alarms for manual investigation.
- **Event Bus:** Amazon MSK (3-broker Kafka cluster) provides the internal event bus between the ingestion layer and the Feature Store pipeline. MSK topics are partitioned by PatientID to ensure ordering of per-patient event streams. Consumer group offset management ensures no event is processed more than once by the Feature Store pipeline under normal operating conditions.
- **Alert Routing:** Amazon EventBridge evaluates alert payloads against routing rules per clinical role, risk score threshold, and facility assignment. EventBridge rules are configured for each of the four clinical role types and each active facility. Rules are version-controlled in Terraform/CDK and deployed via CodePipeline.
- **Dead Letter Queue:** DLQ for the Kinesis consumer Lambda and alert routing Lambda; SNS DLQ alarm triggers on any new DLQ message with immediate notification to the Amatra on-call engineer (or MedCore IT Operations post-hypercare).
- **Retry Policy:** All Lambda functions implement exponential back-off with jitter for retryable failures (network timeouts, throttled API calls): initial retry interval 1 second, maximum 3 retries, maximum back-off 10 seconds. Non-retryable failures (schema validation errors, permanent API errors) are routed immediately to the DLQ.
- **Duplicate Suppression:** The alert routing Lambda implements a Redis-backed duplicate suppression window: if an alert of the same type (e.g., sepsis risk > 0.7) has been delivered for the same patient within the last 30 minutes, the duplicate is suppressed and logged for quality monitoring. Suppression window is configurable per alert type via SSM Parameter Store.

---

# Infrastructure & Operations

The CDS Platform's infrastructure is designed as a fully managed, multi-AZ, multi-region platform provisioned entirely via Infrastructure as Code. This section defines the network topology, compute sizing, high availability design, disaster recovery strategy, monitoring and alerting framework, and cost model for the platform.

## Network Design

The primary region (us-east-1) network topology is designed to ensure all PHI traffic travels exclusively over private, encrypted channels. Three availability zones are used in us-east-1 for all production workloads.

- **VPC CIDR:** 10.10.0.0/16 (us-east-1 Production VPC)
- **Public Subnets (3 AZs):** 10.10.0.0/24, 10.10.1.0/24, 10.10.2.0/24 — ALBs, NAT Gateways only; no application workloads
- **Private Application Subnets (3 AZs):** 10.10.10.0/23, 10.10.12.0/23, 10.10.14.0/23 — ECS Fargate tasks, Lambda functions (VPC-attached), SageMaker endpoints
- **Private Data Subnets (3 AZs):** 10.10.20.0/24, 10.10.21.0/24, 10.10.22.0/24 — RDS Aurora, ElastiCache Redis; no direct internet routing
- **DR Region VPC CIDR (us-west-2):** 10.11.0.0/16 — mirrors us-east-1 topology for standby deployment
- **Transit Gateway:** AWS Transit Gateway in us-east-1 connects the CDS VPC to the Direct Connect Gateway and to other Clinical Applications OU VPCs via peering (if required by MedCore Landing Zone design)
- **PrivateLink Endpoints:** VPC Interface Endpoints provisioned for: HealthLake, SageMaker Runtime, SageMaker Feature Store, Bedrock, S3 (Gateway endpoint), KMS, Secrets Manager, CloudWatch Logs, CloudTrail, SSM, ECS, Lambda, SNS, EventBridge, SQS
- **Connectivity to On-Premises:** 1 Gbps Direct Connect hosted connection from MedCore Nashville DC to AWS us-east-1 via Transit Gateway. Site-to-site VPN (IKEv2, AES-256) as secondary failover path. Both paths terminate at the Transit Gateway and are routed to the CDS VPC private application subnets.

## Compute Sizing

The following compute sizing is based on the SOW scope parameters (10M+ inference requests/month, 2,500+ concurrent active inpatient records, 4,200 MAU clinical staff) and the infrastructure costs schedule. All instance types are provisioned via Terraform/CDK IaC.

<!-- TABLE_CONFIG: widths=[28, 22, 12, 14, 12, 12] -->
| Component | Instance Type | vCPU | Memory | Count | AZ Distribution |
|-----------|---------------|------|--------|-------|-----------------|
| SageMaker Inference Endpoint (sepsis) | ml.m5.xlarge | 4 | 16 GB | 2 (auto-scale 2–6) | Multi-AZ managed by SageMaker |
| SageMaker Inference Endpoint (readmission) | ml.m5.xlarge | 4 | 16 GB | 2 (auto-scale 2–4) | Multi-AZ managed by SageMaker |
| SageMaker Inference Endpoint (rapid-response) | ml.m5.xlarge | 4 | 16 GB | 2 (auto-scale 2–4) | Multi-AZ managed by SageMaker |
| SageMaker Inference Endpoint (ensemble) | ml.m5.xlarge | 4 | 16 GB | 2 (auto-scale 2–4) | Multi-AZ managed by SageMaker |
| SageMaker Training Jobs (weekly retraining) | ml.p3.2xlarge | 8 | 61 GB | On-demand (1 per training run) | Single-AZ on-demand |
| ECS Fargate (Clinical Dashboard) | Fargate vCPU/Mem | 2 vCPU | 4 GB | 4 tasks (auto-scale 4–12) | 2 tasks per AZ (3 AZs) |
| ECS Fargate (API Backend) | Fargate vCPU/Mem | 2 vCPU | 4 GB | 4 tasks (auto-scale 4–12) | 2 tasks per AZ (3 AZs) |
| RDS Aurora PostgreSQL (Primary) | db.r6g.large | 2 | 16 GB | 1 (Multi-AZ with 1 replica) | Primary + replica in separate AZs |
| RDS Aurora Read Replica | db.r6g.large | 2 | 16 GB | 1 | Separate AZ from primary |
| ElastiCache Redis (Cluster Mode Off) | cache.r7g.large | 2 | 13 GB | 2 (primary + replica, Multi-AZ) | Primary + replica in separate AZs |
| Amazon MSK (Kafka Brokers) | msk.m5.large | 2 | 8 GB | 3 (one per AZ) | 1 broker per AZ (3 AZs) |
| Amazon Redshift (Analytics) | ra3.xlplus | 4 | 32 GB | 1 node | Single-AZ (analytics only; no SLA impact) |
| NAT Gateway | AWS Managed | N/A | N/A | 2 (one per AZ) | 2 AZs (us-east-1a, us-east-1b) |
| Application Load Balancer (Dashboard) | AWS Managed | N/A | N/A | 1 (multi-AZ) | Multi-AZ automatically |
| Application Load Balancer (FHIR Inbound) | AWS Managed | N/A | N/A | 1 (multi-AZ) | Multi-AZ automatically |

## High Availability Design

Every component in the production data path is deployed across multiple Availability Zones to achieve the 99.95% availability SLA without requiring a regional failover for most failure scenarios.

- **Multi-AZ Compute:** ECS Fargate tasks are distributed across 3 AZs using ECS Service Placement Strategies (spread across AZs). ALB automatically routes traffic to healthy tasks only; unhealthy tasks are replaced by ECS within 60–90 seconds.
- **Multi-AZ Database:** RDS Aurora PostgreSQL (Multi-AZ) maintains a synchronous hot standby replica in a separate AZ. Automated failover to the standby occurs within 30–60 seconds of primary instance failure with no application code changes required (Aurora DNS endpoint remains constant).
- **Multi-AZ Cache:** ElastiCache Redis with one primary (us-east-1a) and one replica (us-east-1b); automatic failover to replica on primary failure within 60 seconds.
- **Multi-AZ Kafka:** Amazon MSK brokers are distributed one per AZ (us-east-1a, us-east-1b, us-east-1c); topic replication factor of 3 ensures no data loss on single-broker failure.
- **SageMaker Multi-AZ:** SageMaker Real-Time Inference endpoints are deployed with a minimum of 2 instances across multiple AZs; auto-scaling policy maintains ≥ 2 instances at all times. ALB distributes inference requests across healthy endpoint instances.
- **Kinesis High Availability:** Kinesis Data Streams replicates shard data synchronously across 3 AZs within us-east-1; single-AZ failure does not affect Kinesis availability.
- **Health Checks:** ALB target group health checks (HTTP GET /api/v1/health every 10 seconds; 2 consecutive failures = unhealthy); Route 53 health checks on ALB DNS endpoints (every 30 seconds; synthetic HTTP request).

## Disaster Recovery

The CDS Platform operates in an active/passive multi-region configuration. The us-east-1 (primary) region is always serving live clinical traffic. The us-west-2 (passive) region maintains a warm standby infrastructure provisioned via the same Terraform/CDK IaC modules, with data replicated from the primary region. Regional failover is triggered by Route 53 health check failure on the primary region ALB endpoint.

- **RPO:** ≤ 15 minutes — based on HealthLake daily FHIR export to S3 (supplemented by S3 cross-region replication of the raw event archive; most recent events recoverable from Kinesis enhanced fan-out with 24-hour data retention) and Aurora cross-region replication lag (typically < 1 second under normal operating conditions).
- **RTO:** ≤ 4 hours — Route 53 DNS failover to us-west-2 within 30 seconds (passive standby ECS tasks pre-scaled to minimum instance count); database recovery from Aurora cross-region read replica promotion (15–30 minutes); SageMaker endpoints in us-west-2 pre-deployed in low-utilization standby mode; full clinical functionality restored within 4 hours.
- **Backup Strategy:** RDS Aurora: automated nightly snapshots with 35-day retention; continuous PITR enabled. S3: cross-region replication to us-west-2 in real-time for all data lake buckets. HealthLake: daily FHIR export to S3 (Object Lock). ElastiCache Redis: automatic daily snapshots with 7-day retention. Redshift: automated nightly snapshots with 7-day retention.
- **DR Site:** us-west-2 passive standby; Terraform/CDK IaC deploys a mirror of the us-east-1 infrastructure; RDS Aurora global database cross-region read replica is pre-provisioned and can be promoted to primary within 1 minute of initiating failover.
- **Failover Testing:** Annual DR drill (region failover test) using Route 53 health check suppression in staging environment; results documented in Test Results Report; pass criteria: RTO ≤ 4 hours, RPO ≤ 15 minutes, no permanent PHI data loss.

## Monitoring & Alerting

The observability stack combines AWS-native monitoring (CloudWatch + X-Ray) with Datadog APM for enhanced application-level visibility and PagerDuty-integrated on-call escalation.

- **Infrastructure Metrics:** CloudWatch monitors CPU utilization, memory utilization, and network throughput for all ECS tasks, RDS Aurora, ElastiCache, MSK brokers, and SageMaker endpoints. Alarms on: ECS CPU > 80% for 3 consecutive periods; Aurora replica lag > 5 seconds; ElastiCache eviction rate > 100/minute; MSK broker disk utilization > 70%.
- **Application Metrics:** CloudWatch custom metrics capture: end-to-end inference latency (P50/P95/P99 per model); Kinesis DLQ depth; SageMaker endpoint invocation errors; Bedrock invocation latency; alert delivery success rate; feature vector cache hit ratio (ElastiCache).
- **Business Metrics / KPIs:** Amazon QuickSight dashboards (refreshed every 15 minutes) track: sepsis alert volume and false-positive dismissal rate per facility; model AUROC trend (weekly); clinical staff active dashboard logins per facility (adoption tracking); 30-day readmission rate vs. baseline (monthly).
- **Alerting:** CloudWatch Alarms → SNS → PagerDuty for on-call escalation during hypercare. Post-hypercare: SNS → MedCore IT Operations email/PagerDuty. Critical alarms trigger immediate paging; High alarms trigger email with 4-hour response SLA.

### Alert Definitions

The following table defines the primary operational alerts configured in CloudWatch with their escalation severity and expected response actions.

<!-- TABLE_CONFIG: widths=[28, 27, 15, 30] -->
| Alert | Condition | Severity | Response |
|-------|-----------|----------|----------|
| Inference Latency Breach | SageMaker endpoint P95 latency > 3,000 ms for 2 consecutive 1-minute periods | Critical | Page on-call engineer; check endpoint CPU utilization and auto-scaling status; initiate rollback if recently deployed |
| Kinesis DLQ Non-Empty | DLQ depth > 0 messages for 5 minutes | High | Investigate dead-lettered messages for schema validation errors; check Epic FHIR connector logs |
| Platform Unavailability | ALB 5xx error rate > 5% for 3 consecutive 1-minute periods | Critical | Page on-call engineer; check ECS task health; verify RDS Aurora connectivity; initiate DR runbook if primary region issue |
| SageMaker Endpoint Error Rate | Endpoint invocation error rate > 2% for 5 minutes | Critical | Check model logs; validate Feature Store record completeness; roll back model version if recently promoted |
| RDS Aurora Replication Lag | Aurora replica lag > 5 seconds for 10 consecutive minutes | High | Investigate network bandwidth between primary and replica; scale up instance class if sustained |
| GuardDuty Critical Finding | Any GuardDuty finding with severity ≥ 7.0 | Critical | Page CISO on-call; isolate affected resource per incident response runbook; initiate Security Hub investigation |
| HealthLake Import Failure | Daily HealthLake FHIR import job returns FAILED status | High | Investigate source S3 payload; check FHIR resource validation errors; retry import job |
| Bedrock Quota Exhaustion | Bedrock InvokeModel ThrottlingException rate > 10/minute for 5 minutes | High | Submit AWS quota increase request; implement narrative generation fallback (skip narrative; deliver alert without Bedrock summary) |
| ElastiCache Eviction Rate | Redis eviction rate > 100 keys/minute sustained for 10 minutes | High | Increase cache node memory or add read replicas; check for unexpected TTL expiry patterns |
| MSK Broker Disk Utilization | Any MSK broker disk > 70% utilized | High | Increase broker storage; review message retention policy; scale Kinesis-to-MSK consumer lag |
| CloudTrail Log Delivery Failure | CloudTrail stops delivering logs to S3 for > 15 minutes | Critical | Page CISO; investigate S3 bucket policy; check KMS CMK status; resume log delivery immediately |
| Config Non-Compliance | Any AWS Config rule returns NON_COMPLIANT for a PHI-related resource | High | Investigate specific Config rule finding; remediate within 24 hours (Critical findings) or 7 days (High findings) per governance SLA |

## Logging & Observability

A comprehensive observability strategy provides the MedCore IT team and Amatra engineers with full visibility into the platform's operational state at every layer.

- **Log Aggregation:** All ECS Fargate task logs and Lambda function logs are delivered to Amazon CloudWatch Logs in structured JSON format. Datadog APM agent collects logs from ECS task containers (via Docker log driver) and SageMaker endpoint containers, providing log indexing, search, and correlation with APM traces. Log retention: 90 days in CloudWatch Logs; 15 days in Datadog (indexed); 1 year in S3 archive (compressed GZIP).
- **Distributed Tracing:** AWS X-Ray provides end-to-end distributed traces across the inference path: from Kinesis consumer Lambda → Feature Store → ElastiCache → SageMaker endpoint → Bedrock → EventBridge → SNS. X-Ray service map identifies latency hotspots contributing to the 3-second SLA. Datadog APM complements X-Ray with APM-level spans on all ECS service-to-service calls.
- **Dashboards:** Four operational CloudWatch dashboards are provisioned: (1) Ingestion Pipeline (Kinesis throughput, DLQ depth, FHIR connector errors, HL7 adapter errors); (2) ML Inference (per-endpoint P50/P95/P99 latency, invocation error rate, Bedrock latency); (3) Application (ECS task CPU/memory, ALB request rate, 5xx rate, Cognito authentication events); (4) Compliance (GuardDuty finding count, Config compliance percentage, CloudTrail delivery status, KMS key usage).

## Cost Model

The following cost model is based on the Infrastructure Costs Schedule produced during pre-sales. Monthly estimates reflect full 18-hospital utilization (steady-state Year 2 run rate). Year 1 costs include one-time setup activities; Year 3 includes growth factors for Bedrock token volume and Kinesis throughput.

<!-- TABLE_CONFIG: widths=[28, 22, 22, 14, 14] -->
| Category | Monthly Estimate (Year 2) | Annual (Year 2) | Year 3 (Annual) | Optimization |
|----------|--------------------------|-----------------|-----------------|--------------|
| SageMaker Inference (×4 endpoints) | $1,680 | $20,160 | $22,176 | 1-year Reserved Instance; auto-scale down during low-census overnight hours |
| Amazon HealthLake | $1,800 | $21,600 | $23,760 | Storage lifecycle; archive inactive FHIR resources to S3 Glacier after 2 years |
| Amazon Bedrock (Claude) | $1,400 | $16,800 | $19,320 | Prompt template optimization to reduce token count; cache repeated narrative patterns |
| Amazon MSK | $645 | $7,740 | $7,740 | Reserved Instance pricing; right-size to msk.m5.large at current throughput |
| Amazon Redshift | $650 | $7,800 | $7,800 | Reserved Node pricing; query optimization to avoid full-table scans |
| RDS Aurora PostgreSQL | $680 | $8,160 | $8,160 | 1-year Reserved Instance; auto-pause read replica outside business hours |
| Amazon Kinesis Data Streams | $150 | $1,800 | $1,980 | Scale shards dynamically during low-activity hours; Kinesis On-Demand pricing evaluation |
| Amazon ElastiCache Redis | $430 | $5,160 | $5,160 | 1-year Reserved Node; right-size after 90 days of production cache hit ratio data |
| ECS Fargate (Dashboard + API) | $520 | $6,240 | $6,240 | Fargate Spot for non-production environments; right-size task CPU/memory post-go-live |
| SageMaker Training Jobs | $680 | $8,160 | $8,160 | On-demand ml.p3.2xlarge only when training; Spot training for non-time-sensitive retraining |
| Data Transfer + NAT Gateway | $320 | $3,840 | $4,224 | Maximize PrivateLink usage to minimize NAT Gateway egress; S3 VPC Endpoint for all S3 traffic |
| Security Services (GuardDuty, Config, WAF, KMS, CloudTrail) | $393 | $4,716 | $4,716 | Non-negotiable compliance controls; no optimization |
| Connectivity (Direct Connect + VPN) | $786 | $9,432 | $9,432 | Fixed cost; Direct Connect provides predictable pricing vs. data transfer charges |
| AWS Business Support | $1,800 | $21,600 | $21,600 | Required for 99.95% SLA; non-negotiable for clinical platform |
| Software Licenses (Datadog + Snyk) | $920 | $11,040 | $11,040 | Datadog host count optimization; evaluate Snyk tier as container count stabilizes |
| **Total Infrastructure + Support** | **~$11,654** | **~$153,948** | **~$161,508** | 3-year total ~$489,456 (excluding credits); 1-year Reserved Instance savings ~$18K applied |

---

# Implementation Approach

The CDS Platform is delivered through five sequential-but-overlapping project phases over a 14-month engagement, designed to achieve three firm production milestones: Phase 1 go-live (sepsis model + ingestion pipeline) by 2026-10-31, Phase 2 deployment (readmission + rapid-response models + clinical dashboard) by 2027-02-28, and General Availability across all 18 hospitals by 2027-06-30. The implementation approach is shaped by the Phase 1 hard deadline, the clinical safety requirements of a live patient system, and the regulatory complexity of a HIPAA-compliant ML platform.

## Migration/Deployment Strategy

The CDS Platform is a greenfield AWS implementation with no legacy system migration required. The deployment strategy is designed to enable safe, incremental activation of clinical alerting capabilities while maintaining the existing Epic rule-based system as a backstop throughout the rollout period.

- **Approach:** Greenfield build with phased clinical activation. Infrastructure is provisioned in full across all four environments (Dev, QA, Staging, Production) before any clinical workloads are activated. Capabilities are activated incrementally: Phase 1 (sepsis model + ingestion pipeline), Phase 2 (additional models + dashboard), Phase 3 (full facility rollout).
- **Pattern:** Blue/Green deployment for all SageMaker inference endpoint promotions and all ECS Fargate application deployments. Blue/Green ensures zero-downtime deployments for a life-safety platform; automated rollback eliminates risk from failed endpoint promotions.
- **Validation:** Shadow mode activation for Phase 1 — the CDS Platform generates alerts internally but does not deliver them to clinical staff for 48 hours post-cutover. The Amatra team and Clinical Informatics Lead validate alert volume, latency metrics, and model output quality against pre-defined thresholds before authorizing live alert delivery.
- **Rollback:** Automated CI/CD rollback on P95 latency breach (> 3 seconds within 30 minutes of deployment); manual rollback available via a single CodePipeline execution restoring the previous SageMaker model version and ECS task definition. Target rollback time: ≤ 15 minutes. Epic rule-based system remains active as clinical safety backstop throughout Phase 1 hypercare (minimum 2 weeks post-cutover).

## Sequencing & Wave Planning

The implementation is sequenced to deliver the Phase 1 hard deadline while building reusable infrastructure for Phases 2 and 3. Phases 2 and 3 of the ML model development (SOW Phases 3 and 5) overlap with Phase 2 infrastructure build (SOW Phase 2) to optimize the schedule.

<!-- TABLE_CONFIG: widths=[10, 32, 18, 40] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 — Discovery & Architecture Design | Project kickoff; clinical workflow discovery; Epic FHIR R4 and Mirth Connect topology assessment; HIPAA requirements workshops; gap analysis; detailed architecture design; security design; IaC standards definition | Weeks 1–5 | Assessment Report approved by CMO and CIO; HLD, LLD, Security Architecture, and FHIR mapping documents signed off (M1 + M2) |
| 2 — Environment Build & Data Pipeline | Provision Dev/QA/Staging/Production via Terraform/CDK; configure Transit Gateway and PrivateLink to Mirth Connect; build Kinesis + MSK ingestion pipeline; provision HealthLake and Feature Store; implement Azure AD / Cognito SSO; implement KMS encryption and HIPAA audit logging; build CI/CD pipelines | Weeks 6–14 | All 4 environments provisioned; live synthetic HL7 FHIR and HL7 v2.3 data flowing end-to-end to HealthLake and Feature Store (M3 + M4) |
| 3 — ML Model Development & Integration | Develop and train sepsis model (Phase 1 priority); build SHAP explainability pipeline; implement Bedrock narrative integration; build alert routing service; develop clinical dashboard (React/Amplify); build QuickSight dashboards; implement Config + Lambda compliance automation (Phases 2 and 3 models: readmission and rapid-response, overlapping Weeks 8–20) | Weeks 8–30 | Sepsis model AUROC ≥ 0.85 validated; Phase 1 in production by 2026-10-31 (M5); readmission and rapid-response models + dashboard deployed by 2027-02-28 (M6) |
| 4 — Testing & Validation | Develop test plan; functional testing (pipeline, inference, dashboard); integration testing (Epic FHIR end-to-end, HL7 v2.3 at production throughput); load testing (< 3-second latency at peak); multi-region failover test; model accuracy validation; LLM narrative quality review; HIPAA security controls validation; external pen test coordination; SOC 2 readiness review; UAT at pilot facility | Weeks 18–24 (overlaps Phase 3) | Test Results Report approved; CISO security sign-off; CMO/CIO go-live clearance; all Critical/High defects resolved (M7) |
| 5 — Production Rollout, Handover & Hypercare | Phase 3 full facility rollout across all 18 hospitals (cohort-based, per-facility UAT sign-off); operational runbooks delivery; IT and data engineering knowledge transfer sessions; clinical train-the-trainer program; final as-built documentation and IaC repository handover; 8-week hypercare support | Weeks 22–30+ | GA across all 18 hospitals by 2027-06-30; hypercare period complete Q3 2027 + 8 weeks (M8 + M9) |

## Tooling & Automation

The following table summarizes the tooling selection across all delivery and operational dimensions. All tooling selections trace to the SOW Tooling Overview and are constrained to the agreed technology stack.

<!-- TABLE_CONFIG: widths=[28, 30, 42] -->
| Category | Tool | Purpose |
|----------|------|---------|
| Infrastructure as Code | Terraform + AWS CDK | All four-environment provisioning; enforces no manual console changes in production via SCP; CDK for Lambda/ECS constructs; Terraform for VPC, MSK, RDS, ElastiCache, Direct Connect |
| CI/CD Pipeline | AWS CodePipeline + CodeBuild | Application and model deployment pipelines; blue/green inference endpoint promotion; automated rollback on latency breach |
| Container Security | Snyk (Business tier) | Container image scanning for ECS workloads; blocks deployments with Critical or High CVEs; shift-left security for HIPAA posture |
| ML Pipeline Orchestration | SageMaker Pipelines | Model training workflow orchestration; step functions for data prep, training, evaluation, and model registration; weekly retraining automation |
| Model Versioning | SageMaker Model Registry | Governs model version promotion from dev → staging → production; maintains AUROC and validation metrics per model version |
| Feature Store | SageMaker Feature Store | Online feature groups for real-time inference; offline feature groups for model retraining; version-controlled feature definitions |
| Data Ingestion | Amazon Kinesis Data Streams | Real-time HL7 FHIR R4 and HL7 v2.3 event streaming; 10-shard configuration; DLQ for malformed messages |
| Event Bus | Amazon MSK (Kafka) | Internal event bus decoupling ingestion from Feature Store pipeline; 3-broker cluster; topic partitioning by PatientID |
| Load Testing | AWS Distributed Load Testing + Locust | FHIR API simulation for 18-hospital concurrent patient event load; validates < 3-second P95 latency at peak |
| Model Explainability | SHAP (Python shap library in SageMaker container) | Per-inference SHAP feature importance values; bundled with every alert payload |
| LLM Integration | Amazon Bedrock (Claude 3) | Clinical narrative generation for bedside alert summaries; validated prompt templates; < 1-second P95 target |
| Monitoring | Amazon CloudWatch + AWS X-Ray + Datadog APM | CloudWatch: infrastructure metrics and alarms; X-Ray: distributed traces for inference latency; Datadog APM: application-level traces and PagerDuty on-call integration |
| Security Scanning | Amazon GuardDuty + AWS Security Hub + Amazon Macie + Snyk | GuardDuty: ML threat detection; Security Hub: findings aggregation; Macie: PHI data classification in S3; Snyk: container vulnerability scanning |
| Configuration Compliance | AWS Config + AWS Lambda | Continuous HIPAA and SOC 2 configuration compliance monitoring; automated remediation for common drift scenarios |
| Incident Management | PagerDuty (MedCore account) | On-call escalation for Critical and High CloudWatch alarms; integrated with SNS during hypercare |
| Version Control | MedCore GitHub / AWS CodeCommit | All IaC modules, application code, ML pipeline definitions, and documentation; branch protection on main/production branches |

## Cutover Approach

Phase 1 production cutover (targeting 2026-10-31) will follow a blue/green + shadow mode approach to eliminate clinical risk from the initial activation.

- **Type:** Phased activation with 48-hour shadow period before live alert delivery.
- **Duration:** 48-hour shadow period (alerts generated internally, not delivered to clinical staff) followed by Clinical Informatics Lead authorization of live delivery flip; then 2-week parallel run of the CDS Platform and Epic rule-based system before rule-based system is formally decommissioned at that facility.
- **Validation:** During the shadow period, the Amatra team and Clinical Informatics Lead review: alert volume (expected ~50–200 alerts/day at pilot facility), P95 inference latency (must be < 3 seconds), model output distribution (risk score distribution consistent with training data characteristics), Bedrock narrative quality (CLIN review of 20 randomly sampled narratives), and absence of DLQ messages.
- **Decision Point:** Go/no-go decision is made jointly by the Clinical Informatics Lead and the Amatra Technical Lead at the end of the 48-hour shadow period. If all shadow validation criteria are met, the EventBridge routing rules are updated (via CodePipeline execution) to enable live alert delivery. If criteria are not met, the Amatra team investigates and extends the shadow period. No go-live proceeds without Clinical Informatics Lead written sign-off.

## Downtime Expectations

- **Planned Downtime:** Zero planned downtime for clinical alert delivery during Phase 1 or Phase 3 facility activations. Blue/green deployments and multi-AZ infrastructure ensure continuous availability during all deployment activities. Maintenance windows (for RDS Aurora minor version upgrades, ECS task definition updates) are scheduled during low-clinical-activity hours (02:00–04:00 ET on weekends) and executed during the Staging validation cycle first.
- **Unplanned Downtime:** MTTR target for Critical incidents during hypercare: ≤ 4 hours (aligns to the 99.95% SLA allowance of approximately 4.4 hours/month). AZ failure scenarios: ≤ 5 minutes to full recovery (multi-AZ auto-healing). Regional failure scenarios: ≤ 4 hours (Route 53 DNS failover to us-west-2 passive standby).
- **Mitigation:** The Epic rule-based alert system serves as the clinical safety backstop during Phase 1 hypercare. MedCore's CMO and Clinical Informatics Lead must confirm the backstop activation protocol is understood by nursing staff before Phase 1 live alert delivery commences.

## Rollback Strategy

A comprehensive rollback capability is maintained at every layer of the platform throughout the engagement.

- **Infrastructure rollback:** Any Terraform/CDK change can be reverted by executing the previous IaC commit via CodePipeline. Terraform state is stored in an S3 backend with versioning enabled; any prior state can be restored.
- **Application rollback:** ECS Fargate task definition rollback via CodePipeline execution; previous task definition revision is retained in ECS for 30 versions.
- **Model rollback:** Previous SageMaker model version is retained in the Model Registry with a minimum retention of 6 months. Rollback to the previous production model endpoint is triggered automatically by CI/CD on P95 latency breach (> 3 seconds within 30 minutes of deployment) or manually by the Amatra Technical Lead or MedCore CIO at any time during the cutover window. Target model rollback time: ≤ 15 minutes.
- **Database rollback:** RDS Aurora PITR enables restoration to any second within the 35-day retention window. ElastiCache Redis can be restored from the most recent automatic daily snapshot (RPO ≤ 24 hours for cache; runtime data re-populates from the Feature Store within minutes).
- **Maximum rollback window:** The Epic rule-based system is available as a full platform rollback for the Phase 1 hypercare period (8 weeks post-GA). After hypercare, rollback from the CDS Platform requires re-activation of Epic CDS Hooks rules, which is a manual process coordinated by MedCore's EHR Integration Lead.

---

# Appendices

This section provides supporting reference material for the Detailed Design Document, including architecture diagram references, naming conventions, tagging standards, risk register, and glossary.

## Architecture Diagrams

The following diagrams are referenced or produced as part of this engagement.

- **Solution Architecture Diagram** (included in Section 4 — Solution Architecture): End-to-end view of the CDS Platform architecture including ingestion, feature, inference, LLM, alert routing, dashboard, and multi-AZ/multi-region HA layers. Source: `assets/diagrams/architecture-diagram.png`.
- **Network Topology Diagram:** VPC subnet layout, AZ distribution, Transit Gateway connectivity to Direct Connect, PrivateLink endpoints, and NAT Gateway placement. To be produced as part of SOW Deliverable #6 (HLD/LLD Architecture Documents).
- **Data Flow Diagram:** End-to-end data lineage from Epic FHIR R4 / Mirth Connect HL7 v2.3 sources through Kinesis, HealthLake, SageMaker Feature Store, inference, Bedrock, alert routing, dashboard, and nightly SQL Server export. To be produced as SOW Deliverable #7 (Data Flow Diagrams & FHIR Resource Mapping Specification).
- **Security Architecture Diagram:** Defense-in-depth security controls across all platform layers including IAM roles, KMS CMK assignments, PrivateLink endpoints, WAF placement, GuardDuty scope, CloudTrail trail boundary, and RBAC topology. To be produced as SOW Deliverable #8 (Security Architecture Document).

## Naming Conventions

All AWS resources are named using the following convention to ensure consistent resource identification, cost allocation, and IaC management across all environments and AWS accounts.

<!-- TABLE_CONFIG: widths=[28, 38, 34] -->
| Resource Type | Pattern | Example |
|---------------|---------|---------|
| VPC | `medcore-cds-{env}-vpc` | `medcore-cds-prod-vpc` |
| Subnet | `medcore-cds-{env}-{tier}-{az}` | `medcore-cds-prod-app-use1a` |
| ECS Cluster | `medcore-cds-{env}-cluster` | `medcore-cds-prod-cluster` |
| ECS Service | `medcore-cds-{env}-{service-name}` | `medcore-cds-prod-dashboard-api` |
| Lambda Function | `medcore-cds-{env}-{function-name}` | `medcore-cds-prod-fhir-connector` |
| SageMaker Endpoint | `medcore-cds-{env}-{model-name}-ep` | `medcore-cds-prod-sepsis-ep` |
| SageMaker Pipeline | `medcore-cds-{env}-{model-name}-pipeline` | `medcore-cds-prod-sepsis-pipeline` |
| RDS Cluster | `medcore-cds-{env}-aurora-cluster` | `medcore-cds-prod-aurora-cluster` |
| ElastiCache Cluster | `medcore-cds-{env}-redis` | `medcore-cds-prod-redis` |
| MSK Cluster | `medcore-cds-{env}-kafka` | `medcore-cds-prod-kafka` |
| Kinesis Stream | `medcore-cds-{env}-events` | `medcore-cds-prod-events` |
| S3 Bucket | `medcore-cds-{env}-{purpose}-{aws-account-id}` | `medcore-cds-prod-datalake-123456789012` |
| KMS Key (alias) | `alias/medcore-cds-{env}-{datastore}` | `alias/medcore-cds-prod-healthlake` |
| Cognito User Pool | `medcore-cds-{env}-users` | `medcore-cds-prod-users` |
| IAM Role | `medcore-cds-{env}-{service}-role` | `medcore-cds-prod-inference-lambda-role` |
| CloudWatch Log Group | `/medcore-cds/{env}/{service}` | `/medcore-cds/prod/fhir-connector` |
| CodePipeline Pipeline | `medcore-cds-{env}-{pipeline-name}` | `medcore-cds-prod-sepsis-endpoint-deploy` |

*Abbreviations: env = dev/qa/stg/prod; az = use1a/use1b/use1c (us-east-1), usw2a/usw2b/usw2c (us-west-2)*

## Tagging Standards

All AWS resources must be tagged with the following mandatory tags at creation time. Tags are enforced via AWS Config rules that generate a non-compliant finding for any resource missing a required tag within 15 minutes of creation. IaC modules include default tags applied to all resources as a Terraform `default_tags` or CDK `Tags.of(scope).add()` declaration.

<!-- TABLE_CONFIG: widths=[22, 12, 36, 30] -->
| Tag | Required | Example Values | Purpose |
|-----|----------|----------------|---------|
| Environment | Yes | dev, qa, staging, prod | Environment identification; cost allocation |
| Application | Yes | medcore-cds | Cost allocation; resource grouping |
| Owner | Yes | amatra-delivery, medcore-it | Accountability; incident routing |
| CostCenter | Yes | MedCore-ClinicalApps-2026 | MedCore IT budget tracking |
| DataClassification | Yes | phi-restricted, sensitive, internal | HIPAA data classification enforcement |
| Compliance | Yes | hipaa, soc2, hitech | Compliance scope identification for AWS Config |
| Phase | Yes | phase1, phase2, phase3 | Project phase tracking for cost allocation |
| CreatedBy | Yes | terraform, cdk, awscli | Change audit trail |
| ManagedBy | Yes | amatra, medcore-it | Post-handover operational ownership |

## Risk Register

The following risk register identifies the primary risks to the CDS Platform delivery and operation, with likelihood, impact, and mitigation strategies. The Risk Register is a living document maintained by the Amatra Project Manager and reviewed at each phase kick-off and in the weekly status report.

<!-- TABLE_CONFIG: widths=[30, 12, 14, 44] -->
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Phase 1 hard deadline (2026-10-31) slip due to Epic FHIR R4 API access delays | Medium | Critical | Epic FHIR R4 sandbox access is a Week 2 critical path dependency; formal escalation to MedCore CIO if not provided by Week 2; schedule re-baseline triggered if access delayed beyond Week 4 |
| Sepsis model AUROC below 0.85 threshold on first validation run | Medium | High | Early model training iteration in Dev environment during Phase 2 build; Clinical Informatics Lead engaged weekly during feature engineering; fallback to ensemble approach (XGBoost + LightGBM) if single-model AUROC insufficient |
| Direct Connect circuit provisioning delay (MedCore responsibility) | Medium | High | Site-to-site VPN available as immediate fallback for development and QA; Direct Connect required by Week 8; formal escalation to MedCore CIO at Week 6 if circuit not yet ordered |
| PHI data quality issues in training dataset (missing lab values, sparse LOINC codes) | High | High | Data quality assessment completed in Discovery phase; FHIR R4 resource completeness scored before Feature Store ingestion; low-completeness records flagged as `low_confidence` and excluded from initial training set; additional data enrichment SOW change request if coverage is insufficient |
| Azure AD SAML 2.0 federation configuration delays (MedCore identity team) | Low | Medium | SAML integration is a Week 10 dependency; Cognito can operate with local user pool as interim during Dev/QA testing; formal escalation to MedCore CIO if Azure AD metadata not provided by Week 8 |
| Amazon Bedrock (Claude) latency exceeds 1.5-second P95 target at production token volume | Medium | High | Prompt template optimization during Phase 2 development to minimize token count; narrative caching for repeated patient contexts; fallback plan: deliver alert without Bedrock narrative if Bedrock P95 > 2 seconds (SHAP explanation still delivered) |
| SageMaker endpoint latency exceeds 3-second SLA under full 18-hospital load | Low | Critical | Load testing at production-representative scale in staging before Phase 1 go-live; auto-scaling policy pre-configured; instance type upgrade path (ml.m5.2xlarge) available if ml.m5.xlarge insufficient at peak |
| HIPAA audit logging gap discovered during security validation | Low | Critical | CloudTrail enabled from Day 1 of environment provisioning; HIPAA controls validation checklist executed by Security Engineer in Week 18; CISO sign-off is a go-live gate; no PHI in production until full audit logging validated |
| Per-facility Epic FHIR subscription activation delays during Phase 3 rollout | High | Medium | Per-facility activation is a MedCore EHR Integration Lead responsibility; Amatra provides runbook and remote support; cohort-based rollout schedule planned with 2-week buffer between facility cohorts; delays in one cohort do not block subsequent cohorts |
| Clinical staff adoption below 75% target within 90 days | Medium | High | Train-the-trainer program with facility Clinical Champions; dashboard UX validated in UAT before go-live; adoption tracked weekly in QuickSight; facility-specific adoption plans developed where lagging; CMO executive sponsorship is primary adoption driver |
| AWS service disruption (us-east-1 regional outage) | Low | Critical | Active/passive multi-region DR to us-west-2; Route 53 health-check-driven DNS failover; annual DR drill validates RTO ≤ 4 hours; Epic rule-based system provides clinical backstop during regional failover |
| Scope creep from additional ML model requests or facility count increase | Medium | Medium | Formal change control process per SOW Terms; Change Order required for any scope addition; Amatra PM reviews all clinical requests for scope impact before any work begins; additional models require separate SOW |

## Glossary

The following terms and abbreviations are used throughout this document.

<!-- TABLE_CONFIG: widths=[20, 80] -->
| Term | Definition |
|------|------------|
| AUROC | Area Under the Receiver Operating Characteristic Curve — a model performance metric between 0.0 and 1.0 indicating the model's ability to discriminate between positive (at-risk) and negative (not at-risk) patient cases |
| BAA | Business Associate Agreement — a HIPAA-required contract between a covered entity (MedCore) and a business associate (Amatra, AWS) governing PHI handling obligations |
| Bedrock | Amazon Bedrock — an AWS fully managed service providing access to foundation language models (including Anthropic Claude) via API, within the AWS HIPAA BAA boundary |
| CDK | AWS Cloud Development Kit — an open-source framework for defining cloud infrastructure in TypeScript/Python and synthesizing it as AWS CloudFormation templates |
| CDS | Clinical Decision Support — software tools that provide clinicians with patient-specific information and assessments at relevant points in care delivery to enhance health and healthcare delivery |
| CDS Hooks | An HL7 standard for embedding CDS suggestions into the EHR clinical workflow; used by the CDS Platform to write risk score alerts into the Epic EHR workflow |
| CMK | Customer Managed Key — an AWS KMS encryption key owned and controlled by MedCore (rather than AWS), providing exclusive key policy control and audit logging |
| CMO | Chief Medical Officer — MedCore's executive sponsor for clinical outcomes; accountable for model performance sign-off and go-live approval |
| CISO | Chief Information Security Officer / Privacy Officer — MedCore's authority for HIPAA compliance sign-off, PHI data-handling governance, and security testing gate approval |
| Direct Connect | AWS Direct Connect — a dedicated physical network connection from MedCore's Nashville data center to AWS us-east-1, providing private, low-latency, high-bandwidth connectivity |
| DLQ | Dead-Letter Queue — an Amazon SQS queue that receives messages that cannot be processed successfully by the primary consumer, enabling out-of-band investigation without blocking the main pipeline |
| ECS Fargate | Amazon Elastic Container Service (Fargate launch type) — a serverless container orchestration service that runs Docker containers without requiring management of underlying EC2 instances |
| EventBridge | Amazon EventBridge — a serverless event bus that routes events between AWS services based on configurable routing rules; used for alert routing by clinical role and facility |
| Feature Store | Amazon SageMaker Feature Store — a managed repository for ML feature vectors supporting both real-time (online) retrieval for inference and historical (offline) access for model retraining |
| FHIR | Fast Healthcare Interoperability Resources — an HL7 standard for the exchange of healthcare information in electronic form; FHIR R4 is the current version used for Epic integration |
| GuardDuty | Amazon GuardDuty — an AWS threat detection service that continuously analyzes CloudTrail, VPC Flow Logs, and DNS logs using ML to identify unusual API activity, credential compromise, and network-level anomalies |
| HealthLake | Amazon HealthLake — an AWS HIPAA-eligible, FHIR R4-compliant managed datastore for storing, transforming, and querying health data at scale |
| HITECH | Health Information Technology for Economic and Clinical Health Act — US legislation that strengthens HIPAA breach notification requirements and extends HIPAA obligations to business associates |
| HL7 | Health Level Seven International — the standards development organization producing FHIR (HL7 FHIR) and the older HL7 v2.x messaging standard used by Mirth Connect |
| IAM | AWS Identity and Access Management — the AWS service governing authentication and authorization for all AWS API calls via users, roles, and policies |
| IaC | Infrastructure as Code — the practice of provisioning and managing cloud infrastructure through version-controlled code (Terraform/CDK) rather than manual console operations |
| IDN | Integrated Delivery Network — a healthcare organization that combines multiple hospitals, clinics, and services under common ownership and management; MedCore is a $1.4B regional IDN |
| KMS | AWS Key Management Service — the AWS service for creating and managing cryptographic keys used to encrypt data at rest across all PHI data stores in the CDS Platform |
| LLM | Large Language Model — a type of AI model trained on vast text corpora capable of generating human-like text; Amazon Bedrock (Claude) is the LLM used for clinical narrative generation |
| Macie | Amazon Macie — an AWS data security service that uses ML to automatically discover, classify, and protect sensitive data (including PHI) in Amazon S3 |
| MLLP | Minimum Lower Layer Protocol — the traditional transport protocol for HL7 v2.x messages over TCP/IP, used by Mirth Connect for bedside monitor HL7 v2.3 message delivery |
| MSK | Amazon Managed Streaming for Apache Kafka — a fully managed Apache Kafka service used as the internal event bus between the ingestion layer and Feature Store pipeline |
| PHI | Protected Health Information — individually identifiable health information protected under HIPAA; all patient data flowing through the CDS Platform is classified as PHI |
| PrivateLink | AWS PrivateLink — a networking technology enabling private connectivity from a VPC to AWS services and partner services without exposing traffic to the public internet |
| RDS Aurora | Amazon Aurora PostgreSQL — a MySQL/PostgreSQL-compatible managed relational database service with automatic Multi-AZ replication, automated backups, and PITR |
| RPO | Recovery Point Objective — the maximum acceptable amount of data loss measured in time; the CDS Platform RPO target is ≤ 15 minutes |
| RTO | Recovery Time Objective — the maximum acceptable time to restore service after a failure; the CDS Platform RTO target is ≤ 4 hours for a regional failover |
| SAML 2.0 | Security Assertion Markup Language 2.0 — an open standard for exchanging authentication and authorization data between an identity provider (Azure AD) and a service provider (Amazon Cognito) |
| SageMaker | Amazon SageMaker — an AWS fully managed ML platform providing tooling for model training, evaluation, deployment, monitoring, and feature management |
| SCPs | Service Control Policies — AWS Organizations policies that set maximum permissions for accounts within an OU; used to enforce IaC-only production changes and prevent PHI from leaving US regions |
| Security Hub | AWS Security Hub — an AWS service that aggregates security findings from GuardDuty, Config, Inspector, Macie, and partner tools into a unified compliance and security posture dashboard |
| SHAP | SHapley Additive exPlanations — a game-theoretic ML model interpretability technique that assigns each input feature a contribution value (SHAP value) for a given prediction; used to explain each risk score alert |
| SMART on FHIR | Substitutable Medical Applications and Reusable Technologies — a set of open specifications for apps that run on FHIR-enabled EHR systems; used for Epic FHIR R4 API OAuth 2.0 authentication |
| SOC 2 Type II | Service Organization Control 2 — an auditing framework assessing a service provider's controls relevant to security, availability, processing integrity, confidentiality, and privacy over a defined period (Type II = operating effectiveness) |
| Transit Gateway | AWS Transit Gateway — a network transit hub connecting VPCs, Direct Connect gateways, and VPN connections within an AWS region; used to route traffic from Mirth Connect to the CDS Platform VPC |
| UAT | User Acceptance Testing — structured testing conducted by clinical staff (nurses, physicians, administrators) to validate that the CDS Platform meets clinical workflow requirements before facility go-live |
| VPC | Virtual Private Cloud — an isolated virtual network within AWS providing private IP address space and network controls for all CDS Platform resources |
| WAF | AWS Web Application Firewall — a managed web application firewall that protects ALBs and API Gateway endpoints against OWASP Top 10 attacks and custom rule violations |
| WORM | Write Once Read Many — a data storage model ensuring records cannot be modified or deleted after creation; implemented via S3 Object Lock (Compliance mode) for CloudTrail audit logs and HealthLake backups |
| X-Ray | AWS X-Ray — a distributed tracing service that records and visualizes the end-to-end path of requests across microservices; used to diagnose latency breaches in the CDS inference pipeline |
