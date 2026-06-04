---
document_title: Statement of Work
technology_provider: aws
project_name: Amatra Agentic Orchestration Platform
client_name: PREDICTif Solutions
client_contact: Marcus Patel | Director of Pre-Sales Engineering | marcus.patel@predictif.com
consulting_company: Amatra (EO Framework Division)
consultant_contact: Marcus Patel | marcus.patel@predictif.com | +1 (555) 000-0001
opportunity_no: OPP-2026-001
document_date: June 2025
version: 1.0
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Statement of Work (SOW) defines the scope, deliverables, roles, responsibilities, and commercial terms for the design and delivery of the **Amatra Agentic Orchestration Platform** for PREDICTif Solutions. This engagement will deliver a production-ready, serverless agentic automation engine on AWS that transforms the company's EO Framework pre-sales delivery process — reducing per-engagement effort by 90%, from six to ten hours of senior-consultant time to under one hour, and unlocking parallel pipeline throughput across PREDICTif's 120-consultant sales organisation.

The platform will be built on AWS Bedrock AgentCore Runtime using the Strands Agents framework and Claude Sonnet 4.6 as the primary generation model, with Claude Haiku 4.5 for cost-efficient validation. It exposes a pip-installable CLI with fourteen subcommands and a JWT-protected HTTP API with eleven Lambda routes behind API Gateway HTTP API v2, secured by Amazon Cognito User Pools. Five coordinated agents — Input Validator, Pre-Sales Generator, Delivery Generator, Code Generator, and EO Validator — produce twelve total artifacts per solution engagement (five presales, six delivery, one Terraform automation bundle) following strict EO Framework quality standards.

**Project Duration:** 12 weeks (Q2 2026 — hard deadline end of April 2026 for executive demonstration)

**Key Outcomes:**
- Five-agent Strands multi-agent graph registered on Bedrock AgentCore Runtime, producing all twelve artifact types end-to-end with no human in the loop
- Pip-installable CLI with fourteen subcommands and a JWT-protected REST API with eleven Lambda routes behind API Gateway HTTP API v2
- Amazon Cognito User Pools authentication with thirty-day refresh tokens and per-user quota enforcement (ten solutions/month) in DynamoDB
- Deterministic format-check plus LLM quality gate with up to three retries per artifact, ensuring a 95%+ validation pass rate
- Green CloudWatch metrics baseline with per-phase token usage surfaced in both the CLI status command and the admin usage endpoint
- Terraform IaC automation bundle with `terraform validate` syntax gate for the five core AWS services

**Expected Benefits:**
- **90% reduction in per-engagement effort** — senior-consultant time drops from six to ten hours to under one hour per presales bundle
- **Parallel pipeline throughput** — the platform supports up to 200 solutions per month at under $5 model spend per solution, removing the sequential bottleneck that limits deal velocity today
- **Audit trail and quota governance** — full DynamoDB-backed per-user and global quota enforcement with CloudTrail audit eliminates uncontrolled AI spend
- **Accelerated time-to-revenue** — complete presales bundles available in under 60 minutes from brief submission, enabling same-day proposal response to new opportunities
- **Operational scalability** — serverless architecture scales linearly with solution volume; amortised platform cost converges to under $0.50 per solution at 200 solutions/month steady state

The total three-year investment for this engagement is approximately **$375,386**, consisting of Year 1 combined professional services and infrastructure net investment of approximately **$284,308** (after $25,000 in PS partner credits and $5,000 in AWS infrastructure credits), plus Year 2 and Year 3 recurring infrastructure and support costs.

---

# Background & Objectives

PREDICTif Solutions is a North American IT consulting firm specialising in managed services and pre-sales engineering for AWS partner solutions, with approximately 120 consultants distributed across the United States and Canada. The company operates an internal team called Amatra that produces customer-facing pre-sales and delivery documentation following the proprietary EO Framework standard. Despite the quality of their output, the production process is entirely manual, creating a significant constraint on the organisation's growth.

## Current State

Amatra consultants currently produce EO Framework solution packages by running the generation process on local laptops using the Claude Code CLI, with no centralised orchestration, audit trail, or quota enforcement. Each engagement requires a senior consultant to manually feed guidance files into an LLM, iterate three to four times on validation failures, run Python converter scripts to produce Office documents, and manually push results to GitHub. Key challenges include:

- **Excessive Per-Engagement Effort:** Each presales bundle consumes six to ten hours of senior-consultant time — the highest-cost resource in the organisation — limiting the number of concurrent deals the team can support.
- **No Parallel Throughput:** Because the process is entirely sequential and manual, the team cannot process multiple engagements simultaneously, creating a bottleneck during peak pipeline periods.
- **Validation Failures and Rework:** Without automated format-check or LLM quality gates, consultants discover validation issues only after generating a draft, forcing three to four rework cycles per engagement before artifacts meet the EO Framework standard.
- **No Centralised Identity or Quota Control:** There is no per-user identity, no quota enforcement, and no audit trail for AI usage. Generated artifacts are stored in a private OneDrive folder and manually copied into customer engagement repositories, with no version control or access governance.
- **Fragile and Non-Repeatable Process:** The legacy workflow depends on individual consultant expertise and access to the Claude Code CLI. There is no API, no automation, and no mechanism to enforce consistent standards across engagements.

## Business Objectives

The Amatra Agentic Orchestration Platform is designed to achieve the following strategic objectives for PREDICTif Solutions:

- **Automate End-to-End Presales Delivery:** Build a fully agentic pipeline that accepts a client brief as input and produces a complete, validated, publication-ready presales bundle in under one hour with no human in the loop.
- **Reduce Per-Engagement Effort by 90%:** Replace the six-to-ten-hour manual process with a sub-one-hour automated workflow, freeing senior consultants for higher-value client-facing activities.
- **Unlock Parallel Pipeline Throughput:** Design the platform to support 200+ solutions per month concurrently, removing the sequential constraint that limits the sales organisation's deal velocity.
- **Establish Centralised Identity, Governance, and Audit:** Implement Cognito JWT authentication, DynamoDB quota enforcement, and CloudTrail audit to provide full visibility and control over AI usage and expenditure.
- **Prove the Architecture by the Q2 2026 Deadline:** Deliver a demonstrable proof-of-concept — covering all four core capabilities (CLI auth, presales generation, delivery generation, Terraform automation bundle) — in time for the executive demonstration to Sarah Lin, Chief Revenue Officer, by end of April 2026.
- **Establish a Scalable Foundation for Phase 2:** Design the platform's infrastructure and agent architecture to accommodate future expansion — including multi-region deployment, additional artifact types, and increased solution throughput — without requiring a rearchitecture.

## Success Metrics

The engagement will be considered successful when the following measurable criteria are met:

- End-to-end presales bundle (five artifacts) generated in under 60 minutes from brief submission, verified across five representative test cases
- 95% or greater artifact validation pass rate across all twelve artifact types on the first or second LLM attempt (within the three-retry budget)
- All fourteen CLI subcommands operational and pip-installable, with JWT authentication tested end-to-end against the Cognito User Pool
- All eleven Lambda routes responding correctly to authenticated API requests via API Gateway HTTP API v2
- Per-user monthly quota enforcement validated under concurrent load — no user exceeds ten solutions per month; global pool does not exceed 1,000 solutions per month
- Green CloudWatch metrics baseline established with per-phase token usage visible in both CLI `status` command and admin usage endpoint
- `terraform validate` passes on all Terraform IaC output from the Code Generator agent for the five core AWS services
- CTO sign-off obtained on the Cognito-based user pool prior to production deployment
- Executive demonstration delivered to Sarah Lin (CRO) by end of April 2026

---

# Scope of Work

This engagement covers the complete design, build, testing, and deployment of the Amatra Agentic Orchestration Platform on AWS in the us-west-2 region — from initial discovery and architecture design through to a fully operational production system with runbooks, training, and four weeks of hypercare support. The work is structured into five phases spanning twelve weeks and encompasses all platform infrastructure, agent development, CLI tooling, API routes, eof-tools integration, observability, security hardening, and production handover.

The following table defines the key parameters that bound the scope of this engagement:

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | Agents per Solution | 5 agents (Input Validator, Pre-Sales Generator, Delivery Generator, Code Generator, EO Validator) |
| Solution Scope | Artifacts per Solution | 12 total (5 presales + 6 delivery + 1 Terraform automation bundle) |
| Solution Scope | CLI Subcommands | 14 subcommands, pip-installable |
| API & Integration | Lambda Routes | 11 JWT-protected routes via API Gateway HTTP API v2 |
| API & Integration | External Integrations | 3 (GitHub PAT commit, DynamoDB quota enforcement, eof-tools converter pipeline) |
| User Base | Consultant MAUs | ~120 MAUs; per-user quota 10 solutions/month |
| User Base | Global Quota | 1,000 solutions/month enforced atomically in DynamoDB |
| Technical Environment | Deployment Region | Single region: us-west-2 (greenfield, isolated from us-east-1 workloads) |
| Technical Environment | Environments | 3 (dev, staging, prod) |
| AI & Model | Primary Generation Model | Claude Sonnet 4.6 (Bedrock) |
| AI & Model | Validation Model | Claude Haiku 4.5 (Bedrock) |
| Security & Compliance | Authentication | Amazon Cognito User Pools with 30-day refresh tokens |
| Security & Compliance | Validation Retries | Deterministic format-check + LLM quality check, up to 3 retries per artifact |
| Performance | End-to-End Latency Target | Under 60 minutes per solution (full 12-artifact bundle) |

*Note: Changes to these parameters — including additional artifact types, additional agents, new regions, or increased quota limits — may require a scope adjustment and additional investment via change control.*

## In Scope

The following services and deliverables are included in this SOW:

- Design and provisioning of all AWS foundation infrastructure in us-west-2: Cognito User Pool, API Gateway HTTP API v2, Lambda functions, DynamoDB tables, S3 buckets, IAM roles and policies, Secrets Manager, CloudWatch, and ECR
- Development of all five Strands agents (Input Validator, Pre-Sales Generator, Delivery Generator, Code Generator, EO Validator) and registration with Bedrock AgentCore Runtime
- Docker image pipeline for eof-tools integration — multi-stage Dockerfile, ECR push workflow, and AgentCore Runtime image registration
- Integration of the eof-tools converter library (~30 Python modules covering 12 artifact types) into the agent container image; validation across all 12 artifact types (DOCX, PPTX, XLSX)
- Development of the pip-installable CLI with 14 subcommands, JWT token handling, and end-to-end Cognito authentication flow
- Development of all 11 JWT-protected Lambda route handlers with request validation, error handling, and throttling
- DynamoDB atomic quota enforcement — per-user (10/month) and global (1,000/month) counter management with conditional writes
- GitHub PAT-based artifact commit workflow to the fixed public repository
- CloudWatch observability implementation — per-phase token usage metrics, structured log groups, dashboards, and quota alarm notifications
- Security hardening — Secrets Manager for GitHub PAT and API keys, WAF rules on API Gateway, CloudTrail audit, DynamoDB KMS encryption, Cognito MFA option
- Code Generator agent producing Terraform IaC for five core AWS services with `terraform validate` gate
- Comprehensive testing across all five phases: unit tests, integration tests (12 artifact types), API route tests, quota contention tests, security tests, and UAT with Marcus Patel's team
- Production deployment via Terraform with CTO sign-off gate
- Operational runbooks, as-built documentation, API reference, CLI command reference, and user onboarding guide
- Knowledge transfer sessions for the Pre-Sales Engineering team (Marcus Patel) and Delivery Operations team (Daniel Park)
- Four weeks of post-go-live hypercare support

## Out of Scope

The following items are explicitly excluded from this engagement and would require a separate SOW or change control:

- Rewriting or refactoring the eof-tools converter library; the existing ~30 Python modules are baked into the container image as-is
- Multi-region deployment or global availability zones beyond us-west-2; the proof-of-concept footprint is single-region by design
- Migration of existing OneDrive artifact storage to S3; historical artifacts are not in scope
- Additional artifact types beyond the current 12 (5 presales + 6 delivery + 1 automation bundle); new types require a Phase 2 engagement
- Custom branded PPTX/DOCX templates beyond the existing EO Framework eof-tools brand assets
- Integration with third-party CRM or PSA platforms (e.g., Salesforce, ConnectWise); the GitHub commit pipeline is the only external integration in scope
- Day-2 managed operations, 24x7 NOC coverage, or SLA-backed incident response beyond the four-week hypercare period
- SOC 2 Type II audit preparation, penetration testing, or formal compliance certification
- Mobile application or browser-based UI; the platform surface area is CLI and REST API only
- Procurement of additional AWS service limit increases or quota raises beyond the us-west-2 baseline; the client is responsible for requesting limit increases through the AWS console

## Activities

### Phase 1 — Foundation & Security (Weeks 1–4)

This phase establishes the secure, authenticated infrastructure foundation that all subsequent agent and API work builds upon. By the end of Phase 1, PREDICTif will have a fully operational Cognito authentication flow, a functional API Gateway scaffold, and the DynamoDB schema required for per-user quota enforcement — giving the delivery team a proven identity and data layer before any AI model spend begins.

Key activities:
- Kickoff meeting with Sarah Lin, Marcus Patel, and Daniel Park to align on scope, objectives, timeline, and CTO sign-off requirements
- Current state assessment: document the legacy Claude Code CLI workflow and map all ~30 eof-tools library modules across the 12 artifact types
- Requirements gathering: finalise specifications for 14 CLI subcommands, 11 API routes, 5-agent architecture, Cognito settings, and quota schema
- Cloud readiness assessment: review existing us-east-1 footprint, plan us-west-2 greenfield provisioning, and assess Bedrock and AgentCore service limits
- Detailed architecture design: multi-agent Strands graph topology, inter-agent messaging, graded artifact delivery policy, per-phase token tracking, and retry logic — CTO sign-off required
- AWS foundation provisioning via Terraform: Cognito User Pool, DynamoDB tables (user profiles + quota counters), S3 buckets, IAM roles, API Gateway HTTP API v2 scaffold
- Cognito post-confirmation Lambda development: trigger fires on user registration, writes profile to DynamoDB, and seeds the quota counter
- DynamoDB atomic quota enforcement: implement per-user (10/month) and global (1,000/month) conditional write logic with overflow error surfacing

**Deliverable:** Phase 1 Assessment & Architecture Report (covering current state, architecture design, and risk register) and a live Cognito-authenticated API Gateway endpoint with DynamoDB quota schema deployed in us-west-2.

### Phase 2 — Agent Build & Integration (Weeks 5–9)

This phase delivers the five Strands agents, the Docker image pipeline with eof-tools integration, and the complete CLI and Lambda route surface. Each agent is developed and validated independently before wiring into the full multi-agent graph, de-risking the Phase 3 end-to-end validation sprint. The eof-tools integration is treated as a critical path item — the converter library is baked into the agent container image rather than rewritten.

Key activities:
- Input Validator Agent (Agent 0): brief parsing, schema validation, and error surfacing with Strands framework wiring
- Pre-Sales Generator Agent: five-artifact workflow (solution briefing, infra costs, LOE, SoW, proposal) with Sonnet 4.6 prompting and format-check integration
- Delivery Generator Agent: six-artifact workflow (project charter, implementation plan, RAID log, runbooks, test plan, closure report)
- Code Generator Agent: Terraform IaC templates for five core AWS services, `terraform validate` gate, output bundled as automation artifact
- EO Validator Agent: deterministic format-check pass, Haiku 4.5 LLM quality check, up to three retries per artifact, pass/fail envelope
- Multi-stage Dockerfile for eof-tools integration, ECR push workflow, AgentCore Runtime image registration, and image versioning strategy
- CLI development — 14 subcommands covering `auth login/logout`, `solution generate`, `solution status`, `artifact download`, and `admin usage` with JWT token handling
- All 11 JWT-protected Lambda route handlers: solution create/status/artifact-fetch, user profile, quota check, admin usage; request validation and error handling
- GitHub PAT-based commit workflow: solution artifact bundle committed to the fixed public repository on successful generation
- CloudWatch observability: per-phase token usage metrics, structured log groups, dashboards, and quota alarm thresholds
- Security hardening: Secrets Manager for GitHub PAT and Cognito client secrets, WAF rules on API Gateway, CloudTrail audit, DynamoDB KMS encryption

**Deliverable:** All five agents registered on AgentCore Runtime, Docker image published to ECR, pip-installable CLI passing local integration tests, all 11 Lambda routes responding to authenticated requests, and a GitHub commit test confirming the artifact pipeline end-to-end.

### Phase 3 — Validation & Go-Live (Weeks 10–12)

This phase executes comprehensive end-to-end validation across all twelve artifact types, establishes the green CloudWatch metrics baseline required for Phase 3 sign-off, coordinates UAT with Marcus Patel's team, and delivers the production system with full documentation and operational handover. The April 2026 executive demonstration to Sarah Lin is the hard deadline for this phase.

Key activities:
- Test plan development covering agent workflows, CLI commands, API routes, quota enforcement, converter pipeline, and Terraform validation
- Unit testing for all five agent modules (mock Bedrock calls, input/output schema validation, retry logic coverage)
- End-to-end integration testing: generate all 12 artifact types, validate format-check pass, LLM quality check, and converter pipeline output (DOCX/PPTX/XLSX)
- API route testing: all 11 Lambda routes via CLI and HTTP client, JWT auth validation, error response codes, and rate limiting
- Performance and quota testing: concurrent solution submissions, atomic DynamoDB write contention, and per-solution latency measurement (target under 60 minutes)
- Security testing: JWT bypass attempts, WAF rule verification, IAM privilege escalation checks, and Secrets Manager access control validation
- CloudWatch baseline validation: green metrics confirmed; per-phase token usage visible in CLI `status` command and admin usage endpoint — gate for Phase 3 completion
- UAT coordination with Marcus Patel (Pre-Sales Engineering): representative presales bundle generation reviewed with Sarah Lin (CRO)
- Production deployment via Terraform to us-west-2 with CTO sign-off obtained pre-deployment
- CLI package published to internal or public PyPI with versioning and changelog documentation
- Knowledge transfer sessions for Marcus Patel's Pre-Sales Engineering team and Daniel Park's Delivery Operations team
- Full documentation delivery: as-built architecture, API reference, CLI command reference, operator guide, and user onboarding guide
- Four-week hypercare support commencing immediately post-go-live
- Project closeout: retrospective with Sarah Lin, Marcus Patel, and Daniel Park; 90% effort-reduction metric validation; formal acceptance

**Deliverable:** Production platform live in us-west-2, all 12 artifact types validated, green CloudWatch baseline confirmed, executive demonstration delivered, all documentation and runbooks transferred, and formal acceptance sign-off obtained.

---

# Deliverables & Timeline

The Amatra Agentic Orchestration Platform engagement produces twenty-six formal deliverables across three phases, spanning Weeks 1 through 16 (including the four-week hypercare period). Each deliverable has an assigned type, target completion week, and named acceptance authority. Acceptance is formally acknowledged by the named client role signing the deliverable acceptance form or providing written approval via email within five business days of delivery.

## Deliverables

The table below lists all twenty-six deliverables in sequence, covering documents, deployed systems, training sessions, and the formal project acceptance artefact.

<!-- TABLE_CONFIG: widths=[5, 42, 13, 20, 20] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|-------------|------|----------|---------------|
| 1 | Kickoff Meeting Minutes & Scope Confirmation | Document | Week 1 | Marcus Patel |
| 2 | Current State Assessment Report (eof-tools module map, legacy workflow documentation) | Document | Week 2 | Marcus Patel |
| 3 | Cloud Readiness & AI/ML Capability Assessment | Document | Week 2 | Marcus Patel |
| 4 | Detailed Architecture Design (multi-agent graph, Cognito/API GW/DynamoDB design, container pipeline) | Document | Week 3 | CTO / Marcus Patel |
| 5 | Risk Register & Phased Delivery Plan | Document | Week 3 | Daniel Park |
| 6 | AWS Foundation Infrastructure (Cognito, DynamoDB, S3, IAM, API GW scaffold) — deployed via Terraform | System | Week 4 | Marcus Patel |
| 7 | Cognito Post-Confirmation Lambda & DynamoDB Quota Schema | System | Week 4 | Marcus Patel |
| 8 | Input Validator Agent (Agent 0) — unit tested | System | Week 5 | Marcus Patel |
| 9 | Pre-Sales Generator Agent (5-artifact workflow) — unit tested | System | Week 6 | Marcus Patel |
| 10 | Delivery Generator Agent (6-artifact workflow) — unit tested | System | Week 7 | Marcus Patel |
| 11 | Code Generator Agent (Terraform IaC + `terraform validate` gate) — unit tested | System | Week 7 | Marcus Patel |
| 12 | EO Validator Agent (format-check + Haiku 4.5 quality gate, 3-retry logic) — unit tested | System | Week 8 | Marcus Patel |
| 13 | Docker Image Pipeline (multi-stage Dockerfile, ECR push, AgentCore Runtime registration) | System | Week 8 | Marcus Patel |
| 14 | Pip-Installable CLI (14 subcommands, JWT auth, end-to-end tested) | System | Week 9 | Marcus Patel |
| 15 | Lambda Route Handlers — all 11 routes (JWT-protected, request/response validated) | System | Week 9 | Marcus Patel |
| 16 | GitHub Artifact Commit Pipeline (PAT-based commit to fixed public repository) | System | Week 9 | Marcus Patel |
| 17 | CloudWatch Observability Implementation (per-phase token metrics, dashboards, alarms) | System | Week 9 | Daniel Park |
| 18 | Comprehensive Test Plan (agent workflows, CLI, API, quota, security, converter pipeline) | Document | Week 10 | QA Sign-off |
| 19 | Test Results Report (unit, integration, API, quota, security, UAT outcomes) | Document | Week 11 | Marcus Patel |
| 20 | Production Deployment (Terraform apply, smoke test, CTO sign-off gate) | System | Week 11 | CTO |
| 21 | CLI Package Published (pip/PyPI with versioning and changelog) | System | Week 11 | Marcus Patel |
| 22 | Operational Runbooks (agent failure recovery, quota reset, PAT rotation, image update) | Document | Week 12 | Daniel Park |
| 23 | As-Built Architecture Documentation & API/CLI Reference | Document | Week 12 | Marcus Patel |
| 24 | Knowledge Transfer Sessions (Pre-Sales Engineering + Delivery Operations teams) | Training | Week 12 | Marcus Patel / Daniel Park |
| 25 | Optimisation Recommendations & Phase 2 Roadmap | Document | Week 12 | Sarah Lin / Marcus Patel |
| 26 | Formal Project Acceptance & Closeout Report | Document | Week 12 | Sarah Lin |

## Project Milestones

The following milestones mark the completion of major phases and critical decision gates within the engagement. Each milestone triggers a formal review with the named stakeholder before the next phase commences.

<!-- TABLE_CONFIG: widths=[22, 55, 23] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 — Kickoff Complete | Scope confirmed, architecture design initiated, CTO sign-off process commenced | Week 1 |
| M2 — Architecture Approved | Multi-agent graph design, AWS foundation design, and security baseline design approved by CTO and Marcus Patel | Week 3 |
| M3 — Foundation Live | Cognito auth flow operational, API Gateway scaffold responding, DynamoDB quota schema deployed in us-west-2 | Week 4 |
| M4 — All Agents Registered | All five Strands agents unit-tested and registered with Bedrock AgentCore Runtime; Docker image in ECR | Week 8 |
| M5 — Platform Integration Complete | CLI, all 11 Lambda routes, GitHub commit pipeline, and CloudWatch observability fully integrated and tested | Week 9 |
| M6 — Validation Green | All 12 artifact types passing end-to-end validation; green CloudWatch metrics baseline confirmed | Week 11 |
| M7 — Go-Live | Production deployment complete with CTO sign-off; executive demonstration delivered to Sarah Lin | Week 11 |
| M8 — Handover Complete | All documentation delivered, knowledge transfer sessions completed, formal acceptance obtained | Week 12 |
| M9 — Hypercare End | Four-week hypercare support period complete; support transitions to BAU | Week 16 |

---

# Roles & Responsibilities

Successful delivery of the Amatra Agentic Orchestration Platform requires clearly defined roles and collaborative engagement from both the vendor delivery team and PREDICTif Solutions. The following RACI matrix defines accountability across all major work streams, and the Key Personnel section describes the primary responsibilities of each named role.

## RACI Matrix

The table below assigns responsibility across the twelve major task categories for this engagement. Each task has exactly one Accountable (A) party, one or more Responsible (R) parties, and appropriate Consulted (C) and Informed (I) designations.

<!-- TABLE_CONFIG: widths=[30, 10, 10, 10, 10, 10, 10, 10] -->
| Task / Work Stream | Vendor PM | Vendor Arch | Vendor Eng | Vendor QA | Client IT Lead | Client Sec | CTO |
|-------------------|-----------|-------------|------------|-----------|----------------|------------|-----|
| Project Governance & Reporting | A/R | C | I | I | C | I | I |
| Architecture Design & CTO Review | C | A/R | C | I | C | C | A |
| AWS Foundation Infrastructure | C | A | R | I | C | I | I |
| Cognito Auth & API Gateway | C | A | R | I | C | C | C |
| Agent Development (5 Agents) | I | A | R | C | I | I | I |
| eof-Tools & Docker Pipeline | I | C | A/R | C | I | I | I |
| CLI & Lambda Route Development | I | C | A/R | C | I | I | I |
| DynamoDB Quota Enforcement | C | C | A/R | C | I | I | I |
| Security Hardening & Compliance | C | C | R | C | C | A | C |
| Testing & Validation (All Types) | C | C | R | A/R | C | C | I |
| UAT Coordination & Acceptance | A | C | C | R | A | I | C |
| Handover, Training & Runbooks | A/R | C | C | I | A | I | I |

**Legend:** R = Responsible | A = Accountable | C = Consulted | I = Informed

## Key Personnel

The following roles are committed to this engagement. Vendor team members will be confirmed upon contract execution; client roles should be identified and confirmed by Week 1.

**Vendor Team:**
- **Project Manager (Vendor PM):** Overall project coordination, weekly status reporting, risk log maintenance, budget tracking, procurement liaison for AWS spend envelope, and stakeholder communication to Sarah Lin (CRO) and Daniel Park (Head of Delivery Operations)
- **Solution Architect (Vendor Arch):** Technical authority for multi-agent graph design, AWS architecture, Bedrock model governance, and CTO briefings; accountable for architecture quality and adherence to EO Framework standards
- **Senior ML/AI Engineer (Vendor Eng — Agents):** Development lead for all five Strands agents, AgentCore Runtime registration, Bedrock model integration, retry logic, and graded artifact delivery policy
- **Senior Solutions Engineer (Vendor Eng — Platform):** Development lead for CLI (14 subcommands), Lambda route handlers (11 routes), DynamoDB quota enforcement, GitHub integration, and eof-tools Docker pipeline
- **DevOps Engineer (Vendor Eng — DevOps):** Docker image pipeline, ECR workflow, CloudWatch observability implementation, and production deployment via Terraform
- **Security Engineer:** IAM least-privilege policy design, Secrets Manager configuration, WAF rules, CloudTrail audit, DynamoDB KMS encryption, and security testing
- **QA Engineer:** Test plan authorship, unit and integration test execution, API route validation, quota contention testing, and test results report
- **Technical Writer:** Assessment reports, architecture documentation, runbooks, API reference, CLI command reference, and knowledge transfer materials

**Client Team:**
- **Executive Sponsor — Sarah Lin (CRO):** Budget owner, executive decision authority, UAT sign-off participant, and recipient of the April 2026 executive demonstration
- **Technical Lead — Marcus Patel (Director of Pre-Sales Engineering):** Primary client contact and technical counterpart; approves architecture design, accepts all technical deliverables, participates in UAT, and leads the Pre-Sales Engineering knowledge transfer
- **Delivery Stakeholder — Daniel Park (Head of Delivery Operations):** Secondary stakeholder for delivery-phase output; accepts operational runbooks and attends the Delivery Operations knowledge transfer session
- **CTO (Identity):** Required sign-off on the Cognito-based user pool design (prior to Phase 1 completion) and on production deployment (prior to Terraform apply in Phase 3); critical path item
- **Client IT Lead:** Provides access to the existing us-east-1 AWS account for current-state assessment, confirms us-west-2 account provisioning permissions, and assists with network and IAM boundary review
- **Procurement Representative:** Engaged if total platform spend exceeds the existing AWS spend envelope; confirms budget approval and purchase order process

---

# Architecture & Design

The Amatra Agentic Orchestration Platform is a fully serverless, event-driven multi-agent system built on AWS, designed to automate the end-to-end production of EO Framework pre-sales and delivery documentation. The architecture is organised into four logical layers: a security and identity perimeter, an API and CLI surface, an agentic orchestration core, and a persistence and observability substrate. Every component is deployed in the us-west-2 region in a greenfield footprint, isolated from PREDICTif's existing us-east-1 managed-services workloads to contain blast radius during the proof-of-concept phase.

The design philosophy prioritises operational simplicity over infrastructure complexity — the entire platform is serverless (Lambda, AgentCore Runtime, DynamoDB, S3) with no EC2 instances or container clusters to operate. The eof-tools converter library is baked into the agent container image, preserving the existing asset and eliminating rewrite risk. Bedrock AgentCore Runtime provides managed serverless hosting for all five agents, abstracting agent lifecycle management and enabling independent scaling of each agent function.

## Architecture Overview

This section describes the end-to-end architecture of the Amatra Agentic Orchestration Platform, illustrating how the five Strands agents, the API and CLI surface, and the supporting AWS services interact to deliver a fully automated EO Framework artifact generation pipeline.

![Figure 1: Solution Architecture Diagram](../../assets/diagrams/architecture-diagram.png)

**Figure 1: Amatra Agentic Orchestration Platform — AWS Architecture** — End-to-end architecture showing the five-agent Strands graph on Bedrock AgentCore Runtime, API Gateway HTTP API v2 with Cognito JWT authorisation, DynamoDB quota enforcement, S3 artifact storage, and CloudWatch observability in us-west-2.

The platform accepts solution generation requests through two surfaces: the pip-installable CLI (consultant-facing) and the JWT-protected REST API (programmatic). Both surfaces authenticate against the Amazon Cognito User Pool before any Lambda function is invoked. The API Gateway HTTP API v2 JWT authoriser validates every token against the Cognito JWKS endpoint, routing authenticated requests to the appropriate Lambda handler. The Lambda handlers interact with DynamoDB to enforce per-user and global quotas, then invoke the Strands multi-agent graph via Bedrock AgentCore Runtime. Completed artifacts are written to S3 and committed to the GitHub repository via the PAT-based commit pipeline. CloudWatch captures per-phase token usage, Lambda execution metrics, and quota events throughout, with dashboards and alarms surfacing platform health to Daniel Park's operations team in real time.

## Component Architecture

The platform comprises five functional agent components coordinated by the Strands multi-agent framework and hosted on Bedrock AgentCore Runtime:

**Agent 0 — Input Validator** is the entry point for every solution generation request. It receives the client brief (submitted via CLI or REST API), parses the JSON payload against the EO Framework brief schema, validates required fields (client name, provider, category, solution description, discovery answers), and surfaces structured error messages for any schema violations. Only validated briefs progress to the generation pipeline.

**Pre-Sales Generator Agent** orchestrates the production of the five presales artifacts: solution briefing (PPTX source), infrastructure costs (CSV), level-of-effort estimate (CSV), statement of work (DOCX source), and the executive proposal. It uses Claude Sonnet 4.6 via Bedrock for each artifact, with guidance files loaded from S3 as part of the prompt context. Each artifact passes through the EO Validator Agent before the next artifact is generated, implementing a fail-fast validation loop with up to three retries per artifact.

**Delivery Generator Agent** produces the six delivery-phase artifacts: project charter, implementation plan, RAID log, operational runbooks, test plan, and project closure report. It follows the same Sonnet 4.6 generation and Haiku 4.5 validation pattern as the Pre-Sales Generator, consuming delivery-specific guidance files from S3.

**Code Generator Agent** produces the Terraform IaC automation bundle for the five core AWS services deployed by the platform (Cognito, API Gateway, Lambda, DynamoDB, S3). Each generated `.tf` file is passed through a `terraform validate` subprocess call as a deterministic syntax gate before being included in the automation bundle. The bundle is packaged as a ZIP artifact and committed to the GitHub repository alongside the documentation artifacts.

**EO Validator Agent** provides the quality gate for every artifact across both generation pipelines. It runs a deterministic format-check pass (checking required YAML frontmatter, H1 section order, table structure, and image references) followed by a Claude Haiku 4.5 LLM quality review (checking content completeness, contextual introductions, placeholder resolution, and cross-reference accuracy). The agent returns a structured `{passed: bool, errors: [...], phase_part: str}` envelope. Up to three validation cycles are attempted before the artifact is flagged for human review.

The Cognito post-confirmation Lambda is a sixth function that fires as a trigger on user registration, eagerly writing the user profile and initialising the quota counter (seeded at zero) in DynamoDB. This ensures that every authenticated user has a valid quota record before their first solution generation attempt.

## Network Design

All platform components are deployed as serverless AWS managed services within the us-west-2 region and communicate exclusively over AWS-managed service endpoints — there are no EC2 instances, no VPCs, and no customer-managed network infrastructure required for this solution. API Gateway HTTP API v2 serves as the single ingress point for all external traffic, accepting HTTPS requests on the public endpoint and validating JWT tokens against the Cognito User Pool before forwarding to Lambda handlers. All Lambda-to-AWS-service communication (DynamoDB, S3, Bedrock, Secrets Manager, ECR) traverses AWS internal network fabric via IAM-authenticated API calls, never leaving the AWS network boundary. Outbound connectivity to GitHub (for artifact commits) uses HTTPS over the public internet, with the GitHub PAT stored securely in Secrets Manager. CloudWatch Logs and Metrics are emitted via the standard Lambda execution role without additional network configuration.

## Security Design

The platform implements a layered security architecture covering identity, access control, data protection, and detective controls:

**Identity and Access:** Amazon Cognito User Pools provides the authentication authority for all human users. JWT tokens (RS256, 30-day refresh, 1-hour access) are issued on login and validated by the API Gateway HTTP API v2 JWT authoriser on every request. Lambda execution roles follow the principle of least privilege — each function has an IAM role granting only the specific DynamoDB tables, S3 prefixes, Bedrock models, and Secrets Manager secrets it requires, with no wildcard resource ARNs.

**Preventative Controls:** AWS WAF is attached to the API Gateway HTTP API v2 stage with rules blocking common OWASP threats (SQL injection, XSS, rate limiting at 100 requests per IP per minute). Secrets Manager stores the GitHub PAT, Cognito client secret, and any third-party API keys — no secrets are stored in Lambda environment variables or S3. DynamoDB tables and S3 buckets are encrypted at rest using AWS-managed KMS keys.

**Detective Controls:** AWS CloudTrail is enabled for all API calls in us-west-2, providing a full audit log of agent invocations, DynamoDB writes (including quota counter changes), S3 artifact uploads, and Secrets Manager accesses. CloudWatch Alarms are configured to fire when per-user quota approaches the 10-solution limit and when the global quota approaches 1,000 solutions/month.

## Data Architecture

The platform uses three data stores, each optimised for its workload:

**Amazon DynamoDB** is the operational database for the platform, hosting three logical tables: the Users table (user profiles, quota counters, partition key: `userId`), the Solutions table (solution metadata, status, artifact locations, partition key: `solutionId`, sort key: `userId`), and the GlobalQuota table (atomic global counter for monthly solution throughput, partition key: `month`). All quota operations use DynamoDB conditional writes to enforce atomicity under concurrent load. Tables are configured with on-demand capacity (PAY_PER_REQUEST billing mode), encrypted at rest with AWS-managed KMS keys, and point-in-time recovery (PITR) enabled.

**Amazon S3** provides object storage for all artifacts in three logical prefixes: `raw/` (source markdown and CSV artifacts), `converted/` (generated DOCX, PPTX, XLSX artifacts), and `terraform/` (Terraform IaC automation bundles). Artifact objects are versioned with S3 object versioning enabled on the artifacts bucket. Lifecycle rules transition objects older than 90 days to S3 Intelligent-Tiering to manage long-term storage costs.

**Amazon ECR** stores the agent container images (multi-stage Docker builds containing the eof-tools library and all agent dependencies). Images are tagged with semantic versions and SHA digests; the AgentCore Runtime references immutable image digests to prevent unintended agent behaviour changes from tag mutations. ECR image scanning on push is enabled to detect known CVEs in base images and Python dependencies.

## Operational Design

**Observability:** CloudWatch is the primary observability platform. Lambda functions emit structured JSON logs to CloudWatch Log Groups with a 30-day retention policy. Custom CloudWatch metrics track per-phase token usage (Discovery, Planning, Development, Testing, Deployment phases) for each solution generation, enabling cost attribution and throughput reporting. The CLI `solution status <id>` subcommand and the `GET /admin/usage` API route both surface aggregated per-phase token consumption in real time. CloudWatch Dashboards provide four views: platform health (Lambda error rates, DynamoDB throttles, API Gateway 4xx/5xx), solution throughput, cost telemetry (Bedrock token spend by model and phase), and quota utilisation.

**Backup and Recovery:** DynamoDB PITR provides continuous backup with a 35-day recovery window for all three tables. S3 versioning ensures artifact recovery from accidental deletion or overwrite. The platform targets an RTO of 2 hours and an RPO of 1 hour for the production us-west-2 deployment.

**Runbook Coverage:** Operational runbooks will be delivered covering: agent failure recovery, quota reset procedures, GitHub PAT rotation (zero-downtime secret rotation via Secrets Manager), and AgentCore Runtime image update process (blue-green image deployment to avoid generation interruption during updates).

## Tooling Overview

The following table summarises the primary tools used across the engagement for both platform construction and ongoing operations:

<!-- TABLE_CONFIG: widths=[28, 35, 37] -->
| Category | Primary Tools | Purpose |
|----------|---------------|---------|
| Agent Framework | Strands Agents, AWS Bedrock AgentCore Runtime | Multi-agent graph orchestration and serverless agent hosting |
| AI Models | Claude Sonnet 4.6, Claude Haiku 4.5 (via Bedrock) | Artifact generation (Sonnet) and cost-efficient validation (Haiku) |
| Infrastructure as Code | Terraform (HashiCorp) | Platform provisioning and the Code Generator automation bundle |
| Container & Registry | Docker (multi-stage), Amazon ECR | eof-tools agent image build, versioning, and deployment |
| Authentication & API | Amazon Cognito User Pools, API Gateway HTTP API v2 | JWT-based identity and REST API surface for CLI and web consumers |
| Data & Persistence | Amazon DynamoDB, Amazon S3 | Quota enforcement, user profiles, solution metadata, artifact storage |
| Observability | Amazon CloudWatch (Logs, Metrics, Dashboards, Alarms) | Per-phase token usage, error rates, quota telemetry, and alerting |
| Security | AWS Secrets Manager, AWS WAF, AWS CloudTrail, AWS KMS | Secret management, API protection, audit logging, encryption |
| CI/CD & Source Control | AWS CodeBuild, Amazon ECR, GitHub (PAT-based) | Agent image pipeline and artifact commit workflow |
| CLI Tooling | Python (pip-installable), Click framework | 14-subcommand CLI for consultant-facing platform interaction |
| Validation | eof-tools converter library (~30 Python modules) | Deterministic DOCX/PPTX/XLSX conversion for all 12 artifact types |

---

# Security & Compliance

Security is a foundational design principle for the Amatra Agentic Orchestration Platform, not an afterthought. The platform handles authenticated user sessions, stores AI-generated intellectual property artifacts, commits code to public GitHub repositories, and makes metered calls to AWS Bedrock — each of these surfaces requires deliberate security controls. The following sections describe the security architecture across identity, monitoring, compliance, encryption, governance, and environment strategy.

## Identity & Access Management

Amazon Cognito User Pools is the authoritative identity provider for all human users of the platform. Each consultant in the PREDICTif organisation creates a Cognito account via a self-service registration flow; the post-confirmation Lambda trigger fires immediately upon email verification, writing the user profile to DynamoDB and initialising the quota counter. Authentication produces a JWT access token (1-hour expiry) and a refresh token (30-day expiry), both signed with RS256 keys managed by Cognito. The API Gateway HTTP API v2 JWT authoriser validates every inbound request against the Cognito JWKS endpoint — unauthenticated requests receive a `401 Unauthorized` response before reaching any Lambda function.

Lambda execution roles are provisioned with IAM least-privilege policies — no function has `*` resource access to any service. The Pre-Sales Generator Lambda, for example, has `bedrock:InvokeModel` scoped to the specific Sonnet 4.6 and Haiku 4.5 model ARNs, `dynamodb:GetItem` and `dynamodb:UpdateItem` scoped to the Solutions table ARN, and `s3:PutObject` scoped to the artifacts bucket with a `/raw/` prefix condition. Cognito MFA (TOTP) is configured as an optional feature for the initial release and can be made mandatory via a Cognito User Pool policy update without platform changes.

## Monitoring & Threat Detection

AWS CloudTrail is enabled in us-west-2 with a dedicated S3 bucket (server-side encryption, MFA delete enabled) capturing all management and data plane API calls across the platform's AWS services. This provides a tamper-resistant audit log of every Bedrock invocation, DynamoDB write, S3 upload, Secrets Manager access, and Lambda execution. CloudTrail logs are forwarded to CloudWatch Logs for real-time alerting — CloudWatch Alarms trigger on CloudTrail events matching suspicious patterns such as repeated authentication failures, quota counter manipulation outside the application code path, or `GetSecretValue` calls from unexpected IAM principals.

AWS WAF is attached to the API Gateway HTTP API v2 stage and enforces: IP-based rate limiting (100 requests per IP per minute), AWS Managed Rules Common Rule Set (SQLi, XSS, known bad inputs), and a custom rule blocking requests with invalid JWT `iss` claims. WAF findings are logged to CloudWatch Logs and reviewed as part of the weekly operational review during the hypercare period.

## Compliance & Auditing

The platform is designed to support PREDICTif's SOC 2 Type II compliance posture for the AI-generated content workflow, though formal SOC 2 certification is out of scope for this engagement. Key audit controls include: CloudTrail providing a complete record of all solution generation events (who requested, when, which model was invoked, which artifacts were produced), DynamoDB PITR ensuring data integrity and recovery capability, and S3 object versioning providing an immutable artifact history. Per-user and per-solution metadata in DynamoDB includes timestamps, model versions used, validation pass/fail outcomes, and artifact S3 locations — forming a comprehensive generation audit trail.

Quota enforcement (ten solutions per user per month, 1,000 solutions globally per month) is implemented using DynamoDB conditional writes, ensuring atomic enforcement that cannot be bypassed by concurrent submissions.

## Encryption & Key Management

All data at rest is encrypted using AWS-managed KMS keys: DynamoDB tables use AWS-managed CMKs (`aws/dynamodb`), S3 buckets use SSE-S3 (AES-256) with the option to upgrade to SSE-KMS for regulated data, and ECR images are encrypted at rest. All data in transit uses TLS 1.2 or higher — enforced by API Gateway (TLS 1.2 minimum policy), Cognito endpoints, and all AWS SDK calls from Lambda functions. GitHub artifact commits use HTTPS with the PAT stored in Secrets Manager; the PAT is retrieved at runtime and is never logged or included in CloudWatch structured logs.

AWS Secrets Manager stores three secret types: the GitHub Personal Access Token (rotated quarterly), Cognito app client secrets, and any third-party API keys introduced in future phases. Secrets are accessed by Lambda functions via the Secrets Manager SDK at function initialisation and cached in the Lambda execution environment for the duration of the container's warm state.

## Governance

The platform enforces a governance model through a combination of DynamoDB quota controls, IAM policy boundaries, and the graded artifact delivery policy in the EO Validator Agent. The graded delivery policy defines which artifact types must pass all three validation layers before being committed to GitHub versus which may be committed with a documented quality warning. This policy is stored as a configuration file in S3 and can be updated without a platform redeployment.

Change management for the platform follows a GitOps model — all Terraform configuration, Lambda function code, and agent container Dockerfiles are version-controlled in Git. Changes to production require a pull request review from the Solution Architect and pass automated `terraform plan` and unit test gates in CodeBuild before being applied.

## Environments & Access

The platform is deployed across three environments — development, staging, and production — each isolated at the IAM and S3 prefix level within the us-west-2 account.

### Environment Strategy

The following table defines the purpose, access controls, and data classification for each environment:

<!-- TABLE_CONFIG: widths=[18, 28, 28, 26] -->
| Environment | Purpose | Access Control | Data |
|-------------|---------|----------------|------|
| Development | Active development and unit testing of agents, Lambda routes, and CLI | Vendor engineering team only; Cognito test users; no quota enforcement | Synthetic test briefs and mock artifacts; no production data |
| Staging | Integration testing, UAT, and pre-production validation | Vendor QA team + Marcus Patel (UAT); quota enforcement enabled; mirrors production configuration | Representative presales briefs (non-confidential); generated artifacts in staging S3 prefix |
| Production | Live platform serving all 120 PREDICTif consultants | Cognito-authenticated consultants only; per-user and global quota enforced; all actions CloudTrail-logged | Real client briefs and generated presales artifacts; encrypted, versioned, access-logged |

### Access Policies

Access to each environment is controlled by Cognito User Pool groups and IAM policies. Consultants are assigned to the `consultants` group, which grants access to the production environment API routes only (`/solution/*`, `/artifact/*`). Vendor engineers are assigned to the `admin` group during the build phase, which additionally grants access to the development and staging endpoints and the `GET /admin/usage` route. Post-hypercare, vendor engineering access is revoked and the `admin` group is restricted to Daniel Park's Delivery Operations team. All group membership changes are logged in CloudTrail.

---

# Testing & Validation

Testing for the Amatra Agentic Orchestration Platform is structured across eight complementary testing disciplines, executed primarily in Phase 3 (Weeks 10–12) with unit tests occurring incrementally throughout Phase 2 as each agent and Lambda function is completed. The testing objective is to confirm that the platform meets the performance, correctness, security, and acceptance criteria defined in the Background & Objectives section before production deployment. A comprehensive test plan document (Deliverable 18) will be produced at the start of Phase 3, covering all test scenarios, pass/fail criteria, tooling, and sign-off responsibilities.

## Functional Validation

Functional validation covers two layers: individual component unit tests and end-to-end integration tests across the full generation pipeline. Unit tests are written for all five agent modules using Python's `pytest` framework with mocked Bedrock API calls — each agent's input parsing, schema validation, retry logic, and output formatting is tested in isolation against a suite of representative test cases covering both happy-path and error-path scenarios. Lambda route handlers are unit-tested using the `moto` library to mock DynamoDB and S3 interactions, with 100% coverage of request validation and error response paths.

End-to-end integration tests generate all twelve artifact types using real Bedrock API calls against the staging environment, verify format-check pass (zero errors from the deterministic validator), confirm LLM quality check approval from the Haiku 4.5 model, and validate that the eof-tools converter pipeline produces valid DOCX, PPTX, and XLSX files. This test suite must achieve a 95% or greater first-attempt validation pass rate before Phase 3 sign-off.

## Performance & Load Testing

Performance testing validates the platform's behaviour under the expected steady-state throughput of 200 solutions per month, with burst testing simulating peak concurrent submissions. A load test script simulates 20 concurrent solution generation requests, verifying that DynamoDB conditional writes enforce per-user and global quota atomically without race conditions, and that the end-to-end latency for a full twelve-artifact bundle remains under 60 minutes. Bedrock API throughput is monitored during load tests to confirm that token consumption rates stay within the provisioned limits for Sonnet 4.6 and Haiku 4.5. CloudWatch metrics are reviewed during and after load tests to confirm no Lambda throttling events or DynamoDB capacity exceptions occur.

## Security Testing

Security testing validates the platform's defence-in-depth controls across four vectors. JWT bypass testing attempts to access Lambda routes with expired tokens, tokens signed by an incorrect key, and tokens with manipulated `sub` and `scope` claims — all attempts must receive `401 Unauthorized` or `403 Forbidden` responses without reaching function code. WAF rule testing submits requests containing SQLi and XSS payloads to the API Gateway endpoint, confirming WAF blocks them with `403` responses and logs the events to CloudWatch Logs. IAM privilege escalation checks use AWS IAM Access Analyzer to confirm that no Lambda execution role grants unintended access to resources outside its defined scope. Secrets Manager access control is validated by confirming that Lambda functions outside the approved set cannot retrieve the GitHub PAT, and that all `GetSecretValue` calls appear in the CloudTrail audit log.

## Disaster Recovery & Resilience Tests

Resilience testing validates the platform's recovery behaviour under failure conditions. DynamoDB PITR is exercised by restoring the Solutions table to a point-in-time snapshot and verifying that solution metadata is intact and the platform resumes normal operation within the 2-hour RTO target. S3 artifact recovery is tested by deleting a versioned artifact object and restoring it from the previous version. Lambda cold-start behaviour under concurrent invocations is measured and confirmed to remain within acceptable latency bounds. AgentCore Runtime agent failure recovery is tested by deliberately injecting a model timeout error during a generation run and confirming the retry logic and error surfacing behave as specified.

## User Acceptance Testing

User acceptance testing is coordinated by the Project Manager with Marcus Patel (Director of Pre-Sales Engineering) as the primary UAT lead. The UAT scenario requires Marcus to submit three representative client briefs — one for an AWS AI/ML solution, one for a cloud infrastructure engagement, and one for a security solution — via the pip-installed CLI, and to review the generated presales bundles against PREDICTif's EO Framework quality standards. Each generated artifact is evaluated against the EO Framework acceptance criteria for content completeness, correct YAML frontmatter, section ordering, and cross-reference accuracy.

UAT is considered passed when Marcus signs the UAT acceptance form, confirming that the generated artifacts meet the quality bar for client-ready pre-sales documentation. Sarah Lin (CRO) reviews the UAT output as part of her executive demonstration preparation in Week 11, providing executive-level sign-off on the platform's output quality before the formal go-live decision is made.

## Go-Live Readiness

Before production deployment is initiated, the following readiness criteria must be satisfied by the delivery team and confirmed in writing by the named client stakeholder:

- All unit and integration tests passing in the staging environment with zero critical defects open
- End-to-end generation of a full twelve-artifact bundle completing in under 60 minutes in staging
- CloudWatch green baseline confirmed: Lambda error rate < 1%, DynamoDB throttles = 0, API Gateway 4xx rate < 2%
- Security testing complete with no open critical or high-severity findings
- UAT sign-off from Marcus Patel
- CTO sign-off on the Cognito user pool configuration obtained in writing
- Operational runbooks reviewed and approved by Daniel Park
- Production Terraform plan reviewed and approved by the Solution Architect
- Stakeholder communication plan for go-live executed (email to all 120 consultants with CLI onboarding instructions)

## Cutover Plan

The production cutover follows a blue-green approach. The production AWS infrastructure is provisioned via `terraform apply` against the production workspace, with the API Gateway stage initially pointed at a "dark launch" Lambda alias. A smoke test suite (five representative CLI commands, covering `auth login`, `solution generate`, `solution status`, `artifact download`, and `admin usage`) is executed against the production endpoint. Upon smoke test pass, the API Gateway stage mapping is updated to route traffic to the production Lambda alias. A stakeholder notification is sent to Sarah Lin, Marcus Patel, and Daniel Park confirming go-live. The CLI pip package is published to the distribution channel and the onboarding guide is circulated to the consultant team.

Cutover is targeted for Week 11, with a half-day cutover window scheduled during a low-activity period (Tuesday morning Pacific Time) to minimise disruption.

## Rollback Strategy

If the production smoke tests fail or a Severity 1 defect is identified within the first 24 hours of go-live, the rollback procedure is: (1) repoint the API Gateway stage mapping to the previous Lambda alias (< 5 minutes), (2) notify all stakeholders via the Project Manager, (3) revert the DynamoDB table to the pre-cutover state using PITR if any data corruption is detected, and (4) communicate a revised go-live timeline. The staging environment remains available throughout the hypercare period as a fallback for consultants who encounter production issues. Rollback does not affect the CLI pip package — consultants are instructed to use the `--api-url` flag to point the CLI at the staging endpoint during any rollback period.

---

# Handover & Support

A successful handover ensures that PREDICTif Solutions can operate the Amatra Agentic Orchestration Platform independently after the engagement concludes. The handover programme covers all documentation, knowledge transfer sessions, and four weeks of hypercare support, with a clear transition plan to business-as-usual operations.

## Handover Artifacts

The following artifacts will be delivered to PREDICTif Solutions as part of the formal handover package:

- **As-Built Architecture Documentation:** Complete architecture diagrams (draw.io source and PNG exports), network topology, IAM policy inventory, DynamoDB table schemas, S3 bucket layout, and Cognito User Pool configuration
- **API Reference:** OpenAPI 3.0 specification for all 11 Lambda routes, including request/response schemas, authentication requirements, error codes, and example payloads
- **CLI Command Reference:** Complete documentation for all 14 subcommands, including usage examples, flag descriptions, authentication flow, and troubleshooting guidance
- **Operator Guide:** Step-by-step procedures for all routine operational tasks — user provisioning, quota management, Bedrock model updates, and platform scaling
- **User Onboarding Guide:** Consultant-facing guide for CLI installation (pip install), Cognito account creation, first solution generation, and artifact download
- **Operational Runbooks:** Four runbooks covering agent failure recovery, quota reset procedures, GitHub PAT rotation, and AgentCore Runtime image update
- **Terraform Configuration:** All Terraform modules and workspace configurations for dev, staging, and production environments, committed to the agreed Git repository
- **Test Results Report:** Complete test execution results, including pass/fail rates by artifact type, load test metrics, security test findings and resolutions, and UAT sign-off documentation
- **Phase 2 Optimisation Recommendations:** Documented roadmap for parallel pipeline throughput improvements, multi-region expansion, additional artifact types, and cost optimisation at 200 solutions/month steady state

## Knowledge Transfer

Knowledge transfer is structured as a series of role-specific sessions scheduled during Week 12, supplemented by recorded walk-throughs for asynchronous reference. All sessions are conducted via video conference and recorded with participant consent for internal PREDICTif distribution.

- **Session 1 — Platform Overview (2 hours):** Architecture walk-through for Marcus Patel and Daniel Park; covers agent design, Bedrock model governance, DynamoDB quota system, and S3 artifact lifecycle. Target audience: technical stakeholders.
- **Session 2 — CLI & API Usage for Pre-Sales Consultants (2 hours):** Hands-on CLI demonstration covering all 14 subcommands; solution generation workflow; artifact download and review; error handling and quota management. Target audience: Marcus Patel's Pre-Sales Engineering team (~10 representative consultants).
- **Session 3 — Operations & Administration for Delivery Team (2 hours):** Walk-through of all four operational runbooks; CloudWatch dashboard tour; quota override procedures; GitHub PAT rotation demonstration. Target audience: Daniel Park's Delivery Operations team.
- **Session 4 — Admin API & Quota Reporting (1 hour):** Walk-through of the `GET /admin/usage` endpoint, per-phase token reporting, and CloudWatch dashboard configuration. Target audience: Daniel Park and any designated platform administrators.

## Hypercare Support

A four-week hypercare support period commences immediately following production go-live (targeted for the start of Week 12). During hypercare, the vendor team provides reactive support for production issues and proactive monitoring of the platform's health metrics.

- **Coverage:** Business hours (8:00 AM – 6:00 PM Pacific Time, Monday to Friday)
- **Response Times:** Severity 1 (platform down, generation completely blocked) — 2-hour response and workaround; Severity 2 (generation degraded, individual artifact type failing) — 4-hour response; Severity 3 (cosmetic issues, documentation queries) — next business day
- **Scope:** Hypercare covers defects in the delivered platform code and configuration, agent prompt tuning (adjustments to generation quality within the EO Framework spec), quota adjustment (increasing or decreasing per-user or global limits), and GitHub commit troubleshooting
- **Not Covered in Hypercare:** New feature requests, new artifact types, additional CLI subcommands, or changes to the EO Framework guidance files — these require a change request or a Phase 2 engagement

## Managed Services Transition

Ongoing managed operations are not included in this engagement. Following the four-week hypercare period, the platform transitions to PREDICTif's internal operations team (under Daniel Park's oversight) with all operational runbooks, monitoring dashboards, and admin API access fully transferred. If PREDICTif Solutions requires ongoing managed operations, proactive monitoring, or SLA-backed incident response beyond the hypercare period, a separate Managed Services Agreement should be established. The vendor can provide a managed services proposal upon request.

## Assumptions

This engagement is based on the following assumptions. If any of these assumptions prove incorrect, a scope review and potential change request may be required:

1. A dedicated us-west-2 AWS account (or sub-account) will be available for the platform by Week 1, with sufficient IAM permissions for the vendor team to provision all required services via Terraform
2. The CTO will be available for the architecture design review in Week 3 and for production deployment sign-off in Week 11; delays to CTO availability extend the project timeline accordingly
3. Marcus Patel will be available as the primary technical contact for a minimum of 10 hours per week throughout the engagement, and Sarah Lin will be available for UAT review and the executive demonstration
4. The eof-tools converter library (~30 Python modules) is functional and correctly converts all 12 artifact types from source markdown/CSV to DOCX/PPTX/XLSX formats; no debugging or bug-fixing of eof-tools is in scope
5. The existing EO Framework guidance files (stored in S3) are complete, accurate, and loadable by the agent prompts without modification; updating guidance file content is a client responsibility
6. Bedrock service quotas for Claude Sonnet 4.6 and Claude Haiku 4.5 in us-west-2 are sufficient to support the development and testing workload; the client will request quota increases if required
7. The GitHub repository (fixed public repository for artifact commits) is accessible via HTTPS using a Personal Access Token with `repo` scope; the client is responsible for generating and providing the PAT
8. The DynamoDB on-demand billing model is cost-effective for the initial proof-of-concept phase; if throughput significantly exceeds projections, provisioned capacity may need to be evaluated
9. All discovery questionnaire answers, client briefing templates, and EO Framework guidance files required by the agents will be loaded into S3 before Phase 2 agent development begins
10. PREDICTif's internal security team will review and approve the IAM policy designs, WAF rules, and Cognito configuration before production deployment; delays to security review may affect the go-live timeline
11. No existing us-east-1 workloads or security controls will impose network-level restrictions on the us-west-2 greenfield footprint; the two accounts are treated as fully independent
12. Procurement approval (if required for spend exceeding the existing AWS envelope) will be completed before the Phase 1 infrastructure provisioning begins
13. The pip-installable CLI will be distributed via PREDICTif's internal package management tooling; the vendor is responsible for publishing to PyPI and providing the package name; the client is responsible for internal distribution

## Dependencies

The following external dependencies must be satisfied for the engagement to proceed on schedule:

- **D1 — CTO Sign-Off on Cognito User Pool (Critical Path — Week 3):** Required before Phase 1 infrastructure is considered accepted; delays of more than one week push the Phase 2 start date by an equivalent amount
- **D2 — us-west-2 AWS Account Access (Critical Path — Week 1):** Vendor team requires console and programmatic access with sufficient permissions to provision IAM roles, Cognito, DynamoDB, S3, Lambda, API Gateway, ECR, Secrets Manager, and CloudWatch; must be confirmed in the kickoff call
- **D3 — EO Framework Guidance Files in S3 (Week 4):** All presales and delivery guidance files must be loaded into the target S3 bucket before Phase 2 agent development begins; client is responsible for this loading
- **D4 — GitHub PAT Available (Week 5):** The GitHub Personal Access Token for artifact commits must be available for storage in Secrets Manager before the GitHub integration work begins in Phase 2
- **D5 — Bedrock Model Access (Week 5):** Bedrock access for Claude Sonnet 4.6 and Claude Haiku 4.5 must be enabled in the us-west-2 region before agent development begins; the client (or vendor acting as client proxy) must request access via the Bedrock console
- **D6 — UAT Participants Available (Week 10):** Marcus Patel and representative consultants for UAT must be available and briefed on the UAT scenario by the start of Phase 3; Sarah Lin must be available for the executive demonstration in Week 11

---

# Investment Summary

This engagement is sized as a **Large complexity implementation**, reflecting a twelve-artifact multi-agent platform with eleven API routes, fourteen CLI subcommands, three integrated environments, five distinct agents, and a twelve-week fixed delivery timeline with a hard executive demonstration deadline. The investment below reconciles professional services costs from the level-of-effort estimate with infrastructure and support costs from the three-year infrastructure model.

The total three-year investment for this engagement is approximately **$375,386**, consisting of Year 1 combined professional services and infrastructure net of approximately **$284,308**, plus Year 2 and Year 3 recurring infrastructure and support costs of approximately **$43,268** and **$47,810** respectively. Year 1 costs benefit from **$30,000 in combined partner and infrastructure credits** — $25,000 in AWS Partner Network and competency programme PS credits and $5,000 in AWS Activate infrastructure credits.

## Total Investment

The following table presents the three-year investment summary, combining professional services (from the level-of-effort estimate) with infrastructure and support costs (from the infrastructure cost model). Professional services are a one-time Year 1 cost; infrastructure and support recur annually and grow modestly as solution throughput scales toward the 200 solutions/month steady state.

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[22, 13, 12, 12, 11, 11, 13] -->
| Cost Category | Year 1 List | Year 1 Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|----------------|------------|--------|--------|--------------|
| Professional Services | $275,000 | ($25,000) | $250,000 | $0 | $0 | $250,000 |
| Cloud Infrastructure | $33,308 | ($5,000) | $28,308 | $37,268 | $41,810 | $107,386 |
| Software Licenses | $0 | $0 | $0 | $0 | $0 | $0 |
| Support & Maintenance | $6,000 | $0 | $6,000 | $6,000 | $6,000 | $18,000 |
| **TOTAL INVESTMENT** | **$314,308** | **($30,000)** | **$284,308** | **$43,268** | **$47,810** | **$375,386** |
<!-- END COST_SUMMARY_TABLE -->

*Note: Professional Services figure represents gross cost before $25,000 in AWS partner credits. Cloud Infrastructure figures are drawn directly from the infrastructure cost model: Year 1 List $33,308 (AWS Activate credit $5,000 applied), Year 2 $37,268, Year 3 $41,810, 3-Year Infrastructure Total $107,386. Support & Maintenance reflects AWS Business Support at $6,000/year flat rate, 3-Year Total $18,000. Combined infrastructure 3-Year Total: $125,386.*

## Partner Credits

PREDICTif Solutions qualifies for the following partner credit programmes in Year 1, representing a combined saving of **$30,000** against the gross investment:

- **AWS Partner Services Credit ($15,000):** AWS Partner Network (APN) Advanced Tier credit applicable to Bedrock and AgentCore solution architecture and implementation services. Applied directly against professional services billings in Year 1. Subject to standard APN programme approval; the vendor will manage the application process.
- **AWS Generative AI Competency Incentive ($5,000):** AWS Generative AI competency partner incentive for validated multi-agent Bedrock implementations. Eligibility is subject to APN competency verification; the vendor holds the required Generative AI competency designation.
- **Volume Implementation Discount ($5,000):** Strategic account discount on professional services for the fixed-scope twelve-week engagement (approximately 2% of total services value).
- **AWS Activate / Solutions Partner Infrastructure Credit ($5,000):** AWS Activate or Solutions Partner programme credit applicable against Bedrock and compute spend in Year 1. Applied to the Cloud Infrastructure line in the investment table above.

All credits are Year 1 only and are applied as they are consumed; they do not carry forward to Year 2 or Year 3.

## Cost Components

**Professional Services ($275,000 list / $250,000 net):** Professional services cover the complete twelve-week delivery engagement across all five phases — Discovery, Planning, Development, Testing, and Deployment — plus four weeks of hypercare support and project management overhead. The engagement involves eight resource roles: Project Manager, Solution Architect, Senior ML/AI Engineer (Agents), Senior Solutions Engineer (Platform), DevOps Engineer, Security Engineer, QA Engineer, and Technical Writer. Blended hourly rates range from $125 (Technical Writer) to $250 (ML/AI Engineer). Total estimated hours are approximately 1,200 hours, inclusive of a 10% project management and technical leadership overhead applied across all engineering tasks.

**Cloud Infrastructure ($33,308 Year 1 list / $107,386 three-year total):** Infrastructure costs reflect the steady-state operating cost of the platform at approximately 200 solutions per month. The largest single line items are Amazon Bedrock Claude Sonnet 4.6 ($18,000/year) for primary generation, Bedrock AgentCore Runtime ($9,600/year) for serverless agent hosting, and Amazon CloudWatch ($2,400/year) for observability. Full Bedrock token spend (Sonnet + Haiku) is targeted at under $5 per solution in model spend. Year 2 and Year 3 infrastructure costs grow at approximately 20% per year, reflecting projected throughput growth as the platform is adopted across the full 120-consultant organisation.

**Support & Maintenance ($6,000/year / $18,000 three-year total):** AWS Business Support provides 24x7 access and a <1-hour critical response SLA, covering all AWS services in the us-west-2 deployment. This is a flat annual cost and does not scale with solution volume.

## Payment Terms

Professional services fees are invoiced in four milestone-based instalments aligned to the project phases:

- **Milestone 1 (25% — $62,500 net):** Upon execution of this SOW and project kickoff
- **Milestone 2 (25% — $62,500 net):** Upon completion of Phase 1 — AWS foundation infrastructure live and accepted by Marcus Patel (target Week 4)
- **Milestone 3 (35% — $87,500 net):** Upon completion of Phase 2 — all five agents registered on AgentCore Runtime and platform integration complete (target Week 9)
- **Milestone 4 (15% — $37,500 net):** Upon completion of Phase 3 and formal project acceptance — production deployment live, executive demonstration delivered, and all documentation transferred (target Week 12)

AWS partner credits ($25,000) are applied against Milestone 1 and Milestone 2 invoices ($15,000 against M1 and $10,000 against M2). Infrastructure and support costs are invoiced monthly in arrears based on actual AWS consumption, reconciled against the infrastructure cost model at the end of each calendar month.

## Invoicing & Expenses

Invoices are issued electronically to the attention of Marcus Patel with a copy to PREDICTif's Procurement Representative, with Net 30 payment terms. Reasonable pre-approved travel expenses (for on-site kickoff or executive demonstration) are reimbursed at cost against receipts, not to exceed $5,000 for the engagement. All AWS infrastructure costs are invoiced directly to PREDICTif's AWS account; the vendor does not mark up AWS consumption costs.

---

# Terms & Conditions

This Statement of Work is governed by the terms and conditions set out below and, where executed, by the Master Services Agreement (MSA) between PREDICTif Solutions and the Consulting Company. In the event of any conflict between this SOW and the MSA, the MSA shall prevail except where this SOW expressly states otherwise.

## General Terms

This SOW and the services described herein are subject to PREDICTif Solutions' executed Master Services Agreement with the Consulting Company. All general terms — including warranty, indemnification, insurance, and dispute resolution — are as set out in the MSA. This SOW constitutes a Project Order under the MSA and is effective upon signature by both parties.

## Scope Changes

Any change to the scope, timeline, or budget defined in this SOW must be submitted as a formal Change Request (CR). The Project Manager will document the requested change, assess the impact on scope, cost, and timeline, and present a CR to Marcus Patel for approval within three business days of receipt. No change work will commence until the CR is approved in writing. PREDICTif Solutions may request changes via email or through the weekly project status meeting. Approved CRs become addenda to this SOW. Scope changes exceeding 20% of the original engagement value in aggregate may require a revised SOW to be executed by both parties.

## Intellectual Property

All deliverables produced specifically for PREDICTif Solutions under this SOW — including all Terraform code, Lambda function code, CLI source code, agent configuration, architecture documentation, and training materials — become the property of PREDICTif Solutions upon full payment of the applicable invoice. The Consulting Company retains ownership of all pre-existing methodologies, frameworks, tools, accelerators, and know-how (including the Amatra EO Framework architecture patterns) used in the delivery of this engagement. PREDICTif Solutions is granted a perpetual, non-exclusive, royalty-free licence to use any pre-existing Consulting Company intellectual property embedded in the deliverables for internal business purposes. The eof-tools converter library is PREDICTif's existing asset and remains wholly owned by PREDICTif Solutions.

## Service Levels

The Consulting Company warrants that all deliverables will conform to the acceptance criteria defined in this SOW and that the services will be performed in a professional and workmanlike manner. If a defect in any delivered system component is identified within 90 days of the formal project acceptance date (the Warranty Period), the Consulting Company will remedy the defect at no additional cost to PREDICTif Solutions. This warranty does not cover defects arising from changes made to the platform by PREDICTif Solutions after acceptance, third-party service changes (e.g., AWS Bedrock API changes), or issues attributable to incorrect inputs (e.g., malformed client briefs). Hypercare support SLAs are as defined in the Handover & Support section.

## Liability

The total liability of the Consulting Company under this SOW (excluding any liability for fraud, wilful misconduct, or death/personal injury) is capped at the total professional services fees paid by PREDICTif Solutions under this SOW in the twelve months preceding the event giving rise to the claim. Neither party shall be liable to the other for indirect, consequential, special, or punitive damages. PREDICTif Solutions is responsible for ensuring that the platform is used in compliance with AWS's Acceptable Use Policy and Bedrock's usage policies, and for any costs arising from excessive Bedrock token consumption beyond the quota limits enforced by the platform.

## Confidentiality

Both parties agree to maintain the confidentiality of the other party's Confidential Information disclosed in connection with this SOW, using the same degree of care as they use to protect their own confidential information (but no less than reasonable care), and not to disclose such information to any third party without the prior written consent of the disclosing party. Confidential Information does not include information that is or becomes publicly known through no fault of the receiving party, was known to the receiving party prior to disclosure, or is independently developed by the receiving party without use of the disclosing party's Confidential Information. The confidentiality obligations survive termination of this SOW for a period of three years.

## Termination

Either party may terminate this SOW for material breach upon 30 days' written notice if the breach is not remedied within that period. PREDICTif Solutions may terminate this SOW for convenience upon 15 days' written notice, in which case PREDICTif Solutions will pay for all services rendered and expenses incurred up to the termination date plus a termination fee equal to 15% of the remaining milestone payments not yet invoiced. Upon termination, the Consulting Company will deliver all work-in-progress deliverables to PREDICTif Solutions in their current state. The confidentiality, intellectual property, and limitation of liability provisions survive termination.

## Governing Law

This SOW shall be governed by and construed in accordance with the laws of the State of Delaware, United States, without regard to its conflict of law provisions. Any disputes arising under this SOW that cannot be resolved by good-faith negotiation shall be submitted to binding arbitration under the rules of the American Arbitration Association in Seattle, Washington.

---

# Sign-Off

By signing below, both parties confirm that they have read, understood, and agree to the scope, deliverables, timelines, roles, investment, and terms outlined in this Statement of Work. This document constitutes the complete agreement between PREDICTif Solutions and the Consulting Company for the services described herein and supersedes all prior negotiations, representations, or agreements relating to the Amatra Agentic Orchestration Platform engagement.

**Client Authorised Signatory — PREDICTif Solutions:**

Name: __________________________

Title: __________________________

Signature: ______________________

Date: __________________________

Organisation: PREDICTif Solutions

---

**Service Provider Authorised Signatory — Amatra (EO Framework Division):**

Name: __________________________

Title: __________________________

Signature: ______________________

Date: __________________________

Organisation: Amatra / Consulting Company

---

*This Statement of Work, together with the executed Master Services Agreement, constitutes the complete and binding agreement between the parties for the Amatra Agentic Orchestration Platform engagement. Any amendments must be made in writing and signed by authorised representatives of both parties.*

---

*Document Version: 1.0 | Prepared by: Amatra EO Framework Division | Opportunity: OPP-2026-001 | Date: June 2025*
