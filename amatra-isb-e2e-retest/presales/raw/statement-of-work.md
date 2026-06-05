---
document_title: Statement of Work
technology_provider: aws
project_name: AWS Agentic Pre-Sales Orchestration Platform
client_name: PREDICTif Solutions
client_contact: Marcus Patel | Director of Pre-Sales Engineering | marcus.patel@predictif.com
consulting_company: Amatra (EO Framework Practice)
consultant_contact: "[Consultant Name] | [consultant@amatra.com] | [Phone]"
opportunity_no: OPP-2026-001
document_date: June 2025
version: 1.0
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Statement of Work (SOW) defines the scope, deliverables, roles, and commercial terms for the design, development, and deployment of the **AWS Agentic Pre-Sales Orchestration Platform** for PREDICTif Solutions. This engagement will deliver a fully automated, serverless multi-agent platform built on AWS Bedrock AgentCore Runtime and the Strands Agents framework that replaces the current manual presales documentation workflow with an agentic engine capable of producing a complete twelve-artifact solution bundle — including presales documents, delivery guides, and a Terraform automation bundle — in under sixty minutes with no human in the loop.

The platform directly addresses PREDICTif's strategic imperative to scale its pre-sales engineering capacity. Today, each engagement consumes six to ten hours of senior-consultant time through manual Claude Code CLI iteration, ad-hoc validation cycles, and manual file management. By automating the entire workflow — from input validation through artifact generation, format checking, LLM quality validation, Office document conversion, and GitHub commit — the platform targets a 90% reduction in per-engagement effort, unlocking parallel pipeline throughput across the Amatra practice's ~120 consultants in the United States and Canada.

**Project Duration:** 12 weeks (Q2 2026, hard deadline end of April)

**Key Outcomes:**
- Serverless five-agent orchestration platform (Input Validator, Pre-Sales Generator, Delivery Generator, Code Generator, EO Validator) registered in AWS Bedrock AgentCore Runtime
- Pip-installable CLI with fourteen subcommands and a JWT-protected HTTP API with eleven Lambda routes behind API Gateway HTTP API v2
- Amazon Cognito User Pool authentication with per-user (10/month) and global (1,000/month) quota enforcement in DynamoDB
- Deterministic eof-tools converter pipeline producing DOCX, PPTX, and XLSX artifacts baked into the agent Docker image
- End-to-end Terraform Infrastructure-as-Code automation bundle with `terraform validate` syntax gate
- Green CloudWatch metrics baseline and GitHub PAT-based automated artifact commit pipeline

**Expected Benefits:**
- **90% effort reduction:** Per-engagement time drops from 6–10 hours to under 1 hour of senior-consultant involvement
- **Parallel pipeline throughput:** Agentic architecture enables simultaneous generation across multiple engagements
- **Quality consistency:** Deterministic format-check plus LLM quality validation with up to 3 retries per artifact eliminates ad-hoc drift
- **Cost efficiency:** Targeted at under $5 of model spend per solution; amortised infrastructure converges to under $0.50 per solution at 200 solutions/month steady state
- **Auditability:** Full CloudTrail and CloudWatch audit trail replacing the current zero-audit-trail OneDrive folder model

**Total 3-Year Investment:** ~$690,500 net (Professional Services + Infrastructure + Licenses + Support)

---

# Background & Objectives

Amatra is an internal practice within PREDICTif Solutions — a North American IT consulting firm with ~120 consultants across the United States and Canada specialising in managed services and pre-sales engineering for AWS partner solutions. Amatra produces EO Framework solution packages for customers, which define the technical architecture, delivery approach, and commercial investment for each proposed engagement.

## Current State

PREDICTif Solutions currently produces EO Framework solution packages entirely manually using the Claude Code CLI on consultant laptops. There is no centralised orchestration, no audit trail, no per-user identity management, and no automated retry on validation failure. Generated artifacts are stored in a private OneDrive folder and manually copied into customer engagement repositories. Key challenges include:

- **Manual effort and scale bottleneck:** Each presales package consumes six to ten hours of senior-consultant time through repeated LLM prompting, manual validation cycles, Python converter script execution, and file management — preventing the practice from scaling pipeline throughput proportionally with headcount.
- **No quality gates or retry automation:** Validation failures require the consultant to re-prompt Claude Code CLI manually, typically iterating three to four times before achieving a passing artifact. There is no deterministic format-check pass, no LLM quality gate, and no retry loop.
- **Zero centralised identity or access control:** There is no API, no per-user identity, and no quota enforcement. Any consultant can produce any number of packages without oversight. Procurement and audit cannot see usage or cost attribution.
- **Fragile artifact lifecycle:** Artifacts live in OneDrive with no versioning, no structured commit history, and no automated push to the customer engagement GitHub repository. Manual copy-paste introduces error and delays.
- **No observability or cost visibility:** There is no per-phase token usage tracking, no CloudWatch metrics, and no cost attribution by engagement or consultant, making it impossible to manage model spend or identify quality regressions.

## Business Objectives

The following strategic objectives define the outcomes this platform must achieve to be considered successful. Each objective is directly traceable to a pain point identified in the current-state assessment and carries measurable success criteria validated in Phase 3:

- **Automate end-to-end presales package generation:** Deliver a production-ready agentic platform that produces all twelve EO Framework artifacts per solution — five presales, six delivery, one Terraform automation bundle — without human intervention in the generation loop.
- **Reduce per-engagement effort by 90%:** Drive the senior-consultant time investment from 6–10 hours per package to under one hour (primarily review and approval), measured from pilot go-live.
- **Establish scalable multi-tenant identity and quota model:** Implement Amazon Cognito User Pools with JWT-authenticated CLI and API access, DynamoDB-backed atomic quota enforcement (10 solutions/user/month; 1,000 global/month), and an admin override endpoint for capacity management.
- **Deliver a pip-installable CLI and HTTP API:** Surface all platform capabilities through a developer-friendly CLI (14 subcommands) and a structured HTTP API (11 Lambda routes) so Amatra consultants can integrate the platform into their existing workflows without infrastructure expertise.
- **Achieve a hard Q2 2026 executive demonstration deadline:** Deliver a demonstrable platform to executive sponsor Sarah Lin (CRO) by end of April 2026, covering the four core capabilities: CLI auth, presales generation, delivery generation, and Terraform automation bundle.
- **Enable full observability and cost governance:** Surface per-phase token usage in the CLI status command and admin usage endpoint; establish a green CloudWatch metrics baseline with alerting and X-Ray tracing across all seventeen Lambda functions.

## Success Metrics

The following measurable criteria define project success and will be validated during Phase 3 testing before production go-live is approved. Each metric is assigned a specific target and a verification method:

- End-to-end artifact generation time ≤ 60 minutes for a full twelve-artifact solution bundle
- Per-engagement senior-consultant effort ≤ 1 hour (90% reduction from current 6–10 hours)
- Per-solution Bedrock model spend < $5 at 200 solutions/month steady-state throughput
- Artifact validation pass rate ≥ 95% on first attempt across all twelve artifact types
- API availability ≥ 99.5% measured monthly across all eleven Lambda routes
- Zero quota bypass incidents (per-user and global atomic quota enforcement in DynamoDB)
- Green CloudWatch metrics baseline (zero critical alarms) demonstrated in Phase 3 executive demo
- All twelve artifact types pass deterministic format-check AND LLM quality validation with ≤ 3 retries

---

# Scope of Work

This project will design, build, test, and deploy the AWS Agentic Pre-Sales Orchestration Platform on a fresh us-west-2 AWS footprint, isolated from PREDICTif's existing us-east-1 managed-services workloads. The platform integrates five Strands-based agents, Bedrock AgentCore Runtime, Cognito authentication, DynamoDB quota enforcement, the existing eof-tools converter library, and automated GitHub artifact delivery. The following details define the boundaries and activities of this engagement.

## In Scope

The following services and deliverables are included in this SOW:

- AWS foundation provisioning: VPC, IAM roles and least-privilege policies, S3 bucket policies, CloudTrail, KMS keys, and GuardDuty in us-west-2
- Amazon Cognito User Pool with JWT issuance, 30-day refresh tokens, post-confirmation trigger Lambda, and DynamoDB profile write
- API Gateway HTTP API v2 with eleven Lambda routes, JWT Cognito authoriser, CORS configuration, and request throttling
- Five-agent Strands multi-agent graph design and implementation: Input Validator (Agent 0), Pre-Sales Generator, Delivery Generator, Code Generator, and EO Validator
- Bedrock AgentCore Runtime agent registration with Claude Sonnet 4.6 (primary generation) and Claude Haiku 4.5 (cost-efficient validation) model bindings
- eof-tools converter library integration: ~30 Python modules for DOCX, PPTX, and XLSX conversion baked into the agent Docker image via Amazon ECR
- Per-artifact deterministic format-check plus LLM quality validation loop with up to 3 automatic retries per artifact across all twelve artifact types
- Graded artifact delivery policy surfacing partial results when a subset of artifacts pass validation
- Pip-installable CLI with fourteen subcommands including auth, generate, status (with per-phase token usage), and admin endpoints
- DynamoDB schema and atomic quota enforcement: per-user (10 solutions/month) and global (1,000 solutions/month) with admin override capability
- GitHub integration: PAT-based automated commit of generated artifacts to fixed public repository via Secrets Manager
- Terraform Infrastructure-as-Code modules for all platform infrastructure with `terraform validate` syntax gate in CI/CD pipeline
- CloudWatch dashboards, alarms, and per-phase token-usage metrics; X-Ray tracing on Lambda functions
- CI/CD pipeline (GitHub Actions or CodePipeline): Docker build, ECR push, Lambda deploy, and Terraform validate gate
- Operational runbooks, as-built documentation, and knowledge transfer training for the Amatra team
- Four-week hypercare support post go-live

### Scope Parameters

This engagement is sized as a **Medium complexity** implementation based on the following parameters:

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | Agent Count | 5 Strands agents per solution run |
| Solution Scope | Artifacts per Solution | 12 total (5 presales + 6 delivery + 1 Terraform automation bundle) |
| Solution Scope | Artifact Types | 12 distinct EO Framework artifact types with individual format-check and LLM quality validation |
| Integration | External System Integrations | 4 integrations: Bedrock AgentCore, Cognito, GitHub PAT, DynamoDB atomic quotas |
| User Base | Total Users | ~120 consultants (US and Canada); up to 3 roles (consultant, admin, read-only) |
| User Base | Monthly Solution Quota | 10 solutions/user/month; 1,000 solutions/month global pool |
| Technical Environment | Deployment Region | Single region: us-west-2 (new footprint, isolated from us-east-1) |
| Technical Environment | Lambda Functions | 17 total: 11 API routes + 5 agent triggers + 1 Cognito post-confirmation |
| Technical Environment | API Routes | 11 HTTP API v2 routes + 14 CLI subcommands |
| Data Volume | Bedrock Token Volume (Sonnet) | ~3M input + 1M output tokens/month at PoC volume (~50 solutions/month) |
| Data Volume | Artifact Storage | ~500 GB S3 (raw MD/CSV + converted DOCX/PPTX/XLSX + Terraform bundles) |
| Security & Compliance | Authentication | Amazon Cognito JWT with 30-day refresh tokens |
| Security & Compliance | CTO Sign-Off Gate | Required for Cognito user pool provisioning and production deployment |
| Performance | Environments | Development and Production (2 environments) |

*Note: Changes to these parameters — additional artifact types, multi-region deployment, additional agents, or user base growth beyond 200 users — may require scope adjustment and additional investment.*

## Out of Scope

The following items are explicitly excluded from this engagement. These items will not be delivered unless added via a signed Change Request:

- Development of net-new eof-tools converter modules (the existing ~30 modules are integrated as-is)
- Multi-region deployment or active-active redundancy (us-west-2 single-region only for PoC)
- Mobile application or browser-based UI (CLI and HTTP API only)
- Integration with PREDICTif's existing us-east-1 managed-services workloads or accounts
- SIEM/SOC integration beyond GuardDuty and Security Hub baseline
- Advanced Bedrock model routing or A/B model testing (single primary + single validator model)
- Custom artifact types beyond the twelve defined EO Framework artifact types
- Managed services operations post-hypercare (covered under a separate Managed Services Agreement)
- Migration of existing OneDrive artifacts to the new platform
- PCI-DSS, HIPAA, or FedRAMP compliance certification (SOC 2 readiness only)
- Phase 2 scope: multi-region HA, additional artifact types, advanced model routing

## Activities

### Phase 1 — Foundation & Identity (Weeks 1–4)

Phase 1 establishes the secure AWS foundation and identity layer upon which all subsequent agent workloads will be built. This phase delivers working Cognito authentication, the DynamoDB schema, API Gateway routes, and the core IAM/network baseline — providing early, demonstrable proof of a JWT-authenticated API call before AI complexity is introduced.

Key activities:
- Kickoff meeting with Sarah Lin, Marcus Patel, and Daniel Park; scope and success-criteria alignment
- Current-state assessment: document legacy CLI workflow, map eof-tools modules and twelve artifact types
- Requirements gathering for CLI subcommands, API routes, agent graph, quota model, and GitHub push
- AWS Cloud Readiness Assessment: define us-west-2 landing zone and blast-radius isolation strategy
- DynamoDB data and quota model design: partition key strategy for per-user and global atomic counters
- Design documentation: architecture diagrams, ADRs, and component specifications
- Provision VPC, subnets, S3 buckets, IAM roles (least-privilege), CloudTrail, and KMS keys
- Implement Amazon Cognito User Pool, app client, post-confirmation Lambda, and 30-day refresh token policy
- Implement API Gateway HTTP API v2: eleven Lambda routes, JWT Cognito authoriser, CORS, and throttling
- Implement DynamoDB tables (user profiles, solution state, quota counters, audit events)
- Deploy baseline CloudWatch dashboards and CloudTrail audit logging
- Security hardening: Secrets Manager for GitHub PAT, GuardDuty, and Security Hub enablement

**Deliverable:** Architecture Decision Record (ADR), AWS foundation operational with working JWT-authenticated API call, Cognito user pool live (pending CTO sign-off gate)

### Phase 2 — Agent Build & Integration (Weeks 5–9)

Phase 2 is the core build phase delivering the five-agent Strands graph, Bedrock AgentCore Runtime integration, eof-tools converter baking, and the full CLI. Each agent is shipped and tested incrementally to reduce integration risk. The Docker image pipeline is established with ECR and CI/CD gates.

Key activities:
- Design and implement five-agent Strands multi-agent graph with agent-to-agent message passing
- Register all five agents in Bedrock AgentCore Runtime; configure Claude Sonnet 4.6 and Haiku 4.5 model bindings
- Design and build Docker image build pipeline: bake eof-tools converters and Python dependencies into agent image; push to Amazon ECR
- Implement per-artifact deterministic format-check + LLM quality-check validation loop (up to 3 retries per artifact)
- Integrate ~30 eof-tools Python converter modules for DOCX, PPTX, and XLSX output across twelve artifact types
- Implement graded artifact delivery policy (surface partial results on subset pass)
- Build pip-installable CLI with fourteen subcommands including auth, generate, status (per-phase token usage), and admin
- Implement atomic quota enforcement logic in DynamoDB (per-user 10/month, global 1,000/month)
- Implement GitHub PAT push logic: commit generated artifacts to fixed public repository
- Author Terraform IaC modules for all platform infrastructure; implement `terraform validate` syntax gate in CI/CD
- Implement CI/CD pipeline (GitHub Actions or CodePipeline): Docker build, ECR push, Lambda deploy
- Implement CloudWatch per-phase token usage metrics and X-Ray tracing on Lambda functions

**Deliverable:** All five agents operational in AgentCore Runtime, full presales artifact bundle (five artifacts) generated end-to-end with CLI, Docker image pipeline green, quota enforcement verified

### Phase 3 — Validation & Go-Live (Weeks 10–12)

Phase 3 achieves end-to-end validation of all twelve artifact types, performance baselines at projected throughput, and the executive demonstration. All quality gates must be green before production go-live.

Key activities:
- Execute test plan: unit, integration, end-to-end, performance, security, and UAT testing
- Run full solution generation for all twelve artifacts; verify format-check pass and LLM quality-check pass
- Stress-test multi-agent retry logic (up to 3 retries per artifact); confirm no infinite-loop edge cases
- Load test API at projected 200 solutions/month; validate per-solution Bedrock token cost target < $5
- Security testing: JWT auth penetration, quota bypass scenarios, Secrets Manager PAT protection validation
- Validate green CloudWatch metrics baseline across all agents and Lambda functions
- Confirm `terraform validate` syntax gate passes for all IaC modules
- Coordinate UAT with Marcus Patel and Daniel Park; facilitate executive demo run for Sarah Lin
- CTO sign-off on production Cognito user pool
- Author operational runbooks for quota resets, agent failure recovery, Bedrock throttle handling, GitHub push failures
- Deliver knowledge transfer sessions (CLI/API and agent operations)
- Author as-built architecture diagrams, ADRs, and configuration inventory
- Project go-live and handover

**Deliverable:** All twelve artifacts validated end-to-end, green CloudWatch metrics baseline, executive demonstration delivered, production deployment complete, as-built documentation handed over

---

# Deliverables & Timeline

This engagement produces a comprehensive set of technical, documentation, and operational deliverables across the twelve-week programme. All deliverables are accepted by PREDICTif Solutions through Marcus Patel (Director of Pre-Sales Engineering) unless otherwise noted.

## Deliverables

The table below lists all formal deliverables, their type, target due date, and the accepting authority. Deliverable numbers are referenced in the payment milestone schedule in the Investment Summary section.

<!-- TABLE_CONFIG: widths=[5, 42, 14, 18, 21] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|-------------|------|----------|---------------|
| 1 | Architecture Decision Record (ADR) — Current State & Target Architecture | Document | Week 2 | Marcus Patel |
| 2 | AWS Landing Zone — VPC, IAM, S3, CloudTrail, KMS (us-west-2) | System | Week 3 | Daniel Park |
| 3 | Amazon Cognito User Pool (pending CTO sign-off) | System | Week 4 | CTO / Marcus Patel |
| 4 | API Gateway HTTP API v2 — 11 routes with JWT Cognito authoriser | System | Week 4 | Marcus Patel |
| 5 | DynamoDB Tables — user profiles, solution state, quota counters, audit events | System | Week 4 | Daniel Park |
| 6 | Phase 1 Completion Report | Document | Week 4 | Marcus Patel |
| 7 | Five-Agent Strands Graph Implementation (registered in AgentCore Runtime) | System | Week 7 | Marcus Patel |
| 8 | Bedrock AgentCore Runtime Registration — Claude Sonnet 4.6 + Haiku 4.5 bindings | System | Week 7 | Marcus Patel |
| 9 | Docker Image Pipeline — eof-tools baked agent image pushed to ECR | System | Week 7 | Daniel Park |
| 10 | Per-Artifact Validation Loop — format-check + LLM quality-check with 3-retry logic | System | Week 8 | Marcus Patel |
| 11 | CLI — pip-installable, 14 subcommands including auth, generate, status (token usage), admin | System | Week 9 | Marcus Patel |
| 12 | DynamoDB Quota Enforcement — atomic per-user and global counters with admin override | System | Week 9 | Daniel Park |
| 13 | GitHub Integration — PAT-based automated artifact commit pipeline | System | Week 9 | Marcus Patel |
| 14 | CI/CD Pipeline — Docker build, ECR push, Lambda deploy, terraform validate gate | System | Week 9 | Daniel Park |
| 15 | Terraform IaC Automation Bundle — all infrastructure modules with terraform validate gate | Document/System | Week 9 | Daniel Park |
| 16 | Test Plan — unit, integration, E2E, performance, security, UAT | Document | Week 10 | Marcus Patel |
| 17 | End-to-End Artifact Validation Report — all 12 artifact types | Document | Week 11 | Marcus Patel |
| 18 | Load Test Results — 200 solutions/month; per-solution model cost validation | Document | Week 11 | Daniel Park |
| 19 | Security Test Report — JWT auth, quota bypass, PAT protection | Document | Week 11 | Marcus Patel |
| 20 | CloudWatch Metrics Baseline Report — green metrics across all agents and Lambda | Document | Week 12 | Daniel Park |
| 21 | UAT Sign-Off & Executive Demonstration (Sarah Lin) | Project Milestone | Week 12 | Sarah Lin / CTO |
| 22 | Operational Runbooks — quota reset, agent failure, Bedrock throttle, GitHub push errors | Document | Week 12 | Daniel Park |
| 23 | Knowledge Transfer — CLI & API sessions (14 subcommands, 11 routes) | Training | Week 12 | Marcus Patel |
| 24 | Knowledge Transfer — Agent Operations (5-agent graph, token usage, quota management) | Training | Week 12 | Marcus Patel |
| 25 | As-Built Documentation — architecture diagrams, ADRs, configuration inventory | Document | Week 12 | Marcus Patel |
| 26 | Optimization Recommendations — Phase 2 scope candidates | Document | Week 12 | Marcus Patel |
| 27 | Project Closeout Report — retrospective and final invoice reconciliation | Document | Week 12 | Sarah Lin |

## Project Milestones

The following milestones mark completion of major phases and critical decision points throughout the engagement. Each milestone is a go/no-go gate for the subsequent phase and is reported in the weekly status update to Marcus Patel and Daniel Park.

<!-- TABLE_CONFIG: widths=[22, 53, 25] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 — Phase 1 Kickoff | Project start; stakeholder alignment; legacy workflow documented | Week 1 |
| M2 — Foundation Live | AWS us-west-2 foundation operational; CTO sign-off gate for Cognito initiated | Week 3 |
| M3 — Identity & API Ready | Cognito user pool live; JWT-authenticated API call demonstrable; DynamoDB schema deployed | Week 4 |
| M4 — First Agent Generating | Single Strands agent producing one artifact type end-to-end in AgentCore Runtime | Week 6 |
| M5 — Presales Bundle Automated | All five presales artifacts generated end-to-end via CLI with format-check passing | Week 9 |
| M6 — All 12 Artifacts Validated | Full twelve-artifact solution bundle validated; CloudWatch baseline green | Week 11 |
| Go-Live | Production deployment complete; CTO sign-off obtained; executive demo delivered to Sarah Lin | Week 12 |
| Hypercare End | Four-week hypercare support period concluded; platform ownership fully transferred | Week 16 |

---

# Roles & Responsibilities

Clear role definition and accountability are essential for the twelve-week delivery timeline of this engagement. The following RACI matrix and key personnel definitions govern how tasks are executed and decisions are made throughout the project. Every major work package has exactly one Accountable owner to ensure unambiguous decision authority.

## RACI Matrix

The RACI matrix below covers all major task categories across the three delivery phases. Each row assigns exactly one Accountable (A) owner and one or more Responsible (R) parties. Consulted (C) parties provide input before decisions are made; Informed (I) parties receive updates after decisions are made.

<!-- TABLE_CONFIG: widths=[28, 9, 10, 9, 8, 10, 9, 9, 8] -->
| Task / Deliverable | Vendor PM | Vendor Arch | Vendor Eng | Vendor QA | Client IT Lead | Client CTO | Marcus Patel | Sarah Lin |
|-------------------|-----------|-------------|------------|-----------|---------------|------------|--------------|-----------|
| Project Kickoff & Scope Alignment | A | R | I | I | C | I | R | C |
| Current-State Assessment & ADR | C | A | R | I | C | I | R | I |
| AWS Foundation Provisioning (us-west-2) | C | A | R | I | R | I | C | I |
| Cognito User Pool Provisioning | C | A | R | I | C | A | R | I |
| API Gateway & Lambda Route Implementation | C | C | A | I | I | I | R | I |
| DynamoDB Schema & Quota Enforcement | C | A | R | I | C | I | R | I |
| Strands Multi-Agent Graph Implementation | C | A | R | C | I | I | C | I |
| Bedrock AgentCore Runtime Registration | C | A | R | I | I | I | C | I |
| eof-tools Converter Integration | C | C | A | C | I | I | R | I |
| CLI Implementation (14 subcommands) | C | C | A | C | I | I | R | I |
| GitHub Integration (PAT commit pipeline) | C | C | A | I | C | I | R | I |
| Terraform IaC Automation Bundle | C | A | R | C | I | I | C | I |
| Security Hardening & GuardDuty Setup | C | A | R | C | R | C | C | I |
| CI/CD Pipeline Implementation | C | C | A | C | C | I | C | I |
| End-to-End Artifact Validation Testing | C | C | R | A | C | I | R | I |
| Load & Performance Testing | C | C | R | A | I | I | C | I |
| UAT Coordination & Executive Demo | A | C | C | C | C | C | R | R |
| CTO Sign-Off (Cognito / Production) | I | C | I | I | C | A | R | C |
| Runbook Authoring | C | R | R | C | C | I | A | I |
| Knowledge Transfer Delivery | A | R | R | I | C | I | R | I |
| As-Built Documentation | C | A | R | C | C | I | R | I |
| Project Go-Live Approval | A | C | I | C | C | A | R | R |
| Hypercare Support Management | A | C | R | I | R | I | C | I |

**Legend:** R = Responsible (does the work) | A = Accountable (owns the outcome) | C = Consulted (input required) | I = Informed (kept up to date)

## Key Personnel

**Vendor Team (Amatra / EO Framework Practice):**
- **Solution Architect:** Technical lead; owns architecture decisions, Bedrock AgentCore design, multi-agent graph, and ADR governance. Serves as primary escalation point for technical blockers.
- **ML/AI Engineer:** Specialised Bedrock and Strands framework expertise; leads AgentCore Runtime registration, Claude model binding configuration, and agent prompt engineering.
- **Solutions Engineer (Lead):** Owns Lambda function implementation, API Gateway configuration, CLI build, eof-tools integration, and quota enforcement logic.
- **DevOps Engineer:** Responsible for Docker image pipeline, ECR strategy, CI/CD pipeline, Terraform IaC authoring, and CloudWatch observability implementation.
- **Security Engineer:** Responsible for IAM least-privilege design, Secrets Manager configuration, GuardDuty/Security Hub enablement, and security testing.
- **QA Engineer:** Owns test plan development, end-to-end artifact validation, load testing, UAT coordination, and test results documentation.
- **Project Manager:** Owns programme governance, weekly status reporting, risk management, stakeholder communication, and milestone tracking.
- **Technical Writer:** Responsible for ADRs, design documentation, runbooks, knowledge transfer materials, and as-built documentation.

**Client Team (PREDICTif Solutions):**
- **Marcus Patel (Director of Pre-Sales Engineering):** Primary technical contact; approves architecture decisions; leads UAT; responsible for agent prompt refinement in Phase 2; owns requirements sign-off.
- **Daniel Park (Head of Delivery Operations):** Secondary stakeholder; accepts infrastructure and operational deliverables; validates runbook completeness; reviews Phase 2 scope backlog.
- **Sarah Lin (Chief Revenue Officer):** Executive sponsor and budget owner; receives go/no-go recommendations; co-signs executive demonstration milestone; approves Phase 2 engagement.
- **CTO (TBD):** Sign-off required on Cognito user pool provisioning and production deployment; approval is on the critical path for Phase 1 completion.
- **AWS Account Owner (TBD):** Provides us-west-2 account access, billing visibility, and assists with AWS Support and Bedrock quota pre-approval.
- **Procurement (as required):** Engaged if total platform spend exceeds PREDICTif's existing AWS spend envelope; required for GitHub Enterprise Cloud licensing.

---

# Architecture & Design

The AWS Agentic Pre-Sales Orchestration Platform is architected as a cloud-native, serverless solution on AWS in the us-west-2 region, designed for minimal operational overhead, linear cost scaling with solution volume, and strong isolation from PREDICTif's existing us-east-1 managed-services workloads. The platform's design philosophy is "validate first, generate at scale" — every artifact passes a deterministic format gate before being committed, eliminating the manual retry cycles that currently consume senior-consultant time.

## Architecture Overview

The platform is composed of four logical layers: an Identity and API layer (Amazon Cognito + API Gateway HTTP API v2), an Orchestration and Generation layer (Strands multi-agent graph + Bedrock AgentCore Runtime), a Data and Storage layer (DynamoDB + S3 + ECR), and an Observability and Delivery layer (CloudWatch + CloudTrail + GitHub). These layers interact through well-defined Lambda function boundaries, enabling each component to be tested, scaled, and replaced independently.

The five-agent Strands graph drives the core generation loop. Input Validator (Agent 0) validates the client brief and discovery inputs before any generation begins, preventing malformed inputs from propagating token cost into the generation pipeline. The Pre-Sales Generator, Delivery Generator, and Code Generator agents operate in parallel within their respective artifact domains, each invoking the eof-tools converter pipeline to produce DOCX, PPTX, and XLSX outputs. The EO Validator agent applies both deterministic format-check rules and LLM quality scoring, with up to three automatic retries per artifact, implementing a graded delivery policy that surfaces completed artifacts even when a subset requires additional iteration.

The architecture diagram below illustrates the full component topology, data flows, and integration points across the platform:

![Figure 1: Solution Architecture Diagram](../../assets/diagrams/architecture-diagram.png)

**Figure 1: AWS Agentic Pre-Sales Orchestration Platform** — End-to-end architecture showing the five-agent Strands graph on Bedrock AgentCore Runtime, API Gateway HTTP API v2, Cognito authentication, DynamoDB quota enforcement, S3 artifact storage, eof-tools converter pipeline (ECR), CloudWatch observability, and GitHub automated commit pipeline.

## Component Architecture

The platform's component architecture centres on the five Strands agents registered in AWS Bedrock AgentCore Runtime, each with a dedicated responsibility domain:

**Agent 0 — Input Validator:** Receives the client brief and discovery questionnaire as S3-keyed input. Validates required fields, checks completeness thresholds, and writes a structured validation report to DynamoDB before any generation agents are invoked. Acts as a hard gate: generation proceeds only on a clean validation pass.

**Pre-Sales Generator:** Produces the five presales artifacts (solution briefing, statement of work, discovery questionnaire, infrastructure costs CSV, level-of-effort estimate CSV) using Claude Sonnet 4.6 against EO Framework guidance files stored in S3. Each artifact invokes the eof-tools converter pipeline for DOCX/PPTX/XLSX output.

**Delivery Generator:** Produces the six delivery artifacts (implementation plan, runbook, architecture design document, test plan, change log, knowledge transfer guide) using the same Sonnet 4.6 + eof-tools pattern.

**Code Generator:** Produces the Terraform Infrastructure-as-Code automation bundle (the twelfth artifact), running `terraform validate` as a syntax gate before the artifact is accepted.

**EO Validator:** Applies deterministic format-check rules (structure, required sections, table shapes, YAML frontmatter) followed by LLM quality scoring using Claude Haiku 4.5. Implements the three-retry loop and graded artifact delivery policy. Writes per-artifact pass/fail and token-usage metrics to DynamoDB and CloudWatch.

The CLI (pip-installable, 14 subcommands) and the HTTP API (11 Lambda routes, API Gateway HTTP API v2) are the two surfaces through which Amatra consultants invoke the platform. The CLI wraps HTTP API calls and enriches the `status` subcommand with per-phase token-usage display sourced from DynamoDB.

## Network Design

The platform is deployed in a single AWS us-west-2 VPC. Lambda functions run in the VPC private subnets with outbound internet access via a NAT Gateway for Bedrock API calls, GitHub HTTPS push, and ECR image pull. All Lambda-to-DynamoDB and Lambda-to-S3 traffic routes through VPC Endpoints (Gateway type for S3 and DynamoDB, Interface type for Secrets Manager and CloudWatch Logs), ensuring traffic does not traverse the public internet. API Gateway HTTP API v2 is a regional endpoint accepting HTTPS-only traffic; all HTTP requests are rejected. No inbound VPC traffic is permitted beyond API Gateway. The us-west-2 footprint is isolated from us-east-1 via separate VPC and account-level blast-radius controls; there is no VPC peering or Transit Gateway between the regions.

## Security Design

Security architecture is built on the principle of least-privilege with defence-in-depth across the identity, compute, data, and network layers.

**Identity:** Amazon Cognito User Pool issues short-lived JWT access tokens (1-hour expiry) backed by 30-day refresh tokens. The API Gateway JWT authoriser validates every inbound request before Lambda invocation. User profiles are written to DynamoDB via a post-confirmation trigger Lambda, establishing per-user context for quota enforcement. Three roles are implemented: consultant (generate and view own solutions), admin (view all solutions, override quotas), and read-only (view only).

**Compute isolation:** Each Lambda function carries an individual IAM execution role scoped to the minimum permissions required for its function (e.g., the Cognito post-confirmation Lambda has DynamoDB PutItem on the users table only; the GitHub push Lambda has Secrets Manager GetSecretValue on the PAT secret only). No wildcard IAM actions or resource ARNs are permitted.

**Secrets management:** The GitHub Personal Access Token and any third-party credentials are stored in AWS Secrets Manager with automatic rotation enabled. Lambda functions retrieve secrets at runtime via the Secrets Manager SDK; no secrets are baked into container images or environment variables.

**Threat detection:** AWS GuardDuty is enabled across the us-west-2 account with findings routed to Security Hub. AWS Security Hub aggregates findings from GuardDuty, AWS Config, and Amazon Inspector for unified posture visibility. CloudTrail data events are enabled on the S3 artifact bucket for full API-level audit trail.

**Quota enforcement as a security control:** DynamoDB atomic counter logic prevents per-user (10/month) and global (1,000/month) quota exhaustion that could be exploited to drive unbounded Bedrock token spend. The admin override endpoint requires admin-role JWT and is rate-limited independently.

## Data Architecture

**Artifact storage:** All generated artifacts (raw Markdown/CSV, converted DOCX/PPTX/XLSX, Terraform bundles) are stored in a dedicated S3 bucket in us-west-2 with versioning enabled. Object keys follow a structured path: `{solution_id}/raw/`, `{solution_id}/converted/`, and `{solution_id}/automation/`. S3 bucket policies deny public access; all objects are encrypted at rest with SSE-S3 (KMS-CMK for production).

**DynamoDB tables:** Four tables serve the platform — `users` (profile and auth metadata, partition key: `user_id`), `solutions` (solution state, artifact status, and per-phase token usage, partition key: `solution_id`), `quotas` (per-user and global atomic counters, partition key: `user_id` / `GLOBAL`), and `audit_events` (immutable audit log of all API calls, TTL-based retention of 90 days).

**Data classification:** All artifacts are classified as PREDICTif Internal. No customer PII or regulated data is expected in the artifact content; the platform processes consultants' own work product. Data residency is us-west-2 only.

**Retention:** S3 artifacts are retained for 12 months in standard storage, then transitioned to S3 Glacier for 24 months before expiry. DynamoDB audit events are retained for 90 days via TTL. CloudWatch Logs are retained for 90 days (Lambda) and 365 days (CloudTrail).

**Backup:** DynamoDB point-in-time recovery (PITR) is enabled on all four tables with a 35-day recovery window. S3 Cross-Region Replication is out of scope for PoC but recommended in Phase 2 for DR.

## Operational Design

**Observability:** CloudWatch dashboards provide real-time visibility into Lambda invocation counts, error rates, duration percentiles (P50, P95, P99), and Bedrock token-usage metrics per phase. Per-phase token-usage data (input tokens, output tokens, estimated cost) is written to DynamoDB by the EO Validator agent and surfaced in the CLI `status` subcommand and the admin `/usage` API endpoint. AWS X-Ray traces are enabled on all seventeen Lambda functions, with service maps visualising agent-to-agent call chains.

**Alerting:** CloudWatch Alarms are configured for Lambda error rate > 1%, DynamoDB throttle events, Bedrock throttle responses, and quota counter approaching global limit (90% threshold). Alarms route to an SNS topic with email notifications to Daniel Park and the vendor operations team.

**Disaster recovery:** RTO target is 4 hours (Lambda and DynamoDB are serverless, inherently resilient; recovery involves restoring DynamoDB from PITR and redeploying Lambda via CI/CD). RPO target is 1 hour (DynamoDB PITR continuous backup; S3 versioning covers artifact history). DR runbooks are included in the handover package.

**Backup validation:** DynamoDB PITR restore test is executed as part of Phase 3 testing to validate the 4-hour RTO target.

## Tooling Overview

The table below summarises the primary tools and services used across all engagement workstreams, covering orchestration, compute, data, security, observability, and developer tooling. Full version and configuration details are captured in the as-built documentation.

<!-- TABLE_CONFIG: widths=[30, 35, 35] -->
| Category | Primary Tools | Purpose |
|----------|---------------|---------|
| Agent Orchestration | AWS Bedrock AgentCore Runtime, Strands Agents framework | Serverless hosting of five specialised agents; multi-agent graph execution |
| AI/ML Models | Claude Sonnet 4.6, Claude Haiku 4.5 | Primary artifact generation (Sonnet); cost-efficient validation (Haiku) |
| Compute | AWS Lambda (Python 3.12), Amazon ECR | Serverless function execution; container image registry for eof-tools image |
| API & Auth | API Gateway HTTP API v2, Amazon Cognito User Pools | JWT-protected REST API; user authentication and token issuance |
| Data Storage | Amazon DynamoDB (On-Demand), Amazon S3 | Quota enforcement, solution state, audit events; artifact object storage |
| Secrets Management | AWS Secrets Manager | GitHub PAT storage; runtime secret retrieval for Lambda functions |
| IaC & CI/CD | Terraform, GitHub Actions (or CodePipeline), `terraform validate` | Infrastructure provisioning; CI/CD pipeline with syntax validation gate |
| Observability | Amazon CloudWatch, AWS X-Ray, AWS CloudTrail | Dashboards, alarms, tracing, API-level audit trail |
| Security | AWS GuardDuty, AWS Security Hub, AWS Config | Threat detection; posture management; compliance findings aggregation |
| Artifact Conversion | eof-tools (~30 Python modules), python-docx, openpyxl, python-pptx | DOCX, PPTX, XLSX generation from raw Markdown/CSV artifacts |
| Source Control | GitHub (public repo, PAT commit pipeline) | Automated artifact delivery; version history per solution |
| CLI | pip-installable Python package (14 subcommands) | Consultant-facing interface for generation, status, auth, and admin |

---

# Security & Compliance

Security and compliance controls are embedded throughout the platform design to meet PREDICTif's internal security baseline and to support future SOC 2 Type II readiness. The following subsections define the security architecture, access controls, compliance posture, and governance model.

## Identity & Access Management

Amazon Cognito User Pools provides the authoritative identity layer for all consultant and administrator access to the platform. JWT access tokens (1-hour expiry) and 30-day refresh tokens are issued upon successful authentication and validated by the API Gateway JWT authoriser before any Lambda function is invoked. Token introspection is performed on every request — there are no API key bypass paths.

Three IAM roles are implemented within the application layer: **Consultant** (generate solutions within personal quota, view own artifact history), **Admin** (view all solutions, override quotas, access the `/admin/usage` endpoint), and **Read-Only** (view solution status and artifacts without generate capability). Role assignment is stored in the Cognito User Pool `custom:role` attribute and written to the DynamoDB `users` table at post-confirmation time.

All Lambda execution roles follow least-privilege design — each function's IAM role grants only the specific DynamoDB actions, S3 prefixes, and Secrets Manager ARNs required by that function. IAM Access Analyzer is enabled to continuously validate that no overly permissive policies are present. No cross-account IAM roles or organisation-level SCPs are required for the PoC footprint.

## Monitoring & Threat Detection

AWS GuardDuty is enabled in the us-west-2 account with a 30-day free trial transitioning to standard pricing. GuardDuty findings (anomalous API calls, credential exfiltration patterns, unusual Lambda invocation behaviour) are forwarded to AWS Security Hub. Security Hub aggregates findings from GuardDuty, AWS Config rules (e.g., S3 bucket public access, CloudTrail enabled), and Amazon Inspector vulnerability scans on the ECR container image.

CloudWatch Alarms monitor Lambda error rates, Bedrock throttle responses, DynamoDB throttle events, and quota counter thresholds. A CloudWatch Log Insights dashboard provides real-time security event visibility. AWS CloudTrail Management Events and S3 Data Events are enabled, with logs delivered to a dedicated S3 bucket with Object Lock (WORM) enabled to prevent tampering.

## Compliance & Auditing

The platform's audit trail is designed to support PREDICTif's internal audit and SOC 2 Type II readiness requirements:

- **CloudTrail:** Every API call to AWS services (Lambda invoke, DynamoDB read/write, S3 GetObject/PutObject, Secrets Manager GetSecretValue) is logged with requester identity, timestamp, source IP, and request parameters. Logs are stored in an S3 bucket with Object Lock and a 365-day retention policy.
- **DynamoDB `audit_events` table:** Application-level audit log capturing all platform API calls with user ID, action, solution ID, timestamp, and outcome (pass/fail). Retained for 90 days via TTL.
- **Per-phase token usage:** DynamoDB `solutions` table records input tokens, output tokens, and estimated Bedrock cost per agent per artifact, providing granular cost attribution for SOC 2 vendor risk management.
- **GitHub commit history:** Every artifact commit to the public GitHub repository is attributed to the platform's Secrets Manager PAT with a structured commit message including solution ID and artifact type, creating an immutable delivery audit trail.

Compliance frameworks in scope: SOC 2 Type II (internal readiness). PCI-DSS, HIPAA, and FedRAMP are out of scope for PoC; to be assessed in Phase 2 if required by PREDICTif's enterprise clients.

## Encryption & Key Management

All data at rest is encrypted using AWS-managed keys (SSE-S3 with KMS-CMK for the S3 artifact bucket in production). DynamoDB encryption at rest uses AWS-owned keys (default); KMS-CMK to be evaluated in Phase 2 based on data sensitivity requirements. All data in transit uses TLS 1.2+ enforced by API Gateway, Cognito, DynamoDB SDK, and S3 SDK; no HTTP endpoints are exposed. The GitHub PAT stored in Secrets Manager is encrypted with an AWS-managed KMS key; automatic rotation is enabled with a 90-day rotation period.

## Governance

A platform change management process is defined as follows: all infrastructure changes are applied via the Terraform IaC pipeline with peer review in GitHub and `terraform validate` + `terraform plan` output reviewed before `terraform apply`. No manual AWS Console changes are permitted in production (enforced via a restrictive IAM policy boundary on console access). Lambda function deployments are gated by the CI/CD pipeline's automated test suite.

Access reviews are conducted quarterly: Cognito user pool membership, IAM role assignments, and DynamoDB admin override grants are reviewed by Daniel Park. Inactive users (no API activity for 90 days) are suspended automatically via a scheduled Lambda function.

## Environments & Access

### Environment Strategy

<!-- TABLE_CONFIG: widths=[18, 28, 27, 27] -->
| Environment | Purpose | Access Control | Data |
|-------------|---------|----------------|------|
| Development | Agent development, eof-tools integration, unit and integration testing | Vendor engineering team only; Cognito dev user pool; no production data | Synthetic test briefs and generated artifacts only |
| Staging | End-to-end artifact validation, load testing, UAT, executive demo | Vendor team + Marcus Patel + Daniel Park; Cognito staging pool | Representative brief samples (non-customer PII) |
| Production | Live Amatra consultant platform; quota-enforced generation | All authenticated Amatra consultants (role-based); Cognito prod pool; CTO sign-off required | Real consultant work product; no customer PII |

### Access Policies

Production environment access requires a valid Cognito JWT issued to an Amatra-domain email address. Direct Lambda console access and DynamoDB console access in production are restricted to the Admin role only, gated by MFA. Vendor team access to the production environment is limited to the hypercare period (Weeks 13–16) and is fully revoked at hypercare conclusion. All access changes are logged in CloudTrail and the DynamoDB `audit_events` table.

---

# Testing & Validation

A comprehensive test strategy is executed across Phases 2 and 3, covering unit testing through executive UAT. All testing is coordinated by the Vendor QA Engineer with acceptance by Marcus Patel unless otherwise noted. The testing approach addresses all five agents, twelve artifact types, eleven API routes, and fourteen CLI subcommands.

## Functional Validation

Functional validation ensures that each of the twelve EO Framework artifact types is correctly generated and validated by the five-agent Strands graph. Test cases are defined for each artifact type covering: correct YAML frontmatter structure, required section headings in correct order, required table shapes, image references, and cross-reference consistency (e.g., cost figures in statement-of-work.md reconciling against infrastructure-costs.csv).

The EO Validator agent's format-check rules are tested against a library of known-good and known-bad artifact examples. Acceptance criteria: 100% of format-check rules pass on known-good inputs; 100% of known-bad inputs are correctly rejected with actionable error messages. The LLM quality-check (Haiku 4.5) is validated for false-positive and false-negative rates against a benchmark set of twenty artifacts per type.

## Performance & Load Testing

Load testing is executed in the staging environment at 200 solutions/month (approximately 10 concurrent generation requests at peak). Key performance acceptance criteria:
- End-to-end artifact generation time ≤ 60 minutes per twelve-artifact solution bundle
- Per-solution Bedrock model spend < $5 (Sonnet 4.6 + Haiku 4.5 combined)
- API Gateway P99 response latency ≤ 3 seconds for synchronous routes
- Zero Lambda cold-start-induced timeouts at peak load (provisioned concurrency evaluated if required)
- DynamoDB atomic quota operations complete in < 50ms P99

Load test results are documented in the Load Test Results Report (Deliverable 18) and presented to Daniel Park for acceptance.

## Security Testing

Security testing covers all threat vectors relevant to the platform's authentication, quota enforcement, and secrets management design:
- **JWT auth penetration:** Attempts to access API routes with expired, tampered, and unsigned tokens; validates all are rejected with 401
- **Quota bypass scenarios:** Attempts to exceed per-user (10/month) and global (1,000/month) quotas via race conditions and batch requests; validates atomic DynamoDB counters prevent bypass
- **Secrets Manager PAT protection:** Validates that the GitHub PAT is not exposed in Lambda logs, environment variables, or response payloads
- **IAM privilege escalation:** Reviews all Lambda execution roles for overly permissive policies using IAM Access Analyzer
- **S3 public access:** Validates S3 bucket public access block is enabled and no bucket ACLs grant public read/write
- **Container image scanning:** Amazon Inspector scan of ECR image for known CVEs; critical and high CVEs must be remediated before production go-live

Security test findings are documented in the Security Test Report (Deliverable 19) and reviewed by Marcus Patel.

## Disaster Recovery & Resilience Tests

Resilience testing validates that the platform can recover from component failures within the defined RTO/RPO targets. A DynamoDB PITR restore test is performed in staging to validate the 4-hour RTO target: delete a DynamoDB table, restore from PITR to a point-in-time 1 hour prior, validate data integrity of the restored table, and measure total elapsed time. Lambda function cold-start recovery is tested by scaling to zero instances and measuring time to first successful invocation. Bedrock throttle recovery is simulated by configuring a low quota limit and validating the platform's exponential backoff and retry behaviour.

## User Acceptance Testing

UAT is coordinated with Marcus Patel (primary) and Daniel Park (secondary) in Week 11, using representative client briefs provided by PREDICTif. The UAT session is facilitated by the Vendor Project Manager and observed by Sarah Lin as part of the executive demonstration. UAT scenarios include:
- Full presales bundle generation from a representative client brief using the CLI `generate` subcommand
- CLI `status` subcommand displaying per-phase token usage for a completed solution
- Admin quota override via the admin API endpoint
- Verification that all twelve artifacts are committed to the GitHub repository with correct commit messages
- Review of CloudWatch dashboard for solution generation observability
- Validation that a format-check failure triggers the retry loop and surfaces a corrected artifact

UAT sign-off by Marcus Patel is a mandatory gate for production go-live approval.

## Go-Live Readiness

The following readiness criteria must all be satisfied before production go-live is approved:

- [ ] All twelve artifact types pass format-check and LLM quality-check with ≤ 3 retries
- [ ] Load test passes at 200 solutions/month with per-solution model spend < $5
- [ ] Security test report reviewed; all critical and high findings remediated
- [ ] DynamoDB PITR restore test completed; 4-hour RTO validated
- [ ] CloudWatch green metrics baseline confirmed (zero critical alarms)
- [ ] CTO sign-off on Cognito user pool and production deployment obtained
- [ ] UAT sign-off by Marcus Patel obtained
- [ ] Executive demonstration delivered to Sarah Lin
- [ ] All twenty-seven deliverables accepted
- [ ] Operational runbooks completed and reviewed by Daniel Park
- [ ] Knowledge transfer sessions completed with Amatra team
- [ ] Hypercare support roster confirmed

## Cutover Plan

Production cutover is scheduled for Week 12 (hard deadline: end of April 2026). The cutover sequence is:

1. Freeze development and staging environments (no new deployments during cutover window)
2. Execute final Terraform plan; obtain peer review sign-off; apply to production
3. Validate Cognito user pool is live with CTO sign-off confirmed
4. Smoke-test all eleven API routes with production JWT tokens
5. Confirm DynamoDB quota counters are initialised to zero for all users
6. Execute end-to-end generation test in production with a synthetic client brief
7. Validate GitHub commit pipeline delivers artifacts to the production repository
8. Enable CloudWatch alarms and confirm SNS notifications are routing to Daniel Park
9. Communicate go-live to Amatra consultant team; CLI pip package published
10. Begin hypercare support period (Weeks 13–16)

Estimated cutover window: 4 hours. Cutover is scheduled during a low-usage period (early morning US Pacific time).

## Rollback Strategy

If critical issues are identified during or immediately after production cutover, the following rollback procedure is executed:

- **Trigger:** Lambda error rate > 5% sustained for 5 minutes; Bedrock API returning non-transient errors; DynamoDB quota counter corruption detected
- **Rollback procedure:** Redeploy previous Lambda function versions via the CI/CD pipeline (< 15 minutes); restore DynamoDB from PITR if data corruption detected (< 4 hours); Cognito user pool remains intact (no rollback required)
- **Communication:** Marcus Patel and Daniel Park notified immediately via SNS alarm; Sarah Lin notified if rollback extends beyond 2 hours
- **Rollback timeline:** Full rollback to last-known-good state targeted within 4 hours

---

# Handover & Support

## Handover Artifacts

The following artifacts are transferred to PREDICTif Solutions at project conclusion, ensuring the Amatra team can operate and extend the platform independently after hypercare:

- All twenty-seven formal deliverables listed in the Deliverables & Timeline section
- Complete Terraform IaC source code committed to PREDICTif's GitHub repository
- CLI Python package source code with pip packaging configuration
- Docker image source (Dockerfile, eof-tools integration, dependency manifests) committed to ECR-linked GitHub repository
- Strands agent graph configuration and prompt templates as version-controlled files in S3 and GitHub
- CloudWatch dashboard JSON definitions exportable for future customisation
- ADR library covering all major architecture decisions made during the engagement
- Phase 2 scope backlog document covering multi-region HA, additional artifact types, and advanced Bedrock model routing candidates

## Knowledge Transfer

Two structured knowledge transfer sessions are delivered in Week 12, designed to enable the Amatra team to operate the platform without vendor dependency from Day 1 of hypercare:

**Session 1 — CLI & API (4 hours):** Hands-on walkthrough of all fourteen CLI subcommands and eleven API routes with Amatra consultants. Covers: authentication flow, solution generation lifecycle, status monitoring with per-phase token usage, admin quota management, and GitHub artifact retrieval. Session is recorded and provided as a reference asset.

**Session 2 — Agent Operations (3 hours):** Technical deep-dive for Marcus Patel's team on monitoring the five-agent Strands graph in CloudWatch, interpreting per-phase token usage metrics, managing DynamoDB quotas, handling Bedrock throttle responses, and executing runbook procedures for common failure modes. Session is recorded and provided as a reference asset.

Both sessions are supported by written quick-reference cards included in the as-built documentation package.

## Hypercare Support

A four-week hypercare period (Weeks 13–16) is included in this engagement, providing dedicated post-go-live support for the Amatra platform. Hypercare scope and terms:

- **Duration:** Four calendar weeks from production go-live date
- **Coverage:** Business hours (9am–6pm US Pacific, Monday–Friday)
- **Response times:** P1 (platform down or quota enforcement broken) — 2-hour response; P2 (single artifact type failing validation) — 4-hour response; P3 (cosmetic or documentation issues) — next business day
- **Scope:** Bedrock quota issue resolution, agent failure triage and recovery, GitHub push failure remediation, CloudWatch alarm investigation, and Cognito user management assistance
- **Channel:** Dedicated Slack channel (#amatra-platform-hypercare) with vendor engineering team on-call
- **Out of scope during hypercare:** Net-new feature development, additional artifact types, multi-region changes (these require Phase 2 scope)

## Managed Services Transition

Ongoing managed services are not included in this engagement. Refer to a separate Managed Services Agreement if PREDICTif Solutions requires ongoing platform operations, monitoring, and SLA-backed support beyond the four-week hypercare period. The vendor team recommends a Phase 2 engagement assessment at Week 14 to evaluate managed services requirements and Phase 2 scope priorities.

## Assumptions

This engagement is premised on the following assumptions. If any assumption proves invalid, scope and timeline may require adjustment via a signed Change Request:

1. PREDICTif Solutions provides a dedicated AWS account in us-west-2 with sufficient Bedrock service quota pre-approved (AgentCore Runtime agents, Sonnet 4.6 and Haiku 4.5 token throughput) before Week 1
2. CTO sign-off on Cognito user pool provisioning is obtained no later than end of Week 3 to avoid blocking Phase 1 completion milestone
3. Marcus Patel or a designated deputy is available for weekly checkpoint meetings and artifact acceptance reviews throughout the twelve-week engagement
4. A GitHub repository (public or private, per PREDICTif's preference) and a GitHub Personal Access Token with repo write scope are provisioned by PREDICTif before Week 5 (Phase 2 start)
5. The existing eof-tools converter library (~30 Python modules) is provided to the vendor team in its current state before Phase 2 begins; no refactoring or bug-fixing of the eof-tools library is in scope
6. PREDICTif provides a minimum of five representative client briefs as test inputs for agent prompt tuning and UAT in Phase 2; briefs do not need to contain real customer data
7. Procurement review (if required due to spend envelope) is completed within the first two weeks of the engagement so that GitHub Enterprise Cloud licensing and AWS Bedrock quota increases are not on the critical path
8. AWS Bedrock AgentCore Runtime is generally available (not in preview with restricted access) in us-west-2 before the Phase 2 start date; if not, the vendor team will propose an alternative AgentCore hosting approach
9. The three-environment strategy (dev, staging, production) uses a single AWS account with environment-level resource naming and IAM boundaries; separate account provisioning is not required for PoC
10. PREDICTif's existing us-east-1 workloads will not be affected by or integrated with the new us-west-2 platform during this engagement
11. All Amatra consultants who will use the platform have corporate email addresses eligible for Cognito user pool registration; no SSO/SAML federation with an existing IdP is required for PoC
12. Budget approval for the engagement (within the $350k–$500k total envelope) is in place before Week 1 kickoff
13. The vendor team has read and write access to the EO Framework guidance S3 bucket and the solution artifact S3 bucket from Week 1

## Dependencies

The following dependencies are on the critical path for this engagement. Each has a named owner and a required-by date; delays to client-owned dependencies will be escalated to Sarah Lin within one business day of the slippage being identified.

| Dependency | Owner | Required By | Notes |
|------------|-------|-------------|-------|
| us-west-2 AWS account provisioned with Bedrock service quota approved | PREDICTif (AWS Account Owner) | Week 1 | Bedrock AgentCore Runtime quota pre-approval via AWS Solutions Architect recommended |
| CTO sign-off on Cognito User Pool | PREDICTif CTO | Week 3 | Critical path for Phase 1 milestone; must not slip beyond Week 3 |
| GitHub repository and PAT (repo write scope) provisioned | PREDICTif (Marcus Patel) | Week 5 | Required for Phase 2 GitHub integration work package |
| eof-tools converter library source code provided to vendor team | PREDICTif (Daniel Park) | Week 5 | Baked into Docker image during Phase 2; no refactoring in scope |
| Five representative client briefs provided for agent testing | PREDICTif (Marcus Patel) | Week 6 | Required for agent prompt tuning and UAT scenario construction |
| Procurement review completed (if spend > existing AWS envelope) | PREDICTif Procurement | Week 2 | GitHub Enterprise Cloud and Bedrock quota increases need procurement clearance |
| AWS Bedrock AgentCore Runtime GA in us-west-2 | AWS | Week 5 | Vendor team to validate API stability in Week 1 technical spike; contingency to be agreed if still in preview |

---

# Investment Summary

**Medium Implementation:** This pricing reflects a medium-complexity, twelve-week engagement delivering a five-agent agentic platform with twelve artifact types, Cognito authentication, DynamoDB quota enforcement, eof-tools converter integration, Terraform IaC, and four-week hypercare — scoped for ~120 consultants and a target of 200 solutions/month steady-state throughput.

## Total Investment

The investment figures below reconcile directly with the supporting artifacts: Professional Services figures are derived from the Level-of-Effort Estimate (level-of-effort-estimate.csv), summing 1,872 engineering hours plus management overhead at blended rates of $125–$275/hour; Cloud Infrastructure, Software Licenses, and Support & Maintenance figures are sourced from the Infrastructure Costs analysis (infrastructure-costs.csv) using the 3-Year Summary section. The 3-year infrastructure total from infrastructure-costs.csv is $258,025 ($222,925 cloud + $18,900 licenses + $16,200 support); Professional Services are a one-time Year 1 cost of $432,475 net after $20,000 in partner credits.

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[22, 14, 16, 14, 11, 11, 12] -->
| Cost Category | Year 1 List | Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------|------------|--------|--------|--------------|
| Professional Services | $452,475 | ($20,000) | $432,475 | $0 | $0 | $432,475 |
| Cloud Infrastructure | $64,427 | ($15,000) | $49,427 | $76,816 | $96,682 | $222,925 |
| Software Licenses | $6,300 | $0 | $6,300 | $6,300 | $6,300 | $18,900 |
| Support & Maintenance | $5,400 | $0 | $5,400 | $5,400 | $5,400 | $16,200 |
| **TOTAL INVESTMENT** | **$528,602** | **($35,000)** | **$493,602** | **$88,516** | **$108,382** | **$690,500** |
<!-- END COST_SUMMARY_TABLE -->

*Professional Services are a one-time Year 1 cost. Cloud Infrastructure grows at ~20% annually reflecting projected solution volume growth (50 → 200 solutions/month by Year 3). All figures are in USD.*

## Partner Credits

Two categories of credits are applied in Year 1, totalling **$35,000**:

**Professional Services Credits ($20,000 — applied to LOE Year 1):**
- **AWS Partner Services Credit ($10,000):** AWS Partner Network (APN) Advanced Tier credit applied to solution architecture and implementation services
- **AWS MAP Services Credit ($5,000):** AWS Migration Acceleration Program services credit applicable to new AWS footprint build-out in us-west-2
- **Volume Implementation Discount ($5,000):** 10% professional services volume discount reflecting strategic partnership and multi-phase opportunity

**Cloud Infrastructure Credits ($15,000 — applied to Year 1 AWS bill):**
- **AWS MAP Infrastructure Credit ($10,000):** AWS Migration Acceleration Program credit for new us-west-2 workload, available to AWS Partner Network (APN) members
- **Bedrock Proof-of-Concept Credit ($5,000):** AWS Bedrock PoC program credit for qualifying AI/ML workloads during the twelve-week build phase (Q2 2026)

All credits are applied in Year 1 only. Reserved capacity commitments for Bedrock and Lambda will be evaluated post-PoC at Phase 2 for Year 2 cost optimisation.

## Cost Components

**Professional Services ($452,475 list / $432,475 net):** Reflects 1,872 engineering hours across Discovery, Planning, Development, Testing, and Deployment phases, plus management overhead (10% of engineering hours for technical leadership and project management). Resource rates range from $125/hour (Technical Writer) to $275/hour (ML/AI Engineer specialising in Bedrock AgentCore). The largest single work package is Strands Agent Framework Integration (104 hours, $28,600) reflecting the central complexity of the multi-agent graph implementation.

**Cloud Infrastructure ($64,427 list Year 1 / $49,427 net Year 1):** The dominant cost components are Bedrock Claude Sonnet 4.6 ($3,000/month at PoC volume), Bedrock AgentCore Runtime ($1,500/month), and Bedrock Claude Haiku 4.5 ($600/month for validation). Remaining infrastructure (API Gateway, Lambda, DynamoDB, S3, Cognito, ECR, CloudWatch) totals approximately $285/month — confirming the serverless architecture's low fixed-cost footprint. Year 2 and Year 3 reflect 20% annual growth in solution volume. Full service-level breakdown is available in infrastructure-costs.csv.

**Software Licenses ($6,300/year):** GitHub Enterprise Cloud for 25 consultants ($21/user/month) providing repository access for the automated PAT-based artifact commit pipeline.

**Support & Maintenance ($5,400/year):** AWS Business Support Plan covering the full us-west-2 platform footprint including Bedrock AgentCore Runtime, required for production SLA coverage.

## Payment Terms

Professional Services fees are invoiced against the following milestone schedule:

| Milestone | Invoicing Event | % of PS Fees | Amount |
|-----------|----------------|-------------|--------|
| Contract Execution | Engagement commencement | 20% | $86,495 |
| Phase 1 Complete | AWS foundation live, Cognito + API ready (Week 4) | 25% | $108,119 |
| Phase 2 Complete | All five agents in AgentCore Runtime, CLI deployed (Week 9) | 35% | $151,366 |
| Project Go-Live | Executive demo delivered, production deployed (Week 12) | 15% | $64,871 |
| Hypercare Conclusion | Four-week hypercare period ended (Week 16) | 5% | $21,624 |
| **Total** | | **100%** | **$432,475** |

*Net amounts after $20,000 credits applied at contract execution.*

## Invoicing & Expenses

Invoices are issued within five business days of each milestone acceptance sign-off by Marcus Patel or Sarah Lin (as applicable per the deliverable acceptance authority table). Payment terms are Net 30 from invoice date. Cloud Infrastructure and Software License costs are invoiced monthly as incurred against PREDICTif's AWS account and GitHub subscription. Travel expenses (if required for on-site knowledge transfer sessions) are reimbursed at cost with supporting receipts; no travel is anticipated given the distributed delivery model. All expenses require pre-approval by Marcus Patel for amounts exceeding $500.

---

# Terms & Conditions

## General Terms

This Statement of Work is governed by and incorporated into the Master Services Agreement (MSA) executed between PREDICTif Solutions and the consulting company. In the event of any conflict between this SOW and the MSA, the MSA shall take precedence. All services are provided on a time-and-materials basis unless explicitly noted as fixed-fee. This SOW constitutes the complete scope agreement for the AWS Agentic Pre-Sales Orchestration Platform engagement.

## Scope Changes

Any change to the scope defined in this SOW — including additions to the artifact types, agent count, API routes, integration targets, compliance frameworks, or deployment regions — must be documented in a written Change Request (CR) agreed by both parties before work commences. Change Requests will include: description of the change, impact on timeline, impact on cost, and updated RACI entries if applicable. Minor clarifications that do not affect timeline or cost may be handled via email confirmation between Marcus Patel and the Vendor Project Manager. The vendor team will not commence out-of-scope work without a signed CR.

## Intellectual Property

PREDICTif Solutions retains full ownership of all deliverables produced under this SOW, including Terraform IaC modules, Lambda function source code, CLI source code, Strands agent graph configurations, generated artifacts, and all documentation. The consulting company retains ownership of its proprietary methodologies, frameworks (including the EO Framework), reusable templates, and pre-built Strands agent templates — none of which are exclusively assigned to PREDICTif. Open-source components used in the deliverables are subject to their respective licences (MIT, Apache 2.0 as applicable); no GPL-licensed components will be introduced without prior written approval.

## Service Levels

The vendor team commits to the following service levels during the engagement:
- Weekly status reports delivered every Friday by end of business
- Response to client questions within one business day
- Critical blockers (e.g., AWS account access issues, CTO sign-off delays) escalated within two business hours
- Hypercare support response times as defined in the Handover & Support section
- A ninety-day post-go-live warranty covering defects in deliverables traceable to errors in the vendor team's implementation (excluding issues caused by AWS service changes, client-side infrastructure changes, or out-of-scope items)

## Liability

Each party's total cumulative liability under this SOW shall not exceed the total professional services fees paid or payable under this SOW ($432,475 net). Neither party shall be liable for indirect, consequential, incidental, or punitive damages. The vendor team's liability for AWS infrastructure costs incurred due to platform defects is limited to the cost of remediation; the vendor team does not accept liability for Bedrock token overspend attributable to client-initiated generation volume exceeding the scoped 200 solutions/month throughput.

## Confidentiality

Both parties acknowledge that all information shared under this engagement — including client briefs, architecture designs, proprietary methodologies, commercial terms, and generated artifacts — is Confidential Information subject to the NDA provisions of the MSA. Generated artifacts containing client engagement details must not be shared beyond PREDICTif's internal team and the named client without client written consent. The GitHub repository used for artifact delivery shall be private unless PREDICTif explicitly requests public access.

## Termination

Either party may terminate this SOW for convenience with thirty (30) days written notice. In the event of termination, PREDICTif Solutions shall pay for all work completed and accepted up to the termination date at the applicable rates, plus reasonable wind-down costs incurred within the notice period. The vendor team shall deliver all work-in-progress artifacts, documentation, and source code to PREDICTif upon termination. Termination for cause (material breach not remedied within fifteen business days of written notice) entitles the non-breaching party to terminate immediately without payment of the convenience termination fee.

## Governing Law

This Statement of Work shall be governed by the laws of the State of Delaware, United States, without regard to conflict-of-law provisions. Any disputes arising under this SOW that cannot be resolved by the parties within thirty days shall be referred to binding arbitration under the American Arbitration Association Commercial Arbitration Rules.

---

# Sign-Off

By signing below, both parties confirm that they have read, understood, and agreed to the scope, approach, technical architecture, commercial terms, and all conditions outlined in this Statement of Work. This document, together with the executed Master Services Agreement, constitutes the binding agreement for the AWS Agentic Pre-Sales Orchestration Platform engagement.

**Client Authorized Signatory (PREDICTif Solutions):**

Name: __________________________
Title: __________________________
Signature: ______________________
Date: __________________________

**Executive Sponsor:**
Sarah Lin, Chief Revenue Officer
PREDICTif Solutions

&nbsp;

**Service Provider Authorized Signatory:**

Name: __________________________
Title: __________________________
Signature: ______________________
Date: __________________________

&nbsp;

---

*This Statement of Work constitutes the complete agreement between the parties for the services described herein and supersedes all prior negotiations, representations, or agreements relating to the subject matter. Version 1.0 — June 2025.*
