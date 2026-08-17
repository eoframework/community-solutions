# AWS Multi-Account Landing Zone — Terraform Automation

## Overview

This directory contains the Terraform Infrastructure-as-Code (IaC) for the AWS Multi-Account Landing Zone. It implements a two-tier module architecture across three environments (prod, test, dr) following the EO Framework standards.

**Solution:** `aws-landing-zone`  
**Provider:** AWS  
**Regions:** us-east-1 (primary) | us-east-2 (DR)  
**Environments:** prod, test, dr

---

## Architecture

### Two-Tier Module Structure

```
modules/
├── aws/                          # Tier 1: AWS provider primitives
│   ├── cloudtrail/               # CloudTrail trail resource
│   ├── cloudwatch/               # CloudWatch log groups, dashboards, alarms
│   ├── guardduty/                # GuardDuty detector and org admin
│   ├── kms/                      # Customer-managed KMS key + alias
│   ├── organizations/            # AWS Organizations OUs and policies
│   ├── s3/                       # S3 bucket with encryption, lifecycle, object lock
│   ├── securityhub/              # Security Hub with FSBP/NIST standards
│   ├── sns/                      # SNS topic with subscriptions
│   ├── sso/                      # IAM Identity Center permission sets
│   └── well-architected/
│       └── cost-optimization/budgets/   # AWS Budgets
├── aft/                          # Tier 2: Account Factory for Terraform infrastructure
├── best-practices/               # Tier 2: Budgets, Cost Anomaly Detection
├── governance/                   # Tier 2: OU hierarchy + SCPs/RCPs + SSO permission sets
├── logging/                      # Tier 2: Log Archive S3 + CloudTrail org trail + Lake
├── monitoring/                   # Tier 2: SNS topics + CloudWatch dashboards + EventBridge
└── security/                     # Tier 2: KMS keys + GuardDuty + Security Hub
```

### Environment Layout

```
environments/
├── prod/    # Production — us-east-1 primary, full SCPs + RCP, full retention
├── test/    # Test — us-east-1, reduced SCPs (no RCP), shorter retention
└── dr/      # DR — us-east-2 primary, mirrors production governance posture
```

---

## Prerequisites

- Terraform >= 1.9.0
- AWS CLI configured with appropriate credentials
- Management account access (for Control Tower and Organizations)
- `jq` (optional, for output parsing)

---

## Deployment Sequence

### 1. Set Up Remote State Backend (one-time per environment)

```bash
cd setup/backend
./state-backend.sh prod    # Creates S3 + DynamoDB in us-east-1
./state-backend.sh test    # Creates S3 + DynamoDB in us-east-1
./state-backend.sh dr      # Creates S3 + DynamoDB in us-east-2
```

### 2. Deploy Production Environment

```bash
cd environments/prod
terraform init -backend-config=backend.tfvars
./eo-deploy.sh plan
./eo-deploy.sh apply
```

### 3. Deploy DR Environment

```bash
cd environments/dr
terraform init -backend-config=backend.tfvars
./eo-deploy.sh plan
./eo-deploy.sh apply
```

### 4. Deploy Test Environment

```bash
cd environments/test
terraform init -backend-config=backend.tfvars
./eo-deploy.sh plan
./eo-deploy.sh apply
```

---

## Configuration

All environment-specific values are injected via `config/*.tfvars` files generated from `configuration.csv` by the orchestrator. **Do not create or modify .tfvars files manually** — they are regenerated from the single source of truth.

### Variable Groups

| Variable Object | Description | Sensitivity |
|-----------------|-------------|-------------|
| `solution` | Solution identity and metadata | Public |
| `project` | Region and environment config | Public |
| `ownership` | Owner team, cost center, project code | Public |
| `aws_accounts` | AWS account IDs | Confidential (Secrets Manager) |
| `aws_org` | Organizations ID and root ID | Confidential (Secrets Manager) |
| `sso` | IAM Identity Center config | Confidential (Secrets Manager) |
| `security` | SCP/RCP flags, KMS config | Public |
| `networking` | IPAM, VPC, TGW config | Public |
| `logging` | CloudTrail, Config settings | Public |
| `monitoring` | GuardDuty, Security Hub settings | Confidential |
| `aft` | AFT pipeline configuration | Public |
| `storage` | S3 and DynamoDB names | Confidential |
| `finops` | Budgets and cost config | Public |
| `dr` | RTO/RPO targets | Public |

---

## Security

- **No secrets or account IDs are hardcoded** — all sensitive values come from Secrets Manager/SSM at runtime
- KMS encryption enabled for all data at rest
- S3 Object Lock (compliance mode) on Log Archive bucket
- SCPs enforced at organization root level
- RCP data perimeter enforced in prod and dr (not test)
- TLS 1.2 minimum enforced via S3 bucket policies

---

## Key Landing Zone Components Managed

| Component | Module | Notes |
|-----------|--------|-------|
| OU hierarchy (7 OUs) | `governance` | Root, Security, Infrastructure, Workloads-Prod, Workloads-NonProd, Sandbox, Suspended |
| SCPs (5 policies) | `governance` | deny-root, restrict-regions, lock-cloudtrail, lock-config, require-mfa |
| RCP (data perimeter) | `governance` | Prod + DR only; not applied in test |
| IAM Identity Center permission sets | `governance` | PlatformAdmin, WorkloadAdmin, SecurityAuditor, NetworkOperator, FinOps |
| KMS keys | `security` | Primary region CMK with annual rotation |
| GuardDuty | `security` | Org-wide with Audit account as delegated admin |
| Security Hub (FSBP + NIST) | `security` | Aggregated to Audit account |
| Log Archive S3 + Object Lock | `logging` | 90-day Object Lock compliance mode, Glacier after 90 days |
| CloudTrail org trail | `logging` | Multi-region, organisation-wide |
| CloudTrail Lake | `logging` | 7-year retention (prod/dr), 1-year (test) |
| SNS alerting (3 tiers) | `monitoring` | CRITICAL, HIGH, MEDIUM topics |
| CloudWatch dashboards (3) | `monitoring` | Ops, Security Posture, FinOps |
| EventBridge routing | `monitoring` | GuardDuty → HIGH SNS, Security Hub CRITICAL → CRITICAL SNS |
| AFT state infrastructure | `aft` | S3 + DynamoDB for AFT pipeline backend |
| AWS Budgets | `best-practices` | Per-account at 80% and 100% thresholds |
| Cost Anomaly Detection | `best-practices` | Prod + DR only |

---

## Validation

```bash
# Validate all environments (no backend required)
./scripts/validate-all.sh

# Validate single environment
cd environments/prod
terraform init -backend=false
terraform validate
```

---

## DR Operations

The DR environment (us-east-2) mirrors the production governance posture including full SCPs + RCP data perimeter. DR failover procedure:

1. Route 53 / DNS cutover to us-east-2 workloads
2. Verify governance posture: `cd environments/dr && ./eo-deploy.sh plan`
3. Scale up workload AFT accounts in us-east-2 OU
4. Validate Security Hub and GuardDuty operational in us-east-2
5. Monitor S3 CRR replication lag via CloudWatch (RPO < 15 minutes)

**RTO targets:**
- Landing zone full rebuild: < 4 hours
- Log Archive S3 restore from CRR: < 1 hour
- Network Firewall AZ failover: < 30 minutes
- IAM Identity Center SSO: < 2 hours (AWS-managed SLA)

---

## Naming Conventions

All resources follow the pattern: `{solution_abbr}-{environment}-{resource_type}`

Examples:
- `ins-prod-key-primary` — Production KMS key
- `ins-prod-alerts-critical` — CRITICAL SNS topic
- `ins-prod-scp-deny-root` — Root deny SCP
- `ins-prod-cloudtrail-lake` — CloudTrail Lake event store
