---
document_title: Implementation Guide
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

## Project Overview

This Implementation Guide provides step-by-step procedures for deploying the **AWS Agentic Pre-Sales Orchestration Platform** for PREDICTif Solutions. The platform replaces the existing manual pre-sales documentation workflow — which currently consumes six to ten hours of senior-consultant time per engagement — with a serverless, five-agent orchestration engine built on AWS Bedrock AgentCore Runtime and the Strands Agents framework. Upon completion, the platform produces all twelve EO Framework artifacts per engagement in under sixty minutes with no human in the loop during generation.

This guide covers all implementation phases from environment provisioning through production go-live, and serves as the primary operational reference for the Amatra vendor engineering team, PREDICTif's IT leads (Marcus Patel and Daniel Park), and any operations team managing the platform post-hypercare.

## Implementation Scope

- **In Scope:**
  - AWS us-west-2 foundation: VPC, IAM roles, S3 bucket policies, CloudTrail, KMS, GuardDuty
  - Amazon Cognito User Pool with JWT issuance, post-confirmation Lambda, and DynamoDB profile write
  - API Gateway HTTP API v2 with eleven Lambda routes and JWT Cognito authoriser
  - Five-agent Strands multi-agent graph registered in AWS Bedrock AgentCore Runtime
  - eof-tools converter library (~30 Python modules) baked into agent Docker image via Amazon ECR
  - Per-artifact deterministic format-check + LLM quality-check validation loop with up to 3 retries
  - Pip-installable CLI with fourteen subcommands
  - DynamoDB schema and atomic quota enforcement (per-user 10/month; global 1,000/month)
  - GitHub PAT-based automated artifact commit pipeline via AWS Secrets Manager
  - Terraform IaC modules for all platform infrastructure with `terraform validate` syntax gate
  - CloudWatch dashboards, alarms, per-phase token-usage metrics; X-Ray tracing on all 17 Lambda functions
  - CI/CD pipeline (GitHub Actions): Docker build, ECR push, Lambda deploy, Terraform validate gate
  - Development and Production environments (two environments)

- **Out of Scope:**
  - Development of net-new eof-tools converter modules
  - Multi-region deployment or active-active redundancy (us-west-2 single-region only)
  - Mobile application or browser-based UI
  - Integration with PREDICTif's existing us-east-1 managed-services workloads
  - SIEM/SOC integration beyond GuardDuty and Security Hub baseline
  - PCI-DSS, HIPAA, or FedRAMP compliance certification (SOC 2 readiness only)
  - Migration of existing OneDrive artifacts to the new platform

- **Dependencies:**
  - PREDICTif-provided us-west-2 AWS account with Bedrock service quota pre-approved
  - CTO sign-off on Cognito User Pool provisioning (required by end of Week 3)
  - GitHub repository and PAT (repo-write scope) provisioned by Marcus Patel before Week 5
  - eof-tools converter library source code delivered by Daniel Park before Phase 2 begins
  - Minimum five representative client briefs provided by Marcus Patel before Week 6

## Timeline Overview

- **Project Duration:** 12 weeks (Q2 2026, hard deadline end of April 2026)
- **Go-Live Date:** End of Week 12 (end of April 2026)
- **Hypercare Conclusion:** End of Week 16
- **Key Milestones:**
  - Phase 1 Foundation & Identity Complete: Week 4
  - Phase 2 Agent Build & Integration Complete: Week 9
  - Phase 3 Validation & Go-Live Complete: Week 12
  - Hypercare End: Week 16

---

# Prerequisites

## Technical Prerequisites

Complete all items in this section before starting Phase 1. Each item must be verified by the responsible team member and checked off before the Phase 1 kickoff meeting.

### Cloud Infrastructure

- [ ] PREDICTif us-west-2 AWS account provisioned and accessible to the vendor engineering team
- [ ] AWS Bedrock service quota pre-approved: AgentCore Runtime agents, Claude Sonnet 4.6 token throughput (~3M input + 1M output tokens/month), Claude Haiku 4.5 token throughput
- [ ] Administrator IAM access provisioned for vendor engineering team in us-west-2
- [ ] Billing alerts configured for the us-west-2 account (recommended: $5,000 monthly alert threshold)
- [ ] Resource quotas verified for Lambda concurrent executions (minimum 200 concurrency), ECR image storage, and S3 storage in us-west-2
- [ ] AWS Bedrock AgentCore Runtime confirmed generally available (not in preview) in us-west-2
- [ ] AWS Solutions Architect engaged for Bedrock quota pre-approval support

### Network Connectivity

- [ ] Confirm dedicated us-west-2 account is isolated from existing us-east-1 managed-services workloads
- [ ] No VPC peering or Transit Gateway connections planned between us-west-2 and us-east-1
- [ ] Outbound internet access available from the AWS account (required for Bedrock and GitHub HTTPS)
- [ ] DNS resolution confirmed working in us-west-2

### Security Baseline

- [ ] Confirmation that no wildcard IAM policies will be created (least-privilege baseline agreed)
- [ ] KMS key creation permissions verified for vendor team IAM roles
- [ ] AWS Secrets Manager available in us-west-2 region
- [ ] GuardDuty and Security Hub confirmed not previously enabled in us-west-2 account
- [ ] CTO sign-off process confirmed and timeline agreed (target: no later than end of Week 3)

### Development Tools

- [ ] GitHub repository provisioned for artifact delivery (public or private per PREDICTif preference)
- [ ] GitHub Personal Access Token with `repo` write scope provisioned and stored securely (required by Week 5)
- [ ] Docker Desktop or equivalent container build environment available on vendor engineering workstations
- [ ] Terraform CLI v1.5+ installed on vendor DevOps engineer workstation
- [ ] Python 3.12 environment available for CLI development and Lambda function testing
- [ ] AWS CLI v2 installed and configured with us-west-2 default region

### eof-tools Converter Library

- [ ] eof-tools source code (~30 Python modules: python-docx, openpyxl, python-pptx) delivered to vendor team by Daniel Park
- [ ] eof-tools module inventory documented (list all ~30 modules, their dependencies, and known issues)
- [ ] eof-tools integration spike planned for Week 5 to validate all modules prior to Docker image baking

## Organizational Prerequisites

- [ ] Project kickoff meeting scheduled for Week 1 (Marcus Patel, Daniel Park, Sarah Lin, vendor team)
- [ ] Vendor project team assigned and available: Solution Architect, ML/AI Engineer, Solutions Engineer (Lead), DevOps Engineer, Security Engineer, QA Engineer, Project Manager, Technical Writer
- [ ] Executive sponsor (Sarah Lin, CRO) confirmed; executive demo date agreed (end of April 2026)
- [ ] Marcus Patel designated as primary technical contact and artifact acceptance authority
- [ ] Daniel Park designated as secondary stakeholder and infrastructure deliverable acceptor
- [ ] Budget approved: $432,475 Professional Services net + Year 1 infrastructure ($49,427 net after credits)
- [ ] Weekly status report cadence agreed (vendor delivers every Friday by end of business)
- [ ] Dedicated Slack channel for hypercare (#amatra-platform-hypercare) pre-created for Week 13 use
- [ ] At least five representative client briefs committed for agent testing (provided by Marcus Patel by Week 6)

## Environmental Prerequisites

### Development Environment

- [ ] Development IAM user/role provisioned for vendor engineering team with appropriate boundaries
- [ ] Development resource naming prefix confirmed (`eofw-dev-`)
- [ ] Development DynamoDB On-Demand billing confirmed
- [ ] Developer access to CloudWatch Logs and X-Ray in us-west-2 confirmed

### Production Environment

- [ ] Production resource naming prefix confirmed (`eofw-prd-`)
- [ ] CTO sign-off process identified; CTO contact information provided to vendor team
- [ ] Production IAM admin console access restricted to Admin role with MFA requirement
- [ ] On-call rotation for hypercare period (Weeks 13–16) established

---

# Environment Setup

This section covers phase-by-phase environment provisioning and baseline configuration. All activities are executed sequentially except where explicitly noted as parallelisable.

## Phase 1: Foundation & Identity (Weeks 1–4)

### Objectives

Phase 1 establishes the secure AWS us-west-2 landing zone, identity layer, and API foundation upon which all agent workloads will be built.

- Establish VPC, IAM, S3, CloudTrail, KMS, and GuardDuty in us-west-2
- Deploy Amazon Cognito User Pool with post-confirmation Lambda (pending CTO sign-off)
- Deploy API Gateway HTTP API v2 with eleven Lambda routes and JWT Cognito authoriser
- Deploy DynamoDB schema (four tables) with atomic quota enforcement baseline
- Demonstrate a JWT-authenticated API call by end of Week 4

### Activities

The following table summarises all Phase 1 work packages with owner, duration, and dependencies.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Project kickoff and scope alignment | Project Manager | 1 day | None |
| Current-state assessment and ADR authoring | Solution Architect | 3 days | Kickoff |
| AWS us-west-2 landing zone provisioning (VPC, IAM, S3, CloudTrail, KMS) | DevOps Engineer | 4 days | Account access |
| GuardDuty and Security Hub enablement | Security Engineer | 1 day | Landing zone |
| Cognito User Pool implementation (post-confirmation Lambda, JWT) | Solutions Engineer | 4 days | Landing zone + CTO initiation |
| API Gateway HTTP API v2 (11 routes, JWT authoriser, CORS, throttling) | Solutions Engineer | 4 days | Cognito |
| DynamoDB schema (4 tables: users, solutions, quotas, audit_events) | DevOps Engineer | 3 days | Landing zone |
| Baseline CloudWatch dashboards and CloudTrail audit logging | DevOps Engineer | 2 days | All services |
| Secrets Manager setup for GitHub PAT placeholder | Security Engineer | 1 day | Landing zone |
| Phase 1 Completion Report | Project Manager | 1 day | All deliverables |

### Detailed Procedures

#### 1.1 AWS Landing Zone Provisioning

The landing zone is applied via Terraform in a single `terraform apply` from the Phase 1 IaC module. Navigate to the infrastructure directory and execute the following commands.

```bash
# Clone the engagement repository
git clone https://github.com/predictif/eofw-platform.git
cd eofw-platform/infrastructure/environments/dev

# Initialise Terraform with the dev backend configuration
terraform init -backend-config=backend-dev.tfvars

# Review the plan before applying
terraform plan -var-file=dev.tfvars -out=phase1-dev.plan

# Apply the Phase 1 foundation — VPC, IAM roles, S3, CloudTrail, KMS, GuardDuty
terraform apply phase1-dev.plan

# Capture outputs for subsequent modules
terraform output -json > ../../outputs/phase1-dev-outputs.json
```

**Expected output:**

```
Apply complete! Resources: 47 added, 0 changed, 0 destroyed.

Outputs:
vpc_id             = "vpc-0abc123def456789"
private_subnet_az1 = "subnet-0aaa111bbb222"
private_subnet_az2 = "subnet-0ccc333ddd444"
kms_artifact_key   = "arn:aws:kms:us-west-2:123456789012:key/abc-def-ghi"
cloudtrail_bucket  = "eofw-dev-s3-cloudtrail-123456789012"
artifact_bucket    = "eofw-dev-s3-artifacts-123456789012"
```

#### 1.2 Cognito User Pool Configuration

The Cognito User Pool must be provisioned in development first; CTO sign-off is required before the production pool is provisioned. The following commands verify that the pool is live and a test JWT can be obtained.

```bash
# Verify Cognito user pool is active
aws cognito-idp describe-user-pool \
  --user-pool-id $(cat ../../outputs/phase1-dev-outputs.json | jq -r '.cognito_user_pool_id.value') \
  --region us-west-2 \
  --query 'UserPool.Status'

# Create a test user for Phase 1 JWT validation
aws cognito-idp admin-create-user \
  --user-pool-id $(cat ../../outputs/phase1-dev-outputs.json | jq -r '.cognito_user_pool_id.value') \
  --username test-consultant@amatra.com \
  --user-attributes Name=custom:role,Value=consultant \
  --region us-west-2

# Obtain a test JWT for Phase 1 validation
aws cognito-idp initiate-auth \
  --auth-flow USER_PASSWORD_AUTH \
  --auth-parameters USERNAME=test-consultant@amatra.com,PASSWORD=TempPass123! \
  --client-id $(cat ../../outputs/phase1-dev-outputs.json | jq -r '.cognito_app_client_id.value') \
  --region us-west-2
```

#### 1.3 API Gateway JWT Validation

After Cognito and API Gateway are deployed, validate that the JWT authoriser rejects unauthenticated requests and accepts valid tokens.

```bash
# Unauthenticated request — should return 401
curl -s -o /dev/null -w "%{http_code}" \
  https://<apigw-id>.execute-api.us-west-2.amazonaws.com/api/v1/solutions

# Authenticated request — should return 200
JWT_TOKEN="<access-token-from-step-1.2>"
curl -s -w "\nHTTP Status: %{http_code}\n" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  https://<apigw-id>.execute-api.us-west-2.amazonaws.com/api/v1/health
```

**Expected output:**

```
{"status":"healthy","dynamodb":"connected","s3":"connected"}
HTTP Status: 200
```

#### 1.4 DynamoDB Schema Verification

Verify that all four DynamoDB tables are created with correct key schemas and billing modes.

```bash
# Verify all four tables exist and are ACTIVE
for table in users solutions quotas audit-events; do
  aws dynamodb describe-table \
    --table-name "eofw-dev-tbl-$table" \
    --region us-west-2 \
    --query 'Table.TableStatus'
done
```

### Deliverables

- [ ] Architecture Decision Record (ADR) — Current State & Target Architecture (Deliverable 1)
- [ ] AWS Landing Zone operational: VPC, IAM roles, S3 buckets, CloudTrail, KMS keys (Deliverable 2)
- [ ] Amazon Cognito User Pool live (pending CTO sign-off for production) (Deliverable 3)
- [ ] API Gateway HTTP API v2 with 11 routes and JWT authoriser (Deliverable 4)
- [ ] DynamoDB tables (users, solutions, quotas, audit_events) deployed (Deliverable 5)
- [ ] Baseline CloudWatch dashboards and GuardDuty active
- [ ] Phase 1 Completion Report submitted to Marcus Patel (Deliverable 6)

### Success Criteria

- JWT-authenticated API call demonstrable: `GET /api/v1/health` returns 200 with valid JWT; returns 401 without token
- All four DynamoDB tables in ACTIVE state with On-Demand billing
- CloudTrail logging confirmed active (management events enabled)
- GuardDuty enabled in us-west-2; Security Hub aggregating findings
- VPC subnets visible in us-west-2a and us-west-2b: public (2), private (2), database (2)
- `terraform validate` passes for all Phase 1 modules

---

## Phase 2: Agent Build & Integration (Weeks 5–9)

### Objectives

Phase 2 delivers the five-agent Strands graph, Bedrock AgentCore Runtime integration, eof-tools Docker image, validation loop, CLI, and GitHub commit pipeline.

- Implement the five-agent Strands multi-agent graph and register in Bedrock AgentCore Runtime
- Build Docker image pipeline baking eof-tools converters into the agent image
- Implement per-artifact format-check + LLM quality-check validation loop (up to 3 retries)
- Deploy pip-installable CLI with fourteen subcommands
- Implement atomic quota enforcement and GitHub PAT commit pipeline
- Generate the full presales bundle (five artifacts) end-to-end via CLI by end of Phase 2

### Activities

The following table outlines all Phase 2 work packages with owner, duration, and dependencies.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| eof-tools integration spike and module inventory | ML/AI Engineer | 3 days | eof-tools source delivered |
| Strands multi-agent graph design and implementation | ML/AI Engineer | 10 days | Phase 1 complete |
| Bedrock AgentCore Runtime agent registration (all 5 agents) | ML/AI Engineer | 3 days | Agent graph design |
| Docker image pipeline: eof-tools baking + ECR push | DevOps Engineer | 5 days | eof-tools spike |
| Per-artifact validation loop (format-check + Haiku 4.5, 3 retries) | Solutions Engineer | 5 days | Agent registration |
| Graded artifact delivery policy implementation | Solutions Engineer | 2 days | Validation loop |
| CLI implementation (14 subcommands, pip packaging) | Solutions Engineer | 5 days | API Gateway routes |
| DynamoDB atomic quota enforcement logic | Solutions Engineer | 3 days | DynamoDB tables |
| GitHub PAT commit pipeline (Secrets Manager integration) | Solutions Engineer | 3 days | Secrets Manager |
| Terraform IaC modules (all infrastructure) | DevOps Engineer | 5 days | Phase 1 IaC baseline |
| CI/CD pipeline (GitHub Actions: Docker build, ECR push, Lambda deploy) | DevOps Engineer | 3 days | ECR pipeline |
| CloudWatch per-phase token usage metrics + X-Ray tracing | DevOps Engineer | 3 days | All agents deployed |

### Detailed Procedures

#### 2.1 Docker Image Build Pipeline

The agent Docker image bakes the eof-tools converter library into a single immutable image pushed to Amazon ECR. This image is used by the five agent orchestration trigger Lambda functions.

```bash
# Navigate to the Docker build directory
cd eofw-platform/docker/agent-image

# Authenticate to ECR
aws ecr get-login-password --region us-west-2 | \
  docker login --username AWS --password-stdin \
  $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-west-2.amazonaws.com

# Build the agent Docker image (arm64 for Lambda)
BUILD_TAG=$(git rev-parse --short HEAD)
docker build \
  --platform linux/arm64 \
  --tag eofw-agent:$BUILD_TAG \
  --file Dockerfile.agent \
  .

# Tag and push to ECR
ECR_REPO="$(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-west-2.amazonaws.com/eofw-dev-ecr-agent-image"
docker tag eofw-agent:$BUILD_TAG $ECR_REPO:$BUILD_TAG
docker push $ECR_REPO:$BUILD_TAG
echo "Image pushed: $BUILD_TAG"
```

The Dockerfile for the agent image is as follows.

```dockerfile
FROM public.ecr.aws/lambda/python:3.12-arm64

# Copy eof-tools converter library (~30 Python modules)
COPY vendor/eof-tools/ /opt/eof-tools/

# Install Python dependencies including python-docx, openpyxl, python-pptx
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy agent handler code
COPY src/agent_handler.py ${LAMBDA_TASK_ROOT}/

CMD ["agent_handler.lambda_handler"]
```

#### 2.2 Strands Agent Graph Deployment

After the Docker image is pushed to ECR, deploy the five agents to Bedrock AgentCore Runtime via Terraform and validate agent registration.

```bash
cd eofw-platform/infrastructure/environments/dev

# Deploy agent infrastructure (AgentCore Runtime registrations, Lambda triggers)
terraform apply \
  -var-file=dev.tfvars \
  -var="agent_image_tag=$(git rev-parse --short HEAD)" \
  -target=module.bedrock_agents \
  -auto-approve

# Verify all five agents are registered in AgentCore Runtime
aws bedrock-agent list-agents \
  --region us-west-2 \
  --query 'agentSummaries[*].{Name:agentName,Status:agentStatus}'
```

**Expected output:**

```json
[
  {"Name": "eofw-dev-input-validator",     "Status": "PREPARED"},
  {"Name": "eofw-dev-presales-generator",  "Status": "PREPARED"},
  {"Name": "eofw-dev-delivery-generator",  "Status": "PREPARED"},
  {"Name": "eofw-dev-code-generator",      "Status": "PREPARED"},
  {"Name": "eofw-dev-eo-validator",        "Status": "PREPARED"}
]
```

#### 2.3 CLI Installation and Validation

After the CLI pip package is built and published, validate installation and end-to-end authentication.

```bash
# Install the CLI package
pip install eoframework-cli

# Verify installation
eoframework --version

# Authenticate (opens Cognito Hosted UI via PKCE flow)
eoframework auth login

# Verify stored credentials
cat ~/.eoframework/credentials | jq .

# Check quota status
eoframework status --quota

# Trigger a test generation using a synthetic brief
eoframework generate \
  --brief test-data/synthetic-brief-001.json \
  --env dev \
  --wait \
  --output-dir ./test-output/
```

### Deliverables

- [ ] Five-Agent Strands Graph operational in AgentCore Runtime (Deliverable 7)
- [ ] Bedrock AgentCore Runtime registration with Sonnet 4.6 + Haiku 4.5 bindings (Deliverable 8)
- [ ] Docker Image Pipeline — eof-tools agent image pushed to ECR (Deliverable 9)
- [ ] Per-Artifact Validation Loop — format-check + LLM quality-check with 3-retry logic (Deliverable 10)
- [ ] CLI — pip-installable, 14 subcommands including auth, generate, status, admin (Deliverable 11)
- [ ] DynamoDB Quota Enforcement — atomic per-user and global counters with admin override (Deliverable 12)
- [ ] GitHub Integration — PAT-based automated artifact commit pipeline (Deliverable 13)
- [ ] CI/CD Pipeline — Docker build, ECR push, Lambda deploy, terraform validate gate (Deliverable 14)
- [ ] Terraform IaC Automation Bundle (Deliverable 15)

### Success Criteria

- All five agents show `PREPARED` status in Bedrock AgentCore Runtime
- Full presales bundle (five artifacts) generated end-to-end via CLI `eoframework generate`
- Docker image pipeline executes green on every `git push` to `main` branch
- Quota enforcement: concurrent batch of 15 requests results in exactly 10 successes and 5 rejections (HTTP 429)
- GitHub commit pipeline successfully commits generated artifacts to the configured repository

---

## Phase 3: Validation & Go-Live (Weeks 10–12)

### Objectives

Phase 3 achieves end-to-end validation of all twelve artifact types, establishes the green CloudWatch metrics baseline, and delivers the executive demonstration.

- Execute end-to-end validation across all twelve artifact types
- Complete load testing at 200 solutions/month target throughput
- Complete security testing (JWT auth, quota bypass, PAT protection)
- Establish green CloudWatch metrics baseline
- Deliver UAT with Marcus Patel and executive demonstration to Sarah Lin
- Deploy to production with CTO sign-off

### Activities

The following table summarises all Phase 3 work packages.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| End-to-end artifact validation (all 12 types, staging) | QA Engineer | 5 days | Phase 2 complete |
| Load testing at 200 solutions/month (Locust) | QA Engineer | 3 days | Staging environment |
| Security testing (JWT, quota bypass, PAT protection, IAM) | Security Engineer | 3 days | Staging environment |
| DynamoDB PITR restore test (RTO validation) | DevOps Engineer | 1 day | Staging environment |
| CloudWatch green metrics baseline confirmation | DevOps Engineer | 2 days | All services deployed |
| UAT coordination with Marcus Patel and Daniel Park | Project Manager | 2 days | All artifacts validated |
| Production Terraform apply (with CTO sign-off gate) | DevOps Engineer | 1 day | CTO sign-off obtained |
| Production smoke tests (all 11 API routes, 1 E2E generation) | QA Engineer | 1 day | Production deployment |
| Executive demonstration to Sarah Lin | Project Manager | 1 day | Production live |
| Runbook authoring (all 4 failure scenarios) | Technical Writer | 3 days | All services deployed |
| Knowledge transfer Session 1 (CLI & API, 4 hours) | Solution Architect | 1 day | Runbooks delivered |
| Knowledge transfer Session 2 (Agent Operations, 3 hours) | ML/AI Engineer | 1 day | Runbooks delivered |
| As-built documentation and ADR library finalisation | Technical Writer | 2 days | All deliverables |

---

# Infrastructure Deployment

This section defines the deployment procedures for each infrastructure layer. All four subsections must be deployed in order: Networking first, then Security, then Compute, then Monitoring. Each subsection is gated on the successful completion of the preceding one.

## Networking

The networking layer establishes the VPC, subnets, NAT Gateway, Internet Gateway, route tables, security groups, and VPC Endpoints that form the foundation for all other infrastructure components. No Lambda functions or application compute are placed in public subnets; the public subnets host only the NAT Gateway.

### Components

The following table lists all networking components deployed by the `module.networking` Terraform module.

| Component | Resource Type | Specification | Purpose |
|-----------|---------------|---------------|---------|
| VPC | `aws_vpc` | CIDR `10.0.0.0/16`, DNS hostnames enabled | Isolated network boundary for us-west-2 platform |
| Public Subnet AZ1 | `aws_subnet` | `10.0.1.0/24`, us-west-2a | NAT Gateway placement only |
| Public Subnet AZ2 | `aws_subnet` | `10.0.2.0/24`, us-west-2b | NAT Gateway (Phase 2 AZ resilience) |
| Private Subnet AZ1 | `aws_subnet` | `10.0.10.0/24`, us-west-2a | Lambda functions and agent orchestration |
| Private Subnet AZ2 | `aws_subnet` | `10.0.11.0/24`, us-west-2b | Lambda functions and agent orchestration |
| Database Subnet AZ1 | `aws_subnet` | `10.0.20.0/24`, us-west-2a | Reserved for future RDS/ElastiCache |
| Database Subnet AZ2 | `aws_subnet` | `10.0.21.0/24`, us-west-2b | Reserved for future RDS/ElastiCache |
| Internet Gateway | `aws_internet_gateway` | Single IGW | Public subnet outbound internet route |
| NAT Gateway | `aws_nat_gateway` | 1 in us-west-2a public subnet, Elastic IP | Lambda outbound internet (Bedrock, GitHub HTTPS) |
| VPC Endpoint — S3 | `aws_vpc_endpoint` | Gateway type | Route Lambda→S3 without public internet |
| VPC Endpoint — DynamoDB | `aws_vpc_endpoint` | Gateway type | Route Lambda→DynamoDB without public internet |
| VPC Endpoint — Secrets Manager | `aws_vpc_endpoint` | Interface type | Secure PAT retrieval by GitHub push Lambda |
| VPC Endpoint — Bedrock Runtime | `aws_vpc_endpoint` | Interface type | Private routing for agent model invocations |
| VPC Endpoint — ECR API | `aws_vpc_endpoint` | Interface type | Docker image pull without public internet |
| VPC Endpoint — CloudWatch Logs | `aws_vpc_endpoint` | Interface type | Lambda log delivery without public internet |
| Security Group — Lambda | `aws_security_group` | Egress: 443 to VPC endpoints; no inbound | Applied to all Lambda functions |
| Security Group — VPC Endpoints | `aws_security_group` | Ingress: 443 from Lambda SG | Applied to Interface-type VPC Endpoints |

### Script Location

All networking Terraform resources are defined in `infrastructure/modules/networking/` with environment-specific variable overrides in `infrastructure/environments/{ENV}/networking.tfvars`. The root module entry point is `infrastructure/environments/{ENV}/main.tf`, which calls `module "networking" { source = "../../modules/networking" }`.

### Deployment Steps

Execute the following commands to deploy the networking layer to the target environment. Replace `{ENV}` with `dev` or `production`.

```bash
# 1. Navigate to the target environment directory
cd eofw-platform/infrastructure/environments/{ENV}

# 2. Initialise Terraform backend
terraform init -backend-config=backend-{ENV}.tfvars

# 3. Preview networking module changes
terraform plan \
  -var-file={ENV}.tfvars \
  -target=module.networking \
  -out=networking-{ENV}.plan

# 4. Peer-review the plan output before proceeding (required per SOW governance)
#    Review: VPC CIDR, subnet CIDRs, VPC endpoint types, security group rules

# 5. Apply networking resources
terraform apply networking-{ENV}.plan

# 6. Export outputs for dependent modules
terraform output -json | jq '{
  vpc_id: .vpc_id.value,
  private_subnet_ids: .private_subnet_ids.value,
  lambda_sg_id: .lambda_sg_id.value
}' > ../../outputs/{ENV}-networking-outputs.json
```

### Validation

After applying the networking layer, run the following commands to confirm all components are correctly provisioned.

```bash
# Verify VPC exists with correct CIDR
aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=eofw-{ENV}-vpc" \
  --query 'Vpcs[0].{ID:VpcId,CIDR:CidrBlock,DNS:EnableDnsHostnames}' \
  --region us-west-2

# Verify six subnets exist (2 public, 2 private, 2 database)
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$(cat ../../outputs/{ENV}-networking-outputs.json | jq -r .vpc_id)" \
  --query 'Subnets[*].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone}' \
  --region us-west-2

# Verify NAT Gateway is AVAILABLE
aws ec2 describe-nat-gateways \
  --filter "Name=vpc-id,Values=$(cat ../../outputs/{ENV}-networking-outputs.json | jq -r .vpc_id)" \
  --query 'NatGateways[0].State' \
  --region us-west-2

# Verify all VPC Endpoints are AVAILABLE
aws ec2 describe-vpc-endpoints \
  --filters "Name=vpc-id,Values=$(cat ../../outputs/{ENV}-networking-outputs.json | jq -r .vpc_id)" \
  --query 'VpcEndpoints[*].{Service:ServiceName,State:State}' \
  --region us-west-2
```

### Success Criteria

- VPC `eofw-{ENV}-vpc` exists with CIDR `10.0.0.0/16` and DNS hostnames enabled
- All six subnets exist across us-west-2a and us-west-2b with correct CIDRs
- NAT Gateway is in `available` state in the AZ1 public subnet with an associated Elastic IP
- All six VPC Endpoints (S3, DynamoDB, Secrets Manager, Bedrock Runtime, ECR API, CloudWatch Logs) are in `available` state
- Lambda security group allows egress on port 443 only; no inbound rules
- Route tables confirm private subnets route `0.0.0.0/0` through the NAT Gateway
- S3 and DynamoDB gateway endpoints are associated with private subnet route tables

### Rollback

If the networking deployment fails or produces incorrect configuration, destroy the networking module and redeploy after correcting the issue. Because no application state has been created at this stage, this operation is safe.

```bash
# Destroy only the networking module
terraform destroy \
  -var-file={ENV}.tfvars \
  -target=module.networking \
  -auto-approve

# Verify VPC is removed
aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=eofw-{ENV}-vpc" \
  --query 'Vpcs' \
  --region us-west-2
# Expected: empty array []

# Fix the networking.tfvars configuration and re-apply
terraform apply networking-{ENV}.plan
```

---

## Security

The security layer provisions IAM roles, KMS keys, Secrets Manager secrets, the Cognito User Pool, GuardDuty, Security Hub, CloudTrail, and all associated policies. This layer enforces least-privilege and establishes the SOC 2-aligned audit trail required before any agent workloads are deployed.

### Components

The following table lists all security components deployed by the `module.security` Terraform module.

| Component | Resource Type | Specification | Purpose |
|-----------|---------------|---------------|---------|
| KMS CMK — S3 Artifacts | `aws_kms_key` | Symmetric, 90-day rotation | Artifact bucket SSE-KMS encryption at rest |
| KMS Alias | `aws_kms_alias` | `alias/eofw-{env}-s3-artifacts` | Human-readable key reference |
| IAM Role — Input Validator Lambda | `aws_iam_role` | Least-privilege: DynamoDB GetItem/PutItem (users, solutions) | Agent 0 execution role |
| IAM Role — Generation Agent Lambdas (×3) | `aws_iam_role` | S3 PutObject (artifacts prefix), DynamoDB PutItem (solutions) | Generator agent execution roles |
| IAM Role — EO Validator Lambda | `aws_iam_role` | DynamoDB PutItem (solutions, audit_events), S3 GetObject, CloudWatch PutMetricData | Validator execution role |
| IAM Role — GitHub Push Lambda | `aws_iam_role` | Secrets Manager GetSecretValue (github-pat ARN only), S3 GetObject (artifacts prefix) | GitHub commit execution role |
| IAM Role — Cognito Post-Confirmation Lambda | `aws_iam_role` | DynamoDB PutItem (users table only) | Post-confirmation trigger role |
| IAM Role — API Route Handlers (×10) | `aws_iam_role` | DynamoDB GetItem/Query (solutions, quotas, users), S3 GetObject | API handler execution roles |
| Cognito User Pool | `aws_cognito_user_pool` | JWT 1-hr expiry, 30-day refresh, post-confirmation trigger | Consultant and admin authentication |
| Cognito App Client | `aws_cognito_user_pool_client` | PKCE authorization code flow, no client secret | CLI authentication client |
| Secrets Manager — GitHub PAT | `aws_secretsmanager_secret` | 90-day rotation, KMS-encrypted | GitHub PAT storage for commit pipeline |
| GuardDuty Detector | `aws_guardduty_detector` | Enabled, findings to Security Hub | Threat detection in us-west-2 |
| Security Hub | `aws_securityhub_account` | GuardDuty + Config + Inspector integrations | Unified posture management |
| CloudTrail | `aws_cloudtrail` | Management events + S3 data events on artifact bucket | API-level audit trail |
| CloudTrail S3 Bucket | `aws_s3_bucket` | Object Lock (WORM), 365-day retention | Immutable audit log storage |
| IAM Access Analyzer | `aws_accessanalyzer_analyzer` | Account-level, continuous policy validation | Validates no wildcard IAM actions |

### Script Location

All security Terraform resources are defined in `infrastructure/modules/security/`. KMS key ARNs and Cognito pool IDs output by this module are consumed by the `compute`, `database`, and `monitoring` modules. Environment variable overrides are in `infrastructure/environments/{ENV}/security.tfvars`.

### Deployment Steps

The security module must be deployed after the networking module, as it references VPC IDs for security group placement. For production, a manual CTO sign-off gate is embedded before the Cognito User Pool is activated.

```bash
# 1. Confirm networking outputs are available
cat ../../outputs/{ENV}-networking-outputs.json

# 2. Plan security module
terraform plan \
  -var-file={ENV}.tfvars \
  -target=module.security \
  -out=security-{ENV}.plan

# 3. Review plan — confirm no wildcard IAM actions, correct table ARNs, KMS alias names

# 4. Apply security resources
terraform apply security-{ENV}.plan

# 5. Production gate: wait for CTO sign-off before activating production Cognito User Pool
if [ "{ENV}" = "production" ]; then
  echo "WAITING: CTO sign-off required before activating production Cognito User Pool"
  echo "Contact: CTO via Marcus Patel (marcus.patel@predictif.com)"
fi

# 6. Store the GitHub PAT in Secrets Manager (never commit to source control)
aws secretsmanager put-secret-value \
  --secret-id $(terraform output -raw github_pat_secret_arn) \
  --secret-string '{"github_pat":"<PAT-provided-by-Marcus-Patel>"}' \
  --region us-west-2

# 7. Export security outputs for dependent modules
terraform output -json | jq '{
  cognito_user_pool_id: .cognito_user_pool_id.value,
  cognito_app_client_id: .cognito_app_client_id.value,
  kms_s3_cmk_arn: .kms_s3_cmk_arn.value,
  github_pat_secret_arn: .github_pat_secret_arn.value
}' > ../../outputs/{ENV}-security-outputs.json
```

### Validation

Run the following checks to confirm the security layer is correctly deployed and all controls are enforced.

```bash
# Verify KMS key exists with rotation enabled
aws kms describe-key \
  --key-id alias/eofw-{ENV}-s3-artifacts \
  --region us-west-2 \
  --query 'KeyMetadata.{ID:KeyId,State:KeyState}'

# Verify IAM Access Analyzer is active
aws accessanalyzer list-analyzers \
  --region us-west-2 \
  --query 'analyzers[*].{Name:name,Status:status}'

# Verify GuardDuty is enabled
aws guardduty list-detectors --region us-west-2

# Verify CloudTrail is logging
aws cloudtrail get-trail-status \
  --name eofw-{ENV}-cloudtrail \
  --region us-west-2 \
  --query '{Logging:IsLogging,LastDelivery:LatestDeliveryTime}'

# Confirm IAM Access Analyzer reports zero active findings
aws accessanalyzer list-findings \
  --analyzer-arn $(aws accessanalyzer list-analyzers \
    --region us-west-2 --query 'analyzers[0].arn' --output text) \
  --filter '{"status":{"eq":["ACTIVE"]}}' \
  --region us-west-2
# Expected: empty findings list

# Verify Secrets Manager secret exists (do not print value)
aws secretsmanager describe-secret \
  --secret-id $(cat ../../outputs/{ENV}-security-outputs.json | jq -r .github_pat_secret_arn) \
  --query '{Name:Name,RotationEnabled:RotationEnabled}' \
  --region us-west-2
```

### Success Criteria

- KMS CMK for S3 artifacts exists in `Enabled` state with 90-day automatic key rotation enabled
- All Lambda execution IAM roles exist with no wildcard `*` actions or resource ARNs
- IAM Access Analyzer reports zero active findings
- GuardDuty detector is in `ENABLED` state in us-west-2; Security Hub is enabled
- CloudTrail is logging (`IsLogging: true`); S3 data events enabled on artifact bucket (production)
- Secrets Manager secret for GitHub PAT exists with `RotationEnabled: true` on a 90-day schedule
- Cognito User Pool is in `Active` state (production: CTO sign-off obtained before activation)
- CloudTrail S3 bucket has Object Lock enabled in COMPLIANCE mode

### Rollback

If the security deployment fails, destroy the security module resources. Note that KMS key deletion requires a mandatory 7–30 day waiting period; plan accordingly for production rollbacks.

```bash
# Destroy security module resources
terraform destroy \
  -var-file={ENV}.tfvars \
  -target=module.security \
  -auto-approve

# Schedule KMS key deletion if it was created (minimum 7-day waiting period)
aws kms schedule-key-deletion \
  --key-id alias/eofw-{ENV}-s3-artifacts \
  --pending-window-in-days 7 \
  --region us-west-2

# For production: disable the Cognito User Pool rather than deleting it,
# to preserve user accounts while the issue is resolved
aws cognito-idp update-user-pool \
  --user-pool-id $(cat ../../outputs/{ENV}-security-outputs.json | jq -r .cognito_user_pool_id) \
  --policies '{"PasswordPolicy":{"MinimumLength":8}}' \
  --region us-west-2
```

---

## Compute

The compute layer provisions all seventeen Lambda functions, the ECR repository, the API Gateway HTTP API v2, the CI/CD pipeline, and the SQS DLQ for failed GitHub pushes. This is the core execution layer of the platform.

### Components

The following table lists all compute components deployed by the `module.compute` Terraform module.

| Component | Resource Type | Specification | Purpose |
|-----------|---------------|---------------|---------|
| Lambda — API Route Handlers (×10) | `aws_lambda_function` | Python 3.12, arm64, 256 MB, 30s timeout | Handle synchronous API routes (non-generation) |
| Lambda — Solution Generation Initiator | `aws_lambda_function` | Python 3.12, arm64, 512 MB, 60s timeout | Initiate 5-agent generation; return 202 Accepted |
| Lambda — Agent Orchestration Triggers (×5) | `aws_lambda_function` | Python 3.12, arm64, 1024 MB, 900s timeout, container image | Run Strands agents with eof-tools converters |
| Lambda — Cognito Post-Confirmation | `aws_lambda_function` | Python 3.12, arm64, 256 MB, 10s timeout | Write DynamoDB user profile on registration |
| Lambda — GitHub Push | `aws_lambda_function` | Python 3.12, arm64, 256 MB, 60s timeout | Commit artifacts to GitHub via PAT |
| Lambda — Inactive User Suspension | `aws_lambda_function` (scheduled) | Python 3.12, arm64, 256 MB, 300s timeout | Suspend Cognito accounts inactive ≥90 days |
| ECR Repository | `aws_ecr_repository` | `eofw-{ENV}-ecr-agent-image`, IMMUTABLE tags | Store eof-tools agent Docker images |
| API Gateway HTTP API v2 | `aws_apigatewayv2_api` | Regional endpoint, HTTPS-only, Cognito JWT authoriser | Expose 11 Lambda routes at `/api/v1/` |
| API Gateway Stage | `aws_apigatewayv2_stage` | Auto-deploy, throttle burst 1,000 RPS | Default stage with throttle limits |
| SQS FIFO DLQ | `aws_sqs_queue` | `eofw-{ENV}-sqs-github-dlq.fifo` | Dead letter queue for failed GitHub push retries |
| EventBridge Rule | `aws_cloudwatch_event_rule` | Rate(1 day) | Trigger inactive user suspension Lambda daily |

### Script Location

All compute Terraform resources are defined in `infrastructure/modules/compute/`. Lambda function source code is in `src/functions/` with each function in its own subdirectory. The ECR image build and push is automated by the GitHub Actions CI/CD pipeline defined in `.github/workflows/build-and-deploy.yml`. Environment variable overrides are in `infrastructure/environments/{ENV}/compute.tfvars`.

### Deployment Steps

The compute module depends on outputs from the networking and security modules. The ECR image must be pushed to ECR before the agent trigger Lambda functions are deployed.

```bash
# 1. Confirm the ECR agent image is available in ECR
IMAGE_TAG=$(git rev-parse --short HEAD)
aws ecr describe-images \
  --repository-name eofw-{ENV}-ecr-agent-image \
  --image-ids imageTag=$IMAGE_TAG \
  --region us-west-2

# 2. Plan compute module
terraform plan \
  -var-file={ENV}.tfvars \
  -var="agent_image_tag=$IMAGE_TAG" \
  -target=module.compute \
  -out=compute-{ENV}.plan

# 3. Apply compute resources
terraform apply compute-{ENV}.plan

# 4. Trigger CI/CD pipeline to deploy all Lambda function code packages
git tag "deploy-{ENV}-$(date +%Y%m%d-%H%M%S)"
git push origin --tags

# 5. Verify all 17 Lambda functions are Active
aws lambda list-functions \
  --query "Functions[?starts_with(FunctionName, 'eofw-{ENV}-fn-')].{Name:FunctionName,State:State}" \
  --region us-west-2
```

The GitHub Actions CI/CD pipeline that drives Docker build, ECR push, and Lambda deployment is defined as follows.

```yaml
name: Build and Deploy

on:
  push:
    branches: [main]
  workflow_dispatch:

env:
  AWS_REGION: us-west-2
  ECR_REPOSITORY: eofw-dev-ecr-agent-image

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_DEPLOY_ROLE_ARN }}
          aws-region: ${{ env.AWS_REGION }}
      - name: Build and push Docker image to ECR
        run: |
          IMAGE_TAG=$(git rev-parse --short HEAD)
          ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
          aws ecr get-login-password | docker login --username AWS \
            --password-stdin $ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com
          docker build --platform linux/arm64 -t $ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG
      - name: Terraform validate gate
        working-directory: infrastructure
        run: |
          terraform init -backend-config=backend-dev.tfvars
          terraform validate
          echo "Terraform validate: PASSED"
      - name: Deploy Lambda functions
        run: |
          ./scripts/deploy-lambdas.sh dev $(git rev-parse --short HEAD)
```

### Validation

After deploying the compute layer, validate all Lambda functions, the API Gateway endpoint, and CI/CD pipeline health.

```bash
# Verify all 17 Lambda functions exist
aws lambda list-functions \
  --query "Functions[?starts_with(FunctionName, 'eofw-{ENV}-fn-')] | length(@)" \
  --region us-west-2
# Expected: 17

# Invoke the health check Lambda directly
aws lambda invoke \
  --function-name eofw-{ENV}-fn-health-check \
  --payload '{}' \
  --region us-west-2 \
  /tmp/health-response.json
cat /tmp/health-response.json
# Expected: {"statusCode":200,"body":"{\"status\":\"healthy\"}"}

# Test API Gateway health endpoint (unauthenticated)
APIGW_URL=$(terraform output -raw apigw_endpoint)
curl -s "$APIGW_URL/api/v1/health"
# Expected: {"status":"healthy","dynamodb":"connected","s3":"connected"}

# Run terraform validate on all IaC modules
cd eofw-platform/infrastructure
terraform validate
# Expected: "Success! The configuration is valid."
```

### Success Criteria

- All 17 Lambda functions exist in `Active` state in us-west-2
- Health check Lambda returns HTTP 200 both on direct invocation and via API Gateway
- API Gateway HTTP API v2 endpoint is accessible; `GET /api/v1/health` returns `{"status":"healthy"}`
- ECR repository contains the latest agent image with an immutable tag
- `terraform validate` passes for all infrastructure modules with exit code 0
- GitHub Actions CI/CD pipeline completes successfully (Docker build + ECR push + terraform validate + Lambda deploy)
- SQS FIFO DLQ `eofw-{ENV}-sqs-github-dlq.fifo` exists with zero messages at initial state

### Rollback

To roll back the compute layer, redeploy the previous Lambda function versions via the CI/CD pipeline and revert the compute Terraform module if infrastructure changes are also involved.

```bash
# Identify the previous known-good commit tag
PREVIOUS_TAG=$(git log --format="%h" -n 2 | tail -1)

# Redeploy previous Lambda function versions
./scripts/deploy-lambdas.sh {ENV} $PREVIOUS_TAG

# If infrastructure change is also involved, revert the Terraform module
git revert HEAD --no-edit
git push origin main
# CI/CD pipeline applies the reverted Terraform configuration automatically

# Verify rollback succeeded
aws lambda get-function-configuration \
  --function-name eofw-{ENV}-fn-solution-initiator \
  --region us-west-2 \
  --query '{LastModified:LastModified}'
```

---

## Monitoring

The monitoring layer provisions CloudWatch dashboards, metric alarms, log groups, X-Ray tracing groups, Synthetics canaries, and SNS alert topics. This layer provides the operational visibility required for the green metrics baseline in Phase 3 and throughout the hypercare support period. It must be deployed last, after all other modules are operational.

### Components

The following table lists all monitoring components deployed by the `module.monitoring` Terraform module.

| Component | Resource Type | Specification | Purpose |
|-----------|---------------|---------------|---------|
| CloudWatch Dashboard | `aws_cloudwatch_dashboard` | `eofw-{ENV}-health`, JSON widget definitions | Real-time Lambda, DynamoDB, Bedrock, API Gateway visibility |
| Log Groups — Lambda (×17) | `aws_cloudwatch_log_group` | `/eofw/{ENV}/lambda/{fn-name}`, 90-day retention | Structured JSON logs per Lambda function |
| Log Group — CloudTrail | `aws_cloudwatch_log_group` | `/eofw/{ENV}/cloudtrail`, 365-day retention | CloudTrail delivery to CloudWatch for log insights |
| Alarm — Lambda Error Rate | `aws_cloudwatch_metric_alarm` | ErrorRate > 1%, 5-min window, P2 | Lambda error rate threshold |
| Alarm — Bedrock Throttle | `aws_cloudwatch_metric_alarm` | ThrottlingException count > 5 per 5 min, P2 | Bedrock token throughput monitoring |
| Alarm — DynamoDB Throttle | `aws_cloudwatch_metric_alarm` | ThrottledRequests > 0, 5-min window, P2 | DynamoDB capacity monitoring |
| Alarm — GitHub DLQ Depth | `aws_cloudwatch_metric_alarm` | SQS ApproximateNumberOfMessages > 0, P2 | Failed GitHub push detection |
| Alarm — Global Quota at 90% | `aws_cloudwatch_metric_alarm` | Custom metric GlobalQuotaCounter ≥ 900, P3 | Quota headroom warning |
| Alarm — Canary Failure | `aws_cloudwatch_metric_alarm` | Canary SuccessPercent < 100%, 2 consecutive runs, P1 | Platform availability monitoring |
| Alarm — API P99 Latency | `aws_cloudwatch_metric_alarm` | API Gateway P99 > 3,000 ms, P2 | API latency SLA monitoring |
| CloudWatch Synthetics Canary | `aws_synthetics_canary` | 5-min polling interval, `GET /api/v1/health` | Continuous availability check |
| SNS Topic — Ops Alerts | `aws_sns_topic` | `eofw-{ENV}-sns-ops-alerts` | Route all alarms to Daniel Park and on-call |
| SNS Email Subscriptions | `aws_sns_topic_subscription` | daniel.park@predictif.com + vendor on-call alias | Alert notification recipients |
| X-Ray Group | `aws_xray_group` | Filter: `service("eofw-{ENV}*")`, 5% sampling (prod) | Distributed trace grouping for all 17 functions |
| Custom Metric Namespace | CloudWatch custom namespace `EOFW/TokenUsage` | Per-agent input/output tokens and estimated cost | Bedrock spend tracking per solution |

### Script Location

All monitoring Terraform resources are defined in `infrastructure/modules/monitoring/`. CloudWatch dashboard JSON widget definitions are in `infrastructure/modules/monitoring/dashboards/eofw-health-dashboard.json`. The Synthetics canary script is in `infrastructure/modules/monitoring/canaries/health-check-canary.js`. Environment variable overrides are in `infrastructure/environments/{ENV}/monitoring.tfvars`.

### Deployment Steps

Deploy the monitoring module after networking, security, and compute modules are fully operational, as it references Lambda ARNs, SNS topic ARNs, DynamoDB table names, and API Gateway endpoint URLs from those modules.

```bash
# 1. Confirm all prior module outputs are available
ls ../../outputs/{ENV}-networking-outputs.json
ls ../../outputs/{ENV}-security-outputs.json
ls ../../outputs/{ENV}-compute-outputs.json

# 2. Plan monitoring module
terraform plan \
  -var-file={ENV}.tfvars \
  -target=module.monitoring \
  -out=monitoring-{ENV}.plan

# 3. Apply monitoring resources
terraform apply monitoring-{ENV}.plan

# 4. Export monitoring outputs
terraform output -json | jq '{
  ops_alerts_sns_arn: .ops_alerts_sns_arn.value,
  dashboard_name: .dashboard_name.value,
  canary_name: .canary_name.value
}' > ../../outputs/{ENV}-monitoring-outputs.json

# 5. Manually confirm SNS email subscription (Daniel Park must click the confirmation link)
echo "ACTION REQUIRED: Daniel Park must confirm the SNS subscription email sent to daniel.park@predictif.com"

# 6. Start the Synthetics canary and verify first run passes
aws synthetics start-canary \
  --name eofw-{ENV}-health-canary \
  --region us-west-2

sleep 120
aws synthetics get-canary-runs \
  --name eofw-{ENV}-health-canary \
  --region us-west-2 \
  --query 'CanaryRuns[0].{Status:Status.State,Reason:Status.StateReason}'
```

The CloudWatch dashboard includes the following key widget types for per-phase token usage monitoring.

```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "title": "Lambda Error Rate (%)",
        "metrics": [
          ["AWS/Lambda", "Errors", "FunctionName", "eofw-prd-fn-solution-initiator",
           {"stat": "Sum", "period": 300, "id": "errors"}],
          ["AWS/Lambda", "Invocations", "FunctionName", "eofw-prd-fn-solution-initiator",
           {"stat": "Sum", "period": 300, "id": "inv", "visible": false}],
          [{"expression": "errors/inv*100", "label": "Error Rate %", "id": "rate"}]
        ],
        "view": "timeSeries",
        "period": 300
      }
    },
    {
      "type": "metric",
      "properties": {
        "title": "Bedrock Token Usage — Estimated Cost (USD/hr)",
        "metrics": [
          ["EOFW/TokenUsage", "EstimatedCostUSD", "AgentName", "presales-generator"],
          ["EOFW/TokenUsage", "EstimatedCostUSD", "AgentName", "delivery-generator"],
          ["EOFW/TokenUsage", "EstimatedCostUSD", "AgentName", "code-generator"]
        ],
        "view": "timeSeries",
        "period": 3600
      }
    }
  ]
}
```

### Validation

After deploying the monitoring layer, validate that all alarms are in an OK state, the canary is running and passing, and SNS notifications are routing correctly.

```bash
# Verify no alarms are in ALARM state at rest
aws cloudwatch describe-alarms \
  --alarm-name-prefix eofw-{ENV} \
  --state-value ALARM \
  --region us-west-2 \
  --query 'MetricAlarms[*].{Name:AlarmName,State:StateValue}'
# Expected: empty array

# Verify Synthetics canary is in RUNNING state
aws synthetics get-canary \
  --name eofw-{ENV}-health-canary \
  --region us-west-2 \
  --query 'Canary.Status.State'
# Expected: "RUNNING"

# Verify all 17 Lambda log groups exist
aws logs describe-log-groups \
  --log-group-name-prefix /eofw/{ENV}/lambda \
  --region us-west-2 \
  --query 'logGroups | length(@)'
# Expected: 17

# Verify SNS topic has at least one confirmed subscription
aws sns list-subscriptions-by-topic \
  --topic-arn $(cat ../../outputs/{ENV}-monitoring-outputs.json | jq -r .ops_alerts_sns_arn) \
  --region us-west-2 \
  --query 'Subscriptions[*].{Protocol:Protocol,Endpoint:Endpoint,Status:SubscriptionArn}'

# Send a test SNS notification to confirm email delivery
aws sns publish \
  --topic-arn $(cat ../../outputs/{ENV}-monitoring-outputs.json | jq -r .ops_alerts_sns_arn) \
  --message "Test alert: Monitoring layer deployed for eofw-{ENV}. Please confirm receipt." \
  --subject "EOFW Monitoring Validation — $(date +%Y-%m-%d)" \
  --region us-west-2
```

### Success Criteria

- CloudWatch dashboard `eofw-{ENV}-health` is visible in the CloudWatch console with all metric widgets rendering correctly
- All seven CloudWatch Alarms exist in `OK` or `INSUFFICIENT_DATA` state (no spurious alarms during deployment)
- CloudWatch Synthetics canary `eofw-{ENV}-health-canary` is in `RUNNING` state and the most recent run shows `PASSED`
- All 17 Lambda log groups exist under `/eofw/{ENV}/lambda/` with 90-day retention configured
- SNS topic `eofw-{ENV}-sns-ops-alerts` has at least one confirmed email subscription for Daniel Park
- X-Ray service map shows all 17 Lambda functions with active tracing after a test generation
- Custom CloudWatch namespace `EOFW/TokenUsage` appears in the CloudWatch Metrics browser after the first solution generation in Phase 2

### Rollback

The monitoring layer is stateless and fully idempotent. If alarm thresholds or dashboard configurations are incorrect, destroy and redeploy the module without any data loss risk.

```bash
# Destroy the monitoring module only
terraform destroy \
  -var-file={ENV}.tfvars \
  -target=module.monitoring \
  -auto-approve

# Correct the monitoring.tfvars or dashboard JSON definitions, then redeploy
terraform apply \
  -var-file={ENV}.tfvars \
  -target=module.monitoring \
  -auto-approve

# Confirm alarm count is restored
aws cloudwatch describe-alarms \
  --alarm-name-prefix eofw-{ENV} \
  --region us-west-2 \
  --query 'MetricAlarms | length(@)'
# Expected: 7
```

---

# Application Configuration

This section documents the application-layer configuration for all services after the infrastructure is deployed. It covers environment-specific settings, DynamoDB initialisation, Bedrock agent configuration, and GitHub commit pipeline wiring.

## Service Configuration

The platform uses environment-specific YAML configuration files loaded by each Lambda function at startup. These files are stored in the S3 guidance bucket and injected via environment variables during Terraform deployment.

The following configuration governs the core runtime behaviour for all 17 Lambda functions.

```yaml
# config/application-production.yml
application:
  name: eoframework
  version: 1.0.0
  environment: production
  region: us-west-2
  cli_package_name: eoframework-cli
  cli_subcommand_count: 14
  api_route_count: 11
  artifact_types_count: 12
  agent_count: 5

generation:
  max_retries_per_artifact: 3
  generation_timeout_minutes: 60
  cost_per_solution_target_usd: 5.00

logging:
  level: info
  format: json
  structured_fields:
    - solution_id
    - artifact_type
    - agent_name
    - retry_count
    - token_usage

bedrock:
  primary_model_id: anthropic.claude-sonnet-4-5
  validator_model_id: anthropic.claude-haiku-4-5
  agentcore_region: us-west-2

quota:
  per_user_monthly: 10
  global_monthly: 1000
  inactivity_suspension_days: 90
```

## Environment Variables

The following environment variables are injected into all Lambda functions via Terraform. Sensitive values are stored in AWS Secrets Manager and retrieved at runtime — they are never stored in Lambda environment variables.

| Variable | Description | Source | Required |
|----------|-------------|--------|----------|
| `APP_ENVIRONMENT` | Deployment environment (`production` or `dev`) | Terraform `var.environment` | Yes |
| `DYNAMODB_USERS_TABLE` | DynamoDB users table name | Terraform output | Yes |
| `DYNAMODB_SOLUTIONS_TABLE` | DynamoDB solutions table name | Terraform output | Yes |
| `DYNAMODB_QUOTAS_TABLE` | DynamoDB quotas table name | Terraform output | Yes |
| `DYNAMODB_AUDIT_TABLE` | DynamoDB audit_events table name | Terraform output | Yes |
| `S3_ARTIFACT_BUCKET` | S3 artifact bucket name | Terraform output | Yes |
| `S3_GUIDANCE_BUCKET` | S3 guidance files bucket name | Terraform variable | Yes |
| `COGNITO_USER_POOL_ID` | Cognito User Pool ID | Secrets Manager at runtime | Yes |
| `BEDROCK_PRIMARY_MODEL_ID` | Claude Sonnet 4.6 model ID | `application.yml` | Yes |
| `BEDROCK_VALIDATOR_MODEL_ID` | Claude Haiku 4.5 model ID | `application.yml` | Yes |
| `SNS_OPS_ALERTS_ARN` | SNS topic ARN for operational alerts | Terraform output | Yes |
| `GITHUB_PAT_SECRET_ARN` | Secrets Manager ARN for GitHub PAT (GitHub push Lambda only) | Terraform output | Yes |

## IAM Role Configuration

Each Lambda function carries its own least-privilege IAM execution role. The following example shows the IAM policy for the GitHub push Lambda, scoped to only the Secrets Manager secret ARN and the specific S3 artifact prefix it requires.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "GetGitHubPAT",
      "Effect": "Allow",
      "Action": ["secretsmanager:GetSecretValue"],
      "Resource": "arn:aws:secretsmanager:us-west-2:123456789012:secret:eofw/prd/github-pat-*"
    },
    {
      "Sid": "ReadArtifacts",
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::eofw-prd-s3-artifacts-123456789012",
        "arn:aws:s3:::eofw-prd-s3-artifacts-123456789012/*"
      ]
    },
    {
      "Sid": "WriteAuditEvent",
      "Effect": "Allow",
      "Action": ["dynamodb:PutItem"],
      "Resource": "arn:aws:dynamodb:us-west-2:123456789012:table/eofw-prd-tbl-audit-events"
    }
  ]
}
```

## DynamoDB Initialisation

Before the first production solution is generated, initialise the global quota counter in the `quotas` table using the following command.

```bash
# Initialise the global quota counter for the current month
CURRENT_MONTH=$(date +%Y-%m)
aws dynamodb put-item \
  --table-name eofw-prd-tbl-quotas \
  --item "{
    \"user_id\": {\"S\": \"GLOBAL\"},
    \"month_key\": {\"S\": \"$CURRENT_MONTH\"},
    \"counter\": {\"N\": \"0\"},
    \"last_updated\": {\"S\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}
  }" \
  --condition-expression "attribute_not_exists(user_id)" \
  --region us-west-2

echo "Global quota counter initialised for $CURRENT_MONTH"
```

## Bedrock Agent Configuration

After agents are registered in AgentCore Runtime, upload EO Framework guidance files to the S3 guidance bucket so that each agent can read its generation prompts from the structured S3 key prefix.

```bash
# Upload EO Framework guidance files to the guidance bucket
aws s3 sync \
  ./guidance/ \
  s3://$(terraform output -raw guidance_bucket_name)/guidance/ \
  --region us-west-2 \
  --exclude "*.DS_Store"

# Verify guidance files are accessible by the Pre-Sales Generator agent
aws s3 ls \
  s3://$(terraform output -raw guidance_bucket_name)/guidance/pre-sales/ \
  --region us-west-2

# Test agent invocation with a synthetic brief
aws bedrock-agent-runtime invoke-agent \
  --agent-id $(terraform output -raw input_validator_agent_id) \
  --agent-alias-id TSTALIASID \
  --session-id "test-session-$(date +%s)" \
  --input-text "Validate synthetic brief: test-data/synthetic-brief-001.json" \
  --region us-west-2 \
  /tmp/agent-response.json

cat /tmp/agent-response.json | jq .
```

---

# Integration Testing

Integration testing validates end-to-end artifact generation across all twelve artifact types, cross-component integration between agents, all API routes, and external systems (GitHub, Bedrock, DynamoDB). All tests are executed in the staging environment before production deployment and must achieve the pass rates defined below.

## Integration Test Suite Overview

The integration test suite is organised into four test categories, each of which must achieve 100% pass rate before proceeding to production deployment.

| Test Category | Scope | Pass Criteria | Tool |
|---------------|-------|---------------|------|
| API Route Integration | All 11 Lambda routes, JWT auth, quota enforcement | All routes return expected HTTP status codes for all role combinations | pytest + requests |
| Agent-to-Agent Integration | 5-agent Strands graph, message passing, 3-retry loop | All 5 agents invoked correctly per generation request; graded delivery confirmed | Custom E2E test harness |
| Artifact Format Validation | All 12 artifact types, EO Validator format-check rules | ≥95% first-attempt pass rate across all 12 types | EO Validator agent |
| External System Integration | GitHub commit pipeline, Bedrock API, DynamoDB atomic quotas | Zero quota bypass; all passing artifacts committed to GitHub | pytest + boto3 |

## API Route Integration Tests

These tests validate all eleven API routes with valid and invalid JWT tokens, confirming authentication enforcement and correct response codes for all role combinations.

```bash
# Navigate to the API integration test directory
cd eofw-platform/tests/integration/api

# Install test dependencies
pip install -r requirements-test.txt

# Execute API integration tests against staging
pytest test_api_routes.py \
  --env staging \
  --apigw-url "$(cat ../../../outputs/staging-compute-outputs.json | jq -r .apigw_endpoint)" \
  --cognito-pool-id "$(cat ../../../outputs/staging-security-outputs.json | jq -r .cognito_user_pool_id)" \
  -v --tb=short \
  --junit-xml=reports/api-integration-results.xml
```

## End-to-End Artifact Generation Tests

These tests validate the full generation pipeline from CLI invocation through all five agents to GitHub commit, covering all twelve artifact types.

```bash
# Run E2E generation test for all 12 artifact types using a representative brief
cd eofw-platform/tests/e2e

eoframework generate \
  --brief ./test-data/representative-brief-001.json \
  --env staging \
  --wait \
  --output-dir ./e2e-output/solution-001/

# Verify all 12 artifact types were generated and passed validation
python verify_artifact_bundle.py \
  --output-dir ./e2e-output/solution-001/ \
  --expected-artifacts 12

# Verify GitHub commit was created for the solution
python verify_github_commit.py \
  --solution-id $(cat ./e2e-output/solution-001/solution-id.txt) \
  --repo-url "$(cat ../../outputs/staging-compute-outputs.json | jq -r .github_repo_url)"
```

## Quota Enforcement Integration Tests

These tests confirm that the atomic DynamoDB conditional write prevents per-user and global quota bypass via concurrent requests.

```bash
# Test per-user quota limit (10 per month)
python tests/quota/test_per_user_quota.py \
  --user-email "test-consultant@amatra.com" \
  --concurrent-requests 15 \
  --expected-successes 10 \
  --expected-429s 5 \
  --env staging

# Test global quota at 90% threshold alert
python tests/quota/test_global_quota_alarm.py \
  --initial-counter 900 \
  --env staging
# Expected: CloudWatch alarm fires; SNS notification received by Daniel Park

# Stress test: race condition bypass prevention
python tests/quota/test_race_condition_bypass.py \
  --threads 20 \
  --sleep-ms 0 \
  --expected-max-successes 10 \
  --env staging
```

## Integration Test Rollback

If integration tests fail during Phase 3 staging validation with a failure rate above the 5% threshold, the following procedure determines whether to fix forward or initiate rollback.

```bash
# Check failure rate in DynamoDB solutions table
aws dynamodb scan \
  --table-name eofw-staging-tbl-solutions \
  --filter-expression "contains(#status, :failed)" \
  --expression-attribute-names '{"#status":"status"}' \
  --expression-attribute-values '{":failed":{"S":"FAILED"}}' \
  --select COUNT \
  --region us-west-2

# If failure rate > 5%, roll back to previous Lambda versions
PREVIOUS_TAG=$(git log --format="%h" -n 2 | tail -1)
./scripts/deploy-lambdas.sh staging $PREVIOUS_TAG

# Notify Marcus Patel of the integration test failure
python scripts/send-notification.py \
  --event integration-test-failure \
  --recipient marcus.patel@predictif.com \
  --details "Integration test failure exceeded 5% threshold; rolled back to $PREVIOUS_TAG"
```

---

# Security Validation

Security validation ensures all controls are correctly implemented before production go-live. All security tests are executed by the Security Engineer and results are documented in the Security Test Report (Deliverable 19), reviewed by Marcus Patel.

## Security Test Checklist

### Identity and Authentication

All items below must pass before production go-live is approved.

- [ ] JWT access token expiry enforced: expired tokens rejected with HTTP 401 on all 11 API routes
- [ ] Tampered JWT tokens rejected: token with modified payload rejected with HTTP 401
- [ ] Unsigned JWT tokens rejected: token without valid Cognito RS256 signature rejected with HTTP 401
- [ ] Unauthenticated requests rejected: all routes except `/api/v1/health` return HTTP 401 without Bearer token
- [ ] Role enforcement validated: Consultant role cannot access `/api/v1/admin/usage` (expects HTTP 403)
- [ ] Admin MFA requirement confirmed active in production Cognito User Pool
- [ ] Inactive user suspension Lambda tested: account suspended after simulated 90-day inactivity

### Quota Bypass Prevention

- [ ] Per-user quota bypass via concurrent requests: 20 simultaneous requests result in maximum 10 successes
- [ ] Global quota bypass via multiple users: total solutions cannot exceed 1,000/month global limit
- [ ] Admin quota override requires Admin-role JWT: Consultant JWT cannot call `/api/v1/admin/quota-override`

### Secrets Management

- [ ] GitHub PAT not exposed in CloudWatch Logs for `eofw-prd-fn-github-push`
- [ ] GitHub PAT not exposed in any API response payload
- [ ] Secrets Manager `GetSecretValue` calls logged in CloudTrail with requester identity
- [ ] PAT rotation Lambda successfully rotates the Secrets Manager secret on demand

### IAM and Network

- [ ] IAM Access Analyzer reports zero active findings for all Lambda execution roles
- [ ] No Lambda function has wildcard `*` in IAM action or resource ARN
- [ ] S3 artifact bucket public access block is enabled (all four settings: `true`)
- [ ] ECR image tag mutability is set to `IMMUTABLE`

## Security Test Execution

The following commands execute the automated security test suite. Manual review is required for IAM policy inspection and log analysis.

```bash
# JWT penetration tests — all should return correct rejection codes
cd eofw-platform/tests/security
pytest test_jwt_auth.py \
  --apigw-url "$(cat ../../outputs/staging-compute-outputs.json | jq -r .apigw_endpoint)" \
  -v --tb=short

# IAM policy review using Access Analyzer
aws accessanalyzer list-findings \
  --analyzer-arn $(aws accessanalyzer list-analyzers \
    --region us-west-2 --query 'analyzers[0].arn' --output text) \
  --filter '{"status":{"eq":["ACTIVE"]}}' \
  --region us-west-2
# Expected: empty findings list

# S3 public access block validation
aws s3api get-public-access-block \
  --bucket "$(cat ../../outputs/staging-security-outputs.json | jq -r .artifact_bucket_name)"
# Expected: all four BlockPublicAcls/IgnorePublicAcls/BlockPublicPolicy/RestrictPublicBuckets = true

# ECR container image scan results
aws ecr describe-image-scan-findings \
  --repository-name eofw-staging-ecr-agent-image \
  --image-id imageTag=$(git rev-parse --short HEAD) \
  --region us-west-2 \
  --query 'imageScanFindings.findingSeverityCounts'
# Expected: no CRITICAL findings before production go-live
```

## Security Quality Gates

The following phase-level quality gates must all pass before Marcus Patel signs off on UAT and the CTO approves production deployment.

- [ ] Phase 1 quality gate: no critical/high security findings from initial landing zone scan; security baseline validated
- [ ] Phase 2 quality gate: security controls validated; code coverage > 80%; integration tests > 95% pass rate
- [ ] Phase 3 quality gate: JWT auth penetration passed; quota bypass tests passed; PAT protection validated; pen test complete
- [ ] Production quality gate: production deployment successful; smoke tests pass; CloudWatch green baseline confirmed; support team trained

---

# Migration & Cutover

The AWS Agentic Pre-Sales Orchestration Platform is a greenfield deployment. There is no legacy system cutover from the existing OneDrive/Claude Code CLI workflow, and migration of existing OneDrive artifacts is explicitly out of scope per the SOW. The Amatra team transitions all new engagements to the platform from go-live; existing in-flight engagements continue on the legacy workflow during hypercare.

## Migration Approach

**Type:** Greenfield go-live (no parallel run; no data migration)

The platform launches with a clean DynamoDB state. All quota counters are initialised to zero. The rationale for this approach is that each pre-sales engagement is an independent forward-looking work product with no transactional dependency on historical artifacts. A parallel run would create unnecessary operational complexity without adding safety.

## Cutover Plan

The production cutover is scheduled for Week 12 (hard deadline end of April 2026). The cutover window is estimated at 4 hours, scheduled for early morning US Pacific time (6:00 AM – 10:00 AM PT) to minimise consultant impact.

### Pre-Cutover Checklist

All items must be confirmed before the cutover window opens.

- [ ] All 27 formal deliverables accepted by Marcus Patel and Daniel Park
- [ ] UAT sign-off obtained from Marcus Patel
- [ ] CTO sign-off on production Cognito User Pool obtained
- [ ] Final `terraform plan` for production reviewed and peer-approved
- [ ] Green CloudWatch metrics baseline confirmed in staging (zero critical alarms for 24+ hours)
- [ ] Load test at 200 solutions/month completed with per-solution Bedrock cost < $5
- [ ] Security Test Report reviewed; zero critical findings outstanding
- [ ] DynamoDB PITR restore test completed (4-hour RTO validated)
- [ ] All four operational runbooks reviewed and approved by Daniel Park
- [ ] Knowledge Transfer Sessions 1 and 2 completed and recordings distributed
- [ ] Hypercare on-call roster confirmed; #amatra-platform-hypercare Slack channel ready
- [ ] CLI pip package version 1.0.0 built and ready for publishing

### Cutover Sequence

```bash
# STEP 1: Record cutover start time
echo "CUTOVER STARTED: $(date -u)" | tee -a cutover-log.txt

# STEP 2: Execute final Terraform plan for production; peer-review before apply
cd eofw-platform/infrastructure/environments/production
terraform plan -var-file=production.tfvars -out=production-final.plan 2>&1 | tee -a cutover-log.txt
# [PEER REVIEW REQUIRED — confirm plan shows only expected changes]
terraform apply production-final.plan 2>&1 | tee -a cutover-log.txt

# STEP 3: Validate production Cognito User Pool is Active
aws cognito-idp describe-user-pool \
  --user-pool-id $(terraform output -raw cognito_user_pool_id) \
  --region us-west-2 \
  --query 'UserPool.Status'
# Expected: "Active"

# STEP 4: Smoke-test all 11 API routes with production JWT tokens
python tests/smoke/smoke_test_all_routes.py \
  --env production \
  --apigw-url $(terraform output -raw apigw_endpoint) \
  2>&1 | tee -a cutover-log.txt

# STEP 5: Initialise DynamoDB quota counters to zero for current month
CURRENT_MONTH=$(date +%Y-%m)
aws dynamodb put-item \
  --table-name eofw-prd-tbl-quotas \
  --item "{\"user_id\":{\"S\":\"GLOBAL\"},\"month_key\":{\"S\":\"$CURRENT_MONTH\"},\"counter\":{\"N\":\"0\"}}" \
  --condition-expression "attribute_not_exists(user_id)" \
  --region us-west-2

# STEP 6: Execute E2E generation test in production with synthetic brief
eoframework generate \
  --brief test-data/synthetic-brief-production-smoke.json \
  --env production \
  --wait \
  2>&1 | tee -a cutover-log.txt
# Expected: 12 artifacts generated and committed to GitHub

# STEP 7: Confirm GitHub commit is present in production repository
python tests/smoke/verify_github_commit.py --env production 2>&1 | tee -a cutover-log.txt

# STEP 8: Publish CLI pip package and notify Amatra team
pip publish eoframework-cli-1.0.0
echo "CUTOVER COMPLETE: $(date -u)" | tee -a cutover-log.txt
```

### Go/No-Go Criteria

The following conditions must all be met for go-live approval. If any condition is not met, the cutover is aborted and the rollback procedure is initiated.

- [ ] All 11 API smoke tests return expected status codes
- [ ] E2E generation test completes under 60 minutes with all 12 artifacts passing validation
- [ ] GitHub commit pipeline commits all 12 artifacts with correct commit message format
- [ ] Zero CloudWatch alarms in ALARM state after deployment
- [ ] DynamoDB global quota counter initialised to zero for current month
- [ ] CTO sign-off documented and on file

## Rollback Procedures

If critical issues are identified during or immediately after cutover, the following procedure is executed. The rollback target is the last-known-good pre-cutover state.

**Rollback triggers:** Lambda error rate > 5% sustained for 5 minutes; Bedrock non-transient errors; DynamoDB quota counter corruption detected.

```bash
# STEP 1: Notify stakeholders immediately
python scripts/send-notification.py \
  --event production-rollback \
  --recipients "marcus.patel@predictif.com,daniel.park@predictif.com" \
  --details "Production cutover rollback initiated: $(date -u)"

# STEP 2: Redeploy previous Lambda versions (< 15 minutes)
PREVIOUS_TAG=$(git log --format="%h" -n 2 | tail -1)
./scripts/deploy-lambdas.sh production $PREVIOUS_TAG

# STEP 3: Revert Terraform infrastructure if changed (< 30 minutes)
git revert HEAD --no-edit
git push origin main
# CI/CD pipeline applies the reverted Terraform configuration

# STEP 4: Restore DynamoDB from PITR if data corruption detected (< 4 hours)
aws dynamodb restore-table-to-point-in-time \
  --source-table-name eofw-prd-tbl-quotas \
  --target-table-name eofw-prd-tbl-quotas-restored \
  --restore-date-time "$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ)" \
  --region us-west-2

# STEP 5: Validate rollback success
python tests/smoke/smoke_test_all_routes.py --env production
echo "ROLLBACK COMPLETE: $(date -u)"
```

---

# Operational Handover

The operational handover transfers all platform documentation, runbooks, and institutional knowledge to PREDICTif Solutions at project conclusion, ensuring the Amatra team can operate the platform independently from Day 1 of hypercare.

## Documentation Handover

The following documentation package is delivered to Marcus Patel and Daniel Park in Week 12 as part of the formal project closeout.

### Technical Documentation

- [ ] Architecture Decision Record (ADR) library — all major architecture decisions made during the engagement (Deliverable 1, 25)
- [ ] As-built architecture diagrams — VPC topology, data flow, security architecture, agent call graph (Deliverable 25)
- [ ] Configuration Inventory — `configuration.csv` with all production parameter values populated
- [ ] Terraform IaC source code — all modules with inline documentation committed to PREDICTif's GitHub repository (Deliverable 15)
- [ ] CLI Python package source code — pip packaging configuration, 14 subcommands, unit tests (Deliverable 11)
- [ ] Docker image source — Dockerfile, eof-tools integration, dependency manifests (Deliverable 9)
- [ ] CloudWatch dashboard JSON definitions — exportable for future customisation (Deliverable 20)
- [ ] Phase 2 scope backlog — multi-region HA, additional artifact types, advanced Bedrock model routing candidates (Deliverable 26)

### Operational Documentation

- [ ] Runbook 1 — Quota reset: per-user and global counter reset via admin API and DynamoDB console
- [ ] Runbook 2 — Agent failure recovery: Strands agent restart, AgentCore Runtime health check, retry escalation
- [ ] Runbook 3 — Bedrock throttle handling: exponential backoff configuration, quota increase request process
- [ ] Runbook 4 — GitHub push failure remediation: DLQ inspection, PAT rotation, manual re-push
- [ ] Monitoring guide — CloudWatch dashboard navigation, alarm interpretation, X-Ray service map usage
- [ ] Incident response procedures — P1/P2/P3 definitions, escalation contacts, hypercare Slack channel usage

### User Documentation

- [ ] Administrator Guide (PDF, 50 pages)
- [ ] End User Guide (PDF, 30 pages)
- [ ] Quick Reference Cards (Consultant role and Admin role)
- [ ] FAQ document covering top 20 questions from knowledge transfer sessions

## Support Transition

### Support Model

The following support tiers apply during hypercare (Weeks 13–16) and define the steady-state model post-hypercare.

| Tier | Responsibility | Response Time | Channel | Escalation |
|------|----------------|---------------|---------|------------|
| L1 | Initial triage; known issues per runbooks | P1: 2 hrs; P2: 4 hrs; P3: Next business day | #amatra-platform-hypercare (Slack) | To L2 after 2 hrs (P1), 4 hrs (P2) |
| L2 | Technical troubleshooting; agent and Lambda investigation | P1: 2 hrs from escalation; P2: 4 hrs | Slack + screen share | To L3 after 4 hrs (P1) |
| L3 | Expert resolution; Bedrock escalation to AWS Support | P1: same day; P2: 1 business day | Direct engineering contact | AWS Business Support if Bedrock service issue |

### Hypercare Period

The four-week hypercare period (Weeks 13–16) provides dedicated post-go-live support for issues arising from the implemented solution.

- **Duration:** Four calendar weeks from production go-live date
- **Coverage:** Business hours (9:00 AM – 6:00 PM US Pacific, Monday–Friday)
- **Channel:** Dedicated Slack channel (#amatra-platform-hypercare) with vendor engineering team on-call
- **In Scope:** Bedrock quota issue resolution, agent failure triage, GitHub push failure remediation, CloudWatch alarm investigation, Cognito user management assistance
- **Out of Scope:** Net-new feature development, additional artifact types, multi-region changes

### Transition to Steady-State

The following phased transition moves platform ownership from vendor-led to client-owned over the hypercare period.

- **Weeks 13–14 (Vendor-led, client shadowing):** Vendor team leads all incident responses; Amatra team observes and documents
- **Week 15 (Client-led, vendor backup):** Amatra team leads independently; vendor available for escalation within 4 hours
- **Week 16 (Client-owned, vendor on standby):** Amatra team fully owns operations; vendor available for emergency escalation only; all vendor production access fully revoked at Week 16 conclusion

## Handover Checklist

The following items must be signed off by Marcus Patel and Daniel Park before the engagement is formally closed.

- [ ] All 27 formal deliverables accepted and filed in PREDICTif's GitHub repository
- [ ] Knowledge Transfer Session 1 (CLI & API, 4 hours) completed and recording distributed
- [ ] Knowledge Transfer Session 2 (Agent Operations, 3 hours) completed and recording distributed
- [ ] All four runbooks validated through at least one live dry-run exercise
- [ ] CloudWatch dashboard reviewed with operations team; all widgets understood
- [ ] Vendor production environment access fully revoked at Week 16 conclusion
- [ ] Emergency contacts documented: vendor PM, Solution Architect, ML/AI Engineer on-call
- [ ] AWS Business Support Plan confirmed active on us-west-2 account
- [ ] Project Closeout Report delivered and signed off by Sarah Lin (Deliverable 27)

---

# Training Program

## Training Overview

### Objectives

The training program ensures all user groups — Amatra consultants, platform administrators, and IT support staff — achieve competency with the AWS Agentic Pre-Sales Orchestration Platform before go-live and establishes learning paths for onboarding new team members after hypercare.

### Training Approach

- **Phased Delivery:** Training is delivered in Week 12, aligned with Phase 3 go-live activities
- **Role-Based:** Content is tailored to each audience's responsibilities (Consultant, Admin, IT Support)
- **Hands-On Focus:** All technical modules include lab exercises in the staging environment
- **Recorded Sessions:** All VILT and ILT sessions are recorded and provided as reference assets
- **Documentation:** Complete written materials support self-service learning for new team members

### Training Schedule

The following table lists all twelve training modules with target audience, duration, format, and prerequisites.

| Module ID | Module Name | Target Audience | Duration | Format | Prerequisites |
|-----------|-------------|-----------------|----------|--------|---------------|
| TRN-001 | Platform Architecture Overview | All audiences | 1.5 hours | ILT | None |
| TRN-002 | CLI Authentication and Setup | Consultants | 1 hour | Hands-On Lab | TRN-001 |
| TRN-003 | Solution Generation Workflow | Consultants | 2 hours | Hands-On Lab | TRN-002 |
| TRN-004 | Status Monitoring and Token Usage | Consultants | 1 hour | VILT | TRN-003 |
| TRN-005 | Admin Console and User Management | Administrators | 2 hours | Hands-On Lab | TRN-001 |
| TRN-006 | Quota Management and Override | Administrators | 1.5 hours | Hands-On Lab | TRN-005 |
| TRN-007 | CloudWatch Monitoring and Alerting | Administrators / IT Support | 2 hours | ILT | TRN-001 |
| TRN-008 | Runbook Execution: Agent Failures | IT Support | 2 hours | Hands-On Lab | TRN-007 |
| TRN-009 | Runbook Execution: GitHub Push Failures | IT Support | 1.5 hours | Hands-On Lab | TRN-007 |
| TRN-010 | API Integration and CLI Subcommands | Administrators / IT Support | 3 hours | Hands-On Lab | TRN-001 |
| TRN-011 | Bedrock Token Usage and Cost Governance | Administrators | 1.5 hours | VILT | TRN-005 |
| TRN-012 | Train-the-Trainer Workshop | Internal Trainers (Amatra) | 4 hours | Workshop | All modules |

## Knowledge Transfer Sessions

The two formal knowledge transfer sessions (SOW Deliverables 23 and 24) are delivered in Week 12 to Marcus Patel's team and recorded for future reference.

### Knowledge Transfer Session 1 — CLI & API (4 hours, Deliverable 23)

This session is a hands-on walkthrough of all fourteen CLI subcommands and eleven API routes. It covers the full solution generation lifecycle, per-phase token usage monitoring, and admin quota management. The session is recorded and provided as a reference asset.

**Learning Objectives:**
- Install and authenticate with the `eoframework-cli` pip package via the Cognito PKCE flow
- Execute all fourteen CLI subcommands with correct arguments and interpret all outputs
- Understand the solution generation lifecycle from `generate` through `status` to artifact download
- Navigate all eleven HTTP API v2 routes and understand JWT Bearer token usage
- Monitor per-phase Bedrock token usage via the `status` subcommand and admin `/usage` endpoint
- Manage user quotas using the admin quota-override endpoint and DynamoDB console

**Content Outline:**

1. CLI Installation and Authentication (30 min) — `pip install`, `auth login`, `auth whoami`, credential storage
2. Solution Generation Workflow (60 min) — `generate`, `status`, `list`, graded delivery policy; hands-on lab
3. Artifact Management (30 min) — `artifact download`, `artifact list`, GitHub commit verification
4. Admin Subcommands (30 min) — `admin usage`, `admin quota-override`, `admin suspend-user`
5. API Route Live Demo (30 min) — all 11 routes via Postman/curl with JWT Bearer token
6. Q&A and Hands-On Practice (30 min)

**Materials:** Session recording, CLI Quick Reference Card (per role), Postman collection for all 11 API routes, 5 representative client brief JSON templates.

---

### Knowledge Transfer Session 2 — Agent Operations (3 hours, Deliverable 24)

This session is a technical deep-dive on monitoring and operating the five-agent Strands graph in production. It covers CloudWatch dashboard navigation, X-Ray trace analysis, all four operational runbook dry-runs, and escalation procedures. The session is recorded and provided as a reference asset.

**Learning Objectives:**
- Navigate the CloudWatch dashboard `eofw-prd-health` and interpret all metric widgets
- Read and interpret AWS X-Ray service maps for the five-agent orchestration graph
- Execute all four operational runbooks: quota reset, agent failure recovery, Bedrock throttle handling, GitHub push failure remediation
- Manage DynamoDB quota counters using the admin API and DynamoDB console as fallback
- Identify and escalate Bedrock throttling issues to the AWS Solutions Architect
- Understand graded artifact delivery and how partial results are surfaced to consultants

**Content Outline:**

1. CloudWatch Dashboard Navigation (30 min) — widget-by-widget walkthrough, alarm threshold interpretation
2. X-Ray Service Map and Trace Analysis (30 min) — agent call chain visualisation, trace export for escalation
3. Runbook Dry-Runs (60 min) — live dry-run of all four runbooks with the Amatra team
4. Escalation Procedures (30 min) — P1/P2/P3 severity classification, when to engage AWS Support vs. vendor hypercare
5. Q&A and Hands-On Practice (30 min)

**Materials:** Session recording, all four operational runbooks, CloudWatch dashboard JSON for customisation, escalation contact card.

---

## End User Training

End user training covers all Amatra consultants who will use the platform to generate pre-sales packages. The modules below are delivered in the staging environment with pre-created training user accounts.

### TRN-002: CLI Authentication and Setup (1 hour, Hands-On Lab)

This module gives consultants the foundational skills to install, authenticate, and use the CLI before attempting solution generation.

**Learning Objectives:**
- Install the `eoframework-cli` pip package on macOS and Windows
- Complete the Cognito PKCE authentication flow and understand the 1-hour access / 30-day refresh token lifecycle
- Verify quota status and understand the 10 solutions/user/month limit
- Access help documentation and support resources

**Content Outline:**

1. Installation (15 min) — Python 3.12 prerequisite check; `pip install eoframework-cli`; `eoframework --version`
2. Authentication (25 min) — `eoframework auth login` PKCE browser flow; credential storage at `~/.eoframework/credentials`; `eoframework auth whoami`
3. Quota Awareness (10 min) — `eoframework status --quota`; requesting an admin quota override
4. Support Resources (10 min) — `eoframework --help`; Slack #amatra-platform-support; Quick Reference Card

**Lab Exercise:** Install the CLI, authenticate, and run `eoframework auth whoami` to confirm identity and role assignment.

---

### TRN-003: Solution Generation Workflow (2 hours, Hands-On Lab)

This is the primary end-user training module covering the complete generation workflow from brief submission to artifact download.

**Learning Objectives:**
- Prepare a properly formatted client brief JSON file for submission
- Submit a generation request and interpret the 202 Accepted asynchronous response
- Monitor generation progress with per-phase token usage via `eoframework status`
- Download and verify generated artifacts using `eoframework artifact download`
- Understand the graded delivery policy when some artifacts fail all three retries

**Content Outline:**

1. Brief Preparation (20 min) — required fields, brief templates, common input validation errors
2. Generation Workflow (40 min) — `eoframework generate --wait`; 12-artifact bundle structure; real-time status monitoring
3. Artifact Retrieval (30 min) — `artifact list`; `artifact download`; presigned S3 URL expiry; locating the GitHub commit
4. Graded Delivery and Retry (20 min) — identifying failed artifacts; when to escalate vs. resubmit
5. Hands-On Lab (20 min) — submit a generation request using the provided sample brief; download two artifacts

**Lab Exercise:** Submit a generation request using the provided representative brief template. Monitor progress to completion. Download the `solution-briefing` and `statement-of-work` artifacts and confirm they are correctly formatted.

---

### TRN-004: Status Monitoring and Token Usage (1 hour, VILT)

This module teaches consultants how to monitor solution status and interpret per-phase Bedrock token usage costs displayed in the CLI `status` subcommand.

**Learning Objectives:**
- Interpret the `eoframework status <solution-id>` output including artifact pass/fail status and retry counts
- Understand per-phase token usage costs displayed in the status output
- Identify when a solution needs admin intervention versus self-service retry
- Use the `eoframework list` subcommand to manage multiple concurrent solutions

**Content Outline:**

1. Status Output Interpretation (20 min) — artifact_statuses map; pass/fail/retry fields; per-phase token costs
2. Managing Multiple Solutions (20 min) — `eoframework list` filters; understanding solution lifecycle states
3. When to Escalate (20 min) — graded delivery outcomes; contacting IT Support for agent failures

---

## Administrator Training

### TRN-005: Admin Console and User Management (2 hours, Hands-On Lab)

This module covers Cognito user pool administration, role assignment, and the admin API surface for platform management.

**Learning Objectives:**
- Create and manage Amatra consultant user accounts in the Cognito User Pool
- Assign and modify user roles (Consultant, Admin, Read-Only)
- View all solutions across all users using the admin API
- Suspend and reactivate user accounts for SOC 2 CC6.2 compliance

**Content Outline:**

1. Cognito User Pool Administration (45 min) — user creation, role assignment, password reset, MFA for Admin users
2. Solution and User API Administration (45 min) — `eoframework admin usage`; `GET /api/v1/admin/usage`; `POST /api/v1/admin/users/{id}/suspend`
3. Audit Log Review (20 min) — DynamoDB `audit_events` table navigation; CloudTrail event search for SOC 2 evidence
4. Hands-On Lab (10 min) — create a test user, assign a role, view their solutions, and suspend the account

---

### TRN-007: CloudWatch Monitoring and Alerting (2 hours, ILT)

This module builds administrator proficiency in using the CloudWatch dashboard, managing alarms, and using X-Ray for agent call chain debugging.

**Learning Objectives:**
- Navigate the `eofw-prd-health` CloudWatch dashboard and interpret all metric widgets
- Investigate and acknowledge CloudWatch alarms
- Query CloudWatch Log Insights for Lambda error logs by `solution_id` and `artifact_type`
- Navigate X-Ray service maps and traces for agent call chain debugging

**Content Outline:**

1. CloudWatch Dashboard Navigation (30 min) — widget walkthrough; metric dimensions; time range and auto-refresh
2. Alarm Management (30 min) — alarm state review; acknowledging alarms during planned maintenance
3. Log Insights Queries (30 min) — querying by `solution_id`; retry exhaustion events; saving custom queries
4. X-Ray Tracing (30 min) — service map navigation; trace detail view; exporting traces for vendor escalation

---

## IT Support Training

### TRN-008: Runbook Execution — Agent Failures (2 hours, Hands-On Lab)

This module gives IT Support staff the skills to execute Runbooks 1 and 2 (quota reset and agent failure recovery) independently.

**Learning Objectives:**
- Execute Runbook 1: reset per-user and global quota counters via the admin API and DynamoDB console
- Execute Runbook 2: identify a failed agent in AgentCore Runtime; trigger a restart; validate recovery
- Recognise when an agent failure requires vendor hypercare escalation
- Document resolution steps in the DynamoDB `audit_events` table

**Content Outline:**

1. Quota Reset Walkthrough and Dry-Run (40 min) — admin API path; DynamoDB console fallback; validation steps
2. Agent Failure Recovery Walkthrough and Dry-Run (60 min) — CloudWatch log diagnosis; AgentCore health check; Lambda restart
3. Escalation Decision Tree (20 min) — self-service vs. L2 vs. hypercare criteria

---

### TRN-009: Runbook Execution — GitHub Push Failures (1.5 hours, Hands-On Lab)

This module covers DLQ inspection, PAT rotation, and manual artifact re-push (Runbook 4).

**Learning Objectives:**
- Inspect the SQS FIFO DLQ to identify failed GitHub push messages
- Rotate the GitHub PAT in Secrets Manager using the rotation Lambda
- Manually re-push artifacts from the DLQ using the provided script
- Confirm successful GitHub commit after remediation

**Content Outline:**

1. DLQ Inspection (20 min) — SQS console navigation; message body structure; commit message format
2. PAT Rotation (30 min) — Secrets Manager console; `aws secretsmanager rotate-secret` CLI command
3. Manual Re-Push (30 min) — `python scripts/reprocess-dlq.py`; GitHub commit verification
4. Hands-On Lab (10 min) — simulate a DLQ message and execute the re-push procedure

---

## Training Materials

### Documentation Provided

The following materials are delivered to all participants at or before training delivery.

- Administrator Guide (PDF, 50 pages) — delivered to Admin and IT Support participants
- End User Guide (PDF, 30 pages) — delivered to all Consultant participants
- CLI Quick Reference Card (Consultant role) — one per consultant
- CLI Quick Reference Card (Admin role) — one per admin
- Video recordings of Knowledge Transfer Sessions 1 and 2 — shared within 24 hours
- Lab exercise workbooks for hands-on modules (TRN-002, TRN-003, TRN-005, TRN-007, TRN-008, TRN-009)
- Sample brief templates (5 representative client brief JSON files for lab exercises)

### Training Environment

The training environment is the staging Cognito User Pool and staging environment, with pre-created participant user accounts and a pre-loaded set of synthetic solution bundles for reference.

- Staging environment with synthetic test briefs and representative generated artifacts
- Staging Cognito User Pool with one pre-created training user account per participant
- Environment is reset to a clean state before each training session
- Training access provided two weeks before go-live to allow self-paced pre-study

## Training Effectiveness

### Assessment Approach

- **Knowledge Checks:** Short quiz at the end of each module (minimum 70% pass required for completion credit)
- **Practical Assessment:** Successfully complete the lab exercise for each hands-on module
- **Competency Validation:** Demonstrate the ability to complete a full generation workflow independently in the staging environment before go-live

### Success Metrics

The following metrics define training programme success and are measured within the first two weeks post-go-live.

| Metric | Target |
|--------|--------|
| Training Completion Rate | 100% of assigned users complete required modules before go-live |
| Knowledge Check Pass Rate | ≥85% first attempt across all modules |
| Post-Training Satisfaction | ≥4.0/5.0 average across all participants |
| Time to First Independent Generation | ≤2 days after completing TRN-003 |
| Runbook Execution Accuracy | ≥90% of dry-run exercises completed without facilitator intervention |

---

# Appendices

## Appendix A: Environment Configuration Reference

### Development Environment

The development environment uses shorter retention periods and reduced security controls to reduce cost during the build phase.

| Parameter | Value |
|-----------|-------|
| Region | `us-west-2` |
| Resource Prefix | `eofw-dev-` |
| VPC CIDR | `10.0.0.0/16` |
| DynamoDB Billing | On-Demand |
| CloudTrail S3 Data Events | Disabled |
| X-Ray Sampling | 100% |
| CloudWatch Log Retention (Lambda) | 30 days |
| CloudWatch Log Retention (CloudTrail) | 90 days |
| DynamoDB PITR | Disabled |
| Cognito MFA | Disabled |
| KMS CMK | No (SSE-S3 default) |
| Access Method | IAM role with developer boundary |

### Production Environment

The production environment applies full security controls, retention policies, and observability as defined in the SOW.

| Parameter | Value |
|-----------|-------|
| Region | `us-west-2` |
| Resource Prefix | `eofw-prd-` |
| VPC CIDR | `10.0.0.0/16` |
| DynamoDB Billing | On-Demand |
| CloudTrail S3 Data Events | Enabled (artifact bucket) |
| X-Ray Sampling | 5% |
| CloudWatch Log Retention (Lambda) | 90 days |
| CloudWatch Log Retention (CloudTrail) | 365 days |
| DynamoDB PITR | Enabled (35-day window) |
| Cognito MFA | Required for Admin role |
| KMS CMK | Yes (S3 artifact bucket, 90-day rotation) |
| Access Method | Cognito JWT + Admin MFA |

## Appendix B: Deployment Scripts Reference

### deploy-lambdas.sh

This script deploys all seventeen Lambda function code packages to the target environment. It is invoked by the GitHub Actions CI/CD pipeline and can also be run manually for targeted rollbacks.

```bash
#!/bin/bash
# deploy-lambdas.sh — Deploy all 17 Lambda function code packages
set -e

ENV=${1:-dev}
IMAGE_TAG=${2:-$(git rev-parse --short HEAD)}
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
REGION=us-west-2
PKG_BUCKET="eofw-$ENV-s3-lambda-packages-$ACCOUNT"
ECR_URI="$ACCOUNT.dkr.ecr.$REGION.amazonaws.com/eofw-$ENV-ecr-agent-image:$IMAGE_TAG"

echo "Deploying to $ENV (tag: $IMAGE_TAG)"

# Deploy ZIP-based API route handler Lambdas (10 functions)
ZIP_FUNCTIONS=(
  "solution-initiator" "solution-status" "solution-list" "artifact-download"
  "solution-cancel" "auth-me" "auth-refresh" "admin-usage"
  "admin-quota-override" "health-check" "admin-suspend-user"
)
for fn in "${ZIP_FUNCTIONS[@]}"; do
  aws lambda update-function-code \
    --function-name "eofw-$ENV-fn-$fn" \
    --s3-bucket "$PKG_BUCKET" \
    --s3-key "functions/$IMAGE_TAG/$fn-package.zip" \
    --region $REGION --no-cli-pager
  echo "Updated eofw-$ENV-fn-$fn"
done

# Deploy container image-based agent trigger Lambdas (5 functions)
AGENT_FUNCTIONS=(
  "agent-input-validator" "agent-presales-generator"
  "agent-delivery-generator" "agent-code-generator" "agent-eo-validator"
)
for fn in "${AGENT_FUNCTIONS[@]}"; do
  aws lambda update-function-code \
    --function-name "eofw-$ENV-fn-$fn" \
    --image-uri "$ECR_URI" \
    --region $REGION --no-cli-pager
  echo "Updated eofw-$ENV-fn-$fn to $IMAGE_TAG"
done

# Deploy remaining Lambdas
for fn in "cognito-post-confirmation" "github-push" "suspend-inactive-users"; do
  aws lambda update-function-code \
    --function-name "eofw-$ENV-fn-$fn" \
    --s3-bucket "$PKG_BUCKET" \
    --s3-key "functions/$IMAGE_TAG/$fn-package.zip" \
    --region $REGION --no-cli-pager
  echo "Updated eofw-$ENV-fn-$fn"
done

echo "All 17 Lambda functions deployed: $IMAGE_TAG"
```

### rollback.sh

This script rolls back all Lambda functions to a specified previous tag and optionally reverts Terraform infrastructure state.

```bash
#!/bin/bash
# rollback.sh — Roll back Lambda functions to a previous known-good state
set -e

ENV=${1:-production}
PREVIOUS_TAG=${2:-}
ROLLBACK_INFRA=${3:-false}

if [ -z "$PREVIOUS_TAG" ]; then
  PREVIOUS_TAG=$(git log --format="%h" -n 2 | tail -1)
  echo "No tag specified; using previous commit: $PREVIOUS_TAG"
fi

echo "ROLLBACK STARTED: $(date -u) — ENV=$ENV TARGET=$PREVIOUS_TAG"

# Roll back Lambda function code to previous tag
./scripts/deploy-lambdas.sh "$ENV" "$PREVIOUS_TAG"

# Optionally roll back Terraform infrastructure
if [ "$ROLLBACK_INFRA" = "true" ]; then
  echo "Rolling back Terraform infrastructure..."
  cd infrastructure/environments/$ENV
  git checkout "$PREVIOUS_TAG" -- .
  terraform apply -var-file=$ENV.tfvars -auto-approve
  git checkout HEAD -- .
fi

echo "ROLLBACK COMPLETE: $(date -u)"
```

## Appendix C: Troubleshooting Guide

### Issue: Lambda returns 401 Unauthorized unexpectedly

**Symptoms:** CLI returns `Error: 401 Unauthorized` after previously successful authentication.

**Cause:** Cognito access token expired (1-hour expiry) or refresh token is stale.

**Resolution:**

```bash
# Clear cached credentials and re-authenticate
rm ~/.eoframework/credentials
eoframework auth login
eoframework auth whoami
```

**Prevention:** The CLI handles refresh token rotation automatically on each invocation. If the issue recurs, verify the system clock is NTP-synchronised.

---

### Issue: Generation request times out before all 12 artifacts are produced

**Symptoms:** `eoframework status <id>` shows artifacts in `PENDING` or `RETRYING` state after 60 minutes.

**Cause:** Bedrock Claude Sonnet 4.6 throttling causing the three-retry loop to consume extra time.

**Resolution:**

```bash
# Check Bedrock throttle alarm
aws cloudwatch describe-alarms \
  --alarm-names "eofw-prd-bedrock-throttle" \
  --region us-west-2 \
  --query 'MetricAlarms[0].StateValue'

# Check per-artifact retry counts in DynamoDB
aws dynamodb get-item \
  --table-name eofw-prd-tbl-solutions \
  --key '{"solution_id":{"S":"<your-solution-id>"}}' \
  --projection-expression "artifact_statuses" \
  --region us-west-2 | jq '.Item.artifact_statuses.M'

# Request quota increase via AWS Service Quotas console if sustained
# Navigate to: Service Quotas > Amazon Bedrock > Invoke model
```

**Prevention:** Monitor the Bedrock throttle CloudWatch alarm. Request quota increases proactively when usage approaches 80% of provisioned throughput.

---

### Issue: GitHub commit pipeline fails; artifacts not committed to repository

**Symptoms:** `eoframework status <id>` shows `github_push: FAILED`; DLQ depth > 0 alarm fires.

**Cause:** GitHub PAT may have expired or been revoked.

**Resolution:**

```bash
# Check DLQ message count
aws sqs get-queue-attributes \
  --queue-url $(aws sqs get-queue-url \
    --queue-name eofw-prd-sqs-github-dlq.fifo \
    --region us-west-2 --query QueueUrl --output text) \
  --attribute-names ApproximateNumberOfMessages \
  --region us-west-2

# Rotate the GitHub PAT (follow Runbook 4)
aws secretsmanager rotate-secret \
  --secret-id eofw/prd/github-pat \
  --region us-west-2

# Reprocess failed messages from the DLQ
python scripts/reprocess-dlq.py --env production
```

**Prevention:** The 90-day PAT rotation in Secrets Manager prevents expiry under normal conditions. Monitor the DLQ depth CloudWatch alarm.

---

### Issue: DynamoDB quota counter shows unexpected value

**Symptoms:** Admin receives quota alarm before expected usage level; users report unexpected HTTP 429 responses.

**Cause:** Counter initialisation error at month rollover or an admin override that left the counter in an unexpected state.

**Resolution:**

```bash
# Check current quota counter value
CURRENT_MONTH=$(date +%Y-%m)
aws dynamodb get-item \
  --table-name eofw-prd-tbl-quotas \
  --key "{\"user_id\":{\"S\":\"GLOBAL\"},\"month_key\":{\"S\":\"$CURRENT_MONTH\"}}" \
  --region us-west-2

# Reset via admin API (preferred — creates audit trail)
eoframework admin quota-override GLOBAL $CORRECT_COUNT

# Or reset directly in DynamoDB as last resort
aws dynamodb update-item \
  --table-name eofw-prd-tbl-quotas \
  --key "{\"user_id\":{\"S\":\"GLOBAL\"},\"month_key\":{\"S\":\"$CURRENT_MONTH\"}}" \
  --update-expression "SET #cnt = :val" \
  --expression-attribute-names '{"#cnt":"counter"}' \
  --expression-attribute-values "{\":val\":{\"N\":\"$CORRECT_COUNT\"}}" \
  --region us-west-2
```

## Appendix D: Contact Information

### Project Team

The following vendor team members are the primary contacts during the engagement and hypercare period.

| Role | Email | Availability |
|------|-------|--------------|
| Project Manager | pm@amatra.com | Business hours US PT |
| Solution Architect | architect@amatra.com | Business hours US PT |
| ML/AI Engineer | ml@amatra.com | Business hours US PT |
| DevOps Engineer | devops@amatra.com | Business hours US PT |
| Security Engineer | security@amatra.com | Business hours US PT |

### Client Stakeholders

| Role | Name | Email | Availability |
|------|------|-------|--------------|
| Director of Pre-Sales Engineering | Marcus Patel | marcus.patel@predictif.com | Business hours US PT |
| Head of Delivery Operations | Daniel Park | daniel.park@predictif.com | Business hours US PT |
| Chief Revenue Officer (Executive Sponsor) | Sarah Lin | sarah.lin@predictif.com | By appointment |
| CTO (production sign-off authority) | TBD | TBD | By appointment |

### Escalation Contacts

| Level | Contact | Availability | When to Escalate |
|-------|---------|--------------|------------------|
| L1 Hypercare | #amatra-platform-hypercare (Slack) | Mon–Fri 9AM–6PM PT | All P1/P2/P3 issues during hypercare |
| L2 Vendor Engineering | vendor-oncall@amatra.com | Business hours | P1 after L1 2-hour timeout |
| L3 AWS Support | AWS Business Support portal | 24×7 | Bedrock service outages, AgentCore Runtime failures |

### Vendor Support Contacts

| Vendor | Support Portal | SLA |
|--------|----------------|-----|
| AWS Business Support | https://console.aws.amazon.com/support | P1: <1 hour; P2: <4 hours |
| GitHub Support | https://support.github.com | Business hours |

---

*Implementation Guide — AWS Agentic Pre-Sales Orchestration Platform — Version 1.0 — Amatra EO Framework Practice — June 2025*
