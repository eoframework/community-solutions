---
document_title: Statement of Work
technology_provider: aws
project_name: Amatra Intelligent Solution Builder
client_name: Amatra
client_contact: Chief Technology Officer | cto@amatra.com
consulting_company: Amatra Consulting Partner
consultant_contact: Lead Solutions Architect | solutions@partner.com
opportunity_no: OPP-2025-001
document_date: June 2025
version: 1.0
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Statement of Work (SOW) defines the scope, deliverables, roles, and terms for the design and delivery of the **Amatra Intelligent Solution Builder** — an AWS-hosted, serverless platform that transforms a short client brief into a complete, consulting-grade artifact package automatically. Amatra currently produces every engagement artifact by hand, a process that consumes approximately three weeks per proposal and caps the company's ability to pursue new opportunities. This engagement will deliver a production-ready AI generation platform that cuts turnaround to under two business days and triples proposal throughput.

The solution is built cloud-native on AWS, leveraging Amazon Bedrock (Claude models) for intelligent artifact generation, AWS Lambda and Amazon API Gateway for a scalable REST API, AWS Step Functions and Amazon SQS for reliable asynchronous job orchestration, Amazon DynamoDB for solution and usage state, Amazon S3 for artifact storage, and Amazon Cognito for authenticated access with admin governance controls. The engagement is structured across three delivery phases culminating in General Availability by Q1 2027, with a hard Phase 1 Pre-Sales MVP deadline of 30 September 2026 — before Amatra's flagship client annual renewal on 31 January 2027.

**Project Duration:** 9 months (Phases 1–3), with GA by Q1 2027.

**Key Outcomes:**
- Serverless AI generation platform deployed and operational in AWS us-west-2
- Okta identity migrated to Amazon Cognito with admin governance and per-user usage controls
- Seven or more artifact types generated automatically from a client brief (discovery questionnaire, solution briefing, SOW, infrastructure cost model, level-of-effort estimate, detailed design, Terraform automation)
- Legacy internal EC2 monolith decommissioned and Google Workspace manual workflow retired
- Full CI/CD pipeline, IaC (Terraform), and SOC 2 Type II compliance posture operational
- 8-week post-go-live hypercare support with Bedrock prompt optimisation

**Expected Benefits:**
- Reduce artifact turnaround from ~3 weeks to under 2 business days (>90% reduction)
- Triple proposal throughput from ~8 to ~24 active engagements per quarter
- Cut consulting hours per engagement by 40% through automated generation
- Achieve 99.9% platform availability in production (us-west-2)
- Generated artifacts pass internal QA on first review ≥90% of the time
- Platform ROI realised within 12 months through increased proposal volume and reduced manual effort

---

# Background & Objectives

## Current State

Amatra is a B2B SaaS company in the cloud consulting and professional-services-automation space, headquartered in Austin, Texas, with approximately 120 employees and roughly $18M in annual revenue. The company serves enterprise clients across North America who purchase AWS solution-design and delivery engagements. Today, Amatra's pre-sales and delivery teams produce every engagement artifact entirely by hand — working from Google Workspace documents and a suite of Word, Excel, and PowerPoint templates. This manual workflow creates several significant operational challenges:

- **Turnaround Time:** Producing a complete engagement package (discovery questionnaire, solution briefing, SOW, infrastructure cost model, LOE, detailed design, implementation guide, and Terraform automation) takes approximately three weeks per client. This pace limits how many proposals the company can actively pursue at any one time.
- **Capacity Constraint:** With ~8 active engagements per quarter, the pre-sales team is operating at capacity. Growth in revenue requires a commensurate growth in proposal volume, which is not achievable without automation.
- **Inconsistent Quality:** Each consultant produces artifacts with different levels of detail, varying terminology, and divergent formatting. Quality reviews consume additional hours and occasional rework delays client delivery.
- **Legacy Technical Debt:** The current "solution builder" function is embedded in a legacy internal monolith running on a single EC2 instance, which is not scalable, not maintainable, and represents a single point of failure. Identity management currently lives in Okta, which must be migrated to Amazon Cognito as part of this initiative.
- **No Usage Governance:** There are currently no per-user or global controls on how many proposals are in-flight at any time, making it impossible for admins to enforce capacity limits or audit usage for billing and compliance purposes.

## Business Objectives

The following strategic objectives define what this engagement must achieve for Amatra, each tied directly to a measurable business outcome that the Intelligent Solution Builder platform will enable:

- **Automate Artifact Generation:** Deploy an AI-powered platform that converts a short client brief into a complete, consulting-grade engagement package in under 2 business days, without manual drafting effort from consultants.
- **Scale Proposal Throughput:** Enable the pre-sales team to pursue three times as many active engagements per quarter (from ~8 to ~24) by eliminating the time bottleneck in artifact production.
- **Enforce Quality at Scale:** Ensure that ≥90% of generated artifacts pass internal QA on first review by embedding artifact standards, prompt engineering, and validation into the generation pipeline.
- **Modernise Identity and Access:** Migrate user identity from Okta to Amazon Cognito, establish an admins group for governance, and enforce per-user and global monthly usage limits to control cost and capacity.
- **Decommission Legacy Infrastructure:** Retire the legacy EC2 monolith and the manual Google Workspace workflow, replacing them with the new serverless platform.
- **Achieve SOC 2 Type II Compliance:** Design and implement all controls required for SOC 2 Type II certification, ensuring GDPR-aligned data handling with all customer data resident in the United States (us-west-2).

## Success Metrics

The following measurable criteria define project success and will be assessed at key phase gates throughout the engagement to confirm that objectives are being met:

- Artifact turnaround reduced from ~3 weeks to **under 2 business days** by Phase 1 GA (30 September 2026)
- Proposal throughput increased from ~8 to **≥24 active engagements per quarter** within 90 days of GA
- Consulting hours per engagement reduced by **≥40%** compared to manual baseline
- Platform availability of **99.9%** measured monthly in production (us-west-2)
- Generated artifact first-review QA pass rate of **≥90%** within 8 weeks of Phase 1 GA
- **100%** of in-scope Okta users successfully migrated to Cognito with no access disruption
- SOC 2 Type II readiness evidence package delivered at project close
- Legacy EC2 monolith decommissioned with **zero data loss**
- All user data stored exclusively in **us-west-2** (United States data residency)

---

# Scope of Work

This engagement covers the full design, build, test, and deployment of the Amatra Intelligent Solution Builder platform on AWS, including identity migration, legacy monolith decommission, CI/CD pipeline, IaC automation, SOC 2 compliance controls, and post-go-live hypercare. The work is structured across five project phases spanning nine months, with phased delivery milestones tied to Amatra's business deadlines.

The following parameters define the sizing and boundaries of this engagement:

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | Artifact Types Automated | 7+ artifact types (discovery questionnaire, solution briefing, SOW, infrastructure costs, LOE estimate, detailed design, Terraform automation) |
| Solution Scope | Async Job Duration | 30–60 minute generation jobs per engagement |
| Solution Scope | Generation Volume | ~24 engagements per quarter (peak throughput target) |
| Identity & Access | User Base | ~120 internal users (pre-sales consultants, delivery consultants, admins) |
| Identity & Access | Identity Migration | Okta → Amazon Cognito (full user and group migration) |
| Identity & Access | Usage Governance | Per-user and global monthly usage limits, admin override API |
| AI/ML | LLM Platform | Amazon Bedrock — Claude 3 Sonnet/Opus model family |
| AI/ML | Prompt Engineering | 7+ artifact-specific prompt templates with context management |
| Integration | Legacy Systems | Legacy EC2 monolith retirement; Google Workspace workflow sunset |
| Integration | Template Formats | Existing Word/Excel/PowerPoint templates ingested into generation pipeline |
| Environments | Deployment Environments | Dev, Staging, Production (3 environments with full IaC) |
| Infrastructure | IaC Coverage | 100% Terraform coverage across all AWS services and environments |
| Compliance | Frameworks | SOC 2 Type II, GDPR-aligned data handling |
| Compliance | Data Residency | United States only — us-west-2 region |
| Performance | Platform Availability | 99.9% monthly in production |
| CI/CD | Pipeline Platform | GitHub Actions with automated build, test, and Terraform plan/apply gates |

Table: Engagement Scope Parameters

*Note: Changes to these parameters — including additional artifact types, additional user populations, additional AWS regions, or additional compliance frameworks — may require scope adjustment and additional investment via formal change request.*

## In Scope

The following services and deliverables are included in this SOW:

- End-to-end design and deployment of the serverless AWS platform (Lambda, API Gateway, Bedrock, Step Functions, SQS, DynamoDB, S3, Cognito, CloudWatch, WAF, CloudTrail, Secrets Manager, PrivateLink)
- Amazon Bedrock integration with prompt engineering for all 7+ artifact types
- Async job orchestration pipeline (Step Functions + SQS) for 30–60 minute generation jobs
- Okta-to-Cognito identity migration including admin governance group and usage-limit enforcement
- Artifact template ingestion pipeline automating Word, Excel, and PowerPoint output
- Admin console endpoints for per-user and global usage limit management
- CI/CD pipeline (GitHub Actions) with branch protection and automated test gates
- Terraform IaC modules for all AWS services across Dev, Staging, and Production
- SOC 2 Type II compliance controls: encryption, CloudTrail audit logging, IAM least-privilege, WAF, Secrets Manager, GDPR data handling policies
- CloudWatch observability: dashboards, Lambda alarms, Bedrock token-usage metrics, X-Ray tracing
- Legacy EC2 monolith decommission and data archive
- Comprehensive testing: functional, integration, async performance, security, compliance, and UAT
- 8-week hypercare post-go-live support
- Full documentation: architecture decision records, API reference, data dictionary, operational runbooks, SOC 2 evidence package

## Out of Scope

The following items are not included in this engagement unless explicitly added via change control:

- Ongoing managed services or post-hypercare production support (requires separate Managed Services Agreement)
- Development of new artifact template formats beyond the 7 types defined above
- Integration with any external client systems (this platform serves Amatra's internal teams only)
- Multi-region deployment (solution is scoped to us-west-2 only)
- Custom mobile application development
- Application-layer changes to existing Amatra client delivery tools outside this platform
- Third-party SIEM or EDR tooling beyond what is specified in the Security & Compliance section
- Formal penetration testing by an accredited third party (responsibility of Amatra Security team)
- Procurement or licensing of any software not listed in the technical requirements
- Public-facing customer portal or white-label deployment

## Activities

### Phase 1 — Discovery & Assessment (Weeks 1–4)

The Discovery & Assessment phase establishes a shared, documented understanding of Amatra's current manual workflow, legacy infrastructure, stakeholder requirements, and technical constraints. This phase produces the evidence base that all subsequent design and implementation decisions will be grounded in.

Key activities:
- Project kickoff with CTO, VP Engineering, Head of Solutions, and Security & Compliance Lead
- Current state assessment: document the legacy EC2 monolith, Google Workspace workflow, and manual artifact production process
- Stakeholder interviews across pre-sales, delivery, sales, and security teams
- Functional requirements gathering for all 7+ artifact types, usage-limit enforcement, and admin governance
- Amazon Bedrock feasibility assessment: Claude model selection, prompt engineering strategy, async job architecture options, output quality benchmarking
- Okta identity inventory: users, groups, SSO integrations; Cognito migration strategy
- SOC 2 and GDPR requirements assessment: data residency, access control, audit logging
- Gap analysis between manual process and automated platform; Phase 1 vs Phase 2 scope prioritisation
- AWS service-limit and IAM posture review in us-west-2
- Assessment report delivered to CTO and VP Engineering for Phase 1 go/no-go sign-off

**Deliverable:** Discovery & Assessment Report (including findings, recommendations, and Phase 1 go/no-go sign-off)

### Phase 2 — Architecture Design & Planning (Weeks 5–8)

The Architecture Design & Planning phase translates discovery findings into a detailed, validated technical blueprint for the platform. Every major architectural decision — from Bedrock prompt design to DynamoDB schema to Terraform module structure — is documented and approved before development begins.

Key activities:
- End-to-end serverless architecture design (API Gateway → Lambda → Bedrock → S3 async pipeline)
- AWS infrastructure design: DynamoDB table schemas, S3 bucket structure, Lambda function topology, VPC endpoint architecture
- Cognito User Pool design: identity federation from Okta, admins group structure, per-user usage-limit enforcement, OIDC/OAuth 2.0 flows
- AI/ML solution design: Bedrock prompt templates for each artifact type, context window management, model selection rationale, output validation approach
- Security and compliance design: SOC 2 controls, encryption at rest and in transit, CloudTrail configuration, IAM least-privilege policies, GDPR data-handling policies
- Terraform module structure: state backend (S3 + DynamoDB lock), module hierarchy for Dev/Staging/Prod
- CI/CD pipeline design: GitHub Actions workflows for Lambda deployments and Terraform plan/apply, branch protection rules
- Artifact template architecture: ingestion pipeline design for Word/Excel/PowerPoint from Bedrock output
- CloudWatch observability design: dashboards, alarms, X-Ray tracing strategy
- Architecture design documentation, architecture decision records (ADRs), and design review with CTO and Security Lead

**Deliverable:** Detailed Architecture Design Document and Architecture Decision Records

### Phase 3 — Development & Build (Weeks 9–20)

The Development & Build phase implements all platform components in the Dev environment following the approved architecture design, with parallel security hardening, CI/CD pipeline construction, and documentation. This is the most intensive phase of the engagement and delivers the complete working system ready for testing.

Key activities:
- Cognito User Pool provisioning and Okta-to-Cognito user and group migration
- AWS foundation provisioning via Terraform: S3 buckets, DynamoDB tables, IAM roles, VPC endpoints, CloudTrail, KMS keys across all environments
- REST API build: API Gateway configuration, Lambda functions for job submission/status polling/artifact retrieval, Cognito authoriser integration
- Async job orchestration: SQS queues, Step Functions standard workflows for 30–60 minute Bedrock jobs, dead-letter queue handling, idempotency and retry logic
- Bedrock integration and prompt engineering: Lambda-to-Bedrock integration, prompt template development and tuning for all 7+ artifact types, context management, output parsing and validation
- Artifact template automation: Word/Excel/PowerPoint population pipeline from Bedrock output, formatting validation, cross-reference validation
- DynamoDB data layer: solution-state and usage-tracking access patterns, per-user and global usage-limit enforcement, admin override API
- Admin console: usage limit view/set endpoints, audit log viewer, Cognito admins group authorisation
- CI/CD pipeline build: GitHub Actions workflows, Lambda deployment automation, Terraform plan/apply gates, branch protection
- CloudWatch observability deployment: dashboards, Lambda alarms, Bedrock token-usage metrics, X-Ray tracing, automated alerting
- Security hardening: secrets in Secrets Manager, WAF rule sets on API Gateway, S3 bucket policies, encryption validation, GDPR data-retention policy implementation
- Legacy EC2 monolith decommission planning: data export runbook, DNS cutover plan, stakeholder communications
- Configuration documentation: Lambda configurations, API schemas, DynamoDB schemas, Bedrock model parameters

**Deliverable:** Fully built and Dev-tested platform; Configuration Documentation

### Phase 4 — Testing & Validation (Weeks 21–26)

The Testing & Validation phase subjects the complete platform to a comprehensive test programme covering functional correctness, async job performance, security and compliance, identity and authentication, AI output quality, and User Acceptance Testing with Amatra's pre-sales consultants. All SOC 2 compliance evidence is collected during this phase.

Key activities:
- Test plan development covering all test types and acceptance criteria
- Functional testing: all 7+ artifact types against QA rubric; Bedrock output quality and template population accuracy
- Integration testing: API Gateway → Lambda → Bedrock → S3 end-to-end; Cognito auth flows; DynamoDB usage-limit enforcement
- Async job performance testing: load-test 30–60 minute generation pipeline; concurrent job handling; queue depth validation
- Security and compliance testing: OWASP API security tests, WAF rule validation, encryption verification, CloudTrail audit completeness, SOC 2 evidence collection
- Cognito and authentication testing: Okta-migrated user login flows, admin group permissions, per-user limit enforcement, token refresh/expiry
- Artifact quality validation: generated artifacts evaluated against internal QA rubric; iterative Bedrock prompt tuning to achieve ≥90% first-review pass rate
- UAT coordination with Head of Solutions (pre-sales consultants as primary users) and Delivery Consulting team; defect triage and resolution
- Test results report, SOC 2 evidence package, and CTO/Security Lead sign-off for go-live

**Deliverable:** Test Results Report; SOC 2 Evidence Package; Go-Live Sign-Off

### Phase 5 — Deployment, Hypercare & Close (Weeks 27–36)

The Deployment, Hypercare & Close phase executes the phased production rollout — Phase 1 Pre-Sales MVP by 30 September 2026 and Phase 2 Delivery & Terraform by 15 December 2026 — followed by 8 weeks of hypercare support and project closeout targeting GA by Q1 2027.

Key activities:
- Go-live planning: phased rollout plan, rollback procedures, stakeholder communications
- Staging environment full-stack validation prior to production promotion
- Production deployment Phase 1: Pre-Sales MVP (Bedrock, Lambda, API Gateway, Cognito, S3, DynamoDB) live by 30 September 2026
- Okta-to-Cognito DNS/SSO final cutover: all 120 users switched; 48-hour login success monitoring
- Legacy EC2 monolith decommission: data archive, DNS updates, internal documentation updated
- Production deployment Phase 2: Delivery automation and Terraform generation modules live by 15 December 2026
- Admin and pre-sales consultant training sessions
- Delivery team enablement on Phase 2 outputs
- Operational runbook development: Bedrock quota management, Lambda cold-start mitigation, DynamoDB scaling, incident response, DR procedures
- As-built architecture documentation, API reference, data dictionary, and final SOC 2 evidence package delivery
- 8-week hypercare: platform health monitoring, production issue resolution, Bedrock prompt tuning, pre-sales consultant adoption support
- Post-hypercare optimisation roadmap: cost optimisation, model upgrade options, additional artifact types, GA feature enhancements
- Project closeout: retrospective, lessons learned, final report to CTO and VP Engineering, handover to steady-state operations

**Deliverable:** Production platform live (Phase 1 by 30 Sep 2026; Phase 2 by 15 Dec 2026; GA Q1 2027); As-Built Documentation; Hypercare Report; Optimisation Roadmap

---

# Deliverables & Timeline

This engagement produces a comprehensive set of deliverables spanning documentation, deployed systems, training, and project governance. Each deliverable is formally accepted by the designated Amatra stakeholder before the engagement proceeds to the next phase.

## Deliverables

The following table lists all formal deliverables, their type, target due date, and acceptance authority:

<!-- TABLE_CONFIG: widths=[5, 42, 13, 20, 20] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|-------------|------|----------|---------------|
| 1 | Project Kickoff Deck & Meeting Notes | Document | Week 1 | VP Engineering |
| 2 | Current State Assessment Report | Document | Week 3 | CTO |
| 3 | Okta Identity Inventory & Migration Strategy | Document | Week 4 | Security & Compliance Lead |
| 4 | Discovery & Assessment Report (Phase 1 go/no-go) | Document | Week 4 | CTO |
| 5 | Detailed Architecture Design Document | Document | Week 7 | CTO, Security Lead |
| 6 | Architecture Decision Records (ADRs) | Document | Week 8 | VP Engineering |
| 7 | Terraform Module Structure & IaC Design | Document | Week 8 | VP Engineering |
| 8 | AWS Foundation Provisioned (Dev environment) | System | Week 11 | VP Engineering |
| 9 | Cognito User Pool & Okta Migration Complete | System | Week 13 | Security & Compliance Lead |
| 10 | REST API (API Gateway + Lambda) — Dev | System | Week 15 | VP Engineering |
| 11 | Async Job Pipeline (Step Functions + SQS) — Dev | System | Week 16 | VP Engineering |
| 12 | Bedrock Integration & Prompt Templates (7+ artifact types) | System | Week 18 | Head of Solutions |
| 13 | Artifact Template Automation Pipeline | System | Week 19 | Head of Solutions |
| 14 | Admin Console & Usage-Limit Governance API | System | Week 19 | Security & Compliance Lead |
| 15 | CI/CD Pipeline (GitHub Actions) | System | Week 20 | VP Engineering |
| 16 | CloudWatch Observability Stack | System | Week 20 | VP Engineering |
| 17 | Configuration Documentation | Document | Week 20 | VP Engineering |
| 18 | Test Plan | Document | Week 21 | VP Engineering |
| 19 | Functional & Integration Test Results | Document | Week 24 | Head of Solutions |
| 20 | Security & Compliance Test Results + SOC 2 Evidence | Document | Week 25 | Security & Compliance Lead |
| 21 | UAT Sign-Off | Document | Week 26 | Head of Solutions |
| 22 | Go-Live Readiness Sign-Off | Document | Week 26 | CTO |
| 23 | Production Deployment — Phase 1 Pre-Sales MVP | System | 30 Sep 2026 | CTO |
| 24 | Legacy EC2 Monolith Decommission Certificate | Document | Week 29 | VP Engineering |
| 25 | Production Deployment — Phase 2 Delivery & Terraform | System | 15 Dec 2026 | VP Engineering |
| 26 | Admin & Consultant Training Materials | Training | Week 30 | Head of Solutions |
| 27 | Operational Runbooks | Document | Week 34 | VP Engineering |
| 28 | As-Built Architecture Documentation & API Reference | Document | Week 35 | CTO |
| 29 | SOC 2 Evidence Package (final) | Document | Week 35 | Security & Compliance Lead |
| 30 | Hypercare Report & Optimisation Roadmap | Document | Week 36 | CTO |

## Project Milestones

The following milestones mark the completion of major phases and decision points throughout the engagement:

<!-- TABLE_CONFIG: widths=[20, 55, 25] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 — Discovery Complete | Assessment Report delivered and Phase 1 go/no-go approved by CTO | Week 4 |
| M2 — Architecture Approved | Detailed Architecture Design Document and ADRs approved by CTO and Security Lead | Week 8 |
| M3 — Dev Platform Built | All platform components deployed and integrated in Dev environment | Week 20 |
| M4 — Testing Complete | All test phases passed; SOC 2 evidence package assembled; CTO and Security Lead sign-off | Week 26 |
| M5 — Phase 1 Go-Live | Pre-Sales MVP live in Production; Okta-to-Cognito cutover complete | 30 Sep 2026 |
| M6 — Legacy Decommission | EC2 monolith retired; all data archived; Google Workspace workflow sunset | Week 29 |
| M7 — Phase 2 Go-Live | Delivery artifact automation and Terraform generation live in Production | 15 Dec 2026 |
| M8 — General Availability | All ~120 internal users onboarded; admin controls active; monitoring dashboards live | Q1 2027 |
| M9 — Hypercare End | 8-week hypercare complete; Optimisation Roadmap delivered; handover to operations | Week 36 |

---

# Roles & Responsibilities

This engagement involves a cross-functional team from both the consulting partner and Amatra. The RACI matrix below defines accountability for every major workstream to ensure clear ownership and decision-making authority throughout the engagement.

## RACI Matrix

The following matrix assigns responsibilities across the vendor and client teams for all major project workstreams. Each row identifies one "A" (Accountable) owner alongside the responsible, consulted, and informed parties:

<!-- TABLE_CONFIG: widths=[30, 9, 9, 9, 9, 9, 9, 8, 8] -->
| Task / Workstream | Vendor PM | Vendor Arch | Vendor Dev | Vendor Sec | Vendor QA | Client CTO | Client VP Eng | Client Sec Lead |
|-------------------|-----------|-------------|------------|------------|-----------|------------|---------------|-----------------|
| Project Governance & Status Reporting | A/R | C | I | I | I | I | C | I |
| Discovery & Requirements Gathering | A | R | C | C | I | C | C | C |
| Architecture Design & ADRs | C | A/R | C | C | I | C | C | C |
| Security & Compliance Design | C | C | I | A/R | I | I | I | C |
| Cognito Identity Architecture | C | R | C | A | I | I | C | C |
| Okta-to-Cognito Migration Execution | I | C | R | A | C | I | C | R |
| AWS Foundation (Terraform IaC) | I | C | A/R | C | I | I | C | I |
| Bedrock Integration & Prompt Engineering | I | A | R | I | C | I | I | I |
| Artifact Template Automation | I | C | A/R | I | C | I | C | I |
| CI/CD Pipeline Build | I | C | A/R | I | C | I | C | I |
| SOC 2 Controls Implementation | C | C | R | A | C | I | I | R |
| Functional & Integration Testing | C | C | C | I | A/R | I | C | I |
| Security & Compliance Testing | I | I | C | R | A | I | I | R |
| Artifact Quality Validation (QA rubric) | I | R | C | I | A | C | I | I |
| UAT Coordination & Acceptance | A | C | C | I | C | C | R | I |
| Production Go-Live Approval | C | C | C | C | C | A | R | C |
| Legacy Monolith Decommission | C | C | R | C | I | I | A | I |
| Hypercare & Incident Response | A/R | C | R | C | I | I | C | I |
| SOC 2 Evidence Assembly | C | I | I | R | A | I | I | R |
| Training & Knowledge Transfer | A/R | C | C | I | I | I | C | I |

**Legend:** R = Responsible | A = Accountable | C = Consulted | I = Informed

## Key Personnel

The following roles are required for successful delivery of this engagement:

**Vendor Team:**
- **Solution Architect:** Owns end-to-end technical design, architecture governance, Bedrock/AI quality review, and escalation management across all phases
- **Project Manager:** Responsible for project coordination, milestone tracking, status reporting to CTO and VP Engineering, risk management, and change control
- **ML/AI Engineer:** Leads Bedrock model selection, prompt engineering, context management, and artifact quality optimisation
- **Senior Cloud Engineer:** Provisions and maintains AWS foundation (Terraform IaC, S3, DynamoDB, Lambda, API Gateway, VPC) across all environments
- **Security Engineer:** Designs and implements SOC 2 controls, executes Okta-to-Cognito migration, performs security testing, and assembles compliance evidence
- **DevOps Engineer:** Builds and maintains CI/CD pipelines (GitHub Actions), Terraform plan/apply gates, and CloudWatch observability stack
- **QA Engineer:** Develops test plans, executes functional and integration testing, coordinates UAT, and produces test results documentation
- **Technical Writer:** Authors architecture documentation, API reference, operational runbooks, training materials, and as-built deliverables

**Client Team:**
- **CTO (Executive Sponsor):** Budget owner, go/no-go sign-off authority at each phase gate, final approval for production deployments
- **VP of Engineering (Delivery Owner):** Day-to-day technical project owner, engineering team coordination, milestone acceptance
- **Head of Solutions (Pre-Sales):** Defines artifact quality standards, validates Bedrock output against QA rubric, leads UAT as primary end-user representative
- **Security & Compliance Lead:** Reviews and approves all security design decisions, owns SOC 2 control sign-off, participates in compliance testing
- **IT/Operations Representative:** Supports AWS account provisioning, IAM baseline configuration, and network connectivity requirements
- **Delivery Consulting Team Lead:** Represents downstream artifact consumers in requirements and UAT for Phase 2 delivery artifacts

---

# Architecture & Design

## Architecture Overview

The Amatra Intelligent Solution Builder is a fully serverless, cloud-native platform deployed in AWS us-west-2. The architecture is designed around three core principles: **reliability for long-running jobs**, **security and compliance by design**, and **operational simplicity through managed services**. Every component is AWS-managed or serverless, eliminating infrastructure operations overhead and enabling 99.9% platform availability without dedicated server management.

The platform follows an event-driven, asynchronous pattern to accommodate the 30–60 minute artifact generation jobs that are inherent to invoking Amazon Bedrock Claude models for multi-artifact output. Clients submit a brief via the REST API, which returns a job ID immediately. The generation job is enqueued in Amazon SQS, picked up by an AWS Step Functions standard workflow, and processed through a Lambda-orchestrated Bedrock invocation pipeline. Completion notifications are sent via Amazon SES. This architecture ensures that no generation job is lost due to Lambda timeout constraints and that the API remains responsive at all times.

Security and compliance are embedded at every layer: Amazon Cognito enforces authenticated access with admin governance groups; AWS WAF protects the API Gateway endpoint; all data at rest is encrypted with AWS KMS; CloudTrail captures all API activity for SOC 2 audit; and all inter-service connectivity is routed through AWS PrivateLink VPC endpoints, keeping traffic off the public internet.

![Figure 1: Solution Architecture Diagram](../../assets/diagrams/architecture-diagram.png)

**Figure 1: Amatra Intelligent Solution Builder — AWS Serverless Architecture** — End-to-end architecture showing the asynchronous Bedrock generation pipeline, API and auth layer, storage and state management, observability stack, and security controls.

## Component Architecture

The platform is composed of five logical layers, each implemented using purpose-built AWS managed services:

**API & Authentication Layer:** Amazon API Gateway (REST API) serves as the single entry point for all platform operations — brief submission, job status polling, artifact retrieval, and admin governance actions. All API requests are authenticated via an Amazon Cognito authoriser. The Cognito User Pool hosts approximately 120 Amatra users across three roles (pre-sales consultants, delivery consultants, admins), migrated from Okta as part of this engagement. The admins group is granted elevated scopes that allow per-user and global usage limit configuration via a dedicated admin API endpoint layer backed by Lambda.

**Orchestration & Generation Layer:** Upon job submission, a Lambda handler enqueues the generation request to an Amazon SQS FIFO queue. An AWS Step Functions standard workflow polls the queue and orchestrates the multi-step Bedrock invocation sequence: prompt assembly, Claude model invocation for each of the 7+ artifact types, output parsing and validation, and final artifact packaging. Step Functions standard workflows support execution durations of up to one year, eliminating Lambda timeout risk for long-running jobs. Dead-letter queues and idempotency keys ensure exactly-once processing and graceful retry on transient Bedrock failures.

**AI Generation Layer:** Amazon Bedrock (Claude 3 Sonnet as the primary model) powers the artifact generation. Seven or more artifact-specific prompt templates have been engineered with structured context injection (client brief, solution metadata, prior artifact context) and constrained output schemas to ensure consistent, parseable artifact output. Context window management ensures each artifact receives the full relevant context from the client brief without exceeding model limits. Output validation Lambda functions check structural completeness before artifacts are stored.

**Storage & State Layer:** Amazon S3 stores all generated artifacts, source templates (Word/Excel/PowerPoint), and static web assets, organised by solution ID with server-side KMS encryption. Amazon DynamoDB (on-demand capacity mode) maintains solution state records (brief, job status, artifact metadata) and per-user usage tracking tables. Usage tracking records are checked on every job submission to enforce per-user and global monthly limits before Bedrock invocations are initiated.

**Observability & Security Layer:** Amazon CloudWatch provides centralised logging (Lambda, Step Functions, API Gateway), custom metrics (Bedrock token consumption, job throughput, queue depth), alarms (error rate, latency, DLQ depth), and dashboards for platform health. AWS X-Ray provides distributed tracing across the Lambda and Step Functions execution path. AWS WAF enforces rate limiting and OWASP rule sets on the API Gateway endpoint. AWS CloudTrail captures all AWS API activity for SOC 2 audit. AWS Secrets Manager stores all API keys and integration credentials with automatic rotation.

## Network Design

The platform is deployed within a dedicated VPC in us-west-2 with a private subnet architecture. Lambda functions execute within the VPC and communicate with AWS managed services exclusively through AWS PrivateLink VPC interface endpoints — covering S3, DynamoDB, Bedrock, Secrets Manager, and SQS — ensuring that no data traverses the public internet between platform components. Amazon CloudFront serves the pre-sales platform front-end assets from an S3 origin, providing CDN acceleration for static content with TLS enforcement. API Gateway is deployed as a regional endpoint with WAF attached. All inbound API traffic is TLS 1.2+ only. Outbound traffic (SES notifications, external API calls) is routed through a NAT Gateway with security group restrictions limiting egress to approved endpoints.

## Security Design

The security architecture implements defence-in-depth controls across preventative, detective, and responsive layers:

**Identity and Access Controls:** Amazon Cognito enforces MFA for all admin-group users. Lambda execution roles follow least-privilege IAM policies with explicit deny rules for cross-account access. Resource-based S3 bucket policies enforce TLS-only access and deny public access. DynamoDB tables are encrypted with customer-managed KMS keys. All Secrets Manager secrets are rotated on a 30-day schedule.

**Preventative Controls:** AWS WAF on API Gateway enforces rate limiting (1,000 requests per minute per IP), AWS Managed Rules for OWASP Top 10 mitigation, and IP reputation lists. VPC security groups restrict Lambda-to-service traffic to named endpoints only. S3 Block Public Access is enforced at the account level. All inter-service encryption uses AES-256 at rest and TLS 1.2+ in transit.

**Detective Controls:** Amazon CloudTrail (management and data events) provides a complete audit trail of all API operations, S3 object access, and DynamoDB operations, with CloudTrail logs shipped to a dedicated S3 bucket with CloudWatch Logs integration. CloudWatch alarms trigger on anomalous API error rates, unexpected DLQ depth, and Bedrock quota consumption spikes. AWS Config rules monitor resource configuration compliance against SOC 2 baselines.

**Responsive Controls:** CloudWatch alarms feed an SNS topic that notifies the Amatra operations team via email. Step Functions error states trigger automated DLQ re-processing for transient failures and alert on permanent failures requiring human review.

## Data Architecture

All customer data (client briefs, generated artifacts, solution metadata) is stored exclusively in AWS us-west-2, satisfying the GDPR-aligned data residency requirement. The data architecture covers the following tiers:

**Hot Data (DynamoDB):** Solution state records and per-user usage tracking are stored in DynamoDB on-demand mode. The solution-state table uses `solution_id` as the partition key with a GSI on `user_id` for per-user job listing. The usage-tracking table uses `user_id` + `month_key` as a composite key to support per-user monthly limit enforcement queries. Both tables are encrypted with KMS at rest and have point-in-time recovery (PITR) enabled.

**Warm Data (S3 Standard):** Generated artifacts (markdown sources and converted Office documents) are stored in a versioned S3 bucket with server-side encryption (SSE-KMS). Artifacts are organised with the key prefix `{solution_id}/raw/` and `{solution_id}/generated/`. S3 Versioning is enabled to support artifact re-generation and rollback. Object lifecycle policies transition objects older than 90 days to S3 Intelligent-Tiering.

**Archive Data (S3 Glacier):** Artifacts and audit logs older than 365 days are transitioned to S3 Glacier Instant Retrieval for cost-efficient long-term retention. Deletion is restricted to authorised admin actions only, with an MFA-delete policy on the S3 bucket.

**Data Classification:** All data processed by the platform is classified as Confidential (client business information and generated consulting deliverables). PHI, PCI-DSS in-scope, or government-classified data is explicitly out of scope.

## Operational Design

**Observability:** A CloudWatch dashboard tracks seven key platform health indicators in real time: API Gateway request rate and 4xx/5xx error rate, Lambda invocation count and P99 duration, Step Functions execution success/failure rate, SQS queue depth and DLQ message count, and Bedrock token consumption vs monthly quota. CloudWatch Alarms notify the operations team when: API error rate exceeds 1%, DLQ depth exceeds 0, Step Functions failure rate exceeds 5%, or Bedrock token consumption reaches 80% of monthly limit.

**Backup & Disaster Recovery:** DynamoDB PITR provides continuous backup with a 35-day recovery window. S3 versioning and cross-region replication (to us-east-1) protect generated artifacts against accidental deletion and regional service events. RTO target is 4 hours; RPO target is 1 hour, based on DynamoDB PITR recovery and S3 cross-region replication lag. DR runbooks covering Lambda redeployment from IaC, DynamoDB restoration from PITR, and S3 failover are included in the operational runbook deliverable.

**Incident Management:** Severity 1 (platform down, no artifact generation) — 1-hour response, 4-hour resolution target. Severity 2 (partial generation failure, degraded performance) — 4-hour response, 8-hour resolution. Severity 3 (non-critical issues, cosmetic defects) — next business day response. During hypercare, the vendor team is on-call for Severity 1 and 2 issues.

## Tooling Overview

The following tooling is employed across the engagement for development, deployment, monitoring, and operations:

<!-- TABLE_CONFIG: widths=[28, 35, 37] -->
| Category | Primary Tools | Purpose |
|----------|---------------|---------|
| AI / ML Generation | Amazon Bedrock (Claude 3 Sonnet) | Artifact content generation via LLM inference |
| Job Orchestration | AWS Step Functions, Amazon SQS | Async long-running generation job management |
| API & Compute | Amazon API Gateway, AWS Lambda | REST API hosting and serverless function execution |
| Identity & Auth | Amazon Cognito | User authentication, admin governance, usage limits |
| Storage | Amazon S3, Amazon DynamoDB | Artifact storage and solution/usage state management |
| Security | AWS WAF, AWS Secrets Manager, AWS KMS | API protection, secrets management, encryption |
| Compliance & Audit | AWS CloudTrail, AWS Config | API audit logging, SOC 2 compliance monitoring |
| Observability | Amazon CloudWatch, AWS X-Ray | Metrics, logs, alarms, distributed tracing |
| Notifications | Amazon SES | Job completion and error notification emails |
| Networking | AWS PrivateLink, Amazon CloudFront | Private service connectivity and CDN delivery |
| IaC & CI/CD | Terraform, GitHub Actions | Infrastructure as code and automated deployment |
| Monitoring (APM) | Datadog Pro (5 hosts) | Application performance monitoring and tracing |
| Container Registry | Amazon ECR | Lambda container image storage |
| Project Management | Jira / Confluence | Task tracking, documentation, sprint planning |

---

# Security & Compliance

## Identity & Access Management

All platform access is controlled through Amazon Cognito User Pools, which replace the existing Okta identity provider as part of this engagement. Cognito is configured with three user groups: `presales-consultants`, `delivery-consultants`, and `admins`. The `admins` group is granted elevated OAuth 2.0 scopes that permit usage limit configuration and audit log access via the admin API. Multi-factor authentication (MFA) is enforced as mandatory for all `admins` group users and optional (strongly recommended) for all other users. OIDC/OAuth 2.0 with PKCE is used for API authorisation; Cognito-issued JWTs are validated by the API Gateway Cognito authoriser on every request.

IAM roles for Lambda functions follow strict least-privilege policies: each function is granted only the specific DynamoDB table permissions, S3 bucket prefixes, and Secrets Manager ARNs it requires. There are no wildcard resource permissions in any production IAM role. Cross-account access is explicitly denied at the account boundary. IAM Access Analyzer is enabled to continuously validate that no unintended resource sharing exists. All administrative access to the AWS account uses IAM Identity Center (SSO) with hardware MFA required for production environment access.

## Monitoring & Threat Detection

The platform implements continuous security monitoring through a combination of AWS-native services. Amazon CloudTrail records all management-plane and data-plane API events (including S3 object-level operations and DynamoDB table operations) and ships logs to a dedicated, immutable CloudTrail S3 bucket with Object Lock enabled. CloudWatch Metric Filters extract security-relevant events — root account logins, console sign-ins without MFA, IAM policy changes, Security Group modifications — and trigger CloudWatch Alarms for immediate notification.

AWS Config rules continuously evaluate resource configuration against a SOC 2 baseline: S3 Block Public Access enabled, CloudTrail multi-region enabled, KMS key rotation enabled, Secrets Manager rotation enabled, Lambda functions running within VPC. Config findings are surfaced in a Security Hub dashboard for centralised visibility. Any non-compliant configuration triggers an SNS alert to the Security & Compliance Lead.

## Compliance & Auditing

This engagement is designed to achieve SOC 2 Type II readiness across the five Trust Service Criteria: Security, Availability, Processing Integrity, Confidentiality, and Privacy. The following evidence artefacts are produced and delivered as the SOC 2 Evidence Package:

- CloudTrail log exports for the audit period covering all API activity
- AWS Config compliance evaluation history for all monitored rules
- Cognito access logs and admin group membership changes
- CloudWatch Alarm history showing incident detection and response
- Secrets Manager rotation logs demonstrating automatic credential rotation
- IAM Access Analyzer findings and remediation log
- S3 access logs for all artifact buckets
- Encryption-at-rest inventory (KMS key usage per service)

GDPR-aligned data handling is implemented through: data residency enforcement in us-west-2 only; explicit data classification labelling in S3 object metadata; DynamoDB record retention policies with automated deletion of solution records older than the configured retention period; and a documented data subject request process covering access, rectification, and erasure of stored client brief data.

## Encryption & Key Management

All data at rest is encrypted using AWS KMS customer-managed keys (CMKs): S3 buckets (SSE-KMS), DynamoDB tables (KMS at rest), Secrets Manager secrets (KMS), and CloudTrail logs (KMS). A separate CMK is used for each data classification tier. KMS automatic key rotation is enabled on all CMKs with a 365-day rotation schedule. All data in transit uses TLS 1.2 or higher; TLS 1.0 and 1.1 are explicitly disabled on all API Gateway endpoints and CloudFront distributions. Secrets Manager stores all integration credentials (Bedrock API configuration, Datadog API key, SES credentials) and rotates them automatically on a 30-day schedule.

## Governance

The platform implements the following governance controls to satisfy SOC 2 requirements and Amatra's operational policies:

- **Change Management:** All infrastructure changes are applied via Terraform through the GitHub Actions CI/CD pipeline. No manual changes to production resources are permitted; all changes must pass a Terraform plan review and automated test gate before apply. Branch protection rules require at least one peer review approval before merges to the main branch.
- **Access Reviews:** Quarterly Cognito user group membership reviews are conducted by the Security & Compliance Lead to ensure that only active employees have platform access. Departed employees are removed from Cognito within 24 hours of offboarding notification.
- **Usage Limit Governance:** Per-user monthly generation limits and global monthly generation limits are configurable by admins via the admin API. Limit changes are logged in DynamoDB with a timestamp and admin user ID for audit purposes.
- **Secrets Governance:** All API keys and credentials are stored in Secrets Manager. Direct use of plaintext credentials in environment variables is prohibited. Secrets are tagged with owner, rotation policy, and classification metadata.

## Environments & Access

The platform is deployed across three isolated environments, each provisioned by Terraform from the same module configuration with environment-specific parameter overrides:

<!-- TABLE_CONFIG: widths=[18, 28, 28, 26] -->
| Environment | Purpose | Access Control | Data |
|-------------|---------|----------------|------|
| Development | Active development and feature testing | Vendor engineering team only (IAM Identity Center SSO); no Amatra user access | Synthetic test briefs only — no real client data |
| Staging | Pre-production integration testing and UAT | Vendor team + selected Amatra UAT participants; read-only Amatra access | Anonymised copies of real briefs for UAT validation |
| Production | Live platform serving all Amatra internal users | All Amatra users via Cognito; admin access restricted to `admins` group; AWS account access via IAM Identity Center with MFA | Real client briefs and generated artifacts — KMS encrypted, us-west-2 only |

### Access Policies

Production AWS account console and CLI access is restricted to a named set of individuals in the Amatra `admins` Cognito group and the vendor operations team during hypercare. All production access requires IAM Identity Center SSO with hardware MFA. The principle of least privilege is enforced: pre-sales consultants can only submit briefs and retrieve their own artifacts; delivery consultants can retrieve generated delivery artifacts; admins can view and modify usage limits and access audit logs. No direct access to DynamoDB tables, S3 buckets, or Lambda functions is permitted for end users — all access is mediated through the API Gateway REST API.

---

# Testing & Validation

## Functional Validation

Functional validation confirms that the platform correctly generates all required artifact types from a given client brief, that all API endpoints behave according to specification, and that the admin governance functions operate correctly. The QA Engineer executes a suite of test cases derived from the artifact type specifications and API schema. Each test case includes input (a representative client brief), expected output (artifact content matching the QA rubric for that artifact type), and pass/fail criteria. All 7+ artifact types are tested against a minimum of three representative client briefs of varying complexity (simple, medium, complex). Bedrock output quality is validated against the internal QA rubric; a minimum of 90% of test cases must pass on first generation without manual prompt adjustment before the suite is considered complete. Defects are tracked in Jira with severity classification; Severity 1 and 2 defects must be resolved before UAT begins.

## Performance & Load Testing

Async job performance testing validates that the generation pipeline handles concurrent load without degradation and that jobs complete within the expected 30–60 minute window under peak conditions. The test scenario simulates 10 concurrent brief submissions (representing peak load at 24 engagements per quarter), with jobs submitted simultaneously and monitored through to artifact delivery. Step Functions execution duration, SQS queue depth under load, Lambda cold-start frequency, and DynamoDB read/write unit consumption are measured. Success criteria: all 10 concurrent jobs complete within 90 minutes, no jobs land in the dead-letter queue, and no API requests return a 5xx error during the test window. A secondary stress test runs 25 concurrent submissions to establish the platform's throughput ceiling.

## Security Testing

Security testing validates that all SOC 2 controls are implemented correctly and that the API is resistant to common web application attacks. The test programme includes: OWASP API Security Top 10 validation against the API Gateway endpoint; AWS WAF rule effectiveness test (simulated SQL injection, XSS, and rate-limit breach attempts); Cognito authentication bypass tests (token manipulation, scope elevation attempts); S3 bucket access policy validation (confirming no public access, no cross-account access); encryption-at-rest verification for S3, DynamoDB, Secrets Manager, and CloudTrail; and CloudTrail completeness audit (confirming all expected API event types are captured). The Security & Compliance Lead reviews all security test results and must sign off before production deployment.

## Disaster Recovery & Resilience Tests

Disaster recovery testing validates that the platform can recover to RTO (4 hours) and RPO (1 hour) targets following a simulated failure. Tests include: DynamoDB PITR restoration to a point-in-time within the previous hour (validating RPO); Lambda function cold redeployment from Terraform IaC (validating RTO for compute layer); S3 cross-region replication lag measurement (validating RPO for artifact storage); and Step Functions workflow re-execution following a simulated Bedrock API timeout (validating retry logic). DR test results are documented and included in the SOC 2 evidence package.

## User Acceptance Testing

User Acceptance Testing (UAT) is coordinated by the Head of Solutions and involves a group of 5–10 pre-sales consultants from Amatra's primary user population. This phase is critical for validating that the Bedrock-generated artifacts meet the internal quality standard and that the end-to-end platform workflow is intuitive and production-ready before go-live. UAT participants submit real client briefs (or realistic representative briefs) through the production-equivalent staging environment and evaluate the generated artifacts against the internal QA rubric covering artifact completeness, content accuracy, formatting quality, and overall platform usability. Feedback is collected via a structured UAT feedback form; the acceptance criterion is a ≥90% first-review pass rate across all submitted briefs. UAT defects are triaged by severity — all Severity 1 and 2 defects are resolved and re-verified before the Go-Live Readiness Sign-Off milestone is approved by the Head of Solutions. The Delivery Consulting team also participates in a targeted UAT session for Phase 2 artifact types (detailed design, implementation guide, Terraform automation) to confirm fitness for downstream delivery use.

## Go-Live Readiness

Before any production deployment is authorised, the following go-live readiness checklist must be fully satisfied:

- All Severity 1 and Severity 2 defects from functional, integration, performance, and UAT testing are resolved and verified
- Security testing sign-off from Security & Compliance Lead received
- SOC 2 evidence package assembled and reviewed
- Cognito User Pool fully populated with migrated Okta users; pilot login tests passed by ≥95% of users
- Admin usage limits configured and validated in staging
- CloudWatch dashboards, alarms, and notification routing validated in staging
- Operational runbooks completed and reviewed by VP Engineering
- Rollback procedure documented and tested in staging
- CTO and VP Engineering provide formal written go-live approval
- Amatra communications plan for user cutover prepared and ready to distribute

## Cutover Plan

**Phase 1 Cutover (Target: 30 September 2026):**
The Phase 1 cutover transitions Amatra's pre-sales consultant user population from the manual Google Workspace workflow to the new platform. The cutover is executed during a planned maintenance window communicated to all users 5 business days in advance. Steps: (1) final Okta-to-Cognito SSO DNS cutover executed and validated; (2) pre-sales consultant login validation run for all ~80 pre-sales and delivery users — any login failures resolved within 1 hour; (3) brief submission tested end-to-end in production by the Head of Solutions; (4) admin usage limits activated; (5) CloudWatch alarms confirmed active; (6) go-live communications sent to all users; (7) vendor team on-call for 48 hours post-cutover.

**Phase 2 Cutover (Target: 15 December 2026):**
The Phase 2 cutover activates the delivery artifact automation and Terraform generation modules. Steps: (1) delivery team enablement sessions completed; (2) Phase 2 artifact types validated end-to-end in staging; (3) production deployment executed via GitHub Actions pipeline; (4) smoke test of all Phase 2 artifact types in production; (5) legacy EC2 monolith decommission executed (data archive, DNS update); (6) go-live communications to delivery team.

## Rollback Strategy

If a critical defect is detected post-cutover that cannot be resolved within 2 hours, the rollback procedure is activated: (1) API Gateway stage variable switched to the previous Lambda alias (blue/green deployment model maintained for 30 days post-cutover); (2) Cognito User Pool Okta federation temporarily re-enabled (Okta decommission delayed until Phase 1 is stable for 7 days); (3) users notified to revert to Google Workspace manual workflow temporarily; (4) incident RCA conducted within 24 hours; (5) fix-and-re-deploy cycle executed before next cutover attempt. The rollback activation threshold is: ≥5% of user job submissions failing, or any Severity 1 data integrity issue detected.

---

# Handover & Support

## Handover Artifacts

At project completion, Amatra receives a comprehensive handover package covering all aspects of the delivered platform. The following artifacts are formally transferred:

- **Architecture Documentation:** Final as-built architecture document (including all architectural decision records, component diagrams, and network topology), API reference documentation (all endpoints, request/response schemas, error codes), and data dictionary (DynamoDB table schemas, S3 object structure, usage tracking data model)
- **Infrastructure as Code:** Complete Terraform module repository covering all AWS services across Dev, Staging, and Production environments, with README, variable documentation, and example tfvars
- **CI/CD Configuration:** GitHub Actions workflow definitions, branch protection rules, and deployment runbook
- **Security & Compliance:** SOC 2 Type II evidence package (CloudTrail exports, Config compliance history, IAM Access Analyzer findings, encryption inventory), GDPR data handling procedures, and security incident response runbook
- **Operational Runbooks:** Bedrock quota management and model upgrade procedures, Lambda cold-start mitigation and memory optimisation, DynamoDB on-demand capacity scaling guidance, admin user management (Cognito), usage limit configuration guide, incident response procedures, and DR restoration steps
- **Training Materials:** Admin training deck and hands-on lab guide (Cognito management, usage limits, audit log review), pre-sales consultant user guide (brief submission, artifact review, regeneration), delivery team enablement guide (Phase 2 artifact types and Terraform automation), and video recordings of all training sessions

## Knowledge Transfer

Knowledge transfer is delivered across three structured sessions during the Deployment phase, with recorded video copies provided for asynchronous review:

**Session 1 — Admin Enablement (Week 30):** A 4-hour hands-on session with Amatra's designated platform admins covering: Cognito user management (adding/removing users, group assignments), usage limit configuration (per-user and global limits, admin override), CloudWatch dashboard navigation and alarm management, incident response for common platform issues (DLQ messages, Bedrock quota alerts, Lambda errors), and Terraform-based infrastructure change procedure.

**Session 2 — Pre-Sales Consultant Enablement (Week 30):** A 3-hour hands-on session for pre-sales consultants covering: brief submission workflow (what to include for best artifact quality), artifact review and QA checklist, regeneration workflow (how to trigger re-generation with an updated brief), downloading and using generated Office documents, and escalation process for generation quality issues.

**Session 3 — Delivery Team Enablement (Week 32):** A 2-hour session for the Delivery Consulting team covering Phase 2 artifact types (detailed design, implementation guide, Terraform automation), how to review and validate generated delivery artifacts, and integration with the existing delivery workflow.

## Hypercare Support

An 8-week hypercare support period is provided following the Phase 1 Production Go-Live milestone (30 September 2026 through approximately 25 November 2026). Hypercare coverage and terms are as follows:

- **Coverage Hours:** Business hours (8:00am–6:00pm CT, Monday–Friday) plus on-call availability for Severity 1 incidents
- **Response Times:** Severity 1 (platform down) — 1-hour response, 4-hour resolution target; Severity 2 (partial failure, degraded performance) — 4-hour response, 8-hour resolution target; Severity 3 (non-critical issues) — next business day response
- **Hypercare Scope:** Platform health monitoring and proactive issue resolution; production incident investigation and fix; Bedrock prompt tuning based on QA first-pass rate data from live usage; Cognito user onboarding support; admin training follow-up and Q&A; CloudWatch alarm threshold tuning based on real traffic patterns
- **Excluded from Hypercare:** New feature development; changes to artifact types or templates beyond initial scope; changes to AWS account architecture; third-party integrations not included in original scope

## Managed Services Transition

Ongoing managed services are not included in this engagement. Following hypercare completion, Amatra's VP of Engineering and operations team assume full responsibility for steady-state platform operations. The vendor provides an Optimisation Roadmap document at hypercare close that outlines recommended post-hypercare improvements — including Bedrock model upgrade options, cost optimisation opportunities (Reserved Instances, Savings Plans), additional artifact type candidates, and GA feature enhancements. Refer to a separate Managed Services Agreement if ongoing managed operations are required.

## Assumptions

The following assumptions underpin this engagement's scope, timeline, and budget:

1. Amatra will provide a dedicated client technical lead (VP Engineering or designee) available for a minimum of 10 hours per week throughout the engagement
2. AWS account(s) with appropriate service limits for Bedrock, Lambda, DynamoDB, S3, API Gateway, and Cognito in us-west-2 will be provisioned and accessible within 5 business days of contract execution
3. Amatra will provide Okta administrator credentials and SSO configuration details within 2 weeks of Phase 1 kickoff to support identity migration planning
4. All existing Word, Excel, and PowerPoint artifact templates will be delivered to the vendor team in electronic form within 2 weeks of Phase 1 kickoff
5. The CTO, VP Engineering, Head of Solutions, and Security & Compliance Lead are available for weekly project status meetings (1 hour) and phase-gate reviews throughout the engagement
6. Amatra's Security & Compliance Lead will review and approve security design decisions within 5 business days of submission
7. UAT participants (5–10 pre-sales consultants) will be identified and made available for UAT sessions during Phase 4 (Weeks 21–26)
8. Representative client briefs for use in functional testing and UAT will be provided by the Head of Solutions within 2 weeks of Phase 3 kickoff
9. Amatra will manage all internal change management communications to employees regarding the Okta-to-Cognito migration and platform cutover
10. All AWS costs (infrastructure, Bedrock inference, support) are billed directly to Amatra's AWS account; vendor professional services are invoiced separately per the Payment Terms below
11. GitHub is the approved source control platform; GitHub Actions is approved for CI/CD; a Terraform state backend using S3 and DynamoDB locking is available for Terraform state management
12. Amatra's existing Google Workspace instance will remain operational during Phase 1 and Phase 2 as a fallback, and will be sunset only after Phase 1 GA is stable for 30 days
13. No regulatory approvals (government, healthcare, financial) are required before platform go-live; compliance scope is limited to SOC 2 Type II and GDPR-aligned data handling

## Dependencies

The following dependencies must be resolved on the timelines indicated to avoid project schedule impacts:

<!-- TABLE_CONFIG: widths=[32, 20, 18, 30] -->
| Dependency | Owner | Required By | Impact if Delayed |
|------------|-------|-------------|-------------------|
| AWS account provisioned with Bedrock access in us-west-2 | Amatra IT | Week 1 | Blocks Phase 2 architecture design |
| Okta admin credentials and SSO configuration provided | Amatra IT | Week 2 | Delays Cognito migration design (Phase 2) |
| Existing artifact templates (Word/Excel/PowerPoint) provided | Head of Solutions | Week 2 | Delays template ingestion pipeline design |
| Representative client briefs for testing provided | Head of Solutions | Week 20 | Delays functional testing and UAT start |
| Security design review and approval | Security & Compliance Lead | Week 8 | Blocks start of Phase 3 development |
| UAT participants identified and committed | Head of Solutions | Week 20 | Delays UAT scheduling |
| Go-live written approval from CTO and VP Engineering | CTO, VP Engineering | Week 26 | Blocks Phase 1 production deployment |
| Okta decommission approval | Security & Compliance Lead | Week 28 | Delays final Cognito cutover |

---

# Investment Summary

**Large-Complexity Implementation:** This pricing reflects a fully serverless, multi-environment AWS platform with Amazon Bedrock AI generation, Okta-to-Cognito identity migration, SOC 2 Type II compliance controls, 7+ artifact types, and a 9-month phased delivery programme. The scope is classified as **Large** based on 7+ artifact types, SOC 2 Type II + GDPR compliance requirements, three deployment environments, and 99.9% availability SLA.

## Total Investment

The following table presents the 3-year total cost of ownership across professional services and infrastructure, reconciled against the infrastructure cost model and level-of-effort estimate:

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[24, 13, 13, 13, 11, 11, 15] -->
| Cost Category | Year 1 List | Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------|------------|--------|--------|--------------|
| Professional Services | $375,000 | ($30,000) | $345,000 | $0 | $0 | $345,000 |
| Cloud Infrastructure | $61,348 | ($5,000) | $56,348 | $61,348 | $61,348 | $179,044 |
| Software Licenses | $1,632 | $0 | $1,632 | $1,632 | $1,632 | $4,896 |
| Connectivity | $173 | $0 | $173 | $173 | $173 | $519 |
| Support & Maintenance | $6,120 | $0 | $6,120 | $6,120 | $6,120 | $18,360 |
| **TOTAL INVESTMENT** | **$444,273** | **($35,000)** | **$409,273** | **$69,273** | **$69,273** | **$547,819** |
<!-- END COST_SUMMARY_TABLE -->

*Professional Services figures are derived from the Level-of-Effort Estimate. Infrastructure figures are derived from the Infrastructure Cost Model. Year 1 infrastructure figures reflect the Large sizing tier (90M Bedrock tokens/month, 50M Lambda requests/month, 200 GB DynamoDB, 2 TB S3). Years 2 and 3 infrastructure costs reflect steady-state operation with no additional professional services investment.*

## Partner Credits

Two categories of credits reduce the Year 1 investment, both applied in Year 1 only:

**Professional Services Credits ($30,000 — Year 1 only):**
- AWS Partner Network (APN) Advanced Tier Services Credit: **$15,000** — applied to solution architecture, Bedrock integration, and AWS-native implementation services, available through the vendor's APN Advanced Consulting Partner status
- AWS Bedrock Early Adopter Incentive: **$5,000** — AWS Bedrock partner implementation incentive for generative AI production workloads; available to APN partners deploying Bedrock in a production customer environment
- Implementation Volume Discount: **$10,000** — approximately 3% volume discount applied to professional services for engagements exceeding $300K total

**Infrastructure Credits ($5,000 — Year 1 only):**
- AWS Activate Credit: **$5,000** — AWS Startup program credit applied against Year 1 cloud consumption (Bedrock inference, Lambda, S3, DynamoDB)

Total Year 1 credits amount to **$35,000** (8% reduction on Year 1 list price). Credits are subject to AWS partner program approval terms, and the vendor manages all credit application paperwork on behalf of Amatra.

## Cost Components

**Professional Services ($375,000 list / $345,000 net):** The professional services investment covers the complete 9-month engagement across all five phases: Discovery & Assessment, Architecture Design, Development & Build, Testing & Validation, and Deployment & Hypercare. The team includes a Solution Architect, Project Manager, ML/AI Engineer, Cloud Engineer, Security Engineer, DevOps Engineer, QA Engineer, and Technical Writer. Resource effort spans approximately 1,800 total hours at blended rates of $125–$275/hour depending on role. PS credits of $30,000 are applied in Year 1 only; no PS fees are incurred in Years 2 or 3.

**Cloud Infrastructure ($61,348/year):** The primary infrastructure cost driver is Amazon Bedrock (Claude 3 Sonnet inference at 90M tokens/month — approximately $54,000/year). Secondary costs include AWS Business Support ($6,120/year), Amazon DynamoDB ($600/year), Amazon S3 ($552/year), Amazon CloudWatch ($1,800/year), Amazon API Gateway ($2,100/year), AWS Step Functions ($600/year), and minor costs across SQS, Cognito, SES, ECR, WAF, CloudFront, CloudTrail, Secrets Manager, and PrivateLink. A $5,000 AWS Activate credit reduces Year 1 net infrastructure cost to approximately $56,348. The 3-year infrastructure total is $179,044.

**Software Licenses ($1,632/year):** Datadog Pro APM monitoring for 5 Lambda/API Gateway hosts ($1,380/year) and GitHub Actions Team plan for CI/CD pipelines ($252/year). Total 3-year software cost is $4,896.

**Connectivity ($173/year):** AWS PrivateLink VPC interface endpoints for 2 private service connections ($173/year). Total 3-year connectivity cost is $519.

**Support & Maintenance ($6,120/year):** AWS Business Support plan providing 24×7 access to cloud support engineers, TAM access, and infrastructure event management (~10% of monthly AWS charges). Total 3-year support cost is $18,360.

## Payment Terms

Professional services are invoiced on a milestone basis aligned to phase-gate deliverables. The following payment schedule applies:

<!-- TABLE_CONFIG: widths=[28, 30, 18, 24] -->
| Payment | Milestone | Amount | Timing |
|---------|-----------|--------|--------|
| Payment 1 — Mobilisation | Contract execution | $75,000 | Due at contract signing (20%) |
| Payment 2 — Design Complete | Architecture Design Document approved (M2) | $75,000 | Due within 30 days of M2 sign-off |
| Payment 3 — Dev Complete | Platform built and in testing (M3) | $112,500 | Due within 30 days of M3 sign-off |
| Payment 4 — Phase 1 Go-Live | Pre-Sales MVP in production (M5) | $75,000 | Due within 30 days of M5 sign-off |
| Payment 5 — Final Delivery | Hypercare complete and project closed (M9) | $37,500 | Due within 30 days of M9 sign-off |
| **Total Professional Services** | | **$375,000** | |

AWS infrastructure costs are billed directly to Amatra's AWS account on a monthly consumption basis. Software license costs (Datadog, GitHub Actions) are invoiced monthly or annually per vendor billing cycles. Partner credits ($30,000 PS + $5,000 infrastructure) are applied to applicable invoices in Year 1 upon credit programme approval.

## Invoicing & Expenses

Professional services invoices are issued within 5 business days of milestone sign-off and are payable within 30 days of invoice date. Late payments accrue interest at 1.5% per month on the outstanding balance. Reasonable, pre-approved travel and accommodation expenses incurred for on-site work at Amatra's Austin, Texas headquarters are reimbursed at cost with supporting receipts. Remote-first engagement is the default; on-site travel is expected for project kickoff, UAT, and go-live events only.

---

# Terms & Conditions

## General Terms

This Statement of Work is governed by and incorporated into the Master Services Agreement (MSA) executed between Amatra and the consulting partner. In the event of any conflict between this SOW and the MSA, the MSA prevails unless this SOW explicitly states otherwise. This SOW constitutes the complete agreement between the parties for the services described herein.

## Scope Changes

Any request to change the scope, timeline, resources, or budget defined in this SOW must be submitted as a formal Change Request (CR). A CR must include: a description of the requested change, the business justification, the estimated impact on timeline, cost, and resources, and the approval authority. The vendor will respond to any CR with a written Change Order within 5 business days. Changes to scope are not authorised until a Change Order is signed by both parties. Minor clarifications that do not affect timeline or budget do not require a formal CR.

## Intellectual Property

Upon receipt of final payment, Amatra owns all custom deliverables produced under this SOW, including: the deployed AWS infrastructure configuration, Terraform IaC modules, Lambda function code, Bedrock prompt templates, and all documentation. The vendor retains ownership of its pre-existing methodologies, frameworks, prompt engineering techniques, and reusable tools and libraries that are incorporated into deliverables but are not custom-developed for this engagement. The vendor grants Amatra a perpetual, non-exclusive, royalty-free licence to use any vendor intellectual property incorporated into the deliverables.

## Service Levels

The vendor commits to the following service levels during the engagement: response to client communications within 1 business day during active project phases; delivery of all formal deliverables within the timelines defined in the Deliverables & Timeline section, subject to the assumptions and dependencies stated in the Handover & Support section; and a 30-day warranty period post-go-live (in addition to the 8-week hypercare) during which the vendor will remediate defects in deliverables at no additional charge, provided the defects are caused by errors in the vendor's work and not by changes made by Amatra post-go-live.

## Liability

The vendor's total liability under this SOW shall not exceed the total fees paid by Amatra under this SOW in the 12 months preceding the event giving rise to the claim. Neither party shall be liable for indirect, incidental, special, or consequential damages. The vendor is not responsible for third-party service outages (including AWS service events or Bedrock model availability), delays caused by Amatra's failure to meet the assumptions and dependencies stated herein, or defects arising from changes made by Amatra to deliverables after final acceptance.

## Confidentiality

Both parties agree to maintain the confidentiality of all proprietary information exchanged under this SOW in accordance with the NDA and confidentiality provisions of the MSA. Amatra client brief data and generated artifacts are classified as Confidential and are handled in accordance with the data handling procedures described in the Security & Compliance section of this SOW. All customer data is stored exclusively in AWS us-west-2 and is not transferred outside the United States.

## Termination

Either party may terminate this SOW for cause upon 30 days written notice if the other party materially breaches this SOW and fails to cure the breach within the notice period. Amatra may terminate for convenience upon 30 days written notice, in which case Amatra shall pay for all services rendered and reasonable wind-down costs up to the date of termination. Upon termination, the vendor will deliver all work-in-progress deliverables and provide a reasonable handover to Amatra or a successor vendor.

## Governing Law

This SOW shall be governed by the laws of the State of Texas, without regard to its conflict of laws provisions. Any disputes arising under this SOW that cannot be resolved through good-faith negotiation shall be submitted to binding arbitration in Austin, Texas, in accordance with the rules of the American Arbitration Association.

---

# Sign-Off

By signing below, both parties agree to the scope, deliverables, roles, timeline, investment, and terms outlined in this Statement of Work. This SOW is effective as of the date of the last signature below.

**Client Authorized Signatory (Amatra):**

Name: __________________________
Title: __________________________
Signature: ______________________
Date: __________________________

**Service Provider Authorized Signatory:**

Name: __________________________
Title: __________________________
Signature: ______________________
Date: __________________________

---

*This Statement of Work constitutes the complete agreement between the parties for the services described herein and supersedes all prior negotiations, representations, or agreements relating to the subject matter of this SOW. All amendments must be made in writing and signed by both parties.*
