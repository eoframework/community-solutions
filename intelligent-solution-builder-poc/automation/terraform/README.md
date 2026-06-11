# Amatra Intelligent Solution Builder — Terraform Automation

Infrastructure-as-Code for the Amatra ISB platform.  
Provider: **AWS** | Environments: **prod · test · dr**

---

## Directory Structure

```
terraform/
├── environments/
│   ├── prod/          # Production (us-west-2) — full HA, WAF, PITR, S3 replication
│   ├── test/          # Test (us-west-2) — cost-optimised, single NAT, PITR off
│   └── dr/            # Disaster Recovery (us-east-1) — warm standby
└── modules/
    ├── aws/           # Tier 1: Provider-level primitive modules
    │   ├── api-gateway/
    │   ├── cloudtrail/
    │   ├── cloudwatch/
    │   ├── cognito/
    │   ├── dynamodb/
    │   ├── ecr/
    │   ├── kms/
    │   ├── lambda/
    │   ├── s3/
    │   ├── sqs/
    │   ├── step-functions/
    │   ├── vpc/
    │   └── waf/
    ├── api/           # Tier 2: API Gateway + Cognito authoriser
    ├── compute/       # Tier 2: ECR + SQS + Step Functions + Lambda functions
    ├── identity/      # Tier 2: Cognito User Pool and groups
    ├── monitoring/    # Tier 2: CloudWatch + CloudTrail + alarms
    ├── networking/    # Tier 2: VPC + PrivateLink endpoints
    ├── security/      # Tier 2: KMS (4 CMKs) + WAF
    └── storage/       # Tier 2: S3 + DynamoDB tables
```

---

## Pre-requisites

- Terraform >= 1.8.0
- AWS CLI v2 configured with appropriate credentials
- AWS account with service quotas for Bedrock, Lambda, DynamoDB, S3

---

## Quick Start

```bash
# 1. Create the Terraform state backend (one-time per environment)
cd scripts/
./setup-backend.sh prod us-west-2
./setup-backend.sh test us-west-2
./setup-backend.sh dr us-east-1

# 2. Validate all environments
./validate.sh

# 3. Deploy (tfvars files are generated from configuration.csv by the orchestrator)
./deploy.sh prod init
./deploy.sh prod plan
./deploy.sh prod apply
```

---

## Security Notes

- No secrets, credentials, or AWS account IDs are hard-coded anywhere.
- All secrets (KMS key ARNs, Cognito IDs, SES credentials, Datadog API key) are
  retrieved from AWS Secrets Manager at runtime by Lambda functions.
- S3 Block Public Access is enforced on every bucket.
- KMS encryption is applied to all S3 buckets, DynamoDB tables, SQS queues, and
  CloudWatch log groups.

---

## DR Strategy

| Aspect | Details |
|--------|---------|
| Region | us-east-1 (warm standby) |
| S3 | Cross-region replication from prod `amatra-artifacts-prod` |
| DynamoDB | Restored from PITR — no global tables (data residency requirement) |
| Lambda | Full stack deployed; activated on failover |
| RTO | 4 hours (Terraform redeploy + DynamoDB PITR restore) |
| RPO | 1 hour (PITR continuous + S3 sub-minute replication) |
