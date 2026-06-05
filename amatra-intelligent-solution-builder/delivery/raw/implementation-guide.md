---
document_title: Implementation Guide
solution_name: Amatra Agentic Pre-Sales Platform on AWS
document_version: "1.0"
author: Amatra Engagement Lead
last_updated: 2026-06-05
technology_provider: aws
client_name: PREDICTif Solutions
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

## Project Overview

This Implementation Guide provides step-by-step procedures for deploying the **Amatra Agentic Pre-Sales Platform on AWS** for PREDICTif Solutions. The engagement transforms PREDICTif's current manual pre-sales documentation workflow into a fully automated, serverless agentic platform — eliminating six to ten hours of senior-consultant effort per engagement and enabling the sales organisation to generate complete, validated EO Framework solution packages end-to-end in under one hour.

The platform is built on Amazon Bedrock AgentCore Runtime, Strands Agents, and Claude Sonnet 4.6 / Haiku 4.5. It exposes a pip-installable fourteen-subcommand CLI and an eleven-route JWT-protected HTTP API. The implementation follows a three-phase approach across twelve weeks, with a hard deadline of end-of-April 2026 for the executive sponsor demonstration to Sarah Lin (CRO).

## Implementation Scope

The following items define what is included and excluded from this engagement.

- **In Scope:**
  - All AWS infrastructure in us-west-2: Cognito, API Gateway, Lambda, DynamoDB, S3, ECR, AgentCore, Step Functions, Secrets Manager, CloudWatch, VPC
  - Five Bedrock AgentCore agents (Input Validator, Pre-Sales Generator, Delivery Generator, Code Generator, EO Validator) orchestrated via AWS Step Functions
  - pip-installable CLI with fourteen subcommands and eleven JWT-protected HTTP API Lambda routes
  - Per-user (10 solutions/month) and global (1,000 solutions/month) quota enforcement via atomic DynamoDB conditional writes
  - eof-tools converter library (~30 Python modules) integrated into the AgentCore container image
  - Terraform IaC for the complete platform with `terraform validate` as a CI syntax gate
  - Per-artifact format-check and LLM quality-check validation with up to three automated retries
  - Automated GitHub artifact commits via Secrets Manager–stored PAT
  - CloudWatch dashboards, alarms, and green metrics baseline
  - Full as-built documentation, operational runbooks, and knowledge-transfer sessions
  - Eight-week post-go-live hypercare support

- **Out of Scope:**
  - Migration of existing legacy us-east-1 AWS workloads
  - Graphical user interface (GUI) or web portal
  - CRM, PSA, or sales-force automation integrations
  - Custom ML model training or fine-tuning
  - Multi-region deployment or active-active high-availability
  - Refactoring of the eof-tools converter library
  - SOC 2 Type II audit or formal compliance certification

- **Critical Dependencies:**
  - AWS us-west-2 account access provisioned by Client IT Lead (Week 1, Day 1)
  - CTO sign-off on Cognito User Pool design (Week 3)
  - eof-tools SME availability confirmed (Week 5)
  - Bedrock AgentCore GA availability and quota in us-west-2 confirmed (Week 5)
  - Public GitHub repository write access granted (Week 7)
  - UAT participants available (Marcus Patel, Daniel Park, CTO) in Week 11

## Timeline Overview

The project spans twelve weeks with an eight-week hypercare period following go-live.

- **Project Duration:** 12 weeks (Q1–Q2 2026)
- **Go-Live Date:** End of Week 12 / April 2026
- **Hypercare Period:** Weeks 13–20 (8 weeks)
- **Key Milestones:**
  - M1 – Kickoff Complete: Week 1
  - M2 – Foundation Live (Cognito, API GW, DynamoDB, S3, IAM): Week 4
  - M3 – First End-to-End Generation (twelve-artifact bundle): Week 7
  - M4 – Agent Integration Complete (all 5 agents, 14 CLI subcommands, 11 API routes): Week 9
  - M5 – UAT Sign-Off (Marcus Patel, Daniel Park, CTO): Week 11
  - M6 – Green CloudWatch Baseline Certified: Week 12
  - M7 – Go-Live (Full platform in production us-west-2): End of Week 12
  - M8 – Executive Sponsor Demo (Sarah Lin, CRO): End of April 2026
  - M9 – Hypercare End + Phase 2 Roadmap: Week 20

---

# Prerequisites

## Technical Prerequisites

Complete all items below before starting Phase 1. Each item is a hard dependency that blocks environment provisioning or agent registration if unresolved.

### Cloud Infrastructure

- [ ] AWS us-west-2 account created and account ID confirmed with Client IT Lead
- [ ] Administrator-equivalent IAM access provisioned for Amatra vendor team
- [ ] Billing alerts configured at $10,000/month threshold
- [ ] Resource quotas verified: Lambda concurrency ≥ 500, Bedrock RPM for Claude Sonnet 4.6 and Haiku 4.5 at 200 solutions/month
- [ ] Service Control Policies reviewed: Bedrock, AgentCore, ECR, and Step Functions not blocked in us-west-2
- [ ] AWS Business Support plan activated
- [ ] Cost Allocation Tags strategy agreed (project, phase, environment)

### Network Connectivity

- [ ] VPC CIDR `10.0.0.0/16` planned in us-west-2 with three Availability Zones
- [ ] Private subnets in at least 2 AZs: `10.0.1.0/24`, `10.0.2.0/24`, `10.0.3.0/24`
- [ ] Public subnet `10.0.100.0/24` for NAT Gateway
- [ ] NAT Gateway planned for GitHub API and PyPI outbound traffic
- [ ] VPC interface endpoints planned: Bedrock, DynamoDB, S3, Secrets Manager, ECR, CloudWatch Logs
- [ ] Security group egress rules defined: Lambda → NAT Gateway and VPC endpoint CIDRs only

### Security Baseline

- [ ] IAM permission boundaries scoped and approved by Client IT Lead
- [ ] Break-glass IAM role defined (MFA-protected, time-limited for hypercare)
- [ ] KMS Customer Managed Key (CMK) planned for data encryption
- [ ] Secrets Manager secret stubs created: `amatra/github-pat`, `amatra/cognito-client-secret`
- [ ] GuardDuty enablement planned on us-west-2 account
- [ ] CloudTrail data events planned for S3 and DynamoDB

### Development Tools

- [ ] Git repository access configured for Amatra team
- [ ] Docker Desktop installed on all developer machines (minimum Docker 24.x)
- [ ] Terraform v1.7+ installed and `terraform version` verified
- [ ] AWS CLI v2.x installed and configured (`aws configure --profile amatra-dev`)
- [ ] Python 3.11+ installed and `pip install amatra-cli` tested in a clean virtual environment
- [ ] ECR repository `amatra-agents` created in us-west-2

### Bedrock and AgentCore Prerequisites

- [ ] Amazon Bedrock model access approved: Claude Sonnet 4.6 and Claude Haiku 4.5 in us-west-2
- [ ] Bedrock AgentCore Runtime confirmed Generally Available in us-west-2
- [ ] Bedrock service quota request submitted: 200 solutions/month ≈ 5M–25M tokens/month
- [ ] eof-tools library confirmed stable and passing all self-tests in a containerised Linux environment

## Organisational Prerequisites

All named stakeholders and the full vendor team must be confirmed before Week 1 kickoff.

- [ ] Amatra engagement team fully assigned: Engagement Lead, Cloud Engineer, ML/AI Engineer, 2× Solutions Engineers, DevOps Engineer, Security Engineer, QA Engineer, Technical Writer, Project Manager
- [ ] PREDICTif stakeholders confirmed: Sarah Lin (CRO/Executive Sponsor), Marcus Patel (Director Pre-Sales Engineering), Daniel Park (Head of Delivery Operations), CTO (production sign-off), Client IT Lead, eof-tools SME
- [ ] Weekly cadence meetings scheduled: status with Marcus Patel (weekly), executive summary to Sarah Lin (weekly), architecture review (bi-weekly)
- [ ] RAID log created and shared with Marcus Patel
- [ ] Change control process activated (CR template agreed)
- [ ] Budget approved: Professional Services $220,000 net; Cloud Infrastructure $58,920 Year 1 net

## Environmental Readiness

Each environment requires its own confirmation checklist before Phase 1 begins.

### Development Environment

- [ ] Development AWS IAM profile accessible by all Amatra engineers
- [ ] Development VPC and subnets provisioned
- [ ] CI/CD pipeline connected to dev environment
- [ ] Developer IAM roles provisioned with least-privilege boundaries
- [ ] ECR repository accessible from development environment

### Staging Environment

- [ ] Staging IAM role boundary confirmed
- [ ] Staging environment mirrors production architecture sizing
- [ ] Terraform staging backend S3 bucket and DynamoDB lock table provisioned
- [ ] QA team access provisioned for UAT execution in Week 11

### Production Environment

- [ ] Production deployment gated on CTO sign-off (Cognito User Pool activation gate)
- [ ] Production IAM roles and permission boundaries pre-approved
- [ ] Production KMS keys and Secrets Manager secrets provisioned
- [ ] CloudWatch monitoring and alerting configured
- [ ] On-call rotation and P1 escalation path documented and agreed with Daniel Park

---

# Environment Setup

This section details the three implementation phases, their objectives, activities, and success criteria. Phase 1 establishes foundation infrastructure; Phase 2 delivers the agentic core; Phase 3 validates and goes live.

## Phase 1 — Foundation and Security (Weeks 1–4)

### Objectives

Phase 1 establishes the AWS landing zone, identity, and security baseline before any agent code is written. This phase de-risks the engagement by ensuring authentication, quota enforcement, and storage are production-grade from the outset.

- Establish AWS landing zone and VPC in us-west-2
- Deploy Amazon Cognito User Pool and obtain CTO sign-off
- Provision DynamoDB quota tables and API Gateway route stubs
- Configure Secrets Manager, KMS, GuardDuty, and CloudTrail
- Deliver CLI authentication subcommands (login, logout, token-refresh)

### Activities

The following table lists all Phase 1 activities, owners, durations, and dependencies.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Project kickoff and stakeholder alignment | Project Manager | 1 day | Signed SOW |
| Current state assessment and gap analysis | Solution Architect | 3 days | Kickoff |
| AWS landing zone setup (VPC, IAM, tags) | Cloud Engineer | 4 days | Account access |
| Cognito User Pool design and CTO briefing | Security Engineer | 3 days | Landing zone |
| DynamoDB schema design and provisioning | Solutions Engineer | 2 days | Landing zone |
| API Gateway + Lambda route stubs | Solutions Engineer | 3 days | Cognito design |
| Secrets Manager and KMS configuration | Security Engineer | 2 days | Landing zone |
| VPC endpoints and security groups | Cloud Engineer | 2 days | Landing zone |
| GuardDuty and CloudTrail data events | Security Engineer | 1 day | Landing zone |
| CLI auth subcommands (login/logout/refresh) | Solutions Engineer | 3 days | Cognito |
| CTO sign-off on Cognito User Pool | CTO | 1 day | Cognito design |
| Phase 1 acceptance report | Project Manager | 1 day | All above |

### Detailed Procedures

#### 1.1 AWS Landing Zone Bootstrap

Begin by initialising the Terraform backend and deploying the foundational VPC, IAM, and tagging infrastructure.

```bash
# Clone the Amatra platform repository
git clone https://github.com/predictif/amatra-platform.git
cd amatra-platform/infrastructure/landing-zone

# Initialise Terraform backend
terraform init \
  -backend-config="bucket=amatra-tfstate-us-west-2" \
  -backend-config="key=landing-zone/terraform.tfstate" \
  -backend-config="region=us-west-2" \
  -backend-config="dynamodb_table=amatra-tf-locks"

# Review and apply
terraform plan -var-file=dev.tfvars -out=landing-zone.plan
terraform apply landing-zone.plan
```

Expected output:

```
Apply complete! Resources: 47 added, 0 changed, 0 destroyed.
Outputs:
vpc_id          = "vpc-0a1b2c3d4e5f67890"
private_subnets = ["subnet-111aaa", "subnet-222bbb", "subnet-333ccc"]
nat_gateway_id  = "nat-0abcd1234ef567890"
```

#### 1.2 Cognito User Pool Provisioning

Deploy the Cognito User Pool with thirty-day refresh tokens and the post-confirmation Lambda trigger.

```bash
cd ../cognito

terraform plan \
  -var-file=dev.tfvars \
  -var="post_confirmation_lambda_arn=$(aws lambda get-function \
    --function-name amatra-post-confirmation-dev \
    --query 'Configuration.FunctionArn' --output text)" \
  -out=cognito.plan

terraform apply cognito.plan

# Verify User Pool is ACTIVE
aws cognito-idp describe-user-pool \
  --user-pool-id $(terraform output -raw user_pool_id) \
  --query 'UserPool.Status'
```

#### 1.3 DynamoDB Tables Provisioning

Provision the three DynamoDB tables with on-demand capacity and point-in-time recovery enabled.

```bash
cd ../dynamodb
terraform plan -var-file=dev.tfvars -out=dynamodb.plan
terraform apply dynamodb.plan

# Validate PITR is enabled on all three tables
for TABLE in user_profiles solution_state quota_global; do
  STATUS=$(aws dynamodb describe-continuous-backups \
    --table-name amatra-${TABLE}-dev \
    --query 'ContinuousBackupsDescription.PointInTimeRecoveryDescription.PointInTimeRecoveryStatus' \
    --output text)
  echo "amatra-${TABLE}-dev PITR: $STATUS"
done
```

Expected output:

```
amatra-user_profiles-dev PITR: ENABLED
amatra-solution_state-dev PITR: ENABLED
amatra-quota_global-dev PITR: ENABLED
```

### Deliverables

- [ ] AWS landing zone (VPC, IAM, tags) operational in us-west-2
- [ ] Cognito User Pool live with post-confirmation Lambda trigger
- [ ] DynamoDB tables `user_profiles`, `solution_state`, `quota_global` provisioned with PITR
- [ ] API Gateway HTTP API v2 with JWT authoriser and eleven route stubs
- [ ] Secrets Manager secrets created for GitHub PAT and Cognito client secret
- [ ] VPC endpoints deployed for Bedrock, DynamoDB, S3, Secrets Manager, ECR, CloudWatch Logs
- [ ] GuardDuty and CloudTrail data events enabled
- [ ] CLI login/logout/token-refresh subcommands functional
- [ ] CTO sign-off on Cognito User Pool obtained and recorded in RAID log
- [ ] Foundation Infrastructure Acceptance Report accepted by Marcus Patel

### Success Criteria

- Cognito User Pool returns a valid JWT on successful CLI login
- Post-confirmation Lambda writes user profile to DynamoDB on new user sign-up
- JWT authoriser rejects unauthenticated API requests with HTTP 401
- DynamoDB conditional write test confirms atomic quota enforcement under 10 concurrent writes
- All VPC endpoints in `available` state; no internal traffic traverses NAT Gateway for AWS service calls

## Phase 2 — Agents and Integration (Weeks 5–9)

### Objectives

Phase 2 delivers the core agentic platform: all five Strands agents on Bedrock AgentCore Runtime, the eof-tools container pipeline, Step Functions orchestration, and the complete CLI and API surface.

- Register five AgentCore agents with eof-tools baked into the Docker image
- Implement Step Functions orchestration state machine
- Complete all fourteen CLI subcommands and eleven Lambda API routes
- Integrate GitHub artifact commit workflow via Secrets Manager PAT
- Establish CodePipeline CI/CD and Terraform IaC full-platform modules

### Activities

The following table lists Phase 2 activities in execution sequence.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Agent graph design (Strands framework) | Solution Architect | 5 days | Phase 1 complete |
| Docker image build with eof-tools | DevOps Engineer | 5 days | Phase 1 complete |
| Bedrock AgentCore agent registration | Solutions Engineer | 4 days | Docker images in ECR |
| Step Functions state machine | Solutions Engineer | 4 days | Agents registered |
| Bedrock model integration and prompts | ML/AI Engineer | 5 days | Agents registered |
| Quota enforcement implementation | Solutions Engineer | 3 days | DynamoDB tables |
| All 11 Lambda routes (JWT-protected) | Solutions Engineer | 6 days | API GW stubs |
| Complete CLI (14 subcommands) | Solutions Engineer | 5 days | Lambda routes |
| GitHub PAT commit integration | Solutions Engineer | 2 days | Secrets Manager PAT |
| CI/CD pipeline (CodePipeline + CodeBuild) | DevOps Engineer | 4 days | ECR images |
| Terraform IaC full-platform modules | DevOps Engineer | 5 days | All components |
| Token usage instrumentation | ML/AI Engineer | 2 days | All agents |
| Security hardening | Security Engineer | 3 days | All components |
| Agent Integration Milestone Report | Project Manager | 1 day | All above |

### Detailed Procedures

#### 2.1 Docker Image Build and ECR Push

Build the agent container image with eof-tools baked in and push to ECR.

```bash
cd containers/amatra-agent

# Authenticate to ECR
aws ecr get-login-password --region us-west-2 | \
  docker login --username AWS \
  --password-stdin 123456789012.dkr.ecr.us-west-2.amazonaws.com

# Build and tag
docker build --build-arg EOF_TOOLS_VERSION=2.4.1 -t amatra-agents:1.0.0 .
docker tag amatra-agents:1.0.0 \
  123456789012.dkr.ecr.us-west-2.amazonaws.com/amatra-agents:1.0.0
docker push 123456789012.dkr.ecr.us-west-2.amazonaws.com/amatra-agents:1.0.0

# Verify all 12 artifact-type converters pass
docker run --rm amatra-agents:1.0.0 python -m eof_tools.validate_converters
```

Expected output:

```
Validating 12 artifact converters...
  [PASS] solution-briefing (PPTX)    [PASS] statement-of-work (DOCX)
  [PASS] level-of-effort-estimate (XLSX)  [PASS] infrastructure-costs (XLSX)
  [PASS] discovery-questionnaire (XLSX)   [PASS] detailed-design (DOCX)
  [PASS] implementation-guide (DOCX)  [PASS] test-plan (DOCX)
  [PASS] runbook (DOCX)               [PASS] training-plan (XLSX)
  [PASS] project-closure (DOCX)       [PASS] terraform-bundle (IaC ZIP)
All 12 converters validated successfully.
```

#### 2.2 AgentCore Agent Registration

Register all five Strands agents in Bedrock AgentCore Runtime using the registration script.

```bash
cd scripts

for AGENT in input-validator presales-generator delivery-generator code-generator eo-validator; do
  python register_agent.py \
    --agent-name "amatra-${AGENT}-dev" \
    --image-uri "123456789012.dkr.ecr.us-west-2.amazonaws.com/amatra-agents:1.0.0" \
    --role-arn "arn:aws:iam::123456789012:role/amatra-${AGENT}-execution-role" \
    --region us-west-2
done

# Verify all agents are ACTIVE
aws bedrock-agentcore list-agents \
  --query 'agents[?contains(agentName,`amatra`)].{Name:agentName,Status:agentStatus}' \
  --output table
```

### Deliverables

- [ ] All five Bedrock AgentCore agents registered and ACTIVE
- [ ] Docker image in ECR; all 12 artifact-type converters validated
- [ ] Step Functions orchestration state machine deployed and smoke-tested
- [ ] All fourteen CLI subcommands functional
- [ ] All eleven Lambda API routes JWT-protected and quota-enforced
- [ ] GitHub integration committed a test artifact bundle to the public repository
- [ ] CI/CD pipeline building and deploying on push
- [ ] Terraform IaC modules with `terraform validate` passing
- [ ] Token usage instrumentation emitting to CloudWatch
- [ ] At least one complete twelve-artifact solution generated end-to-end
- [ ] Agent Integration Milestone Report accepted by Marcus Patel and Daniel Park

### Success Criteria

- All five agents return ACTIVE status in AgentCore Runtime
- End-to-end generation produces all twelve artifact types without manual intervention
- DynamoDB quota conditional write blocks generation at 10 solutions/user/month
- GitHub commit creates a branch with all twelve artifacts under `{solution_id}/`
- `terraform validate` passes in CodeBuild for all IaC modules

## Phase 3 — Validation and Green Baseline (Weeks 10–12)

### Objectives

Phase 3 validates the complete platform, achieves the CloudWatch green baseline, deploys to production, and prepares the executive sponsor demonstration.

- Execute unit, integration, load, and security test suites
- Coordinate UAT with Marcus Patel, Daniel Park, and CTO
- Achieve and certify green CloudWatch metrics baseline
- Deploy full platform to production us-west-2
- Deliver CLI package, runbooks, knowledge-transfer sessions, and executive demo

### Activities

The following table lists Phase 3 activities in execution sequence.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Test plan development | QA Engineer | 2 days | Phase 2 complete |
| Unit testing (>80% code coverage) | Solutions Engineer | 4 days | Test plan |
| Integration testing (all 12 artifact types) | Solutions Engineer | 4 days | Unit tests pass |
| Validation loop testing (3-retry mechanism) | QA Engineer | 3 days | Integration tests |
| Load testing (200 sol/month throughput) | Solutions Engineer | 3 days | Integration tests |
| Security testing (IAM, OWASP API Top 10) | Security Engineer | 2 days | Integration tests |
| Terraform validate gate testing | DevOps Engineer | 2 days | IaC modules |
| Token usage instrumentation validation | ML/AI Engineer | 1 day | CloudWatch metrics |
| UAT coordination (Marcus, Daniel, CTO) | Project Manager | 3 days | All tests pass |
| Defect resolution (P1/P2) | Solutions Engineer | 5 days | UAT feedback |
| Green CloudWatch baseline certification | DevOps Engineer | 2 days | Defects resolved |
| Production deployment | Cloud Engineer | 2 days | Green baseline |
| Runbook delivery and dry-runs | Technical Writer | 2 days | Production deploy |
| Knowledge transfer sessions | Solution Architect | 2 days | Runbooks delivered |
| Executive sponsor demonstration | Engagement Lead | 1 day | Go-live confirmed |

### Success Criteria

- All twelve artifact types pass format-check and LLM quality-check in ≤ 3 retry cycles
- P95 end-to-end latency confirmed < 60 minutes under 200 solutions/month load
- Per-solution Bedrock token spend confirmed ≤ $5 in load test
- Zero P1/P2 open defects at UAT sign-off
- UAT sign-off from Marcus Patel, Daniel Park, and CTO formally recorded
- Green CloudWatch metrics dashboard certified by DevOps Engineer

---

# Infrastructure Deployment

This section provides component-by-component deployment procedures for the Amatra Agentic Pre-Sales Platform. The infrastructure is organised into four layers deployed in order: Networking, Security, Compute, and Monitoring. Each subsection provides all required details — components, script location, deployment steps, validation, success criteria, and rollback — for its layer. All infrastructure is deployed to AWS us-west-2 using Terraform with a CodePipeline CI/CD gate enforcing `terraform validate` before every apply.

## Networking

The networking layer establishes the VPC, subnets, NAT Gateway, and VPC interface endpoints that provide private, high-throughput connectivity for all Lambda functions, AgentCore agents, and DynamoDB/Bedrock interactions. This layer must be applied first; all subsequent layers depend on its outputs.

### Components

The following table lists all networking components deployed in this layer.

| Component | Type | CIDR / ID | Purpose |
|-----------|------|-----------|---------|
| Amatra VPC | AWS VPC | `10.0.0.0/16` | Isolated network boundary for the full platform |
| Private Subnet AZ-A | Subnet | `10.0.1.0/24` | Lambda and AgentCore container execution |
| Private Subnet AZ-B | Subnet | `10.0.2.0/24` | Lambda and AgentCore container execution |
| Private Subnet AZ-C | Subnet | `10.0.3.0/24` | Lambda and AgentCore container execution |
| Public Subnet (NAT) | Subnet | `10.0.100.0/24` | NAT Gateway for GitHub API and PyPI outbound |
| NAT Gateway | NAT Gateway | Elastic IP | Outbound internet for GitHub API calls |
| VPC Endpoint – Bedrock | Interface Endpoint | `vpce-bedrock` | Private Bedrock API access (no NAT charges) |
| VPC Endpoint – DynamoDB | Gateway Endpoint | `vpce-dynamodb` | Private DynamoDB access |
| VPC Endpoint – S3 | Gateway Endpoint | `vpce-s3` | Private S3 artifact storage access |
| VPC Endpoint – Secrets Manager | Interface Endpoint | `vpce-secretsmanager` | Private Secrets Manager access |
| VPC Endpoint – ECR API | Interface Endpoint | `vpce-ecr-api` | Private ECR API for image pulls |
| VPC Endpoint – ECR DKR | Interface Endpoint | `vpce-ecr-dkr` | Private ECR Docker registry |
| VPC Endpoint – CloudWatch Logs | Interface Endpoint | `vpce-logs` | Private CloudWatch Logs ingestion |
| Security Group – Lambda | Security Group | `sg-lambda` | Egress: NAT GW + VPC endpoints only |

### Script Location

All networking Terraform modules are located at `infrastructure/networking/` in the platform repository. The key files are listed below.

- `infrastructure/networking/main.tf` — VPC, subnets, route tables, NAT Gateway
- `infrastructure/networking/endpoints.tf` — VPC interface and gateway endpoints
- `infrastructure/networking/security-groups.tf` — Lambda and service security groups
- `infrastructure/networking/dev.tfvars` — Development environment variable values
- `infrastructure/networking/prod.tfvars` — Production environment variable values

### Deployment Steps

Follow these steps in order. Do not proceed to the next step if a step fails.

```bash
# Step 1: Navigate to the networking module
cd infrastructure/networking

# Step 2: Initialise Terraform with the remote backend
terraform init \
  -backend-config="bucket=amatra-tfstate-us-west-2" \
  -backend-config="key=networking/terraform.tfstate" \
  -backend-config="region=us-west-2" \
  -backend-config="dynamodb_table=amatra-tf-locks"

# Step 3: Plan the deployment (review before applying)
terraform plan -var-file=${ENVIRONMENT}.tfvars -out=networking.plan

# Step 4: Apply the networking deployment
terraform apply networking.plan

# Step 5: Export outputs for downstream modules
terraform output -json > ../../outputs/networking-outputs-${ENVIRONMENT}.json

# Step 6: Confirm all VPC endpoints are in 'available' state
aws ec2 describe-vpc-endpoints \
  --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)" \
  --query 'VpcEndpoints[*].{ID:VpcEndpointId,Service:ServiceName,State:State}' \
  --output table
```

### Validation

Run the following checks immediately after deployment to confirm network integrity.

```bash
# Validate VPC is in 'available' state
VPC_ID=$(terraform output -raw vpc_id)
aws ec2 describe-vpcs --vpc-ids $VPC_ID \
  --query 'Vpcs[0].State' --output text
# Expected: available

# Validate three private subnets exist
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Type,Values=private" \
  --query 'length(Subnets)' --output text
# Expected: 3

# Validate NAT Gateway is available
aws ec2 describe-nat-gateways \
  --filter "Name=vpc-id,Values=$VPC_ID" \
  --query 'NatGateways[0].State' --output text
# Expected: available

# Validate S3 gateway endpoint is present
aws ec2 describe-vpc-endpoints \
  --filters "Name=vpc-id,Values=$VPC_ID" \
    "Name=service-name,Values=com.amazonaws.us-west-2.s3" \
  --query 'VpcEndpoints[0].State' --output text
# Expected: available
```

### Success Criteria

- VPC `10.0.0.0/16` in `available` state in us-west-2
- Three private subnets across three AZs with correct CIDRs
- NAT Gateway in `available` state with Elastic IP assigned
- All seven VPC endpoints in `available` state; interface endpoints associated with private subnets
- Lambda security group permits egress to NAT Gateway and VPC endpoint CIDRs only; no inbound rules
- `networking-outputs-${ENVIRONMENT}.json` written with non-null `vpc_id`, `private_subnets`, `nat_gateway_id`

### Rollback

If the networking deployment fails, execute the following rollback procedure. Only destroy this layer if no downstream resources have been applied.

```bash
# Identify partial deployment errors
terraform show -json | python3 -m json.tool | grep '"type"' | head -20

# Remove VPC endpoints stuck in 'pending' state
ENDPOINT_IDS=$(aws ec2 describe-vpc-endpoints \
  --filters "Name=vpc-id,Values=$VPC_ID" "Name=state,Values=pending" \
  --query 'VpcEndpoints[*].VpcEndpointId' --output text)
[ -n "$ENDPOINT_IDS" ] && aws ec2 delete-vpc-endpoints --vpc-endpoint-ids $ENDPOINT_IDS

# Destroy networking layer (only if no Security/Compute/Monitoring applied)
terraform destroy -var-file=${ENVIRONMENT}.tfvars -target=module.vpc -auto-approve

# Re-plan and re-apply after correcting the issue
terraform plan -var-file=${ENVIRONMENT}.tfvars -out=networking-retry.plan
terraform apply networking-retry.plan
```

Rollback estimated time: 15–30 minutes. Escalate to Cloud Engineer if VPC deletion fails due to dependent resources.

## Security

The security layer deploys IAM execution roles, KMS keys, Secrets Manager secrets, Cognito User Pool, and compliance controls (GuardDuty, CloudTrail). This layer must be fully deployed and CTO-approved before any agent code executes in production. The Networking layer must be applied first.

### Components

The following table lists all security components deployed in this layer.

| Component | Service | Configuration | Purpose |
|-----------|---------|---------------|---------|
| Amatra KMS CMK | AWS KMS | Customer-managed, annual auto-rotation | Encryption for S3, DynamoDB, CloudWatch Logs |
| Cognito User Pool | Amazon Cognito | 30-day refresh token, MFA eligible | JWT issuance and user identity |
| Post-Confirmation Lambda | Lambda | Triggered on Cognito sign-up | Eager DynamoDB user-profile write |
| IAM Role – Input Validator | IAM | Least-privilege: Bedrock invoke, S3 read | AgentCore Input Validator execution role |
| IAM Role – PreSales Generator | IAM | Least-privilege: Bedrock invoke, S3 write | AgentCore Pre-Sales Generator execution role |
| IAM Role – Delivery Generator | IAM | Least-privilege: Bedrock invoke, S3 write | AgentCore Delivery Generator execution role |
| IAM Role – Code Generator | IAM | Least-privilege: Bedrock invoke, S3 write, Secrets read | AgentCore Code Generator execution role |
| IAM Role – EO Validator | IAM | Least-privilege: Bedrock invoke, S3 read/write | AgentCore EO Validator execution role |
| IAM Role – Lambda Routes | IAM | Least-privilege: DynamoDB read/write, S3 read | Eleven Lambda API route execution roles |
| Secret – GitHub PAT | Secrets Manager | 90-day rotation via Lambda rotator | GitHub commit workflow credential |
| Secret – Cognito Client | Secrets Manager | 365-day rotation | Cognito app client secret |
| GuardDuty Detector | AWS GuardDuty | Enabled, us-west-2 | Continuous threat detection |
| CloudTrail S3 Data Events | AWS CloudTrail | Object-level read/write on artifact bucket | Compliance audit trail |
| CloudTrail DynamoDB Events | AWS CloudTrail | Table-level operations on all three tables | Quota modification audit trail |
| CloudTrail Log Bucket | S3 + Object Lock | WORM, 365-day retention | Tamper-proof audit evidence |

### Script Location

All security Terraform modules are located at `infrastructure/security/` in the platform repository. The key files are listed below.

- `infrastructure/security/iam.tf` — IAM roles, policies, and permission boundaries
- `infrastructure/security/cognito.tf` — Cognito User Pool and post-confirmation Lambda trigger
- `infrastructure/security/kms.tf` — Customer-managed KMS keys and key policies
- `infrastructure/security/secrets.tf` — Secrets Manager secrets and rotation Lambdas
- `infrastructure/security/guardduty.tf` — GuardDuty detector and findings SNS notification
- `infrastructure/security/cloudtrail.tf` — CloudTrail, S3 data events, Object Lock bucket
- `infrastructure/security/dev.tfvars` — Development environment values
- `infrastructure/security/prod.tfvars` — Production values (requires CTO review before apply)

### Deployment Steps

Execute these steps in order. For production, CTO sign-off must be recorded in the RAID log before Step 5 is executed.

```bash
# Step 1: Navigate to the security module
cd infrastructure/security

# Step 2: Initialise Terraform backend
terraform init \
  -backend-config="bucket=amatra-tfstate-us-west-2" \
  -backend-config="key=security/terraform.tfstate" \
  -backend-config="region=us-west-2" \
  -backend-config="dynamodb_table=amatra-tf-locks"

# Step 3: Plan the security deployment
terraform plan \
  -var-file=${ENVIRONMENT}.tfvars \
  -var="vpc_id=$(python3 -c 'import json; d=json.load(open("../../outputs/networking-outputs-'${ENVIRONMENT}'.json")); print(d["vpc_id"]["value"])')" \
  -out=security.plan

# Step 4: For PRODUCTION — confirm CTO sign-off before applying
if [ "$ENVIRONMENT" == "prod" ]; then
  read -p "CTO sign-off confirmed in RAID log? [y/N]: " CONFIRM
  [ "$CONFIRM" != "y" ] && echo "Aborting: CTO sign-off required." && exit 1
fi

# Step 5: Apply the security layer
terraform apply security.plan

# Step 6: Seed Secrets Manager with placeholder values
aws secretsmanager put-secret-value \
  --secret-id amatra/github-pat \
  --secret-string '{"token":"REPLACE_WITH_ACTUAL_PAT"}' \
  --region us-west-2

# Step 7: Export security outputs
terraform output -json > ../../outputs/security-outputs-${ENVIRONMENT}.json
```

After deployment, validate the post-confirmation trigger:

```bash
# Step 8: Create a test user and verify DynamoDB profile write
aws cognito-idp admin-create-user \
  --user-pool-id $(terraform output -raw user_pool_id) \
  --username "test-user@amatra-test.com" \
  --temporary-password "TempPass1234!" \
  --message-action SUPPRESS

aws dynamodb get-item \
  --table-name amatra-user_profiles-${ENVIRONMENT} \
  --key '{"userId":{"S":"test-user@amatra-test.com"}}' \
  --query 'Item.userId.S' --output text
# Expected: test-user@amatra-test.com
```

### Validation

Run the following checks to confirm the security layer is correctly deployed.

```bash
# Validate KMS CMK is enabled
aws kms describe-key \
  --key-id $(terraform output -raw kms_key_id) \
  --query 'KeyMetadata.KeyState' --output text
# Expected: Enabled

# Validate GuardDuty is ENABLED
aws guardduty list-detectors --region us-west-2 \
  --query 'DetectorIds[0]' --output text | \
  xargs -I{} aws guardduty get-detector --detector-id {} \
  --query 'Status' --output text
# Expected: ENABLED

# Validate Secrets Manager secret exists
aws secretsmanager describe-secret \
  --secret-id amatra/github-pat \
  --query 'Name' --output text
# Expected: amatra/github-pat

# Validate no wildcard resources on Input Validator IAM role
aws iam get-role-policy \
  --role-name amatra-input-validator-execution-role \
  --policy-name amatra-input-validator-permissions | \
  python3 -c "
import sys, json
doc = json.load(sys.stdin)
stmts = json.loads(doc['PolicyDocument'])['Statement']
wildcards = [s for s in stmts if s.get('Resource') == '*']
print('FAIL: wildcard found') if wildcards else print('PASS: no wildcards')
"

# Validate Cognito User Pool is ACTIVE
aws cognito-idp describe-user-pool \
  --user-pool-id $(terraform output -raw user_pool_id) \
  --query 'UserPool.Status' --output text
# Expected: ACTIVE
```

### Success Criteria

- Cognito User Pool in ACTIVE status with thirty-day refresh token configuration
- Post-confirmation Lambda writes user profile to DynamoDB on every new user sign-up
- All five AgentCore IAM execution roles have no wildcard resource policies
- KMS CMK enabled with annual auto-rotation
- GuardDuty detector ENABLED in us-west-2
- CloudTrail S3 and DynamoDB data events active and logging to the Object Lock bucket
- Secrets Manager secrets exist with rotation schedules configured
- For production: CTO sign-off formally recorded in RAID log before apply

### Rollback

The security rollback must be executed carefully to avoid orphaning resources that downstream layers depend on.

```bash
# Step 1: DEV only — remove Cognito users before destroying User Pool
if [ "$ENVIRONMENT" == "dev" ]; then
  aws cognito-idp list-users \
    --user-pool-id $(terraform output -raw user_pool_id) \
    --query 'Users[*].Username' --output text | tr '\t' '\n' | \
    while read USER; do
      aws cognito-idp admin-delete-user \
        --user-pool-id $(terraform output -raw user_pool_id) \
        --username "$USER"
    done
fi

# Step 2: Targeted destroy of Cognito and IAM roles
terraform destroy -var-file=${ENVIRONMENT}.tfvars \
  -target=aws_cognito_user_pool.amatra \
  -target=aws_iam_role.amatra_lambda_routes \
  -auto-approve

# Step 3: Schedule KMS key deletion (7-day minimum waiting period)
aws kms schedule-key-deletion \
  --key-id $(terraform output -raw kms_key_id) \
  --pending-window-in-days 7

# Step 4: Re-deploy from corrected configuration
terraform plan -var-file=${ENVIRONMENT}.tfvars -out=security-retry.plan
terraform apply security-retry.plan
```

Rollback estimated time: 30–60 minutes. KMS key deletion has a mandatory 7-day waiting period.

## Compute

The compute layer deploys all Lambda functions, Bedrock AgentCore agents, ECR container images, Step Functions state machine, and the CodePipeline CI/CD pipeline. This is the critical-path layer that implements the core agentic orchestration platform. The Security layer must be applied and validated first.

### Components

The following table lists all compute components deployed in this layer.

| Component | Service | Specification | Purpose |
|-----------|---------|---------------|---------|
| ECR Repository | Amazon ECR | Image scanning enabled, 3-version lifecycle | Docker images for all five AgentCore agents |
| AgentCore – Input Validator | Bedrock AgentCore Runtime | `amatra-agents:latest`, Sonnet 4.6 | Validates client brief format and completeness |
| AgentCore – Pre-Sales Generator | Bedrock AgentCore Runtime | `amatra-agents:latest`, Sonnet 4.6 | Produces five presales artifacts |
| AgentCore – Delivery Generator | Bedrock AgentCore Runtime | `amatra-agents:latest`, Sonnet 4.6 | Produces six delivery artifacts |
| AgentCore – Code Generator | Bedrock AgentCore Runtime | `amatra-agents:latest`, Sonnet 4.6 | Produces Terraform IaC automation bundle |
| AgentCore – EO Validator | Bedrock AgentCore Runtime | `amatra-agents:latest`, Haiku 4.5 | Format-check + LLM quality-check, up to 3 retries |
| Step Functions State Machine | AWS Step Functions | Standard workflow, 14-day history | Agent-graph orchestration and retry management |
| Lambda – Solution Start | Lambda | Python 3.11, 512 MB, 15 min timeout | `POST /solutions` — initiates generation |
| Lambda – Solution Status | Lambda | Python 3.11, 256 MB, 30 s timeout | `GET /solutions/{id}/status` |
| Lambda – Artifact Download | Lambda | Python 3.11, 256 MB, 30 s timeout | `GET /solutions/{id}/artifacts/{type}` |
| Lambda – User Quota Check | Lambda | Python 3.11, 128 MB, 10 s timeout | `GET /users/me/quota` |
| Lambda – Admin Usage | Lambda | Python 3.11, 256 MB, 30 s timeout | `GET /admin/usage` |
| Lambda – Post-Confirmation | Lambda | Python 3.11, 128 MB, 10 s timeout | Cognito post-confirmation trigger |
| Lambda – Quota Monthly Reset | Lambda | Python 3.11, 128 MB, 5 min timeout | Scheduled first-of-month quota reset |
| CodePipeline | AWS CodePipeline | 3-stage: Source → Build → Deploy | CI/CD for Docker build, ECR push, smoke test |
| CodeBuild – Build | AWS CodeBuild | `aws/codebuild/standard:7.0` | Docker build, ECR push, `terraform validate` gate |
| CodeBuild – Smoke Test | AWS CodeBuild | `aws/codebuild/standard:7.0` | Post-deploy end-to-end smoke test |

### Script Location

Compute Terraform modules and application code are located across several directories in the platform repository.

- `infrastructure/compute/ecr.tf` — ECR repository and lifecycle policies
- `infrastructure/compute/lambda.tf` — All Lambda function definitions and event sources
- `infrastructure/compute/step-functions.tf` — State machine definition (Amazon States Language JSON)
- `infrastructure/compute/codepipeline.tf` — CodePipeline and CodeBuild project definitions
- `containers/amatra-agent/Dockerfile` — Agent container image definition
- `containers/amatra-agent/agents/` — Strands agent implementations (one subdirectory per agent)
- `src/lambda/` — Lambda handler source code
- `scripts/register_agents.py` — AgentCore Runtime registration script
- `scripts/smoke_test.py` — Post-deployment smoke test script

### Deployment Steps

Execute these steps in order. Docker image push to ECR must precede AgentCore registration.

```bash
# Step 1: Initialise and plan compute module
cd infrastructure/compute
terraform init \
  -backend-config="bucket=amatra-tfstate-us-west-2" \
  -backend-config="key=compute/terraform.tfstate" \
  -backend-config="region=us-west-2" \
  -backend-config="dynamodb_table=amatra-tf-locks"

terraform plan \
  -var-file=${ENVIRONMENT}.tfvars \
  -var="networking_outputs=../../outputs/networking-outputs-${ENVIRONMENT}.json" \
  -var="security_outputs=../../outputs/security-outputs-${ENVIRONMENT}.json" \
  -out=compute.plan

# Step 2: Apply ECR and Lambda infrastructure first
terraform apply -target=aws_ecr_repository.amatra_agents compute.plan
terraform apply -target=module.lambda compute.plan

# Step 3: Build and push Docker image
cd ../../containers/amatra-agent
ECR_URI=$(cd ../../infrastructure/compute && terraform output -raw ecr_repository_uri)
IMAGE_TAG="1.0.0"

aws ecr get-login-password --region us-west-2 | \
  docker login --username AWS --password-stdin ${ECR_URI%/*}

docker build -t amatra-agents:${IMAGE_TAG} .
docker tag amatra-agents:${IMAGE_TAG} ${ECR_URI}:${IMAGE_TAG}
docker push ${ECR_URI}:${IMAGE_TAG}

# Step 4: Register all five AgentCore agents
cd ../../scripts
python3 register_agents.py \
  --image-uri "${ECR_URI}:${IMAGE_TAG}" \
  --environment ${ENVIRONMENT} \
  --region us-west-2

# Step 5: Deploy Step Functions and CodePipeline
cd ../infrastructure/compute
terraform apply compute.plan

# Step 6: Export compute outputs
terraform output -json > ../../outputs/compute-outputs-${ENVIRONMENT}.json

# Step 7: Test atomic quota enforcement
python3 ../../scripts/test_quota_enforcement.py \
  --user-id "test-user@amatra-test.com" \
  --table-name "amatra-quota_global-${ENVIRONMENT}" \
  --concurrent-writes 20
# Expected: 10 succeed; 10 return QuotaExceededException
```

### Validation

Run the following checks to confirm the compute layer is correctly deployed.

```bash
# Validate all five AgentCore agents are ACTIVE
aws bedrock-agentcore list-agents \
  --query 'agents[?contains(agentName,`amatra`)].{Name:agentName,Status:agentStatus}' \
  --output table

# Validate Lambda functions are in Active state
for LAMBDA in solution-start solution-status artifact-download user-quota admin-usage; do
  STATE=$(aws lambda get-function \
    --function-name "amatra-${LAMBDA}-${ENVIRONMENT}" \
    --query 'Configuration.State' --output text)
  echo "amatra-${LAMBDA}-${ENVIRONMENT}: $STATE"
done
# Expected: Active for all functions

# Validate Step Functions state machine is ACTIVE
aws stepfunctions describe-state-machine \
  --state-machine-arn $(python3 -c "import json; d=json.load(open('../../outputs/compute-outputs-${ENVIRONMENT}.json')); print(d['state_machine_arn']['value'])") \
  --query 'status' --output text
# Expected: ACTIVE

# Run end-to-end smoke test
python3 scripts/smoke_test.py \
  --environment ${ENVIRONMENT} \
  --test-brief "tests/fixtures/smoke-test-brief.txt"
# Expected: 12 artifacts generated and validated within 30 minutes
```

### Success Criteria

- All five Bedrock AgentCore agents return `ACTIVE` status in us-west-2
- ECR image scan shows zero `CRITICAL` severity vulnerabilities
- All Lambda functions in `Active` state with no configuration errors
- Step Functions state machine `ACTIVE` and successfully executes a twelve-artifact smoke test
- Atomic quota enforcement confirms exactly 10 successful writes per user under concurrent load
- CodePipeline last execution `Succeeded`; `terraform validate` passes in CodeBuild stage
- Smoke test produces all twelve artifact types in S3 and commits them to GitHub

### Rollback

The compute rollback handles individual component failures without requiring full infrastructure teardown.

```bash
# Scenario A: Roll back Lambda functions to previous version using aliases
FUNCTION_NAME="amatra-solution-start-${ENVIRONMENT}"
PREV_VERSION=$(aws lambda list-versions-by-function \
  --function-name $FUNCTION_NAME \
  --query 'Versions[-2].Version' --output text)
aws lambda update-alias \
  --function-name $FUNCTION_NAME \
  --name live \
  --function-version $PREV_VERSION

# Scenario B: Re-register AgentCore agents with the previous image tag
PREVIOUS_TAG=$(aws ecr describe-images \
  --repository-name amatra-agents \
  --query 'sort_by(imageDetails,& imagePushedAt)[-2].imageTags[0]' \
  --output text)
python3 scripts/register_agents.py \
  --image-uri "${ECR_URI}:${PREVIOUS_TAG}" \
  --environment ${ENVIRONMENT} \
  --region us-west-2

# Scenario C: Roll back Step Functions state machine
cd infrastructure/compute
git checkout HEAD~1 -- step-functions.tf
terraform plan -var-file=${ENVIRONMENT}.tfvars -out=sfn-rollback.plan
terraform apply -target=aws_sfn_state_machine.amatra_orchestrator sfn-rollback.plan
```

Rollback estimated time: 20–45 minutes. AgentCore re-registration takes approximately 15 minutes per agent.

## Monitoring

The monitoring layer deploys CloudWatch dashboards, custom metrics, alarms, and SNS notifications that provide full observability of operational health, performance, and cost posture. The Compute layer must be applied and smoke-tested before this layer is deployed.

### Components

The following table lists all monitoring components deployed in this layer.

| Component | Service | Configuration | Purpose |
|-----------|---------|---------------|---------|
| Log Group – Lambda | CloudWatch Logs | 90-day retention, KMS encrypted | Structured JSON logs from all Lambda functions |
| Log Group – AgentCore | CloudWatch Logs | 90-day retention, KMS encrypted | Agent execution logs |
| Metric – TokenUsage | CloudWatch Custom Metric | Namespace: `AmatraPlatform/TokenUsage` | Per-phase token counts by agent and model |
| Metric – SolutionLatency | CloudWatch Custom Metric | Namespace: `AmatraPlatform/Performance` | End-to-end generation latency per solution |
| Metric – ValidationRetries | CloudWatch Custom Metric | Namespace: `AmatraPlatform/Quality` | Per-artifact retry count |
| Dashboard – Operations | CloudWatch Dashboard | Auto-refresh 1 minute | P99 Lambda latency, error rates, retry rates, token spend |
| Dashboard – Cost | CloudWatch Dashboard | Auto-refresh 1 hour | Per-solution Bedrock spend vs $5 target |
| Alarm – Lambda Error Rate | CloudWatch Alarm | Threshold: > 1% over 5 minutes | SNS on Lambda error spike |
| Alarm – Step Functions Failure | CloudWatch Alarm | Threshold: > 2% over 5 minutes | SNS on state machine execution failures |
| Alarm – DynamoDB Throttle | CloudWatch Alarm | Threshold: > 0 events | SNS on any quota table throttle |
| Alarm – Bedrock Daily Spend | CloudWatch Alarm | Threshold: > 110% daily budget | SNS on Bedrock overspend |
| Alarm – GuardDuty HIGH Finding | EventBridge Rule | Severity ≥ HIGH | SNS on GuardDuty HIGH/CRITICAL findings |
| SNS Topic – Operations | Amazon SNS | Email + PagerDuty | Receives all CloudWatch alarm notifications |
| SNS Topic – Security | Amazon SNS | Security contact email | Receives GuardDuty and CloudTrail anomaly alerts |

### Script Location

All monitoring Terraform modules and dashboard definitions are located at `infrastructure/monitoring/` and related source files.

- `infrastructure/monitoring/cloudwatch.tf` — Log groups, metric filters, alarms, and dashboards
- `infrastructure/monitoring/sns.tf` — SNS topics and subscriptions
- `infrastructure/monitoring/eventbridge.tf` — GuardDuty event routing to SNS
- `infrastructure/monitoring/dashboards/operations-dashboard.json` — Operations dashboard JSON
- `infrastructure/monitoring/dashboards/cost-dashboard.json` — Cost and token spend dashboard JSON
- `src/lambda/metrics_emitter.py` — Shared utility for emitting custom CloudWatch metrics
- `infrastructure/monitoring/dev.tfvars` — Development environment values
- `infrastructure/monitoring/prod.tfvars` — Production environment values

### Deployment Steps

Execute these steps after the compute layer is fully validated and the smoke test has passed.

```bash
# Step 1: Navigate to the monitoring module
cd infrastructure/monitoring

# Step 2: Initialise Terraform backend
terraform init \
  -backend-config="bucket=amatra-tfstate-us-west-2" \
  -backend-config="key=monitoring/terraform.tfstate" \
  -backend-config="region=us-west-2" \
  -backend-config="dynamodb_table=amatra-tf-locks"

# Step 3: Plan the monitoring deployment
terraform plan \
  -var-file=${ENVIRONMENT}.tfvars \
  -var="compute_outputs=../../outputs/compute-outputs-${ENVIRONMENT}.json" \
  -out=monitoring.plan

# Step 4: Apply monitoring deployment
terraform apply monitoring.plan

# Step 5: Subscribe operations and security teams to SNS topics
aws sns subscribe \
  --topic-arn $(terraform output -raw ops_sns_topic_arn) \
  --protocol email --notification-endpoint "daniel.park@predictif.com"

aws sns subscribe \
  --topic-arn $(terraform output -raw ops_sns_topic_arn) \
  --protocol email --notification-endpoint "amatra-ops@amatra.io"

aws sns subscribe \
  --topic-arn $(terraform output -raw security_sns_topic_arn) \
  --protocol email --notification-endpoint "amatra-security@amatra.io"

echo "Action required: All SNS subscription emails must be confirmed by recipients."

# Step 6: Run smoke test to generate custom metrics
python3 ../../scripts/smoke_test.py --environment ${ENVIRONMENT}

# Step 7: Confirm custom metrics appear in CloudWatch (wait 2 minutes)
aws cloudwatch list-metrics \
  --namespace "AmatraPlatform/TokenUsage" \
  --query 'Metrics[*].MetricName' --output table
```

### Validation

Run the following checks to confirm the monitoring layer is fully operational.

```bash
# Validate operations dashboard exists
aws cloudwatch describe-dashboards \
  --dashboard-name-prefix "amatra-operations" \
  --query 'DashboardEntries[0].DashboardName' --output text
# Expected: amatra-operations-${ENVIRONMENT}

# Validate critical alarms are in OK or INSUFFICIENT_DATA (not ALARM)
for ALARM in lambda-error-rate sfn-failure-rate dynamodb-throttle bedrock-daily-spend; do
  STATE=$(aws cloudwatch describe-alarms \
    --alarm-names "amatra-${ALARM}-${ENVIRONMENT}" \
    --query 'MetricAlarms[0].StateValue' --output text)
  echo "Alarm amatra-${ALARM}-${ENVIRONMENT}: $STATE"
done
# Expected: OK or INSUFFICIENT_DATA

# Validate custom metrics are present after smoke test
aws cloudwatch list-metrics \
  --namespace "AmatraPlatform/TokenUsage" \
  --query 'length(Metrics)' --output text
# Expected: >= 5

# Validate log group retention is 90 days
for LOG_GROUP in /aws/lambda/amatra /aws/bedrock-agentcore/amatra; do
  RETENTION=$(aws logs describe-log-groups \
    --log-group-name-prefix $LOG_GROUP \
    --query 'logGroups[0].retentionInDays' --output text)
  echo "$LOG_GROUP retention: $RETENTION days"
done
# Expected: 90 for both
```

### Success Criteria

- CloudWatch Operations and Cost dashboards accessible and displaying live data within 5 minutes of smoke test
- All four critical alarms in `OK` or `INSUFFICIENT_DATA` state after clean deployment
- Custom metrics `AmatraPlatform/TokenUsage`, `AmatraPlatform/Performance`, `AmatraPlatform/Quality` visible within 2 minutes of smoke test
- SNS subscriptions confirmed by all recipients
- Log groups with 90-day retention and KMS encryption for Lambda and AgentCore
- GuardDuty EventBridge rule routes HIGH-severity findings to security SNS topic
- Per-solution token spend metric confirms ≤ $5 Bedrock spend in smoke test

### Rollback

Monitoring layer rollback is lower risk than other layers because it does not affect platform availability.

```bash
# Step 1: Disable alarms before rollback to prevent false-positive alerts
for ALARM in lambda-error-rate sfn-failure-rate dynamodb-throttle bedrock-daily-spend; do
  aws cloudwatch disable-alarm-actions \
    --alarm-names "amatra-${ALARM}-${ENVIRONMENT}"
done

# Step 2: Destroy and re-deploy monitoring layer
terraform destroy -var-file=${ENVIRONMENT}.tfvars \
  -target=module.cloudwatch_alarms \
  -target=module.cloudwatch_dashboards \
  -auto-approve

# Step 3: Correct configuration and re-apply
terraform plan -var-file=${ENVIRONMENT}.tfvars -out=monitoring-retry.plan
terraform apply monitoring-retry.plan

# Step 4: Re-enable alarms after successful re-deployment
for ALARM in lambda-error-rate sfn-failure-rate dynamodb-throttle bedrock-daily-spend; do
  aws cloudwatch enable-alarm-actions \
    --alarm-names "amatra-${ALARM}-${ENVIRONMENT}"
done
```

Rollback estimated time: 10–20 minutes with no impact on platform availability.

---

# Application Configuration

This section covers post-infrastructure configuration of all Amatra platform services — Bedrock model settings, DynamoDB quota initialisation, API Gateway route verification, Secrets Manager PAT injection, and security control validation.

## Bedrock Model Configuration

The platform uses two Bedrock models with distinct roles. Claude Sonnet 4.6 handles artifact generation; Claude Haiku 4.5 handles cost-efficient validation. Apply the following configuration to each AgentCore agent's Lambda environment before production traffic is enabled.

```yaml
# config/bedrock-model-config.yaml
bedrock:
  generation_model:
    model_id: "us.anthropic.claude-sonnet-4-6-20261001-v1:0"
    region: us-west-2
    max_tokens: 8192
    temperature: 0.1
    top_p: 0.95
    retry_config:
      max_retries: 3
      retry_delay_seconds: 30
      backoff_multiplier: 2.0

  validation_model:
    model_id: "us.anthropic.claude-haiku-4-5-20261001-v1:0"
    region: us-west-2
    max_tokens: 2048
    temperature: 0.0
    retry_config:
      max_retries: 2
      retry_delay_seconds: 15
      backoff_multiplier: 1.5

  budget:
    per_solution_token_budget_usd: 5.00
    alert_threshold_percent: 90
    sonnet_price_per_1k_input_tokens: 0.003
    sonnet_price_per_1k_output_tokens: 0.015
    haiku_price_per_1k_input_tokens: 0.0008
    haiku_price_per_1k_output_tokens: 0.004
```

Apply the configuration to all AgentCore agent Lambda handlers:

```bash
# Apply Bedrock model environment variables to all five agent Lambda handlers
for AGENT in input-validator presales-generator delivery-generator code-generator eo-validator; do
  aws lambda update-function-configuration \
    --function-name "amatra-${AGENT}-${ENVIRONMENT}" \
    --environment Variables="{
      BEDROCK_GENERATION_MODEL_ID=us.anthropic.claude-sonnet-4-6-20261001-v1:0,
      BEDROCK_VALIDATION_MODEL_ID=us.anthropic.claude-haiku-4-5-20261001-v1:0,
      BEDROCK_REGION=us-west-2,
      ENVIRONMENT=${ENVIRONMENT},
      LOG_LEVEL=INFO,
      CLOUDWATCH_NAMESPACE=AmatraPlatform
    }"
done
```

## DynamoDB Quota Initialisation

Before the first production user can generate solutions, the global quota counter must be initialised for the current calendar month.

```bash
# Initialise the global quota counter for the current month
CURRENT_MONTH=$(date +%Y-%m)
aws dynamodb put-item \
  --table-name "amatra-quota_global-${ENVIRONMENT}" \
  --item "{
    \"period\": {\"S\": \"${CURRENT_MONTH}\"},
    \"solutionsGenerated\": {\"N\": \"0\"},
    \"globalLimit\": {\"N\": \"1000\"},
    \"lastUpdated\": {\"S\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}
  }" \
  --condition-expression "attribute_not_exists(period)"

echo "Global quota initialised for period: ${CURRENT_MONTH}"
```

## API Gateway Route Configuration

Verify all eleven API routes are correctly mapped to Lambda functions with JWT authorisation before enabling production traffic.

```bash
# List all API Gateway routes and their integration targets
API_ID=$(python3 -c "import json; d=json.load(open('outputs/compute-outputs-${ENVIRONMENT}.json')); print(d['api_id']['value'])")

aws apigatewayv2 get-routes \
  --api-id $API_ID \
  --query 'Items[*].{Method:RouteKey,Target:Target}' \
  --output table
```

The expected route inventory is shown in the following table.

| Route | Lambda Handler | Auth |
|-------|---------------|------|
| `POST /solutions` | `amatra-solution-start` | JWT |
| `GET /solutions/{id}/status` | `amatra-solution-status` | JWT |
| `GET /solutions/{id}/artifacts/{type}` | `amatra-artifact-download` | JWT |
| `GET /solutions` | `amatra-solution-list` | JWT |
| `DELETE /solutions/{id}` | `amatra-solution-delete` | JWT |
| `GET /users/me/quota` | `amatra-user-quota` | JWT |
| `GET /users/me/profile` | `amatra-user-profile` | JWT |
| `POST /auth/refresh` | `amatra-token-refresh` | None (public) |
| `GET /admin/usage` | `amatra-admin-usage` | JWT + Admin scope |
| `POST /admin/quota/reset` | `amatra-admin-quota-reset` | JWT + Admin scope |
| `GET /health` | `amatra-health` | None (public) |

## Secrets Manager PAT Injection

Before GitHub integration can commit artifacts, the actual GitHub PAT must replace the placeholder set during Security layer deployment.

```bash
# Inject the GitHub PAT — read securely without echoing
read -s -p "Enter GitHub PAT (repo scope): " GITHUB_PAT
echo

aws secretsmanager put-secret-value \
  --secret-id "amatra/github-pat" \
  --secret-string "{\"token\":\"${GITHUB_PAT}\"}" \
  --region us-west-2

# Verify the secret metadata (not the value)
aws secretsmanager describe-secret \
  --secret-id "amatra/github-pat" \
  --query '{Name:Name,RotationEnabled:RotationEnabled,LastChangedDate:LastChangedDate}' \
  --output table

unset GITHUB_PAT
```

## Security Controls

### IAM Least-Privilege Validation

Validate all Lambda and AgentCore execution roles comply with least-privilege before enabling production traffic.

```bash
# Run IAM Access Analyzer to surface overly permissive policies
aws accessanalyzer create-analyzer \
  --analyzer-name "amatra-iam-analyzer-${ENVIRONMENT}" \
  --type ACCOUNT --region us-west-2

# Check for active findings (allow 2-5 minutes after creation)
aws accessanalyzer list-findings \
  --analyzer-arn "arn:aws:access-analyzer:us-west-2:123456789012:analyzer/amatra-iam-analyzer-${ENVIRONMENT}" \
  --filter '{"resourceType":{"eq":["AWS::IAM::Role"]}}' \
  --query 'findings[?status==`ACTIVE`]' --output table
# Expected: zero active findings for Amatra roles
```

### Data Protection

Confirm S3 bucket SSE-KMS encryption and Block Public Access before any artifacts are written.

```bash
# Verify S3 bucket encryption is aws:kms
aws s3api get-bucket-encryption \
  --bucket "amatra-artifacts-${ENVIRONMENT}" \
  --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' \
  --output text
# Expected: aws:kms

# Verify Block Public Access is fully enforced
aws s3api get-public-access-block \
  --bucket "amatra-artifacts-${ENVIRONMENT}" \
  --query 'PublicAccessBlockConfiguration' --output table
# Expected: all four settings = true
```

## Application Security Validation Checklist

The following checklist must be fully completed before any production traffic is enabled.

- [ ] IAM roles for all five AgentCore agents — no wildcard resources
- [ ] KMS encryption enabled for S3 bucket, all three DynamoDB tables, and CloudWatch Logs
- [ ] TLS 1.2+ enforced on all API Gateway endpoints (HTTPS-only listener)
- [ ] S3 bucket policy includes `aws:SecureTransport` condition denying HTTP
- [ ] All credentials in Secrets Manager — zero plaintext in Lambda environment variables
- [ ] GitHub PAT injected and 90-day rotation schedule active
- [ ] IAM Access Analyzer returns zero active findings for Amatra roles
- [ ] VPC endpoints operational — no Bedrock/DynamoDB/S3 traffic over NAT Gateway
- [ ] CloudTrail data events capturing all S3 object reads/writes
- [ ] GuardDuty ENABLED and security SNS subscription confirmed by recipient

---

# Integration Testing

Integration testing validates the end-to-end solution generation pipeline across all twelve artifact types, the GitHub commit workflow, the DynamoDB quota enforcement under concurrent load, and the CLI-to-API integration path.

## Integration Test Strategy

The integration testing approach is structured in five tiers, all of which must pass before UAT begins in Week 11.

| Test Tier | Scope | Owner | Duration | Pass Criteria |
|-----------|-------|-------|----------|---------------|
| Component Integration | Individual agent pairs and Lambda routes | Solutions Engineer | 2 days | 100% of unit interfaces pass |
| Pipeline Integration | Full five-agent pipeline, all 12 artifact types | Solutions Engineer | 4 days | All 12 artifact types produced and validated |
| End-to-End Generation | CLI → API → Step Functions → Agents → GitHub | QA Engineer | 2 days | Complete solution in S3 and GitHub within 60 min |
| Quota Stress Test | 20 concurrent generation requests | Solutions Engineer | 1 day | Exactly 10 succeed; 10 return QuotaExceeded |
| Format and Quality Check | All 12 artifacts: format-check + LLM validation | QA Engineer | 2 days | All pass with ≤ 3 retries |

## Pipeline Integration Test Procedure

The following procedure validates the complete five-agent pipeline for a single representative solution.

```bash
# Run the full pipeline integration test suite
cd tests/integration

export ENVIRONMENT=dev
export TEST_USER_TOKEN=$(python3 ../scripts/get_test_token.py --username "qa-test@amatra-test.com")
export API_ENDPOINT=$(python3 -c "import json; d=json.load(open('../../outputs/compute-outputs-dev.json')); print(d['api_endpoint']['value'])")

python3 -m pytest test_pipeline_integration.py \
  -v --timeout=3600 \
  --html=reports/pipeline-integration-report.html \
  --self-contained-html
```

## Quota Enforcement Stress Test

This test confirms the DynamoDB atomic conditional write correctly enforces the 10 solutions/user/month limit under concurrent load.

```bash
# Run quota enforcement stress test
python3 tests/integration/test_quota_enforcement.py \
  --concurrent-requests 20 \
  --user-id "quota-test@amatra-test.com" \
  --environment dev

# Expected output:
# Results: 10 SUCCEEDED, 10 FAILED (QuotaExceededException)
# PASS: Quota enforcement is atomic and consistent
```

## CLI End-to-End Test

This test validates the full CLI workflow from install to artifact download.

```bash
# Install CLI in a fresh virtual environment
python3 -m venv /tmp/amatra-cli-test
source /tmp/amatra-cli-test/bin/activate
pip install amatra-cli==1.0.0

# Exercise all 14 subcommands
amatra login --username "cli-test@amatra-test.com" --password "TestPass1234!"
amatra quota status
amatra generate --brief tests/fixtures/sample-brief.txt --solution-name "CLI Integration Test"
SOLUTION_ID=$(amatra solutions list --latest --output json | \
  python3 -c "import sys,json; print(json.load(sys.stdin)[0]['solutionId'])")
amatra status --solution-id $SOLUTION_ID
amatra artifacts list --solution-id $SOLUTION_ID
amatra artifacts download --solution-id $SOLUTION_ID --type implementation-guide --output /tmp/
amatra admin usage
amatra logout

deactivate
echo "All 14 CLI subcommand tests passed."
```

## GitHub Commit Validation

After a successful solution generation, confirm all twelve artifacts are committed to the public GitHub repository.

```bash
# Validate the solution branch was created with all 12 artifacts
GITHUB_REPO="predictif/amatra-solutions"
BRANCH="${SOLUTION_ID}"

curl -s -H "Authorization: token ${GITHUB_PAT}" \
  "https://api.github.com/repos/${GITHUB_REPO}/branches/${BRANCH}" | \
  python3 -c "import sys,json; d=json.load(sys.stdin); print('Branch:', d.get('name','NOT FOUND'))"

curl -s -H "Authorization: token ${GITHUB_PAT}" \
  "https://api.github.com/repos/${GITHUB_REPO}/git/trees/${BRANCH}?recursive=1" | \
  python3 -c "import sys,json; d=json.load(sys.stdin); [print(f['path']) for f in d.get('tree',[])]"
```

## Integration Test Success Criteria

All of the following must be satisfied before UAT can begin.

- [ ] All twelve artifact types produced by the pipeline in a single generation run
- [ ] All twelve artifacts pass format-check without manual intervention
- [ ] All twelve artifacts pass LLM quality-check in ≤ 3 retry cycles
- [ ] DynamoDB quota returns `QuotaExceededException` on the eleventh concurrent write for a single user
- [ ] GitHub commit creates a branch with all twelve artifacts under `{solution_id}/`
- [ ] All fourteen CLI subcommands complete without error on a clean installation
- [ ] End-to-end generation time < 60 minutes at P95 in single-run integration tests
- [ ] CloudWatch custom metrics visible for all five agents within 2 minutes of run completion

---

# Security Validation

Security validation confirms all platform controls meet SOW requirements and are production-ready. All findings are documented in the Security Test Report (Deliverable #22), which is a prerequisite for UAT sign-off.

## IAM Policy Review

All IAM execution roles must pass the following least-privilege validation before production deployment.

- [ ] Input Validator role: `bedrock:InvokeModel` on Sonnet 4.6 ARN only; `s3:GetObject` scoped to brief path only
- [ ] Pre-Sales Generator role: `bedrock:InvokeModel` on Sonnet 4.6 ARN only; `s3:PutObject` on presales prefix only
- [ ] Delivery Generator role: `bedrock:InvokeModel` on Sonnet 4.6 ARN only; `s3:PutObject` on delivery prefix only
- [ ] Code Generator role: `bedrock:InvokeModel` on Sonnet 4.6 ARN; `secretsmanager:GetSecretValue` on `amatra/github-pat` ARN only
- [ ] EO Validator role: `bedrock:InvokeModel` on Haiku 4.5 ARN only; `s3:GetObject` and `s3:PutObject` scoped to solution path
- [ ] Lambda route roles: DynamoDB actions on named table ARNs only — no wildcard resources
- [ ] Step Functions execution role: `lambda:InvokeFunction` on named Lambda ARNs only
- [ ] No `Resource: "*"` policies on any Amatra execution role

## Cognito and JWT Validation

The following tests confirm the JWT authoriser correctly rejects invalid tokens on all protected routes.

```bash
# Test 1: Expired token is rejected with 401
EXPIRED_TOKEN="eyJhbGciOiJSUzI1NiJ9.eyJleHAiOjE2MDAwMDAwMDB9.invalid"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $EXPIRED_TOKEN" \
  "${API_ENDPOINT}/solutions")
echo "Expired token: HTTP $RESPONSE (expected 401)"

# Test 2: Tampered token is rejected
VALID_TOKEN=$(amatra login --username "test@amatra-test.com" --password "TestPass1234!" --output token)
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer ${VALID_TOKEN}tampered" \
  "${API_ENDPOINT}/solutions")
echo "Tampered token: HTTP $RESPONSE (expected 401)"

# Test 3: Missing token is rejected
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "${API_ENDPOINT}/solutions")
echo "Missing token: HTTP $RESPONSE (expected 401)"

# Test 4: Valid token is accepted on public health endpoint
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "${API_ENDPOINT}/health")
echo "Health check: HTTP $RESPONSE (expected 200)"
```

## OWASP API Top 10 Validation

The following table maps each OWASP API Security control to the Amatra platform implementation for all eleven Lambda routes.

| OWASP Control | Implementation | Validated |
|---------------|----------------|-----------|
| API1: Broken Object Level Authorization | Solution IDs scoped to authenticated user; cross-user access returns 403 | - [ ] |
| API2: Broken Authentication | Cognito JWT on all protected routes; only `/health` and `/auth/refresh` are public | - [ ] |
| API3: Broken Object Property Level Exposure | Lambda responses use explicit field whitelists | - [ ] |
| API4: Unrestricted Resource Consumption | Per-route throttling in API Gateway; per-user quota in DynamoDB | - [ ] |
| API5: Broken Function Level Authorization | Admin routes require `admin` Cognito group scope; non-admin JWT returns 403 | - [ ] |
| API6: Unrestricted Access to Sensitive Business Flows | Quota enforcement prevents brute-force generation | - [ ] |
| API7: Server Side Request Forgery | No user-controlled URLs in backend; GitHub URL is hardcoded | - [ ] |
| API8: Security Misconfiguration | S3 block public access, API GW HTTPS-only, no default credentials | - [ ] |
| API9: Improper Inventory Management | All eleven routes in OpenAPI spec; no undocumented routes | - [ ] |
| API10: Unsafe Consumption of APIs | Bedrock and GitHub SDK clients use retry and timeout configuration | - [ ] |

## Security Phase Gate

All of the following must be green before the Security Test Report (Deliverable #22) is signed off.

- [ ] Zero P1 or P2 security findings after IAM policy review
- [ ] All eleven Lambda routes confirmed JWT-protected (expired/tampered token tests passing)
- [ ] OWASP API Top 10 checklist 100% complete
- [ ] No plaintext credentials in any Lambda environment variable
- [ ] ECR image scan shows zero CRITICAL vulnerabilities in the production image tag
- [ ] Zero Bedrock/DynamoDB/S3 traffic traverses NAT Gateway (VPC endpoint validation)
- [ ] CloudTrail confirms all administrative API calls logged with actor identity
- [ ] GuardDuty shows zero HIGH or CRITICAL findings in the 72 hours following production deployment

---

# Migration & Cutover

## Migration Approach

The platform uses a **parallel deployment** strategy. The legacy manual workflow (Claude Code CLI on local laptops) continues without interruption throughout the engagement. The new Amatra Agentic Pre-Sales Platform is built, tested, and validated entirely in parallel in the new us-west-2 AWS footprint. At Go-Live (Week 12 / end of April 2026), the platform is activated by publishing the CLI to PyPI. No data migration from the legacy workflow is required — the new platform generates net-new solution packages in the S3 + GitHub storage model.

## Cutover Plan

The production cutover follows the sequence below, anchored to Week 12. All times are Pacific Time.

| Timing | Step | Owner | Verification |
|--------|------|-------|--------------|
| T-72h | Final staging smoke test completed | QA Engineer | All 12 artifact types pass |
| T-72h | All go-live readiness criteria confirmed green | Project Manager | Checklist signed off |
| T-48h | CTO production Cognito User Pool sign-off obtained | CTO | RAID log entry created |
| T-24h | Production DynamoDB tables, S3 bucket, Cognito User Pool activated | Cloud Engineer | All resources ACTIVE |
| T-24h | Global quota counter initialised for current month | Solutions Engineer | DynamoDB item confirmed |
| T-12h | GitHub repository branch protection and PAT integration validated | Solutions Engineer | Test commit successful |
| T-4h | Full Terraform apply for production environment | Cloud Engineer | All modules applied cleanly |
| T-4h | All five agents registered in production AgentCore Runtime | Solutions Engineer | All agents ACTIVE |
| T-1h | Production smoke test: one complete twelve-artifact solution | QA Engineer | All 12 artifacts in S3 + GitHub |
| T-1h | CloudWatch green baseline confirmed in production | DevOps Engineer | Dashboard green |
| T-0 | Go-live declared; CLI package published to PyPI | Engagement Lead | `pip install amatra-cli` succeeds |
| T+1h | Announcement sent to Marcus Patel for 120-consultant rollout | Project Manager | Email confirmed sent |

## Go/No-Go Criteria

All of the following must be confirmed green before go-live is declared at T-0.

- [ ] All twelve artifact types pass end-to-end generation in production smoke test
- [ ] P95 end-to-end latency confirmed < 60 minutes in production smoke test
- [ ] Per-solution Bedrock token spend confirmed ≤ $5 in production smoke test
- [ ] Zero P1/P2 open defects
- [ ] UAT sign-off from Marcus Patel, Daniel Park, and CTO (Deliverable #23)
- [ ] Green CloudWatch metrics dashboard certified by DevOps Engineer
- [ ] Security Test Report accepted (Deliverable #22)
- [ ] All eleven Lambda routes confirmed JWT-protected in production
- [ ] DynamoDB quota enforcement confirmed atomic with no race conditions
- [ ] GitHub PAT in Secrets Manager with rotation schedule active
- [ ] `terraform validate` passing in CI for all modules
- [ ] CTO sign-off for production Cognito User Pool activation recorded in RAID log
- [ ] Runbooks delivered and accepted by Daniel Park (Deliverable #27)
- [ ] `pip install amatra-cli==1.0.0` succeeds in a clean environment

## Rollback Strategy

Rollback is triggered if the production smoke test fails after two attempts, a P1 security vulnerability is discovered, CTO withholds sign-off, or P95 latency exceeds 90 minutes.

```bash
# Step 1: Notify stakeholders
python3 scripts/send_notification.py \
  --event rollback \
  --recipients "marcus.patel@predictif.com,sarah.lin@predictif.com,engagement@amatra.io" \
  --message "Production rollback initiated. Staging environment remains operational."

# Step 2: Roll back Lambda function aliases to previous stable version
for FUNCTION in solution-start solution-status artifact-download user-quota admin-usage; do
  PREV_VERSION=$(aws lambda list-versions-by-function \
    --function-name "amatra-${FUNCTION}-prod" \
    --query 'Versions[-2].Version' --output text)
  aws lambda update-alias \
    --function-name "amatra-${FUNCTION}-prod" \
    --name live --function-version $PREV_VERSION
  echo "Rolled back amatra-${FUNCTION}-prod to version $PREV_VERSION"
done

# Step 3: Re-register AgentCore agents with previous stable image tag
PREVIOUS_IMAGE_TAG=$(aws ecr describe-images \
  --repository-name amatra-agents \
  --query 'sort_by(imageDetails,& imagePushedAt)[-2].imageTags[0]' \
  --output text)

python3 scripts/register_agents.py \
  --image-uri "123456789012.dkr.ecr.us-west-2.amazonaws.com/amatra-agents:${PREVIOUS_IMAGE_TAG}" \
  --environment prod --region us-west-2

# Step 4: Validate staging environment is fully operational as interim service
python3 scripts/smoke_test.py --environment staging
echo "Rollback complete. Staging environment serving as interim platform."
```

Estimated rollback time: 2 hours. The staging environment remains fully operational throughout the cutover window.

---

# Operational Handover

## Documentation Handover

The following complete documentation package is delivered to PREDICTif at the end of Week 12. All documents are stored in the S3 artifact bucket under `documentation/` and committed to the GitHub repository.

- [ ] Architecture Design Document (full system architecture, component descriptions, data-flow diagrams, agent-graph topology, ADRs)
- [ ] API Reference (OpenAPI 3.0): all eleven Lambda routes, request/response schemas, JWT authorisation, error codes
- [ ] Deployment Guide (this document): step-by-step Terraform procedures for deploying the full platform
- [ ] Operational Runbooks: five scenario runbooks — agent timeout, quota throttle, GitHub PAT rotation, Bedrock disruption, Cognito outage
- [ ] Environment Variable Reference: all Lambda environment variables, Secrets Manager secret names, DynamoDB table names across dev, staging, production
- [ ] eof-tools Integration Guide: how eof-tools is baked into the ECR image, how to update the library version, how to add new artifact types
- [ ] As-Built Documentation Package (Deliverable #28)
- [ ] Test Results Report: unit, integration, load, security, and UAT results (Deliverable #26)
- [ ] Optimisation Recommendations and Phase 2 Roadmap (Deliverable #32)

## Support Transition

### Support Model

The following support tiers govern incident response during and after the hypercare period.

| Tier | Responsibility | Response Time | Escalation Path |
|------|----------------|---------------|-----------------|
| L1 – PREDICTif Operations | Initial triage, runbook-known issues | < 1 hour | Escalate to L2 after 2 hours unresolved |
| L2 – Amatra Hypercare (Weeks 13–20) | Technical troubleshooting, agent failure triage | P1: 1 hr; P2: 4 biz hrs; P3: next biz day | Escalate to L3 for code-level fixes |
| L3 – Amatra Engineering | Expert resolution and code-level fixes | < 1 business day | Escalate to AWS for service-level issues |
| AWS Support | Bedrock, Lambda, DynamoDB service issues | Per AWS Business Support SLA | TAM escalation for P1 |

### Escalation Path

For incidents during hypercare (Weeks 13–20):

1. **Primary Contact:** Marcus Patel, Director of Pre-Sales Engineering — first point of contact for all operational issues
2. **Executive Escalation:** Sarah Lin, CRO — for issues impacting business continuity or the executive sponsor demonstration
3. **Vendor Escalation:** Amatra Engagement Lead — `engagement@amatra.io`, +1 (800) 555-0190 — vendor-side L2/L3 resolution
4. **AWS Support:** Bedrock quota, AgentCore Runtime, DynamoDB issues via PREDICTif AWS account Support Centre

## Hypercare Period

The eight-week hypercare period (Weeks 13–20) provides hands-on support during the ramp-up to steady-state 200 solutions/month throughput.

- **Duration:** 8 weeks post-go-live (Weeks 13–20)
- **Coverage:** Business hours Monday–Friday 08:00–18:00 Pacific; P1 extended to 24×7
- **Included:** Bedrock quota monitoring and tuning, agent failure triage and recovery, validation retry rate investigation, CloudWatch alarm response, quota counter adjustment, GitHub PAT rotation support, minor bug fixes
- **Not Included During Hypercare:** New feature development, additional artifact types, multi-region expansion, Cognito User Pool changes beyond bug fixes, eof-tools refactoring
- **Hypercare Conclusion:** At Week 20, the Optimisation Recommendations and Phase 2 Roadmap are delivered and responsibility transfers fully to PREDICTif's nominated operations team

## Handover Checklist

The following checklist must be completed before formal handover sign-off at the end of Week 12.

- [ ] All documentation delivered and acknowledged by Marcus Patel
- [ ] Architecture Design Document reviewed and accepted by Marcus Patel and Daniel Park
- [ ] Operational Runbooks reviewed and accepted by Daniel Park
- [ ] Five runbook dry-runs completed with PREDICTif operations team
- [ ] Engineering Deep-Dive training session completed and recording uploaded to S3
- [ ] Pre-Sales Workflow Training completed; CLI cheat sheet distributed
- [ ] CloudWatch dashboards reviewed live with PREDICTif operations team
- [ ] Support model and escalation path distributed to all stakeholders
- [ ] Hypercare contact details confirmed
- [ ] Break-glass IAM role expiry date confirmed (auto-expires end of Week 20)
- [ ] Vendor AWS account access revocation scheduled for end of hypercare

---

# Training Program

## Training Overview

### Objectives

The training program ensures all user groups achieve competency with the Amatra Agentic Pre-Sales Platform before go-live and establishes ongoing learning paths for new team members as PREDICTif reaches full 120-consultant adoption. Training content is aligned with three platform personas: administrators and engineers who operate the platform, pre-sales consultants who generate solutions daily, and IT support staff who triage and escalate issues.

### Training Approach

The training program is delivered using the following approach to maximise coverage across 120 distributed consultants.

- **Phased Delivery:** Engineering training in Weeks 11–12; consultant rollout during Week 12 and hypercare
- **Role-Based:** Content tailored to each audience's responsibilities and technical depth
- **Hands-On Focus:** Practical exercises in the dev sandbox environment
- **Train-the-Trainer Model:** Marcus Patel's team trains 120 distributed consultants using delivered materials and recordings
- **Documentation First:** All materials stored in S3 and GitHub for self-service onboarding

## Training Schedule

The following table summarises all ten training modules, target audiences, durations, formats, and prerequisites.

| Module ID | Module Name | Target Audience | Duration | Format | Prerequisites |
|-----------|-------------|-----------------|----------|--------|---------------|
| TRN-001 | Platform Architecture Overview | Administrators, Engineering | 2 hours | ILT (recorded) | None |
| TRN-002 | AWS Console and Monitoring Operations | Administrators | 3 hours | Hands-On Lab | TRN-001 |
| TRN-003 | Terraform IaC and Deployment Procedures | DevOps / Engineering | 4 hours | Hands-On Lab | TRN-001 |
| TRN-004 | Backup, Recovery, and Runbook Execution | Administrators, Operations | 2 hours | VILT | TRN-002 |
| TRN-005 | CLI Installation and Core Workflow | Pre-Sales Consultants | 1.5 hours | VILT | None |
| TRN-006 | Solution Generation and Artifact Review | Pre-Sales Consultants | 2 hours | Hands-On Lab | TRN-005 |
| TRN-007 | Quota Management and Reporting | Pre-Sales Managers, Power Users | 1.5 hours | ILT | TRN-005 |
| TRN-008 | API Integration and Custom Workflows | IT Support, Solutions Engineers | 3 hours | Hands-On Lab | TRN-001 |
| TRN-009 | Troubleshooting and Escalation Procedures | IT Support, Operations | 2 hours | ILT | TRN-008 |
| TRN-010 | Train-the-Trainer Certification Workshop | Internal Trainers | 4 hours | Workshop | All modules |

## Administrator Training

### TRN-001: Platform Architecture Overview (2 hours, ILT — Recorded)

**Learning Objectives:**
- Describe the five-agent Strands graph and Step Functions orchestration model
- Navigate the CloudWatch Operations and Cost dashboards
- Explain the data flow from client brief submission to GitHub artifact commit
- Identify key integration points: Cognito, API Gateway, Bedrock, DynamoDB, S3, GitHub

**Content Outline:**
1. Platform architecture walkthrough — 45 min (five-agent graph, Step Functions, API layer)
2. CloudWatch dashboards tour — 30 min (P99 latency, error rates, token spend)
3. Data flow walkthrough — 30 min (S3 storage structure, DynamoDB tables, GitHub commit)
4. Knowledge check and Q&A — 15 min

**Materials Required:** Architecture diagram, CloudWatch read-only console access, component glossary quick reference card

### TRN-002: AWS Console and Monitoring Operations (3 hours, Hands-On Lab)

**Learning Objectives:**
- Access and interpret CloudWatch dashboards and alarms
- Search CloudWatch Logs for agent and Lambda execution traces using correlation IDs
- Monitor DynamoDB quota utilisation and perform monthly reset
- Review GuardDuty findings and route to SNS escalation path

**Lab Exercises:**
- Exercise 1: Locate a solution generation trace in CloudWatch Logs using a correlation ID
- Exercise 2: Identify a simulated validation retry spike on the Operations dashboard
- Exercise 3: Simulate a monthly quota reset against the global counter table
- Exercise 4: Triage a simulated GuardDuty finding and escalate via SNS

**Materials Required:** Lab guide with step-by-step instructions, dev environment read/write access, CloudWatch Logs Insights queries reference card

### TRN-003: Terraform IaC and Deployment Procedures (4 hours, Hands-On Lab)

**Learning Objectives:**
- Navigate the Terraform module structure and execute the four-layer deployment sequence
- Update a Lambda function deployment using the CI/CD pipeline
- Confirm `terraform validate` passes in CodeBuild after an IaC change
- Execute the Lambda rollback procedure to a previous function version

**Lab Exercises:**
- Exercise 1: Deploy the networking layer to dev using `terraform apply`
- Exercise 2: Trigger a Lambda code update via CodePipeline and observe build stages
- Exercise 3: Introduce a `terraform validate` syntax error; observe the CI gate rejection
- Exercise 4: Roll back a Lambda function to the previous version using aliases

**Materials Required:** Lab environment with Terraform, AWS CLI, and Docker; platform repository cloned; lab guide with expected outputs

### TRN-004: Backup, Recovery, and Runbook Execution (2 hours, VILT)

**Learning Objectives:**
- Execute all five operational runbooks: agent timeout, quota throttle, GitHub PAT rotation, Bedrock disruption, Cognito outage
- Verify DynamoDB PITR restoration from a 24-hour backup
- Rotate the GitHub PAT using the documented procedure
- Confirm platform health after each recovery action

**Materials Required:** Five operational runbooks (PDF and GitHub), VILT platform with screen share, dev environment with pre-configured failure scenarios

## End User Training

### TRN-005: CLI Installation and Core Workflow (1.5 hours, VILT)

**Learning Objectives:**
- Install the Amatra CLI using `pip install amatra-cli` in a virtual environment
- Authenticate with `amatra login` and manage thirty-day JWT refresh tokens
- Generate a solution using `amatra generate` and monitor progress with `amatra status`
- Check quota usage and download artifacts with `amatra artifacts download`

**Content Outline:**
1. CLI installation and prerequisites — 15 min (`pip install amatra-cli`, `amatra --version`)
2. Authentication workflow — 20 min (`amatra login`, token storage, `amatra logout`)
3. Solution generation walkthrough — 30 min (`amatra generate`, `amatra status`, progress monitoring)
4. Artifact download and review — 15 min (`amatra artifacts list`, `amatra artifacts download`)
5. Support resources — 10 min (CLI cheat sheet, `amatra --help`, escalation path)

**Materials Required:** VILT platform with screen share, pre-configured dev environment, CLI cheat sheet (one page), FAQ document

### TRN-006: Solution Generation and Artifact Review (2 hours, Hands-On Lab)

**Learning Objectives:**
- Submit a client brief that passes Input Validator validation on the first attempt
- Interpret generation status messages and distinguish successful generation from retry states
- Review all twelve generated artifacts against EO Framework quality standards
- Download and share DOCX, PPTX, and XLSX artifacts with clients

**Lab Exercises:**
- Exercise 1: Submit a brief with a missing required field; observe rejection; correct and resubmit
- Exercise 2: Generate a complete solution for a provided sample scenario; download all twelve artifacts
- Exercise 3: Review the `statement-of-work.md` and `solution-briefing.md` against the EO Framework checklist

**Materials Required:** Dev environment with sandbox Cognito credentials, three sample brief templates (SMB, mid-market, enterprise), EO Framework artifact quality checklist

## Power User Training

### TRN-007: Quota Management and Reporting (1.5 hours, ILT)

**Learning Objectives:**
- Interpret per-user and global quota utilisation from `amatra quota status` and the admin API
- Access the CloudWatch Cost dashboard to track per-solution Bedrock token spend
- Understand the monthly quota reset cycle and the quota override procedure
- Run usage reports using the `GET /admin/usage` API endpoint

**Content Outline:**
1. Quota model overview — 20 min (per-user 10/month, global 1,000/month)
2. Monitoring quota via CLI and CloudWatch — 30 min
3. Quota reset cycle and emergency override procedure — 20 min
4. Admin usage reporting — 20 min (`GET /admin/usage`, interpreting output)

**Materials Required:** CLI with admin scope credentials, CloudWatch console access, quota override request form

## IT Support Training

### TRN-008: API Integration and Custom Workflows (3 hours, Hands-On Lab)

**Learning Objectives:**
- Authenticate programmatically against the Amatra API using Cognito JWT tokens
- Call all eleven Lambda routes using Python `requests` or `curl`
- Build a polling workflow: submit brief → poll status → download artifacts
- Troubleshoot API errors (401, 403, 429, 500) using CloudWatch Logs correlation IDs

**Lab Exercises:**
- Exercise 1: Obtain a Cognito JWT programmatically using the `POST /auth/refresh` flow
- Exercise 2: Submit `POST /solutions` and poll `GET /solutions/{id}/status` until completion
- Exercise 3: Download the `implementation-guide.md` artifact via the S3 presigned URL
- Exercise 4: Introduce a deliberate 401 error; locate the CloudWatch Logs entry using the correlation ID

**Materials Required:** Python 3.11+ with `requests` installed, OpenAPI specification, CloudWatch Logs read access

### TRN-009: Troubleshooting and Escalation Procedures (2 hours, ILT)

**Learning Objectives:**
- Diagnose the five most common platform issues using CloudWatch Logs and operational runbooks
- Apply P1/P2/P3 incident classification and correct response times
- Execute runbooks for agent timeout, quota throttle, GitHub PAT expiry, and Bedrock disruption
- Escalate to Amatra L3 hypercare with the correct information package

**Materials Required:** Five operational runbooks, incident classification guide, escalation package template, CloudWatch Logs Insights queries reference

## Train-the-Trainer

### TRN-010: Train-the-Trainer Certification Workshop (4 hours, Workshop)

**Learning Objectives:**
- Deliver TRN-005 and TRN-006 independently to groups of up to 20 consultants
- Facilitate hands-on lab exercises using the sandbox environment
- Answer the thirty most common questions from the CLI FAQ
- Assess learner competency using the provided assessment checklist
- Onboard new consultants using the recorded TRN-001 session and CLI cheat sheet

**Content Outline:**
1. Trainer preparation and sandbox reset procedure — 30 min
2. TRN-005 delivery walkthrough with facilitation tips — 60 min
3. TRN-006 delivery walkthrough with live exercise facilitation — 60 min
4. Common questions and edge cases — 30 min
5. Competency assessment and certification sign-off process — 30 min
6. New consultant onboarding checklist review — 30 min

**Materials Required:** TRN-005 and TRN-006 slides, lab guides, CLI cheat sheet; sandbox admin access; FAQ with thirty Q&As; five-task competency checklist; trainer certification sign-off form

## Training Materials

### Documentation Package

The following training materials are delivered at the end of Week 12 and stored in S3 under `documentation/training/`.

- Administrator Guide (Markdown + PDF, ~50 pages) — architecture, operations, Terraform deployment
- End User CLI Guide (Markdown + PDF, ~20 pages) — installation, authentication, generation, artifact review
- Quick Reference Cards — one per role (Administrator, Pre-Sales Consultant, IT Support)
- CLI Cheat Sheet — all fourteen subcommands with examples (one page)
- Video Recordings — all ILT and VILT sessions stored in S3 under `documentation/training/recordings/`
- Lab Exercise Workbooks — for TRN-003, TRN-006, and TRN-008 (with facilitator solution keys)
- FAQ Document — thirty common questions covering installation, authentication, generation, quotas, and troubleshooting

### Training Environment

The dev environment serves as the sandbox training environment with the following configuration.

- Cognito User Pool `amatra-user-pool-dev` with pre-configured training accounts
- DynamoDB tables reset before each session using the monthly reset Lambda
- S3 artifact bucket `amatra-artifacts-dev` contains sample completed solutions for review exercises
- Sandbox training accounts have reduced quota (5 solutions/user/month) to limit Bedrock spend during training

## Training Effectiveness

### Assessment Approach

Training completion is tracked and assessed using the following methods for all modules.

- **Knowledge Checks:** Five-question quiz at end of each module; 70% pass required for training credit
- **Practical Assessment:** Completion of designated lab exercises verified against solution keys
- **TRN-010 Certification:** Trainer candidates deliver a thirty-minute TRN-005 or TRN-006 segment to a panel of at least two attendees

### Success Metrics

The following metrics define training programme success and are reported to Marcus Patel at the end of the hypercare period.

| Metric | Target |
|--------|--------|
| Training Completion Rate | > 95% of assigned pre-sales consultants within 4 weeks of go-live |
| Knowledge Check Pass Rate | > 85% first attempt across all modules |
| Post-Training Satisfaction Score | > 4.0/5.0 collected at end of each module |
| Time to First Successful Generation | < 30 minutes for a trained consultant |
| TRN-010 Trainer Certification Rate | 100% of designated internal trainers by end of Week 12 |

---

# Appendices

## Appendix A: Environment Details

This appendix provides a quick reference for the three deployment environment configurations.

### Development Environment

| Component | Value |
|-----------|-------|
| AWS Region | us-west-2 |
| VPC CIDR | 10.0.0.0/16 |
| Cognito User Pool | `amatra-user-pool-dev` |
| DynamoDB Tables | `amatra-user_profiles-dev`, `amatra-solution_state-dev`, `amatra-quota_global-dev` |
| S3 Artifact Bucket | `amatra-artifacts-dev` |
| API Endpoint | `https://{api-id}.execute-api.us-west-2.amazonaws.com/dev` |
| ECR Repository | `123456789012.dkr.ecr.us-west-2.amazonaws.com/amatra-agents` |
| Access Method | IAM role assumption via `aws configure --profile amatra-dev` |
| Data Classification | Synthetic test data only |

### Staging Environment

| Component | Value |
|-----------|-------|
| AWS Region | us-west-2 |
| VPC CIDR | 10.0.0.0/16 (separate VPC) |
| Cognito User Pool | `amatra-user-pool-staging` |
| DynamoDB Tables | `amatra-user_profiles-staging`, `amatra-solution_state-staging`, `amatra-quota_global-staging` |
| S3 Artifact Bucket | `amatra-artifacts-staging` |
| API Endpoint | `https://{api-id}.execute-api.us-west-2.amazonaws.com/staging` |
| Access Method | IAM role assumption; MFA required; Amatra team + Client IT Lead |
| Data Classification | Anonymised/sample client briefs |

### Production Environment

| Component | Value |
|-----------|-------|
| AWS Region | us-west-2 |
| VPC CIDR | 10.0.0.0/16 (dedicated production VPC) |
| Cognito User Pool | `amatra-user-pool-prod` (CTO sign-off required) |
| DynamoDB Tables | `amatra-user_profiles-prod`, `amatra-solution_state-prod`, `amatra-quota_global-prod` |
| S3 Artifact Bucket | `amatra-artifacts-prod` |
| API Endpoint | `https://{api-id}.execute-api.us-west-2.amazonaws.com/prod` |
| Access Method | Named individuals; MFA mandatory; CTO approval |
| Data Classification | Real client engagement data; full KMS encryption |

## Appendix B: Terraform Module Reference

The following table summarises the five Terraform modules that compose the full platform. All modules must pass `terraform validate` in CI before `terraform apply` is permitted.

| Module | Directory | Key Resources | Apply Order |
|--------|-----------|---------------|-------------|
| Landing Zone | `infrastructure/landing-zone/` | VPC, IAM boundaries, Cost Allocation Tags | 1 |
| Networking | `infrastructure/networking/` | Subnets, NAT GW, VPC endpoints, Security Groups | 2 |
| Security | `infrastructure/security/` | Cognito, KMS, Secrets Manager, GuardDuty, CloudTrail | 3 |
| Compute | `infrastructure/compute/` | ECR, Lambda, AgentCore, Step Functions, CodePipeline | 4 |
| Monitoring | `infrastructure/monitoring/` | CloudWatch Logs, dashboards, alarms, SNS | 5 |

## Appendix C: Deployment Scripts Reference

### deploy.sh — Full Platform Deployment

The following script deploys all four infrastructure layers in sequence and runs a post-deployment smoke test.

```bash
#!/bin/bash
# deploy.sh — Full Amatra platform deployment script
# Usage: ./deploy.sh [dev|staging|prod] [image-tag]
set -euo pipefail

ENVIRONMENT=${1:-dev}
IMAGE_TAG=${2:-latest}
REPO_ROOT=$(git rev-parse --show-toplevel)

echo "Deploying Amatra Platform — Environment: $ENVIRONMENT — Image: $IMAGE_TAG"

for LAYER in networking security compute monitoring; do
  echo "Deploying layer: $LAYER"
  cd $REPO_ROOT/infrastructure/$LAYER
  terraform init -backend-config="${ENVIRONMENT}-backend.tfvars" -reconfigure
  terraform apply -var-file="${ENVIRONMENT}.tfvars" -auto-approve
  terraform output -json > $REPO_ROOT/outputs/${LAYER}-outputs-${ENVIRONMENT}.json
  echo "Layer $LAYER deployed successfully."
done

echo "Running post-deployment smoke test..."
cd $REPO_ROOT
python3 scripts/smoke_test.py --environment ${ENVIRONMENT}
echo "Deployment complete for: $ENVIRONMENT"
```

### rollback.sh — Platform Rollback

The following script rolls back Lambda functions and AgentCore agents to the previous stable version.

```bash
#!/bin/bash
# rollback.sh — Lambda and AgentCore rollback script
# Usage: ./rollback.sh [dev|staging|prod] [previous-image-tag]
set -euo pipefail

ENVIRONMENT=${1:-dev}
PREVIOUS_TAG=${2:-}
ECR_URI="123456789012.dkr.ecr.us-west-2.amazonaws.com/amatra-agents"

if [ -z "$PREVIOUS_TAG" ]; then
  PREVIOUS_TAG=$(aws ecr describe-images \
    --repository-name amatra-agents --region us-west-2 \
    --query 'sort_by(imageDetails,& imagePushedAt)[-2].imageTags[0]' \
    --output text)
  echo "Auto-detected previous image tag: $PREVIOUS_TAG"
fi

# Roll back Lambda function aliases
for FUNCTION in solution-start solution-status artifact-download user-quota admin-usage; do
  PREV_VER=$(aws lambda list-versions-by-function \
    --function-name "amatra-${FUNCTION}-${ENVIRONMENT}" \
    --query 'Versions[-2].Version' --output text 2>/dev/null || echo "1")
  aws lambda update-alias \
    --function-name "amatra-${FUNCTION}-${ENVIRONMENT}" \
    --name live --function-version $PREV_VER
  echo "Rolled back amatra-${FUNCTION}-${ENVIRONMENT} to version $PREV_VER"
done

# Roll back AgentCore agents
python3 scripts/register_agents.py \
  --image-uri "${ECR_URI}:${PREVIOUS_TAG}" \
  --environment ${ENVIRONMENT} --region us-west-2

python3 scripts/smoke_test.py --environment ${ENVIRONMENT}
echo "Rollback complete."
```

## Appendix D: Troubleshooting Guide

This appendix documents the five most common issues observed during Phase 3 testing, with resolution procedures aligned to the operational runbooks.

### Issue 1: Agent Timeout — Step Functions Execution Stuck in Running

**Symptoms:** Step Functions console shows execution `Running` for > 30 minutes; CloudWatch Logs for the affected agent show no recent entries; `amatra status` returns `GENERATING` for > 60 minutes.

**Cause:** Bedrock InvokeModel call timed out or hit a service-side error; Step Functions retry policy exhausted; agent Lambda reached 15-minute timeout.

**Resolution:**

```bash
# Identify and stop stuck executions
aws stepfunctions list-executions \
  --state-machine-arn ${STATE_MACHINE_ARN} \
  --status-filter RUNNING \
  --query 'executions[*].{Name:name,Start:startDate,Arn:executionArn}' \
  --output table

aws stepfunctions stop-execution \
  --execution-arn ${STUCK_EXECUTION_ARN} \
  --error "AgentTimeout" \
  --cause "Manual stop by operations team after 60 minute timeout"

# Check CloudWatch Logs for root cause
aws logs start-query \
  --log-group-name "/aws/lambda/amatra-presales-generator-prod" \
  --start-time $(date -d '2 hours ago' +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc | limit 20'
```

### Issue 2: GitHub PAT Expiry — Artifact Commit Stalls

**Symptoms:** Generation shows all twelve artifacts validated but GitHub commit step fails; Code Generator agent logs show `403 Forbidden` from GitHub API; `GET /solutions/{id}/status` returns `COMMIT_FAILED`.

**Cause:** GitHub PAT has expired or been revoked; the 90-day rotation Lambda did not complete.

**Resolution:**

```bash
# Check PAT rotation status
aws secretsmanager describe-secret \
  --secret-id "amatra/github-pat" \
  --query '{LastRotated:LastRotatedDate,NextRotation:NextRotationDate}' \
  --output table

# Trigger rotation Lambda manually
aws lambda invoke \
  --function-name "amatra-github-pat-rotation-prod" \
  --payload '{"SecretId":"amatra/github-pat","Step":"createSecret"}' \
  /tmp/rotation-response.json
cat /tmp/rotation-response.json

# Retry the failed commit
python3 scripts/retry_github_commit.py \
  --solution-id ${FAILED_SOLUTION_ID} --environment prod
```

### Issue 3: DynamoDB Quota Table Throttle

**Symptoms:** CloudWatch alarm `amatra-dynamodb-throttle-prod` enters ALARM state; users receive `QuotaExceededException` even when below the 1,000/month limit.

**Cause:** Burst of concurrent writes exceeds DynamoDB on-demand burst capacity.

**Resolution:**

```bash
# Check consumed write capacity
aws cloudwatch get-metric-statistics \
  --namespace "AWS/DynamoDB" \
  --metric-name "ConsumedWriteCapacityUnits" \
  --dimensions Name=TableName,Value=amatra-quota_global-prod \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 60 --statistics Sum --output table

# Switch to provisioned capacity if throttling persists
aws dynamodb update-table \
  --table-name amatra-quota_global-prod \
  --billing-mode PROVISIONED \
  --provisioned-throughput ReadCapacityUnits=100,WriteCapacityUnits=100
```

### Issue 4: Bedrock Service Disruption

**Symptoms:** Multiple agent executions fail simultaneously with `ServiceUnavailableException`; AWS Health Dashboard shows active Bedrock incident in us-west-2.

**Resolution:**

```bash
# Check AWS Health Dashboard for active Bedrock events
aws health describe-events \
  --filter '{"services":["BEDROCK"],"regions":["us-west-2"],"eventStatusCodes":["open","upcoming"]}' \
  --query 'events[*].{Service:service,Status:statusCode,StartTime:startTime}' \
  --output table

# Pause new solution generation requests during active incident
aws apigatewayv2 update-stage \
  --api-id ${API_ID} --stage-name ${ENVIRONMENT} \
  --default-route-settings '{"ThrottlingBurstLimit":0,"ThrottlingRateLimit":0}'
```

### Issue 5: Cognito User Pool Outage

**Symptoms:** All `amatra login` commands fail; API Gateway returns 401 for all requests including valid tokens; CloudWatch Logs show JWT authoriser failures.

**Resolution:**

```bash
# Check Cognito service health
aws health describe-events \
  --filter '{"services":["COGNITO"],"regions":["us-west-2"],"eventStatusCodes":["open"]}' \
  --query 'events[*].{Service:service,Status:statusCode,StartTime:startTime}' \
  --output table

# Communicate outage status — existing JWT tokens remain valid until expiry
python3 scripts/send_notification.py \
  --event cognito-outage \
  --recipients "marcus.patel@predictif.com" \
  --message "Cognito disruption in us-west-2. Active sessions continue. New logins unavailable. Tracking: https://health.aws.amazon.com"
```

## Appendix E: Contact Information

### Project Team

| Role | Contact | Email | Availability |
|------|---------|-------|--------------|
| Engagement Lead / Solution Architect | Amatra Engagement Lead | engagement@amatra.io | Business hours + P1 on-call |
| Cloud Engineer | Amatra Cloud Engineer | cloud@amatra.io | Business hours |
| ML/AI Engineer | Amatra ML Engineer | ai@amatra.io | Business hours |
| DevOps Engineer | Amatra DevOps Engineer | devops@amatra.io | Business hours |
| Security Engineer | Amatra Security Engineer | security@amatra.io | Business hours |
| Project Manager | Amatra Project Manager | pm@amatra.io | Business hours |

### Client Escalation Contacts

| Role | Name | Email |
|------|------|-------|
| Director of Pre-Sales Engineering (Primary) | Marcus Patel | marcus.patel@predictif.com |
| Head of Delivery Operations | Daniel Park | daniel.park@predictif.com |
| Executive Sponsor (CRO) | Sarah Lin | sarah.lin@predictif.com |
| Client IT Lead | Nominated in Week 1 | client-it@predictif.com |

### Vendor Support

| Vendor | Portal | SLA |
|--------|--------|-----|
| AWS Business Support | https://console.aws.amazon.com/support | P1: < 1 hour response |
| Amatra Hypercare | engagement@amatra.io / +1 (800) 555-0190 | P1: 1 hr; P2: 4 biz hrs; P3: next biz day |

## Appendix F: Go-Live Readiness Checklist

All items below must be confirmed GREEN before go-live is declared at T-0.

- [ ] All twelve artifact types pass end-to-end generation in production smoke test
- [ ] P95 end-to-end latency confirmed < 60 minutes under 200 solutions/month load
- [ ] Per-solution Bedrock token spend confirmed ≤ $5 in load test
- [ ] Zero P1/P2 open defects
- [ ] UAT sign-off from Marcus Patel, Daniel Park, and CTO (Deliverable #23)
- [ ] Green CloudWatch metrics dashboard certified by DevOps Engineer
- [ ] Security Test Report accepted (Deliverable #22)
- [ ] All eleven Lambda routes confirmed JWT-protected in production
- [ ] DynamoDB quota enforcement confirmed atomic under concurrent load
- [ ] GitHub PAT in Secrets Manager with 90-day rotation schedule active
- [ ] Terraform IaC `terraform validate` passing in CI for all modules
- [ ] CTO sign-off for production Cognito User Pool activation recorded in RAID log
- [ ] All five runbook dry-runs completed with Daniel Park
- [ ] Engineering Deep-Dive training session completed and recording in S3
- [ ] Pre-Sales Workflow Training completed; CLI cheat sheet distributed
- [ ] CLI package `amatra-cli==1.0.0` on PyPI and `pip install` verified in clean environment
- [ ] Executive sponsor demonstration package delivered to Sarah Lin (Deliverable #31)
