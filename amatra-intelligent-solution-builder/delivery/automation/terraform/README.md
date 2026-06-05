# Amatra Agentic Pre-Sales Platform — Terraform Automation

## Overview

This Terraform module tree provisions the complete Amatra Agentic Pre-Sales Platform on AWS (us-west-2), as specified in SOW OPP-2026-001. The platform is a fully serverless, multi-agent orchestration system producing 12 EO Framework artifacts per solution run in under 60 minutes.

## Architecture

### Two-Tier Module Structure

```
modules/
├── aws/                    # Tier 1: AWS provider primitive modules
│   ├── api-gateway/        # HTTP API v2, JWT authoriser, 11 routes
│   ├── cloudtrail/         # CloudTrail with S3 + DynamoDB data events
│   ├── codepipeline/       # CodePipeline + CodeBuild CI/CD
│   ├── cognito/            # User Pool, 30-day refresh tokens
│   ├── dynamodb/           # user_profiles, solution_state, quota_global
│   ├── ecr/                # Agent Docker image repository
│   ├── guardduty/          # Threat detection (SOC 2 baseline)
│   ├── kms/                # Customer-managed encryption keys
│   ├── lambda/             # API route handlers, quota-reset trigger
│   ├── s3/                 # Artifact bucket + CloudTrail audit bucket
│   ├── secrets-manager/    # GitHub PAT + Cognito secret (no values)
│   ├── step-functions/     # 5-agent orchestration state machine
│   └── vpc/                # VPC, private subnets, NAT GW, VPC endpoints
└── monitoring/             # Tier 2: CloudWatch dashboards, SNS, alarms
```

### Environments

| Environment | Purpose | Key Differences |
|-------------|---------|-----------------|
| `prod` | Production platform | Full concurrency (50), 365-day retention, PITR enabled |
| `test` | Dev/test workloads | Reduced concurrency (10), 30-day retention, PITR disabled |
| `dr` | Disaster recovery | Mirrors prod sizing, independent CMK, 4-hour RTO |

## Prerequisites

1. AWS account access in us-west-2 (fresh footprint per SOW)
2. Terraform >= 1.10.0
3. AWS CLI configured with appropriate IAM permissions
4. S3 backend bucket + DynamoDB lock table (created via `scripts/deploy.sh`)

## Quick Start

```bash
# Validate all environments (no AWS credentials required)
cd automation/scripts
./validate-all.sh

# Plan production
./deploy.sh prod plan

# Apply production
./deploy.sh prod apply
```

## Security

- **No secrets in code**: All sensitive values (GitHub PAT, Cognito client secret, KMS key IDs, account IDs) are retrieved from AWS Secrets Manager or SSM Parameter Store at runtime.
- **SSE-KMS**: All S3 buckets and CloudWatch Log Groups use customer-managed KMS keys.
- **VPC isolation**: Lambda functions run in private subnets; VPC endpoints route Bedrock/DynamoDB/S3/ECR traffic without NAT.
- **JWT auth**: All 11 API routes require valid Cognito JWT tokens.

## Module Dependencies

```
kms → networking → cognito → database → storage → ecr → secrets
                           ↘                              ↘
                             compute → api_gateway          monitoring
                           ↗           ↘
                  stepfunctions        cloudtrail, guardduty, cicd
```

## Variables

Variables are declared in `variables.tf` per environment. Values are supplied via `config/*.tfvars` files generated from `configuration.csv` by the orchestrator. **Do not create `.tfvars` files manually** — the orchestrator owns those.

## Outputs

Key outputs per environment:

- `vpc_id` — VPC for Lambda and AgentCore
- `cognito_user_pool_id` — Referenced by API Gateway JWT authoriser
- `api_gateway_endpoint` — HTTP API v2 invoke URL
- `artifact_bucket_name` — S3 bucket for raw and converted artifacts
- `stepfunctions_state_machine_arn` — Solution generation orchestrator
- `ecr_repository_url` — Agent Docker image repository

## CI/CD Gate

The CodeBuild project enforces `terraform validate` on every PR before Docker image build. See `modules/aws/codepipeline/main.tf` for the full buildspec.
