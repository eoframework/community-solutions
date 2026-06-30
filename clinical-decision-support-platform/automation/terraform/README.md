# MedCore CDS Platform — Terraform Automation

Infrastructure-as-Code for the MedCore Clinical Decision Support Platform on AWS.

## Architecture Overview

| Layer | Technology |
|-------|-----------|
| Ingestion | Kinesis Data Streams (10 shards) + MSK Kafka (3-broker) |
| PHI Datastore | Amazon HealthLake FHIR R4 |
| Feature Cache | SageMaker Feature Store + ElastiCache Redis |
| ML Inference | SageMaker Real-Time Endpoints (sepsis, readmission, rapid-response) |
| LLM Narratives | Amazon Bedrock (Claude 3) |
| Alert Routing | EventBridge + SNS + Lambda |
| Dashboard | React/Amplify + ECS Fargate + ALB |
| Identity | Amazon Cognito + Azure AD SAML 2.0 |
| Database | RDS Aurora PostgreSQL (Multi-AZ) |
| Security | KMS CMKs + WAF + GuardDuty + CloudTrail + Config + Security Hub |
| DR | Active/Passive multi-region (us-east-1 → us-west-2) |

## Directory Structure

```
terraform/
├── environments/
│   ├── prod/          # Production (us-east-1)
│   ├── test/          # QA/Test (us-east-1, reduced sizing)
│   └── dr/            # Passive DR standby (us-west-2)
└── modules/
    ├── aws/           # Tier 1 — provider primitives
    │   ├── vpc/       # VPC + subnets + NAT + PrivateLink
    │   ├── kms/       # KMS Customer Managed Keys
    │   ├── alb/       # Application Load Balancer
    │   ├── rds/       # Aurora PostgreSQL
    │   ├── elasticache/ # ElastiCache Redis
    │   ├── s3/        # S3 buckets (HIPAA Object Lock)
    │   ├── kinesis/   # Kinesis Data Streams + DLQ
    │   ├── msk/       # MSK Kafka cluster
    │   └── ecs/       # ECS Fargate cluster + service
    ├── networking/    # Tier 2 — VPC composition
    ├── security/      # Tier 2 — KMS + WAF + GuardDuty + audit
    ├── storage/       # Tier 2 — S3 + Aurora + ElastiCache
    ├── ingestion/     # Tier 2 — Kinesis + MSK
    ├── compute/       # Tier 2 — ALB + ECS (dashboard + API)
    ├── ml-platform/   # Tier 2 — SageMaker roles + SSM + Model Registry
    └── monitoring/    # Tier 2 — CloudWatch + SNS + AWS Config
```

## Prerequisites

- Terraform >= 1.10.0
- AWS CLI configured with appropriate credentials
- AWS account in the Clinical Applications OU

## Deployment Sequence

### 1. Set up Remote State Backend

```bash
cd scripts/
./state-backend.sh prod    # us-east-1
./state-backend.sh test    # us-east-1
./state-backend.sh dr      # us-west-2
```

### 2. Deploy Production

```bash
cd environments/prod
terraform init -backend-config=backend.tfvars
./eo-deploy.sh plan
./eo-deploy.sh apply
```

### 3. Deploy Test

```bash
cd environments/test
terraform init -backend-config=backend.tfvars
./eo-deploy.sh apply
```

### 4. Deploy DR

```bash
cd environments/dr
terraform init -backend-config=backend.tfvars
./eo-deploy.sh apply
```

## Configuration

All environment values are supplied via `config/*.tfvars` files, generated from
`configuration.csv` by the orchestrator. **Do not** edit `.tfvars` files manually.

## Security Notes

- No secrets, credentials, or AWS account IDs are hard-coded anywhere.
- All PHI data stores are encrypted with dedicated KMS Customer Managed Keys.
- Secrets Manager manages all application credentials (Aurora, Epic OAuth, Mirth API key).
- CloudTrail provides 7-year WORM audit logging via S3 Object Lock (Compliance mode).
- WAF, GuardDuty, Security Hub, and Macie are enabled in Production and DR.

## Compliance

This platform is HIPAA BAA-covered, SOC 2 Type II-ready, and HITECH-compliant.
See the Security Architecture Document for control mappings.
