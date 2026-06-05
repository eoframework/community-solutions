---
document_title: Statement of Work
technology_provider: aws
project_name: Amatra Agentic Pre-Sales Platform on AWS
client_name: PREDICTif Solutions
client_contact: Marcus Patel | Director of Pre-Sales Engineering | marcus.patel@predictif.com
consulting_company: Amatra (EO Framework Division)
consultant_contact: Engagement Lead | engagement@amatra.io | +1 (800) 555-0190
opportunity_no: OPP-2026-001
document_date: May 2025
version: 1.0
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Statement of Work (SOW) defines the scope, deliverables, roles, and commercial terms for the design and delivery of the **Amatra Agentic Pre-Sales Platform on AWS** for PREDICTif Solutions. This twelve-week, fixed-timeline engagement will transform PREDICTif's current manual pre-sales documentation workflow into a fully automated, serverless agentic platform — eliminating the six to ten hours of senior-consultant effort currently consumed per engagement and enabling the sales organisation to generate complete, validated EO Framework solution packages end-to-end in under one hour.

The platform is built on Amazon Bedrock AgentCore Runtime, Strands Agents, and Claude Sonnet 4.6 / Haiku 4.5, and exposes both a pip-installable fourteen-subcommand CLI and an eleven-route JWT-protected HTTP API. It produces twelve artifacts per solution (five presales, six delivery, one Terraform automation bundle), enforces per-user and global quotas via DynamoDB, and commits all output artifacts to a public GitHub repository. The proof-of-concept will be deployed in a fresh us-west-2 AWS footprint, with an executive sponsor demonstration hard-targeted for end of April 2026.

**Project Duration:** 12 Weeks (Q1–Q2 2026)

**Key Outcomes:**
- Serverless multi-agent orchestration platform live in us-west-2 by end of April 2026
- Five Bedrock AgentCore agents registered and orchestrated by Step Functions
- All twelve artifact types (DOCX, PPTX, XLSX, Terraform IaC) passing validation end-to-end
- Green CloudWatch metrics baseline demonstrating per-solution latency, token spend, and retry rates
- pip-installable CLI with fourteen subcommands and eleven JWT-protected Lambda API routes

**Expected Benefits:**
- **90% effort reduction:** Per-engagement consultant time cut from 6–10 hours to under 1 hour
- **Parallel pipeline throughput:** Simultaneous multi-solution generation with no manual intervention
- **Predictable cost:** Per-solution Bedrock spend targeted at under $5; infrastructure amortises to under $0.50 per solution at 200 solutions/month steady state
- **Audit and governance:** Complete CloudTrail audit trail, per-user monthly quotas (10 solutions/user), and global pool (1,000 solutions/month) enforced atomically
- **Scalable delivery:** Platform designed to scale linearly from PoC throughput to 1,000+ solutions/month with no architectural changes

---

# Background & Objectives

PREDICTif Solutions operates a 120-consultant distributed practice across the United States and Canada, generating customer-facing pre-sales and delivery documentation through a product internally branded as Amatra. The current workflow relies on individual consultants manually feeding EO Framework guidance files into Claude Code CLI on local laptops, iterating three to four times on validation failures, running Python converter scripts to produce Office-format documents, and manually pushing results into a customer engagement repository on GitHub. This process has no centralised orchestration, no per-user identity, no automated retry on validation failure, and no audit trail — each presales package consuming six to ten hours of senior-consultant time.

## Current State

PREDICTif's Amatra team produces EO Framework solution packages entirely manually. Key challenges include:

- **No Automation or Orchestration:** Each engagement requires a senior consultant to manually invoke Claude Code CLI, iterate on validation failures, run converter scripts, and copy artifacts to OneDrive and then GitHub. There is no pipeline, no retry automation, and no parallelism.
- **High Effort Per Engagement:** Six to ten hours of senior-consultant time per pre-sales package limits the number of concurrent opportunities the team can pursue and represents a significant cost of sales for every engagement.
- **No Centralised Identity or Quota Controls:** Artifacts are stored in a private OneDrive folder with no per-user identity, no audit trail, no access control, and no quota enforcement — creating risk of runaway LLM spend and output inconsistency.
- **No API or Programmatic Interface:** The workflow is entirely manual with no API surface. There is no way for the sales organisation to self-serve, no status tracking, and no integration with downstream CRM or delivery systems.
- **Fragile Single-Machine Process:** Generation depends on a local laptop environment with no reproducibility guarantee. Environment drift, model version changes, and converter script updates can silently break the pipeline with no alerting.
- **Scalability Ceiling:** The manual workflow cannot scale beyond the current throughput of a handful of engagements per consultant per week, creating a hard ceiling on pipeline capacity as the sales organisation grows.

## Business Objectives

The following strategic objectives have been established in partnership with Sarah Lin (CRO), Marcus Patel (Director of Pre-Sales Engineering), and Daniel Park (Head of Delivery Operations) to guide the scope and success criteria for this engagement.

- **Automate End-to-End Generation:** Deliver an agentic platform that produces a complete twelve-artifact EO Framework solution package end-to-end in under one hour with no human in the loop.
- **Establish Centralised Identity and Quota Governance:** Implement Amazon Cognito User Pools, JWT-protected API, and atomic DynamoDB quota enforcement to control per-user and global solution generation rates.
- **Reduce Per-Engagement Effort by 90%:** Shift senior-consultant time from artifact production to artifact review and client customisation, targeting a reduction from 6–10 hours to under 30 minutes of human effort per engagement.
- **Enable Parallel Pipeline Throughput:** Allow the sales organisation to run multiple solution generations concurrently at 200 solutions/month steady-state, unlocking capacity for higher pipeline volume without proportional headcount growth.
- **Build a Production-Ready PoC by April 2026:** Deliver a demonstrable, executive-ready platform within the fixed twelve-week schedule, meeting the hard deadline for Sarah Lin's (CRO) executive sponsor presentation.
- **Establish a Foundation for Phase 2 Growth:** Design the platform to scale linearly to 1,000+ solutions/month and to accommodate multi-region expansion, advanced analytics, and managed-services integration in a follow-on engagement.

## Success Metrics

The platform's success will be measured against the following specific, time-bound criteria upon completion of the twelve-week engagement and through the hypercare period.

- End-to-end solution generation time of under 60 minutes at the P95 latency for a twelve-artifact bundle
- 90% reduction in per-engagement senior-consultant effort measured against the 6–10 hour baseline
- All twelve artifact types (five presales, six delivery, one Terraform bundle) passing format-check and LLM quality validation end-to-end without manual intervention
- Per-solution Bedrock token spend at or below $5 for the Claude Sonnet 4.6 + Haiku 4.5 mix
- Zero quota overruns: per-user limit (10 solutions/month) and global pool (1,000 solutions/month) enforced atomically in DynamoDB with no race conditions under load
- Green CloudWatch metrics dashboard with P99 Lambda latency, error rates, and validation retry rates within agreed thresholds
- Successful executive sponsor demonstration delivered to Sarah Lin by end of April 2026

---

# Scope of Work

This engagement delivers a full-stack serverless agentic orchestration platform on AWS that automates the EO Framework pre-sales documentation workflow for PREDICTif's Amatra team. The following defines the exact boundaries, activities, and phasing of the twelve-week engagement.

## In Scope

The following services and deliverables are included in this SOW:

- Design, provisioning, and configuration of all AWS infrastructure in us-west-2 (Cognito, API Gateway, Lambda, DynamoDB, S3, ECR, AgentCore, Step Functions, Secrets Manager, CloudWatch, VPC)
- Implementation of five Bedrock AgentCore agents (Input Validator, Pre-Sales Generator, Delivery Generator, Code Generator, EO Validator) orchestrated via AWS Step Functions
- Development and packaging of a pip-installable CLI with fourteen subcommands, including authentication, solution generation, status, and admin subcommands
- Eleven JWT-protected HTTP API Lambda routes behind API Gateway HTTP API v2
- Amazon Cognito User Pool with thirty-day refresh tokens and post-confirmation Lambda trigger for eager DynamoDB user-profile writes
- Per-user (10 solutions/month) and global (1,000 solutions/month) quota enforcement via atomic DynamoDB conditional writes
- Integration of the eof-tools converter library (~30 Python modules) into the AgentCore container image to produce DOCX, PPTX, and XLSX artifacts
- Terraform IaC for the complete platform with `terraform validate` as a CI syntax gate
- Per-artifact format-check and LLM quality-check validation with up to three automated retries per artifact
- Per-phase token usage instrumentation surfaced in the CLI status command and admin API endpoint
- Automated GitHub artifact commits via Secrets Manager–stored personal access token
- CloudWatch dashboards, alarms, and green metrics baseline
- Full as-built documentation, operational runbooks, and knowledge-transfer sessions
- Eight-week post-go-live hypercare support

### Scope Parameters

This engagement is sized at the **Large** complexity tier, based on the following parameters that define the boundaries of this SOW.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | Artifact Types per Solution | 12 (5 presales + 6 delivery + 1 Terraform IaC bundle) |
| Solution Scope | Agents per Solution Run | 5 (Input Validator, Pre-Sales Generator, Delivery Generator, Code Generator, EO Validator) |
| Solution Scope | Validation Retries per Artifact | Up to 3 (format-check + LLM quality-check) |
| Integration | External Integrations | 5 (Bedrock, Cognito, DynamoDB, S3, GitHub PAT) |
| Integration | API Routes | 11 Lambda routes behind API Gateway HTTP API v2 |
| Integration | CLI Subcommands | 14 (pip-installable) |
| User Base | Monthly Active Users | ~120 distributed consultants (US & CA) |
| User Base | Per-User Quota | 10 solutions/user/month enforced atomically |
| User Base | Global Monthly Quota | 1,000 solutions/month global pool |
| Data Volume | Artifact Storage | ~200 GB Year 1 (raw markdown/CSV + converted DOCX/PPTX/XLSX) |
| Data Volume | Bedrock Token Volume | 5M–25M tokens/month (Sonnet 4.6 + Haiku 4.5 combined) |
| Technical Environment | AWS Region | us-west-2 (isolated fresh footprint) |
| Technical Environment | Environments | 2 (dev, production) + staging for Terraform validation |
| Technical Environment | Container Strategy | eof-tools baked into AgentCore Docker image via ECR |
| Security & Compliance | Authentication | Cognito User Pool, JWT, 30-day refresh tokens |
| Security & Compliance | Secrets Management | Secrets Manager for GitHub PAT and all API keys |
| Security & Compliance | Audit Trail | CloudTrail data events + CloudWatch log retention |
| Performance | End-to-End SLA | Under 60 minutes per twelve-artifact solution |
| Performance | Monthly Throughput Target | 200 solutions/month steady state |

*Note: Changes to these parameters — particularly agent count, artifact types, or integration surface — may require scope adjustment and additional investment.*

## Out of Scope

These items are explicitly not included in this engagement unless added via formal change control:

- Migration of existing legacy us-east-1 AWS workloads (managed-services accounts remain unchanged)
- Development of a graphical user interface (GUI) or web portal (CLI and API only)
- Integration with external CRM, PSA, or sales-force automation systems
- Custom machine learning model training or fine-tuning of Claude Sonnet 4.6 / Haiku 4.5
- Multi-region deployment or active-active high-availability configuration (us-west-2 only)
- Managed services ongoing operations post-hypercare (subject to separate Managed Services Agreement)
- Refactoring or re-engineering of the eof-tools converter library (~30 Python modules are integrated as-is)
- Development of additional CLI subcommands beyond the specified fourteen
- Enterprise GitHub organisation setup or GitHub Actions CI/CD for the public artifact repository
- SOC 2 Type II audit or formal compliance certification (security controls are implemented but not certified)
- Third-party penetration testing (internal security testing is included; independent pen test is out of scope)

## Activities

### Phase 1 – Foundation & Security (Weeks 1–4)

Phase 1 establishes the core AWS infrastructure, identity, and security baseline before any agent code is written. This phase de-risks the entire engagement by ensuring authentication, quota enforcement, and storage are production-grade from the outset.

Key activities:
- Provision fresh us-west-2 AWS account structure: VPC, IAM roles, S3 bucket policies, CloudTrail, cost allocation tags, and resource tagging strategy
- Deploy Amazon Cognito User Pool with thirty-day refresh tokens and post-confirmation Lambda trigger for eager DynamoDB user-profile writes
- Design and provision DynamoDB tables for user profiles, solution state, per-user quota counters, and global pool counter with atomic conditional-write enforcement
- Deploy API Gateway HTTP API v2 with JWT authoriser and eleven Lambda route stubs; implement per-route throttling and per-user quota enforcement
- Implement Secrets Manager secrets for GitHub PAT and all API keys with rotation schedules
- Establish KMS key policy, VPC endpoints for Bedrock/DynamoDB/S3, CloudTrail data events, and GuardDuty enablement
- Begin development of pip-installable CLI: login, logout, and token-refresh subcommands with JWT credential storage
- Conduct CTO briefing on Cognito User Pool scope and obtain sign-off gate for production deployment

**Deliverable:** Foundation Infrastructure Acceptance Report confirming all Phase 1 AWS resources provisioned, IAM baseline validated, Cognito User Pool live, and CTO sign-off obtained.

### Phase 2 – Agents & Integration (Weeks 5–9)

Phase 2 delivers the core agentic platform, including all five Strands agents registered on Bedrock AgentCore Runtime, the eof-tools container integration, and the end-to-end solution generation workflow. This is the critical-path phase of the engagement.

Key activities:
- Design and implement the multi-agent Strands graph: Agent 0 (Input Validator), Pre-Sales Generator, Delivery Generator, Code Generator, EO Validator with inter-agent messaging contracts
- Build and push Docker images to ECR with eof-tools library (~30 Python modules) baked in; validate all twelve artifact-type converters (DOCX, PPTX, XLSX, Terraform IaC)
- Register all five agents in Bedrock AgentCore Runtime with appropriate IAM execution roles and resource-based policies
- Implement AWS Step Functions orchestration state machine for agent-graph execution and graded artifact-delivery policy enforcement
- Integrate Claude Sonnet 4.6 for artifact generation and Claude Haiku 4.5 for cost-efficient validation; implement prompt templates and retry logic (up to three retries per artifact)
- Complete all fourteen CLI subcommands (solution generation, status, artifact download, quota check, admin usage)
- Implement all eleven Lambda API route handlers with JWT protection, per-route throttle policies, and DynamoDB quota enforcement
- Implement GitHub integration: commit output artifacts to public repository via Secrets Manager–stored PAT with branch strategy and commit message format
- Set up CodePipeline + CodeBuild CI/CD: Docker image build, ECR push, AgentCore re-registration, and automated smoke test on deploy

**Deliverable:** Agent Integration Milestone Report confirming all five agents registered in AgentCore, end-to-end solution generation producing at least one complete twelve-artifact bundle, and all twelve artifact-type converters passing validation.

### Phase 3 – Validation & Green Baseline (Weeks 10–12)

Phase 3 validates the complete platform across all artifact types, establishes the CloudWatch metrics baseline, and prepares the platform for the executive sponsor demonstration. This phase gates on a green metrics baseline before go-live is declared.

Key activities:
- Execute comprehensive test plan: unit tests (>80% coverage), integration tests across all twelve artifact types, validation-loop testing (format-check + LLM quality-check with up to three retries)
- Conduct load testing at 200 solutions/month throughput; verify concurrent solution generation and DynamoDB atomic quota writes under load; confirm P95 end-to-end latency under 60 minutes
- Complete security testing: IAM policy review, Cognito token validation, JWT authoriser bypass testing, OWASP API Top 10 checks on all eleven Lambda routes
- Validate `terraform validate` gate passing in CI for all IaC modules; test plan/apply in staging environment
- Instrument per-phase token usage in all five agents; surface counts in CLI `status` command and `GET /admin/usage` endpoint
- Coordinate UAT with Marcus Patel (pre-sales scenarios), Daniel Park (delivery scenarios), and CTO (Cognito/production gate); obtain UAT sign-off
- Achieve and document green CloudWatch metrics baseline: error rates, P99 latency, validation retry rates, and per-solution token spend
- Deploy full platform to production us-west-2; configure GitHub repository with branch protection and PAT integration
- Deliver CLI package, runbooks, and complete as-built documentation; conduct knowledge-transfer sessions for engineering and pre-sales teams
- Execute executive sponsor demonstration for Sarah Lin (CRO) by end of April 2026

**Deliverable:** Test Results Report (including UAT sign-off, security attestation, CloudWatch baseline), Production Deployment Confirmation, and Executive Sponsor Demonstration Package.

---

# Deliverables & Timeline

This section defines all formal deliverables produced during the engagement, their acceptance authority, and the project milestones that gate phase transitions. Every deliverable listed below is a binding commitment within the scope of this SOW.

## Deliverables

The following table enumerates all deliverables across all three phases, including both technical system deliverables and documentation outputs. Each deliverable has a named acceptance authority to ensure clear ownership of the sign-off process.

<!-- TABLE_CONFIG: widths=[5, 42, 12, 18, 23] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|-------------|------|----------|---------------|
| 1 | Project Kickoff Deck & Minutes | Document | Week 1 | Marcus Patel, Sarah Lin |
| 2 | Current State Assessment & Gap Analysis | Document | Week 2 | Marcus Patel |
| 3 | Architecture Design Document (incl. agent-graph topology, OpenAPI spec, ADRs) | Document | Week 3 | Marcus Patel, CTO |
| 4 | CTO Sign-Off: Cognito User Pool Design | Approval | Week 3 | CTO |
| 5 | Foundation Infrastructure — Cognito, API GW, DynamoDB, S3, IAM, VPC | System | Week 4 | Cloud Engineer, Client IT |
| 6 | Foundation Infrastructure Acceptance Report | Document | Week 4 | Marcus Patel, Daniel Park |
| 7 | pip-installable CLI Package (authentication subcommands) | System | Week 5 | Marcus Patel |
| 8 | AgentCore Runtime — All 5 Agents Registered | System | Week 7 | Solution Architect |
| 9 | eof-tools Container Image (all 12 artifact converters validated) | System | Week 7 | DevOps Engineer |
| 10 | Step Functions Orchestration State Machine | System | Week 8 | Solution Architect |
| 11 | Complete CLI Package (all 14 subcommands) | System | Week 9 | Marcus Patel |
| 12 | All 11 Lambda API Routes (JWT-protected, quota-enforced) | System | Week 9 | Solutions Engineer |
| 13 | GitHub Integration (PAT commit, branch strategy) | System | Week 9 | Solutions Engineer |
| 14 | CI/CD Pipeline (CodePipeline + CodeBuild + ECR) | System | Week 9 | DevOps Engineer |
| 15 | Terraform IaC Full Platform Modules (terraform validate passing) | System | Week 9 | DevOps Engineer |
| 16 | Agent Integration Milestone Report | Document | Week 9 | Marcus Patel, Daniel Park |
| 17 | Test Plan | Document | Week 10 | QA Engineer, Marcus Patel |
| 18 | Token Usage Instrumentation (CLI status + admin API endpoint) | System | Week 10 | ML/AI Engineer |
| 19 | Unit Test Suite (>80% code coverage) | System | Week 11 | Solutions Engineer |
| 20 | Integration Test Results (all 12 artifact types) | Document | Week 11 | QA Engineer |
| 21 | Load Test Results (200 solutions/month throughput) | Document | Week 11 | Solutions Engineer |
| 22 | Security Test Report (IAM, Cognito, OWASP API Top 10) | Document | Week 11 | Security Engineer |
| 23 | UAT Sign-Off (Marcus Patel, Daniel Park, CTO) | Approval | Week 12 | Marcus Patel, CTO |
| 24 | Green CloudWatch Metrics Baseline Dashboard | System | Week 12 | DevOps Engineer |
| 25 | Production Deployment — Full Platform in us-west-2 | System | Week 12 | Cloud Engineer, CTO |
| 26 | Test Results Report (consolidated) | Document | Week 12 | QA Engineer |
| 27 | Operational Runbooks (agent failure recovery, quota reset, PAT rotation, DR) | Document | Week 12 | Daniel Park |
| 28 | As-Built Documentation Package (architecture, API reference, deployment guide) | Document | Week 12 | Marcus Patel, Daniel Park |
| 29 | Knowledge Transfer — Engineering Deep-Dive (recorded) | Training | Week 12 | Amatra Engineering Team |
| 30 | Knowledge Transfer — Pre-Sales Workflow Training | Training | Week 12 | Marcus Patel's Pre-Sales Team |
| 31 | Executive Sponsor Demonstration Package | Document | Week 12 | Sarah Lin (CRO) |
| 32 | Optimisation Recommendations & Phase 2 Roadmap | Document | Week 12 + Hypercare | Marcus Patel, Sarah Lin |

## Project Milestones

The milestones below mark the formal completion of each phase and the critical decision gates that govern the engagement timeline. Each milestone must be achieved on schedule to protect the hard April 2026 executive sponsor demonstration deadline.

<!-- TABLE_CONFIG: widths=[22, 53, 25] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 – Kickoff Complete | Stakeholder alignment achieved; architecture design underway; CTO briefing scheduled | Week 1 |
| M2 – Foundation Live | Cognito User Pool, API Gateway, DynamoDB, S3, and IAM baseline provisioned and accepted; CTO sign-off on Cognito obtained | Week 4 |
| M3 – First End-to-End Generation | At least one complete twelve-artifact solution bundle generated and validated through all five agents | Week 7 |
| M4 – Agent Integration Complete | All five agents registered in AgentCore, all fourteen CLI subcommands operational, all eleven API routes live; eof-tools converters validated | Week 9 |
| M5 – UAT Sign-Off | UAT completed and formally signed off by Marcus Patel, Daniel Park, and CTO; all P1/P2 defects resolved | Week 11 |
| M6 – Green Baseline | CloudWatch metrics baseline certified green; per-solution token spend ≤ $5; P95 latency < 60 minutes | Week 12 |
| M7 – Go-Live | Full platform deployed to production us-west-2; GitHub integration live; all deliverables accepted | End of Week 12 / April 2026 |
| M8 – Executive Demo | Live demonstration to Sarah Lin (CRO) confirming 90% effort reduction and end-to-end generation under 60 minutes | End of April 2026 |
| M9 – Hypercare End | Eight-week hypercare period concludes; Optimisation Recommendations and Phase 2 Roadmap delivered | Week 20 |

---

# Roles & Responsibilities

This section defines the roles, responsibilities, and accountability assignments for all parties involved in the engagement. A RACI matrix governs task ownership across the vendor team and the PREDICTif client team throughout all three phases.

## RACI Matrix

The following matrix covers the major task categories for the twelve-week engagement. Each task has exactly one Accountable (A) party and one or more Responsible (R) parties. The matrix spans the full delivery lifecycle from architecture design through hypercare.

<!-- TABLE_CONFIG: widths=[30, 10, 10, 10, 9, 10, 11] -->
| Task | Vendor PM | Vendor Arch | Vendor Eng | Vendor QA | Client IT | Client PM |
|------|-----------|-------------|------------|-----------|-----------|-----------|
| Project Kickoff & Stakeholder Alignment | A/R | C | I | I | C | C |
| Architecture Design & ADRs | C | A/R | C | I | C | I |
| AWS Landing Zone & IAM Baseline | I | A | R | I | C | I |
| Cognito User Pool Design & CTO Sign-Off | C | A | R | I | A | C |
| DynamoDB Schema & Quota Enforcement | I | A | R | I | C | I |
| API Gateway & Lambda Route Development | I | C | A/R | C | I | I |
| Strands Agent Graph Design | C | A/R | C | I | I | I |
| AgentCore Runtime Registration (5 Agents) | I | A | R | C | I | I |
| eof-tools Container Image Build & Validation | I | C | A/R | C | I | I |
| Step Functions Orchestration State Machine | I | A | R | C | I | I |
| CLI Development (14 Subcommands) | I | C | A/R | C | I | I |
| Bedrock Model Integration & Retry Logic | I | A | R | C | I | I |
| GitHub PAT Integration & Commit Workflow | I | C | A/R | C | I | C |
| CI/CD Pipeline (CodePipeline + CodeBuild) | I | C | A/R | C | I | I |
| Terraform IaC & terraform validate Gate | I | C | A/R | C | I | I |
| Security Hardening & Secrets Manager | C | C | A/R | C | C | I |
| Token Usage Instrumentation | I | A | R | C | I | I |
| CloudWatch Dashboards & Alarms | I | C | A/R | C | I | I |
| Test Plan Development | C | C | C | A/R | I | C |
| Unit & Integration Testing | I | C | R | A | I | I |
| UAT Coordination & Sign-Off | A | C | C | R | R | A |
| Load & Performance Testing | I | C | R | A/R | I | I |
| Security Testing (IAM, OWASP API Top 10) | C | C | R | A | C | I |
| Production Deployment | A | C | R | C | C | C |
| Runbook Development | C | C | R | I | C | A |
| Knowledge Transfer — Engineering | C | A/R | C | I | R | C |
| Knowledge Transfer — Pre-Sales | A | C | C | I | I | R |
| Executive Sponsor Demonstration | A | R | C | I | I | C |
| Hypercare Support | A | C | R | C | I | C |
| Project Closeout & Phase 2 Roadmap | A/R | C | I | I | I | C |

**Legend:** R = Responsible | A = Accountable | C = Consulted | I = Informed

## Key Personnel

**Vendor (Amatra) Team:**
- **Engagement Lead / Senior Solution Architect:** Overall technical ownership of the platform design, agent-graph topology, architecture governance, and quality reviews across all phases. Provides technical escalation path and leads knowledge-transfer sessions.
- **Cloud Engineer:** Provisions and configures all AWS infrastructure including VPC, IAM, Cognito, DynamoDB, S3, API Gateway, and Lambda. Leads production deployment and CI/CD pipeline.
- **ML/AI Engineer:** Integrates Claude Sonnet 4.6 and Haiku 4.5 via Bedrock; designs prompt templates, retry logic, and per-phase token usage instrumentation.
- **Solutions Engineer (x2):** Implements CLI subcommands, Lambda routes, Strands agent implementations, quota enforcement, GitHub integration, and eof-tools container integration.
- **DevOps Engineer:** Builds and maintains Docker image pipeline, ECR repository, AgentCore Runtime registration, CodePipeline CI/CD, Terraform IaC modules, and CloudWatch dashboards.
- **Security Engineer:** Delivers IAM least-privilege policies, Secrets Manager rotation, VPC endpoints, GuardDuty, and security testing (IAM, Cognito, OWASP).
- **QA Engineer:** Develops test plan, executes unit/integration/load/security test phases, coordinates UAT, and produces consolidated Test Results Report.
- **Technical Writer:** Produces Architecture Design Document, operational runbooks, as-built documentation, API reference, and all knowledge-transfer materials.
- **Project Manager:** Manages schedule, RAID log, weekly status reports, stakeholder communications to Sarah Lin and Marcus Patel, and executive sponsor demonstration logistics.

**Client (PREDICTif Solutions) Team:**
- **Sarah Lin (CRO) — Executive Sponsor:** Budget owner and executive decision authority; receives weekly executive status; required for Go-Live approval and executive sponsor demonstration.
- **Marcus Patel (Director of Pre-Sales Engineering) — Technical Lead:** Primary day-to-day technical contact; accepts deliverables; participates in UAT; provides guidance on pre-sales workflow requirements and eof-tools integration.
- **Daniel Park (Head of Delivery Operations) — Delivery Stakeholder:** Secondary stakeholder for delivery-phase output; accepts runbooks and operational documentation; participates in UAT for delivery artifact types.
- **CTO — Production Sign-Off Authority:** Required gate for Cognito User Pool production deployment; reviews security design; provides final go-live approval before production Cognito User Pool is activated.
- **Client IT Lead:** Provides AWS account access, IAM approval chain, and confirms procurement trigger if new spend exceeds existing AWS spend envelope.
- **eof-tools SME:** Internal subject-matter expert for the eof-tools converter library (~30 Python modules); must be available during Phase 2 (Weeks 5–9) for integration questions.

---

# Architecture & Design

This section describes the technical architecture of the Amatra Agentic Pre-Sales Platform — a fully serverless, event-driven, multi-agent system on AWS designed for scalable, automated EO Framework document generation. The architecture follows AWS Well-Architected principles across the five pillars: Operational Excellence, Security, Reliability, Performance Efficiency, and Cost Optimisation.

## Architecture Overview

The platform is architected as a serverless multi-agent orchestration system in AWS us-west-2. At its core, Amazon Bedrock AgentCore Runtime hosts five specialised Strands agents — Input Validator, Pre-Sales Generator, Delivery Generator, Code Generator, and EO Validator — each encapsulated in a Docker container image that includes the eof-tools converter library. AWS Step Functions orchestrates the agent execution graph, enforcing the graded artifact-delivery policy and managing retry state across up to three per-artifact validation cycles. The entire generation pipeline is triggered via an API Gateway HTTP API v2, which authenticates every request through an Amazon Cognito JWT authoriser before routing to eleven Lambda handler functions.

Identity and quota governance are first-class concerns: every authenticated user has a DynamoDB profile (written eagerly via a post-confirmation Lambda trigger) with an atomic per-user monthly quota counter. A global pool counter enforces the 1,000 solutions/month hard cap using DynamoDB conditional writes, preventing race conditions at any throughput level. All output artifacts — raw markdown/CSV and converted DOCX/PPTX/XLSX — are stored in S3 and committed to a public GitHub repository via a PAT stored in Secrets Manager. The platform exposes a pip-installable CLI (14 subcommands) that wraps the HTTP API for consultant use, with full JWT authentication, credential storage, and token refresh.

Observability is built in from the start: all five agents emit per-phase token usage to CloudWatch custom metrics, surfaced in both the CLI `status` command and the `GET /admin/usage` API endpoint. CloudWatch Logs, CloudTrail data events, and GuardDuty provide the security and compliance audit trail. The Terraform IaC bundle covers all platform resources and is gated by `terraform validate` in the CI/CD pipeline.

![Figure 1: Amatra Agentic Pre-Sales Platform — Architecture Diagram](../../assets/diagrams/architecture-diagram.png)

**Figure 1: Amatra Agentic Pre-Sales Platform Architecture** — End-to-end serverless multi-agent orchestration on AWS us-west-2, showing the API layer, Cognito authentication, Step Functions orchestration, Bedrock AgentCore agents, eof-tools container pipeline, DynamoDB quota enforcement, S3 artifact storage, and GitHub commit flow.

## Component Architecture

The platform is composed of five functional layers, each with distinct AWS service responsibilities.

**API & Authentication Layer:** API Gateway HTTP API v2 serves as the single entry point for both CLI and direct API consumers. All eleven routes are protected by a Cognito JWT authoriser with a thirty-day refresh token TTL. Route-level throttling prevents any single user from saturating the Lambda concurrency pool. The post-confirmation Lambda trigger fires on every successful Cognito sign-up and eagerly writes the user's profile and initial quota counters into DynamoDB — ensuring every authenticated call has a valid quota record.

**Orchestration Layer:** AWS Step Functions hosts the solution generation state machine, which models the agent-graph as a sequence of parallel and sequential state transitions. The state machine enforces the graded artifact-delivery policy: artifacts are delivered as they are validated rather than waiting for the full bundle, and the Step Functions execution record provides a durable audit of every state transition, retry, and failure. Step Functions also manages the per-artifact retry loop (up to three iterations) and escalates unresolved failures to a Dead Letter Queue backed by SNS.

**Agent Execution Layer:** Five Bedrock AgentCore Runtime agents are registered in us-west-2. Each agent is a Strands-framework Python application packaged as a Docker image in ECR. The eof-tools converter library (~30 Python modules) is baked into the image at build time. Agent roles: Input Validator (validates brief.txt format and completeness), Pre-Sales Generator (produces five presales artifacts), Delivery Generator (produces six delivery artifacts), Code Generator (produces the Terraform IaC automation bundle), EO Validator (runs format-check and LLM quality-check with retry). Claude Sonnet 4.6 is the generation model; Claude Haiku 4.5 is the validation model — chosen for its 5× cost advantage at comparable accuracy for structured validation tasks.

**Data & Storage Layer:** DynamoDB hosts three tables: `user_profiles` (user metadata, quota counters), `solution_state` (per-solution execution state, artifact status, retry counts), and `quota_global` (global pool counter with conditional-write enforcement). S3 hosts raw artifacts under `{solution_id}/raw/` and converted Office documents under `{solution_id}/converted/`. ECR stores the five agent Docker images with vulnerability scanning enabled and lifecycle policies that retain the three most recent tagged versions. Secrets Manager holds the GitHub PAT, Cognito app client secret, and any third-party API keys with automatic rotation.

**Delivery & Observability Layer:** The GitHub integration module (a Lambda-invoked function within the Code Generator agent) commits all twelve artifacts to the public repository on solution completion. CloudWatch Logs captures structured JSON log output from all Lambda functions and AgentCore agents. Custom CloudWatch metrics track per-phase token counts, per-solution latency, and validation retry rates. GuardDuty monitors the AWS account for anomalous API activity; CloudTrail records all data-plane events on S3 and DynamoDB.

## Network Design

The platform is deployed within a purpose-built VPC in us-west-2 with three availability zones. Private subnets host all Lambda functions and AgentCore containers, with internet-bound traffic (GitHub API calls, CLI artifact downloads) routed through a NAT Gateway in a public subnet. VPC interface endpoints are provisioned for Amazon Bedrock, DynamoDB, S3, Secrets Manager, ECR, and CloudWatch Logs — keeping all internal service traffic on the AWS private network and eliminating NAT Gateway charges for high-volume Bedrock and DynamoDB interactions. API Gateway HTTP API v2 terminates at the AWS edge and does not require VPC integration; Lambda functions invoke it via the public HTTPS endpoint. Security groups restrict Lambda egress to the NAT Gateway and VPC endpoint prefixes only; no inbound rules are required given the Lambda execution model.

## Security Design

The platform implements a defence-in-depth architecture with controls at the identity, network, data, and application layers. At the identity layer, Amazon Cognito enforces password policies, MFA eligibility, and thirty-day refresh token rotation; the JWT authoriser validates every API request against the Cognito User Pool's JWKS endpoint before any Lambda handler executes. IAM execution roles follow strict least-privilege: each Lambda function and AgentCore agent has a dedicated IAM role with only the permissions required for its specific task. No wildcard resource policies exist in production.

At the network layer, all inter-service traffic uses VPC endpoints, eliminating exposure to the public internet. The NAT Gateway handles only GitHub API calls and CLI distribution traffic. Security groups implement default-deny with explicit allow rules scoped to CIDR prefix lists and service endpoints.

At the data layer, all S3 buckets enforce server-side encryption (SSE-KMS) with customer-managed keys. DynamoDB tables use AWS-managed encryption at rest. All data in transit uses TLS 1.2 or higher. Secrets Manager stores all credentials with automatic rotation schedules; no plaintext credentials exist in Lambda environment variables or container images.

At the application layer, per-artifact validation (format-check + LLM quality-check) acts as a security control against prompt injection in client briefs — malformed or adversarial inputs are rejected by the Input Validator agent before reaching generation models.

## Data Architecture

Artifacts flow through three tiers: raw generation output (markdown and CSV), converted Office documents (DOCX, PPTX, XLSX), and the Terraform IaC automation bundle. Raw artifacts are written to S3 at `{solution_id}/raw/` by each generator agent; the eof-tools converter pipeline reads from the raw tier and writes to `{solution_id}/converted/` within the same S3 bucket. Both tiers are retained for the lifetime of the solution record (default 365 days, configurable via S3 lifecycle policy).

DynamoDB data is retained indefinitely for user profiles and quota counters; solution state records are archived after 90 days via DynamoDB TTL. Point-in-time recovery (PITR) is enabled on all three DynamoDB tables, providing a 35-day recovery window. S3 versioning is enabled on the artifact bucket with a lifecycle rule that moves non-current versions to S3 Glacier after 30 days.

Data classification: all artifacts are classified as PREDICTif Confidential during generation; once committed to the public GitHub repository, they are treated as public. No personally identifiable information (PII) or regulated data enters the generation pipeline — client briefs contain engagement metadata only.

## Operational Design

Observability is built into every component. Lambda functions emit structured JSON logs to CloudWatch Logs with correlation IDs that link every log entry to a solution generation run. AgentCore agents emit per-phase token counts as CloudWatch custom metrics (`AmatraPlatform/TokenUsage`), enabling budget tracking against the $5/solution target. Step Functions execution history provides a durable audit log of every agent invocation, retry, and state transition.

CloudWatch alarms notify the operations team (via SNS) on: Lambda error rate > 1%, Step Functions execution failure rate > 2%, DynamoDB quota table throttle events > 0, and Bedrock daily token spend > 110% of budget. A CloudWatch dashboard surfaces all key operational metrics in a single pane of glass and is accessible via the `amatra status` CLI subcommand.

**RTO/RPO Targets:**
- RTO (Recovery Time Objective): 4 hours for full platform restoration from a component failure
- RPO (Recovery Point Objective): 24 hours for DynamoDB data; 0 hours for S3 artifacts (versioned, multi-AZ)
- The serverless architecture inherently provides multi-AZ redundancy for Lambda, DynamoDB, and S3

Backup strategy: DynamoDB PITR enabled (35-day window); S3 versioning with Glacier transition; ECR image lifecycle retains last three tagged versions; Secrets Manager rotation provides automatic secret backup. Runbooks cover the top five failure scenarios: agent timeout, quota table throttle, GitHub PAT expiry, Bedrock service disruption, and Cognito User Pool outage.

## Tooling Overview

The following table summarises the primary tools used across each functional category of the engagement, spanning both the AWS platform services and the open-source components that make up the Amatra agentic stack.

<!-- TABLE_CONFIG: widths=[28, 35, 37] -->
| Category | Primary Tools | Purpose |
|----------|---------------|---------|
| AI Generation | Amazon Bedrock (Claude Sonnet 4.6) | Primary artifact generation model |
| AI Validation | Amazon Bedrock (Claude Haiku 4.5) | Cost-efficient format-check and quality validation |
| Agent Framework | Strands Agents (OSS, Apache 2.0) | Multi-agent graph construction and inter-agent messaging |
| Agent Hosting | Bedrock AgentCore Runtime | Serverless hosting and invocation for all five agents |
| Orchestration | AWS Step Functions | Agent-graph execution, state management, retry policy |
| API Layer | API Gateway HTTP API v2 + Lambda | JWT-protected REST API with 11 routes |
| Authentication | Amazon Cognito User Pools | JWT issuance, refresh token management, MFA |
| Database | Amazon DynamoDB (on-demand) | User profiles, solution state, quota enforcement |
| Storage | Amazon S3 | Raw and converted artifact storage |
| Container Registry | Amazon ECR | Docker images for AgentCore agents with eof-tools |
| Secrets Management | AWS Secrets Manager | GitHub PAT, Cognito secrets, API key rotation |
| IaC | Terraform (HashiCorp) | Full-platform infrastructure provisioning |
| CI/CD | AWS CodePipeline + CodeBuild | Automated build, test, ECR push, and smoke test |
| Observability | Amazon CloudWatch | Logs, metrics, dashboards, alarms, token usage tracking |
| Security | AWS GuardDuty + CloudTrail | Threat detection and API-level audit trail |
| Networking | AWS VPC + NAT Gateway + VPC Endpoints | Private network isolation and controlled egress |
| Artifact Conversion | eof-tools (~30 Python modules) | DOCX, PPTX, XLSX converter pipeline (baked into ECR image) |
| CLI Distribution | pip (PyPI) | 14-subcommand CLI distribution to 120 consultants |
| Artifact Delivery | GitHub (public repository + PAT) | Automated artifact commit and versioning |

---

# Security & Compliance

The Amatra Agentic Pre-Sales Platform is designed with security as a foundational requirement, not an afterthought. This section describes the security architecture, compliance posture, and governance controls that protect PREDICTif's consultant identities, engagement data, and AWS infrastructure.

## Identity & Access Management

All platform access is gated by Amazon Cognito User Pools with JWT-based authentication. Every CLI invocation and API request carries a Cognito-issued JWT bearer token, validated by the API Gateway JWT authoriser before any Lambda handler executes. Tokens have a thirty-day refresh TTL with automatic rotation; access tokens expire after one hour. The post-confirmation Lambda trigger eagerly writes the user's DynamoDB profile and initialises quota counters at sign-up, ensuring no authenticated user can generate solutions without a valid quota record.

IAM roles follow strict least-privilege principles. Each Lambda function, AgentCore agent, and CI/CD pipeline component has a dedicated IAM execution role with scoped permissions — no wildcard resources, no cross-service star policies. IAM role boundaries are enforced using permission boundaries on developer and CI/CD roles to prevent privilege escalation. Role assumptions are logged via CloudTrail. Administrative access to the AWS account requires MFA and is restricted to a named break-glass IAM role.

## Monitoring & Threat Detection

AWS GuardDuty is enabled across the us-west-2 account, providing continuous threat detection for anomalous API calls, credential compromise, and network reconnaissance. CloudTrail data events are enabled for S3 (object-level reads and writes) and DynamoDB (table-level operations), providing a complete API-level audit trail for all artifact access and quota modifications. CloudWatch Logs captures structured JSON from all Lambda functions and AgentCore agents with a minimum 90-day retention period.

Security-relevant CloudWatch alarms are configured for: Cognito authentication failure spikes (potential credential stuffing), IAM policy change events (CloudTrail metric filter), GuardDuty HIGH-severity findings, and DynamoDB conditional-write failures above threshold. All alarms route to an SNS topic with email notification to the Amatra security contact and, by the end of Phase 3, to PREDICTif's nominated security contact.

## Compliance & Auditing

The platform is designed to support a SOC 2 Type II audit baseline, with controls mapped to the Trust Services Criteria (TSC) for Availability, Confidentiality, and Processing Integrity. Specific control implementations include: CloudTrail for CC7.2 (system monitoring), Cognito + JWT for CC6.1 (logical access), Secrets Manager rotation for CC6.7 (transmission and encryption), DynamoDB PITR for A1.2 (availability commitments), and IAM least-privilege for CC6.3 (access restriction).

A formal SOC 2 Type II certification is out of scope for this engagement but the control implementation provides the evidence corpus for a future audit. All CloudTrail logs are stored in a dedicated S3 bucket with object lock (WORM) enabled for a 365-day retention period, ensuring tamper-proof audit evidence.

## Encryption & Key Management

All data at rest is encrypted using AWS KMS with customer-managed keys (CMKs). S3 buckets use SSE-KMS; DynamoDB tables use AWS-managed KMS encryption. CloudWatch Logs are encrypted with a dedicated KMS key. All data in transit uses TLS 1.2 minimum — enforced via S3 bucket policy (`aws:SecureTransport` condition), API Gateway HTTPS-only listener, and DynamoDB TLS endpoint.

Secrets Manager stores the GitHub PAT, Cognito app client secret, and all other API credentials. Secrets are configured with automatic rotation schedules: the GitHub PAT rotates every 90 days via a Lambda rotation function; Cognito secrets rotate every 365 days. No plaintext credentials appear in Lambda environment variables, container image layers, or IaC state files.

## Governance

Infrastructure changes are gated by the CI/CD pipeline: all Terraform changes must pass `terraform validate` in CodeBuild before plan/apply is permitted. Pull-request-based workflow for IaC changes provides a human review gate in pre-production. CloudTrail records all AWS Console and API changes with immutable log storage. A weekly Cost Explorer report is distributed to Sarah Lin and Marcus Patel to track spend against the $100K–$200K first-year infrastructure budget.

Quota governance is enforced at the application layer: atomic DynamoDB conditional writes prevent any user from exceeding 10 solutions/month and the global pool from exceeding 1,000 solutions/month. Quota resets are performed via a scheduled Lambda function at the start of each calendar month. Administrative quota overrides require approval from Sarah Lin and are logged in DynamoDB with an audit timestamp.

## Environments & Access

### Environment Strategy

The following table defines the three deployment environments used across the engagement lifecycle, their purpose, access controls, and data classifications.

<!-- TABLE_CONFIG: widths=[15, 30, 28, 27] -->
| Environment | Purpose | Access Control | Data |
|-------------|---------|----------------|------|
| Development | Feature development, unit testing, integration experiments | Vendor engineering team only; IAM roles; no MFA required for dev-role assumption | Synthetic test data; no real client briefs |
| Staging | Integration testing, load testing, UAT, Terraform plan/apply validation | Vendor engineering team + nominated client IT lead; MFA required for staging-role assumption | Anonymised/sample client briefs; representative data volumes |
| Production | Live platform serving PREDICTif consultants; executive demo | Named individuals only; MFA mandatory; CTO sign-off required for initial activation | Real client engagement data; full encryption; CloudTrail data events enabled |

### Access Policies

Production environment access is restricted to named individuals in PREDICTif's AWS account with MFA enforcement. The Amatra vendor team retains break-glass access during the hypercare period (Weeks 13–20) via a time-limited IAM role that automatically expires. After hypercare, all vendor access is revoked and must be re-established via a formal access request process. The CI/CD pipeline uses dedicated IAM service roles with no human console access; pipeline credentials are rotated automatically via Secrets Manager.

---

# Testing & Validation

The testing strategy for the Amatra Agentic Pre-Sales Platform covers all quality dimensions from unit-level code correctness through end-to-end generation accuracy, load performance, and security posture. Testing is a formal gate for go-live — the production deployment cannot proceed without UAT sign-off and a certified green CloudWatch baseline.

## Functional Validation

Functional testing validates that each of the five agents correctly processes its inputs and produces the expected artifact outputs. Unit tests cover all agent handler functions, Lambda routes, Cognito trigger logic, quota enforcement logic, and GitHub integration module, targeting greater than 80% code coverage measured by `pytest-cov`. Integration tests execute the full five-agent pipeline end-to-end for each of the twelve artifact types, verifying that raw markdown/CSV output matches the EO Framework schema and that eof-tools converters produce well-formed DOCX, PPTX, and XLSX output.

Acceptance criteria: every artifact type passes both the deterministic format-check (schema validation) and the LLM quality-check (EO Validator agent) in no more than three retry cycles. Any artifact type that fails consistently after three retries is treated as a P1 defect and blocks go-live.

## Performance & Load Testing

Load testing simulates 200 solutions/month throughput (approximately 10 concurrent solution generations during peak usage) to validate: P95 end-to-end latency under 60 minutes, Lambda concurrency within reserved limits, DynamoDB atomic quota writes with zero throttle events under load, and per-solution Bedrock token spend within the $5 budget target. Testing is executed using AWS Lambda's concurrency test harness and DynamoDB's on-demand capacity to stress the quota-enforcement conditional-write path.

Baseline targets: P50 latency < 30 minutes, P95 latency < 60 minutes, P99 latency < 90 minutes. Any result exceeding P95 > 60 minutes triggers a performance investigation and remediation before go-live.

## Security Testing

Security testing covers the OWASP API Security Top 10 for all eleven Lambda API routes (Broken Object Level Authorisation, Broken Authentication, Excessive Data Exposure, Rate Limiting, Function Level Authorisation, Mass Assignment, Security Misconfiguration, Injection, Improper Asset Management, and Insufficient Logging). IAM policy review validates least-privilege for all execution roles. Cognito JWT token validation testing confirms that expired, tampered, or unsigned tokens are rejected at the authoriser layer. Secrets Manager access testing confirms that no Lambda function can retrieve secrets outside its designated scope. VPC endpoint validation confirms that no internal service traffic traverses the public internet.

Security testing is conducted by the Vendor Security Engineer and results are documented in the Security Test Report (Deliverable #22), which is a prerequisite for UAT sign-off.

## Disaster Recovery & Resilience Tests

DR testing validates the platform's ability to recover from the five most likely failure scenarios documented in the operational runbooks: agent timeout (Step Functions retry + DLQ alert), DynamoDB quota throttle (on-demand scale-out validated), GitHub PAT expiry (rotation procedure executed; commit resumes within 15 minutes), Bedrock service disruption (error handling and user-facing message validated), and Cognito User Pool outage (CLI and API fail gracefully with no data loss).

RTO validation: each scenario achieves restoration within the 4-hour RTO target. RPO validation: DynamoDB PITR restoration from a 24-hour-old backup is tested in staging to confirm data integrity.

## User Acceptance Testing

UAT is coordinated by the Vendor Project Manager and executed by three named client stakeholders across two scenario sets. Marcus Patel executes pre-sales workflow scenarios: generate a complete five-artifact presales bundle from a representative client brief, review artifact quality, and verify CLI usability across all fourteen subcommands. Daniel Park executes delivery workflow scenarios: generate a six-artifact delivery bundle and verify runbook and IaC bundle quality against EO Framework standards. The CTO executes the production gate scenario: activate the Cognito User Pool in production, confirm MFA enforcement, verify quota reset behaviour, and review security event visibility in CloudWatch.

UAT sign-off requires all three stakeholders to formally approve via the UAT Sign-Off form (Deliverable #23). Any P1 or P2 defect identified during UAT must be resolved before sign-off is granted. UAT is timeboxed to Week 11 to preserve the Week 12 production deployment window.

## Go-Live Readiness

The following checklist gates the production deployment decision — all items must be confirmed green before the go-live milestone is declared.

- [ ] All twelve artifact types pass end-to-end generation and validation without manual intervention
- [ ] P95 end-to-end latency confirmed < 60 minutes under 200 solutions/month load
- [ ] Per-solution Bedrock token spend confirmed ≤ $5 in load test
- [ ] Zero P1/P2 open defects
- [ ] UAT sign-off from Marcus Patel, Daniel Park, and CTO
- [ ] Green CloudWatch metrics baseline certified by DevOps Engineer
- [ ] Security Test Report accepted by Vendor Security Engineer and Client IT Lead
- [ ] All eleven Lambda routes confirmed JWT-protected in production
- [ ] DynamoDB quota enforcement confirmed atomic with no race conditions
- [ ] GitHub PAT confirmed in Secrets Manager with rotation schedule active
- [ ] Terraform IaC `terraform validate` passing in CI for all modules
- [ ] CTO sign-off for production Cognito User Pool activation obtained
- [ ] Runbooks delivered and accepted by Daniel Park
- [ ] Procurement notified if platform spend exceeds existing AWS spend envelope

## Cutover Plan

The production cutover is executed at the start of Week 12 following M5 (UAT Sign-Off). The cutover sequence runs as follows: at T-48h the final staging smoke test is completed and all go-live readiness criteria confirmed; at T-24h the DynamoDB production tables, S3 production bucket, and Cognito production User Pool are activated with CTO sign-off; at T-4h the full Terraform apply runs for the production environment and all agents are registered in AgentCore; at T-1h the production smoke test validates one complete twelve-artifact solution end-to-end including GitHub commit; at T-0 go-live is declared, the CLI package is published to PyPI, and the announcement is distributed to Marcus Patel for rollout to 120 consultants.

## Rollback Strategy

Rollback is triggered if the production smoke test fails after two attempts, a P1 security vulnerability is discovered post-deployment, or the CTO withholds go-live sign-off. The rollback procedure: Lambda function versions are rolled back to the last stable deployment using Lambda aliases; AgentCore agents are re-registered with the previous container image tag from ECR; DynamoDB tables are restored from PITR if any data corruption is detected; the production Cognito User Pool is deactivated. Full rollback is estimated at 2 hours. The previous production-equivalent staging environment remains fully operational throughout the cutover window to serve as a clean rollback target.

---

# Handover & Support

This section defines all knowledge-transfer activities, documentation deliverables, and post-go-live support arrangements that ensure PREDICTif's Amatra team can operate and evolve the platform independently after the engagement concludes.

## Handover Artifacts

The following complete set of artifacts is delivered to PREDICTif as part of the formal handover at the end of Week 12:

- **Architecture Design Document:** Full system architecture, component descriptions, data-flow diagrams, agent-graph topology, and Architecture Decision Records (ADRs) for all major design choices
- **API Reference (OpenAPI 3.0):** Complete specification for all eleven Lambda routes, request/response schemas, JWT authorisation requirements, and error codes
- **Deployment Guide:** Step-by-step instructions for deploying the platform from scratch using Terraform, including pre-requisite account setup, Cognito configuration, and AgentCore registration
- **Operational Runbooks:** Five scenario runbooks covering agent timeout, quota throttle, GitHub PAT expiry, Bedrock disruption, and Cognito outage — each with diagnosis steps, remediation procedure, and escalation path
- **Environment Variable Reference:** Complete list of all Lambda environment variables, Secrets Manager secret names, and DynamoDB table names across dev, staging, and production
- **eof-tools Integration Guide:** Documentation of how eof-tools is baked into the ECR container image, how to update the library version, and how to add new artifact types
- **Code Repository (GitHub):** All source code (agent implementations, Lambda handlers, CLI, Terraform modules, test suites) with README files and inline documentation
- **Test Results Report:** Consolidated results from unit, integration, load, security, and UAT phases including coverage metrics, UAT sign-off records, and CloudWatch baseline screenshots
- **Optimisation Recommendations & Phase 2 Roadmap:** Documented opportunities for cost optimisation, multi-region expansion, advanced analytics, and Haiku 4.5 cost tuning

## Knowledge Transfer

Two formal knowledge-transfer sessions are delivered in Week 12 to ensure PREDICTif's teams can operate, support, and build on the platform independently.

**Engineering Deep-Dive (4 hours, recorded):** Targeted at PREDICTif's Amatra engineering team and AWS account owners. Covers agent architecture and Strands framework patterns, Lambda route implementation and JWT authorisation, DynamoDB quota enforcement design, CI/CD pipeline and ECR image management, Terraform module structure and deployment, CloudWatch dashboards and alarm configuration, and eof-tools container update procedures. The session is recorded and uploaded to S3 for future onboarding use.

**Pre-Sales Workflow Training (2 hours):** Targeted at Marcus Patel's 120 distributed consultants using a train-the-trainer approach. Covers CLI installation and authentication (`pip install amatra-cli`), the fourteen subcommand reference, solution generation workflow, artifact review and download, quota management, and troubleshooting common errors. Training materials (slide deck, quick-reference card, CLI cheat sheet) are delivered as part of the documentation package.

## Hypercare Support

An eight-week hypercare support period is included following the Go-Live milestone (Weeks 13–20), providing hands-on assistance during the ramp-up to steady-state 200 solutions/month throughput.

- **Coverage:** Business hours (Monday–Friday, 8 AM–6 PM Pacific Time) with P1 emergency response extended to 24×7
- **Response Times:** P1 (platform down / data loss) — 1 hour; P2 (major functionality impaired) — 4 business hours; P3 (non-critical issue or question) — next business day
- **Scope:** Bedrock quota monitoring and tuning, agent failure triage and recovery, validation retry rate investigation, CloudWatch alarm response, quota counter adjustment, GitHub PAT rotation support, and minor bug fixes in production
- **Out of Scope During Hypercare:** New feature development, additional artifact types, multi-region expansion, or changes to the Cognito User Pool beyond those required for bug fixes
- **Escalation Path:** Marcus Patel (primary) → Sarah Lin (executive escalation) → Amatra Engagement Lead (vendor-side resolution)
- **Hypercare Conclusion:** At Week 20, the Optimisation Recommendations and Phase 2 Roadmap are delivered, and responsibility for the platform transfers fully to PREDICTif's nominated operations team.

## Managed Services Transition

Ongoing managed services are not included in this engagement. Refer to a separate Managed Services Agreement with PREDICTif if ongoing operations, SLA-backed support, and proactive cost optimisation are required beyond the eight-week hypercare period.

## Assumptions

The following assumptions underpin the scope, schedule, and commercial terms of this SOW. Failure to satisfy any of these assumptions may require a scope change or schedule adjustment.

1. PREDICTif will provide AWS account access (console and programmatic) in the new us-west-2 account within five business days of contract execution.
2. The Amatra vendor team will have sufficient IAM permissions to provision all required AWS services, including Bedrock, AgentCore Runtime, Cognito, DynamoDB, S3, Lambda, API Gateway, ECR, Step Functions, Secrets Manager, CloudWatch, and VPC resources.
3. CTO sign-off on the Cognito User Pool design will be obtained by the end of Week 3 to avoid blocking Phase 1 completion.
4. Marcus Patel (or a named delegate) will be available for at least 4 hours per week during Weeks 1–12 for design reviews, deliverable acceptance, and UAT participation.
5. The eof-tools SME will be available for a minimum of two full days during Phase 2 (Weeks 5–9) to support container integration questions.
6. The existing eof-tools converter library is stable and passes all self-tests in a containerised Linux environment; no library refactoring is required.
7. PREDICTif's public GitHub repository is already provisioned and the Amatra team will be granted write access via a stored PAT.
8. The Claude Sonnet 4.6 and Haiku 4.5 model versions are available in the Bedrock us-west-2 region with sufficient quota for 200 solutions/month at the start of Phase 2.
9. Bedrock AgentCore Runtime is generally available in us-west-2 at the time of Phase 2 kickoff (Week 5).
10. PREDICTif's procurement team will be notified before Phase 2 begins if the projected AWS spend is expected to exceed the existing AWS spend envelope.
11. All stakeholder approvals (CTO sign-off, UAT sign-off) will be provided within five business days of the vendor requesting them; delays beyond five business days may impact the April 2026 deadline.
12. PREDICTif will designate a named AWS account owner and IAM approver before Week 1 kickoff.
13. The four core capabilities (CLI auth, presales generation, delivery generation, Terraform IaC bundle) are in scope; additional capabilities identified during the engagement will be deferred to a Phase 2 SOW.
14. English is the sole language for all generated artifacts; no internationalisation or multi-language support is required.
15. No HIPAA, PCI-DSS, or FedRAMP compliance requirements apply to the platform; SOC 2 Type II baseline controls are sufficient.

## Dependencies

The following critical dependencies must be resolved by the dates shown to avoid impact to the twelve-week schedule and the April 2026 hard deadline.

<!-- TABLE_CONFIG: widths=[32, 18, 15, 35] -->
| Dependency | Owner | Required By | Notes |
|------------|-------|-------------|-------|
| AWS us-west-2 account access provisioned | Client IT Lead | Week 1, Day 1 | Blocks all Phase 1 activities |
| IAM permission boundary scope confirmed | Client IT Lead | Week 1 | Unblocks Landing Zone setup |
| CTO Cognito sign-off obtained | CTO | Week 3 | Gates Phase 1 completion milestone |
| eof-tools SME availability confirmed | Marcus Patel | Week 5 | Gates Phase 2 container integration |
| Bedrock AgentCore GA availability in us-west-2 | AWS | Week 5 | Architecture feasibility validated in Phase 1 |
| Bedrock quota (Sonnet 4.6 + Haiku 4.5) confirmed | Client IT Lead | Week 5 | Quota request must be raised with AWS in Week 1 |
| Public GitHub repository access (write) granted | PREDICTif | Week 7 | Gates GitHub integration deliverable |
| UAT participants available (Marcus, Daniel, CTO) | Marcus Patel | Week 11 | UAT sign-off is a go-live gate |
| Procurement notification for AWS spend envelope | Marcus Patel | Week 4 | If Phase 2 spend projected to exceed envelope |
| Executive sponsor demonstration slot confirmed | Sarah Lin | Week 8 | Locks in April 2026 deadline logistics |

---

# Investment Summary

This engagement is priced at the **Large** complexity tier, reflecting the five-agent orchestration platform, twelve artifact types, fourteen CLI subcommands, eleven API routes, three-environment deployment, and fixed twelve-week timeline with a hard April 2026 delivery deadline. The investment figures below reconcile directly with the infrastructure-costs.csv (3-Year Summary) and level-of-effort-estimate.csv totals for this solution.

## Total Investment

The table below presents the complete three-year investment summary, with Year 1 figures reflecting both list pricing and the AWS partner credits available to PREDICTif. Cloud infrastructure figures are drawn directly from the infrastructure-costs.csv 3-Year Summary; professional services figures reconcile with the level-of-effort-estimate.csv total hours and blended rates.

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[24, 13, 14, 13, 10, 10, 13] -->
| Cost Category | Year 1 List | Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------|------------|--------|--------|--------------|
| Professional Services | $250,000 | ($30,000) | $220,000 | $0 | $0 | $220,000 |
| Cloud Infrastructure | $88,920 | ($30,000) | $58,920 | $110,466 | $143,606 | $313,992 |
| Software Licenses | $0 | $0 | $0 | $0 | $0 | $0 |
| Support & Maintenance | $8,880 | $0 | $8,880 | $10,656 | $12,787 | $32,323 |
| **TOTAL INVESTMENT** | **$347,800** | **($60,000)** | **$287,800** | **$121,122** | **$156,393** | **$566,315** |
<!-- END COST_SUMMARY_TABLE -->

*Note: Year 2 and Year 3 infrastructure costs reflect projected growth at 1.3× Year 1 Bedrock volume (Sonnet 4.6 + Haiku 4.5) and 1.5× Cognito MAU growth as the 120-consultant user base reaches full adoption. Professional Services are a one-time engagement cost — no recurring PS spend in Years 2 or 3. The 3-year infrastructure-only total of $345,315 is sourced directly from infrastructure-costs.csv.*

## Partner Credits

Three AWS credit programmes are available to PREDICTif for Year 1, totalling **$30,000 in infrastructure credits** and **$30,000 in professional-services credits** — reducing the net Year 1 investment from $347,800 to **$287,800**:

**Infrastructure Credits ($30,000 applied to cloud spend):**
- **AWS Activate Portfolio Credit ($10,000):** Applied as a net-new AWS workload in us-west-2. Eligible as a first-time Bedrock + AgentCore deployment in the region.
- **AWS Migration Acceleration Program (MAP) Credit ($15,000):** Applied to the migration from manual on-premises CLI workflow to AWS-native serverless architecture.
- **Amazon Bedrock Early Adopter Credit ($5,000):** AgentCore Runtime GA launch credit for early-adopter AWS partners building on Bedrock generative AI services.

**Professional Services Credits ($30,000 applied to engagement fees):**
- **AWS Partner Network (APN) Services Credit ($15,000):** APN Advanced Tier Partner credit for AWS AI/ML solution builds using Bedrock and AgentCore Runtime.
- **AWS Bedrock Launch Partner Incentive ($5,000):** Early adopter incentive for AgentCore Runtime, applicable to new platform builds in Year 1.
- **Implementation Volume Discount ($10,000):** 4% volume discount on professional services for engagements exceeding $200K — applied as a strategic PREDICTif / Amatra deal incentive.

All credits are contingent on standard AWS programme approval. The Amatra team manages all credit application paperwork through the AWS Advanced Consulting Partner channel.

## Cost Components

**Professional Services ($250,000 list / $220,000 net):**
The LOE estimate covers five phases across twelve resource types. Key effort drivers are the multi-agent Strands/AgentCore implementation (Phase 2, ~500 hours across Solutions Engineers and ML/AI Engineers), the Terraform IaC full-platform build (~62 hours DevOps), and the eight-week hypercare period (~80 hours Support Engineer). Management overhead (Technical Leadership + Project Management at 10% of engineering hours each) adds approximately 200 hours at blended senior rates. Total LOE across all phases is approximately 1,400 hours at a blended rate of approximately $179/hour, reconciling with the $250,000 list price.

**Cloud Infrastructure ($88,920 Year 1 list):**
The largest Year 1 infrastructure cost driver is Amazon Bedrock — Claude Sonnet 4.6 at $54,000/year and Haiku 4.5 at $10,200/year — at the 200 solutions/month steady-state target. AgentCore Runtime adds $14,400/year. Supporting services (Lambda, API Gateway, Cognito, DynamoDB, S3, ECR, CloudWatch, Secrets Manager, VPC/NAT, Step Functions, Data Transfer, AWS Business Support) total approximately $10,320/year. These figures match the line items in infrastructure-costs.csv. Year 2–3 costs grow as Bedrock volume scales with solution throughput; the infrastructure is designed to scale linearly with no architectural changes required, reaching a 3-year infrastructure total of $345,315.

**Software Licenses ($0):**
Strands Agents is open-source (Apache 2.0). The eof-tools library is an existing internal asset. The PyPI CLI distribution has no incremental cost. GitHub public repository has no additional cost. All license costs are $0 as reflected in the infrastructure-costs.csv Software Licenses rows.

**Support & Maintenance ($8,880 Year 1):**
AWS Business Support at approximately 10% of monthly AWS spend covers Lambda, Bedrock, AgentCore, DynamoDB, Cognito, and S3 on the critical path. Includes Trusted Advisor, AWS Health Dashboard, and access to a Technical Account Manager (TAM) during the hypercare period. Support costs grow to $10,656 in Year 2 and $12,787 in Year 3 as the platform's monthly AWS spend increases, for a 3-year support total of $32,323.

## Payment Terms

Professional services are invoiced against milestones as follows:

| Milestone | Invoice Trigger | Amount |
|-----------|----------------|--------|
| M1 – Contract Execution & Kickoff | Countersigned SOW received | $50,000 (20%) |
| M2 – Foundation Live (Week 4) | Foundation Infrastructure Acceptance Report accepted by Marcus Patel | $75,000 (30%) |
| M4 – Agent Integration Complete (Week 9) | Agent Integration Milestone Report accepted | $75,000 (30%) |
| M7 – Go-Live (Week 12) | Production Deployment Confirmation + UAT Sign-Off received | $50,000 (20%) |

Cloud infrastructure costs are invoiced directly by AWS to PREDICTif's AWS account on a monthly consumption basis. Credits are applied by AWS as they are allocated; the Amatra team will provide credit application reference numbers within 10 business days of contract execution.

## Invoicing & Expenses

Invoices are issued within five business days of each milestone trigger event and are payable within thirty days of invoice receipt. Payment is accepted via bank transfer; wire transfer details are provided with the first invoice. All amounts are in USD and exclusive of applicable taxes.

Reimbursable expenses (travel, accommodation, on-site working sessions) are not anticipated for this engagement given the distributed remote delivery model. Any travel required for the executive sponsor demonstration will be agreed in advance and invoiced at cost with receipts, subject to a pre-approved expense cap of $2,500.

---

# Terms & Conditions

## General Terms

This Statement of Work is entered into under and subject to the terms of the Master Services Agreement (MSA) executed between PREDICTif Solutions and Amatra (or its parent consulting entity). In the event of any conflict between this SOW and the MSA, the MSA shall prevail except where this SOW expressly states that it supersedes a specific MSA provision. If no MSA is currently in place, the parties agree to execute an MSA concurrently with this SOW, and the standard Amatra MSA terms shall apply.

## Scope Changes

Any change to the scope, timeline, or commercial terms of this SOW must be processed via a formal Change Request (CR). The requesting party submits a written CR describing the proposed change; the vendor provides an impact assessment (effort, cost, timeline) within five business days; the change becomes effective only upon written approval from both parties' authorised signatories. Verbal agreements do not constitute a scope change. The vendor reserves the right to pause delivery of affected work items pending CR approval if a requested change materially impacts the critical path.

## Intellectual Property

All deliverables produced under this SOW — including deployed systems, Terraform IaC modules, Lambda function code, CLI package, agent implementations, documentation, and training materials — are the sole property of PREDICTif Solutions upon full payment of all invoices. The vendor retains ownership of its pre-existing methodologies, frameworks, tools, and the EO Framework standards. The eof-tools library remains PREDICTif property as an existing asset. The Strands Agents framework remains open-source under Apache 2.0. The vendor is granted a non-exclusive, royalty-free licence to reference the engagement as a case study (without disclosing confidential client data) for marketing purposes, subject to PREDICTif's prior written approval.

## Service Levels

The vendor warrants that all deliverables will conform to the acceptance criteria defined in this SOW for a period of ninety (90) days following the Go-Live milestone. During the warranty period, the vendor will remediate any defects in deliverables at no additional charge. The warranty does not cover defects caused by: changes to the AWS platform outside the vendor's control (e.g., Bedrock API version changes), PREDICTif modifications to the delivered systems, or changes to the eof-tools library by PREDICTif after handover. Post-warranty support is available under the separate Managed Services Agreement or via time-and-materials engagement.

## Liability

The vendor's aggregate liability under this SOW shall not exceed the total professional services fees paid by PREDICTif under this SOW. Neither party shall be liable for indirect, incidental, consequential, special, or punitive damages, regardless of the form of action or the theory of recovery. The vendor carries professional indemnity insurance of not less than $2,000,000 per occurrence; certificates of insurance are available on request. AWS infrastructure costs billed directly to PREDICTif's AWS account are not subject to vendor liability caps.

## Confidentiality

Both parties shall maintain the confidentiality of the other party's Confidential Information (defined as any non-public information disclosed in connection with this SOW) and shall not disclose it to any third party without prior written consent. Confidential Information does not include information that is publicly available, already known to the receiving party, independently developed, or required to be disclosed by law. Obligations of confidentiality survive termination of this SOW for a period of three (3) years. Each party shall implement reasonable technical and organisational measures to protect the other's Confidential Information.

## Termination

Either party may terminate this SOW for convenience upon thirty (30) days' written notice. In the event of termination for convenience, PREDICTif shall pay for all services rendered up to the date of termination, including any non-cancellable third-party costs incurred by the vendor on PREDICTif's behalf. Either party may terminate for material breach if the breaching party fails to cure the breach within fifteen (15) business days of written notice. Upon termination, the vendor shall deliver all work-in-progress deliverables to PREDICTif and securely delete all PREDICTif Confidential Information from vendor systems within thirty (30) days.

## Governing Law

This SOW and any dispute arising under it shall be governed by the laws of the State of Washington, USA, without regard to its conflict-of-law provisions. Any dispute that cannot be resolved by good-faith negotiation within thirty (30) days shall be submitted to binding arbitration under the rules of the American Arbitration Association (AAA) in Seattle, Washington. The prevailing party in any arbitration shall be entitled to recover reasonable attorneys' fees and costs.

---

# Sign-Off

By signing below, both parties confirm they have read, understood, and agreed to the scope, deliverables, roles, investment, and terms outlined in this Statement of Work. This document, together with the executed Master Services Agreement, constitutes the complete and binding agreement between the parties for the services described herein.

---

**Client Authorised Signatory — PREDICTif Solutions:**

Name: __________________________
Title: __________________________
Signature: ______________________
Date: __________________________

**Executive Sponsor Acknowledgement:**

Name: Sarah Lin
Title: Chief Revenue Officer, PREDICTif Solutions
Signature: ______________________
Date: __________________________

---

**Service Provider Authorised Signatory — Amatra:**

Name: __________________________
Title: __________________________
Signature: ______________________
Date: __________________________

**Technical Lead Acknowledgement:**

Name: Marcus Patel
Title: Director of Pre-Sales Engineering, PREDICTif Solutions
Signature: ______________________
Date: __________________________

---

*This Statement of Work constitutes the complete agreement between PREDICTif Solutions and Amatra for the services described herein and supersedes all prior negotiations, representations, or agreements relating to the Amatra Agentic Pre-Sales Platform engagement. Any amendment must be made in writing and signed by authorised representatives of both parties.*

*Document Version: 1.0 | Opportunity: OPP-2026-001 | Generated by EO Framework Pre-Sales Generator*
