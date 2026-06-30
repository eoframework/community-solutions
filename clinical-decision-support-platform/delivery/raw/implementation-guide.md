---
document_title: Implementation Guide
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

## Project Overview

This Implementation Guide provides step-by-step procedures for deploying the MedCore Clinical Decision Support (CDS) Platform — an AWS-hosted, HIPAA-compliant, real-time AI/ML system that delivers risk scoring, LLM-powered clinical narratives, and role-based alerting across all 18 MedCore hospitals and 60+ outpatient clinics. It is the authoritative operational reference for Amatra's delivery team and MedCore's CIO, Clinical Informatics Lead, and CISO throughout all phases of the engagement. Every procedure described herein traces directly to a commitment made in Statement of Work OPP-2026-0047.

The platform continuously analyzes patient vitals, lab results, medication history, and EHR events ingested from Epic FHIR R4 and Mirth Connect HL7 v2.3 streams, generating actionable risk alerts powered by three custom ML models (sepsis, 30-day readmission, and rapid-response) and Amazon Bedrock (Claude) clinical narratives. Delivery follows a five-phase approach designed to meet a hard Phase 1 go-live deadline of **2026-10-31** ahead of MedCore's Joint Commission accreditation review.

## Implementation Scope

- **In Scope:**
  - AWS multi-region infrastructure (us-east-1 primary, us-west-2 passive DR) provisioned via Terraform/CDK IaC across four environments (Dev, QA, Staging, Production)
  - Real-time ingestion pipeline: Kinesis Data Streams (10 shards), MSK (3-broker Kafka), Epic FHIR R4 connector, and HL7 v2.3 Mirth Connect adapter
  - Amazon HealthLake FHIR R4 PHI datastore, SageMaker Feature Store, and three custom ML risk models
  - SHAP explainability pipeline and Amazon Bedrock (Claude 3) clinical narrative generation
  - React/AWS Amplify clinical dashboard with Azure AD SAML 2.0 federation via Amazon Cognito
  - HIPAA/HITECH/SOC 2 Type II compliance controls: KMS CMK encryption, CloudTrail 7-year WORM audit logging, GuardDuty, Config, Security Hub
  - CI/CD pipelines (CodePipeline/CodeBuild) with blue/green deployment for ML inference endpoints
  - Phased rollout across all 18 hospitals with per-facility UAT, knowledge transfer, and 8-week hypercare

- **Out of Scope:**
  - Epic EHR configuration changes, Mirth Connect upgrades, or bedside hardware
  - Azure Active Directory tenant configuration or user provisioning
  - On-premises SQL Server 2016 data warehouse modifications
  - ML models beyond sepsis, readmission, and rapid-response
  - Native iOS/Android mobile applications
  - Post-hypercare managed services (covered under a separate MSA)

- **Dependencies:**
  - Epic FHIR R4 API sandbox access by Week 2 (MedCore EHR Integration Lead)
  - AWS account vending under Clinical Applications OU by Week 2 (MedCore CIO/IT)
  - AWS BAA execution before Development phase (MedCore CISO, by Week 6)
  - 1 Gbps Direct Connect circuit available for testing by Week 8 (MedCore IT)
  - Azure AD SAML 2.0 metadata available by Week 10 (MedCore Identity Admin)
  - De-identified clinical training dataset (≥ 1 TB) by Week 9 (Clinical Informatics Lead)

## Timeline Overview

- **Project Duration:** 14 months (May 2026 – June 2027) + 8-week hypercare
- **Phase 1 Go-Live (Sepsis + Pipeline):** 2026-10-31 (hard deadline — Joint Commission gate)
- **Phase 2 Deployment (Readmission + Dashboard):** 2027-02-28
- **General Availability (all 18 hospitals):** 2027-06-30
- **Key Milestones:**
  - M1 — Discovery Complete: Week 5
  - M2 — Architecture Approved: Week 7
  - M3 — Infrastructure Ready: Week 10
  - M4 — Data Pipeline Live: Week 14
  - M5 — Phase 1 Go-Live: **2026-10-31**
  - M6 — Phase 2 Deployment: **2027-02-28**
  - M7 — Test Sign-Off: Week 36
  - M8 — Enterprise GA: **2027-06-30**
  - M9 — Hypercare End: Q3 2027 + 8 weeks

---

# Prerequisites

## Technical Prerequisites

The following items must be completed before infrastructure provisioning begins in Phase 2 (Week 6). The Amatra Engagement Director and MedCore CIO will validate all items at the Phase 1 Discovery gate review.

### Cloud Infrastructure

- [ ] Dedicated CDS AWS account provisioned under MedCore's Clinical Applications OU (account ID confirmed)
- [ ] MedCore CIO or Cloud Engineering Lead has granted Amatra IAM role assumption access (external ID condition configured)
- [ ] AWS Business Support tier upgrade approved and activated ($1,800/month; required for 99.95% SLA)
- [ ] AWS Billing Alerts configured for monthly threshold notification ($20,000)
- [ ] Resource quotas validated in us-east-1 for: SageMaker ml.m5.xlarge (minimum 8 instances), ml.p3.2xlarge training jobs, Kinesis shards (10), MSK brokers (3), ECS Fargate vCPU (48+)
- [ ] AWS BAA executed between MedCore and AWS (CISO sign-off required; must complete before Week 6)
- [ ] Service Control Policies at Clinical Applications OU reviewed — confirm SageMaker, HealthLake, Bedrock, Kinesis, MSK, and Cognito are not blocked

### Network Connectivity

- [ ] 1 Gbps AWS Direct Connect hosted connection ordered and scheduled for delivery by Week 8
- [ ] Direct Connect Gateway configured in us-east-1
- [ ] Site-to-site VPN (IKEv2, AES-256) configured as Direct Connect failover path
- [ ] Mirth Connect integration server accessible from AWS test environment via Direct Connect/PrivateLink (confirm by Week 10)
- [ ] DNS resolution confirmed for VPC-to-on-premises paths (Mirth Connect and Epic FHIR API)
- [ ] Firewall rules updated to allow AWS VPC CIDR `10.10.0.0/16` to reach Mirth Connect MLLP port (TCP 6661 default) and Epic FHIR API HTTPS (TCP 443)

### Security Baseline

- [ ] AWS KMS CMKs provisioned (separate keys for HealthLake, RDS Aurora, S3 data lake, S3 audit, ElastiCache, EBS) — 6 keys total; annual auto-rotation enabled; CISO holds admin key policy access
- [ ] AWS Secrets Manager secrets provisioned as empty placeholders: Aurora master credentials, Epic FHIR OAuth client secret, Mirth Connect API key, Datadog API key, PagerDuty integration key
- [ ] S3 audit bucket created with Object Lock enabled (Compliance mode, 7-year WORM) before CloudTrail trail is created
- [ ] CloudTrail organization-level trail enabled, delivering to S3 audit bucket with KMS encryption and log file validation
- [ ] GuardDuty, AWS Config (HIPAA rule set), Security Hub, and Macie enabled across the CDS account
- [ ] AWS WAF rule groups loaded: AWS Managed Rules Core Rule Set (OWASP Top 10), IP Reputation List, and healthcare payload size rule

### Development Tools and Repositories

- [ ] MedCore GitHub (or AWS CodeCommit) repository created for IaC modules (Terraform/CDK), application code, ML pipelines, and documentation
- [ ] Amatra engineers granted access to the CDS AWS account via IAM roles (least-privilege, time-limited during build)
- [ ] Terraform state S3 backend bucket created with versioning enabled, per-environment state files configured
- [ ] AWS CodePipeline and CodeBuild service roles provisioned
- [ ] Snyk Business tier subscription activated; Snyk API token stored in Secrets Manager
- [ ] Datadog APM subscription active; 20-host license confirmed; Datadog API key stored in Secrets Manager

## Organizational Prerequisites

- [ ] Project team assigned and available (all roles per RACI): Amatra PM, Lead Architect, 2× ML/AI Engineers, 2× Data Engineers, 2× Solutions Engineers, Security Engineer, DevOps Engineer, QA Engineer, Technical Writer
- [ ] MedCore stakeholder commitments confirmed: CMO, CIO, Clinical Informatics Lead (≥ 8 hrs/week during ML development), CISO, EHR Integration Lead
- [ ] Executive sponsor (CMO) has communicated program priority to nursing and clinical leadership
- [ ] Change management plan activated; MedCore communications team briefed on CDS Platform timeline
- [ ] Clinical Champion nominations confirmed for train-the-trainer program (one per facility, minimum 18 Clinical Champions; due by Week 30)
- [ ] Budget approved — Year 1 net: $1,117,432; monthly AWS run-rate authority: $18,000–$24,000/month
- [ ] Project governance cadence established: weekly status reports, bi-weekly steering committee, phase gate reviews at each milestone

## Environmental Setup

### Development Environment

- [ ] Dev AWS account/VPC provisioned under Clinical Applications OU (VPC CIDR: `10.20.0.0/16`)
- [ ] Dev environment tagged `Environment=dev`; no PHI permitted — synthetic/generated test data only
- [ ] Amatra engineers have full-access IAM role in Dev environment
- [ ] CI/CD pipeline connected to Dev environment; CodePipeline trigger on feature branch push confirmed
- [ ] Synthetic PHI dataset loaded for integration testing (generated using HealthLake FHIR de-identification tool)

### QA Environment

- [ ] QA AWS account/VPC provisioned (VPC CIDR: `10.20.0.0/16`)
- [ ] QA environment tagged `Environment=qa`; de-identified synthetic PHI only
- [ ] MedCore QA team, Security Engineer, and EHR Integration Lead (read-only) access provisioned
- [ ] QA mirrors staging architecture at reduced instance sizing (ml.m5.large endpoints, db.r6g.medium Aurora)
- [ ] Epic FHIR R4 test environment credentials confirmed and functional in QA

### Staging Environment

- [ ] Staging AWS account/VPC provisioned, mirroring production sizing
- [ ] Staging environment tagged `Environment=staging`; de-identified PHI subset loaded (representative of production volume)
- [ ] MedCore Clinical Informatics Lead and CISO staging access provisioned
- [ ] Performance testing tooling deployed: AWS Distributed Load Testing solution and Locust FHIR simulator
- [ ] UAT environment URL confirmed and shared with MedCore clinical UAT team

### Production Environment

- [ ] Production AWS account/VPC provisioned (VPC CIDR: `10.10.0.0/16`); three AZs (us-east-1a, 1b, 1c)
- [ ] DR VPC provisioned in us-west-2 (VPC CIDR: `10.11.0.0/16`)
- [ ] Production-grade resources provisioned per compute sizing (ml.m5.xlarge endpoints, db.r6g.large Aurora Multi-AZ)
- [ ] Route 53 health checks configured on production ALB endpoint (30-second check interval)
- [ ] Monitoring dashboards created (CloudWatch: 4 dashboards — Ingestion Pipeline, ML Inference, Application, Compliance)
- [ ] PagerDuty on-call rotation established; SNS-to-PagerDuty integration key tested
- [ ] Epic rule-based system confirmed active as clinical safety backstop before any live alert delivery

---

# Environment Setup

## Phase 1: Foundation Setup (Weeks 1–5) — Discovery and Architecture

### Objectives

This phase establishes the clinical, technical, and compliance foundation for the entire program. It produces the approved Assessment Report and Detailed Architecture Design before any infrastructure is provisioned.

### Activities

The following activities are executed by the Amatra delivery team with active participation from MedCore stakeholders. All activities in this phase are completed before any infrastructure provisioning begins.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Project kickoff, RACI alignment, governance cadence setup | Amatra PM | Day 1 | SOW execution |
| Clinical workflow discovery (CMO, nursing, hospitalists) | Amatra Architect + Clinical Informatics Lead | Week 1–2 | Kickoff |
| Epic FHIR R4 API and Mirth Connect topology assessment | Amatra Solutions Engineer + EHR Integration Lead | Week 2–3 | FHIR sandbox access |
| HIPAA PHI data-handling requirements workshops | Amatra Security Engineer + CISO | Week 2–3 | None |
| ML feature requirements workshops (sepsis model priority) | Amatra ML Engineers + Clinical Informatics Lead | Week 3–4 | Clinical discovery |
| AWS Landing Zone and SCP gap analysis | Amatra DevOps Engineer + MedCore IT | Week 3–4 | Account access |
| Detailed architecture design (VPC, Kinesis, SageMaker, Bedrock) | Amatra Architect | Week 4–5 | All discovery sessions |
| Security and compliance design (KMS, CloudTrail, RBAC) | Amatra Security Engineer | Week 4–5 | HIPAA workshops |
| Assessment Report production and approval | Amatra PM + Amatra Architect | Week 5 | All above |

### Deliverables

- [ ] Assessment Report approved by CMO and CIO (M1 gate)
- [ ] HLD, LLD, Security Architecture, and FHIR Resource Mapping documents signed off (M2 gate)
- [ ] IaC standards and CI/CD pipeline definition documented
- [ ] Risk register initialized with all critical-path risks

### Success Criteria

- CMO and CIO have formally approved the Assessment Report and architecture documents in writing
- Epic FHIR R4 API capabilities confirmed sufficient for Phase 1 model features
- HIPAA BAA with AWS confirmed on track for execution before Week 6
- No blocking SCP constraints discovered in Clinical Applications OU
- All phase 2 dependency dates confirmed and committed by MedCore stakeholders

---

## Phase 2: Environment Build and Data Pipeline (Weeks 6–14)

### Objectives

This phase provisions the full four-environment AWS infrastructure via IaC, establishes secure connectivity to on-premises Mirth Connect, and delivers a live real-time data ingestion pipeline with synthetic PHI flowing end-to-end into HealthLake and the SageMaker Feature Store.

### Activities

The following activities are executed primarily by Amatra's DevOps Engineer, Data Engineers, and Solutions Engineers with MedCore IT coordination.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Provision Dev/QA/Staging/Production VPCs via Terraform/CDK | Amatra DevOps | Week 6–8 | IaC standards approved |
| Configure Transit Gateway, Direct Connect Gateway, Site-to-Site VPN | Amatra DevOps + MedCore IT | Week 8–9 | Direct Connect circuit ready |
| Implement KMS CMKs and S3 Object Lock audit bucket | Amatra Security Engineer | Week 6–7 | KMS CMK placeholders provisioned |
| Build Kinesis Data Streams (10 shards) and MSK (3-broker) ingestion pipeline | Amatra Data Engineer | Week 7–10 | VPC and networking complete |
| Develop Epic FHIR R4 Lambda connector (SMART on FHIR OAuth 2.0) | Amatra Solutions Engineer | Week 7–12 | FHIR sandbox access, Direct Connect |
| Develop HL7 v2.3 Mirth Connect Lambda adapter (ADT/ORU message types) | Amatra Solutions Engineer | Week 8–12 | Mirth Connect accessible via PrivateLink |
| Provision and configure Amazon HealthLake FHIR R4 datastore | Amatra Data Engineer | Week 9–10 | KMS CMK ready, BAA confirmed |
| Build SageMaker Feature Store (online + offline feature groups) | Amatra ML Engineer + Data Engineer | Week 10–13 | HealthLake provisioned |
| Implement Azure AD SAML 2.0 federation with Amazon Cognito | Amatra Solutions Engineer + MedCore Identity Admin | Week 10–12 | Azure AD SAML metadata available |
| Implement HIPAA audit logging (CloudTrail + Athena query layer) | Amatra Security Engineer | Week 9–10 | S3 audit bucket with Object Lock |
| Implement AWS Config HIPAA rules, Security Hub, GuardDuty | Amatra Security Engineer | Week 10–11 | All environments provisioned |
| Build CI/CD pipelines with blue/green endpoint deployment capability | Amatra DevOps Engineer | Week 11–14 | CodePipeline/CodeBuild roles ready |

### Detailed Procedures

#### 2.1 Environment Provisioning

The following commands provision the Development environment as the first environment in the sequence. Staging and Production follow the same pattern with environment-specific `.tfvars` files.

```bash
# Navigate to IaC root
cd infrastructure/environments/dev

# Initialise Terraform with the S3 backend
terraform init \
  -backend-config="bucket=medcore-cds-terraform-state" \
  -backend-config="key=dev/terraform.tfstate" \
  -backend-config="region=us-east-1"

# Validate the configuration
terraform validate

# Preview the deployment plan
terraform plan \
  -var-file=dev.tfvars \
  -out=dev.plan \
  | tee dev-plan-output.txt

# Apply the plan
terraform apply dev.plan

# Capture outputs for downstream scripts
terraform output -json > dev-outputs.json

echo "Dev environment provisioned successfully."
```

**Expected output (truncated):**

```
Apply complete! Resources: 87 added, 0 changed, 0 destroyed.

Outputs:
vpc_id            = "vpc-0abc1234def56789a"
private_app_subnets = ["subnet-0a1b2c3d", "subnet-0e4f5a6b", "subnet-0c7d8e9f"]
private_data_subnets = ["subnet-0d1e2f3a", "subnet-0b4c5d6e"]
kms_healthlake_key_arn = "arn:aws:kms:us-east-1:123456789012:key/..."
```

#### 2.2 Kinesis Data Streams Deployment

After VPC creation, deploy the Kinesis ingestion pipeline. The following snippet shows the Terraform resource block for reference; the CI/CD pipeline applies this automatically.

```hcl
# infrastructure/modules/kinesis/main.tf
resource "aws_kinesis_stream" "cds_events" {
  name             = "medcore-cds-${var.environment}-events"
  shard_count      = var.kinesis_shard_count  # 10 in production
  retention_period = 24

  encryption_type = "KMS"
  kms_key_id      = var.kinesis_kms_key_id

  tags = {
    Environment     = var.environment
    Application     = "medcore-cds"
    DataClassification = "phi-restricted"
    Compliance      = "hipaa,soc2,hitech"
  }
}
```

```bash
# Verify stream is ACTIVE before proceeding
aws kinesis describe-stream-summary \
  --stream-name medcore-cds-prod-events \
  --query 'StreamDescriptionSummary.StreamStatus'
# Expected: "ACTIVE"

# Confirm shard count
aws kinesis describe-stream-summary \
  --stream-name medcore-cds-prod-events \
  --query 'StreamDescriptionSummary.OpenShardCount'
# Expected: 10
```

#### 2.3 HealthLake FHIR Datastore Provisioning

HealthLake must be provisioned after the KMS CMK and the AWS BAA are both confirmed.

```bash
# Create HealthLake FHIR R4 datastore
aws healthlake create-fhir-datastore \
  --datastore-type-version R4 \
  --datastore-name "medcore-cds-prod-healthlake" \
  --sse-configuration \
    "KmsEncryptionConfig={CmkType=CUSTOMER_MANAGED_KMS_KEY,\
KmsKeyId=arn:aws:kms:us-east-1:123456789012:key/[kms-healthlake-key-id]}" \
  --region us-east-1

# Poll status until ACTIVE (typically 10–15 minutes)
aws healthlake describe-fhir-datastore \
  --datastore-id "[healthlake-datastore-id]" \
  --query 'DatastoreProperties.DatastoreStatus'
# Expected: "ACTIVE"
```

### Deliverables

- [ ] All four environments (Dev, QA, Staging, Production) provisioned via IaC and tagged correctly
- [ ] Direct Connect and site-to-site VPN connectivity validated (connectivity test to Mirth Connect server)
- [ ] Synthetic PHI flowing end-to-end from Epic FHIR R4 connector → Kinesis → HealthLake → Feature Store
- [ ] HL7 v2.3 adapter processing ADT and ORU messages from Mirth Connect test feed
- [ ] Azure AD SAML 2.0 federation functional — test user authenticates via MedCore SSO to dashboard
- [ ] HIPAA audit logging verified: CloudTrail capturing PHI access events; Athena query returns results
- [ ] All CI/CD pipelines deploying to Dev successfully

### Success Criteria

- All 87+ IaC-managed resources in production are in `terraform apply` green state
- Kinesis DLQ message depth = 0 after 24-hour synthetic traffic run
- HealthLake FHIR import job status = COMPLETED for synthetic dataset
- End-to-end latency from FHIR connector to Feature Store < 500 ms (P95) in QA load test
- CloudTrail logs delivering to S3 audit bucket with Object Lock confirmed (CISO sign-off)
- AWS Config reports 100% compliance on HIPAA rule set for all provisioned resources

---

## Phase 3: ML Model Development and Integration (Weeks 8–30)

### Objectives

This phase covers development and training of all three custom risk models, the LLM clinical narrative layer, alert routing, and the clinical dashboard. Phase 1 (sepsis model + pipeline) must reach production by Week 22 (2026-10-31). Phase 2 models follow by 2027-02-28.

### Activities

The following activities are executed primarily by Amatra ML/AI Engineers and Solutions Engineers. Phase 3 overlaps Phase 2 to meet the Phase 1 deadline.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Sepsis model feature engineering (SageMaker Feature Store online/offline groups) | Amatra ML Engineer + Clinical Informatics Lead | Week 9–14 | Feature Store provisioned, training dataset delivered |
| Sepsis risk model training and AUROC validation (target ≥ 0.85) | Amatra ML Engineer | Week 14–18 | Training data, SageMaker Pipelines |
| SHAP explainability pipeline development (inline with inference container) | Amatra ML Engineer | Week 15–19 | Sepsis model trained |
| Amazon Bedrock (Claude 3) clinical narrative integration | Amatra ML Engineer + Clinical Informatics Lead | Week 17–21 | Sepsis model, prompt template validated |
| Alert routing service (EventBridge + SNS + Epic CDS Hooks write-back) | Amatra Solutions Engineer | Week 18–22 | Cognito RBAC, SageMaker endpoint |
| React/Amplify clinical dashboard development (Phase 2) | Amatra Solutions Engineer | Week 18–28 | Cognito RBAC, API backend |
| Readmission and rapid-response model development (Phase 2) | Amatra ML Engineers | Week 20–30 | Extended training dataset |
| QuickSight longitudinal outcomes dashboards | Amatra Data Engineer | Week 25–30 | Redshift, model performance data |

### Deliverables

- [ ] Sepsis model (AUROC ≥ 0.85) deployed to Production by 2026-10-31 (M5)
- [ ] SHAP explainability payload bundled with every sepsis alert
- [ ] Bedrock (Claude 3) narrative generation functional; clinical narrative quality confirmed by ≥ 5 clinical reviewers
- [ ] Alert routing service active — risk scores reaching EventBridge → SNS within 3-second end-to-end SLA
- [ ] Clinical dashboard (React/Amplify) deployed by 2027-02-28 (M6)
- [ ] Readmission and rapid-response models deployed to Production by 2027-02-28 (M6)

### Success Criteria

- Sepsis model AUROC ≥ 0.85 on held-out clinical validation dataset; Clinical Informatics Lead sign-off received
- End-to-end inference latency < 3 seconds P95 validated in QA load test
- Bedrock narrative generation P95 latency < 1 second
- SHAP values present in 100% of alert payloads (validated by QA automated test suite)
- Alert routing correctly scopes nurse alerts to assigned-patient-only view (RBAC test passes)

---

## Phase 4: Testing and Validation (Weeks 18–36)

### Objectives

This phase executes the full test program covering functional, integration, performance, security, model accuracy, and user acceptance testing. All Critical and High findings must be resolved before go-live.

### Activities

The QA Engineer leads all testing activities with support from the Security Engineer for HIPAA validation.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Test plan development (reviewed by Clinical Informatics Lead and CISO) | Amatra QA Engineer | Week 18–20 | Phase 3 complete for Phase 1 scope |
| Functional testing: pipeline, inference, dashboard | Amatra QA Engineer | Week 20–24 | Staging environment complete |
| Integration testing: Epic FHIR R4 end-to-end with synthetic PHI | Amatra QA + EHR Integration Lead | Week 20–24 | Epic test environment |
| Load testing: < 3-second P95 at 18-hospital peak load | Amatra QA + DevOps | Week 22–24 | Locust and AWS DLT deployed |
| Multi-region failover test (AZ and region) | Amatra DevOps + QA | Week 24 | Staging DR infrastructure |
| HIPAA security controls validation | Amatra Security Engineer + CISO | Week 24–26 | All security controls deployed |
| External penetration test coordination | CISO + Amatra Security Engineer | Week 30–34 | Pen test firm engaged |
| UAT at pilot facility (clinical staff walk-through in staging) | Amatra PM + Clinical Informatics Lead | Week 32–35 | Staging with representative PHI |
| Defect triage and resolution (all Critical/High blockers) | Amatra QA + Eng | Week 20–36 | Ongoing |

### Deliverables

- [ ] Test Results Report with model performance metrics and security validation summary
- [ ] All Critical and High functional defects resolved
- [ ] External pen test completed; all Critical/High findings remediated
- [ ] UAT pilot facility sign-off from CMO representative
- [ ] CISO security controls validation checklist signed
- [ ] CMO/CIO go-live clearance recorded in writing (M7 gate)

### Success Criteria

- End-to-end P95 inference latency < 3,000 ms at simulated 2,500+ concurrent inpatient load
- Multi-AZ failover recovery < 5 minutes; region failover RTO ≤ 4 hours
- Zero Critical or High unresolved security findings at go-live
- HIPAA audit logging covering 100% of PHI access event types confirmed by CISO
- UAT pass rate ≥ 95% of defined test scenarios

---

## Phase 5: Production Rollout, Handover, and Hypercare (Weeks 22–52+)

### Objectives

This phase executes cohort-based enterprise rollout across all 18 hospitals, delivers all knowledge transfer and training, completes as-built documentation, and provides 8 weeks of post-GA hypercare support.

### Activities

The PM, Solutions Engineers, and QA Engineer lead rollout execution with the Technical Writer producing documentation in parallel.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Phase 1 production deployment (sepsis + pipeline, pilot facility) | Amatra DevOps + Clinical Informatics Lead | Week 22 | Go-live readiness gate met |
| Phase 2 production deployment (readmission + rapid-response + dashboard) | Amatra DevOps | Week 30 | Phase 2 models validated |
| Phase 3 cohort-based facility rollout (18 hospitals, per-facility UAT) | Amatra PM + Solutions Engineers | Weeks 35–44 | Phase 2 deployed |
| Operational runbooks delivery (pipeline, inference, alert system) | Amatra Technical Writer + Architects | Week 40–44 | All components deployed |
| IT and data engineering knowledge transfer (4 half-day sessions) | Amatra Architects + Engineers | Week 42–44 | Runbooks draft complete |
| Clinical train-the-trainer program (2-day facilitated session for 18 Clinical Champions) | Amatra PM + Solutions Engineer | Week 44 | Dashboard live at all facilities |
| Final as-built documentation and IaC repository handover | Amatra Technical Writer | Week 44 | All components final |
| 8-week hypercare support | Amatra Senior Support Engineer + Lead Architect | Weeks 44–52 | GA milestone signed off |
| Project closure outcomes report | Amatra PM | Week 52+ | Hypercare end |

### Deliverables

- [ ] GA across all 18 hospitals by 2027-06-30 (M8)
- [ ] All documentation and IaC repository formally transferred to MedCore
- [ ] Hypercare period complete; transition to MedCore IT Operations (M9)
- [ ] Project closure outcomes report (KPI baseline vs. actual) delivered to CMO and CIO

### Success Criteria

- All 18 hospitals clinically active with per-facility UAT sign-off on file
- Clinical staff adoption rate ≥ 75% per facility within 90 days of go-live (tracked via Cognito/QuickSight)
- 8-week hypercare completed with all Critical/High incidents resolved within SLA
- MedCore IT team can independently execute all operational runbooks

---

# Infrastructure Deployment

This section defines the four required infrastructure subsections — Networking, Security, Compute, and Monitoring — each detailing the components deployed, the IaC location, step-by-step deployment procedures, validation commands, success criteria, and rollback procedures. All infrastructure changes must be applied exclusively via the CI/CD pipeline from version-controlled Terraform/CDK; direct AWS console modifications are prohibited by SCP in all environments.

## Networking

The networking layer establishes the private, encrypted foundation for all PHI data flows. It provisions the multi-AZ VPCs, subnet tiers, Transit Gateway, Direct Connect Gateway, site-to-site VPN, PrivateLink endpoints, Application Load Balancers, NAT Gateways, and AWS WAF. All PHI traffic is routed exclusively over private subnets and AWS PrivateLink; no PHI traverses the public internet.

### Components

The table below lists all networking resources deployed by the IaC networking module.

| Component | Resource ID / Name | Specification | Purpose |
|-----------|-------------------|---------------|---------|
| Production VPC | `medcore-cds-prod-vpc` | CIDR `10.10.0.0/16`, us-east-1, 3 AZs | Isolated network boundary for all CDS Platform resources |
| Public Subnets (3 AZs) | `medcore-cds-prod-public-use1a/b/c` | `/24` per AZ (10.10.0.0–2.0) | ALBs and NAT Gateways only; no application workloads |
| Private App Subnets (3 AZs) | `medcore-cds-prod-app-use1a/b/c` | `/23` per AZ (10.10.10.0–14.0) | ECS Fargate tasks, VPC-attached Lambda, SageMaker endpoints |
| Private Data Subnets (3 AZs) | `medcore-cds-prod-data-use1a/b/c` | `/24` per AZ (10.10.20.0–22.0) | RDS Aurora, ElastiCache Redis; inbound from app tier only |
| DR VPC (us-west-2) | `medcore-cds-prod-vpc` (us-west-2) | CIDR `10.11.0.0/16` | Passive DR region; mirrors primary topology |
| Transit Gateway | `medcore-cds-prod-tgw` | AWS-managed; us-east-1 | Connects CDS VPC to Direct Connect Gateway |
| Direct Connect Gateway | `medcore-cds-prod-dxgw` | 1 Gbps hosted connection (MedCore Nashville DC → us-east-1) | Primary private channel for Epic FHIR events and HL7 v2.3 feeds |
| Site-to-Site VPN | `medcore-cds-prod-vpn` | IKEv2, AES-256; 2 tunnels | Failover path for Direct Connect disruption |
| NAT Gateways (2) | `medcore-cds-prod-nat-use1a/b` | One per AZ (us-east-1a, 1b) | Controlled outbound access for AWS control-plane calls |
| ALB (Dashboard) | `medcore-cds-prod-dashboard-alb` | Multi-AZ; HTTPS-only; WAF attached | HTTPS termination for clinical dashboard and API backend |
| ALB (FHIR Inbound) | `medcore-cds-prod-fhir-alb` | Multi-AZ; HTTPS-only; WAF attached | Receives Epic FHIR subscription events over Direct Connect |
| PrivateLink Endpoints (20+) | VPC Interface Endpoints | HealthLake, SageMaker Runtime, SageMaker Feature Store, Bedrock, S3 (Gateway), KMS, Secrets Manager, CloudWatch Logs, CloudTrail, SSM, ECS, Lambda, SNS, EventBridge, SQS, and others | Eliminates PHI egress to public internet for all service-to-service calls |
| AWS WAF | `medcore-cds-prod-waf` | AWS Managed Rules Core Set (OWASP Top 10) + IP Reputation List + healthcare payload rule | Protection for ALBs against web attacks and malformed FHIR payloads |
| Security Groups | Per-resource Security Groups | Application tier: inbound from ALB SG only; data tier: inbound from app tier SG only | Least-privilege port-level access control at resource boundary |

### Script Location

All networking resources are defined in the Terraform module at:

```
infrastructure/
  modules/
    networking/
      main.tf           # VPC, subnets, IGW, NAT Gateways, route tables
      alb.tf            # Application Load Balancers, listeners, target groups
      waf.tf            # WAF WebACL and rule group associations
      privatelink.tf    # VPC Interface and Gateway Endpoints
      tgw.tf            # Transit Gateway and Direct Connect Gateway attachments
      vpn.tf            # Site-to-Site VPN configuration
      variables.tf
      outputs.tf
  environments/
    prod/networking.tfvars
    staging/networking.tfvars
    qa/networking.tfvars
    dev/networking.tfvars
```

### Deployment Steps

These steps deploy the networking layer. Execute them in sequence; do not proceed to the next step until the current step is validated.

```bash
# Step 1: Deploy the networking module for the target environment
ENVIRONMENT=prod
cd infrastructure/environments/${ENVIRONMENT}

terraform init \
  -backend-config="bucket=medcore-cds-terraform-state" \
  -backend-config="key=${ENVIRONMENT}/networking.tfstate" \
  -backend-config="region=us-east-1"

terraform plan \
  -target=module.networking \
  -var-file=${ENVIRONMENT}.tfvars \
  -out=networking.plan

terraform apply networking.plan
```

```bash
# Step 2: Verify VPC and subnet creation
aws ec2 describe-vpcs \
  --filters "Name=tag:Application,Values=medcore-cds" \
            "Name=tag:Environment,Values=prod" \
  --query 'Vpcs[].{VpcId:VpcId,CIDR:CidrBlock,State:State}'

aws ec2 describe-subnets \
  --filters "Name=tag:Application,Values=medcore-cds" \
            "Name=tag:Environment,Values=prod" \
  --query 'Subnets[].{SubnetId:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Tier:Tags[?Key==`Tier`]|[0].Value}'
```

```bash
# Step 3: Verify ALB creation and HTTPS listener
aws elbv2 describe-load-balancers \
  --names medcore-cds-prod-dashboard-alb \
  --query 'LoadBalancers[].{ARN:LoadBalancerArn,State:State.Code,DNS:DNSName}'

aws elbv2 describe-listeners \
  --load-balancer-arn "[alb-dashboard-arn]" \
  --query 'Listeners[].{Port:Port,Protocol:Protocol}'
# Expected: Port=443, Protocol=HTTPS
```

```bash
# Step 4: Verify PrivateLink endpoints are available
aws ec2 describe-vpc-endpoints \
  --filters "Name=tag:Application,Values=medcore-cds" \
            "Name=tag:Environment,Values=prod" \
  --query 'VpcEndpoints[].{ServiceName:ServiceName,State:State}'
# All endpoints must show State=available
```

```bash
# Step 5: Test Direct Connect connectivity to Mirth Connect
# Run from an EC2 instance in the private application subnet
nc -zv [mirth-connect-private-ip] 6661
# Expected: Connection to [mirth-connect-private-ip] 6661 port succeeded
```

### Validation

After deployment, run the following validation checks before declaring the networking layer ready.

- [ ] All VPC subnets have correct CIDR ranges and route table associations
- [ ] Public subnets route `0.0.0.0/0` to Internet Gateway; private app subnets route to NAT Gateway
- [ ] Data subnets have no route to Internet Gateway or NAT Gateway (data-tier isolation)
- [ ] Both ALBs respond to HTTPS health check; HTTP requests return 301 redirect to HTTPS
- [ ] All 20+ PrivateLink VPC endpoints are in `available` state
- [ ] Direct Connect and VPN connectivity tests pass from private application subnet
- [ ] WAF WebACL correctly associated with both ALBs; test OWASP payload blocked with 403
- [ ] DR VPC in us-west-2 provisioned and reachable via Transit Gateway (if applicable)

### Success Criteria

- VPC CIDR `10.10.0.0/16` active in us-east-1; DR VPC `10.11.0.0/16` active in us-west-2
- Zero PHI data paths traversing a NAT Gateway to the public internet (confirmed by VPC Flow Log analysis)
- Both ALBs return HTTP 200 on `/api/v1/health` from within the private application subnet
- Direct Connect path from on-premises Mirth Connect to CDS VPC functional (round-trip < 5 ms)
- All PrivateLink endpoints resolving correctly in the VPC DNS namespace

### Rollback

If the networking deployment fails at any step, revert using the following procedure.

```bash
# Targeted rollback: destroy only networking module
cd infrastructure/environments/${ENVIRONMENT}

terraform destroy \
  -target=module.networking \
  -var-file=${ENVIRONMENT}.tfvars \
  -auto-approve

# Verify all networking resources removed
aws ec2 describe-vpcs \
  --filters "Name=tag:Application,Values=medcore-cds" \
            "Name=tag:Environment,Values=${ENVIRONMENT}" \
  --query 'Vpcs[].VpcId'
# Expected: [] (empty array)
```

For partial failures, review `terraform.tfstate` to identify the specific resource causing the failure, address the issue (e.g., overlapping CIDR, quota breach, missing IAM permission), and re-run `terraform apply networking.plan`.

---

## Security

The security layer provisions KMS Customer Managed Keys, IAM roles and policies, Amazon Cognito user pool, CloudTrail organization-level trail, AWS Config HIPAA rule set, Security Hub, GuardDuty, Macie, and Secrets Manager secrets. All security controls must be deployed and validated before any PHI enters the production environment. This is a CISO sign-off gate.

### Components

The table below lists the security resources deployed by the IaC security module.

| Component | Resource ID / Name | Specification | Purpose |
|-----------|-------------------|---------------|---------|
| KMS CMK — HealthLake | `alias/medcore-cds-prod-healthlake` | Customer Managed; annual auto-rotation; CISO holds admin key policy | Encrypts Amazon HealthLake FHIR R4 PHI datastore |
| KMS CMK — Aurora | `alias/medcore-cds-prod-aurora` | Customer Managed; annual auto-rotation | Encrypts RDS Aurora PostgreSQL at rest |
| KMS CMK — S3 Data Lake | `alias/medcore-cds-prod-s3-datalake` | Customer Managed; annual auto-rotation | Encrypts S3 data lake (HL7 event archive, ML artefacts) |
| KMS CMK — S3 Audit | `alias/medcore-cds-prod-s3-audit` | Customer Managed; annual auto-rotation | Encrypts CloudTrail audit log delivery bucket |
| KMS CMK — ElastiCache | `alias/medcore-cds-prod-elasticache` | Customer Managed; annual auto-rotation | Encrypts ElastiCache Redis patient context cache |
| KMS CMK — EBS | `alias/medcore-cds-prod-ebs` | Customer Managed; annual auto-rotation | Encrypts EBS volumes (MSK brokers, SageMaker training) |
| Amazon Cognito User Pool | `medcore-cds-prod-users` | SAML 2.0 federation to Azure AD; 4 clinical role groups; 8-hour session expiry | SSO and RBAC for all 4,200+ clinical staff |
| IAM Roles (per-service) | `medcore-cds-prod-{service}-role` | Least-privilege per-service roles; no wildcard actions or resource ARNs | Service-to-service authentication (Lambda, ECS, SageMaker) |
| IAM Break-Glass Role | `medcore-cds-prod-breakglass-role` | Requires CIO written approval; every session logged to CloudTrail; email notification to CISO | Emergency production access for Amatra incident response only |
| CloudTrail Trail | `medcore-cds-prod-trail` | Organization-level; delivering to S3 audit bucket with KMS + log file validation | Immutable PHI access audit trail with 7-year WORM retention |
| S3 Audit Bucket | `medcore-cds-prod-audit-[account-id]` | Object Lock enabled (Compliance mode, 7-year retention); versioning enabled | Stores CloudTrail logs; HIPAA §164.312(b) compliance |
| AWS Config HIPAA Rules | 30+ HIPAA-specific rules | Continuous compliance monitoring; drift detected within 15 minutes | Validates encryption, access controls, logging at all times |
| AWS Security Hub | `medcore-cds-prod` | Aggregates GuardDuty + Config + Inspector + Macie findings | Single compliance pane for CISO; SOC 2 Type II audit evidence |
| Amazon GuardDuty | Organization-level | ML-driven threat detection; High/Critical findings → PagerDuty | Continuous threat detection: API anomalies, credential compromise, network threats |
| Amazon Macie | `medcore-cds-prod` | PHI data classification in S3 buckets | Alerts if PHI found in non-production or non-encrypted buckets |
| AWS Secrets Manager | 5 secrets (Aurora, Epic OAuth, Mirth, Datadog, PagerDuty) | 30-day automatic rotation; every GetSecretValue logged to CloudTrail | Credential management; eliminates hardcoded secrets from all code and IaC |
| IAM Access Analyzer | `medcore-cds-prod-analyzer` | Continuous overly-permissive resource policy detection | Identifies unintended cross-account or public access |

### Script Location

All security resources are defined in the Terraform module at:

```
infrastructure/
  modules/
    security/
      kms.tf            # All 6 KMS CMKs and key policies
      cognito.tf        # Cognito User Pool, App Client, SAML IdP configuration
      iam_roles.tf      # All per-service IAM roles and policies
      iam_break_glass.tf  # Break-glass role with SCP conditions
      cloudtrail.tf     # Organization-level CloudTrail trail
      s3_audit.tf       # Audit bucket with Object Lock
      config.tf         # AWS Config recorder, delivery channel, HIPAA rules
      security_hub.tf   # Security Hub enablement and standards
      guardduty.tf      # GuardDuty enablement
      macie.tf          # Macie enablement and classification jobs
      secrets.tf        # Secrets Manager secret placeholders and rotation config
      variables.tf
      outputs.tf
  environments/
    prod/security.tfvars
```

### Deployment Steps

Security resources must be deployed in the order shown below; later resources depend on KMS CMKs being available.

```bash
# Step 1: Deploy KMS CMKs first (all other security resources depend on them)
ENVIRONMENT=prod
cd infrastructure/environments/${ENVIRONMENT}

terraform apply \
  -target=module.security.aws_kms_key.healthlake \
  -target=module.security.aws_kms_key.aurora \
  -target=module.security.aws_kms_key.s3_datalake \
  -target=module.security.aws_kms_key.s3_audit \
  -target=module.security.aws_kms_key.elasticache \
  -target=module.security.aws_kms_key.ebs \
  -var-file=${ENVIRONMENT}.tfvars \
  -auto-approve
```

```bash
# Step 2: Deploy S3 audit bucket with Object Lock BEFORE CloudTrail
terraform apply \
  -target=module.security.aws_s3_bucket.audit \
  -target=module.security.aws_s3_bucket_object_lock_configuration.audit \
  -var-file=${ENVIRONMENT}.tfvars \
  -auto-approve

# Verify Object Lock is in COMPLIANCE mode
aws s3api get-object-lock-configuration \
  --bucket medcore-cds-prod-audit-[account-id] \
  --query 'ObjectLockConfiguration.Rule.DefaultRetention'
# Expected: {"Mode": "COMPLIANCE", "Years": 7}
```

```bash
# Step 3: Deploy CloudTrail organization-level trail
terraform apply \
  -target=module.security.aws_cloudtrail.cds_trail \
  -var-file=${ENVIRONMENT}.tfvars \
  -auto-approve

# Verify trail is logging
aws cloudtrail get-trail-status \
  --name medcore-cds-prod-trail \
  --query '{IsLogging:IsLogging,LatestDeliveryTime:LatestDeliveryTime}'
# Expected: {"IsLogging": true, "LatestDeliveryTime": "<recent timestamp>"}
```

```bash
# Step 4: Deploy Cognito User Pool with Azure AD SAML federation
# Prerequisite: Azure AD SAML metadata URL must be available
terraform apply \
  -target=module.security.aws_cognito_user_pool.cds \
  -target=module.security.aws_cognito_identity_provider.azure_ad \
  -target=module.security.aws_cognito_user_pool_client.dashboard \
  -var-file=${ENVIRONMENT}.tfvars \
  -auto-approve

# Test SAML federation with a test MedCore Azure AD account
aws cognito-idp describe-user-pool \
  --user-pool-id "[cognito-user-pool-id]" \
  --query 'UserPool.{Status:Status,MfaConfiguration:MfaConfiguration}'
```

```bash
# Step 5: Deploy remaining security controls (Config, GuardDuty, Security Hub, Macie, IAM roles)
terraform apply \
  -target=module.security \
  -var-file=${ENVIRONMENT}.tfvars \
  -auto-approve
```

### Validation

After full security layer deployment, run the HIPAA security controls validation checklist.

- [ ] All 6 KMS CMKs exist, are ENABLED, and have automatic rotation enabled
- [ ] S3 audit bucket has Object Lock COMPLIANCE mode with 7-year retention configured
- [ ] CloudTrail trail is logging; test PHI-touching API call (HealthLake read) appears in CloudTrail within 2 minutes
- [ ] Athena table over CloudTrail S3 successfully returns PHI access query results
- [ ] Cognito User Pool SAML federation functional; test Azure AD user authenticated and assigned to correct Cognito group
- [ ] IAM Access Analyzer reports zero external or cross-account access findings on initial scan
- [ ] All AWS Config rules are in COMPLIANT state (zero NON_COMPLIANT resources)
- [ ] GuardDuty enabled and active; test finding generated and visible in Security Hub
- [ ] Macie scan on S3 data lake bucket completes without unexpected PHI findings in non-production data
- [ ] All Secrets Manager secrets have rotation configured and last-rotated timestamp present

### Success Criteria

- CISO formally signs off on HIPAA security controls validation checklist
- Zero Critical or High Security Hub findings on initial post-deployment scan
- CloudTrail log file validation enabled and passing (no integrity violations)
- AWS Config HIPAA rule set reports 100% compliance for all deployed resources
- Cognito SAML federation verified for at least one user per clinical role type (Nurse, Physician, Administrator)

### Rollback

If a security deployment step fails, revert the specific resource rather than destroying the entire security module, as KMS CMKs have a mandatory 30-day deletion waiting period.

```bash
# Rollback Cognito configuration only (safe to destroy and re-apply)
terraform destroy \
  -target=module.security.aws_cognito_user_pool.cds \
  -var-file=${ENVIRONMENT}.tfvars

# To schedule KMS key deletion (30-day waiting period enforced by AWS)
aws kms schedule-key-deletion \
  --key-id "[key-id]" \
  --pending-window-in-days 30
# WARNING: Do not delete KMS keys unless the associated data store is also being decommissioned

# For partial Config/GuardDuty failures, disable and re-enable
aws guardduty update-detector \
  --detector-id "[detector-id]" \
  --no-enable
# Re-enable:
aws guardduty update-detector \
  --detector-id "[detector-id]" \
  --enable
```

---

## Compute

The compute layer provisions all application-tier and ML inference resources: ECS Fargate clusters and services (clinical dashboard and API backend), SageMaker real-time inference endpoints (4 models), SageMaker training pipelines, Lambda functions (FHIR connector, HL7 adapter, inference orchestrator, alert router), RDS Aurora PostgreSQL (Multi-AZ), Amazon ElastiCache Redis (Multi-AZ), Amazon MSK (3-broker Kafka), and Amazon Redshift. All compute resources are provisioned after the networking and security layers are fully validated.

### Components

The table below lists all compute resources deployed by the IaC compute module.

| Component | Resource ID / Name | Specification | Purpose |
|-----------|-------------------|---------------|---------|
| ECS Fargate Cluster | `medcore-cds-prod-cluster` | AWS Fargate; us-east-1 | Container orchestration for dashboard and API backend |
| ECS Service — Dashboard | `medcore-cds-prod-dashboard-svc` | 4 tasks min / 12 max; 2 vCPU / 4 GB per task; 3 AZs | Serves React/Amplify clinical dashboard SPA |
| ECS Service — API Backend | `medcore-cds-prod-api-svc` | 4 tasks min / 12 max; 2 vCPU / 4 GB per task; 3 AZs | REST API backend for dashboard; Lambda authorizer for JWT validation |
| Lambda — FHIR Connector | `medcore-cds-prod-fhir-connector` | 1,024 MB; 30s timeout; VPC-attached | Ingests Epic FHIR R4 subscription events → Kinesis |
| Lambda — HL7 Adapter | `medcore-cds-prod-hl7-adapter` | 1,024 MB; 30s timeout; VPC-attached | Ingests Mirth Connect HL7 v2.3 ADT/ORU messages → Kinesis |
| Lambda — Inference Orchestrator | `medcore-cds-prod-inference-orchestrator` | 2,048 MB; 30s timeout; VPC-attached | Retrieves features (ElastiCache), invokes SageMaker + Bedrock, dispatches alert |
| Lambda — Alert Router | `medcore-cds-prod-alert-router` | 512 MB; 30s timeout; VPC-attached | Duplicate suppression (Redis), RDS Aurora persistence, Epic CDS Hooks write-back |
| SageMaker Endpoint — Sepsis | `medcore-cds-prod-sepsis-ep` | ml.m5.xlarge × 2 min / 6 max; auto-scaling at 70% CPU | Real-time sepsis risk inference + SHAP |
| SageMaker Endpoint — Readmission | `medcore-cds-prod-readmission-ep` | ml.m5.xlarge × 2 min / 4 max (Phase 2) | Real-time 30-day readmission risk inference |
| SageMaker Endpoint — Rapid-Response | `medcore-cds-prod-rapid-response-ep` | ml.m5.xlarge × 2 min / 4 max (Phase 2) | Real-time rapid-response / early deterioration inference |
| SageMaker Endpoint — Ensemble | `medcore-cds-prod-ensemble-ep` | ml.m5.xlarge × 2 min / 4 max (Phase 3) | Ensemble aggregation across all three models |
| SageMaker Training Pipeline | `medcore-cds-prod-sepsis-pipeline` | ml.p3.2xlarge (on-demand; weekly Sunday 02:00 UTC) | Weekly model retraining from offline Feature Store |
| RDS Aurora PostgreSQL | `medcore-cds-prod-aurora-cluster` | db.r6g.large × 2 (Multi-AZ primary + replica); 35-day PITR | Risk scores, alert history, audit metadata |
| ElastiCache Redis | `medcore-cds-prod-redis` | cache.r7g.large × 2 (primary + replica, Multi-AZ); 14,400s TTL | Patient context cache; alert duplicate suppression |
| Amazon MSK | `medcore-cds-prod-kafka` | kafka.m5.large × 3 (one per AZ); replication factor 3 | Internal event bus; partitioned by PatientID |
| Amazon Redshift | `medcore-cds-prod-redshift` | ra3.xlplus × 1; 7-day snapshot retention | Longitudinal outcomes analytics warehouse |
| Amazon HealthLake | `[healthlake-datastore-id]` | FHIR R4; 1 TB active + 500 GB/month import | HIPAA-eligible PHI datastore; longitudinal patient records |
| SageMaker Feature Store — Online | `medcore-cds-patient-features-online` | Sub-millisecond read latency; ~2,500 active patients at peak | Real-time feature vector retrieval for inference |
| SageMaker Feature Store — Offline | `medcore-cds-patient-features-offline` | S3-backed; historical snapshots for retraining | Weekly model retraining data source |

### Script Location

All compute resources are defined in the following IaC locations:

```
infrastructure/
  modules/
    compute/
      ecs.tf            # ECS Fargate cluster, services, task definitions, auto-scaling
      lambda.tf         # All Lambda function definitions, VPC config, environment variables
      sagemaker.tf      # SageMaker endpoints, endpoint configs, auto-scaling policies
      sagemaker_pipelines.tf  # SageMaker Pipeline definitions for model retraining
      feature_store.tf  # SageMaker Feature Store online and offline feature groups
      rds_aurora.tf     # Aurora PostgreSQL cluster, parameter group, subnet group
      elasticache.tf    # ElastiCache Redis cluster, subnet group, parameter group
      msk.tf            # MSK Kafka cluster, broker configuration, topic definitions
      redshift.tf       # Redshift cluster, subnet group, parameter group
      healthlake.tf     # HealthLake datastore (provisioned separately; see Section 3.2.3)
      variables.tf
      outputs.tf
  environments/
    prod/compute.tfvars
```

### Deployment Steps

Compute resources are deployed after networking and security layers are fully validated. The deployment sequence respects dependencies (e.g., RDS before Lambda; Feature Store before SageMaker endpoints).

```bash
# Step 1: Deploy data-tier resources first (Aurora, ElastiCache, MSK, Redshift)
ENVIRONMENT=prod
cd infrastructure/environments/${ENVIRONMENT}

terraform apply \
  -target=module.compute.aws_rds_cluster.aurora \
  -target=module.compute.aws_elasticache_replication_group.redis \
  -target=module.compute.aws_msk_cluster.kafka \
  -target=module.compute.aws_redshift_cluster.outcomes \
  -var-file=${ENVIRONMENT}.tfvars \
  -auto-approve

# Verify Aurora cluster is available
aws rds describe-db-clusters \
  --db-cluster-identifier medcore-cds-prod-aurora-cluster \
  --query 'DBClusters[0].{Status:Status,MultiAZ:MultiAZ,Engine:Engine}'
# Expected: {"Status": "available", "MultiAZ": true, "Engine": "aurora-postgresql"}
```

```bash
# Step 2: Deploy SageMaker Feature Store feature groups
terraform apply \
  -target=module.compute.aws_sagemaker_feature_group.online \
  -target=module.compute.aws_sagemaker_feature_group.offline \
  -var-file=${ENVIRONMENT}.tfvars \
  -auto-approve

# Verify feature groups are Created
aws sagemaker describe-feature-group \
  --feature-group-name medcore-cds-patient-features-online \
  --query 'FeatureGroupStatus'
# Expected: "Created"
```

```bash
# Step 3: Deploy Lambda functions (all four functions)
terraform apply \
  -target=module.compute.aws_lambda_function.fhir_connector \
  -target=module.compute.aws_lambda_function.hl7_adapter \
  -target=module.compute.aws_lambda_function.inference_orchestrator \
  -target=module.compute.aws_lambda_function.alert_router \
  -var-file=${ENVIRONMENT}.tfvars \
  -auto-approve

# Test FHIR connector with synthetic payload
aws lambda invoke \
  --function-name medcore-cds-prod-fhir-connector \
  --payload '{"test":true,"resourceType":"Observation"}' \
  --cli-binary-format raw-in-base64-out \
  response.json && cat response.json
# Expected: {"statusCode": 200, "body": "synthetic_test_ok"}
```

```bash
# Step 4: Deploy SageMaker inference endpoints (Phase 1: sepsis endpoint first)
terraform apply \
  -target=module.compute.aws_sagemaker_endpoint.sepsis \
  -var-file=${ENVIRONMENT}.tfvars \
  -auto-approve

# Wait for endpoint to be InService (5–10 minutes)
aws sagemaker describe-endpoint \
  --endpoint-name medcore-cds-prod-sepsis-ep \
  --query 'EndpointStatus'
# Expected: "InService"

# Run a test inference to confirm end-to-end functionality
aws sagemaker-runtime invoke-endpoint \
  --endpoint-name medcore-cds-prod-sepsis-ep \
  --body '{"features":[0.8,0.6,0.9,0.4,0.7]}' \
  --content-type "application/json" \
  --accept "application/json" \
  response.json && cat response.json
# Expected: {"sepsis_risk_score":0.XX, "shap_values":[...]}
```

```bash
# Step 5: Deploy ECS Fargate services (dashboard and API backend)
terraform apply \
  -target=module.compute.aws_ecs_service.dashboard \
  -target=module.compute.aws_ecs_service.api_backend \
  -var-file=${ENVIRONMENT}.tfvars \
  -auto-approve

# Verify ECS service tasks are RUNNING
aws ecs describe-services \
  --cluster medcore-cds-prod-cluster \
  --services medcore-cds-prod-dashboard-svc medcore-cds-prod-api-svc \
  --query 'services[].{Service:serviceName,Running:runningCount,Desired:desiredCount}'
# Expected: runningCount == desiredCount (4) for each service
```

### Validation

After full compute layer deployment, run these validation checks across all components.

- [ ] RDS Aurora cluster status = `available`; Multi-AZ confirmed; replica lag < 1 second
- [ ] ElastiCache Redis cluster status = `available`; replica synchronized; automatic failover enabled
- [ ] MSK cluster status = `ACTIVE`; all 3 brokers healthy; Kafka topics created with replication factor 3
- [ ] All 4 Lambda functions return HTTP 200 on synthetic test invocations
- [ ] SageMaker sepsis endpoint status = `InService`; test inference returns risk score and SHAP values
- [ ] SageMaker Feature Store online feature group status = `Created`; sample record ingested successfully
- [ ] ECS Fargate services running desired task count (4 tasks each); ALB health checks passing
- [ ] Redshift cluster available; QuickSight connection test passes
- [ ] End-to-end pipeline test: synthetic FHIR event → Kinesis → Feature Store → SageMaker → Bedrock → alert router (confirm < 3-second total)

### Success Criteria

- All compute resources in desired running/available state with zero CloudWatch alarms active
- End-to-end inference latency < 3,000 ms P95 on a 100-request synthetic load test in staging
- SageMaker endpoint CPU utilization < 70% at synthetic peak load (250 concurrent requests)
- RDS Aurora read replica lag < 1 second (CloudWatch `AuroraReplicaLag` metric)
- Kinesis DLQ message depth remains 0 after 1-hour synthetic traffic run

### Rollback

For compute rollback, use the targeted destroy approach. Data-tier resources (Aurora, ElastiCache) should only be destroyed if confirmed empty or if a rollback backup restoration is planned.

```bash
# Rollback SageMaker endpoint to previous model version (most common compute rollback)
# Retrieve previous production endpoint config from Model Registry
PREVIOUS_MODEL_VERSION=$(aws sagemaker list-model-packages \
  --model-package-group-name medcore-cds-model-registry \
  --model-approval-status Approved \
  --sort-by CreationTime \
  --sort-order Descending \
  --query 'ModelPackageSummaryList[1].ModelPackageArn' \
  --output text)

# Update endpoint to previous approved version (CodePipeline execution)
aws codepipeline start-pipeline-execution \
  --name medcore-cds-prod-sepsis-endpoint-deploy \
  --variables "name=MODEL_VERSION,value=${PREVIOUS_MODEL_VERSION}"
# Target rollback time: ≤ 15 minutes

# Rollback ECS Fargate service to previous task definition revision
aws ecs update-service \
  --cluster medcore-cds-prod-cluster \
  --service medcore-cds-prod-dashboard-svc \
  --task-definition medcore-cds-prod-dashboard:PREVIOUS_REVISION \
  --force-new-deployment
```

---

## Monitoring

The monitoring layer provisions Amazon CloudWatch dashboards and alarms, AWS X-Ray distributed tracing, Datadog APM agent configuration, Amazon QuickSight dashboards, and PagerDuty SNS integration. Monitoring must be deployed before any live clinical traffic is accepted and must be validated by the Amatra DevOps Engineer and MedCore IT Operations before go-live.

### Components

The table below lists all monitoring resources deployed by the IaC monitoring module.

| Component | Resource ID / Name | Specification | Purpose |
|-----------|-------------------|---------------|---------|
| CloudWatch Dashboard — Ingestion Pipeline | `medcore-cds-prod-ingestion` | Kinesis throughput, DLQ depth, FHIR connector errors, HL7 adapter errors | Real-time ingestion pipeline health visibility |
| CloudWatch Dashboard — ML Inference | `medcore-cds-prod-inference` | Per-endpoint P50/P95/P99 latency, invocation error rate, Bedrock latency | Inference latency and error monitoring; P95 3-second SLA gate |
| CloudWatch Dashboard — Application | `medcore-cds-prod-application` | ECS CPU/memory, ALB request rate and 5xx rate, Cognito auth events | Application-tier health and user authentication monitoring |
| CloudWatch Dashboard — Compliance | `medcore-cds-prod-compliance` | GuardDuty finding count, Config compliance %, CloudTrail delivery status, KMS key usage | Security and compliance posture visibility for CISO |
| CloudWatch Alarm — Inference Latency | `medcore-cds-prod-latency-alarm` | Critical; P95 > 3,000 ms for 2 consecutive 1-minute periods → SNS → PagerDuty | Immediate on-call paging for SLA breach |
| CloudWatch Alarm — Kinesis DLQ | `medcore-cds-prod-dlq-alarm` | High; DLQ depth > 0 for 5 minutes | Alerts on malformed FHIR events requiring investigation |
| CloudWatch Alarm — Platform Unavailability | `medcore-cds-prod-5xx-alarm` | Critical; ALB 5xx > 5% for 3 consecutive minutes → SNS → PagerDuty | Immediate paging for platform-wide availability issue |
| CloudWatch Alarm — GuardDuty Critical Finding | `medcore-cds-prod-guardduty-alarm` | Critical; any finding with severity ≥ 7.0 → SNS → CISO PagerDuty | Security incident immediate escalation |
| CloudWatch Alarm — SageMaker Error Rate | `medcore-cds-prod-sagemaker-error-alarm` | Critical; endpoint invocation error rate > 2% for 5 minutes | Model endpoint health degradation detection |
| CloudWatch Alarm — CloudTrail Delivery Failure | `medcore-cds-prod-cloudtrail-alarm` | Critical; no log delivery for > 15 minutes → CISO notification | Audit logging integrity protection |
| CloudWatch Alarm — Config Non-Compliance | `medcore-cds-prod-config-alarm` | High; any PHI-related resource NON_COMPLIANT → email + PagerDuty | Continuous compliance drift detection |
| SNS Topic — Operational Alarms | `[alarm-sns-topic-arn]` | Subscribers: PagerDuty integration (Critical), email (High) | Central alarm routing hub |
| AWS X-Ray | X-Ray Tracing Groups | Sampling rate 5% in production; end-to-end service map for inference path | Distributed latency tracing: Kinesis → Feature Store → SageMaker → Bedrock → SNS |
| Datadog APM Agent | ECS task definition sidecar + SageMaker endpoint container | 20 hosts (4 ECS services × 4 tasks + 4 SageMaker endpoints) | Enhanced application traces; PagerDuty-integrated on-call escalation during hypercare |
| QuickSight Dashboard — Clinical Outcomes | `medcore-cds-outcomes` | Refreshed every 15 minutes from Redshift; tracks sepsis trends, readmission rates, adoption metrics | Clinical Informatics Lead and Quality & Safety KPI monitoring |
| QuickSight Dashboard — Model Performance | `medcore-cds-model-perf` | Weekly AUROC trend, false-positive rate, alert precision by facility | SageMaker Model Monitor feeding QuickSight for drift alerting |

### Script Location

All monitoring resources are defined in the following IaC locations:

```
infrastructure/
  modules/
    monitoring/
      cloudwatch_dashboards.tf   # All 4 operational CloudWatch dashboards
      cloudwatch_alarms.tf       # All 12 CloudWatch alarms with SNS routing
      sns_topics.tf              # SNS topics for alarm routing and PagerDuty integration
      xray.tf                    # X-Ray tracing configuration and sampling rules
      datadog.tf                 # Datadog APM agent ECS task definition injection
      quicksight.tf              # QuickSight data sources, datasets, and dashboards
      variables.tf
      outputs.tf
  environments/
    prod/monitoring.tfvars
```

### Deployment Steps

The monitoring layer is deployed after compute resources are available (alarms reference compute resource ARNs and metric namespaces).

```bash
# Step 1: Deploy SNS topics and PagerDuty integration first
ENVIRONMENT=prod
cd infrastructure/environments/${ENVIRONMENT}

terraform apply \
  -target=module.monitoring.aws_sns_topic.operational_alarms \
  -target=module.monitoring.aws_sns_topic_subscription.pagerduty \
  -var-file=${ENVIRONMENT}.tfvars \
  -auto-approve

# Test SNS → PagerDuty integration with a test message
aws sns publish \
  --topic-arn "[alarm-sns-topic-arn]" \
  --message '{"AlarmName":"TEST-ALARM","AlarmDescription":"Connectivity test","NewStateValue":"ALARM"}' \
  --subject "CDS Platform Test Alert"
# Verify a low-urgency PagerDuty incident was created (acknowledge immediately)
```

```bash
# Step 2: Deploy CloudWatch alarms
terraform apply \
  -target=module.monitoring.aws_cloudwatch_metric_alarm.inference_latency \
  -target=module.monitoring.aws_cloudwatch_metric_alarm.kinesis_dlq \
  -target=module.monitoring.aws_cloudwatch_metric_alarm.alb_5xx \
  -target=module.monitoring.aws_cloudwatch_metric_alarm.guardduty \
  -target=module.monitoring.aws_cloudwatch_metric_alarm.sagemaker_error_rate \
  -target=module.monitoring.aws_cloudwatch_metric_alarm.cloudtrail_delivery \
  -var-file=${ENVIRONMENT}.tfvars \
  -auto-approve

# Verify all alarms are in OK or INSUFFICIENT_DATA state (not ALARM)
aws cloudwatch describe-alarms \
  --alarm-name-prefix medcore-cds-prod \
  --query 'MetricAlarms[].{Name:AlarmName,State:StateValue}'
```

```bash
# Step 3: Deploy CloudWatch dashboards
terraform apply \
  -target=module.monitoring \
  -var-file=${ENVIRONMENT}.tfvars \
  -auto-approve

# Verify dashboards exist
aws cloudwatch list-dashboards \
  --dashboard-name-prefix medcore-cds-prod \
  --query 'DashboardEntries[].DashboardName'
# Expected: 4 dashboards listed
```

```bash
# Step 4: Deploy X-Ray tracing configuration
# X-Ray is enabled via Lambda and ECS task definition environment variables
# Verify X-Ray service map is populated after running synthetic traffic
aws xray get-service-graph \
  --start-time $(date -d '1 hour ago' +%s) \
  --end-time $(date +%s) \
  --query 'Services[].Name'
# Expected: fhir-connector, kinesis, feature-store, sagemaker-sepsis-ep, bedrock, alert-router
```

```bash
# Step 5: Deploy QuickSight dashboards
# QuickSight data source connection to Redshift must be established first
aws quicksight create-data-source \
  --aws-account-id "[account-id]" \
  --data-source-id medcore-cds-redshift \
  --name "medcore-cds-outcomes-redshift" \
  --type REDSHIFT \
  --data-source-parameters \
    "RedshiftParameters={Host=[redshift-endpoint],Port=5439,Database=medcore_cds}" \
  --credentials \
    "CredentialPair={Username=[redshift-user],Password=[redshift-password]}"

# Verify QuickSight data source connection status
aws quicksight describe-data-source \
  --aws-account-id "[account-id]" \
  --data-source-id medcore-cds-redshift \
  --query 'DataSource.Status'
# Expected: "CREATION_SUCCESSFUL"
```

### Validation

After full monitoring layer deployment, validate each component before declaring monitoring ready.

- [ ] All 12 CloudWatch alarms are in `OK` or `INSUFFICIENT_DATA` state (none in `ALARM`)
- [ ] SNS → PagerDuty test message successfully creates a PagerDuty incident and is acknowledged
- [ ] All 4 CloudWatch dashboards render without errors; metrics appear for all deployed resources
- [ ] X-Ray service map shows complete end-to-end inference trace (Kinesis → Bedrock → SNS) after synthetic traffic run
- [ ] Datadog APM traces visible in Datadog console for ECS task containers; host count shows 20
- [ ] QuickSight dashboards load without connection errors; sample outcome data visible
- [ ] CloudTrail delivery alarm does NOT trigger after 30 minutes of trail operation (confirms healthy delivery)
- [ ] MedCore IT Operations team has been granted read-only access to CloudWatch dashboards and QuickSight

### Success Criteria

- All Critical alarms (inference latency, ALB 5xx, GuardDuty, CloudTrail) have verified PagerDuty routing confirmed by on-call engineer receiving and acknowledging a test page
- X-Ray P95 latency trace shows < 3,000 ms end-to-end on synthetic 100-request test
- CloudWatch Compliance dashboard shows 100% AWS Config compliance and CloudTrail delivery healthy
- QuickSight clinical outcomes dashboard accessible to Clinical Informatics Lead with correct data scope

### Rollback

Monitoring resources are non-destructive; rollback primarily involves disabling misconfigured alarms to prevent alert storms during troubleshooting.

```bash
# Temporarily disable a specific alarm during maintenance
aws cloudwatch disable-alarm-actions \
  --alarm-names medcore-cds-prod-latency-alarm

# Re-enable after maintenance window
aws cloudwatch enable-alarm-actions \
  --alarm-names medcore-cds-prod-latency-alarm

# If QuickSight dashboard is broken, delete and re-deploy
aws quicksight delete-dashboard \
  --aws-account-id "[account-id]" \
  --dashboard-id medcore-cds-outcomes

# Re-run Terraform to recreate dashboard
terraform apply \
  -target=module.monitoring.aws_quicksight_dashboard.outcomes \
  -var-file=${ENVIRONMENT}.tfvars \
  -auto-approve
```

---

# Application Configuration

This section defines the application-layer configuration required after all four infrastructure subsections (Networking, Security, Compute, Monitoring) are fully deployed. It covers service connection wiring, environment variable injection, IAM role assignments, alert routing rules, and SageMaker model configuration.

## Service Connection Configuration

All service connections use Secrets Manager for credential injection at runtime. No credentials are stored in environment variables, task definitions, or source code. The following configuration validates that all application-tier services can reach their data-tier dependencies.

```yaml
# config/application-prod.yml
# All sensitive values injected from AWS Secrets Manager at ECS task launch time
application:
  name: medcore-cds
  version: "1.0.0"
  environment: prod
  region: us-east-1

logging:
  level: info
  format: json
  output: cloudwatch
  group: /medcore-cds/prod/dashboard-api

database:
  host: "${DB_HOST}"                  # Aurora cluster DNS endpoint
  port: 5432
  name: medcore_cds
  ssl_mode: require
  pool_size: 20
  connection_timeout_ms: 5000

cache:
  endpoint: "${REDIS_ENDPOINT}"       # ElastiCache Redis primary endpoint
  port: 6379
  tls_enabled: true
  ttl_patient_context_seconds: 14400
  ttl_duplicate_suppression_seconds: 1800

sagemaker:
  sepsis_endpoint: medcore-cds-prod-sepsis-ep
  readmission_endpoint: medcore-cds-prod-readmission-ep
  rapid_response_endpoint: medcore-cds-prod-rapid-response-ep
  ensemble_endpoint: medcore-cds-prod-ensemble-ep
  latency_budget_ms: 1500
  shap_enabled: true

bedrock:
  model_id: anthropic.claude-3-sonnet-20240229-v1:0
  max_tokens: 512
  timeout_ms: 1000
  fallback_on_timeout: true   # Deliver alert without narrative if Bedrock exceeds 2s
  prompt_template_version: v1.0
  prompt_template_ssm_path: /medcore-cds/prod/bedrock/prompt-template

kinesis:
  stream_name: medcore-cds-prod-events
  shard_count: 10

feature_store:
  online_group: medcore-cds-patient-features-online
  offline_group: medcore-cds-patient-features-offline
  completeness_threshold: 0.8
```

## Environment Variable Reference

The following table lists all environment variables for ECS Fargate task definitions and Lambda function configurations. Sensitive values reference Secrets Manager ARNs and must never be hardcoded.

| Variable | Description | Source | Required |
|----------|-------------|--------|----------|
| `APP_ENVIRONMENT` | Deployment environment identifier | Static: `prod` | Yes |
| `DB_HOST` | Aurora PostgreSQL cluster endpoint DNS name | SSM Parameter Store: `/medcore-cds/prod/aurora/endpoint` | Yes |
| `REDIS_ENDPOINT` | ElastiCache Redis primary endpoint | SSM Parameter Store: `/medcore-cds/prod/redis/endpoint` | Yes |
| `AURORA_SECRET_ARN` | Secrets Manager ARN for Aurora credentials | Static: `[aurora-secret-arn]` | Yes |
| `EPIC_OAUTH_SECRET_ARN` | Secrets Manager ARN for Epic SMART on FHIR OAuth credentials | Static: `[epic-oauth-secret-arn]` | Yes |
| `MIRTH_API_KEY_ARN` | Secrets Manager ARN for Mirth Connect API key | Static: `[mirth-api-key-arn]` | Yes |
| `KINESIS_STREAM_NAME` | Kinesis stream name for event production | Static: `medcore-cds-prod-events` | Yes |
| `HEALTHLAKE_DATASTORE_ID` | HealthLake FHIR R4 datastore ID | SSM Parameter Store: `/medcore-cds/prod/healthlake/datastore-id` | Yes |
| `COGNITO_USER_POOL_ID` | Cognito User Pool ID for JWT validation | SSM Parameter Store: `/medcore-cds/prod/cognito/user-pool-id` | Yes |
| `COGNITO_CLIENT_ID` | Cognito App Client ID | SSM Parameter Store: `/medcore-cds/prod/cognito/client-id` | Yes |
| `BEDROCK_MODEL_ID` | Amazon Bedrock Claude model identifier | Static: `anthropic.claude-3-sonnet-20240229-v1:0` | Yes |
| `ALERT_RISK_THRESHOLD_SEPSIS` | Sepsis risk score threshold for alert generation | SSM Parameter Store: `/medcore-cds/prod/models/sepsis/threshold` (default: `0.7`) | Yes |
| `DATADOG_API_KEY_ARN` | Secrets Manager ARN for Datadog APM API key | Static: `[datadog-api-key-arn]` | Yes |
| `AWS_XRAY_SDK_ENABLED` | Enable AWS X-Ray distributed tracing | Static: `true` | Yes |

## IAM Role Assignments

All service-to-service permissions are granted via IAM role policies. The following commands verify that each Lambda function and ECS task is operating under its correct dedicated role.

```bash
# Verify Lambda execution roles
for fn in fhir-connector hl7-adapter inference-orchestrator alert-router; do
  ROLE=$(aws lambda get-function-configuration \
    --function-name medcore-cds-prod-${fn} \
    --query 'Role' --output text)
  echo "${fn}: ${ROLE}"
done
# Each function must have its own dedicated role: medcore-cds-prod-{fn}-role

# Verify ECS task execution role
aws ecs describe-task-definition \
  --task-definition medcore-cds-prod-dashboard \
  --query 'taskDefinition.{ExecutionRole:executionRoleArn,TaskRole:taskRoleArn}'
# Expected: separate execution role and task role per component
```

## EventBridge Alert Routing Rules

Alert routing rules are version-controlled in Terraform and deployed via CodePipeline. The following snippet shows the Terraform resource for the nurse role routing rule; similar rules exist for each clinical role type.

```hcl
# infrastructure/modules/compute/eventbridge.tf
resource "aws_cloudwatch_event_rule" "nurse_alert_routing" {
  name        = "medcore-cds-${var.environment}-nurse-alerts"
  description = "Routes sepsis and rapid-response alerts to nurse role for assigned patients"

  event_pattern = jsonencode({
    source      = ["medcore.cds.inference"]
    detail-type = ["ClinicalRiskAlert"]
    detail = {
      targetRole  = ["NURSE"]
      riskScore   = [{ numeric = [">=", 0.7] }]
      alertType   = ["SEPSIS", "RAPID_RESPONSE"]
    }
  })

  tags = {
    Environment = var.environment
    Application = "medcore-cds"
    Compliance  = "hipaa"
  }
}

resource "aws_cloudwatch_event_target" "nurse_sns" {
  rule      = aws_cloudwatch_event_rule.nurse_alert_routing.name
  target_id = "NurseSNSTarget"
  arn       = aws_sns_topic.nurse_alerts.arn
}
```

## SageMaker Model Registry Promotion

Before any model endpoint goes live, the model version must be approved in the SageMaker Model Registry by the Clinical Informatics Lead. The following procedure validates and promotes a model version.

```bash
# List pending model packages awaiting approval
aws sagemaker list-model-packages \
  --model-package-group-name medcore-cds-model-registry \
  --model-approval-status PendingManualApproval \
  --query 'ModelPackageSummaryList[].{ARN:ModelPackageArn,Created:CreationTime}'

# Review model metrics (AUROC must be ≥ 0.85 for sepsis model)
MODEL_ARN="arn:aws:sagemaker:us-east-1:123456789012:model-package/medcore-cds-model-registry/1"

aws sagemaker describe-model-package \
  --model-package-name "${MODEL_ARN}" \
  --query 'ModelMetrics.ModelQuality.Statistics.ContentType'

# After Clinical Informatics Lead confirms AUROC ≥ 0.85, approve the model
aws sagemaker update-model-package \
  --model-package-arn "${MODEL_ARN}" \
  --model-approval-status Approved \
  --approval-description "AUROC 0.87 validated by Clinical Informatics Lead - Phase 1 go-live approval"

# Trigger CodePipeline to deploy approved model to production endpoint
aws codepipeline start-pipeline-execution \
  --name medcore-cds-prod-sepsis-endpoint-deploy
```

## Post-Deployment Validation Checklist

After application configuration is complete, validate the full application stack with these checks.

- [ ] All Lambda functions respond to health-check invocations with HTTP 200
- [ ] FHIR connector successfully ingests synthetic FHIR subscription event and produces record to Kinesis
- [ ] HL7 adapter successfully parses ADT and ORU messages from Mirth Connect test feed
- [ ] Inference orchestrator retrieves patient context from ElastiCache, invokes SageMaker, and receives risk score + SHAP payload
- [ ] Bedrock narrative generation returns a plain-language clinical narrative for a test alert payload
- [ ] Alert router correctly suppresses duplicate alerts within 30-minute window (verified via Redis TTL check)
- [ ] Alert router successfully writes to RDS Aurora alert history table
- [ ] Clinical dashboard accessible via HTTPS at production ALB DNS; Cognito SSO flow redirects to Azure AD login
- [ ] Role-based access confirmed: nurse role sees only assigned-patient alerts; physician role sees full explanation panel
- [ ] End-to-end pipeline: synthetic FHIR event → Kinesis → Feature Store → SageMaker (sepsis) → Bedrock → SNS alert delivered (< 3-second wall clock)

---

# Integration Testing

This section covers the end-to-end integration test procedures for all three external integration points (Epic FHIR R4, Mirth Connect HL7 v2.3, and Azure AD SSO) as well as the internal pipeline integration from ingestion to alert delivery.

## Epic FHIR R4 Integration Testing

All Epic FHIR R4 integration tests must be run using the Epic FHIR R4 test environment with synthetic PHI. No real patient data may be used in testing outside of the Production environment.

```bash
# Test 1: Authenticate to Epic FHIR R4 using SMART on FHIR OAuth 2.0
curl -X POST "[epic-oauth-token-url]" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&client_id=[client-id]&client_secret=[from-secrets-manager]&scope=system/*.read"
# Expected: {"access_token": "...", "token_type": "Bearer", "expires_in": 3600}

# Test 2: Query a synthetic patient Observation resource
ACCESS_TOKEN="[access-token-from-step-1]"
curl -X GET "[epic-fhir-base-url]/Observation?patient=[synthetic-patient-id]&code=59408-5" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Accept: application/fhir+json"
# Expected: FHIR Bundle with Observation resources for SpO2

# Test 3: Verify FHIR subscription event triggers FHIR connector Lambda
# Post a synthetic Observation to the FHIR inbound ALB endpoint
curl -X POST "https://[alb-fhir-inbound-dns]/api/v1/fhir/subscription" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/fhir+json" \
  -d @tests/synthetic_observation.json
# Expected: HTTP 200 {"status":"accepted","kinesis_sequence_number":"[seq]"}

# Test 4: Verify the event reached Kinesis Data Streams
aws kinesis get-shard-iterator \
  --stream-name medcore-cds-prod-events \
  --shard-id shardId-000000000000 \
  --shard-iterator-type LATEST \
  --query 'ShardIterator' --output text > /tmp/shard-iterator.txt

aws kinesis get-records \
  --shard-iterator $(cat /tmp/shard-iterator.txt) \
  --limit 10 \
  --query 'Records[].SequenceNumber'
# Expected: One or more sequence numbers present
```

## Mirth Connect HL7 v2.3 Integration Testing

```bash
# Test 1: Send a synthetic ORU R01 vitals message to the HL7 adapter
# From within the private application subnet (EC2 test instance or Lambda)
python3 tests/send_hl7_test_message.py \
  --endpoint "[mirth-endpoint-url]" \
  --message-type ORU_R01 \
  --patient-id "TEST-PATIENT-001" \
  --vital-type heart_rate \
  --value 120

# Test 2: Verify HL7 adapter Lambda processed the message
aws logs filter-log-events \
  --log-group-name /medcore-cds/prod/hl7-adapter \
  --filter-pattern "TEST-PATIENT-001" \
  --start-time $(date -d '5 minutes ago' +%s000) \
  --query 'events[].message'
# Expected: Log entry showing ORU R01 parsed and produced to Kinesis

# Test 3: Test ADT A01 admission message processing
python3 tests/send_hl7_test_message.py \
  --endpoint "[mirth-endpoint-url]" \
  --message-type ADT_A01 \
  --patient-id "TEST-PATIENT-002"
# Expected: ADT event appears in CloudWatch Logs for hl7-adapter
```

## End-to-End Pipeline Integration Test

The following test exercises the complete pipeline from FHIR event ingestion to alert delivery, measuring end-to-end latency against the 3-second SLA.

```bash
# Run the end-to-end integration test script
python3 tests/e2e_pipeline_test.py \
  --environment prod \
  --patient-count 10 \
  --scenario sepsis_high_risk \
  --timeout-seconds 10

# Expected output:
# Test Patient TEST-E2E-001: 2,847ms ✓ (Alert delivered to SNS)
# Test Patient TEST-E2E-002: 2,631ms ✓ (Alert delivered to SNS)
# ...
# Summary: 10/10 alerts delivered; max latency 2,991ms; P95 2,843ms ✓ (SLA: < 3,000ms)
```

## Azure AD SSO Integration Test

```bash
# Test SSO flow from clinical dashboard URL
# Use MedCore test user accounts for each of the 4 clinical role types

# Test Nurse role: confirm only assigned-patient alerts visible
curl -X GET "https://[alb-dashboard-dns]/api/v1/patients/TEST-PATIENT-001/alerts" \
  -H "Authorization: Bearer [nurse-role-jwt]"
# Expected: HTTP 200, only alerts for TEST-PATIENT-001 in nurse's assigned unit

# Test Physician role: confirm full SHAP explanation accessible
curl -X GET "https://[alb-dashboard-dns]/api/v1/patients/TEST-PATIENT-001/alerts" \
  -H "Authorization: Bearer [physician-role-jwt]" \
  --query 'alerts[0].shap_payload'
# Expected: HTTP 200, SHAP values present in response body

# Test cross-patient access denied for nurse
curl -X GET "https://[alb-dashboard-dns]/api/v1/patients/TEST-PATIENT-DIFF-UNIT/alerts" \
  -H "Authorization: Bearer [nurse-role-jwt]"
# Expected: HTTP 403 Forbidden
```

## Integration Test Summary Gate

All integration tests must pass before Phase 1 production go-live is authorized. The following items are the integration test gate criteria.

- [ ] Epic FHIR R4 OAuth 2.0 authentication succeeds in production environment
- [ ] FHIR subscription events trigger Lambda connector and produce records to Kinesis
- [ ] HL7 v2.3 ORU R01 and ADT A01/A03/A08 messages processed by HL7 adapter without DLQ errors
- [ ] End-to-end pipeline P95 latency < 3,000 ms across 10+ synthetic high-risk patient scenarios
- [ ] RBAC enforcement confirmed for all 4 clinical role types (nurse, physician, administrator, data scientist)
- [ ] Alert duplicate suppression prevents repeat alerts within 30-minute window
- [ ] Epic CDS Hooks write-back delivers alert card to Epic test workflow successfully
- [ ] Nightly SQL Server readmission export Lambda runs at scheduled time and completes without errors

---

# Security Validation

This section defines the HIPAA security controls validation checklist that the Amatra Security Engineer and MedCore CISO must complete and sign off before any PHI enters the production environment and before each facility go-live during Phase 3 rollout.

## HIPAA Security Controls Validation

The CISO must formally sign off that all controls below have been verified. This checklist is included in the Test Results Report.

### PHI Encryption at Rest

- [ ] HealthLake FHIR datastore encrypted with KMS CMK `alias/medcore-cds-prod-healthlake` (verify via `aws healthlake describe-fhir-datastore`)
- [ ] RDS Aurora cluster encrypted with `alias/medcore-cds-prod-aurora`; snapshot encryption confirmed
- [ ] S3 data lake bucket encrypted with `alias/medcore-cds-prod-s3-datalake`; default encryption enforced
- [ ] S3 audit bucket encrypted with `alias/medcore-cds-prod-s3-audit`; no unencrypted objects
- [ ] ElastiCache Redis at-rest encryption enabled with `alias/medcore-cds-prod-elasticache`
- [ ] EBS volumes for MSK brokers encrypted with `alias/medcore-cds-prod-ebs`
- [ ] All KMS CMK auto-rotation enabled; rotation status confirmed

### PHI Encryption in Transit

- [ ] All ALB listeners enforce HTTPS-only (HTTP → HTTPS 301 redirect confirmed)
- [ ] TLS 1.2+ confirmed on all ALB and API Gateway endpoints (TLS scan using `nmap --script ssl-enum-ciphers`)
- [ ] SageMaker endpoint invocations using HTTPS via PrivateLink (no public endpoint)
- [ ] Bedrock API calls using HTTPS via PrivateLink
- [ ] HealthLake API calls using HTTPS via PrivateLink
- [ ] Direct Connect MACsec encryption verified (where supported by hosted connection provider)
- [ ] Site-to-site VPN using IKEv2/AES-256 (VPN connection configuration confirmed)
- [ ] No PHI-bearing Lambda environment variables in plaintext (Secrets Manager ARN injection verified)

### Access Control Validation

```bash
# Verify Cognito user pool configuration
aws cognito-idp describe-user-pool \
  --user-pool-id "[cognito-user-pool-id]" \
  --query 'UserPool.{MFA:MfaConfiguration,TokenValidity:TokenValidityUnits}'

# List Cognito groups (should have exactly 4 clinical role groups)
aws cognito-idp list-groups \
  --user-pool-id "[cognito-user-pool-id]" \
  --query 'Groups[].GroupName'
# Expected: ["NURSE","PHYSICIAN","ADMINISTRATOR","DATA_SCIENTIST"]

# Verify no Lambda function has wildcard IAM permissions
for fn in fhir-connector hl7-adapter inference-orchestrator alert-router; do
  ROLE=$(aws lambda get-function-configuration \
    --function-name medcore-cds-prod-${fn} \
    --query 'Role' --output text | awk -F'/' '{print $NF}')
  aws iam get-role-policy \
    --role-name "${ROLE}" \
    --policy-name "${ROLE}-policy" \
    --query 'PolicyDocument.Statement[?Action==`*`].Action'
  # Expected: [] (no wildcard actions)
done
```

- [ ] Cognito session token expiry = 8 hours (aligned to clinical shift length)
- [ ] IAM Access Analyzer reports zero external access findings
- [ ] Break-glass role requires CIO written approval; test activation logged to CloudTrail confirmed
- [ ] Secrets Manager rotation confirmed for all 5 secrets (rotation test: manually trigger rotation, confirm new version active)

### HIPAA Audit Logging Validation

```bash
# Verify CloudTrail is logging PHI access events
# Generate a test HealthLake read event
aws healthlake start-fhir-import-job \
  --datastore-id "[healthlake-datastore-id]" \
  --input-data-config S3Uri="s3://[datalake-bucket]/test/" \
  --data-access-role-arn "arn:aws:iam::[account-id]:role/medcore-cds-prod-healthlake-import-role" \
  --region us-east-1

# Wait 2 minutes, then query Athena for the CloudTrail event
aws athena start-query-execution \
  --query-string "SELECT eventTime, userIdentity.arn, eventName, requestParameters FROM cloudtrail_logs WHERE eventSource='healthlake.amazonaws.com' AND eventTime > '$(date -u -d '5 minutes ago' +%Y-%m-%dT%H:%M:%SZ)' LIMIT 10" \
  --query-execution-context Database=medcore_cds_audit \
  --result-configuration OutputLocation="s3://[datalake-bucket]/athena-results/"
# Expected: At least one HealthLake API call appears in CloudTrail within 2 minutes
```

- [ ] CloudTrail organization-level trail delivering to S3 audit bucket with < 5-minute delay
- [ ] S3 audit bucket Object Lock (Compliance mode, 7-year retention) confirmed on audit objects
- [ ] Log file validation enabled and no integrity violations detected
- [ ] Athena query layer on CloudTrail functional; CISO can execute PHI access audit query in < 30 seconds
- [ ] CloudWatch Logs group `/medcore-cds/prod/` present for all services; 90-day retention configured

## SOC 2 Type II Readiness Checklist

The following items confirm SOC 2 Type II evidence collection is operational before GA.

- [ ] AWS Config rules: all HIPAA rules in COMPLIANT state; compliance history snapshots available for auditors
- [ ] Security Hub standard enabled; overall compliance score > 90%; all Critical findings remediated
- [ ] GuardDuty enabled for ≥ 30 days before SOC 2 audit window; findings history available
- [ ] Quarterly access review process documented and first review completed; Cognito role assignments verified
- [ ] All production changes deployed exclusively via CodePipeline (no manual console changes found in CloudTrail)
- [ ] SOC 2 evidence package (Config snapshots, CloudTrail exports, access control reports) produced and delivered to MedCore CISO

## Go-Live Security Sign-Off

Before any facility is activated for live clinical use, the following security gate items must all be confirmed in writing by the CISO.

- [ ] Zero Critical or High unresolved Security Hub findings
- [ ] HIPAA security controls validation checklist signed by CISO
- [ ] All Critical and High penetration test findings remediated and re-tested
- [ ] AWS CloudTrail audit logging validated end-to-end for all PHI access event types
- [ ] KMS CMK status confirmed ENABLED with rotation active for all 6 CMKs
- [ ] MedCore CISO formal go-live security approval recorded

---

# Migration & Cutover

The CDS Platform is a greenfield AWS implementation with no legacy data migration required for the core operational platform. Migration activities are limited to ML training data preparation and the phased cutover from the Epic rule-based alert system to the CDS Platform.

## Migration Approach

**Type:** Greenfield build with phased activation. No data migration of operational systems is required. ML training data is delivered by MedCore's Clinical Informatics team as a one-time de-identified dataset.

**Training Data Preparation Timeline:**

| Phase | Data Type | Volume | Source | Delivery Method | Validation |
|-------|-----------|--------|--------|-----------------|------------|
| 1 | Sepsis historical events (2+ years) | ≥ 500 GB | Epic Clarity DB (MedCore-managed extract) | S3 upload to `medcore-cds-dev-datalake` | Row counts, schema conformance, outcome label distribution |
| 2 | Readmission historical events (2+ years) | ≥ 300 GB | Epic Clarity DB | S3 upload | Readmission outcome linkage validation |
| 3 | Rapid-response events (2+ years) | ≥ 200 GB | Epic Clarity DB + Mirth Connect historical HL7 | S3 upload | Temporal integrity check, vital sign completeness |
| All | De-identification validation | N/A | HealthLake FHIR de-identification | Macie PHI scan on S3 | Zero PHI identifiers in training data |

## Cutover Plan

**Phase 1 Cutover (2026-10-31 target — pilot facility cohort):**

The Phase 1 production cutover follows a blue/green + shadow mode approach designed to eliminate clinical risk from the initial activation.

**Pre-Cutover Checklist (complete ≥ 48 hours before cutover window):**

- [ ] All go-live readiness criteria met (see Prerequisites Section)
- [ ] Epic rule-based system confirmed active as clinical backstop
- [ ] Nursing manager and on-call physician at pilot facility notified of shadow period start
- [ ] Amatra Technical Lead and MedCore Clinical Informatics Lead available for the full shadow period
- [ ] Rollback procedure dry-run completed (previous model version restored and re-deployed in < 15 minutes)
- [ ] PagerDuty on-call rotation confirmed; Critical SLA: 1-hour response

**Cutover Window:** 2026-10-31 08:00 ET (non-peak clinical hours; avoids overnight shift handover)

**Go/No-Go Criteria:**

- Sepsis model AUROC ≥ 0.85 (Clinical Informatics Lead sign-off on file)
- End-to-end P95 latency < 3,000 ms validated in staging load test
- Zero Critical security findings; CISO sign-off received
- All UAT test scenarios passed at pilot facility (CMO representative sign-off)
- Direct Connect and VPN connectivity stable for ≥ 72 hours
- CloudTrail audit logging verified end-to-end

**Shadow Mode Procedure (48 hours):**

```bash
# Step 1: Deploy CDS Platform in shadow mode (alerts generated but NOT delivered to clinical staff)
# Update EventBridge routing rule to shadow mode via CodePipeline
aws codepipeline start-pipeline-execution \
  --name medcore-cds-prod-alert-routing-config \
  --variables "name=ALERT_DELIVERY_MODE,value=SHADOW"

# Step 2: Monitor shadow alert volume and latency for 48 hours
# Expected: 50–200 shadow alerts/day at pilot facility; P95 latency < 3,000ms
aws cloudwatch get-metric-statistics \
  --namespace MedCoreCDS \
  --metric-name ShadowAlertCount \
  --dimensions Name=Facility,Value=[pilot-facility-id] \
  --start-time "$(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ)" \
  --end-time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --period 3600 \
  --statistics Sum
```

**Live Alert Delivery Flip (authorized by Clinical Informatics Lead after 48-hour shadow validation):**

```bash
# Step 3: Flip from shadow mode to live alert delivery
aws codepipeline start-pipeline-execution \
  --name medcore-cds-prod-alert-routing-config \
  --variables "name=ALERT_DELIVERY_MODE,value=LIVE"

# Confirm EventBridge rules updated
aws events list-rules \
  --name-prefix medcore-cds-prod \
  --query 'Rules[].{Name:Name,State:State}'
# All rules must show State=ENABLED
```

**Post-Cutover Parallel Run (2 weeks):**

Both the CDS Platform (live alert delivery) and the Epic rule-based system remain active in parallel for 2 weeks post-cutover. The Clinical Informatics Lead monitors for any discrepancy in alert volume or clinical response patterns. The Epic rule-based system is formally decommissioned at that facility only after 2-week parallel run success.

## Rollback Triggers and Procedures

**Automatic Rollback Triggers:**
- P95 inference latency > 3,000 ms within 30 minutes of any deployment (CI/CD pipeline auto-rollback)
- SageMaker endpoint invocation error rate > 2% sustained for 5 minutes

**Manual Rollback Triggers:**
- Clinical Informatics Lead or CMO requests rollback during shadow or live period
- Any Critical patient safety event linked to incorrect or missing alert

**Rollback Procedure:**

```bash
# Immediate rollback: restore previous SageMaker model endpoint version
aws codepipeline start-pipeline-execution \
  --name medcore-cds-prod-sepsis-endpoint-deploy \
  --variables "name=ROLLBACK,value=true"
# Target: ≤ 15 minutes to restore previous production endpoint

# Simultaneously flip EventBridge routing back to Epic rule-based system
aws codepipeline start-pipeline-execution \
  --name medcore-cds-prod-alert-routing-config \
  --variables "name=ALERT_DELIVERY_MODE,value=EPIC_RULESET"

# Notify stakeholders immediately
aws sns publish \
  --topic-arn "[alarm-sns-topic-arn]" \
  --message "ROLLBACK INITIATED: CDS Platform Phase 1. Reverting to Epic rule-based alerts. Investigation in progress." \
  --subject "CDS Platform Rollback Alert"
```

**Phase 3 Facility Rollout Cadence:**

During Phase 3 (full 18-hospital rollout), each facility cohort follows the same shadow + live + parallel run procedure above. The rollout schedule is planned in cohorts of 3–4 hospitals per bi-weekly sprint to allow Amatra support engineers to monitor each activation before the next cohort begins.

---

# Operational Handover

## Documentation Handover

All documentation is formally transferred to MedCore at engagement completion (Week 44, ahead of M8 Enterprise GA). The Technical Writer produces all documents in parallel with Phase 5 rollout activities.

- [ ] Architecture documentation (as-built architecture diagrams, VPC/subnet configuration, infrastructure decision log) — delivered to MedCore CIO
- [ ] IaC Repository (all Terraform/CDK modules, environment configuration files, pipeline definitions) — committed to MedCore GitHub; Amatra engineers removed from repository after handover
- [ ] ML Model Cards (one per trained model: sepsis, readmission, rapid-response) — training data, features, AUROC/sensitivity/specificity, known limitations, retraining schedule, bias assessment — delivered to Clinical Informatics Lead
- [ ] FHIR Resource Mapping Specification (Epic FHIR R4 resource fields to SageMaker Feature Store schema) — delivered to EHR Integration Lead
- [ ] Data Flow Diagrams (end-to-end data lineage from Epic/Mirth to HealthLake, Feature Store, Redshift, SQL Server export) — delivered to CIO
- [ ] Security Architecture Document (KMS key inventory, IAM role catalogue, SCP list, Cognito configuration, HIPAA control mapping) — delivered to CISO
- [ ] Operational Runbooks (ingestion pipeline failure, SageMaker endpoint latency breach, Bedrock quota exhaustion, Direct Connect failover, model rollback) — delivered to CIO/IT Operations
- [ ] HIPAA Compliance Evidence Package (CloudTrail exports, Config snapshots, access control reports for SOC 2 Type II audit) — delivered to CISO
- [ ] Test Results Report (comprehensive test execution results, model validation metrics, pen test findings and remediation evidence) — delivered to CMO/CIO/CISO

## Support Transition

### Support Model

The following support model defines the escalation tiers from MedCore IT Operations through Amatra during hypercare and into steady-state operations after hypercare ends.

| Tier | Responsibility | Response Time | Escalation |
|------|----------------|---------------|------------|
| L1 — MedCore IT Help Desk | Initial clinical alert triage; known issue resolution via runbook | < 1 hour | Escalate to L2 after 2 hours if unresolved |
| L2 — MedCore IT Operations | Technical troubleshooting; CloudWatch dashboard investigation; runbook execution | < 4 hours | Escalate to L3 (Amatra hypercare) after 8 hours |
| L3 — Amatra Hypercare (during hypercare) | Expert resolution; code-level defect repair; model rollback; configuration changes | Critical: 1-hour response / 4-hour resolution; High: 4-hour response / NBD resolution | Escalate to Amatra Lead Architect for complex issues; vendor support for AWS service issues |
| L3 — MedCore IT Advanced (post-hypercare) | Expert resolution using delivered runbooks and as-built documentation | Per internal MedCore SLA | Amatra on-call via MSA (if applicable); AWS Business Support for infrastructure issues |

### Escalation Path

For the 8-week hypercare period, all Critical incidents (patient safety impact or platform unavailability) are escalated to the Amatra Senior Support Engineer via PagerDuty within 1 hour. The Amatra Lead Solutions Architect is available for complex technical escalation within 2 hours of any Critical incident. MedCore CIO is notified of all Critical incidents within 30 minutes of detection via automated SNS email.

## Hypercare Period

**Duration:** 8 weeks post-GA (following M8 Enterprise GA at 2027-06-30; Hypercare End = Q3 2027 + 8 weeks)

**Coverage:** Extended business hours plus on-call — Monday–Friday 07:00–22:00 ET; on-call paging for Critical incidents outside business hours

**Response SLAs:**
- **Critical** (patient safety impact or platform unavailability): 1-hour response / 4-hour resolution target
- **High** (alert delivery degraded, model latency elevated): 4-hour response / next-business-day resolution
- **Medium/Low**: 2-business-day response

**Scope:** Defect resolution for issues originating from the delivered solution; configuration assistance; model performance monitoring. Change requests (new features, additional models) are out of hypercare scope and require a separate work order.

**Not Included:** New feature development; scope additions; third-party system issues (Epic EHR, Azure AD, Mirth Connect infrastructure)

## Handover Checklist

- [ ] All documentation delivered and formally accepted in writing by MedCore CIO and CISO
- [ ] IaC repository ownership transferred to MedCore GitHub; Amatra engineers removed
- [ ] MedCore IT Operations team trained on all operational runbooks (dry-run exercise completed)
- [ ] MedCore IT Operations has full CloudWatch dashboard access and can independently investigate L1/L2 incidents
- [ ] PagerDuty on-call rotation transitioned from Amatra to MedCore IT Operations post-hypercare
- [ ] Emergency contacts documented: Amatra escalation path, AWS Business Support, key vendor contacts
- [ ] Cognito access review completed; all Amatra engineer accounts deprovisioned from production
- [ ] Final outcomes report (KPI baseline vs. actual) delivered to CMO and CIO

---

# Training Program

This section defines the complete training program for all user groups. The program ensures that all clinical staff, administrators, IT Operations, and data engineering personnel achieve competency with the CDS Platform before go-live and establishes ongoing learning paths for new team members.

## Training Overview

### Objectives

The training program ensures all MedCore user groups achieve competency with the CDS Platform before each facility's go-live and establishes a self-sustaining train-the-trainer model for the ongoing 18-hospital rollout. Training is delivered using a role-based, phased approach integrated with the Phase 3 facility rollout timeline.

### Training Approach

- **Phased Delivery:** Technical training (IT and data engineering) delivered at Week 42–44 ahead of final handover; clinical training (train-the-trainer) delivered at Week 44 ahead of GA
- **Role-Based:** Content is tailored to each audience's responsibilities and daily workflows; no generic one-size-fits-all sessions
- **Hands-On Focus:** All technical and admin training includes live exercises in the sandbox environment; clinical training uses the UAT staging environment with de-identified PHI
- **Train-the-Trainer Model:** Amatra delivers master training to 18 Clinical Champions (one per facility); Champions train local nursing and physician staff
- **Documentation:** Complete written materials, recorded session videos, and quick reference cards provided for self-service learning post-handover

### Training Schedule

The following table lists all 10 training modules with target audience, duration, format, and prerequisites.

| Module ID | Module Name | Target Audience | Duration | Format | Prerequisites |
|-----------|-------------|-----------------|----------|--------|---------------|
| TRN-001 | CDS Platform Architecture Overview | IT Operations, Data Engineering | 2 hours | ILT (Instructor-Led) | None |
| TRN-002 | IaC and Infrastructure Operations | IT Operations, Cloud Engineering | 4 hours | Hands-On Lab | TRN-001 |
| TRN-003 | ML Pipeline Operations and Model Retraining | Data Engineering, IT Operations | 4 hours | Hands-On Lab | TRN-001 |
| TRN-004 | Kinesis, MSK, and Ingestion Pipeline Troubleshooting | IT Operations, Data Engineering | 3 hours | ILT + Lab | TRN-002 |
| TRN-005 | Incident Response and Runbook Execution | IT Operations | 3 hours | Tabletop + Lab | TRN-002, TRN-004 |
| TRN-006 | Clinical Dashboard Navigation for End Users | Nurses, Clinical Staff | 1.5 hours | VILT (Virtual ILT) | None |
| TRN-007 | Understanding AI Risk Scores and SHAP Explanations | Nurses, Physicians, Hospitalists | 2 hours | VILT + Lab | TRN-006 |
| TRN-008 | Alert Management and Escalation Workflows | Nurses, Physicians, Administrators | 1.5 hours | VILT + Scenarios | TRN-007 |
| TRN-009 | Administrator Console and Reporting | Clinical Administrators | 2 hours | Hands-On Lab | TRN-006 |
| TRN-010 | Train-the-Trainer Facilitation Workshop | Clinical Champions (18 facility leads) | 8 hours | Workshop (2-day split) | TRN-006–TRN-009 |

---

## IT Operations and Data Engineering Training

The technical track prepares MedCore's IT and data engineering teams to operate and maintain the CDS Platform independently after hypercare ends.

### TRN-001: CDS Platform Architecture Overview (2 hours, ILT)

This session provides MedCore IT Operations and data engineering staff with a comprehensive understanding of the CDS Platform's architecture, data flows, and operational model.

**Learning Objectives:**
- Describe the six functional layers of the CDS Platform (Ingestion, Feature, Inference, Narrative, Routing, Dashboard)
- Navigate the AWS Management Console to locate key CDS Platform resources
- Explain data flow from Epic FHIR R4 / Mirth Connect HL7 v2.3 to clinical alert delivery
- Identify key integration points and their operational dependencies
- Understand the HIPAA compliance controls and their implementation

**Content Outline:**
1. Architecture walkthrough with live AWS console tour (45 min)
   - Kinesis Data Streams, MSK, Lambda functions
   - SageMaker endpoints and Feature Store
   - Amazon Bedrock (Claude) integration
   - Amazon HealthLake and data tiers
2. Data flow demonstration with synthetic trace in X-Ray (30 min)
3. HIPAA compliance controls overview (20 min)
   - KMS CMKs, CloudTrail, GuardDuty, Config
4. Q&A and resource handover overview (25 min)

**Materials Required:**
- Architecture diagram (as-built version)
- AWS console read-only access to CDS production account
- X-Ray service map screenshot with annotated latency budgets
- HIPAA control mapping document

---

### TRN-002: IaC and Infrastructure Operations (4 hours, Hands-On Lab)

This session trains MedCore cloud engineers on how to safely modify, re-deploy, and manage the CDS Platform infrastructure using Terraform/CDK and CodePipeline.

**Learning Objectives:**
- Navigate the CDS Platform IaC repository structure
- Execute Terraform plan and apply for safe infrastructure changes
- Understand the CodePipeline CI/CD deployment process and blue/green endpoint promotion
- Perform routine infrastructure scaling operations (Kinesis shard scaling, ECS task count adjustment)
- Understand SCP constraints and how to manage change requests for OU-level policy modifications

**Content Outline:**
1. IaC repository walkthrough (30 min)
2. Terraform plan and apply demonstration (45 min)
3. CodePipeline pipeline anatomy and stage gates (30 min)
4. Lab Exercise 1: Scale ECS task count in staging environment (30 min)
5. Lab Exercise 2: Update SageMaker endpoint auto-scaling policy (30 min)
6. Change control process for production IaC changes (30 min)
7. Troubleshooting common Terraform apply failures (45 min)

**Lab Exercises:**
- Exercise 1: Increase ECS Fargate minimum task count from 4 to 6 in staging; verify deployment via CodePipeline
- Exercise 2: Modify SageMaker endpoint auto-scaling target to 60% CPU; validate CloudWatch alarm update
- Exercise 3: Simulate a Terraform plan that would be blocked by SCP; confirm error message and remediation path

**Materials Required:**
- Staging environment access with IaC write permissions
- IaC module documentation (Terraform variable reference)
- CodePipeline deployment runbook
- SCP constraint reference document

---

### TRN-003: ML Pipeline Operations and Model Retraining (4 hours, Hands-On Lab)

This session prepares MedCore data engineering staff to manage the SageMaker ML pipeline, trigger model retraining, promote models through the registry, and monitor model performance.

**Learning Objectives:**
- Trigger an ad-hoc SageMaker Pipelines retraining run and monitor job progress
- Review model evaluation metrics in the SageMaker Model Registry
- Promote a model version from Pending to Approved status after reviewing AUROC
- Interpret SageMaker Model Monitor drift alerts and respond appropriately
- Understand the model rollback procedure using the Model Registry

**Content Outline:**
1. SageMaker Pipelines architecture for CDS Platform retraining (30 min)
2. Model Registry: version governance and approval workflow (30 min)
3. Lab Exercise 1: Review a weekly retraining pipeline run in SageMaker Studio (45 min)
4. Lab Exercise 2: Approve a model version in the staging registry (30 min)
5. SageMaker Model Monitor: drift alerts and threshold tuning (30 min)
6. Model rollback procedure walkthrough (30 min)
7. Bedrock prompt template versioning and SSM Parameter Store management (45 min)

**Lab Exercises:**
- Exercise 1: Start an ad-hoc sepsis model retraining job in the QA environment; monitor pipeline steps
- Exercise 2: Review model metrics for a sample model version; approve or reject based on AUROC threshold
- Exercise 3: Simulate a model drift alert in SageMaker Model Monitor; identify the metric causing the alert

**Materials Required:**
- SageMaker Studio access (staging environment)
- Model Registry documentation and AUROC threshold reference
- Model Monitor threshold configuration guide
- Bedrock prompt template management runbook

---

### TRN-004: Kinesis, MSK, and Ingestion Pipeline Troubleshooting (3 hours, ILT + Lab)

**Learning Objectives:**
- Diagnose Kinesis Data Streams shard throughput issues and dead-letter queue events
- Monitor MSK broker health and interpret Kafka consumer lag metrics
- Investigate Lambda FHIR connector and HL7 adapter errors using CloudWatch Logs
- Scale Kinesis shards using on-demand mode or manual reshard for throughput needs

**Content Outline:**
1. Kinesis Data Streams monitoring with CloudWatch (30 min)
2. MSK broker health monitoring and Kafka consumer lag (30 min)
3. Dead-letter queue investigation and replay procedure (30 min)
4. Lab Exercise 1: Investigate a simulated DLQ event in QA (45 min)
5. Kinesis resharding procedure and impact on downstream consumers (30 min)
6. Common Lambda ingestion errors and resolution playbook (15 min)

**Lab Exercises:**
- Exercise 1: Examine a dead-lettered malformed FHIR event; identify the schema validation failure; replay after correction
- Exercise 2: Review Kinesis CloudWatch metrics for shard hotspot; identify solution (partition key distribution)

---

### TRN-005: Incident Response and Runbook Execution (3 hours, Tabletop + Lab)

**Learning Objectives:**
- Execute all five operational runbooks (ingestion pipeline failure, SageMaker latency breach, Bedrock quota exhaustion, Direct Connect failover, model rollback)
- Navigate CloudWatch and Datadog dashboards to diagnose active incidents
- Follow the PagerDuty escalation path and document incidents correctly
- Perform the route 53 DNS failover procedure to us-west-2 DR region

**Content Outline:**
1. Incident response process overview and PagerDuty integration (20 min)
2. Tabletop Exercise A: SageMaker endpoint P95 latency breach (45 min)
3. Tabletop Exercise B: Direct Connect failover to VPN (45 min)
4. Lab Exercise: Execute model rollback runbook in staging (30 min)
5. DR failover runbook walkthrough (simulate us-east-1 outage in staging) (40 min)

---

## End User Training

### TRN-006: Clinical Dashboard Navigation for End Users (1.5 hours, VILT)

This session introduces nursing staff, hospitalists, and administrators to the CDS Platform clinical dashboard, covering login, navigation, and core daily workflows.

**Learning Objectives:**
- Log in to the clinical dashboard via MedCore SSO (Azure AD)
- Navigate the patient risk score view and identify active alerts
- Understand the risk score display (0–100 scale) and colour-coded severity indicators
- Access help documentation and submit a support request

**Content Outline:**
1. Login process and MedCore SSO walkthrough (15 min)
   - Azure AD authentication via existing MedCore credentials
   - Dashboard loading and initial patient panel view
2. Dashboard navigation (30 min)
   - Patient list view and risk score indicators
   - Alert notification panel
   - Navigation between patient context and alert detail
3. Mobile-responsive bedside view (15 min)
   - Tablet access for bedside use
   - Simplified risk score display
4. Practice exercise — guided navigation (20 min)
5. Support resources and feedback submission (10 min)

**Materials Required:**
- UAT staging environment access (de-identified PHI)
- Quick reference card: CDS Dashboard Navigation (1 page, laminated for bedside use)
- FAQ document (top 20 questions from UAT sessions)
- Recording link for asynchronous review

---

### TRN-007: Understanding AI Risk Scores and SHAP Explanations (2 hours, VILT + Lab)

**Learning Objectives:**
- Interpret the sepsis, readmission, and rapid-response risk scores in clinical context
- Understand SHAP feature contribution factors displayed in the dashboard explanation panel
- Read and act on a Bedrock-generated plain-language clinical narrative
- Distinguish between a high-confidence and low-confidence risk score (feature completeness flag)

**Content Outline:**
1. How the AI risk models work — non-technical overview (20 min)
   - What data the model uses (vitals, labs, medications, EHR events)
   - How risk scores are calculated and what the 0–100 scale means
   - Limitations: what the model does not know
2. Reading the SHAP explanation panel (40 min)
   - Top contributing factors for the current alert
   - Understanding direction (increasing vs. decreasing risk contribution)
   - Lab exercise: review 5 synthetic patient SHAP panels and discuss
3. Reading the Bedrock clinical narrative (20 min)
   - What the plain-language summary contains
   - How to use the narrative to inform clinical decision-making
4. Low-confidence alerts and when to trust the score (20 min)
5. Q&A with Clinical Informatics Lead (20 min)

**Lab Exercises:**
- Exercise 1: Review 5 synthetic high-risk sepsis patient profiles in staging; identify the primary SHAP contributing factor in each
- Exercise 2: Compare two alerts — one with high feature completeness vs. one with low-confidence flag; discuss clinical interpretation

---

### TRN-008: Alert Management and Escalation Workflows (1.5 hours, VILT + Scenarios)

**Learning Objectives:**
- Acknowledge and dismiss alerts using the correct workflow
- Escalate an alert to a physician or charge nurse using the dashboard escalation feature
- Understand alert suppression windows (how duplicate alerts are managed)
- Document alert response for audit and feedback purposes

**Content Outline:**
1. Alert lifecycle: delivery → acknowledgment → action → documentation (20 min)
2. Scenario walkthroughs using staging environment (50 min)
   - Scenario A: Sepsis risk alert → acknowledge → escalate to physician
   - Scenario B: False-positive alert → dismiss with reason code
   - Scenario C: Rapid-response alert → direct response workflow
3. Alert escalation to Epic CDS Hooks workflow (15 min)
4. Feedback submission and false-positive reporting (5 min)

**Lab Exercises:**
- Complete all three scenario walkthroughs using staging environment access

---

### TRN-009: Administrator Console and Reporting (2 hours, Hands-On Lab)

**Learning Objectives:**
- Configure alert threshold settings for the facility (with Clinical Informatics Lead approval)
- Generate facility-level QuickSight reports on alert volume, false-positive rates, and staff adoption
- Manage user access requests and role escalations (coordinate with MedCore IT Help Desk)
- Review audit log summaries from the administrator dashboard view

**Content Outline:**
1. Administrator dashboard overview and capabilities (20 min)
2. Alert threshold configuration (30 min)
   - Lab Exercise: Adjust sepsis risk threshold in staging; observe downstream alert volume change
3. QuickSight reporting for administrators (30 min)
   - Lab Exercise: Generate a 7-day facility alert summary report
4. User access management (20 min)
5. Audit log summary view and escalation to CISO (20 min)

**Materials Required:**
- Staging environment with administrator role access
- QuickSight dashboard user guide
- Alert threshold change request procedure (requires Clinical Informatics Lead approval)

---

## Train-the-Trainer Program

### TRN-010: Train-the-Trainer Facilitation Workshop (8 hours total, 2-day facilitated workshop)

This workshop is delivered by Amatra to the 18 Clinical Champions nominated by MedCore's CMO and Nursing Directors (one champion per facility). Champions must complete TRN-006 through TRN-009 before attending.

**Learning Objectives:**
- Deliver all four end-user training modules (TRN-006 through TRN-009) effectively to local facility staff
- Facilitate hands-on lab exercises in the staging environment
- Answer the 30 most common clinical questions about the CDS Platform (FAQ book)
- Assess learner competency using the provided assessment rubric
- Report training completion metrics to MedCore CMO and CIO via the adoption tracking QuickSight dashboard

**Content Outline — Day 1 (4 hours):**
1. Train-the-Trainer methodology and adult learning principles (60 min)
2. Full run-through of TRN-006 and TRN-007 from the facilitator perspective (90 min)
3. Practice delivery: Champions present a 15-minute segment to the group (90 min)

**Content Outline — Day 2 (4 hours):**
1. Full run-through of TRN-008 and TRN-009 from the facilitator perspective (90 min)
2. Scenario facilitation practice: handling edge case clinical questions (60 min)
3. Competency assessment approach and adoption tracking in QuickSight (30 min)
4. Logistics planning: facility-specific training schedule coordination (60 min)

**Materials Provided to Each Clinical Champion:**
- Facilitator guide for TRN-006 through TRN-009 (includes presenter notes, timing, and common Q&A)
- Participant workbooks (50 copies per facility for initial rollout)
- Laminated quick reference cards (one per clinical role type)
- Competency assessment rubric (task completion checklist for bedside observation)
- FAQ book (top 50 questions with answers, clinically reviewed by CMO representative)
- Link to recorded Amatra VILT sessions for asynchronous reference

---

## Training Materials

### Documentation Provided

All training documentation is delivered to MedCore at Week 44 alongside the as-built documentation package.

- Administrator Guide (PDF, 60 pages) — system configuration, user management, threshold administration
- End User Guide (PDF, 35 pages) — dashboard navigation, risk score interpretation, alert workflows
- Quick Reference Cards (per role: Nurse, Physician, Administrator, IT Operations) — one-page laminated A4
- Video recordings of all VILT sessions (TRN-006, TRN-007, TRN-008) — uploaded to MedCore SharePoint
- Lab exercise workbooks (TRN-002, TRN-003, TRN-004, TRN-005, TRN-009) — hands-on procedure guides
- Train-the-Trainer facilitator guide and participant workbooks (TRN-010)
- Competency assessment rubrics (per role)

### Training Environment

The training sandbox environment is provisioned specifically for training activities; it is separate from Dev, QA, Staging, and Production.

- Sandbox URL: `https://training.[alb-dashboard-dns]` (separate ECS Fargate task set in staging)
- Sample de-identified data loaded (50 synthetic patients representing diverse clinical scenarios)
- Environment reset to clean state every Sunday 03:00 ET (automated Lambda reset job)
- Access provisioned 3 weeks before each facility's go-live for Clinical Champion pre-training
- Access expires 4 weeks after facility go-live (sufficient for new staff onboarding period)

## Training Effectiveness

### Assessment Approach

- **Knowledge Checks:** 10-question multiple-choice quiz at end of each VILT module (70% pass required to receive completion certificate)
- **Practical Assessment:** Clinical Champions observe each trainee completing 3 assigned tasks in the staging environment (alert acknowledgement, SHAP interpretation, and escalation workflow); pass = all 3 tasks completed correctly
- **Post-Training Survey:** 5-question satisfaction survey after each session; results reported to CMO/CIO in monthly training summary
- **Adoption Tracking:** Active dashboard logins per facility per week tracked in QuickSight; adoption target ≥ 75% per facility within 90 days of go-live

### Success Metrics

| Metric | Target |
|--------|--------|
| Training Completion Rate | ≥ 95% of assigned users per facility before go-live |
| Knowledge Check Pass Rate | ≥ 85% of participants pass on first attempt |
| Post-Training Satisfaction Score | ≥ 4.0/5.0 average across all sessions |
| Clinical Staff Adoption Rate | ≥ 75% per facility within 90 days (active dashboard logins) |
| Train-the-Trainer Coverage | 100% of 18 facilities have a trained Clinical Champion before Phase 3 rollout |
| Time to Competency | Clinical staff pass practical assessment within 1 week of training completion |

---

# Appendices

## Appendix A: Environment Details

The following tables record the key configuration parameters for each environment. Values in brackets `[...]` are provisioned at deployment time and recorded in the Terraform state outputs file for that environment.

### Production Environment

| Component | Value |
|-----------|-------|
| AWS Account ID | `[aws-account-id]` |
| Primary Region | `us-east-1` |
| DR Region | `us-west-2` |
| VPC CIDR (Primary) | `10.10.0.0/16` |
| VPC CIDR (DR) | `10.11.0.0/16` |
| Kinesis Stream Name | `medcore-cds-prod-events` |
| HealthLake Datastore ID | `[healthlake-datastore-id]` |
| Aurora Cluster Endpoint | `[medcore-cds-prod-aurora-cluster.cluster-xxx.us-east-1.rds.amazonaws.com]` |
| ElastiCache Redis Endpoint | `[medcore-cds-prod-redis.xxx.cache.amazonaws.com]` |
| Cognito User Pool ID | `[cognito-user-pool-id]` |
| CloudTrail Trail ARN | `[cloudtrail-trail-arn]` |
| Access Method | Cognito SSO (Azure AD federation); Amatra break-glass via CIO-approved IAM role |

### Staging Environment

| Component | Value |
|-----------|-------|
| AWS Account ID | `[aws-staging-account-id]` |
| Region | `us-east-1` |
| VPC CIDR | `10.20.0.0/16` (staging mirrors production; reduced instance sizing) |
| Data | De-identified PHI subset; volume representative of production load |
| Access | Amatra delivery team + MedCore Clinical Informatics Lead + CISO |

### QA Environment

| Component | Value |
|-----------|-------|
| AWS Account ID | `[aws-qa-account-id]` |
| Region | `us-east-1` |
| VPC CIDR | `10.20.0.0/16` |
| Data | De-identified synthetic PHI (HealthLake FHIR de-identification) |
| Access | Amatra QA + Security Engineers + MedCore EHR Integration Lead (read-only) |

### Development Environment

| Component | Value |
|-----------|-------|
| AWS Account ID | `[aws-dev-account-id]` |
| Region | `us-east-1` |
| VPC CIDR | `10.20.0.0/16` |
| Data | Synthetic/generated test data only; zero real PHI permitted |
| Access | Amatra engineers (full access); no MedCore PHI access |

## Appendix B: Configuration Reference

The full configuration parameter reference is maintained in `delivery/configuration.csv`. Key production parameter values are summarised below for operational reference.

| Parameter | Production Value | Notes |
|-----------|-----------------|-------|
| `ml.kinesis.shard_count` | `10` | 30% headroom at 18-hospital peak |
| `ml.model.sepsis.auroc_threshold` | `0.85` | Hard go-live gate; Clinical Informatics Lead sign-off required |
| `ml.model.sepsis.risk_score_alert_threshold` | `0.7` | Configurable by Clinical Informatics Lead via SSM |
| `ml.bedrock.model_id` | `anthropic.claude-3-sonnet-20240229-v1:0` | Claude 3 Sonnet for production narrative quality |
| `ml.inference.latency_target_ms` | `3000` | P95; auto-rollback triggers if exceeded within 30 min of deployment |
| `cache.elasticache.ttl_patient_context_seconds` | `14400` | 4-hour clinical review window |
| `operations.hypercare_duration_weeks` | `8` | Post-GA hypercare; Critical SLA: 1-hour response |
| `security.audit_log_retention_years` | `7` | HIPAA WORM retention; S3 Object Lock Compliance mode |
| `database.aurora.backup_retention_days` | `35` | Maximum Aurora PITR window |
| `operations.dr.rto_hours` | `4` | Regional failover RTO; tested annually |
| `operations.dr.rpo_minutes` | `15` | Regional failover RPO; based on HealthLake export + Aurora replication lag |

## Appendix C: Deployment Scripts

The following scripts are stored in `infrastructure/scripts/` in the MedCore IaC repository.

### deploy.sh — Full Environment Deployment

```bash
#!/bin/bash
# deploy.sh — Full CDS Platform deployment for a target environment
# Usage: ./deploy.sh <environment> <phase>
# Example: ./deploy.sh prod phase1

set -euo pipefail

ENVIRONMENT=${1:-staging}
PHASE=${2:-phase1}

echo "======================================================"
echo "MedCore CDS Platform Deployment"
echo "Environment: ${ENVIRONMENT} | Phase: ${PHASE}"
echo "======================================================"

# Pre-deployment checks
./scripts/pre-deploy-check.sh "${ENVIRONMENT}"

# Deploy infrastructure layers in order
echo "[1/4] Deploying Networking layer..."
terraform -chdir="infrastructure/environments/${ENVIRONMENT}" apply \
  -target=module.networking \
  -var-file="${ENVIRONMENT}.tfvars" \
  -auto-approve

echo "[2/4] Deploying Security layer..."
terraform -chdir="infrastructure/environments/${ENVIRONMENT}" apply \
  -target=module.security \
  -var-file="${ENVIRONMENT}.tfvars" \
  -auto-approve

echo "[3/4] Deploying Compute layer..."
terraform -chdir="infrastructure/environments/${ENVIRONMENT}" apply \
  -target=module.compute \
  -var-file="${ENVIRONMENT}.tfvars" \
  -auto-approve

echo "[4/4] Deploying Monitoring layer..."
terraform -chdir="infrastructure/environments/${ENVIRONMENT}" apply \
  -target=module.monitoring \
  -var-file="${ENVIRONMENT}.tfvars" \
  -auto-approve

# Post-deployment validation
./scripts/post-deploy-validate.sh "${ENVIRONMENT}"

echo "======================================================"
echo "Deployment complete. Environment: ${ENVIRONMENT}"
echo "Review CloudWatch dashboards: medcore-cds-${ENVIRONMENT}-*"
echo "======================================================"
```

### rollback.sh — Production Rollback Script

```bash
#!/bin/bash
# rollback.sh — Emergency rollback for CDS Platform production
# Usage: ./rollback.sh <component>
# Components: sagemaker-sepsis | ecs-dashboard | ecs-api | full
# Example: ./rollback.sh sagemaker-sepsis

set -euo pipefail

COMPONENT=${1:-"sagemaker-sepsis"}
ENVIRONMENT="prod"

echo "======================================================"
echo "CDS Platform ROLLBACK INITIATED"
echo "Component: ${COMPONENT} | Environment: ${ENVIRONMENT}"
echo "Time: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "======================================================"

# Notify stakeholders immediately
aws sns publish \
  --topic-arn "${ALARM_SNS_TOPIC_ARN}" \
  --message "ROLLBACK INITIATED for ${COMPONENT} at $(date -u '+%Y-%m-%dT%H:%M:%SZ'). Investigation in progress." \
  --subject "CDS Platform Rollback - ${COMPONENT}"

case "${COMPONENT}" in
  "sagemaker-sepsis")
    echo "Rolling back SageMaker sepsis endpoint to previous approved model version..."
    aws codepipeline start-pipeline-execution \
      --name medcore-cds-prod-sepsis-endpoint-deploy \
      --variables "name=ROLLBACK,value=true"
    echo "Rollback pipeline triggered. Target: ≤ 15 minutes."
    ;;
  "ecs-dashboard")
    PREVIOUS_REVISION=$(aws ecs describe-services \
      --cluster medcore-cds-prod-cluster \
      --services medcore-cds-prod-dashboard-svc \
      --query 'services[0].taskDefinition' \
      --output text | sed 's/.*://' | awk '{print $1-1}')
    aws ecs update-service \
      --cluster medcore-cds-prod-cluster \
      --service medcore-cds-prod-dashboard-svc \
      --task-definition "medcore-cds-prod-dashboard:${PREVIOUS_REVISION}" \
      --force-new-deployment
    echo "ECS dashboard rollback initiated to revision ${PREVIOUS_REVISION}."
    ;;
  "full")
    echo "FULL ROLLBACK: Switching alert delivery to Epic rule-based system..."
    aws codepipeline start-pipeline-execution \
      --name medcore-cds-prod-alert-routing-config \
      --variables "name=ALERT_DELIVERY_MODE,value=EPIC_RULESET"
    echo "Full rollback complete. Epic rule-based alerts now active."
    ;;
  *)
    echo "Unknown component: ${COMPONENT}. Valid options: sagemaker-sepsis | ecs-dashboard | ecs-api | full"
    exit 1
    ;;
esac

echo "======================================================"
echo "Rollback initiated. Monitor CloudWatch: medcore-cds-prod-*"
echo "Page on-call if not resolved within SLA."
echo "======================================================"
```

## Appendix D: Troubleshooting Guide

The following covers the five most common operational issues encountered during the engagement. Full runbooks for all failure scenarios are delivered as separate operational runbook documents.

### Issue 1: SageMaker Endpoint P95 Latency Breach (> 3,000 ms)

**Symptoms:**
- CloudWatch alarm `medcore-cds-prod-latency-alarm` in ALARM state
- PagerDuty Critical incident created
- End-to-end inference latency > 3 seconds in X-Ray traces

**Cause:** Endpoint CPU saturation; auto-scaling response lag; or recently deployed model version with higher inference complexity.

**Resolution:**

```bash
# Check endpoint CPU utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/SageMaker \
  --metric-name CPUUtilization \
  --dimensions Name=EndpointName,Value=medcore-cds-prod-sepsis-ep \
               Name=VariantName,Value=AllTraffic \
  --start-time $(date -d '30 minutes ago' -u +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 60 \
  --statistics Average

# If CPU > 70%: auto-scaling should be responding; if not, manually scale
aws application-autoscaling register-scalable-target \
  --service-namespace sagemaker \
  --resource-id "endpoint/medcore-cds-prod-sepsis-ep/variant/AllTraffic" \
  --scalable-dimension sagemaker:variant:DesiredInstanceCount \
  --min-capacity 2 --max-capacity 6

# If latency persists after scaling: trigger rollback to previous model version
./scripts/rollback.sh sagemaker-sepsis
```

**Prevention:** Monitor `SageMakerVariantInvocationsPerInstance` metric; ensure auto-scaling policy activates at 70% CPU.

---

### Issue 2: Kinesis Dead-Letter Queue Filling (DLQ Depth > 0)

**Symptoms:**
- CloudWatch alarm `medcore-cds-prod-dlq-alarm` in ALARM state
- DLQ message count increasing in CloudWatch
- FHIR events not reaching SageMaker Feature Store

**Cause:** Malformed FHIR R4 message (schema validation failure); missing required LOINC code; Epic FHIR API returning unexpected response format.

**Resolution:**

```bash
# Examine dead-lettered messages
aws sqs receive-message \
  --queue-url "https://sqs.us-east-1.amazonaws.com/[account-id]/medcore-cds-prod-fhir-dlq" \
  --max-number-of-messages 5 \
  --query 'Messages[].Body'

# Identify the failing FHIR resource type from message body
# Fix schema validation rule if Epic API changed output format

# After fix is deployed, replay messages from DLQ to main queue
aws lambda invoke \
  --function-name medcore-cds-prod-dlq-replay \
  --payload '{"dlq_url":"[dlq-url]","replay_count":100}' \
  response.json
```

**Prevention:** Monitor Epic FHIR API changelog; update Lambda connector schema validation when Epic releases new FHIR API versions.

---

### Issue 3: Aurora PostgreSQL Replica Lag Elevated (> 5 seconds)

**Symptoms:**
- CloudWatch alarm `medcore-cds-prod-aurora-replica-lag` in ALARM state
- Dashboard API slow to return alert history

**Cause:** High write volume during peak alert period; network bandwidth constraint between primary and replica.

**Resolution:**

```bash
# Check replication lag
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name AuroraReplicaLag \
  --dimensions Name=DBClusterIdentifier,Value=medcore-cds-prod-aurora-cluster \
  --start-time $(date -d '30 minutes ago' -u +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 60 --statistics Average

# If sustained > 10 seconds for > 30 minutes, consider upgrading instance class
aws rds modify-db-instance \
  --db-instance-identifier medcore-cds-prod-aurora-instance-2 \
  --db-instance-class db.r6g.xlarge \
  --apply-immediately
```

---

### Issue 4: Bedrock Quota Exhaustion (ThrottlingException Rate > 10/minute)

**Symptoms:**
- CloudWatch alarm `medcore-cds-prod-bedrock-quota-alarm` in ALARM state
- Alerts delivered without Bedrock narrative (fallback mode active)

**Resolution:**

```bash
# Submit AWS quota increase request immediately
aws service-quotas request-service-quota-increase \
  --service-code bedrock \
  --quota-code L-XXXXXXXX \
  --desired-value 100

# Confirm fallback mode is active (alerts still delivered without narrative)
aws logs filter-log-events \
  --log-group-name /medcore-cds/prod/inference-orchestrator \
  --filter-pattern "BEDROCK_FALLBACK" \
  --start-time $(date -d '30 minutes ago' +%s000)
# Expected: Log entries showing BEDROCK_FALLBACK=true and alert delivered successfully
```

---

### Issue 5: Direct Connect Connectivity Loss to Mirth Connect

**Symptoms:**
- HL7 v2.3 Lambda adapter Lambda error rate spiking
- Mirth Connect events not reaching Kinesis
- CloudWatch alarm for HL7 adapter Lambda errors

**Resolution:**

```bash
# Confirm Direct Connect status
aws directconnect describe-connections \
  --query 'connections[].{Name:connectionName,State:connectionState,Bandwidth:bandwidth}'

# If Direct Connect DOWN: VPN should automatically failover (BGP route propagation)
# Confirm VPN is carrying HL7 traffic
aws ec2 describe-vpn-connections \
  --query 'VpnConnections[].{State:State,Tunnels:VgwTelemetry[].Status}'
# Expected: One or both tunnels show Status=UP

# If VPN also down: contact MedCore IT for on-premises network investigation
# Escalate to PagerDuty Critical immediately — patient alert delivery is impaired
```

## Appendix E: Contact Information

### Project Team

| Role | Name | Email | Availability |
|------|------|-------|--------------|
| Engagement Director / PM | Amatra PM | engagement@amatra.io | Business hours; weekday on-call during hypercare |
| Lead Solutions Architect | Amatra Lead Architect | engagement@amatra.io | Business hours; escalation for complex technical issues |
| Senior Support Engineer (Hypercare) | Amatra Support Engineer | engagement@amatra.io | Extended hours during hypercare (07:00–22:00 ET); on-call paging for Critical |
| ML/AI Lead | Amatra ML Engineer | engagement@amatra.io | Business hours |

### MedCore Stakeholder Contacts

| Role | Contact | Phone |
|------|---------|-------|
| Chief Information Officer | MedCore CIO | +1 (615) 555-0100 |
| Chief Medical Officer | MedCore CMO | +1 (615) 555-0100 |
| Clinical Informatics Lead | [Name TBC] | [Number TBC] |
| CISO / Privacy Officer | [Name TBC] | [Number TBC] |
| EHR Integration Lead | [Name TBC] | [Number TBC] |
| IT Operations On-Call | [Rotation TBC] | PagerDuty rotation |

### Vendor Support Contacts

| Vendor | Support Portal | SLA |
|--------|----------------|-----|
| AWS | https://console.aws.amazon.com/support | Business Support: < 1-hour Critical response (24x7) |
| Datadog | https://help.datadoghq.com | Per Datadog Business plan SLA |
| Snyk | https://support.snyk.io | Per Snyk Business plan SLA |
| Epic | MedCore EHR Integration Lead escalates via Epic portal | Per MedCore Epic MSA |
| PagerDuty | https://support.pagerduty.com | Per PagerDuty plan SLA |

### Escalation Path (Hypercare Period)

| Level | Contact | Trigger | Availability |
|-------|---------|---------|--------------|
| Primary | Amatra Senior Support Engineer | Any Critical/High incident during hypercare | 07:00–22:00 ET Mon–Fri; on-call paging outside hours |
| Secondary | Amatra Lead Solutions Architect | Unresolved Critical after 2 hours; complex technical root cause | Same as Primary |
| Emergency | Amatra Engagement Director | Patient safety event; media/regulatory escalation | 24x7 via PagerDuty |
| AWS | AWS Business Support | AWS service outage contributing to platform unavailability | 24x7; < 1-hour Critical response per Business Support SLA |
