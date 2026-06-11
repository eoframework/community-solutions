---
document_title: Implementation Guide
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

## Project Overview

This Implementation Guide provides step-by-step, executable procedures for deploying the Amatra Intelligent Solution Builder — a fully serverless, AI-powered AWS platform that automates the production of consulting-grade engagement artifact packages from a short client brief. The platform eliminates Amatra's current three-week manual artifact-production workflow, targeting a turnaround of under two business days and tripling proposal throughput from approximately 8 to ≥24 active engagements per quarter.

The guide is structured to match the five-phase programme defined in the Statement of Work (SOW), spanning nine months from project kickoff to General Availability by Q1 2027. It translates every architectural and security decision documented in the Detailed Design Document into specific commands, Terraform configurations, validation procedures, and rollback steps that the implementation team can execute directly. All phase names, durations, and milestone dates are as committed in the SOW.

## Implementation Scope

- **In Scope:**
  - End-to-end serverless AWS platform deployment: API Gateway, Lambda, Bedrock (Claude 3 Sonnet), Step Functions, SQS, DynamoDB, S3, Cognito, CloudWatch, X-Ray, WAF, CloudTrail, KMS, Secrets Manager, PrivateLink, SES, CloudFront, ECR
  - Okta-to-Cognito identity migration for all ~120 internal users across three roles
  - Artifact generation pipeline for all 7 artifact types with prompt engineering and output validation
  - Async job orchestration pipeline (Step Functions + SQS FIFO) for 30–60 minute Bedrock jobs
  - CI/CD pipeline (GitHub Actions) with Terraform plan/apply gates across Dev, Staging, and Production
  - SOC 2 Type II compliance controls: encryption, CloudTrail, IAM least-privilege, WAF, Secrets Manager
  - CloudWatch observability stack: dashboards, Lambda alarms, Bedrock token-usage metrics, X-Ray tracing
  - Legacy EC2 monolith decommission and Google Workspace manual workflow retirement
  - 8-week hypercare support post-Phase 1 Go-Live (30 Sep 2026 through ~25 Nov 2026)

- **Out of Scope:**
  - Ongoing managed services or post-hypercare production support
  - New artifact template formats beyond the 7 defined types
  - Integration with any external client systems
  - Multi-region deployment (us-west-2 only)
  - Custom mobile application development
  - Formal third-party penetration testing

- **Dependencies:**
  - AWS account provisioned with Bedrock access in us-west-2 (required by Week 1)
  - Okta admin credentials and SSO configuration provided (required by Week 2)
  - Existing artifact templates (Word/Excel/PowerPoint) provided (required by Week 2)
  - Representative client briefs for testing (required by Week 20)
  - Security design review and approval from Security & Compliance Lead (required by Week 8)

## Timeline Overview

- **Project Duration:** 36 weeks (~9 months)
- **Phase 1 Pre-Sales MVP Go-Live:** 30 September 2026
- **Phase 2 Delivery & Terraform Go-Live:** 15 December 2026
- **General Availability:** Q1 2027
- **Hypercare End:** Week 36
- **Key Milestones:**
  - M1 — Discovery Complete: Week 4
  - M2 — Architecture Approved: Week 8
  - M3 — Dev Platform Built: Week 20
  - M4 — Testing Complete: Week 26
  - M5 — Phase 1 Go-Live: 30 Sep 2026
  - M6 — Legacy Decommission: Week 29
  - M7 — Phase 2 Go-Live: 15 Dec 2026
  - M8 — General Availability: Q1 2027
  - M9 — Hypercare End: Week 36

---

# Prerequisites

## Technical Prerequisites

Complete all items in this section before starting Phase 1 environment provisioning.

### Cloud Infrastructure

- [ ] AWS account created and accessible in us-west-2 (account ID confirmed with Amatra IT)
- [ ] Amazon Bedrock service enabled in us-west-2 with Claude 3 Sonnet model access granted
- [ ] Bedrock token quota set to minimum 90M tokens/month (Large tier per SOW)
- [ ] Lambda concurrency quota confirmed ≥500 concurrent executions in us-west-2
- [ ] DynamoDB on-demand capacity enabled for us-west-2 region
- [ ] Administrator access provisioned for vendor implementation team via IAM Identity Center SSO
- [ ] Billing alerts configured at $5,000/month threshold
- [ ] AWS Business Support plan activated (~10% of monthly AWS charges)
- [ ] S3 Block Public Access enabled at the account level

### Network Connectivity

- [ ] VPC CIDR range `10.10.0.0/16` confirmed available (no overlap with Amatra corporate network)
- [ ] NAT Gateway deployment approved for three AZs in us-west-2 (us-west-2a/b/c)
- [ ] AWS PrivateLink endpoints approved for: Bedrock, Secrets Manager, SQS, SES (interface endpoints, ~$173/year)
- [ ] S3 and DynamoDB Gateway endpoints approved (free)
- [ ] Outbound IP addresses from NAT Gateways to be communicated to Amatra IT for firewall allowlisting
- [ ] DNS resolution confirmed for `*.amazoncognito.com` and `*.amazonaws.com` from corporate network

### Security Baseline

- [ ] IAM Identity Center (SSO) configured with hardware MFA required for production account access
- [ ] GitHub Actions OIDC provider registered in IAM (no static access keys required)
- [ ] Dedicated AWS sub-accounts or environment tags established for Dev, Staging, and Production
- [ ] AWS Config enabled in us-west-2 to begin resource compliance monitoring
- [ ] AWS CloudTrail multi-region trail bucket (`amatra-cloudtrail-logs-prod`) pre-created with Object Lock

### Development Tools

- [ ] GitHub repository `amatra/intelligent-solution-builder` created with branch protection (1 peer review required)
- [ ] GitHub Actions Team plan activated ($252/year)
- [ ] Terraform v1.8+ installed on all developer workstations and CI/CD runners
- [ ] AWS CLI v2 installed and configured on all developer workstations
- [ ] Datadog Pro account (5 hosts) provisioned and API key available in Secrets Manager
- [ ] Python 3.12 development environment confirmed on all developer workstations
- [ ] Docker Desktop installed for Lambda container image builds

## Organizational Prerequisites

- [ ] Project team fully assigned and calendars cleared for engagement duration
- [ ] CTO (cto@amatra.com) confirmed as executive sponsor and go/no-go authority
- [ ] VP Engineering confirmed as day-to-day delivery owner
- [ ] Head of Solutions confirmed as primary end-user representative and UAT lead
- [ ] Security & Compliance Lead confirmed for SOC 2 control approvals
- [ ] Budget approved: $409,273 net Year 1 (professional services + infrastructure, after $35,000 credits)
- [ ] Change management process activated for Okta-to-Cognito migration communications
- [ ] Project communication plan distributed to all stakeholders
- [ ] Weekly status meeting cadence established (1 hour, all key stakeholders)
- [ ] Jira project board and Confluence space created for the engagement

## Environmental Setup

### Development Environment

- [ ] Development AWS account/environment ready (or Development environment tag policy applied)
- [ ] Development VPC CIDR `10.10.0.0/16` configured in us-west-2 (single NAT Gateway to reduce cost)
- [ ] GitHub Actions pipeline connected to Dev environment via OIDC role `amatra-github-actions-dev-role`
- [ ] Developer IAM Identity Center access provisioned for vendor engineering team
- [ ] Synthetic test briefs prepared for Dev functional testing (no real client data)
- [ ] Dev Datadog host quota allocated (5 hosts shared across Dev/Staging/Prod)

### Staging Environment

- [ ] Staging AWS account or environment ready, mirroring Production architecture (3-AZ)
- [ ] Anonymised copies of representative client briefs prepared for UAT validation
- [ ] UAT participant access provisioned (5–10 pre-sales consultants with read access)
- [ ] Staging Cognito User Pool populated with test user cohort (anonymised Okta data)
- [ ] Staging monitoring dashboards confirmed operational before UAT begins

### Production Environment

- [ ] Production AWS account ready with all service quotas confirmed
- [ ] Production-grade resources provisioned (3-AZ NAT Gateways, all PrivateLink endpoints)
- [ ] CloudWatch dashboards `amatra-platform-prod` and `amatra-security-prod` provisioned
- [ ] On-call rotation established for vendor Hypercare team (Severity 1 response)
- [ ] SNS topic `amatra-ops-alerts-prod` configured with operations team email and PagerDuty endpoint
- [ ] Go-live communications plan prepared and ready to distribute to all ~120 users

---

# Environment Setup

## Phase 1: Discovery & Assessment (Weeks 1–4)

### Objectives

- Document current-state legacy systems and manual workflow
- Complete Bedrock feasibility assessment and Okta identity inventory
- Conduct SOC 2 and GDPR requirements gap analysis
- Validate all prerequisites and obtain Phase 2 go/no-go sign-off from CTO

### Activities

The following table documents all Phase 1 activities with ownership and duration:

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Project kickoff with CTO, VP Engineering, Head of Solutions, Security Lead | Vendor PM | 1 day | Contract execution |
| Current-state assessment: EC2 monolith, Google Workspace, manual process | Vendor Architect | 5 days | Kickoff complete |
| Stakeholder interviews: pre-sales, delivery, sales, security teams | Vendor PM + Architect | 5 days | Kickoff complete |
| Bedrock feasibility assessment: Claude model selection, prompt strategy | ML/AI Engineer | 5 days | AWS account access |
| Okta identity inventory: users, groups, SSO config; Cognito migration strategy | Security Engineer | 3 days | Okta credentials provided |
| SOC 2 / GDPR requirements assessment and gap analysis | Security Engineer | 3 days | Stakeholder interviews |
| AWS service-limit and IAM posture review in us-west-2 | Cloud Engineer | 2 days | AWS account access |
| Assessment report compilation and CTO review | Vendor PM + Architect | 2 days | All above complete |

### Detailed Procedures

#### 1.1 AWS Account and Prerequisite Verification

Before any infrastructure work begins, validate that all prerequisites are met:

```bash
# Verify AWS CLI access and account identity
aws sts get-caller-identity

# Confirm Bedrock Claude 3 Sonnet model access in us-west-2
aws bedrock list-foundation-models \
  --region us-west-2 \
  --query "modelSummaries[?contains(modelId, 'claude-3-sonnet')]"

# Confirm Lambda concurrency quota
aws service-quotas get-service-quota \
  --service-code lambda \
  --quota-code L-B99A9384 \
  --region us-west-2

# Verify S3 Block Public Access is enabled at account level
aws s3control get-public-access-block \
  --account-id $(aws sts get-caller-identity --query Account --output text)
```

**Expected Output (Bedrock check):**

```bash
# Claude 3 Sonnet model should appear in the list
# {
#     "modelId": "anthropic.claude-3-sonnet-20240229-v1:0",
#     "modelName": "Claude 3 Sonnet",
#     ...
# }
```

#### 1.2 Okta Identity Inventory

Run the Okta inventory script to document all users, groups, and SSO integrations before migration planning:

```bash
# Clone the project repository (once available)
git clone https://github.com/amatra/intelligent-solution-builder.git
cd intelligent-solution-builder

# Run Okta inventory script (requires OKTA_DOMAIN and OKTA_API_TOKEN env vars)
export OKTA_DOMAIN="amatra.okta.com"
export OKTA_API_TOKEN="<okta-api-token>"

python scripts/identity/okta_inventory.py \
  --output reports/okta-inventory-$(date +%Y%m%d).json \
  --include-groups \
  --include-sso-integrations

# Generate migration mapping
python scripts/identity/generate_cognito_mapping.py \
  --okta-inventory reports/okta-inventory-$(date +%Y%m%d).json \
  --output reports/cognito-migration-mapping.csv
```

### Deliverables

- [ ] Discovery & Assessment Report (findings, recommendations, go/no-go sign-off)
- [ ] Okta Identity Inventory document (users, groups, SSO integrations)
- [ ] Bedrock feasibility assessment (model selection rationale, prompt strategy)
- [ ] SOC 2 gap analysis document
- [ ] AWS service-limit review report
- [ ] Phase 2 go/no-go sign-off from CTO (Milestone M1)

### Success Criteria

- CTO formally approves Discovery & Assessment Report (Milestone M1, Week 4)
- Okta inventory confirms user count (~120), group structure, and SSO configuration
- Bedrock feasibility assessment confirms Claude 3 Sonnet can produce qualifying artifacts
- All critical prerequisites confirmed as met or a remediation plan documented

---

## Phase 2: Architecture Design & Planning (Weeks 5–8)

### Objectives

- Produce the detailed architecture design and ADRs for CTO and Security Lead approval
- Finalise Terraform module structure and CI/CD pipeline design
- Complete Cognito User Pool design and Bedrock prompt template framework
- Obtain Security Lead sign-off before Phase 3 development begins

### Activities

The following table documents all Phase 2 activities with ownership and duration:

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| End-to-end serverless architecture design | Vendor Architect | 5 days | M1 approved |
| DynamoDB schema and S3 object structure design | Cloud Engineer | 3 days | Architecture design |
| Cognito User Pool design: groups, scopes, MFA, usage limits | Security Engineer | 3 days | Okta inventory |
| Bedrock prompt template framework: 7 artifact types | ML/AI Engineer | 5 days | Architecture design |
| Terraform module structure and state backend design | Cloud Engineer | 3 days | Architecture design |
| CI/CD pipeline design: GitHub Actions, branch protection | DevOps Engineer | 2 days | Architecture design |
| CloudWatch observability design: dashboards and alarms | DevOps Engineer | 2 days | Architecture design |
| Security and compliance design review with Security Lead | Security Engineer | 2 days | All design docs |
| Architecture design documentation and ADRs authored | Technical Writer + Architect | 3 days | All design complete |

### Deliverables

- [ ] Detailed Architecture Design Document
- [ ] Architecture Decision Records (ADRs)
- [ ] Terraform Module Structure and IaC Design document
- [ ] CTO and Security Lead sign-off (Milestone M2, Week 8)

### Success Criteria

- CTO and Security Lead formally approve Detailed Architecture Design Document (Milestone M2, Week 8)
- Security Lead confirms SOC 2 controls design satisfies all five Trust Service Criteria
- Terraform module structure reviewed and approved by VP Engineering
- Bedrock prompt framework reviewed by Head of Solutions against artifact quality standards

---

## Phase 3: Development & Build (Weeks 9–20)

### Objectives

- Provision the AWS foundation (Dev environment) via Terraform IaC
- Deploy all platform components: API, async pipeline, Bedrock integration, admin console
- Build and validate CI/CD pipeline and CloudWatch observability stack
- Complete Cognito User Pool provisioning and Okta-to-Cognito migration in Dev

### Activities

The following table documents all Phase 3 activities with ownership and duration:

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Terraform AWS foundation provisioning (Dev) | Cloud Engineer | 5 days | M2 approved |
| Cognito User Pool + Okta migration (Dev) | Security Engineer | 5 days | Foundation provisioned |
| REST API (API Gateway + Lambda functions) | Senior Cloud Engineer | 8 days | Foundation provisioned |
| Async pipeline (Step Functions + SQS FIFO) | Cloud Engineer | 5 days | REST API |
| Bedrock integration + prompt templates (7 types) | ML/AI Engineer | 10 days | Async pipeline |
| Artifact template automation pipeline | Developer | 5 days | Bedrock integration |
| Admin console API (usage limits, audit logs) | Developer | 4 days | Cognito + DynamoDB |
| CI/CD pipeline build (GitHub Actions) | DevOps Engineer | 5 days | Foundation provisioned |
| CloudWatch observability stack | DevOps Engineer | 5 days | All services deployed |
| Security hardening: WAF, Secrets Manager, KMS | Security Engineer | 5 days | All services deployed |
| Configuration documentation | Technical Writer | 3 days | All services deployed |

### Detailed Procedures

#### 3.1 Terraform Foundation Provisioning (Dev)

The following commands initialise the Terraform remote state backend and apply the Dev environment foundation:

```bash
# Navigate to the environment directory
cd infrastructure/environments/dev

# Copy the example variable file and fill in values
cp terraform.tfvars.example terraform.tfvars

# Initialise Terraform with the S3 remote state backend
terraform init \
  -backend-config="bucket=amatra-terraform-state-dev" \
  -backend-config="key=dev/terraform.tfstate" \
  -backend-config="region=us-west-2" \
  -backend-config="dynamodb_table=amatra-terraform-lock-dev"

# Preview the deployment plan
terraform plan -var-file=terraform.tfvars -out=dev.plan

# Apply the foundation infrastructure
terraform apply dev.plan

# Capture all outputs for use in subsequent steps
terraform output -json > ../../outputs/dev-outputs.json
```

#### 3.2 Cognito User Pool Provisioning

After the Terraform foundation is applied, validate the Cognito User Pool configuration:

```bash
# Retrieve the User Pool ID from Terraform outputs
POOL_ID=$(cat ../../outputs/dev-outputs.json | \
  python3 -c "import json,sys; print(json.load(sys.stdin)['cognito_pool_id']['value'])")

# Verify the three user groups were created
aws cognito-idp list-groups \
  --user-pool-id "$POOL_ID" \
  --region us-west-2 \
  --query 'Groups[].GroupName'

# Confirm MFA configuration for admins group
aws cognito-idp get-user-pool \
  --user-pool-id "$POOL_ID" \
  --region us-west-2 \
  --query 'UserPool.MfaConfiguration'
```

#### 3.3 Okta-to-Cognito User Migration (Dev Validation)

Run the migration script against the Dev Cognito User Pool to validate before Production cutover:

```bash
export COGNITO_USER_POOL_ID="$POOL_ID"
export AWS_REGION="us-west-2"
export OKTA_DOMAIN="amatra.okta.com"
export OKTA_API_TOKEN="<okta-api-token>"

# Dry-run first
python scripts/identity/migrate_okta_to_cognito.py \
  --mapping-file reports/cognito-migration-mapping.csv \
  --dry-run \
  --output reports/migration-dry-run-$(date +%Y%m%d).json

# Execute after reviewing dry-run report
python scripts/identity/migrate_okta_to_cognito.py \
  --mapping-file reports/cognito-migration-mapping.csv \
  --execute \
  --output reports/migration-result-$(date +%Y%m%d).json

# Validate success rate
python scripts/identity/validate_migration.py \
  --result-file reports/migration-result-$(date +%Y%m%d).json \
  --min-success-rate 0.95
```

#### 3.4 Lambda Container Image Build and Push

All Lambda functions are deployed as container images via ECR. Build and push all 9 function images:

```bash
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr get-login-password --region us-west-2 | \
  docker login --username AWS --password-stdin \
  "$AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com"

for function in brief-submission job-status artifact-retrieval admin-governance \
                bedrock-orchestration output-validation artifact-template \
                ses-notification health-check; do
  echo "Building $function..."
  docker build \
    -t "amatra/$function:latest" \
    --platform linux/arm64 \
    "application/lambdas/$function/"
  docker tag "amatra/$function:latest" \
    "$AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/amatra/$function:latest"
  docker push "$AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/amatra/$function:latest"
  echo "Pushed $function successfully"
done
```

#### 3.5 Bedrock Prompt Template Upload

Upload all 7 artifact-specific prompt templates to the S3 artifacts bucket:

```bash
ARTIFACTS_BUCKET="amatra-artifacts-dev"

for artifact_type in discovery-questionnaire solution-briefing statement-of-work \
                     infrastructure-costs level-of-effort-estimate detailed-design \
                     terraform-automation; do
  aws s3 cp \
    "prompts/$artifact_type/prompt-template.txt" \
    "s3://$ARTIFACTS_BUCKET/prompts/$artifact_type/prompt-template.txt" \
    --sse aws:kms \
    --metadata "artifact-type=$artifact_type,version=1.0"
done

# Verify all 7 templates are present
aws s3 ls "s3://$ARTIFACTS_BUCKET/prompts/" --recursive | grep "prompt-template.txt"
```

### Deliverables

- [ ] Dev environment fully provisioned and operational (Milestone M3, Week 20)
- [ ] All 9 Lambda functions deployed and health-checked
- [ ] Step Functions workflow deployed and validated with test brief
- [ ] Cognito User Pool provisioned with all 3 groups; Okta migration validated in Dev
- [ ] All 7 Bedrock prompt templates uploaded to S3
- [ ] CI/CD pipeline deploying to Dev on every PR merge
- [ ] CloudWatch dashboards operational and capturing Dev metrics
- [ ] Configuration Documentation delivered to VP Engineering

### Success Criteria

- All Lambda functions respond to health check invocations with 200 OK
- Step Functions test workflow completes in under 90 minutes for a single-brief generation
- Okta-to-Cognito migration in Dev achieves ≥95% login success rate in a pilot test
- CI/CD pipeline successfully deploys an updated Lambda function end-to-end
- CloudWatch dashboard displays all 7 key platform health indicators

---

## Phase 4: Testing & Validation (Weeks 21–26)

### Objectives

- Execute comprehensive functional, integration, performance, security, and UAT test suites
- Validate SOC 2 evidence and assemble the evidence package
- Achieve ≥90% artifact first-review QA pass rate
- Obtain CTO and Security Lead go-live sign-off (Milestone M4)

### Activities

The following table documents all Phase 4 activities with ownership and duration:

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Test plan development and review | QA Engineer | 5 days | M3 approved |
| Functional testing: all 7 artifact types against QA rubric | QA Engineer | 8 days | Test plan approved |
| Integration testing: API → Lambda → Bedrock → S3 end-to-end | QA Engineer | 5 days | Functional testing |
| Async job performance load testing (10 concurrent jobs) | DevOps Engineer | 3 days | Integration testing |
| Security and compliance testing: OWASP, WAF, encryption | Security Engineer | 5 days | All services deployed |
| DR testing: DynamoDB PITR, Lambda redeployment, S3 replication | Cloud Engineer | 2 days | Security testing |
| Artifact quality validation with iterative Bedrock prompt tuning | ML/AI Engineer | 10 days | Functional testing |
| UAT with Head of Solutions and 5–10 pre-sales consultants | QA Engineer + PM | 5 days | Quality validation |
| SOC 2 evidence package assembly | Security Engineer + QA | 3 days | All testing complete |
| CTO and Security Lead go-live sign-off | Vendor PM | 1 day | Evidence package |

### Deliverables

- [ ] Test Plan (Deliverable 18, Week 21)
- [ ] Functional & Integration Test Results (Deliverable 19, Week 24)
- [ ] Security & Compliance Test Results + SOC 2 Evidence (Deliverable 20, Week 25)
- [ ] UAT Sign-Off from Head of Solutions (Deliverable 21, Week 26)
- [ ] Go-Live Readiness Sign-Off from CTO (Deliverable 22, Week 26 / Milestone M4)

### Success Criteria

- All 7 artifact types pass functional testing with ≥90% first-review QA pass rate
- 10 concurrent job load test completes all jobs within 90 minutes with zero DLQ messages
- OWASP API Security Top 10 test passes with no critical or high findings
- SOC 2 evidence package assembled and reviewed by Security & Compliance Lead
- UAT pass rate ≥90% across all briefs submitted by 5–10 pre-sales consultants

---

## Phase 5: Deployment, Hypercare & Close (Weeks 27–36)

### Objectives

- Deploy Phase 1 Pre-Sales MVP to Production by 30 September 2026
- Execute Okta-to-Cognito production cutover and legacy EC2 decommission
- Deploy Phase 2 Delivery & Terraform modules to Production by 15 December 2026
- Complete 8-week hypercare and deliver optimisation roadmap

### Activities

The following table documents all Phase 5 activities with ownership and duration:

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Staging full-stack validation prior to Phase 1 production deployment | QA Engineer | 3 days | M4 signed off |
| Production Phase 1 deployment (Pre-Sales MVP) | Cloud Engineer + DevOps | 1 day | Staging validation |
| Okta-to-Cognito DNS/SSO final cutover (all 120 users) | Security Engineer | 1 day | Phase 1 deployed |
| 48-hour cutover monitoring and issue resolution | Vendor Team | 2 days | Cutover complete |
| Legacy EC2 monolith data export and decommission | Cloud Engineer | 5 days | Phase 1 stable (30 days) |
| Admin and pre-sales consultant training sessions | Technical Writer + PM | 3 days | Phase 1 deployed |
| Production Phase 2 deployment (Delivery & Terraform) | Cloud Engineer + DevOps | 1 day | Phase 1 stable |
| Delivery team enablement session | Technical Writer + PM | 1 day | Phase 2 deployed |
| 8-week hypercare: monitoring, incident response, prompt tuning | Vendor Team | 8 weeks | Phase 1 Go-Live |
| Optimisation roadmap documentation | Vendor Architect | 3 days | Hypercare complete |
| Project closeout: retrospective, final report | Vendor PM | 2 days | Roadmap delivered |

### Deliverables

- [ ] Production Deployment Phase 1 — Pre-Sales MVP live (30 Sep 2026 / Milestone M5)
- [ ] Legacy EC2 Monolith Decommission Certificate (Week 29 / Milestone M6)
- [ ] Production Deployment Phase 2 — Delivery & Terraform (15 Dec 2026 / Milestone M7)
- [ ] Admin & Consultant Training Materials (Week 30)
- [ ] Operational Runbooks (Week 34)
- [ ] As-Built Architecture Documentation & API Reference (Week 35)
- [ ] SOC 2 Evidence Package — Final (Week 35)
- [ ] Hypercare Report & Optimisation Roadmap (Week 36 / Milestone M9)

### Success Criteria

- Phase 1 Pre-Sales MVP live in Production with ≥95% Cognito login success rate at cutover
- Legacy EC2 monolith decommissioned with zero data loss
- Phase 2 Delivery & Terraform modules live in Production by 15 December 2026
- General Availability to all ~120 users by Q1 2027 (Milestone M8)
- 8-week hypercare complete with all Severity 1 and Severity 2 issues resolved

---

# Infrastructure Deployment

This section documents the complete infrastructure deployment procedures for all four infrastructure layers: Networking, Security, Compute, and Monitoring. All infrastructure is provisioned exclusively via Terraform from the `infrastructure/` directory of the GitHub repository. No manual AWS console resource creation is permitted in any environment. Each subsection covers the required components, Terraform module location, deployment steps, validation procedures, success criteria, and rollback procedures.

## Networking

The networking layer establishes the VPC foundation, private and public subnet topology, NAT Gateways, PrivateLink endpoints, API Gateway, and CloudFront distribution that all other platform components rely on. It must be deployed first, before any other infrastructure module.

### Components

The following table describes all networking components deployed in the platform:

| Component | Specification | Purpose |
|-----------|---------------|---------|
| VPC (`amatra-platform-vpc-{env}`) | CIDR `10.10.0.0/16`, us-west-2, 3 AZs | Isolated network boundary for all platform resources |
| Private Subnets (3×) | `10.10.10.0/24`, `10.10.11.0/24`, `10.10.12.0/24` | Lambda VPC execution; no internet gateway route; all service traffic via PrivateLink |
| Public Subnets (3×) | `10.10.0.0/24`, `10.10.1.0/24`, `10.10.2.0/24` | NAT Gateway hosting for outbound egress only |
| NAT Gateways (3× prod, 1× dev) | One per AZ in Production | Outbound internet egress for Lambda (SES, external calls) |
| Internet Gateway | 1 per VPC | Attached to public subnets for NAT Gateway internet routing |
| PrivateLink — Bedrock | Interface endpoint `com.amazonaws.us-west-2.bedrock-runtime` | Private Bedrock InvokeModel API access |
| PrivateLink — Secrets Manager | Interface endpoint `com.amazonaws.us-west-2.secretsmanager` | Private Secrets Manager access from Lambda |
| PrivateLink — SQS | Interface endpoint `com.amazonaws.us-west-2.sqs` | Private SQS access from Lambda |
| PrivateLink — SES | Interface endpoint `com.amazonaws.us-west-2.email-smtp` | Private SES SMTP access from Lambda |
| S3 Gateway Endpoint | VPC Gateway Endpoint (free) | Private S3 access routing — no NAT charges |
| DynamoDB Gateway Endpoint | VPC Gateway Endpoint (free) | Private DynamoDB access routing — no NAT charges |
| API Gateway (REST, Regional) | Regional endpoint `amatra-platform-api-{env}` | Single external entry point for all API calls |
| CloudFront Distribution | S3 origin, TLS enforced, WAF attached | CDN for static web assets; HTTPS-only |

### Script Location

Networking Terraform module: `infrastructure/modules/networking/`

Environment-specific entry point: `infrastructure/environments/{env}/main.tf` (references `module "networking"`)

Variable definitions: `infrastructure/modules/networking/variables.tf`

### Deployment Steps

Deploy the networking layer first, targeting the module specifically to avoid dependency issues with subsequent modules:

```bash
# Step 1: Navigate to the environment directory
cd infrastructure/environments/dev

# Step 2: Verify networking variable values are set
grep -E "vpc_cidr|nat_gateway_count|privatelink" terraform.tfvars

# Step 3: Plan and apply the networking module
terraform plan \
  -var-file=terraform.tfvars \
  -target=module.networking \
  -out=networking.plan

terraform apply networking.plan

# Step 4: Capture networking outputs for downstream modules
terraform output -json | python3 -c "
import json, sys
outputs = json.load(sys.stdin)
keys = ['vpc_id', 'private_subnet_ids', 'public_subnet_ids', 'api_gateway_endpoint']
for k in keys:
    print(f'{k}: {outputs.get(k, {}).get(\"value\", \"NOT FOUND\")}')
"

# Step 5: Verify PrivateLink endpoints are available
aws ec2 describe-vpc-endpoints \
  --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)" \
  --query "VpcEndpoints[].{Service:ServiceName,State:State}" \
  --region us-west-2
```

### Validation

After deploying the networking layer, run the following validation checks to confirm correct configuration:

```bash
# Verify private subnets have no route to the Internet Gateway
PRIVATE_RT=$(aws ec2 describe-route-tables \
  --filters "Name=tag:Name,Values=amatra-private-rt-*" \
  --query "RouteTables[0].RouteTableId" --output text \
  --region us-west-2)

aws ec2 describe-route-tables \
  --route-table-ids "$PRIVATE_RT" \
  --query "RouteTables[0].Routes[?GatewayId!=null].GatewayId" \
  --region us-west-2
# Expected: No igw-* entries in private route tables

# Verify NAT Gateway is in available state
aws ec2 describe-nat-gateways \
  --filter "Name=tag:Environment,Values=dev" \
  --query "NatGateways[].State" \
  --region us-west-2
# Expected: ["available"] for dev; ["available","available","available"] for prod

# Test API Gateway health endpoint reachability
API_URL=$(terraform output -raw api_gateway_url)
curl -s -o /dev/null -w "%{http_code}" "$API_URL/api/v1/health"
# Expected: 200
```

### Success Criteria

- VPC `amatra-platform-vpc-{env}` created with CIDR `10.10.0.0/16`
- All 3 private subnets and 3 public subnets provisioned and tagged correctly
- NAT Gateways in `available` state (3 in Production, 1 in Dev)
- All 4 PrivateLink interface endpoints in `available` state
- S3 and DynamoDB Gateway endpoints associated with private route tables
- API Gateway health endpoint returns HTTP 200
- Private subnets have zero direct routes to Internet Gateway

### Rollback

Networking rollback removes the VPC and all dependent resources. Because other modules depend on networking, destroy dependent modules first in reverse dependency order before removing the networking module:

```bash
# Step 1: Destroy dependent modules first (reverse dependency order)
cd infrastructure/environments/dev

terraform destroy \
  -var-file=terraform.tfvars \
  -target=module.monitoring \
  -target=module.compute \
  -target=module.security \
  --auto-approve

# Step 2: Destroy the networking module
terraform destroy \
  -var-file=terraform.tfvars \
  -target=module.networking \
  --auto-approve

# Step 3: Confirm all VPC resources are removed
aws ec2 describe-vpcs \
  --filters "Name=tag:Application,Values=amatra-intelligent-solution-builder" \
  --query "Vpcs[].VpcId" \
  --region us-west-2
# Expected: empty list
```

---

## Security

The security layer provisions all identity, encryption, audit, and access-control resources required for the platform's SOC 2 Type II posture and GDPR-aligned data handling. It must be deployed after networking and before compute.

### Components

The following table describes all security components deployed in the platform:

| Component | Specification | Purpose |
|-----------|---------------|---------|
| Amazon Cognito User Pool (`amatra-users-{env}`) | 3 groups: `presales-consultants`, `delivery-consultants`, `admins`; MFA mandatory for admins | User authentication, role-based OAuth 2.0 scopes, usage-limit enforcement |
| AWS WAF v2 Web ACL | OWASP CommonRuleSet + KnownBadInputsRuleSet; rate limit 1,000 req/min/IP; IP Reputation List | API Gateway and CloudFront protection against OWASP Top 10 |
| KMS CMK — Artifacts (`alias/amatra-artifacts-{env}`) | 365-day auto-rotation | Encrypts S3 artifact bucket (SSE-KMS) |
| KMS CMK — Database (`alias/amatra-database-{env}`) | 365-day auto-rotation | Encrypts DynamoDB tables at rest |
| KMS CMK — Secrets (`alias/amatra-secrets-{env}`) | 365-day auto-rotation | Encrypts Secrets Manager secrets |
| KMS CMK — Audit (`alias/amatra-audit-{env}`) | 365-day auto-rotation | Encrypts CloudTrail logs and CloudWatch Logs |
| AWS Secrets Manager | Bedrock config, Datadog API key, SES credentials; 30-day auto-rotation | Centralised credential storage; no plaintext in Lambda env vars |
| AWS CloudTrail (multi-region trail) | Management + data events; S3 Object Lock (WORM) 7-year retention | SOC 2 immutable API audit log |
| AWS Config | SOC 2 baseline rules: S3 Block Public Access, CloudTrail, KMS rotation, Secrets Manager rotation | Continuous compliance monitoring |
| AWS Security Hub | Aggregates Config findings and CloudTrail anomaly detection | Centralised security posture dashboard |
| IAM Execution Roles (9×) | Least-privilege, per-Lambda function; no wildcard resource permissions | Lambda-to-service authorisation |
| S3 Block Public Access | Enforced at account level | Prevents accidental public exposure of artifacts |
| TLS Policy | Minimum TLS 1.2 on API Gateway and CloudFront | Encrypts all data in transit |

### Script Location

Security Terraform module: `infrastructure/modules/security/`

Cognito submodule: `infrastructure/modules/security/cognito/`

KMS submodule: `infrastructure/modules/security/kms/`

IAM submodule: `infrastructure/modules/security/iam/`

### Deployment Steps

Deploy the security module after the networking module is validated. The following commands provision all security resources including KMS keys, Cognito, WAF, IAM roles, Secrets Manager, and CloudTrail:

```bash
# Step 1: Deploy the security module
cd infrastructure/environments/dev

terraform plan \
  -var-file=terraform.tfvars \
  -target=module.security \
  -out=security.plan

terraform apply security.plan

# Step 2: Capture key security outputs
terraform output -json | python3 -c "
import json, sys
outputs = json.load(sys.stdin)
keys = ['kms_artifacts_key_arn', 'kms_database_key_arn', 'cognito_user_pool_id',
        'cognito_app_client_id', 'waf_acl_arn']
for k in keys:
    print(f'{k}: {outputs.get(k, {}).get(\"value\", \"NOT FOUND\")}')
" > security-outputs.txt

# Step 3: Upload initial secrets to Secrets Manager
AWS_REGION="us-west-2"
ENV="dev"

aws secretsmanager create-secret \
  --name "/amatra/$ENV/bedrock/config" \
  --description "Bedrock API configuration parameters" \
  --secret-string '{"model_id":"anthropic.claude-3-sonnet-20240229-v1:0","region":"us-west-2"}' \
  --kms-key-id "alias/amatra-secrets-$ENV" \
  --region "$AWS_REGION"

aws secretsmanager create-secret \
  --name "/amatra/$ENV/datadog/api_key" \
  --description "Datadog APM API key" \
  --secret-string '{"api_key":"<REPLACE_WITH_ACTUAL_DATADOG_KEY>"}' \
  --kms-key-id "alias/amatra-secrets-$ENV" \
  --region "$AWS_REGION"

# Step 4: Verify CloudTrail is active
aws cloudtrail get-trail-status \
  --name amatra-audit-trail \
  --region us-west-2 \
  --query '{IsLogging:IsLogging,LatestDeliveryTime:LatestDeliveryTime}'
```

### Validation

After deploying the security layer, validate all controls are operational before proceeding to the compute module:

```bash
# Validate KMS key rotation is enabled on all 4 CMKs
for key_alias in amatra-artifacts-dev amatra-database-dev \
                 amatra-secrets-dev amatra-audit-dev; do
  KEY_ID=$(aws kms describe-key \
    --key-id "alias/$key_alias" \
    --query 'KeyMetadata.KeyId' --output text)
  ROTATION=$(aws kms get-key-rotation-status \
    --key-id "$KEY_ID" \
    --query 'KeyRotationEnabled' --output text)
  echo "$key_alias: rotation_enabled=$ROTATION"
done
# Expected: all 4 show rotation_enabled=True

# Validate Cognito User Pool has 3 groups
POOL_ID=$(terraform output -raw cognito_user_pool_id)
aws cognito-idp list-groups \
  --user-pool-id "$POOL_ID" \
  --query 'Groups[].GroupName' \
  --region us-west-2
# Expected: ["presales-consultants", "delivery-consultants", "admins"]

# Validate WAF ACL is attached to API Gateway
aws wafv2 get-web-acl-for-resource \
  --resource-arn "$(terraform output -raw api_gateway_stage_arn)" \
  --region us-west-2
# Expected: WAF ACL details returned (not empty)

# Validate CloudTrail is logging
aws cloudtrail get-trail-status \
  --name amatra-audit-trail \
  --region us-west-2 \
  --query 'IsLogging'
# Expected: true
```

### Success Criteria

- All 4 KMS CMKs created with 365-day auto-rotation enabled
- Cognito User Pool created with 3 groups and MFA mandatory for `admins` group
- WAF Web ACL attached to API Gateway with OWASP Managed Rules active
- Secrets Manager secrets created for Bedrock, Datadog, and SES credentials with 30-day rotation
- CloudTrail multi-region trail active and logging to immutable S3 bucket with Object Lock
- AWS Config evaluating all SOC 2 baseline rules with zero non-compliant resources at launch
- S3 Block Public Access confirmed enabled at account level

### Rollback

Security rollback is performed in reverse order. KMS keys cannot be immediately deleted (7-day pending deletion minimum); schedule for deletion rather than immediately destroying:

```bash
# Step 1: Schedule KMS key deletion (7-day pending window — cannot be shortened)
for key_alias in amatra-artifacts-dev amatra-database-dev \
                 amatra-secrets-dev amatra-audit-dev; do
  KEY_ID=$(aws kms describe-key \
    --key-id "alias/$key_alias" \
    --query 'KeyMetadata.KeyId' --output text 2>/dev/null)
  if [ ! -z "$KEY_ID" ]; then
    aws kms schedule-key-deletion \
      --key-id "$KEY_ID" \
      --pending-window-in-days 7
    echo "Scheduled $key_alias for deletion in 7 days"
  fi
done

# Step 2: Destroy remaining security resources via Terraform
cd infrastructure/environments/dev
terraform destroy \
  -var-file=terraform.tfvars \
  -target=module.security \
  --auto-approve

# Step 3: Verify CloudTrail is no longer logging
aws cloudtrail get-trail-status \
  --name amatra-audit-trail \
  --region us-west-2 \
  --query 'IsLogging'
# Expected: false
```

---

## Compute

The compute layer deploys all Lambda functions, the Step Functions standard workflow, SQS FIFO queues, and ECR container repositories that host the platform's business logic. Deploy this layer after both networking and security layers are validated.

### Components

The following table describes all compute components deployed in the platform:

| Component | Specification | Purpose |
|-----------|---------------|---------|
| Brief Submission Lambda (`amatra-brief-submission-{env}`) | 512 MB, 30s timeout, 50 reserved concurrency, arm64 | Validates brief, enqueues SQS message, returns job ID |
| Job Status Lambda (`amatra-job-status-{env}`) | 256 MB, 10s timeout, 20 reserved concurrency, arm64 | Returns current job status and artifact manifest |
| Artifact Retrieval Lambda (`amatra-artifact-retrieval-{env}`) | 256 MB, 10s timeout, 20 reserved concurrency, arm64 | Generates pre-signed S3 URLs (1-hour expiry) for artifact downloads |
| Admin Governance Lambda (`amatra-admin-governance-{env}`) | 512 MB, 30s timeout, 10 reserved concurrency, arm64 | CRUD for per-user and global usage limits |
| Bedrock Orchestration Lambda (`amatra-bedrock-orchestration-{env}`) | 3008 MB, 900s timeout, 100 reserved concurrency, arm64 | Assembles prompt context and invokes Bedrock per artifact type |
| Output Validation Lambda (`amatra-output-validation-{env}`) | 1024 MB, 60s timeout, 50 reserved concurrency, arm64 | Validates Bedrock output structure before storage |
| Artifact Template Lambda (`amatra-artifact-template-{env}`) | 2048 MB, 120s timeout, 30 reserved concurrency, arm64 | Populates Word/Excel/PowerPoint templates from markdown |
| SES Notification Lambda (`amatra-ses-notification-{env}`) | 256 MB, 10s timeout, 10 reserved concurrency, arm64 | Sends job completion and error emails |
| Health Check Lambda (`amatra-health-check-{env}`) | 128 MB, 5s timeout, 5 reserved concurrency, arm64 | Invoked by CloudWatch Synthetics every 1 minute |
| Step Functions Workflow (`amatra-generation-workflow-{env}`) | Standard workflow; max 1-year execution duration | Orchestrates multi-artifact Bedrock generation pipeline |
| SQS FIFO Queue (`amatra-generation-queue-{env}.fifo`) | Content-based deduplication; 4-day retention; MessageGroupId=solution_id | Decouples API submission from Bedrock pipeline |
| SQS Dead-Letter Queue (`amatra-generation-dlq-{env}`) | MaxReceiveCount=3; Standard queue | Captures permanently failed generation jobs |
| ECR Repositories (9×) | One per Lambda function; immutable tags in Production | Stores Lambda container images |

### Script Location

Compute Terraform module: `infrastructure/modules/compute/`

Lambda submodule: `infrastructure/modules/compute/lambda/`

Step Functions submodule: `infrastructure/modules/compute/stepfunctions/`

SQS submodule: `infrastructure/modules/compute/sqs/`

Lambda container Dockerfiles: `application/lambdas/{function-name}/Dockerfile`

### Deployment Steps

With container images already pushed to ECR (Section 3.4), deploy the compute infrastructure module:

```bash
# Step 1: Deploy the compute module
cd infrastructure/environments/dev

terraform plan \
  -var-file=terraform.tfvars \
  -target=module.compute \
  -out=compute.plan

terraform apply compute.plan

# Step 2: Verify all Lambda functions are in Active state
aws lambda list-functions \
  --query "Functions[?starts_with(FunctionName, 'amatra-')].{Name:FunctionName,State:State}" \
  --region us-west-2

# Step 3: Health-check each API-facing Lambda function
for function in amatra-brief-submission-dev amatra-job-status-dev \
                amatra-artifact-retrieval-dev amatra-admin-governance-dev \
                amatra-health-check-dev; do
  echo "Testing $function..."
  aws lambda invoke \
    --function-name "$function" \
    --payload '{"httpMethod":"GET","path":"/api/v1/health"}' \
    --region us-west-2 \
    /tmp/lambda-response.json
  cat /tmp/lambda-response.json
  echo ""
done

# Step 4: Validate Step Functions workflow is Active
aws stepfunctions describe-state-machine \
  --state-machine-arn "$(terraform output -raw stepfunctions_arn)" \
  --query '{Name:name,Status:status}' \
  --region us-west-2

# Step 5: Verify SQS queue configuration
aws sqs get-queue-attributes \
  --queue-url "$(terraform output -raw sqs_queue_url)" \
  --attribute-names All \
  --query '{FIFO:Attributes.FifoQueue,ContentDedup:Attributes.ContentBasedDeduplication,Retention:Attributes.MessageRetentionPeriod}' \
  --region us-west-2
```

### Validation

Run an end-to-end generation test in Dev to validate the full compute stack integration:

```bash
API_URL=$(terraform output -raw api_gateway_url)
TEST_TOKEN="<cognito-test-user-jwt>"

# Submit a test brief
RESPONSE=$(curl -s -X POST "$API_URL/api/v1/briefs" \
  -H "Authorization: Bearer $TEST_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "client_name": "Integration Test Corp",
    "industry": "Technology",
    "requirements": "Cloud migration of legacy ERP to AWS",
    "artifact_types": ["discovery-questionnaire", "solution-briefing"]
  }')

SOLUTION_ID=$(echo "$RESPONSE" | \
  python3 -c "import json,sys; print(json.load(sys.stdin)['solution_id'])")
echo "Submitted job: $SOLUTION_ID"

# Poll for completion (max 90 minutes)
for i in {1..45}; do
  STATUS=$(curl -s "$API_URL/api/v1/briefs/$SOLUTION_ID/status" \
    -H "Authorization: Bearer $TEST_TOKEN" | \
    python3 -c "import json,sys; print(json.load(sys.stdin)['status'])")
  echo "Attempt $i: status=$STATUS"
  if [ "$STATUS" = "COMPLETE" ] || [ "$STATUS" = "FAILED" ]; then break; fi
  sleep 120
done

echo "Final status: $STATUS"
```

### Success Criteria

- All 9 Lambda functions deployed with correct memory, timeout, and reserved concurrency settings
- Step Functions standard workflow `amatra-generation-workflow-dev` in `ACTIVE` state
- SQS FIFO queue `amatra-generation-queue-dev.fifo` created with content-based deduplication and 4-day retention
- SQS DLQ `amatra-generation-dlq-dev` created with `MaxReceiveCount=3` configured
- End-to-end generation test completes successfully in under 90 minutes
- No DLQ messages after the end-to-end test

### Rollback

Lambda rollback uses the blue-green alias pattern — it completes in under 5 minutes with no redeployment:

```bash
# Identify the previous Lambda version for each function
for function in brief-submission job-status artifact-retrieval admin-governance \
                bedrock-orchestration output-validation artifact-template ses-notification; do
  FUNCTION_NAME="amatra-$function-dev"
  echo "--- $FUNCTION_NAME ---"
  aws lambda list-aliases \
    --function-name "$FUNCTION_NAME" \
    --query "Aliases[].{Name:Name,Version:FunctionVersion}" \
    --region us-west-2
done

# Roll back a specific function to the previous version
FUNCTION_NAME="amatra-brief-submission-dev"
PREVIOUS_VERSION="<version-number>"

aws lambda update-alias \
  --function-name "$FUNCTION_NAME" \
  --name production \
  --function-version "$PREVIOUS_VERSION" \
  --region us-west-2

echo "Rollback complete for $FUNCTION_NAME -> version $PREVIOUS_VERSION"
```

---

## Monitoring

The monitoring layer provisions all CloudWatch dashboards, alarms, synthetic canaries, log groups, X-Ray tracing, and Datadog APM integration needed for continuous platform observability and SOC 2 detective controls. Deploy this layer last, after all application components are operational.

### Components

The following table describes all monitoring components deployed in the platform:

| Component | Specification | Purpose |
|-----------|---------------|---------|
| CloudWatch Dashboard (`amatra-platform-{env}`) | 7 KPI widgets: API error rate, Lambda P99, Step Functions failure rate, SQS queue depth, DLQ count, Bedrock token consumption, job completion rate | Real-time platform health for operations team |
| CloudWatch Dashboard (`amatra-security-{env}`) | CloudTrail security events, Cognito auth metrics, WAF blocked requests, AWS Config compliance | Security posture monitoring for Security Lead |
| CloudWatch Synthetics Canary | 1-min interval (5-min in Dev); targets `/api/v1/health` | Rapid availability detection |
| Alarm — Platform-Availability-Critical | API Gateway 5xx rate > 1% over 5 min; Severity 1 → SNS + PagerDuty | Availability SLA enforcement |
| Alarm — DLQ-Message-Received | SQS DLQ `ApproximateNumberOfMessagesVisible` > 0; Severity 2 | Failed job detection |
| Alarm — Step-Functions-Failure-Rate | Step Functions failure rate > 5% over 10 min; Severity 2 | Generation pipeline health |
| Alarm — Bedrock-Quota-Warning | Token consumption > 80% of 90M monthly quota; Severity 2 | Proactive quota management |
| Alarm — Lambda-Error-Rate | Any Lambda function error rate > 5% over 5 min; Severity 2 | Per-function health monitoring |
| Alarm — API-Latency-P95-Breach | API Gateway P95 latency > 5,000 ms over 5 min; Severity 3 | Performance SLA monitoring |
| Alarm — CloudTrail-Root-Login | Root account console login event; Severity 1 | Security control |
| Alarm — IAM-Policy-Change | `PutRolePolicy`/`AttachRolePolicy` outside CI/CD; Severity 1 | Privilege escalation detection |
| CloudWatch Log Groups (9×) | `/aws/lambda/amatra-{function}-{env}`; 365-day retention in Production | Structured JSON Lambda execution logs |
| AWS X-Ray Tracing | Active tracing on all Lambda + API Gateway; 5% sampling in Production | End-to-end distributed tracing |
| SNS Topic (`amatra-ops-alerts-{env}`) | Operations team email + PagerDuty (Severity 1 only) | Alert notification routing |
| Datadog APM (5 hosts) | Lambda + API Gateway host monitoring; 30-second metric latency | Advanced APM dashboards and anomaly detection |

### Script Location

Monitoring Terraform module: `infrastructure/modules/monitoring/`

CloudWatch dashboard JSON templates: `infrastructure/modules/monitoring/dashboards/`

Alarm definitions: `infrastructure/modules/monitoring/alarms/`

X-Ray configuration: embedded in Lambda Terraform resource blocks (attribute `tracing_config`)

### Deployment Steps

Deploy the monitoring module after all compute resources are confirmed healthy:

```bash
# Step 1: Deploy the monitoring module
cd infrastructure/environments/dev

terraform plan \
  -var-file=terraform.tfvars \
  -target=module.monitoring \
  -out=monitoring.plan

terraform apply monitoring.plan

# Step 2: Confirm SNS topic and subscriptions are configured
SNS_TOPIC_ARN=$(terraform output -raw sns_ops_topic_arn)
aws sns list-subscriptions-by-topic \
  --topic-arn "$SNS_TOPIC_ARN" \
  --query 'Subscriptions[].{Protocol:Protocol,Endpoint:Endpoint}' \
  --region us-west-2

# Step 3: Verify all CloudWatch alarms are in OK state
aws cloudwatch describe-alarms \
  --alarm-name-prefix "amatra-" \
  --query "MetricAlarms[].{Name:AlarmName,State:StateValue}" \
  --region us-west-2

# Step 4: Confirm CloudWatch Synthetics canary is running
aws synthetics describe-canaries \
  --query "Canaries[?Name=='amatra-health-canary-dev'].{Name:Name,Status:Status.State}" \
  --region us-west-2

# Step 5: Verify X-Ray active tracing on all Lambda functions
aws lambda list-functions \
  --query "Functions[?starts_with(FunctionName,'amatra-')].{Name:FunctionName,Tracing:TracingConfig.Mode}" \
  --region us-west-2
# Expected: all functions show Mode = "Active"
```

### Validation

Trigger a test alarm to validate the full SNS notification pipeline end-to-end:

```bash
# Set the DLQ alarm to ALARM state to test notification routing
aws cloudwatch set-alarm-state \
  --alarm-name "amatra-DLQ-Message-Received-dev" \
  --state-value ALARM \
  --state-reason "Test: validating SNS notification routing" \
  --region us-west-2

# Wait 30 seconds then confirm the operations team received the notification email
sleep 30
echo "ACTION: Confirm operations team email inbox shows SNS notification from amatra-ops-alerts-dev"

# Reset the alarm back to OK
aws cloudwatch set-alarm-state \
  --alarm-name "amatra-DLQ-Message-Received-dev" \
  --state-value OK \
  --state-reason "Test complete" \
  --region us-west-2

# Confirm the dashboard has the expected number of widgets
aws cloudwatch get-dashboard \
  --dashboard-name "amatra-platform-dev" \
  --region us-west-2 \
  --query 'DashboardBody' | \
  python3 -c "import json,sys; body=json.load(sys.stdin); print(f'Widgets: {len(json.loads(body)[\"widgets\"])}')"
# Expected: Widgets: 7 (or more)
```

### Success Criteria

- Both CloudWatch dashboards (`amatra-platform-{env}` and `amatra-security-{env}`) created and displaying live data
- All 10 CloudWatch alarms created and in `OK` state at baseline
- CloudWatch Synthetics canary running on schedule and returning `PASSED`
- Test alarm SNS notification received by operations team within 2 minutes
- All Lambda functions show `TracingMode: Active` in X-Ray configuration
- All 9 Lambda Log Groups created with correct retention (365 days Production, 30 days Dev)
- Datadog APM reporting metrics from ≥1 host within 10 minutes of deployment

### Rollback

Monitoring resources are observational and non-destructive. If alarms produce false positives during initial deployment, suppress alarm actions while investigating — do not delete alarms:

```bash
# Temporarily suppress a noisy alarm's actions (SNS notifications silenced)
ALARM_NAME="amatra-Lambda-Error-Rate-dev"
aws cloudwatch disable-alarm-actions \
  --alarm-names "$ALARM_NAME" \
  --region us-west-2
echo "Alarm actions disabled for $ALARM_NAME — SNS notifications suppressed"

# Re-enable after investigation is complete
aws cloudwatch enable-alarm-actions \
  --alarm-names "$ALARM_NAME" \
  --region us-west-2
echo "Alarm actions re-enabled for $ALARM_NAME"

# Full module teardown (for environment decommission only)
cd infrastructure/environments/dev
terraform destroy \
  -var-file=terraform.tfvars \
  -target=module.monitoring \
  --auto-approve
```

---

# Application Configuration

This section covers application-layer configuration: Lambda environment variables, API Gateway settings, Cognito OAuth 2.0 scope wiring, Step Functions workflow parameters, usage limit initialisation, and IAM policy implementation.

## Lambda Environment Variable Configuration

All Lambda functions receive configuration through environment variables injected by Terraform at deployment time. No plaintext secrets are stored in environment variables — all sensitive values reference Secrets Manager ARNs retrieved at runtime by the Lambda function using its IAM execution role.

The following Terraform excerpt shows the pattern for the Brief Submission Lambda:

```hcl
# infrastructure/modules/compute/lambda/main.tf (excerpt)
resource "aws_lambda_function" "brief_submission" {
  function_name = "amatra-brief-submission-${var.environment}"
  package_type  = "Image"
  image_uri     = "${var.ecr_registry}/amatra/brief-submission:${var.image_tag}"
  role          = aws_iam_role.brief_submission_role.arn
  architectures = ["arm64"]
  memory_size   = var.lambda_config.brief_submission.memory_mb
  timeout       = var.lambda_config.brief_submission.timeout_seconds

  reserved_concurrent_executions = var.lambda_config.brief_submission.reserved_concurrency

  environment {
    variables = {
      ENVIRONMENT                  = var.environment
      APPLICATION_NAME             = var.application_name
      LOG_LEVEL                    = var.log_level
      AWS_REGION_NAME              = var.aws_region
      SOLUTION_STATE_TABLE         = var.dynamodb_solution_state_table
      USAGE_TRACKING_TABLE         = var.dynamodb_usage_tracking_table
      SQS_QUEUE_URL                = aws_sqs_queue.generation_queue.url
      ARTIFACTS_BUCKET             = var.s3_artifacts_bucket
      BEDROCK_SECRET_ARN           = aws_secretsmanager_secret.bedrock_config.arn
      PRESIGNED_URL_EXPIRY         = tostring(var.presigned_url_expiry_seconds)
      DEFAULT_USER_MONTHLY_LIMIT   = tostring(var.default_user_monthly_limit)
      DEFAULT_GLOBAL_MONTHLY_LIMIT = tostring(var.default_global_monthly_limit)
    }
  }

  tracing_config {
    mode = "Active"
  }
}
```

## API Gateway Stage Configuration

The following Terraform excerpt shows the API Gateway stage configuration with structured access logging, X-Ray tracing, and WAF attachment:

```hcl
# infrastructure/modules/networking/api_gateway.tf (excerpt)
resource "aws_api_gateway_stage" "v1" {
  rest_api_id   = aws_api_gateway_rest_api.platform.id
  stage_name    = "v1"
  deployment_id = aws_api_gateway_deployment.platform.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_access.arn
    format = jsonencode({
      requestId          = "$context.requestId"
      sourceIp           = "$context.identity.sourceIp"
      requestTime        = "$context.requestTime"
      httpMethod         = "$context.httpMethod"
      resourcePath       = "$context.resourcePath"
      status             = "$context.status"
      integrationLatency = "$context.integrationLatency"
      jwtClaims          = "$context.authorizer.claims"
    })
  }

  xray_tracing_enabled = true
}

resource "aws_wafv2_web_acl_association" "api_gateway" {
  resource_arn = aws_api_gateway_stage.v1.arn
  web_acl_arn  = aws_wafv2_web_acl.platform.arn
}
```

## Step Functions Retry Configuration

The Step Functions generation workflow applies retry logic to all Bedrock invocation states. The following JSON ASL excerpt shows the retry and catch configuration:

```json
{
  "InvokeBedrockForArtifact": {
    "Type": "Task",
    "Resource": "arn:aws:states:::lambda:invoke",
    "Parameters": {
      "FunctionName.$": "$.bedrock_orchestration_function_arn",
      "Payload.$": "$"
    },
    "Retry": [
      {
        "ErrorEquals": ["ThrottlingException", "ServiceUnavailableException"],
        "IntervalSeconds": 30,
        "MaxAttempts": 3,
        "BackoffRate": 2
      }
    ],
    "Catch": [
      {
        "ErrorEquals": ["ValidationException", "ModelNotReadyException"],
        "Next": "HandlePermanentFailure"
      }
    ],
    "Next": "ValidateOutput"
  }
}
```

## Usage Limit Initialisation

After the Admin Governance Lambda is deployed, configure the default per-user and global monthly generation limits via the admin API:

```bash
API_URL="https://<api-id>.execute-api.us-west-2.amazonaws.com/v1"
ADMIN_TOKEN="<admin-group-cognito-jwt>"

# Set default global monthly limit (500 engagements/month)
curl -s -X PUT "$API_URL/api/v1/admin/usage/limits/global" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"limit": 500, "reason": "Initial configuration per SOW sizing"}'

# Verify the configuration was applied
curl -s "$API_URL/api/v1/admin/usage" \
  -H "Authorization: Bearer $ADMIN_TOKEN" | python3 -m json.tool
```

## IAM Least-Privilege Policy Example

The following JSON shows the least-privilege IAM policy for the Brief Submission Lambda, illustrating the per-resource, per-action approach required across all Lambda execution roles:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowDynamoDBSolutionState",
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:UpdateItem",
        "dynamodb:Query"
      ],
      "Resource": [
        "arn:aws:dynamodb:us-west-2:ACCOUNT_ID:table/amatra-solution-state-prod",
        "arn:aws:dynamodb:us-west-2:ACCOUNT_ID:table/amatra-usage-tracking-prod"
      ]
    },
    {
      "Sid": "AllowSQSPublish",
      "Effect": "Allow",
      "Action": ["sqs:SendMessage"],
      "Resource": "arn:aws:sqs:us-west-2:ACCOUNT_ID:amatra-generation-queue-prod.fifo"
    },
    {
      "Sid": "AllowS3BriefWrite",
      "Effect": "Allow",
      "Action": ["s3:PutObject"],
      "Resource": "arn:aws:s3:::amatra-artifacts-prod/*/brief/*"
    },
    {
      "Sid": "AllowSecretsRead",
      "Effect": "Allow",
      "Action": ["secretsmanager:GetSecretValue"],
      "Resource": "arn:aws:secretsmanager:us-west-2:ACCOUNT_ID:secret:/amatra/prod/*"
    }
  ]
}
```

## Application Configuration Security Checklist

Before proceeding to Integration Testing, complete all application-layer security validations:

- [ ] All Lambda environment variables contain no plaintext secrets (all sensitive values are Secrets Manager ARNs)
- [ ] Each Lambda IAM role grants only the minimum required actions and specific resource ARNs
- [ ] No wildcard (`*`) resource ARNs in any production Lambda IAM policy
- [ ] Cognito User Pool App Client has token revocation enabled
- [ ] S3 artifact bucket lifecycle rules confirmed: 90-day Intelligent-Tiering transition, 1825-day Glacier transition
- [ ] DynamoDB TTL attribute enabled on solution-state table (3-year retention = 1095-day TTL)
- [ ] Secrets Manager rotation schedules confirmed active (30-day interval for all secrets)
- [ ] API Gateway execution logging enabled at INFO level for all methods
- [ ] CloudFront distribution enforces HTTPS-only with minimum TLS 1.2 security policy

---

# Integration Testing

This section documents the integration testing approach, end-to-end test scenarios, data migration testing, and rollback plans for all integration points of the platform.

## Integration Test Scope

Integration testing validates complete data paths across all platform components. The following table documents each test scenario, the components exercised, and the expected pass criterion:

| Test Scenario | Components Under Test | Success Criteria |
|---------------|----------------------|------------------|
| Brief submission to job queued | API Gateway → Cognito Auth → Brief Submission Lambda → SQS FIFO → DynamoDB | HTTP 202 returned; job ID created; SQS message enqueued within 5 seconds |
| Job orchestration to Bedrock invocation | SQS → Step Functions → Bedrock Orchestration Lambda → Amazon Bedrock | Step Functions execution started; Bedrock InvokeModel called without error |
| Bedrock output validation and storage | Output Validation Lambda → S3 artifact write → DynamoDB status update | Valid artifact stored at correct S3 key; status transitions to COMPLETE |
| Artifact retrieval via pre-signed URL | Artifact Retrieval Lambda → S3 pre-signed URL generation | Pre-signed URL returned; artifact downloadable within 1-hour expiry |
| Usage limit enforcement | Brief Submission Lambda → DynamoDB usage check → limit rejection | HTTP 429 returned when user exceeds configured monthly limit |
| Cognito scope enforcement | API Gateway Cognito Authoriser → JWT validation → scope check | Delivery consultant receives HTTP 403 on POST /briefs; admin can access /admin/* |
| DLQ handling for failed jobs | Bedrock permanent failure → Step Functions error state → SQS DLQ | Failed job appears in DLQ; CloudWatch alarm fires within 5 minutes |
| SES completion notification | Step Functions success terminal state → SES Notification Lambda | Completion email received within 5 minutes of job COMPLETE |

## End-to-End Integration Test Procedure

The following procedure submits a full 7-artifact brief and validates the complete platform pipeline from submission to artifact download:

```bash
API_URL="https://<api-id>.execute-api.us-west-2.amazonaws.com/v1"
PRESALES_TOKEN="<presales-consultant-cognito-jwt>"

# Submit a full 7-artifact test brief
RESPONSE=$(curl -s -X POST "$API_URL/api/v1/briefs" \
  -H "Authorization: Bearer $PRESALES_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "client_name": "Integration Test Corp",
    "industry": "Financial Services",
    "requirements": "Migrate legacy data warehouse to AWS Redshift with real-time ingestion",
    "compliance_requirements": ["SOC 2 Type II"],
    "artifact_types": [
      "discovery-questionnaire", "solution-briefing", "statement-of-work",
      "infrastructure-costs", "level-of-effort-estimate",
      "detailed-design", "terraform-automation"
    ]
  }')

SOLUTION_ID=$(echo "$RESPONSE" | \
  python3 -c "import json,sys; print(json.load(sys.stdin)['solution_id'])")
echo "Submitted job: $SOLUTION_ID"

# Poll for completion (max 90 minutes, polling every 2 minutes)
START=$(date +%s)
STATUS="QUEUED"
while [ "$STATUS" != "COMPLETE" ] && [ "$STATUS" != "FAILED" ]; do
  ELAPSED=$(( ($(date +%s) - START) / 60 ))
  if [ $ELAPSED -gt 90 ]; then echo "ERROR: Job timed out"; break; fi
  STATUS=$(curl -s "$API_URL/api/v1/briefs/$SOLUTION_ID/status" \
    -H "Authorization: Bearer $PRESALES_TOKEN" | \
    python3 -c "import json,sys; print(json.load(sys.stdin)['status'])")
  echo "Elapsed: ${ELAPSED}min — Status: $STATUS"
  sleep 120
done

# Retrieve all 7 artifact pre-signed URLs on completion
if [ "$STATUS" = "COMPLETE" ]; then
  curl -s "$API_URL/api/v1/briefs/$SOLUTION_ID/artifacts" \
    -H "Authorization: Bearer $PRESALES_TOKEN" | python3 -m json.tool
fi
```

## Okta-to-Cognito Migration Validation Test

Before the Production cutover, validate the migration by running a pilot cohort through Cognito authentication in Staging:

```python
# scripts/identity/validate_cognito_login.py
# Usage: python3 validate_cognito_login.py --user-pool-id <id> --test-users-file <csv> --min-success-rate 0.95

import boto3, csv, sys

def validate_cognito_logins(pool_id, test_users_file, min_rate):
    client = boto3.client('cognito-idp', region_name='us-west-2')
    results = {"passed": 0, "failed": 0, "errors": []}

    with open(test_users_file) as f:
        for row in csv.DictReader(f):
            try:
                client.admin_get_user(UserPoolId=pool_id, Username=row['email'])
                results["passed"] += 1
            except client.exceptions.UserNotFoundException:
                results["failed"] += 1
                results["errors"].append(row['email'])

    total = results["passed"] + results["failed"]
    rate = results["passed"] / total if total > 0 else 0
    print(f"Total: {total} | Passed: {results['passed']} | Rate: {rate:.1%}")
    if rate >= min_rate:
        print(f"PASS — threshold {min_rate:.0%} met")
    else:
        print(f"FAIL — {rate:.1%} below threshold {min_rate:.0%}")
        sys.exit(1)
```

## Data Migration Procedures

The data migration scope is limited to Okta user migration and artifact template ingestion. No historical data from the legacy EC2 monolith is imported into the new platform — it is archived to S3 Glacier.

### Okta User Migration (Production)

The following procedure migrates all ~120 Okta users to the Production Cognito User Pool during the Phase 1 maintenance window:

```bash
export COGNITO_USER_POOL_ID="us-west-2_ProductionPoolId"
export AWS_REGION="us-west-2"

python scripts/identity/migrate_okta_to_cognito.py \
  --mapping-file reports/cognito-migration-mapping.csv \
  --execute \
  --environment prod \
  --output reports/prod-migration-result-$(date +%Y%m%d).json

python scripts/identity/validate_migration.py \
  --result-file reports/prod-migration-result-$(date +%Y%m%d).json \
  --min-success-rate 0.95
```

### Artifact Template Ingestion

Upload all Word/Excel/PowerPoint artifact templates to the Production S3 bucket during Phase 3 provisioning:

```bash
ARTIFACTS_BUCKET="amatra-artifacts-prod"

for artifact_type in discovery-questionnaire solution-briefing statement-of-work \
                     infrastructure-costs level-of-effort-estimate \
                     detailed-design terraform-automation; do
  for ext in docx xlsx pptx; do
    TEMPLATE_FILE="templates/$artifact_type/template.$ext"
    if [ -f "$TEMPLATE_FILE" ]; then
      aws s3 cp "$TEMPLATE_FILE" \
        "s3://$ARTIFACTS_BUCKET/templates/$artifact_type/template.$ext" \
        --sse aws:kms \
        --metadata "artifact-type=$artifact_type,version=1.0,classification=Internal"
      echo "Uploaded: $artifact_type/$ext"
    fi
  done
done

# Verify all templates are present
aws s3 ls "s3://$ARTIFACTS_BUCKET/templates/" --recursive
```

## Integration Testing Rollback Plan

The following rollback actions are triggered if integration testing reveals critical defects:

| Trigger Condition | Rollback Action | Owner |
|-------------------|-----------------|-------|
| > 5% of API requests returning 5xx errors | Switch Lambda aliases to previous version (< 5 minutes) | Cloud Engineer |
| Bedrock output validation failure rate > 20% | Pause SQS queue processing; re-tune prompt templates; re-run | ML/AI Engineer |
| DynamoDB usage counters showing incorrect values | Restore DynamoDB table from PITR to last known good state | Cloud Engineer |
| Cognito migration failure rate > 5% | Re-enable Okta OIDC federation in Cognito; investigate errors | Security Engineer |
| CloudTrail logging gap detected | Re-enable CloudTrail trail immediately; notify Security Lead | Security Engineer |

---

# Security Validation

This section documents the security validation procedures, compliance checks, quality gates, and acceptance criteria required before the platform is approved for production deployment.

## Security Test Programme

The following security tests are executed during Phase 4 (Weeks 21–26) by the Security Engineer, with all results reviewed and signed off by the Security & Compliance Lead before Milestone M4.

### OWASP API Security Top 10 Validation

The platform API Gateway endpoint is tested against the OWASP API Security Top 10 using the OWASP ZAP automated scanner:

```bash
# Run OWASP ZAP API scan against Staging API Gateway endpoint
docker run -v $(pwd)/reports:/zap/wrk/:rw \
  --network host \
  owasp/zap2docker-stable zap-api-scan.py \
  -t "https://<staging-api-id>.execute-api.us-west-2.amazonaws.com/v1/api/v1/health" \
  -f openapi \
  -r reports/owasp-zap-scan-$(date +%Y%m%d).html

echo "Review reports/owasp-zap-scan-$(date +%Y%m%d).html"
echo "Pass criteria: zero HIGH or CRITICAL findings"
```

### WAF Rule Effectiveness Test

The AWS WAF v2 rule set is tested by simulating SQL injection, XSS, and rate-limit breach attempts:

```bash
# Test SQL injection protection (expect HTTP 403)
curl -s -X POST "$API_URL/api/v1/briefs" \
  -H "Content-Type: application/json" \
  -d '{"client_name": "Test; DROP TABLE solutions; --"}' \
  -w "\nHTTP Status: %{http_code}\n"
# Expected: HTTP 403

# Test XSS protection (expect HTTP 403)
curl -s "$API_URL/api/v1/briefs?search=<script>alert(1)</script>" \
  -w "\nHTTP Status: %{http_code}\n"
# Expected: HTTP 403
```

### Encryption Verification

Verify SSE-KMS encryption is active on all data stores:

```bash
# Verify S3 bucket default encryption
aws s3api get-bucket-encryption \
  --bucket amatra-artifacts-prod \
  --query "ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault"
# Expected: {"KMSMasterKeyID": "arn:aws:kms:...", "SSEAlgorithm": "aws:kms"}

# Verify DynamoDB table encryption
for table in amatra-solution-state-prod amatra-usage-tracking-prod; do
  aws dynamodb describe-table \
    --table-name "$table" \
    --query "Table.SSEDescription.{Status:Status,KMSKey:KMSMasterKeyArn}" \
    --region us-west-2
done
# Expected: Status = ENABLED for both tables
```

## Quality Gates

The following quality gates must be formally signed off at each milestone before the engagement proceeds to the next phase.

### Phase 1 Quality Gate (Week 4 — Milestone M1)

- [ ] Current-state assessment report delivered and accepted by CTO
- [ ] Okta identity inventory complete with all ~120 users documented
- [ ] Bedrock feasibility confirmed: Claude 3 Sonnet can produce qualifying artifacts
- [ ] All critical prerequisites met or a remediation plan documented
- [ ] CTO signs Phase 2 go/no-go approval

### Phase 2 Quality Gate (Week 8 — Milestone M2)

- [ ] Detailed Architecture Design Document approved by CTO
- [ ] SOC 2 controls design approved by Security & Compliance Lead
- [ ] Terraform module structure reviewed and approved by VP Engineering
- [ ] No unresolved high-risk items in the risk register
- [ ] CTO and Security Lead co-sign Architecture Approval

### Phase 3 Quality Gate (Week 20 — Milestone M3)

- [ ] All 9 Lambda functions deployed and responding to health checks in Dev
- [ ] Step Functions workflow completes end-to-end test generation in under 90 minutes
- [ ] Okta-to-Cognito migration pilot achieves ≥95% login success rate in Dev
- [ ] CI/CD pipeline deploys successfully to Dev environment on PR merge
- [ ] CloudWatch dashboard displays all 7 KPIs with live data
- [ ] Configuration Documentation accepted by VP Engineering

### Phase 4 Quality Gate (Week 26 — Milestone M4)

- [ ] All 7 artifact types pass functional testing with ≥90% first-review QA pass rate
- [ ] 10 concurrent job load test: all jobs complete in ≤90 minutes, zero DLQ messages
- [ ] OWASP API Security scan: zero HIGH or CRITICAL findings
- [ ] SOC 2 evidence package assembled: CloudTrail exports, Config compliance history, KMS rotation logs, IAM Access Analyzer findings
- [ ] UAT sign-off from Head of Solutions (≥90% pass rate across all submitted briefs)
- [ ] DR test: DynamoDB PITR restoration completes within 1 hour
- [ ] CTO and Security Lead provide formal written go-live approval

## Quality Metrics

The following quantitative metrics govern platform acceptance across all testing phases:

| Metric | Target | Measurement Method | Phase Gate |
|--------|--------|--------------------|------------|
| Artifact First-Review QA Pass Rate | ≥ 90% | QA rubric scoring across all 7 artifact types | M4 |
| API P95 Response Time (job submission) | < 2 seconds | API Gateway CloudWatch P95 latency | M4 |
| Concurrent Job Throughput (10 jobs) | All complete ≤ 90 minutes | Step Functions execution duration under load | M4 |
| Okta-to-Cognito Login Success Rate | ≥ 95% | Cognito login success rate in pilot | M4 / M5 |
| OWASP Security Findings | Zero HIGH or CRITICAL | OWASP ZAP scan report | M4 |
| Platform Availability (production) | ≥ 99.9% monthly | CloudWatch Synthetics canary success rate | Ongoing |
| DLQ Message Rate | 0 under normal operation | CloudWatch DLQ alarm: zero tolerance | Ongoing |
| Code Coverage | ≥ 80% | pytest coverage report | M3 |

---

# Migration & Cutover

## Migration Approach

The Amatra Intelligent Solution Builder uses a **phased migration** approach. The platform is a greenfield build; the migration scope is limited to migrating ~120 Okta users to Amazon Cognito and retiring two legacy systems — the EC2 monolith and the Google Workspace manual workflow — in sequenced phases that protect business continuity.

**Migration Type:** Phased (pre-sales user population first in Phase 1; delivery team second in Phase 2; legacy decommission after stability confirmation)

**Rationale:** The phased approach validates AI generation quality with the pre-sales team before onboarding delivery consultants, de-risks the identity cutover by maintaining Okta as a 30-day fallback, and ensures no disruption to the current manual workflow until the new platform is confirmed stable.

## Cutover Plan

### Phase 1 Cutover (Target: 30 September 2026)

This cutover transitions Amatra's pre-sales consultant user population from the manual Google Workspace workflow to the new platform. It is executed during a planned maintenance window communicated to all users ≥5 business days in advance.

**Cutover Window:** Saturday, 30 September 2026, 06:00–10:00 CT

**Pre-Cutover Checklist (must be complete before maintenance window opens):**

- [ ] All Phase 4 quality gates passed and Milestone M4 signed off
- [ ] Staging full-stack validation passed within 48 hours of cutover
- [ ] Production Cognito User Pool fully populated (~120 migrated users) and Staging pilot login validation passed
- [ ] Admin usage limits configured and validated: per-user limit = 50, global limit = 500
- [ ] CloudWatch alarms active and SNS routing validated (test alarm received by operations team)
- [ ] Rollback procedure tested in Staging (Lambda alias rollback completes in < 5 minutes)
- [ ] Okta OIDC federation fallback configured in Production Cognito (30-day fallback window)
- [ ] Head of Solutions has completed pre-cutover brief submission test in Staging
- [ ] Vendor team on-call roster confirmed for 48 hours post-cutover
- [ ] User communications email approved by VP Engineering and ready to send

**Cutover Steps:**

```bash
# Step 1: Execute Okta-to-Cognito SSO DNS cutover
# Coordinate with Amatra IT to update the Okta application redirect to:
# https://amatra-prod.auth.us-west-2.amazoncognito.com/oauth2/authorize
echo "ACTION: Update Okta SSO DNS redirect — coordinate with Amatra IT"

# Step 2: Monitor Cognito login success rate for 15 minutes post-DNS update
# Check CloudWatch Cognito metrics for authentication success/failure ratio

# Step 3: Run end-to-end smoke test in Production (Head of Solutions executes)
echo "ACTION: Head of Solutions to submit a test brief in Production and confirm artifact generation"

# Step 4: Activate admin usage limits in Production
API_URL="https://<prod-api-id>.execute-api.us-west-2.amazonaws.com/v1"
ADMIN_TOKEN="<prod-admin-cognito-jwt>"

curl -s -X PUT "$API_URL/api/v1/admin/usage/limits/global" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"limit": 500}'

# Step 5: Confirm all CloudWatch alarms are in OK state
aws cloudwatch describe-alarms \
  --alarm-name-prefix "amatra-" \
  --state-value OK \
  --query "MetricAlarms[].AlarmName" \
  --region us-west-2

# Step 6: Send go-live communications to all pre-sales users
echo "ACTION: VP Engineering to approve and distribute go-live email to all users"
echo "Phase 1 cutover complete — 48-hour active monitoring period begins"
```

### Phase 2 Cutover (Target: 15 December 2026)

Phase 2 activates the delivery artifact automation and Terraform generation modules and decommissions the legacy EC2 monolith.

**Pre-Cutover Checklist:**

- [ ] Delivery team enablement session (TRN-009) completed
- [ ] Phase 2 artifact types validated end-to-end in Staging
- [ ] Legacy EC2 monolith data export complete and archived to S3 Glacier

**Cutover Steps:**

```bash
# Step 1: Deploy Phase 2 modules via GitHub Actions pipeline (triggered by git tag)
git tag -a "v2.0.0-prod" -m "Phase 2 Production Deployment — 15 Dec 2026"
git push origin "v2.0.0-prod"

# Step 2: Smoke test all Phase 2 artifact types in Production
for artifact_type in "detailed-design" "terraform-automation"; do
  echo "Smoke testing $artifact_type generation in Production..."
done

# Step 3: Decommission legacy EC2 monolith (dry-run first)
python scripts/decommission/archive_ec2_monolith.py \
  --instance-id "<legacy-ec2-instance-id>" \
  --archive-bucket amatra-artifacts-prod \
  --archive-prefix legacy-ec2-archive/ \
  --dry-run

# Step 4: Execute decommission after dry-run validation
python scripts/decommission/archive_ec2_monolith.py \
  --instance-id "<legacy-ec2-instance-id>" \
  --archive-bucket amatra-artifacts-prod \
  --archive-prefix legacy-ec2-archive/ \
  --execute

aws ec2 terminate-instances \
  --instance-ids "<legacy-ec2-instance-id>" \
  --region us-west-2

# Step 5: Remove legacy EC2 DNS records and send go-live communications
echo "ACTION: Amatra IT to remove legacy EC2 DNS records"
echo "ACTION: VP Engineering to send Phase 2 go-live email to delivery team"
```

## Go/No-Go Criteria

The following go/no-go criteria must all be satisfied before any production deployment is authorised. Any single NO-GO item postpones the cutover.

| Criteria | GO Condition | Verification |
|----------|-------------|--------------|
| Phase 4 quality gates | All quality gates passed (M4 signed off) | Written CTO approval on file |
| Staging validation | Full-stack smoke test passed within 48h | QA Engineer sign-off |
| Login success rate | ≥ 95% Cognito login success in Staging pilot | Migration validation report |
| Open defects | Zero Severity 1 or 2 defects in Jira | QA Engineer confirmation |
| Security sign-off | Security & Compliance Lead written approval | Email approval on file |
| CloudWatch alarms | All alarms in OK state; SNS routing validated | Operations team confirmation |
| Rollback tested | Lambda alias rollback tested in Staging (< 5 min) | DevOps Engineer sign-off |
| User communications | Go-live email approved and ready to send | VP Engineering approval |

## Rollback Strategy

The rollback strategy is maintained for 30 days post-cutover. The rollback activation threshold is ≥5% of user job submissions failing OR any Severity 1 data integrity issue detected.

**Rollback Execution:**

```bash
# Step 1: Switch all Lambda production aliases to the previous version (< 5 minutes)
PREVIOUS_VERSION="<version-number>"
for function in brief-submission job-status artifact-retrieval admin-governance \
                bedrock-orchestration output-validation artifact-template ses-notification; do
  aws lambda update-alias \
    --function-name "amatra-$function-prod" \
    --name production \
    --function-version "$PREVIOUS_VERSION" \
    --region us-west-2
  echo "Rolled back amatra-$function-prod to version $PREVIOUS_VERSION"
done

# Step 2: Re-enable Okta OIDC federation in Cognito if authentication issues are detected
echo "ACTION: Navigate to Cognito User Pool → Sign-in experience → Federated identity providers"
echo "Re-enable the Okta OIDC provider to restore Okta authentication as fallback"

# Step 3: Notify all affected users of temporary rollback
echo "ACTION: VP Engineering to send rollback notification email to all users"
echo "Conduct RCA within 24 hours and schedule re-deployment attempt"
```

---

# Operational Handover

## Documentation Handover

The following documentation is formally delivered to Amatra at project close. All documents must be accepted by the designated approver before the engagement is formally closed.

| Document | Type | Due | Acceptance By |
|----------|------|-----|---------------|
| As-Built Architecture Documentation | Architecture | Week 35 | CTO |
| API Reference (OpenAPI 3.0) | Technical | Week 35 | VP Engineering |
| Data Dictionary (DynamoDB schemas, S3 structure) | Technical | Week 35 | VP Engineering |
| Architecture Decision Records (ADRs) | Architecture | Week 8 | VP Engineering |
| Terraform Module Repository (README + variable docs) | IaC | Week 8 | VP Engineering |
| CI/CD Configuration (GitHub Actions workflows) | DevOps | Week 20 | VP Engineering |
| Configuration Documentation (configuration.csv) | Technical | Week 20 | VP Engineering |
| Operational Runbooks (9 SOPs) | Operations | Week 34 | VP Engineering |
| SOC 2 Evidence Package (final) | Compliance | Week 35 | Security & Compliance Lead |
| GDPR Data Handling Procedures | Compliance | Week 35 | Security & Compliance Lead |
| Admin Training Materials | Training | Week 30 | Head of Solutions |
| Pre-Sales Consultant User Guide | Training | Week 30 | Head of Solutions |
| Delivery Team Enablement Guide | Training | Week 30 | Head of Solutions |
| Hypercare Report & Optimisation Roadmap | Operations | Week 36 | CTO |

### Documentation Handover Checklist

- [ ] As-built architecture document reflects the deployed production configuration
- [ ] API reference (OpenAPI 3.0 spec) matches all deployed endpoints
- [ ] Terraform module repository cloned to Amatra's GitHub organisation with README complete
- [ ] All 9 operational runbooks reviewed by VP Engineering during a 2-hour dry-run walkthrough
- [ ] SOC 2 evidence package reviewed and accepted by Security & Compliance Lead
- [ ] Admin training materials reviewed and accepted by Head of Solutions
- [ ] All training session recordings uploaded to Amatra's Confluence space

## Support Transition

### Support Model

The following support tier model is operative during the 8-week Hypercare period (30 Sep 2026 – 25 Nov 2026) and transitions to Amatra's steady-state operations team at hypercare close.

| Tier | Responsibility | Response Time | Coverage | Escalation |
|------|---------------|---------------|----------|------------|
| L1 — Amatra Operations | Initial triage, known issues, user access support | < 1 hour (business hours) | 08:00–18:00 CT, Mon–Fri | To L2 after 2 hours unresolved |
| L2 — Vendor Hypercare | Technical troubleshooting, Lambda/Step Functions issues, Bedrock prompt issues | < 4 hours | Business hours + on-call for Severity 1 | To L3 after 8 hours unresolved |
| L3 — Vendor Expert / AWS Support | Expert resolution, architecture changes, Bedrock service issues | < 1 business day | Business hours | AWS Business Support escalation |

### Hypercare Period Details

The 8-week hypercare support period runs from the Phase 1 Production Go-Live milestone (30 September 2026) through approximately 25 November 2026, as committed in the SOW.

- **Coverage Hours:** Business hours (08:00–18:00 CT, Monday–Friday) plus on-call for Severity 1 incidents
- **Severity 1 Response:** 1-hour response, 4-hour resolution target
- **Severity 2 Response:** 4-hour response, 8-hour resolution target
- **Severity 3 Response:** Next business day response

**Hypercare Scope Includes:** Platform health monitoring and proactive issue resolution; production incident investigation and fix deployment; Bedrock prompt tuning based on QA first-pass rate data from live usage; Cognito user onboarding support; admin training follow-up Q&A (up to 2 additional sessions); CloudWatch alarm threshold tuning based on real production traffic patterns.

**Excluded from Hypercare:** New feature development; changes to artifact types beyond the 7 in scope; post-hypercare ongoing managed operations (requires separate Managed Services Agreement).

## Operational Runbooks

The Operational Runbooks deliverable (Week 34) includes the following SOPs, each validated through dry-run during Phase 5:

| Runbook | SOP Number | Scenario |
|---------|-----------|----------|
| Bedrock Quota Management | SOP-OPS-001 | Responding to 80% Bedrock token quota alarm; requesting quota increase |
| Lambda Cold Start Mitigation | SOP-OPS-002 | Tuning provisioned concurrency when P95 API latency exceeds 5 seconds |
| DynamoDB PITR Restoration | SOP-OPS-003 | Restoring solution-state or usage-tracking table to a point-in-time |
| Incident Response | SOP-OPS-004 | End-to-end triage from alarm to RCA for Severity 1 and 2 incidents |
| DR Restoration | SOP-OPS-005 | Full platform reconstruction from Terraform IaC after catastrophic failure |
| Cognito User Management | SOP-OPS-006 | Adding/removing users, group assignments, 24-hour offboarding procedure |
| Usage Limit Configuration | SOP-OPS-007 | Setting per-user and global limits via admin API |
| DLQ Re-Drive | SOP-OPS-008 | Investigating and re-driving failed generation jobs from SQS DLQ |
| EC2 Monolith Archive Access | SOP-OPS-009 | Retrieving archived data from the S3 Glacier legacy EC2 archive |

## Handover Checklist

The following checklist confirms all handover activities are complete before the engagement is formally closed (Milestone M9, Week 36):

- [ ] All 30 formal deliverables accepted by the designated Amatra approver
- [ ] Training completed for all three user groups: Admin, Pre-Sales Consultant, Delivery Team
- [ ] All 9 operational runbooks reviewed and validated through dry-run walkthrough
- [ ] Operations team independently executed the DLQ re-drive procedure (SOP-OPS-008) during dry-run
- [ ] DR restoration runbook executed end-to-end in Staging (RTO ≤ 4 hours confirmed)
- [ ] Cognito user management training completed with Amatra admin team
- [ ] CloudWatch dashboards and alarms reviewed with VP Engineering and operations team
- [ ] Terraform repository access transferred to Amatra's GitHub organisation
- [ ] All vendor personnel removed from Amatra AWS account after hypercare period ends
- [ ] Emergency contact list (vendor team + AWS Business Support) documented and distributed
- [ ] Hypercare Report and Optimisation Roadmap accepted by CTO (Milestone M9)
- [ ] Project retrospective and lessons-learned session completed with CTO and VP Engineering

---

# Training Program

## Training Overview

### Objectives

The training programme ensures all three Amatra user groups — platform admins, pre-sales consultants, and delivery consultants — achieve full competency with the Amatra Intelligent Solution Builder before go-live and establishes a self-service learning path for new team members onboarded after General Availability.

### Training Approach

The programme is phased to align with production deployment milestones and delivers content through multiple formats to accommodate distributed, remote-first teams:

- **Phased Delivery:** Training delivered in sequence with Phase 5 deployment milestones (Weeks 29–32)
- **Role-Based:** Content tailored to each audience's specific responsibilities and platform scope
- **Hands-On Focus:** Every module includes practical exercises in a dedicated sandbox environment, with sample data reset weekly to a clean state
- **Recorded:** All VILT and ILT sessions are recorded and uploaded to Amatra's Confluence space within 5 business days for asynchronous review by new hires

### Training Schedule

The following table summarises all 10 training modules, their target audiences, formats, and delivery weeks:

| Module ID | Module Name | Target Audience | Duration | Format | Prerequisites | Delivery Week |
|-----------|-------------|-----------------|----------|--------|---------------|---------------|
| TRN-001 | Platform Architecture Overview | All Users | 1.5 hours | ILT | None | Week 29 |
| TRN-002 | Admin Console & Cognito User Management | Administrators | 4 hours | Hands-On Lab | TRN-001 | Week 30 |
| TRN-003 | Usage Limit Configuration & Governance | Administrators | 2 hours | VILT | TRN-002 | Week 30 |
| TRN-004 | CloudWatch Dashboards & Alarm Response | Administrators | 2 hours | Hands-On Lab | TRN-002 | Week 30 |
| TRN-005 | Incident Response & Operational Runbooks | Administrators | 3 hours | Hands-On Lab | TRN-002, TRN-004 | Week 30 |
| TRN-006 | Brief Submission & Pre-Sales Workflow | Pre-Sales Consultants | 1.5 hours | VILT | TRN-001 | Week 30 |
| TRN-007 | Artifact Review & QA Checklist | Pre-Sales Consultants | 2 hours | VILT | TRN-006 | Week 30 |
| TRN-008 | Regeneration Workflow & Escalation Process | Pre-Sales Consultants | 1 hour | VILT | TRN-007 | Week 31 |
| TRN-009 | Delivery Artifacts & Terraform Automation | Delivery Consultants | 2 hours | ILT | TRN-001 | Week 32 |
| TRN-010 | Train-the-Trainer Workshop | Internal Trainers | 4 hours | Workshop | All modules | Week 32 |

---

## Administrator Training

Administrator training (TRN-001 through TRN-005) targets the designated Amatra platform admins responsible for day-to-day user management, usage governance, and operational monitoring. All admin users must complete TRN-002 through TRN-005 and pass all knowledge checks before go-live.

### TRN-001: Platform Architecture Overview (1.5 hours, ILT — All Users)

This foundational module is delivered to all three user groups before role-specific training begins.

**Learning Objectives:**
- Describe the five logical layers of the platform and how data flows between them
- Explain why generation jobs are asynchronous (30–60 minute Bedrock jobs exceed Lambda's 15-minute limit)
- Identify the 7 artifact types and the expected generation timeline
- Explain the Cognito authentication model and the three user roles
- Navigate to the CloudWatch production dashboard and identify the 7 platform health indicators

**Content Outline:**
1. Business context and platform overview (20 min) — what problem the platform solves; the 3-week-to-2-day improvement
2. Architecture diagram walkthrough (30 min) — all 5 logical layers; the async SQS → Step Functions → Bedrock pipeline
3. Authentication and role model (20 min) — Cognito migration from Okta; group membership; MFA for admins
4. Q&A and wrap-up (20 min)

**Materials Required:**
- Architecture diagram (Figure 1 from Detailed Design Document)
- Platform login URL and sandbox credentials (pre-provisioned)
- Quick reference card: 7 artifact types, generation timeline, support contacts

---

### TRN-002: Admin Console & Cognito User Management (4 hours, Hands-On Lab)

**Learning Objectives:**
- Add, modify, and remove users from the Cognito User Pool using both AWS Console and Admin API
- Assign users to the correct Cognito group and verify group-to-permission mapping
- Reset user passwords and manage MFA device registration for admin-group users
- Execute the 24-hour offboarding access revocation procedure (SOP-OPS-006)

**Content Outline:**
1. Cognito User Pool structure and group-permission mapping (30 min)
2. User management via AWS Console: create, modify, disable (45 min)
3. User management via Admin API: usage stats, limit overrides, audit queries (45 min)
4. MFA management for admin-group users (30 min)
5. Offboarding procedure dry-run (30 min)

**Lab Exercises:**
- Exercise 1: Onboard a new pre-sales consultant; assign group; send temporary password
- Exercise 2: Promote a consultant to `admins` group; verify MFA requirement is enforced
- Exercise 3: Execute the offboarding procedure for a test user; confirm access is revoked within 24 hours
- Exercise 4: Query the audit API and identify the last 5 admin actions

**Materials Required:** Sandbox Cognito User Pool with sample users; Admin API Postman collection; offboarding SOP checklist (SOP-OPS-006); exercise workbook

---

### TRN-003: Usage Limit Configuration & Governance (2 hours, VILT)

**Learning Objectives:**
- Configure per-user limits and global limits via the admin API
- Interpret the monthly usage dashboard and identify users approaching their limits
- Apply the monthly Bedrock quota review process required by SOC 2 governance controls

**Content Outline:**
1. Usage limit concepts and cost-control rationale (30 min)
2. Live demo: setting per-user limit overrides and global monthly limit (45 min)
3. Monthly quota review process and Bedrock quota increase procedure (SOP-OPS-001) (30 min)
4. Q&A (15 min)

**Materials Required:** Video conferencing with screen share; Admin API Postman collection; CloudWatch Bedrock quota alarm console access

---

### TRN-004: CloudWatch Dashboards & Alarm Response (2 hours, Hands-On Lab)

**Learning Objectives:**
- Navigate both CloudWatch dashboards and interpret all 7 KPI widgets
- Explain all 10 CloudWatch alarms, their severity levels, and initial response actions
- Describe the SNS and PagerDuty notification flow for Severity 1 alarms

**Content Outline:**
1. Platform health dashboard walkthrough: all 7 KPI widgets, normal vs. anomalous patterns (45 min)
2. Alarm deep-dive: all 10 alarms with conditions, severity, and initial response (45 min)
3. SNS / PagerDuty notification flow overview (15 min)
4. Hands-on: identify current platform health state; navigate X-Ray trace for the slowest invocation (15 min)

**Lab Exercises:**
- Exercise 1: Trigger a test alarm and confirm SNS notification received within 2 minutes
- Exercise 2: Identify the Step Functions failure rate threshold and explain the SOP response
- Exercise 3: Navigate X-Ray to find the slowest Lambda invocation in the last 24 hours

**Materials Required:** AWS Console access to CloudWatch sandbox dashboard; X-Ray service map

---

### TRN-005: Incident Response & Operational Runbooks (3 hours, Hands-On Lab)

**Learning Objectives:**
- Execute the incident response SOP from alarm detection through to RCA documentation (SOP-OPS-004)
- Independently execute the DLQ re-drive procedure for failed generation jobs (SOP-OPS-008)
- Execute a Lambda alias rollback in the sandbox environment
- Navigate the DR restoration runbook (SOP-OPS-005) and identify steps required to meet the 4-hour RTO

**Content Outline:**
1. Incident classification, severity definitions, and response SLAs (30 min)
2. DLQ investigation and re-drive procedure walkthrough (45 min)
3. Lambda alias rollback procedure and confirmation (30 min)
4. DR restoration overview — DynamoDB PITR and Lambda redeployment (45 min)
5. Q&A (30 min)

**Lab Exercises:**
- Exercise 1: Send a malformed brief to trigger a DLQ message; investigate and re-drive via SOP-OPS-008
- Exercise 2: Execute a Lambda alias rollback on the Brief Submission function in the sandbox
- Exercise 3: Initiate a DynamoDB PITR restoration to a point 1 hour in the past (sandbox)

---

## End User Training

End user training (TRN-006 through TRN-008) targets the ~80 pre-sales consultants who are the primary users of the platform. All pre-sales consultants must complete TRN-006 and TRN-007 before go-live.

### TRN-006: Brief Submission & Pre-Sales Workflow (1.5 hours, VILT)

**Learning Objectives:**
- Log in to the platform using the Cognito Hosted UI with existing Amatra credentials
- Submit a client brief with all required fields to produce a complete 7-artifact package
- Monitor job status through the 30–90 minute generation window
- Download generated artifacts (Markdown source and Office documents) from the platform

**Content Outline:**
1. Logging in and navigating the platform (15 min) — new Cognito login URL; credential setup after Okta migration
2. Submitting your first brief (40 min) — required fields; best practices for brief quality; live demo submission
3. Monitoring and downloading (25 min) — job status meanings (QUEUED/PROCESSING/COMPLETE/FAILED); SES completion email; downloading artifacts; escalation if a job fails
4. Support resources (10 min) — help documentation location in Confluence; escalation path

**Materials Required:** Video conferencing with screen share; sandbox platform access; quick reference card (login URL, job status meanings, support contacts); sample client brief template

---

### TRN-007: Artifact Review & QA Checklist (2 hours, VILT)

**Learning Objectives:**
- Apply the internal QA rubric to evaluate a generated artifact across completeness, accuracy, formatting, and usability dimensions
- Identify common artifact quality issues and their likely root causes
- Use the QA checklist to systematically review a generated SOW or Solution Briefing before sharing with a client
- Provide structured feedback for artifact regeneration

**Content Outline:**
1. The internal QA rubric — four dimensions and the ≥90% first-review pass target (30 min)
2. Live review of a sample Solution Briefing against the QA rubric (30 min)
3. Live review of a sample SOW — key sections to validate (scope, timeline, investment) (30 min)
4. Structured feedback for regeneration — when to regenerate vs. manually edit (20 min)
5. Q&A (10 min)

**Materials Required:** Sample generated artifacts from Staging; internal QA rubric document; QA scoring worksheet

---

### TRN-008: Regeneration Workflow & Escalation Process (1 hour, VILT)

**Learning Objectives:**
- Trigger an artifact regeneration with an updated brief using the platform
- Describe the escalation path when two consecutive regenerations do not achieve the quality standard
- Understand how consultant feedback feeds the Bedrock prompt tuning improvement loop

**Content Outline:**
1. When to regenerate vs. manually edit (15 min)
2. Executing regeneration — updating the brief; submitting via the same API; comparing outputs (25 min)
3. Escalation after 2 failed regenerations — escalation ticket template; Vendor Hypercare scope (15 min)
4. Q&A (5 min)

**Materials Required:** Sample low-quality artifact for regeneration practice (pre-prepared in sandbox); regeneration request template; escalation ticket template

---

## Power User Training

### TRN-009: Delivery Artifacts & Terraform Automation (2 hours, ILT)

This module is delivered in Week 32 and targets the Delivery Consulting team who consume Phase 2 artifact outputs.

**Learning Objectives:**
- Describe the Phase 2 delivery artifact types (detailed design, implementation guide, Terraform automation) and their purpose in the delivery workflow
- Review and validate a generated Detailed Design Document against architecture standards
- Download and inspect a generated Terraform automation package; explain its module structure
- Integrate generated delivery artifacts into the existing Amatra delivery workflow

**Content Outline:**
1. Phase 2 artifact types overview — what each contains and how to validate it (30 min)
2. Reviewing a generated Detailed Design — validation checklist; common quality issues (45 min)
3. Working with Terraform automation output — running `terraform plan`; customisation guidance (30 min)
4. Integration with the delivery workflow — version control; S3 versioning; Git (15 min)

**Materials Required:** Sample generated Detailed Design and Terraform package from a representative brief; Terraform v1.8+ installed on attendee laptops

---

## Train-the-Trainer

### TRN-010: Train-the-Trainer Workshop (4 hours, Workshop)

This module equips Amatra's designated internal trainers to deliver all modules to new hires and future user cohorts independently after General Availability.

**Learning Objectives:**
- Deliver all 9 role-specific training modules effectively to new cohorts
- Manage the sandbox environment including resetting to clean state and provisioning new user credentials
- Answer the 20 most common questions from the initial training sessions
- Administer knowledge check quizzes and conduct practical competency assessments

**Content Outline:**
1. Training delivery methodology and facilitation techniques (45 min)
2. Sandbox environment management — resetting, provisioning credentials, troubleshooting (30 min)
3. Facilitation practice — each trainer delivers a 10-minute segment with peer feedback (90 min)
4. Q&A bank review and assessment administration walkthrough (45 min)

**Materials Required:** Trainer's guide for all 10 modules; sandbox reset SOP; knowledge check quiz questions and answer key; practical assessment rubric

## Training Materials

### Documentation Provided

All training materials are included in Deliverable 26 (Admin & Consultant Training Materials, Week 30):

- Admin Training Deck: Slides and lab exercises for TRN-002 through TRN-005 (PDF + PPTX)
- Pre-Sales Consultant User Guide: Step-by-step brief submission and QA guide (PDF, ~30 pages)
- Delivery Team Enablement Guide: Phase 2 artifact types and Terraform automation guide (PDF, ~25 pages)
- Quick Reference Cards: Role-specific single-page summary (Pre-Sales, Admin, Delivery Consultant)
- Video Recordings: All VILT and ILT sessions recorded and uploaded to Confluence within 5 business days
- Lab Exercise Workbooks: Printed and digital versions for all hands-on modules
- Knowledge Check Quizzes: One per module, administered via Confluence survey

### Training Environment

A dedicated sandbox environment (separate from Dev, Staging, and Production) is provisioned for training and reset every Monday at 06:00 CT via an automated Lambda function. Sandbox access is provisioned for all participants 2 weeks before scheduled training. Bedrock integration is replaced with pre-recorded responses in the sandbox to ensure deterministic lab exercises. The sandbox is decommissioned 90 days post-GA.

## Training Effectiveness

### Assessment Approach

- **Knowledge Checks:** 5–10 question quiz at the end of each module; 70% pass score required for completion credit
- **Practical Assessment:** Successfully complete all assigned lab exercises as observed by the facilitator
- **Admin Certification:** Admin users must independently execute the offboarding procedure (TRN-002 Exercise 3) and the DLQ re-drive procedure (TRN-005 Exercise 1) unassisted

### Success Metrics

The following metrics govern training programme effectiveness and are reported in the Hypercare Report (Deliverable 30):

| Metric | Target |
|--------|--------|
| Training Completion Rate | > 95% of assigned users complete required modules before go-live |
| Knowledge Check First-Attempt Pass Rate | > 85% across all modules |
| Post-Training Satisfaction Score | > 4.0 / 5.0 (Confluence survey) |
| Time to Independent Competency | ≤ 2 weeks post-training for end users |
| Admin Certification Rate | 100% of designated admins certified before go-live |

---

# Appendices

## Appendix A: Environment Configuration Reference

This appendix documents the key environment-specific configuration values for all three deployment environments. Sensitive values (KMS key ARNs, Cognito pool IDs, WAF ACL ARNs) are retrieved from Terraform outputs post-provisioning and stored in Secrets Manager — the values shown below are reference templates.

### Development Environment

| Parameter | Value |
|-----------|-------|
| Environment Name | `dev` |
| AWS Region | `us-west-2` |
| VPC CIDR | `10.10.0.0/16` |
| Artifacts S3 Bucket | `amatra-artifacts-dev` |
| Solution State DynamoDB Table | `amatra-solution-state-dev` |
| Usage Tracking DynamoDB Table | `amatra-usage-tracking-dev` |
| Step Functions Workflow | `amatra-generation-workflow-dev` |
| SQS FIFO Queue | `amatra-generation-queue-dev.fifo` |
| Cognito User Pool Domain | `amatra-dev.auth.us-west-2.amazoncognito.com` |
| CloudWatch Dashboard | `amatra-platform-dev` |
| NAT Gateway Count | 1 (cost optimised) |
| Log Retention | 30 days |
| DynamoDB PITR | Disabled |
| X-Ray Sampling Rate | 100% |
| Bedrock Token Quota | 10M tokens/month |

### Staging Environment

| Parameter | Value |
|-----------|-------|
| Environment Name | `staging` |
| AWS Region | `us-west-2` |
| VPC CIDR | `10.10.0.0/16` |
| Artifacts S3 Bucket | `amatra-artifacts-staging` |
| Solution State DynamoDB Table | `amatra-solution-state-staging` |
| Step Functions Workflow | `amatra-generation-workflow-staging` |
| Cognito User Pool Domain | `amatra-staging.auth.us-west-2.amazoncognito.com` |
| CloudWatch Dashboard | `amatra-platform-staging` |
| NAT Gateway Count | 3 (mirrors Production) |
| Log Retention | 90 days |
| DynamoDB PITR | Enabled |
| X-Ray Sampling Rate | 100% |
| Data Policy | Anonymised copies of real briefs only |

### Production Environment

| Parameter | Value |
|-----------|-------|
| Environment Name | `prod` |
| AWS Region | `us-west-2` |
| VPC CIDR | `10.10.0.0/16` |
| Artifacts S3 Bucket | `amatra-artifacts-prod` |
| DR Replication Bucket | `amatra-artifacts-dr-use1` (us-east-1) |
| Solution State DynamoDB Table | `amatra-solution-state-prod` |
| Usage Tracking DynamoDB Table | `amatra-usage-tracking-prod` |
| Audit Records DynamoDB Table | `amatra-audit-records-prod` |
| Step Functions Workflow | `amatra-generation-workflow-prod` |
| SQS FIFO Queue | `amatra-generation-queue-prod.fifo` |
| Cognito User Pool Domain | `amatra-prod.auth.us-west-2.amazoncognito.com` |
| CloudWatch Dashboard | `amatra-platform-prod` |
| NAT Gateway Count | 3 (one per AZ) |
| Log Retention | 365 days |
| CloudTrail Retention | 7 years (S3 Object Lock) |
| DynamoDB PITR | Enabled |
| X-Ray Sampling Rate | 5% |
| Bedrock Token Quota | 90M tokens/month |
| Default Per-User Monthly Limit | 50 engagements |
| Default Global Monthly Limit | 500 engagements |

## Appendix B: Terraform Variable Reference

The following table provides a quick reference for the most commonly adjusted Terraform variables. Full variable documentation is in `infrastructure/modules/{module}/variables.tf`.

| Variable | Module | Default (Prod) | Description |
|----------|--------|----------------|-------------|
| `environment` | All | `prod` | Deployment environment identifier |
| `aws_region` | All | `us-west-2` | AWS region for all resources |
| `bedrock_model_id` | compute | `anthropic.claude-3-sonnet-20240229-v1:0` | Bedrock model for artifact generation |
| `bedrock_monthly_token_quota` | monitoring | `90000000` | Monthly token quota for Bedrock quota alarm |
| `lambda_architecture` | compute | `arm64` | Lambda CPU architecture (arm64 = 20% cost saving) |
| `nat_gateway_count` | networking | `3` | NAT Gateways per environment (1 for Dev) |
| `log_retention_days` | monitoring | `365` | CloudWatch Log Group retention |
| `pitr_enabled` | storage | `true` | DynamoDB Point-in-Time Recovery |
| `s3_cross_region_replication` | storage | `true` | Enable S3 DR replication to us-east-1 |
| `default_user_monthly_limit` | compute | `50` | Default per-user generation limit |
| `default_global_monthly_limit` | compute | `500` | Default global generation limit |
| `xray_sampling_rate` | monitoring | `0.05` | X-Ray trace sampling rate (5% in Production) |

## Appendix C: Deployment and Rollback Scripts

The following scripts provide the primary deployment and rollback automation. Both scripts are stored in `scripts/` in the project repository and are invoked by the GitHub Actions CI/CD pipeline on production deployments.

### deploy.sh

```bash
#!/bin/bash
# Full environment deployment script
# Usage: ./scripts/deploy.sh <environment> <image_tag>

set -euo pipefail

ENVIRONMENT=${1:-staging}
IMAGE_TAG=${2:-latest}
AWS_REGION="us-west-2"

echo "=== Amatra Intelligent Solution Builder Deployment ==="
echo "Environment: $ENVIRONMENT | Image Tag: $IMAGE_TAG"

# Pre-deployment checks
./scripts/pre-deploy-check.sh "$ENVIRONMENT"

# Build and push Lambda container images
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

aws ecr get-login-password --region "$AWS_REGION" | \
  docker login --username AWS --password-stdin "$ECR_REGISTRY"

for function in brief-submission job-status artifact-retrieval admin-governance \
                bedrock-orchestration output-validation artifact-template \
                ses-notification health-check; do
  docker build --platform linux/arm64 \
    -t "amatra/$function:$IMAGE_TAG" \
    "application/lambdas/$function/"
  docker tag "amatra/$function:$IMAGE_TAG" \
    "$ECR_REGISTRY/amatra/$function:$IMAGE_TAG"
  docker push "$ECR_REGISTRY/amatra/$function:$IMAGE_TAG"
done

# Deploy infrastructure via Terraform
cd "infrastructure/environments/$ENVIRONMENT"
terraform init -upgrade
terraform apply -var-file=terraform.tfvars \
  -var="image_tag=$IMAGE_TAG" -auto-approve

# Post-deployment validation
cd ../../..
./scripts/post-deploy-validate.sh "$ENVIRONMENT"

echo "=== Deployment complete: $ENVIRONMENT @ $IMAGE_TAG ==="
```

### rollback.sh

```bash
#!/bin/bash
# Lambda alias rollback script
# Usage: ./scripts/rollback.sh <environment> <version>

set -euo pipefail

ENVIRONMENT=${1:-prod}
ROLLBACK_VERSION=${2:?Error: must specify rollback version number}
AWS_REGION="us-west-2"

FUNCTIONS=(brief-submission job-status artifact-retrieval admin-governance
           bedrock-orchestration output-validation artifact-template ses-notification)

echo "=== Rolling back $ENVIRONMENT to Lambda version $ROLLBACK_VERSION ==="

for function in "${FUNCTIONS[@]}"; do
  FUNCTION_NAME="amatra-$function-$ENVIRONMENT"
  aws lambda update-alias \
    --function-name "$FUNCTION_NAME" \
    --name production \
    --function-version "$ROLLBACK_VERSION" \
    --region "$AWS_REGION"
  echo "Rolled back: $FUNCTION_NAME -> version $ROLLBACK_VERSION"
done

# Validate health endpoint after rollback
sleep 10
API_URL=$(terraform output -raw api_gateway_url 2>/dev/null || echo "")
if [ -n "$API_URL" ]; then
  curl -s -o /dev/null -w "Health check: HTTP %{http_code}\n" "$API_URL/api/v1/health"
fi

echo "=== Rollback complete ==="
```

## Appendix D: Troubleshooting Guide

This section provides resolution procedures for the most common issues encountered during deployment and production operations.

### Issue 1: Lambda Reports ThrottlingException from Bedrock

**Symptoms:** Step Functions workflow in `FAILED` state; `Bedrock-Quota-Warning` alarm firing; generation jobs returning `FAILED` status.

**Cause:** Amazon Bedrock throughput quota exhausted for the month or concurrent request limit reached.

**Resolution:**

```bash
# Check current Bedrock throttle count over the past hour
aws cloudwatch get-metric-statistics \
  --namespace AWS/Bedrock \
  --metric-name InvocationThrottles \
  --dimensions Name=ModelId,Value=anthropic.claude-3-sonnet-20240229-v1:0 \
  --start-time "$(date -u -d '1 hour ago' '+%Y-%m-%dT%H:%M:%SZ')" \
  --end-time "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
  --period 3600 \
  --statistics Sum \
  --region us-west-2

# Temporarily reduce global limit while awaiting quota increase
curl -s -X PUT "$API_URL/api/v1/admin/usage/limits/global" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"limit": 100, "reason": "Temporary reduction pending Bedrock quota increase"}'
```

**Prevention:** Follow SOP-OPS-001; set the `Bedrock-Quota-Warning` alarm at 80% (already configured). Request a quota increase to 200M tokens/month before Phase 3 per the risk register.

---

### Issue 2: Cognito Login Failures After DNS Cutover

**Symptoms:** Users receive `invalid_client` OAuth 2.0 errors; login success rate drops below 95%; users cannot authenticate post-cutover.

**Cause:** DNS propagation lag, incorrect App Client callback URL configuration, or users not completing the required password reset.

**Resolution:**

```bash
# Verify Cognito App Client callback URLs are correctly configured
aws cognito-idp describe-user-pool-client \
  --user-pool-id "$POOL_ID" \
  --client-id "$APP_CLIENT_ID" \
  --query 'UserPoolClient.{CallbackURLs:CallbackURLs,LogoutURLs:LogoutURLs}' \
  --region us-west-2

# Check Cognito authentication failure logs
aws logs filter-log-events \
  --log-group-name "/aws/cognito/userpools/$POOL_ID" \
  --filter-pattern "AuthenticationFailed" \
  --start-time "$(date -d '1 hour ago' +%s)000" \
  --region us-west-2
```

If failure rate exceeds 5%, re-enable the Okta OIDC federation provider in the Cognito User Pool console to restore Okta authentication while the issue is investigated.

**Prevention:** Conduct ≥95% login success rate validation in Staging at least 48 hours before Production cutover. Maintain Okta OIDC federation fallback in Cognito for 30 days post-cutover.

---

### Issue 3: Step Functions Workflow Stuck in RUNNING State

**Symptoms:** Job status remains `PROCESSING` for over 90 minutes; no completion email received; Step Functions execution history shows no recent transitions.

**Cause:** Bedrock Orchestration Lambda has timed out (900-second per-invocation limit), or a specific Step Functions state is blocked waiting for a downstream service.

**Resolution:**

```bash
# Inspect the Step Functions execution history for the stuck job
EXECUTION_ARN="arn:aws:states:us-west-2:<account>:execution:amatra-generation-workflow-prod:<solution-id>"

aws stepfunctions get-execution-history \
  --execution-arn "$EXECUTION_ARN" \
  --max-results 20 \
  --query "events[-5:].{Type:type,Timestamp:timestamp}" \
  --region us-west-2

# Stop the stuck execution and reset the DynamoDB record for re-submission
aws stepfunctions stop-execution \
  --execution-arn "$EXECUTION_ARN" \
  --cause "Manual stop: execution stuck >90 min; re-submitting" \
  --region us-west-2

aws dynamodb update-item \
  --table-name "amatra-solution-state-prod" \
  --key '{"solution_id": {"S": "<solution-id>"}}' \
  --update-expression "SET #s = :status" \
  --expression-attribute-names '{"#s": "status"}' \
  --expression-attribute-values '{":status": {"S": "QUEUED"}}' \
  --region us-west-2
```

**Prevention:** Ensure Bedrock Orchestration Lambda timeout is set to maximum (900 seconds) and Step Functions retry configuration (3 attempts, 30s interval, 2× backoff) is applied to all Bedrock invocation states.

---

### Issue 4: S3 Pre-Signed URL Returns Access Denied

**Symptoms:** Consultant clicks artifact download link and receives an `AccessDenied` XML error from S3; HTTP 403 response.

**Cause:** Pre-signed URL has expired (1-hour expiry) or the URL was generated under an IAM role that no longer has the required S3 GetObject permission.

**Resolution:** Instruct the consultant to call the Artifact Retrieval API endpoint again to generate a fresh pre-signed URL. The 1-hour expiry is intentional per the security design.

```bash
# Verify the Artifact Retrieval Lambda IAM role has s3:GetObject on the artifacts bucket
aws iam simulate-principal-policy \
  --policy-source-arn "arn:aws:iam::<account>:role/amatra-artifact-retrieval-prod-role" \
  --action-names "s3:GetObject" \
  --resource-arns "arn:aws:s3:::amatra-artifacts-prod/*" \
  --query "EvaluationResults[0].EvalDecision"
# Expected: "allowed"
```

**Prevention:** Communicate during TRN-006 that download links expire after 1 hour and users must call the artifacts API again for a fresh link.

## Appendix E: Contact Information

This appendix documents all project team contacts and escalation paths for the engagement. Contact details are sourced directly from the SOW and are valid throughout the engagement and hypercare period.

### Project Team

The following individuals are the designated project contacts for the Amatra Intelligent Solution Builder engagement:

| Role | Name | Email | Availability |
|------|------|-------|--------------|
| Lead Solutions Architect (Vendor) | Lead Solutions Architect | solutions@partner.com | Business hours + Severity 1 on-call |
| Project Manager (Vendor) | Vendor PM | pm@partner.com | Business hours (08:00–18:00 CT) |
| ML/AI Engineer (Vendor) | ML/AI Engineer | ml@partner.com | Business hours |
| Security Engineer (Vendor) | Security Engineer | security@partner.com | Business hours |
| CTO — Executive Sponsor (Amatra) | Amatra CTO | cto@amatra.com | Go/no-go decisions; Severity 1 escalation |
| VP of Engineering — Delivery Owner (Amatra) | VP Engineering | vp-eng@amatra.com | Business hours; milestone approvals |
| Head of Solutions — UAT Lead (Amatra) | Head of Solutions | solutions@amatra.com | Business hours; artifact QA reviews |
| Security & Compliance Lead (Amatra) | Security Lead | security@amatra.com | Business hours; SOC 2 approvals |
| Consulting Partner (Vendor) | Amatra Consulting Partner | solutions@partner.com | Engagement delivery |

### Escalation Contacts

The following escalation contacts are active during the engagement and the 8-week hypercare period:

| Level | Contact | Availability | Trigger |
|-------|---------|--------------|---------|
| Primary — Vendor Hypercare L2 | Vendor Team (solutions@partner.com) | Business hours + Severity 1 on-call | Any Severity 1 or 2 incident during hypercare |
| Secondary — AWS Business Support | AWS Support Portal (console.aws.amazon.com/support) | 24×7 | AWS service outages; Bedrock quota; Lambda service issues |
| Emergency — Amatra CTO | cto@amatra.com | 24×7 for Severity 1 data integrity events | Platform-down scenarios exceeding 2-hour resolution |

### Vendor Support

The following vendor support portals and SLAs are applicable throughout the engagement:

| Vendor | Support Portal | SLA |
|--------|----------------|-----|
| AWS (Cloud Infrastructure + Bedrock) | https://console.aws.amazon.com/support | AWS Business Support: 1-hour response for Critical severity |
| Datadog (APM Monitoring) | https://help.datadoghq.com | Datadog Pro: email support; 24-hour response |
| GitHub (CI/CD Pipeline) | https://support.github.com | GitHub Team: standard support |
| Anthropic / Amazon Bedrock | Via AWS Support | Covered under AWS Business Support plan |
