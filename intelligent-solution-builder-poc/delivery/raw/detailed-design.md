---
document_title: Detailed Design Document
solution_name: Amatra Intelligent Solution Builder
document_version: "1.0"
author: Lead Solutions Architect
last_updated: 2025-06-15
technology_provider: aws
client_name: Amatra
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

The Amatra Intelligent Solution Builder is a fully serverless, AI-powered platform hosted on AWS us-west-2 that automates the production of consulting-grade engagement artifacts from a short client brief. This Detailed Design Document provides the complete technical blueprint for implementation — translating the architecture decisions documented in the Statement of Work and Solution Briefing into implementation-ready specifications for every component, integration, data structure, security control, and operational procedure.

The platform addresses a critical business constraint: Amatra's pre-sales and delivery teams currently spend approximately three weeks producing each engagement artifact package by hand. This manual process caps proposal throughput at approximately eight active engagements per quarter and introduces quality variability across consultants. The Intelligent Solution Builder eliminates this constraint by orchestrating Amazon Bedrock Claude model invocations across seven or more artifact-specific prompt templates, storing results in Amazon S3, tracking state in Amazon DynamoDB, and delivering artifacts through a secure REST API authenticated by Amazon Cognito. The architecture is event-driven and fully asynchronous to accommodate the 30–60 minute generation windows inherent to multi-artifact Bedrock invocations.

This document is the authoritative technical reference for the implementation team throughout all five project phases (Discovery, Architecture Design, Development & Build, Testing & Validation, and Deployment & Hypercare), spanning nine months to General Availability by Q1 2027. Every design decision herein traces directly to a commitment in the Statement of Work or Solution Briefing.

## Purpose

This document defines the detailed technical design for the Amatra Intelligent Solution Builder platform. It serves as the single source of truth for solution architects, cloud engineers, ML/AI engineers, security engineers, DevOps engineers, and QA engineers throughout the engagement. The document specifies architecture components, data models, integration patterns, security controls, infrastructure configuration, and implementation sequencing at a level of detail sufficient to build and validate the complete system without additional design input.

## Scope

**In-scope:**

- End-to-end serverless AWS platform design: Amazon API Gateway, AWS Lambda, Amazon Bedrock (Claude 3 Sonnet), AWS Step Functions, Amazon SQS, Amazon DynamoDB, Amazon S3, Amazon Cognito, Amazon CloudWatch, AWS X-Ray, AWS WAF, AWS CloudTrail, AWS KMS, AWS Secrets Manager, AWS PrivateLink, Amazon SES, Amazon CloudFront, Amazon ECR
- Okta-to-Cognito identity migration: User Pool design, group structure, OAuth 2.0/OIDC flows, per-user and global usage-limit enforcement, admin governance API
- Artifact generation pipeline for all 7+ artifact types (discovery questionnaire, solution briefing, statement of work, infrastructure cost model, level-of-effort estimate, detailed design, Terraform automation)
- Async job orchestration via AWS Step Functions standard workflows and Amazon SQS FIFO queues
- CI/CD pipeline using GitHub Actions with Terraform plan/apply gates and branch protection
- Terraform IaC modules covering all AWS services across Dev, Staging, and Production environments
- SOC 2 Type II compliance controls: encryption, CloudTrail audit logging, IAM least-privilege, WAF, Secrets Manager, GDPR data-handling policies
- CloudWatch observability stack: dashboards, Lambda alarms, Bedrock token-usage metrics, AWS X-Ray distributed tracing
- Legacy EC2 monolith decommission and Google Workspace manual workflow retirement
- 8-week hypercare post-go-live support scope

**Out-of-scope:**

- Ongoing managed services or post-hypercare production support
- New artifact template formats beyond the 7 defined artifact types
- Integration with any external client systems (platform serves Amatra internal teams only)
- Multi-region deployment (us-west-2 only)
- Custom mobile application development
- Third-party SIEM or EDR tooling beyond specified controls
- Formal penetration testing by an accredited third party
- Public-facing customer portal or white-label deployment

## Assumptions & Constraints

- AWS account with Bedrock, Lambda, DynamoDB, S3, API Gateway, and Cognito service limits for the Large tier is provisioned in us-west-2 before Week 1
- All existing Word, Excel, and PowerPoint artifact templates are delivered to the vendor team within 2 weeks of Phase 1 kickoff
- Okta administrator credentials and SSO configuration details are provided within 2 weeks of Phase 1 kickoff
- Representative client briefs for testing and UAT are provided by the Head of Solutions within 2 weeks of Phase 3 kickoff
- GitHub is the approved source control platform; GitHub Actions is approved for CI/CD
- A Terraform state backend using S3 and DynamoDB locking is available for state management
- Amatra's Google Workspace instance remains operational as a fallback through Phase 1 and is sunset only after Phase 1 GA is stable for 30 days
- No regulatory approvals (government, healthcare, financial) are required before go-live; compliance scope is limited to SOC 2 Type II and GDPR-aligned data handling
- All user data must be stored exclusively in us-west-2 (United States data residency)
- Datadog Pro (5 hosts) and GitHub Actions Team plan are approved software licenses

## References

- Statement of Work (SOW) — Amatra Intelligent Solution Builder, v1.0, June 2025
- Solution Briefing — Amatra Intelligent Solution Builder
- Infrastructure Cost Model (infrastructure-costs.csv)
- Level-of-Effort Estimate (level-of-effort-estimate.csv)
- AWS Well-Architected Framework — Serverless Lens
- SOC 2 Trust Service Criteria (AICPA TSC 2017)
- GDPR Regulation (EU) 2016/679 — Article 25 (Data Protection by Design)
- OWASP API Security Top 10 (2023)
- Amazon Bedrock Claude 3 Model Card

---

# Business Context

Amatra operates as a B2B SaaS company in the cloud consulting and professional-services-automation space, headquartered in Austin, Texas, serving enterprise clients across North America. The company's pre-sales and delivery teams have historically produced every engagement artifact entirely by hand from Google Workspace documents and Word, Excel, and PowerPoint templates — a process that takes approximately three weeks per client engagement package. This manual workflow constrains the company's growth by capping proposal throughput and introducing quality variability. The Intelligent Solution Builder platform is the strategic response to this constraint, replacing manual drafting with AI-powered generation while simultaneously modernising Amatra's identity infrastructure, retiring legacy technical debt, and establishing a SOC 2 Type II compliance posture.

## Business Drivers

- **Throughput Constraint:** The current manual workflow limits the pre-sales team to approximately eight active engagements per quarter. The three-week artifact turnaround creates a pipeline bottleneck that prevents revenue growth without a commensurate increase in headcount. The platform removes this constraint by automating artifact production, targeting 24 engagements per quarter (3× throughput increase) within 90 days of GA.
- **Quality and Consistency:** Each consultant produces artifacts with different levels of detail, varying terminology, and divergent formatting. Quality reviews consume additional hours and occasional rework delays client delivery. The platform enforces consistent, consulting-grade output through structured Bedrock prompt templates and an embedded QA validation pipeline, targeting a ≥90% first-review pass rate on all generated artifacts.
- **Identity Modernisation:** The current identity provider (Okta) must be migrated to Amazon Cognito as part of this initiative. Cognito provides native integration with the AWS platform, supports per-user and global monthly usage-limit enforcement, and enables an admin governance group with elevated API scopes — capabilities not efficiently available in the legacy Okta configuration.
- **Legacy Technical Debt Retirement:** A legacy EC2 monolith hosts the current solution-builder function and represents a single point of failure with no scalability. Decommissioning this monolith and retiring the Google Workspace manual workflow eliminates operational risk and consolidates the platform on a modern, maintainable serverless architecture.
- **Compliance and Governance:** Amatra's enterprise client base requires SOC 2 Type II certification and GDPR-aligned data handling. The platform must be designed from the ground up with the controls necessary to produce a SOC 2 evidence package and maintain data residency in the United States (us-west-2 only).
- **Flagship Client Retention:** The Phase 1 Pre-Sales MVP hard deadline of 30 September 2026 is driven by Amatra's flagship client annual renewal on 31 January 2027. Demonstrating automated, high-quality artifact delivery before the renewal window is a critical business objective.

## Workload Criticality & SLA Expectations

The platform supports Amatra's core revenue-generation activities and is classified as business-critical. All SLA targets below are binding commitments from the Statement of Work and govern platform design decisions throughout this document.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Metric | Target | Measurement Method | Priority |
|--------|--------|--------------------|----------|
| Platform Availability | 99.9% monthly | CloudWatch uptime monitoring (API Gateway 5xx rate) | Critical |
| Artifact Generation Time | ≤ 90 minutes (under peak load of 10 concurrent jobs) | Step Functions execution duration | High |
| API Response Time (job submission) | < 2 seconds (P95) | API Gateway CloudWatch P95 latency | High |
| RTO | 4 hours | DR test validation | Critical |
| RPO | 1 hour | DynamoDB PITR and S3 cross-region replication lag | Critical |
| Artifact QA First-Pass Rate | ≥ 90% | UAT and production QA sampling | Critical |
| Identity Migration Success | 100% of Okta users migrated | Cognito login success rate post-cutover | Critical |
| Severity 1 Incident Response | 1-hour response, 4-hour resolution | Incident tracking (Jira) | Critical |
| Severity 2 Incident Response | 4-hour response, 8-hour resolution | Incident tracking (Jira) | High |

## Compliance & Regulatory Factors

- **SOC 2 Type II:** The platform is designed to satisfy all five Trust Service Criteria (Security, Availability, Processing Integrity, Confidentiality, and Privacy). SOC 2 controls are implemented and evidenced throughout the build and testing phases, with the final evidence package delivered at project close.
- **GDPR-Aligned Data Handling:** All customer data (client briefs and generated artifacts) is stored exclusively in AWS us-west-2, satisfying United States data residency requirements. Data subject request procedures covering access, rectification, and erasure of stored client brief data are documented and operational at GA.
- **OWASP API Security:** The API Gateway endpoint is hardened against OWASP API Security Top 10 vulnerabilities through AWS WAF rule sets, validated during security testing in Phase 4.

## Success Criteria

- Artifact turnaround reduced from approximately three weeks to under two business days by Phase 1 GA (30 September 2026)
- Proposal throughput increased from approximately eight to ≥24 active engagements per quarter within 90 days of GA
- Consulting hours per engagement reduced by ≥40% compared to the manual baseline
- Platform availability of 99.9% measured monthly in production (us-west-2)
- Generated artifact first-review QA pass rate of ≥90% within 8 weeks of Phase 1 GA
- 100% of in-scope Okta users successfully migrated to Cognito with no access disruption
- SOC 2 Type II readiness evidence package delivered at project close
- Legacy EC2 monolith decommissioned with zero data loss
- All user data stored exclusively in us-west-2

---

# Current-State Assessment

The current-state assessment documents the legacy systems and manual processes that the Amatra Intelligent Solution Builder platform will replace or retire. Understanding the current environment is essential to deriving migration requirements, establishing a cutover strategy, and identifying integration risks.

## Application Landscape

Amatra's current pre-sales and delivery workflow relies on a combination of a legacy monolith application and manual Google Workspace tooling. The following table summarises the in-scope applications and their disposition in the new platform.

<!-- TABLE_CONFIG: widths=[25, 30, 25, 20] -->
| Application | Purpose | Technology | Disposition |
|-------------|---------|------------|-------------|
| Legacy EC2 Solution Builder | Houses legacy solution-builder function; single point of failure | EC2 instance (monolith), unspecified runtime | Retire (decommission) |
| Google Workspace Manual Workflow | Manual artifact drafting, collaboration, and review for all engagement types | Google Docs, Sheets, Slides | Retire (sunset post-GA) |
| Okta Identity Provider | User authentication and SSO for Amatra internal users | Okta (SaaS) | Migrate to Amazon Cognito |
| Word/Excel/PowerPoint Templates | Source templates for all 7+ artifact types | Microsoft Office (manual authoring) | Ingest into generation pipeline |

## Infrastructure Inventory

The legacy infrastructure is limited in scope — the current solution-builder function is embedded in a single EC2 monolith. The following inventory documents the components subject to decommission or migration.

<!-- TABLE_CONFIG: widths=[20, 15, 35, 30] -->
| Component | Quantity | Specifications | Notes |
|-----------|----------|----------------|-------|
| EC2 Instance (Legacy Monolith) | 1 | Unspecified instance type; single AZ; no auto-scaling | Single point of failure; no HA; decommission in Phase 5 |
| Okta Tenant | 1 | Approximately 120 users; 3 functional groups | Full user and group migration to Cognito required |
| Google Workspace | 1 | Shared Drive for artifact templates and drafts | Templates ingested into S3; workflow retired post-GA |
| Word/Excel/PowerPoint Templates | 7+ | Manual templates for all artifact types | Ingested into S3 template store; used by generation pipeline |

## Dependencies & Integration Points

- The legacy EC2 monolith must remain operational until Phase 1 GA (30 September 2026) as a fallback, ensuring no disruption to the pre-sales team during the transition period
- Okta SSO DNS cutover is the critical dependency for Phase 1 GA — the cutover must be validated with a ≥95% user login success rate before the legacy Okta federation is disabled
- Google Workspace serves as the manual fallback workflow and must remain accessible until Phase 1 GA is confirmed stable for 30 days, at which point the workflow is formally sunset
- All Word, Excel, and PowerPoint templates must be ingested into the S3 template store before the artifact generation pipeline can be fully tested in Phase 3

## Network Topology

The current environment does not have a formal private cloud network. The legacy EC2 monolith and Okta SaaS are accessed over the public internet with no documented VPC or private endpoint architecture. The new platform replaces this with a purpose-built VPC in us-west-2 using private subnets and AWS PrivateLink endpoints, as detailed in the Infrastructure & Operations section.

## Security Posture

The current environment presents several security gaps that the new platform directly addresses. The legacy EC2 monolith operates without documented IAM least-privilege policies or SOC 2 controls. Okta provides SSO but without the usage-limit enforcement and admin governance group capabilities required for the new platform. There is no CloudTrail audit logging, no encryption-at-rest inventory, and no formal incident response procedure in the current environment. The new platform closes all identified gaps through the security architecture described in the Security & Compliance section.

## Performance Baseline

The following baseline measurements characterise the current manual workflow performance against which the new platform's improvements will be measured:

- Average artifact package turnaround: approximately 3 weeks per engagement
- Active engagements per quarter: approximately 8
- Consulting hours per engagement: baseline to be formally measured during Phase 1 discovery; estimated at 40–60 hours per engagement package
- Artifact first-review QA pass rate: variable; no formal measurement exists; estimated at 60–70% based on stakeholder interviews
- Platform availability: not applicable (no automated platform; manual workflow)

## Gap Analysis

The following gap analysis maps the critical deficiencies in the current state to the target capabilities delivered by the Intelligent Solution Builder platform.

<!-- TABLE_CONFIG: widths=[33, 34, 33] -->
| Current State | Gap | Target State |
|---------------|-----|--------------|
| Manual artifact drafting — 3-week turnaround per engagement | No automation; human effort required for every artifact | AI-powered Bedrock generation — under 2 business days turnaround |
| ~8 active engagements per quarter | Throughput capped by manual production time | ≥24 active engagements per quarter (3× throughput) |
| Inconsistent artifact quality; variable consultant output | No standardised generation pipeline or embedded QA | ≥90% first-review QA pass rate through structured Bedrock prompts |
| Legacy EC2 monolith — single point of failure, no scaling | No HA, no IaC, no CI/CD | Fully serverless AWS platform; 99.9% availability; 100% Terraform IaC |
| Okta identity — no usage-limit enforcement, no admin governance | No per-user or global usage controls; no admin API | Amazon Cognito with admin governance group and usage-limit enforcement |
| No CloudTrail audit logging or SOC 2 controls | No compliance posture | SOC 2 Type II readiness; full CloudTrail coverage; KMS encryption |
| Data residency not enforced | No formal data residency controls | All data exclusively in us-west-2; GDPR-aligned data handling |

---

# Solution Architecture

The Amatra Intelligent Solution Builder is designed as a fully serverless, event-driven, cloud-native platform deployed exclusively in AWS us-west-2. The architecture is built around three core principles: reliability for long-running AI generation jobs, security and compliance by design, and operational simplicity through AWS managed services. Every component is either AWS-managed or serverless, eliminating infrastructure operations overhead and enabling the 99.9% monthly availability target without dedicated server management.

The asynchronous job processing pattern is the central architectural decision. Because Amazon Bedrock Claude model invocations for multi-artifact generation jobs can run for 30–60 minutes, a synchronous Lambda-to-API response pattern is not viable — AWS Lambda has a maximum execution timeout of 15 minutes. The solution uses AWS Step Functions standard workflows (which support execution durations of up to one year) orchestrated by Amazon SQS FIFO queues to manage these long-running jobs. When a brief is submitted via the REST API, the client receives a job ID immediately. The Step Functions workflow orchestrates Bedrock invocations in the background, and the client polls a status endpoint or receives an Amazon SES email notification on completion.

Security is embedded at every architectural layer. Amazon Cognito enforces authenticated access with role-based scopes and MFA for admin users. AWS WAF protects the API Gateway endpoint from OWASP Top 10 attacks and rate-limit abuse. All inter-service connectivity is routed through AWS PrivateLink VPC interface endpoints, ensuring no data traverses the public internet between platform components. All data at rest is encrypted with AWS KMS customer-managed keys, and AWS CloudTrail captures all API activity for SOC 2 audit evidence.

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

**Figure 1: Amatra Intelligent Solution Builder — AWS Serverless Architecture.** The diagram illustrates the five logical layers of the platform: (1) API & Authentication Layer — API Gateway, WAF, Cognito; (2) Orchestration & Generation Layer — Lambda, SQS FIFO, Step Functions; (3) AI Generation Layer — Amazon Bedrock Claude 3 Sonnet; (4) Storage & State Layer — S3, DynamoDB; and (5) Observability & Security Layer — CloudWatch, X-Ray, CloudTrail, Secrets Manager.

## Architecture Principles

The following principles govern every design decision in this document and must be preserved throughout development and future evolution of the platform.

- **Async-First for Long-Running Jobs:** All generation jobs that invoke Amazon Bedrock are processed asynchronously via Step Functions + SQS. No synchronous Lambda execution path is permitted for Bedrock-dependent operations. This principle eliminates Lambda timeout risk and ensures reliability for 30–60 minute generation jobs.
- **Security by Design:** Security controls are implemented at every layer — authentication, authorisation, network, encryption, audit — rather than bolted on after build. Every AWS resource is provisioned with least-privilege IAM, KMS encryption, and CloudTrail coverage enabled from day one.
- **Immutable Infrastructure via IaC:** All AWS resources are provisioned and managed exclusively through Terraform. No manual changes to production resources are permitted. All changes must pass a Terraform plan review and automated test gate before apply.
- **Observability as a First-Class Concern:** CloudWatch dashboards, alarms, and X-Ray tracing are provisioned alongside every application component, not as an afterthought. Platform health is continuously visible to the operations team.
- **Managed Services Over Self-Managed:** All services used in the platform are AWS-managed or serverless. There are no self-managed EC2 instances, self-managed databases, or self-managed message brokers in the target architecture. This minimises operational overhead and maximises reliability.
- **Data Residency Enforcement:** All data — client briefs, generated artifacts, state records, audit logs — is stored exclusively in us-west-2. No cross-region replication of customer data is performed except for disaster recovery purposes, and the DR replica in us-east-1 is subject to the same access controls as the primary.

## Architecture Patterns

The following patterns are applied consistently across the platform.

- **Primary Pattern:** Event-Driven Serverless — brief submission triggers an SQS event, which drives a Step Functions workflow, which orchestrates Lambda-to-Bedrock invocations. All state transitions are event-driven with no polling loops in application code.
- **Data Pattern:** Command Query Responsibility Segregation (CQRS) — write operations (brief submission, job status updates, usage limit changes) are separated from read operations (job status polling, artifact retrieval, audit log queries) at the DynamoDB access-pattern level, with dedicated GSIs for query paths.
- **Integration Pattern:** REST API Gateway with Cognito Authoriser — all external integrations consume the single API Gateway REST API endpoint. No direct service-to-service access is permitted for external clients; all requests are mediated through the API layer.
- **Deployment Pattern:** Blue-Green via Lambda Aliases — production Lambda functions are deployed using Lambda aliases (blue/green), allowing instant traffic routing switches and rollback within 2 hours post-cutover.

## Component Design

The platform is composed of five logical layers, each implemented using purpose-built AWS managed services. The following table documents all major components, their purpose, technology, dependencies, and scaling behaviour.

<!-- TABLE_CONFIG: widths=[18, 25, 22, 18, 17] -->
| Component | Purpose | Technology | Dependencies | Scaling |
|-----------|---------|------------|--------------|---------|
| API Gateway (REST) | Single entry point for all platform operations | Amazon API Gateway (Regional) | Cognito Authoriser, Lambda handlers | Auto-scales; no capacity planning required |
| Cognito User Pool | User authentication, admin governance, usage-limit token scopes | Amazon Cognito | Lambda triggers, DynamoDB usage table | Managed; scales to 120 MAU with headroom |
| WAF Web ACL | OWASP Top 10 protection and rate limiting on API endpoint | AWS WAF v2 | API Gateway | Auto-scales with request volume |
| Brief Submission Lambda | Validates brief, enqueues SQS message, returns job ID | AWS Lambda (Python 3.12) | SQS FIFO, DynamoDB solution table | Concurrency auto-scales; reserved concurrency: 50 |
| Job Status Lambda | Returns current job status and artifact metadata | AWS Lambda (Python 3.12) | DynamoDB solution table | Concurrency auto-scales; reserved concurrency: 20 |
| Artifact Retrieval Lambda | Generates pre-signed S3 URL for artifact download | AWS Lambda (Python 3.12) | S3, DynamoDB solution table | Concurrency auto-scales; reserved concurrency: 20 |
| Admin Governance Lambda | CRUD operations for per-user and global usage limits | AWS Lambda (Python 3.12) | DynamoDB usage table, Cognito | Concurrency auto-scales; reserved concurrency: 10 |
| SQS FIFO Queue | Decouples API submission from Bedrock invocation pipeline | Amazon SQS (FIFO, message deduplication enabled) | Step Functions, Brief Submission Lambda | Managed; unlimited throughput |
| SQS Dead-Letter Queue | Captures failed generation jobs for investigation and retry | Amazon SQS (Standard) | CloudWatch alarm, SNS notification | Managed; triggers alert on any DLQ message |
| Step Functions Workflow | Orchestrates multi-step Bedrock artifact generation | AWS Step Functions (Standard) | Lambda workers, Bedrock, S3, DynamoDB | Parallel states for concurrent artifact invocations |
| Bedrock Orchestration Lambda | Assembles prompt context and invokes Bedrock model per artifact type | AWS Lambda (Python 3.12, 3008 MB) | Amazon Bedrock, S3, Secrets Manager | Concurrency auto-scales; reserved concurrency: 100 |
| Output Validation Lambda | Validates Bedrock output structure and completeness before storage | AWS Lambda (Python 3.12, 1024 MB) | S3, DynamoDB | Concurrency auto-scales; reserved concurrency: 50 |
| Artifact Store (S3) | Stores generated artifacts and source templates | Amazon S3 (SSE-KMS, versioned) | Lambda, CloudFront | Unlimited; lifecycle rules manage tiering |
| Solution State Table (DynamoDB) | Tracks solution records, job status, artifact metadata | Amazon DynamoDB (on-demand) | All Lambda functions | On-demand; auto-scales read/write capacity |
| Usage Tracking Table (DynamoDB) | Per-user and global monthly usage counters and limits | Amazon DynamoDB (on-demand) | Brief Submission Lambda, Admin Lambda | On-demand; auto-scales read/write capacity |
| CloudFront Distribution | CDN for static web assets served from S3 origin | Amazon CloudFront | S3 (origin), WAF | Managed global CDN; auto-scales |
| SES Notification | Sends job completion and error notification emails | Amazon SES | Step Functions (success/failure states) | Managed; auto-scales with notification volume |
| CloudWatch Observability | Centralised logs, metrics, alarms, and dashboards | Amazon CloudWatch + AWS X-Ray | All Lambda functions, Step Functions, API Gateway | Managed; scales with log volume |
| ECR Container Registry | Stores Lambda container images for deployment | Amazon ECR | GitHub Actions CI/CD pipeline | Managed; pay-per-GB |
| Secrets Manager | Stores and rotates all API keys and integration credentials | AWS Secrets Manager | Lambda functions, Bedrock integration | Managed; auto-rotation enabled |
| CloudTrail | Captures all AWS API activity for SOC 2 audit | AWS CloudTrail (multi-region trail) | S3 (log bucket), CloudWatch Logs | Managed; unlimited event capture |

## Technology Stack

The technology stack is entirely AWS-native or AWS-managed, consistent with the serverless-first architecture principle. All technology choices were made in the Statement of Work and are reflected here without modification.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Layer | Technology | Rationale |
|-------|------------|-----------|
| AI/ML Inference | Amazon Bedrock — Claude 3 Sonnet | Only AWS-native LLM service with Claude models; no egress to third-party AI providers; supports 200K token context window for multi-artifact generation; SOC 2 compliant |
| Async Orchestration | AWS Step Functions (Standard Workflows) | Supports execution durations up to 1 year — eliminates Lambda 15-min timeout risk for 30–60 min generation jobs; built-in error handling, retry logic, and parallel execution states |
| Queue | Amazon SQS FIFO | Exactly-once message delivery with deduplication IDs; decouples API submission from Bedrock pipeline; integrated with Step Functions polling |
| API Layer | Amazon API Gateway (REST, Regional) | Managed API hosting with Cognito authoriser integration; per-method throttling; WAF attachment; request/response validation |
| Compute | AWS Lambda (Python 3.12, container images via ECR) | Serverless compute; no server management; per-invocation billing; Lambda container images support large ML dependency sets via ECR |
| Identity | Amazon Cognito User Pools | Native AWS identity service; migrates Okta users; supports custom OAuth 2.0 scopes for admin group; integrates natively with API Gateway authoriser |
| Storage (Artifacts) | Amazon S3 (Standard + Intelligent-Tiering) | Unlimited scalable object store; SSE-KMS encryption; versioning; lifecycle policies for cost optimisation; cross-region replication for DR |
| Database (State) | Amazon DynamoDB (on-demand capacity) | Serverless NoSQL; sub-millisecond latency; on-demand scales with unpredictable workload; PITR enabled for RPO compliance |
| CDN | Amazon CloudFront | Global CDN for static assets; TLS enforcement; WAF integration; S3 origin |
| Encryption | AWS KMS (Customer-Managed Keys) | Customer-managed key rotation; separate CMKs per data classification tier; native integration with S3, DynamoDB, Secrets Manager |
| Secrets | AWS Secrets Manager | Centralised secret storage with automatic 30-day rotation; Lambda integration via SDK; eliminates plaintext credentials in environment variables |
| Networking | AWS PrivateLink (VPC Interface Endpoints) | All Lambda-to-service traffic stays on AWS private network; no internet egress for service calls; required for SOC 2 network isolation controls |
| WAF | AWS WAF v2 | OWASP Managed Rule Groups; rate limiting (1,000 req/min/IP); IP reputation lists; attached to API Gateway and CloudFront |
| Audit | AWS CloudTrail (multi-region) | Immutable API activity log; management events + data events on S3 and DynamoDB; ships to dedicated S3 bucket with Object Lock |
| Compliance Monitoring | AWS Config | Continuous configuration compliance evaluation against SOC 2 baseline; findings surfaced in Security Hub |
| Observability | Amazon CloudWatch + AWS X-Ray | CloudWatch for logs, metrics, and alarms; X-Ray for distributed tracing across Lambda chains and Step Functions |
| Notifications | Amazon SES | Transactional email for job completion and error notifications |
| Container Registry | Amazon ECR | Lambda container image storage; integrated with GitHub Actions deployment pipeline |
| IaC | Terraform (v1.8+) | 100% IaC coverage; modular structure for Dev/Staging/Prod; S3 + DynamoDB state backend |
| CI/CD | GitHub Actions | Automated build, test, Terraform plan/apply gates; branch protection; Lambda deployment automation |
| APM | Datadog Pro (5 hosts) | Application performance monitoring and distributed tracing for Lambda and API Gateway hosts |

---

# Security & Compliance

The security architecture implements defence-in-depth controls across preventative, detective, and responsive layers, designed to satisfy SOC 2 Type II Trust Service Criteria and GDPR-aligned data handling requirements. Security is not a layer added after the platform is built — every AWS resource is provisioned with encryption, IAM least-privilege, and audit coverage enabled from the moment it is created by Terraform.

## Identity & Access Management

All platform access is controlled through Amazon Cognito User Pools, which replace the existing Okta identity provider as part of this engagement. The Cognito User Pool is configured with three user groups: `presales-consultants`, `delivery-consultants`, and `admins`.

- **Authentication:** OAuth 2.0 with PKCE (Proof Key for Code Exchange) for all API clients. Cognito-issued JWTs are validated by the API Gateway Cognito authoriser on every request. Token expiry is set to 1 hour for access tokens and 30 days for refresh tokens.
- **Authorization:** Role-based access control via Cognito group membership and custom OAuth 2.0 scopes. The `admins` group is granted the `platform:admin` scope, which is required by the Admin Governance Lambda's API Gateway method policy. The `presales-consultants` group is granted the `artifacts:generate` and `artifacts:read` scopes. The `delivery-consultants` group is granted the `artifacts:read` scope only.
- **MFA:** Mandatory for all `admins` group users (TOTP or SMS). Strongly recommended (but optional) for all other users. MFA enforcement is implemented via Cognito User Pool advanced security mode.
- **Service Accounts:** Lambda execution roles are IAM roles, not Cognito users. Each Lambda function has a dedicated IAM execution role with only the specific DynamoDB table ARNs, S3 bucket prefixes, Bedrock model ARNs, and Secrets Manager ARNs it requires. Wildcard resource permissions are prohibited in all production IAM roles.

### Role Definitions

The following table documents the four operational roles, their permissions, and their access scope. All role assignments are managed via Cognito group membership, reviewed quarterly by the Security & Compliance Lead.

<!-- TABLE_CONFIG: widths=[20, 40, 40] -->
| Role | Permissions | Scope |
|------|-------------|-------|
| Admin | `platform:admin` scope — usage limit CRUD, audit log access, Cognito user management, CloudWatch dashboard access | All environments; production AWS console via IAM Identity Center with hardware MFA |
| Pre-Sales Consultant | `artifacts:generate`, `artifacts:read` — brief submission, job status polling, artifact retrieval for own solutions only | Production API only; no direct AWS resource access |
| Delivery Consultant | `artifacts:read` — artifact retrieval for assigned solutions | Production API only; no direct AWS resource access |
| Auditor | Read-only CloudTrail and CloudWatch log access via IAM Identity Center | All environments; read-only; no API access |

## Secrets Management

All API keys, integration credentials, and sensitive configuration values are stored in AWS Secrets Manager and accessed by Lambda functions at runtime via the AWS SDK. Direct use of plaintext credentials in Lambda environment variables is prohibited.

- The following secrets are managed in Secrets Manager: Bedrock API configuration parameters, Datadog API key, SES SMTP credentials, GitHub Actions deployment tokens, and any third-party integration keys added in future phases.
- All secrets are rotated automatically on a 30-day schedule using Secrets Manager's built-in Lambda rotation function.
- All access to Secrets Manager is logged to CloudTrail. Lambda functions access secrets via their IAM execution role (no hard-coded secret ARNs in code); secret ARNs are passed via environment variables at deploy time by Terraform.
- Secrets are tagged with `Owner`, `RotationPolicy`, `Classification`, and `Environment` metadata for governance and audit.

## Network Security

The platform is deployed within a dedicated VPC in us-west-2 with a private-subnet-first architecture. The following controls implement network isolation and traffic inspection.

- **Segmentation:** Lambda functions execute within private subnets only. All inbound traffic enters via the public-facing API Gateway endpoint (with WAF). No Lambda functions are directly internet-accessible. Database subnets are isolated from application subnets via security group rules.
- **PrivateLink Endpoints:** All Lambda-to-service traffic (S3, DynamoDB, Bedrock, Secrets Manager, SQS, SES) is routed through AWS PrivateLink VPC interface endpoints. No traffic traverses the public internet between platform components.
- **WAF:** AWS WAF v2 is attached to both the API Gateway endpoint and the CloudFront distribution. WAF rules include: AWS Managed Rules for OWASP Top 10 (CommonRuleSet, KnownBadInputsRuleSet), rate limiting at 1,000 requests per minute per source IP, and AWS IP Reputation List.
- **DDoS Protection:** AWS Shield Standard is included with WAF and CloudFront at no additional cost, providing protection against common network and transport layer DDoS attacks.
- **TLS Enforcement:** All inbound API traffic requires TLS 1.2 or higher. TLS 1.0 and 1.1 are explicitly disabled on all API Gateway endpoints and CloudFront distributions via security policy configuration.

## Data Protection

All data processed by the platform is classified as Confidential (client business information and generated consulting deliverables). The following controls protect data at rest and in transit.

- **Encryption at Rest:** All S3 buckets use SSE-KMS with customer-managed keys. DynamoDB tables are encrypted with KMS at rest. Secrets Manager secrets are encrypted with a dedicated KMS CMK. CloudTrail logs are encrypted with a dedicated KMS CMK. KMS automatic key rotation is enabled on all CMKs with a 365-day rotation schedule.
- **Encryption in Transit:** All data in transit uses TLS 1.2 or higher. This applies to API Gateway, CloudFront, Lambda-to-service calls through PrivateLink, and S3 pre-signed URL downloads. TLS certificate management is handled by AWS Certificate Manager (ACM) for API Gateway and CloudFront domains.
- **Key Management:** Four KMS CMKs are provisioned: (1) `amatra-artifacts-key` for S3 artifact buckets; (2) `amatra-database-key` for DynamoDB tables; (3) `amatra-secrets-key` for Secrets Manager; (4) `amatra-audit-key` for CloudTrail and CloudWatch Logs. Key policies grant access only to the specific Lambda IAM roles and AWS services that require them.
- **Data Masking:** Non-production environments (Dev and Staging) use synthetic client briefs only. Anonymised copies of real briefs may be used in Staging for UAT, with all personally identifiable information (PII) removed or substituted before transfer to the Staging environment. Production data is never copied to Dev.

## Compliance Mappings

The following table maps SOC 2 Trust Service Criteria to specific platform implementations. This mapping is the basis for the SOC 2 evidence package assembled during Phase 4.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Framework | Requirement | Implementation |
|-----------|-------------|----------------|
| SOC 2 — Security (CC6.1) | Logical access controls | Cognito User Pool with group-based OAuth 2.0 scopes; IAM least-privilege Lambda execution roles; MFA mandatory for admins |
| SOC 2 — Security (CC6.7) | Encryption of data in transit and at rest | SSE-KMS for all S3 and DynamoDB; TLS 1.2+ enforced on API Gateway and CloudFront; AWS WAF rate limiting |
| SOC 2 — Availability (A1.1) | Performance and availability monitoring | CloudWatch dashboards and alarms for all seven platform health indicators; 99.9% SLA target; DynamoDB PITR and S3 cross-region replication for DR |
| SOC 2 — Processing Integrity (PI1.1) | Complete and accurate processing | Output Validation Lambda checks structural completeness before artifact storage; Step Functions retry logic and DLQ for failed jobs; idempotency keys on all SQS messages |
| SOC 2 — Confidentiality (C1.1) | Confidential information protection | All artifacts classified Confidential; S3 bucket policies enforce TLS-only access and deny public access; data residency restricted to us-west-2 |
| SOC 2 — Privacy (P1.1) | Data collection and use | GDPR-aligned data handling procedures; explicit data classification in S3 object metadata; DynamoDB retention policies with automated deletion; documented data subject request process |
| GDPR — Art. 25 (Privacy by Design) | Data protection by design | Data residency in us-west-2 only; KMS encryption from day one; no plaintext credentials; MFA for privileged access |

## Audit Logging & SIEM Integration

Comprehensive audit logging ensures that every action taken on the platform is traceable to a specific user, role, and timestamp — a core requirement for SOC 2 Type II evidence.

- **What is Logged:** All AWS management-plane and data-plane API events via CloudTrail (including S3 object-level operations and DynamoDB table operations); all API Gateway requests and responses; all Lambda invocation errors and duration anomalies; all Cognito user authentication events (logins, MFA challenges, failed attempts, group membership changes); all usage limit changes (logged in DynamoDB with admin user ID and timestamp).
- **Retention:** CloudTrail logs are retained for 7 years in a dedicated, immutable S3 bucket with S3 Object Lock (WORM) enabled. CloudWatch Logs are retained for 1 year. DynamoDB audit records are retained for 3 years per the data retention policy.
- **SIEM Integration:** CloudTrail logs are shipped to CloudWatch Logs, where CloudWatch Metric Filters extract security-relevant events: root account logins, console sign-ins without MFA, IAM policy changes, and Security Group modifications. These filters trigger CloudWatch Alarms that notify the Security & Compliance Lead via SNS. AWS Security Hub aggregates findings from AWS Config compliance checks and CloudTrail anomaly detection for centralised visibility.

---

# Data Architecture

The data architecture defines how client brief data and generated artifacts are modelled, stored, validated, migrated, and governed throughout the platform lifecycle. All design decisions are aligned with the GDPR and SOC 2 requirements documented in the Security & Compliance section, and all data is stored exclusively in us-west-2.

## Data Model

### Conceptual Model

The platform operates on three core data domains: **Engagements** (the brief submitted by a pre-sales consultant), **Solutions** (the generated artifact package associated with an engagement), and **Users** (the Amatra employees interacting with the platform). An Engagement contains the client brief metadata and input parameters. A Solution references an Engagement and tracks the job status, generated artifact types, and S3 storage locations. User records in DynamoDB track per-user monthly usage counters against configurable limits.

### Logical Model

The following table documents the key DynamoDB entities, their attributes, relationships, and expected data volumes at the Large tier (24 engagements/quarter, 120 users).

<!-- TABLE_CONFIG: widths=[20, 25, 30, 25] -->
| Entity | Key Attributes | Relationships | Volume |
|--------|----------------|---------------|--------|
| Solution Record | `solution_id` (PK, UUID), `user_id` (GSI PK), `created_at`, `status` (QUEUED/PROCESSING/COMPLETE/FAILED), `brief_s3_key`, `artifact_manifest` (JSON list of artifact types and S3 keys), `error_detail` | Belongs to User; references Artifacts in S3 | ~96 records/year at 24 engagements/quarter; < 1 MB total table size at scale |
| Usage Record | `user_id` (PK), `month_key` (SK, format: `YYYY-MM`), `generation_count`, `token_count`, `user_limit_override`, `global_limit_at_creation` | Belongs to User; checked on every job submission | ~1,440 records/year (120 users × 12 months); < 1 MB total table size |
| Limit Config Record | `config_key` (PK, e.g., `global_monthly_limit`), `limit_value`, `updated_by`, `updated_at` | Read by Brief Submission Lambda on every submission | Fewer than 10 records; negligible size |
| Audit Record | `record_id` (PK, UUID), `event_type`, `user_id`, `timestamp`, `detail` (JSON) | References User and Solution | ~5,000 records/year; < 10 MB total size |

### S3 Object Structure

All artifacts and source templates are stored in the `amatra-artifacts-{env}` S3 bucket with the following key structure:

- `{solution_id}/brief/client-brief.json` — the original submitted brief in structured JSON format
- `{solution_id}/raw/{artifact_type}.md` — Bedrock-generated raw markdown output for each artifact type
- `{solution_id}/generated/{artifact_type}.docx` — populated Office document derived from the raw markdown
- `templates/{artifact_type}/template.docx` — source Word/Excel/PowerPoint template files (ingested from Amatra's Google Workspace)
- `prompts/{artifact_type}/prompt-template.txt` — versioned Bedrock prompt templates for each artifact type

## Data Flow Design

The following sequence describes how data moves through the platform from brief submission to artifact delivery. Each step is implemented as a discrete Lambda function or Step Functions state, ensuring observability and error isolation at every stage.

1. **Ingestion:** A pre-sales consultant submits a structured client brief via a POST request to the API Gateway `/briefs` endpoint. The Brief Submission Lambda validates the JSON schema, checks usage limits against the DynamoDB Usage Record, creates a Solution Record in the solution-state DynamoDB table with status `QUEUED`, stores the brief as `{solution_id}/brief/client-brief.json` in S3, and enqueues an SQS FIFO message containing the solution ID and job metadata.
2. **Orchestration:** AWS Step Functions polls the SQS FIFO queue via an EventBridge Pipes integration. The Step Functions standard workflow starts execution for the solution, updating the Solution Record status to `PROCESSING`.
3. **Prompt Assembly:** For each artifact type in the generation sequence (discovery questionnaire first, then solution briefing, then SOW, etc.), the Bedrock Orchestration Lambda retrieves the client brief from S3, loads the artifact-specific prompt template from the `prompts/` S3 prefix, injects brief context and prior-artifact context into the prompt, and invokes the Amazon Bedrock `InvokeModel` API with Claude 3 Sonnet.
4. **Validation:** The Output Validation Lambda receives the Bedrock response, checks structural completeness against the artifact type's validation schema (required sections, minimum word counts, table structure), and routes to a retry state if validation fails (up to 3 retries) or to storage if validation passes.
5. **Storage:** Validated raw markdown output is stored at `{solution_id}/raw/{artifact_type}.md` in S3. The Artifact Template Lambda populates the corresponding Word/Excel/PowerPoint template from the markdown content and stores the generated Office document at `{solution_id}/generated/{artifact_type}.docx`.
6. **Distribution:** On completion of all artifact types, the Step Functions workflow updates the Solution Record status to `COMPLETE`, stores the artifact manifest in the Solution Record, and triggers SES to send a job completion notification email to the consultant. The consultant retrieves artifacts by calling the Artifact Retrieval Lambda, which returns pre-signed S3 URLs (1-hour expiry) for each generated file.

## Data Migration Strategy

The data migration scope for this engagement is limited — the platform is primarily a greenfield build, but the following data migration activities are required:

- **Okta User Migration:** All approximately 120 Okta users and their group memberships are migrated to the Cognito User Pool using a scripted migration process. User passwords are not migrated (Cognito generates temporary passwords and requires users to set new passwords on first login). Group assignments are mapped from Okta groups to Cognito groups (`presales-consultants`, `delivery-consultants`, `admins`).
- **Artifact Template Ingestion:** All existing Word, Excel, and PowerPoint artifact templates are ingested into the `templates/` S3 prefix during Phase 3. Templates are versioned using S3 object versioning. The ingestion script is included in the Terraform/CI/CD pipeline as a one-time provisioning step.
- **Approach:** Scripted migration for Okta users (one-time); S3 upload for templates (one-time). No legacy data from the EC2 monolith is migrated into the new DynamoDB or S3 stores — historical data from the legacy system is archived to a separate S3 Glacier bucket and is not operationally imported.
- **Validation:** Okta-to-Cognito migration is validated by requiring ≥95% of users to successfully complete a test login against the Cognito User Pool in the Staging environment before Phase 1 production cutover. Template ingestion is validated by running the generation pipeline against each template type with a representative brief and confirming correct output structure.
- **Rollback:** If the Cognito migration cutover encounters login failures exceeding 5%, the Okta federation is temporarily re-enabled in Cognito (OIDC federation fallback), allowing users to continue authenticating via Okta while the migration issues are resolved.
- **Cutover:** The Okta-to-Cognito DNS/SSO cutover is the final step in Phase 5 (Production Deployment Phase 1). It is executed during a planned maintenance window communicated to all users 5 business days in advance.

## Data Governance

The following governance policies apply to all data processed and stored by the platform, and are implemented through a combination of S3 lifecycle rules, DynamoDB TTL attributes, Cognito access controls, and documented operational procedures.

- **Classification:** All data processed by the platform is classified as Confidential (client business information and generated consulting deliverables). PHI, PCI-DSS in-scope, and government-classified data are explicitly out of scope. Classification metadata is stored as S3 object tags (`Classification: Confidential`, `DataResidency: us-west-2`) applied by Lambda at write time.
- **Retention:** Solution records in DynamoDB are retained for 3 years and then deleted by a DynamoDB TTL attribute set at record creation. Generated artifacts in S3 are retained for 3 years in Standard tier, then transitioned to S3 Intelligent-Tiering, and archived to S3 Glacier Instant Retrieval at 5 years. Audit logs in CloudTrail are retained for 7 years. CloudWatch Logs are retained for 1 year.
- **Quality:** The Output Validation Lambda enforces data quality by checking that every generated artifact meets the minimum structural completeness requirements before storage. Artifacts that fail validation after 3 retries are stored in a `{solution_id}/failed/` S3 prefix and the Solution Record is updated with a `VALIDATION_FAILED` status and error detail for human review.
- **Access:** All access to artifact data is mediated through the API Gateway REST API. No direct access to S3 buckets, DynamoDB tables, or Lambda functions is permitted for end users. Pre-signed S3 URLs are used for artifact downloads (1-hour expiry). S3 Block Public Access is enforced at the account level.

---

# Integration Design

The Amatra Intelligent Solution Builder platform operates as an internal tool, not as a public-facing service. Integration points are intentionally limited to the REST API consumed by Amatra's internal users, the Amazon Bedrock model inference API, legacy system retirement integrations, and operational tooling. This section documents all integration patterns, API specifications, authentication flows, and messaging patterns in implementation-ready detail.

## External System Integrations

The following table documents all external and internal system integrations, their protocols, data formats, error handling approaches, and SLAs.

<!-- TABLE_CONFIG: widths=[18, 15, 15, 15, 22, 15] -->
| System | Type | Protocol | Format | Error Handling | SLA |
|--------|------|----------|--------|----------------|-----|
| Amazon Bedrock (Claude 3 Sonnet) | Async, per-artifact | AWS SDK (InvokeModel API) | JSON request, markdown response | 3 retries with exponential backoff; DLQ on permanent failure; CloudWatch alarm on 3+ consecutive failures | < 60 min per full artifact set |
| Amazon Cognito (User Pool) | Real-time | HTTPS / OAuth 2.0 (PKCE) | JWT (Cognito ID token + Access token) | Cognito-managed token validation; API Gateway rejects invalid/expired tokens with 401 | Managed service; 99.9% SLA |
| Amazon SES (email notifications) | Async (event-driven) | AWS SDK (SendEmail API) | Plain text + HTML email | 3 retries; failed sends logged to CloudWatch; non-blocking (job completion is not gated on email delivery) | Best-effort; < 5 min delivery |
| Okta (legacy identity provider) | One-time migration | Okta SCIM API / CSV export | JSON / CSV user records | Scripted migration with validation; OIDC federation fallback in Cognito for rollback | One-time; migration window: Phase 5 |
| Datadog (APM) | Real-time (agent-based) | HTTPS (Datadog Agent) | StatsD / Trace API | Agent buffering; data gaps are non-critical; CloudWatch is primary monitoring | Best-effort APM; < 30 sec latency |
| GitHub Actions (CI/CD) | Event-driven (push/PR) | GitHub Webhooks + OIDC | YAML workflow definitions | Failed pipelines block merge via branch protection; Terraform plan errors surface in PR review | Pipeline execution < 15 min |

## API Design

The platform exposes a single REST API via Amazon API Gateway. All endpoints are versioned under `/api/v1/`. The API follows REST conventions with JSON request and response bodies. OpenAPI 3.0 specification is maintained in the GitHub repository and referenced in the As-Built documentation deliverable.

- **Style:** REST (JSON over HTTPS)
- **Versioning:** URL path versioning (`/api/v1/`)
- **Authentication:** OAuth 2.0 Bearer token (Cognito-issued JWT) on all endpoints. Tokens are validated by the API Gateway Cognito authoriser on every request.
- **Rate Limiting:** AWS WAF rate limiting at 1,000 requests per minute per source IP across the API. Individual Lambda reserved concurrency limits provide secondary rate control per operation type.
- **Content-Type:** `application/json` for all request and response bodies. Pre-signed S3 URLs are returned in the artifact retrieval response body.

### API Endpoints

The following table documents all API endpoints in the Phase 1 MVP scope. Phase 2 endpoints for Terraform artifact generation are additive and follow the same patterns.

<!-- TABLE_CONFIG: widths=[10, 35, 20, 35] -->
| Method | Endpoint | Auth Scope | Description |
|--------|----------|------------|-------------|
| POST | /api/v1/briefs | `artifacts:generate` | Submit a client brief; returns `solution_id` and job status URL |
| GET | /api/v1/briefs/{solution_id}/status | `artifacts:read` | Poll job status; returns status enum and artifact manifest on COMPLETE |
| GET | /api/v1/briefs/{solution_id}/artifacts | `artifacts:read` | Retrieve pre-signed S3 download URLs for all generated artifacts (1-hour expiry) |
| GET | /api/v1/briefs/{solution_id}/artifacts/{artifact_type} | `artifacts:read` | Retrieve pre-signed S3 URL for a single artifact type |
| GET | /api/v1/briefs | `artifacts:read` | List all solutions submitted by the authenticated user (GSI query on `user_id`) |
| GET | /api/v1/admin/usage | `platform:admin` | Retrieve per-user and global monthly usage statistics |
| PUT | /api/v1/admin/usage/limits/user/{user_id} | `platform:admin` | Set per-user monthly generation limit |
| PUT | /api/v1/admin/usage/limits/global | `platform:admin` | Set global monthly generation limit |
| GET | /api/v1/admin/audit | `platform:admin` | Query DynamoDB audit records (paginated, date-range filtered) |
| GET | /api/v1/health | None (no auth required) | API health check endpoint for CloudWatch synthetic monitoring |

## Authentication & SSO Flows

The following describes the authentication flows used by platform clients and the service-to-service authentication pattern used internally.

- **User Authentication (Cognito PKCE Flow):** Users authenticate via the Cognito Hosted UI (or a custom login page in Phase 2) using the OAuth 2.0 Authorization Code flow with PKCE. On successful authentication, Cognito issues an access token (1-hour expiry) and a refresh token (30-day expiry). The access token is included as a Bearer token in all API requests. API Gateway validates the token signature against the Cognito JWKS endpoint, verifies the `aud` claim matches the API Gateway resource server ID, and verifies the required scope claim is present.
- **Admin MFA Flow:** Admin group users are required to complete TOTP or SMS MFA as part of the Cognito authentication flow before receiving tokens. The `platform:admin` scope is only included in tokens issued after successful MFA verification.
- **Service-to-Service Authentication (Lambda-to-AWS Services):** All Lambda functions authenticate to AWS services (S3, DynamoDB, Bedrock, SQS, Secrets Manager, SES) via their IAM execution role. No API keys or access key/secret pairs are used for Lambda-to-AWS service calls. IAM role assumption is managed transparently by the Lambda execution environment.
- **Token Refresh:** Clients use the Cognito refresh token endpoint to obtain new access tokens before expiry. The platform frontend (if built in Phase 2) handles token refresh automatically; the Phase 1 API is consumed by pre-sales consultants directly (CLI or Postman) until a frontend is added.

## Messaging & Event Patterns

The asynchronous job processing backbone of the platform relies on Amazon SQS FIFO queues and AWS Step Functions to decouple brief submission from long-running Bedrock invocations.

- **Queue Service:** Amazon SQS FIFO (`amatra-generation-queue-{env}.fifo`) with content-based deduplication enabled. Each message contains the `solution_id`, `user_id`, `artifact_types` list, and an idempotency key derived from `solution_id + submission_timestamp`. MessageGroupId is set to `solution_id` to prevent duplicate processing of the same solution. Message retention period is 4 days; messages that fail processing are moved to the Dead-Letter Queue after 3 delivery attempts.
- **Event Bus:** AWS EventBridge Pipes connects the SQS FIFO queue to the Step Functions standard workflow trigger, enabling automatic workflow execution on message arrival without a polling Lambda function.
- **Dead Letter Queue:** `amatra-generation-dlq-{env}` (SQS Standard) captures messages that have exceeded 3 delivery attempts. A CloudWatch alarm fires on any message arriving in the DLQ (`ApproximateNumberOfMessagesVisible > 0`), triggering an SNS notification to the operations team. DLQ messages include the full message body and failure reason for investigation.
- **Retry Policy:** Step Functions states for Bedrock invocations implement exponential backoff retry: `MaxAttempts: 3`, `BackoffRate: 2`, `IntervalSeconds: 30`. Bedrock throttling errors (`ThrottlingException`) and transient service errors (`ServiceUnavailableException`) trigger retries. `ValidationException` and `ModelNotReadyException` are treated as permanent failures and route to the error handling state (which updates the Solution Record to `FAILED` and triggers a failure notification SES email).

---

# Infrastructure & Operations

The infrastructure underpins every other aspect of the platform and is designed for 99.9% availability, full observability, automated deployment, and cost-efficient operations at the Large tier (90M Bedrock tokens/month, 50M Lambda requests/month, 200 GB DynamoDB, 2 TB S3). All infrastructure is provisioned exclusively via Terraform from the GitHub Actions CI/CD pipeline; no manual resource creation is permitted in any environment.

## Network Design

The platform is deployed within a dedicated VPC (`amatra-platform-vpc`, CIDR `10.10.0.0/16`) in us-west-2, spanning three Availability Zones (us-west-2a, us-west-2b, us-west-2c). The network architecture uses private subnets for all Lambda functions and reserves public subnets only for NAT Gateway egress.

- **VPC CIDR:** `10.10.0.0/16`
- **Public Subnets (NAT Gateways):** `10.10.0.0/24` (us-west-2a), `10.10.1.0/24` (us-west-2b), `10.10.2.0/24` (us-west-2c) — NAT Gateway per AZ for outbound egress; no inbound internet routes
- **Private Subnets (Lambda):** `10.10.10.0/24` (us-west-2a), `10.10.11.0/24` (us-west-2b), `10.10.12.0/24` (us-west-2c) — Lambda VPC configuration; no internet gateway route; all service connectivity via PrivateLink
- **Database Subnets:** Not applicable — DynamoDB is a fully managed serverless service accessed via PrivateLink; no EC2-hosted database instances exist in the architecture
- **PrivateLink Endpoints:** VPC interface endpoints for Amazon Bedrock, Amazon S3 (Gateway endpoint), Amazon DynamoDB (Gateway endpoint), AWS Secrets Manager, Amazon SQS, and Amazon SES. Gateway endpoints for S3 and DynamoDB are free; interface endpoints for Bedrock, Secrets Manager, SQS, and SES incur the $7.20/endpoint/month cost modelled in the infrastructure cost file (2 billed interface endpoints at $173/year)
- **Outbound Egress:** NAT Gateway in each public subnet routes Lambda outbound traffic (SES, external webhook calls) through an Internet Gateway. Security group rules restrict Lambda outbound traffic to the PrivateLink endpoints and the NAT Gateway. Outbound IP addresses are documented and communicated to Amatra IT for firewall allowlisting.

## Compute Sizing

The following table documents the Lambda function configurations derived from the Large tier sizing parameters (50M Lambda requests/month, 90M Bedrock tokens/month). Memory and timeout settings are tuned for each function's workload characteristics.

<!-- TABLE_CONFIG: widths=[30, 20, 15, 15, 20] -->
| Lambda Function | Memory (MB) | Timeout (s) | Reserved Concurrency | Trigger |
|-----------------|-------------|-------------|----------------------|---------|
| Brief Submission | 512 | 30 | 50 | API Gateway POST /briefs |
| Job Status | 256 | 10 | 20 | API Gateway GET /briefs/{id}/status |
| Artifact Retrieval | 256 | 10 | 20 | API Gateway GET /briefs/{id}/artifacts |
| Admin Governance | 512 | 30 | 10 | API Gateway PUT/GET /admin/* |
| Bedrock Orchestration | 3008 | 900 | 100 | Step Functions (invoked per artifact type) |
| Output Validation | 1024 | 60 | 50 | Step Functions (invoked after each Bedrock response) |
| Artifact Template Population | 2048 | 120 | 30 | Step Functions (invoked per artifact on validation pass) |
| SES Notification | 256 | 10 | 10 | Step Functions (success/failure terminal states) |
| Health Check | 128 | 5 | 5 | CloudWatch Synthetics (scheduled every 1 min) |

## High Availability Design

The platform achieves the 99.9% monthly availability SLA through the inherent availability properties of AWS serverless managed services, combined with the following explicit HA design decisions.

- **Multi-AZ Lambda Execution:** Lambda functions configured with the VPC subnets spanning us-west-2a, us-west-2b, and us-west-2c. Lambda automatically distributes invocations across available AZs; a single AZ failure does not impact function availability.
- **Multi-AZ DynamoDB:** Amazon DynamoDB on-demand is natively multi-AZ within us-west-2. Data is replicated synchronously across three AZs. There is no single point of failure in the database layer.
- **Multi-AZ SQS:** Amazon SQS FIFO is natively durable and multi-AZ within the region. Messages are replicated across multiple AZs before the SQS `SendMessage` API returns success.
- **API Gateway Regional Endpoint:** The regional API Gateway endpoint is inherently multi-AZ. AWS manages availability of the API Gateway control plane; the platform's Lambda functions are the only availability dependency.
- **Failover Strategy:** Because all platform components are AWS-managed serverless, traditional active-passive failover is not applicable. The HA strategy is: (1) use only multi-AZ managed services; (2) implement Lambda reserved concurrency to prevent noisy-neighbour starvation; (3) implement SQS message retention (4 days) and DLQ to ensure no jobs are lost during partial service disruptions.
- **Health Checks:** CloudWatch Synthetics runs a canary every 1 minute against the `/api/v1/health` endpoint. A failure rate above 1% over 5 minutes triggers the `Platform-Availability-Critical` alarm.

## Disaster Recovery

The following DR design meets the RTO of 4 hours and RPO of 1 hour committed in the Statement of Work.

- **RPO (1 hour):** DynamoDB Point-in-Time Recovery (PITR) provides continuous backup with any-second recovery within a 35-day window. S3 cross-region replication to us-east-1 replicates all new and updated objects with sub-minute replication lag under normal conditions. The effective RPO for both data stores is less than 1 hour under any single-service failure scenario.
- **RTO (4 hours):** The Lambda functions and Step Functions workflows are defined entirely in Terraform and GitHub Actions. In the event of a catastrophic failure requiring full platform redeployment, the Terraform `apply` from the `production` environment state file redeploys all infrastructure in under 2 hours. DynamoDB restoration from PITR adds approximately 1 hour. Total estimated RTO for full reconstruction is 3–4 hours.
- **Backup:** DynamoDB PITR is enabled on both the Solution State table and the Usage Tracking table. S3 versioning is enabled on all artifact buckets. CloudTrail log delivery to the dedicated immutable bucket (S3 Object Lock) ensures audit data integrity.
- **DR Site:** S3 cross-region replication targets the `amatra-artifacts-dr-use1` bucket in us-east-1. DynamoDB global tables are not enabled (us-west-2 only, per data residency requirement); in a DR scenario, the DynamoDB tables are restored from PITR backup rather than promoted from a replica.
- **DR Runbooks:** Full DR restoration runbooks (Lambda redeployment, DynamoDB PITR restoration, S3 failover) are documented in the Operational Runbooks deliverable and validated during Phase 4 DR testing.

## Monitoring & Alerting

Amazon CloudWatch is the primary monitoring platform, supplemented by Datadog Pro for advanced APM tracing. The following seven key platform health indicators are tracked on the CloudWatch production dashboard in real time.

- **Infrastructure:** Lambda invocation count, P99 duration, error rate, and concurrent executions; SQS queue depth and DLQ message count; Step Functions execution success/failure rate and execution duration; DynamoDB consumed read/write capacity units and throttle events
- **Application:** API Gateway request rate, P95 latency, 4xx error rate, and 5xx error rate; Bedrock token consumption (input + output) vs. monthly quota; job completion rate and job duration distribution
- **Business:** Daily brief submission count vs. target throughput; artifact QA first-pass rate (sampled from Output Validation Lambda logs); monthly generation count per user vs. configured usage limits

### Alert Definitions

The following alerts are configured in CloudWatch with SNS notifications routing to the Amatra operations team email and PagerDuty (Severity 1 only). All thresholds are validated and tuned during the 8-week hypercare period.

<!-- TABLE_CONFIG: widths=[25, 25, 15, 35] -->
| Alert Name | Condition | Severity | Response |
|------------|-----------|----------|----------|
| Platform-Availability-Critical | API Gateway 5xx rate > 1% over 5 minutes | Severity 1 | Immediate investigation; check Lambda errors, Step Functions failures; rollback candidate |
| DLQ-Message-Received | SQS DLQ `ApproximateNumberOfMessagesVisible` > 0 | Severity 2 | Investigate failed job; check Bedrock throttling or Lambda errors; manual DLQ re-drive |
| Step-Functions-Failure-Rate | Step Functions execution failure rate > 5% over 10 minutes | Severity 2 | Check Bedrock quota; inspect failed execution event history |
| Bedrock-Quota-Warning | Bedrock token consumption > 80% of monthly quota | Severity 2 | Alert to CTO; consider requesting quota increase; notify admins to manage submission rate |
| Lambda-Error-Rate | Any Lambda function error rate > 5% over 5 minutes | Severity 2 | Check Lambda logs in CloudWatch; investigate recent deployment; consider rollback |
| API-Latency-P95-Breach | API Gateway P95 latency > 5 seconds over 5 minutes | Severity 3 | Check Lambda cold starts; review concurrency; check DynamoDB throttling |
| CloudTrail-Root-Login | CloudTrail event: root account console login | Severity 1 | Immediate security alert to Security & Compliance Lead; investigate unauthorised access |
| IAM-Policy-Change | CloudTrail event: `PutRolePolicy`, `AttachRolePolicy`, `CreatePolicy` outside CI/CD pipeline | Severity 1 | Immediate security investigation; possible unauthorised privilege escalation |
| Cognito-Admin-Login-Failure | ≥ 5 failed admin Cognito login attempts within 10 minutes | Severity 2 | Investigate possible brute-force attack; consider temporary account lock |
| S3-Public-Access-Enabled | AWS Config rule violation: S3 Block Public Access disabled | Severity 1 | Immediate remediation via Terraform; notify Security & Compliance Lead |

## Logging & Observability

A unified observability strategy ensures that every request, every generation job, and every error can be traced end-to-end across the Lambda chain, Step Functions workflow, and Bedrock invocations.

- **Log Aggregation:** All Lambda functions write structured JSON logs to CloudWatch Logs using the AWS Lambda Powertools library (`Logger`). Step Functions execution history is available in the AWS console and via API. API Gateway access logs are enabled with a structured format including request ID, caller IP, JWT claims, HTTP method, path, response code, and latency. All log groups are retained for 1 year.
- **Distributed Tracing:** AWS X-Ray is enabled on all Lambda functions and API Gateway. X-Ray traces propagate across the API Gateway → Lambda → SQS → Step Functions → Lambda → Bedrock call chain, allowing end-to-end latency analysis for job submissions. Datadog Pro supplements X-Ray with richer APM dashboards and anomaly detection for the 5 monitored Lambda/API Gateway hosts.
- **Dashboards:** A CloudWatch dashboard named `amatra-platform-production` is provisioned via Terraform and displays all seven KPIs defined above. A secondary security dashboard named `amatra-security-production` displays CloudTrail security events, Cognito authentication metrics, WAF blocked requests, and AWS Config compliance status.

## Cost Model

The following cost model is derived directly from the infrastructure-costs.csv file, reflecting Large tier operations at 90M Bedrock tokens/month, 50M Lambda requests/month, 200 GB DynamoDB, and 2 TB S3. AWS Business Support (~10% of monthly infrastructure) and Datadog Pro are included.

<!-- TABLE_CONFIG: widths=[30, 25, 25, 20] -->
| Category | Annual Cost | Optimisation Opportunity | Potential Savings |
|----------|-------------|--------------------------|-------------------|
| Amazon Bedrock (Claude 3 Sonnet) | $54,000 | Prompt optimisation to reduce token count per generation; upgrade to Claude 3 Haiku for lower-complexity artifact types | 10–20% |
| AWS Business Support | $6,120 | N/A (required for SLA and TAM access) | None |
| Amazon API Gateway | $2,100 | HTTP API (vs REST API) if WAF is moved to CloudFront; reduces per-request cost | 15% |
| Amazon CloudWatch | $1,800 | Log retention tuning; metric filter optimisation | 5% |
| Amazon S3 (storage + egress) | $1,092 | S3 Intelligent-Tiering for artifacts > 90 days reduces storage cost | 15% |
| Amazon DynamoDB | $600 | PITR retention tuning after Year 1; Reserved Capacity in Year 2 | 10–20% |
| AWS Step Functions | $600 | Express workflows for sub-1-hour jobs (lower cost per state transition) | 25% |
| Datadog Pro (5 hosts) | $1,380 | Review host count after Year 1; reduce to 3 hosts if APM coverage is sufficient | 40% |
| All Other Services (SQS, Cognito, SES, ECR, WAF, CloudFront, CloudTrail, Secrets Manager, PrivateLink) | ~$1,456 | Consolidate PrivateLink endpoints where possible | 5% |
| **Total Annual Infrastructure + Licenses** | **$68,148** | Post-hypercare optimisation roadmap targets 10–15% reduction in Year 2 | **~$7,000–$10,000** |

---

# Implementation Approach

The implementation approach is structured as a five-phase programme spanning nine months from project kickoff to General Availability, with a hard Phase 1 Pre-Sales MVP deadline of 30 September 2026. The approach is phased to deliver business value incrementally, validate AI generation quality early (before full rollout), and de-risk the Okta-to-Cognito migration before the delivery consultant population onboards in Phase 2.

## Migration/Deployment Strategy

- **Approach:** Phased greenfield build with incremental feature activation. Phase 1 (Pre-Sales MVP) delivers the core Bedrock generation pipeline and Cognito identity migration for the pre-sales consultant user population. Phase 2 (Delivery & Terraform Automation) extends the platform with delivery artifact types and Terraform automation. Phase 3 (General Availability) completes the rollout to all ~120 users with admin governance fully activated.
- **Pattern:** Blue-Green deployment via Lambda aliases. Each Lambda function has a `production` alias pointing to a specific version. New versions are deployed by the GitHub Actions pipeline, and traffic is switched by updating the alias pointer. The previous Lambda version is retained for 30 days post-cutover to enable instant rollback.
- **Validation:** Every deployment to Production is preceded by full-stack validation in the Staging environment, including a smoke test of all in-scope artifact types and a Cognito authentication test. CloudWatch synthetic monitoring confirms platform availability within 5 minutes of deployment.
- **Rollback:** Lambda alias rollback executes in under 5 minutes. Terraform state is maintained in the S3 backend, allowing infrastructure rollback via `terraform apply` with the previous state. The rollback activation threshold is ≥5% of user job submissions failing, or any Severity 1 data integrity issue.

## Sequencing & Wave Planning

The following table documents the five implementation phases with activities, durations, and exit criteria. All durations are measured from project kickoff.

<!-- TABLE_CONFIG: widths=[10, 30, 15, 45] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 — Discovery & Assessment | Stakeholder interviews; current state documentation; Bedrock feasibility assessment; Okta identity inventory; SOC 2 gap analysis; AWS service limit review | Weeks 1–4 | Discovery & Assessment Report approved by CTO; Phase 2 go/no-go signed off |
| 2 — Architecture Design | End-to-end architecture design; DynamoDB schema design; Cognito User Pool design; Bedrock prompt template framework; Terraform module structure; CI/CD design; CloudWatch observability design | Weeks 5–8 | Detailed Architecture Design Document and ADRs approved by CTO and Security Lead |
| 3 — Development & Build | AWS foundation provisioning (Dev); Cognito User Pool + Okta migration (Dev); API Gateway + Lambda (Dev); Step Functions + SQS pipeline; Bedrock integration + prompt templates (7+ artifact types); template automation pipeline; admin console; CI/CD pipeline; CloudWatch observability stack | Weeks 9–20 | All platform components deployed and integrated in Dev environment; configuration documentation delivered |
| 4 — Testing & Validation | Functional testing; integration testing; async performance load testing; security and compliance testing (OWASP, WAF, encryption, CloudTrail); DR testing; artifact quality validation; UAT with 5–10 pre-sales consultants; SOC 2 evidence assembly | Weeks 21–26 | All test phases passed; SOC 2 evidence package assembled; CTO and Security Lead go-live sign-off received |
| 5 — Deployment, Hypercare & Close | Staging validation; Production Phase 1 deployment (Pre-Sales MVP, 30 Sep 2026); Okta-to-Cognito cutover; legacy EC2 decommission; Production Phase 2 deployment (Delivery & Terraform, 15 Dec 2026); training sessions; hypercare support (8 weeks); optimisation roadmap; project closeout | Weeks 27–36 | All production deployments live; all ~120 users onboarded; hypercare complete; final deliverables accepted by CTO |

## Tooling & Automation

The following tooling is used across the engagement. All tool selections were approved in the Statement of Work.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Tool | Purpose |
|----------|------|---------|
| Infrastructure as Code | Terraform v1.8+ | 100% IaC coverage for all AWS resources across Dev, Staging, and Production; S3 + DynamoDB state backend; modular structure with environment-specific parameter overrides |
| CI/CD Pipeline | GitHub Actions | Automated Lambda build and deployment; Terraform plan/apply gates on PR and merge; branch protection (1 peer review required); automated test execution |
| Container Registry | Amazon ECR | Stores Lambda container images; integrated with GitHub Actions deployment workflow; image vulnerability scanning enabled |
| Bedrock Integration | Amazon Bedrock SDK (Python Boto3) | `InvokeModel` API calls from Bedrock Orchestration Lambda; supports streaming responses for large artifact outputs |
| Identity Migration | Custom Python migration script (Okta SCIM API → Cognito AdminCreateUser) | One-time script to migrate ~120 Okta users and group assignments to Cognito User Pool; includes validation report |
| Testing | pytest + AWS SDK mocks (moto) | Unit and integration testing for Lambda functions; Step Functions local testing with `stepfunctions-local`; API testing with Postman collections |
| Security Testing | OWASP ZAP + AWS WAF test scripts | Automated OWASP API Security Top 10 testing against Staging API Gateway endpoint; WAF rule effectiveness validation |
| Observability | Amazon CloudWatch + AWS X-Ray + Datadog Pro | CloudWatch for operational monitoring and alarms; X-Ray for distributed tracing; Datadog for APM dashboards and anomaly detection |
| Project Management | Jira / Confluence | Sprint planning, task tracking, defect management, and documentation |
| Documentation | Markdown (this repository) | All deliverable documentation authored in Markdown; converted to DOCX/PPTX by the EO Framework document pipeline |

## Cutover Approach

The platform uses a phased cutover model aligned to the two production deployment milestones defined in the SOW.

- **Phase 1 Cutover (Target: 30 September 2026):** Activates the Pre-Sales MVP for the pre-sales consultant user population. Executed during a planned maintenance window communicated 5 business days in advance. Steps: (1) Okta-to-Cognito SSO DNS cutover executed; (2) pre-sales consultant login validation (≥95% success rate required); (3) brief submission end-to-end test in Production by Head of Solutions; (4) admin usage limits activated; (5) CloudWatch alarms confirmed active; (6) go-live communications sent; (7) vendor team on-call for 48 hours post-cutover.
- **Phase 2 Cutover (Target: 15 December 2026):** Activates delivery artifact automation and Terraform generation modules. Steps: (1) delivery team enablement sessions completed; (2) Phase 2 artifact types validated end-to-end in Staging; (3) Production deployment via GitHub Actions pipeline; (4) smoke test of all Phase 2 artifact types in Production; (5) legacy EC2 monolith decommission (data archive, DNS update); (6) go-live communications to delivery team.
- **Type:** Phased (pre-sales first, delivery second)
- **Duration:** 48-hour parallel run monitoring period after each cutover milestone
- **Decision Point:** Go/no-go criteria: all Severity 1 and Severity 2 defects resolved; security sign-off received; Cognito login success rate ≥95%; CloudWatch alarms active; rollback procedure validated in Staging

## Downtime Expectations

- **Planned Downtime:** Zero for Lambda and API Gateway (blue-green deployment with instant alias switching). The Okta-to-Cognito DNS cutover may cause a brief (< 5 minute) authentication disruption during DNS propagation; this is communicated to users in advance and is executed during a low-traffic window.
- **Unplanned Downtime:** MTTR target is 4 hours for Severity 1 incidents (platform down). The 99.9% availability SLA allows for approximately 8.7 hours of downtime per year.
- **Mitigation:** Blue-green Lambda deployments eliminate downtime for application code changes. Infrastructure changes (VPC, IAM, DynamoDB schema) are planned during low-traffic periods and validated in Staging before applying to Production.

## Rollback Strategy

A complete rollback capability is maintained for 30 days post-Phase 1 cutover and 30 days post-Phase 2 cutover.

- **Infrastructure Rollback:** Terraform state is maintained in the S3 backend. Rolling back infrastructure means applying the previous Terraform state, which the GitHub Actions pipeline can execute in under 20 minutes.
- **Application Rollback:** Lambda aliases point to specific function versions. Rollback is executed by updating the Lambda alias to point to the previous version — a single AWS CLI command that completes in under 1 minute and requires no redeployment.
- **Identity Rollback:** Cognito is configured with an Okta OIDC federation provider as a fallback during the 30-day post-cutover window. If Cognito authentication issues are detected, the Okta federation is re-enabled, routing all authentication to the legacy Okta provider while the Cognito issues are investigated.
- **Data Rollback:** DynamoDB PITR allows point-in-time restoration of the Solution State and Usage Tracking tables to any second within the previous 35 days. S3 versioning allows rollback of any individual artifact to a previous version.
- **Maximum Rollback Window:** 30 days post-cutover for both Phase 1 and Phase 2 deployments. After 30 days of stable operation, the previous Lambda versions and Okta federation fallback are decommissioned.

---

# Appendices

This section provides supplementary reference material including architecture diagram references, naming conventions, tagging standards, risk register, and glossary. These artefacts are used throughout development and operations and are maintained as living documents in the project's Confluence space.

## Architecture Diagrams

The following diagrams document the platform architecture at different levels of detail. All diagrams are maintained in the `assets/diagrams/` directory of the project repository and are regenerated from source (`.drawio` and `.gv` files) as part of the documentation pipeline.

- **Solution Architecture Diagram** — included in the Solution Architecture section above (Figure 1); illustrates all five logical layers and the asynchronous Bedrock generation pipeline
- **Network Topology Diagram** — documents the VPC CIDR structure, public/private subnet layout, NAT Gateway placement, PrivateLink endpoint configuration, and security group boundaries
- **Data Flow Diagram** — documents the end-to-end data flow from brief submission through Bedrock invocation to artifact delivery, annotated with data classification labels and encryption boundaries
- **Security Architecture Diagram** — documents all security controls layered across the platform: WAF, Cognito, IAM, KMS, CloudTrail, Config, and PrivateLink isolation

## Naming Conventions

All AWS resources are named according to the following convention: `amatra-{component}-{environment}` (e.g., `amatra-solution-state-prod`, `amatra-generation-queue-staging.fifo`). The following table documents the pattern for each major resource type.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Resource Type | Pattern | Example |
|---------------|---------|---------|
| S3 Bucket | `amatra-{purpose}-{env}` | `amatra-artifacts-prod`, `amatra-terraform-state-prod` |
| DynamoDB Table | `amatra-{domain}-{env}` | `amatra-solution-state-prod`, `amatra-usage-tracking-prod` |
| Lambda Function | `amatra-{function-name}-{env}` | `amatra-brief-submission-prod`, `amatra-bedrock-orchestration-prod` |
| API Gateway | `amatra-platform-api-{env}` | `amatra-platform-api-prod` |
| Step Functions | `amatra-generation-workflow-{env}` | `amatra-generation-workflow-prod` |
| SQS Queue | `amatra-{purpose}-{env}[.fifo]` | `amatra-generation-queue-prod.fifo`, `amatra-generation-dlq-prod` |
| Cognito User Pool | `amatra-users-{env}` | `amatra-users-prod` |
| KMS Key (alias) | `alias/amatra-{purpose}-{env}` | `alias/amatra-artifacts-prod`, `alias/amatra-database-prod` |
| IAM Role | `amatra-{function-name}-{env}-role` | `amatra-brief-submission-prod-role` |
| CloudWatch Log Group | `/aws/lambda/amatra-{function-name}-{env}` | `/aws/lambda/amatra-bedrock-orchestration-prod` |
| CloudWatch Dashboard | `amatra-platform-{env}` | `amatra-platform-prod`, `amatra-security-prod` |
| VPC | `amatra-platform-vpc-{env}` | `amatra-platform-vpc-prod` |
| ECR Repository | `amatra/{function-name}` | `amatra/bedrock-orchestration`, `amatra/brief-submission` |

## Tagging Standards

All AWS resources must be tagged with the following mandatory tags. Tags are enforced via AWS Config rules and applied by Terraform at resource creation time. Resources without mandatory tags trigger a Config non-compliance finding.

<!-- TABLE_CONFIG: widths=[25, 10, 35, 30] -->
| Tag Key | Required | Description | Example Values |
|---------|----------|-------------|----------------|
| `Environment` | Yes | Deployment environment | `dev`, `staging`, `prod` |
| `Application` | Yes | Platform name | `amatra-intelligent-solution-builder` |
| `Component` | Yes | Functional component within the platform | `api`, `orchestration`, `storage`, `identity`, `observability` |
| `Owner` | Yes | Team responsible for the resource | `vendor-team`, `amatra-engineering` |
| `CostCenter` | Yes | Billing cost center code | `AISB-2025-PROD`, `AISB-2025-DEV` |
| `DataClassification` | Yes (data resources only) | Data classification tier | `Confidential`, `Internal`, `Public` |
| `ManagedBy` | Yes | Provisioning method | `terraform` |
| `TerraformModule` | Recommended | Terraform module that manages the resource | `modules/storage`, `modules/api` |

## Risk Register

The following risks have been identified through discovery and architecture review. Each risk is assigned a likelihood and impact rating, and a mitigation approach is defined. The risk register is maintained in Jira and reviewed at each phase gate.

<!-- TABLE_CONFIG: widths=[30, 12, 12, 46] -->
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Amazon Bedrock throughput quota insufficient for 24 engagements/quarter at peak concurrency | Medium | High | Request Bedrock quota increase to 200M tokens/month before Phase 3 build; design Step Functions with built-in throttling and retry logic; monitor Bedrock token consumption vs quota with 80% alarm |
| Okta-to-Cognito migration encounters user login failures at cutover (>5% failure rate) | Medium | High | Maintain Okta OIDC federation as fallback in Cognito for 30 days post-cutover; validate ≥95% login success in Staging with anonymised user cohort before Phase 1 cutover; communicate password-reset requirement to all users in advance |
| Bedrock-generated artifacts fail to achieve ≥90% first-review QA pass rate | Medium | Critical | Invest heavily in prompt engineering during Phase 3 with iterative QA feedback from Head of Solutions; validate against representative client briefs in Phase 4 functional testing; budget for prompt tuning during hypercare |
| AWS Lambda cold starts degrade API response time under low-traffic conditions | Low | Medium | Configure Lambda Provisioned Concurrency for the Brief Submission and Job Status functions (2 provisioned instances each); monitor P95 API Gateway latency; tune during hypercare |
| Step Functions job exceeds 90-minute window due to Bedrock latency spikes | Low | Medium | Step Functions standard workflows support up to 1-year execution; Bedrock orchestration Lambda timeout is set to 900 seconds (15 min) per artifact with retry; monitor Step Functions execution duration; alert on P95 > 90 minutes |
| Security Group or IAM misconfiguration exposes Lambda to unintended access paths | Low | Critical | AWS Config continuously evaluates all security group and IAM policies against SOC 2 baseline; Terraform plan includes policy simulation step in CI/CD pipeline; IAM Access Analyzer runs continuously in all environments |
| Legacy EC2 monolith data loss during decommission | Low | High | Comprehensive data export runbook executed before decommission; all data archived to S3 Glacier before EC2 termination; decommission is executed only after Phase 1 GA is confirmed stable for 30 days |
| Key AWS service outage (Bedrock or Step Functions) in us-west-2 | Very Low | Critical | SQS message retention (4 days) holds jobs during service outage; Step Functions restart capability picks up in-flight jobs on service recovery; CloudWatch alarms trigger immediate notification; DR runbook covers Lambda redeployment from IaC if required |
| SOC 2 evidence gaps identified during Phase 4 compliance testing | Medium | High | SOC 2 control design is validated in Phase 2 Architecture Design (Security Lead sign-off required before Phase 3 build); AWS Config rules enforce continuous compliance from Phase 3 onwards; Security Engineer is full-time on SOC 2 controls throughout Phases 3–4 |
| GitHub Actions pipeline failures delay Development milestones | Low | Medium | Branch protection requires pipeline success before merge; pipeline failures are visible to all team members immediately; Terraform state locking prevents concurrent conflicting applies; pipeline run history is retained for 90 days for debugging |

## Glossary

The following table defines key terms and acronyms used throughout this document. Terms are consistent with AWS documentation and the SOW.

<!-- TABLE_CONFIG: widths=[25, 75] -->
| Term | Definition |
|------|------------|
| ADR | Architecture Decision Record — a document that captures an important architectural decision made during the engagement, including the context, decision, and consequences |
| Bedrock | Amazon Bedrock — AWS's fully managed service for foundation model inference; this platform uses the Claude 3 Sonnet model via the `InvokeModel` API |
| Claude 3 Sonnet | Anthropic's Claude 3 Sonnet model, accessed via Amazon Bedrock; selected as the primary model for artifact generation based on output quality, context window size, and cost-per-token |
| CMK | Customer-Managed Key — a KMS encryption key whose key material is managed by the customer (Amatra), providing full control over key rotation and key policy |
| CQRS | Command Query Responsibility Segregation — an architectural pattern that separates write operations (commands) from read operations (queries) at the data access layer |
| DLQ | Dead-Letter Queue — an Amazon SQS queue that captures messages that have failed processing after the maximum number of retries, for investigation and manual re-drive |
| FIFO | First-In-First-Out — an Amazon SQS queue type that guarantees message ordering and exactly-once processing via message deduplication IDs |
| GSI | Global Secondary Index — a DynamoDB index with a different partition key than the table, enabling efficient queries on non-primary-key attributes (e.g., `user_id` on the solution-state table) |
| IaC | Infrastructure as Code — the practice of provisioning and managing infrastructure through machine-readable configuration files (Terraform) rather than manual processes |
| IdP | Identity Provider — the system that authenticates users and issues identity tokens; Okta is the current IdP; Amazon Cognito is the target IdP |
| JWT | JSON Web Token — a compact, URL-safe means of representing claims between parties; Cognito issues JWTs as access tokens and ID tokens for API authorisation |
| LOE | Level of Effort — an estimate of the professional services hours required for the engagement |
| MFA | Multi-Factor Authentication — requiring a second form of verification (TOTP or SMS) in addition to a password; mandatory for admin group users in Cognito |
| MTTR | Mean Time to Repair — the average time required to restore a service after a failure; Severity 1 MTTR target is 4 hours |
| PITR | Point-in-Time Recovery — DynamoDB's continuous backup feature that allows restoration of a table to any second within the previous 35 days |
| PKCE | Proof Key for Code Exchange — an OAuth 2.0 security extension that prevents authorization code interception attacks; required for all Cognito OAuth 2.0 flows |
| PrivateLink | AWS PrivateLink — a technology that provides private connectivity between VPCs and AWS services without traversing the public internet, using VPC interface endpoints |
| RPO | Recovery Point Objective — the maximum acceptable amount of data loss measured in time; this platform's RPO is 1 hour |
| RTO | Recovery Time Objective — the maximum acceptable time to restore service after a failure; this platform's RTO is 4 hours |
| SCIM | System for Cross-domain Identity Management — an open standard for automating user provisioning between identity providers; used in the Okta-to-Cognito migration script |
| SOC 2 | Service Organization Control 2 — a framework developed by the AICPA for evaluating an organization's controls relevant to the five Trust Service Criteria: Security, Availability, Processing Integrity, Confidentiality, and Privacy |
| SOW | Statement of Work — the primary contract document governing this engagement, defining scope, deliverables, timeline, investment, and terms |
| SSE-KMS | Server-Side Encryption with AWS KMS — an S3 encryption mode where objects are encrypted at rest using AWS KMS keys managed by the customer |
| Step Functions | AWS Step Functions — a serverless orchestration service that uses state machines to coordinate distributed applications and multi-step workflows; standard workflows support execution durations up to 1 year |
| WAF | Web Application Firewall — AWS WAF v2, which protects API Gateway and CloudFront endpoints from OWASP Top 10 attacks, DDoS, and rate-limit abuse |
| X-Ray | AWS X-Ray — a distributed tracing service that provides end-to-end visibility into request execution across Lambda functions, API Gateway, and Step Functions workflows |
