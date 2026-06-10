---
document_title: Detailed Design Document
solution_name: Amatra Intelligent Solution Builder
document_version: "1.0"
author: Lead Solutions Architect — EO Framework Consulting
last_updated: 2026-07-01
technology_provider: aws
client_name: Amatra
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Detailed Design Document (DDD) defines the complete technical blueprint for the **Amatra Intelligent Solution Builder** — a cloud-native, fully serverless platform hosted on Amazon Web Services (AWS) that transforms a structured client brief into a consulting-grade engagement package. The platform is built on Amazon Bedrock (Claude 3 Sonnet/Haiku), AWS Lambda, Amazon API Gateway, AWS Step Functions, Amazon SQS, Amazon DynamoDB, Amazon S3, and Amazon Cognito, all deployed within the us-west-2 region to enforce US data residency. It automates the production of seven artifact types spanning pre-sales and delivery workstreams, and is designed from the outset to satisfy SOC 2 Type II and GDPR-aligned data-handling requirements.

This document expands the Architecture & Design section of the Statement of Work (SOW, Opportunity OPP-2026-001) into implementation-ready technical specifications. Every architecture component, integration point, security control, and operational procedure described herein traces directly to a presales commitment. No services, regions, or capabilities beyond those established in the SOW are introduced. This document is the authoritative technical reference for all implementation, testing, and handover activities across the three project phases, with Phase 1 MVP targeting 30 September 2026, Phase 2 targeting 15 December 2026, and General Availability targeting Q1 2027 (hard deadline 31 January 2027).

The design prioritises operational simplicity, security by default, and compliance readiness. Every component is a managed or serverless AWS service, eliminating EC2 fleet management. All data is encrypted at rest using AWS KMS Customer Managed Keys (CMKs) and in transit via TLS 1.2+. All API calls are recorded by AWS CloudTrail to provide an immutable SOC 2 audit trail. Three isolated environments — Dev, Staging, and Production — are managed through a GitHub Actions CI/CD pipeline with mandatory quality gates between each promotion.

## Purpose

This document defines the target-state technical architecture, component specifications, security controls, data design, integration patterns, infrastructure configuration, and implementation sequencing for the Amatra Intelligent Solution Builder. It is the primary reference for the EO Framework Consulting engineering team during build and for Amatra's VP Engineering and Security & Compliance Lead during review, acceptance, and ongoing operations. It supersedes any preliminary architecture sketches produced during the Discovery phase.

## Scope

The following items are explicitly within the scope of this design document and the corresponding implementation engagement.

**In-scope:**

- Greenfield serverless AWS platform design and deployment in us-west-2 (Lambda, API Gateway, DynamoDB, S3, Cognito, SQS, Step Functions, CloudWatch, WAF, GuardDuty, CloudTrail, Secrets Manager, KMS)
- Amazon Bedrock (Claude 3 Sonnet/Haiku) AI generation pipeline for all seven artifact types
- Durable asynchronous job orchestration (AWS Step Functions + Amazon SQS) supporting 30–60 minute generation workflows
- Okta-to-Amazon Cognito identity migration with admin group governance and per-user/global usage limit enforcement
- Legacy artifact template migration (Word, Excel, PowerPoint from Google Workspace) into the automated generation pipeline
- SOC 2 Type II controls design and implementation, including CloudTrail, KMS, WAF, GuardDuty, and Security Hub
- GDPR-aligned data handling controls and US data residency enforcement
- Multi-environment CI/CD pipeline (GitHub Actions) for Dev, Staging, and Production
- Pre-sales artifact pipeline (Phase 1): discovery questionnaire, solution briefing, statement of work, infrastructure cost model
- Delivery artifact pipeline (Phase 2): detailed design document, implementation guide, Terraform automation scripts
- CloudWatch monitoring dashboards and alarms for availability, async job reliability, and QA pass-rate tracking
- Training, enablement, and hypercare support as defined in the SOW

**Out-of-scope:**

- Multi-region deployment or disaster recovery to a secondary AWS region
- External client-facing portal (internal Amatra platform only)
- Custom model fine-tuning or foundation model training beyond prompt engineering
- CRM integration, billing automation, or application development outside the artifact generation platform
- Physical data centre, co-location, or on-premises infrastructure
- Ongoing managed services post-hypercare
- HIPAA, PCI-DSS, FedRAMP, or compliance frameworks beyond SOC 2 Type II and GDPR
- Data migration of historical engagement artifacts into the new platform
- CloudFront distribution (noted as a future optimisation, not in MVP scope)

## Assumptions & Constraints

The following assumptions underpin the technical decisions made in this document. Material changes to any assumption may require a design revision and Change Order.

- Amatra's VP Engineering provisions the AWS account(s) in us-west-2 and grants IAM access to the vendor engineering team by Week 1 of the project.
- AWS Bedrock Claude 3 Sonnet and Haiku models are available in us-west-2 at project start; if not, us-east-1 cross-region inference is accepted as an approved fallback.
- A complete Okta user directory export is provided by the Security & Compliance Lead within two weeks of kickoff; the current active user count is approximately 50 users.
- The Head of Solutions provides 10–20 representative historical client briefs (PII-scrubbed) for Bedrock prompt engineering by Week 2.
- All Lambda functions are authored in Python 3.12 using the AWS SDK (boto3).
- The platform is fully serverless; no EC2 instances, containers, or Kubernetes clusters are required.
- DynamoDB is provisioned on-demand capacity mode; no reserved capacity is applicable.
- Legacy Word/Excel/PowerPoint templates in Google Workspace are accessible and exportable without restriction.
- No changes to the Phase 1 deadline (30 September 2026) or GA deadline (31 January 2027) are expected without a formal Change Order.
- The AWS Business Support plan is activated on the production account before Phase 1 go-live.

## References

- Statement of Work (SOW) — Amatra Intelligent Solution Builder, Opportunity OPP-2026-001, v1.0, 1 July 2026
- Solution Briefing — Amatra Intelligent Solution Builder, EO Framework Consulting
- Infrastructure Costs Model — infrastructure-costs.csv (3-year infrastructure totals)
- Level of Effort Estimate — level-of-effort-estimate.csv (professional services LOE by phase and resource)
- AWS Well-Architected Framework — Serverless Application Lens
- AWS Bedrock Claude Model Documentation (us-west-2 regional availability)
- SOC 2 Trust Service Criteria — Security, Availability, Processing Integrity, Confidentiality, Privacy
- GDPR Article 25 (Data Protection by Design and by Default)

---

# Business Context

The Amatra Intelligent Solution Builder exists to solve a fundamental throughput and quality problem in Amatra's consulting operations. Today, every pre-sales and delivery artifact is produced manually by individual consultants using Google Workspace documents and a legacy internal monolith hosted on a single EC2 instance. This manual cycle takes approximately three weeks per engagement, caps quarterly proposal throughput at roughly eight active pursuits, and produces inconsistently structured output that frequently fails internal QA. The technical design described in this document is the direct response to those constraints — an AI-powered, serverless AWS platform that converts a structured client brief into a complete engagement package in under two business days, with ≥90% first-review acceptance.

## Business Drivers

The following primary business drivers are derived directly from the SOW Background & Objectives section and inform every architecture decision in this document.

- **Artifact Turnaround Acceleration:** Reducing the end-to-end artifact cycle from approximately three weeks to under two business days (>90% improvement) is the primary value driver. Every design decision that introduces latency — such as synchronous Bedrock calls, blocking Lambda chains, or manual approval gates in the pipeline — was evaluated against this target and resolved in favour of the durable asynchronous pattern (Step Functions + SQS).
- **Proposal Throughput Tripling:** Scaling from ~8 to ~24 active engagements per quarter without proportional headcount growth requires a platform that can handle up to 24 concurrent generation jobs without degradation. The on-demand DynamoDB capacity model, auto-scaling Lambda concurrency, and SQS queue depth management directly support this objective.
- **Quality Consistency:** Individual consultant judgment variability produces unpredictable QA pass rates. The Bedrock prompt engineering framework, artifact-type-specific structured prompts, and the Phase 2 QA validation layer are designed to enforce ≥90% first-review acceptance across all seven artifact types.
- **Identity & Governance Modernisation:** Migrating from Okta to Amazon Cognito aligns identity management with AWS-native security patterns, enables per-user and global usage-limit enforcement via DynamoDB counters, and introduces admin group governance controls that the current Okta configuration does not support.
- **SOC 2 Type II and GDPR Compliance:** Enterprise clients impose contractual compliance requirements that the current environment cannot satisfy. CloudTrail audit logging, KMS encryption, WAF, GuardDuty, Security Hub, and GDPR-aligned data flows are designed in from Day 1 — not retrofitted — to support the flagship client renewal by 31 January 2027.
- **Legacy Template Preservation:** Amatra's existing Word, Excel, and PowerPoint templates represent accumulated brand and quality standards. The template ingestion pipeline (Phase 2) preserves those standards in the automated generation workflow rather than discarding them.

## Workload Criticality & SLA Expectations

The Amatra Intelligent Solution Builder is a mission-critical internal platform. A failure in the generation pipeline directly blocks pre-sales consultants from responding to client opportunities, making uptime and async job reliability first-class SLA targets. The table below defines the platform's quantified SLA commitments and their measurement approaches.

<!-- TABLE_CONFIG: widths=[28, 22, 28, 22] -->
| Metric | Target | Measurement | Priority |
|--------|--------|-------------|----------|
| Platform Availability | 99.9% monthly | API Gateway health-check success rate | Critical |
| Artifact Turnaround | ≤2 business days | Job submission to artifact-ready event | Critical |
| Async Job Completion | ≤60 minutes | Step Functions execution duration p95 | Critical |
| API Response Time (job submission) | ≤500 ms p99 | API Gateway latency metrics | High |
| QA First-Pass Acceptance Rate | ≥90% | QA validation layer scoring | High |
| Lambda Cold Start Latency | ≤3 seconds | CloudWatch cold-start metric | High |
| DynamoDB Read/Write Latency | ≤10 ms p99 | CloudWatch DynamoDB metrics | Medium |
| RTO (platform recovery) | ≤1 hour | DR test results | Critical |
| RPO (data recovery point) | ≤15 minutes | DynamoDB PITR continuous backup | Critical |

## Compliance & Regulatory Factors

The platform must satisfy two compliance frameworks from initial deployment. SOC 2 Type II scopes all five Trust Service Criteria (Security, Availability, Processing Integrity, Confidentiality, Privacy), with evidence collection beginning at Phase 1 go-live and the complete evidence package delivered by Month 8, Week 2. GDPR-aligned data handling governs all personal data within client briefs (user identifiers, client contact details), requiring documented data flows, data minimisation, right-to-erasure capability, and strict US data residency (us-west-2). An AWS Organization Service Control Policy (SCP) enforces the residency requirement by blocking data replication outside us-east-1 and us-west-2.

## Success Criteria

The following measurable criteria, drawn directly from the SOW Success Metrics section, define the acceptance standard for this engagement and the design targets embedded in this document.

- Artifact turnaround time of ≤2 business days from brief submission to complete package delivery
- Quarterly proposal throughput of ≥24 active engagements per quarter within 90 days of General Availability
- Consulting hours per engagement at ≤60% of the current baseline (≥40% reduction)
- QA first-pass acceptance rate of ≥90% of generated artifacts approved without rework
- Platform availability of 99.9% uptime measured monthly in production (us-west-2)
- 100% of Okta user records migrated to Cognito with zero authentication outages
- SOC 2 Type II audit-ready controls implemented and evidenced prior to General Availability
- Platform live and all ~120 internal users onboarded before 31 January 2027

---

# Current-State Assessment

The Amatra Intelligent Solution Builder is a fully **greenfield** implementation. There is no existing automated artifact generation platform to migrate from. However, there are incumbent systems and processes that this implementation replaces or integrates with, and those are documented here to establish the baseline from which the gap analysis derives the design requirements.

## Application Landscape

Amatra's current artifact production environment relies on a combination of manual workflows, a legacy internal monolith, and Google Workspace document tools. These systems do not provide automated generation capability, and their limitations directly motivate the target-state design.

<!-- TABLE_CONFIG: widths=[28, 28, 22, 22] -->
| Application | Purpose | Technology | Disposition |
|-------------|---------|------------|-------------|
| Legacy Internal Monolith | Internal tooling and workflow support | Single EC2 instance (region unspecified) | Retire — replaced by serverless platform |
| Google Workspace | Document authoring, artifact templates, team collaboration | Word/Excel/PowerPoint + Drive | Integrate — templates migrated into generation pipeline |
| Okta | Identity and access management for ~50 active users | SaaS IdP | Replace — migrate to Amazon Cognito |
| Manual Artifact Authoring | Individual consultant document creation | Human workflow | Automate — replaced by Bedrock generation pipeline |
| Email/Slack (ad-hoc) | Artifact delivery to clients | Unstructured | Replace — S3 presigned URL delivery |

## Infrastructure Inventory

The current infrastructure footprint is minimal and entirely underpins the legacy monolith. The greenfield serverless platform introduces no dependency on existing infrastructure and is provisioned independently in us-west-2.

<!-- TABLE_CONFIG: widths=[25, 12, 38, 25] -->
| Component | Quantity | Specifications | Notes |
|-----------|----------|----------------|-------|
| Legacy EC2 Instance | 1 | Single instance, region unspecified, no HA | To be retired post-Phase 1 GA |
| Google Workspace Tenant | 1 | G Suite Business; Drive, Docs, Sheets, Slides | Templates exported to S3 in Phase 2 |
| Okta Tenant | 1 | ~50 active users; no admin group governance | Migrated to Cognito in Phase 1 |
| Manual Artifact Templates | ~20+ | Word (.docx), Excel (.xlsx), PowerPoint (.pptx) files | Ingested into pipeline in Phase 2 |

## Dependencies & Integration Points

The greenfield platform has three external integration points that must be resolved before go-live. These dependencies are identified here to ensure they are tracked on the project risk register and resolved within the timelines specified in the SOW.

- **Okta Directory Export:** The Security & Compliance Lead must provide a complete Okta user directory export (user attributes, group memberships) within two weeks of kickoff. This export is the input for the Cognito user pool population script.
- **Legacy Template Export:** The Head of Solutions must export all Word/Excel/PowerPoint artifact templates from Google Workspace by Month 2. These files are the input for the Phase 2 template ingestion pipeline.
- **AWS Bedrock Model Availability:** The VP Engineering must confirm that Amazon Bedrock Claude 3 Sonnet and Haiku are enabled in us-west-2 by Month 2. If unavailable, us-east-1 cross-region inference is the approved fallback per SOW Assumption 6.

## Network Topology

The current state has no defined network architecture relevant to the new platform. The legacy EC2 monolith operates in an unspecified VPC configuration that is not inherited by the greenfield serverless platform. The target-state network design is fully defined in Section 8 (Infrastructure & Operations).

## Security Posture

The current environment has several identified security and compliance gaps that the new platform is explicitly designed to close.

- **Identity Governance Gap:** Okta manages user identity without centralized usage governance, per-user limits, or admin controls aligned to AWS-native security patterns. Addressed by Cognito admin group governance in Phase 1.
- **Encryption Gap:** No evidence of KMS-managed encryption at rest on the legacy EC2 monolith or associated storage. The new platform enforces KMS CMK encryption on all S3 buckets and DynamoDB tables from day one.
- **Audit Logging Gap:** No CloudTrail equivalent in the current environment. AWS CloudTrail with S3 Object Lock (WORM) is enabled from the AWS landing zone setup in Month 2.
- **SOC 2 Readiness Gap:** The current environment lacks SOC 2 Type II controls, GDPR-aligned data handling, and US data residency enforcement. All five Trust Service Criteria controls are designed into the new platform from Phase 1.
- **Availability Gap:** The single EC2 monolith has no HA design. The serverless architecture (Lambda + API Gateway + DynamoDB) inherits AWS multi-AZ availability by default.

## Performance Baseline

The current manual artifact workflow provides the following performance baseline, against which the new platform's success criteria are measured.

- Average artifact cycle time: approximately 3 weeks (15 business days) from brief initiation to complete package
- Peak quarterly engagements handled: approximately 8 active proposals per quarter
- QA first-pass acceptance rate: variable — no formal measurement; estimated below 90% based on Head of Solutions feedback
- Platform availability: not formally measured; single EC2 monolith with no SLA commitment

## Gap Analysis

The gap analysis below maps each current-state limitation to its corresponding target-state resolution. Every gap identified here has a direct architectural component, security control, or operational mechanism in this design document.

<!-- TABLE_CONFIG: widths=[33, 34, 33] -->
| Current State | Gap | Target State |
|---------------|-----|--------------|
| 3-week manual artifact cycle | No automated generation; 100% human authoring | ≤2-day AI-powered pipeline via Bedrock + Step Functions |
| ~8 engagements/quarter max | Single-threaded manual throughput | ≥24 concurrent engagements via async SQS + Step Functions |
| Variable artifact quality | No quality standard enforcement | ≥90% QA first-pass rate via structured Bedrock prompts + validation layer |
| Okta IdP, no admin governance | No per-user usage limits or admin controls | Amazon Cognito with admin group, DynamoDB usage counters |
| No encryption at rest | Unencrypted EC2 storage | KMS CMK encryption on all S3 buckets and DynamoDB tables |
| No CloudTrail / audit log | No API call audit trail for SOC 2 | CloudTrail with S3 Object Lock, 7-year retention |
| No SOC 2 controls | Not enterprise-contract-ready | Five Trust Service Criteria controls from Phase 1 go-live |
| Single EC2, no HA | SPOF, no SLA | 99.9% serverless platform with Lambda + API Gateway + DynamoDB multi-AZ |
| Legacy Word/Excel/PPT templates | No pipeline integration | Template ingestion pipeline in Phase 2 (format-consistent output) |
| 30–60 min jobs timeout | Synchronous tooling drops long jobs | Step Functions durable state machine with SQS, retries, and DLQ |

---

# Solution Architecture

The Amatra Intelligent Solution Builder is a fully serverless, event-driven platform on AWS that ingests a structured client brief, orchestrates a multi-step AI generation pipeline via Amazon Bedrock, and produces a complete consulting engagement package. The architecture is organised into four logical layers: the **API & Auth Layer** handles all inbound requests from Amatra's internal users via Amazon API Gateway and enforces identity through Amazon Cognito; the **Orchestration Layer** manages long-running generation jobs via AWS Step Functions and Amazon SQS, ensuring reliability across 30–60 minute pipelines; the **AI Generation Layer** executes structured prompts against client brief inputs via Amazon Bedrock (Claude 3 Sonnet/Haiku) to produce artifact content; and the **Data & Storage Layer** tracks solution state and usage limits in Amazon DynamoDB and stores all generated artifacts in Amazon S3 with lifecycle management and presigned URL delivery.

The design philosophy prioritises operational simplicity, compliance by default, and alignment to the AWS Well-Architected Serverless Application Lens. Every component is a managed or serverless AWS service — there are no EC2 instances, containers, or Kubernetes clusters. All data is encrypted at rest using AWS KMS Customer Managed Keys and in transit via TLS 1.2+. The platform is deployed across three isolated environments (Dev, Staging, Production) using a GitHub Actions CI/CD pipeline with automated quality gates. The architecture is sized for the Medium-Large engagement tier: ~10M Bedrock input tokens/month, ~3M API Gateway requests/month, 100 GB S3 artifact storage, and up to 24 concurrent generation jobs.

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

**Figure 1: Amatra Intelligent Solution Builder Architecture** — End-to-end serverless AWS architecture showing the API & Auth Layer, Orchestration Layer, AI Generation Layer, and Data & Storage Layer, all deployed in us-west-2 with CloudWatch observability, WAF security controls, and GitHub Actions CI/CD pipeline.

## Architecture Principles

The following five principles guided every design decision in this document. Departures from any principle require an Architecture Decision Record (ADR) documenting the rationale and trade-offs.

- **Serverless by Default:** All compute is Lambda-based; all data stores are fully managed (DynamoDB, S3, Cognito). This eliminates EC2 fleet management overhead, inherits AWS multi-AZ availability, and reduces operational burden on Amatra's internal team post-handover. The only exception considered — ECS for Bedrock streaming — was rejected in favour of Lambda with Step Functions wait states.
- **Durable Async Orchestration:** Long-running generation jobs (30–60 minutes) must never be silently dropped. Step Functions state machines with built-in retry logic, error handling, and wait states — backed by SQS DLQs — ensure every job either completes successfully or fails with a traceable, recoverable error record.
- **Compliance by Design:** SOC 2 Type II controls and GDPR-aligned data handling are embedded from the first infrastructure commit, not retrofitted. CloudTrail with WORM, KMS CMK encryption, least-privilege IAM roles, and the GDPR data minimisation principle are architectural constraints, not optional add-ons.
- **Security in Depth:** Defence-in-depth is applied at every layer: WAF inspects inbound traffic before it reaches Lambda; Cognito validates JWT tokens before any handler logic executes; IAM permission boundaries prevent Lambda functions from exceeding their defined privilege scope; GuardDuty and Security Hub provide continuous threat detection and compliance monitoring.
- **Prompt-Driven Quality:** Artifact quality is determined primarily by the precision of the Bedrock prompt engineering framework, not by post-generation editing. Seven artifact-type-specific prompt templates, each with structured output schemas, token budgets, and quality rubrics, are maintained as versioned assets in the GitHub repository and updated iteratively based on QA pass-rate feedback from the validation layer.

## Architecture Patterns

The following patterns define the structural approach to the platform's major concerns. Each pattern choice was evaluated against alternatives and selected based on the constraints of the engagement.

- **Primary Pattern:** Serverless Event-Driven — API Gateway triggers Lambda for synchronous API responses; SQS + Step Functions manages async generation job lifecycle.
- **AI/ML Pattern:** Managed Foundation Model API — Amazon Bedrock with structured prompt templates per artifact type; no custom model training; prompt engineering as the primary quality lever.
- **Data Pattern:** Command-Query Responsibility Segregation (CQRS) light — write path (job submission → SQS → Step Functions → DynamoDB state write) is decoupled from read path (job-status poll → DynamoDB read → API response; artifact retrieval → S3 presigned URL).
- **Integration Pattern:** REST API Gateway with Cognito JWT authorisation; async SQS messaging for Bedrock invocation decoupling; S3 presigned URL for artifact delivery.
- **Deployment Pattern:** GitOps with blue-green Lambda alias promotion — GitHub Actions pipeline promotes Lambda deployment packages through Dev → Staging → Production using versioned function aliases; no in-place production updates.

## Component Design

The platform comprises six core AWS services and four supporting services, each with a discrete responsibility and defined interface contract. The table below summarises the full component inventory, their purposes, implementing technologies, dependencies, and scaling behaviour.

<!-- TABLE_CONFIG: widths=[18, 22, 20, 22, 18] -->
| Component | Purpose | Technology | Dependencies | Scaling |
|-----------|---------|------------|--------------|---------|
| API Handler Functions | Accept brief submissions, return job status, deliver artifact URLs, enforce usage limits | AWS Lambda (Python 3.12) | API Gateway, Cognito, DynamoDB, SQS | Auto-scales to 1,000 concurrent by default; provisioned concurrency on critical paths |
| Async Job Orchestrator | Durable 30–60 min generation workflow management, retry logic, error handling | AWS Step Functions (Standard) | Lambda, SQS, DynamoDB, Bedrock | Scales to 2,000 concurrent state machine executions per region |
| AI Generation Engine | Claude prompt execution, artifact content generation for all 7 artifact types | Amazon Bedrock (Claude 3 Sonnet / Haiku) | Lambda (invoker), S3 (output) | Bedrock managed; throttle via token budget; Haiku for low-latency types |
| Job Queue | Decouple API layer from Bedrock invocation; buffer job submissions | Amazon SQS (Standard Queue) | Lambda (consumer), Step Functions | Virtually unlimited queue depth; DLQ captures failed messages |
| Solution State & Usage Store | Track job status, artifact S3 keys, per-user and global monthly usage counters | Amazon DynamoDB (On-Demand) | Lambda, Step Functions | On-demand capacity scales automatically; PITR enabled |
| Artifact Storage | Store all generated artifacts (MD, CSV, DOCX, PPTX, PNG, Terraform) under structured key taxonomy | Amazon S3 | Lambda, Step Functions, end users (presigned URLs) | S3 managed; lifecycle rules archive to Glacier at 180 days |
| Identity & Auth | User authentication, JWT issuance, admin group governance, usage policy enforcement | Amazon Cognito User Pool | API Gateway (authorizer), Lambda | Scales to millions of MAUs; ~50 active users initially |
| API Gateway | Single HTTPS ingress for all platform traffic; request validation, throttling | Amazon API Gateway (REST) | Cognito (authorizer), Lambda, WAF | 10,000 RPS default; per-stage throttling configured |
| Secret Store | API keys, DynamoDB connection config, third-party credentials with automatic rotation | AWS Secrets Manager | Lambda | Managed; 10 secrets initially |
| Security Controls | WAF rule evaluation, GuardDuty threat detection, Security Hub aggregation, CloudTrail audit | AWS WAF, GuardDuty, Security Hub, CloudTrail | API Gateway (WAF), SNS (alerting) | Managed; scales with traffic and API call volume |

## Technology Stack

The technology stack is fixed to the services named in the SOW. The table below documents each stack layer, the specific service selected, and the rationale for its selection over alternatives.

<!-- TABLE_CONFIG: widths=[20, 30, 50] -->
| Layer | Technology | Rationale |
|-------|------------|-----------|
| AI / ML Generation | Amazon Bedrock — Claude 3 Sonnet (complex artifacts) / Claude 3 Haiku (lightweight artifacts) | Only managed FM API in AWS; Sonnet balances output quality and cost for detailed design/SOW types; Haiku reduces cost for simpler questionnaire types |
| Serverless Compute | AWS Lambda — Python 3.12, boto3 | Serverless eliminates EC2 management; Python 3.12 is the team's standard; Lambda natively integrates with all other platform services |
| API Management | Amazon API Gateway (REST API) + AWS WAF | REST API supports Lambda proxy integration and Cognito JWT authorisation natively; WAF provides L7 protection without additional infrastructure |
| Async Orchestration | AWS Step Functions (Standard Workflows) + Amazon SQS | Step Functions provides durable state management and built-in retry/error handling for 30–60 min jobs; SQS decouples API from Bedrock invocations and provides DLQ capability |
| Identity & Access | Amazon Cognito User Pool + IAM | Replaces Okta; native API Gateway JWT authorisation; admin group governance; per-user limit enforcement via DynamoDB; AWS-native security posture |
| Data / State | Amazon DynamoDB (On-Demand) | Sub-10ms latency at p99; on-demand capacity eliminates provisioned-capacity management; PITR supports ≤15-min RPO |
| Artifact Storage | Amazon S3 (Standard + Glacier lifecycle) | Cost-effective; structured key taxonomy; presigned URL delivery; versioning + Object Lock for WORM compliance; lifecycle to Glacier at 180 days |
| Secret Management | AWS Secrets Manager | Automatic rotation; native Lambda integration; KMS-encrypted; SOC 2 control requirement |
| Security & Compliance | AWS GuardDuty, Security Hub, CloudTrail, KMS, WAF | Full SOC 2 detective and preventative control set; all AWS-native; no third-party security tooling required |
| Monitoring & Observability | Amazon CloudWatch + Datadog APM | CloudWatch covers infrastructure metrics, logs, alarms, and SLA dashboards; Datadog APM provides Lambda cold-start profiling and Bedrock invocation latency histograms beyond CloudWatch capability |
| CI/CD | GitHub Actions + AWS CodeDeploy | GitOps model; Lambda alias promotion for blue-green deployments; manual approval gate in production workflow |
| Infrastructure as Code | AWS CloudFormation / SAM + Terraform | SAM for Lambda/API Gateway/Cognito resources; Terraform for the Terraform artifact generation deliverable (Deliverable #3 via pipeline) |
| Development | Python 3.12, AWS SDK (boto3) | Team standard; boto3 provides native access to all AWS services used in the platform |

---

# Security & Compliance

Security and compliance are first-class architectural constraints for the Amatra Intelligent Solution Builder — not features added after delivery. The platform is designed to satisfy SOC 2 Type II Trust Service Criteria from the first Phase 1 production deployment, with GDPR-aligned data handling and strict US data residency controls enforced at the infrastructure level. The security architecture implements defence-in-depth across four control layers: identity and access management, network perimeter controls, data protection, and continuous threat detection and response.

## Identity & Access Management

Amazon Cognito serves as the single identity provider for all platform users following the Okta-to-Cognito migration completed in Phase 1, Month 3. All ~50 active users are migrated with zero downtime; new users are onboarded directly to Cognito from Phase 1 go-live through General Availability (targeting all ~120 internal users by 31 January 2027).

- **Authentication:** Amazon Cognito User Pool issues JWT access tokens and ID tokens upon successful authentication. Tokens are validated natively by the API Gateway Cognito authoriser before any Lambda function is invoked, ensuring no unauthenticated request reaches platform logic.
- **Authorisation:** Role-based access control is enforced through Cognito User Pool Groups. Three groups are defined: `AmAdmin` (platform administrators with usage-limit override capability), `PreSales` (pre-sales consultants with access to Phase 1 artifact types), and `Delivery` (delivery consultants with access to all seven artifact types post-Phase 2).
- **MFA:** TOTP-based MFA is enforced for all users in the `AmAdmin` Cognito group. SMS-based MFA is offered as a fallback. MFA is strongly recommended but not mandatorily enforced for `PreSales` and `Delivery` groups in the MVP; mandatory enforcement is a Phase 3 hardening item.
- **Service Accounts:** No IAM user credentials are used by the platform. All Lambda-to-AWS-service calls use IAM role-based authentication. Each Lambda function has a dedicated execution role scoped to the minimum required permissions.

### Role Definitions

The following roles define the platform's access model. Each role maps to a Cognito group and a corresponding IAM policy boundary that governs the AWS resources accessible by that role's Lambda functions.

<!-- TABLE_CONFIG: widths=[22, 42, 36] -->
| Role | Permissions | Scope |
|------|-------------|-------|
| AmAdmin (Cognito Group) | Submit briefs, retrieve artifacts, override per-user limits, view usage dashboards, manage Cognito users | All artifact types; all environments (admin console) |
| PreSales (Cognito Group) | Submit briefs (Phase 1 artifact types), poll job status, retrieve artifacts via presigned URL | Discovery questionnaire, solution briefing, SoW, infrastructure cost model |
| Delivery (Cognito Group) | Submit briefs (all artifact types), poll job status, retrieve artifacts | All 7 artifact types post-Phase 2 |
| Lambda Execution Roles (IAM) | Least-privilege per function: scoped DynamoDB table access, scoped S3 bucket/prefix access, named Bedrock model ARNs, named SQS queues | Per-function resource boundaries; no wildcard resource policies |
| CI/CD Role (GitHub Actions OIDC) | Deploy Lambda packages, update CloudFormation stacks, create API Gateway deployments | Dev, Staging, Production with manual approval gate on Production |
| Auditor (read-only) | CloudTrail log read, CloudWatch metrics read, Security Hub finding read | All environments; read-only |

## Secrets Management

All credentials, API keys, and connection strings are stored in AWS Secrets Manager. No secrets are stored in environment variables, source code, or CloudFormation templates in plain text.

- Secrets are stored under a structured naming convention: `amatra/{environment}/{service}/{secret-name}` (e.g., `amatra/prod/bedrock/api-config`).
- Automatic rotation is enabled for all secrets that support AWS-managed rotation (RDS credentials, if applicable; third-party API keys use a custom Lambda rotation function).
- All secrets are encrypted using a dedicated KMS CMK: `amatra-secrets-manager-cmk`.
- Lambda functions access secrets via the Secrets Manager API at function initialisation (cached in memory for the function lifetime to minimise latency and API call costs). Secret access events are logged to CloudTrail.
- The 10 initial secrets cover: Bedrock API configuration, DynamoDB table names and region, S3 bucket names, Cognito User Pool ID and Client ID, GitHub Actions OIDC configuration, Datadog API key, and third-party integration credentials (if applicable in later phases).

## Network Security

The Amatra Intelligent Solution Builder is fully serverless and operates within the AWS managed network fabric. There are no VPCs, subnets, or NAT gateways required for the core Lambda and managed-service components. All inbound traffic enters through API Gateway over HTTPS; all inter-service traffic uses AWS service endpoints and remains within the AWS us-west-2 region.

- **Perimeter:** AWS WAF is attached to the API Gateway REST API stage. WAF enforces the AWS Managed Rule Group Core Rule Set (CRS) and Known Bad Inputs (KBI) rule group, plus custom rate-limiting rules that enforce per-user API call quotas (aligned to the Cognito group-level limits).
- **TLS Enforcement:** The API Gateway custom domain enforces a TLS 1.2+ security policy. The ACM-managed certificate auto-renews. HTTP (port 80) requests are rejected; HTTPS (port 443) only.
- **S3 Block Public Access:** S3 Block Public Access is enforced at the AWS account level. All artifact buckets are private; access is exclusively via IAM-authenticated Lambda calls or time-limited presigned URLs.
- **WAF Rules:** Rate limiting is set at 2,000 requests per 5-minute window per IP address (WAF rate-based rule). The CRS rule group blocks common web attack vectors (SQLi, XSS, path traversal). Custom rules block requests missing a valid Cognito-issued Authorization header before the Cognito authoriser layer.
- **DDoS Protection:** AWS Shield Standard is included with WAF at no additional cost and provides protection against common L3/L4 DDoS attacks. Shield Advanced is not in scope for the MVP but is recommended as a Phase 4 enhancement.

## Data Protection

All client brief inputs, generated artifacts, and platform telemetry are protected by encryption at rest and in transit. The following controls implement the data protection requirements from the SOW Security & Compliance section.

- **Encryption at Rest:** All S3 buckets use SSE-KMS with dedicated Customer Managed Keys. Unencrypted PutObject requests are denied by S3 bucket policy. DynamoDB tables are encrypted at rest using a dedicated KMS CMK. Secrets Manager uses a dedicated KMS CMK. Four separate CMKs are provisioned: `amatra-s3-artifacts-cmk`, `amatra-dynamodb-cmk`, `amatra-cloudtrail-cmk`, and `amatra-secrets-manager-cmk`. Annual automatic key rotation is enabled for all CMKs.
- **Encryption in Transit:** TLS 1.2+ is enforced on all API Gateway endpoints. Lambda-to-DynamoDB, Lambda-to-S3, Lambda-to-Bedrock, and Lambda-to-Step-Functions traffic uses HTTPS endpoints within the AWS network fabric.
- **Key Management:** All KMS CMK key policies restrict usage to named IAM roles and deny all other principals (including the AWS account root user for `amatra-cloudtrail-cmk`). Key usage is logged to CloudTrail.
- **Data Masking:** Non-production environments (Dev, Staging) use only synthetic or anonymised client briefs — no real client data. Masking is enforced by a policy documented in the Environment Strategy section and validated during UAT.

## Compliance Mappings

The following table maps the SOC 2 Trust Service Criteria to the specific platform controls that satisfy each requirement. This mapping forms the basis for the SOC 2 evidence package (Deliverable #16, Month 8, Week 2).

<!-- TABLE_CONFIG: widths=[22, 32, 46] -->
| Framework | Requirement | Implementation |
|-----------|-------------|----------------|
| SOC 2 — Security (CC6) | Logical and physical access controls | Cognito JWT auth on all API endpoints; IAM least-privilege Lambda roles; MFA for admin group; Cognito access reviews (quarterly) |
| SOC 2 — Security (CC7) | System operations — change management | GitOps CI/CD pipeline; no direct console changes to Production; all changes via pull request + manual approval gate; CloudTrail records all API changes |
| SOC 2 — Availability (A1) | System availability commitments | 99.9% SLA via serverless multi-AZ; CloudWatch availability alarms; RTO ≤1 hour; RPO ≤15 minutes via DynamoDB PITR |
| SOC 2 — Processing Integrity (PI1) | Complete and accurate processing | Step Functions durable state machine with retries; QA validation layer (≥90% first-pass); DLQ for failed jobs; job completion audit records in DynamoDB |
| SOC 2 — Confidentiality (C1) | Protection of confidential information | KMS CMK encryption at rest on all data stores; TLS 1.2+ in transit; S3 Block Public Access; IAM access policies; environment isolation |
| SOC 2 — Privacy (P1–P8) | GDPR-aligned data handling and privacy | Data processing register documented; data minimisation in client briefs; right-to-erasure via S3 lifecycle + DynamoDB TTL; US data residency via us-west-2 + SCP |
| GDPR — Article 25 | Data protection by design | US data residency enforced via AWS Org SCP; personal data only in us-west-2; S3 lifecycle right-to-erasure; DynamoDB TTL for user records |
| GDPR — Article 30 | Records of processing activities | Data processing register maintained; CloudTrail records all data access events; structured S3 key taxonomy enables data subject access requests |

## Audit Logging & SIEM Integration

CloudTrail is the primary audit logging mechanism. Management events and S3 data events (GetObject, PutObject, DeleteObject on the artifacts bucket) are captured across all API calls in the account. Logs are written to a dedicated, immutable S3 bucket (`amatra-cloudtrail-logs-prod`) with Object Lock (Compliance mode) and a 7-year retention policy. CloudTrail log file integrity validation is enabled to detect tampering.

AWS Security Hub aggregates findings from GuardDuty, AWS Config, and Inspector into a single dashboard, reviewed weekly by the Security & Compliance Lead. High-severity GuardDuty findings trigger automated Lambda-based remediation (e.g., Cognito user account suspension for credential-stuffing detection) and SNS notifications to the Security & Compliance Lead. A dedicated SIEM integration (via Security Hub EventBridge integration) is available as a Phase 4 enhancement if Amatra adopts a third-party SIEM. For the MVP, CloudWatch Log Insights and Security Hub serve as the primary investigation tools.

---

# Data Architecture

The data architecture for the Amatra Intelligent Solution Builder is designed around three core principles: data minimisation (store only what is necessary for generation and governance), strict residency enforcement (all data in us-west-2), and compliance-ready retention (lifecycle policies, WORM for audit logs, TTL for operational data). Two primary data stores underpin the platform — Amazon DynamoDB for solution state and usage governance, and Amazon S3 for artifact storage — supplemented by AWS Secrets Manager for credentials and CloudWatch Logs for operational telemetry.

## Data Model

### Conceptual Model

The platform's data domain is structured around three core entities: the **Solution** (representing a single client engagement package generation request), the **User** (an authenticated Amatra internal user), and the **Artifact** (a generated document or file produced by the Bedrock pipeline). Solutions contain one or more Artifacts. Users submit Solutions and are subject to usage limits tracked per user per calendar month.

### Logical Model

The following entities define the logical data model and map to the DynamoDB table schemas and S3 key taxonomy described in the Data Flow Design section.

<!-- TABLE_CONFIG: widths=[18, 32, 28, 22] -->
| Entity | Key Attributes | Relationships | Volume |
|--------|----------------|---------------|--------|
| Solution | solution_id (PK, UUID), user_id, status (PENDING / IN_PROGRESS / COMPLETE / FAILED), created_at, completed_at, brief_s3_key, artifact_type_list, metadata | 1 Solution → N Artifacts; 1 User → N Solutions | ~24 solutions/month; 288/year |
| Artifact | artifact_id (PK), solution_id (SK), artifact_type, s3_key, generation_duration_s, bedrock_tokens_used, qa_score, created_at | N Artifacts → 1 Solution | ~7 artifacts/solution; ~168/month |
| UsageCounter | user_id (PK), year_month (SK, e.g. "2026-09"), generation_count, token_count, last_updated | 1 UsageCounter per user per month | ~120 users × 12 months = ~1,440 records |
| GlobalUsageCounter | key="GLOBAL" (PK), year_month (SK), generation_count, token_count | Singleton global counter | 12 records/year |
| UserRecord | user_id (PK), cognito_sub, email, cognito_groups, monthly_limit, created_at, last_active | 1 UserRecord → N UsageCounters | ~120 records |

### DynamoDB Table Design

Two DynamoDB tables are provisioned on-demand capacity, with Global Secondary Indexes (GSIs) to support the access patterns required by the API layer.

**Table 1: `AmatraISB-SolutionState-{env}`**
- Partition Key: `solution_id` (String, UUID)
- Sort Key: `artifact_id` (String)
- GSI 1: `UserSolutionsIndex` — PK: `user_id`, SK: `created_at` (for listing a user's solutions)
- GSI 2: `StatusIndex` — PK: `status`, SK: `created_at` (for admin monitoring of in-flight jobs)
- TTL attribute: `expires_at` (365 days from creation for COMPLETE records; no TTL for FAILED records pending investigation)
- Encryption: KMS CMK (`amatra-dynamodb-cmk`)
- PITR: Enabled (35-day continuous backup window)

**Table 2: `AmatraISB-UsageTracking-{env}`**
- Partition Key: `user_id` (String)
- Sort Key: `year_month` (String, e.g. `"2026-09"`)
- TTL attribute: `expires_at` (365 days from record creation)
- Encryption: KMS CMK (`amatra-dynamodb-cmk`)
- PITR: Enabled

## Data Flow Design

The following describes how data moves through the platform from brief submission to artifact delivery. Each step is implemented as a Lambda function or Step Functions state machine task.

1. **Ingestion:** An authenticated user submits a structured client brief (JSON payload) via `POST /api/v1/solutions`. The API Handler Lambda validates the request schema, checks the UsageTracking table to enforce per-user monthly limits, writes a new SolutionState record (status: `PENDING`), and enqueues a job message to the primary SQS queue.
2. **Orchestration Start:** The Step Functions Initiator Lambda receives the SQS message, starts a new Standard Workflow execution, and updates the SolutionState record to `IN_PROGRESS`. The Step Functions state machine carries the `solution_id`, `user_id`, `artifact_type_list`, and `brief_s3_key` as execution input.
3. **Prompt Assembly:** For each artifact type in the list, a dedicated Prompt Assembly Lambda retrieves the client brief from S3, loads the artifact-type-specific prompt template from the prompt library (S3 versioned object), and assembles the final Bedrock prompt with the brief content injected into the template.
4. **Bedrock Invocation:** The Bedrock Invoker Lambda calls the Amazon Bedrock `InvokeModel` API with the assembled prompt and the appropriate Claude model (Sonnet for complex types; Haiku for lightweight types). Step Functions retries the task up to 3 times on `ThrottlingException` or `ServiceUnavailableException` with exponential backoff.
5. **Artifact Post-Processing:** The generated markdown or CSV content from Bedrock is passed to the Artifact Processor Lambda, which applies format validation, enforces required section structure, and (in Phase 2) scores the artifact against the QA rubric. If the QA score falls below the 90% threshold, the artifact is flagged for human review rather than rejected.
6. **S3 Write:** The processed artifact is written to S3 under the key `{solution_id}/raw/{phase}/{artifact_type}/{filename}`. The S3 key is recorded in the SolutionState DynamoDB record.
7. **Distribution:** Upon completion of all artifact types in the solution, the Step Functions state machine updates the SolutionState record to `COMPLETE`. The client polls `GET /api/v1/solutions/{solution_id}/status` and retrieves artifact download links via `GET /api/v1/solutions/{solution_id}/artifacts/{artifact_type}`, which returns a time-limited S3 presigned URL (valid for 24 hours).

## Data Migration Strategy

No bulk data migration of historical engagement artifacts is in scope for this engagement (explicitly excluded from the SOW). The only data migration activities are:

- **Okta-to-Cognito User Migration (Phase 1, Month 3):** User records (email, display name, group memberships) are exported from Okta as a JSON file by the Security & Compliance Lead, imported into the Cognito User Pool via the `AdminCreateUser` API using a one-time migration Lambda function, and validated by confirming all users can authenticate. Temporary passwords are issued and users are prompted to set new passwords on first login. Zero-downtime is maintained by running Cognito and Okta in parallel for a two-week overlap period before Okta is decommissioned.
- **Legacy Template Pipeline (Phase 2, Month 6):** Word, Excel, and PowerPoint templates are exported from Google Workspace, uploaded to S3 under `templates/legacy/{artifact_type}/`, and processed by the Template Ingestion Lambda to extract structure and formatting rules that are encoded into the Bedrock prompt templates.

## Data Governance

The following governance policies apply to all data stored within the platform and are enforced by a combination of S3 lifecycle rules, DynamoDB TTL, IAM policies, and documented operational procedures.

- **Classification:** Three data tiers — (1) Client Brief Inputs (confidential, US-resident, GDPR-applicable); (2) Generated Artifacts (confidential, US-resident); (3) Platform Telemetry (internal operational data, US-resident). Each tier has a defined retention policy and access control set.
- **Retention:** Generated artifacts are retained in S3 Standard for 180 days, then transitioned to S3 Glacier Flexible Retrieval for long-term archival. CloudTrail audit logs are retained for 7 years (Object Lock, WORM). DynamoDB SolutionState records have a 365-day TTL; UsageTracking records have a 365-day TTL.
- **Quality:** Bedrock output is validated by the Artifact Processor Lambda against a required-section checklist (artifact-type-specific). The Phase 2 QA validation layer adds automated scoring against a weighted quality rubric. Artifacts scoring below 90% are flagged in the DynamoDB SolutionState record with a `qa_status: REVIEW_REQUIRED` field.
- **Access:** S3 artifact access is exclusively via IAM-authenticated Lambda calls (for writes) or time-limited presigned URLs (for end-user reads). Direct S3 console access to the artifacts bucket is blocked by IAM policy for all roles except the Amatra VP Engineering break-glass role. All S3 data events are logged to CloudTrail.
- **Right to Erasure (GDPR):** User-linked data (client briefs containing personal information, SolutionState records linked to a user_id) can be erased on request via an administrative Lambda function that: (1) deletes the S3 objects at the user's solution keys, (2) deletes the DynamoDB SolutionState and UsageTracking records for the user, and (3) deletes the Cognito UserRecord. S3 versioning ensures that object deletion is captured in the version history for audit purposes.

---

# Integration Design

The Amatra Intelligent Solution Builder integrates with three external systems: Amazon Bedrock (Claude 3 Sonnet/Haiku) as the AI generation engine, the legacy Okta tenant for the one-time identity migration, and Google Workspace for the legacy template export pipeline. All other platform component interactions are internal AWS service-to-service calls within the us-west-2 region. The integration architecture prioritises loose coupling, retry resilience, and clear error boundaries, ensuring that failures in any single integration do not silently propagate to the end user or corrupt platform state.

## External System Integrations

The following table defines all external integration points, their protocols, data formats, error handling strategies, and SLA commitments. All integrations operate within the us-west-2 region to satisfy the US data residency requirement.

<!-- TABLE_CONFIG: widths=[18, 14, 14, 12, 26, 16] -->
| System | Type | Protocol | Format | Error Handling | SLA |
|--------|------|----------|--------|----------------|-----|
| Amazon Bedrock (Claude 3 Sonnet) | Real-time (async) | HTTPS (AWS SDK) | JSON (request) / Text (response) | Step Functions retry (3× exp backoff on ThrottlingException); DLQ for persistent failures | Bedrock SLA; ≤60 min job completion |
| Amazon Bedrock (Claude 3 Haiku) | Real-time (async) | HTTPS (AWS SDK) | JSON (request) / Text (response) | Same as Sonnet; Haiku used for lower-cost artifact types | Bedrock SLA; ≤30 min |
| Okta (migration only) | One-time batch | Okta API (REST/JSON) | JSON (user records export) | Manual retry with rollback plan; 2-week parallel run period | N/A — one-time event |
| Google Workspace (Phase 2 template export) | One-time batch | Google Drive API / file export | DOCX, XLSX, PPTX | Manual export, upload to S3, validation Lambda; retry on parse failure | N/A — one-time event |
| Datadog APM | Continuous async | HTTPS (Datadog Agent / Lambda layer) | JSON (metrics, traces) | Fire-and-forget; platform does not depend on Datadog availability | Best-effort observability |

## API Design

The platform exposes a REST API through Amazon API Gateway. All endpoints require a valid Cognito JWT bearer token. The API is versioned at the URL path level (`/api/v1/`) to support non-breaking evolution. Rate limiting is enforced at both the WAF layer (per-IP) and the API Gateway usage plan layer (per-Cognito-authenticated user).

- **Style:** REST (JSON request/response bodies)
- **Versioning:** URL path versioning (`/api/v1/`); breaking changes introduce `/api/v2/` with a deprecation notice period
- **Authentication:** Bearer token (Cognito-issued JWT) in the `Authorization` header; validated by API Gateway Cognito authoriser
- **Rate Limiting:** 100 requests/minute per authenticated user (API Gateway usage plan); 2,000 requests per 5 minutes per IP (WAF rate-based rule)
- **Throttling:** API Gateway stage-level throttling at 500 RPS burst / 200 RPS steady-state (aligned to Lambda concurrency reserve)

### API Endpoints

The following endpoints constitute the complete Platform API surface. All endpoints return `application/json` and follow RFC 7807 (Problem Details) for error responses.

<!-- TABLE_CONFIG: widths=[8, 36, 16, 40] -->
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | /api/v1/solutions | Bearer (PreSales / Delivery / AmAdmin) | Submit a new client brief and initiate artifact generation pipeline |
| GET | /api/v1/solutions/{solution_id}/status | Bearer (owner or AmAdmin) | Poll async job status (PENDING / IN_PROGRESS / COMPLETE / FAILED) |
| GET | /api/v1/solutions/{solution_id}/artifacts | Bearer (owner or AmAdmin) | List all artifact types and their availability for a given solution |
| GET | /api/v1/solutions/{solution_id}/artifacts/{type} | Bearer (owner or AmAdmin) | Retrieve a 24-hour presigned S3 URL for a specific artifact type |
| GET | /api/v1/solutions | Bearer (AmAdmin) | Admin: list all solutions with status, user, and timestamp filters |
| GET | /api/v1/usage/me | Bearer (all) | Retrieve current user's monthly generation count vs. limit |
| GET | /api/v1/usage/users/{user_id} | Bearer (AmAdmin) | Admin: retrieve usage metrics for a specific user |
| PUT | /api/v1/usage/users/{user_id}/limit | Bearer (AmAdmin) | Admin: override per-user monthly generation limit |
| GET | /api/v1/health | No auth | API Gateway health check endpoint (used by CloudWatch availability alarm) |

## Authentication & SSO Flows

The authentication flow is designed to be transparent to end users while providing strong security guarantees at the API layer.

- **User Login:** Users authenticate via the Amazon Cognito Hosted UI (or a custom login page in Phase 3) using their migrated credentials. Cognito issues a JWT access token (15-minute expiry) and a refresh token (30-day expiry). The access token is included in all API requests as a Bearer token.
- **API Gateway Validation:** The API Gateway Cognito authoriser validates the JWT token's signature, expiry, and issuer on every request. Invalid or expired tokens receive an HTTP 401 response. Token refresh is the responsibility of the client (browser or CLI tool).
- **Admin Group Enforcement:** The Cognito authoriser Lambda (a custom authoriser wrapping the native Cognito authoriser) inspects the `cognito:groups` claim in the JWT to enforce endpoint-level RBAC. `GET /api/v1/solutions` (list all) and `PUT /api/v1/usage/users/{user_id}/limit` require the `AmAdmin` group claim.
- **Service-to-Service Auth:** All Lambda-to-AWS-service calls use IAM role-based authentication via the Lambda execution role. No service-to-service JWT tokens are used. AWS SigV4 request signing is handled transparently by the AWS SDK (boto3).

## Messaging & Event Patterns

The asynchronous messaging architecture is the critical reliability mechanism that enables 30–60 minute generation jobs to complete without risk of Lambda timeout or dropped work.

- **Primary Queue:** `amatra-job-queue-{env}` — Standard SQS queue. Receives job initiation messages from the API Handler Lambda after initial validation and SolutionState creation. Visibility timeout is set to 5 minutes (for the Step Functions Initiator Lambda to consume and start execution). Message retention is 4 days.
- **Dead Letter Queue (DLQ):** `amatra-job-dlq-{env}` — Messages that fail to be processed after 3 receive attempts are moved to the DLQ. An SNS alarm triggers a P1 alert to the on-call engineer when the DLQ depth exceeds 0 messages. DLQ messages are investigated and replayed manually or via a replay Lambda.
- **Step Functions — Internal Events:** The Step Functions state machine uses internal `TaskToken` callbacks for long-running Bedrock invocation tasks, preventing Lambda from blocking for the full 30–60 minute duration. The Bedrock Invoker Lambda invokes Bedrock asynchronously and writes the result back to Step Functions via `SendTaskSuccess` / `SendTaskFailure`.
- **Event Bus (Future):** Amazon EventBridge is noted as a Phase 4 enhancement for publishing solution-complete events to downstream consumers (e.g., a notification service). Not in MVP scope.
- **Retry Policy:** Step Functions retries Bedrock invocation tasks up to 3 times on `ThrottlingException` (interval: 30 seconds, backoff rate: 2, max attempts: 3). After 3 failures, the task transitions to a `Catch` handler that marks the SolutionState as `FAILED` and triggers an SNS P1 alert.

---

# Infrastructure & Operations

The Amatra Intelligent Solution Builder is a fully serverless platform — there are no EC2 instances, load balancers, or VPCs to provision or manage. The infrastructure footprint is entirely composed of managed AWS services, which inherit AWS's multi-AZ availability architecture by default and scale automatically with demand. This section defines the network boundary, compute sizing, HA design, DR targets, monitoring configuration, and cost model for the production environment in us-west-2.

## Network Design

The platform operates within the AWS managed network fabric. All inbound traffic enters through the API Gateway HTTPS endpoint; all inter-service traffic uses AWS service endpoints within the us-west-2 region. No custom VPC, subnet, or NAT gateway configuration is required for the core Lambda and managed-service components.

- **API Gateway Custom Domain:** `api.amatra-isb.internal` (or equivalent internal domain) with an ACM-managed TLS certificate. HTTP (port 80) requests are redirected to HTTPS (port 443). TLS 1.2+ security policy enforced.
- **WAF Attachment:** AWS WAF WebACL attached to the API Gateway REST API stage. Managed Rule Groups: Core Rule Set (CRS), Known Bad Inputs (KBI). Custom rate-limiting rule: 2,000 requests per 5-minute window per IP. All WAF rule evaluations are logged to CloudWatch Logs.
- **S3 Access:** S3 Block Public Access enforced at the AWS account level. All S3 bucket access is via Lambda IAM roles (internal) or presigned URLs (external, time-limited). No public S3 endpoints.
- **Data Residency:** All AWS services are explicitly provisioned in us-west-2. An AWS Organizations Service Control Policy (SCP) on the production account blocks all S3 replication, DynamoDB global table replication, and new service deployments outside us-east-1 and us-west-2.
- **Egress:** ~200 GB/month artifact download egress from S3 to end users via presigned URLs over HTTPS. No VPN or Direct Connect is required; users access the platform via the public internet through API Gateway and S3.

## Compute Sizing

The following Lambda function sizing is derived from the LOE estimate's performance benchmark targets and the expected workload profile (up to 24 concurrent generation jobs, ~2M Lambda invocations/month). All functions are deployed with per-environment aliases; provisioned concurrency is applied to the latency-sensitive API Handler functions to mitigate cold-start impact on the ≤500 ms p99 API response target.

<!-- TABLE_CONFIG: widths=[28, 22, 10, 14, 14, 12] -->
| Component | Function Name | Memory | Timeout | Provisioned Concurrency | Count |
|-----------|---------------|--------|---------|------------------------|-------|
| API Handler — Submit Brief | `isb-api-submit` | 512 MB | 30 s | 5 (prod) | 1 |
| API Handler — Poll Status | `isb-api-status` | 256 MB | 10 s | 5 (prod) | 1 |
| API Handler — Retrieve Artifact | `isb-api-retrieve` | 256 MB | 10 s | 3 (prod) | 1 |
| API Handler — Admin Controls | `isb-api-admin` | 256 MB | 30 s | 2 (prod) | 1 |
| Step Functions Initiator | `isb-orchestrator-start` | 512 MB | 60 s | 0 | 1 |
| Prompt Assembly | `isb-prompt-assembly` | 512 MB | 120 s | 0 | 1 per artifact type (7) |
| Bedrock Invoker (Sonnet) | `isb-bedrock-sonnet` | 1024 MB | 900 s | 0 | 1 |
| Bedrock Invoker (Haiku) | `isb-bedrock-haiku` | 512 MB | 600 s | 0 | 1 |
| Artifact Processor / QA | `isb-artifact-processor` | 512 MB | 300 s | 0 | 1 |
| Template Ingestion (Phase 2) | `isb-template-ingest` | 1024 MB | 900 s | 0 | 1 |
| Okta Migration (Phase 1 one-off) | `isb-okta-migrate` | 512 MB | 300 s | 0 | 1 |

## High Availability Design

The serverless architecture inherits AWS multi-AZ availability by default. Lambda, API Gateway, DynamoDB, S3, Cognito, SQS, and Step Functions are all multi-AZ managed services. No additional HA configuration is required beyond the following platform-specific settings:

- **DynamoDB:** On-demand capacity mode prevents capacity-throttling-induced unavailability. PITR is enabled on both tables for continuous backup. DynamoDB is inherently replicated across three Availability Zones within us-west-2.
- **S3:** Standard storage class provides 99.99% availability and 11 nines durability via automatic multi-AZ replication within us-west-2. Versioning is enabled on the artifacts bucket to protect against accidental deletion.
- **Lambda:** Reserved concurrency is set to 500 for the total platform to prevent runaway invocations from consuming the full account concurrency limit and starving other functions. Per-function concurrency limits are set based on the compute sizing table above.
- **API Gateway:** CloudWatch alarms monitor the 5xx error rate on the API Gateway stage; a rate above 1% over 15 minutes triggers a P2 alert.
- **Health Checks:** CloudWatch Synthetics canary pings `GET /api/v1/health` every 60 seconds from within us-west-2 to provide the primary availability SLA measurement signal.

## Disaster Recovery

The DR strategy is designed to meet the RPO ≤15 minutes and RTO ≤1 hour targets defined in the SOW Success Metrics and Business Context sections. The fully serverless architecture means most recovery scenarios involve data restoration rather than infrastructure reprovisioning.

- **RPO ≤15 minutes:** DynamoDB Point-in-Time Recovery (PITR) provides continuous backups with 35-day recovery window and minute-level granularity. S3 versioning provides point-in-time object recovery. Lambda function code is stored in GitHub (source of truth) and in S3 deployment buckets; redeployment from either source takes ≤10 minutes.
- **RTO ≤1 hour:** Lambda and API Gateway auto-recover without intervention following AWS-side service disruptions (covered by AWS SLA). DynamoDB PITR restore to a new table takes approximately 15–30 minutes for the expected data volumes. S3 versioned object recovery is immediate. Cognito User Pool is backed up nightly via a scheduled Lambda that exports user attributes to an encrypted S3 bucket; restore from backup takes ≤30 minutes for ~120 users.
- **Backup:** DynamoDB PITR enabled on both tables (35-day window). S3 versioning enabled on artifacts bucket. Cognito user pool nightly export to S3 (encrypted with `amatra-s3-artifacts-cmk`). Step Functions execution history retained for 90 days. CloudTrail logs retained 7 years (Object Lock).
- **DR Test:** DR testing is performed in the Staging environment at Phase 1 and Phase 2 go-live gates. Tests include: DynamoDB PITR point-in-time restore to a specific timestamp, S3 versioned object recovery, Step Functions state machine failure injection (Bedrock API throttling and Lambda timeout simulation) with retry-and-resume validation, and Cognito user pool backup restore drill.

## Monitoring & Alerting

The observability stack combines Amazon CloudWatch (primary) and Datadog APM (supplementary cold-start and Bedrock latency profiling). All Lambda logs use structured JSON formatting for CloudWatch Log Insights query efficiency.

- **Infrastructure Monitoring:** Lambda invocation count, error rate, duration (p50/p95/p99), cold-start rate, concurrency utilisation, and throttle count. DynamoDB read/write capacity utilisation, throttle events, and system errors. SQS queue depth, number of messages sent/received, DLQ depth. API Gateway request count, 4xx/5xx error rates, latency (p50/p99).
- **Application Monitoring:** Step Functions execution success rate, execution duration, failed state transitions. Bedrock invocation latency (via Datadog APM), token consumption vs. monthly budget. S3 PutObject/GetObject latency and error rates. Cognito authentication success/failure rates, active user sessions.
- **Business KPI Monitoring:** Async job completion rate (target: >99% of submitted jobs complete within 60 minutes). QA validation layer first-pass acceptance rate (target: ≥90%). Monthly active users vs. licensed users. Per-user and global generation count vs. monthly limit.
- **Alerting Integration:** All CloudWatch alarms route to an SNS topic (`amatra-isb-alerts-prod`). SNS subscriptions: PagerDuty (P1), Slack `#amatra-isb-ops` channel (P2), email to Head of Solutions (P3 token budget alerts).

### Alert Definitions

The following table defines the primary production alerts. All alerts are configured in CloudWatch Alarms with the specified evaluation periods and thresholds.

<!-- TABLE_CONFIG: widths=[28, 26, 12, 34] -->
| Alert | Condition | Severity | Response |
|-------|-----------|----------|----------|
| Platform Availability Degraded | `GET /api/v1/health` success rate < 99.9% over 5 min | P1 | PagerDuty page to on-call engineer; escalate to VP Engineering if not resolved in 30 min |
| Async Job Failure Rate High | Step Functions execution failure rate > 5% over 5 min | P1 | PagerDuty page; investigate DLQ depth; check Bedrock throttling; initiate runbook |
| DLQ Message Received | SQS DLQ depth > 0 messages | P1 | Immediate investigation; replay or triage failed job; SNS + PagerDuty |
| API Gateway 5xx Error Rate High | API Gateway 5xx rate > 1% over 15 min | P2 | Slack alert to VP Engineering; investigate Lambda errors; check CloudTrail |
| Lambda Error Rate High | Any platform Lambda error rate > 2% over 10 min | P2 | Slack alert; investigate function logs in CloudWatch Log Insights |
| Bedrock Token Budget Warning | Monthly Bedrock token consumption > 80% of budget | P3 | Email to Head of Solutions; review generation volumes; consider Haiku substitution |
| Cognito Auth Failure Rate High | Cognito authentication failures > 10% over 5 min | P2 | Slack alert; check GuardDuty for credential-stuffing; consider account lockout |
| GuardDuty High Severity Finding | GuardDuty finding severity ≥ HIGH | P1 | SNS to Security & Compliance Lead; automated Lambda remediation triggered |
| CloudWatch Alarm: DynamoDB Throttle | DynamoDB throttle events > 0 over 5 min | P2 | Slack alert; verify on-demand capacity scaling; check request patterns |

## Logging & Observability

All Lambda function logs are emitted in structured JSON format and flow to CloudWatch Log Groups with a 90-day retention policy. Log group naming convention: `/aws/lambda/amatra-isb-{function-name}-{env}`.

Datadog APM is deployed as a Lambda layer on all functions, providing distributed tracing across the full request lifecycle (API Gateway → Lambda API Handler → SQS → Step Functions → Lambda Bedrock Invoker → S3). Bedrock invocation latency histograms and Lambda cold-start profiling are captured in Datadog for performance optimisation during Phase 3. CloudWatch dashboards provide the primary SLA visibility layer for the Amatra VP Engineering team.

Three CloudWatch dashboards are delivered as part of the platform:
1. **Operations Dashboard:** Real-time async job queue depth, active Step Functions executions, Lambda error rates, API Gateway latency, DLQ depth.
2. **SLA & Availability Dashboard:** Monthly availability percentage (vs. 99.9% target), job completion rate (vs. >99% target), average and p95 job completion time (vs. ≤60 min target).
3. **Quality & Usage Dashboard:** QA first-pass acceptance rate (vs. ≥90% target), monthly generation count vs. limit (global and per-user), Bedrock token consumption vs. budget, artifact type distribution.

## Cost Model

The following infrastructure cost model is sourced from the infrastructure-costs.csv 3-year summary and represents the steady-state monthly cloud infrastructure spend for the platform in the Medium-Large tier. Professional services costs are excluded (Year 1 only; see SOW Investment Summary). AWS partner credits of $8,000 are applied in Year 1 to reduce the net infrastructure cost.

<!-- TABLE_CONFIG: widths=[32, 22, 22, 24] -->
| Category | Monthly Estimate | Annual Estimate | Optimisation Notes |
|----------|------------------|-----------------|-------------------|
| Amazon Bedrock (Claude 3 Sonnet/Haiku) | $825 | $9,900 | Substitute Haiku for simpler artifact types (discovery questionnaire) to reduce Sonnet token costs by ~20% |
| AWS Lambda (~2M invocations/month) | $200 | $2,400 | Provisioned concurrency on API Handler functions only; Step Functions/Bedrock functions on-demand |
| Amazon API Gateway (~3M requests/month) | $105 | $1,260 | REST API; consider HTTP API migration in Phase 3 for ~70% cost reduction on non-Cognito endpoints |
| Data Transfer Out (~200 GB/month) | $180 | $2,160 | S3 presigned URL delivery; CloudFront (Phase 4) would reduce egress costs by ~60% |
| Amazon CloudWatch (20 GB logs/month) | $85 | $1,020 | Structured JSON logs reduce average log size; Log Insights queries reduce need for dedicated log analytics |
| AWS WAF | $35 | $420 | Fixed cost; no optimisation opportunity without reducing rule coverage |
| Amazon DynamoDB (on-demand) | $25 | $300 | On-demand scales to zero; actual cost likely $10–$20/month at current volumes |
| Amazon S3 (100 GB storage + operations) | $12 | $138 | Lifecycle to Glacier at 180 days reduces long-term storage cost by ~80% |
| Amazon Cognito (~50 MAU initial) | $5.50 | $66 | Free tier covers first 50K MAUs; minimal cost until GA scale |
| Amazon SQS, Secrets Manager, CloudTrail, Route 53 | $24.50 | $294 | Minimal costs; no significant optimisation opportunity |
| AWS Business Support (~10% of spend) | $345 | $4,140 | Required for 99.9% SLA; 1-hour critical response time |
| **Total Infrastructure (excl. support)** | **$1,497** | **$17,960** | — |
| **Total including AWS Business Support** | **$1,842** | **$22,100** | $8,000 in Year 1 AWS partner credits reduce Year 1 net to ~$14,100 |

---

# Implementation Approach

The implementation is structured as a three-phase delivery aligned to the SOW's milestone schedule. Each phase builds on the previous and is gated by a formal CTO phase-gate approval before the next phase of work and expenditure is authorised. The overall deployment strategy uses GitOps with Lambda alias-based blue-green promotion, ensuring every production change is traceable to a pull request, peer-reviewed, and automatically tested before reaching end users.

## Migration/Deployment Strategy

The Amatra Intelligent Solution Builder is a greenfield implementation with no existing production platform to migrate away from. The deployment strategy is therefore focused on progressive build-and-validate rather than migration risk management.

- **Approach:** Phased greenfield build — Phase 1 MVP establishes foundation and pre-sales pipeline; Phase 2 extends to full delivery pipeline and template ingestion; Phase 3 achieves General Availability.
- **Pattern:** Blue-green Lambda alias promotion — Lambda function versions are deployed as numbered releases; production aliases (`$PROD`) are updated to point to new versions only after Staging validation. Rollback is a single alias update to the prior version.
- **Validation:** Functional testing → integration testing → performance testing → security testing → UAT at each phase gate before production promotion.
- **Rollback:** Lambda alias revert via a single GitHub Actions workflow step (automated). Target rollback time: ≤30 minutes. Rollback decision authority: vendor Project Manager in consultation with Amatra VP Engineering.

## Sequencing & Wave Planning

The following table defines the five implementation phases within the 12-month engagement, aligned to the SOW Deliverables & Timeline section.

<!-- TABLE_CONFIG: widths=[8, 32, 18, 42] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| Phase 1a: Foundation | AWS landing zone setup, IAM roles/policies, CloudTrail, AWS Config, GitHub Actions CI/CD pipeline, DynamoDB tables, S3 buckets, KMS CMKs | Months 1–2 | AWS landing zone operational in Dev/Staging; CI/CD pipeline deploying to all three environments; CloudTrail active |
| Phase 1b: Core Platform | Cognito user pool, Okta migration, API Gateway + Lambda API layer, SQS queues, Step Functions state machine, Bedrock integration layer (Phase 1 artifact types), security hardening (WAF, GuardDuty, Security Hub) | Months 2–3 | Okta migration complete; end-to-end brief-to-artifact pipeline functional in Staging for Phase 1 artifact types |
| Phase 1c: MVP Go-Live | Phase 1 functional, integration, performance, and security testing; UAT with Head of Solutions and pre-sales consultants; production deployment; pre-sales consultant training | Month 4 (target: 30 Sep 2026) | CTO phase-gate approval; ≥90% UAT acceptance; zero P1 defects; production deployment confirmed |
| Phase 2: Delivery Pipeline | Legacy template ingestion pipeline, delivery artifact pipeline (detailed design, implementation guide, Terraform scripts), QA validation layer, per-user/global usage limit UI controls, Phase 2 SOC 2 controls evidence, compliance validation, delivery team UAT | Months 5–8 (target: 15 Dec 2026) | All 7 artifact types operational in production; QA validation layer active; SOC 2 evidence package delivered; CTO phase-gate approval |
| Phase 3: GA & Optimisation | GA rollout plan, all ~120 user onboarding, Bedrock prompt optimisation, Lambda cold-start tuning, DynamoDB capacity planning optimisation, train-the-trainer, Phase 1 8-week hypercare completion, Phase 2 4-week hypercare, final SOC 2 evidence package, project closeout | Months 9–12 (target: 31 Jan 2027 GA) | All 120 users onboarded and authenticated; QA pass rate ≥90% in production; optimisation report delivered; CTO project close sign-off |

## Tooling & Automation

The following tools and frameworks support the full implementation lifecycle from infrastructure provisioning through AI generation, security monitoring, and CI/CD delivery. All tools are consistent with the SOW Tooling Overview table.

<!-- TABLE_CONFIG: widths=[28, 32, 40] -->
| Category | Tool | Purpose |
|----------|------|---------|
| Infrastructure as Code | AWS CloudFormation / SAM | Provision Lambda functions, API Gateway, Cognito User Pool, DynamoDB tables, S3 buckets, SQS queues, Step Functions state machines, KMS CMKs |
| Infrastructure as Code (Terraform artifact) | HashiCorp Terraform | Platform reprovisioning scripts delivered as Deliverable #3 artifact type in the generation pipeline; also used for CI/CD pipeline infrastructure |
| CI/CD | GitHub Actions | Multi-environment automated deployment pipeline; OIDC integration with AWS IAM; manual approval gate on production deployments; dependency scanning for Lambda layers |
| Security Scanning | Amazon Inspector + GitHub Actions dependency scan | Lambda function dependency vulnerability scanning; P1/P2 findings block production deployment gate |
| Configuration Management | AWS Systems Manager Parameter Store | Environment-specific non-secret configuration values (DynamoDB table names, S3 bucket names, Bedrock model IDs) |
| Secret Management | AWS Secrets Manager | All credentials and API keys; automatic rotation; KMS encryption |
| Testing Framework | pytest (Python), AWS Step Functions Local | Unit and integration testing for Lambda functions; Step Functions local emulation for state machine testing |
| Performance Testing | Locust (Python) | Load testing at 2× expected peak concurrency in Staging environment to validate 24 concurrent engagement target |
| Monitoring & Observability | Amazon CloudWatch + Datadog APM | CloudWatch for infrastructure metrics, logs, alarms, and SLA dashboards; Datadog for Lambda cold-start profiling and Bedrock invocation latency |
| Artifact Generation | AWS SDK (boto3) + Amazon Bedrock | Python Lambda functions invoking Bedrock Claude API with structured prompt templates per artifact type |

## Cutover Approach

Two production cutovers are planned, corresponding to Phase 1 MVP (30 September 2026) and Phase 2 Full Pipeline (15 December 2026). Each cutover follows the same sequence of steps with phase-specific additions.

**Phase 1 Cutover (30 September 2026):**
- Final Staging smoke test: submit three representative client briefs and confirm all four Phase 1 artifact types are generated correctly.
- Cognito production user pool activated; all migrated users receive temporary-password reset email.
- DNS update: API Gateway custom domain pointed to production stage.
- Lambda `$PROD` aliases updated to latest Phase 1 verified deployment package.
- CloudWatch alarms and Synthetics canary confirmed active in production.
- WAF rules validated against production traffic patterns.
- Communication sent to all pre-sales consultants: platform live, training sessions scheduled.
- Monitor async job completion rate, error rate, and Bedrock token consumption for 24 hours post-cutover.

**Phase 2 Cutover (15 December 2026):**
- Phase 2 delivery pipeline Staging smoke test: all seven artifact types generated successfully.
- QA validation layer activated in production; pass-rate dashboard live.
- Delivery team notified; Phase 2 training sessions scheduled and calendar invites sent.
- Monitor QA pass-rate metrics, template pipeline output quality, and DLQ depth for 48 hours post-cutover.

## Downtime Expectations

The serverless architecture is designed for zero-downtime deployments. Lambda alias promotion does not interrupt in-flight requests; API Gateway continues serving from the previous alias until the new alias is confirmed healthy.

- **Planned Downtime:** Zero for Lambda function updates (alias promotion). API Gateway stage deployments are instantaneous. Cognito configuration updates require a brief (<1 minute) propagation period but do not interrupt active sessions.
- **Unplanned Downtime:** Target MTTR of ≤1 hour (RTO). AWS service-layer outages are covered by the AWS SLA and are not within the platform team's control.
- **Cutover Downtime:** The Okta-to-Cognito migration (Phase 1, Month 3) requires a two-week parallel-run period. Users may need to re-authenticate once when the Cognito pool is activated in production, but no platform downtime occurs. DNS TTL is set to 60 seconds pre-cutover to enable rapid re-pointing if needed.

## Rollback Strategy

Rollback capability is available for both Phase 1 and Phase 2 cutovers, with pre-defined triggers and a target execution time of ≤30 minutes.

- **Rollback Triggers:** Initiated if any of the following occur within 4 hours of cutover: async job failure rate >20%, API Gateway 5xx error rate >5%, Cognito authentication failure rate >10%, or data integrity issue detected in S3 artifacts.
- **Infrastructure Rollback:** Lambda function aliases are reverted to the prior verified deployment package via a single `Rollback` workflow in GitHub Actions (single click; automated). This is the fastest and lowest-risk rollback mechanism.
- **Application Rollback:** API Gateway stage is rolled back to the previous deployment via the same GitHub Actions workflow.
- **Database Rollback:** DynamoDB schema changes are additive (new GSIs, new attributes) and do not require rollback. If a data corruption event is detected, DynamoDB PITR restores to a point before the cutover (target: 15-minute RPO).
- **Maximum Rollback Window:** ≤30 minutes from rollback decision to previous-version traffic confirmed. Rollback decision authority rests with the vendor Project Manager in consultation with the Amatra VP Engineering.

---

# Appendices

## Architecture Diagrams

The following diagrams are referenced in this document and are produced and maintained by EO Framework Consulting throughout the engagement. Source files (draw.io) and PNG exports are delivered to Amatra as part of the handover package (Deliverable #2, Month 2, Week 2 — updated throughout the engagement).

- **Solution Architecture Diagram** — included in Section 4 (Solution Architecture); see `../../assets/diagrams/architecture-diagram.png`
- **Network Topology Diagram** — serverless network boundary, API Gateway ingress, WAF, S3 presigned URL egress paths
- **Data Flow Diagram** — end-to-end data flow from brief submission through Step Functions orchestration to S3 artifact delivery
- **Security Architecture Diagram** — defence-in-depth controls, identity flow (Cognito JWT), KMS encryption boundaries, GuardDuty/Security Hub aggregation
- **Step Functions State Machine Diagram** — complete state machine definition showing all task states, retry configurations, error handlers, and wait states for the async generation workflow

## Naming Conventions

All AWS resources follow the naming convention `amatra-isb-{resource-type}-{env}` (Production: `prod`, Staging: `staging`, Development: `dev`). The following table provides specific patterns and examples for each resource type.

<!-- TABLE_CONFIG: widths=[28, 38, 34] -->
| Resource Type | Pattern | Example |
|---------------|---------|---------|
| Lambda Function | `isb-{function-name}-{env}` | `isb-api-submit-prod` |
| DynamoDB Table | `AmatraISB-{TableName}-{Env}` | `AmatraISB-SolutionState-Prod` |
| S3 Bucket | `amatra-isb-{purpose}-{env}-{account-id}` | `amatra-isb-artifacts-prod-123456789012` |
| SQS Queue | `amatra-isb-{queue-name}-{env}` | `amatra-isb-job-queue-prod` |
| Step Functions State Machine | `amatra-isb-{workflow-name}-{env}` | `amatra-isb-generation-workflow-prod` |
| Cognito User Pool | `amatra-isb-users-{env}` | `amatra-isb-users-prod` |
| KMS CMK Alias | `alias/amatra-isb-{purpose}-{env}` | `alias/amatra-isb-s3-artifacts-prod` |
| Secrets Manager Secret | `amatra/{env}/{service}/{secret-name}` | `amatra/prod/bedrock/api-config` |
| CloudWatch Log Group | `/aws/lambda/isb-{function-name}-{env}` | `/aws/lambda/isb-api-submit-prod` |
| CloudWatch Alarm | `amatra-isb-{metric}-alarm-{env}` | `amatra-isb-dlq-depth-alarm-prod` |
| IAM Role | `amatra-isb-{function-name}-role-{env}` | `amatra-isb-api-submit-role-prod` |
| GitHub Actions Workflow | `{phase}-{action}.yml` | `phase1-deploy-staging.yml` |

## Tagging Standards

All AWS resources created by this engagement must carry the following tags. Tags are enforced via an AWS Config rule (`required-tags`) that raises a non-compliance finding in Security Hub if mandatory tags are absent. CloudFormation templates are the canonical source of all resource tags.

<!-- TABLE_CONFIG: widths=[22, 12, 66] -->
| Tag | Required | Example Values |
|-----|----------|----------------|
| Environment | Yes | `dev`, `staging`, `prod` |
| Application | Yes | `amatra-isb` |
| Owner | Yes | `eoframework-consulting` (build phase); `amatra-vp-engineering` (post-handover) |
| CostCenter | Yes | `OPP-2026-001` |
| Phase | Yes | `phase1`, `phase2`, `phase3` |
| Compliance | Yes | `soc2`, `gdpr` |
| DataClassification | Yes | `confidential`, `internal`, `public` |
| CreatedBy | No | `cloudformation`, `github-actions` |
| LastUpdated | No | ISO 8601 date of last resource change |

## Risk Register

The following risk register identifies the primary technical and delivery risks for the Amatra Intelligent Solution Builder engagement. Each risk has a defined likelihood, impact, and mitigation strategy. The risk register is reviewed at every phase gate and updated by the vendor Project Manager. Risks escalating to High/Critical are reported to the Amatra CTO within one business day of identification.

<!-- TABLE_CONFIG: widths=[30, 12, 12, 46] -->
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Amazon Bedrock Claude 3 Sonnet/Haiku unavailable in us-west-2 at project start | Low | Critical | SOW Assumption 6 approves us-east-1 cross-region inference as fallback; test model availability in Week 1; alert VP Engineering if unavailable |
| Async generation job duration exceeds 60 minutes under peak load (24 concurrent jobs) | Medium | High | Step Functions Standard Workflow supports up to 1-year execution duration; Bedrock invocation uses TaskToken callback to avoid Lambda timeout; load-tested at 2× peak in Staging before Phase 1 go-live |
| Okta-to-Cognito migration introduces authentication outage for pre-sales consultants | Medium | Critical | Two-week parallel-run period; progressive user migration in batches of 10; rollback script pre-staged to revert Cognito authoriser to Okta JWT validation within 15 minutes; zero-downtime design reviewed by Security & Compliance Lead |
| Bedrock-generated artifact quality falls below 90% QA first-pass target | Medium | High | Iterative prompt engineering during Phase 1 using 10–20 historical client briefs; Head of Solutions validates quality at Phase 1 UAT gate; QA validation layer provides automated scoring and flags low-quality artifacts for human review rather than silently delivering poor output |
| SOC 2 evidence collection not complete before Phase 2 go-live (15 Dec 2026) | Low | High | Evidence collection begins at Phase 1 go-live (Month 4); Security & Compliance Lead co-owns evidence log; Monthly review cadence; Deliverable #16 due Month 8, Week 2 — 4 weeks before Phase 2 go-live |
| Legacy Word/Excel/PowerPoint template complexity exceeds template pipeline design assumptions | Medium | Medium | Head of Solutions provides templates in Month 2; Template Ingestion Lambda design is reviewed against actual template structure before Phase 2 implementation begins; additional scope via Change Order if template complexity is materially higher than expected |
| AWS Lambda cold-start latency exceeds 3-second target for API Handler functions under low-traffic conditions | Medium | Medium | Provisioned concurrency on all four API Handler Lambda functions in production eliminates cold-start risk for those functions; Bedrock invoker and processor functions are async and not latency-sensitive |
| DynamoDB on-demand capacity throttling under burst load (24 concurrent jobs each writing status updates simultaneously) | Low | Medium | On-demand capacity scales within seconds; initial burst absorbs 2× prior peak without throttling; load testing at 2× peak in Staging confirms behaviour; CloudWatch throttle alarm triggers P2 alert if throttling occurs in production |
| GitHub Actions CI/CD pipeline outage blocks production deployment during a critical go-live window | Low | High | GitHub Actions is the deployment toolchain; rollback via Lambda alias update is executable manually via AWS CLI if GitHub Actions is unavailable; manual deployment runbook documented and rehearsed before Phase 1 cutover |
| Bedrock token budget overrun ($825/month baseline) due to higher-than-expected generation volume in Phase 3 GA | Medium | Medium | P3 CloudWatch alarm at 80% monthly budget triggers email to Head of Solutions; Haiku model substitution for simpler artifact types reduces per-generation cost by ~60%; monthly budget reviewed at Phase 3 optimisation review |

## Glossary

The following terms and acronyms are used throughout this document. Definitions align to AWS service documentation and SOC 2 Trust Service Criteria terminology.

<!-- TABLE_CONFIG: widths=[22, 78] -->
| Term | Definition |
|------|------------|
| ADR | Architecture Decision Record — a document capturing a significant architectural decision, its context, considered alternatives, and rationale |
| APM | Application Performance Monitoring — tooling (Datadog APM) that provides distributed tracing and latency profiling across Lambda functions |
| Bedrock | Amazon Bedrock — the AWS managed foundation model API service used to invoke Claude 3 Sonnet and Haiku for artifact content generation |
| Boto3 | The AWS SDK for Python, used in all Lambda functions for AWS service API calls |
| Claude | Anthropic's Claude large language model, accessed via Amazon Bedrock; Sonnet for complex artifact types, Haiku for lightweight types |
| CMK | Customer Managed Key — an AWS KMS encryption key that Amatra owns and controls; separate CMKs are provisioned for S3, DynamoDB, CloudTrail, and Secrets Manager |
| CQRS | Command-Query Responsibility Segregation — a pattern that separates write operations (commands) from read operations (queries) to enable independent scaling |
| DLQ | Dead Letter Queue — an Amazon SQS queue that receives messages that could not be successfully processed after the maximum number of receive attempts |
| DDD | Detailed Design Document — this document |
| GA | General Availability — the Phase 3 milestone at which all ~120 internal Amatra users are onboarded and the platform is fully operational |
| GitOps | A deployment model where all infrastructure and application changes are made through version-controlled pull requests and applied via automated pipelines |
| GDPR | General Data Protection Regulation — EU privacy regulation; Amatra implements GDPR-aligned data handling for personal data within client briefs |
| GuardDuty | AWS GuardDuty — a threat detection service that continuously monitors CloudTrail, DNS logs, and VPC Flow Logs for malicious activity |
| IAM | Identity and Access Management — the AWS service managing authentication and authorisation for AWS resources |
| ISB | Intelligent Solution Builder — shorthand for the Amatra Intelligent Solution Builder platform |
| JWT | JSON Web Token — a compact, self-contained token issued by Amazon Cognito for user authentication; validated by API Gateway on every request |
| KMS | AWS Key Management Service — the service used to create and control the Customer Managed Keys encrypting platform data |
| Lambda | AWS Lambda — the serverless compute service executing all platform function logic in Python 3.12 |
| LOE | Level of Effort — the professional services hours and cost estimate by phase and resource type (from level-of-effort-estimate.csv) |
| MVP | Minimum Viable Product — the Phase 1 production release (target: 30 September 2026) delivering the pre-sales artifact generation pipeline |
| PITR | Point-in-Time Recovery — DynamoDB's continuous backup capability providing minute-level restore granularity with a 35-day window |
| Presigned URL | A time-limited, cryptographically signed S3 URL that grants temporary read access to a specific S3 object without requiring AWS credentials |
| RPO | Recovery Point Objective — the maximum acceptable data loss measured in time; target: ≤15 minutes (DynamoDB PITR) |
| RTO | Recovery Time Objective — the maximum acceptable time to restore platform service after an outage; target: ≤1 hour |
| SAM | AWS Serverless Application Model — a CloudFormation extension simplifying the definition of Lambda, API Gateway, and DynamoDB resources |
| SCP | Service Control Policy — an AWS Organizations policy that enforces guardrails on all accounts in the organisation (e.g., blocking service deployments outside approved regions) |
| SIEM | Security Information and Event Management — a system aggregating security events for real-time analysis; Security Hub serves this function in the MVP |
| SOC 2 | System and Organisation Controls 2 — an auditing framework assessing controls across five Trust Service Criteria: Security, Availability, Processing Integrity, Confidentiality, and Privacy |
| SOW | Statement of Work — the contract document (Opportunity OPP-2026-001, v1.0, 1 July 2026) defining the scope, deliverables, and commercial terms for this engagement |
| Step Functions | AWS Step Functions — the serverless workflow orchestration service managing the durable 30–60 minute generation job state machines |
| TLS | Transport Layer Security — the cryptographic protocol (version 1.2+) protecting all data in transit across API Gateway and AWS service endpoints |
| UAT | User Acceptance Testing — the final quality gate before each production deployment, led by the Head of Solutions (Phase 1) and VP Engineering (Phase 2) |
| WAF | AWS Web Application Firewall — the L7 security service protecting the API Gateway endpoint against common web attacks and enforcing per-IP rate limiting |
| WORM | Write Once Read Many — a data storage model (implemented via S3 Object Lock in Compliance mode) that prevents modification or deletion of audit log records |
