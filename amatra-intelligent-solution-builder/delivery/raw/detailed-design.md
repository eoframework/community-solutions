---
document_title: Detailed Design Document
solution_name: Amatra Agentic Pre-Sales Platform on AWS
document_version: "1.0"
author: Amatra Engagement Lead / Senior Solution Architect
last_updated: 2026-06-05
technology_provider: aws
client_name: PREDICTif Solutions
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Detailed Design Document (DDD) provides the complete technical blueprint for the Amatra Agentic Pre-Sales Platform on AWS — a fully serverless, multi-agent orchestration system that automates EO Framework solution-package generation for PREDICTif Solutions. The platform eliminates six to ten hours of senior-consultant manual effort per engagement, replacing the current fragmented local-laptop workflow with a centralised, identity-governed, audit-trailed cloud pipeline capable of producing all twelve EO Framework artifacts (five presales, six delivery, one Terraform IaC bundle) in under sixty minutes at P95 latency.

The architecture is anchored on Amazon Bedrock AgentCore Runtime hosting five specialised Strands Agents (Input Validator, Pre-Sales Generator, Delivery Generator, Code Generator, and EO Validator), coordinated by an AWS Step Functions state machine. Authentication and quota enforcement are first-class concerns: Amazon Cognito User Pools provide JWT-based identity; atomic DynamoDB conditional writes enforce per-user (10 solutions/month) and global (1,000 solutions/month) generation quotas with zero race-condition risk. All output artifacts are stored in Amazon S3 and automatically committed to a public GitHub repository, with the pip-installable fourteen-subcommand CLI exposing every platform capability to PREDICTif's 120 distributed consultants in the US and Canada.

This document expands the Architecture & Design section of the Statement of Work (SOW, Opportunity OPP-2026-001) into implementation-ready specifications covering component design, network topology, security controls, data architecture, API surface, infrastructure sizing, and phased delivery sequencing. Every design decision traces directly to a presales commitment; no services, regions, or capabilities have been added beyond the agreed SOW scope.

## Purpose

This document defines the technical implementation specification for the Amatra Agentic Pre-Sales Platform on AWS. It is intended for use by the Amatra delivery engineering team, PREDICTif's technical stakeholders (CTO, Marcus Patel, Daniel Park, Client IT Lead), and the DevOps and QA teams responsible for deployment, testing, and go-live acceptance. The document is the authoritative reference for all architectural decisions, component configurations, integration contracts, and operational procedures during the twelve-week engagement.

## Scope

**In-scope:**

- All AWS infrastructure in us-west-2: VPC, IAM, Amazon Cognito, API Gateway HTTP API v2, AWS Lambda (eleven routes plus triggers), Amazon DynamoDB (three tables), Amazon S3, Amazon ECR, Amazon Bedrock AgentCore Runtime (five agents), AWS Step Functions, AWS Secrets Manager, Amazon CloudWatch, AWS CodePipeline, AWS CodeBuild, AWS GuardDuty, AWS CloudTrail
- Five Bedrock AgentCore agents implemented using the Strands Agents framework with eof-tools (~30 Python modules) baked into the container image
- Pip-installable CLI with fourteen subcommands wrapping the JWT-protected HTTP API
- Eleven JWT-protected Lambda API routes behind API Gateway HTTP API v2
- Amazon Cognito User Pool with post-confirmation Lambda trigger, thirty-day refresh tokens, and atomic DynamoDB quota initialisation
- Per-user (10 solutions/month) and global (1,000 solutions/month) quota enforcement via DynamoDB conditional writes
- Terraform IaC bundle for the complete platform with `terraform validate` CI gate
- Per-artifact format-check and LLM quality-check validation with up to three automated retries
- Token usage instrumentation surfaced in CLI `status` command and `GET /admin/usage` API endpoint
- Automated GitHub artifact commits via Secrets Manager-stored personal access token
- CloudWatch dashboards, alarms, and green metrics baseline
- Full as-built documentation, operational runbooks, and knowledge-transfer deliverables
- Eight-week post-go-live hypercare support (Weeks 13–20)

**Out-of-scope:**

- Migration of legacy us-east-1 AWS workloads or managed-services accounts
- Graphical user interface (GUI) or web portal — CLI and API only
- Integration with CRM, PSA, or sales-force automation systems
- Custom model training or fine-tuning of Claude Sonnet 4.6 / Haiku 4.5
- Multi-region deployment or active-active high availability (us-west-2 only)
- Managed services ongoing operations beyond the hypercare period
- Refactoring or re-engineering of the eof-tools converter library
- Additional CLI subcommands beyond the specified fourteen
- SOC 2 Type II formal certification or third-party penetration testing

## Assumptions & Constraints

- PREDICTif provides AWS account access in a fresh us-west-2 account within five business days of contract execution
- Bedrock AgentCore Runtime is generally available in us-west-2 by Phase 2 kickoff (Week 5)
- Claude Sonnet 4.6 and Haiku 4.5 model versions are available in us-west-2 with sufficient Bedrock quota for 200 solutions/month
- CTO sign-off on Cognito User Pool design is obtained by end of Week 3 — this is a hard gate for Phase 1 completion
- The eof-tools converter library is stable in a containerised Linux environment with no refactoring required
- The public GitHub repository is pre-provisioned and write access granted via PAT by Week 7
- English is the sole language for all generated artifacts; no internationalisation is required
- No HIPAA, PCI-DSS, or FedRAMP requirements apply; SOC 2 Type II baseline controls are sufficient
- The fixed April 2026 executive sponsor demonstration deadline is non-negotiable

## References

- Statement of Work (SOW) — Amatra Agentic Pre-Sales Platform on AWS, OPP-2026-001, Version 1.0
- Solution Briefing — Amatra Agentic Pre-Sales Platform on AWS, Marcus Patel, 2026-06-05
- Infrastructure Costs CSV — 3-Year Summary, OPP-2026-001
- Level of Effort Estimate CSV — OPP-2026-001
- EO Framework Guidance Documentation — Amatra EO Framework Division
- AWS Well-Architected Framework — Five Pillars (Operational Excellence, Security, Reliability, Performance Efficiency, Cost Optimisation)
- Amazon Bedrock AgentCore Runtime — Service Documentation
- Strands Agents Framework — Apache 2.0 Open-Source Documentation

---

# Business Context

PREDICTif Solutions is a 120-consultant distributed AWS consulting practice operating across the United States and Canada, generating customer-facing pre-sales and delivery documentation through its Amatra product. The current workflow is entirely manual: individual consultants feed EO Framework guidance files into Claude Code CLI on local laptops, iterate three to four times on validation failures, run Python converter scripts, and manually push results to GitHub. This process has no centralised orchestration, no per-user identity, no automated retry, and no audit trail — consuming six to ten hours of senior-consultant time per engagement.

The Amatra Agentic Pre-Sales Platform is a direct response to this operational bottleneck. By replacing the fragmented local-laptop workflow with a serverless, agentic, API-driven platform, PREDICTif will unlock 90% consultant effort reduction per engagement, parallel multi-solution throughput at 200 solutions/month steady state, and a complete CloudTrail audit trail with per-user quota governance. The platform is designed to scale linearly to 1,000+ solutions/month with no architectural changes, providing the foundation for Phase 2 growth as PREDICTif's pipeline expands.

## Business Drivers

- **90% Effort Reduction:** Shift senior-consultant time from artifact production (6–10 hours) to artifact review and client customisation (under 1 hour), enabling the pre-sales team to pursue more concurrent opportunities without headcount growth
- **Parallel Pipeline Throughput:** Enable simultaneous multi-solution generation at 200+ solutions/month, removing the hard capacity ceiling imposed by the single-machine manual workflow
- **Centralised Identity and Quota Governance:** Eliminate the risk of runaway LLM spend and output inconsistency by enforcing per-user (10/month) and global (1,000/month) quotas atomically via DynamoDB conditional writes backed by Amazon Cognito User Pools
- **Predictable Cost at Scale:** Target per-solution Bedrock spend under $5 (Claude Sonnet 4.6 + Haiku 4.5 combined) and amortised infrastructure under $0.50/solution at 200 solutions/month steady state
- **Audit and Compliance Foundation:** Provide a complete CloudTrail audit trail, structured CloudWatch logging, and SOC 2 Type II baseline controls to support future compliance certification
- **Fixed April 2026 Deadline:** Deliver a demonstrable, executive-ready platform in twelve weeks to meet the hard deadline for Sarah Lin's (CRO) executive sponsor presentation

## Workload Criticality & SLA Expectations

The platform is classified as business-critical during pre-sales engagements. The following SLA targets govern the design and are drawn directly from the SOW success criteria.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Metric | Target | Measurement | Priority |
|--------|--------|-------------|----------|
| End-to-End Solution Generation (P95) | < 60 minutes | CloudWatch custom metric per solution run | Critical |
| End-to-End Solution Generation (P50) | < 30 minutes | CloudWatch custom metric per solution run | High |
| End-to-End Solution Generation (P99) | < 90 minutes | CloudWatch custom metric per solution run | Medium |
| Platform Availability | ≥ 99.5% | CloudWatch alarm on Lambda error rate | High |
| Per-Solution Bedrock Token Spend | ≤ $5 | CloudWatch custom metric AmatraPlatform/TokenCost | Critical |
| Monthly Solution Throughput | 200 solutions/month steady state | CloudWatch dashboard aggregate counter | High |
| RTO (Platform Restoration) | ≤ 4 hours | DR test validated in Phase 3 | Critical |
| RPO (DynamoDB Data) | ≤ 24 hours | PITR backup verified in staging | High |
| RPO (S3 Artifacts) | 0 (versioned, multi-AZ) | S3 versioning policy | Critical |
| Validation Retry Success Rate | ≥ 95% resolved within 3 retries | CloudWatch metric on EO Validator retry counts | High |

## Compliance & Regulatory Factors

- **SOC 2 Type II Baseline:** The platform implements controls aligned to the Trust Services Criteria (TSC) for Availability (A1), Confidentiality (C1), and Processing Integrity (PI1). Formal certification is out of scope but control evidence is collected for a future audit
- **No PII in Generation Pipeline:** Client briefs contain engagement metadata only — no personally identifiable information or regulated data enters the Bedrock generation pipeline
- **Data Classification:** All artifacts are classified as PREDICTif Confidential during generation and in S3; once committed to the public GitHub repository they are treated as public
- **Audit Trail Requirements:** CloudTrail data events enabled for S3 and DynamoDB with 365-day WORM retention in a dedicated audit S3 bucket
- **Quota Governance:** Atomic DynamoDB conditional writes enforce hard caps at both user and global levels with full audit timestamp logging for any administrative quota override

## Success Criteria

- All twelve artifact types (5 presales, 6 delivery, 1 Terraform IaC bundle) passing format-check and LLM quality validation end-to-end without manual intervention
- P95 end-to-end latency confirmed below sixty minutes under 200 solutions/month load test
- Per-solution Bedrock token spend confirmed at or below $5 for the Claude Sonnet 4.6 + Haiku 4.5 mix
- Zero quota overruns: per-user limit (10 solutions/month) and global pool (1,000 solutions/month) enforced atomically with no race conditions under concurrent load
- Green CloudWatch metrics dashboard certified by DevOps Engineer with P99 Lambda latency, error rates, and validation retry rates within agreed thresholds
- UAT sign-off from Marcus Patel, Daniel Park, and CTO with zero open P1/P2 defects
- Successful executive sponsor demonstration delivered to Sarah Lin (CRO) by end of April 2026

---

# Current-State Assessment

PREDICTif's Amatra team currently produces EO Framework solution packages entirely through a manual, unorchestrated workflow. Each senior consultant operates independently on a local laptop, manually invoking Claude Code CLI against EO Framework guidance files, iterating on validation failures, executing Python converter scripts, and manually pushing artifacts to GitHub via OneDrive. This section documents the current environment, its limitations, and the gap analysis that drives the target-state architecture.

## Application Landscape

The current Amatra workflow is not a discrete application but a loosely coupled set of manual steps executed by individual consultants. The following table captures the key workflow components and their disposition under the new platform.

<!-- TABLE_CONFIG: widths=[25, 30, 25, 20] -->
| Application | Purpose | Technology | Status |
|-------------|---------|------------|--------|
| Claude Code CLI (local) | LLM-driven artifact generation per guidance file | Claude API, local Python scripts | Replace with AgentCore agents |
| eof-tools Converter Scripts | Convert markdown/CSV to DOCX, PPTX, XLSX | ~30 Python modules, local execution | Containerise into ECR image |
| Manual GitHub Push | Commit generated artifacts to customer repository | Git CLI, OneDrive staging area | Replace with Lambda GitHub integration |
| Local Validation Scripts | Run format-check against EO Framework schema | Python scripts, manual execution | Automate via EO Validator agent |
| No identity/quota system | N/A — no centralised access control exists | None | Replace with Cognito + DynamoDB quota enforcement |
| No API or CLI distribution | N/A — no programmatic interface exists | None | Build: 14-subcommand pip CLI + 11 Lambda routes |

## Infrastructure Inventory

The current state has no dedicated cloud infrastructure for the Amatra workflow. All generation occurs on consultant laptops with no reproducibility guarantee, no environment standardisation, and no monitoring.

<!-- TABLE_CONFIG: widths=[20, 15, 35, 30] -->
| Component | Quantity | Specifications | Notes |
|-----------|----------|----------------|-------|
| Consultant laptops | ~120 | Various OS (macOS, Windows); local Python environments | Environment drift is a documented risk; no standardisation |
| Claude Code CLI instances | ~120 | Local install per consultant; unmanaged version updates | No central version control or prompt template governance |
| OneDrive storage | Per-consultant | Unstructured artifact staging; no access control | No quota tracking, no audit trail, no automation |
| GitHub repository (existing) | 1 (public) | Manual push workflow; no branch protection | Target for automated PAT-commit integration |
| AWS account (us-east-1) | 1 | Existing managed-services workloads; not in scope | Remains unchanged; new us-west-2 account is the platform target |

## Dependencies & Integration Points

- **eof-tools library (~30 Python modules):** Existing PREDICTif asset that converts raw markdown/CSV to DOCX, PPTX, and XLSX. Must be containerised and baked into the AgentCore ECR image without refactoring
- **Public GitHub repository:** Pre-provisioned artifact destination; write access via PAT to be stored in Secrets Manager by Week 7
- **EO Framework guidance files:** Authoritative templates that govern artifact schema; referenced by all five agents and by the EO Validator format-check
- **Bedrock model availability:** Claude Sonnet 4.6 (generation) and Claude Haiku 4.5 (validation) must be available in us-west-2 with sufficient quota — Bedrock quota request must be raised with AWS in Week 1

## Network Topology

The current state has no dedicated network topology for the Amatra workflow. Consultants access Claude API and GitHub directly from their laptops over public internet connections. There is no VPC, no VPN, no access control at the network layer, and no monitoring of outbound API traffic. This creates uncontrolled LLM API spend, no rate limiting, and no security posture enforcement.

## Security Posture

The current workflow has significant security gaps that the target platform directly addresses. There is no centralised identity management — any consultant with the Claude API key can generate artifacts with no attribution or quota enforcement. Artifacts are stored in OneDrive with no encryption at rest policy, no access control audit, and no data classification enforcement. The GitHub PAT used for repository commits is shared informally with no rotation schedule. No MFA is enforced on any workflow step, and there is no audit trail for artifact generation, modification, or deletion.

## Performance Baseline

- Average per-artifact generation time: 15–45 minutes (manual, unoptimised)
- Peak consultant throughput: 2–3 pre-sales packages per consultant per week
- Daily transaction volume: Approximately 5–10 solution packages across the team on peak days
- Validation retry rate: 3–4 manual iterations per artifact on average (no automation)
- Monthly throughput ceiling: ~50–80 solution packages constrained by manual effort

## Gap Analysis

The following table maps the key current-state limitations to the gaps they create and the target-state capabilities that close them.

<!-- TABLE_CONFIG: widths=[33, 34, 33] -->
| Current State | Gap | Target State |
|---------------|-----|--------------|
| Manual Claude Code CLI per consultant | No orchestration, no parallelism, 6–10 hours/package | Five-agent AgentCore pipeline; end-to-end generation under 60 minutes |
| No centralised identity or quota control | Runaway LLM spend risk; no attribution or audit trail | Cognito User Pool + DynamoDB atomic quota enforcement; full CloudTrail audit |
| No API or CLI distribution | Sales team cannot self-serve; no status tracking | 11 JWT-protected Lambda routes + pip-installable 14-subcommand CLI |
| Local eof-tools execution (manual) | Environment drift; no reproducibility; no parallelism | eof-tools baked into ECR container image; invoked deterministically by Code Generator agent |
| Manual GitHub push via OneDrive | No automation, inconsistent commits, no branch strategy | Lambda GitHub integration via Secrets Manager PAT; automated commit on solution completion |
| No validation automation | 3–4 manual retries per artifact; blocks throughput | EO Validator agent with format-check + LLM quality-check; up to 3 automated retries |
| No monitoring or alerting | Silent failures; no cost visibility; no SLA tracking | CloudWatch dashboards, alarms, and per-solution token spend metrics |
| Single-machine fragility | Environment drift, model version changes break pipeline | Containerised agents on AgentCore Runtime; CI/CD with ECR image lifecycle |

---

# Solution Architecture

The Amatra Agentic Pre-Sales Platform is a fully serverless, event-driven, multi-agent orchestration system deployed in AWS us-west-2. The platform replaces PREDICTif's fragmented manual workflow with a centralised, identity-governed, API-driven pipeline that produces all twelve EO Framework artifacts end-to-end in under sixty minutes. The architecture is designed around five core principles: serverless operations, agent specialisation, security by default, cost predictability, and linear scalability.

At the core of the platform, five Strands Agents are registered on Amazon Bedrock AgentCore Runtime — each encapsulated in a Docker container image (stored in Amazon ECR) that includes the eof-tools converter library. AWS Step Functions orchestrates the agent execution graph, managing state transitions, graded artifact delivery, and per-artifact retry logic (up to three cycles). All platform entry points — both the CLI and the API — route through Amazon API Gateway HTTP API v2, which validates every request via a Cognito JWT authoriser before any Lambda handler executes. Output artifacts are written to Amazon S3 and automatically committed to the public GitHub repository via a Lambda-invoked GitHub integration module using a Secrets Manager-stored PAT.

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

## Architecture Principles

- **Serverless Operations:** All compute — Lambda functions, AgentCore agents, Step Functions state machines — is serverless and managed. There are no EC2 instances, no patch cycles, and no capacity planning required. The architecture scales automatically from zero to peak concurrency with no changes
- **Agent Specialisation:** Each of the five agents (Input Validator, Pre-Sales Generator, Delivery Generator, Code Generator, EO Validator) has a single, well-defined responsibility with an explicit input/output contract. Agent specialisation enables independent development, testing, and model tuning without cross-agent coupling
- **Security by Default:** Every design decision defaults to the most restrictive posture: least-privilege IAM roles per component, JWT validation on every API route, VPC endpoints for all internal service traffic, SSE-KMS encryption on all data at rest, and no plaintext credentials anywhere in the stack
- **Cost Predictability:** Per-solution Bedrock spend is bounded by model selection (Haiku 4.5 for validation at 5× cost advantage over Sonnet 4.6), retry caps (maximum three per artifact), and token usage instrumentation surfaced in real time via CloudWatch metrics and the CLI `status` command
- **Linear Scalability:** The serverless architecture scales linearly from PoC throughput to 1,000+ solutions/month with no architectural changes. DynamoDB on-demand capacity absorbs quota enforcement spikes; Lambda concurrency scales with API request volume; Bedrock quotas scale with AWS account-level increases

## Architecture Patterns

- **Primary Pattern:** Event-driven multi-agent pipeline — each agent is triggered by the Step Functions state machine, processes its designated artifact set, and emits a completion event that triggers the next state
- **Data Pattern:** CQRS-lite — artifact generation (write path) is decoupled from artifact retrieval and status (read path) via separate DynamoDB access patterns and S3 object keys
- **Integration Pattern:** API Gateway + Lambda for synchronous CLI/API requests; Step Functions for asynchronous agent orchestration; SNS Dead Letter Queue for failed agent escalation
- **Deployment Pattern:** Blue-green via Lambda aliases and AgentCore agent version pinning — the previous stable version remains available for instant rollback without redeployment
- **Validation Pattern:** Bounded retry loop — the EO Validator agent executes format-check (deterministic schema validation) followed by LLM quality-check (Claude Haiku 4.5) with a hard maximum of three retry cycles per artifact before escalating to a Dead Letter Queue

## Component Design

The platform is composed of six functional layers, each grouping AWS services and application components by their primary responsibility. The following table details the key components, their purpose, the specific technology used, their dependencies, and scaling strategy.

<!-- TABLE_CONFIG: widths=[18, 25, 22, 18, 17] -->
| Component | Purpose | Technology | Dependencies | Scaling |
|-----------|---------|------------|--------------|---------|
| API Gateway HTTP API v2 | Single entry point for all CLI and API requests; JWT authorisation | AWS API Gateway HTTP API v2 | Cognito User Pool (JWT JWKS) | AWS-managed; scales to millions of requests/month |
| Cognito User Pool | JWT issuance, refresh token management, user identity, post-confirmation trigger | Amazon Cognito | Lambda (post-confirmation trigger), DynamoDB | Scales to 50K+ MAUs; no manual capacity management |
| Post-Confirmation Lambda | Eager DynamoDB user-profile and quota-counter initialisation on sign-up | AWS Lambda (Python 3.12) | Cognito, DynamoDB user_profiles table | Auto-scales with Cognito trigger invocations |
| API Route Lambdas (×11) | JWT-protected HTTP handlers for all API routes: generate, status, download, quota, admin | AWS Lambda (Python 3.12) | API Gateway, DynamoDB, S3, Step Functions | Reserved concurrency per route; auto-scales |
| Step Functions State Machine | Agent-graph orchestration; graded artifact-delivery policy; retry state management | AWS Step Functions (Standard Workflow) | AgentCore agents, DynamoDB solution_state, SNS DLQ | Scales to thousands of concurrent executions |
| Input Validator Agent | Validates brief.txt format, completeness, and EO Framework schema compliance | Bedrock AgentCore + Strands + Claude Haiku 4.5 | ECR container image, S3 (brief input) | AgentCore auto-scales agent containers |
| Pre-Sales Generator Agent | Generates five presales artifacts (solution-briefing, SOW, discovery-questionnaire, LOE, infrastructure-costs) | Bedrock AgentCore + Strands + Claude Sonnet 4.6 | ECR container image, S3 (output), eof-tools | AgentCore auto-scales agent containers |
| Delivery Generator Agent | Generates six delivery artifacts (detailed-design, test-plan, runbook, implementation-guide, change-management, as-built) | Bedrock AgentCore + Strands + Claude Sonnet 4.6 | ECR container image, S3 (output), eof-tools | AgentCore auto-scales agent containers |
| Code Generator Agent | Generates Terraform IaC automation bundle; triggers GitHub commit | Bedrock AgentCore + Strands + Claude Sonnet 4.6 | ECR container image, S3, Secrets Manager (PAT), GitHub API | AgentCore auto-scales; GitHub rate limit: 5K req/hour |
| EO Validator Agent | Runs format-check + LLM quality-check on every artifact; manages retry signals | Bedrock AgentCore + Strands + Claude Haiku 4.5 | ECR container image, S3 (artifact input), Step Functions callback token | AgentCore auto-scales agent containers |
| DynamoDB (user_profiles) | User metadata, quota counters (per-user monthly), profile initialisation | Amazon DynamoDB (on-demand) | Lambda (post-confirmation), API Route Lambdas | On-demand auto-scales; no provisioned capacity required |
| DynamoDB (solution_state) | Per-solution execution state, artifact status, retry counts, phase token usage | Amazon DynamoDB (on-demand) | Step Functions, all agents, CLI status route | On-demand auto-scales; TTL-based archival after 90 days |
| DynamoDB (quota_global) | Global monthly solution pool counter (1,000/month hard cap) | Amazon DynamoDB (on-demand) | API Route Lambda (generate), scheduled Lambda (monthly reset) | On-demand; single-key hot partition mitigated by conditional writes |
| Amazon S3 (artifact bucket) | Raw markdown/CSV + converted DOCX/PPTX/XLSX storage; versioned with Glacier lifecycle | Amazon S3 (Standard) | All agents, API Route Lambdas, GitHub integration Lambda | Unlimited storage; lifecycle policy to Glacier for non-current versions after 30 days |
| Amazon ECR | Docker images for all five agents with eof-tools baked in; vulnerability scanning | Amazon ECR | CodeBuild (image push), AgentCore (image pull) | Lifecycle policy: retain 3 most recent tagged versions |
| Secrets Manager | GitHub PAT, Cognito app client secret, all API keys with automatic rotation | AWS Secrets Manager | Code Generator Lambda, Cognito triggers, CI/CD pipeline | Scales with API call volume; rotation Lambda invoked on schedule |
| CloudWatch | Logs, custom metrics (token usage, latency, retry rate), dashboards, alarms | Amazon CloudWatch | All Lambda functions, all agents, Step Functions | AWS-managed; log ingestion scales with volume |

## Technology Stack

The following table captures the definitive technology stack for the platform, with the rationale for each choice tied directly to the SOW requirements.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Layer | Technology | Rationale |
|-------|------------|-----------|
| AI Generation | Amazon Bedrock — Claude Sonnet 4.6 | Highest-quality artifact output for presales/delivery content; selected in SOW as primary generation model |
| AI Validation | Amazon Bedrock — Claude Haiku 4.5 | 5× cost advantage over Sonnet 4.6 at comparable accuracy for structured validation tasks; reduces per-solution Bedrock spend |
| Agent Framework | Strands Agents (OSS, Apache 2.0) | Multi-agent graph construction and inter-agent messaging; Apache 2.0 means zero licensing cost |
| Agent Hosting | Bedrock AgentCore Runtime | Serverless agent hosting in us-west-2; eliminates EC2 instance management; scales automatically with solution volume |
| Orchestration | AWS Step Functions (Standard Workflow) | Durable state management, built-in retry logic, graded delivery policy enforcement, full execution history for audit |
| API Layer | API Gateway HTTP API v2 + Lambda (Python 3.12) | Lowest-latency API tier; JWT native integration; 11 routes; cost-efficient at ~$1/M requests |
| Authentication | Amazon Cognito User Pools | JWT issuance + refresh token management + MFA eligibility; post-confirmation trigger for eager quota initialisation |
| Database | Amazon DynamoDB (on-demand capacity) | Atomic conditional writes for quota enforcement; single-digit millisecond latency; no provisioned capacity planning |
| Storage | Amazon S3 (Standard + Glacier lifecycle) | Unlimited artifact storage; versioning + PITR-equivalent via versioning; Glacier lifecycle for cost control |
| Container Registry | Amazon ECR | Private container registry for agent images; vulnerability scanning; lifecycle policy for image retention |
| Secrets Management | AWS Secrets Manager | Automatic rotation for GitHub PAT (90-day) and Cognito secrets (365-day); no plaintext credentials in Lambda env vars |
| IaC | Terraform (HashiCorp) | Full-platform infrastructure-as-code; `terraform validate` CI gate in CodeBuild |
| CI/CD | AWS CodePipeline + CodeBuild | Docker image build, ECR push, AgentCore re-registration, and automated smoke test on every deploy |
| Observability | Amazon CloudWatch (Logs + Metrics + Dashboards + Alarms) | Native AWS integration; custom metrics for per-phase token usage; alarms for error rate and latency SLAs |
| Security | AWS GuardDuty + CloudTrail + KMS | Threat detection, API-level audit trail with WORM retention, SSE-KMS encryption for all data at rest |
| Networking | AWS VPC + Private Subnets + NAT Gateway + VPC Endpoints | Private network isolation; VPC endpoints eliminate NAT charges for Bedrock/DynamoDB/S3; NAT handles GitHub API egress |
| Artifact Conversion | eof-tools (~30 Python modules, PREDICTif asset) | Existing internal converter library producing DOCX, PPTX, XLSX; baked into ECR image at build time |
| CLI Distribution | pip / PyPI | 14-subcommand CLI; zero hosting cost beyond existing infrastructure; standard for Python developer distribution |
| Artifact Delivery | GitHub (public repository + PAT) | Automated artifact commit and versioning; PAT stored in Secrets Manager with 90-day rotation |

---

# Security & Compliance

The security architecture of the Amatra Agentic Pre-Sales Platform implements defence-in-depth across four layers: identity, network, data, and application. Every security control is aligned to the SOW Security & Compliance section and to the SOC 2 Type II Trust Services Criteria (TSC) baseline. Security is not bolted on post-deployment — it is built into every component from the VPC design through the application-layer quota enforcement.

## Identity & Access Management

All platform access is gated by Amazon Cognito User Pools with JWT-based authentication. Every CLI invocation and API request carries a Cognito-issued JWT bearer token validated by the API Gateway JWT authoriser against the Cognito User Pool's JWKS endpoint before any Lambda handler executes. Access tokens expire after one hour; refresh tokens have a thirty-day TTL with automatic rotation. The post-confirmation Lambda trigger fires on every successful Cognito sign-up and eagerly writes the user's DynamoDB profile with quota counters initialised to zero, ensuring every authenticated request has a valid quota record before the first generation attempt.

IAM execution roles follow strict least-privilege principles. Every Lambda function, AgentCore agent, CI/CD pipeline component, and Step Functions state machine has a dedicated IAM execution role with permissions scoped to only the specific resources and actions required for its function. No wildcard resource policies (`*`) exist in production. IAM permission boundaries are enforced on developer and CI/CD roles to prevent privilege escalation. All role assumptions are logged via CloudTrail. Administrative access to the AWS account requires MFA and is restricted to a named break-glass IAM role.

### Role Definitions

The following roles govern all human and service access to the platform across all three environments.

<!-- TABLE_CONFIG: widths=[20, 40, 40] -->
| Role | Permissions | Scope |
|------|-------------|-------|
| PlatformAdministrator | Full CloudFormation/Terraform apply, Cognito User Pool admin, DynamoDB table admin, S3 bucket policy management | Production — MFA required; CTO approval for first activation |
| CloudEngineer (Vendor) | VPC, IAM role provisioning, S3/DynamoDB CRUD, Lambda deploy, ECR push | Dev and Staging environments only; break-glass time-limited for Production during hypercare |
| AgentCoreExecutionRole-{AgentName} | Bedrock InvokeModel (scoped to Sonnet 4.6 or Haiku 4.5 ARN only), S3 PutObject/GetObject (artifact bucket scoped), DynamoDB UpdateItem (solution_state table only), CloudWatch PutMetricData | Per-agent, per-task scoped — five separate roles, one per agent |
| LambdaExecutionRole-{RouteName} | DynamoDB GetItem/UpdateItem/ConditionCheck (user_profiles and quota_global scoped), S3 GetObject (artifact bucket), Step Functions StartExecution | Per-route scoped — eleven separate roles |
| CognitoTriggerLambdaRole | DynamoDB PutItem (user_profiles table only), CloudWatch PutLogEvents | Scoped to post-confirmation trigger function only |
| CodePipelineServiceRole | CodeBuild:StartBuild, ECR:GetAuthorizationToken, ECR:BatchCheckLayerAvailability, ECR:PutImage | Scoped to platform ECR repository and CodeBuild projects |
| PREDICTifConsultant (Cognito) | API Gateway invoke (JWT-protected routes), S3 GetObject (own solution artifacts via pre-signed URLs), CLI credential storage (local only) | Platform end-users — quota enforced at DynamoDB layer |
| Auditor | CloudTrail GetTrail/LookupEvents, CloudWatch Logs read, DynamoDB scan (read-only), S3 GetObject (audit bucket read) | All environments — read-only; no write or invoke permissions |

## Secrets Management

All credentials are managed exclusively through AWS Secrets Manager. No plaintext credentials appear in Lambda environment variables, container image layers, ECR image contents, Terraform state files, or GitHub repository contents.

- **GitHub PAT:** Stored as `amatra/github-pat` in Secrets Manager; retrieved at runtime by the Code Generator agent Lambda; automatic rotation every 90 days via a dedicated Lambda rotation function
- **Cognito App Client Secret:** Stored as `amatra/cognito-app-client-secret`; used by the CLI credential refresh flow; rotates every 365 days
- **Bedrock API credentials:** Not stored in Secrets Manager — all Bedrock access uses IAM execution roles (no API keys required); no static credentials exist for Bedrock
- **Access logging:** Every Secrets Manager GetSecretValue call is logged via CloudTrail; alerts fire on anomalous access patterns (e.g., retrieval from unexpected Lambda ARN)

## Network Security

The platform is deployed within a purpose-built VPC in us-west-2 across three availability zones. All Lambda functions and AgentCore containers run in private subnets with no inbound internet access. VPC interface endpoints are provisioned for Amazon Bedrock, DynamoDB, S3, Secrets Manager, ECR API, ECR DKR, CloudWatch Logs, and Step Functions — keeping all internal service traffic on the AWS private backbone and eliminating NAT Gateway charges for high-volume Bedrock and DynamoDB interactions.

- **Segmentation:** Three subnet tiers — private (Lambda/AgentCore), database (DynamoDB VPC endpoint association), and public (NAT Gateway only)
- **Firewall:** Security groups implement default-deny with explicit allow rules scoped to CIDR prefix lists and VPC endpoint security group IDs; no 0.0.0.0/0 ingress rules
- **Egress Control:** NAT Gateway handles only GitHub API calls (api.github.com) and CLI distribution traffic (pypi.org); all other egress routes through VPC endpoints
- **DDoS Protection:** API Gateway HTTP API v2 includes AWS Shield Standard at no additional cost; WAF is not required at PoC scale but is recommended for Phase 2

## Data Protection

All data at rest and in transit is encrypted using AWS-managed and customer-managed keys.

- **Encryption at Rest (S3):** Server-side encryption with customer-managed KMS key (SSE-KMS); S3 bucket policy enforces `aws:SecureTransport` condition denying any non-HTTPS request
- **Encryption at Rest (DynamoDB):** AWS-managed KMS encryption on all three tables (user_profiles, solution_state, quota_global)
- **Encryption at Rest (CloudWatch Logs):** Dedicated KMS CMK for CloudWatch Log Group encryption
- **Encryption at Rest (Secrets Manager):** KMS-encrypted secret values with envelope encryption
- **Encryption in Transit:** TLS 1.2 minimum enforced on all API Gateway endpoints, all S3 bucket policy conditions, all DynamoDB endpoint connections, and all VPC endpoint communications
- **Key Management:** Customer-managed KMS keys for S3 and CloudWatch Logs; automatic key rotation enabled (annual); AWS-managed keys for DynamoDB and Secrets Manager
- **Data Masking:** Synthetic test data in Dev environment; anonymised sample briefs in Staging; no real client data in non-production environments

## Compliance Mappings

The following table maps each SOC 2 Trust Services Criteria control requirement to its implementation in the platform. This evidence corpus supports a future SOC 2 Type II audit.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Framework | Requirement | Implementation |
|-----------|-------------|----------------|
| SOC 2 — CC6.1 (Logical Access) | Restrict logical access to authorised users | Amazon Cognito User Pool + JWT authoriser on all 11 API routes; IAM least-privilege per Lambda function |
| SOC 2 — CC6.3 (Access Restriction) | Implement access restriction policies | IAM permission boundaries on all developer and CI/CD roles; no wildcard resource policies in production |
| SOC 2 — CC6.7 (Encryption in Transit) | Encrypt data in transit | TLS 1.2 enforced on API Gateway, S3 bucket policy, and all VPC endpoint communications |
| SOC 2 — CC7.2 (System Monitoring) | Monitor system components for anomalies | CloudTrail data events (S3 + DynamoDB), GuardDuty HIGH-severity alerts, CloudWatch Logs with 90-day retention |
| SOC 2 — A1.2 (Availability Commitments) | Meet availability commitments and system requirements | DynamoDB PITR (35-day window), S3 versioning with Glacier lifecycle, Lambda multi-AZ execution, 4-hour RTO DR tested in Phase 3 |
| SOC 2 — PI1.2 (Processing Integrity) | Process inputs completely and accurately | EO Validator agent format-check + LLM quality-check with bounded 3-retry loop; Input Validator agent rejects malformed briefs before generation |
| SOC 2 — C1.1 (Confidentiality) | Identify and maintain confidential information | S3 SSE-KMS encryption, DynamoDB KMS encryption, Secrets Manager for all credentials, no PII in generation pipeline |

## Audit Logging & SIEM Integration

All security-relevant events are logged to CloudWatch Logs and CloudTrail with structured JSON formatting and correlation IDs linking every event to a solution generation run.

- **What is logged:** Every API Gateway request (request ID, user sub, route, latency, status), every Lambda invocation (function name, correlation ID, quota check result), every DynamoDB conditional write (success/failure, table, user sub), every AgentCore agent invocation (agent name, input hash, output artifact S3 key, token counts), every Secrets Manager GetSecretValue call (secret ARN, caller Lambda ARN), every Cognito authentication event (user sub, success/failure, MFA status)
- **Retention policy:** CloudWatch Logs — 90-day minimum retention; CloudTrail logs — 365-day WORM retention in dedicated audit S3 bucket with object lock enabled
- **SIEM integration approach:** CloudTrail logs delivered to the audit S3 bucket are available for ingestion by PREDICTif's nominated SIEM tool via S3 event notification or polling. An EventBridge rule forwards GuardDuty HIGH-severity findings and CloudWatch Alarm state changes to an SNS topic for immediate notification to the Amatra security contact and PREDICTif's nominated security contact

---

# Data Architecture

The platform's data architecture is designed around three artifact tiers, three DynamoDB tables, and a clear data flow from client brief ingestion through multi-agent generation to S3 storage and GitHub commit. Data classification, retention, and access control policies are defined from day one to support both operational needs and the SOC 2 Type II control evidence requirements.

## Data Model

### Conceptual Model

The platform's data domain centres on three core entities: **Users** (Cognito-authenticated consultants with DynamoDB-tracked profiles and quota counters), **Solutions** (generation runs identified by a UUID `solution_id`, tracking per-artifact state through the agent pipeline), and **Artifacts** (the twelve output objects — raw markdown/CSV and converted DOCX/PPTX/XLSX — stored in S3 under deterministic key paths). Users initiate Solutions; Solutions produce Artifacts; all three entities are linked by the `solution_id` correlation key that propagates through every log entry, DynamoDB record, S3 object key, and GitHub commit message.

### Logical Model

The following table defines the key DynamoDB entities and their attributes, estimated per-record volume, and relationships.

<!-- TABLE_CONFIG: widths=[20, 25, 30, 25] -->
| Entity | Key Attributes | Relationships | Volume |
|--------|----------------|---------------|--------|
| UserProfile (user_profiles table) | PK: `user_id` (Cognito sub UUID); SK: `PROFILE`; `email`, `display_name`, `monthly_quota_used` (atomic counter), `quota_reset_month` (YYYY-MM), `created_at`, `last_active` | 1:many to SolutionState (via user_id); 1:1 to Cognito user | ~120 records at go-live; grows with MAUs |
| SolutionState (solution_state table) | PK: `solution_id` (UUID); SK: `STATE`; `user_id`, `status` (QUEUED/RUNNING/VALIDATING/COMPLETE/FAILED), `phase` (1–5 agent stages), `artifact_status` (map of 12 artifact keys to status), `retry_counts` (map), `token_usage_by_phase` (map), `created_at`, `updated_at`, `ttl` (90-day archive) | Many:1 to UserProfile; 1:12 to S3 artifact objects | ~200 active records/month; archived via TTL after 90 days |
| ArtifactStatus (embedded in SolutionState) | `artifact_key` (e.g., `solution-briefing.md`), `status` (PENDING/GENERATING/VALIDATING/PASSED/FAILED), `retry_count` (0–3), `s3_raw_key`, `s3_converted_key`, `validated_at` | Embedded map within SolutionState | 12 entries per solution record |
| QuotaGlobal (quota_global table) | PK: `GLOBAL`; SK: `QUOTA`; `solutions_used_this_month` (atomic counter), `quota_limit` (1000), `reset_month` (YYYY-MM), `last_override_by`, `last_override_at` | Checked atomically with UserProfile quota on every generate request | 1 record; updated on every solution initiation and monthly reset |

### S3 Object Key Schema

All S3 artifact objects follow a deterministic key schema to enable consistent retrieval, audit, and lifecycle management:

- Raw artifacts: `{solution_id}/raw/pre-sales/{artifact_filename}` and `{solution_id}/raw/delivery/{artifact_filename}`
- Converted artifacts: `{solution_id}/converted/pre-sales/{artifact_filename}` and `{solution_id}/converted/delivery/{artifact_filename}`
- Client briefs (input): `{solution_id}/input/brief.txt`
- Validation reports: `{solution_id}/validation/{artifact_filename}.validation.json`

## Data Flow Design

The following describes how data moves through the platform from client brief submission to final GitHub commit, following the five-stage agent pipeline.

1. **Ingestion:** The consultant submits a client brief (`brief.txt`) via the CLI `generate` subcommand or the `POST /api/v1/solutions` route. The API Gateway JWT authoriser validates the Cognito token; the Generate Lambda performs an atomic DynamoDB conditional write to decrement both the per-user quota counter and the global pool counter. If either quota is exhausted, the request is rejected with HTTP 429. If both quotas are available, the brief is written to S3 at `{solution_id}/input/brief.txt` and a Step Functions execution is started with the `solution_id` as the execution name
2. **Validation:** The Input Validator agent reads `brief.txt` from S3, executes deterministic schema validation against the EO Framework brief format, and updates `SolutionState.status` to `RUNNING` or `FAILED` (with rejection reason) in DynamoDB. Validated briefs proceed to the parallel generation stage; malformed or adversarial briefs are rejected with a structured error response
3. **Processing:** The Step Functions state machine executes the Pre-Sales Generator, Delivery Generator, and Code Generator agents in a coordinated sequence (presales artifacts first, delivery artifacts in parallel with code generation). Each generator agent reads from S3 (`brief.txt` and prior-phase artifacts as context), invokes Claude Sonnet 4.6 via Bedrock, writes raw markdown/CSV output to S3, and invokes the eof-tools converter to produce the converted Office documents. Per-phase token counts are written to `SolutionState.token_usage_by_phase` after each generation step
4. **Storage:** All twelve raw artifacts are stored in S3 under `{solution_id}/raw/`, and all converted Office documents under `{solution_id}/converted/`. S3 versioning is enabled; lifecycle policy moves non-current versions to S3 Glacier after 30 days
5. **Distribution:** After all twelve artifacts pass EO Validator (format-check + LLM quality-check), the Code Generator agent's GitHub integration module commits all artifacts to the public repository via the Secrets Manager-stored PAT. The `SolutionState.status` is updated to `COMPLETE` in DynamoDB. The CLI `status` subcommand polls the Step Functions execution status and DynamoDB `SolutionState` record to surface real-time progress and final per-phase token usage to the consultant

## Data Migration Strategy

There is no data migration from the current state to the target state. The existing OneDrive-based artifact storage is not migrated to S3 — consultants will continue to use the existing GitHub repository for pre-existing artifacts. New solutions generated by the platform will be stored in S3 and committed to GitHub from the first go-live solution generation. This clean-slate approach eliminates migration risk and protects the April 2026 delivery deadline.

## Data Governance

- **Classification:** All artifacts in S3 are tagged `DataClassification: PREDICTif-Confidential` during generation; once committed to the public GitHub repository, they are treated as public. Client briefs (`brief.txt`) are tagged `DataClassification: PREDICTif-Confidential` and are never committed to the public repository
- **Retention:** S3 artifacts — 365-day active retention (configurable via S3 lifecycle policy), then Glacier transition. DynamoDB `solution_state` records — 90-day active TTL, then automatically archived. DynamoDB `user_profiles` and `quota_global` — indefinite retention. CloudTrail logs — 365-day WORM in audit bucket. CloudWatch Logs — 90-day minimum
- **Quality:** Every artifact must pass EO Validator format-check (deterministic schema) and LLM quality-check (Claude Haiku 4.5) before being marked `PASSED` in `SolutionState`. Validation failure details are written to `{solution_id}/validation/{artifact_filename}.validation.json` for debugging and audit
- **Access:** Artifact retrieval is via pre-signed S3 URLs issued by the `GET /api/v1/solutions/{solution_id}/artifacts/{artifact_key}` Lambda route, scoped to the authenticated user's own solutions. Cross-user artifact access is blocked by IAM condition (`s3:prefix` condition key scoped to `{user_id}/`)

---

# Integration Design

The platform integrates with five external systems — Amazon Bedrock, Amazon Cognito, Amazon DynamoDB, Amazon S3, and GitHub — plus exposes eleven JWT-protected Lambda API routes and a pip-installable CLI. All integrations are designed for resilience, with retry logic, dead-letter queues, and graceful degradation for every external dependency.

## External System Integrations

The following table documents all external system integrations, their protocols, data formats, error handling strategies, and SLA targets.

<!-- TABLE_CONFIG: widths=[18, 15, 15, 15, 22, 15] -->
| System | Type | Protocol | Format | Error Handling | SLA |
|--------|------|----------|--------|----------------|-----|
| Amazon Bedrock (Claude Sonnet 4.6) | Real-time (agent-invoked) | AWS SDK (Bedrock Runtime) | JSON (prompt/response) | 3 retries with exponential backoff; Step Functions catches ThrottlingException; SNS DLQ on persistent failure | < 60 min P95 per solution |
| Amazon Bedrock (Claude Haiku 4.5) | Real-time (validator-invoked) | AWS SDK (Bedrock Runtime) | JSON (validation prompt/response) | 3 retries per artifact; bounded retry loop; graceful fail with error details in validation JSON | < 60 min P95 per solution |
| Amazon Cognito User Pools | Real-time (JWT validation per API request) | HTTPS (JWKS endpoint) | JWT Bearer token | API Gateway rejects with HTTP 401 on invalid/expired token; CLI auto-refreshes on 401 response | < 500ms token validation |
| Amazon DynamoDB | Real-time (quota enforcement, state updates) | AWS SDK (DynamoDB) | JSON (DynamoDB attribute maps) | Conditional write failure returns HTTP 429 (quota exhausted); retry with exponential backoff on ProvisionedThroughputExceededException | < 10ms p99 DynamoDB latency |
| Amazon S3 | Real-time (artifact read/write) | AWS SDK (S3) | Binary (DOCX/PPTX/XLSX), plain text (MD/CSV) | Retry on 5xx with exponential backoff; version rollback on partial write detection | < 5ms p99 S3 PUT in us-west-2 |
| GitHub API | Async (post-generation commit) | HTTPS REST (api.github.com) | JSON (commit payload), Base64 (artifact content) | 3 retries on HTTP 5xx; exponential backoff; SNS alert on PAT authentication failure (401/403); commit deferred, not lost | GitHub 99.9% monthly uptime SLA |

## API Design

The platform exposes a RESTful HTTP API through API Gateway HTTP API v2. All eleven routes require a valid Cognito JWT bearer token; no route is accessible without authentication. The API follows resource-oriented URL design with versioned paths (`/api/v1/`) and consistent JSON request/response schemas.

- **Style:** REST (resource-oriented, stateless)
- **Versioning:** URL path versioning (`/api/v1/`) to allow non-breaking evolution to `/api/v2/` in a future phase
- **Authentication:** Bearer JWT (Cognito-issued access token) on all routes; token validation by API Gateway JWT authoriser
- **Rate Limiting:** Per-route throttling on API Gateway (burst limit: 100 requests/route; steady-state: 50 requests/second per route); per-user solution generation quota enforced at DynamoDB layer (10/month)
- **Error Response Schema:** All error responses return `{"error": {"code": "<CODE>", "message": "<MSG>", "solution_id": "<UUID_IF_APPLICABLE>"}}` with appropriate HTTP status codes

### API Endpoints

The following table defines all eleven JWT-protected Lambda API routes, their authentication requirement, and their purpose.

<!-- TABLE_CONFIG: widths=[10, 42, 15, 33] -->
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | /api/v1/solutions | Bearer JWT | Initiate a new solution generation run; validates brief payload; decrements per-user and global quota counters; starts Step Functions execution; returns `solution_id` |
| GET | /api/v1/solutions/{solution_id} | Bearer JWT | Retrieve solution status, phase progress, artifact status map, and per-phase token usage from DynamoDB `solution_state` |
| GET | /api/v1/solutions/{solution_id}/artifacts | Bearer JWT | List all artifacts for a solution with their S3 keys, conversion status, and validation results |
| GET | /api/v1/solutions/{solution_id}/artifacts/{artifact_key} | Bearer JWT | Generate a pre-signed S3 URL for downloading a specific artifact (raw or converted) |
| DELETE | /api/v1/solutions/{solution_id} | Bearer JWT | Mark a solution as cancelled in DynamoDB; signal Step Functions execution stop if still running |
| GET | /api/v1/quota | Bearer JWT | Return the authenticated user's current quota usage (used/limit/reset date) and global pool status |
| GET | /api/v1/solutions | Bearer JWT | List all solutions for the authenticated user with pagination (max 50 per page, cursor-based) |
| POST | /api/v1/auth/refresh | Public (Cognito refresh token) | Exchange a Cognito refresh token for a new access token; used by CLI auto-refresh on 401 |
| GET | /api/v1/admin/usage | Bearer JWT + Admin Scope | Return aggregate platform usage: solutions generated this month, total token spend, per-user top-10 list, global quota remaining |
| POST | /api/v1/admin/quota/reset | Bearer JWT + Admin Scope | Manually reset a specific user's monthly quota counter; requires admin Cognito group membership; logged to DynamoDB with admin sub and timestamp |
| GET | /api/v1/health | Public | Platform health check returning Lambda cold-start warmth indicator and DynamoDB connectivity status; used by CloudWatch synthetic canary |

## Authentication & SSO Flows

The platform uses Amazon Cognito User Pools as the sole identity provider. There is no federated SSO in scope for this engagement; all consultants sign up directly in the Cognito User Pool.

- **Sign-up flow:** Consultant registers via `amatra login` CLI subcommand → Cognito sends email verification → post-confirmation Lambda trigger fires → DynamoDB `user_profiles` record created with `monthly_quota_used=0` and `quota_reset_month=YYYY-MM` → consultant can immediately invoke `amatra generate`
- **Authentication flow:** CLI calls `POST /api/v1/auth/refresh` with Cognito refresh token (stored in local credential file at `~/.amatra/credentials`) to obtain a new access token; access tokens have 1-hour TTL and are refreshed transparently on 401 responses
- **Token management:** Cognito access tokens (1-hour TTL) and refresh tokens (30-day TTL) are stored in the local CLI credential file with OS-level file permissions (chmod 600); no tokens are stored in environment variables or shell history
- **Service-to-service auth:** All agent-to-service calls (Bedrock, DynamoDB, S3, Secrets Manager) use IAM execution roles with no static credentials; all authentication is via temporary STS credentials vended to the Lambda/AgentCore execution environment

## Messaging & Event Patterns

The platform uses Step Functions as the primary orchestration mechanism, with SNS/SQS for failure escalation and asynchronous notification.

- **Queue Service:** Amazon SQS Dead Letter Queue (DLQ) — receives failed Step Functions execution events and unresolvable EO Validator retry failures; polled by an alarm Lambda that fires a CloudWatch alarm and sends SNS notification to the operations team
- **Event Bus:** AWS Step Functions execution events are published to EventBridge for CloudWatch dashboarding and downstream notification (e.g., email to consultant on solution completion)
- **Dead Letter Queue:** Every Step Functions state machine has a `Catch` clause routing unhandled failures to the DLQ; DLQ depth > 0 triggers a CloudWatch alarm with `CRITICAL` severity
- **Retry Policy:** Per-artifact: up to 3 retries by EO Validator with exponential backoff (1s, 2s, 4s between retry invocations); per-Bedrock API call: up to 3 retries on `ThrottlingException` with exponential backoff (5s, 10s, 20s); Step Functions state-level retries: 2 retries on `States.TaskFailed` before routing to DLQ

---

# Infrastructure & Operations

The infrastructure is fully serverless and deployed exclusively in AWS us-west-2. There are no EC2 instances, no managed container clusters, and no physical infrastructure. All compute is provided by Lambda and Bedrock AgentCore Runtime; all storage is provided by S3 and DynamoDB. This section defines the network design, compute sizing, high availability posture, disaster recovery targets, monitoring strategy, and cost model.

## Network Design

The platform is deployed within a purpose-built VPC (`10.0.0.0/16`) in us-west-2 across three availability zones (us-west-2a, us-west-2b, us-west-2c). Lambda functions execute in private subnets with no inbound internet access; all internal service traffic routes through VPC endpoints.

- **VPC CIDR:** 10.0.0.0/16
- **Private Subnets (Lambda/AgentCore):** 10.0.1.0/24 (us-west-2a), 10.0.2.0/24 (us-west-2b), 10.0.3.0/24 (us-west-2c) — hosts all Lambda functions and AgentCore execution environments
- **Public Subnets (NAT Gateway):** 10.0.101.0/24 (us-west-2a), 10.0.102.0/24 (us-west-2b) — hosts NAT Gateway for outbound GitHub API and PyPI traffic only; no inbound internet access
- **VPC Endpoints (Interface):** Amazon Bedrock, Amazon DynamoDB, Amazon S3, AWS Secrets Manager, Amazon ECR API, Amazon ECR DKR, Amazon CloudWatch Logs, AWS Step Functions — all internal service traffic avoids NAT Gateway and stays on the AWS private network
- **Security Groups:** Default-deny; Lambda security group allows egress to VPC endpoint prefixes and NAT Gateway only; no inbound rules required given the Lambda execution model
- **NAT Gateway:** Single NAT Gateway in us-west-2a for GitHub API calls (~30 GB/month outbound data transfer) and PyPI CLI distribution; a second NAT Gateway in us-west-2b is recommended for Phase 2 multi-AZ egress resilience

## Compute Sizing

The platform is serverless — no instance type selection is required for Lambda or AgentCore. The following table documents the configuration parameters for each compute component.

<!-- TABLE_CONFIG: widths=[25, 20, 20, 20, 15] -->
| Component | Instance Type | vCPU (equiv.) | Memory | Count |
|-----------|---------------|---------------|--------|-------|
| API Route Lambdas (×11) | Lambda (ARM64, Graviton2) | 1 (burst) | 512 MB | Up to 100 concurrent per route (reserved) |
| Post-Confirmation Lambda | Lambda (ARM64, Graviton2) | 1 (burst) | 256 MB | Cognito-triggered; no reserved concurrency |
| EO Validator Retry Lambda | Lambda (ARM64, Graviton2) | 1 (burst) | 512 MB | 50 concurrent (reserved) |
| AgentCore — Input Validator | AgentCore Runtime (managed) | AgentCore-managed | AgentCore-managed | Auto-scales with Step Functions invocations |
| AgentCore — Pre-Sales Generator | AgentCore Runtime (managed) | AgentCore-managed | AgentCore-managed | Auto-scales; Sonnet 4.6 avg 8–12 min per agent run |
| AgentCore — Delivery Generator | AgentCore Runtime (managed) | AgentCore-managed | AgentCore-managed | Auto-scales; Sonnet 4.6 avg 8–12 min per agent run |
| AgentCore — Code Generator | AgentCore Runtime (managed) | AgentCore-managed | AgentCore-managed | Auto-scales; Sonnet 4.6 avg 5–8 min per agent run |
| AgentCore — EO Validator | AgentCore Runtime (managed) | AgentCore-managed | AgentCore-managed | Auto-scales; Haiku 4.5 avg 2–3 min per artifact validation |
| CodeBuild (CI/CD) | `BUILD_GENERAL1_MEDIUM` | 4 vCPU | 7 GB | On-demand; triggered by CodePipeline |
| DLQ Alarm Lambda | Lambda (ARM64, Graviton2) | 1 (burst) | 128 MB | Event-driven; SQS trigger |

## High Availability Design

The platform achieves multi-AZ redundancy through the inherent multi-AZ deployment of all serverless services. Lambda executes across all AZs in us-west-2; DynamoDB is natively multi-AZ; S3 stores data redundantly across at least three AZs; AgentCore Runtime distributes agent execution across AZs.

- **Multi-AZ Lambda:** All Lambda functions are deployed in three private subnets across three AZs; Lambda automatically redistributes execution on AZ failure with no manual intervention
- **DynamoDB Multi-AZ:** DynamoDB natively replicates across three AZs in us-west-2; on-demand capacity mode scales automatically without provisioned capacity planning
- **S3 Multi-AZ:** S3 Standard durability (11 nines) with automatic cross-AZ data replication; versioning enabled for all artifact objects
- **Failover Strategy:** No manual failover is required for any component — all services are managed multi-AZ by AWS; the only single-AZ component is the NAT Gateway (single gateway in us-west-2a at PoC scale; Phase 2 adds us-west-2b NAT Gateway)
- **Health Checks:** API Gateway HTTP API v2 integrates Lambda health checks via the `GET /api/v1/health` endpoint; CloudWatch synthetic canary runs every 5 minutes against the health endpoint; alarm fires if two consecutive canary checks fail

## Disaster Recovery

The platform's serverless architecture provides inherent resilience against most failure scenarios. Formal DR targets and backup strategies are defined below, aligned to the SOW RTO/RPO commitments.

- **RPO (DynamoDB):** ≤ 24 hours — Point-in-time recovery (PITR) enabled on all three DynamoDB tables, providing a 35-day recovery window; daily automated backup confirmed in staging during Phase 3
- **RPO (S3 Artifacts):** 0 hours — S3 versioning with cross-AZ redundancy; no data loss on individual AZ failure
- **RTO (Full Platform):** ≤ 4 hours — Terraform IaC enables full re-provisioning of all platform resources from scratch in under 2 hours; Lambda versions and AgentCore image tags provide instant rollback without redeployment
- **Backup Strategy:** DynamoDB PITR enabled (35-day window) on all three tables; S3 versioning with Glacier transition for non-current versions after 30 days; ECR lifecycle policy retains last three tagged agent image versions; Secrets Manager automatic rotation provides implicit secret backup
- **DR Site:** No secondary region in scope for this engagement — us-west-2 only; multi-region expansion is a Phase 2 consideration
- **Runbook Coverage:** Five documented runbook scenarios — agent timeout (Step Functions retry + DLQ alert), DynamoDB quota throttle (on-demand scale-out validated), GitHub PAT expiry (rotation procedure: commit resumes within 15 minutes), Bedrock service disruption (error handling and user-facing message), Cognito User Pool outage (CLI and API fail gracefully with structured error, no data loss)

## Monitoring & Alerting

The observability strategy provides a complete view of platform health across infrastructure, application, and business dimensions. All metrics are surfaced in a CloudWatch dashboard accessible via the `amatra status` CLI subcommand and the `GET /admin/usage` API endpoint.

- **Infrastructure:** Lambda concurrency utilisation, Lambda error rate (%), Lambda cold start rate (%), DynamoDB WCU/RCU consumed, DynamoDB conditional write failure rate, S3 request latency (p50/p99), NAT Gateway bytes processed, API Gateway 4xx/5xx rates, VPC endpoint data transfer
- **Application:** Per-solution end-to-end generation latency (custom metric `AmatraPlatform/GenerationLatencyMs`), per-phase token counts by model (custom metrics `AmatraPlatform/TokenUsage/Sonnet` and `AmatraPlatform/TokenUsage/Haiku`), EO Validator retry rate (custom metric `AmatraPlatform/ValidationRetryRate`), Step Functions execution success/failure rate, DLQ depth
- **Business:** Monthly solution generation count vs. quota limit, per-user quota utilisation, estimated per-solution Bedrock cost (custom metric `AmatraPlatform/TokenCostUSD`), consultant CLI active users (weekly), GitHub commit success rate

### Alert Definitions

The following alerts are configured in CloudWatch with routing to an SNS topic that delivers email notifications to the Amatra operations contact and PREDICTif's nominated technical contact (Marcus Patel or Daniel Park).

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Alert | Condition | Severity | Response |
|-------|-----------|----------|----------|
| High Lambda Error Rate | Lambda error rate > 1% over 5-minute window (any function) | HIGH | Investigate CloudWatch Logs for stack traces; check DynamoDB connectivity; escalate to on-call if persists > 15 minutes |
| Step Functions Execution Failure | Execution failure rate > 2% over 15-minute window | HIGH | Check DLQ depth; identify failing artifact type; trigger manual retry or initiate rollback if systemic |
| DLQ Depth > 0 | SQS DLQ receives any message | CRITICAL | Immediate alert to on-call; retrieve DLQ message; identify root cause (agent failure, Bedrock throttle, validation loop exhaustion) |
| Bedrock Daily Token Spend > Budget | Daily Bedrock token spend > 110% of daily budget ($5 × expected daily solutions) | HIGH | Investigate runaway retry loops; check EO Validator retry counts; apply emergency throttle if needed |
| DynamoDB Conditional Write Failure Spike | > 10 conditional write failures per minute on quota tables | MEDIUM | Check for concurrent generation flood; confirm quota reset Lambda ran correctly; verify atomic write correctness |
| Cognito Authentication Failure Spike | > 50 failed authentication attempts in 5 minutes | HIGH | Potential credential stuffing; GuardDuty alert expected; notify PREDICTif security contact; consider temporary Cognito block |
| GuardDuty HIGH Finding | GuardDuty finding severity ≥ 7.0 | CRITICAL | Immediate security incident response; notify PREDICTif CTO and Amatra Engagement Lead; follow security incident runbook |
| CloudWatch Canary Failure | Health endpoint fails 2 consecutive 5-minute canary checks | CRITICAL | Immediately check Lambda health; verify VPC endpoint connectivity; escalate to P1 if platform unreachable |
| P95 Generation Latency Breach | Rolling 1-hour P95 generation latency > 60 minutes | HIGH | Identify slow agent phase via token usage metrics; check Bedrock throttling; check Step Functions execution graph |
| GitHub Commit Failure | 3 consecutive GitHub API calls fail with non-5xx error | HIGH | Check PAT validity in Secrets Manager; verify GitHub repository access; trigger PAT rotation if 401/403 |

## Logging & Observability

A structured, correlated observability stack ensures every platform event is traceable from API request to agent invocation to artifact storage.

- **Log aggregation:** All Lambda functions emit structured JSON logs to CloudWatch Logs with a `correlation_id` field equal to the `solution_id` (UUID), enabling cross-function log correlation via CloudWatch Logs Insights queries. Log groups are named `/amatra/{environment}/{function-name}` with 90-day retention
- **Distributed tracing:** AWS X-Ray is enabled on all Lambda functions and API Gateway for end-to-end request tracing. X-Ray service maps visualise the complete call graph from API Gateway through Lambda through DynamoDB and S3. Trace IDs are included in all error responses to the CLI for support ticket correlation
- **Token usage dashboards:** The CloudWatch dashboard `AmatraPlatform-{environment}` includes a widget for per-phase token counts (Sonnet 4.6 vs. Haiku 4.5), a widget for estimated daily and monthly Bedrock cost, and a widget for validation retry distribution (0 retries / 1 retry / 2 retries / 3 retries / failed). The same data is surfaced in the CLI `amatra status {solution_id}` command and the `GET /admin/usage` API endpoint

## Cost Model

The following cost model is derived directly from the infrastructure-costs.csv 3-Year Summary for solution OPP-2026-001. Year 1 figures reflect list pricing and applied AWS partner credits; Year 2–3 reflect projected volume growth.

<!-- TABLE_CONFIG: widths=[30, 25, 25, 20] -->
| Category | Monthly Estimate (Y1 Steady State) | Optimisation | Savings |
|----------|-------------------------------------|--------------|---------|
| Amazon Bedrock — Claude Sonnet 4.6 | $4,500/month | Use Haiku 4.5 for all validation tasks (EO Validator); minimise Sonnet 4.6 prompt tokens via structured prompt templates | ~40% vs. Sonnet 4.6 for all tasks |
| Amazon Bedrock — Claude Haiku 4.5 | $850/month | Bounded 3-retry limit per artifact prevents runaway validation costs | Cost ceiling enforced by retry cap |
| Bedrock AgentCore Runtime | $1,200/month | Agents are stateless; no persistent agent sessions; cost scales linearly with solution volume | Linear scaling; no idle cost |
| AWS Lambda | $180/month | ARM64 (Graviton2) runtime; 512 MB memory allocation; X-Ray sampling at 5% | ~20% vs. x86 Lambda pricing |
| API Gateway HTTP API v2 | $10/month | HTTP API v2 (not REST API) at $1.00/M requests | 70% cheaper than REST API tier |
| Amazon Cognito User Pools | $75/month | First 50K MAUs; no WAF integration at PoC scale | Included in free tier for first 50 MAUs |
| Amazon DynamoDB (on-demand) | $120/month | On-demand mode auto-scales; no provisioned capacity waste; TTL-based archival reduces storage costs | ~30% vs. provisioned mode at variable load |
| Amazon S3 | $45/month | Lifecycle policy moves non-current versions to Glacier after 30 days; intelligent tiering for converted artifacts | ~15% via Glacier lifecycle |
| Amazon ECR | $15/month | Lifecycle policy retains only 3 most recent tagged images | Minimal storage cost |
| Amazon CloudWatch | $220/month | X-Ray sampling at 5%; log retention set to minimum acceptable (90 days); custom metrics use 1-minute resolution | Sampling and retention optimisation |
| AWS Secrets Manager | $20/month | ~10 secrets; rotation Lambda included in Lambda free tier | Fixed cost; no optimisation needed |
| VPC + NAT Gateway | $95/month | VPC endpoints for Bedrock/DynamoDB/S3/ECR eliminate NAT charges for high-volume traffic | ~60% NAT cost reduction vs. no VPC endpoints |
| AWS Step Functions | $35/month | Standard Workflow at $0.025/1K transitions; ~500 transitions/solution | Cost scales linearly with solution volume |
| Data Transfer Out | $180/month (200 GB) | VPC endpoints eliminate inter-service data transfer charges | ~50% of naive data transfer cost |
| AWS Business Support | $740/month | 10% of monthly AWS spend; standard Business Support plan | No optimisation; required for TAM access |

---

# Implementation Approach

The implementation follows a three-phase Foundation-Build-Validate methodology aligned to the SOW phasing. The approach is designed to front-load security and identity concerns (Phase 1), maximise parallel development on the critical agent path (Phase 2), and gate go-live on a certified green metrics baseline (Phase 3). Every phase ends with a formal milestone review and acceptance gate before the next phase begins.

## Migration/Deployment Strategy

The Amatra Agentic Pre-Sales Platform is a greenfield build — there is no migration of existing systems or data from the current manual workflow to the target platform. The deployment approach is a phased rollout with blue-green capability at the Lambda and AgentCore layers for zero-downtime updates post-go-live.

- **Approach:** Phased greenfield deployment (three phases over twelve weeks)
- **Pattern:** Blue-green via Lambda aliases (stable alias points to last-validated version; traffic shifts via alias update) and AgentCore agent version pinning (previous container image tag retained in ECR for rollback)
- **Validation:** End-to-end integration test after every major deployment; format-check + LLM quality-check validation on all twelve artifact types before go-live acceptance
- **Rollback:** Lambda alias rollback within 5 minutes; AgentCore agent rollback within 15 minutes (re-registration with previous ECR image tag); DynamoDB PITR for data recovery; full platform rollback estimated at 2 hours

## Sequencing & Wave Planning

The following table defines the five delivery phases, their key activities, target duration, and the exit criteria that gate progression to the next phase.

<!-- TABLE_CONFIG: widths=[15, 30, 25, 30] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 — Foundation & Security | Provision VPC, IAM, Cognito User Pool, API Gateway HTTP API v2, DynamoDB tables, S3 bucket, Secrets Manager; deploy 3 CLI auth subcommands (login, logout, refresh); implement post-confirmation Lambda; establish CloudTrail and GuardDuty; CTO sign-off on Cognito design | Weeks 1–4 | Foundation Infrastructure Acceptance Report accepted by Marcus Patel; Cognito User Pool live with JWT authoriser validating test tokens; DynamoDB quota tables operational with atomic conditional write verified; CTO sign-off obtained |
| 2 — Agent Build & Container Integration | Build and push ECR Docker images with eof-tools baked in; register all 5 Strands agents on AgentCore Runtime; implement Step Functions orchestration state machine; build remaining 11 CLI subcommands; implement all 11 Lambda API routes with JWT protection and quota enforcement; integrate Claude Sonnet 4.6 and Haiku 4.5 with prompt templates and retry logic; implement GitHub PAT integration; set up CodePipeline + CodeBuild CI/CD | Weeks 5–9 | Agent Integration Milestone Report accepted; all 5 agents registered in AgentCore; at least one complete 12-artifact solution bundle generated and validated end-to-end; all 11 API routes JWT-protected and quota-enforced; eof-tools converters producing valid DOCX/PPTX/XLSX |
| 3a — Testing & Validation | Execute unit tests (>80% coverage), integration tests (all 12 artifact types), load test (200 solutions/month throughput, P95 < 60 min), security test (OWASP API Top 10, IAM policy review, Cognito JWT bypass testing); instrument per-phase token usage; validate `terraform validate` gate; coordinate UAT with Marcus Patel, Daniel Park, CTO | Weeks 10–11 | Unit test coverage > 80%; all 12 artifact types passing integration tests; load test P95 < 60 min confirmed; security test report completed; UAT sign-off (all three stakeholders) |
| 3b — Green Baseline & Go-Live | Achieve certified green CloudWatch metrics baseline; resolve all P1/P2 defects; complete Terraform IaC full-platform modules; deploy to production us-west-2; publish CLI to PyPI; commit all 12 artifact types to GitHub; deliver runbooks and as-built documentation; conduct knowledge-transfer sessions | Week 12 | Production deployment confirmation; green CloudWatch dashboard certified; CLI `pip install amatra-cli` verified; all 32 SOW deliverables accepted; go-live milestone declared |
| 4 — Hypercare | Monitor production platform; triage and resolve P1/P2/P3 issues; tuning Bedrock token spend; quota counter adjustments; GitHub PAT rotation support; ramp to 200 solutions/month steady state; deliver Optimisation Recommendations and Phase 2 Roadmap | Weeks 13–20 | All P1/P2 issues resolved; steady-state 200 solutions/month throughput confirmed; Phase 2 Roadmap delivered; platform responsibility transferred to PREDICTif operations team |

## Tooling & Automation

The following table defines the tooling used across all implementation categories, aligned to the SOW tooling decisions.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Tool | Purpose |
|----------|------|---------|
| Infrastructure as Code | Terraform (HashiCorp) | Full-platform resource provisioning: VPC, IAM, Cognito, API Gateway, Lambda, DynamoDB, S3, ECR, AgentCore, Step Functions, Secrets Manager, CloudWatch, CodePipeline |
| CI Gate | `terraform validate` in AWS CodeBuild | Syntax validation of all Terraform modules on every PR; blocks merge on validation failure |
| Container Build | AWS CodeBuild (Docker build) | Builds agent Docker images with eof-tools baked in; pushes to ECR; triggers AgentCore re-registration |
| Container Registry | Amazon ECR | Stores five agent Docker images; vulnerability scanning on push; lifecycle policy retains last 3 tagged versions |
| CI/CD Pipeline | AWS CodePipeline + CodeBuild | Source (GitHub) → Build (Docker + Terraform validate) → Deploy (ECR push + Lambda update + AgentCore re-register) → Test (automated smoke test) |
| Agent Framework | Strands Agents (OSS, Apache 2.0) | Multi-agent graph construction, inter-agent messaging contracts, tool invocation wrappers for Bedrock, S3, DynamoDB |
| Artifact Conversion | eof-tools (~30 Python modules) | DOCX, PPTX, XLSX converter pipeline; baked into ECR image at build time; invoked by generator agents via Python import |
| Testing — Unit | pytest + pytest-cov | Unit tests for all Lambda handlers, agent implementations, quota enforcement logic, GitHub integration module; > 80% coverage target |
| Testing — Integration | Custom pytest integration suite | End-to-end tests for all 12 artifact types; verifies EO Validator passes format-check and LLM quality-check |
| Testing — Load | AWS Lambda concurrency test harness + k6 (CLI simulation) | Simulates 200 solutions/month throughput; validates P95 latency < 60 minutes; confirms DynamoDB atomic quota writes under concurrent load |
| Testing — Security | AWS IAM Access Analyzer + OWASP ZAP (API Top 10) | IAM least-privilege policy review; OWASP API Security Top 10 checks on all 11 Lambda routes; Cognito JWT bypass testing |
| Monitoring | Amazon CloudWatch (Logs + Metrics + Dashboards + Alarms) + AWS X-Ray | Structured log aggregation, custom metrics (token usage, latency, retry rate), distributed tracing, alarm management |
| Secret Rotation | AWS Secrets Manager + Lambda rotation function | Automated 90-day GitHub PAT rotation; 365-day Cognito app client secret rotation |
| CLI Distribution | pip (PyPI) | `pip install amatra-cli` distribution to 120 PREDICTif consultants; authenticated via Cognito JWT |

## Cutover Approach

The production cutover is executed at the start of Week 12 following M5 (UAT Sign-Off). The cutover is a clean go-live with no parallel-run period required — the existing manual workflow continues until the platform is live, then consultants switch to the CLI.

- **Type:** Clean cutover (no parallel run)
- **Duration:** T-48h to T-0 (two-day cutover window)
- **Validation:** One complete twelve-artifact solution generated end-to-end in production, including GitHub commit, before go-live is declared
- **Decision Point:** Go/no-go checklist with fourteen items (defined in Testing & Validation section of SOW); all items must be confirmed green by DevOps Engineer and Solution Architect before go-live is declared
- **Cutover sequence:**
  - T-48h: Final staging smoke test completed; all go-live readiness criteria confirmed green
  - T-24h: Production DynamoDB tables, S3 bucket, and Cognito User Pool activated with CTO sign-off
  - T-4h: Full Terraform apply for production environment; all five agents registered in AgentCore
  - T-1h: Production smoke test — one complete twelve-artifact solution generated end-to-end including GitHub commit
  - T-0: Go-live declared; CLI package published to PyPI; announcement distributed to Marcus Patel for rollout to 120 consultants

## Downtime Expectations

- **Planned Downtime:** Zero — the platform is new and does not replace any running system; consultants continue manual workflow until CLI is available; no downtime window required
- **Unplanned Downtime:** MTTR target of 4 hours (aligned to RTO); Lambda multi-AZ execution and DynamoDB multi-AZ replication provide automatic recovery from single-AZ failures without downtime
- **Mitigation:** Serverless architecture eliminates the primary causes of planned downtime (patching, instance restarts, capacity events); the only planned maintenance events are Lambda deployment updates (blue-green via aliases, zero downtime) and Cognito User Pool configuration changes (requires brief read-only mode)

## Rollback Strategy

Rollback is triggered if the production smoke test fails after two attempts, a P1 security vulnerability is discovered post-deployment, or the CTO withholds go-live sign-off.

- **Lambda rollback:** Lambda function aliases are updated to point to the previous stable version within 5 minutes; no redeployment required
- **AgentCore agent rollback:** Agents are re-registered with the previous container image tag from ECR within 15 minutes; the previous image is guaranteed to be available by the ECR lifecycle policy (3 most recent tagged versions retained)
- **DynamoDB rollback:** PITR restore from a pre-cutover backup snapshot if data corruption is detected; restore time estimated at 30–60 minutes depending on table size
- **Infrastructure rollback:** Terraform state file backup taken before production apply; `terraform apply` with the previous state can restore infrastructure configuration
- **Maximum rollback window:** 2 hours for full platform rollback; previous production-equivalent staging environment remains fully operational throughout the cutover window as a clean rollback target
- **Rollback communication:** Rollback decision and status communicated to Marcus Patel and CTO within 15 minutes of trigger; new go-live window confirmed within 24 hours

---

# Appendices

This section provides supporting reference material including architecture diagram inventory, naming conventions, resource tagging standards, a risk register, and a glossary of key terms and acronyms used throughout this document.

## Architecture Diagrams

The following diagrams support the technical design described in this document. The primary architecture diagram is embedded in Section 4 (Solution Architecture) and reproduced here for reference.

- **Solution Architecture Diagram** — Included in Section 4 (Solution Architecture); shows the complete end-to-end platform including API layer, Cognito authentication, Step Functions orchestration, Bedrock AgentCore agents, eof-tools container pipeline, DynamoDB quota enforcement, S3 artifact storage, and GitHub commit flow
- **Network Topology Diagram** — VPC in us-west-2 with three AZs; private subnets (Lambda/AgentCore), public subnets (NAT Gateway); VPC endpoints for Bedrock, DynamoDB, S3, Secrets Manager, ECR, CloudWatch Logs, Step Functions; security group rules; NAT Gateway egress path to GitHub API and PyPI
- **Data Flow Diagram** — Five-stage data flow: (1) brief ingestion via API Gateway → (2) Input Validator → (3) parallel generation (Pre-Sales + Delivery + Code Generator) → (4) EO Validator per-artifact with retry loop → (5) S3 storage + GitHub commit; DynamoDB quota state transitions at each stage
- **Agent Graph Topology** — Step Functions state machine diagram showing agent execution sequence, parallel states (Pre-Sales Generator and Code Generator run in parallel with Delivery Generator), EO Validator retry loop, DLQ escalation path, and graded artifact-delivery policy

## Naming Conventions

All AWS resources follow a deterministic naming convention to enable consistent resource identification, cost allocation, and Terraform management across dev, staging, and production environments.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Resource Type | Pattern | Example |
|---------------|---------|---------|
| VPC | `amatra-{env}-vpc` | `amatra-prod-vpc` |
| Subnet | `amatra-{env}-{tier}-{az}` | `amatra-prod-private-us-west-2a` |
| Security Group | `amatra-{env}-{component}-sg` | `amatra-prod-lambda-sg` |
| Lambda Function | `amatra-{env}-{route-or-function-name}` | `amatra-prod-generate-solution` |
| DynamoDB Table | `amatra-{env}-{table-name}` | `amatra-prod-solution-state` |
| S3 Bucket | `amatra-{env}-artifacts-{account-id}` | `amatra-prod-artifacts-123456789012` |
| ECR Repository | `amatra/{env}/{agent-name}` | `amatra/prod/eo-validator` |
| Secrets Manager Secret | `amatra/{env}/{secret-name}` | `amatra/prod/github-pat` |
| CloudWatch Log Group | `/amatra/{env}/{function-name}` | `/amatra/prod/generate-solution` |
| Step Functions State Machine | `amatra-{env}-solution-generation` | `amatra-prod-solution-generation` |
| Cognito User Pool | `amatra-{env}-user-pool` | `amatra-prod-user-pool` |
| KMS Key Alias | `alias/amatra-{env}-{resource-type}` | `alias/amatra-prod-s3` |
| IAM Role | `amatra-{env}-{component}-execution-role` | `amatra-prod-lambda-generate-execution-role` |
| CodePipeline Pipeline | `amatra-{env}-platform-pipeline` | `amatra-prod-platform-pipeline` |

## Tagging Standards

All AWS resources are tagged with the following mandatory tags at creation time. Tags are enforced via an AWS Config rule (`required-tags`) that fires a CloudWatch alarm on any untagged resource. Terraform modules include the `default_tags` block applying all mandatory tags at the provider level.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Tag | Required | Example Values |
|-----|----------|----------------|
| Environment | Yes | `dev`, `staging`, `prod` |
| Application | Yes | `amatra-platform` |
| Owner | Yes | `amatra-engineering` (vendor during engagement), `predictif-operations` (post-handover) |
| CostCenter | Yes | `OPP-2026-001` (engagement cost code) |
| ManagedBy | Yes | `terraform` |
| DataClassification | Yes | `PREDICTif-Confidential` (all resources) |
| Project | Yes | `amatra-agentic-presales-platform` |
| CreatedDate | Yes | `2026-01-13` (ISO 8601) |

## Risk Register

The following risk register identifies the top risks to the engagement timeline, platform stability, and commercial commitments, with assigned likelihood, impact, and mitigation strategies. This register is maintained as a living document throughout the engagement.

<!-- TABLE_CONFIG: widths=[25, 15, 15, 45] -->
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Bedrock AgentCore Runtime not GA in us-west-2 by Week 5 | Low | Critical | AgentCore GA viability spike scheduled for Week 1; if not GA, fallback to Lambda-direct agent invocation pattern (fully designed, Terraform modules pre-built); timeline impact absorbed in Phase 2 buffer |
| Claude Sonnet 4.6 / Haiku 4.5 Bedrock quota insufficient for 200 solutions/month | Medium | High | Bedrock quota increase request raised with AWS in Week 1 (client IT lead action); quota approval tracked as a Phase 2 prerequisite; load testing uses quota monitoring to detect ceiling before go-live |
| eof-tools library unstable in containerised Linux environment | Medium | High | eof-tools stability assessment (all 30 modules) in Week 1 using Docker containerisation test harness; any unstable modules flagged to eof-tools SME for resolution in Weeks 2–4 before Phase 2 integration begins |
| CTO sign-off on Cognito User Pool delayed beyond Week 3 | Medium | High | CTO briefing scheduled for Week 2 (not Week 3) to provide one-week buffer; sign-off gate is a named dependency with a five-business-day escalation path per SOW |
| Per-solution Bedrock spend exceeds $5 target | Medium | Medium | Haiku 4.5 used for all EO Validator invocations (5× cost advantage); token usage instrumentation live from Phase 2 Week 7; daily spend alarm at 110% of budget triggers immediate investigation; retry cap (max 3) enforces cost ceiling |
| April 2026 executive demo deadline missed | Low | Critical | Fixed twelve-week schedule with three formal milestone gates (M2 Week 4, M4 Week 9, M7 Week 12); deferred scope list agreed in Phase 1 to protect critical path; weekly status reports to Sarah Lin with schedule risk flagging |
| DynamoDB quota table hot-partition throttling under concurrent load | Low | High | Quota_global uses a single-key conditional write pattern; on-demand capacity mode absorbs bursts; load test validates quota table behaviour at 10 concurrent generations; adaptive write pattern (exponential backoff) mitigates throttle events |
| GitHub PAT expiry causing artifact commit failures | Medium | Medium | 90-day automatic rotation via Secrets Manager Lambda rotation function; rotation tested in staging before go-live; CloudWatch alarm fires on commit failure (3 consecutive failures); rotation runbook delivered in Week 12 |
| Step Functions execution timeout on slow Bedrock responses | Low | Medium | Standard Workflow execution timeout set to 90 minutes (1.5× P99 SLA); per-task `HeartbeatSeconds` timeout for AgentCore invocations (15 minutes per agent); graceful timeout handling updates SolutionState to FAILED with user-visible error |
| eof-tools converter producing malformed DOCX/PPTX/XLSX output | Medium | Medium | Integration tests validate all 12 artifact-type converters in Phase 2 Week 7 before agent integration milestone; EO Validator format-check includes converter output schema validation; converter failures trigger retry loop |
| Cognito User Pool production activation blocked by CTO | Low | High | CTO sign-off obtained by Week 3 for design approval; production activation is a separate gate at T-24h in cutover sequence; staging environment fully functional as fallback for executive demo if production activation delayed |
| AWS account IAM permission scope too restrictive for platform provisioning | Medium | Medium | IAM permission boundary scope confirmed with Client IT Lead in Week 1 (SOW dependency); Terraform plan output reviewed with Client IT Lead in Week 2 to identify any permission gaps before Phase 1 deployment begins |

## Glossary

The following table defines key acronyms and technical terms used throughout this document and the broader engagement.

<!-- TABLE_CONFIG: widths=[25, 75] -->
| Term | Definition |
|------|------------|
| AgentCore Runtime | Amazon Bedrock AgentCore Runtime — AWS managed service for hosting and invoking containerised AI agents in a serverless execution environment |
| Strands Agents | Open-source multi-agent framework (Apache 2.0) for building agent graphs with inter-agent messaging contracts and tool invocation wrappers |
| EO Framework | Engagement Orchestration Framework — Amatra's proprietary methodology and schema standards governing the structure and content of presales and delivery artifacts |
| eof-tools | PREDICTif's existing internal Python library (~30 modules) that converts raw EO Framework markdown/CSV artifacts into Office-format documents (DOCX, PPTX, XLSX) |
| Solution Package | A complete set of twelve EO Framework artifacts (5 presales + 6 delivery + 1 Terraform IaC bundle) generated for a single client engagement |
| Brief | The client brief input file (`brief.txt`) submitted by a consultant to initiate a solution generation run; contains engagement metadata, client context, and solution parameters |
| JWT | JSON Web Token — the bearer token issued by Amazon Cognito and validated by the API Gateway JWT authoriser on every API request |
| PAT | Personal Access Token — the GitHub credential stored in AWS Secrets Manager used by the Code Generator agent to commit artifacts to the public GitHub repository |
| DLQ | Dead Letter Queue — the Amazon SQS queue that receives failed agent invocations and unresolvable EO Validator retry failures for operations team triage |
| PITR | Point-in-Time Recovery — Amazon DynamoDB's continuous backup feature providing a 35-day recovery window for all three platform DynamoDB tables |
| CMK | Customer-Managed Key — an AWS KMS key created and managed by the platform team (as opposed to AWS-managed keys), used for SSE-KMS encryption of S3 artifacts and CloudWatch Logs |
| CQRS | Command Query Responsibility Segregation — the architectural pattern separating artifact generation (write path) from artifact retrieval and status queries (read path) used in the data architecture design |
| RTO | Recovery Time Objective — the maximum acceptable time to restore the platform to operational status after a failure event; target is 4 hours |
| RPO | Recovery Point Objective — the maximum acceptable data loss measured in time; target is 24 hours for DynamoDB data and 0 hours for S3 artifacts |
| MAU | Monthly Active User — a Cognito metric counting distinct authenticated users who invoke the platform API or CLI within a calendar month |
| SSE-KMS | Server-Side Encryption with AWS Key Management Service — the encryption mechanism applied to all S3 objects and CloudWatch Logs in the platform |
| VPC Endpoint | An AWS PrivateLink endpoint that enables communication between Lambda functions in a private VPC subnet and AWS services without traversing the public internet |
| P95 / P99 | Percentile latency metrics — P95 means 95% of requests complete within the stated latency; P99 means 99% complete within the stated latency |
| WORM | Write Once Read Many — the object lock configuration applied to the CloudTrail audit S3 bucket, preventing log tampering or deletion for 365 days |
| SOC 2 TSC | SOC 2 Trust Services Criteria — the audit framework used to assess the platform's security, availability, and processing integrity controls |
| Graded Delivery | The Step Functions policy of delivering artifacts to S3 (and updating DynamoDB SolutionState) as each artifact is validated, rather than waiting for the complete 12-artifact bundle before committing any output |
