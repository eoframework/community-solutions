---
document_title: Detailed Design Document
solution_name: AWS Agentic Pre-Sales Orchestration Platform
document_version: "1.0"
author: Amatra EO Framework Practice — Solution Architect
last_updated: 2025-06-01
technology_provider: aws
client_name: PREDICTif Solutions
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Detailed Design Document provides the complete technical blueprint for the design, build, and deployment of the **AWS Agentic Pre-Sales Orchestration Platform** for PREDICTif Solutions. It translates the commitments made in the Statement of Work (SOW) into implementation-ready specifications covering architecture, security, data, integrations, infrastructure, and delivery sequencing. Every component, integration point, and security control described herein traces directly to the SOW scope and the Solution Briefing presented to PREDICTif's executive leadership.

The platform replaces PREDICTif's entirely manual pre-sales documentation workflow — which currently consumes six to ten hours of senior-consultant time per engagement — with a serverless, five-agent orchestration engine built on AWS Bedrock AgentCore Runtime and the Strands Agents framework. Upon completion, the platform will produce all twelve EO Framework artifacts per engagement (five presales, six delivery, and one Terraform automation bundle) in under sixty minutes, with no human in the loop during generation. Target per-engagement senior-consultant effort is reduced to under one hour of review and approval activity.

This document is the authoritative reference for the Amatra vendor engineering team, PREDICTif's internal IT leads (Marcus Patel and Daniel Park), and the CTO who must provide sign-off on Cognito User Pool provisioning and production deployment. All architecture decisions are captured here alongside the Architecture Decision Records (ADRs) produced in Phase 1. The document must be read in conjunction with the SOW, the Infrastructure Costs analysis, and the Level-of-Effort Estimate.

## Purpose

This document defines the target-state architecture, component specifications, security controls, data model, integration patterns, infrastructure configuration, and implementation sequencing for the AWS Agentic Pre-Sales Orchestration Platform. It serves as the primary technical reference for the vendor engineering team during build, as the acceptance baseline for Marcus Patel's formal deliverable reviews, and as the as-built foundation for operational handover at go-live.

## Scope

**In-scope:**

- Five-agent Strands multi-agent graph registered in AWS Bedrock AgentCore Runtime (Input Validator, Pre-Sales Generator, Delivery Generator, Code Generator, EO Validator)
- API Gateway HTTP API v2 with eleven Lambda routes, JWT Cognito authoriser, CORS configuration, and request throttling
- Amazon Cognito User Pool with JWT issuance, 30-day refresh tokens, post-confirmation trigger Lambda, and DynamoDB profile write
- Per-artifact deterministic format-check plus LLM quality-check validation loop with up to three automatic retries per artifact across all twelve artifact types
- Pip-installable CLI with fourteen subcommands including auth, generate, status (with per-phase token usage), and admin
- DynamoDB schema and atomic quota enforcement: per-user (10 solutions/month) and global (1,000 solutions/month) with admin override
- eof-tools converter library integration (~30 Python modules) baked into agent Docker image via Amazon ECR
- GitHub PAT-based automated artifact commit pipeline via AWS Secrets Manager
- Terraform Infrastructure-as-Code modules for all platform infrastructure with `terraform validate` syntax gate
- CloudWatch dashboards, alarms, per-phase token-usage metrics; X-Ray tracing on all seventeen Lambda functions
- CI/CD pipeline (GitHub Actions or CodePipeline): Docker build, ECR push, Lambda deploy, and Terraform validate gate
- Development and Production environments in AWS us-west-2

**Out-of-scope:**

- Development of net-new eof-tools converter modules (existing ~30 modules integrated as-is)
- Multi-region deployment or active-active redundancy (us-west-2 single-region only)
- Mobile application or browser-based UI (CLI and HTTP API surfaces only)
- Integration with PREDICTif's existing us-east-1 managed-services workloads
- SIEM/SOC integration beyond GuardDuty and Security Hub baseline
- PCI-DSS, HIPAA, or FedRAMP compliance certification (SOC 2 readiness only)
- Migration of existing OneDrive artifacts to the new platform
- Phase 2 scope: multi-region HA, additional artifact types, advanced Bedrock model routing

## Assumptions & Constraints

- PREDICTif Solutions provides a dedicated AWS account in us-west-2 with Bedrock service quota pre-approved (AgentCore Runtime, Claude Sonnet 4.6, and Claude Haiku 4.5 token throughput) before Week 1.
- CTO sign-off on Cognito User Pool provisioning is obtained no later than end of Week 3 to avoid blocking the Phase 1 completion milestone.
- A GitHub repository (public or private) and a GitHub Personal Access Token with repo-write scope are provisioned by PREDICTif before Week 5.
- The existing eof-tools converter library (~30 Python modules) is provided to the vendor team in its current state before Phase 2 begins; no refactoring or bug-fixing of the eof-tools library is in scope.
- PREDICTif provides a minimum of five representative client briefs as test inputs for agent prompt tuning and UAT in Phase 2.
- AWS Bedrock AgentCore Runtime is generally available (not in preview with restricted access) in us-west-2 before Phase 2 start.
- The three-environment strategy uses a single AWS account with environment-level resource naming and IAM boundaries; separate account provisioning is not required for PoC.
- All Amatra consultants have corporate email addresses eligible for Cognito User Pool registration; no SSO/SAML federation is required for PoC.
- The hard project deadline is end of April 2026 (Q2 2026).

## References

- Statement of Work — AWS Agentic Pre-Sales Orchestration Platform (Version 1.0, June 2025)
- Solution Briefing — AWS Agentic Pre-Sales Orchestration Platform (EO Framework Pre-Sales Deck)
- Infrastructure Costs Analysis — infrastructure-costs.csv
- Level-of-Effort Estimate — level-of-effort-estimate.csv
- AWS Bedrock AgentCore Runtime Documentation
- Strands Agents Framework Documentation
- EO Framework Guidance Files (S3 guidance bucket)

---

# Business Context

PREDICTif Solutions operates an internal practice called Amatra, comprising approximately 120 consultants across the United States and Canada who specialise in managed services and pre-sales engineering for AWS partner solutions. Each pre-sales engagement today requires six to ten hours of senior-consultant time involving repeated manual LLM prompting through the Claude Code CLI, ad-hoc validation cycles, manual file management, and manual copy of artifacts into customer repositories. This manual workflow creates a hard scale bottleneck: consultant headcount growth does not translate to proportional pipeline throughput growth. The AWS Agentic Pre-Sales Orchestration Platform is designed to eliminate this bottleneck by automating the entire generation-validation-delivery workflow, reducing per-engagement senior-consultant involvement to under one hour of review and approval.

## Business Drivers

- **Scale bottleneck elimination:** The current manual workflow prevents Amatra from running parallel pipeline across multiple concurrent engagements. The platform's agentic architecture enables simultaneous generation across multiple solutions, directly translating headcount growth into pipeline velocity.
- **Quality consistency:** Today's manual workflow produces inconsistent artifact quality — no deterministic format-gate, no LLM quality scoring, and no structured retry loop. The platform's EO Validator agent applies format-check rules and Claude Haiku 4.5 quality scoring against every artifact with up to three automatic retries, targeting a ≥95% first-attempt pass rate.
- **Cost visibility and governance:** There is currently no per-engagement cost attribution, no CloudWatch metrics, and no audit trail. The platform's per-phase token usage tracking in DynamoDB — surfaced in the CLI `status` subcommand and the admin `/usage` endpoint — provides granular cost attribution for every solution, enabling SOC 2 vendor risk management and Bedrock spend governance.
- **Auditability and compliance:** The current OneDrive folder model produces zero audit trail. The platform implements CloudTrail management and data events, DynamoDB audit_events records, and GitHub commit history per solution, replacing ad-hoc file management with an immutable delivery audit trail.
- **Executive demonstration deadline:** Sarah Lin (CRO) requires a demonstrable platform by end of April 2026, covering four core capabilities: CLI auth, presales generation, delivery generation, and Terraform automation bundle. This hard deadline drives the twelve-week delivery schedule and milestone sequencing.

## Workload Criticality & SLA Expectations

The platform is the primary vehicle through which Amatra consultants produce pre-sales packages for customer engagements. Outages or quality failures directly impact PREDICTif's revenue pipeline. The following SLA targets are derived from the SOW success metrics and must be validated in Phase 3 testing before production go-live approval.

<!-- TABLE_CONFIG: widths=[28, 24, 24, 24] -->
| Metric | Target | Measurement Method | Priority |
|--------|--------|--------------------|----------|
| API Availability | ≥ 99.5% monthly | CloudWatch Lambda error rate alarm | Critical |
| End-to-End Generation Time | ≤ 60 minutes per 12-artifact bundle | CloudWatch duration metric (E2E) | Critical |
| Artifact Validation Pass Rate | ≥ 95% on first attempt | EO Validator DynamoDB metrics | High |
| API Gateway P99 Latency | ≤ 3 seconds (synchronous routes) | CloudWatch API Gateway latency | High |
| Per-Solution Bedrock Cost | < $5 at 200 solutions/month steady state | DynamoDB per-phase token usage | High |
| DynamoDB Quota Op Latency | < 50ms P99 | CloudWatch DynamoDB latency | Medium |
| RTO | 4 hours | DR PITR restore test (Phase 3) | Critical |
| RPO | 1 hour | DynamoDB PITR continuous backup | Critical |

## Compliance & Regulatory Factors

- **SOC 2 Type II readiness:** The platform implements CloudTrail audit logging, DynamoDB audit_events records, per-phase token usage attribution, and IAM least-privilege design aligned with SOC 2 CC6 (Logical and Physical Access) and CC7 (System Operations) criteria.
- **Data residency:** All data is stored in AWS us-west-2 only. There is no cross-region data replication in scope for PoC.
- **Data classification:** All artifacts are classified as PREDICTif Internal. No customer PII or regulated data is processed; the platform operates on consultants' own work product.
- **PCI-DSS, HIPAA, FedRAMP:** Explicitly out of scope for PoC. To be assessed in Phase 2 if required by PREDICTif's enterprise clients.

## Success Criteria

- End-to-end artifact generation time ≤ 60 minutes for a full twelve-artifact solution bundle, verified in Phase 3 load testing.
- Per-engagement senior-consultant effort ≤ 1 hour (90% reduction from current 6–10 hours), measured from pilot go-live.
- Per-solution Bedrock model spend < $5 at 200 solutions/month steady-state throughput, validated in Phase 3 load test.
- Artifact validation pass rate ≥ 95% on first attempt across all twelve artifact types.
- Zero quota bypass incidents during security testing (per-user and global atomic quota enforcement in DynamoDB).
- Green CloudWatch metrics baseline demonstrated in the Phase 3 executive demo for Sarah Lin.
- All twelve artifact types pass deterministic format-check AND LLM quality validation with ≤ 3 retries.
- CTO sign-off on Cognito User Pool and production deployment obtained before go-live.

---

# Current-State Assessment

PREDICTif Solutions currently produces EO Framework solution packages entirely manually using the Claude Code CLI on individual consultant laptops. There is no centralised orchestration platform, no per-user identity or quota management, no automated validation or retry logic, and no structured audit trail. This section documents the existing workflow and infrastructure that the AWS Agentic Pre-Sales Orchestration Platform will replace, providing the baseline against which the 90% effort-reduction target is measured.

## Application Landscape

The current-state tooling consists of a small set of local and cloud-based tools stitched together manually by each consultant. There is no shared platform state, no API surface, and no programmatic orchestration between tools.

<!-- TABLE_CONFIG: widths=[28, 30, 22, 20] -->
| Application | Purpose | Technology | Disposition |
|-------------|---------|------------|-------------|
| Claude Code CLI | LLM-driven artifact generation via iterative prompting | Anthropic Claude API (direct) | Replace with Bedrock AgentCore |
| eof-tools converter scripts | Convert raw MD/CSV artifacts to DOCX/PPTX/XLSX | Python (~30 modules): python-docx, openpyxl, python-pptx | Integrate as-is into Docker image |
| OneDrive folder | Artifact storage and sharing | Microsoft OneDrive | Replace with S3 + GitHub |
| Manual validation scripts | Ad-hoc format checks (inconsistent per consultant) | Ad-hoc Python scripts | Replace with EO Validator agent |
| Email / Slack | Stakeholder notifications and delivery | Email, Slack | Replace with SNS + GitHub commit |

## Infrastructure Inventory

The current-state infrastructure is laptop-centric with no shared cloud footprint for the pre-sales workflow. The AWS resources described below are the existing managed-services workloads in us-east-1 that will not be touched by this engagement.

<!-- TABLE_CONFIG: widths=[22, 15, 33, 30] -->
| Component | Quantity | Specifications | Notes |
|-----------|----------|----------------|-------|
| Consultant laptops | ~120 | macOS/Windows, Claude Code CLI installed | Per-consultant; no shared state |
| us-east-1 AWS account | 1 | Existing managed-services workloads | Isolated; no integration in scope |
| OneDrive tenant | 1 | PREDICTif corporate OneDrive | Replaced by S3 + GitHub |
| GitHub (existing) | 1 | PREDICTif existing repositories | New repo required for artifact delivery |

## Dependencies & Integration Points

- **Claude Code CLI → Anthropic API:** Direct API calls without AWS Bedrock; no quota enforcement, no cost tracking.
- **eof-tools library → Consultant laptop Python runtime:** Executed locally; no container packaging, no CI/CD.
- **OneDrive → Manual copy to engagement repository:** No structured versioning, no commit attribution.
- **Validation → Manual re-prompt:** Consultant manually re-prompts CLI on validation failure; typically three to four iterations per artifact.

## Network Topology

The current-state network topology is entirely internet-egress from consultant laptops. There is no VPC, no private networking, no VPC endpoints, and no network-level isolation between the pre-sales workflow and the us-east-1 managed-services environment. The new us-west-2 platform will implement a fully defined VPC topology with private subnets, VPC endpoints, and NAT Gateway as detailed in the Infrastructure & Operations section.

## Security Posture

The current security posture has significant gaps that the new platform directly addresses:

- **Authentication:** No identity management; any consultant with the Anthropic API key can generate unlimited artifacts.
- **Quota enforcement:** No per-user or global quota; no cost attribution; unbounded Bedrock API spend risk.
- **Secrets management:** API keys stored in local environment variables or `.env` files; no rotation; no access logging.
- **Audit trail:** Zero audit trail; no record of who generated what artifact, when, or at what cost.
- **Data protection:** Artifacts stored in OneDrive with no encryption at rest beyond Microsoft's platform defaults; no object versioning.

## Performance Baseline

- Average per-engagement artifact generation time: 6–10 hours (senior-consultant active time)
- Peak concurrent engagements: Limited by consultant availability; typically 1–2 per consultant
- Manual validation retry iterations: 3–4 per artifact on average
- Artifact delivery lead time: 1–3 business days from generation to customer delivery

## Gap Analysis

The following gap analysis summarises the delta between the current manual workflow and the target agentic platform that this engagement will close.

<!-- TABLE_CONFIG: widths=[33, 34, 33] -->
| Current State | Gap | Target State |
|---------------|-----|--------------|
| Manual Claude Code CLI; no orchestration | No multi-agent orchestration; no retry automation | Five-agent Strands graph on Bedrock AgentCore Runtime |
| No identity or access management | No JWT auth, no quota enforcement, no roles | Amazon Cognito + API Gateway JWT authoriser + DynamoDB quotas |
| Ad-hoc local validation scripts | No deterministic format-check; no LLM quality gate | EO Validator: format-check + Haiku 4.5 quality scoring; ≤3 retries |
| eof-tools run locally per consultant | No shared container; no versioned converter pipeline | eof-tools baked into Docker image; ECR registry; CI/CD pipeline |
| OneDrive artifact storage; no versioning | No structured S3 path; no commit history | S3 with versioning + GitHub automated commit per solution |
| Zero audit trail | No CloudTrail, no cost attribution, no DynamoDB log | CloudTrail + DynamoDB audit_events + per-phase token usage |
| Manual cutover to customer repo | No GitHub integration; manual copy-paste | GitHub PAT automated commit pipeline via Secrets Manager |
| No observability | No CloudWatch, no X-Ray, no token metrics | CloudWatch dashboards + X-Ray tracing + token usage in CLI status |

---

# Solution Architecture

The AWS Agentic Pre-Sales Orchestration Platform is designed as a cloud-native, serverless solution on AWS us-west-2, centred on a five-agent Strands multi-agent graph running on AWS Bedrock AgentCore Runtime. The platform is architected in four logical layers that interact through well-defined Lambda function boundaries: an Identity and API layer (Amazon Cognito + API Gateway HTTP API v2), an Orchestration and Generation layer (Strands multi-agent graph + Bedrock AgentCore Runtime), a Data and Storage layer (DynamoDB + S3 + ECR), and an Observability and Delivery layer (CloudWatch + CloudTrail + GitHub). This layered design allows each component to be tested, scaled, and replaced independently, minimising integration risk during the twelve-week build.

The core generation loop is driven by the five-agent Strands graph. Agent 0 (Input Validator) validates the client brief and discovery questionnaire before any generation begins, preventing malformed inputs from propagating token cost into the generation pipeline. The Pre-Sales Generator, Delivery Generator, and Code Generator agents produce artifacts using Claude Sonnet 4.6, invoking the eof-tools converter pipeline (baked into the agent Docker image) for DOCX, PPTX, and XLSX output. The EO Validator agent applies both deterministic format-check rules and Claude Haiku 4.5 quality scoring, with up to three automatic retries, implementing a graded delivery policy that surfaces completed artifacts even when a subset requires additional iteration.

The platform surfaces two consumer interfaces: a pip-installable CLI (fourteen subcommands) that wraps HTTP API calls and enriches the `status` subcommand with per-phase token-usage data from DynamoDB, and a JWT-protected HTTP API (eleven Lambda routes via API Gateway HTTP API v2) that Amatra consultants and administrators interact with programmatically. All generated artifacts are stored in a structured S3 path hierarchy and automatically committed to a GitHub repository via a PAT-based commit pipeline using a Personal Access Token stored in AWS Secrets Manager.

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

## Architecture Principles

- **Validate first, generate at scale:** Agent 0 (Input Validator) applies a hard gate before any generation begins. No token spend occurs on malformed or incomplete inputs. This principle eliminates the primary source of wasted senior-consultant time in the current state.
- **Serverless-first design:** All compute is implemented on AWS Lambda and Bedrock AgentCore Runtime. There are no EC2 instances, no containers running 24/7, and no shared compute infrastructure. Fixed costs converge toward zero at idle, and the cost model scales linearly with generation volume.
- **Least-privilege security by design:** Each of the seventeen Lambda functions carries its own IAM execution role scoped to the minimum permissions required. No wildcard IAM actions or resource ARNs are permitted. This principle is enforced at build time via IAM Access Analyzer and at deployment time via the Terraform IaC pipeline.
- **Immutable audit trail:** Every API call, artifact generation event, and token usage measurement is written to DynamoDB `audit_events` and CloudTrail. The GitHub commit pipeline attributes every artifact delivery to a structured commit message including solution ID and artifact type. No action on the platform is unobservable.
- **Graded delivery over all-or-nothing:** The EO Validator implements a graded artifact delivery policy: when a subset of artifacts pass validation while others fail all three retries, the platform surfaces the passing artifacts immediately and continues retrying the failing subset. This prevents a single-artifact failure from blocking delivery of the full bundle.
- **IaC-only infrastructure changes:** All infrastructure changes are applied through the Terraform IaC pipeline with peer review and `terraform plan` output reviewed before `terraform apply`. No manual AWS Console changes are permitted in production.

## Architecture Patterns

- **Primary Pattern:** Serverless multi-agent orchestration graph (Strands Agents framework on Bedrock AgentCore Runtime)
- **Data Pattern:** Event-driven state machine with per-artifact status tracking in DynamoDB (solution_id → artifact_type → pass/fail/retry_count/token_usage)
- **Integration Pattern:** JWT-authenticated REST API (API Gateway HTTP API v2) with synchronous and asynchronous Lambda route handlers
- **Deployment Pattern:** Immutable container image pipeline (Docker build → ECR push → Lambda deploy via CI/CD); blue-green Lambda function versioning for zero-downtime deployments
- **Validation Pattern:** Deterministic format-check gate followed by LLM quality scoring (Claude Haiku 4.5) with up to three automatic retries; graded delivery on partial pass

## Component Design

The platform is composed of five primary agent components, seventeen Lambda functions, and the supporting AWS managed services that underpin identity, storage, observability, and delivery. The table below describes each major component, its responsibility, the specific technology, its dependencies, and its scaling strategy.

<!-- TABLE_CONFIG: widths=[20, 22, 20, 20, 18] -->
| Component | Purpose | Technology | Dependencies | Scaling |
|-----------|---------|------------|--------------|---------|
| Agent 0 — Input Validator | Validate client brief and discovery questionnaire; hard gate before generation | Strands Agent, Claude Haiku 4.5, DynamoDB | DynamoDB users, S3 input bucket | AgentCore auto-scales; Lambda concurrency limit 100 |
| Pre-Sales Generator | Produce five presales artifacts: solution briefing, SOW, discovery questionnaire, infrastructure costs CSV, LOE CSV | Strands Agent, Claude Sonnet 4.6, eof-tools converter | S3 guidance bucket, ECR agent image, DynamoDB solutions | AgentCore auto-scales; parallel per-artifact invocation |
| Delivery Generator | Produce six delivery artifacts: implementation plan, runbook, architecture design, test plan, change log, KT guide | Strands Agent, Claude Sonnet 4.6, eof-tools converter | S3 guidance bucket, ECR agent image, DynamoDB solutions | AgentCore auto-scales; parallel per-artifact invocation |
| Code Generator | Produce Terraform IaC automation bundle (12th artifact); run `terraform validate` syntax gate | Strands Agent, Claude Sonnet 4.6, Terraform CLI | S3 automation bucket, DynamoDB solutions | AgentCore auto-scales |
| EO Validator | Apply deterministic format-check + Haiku 4.5 LLM quality scoring; up to 3 retries per artifact; graded delivery | Strands Agent, Claude Haiku 4.5, DynamoDB | DynamoDB solutions, S3 artifact bucket, CloudWatch | AgentCore auto-scales |
| API Gateway HTTP API v2 | Eleven JWT-protected Lambda routes for consultant and admin actions | API Gateway HTTP API v2, Cognito JWT authoriser | Cognito User Pool, Lambda route handlers | AWS managed; regional endpoint; throttle: 1,000 RPS burst |
| Cognito User Pool | JWT issuance, authentication, post-confirmation profile write | Amazon Cognito, Lambda (post-confirmation trigger) | DynamoDB users table | AWS managed; scales to 10,000 MAUs |
| DynamoDB (four tables) | Quota enforcement, solution state, user profiles, audit events | DynamoDB On-Demand | All Lambda functions, all agents | On-Demand; auto-scales to any throughput |
| S3 Artifact Store | Raw MD/CSV, converted DOCX/PPTX/XLSX, Terraform bundles | Amazon S3 (versioning enabled, SSE-KMS) | All agents, GitHub push Lambda | Unlimited object storage |
| ECR Agent Image | eof-tools Docker image with ~30 Python converter modules baked in | Amazon ECR, Docker | CI/CD pipeline (GitHub Actions / CodePipeline) | Immutable image tags; updated each sprint |
| GitHub Commit Pipeline | Automated PAT-based commit of all generated artifacts to public repository | Lambda (GitHub push), AWS Secrets Manager | S3 artifact bucket, DynamoDB audit_events | Lambda concurrency; PAT retrieved at runtime |
| CloudWatch + X-Ray | Dashboards, alarms, per-phase token metrics, distributed tracing | Amazon CloudWatch, AWS X-Ray | All 17 Lambda functions, all agents | AWS managed |

## Technology Stack

The following technology stack aligns exactly with the presales commitments in the SOW. No services or capabilities outside this stack are introduced.

<!-- TABLE_CONFIG: widths=[22, 38, 40] -->
| Layer | Technology | Rationale |
|-------|------------|-----------|
| Agent Orchestration | AWS Bedrock AgentCore Runtime + Strands Agents framework | Serverless managed hosting for multi-agent graphs; eliminates EC2 management overhead; native Bedrock model integration |
| AI/ML Models | Claude Sonnet 4.6 (generation) + Claude Haiku 4.5 (validation) | Sonnet 4.6 for high-quality artifact generation; Haiku 4.5 for cost-efficient per-artifact quality validation (targeting < $5/solution) |
| Compute | AWS Lambda (Python 3.12), seventeen functions | Zero idle cost; per-invocation billing; native Bedrock and DynamoDB SDK integration |
| Container Registry | Amazon ECR | Immutable image tags; native Lambda container image support; integrated Amazon Inspector scanning |
| API Layer | API Gateway HTTP API v2 | Lower latency and cost versus REST API v1; native JWT authoriser integration with Cognito; HTTP/2 support |
| Authentication | Amazon Cognito User Pools | Managed JWT issuance; 1-hour access token + 30-day refresh token; post-confirmation trigger Lambda; three role attributes |
| Database | Amazon DynamoDB On-Demand | Serverless; atomic conditional writes for quota enforcement; PITR backup; TTL for audit event expiry |
| Object Storage | Amazon S3 (versioning + SSE-KMS) | Unlimited capacity; structured path hierarchy per solution_id; 12-month standard → 24-month Glacier lifecycle |
| Secrets Management | AWS Secrets Manager | GitHub PAT storage with 90-day automatic rotation; runtime retrieval by Lambda functions; no secrets in environment variables |
| IaC | Terraform (all infrastructure modules) | Declarative infrastructure; `terraform validate` syntax gate in CI/CD; peer-reviewed plan before apply |
| CI/CD | GitHub Actions (or AWS CodePipeline) | Docker build → ECR push → Lambda deploy → `terraform validate` gate |
| Observability | Amazon CloudWatch + AWS X-Ray + AWS CloudTrail | Dashboards and alarms for Lambda metrics; distributed traces for agent-to-agent call chains; API-level audit trail |
| Security | AWS GuardDuty + Security Hub + AWS Config + IAM Access Analyzer | Threat detection; posture management; policy validation; compliance findings aggregation |
| Artifact Conversion | eof-tools (~30 Python modules): python-docx, openpyxl, python-pptx | Existing investment; no rewrite in scope; baked into Docker image for consistent runtime |
| CLI | Pip-installable Python package (14 subcommands) | Consultant-facing; wraps HTTP API; enriches `status` with per-phase token usage from DynamoDB |

---

# Security & Compliance

The platform's security architecture is built on least-privilege access, defence-in-depth across all layers, and an immutable audit trail that supports PREDICTif's internal security baseline and future SOC 2 Type II readiness. Security controls are embedded in the identity, compute, data, network, and delivery layers — not bolted on after the fact. Every architecture decision in this section is directly traceable to the security requirements defined in the SOW.

## Identity & Access Management

Amazon Cognito User Pools provides the authoritative identity layer for all consultant and administrator access to the platform. JWT access tokens carry a one-hour expiry backed by 30-day refresh tokens, and the API Gateway JWT authoriser validates every inbound request before any Lambda function is invoked. There are no API key bypass paths and no unauthenticated routes.

Three application-layer roles are implemented within Cognito and enforced by Lambda route handlers using the `custom:role` attribute written at post-confirmation time:

- **Consultant:** Generate solutions within personal quota (10/month); view own artifact history and token usage via the CLI `status` subcommand.
- **Admin:** View all solutions and token usage across all users; override per-user quotas via the `/admin/quota-override` endpoint; access the `/admin/usage` usage report.
- **Read-Only:** View solution status and artifacts without generate capability; suitable for account managers and executive sponsors.

### Role Definitions

Role assignments are stored in the Cognito User Pool `custom:role` attribute and replicated to the DynamoDB `users` table at post-confirmation time. The following table summarises permissions by role across the platform's eleven API routes.

<!-- TABLE_CONFIG: widths=[18, 45, 37] -->
| Role | Permissions | Scope |
|------|-------------|-------|
| Consultant | generate, status (own), list (own), artifact download (own) | Own solutions only; bounded by 10/month quota |
| Admin | All consultant permissions + view all solutions, usage report, quota override, user management | All solutions across all users; global quota visibility |
| Read-Only | status (own), list (own), artifact download (own) | Own solutions only; no generate capability |

All Lambda execution roles follow strict least-privilege design: each function's IAM role grants only the specific DynamoDB table actions, S3 key prefixes, and Secrets Manager ARNs required for that function's operation. IAM Access Analyzer is enabled to continuously validate that no overly permissive policies are present. No cross-account IAM roles or wildcard resource ARNs are permitted.

## Secrets Management

All credentials and sensitive configuration values are stored in AWS Secrets Manager, not in Lambda environment variables, container images, or source control. The GitHub Personal Access Token (PAT) used for automated artifact commit is the primary secret managed by this service.

- **GitHub PAT:** Stored in Secrets Manager with automatic rotation enabled on a 90-day rotation period. The GitHub push Lambda retrieves the PAT at runtime via the Secrets Manager SDK (`GetSecretValue`). The PAT is never written to Lambda logs, CloudWatch metrics, or API response payloads — validated explicitly in the Phase 3 security test report.
- **Rotation policy:** 90-day automatic rotation for the GitHub PAT. Rotation Lambda function rotates the secret and updates the GitHub repository's allowed token list.
- **Access logging:** All `GetSecretValue` calls are logged in CloudTrail with requester identity, timestamp, and source IP, providing a complete access history for the secret.

## Network Security

The platform is deployed in a single AWS us-west-2 VPC with the following segmentation and controls designed to ensure that no traffic traverses the public internet unnecessarily.

- **Segmentation:** Three subnet tiers: public subnets (NAT Gateway only — no Lambda or application compute), private subnets (Lambda functions and agent orchestration), and isolated database subnets (no direct internet route; DynamoDB accessed via VPC Endpoint only).
- **VPC Endpoints:** Gateway-type VPC Endpoints for S3 and DynamoDB; Interface-type VPC Endpoints for Secrets Manager, CloudWatch Logs, ECR, and Bedrock. All Lambda-to-service traffic routes through VPC Endpoints and does not traverse the public internet.
- **NAT Gateway:** Single NAT Gateway in the public subnet provides outbound internet access for Lambda functions that require it (Bedrock API calls not covered by VPC Endpoint, GitHub HTTPS push).
- **WAF:** AWS WAF is evaluated for the API Gateway endpoint in Phase 2 if additional protection is required beyond Cognito JWT validation and API Gateway throttling.
- **DDoS Protection:** AWS Shield Standard (included with API Gateway) protects against volumetric DDoS at the edge. API Gateway request throttling (1,000 RPS burst limit) prevents abuse.

## Data Protection

All data at rest and in transit is encrypted using AWS-managed cryptographic controls.

- **Encryption at Rest:** S3 artifact bucket uses SSE-KMS with a customer-managed KMS key (CMK). DynamoDB tables use AWS-owned encryption keys (default) in the PoC; KMS-CMK to be evaluated in Phase 2. ECR container images are encrypted at rest with AWS-managed keys.
- **Encryption in Transit:** TLS 1.2+ is enforced by API Gateway (HTTPS-only; HTTP requests are rejected), Cognito, DynamoDB SDK, S3 SDK, and Secrets Manager SDK. No cleartext transport is permitted on any service boundary.
- **Key Management:** The S3 KMS-CMK is managed by the Amatra DevOps team with a 90-day key rotation policy. Key usage is logged in CloudTrail.
- **Data Masking:** Non-production environments (dev, staging) use synthetic test briefs only. No real customer data or PII is permitted in non-production artifact stores.

## Compliance Mappings

The following table maps key platform controls to SOC 2 Type II Trust Services Criteria (TSC). This mapping supports PREDICTif's internal SOC 2 readiness assessment and provides the audit evidence baseline for the external audit in Phase 2.

<!-- TABLE_CONFIG: widths=[18, 42, 40] -->
| Framework | Requirement | Implementation |
|-----------|-------------|----------------|
| SOC 2 CC6.1 | Logical access security — restrict access to authorised users | Cognito JWT authoriser on all API routes; three-role RBAC; MFA required for Admin role in production |
| SOC 2 CC6.2 | User registration and de-provisioning | Cognito post-confirmation trigger writes user profile; scheduled Lambda suspends inactive users (90-day inactivity threshold) |
| SOC 2 CC6.3 | Role-based access control | Three Cognito roles (Consultant, Admin, Read-Only); DynamoDB `users` table stores role assignments |
| SOC 2 CC7.2 | System monitoring | CloudWatch alarms on Lambda error rate, DynamoDB throttles, Bedrock throttles; SNS notifications to operations team |
| SOC 2 CC7.3 | Incident response | Operational runbooks for agent failure, Bedrock throttle, GitHub push failure, quota counter corruption |
| SOC 2 CC8.1 | Change management | Terraform IaC-only deployments; peer-reviewed `terraform plan`; CI/CD gate; no manual console changes in production |
| SOC 2 CC9.1 | Risk management | Risk register maintained in Phase 1 ADR; monthly review by Daniel Park |

## Audit Logging & SIEM Integration

The platform implements a multi-layer audit trail that covers AWS API-level events, application-level events, and per-phase token usage:

- **AWS CloudTrail:** Management Events (all API calls to AWS services) and S3 Data Events (GetObject, PutObject on the artifact bucket) are enabled, with logs delivered to a dedicated S3 bucket with Object Lock (WORM) and a 365-day retention policy.
- **DynamoDB `audit_events` table:** Application-level audit log capturing all platform API calls with user_id, action, solution_id, timestamp, and outcome (pass/fail). Retained for 90 days via TTL attribute.
- **Per-phase token usage:** The DynamoDB `solutions` table records input tokens, output tokens, and estimated Bedrock cost per agent per artifact, providing granular cost attribution for SOC 2 vendor risk management.
- **GitHub commit history:** Every artifact commit is attributed to the platform's Secrets Manager PAT with a structured commit message (`solution_id/<artifact_type>: generated by EO Validator — <pass|partial>`), creating an immutable delivery audit trail.
- **SIEM Integration:** GuardDuty findings are forwarded to AWS Security Hub. Security Hub aggregates findings from GuardDuty, AWS Config rules, and Amazon Inspector ECR scans. No external SIEM integration is in scope for PoC (out of scope per SOW).

---

# Data Architecture

The platform's data architecture is designed around a clear separation of concerns: agent-produced artifacts live in S3 as immutable objects; operational state (quota counters, solution lifecycle, user profiles) lives in DynamoDB with strong consistency and atomic writes; and audit events are written to both DynamoDB (application layer) and CloudTrail (infrastructure layer). This separation ensures that artifact storage can scale independently of quota enforcement logic, and that the audit trail cannot be altered even by platform administrators.

## Data Model

### Conceptual Model

The platform operates on five core data domains: **Users** (authenticated consultant identities and their role assignments), **Solutions** (each generation request, its artifact status, and per-phase token usage), **Quotas** (per-user and global atomic counters enforcing monthly generation limits), **Artifacts** (the generated MD/CSV files and their converted DOCX/PPTX/XLSX equivalents stored in S3), and **Audit Events** (an immutable log of all platform actions for SOC 2 compliance). Users own Solutions; each Solution contains up to twelve Artifacts; Quotas are decremented atomically when a Solution is created and incremented on cancellation; Audit Events reference both Users and Solutions.

### Logical Model

The following table defines the core DynamoDB entities, their key attributes, relationships, and expected data volumes at 200 solutions/month steady-state throughput.

<!-- TABLE_CONFIG: widths=[18, 32, 28, 22] -->
| Entity (Table) | Key Attributes | Relationships | Volume Estimate |
|----------------|---------------|---------------|-----------------|
| `users` | PK: `user_id` (Cognito sub); Attributes: email, role, created_at, last_active_at, monthly_quota_used | Referenced by `solutions`, `quotas`, `audit_events` | ~120 items (stable) |
| `solutions` | PK: `solution_id` (UUID); SK: `user_id`; Attributes: status, artifact_statuses (map), token_usage (map per agent), created_at, completed_at | Owned by `users`; references 12 artifact S3 keys | ~2,400 items/year at steady state |
| `quotas` | PK: `user_id` or `GLOBAL`; Attributes: month_key (YYYY-MM), counter (atomic integer), last_updated | References `users` | ~121 items per month (120 users + 1 global) |
| `audit_events` | PK: `event_id` (UUID); SK: `timestamp`; Attributes: user_id, action, solution_id, outcome, source_ip; TTL: 90 days | References `users` and `solutions` | ~50,000 items/month at steady state; auto-expired via TTL |

### S3 Object Key Structure

All artifacts follow a structured S3 path hierarchy that enables programmatic enumeration, lifecycle management, and GitHub push targeting:

```
{solution_id}/raw/pre-sales/         — Raw MD/CSV presales artifacts
{solution_id}/raw/delivery/          — Raw MD delivery artifacts
{solution_id}/converted/pre-sales/   — DOCX/PPTX/XLSX converted presales
{solution_id}/converted/delivery/    — DOCX/PPTX/XLSX converted delivery
{solution_id}/automation/            — Terraform IaC bundle (12th artifact)
```

## Data Flow Design

Data flows through the platform in a linear pipeline from consultant input through generation, validation, conversion, storage, and GitHub delivery. The following steps describe the end-to-end data lifecycle for a single solution generation request.

1. **Ingestion:** The consultant submits a client brief and discovery questionnaire via the CLI `generate` subcommand or the `/api/v1/solutions` POST route. The API Gateway JWT authoriser validates the Cognito token before the request reaches the Lambda handler.
2. **Quota check:** The Lambda handler performs an atomic DynamoDB conditional write on the `quotas` table (per-user counter < 10 AND global counter < 1,000). If the quota check fails, a 429 response is returned immediately; no agent invocation occurs.
3. **Input validation:** Agent 0 (Input Validator) reads the brief from S3, applies completeness and format checks, and writes a validation report to DynamoDB `solutions` table. If validation fails, the solution state is set to `FAILED_VALIDATION` and the consultant is notified with actionable error messages.
4. **Parallel artifact generation:** The Pre-Sales Generator, Delivery Generator, and Code Generator agents produce artifacts in parallel within their respective domains. Each agent writes raw MD/CSV artifacts to the `{solution_id}/raw/` S3 path and invokes the eof-tools converter pipeline to produce DOCX/PPTX/XLSX outputs written to `{solution_id}/converted/`.
5. **Validation loop:** The EO Validator agent applies deterministic format-check rules (YAML frontmatter, required H1 sections, table shapes, image references) followed by Claude Haiku 4.5 LLM quality scoring. Per-artifact pass/fail status and retry count are written to the DynamoDB `solutions.artifact_statuses` map. On failure, the generating agent is reinvoked (up to three retries per artifact).
6. **Graded delivery:** Once all artifacts have either passed validation or exhausted retries, the graded delivery policy assembles the result set. Passing artifacts proceed to step 7; failing artifacts are flagged in the solution status with actionable error context for manual remediation.
7. **GitHub commit:** The GitHub push Lambda retrieves the PAT from Secrets Manager and commits all passing artifacts to the configured public repository with a structured commit message. The commit SHA is written to the DynamoDB `solutions` table.
8. **Token usage recording:** The EO Validator writes per-phase token usage (input tokens, output tokens, estimated cost per agent per artifact) to the DynamoDB `solutions` table. This data is surfaced in the CLI `status` subcommand and the admin `/usage` API endpoint.

## Data Migration Strategy

No data migration from the existing OneDrive artifact store is in scope for this engagement. Existing artifacts remain in OneDrive and are not imported into the new S3 artifact store. This is an explicit out-of-scope item per the SOW.

The platform launches with a clean DynamoDB state. All quota counters are initialised to zero. Amatra consultants begin using the new platform from go-live for all new engagements; historical artifacts remain in OneDrive as an archive.

## Data Governance

The following governance policies apply to all data managed by the platform, consistent with PREDICTif's internal data governance standards and the SOC 2 readiness requirements.

- **Classification:** All artifacts and DynamoDB records are classified as "PREDICTif Internal." No customer PII or regulated data is permitted in artifact content. The platform operates on consultants' own work product.
- **Retention:** S3 artifacts are retained for 12 months in S3 Standard, then transitioned to S3 Glacier for 24 months before expiry (managed via S3 Lifecycle rules). DynamoDB `audit_events` records are retained for 90 days via TTL. CloudWatch Logs are retained for 90 days (Lambda function logs) and 365 days (CloudTrail logs).
- **Data quality:** Input validation by Agent 0 enforces completeness and format requirements before any generation token spend occurs. The EO Validator's format-check rules enforce structural quality on all generated artifacts.
- **Access control:** S3 bucket policies deny public access; all objects require authenticated AWS credentials for access. DynamoDB table policies restrict access to the specific Lambda execution roles that require it. No cross-account access is permitted.
- **Backup:** DynamoDB PITR is enabled on all four tables with a 35-day recovery window. S3 versioning is enabled on the artifact bucket; previous versions of overwritten or deleted objects are retained for 90 days. A PITR restore test is executed in Phase 3 to validate the 4-hour RTO target.

---

# Integration Design

The platform integrates with four external systems, as scoped in the SOW: AWS Bedrock AgentCore Runtime (agent hosting and model invocation), Amazon Cognito (authentication and JWT issuance), GitHub (automated artifact delivery via PAT), and DynamoDB (quota enforcement — internal but treated as a distinct integration domain given the atomic consistency requirements). All integrations use HTTPS with TLS 1.2+ and are authenticated via AWS SDK credential chains or Cognito JWT tokens.

## External System Integrations

The following table summarises all four external integrations, their protocol, data format, error handling strategy, and SLA expectations.

<!-- TABLE_CONFIG: widths=[18, 16, 14, 14, 23, 15] -->
| System | Type | Protocol | Format | Error Handling | SLA |
|--------|------|----------|--------|----------------|-----|
| AWS Bedrock AgentCore Runtime | Real-time (async agent invocation) | HTTPS (AWS SDK) | JSON (Bedrock API) | Exponential backoff up to 3 retries; throttle alarm triggers SNS notification | AWS SLA for Bedrock |
| Amazon Cognito | Real-time (token validation per request) | HTTPS (JWT, OAuth 2.0) | JWT (RS256) | Token expiry returns 401; refresh token flow in CLI; invalid token returns 401 | AWS SLA for Cognito |
| GitHub (PAT commit pipeline) | Event-driven (post-validation commit) | HTTPS (GitHub REST API v3) | JSON (GitHub API) + file content | Retry up to 3 times on 5xx; PAT expiry alarm triggers SNS; DLQ for failed commits | GitHub SLA |
| DynamoDB (quota enforcement) | Real-time (per-request atomic write) | HTTPS (AWS SDK) | JSON (DynamoDB item) | Conditional write failure → 429 to caller; DynamoDB throttle → CloudWatch alarm | AWS SLA for DynamoDB |

## API Design

The platform exposes an HTTP API v2 on API Gateway with eleven Lambda routes and a pip-installable CLI (fourteen subcommands) that wraps these routes. The API follows RESTful resource conventions with URL-path versioning.

- **Style:** REST (JSON request/response)
- **Versioning:** URL path versioning (`/api/v1/`)
- **Authentication:** Cognito JWT Bearer token (required on all routes)
- **Rate Limiting:** API Gateway default throttle: 10,000 requests/second with a 1,000 RPS burst; per-user quota enforced in DynamoDB (not at API Gateway level)
- **Content-Type:** `application/json` for all request and response bodies

### API Endpoints

The eleven API routes cover the complete solution lifecycle from generation through status monitoring, artifact retrieval, admin quota management, and usage reporting.

<!-- TABLE_CONFIG: widths=[10, 35, 18, 37] -->
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | /api/v1/solutions | Consultant, Admin | Initiate solution generation; validates JWT, checks quota, triggers Input Validator agent |
| GET | /api/v1/solutions/{solution_id} | Consultant, Admin, Read-Only | Retrieve solution status including artifact_statuses map and per-phase token usage |
| GET | /api/v1/solutions | Consultant, Admin | List solutions for authenticated user; Admin sees all users |
| GET | /api/v1/solutions/{solution_id}/artifacts/{artifact_type} | Consultant, Admin | Download presigned S3 URL for a specific artifact |
| DELETE | /api/v1/solutions/{solution_id} | Consultant, Admin | Cancel in-progress solution; decrements quota counter |
| GET | /api/v1/auth/me | All roles | Return authenticated user profile from DynamoDB `users` table |
| POST | /api/v1/auth/refresh | All roles | Exchange refresh token for new access token via Cognito |
| GET | /api/v1/admin/usage | Admin | Return per-user and global token usage and solution counts for current month |
| POST | /api/v1/admin/quota-override | Admin | Override per-user quota limit for the current month |
| GET | /api/v1/health | Unauthenticated | Platform health check; returns Lambda and DynamoDB connectivity status |
| POST | /api/v1/admin/users/{user_id}/suspend | Admin | Suspend inactive user (disable Cognito account and block DynamoDB access) |

## Authentication & SSO Flows

The platform implements two authentication flows: the primary consultant authentication flow (CLI-driven, interactive) and the service-to-service flow (Lambda function IAM roles).

- **Consultant authentication (CLI):** The `eoframework auth login` CLI subcommand opens the Cognito Hosted UI in the system browser (PKCE-based authorization code flow). Upon successful authentication, the CLI stores the JWT access token and refresh token in `~/.eoframework/credentials`. Subsequent CLI subcommands include the access token as a Bearer header. On token expiry (1 hour), the CLI automatically calls `/api/v1/auth/refresh` using the 30-day refresh token.
- **Service-to-service authentication (Lambda):** All Lambda functions authenticate to AWS services (DynamoDB, S3, Secrets Manager, Bedrock) using their IAM execution role credentials obtained from the Lambda runtime environment. No long-lived credentials are stored.
- **Token management:** Access tokens are short-lived (1-hour expiry). Refresh tokens have a 30-day expiry. The CLI handles refresh token rotation automatically. Revoked tokens are invalidated by deleting the Cognito user session; the JWT authoriser will reject tokens for disabled users.

## Messaging & Event Patterns

The platform uses a lightweight event-driven pattern for asynchronous generation invocations. There is no dedicated message queue for the primary generation path; instead, the API Gateway route handler invokes the Input Validator agent asynchronously via the Bedrock AgentCore Runtime invocation API and returns a `202 Accepted` with `solution_id` immediately.

- **Asynchronous generation:** POST `/api/v1/solutions` returns `202 Accepted` with `solution_id`. The CLI `status` subcommand polls the `GET /api/v1/solutions/{solution_id}` route to display real-time artifact status and token usage. Long-polling interval: 10 seconds.
- **Dead Letter Queue:** A DLQ (SQS FIFO queue) is attached to the GitHub push Lambda. Failed GitHub commits (after 3 retries) are written to the DLQ. A CloudWatch Alarm triggers on DLQ message depth > 0, routing an SNS notification to Daniel Park and the vendor operations team.
- **Retry Policy:** Agent retry logic (up to 3 retries per artifact) is implemented inside the EO Validator agent, not at the Lambda level. Lambda-level retries are disabled for API route handlers to prevent duplicate solution records.
- **SNS Alerts:** CloudWatch Alarms route to an SNS topic (`eoframework-ops-alerts`) with email subscriptions for Daniel Park and the vendor operations team. Alert categories: Lambda error rate, Bedrock throttle, DynamoDB throttle, DLQ depth, quota counter at 90% of global limit.

---

# Infrastructure & Operations

The platform's infrastructure is entirely serverless on AWS us-west-2, minimising operational overhead while providing the scalability, resilience, and observability required for a production pre-sales generation service. All infrastructure is defined in Terraform IaC modules and applied exclusively through the CI/CD pipeline. This section documents the network topology, compute sizing, high availability design, disaster recovery configuration, monitoring strategy, and cost model.

## Network Design

The platform is deployed in a single VPC in us-west-2 with a CIDR block of `10.0.0.0/16`. Three subnet tiers provide isolation between internet-facing NAT resources, application Lambda compute, and data-tier services.

- **VPC CIDR:** `10.0.0.0/16`
- **Public Subnets:** `10.0.1.0/24` (us-west-2a), `10.0.2.0/24` (us-west-2b) — NAT Gateway only; no Lambda functions or application compute placed in public subnets
- **Private Subnets:** `10.0.10.0/24` (us-west-2a), `10.0.11.0/24` (us-west-2b) — All Lambda functions and agent orchestration; outbound internet via NAT Gateway
- **Database Subnets:** `10.0.20.0/24` (us-west-2a), `10.0.21.0/24` (us-west-2b) — Reserved for future RDS or ElastiCache use; DynamoDB accessed via VPC Gateway Endpoint (no traffic in database subnets)
- **VPC Endpoints:** Gateway Endpoints for S3 and DynamoDB; Interface Endpoints for Secrets Manager, CloudWatch Logs, ECR API, ECR DKR, and Bedrock Runtime; eliminating public internet traversal for all primary service traffic

## Compute Sizing

All compute is serverless Lambda. The following table documents the memory and timeout configuration for each Lambda function group, derived from the performance requirements in the SOW and sizing guidelines in the level-of-effort estimate.

<!-- TABLE_CONFIG: widths=[28, 22, 16, 18, 16] -->
| Component | Lambda Config | Memory (MB) | Timeout (s) | Count |
|-----------|---------------|-------------|-------------|-------|
| API Route Handlers (non-generation) | Python 3.12, arm64 | 256 | 30 | 10 |
| Solution Generation Initiator | Python 3.12, arm64 | 512 | 60 | 1 |
| Agent Orchestration Triggers | Python 3.12, arm64, container image (eof-tools) | 1024 | 900 | 5 |
| Cognito Post-Confirmation Trigger | Python 3.12, arm64 | 256 | 10 | 1 |
| GitHub Push Lambda | Python 3.12, arm64 | 256 | 60 | 1 |
| Inactive User Suspension (scheduled) | Python 3.12, arm64 | 256 | 300 | 1 |

## High Availability Design

The platform leverages the inherent multi-AZ resilience of all AWS managed services used in the architecture. There are no single points of failure in the compute or data tiers.

- **Multi-AZ deployment:** Lambda functions and Bedrock AgentCore Runtime are inherently multi-AZ (AWS-managed). DynamoDB is a fully managed, multi-AZ service with synchronous replication. S3 provides 99.999999999% durability with automatic multi-AZ redundancy. Cognito User Pools are managed, multi-AZ services.
- **NAT Gateway redundancy:** A single NAT Gateway is deployed in us-west-2a for the PoC. A second NAT Gateway in us-west-2b is recommended in Phase 2 for AZ-level resilience.
- **Failover strategy:** No application-level failover logic is required; all compute and storage services are managed and multi-AZ. The CI/CD pipeline enables rapid redeployment of Lambda functions (< 5 minutes) in the event of a function-level issue.
- **Health checks:** API Gateway performs implicit Lambda health checks via invocation. The unauthenticated `/api/v1/health` route returns a 200 with DynamoDB and S3 connectivity status; this route is polled by CloudWatch Synthetics (canary) every 5 minutes.

## Disaster Recovery

The platform's RTO and RPO targets are defined in the SOW and must be validated in Phase 3 testing before go-live approval.

- **RPO:** 1 hour — DynamoDB PITR provides continuous backup with point-in-time recovery to any second within the 35-day window; S3 versioning retains all previous artifact versions.
- **RTO:** 4 hours — DynamoDB is serverless and requires no provisioning on recovery; table restore from PITR is the primary recovery action. Lambda functions are redeployed from the CI/CD pipeline. A PITR restore test in Phase 3 validates this target.
- **Backup strategy:** DynamoDB PITR enabled on all four tables (35-day window). S3 versioning enabled on artifact bucket with 90-day noncurrent version retention. S3 Cross-Region Replication is out of scope for PoC but recommended in Phase 2.
- **DR site:** Single-region PoC; no active DR site. Recovery is in-region from DynamoDB PITR and Lambda function redeployment.

## Monitoring & Alerting

The platform's observability stack is built on CloudWatch (metrics, logs, dashboards, alarms), AWS X-Ray (distributed tracing), and CloudTrail (API-level audit). Per-phase token usage data is written to DynamoDB by the EO Validator and surfaced in the CLI `status` subcommand and the admin `/usage` endpoint, providing cost visibility to individual consultants and the operations team.

- **Infrastructure metrics:** Lambda invocation count, error rate, duration (P50, P95, P99), cold start count, concurrency utilisation; DynamoDB consumed RCU/WCU, throttle events, conditional write success rate; API Gateway 4xx/5xx error rates, latency P99.
- **Application metrics:** Per-artifact validation pass/fail rate; per-artifact retry count; per-phase Bedrock token usage (input, output, estimated cost); solution generation duration (total); GitHub push success/failure rate.
- **Business KPIs:** Solutions generated per day/month; per-user quota utilisation (%); global quota utilisation (%); estimated platform Bedrock cost per day.
- **Alerting:** All alarms route to the `eoframework-ops-alerts` SNS topic with email subscriptions for Daniel Park and the vendor operations on-call.

### Alert Definitions

The following CloudWatch Alarms are configured at go-live. All alarms use a 5-minute evaluation period (1 data point) unless otherwise noted.

<!-- TABLE_CONFIG: widths=[28, 28, 18, 26] -->
| Alert | Condition | Severity | Response |
|-------|-----------|----------|---------|
| Lambda High Error Rate | Lambda error rate > 1% (any function, 5-min window) | P2 | Ops team investigates CloudWatch Logs; escalate to P1 if sustained > 15 min |
| Bedrock Throttle | Bedrock ThrottlingException count > 5 per 5 min | P2 | Investigate token throughput; request quota increase if sustained |
| DynamoDB Throttle | DynamoDB ThrottledRequests > 0 per 5 min | P2 | Review capacity; DynamoDB On-Demand auto-adjusts but spike may indicate access pattern issue |
| GitHub DLQ Depth | SQS DLQ message count > 0 | P2 | Investigate GitHub push failures; check PAT validity and repo permissions |
| Global Quota at 90% | Global quota counter ≥ 900 (90% of 1,000/month limit) | P3 | Notify Admin; evaluate quota increase or rate limiting for current month |
| CloudWatch Synthetics Canary Failure | Health check canary failure ≥ 2 consecutive runs | P1 | Immediate escalation; validate Lambda and DynamoDB connectivity |
| Lambda Cold Start Timeout | Duration P99 > 80% of configured timeout for agent triggers | P3 | Evaluate provisioned concurrency for agent trigger Lambdas |

## Logging & Observability

CloudWatch Log Groups are created for each of the seventeen Lambda functions with 90-day retention. Log groups for agent orchestration triggers (which include eof-tools converter output) use structured JSON logging with `solution_id`, `artifact_type`, `agent_name`, `retry_count`, `token_usage`, and `outcome` fields, enabling CloudWatch Log Insights queries for operational analytics.

AWS X-Ray traces are enabled on all seventeen Lambda functions. The X-Ray service map visualises the full agent-to-agent call chain from the Solution Generation Initiator Lambda through each of the five agent triggers to the EO Validator and GitHub push Lambda. Trace sampling rate is 5% in production (configurable) and 100% in staging.

CloudTrail Management Events and S3 Data Events are enabled on the artifact bucket, with logs delivered to a dedicated S3 bucket with Object Lock enabled and a 365-day retention period.

## Cost Model

The following monthly cost model is derived directly from the infrastructure-costs.csv analysis and reflects the target steady-state throughput of approximately 200 solutions/month. Year 2 and Year 3 figures reflect 20% annual volume growth. AWS partner credits of $15,000 are applied in Year 1.

<!-- TABLE_CONFIG: widths=[28, 22, 22, 28] -->
| Category | Monthly Estimate | Annual (Year 1) | Optimisation Approach |
|----------|-----------------|-----------------|----------------------|
| Bedrock Claude Sonnet 4.6 (generation) | $3,000 | $36,000 | Reserve capacity post-PoC; optimise prompt lengths in Phase 2 |
| Bedrock AgentCore Runtime | $1,500 | $18,000 | Right-size agent invocation concurrency post Phase 3 load test |
| Bedrock Claude Haiku 4.5 (validation) | $600 | $7,200 | Haiku chosen specifically to reduce validation token cost vs Sonnet |
| Amazon Cognito (MAU-based) | $50 | $600 | MAU pricing; cost grows only with user base |
| Amazon ECR (container registry) | $30 | $360 | Single agent image; incremental layer caching reduces push time/cost |
| Amazon CloudWatch (logs + metrics) | $150 | $1,800 | Compress non-critical log groups to 30-day retention in Phase 2 |
| S3 Artifact Storage (500 GB) | $11.50 | $138 | Lifecycle policy to Glacier after 12 months |
| API Gateway + Lambda (17 functions) | $2.20 | $26.40 | Pay-per-invocation; zero idle cost |
| DynamoDB (On-Demand) | $0.25 | $3 | On-Demand scales automatically; review reserved capacity at scale |
| AWS Business Support | $450 | $5,400 | Required for production SLA coverage |
| GitHub Enterprise Cloud (25 users) | $525 | $6,300 | Required for PAT-based artifact commit pipeline |
| **Total Infrastructure + Licenses** | **~$6,319** | **~$75,827** | **$15,000 AWS credits in Year 1** |

---

# Implementation Approach

The platform is delivered in three sequential phases over twelve weeks, with a hard go-live deadline of end of April 2026. The phasing strategy is "foundation-first" — the identity and API layer is delivered and demonstrable before AI agent complexity is introduced, reducing the risk that Bedrock or Strands framework integration issues block the core authentication and quota enforcement milestones. Each phase concludes with a formal deliverable acceptance by Marcus Patel and a go/no-go gate for the subsequent phase.

## Migration/Deployment Strategy

The platform is a greenfield build on a net-new AWS us-west-2 footprint; there is no existing platform to migrate from or cut over to. The deployment strategy is incremental by phase, with each phase adding capability on top of the validated foundation from the previous phase.

- **Approach:** Greenfield; incremental phase-gated delivery
- **Pattern:** Immutable Lambda function deployments via CI/CD (blue-green function versions); Docker image pipeline with ECR for agent container images
- **Validation:** Per-artifact format-check + LLM quality scoring in staging before production deployment; load test at 200 solutions/month in Phase 3
- **Rollback:** Previous Lambda function versions retained; `terraform apply` with `tfstate` rollback capability; DynamoDB PITR for data recovery

## Sequencing & Wave Planning

The following phase plan aligns directly with the SOW's phased delivery structure. Each phase has defined activities, duration, and exit criteria that serve as formal acceptance gates.

<!-- TABLE_CONFIG: widths=[12, 30, 15, 43] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| Phase 1 | AWS us-west-2 foundation (VPC, IAM, S3, CloudTrail, KMS, GuardDuty); Cognito User Pool; API Gateway HTTP API v2 (11 routes); DynamoDB schema (4 tables); baseline CloudWatch dashboards | Weeks 1–4 | CTO sign-off on Cognito initiated; JWT-authenticated API call demonstrable; DynamoDB schema deployed; CloudTrail enabled |
| Phase 2 | Five-agent Strands graph (AgentCore Runtime registration); Claude Sonnet 4.6 + Haiku 4.5 model bindings; Docker image pipeline (ECR); eof-tools converter integration; per-artifact validation loop (3-retry); graded delivery policy; CLI (14 subcommands); quota enforcement; GitHub integration; Terraform IaC; CI/CD pipeline | Weeks 5–9 | All five agents operational; full presales bundle (5 artifacts) generated E2E via CLI; Docker image pipeline green; quota enforcement verified |
| Phase 3 | End-to-end artifact validation (all 12 types); load testing (200 solutions/month); security testing (JWT, quota bypass, PAT protection); CloudWatch metrics baseline; PITR restore test; UAT with Marcus Patel; executive demo to Sarah Lin; production deployment; runbooks; knowledge transfer | Weeks 10–12 | All 12 artifacts pass format-check + LLM quality-check ≤3 retries; green CloudWatch baseline; executive demo delivered; production go-live approved by CTO |
| Hypercare | Post-go-live support; Bedrock quota issue resolution; agent failure triage; GitHub push remediation; CloudWatch alarm investigation; Cognito user management | Weeks 13–16 | All P1/P2 issues resolved; platform ownership fully transferred to PREDICTif team |

## Tooling & Automation

The following tools are used across all phases of the engagement. Tooling choices are aligned with the SOW commitments and with PREDICTif's existing AWS and GitHub investments.

<!-- TABLE_CONFIG: widths=[28, 30, 42] -->
| Category | Tool | Purpose |
|----------|------|---------|
| Infrastructure as Code | Terraform (all infrastructure modules) | Declarative provisioning of VPC, Lambda, DynamoDB, Cognito, API Gateway, S3, ECR; `terraform validate` gate in CI/CD |
| CI/CD Pipeline | GitHub Actions (primary) or AWS CodePipeline (fallback) | Docker build → ECR push → Lambda deploy → `terraform validate` gate; peer-reviewed plan before apply |
| Container Build | Docker, Amazon ECR | Build and publish agent Docker image with eof-tools (~30 Python modules) baked in |
| Agent Framework | Strands Agents framework | Multi-agent graph definition, agent-to-agent message passing, retry orchestration |
| AI/ML Models | Claude Sonnet 4.6, Claude Haiku 4.5 (via Bedrock AgentCore Runtime) | Artifact generation (Sonnet); cost-efficient validation and format scoring (Haiku) |
| Artifact Conversion | eof-tools (~30 Python modules): python-docx, openpyxl, python-pptx | Convert raw MD/CSV artifacts to DOCX, PPTX, XLSX |
| Secrets Management | AWS Secrets Manager | GitHub PAT storage; runtime retrieval; 90-day automatic rotation |
| Testing — Unit/Integration | pytest (Python), Moto (DynamoDB mock) | Unit testing Lambda handlers; mocking DynamoDB quota operations |
| Testing — E2E | Custom test harness (Python) against staging environment | End-to-end generation across all 12 artifact types; format-check validation |
| Testing — Load | Locust (Python-based load testing framework) | Load test at 200 solutions/month; validate per-solution Bedrock cost < $5 |
| Testing — Security | AWS IAM Access Analyzer, manual JWT penetration tests | IAM policy validation; JWT auth bypass; quota bypass; PAT protection |
| Observability | Amazon CloudWatch, AWS X-Ray, AWS CloudTrail | Dashboards, alarms, distributed traces, API-level audit trail |

## Cutover Approach

The production cutover is scheduled for Week 12 (hard deadline: end of April 2026). The cutover is a greenfield go-live — no legacy system cutover is required. The Amatra team simply begins using the new platform CLI from go-live for all new engagements.

- **Type:** Greenfield go-live (no parallel run required; legacy CLI remains available on consultant laptops as a fallback during hypercare)
- **Duration:** Estimated 4-hour cutover window (early morning US Pacific time to minimise consultant impact)
- **Validation:** End-to-end generation test with a synthetic client brief in production; all eleven API routes smoke-tested with production JWT tokens; GitHub commit pipeline validated; CloudWatch alarms confirmed active
- **Decision point (go/no-go criteria):** All go-live readiness checklist items satisfied (see SOW Testing & Validation section); CTO sign-off obtained; Marcus Patel UAT sign-off obtained

## Downtime Expectations

- **Planned downtime:** Zero for compute and API services (Lambda and API Gateway are managed, serverless, and deploy with zero downtime via blue-green function versioning). DynamoDB schema changes (if any) are additive only — no table drops are planned at go-live.
- **Unplanned downtime:** Lambda MTTR target < 5 minutes (function redeployment from CI/CD); DynamoDB MTTR target < 4 hours (PITR restore from backup in the event of data corruption).
- **Mitigation:** Provisioned concurrency on agent trigger Lambdas if cold-start timeouts are observed during Phase 3 load testing; DynamoDB On-Demand auto-scales to prevent capacity-related downtime.

## Rollback Strategy

The following rollback procedures are defined for the production cutover. Rollback is triggered by the Lambda error rate alarm (> 5% sustained for 5 minutes), a non-transient Bedrock API error, or DynamoDB quota counter corruption detected.

- **Lambda function rollback:** Redeploy the previous Lambda function version via the CI/CD pipeline. Estimated time: < 15 minutes. Previous function versions are retained in AWS Lambda for 30 days.
- **Infrastructure rollback:** Revert the Terraform state to the previous approved `terraform apply` and rerun the pipeline. Estimated time: < 30 minutes.
- **DynamoDB data recovery:** If quota counter corruption is detected, restore the `quotas` table from DynamoDB PITR to the last known-good point in time. Estimated time: < 4 hours (RTO target).
- **Cognito:** No rollback required; the Cognito User Pool is stable and requires no rollback in the event of a Lambda or infrastructure issue.
- **Maximum rollback window:** 4 hours (RTO target). If rollback exceeds 4 hours, Sarah Lin is notified and a decision point is convened with Marcus Patel.
- **Communication:** Marcus Patel and Daniel Park notified via SNS alarm immediately on rollback trigger. Sarah Lin notified if rollback extends beyond 2 hours.

---

# Appendices

This section provides supporting reference material for the detailed design, including naming conventions, tagging standards, the risk register, and a glossary of key acronyms and terms used throughout the document.

## Architecture Diagrams

The following diagrams support the architecture described in this document. The primary Solution Architecture Diagram is included in the Solution Architecture section above and is the authoritative reference for the platform's component topology and data flows.

- **Solution Architecture Diagram** — Included in Section 4 (Solution Architecture); references `../../assets/diagrams/architecture-diagram.png`
- **Network Topology Diagram** — Illustrates the us-west-2 VPC, subnet tiers (public/private/database), NAT Gateway, VPC Endpoints, and Lambda placement; to be produced in Phase 1 as part of the ADR package
- **Data Flow Diagram** — Illustrates the end-to-end artifact generation pipeline from CLI invocation through Agent 0 → Generation Agents → EO Validator → GitHub push; to be produced in Phase 1
- **Security Architecture Diagram** — Illustrates IAM role boundaries, Cognito JWT flow, Secrets Manager integration, and GuardDuty/Security Hub posture; to be produced in Phase 1

## Naming Conventions

All AWS resources follow a consistent naming pattern to support operational clarity, Terraform resource management, and CloudWatch metric filtering. The pattern is `eofw-{env}-{resource-type}-{descriptor}` where `env` is one of `dev`, `stg` (staging), or `prd` (production).

<!-- TABLE_CONFIG: widths=[22, 38, 40] -->
| Resource Type | Pattern | Example |
|---------------|---------|---------|
| VPC | `eofw-{env}-vpc` | `eofw-prd-vpc` |
| Lambda Function | `eofw-{env}-fn-{descriptor}` | `eofw-prd-fn-input-validator` |
| DynamoDB Table | `eofw-{env}-tbl-{descriptor}` | `eofw-prd-tbl-solutions` |
| S3 Bucket | `eofw-{env}-s3-{descriptor}-{account-id}` | `eofw-prd-s3-artifacts-123456789012` |
| API Gateway | `eofw-{env}-apigw` | `eofw-prd-apigw` |
| Cognito User Pool | `eofw-{env}-userpool` | `eofw-prd-userpool` |
| ECR Repository | `eofw-{env}-ecr-{descriptor}` | `eofw-prd-ecr-agent-image` |
| IAM Role (Lambda) | `eofw-{env}-role-fn-{descriptor}` | `eofw-prd-role-fn-github-push` |
| CloudWatch Log Group | `/eofw/{env}/lambda/{function-name}` | `/eofw/prd/lambda/input-validator` |
| Secrets Manager Secret | `eofw/{env}/{descriptor}` | `eofw/prd/github-pat` |
| SNS Topic | `eofw-{env}-sns-{descriptor}` | `eofw-prd-sns-ops-alerts` |

## Tagging Standards

All AWS resources must carry the following tags to support cost allocation, ownership tracking, and SOC 2 compliance evidence. Tags are enforced via AWS Config rules and the Terraform IaC modules. Resources without required tags will fail the Terraform plan gate.

<!-- TABLE_CONFIG: widths=[22, 15, 63] -->
| Tag Key | Required | Example Values |
|---------|----------|----------------|
| Environment | Yes | `dev`, `staging`, `production` |
| Application | Yes | `eoframework` |
| Owner | Yes | `amatra-devops`, `amatra-engineering` |
| CostCenter | Yes | `AMATRA-PRESALES-2026` |
| ManagedBy | Yes | `terraform` |
| SolutionID | Yes (per-resource if applicable) | `1db81e21-1605-480b-8672-226127aa56a3` |
| DataClassification | Yes | `PREDICTif-Internal` |
| Compliance | Recommended | `SOC2-Readiness` |

## Risk Register

The following risk register captures the primary technical, schedule, and operational risks identified during the pre-sales and Phase 1 discovery processes. Each risk is assigned a likelihood and impact score and a mitigation strategy. The risk register is reviewed weekly by the Vendor Project Manager and reported to Marcus Patel in the Friday status update.

<!-- TABLE_CONFIG: widths=[30, 14, 14, 42] -->
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Bedrock AgentCore Runtime not GA in us-west-2 by Phase 2 start | Medium | Critical | Validate API stability in Week 1 technical spike; agree contingency (self-hosted Strands on Lambda containers) with Marcus Patel if still in preview |
| CTO sign-off on Cognito User Pool delayed beyond Week 3 | Medium | High | Escalate to Sarah Lin (CRO) within one business day of any slip; provision Cognito in dev environment immediately to unblock Phase 1 parallel work |
| eof-tools converter library has undiscovered bugs in one or more of the ~30 modules | Medium | High | Conduct eof-tools integration spike in Week 5 before committing to Phase 2 converter work packages; raise bugs to Daniel Park for triage (refactoring is out of scope) |
| Bedrock token throughput quota insufficient for 200 solutions/month load test | Medium | High | Engage AWS Solutions Architect for quota pre-approval in Week 1; escalate to AWS account team if self-serve quota increase is insufficient |
| Per-solution Bedrock cost exceeds $5 target at 200 solutions/month | Low | High | Monitor token usage per artifact during Phase 2 development; optimise prompt lengths and context window truncation before Phase 3 load test |
| GitHub PAT expires mid-engagement and breaks commit pipeline | Low | Medium | 90-day automatic rotation via Secrets Manager; CloudWatch alarm on GitHub push Lambda failure; PAT expiry date tracked in operations calendar |
| DynamoDB quota counter race condition allows quota bypass | Low | Critical | Implement atomic conditional writes (DynamoDB `ConditionExpression: counter < :limit`); test quota bypass via concurrent batch requests in Phase 3 security testing |
| Phase 3 load test reveals Lambda cold-start timeouts on agent triggers | Medium | Medium | Evaluate provisioned concurrency for the five agent trigger Lambdas if P99 duration exceeds 80% of configured timeout; budget headroom for this is included in the infrastructure cost model |
| Key personnel availability risk: Marcus Patel unavailability for UAT in Week 11 | Low | High | Identify a designated deputy (from Daniel Park's team) at kickoff for UAT coverage; maintain two-week UAT preparation lead time |
| AWS Bedrock service disruption during Phase 3 executive demo | Low | Critical | Execute executive demo in staging environment (not production) against a pre-generated solution bundle as a fallback; schedule production demo in a separate session post-hypercare |

## Glossary

The following terms and acronyms are used throughout this document and the associated SOW, Solution Briefing, and operational runbooks.

<!-- TABLE_CONFIG: widths=[22, 78] -->
| Term | Definition |
|------|------------|
| ADR | Architecture Decision Record — a document capturing a significant architecture decision, its context, options considered, and rationale |
| AgentCore Runtime | AWS Bedrock AgentCore Runtime — the serverless managed hosting environment for Strands-based multi-agent graphs |
| Artifact | A single generated output file in the EO Framework bundle (e.g., solution-briefing.md, statement-of-work.md, infrastructure-costs.csv) |
| CLI | Command Line Interface — the pip-installable Python package exposing 14 subcommands for consultant-facing platform interaction |
| DLQ | Dead Letter Queue — an SQS FIFO queue receiving failed GitHub push messages after 3 retry attempts |
| ECR | Amazon Elastic Container Registry — the AWS-managed Docker image registry storing the eof-tools agent container image |
| EO Framework | Engagement Operations Framework — Amatra's standardised methodology for producing pre-sales and delivery solution packages |
| eof-tools | The existing Python converter library (~30 modules) that transforms raw MD/CSV artifacts into DOCX, PPTX, and XLSX Office documents |
| EO Validator | The fifth Strands agent responsible for deterministic format-check and LLM quality scoring of all generated artifacts |
| Graded Delivery | The platform policy of surfacing passing artifacts immediately while continuing to retry failing artifacts, rather than blocking all delivery on a single failure |
| HTTP API v2 | API Gateway HTTP API v2 — the lower-latency, lower-cost API Gateway tier used for the platform's eleven Lambda routes |
| IaC | Infrastructure as Code — Terraform modules defining all AWS resources; applied exclusively through the CI/CD pipeline |
| JWT | JSON Web Token — the access token format issued by Cognito and validated by the API Gateway JWT authoriser on every request |
| KMS-CMK | AWS Key Management Service Customer-Managed Key — a customer-controlled KMS key used for S3 artifact bucket encryption at rest |
| LOE | Level of Effort — the engineering hours estimate underpinning the professional services investment |
| PITR | Point-In-Time Recovery — DynamoDB's continuous backup feature enabling table restore to any second within the 35-day recovery window |
| PoC | Proof of Concept — the twelve-week initial build phase scoped in this SOW; positioned as the foundation for Phase 2 |
| RPO | Recovery Point Objective — the maximum acceptable data loss in the event of a disaster; target: 1 hour |
| RTO | Recovery Time Objective — the maximum acceptable downtime in the event of a disaster; target: 4 hours |
| SOC 2 | Service Organization Control 2 — the AICPA trust services framework; PREDICTif targets SOC 2 Type II readiness (not certification) in this engagement |
| SOW | Statement of Work — the contractual document defining scope, deliverables, timeline, and commercial terms for this engagement |
| Strands | The open-source AWS Strands Agents framework used to define and orchestrate the five-agent multi-agent graph |
| TTL | Time to Live — the DynamoDB item expiry attribute; used on `audit_events` records to enforce 90-day retention without manual deletion |
| WORM | Write Once Read Many — the S3 Object Lock configuration applied to CloudTrail log buckets to prevent tampering of audit records |
