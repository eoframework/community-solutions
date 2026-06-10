---
document_title: Statement of Work
technology_provider: aws
project_name: Amatra Intelligent Solution Builder
client_name: Amatra
client_contact: Chief Technology Officer | cto@amatra.com | Austin, TX
consulting_company: EO Framework Consulting
consultant_contact: Lead Solutions Architect | solutions@eoframework.com
opportunity_no: OPP-2026-001
document_date: July 1, 2026
version: "1.0"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Statement of Work (SOW) defines the scope, deliverables, roles, commercial terms, and technical approach for designing and delivering the **Amatra Intelligent Solution Builder** — a cloud-native, serverless platform hosted on Amazon Web Services (AWS) that transforms a short client brief into a complete, consulting-grade engagement package automatically. EO Framework Consulting will partner with Amatra to architect, build, and deploy this platform across three structured phases, achieving General Availability before Amatra's flagship client renewal deadline of 31 January 2027.

Today Amatra's pre-sales and delivery teams build every client engagement artifact by hand — a process that consumes approximately three weeks per engagement, produces inconsistent output quality, and directly caps the number of proposals the company can pursue each quarter. This engagement eliminates that constraint by deploying an AI-powered generation pipeline built on Amazon Bedrock (Claude models), AWS Lambda, Amazon API Gateway, Amazon DynamoDB, Amazon S3, and Amazon Cognito. The platform will automate seven artifact types spanning both pre-sales and delivery workstreams, enforce per-user and global usage governance, and satisfy SOC 2 Type II and GDPR-aligned data-handling requirements.

**Project Duration:** 12 months (Phase 1 MVP by 30 September 2026 · Phase 2 by 15 December 2026 · GA in Q1 2027)

**Key Outcomes:**
- Serverless AWS platform deployed in us-west-2 with 99.9% availability SLA
- Amazon Bedrock (Claude) generation pipeline automating 7 consulting artifact types
- Okta-to-Cognito identity migration with admin group governance controls
- SOC 2 Type II compliance controls designed and implemented from Day 1
- Legacy Word/Excel/PowerPoint artifact templates carried over into automated pipelines
- General Availability rollout to all ~120 internal users before 31 January 2027

**Expected Benefits:**
- Artifact turnaround reduced from ~3 weeks to under 2 business days (>90% improvement)
- Proposal throughput tripled — from ~8 to ~24 active engagements per quarter
- Consulting hours per engagement reduced by 40% through intelligent automation
- ≥90% of generated artifacts pass internal QA on first review, eliminating rework cycles
- Platform availability of 99.9% supports mission-critical pre-sales and delivery operations
- Year 1 total investment of approximately $378,178 (net of AWS partner credits) within the approved $300K–$450K budget envelope

---

# Background & Objectives

Amatra is a B2B SaaS company in the cloud consulting and professional-services-automation space, headquartered in Austin, Texas, with approximately 120 employees and ~$18M in annual revenue. It serves enterprise clients across North America who purchase AWS solution-design and delivery engagements. The decision to invest in an AI-powered platform reflects Amatra's strategic imperative to scale proposal velocity without proportionally scaling headcount.

## Current State

Amatra's pre-sales and delivery teams currently build every client engagement artifact manually using Google Workspace documents and a legacy internal monolith running on a single EC2 instance. Key challenges include:

- **Throughput Constraint:** The manual end-to-end artifact cycle takes approximately three weeks per engagement, limiting the company to roughly eight active proposals per quarter — well below market demand.
- **Quality Inconsistency:** Individual consultants apply personal judgment to artifact structure, depth, and terminology, resulting in variable output quality and unpredictable QA pass rates.
- **Identity & Governance Debt:** User identity is managed in Okta without centralised usage governance, per-user limits, or admin controls aligned to AWS-native security patterns.
- **Legacy Template Fragmentation:** Artifact templates exist as Word, Excel, and PowerPoint files in Google Workspace, with no automated pipeline to translate these formats into structured, AI-generated output.
- **Async Reliability Gap:** Long-running generation jobs (30–60 minutes) cannot be reliably handled by the current synchronous tooling, creating risk of dropped work and timeout failures.
- **Compliance Readiness:** The current environment lacks SOC 2 Type II controls, GDPR-aligned data-handling processes, and US data-residency enforcement — requirements imposed by enterprise clients.

## Business Objectives

The following strategic objectives drive this engagement. Each is directly traceable to a measurable outcome that the Amatra Intelligent Solution Builder is designed to deliver, ensuring the platform investment is tightly coupled to business value rather than purely technical capability.

- **Automate Artifact Generation:** Deploy an AI-powered platform that converts a short client brief into a complete, consulting-grade engagement package with no manual authoring required.
- **Accelerate Proposal Velocity:** Reduce artifact turnaround from approximately three weeks to under two business days, enabling the sales team to respond to RFPs and inbound leads at market speed.
- **Triple Proposal Throughput:** Scale from ~8 to ~24 active engagements per quarter without a proportional increase in consulting headcount.
- **Modernise Identity & Governance:** Migrate from Okta to Amazon Cognito, establish an admin group for per-user and global usage-limit enforcement, and align identity posture to AWS security best practices.
- **Achieve and Maintain Compliance:** Implement SOC 2 Type II controls, GDPR-aligned data flows, and US data residency from the outset to support enterprise client contractual requirements.
- **Protect the Flagship Renewal:** Deliver General Availability by Q1 2027 — with a hard backstop of 31 January 2027 — to demonstrate platform readiness to Amatra's most strategically important client.

## Success Metrics

The following measurable criteria define what "done" looks like for this engagement. Each metric is tied to a specific business objective and will be tracked from Phase 1 go-live through General Availability, with progress reported to the CTO at every phase gate.

- Artifact turnaround time: **≤2 business days** from brief submission to complete package delivery
- Quarterly proposal throughput: **≥24 active engagements** per quarter within 90 days of GA
- Consulting hours per engagement: **≤60% of current baseline** (≥40% reduction)
- QA first-pass acceptance rate: **≥90%** of generated artifacts approved without rework
- Platform availability: **99.9% uptime** measured monthly in production (us-west-2)
- Identity migration: **100% of Okta user records** migrated to Cognito with zero authentication outages
- SOC 2 Type II: **Audit-ready controls** implemented and evidenced prior to General Availability
- GA deadline: Platform live and all ~120 users onboarded **before 31 January 2027**

---

# Scope of Work

This engagement delivers the end-to-end design, build, and rollout of the Amatra Intelligent Solution Builder platform on AWS. It encompasses infrastructure provisioning, AI/ML integration, identity migration, legacy template pipeline, compliance controls, and user enablement across three phased milestones. The following parameters quantify the engagement boundaries:

## In Scope

The following services and deliverables are included in this SOW:

- Greenfield serverless AWS platform design and deployment in us-west-2 (Lambda, API Gateway, DynamoDB, S3, Cognito, SQS, CloudWatch)
- Amazon Bedrock (Claude 3 Sonnet/Haiku) integration for AI artifact generation across all seven artifact types
- Durable asynchronous job orchestration (AWS Step Functions + SQS) supporting 30–60 minute generation pipelines
- Okta-to-Amazon Cognito identity migration, including admin group governance and per-user/global usage limit enforcement
- Legacy artifact template migration: Word, Excel, and PowerPoint templates ingested and integrated into the automated generation pipeline
- SOC 2 Type II controls design and implementation, including CloudTrail audit logging, KMS encryption, WAF, GuardDuty, and Security Hub
- GDPR-aligned data handling controls and US data residency enforcement (us-west-2)
- Multi-environment CI/CD pipeline (GitHub Actions) for Dev, Staging, and Production deployments
- Pre-sales artifact pipeline (Phase 1): discovery questionnaire, solution briefing, statement of work, infrastructure cost model
- Delivery artifact pipeline (Phase 2): detailed design, implementation guide, Terraform automation scripts
- CloudWatch dashboards and alarms for availability, async job reliability, and QA pass-rate monitoring
- Training and enablement for pre-sales consultants, delivery team, and platform administrators
- 8-week hypercare support for Phase 1 MVP and 4-week hypercare for Phase 2 delivery pipeline

### Scope Parameters

This engagement is sized at **Medium-Large** complexity based on the following parameters:

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | Artifact types automated | 7 (discovery questionnaire, briefing, SoW, infra costs, detailed design, impl guide, Terraform) |
| Solution Scope | AI/ML model | Amazon Bedrock Claude 3 Sonnet/Haiku; ~10M input + 5M output tokens/month |
| Solution Scope | Async job duration | Long async (30–60 min); durable orchestration via Step Functions + SQS |
| User Base | Internal platform users | ~120 employees (pre-sales, delivery, sales, admin) |
| User Base | Concurrent generation jobs | Up to 24 simultaneous pipelines (target: 24 engagements/quarter) |
| Integration | Identity migration | Okta → Amazon Cognito (all ~50 active users; zero-downtime migration) |
| Integration | Legacy templates | Word/Excel/PowerPoint from Google Workspace → automated pipeline |
| Technical Environment | AWS services in scope | 6 named services + SQS, CloudWatch, WAF, GuardDuty, CloudTrail, Secrets Manager |
| Technical Environment | Deployment environments | 3 (Dev, Staging, Production) in us-west-2 |
| Technical Environment | Existing infrastructure | Greenfield — legacy EC2 monolith to be retired |
| Data Volume | S3 artifact storage | ~100 GB active; ~200 GB/month egress |
| Data Volume | DynamoDB requests | ~2M reads + 500K writes/month (solution state + usage tracking) |
| Security & Compliance | Compliance frameworks | SOC 2 Type II + GDPR-aligned + US data residency (us-west-2) |
| Performance | Availability SLA | 99.9% platform availability |
| Performance | QA pass rate target | ≥90% of artifacts approved on first review |

*Note: Changes to these parameters — including additional artifact types, additional regions, or new compliance frameworks — may require scope adjustment and additional investment via the change-control process defined in Section 11.*

## Out of Scope

These items are explicitly excluded from this SOW unless added via formal change control:

- Multi-region deployment or disaster recovery to a secondary AWS region
- External client-facing portal (this engagement delivers an internal Amatra platform only)
- Custom model fine-tuning or training of foundation models beyond prompt engineering
- Application development beyond the artifact generation platform (e.g., CRM integration, billing automation)
- Physical data centre, co-location, or on-premises infrastructure of any kind
- Managed services or ongoing platform operations post-hypercare (see Section 9)
- Third-party software licensing beyond those itemised in the infrastructure-costs.csv
- Penetration testing by an external third party (internal security validation is in scope)
- HIPAA, PCI-DSS, FedRAMP, or other compliance frameworks beyond SOC 2 Type II and GDPR
- Data migration of historical engagement artifacts into the new platform

## Activities

### Phase 1 — Foundation & Pre-Sales MVP (Months 1–4 | Target: 30 September 2026)

Phase 1 establishes the complete AWS serverless foundation and delivers a production-ready pre-sales artifact generation pipeline. At the end of this phase, Amatra's pre-sales consultants will be able to submit a client brief and receive a fully generated pre-sales engagement package.

Key activities:
- Kickoff workshops with CTO, VP Engineering, Head of Solutions, and Security & Compliance Lead
- Current-state assessment: document manual workflows, inventory legacy templates, benchmark quality
- AWS landing zone setup: IAM roles/policies, CloudTrail, AWS Config, multi-environment structure
- Detailed architecture design, ADRs, data-flow diagrams, and sequence diagrams
- Bedrock integration layer: Claude prompt framework for Phase 1 artifact types, error handling, retries
- Async orchestration: Step Functions state machine for durable 30–60 minute generation jobs
- API Gateway + Lambda REST API layer (submit brief, poll status, retrieve artifacts, admin controls)
- DynamoDB state and usage layer: per-user and global monthly usage limit enforcement
- S3 artifact storage: bucket policies, presigned URL delivery, lifecycle management
- Cognito user pool configuration and Okta-to-Cognito user migration (zero-downtime)
- Pre-sales artifact pipeline: discovery questionnaire, solution briefing, SoW, infra cost model
- Security hardening: KMS encryption, WAF rules, GuardDuty, Security Hub, Secrets Manager
- CI/CD pipeline (GitHub Actions) for multi-environment deployments
- Phase 1 functional testing, integration testing, async reliability testing, security validation
- UAT with Head of Solutions and pre-sales consultants; CTO phase-gate approval
- Production deployment to us-west-2; pre-sales consultant training

**Deliverable:** Phase 1 MVP — pre-sales artifact generation platform live in production

### Phase 2 — Delivery Automation & Terraform Pipeline (Months 5–8 | Target: 15 December 2026)

Phase 2 extends the platform to cover the full delivery artifact pipeline, including Terraform automation scripts, and activates all remaining compliance controls required for SOC 2 Type II.

Key activities:
- Delivery artifact pipeline: detailed design documents, implementation guides, Terraform automation scripts
- Legacy template pipeline: Word/Excel/PowerPoint template ingestion and format-consistent output
- Per-user and global usage limit UI/admin controls activated and validated
- QA validation layer: automated quality-gate scoring against artifact standards
- CloudWatch dashboards: QA pass-rate tracking, async job success rates, SLA availability metrics
- Phase 2 functional testing, template pipeline validation, load and scalability testing
- Compliance validation: SOC 2 Type II controls evidence, GDPR data flow review, residency verification
- Delivery team UAT and sign-off; CTO phase-gate approval
- Production deployment Phase 2; delivery team enablement sessions

**Deliverable:** Full artifact pipeline (7 artifact types) in production with compliance controls active

### Phase 3 — GA Rollout & Optimisation (Months 9–12 | Target: Q1 2027, hard deadline 31 January 2027)

Phase 3 achieves General Availability for all ~120 internal users, tunes the platform based on production usage data, and formally closes the engagement.

Key activities:
- GA rollout plan and communications to all internal user cohorts
- Onboarding of all pre-sales, delivery, and sales team members
- Bedrock prompt optimisation based on Phase 1/2 production usage patterns
- Lambda cold-start and DynamoDB capacity planning optimisation
- Train-the-trainer session for Head of Solutions to onboard future hires
- Phase 1 8-week hypercare completion and Phase 2 4-week hypercare
- Optimisation recommendations document
- Final SOC 2 Type II evidence package and compliance sign-off
- Project retrospective, lessons learned, and closeout with CTO

**Deliverable:** GA platform live; all ~120 users onboarded; optimisation report delivered

---

# Deliverables & Timeline

This section defines the complete set of outputs Amatra will receive from this engagement, the type and due date of each, and who is accountable for acceptance. Clear acceptance ownership ensures that phase-gate approvals are unambiguous and that no deliverable is left without an assigned reviewer.

## Deliverables

The table below lists all 24 formal deliverables across the three phases. Deliverables marked as "System" represent deployed, operational AWS infrastructure or software; those marked "Document" or "Training" represent artefacts transferred to Amatra in written or recorded form.

<!-- TABLE_CONFIG: widths=[5, 42, 12, 18, 23] -->
| # | Deliverable | Type | Due | Acceptance By |
|---|-------------|------|-----|---------------|
| 1 | Discovery & Assessment Report | Document | Month 1, Week 4 | VP Engineering |
| 2 | Detailed Architecture Design & ADRs | Document | Month 2, Week 2 | CTO + VP Engineering |
| 3 | AWS Landing Zone & Environment Setup | System | Month 2, Week 2 | VP Engineering |
| 4 | CI/CD Pipeline (GitHub Actions, multi-env) | System | Month 2, Week 4 | VP Engineering |
| 5 | Okta-to-Cognito Identity Migration | System | Month 3, Week 2 | Security & Compliance Lead |
| 6 | Bedrock Integration Layer (Phase 1 artifacts) | System | Month 3, Week 4 | Head of Solutions |
| 7 | Async Job Orchestration (Step Functions + SQS) | System | Month 3, Week 4 | VP Engineering |
| 8 | Pre-Sales Artifact Pipeline (4 artifact types) | System | Month 4, Week 2 | Head of Solutions |
| 9 | Security Hardening & SOC 2 Controls (Phase 1) | System | Month 4, Week 2 | Security & Compliance Lead |
| 10 | Phase 1 Test Results Report & Sign-Off | Document | Month 4, Week 3 | CTO |
| 11 | Phase 1 Production Deployment (MVP Go-Live) | System | 30 Sep 2026 | CTO |
| 12 | Pre-Sales Consultant Training Materials | Document | Month 4, Week 4 | Head of Solutions |
| 13 | Legacy Template Pipeline (Word/Excel/PPT) | System | Month 6, Week 2 | Head of Solutions |
| 14 | Delivery Artifact Pipeline (3 additional artifact types) | System | Month 7, Week 2 | VP Engineering |
| 15 | QA Validation Layer & Pass-Rate Dashboard | System | Month 7, Week 4 | Head of Solutions |
| 16 | SOC 2 Type II Controls Evidence Package | Document | Month 8, Week 2 | Security & Compliance Lead |
| 17 | Phase 2 Test Results Report & Sign-Off | Document | Month 8, Week 3 | CTO |
| 18 | Phase 2 Production Deployment | System | 15 Dec 2026 | CTO |
| 19 | Delivery Team & Administrator Training | Training | Month 8, Week 4 | VP Engineering |
| 20 | CloudWatch Monitoring & SLA Dashboards | System | Month 8, Week 4 | VP Engineering |
| 21 | Optimisation Recommendations Report | Document | Month 11, Week 2 | CTO |
| 22 | Train-the-Trainer Session | Training | Month 11, Week 4 | Head of Solutions |
| 23 | Operations Runbooks & Configuration Docs | Document | Month 11, Week 4 | VP Engineering |
| 24 | Final Project Closeout Report | Document | Month 12 | CTO |

## Project Milestones

The milestones below mark the completion of major phases and critical decision points across the 12-month engagement. Each milestone is a formal gate requiring written CTO approval before the next phase of work and expenditure is authorised.

<!-- TABLE_CONFIG: widths=[22, 55, 23] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 — Kickoff Complete | CTO, VP Engineering, and Head of Solutions aligned on scope, success criteria, and governance model | Month 1, Week 1 |
| M2 — Architecture Approved | Detailed architecture design, ADRs, and data models approved by CTO and VP Engineering | Month 2, Week 2 |
| M3 — Infrastructure Foundation Live | AWS landing zone, Cognito migration, CI/CD pipeline, and async orchestration operational in Staging | Month 3, Week 4 |
| M4 — Phase 1 MVP Go-Live | Pre-sales artifact pipeline (4 types) live in production; pre-sales consultants generating artifacts | 30 Sep 2026 |
| M5 — Phase 1 Hypercare End | 8-week Phase 1 hypercare period complete; platform stable; usage metrics baselined | Month 6, Week 4 |
| M6 — Phase 2 Go-Live | Full 7-type artifact pipeline live; QA validation layer active; compliance controls evidenced | 15 Dec 2026 |
| M7 — Phase 2 Hypercare End | 4-week Phase 2 hypercare complete; delivery team using platform in production | Month 9, Week 2 |
| M8 — GA Rollout Complete | All ~120 internal users onboarded; prompts optimised; all training complete | Q1 2027 |
| M9 — Project Close | SOC 2 evidence package delivered, project retrospective complete, engagement formally closed | Jan 2027 |

---

# Roles & Responsibilities

This section defines who is accountable, responsible, consulted, and informed for each major work stream of the engagement. Clear role definition is critical given the project's complexity, multi-phase structure, and the number of internal stakeholder groups at Amatra.

## RACI Matrix

The table below assigns RACI designations across all major project task categories. Each row has been reviewed to carry exactly one **A** (Accountable) owner, ensuring no task is left without a single decision-making authority.

<!-- TABLE_CONFIG: widths=[28, 9, 10, 9, 8, 9, 9, 9, 9] -->
| Task / Deliverable | Vendor PM | Vendor Arch | Vendor Eng | Vendor QA | Client CTO | Client VP Eng | Head of Solutions | Sec & Compliance |
|--------------------|-----------|-------------|------------|-----------|------------|---------------|-------------------|------------------|
| Project Governance & Reporting | A | C | I | I | C | C | I | I |
| Discovery & Assessment | C | A | R | I | C | C | C | C |
| Architecture Design & ADRs | I | A | R | I | C | C | I | C |
| AWS Landing Zone & Environments | C | C | A/R | I | I | C | I | C |
| Bedrock / AI Integration | C | A | R | I | I | C | C | I |
| Async Job Orchestration | C | A | R | I | I | C | I | I |
| API Gateway & Lambda API | C | C | A/R | I | I | C | I | I |
| Okta → Cognito Migration | C | C | R | I | I | C | I | A |
| Legacy Template Pipeline | C | C | A/R | C | I | C | C | I |
| Security Hardening & SOC 2 Controls | I | C | R | C | I | C | I | A |
| CI/CD Pipeline | C | C | A/R | C | I | C | I | I |
| QA Validation Layer | C | C | R | A | I | C | C | I |
| Functional & Integration Testing | C | C | R | A | I | C | C | C |
| UAT — Pre-Sales Artifacts | C | I | I | C | I | I | A | I |
| UAT — Delivery Artifacts | C | I | I | C | I | A | C | I |
| Phase Gate Approvals | C | C | I | I | A | C | C | C |
| Production Deployments | A | C | R | C | I | C | I | C |
| Training Delivery | A | C | R | I | I | C | C | I |
| Hypercare Support | A | C | R | I | I | C | C | I |
| SOC 2 Evidence & Compliance Sign-Off | C | C | R | C | I | I | I | A |
| Optimisation & Project Closeout | A | R | C | I | C | C | I | I |

**Legend:** R = Responsible (does the work) | A = Accountable (owns the outcome) | C = Consulted (input required) | I = Informed (kept updated)

## Key Personnel

**Vendor Team (EO Framework Consulting):**
- **Project Manager:** End-to-end engagement coordination, stakeholder reporting to CTO and VP Engineering, risk and issue management, phase-gate scheduling
- **Lead Solutions Architect:** Technical governance across all phases, AWS serverless architecture design, Bedrock integration design, ADR authorship, quality review
- **ML/AI Engineer:** Amazon Bedrock Claude integration, prompt engineering framework for all 7 artifact types, token budget management, generation quality tuning
- **Senior Solutions Engineer:** Async orchestration (Step Functions), API layer, Okta migration, legacy template pipeline, artifact delivery workflows
- **Cloud/DevOps Engineer:** AWS landing zone, DynamoDB, S3, CI/CD pipeline, CloudWatch dashboards, Lambda performance
- **Security Engineer:** IAM least-privilege policies, KMS, WAF, GuardDuty, Security Hub, SOC 2 controls design and evidence collection
- **QA Engineer:** Test plan, functional and integration test execution, async reliability load testing, test results reporting
- **Technical Writer:** Architecture diagrams, runbooks, training materials, configuration documentation

**Client Team (Amatra):**
- **CTO (Executive Sponsor):** Budget authority, phase-gate approvals, go/no-go decisions, final SOW signatory
- **VP of Engineering (Delivery Owner):** Day-to-day engineering accountability, environment provisioning, AWS account access, technical decision escalation
- **Head of Solutions (Pre-Sales):** Artifact quality standards definition, UAT lead for pre-sales artifacts, Bedrock prompt quality validation, train-the-trainer recipient
- **Security & Compliance Lead:** SOC 2 Type II scoping, GDPR control review, Okta migration security oversight, compliance evidence sign-off
- **Pre-Sales Consultants:** UAT participants, primary day-to-day end users of the platform post-GA
- **Delivery Consulting Team:** UAT participants for Phase 2 delivery artifacts and Terraform outputs

---

# Architecture & Design

The Amatra Intelligent Solution Builder is a fully serverless, event-driven platform on AWS that ingests a structured client brief, orchestrates a multi-step AI generation pipeline via Amazon Bedrock, and produces a complete consulting engagement package. The architecture is designed for high availability (99.9% SLA), long-running async workloads (30–60 minute generation jobs), SOC 2 Type II compliance, and GDPR-aligned data handling — all within a single AWS region (us-west-2) to enforce US data residency.

The design philosophy prioritises operational simplicity and compliance-by-default: every component is serverless or managed, eliminating the need for EC2 fleet management; all data is encrypted at rest and in transit using AWS KMS; and every API call is logged via CloudTrail for audit purposes. The platform is deployed across three isolated environments — Dev, Staging, and Production — using a GitHub Actions CI/CD pipeline with automated quality gates between each promotion.

## Architecture Overview

The platform is composed of four logical layers: (1) the **API & Auth Layer**, which handles all inbound requests from Amatra's internal users via API Gateway and enforces identity through Amazon Cognito; (2) the **Orchestration Layer**, which manages long-running generation jobs via AWS Step Functions and SQS, ensuring reliability across 30–60 minute pipelines; (3) the **AI Generation Layer**, where Amazon Bedrock (Claude 3 Sonnet/Haiku) executes structured prompts against client brief inputs to produce artifact content; and (4) the **Data & Storage Layer**, where DynamoDB tracks solution state and usage limits and S3 stores all generated artifacts with lifecycle management and presigned URL delivery.

![Figure 1: Amatra Intelligent Solution Builder — Architecture Diagram](../../assets/diagrams/architecture-diagram.png)

**Figure 1: Amatra Intelligent Solution Builder Architecture** — End-to-end serverless AWS architecture showing the API, orchestration, AI generation, and data storage layers deployed in us-west-2 with CloudWatch observability and WAF security controls.

## Component Architecture

The platform comprises six named AWS service components and four supporting services, each with a discrete responsibility:

**Core Services:**
- **Amazon Bedrock (Claude 3 Sonnet/Haiku):** The AI generation engine. Receives structured prompts constructed from client brief inputs and artifact-specific templates; returns generated artifact content. Prompt engineering frameworks are maintained per artifact type (7 total), with token budgets calibrated to ~10M input + 5M output tokens/month.
- **AWS Lambda:** Serverless compute for the REST API handlers, async job orchestration workers, Bedrock invocation wrappers, and artifact post-processing functions. Functions are deployed with per-environment aliases and provisioned concurrency for latency-sensitive paths.
- **Amazon API Gateway (REST):** Single ingress point for all platform API traffic. Routes brief-submission, job-status-polling, artifact-retrieval, and admin-control endpoints to the appropriate Lambda handlers. Backed by AWS WAF for rate limiting and managed rule groups.
- **Amazon DynamoDB (On-Demand):** Two primary tables — `SolutionState` (tracks job status, artifact keys, generation metadata per engagement) and `UsageTracking` (enforces per-user and global monthly generation limits). On-demand capacity scales automatically with usage.
- **Amazon S3:** Primary artifact store. Generated artifacts (Markdown, CSV, DOCX, PPTX, PNG, Terraform) are stored under a structured key taxonomy (`{solution_id}/raw/{phase}/{artifact_type}`). Presigned URLs provide time-limited client access. Lifecycle rules archive artifacts older than 180 days to S3 Glacier.
- **Amazon Cognito:** User pool for all ~120 internal users. Replaces Okta as the identity provider. Admin group controls enforce governance policies. JWT token validation is handled natively by API Gateway's Cognito authorizer.

**Supporting Services:**
- **AWS Step Functions:** Durable state machine orchestrating multi-step generation workflows (brief parse → prompt assembly → Bedrock invocation → artifact post-processing → S3 write → status update). Retries, error handling, and wait states are built into the state machine, guaranteeing 30–60 minute jobs complete even under Lambda execution limits.
- **Amazon SQS:** Decouples the API layer from the Bedrock invocation layer. Dead-letter queues (DLQ) capture failed messages for investigation without data loss.
- **AWS Secrets Manager:** Manages all API keys, DynamoDB connection strings, and third-party integration credentials. Automatic rotation is enabled for all secrets.
- **AWS WAF:** Web Application Firewall protecting the API Gateway endpoint. Applies AWS Managed Rule groups (Core Rule Set, Known Bad Inputs) plus custom rate-limiting rules to enforce per-user API call quotas.

## Network Design

The platform is fully serverless and operates within the AWS managed network fabric — there are no VPCs, subnets, or NAT gateways required for the core Lambda and managed-service components. All inbound traffic enters through API Gateway (HTTPS only; TLS 1.2 minimum enforced via custom domain with ACM certificate). All traffic between Lambda, DynamoDB, S3, Bedrock, Step Functions, and SQS uses AWS service endpoints and remains entirely within the AWS us-west-2 region, satisfying the US data residency requirement without VPC endpoint complexity.

Outbound egress to end users (~200 GB/month) flows from S3 via presigned URLs over HTTPS. AWS WAF sits in front of API Gateway to inspect and filter all inbound HTTP/S traffic before it reaches Lambda. CloudFront is not in scope for the MVP but is noted as a future optimisation for artifact download performance.

## Security Design

The platform implements defence-in-depth across the full request lifecycle:

**Identity & Access:** Amazon Cognito User Pool issues JWT tokens for all platform users. API Gateway validates tokens natively at the edge before any Lambda function is invoked. IAM roles follow least-privilege principles — each Lambda function has a dedicated execution role with only the specific DynamoDB tables, S3 buckets, Bedrock model ARNs, and SQS queues it needs. No wildcard resource policies are permitted.

**Encryption:** All data at rest is encrypted using AWS KMS Customer Managed Keys (CMKs): S3 bucket default encryption (SSE-KMS), DynamoDB encryption at rest, and Secrets Manager secret encryption. All data in transit is protected by TLS 1.2+ on all API Gateway endpoints and between Lambda and managed services.

**Preventative Controls:** AWS WAF on API Gateway (rate limiting, managed rule groups); Cognito MFA enforcement for admin group users; IAM permission boundaries on Lambda execution roles; S3 Block Public Access enforced at account level; DynamoDB resource-based policies restricting table access to named Lambda execution roles.

**Detective Controls:** AWS GuardDuty for threat detection across the AWS account; AWS Security Hub aggregating findings from GuardDuty, AWS Config, and Inspector; CloudWatch alarms on suspicious invocation patterns (rate spikes, error-rate anomalies); CloudTrail logging all API calls to an immutable S3 bucket with Object Lock.

**Responsive Controls:** CloudWatch alarms trigger SNS notifications to the Security & Compliance Lead for high-severity findings. A documented incident response runbook (delivered as part of the handover package) defines escalation paths and containment procedures.

## Data Architecture

**Data Classification:** Three data tiers are defined: (1) Client Brief Inputs — confidential, US-resident, GDPR-applicable; (2) Generated Artifacts — confidential, US-resident; (3) Platform Telemetry — internal operational data, US-resident.

**Storage:** All client brief inputs and generated artifacts are stored in Amazon S3 (us-west-2) under the structured key taxonomy. DynamoDB stores only solution state metadata and usage counters — no raw client content is persisted in DynamoDB. Secrets Manager holds all credentials.

**Retention & Lifecycle:** Generated artifacts are retained in S3 Standard for 180 days, then transitioned to S3 Glacier Flexible Retrieval for long-term archival. CloudTrail audit logs are retained for 7 years in a dedicated S3 bucket with Object Lock (WORM) enabled. DynamoDB TTL is set to 365 days for usage-tracking records.

**Data Protection:** KMS CMK encryption at rest on all S3 buckets and DynamoDB tables. S3 versioning enabled on the artifacts bucket to protect against accidental deletion. S3 Object Lock (Compliance mode, 7-year retention) applied to the CloudTrail log bucket. Cross-region replication is not in scope for MVP but is recommended as a Phase 4 enhancement.

**GDPR Alignment:** Personal data (user identifiers, client contact details within briefs) is stored only in us-west-2. A data processing register is maintained documenting all data flows. S3 lifecycle policies and DynamoDB TTL enforce right-to-erasure capability for individual user records on request.

## Operational Design

**Monitoring & Observability:** CloudWatch provides the primary observability layer with custom dashboards tracking: async job completion rate, Bedrock token consumption vs. budget, Lambda invocation error rates, API Gateway 4xx/5xx rates, DynamoDB throttle events, and S3 PUT/GET operation latency. Datadog APM supplements CloudWatch for Lambda cold-start profiling and Bedrock invocation latency histograms. All Lambda logs flow to CloudWatch Log Groups with structured JSON formatting for query efficiency.

**Alerting:** CloudWatch alarms are configured at three severity levels — P1 (async job failure rate >5% in 5 minutes → immediate PagerDuty/SNS escalation), P2 (API error rate >1% over 15 minutes → Slack notification to VP Engineering), P3 (token budget >80% consumed in month → email to Head of Solutions).

**Backup & Disaster Recovery:** S3 versioning provides point-in-time recovery for all generated artifacts. DynamoDB point-in-time recovery (PITR) is enabled on both tables, providing continuous backups with a 35-day recovery window. Step Functions execution history is retained for 90 days for job audit and replay. Cognito user pool backup is achieved via nightly export of user attributes to S3 (encrypted).

**RTO/RPO Targets:**
- **RTO:** ≤1 hour for full platform recovery following a service-layer failure (Lambda/API Gateway auto-recover; DynamoDB PITR; S3 replicated)
- **RPO:** ≤15 minutes (DynamoDB PITR continuous backup; S3 versioning)
- **Availability:** 99.9% monthly uptime target, measured as successful API Gateway health-check responses

**Runbooks:** Operational runbooks covering async job failure triage, Cognito user administration, usage limit override procedures, and Bedrock quota management will be delivered as part of the Phase 1 handover package.

## Tooling Overview

The table below summarises the primary tools and AWS services used across the engagement, organised by functional category. These tools cover the full lifecycle from infrastructure provisioning through AI generation, security monitoring, and CI/CD delivery.

<!-- TABLE_CONFIG: widths=[28, 35, 37] -->
| Category | Primary Tools | Purpose |
|----------|---------------|---------|
| AI / ML Generation | Amazon Bedrock (Claude 3 Sonnet, Haiku) | Consulting artifact content generation via structured prompts |
| Serverless Compute | AWS Lambda (Python 3.12) | API handlers, Bedrock invokers, artifact processors |
| API Management | Amazon API Gateway (REST) + AWS WAF | Secure API ingress, rate limiting, request validation |
| Job Orchestration | AWS Step Functions, Amazon SQS | Durable 30–60 min async generation pipeline management |
| Identity & Auth | Amazon Cognito, AWS IAM | User authentication, admin governance, least-privilege access |
| Data / State | Amazon DynamoDB, Amazon S3 | Solution state, usage limits, artifact storage |
| Secret Management | AWS Secrets Manager | API keys, credentials, automatic rotation |
| Security | AWS GuardDuty, Security Hub, CloudTrail, KMS | Threat detection, compliance monitoring, audit logging, encryption |
| Observability | Amazon CloudWatch, Datadog APM | Metrics, logs, alarms, cold-start profiling, SLA dashboards |
| CI/CD | GitHub Actions, AWS CodeDeploy | Multi-environment automated deployment pipeline |
| Infrastructure as Code | AWS CloudFormation / SAM, Terraform | Infrastructure provisioning and Terraform artifact generation |
| Development | Python 3.12, AWS SDK (boto3) | Lambda function development and Bedrock client integration |

---

# Security & Compliance

Security and compliance are first-class design constraints for the Amatra Intelligent Solution Builder — not retrofitted after delivery. The platform is designed to satisfy SOC 2 Type II requirements from initial deployment, with GDPR-aligned data handling and strict US data residency controls enforced at the infrastructure level.

## Identity & Access Management

Amazon Cognito serves as the single identity provider for all platform users following the Okta migration. All users authenticate via the Cognito User Pool; JWT tokens are issued at login and validated by API Gateway before any Lambda function is reached. MFA (TOTP or SMS) is enforced for all users in the Amatra Admin Cognito group. Regular access reviews (quarterly) are conducted by the Security & Compliance Lead to ensure dormant accounts are deactivated.

IAM roles for Lambda functions follow strict least-privilege principles. Each function has a dedicated execution role scoped to the minimum set of AWS resources required for its specific task. Permission boundaries prevent privilege escalation. IAM Access Analyzer is enabled to detect overly permissive policies. No IAM user credentials are used by the platform; all service-to-service calls use IAM role-based authentication.

Per-user and global monthly usage limits are enforced via DynamoDB counters inspected by a pre-authorisation Lambda function before any generation job is submitted. Administrators can override limits via the Cognito admin group console. All usage-limit changes are logged to CloudTrail.

## Monitoring & Threat Detection

AWS GuardDuty is enabled across the Amatra AWS account to continuously monitor CloudTrail, VPC Flow Logs (if applicable), and DNS logs for threat indicators including unusual API call patterns, credential exfiltration attempts, and known malicious IPs. AWS Security Hub aggregates GuardDuty findings alongside AWS Config rule compliance results and Inspector vulnerability findings into a single dashboard reviewed weekly by the Security & Compliance Lead.

CloudWatch alarms provide real-time alerting on security-relevant events: API Gateway spike in 4xx/5xx responses, Cognito authentication failure rate above threshold, S3 GetObject calls from unexpected principals, and CloudTrail log file integrity failures. All alarms route to an SNS topic with email and Slack integrations. High-severity GuardDuty findings trigger automated Lambda-based remediation (e.g., Cognito user account suspension for credential-stuffing detection).

## Compliance & Auditing

SOC 2 Type II compliance is scoped to the five Trust Service Criteria: Security, Availability, Processing Integrity, Confidentiality, and Privacy. Controls are designed and implemented during the Development phase with evidence collection beginning at Phase 1 go-live. The complete evidence package is delivered in Deliverable #16 (Month 8, Week 2) for Security & Compliance Lead sign-off.

AWS CloudTrail is enabled for all API calls (management events and S3 data events) across the account and logs to an immutable S3 bucket with Object Lock (Compliance mode, 7-year retention). AWS Config records all resource configuration changes and evaluates them against a set of custom and managed rules aligned to SOC 2 requirements. Config non-compliance findings are surfaced in Security Hub and trigger remediation workflows.

GDPR-aligned data handling covers: (1) a documented data processing register; (2) data minimisation — client briefs contain only the information necessary for generation; (3) right-to-erasure via S3 lifecycle deletion and DynamoDB TTL for user-linked records; (4) US data residency enforced via us-west-2 region restriction on all storage services and an AWS Organisation Service Control Policy (SCP) blocking data replication outside us-east-1/us-west-2.

## Encryption & Key Management

All data at rest is encrypted using AWS KMS Customer Managed Keys (CMKs). Separate CMKs are provisioned for: S3 artifacts bucket, DynamoDB tables, CloudTrail log bucket, and Secrets Manager. Key rotation is enabled (annual automatic rotation) for all CMKs. Key policies restrict usage to named IAM roles and deny all other principals. All S3 buckets enforce SSE-KMS encryption via bucket policy; unencrypted PutObject requests are denied.

All data in transit is protected by TLS 1.2 or higher. API Gateway custom domain is configured with an ACM-managed certificate, and the security policy enforces TLS 1.2+. Lambda-to-DynamoDB, Lambda-to-S3, and Lambda-to-Bedrock traffic uses HTTPS endpoints within the AWS network. Secrets Manager enforces TLS on all API calls.

## Governance

Platform governance is enforced at three levels: (1) **IAM Permission Boundaries** — prevent any Lambda function from exceeding its defined privilege scope regardless of policy changes; (2) **AWS Organizations SCPs** — restrict the Amatra production account from enabling services in non-approved regions or disabling CloudTrail; (3) **Cognito Group Policies** — enforce MFA, session duration limits, and usage quotas by group.

Change management follows a GitOps model: all infrastructure changes are committed to the GitHub repository, reviewed via pull request, and deployed via the CI/CD pipeline. No direct console changes are permitted in Production. All production deployments require a manual approval step in the GitHub Actions workflow, with the approval action logged to CloudTrail.

## Environments & Access

### Environment Strategy

The three environments below are isolated by AWS account or IAM boundary, ensuring that development and test activity cannot affect production data or availability.

<!-- TABLE_CONFIG: widths=[18, 28, 28, 26] -->
| Environment | Purpose | Access Control | Data |
|-------------|---------|----------------|------|
| Development | Feature development, unit testing, integration testing | Vendor engineering team only; Cognito dev user pool | Synthetic test data only; no real client briefs |
| Staging | QA, UAT, compliance validation, pre-production load testing | Vendor QA + Client VP Eng + Head of Solutions; Cognito staging pool | Anonymised or synthetic data; no production client content |
| Production | Live platform for all ~120 Amatra internal users | All authenticated Amatra users via Cognito; admin group for governance | Real client briefs and generated artifacts; US data residency enforced |

### Access Policies

Production environment access is restricted to authenticated Amatra users only, verified by Cognito JWT token validation at API Gateway. No vendor team members have persistent access to the Production environment post-go-live — access is granted on a time-limited, break-glass basis via a Cognito admin group, with all access events logged to CloudTrail. Staging access for vendor team members is revoked upon Phase 2 completion. Development environment access is managed by the VP Engineering team.

---

# Testing & Validation

A comprehensive, multi-stream testing approach is implemented across both phases to validate functional correctness, performance, security posture, and user acceptance. All testing is gated — Phase 2 cannot begin until Phase 1 tests pass, and Production deployment cannot proceed without explicit CTO sign-off on test results.

## Functional Validation

Functional testing validates that each generation pipeline produces artifact output that meets Amatra's quality standards. Test cases are derived from a representative set of 10–20 historical client briefs (provided by Head of Solutions during Discovery) and executed against all 7 artifact types across Phase 1 and Phase 2. Acceptance criteria for each artifact type are defined jointly with the Head of Solutions during the Discovery phase and formalised in the Test Plan (Deliverable #10 / #17).

Each generated artifact is evaluated against a structured quality rubric: required sections present, placeholders replaced, cross-references consistent (e.g., Investment Summary reconciles against infrastructure-costs.csv), formatting correct, and no hallucinated content in named fields (client name, technology stack, pricing). The QA validation layer (Phase 2) automates a subset of these checks; manual review covers the remainder.

**Target acceptance criterion:** ≥90% of generated artifacts pass all quality rubric checks on first review, with no P1 (blocking) defects in production.

## Performance & Load Testing

Performance testing validates the platform's ability to handle target throughput (24 concurrent engagements/quarter) and confirms that async generation jobs complete within the expected 30–60 minute window under load. Load tests are executed in the Staging environment using simulated brief-submission events at 2× expected peak load.

Key performance benchmarks:
- API Gateway response time (job submission endpoint): ≤500 ms at p99
- Async generation job completion: ≤60 minutes for all artifact types under standard load
- Lambda cold start latency: ≤3 seconds for all functions (provisioned concurrency for critical paths)
- DynamoDB read/write latency: ≤10 ms at p99 under target load
- S3 presigned URL generation: ≤200 ms

## Security Testing

Security validation is conducted by the vendor Security Engineer in coordination with the Security & Compliance Lead. Testing covers: IAM policy review (automated via IAM Access Analyzer and manual review), KMS encryption verification (S3 bucket policy audit, DynamoDB encryption-at-rest check), WAF rule testing (simulated injection and rate-limit validation against API Gateway), GuardDuty alert validation (simulated threat events to confirm detection and alerting), and Cognito authentication flow testing (MFA enforcement, token expiry, and group-based access control).

A Vulnerability Assessment is conducted on all Lambda function dependencies using Amazon Inspector and a dependency scanning step in the CI/CD pipeline (GitHub Actions). All P1/P2 findings must be resolved before the Production deployment gate.

## Disaster Recovery & Resilience Tests

DR testing validates the RTO (≤1 hour) and RPO (≤15 minutes) targets. Tests performed in Staging include: DynamoDB PITR point-in-time restore to a specific timestamp, S3 versioned object recovery, Step Functions state machine failure injection (simulating Bedrock API throttling and Lambda timeouts) with retry-and-resume validation, and Cognito user pool backup restore drill. Results are documented in the test results report.

## User Acceptance Testing

UAT is the final quality gate before each Production deployment and ensures that real end-users — not just the vendor QA team — confirm the platform meets Amatra's quality standards. Two separate UAT streams are run: one for pre-sales artifacts (Phase 1) and one for delivery artifacts and Terraform outputs (Phase 2).

Phase 1 UAT is led by the Head of Solutions with 3–5 pre-sales consultants participating over a structured two-week period in Staging. Participants submit real client briefs (with PII scrubbed) and evaluate generated artifacts against the quality rubric. Feedback is collected via a structured scoring form; any artifact scoring below the 90% threshold triggers defect logging and targeted prompt refinement. Written sign-off from the Head of Solutions is required before the Phase 1 Production deployment gate.

Phase 2 UAT is led by the VP Engineering with the Delivery Consulting team evaluating delivery artifacts and Terraform outputs. Sign-off from both UAT streams is required before CTO phase-gate approval for Phase 2 Production deployment.

## Go-Live Readiness

Before each Production deployment, the following readiness checklist must be fully signed off by the CTO:

- [ ] All functional test cases passing (0 open P1 defects, ≤3 open P2 defects with mitigations)
- [ ] Load test results meeting all performance benchmarks
- [ ] Security validation complete; all P1/P2 findings resolved
- [ ] DR test completed with RTO/RPO targets met
- [ ] UAT sign-off received from Head of Solutions (Phase 1) and VP Engineering (Phase 2)
- [ ] CloudWatch dashboards and alarms live and validated
- [ ] Cognito user migration complete and all users able to authenticate (Phase 1)
- [ ] SOC 2 controls evidence collection confirmed active (Phase 1)
- [ ] Training materials delivered and reviewed (Phase 1)
- [ ] Rollback plan reviewed and rehearsed

## Cutover Plan

**Phase 1 Cutover (Target: 30 September 2026):**
1. Final Staging smoke test: submit 3 representative briefs and confirm artifact output
2. Cognito production user pool activated; pre-sales consultants notified of login credentials
3. DNS cutover: platform custom domain pointed to production API Gateway endpoint (ACM cert validated)
4. Lambda production alias updated to latest verified deployment package
5. CloudWatch alarms confirmed active; on-call rotation set for hypercare period
6. Communication sent to all pre-sales consultants: platform live, training sessions scheduled
7. Monitor async job completion rate, error rate, and Bedrock token consumption for 24 hours post-cutover

**Phase 2 Cutover (Target: 15 December 2026):**
1. Phase 2 delivery pipeline Staging smoke test (all 7 artifact types)
2. QA validation layer activated in Production; pass-rate dashboard live
3. Delivery team notified; Phase 2 training sessions scheduled
4. Monitor QA pass-rate metrics for 48 hours post-cutover

## Rollback Strategy

Rollback is available as a safety net for both Phase 1 and Phase 2 cutovers, with pre-defined triggers and a target execution time of ≤30 minutes to minimise disruption to Amatra's pre-sales operations.

**Rollback Triggers:** Rollback is initiated if any of the following occur within 4 hours of cutover: async job failure rate >20%, API Gateway 5xx error rate >5%, Cognito authentication failure rate >10%, or data integrity issue detected in S3 artifacts.

**Rollback Procedure:** Lambda function aliases are reverted to the prior verified deployment package via a single GitHub Actions workflow step (automated rollback). API Gateway stage is rolled back to the previous deployment. DNS TTL is set to 60 seconds pre-cutover to enable rapid re-pointing if needed. Rollback decision authority rests with the vendor Project Manager in consultation with VP Engineering; full rollback target time is ≤30 minutes.

---

# Handover & Support

Successful completion of this engagement transfers full operational ownership of the Amatra Intelligent Solution Builder platform to Amatra's internal teams. The handover package is designed to ensure the VP Engineering team can operate, monitor, and evolve the platform without external dependency.

## Handover Artifacts

The following items are transferred to Amatra at engagement close:

- All source code in Amatra's GitHub organisation (Lambda functions, Step Functions state machine definitions, CloudFormation/SAM templates, Terraform modules)
- Architecture diagrams (draw.io source files and PNG exports), ADRs, and data-flow diagrams
- Operational runbooks: async job failure triage, Cognito user administration, usage limit override, Bedrock quota management, incident response
- Terraform automation scripts for platform infrastructure reprovisioning
- Test plans, test results reports, and UAT sign-off records
- SOC 2 Type II controls evidence package
- Training materials: user guides (pre-sales and delivery workflows), administrator guide, recorded training session videos
- CloudWatch dashboard definitions (JSON) for re-deployment
- Secrets Manager rotation schedules and KMS key policy documentation

## Knowledge Transfer

Knowledge transfer is structured across three sessions to ensure each audience receives targeted, role-appropriate enablement without information overload:

- **Session 1 (Phase 1 End):** Platform Operations Training for VP Engineering team — covers CloudWatch monitoring, Lambda deployment management, DynamoDB capacity review, Cognito user administration, and incident response runbook walkthrough. Duration: half-day.
- **Session 2 (Phase 2 End):** Delivery Artifact Pipeline Enablement for Delivery Consulting team — covers artifact type overview, quality rubric, Terraform output interpretation, and QA validation layer controls. Duration: 2 hours.
- **Session 3 (GA):** Train-the-Trainer for Head of Solutions — enables independent onboarding of future pre-sales hires. Covers brief-submission workflow, artifact review process, and quality feedback loop. Duration: 2 hours.

All sessions are recorded and the recordings are delivered to Amatra for future self-service enablement.

## Hypercare Support

**Phase 1 Hypercare (8 weeks post Phase 1 go-live — October/November 2026):**
- Coverage: Business hours (09:00–18:00 CT, Monday–Friday)
- Scope: Triage of generation failures, Bedrock prompt quality issues, Cognito authentication problems, async job failures, CloudWatch alarm investigation, and performance tuning
- Response times: P1 issues (platform down or generation pipeline failing) ≤2-hour response; P2 issues ≤next-business-day response
- Communication channel: Dedicated Slack channel shared between vendor and Amatra teams

**Phase 2 Hypercare (4 weeks post Phase 2 go-live — January 2027):**
- Coverage: Business hours (09:00–18:00 CT, Monday–Friday)
- Scope: Delivery pipeline issues, QA validation layer tuning, Terraform output quality, template pipeline defects
- Response times: P1 ≤2-hour response; P2 ≤next-business-day response

## Managed Services Transition

Ongoing managed services are not included in this engagement. Refer to a separate Managed Services Agreement if Amatra requires post-hypercare operational support, ongoing Bedrock prompt optimisation, or platform feature development beyond the scope of this SOW.

## Assumptions

The following assumptions underpin the scope, timeline, and cost of this engagement. Material changes to any assumption may require a Change Order to adjust scope, schedule, or investment.

1. Amatra's CTO provides budget and governance approval before Phase 1 kickoff, with no change to the approved scope or budget envelope.
2. VP Engineering provisions the AWS account(s) in us-west-2 and grants the vendor team appropriate IAM access within Week 1 of the project.
3. Amatra provides a complete Okta user directory export within two weeks of project kickoff.
4. Head of Solutions provides 10–20 representative historical client briefs (PII-scrubbed) for Bedrock prompt engineering within Week 2.
5. Amatra maintains active GitHub licences for the engineering team throughout the engagement.
6. AWS Bedrock Claude 3 Sonnet and Haiku models are available in us-west-2 at project start; if not, Amatra accepts use of us-east-1 cross-region inference as a fallback.
7. Client review and approval of architecture design and phase gate deliverables will be completed within five business days of submission.
8. The Security & Compliance Lead is available for at least two hours per week throughout the project for SOC 2 scoping and controls review.
9. Amatra's legacy Word/Excel/PowerPoint templates are available in their current Google Workspace location and can be exported without restriction.
10. All Amatra stakeholders named in this SOW are available for scheduled workshops, UAT sessions, and phase-gate reviews with reasonable advance notice (≥5 business days).
11. The AWS Business Support plan is activated on the production account before Phase 1 go-live.
12. No change to the Phase 1 deadline (30 September 2026) or GA deadline (31 January 2027) is expected; timeline compression requests are subject to change control.
13. Terraform automation artifact scope is limited to infrastructure reprovisioning for the solution builder platform itself; client-engagement Terraform is a separate deliverable of the generation pipeline.
14. The vendor team does not have access to live production client data; all testing uses synthetic or anonymised briefs.

## Dependencies

The following dependencies must be satisfied for the engagement to proceed on schedule. Each dependency has an assigned owner and a latest acceptable resolution date; unresolved dependencies beyond their due date will trigger a risk escalation to the CTO.

| Dependency | Owner | Required By |
|------------|-------|-------------|
| AWS account provisioning and IAM access granted | Amatra VP Engineering | Week 1 |
| Okta user directory export | Amatra Security & Compliance Lead | Week 2 |
| Historical client briefs (anonymised, 10–20 sample set) | Head of Solutions | Week 2 |
| Legacy artifact template files exported from Google Workspace | Head of Solutions | Month 2 |
| Artifact quality rubric defined and approved | Head of Solutions | Month 2 |
| AWS Bedrock model access enabled in us-west-2 | Amatra VP Engineering | Month 2 |
| SOC 2 scoping exercise completed | Security & Compliance Lead | Month 3 |
| Phase 1 UAT participants confirmed and available | Head of Solutions | Month 4 |
| Phase 2 UAT participants confirmed and available | VP Engineering | Month 7 |
| CTO phase-gate approval (Phase 1) | CTO | 30 Sep 2026 |
| CTO phase-gate approval (Phase 2) | CTO | 15 Dec 2026 |

---

# Investment Summary

This engagement represents a **Medium-Large** scope implementation — a fully serverless, greenfield AWS platform integrating six named AWS services, an AI/ML generation pipeline, identity migration, SOC 2 Type II compliance controls, and a seven-artifact-type generation pipeline spanning pre-sales and delivery workstreams. The investment figures below are reconciled against the infrastructure-costs.csv (3-year infrastructure totals) and level-of-effort-estimate.csv (professional services LOE) and represent the complete financial commitment for all three phases of the engagement.

## Total Investment

The table below summarises the complete 3-year total cost of ownership, inclusive of all professional services, cloud infrastructure, software licences, and AWS support, net of applicable AWS partner credits. Infrastructure line items are sourced directly from the infrastructure-costs.csv 3-Year Summary; professional services reflect the level-of-effort-estimate.csv SUMPRODUCT of actual hours × rates across all phases.

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[22, 12, 14, 12, 10, 10, 13] -->
| Cost Category | Year 1 List | Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------|------------|--------|--------|--------------|
| Professional Services | $395,000 | ($35,000) | $360,000 | $0 | $0 | $360,000 |
| Cloud Infrastructure | $18,000 | ($8,000) | $10,000 | $18,000 | $18,000 | $46,000 |
| Software Licenses | $4,038 | $0 | $4,038 | $3,288 | $3,288 | $10,614 |
| Support & Maintenance | $4,140 | $0 | $4,140 | $4,140 | $4,140 | $12,420 |
| **TOTAL INVESTMENT** | **$421,178** | **($43,000)** | **$378,178** | **$25,428** | **$25,428** | **$429,034** |
<!-- END COST_SUMMARY_TABLE -->

*Year 2 and Year 3 run costs of ~$25,428/year reflect steady-state infrastructure, software licences, and AWS Business Support — consistent with the brief's projected run cost of $4,000–$6,000/month (~$48,000–$72,000/year at list; actual AWS consumption is significantly lower at ~$18,000/year based on the infrastructure-costs.csv model). No professional services are included in Years 2–3 under this SOW.*

## Partner Credits

The following AWS partner credits reduce the Year 1 investment by a combined $43,000. Credits are applied in Year 1 only and are confirmed at project kickoff before the first invoice is issued.

**Professional Services Credits (Level-of-Effort-Estimate.csv — $35,000 total):**
- **AWS Partner Services Credit:** ($15,000) — AWS Partner Network (APN) Advanced Tier credit applied to solution architecture and implementation of AWS-native platform (Bedrock, Lambda, API Gateway, DynamoDB, S3, Cognito)
- **AWS AI/ML Specialisation Credit:** ($5,000) — AWS Generative AI competency partner credit for Amazon Bedrock implementation and Claude model integration
- **Implementation Volume Discount:** ($10,000) — Strategic engagement discount for multi-phase engagement (Phase 1 MVP + Phase 2 + GA rollout) totalling Year 1 build commitment of $300K–$450K
- **New Workload Incentive:** ($5,000) — AWS new workload launch incentive for greenfield serverless platform with net-new Bedrock consumption commitment

**Infrastructure Credits (Infrastructure-Costs.csv — $8,000 total):**
- **AWS Migration Acceleration Program (MAP) Credit:** ($5,000) — Applied to Okta-to-Cognito identity migration workstream
- **AWS Partner Network Credit:** ($3,000) — Applied to Bedrock and Lambda Year 1 consumption

## Cost Components

**Professional Services — $395,000 list / $360,000 net (Year 1 only):**
Professional services encompass all labour across the seven LOE phases: Discovery (~$41,800), Planning & Design (~$78,425), Development & Implementation (~$183,050), Testing & Validation (~$62,875), Deployment (~$31,200), Training & Enablement (~$13,600), and Management overhead (~$40,000). Blended rates range from $125/hour (Technical Writer) to $275/hour (ML/AI Engineer). Total professional services hours across all phases are approximately 1,650 hours.

**Cloud Infrastructure — $18,000 list / $10,000 net Year 1 | $18,000/year steady-state:**
Cloud infrastructure reflects 12 AWS services (Lambda, API Gateway, Bedrock, DynamoDB, S3, Cognito, SQS, CloudWatch, WAF, Secrets Manager, CloudTrail, Route 53) plus data transfer egress, scoped to the Medium-Large engagement tier (~10M Bedrock input tokens/month, ~3M API Gateway requests/month, 100 GB S3 storage). Amazon Bedrock (Claude 3 Sonnet/Haiku) represents the largest component at $9,900/year.

**Software Licences — $4,038 list Year 1 / $3,288/year steady-state:**
Includes: Okta wind-down (3-month overlap, $750, Year 1 only), GitHub Actions Team plan for the engineering team ($528/year), and Datadog APM for 10 hosts ($2,760/year).

**Support & Maintenance — $4,140/year:**
AWS Business Support plan at ~10% of monthly AWS spend (~$345/month), providing 1-hour critical response time required for the 99.9% availability SLA.

## Payment Terms

Payments are tied to project milestones to align financial commitment with delivered value:

| Milestone | Amount Due | Due Date |
|-----------|-----------|----------|
| Contract Execution & Kickoff | $75,636 (20% net Year 1) | Upon SOW signature |
| M2 — Architecture Approved | $56,727 (15% net Year 1) | Month 2, Week 2 |
| M4 — Phase 1 MVP Go-Live | $113,454 (30% net Year 1) | 30 September 2026 |
| M6 — Phase 2 Go-Live | $94,545 (25% net Year 1) | 15 December 2026 |
| M9 — Project Close | $37,818 (10% net Year 1) | Upon final deliverable acceptance |
| Monthly Cloud & Software | Per-invoice monthly | 1st of each calendar month |

Net payment terms: 30 days from invoice date. All payments in USD.

## Invoicing & Expenses

Professional services are invoiced at each milestone gate listed above, upon written client acceptance of the associated deliverables. Cloud infrastructure and software licence costs are invoiced monthly based on actual AWS consumption and licence usage, reconciled against the infrastructure-costs.csv baseline. Reasonable travel expenses (if any in-person workshops are requested) are reimbursed at cost with prior written approval; all current-scope work is assumed to be delivered remotely.

---

# Terms & Conditions

This Statement of Work is incorporated into and governed by the Master Services Agreement (MSA) executed between Amatra and EO Framework Consulting. In the event of any conflict between this SOW and the MSA, the MSA governs unless this SOW expressly states otherwise.

## General Terms

This SOW constitutes the complete description of services to be performed. Services will be delivered remotely unless otherwise agreed in writing. All work will be performed by qualified professionals with relevant AWS certifications and experience. The vendor reserves the right to use subcontractors, subject to Amatra's written consent, which shall not be unreasonably withheld.

## Scope Changes

Any change to scope, timeline, budget, deliverables, or personnel must be documented in a written Change Order signed by both parties before implementation. Change Requests are initiated by either party, evaluated by the vendor Project Manager within five business days, and presented with impact analysis (cost, timeline, resource implications) for client review. Work on changed scope does not begin until the Change Order is executed. Minor clarifications that do not affect cost or schedule may be agreed via email confirmation.

## Intellectual Property

Upon receipt of final payment, Amatra receives full ownership of all deliverables created specifically for this engagement, including source code, architecture documents, runbooks, training materials, and data models. The vendor retains ownership of all pre-existing methodologies, frameworks, accelerators, prompt engineering libraries, and reusable tooling ("Vendor IP") that may be embedded in deliverables. Vendor IP embedded in deliverables is licensed to Amatra on a perpetual, royalty-free, non-exclusive basis for internal business use. The EO Framework artifact generation templates remain the intellectual property of EO Framework Consulting and are licensed — not transferred — to Amatra under this SOW.

## Service Levels

The vendor warrants that all deliverables will conform to the acceptance criteria defined in Section 4 for a period of 30 days following written acceptance by the client ("Warranty Period"). Defects reported during the Warranty Period will be remediated at no additional charge. The warranty does not cover defects caused by client modifications, third-party software failures, or AWS service outages. After the Warranty Period, defect resolution is covered by the hypercare support defined in Section 9 or a separate support agreement.

Platform SLA targets (99.9% availability, ≥90% QA pass rate, ≤2-day artifact turnaround) are design targets for the delivered platform, not service-level commitments by the vendor for ongoing operations. Once the platform is transferred to Amatra's operational control, SLA achievement is the responsibility of Amatra's internal teams.

## Liability

The vendor's total aggregate liability under this SOW shall not exceed the total fees paid by Amatra in the preceding twelve months. Neither party shall be liable for indirect, consequential, incidental, or punitive damages, loss of profits, or loss of data arising from this engagement, whether or not such damages were foreseeable. This limitation does not apply to gross negligence, wilful misconduct, or breaches of confidentiality obligations.

## Confidentiality

Both parties agree to maintain in strict confidence all Confidential Information received from the other party, to use it solely for the purposes of this engagement, and not to disclose it to any third party without prior written consent. Confidential Information includes client briefs, business strategies, pricing, technical designs, personnel information, and all non-public project deliverables. Confidentiality obligations survive termination of this SOW for a period of three years. The parties' obligations under any separately executed NDA or MSA confidentiality provisions remain in full force.

## Termination

Either party may terminate this SOW for convenience upon 30 days written notice. Upon termination, the client shall pay for all work performed and expenses incurred up to the termination effective date, plus any non-cancellable commitments made by the vendor on the client's behalf. Either party may terminate immediately for material breach if the breach is not cured within 15 business days of written notice. Upon termination, the vendor will deliver all work product completed to date and transfer all client-owned materials to Amatra within 10 business days.

## Governing Law

This Statement of Work shall be governed by and construed in accordance with the laws of the State of Texas, United States, without regard to its conflict of law provisions. Any disputes arising under this SOW shall be subject to the exclusive jurisdiction of the courts of Travis County, Texas, unless the MSA specifies an alternative dispute resolution mechanism (e.g., binding arbitration), in which case that mechanism governs.

---

# Sign-Off

By signing below, both parties confirm they have read, understood, and agree to the scope, approach, commercial terms, and conditions set out in this Statement of Work. This document, together with any executed Change Orders, forms the complete agreement for the services described herein and supersedes all prior negotiations, representations, or proposals relating to the Amatra Intelligent Solution Builder engagement.

**Client Authorized Signatory (Amatra):**

Name: __________________________
Title: __________________________
Signature: ______________________
Date: __________________________


**Service Provider Authorized Signatory (EO Framework Consulting):**

Name: __________________________
Title: __________________________
Signature: ______________________
Date: __________________________

---

*This Statement of Work, once signed, constitutes a binding agreement. It supersedes all prior oral or written representations relating to the subject matter and may only be modified by a written Change Order executed by both parties.*

*Document Version: 1.0 | Opportunity: OPP-2026-001 | Prepared: July 1, 2026*
