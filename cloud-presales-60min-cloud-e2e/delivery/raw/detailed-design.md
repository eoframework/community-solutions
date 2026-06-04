---
document_title: Detailed Design Document
solution_name: Amatra Agentic Orchestration Platform
document_version: "1.0"
author: Amatra EO Framework Division
last_updated: 2025-06-01
technology_provider: aws
client_name: PREDICTif Solutions
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Detailed Design Document provides the complete technical blueprint for the implementation of the **Amatra Agentic Orchestration Platform** for PREDICTif Solutions. The platform is a fully serverless, event-driven multi-agent system built on AWS that automates the end-to-end production of EO Framework pre-sales and delivery documentation — reducing per-engagement senior-consultant effort from six to ten hours down to under one hour and unlocking parallel pipeline throughput across PREDICTif's 120-consultant sales organisation.

The architecture is built on AWS Bedrock AgentCore Runtime using the Strands Agents framework, with Claude Sonnet 4.6 as the primary generation model and Claude Haiku 4.5 for cost-efficient validation. Five coordinated agents — Input Validator, Pre-Sales Generator, Delivery Generator, Code Generator, and EO Validator — operate as a directed multi-agent graph to produce twelve total artifacts per solution engagement (five presales, six delivery, and one Terraform automation bundle) following strict EO Framework quality standards. The platform is exposed via a pip-installable CLI with fourteen subcommands and a JWT-protected HTTP API with eleven Lambda routes behind API Gateway HTTP API v2, secured by Amazon Cognito User Pools.

This document expands upon the Architecture & Design commitments in the Statement of Work (SOW) dated June 2025, translating the high-level design into implementation-ready technical specifications for every component, integration, security control, data store, and operational procedure. All architecture decisions, technology choices, and design patterns in this document trace directly to the presales scope — no components or services are introduced beyond what was sold to PREDICTif Solutions. The document is intended for the vendor delivery team, the PREDICTif Solutions technical leads (Marcus Patel and Daniel Park), and the CTO, whose formal sign-off on the Cognito user pool configuration is required before Phase 1 infrastructure is deployed to production.

## Purpose

This document defines the implementation-ready technical design for the Amatra Agentic Orchestration Platform. It serves as the authoritative reference for all engineering, security, testing, and operational decisions made during the twelve-week delivery engagement. Solution Architects, ML/AI Engineers, Solutions Engineers, DevOps Engineers, and Security Engineers on the vendor team should use this document to guide their implementation work. PREDICTif Solutions technical stakeholders should use it to validate that the delivered platform conforms to the agreed architecture.

## Scope

**In-scope:**

- All five Strands agents (Input Validator, Pre-Sales Generator, Delivery Generator, Code Generator, EO Validator) and their registration with Bedrock AgentCore Runtime
- AWS foundation infrastructure in us-west-2: Cognito User Pool, API Gateway HTTP API v2, eleven Lambda route handlers, DynamoDB tables, S3 buckets, IAM roles and policies, Secrets Manager, CloudWatch, and ECR
- Pip-installable CLI with fourteen subcommands and JWT token management
- DynamoDB atomic quota enforcement — per-user (ten solutions/month) and global (1,000 solutions/month)
- Docker image pipeline for eof-tools integration, ECR workflow, and AgentCore Runtime image registration
- GitHub PAT-based artifact commit pipeline to the fixed public repository
- CloudWatch observability: per-phase token usage metrics, dashboards, and quota alarm notifications
- Security hardening: Secrets Manager, WAF rules, CloudTrail audit, DynamoDB KMS encryption
- Code Generator agent with Terraform IaC for five core AWS services and `terraform validate` gate
- Three-environment deployment strategy (dev, staging, prod) in us-west-2

**Out-of-scope:**

- Rewriting or refactoring the eof-tools converter library (~30 Python modules baked into the container image as-is)
- Multi-region deployment or any footprint beyond us-west-2
- Migration of existing OneDrive artifact storage to S3
- Additional artifact types beyond the current twelve (five presales, six delivery, one automation bundle)
- Integration with third-party CRM or PSA platforms (e.g., Salesforce, ConnectWise)
- Day-2 managed operations or SLA-backed incident response beyond the four-week hypercare period
- SOC 2 Type II audit preparation, penetration testing, or formal compliance certification
- Mobile application or browser-based UI

## Assumptions & Constraints

- A dedicated us-west-2 AWS account with sufficient IAM permissions will be available by Week 1
- The CTO will be available for architecture design review in Week 3 and production deployment sign-off in Week 11; delays to CTO availability extend the project timeline accordingly
- Marcus Patel will be available as primary technical contact for a minimum of ten hours per week throughout the engagement
- The eof-tools converter library is functional and correctly converts all twelve artifact types; no debugging or bug-fixing of eof-tools is in scope
- EO Framework guidance files are complete, accurate, and pre-loaded in S3 before Phase 2 agent development begins
- Bedrock service quotas for Claude Sonnet 4.6 and Claude Haiku 4.5 in us-west-2 are sufficient for development and testing workloads
- The GitHub repository is accessible via HTTPS using a Personal Access Token with `repo` scope
- The DynamoDB on-demand billing model is cost-effective for the proof-of-concept phase

## References

- Statement of Work (SOW) — Amatra Agentic Orchestration Platform, OPP-2026-001, June 2025
- Solution Briefing — Amatra Agentic Orchestration Platform, Marcus Patel, PREDICTif Solutions
- Infrastructure Cost Model — Amatra Agentic Orchestration Platform (infrastructure-costs.csv)
- Level of Effort Estimate — Amatra Agentic Orchestration Platform (level-of-effort-estimate.csv)
- AWS Bedrock AgentCore Runtime Developer Guide
- Strands Agents Framework Documentation
- EO Framework Quality Standards and Guidance Files (S3)

---

# Business Context

The Amatra Agentic Orchestration Platform is driven by PREDICTif Solutions' strategic imperative to scale its pre-sales engineering function without linearly scaling senior-consultant headcount. The platform addresses a fundamental constraint: each EO Framework presales bundle currently consumes six to ten hours of irreplaceable senior-consultant time, limiting the company to sequential deal processing and capping the number of concurrent client engagements its 120-consultant organisation can support.

## Business Drivers

- **90% Effort Reduction:** Senior-consultant time per presales bundle is targeted to drop from six to ten hours to under one hour. This frees the highest-cost resource in the organisation for higher-value client-facing activities rather than documentation production.
- **Parallel Pipeline Throughput:** The platform is designed to support 200+ solutions per month concurrently. Removing the sequential constraint that today limits deal velocity directly translates to increased revenue capacity without additional headcount.
- **Cost-Efficient AI Spend at Scale:** By targeting under $5 in model spend per solution (Claude Sonnet 4.6 for generation, Claude Haiku 4.5 for validation), the platform achieves a total amortised cost of under $0.50 per solution at 200 solutions/month steady state — a compelling unit economics profile.
- **Centralised Identity, Governance, and Audit:** Amazon Cognito JWT authentication, DynamoDB quota enforcement, and CloudTrail audit provide full visibility and control over AI usage and expenditure — eliminating the uncontrolled spend risk present in the existing laptop-based Claude Code CLI workflow.
- **Executive Demonstration Deadline:** The engagement must deliver a demonstrable proof-of-concept covering all four core capabilities (CLI auth, presales generation, delivery generation, Terraform automation bundle) in time for Sarah Lin (CRO) to present to executives by end of April 2026.
- **Scalable Foundation for Phase 2:** The architecture is designed to accommodate future multi-region deployment, additional artifact types, and increased solution throughput without requiring a fundamental rearchitecture.

## Workload Criticality & SLA Expectations

The platform directly supports PREDICTif Solutions' revenue-generating pre-sales function. Availability and performance targets reflect the business impact of generation failures or significant latency degradation.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Metric | Target | Measurement | Priority |
|--------|--------|-------------|----------|
| Platform Availability | 99.5% | CloudWatch uptime monitoring | Critical |
| End-to-End Generation Latency | < 60 minutes per 12-artifact solution | CloudWatch per-solution duration metrics | Critical |
| Artifact Validation Pass Rate | ≥ 95% on first or second LLM attempt | EO Validator pass/fail envelope | Critical |
| Lambda Error Rate | < 1% across all 11 routes | CloudWatch Lambda error rate metric | High |
| API Gateway 4xx Rate | < 2% of all requests | CloudWatch API Gateway metrics | High |
| DynamoDB Quota Enforcement | 100% atomic — zero bypass under concurrency | Load test validation | Critical |
| CLI Authentication Latency | < 5 seconds for `auth login` | End-to-end CLI test | Medium |
| RTO | 2 hours | DR testing and PITR recovery | High |
| RPO | 1 hour | DynamoDB PITR and S3 versioning | High |

## Compliance & Regulatory Factors

- The platform is designed to support PREDICTif Solutions' SOC 2 Type II compliance posture for the AI-generated content workflow; formal SOC 2 certification is out of scope but detective controls (CloudTrail, structured logging, quota audit trail) are built in by design
- Per-user quota enforcement (ten solutions/month) and global quota (1,000 solutions/month) implement a financial governance control over AI spend, addressing the lack of controls in the legacy workflow
- All Bedrock model invocations are logged to CloudTrail, providing a complete audit trail of who generated what artifacts and when — meeting the audit trail requirement for PREDICTif's internal governance standards
- AWS Business Support is included in the infrastructure model, providing 24x7 access and a sub-one-hour critical response SLA for all platform components

## Success Criteria

- End-to-end presales bundle (five artifacts) generated in under 60 minutes from brief submission, verified across five representative test cases in staging
- 95% or greater artifact validation pass rate across all twelve artifact types on the first or second LLM attempt within the three-retry budget
- All fourteen CLI subcommands operational, pip-installable, and JWT-authenticated end-to-end against the Cognito User Pool
- All eleven Lambda routes responding correctly to authenticated API requests via API Gateway HTTP API v2
- Per-user monthly quota enforcement validated under concurrent load — no user exceeds ten solutions per month; global pool does not exceed 1,000 solutions per month
- Green CloudWatch metrics baseline established with per-phase token usage visible in both the CLI `status` command and the `GET /admin/usage` API endpoint
- `terraform validate` passes on all Terraform IaC output from the Code Generator agent for the five core AWS services
- CTO sign-off obtained on the Cognito-based user pool prior to Phase 1 completion
- Executive demonstration delivered to Sarah Lin (CRO) by end of April 2026

---

# Current-State Assessment

The current state assessment documents the existing manual EO Framework delivery workflow at PREDICTif Solutions and provides the baseline against which the Amatra Agentic Orchestration Platform is measured. This section is based on the current state review conducted during Phase 1 Discovery and informs the gap analysis that drives the target architecture decisions.

## Application Landscape

PREDICTif Solutions' existing EO Framework delivery capability consists of a collection of informal tooling and manual processes rather than a coherent platform. The following table summarises the current application landscape:

<!-- TABLE_CONFIG: widths=[25, 30, 25, 20] -->
| Application | Purpose | Technology | Status |
|-------------|---------|------------|--------|
| Claude Code CLI | LLM-powered artifact generation run on local developer laptops | Claude (Anthropic), local Python | Replace with agentic platform |
| eof-tools converter library | Converts raw MD/CSV source to DOCX/PPTX/XLSX EO Framework documents | ~30 Python modules | Integrate (bake into container image) |
| OneDrive Folder | Ad-hoc artifact storage and sharing across the team | Microsoft OneDrive | Supersede with S3 + GitHub pipeline |
| Manual GitHub Push | Copy-paste of generated artifacts into engagement GitHub repositories | GitHub, manual CLI | Automate via PAT-based commit workflow |
| Local Validation Scripts | Ad-hoc Python scripts run by individual consultants to check format | Python | Replace with EO Validator Agent |

## Infrastructure Inventory

The current delivery infrastructure is entirely laptop-based with no centralised server components. The following table captures the relevant components for migration planning:

<!-- TABLE_CONFIG: widths=[20, 15, 35, 30] -->
| Component | Quantity | Specifications | Notes |
|-----------|----------|----------------|-------|
| Consultant Laptops | ~120 | MacOS/Windows; local Python 3.10+; Claude Code CLI installed | Replaced by centralised platform; laptops become CLI clients only |
| Claude Code CLI | 1 per consultant | Anthropic Claude, ad-hoc model selection | Replaced by pip-installable CLI targeting Bedrock |
| OneDrive Artifact Storage | 1 shared folder | Microsoft OneDrive, ~50 GB estimated | Not migrated; S3 replaces for new engagements |
| GitHub Repositories | Per-engagement | Public GitHub repositories, manual push | Automated via PAT-based commit pipeline |
| eof-tools Library | 1 copy per developer | ~30 Python modules, proprietary EO Framework converter | Baked into agent container image; not rewritten |

## Dependencies & Integration Points

The current-state workflow has the following dependencies that inform the target integration design:

- The eof-tools library is the only existing technical asset with a direct dependency in the target architecture — it is baked into the Docker container image as-is, preserving the investment without rewrite risk
- GitHub repositories for client engagements are the target publication endpoint — the platform must commit generated artifacts to the fixed public repository via HTTPS PAT authentication
- EO Framework guidance files (S3-stored) must be pre-loaded before agent development begins and are the authoritative quality standard for all generated artifacts
- Bedrock model access (Claude Sonnet 4.6, Claude Haiku 4.5) in us-west-2 must be enabled and quota-provisioned before Phase 2 agent development commences

## Network Topology

The current state has no centralised network infrastructure. All generation activity originates from consultant laptops connecting directly to the Anthropic Claude API over the public internet. There are no VPCs, no private connectivity, and no AWS network footprint associated with the existing workflow. The target architecture replaces this with an AWS-managed serverless topology (described in Section 4) — API Gateway as the single public ingress point, with all Lambda-to-service communication traversing the AWS internal network fabric.

## Security Posture

The current-state security posture has significant gaps that the platform is designed to close:

- **No Centralised Identity:** Consultants use individually managed Anthropic API keys with no centralised identity provider, no single sign-on, and no per-user access control
- **No Quota Enforcement:** There is no mechanism to cap AI spend per user or globally; a single misconfigured generation run could exhaust budget without detection
- **No Audit Trail:** There is no record of who generated which artifacts, which models were invoked, or how many tokens were consumed per engagement
- **No Secret Management:** GitHub PATs and API keys are stored in local environment files or shared informally via messaging channels
- **No Artifact Access Control:** Generated artifacts in OneDrive are accessible to any consultant with the shared folder link, with no granular access governance

## Performance Baseline

The current manual process exhibits the following performance characteristics, establishing the baseline against which the platform's targets are measured:

- Average per-engagement effort: six to ten hours of senior-consultant time
- Peak concurrent engagements supported: two to three (limited by senior-consultant availability)
- Validation failure rework cycles per engagement: three to four iterations before meeting EO Framework standards
- Monthly engagement throughput: approximately thirty to fifty engagements at peak

## Gap Analysis

The following table maps the current-state gaps to their target-state resolution in the Amatra Agentic Orchestration Platform:

<!-- TABLE_CONFIG: widths=[33, 34, 33] -->
| Current State | Gap | Target State |
|---------------|-----|--------------|
| Manual Claude Code CLI on local laptops; 6-10 hours per bundle | No orchestration, no parallelism, no automation | Five-agent Strands graph on AgentCore Runtime; sub-60-minute automated generation |
| No centralised identity; individual Anthropic API keys | No SSO, no per-user governance | Amazon Cognito User Pools; JWT-protected API; 14 CLI subcommands |
| No quota enforcement; unlimited AI spend risk | No cost governance | DynamoDB atomic quota counters; 10 solutions/user/month; 1,000 global/month |
| Three to four validation rework cycles per engagement | No automated format-check or quality gate | EO Validator Agent; deterministic format-check + Haiku 4.5 quality gate; 3-retry loop |
| OneDrive artifact storage; manual GitHub push | No automation, no version control | S3 artifact storage; automated GitHub PAT-based commit pipeline |
| No audit trail for AI spend or artifact lineage | No compliance or governance evidence | CloudTrail + structured DynamoDB metadata for every generation event |
| eof-tools run manually; DOCX/PPTX/XLSX conversion ad-hoc | Fragile, non-repeatable, consultant-expertise-dependent | eof-tools baked into Docker container; automated converter pipeline for all 12 artifact types |

---

# Solution Architecture

The Amatra Agentic Orchestration Platform delivers a fully serverless, event-driven architecture organised into four logical layers: a security and identity perimeter, an API and CLI surface, an agentic orchestration core, and a persistence and observability substrate. Every component is deployed in the AWS us-west-2 region in a greenfield footprint, isolated from PREDICTif's existing us-east-1 managed-services workloads to contain blast radius during the proof-of-concept phase. The design philosophy prioritises operational simplicity — the entire platform is serverless (Lambda, AgentCore Runtime, DynamoDB, S3) with no EC2 instances or container clusters to operate on an ongoing basis.

The platform accepts solution generation requests through two surfaces: the pip-installable CLI (consultant-facing) and the JWT-protected REST API (programmatic). Both surfaces authenticate against the Amazon Cognito User Pool before any Lambda function is invoked. The API Gateway HTTP API v2 JWT authoriser validates every token against the Cognito JWKS endpoint, routing authenticated requests to the appropriate Lambda handler. Lambda handlers enforce per-user and global quotas in DynamoDB, then invoke the Strands multi-agent graph via Bedrock AgentCore Runtime. Completed artifacts are written to S3 and committed to the GitHub repository via the PAT-based commit pipeline. CloudWatch captures per-phase token usage, Lambda execution metrics, and quota events throughout.

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

*Figure 1: Amatra Agentic Orchestration Platform — End-to-end AWS architecture showing the five-agent Strands graph on Bedrock AgentCore Runtime, API Gateway HTTP API v2 with Cognito JWT authorisation, DynamoDB quota enforcement, S3 artifact storage, and CloudWatch observability in us-west-2.*

## Architecture Principles

The following principles guide every design decision in the Amatra Agentic Orchestration Platform and must be upheld throughout the implementation:

- **Serverless-First:** All compute is managed (Lambda, AgentCore Runtime) — no EC2 instances, no ECS clusters, no infrastructure to patch or scale manually. This minimises operational overhead for Daniel Park's team post-handover and ensures the platform scales automatically with solution volume.
- **Security by Design:** Authentication, authorisation, encryption, and audit logging are foundational, not bolted on. Every API request requires a valid Cognito JWT; every Lambda execution role follows least-privilege IAM; every secret is stored in Secrets Manager; every action is logged in CloudTrail.
- **AI-First Generation with Deterministic Guardrails:** Claude Sonnet 4.6 handles generative complexity while the EO Validator Agent applies deterministic format-checks before invoking the LLM quality gate — ensuring that AI creativity operates within strict structural and quality boundaries.
- **Fail-Fast Validation with Bounded Retry:** Each artifact passes through the EO Validator immediately after generation. Up to three validation cycles are attempted before an artifact is flagged for human review, bounding the cost of validation failures and protecting the 95% pass-rate SLA.
- **Immutable Artifact Lineage:** Every generated artifact is versioned in S3 and its metadata (generation timestamp, model version, validation outcome, artifact S3 location) is persisted to DynamoDB. This provides a tamper-evident audit trail for governance and quality review.
- **Cost Attribution by Design:** Per-phase Bedrock token usage is emitted as custom CloudWatch metrics on every generation run, enabling per-solution cost attribution from day one without requiring post-hoc log analysis.

## Architecture Patterns

The platform applies the following architectural patterns to address the core design challenges:

- **Primary Pattern:** Directed Multi-Agent Graph — five specialised agents orchestrated by the Strands framework on AgentCore Runtime, each responsible for a defined production scope, communicating via structured pass/fail envelopes
- **Data Pattern:** Event-Driven State Machine — solution generation state is tracked in DynamoDB with atomic status transitions; agents consume and produce state transitions rather than shared mutable state
- **Integration Pattern:** PAT-Based GitHub Commit Pipeline — asynchronous artifact publication to GitHub after successful generation and validation, decoupled from the synchronous API response path
- **Deployment Pattern:** Blue-Green Lambda Alias Swap — production cutover uses Lambda alias routing to switch traffic from the previous version to the new version with zero-downtime rollback capability
- **Validation Pattern:** Deterministic + LLM Cascade — format-check (structural rules, zero false negatives) runs first; LLM quality check (content completeness, contextual accuracy) runs only when format-check passes, minimising Haiku token spend

## Component Design

The platform comprises twelve distinct compute components — five agents, six Lambda route handlers, and one post-confirmation trigger — plus the supporting AWS managed services. The following table describes each major functional component:

<!-- TABLE_CONFIG: widths=[18, 25, 22, 18, 17] -->
| Component | Purpose | Technology | Dependencies | Scaling |
|-----------|---------|------------|--------------|---------|
| Input Validator Agent | Parse and validate client brief JSON against EO Framework brief schema | Strands Agent, AgentCore Runtime, Python | Bedrock (schema validation), DynamoDB (solution record create) | AgentCore Runtime auto-scales |
| Pre-Sales Generator Agent | Orchestrate 5-artifact presales workflow (briefing, costs, LOE, SOW, proposal) | Strands Agent, AgentCore Runtime, Claude Sonnet 4.6 | Input Validator, EO Validator, S3, DynamoDB | AgentCore Runtime auto-scales |
| Delivery Generator Agent | Orchestrate 6-artifact delivery workflow (charter, plan, RAID, runbooks, test plan, closure) | Strands Agent, AgentCore Runtime, Claude Sonnet 4.6 | Pre-Sales Generator, EO Validator, S3, DynamoDB | AgentCore Runtime auto-scales |
| Code Generator Agent | Produce Terraform IaC for 5 core AWS services with `terraform validate` gate | Strands Agent, AgentCore Runtime, Python subprocess | Delivery Generator, S3 (bundle output), ECR | AgentCore Runtime auto-scales |
| EO Validator Agent | Deterministic format-check + Haiku 4.5 LLM quality gate with 3-retry logic | Strands Agent, AgentCore Runtime, Claude Haiku 4.5 | S3 (artifact read), DynamoDB (validation record) | AgentCore Runtime auto-scales |
| Solution Create Lambda | Accept solution generation request; enforce quota; invoke multi-agent graph | AWS Lambda (Python 3.12), API Gateway HTTP API v2 | Cognito JWT, DynamoDB, AgentCore Runtime | Lambda auto-scales (concurrency limit: 50) |
| Solution Status Lambda | Return solution generation status and per-phase token usage | AWS Lambda (Python 3.12), API Gateway HTTP API v2 | Cognito JWT, DynamoDB | Lambda auto-scales |
| Artifact Fetch Lambda | Return presigned S3 URL for artifact download | AWS Lambda (Python 3.12), API Gateway HTTP API v2 | Cognito JWT, S3, DynamoDB | Lambda auto-scales |
| User Profile Lambda | Return and update authenticated user profile and quota status | AWS Lambda (Python 3.12), API Gateway HTTP API v2 | Cognito JWT, DynamoDB | Lambda auto-scales |
| Quota Check Lambda | Return current per-user and global quota consumption | AWS Lambda (Python 3.12), API Gateway HTTP API v2 | Cognito JWT, DynamoDB | Lambda auto-scales |
| Admin Usage Lambda | Return aggregate per-phase token usage and platform throughput metrics | AWS Lambda (Python 3.12), API Gateway HTTP API v2 | Cognito JWT (admin group), DynamoDB, CloudWatch | Lambda auto-scales |
| Cognito Post-Confirmation Lambda | Trigger on user registration; write user profile to DynamoDB; seed quota counter at zero | AWS Lambda (Python 3.12), Cognito User Pool trigger | DynamoDB (Users table), IAM | Lambda auto-scales |

## Technology Stack

The following table defines the technology stack for the platform, with rationale for each choice tracing directly to the presales commitments:

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Layer | Technology | Rationale |
|-------|------------|-----------|
| Agent Framework | Strands Agents (AWS) | AWS-native multi-agent orchestration framework; native AgentCore Runtime integration; aligns with SOW agent design commitment |
| Agent Hosting | Bedrock AgentCore Runtime | Managed serverless agent hosting; no infrastructure to operate; scales independently per agent; eliminates container cluster management |
| Primary Generation Model | Claude Sonnet 4.6 (via Amazon Bedrock) | Highest-quality artifact generation for EO Framework content; RS256-signed API access; metered per-token cost attributable per solution |
| Validation Model | Claude Haiku 4.5 (via Amazon Bedrock) | Cost-efficient validation passes; 3x lower cost than Sonnet for quality-check prompts; achieves <$5 total model spend per solution |
| API Surface | Amazon API Gateway HTTP API v2 | Low-latency, low-cost HTTP API with native JWT authoriser for Cognito integration; 11 Lambda routes behind a single managed endpoint |
| Authentication | Amazon Cognito User Pools | AWS-native identity for 120 consultant MAUs; RS256 JWT issuance; 30-day refresh tokens; post-confirmation Lambda trigger; SOW commitment |
| Compute | AWS Lambda (Python 3.12) | Serverless; zero idle cost; auto-scaling; native integration with all platform AWS services; supports concurrency limits for quota protection |
| Data / Quotas | Amazon DynamoDB (on-demand) | Sub-millisecond conditional writes for atomic quota enforcement; PITR for data recovery; KMS encryption; PAY_PER_REQUEST billing |
| Artifact Storage | Amazon S3 | Object storage for raw MD/CSV source and converted DOCX/PPTX/XLSX artifacts; versioning; lifecycle to Intelligent-Tiering after 90 days |
| Container Registry | Amazon ECR | Stores eof-tools agent Docker images; immutable image digests; vulnerability scanning on push |
| CI/CD | AWS CodeBuild | Docker image build pipeline; automated ECR push; `terraform plan` gate for IaC changes |
| Infrastructure as Code | Terraform (HashiCorp) | Platform provisioning for all five core services; Code Generator output artifact; `terraform validate` gate |
| Observability | Amazon CloudWatch (Logs, Metrics, Dashboards, Alarms) | Per-phase token usage metrics; Lambda error rates; quota utilisation dashboards; alarm notifications |
| Secret Management | AWS Secrets Manager | GitHub PAT, Cognito client secrets, API keys; runtime retrieval; no secrets in Lambda environment variables |
| Audit | AWS CloudTrail | Full API call audit log for all Bedrock invocations, DynamoDB writes, S3 uploads, and Secrets Manager accesses |
| Network Security | AWS WAF | IP-based rate limiting; OWASP Common Rule Set; custom JWT `iss` claim rule; attached to API Gateway stage |
| Source Control / Publishing | GitHub (PAT-based), PyPI | Artifact commit pipeline; pip-installable CLI distribution |
| CLI Framework | Python, Click | 14-subcommand pip-installable CLI; JWT token handling; `--api-url` flag for environment switching |

---

# Security & Compliance

Security is a foundational design principle for the Amatra Agentic Orchestration Platform. The platform handles authenticated user sessions, stores AI-generated intellectual property artifacts, commits code to public GitHub repositories, and makes metered API calls to AWS Bedrock — each surface requires deliberate, layered security controls. The security architecture follows a defence-in-depth model covering identity, access management, network security, data protection, detective controls, and governance.

## Identity & Access Management

Amazon Cognito User Pools is the authoritative identity provider for all human users of the platform. Each PREDICTif consultant registers via a self-service flow; the Cognito post-confirmation Lambda trigger fires immediately upon email verification, writing the user profile to DynamoDB and initialising the quota counter. Authentication produces a JWT access token (1-hour expiry, RS256-signed) and a refresh token (30-day expiry). The API Gateway HTTP API v2 JWT authoriser validates every inbound request against the Cognito JWKS endpoint — unauthenticated requests receive a `401 Unauthorized` response before reaching any Lambda function.

- **Authentication:** Amazon Cognito User Pools; RS256 JWT access tokens (1-hour expiry); 30-day refresh tokens
- **Authorisation:** Cognito User Pool Groups (`consultants`, `admin`) mapped to IAM policy boundaries; API Gateway JWT authoriser enforces group scope on protected routes
- **MFA:** Cognito TOTP MFA configured as optional for initial release; can be made mandatory via User Pool policy update without platform changes
- **Service Accounts:** Lambda execution roles provisioned via Terraform with least-privilege IAM policies; no shared credentials; no wildcard resource ARNs

### Role Definitions

The following roles are defined in the platform's access model, covering both human users and service principals:

<!-- TABLE_CONFIG: widths=[20, 40, 40] -->
| Role | Permissions | Scope |
|------|-------------|-------|
| Consultant (Cognito Group) | Submit solution generation requests; download own artifacts; check own quota | Production API routes: `/solution/*`, `/artifact/*`, `/user/profile` |
| Admin (Cognito Group) | All Consultant permissions + access to admin usage endpoint and quota override | All production routes including `GET /admin/usage` |
| Pre-Sales Generator Lambda Role | `bedrock:InvokeModel` (Sonnet 4.6 ARN), `dynamodb:GetItem/UpdateItem` (Solutions table), `s3:PutObject` (`/raw/` prefix) | us-west-2, specific ARNs only |
| EO Validator Lambda Role | `bedrock:InvokeModel` (Haiku 4.5 ARN), `s3:GetObject` (artifacts bucket), `dynamodb:UpdateItem` (Solutions table) | us-west-2, specific ARNs only |
| Code Generator Lambda Role | `s3:PutObject` (Terraform bundle prefix), `secretsmanager:GetSecretValue` (GitHub PAT ARN) | us-west-2, specific ARNs only |
| Cognito Post-Confirmation Role | `dynamodb:PutItem` (Users table), `dynamodb:UpdateItem` (GlobalQuota table) | us-west-2, specific ARNs only |
| DevOps/Admin (IAM User, build phase) | Terraform apply, ECR push, CloudWatch configuration | Revoked post-hypercare; replaced by Daniel Park's team admin access |

## Secrets Management

All platform secrets are stored in AWS Secrets Manager and retrieved by Lambda functions at runtime via the Secrets Manager SDK. No secrets are stored in Lambda environment variables, S3 objects, or source control.

- **GitHub Personal Access Token:** Stored as a Secrets Manager secret (`amatra/github/pat`); retrieved by the GitHub integration Lambda at runtime; rotated quarterly using a manual rotation procedure defined in the operational runbook
- **Cognito App Client Secret:** Stored as a Secrets Manager secret (`amatra/cognito/client-secret`); used by the CLI for PKCE token exchange; rotated on-demand
- **Rotation Policy:** GitHub PAT rotated quarterly; Cognito client secret rotated on-demand or on security incident; all rotation events logged in CloudTrail
- **Access Logging:** All `GetSecretValue` API calls are captured in CloudTrail; CloudWatch alarms fire if unexpected IAM principals access any Secrets Manager secret

## Network Security

All platform components are deployed as serverless AWS managed services — there are no VPCs, no EC2 instances, and no customer-managed network infrastructure. Network security is enforced at the API Gateway and IAM layers.

- **Segmentation:** API Gateway HTTP API v2 is the single public ingress point; all Lambda-to-service communication (DynamoDB, S3, Bedrock, Secrets Manager, ECR) traverses the AWS internal network fabric via IAM-authenticated API calls
- **Firewall:** AWS WAF attached to the API Gateway HTTP API v2 stage enforcing IP-based rate limiting (100 requests/IP/minute) and AWS Managed Rules Common Rule Set
- **WAF:** Custom WAF rule blocks requests with invalid JWT `iss` claims before reaching Lambda authoriser; WAF findings logged to CloudWatch Logs
- **DDoS Protection:** AWS Shield Standard (included with API Gateway) provides automatic DDoS protection for the API Gateway endpoint
- **Outbound:** GitHub commits via HTTPS over public internet; GitHub PAT retrieved from Secrets Manager at runtime and never logged

## Data Protection

All data stored or transmitted by the platform is encrypted using AWS-managed services and standard protocols.

- **Encryption at Rest:** DynamoDB tables encrypted with AWS-managed CMK (`aws/dynamodb`); S3 buckets encrypted with SSE-S3 (AES-256) with upgrade path to SSE-KMS for regulated data; ECR images encrypted at rest; Secrets Manager uses AWS KMS by default
- **Encryption in Transit:** TLS 1.2 minimum enforced by API Gateway; all AWS SDK calls from Lambda use HTTPS; GitHub artifact commits use HTTPS
- **Key Management:** AWS-managed KMS keys for DynamoDB and S3; Cognito RS256 key pair managed by Cognito; no customer-managed CMKs required for the initial release
- **Data Masking:** Synthetic test briefs and mock artifacts only in dev and staging; no production data (real client briefs) in non-production environments

## Compliance Mappings

The platform implements the following controls mapped to PREDICTif Solutions' compliance posture:

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Framework | Requirement | Implementation |
|-----------|-------------|----------------|
| SOC 2 (CC6.1) | Logical and physical access controls | Cognito JWT authentication; IAM least-privilege Lambda roles; Cognito User Pool Groups for authorisation |
| SOC 2 (CC7.2) | System monitoring | CloudWatch metrics, dashboards, and alarms; CloudTrail API audit; structured Lambda logging |
| SOC 2 (CC6.7) | Transmission and disposal of information | TLS 1.2+ for all data in transit; S3 lifecycle rules for artifact expiry; DynamoDB PITR for recovery |
| SOC 2 (CC9.2) | Risk mitigation for vendors | AWS Bedrock and AgentCore Runtime are AWS-managed; per-solution quota caps limit financial exposure |
| Internal Quota Governance | Per-user and global AI spend controls | DynamoDB atomic conditional writes enforcing 10 solutions/user/month and 1,000 solutions/month globally |

## Audit Logging & SIEM Integration

The platform produces a comprehensive audit trail across all generation, authentication, and administrative events through the following logging architecture:

- **What is Logged:** CloudTrail captures all management and data-plane API calls — every Bedrock model invocation, DynamoDB write (including quota counter changes and solution metadata updates), S3 artifact upload, Secrets Manager `GetSecretValue` call, Lambda execution, Cognito authentication event, and API Gateway request
- **Retention Policy:** CloudTrail logs retained in a dedicated S3 bucket with server-side encryption and MFA delete enabled; CloudWatch Lambda log groups configured with 30-day retention; DynamoDB PITR provides 35-day point-in-time recovery window
- **SIEM Integration:** CloudTrail logs forwarded to CloudWatch Logs for real-time alerting; CloudWatch Alarms trigger on suspicious patterns (repeated auth failures, quota counter manipulation outside application code path, `GetSecretValue` from unexpected principals); SIEM forwarding (e.g., Splunk, Datadog) can be added post-hypercare via CloudWatch Logs subscription filters without platform changes

---

# Data Architecture

The Amatra Agentic Orchestration Platform uses three purpose-built AWS data stores, each optimised for its specific workload: DynamoDB for operational metadata and atomic quota enforcement, S3 for artifact object storage, and ECR for versioned agent container images. The data architecture is designed for durability, recoverability, and cost efficiency — with PITR on DynamoDB, versioning on S3, and immutable digest pinning on ECR providing multi-layer data integrity guarantees.

## Data Model

### Conceptual Model

The platform's data model centres on three core domains: **Users** (identity, profile, and quota state), **Solutions** (generation requests, status, and artifact locations), and **Artifacts** (the generated EO Framework documents stored as S3 objects). Users initiate Solutions; Solutions produce Artifacts. A GlobalQuota record enforces the platform-wide generation ceiling, preventing uncontrolled Bedrock spend regardless of individual user quota availability.

### Logical Model

The following table defines the DynamoDB entities and their key attributes, relationships, and expected data volumes at 200 solutions/month steady state:

<!-- TABLE_CONFIG: widths=[20, 25, 30, 25] -->
| Entity | Key Attributes | Relationships | Volume |
|--------|----------------|---------------|--------|
| User | `userId` (PK, Cognito `sub`), `email`, `quotaUsed` (current month), `quotaMonth` (YYYY-MM), `createdAt`, `lastActiveAt` | One User → Many Solutions | ~120 records; low write volume |
| Solution | `solutionId` (PK, UUID), `userId` (SK), `status` (PENDING/IN_PROGRESS/COMPLETE/FAILED), `phase` (current agent), `artifactLocations` (map), `tokenUsage` (phase breakdown), `createdAt`, `completedAt` | One Solution → One User (FK); One Solution → Many Artifacts (S3 refs) | ~200/month; moderate write volume (status updates) |
| GlobalQuota | `month` (PK, YYYY-MM), `solutionsGenerated` (atomic counter) | Referenced by Solution Create Lambda | 1 active record; high conditional write volume during peak |
| ArtifactMetadata | `artifactId` (PK, UUID), `solutionId`, `artifactType` (e.g., `statement-of-work`), `phase` (presales/delivery/automation), `s3Key`, `validationStatus`, `generatedAt` | Many Artifacts → One Solution | ~2,400/month (12 per solution × 200 solutions) |

### DynamoDB Table Design

The platform provisions three DynamoDB tables, all in on-demand (PAY_PER_REQUEST) billing mode with PITR enabled and AWS-managed KMS encryption:

- **UsersTable** — Partition key: `userId` (String). Stores user profiles and per-user monthly quota counters. The `quotaMonth` attribute enables atomic reset of `quotaUsed` counter at the start of each calendar month without a batch job.
- **SolutionsTable** — Partition key: `solutionId` (String), Sort key: `userId` (String). Stores solution generation metadata, status, phase tracking, per-phase token usage, and S3 artifact location map. A Global Secondary Index on `userId` + `createdAt` supports the CLI `solution list` subcommand.
- **GlobalQuotaTable** — Partition key: `month` (String, format YYYY-MM). Single-record atomic counter enforced via DynamoDB conditional write (`ConditionExpression: solutionsGenerated < :limit`). If the condition fails, the Solution Create Lambda returns a `429 Too Many Requests` response to the API caller.

## Data Flow Design

The following sequence describes how data moves through the platform during a single solution generation request — from CLI brief submission to artifact commit:

1. **Ingestion:** The consultant submits a JSON brief via the CLI (`solution generate --brief brief.json`); the CLI sends a JWT-authenticated `POST /solution` request to API Gateway HTTP API v2
2. **Quota Validation:** The Solution Create Lambda performs a DynamoDB conditional write to increment `GlobalQuota.solutionsGenerated` (must be < 1,000) and `User.quotaUsed` (must be < 10); if either condition fails, the request is rejected with `429 Too Many Requests` before any Bedrock spend occurs
3. **Agent Invocation:** On successful quota allocation, the Lambda creates a Solution record in DynamoDB (`status: IN_PROGRESS`) and invokes the Strands multi-agent graph via AgentCore Runtime; the brief JSON and solution ID are passed as the agent invocation payload
4. **Validation & Storage:** The Input Validator Agent parses and validates the brief; the Pre-Sales Generator Agent produces five presales artifact markdown/CSV files; each is passed to the EO Validator Agent for format-check and LLM quality review; on pass, the artifact is written to S3 (`{solutionId}/raw/pre-sales/{artifact-name}`)
5. **Delivery Generation:** The Delivery Generator Agent produces six delivery artifacts following the same generation → validation → S3 write pattern; the Code Generator Agent produces the Terraform bundle and runs `terraform validate` before S3 write
6. **Artifact Publication:** The GitHub integration Lambda commits all twelve artifacts from S3 to the fixed public GitHub repository via HTTPS PAT authentication; artifact S3 locations and commit SHA are written to the Solution record in DynamoDB
7. **Status Update:** The Solution Create Lambda updates the Solution record to `status: COMPLETE` with `completedAt` timestamp and per-phase token usage breakdown; CloudWatch custom metrics are emitted for each phase's token consumption

## Data Migration Strategy

This is a greenfield implementation — there is no existing platform data to migrate. The following points govern the initial data bootstrap:

- **Approach:** No migration required; the DynamoDB tables are provisioned empty via Terraform and populated organically through platform usage
- **EO Framework Guidance Files:** Pre-populated to S3 before Phase 2 agent development begins; client responsibility (Dependency D3 per SOW)
- **Validation:** eof-tools converter library integration is validated against all twelve artifact types in staging before production deployment
- **Rollback:** DynamoDB PITR is enabled from the moment tables are provisioned; any corrupted state during testing can be restored to a clean point-in-time snapshot

## Data Governance

The platform's data governance model covers classification, retention, quality enforcement, and access control:

- **Classification:** Client briefs and generated artifacts are classified as PREDICTif Confidential; token usage metrics and quota counters are classified as Internal; CloudTrail audit logs are classified as Internal/Audit
- **Retention:** S3 artifacts retained for active lifecycle; objects older than 90 days transitioned to S3 Intelligent-Tiering; DynamoDB PITR provides 35-day recovery window; CloudTrail logs retained per S3 lifecycle policy (minimum 1 year recommended)
- **Quality:** The EO Validator Agent enforces artifact quality at generation time — format-check validates structural correctness; Haiku 4.5 quality gate validates content completeness; artifacts that fail after three retries are flagged with `status: VALIDATION_FAILED` in DynamoDB and not committed to GitHub
- **Access:** S3 artifacts are accessible only via Lambda presigned URLs issued by the Artifact Fetch Lambda to authenticated users; direct S3 public access is blocked on all buckets; cross-user artifact access is prevented by a Lambda-side `userId` ownership check before presigned URL generation

---

# Integration Design

The Amatra Agentic Orchestration Platform integrates with three external systems — GitHub (artifact publication), the eof-tools converter library (DOCX/PPTX/XLSX conversion), and DynamoDB (quota enforcement as an internal integration boundary) — plus exposes an HTTP API consumed by the pip-installable CLI. Integration design follows an asynchronous, event-driven pattern for artifact publication and a synchronous request-response pattern for the API surface. All integrations are secured with credentials stored in Secrets Manager and audited via CloudTrail.

## External System Integrations

The following table summarises all external system integrations in scope for this engagement:

<!-- TABLE_CONFIG: widths=[18, 15, 15, 15, 22, 15] -->
| System | Type | Protocol | Format | Error Handling | SLA |
|--------|------|----------|--------|----------------|-----|
| GitHub (artifact commit) | Asynchronous, post-generation | HTTPS REST (GitHub API v3) | JSON API payload + raw file content | Retry up to 3 times on 5xx; DLQ for persistent failures; alert Daniel Park's team | Best-effort; generation considered complete even if GitHub commit fails (S3 artifacts are authoritative) |
| eof-tools converter library | Synchronous, in-process | Python function call (in container) | Markdown/CSV input → DOCX/PPTX/XLSX output | Converter exception caught and surfaced as artifact conversion failure; EO Validator flags artifact | Must complete within Lambda timeout (15 min max) |
| Amazon Bedrock (Claude Sonnet 4.6) | Synchronous, per-artifact | AWS SDK (InvokeModel API) | JSON request/response with base64-encoded content | Bedrock throttling triggers exponential backoff; up to 3 retries; after 3 failures artifact is failed | Bedrock p99 latency target; generation must complete within 60-minute end-to-end budget |
| Amazon Bedrock (Claude Haiku 4.5) | Synchronous, per-artifact validation | AWS SDK (InvokeModel API) | JSON request/response | Same retry pattern as Sonnet; Haiku retry budget shared with the 3-retry envelope | Haiku is faster and cheaper; quality-check call typically completes in < 10 seconds |

## API Design

The platform exposes a RESTful HTTP API via Amazon API Gateway HTTP API v2. All routes are JWT-protected using the Cognito User Pool JWT authoriser. The API follows REST conventions with URL path versioning.

- **Style:** REST over HTTPS
- **Versioning:** URL path versioning (`/v1/...`); initial release is `v1`; future versions are introduced alongside `v1` without breaking existing clients
- **Authentication:** Cognito JWT Bearer token in the `Authorization: Bearer <token>` header; validated by API Gateway JWT authoriser against Cognito JWKS before Lambda invocation
- **Rate Limiting:** API Gateway default throttling (10,000 requests/second burst; 5,000 requests/second steady state); WAF IP-based rate limiting at 100 requests/IP/minute for DDoS protection

### API Endpoints

The following table defines all eleven Lambda route handlers exposed by the API:

<!-- TABLE_CONFIG: widths=[10, 40, 20, 30] -->
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | /v1/solution | Bearer (any group) | Submit a new solution generation request; returns `solutionId` and initial status |
| GET | /v1/solution/{solutionId} | Bearer (owner or admin) | Return solution status, current phase, and per-phase token usage |
| GET | /v1/solution/{solutionId}/artifacts | Bearer (owner or admin) | Return list of generated artifact types and their S3 presigned download URLs |
| DELETE | /v1/solution/{solutionId} | Bearer (owner or admin) | Cancel an in-progress solution or delete a completed solution record |
| GET | /v1/solutions | Bearer (any group) | List all solutions for the authenticated user, paginated by `createdAt` descending |
| GET | /v1/user/profile | Bearer (any group) | Return authenticated user's profile, quota used, and quota remaining for the current month |
| PUT | /v1/user/profile | Bearer (any group) | Update user profile display name and preferences |
| GET | /v1/quota | Bearer (any group) | Return current per-user and global quota consumption for the current month |
| POST | /v1/auth/refresh | Bearer (refresh token) | Exchange a Cognito refresh token for a new access token |
| GET | /v1/admin/usage | Bearer (admin group only) | Return aggregate per-phase token usage, solution throughput, and cost metrics |
| POST | /v1/admin/quota/reset | Bearer (admin group only) | Override quota counters for a specific user or reset the global monthly counter |

## Authentication & SSO Flows

The platform implements JWT-based authentication using Cognito User Pools, with the following flows supporting the CLI and API consumers:

- **User Registration:** Self-service via Cognito hosted UI or CLI `auth register` subcommand; Cognito sends email verification; on confirmation, post-confirmation Lambda writes user profile to DynamoDB and seeds quota counter at zero
- **CLI Login Flow:** CLI `auth login` subcommand executes the Cognito USER_PASSWORD_AUTH flow; on success, stores JWT access token and refresh token in the local `~/.amatra/credentials` file (mode 0600)
- **API Request Flow:** CLI prepends `Authorization: Bearer {access_token}` to every API request; API Gateway JWT authoriser validates the token against Cognito JWKS; on expiry, the CLI transparently refreshes using `POST /v1/auth/refresh` before retrying the original request
- **Token Management:** Access tokens expire after 1 hour; refresh tokens expire after 30 days; the CLI tracks token expiry and proactively refreshes before sending API requests to avoid mid-generation authentication failures
- **Service-to-Service Auth:** Lambda functions authenticate to AWS services (DynamoDB, S3, Bedrock, Secrets Manager) exclusively via IAM execution role credentials — no JWT tokens are used for service-to-service calls

## Messaging & Event Patterns

The platform uses an event-driven pattern for the agent orchestration pipeline, with DynamoDB serving as the state store for solution lifecycle events:

- **Agent Orchestration:** The Strands multi-agent graph on AgentCore Runtime uses an internal event-passing mechanism between agents; agent outputs (artifact content, validation results) are passed as structured JSON payloads to the next agent in the graph
- **Queue Service:** No SQS queue is required for the initial release — the AgentCore Runtime manages agent invocation queuing internally; if concurrent solution volume exceeds AgentCore Runtime concurrency limits in a future phase, an SQS queue can be introduced between the Solution Create Lambda and the agent graph invocation
- **Dead Letter Queue:** GitHub commit failures after three retries are logged to a CloudWatch Log Group (`/amatra/github-commit-failures`) and trigger a CloudWatch Alarm notification to Daniel Park's operations team; a manual re-trigger procedure is documented in the operational runbook
- **Retry Policy:** All AWS SDK calls from Lambda functions implement exponential backoff with jitter: initial delay 100ms, backoff factor 2x, maximum delay 10 seconds, maximum 3 retries; Bedrock throttling errors are retried with longer initial delay (1 second) given the LLM generation context

---

# Infrastructure & Operations

The Amatra Agentic Orchestration Platform is a fully serverless infrastructure — there are no EC2 instances, no VPC subnets to manage, and no container orchestrators to operate. All compute is AWS-managed (Lambda, AgentCore Runtime), all storage is managed (DynamoDB, S3, ECR), and all network security is enforced at the API Gateway and IAM layers. This section describes the compute sizing, high-availability design, disaster recovery targets, monitoring architecture, and cost model for the platform.

## Network Design

The platform operates entirely on AWS-managed service endpoints with no customer-managed VPC required. The following describes the logical network topology:

- **Public Ingress:** API Gateway HTTP API v2 serves as the single public HTTPS endpoint; DNS record points to the API Gateway custom domain; TLS certificate managed by AWS Certificate Manager
- **Internal Communication:** All Lambda-to-AWS-service calls (DynamoDB, S3, Bedrock, Secrets Manager, ECR, CloudWatch) use AWS PrivateLink-equivalent internal routing via IAM-authenticated SDK calls — traffic never traverses the public internet
- **Outbound:** GitHub artifact commits use HTTPS over the public internet; the GitHub PAT is retrieved from Secrets Manager at runtime; outbound requests originate from Lambda's managed network address (no fixed IP required for GitHub allow-listing)
- **WAF:** AWS WAF attached to the API Gateway stage enforces IP rate limits and OWASP rules at the network edge before requests reach any Lambda function
- **Environment Isolation:** Dev, staging, and production environments are isolated at the IAM policy and S3 prefix level within the us-west-2 account; separate API Gateway stages and Lambda aliases are used for each environment

## Compute Sizing

The following table defines the Lambda function sizing and concurrency configuration for all platform functions:

<!-- TABLE_CONFIG: widths=[25, 20, 20, 20, 15] -->
| Component | Runtime | Memory | Timeout | Concurrency Limit |
|-----------|---------|--------|---------|-------------------|
| Solution Create Lambda | Python 3.12 | 512 MB | 30 seconds | 50 |
| Solution Status Lambda | Python 3.12 | 256 MB | 10 seconds | 100 |
| Artifact Fetch Lambda | Python 3.12 | 256 MB | 10 seconds | 100 |
| User Profile Lambda | Python 3.12 | 256 MB | 10 seconds | 100 |
| Quota Check Lambda | Python 3.12 | 256 MB | 10 seconds | 100 |
| Admin Usage Lambda | Python 3.12 | 256 MB | 15 seconds | 10 |
| Auth Refresh Lambda | Python 3.12 | 256 MB | 10 seconds | 100 |
| Solutions List Lambda | Python 3.12 | 256 MB | 10 seconds | 100 |
| Quota Reset Lambda (Admin) | Python 3.12 | 256 MB | 10 seconds | 5 |
| Cognito Post-Confirmation Lambda | Python 3.12 | 256 MB | 15 seconds | 50 |
| GitHub Integration Lambda | Python 3.12 | 512 MB | 60 seconds | 20 |
| AgentCore Runtime (per agent) | Managed container | Managed | Managed | 10 per agent |

*Note: AgentCore Runtime agent sizing is managed by AWS — memory and timeout are configured at agent registration time via the AgentCore Runtime API, not Lambda configuration.*

## High Availability Design

The platform achieves high availability through the inherent multi-AZ design of all AWS managed services deployed:

- **Multi-AZ:** API Gateway HTTP API v2, Lambda, DynamoDB (on-demand), S3, Cognito User Pools, and AgentCore Runtime are all AWS-managed services that operate across multiple Availability Zones in us-west-2 by default — no additional configuration is required
- **Failover Strategy:** AWS manages failover transparently for all serverless components; there is no customer-managed failover logic; the platform's availability SLA (99.5%) is directly backed by the individual service SLAs of the constituent AWS services
- **Health Checks:** CloudWatch Synthetic Canaries run every 5 minutes against the `GET /v1/quota` endpoint (lightweight, no Bedrock spend) to confirm end-to-end API Gateway → Lambda → DynamoDB availability; canary failures trigger a CloudWatch Alarm notification to Daniel Park's team
- **Cold Start Mitigation:** Lambda Provisioned Concurrency is configured for the Solution Create Lambda (2 instances) and the Solution Status Lambda (2 instances) in production to eliminate cold-start latency for the most frequently called routes; all other functions use on-demand concurrency

## Disaster Recovery

The platform is designed to meet an RTO of 2 hours and an RPO of 1 hour for the production us-west-2 deployment. Recovery procedures are documented in the operational runbooks delivered at project close.

- **RPO (1 hour):** DynamoDB PITR provides continuous backup with sub-second granularity; S3 object versioning enables recovery from any point in the object's lifecycle; in practice, RPO is measured in seconds for DynamoDB and S3
- **RTO (2 hours):** The platform has no stateful compute to recover — Lambda and AgentCore Runtime are restored by AWS automatically; DynamoDB table restoration from PITR is the primary recovery procedure (estimated 30–60 minutes for table sizes anticipated at launch); S3 versioned artifact recovery is instantaneous
- **Backup Strategy:** DynamoDB PITR enabled on all three tables from provisioning; S3 versioning enabled on the artifacts bucket from provisioning; ECR image digests are immutable — previous agent container images are always retrievable
- **DR Site:** Single-region deployment (us-west-2) for the initial proof-of-concept; multi-region failover is deferred to Phase 2 per the SOW out-of-scope boundary

## Monitoring & Alerting

CloudWatch is the primary observability platform for the Amatra Agentic Orchestration Platform. Lambda functions emit structured JSON logs and custom metrics; DynamoDB and API Gateway emit service-native metrics; Bedrock token usage is tracked as a custom metric per generation phase.

- **Infrastructure Metrics:** Lambda invocation count, duration p50/p95/p99, error rate, throttle count; DynamoDB consumed read/write capacity units, throttled requests; API Gateway request count, 4xx rate, 5xx rate, latency p95
- **Application Metrics:** Per-solution end-to-end generation duration; per-artifact validation pass/fail count; EO Validator retry count distribution; GitHub commit success/failure rate
- **Business Metrics (KPIs):** Solutions generated per day/week/month; per-user quota utilisation; global quota utilisation percentage; Bedrock token spend per solution (Sonnet + Haiku combined); CloudWatch dashboard for Sarah Lin / Marcus Patel visibility
- **Alerting Integration:** CloudWatch Alarms notify Daniel Park's operations team via SNS → email; critical alarms (platform down, Lambda error rate > 5%) also trigger a PagerDuty-compatible webhook if configured post-hypercare

### Alert Definitions

The following alerts are configured in production from day one of go-live:

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Alert | Condition | Severity | Response |
|-------|-----------|----------|----------|
| Platform Availability Degraded | CloudWatch Canary failure for 2 consecutive 5-minute periods | Critical (P1) | Immediate notification to Daniel Park; incident declared; rollback candidate if recently deployed |
| Lambda Error Rate High | Any Lambda error rate > 5% over 5-minute period | High (P2) | Notification to Daniel Park; check CloudWatch Logs for error pattern; rollback if deployment-correlated |
| Global Quota Near Limit | `GlobalQuota.solutionsGenerated` > 900 (90% of 1,000) | High (P2) | Notification to Marcus Patel and Daniel Park; assess if quota increase needed for month-end |
| User Quota Exceeded Attempts | > 5 `429 Too Many Requests` responses for a single `userId` in 1 hour | Medium (P3) | Notification to Daniel Park; check if consultant has legitimate high-volume need for quota override |
| Bedrock Token Spend Anomaly | Per-solution token spend > $10 (2× expected budget) | Medium (P3) | Notification to Daniel Park; investigate prompt injection or runaway retry loops |
| GitHub Commit Failure | GitHub integration Lambda DLQ message count > 0 | Medium (P3) | Notification to Daniel Park; artifacts are safe in S3; manual re-trigger procedure in runbook |
| CloudTrail Suspicious Access | `GetSecretValue` from non-approved Lambda IAM principal | High (P2) | Immediate notification; automated IAM policy evaluation via Access Analyzer |
| DynamoDB Throttling | Any DynamoDB throttled request count > 10 over 5-minute period | Medium (P3) | Notification to Daniel Park; on-demand billing should prevent throttling; investigate unexpected write patterns |

## Logging & Observability

The platform implements structured logging and distributed observability across all components, enabling rapid root-cause analysis of generation failures:

- **Log Aggregation:** All Lambda functions log structured JSON to CloudWatch Log Groups (`/aws/lambda/{function-name}`) with 30-day retention; AgentCore Runtime agent logs are surfaced via CloudWatch Log Groups created at agent registration time
- **Tracing:** AWS X-Ray is enabled on all Lambda functions and API Gateway stage; trace spans cover API Gateway → Lambda → DynamoDB and Lambda → Bedrock calls, enabling end-to-end latency attribution per solution generation request
- **Dashboards:** Four CloudWatch dashboards are delivered at go-live: (1) Platform Health (Lambda errors, DynamoDB throttles, API Gateway 4xx/5xx), (2) Solution Throughput (solutions/day, artifact types generated, validation pass rate), (3) Cost Telemetry (Bedrock token spend by model and phase, per-solution cost trend), (4) Quota Utilisation (per-user and global quota consumption heat map)

## Cost Model

The following cost model reflects the platform's annual infrastructure spend at approximately 200 solutions/month steady state, drawn directly from the infrastructure cost model in the presales artifacts. Year 2 and Year 3 figures reflect approximately 20% year-over-year growth in Bedrock token volume as solution throughput scales.

<!-- TABLE_CONFIG: widths=[30, 25, 25, 20] -->
| Category | Annual Cost (Year 1) | Optimization Approach | Projected Savings |
|----------|---------------------|----------------------|-------------------|
| Amazon Bedrock (Sonnet 4.6) | $18,000 | Generation prompt optimisation to reduce token count per artifact | 10–15% in Year 2 |
| AgentCore Runtime | $9,600 | Flat-rate steady-state pricing; no further optimisation needed | — |
| Amazon CloudWatch | $2,400 | Log retention tuning (30-day policy); metric filter limits | 5–10% |
| Amazon DynamoDB | $300 | On-demand billing already optimised for variable workload; no Reserved Capacity needed | — |
| Amazon S3 | $138 | Lifecycle rule to S3 Intelligent-Tiering at 90 days | 20–30% on aged objects |
| Amazon Bedrock (Haiku 4.5) | $1,800 | Haiku already the cost-efficient validation choice; maintain current usage | — |
| API Gateway HTTP API | $216 | HTTP API v2 already lowest-cost API Gateway option | — |
| AWS Lambda | $26 | Negligible at current invocation volume | — |
| Amazon Cognito | $120 | MAU pricing is fixed; no optimisation lever | — |
| Amazon ECR | $60 | Image lifecycle policies to remove untagged images > 30 days | 10% |
| AWS CodeBuild | $600 | Build frequency optimisation (cache layers) | 15% |
| AWS Secrets Manager | $48 | Fixed cost; no optimisation needed | — |
| AWS Business Support | $6,000 | Flat rate; Business tier appropriate for platform criticality | — |
| **Total Annual (Year 1 List)** | **$39,308** | **AWS Activate credit: -$5,000 → Net $34,308** | — |

---

# Implementation Approach

The Amatra Agentic Orchestration Platform is delivered in three sequential phases over twelve weeks, following a foundation-first methodology that establishes security, identity, and data infrastructure before any AI model spend begins. This sequencing reduces financial risk, enables incremental agent validation rather than big-bang integration, and ensures that the CTO sign-off gate on the Cognito user pool is cleared early — protecting the April 2026 executive demonstration deadline. Each phase produces demonstrable, client-accepted deliverables before the next phase commences.

## Migration/Deployment Strategy

The platform is a greenfield implementation — there is no existing production system to migrate or cut over from. The legacy laptop-based Claude Code CLI workflow continues to operate in parallel throughout the engagement; consultants transition to the new platform after go-live, not before.

- **Approach:** Greenfield phased build — Foundation (Phase 1), Agent Build & Integration (Phase 2), Validation & Go-Live (Phase 3)
- **Pattern:** Blue-green Lambda alias swap for production cutover; API Gateway stage mapping updated to route traffic to the production Lambda alias after smoke tests pass
- **Validation:** Comprehensive test suite across all five test disciplines (unit, integration, API, security, UAT) with quantified pass criteria before go-live decision
- **Rollback:** API Gateway stage mapping repointed to previous Lambda alias in < 5 minutes; DynamoDB PITR available for data state rollback; staging environment preserved throughout hypercare as fallback

## Sequencing & Wave Planning

The delivery is structured into five sequential phases, with each phase gated by the completion of its defined exit criteria before the next phase commences. The table below reflects the task sequencing from the Level of Effort estimate:

<!-- TABLE_CONFIG: widths=[15, 30, 25, 30] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| Phase 1: Discovery | Kickoff; current-state assessment of eof-tools library; requirements gathering; cloud readiness assessment; AI/ML capability assessment; gap analysis; risk assessment; assessment report | Weeks 1–2 | Assessment report delivered and accepted by Marcus Patel; risk register approved by Daniel Park |
| Phase 2: Planning | Detailed architecture design (CTO sign-off required); AWS foundation design; Cognito & auth design; API Gateway & Lambda architecture; agent orchestration design; container image pipeline design; security baseline design; monitoring & observability design; design documentation | Weeks 2–3 | Architecture design approved by CTO and Marcus Patel (Milestone M2); all design documents delivered |
| Phase 3: Development | Foundation infrastructure provisioning via Terraform; post-confirmation Lambda; all five agents; eof-tools Docker image pipeline; CLI (14 subcommands); Lambda route handlers (11 routes); DynamoDB quota enforcement; GitHub integration; CloudWatch observability; security hardening | Weeks 4–9 | All five agents registered on AgentCore Runtime; Docker image in ECR; CLI pip-installable; all 11 Lambda routes responding; GitHub commit test confirmed (Milestone M4 and M5) |
| Phase 4: Testing | Test plan development; unit testing; end-to-end integration testing (12 artifact types); API route testing; Terraform validate gate testing; performance & quota testing; security testing; CloudWatch baseline validation; UAT coordination with Marcus Patel and Sarah Lin; defect resolution | Weeks 10–11 | Green CloudWatch metrics baseline; 95%+ artifact validation pass rate; all security tests passed; UAT sign-off from Marcus Patel (Milestone M6) |
| Phase 5: Deployment | Go-live planning; production deployment via Terraform (CTO sign-off gate); CLI package publishing to PyPI; runbook development; knowledge transfer sessions; documentation delivery; hypercare support (4 weeks); optimisation recommendations; project closeout | Weeks 11–16 | Production platform live; executive demonstration delivered to Sarah Lin; all documentation transferred; formal acceptance from Sarah Lin (Milestones M7, M8, M9) |

## Tooling & Automation

All platform construction and operational tooling is defined in the following table, ensuring the delivery team has a consistent, reproducible set of tools for every phase of the engagement:

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Tool | Purpose |
|----------|------|---------|
| Infrastructure as Code | Terraform (HashiCorp) | Provisioning all five core AWS services (Cognito, API Gateway, Lambda, DynamoDB, S3) in dev/staging/prod workspaces; Code Generator automation bundle output |
| Agent Framework | Strands Agents (AWS) | Multi-agent graph authoring, inter-agent communication, and AgentCore Runtime registration |
| Container Build | Docker (multi-stage Dockerfile) | Build the eof-tools agent container image with all Python dependencies and converter modules |
| Container Registry | Amazon ECR | Push, version, and serve agent container images with immutable digest pinning |
| CI/CD | AWS CodeBuild | Automated agent image build pipeline on Git push; `terraform plan` gate for IaC changes |
| Configuration Management | AWS Systems Manager Parameter Store | Environment-specific configuration (non-secret) such as S3 bucket names, DynamoDB table names, and API Gateway URLs per environment |
| CLI Development | Python (Click framework), pip | 14-subcommand CLI packaging, distribution, and JWT token management |
| API Testing | Postman / `httpx` (Python) | API route functional testing and automated integration test scripts |
| Unit Testing | `pytest`, `moto` (AWS mocks) | Lambda route handler unit tests with mocked DynamoDB and S3 interactions |
| Load Testing | `locust` (Python) | Concurrent solution submission load tests; DynamoDB quota contention validation |
| Security Testing | AWS IAM Access Analyzer, `curl` (JWT bypass) | IAM privilege escalation checks; WAF rule validation; JWT bypass attempt scripting |
| Observability | Amazon CloudWatch (Logs, Metrics, Dashboards, Alarms), AWS X-Ray | Per-phase token usage metrics; distributed tracing; platform health dashboards; alert notifications |
| Source Control | GitHub (PAT-based) | Artifact commit pipeline; Terraform and Lambda code version control |

## Cutover Approach

The production cutover follows a blue-green approach with a defined go/no-go decision gate, targeting a Tuesday morning Pacific Time window (low-activity period) during Week 11:

- **Type:** Blue-green Lambda alias swap — production infrastructure provisioned via `terraform apply` with API Gateway stage initially pointing at a "dark launch" Lambda alias
- **Duration:** Half-day cutover window (4 hours) with a 2-hour smoke test execution period
- **Validation:** Five-command smoke test suite executed against the production endpoint: `auth login`, `solution generate` (representative brief), `solution status {id}`, `artifact download {id}`, `admin usage`
- **Decision Point:** Go/no-go decision by Marcus Patel and Solution Architect after smoke test completion; CTO sign-off is a pre-condition that must be confirmed before `terraform apply` is initiated; all stakeholders notified of go/no-go outcome

## Downtime Expectations

Because the platform is greenfield and the legacy laptop-based workflow continues in parallel, there is no planned downtime for existing PREDICTif operations during the cutover:

- **Planned Downtime:** None for existing workflows; the Amatra platform is net-new with no existing users to migrate
- **Unplanned Downtime MTTR:** < 2 hours (matching the RTO target); Lambda and AgentCore Runtime are AWS-managed with automatic failover; DynamoDB restoration from PITR is the primary recovery path
- **Mitigation:** Staged rollout — the first cohort of consultants onboarded post-go-live are a nominated pilot group from Marcus Patel's team; broad rollout to all 120 consultants occurs after 48-hour pilot period with green metrics confirmed

## Rollback Strategy

The following rollback procedures are documented and tested before the production cutover window opens:

- **Infrastructure Rollback:** API Gateway stage mapping repointed to the previous Lambda alias via the AWS console or `terraform apply` with the previous alias configuration; execution time < 5 minutes; no data loss
- **Application Rollback:** Lambda functions are versioned; previous function versions are retained for 30 days; alias swap immediately reverts to previous code without redeployment
- **Database Rollback:** DynamoDB PITR restores any table to a pre-cutover snapshot if data corruption is detected; estimated restoration time 30–60 minutes
- **CLI Rollback:** Consultants are instructed to use the `--api-url` flag to point the CLI at the staging endpoint during any rollback period; the staging environment remains live throughout the hypercare period as a fallback
- **Maximum Rollback Window:** Decision to rollback must be made within 24 hours of go-live if a Severity 1 defect is identified; after 24 hours with no critical issues, the go-live is considered stable

---

# Appendices

This section provides supporting reference material for the Amatra Agentic Orchestration Platform, including architecture diagram references, resource naming conventions, tagging standards, a risk register, and a glossary of terms used throughout this document.

## Architecture Diagrams

The following diagrams support the architecture described in this document:

- **Solution Architecture Diagram** — Included in the Solution Architecture section (Figure 1); shows the end-to-end five-agent Strands graph on Bedrock AgentCore Runtime, API Gateway HTTP API v2 with Cognito JWT authorisation, DynamoDB quota enforcement, S3 artifact storage, and CloudWatch observability in us-west-2
- **Data Flow Diagram** — Describes the sequence of data movement from CLI brief submission through agent invocation, validation, S3 storage, and GitHub commit (Section 6: Data Architecture, Data Flow Design)
- **Security Architecture** — Defence-in-depth model covering Cognito JWT perimeter, WAF, IAM least-privilege roles, Secrets Manager, KMS encryption, and CloudTrail audit (Section 5: Security & Compliance)
- **Integration Architecture** — API endpoint map, GitHub commit pipeline, and eof-tools integration boundary (Section 7: Integration Design)

## Naming Conventions

All AWS resources are named following the pattern `amatra-{environment}-{service}-{purpose}` to ensure consistent identification across dev, staging, and production environments:

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Resource Type | Pattern | Example |
|---------------|---------|---------|
| Lambda Function | `amatra-{env}-lambda-{purpose}` | `amatra-prod-lambda-solution-create` |
| DynamoDB Table | `amatra-{env}-ddb-{table-name}` | `amatra-prod-ddb-solutions` |
| S3 Bucket | `amatra-{env}-s3-{purpose}-{account-id}` | `amatra-prod-s3-artifacts-123456789012` |
| Cognito User Pool | `amatra-{env}-cognito-userpool` | `amatra-prod-cognito-userpool` |
| API Gateway | `amatra-{env}-apigw-http-api` | `amatra-prod-apigw-http-api` |
| ECR Repository | `amatra-{env}-ecr-{image-name}` | `amatra-prod-ecr-eoframework-agent` |
| Secrets Manager Secret | `amatra/{env}/{service}/{secret-name}` | `amatra/prod/github/pat` |
| CloudWatch Log Group | `/amatra/{env}/{function-name}` | `/amatra/prod/solution-create` |
| IAM Role | `amatra-{env}-iam-role-{function-name}` | `amatra-prod-iam-role-solution-create` |
| CodeBuild Project | `amatra-{env}-codebuild-{pipeline-name}` | `amatra-prod-codebuild-agent-image` |

## Tagging Standards

All AWS resources provisioned via Terraform must carry the following tags at creation time. Tags are enforced via AWS Config rule and Terraform provider default tags:

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Tag | Required | Example Values |
|-----|----------|----------------|
| Environment | Yes | `dev`, `staging`, `prod` |
| Application | Yes | `amatra-agentic-platform` |
| Owner | Yes | `vendor-delivery-team` (build phase); `predictif-devops` (post-handover) |
| CostCenter | Yes | `OPP-2026-001` |
| Project | Yes | `amatra-agentic-orchestration-platform` |
| ManagedBy | Yes | `terraform` |
| DataClassification | Yes | `confidential` (DynamoDB, S3); `internal` (CloudWatch, CloudTrail) |
| LastReviewedBy | Recommended | IAM principal that last applied the Terraform configuration |

## Risk Register

The following risks have been identified during the Discovery and Planning phases. Each risk is assigned a likelihood, impact rating, and mitigation strategy. The risk register is reviewed at each phase gate and updated by the Project Manager:

<!-- TABLE_CONFIG: widths=[28, 15, 15, 42] -->
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| CTO sign-off on Cognito user pool delayed beyond Week 3, pushing Phase 1 completion and compressing Phase 2 | Medium | Critical | Initiate CTO briefing in Week 1 kickoff; prepare a 1-page executive summary of the Cognito design for CTO review; escalate to Sarah Lin if no response within 5 business days |
| Bedrock service quota for Claude Sonnet 4.6 or Haiku 4.5 insufficient in us-west-2 at development or test throughput | Medium | High | Request Bedrock quota increase in Week 1 alongside account provisioning; monitor token throughput in Phase 2 development; design retry logic with exponential backoff to tolerate temporary throttling |
| eof-tools converter library produces invalid DOCX/PPTX/XLSX for one or more of the 12 artifact types | Low | High | Conduct early integration smoke test of all 12 artifact types in Week 5 (start of Phase 2) before full agent build; any eof-tools failures are flagged immediately for Marcus Patel to resolve (out of vendor scope) |
| DynamoDB hot-partition risk on GlobalQuota table during peak concurrent solution submissions | Low | Medium | Use a single atomic conditional write with `ConditionExpression`; at 200 solutions/month this equates to < 1 write/hour on average; monitor DynamoDB throttle metrics during load testing and alert if throttling occurs |
| GitHub PAT expires or is revoked mid-engagement, blocking artifact commit pipeline | Low | High | Store PAT in Secrets Manager with rotation runbook; monitor GitHub commit Lambda failure rate; alert Daniel Park's team immediately on commit failure; S3 artifacts are authoritative so generation continues unaffected |
| Agent generation produces artifacts that consistently fail EO Validator format-check, exhausting the 3-retry budget | Medium | High | Run format-check validation against prompt outputs during Phase 2 development (not just Phase 3 testing); iterate on Sonnet 4.6 prompts until pass rate > 95% in staging before Phase 3 sign-off |
| April 2026 executive demonstration deadline missed due to scope creep or testing delays | Medium | Critical | Fixed scope with formal change control (SOW Section 5); scope deferral policy agreed in Week 1; Phase 3 begins only when Phase 2 exit criteria are met; weekly status reporting to Sarah Lin with milestone tracking |
| Lambda cold-start latency on the Solution Create function causes unacceptable API response time for `solution generate` CLI command | Low | Medium | Configure 2 instances of Provisioned Concurrency on the Solution Create Lambda in production; monitor p99 latency during load testing in Phase 4 |
| us-west-2 AWS account provisioning permissions insufficient — Terraform apply fails for one or more services | Low | High | Confirm IAM permission boundaries in kickoff call (Week 1); vendor team to validate with a dry-run `terraform plan` before Phase 1 provisioning begins; escalate to Client IT Lead if missing permissions identified |
| Bedrock model behaviour changes (prompt format, token count, output structure) between development and production | Low | Medium | Pin model versions to specific Claude Sonnet 4.6 and Haiku 4.5 model ARNs in all Lambda invocations; test against model version updates in staging before applying to production; include model version in CloudTrail audit |

## Glossary

The following terms are used throughout this document and align with the EO Framework and AWS service naming conventions:

<!-- TABLE_CONFIG: widths=[25, 75] -->
| Term | Definition |
|------|------------|
| AgentCore Runtime | AWS Bedrock AgentCore Runtime — managed serverless hosting service for Strands agents; abstracts agent lifecycle management and provides independent scaling per agent |
| Artifact | A single EO Framework document produced by the platform (e.g., statement-of-work.md, solution-briefing.md, infrastructure-costs.csv); twelve artifacts are produced per solution engagement |
| Bedrock | Amazon Bedrock — AWS managed AI/ML service providing access to foundation models including Claude Sonnet 4.6 and Claude Haiku 4.5 via a unified API |
| CLI | Command-Line Interface — the pip-installable Python tool providing fourteen subcommands for consultant-facing platform interaction |
| DLQ | Dead Letter Queue — a CloudWatch Logs target for messages (e.g., GitHub commit failures) that cannot be processed successfully after all retry attempts |
| EO Framework | Engagement Operations Framework — PREDICTif Solutions' proprietary standard for pre-sales and delivery documentation, defining required artifact types, section structures, YAML frontmatter, and quality criteria |
| eof-tools | The EO Framework converter library — approximately 30 Python modules that convert raw markdown and CSV source artifacts into formatted DOCX, PPTX, and XLSX office documents |
| Format-Check | The deterministic validation pass in the EO Validator Agent that checks required YAML frontmatter fields, H1 section order, TABLE_CONFIG directives, and image references — runs before the LLM quality gate |
| Haiku 4.5 | Claude Haiku 4.5 — Anthropic's cost-efficient Claude model used for validation passes; approximately 3× lower per-token cost than Sonnet 4.6 |
| JWT | JSON Web Token — the authentication token issued by Amazon Cognito User Pools (RS256-signed) and validated by API Gateway on every API request |
| LOE | Level of Effort — the task-by-task effort estimate artifact (CSV) produced by the Pre-Sales Generator Agent as part of the five-artifact presales bundle |
| MAU | Monthly Active User — the billing unit for Amazon Cognito User Pools; the platform is sized for approximately 120 MAUs (PREDICTif consultants) |
| PAT | Personal Access Token — the GitHub authentication credential stored in Secrets Manager and used by the GitHub integration Lambda to commit artifacts to the fixed public repository |
| PITR | Point-In-Time Recovery — DynamoDB's continuous backup feature providing sub-second recovery granularity with a 35-day recovery window |
| Presales Bundle | The five-artifact presales output of the platform: solution briefing (PPTX source), infrastructure costs (CSV), level-of-effort estimate (CSV), statement of work (DOCX source), and executive proposal |
| RAID Log | Risks, Assumptions, Issues, and Dependencies log — one of the six delivery artifacts produced by the Delivery Generator Agent |
| RTO | Recovery Time Objective — the maximum acceptable time to restore the platform to operational status after a failure; targeted at 2 hours for this deployment |
| RPO | Recovery Point Objective — the maximum acceptable data loss window; targeted at 1 hour, achievable via DynamoDB PITR and S3 versioning |
| SOW | Statement of Work — the presales contract document (OPP-2026-001) defining the scope, deliverables, roles, investment, and terms for this engagement |
| Sonnet 4.6 | Claude Sonnet 4.6 — Anthropic's high-quality generation model used for all artifact production passes via Amazon Bedrock |
| Strands | The AWS Strands Agents framework — an open-source Python library for building multi-agent graphs; used to author all five agents in the platform |
| Terraform | HashiCorp Terraform — the Infrastructure as Code tool used for platform provisioning and as the output format of the Code Generator Agent's automation bundle |
| TOTP | Time-based One-Time Password — the MFA method supported by Amazon Cognito; configured as optional for the initial platform release |
| WAF | AWS Web Application Firewall — AWS-managed network security service attached to the API Gateway HTTP API v2 stage; enforces rate limits and OWASP rules |
