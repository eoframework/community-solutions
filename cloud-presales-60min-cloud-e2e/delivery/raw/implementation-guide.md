---
document_title: Implementation Guide
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

## Project Overview

This Implementation Guide provides step-by-step procedures for deploying the **Amatra Agentic Orchestration Platform** for PREDICTif Solutions. The platform is a fully serverless, event-driven multi-agent system on AWS that automates the end-to-end production of EO Framework pre-sales and delivery documentation — reducing per-engagement senior-consultant effort from six to ten hours to under one hour and unlocking parallel pipeline throughput across PREDICTif's 120-consultant sales organisation.

The platform is built on AWS Bedrock AgentCore Runtime using the Strands Agents framework, with Claude Sonnet 4.6 as the primary generation model and Claude Haiku 4.5 for cost-efficient validation. Five coordinated agents — Input Validator, Pre-Sales Generator, Delivery Generator, Code Generator, and EO Validator — produce twelve total artifacts per solution engagement following strict EO Framework quality standards.

## Implementation Scope

- **In Scope:**
  - AWS foundation infrastructure in us-west-2: Cognito User Pool, API Gateway HTTP API v2, eleven Lambda route handlers, DynamoDB tables, S3 buckets, IAM roles, Secrets Manager, CloudWatch, and ECR
  - All five Strands agents registered with Bedrock AgentCore Runtime
  - Docker image pipeline for eof-tools integration, ECR workflow, and AgentCore Runtime image registration
  - Pip-installable CLI with fourteen subcommands and JWT token management
  - DynamoDB atomic quota enforcement — per-user (10 solutions/month) and global (1,000 solutions/month)
  - GitHub PAT-based artifact commit pipeline to the fixed public repository
  - CloudWatch observability: per-phase token usage metrics, dashboards, and quota alarms
  - Security hardening: Secrets Manager, WAF rules, CloudTrail audit, DynamoDB KMS encryption
  - Code Generator agent with Terraform IaC for five core AWS services and `terraform validate` gate
  - Three-environment deployment strategy (dev, staging, prod) in us-west-2
  - Operational runbooks, as-built documentation, API reference, CLI command reference, and user onboarding guide
  - Knowledge transfer sessions for Pre-Sales Engineering (Marcus Patel) and Delivery Operations (Daniel Park)
  - Four weeks of post-go-live hypercare support

- **Out of Scope:**
  - Rewriting or refactoring the eof-tools converter library (~30 Python modules baked into container as-is)
  - Multi-region deployment or any footprint beyond us-west-2
  - Migration of existing OneDrive artifact storage to S3
  - Additional artifact types beyond the current twelve
  - Integration with third-party CRM or PSA platforms (e.g., Salesforce, ConnectWise)
  - Day-2 managed operations or SLA-backed incident response beyond the four-week hypercare period
  - SOC 2 Type II audit preparation, penetration testing, or formal compliance certification
  - Mobile application or browser-based UI

- **Dependencies:**
  - Dedicated us-west-2 AWS account with sufficient IAM permissions available by Week 1
  - CTO sign-off on Cognito user pool design by Week 3 (critical path)
  - EO Framework guidance files pre-loaded to S3 before Phase 2 agent development (Week 4)
  - GitHub PAT with `repo` scope available for Secrets Manager storage (Week 5)
  - Bedrock access for Claude Sonnet 4.6 and Claude Haiku 4.5 enabled in us-west-2 (Week 5)
  - Marcus Patel available as primary technical contact for a minimum of 10 hours per week

## Timeline Overview

- **Project Duration:** 12 weeks (plus 4-week hypercare, Weeks 13–16)
- **Hard Deadline:** Executive demonstration to Sarah Lin (CRO) by end of April 2026
- **Key Milestones:**
  - M1 — Kickoff Complete: Week 1
  - M2 — Architecture Approved (CTO sign-off): Week 3
  - M3 — Foundation Live (Cognito, API Gateway, DynamoDB): Week 4
  - M4 — All Agents Registered on AgentCore Runtime: Week 8
  - M5 — Platform Integration Complete (CLI, Lambda routes, GitHub pipeline): Week 9
  - M6 — Validation Green (all 12 artifact types, CloudWatch baseline): Week 11
  - M7 — Go-Live (production deployment, executive demonstration): Week 11
  - M8 — Handover Complete (documentation, knowledge transfer, formal acceptance): Week 12
  - M9 — Hypercare End: Week 16

---

# Prerequisites

## Technical Prerequisites

Complete all items in this section before starting Phase 1 development activities.

### Cloud Infrastructure

- [ ] Dedicated us-west-2 AWS account created and isolated from existing us-east-1 managed-services workloads
- [ ] Administrator IAM access provisioned for the vendor delivery team with permissions for: Cognito, API Gateway, Lambda, DynamoDB, S3, ECR, Secrets Manager, CloudWatch, WAF, CloudTrail, IAM, CodeBuild, KMS, ACM, and SSM Parameter Store
- [ ] AWS Activate or Solutions Partner infrastructure credit ($5,000) applied to the account
- [ ] Billing alerts configured at 80% of monthly infrastructure cost threshold
- [ ] Resource quotas (service limits) verified for us-west-2: Lambda concurrent executions ≥ 1,000; Bedrock token throughput for Claude Sonnet 4.6 and Claude Haiku 4.5 confirmed

### Bedrock Model Access

- [ ] Amazon Bedrock enabled in us-west-2 region
- [ ] Claude Sonnet 4.6 model access requested and approved (`anthropic.claude-sonnet-4-6`)
- [ ] Claude Haiku 4.5 model access requested and approved (`anthropic.claude-haiku-4-5`)
- [ ] Bedrock AgentCore Runtime service limits confirmed: ≥ 10 concurrent invocations per agent

### Network Connectivity

- [ ] API Gateway custom domain SSL certificate created in us-east-1 via ACM (required for API GW custom domain attachment regardless of deployment region): `api.amatra.predictif.com`
- [ ] DNS records for `api.amatra.predictif.com` and `api-dev.amatra.predictif.com` configured or pending configuration
- [ ] Outbound HTTPS access to GitHub API (`api.github.com`) confirmed from Lambda execution environment

### Security Baseline

- [ ] IAM permission boundary policies defined and approved by Client IT Lead
- [ ] KMS key aliases confirmed (`aws/dynamodb` for initial release)
- [ ] GitHub Personal Access Token (PAT) with `repo` scope generated and ready for storage in Secrets Manager
- [ ] CTO briefing package prepared (Cognito User Pool design summary for sign-off by Week 3)

### Development Tools

- [ ] Terraform CLI ≥ 1.5 installed on vendor engineering workstations
- [ ] AWS CLI v2 configured with appropriate profiles for dev, staging, and prod workspaces
- [ ] Docker Desktop ≥ 24.0 installed for multi-stage container builds
- [ ] Python 3.12 installed for Lambda development and CLI packaging
- [ ] Git repository (private vendor repo) configured for Terraform modules, Lambda code, and agent Dockerfiles
- [ ] `pytest` and `moto` Python packages available for unit testing
- [ ] `locust` Python package available for load testing

## Organizational Prerequisites

- [ ] Project kickoff meeting scheduled with Sarah Lin (CRO), Marcus Patel (Director of Pre-Sales Engineering), and Daniel Park (Head of Delivery Operations)
- [ ] CTO identified and briefed on Cognito User Pool sign-off requirement; review slot secured for Week 3
- [ ] Budget approved: $250,000 net professional services; $28,308 net Year 1 infrastructure; $6,000 AWS Business Support
- [ ] AWS Partner credits application initiated: $25,000 PS credits + $5,000 infrastructure credit
- [ ] Change management process activated; communication plan for 120-consultant rollout drafted
- [ ] Procurement representative engaged for AWS spend envelope confirmation
- [ ] Client IT Lead confirmed and available for IAM boundary review and us-west-2 account provisioning confirmation

## Environmental Setup

The platform deploys across three isolated environments within the us-west-2 AWS account. Each environment has its own Terraform workspace, S3 state bucket, Lambda function aliases, DynamoDB table prefix, and API Gateway stage.

### Development Environment

- [ ] Development Terraform workspace (`dev`) initialised with backend config pointing to `amatra-dev-s3-tfstate-{account-id}`
- [ ] Development resource prefix `amatra-dev` confirmed and applied
- [ ] Development API Gateway stage `dev` operational
- [ ] Vendor engineering team Cognito test users provisioned
- [ ] CI/CD pipeline (CodeBuild) connected to the vendor Git repository for automated ECR pushes

### Staging Environment

- [ ] Staging Terraform workspace (`staging`) initialised
- [ ] Staging mirrors production architecture for UAT fidelity
- [ ] Staging DynamoDB quota enforcement enabled (mirroring production settings)
- [ ] Marcus Patel and QA team Cognito accounts provisioned in staging user pool
- [ ] Representative presales brief corpus loaded in staging S3 guidance bucket

### Production Environment

- [ ] Production Terraform workspace (`prod`) initialised
- [ ] CTO sign-off on Cognito User Pool configuration obtained in writing prior to production Terraform apply
- [ ] Lambda Provisioned Concurrency configured: 2 instances for Solution Create Lambda, 2 instances for Solution Status Lambda
- [ ] AWS Business Support tier confirmed (24x7, < 1 hour critical response SLA)
- [ ] CloudWatch Synthetic Canary targeting `GET /v1/quota` configured at 5-minute intervals
- [ ] SNS topic `amatra-prod-ops-alerts` created and Daniel Park's email subscribed before go-live
- [ ] On-call rotation established for the 4-week hypercare period

---

# Environment Setup

This section covers environment provisioning and baseline configuration across all three environments before infrastructure deployment begins. Each phase has defined objectives, activities, deliverables, and success criteria that must be met before the next phase commences.

## Phase 1: Foundation & Security (Weeks 1–4)

### Objectives

- Establish project infrastructure and governance for the twelve-week engagement
- Provision Cognito, DynamoDB, S3, IAM, and API Gateway scaffold via Terraform in us-west-2
- Implement per-user and global quota enforcement (DynamoDB atomic conditional writes)
- Obtain CTO sign-off on the Cognito User Pool design
- Validate all prerequisites and confirm Phase 1 exit criteria

### Activities

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Kickoff meeting (scope, timeline, CTO sign-off process) | Vendor PM | 1 day | None |
| Current-state assessment (eof-tools library map, legacy workflow) | Vendor Arch | 3 days | Kickoff |
| Cloud readiness assessment (us-east-1 review, us-west-2 limits) | Vendor Eng | 2 days | Kickoff |
| Detailed architecture design + CTO briefing package | Vendor Arch | 5 days | Assessment |
| AWS foundation provisioning via Terraform (Cognito, DDB, S3, IAM, API GW) | Vendor Eng | 5 days | Architecture approval |
| Cognito post-confirmation Lambda development | Vendor Eng | 2 days | Cognito provisioned |
| DynamoDB atomic quota enforcement implementation | Vendor Eng | 3 days | DDB tables provisioned |
| Security baseline: Secrets Manager, CloudTrail, WAF rules | Security Eng | 3 days | Foundation provisioned |

### Detailed Procedures

#### 1.1 Terraform Backend Initialisation

The following commands initialise the Terraform backend for each environment. Run these once per environment before any `terraform plan` or `terraform apply` commands.

```bash
# Navigate to the Terraform root module
cd infrastructure/

# Initialise the development workspace
terraform init \
  -backend-config="bucket=amatra-dev-s3-tfstate-${AWS_ACCOUNT_ID}" \
  -backend-config="key=amatra/dev/terraform.tfstate" \
  -backend-config="region=us-west-2" \
  -backend-config="dynamodb_table=amatra-dev-ddb-tfstate-lock"

# Select or create the dev workspace
terraform workspace select dev || terraform workspace new dev

# Plan the foundation deployment
terraform plan \
  -var-file=environments/dev.tfvars \
  -out=plans/dev-foundation.plan

# Apply the foundation
terraform apply plans/dev-foundation.plan
```

Expected output:

```
Apply complete! Resources: 47 added, 0 changed, 0 destroyed.

Outputs:
cognito_user_pool_id    = "us-west-2_AbCdEfGhI"
api_gateway_endpoint    = "https://abc123.execute-api.us-west-2.amazonaws.com/dev"
s3_artifacts_bucket     = "amatra-dev-s3-artifacts-123456789012"
dynamodb_solutions_table = "amatra-dev-ddb-solutions"
```

#### 1.2 DynamoDB Quota Schema Validation

After provisioning, verify that the three DynamoDB tables are correctly configured with the required partition keys and PITR settings.

```bash
# Verify Users table
aws dynamodb describe-table \
  --table-name amatra-dev-ddb-users \
  --region us-west-2 \
  --query 'Table.{Status:TableStatus,PITR:PointInTimeRecoveryDescription.PointInTimeRecoveryStatus,BillingMode:BillingModeSummary.BillingMode}'

# Verify GlobalQuota table
aws dynamodb describe-table \
  --table-name amatra-dev-ddb-global-quota \
  --region us-west-2 \
  --query 'Table.{Status:TableStatus,PKName:KeySchema[0].AttributeName}'

# Test atomic quota conditional write
aws dynamodb put-item \
  --table-name amatra-dev-ddb-global-quota \
  --item '{"month":{"S":"2026-04"},"solutionsGenerated":{"N":"0"}}' \
  --condition-expression "attribute_not_exists(#m)" \
  --expression-attribute-names '{"#m":"month"}' \
  --region us-west-2
```

#### 1.3 Cognito User Pool Verification

Run the following commands to confirm the Cognito User Pool is operational and the post-confirmation Lambda trigger is wired correctly.

```bash
# List user pools to confirm creation
aws cognito-idp list-user-pools \
  --max-results 10 \
  --region us-west-2 \
  --query 'UserPools[?Name==`amatra-dev-cognito-userpool`].{Id:Id,Status:Status}'

# Verify Lambda trigger wiring
aws cognito-idp describe-user-pool \
  --user-pool-id us-west-2_AbCdEfGhI \
  --region us-west-2 \
  --query 'UserPool.LambdaConfig.PostConfirmation'

# Confirm app client created (no client secret required for CLI PKCE flow)
aws cognito-idp list-user-pool-clients \
  --user-pool-id us-west-2_AbCdEfGhI \
  --region us-west-2
```

### Deliverables

- [ ] Phase 1 Assessment & Architecture Report delivered and accepted by Marcus Patel
- [ ] Risk register approved by Daniel Park
- [ ] Cognito User Pool operational in us-west-2 with post-confirmation Lambda trigger active
- [ ] API Gateway HTTP API v2 scaffold responding to unauthenticated requests with `401 Unauthorized`
- [ ] DynamoDB three-table schema deployed with quota conditional write logic verified
- [ ] CloudTrail enabled in us-west-2; WAF attached to API Gateway stage
- [ ] CTO sign-off on Cognito User Pool configuration obtained in writing

### Success Criteria

- All three DynamoDB tables in `ACTIVE` state with PITR enabled in staging and production
- Cognito User Pool issuing JWT access tokens (1-hour expiry) and refresh tokens (30-day expiry)
- API Gateway JWT authoriser rejecting requests without valid Cognito tokens
- DynamoDB conditional write test: quota counter increments atomically and rejects writes when limit reached
- CloudTrail logs accessible in dedicated S3 bucket with MFA delete enabled

---

## Phase 2: Agent Build & Integration (Weeks 5–9)

### Objectives

- Develop all five Strands agents and register with Bedrock AgentCore Runtime
- Build and publish the eof-tools Docker image to ECR
- Implement the pip-installable CLI with 14 subcommands
- Develop all 11 Lambda route handlers with JWT protection
- Establish GitHub PAT-based artifact commit pipeline and CloudWatch observability

### Activities

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Input Validator Agent development and unit testing | Senior ML/AI Eng | 3 days | Phase 1 complete |
| Pre-Sales Generator Agent (5-artifact workflow) | Senior ML/AI Eng | 5 days | Input Validator |
| Delivery Generator Agent (6-artifact workflow) | Senior ML/AI Eng | 5 days | Pre-Sales Generator |
| Code Generator Agent (Terraform IaC + validate gate) | Senior ML/AI Eng | 3 days | Delivery Generator |
| EO Validator Agent (format-check + Haiku 4.5 quality gate, 3-retry logic) | Senior ML/AI Eng | 4 days | All generator agents |
| Multi-stage Dockerfile + ECR push + AgentCore Runtime registration | DevOps Eng | 3 days | Phase 1 complete |
| CLI development (14 subcommands, JWT auth, pip packaging) | Senior Solutions Eng | 5 days | Cognito operational |
| Lambda route handlers (all 11 routes, request/response validated) | Senior Solutions Eng | 5 days | DynamoDB and S3 provisioned |
| GitHub PAT integration Lambda + DLQ configuration | Senior Solutions Eng | 2 days | Secrets Manager |
| CloudWatch observability (per-phase token metrics, dashboards, alarms) | DevOps Eng | 3 days | All agents integrated |
| Security hardening (WAF, KMS, IAM policy audit) | Security Eng | 3 days | All components |

### Detailed Procedures

#### 2.1 Docker Image Build and ECR Push

The eof-tools agent container image is built using a multi-stage Dockerfile that bakes all ~30 eof-tools Python converter modules into the image without rewriting them.

```bash
# Navigate to the agent container directory
cd containers/eoframework-agent/

# Build the multi-stage image (stage 1: dependencies; stage 2: runtime)
docker build \
  --target runtime \
  --build-arg PYTHON_VERSION=3.12 \
  --tag amatra-eoframework-agent:1.0.0 \
  .

# Authenticate to ECR
aws ecr get-login-password --region us-west-2 | \
  docker login \
  --username AWS \
  --password-stdin \
  ${AWS_ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com

# Tag the image with the ECR repository URI
docker tag amatra-eoframework-agent:1.0.0 \
  ${AWS_ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com/amatra-dev-ecr-eoframework-agent:1.0.0

# Push to ECR
docker push \
  ${AWS_ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com/amatra-dev-ecr-eoframework-agent:1.0.0

# Retrieve the immutable digest for AgentCore Runtime registration
aws ecr describe-images \
  --repository-name amatra-dev-ecr-eoframework-agent \
  --image-ids imageTag=1.0.0 \
  --region us-west-2 \
  --query 'imageDetails[0].imageDigest'
```

#### 2.2 AgentCore Runtime Agent Registration

Register each of the five Strands agents with Bedrock AgentCore Runtime using immutable ECR image digest references.

```bash
# Register the Input Validator Agent
aws bedrock-agentcore create-agent \
  --agent-name amatra-dev-input-validator \
  --description "Parses and validates EO Framework client brief JSON against schema" \
  --container-configuration '{
    "imageUri": "${ECR_URI}/amatra-dev-ecr-eoframework-agent@sha256:${IMAGE_DIGEST}",
    "entrypoint": ["python", "-m", "agents.input_validator"]
  }' \
  --region us-west-2

# Register the Pre-Sales Generator Agent
aws bedrock-agentcore create-agent \
  --agent-name amatra-dev-presales-generator \
  --description "Orchestrates 5-artifact presales workflow using Claude Sonnet 4.6" \
  --container-configuration '{
    "imageUri": "${ECR_URI}/amatra-dev-ecr-eoframework-agent@sha256:${IMAGE_DIGEST}",
    "entrypoint": ["python", "-m", "agents.presales_generator"]
  }' \
  --region us-west-2

# Repeat for delivery-generator, code-generator, and eo-validator agents
# Verify all agents are ACTIVE
aws bedrock-agentcore list-agents \
  --region us-west-2 \
  --query 'agents[?starts_with(agentName, `amatra-dev`)].{Name:agentName,Status:agentStatus}'
```

#### 2.3 CLI Package Verification

After CLI development, verify all 14 subcommands are present in the pip-installable package.

```bash
# Install the CLI from the local package
pip install -e cli/

# Verify all 14 subcommands are registered
amatra --help

# Test authentication flow end-to-end
amatra auth login --username test.user@predictif.com

# Verify token is stored
ls -la ~/.amatra/credentials

# Test solution generate (dry run against staging)
amatra solution generate \
  --brief tests/fixtures/sample-brief.json \
  --api-url https://api-dev.amatra.predictif.com \
  --dry-run
```

### Deliverables

- [ ] All five agents registered on Bedrock AgentCore Runtime with `ACTIVE` status
- [ ] Docker image published to ECR with immutable digest confirmed and ECR scan showing no critical CVEs
- [ ] Pip-installable CLI passing local integration tests against all 14 subcommands
- [ ] All 11 Lambda routes responding to authenticated requests with correct response shapes
- [ ] GitHub commit test: sample artifact bundle committed to the fixed public repository via PAT
- [ ] CloudWatch dashboards (all four) and alarms deployed and verifiable

### Success Criteria

- All five agents return a valid pass/fail envelope when invoked with a representative EO Framework brief
- CLI `auth login` completes in under 5 seconds and stores credentials in `~/.amatra/credentials`
- All 11 Lambda routes return `401` for unauthenticated requests and `200` for valid JWT requests
- GitHub commit Lambda successfully commits a test artifact to the `main` branch
- CloudWatch custom metric `SolutionTokenUsage` is emitted for each phase (Discovery, Planning, Development, Testing, Deployment)

---

## Phase 3: Validation & Go-Live (Weeks 10–12)

### Objectives

- Execute comprehensive end-to-end validation across all 12 artifact types
- Establish green CloudWatch metrics baseline (Lambda error rate < 1%, API Gateway 4xx < 2%)
- Coordinate UAT with Marcus Patel and executive demonstration preparation for Sarah Lin
- Deploy to production via Terraform with CTO sign-off gate
- Deliver all documentation, runbooks, and knowledge transfer sessions

### Activities

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Test plan development (Deliverable 18) | QA Eng | 3 days | Phase 2 complete |
| Unit and integration testing (all 12 artifact types) | QA Eng | 5 days | Test plan |
| API route testing (all 11 routes, JWT, error codes) | QA Eng | 2 days | Test plan |
| Performance and quota load testing (concurrent submissions) | QA Eng | 2 days | Integration tests |
| Security testing (JWT bypass, WAF, IAM escalation checks) | Security Eng | 2 days | Infrastructure final |
| CloudWatch baseline validation (green metrics confirmation) | DevOps Eng | 1 day | All tests passing |
| UAT coordination with Marcus Patel (3 representative briefs) | Vendor PM | 2 days | Green baseline |
| Production Terraform apply (CTO sign-off gate) | DevOps Eng | 1 day | UAT sign-off |
| CLI PyPI package publication | DevOps Eng | 1 day | Production deployed |
| Runbooks, documentation, knowledge transfer sessions | Technical Writer | 3 days | Go-live confirmed |
| Executive demonstration to Sarah Lin (CRO) | Vendor PM + Arch | 1 day | Production live |

### Deliverables

- [ ] Test Results Report (Deliverable 19) delivered with 95%+ first-attempt pass rate confirmed
- [ ] Production deployment live in us-west-2 (Deliverable 20)
- [ ] CLI pip package published to PyPI (Deliverable 21)
- [ ] Operational runbooks delivered and accepted by Daniel Park (Deliverable 22)
- [ ] As-built architecture and API/CLI reference delivered (Deliverable 23)
- [ ] Knowledge transfer sessions completed for both teams (Deliverable 24)
- [ ] Executive demonstration delivered to Sarah Lin
- [ ] Formal project acceptance and closeout report signed (Deliverable 26)

### Success Criteria

- All 12 artifact types generating and passing validation in under 60 minutes end-to-end
- CloudWatch green baseline: Lambda error rate < 1%, DynamoDB throttles = 0, API Gateway 4xx < 2%
- UAT sign-off obtained from Marcus Patel
- CTO sign-off on production deployment confirmed in writing before `terraform apply`
- All 120 consultants notified with CLI onboarding instructions

---

# Infrastructure Deployment

This section defines the precise deployment procedures for each infrastructure layer of the Amatra Agentic Orchestration Platform. All deployments are executed via Terraform against the us-west-2 region across three environments (dev, staging, prod). The four subsections below must be deployed in order: Networking first, then Security, then Compute, then Monitoring.

## Networking

The networking layer establishes the API Gateway HTTP API v2 as the single public ingress point, WAF attachment, ACM certificate, and custom domain configuration. Because the platform is fully serverless, there are no VPCs, subnets, or NAT gateways to configure.

### Components

The following table lists all networking components deployed in this subsection.

| Component | Type | Purpose | Environment |
|-----------|------|---------|-------------|
| API Gateway HTTP API v2 | `aws_apigatewayv2_api` | Single public HTTPS ingress for all 11 Lambda routes | dev, staging, prod |
| API Gateway Stage | `aws_apigatewayv2_stage` | Per-environment stage (`dev`, `staging`, `prod`) with access logging | dev, staging, prod |
| ACM TLS Certificate | `aws_acm_certificate` | TLS 1.2+ certificate for custom domain (must be in us-east-1) | prod only |
| Custom Domain | `aws_apigatewayv2_domain_name` | `api.amatra.predictif.com` / `api-dev.amatra.predictif.com` | dev, prod |
| WAF WebACL | `aws_wafv2_web_acl` | IP rate limiting (100 req/IP/min) + AWS Managed Rules CRS | dev, staging, prod |
| WAF WebACL Association | `aws_wafv2_web_acl_association` | Attaches WAF WebACL to the API Gateway stage ARN | dev, staging, prod |

### Script Location

Networking Terraform modules are located at `infrastructure/modules/networking/` with environment-specific variable files at `infrastructure/environments/{env}.tfvars`.

### Deployment Steps

The following commands deploy the networking layer. Execute from the `infrastructure/` directory with the appropriate workspace selected.

```bash
# Confirm the correct workspace is selected
terraform workspace show

# Plan the networking module only
terraform plan \
  -var-file=environments/${ENVIRONMENT}.tfvars \
  -target=module.networking \
  -out=plans/${ENVIRONMENT}-networking.plan

# Review the plan output — verify API Gateway, ACM, WAF resources are included
cat plans/${ENVIRONMENT}-networking.plan | grep "resource"

# Apply the networking module
terraform apply plans/${ENVIRONMENT}-networking.plan

# Capture networking outputs for downstream modules
terraform output -json > outputs/${ENVIRONMENT}-networking.json

# Verify API Gateway endpoint is reachable
curl -s -o /dev/null -w "%{http_code}" \
  "$(terraform output -raw api_gateway_endpoint)/v1/quota"
# Expected: 401 (JWT authoriser active, no token provided)
```

### Validation

After applying the networking module, run the following validation checks:

```bash
# Confirm API Gateway is in ACTIVE state
aws apigatewayv2 get-apis \
  --region us-west-2 \
  --query 'Items[?Name==`amatra-'${ENVIRONMENT}'-apigw-http-api`].{Id:ApiId,State:ApiEndpoint}'

# Confirm WAF WebACL is attached to the API Gateway stage
aws wafv2 list-resources-for-web-acl \
  --web-acl-arn $(terraform output -raw waf_web_acl_arn) \
  --resource-type API_GATEWAY \
  --region us-west-2

# Confirm TLS 1.2 minimum is enforced (production only)
curl -v --tlsv1.1 https://api.amatra.predictif.com/v1/quota 2>&1 | grep "SSL"
# Expected: TLS 1.1 connection REJECTED; TLS 1.2 ACCEPTED
```

### Success Criteria

- API Gateway HTTP API v2 in `ACTIVE` state with JWT authoriser configured
- All unauthenticated requests to any route receive `401 Unauthorized`
- WAF WebACL successfully blocks SQLi payloads (test with `curl` payload containing `' OR 1=1`)
- TLS 1.2 minimum enforced; TLS 1.0/1.1 connections rejected
- Custom domain resolving to API Gateway endpoint via DNS

### Rollback

If the networking deployment fails or produces an incorrect configuration, execute the following rollback:

```bash
# Destroy only the networking module resources
terraform destroy \
  -var-file=environments/${ENVIRONMENT}.tfvars \
  -target=module.networking \
  -auto-approve

# Verify all networking resources are removed
aws apigatewayv2 get-apis --region us-west-2 \
  --query 'Items[?starts_with(Name, `amatra-'${ENVIRONMENT}'`)]'
# Expected: empty list

# Notify stakeholders of rollback
echo "Networking rollback complete at $(date -u)" | \
  aws sns publish \
  --topic-arn $(cat outputs/${ENVIRONMENT}-sns-arn.txt) \
  --message file:///dev/stdin \
  --subject "Amatra Platform - Networking Rollback - ${ENVIRONMENT}"
```

---

## Security

The security layer provisions the Cognito User Pool, JWT authoriser, Secrets Manager secrets, IAM least-privilege roles, KMS key configuration, and CloudTrail. This subsection requires CTO sign-off on the Cognito User Pool design before production deployment.

### Components

The following table lists all security components deployed in this subsection.

| Component | Type | Purpose | Environment |
|-----------|------|---------|-------------|
| Cognito User Pool | `aws_cognito_user_pool` | Identity provider for ~120 consultant MAUs; RS256 JWT issuance | dev, staging, prod |
| Cognito User Pool Client | `aws_cognito_user_pool_client` | CLI app client for USER_PASSWORD_AUTH flow; no client secret for PKCE | dev, staging, prod |
| Cognito User Pool Groups | `aws_cognito_user_group` | `consultants` and `admin` groups for route-level authorisation | dev, staging, prod |
| API Gateway JWT Authoriser | `aws_apigatewayv2_authorizer` | Validates Cognito JWT against JWKS endpoint on every request | dev, staging, prod |
| Secrets Manager — GitHub PAT | `aws_secretsmanager_secret` | Stores GitHub PAT at `amatra/{env}/github/pat`; quarterly rotation | dev, staging, prod |
| Secrets Manager — Cognito Secret | `aws_secretsmanager_secret` | Stores Cognito app client secret at `amatra/{env}/cognito/client-secret` | dev, staging, prod |
| IAM Lambda Execution Roles | `aws_iam_role` | Per-function least-privilege roles (11 Lambda + 1 post-confirmation trigger) | dev, staging, prod |
| CloudTrail Trail | `aws_cloudtrail` | All management + data-plane API calls; S3 delivery with MFA delete | dev, staging, prod |
| CloudTrail S3 Bucket | `aws_s3_bucket` | Dedicated bucket for CloudTrail log delivery; SSE + MFA delete enabled | dev, staging, prod |

### Script Location

Security Terraform modules are located at `infrastructure/modules/security/` and `infrastructure/modules/iam/`. IAM policy documents are in `infrastructure/policies/`.

### Deployment Steps

The following commands deploy the security layer. The Cognito User Pool requires CTO sign-off before production deployment — ensure written approval is on file before applying to the `prod` workspace.

```bash
# IMPORTANT: For production, confirm CTO sign-off is on file before proceeding
# [GATE] CTO written approval required: amatra-cto-cognito-signoff.pdf

# Plan the security module
terraform plan \
  -var-file=environments/${ENVIRONMENT}.tfvars \
  -target=module.security \
  -target=module.iam \
  -out=plans/${ENVIRONMENT}-security.plan

# Apply the security module
terraform apply plans/${ENVIRONMENT}-security.plan

# Store the GitHub PAT in Secrets Manager (operator provides PAT value interactively)
read -s -p "Enter GitHub PAT value: " GITHUB_PAT
aws secretsmanager put-secret-value \
  --secret-id "amatra/${ENVIRONMENT}/github/pat" \
  --secret-string "${GITHUB_PAT}" \
  --region us-west-2
unset GITHUB_PAT

# Verify IAM policies have no wildcard resource ARNs
aws iam list-role-policies \
  --role-name amatra-${ENVIRONMENT}-iam-role-solution-create \
  --query 'PolicyNames'
```

### Validation

After applying the security module, run the following validation checks:

```bash
# Verify Cognito User Pool is ACTIVE with JWT authoriser
aws cognito-idp describe-user-pool \
  --user-pool-id $(terraform output -raw cognito_user_pool_id) \
  --region us-west-2 \
  --query 'UserPool.{Status:Status,MFA:MfaConfiguration,Lambda:LambdaConfig}'

# Verify Secrets Manager secrets exist (without retrieving values)
aws secretsmanager describe-secret \
  --secret-id "amatra/${ENVIRONMENT}/github/pat" \
  --region us-west-2 \
  --query '{Name:Name,LastChangedDate:LastChangedDate}'

# Verify CloudTrail is logging
aws cloudtrail describe-trails \
  --region us-west-2 \
  --query 'trailList[?Name==`amatra-${ENVIRONMENT}-cloudtrail`].{Status:IsLogging,S3Bucket:S3BucketName}'

# Verify IAM Access Analyzer finds no unintended external access
aws accessanalyzer list-findings \
  --analyzer-arn $(terraform output -raw access_analyzer_arn) \
  --filter '{"status":{"eq":["ACTIVE"]}}' \
  --region us-west-2
```

### Success Criteria

- Cognito User Pool `ACTIVE`; JWT access tokens issued with 1-hour expiry; refresh tokens with 30-day expiry
- All Secrets Manager secrets created; `GetSecretValue` calls visible in CloudTrail within 5 minutes of access
- IAM Access Analyzer reports zero active findings for Lambda execution roles
- CloudTrail logging active; S3 bucket has MFA delete enabled and SSE-S3 encryption
- Cognito `consultants` group grants access only to `/solution/*`, `/artifact/*`, `/user/profile` routes
- Cognito `admin` group additionally grants access to `GET /admin/usage` and `POST /admin/quota/reset`

### Rollback

If the security deployment fails, execute the following rollback procedure:

```bash
# Destroy security module resources (Cognito, IAM roles, Secrets Manager)
terraform destroy \
  -var-file=environments/${ENVIRONMENT}.tfvars \
  -target=module.security \
  -target=module.iam \
  -auto-approve

# Confirm Cognito User Pool is deleted
aws cognito-idp list-user-pools \
  --max-results 10 \
  --region us-west-2 \
  --query 'UserPools[?Name==`amatra-'${ENVIRONMENT}'-cognito-userpool`]'
# Expected: empty list

# CloudTrail and S3 audit bucket are retained for audit purposes even on rollback
# Do NOT delete the CloudTrail S3 bucket during rollback — retain for compliance
```

---

## Compute

The compute layer provisions all twelve Lambda functions (11 route handlers + 1 post-confirmation trigger), Bedrock AgentCore Runtime agent registrations, ECR repository, CodeBuild projects, and SSM Parameter Store configuration. This is the heaviest deployment module and is applied after Networking and Security are fully validated.

### Components

The following table lists all compute components deployed in this subsection.

| Component | Type | Purpose | Environment |
|-----------|------|---------|-------------|
| Lambda — Solution Create | `aws_lambda_function` | Accept solution request; enforce quota; invoke AgentCore graph | dev, staging, prod |
| Lambda — Solution Status | `aws_lambda_function` | Return generation status and per-phase token usage | dev, staging, prod |
| Lambda — Artifact Fetch | `aws_lambda_function` | Return S3 presigned URL for artifact download | dev, staging, prod |
| Lambda — User Profile | `aws_lambda_function` | Return/update authenticated user profile and quota status | dev, staging, prod |
| Lambda — Quota Check | `aws_lambda_function` | Return current per-user and global quota consumption | dev, staging, prod |
| Lambda — Admin Usage | `aws_lambda_function` | Return aggregate token usage and platform metrics | dev, staging, prod |
| Lambda — Auth Refresh | `aws_lambda_function` | Exchange Cognito refresh token for new access token | dev, staging, prod |
| Lambda — Solutions List | `aws_lambda_function` | List all solutions for authenticated user, paginated | dev, staging, prod |
| Lambda — Solution Delete | `aws_lambda_function` | Cancel in-progress or delete completed solution record | dev, staging, prod |
| Lambda — Quota Reset (Admin) | `aws_lambda_function` | Override quota counters for user or global reset | dev, staging, prod |
| Lambda — GitHub Integration | `aws_lambda_function` | Commit all 12 artifacts to fixed public GitHub repository | dev, staging, prod |
| Lambda — Post-Confirmation | `aws_lambda_function` | Cognito trigger: write user profile + seed quota counter | dev, staging, prod |
| AgentCore Runtime Agents (5) | Bedrock AgentCore | Input Validator, Pre-Sales Gen, Delivery Gen, Code Gen, EO Validator | dev, staging, prod |
| ECR Repository | `aws_ecr_repository` | Stores versioned eof-tools agent container images | dev, staging, prod |
| CodeBuild — Agent Image | `aws_codebuild_project` | Builds multi-stage Docker image and pushes to ECR | dev, staging, prod |
| CodeBuild — Terraform Plan | `aws_codebuild_project` | Runs `terraform plan` gate on pull request before merge | dev, staging, prod |
| SSM Parameters | `aws_ssm_parameter` | Non-secret runtime config (bucket names, table names, API URLs) | dev, staging, prod |

### Script Location

Compute Terraform modules are located at `infrastructure/modules/compute/` and `infrastructure/modules/ecr/`. Lambda function source code is at `src/lambda/` and agent source code is at `src/agents/`. CodeBuild buildspec files are at `buildspecs/`.

### Deployment Steps

The following commands deploy the compute layer. Lambda functions are packaged, zipped, and uploaded to S3 before Terraform references them.

```bash
# Step 1: Package Lambda functions
cd src/lambda/
pip install -r requirements.txt -t packages/
cd packages/
zip -r ../../../artifacts/lambda-${ENVIRONMENT}-${VERSION}.zip .
cd ../../../
zip -ur artifacts/lambda-${ENVIRONMENT}-${VERSION}.zip src/lambda/*.py

# Step 2: Upload Lambda package to S3
aws s3 cp artifacts/lambda-${ENVIRONMENT}-${VERSION}.zip \
  s3://amatra-${ENVIRONMENT}-s3-artifacts-${AWS_ACCOUNT_ID}/deployments/${VERSION}/ \
  --region us-west-2

# Step 3: Deploy compute module via Terraform
cd infrastructure/
terraform plan \
  -var-file=environments/${ENVIRONMENT}.tfvars \
  -var="lambda_package_version=${VERSION}" \
  -target=module.compute \
  -target=module.ecr \
  -out=plans/${ENVIRONMENT}-compute.plan

terraform apply plans/${ENVIRONMENT}-compute.plan

# Step 4: Configure Provisioned Concurrency for production (prod only)
if [ "${ENVIRONMENT}" = "prod" ]; then
  aws lambda put-provisioned-concurrency-config \
    --function-name amatra-prod-lambda-solution-create \
    --qualifier LIVE \
    --provisioned-concurrent-executions 2 \
    --region us-west-2

  aws lambda put-provisioned-concurrency-config \
    --function-name amatra-prod-lambda-solution-status \
    --qualifier LIVE \
    --provisioned-concurrent-executions 2 \
    --region us-west-2
fi

# Step 5: Invoke each Lambda function with a health check payload
for FUNCTION in solution-create solution-status artifact-fetch user-profile quota-check; do
  aws lambda invoke \
    --function-name amatra-${ENVIRONMENT}-lambda-${FUNCTION} \
    --payload '{"httpMethod":"GET","path":"/health","headers":{}}' \
    --region us-west-2 \
    /tmp/lambda-${FUNCTION}-response.json
  echo "=== ${FUNCTION} ===" && cat /tmp/lambda-${FUNCTION}-response.json
done
```

### Validation

After applying the compute module, run the following validation checks:

```bash
# Verify all 11 route Lambda functions are in Active state
aws lambda list-functions \
  --region us-west-2 \
  --query 'Functions[?starts_with(FunctionName, `amatra-'${ENVIRONMENT}'-lambda`)].{Name:FunctionName,State:State,Runtime:Runtime}'

# Verify all 5 AgentCore Runtime agents are ACTIVE
aws bedrock-agentcore list-agents \
  --region us-west-2 \
  --query 'agents[?starts_with(agentName, `amatra-'${ENVIRONMENT}'`)].{Name:agentName,Status:agentStatus}'
# Expected: all 5 agents with Status=ACTIVE

# Verify ECR repository and latest image digest
aws ecr describe-images \
  --repository-name amatra-${ENVIRONMENT}-ecr-eoframework-agent \
  --region us-west-2 \
  --query 'sort_by(imageDetails, &imagePushedAt)[-1].{Tag:imageTags[0],Digest:imageDigest,ScanStatus:imageScanStatus.status}'
# Expected: ScanStatus=COMPLETE (no CRITICAL findings)

# Verify SSM parameters are populated
aws ssm get-parameters-by-path \
  --path "/amatra/${ENVIRONMENT}/" \
  --region us-west-2 \
  --query 'Parameters[].{Name:Name,Type:Type}'
```

### Success Criteria

- All 12 Lambda functions in `Active` state with correct memory and timeout configuration matching `configuration.csv`
- All 5 AgentCore Runtime agents in `ACTIVE` status with immutable ECR image digest references
- ECR image scan result: zero `CRITICAL` or `HIGH` severity CVEs
- Provisioned Concurrency configured for Solution Create Lambda (2 instances) and Solution Status Lambda (2 instances) in production
- SSM Parameter Store populated with all runtime configuration values; Lambda functions successfully reading SSM parameters on cold start
- End-to-end test: `POST /v1/solution` with valid JWT returns `solutionId` and `PENDING` status within 30 seconds

### Rollback

If the compute deployment fails, execute the following rollback procedure:

```bash
# For Lambda functions: repoint alias to previous version
PREVIOUS_VERSION=$(aws lambda list-versions-by-function \
  --function-name amatra-${ENVIRONMENT}-lambda-solution-create \
  --region us-west-2 \
  --query 'sort_by(Versions, &LastModified)[-2].Version' \
  --output text)

aws lambda update-alias \
  --function-name amatra-${ENVIRONMENT}-lambda-solution-create \
  --name LIVE \
  --function-version ${PREVIOUS_VERSION} \
  --region us-west-2

# For API Gateway: repoint stage to previous Lambda alias
# (blue-green alias swap — < 5 minutes execution time)
aws apigatewayv2 update-integration \
  --api-id $(terraform output -raw api_gateway_id) \
  --integration-id $(terraform output -raw solution_create_integration_id) \
  --integration-uri arn:aws:lambda:us-west-2:${AWS_ACCOUNT_ID}:function:amatra-${ENVIRONMENT}-lambda-solution-create:${PREVIOUS_VERSION} \
  --region us-west-2

# Notify stakeholders
echo "Compute rollback complete. API traffic reverted to Lambda version ${PREVIOUS_VERSION}" | \
  aws sns publish \
  --topic-arn $(terraform output -raw sns_ops_topic_arn) \
  --message file:///dev/stdin \
  --subject "Amatra Platform - Compute Rollback - ${ENVIRONMENT}"
```

---

## Monitoring

The monitoring layer provisions all CloudWatch dashboards, alarms, log groups, X-Ray tracing, Synthetic Canaries, and SNS notification topics. This subsection is deployed last as it depends on resource ARNs from all preceding modules.

### Components

The following table lists all monitoring components deployed in this subsection.

| Component | Type | Purpose | Environment |
|-----------|------|---------|-------------|
| CloudWatch Log Groups (12) | `aws_cloudwatch_log_group` | Structured JSON logs for all Lambda functions; 30-day retention (prod/staging), 14-day (dev) | dev, staging, prod |
| CloudWatch Dashboard — Platform Health | `aws_cloudwatch_dashboard` | Lambda errors, DynamoDB throttles, API Gateway 4xx/5xx | dev, staging, prod |
| CloudWatch Dashboard — Solution Throughput | `aws_cloudwatch_dashboard` | Solutions/day, artifact types, validation pass rate | dev, staging, prod |
| CloudWatch Dashboard — Cost Telemetry | `aws_cloudwatch_dashboard` | Bedrock token spend by model and phase, per-solution cost trend | dev, staging, prod |
| CloudWatch Dashboard — Quota Utilisation | `aws_cloudwatch_dashboard` | Per-user and global quota consumption heat map | dev, staging, prod |
| CloudWatch Alarms (8) | `aws_cloudwatch_metric_alarm` | Platform availability, Lambda errors, quota near-limit, GitHub failures, Bedrock spend anomaly | dev, staging, prod |
| SNS Topic — Ops Alerts | `aws_sns_topic` | Notification channel for all CloudWatch alarms to Daniel Park's team | dev, staging, prod |
| CloudWatch Synthetic Canary | `aws_synthetics_canary` | Availability check against `GET /v1/quota` every 5 minutes | prod, staging |
| AWS X-Ray — Tracing Group | `aws_xray_group` | End-to-end distributed tracing for API Gateway → Lambda → DynamoDB → Bedrock | dev, staging, prod |
| CloudWatch Custom Metric Namespace | (emitted by Lambda code) | `Amatra/TokenUsage` namespace for per-phase Bedrock token consumption | dev, staging, prod |

### Script Location

Monitoring Terraform modules are located at `infrastructure/modules/monitoring/`. Dashboard JSON widgets are in `infrastructure/modules/monitoring/dashboards/`. Canary scripts are at `infrastructure/modules/monitoring/canary/`.

### Deployment Steps

The following commands deploy the monitoring layer.

```bash
# Deploy the monitoring module
cd infrastructure/
terraform plan \
  -var-file=environments/${ENVIRONMENT}.tfvars \
  -target=module.monitoring \
  -out=plans/${ENVIRONMENT}-monitoring.plan

terraform apply plans/${ENVIRONMENT}-monitoring.plan

# Subscribe Daniel Park to the SNS ops alerts topic (production only)
if [ "${ENVIRONMENT}" = "prod" ]; then
  aws sns subscribe \
    --topic-arn $(terraform output -raw sns_ops_topic_arn) \
    --protocol email \
    --notification-endpoint daniel.park@predictif.com \
    --region us-west-2
  echo "Subscription confirmation email sent to daniel.park@predictif.com"
fi

# Enable X-Ray active tracing on all Lambda functions
for FUNCTION_NAME in $(aws lambda list-functions \
  --region us-west-2 \
  --query 'Functions[?starts_with(FunctionName, `amatra-'${ENVIRONMENT}'`)].FunctionName' \
  --output text); do
  aws lambda update-function-configuration \
    --function-name ${FUNCTION_NAME} \
    --tracing-config Mode=Active \
    --region us-west-2
done

# Trigger a test alarm to verify SNS notification delivery
aws cloudwatch set-alarm-state \
  --alarm-name "amatra-${ENVIRONMENT}-lambda-error-rate-high" \
  --state-value ALARM \
  --state-reason "Test notification — monitoring deployment validation" \
  --region us-west-2

# Reset the alarm after confirming notification received
sleep 30
aws cloudwatch set-alarm-state \
  --alarm-name "amatra-${ENVIRONMENT}-lambda-error-rate-high" \
  --state-value OK \
  --state-reason "Test notification complete" \
  --region us-west-2
```

### Validation

After applying the monitoring module, run the following validation checks:

```bash
# Verify all four CloudWatch dashboards exist
aws cloudwatch list-dashboards \
  --dashboard-name-prefix amatra-${ENVIRONMENT} \
  --region us-west-2 \
  --query 'DashboardEntries[].DashboardName'
# Expected: 4 dashboards (platform-health, solution-throughput, cost-telemetry, quota-utilisation)

# Verify all 8 alarms are in OK state
aws cloudwatch describe-alarms \
  --alarm-name-prefix amatra-${ENVIRONMENT} \
  --region us-west-2 \
  --query 'MetricAlarms[].{Name:AlarmName,State:StateValue}'

# Verify Synthetic Canary is running (prod/staging only)
aws synthetics describe-canaries \
  --name amatra-${ENVIRONMENT}-availability-canary \
  --region us-west-2 \
  --query 'Canaries[0].{Status:Status.State,LastRunStatus:Status.StateReason}'

# Verify X-Ray tracing is active
aws xray get-groups \
  --region us-west-2 \
  --query 'Groups[?GroupName==`amatra-${ENVIRONMENT}-tracing`]'

# Emit a test custom metric and verify it appears in CloudWatch
aws cloudwatch put-metric-data \
  --namespace "Amatra/TokenUsage" \
  --metric-name "PhaseTotalTokens" \
  --dimensions Phase=Development,Environment=${ENVIRONMENT} \
  --value 1500 \
  --unit Count \
  --region us-west-2

aws cloudwatch get-metric-statistics \
  --namespace "Amatra/TokenUsage" \
  --metric-name "PhaseTotalTokens" \
  --dimensions Name=Phase,Value=Development Name=Environment,Value=${ENVIRONMENT} \
  --start-time $(date -u -d '5 minutes ago' '+%Y-%m-%dT%H:%M:%SZ') \
  --end-time $(date -u '+%Y-%m-%dT%H:%M:%SZ') \
  --period 300 \
  --statistics Sum \
  --region us-west-2
```

### Success Criteria

- All four CloudWatch dashboards visible and populating with live metrics within 5 minutes of first Lambda invocation
- All 8 CloudWatch alarms in `OK` state with SNS notification delivery confirmed via test alarm
- Synthetic Canary reporting `PASSED` status on every 5-minute run against `GET /v1/quota`
- X-Ray traces visible in the console for all Lambda function invocations; end-to-end trace including DynamoDB and Bedrock spans
- `Amatra/TokenUsage` custom metrics namespace visible in CloudWatch with `PhaseTotalTokens` data points per phase

### Rollback

If the monitoring deployment produces misconfigured alarms or dashboards, execute the following rollback:

```bash
# Destroy only the monitoring module resources
terraform destroy \
  -var-file=environments/${ENVIRONMENT}.tfvars \
  -target=module.monitoring \
  -auto-approve

# Note: CloudWatch Log Groups are retained even on rollback to preserve log history
# Only dashboards, alarms, canary, and SNS topic are destroyed

# Notify stakeholders of monitoring rollback
echo "Monitoring module rollback complete at $(date -u). Log groups retained." | \
  aws sns publish \
  --topic-arn $(cat outputs/${ENVIRONMENT}-sns-arn.txt 2>/dev/null || echo "N/A — SNS destroyed in rollback") \
  --message file:///dev/stdin \
  --subject "Amatra Platform - Monitoring Rollback - ${ENVIRONMENT}" \
  --region us-west-2 2>/dev/null || true
```

---

# Application Configuration

This section covers application-layer configuration after all four infrastructure modules are deployed and validated. It wires the five agents, Lambda functions, CLI, and GitHub integration together with their final runtime values.

## Cognito User Pool Configuration

The Cognito User Pool is provisioned by Terraform, but the following post-provisioning steps must be completed manually for each environment before end-user access is enabled.

Configuring the Cognito User Pool requires the following steps after Terraform provisioning:

```bash
# Create the consultants group
aws cognito-idp create-group \
  --user-pool-id ${COGNITO_USER_POOL_ID} \
  --group-name consultants \
  --description "Standard PREDICTif consultants — access to solution and artifact routes" \
  --region us-west-2

# Create the admin group
aws cognito-idp create-group \
  --user-pool-id ${COGNITO_USER_POOL_ID} \
  --group-name admin \
  --description "Platform administrators — access to admin usage and quota reset routes" \
  --region us-west-2

# Add Daniel Park to the admin group
aws cognito-idp admin-add-user-to-group \
  --user-pool-id ${COGNITO_USER_POOL_ID} \
  --username daniel.park@predictif.com \
  --group-name admin \
  --region us-west-2

# Add Marcus Patel to the admin group
aws cognito-idp admin-add-user-to-group \
  --user-pool-id ${COGNITO_USER_POOL_ID} \
  --username marcus.patel@predictif.com \
  --group-name admin \
  --region us-west-2
```

## Agent Configuration

The five Strands agents are configured via a YAML configuration file loaded from S3 at agent initialisation time. The following is the complete agent configuration file structure.

```yaml
# config/agents/agent-config-{env}.yml
# Loaded by agents from S3: s3://amatra-{env}-s3-guidance-{account-id}/config/agent-config.yml

platform:
  name: amatra-agentic-orchestration-platform
  version: "1.0.0"
  environment: ${ENVIRONMENT}
  region: us-west-2

bedrock:
  generation_model_id: anthropic.claude-sonnet-4-6
  validation_model_id: anthropic.claude-haiku-4-5
  max_retries_per_artifact: 3
  generation_retry_initial_delay_ms: 1000
  target_cost_per_solution_usd: 5.00

agents:
  input_validator:
    name: amatra-${ENVIRONMENT}-input-validator
    brief_schema_s3_key: schemas/brief-schema-v1.json
  presales_generator:
    name: amatra-${ENVIRONMENT}-presales-generator
    guidance_prefix: guidance/pre-sales/
    artifact_types:
      - solution-briefing
      - infrastructure-costs
      - level-of-effort-estimate
      - statement-of-work
      - proposal
  delivery_generator:
    name: amatra-${ENVIRONMENT}-delivery-generator
    guidance_prefix: guidance/delivery/
    artifact_types:
      - project-charter
      - implementation-guide
      - raid-log
      - runbooks
      - test-plan
      - closure-report
  code_generator:
    name: amatra-${ENVIRONMENT}-code-generator
    terraform_services:
      - cognito
      - api-gateway
      - lambda
      - dynamodb
      - s3
    validate_gate: true
  eo_validator:
    name: amatra-${ENVIRONMENT}-eo-validator
    format_check_enabled: true
    llm_quality_check_enabled: true
    pass_rate_target: 0.95

storage:
  artifacts_bucket: amatra-${ENVIRONMENT}-s3-artifacts-${AWS_ACCOUNT_ID}
  guidance_bucket: amatra-${ENVIRONMENT}-s3-guidance-${AWS_ACCOUNT_ID}
  raw_prefix: raw/
  converted_prefix: converted/
  terraform_prefix: terraform/

quota:
  user_monthly_limit: 10
  global_monthly_limit: 1000
  global_alert_threshold_pct: 90
  user_alert_count: 8
```

## Lambda Environment Variables

The following table defines all Lambda environment variable configurations. Values are sourced from SSM Parameter Store at Lambda initialisation time — not hardcoded.

| Variable | SSM Parameter Path | Example Value | Lambda Functions |
|----------|--------------------|---------------|-----------------|
| `ARTIFACTS_BUCKET_NAME` | `/amatra/{env}/s3/artifacts-bucket-name` | `amatra-prod-s3-artifacts-123456789` | All |
| `GUIDANCE_BUCKET_NAME` | `/amatra/{env}/s3/guidance-bucket-name` | `amatra-prod-s3-guidance-123456789` | Agent Lambdas |
| `SOLUTIONS_TABLE_NAME` | `/amatra/{env}/dynamodb/solutions-table-name` | `amatra-prod-ddb-solutions` | All |
| `USERS_TABLE_NAME` | `/amatra/{env}/dynamodb/users-table-name` | `amatra-prod-ddb-users` | Post-Confirm, Profile |
| `GLOBAL_QUOTA_TABLE_NAME` | `/amatra/{env}/dynamodb/global-quota-table-name` | `amatra-prod-ddb-global-quota` | Solution Create |
| `COGNITO_USER_POOL_ID` | `/amatra/{env}/cognito/user-pool-id` | `us-west-2_AbCdEfGhI` | Auth Refresh |
| `GITHUB_PAT_SECRET_NAME` | `/amatra/{env}/secrets/github-pat-name` | `amatra/prod/github/pat` | GitHub Integration |
| `CLOUDWATCH_METRICS_NAMESPACE` | `/amatra/{env}/cloudwatch/metrics-namespace` | `Amatra/TokenUsage` | Agent Lambdas |
| `ENVIRONMENT` | `/amatra/{env}/platform/environment` | `prod` | All |
| `LOG_LEVEL` | `/amatra/{env}/platform/log-level` | `info` | All |

## CLI Configuration

After pip installation, consultants configure the CLI with their Cognito credentials and the platform API URL.

```bash
# Install the CLI
pip install amatra-cli

# Configure the CLI for production
amatra configure \
  --api-url https://api.amatra.predictif.com \
  --region us-west-2

# Authenticate (prompts for username and password)
amatra auth login

# Verify authentication succeeded
amatra auth status
# Expected output:
# Authenticated as: marcus.patel@predictif.com
# Token expires: 2026-04-15T11:00:00Z
# Quota remaining: 8/10 solutions this month

# Generate a presales bundle from a brief file
amatra solution generate \
  --brief my-client-brief.json \
  --wait

# Check generation status
amatra solution status <solution-id>

# Download all artifacts
amatra artifact download <solution-id> --output ./my-client-artifacts/
```

## GitHub Integration Configuration

The GitHub integration Lambda uses the PAT stored in Secrets Manager to commit all twelve artifacts to the fixed public repository. Configure the integration as follows:

```bash
# Verify the PAT can authenticate to the repository
GITHUB_PAT=$(aws secretsmanager get-secret-value \
  --secret-id "amatra/${ENVIRONMENT}/github/pat" \
  --region us-west-2 \
  --query 'SecretString' \
  --output text)

# Test repository access
curl -s -H "Authorization: token ${GITHUB_PAT}" \
  "https://api.github.com/repos/predictif-solutions/amatra-artifacts" \
  --query '.permissions' 2>/dev/null | python3 -c "import sys, json; d=json.load(sys.stdin); print('Push:', d.get('push', False))"
# Expected: Push: True

unset GITHUB_PAT
```

---

# Integration Testing

This section defines the end-to-end integration testing procedures that validate every component of the Amatra Agentic Orchestration Platform before UAT and production deployment. All tests are executed in the staging environment against live AWS services.

## Integration Test Strategy

The integration test suite covers six test disciplines. Each test category has defined pass/fail criteria that serve as phase gates. All integration tests must pass before UAT coordination begins with Marcus Patel.

The following table summarises the test phases, scope, tooling, and pass criteria:

| Test Phase | Scope | Tooling | Pass Criteria |
|------------|-------|---------|---------------|
| Artifact Generation (E2E) | All 12 artifact types; format-check + LLM quality gate; eof-tools converter pipeline | `pytest`, live Bedrock API, staging environment | ≥ 95% first-attempt pass rate across 12 artifact types |
| API Route Testing | All 11 Lambda routes; JWT auth; request/response validation; error codes | `httpx` (Python), Postman, `curl` | 100% of routes return correct response shapes; `401` for unauthenticated; correct error codes |
| Quota Enforcement Testing | Per-user (10/month) and global (1,000/month) atomic enforcement under concurrency | `locust` (Python), 20 concurrent users | Zero quota bypass events; correct `429` responses when limits reached |
| CLI Subcommand Testing | All 14 CLI subcommands; JWT token lifecycle; `--api-url` flag | `pytest` CLI integration tests | All 14 subcommands execute without errors against staging endpoint |
| Security Testing | JWT bypass, WAF rules, IAM escalation, Secrets Manager access control | `curl`, AWS IAM Access Analyzer, manual JWT manipulation | Zero successful bypass attempts; WAF blocks all test SQLi/XSS payloads |
| Terraform Validate Gate | Code Generator agent output; all 5 Terraform IaC modules | `terraform validate` subprocess in Code Generator agent | `terraform validate` passes on all generated `.tf` files; zero syntax errors |

## End-to-End Artifact Generation Tests

The end-to-end test suite generates a complete 12-artifact bundle using three representative client briefs from Marcus Patel's team — one AI/ML engagement, one cloud infrastructure engagement, and one security engagement.

```bash
# Navigate to the integration test directory
cd tests/integration/

# Run the full artifact generation test suite against staging
pytest test_artifact_generation.py \
  --environment staging \
  --brief-fixtures fixtures/ai-ml-brief.json fixtures/cloud-infra-brief.json fixtures/security-brief.json \
  --timeout 3600 \
  --verbose \
  --junit-xml results/artifact-generation-results.xml

# Check pass rate from results
python3 scripts/calculate_pass_rate.py results/artifact-generation-results.xml
# Expected: Pass rate >= 95% on first attempt
```

## API Route Validation Tests

Each of the 11 Lambda routes is tested for correct authentication, request validation, and response shape.

```bash
# Run the API route test suite
pytest test_api_routes.py \
  --api-url https://api-staging.amatra.predictif.com \
  --test-user-token $(amatra auth login --output token) \
  --admin-token $(amatra auth login --username admin@predictif.com --output token) \
  --verbose \
  --junit-xml results/api-route-results.xml

# Specifically test quota enforcement
pytest test_quota_enforcement.py \
  --concurrency 20 \
  --requests-per-user 11 \
  --verbose
# Expected: users 1-10 succeed; request 11 returns 429 for each user
```

## Performance and Load Test Procedures

Load testing validates the platform's behaviour under the expected steady-state throughput of 200 solutions per month, with burst testing simulating peak concurrent submissions.

```bash
# Run the load test with locust
locust \
  --locustfile tests/load/locustfile.py \
  --host https://api-staging.amatra.predictif.com \
  --users 20 \
  --spawn-rate 2 \
  --run-time 60m \
  --headless \
  --csv results/load-test

# Review results
python3 scripts/analyze_load_results.py results/load-test_stats.csv
# Expected:
# - No DynamoDB quota bypass events
# - p95 latency for /v1/quota endpoint < 500ms
# - Zero Lambda throttling events
# - All 20 concurrent solution submits tracked independently in DynamoDB
```

## Test Results Documentation

All test results are documented in the Test Results Report (Deliverable 19). The report includes:

- [ ] Artifact generation pass rate by artifact type (target: ≥ 95%)
- [ ] API route test results: pass/fail per endpoint with response time measurements
- [ ] Quota enforcement validation: zero bypass events confirmed under 20-user concurrent load
- [ ] CLI subcommand test results: all 14 subcommands exercised
- [ ] Security test findings: zero open critical or high severity findings
- [ ] Terraform validate gate results: all Code Generator outputs passing
- [ ] End-to-end latency measurement: average, p95, and maximum generation time for 12-artifact bundle

---

# Security Validation

This section defines security testing procedures and validation gates that must all pass before production deployment is authorised. Security validation is a mandatory Phase 4 gate — no production `terraform apply` proceeds with open critical or high security findings.

## Identity and Access Validation

The following security quality gates validate all IAM, Cognito, and JWT security controls.

### Phase 1 Security Quality Gate (Infrastructure)

- [ ] IAM Access Analyzer reports zero active findings for all Lambda execution roles
- [ ] No Lambda execution role contains wildcard (`*`) resource ARNs — verified by Config rule
- [ ] AWS Config rule `LAMBDA_FUNCTION_SETTINGS_CHECK` passing for all functions
- [ ] Cognito User Pool MFA configuration confirmed as per CTO-approved design
- [ ] CTO sign-off document (`amatra-cto-cognito-signoff.pdf`) on file before production apply

### Phase 2 Security Quality Gate (Application)

- [ ] JWT bypass testing: expired tokens, wrong-key-signed tokens, and `sub`-manipulated tokens all receive `401`
- [ ] WAF blocks requests with SQLi payloads (test: `' OR 1=1 --`) with `403` response
- [ ] WAF blocks requests with XSS payloads (test: `<script>alert(1)</script>`) with `403` response
- [ ] WAF IP rate limiting blocks 101st request from same IP within 1 minute with `429` response
- [ ] Secrets Manager access: GitHub PAT `GetSecretValue` restricted to GitHub Integration Lambda role only

### Phase 3 Security Quality Gate (Pre-Production)

- [ ] All security test cases from Deliverable 18 (Test Plan) executed in staging
- [ ] Zero open critical or high-severity security findings
- [ ] CloudTrail captures all `GetSecretValue` calls to `amatra/prod/github/pat`
- [ ] No Lambda environment variables contain secret values — all secrets sourced from Secrets Manager
- [ ] DynamoDB tables confirm no public access or unintended cross-account access

### Phase 4 Security Quality Gate (Go-Live)

- [ ] Production Terraform plan reviewed and approved by Solution Architect
- [ ] Production CloudTrail logging confirmed active before go-live window opens
- [ ] WAF WebACL attached to production API Gateway stage ARN
- [ ] All CloudWatch security alarms in `OK` state with SNS notifications confirmed
- [ ] Go-live approval sign-off from Marcus Patel (UAT) and CTO (production deployment) obtained

## Security Monitoring Validation

The following commands validate that all detective controls are active and alerting correctly.

```bash
# Verify CloudTrail is logging data events for S3 artifacts bucket
aws cloudtrail get-event-selectors \
  --trail-name amatra-${ENVIRONMENT}-cloudtrail \
  --region us-west-2 \
  --query 'EventSelectors[].{ReadWrite:ReadWriteType,Resources:DataResources}'

# Verify CloudWatch alarm for suspicious Secrets Manager access
aws cloudwatch describe-alarms \
  --alarm-names "amatra-${ENVIRONMENT}-secrets-manager-unexpected-access" \
  --region us-west-2 \
  --query 'MetricAlarms[0].{State:StateValue,AlarmActions:AlarmActions}'

# Run IAM Access Analyzer for final pre-production check
aws accessanalyzer start-resource-scan \
  --analyzer-arn $(terraform output -raw access_analyzer_arn) \
  --resource-arn $(terraform output -raw lambda_solution_create_arn) \
  --region us-west-2

# Wait for scan to complete and check for findings
sleep 30
aws accessanalyzer list-findings \
  --analyzer-arn $(terraform output -raw access_analyzer_arn) \
  --filter '{"status":{"eq":["ACTIVE"]}}' \
  --region us-west-2
# Expected: empty findings list
```

## Security Metrics

The following security metrics are tracked and reported in the Test Results Report:

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| JWT Bypass Success Rate | 0% | Manual testing with expired/invalid tokens |
| WAF Block Rate (SQLi/XSS) | 100% of injected test payloads | WAF CloudWatch `BlockedRequests` metric |
| IAM Wildcard Resource ARNs | 0 violations | AWS Config rule + IAM Access Analyzer |
| Secrets in Lambda Env Vars | 0 occurrences | Automated scan of Lambda configurations |
| CloudTrail Coverage | 100% of API calls captured | CloudTrail health check |
| Open Critical/High Findings | 0 at go-live | Security test results report |

---

# Migration & Cutover

## Migration Approach

The Amatra Agentic Orchestration Platform is a greenfield implementation — no existing production platform data requires migration. The legacy laptop-based Claude Code CLI workflow continues to operate in parallel throughout the twelve-week engagement; consultants transition to the new platform after go-live, not before.

**Type:** Greenfield parallel operation — no data migration required
**Historical Data:** Existing OneDrive artifact storage is explicitly out of scope per SOW; historical artifacts remain in OneDrive and are not migrated to S3

The only data bootstrap required before go-live is loading the EO Framework guidance files to S3 (Dependency D3 in the SOW — client responsibility due by Week 4).

```bash
# Load EO Framework guidance files to S3 (client provides files; vendor executes upload)
aws s3 sync ./eo-framework-guidance/ \
  s3://amatra-prod-s3-guidance-${AWS_ACCOUNT_ID}/guidance/ \
  --region us-west-2 \
  --exclude "*.DS_Store" \
  --exclude "*.git*"

# Verify guidance file count
aws s3 ls s3://amatra-prod-s3-guidance-${AWS_ACCOUNT_ID}/guidance/ --recursive | wc -l
# Expected: all guidance files present (verify count matches the file inventory)
```

## Cutover Plan

The production cutover follows a blue-green approach targeting a Tuesday morning Pacific Time window during Week 11.

| Step | Activity | Owner | Duration | Rollback Trigger |
|------|----------|-------|----------|-----------------|
| Pre-Cutover | Confirm all go-live readiness criteria met (checklist below) | Vendor PM | Morning before cutover | Incomplete checklist = postpone |
| Pre-Cutover | Confirm CTO sign-off document on file | Vendor PM | — | Missing sign-off = postpone |
| Cutover Start | Execute `terraform apply` against production workspace | DevOps Eng | ~20 minutes | Terraform error = immediate rollback |
| Cutover | Run 5-command production smoke test suite | QA Eng | ~30 minutes | Any smoke test fail = rollback |
| Go/No-Go | Vendor PM + Marcus Patel review smoke test results | PM + Client | ~15 minutes | Failed result = rollback |
| Go-Live | Update API Gateway stage to LIVE Lambda alias | DevOps Eng | ~5 minutes | — |
| Go-Live | Publish CLI pip package to PyPI | DevOps Eng | ~10 minutes | — |
| Go-Live | Send onboarding notification to 120 consultants | Vendor PM | ~15 minutes | — |
| Go-Live | Notify Sarah Lin, Marcus Patel, Daniel Park | Vendor PM | ~5 minutes | — |

### Go/No-Go Criteria

The following criteria must all be satisfied before the Go/No-Go decision is made:

- [ ] All unit and integration tests passing in staging with zero critical defects open
- [ ] End-to-end generation of a full 12-artifact bundle completing in under 60 minutes in staging
- [ ] CloudWatch green baseline in staging: Lambda error rate < 1%, DynamoDB throttles = 0, API Gateway 4xx < 2%
- [ ] Security testing complete with zero open critical or high-severity findings
- [ ] UAT sign-off from Marcus Patel confirmed in writing
- [ ] CTO sign-off on Cognito User Pool configuration confirmed in writing
- [ ] Operational runbooks reviewed and approved by Daniel Park
- [ ] Production Terraform plan reviewed and approved by Solution Architect
- [ ] SNS ops alert topic subscriptions confirmed for Daniel Park
- [ ] Stakeholder communication plan for go-live ready for execution

### Production Smoke Test Suite

The five-command smoke test suite is executed immediately after production deployment and before the Go/No-Go decision:

```bash
# Smoke Test 1: Authentication
amatra auth login \
  --username smoke.test@predictif.com \
  --api-url https://api.amatra.predictif.com
echo "SMOKE TEST 1: auth login — PASS"

# Smoke Test 2: Solution Generation
SOLUTION_ID=$(amatra solution generate \
  --brief tests/fixtures/smoke-test-brief.json \
  --api-url https://api.amatra.predictif.com \
  --output json | python3 -c "import sys, json; print(json.load(sys.stdin)['solutionId'])")
echo "SMOKE TEST 2: solution generate — SOLUTION_ID=${SOLUTION_ID}"

# Smoke Test 3: Solution Status
amatra solution status ${SOLUTION_ID} \
  --api-url https://api.amatra.predictif.com
echo "SMOKE TEST 3: solution status — PASS"

# Smoke Test 4: Artifact Download (run after generation completes)
amatra artifact download ${SOLUTION_ID} \
  --output /tmp/smoke-test-artifacts/ \
  --api-url https://api.amatra.predictif.com
echo "SMOKE TEST 4: artifact download — PASS"

# Smoke Test 5: Admin Usage
amatra admin usage \
  --api-url https://api.amatra.predictif.com
echo "SMOKE TEST 5: admin usage — PASS"
```

## Rollback Procedures

If the production smoke tests fail or a Severity 1 defect is identified within the first 24 hours of go-live, execute the following rollback procedure:

```bash
# Step 1: Repoint API Gateway stage to previous Lambda alias (< 5 minutes)
aws apigatewayv2 update-stage \
  --api-id ${API_GATEWAY_ID} \
  --stage-name prod \
  --default-route-settings '{"ThrottlingBurstLimit":10000,"ThrottlingRateLimit":5000}' \
  --region us-west-2

# Update the Lambda alias to point to the previous version
aws lambda update-alias \
  --function-name amatra-prod-lambda-solution-create \
  --name LIVE \
  --function-version ${PREVIOUS_VERSION} \
  --region us-west-2

# Step 2: Notify all stakeholders via SNS
aws sns publish \
  --topic-arn ${SNS_OPS_TOPIC_ARN} \
  --subject "ALERT: Amatra Platform Production Rollback Initiated" \
  --message "Production rollback initiated at $(date -u). API traffic reverted to Lambda version ${PREVIOUS_VERSION}. Staging environment available at api-staging.amatra.predictif.com. Consultants: use --api-url https://api-staging.amatra.predictif.com until further notice." \
  --region us-west-2

# Step 3: If DynamoDB data corruption detected, restore from PITR
# (Only if data integrity issue confirmed — consult Solution Architect before executing)
aws dynamodb restore-table-to-point-in-time \
  --source-table-name amatra-prod-ddb-solutions \
  --target-table-name amatra-prod-ddb-solutions-restored \
  --restore-date-time ${PRE_CUTOVER_TIMESTAMP} \
  --region us-west-2

# Step 4: Communicate revised go-live timeline to Sarah Lin within 2 hours
```

---

# Operational Handover

## Documentation Handover

The following documentation artifacts are delivered to PREDICTif Solutions as part of the formal handover package at Week 12. All documents are committed to the designated Git repository in both source markdown and converted PDF/DOCX formats.

- [ ] **As-Built Architecture Documentation** (Deliverable 23): Complete architecture diagrams (draw.io source + PNG), IAM policy inventory, DynamoDB table schemas, S3 bucket layout, and Cognito User Pool configuration
- [ ] **API Reference** (Deliverable 23): OpenAPI 3.0 specification for all 11 Lambda routes, including request/response schemas, authentication requirements, error codes, and example payloads
- [ ] **CLI Command Reference** (Deliverable 23): Complete documentation for all 14 subcommands with usage examples, flag descriptions, authentication flow, and troubleshooting guidance
- [ ] **Operator Guide** (Deliverable 22): Step-by-step procedures for all routine operational tasks — user provisioning, quota management, Bedrock model updates, and platform scaling
- [ ] **User Onboarding Guide**: Consultant-facing guide for CLI installation (`pip install amatra-cli`), Cognito account creation, first solution generation, and artifact download
- [ ] **Operational Runbooks** (Deliverable 22): Four runbooks covering agent failure recovery, quota reset procedures, GitHub PAT rotation, and AgentCore Runtime image update
- [ ] **Terraform Configuration**: All Terraform modules and workspace configurations for dev, staging, and production environments committed to the agreed Git repository
- [ ] **Test Results Report** (Deliverable 19): Complete test execution results including pass/fail rates by artifact type, load test metrics, security test findings, and UAT sign-off
- [ ] **Phase 2 Optimisation Recommendations** (Deliverable 25): Documented roadmap for parallel pipeline throughput improvements, multi-region expansion, additional artifact types, and cost optimisation

## Support Transition

### Support Model

The following support tiers define responsibility, response time, and escalation path during hypercare and post-hypercare BAU operations:

| Tier | Responsibility | Response Time | Escalation Path |
|------|----------------|---------------|-----------------|
| L1 — Vendor Hypercare | Initial triage of production issues; known issue resolution; agent prompt tuning | Sev1: 2 hours; Sev2: 4 hours; Sev3: next business day | To L2 Vendor Arch after 2 hours for Sev1 |
| L2 — Vendor Architecture | Technical deep-dives; code-level defect resolution; infrastructure configuration fixes | 4 hours for Sev1 escalations | To vendor ML/AI Eng for agent-specific issues |
| L3 — AWS Support | AWS service issues (Bedrock, DynamoDB, Lambda, Cognito); AWS-side quota raises | < 1 hour critical response (Business Support SLA) | Direct case on the AWS console |
| BAU — PREDICTif Ops | Post-hypercare: all operational tasks using delivered runbooks; L1 triage via runbooks | Per PREDICTif's internal SLAs | To AWS Support (L3) for service-level issues |

### Escalation Path

During the four-week hypercare period, all Severity 1 and Severity 2 issues are reported via the following escalation path:

1. **Detection:** CloudWatch Alarm fires → SNS → Daniel Park email notification
2. **Triage (0–15 min):** Daniel Park reviews CloudWatch dashboard (Platform Health view) and applies runbook procedure
3. **Escalation (15 min):** If unresolved after first runbook attempt, Daniel Park contacts the Vendor PM via the agreed hypercare Slack channel
4. **Vendor Response (Sev1 ≤ 2 hours, Sev2 ≤ 4 hours):** Vendor Architect and appropriate engineer join the incident bridge
5. **Resolution:** Vendor team implements fix and confirms green CloudWatch metrics
6. **Post-Incident:** Vendor team provides a concise RCA report within 24 hours of resolution

## Hypercare Period

The four-week hypercare support period commences immediately following production go-live (targeted Week 12 start). Hypercare provides vendor reactive support and proactive platform health monitoring.

- **Duration:** 4 weeks post-go-live (Weeks 12–16); as committed in the SOW
- **Coverage:** Business hours, 08:00 AM – 06:00 PM Pacific Time, Monday to Friday
- **Response Times:** Severity 1 (platform down, generation completely blocked) — 2-hour response and workaround; Severity 2 (generation degraded, individual artifact type failing) — 4-hour response; Severity 3 (cosmetic issues, documentation queries) — next business day
- **In Scope:** Defects in delivered platform code and configuration; agent prompt tuning; quota adjustments; GitHub commit troubleshooting
- **Not in Scope:** New feature requests, new artifact types, additional CLI subcommands, or EO Framework guidance file updates

## Handover Checklist

The following checklist must be completed before the formal project acceptance sign-off is obtained from Sarah Lin:

- [ ] All documentation (Deliverables 22, 23, 25) delivered to agreed Git repository and accepted by Marcus Patel
- [ ] All four knowledge transfer sessions completed (Session 1–4; see Training Program section)
- [ ] Operational runbooks validated through dry-run exercises with Daniel Park's Delivery Operations team
- [ ] CloudWatch dashboards walked through with Daniel Park; all four dashboards confirmed populating correctly
- [ ] Monitoring alarms reviewed: SNS email subscriptions confirmed for Daniel Park; test alarm confirmed delivered
- [ ] Vendor admin IAM access revoked from production; `admin` Cognito group transferred to Daniel Park's team
- [ ] Emergency contacts documented and distributed: Vendor PM mobile, Vendor Architect email, AWS Support case portal
- [ ] CLI PyPI package publication confirmed: `pip install amatra-cli` installs current version
- [ ] 90% effort-reduction metric validated: three representative solutions generated in under 60 minutes each
- [ ] Formal Project Acceptance and Closeout Report (Deliverable 26) signed by Sarah Lin

---

# Training Program

## Training Overview

### Objectives

The training program ensures all user groups at PREDICTif Solutions achieve competency with the Amatra Agentic Orchestration Platform before go-live and establishes ongoing learning paths for new team members. The program covers platform administrators (Daniel Park's team), pre-sales consultants (Marcus Patel's team), IT support staff, and internal trainers who will onboard the broader 120-consultant organisation.

### Training Approach

- **Phased Delivery:** Training sessions are delivered in alignment with the Week 12 handover schedule — administrator sessions first, then consultant sessions, then the train-the-trainer workshop
- **Role-Based Content:** Each module is tailored to the specific responsibilities and daily workflows of the target audience
- **Hands-On Focus:** All technical modules include live exercises in the staging sandbox environment, ensuring consultants practice real workflows before using the production platform
- **Recorded for Async Reference:** All sessions are recorded (with participant consent) and made available in PREDICTif's internal learning repository within 48 hours of session delivery
- **Sandbox Access:** Consultants receive staging environment credentials two weeks before go-live for self-directed practice

## Training Schedule

The following table summarises all ten training modules, their target audiences, durations, and delivery formats:

| Module ID | Module Name | Target Audience | Duration | Format | Prerequisites |
|-----------|-------------|-----------------|----------|--------|---------------|
| TRN-001 | Platform Architecture Overview | Administrators, IT Support | 2 hours | ILT (Session 1) | None |
| TRN-002 | CLI Installation and Authentication | All consultants, Admins | 1.5 hours | VILT (Session 2) | TRN-001 |
| TRN-003 | Generating Your First Presales Bundle | Pre-Sales Consultants | 2 hours | Hands-On Lab (Session 2) | TRN-002 |
| TRN-004 | Operations and Administration | Delivery Operations team | 2 hours | ILT + Hands-On (Session 3) | TRN-001 |
| TRN-005 | Runbook Execution and Incident Response | Delivery Operations team | 1.5 hours | Hands-On Lab (Session 3) | TRN-004 |
| TRN-006 | Admin API and Quota Reporting | Admins, Daniel Park | 1 hour | ILT (Session 4) | TRN-004 |
| TRN-007 | Artifact Review and Quality Standards | Pre-Sales Consultants | 1.5 hours | VILT | TRN-003 |
| TRN-008 | API Integration and Developer Guide | IT Support | 2 hours | Hands-On Lab | TRN-001 |
| TRN-009 | Troubleshooting and Diagnostics | IT Support, Admins | 1.5 hours | ILT | TRN-005 |
| TRN-010 | Train-the-Trainer Workshop | Internal Trainers (Marcus Patel's nominees) | 4 hours | Workshop | All modules |

## Administrator Training

### TRN-001: Platform Architecture Overview (2 hours, ILT)

**Learning Objectives:**
- Describe the five-agent Strands multi-agent graph architecture and explain how each agent contributes to the 12-artifact output
- Navigate the CloudWatch Platform Health dashboard and interpret Lambda error rate, DynamoDB throttle, and API Gateway 4xx metrics
- Explain the Cognito User Pool authentication flow and the JWT access/refresh token lifecycle
- Identify the three DynamoDB tables and explain their roles in quota enforcement and solution state management

**Content Outline:**
1. Platform architecture walkthrough (40 min) — five-agent graph, AgentCore Runtime, API Gateway → Lambda → DynamoDB → Bedrock data flow, S3 artifact storage, GitHub commit pipeline
2. CloudWatch dashboard tour (30 min) — live tour of all four dashboards; interpreting green vs. alert states
3. Security architecture overview (25 min) — Cognito JWT perimeter, WAF, Secrets Manager, CloudTrail, IAM roles
4. Q&A and discussion (25 min)

**Materials Required:**
- Presentation slides (as-built architecture diagrams)
- Access to CloudWatch console (read-only for trainees)
- Architecture diagram handout (from As-Built Documentation)

### TRN-002: CLI Installation and Authentication (1.5 hours, VILT)

**Learning Objectives:**
- Install the `amatra-cli` pip package and configure it for the production endpoint
- Complete the Cognito authentication flow (`amatra auth login`) and manage the `~/.amatra/credentials` token store
- Navigate the fourteen CLI subcommands and identify the appropriate command for each workflow task
- Handle token expiry and re-authentication without manual intervention

**Content Outline:**
1. CLI installation and configuration (20 min) — `pip install amatra-cli`; `amatra configure`; credential file location
2. Authentication walkthrough (25 min) — `auth login`; token lifecycle; `auth status`; `auth logout`
3. Subcommand tour (30 min) — all 14 subcommands overview; `--help` flag usage; `--api-url` override for staging
4. Live Q&A (15 min)

**Lab Exercises:**
- Exercise 1: Install the CLI and authenticate using provided staging credentials
- Exercise 2: Run `amatra auth status` and interpret the output (token expiry, quota remaining)
- Exercise 3: List all solutions using `amatra solution list`

**Materials Required:**
- Staging environment CLI credentials (distributed before session)
- Quick reference card for all 14 subcommands

### TRN-003: System Configuration (4 hours, Hands-On Lab)

**Learning Objectives:**
- Manage Cognito User Pool groups (`consultants` and `admin`) via the AWS console and CLI
- Perform per-user and global quota adjustments using `POST /admin/quota/reset`
- Configure SSM Parameter Store values for environment-specific Lambda configuration
- Execute the GitHub PAT rotation procedure from the operational runbook without service interruption

**Content Outline:**
1. Cognito user management (60 min) — adding/removing users; group assignments; resetting passwords
2. Quota management (45 min) — viewing quota consumption via admin dashboard; per-user override; global reset procedures
3. SSM Parameter Store configuration (45 min) — parameter naming conventions; updating values; triggering Lambda re-init
4. GitHub PAT rotation runbook walkthrough (45 min) — rotating PAT in Secrets Manager; verifying commit pipeline continuity
5. Lab exercises (45 min)

**Lab Exercises:**
- Exercise 1: Add a test user to the `consultants` Cognito group and verify their API access
- Exercise 2: Reset a user's monthly quota counter using `POST /admin/quota/reset`
- Exercise 3: Update an SSM parameter and observe the Lambda configuration change

### TRN-004: Backup and Recovery (2 hours, VILT)

**Learning Objectives:**
- Identify the backup mechanisms for each platform data store (DynamoDB PITR, S3 versioning, ECR image digests)
- Execute a DynamoDB point-in-time recovery to restore a table to a specific timestamp
- Recover a versioned S3 artifact from a previous object version
- Confirm RTO (2 hours) and RPO (1 hour) targets are achievable with the documented procedures

**Content Outline:**
1. Backup architecture overview (20 min) — DynamoDB PITR, S3 versioning, ECR digest immutability
2. DynamoDB PITR recovery demonstration (40 min) — console walkthrough of table restoration; validation of recovered data
3. S3 versioned artifact recovery (25 min) — listing object versions; restoring a specific version via CLI
4. DR scenario walkthrough (25 min) — simulated Severity 1 event; step-by-step recovery using runbook
5. Q&A (10 min)

**Materials Required:**
- Operational runbook (agent failure recovery + backup/restore procedures section)
- Staging DynamoDB table with sample data for recovery exercise

## End User Training

### TRN-005: Core Functionality — Generating Your First Presales Bundle (1.5 hours, VILT)

This module is the primary end-user training session for PREDICTif's pre-sales consultants. It focuses entirely on the workflow consultants will perform daily: submitting a client brief, monitoring generation progress, and downloading the resulting presales bundle.

**Learning Objectives:**
- Construct a valid EO Framework client brief JSON using the provided template
- Submit a solution generation request via `amatra solution generate` and monitor its progress
- Download completed artifacts using `amatra artifact download` and identify each of the five presales documents
- Interpret generation status codes (`PENDING`, `IN_PROGRESS`, `COMPLETE`, `VALIDATION_FAILED`) and take appropriate action
- Manage quota consumption and check remaining monthly allowance via `amatra auth status`

**Content Outline:**
1. Client brief JSON structure (20 min) — required fields (client name, provider, category, solution description, discovery answers); template walkthrough; common validation errors
2. Generation workflow demonstration (30 min) — live generation of a sample presales bundle; status monitoring; expected completion time (under 60 minutes)
3. Artifact download and review (25 min) — `amatra artifact download`; five presales documents overview; quality review checklist
4. Quota management and troubleshooting (15 min) — checking quota; what happens at the limit; how to request a quota override
5. Q&A and practice time (10 min)

**Lab Exercises:**
- Exercise 1: Using the provided brief template, create `my-first-brief.json` for a hypothetical client
- Exercise 2: Submit the brief using `amatra solution generate --brief my-first-brief.json`
- Exercise 3: Monitor status with `amatra solution status {id}` until `COMPLETE`
- Exercise 4: Download artifacts to a local directory and open the statement-of-work.md file

**Materials Required:**
- Client brief JSON template (`brief-template.json`)
- Staging environment credentials (pre-issued 2 weeks before session)
- Quick reference card: 14 CLI subcommands with one-line descriptions
- FAQ document: top 10 questions from the UAT sessions

### TRN-006: Data Entry and Processing — Crafting Effective Client Briefs (2 hours, Hands-On Lab)

**Learning Objectives:**
- Write high-quality discovery questionnaire answers that result in higher first-attempt validation pass rates
- Identify the six required fields in the client brief schema and explain the impact of each on artifact quality
- Troubleshoot `VALIDATION_FAILED` status events using the error envelope returned by the EO Validator Agent
- Re-submit a corrected brief after addressing validation feedback without generating a duplicate solution

**Content Outline:**
1. Brief schema deep-dive (30 min) — field definitions; validation rules; schema version history
2. Quality factors for high pass-rate briefs (40 min) — discovery answer completeness; provider-specific context; solution description richness
3. Interpreting validation feedback (25 min) — EO Validator error envelope structure; `format_check` vs. `quality_check` errors; corrective actions
4. Lab: fix-a-failing-brief exercise (25 min)

**Lab Exercises:**
- Exercise 1: Review three sample briefs (good, mediocre, poor) and rank them by expected pass rate
- Exercise 2: Submit the "poor" brief, receive a `VALIDATION_FAILED` response, correct the issues, and re-submit

## Power User Training

### TRN-007: Reporting and Analytics — Artifact Review and Quality Standards (1.5 hours, VILT)

**Learning Objectives:**
- Access and interpret the CloudWatch Solution Throughput and Cost Telemetry dashboards for executive reporting
- Calculate per-solution Bedrock token spend from the `GET /admin/usage` endpoint response
- Identify the EO Framework quality criteria for each of the five presales artifact types
- Escalate artifact quality concerns to the platform administration team with the required diagnostic information

**Content Outline:**
1. CloudWatch throughput and cost dashboards (30 min) — live dashboard walkthrough; exporting metrics to CSV; building exec summary tables
2. Admin usage API walkthrough (25 min) — `GET /admin/usage` response structure; per-phase token breakdown; month-over-month trend
3. EO Framework quality standards overview (25 min) — required YAML frontmatter; H1 section requirements; table format; image references
4. Quality escalation procedure (10 min) — when and how to flag a low-quality artifact for platform team review

## IT Support Training

### TRN-008: API Integration and Developer Guide (2 hours, Hands-On Lab)

**Learning Objectives:**
- Authenticate to the REST API using Cognito JWT tokens obtained via the Cognito USER_PASSWORD_AUTH flow
- Construct valid `POST /v1/solution` request payloads and interpret the `solutionId` response for downstream automation
- Use all 11 API endpoints via `curl` or an HTTP client library with correct `Authorization: Bearer` header handling
- Monitor API health using CloudWatch API Gateway metrics and interpret 4xx/5xx error spikes

**Content Outline:**
1. API architecture and authentication flow (30 min) — Cognito JWT issuance; `Authorization: Bearer` header; token refresh flow
2. Solution generation API walkthrough (40 min) — `POST /v1/solution`; status polling pattern; artifact download via presigned URL
3. Admin API endpoints (25 min) — `GET /admin/usage`; `POST /admin/quota/reset`; admin group requirement
4. Error codes and troubleshooting (25 min) — `401`, `403`, `429`, `500` response handling; CloudWatch Logs for Lambda error detail

**Lab Exercises:**
- Exercise 1: Obtain a Cognito JWT access token using `curl` against the Cognito token endpoint
- Exercise 2: Submit a solution generation request via `POST /v1/solution` using the JWT
- Exercise 3: Poll `GET /v1/solution/{solutionId}` until `COMPLETE` and download an artifact using the presigned URL

### TRN-009: Troubleshooting and Diagnostics (1.5 hours, ILT)

**Learning Objectives:**
- Diagnose common platform issues using the four CloudWatch dashboards and structured Lambda logs
- Apply the four operational runbooks (agent failure recovery, quota reset, PAT rotation, image update) to common incident scenarios
- Distinguish between issues attributable to the platform vs. issues attributable to input brief quality or Bedrock service availability
- Escalate incidents to the vendor team (during hypercare) or AWS Support (post-hypercare) with the correct diagnostic information

**Content Outline:**
1. Diagnostic workflow overview (20 min) — start with CloudWatch Platform Health dashboard; follow the alert → logs → runbook chain
2. Common issue patterns (40 min) — agent timeout; `VALIDATION_FAILED` after 3 retries; GitHub commit failure; quota enforcement errors; Bedrock throttling
3. Runbook walkthrough (30 min) — hands-on walkthrough of all four runbooks in the staging environment
4. Escalation procedure (10 min) — what to include in a vendor escalation; what to include in an AWS Support case

## Train-the-Trainer

### TRN-010: Train-the-Trainer Workshop (4 hours, Workshop)

**Learning Objectives:**
- Deliver all end-user training modules (TRN-002, TRN-003, TRN-005, TRN-006) independently to new consultant cohorts
- Facilitate the hands-on lab exercises and answer consultant questions about brief quality and artifact interpretation
- Set up and reset the staging sandbox environment for new cohort onboarding sessions
- Assess learner competency using the provided knowledge check rubric and practical observation checklist

**Content Outline:**
1. Facilitator guide walkthrough (60 min) — session flow, timing, common questions and model answers for each module
2. Dry-run delivery exercise (90 min) — each nominated trainer delivers a 20-minute segment; peer feedback; facilitator coaching
3. Lab environment management (30 min) — creating test Cognito accounts; resetting quota counters; preparing sample briefs
4. Competency assessment techniques (30 min) — knowledge check quizzes; practical observation rubric; coaching techniques
5. Ongoing support and questions (30 min)

**Materials Required:**
- Complete facilitator guides for TRN-002, TRN-003, TRN-005, TRN-006
- Knowledge check quizzes and answer keys
- Practical observation rubric for lab exercises
- Staging environment admin access (to create/reset test accounts)
- All quick reference cards, FAQ documents, and brief templates

## Training Materials

### Documentation Provided

The following materials are delivered as part of the training programme handover:

- CLI Command Reference (PDF and Markdown, 14 subcommands with examples)
- API Reference — OpenAPI 3.0 specification (YAML, viewable in Swagger UI)
- User Onboarding Guide (PDF, 15 pages) — from CLI install to first artifact download
- Administrator Operator Guide (PDF, 30 pages) — all routine tasks, runbooks, quota management
- Quick Reference Cards (per role: Consultant, Administrator, IT Support)
- Video recordings of all four live knowledge transfer sessions (MP4, available within 48 hours of delivery)
- Client brief JSON template and schema documentation
- EO Framework quality standards summary (per artifact type)

### Training Environment

The staging environment serves as the training sandbox:

- Accessible at `https://api-staging.amatra.predictif.com` via the CLI with `--api-url` flag
- Training Cognito accounts provisioned with quota set to 20 (double production limit) to allow practice without hitting limits
- Staging environment contains sample artifacts and representative briefs from the UAT sessions
- Environment is not reset automatically; the operations team resets it as needed using the quota reset runbook

## Training Effectiveness

### Assessment Approach

Each module includes a brief knowledge check to confirm comprehension before participants move on:

- **Knowledge Checks:** 5–10 multiple-choice questions at the end of each module (70% pass required to receive completion confirmation)
- **Practical Assessment (Lab Modules):** Successful completion of all lab exercises as observed by the facilitator
- **Competency Validation (TRN-010):** Nominated trainers must deliver a 20-minute segment with a passing score on the peer feedback rubric

### Success Metrics

| Metric | Target |
|--------|--------|
| Training Completion Rate (go-live cohort) | 100% of Delivery Operations team; 100% of nominated internal trainers; ≥ 10 representative consultants |
| Knowledge Check Pass Rate | ≥ 85% first attempt across all modules |
| Post-Training Satisfaction Survey | ≥ 4.0 / 5.0 |
| Time to First Independent Presales Bundle | ≤ 2 hours from completing TRN-005 |
| Internal Trainer Readiness | All nominated trainers pass TRN-010 peer assessment before broad rollout |

---

# Appendices

## Appendix A: Environment Details

The following tables document the resource identifiers for each deployed environment. Values in brackets are populated after Terraform provisioning and are stored in `infrastructure/outputs/{env}-outputs.json`.

### Development Environment

| Component | Value |
|-----------|-------|
| AWS Account ID | [aws-account-id] |
| Region | us-west-2 |
| Resource Prefix | `amatra-dev` |
| API Gateway Endpoint | `https://[api-id].execute-api.us-west-2.amazonaws.com/dev` |
| Custom Domain | `api-dev.amatra.predictif.com` |
| Cognito User Pool ID | `us-west-2_[pool-id]` |
| S3 Artifacts Bucket | `amatra-dev-s3-artifacts-[account-id]` |
| S3 Guidance Bucket | `amatra-dev-s3-guidance-[account-id]` |
| DynamoDB Solutions Table | `amatra-dev-ddb-solutions` |
| DynamoDB Users Table | `amatra-dev-ddb-users` |
| DynamoDB Global Quota Table | `amatra-dev-ddb-global-quota` |
| ECR Repository | `amatra-dev-ecr-eoframework-agent` |
| SNS Ops Topic ARN | `arn:aws:sns:us-west-2:[account-id]:amatra-dev-ops-alerts` |
| Terraform Workspace | `dev` |
| Terraform State Bucket | `amatra-dev-s3-tfstate-[account-id]` |

### Staging Environment

| Component | Value |
|-----------|-------|
| AWS Account ID | [aws-account-id] |
| Region | us-west-2 |
| Resource Prefix | `amatra-staging` |
| API Gateway Endpoint | `https://[api-id].execute-api.us-west-2.amazonaws.com/staging` |
| Custom Domain | `api-staging.amatra.predictif.com` |
| Cognito User Pool ID | `us-west-2_[pool-id]` |
| S3 Artifacts Bucket | `amatra-staging-s3-artifacts-[account-id]` |
| DynamoDB Solutions Table | `amatra-staging-ddb-solutions` |
| Terraform Workspace | `staging` |
| Terraform State Bucket | `amatra-staging-s3-tfstate-[account-id]` |

### Production Environment

| Component | Value |
|-----------|-------|
| AWS Account ID | [aws-account-id] |
| Region | us-west-2 |
| Resource Prefix | `amatra-prod` |
| API Gateway Endpoint | `https://[api-id].execute-api.us-west-2.amazonaws.com/prod` |
| Custom Domain | `api.amatra.predictif.com` |
| Cognito User Pool ID | `us-west-2_[pool-id]` |
| S3 Artifacts Bucket | `amatra-prod-s3-artifacts-[account-id]` |
| S3 Guidance Bucket | `amatra-prod-s3-guidance-[account-id]` |
| DynamoDB Solutions Table | `amatra-prod-ddb-solutions` |
| DynamoDB Users Table | `amatra-prod-ddb-users` |
| DynamoDB Global Quota Table | `amatra-prod-ddb-global-quota` |
| ECR Repository | `amatra-prod-ecr-eoframework-agent` |
| SNS Ops Topic ARN | `arn:aws:sns:us-west-2:[account-id]:amatra-prod-ops-alerts` |
| GitHub Repository | `https://github.com/predictif-solutions/amatra-artifacts` |
| Terraform Workspace | `prod` |
| Terraform State Bucket | `amatra-prod-s3-tfstate-[account-id]` |
| CTO Sign-Off Document | `amatra-cto-cognito-signoff.pdf` (on file) |

## Appendix B: Configuration Reference

The following table summarises the key configuration parameters from `configuration.csv` relevant to day-to-day operations. Full configuration details are available in the delivered configuration file.

| Parameter | Production Value | Description |
|-----------|-----------------|-------------|
| `quota.user.monthly_solution_limit` | 10 | Per-user monthly solution generation cap |
| `quota.global.monthly_solution_limit` | 1000 | Global monthly solution generation cap |
| `quota.global.alert_threshold_pct` | 90% | Triggers CloudWatch alarm when global quota reaches 900/1000 |
| `integration.bedrock.max_retries_per_artifact` | 3 | EO Validator retry budget per artifact |
| `integration.bedrock.target_cost_per_solution_usd` | $5.00 | Target combined Bedrock model spend per 12-artifact bundle |
| `application.max_solution_generation_minutes` | 60 | End-to-end generation timeout; SOW SLA commitment |
| `operations.hypercare.duration_weeks` | 4 | Post-go-live vendor support period |
| `operations.hypercare.severity1_response_hours` | 2 | Maximum response time for platform-down incidents |
| `monitoring.cloudwatch.log_retention_days` | 30 | Lambda log group retention (production and staging) |
| `monitoring.canary.interval_minutes` | 5 | CloudWatch Synthetic Canary frequency |

## Appendix C: Deployment Scripts

### deploy.sh — Full Platform Deployment

This script performs a complete platform deployment for the specified environment, executing all four infrastructure modules in sequence.

```bash
#!/bin/bash
set -euo pipefail

ENVIRONMENT=${1:-staging}
VERSION=${2:-1.0.0}
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "=== Amatra Agentic Orchestration Platform Deployment ==="
echo "Environment: ${ENVIRONMENT}"
echo "Version: ${VERSION}"
echo "Account: ${AWS_ACCOUNT_ID}"
echo ""

# Pre-deployment checks
echo "[1/6] Running pre-deployment checks..."
terraform fmt -check -recursive infrastructure/
aws sts get-caller-identity > /dev/null
echo "Pre-deployment checks passed."

# Select Terraform workspace
echo "[2/6] Selecting Terraform workspace: ${ENVIRONMENT}"
cd infrastructure/
terraform workspace select ${ENVIRONMENT} || terraform workspace new ${ENVIRONMENT}

# Deploy all four modules in sequence
echo "[3/6] Deploying Networking module..."
terraform apply -var-file=environments/${ENVIRONMENT}.tfvars -target=module.networking -auto-approve

echo "[4/6] Deploying Security module..."
echo "NOTE: For production, confirm CTO sign-off is on file before proceeding."
terraform apply -var-file=environments/${ENVIRONMENT}.tfvars -target=module.security -target=module.iam -auto-approve

echo "[5/6] Deploying Compute module..."
terraform apply -var-file=environments/${ENVIRONMENT}.tfvars \
  -var="lambda_package_version=${VERSION}" \
  -target=module.compute -target=module.ecr -auto-approve

echo "[6/6] Deploying Monitoring module..."
terraform apply -var-file=environments/${ENVIRONMENT}.tfvars -target=module.monitoring -auto-approve

# Save outputs
terraform output -json > ../outputs/${ENVIRONMENT}-outputs.json

echo ""
echo "=== Deployment Complete ==="
echo "API Gateway Endpoint: $(terraform output -raw api_gateway_endpoint)"
echo "Outputs saved to: outputs/${ENVIRONMENT}-outputs.json"
```

### rollback.sh — Emergency Rollback Script

This script performs an emergency rollback by reverting the API Gateway stage to the previous Lambda alias.

```bash
#!/bin/bash
set -euo pipefail

ENVIRONMENT=${1:-prod}
PREVIOUS_VERSION=${2:-}

if [ -z "${PREVIOUS_VERSION}" ]; then
  echo "ERROR: Previous Lambda version is required as the second argument."
  echo "Usage: ./rollback.sh prod <previous-version-number>"
  exit 1
fi

echo "=== Amatra Platform Emergency Rollback ==="
echo "Environment: ${ENVIRONMENT}"
echo "Reverting to Lambda version: ${PREVIOUS_VERSION}"

# Revert Lambda alias
for FUNCTION in solution-create solution-status artifact-fetch; do
  aws lambda update-alias \
    --function-name amatra-${ENVIRONMENT}-lambda-${FUNCTION} \
    --name LIVE \
    --function-version ${PREVIOUS_VERSION} \
    --region us-west-2
  echo "Reverted amatra-${ENVIRONMENT}-lambda-${FUNCTION} to version ${PREVIOUS_VERSION}"
done

# Notify stakeholders
SNS_TOPIC_ARN=$(cat outputs/${ENVIRONMENT}-outputs.json | python3 -c "import sys, json; print(json.load(sys.stdin).get('sns_ops_topic_arn', {}).get('value', 'N/A'))")
aws sns publish \
  --topic-arn ${SNS_TOPIC_ARN} \
  --subject "ALERT: Amatra Platform Rollback Initiated — ${ENVIRONMENT}" \
  --message "Emergency rollback executed at $(date -u). Lambda functions reverted to version ${PREVIOUS_VERSION}. Staging endpoint available for consultants: --api-url https://api-staging.amatra.predictif.com" \
  --region us-west-2

echo "Rollback complete. Stakeholders notified."
```

## Appendix D: Troubleshooting Guide

### Common Issues

#### Issue: Solution status stuck at PENDING for more than 10 minutes

**Symptoms:**
- `amatra solution status {id}` returns `PENDING` after more than 10 minutes
- No `IN_PROGRESS` transition observed in CloudWatch logs

**Cause:** The Solution Create Lambda successfully wrote the DynamoDB record but the AgentCore Runtime invocation failed silently due to a cold-start timeout or an agent configuration error.

**Resolution:**

```bash
# Check the Solution Create Lambda logs for the specific solutionId
aws logs filter-log-events \
  --log-group-name /amatra/prod/solution-create \
  --filter-pattern "solutionId {solutionId}" \
  --start-time $(date -d '30 minutes ago' +%s)000 \
  --region us-west-2

# Check AgentCore Runtime agent status
aws bedrock-agentcore list-agent-invocations \
  --agent-name amatra-prod-input-validator \
  --region us-west-2 \
  --query 'invocations[?Status==`FAILED`]'
```

**Prevention:** Ensure Lambda Provisioned Concurrency is active for the Solution Create Lambda (2 instances) to eliminate cold-start-induced timeouts.

#### Issue: `VALIDATION_FAILED` after all 3 retries

**Symptoms:**
- Solution status transitions to `VALIDATION_FAILED` in DynamoDB
- EO Validator Agent logs show format-check errors for the same artifact on all three attempts

**Cause:** The client brief is missing required context (e.g., insufficient discovery questionnaire answers) causing Claude Sonnet 4.6 to generate an artifact that consistently fails the deterministic format-check.

**Resolution:**

```bash
# Retrieve the validation error envelope from DynamoDB
aws dynamodb get-item \
  --table-name amatra-prod-ddb-solutions \
  --key '{"solutionId":{"S":"<solution-id>"},"userId":{"S":"<user-id>"}}' \
  --region us-west-2 \
  --query 'Item.validationErrors'

# Review the specific format-check errors reported
# Typical causes: missing YAML frontmatter, incorrect H1 section order, empty placeholder text

# Advise the consultant to revise their brief with more complete discovery answers
# and resubmit as a new solution
```

**Prevention:** Distribute the brief quality training (TRN-006) to all consultants before go-live.

#### Issue: GitHub commit Lambda failing with 5xx errors

**Symptoms:**
- CloudWatch Alarm `amatra-prod-github-commit-failure` fires
- `amatra-prod/github-commit-failures` CloudWatch Log Group has messages

**Cause:** GitHub API is returning 5xx errors (service interruption) or the PAT has expired/been revoked.

**Resolution:**

```bash
# Check the GitHub Integration Lambda logs
aws logs filter-log-events \
  --log-group-name /amatra/prod/github-integration \
  --filter-pattern "ERROR" \
  --start-time $(date -d '1 hour ago' +%s)000 \
  --region us-west-2

# Verify GitHub API status
curl -s https://www.githubstatus.com/api/v2/status.json | python3 -c "import sys, json; d=json.load(sys.stdin); print(d['status']['description'])"

# If PAT is invalid, rotate it (follow PAT rotation runbook):
# 1. Generate new PAT with repo scope at https://github.com/settings/tokens
# 2. Update Secrets Manager:
aws secretsmanager put-secret-value \
  --secret-id amatra/prod/github/pat \
  --secret-string "${NEW_GITHUB_PAT}" \
  --region us-west-2
# 3. Verify: the next GitHub commit Lambda invocation will pick up the new PAT automatically
# Note: S3 artifacts are authoritative; GitHub commit failure does NOT invalidate the solution
```

**Prevention:** Set a recurring calendar reminder to rotate the GitHub PAT quarterly per the runbook schedule.

## Appendix E: Contact Information

### Project Team

| Role | Name | Email | Availability |
|------|------|-------|--------------|
| Vendor Project Manager | [Vendor PM Name] | [pm@vendor.com] | Business hours PT |
| Vendor Solution Architect | [Vendor Arch Name] | [arch@vendor.com] | Business hours PT |
| Vendor ML/AI Engineer (Agents) | [Vendor ML Eng Name] | [mleng@vendor.com] | Business hours PT |
| Vendor Solutions Engineer (Platform) | [Vendor Solutions Eng Name] | [solutionseng@vendor.com] | Business hours PT |
| Vendor Security Engineer | [Vendor Security Eng Name] | [seceng@vendor.com] | Business hours PT |

### Client Stakeholders

| Role | Name | Email | Phone |
|------|------|-------|-------|
| Executive Sponsor (CRO) | Sarah Lin | sarah.lin@predictif.com | [Phone] |
| Technical Lead (Pre-Sales Eng) | Marcus Patel | marcus.patel@predictif.com | +1 (555) 000-0001 |
| Delivery Operations Lead | Daniel Park | daniel.park@predictif.com | [Phone] |
| CTO | [CTO Name] | [cto@predictif.com] | [Phone] |
| Client IT Lead | [IT Lead Name] | [itlead@predictif.com] | [Phone] |

### Escalation Contacts

| Level | Contact | Availability | Trigger |
|-------|---------|--------------|---------|
| Hypercare L1 | Vendor PM (Slack/email) | Business hours PT | Any production incident |
| Hypercare L2 | Vendor Solution Architect (Slack/mobile) | Business hours PT; Sev1 extended | Sev1 unresolved after 30 min |
| AWS Support | AWS Business Support Portal | 24x7 (< 1 hour critical SLA) | AWS service-level issues |
| Post-Hypercare BAU | Daniel Park (Delivery Operations) | Per PREDICTif SLAs | All post-hypercare issues |

### Vendor Support

| Vendor | Support Channel | SLA | Notes |
|--------|----------------|-----|-------|
| Amazon Web Services | AWS Support Console (`console.aws.amazon.com/support`) | Business Support: < 1 hour critical | Case type: Lambda, DynamoDB, Cognito, Bedrock |
| Anthropic (Bedrock) | AWS Bedrock Support via AWS Console | Via AWS Business Support | Bedrock quota increases: `console.aws.amazon.com/bedrock` |

---

*Document Version: 1.0 | Prepared by: Amatra EO Framework Division | Solution: Amatra Agentic Orchestration Platform | Opportunity: OPP-2026-001 | Date: 2025-06-01*
