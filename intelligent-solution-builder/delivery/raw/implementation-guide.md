---
document_title: Implementation Guide
solution_name: Amatra Intelligent Solution Builder
document_version: "1.0"
author: Lead Solutions Architect — EO Framework Consulting
last_updated: 2026-07-01
technology_provider: aws
client_name: Amatra
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

## Project Overview

This Implementation Guide provides step-by-step procedures for deploying the **Amatra Intelligent Solution Builder** — a fully serverless, AI-powered AWS platform that converts a structured client brief into a complete consulting-grade engagement package. The platform is built on Amazon Bedrock (Claude 3 Sonnet/Haiku), AWS Lambda, Amazon API Gateway, AWS Step Functions, Amazon SQS, Amazon DynamoDB, Amazon S3, and Amazon Cognito, all deployed in us-west-2 to enforce US data residency. It automates seven artifact types across pre-sales and delivery workstreams and is designed from the outset to satisfy SOC 2 Type II and GDPR-aligned data-handling requirements.

This guide follows the three-phase delivery structure established in the Statement of Work (OPP-2026-001): Phase 1 (Foundation & Pre-Sales MVP, target 30 September 2026), Phase 2 (Delivery Automation & Terraform Pipeline, target 15 December 2026), and Phase 3 (GA Rollout & Optimisation, target Q1 2027 with hard deadline 31 January 2027). All procedures, phase names, durations, and deliverables trace directly to SOW commitments.

## Implementation Scope

**In Scope:**
- Greenfield serverless AWS platform deployment in us-west-2 (Lambda, API Gateway, DynamoDB, S3, Cognito, SQS, Step Functions)
- Amazon Bedrock (Claude 3 Sonnet/Haiku) integration for all seven artifact types
- Okta-to-Cognito identity migration with zero-downtime parallel-run
- SOC 2 Type II controls (CloudTrail, KMS, WAF, GuardDuty, Security Hub) from Phase 1
- Legacy Word/Excel/PowerPoint template ingestion pipeline (Phase 2)
- Multi-environment CI/CD pipeline (GitHub Actions) for Dev, Staging, and Production
- Pre-sales artifact pipeline: discovery questionnaire, solution briefing, SOW, infrastructure cost model
- Delivery artifact pipeline: detailed design document, implementation guide, Terraform automation scripts
- CloudWatch monitoring dashboards, alarms, and SLA tracking
- Training for pre-sales consultants, delivery team, and platform administrators
- 8-week hypercare (Phase 1) and 4-week hypercare (Phase 2)

**Out of Scope:**
- Multi-region deployment or secondary-region disaster recovery
- External client-facing portal
- Custom foundation model fine-tuning beyond prompt engineering
- CRM integration or billing automation
- Physical or on-premises infrastructure
- Ongoing managed services post-hypercare
- HIPAA, PCI-DSS, or FedRAMP compliance frameworks
- Historical engagement artifact data migration

**Dependencies:**
- AWS account provisioned in us-west-2 with IAM access granted to vendor team (Week 1)
- Okta user directory export provided by Security & Compliance Lead (Week 2)
- 10–20 representative historical client briefs (PII-scrubbed) from Head of Solutions (Week 2)
- AWS Bedrock Claude 3 Sonnet and Haiku model access enabled in us-west-2 (Month 2)
- Legacy artifact template files exported from Google Workspace (Month 2)

## Timeline Overview

- **Project Duration:** 12 months (July 2026 – Q1 2027)
- **Phase 1 MVP Go-Live:** 30 September 2026
- **Phase 2 Go-Live:** 15 December 2026
- **General Availability:** 31 January 2027 (hard deadline)
- **Key Milestones:**
  - M1 — Kickoff Complete: Month 1, Week 1
  - M2 — Architecture Approved: Month 2, Week 2
  - M3 — Infrastructure Foundation Live: Month 3, Week 4
  - M4 — Phase 1 MVP Go-Live: 30 September 2026
  - M5 — Phase 1 Hypercare End: Month 6, Week 4
  - M6 — Phase 2 Go-Live: 15 December 2026
  - M7 — Phase 2 Hypercare End: Month 9, Week 2
  - M8 — GA Rollout Complete: Q1 2027
  - M9 — Project Close: January 2027

# Prerequisites

## Technical Prerequisites

Complete all items in this section before beginning Phase 1 activities. Each item maps to a SOW dependency with a defined "Required By" date.

### Cloud Infrastructure

- [ ] AWS account provisioned in us-west-2 with a unique 12-digit account ID
- [ ] Administrator IAM access granted to vendor engineering team (GitHub Actions OIDC role pre-created)
- [ ] AWS Organizations SCP configured to block replication outside us-east-1/us-west-2
- [ ] AWS Business Support plan activated on production account (required for 99.9% SLA, 1-hour critical response)
- [ ] AWS Bedrock Claude 3 Sonnet (`anthropic.claude-3-sonnet-20240229-v1:0`) and Haiku (`anthropic.claude-3-haiku-20240307-v1:0`) model access enabled in us-west-2
- [ ] Billing alerts configured at $2,000/month threshold
- [ ] Resource quotas verified: Lambda concurrent executions ≥ 1,000; API Gateway ≥ 10,000 RPS

### Identity and Access

- [ ] Okta user directory export completed by Security & Compliance Lead (all ~50 active user records in JSON format)
- [ ] IAM OIDC provider created for GitHub Actions (`token.actions.githubusercontent.com`)
- [ ] GitHub Actions OIDC IAM role created with trust policy scoped to `amatra/amatra-isb` repository
- [ ] Development, Staging, and Production IAM environment boundaries defined

### Security Baseline

The four KMS Customer Managed Keys listed below must exist before any data store can be provisioned. Each key requires annual auto-rotation enabled and a key policy that restricts usage to named IAM roles only.

- [ ] `alias/amatra-isb-s3-artifacts-prod` — for S3 artifacts bucket
- [ ] `alias/amatra-isb-dynamodb-prod` — for both DynamoDB tables
- [ ] `alias/amatra-isb-cloudtrail-prod` — for CloudTrail log bucket; root user denied in key policy
- [ ] `alias/amatra-isb-secrets-manager-prod` — for Secrets Manager
- [ ] S3 Block Public Access enforced at AWS account level (all four settings enabled)
- [ ] CloudTrail trail enabled for all management events and S3 data events
- [ ] AWS Config enabled with SOC 2 alignment managed rules

### Development Tools

- [ ] GitHub repository `amatra/amatra-isb` created and vendor team granted write access
- [ ] GitHub Actions Team plan active for engineering team
- [ ] Python 3.12 development environment configured on all vendor workstations
- [ ] AWS CLI v2 installed and configured
- [ ] AWS SAM CLI installed (version ≥ 1.90)
- [ ] Terraform CLI installed (version ≥ 1.6)

### Secrets Manager Pre-Provisioning

All secrets are created with placeholder values at project start and populated with real values at each phase deployment. The following secrets must exist under prefix `amatra/prod/` before Phase 1 infrastructure deployment begins.

- [ ] `amatra/prod/bedrock/api-config`
- [ ] `amatra/prod/cognito/user-pool-config`
- [ ] `amatra/prod/dynamodb/table-config`
- [ ] `amatra/prod/s3/bucket-config`
- [ ] `amatra/prod/datadog/api-key`
- [ ] `amatra/prod/github/oidc-config`

## Organizational Prerequisites

- [ ] CTO executive sponsorship confirmed; budget approved ($378,178 Year 1 net of credits)
- [ ] VP Engineering available for ≥20% time commitment throughout the engagement
- [ ] Head of Solutions available for Phase 1 UAT leadership and artifact quality sign-off
- [ ] Security & Compliance Lead available for ≥2 hours/week for SOC 2 scoping and review
- [ ] Pre-sales consultants (3–5) confirmed available for Phase 1 UAT (Month 4)
- [ ] Delivery consulting team confirmed available for Phase 2 UAT (Month 7)
- [ ] Change management process activated; platform communication plan drafted
- [ ] Dedicated Slack channel `#amatra-isb-ops` created and shared with vendor team

## Environmental Setup Checklist

### Development Environment

- [ ] Development IAM boundary or sub-account created for the `dev` environment
- [ ] Development Cognito user pool (`amatra-isb-users-dev`) created with synthetic test users
- [ ] Development DynamoDB tables (`AmatraISB-SolutionState-Dev`, `AmatraISB-UsageTracking-Dev`) created
- [ ] Development S3 buckets created with SSE-KMS using dev CMKs
- [ ] GitHub Actions workflow `phase1-deploy-dev.yml` deploying successfully to dev

### Staging Environment

- [ ] Staging IAM boundary or sub-account created for the `staging` environment
- [ ] Staging mirrors production architecture at reduced compute sizing
- [ ] Synthetic client brief test data loaded (no real PII)
- [ ] QA team and Amatra VP Engineering granted Cognito staging user pool access
- [ ] GitHub Actions workflow `phase1-deploy-staging.yml` deploying successfully to staging

### Production Environment

- [ ] Production AWS account dedicated and isolated from dev and staging
- [ ] Production-grade resource quotas reserved
- [ ] CloudWatch Synthetics canary pre-configured for `GET /api/v1/health`
- [ ] On-call rotation established with vendor team for Phase 1 hypercare
- [ ] Rollback procedure rehearsed; Lambda alias revert workflow tested end-to-end

# Environment Setup

## Phase 1: Foundation Setup (Months 1–2)

### Objectives

Phase 1 establishes the complete AWS landing zone, CI/CD pipeline, security baseline, and observability foundation. At the end of this phase all three environments are provisioned and the CI/CD pipeline is deploying infrastructure changes automatically with mandatory quality gates between each promotion.

### Activities

The following activities are executed in sequence during Months 1–2. Each activity has a defined owner, estimated duration, and prerequisite dependency.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Project kickoff with CTO, VP Engineering, Head of Solutions | Project Manager | 1 day | SOW signature |
| Current-state assessment: legacy template inventory, workflow benchmark | Lead Architect + ML Engineer | 3 days | Kickoff |
| AWS landing zone setup (IAM roles, CloudTrail, Config, SCPs) | Cloud/DevOps Engineer | 3 days | Account provisioning |
| Dev and Staging environment provisioning | Cloud/DevOps Engineer | 3 days | Landing zone |
| KMS CMK creation and key policy configuration | Security Engineer | 1 day | Landing zone |
| S3 bucket creation (artifacts, CloudTrail, templates) | Cloud/DevOps Engineer | 1 day | KMS CMKs |
| DynamoDB table creation (SolutionState, UsageTracking) | Cloud/DevOps Engineer | 1 day | Landing zone |
| GitHub Actions CI/CD pipeline (multi-env) | Cloud/DevOps Engineer | 3 days | Environments |
| CloudWatch dashboards, alarms, and Synthetics canary baseline | Cloud/DevOps Engineer | 2 days | Environments |
| GuardDuty, Security Hub, and WAF initial configuration | Security Engineer | 2 days | Landing zone |

### Detailed Procedures

#### 1.1 AWS Landing Zone Setup

Before provisioning application resources, the landing zone must be established. Execute the following commands from the vendor engineering workstation with administrator access to the target AWS account.

```bash
git clone https://github.com/amatra/amatra-isb.git
cd amatra-isb/infrastructure/landing-zone
aws configure set region us-west-2

aws cloudformation deploy \
  --template-file landing-zone.yaml \
  --stack-name amatra-isb-landing-zone \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    Environment=prod \
    OpportunityId=OPP-2026-001 \
    CloudTrailRetentionYears=7

aws cloudtrail get-trail-status \
  --name amatra-isb-cloudtrail-prod \
  --query '{IsLogging: IsLogging, LatestDeliveryTime: LatestDeliveryTime}'
```

#### 1.2 KMS CMK Provisioning

Four Customer Managed Keys are required before any data stores are provisioned. Deploy the KMS stack and verify all four aliases exist before continuing.

```bash
cd infrastructure/security/kms

aws cloudformation deploy \
  --template-file kms-keys.yaml \
  --stack-name amatra-isb-kms-keys-prod \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides Environment=prod

aws kms list-aliases \
  --query "Aliases[?contains(AliasName, 'amatra-isb')].AliasName" \
  --output table
```

#### 1.3 Environment Provisioning

Deploy all three environments using the SAM template with environment-specific variable files.

```bash
cd infrastructure/environments

sam deploy \
  --template-file template.yaml \
  --stack-name amatra-isb-dev \
  --parameter-overrides file://dev.json \
  --capabilities CAPABILITY_NAMED_IAM \
  --resolve-s3

sam deploy \
  --template-file template.yaml \
  --stack-name amatra-isb-staging \
  --parameter-overrides file://staging.json \
  --capabilities CAPABILITY_NAMED_IAM \
  --resolve-s3

aws cloudformation describe-stacks \
  --query "Stacks[?contains(StackName,'amatra-isb')].{Name:StackName,Status:StackStatus}" \
  --output table
```

#### 1.4 CI/CD Pipeline Validation

Once environments are provisioned, validate that the GitHub Actions pipeline can deploy end-to-end without errors.

```bash
gh workflow run phase1-deploy-dev.yml \
  --ref main \
  --field version=0.1.0-test

gh run watch --exit-status

aws lambda list-functions \
  --query "Functions[?starts_with(FunctionName,'isb-')].{Name:FunctionName,State:State}" \
  --output table
```

### Deliverables

- [ ] AWS landing zone operational (CloudTrail, Config, SCPs active) in all environments
- [ ] All 4 KMS CMKs provisioned with correct key policies and annual rotation enabled
- [ ] Dev and Staging environments provisioned and accessible
- [ ] CI/CD pipeline (GitHub Actions) successfully deploying to dev and staging
- [ ] CloudWatch baseline alarms configured (DLQ depth, API 5xx, job failure rate)
- [ ] GuardDuty and Security Hub enabled and baseline findings reviewed

### Success Criteria

- CloudTrail logging confirmed active with log file integrity validation enabled
- All CI/CD pipeline smoke-test runs pass with zero infrastructure drift between runs
- Security scan returns no critical findings on landing zone resources
- All four KMS CMK aliases visible in us-west-2 with rotation status `ENABLED`

## Phase 2: Core Platform Build (Months 2–3)

### Objectives

Phase 2 deploys the core serverless platform components: Amazon Cognito with Okta migration, API Gateway, Lambda functions, Step Functions orchestration, SQS queues, and the Bedrock integration layer for Phase 1 artifact types.

### Activities

The following activities build on the landing zone foundation established in Phase 1 and must be executed in dependency order.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Cognito User Pool provisioning and Okta migration | Security Engineer | 5 days | Landing zone |
| API Gateway REST API and WAF WebACL deployment | Senior Solutions Engineer | 3 days | Cognito |
| Lambda function deployment (API handlers + orchestration) | Senior Solutions Engineer | 5 days | API Gateway |
| Step Functions state machine deployment | Senior Solutions Engineer | 3 days | Lambda |
| SQS queue and DLQ deployment | Cloud/DevOps Engineer | 1 day | Lambda |
| Bedrock integration layer (Phase 1 artifact types) | ML/AI Engineer | 10 days | Step Functions |
| Secrets Manager secrets population with real values | Security Engineer | 1 day | All services |

### Detailed Procedures

#### 2.1 Cognito User Pool and Okta Migration

The Okta-to-Cognito migration uses a two-week parallel-run period to ensure zero authentication outages. Users are migrated in batches of ten to limit blast radius at each step.

```bash
cd infrastructure/auth

aws cloudformation deploy \
  --template-file cognito.yaml \
  --stack-name amatra-isb-cognito-prod \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    Environment=prod \
    AdminGroupName=AmAdmin \
    PreSalesGroupName=PreSales \
    DeliveryGroupName=Delivery \
    TokenExpiryMinutes=15

cd scripts/migration
python okta_to_cognito_migration.py \
  --okta-export-file okta_users_export.json \
  --cognito-user-pool-id "$(aws cloudformation describe-stacks \
    --stack-name amatra-isb-cognito-prod \
    --query "Stacks[0].Outputs[?OutputKey=='UserPoolId'].OutputValue" \
    --output text)" \
  --batch-size 10 \
  --dry-run false

python validate_cognito_migration.py \
  --expected-count 50 \
  --expected-groups AmAdmin,PreSales,Delivery
```

#### 2.2 API Gateway and WAF Deployment

Deploy the API Gateway REST API with a WAF WebACL attached and confirm the health endpoint returns a valid response.

```bash
cd infrastructure/api

sam deploy \
  --template-file api-gateway.yaml \
  --stack-name amatra-isb-api-prod \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    Environment=prod \
    ThrottleBurstRps=500 \
    ThrottleSteadyRps=200

API_ENDPOINT="$(aws cloudformation describe-stacks \
  --stack-name amatra-isb-api-prod \
  --query "Stacks[0].Outputs[?OutputKey=='ApiEndpoint'].OutputValue" \
  --output text)"

curl -X GET "${API_ENDPOINT}/api/v1/health"
```

#### 2.3 Step Functions State Machine and SQS Queues

Deploy the async orchestration layer including the primary SQS job queue, the dead-letter queue, and the Step Functions state machine.

```bash
cd infrastructure/orchestration

aws cloudformation deploy \
  --template-file orchestration.yaml \
  --stack-name amatra-isb-orchestration-prod \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    Environment=prod \
    JobQueueName=amatra-isb-job-queue-prod \
    DlqName=amatra-isb-job-dlq-prod \
    VisibilityTimeoutSeconds=300 \
    MessageRetentionSeconds=345600 \
    MaxReceiveCount=3

aws stepfunctions describe-state-machine \
  --state-machine-arn "$STATE_MACHINE_ARN" \
  --query '{Name: name, Status: status}'
```

### Deliverables

- [ ] Amazon Cognito User Pool operational with all 50 Okta users migrated
- [ ] All three Cognito groups (AmAdmin, PreSales, Delivery) created with correct permissions
- [ ] API Gateway REST API deployed with WAF WebACL and CRS + KBI managed rules active
- [ ] All Lambda functions deployed with provisioned concurrency on API Handler functions
- [ ] Step Functions state machine active with retry logic and DLQ configured
- [ ] SQS primary queue and DLQ active; P1 alarm on DLQ depth > 0 configured
- [ ] Bedrock integration layer functional for Phase 1 artifact types in staging

### Success Criteria

- Cognito migration: 100% of Okta users authenticated successfully via Cognito within the parallel-run window
- API Gateway `GET /api/v1/health` returns HTTP 200 from all three environments
- End-to-end brief submission in staging: POST enters pipeline and Step Functions execution starts within 500 ms p99
- DLQ depth remains 0 during all staging integration tests

## Phase 3: Integration and Testing (Month 4)

### Objectives

Execute functional, integration, performance, and security testing; conduct UAT with Head of Solutions and pre-sales consultants; and prepare for Phase 1 Production deployment on 30 September 2026.

### Activities

These activities constitute the final validation gate before Phase 1 production go-live and must complete in sequence.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Phase 1 functional test execution | QA Engineer | 5 days | Core platform |
| Integration testing (end-to-end brief-to-artifact) | QA Engineer | 3 days | Functional tests |
| Async reliability testing (24 concurrent jobs) | QA Engineer | 2 days | Integration tests |
| Security validation (IAM, WAF, GuardDuty) | Security Engineer | 3 days | Integration tests |
| Phase 1 UAT with Head of Solutions and pre-sales consultants | Head of Solutions | 10 days | All tests passing |
| Phase 1 production deployment and cutover | Cloud/DevOps Engineer | 1 day | UAT sign-off |

### Deliverables

- [ ] Phase 1 Test Results Report completed and approved by CTO
- [ ] UAT sign-off received from Head of Solutions (≥90% artifact acceptance rate)
- [ ] Zero open P1 defects; ≤3 open P2 defects with documented mitigations
- [ ] Phase 1 Production Deployment (MVP Go-Live) on 30 September 2026
- [ ] Pre-Sales Consultant Training Materials (Deliverable #12) delivered to Head of Solutions

### Success Criteria

- All Phase 1 functional test cases pass with 100% coverage of the four pre-sales artifact types
- Load test at 24 concurrent jobs: all jobs complete within 60 minutes
- Security scan: zero critical or high-severity findings
- UAT: ≥90% of submitted brief-to-artifact cycles accepted by pre-sales consultants on first review

# Infrastructure Deployment

This section provides the complete infrastructure deployment runbooks for all four platform infrastructure layers. Each subsection covers the required components, automation scripts, step-by-step deployment procedures, validation commands, success criteria, and rollback procedures. All deployments follow the GitOps model — every change is committed to `amatra/amatra-isb`, reviewed via pull request, and applied via the GitHub Actions CI/CD pipeline with a mandatory manual approval gate for production.

## Networking

The Amatra Intelligent Solution Builder is a fully serverless platform that operates within the AWS managed network fabric. No VPC, subnet, or NAT gateway is required for core Lambda and managed-service components. All networking configuration is enforced at the API Gateway, WAF, and S3 access-control layers.

### Components

The following table lists all networking components, their specifications, and their purposes in the platform.

| Component | Service | Specification | Purpose |
|-----------|---------|---------------|---------|
| API Gateway Custom Domain | API Gateway | `api.amatra-isb.internal`; TLS 1.2+ policy enforced | Single HTTPS ingress for all platform traffic |
| ACM Certificate | AWS Certificate Manager | Auto-renewing certificate; DNS validation | TLS termination at API Gateway custom domain |
| WAF WebACL | AWS WAF v2 | CRS + KBI managed rule groups; 2,000 req/5 min/IP | L7 perimeter protection, DDoS mitigation, rate limiting |
| S3 Block Public Access | S3 Account-level | All four block-public-access settings enabled | Prevents accidental public exposure of artifact buckets |
| AWS Org SCP | AWS Organizations | Blocks replication outside us-east-1/us-west-2 | US data residency enforcement per GDPR requirements |
| Route 53 DNS | Route 53 | A record alias to API Gateway endpoint; TTL 60 s pre-cutover | DNS routing for API Gateway custom domain |

### Script Location

All networking infrastructure-as-code templates are stored in the repository. The directory layout is shown below.

```text
amatra-isb/
  infrastructure/
    networking/
      api-gateway-domain.yaml       # ACM certificate + custom domain mapping
      waf-web-acl.yaml              # WAF WebACL with managed rules and rate limit
      s3-account-public-access.yaml # Account-level Block Public Access
    landing-zone/
      scp-data-residency.json       # Org SCP for us-west-2 data residency
    scripts/
      dns-cutover-prod.json         # Route 53 change batch for production cutover
      dns-rollback-prod.json        # Route 53 change batch for rollback
```

### Deployment Steps

Follow these steps in the exact order shown. The WAF WebACL must be deployed before the API Gateway custom domain because the domain stack attaches the WebACL to the API Gateway stage.

```bash
# Step 1: Enable S3 Block Public Access at account level
aws s3control put-public-access-block \
  --account-id "$AWS_ACCOUNT_ID" \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,\
BlockPublicPolicy=true,RestrictPublicBuckets=true

# Step 2: Request ACM certificate for the API custom domain
CERT_ARN="$(aws acm request-certificate \
  --domain-name "api.amatra-isb.internal" \
  --validation-method DNS \
  --query "CertificateArn" --output text)"
echo "Certificate ARN: $CERT_ARN"

# Step 3: Deploy WAF WebACL (regional — us-west-2)
aws cloudformation deploy \
  --template-file infrastructure/networking/waf-web-acl.yaml \
  --stack-name amatra-isb-waf-prod \
  --parameter-overrides \
    Environment=prod \
    RateLimitPerIpPer5Min=2000

# Step 4: Deploy API Gateway custom domain and attach WAF
aws cloudformation deploy \
  --template-file infrastructure/networking/api-gateway-domain.yaml \
  --stack-name amatra-isb-api-domain-prod \
  --parameter-overrides \
    Environment=prod \
    CertificateArn="$CERT_ARN" \
    ApiGatewayId="$API_GATEWAY_ID"

# Step 5: Update Route 53 DNS record (TTL set to 60 s for rapid rollback)
aws route53 change-resource-record-sets \
  --hosted-zone-id "$HOSTED_ZONE_ID" \
  --change-batch file://infrastructure/scripts/dns-cutover-prod.json
```

### Validation

After completing all deployment steps, run the following commands to confirm networking is correctly configured before proceeding to the security layer.

```bash
# Confirm S3 Block Public Access is fully enabled at account level
aws s3control get-public-access-block \
  --account-id "$AWS_ACCOUNT_ID" \
  --query "PublicAccessBlockConfiguration"

# Confirm ACM certificate status is ISSUED
aws acm describe-certificate \
  --certificate-arn "$CERT_ARN" \
  --query "Certificate.Status"

# Confirm WAF WebACL is attached to the API Gateway stage
aws wafv2 get-web-acl-for-resource \
  --resource-arn "$API_GATEWAY_STAGE_ARN" \
  --query "WebACL.Name"

# Confirm TLS 1.0 and 1.1 are rejected
curl --tlsv1.0 https://api.amatra-isb.internal/api/v1/health 2>&1 \
  | grep -E "SSL|TLS|handshake"

# Confirm the health endpoint returns HTTP 200 over HTTPS
curl -v https://api.amatra-isb.internal/api/v1/health
```

### Success Criteria

- S3 Block Public Access: all four settings `true` at account level across all environments
- ACM certificate: status `ISSUED` with DNS validation complete before any traffic is routed
- WAF WebACL: attached to production API Gateway stage; CRS and KBI rule groups in `ACTIVE` state
- TLS 1.0 and TLS 1.1 connection attempts are rejected by API Gateway
- API Gateway custom domain resolves to the correct endpoint and returns HTTP 200 on health check
- Rate limiting confirmed: 2,001 requests per 5-minute window from a single IP receives HTTP 429

### Rollback

In the event of a networking deployment failure, execute the following rollback procedure. The DNS record can be reverted in under 60 seconds due to the low TTL set before cutover.

```bash
# Revert DNS record to prior A record
aws route53 change-resource-record-sets \
  --hosted-zone-id "$HOSTED_ZONE_ID" \
  --change-batch file://infrastructure/scripts/dns-rollback-prod.json

# Disassociate WAF WebACL from API Gateway stage if the WebACL is causing errors
aws wafv2 disassociate-web-acl \
  --resource-arn "$API_GATEWAY_STAGE_ARN"

# Roll back CloudFormation stacks for networking components
aws cloudformation delete-stack --stack-name amatra-isb-api-domain-prod
aws cloudformation delete-stack --stack-name amatra-isb-waf-prod

# Verify API Gateway is reachable via the execute-api fallback URL
curl -v "https://${API_GATEWAY_ID}.execute-api.us-west-2.amazonaws.com/prod/api/v1/health"
```

## Security

The security infrastructure layer deploys all preventative and detective controls required for SOC 2 Type II compliance and GDPR-aligned data handling. This section covers IAM roles, KMS encryption, Cognito identity configuration, GuardDuty, Security Hub, and CloudTrail.

### Components

The following table lists all security components, their specifications, and their purpose in satisfying SOC 2 Trust Service Criteria.

| Component | Service | Specification | Purpose |
|-----------|---------|---------------|---------|
| KMS CMKs (4) | AWS KMS | Customer Managed Keys; annual auto-rotation | At-rest encryption for S3, DynamoDB, CloudTrail, Secrets Manager |
| Lambda IAM Execution Roles | IAM | Least-privilege per function; permission boundaries | Service-to-service auth; prevents privilege escalation |
| GitHub Actions OIDC Role | IAM | OIDC trust policy; scoped to `amatra/amatra-isb` | CI/CD deployment without static AWS credentials |
| Cognito User Pool | Amazon Cognito | MFA (TOTP) for AmAdmin; 15-min JWT expiry | User authentication; JWT issuance; group-based RBAC |
| GuardDuty | AWS GuardDuty | All threat detectors enabled; auto-remediation Lambda | Threat detection; credential-stuffing detection |
| Security Hub | AWS Security Hub | GuardDuty + Config + Inspector aggregation | SOC 2 CC7 compliance monitoring; weekly review |
| CloudTrail | AWS CloudTrail | Management events + S3 data events; Object Lock 7 yr | Immutable audit trail; SOC 2 evidence |
| AWS Config | AWS Config | SOC 2 managed rule set; non-compliance alerts | Continuous resource configuration compliance monitoring |
| Secrets Manager | AWS Secrets Manager | 10 secrets; KMS-encrypted; rotation enabled | Credential management; zero plaintext secrets in code |

### Script Location

All security infrastructure templates and scripts are located in the repository. The directory layout is shown below.

```text
amatra-isb/
  infrastructure/
    security/
      kms-keys.yaml               # All 4 KMS CMKs with key policies
      iam-lambda-roles.yaml       # Lambda execution roles + permission boundaries
      iam-cicd-role.yaml          # GitHub Actions OIDC IAM role
      cognito.yaml                # Cognito User Pool, groups, app client
      guardduty.yaml              # GuardDuty detector and auto-remediation Lambda
      securityhub.yaml            # Security Hub enablement and standards
      cloudtrail.yaml             # CloudTrail trail with WORM S3 bucket
      config.yaml                 # AWS Config recorder and SOC 2 rule set
    scripts/
      okta_to_cognito_migration.py
      validate_cognito_migration.py
      rotate_secrets.py
```

### Deployment Steps

Deploy the security layer in this exact order. KMS CMKs must exist before any other resource is created, and the CloudTrail Object Lock S3 bucket must be created before CloudTrail is enabled.

```bash
# Step 1: Deploy KMS CMKs — all other services depend on these
aws cloudformation deploy \
  --template-file infrastructure/security/kms-keys.yaml \
  --stack-name amatra-isb-kms-prod \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides Environment=prod

# Step 2: Deploy IAM Lambda execution roles and permission boundaries
aws cloudformation deploy \
  --template-file infrastructure/security/iam-lambda-roles.yaml \
  --stack-name amatra-isb-iam-roles-prod \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides Environment=prod

# Step 3: Deploy CloudTrail with Object Lock S3 bucket
# Object Lock must be enabled at bucket creation — it cannot be added retroactively
aws cloudformation deploy \
  --template-file infrastructure/security/cloudtrail.yaml \
  --stack-name amatra-isb-cloudtrail-prod \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    Environment=prod \
    RetentionYears=7 \
    KmsKeyAlias=alias/amatra-isb-cloudtrail-prod

# Step 4: Deploy Cognito User Pool with groups and app client
aws cloudformation deploy \
  --template-file infrastructure/security/cognito.yaml \
  --stack-name amatra-isb-cognito-prod \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    Environment=prod \
    TokenExpiryMinutes=15 \
    SessionTimeoutMinutes=30

# Step 5: Enable GuardDuty with auto-remediation Lambda
aws cloudformation deploy \
  --template-file infrastructure/security/guardduty.yaml \
  --stack-name amatra-isb-guardduty-prod \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides Environment=prod

# Step 6: Enable Security Hub with AWS Foundational Security Best Practices
aws cloudformation deploy \
  --template-file infrastructure/security/securityhub.yaml \
  --stack-name amatra-isb-securityhub-prod \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides Environment=prod

# Step 7: Deploy AWS Config with SOC 2 managed rule set
aws cloudformation deploy \
  --template-file infrastructure/security/config.yaml \
  --stack-name amatra-isb-config-prod \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides Environment=prod
```

### Validation

The following commands confirm all security controls are operational after deployment. Run each command and verify the expected result before proceeding to the compute layer.

```bash
# Verify all 4 KMS CMKs have auto-rotation enabled
for ALIAS in alias/amatra-isb-s3-artifacts-prod \
             alias/amatra-isb-dynamodb-prod \
             alias/amatra-isb-cloudtrail-prod \
             alias/amatra-isb-secrets-manager-prod; do
  KEY_ID="$(aws kms describe-key --key-id "$ALIAS" \
    --query 'KeyMetadata.KeyId' --output text)"
  aws kms get-key-rotation-status --key-id "$KEY_ID" \
    --query "{Alias: \"$ALIAS\", RotationEnabled: KeyRotationEnabled}"
done

# Verify CloudTrail is logging with log file integrity validation on
aws cloudtrail get-trail-status \
  --name amatra-isb-cloudtrail-prod \
  --query '{IsLogging: IsLogging, LogFileValidation: LogFileValidationEnabled}'

# Verify S3 Object Lock is enabled on the CloudTrail bucket
aws s3api get-object-lock-configuration \
  --bucket amatra-isb-cloudtrail-logs-prod \
  --query "ObjectLockConfiguration"

# Verify GuardDuty detector is ENABLED
aws guardduty list-detectors --query "DetectorIds" --output text | \
  xargs -I {} aws guardduty get-detector --detector-id {} --query "Status"

# Verify Security Hub is enabled
aws securityhub describe-hub --query "HubArn"

# IAM Access Analyzer — confirm zero active findings on Lambda roles
aws accessanalyzer list-findings \
  --analyzer-arn "$ANALYZER_ARN" \
  --filter '{"status": {"eq": ["ACTIVE"]}}' \
  --query "length(findings)"
```

### Success Criteria

- All 4 KMS CMKs: `KeyRotationEnabled: true` with key policies restricting usage to named IAM roles only
- CloudTrail: `IsLogging: true`; `LogFileValidationEnabled: true`; S3 bucket Object Lock in Compliance mode with 7-year retention
- GuardDuty: detector `ENABLED`; simulated threat event produces HIGH finding within 5 minutes
- Security Hub: enabled with AWS Foundational Security Best Practices standard; zero CRITICAL findings at baseline
- IAM Access Analyzer: zero active findings on all Lambda execution roles
- Cognito: all 50 migrated users authenticate successfully; AmAdmin users prompted for TOTP MFA on login

### Rollback

Security layer rollback is conservative — remove only the failing component while preserving the audit log. The CloudTrail Object Lock bucket cannot be deleted once Object Lock is set.

```bash
# Rollback GuardDuty if the detector configuration is causing issues
aws guardduty delete-detector --detector-id "$DETECTOR_ID"

# Rollback Security Hub if misconfigured
aws securityhub disable-security-hub

# Rollback Cognito User Pool only if the migration has NOT yet run
aws cloudformation delete-stack --stack-name amatra-isb-cognito-prod

# Identify the root cause for any KMS or CloudTrail stack failures
aws cloudformation describe-stack-events \
  --stack-name amatra-isb-kms-prod \
  --query "StackEvents[?ResourceStatus=='CREATE_FAILED'].{Resource:LogicalResourceId,Reason:ResourceStatusReason}"

# Re-run the specific failing stack after the issue is resolved
aws cloudformation deploy \
  --template-file infrastructure/security/kms-keys.yaml \
  --stack-name amatra-isb-kms-prod \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides Environment=prod
```

## Compute

The compute layer deploys all Lambda functions, the Step Functions state machine, SQS queues, and the Amazon Bedrock integration layer. This is the largest deployment phase and implements all seven artifact generation pipeline components, the async orchestration backbone, and the DynamoDB state and usage stores.

### Components

The following table lists all compute components with their specifications and roles in the generation pipeline.

| Component | Service | Specification | Purpose |
|-----------|---------|---------------|---------|
| `isb-api-submit` | Lambda Python 3.12 | 512 MB; 30 s; 5 provisioned concurrency (prod) | Accept brief submissions; enforce usage limits; enqueue to SQS |
| `isb-api-status` | Lambda Python 3.12 | 256 MB; 10 s; 5 provisioned concurrency (prod) | Poll async job status from DynamoDB SolutionState |
| `isb-api-retrieve` | Lambda Python 3.12 | 256 MB; 10 s; 3 provisioned concurrency (prod) | Generate presigned S3 URL for artifact download |
| `isb-api-admin` | Lambda Python 3.12 | 256 MB; 30 s; 2 provisioned concurrency (prod) | Admin controls: usage overrides, user management |
| `isb-orchestrator-start` | Lambda Python 3.12 | 512 MB; 60 s; on-demand | Start Step Functions execution from SQS message |
| `isb-prompt-assembly` (x7) | Lambda Python 3.12 | 512 MB; 120 s; on-demand | Assemble Bedrock prompt per artifact type |
| `isb-bedrock-sonnet` | Lambda Python 3.12 | 1024 MB; 900 s; on-demand | Invoke Claude 3 Sonnet for complex artifact types |
| `isb-bedrock-haiku` | Lambda Python 3.12 | 512 MB; 600 s; on-demand | Invoke Claude 3 Haiku for lightweight artifact types |
| `isb-artifact-processor` | Lambda Python 3.12 | 512 MB; 300 s; on-demand | QA validation, format enforcement, S3 write |
| Step Functions State Machine | AWS Step Functions | Standard Workflow; up to 2,000 concurrent executions | Orchestrate durable 30–60 min generation pipeline |
| SQS Job Queue | Amazon SQS | Standard; 300 s visibility timeout; 4-day retention | Decouple API layer from Bedrock invocations |
| SQS Dead Letter Queue | Amazon SQS | maxReceiveCount=3; P1 alarm on depth > 0 | Capture failed job messages for triage and replay |
| DynamoDB SolutionState | Amazon DynamoDB | On-demand; PITR enabled; 365-day TTL on COMPLETE records | Job status tracking and artifact S3 key storage |
| DynamoDB UsageTracking | Amazon DynamoDB | On-demand; PITR enabled; 365-day TTL | Per-user and global monthly generation counters |

### Script Location

All compute infrastructure templates and Lambda source code are located in the repository. The directory layout is shown below.

```text
amatra-isb/
  infrastructure/
    compute/
      dynamodb-tables.yaml         # SolutionState + UsageTracking tables with GSIs
      sqs-queues.yaml              # Job queue + DLQ with alarm wiring
      stepfunctions.yaml           # Step Functions state machine definition
  src/
    api/
      submit_brief.py              # isb-api-submit Lambda handler
      poll_status.py               # isb-api-status Lambda handler
      retrieve_artifact.py         # isb-api-retrieve Lambda handler
      admin_controls.py            # isb-api-admin Lambda handler
    orchestration/
      start_execution.py           # isb-orchestrator-start handler
    generation/
      prompt_assembly.py           # isb-prompt-assembly handler
      bedrock_sonnet.py            # isb-bedrock-sonnet handler
      bedrock_haiku.py             # isb-bedrock-haiku handler
      artifact_processor.py        # isb-artifact-processor handler
    templates/
      prompts/                     # Versioned Bedrock prompt templates per artifact type
  template.yaml                    # Root SAM template for all Lambda functions
```

### Deployment Steps

The compute layer must be deployed in a defined sequence: DynamoDB tables first, then SQS queues, then Lambda functions via SAM, and finally the Step Functions state machine which references Lambda ARNs.

```bash
# Step 1: Deploy DynamoDB tables
aws cloudformation deploy \
  --template-file infrastructure/compute/dynamodb-tables.yaml \
  --stack-name amatra-isb-dynamodb-prod \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    Environment=prod \
    SolutionStateTableName=AmatraISB-SolutionState-Prod \
    UsageTrackingTableName=AmatraISB-UsageTracking-Prod \
    BillingMode=PAY_PER_REQUEST \
    PitrEnabled=true \
    TtlSolutionStateDays=365 \
    TtlUsageTrackingDays=365

# Step 2: Deploy SQS queues (primary + DLQ)
aws cloudformation deploy \
  --template-file infrastructure/compute/sqs-queues.yaml \
  --stack-name amatra-isb-sqs-prod \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    Environment=prod \
    JobQueueName=amatra-isb-job-queue-prod \
    DlqName=amatra-isb-job-dlq-prod \
    VisibilityTimeoutSeconds=300 \
    MessageRetentionSeconds=345600 \
    MaxReceiveCount=3

# Step 3: Build and deploy all Lambda functions via SAM
sam build --use-container

sam deploy \
  --stack-name amatra-isb-compute-prod \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides file://infrastructure/compute/prod.json \
  --no-fail-on-empty-changeset

# Step 4: Set provisioned concurrency on API Handler functions
for FUNC_CONFIG in "isb-api-submit-prod:5" "isb-api-status-prod:5" \
                   "isb-api-retrieve-prod:3" "isb-api-admin-prod:2"; do
  FUNC_NAME="${FUNC_CONFIG%%:*}"
  PC_VALUE="${FUNC_CONFIG##*:}"
  FUNC_VERSION="$(aws lambda publish-version \
    --function-name "$FUNC_NAME" \
    --query "Version" --output text)"
  aws lambda put-provisioned-concurrency-config \
    --function-name "$FUNC_NAME" \
    --qualifier "$FUNC_VERSION" \
    --provisioned-concurrent-executions "$PC_VALUE"
  echo "Provisioned concurrency $PC_VALUE set for $FUNC_NAME version $FUNC_VERSION"
done

# Step 5: Deploy Step Functions state machine
aws cloudformation deploy \
  --template-file infrastructure/compute/stepfunctions.yaml \
  --stack-name amatra-isb-stepfunctions-prod \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    Environment=prod \
    BedrockSonnetModelId=anthropic.claude-3-sonnet-20240229-v1:0 \
    BedrockHaikuModelId=anthropic.claude-3-haiku-20240307-v1:0 \
    MaxRetryAttempts=3 \
    RetryIntervalSeconds=30
```

### Validation

Run the following smoke tests to confirm the compute layer is fully functional before proceeding to integration testing.

```bash
# Confirm all Lambda functions are Active and on Python 3.12
aws lambda list-functions \
  --query "Functions[?starts_with(FunctionName,'isb-')].{Name:FunctionName,State:State,Runtime:Runtime}" \
  --output table

# Confirm both DynamoDB tables are ACTIVE with PITR enabled
for TABLE in "AmatraISB-SolutionState-Prod" "AmatraISB-UsageTracking-Prod"; do
  aws dynamodb describe-table --table-name "$TABLE" \
    --query "{Table:Table.TableName,Status:Table.TableStatus,BillingMode:Table.BillingModeSummary.BillingMode}"
  aws dynamodb describe-continuous-backups --table-name "$TABLE" \
    --query "ContinuousBackupsDescription.PointInTimeRecoveryDescription.PointInTimeRecoveryStatus"
done

# Submit a test brief and confirm the async pipeline starts
TEST_JWT="$(python scripts/get_test_jwt.py --user test-presales@amatra.com --env prod)"
RESPONSE="$(curl -s -X POST \
  https://api.amatra-isb.internal/api/v1/solutions \
  -H "Authorization: Bearer $TEST_JWT" \
  -H "Content-Type: application/json" \
  -d @tests/fixtures/sample-brief.json)"
echo "$RESPONSE"

# Confirm a Step Functions execution was started
aws stepfunctions list-executions \
  --state-machine-arn "$STATE_MACHINE_ARN" \
  --status-filter RUNNING \
  --query "executions[0].{Name:name,Status:status,StartDate:startDate}"
```

### Success Criteria

- All Lambda functions: State `Active`; Runtime `python3.12`
- All four API Handler functions: provisioned concurrency status `READY` in production
- Both DynamoDB tables: status `ACTIVE`; PITR `ENABLED`; billing mode `PAY_PER_REQUEST`
- SQS job queue and DLQ visible in us-west-2 console with DLQ association confirmed
- Step Functions state machine: status `ACTIVE`; test execution starts within 5 seconds of SQS message delivery
- End-to-end smoke test: brief submission returns HTTP 202 within 500 ms p99; artifact file present in S3 upon completion

### Rollback

The compute layer uses Lambda alias-based blue-green rollback. This is the fastest and lowest-risk rollback mechanism, with a target completion time of 30 minutes or less from rollback decision.

```bash
# Rollback Lambda functions to prior verified version via GitHub Actions
gh workflow run rollback.yml \
  --ref main \
  --field environment=prod \
  --field target_version="$PREVIOUS_VERSION"

gh run watch --exit-status

# Verify the PROD alias now points to the prior version
for FUNC in isb-api-submit-prod isb-api-status-prod \
            isb-api-retrieve-prod isb-api-admin-prod; do
  aws lambda get-alias \
    --function-name "$FUNC" \
    --name PROD \
    --query "{FunctionVersion:FunctionVersion,AliasArn:AliasArn}"
done

# Rollback Step Functions state machine if a state definition change is involved
aws cloudformation rollback-stack \
  --stack-name amatra-isb-stepfunctions-prod

# If a DynamoDB schema change caused data corruption (rare — changes are additive),
# initiate a PITR restore to a timestamp before the deployment
aws dynamodb restore-table-to-point-in-time \
  --source-table-name AmatraISB-SolutionState-Prod \
  --target-table-name AmatraISB-SolutionState-Prod-Restored \
  --restore-date-time "$PRE_DEPLOYMENT_TIMESTAMP"
```

## Monitoring

The monitoring layer deploys the three CloudWatch dashboards, all production alarms, the CloudWatch Synthetics canary for availability measurement, and the SNS alerting topic with PagerDuty (P1), Slack (P2), and email (P3) subscriptions. This layer must be deployed after the compute layer because alarm definitions reference Lambda function names and Step Functions ARNs.

### Components

The following table lists all monitoring and observability components, their configurations, and their operational purposes.

| Component | Service | Specification | Purpose |
|-----------|---------|---------------|---------|
| Operations Dashboard | CloudWatch Dashboard | `amatra-isb-operations-prod`; 5-min refresh | Job queue depth, Lambda error rates, DLQ depth, API latency |
| SLA & Availability Dashboard | CloudWatch Dashboard | `amatra-isb-sla-prod`; hourly aggregation | Monthly availability vs. 99.9% target; job completion rate |
| Quality & Usage Dashboard | CloudWatch Dashboard | `amatra-isb-quality-prod`; daily aggregation | QA first-pass rate; Bedrock token consumption; per-user usage |
| Synthetics Canary | CloudWatch Synthetics | 60 s interval; `GET /api/v1/health` | Primary SLA availability measurement signal |
| P1 Alarm: Platform Availability | CloudWatch Alarm | Health check success rate < 99.9% over 5 min | PagerDuty page; escalate to VP Engineering if unresolved in 30 min |
| P1 Alarm: Async Job Failure | CloudWatch Alarm | Step Functions failure rate > 5% over 5 min | PagerDuty page; DLQ investigation; Bedrock throttle check |
| P1 Alarm: DLQ Depth | CloudWatch Alarm | SQS DLQ depth > 0 messages | PagerDuty + SNS; investigate failed job immediately |
| P2 Alarm: API 5xx Rate | CloudWatch Alarm | API Gateway 5xx rate > 1% over 15 min | Slack `#amatra-isb-ops`; VP Engineering investigation |
| P2 Alarm: Lambda Error Rate | CloudWatch Alarm | Any Lambda error rate > 2% over 10 min | Slack alert; investigate via CloudWatch Log Insights |
| P2 Alarm: Cognito Auth Failure | CloudWatch Alarm | Auth failure rate > 10% over 5 min | Slack; GuardDuty check; auto-suspend Lambda triggered |
| P3 Alarm: Bedrock Budget Warning | CloudWatch Alarm | Token consumption > 80% of monthly budget | Email to Head of Solutions; Haiku substitution review |
| SNS Alerts Topic | Amazon SNS | `amatra-isb-alerts-prod` | Central routing for all P1/P2/P3 severity levels |
| Datadog APM Layer | Datadog Lambda Extension | API key from Secrets Manager `amatra/prod/datadog/api-key` | Cold-start profiling; Bedrock invocation latency histograms |

### Script Location

All monitoring infrastructure-as-code templates and dashboard JSON definitions are located in the repository. The directory layout is shown below.

```text
amatra-isb/
  infrastructure/
    monitoring/
      cloudwatch-dashboards.yaml   # All 3 CloudWatch dashboard definitions
      cloudwatch-alarms.yaml       # All production alarms (P1, P2, P3)
      synthetics-canary.yaml       # CloudWatch Synthetics canary configuration
      sns-topic.yaml               # SNS topic + subscriptions
  monitoring/
    dashboards/
      operations-dashboard.json    # Operations dashboard JSON (handover deliverable)
      sla-dashboard.json           # SLA dashboard JSON (handover deliverable)
      quality-dashboard.json       # Quality dashboard JSON (handover deliverable)
```

### Deployment Steps

Deploy the monitoring layer in the sequence shown. The SNS topic must exist before CloudWatch alarms are created, because each alarm references the SNS topic ARN for its alert action.

```bash
# Step 1: Deploy SNS alerts topic with PagerDuty, Slack, and email subscriptions
aws cloudformation deploy \
  --template-file infrastructure/monitoring/sns-topic.yaml \
  --stack-name amatra-isb-sns-prod \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    Environment=prod \
    PagerDutyEndpoint="$PAGERDUTY_HTTPS_ENDPOINT" \
    SlackWebhookUrl="$SLACK_WEBHOOK_URL" \
    HeadOfSolutionsEmail=solutions-lead@amatra.com

# Step 2: Deploy all three CloudWatch dashboards
aws cloudformation deploy \
  --template-file infrastructure/monitoring/cloudwatch-dashboards.yaml \
  --stack-name amatra-isb-dashboards-prod \
  --parameter-overrides \
    Environment=prod \
    OperationsDashboardName=amatra-isb-operations-prod \
    SlaDashboardName=amatra-isb-sla-prod \
    QualityDashboardName=amatra-isb-quality-prod

# Step 3: Deploy all CloudWatch alarms (P1, P2, P3)
SNS_TOPIC_ARN="$(aws sns list-topics \
  --query "Topics[?contains(TopicArn,'amatra-isb-alerts-prod')].TopicArn" \
  --output text)"

aws cloudformation deploy \
  --template-file infrastructure/monitoring/cloudwatch-alarms.yaml \
  --stack-name amatra-isb-alarms-prod \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    Environment=prod \
    SnsTopicArn="$SNS_TOPIC_ARN" \
    JobFailureRateThresholdPct=5 \
    Api5xxThresholdPct=1 \
    BedrockBudgetWarningPct=80 \
    DlqDepthThreshold=1 \
    CognitoAuthFailurePct=10

# Step 4: Deploy CloudWatch Synthetics canary for availability measurement
aws cloudformation deploy \
  --template-file infrastructure/monitoring/synthetics-canary.yaml \
  --stack-name amatra-isb-canary-prod \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    Environment=prod \
    ApiEndpoint=https://api.amatra-isb.internal \
    HealthCheckIntervalSeconds=60

# Step 5: Attach Datadog APM extension layer to all platform Lambda functions
# Retrieve the current Datadog Python 3.12 layer ARN from the Datadog documentation
# at https://docs.datadoghq.com/serverless/installation/python/ before running this step
DATADOG_LAYER_ARN="arn:aws:lambda:us-west-2:464622532012:layer:Datadog-Python312:97"
for FUNC_NAME in $(aws lambda list-functions \
  --query "Functions[?starts_with(FunctionName,'isb-')].FunctionName" \
  --output text); do
  aws lambda update-function-configuration \
    --function-name "$FUNC_NAME" \
    --layers "$DATADOG_LAYER_ARN" \
    --environment "Variables={DD_API_KEY_SECRET_ARN=arn:aws:secretsmanager:us-west-2:${AWS_ACCOUNT_ID}:secret:amatra/prod/datadog/api-key}"
done
```

### Validation

Run the following commands to confirm all monitoring components are operational before declaring the monitoring layer deployment complete.

```bash
# Confirm all 3 CloudWatch dashboards are deployed and named correctly
aws cloudwatch list-dashboards \
  --dashboard-name-prefix amatra-isb \
  --query "DashboardEntries[].DashboardName" \
  --output table

# Confirm all alarms are in OK state at baseline (no false positives)
aws cloudwatch describe-alarms \
  --alarm-name-prefix amatra-isb \
  --query "MetricAlarms[].{Name:AlarmName,State:StateValue}" \
  --output table

# Confirm the Synthetics canary is in RUNNING state
aws synthetics describe-canaries \
  --query "Canaries[?Name=='amatra-isb-health-canary'].{Name:Name,Status:Status.State}" \
  --output table

# Trigger a test P1 alarm to validate PagerDuty routing, then reset it
aws cloudwatch set-alarm-state \
  --alarm-name amatra-isb-dlq-depth-alarm-prod \
  --state-value ALARM \
  --state-reason "Test alarm to validate PagerDuty routing"

aws cloudwatch set-alarm-state \
  --alarm-name amatra-isb-dlq-depth-alarm-prod \
  --state-value OK \
  --state-reason "Test complete — resetting to OK"
```

### Success Criteria

- All three CloudWatch dashboards deployed and displaying live metrics from the compute layer
- All 9 production alarms in `OK` state at baseline with no false positives
- CloudWatch Synthetics canary: status `RUNNING`; first health check `PASSED` within 60 seconds of deployment
- P1 test alarm: PagerDuty incident created within 2 minutes of alarm state transition to ALARM
- P2 test alarm: Slack `#amatra-isb-ops` message delivered within 2 minutes
- P3 test alarm: email received at Head of Solutions email address within 5 minutes
- Datadog APM: Lambda distributed traces visible for all platform functions within 5 minutes of first invocation

### Rollback

Monitoring rollback is low-risk and does not affect platform functionality. Alarms can be disabled independently without impacting the compute or networking layers.

```bash
# Disable all alarm actions to prevent false-positive pages during a rollback event
aws cloudwatch disable-alarm-actions \
  --alarm-names $(aws cloudwatch describe-alarms \
    --alarm-name-prefix amatra-isb \
    --query "MetricAlarms[].AlarmName" \
    --output text)

# Stop the Synthetics canary if it is generating excessive noise
aws synthetics stop-canary --name amatra-isb-health-canary

# Roll back specific monitoring stacks if needed
aws cloudformation delete-stack --stack-name amatra-isb-alarms-prod
aws cloudformation delete-stack --stack-name amatra-isb-dashboards-prod
aws cloudformation delete-stack --stack-name amatra-isb-canary-prod

# Re-deploy monitoring layer after the issue is resolved
aws cloudformation deploy \
  --template-file infrastructure/monitoring/cloudwatch-alarms.yaml \
  --stack-name amatra-isb-alarms-prod \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides Environment=prod SnsTopicArn="$SNS_TOPIC_ARN"

# Re-enable alarm actions once the monitoring layer is confirmed stable
aws cloudwatch enable-alarm-actions \
  --alarm-names $(aws cloudwatch describe-alarms \
    --alarm-name-prefix amatra-isb \
    --query "MetricAlarms[].AlarmName" \
    --output text)
```

# Application Configuration

## Core Application Settings

Once the infrastructure deployment is complete, the application layer requires environment-specific configuration. All parameters are sourced from `configuration.csv` and injected into Lambda functions via AWS Systems Manager Parameter Store and Secrets Manager. No configuration values are hardcoded in Lambda source code.

The following YAML illustrates the application settings structure for the production environment. All values must be populated and validated before the Phase 1 cutover window opens.

```yaml
# config/application-prod.yml
application:
  name: amatra-isb
  version: 1.0.0
  environment: prod
  api_version: v1
  presigned_url_ttl_seconds: 86400
  max_brief_size_kb: 512
  artifact_types:
    - discovery-questionnaire
    - solution-briefing
    - statement-of-work
    - infrastructure-costs
    - detailed-design
    - implementation-guide
    - terraform

logging:
  level: info
  format: json
  retention_days: 90

database:
  solution_state_table: AmatraISB-SolutionState-Prod
  usage_tracking_table: AmatraISB-UsageTracking-Prod
  billing_mode: PAY_PER_REQUEST
  pitr_enabled: true
  ttl_solution_state_days: 365
  ttl_usage_tracking_days: 365

bedrock:
  sonnet_model_id: anthropic.claude-3-sonnet-20240229-v1:0
  haiku_model_id: anthropic.claude-3-haiku-20240307-v1:0
  max_input_tokens_monthly: 10000000
  max_output_tokens_monthly: 5000000
  retry_max_attempts: 3
  retry_interval_seconds: 30

usage_limits:
  per_user_monthly_default: 10
  global_monthly_default: 240
```

## Environment Variable Reference

Lambda functions consume the following environment variables, which are injected by the SAM template from Systems Manager Parameter Store at deployment time. All sensitive credentials are retrieved from Secrets Manager at Lambda initialisation and are never stored in environment variables.

| Variable | Description | Example Value | Required |
|----------|-------------|---------------|----------|
| `APP_ENVIRONMENT` | Deployment environment identifier | `prod` | Yes |
| `SOLUTION_STATE_TABLE` | DynamoDB SolutionState table name | `AmatraISB-SolutionState-Prod` | Yes |
| `USAGE_TRACKING_TABLE` | DynamoDB UsageTracking table name | `AmatraISB-UsageTracking-Prod` | Yes |
| `ARTIFACTS_BUCKET_NAME` | S3 artifacts bucket name | `amatra-isb-artifacts-prod-123456789012` | Yes |
| `TEMPLATES_BUCKET_NAME` | S3 templates bucket name | `amatra-isb-templates-prod` | Yes |
| `JOB_QUEUE_URL` | SQS job queue URL | `https://sqs.us-west-2.amazonaws.com/...` | Yes |
| `STATE_MACHINE_ARN` | Step Functions state machine ARN | `arn:aws:states:us-west-2:...` | Yes |
| `COGNITO_USER_POOL_ID` | Cognito User Pool ID | `us-west-2_AbCdEfGhI` | Yes |
| `BEDROCK_SONNET_MODEL_ID` | Bedrock Claude 3 Sonnet model ID | `anthropic.claude-3-sonnet-20240229-v1:0` | Yes |
| `BEDROCK_HAIKU_MODEL_ID` | Bedrock Claude 3 Haiku model ID | `anthropic.claude-3-haiku-20240307-v1:0` | Yes |
| `SECRETS_PREFIX` | Secrets Manager path prefix | `amatra/prod` | Yes |
| `LOG_LEVEL` | Lambda logging verbosity | `info` | Yes |

## IAM Role Configuration

Each Lambda function has a dedicated IAM execution role following the least-privilege principle. The following policy document illustrates the `isb-api-submit-prod` role, which is scoped to exactly the DynamoDB tables, SQS queue, KMS key, and Secrets Manager prefix it requires and nothing else.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DynamoDBUsageCheck",
      "Effect": "Allow",
      "Action": ["dynamodb:GetItem", "dynamodb:UpdateItem"],
      "Resource": "arn:aws:dynamodb:us-west-2:ACCOUNT_ID:table/AmatraISB-UsageTracking-Prod"
    },
    {
      "Sid": "DynamoDBSolutionWrite",
      "Effect": "Allow",
      "Action": ["dynamodb:PutItem"],
      "Resource": "arn:aws:dynamodb:us-west-2:ACCOUNT_ID:table/AmatraISB-SolutionState-Prod"
    },
    {
      "Sid": "SQSSendMessage",
      "Effect": "Allow",
      "Action": ["sqs:SendMessage"],
      "Resource": "arn:aws:sqs:us-west-2:ACCOUNT_ID:amatra-isb-job-queue-prod"
    },
    {
      "Sid": "KMSDecrypt",
      "Effect": "Allow",
      "Action": ["kms:Decrypt", "kms:GenerateDataKey"],
      "Resource": "arn:aws:kms:us-west-2:ACCOUNT_ID:key/DYNAMODB_KEY_ID"
    },
    {
      "Sid": "SecretsManagerRead",
      "Effect": "Allow",
      "Action": ["secretsmanager:GetSecretValue"],
      "Resource": "arn:aws:secretsmanager:us-west-2:ACCOUNT_ID:secret:amatra/prod/*"
    }
  ]
}
```

## Bedrock Prompt Template Configuration

Prompt templates for all seven artifact types are stored as versioned S3 objects under `templates/prompts/{artifact-type}/`. The following procedure uploads the templates and validates Bedrock connectivity before any generation job is submitted.

```bash
aws s3 sync src/templates/prompts/ \
  s3://amatra-isb-templates-prod/prompts/ \
  --sse aws:kms \
  --sse-kms-key-id alias/amatra-isb-s3-artifacts-prod

aws s3 ls s3://amatra-isb-templates-prod/prompts/ --recursive \
  | awk '{print $4}' | sort

python scripts/test_bedrock_connectivity.py \
  --model-id anthropic.claude-3-sonnet-20240229-v1:0 \
  --region us-west-2 \
  --test-prompt "Generate a 50-word summary of a serverless AWS platform."
```

## Security Controls Validation

After the application layer is configured, run the security validation script to confirm all controls are correctly wired to application resources before the production cutover.

```bash
python scripts/security_validation.py --environment prod
```

The script checks the following automatically: Lambda functions use dedicated IAM roles with no wildcard resource policies; all S3 PutObject calls include the SSE-KMS header; DynamoDB tables are encrypted with the correct CMK; all Secrets Manager secrets are accessible from Lambda execution roles; and the WAF WebACL is attached with CRS and KBI rules active.

# Integration Testing

## Test Strategy

Integration testing validates end-to-end data flows across all platform layers — from brief submission through async orchestration to artifact delivery. All tests are executed in the Staging environment using synthetic client briefs with no real PII. All integration tests must pass before any production deployment gate is opened.

The following test categories are executed in sequence, with each category gating the next.

| Test Category | Tool | Environment | Pass Criteria |
|---------------|------|-------------|---------------|
| API endpoint functional tests | pytest + requests | Staging | 100% of test cases pass |
| Async pipeline end-to-end | pytest + polling | Staging | All 7 artifact types generated within 60 min |
| Step Functions state machine | Step Functions Local + pytest | Dev | All states reachable; retry logic confirmed |
| Bedrock integration quality | Manual QA rubric | Staging | ≥90% of test briefs produce acceptable output |
| Identity and authentication | pytest + Cognito test users | Staging | All 3 groups: correct access enforced |
| Usage limit enforcement | pytest | Staging | Per-user limit enforced; admin override functional |
| Performance / load test | Locust | Staging | 24 concurrent jobs; all complete within 60 min |
| DR validation | AWS CLI | Staging | PITR restore and Lambda rollback complete within SLA |

## End-to-End Pipeline Test

The following procedure executes the full integration test suite covering the complete brief-to-artifact pipeline for all Phase 1 artifact types.

```bash
cd tests/integration

pytest test_e2e_pipeline.py \
  --environment staging \
  --artifact-types discovery-questionnaire,solution-briefing,statement-of-work,infrastructure-costs \
  --concurrent-jobs 5 \
  --timeout 3600 \
  --verbose \
  --html=reports/integration-test-phase1.html
```

## Performance Load Test

Validate platform throughput at 2x expected peak concurrency using Locust before the production go-live cutover. Key metrics to capture include API Gateway p99 response time (target 500 ms or less), Step Functions execution completion for all 24 concurrent jobs within 60 minutes, and zero Lambda or DynamoDB throttle events throughout the run.

```bash
cd tests/performance

locust \
  --locustfile locustfile_brief_submission.py \
  --host https://staging-api.amatra-isb.internal \
  --users 24 \
  --spawn-rate 2 \
  --run-time 120m \
  --headless \
  --html=reports/load-test-phase1.html
```

## Integration Test Sign-Off Checklist

All items in this checklist must be confirmed before the production deployment gate is opened.

- [ ] All API endpoint functional tests pass with 100% coverage of Phase 1 artifact types
- [ ] All 7 artifact types generate successfully in staging within 60 minutes
- [ ] 24 concurrent jobs load test: zero DLQ messages; zero Lambda throttle events
- [ ] API Gateway p99 response time 500 ms or less for job submission endpoint
- [ ] Cognito authentication: all 50 migrated users authenticate successfully with correct group assignments
- [ ] Usage limit enforcement: per-user and global counters correctly enforced and decremented
- [ ] DynamoDB PITR restore test: restore to prior timestamp completes in 30 minutes or less
- [ ] Lambda alias rollback test: rollback via GitHub Actions completes in 5 minutes or less

# Security Validation

## Security Validation Scope

Security validation is conducted by the vendor Security Engineer in coordination with the Amatra Security & Compliance Lead before each production deployment gate. The validation covers IAM policy analysis, encryption controls, WAF effectiveness, GuardDuty threat detection, Cognito authentication posture, and SOC 2 evidence collection confirmation.

## Phase 1 Security Quality Gate

Complete all items in this checklist before the Phase 1 MVP production deployment on 30 September 2026.

- [ ] IAM Access Analyzer reports zero active findings on all Lambda execution roles
- [ ] Automated policy scanner confirms no `"Resource": "*"` statements in any production Lambda role
- [ ] All S3 buckets, DynamoDB tables, Secrets Manager secrets, and CloudTrail bucket encrypted with dedicated CMKs
- [ ] S3 bucket policy rejects unencrypted PutObject requests (missing SSE-KMS header) with HTTP 403
- [ ] TLS 1.0 and 1.1 rejected by API Gateway; TLS 1.2+ confirmed via cipher scan
- [ ] WAF validation: SQL injection blocked by CRS rule; rate limit triggers HTTP 429 at 2,001 requests/5 min
- [ ] GuardDuty test: simulated suspicious API call generates HIGH finding within 5 minutes
- [ ] CloudTrail integrity: log file validation passes with no tampered files detected
- [ ] AmAdmin group users prompted for TOTP MFA; authentication fails without valid OTP
- [ ] Lambda functions retrieve all secrets via Secrets Manager API; no secrets in CloudFormation outputs
- [ ] SOC 2 evidence collection confirmed active: CloudTrail logging, Config evaluating, Security Hub aggregating

## Phase 2 Security Quality Gate

Complete all items before the Phase 2 production deployment on 15 December 2026.

- [ ] Amazon Inspector scan on all Lambda function layers: zero P1/P2 findings
- [ ] GitHub Actions CI/CD dependency scan: all known CVE alerts resolved before deployment
- [ ] GDPR data flow review: right-to-erasure procedure tested end-to-end
- [ ] AWS Config rule confirms no S3 replication to non-approved regions
- [ ] SOC 2 evidence package (Deliverable #16) delivered and signed off by Security & Compliance Lead

## Security Validation Procedures

The following commands are the core security validation procedures executed at each quality gate.

```bash
# IAM Access Analyzer — confirm zero active findings
aws accessanalyzer list-findings \
  --analyzer-arn "$ANALYZER_ARN" \
  --filter '{"status": {"eq": ["ACTIVE"]}}' \
  --query "length(findings)"

# KMS encryption validation for all S3 buckets
for BUCKET in amatra-isb-artifacts-prod \
              amatra-isb-cloudtrail-logs-prod \
              amatra-isb-templates-prod; do
  aws s3api get-bucket-encryption --bucket "$BUCKET" \
    --query "ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm"
done

# DynamoDB at-rest encryption confirmation
for TABLE in AmatraISB-SolutionState-Prod AmatraISB-UsageTracking-Prod; do
  aws dynamodb describe-table --table-name "$TABLE" \
    --query "Table.SSEDescription.Status"
done

# WAF SQL injection block test
curl -s -o /dev/null -w "%{http_code}" \
  -X POST "https://api.amatra-isb.internal/api/v1/solutions" \
  -H "Content-Type: application/json" \
  -d '{"brief": "SELECT * FROM users; DROP TABLE artifacts;--"}'

# CloudTrail log file integrity validation
aws cloudtrail validate-logs \
  --trail-arn "arn:aws:cloudtrail:us-west-2:${AWS_ACCOUNT_ID}:trail/amatra-isb-cloudtrail-prod" \
  --start-time "2026-07-01T00:00:00Z" \
  --query "failures"
```

## Ongoing Security Monitoring Schedule

The following recurring activities maintain the platform's security posture after go-live and provide the evidence stream for the SOC 2 audit.

- **Weekly:** Security & Compliance Lead reviews Security Hub findings dashboard; all NEW findings triaged
- **Monthly:** IAM Access Analyzer run to detect policy drift; CloudTrail log integrity re-validation
- **Quarterly:** Cognito access review — dormant accounts (no login in 90 days) deactivated
- **Annual:** KMS CMK rotation confirmed; SOC 2 control evidence refreshed for the audit period
- **On-Alert:** GuardDuty HIGH finding triggers automated Lambda remediation plus SNS to Security & Compliance Lead within 5 minutes

# Migration & Cutover

## Migration Approach

The Amatra Intelligent Solution Builder is a **greenfield** implementation. The two migration activities in scope are the Okta-to-Cognito identity migration in Phase 1 and the legacy Word/Excel/PowerPoint template ingestion in Phase 2. No bulk historical artifact migration is in scope per the SOW exclusions.

The identity migration uses a phased cut-over with a two-week parallel-run period: users are migrated in batches of 10 to Cognito while Okta remains active, and the Cognito JWT authoriser replaces the Okta validator on the production go-live date. The template migration is a one-time batch in Phase 2: templates are exported from Google Workspace, uploaded to S3, and processed by the Template Ingestion Lambda.

## Phase 1 Cutover Plan (30 September 2026)

### Pre-Cutover Checklist

All items in this checklist must be confirmed before the cutover window opens at 09:00 CT on 30 September 2026.

- [ ] Phase 1 UAT sign-off received from Head of Solutions in writing
- [ ] CTO phase-gate approval confirmed in writing
- [ ] All production infrastructure deployed and validated per Infrastructure Deployment runbooks
- [ ] DNS TTL reduced to 60 seconds for `api.amatra-isb.internal`
- [ ] Lambda `$PROD` aliases pointing to Phase 1 verified deployment package confirmed
- [ ] CloudWatch alarms and Synthetics canary active in production
- [ ] On-call rotation set for Phase 1 hypercare (vendor team)
- [ ] Go-live communication drafted to pre-sales consultants with login instructions and training schedule
- [ ] Rollback procedure rehearsed; GitHub Actions `rollback.yml` workflow tested end-to-end

### Go/No-Go Criteria

All criteria listed below must be confirmed as YES before the CTO authorises go-ahead. Any single NO blocks the cutover.

| Criterion | Status |
|-----------|--------|
| UAT sign-off from Head of Solutions received | Not confirmed |
| CTO phase-gate approval granted | Not confirmed |
| Zero P1 defects open | Not confirmed |
| All production infrastructure in target state | Not confirmed |
| Rollback procedure rehearsed and verified | Not confirmed |
| On-call rotation confirmed | Not confirmed |
| Training materials delivered to Head of Solutions | Not confirmed |

### Cutover Execution Steps

The following steps are executed in sequence by the vendor Cloud/DevOps Engineer and observed by the Amatra VP Engineering.

```bash
# Step 1: Final Staging smoke test
python scripts/cutover_smoke_test.py \
  --environment staging \
  --brief-count 3 \
  --artifact-types discovery-questionnaire,solution-briefing,statement-of-work,infrastructure-costs

# Step 2: Activate production Cognito user pool
python scripts/activate_prod_cognito.py \
  --user-pool-id "$PROD_USER_POOL_ID" \
  --notify-users true

# Step 3: Update Lambda PROD aliases to Phase 1 verified deployment package
for FUNC in isb-api-submit isb-api-status isb-api-retrieve isb-api-admin \
            isb-orchestrator-start isb-bedrock-sonnet isb-bedrock-haiku isb-artifact-processor; do
  FUNC_VERSION="$(aws lambda list-versions-by-function \
    --function-name "${FUNC}-prod" \
    --query "sort_by(Versions, &LastModified)[-1].Version" --output text)"
  aws lambda update-alias \
    --function-name "${FUNC}-prod" \
    --name PROD \
    --function-version "$FUNC_VERSION"
done

# Step 4: Update DNS to point to production API Gateway
aws route53 change-resource-record-sets \
  --hosted-zone-id "$HOSTED_ZONE_ID" \
  --change-batch file://infrastructure/scripts/dns-cutover-prod.json

# Step 5: Confirm production health check passes
sleep 10
curl -f https://api.amatra-isb.internal/api/v1/health

# Step 6: Send go-live communication to pre-sales consultants
python scripts/send_golive_notification.py \
  --template templates/presales_golive_email.html \
  --recipient-group presales

# Step 7: Monitor 4-hour window for DLQ messages, 5xx rate, and auth failures
python scripts/cutover_health_monitor.py \
  --environment prod \
  --duration-minutes 240
```

### Rollback Procedure

Rollback is initiated if any of the following occur within 4 hours of cutover: async job failure rate > 20%, API Gateway 5xx error rate > 5%, Cognito auth failure rate > 10%, or data integrity issues in S3 artifacts. Rollback authority rests with the vendor Project Manager in consultation with the Amatra VP Engineering, with a target completion time of 30 minutes or less.

```bash
# Rollback Lambda aliases to prior verified version
gh workflow run rollback.yml \
  --ref main \
  --field environment=prod \
  --field target_version="$PREVIOUS_VERSION"

# Revert DNS to API Gateway fallback URL if custom domain issues exist
aws route53 change-resource-record-sets \
  --hosted-zone-id "$HOSTED_ZONE_ID" \
  --change-batch file://infrastructure/scripts/dns-rollback-prod.json

# Notify CTO, VP Engineering, and Head of Solutions of rollback
python scripts/send_notification.py \
  --event rollback \
  --recipients cto@amatra.com,vp-engineering@amatra.com,solutions-lead@amatra.com
```

## Phase 2 Cutover Plan (15 December 2026)

Phase 2 follows the same pre-cutover, go/no-go, and rollback structure as Phase 1 with the following Phase 2-specific additions. The delivery pipeline Staging smoke test must confirm all seven artifact types generate successfully. The QA validation layer is activated in production with the pass-rate threshold set to 90%. The delivery team is notified with Phase 2 training session invites. An extended 48-hour monitoring window is used post-cutover due to the QA validation layer activation and new artifact types.

# Operational Handover

## Documentation Handover

All documentation items listed below are transferred to Amatra upon Phase 3 completion. Each item is reviewed in a joint session between the vendor Technical Writer/Lead Architect and the Amatra VP Engineering before formal acceptance.

### Technical Documentation

- [ ] Architecture Documentation: draw.io source files + PNG exports; all ADRs; data-flow diagrams
- [ ] API Documentation: OpenAPI 3.0 specification for all 9 platform endpoints
- [ ] Database Schema Documentation: DynamoDB table schemas, GSIs, TTL configuration, access patterns
- [ ] Integration Specifications: Bedrock prompt template library; Step Functions state machine diagram
- [ ] Configuration Guide: full `configuration.csv` parameter reference with per-environment values
- [ ] Infrastructure as Code Repository transferred to `amatra/amatra-isb` GitHub organisation with full history

### Operational Documentation

The following runbooks are delivered as Deliverable #23 (Operations Runbooks & Configuration Docs, Month 11, Week 4).

- [ ] **RUN-001:** Async Job Failure Triage — DLQ investigation, job replay, Bedrock throttle resolution
- [ ] **RUN-002:** Cognito User Administration — provisioning, group changes, account unlock, quarterly access review
- [ ] **RUN-003:** Usage Limit Override — per-user and global limit adjustment via admin console and AWS CLI
- [ ] **RUN-004:** Bedrock Quota Management — token budget review, Haiku substitution, quota increase request
- [ ] **RUN-005:** Incident Response — P1/P2/P3 escalation paths, automated remediation review, post-incident template
- [ ] **RUN-006:** DynamoDB PITR Restore — step-by-step restore to point-in-time for disaster recovery events
- [ ] **RUN-007:** Lambda Rollback — alias revert procedure for blue-green rollback within 30 minutes
- [ ] **RUN-008:** Cognito User Pool Backup Restore — nightly S3 export restore procedure

### User Documentation

- [ ] Pre-Sales Consultant User Guide (PDF, 30 pages)
- [ ] Delivery Consultant User Guide (PDF, 25 pages)
- [ ] Platform Administrator Guide (PDF, 50 pages)
- [ ] Quick Reference Cards per role: Pre-Sales, Delivery, Admin
- [ ] Recorded training session videos for all VILT sessions
- [ ] FAQ Document (50 Q&A; updated post-Phase 1 UAT)

## Knowledge Transfer Sessions

Knowledge transfer is structured across three targeted sessions aligned to the SOW Handover & Support section. All sessions are recorded and delivered to Amatra for future self-service onboarding of new hires.

Session 1 is Platform Operations Training delivered to the VP Engineering team at Phase 1 end (half-day). It covers CloudWatch dashboards, Lambda deployment management, DynamoDB capacity review, Cognito user administration, and incident response runbook walkthroughs (RUN-001 and RUN-005).

Session 2 is Delivery Artifact Pipeline Enablement delivered to the Delivery Consulting team at Phase 2 end (2 hours). It covers all seven artifact types, quality rubric interpretation, Terraform output customisation, and the admin override procedure for flagged artifacts.

Session 3 is Train-the-Trainer delivered to the Head of Solutions at GA (2 hours). It enables independent onboarding of future pre-sales hires, covering brief-submission facilitation, artifact review quality criteria, sandbox exercise delivery, and FAQ management.

## Support Transition

### Support Model

The table below defines the tier-based support model that governs both the hypercare period and steady-state operations after handover.

| Tier | Responsibility | Response Time | Escalation |
|------|----------------|---------------|------------|
| L1 (Amatra Internal) | Initial triage using runbooks; known issues via FAQ | 1 hour or less during business hours | To vendor L2 during hypercare; to VP Engineering post-hypercare |
| L2 (Vendor Hypercare) | Lambda errors, Cognito problems, Step Functions failures | P1 within 2 hours; P2 next business day | To L3 if unresolved within SLA |
| L3 (Vendor Lead Architect) | Complex architectural issues, security incidents, PITR events | P1 within 4 hours; P2 within 2 business days | AWS Business Support for service-layer issues |

### Hypercare Period

Phase 1 hypercare runs for 8 weeks post Phase 1 Go-Live (October/November 2026) with business-hours coverage (09:00–18:00 CT, Monday–Friday) via Slack channel `#amatra-isb-ops`. Scope includes generation failures, Bedrock prompt quality issues, Cognito authentication problems, async job failures, and performance tuning.

Phase 2 hypercare runs for 4 weeks post Phase 2 Go-Live (January 2027) with business-hours coverage. Scope includes delivery pipeline issues, QA validation layer tuning, Terraform output quality, and template pipeline defects.

## Handover Checklist

- [ ] All 24 SOW deliverables formally accepted by their designated acceptance owners
- [ ] All 8 operational runbooks delivered, reviewed, and validated through dry-runs
- [ ] All three knowledge transfer sessions completed and recordings delivered
- [ ] All three CloudWatch dashboard JSON definitions delivered for re-deployment
- [ ] SOC 2 Type II evidence package (Deliverable #16) delivered and signed off
- [ ] GitHub repository ownership transferred to `amatra/amatra-isb` organisation with full history
- [ ] All vendor team Staging environment access revoked post-Phase 2 completion
- [ ] Emergency contact list and escalation matrix documented and delivered
- [ ] Optimisation Recommendations Report (Deliverable #21) delivered to CTO

# Training Program

## Training Overview

### Objectives

The training program ensures all Amatra user groups achieve operational competency with the Intelligent Solution Builder platform before General Availability on 31 January 2027. Training is delivered in alignment with the SOW Handover & Support section, with three structured knowledge transfer sessions plus role-specific enablement modules covering all platform audiences. All sessions are recorded and transferred to Amatra for future self-service onboarding.

### Training Approach

The training program follows four core principles: phased delivery aligned with implementation milestones; role-based content tailored to each audience's responsibilities and Cognito group access; hands-on focus with practical exercises in a dedicated sandbox environment; and recorded sessions for all live VILT modules.

## Training Schedule

The table below lists all 10 training modules with their target audiences, durations, formats, and prerequisites. Module IDs map to SOW Deliverables #12 and #19.

| Module ID | Module Name | Target Audience | Duration | Format | Prerequisites |
|-----------|-------------|-----------------|----------|--------|---------------|
| TRN-001 | Platform Architecture Overview | Administrators, Delivery Team | 2 hours | ILT | None |
| TRN-002 | Admin Console & Cognito User Management | Administrators | 3 hours | Hands-On Lab | TRN-001 |
| TRN-003 | CloudWatch Monitoring & Incident Response | Administrators | 3 hours | Hands-On Lab | TRN-001 |
| TRN-004 | Backup, Recovery & Runbook Execution | Administrators | 2 hours | VILT | TRN-002 |
| TRN-005 | Pre-Sales Brief Submission & Artifact Review | Pre-Sales Consultants | 1.5 hours | VILT | None |
| TRN-006 | Artifact Quality Review & Feedback Loop | Pre-Sales Consultants | 2 hours | Hands-On Lab | TRN-005 |
| TRN-007 | Delivery Artifact Pipeline & Terraform Outputs | Delivery Consultants | 2 hours | ILT | TRN-001 |
| TRN-008 | QA Validation Layer & Quality Rubric | Delivery Consultants, Power Users | 2 hours | Hands-On Lab | TRN-007 |
| TRN-009 | API Integration & Usage Limits | IT Support, Administrators | 2 hours | Hands-On Lab | TRN-001 |
| TRN-010 | Train-the-Trainer Workshop | Head of Solutions | 2 hours | Workshop | All modules |

## Administrator Training

### TRN-001: Platform Architecture Overview (2 hours, ILT)

This module introduces the Amatra ISB platform architecture to administrators and delivery team members, providing the conceptual foundation required for all subsequent technical training.

**Learning Objectives:**
- Describe the four-layer serverless architecture (API & Auth, Orchestration, AI Generation, Data & Storage)
- Navigate the three CloudWatch dashboards (Operations, SLA, Quality)
- Explain the data flow from brief submission through Step Functions to S3 presigned URL delivery
- Identify the seven core AWS service components and their interactions

**Content Outline:**
1. Architecture diagram walkthrough (30 min) — layer-by-layer component review
2. Data flow deep dive (30 min) — brief submission to artifact download
3. Dashboard orientation (30 min) — live CloudWatch dashboards walkthrough
4. Security controls overview (20 min) — Cognito, KMS, WAF, GuardDuty
5. Knowledge check quiz (10 min)

**Materials Required:** Architecture diagram printed and projected; live CloudWatch dashboard read-only access; Platform Architecture Overview slide deck.

### TRN-002: Admin Console & Cognito User Management (3 hours, Hands-On Lab)

This module provides administrators with the skills to manage the full Cognito user lifecycle and platform usage governance controls.

**Learning Objectives:**
- Create, modify, and deactivate Cognito user accounts in all three groups
- Configure per-user monthly generation limits via DynamoDB and the admin console
- Override usage limits using the admin API endpoint
- Query CloudTrail audit logs for user administration events

**Content Outline:**
1. Cognito User Pool console navigation (30 min)
2. User provisioning and deactivation (45 min)
3. Usage limit management via DynamoDB and admin API (45 min)
4. Audit log review with CloudTrail Log Insights (30 min)
5. Backup export drill (30 min)

**Lab Exercises:** Onboard a new pre-sales consultant; override a user's monthly limit and verify the DynamoDB record; deactivate a dormant user and query CloudTrail; run the Cognito export script and confirm the S3 backup object.

**Materials Required:** Sandbox Cognito User Pool; lab exercise workbook; Administrator Guide (PDF).

### TRN-003: CloudWatch Monitoring & Incident Response (3 hours, Hands-On Lab)

This module equips administrators to proactively monitor platform health and execute incident response runbooks for P1 and P2 alerts.

**Learning Objectives:**
- Interpret all three CloudWatch dashboards against their SLA targets
- Diagnose async job failures using CloudWatch Log Insights structured JSON queries
- Execute the DLQ triage runbook (RUN-001) for a failed job message
- Escalate a P1 incident following the incident response runbook (RUN-005)

**Content Outline:**
1. Dashboard deep dive with live metric interpretation (45 min)
2. Log Insights structured JSON query techniques (30 min)
3. DLQ triage simulation with injected failed message (45 min)
4. P1 incident simulation and escalation walkthrough (30 min)
5. Contact matrix and Slack protocol (30 min)

**Lab Exercises:** Write a Log Insights query to find Lambda errors in the past 24 hours; replay a DLQ message; simulate a Bedrock throttle event and verify Step Functions retry behaviour; trigger a test P2 alarm and trace the alert to Slack.

**Materials Required:** Sandbox environment with pre-injected DLQ message; runbooks RUN-001 and RUN-005; CloudWatch Log Insights query cheat sheet.

### TRN-004: Backup, Recovery & Runbook Execution (2 hours, VILT)

This module covers disaster recovery procedures and validates that administrators can execute all platform runbooks independently before the hypercare period ends.

**Learning Objectives:**
- Initiate a DynamoDB PITR restore to a specified timestamp (RUN-006)
- Execute the Lambda rollback runbook (RUN-007) via GitHub Actions
- Restore the Cognito user pool from a nightly S3 backup (RUN-008)
- Document DR test results for the SOC 2 evidence package

**Content Outline:**
1. Backup architecture overview (20 min) — PITR, S3 versioning, Cognito export cadence
2. DynamoDB PITR restore procedure demo with RUN-006 walkthrough (40 min)
3. Lambda rollback procedure via GitHub Actions with RUN-007 walkthrough (30 min)
4. DR test execution in sandbox with results documentation (30 min)

**Materials Required:** Sandbox DynamoDB table with PITR enabled; GitHub Actions workflow access; runbooks RUN-006, RUN-007, and RUN-008.

## End User Training

End user training covers the day-to-day workflows for pre-sales consultants and delivery consultants — the two primary user groups who interact with the platform to generate and review consulting artifacts.

### TRN-005: Pre-Sales Brief Submission & Artifact Review (1.5 hours, VILT)

This module enables pre-sales consultants to use the platform for their primary workflow of submitting client briefs and reviewing the four Phase 1 artifact types.

**Learning Objectives:**
- Submit a structured client brief using the platform API
- Monitor async job status using the polling endpoint until completion
- Download and review generated artifacts via presigned S3 URLs
- Understand the content and purpose of each Phase 1 artifact type
- Access FAQ and submit a support request for artifact refinement

**Content Outline:**
1. Platform login and Cognito authentication (15 min)
2. Brief submission workflow with live demonstration (30 min)
3. Artifact review process for all four Phase 1 types (25 min)
4. Support resources and FAQ navigation (10 min)
5. Q&A (10 min)

**Materials Required:** Video conferencing with screen share; sandbox environment with sample briefs; Pre-Sales Consultant User Guide (PDF); Platform Quick Reference Card (one-page laminated).

### TRN-006: Artifact Quality Review & Feedback Loop (2 hours, Hands-On Lab)

This module trains pre-sales consultants in evaluating artifact quality against the quality rubric and providing structured feedback to improve Bedrock prompt performance.

**Learning Objectives:**
- Apply the artifact quality rubric across four evaluation dimensions
- Identify and document quality issues using the structured feedback form
- Submit a re-generation request with additional brief context to improve output
- Understand the 90% first-pass QA target and the consultant's role in achieving it

**Content Outline:**
1. Quality rubric overview with passing and failing examples (30 min)
2. Artifact review exercise — score three generated artifacts (45 min)
3. Feedback submission and re-generation workflow (20 min)
4. Quality trend interpretation via the Quality dashboard (25 min)

**Lab Exercises:** Score three pre-generated artifacts using the rubric; identify a content gap and submit structured feedback; re-submit a brief with enhanced context and compare output quality.

**Materials Required:** Sandbox environment with three pre-generated artifact sets; quality rubric scoring form; Pre-Sales Consultant User Guide quality review section.

## Delivery Consultant Training

### TRN-007: Delivery Artifact Pipeline & Terraform Outputs (2 hours, ILT)

This module introduces delivery consultants to the three Phase 2 artifact types and how to interpret Terraform automation outputs for infrastructure reprovisioning.

**Learning Objectives:**
- Describe the three delivery artifact types: detailed design document, implementation guide, and Terraform scripts
- Submit a brief for delivery artifact generation using the Delivery Cognito group
- Review and validate a generated detailed design document against its required sections
- Interpret Terraform HCL output files for customisation and reprovisioning

**Content Outline:**
1. Phase 2 pipeline architecture extension overview (30 min)
2. Detailed design document review (30 min)
3. Implementation guide review — phase alignment and command structure (25 min)
4. Terraform output interpretation and customisation (35 min)

**Materials Required:** Architecture diagram showing Phase 2 pipeline extensions; sample generated detailed design document from staging; sample generated Terraform outputs.

### TRN-008: QA Validation Layer & Quality Rubric (2 hours, Hands-On Lab)

This module provides delivery consultants and power users with skills to use the QA validation layer dashboard and manage the human review workflow for flagged artifacts.

**Learning Objectives:**
- Access and interpret the Quality & Usage CloudWatch dashboard metrics
- Understand QA scoring criteria applied by the Artifact Processor Lambda for each artifact type
- Identify artifacts with `qa_status: REVIEW_REQUIRED` and manage the review workflow
- Manually score a generated delivery artifact against the quality rubric

**Content Outline:**
1. QA validation layer architecture and scoring logic (20 min)
2. Quality dashboard walkthrough with live metrics (30 min)
3. REVIEW_REQUIRED workflow — identification and human review process (30 min)
4. Manual scoring exercise — apply rubric to three delivery artifacts (40 min)

**Lab Exercises:** Query DynamoDB for `REVIEW_REQUIRED` artifacts; score a flagged implementation guide; approve an artifact and verify the DynamoDB status update.

**Materials Required:** Sandbox environment with pre-flagged artifacts; quality rubric scoring reference per artifact type; Delivery Consultant User Guide QA section.

## IT Support Training

### TRN-009: API Integration & Usage Limits (2 hours, Hands-On Lab)

This module prepares IT support staff and administrators to interact with the platform API programmatically and manage usage governance controls.

**Learning Objectives:**
- Authenticate with the Cognito User Pool and obtain a JWT bearer token programmatically
- Call all nine platform API endpoints using curl and Python boto3
- Monitor per-user and global usage counters via the usage API endpoints
- Troubleshoot common API errors using HTTP response codes and CloudWatch Log Insights

**Content Outline:**
1. API authentication flow — Cognito JWT acquisition and token refresh (20 min)
2. Platform API endpoint walkthrough with live curl demonstrations (40 min)
3. Usage limit management via DynamoDB query and admin override API (30 min)
4. Troubleshooting common HTTP errors and Log Insights query patterns (30 min)

**Lab Exercises:** Obtain a JWT token and call the health and usage endpoints; submit a brief and poll until COMPLETE; simulate a usage limit exceeded error and verify the DynamoDB counter.

**Materials Required:** Sandbox API endpoint with a dedicated IT support Cognito test user; API endpoint reference card with all nine endpoints; Python 3.12 environment with boto3 and requests installed.

## Train-the-Trainer

### TRN-010: Train-the-Trainer Workshop (2 hours, Workshop)

This module fulfils SOW Deliverable #22 (Train-the-Trainer Session, Month 11, Week 4) and enables the Head of Solutions to independently onboard future pre-sales hires without requiring vendor involvement.

**Learning Objectives:**
- Deliver TRN-005 and TRN-006 to new pre-sales hires independently
- Facilitate the sandbox hands-on exercises in both modules
- Answer the top 20 most common platform questions using the documented FAQ
- Assess new hire competency using the platform knowledge check quiz

**Content Outline:**
1. Training delivery techniques for VILT and hands-on lab formats (20 min)
2. TRN-005 and TRN-006 materials review with facilitator guide walkthrough (40 min)
3. Mock delivery — Head of Solutions delivers a 10-minute excerpt of TRN-005 (30 min)
4. FAQ management and escalation paths for technical issues (30 min)

**Materials Required:** All TRN-005 and TRN-006 materials; facilitator guide with talking points and answer keys; new hire onboarding checklist template.

## Training Materials

All training materials are delivered as Deliverable #12 (Phase 1) and Deliverable #19 (Phase 2) and transferred to Amatra upon engagement close. The following materials are provided in both digital and print-ready formats.

- Pre-Sales Consultant User Guide (PDF, 30 pages) — covers TRN-005 and TRN-006 content
- Delivery Consultant User Guide (PDF, 25 pages) — covers TRN-007 and TRN-008 content
- Platform Administrator Guide (PDF, 50 pages) — covers TRN-001 through TRN-004 and TRN-009
- Quick Reference Cards per role (Pre-Sales, Delivery, Admin) in laminated one-page format
- Recorded session videos for all VILT sessions (TRN-004, TRN-005, TRN-010)
- Lab exercise workbooks for TRN-002, TRN-003, TRN-006, TRN-008, TRN-009
- Platform FAQ Document (50 Q&A; updated after Phase 1 UAT)

### Training Environment

All hands-on training is conducted in a dedicated sandbox environment isolated from dev, staging, and production. The sandbox uses synthetic client brief data, is reset weekly to a clean state, and is provided to participants two weeks before their scheduled training session.

### Training Effectiveness

The following assessment approach ensures training produces measurable competency outcomes for all participants.

| Metric | Target |
|--------|--------|
| Training Completion Rate | More than 95% of assigned users complete required modules before go-live |
| Knowledge Check Pass Rate | More than 85% of participants pass their module quiz on first attempt |
| Post-Training Satisfaction Score | More than 4.0 out of 5.0 from post-session survey |
| Time to Competency | Less than 2 weeks post-training for independent platform use |
| UAT First-Pass Rate | 90% or more of trained pre-sales consultants pass UAT artifact generation on first attempt |

# Appendices

## Appendix A: Environment Details

The following reference tables provide key configuration values for each of the three deployment environments. Values shown in brackets are populated at deployment time from `configuration.csv` and stored in AWS Systems Manager Parameter Store.

### Development Environment

| Component | Value |
|-----------|-------|
| Environment Name | `dev` |
| AWS Region | `us-west-2` |
| Cognito User Pool | `amatra-isb-users-dev` |
| DynamoDB SolutionState Table | `AmatraISB-SolutionState-Dev` |
| DynamoDB UsageTracking Table | `AmatraISB-UsageTracking-Dev` |
| S3 Artifacts Bucket | `[amatra-isb-artifacts-dev-account-id]` |
| API Gateway Stage | `dev` |
| Log Level | `debug` |
| Lambda Reserved Concurrency | `100` |
| CloudTrail Retention | `1 year` |
| PITR Enabled | `false` |
| Access | Vendor engineering team only; synthetic data only |

### Staging Environment

| Component | Value |
|-----------|-------|
| Environment Name | `staging` |
| AWS Region | `us-west-2` |
| Cognito User Pool | `amatra-isb-users-staging` |
| DynamoDB SolutionState Table | `AmatraISB-SolutionState-Staging` |
| DynamoDB UsageTracking Table | `AmatraISB-UsageTracking-Staging` |
| S3 Artifacts Bucket | `[amatra-isb-artifacts-staging-account-id]` |
| API Gateway Stage | `staging` |
| Log Level | `info` |
| Lambda Reserved Concurrency | `200` |
| CloudTrail Retention | `1 year` |
| PITR Enabled | `true` |
| Access | Vendor QA + Amatra VP Engineering + Head of Solutions; anonymised/synthetic data only |

### Production Environment

| Component | Value |
|-----------|-------|
| Environment Name | `prod` |
| AWS Region | `us-west-2` |
| Cognito User Pool | `amatra-isb-users-prod` |
| DynamoDB SolutionState Table | `AmatraISB-SolutionState-Prod` |
| DynamoDB UsageTracking Table | `AmatraISB-UsageTracking-Prod` |
| S3 Artifacts Bucket | `[amatra-isb-artifacts-prod-account-id]` |
| API Gateway Stage | `prod` |
| Log Level | `info` |
| Lambda Reserved Concurrency | `500` |
| CloudTrail Retention | `7 years (Object Lock, Compliance mode)` |
| PITR Enabled | `true` |
| Access | All authenticated Amatra users (Cognito JWT); US data residency enforced; real client briefs |

## Appendix B: Configuration Reference

The complete configuration parameter reference is maintained in `configuration.csv` in the delivery artifact prefix. The table below summarises configuration categories and their most critical parameters.

| Category | Parameter Count | Key Parameters |
|----------|-----------------|----------------|
| Project | 6 | `solution.name`, `solution.region.primary`, `aws.account_id` |
| Application | 7 | `application.artifact_types`, `application.presigned_url_ttl_seconds` |
| Compute | 11 | Lambda memory, timeout, and provisioned concurrency per function |
| Database | 8 | Table names, PITR flag, TTL days, encryption key aliases |
| Storage | 6 | Bucket names, lifecycle days, versioning flag, encryption key alias |
| Security | 15 | Cognito IDs, KMS key IDs, WAF WebACL ARN, GuardDuty flag |
| Integration | 16 | API Gateway IDs, Bedrock model IDs, SQS and Step Functions ARNs |
| Monitoring | 12 | Dashboard names, alarm thresholds, SNS topic ARN |
| Operations | 9 | Usage limits, backup schedules, CI/CD settings, rollback thresholds |

## Appendix C: Deployment Scripts

### deploy.sh

The following script orchestrates a full platform deployment to a target environment, invoking all CloudFormation and SAM deployment steps in the correct order and running pre- and post-deployment validation checks.

```bash
#!/bin/bash
# deploy.sh — Full Amatra ISB platform deployment script
# Usage: ./deploy.sh [environment] [version]
set -euo pipefail

ENVIRONMENT="${1:-staging}"
VERSION="${2:-latest}"

echo "Amatra ISB Deploy: v${VERSION} -> ${ENVIRONMENT}"

python scripts/pre_deploy_check.py --environment "$ENVIRONMENT"

aws cloudformation deploy \
  --template-file infrastructure/security/kms-keys.yaml \
  --stack-name "amatra-isb-kms-${ENVIRONMENT}" \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides "Environment=${ENVIRONMENT}"

sam build --use-container
sam deploy \
  --stack-name "amatra-isb-compute-${ENVIRONMENT}" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides "file://infrastructure/compute/${ENVIRONMENT}.json" \
  --no-fail-on-empty-changeset

aws cloudformation deploy \
  --template-file infrastructure/monitoring/cloudwatch-alarms.yaml \
  --stack-name "amatra-isb-alarms-${ENVIRONMENT}" \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides "Environment=${ENVIRONMENT}"

python scripts/post_deploy_validate.py --environment "$ENVIRONMENT"
echo "Deploy complete: amatra-isb v${VERSION} -> ${ENVIRONMENT}"
```

### rollback.sh

The following script performs an alias-based blue-green rollback for all Lambda functions, targeting a specific prior version and reverting all PROD aliases before running post-deployment validation.

```bash
#!/bin/bash
# rollback.sh — Lambda alias rollback to prior verified version
# Usage: ./rollback.sh [environment] [prior_version]
set -euo pipefail

ENVIRONMENT="${1:-prod}"
PRIOR_VERSION="${2:?prior_version is required}"

echo "ROLLBACK: amatra-isb -> ${ENVIRONMENT} (v${PRIOR_VERSION})"

FUNCTIONS=(
  "isb-api-submit" "isb-api-status" "isb-api-retrieve" "isb-api-admin"
  "isb-orchestrator-start" "isb-bedrock-sonnet" "isb-bedrock-haiku" "isb-artifact-processor"
)

for FUNC in "${FUNCTIONS[@]}"; do
  FUNC_NAME="${FUNC}-${ENVIRONMENT}"
  aws lambda update-alias \
    --function-name "$FUNC_NAME" \
    --name PROD \
    --function-version "$PRIOR_VERSION"
  echo "Reverted $FUNC_NAME to version $PRIOR_VERSION"
done

python scripts/post_deploy_validate.py --environment "$ENVIRONMENT"
echo "Rollback complete in $SECONDS seconds."
```

## Appendix D: Troubleshooting Guide

### Common Issues

#### Issue: Async Job Stuck in IN_PROGRESS for Over 60 Minutes

**Symptoms:** `GET /api/v1/solutions/{solution_id}/status` returns `IN_PROGRESS` for over 60 minutes; no artifact file appears in S3.

**Cause:** Step Functions execution stalled — likely due to a Bedrock `ThrottlingException` that exceeded the three retry attempts, or a Lambda timeout on the Bedrock Invoker function.

**Resolution:** Run the following commands to diagnose and restart the failed job.

```bash
aws stepfunctions describe-execution \
  --execution-arn "$EXECUTION_ARN" \
  --query "{Status:status,StopDate:stopDate,StatusDetails:statusDetails}"

aws logs filter-log-events \
  --log-group-name /aws/lambda/isb-bedrock-sonnet-prod \
  --start-time "$START_EPOCH_MS" \
  --filter-pattern "ThrottlingException"

python scripts/restart_failed_job.py --solution-id "$SOLUTION_ID"
```

#### Issue: DLQ Message Received (P1 Alert)

**Symptoms:** PagerDuty P1 alert fires; `amatra-isb-job-dlq-prod` has one or more messages.

**Cause:** A job message failed processing three times. Possible causes include Lambda error, DynamoDB write throttle, or SQS permission misconfiguration.

**Resolution:** Run the following commands to inspect the DLQ message and replay it after investigation.

```bash
aws sqs receive-message \
  --queue-url "https://sqs.us-west-2.amazonaws.com/${AWS_ACCOUNT_ID}/amatra-isb-job-dlq-prod" \
  --attribute-names All \
  --max-number-of-messages 1

aws logs filter-log-events \
  --log-group-name /aws/lambda/isb-orchestrator-start-prod \
  --filter-pattern "ERROR"

python scripts/replay_dlq_message.py \
  --dlq-url "https://sqs.us-west-2.amazonaws.com/${AWS_ACCOUNT_ID}/amatra-isb-job-dlq-prod" \
  --target-queue-url "https://sqs.us-west-2.amazonaws.com/${AWS_ACCOUNT_ID}/amatra-isb-job-queue-prod"
```

#### Issue: Cognito Authentication Failure Rate Above 10% (P2 Alert)

**Symptoms:** Slack alert in `#amatra-isb-ops`; multiple users reporting login failures.

**Cause:** Credential-stuffing attack detected by GuardDuty, or a Cognito User Pool configuration change.

**Resolution:** Run the following commands to determine whether the cause is an attack or a configuration issue.

```bash
aws guardduty list-findings \
  --detector-id "$DETECTOR_ID" \
  --finding-criteria '{"Criterion": {"severity": {"Gte": 5}}}' \
  --query "FindingIds"

aws logs filter-log-events \
  --log-group-name /aws/lambda/isb-guardduty-remediation-prod \
  --filter-pattern "SUSPEND"

aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventSource,AttributeValue=cognito-idp.amazonaws.com \
  --start-time "$INCIDENT_START_TIME" \
  --query "Events[].{Time:EventTime,Event:EventName,User:Username}"
```

## Appendix E: Contact Information

### Project Team

The following vendor team contacts are available during business hours Central Time throughout the engagement and hypercare periods.

| Role | Email | Availability |
|------|-------|--------------|
| Vendor Project Manager | pm@eoframework.com | Business hours CT |
| Lead Solutions Architect | solutions@eoframework.com | Business hours CT |
| ML/AI Engineer | ml@eoframework.com | Business hours CT |
| Security Engineer | security@eoframework.com | Business hours CT |
| Cloud/DevOps Engineer | devops@eoframework.com | Business hours CT |

### Amatra Stakeholder Contacts

| Role | Email |
|------|-------|
| CTO (Executive Sponsor) | cto@amatra.com |
| VP of Engineering | vpeng@amatra.com |
| Head of Solutions | solutions-lead@amatra.com |
| Security & Compliance Lead | security@amatra.com |

### Escalation Contacts

| Level | Contact | Availability | Response SLA |
|-------|---------|--------------|--------------|
| P1 (Platform Down) | Vendor on-call via PagerDuty | 24x7 during hypercare | Within 2 hours |
| P2 (Degraded Performance) | Slack `#amatra-isb-ops` | Business hours | Next business day |
| P3 (Advisory) | solutions@eoframework.com | Business hours | Within 3 business days |

### Vendor Support

| Vendor | Support Portal | SLA |
|--------|----------------|-----|
| AWS Business Support | https://console.aws.amazon.com/support | 1-hour response for critical (P1) |
| Amazon Bedrock quota increase | AWS Service Quotas console | Standard quota increase: 3–5 business days |
| Datadog APM | https://support.datadoghq.com | Per Datadog subscription agreement |
| GitHub Actions | https://support.github.com | Per GitHub Team plan |

## Appendix F: Glossary

The following terms and acronyms are used throughout this implementation guide and align to the Detailed Design Document glossary for consistency across all engagement deliverables.

| Term | Definition |
|------|------------|
| ADR | Architecture Decision Record — documents a significant architecture decision, alternatives, and rationale |
| Bedrock | Amazon Bedrock — the AWS managed foundation model API invoking Claude 3 Sonnet and Haiku |
| CMK | Customer Managed Key — an AWS KMS encryption key owned and controlled by Amatra |
| DLQ | Dead Letter Queue — an SQS queue capturing failed job messages after maxReceiveCount is reached |
| GA | General Availability — Phase 3 milestone (31 January 2027) when all 120 Amatra users are onboarded |
| GitOps | Deployment model where all changes are committed via pull request and applied by the CI/CD pipeline |
| ISB | Intelligent Solution Builder — shorthand for the Amatra Intelligent Solution Builder platform |
| PITR | Point-in-Time Recovery — DynamoDB continuous backup with minute-level restore and a 35-day window |
| Presigned URL | Time-limited, signed S3 URL granting temporary artifact download access (24-hour TTL) |
| RPO | Recovery Point Objective — maximum acceptable data loss; target 15 minutes or less via DynamoDB PITR |
| RTO | Recovery Time Objective — maximum acceptable recovery time; target 1 hour or less |
| SAM | AWS Serverless Application Model — CloudFormation extension for Lambda, API Gateway, and DynamoDB |
| SOC 2 | System and Organisation Controls 2 — auditing framework assessing five Trust Service Criteria |
| Step Functions | AWS Step Functions Standard Workflows — durable async generation pipeline orchestration |
| UAT | User Acceptance Testing — final quality gate before each production deployment |
| WAF | AWS Web Application Firewall — L7 protection on API Gateway with CRS, KBI, and rate-limiting rules |
