---
document_title: Implementation Guide
solution_name: AWS Cloud Governance Platform — Contoso Financial
document_version: "1.0"
author: Amatra Lead Solution Architect
last_updated: 2025-06-01
technology_provider: aws
client_name: Contoso Financial
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

## Project Overview

This Implementation Guide provides step-by-step procedures for deploying the AWS Cloud Governance Platform for Contoso Financial. The engagement replaces a manual, credential-sharing cloud environment with a fully automated, policy-enforced governance foundation built on AWS Control Tower, Account Factory for Terraform (AFT), Service Control Policies, AWS Config, IAM Identity Center, Security Hub, GuardDuty, and CloudTrail — all deployed within Australian AWS regions (ap-southeast-2 primary; ap-southeast-4 DR) to satisfy Contoso Financial's data sovereignty obligations.

The implementation follows a three-phase, foundation-first approach over 16 weeks, deliberately structured to protect the April 30, 2026 ISO 27001 regulatory review deadline. Every procedure in this guide is traceable to a commitment in the Statement of Work (SOW v1.0, June 2025) and to the technical specifications in the Detailed Design Document (v1.0).

## Implementation Scope

- **In Scope:**
  - AWS Control Tower landing zone with structured OU hierarchy (ap-southeast-2 primary; ap-southeast-4 DR baseline)
  - AFT account vending pipeline with ITSM change-approval integration
  - Preventive guardrails (SCPs): no-console-access in production, region lock (ap-southeast-2/ap-southeast-4 only), encryption enforcement
  - Detective guardrails: ~80 AWS Config rules (ISO 27001 conformance pack + Contoso Financial internal security baseline)
  - Centralised Security Hub, GuardDuty, and CloudTrail with 12-month S3 WORM log archive
  - IAM Identity Center federation with on-premises enterprise directory (1 IdP connector, SAML 2.0)
  - SIEM integration: Security Hub CRITICAL/HIGH findings and CloudTrail events forwarded to existing SIEM (≤ 5-minute SLA)
  - ITSM integration: change-approval gating for all account vending and guardrail changes
  - Onboarding of three existing production environments via AFT baseline
  - Network infrastructure: Transit Gateway (hub-spoke), AWS Network Firewall, Direct Connect (ap-southeast-2 and ap-southeast-4)
  - ISO 27001 compliance evidence package for Q2 2026 regulatory submission
  - Operational runbooks and knowledge transfer to Contoso Financial platform team
  - 8-week post-go-live hypercare support (Weeks 17–24, covering the April 2026 review period)

- **Out of Scope:**
  - Migration or remediation of the two legacy on-premises workloads
  - Application refactoring or code changes to existing workloads
  - Replacement of the on-premises identity provider (federation only)
  - Management of the existing on-premises SIEM or ITSM platform
  - AWS Direct Connect circuit procurement (Contoso Financial responsibility)
  - Compliance frameworks beyond ISO 27001 and the internal security baseline

- **Dependencies:**
  - AWS Direct Connect circuits ordered and provisioned before Phase 2 start (Week 7)
  - CISO sign-off on Architecture Design Document by end of Week 6
  - On-premises IdP team availability for federation workshop (Week 3) and configuration sessions (Week 11)
  - SIEM API credentials and endpoint documentation by Week 9
  - ITSM API access and workflow documentation by Week 8

## Timeline Overview

- **Project Duration:** 16 weeks (4 months)
- **Go-Live Date:** End of Week 15 (M9 milestone)
- **Hypercare End:** Week 24 (M10 milestone)
- **Key Milestones:**
  - M1 – Kickoff Complete: End of Week 1
  - M2 – Discovery Sign-Off: End of Week 4
  - M3 – Architecture Approved (CISO gate): End of Week 6
  - M4 – Landing Zone Live: End of Week 9
  - M5 – Guardrails Enforced: End of Week 10
  - M6 – Identity Federated: End of Week 11
  - M7 – Full Platform Live: End of Week 12
  - M8 – UAT Sign-Off: End of Week 15
  - M9 – Go-Live: End of Week 15
  - M10 – Hypercare End: Week 24

---

# Prerequisites

Before starting Phase 1 implementation activities, all items in the checklists below must be verified and confirmed. Incomplete prerequisites must be resolved and escalated to Rachel Moore (Contoso Financial PM) and Amatra Project Manager.

## Technical Prerequisites

The following technical items must be in place before implementation begins.

### AWS Account Access

- [ ] Read-only access to all existing Contoso Financial AWS accounts provisioned for the Amatra team within 5 business days of kickoff
- [ ] AWS Management account credentials confirmed; Amatra team has sufficient permissions to assess account structure
- [ ] Existing IAM reports exported and provided to Amatra Senior Security Engineer for gap analysis
- [ ] Existing AWS account inventory documented (estimated 3–5 accounts)
- [ ] AWS MAP and AWS Partner Services Credits confirmed by AWS APAC account team

### Network Connectivity

- [ ] AWS Direct Connect hosted connections for ap-southeast-2 (1 Gbps) ordered by Contoso Financial procurement before Week 7
- [ ] AWS Direct Connect hosted connections for ap-southeast-4 (1 Gbps) ordered by Contoso Financial procurement before Week 7
- [ ] Site-to-Site VPN credentials and configuration documentation available for backup path configuration
- [ ] VPC CIDR master pool (10.0.0.0/16 primary; 10.1.0.0/16 DR) confirmed as non-overlapping with on-premises address space
- [ ] Network Account CIDR (10.0.0.0/24) confirmed available

### Security Baseline

- [ ] Contoso Financial Internal Security Baseline documentation provided to Amatra Senior Security Engineer by Week 1
- [ ] ISO 27001 Annex A control mapping requirements confirmed with CISO
- [ ] Break-glass emergency access procedure policy approved and stored securely
- [ ] MFA enforcement confirmed on on-premises IdP for all federation-bound user groups

### Identity & Integration Prerequisites

- [ ] On-premises IdP SAML 2.0 metadata URL (`identity.sso.saml_idp_metadata_url`) available from IdP team by Week 3
- [ ] On-premises IdP signing certificate PEM provided by Week 3
- [ ] SIEM API endpoint URL and authentication credentials available by Week 9
- [ ] ITSM API endpoint URL, OAuth 2.0 client ID and secret available by Week 8
- [ ] ITSM change-approval workflow documentation provided to Amatra Integration Specialist by Week 8
- [ ] SCIM provisioning capabilities of on-premises IdP confirmed (Week 3 workshop)

### Tooling & Licensing

- [ ] Terraform Cloud Plus licence (10 workspaces) procured before Phase 2 start
- [ ] Git repository created with appropriate access controls for IaC source of truth
- [ ] AWS Business Support plan activated on the Management account before Phase 2

## Organisational Prerequisites

- [ ] Project team assigned and confirmed available for engagement duration
- [ ] James Wu (CTO) confirmed as executive sponsor and budget owner; available for milestone approvals
- [ ] Priya Nair (Head of Platform Engineering) confirmed as primary technical contact; 25% time commitment confirmed
- [ ] Rachel Moore (IT Delivery Manager) confirmed as PM counterpart; available for the full engagement
- [ ] CISO (or delegated security representative) available for architecture sign-off by end of Week 4 and UAT sign-off by end of Week 15
- [ ] On-call rotation established for platform team before go-live
- [ ] Change management process activated; ITSM change windows for production cutovers confirmed for Week 15

## Environmental Setup

### Development / Non-Production Environment

- [ ] Contoso Financial AWS account designated for non-production (dev/test/staging) workloads confirmed
- [ ] Non-production accounts accessible via ITSM-gated provisioning after AFT deployment
- [ ] Synthetic/anonymised test data prepared (no PII in non-production environments)
- [ ] Platform team developer access (Developer permission set) provisioned before Phase 2 baseline deployment

### Staging / Pre-Production Environment

- [ ] Staging OU defined in target Control Tower OU hierarchy design
- [ ] Staging AFT baseline configuration prepared and reviewed by Lead Solution Architect
- [ ] QA team access provisioned for UAT activities (Weeks 14–15)

### Production Environment

- [ ] Three production environment accounts confirmed in scope for onboarding (Weeks 10–12)
- [ ] Production ITSM change windows confirmed for Week 15 cutovers (Days 1, 2, and 3)
- [ ] Production workload owners notified of onboarding schedule and 2-hour post-cutover monitoring windows
- [ ] On-call rotation and runbook acceptance procedure agreed with Priya Nair before go-live

---

# Environment Setup

## Phase 1: Discovery & Design (Weeks 1–6)

### Objectives

Phase 1 establishes a shared understanding of the current AWS environment, produces all architecture and design artefacts required for implementation, and obtains the CISO sign-off gate (M3) that clears Phase 2 to begin. This phase is critical-path: design decisions made here define the SCP framework, OU hierarchy, and federation architecture for the entire platform.

### Activities

The table below covers all Phase 1 activities, their owners, durations, and dependencies.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Project kickoff — RAID log, team onboarding, access provisioning | Amatra PM + Contoso FM | 1 day | SOW execution |
| Current-state assessment — account inventory, IAM reports, CloudTrail gaps | Amatra Arch + Sec Eng | 3 days | Read-only AWS access |
| AWS Control Tower / Organizations readiness assessment | Amatra Arch | 2 days | Current-state assessment |
| ISO 27001 control mapping to AWS services (Deliverable #4) | Amatra Sec Eng | 3 days | Internal security baseline doc |
| On-premises IdP assessment + federation design workshop | Amatra Sec Eng + IdP team | 1 day (Week 3) | IdP team availability |
| ITSM and SIEM integration assessment | Amatra Eng + ITSM/SIEM admins | 2 days | API documentation |
| Gap analysis and risk register | Amatra Arch + Sec Eng | 2 days | All assessments |
| Architecture design: OU hierarchy, guardrails, identity, network, security monitoring | Amatra Arch | 5 days | Gap analysis complete |
| Architecture documentation package for CISO review (Deliverable #5) | Amatra Arch + Tech Writer | 3 days | Architecture design |
| CISO architecture review session (Week 5) | Amatra Arch + CISO | 1 day | Architecture doc package |
| Architecture sign-off gate — M3 (End of Week 6) | CISO | — | CISO review session |

### Detailed Procedures

#### 1.1 Project Kickoff

The kickoff session aligns all stakeholders on engagement scope, operating rhythm, and immediate actions.

```bash
# Verify AWS access for Amatra team (run from Amatra's management workstation)
aws sts get-caller-identity --profile contoso-readonly

# List existing AWS accounts in the organization
aws organizations list-accounts --profile contoso-readonly \
  --query 'Accounts[*].{Id:Id,Name:Name,Status:Status}'

# Export IAM credential report for gap analysis
aws iam generate-credential-report --profile contoso-readonly
aws iam get-credential-report --profile contoso-readonly \
  --query 'Content' --output text | base64 -d > credential-report.csv
```

**Expected Output:**
```
{
    "UserId": "AIDA...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/amatra-readonly"
}
```

#### 1.2 Environment Provisioning Preparation

Before any infrastructure is deployed, confirm that the Terraform Cloud Plus workspace configuration and backend are ready.

```bash
# Clone the IaC repository
git clone https://github.com/amatra/cntso-governance-platform.git
cd cntso-governance-platform

# Validate Terraform version (required: >= 1.5)
terraform version

# Initialise Terraform Cloud workspace
terraform login
terraform workspace new cntso-management-aft
```

#### 1.3 CI/CD Pipeline Baseline

The GitOps pipeline must be configured before Phase 2 build activities begin.

```bash
# Verify Terraform Cloud workspace VCS connection
terraform workspace list

# Run a plan to validate workspace configuration (no resources yet)
terraform plan -var-file=envs/nonprod.tfvars
```

### Deliverables

- [ ] Current State Assessment Report accepted by Priya Nair (Deliverable #2, Week 3)
- [ ] Cloud Readiness & Gap Analysis accepted by Priya Nair and CISO (Deliverable #3, Week 4)
- [ ] ISO 27001 Control Mapping Matrix accepted by CISO (Deliverable #4, Week 4)
- [ ] Architecture Design Document signed off by CISO (Deliverable #5, Week 5; gate: Week 6)
- [ ] Project Kickoff Deck and RAID log accepted by Rachel Moore (Deliverable #1, Week 1)

### Success Criteria

- CISO has provided written sign-off on the Architecture Design Document by end of Week 6 (M3 gate)
- All assessment findings documented and accepted by Priya Nair
- ISO 27001 control-to-AWS-service mapping validated against Contoso Financial's internal security baseline
- ITSM and SIEM integration assessment completed; API access confirmed available by Weeks 8–9

---

## Phase 2: Build & Integrate (Weeks 7–12)

### Objectives

Phase 2 deploys the full governance platform in ap-southeast-2, establishes the DR baseline in ap-southeast-4, and integrates with Contoso Financial's existing SIEM and ITSM platforms. All production changes are gated through ITSM change-approval workflow.

### Activities

The following table covers all Phase 2 activities across sub-phases 2a (Landing Zone & Identity), 2b (Guardrails & Integrations), and 2c (Network & DR).

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| AWS Control Tower deployment (ap-southeast-2) | Amatra Cloud Eng | 3 days | M3 CISO sign-off |
| OU hierarchy and account structure establishment | Amatra Arch + Cloud Eng | 2 days | Control Tower deployment |
| IAM Identity Center federation with on-premises IdP | Amatra Sec Eng + IdP team | 2 days (Week 11) | IdP team availability |
| AFT pipeline deployment with ITSM integration | Amatra Eng (×2) | 5 days | Terraform Cloud Plus licence |
| SCP guardrail implementation | Amatra Sec Eng | 3 days | OU hierarchy live |
| AWS Config conformance packs and custom rules | Amatra Sec Eng | 4 days | Security Account setup |
| Auto-remediation Lambda functions | Amatra Eng | 3 days | Config rules deployed |
| Security Hub + GuardDuty org configuration | Amatra Sec Eng | 2 days | Audit Account setup |
| SIEM integration (EventBridge + Lambda) | Amatra Eng | 3 days | SIEM API credentials (Week 9) |
| ITSM workflow integration | Amatra Eng | 3 days | ITSM API credentials (Week 8) |
| Transit Gateway + Network Firewall deployment | Amatra Cloud Eng | 3 days | Network Account setup |
| Direct Connect + VPN configuration | Amatra Cloud Eng | 2 days | Direct Connect circuits provisioned |
| DR baseline deployment (ap-southeast-4) | Amatra Arch + Cloud Eng | 3 days | Primary region complete |
| Production environment onboarding (3 environments) | Amatra Eng + Priya Nair | 3 days (Week 12) | AFT pipeline operational |
| CI/CD GitOps pipeline configuration | Amatra Eng | 2 days | All Terraform workspaces live |
| Configuration and Operations Guide (Deliverable #17) | Amatra Tech Writer | 5 days | All components deployed |

### Detailed Procedures

#### 2.1 Core Infrastructure Deployment

The core deployment uses the AFT Terraform pipeline. All deployments are initiated via approved ITSM change records.

```bash
# Switch to the management account workspace
cd infrastructure/management
terraform init -backend-config=backend-prod.tfvars

# Plan Control Tower deployment
terraform plan -var-file=envs/prod.tfvars -out=ct-deployment.plan

# Review plan and apply after ITSM change approval
terraform apply ct-deployment.plan

# Verify Control Tower landing zone status
aws controltower list-landing-zones \
  --query 'landingZones[0].{Status:status,Version:version}'
```

**Expected Output:**
```
{
    "Status": "ACTIVE",
    "Version": "3.3"
}
```

#### 2.2 AFT Pipeline Deployment

```bash
# Deploy AFT pipeline from the management account workspace
cd infrastructure/aft
terraform init -backend-config=backend-aft.tfvars

terraform plan -var-file=envs/prod.tfvars -out=aft.plan
terraform apply aft.plan

# Confirm AFT CodePipeline is healthy
aws codepipeline get-pipeline-state \
  --name aws-aft-account-provisioning-pipeline \
  --query 'stageStates[*].{Stage:stageName,Status:latestExecution.status}'
```

#### 2.3 GuardDuty and Security Hub Org Configuration

```bash
# Enable GuardDuty organizational detector
aws guardduty create-detector \
  --enable \
  --data-sources S3Logs={Enable=true},Kubernetes={AuditLogs={Enable=true}} \
  --features '[{"Name":"S3_DATA_EVENTS","Status":"ENABLED"},{"Name":"EKS_AUDIT_LOGS","Status":"ENABLED"}]'

# Delegate Security Hub to Audit account
aws securityhub enable-organization-admin-account \
  --admin-account-id $(aws ssm get-parameter \
    --name "/cntso/account_id/audit" \
    --query 'Parameter.Value' --output text)
```

### Deliverables

- [ ] IaC Module Library (Terraform) accepted by Priya Nair (Deliverable #6, Week 9)
- [ ] AWS Control Tower Landing Zone accepted by Priya Nair (Deliverable #7, Week 9)
- [ ] Account Vending Machine (AFT + ITSM integration) accepted (Deliverable #8, Week 10)
- [ ] Preventive & Detective Guardrails accepted by CISO (Deliverable #9, Week 10)
- [ ] IAM Identity Center Federation accepted by CISO (Deliverable #10, Week 11)
- [ ] Centralised Security Hub, GuardDuty & CloudTrail accepted by CISO (Deliverable #11, Week 11)
- [ ] SIEM Integration validated (Deliverable #12, Week 11)
- [ ] DR Baseline active (Deliverable #13, Week 12)
- [ ] Network Infrastructure deployed (Deliverable #14, Week 12)
- [ ] Production Environment Onboarding complete (Deliverable #15, Week 12)
- [ ] CI/CD GitOps Pipeline accepted (Deliverable #16, Week 12)
- [ ] Configuration and Operations Guide accepted by Priya Nair (Deliverable #17, Week 12)

### Success Criteria

- All platform services operational in ap-southeast-2; DR baseline active in ap-southeast-4 (M7)
- SCPs enforce no-console-access in all production OUs; Config rules active (M5)
- IAM Identity Center federated with on-premises IdP; zero shared credentials in new accounts (M6)
- AFT pipeline successfully provisions a test account within 60 minutes of ITSM approval
- SIEM receives test Security Hub CRITICAL finding within 5 minutes
- All three production environments onboarded via AFT baseline

---

## Phase 3: Testing, Validation & Handover (Weeks 13–16)

### Objectives

Phase 3 validates all controls against ISO 27001, executes DR failover testing, completes UAT with the platform team and CISO, and hands over the platform to Contoso Financial's internal teams. The compliance evidence package produced in this phase is the primary input to the Q2 2026 regulatory review.

### Activities

The following table covers all Phase 3 activities from test plan execution through to hypercare commencement.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Test plan development (Deliverable #18) | Amatra QA | 2 days | Phase 2 complete |
| Functional test execution — account vending, guardrails, federation, SIEM | Amatra QA + Sec Eng | 5 days | Test plan approved |
| ISO 27001 control checklist execution and evidence package compilation | Amatra QA + Sec Eng | 4 days | Functional tests pass |
| DR failover drill — RTO/RPO validation (Deliverable #20) | Amatra Arch + Cloud Eng | 1 day | DR baseline active |
| UAT with platform team (Priya Nair's team + CISO) | Amatra Arch (facilitating) | 3 days (Weeks 14–15) | CISO availability |
| Operational runbook delivery (Deliverable #21) | Amatra Tech Writer | 4 days | All components validated |
| Knowledge transfer sessions (Deliverable #22, 4 sessions) | Amatra Arch + Sec Eng | 2 days (Week 16) | Runbooks delivered |
| Administrator training sessions (Deliverable #23) | Amatra Eng + Sec Eng | 2 days (Week 16) | Training materials ready |
| Platform Optimisation Roadmap (Deliverable #24) | Amatra Arch | 1 day | Project closeout |
| Project Closeout Report (Deliverable #25) | Amatra PM | 1 day | All deliverables accepted |
| Hypercare commencement — 8-week support period begins | Amatra PM + Delivery Team | — | M9 Go-Live |

### Deliverables

- [ ] Test Plan accepted by Rachel Moore (Deliverable #18, Week 13)
- [ ] Test Results & Compliance Evidence Package accepted by CISO (Deliverable #19, Week 15)
- [ ] DR Failover Test Report accepted by CISO (Deliverable #20, Week 15)
- [ ] Operational Runbook Suite accepted by Priya Nair (Deliverable #21, Week 15)
- [ ] Knowledge Transfer Sessions delivered and recorded (Deliverable #22, Week 16)
- [ ] Administrator Training Sessions delivered (Deliverable #23, Week 16)
- [ ] Platform Optimisation Roadmap accepted by James Wu (Deliverable #24, Week 16)
- [ ] Project Closeout Report accepted by Rachel Moore (Deliverable #25, Week 16)

### Success Criteria

- All functional test cases passed; no outstanding CRITICAL defects
- DR failover drill achieves RTO < 4 hours and RPO < 1 hour (measured and documented)
- CISO written sign-off obtained (M8)
- ISO 27001 compliance evidence package validated and accepted by CISO before regulatory review
- Platform team self-sufficient after knowledge transfer; all runbooks dry-run validated

---

# Infrastructure Deployment

This section provides the authoritative deployment procedures for all infrastructure components of the AWS Cloud Governance Platform. Each subsection covers a specific infrastructure layer and must be executed in the order presented: Networking first, then Security, then Compute, then Monitoring. All deployments are managed through the Terraform Cloud GitOps pipeline and require an approved ITSM change record before execution.

## Networking

The network layer establishes the hub-and-spoke Transit Gateway topology, Network Account VPC, AWS Network Firewall, Direct Connect termination, and VPC endpoints that all other platform components depend on.

### Components

The following table lists all networking components deployed in the Network Account across both regions.

| Component | Type | Region | Purpose |
|-----------|------|--------|---------|
| Transit Gateway (Primary) | AWS Transit Gateway | ap-southeast-2 | Central hub for inter-account and on-premises routing |
| Transit Gateway (DR) | AWS Transit Gateway | ap-southeast-4 | DR connectivity; activated during failover |
| Network Account VPC | AWS VPC (10.0.0.0/24) | ap-southeast-2 | Inspection VPC hosting Network Firewall and NAT Gateways |
| AWS Network Firewall | Stateful Firewall (2 AZs) | ap-southeast-2 | East-west traffic inspection and egress filtering |
| NAT Gateway (×2) | AWS NAT Gateway | ap-southeast-2 (2 AZs) | Outbound internet for patch management (Systems Manager) |
| Direct Connect Gateway | AWS DXGW | Global | Connects both Direct Connect circuits to Transit Gateway |
| Direct Connect (Primary) | 1 Gbps hosted connection | ap-southeast-2 | Private DC-to-AWS connectivity; MACsec encrypted |
| Direct Connect (DR) | 1 Gbps hosted connection | ap-southeast-4 | DR DC-to-AWS connectivity; MACsec encrypted |
| Site-to-Site VPN | IPSec VPN | ap-southeast-2 + ap-southeast-4 | Backup path for management and federation traffic |
| VPC Endpoints (×8 services) | Interface VPC Endpoints | ap-southeast-2 | S3, SSM, SSMMessages, EC2Messages, KMS, SecretsManager, Config, CloudTrail |

### Script Location

All networking IaC is located in the Git repository under:

```
cntso-governance-platform/
  infrastructure/
    network/
      main.tf           # Transit Gateway, VPC, firewall, Direct Connect
      variables.tf      # CIDR allocations, region configuration
      outputs.tf        # TGW IDs, VPC endpoints exported for cross-module reference
      backend.tf        # Terraform Cloud backend configuration
    envs/
      prod.tfvars       # Production network parameters
      nonprod.tfvars    # Non-production network parameters
```

The Terraform Cloud workspace name is `cntso-network-vpc-apse2` for the primary region and `cntso-network-vpc-apse4` for the DR region.

### Deployment Steps

All network deployment steps must be executed following an approved ITSM change record. The steps below deploy the primary region network infrastructure.

```bash
# Step 1: Navigate to the network infrastructure directory
cd infrastructure/network

# Step 2: Initialise Terraform with the production backend
terraform init -backend-config=backend-prod.tfvars

# Step 3: Validate the Terraform configuration
terraform validate

# Step 4: Generate and review the deployment plan
terraform plan -var-file=envs/prod.tfvars -out=network-prod.plan

# Step 5: Apply after ITSM change record is approved (confirm change ID)
# Replace CHG0012345 with the actual ITSM change record number
export ITSM_CHANGE_ID="CHG0012345"
echo "Deploying under ITSM change: ${ITSM_CHANGE_ID}"
terraform apply network-prod.plan

# Step 6: Export outputs for use by downstream modules
terraform output -json > ../outputs/network-prod-outputs.json

# Step 7: Configure MACsec on Direct Connect connections (after circuits provisioned)
aws directconnect associate-mac-sec-key \
  --connection-id dxcon-XXXXXXXX \
  --ckn $(aws secretsmanager get-secret-value \
    --secret-id cntso-dx-macsec-ckn \
    --query 'SecretString' --output text) \
  --cak $(aws secretsmanager get-secret-value \
    --secret-id cntso-dx-macsec-cak \
    --query 'SecretString' --output text)
```

For the DR region Transit Gateway, repeat the above steps using workspace `cntso-network-vpc-apse4` and `envs/dr.tfvars`.

### Validation

After deployment, run the following validation commands to confirm network infrastructure health.

```bash
# Verify Transit Gateway is active
aws ec2 describe-transit-gateways \
  --region ap-southeast-2 \
  --filters Name=state,Values=available \
  --query 'TransitGateways[0].{Id:TransitGatewayId,State:State,OwnerId:OwnerId}'

# Verify Network Firewall status in both AZs
aws network-firewall describe-firewall \
  --firewall-name cntso-network-firewall-apse2 \
  --query 'FirewallStatus.Status'

# Verify Direct Connect BGP session state
aws directconnect describe-virtual-interfaces \
  --query 'virtualInterfaces[*].{Name:virtualInterfaceName,BGP:bgpPeers[0].bgpStatus}'

# Confirm VPC endpoints are available in all workload accounts
aws ec2 describe-vpc-endpoints \
  --filters Name=state,Values=available \
  --query 'VpcEndpoints[*].{Service:ServiceName,State:State}' \
  --region ap-southeast-2

# Test outbound internet through NAT Gateway (SSM patch traffic simulation)
aws ec2 describe-nat-gateways \
  --filter Name=state,Values=available \
  --query 'NatGateways[*].{Id:NatGatewayId,State:State,SubnetId:SubnetId}'
```

**Expected Output (Transit Gateway):**
```json
{
    "Id": "tgw-0a1b2c3d4e5f67890",
    "State": "available",
    "OwnerId": "123456789012"
}
```

### Success Criteria

- [ ] Transit Gateway in ap-southeast-2 reports state `available`
- [ ] Transit Gateway in ap-southeast-4 reports state `available`
- [ ] Both Direct Connect BGP sessions report state `up`
- [ ] Network Firewall deployed across 2 AZs (ap-southeast-2a and ap-southeast-2b) with state `READY`
- [ ] All 8 VPC endpoint services available in the Network Account VPC
- [ ] NAT Gateways (×2) available in ap-southeast-2a and ap-southeast-2b
- [ ] MACsec association confirmed on both Direct Connect hosted connections
- [ ] Route tables verified: workload accounts route internet-bound traffic through Network Account; no direct Internet Gateways in workload VPCs
- [ ] Site-to-Site VPN backup path confirmed by testing failover with BGP session down simulation

### Rollback

In the event networking deployment must be rolled back, the procedure is:

```bash
# Rollback Step 1: Detach all TGW attachments before destruction
aws ec2 delete-transit-gateway-vpc-attachment \
  --transit-gateway-attachment-id tgw-attach-XXXXXXXX

# Rollback Step 2: Destroy network infrastructure via Terraform
cd infrastructure/network
terraform destroy -var-file=envs/prod.tfvars -auto-approve

# Rollback Step 3: Verify no TGW, Firewall, or VPC endpoint resources remain
aws ec2 describe-transit-gateways \
  --filters Name=state,Values=available

# Rollback Step 4: Update ITSM change record with rollback status
echo "Rollback complete. Update ITSM change ${ITSM_CHANGE_ID} with rollback outcome."
```

Rollback is typically only required if a CIDR conflict is identified post-deployment or if the Direct Connect circuits are not provisioned within the Phase 2 window. In that case, the site-to-site VPN provides a temporary connectivity path without TGW, and network deployment can be retried in the following change window.

---

## Security

The security layer deploys all IAM Identity Center federation configuration, Service Control Policies, AWS Config conformance packs, AWS Secrets Manager secrets, and KMS keys that enforce the platform's preventive and detective guardrail posture.

### Components

The following table lists all security components deployed across the governance platform accounts.

| Component | Account | Type | Purpose |
|-----------|---------|------|---------|
| IAM Identity Center | Security Account | AWS IAM Identity Center | Federated SSO with on-premises IdP via SAML 2.0 |
| SAML 2.0 Connector | Security Account | IAM Identity Center IdP | Connects on-premises enterprise directory |
| Permission Sets (×4) | Security Account | IAM Identity Center | Developer, PlatformOperator, SecurityViewer, BreakGlass |
| SCP: Deny Console Access | Management Account | AWS Organizations SCP | Blocks IAM user creation and console sign-in in production OUs |
| SCP: Region Lock | Management Account | AWS Organizations SCP | Restricts all services to ap-southeast-2 and ap-southeast-4 |
| SCP: Enforce Encryption | Management Account | AWS Organizations SCP | Mandates KMS encryption for S3 objects and EBS volumes |
| Config Conformance Pack | Audit Account | AWS Config | ISO 27001 Annex A (~80 rules) + internal security baseline rules |
| KMS CMK — Log Archive | Log Archive Account | AWS KMS | Encrypts CloudTrail and Config S3 logs |
| KMS CMK — Terraform State | Management Account | AWS KMS | Encrypts Terraform state S3 bucket |
| KMS CMK — AFT DynamoDB | Management Account | AWS KMS | Encrypts AFT workflow state table |
| Secrets Manager — SIEM Key | Audit Account | AWS Secrets Manager | Stores SIEM API Bearer token; 90-day rotation |
| Secrets Manager — ITSM OAuth | Management Account | AWS Secrets Manager | Stores ITSM OAuth 2.0 client secret; 90-day rotation |
| Auto-Remediation Lambdas | Audit Account | AWS Lambda | Triggered by Config non-compliant events for defined low-risk deviations |

### Script Location

All security IaC modules are located in:

```
cntso-governance-platform/
  infrastructure/
    security/
      scps/
        deny-console-access.tf     # Production OU SCP
        region-lock.tf             # ap-southeast-2/4 only SCP
        enforce-encryption.tf      # KMS encryption mandate SCP
      iam-identity-center/
        main.tf                    # IAM Identity Center configuration
        permission-sets.tf         # Developer, Operator, SecurityViewer, BreakGlass
        idp-connector.tf           # SAML 2.0 IdP connector
      config/
        conformance-pack-iso27001.tf  # ISO 27001 Config rules
        custom-rules-baseline.tf      # Internal security baseline rules
        auto-remediation.tf           # Lambda remediation functions
      kms/
        main.tf                    # KMS CMKs for all platform encryption
      secrets/
        main.tf                    # Secrets Manager secrets (placeholders; values injected post-deploy)
```

Terraform Cloud workspaces: `cntso-management-scps`, `cntso-security-iam-idc`, `cntso-audit-config`, `cntso-management-kms`.

### Deployment Steps

Security deployment must follow a defined sequence: KMS keys first, then Secrets Manager (empty), then IAM Identity Center, then SCPs, then Config rules.

```bash
# --- Step 1: Deploy KMS keys ---
cd infrastructure/security/kms
terraform init -backend-config=backend-prod.tfvars
terraform plan -var-file=envs/prod.tfvars -out=kms.plan
terraform apply kms.plan

# Enable annual key rotation on all CMKs
for KEY_ARN in $(terraform output -json kms_key_arns | jq -r '.[]'); do
  aws kms enable-key-rotation --key-id "${KEY_ARN}"
  echo "Rotation enabled: ${KEY_ARN}"
done

# --- Step 2: Create Secrets Manager secrets (placeholder values) ---
cd ../secrets
terraform init -backend-config=backend-prod.tfvars
terraform apply -var-file=envs/prod.tfvars -auto-approve

# Populate SIEM API key after receiving credentials from SIEM team
aws secretsmanager put-secret-value \
  --secret-id cntso-siem-api-key-prod \
  --secret-string "$(echo '{"api_key":"<SIEM_KEY_FROM_SIEM_ADMIN>"}' | \
    aws kms encrypt --key-id alias/cntso-log-archive-apse2 \
    --plaintext fileb:///dev/stdin --output text --query CiphertextBlob)"

# --- Step 3: Configure IAM Identity Center ---
cd ../iam-identity-center
terraform init -backend-config=backend-security.tfvars
terraform plan -var-file=envs/prod.tfvars -out=idc.plan
terraform apply idc.plan

# Verify SAML metadata is correctly registered
aws sso-admin list-instances \
  --query 'Instances[0].{InstanceArn:InstanceArn,IdentityStoreId:IdentityStoreId}'

# --- Step 4: Deploy SCPs ---
cd ../scps
terraform init -backend-config=backend-management.tfvars
terraform plan -var-file=envs/prod.tfvars -out=scps.plan
terraform apply scps.plan

# Verify SCPs are attached to production OU
aws organizations list-policies-for-target \
  --target-id $(aws organizations list-organizational-units-for-parent \
    --parent-id r-XXXX \
    --query "OrganizationalUnits[?Name=='Production'].Id" --output text) \
  --filter SERVICE_CONTROL_POLICY \
  --query 'Policies[*].{Name:Name,Id:Id}'

# --- Step 5: Deploy Config conformance packs ---
cd ../config
terraform init -backend-config=backend-audit.tfvars
terraform plan -var-file=envs/prod.tfvars -out=config.plan
terraform apply config.plan
```

### Validation

After security component deployment, validate each layer as follows.

```bash
# Validate SCP effectiveness — attempt blocked action (expect AccessDenied)
aws iam create-user --user-name test-blocked-user \
  --profile cntso-prod-workload-1
# Expected: An error occurred (AccessDenied) — SCP deny in effect

# Validate region lock SCP — attempt to launch resource in forbidden region
aws ec2 run-instances \
  --image-id ami-XXXXXXXX \
  --instance-type t3.micro \
  --region us-east-1 \
  --profile cntso-prod-workload-1
# Expected: An error occurred (AccessDenied) — region lock SCP deny in effect

# Validate IAM Identity Center federation — test SSO login flow
aws sso list-account-assignments \
  --instance-arn arn:aws:sso:::instance/ssoins-XXXXXXXX \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --permission-set-arn arn:aws:sso:::permissionSet/ssoins-XXXXXXXX/ps-XXXXXXXX

# Validate Config rules are evaluating
aws configservice describe-compliance-by-config-rule \
  --compliance-types NON_COMPLIANT COMPLIANT \
  --query 'ComplianceByConfigRules[0:5].{Rule:ConfigRuleName,Compliance:Compliance.ComplianceType}'

# Validate KMS key rotation is enabled
aws kms describe-key \
  --key-id alias/cntso-log-archive-apse2 \
  --query 'KeyMetadata.{KeyState:KeyState,KeyUsage:KeyUsage}'
aws kms get-key-rotation-status \
  --key-id alias/cntso-log-archive-apse2 \
  --query 'KeyRotationEnabled'
```

**Expected KMS Validation Output:**
```json
{
    "KeyState": "Enabled",
    "KeyUsage": "ENCRYPT_DECRYPT"
}
true
```

### Success Criteria

- [ ] All three SCPs (deny-console-access, region-lock, enforce-encryption) attached to correct OUs
- [ ] Test IAM user creation attempt in production account returns `AccessDenied`
- [ ] Test resource creation in non-AU region returns `AccessDenied`
- [ ] IAM Identity Center SAML connector shows status `Active`; test SSO login for all 4 permission set roles passes
- [ ] Config conformance pack deployed with all ~80 rules in `ACTIVE` evaluation status
- [ ] All KMS CMKs in `ENABLED` state with annual key rotation active
- [ ] Secrets Manager secrets created with correct ARNs; SIEM and ITSM credentials populated and accessible only by designated Lambda execution roles
- [ ] Zero shared IAM user credentials remain in any new account after IAM Identity Center activation
- [ ] Auto-remediation Lambda functions deployed and functional (test trigger with deliberate non-compliant S3 bucket in test account)

### Rollback

Security rollback follows a tiered approach depending on which component is being rolled back.

```bash
# SCP Rollback — remove console-access deny SCP from production OU (break-glass path)
# This is the primary rollback action if production workloads are disrupted
aws organizations detach-policy \
  --policy-id p-XXXXXXXX \
  --target-id ou-XXXX-XXXXXXXX
echo "SCP removed. Production console access restored within ~5 minutes."

# Config Rules Rollback — delete conformance pack
aws configservice delete-conformance-pack \
  --conformance-pack-name cntso-iso27001-org

# IAM Identity Center Rollback — disable external IdP connector
# (only required if federation is causing login failures)
aws sso-admin update-instance-access-control-attribute-configuration \
  --instance-arn arn:aws:sso:::instance/ssoins-XXXXXXXX \
  --instance-access-control-attribute-configuration AccessControlAttributes=[]

# Document rollback in ITSM change record and notify CISO immediately
```

Full Terraform-based rollback (to restore previous state version):

```bash
cd infrastructure/security/scps
# Retrieve prior state version from S3
aws s3 cp s3://cntso-tf-state-prod/security/scps/terraform.tfstate.backup ./
terraform state push terraform.tfstate.backup
terraform apply -var-file=envs/prod.tfvars -auto-approve
```

---

## Compute

The compute layer deploys all Lambda functions (SIEM forwarding, ITSM integration, Config auto-remediation, AFT pipeline support functions) and any Systems Manager-managed platform instances required for the governance platform. The architecture is serverless-first; all compute is Lambda-based with the exception of NAT Gateways (deployed in the Networking layer) and Network Firewall (also Networking layer).

### Components

The following table lists all compute resources in the governance platform.

| Component | Type | Memory | Concurrency | Account | Purpose |
|-----------|------|--------|-------------|---------|---------|
| SIEM Forwarding Lambda | AWS Lambda | 1,024 MB | Reserved: 10 | Audit Account | Transforms and delivers Security Hub findings to SIEM API |
| ITSM Integration Lambda | AWS Lambda | 512 MB | Reserved: 5 | Management Account | Polls ITSM for change-approval; posts provisioning status back |
| Config Auto-Remediation Lambda | AWS Lambda | 512 MB | Max: 20 | Audit Account | Triggered by Config non-compliant events; remediates defined deviations |
| AFT Pipeline Lambda (vending) | AWS Lambda | 3,008 MB | Max: 10 | Management Account | Executes account provisioning steps; applies AFT baseline |
| CloudTrail SIEM Lambda | AWS Lambda | 512 MB | Reserved: 5 | Audit Account | Forwards selected high-risk CloudTrail events to SIEM |
| Platform Instances (if any) | t3.medium (SSM-managed) | 4 GB RAM | N/A | Network Account | Only if network appliance functions cannot be fully serverless |

### Script Location

All compute IaC is located in:

```
cntso-governance-platform/
  infrastructure/
    compute/
      lambda/
        siem-forward/
          main.tf              # Lambda function, IAM role, EventBridge trigger
          siem_forward.py      # Lambda function code
          requirements.txt     # Python dependencies
        itsm-integration/
          main.tf              # Lambda function, IAM role, SQS DLQ
          itsm_integration.py  # Lambda function code
        config-remediation/
          main.tf              # Lambda function per remediation type
          remediation.py       # Remediation logic (scoped to governance resources only)
        aft-pipeline/
          main.tf              # AFT pipeline Lambda customisation hooks
```

Terraform Cloud workspace: `cntso-audit-compute`, `cntso-management-compute`.

### Deployment Steps

Lambda deployments are packaged and deployed via the Terraform CI/CD pipeline. The following steps apply to all Lambda functions.

```bash
# Step 1: Package the SIEM forwarding Lambda
cd infrastructure/compute/lambda/siem-forward
pip install -r requirements.txt -t ./package/
cp siem_forward.py ./package/
cd package && zip -r ../siem-forward.zip . && cd ..

# Step 2: Upload Lambda package to deployment S3 bucket
aws s3 cp siem-forward.zip \
  s3://cntso-lambda-deploy-prod/siem-forward/v1.0.0/siem-forward.zip

# Step 3: Deploy Lambda function via Terraform
cd ../../..  # back to infrastructure/compute
terraform init -backend-config=backend-audit.tfvars
terraform plan -var-file=envs/prod.tfvars -out=compute.plan
terraform apply compute.plan

# Step 4: Set reserved concurrency for SIEM forwarding Lambda
aws lambda put-function-concurrency \
  --function-name cntso-siem-forward-eventbridge \
  --reserved-concurrent-executions 10

# Step 5: Set reserved concurrency for ITSM integration Lambda
aws lambda put-function-concurrency \
  --function-name cntso-itsm-integration-prod \
  --reserved-concurrent-executions 5

# Step 6: Enable X-Ray tracing on integration Lambda functions
aws lambda update-function-configuration \
  --function-name cntso-siem-forward-eventbridge \
  --tracing-config Mode=Active
aws lambda update-function-configuration \
  --function-name cntso-itsm-integration-prod \
  --tracing-config Mode=Active

# Step 7: Deploy EventBridge rule triggering SIEM forwarding Lambda
aws events put-rule \
  --name cntso-securityhub-critical-high \
  --event-pattern '{
    "source": ["aws.securityhub"],
    "detail-type": ["Security Hub Findings - Imported"],
    "detail": {
      "findings": {
        "Severity": {
          "Label": ["CRITICAL", "HIGH"]
        }
      }
    }
  }' \
  --state ENABLED
```

### Validation

After compute deployment, validate all Lambda functions with live test invocations.

```bash
# Test SIEM forwarding Lambda with a synthetic finding payload
aws lambda invoke \
  --function-name cntso-siem-forward-eventbridge \
  --payload file://tests/synthetic-finding.json \
  --log-type Tail \
  --query 'LogResult' \
  --output text response-siem.json | base64 -d

# Verify SIEM received the test finding (check SIEM console or use SIEM query API)
echo "Verify test finding appeared in SIEM within 5 minutes"

# Test ITSM integration Lambda — poll for a test change record
aws lambda invoke \
  --function-name cntso-itsm-integration-prod \
  --payload '{"change_id": "CHG-TEST-001", "action": "poll_approval"}' \
  response-itsm.json
cat response-itsm.json

# Test Config auto-remediation Lambda — create non-compliant S3 bucket in test account
aws s3api create-bucket \
  --bucket cntso-test-remediation-$(date +%s) \
  --region ap-southeast-2 \
  --profile cntso-nonprod-test
# Wait for Config evaluation (≤ 60 seconds), then verify remediation fired
sleep 90
aws configservice get-compliance-details-by-config-rule \
  --config-rule-name cntso-s3-encryption-required \
  --compliance-types NON_COMPLIANT

# Verify CloudWatch X-Ray traces for SIEM Lambda
aws xray get-service-graph \
  --start-time $(date -u -d '5 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --query 'Services[?Name==`cntso-siem-forward-eventbridge`]'
```

**Expected Lambda Test Output:**
```json
{"statusCode": 200, "body": "Finding delivered to SIEM: 1 event(s) processed"}
```

### Success Criteria

- [ ] SIEM forwarding Lambda invokes successfully; test CRITICAL finding appears in on-premises SIEM within 5 minutes
- [ ] ITSM integration Lambda polls successfully; approval status returned within 2-minute interval
- [ ] Config auto-remediation Lambda triggers within 90 seconds of deliberate non-compliant resource creation in test account
- [ ] AFT pipeline Lambda functions execute without error on a test account vending request
- [ ] X-Ray traces show end-to-end latency for SIEM Lambda consistently below 30-second timeout
- [ ] Reserved concurrency set correctly (SIEM: 10, ITSM: 5) and confirmed via AWS Console
- [ ] SQS DLQ depth is 0 after all test invocations (no failed deliveries)
- [ ] CloudWatch Logs groups created for all Lambda functions with 90-day retention configured

### Rollback

Lambda rollback is performed by reverting to the previous function version.

```bash
# Identify the previous Lambda version
aws lambda list-versions-by-function \
  --function-name cntso-siem-forward-eventbridge \
  --query 'Versions[*].{Version:Version,LastModified:LastModified}'

# Update the Lambda alias to point to the prior version
aws lambda update-alias \
  --function-name cntso-siem-forward-eventbridge \
  --name live \
  --function-version 1

# Alternatively, roll back the entire compute workspace via Terraform state
cd infrastructure/compute
terraform state list
# Restore prior state version from versioned S3 bucket
aws s3 cp s3://cntso-tf-state-prod/compute/terraform.tfstate.backup ./
terraform state push terraform.tfstate.backup
terraform apply -var-file=envs/prod.tfvars -auto-approve
```

---

## Monitoring

The monitoring layer deploys all CloudWatch dashboards, metric alarms, SNS notification topics, and AWS X-Ray configurations that provide the platform team with real-time visibility into platform health, guardrail compliance trends, and security finding volumes.

### Components

The following table lists all monitoring resources deployed across the governance platform accounts.

| Component | Account | Type | Purpose |
|-----------|---------|------|---------|
| Platform Operations Dashboard | Management Account | CloudWatch Dashboard | AFT pipeline health, Config compliance trends, Security Hub finding volumes |
| Identity & Access Dashboard | Security Account | CloudWatch Dashboard | IAM Identity Center login events, permission set assignments, break-glass usage |
| DR & Replication Dashboard | Log Archive Account | CloudWatch Dashboard | S3 CRR lag, Direct Connect BGP state, DR region Config aggregation health |
| P1 Alarms (×8) | Audit + Management | CloudWatch Alarms | AFT pipeline failure, SIEM DLQ depth, CRR lag, BGP state, break-glass usage, CloudTrail gap, GuardDuty disabled, Config evaluation errors |
| SNS Alert Topic | Audit Account | Amazon SNS | Routes P1 and P2 alarms to on-call platform engineer |
| Log Archive Alarm | Log Archive Account | CloudWatch Alarm | Fires if no CloudTrail log delivered for > 30 minutes (evidence continuity risk) |
| S3 CRR Replication Lag Alarm | Log Archive Account | CloudWatch Alarm | Fires if replication lag to ap-southeast-4 exceeds 1 hour (RPO breach risk) |
| GuardDuty Enabled Alarm | Audit Account | CloudWatch Alarm | Fires on `DeleteDetector` CloudTrail event (SCP should block; alarm is defence-in-depth) |
| X-Ray Tracing | Audit Account | AWS X-Ray | End-to-end latency traces for SIEM and ITSM Lambda functions |

### Script Location

All monitoring IaC is located in:

```
cntso-governance-platform/
  infrastructure/
    monitoring/
      dashboards/
        platform-ops-dashboard.tf       # Platform Operations CloudWatch Dashboard JSON
        identity-dashboard.tf           # Identity & Access CloudWatch Dashboard JSON
        dr-replication-dashboard.tf     # DR & Replication CloudWatch Dashboard JSON
      alarms/
        p1-alarms.tf                    # All P1 priority CloudWatch alarms
        p2-alarms.tf                    # All P2 priority CloudWatch alarms
      sns/
        main.tf                         # SNS topic and email subscription
      log-exports/
        main.tf                         # Scheduled CloudWatch Logs → S3 export tasks
```

Terraform Cloud workspace: `cntso-audit-monitoring`.

### Deployment Steps

Deploy monitoring after all Networking, Security, and Compute layers are live so that alarms reference actual resource names and ARNs.

```bash
# Step 1: Deploy SNS topic and subscriptions first
cd infrastructure/monitoring/sns
terraform init -backend-config=backend-audit.tfvars
terraform plan -var-file=envs/prod.tfvars -out=sns.plan
terraform apply sns.plan

# Confirm on-call platform engineer email subscription
SNS_TOPIC_ARN=$(terraform output -raw sns_alert_topic_arn)
echo "SNS Topic ARN: ${SNS_TOPIC_ARN}"
echo "Confirm the subscription email sent to the on-call engineer inbox"

# Step 2: Deploy CloudWatch alarms
cd ../alarms
terraform init -backend-config=backend-audit.tfvars
terraform plan -var-file=envs/prod.tfvars -out=alarms.plan
terraform apply alarms.plan

# Step 3: Deploy CloudWatch dashboards
cd ../dashboards
terraform init -backend-config=backend-management.tfvars
terraform plan -var-file=envs/prod.tfvars -out=dashboards.plan
terraform apply dashboards.plan

# Step 4: Configure nightly CloudWatch Logs → S3 export tasks
cd ../log-exports
terraform init -backend-config=backend-audit.tfvars
terraform apply -var-file=envs/prod.tfvars -auto-approve

# Step 5: Set CloudWatch Log Group retention to 90 days for all platform groups
for LOG_GROUP in $(aws logs describe-log-groups \
  --log-group-name-prefix "/aws/lambda/cntso" \
  --query 'logGroups[*].logGroupName' --output text); do
  aws logs put-retention-policy \
    --log-group-name "${LOG_GROUP}" \
    --retention-in-days 90
  echo "Retention set: ${LOG_GROUP}"
done

# Step 6: Validate S3 CRR replication lag alarm threshold
aws cloudwatch put-metric-alarm \
  --alarm-name "cntso-crr-replication-lag-p1" \
  --alarm-description "S3 CRR replication lag to ap-southeast-4 exceeds 1 hour — RPO at risk" \
  --metric-name ReplicationLatency \
  --namespace AWS/S3 \
  --dimensions Name=SourceBucket,Value=cntso-log-archive-cloudtrail-apse2 \
               Name=DestinationBucket,Value=cntso-log-archive-cloudtrail-apse4 \
               Name=RuleId,Value=cntso-crr-rule \
  --statistic Maximum \
  --period 3600 \
  --evaluation-periods 1 \
  --threshold 3600 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions "${SNS_TOPIC_ARN}"
```

### Validation

After monitoring deployment, validate that all alarms are in the correct state and that dashboards are populating with live data.

```bash
# Verify all P1 alarms are in OK or INSUFFICIENT_DATA state (not ALARM) after deployment
aws cloudwatch describe-alarms \
  --alarm-names \
    "cntso-aft-pipeline-failure-p1" \
    "cntso-siem-dlq-depth-p1" \
    "cntso-crr-replication-lag-p1" \
    "cntso-dx-bgp-state-p1" \
    "cntso-breakglass-assumption-p1" \
    "cntso-cloudtrail-delivery-gap-p1" \
    "cntso-guardduty-disabled-p1" \
  --query 'MetricAlarms[*].{Name:AlarmName,State:StateValue}'

# Test SNS alarm notification by triggering a test state change
aws cloudwatch set-alarm-state \
  --alarm-name "cntso-aft-pipeline-failure-p1" \
  --state-value ALARM \
  --state-reason "Test notification for on-call engineer validation"
echo "Check on-call engineer inbox for SNS notification"
# Reset alarm state
aws cloudwatch set-alarm-state \
  --alarm-name "cntso-aft-pipeline-failure-p1" \
  --state-value OK \
  --state-reason "Test complete"

# Verify CloudWatch dashboards are visible
aws cloudwatch list-dashboards \
  --dashboard-name-prefix "cntso-" \
  --query 'DashboardEntries[*].{Name:DashboardName,LastModified:LastModified}'

# Validate S3 export scheduled tasks
aws logs describe-export-tasks \
  --status-filter COMPLETED \
  --query 'exportTasks[0:3].{Name:taskName,Status:status,Destination:destination}'
```

**Expected Alarm Validation Output:**
```json
[
    {"Name": "cntso-aft-pipeline-failure-p1", "State": "OK"},
    {"Name": "cntso-siem-dlq-depth-p1", "State": "OK"},
    {"Name": "cntso-crr-replication-lag-p1", "State": "OK"}
]
```

### Success Criteria

- [ ] All three CloudWatch dashboards (`cntso-platform-operations`, `cntso-identity-access`, `cntso-dr-replication`) visible and populating with live metrics
- [ ] All 8 P1 alarms in `OK` or `INSUFFICIENT_DATA` state after baseline deployment
- [ ] SNS test notification received by on-call platform engineer inbox within 2 minutes
- [ ] CRR replication lag alarm threshold set at 3,600 seconds (1 hour); current lag < 300 seconds (healthy baseline)
- [ ] CloudWatch Log Group retention set to 90 days for all `/aws/lambda/cntso/*` groups
- [ ] Nightly S3 export tasks scheduled and confirmed (first export run completed)
- [ ] X-Ray service map shows SIEM and ITSM Lambda traces; p95 latency < 5,000 ms
- [ ] Direct Connect BGP state alarm triggers within 60 seconds of BGP session state change (tested in failover simulation)

### Rollback

Monitoring rollback is low-risk; it involves disabling alarms rather than removing infrastructure.

```bash
# Disable all P1 alarms if they are generating false-positive noise during tuning
aws cloudwatch disable-alarm-actions \
  --alarm-names \
    "cntso-aft-pipeline-failure-p1" \
    "cntso-siem-dlq-depth-p1" \
    "cntso-crr-replication-lag-p1"

# Rollback dashboard to prior version via Terraform state
cd infrastructure/monitoring/dashboards
terraform state pull > dashboards-current.tfstate
aws s3 cp s3://cntso-tf-state-prod/monitoring/dashboards/terraform.tfstate.backup ./
terraform state push terraform.tfstate.backup
terraform apply -var-file=envs/prod.tfvars -auto-approve
```

Full monitoring rollback (destroy and redeploy) is performed via `terraform destroy` followed by re-deploy. No data is lost as dashboards and alarms do not store persistent data. All alarm thresholds and dashboard definitions are captured in IaC.

---

# Application Configuration

## IAM Identity Center Permission Sets

IAM Identity Center permission sets define what each user role can do in AWS. All permission sets are deployed via IaC and cannot be modified via the console.

The following YAML defines the Developer permission set boundaries:

```yaml
# permission-sets/developer.yaml
name: Developer
description: "Read-only access to own workload account resources. No IAM modifications. No production access."
session_duration: PT1H
managed_policies:
  - arn:aws:iam::aws:policy/ReadOnlyAccess
inline_policy: |
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Deny",
        "Action": [
          "iam:*",
          "organizations:*",
          "account:*"
        ],
        "Resource": "*"
      }
    ]
  }
```

To deploy permission sets via the CLI after IaC deployment:

```bash
# Verify permission sets are deployed correctly
aws sso-admin list-permission-sets \
  --instance-arn arn:aws:sso:::instance/ssoins-XXXXXXXX \
  --query 'PermissionSets'

# Assign the Developer permission set to the on-premises dev group
aws sso-admin create-account-assignment \
  --instance-arn arn:aws:sso:::instance/ssoins-XXXXXXXX \
  --target-id WORKLOAD_ACCOUNT_ID \
  --target-type AWS_ACCOUNT \
  --permission-set-arn arn:aws:sso:::permissionSet/ssoins-XXXXXXXX/ps-dev-XXXXXXXX \
  --principal-type GROUP \
  --principal-id ONPREM_DEV_GROUP_ID
```

## AFT Pipeline Configuration

The AFT pipeline configuration is managed via Terraform Cloud workspace variables and the AFT account customisation framework. Key parameters from `configuration.csv` are referenced in the deployment below.

```hcl
# aft-config/main.tf — AFT pipeline core configuration
module "aft" {
  source = "github.com/aws-ia/terraform-aws-control_tower_account_factory"

  ct_management_account_id    = var.aws_account_id_management
  log_archive_account_id      = var.aws_account_id_log_archive
  audit_account_id            = var.aws_account_id_audit
  aft_management_account_id   = var.aws_account_id_management
  ct_home_region              = "ap-southeast-2"
  tf_backend_secondary_region = "ap-southeast-4"

  aft_feature_cloudtrail_data_events  = true
  aft_feature_enterprise_support      = true
  aft_feature_delete_default_vpcs_enabled = true

  concurrent_account_vend_limit = 5  # matches aft.pipeline.max_concurrent_requests

  # ITSM integration — approval required before pipeline executes
  itsm_approval_required = true
  itsm_api_endpoint_ssm_path = "/cntso/itsm/api_endpoint"
}
```

## Environment Variable Configuration

The following environment variables are required for the Lambda integration functions. All secret values are stored in AWS Secrets Manager; only non-secret values are stored as Lambda environment variables.

| Variable | Lambda Function | Value | Source |
|----------|-----------------|-------|--------|
| `SIEM_API_ENDPOINT` | cntso-siem-forward-eventbridge | `https://siem.contoso.internal/api/v1/events` | Secrets Manager |
| `SIEM_DELIVERY_SLA_MINUTES` | cntso-siem-forward-eventbridge | `5` | Environment variable |
| `ITSM_API_ENDPOINT` | cntso-itsm-integration-prod | `https://itsm.contoso.internal/api/v2` | Secrets Manager |
| `ITSM_POLL_INTERVAL_SECONDS` | cntso-itsm-integration-prod | `120` | Environment variable |
| `LOG_LEVEL` | All Lambda functions | `info` (prod) / `debug` (nonprod) | Environment variable |
| `AWS_DEFAULT_REGION` | All Lambda functions | `ap-southeast-2` | Environment variable |
| `REMEDIATION_SCOPE` | cntso-config-remediation | `governance-only` | Environment variable |

```bash
# Update SIEM forwarding Lambda environment variables
aws lambda update-function-configuration \
  --function-name cntso-siem-forward-eventbridge \
  --environment "Variables={
    SIEM_DELIVERY_SLA_MINUTES=5,
    LOG_LEVEL=info,
    AWS_DEFAULT_REGION=ap-southeast-2,
    SIEM_SECRET_ARN=arn:aws:secretsmanager:ap-southeast-2:AUDIT_ACCOUNT_ID:secret:cntso-siem-api-key-prod
  }"
```

## Security Configuration

All application-layer security controls are configured as follows.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSIEMForwardingLambdaExecution",
      "Effect": "Allow",
      "Action": [
        "securityhub:GetFindings",
        "securityhub:ListFindings",
        "secretsmanager:GetSecretValue",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords",
        "sqs:SendMessage",
        "sqs:GetQueueUrl"
      ],
      "Resource": [
        "arn:aws:securityhub:ap-southeast-2:AUDIT_ACCOUNT_ID:hub/default",
        "arn:aws:secretsmanager:ap-southeast-2:AUDIT_ACCOUNT_ID:secret:cntso-siem-api-key-prod*",
        "arn:aws:logs:ap-southeast-2:AUDIT_ACCOUNT_ID:log-group:/aws/lambda/cntso-siem-forward-eventbridge:*",
        "arn:aws:sqs:ap-southeast-2:AUDIT_ACCOUNT_ID:cntso-siem-forward-dlq-prod"
      ]
    }
  ]
}
```

## Validation Checklist

- [ ] All Lambda function environment variables set correctly per configuration table
- [ ] IAM execution roles follow least-privilege — no wildcard `Resource` in production policies
- [ ] Secrets Manager secret ARNs correctly referenced by Lambda environment variables
- [ ] AFT pipeline `itsm_approval_required = true` confirmed in production workspace
- [ ] Permission sets assigned to correct on-premises directory groups
- [ ] SIEM API endpoint accessible from Audit account Lambda (test `curl` equivalent via Lambda invocation)
- [ ] ITSM API endpoint accessible from Management account Lambda
- [ ] CloudTrail data events enabled on Log Archive S3 bucket

---

# Integration Testing

## SIEM Integration Testing

SIEM integration testing validates that Security Hub findings reach the on-premises SIEM within the 5-minute SLA and that CloudTrail high-risk events are forwarded correctly.

The following test script generates a synthetic Security Hub finding and verifies end-to-end delivery to the SIEM.

```python
# tests/test_siem_integration.py
import boto3
import time
import json
from datetime import datetime, timezone

def create_synthetic_finding(sh_client, account_id, region):
    """Create a synthetic CRITICAL Security Hub finding for SIEM integration test."""
    finding = {
        "SchemaVersion": "2018-10-08",
        "Id": f"arn:aws:securityhub:{region}:{account_id}:finding/test-{datetime.now().isoformat()}",
        "ProductArn": f"arn:aws:securityhub:{region}:{account_id}:product/{account_id}/default",
        "GeneratorId": "cntso-integration-test",
        "AwsAccountId": account_id,
        "Types": ["Software and Configuration Checks/Industry and Regulatory Standards/ISO 27001"],
        "CreatedAt": datetime.now(timezone.utc).isoformat(),
        "UpdatedAt": datetime.now(timezone.utc).isoformat(),
        "Severity": {"Label": "CRITICAL", "Product": 100, "Normalized": 100},
        "Title": "Integration Test: SIEM Forwarding Validation",
        "Description": "Synthetic finding for SIEM forwarding pipeline validation — Phase 3 test",
        "Resources": [{"Type": "AwsAccount", "Id": f"AWS::::Account:{account_id}"}]
    }

    response = sh_client.batch_import_findings(Findings=[finding])
    return response, finding["Id"]

def test_siem_delivery(finding_id, siem_client, max_wait_minutes=5):
    """Poll SIEM for the test finding and confirm delivery within SLA."""
    start = time.time()
    while (time.time() - start) < (max_wait_minutes * 60):
        # Replace with SIEM-specific query API call
        result = siem_client.query(f'finding_id="{finding_id}"')
        if result.get("total_hits", 0) > 0:
            elapsed = time.time() - start
            print(f"Finding delivered to SIEM in {elapsed:.1f} seconds (SLA: {max_wait_minutes * 60}s)")
            return True
        time.sleep(30)
    print(f"FAIL: Finding not received in SIEM within {max_wait_minutes} minutes")
    return False

if __name__ == "__main__":
    import boto3
    sh_client = boto3.client("securityhub", region_name="ap-southeast-2")
    account_id = boto3.client("sts").get_caller_identity()["Account"]
    response, finding_id = create_synthetic_finding(sh_client, account_id, "ap-southeast-2")
    print(f"Test finding created: {finding_id}")
    print(f"Import result: {json.dumps(response, indent=2)}")
```

```bash
# Run SIEM integration test
python3 tests/test_siem_integration.py

# Verify DLQ remains empty after test
aws sqs get-queue-attributes \
  --queue-url https://sqs.ap-southeast-2.amazonaws.com/AUDIT_ACCOUNT_ID/cntso-siem-forward-dlq-prod \
  --attribute-names ApproximateNumberOfMessages \
  --query 'Attributes.ApproximateNumberOfMessages'
```

## ITSM Integration Testing

ITSM integration testing validates the account vending approval workflow from ITSM request creation through AFT pipeline execution.

```bash
# Step 1: Create a test account vending request in ITSM
# (done via ITSM web interface by a platform engineer, or via ITSM API)
CHANGE_ID="CHG-TEST-$(date +%s)"

# Step 2: Verify AFT pipeline detects the request and blocks on approval
aws codepipeline get-pipeline-state \
  --name aws-aft-account-provisioning-pipeline \
  --query 'stageStates[?stageName==`ITSM-Approval`].{Stage:stageName,Status:latestExecution.status}'

# Step 3: Approve the change in ITSM (done by designated approver)
# Step 4: Verify AFT pipeline proceeds after approval
aws codepipeline get-pipeline-state \
  --name aws-aft-account-provisioning-pipeline \
  --query 'stageStates[*].{Stage:stageName,Status:latestExecution.status}'
```

## End-to-End Guardrail Testing

Guardrail testing validates both preventive (SCP) and detective (Config) controls.

```bash
# Test 1: SCP — attempt to disable CloudTrail (must be denied)
aws cloudtrail delete-trail \
  --name arn:aws:cloudtrail:ap-southeast-2:PROD_ACCOUNT_ID:trail/cntso-org-trail \
  --profile cntso-prod-workload-1
# Expected: An error occurred (AccessDenied) — SCP deny in effect

# Test 2: Config — introduce non-compliant S3 bucket; confirm evaluation within 60s
aws s3api create-bucket \
  --bucket cntso-test-unencrypted-$(date +%s) \
  --region ap-southeast-2 \
  --profile cntso-nonprod-test
sleep 90
aws configservice get-compliance-details-by-config-rule \
  --config-rule-name cntso-s3-encryption-required \
  --compliance-types NON_COMPLIANT \
  --query 'EvaluationResults[0].{Resource:EvaluationResultIdentifier.EvaluationResultQualifier.ResourceId,Status:ComplianceType}'

# Test 3: SIEM alert for Config non-compliance
# Confirm a Security Hub finding appeared in SIEM for the above non-compliant bucket
echo "Verify HIGH/CRITICAL finding for S3 encryption in SIEM within 5 minutes"
```

## Integration Test Success Criteria

- [ ] SIEM receives CRITICAL/HIGH Security Hub findings within 5 minutes of finding creation (10 consecutive tests pass)
- [ ] CloudTrail high-risk events (DeleteTrail, CreateUser, AssumeRoleWithSAML) forwarded to SIEM within 5 minutes
- [ ] ITSM approval gate correctly blocks AFT pipeline; pipeline resumes within 2 minutes of approval status change
- [ ] Config rule evaluates non-compliant resource within 60 seconds; Security Hub finding generated within 90 seconds
- [ ] All SCP-blocked actions return `AccessDenied` with no delay; corresponding CloudTrail events visible in Log Archive
- [ ] AFT account vending completes end-to-end (ITSM request → account provisioned with baseline) within 60 minutes
- [ ] SQS DLQ remains at 0 messages throughout all integration tests

---

# Security Validation

## Phase 3 Security Test Execution

Security validation is the formal execution of the test plan (Deliverable #18) by the Amatra QA and Security Engineering team. All tests must pass before the CISO provides go-live sign-off (M8).

### SCP Guardrail Validation

The following quality gate confirms that all preventive controls are effective against the defined blocked actions.

- [ ] `iam:CreateUser` in production account returns `AccessDenied` — SCP cntso-deny-console-access-prod confirmed active
- [ ] `iam:CreateLoginProfile` in production account returns `AccessDenied` — console login blocked
- [ ] `ec2:RunInstances` in `us-east-1` from production account returns `AccessDenied` — region lock confirmed
- [ ] `s3:PutObject` without KMS key specification in production account returns `AccessDenied` — encryption mandate confirmed
- [ ] `cloudtrail:DeleteTrail` returns `AccessDenied` — CloudTrail tamper protection confirmed
- [ ] `config:StopConfigurationRecorder` returns `AccessDenied` — Config tamper protection confirmed

### Detective Control Validation

- [ ] AWS Config rule `cntso-s3-encryption-required` evaluates within 60 seconds of non-compliant bucket creation
- [ ] Security Hub finding generated for Config non-compliance within 90 seconds; severity correctly scored
- [ ] SIEM receives the Security Hub finding within 5 minutes of finding creation
- [ ] Auto-remediation Lambda triggered for defined low-risk deviation (e.g., S3 versioning disabled); resource remediated within 3 minutes; remediation action logged to CloudTrail

### Identity Security Validation

- [ ] SSO login flow confirmed for all 4 permission set roles (Developer, PlatformOperator, SecurityViewer, BreakGlass)
- [ ] IAM Identity Center session tag `PrincipalTag/email` propagated to CloudTrail `userIdentity` for all test API calls
- [ ] BreakGlass role assumption generates immediate GuardDuty finding and SIEM alert within 2 minutes
- [ ] Attempting to assume BreakGlass role without CISO approval (simulated) is blocked by ITSM workflow check
- [ ] MFA enforcement at IdP confirmed: SAML assertion without MFA factor returns authentication failure

### Phase 3 Quality Gates

All four quality gates below must be passed before go-live.

**Phase 3 Quality Gate — Must Pass (all items required for CISO sign-off):**
- [ ] All functional test cases executed with zero outstanding CRITICAL defects
- [ ] All SCP guardrails confirmed active on all production OUs; no exception found
- [ ] IAM Identity Center federation live; zero shared credentials in any production account
- [ ] Security Hub findings forwarded to SIEM; validated by SIEM team within 5-minute SLA
- [ ] DR failover test completed: RTO < 4 hours (measured); RPO < 1 hour (S3 CRR lag measurement included)
- [ ] ISO 27001 compliance evidence package reviewed and accepted by CISO
- [ ] Operational runbooks delivered and dry-run validated by platform team
- [ ] AWS Inspector scan of all Lambda functions: zero CRITICAL/HIGH findings outstanding at go-live
- [ ] CISO written sign-off obtained (M8 milestone)
- [ ] ITSM change record approved for production go-live

### Quality Metrics

The following table summarises the quality metrics targets for this engagement.

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| SCP Enforcement | 100% blocked actions denied | Guardrail test execution report |
| Config Rule Evaluation Lag | ≤ 60 seconds | Phase 3 timing test across 10 rule evaluations |
| SIEM Delivery SLA | ≤ 5 minutes (p95) | 10 consecutive integration tests |
| AFT Provisioning Time | ≤ 60 minutes end-to-end | 3 test account provisionings |
| DR RTO | < 4 hours | Phase 3 DR failover drill — measured |
| DR RPO | < 1 hour | S3 CRR replication lag measurement over 24 hours |
| Platform Availability | 99.9% | CloudWatch uptime monitoring |
| Test Pass Rate | 100% (no CRITICAL defects at go-live) | QA test results report (Deliverable #19) |
| ISO 27001 Evidence Coverage | 100% of Annex A controls mapped | ISO 27001 Control Mapping Matrix (Deliverable #4) |

---

# Migration & Cutover

## Migration Approach

This engagement does not involve application data migration. All governance platform data stores (CloudTrail log archive, Config snapshots, Terraform state) are created fresh in Phase 2. Historical CloudTrail logs from existing accounts prior to Control Tower onboarding are not migrated; the compliance evidence window begins from the date of the platform go-live at end of Week 15. This provides six months of continuous automated evidence before the April 30, 2026 regulatory deadline.

The migration scope is limited to the onboarding of three existing production environments into the new account structure. These environments are not re-platformed; the AFT baseline is applied to bring them under the governance framework.

**Migration Type:** Phased (one production environment per day, Days 1–3 of Week 15)

## Cutover Plan

Production go-live is executed as a staged cutover across three production environments in Week 15, each in a separate ITSM-approved change window on consecutive days.

**Cutover Window:** Week 15, Days 1–3 (three separate ITSM change windows)
**Cutover Hours:** Pre-approved maintenance window (low-traffic period; to be confirmed with Priya Nair)
**Post-Cutover Monitoring:** 2-hour window per environment before proceeding to the next

**Go/No-Go Criteria (confirmed before each environment cutover):**
- [ ] All Phase 3 quality gate items passed
- [ ] CISO written sign-off obtained (M8)
- [ ] ITSM change record approved for specific environment
- [ ] Workload owner notified and available during 2-hour monitoring window
- [ ] Rollback procedure rehearsed by the delivery team in the preceding 48 hours
- [ ] Amatra on-call coverage confirmed for the full 2-hour monitoring window

**Cutover Sequence:**

| Day | Environment | Activity | Monitoring |
|-----|-------------|----------|------------|
| Week 15, Day 1 | Production Environment 1 | AFT baseline applied; SCP enforcement activated; Security Hub enrolled | 2-hour window; Priya Nair + Amatra on-call |
| Week 15, Day 2 | Production Environment 2 | Repeat cutover procedure | 2-hour window |
| Week 15, Day 3 | Production Environment 3 | Final production environment onboarded | 2-hour window |
| Week 15, Days 4–5 | All environments | Post-cutover validation across all 3 environments | Full platform sign-off |

**Cutover Checklist (per environment):**
- [ ] ITSM change record approved; change window confirmed with Priya Nair and workload owner
- [ ] AFT pipeline executed; account baseline applied (IAM roles, Config enrollment, Security Hub enrollment, tagging)
- [ ] SCPs active; console access test returns `AccessDenied` as expected
- [ ] IAM Identity Center permission sets assigned to platform team roles for this environment
- [ ] Security Hub enrollment confirmed; first finding visible in Audit account within 5 minutes
- [ ] CloudTrail delivery confirmed to Log Archive bucket; at least one log file delivered
- [ ] SIEM alert flow confirmed: test finding forwarded and received within 5 minutes
- [ ] No service disruption reported by workload owner during 2-hour post-cutover monitoring window

## Rollback Procedures

Rollback is triggered if any of the following conditions are met during a 2-hour post-cutover monitoring window:
- A workload-impacting service disruption is detected
- A CRITICAL Security Hub finding is raised as a direct consequence of the cutover changes
- Priya Nair (Platform Lead) or the CISO calls a rollback

```bash
# Rollback Step 1: Remove console-access deny SCP from affected production OU
# (break-glass procedure — requires CISO approval via ITSM)
aws organizations detach-policy \
  --policy-id p-XXXXXXXX \
  --target-id ou-XXXX-XXXXXXXX
echo "SCP removed. Pre-cutover access model restored within ~5 minutes."

# Rollback Step 2: Notify stakeholders immediately
aws sns publish \
  --topic-arn ${SNS_TOPIC_ARN} \
  --message "ROLLBACK INITIATED: Production Environment ${ENV_NAME} cutover rolled back at $(date -u). Reason: [INSERT]. SCP removed. All access restored. ITSM incident raised." \
  --subject "CNTSO Platform Rollback Alert"

# Rollback Step 3: Record rollback in ITSM platform
# (manual step — PM raises ITSM incident and updates the change record)
echo "Raise ITSM incident and update change record ${ITSM_CHANGE_ID} with rollback outcome"

# Rollback Step 4: Leave AFT baseline resources in place (non-destructive)
# IAM roles, Config enrollment, Security Hub enrollment, and tagging applied by AFT
# are non-destructive and do not impact workload operations.
# Remove only if specifically instructed by Priya Nair.

# Rollback Step 5: Schedule rollback review and re-cutover planning
echo "Rollback complete. Re-cutover scheduled for next available ITSM change window."
```

**Rollback Timeline:** SCP rollback completes in < 30 minutes. Full access restoration to pre-cutover state confirmed within 30 minutes of rollback decision.

---

# Operational Handover

## Documentation Handover

All documentation deliverables are transferred to Contoso Financial at close of the engagement. Delivery acceptance requires written sign-off from Priya Nair (or CISO, where specified) within 5 business days of delivery.

- [ ] Architecture Design Document (Deliverable #5) — complete as-designed diagrams, design decision log, CISO-approved; delivered Week 5
- [ ] Configuration and Operations Guide (Deliverable #17) — step-by-step reference for all platform configurations; delivered Week 12
- [ ] Operational Runbook Suite (Deliverable #21) — individual runbooks for account vending, guardrail management, break-glass procedure, SIEM alert triage, DR failover, and patch management; delivered Week 15
- [ ] ISO 27001 Compliance Evidence Package (Deliverable #19) — control mapping matrix, Config compliance reports, CloudTrail attestation, Security Hub trend report, DR test results; delivered Week 15
- [ ] IaC Module Library (Git repository) — all Terraform modules, AFT customisations, VPC modules, IAM role modules, Config rule packs; transferred Week 16
- [ ] CI/CD Pipeline Configuration — Terraform Cloud workspace settings, Sentinel policy definitions, change-approval workflow configuration; transferred Week 16
- [ ] Test Results Report (Deliverable #19) — all test cases, results, defects, and resolution evidence
- [ ] Platform Optimisation Roadmap (Deliverable #24) — ongoing cost, guardrail, and compliance automation recommendations
- [ ] Project Closeout Report (Deliverable #25) — engagement summary, lessons learned, future phase recommendations
- [ ] Knowledge Transfer Session Recordings (Deliverable #22) — recorded sessions for IaC pipeline, Security Hub, and IAM Identity Center administration

## Support Transition

### Support Model

The following support model governs the 8-week hypercare period and the steady-state transition to Contoso Financial's internal teams.

| Tier | Responsibility | Response Time | Escalation |
|------|----------------|---------------|------------|
| L1 — Platform Team | Initial triage; known issues; day-to-day operations | < 1 hour (business hours) | Escalate to L2 after 2 hours |
| L2 — Amatra Hypercare | Technical troubleshooting; platform defects; guardrail tuning | < 2 hours P1; next business day P2 | Escalate to L3 for code-level issues |
| L3 — Amatra Architecture | Expert resolution; design changes; code-level defects | < 1 business day | AWS APAC Support for service issues |
| AWS Business Support | AWS service incidents; Trusted Advisor; architecture guidance | < 1 hour (production outage) | AWS APAC team via Business Support portal |

## Hypercare Period

The 8-week hypercare support period commences immediately upon production go-live (M9, end of Week 15) and is deliberately sized to cover the April 2026 regulatory review period.

- **Duration:** 8 weeks (Weeks 17–24)
- **Coverage:** Business hours, 09:00–17:00 AEST, Monday to Friday
- **Response Times:** P1 (platform outage or compliance-blocking issue) — 2-hour response; P2 (functional issue, non-blocking) — next business day response
- **P1 Scope:** Platform outage, compliance evidence collection failure, SCP enforcement failure, SIEM forwarding failure, DR replication lag exceeding RPO, break-glass access event
- **P2 Scope:** Guardrail false-positive tuning, SIEM alert correlation refinement, non-critical Config rule adjustments, advisory on new account vending requests

**Hypercare includes:**
- Triage and resolution of platform defects identified post-go-live
- Guardrail tuning based on false-positive findings in production
- SIEM alert correlation refinement
- Assistance with regulatory review evidence queries
- Advisory on new account vending requests (up to 5 accounts during hypercare)

**Hypercare excludes:**
- New feature development or scope changes (require Change Request)
- Integration of additional external systems beyond SIEM and ITSM
- Remediation of on-premises workloads (explicitly out of scope)

## Handover Checklist

The following checklist must be completed and signed off by Priya Nair and Rachel Moore at the M10 (Week 24) final handover call.

- [ ] All documentation deliverables delivered and accepted (written sign-off received)
- [ ] All 4 knowledge transfer sessions delivered, recorded, and recordings provided to Contoso Financial
- [ ] Administrator training sessions completed; attendance records provided
- [ ] Platform team has successfully performed all core operational tasks in sandbox (dry-run validation)
- [ ] All operational runbooks dry-run validated by at least one platform team member per runbook
- [ ] Support escalation contacts documented and tested (L2/L3 contact details confirmed)
- [ ] Monitoring dashboards reviewed with Priya Nair's operations team; all metrics explained
- [ ] SIEM alert correlation configured and reviewed by SIEM team
- [ ] AWS Business Support contact details shared and test case raised with AWS
- [ ] Amatra vendor support contact details and SLA terms confirmed for post-hypercare availability under Managed Services Agreement (if applicable)
- [ ] All hypercare items (ITSM incidents) resolved or accepted by Priya Nair
- [ ] Final handover call with Priya Nair and Rachel Moore completed; platform self-sufficiency confirmed

---

# Training Program

## Training Overview

### Objectives

The training program ensures all user groups at Contoso Financial achieve competency with the AWS Cloud Governance Platform before go-live and establishes ongoing learning paths for new platform team members joining after the engagement concludes. Training is aligned to the knowledge transfer commitments in the SOW (Section 9 — Handover & Support) and is delivered as part of Phase 3 (Weeks 15–16).

### Training Approach

- **Phased Delivery:** Training delivered in sequence with implementation phases — foundational content in Phase 2, hands-on operational training in Phase 3
- **Role-Based:** Content is tailored to each audience's operational responsibilities; no role receives irrelevant content
- **Hands-On Focus:** Technical training uses the deployed sandbox environment with realistic scenarios
- **Documentation:** All session materials (slides, lab workbooks, quick reference cards) are delivered to Contoso Financial for self-service learning and onboarding of new team members
- **Recorded Sessions:** All instructor-led and virtual instructor-led sessions are recorded and delivered as Deliverable #22

## Training Schedule

The table below summarises all training modules, target audiences, durations, formats, and prerequisites.

| Module ID | Module Name | Target Audience | Duration | Format | Prerequisites |
|-----------|-------------|-----------------|----------|--------|---------------|
| TRN-001 | AWS Cloud Governance Platform Architecture Overview | Platform Engineers, CISO | 2 hours | ILT | None |
| TRN-002 | Control Tower and AFT — Account Vending Operations | Platform Engineers | 3 hours | Hands-On Lab | TRN-001 |
| TRN-003 | SCP and Config Guardrail Management | Platform Engineers, CISO | 3 hours | Hands-On Lab | TRN-002 |
| TRN-004 | IAM Identity Center Operations | Platform Engineers, CISO | 2 hours | VILT | TRN-001 |
| TRN-005 | Security Hub and Compliance Evidence | Platform Engineers, CISO | 3 hours | Hands-On Lab | TRN-001 |
| TRN-006 | SIEM and ITSM Integration Operations | Platform Engineers | 2 hours | VILT | TRN-003 |
| TRN-007 | DR Failover Procedures and Runbook | Platform Engineers | 2 hours | Hands-On Lab | TRN-003 |
| TRN-008 | Break-Glass Access Procedure | Platform Engineers, CISO | 1 hour | VILT | TRN-004 |
| TRN-009 | Troubleshooting and Incident Response | Platform Engineers | 2 hours | ILT | TRN-005 |
| TRN-010 | Platform Optimisation and Roadmap Briefing | James Wu, Priya Nair, CISO | 1.5 hours | Briefing | All modules |

## Administrator Training

### TRN-001: AWS Cloud Governance Platform Architecture Overview (2 hours, ILT)

**Learning Objectives:**
- Describe the multi-account landing zone architecture and the role of each specialised account (Management, Log Archive, Audit, Security, Network, Workload)
- Explain the two-layer guardrail model (preventive SCPs + detective Config rules) and how each prevents or detects non-compliance
- Trace the flow of compliance evidence from resource configuration change through Config → Security Hub → Log Archive S3 → SIEM
- Explain the data sovereignty design: why all data remains in ap-southeast-2/ap-southeast-4 and how region lock SCPs enforce this

**Content Outline:**
1. Architecture overview (40 min): component diagram walkthrough; account structure; OU hierarchy; network hub-spoke topology
2. Security and compliance posture (30 min): SCP hierarchy; Config conformance pack; IAM Identity Center federation model
3. Data architecture and evidence flow (20 min): CloudTrail → S3 WORM; Config → Security Hub; SIEM forwarding pipeline
4. Q&A session (30 min)

**Materials Required:**
- Architecture diagram (from Deliverable #5)
- Architecture Design Document (read-only reference)
- Quick reference card: account structure and OU hierarchy

### TRN-002: Control Tower and AFT — Account Vending Operations (3 hours, Hands-On Lab)

**Learning Objectives:**
- Raise a compliant account vending request in the ITSM ticketing platform
- Describe the end-to-end AFT pipeline execution flow from ITSM approval to account baseline application
- Monitor AFT pipeline execution via CodePipeline and CloudWatch dashboards
- Identify and triage common account vending failures using pipeline execution logs

**Content Outline:**
1. AFT pipeline architecture (30 min): CodePipeline stages; ITSM approval gate; Terraform Cloud workspace execution; account baseline application
2. Raising an account vending request (20 min): ITSM portal walkthrough; required fields; environment tier selection
3. Monitoring pipeline execution (30 min): CodePipeline console; CloudWatch Platform Operations dashboard; expected timelines
4. Lab Exercise 1 (40 min): End-to-end account vending request in sandbox — raise ITSM request, approve, monitor pipeline, validate new account baseline
5. Common failure scenarios (20 min): ITSM approval timeout; Terraform workspace error; baseline customisation failure
6. Lab Exercise 2 (20 min): Diagnose and remediate a simulated pipeline failure

**Lab Environment:**
- Sandbox Management account with AFT pipeline deployed
- ITSM sandbox tenant with change-approval workflow configured
- Terraform Cloud sandbox workspace

**Materials Required:**
- Lab workbook with step-by-step instructions for both exercises
- CodePipeline execution log reference card
- ITSM account vending request form template

### TRN-003: SCP and Config Guardrail Management (3 hours, Hands-On Lab)

**Learning Objectives:**
- Explain the SCP inheritance hierarchy and how SCPs interact with account-level IAM policies
- Interpret Config rule evaluation results and compliance reports in the Config console
- Request a guardrail change via the IaC pipeline and ITSM change-approval workflow
- Confirm auto-remediation has triggered and validate the remediation action in CloudTrail

**Content Outline:**
1. SCP deep dive (40 min): Policy syntax; OU attachment; inheritance; deny-all-except vs explicit deny patterns
2. AWS Config conformance packs (30 min): ISO 27001 conformance pack structure; custom rule library; compliance score interpretation
3. Raising a guardrail change request (20 min): Git pull request workflow; Sentinel policy check; ITSM change-approval gate
4. Lab Exercise 1 (40 min): Interpret a non-compliant Config evaluation; trace finding from Config → Security Hub; confirm SIEM forwarding
5. Auto-remediation walkthrough (20 min): Lambda function review; remediation action scope; CloudTrail audit trail for remediation
6. Lab Exercise 2 (20 min): Raise a guardrail change request in sandbox (add a custom Config rule via Git PR)

### TRN-004: IAM Identity Center Operations (2 hours, VILT)

**Learning Objectives:**
- Navigate the IAM Identity Center admin console and describe permission set assignment architecture
- Add a new permission set or modify an existing assignment via the IaC pipeline
- Interpret IAM Identity Center access logs and trace a federated user session in CloudTrail
- Execute the break-glass access review procedure after an emergency access event

**Content Outline:**
1. IAM Identity Center architecture (20 min): instance; SAML IdP connector; groups; permission sets; account assignments
2. Permission set management (25 min): reviewing existing assignments; raising a change request; quarterly access review process
3. Log analysis (25 min): CloudTrail `AssumeRoleWithSAML` events; session tag propagation; access attribution
4. Break-glass awareness (20 min): When break-glass is used; how to confirm the event in CloudTrail; post-event audit review
5. Q&A and demonstration (30 min)

**Materials Required:**
- Video conferencing platform with screen share
- IAM Identity Center sandbox instance
- CloudTrail log query examples workbook

### TRN-005: Security Hub and Compliance Evidence (3 hours, Hands-On Lab)

**Learning Objectives:**
- Navigate Security Hub dashboard; interpret compliance scores and finding prioritisation
- Generate a Config conformance pack compliance report and export it in the format required for the ISO 27001 evidence package
- Understand how Security Hub findings map to ISO 27001 Annex A controls
- Run a compliance evidence export for regulatory submission

**Content Outline:**
1. Security Hub dashboard navigation (30 min): summary page; standards compliance scores; finding filters; insight charts
2. ISO 27001 control mapping (20 min): how Config conformance pack findings map to Annex A controls
3. Compliance evidence export (20 min): exporting Config reports; Security Hub finding exports; CloudTrail attestation procedure
4. Lab Exercise 1 (40 min): Navigate Security Hub sandbox; identify and triage a CRITICAL finding; export a compliance report in PDF format
5. Lab Exercise 2 (30 min): Assemble a mini compliance evidence package for a single ISO 27001 control domain
6. Q&A (20 min)

**Lab Environment:**
- Security Hub sandbox aggregator in Audit account sandbox
- Pre-populated with representative findings from all control categories

### TRN-006: SIEM and ITSM Integration Operations (2 hours, VILT)

**Learning Objectives:**
- Describe the SIEM forwarding pipeline architecture and end-to-end event flow
- Diagnose SIEM delivery failures using SQS DLQ depth alarms and Lambda CloudWatch logs
- Confirm ITSM change-approval integration is functioning; diagnose polling failures
- Trigger a manual re-delivery of a failed finding from the SQS DLQ

**Content Outline:**
1. SIEM integration architecture (20 min): EventBridge rule; Lambda transformer; SIEM API; DLQ; retry policy
2. Operational monitoring (25 min): CloudWatch Platform Operations dashboard for SIEM; DLQ depth alarm; Lambda error rates
3. Diagnosing delivery failures (25 min): Lambda CloudWatch Logs; DLQ message inspection; SIEM API health check
4. ITSM integration walkthrough (20 min): AFT polling mechanism; approval status codes; timeout handling
5. Q&A and live demonstration (30 min)

## End User Training

### TRN-007: DR Failover Procedures and Runbook (2 hours, Hands-On Lab)

End users in this context are platform engineers who are the primary operators of the DR failover procedure. This session makes them competent to execute the DR failover runbook independently.

**Learning Objectives:**
- Identify the conditions that trigger DR activation (compliance evidence collection disrupted for > 30 minutes)
- Execute the DR failover runbook step-by-step in a sandbox environment
- Validate that the ap-southeast-4 DR baseline is operational after failover activation
- Document DR test results in the format required for regulatory evidence

**Content Outline:**
1. DR architecture review (20 min): ap-southeast-4 baseline; S3 CRR; Config cross-region aggregation; Security Hub cross-region aggregation
2. DR activation criteria (15 min): triggers; escalation decision tree; CISO communication protocol
3. Runbook walkthrough (35 min): step-by-step DR failover runbook; expected outputs at each step; validation checks
4. Lab Exercise (40 min): Execute DR failover runbook in sandbox (simulated ap-southeast-2 failure); validate ap-southeast-4 baseline operational; measure simulated RTO
5. Evidence documentation (10 min): completing the DR test results template for regulatory submission

### TRN-008: Break-Glass Access Procedure (1 hour, VILT)

This session is attended by all Platform Engineers and the CISO. It ensures all parties understand the break-glass procedure, their roles during an emergency access event, and the post-event audit requirements.

**Learning Objectives:**
- Define the conditions under which break-glass access is approved and used
- Execute the break-glass access request via ITSM (approved by CISO)
- Confirm that break-glass usage generates a GuardDuty finding and SIEM alert
- Complete the post-event audit review: CloudTrail log review; ITSM incident closure; credential rotation

**Content Outline:**
1. Break-glass policy (15 min): when to use; CISO approval requirement; 4-hour time limit; dual-person credential control
2. Break-glass procedure walkthrough (20 min): raising ITSM emergency access request; credential retrieval from physical escrow; session logging
3. Post-event obligations (15 min): CloudTrail log review; GuardDuty finding review; ITSM incident documentation; credential rotation after use
4. Q&A (10 min)

## IT Support Training

### TRN-009: Troubleshooting and Incident Response (2 hours, ILT)

**Learning Objectives:**
- Diagnose common platform issues using CloudWatch dashboards, Lambda logs, and CloudTrail
- Apply standard resolution procedures from the Operational Runbook Suite
- Escalate issues to Amatra hypercare using the correct P1/P2 priority classification
- Document resolutions in the ITSM knowledge base for future reference

**Content Outline:**
1. Troubleshooting framework (20 min): symptom-driven diagnosis; which log source to start with; escalation decision criteria
2. Common issues reference (40 min): AFT pipeline failures; SIEM DLQ depth alerts; Config evaluation gaps; Identity Center login failures; CloudTrail delivery gaps
3. Lab Exercise 1 (30 min): Diagnose a simulated AFT pipeline failure; identify root cause from CodePipeline logs and CloudWatch; apply runbook resolution
4. Lab Exercise 2 (20 min): Investigate a simulated SIEM delivery failure; check DLQ; re-deliver failed message; confirm SIEM receipt
5. Escalation and documentation (10 min): P1/P2 priority classification; Amatra hypercare contact details; ITSM incident template

**Materials Required:**
- Operational Runbook Suite (Deliverable #21) — pre-reading
- Troubleshooting quick reference card (provided at session)
- Amatra hypercare contact details and escalation matrix

## Training Materials

### Documentation Provided

The following training materials are delivered to Contoso Financial as part of Deliverable #22 and #23.

- Architecture Design Document (PDF, reference) — as-designed reference for TRN-001
- Configuration and Operations Guide (PDF, reference) — step-by-step platform configuration reference
- Operational Runbook Suite (PDF, 10 runbooks) — primary operational reference for all training
- Quick Reference Cards (per role): Platform Engineer card; CISO card; On-Call Engineer card
- Lab Exercise Workbooks (per session): TRN-002, TRN-003, TRN-005, TRN-007, TRN-009
- Session recordings (MP4): all ILT and VILT sessions recorded and provided
- Assessment questions and answers (for internal training redelivery)

### Training Environment

All hands-on lab exercises use the governance platform sandbox environment, which is a separate AWS account with representative data and configurations that mirrors the production architecture without hosting live workloads or production data.

- **Environment:** Dedicated sandbox AWS account (vended via AFT during Phase 2)
- **Reset Policy:** Sandbox environment is reset weekly to a clean baseline state; no persistent changes
- **Access:** Platform team access provisioned via Developer permission set 2 weeks before Phase 3 training sessions
- **Data:** Synthetic data only; no PII or production data in the sandbox

## Training Effectiveness

### Assessment Approach

- **Knowledge Checks:** Short quiz at the end of each module (minimum 70% pass required); results documented by Amatra facilitator
- **Practical Assessment:** Lab exercises are graded; participants must complete all steps correctly without facilitator assistance on the second attempt
- **Competency Validation:** Priya Nair observes the dry-run of at least one full account vending cycle and one guardrail management task by a platform engineer before go-live sign-off

### Success Metrics

| Metric | Target |
|--------|--------|
| Training Completion Rate | 100% of designated platform team attendees |
| Knowledge Check Pass Rate | > 85% first attempt across all modules |
| Lab Exercise Completion | 100% of participants complete all lab exercises |
| Post-Training Satisfaction | > 4.0 / 5.0 (post-session survey) |
| Time to Competency | Platform team self-sufficient by Week 24 (hypercare end) |
| Dry-Run Validation | All operational runbooks dry-run validated before go-live |

---

# Appendices

## Appendix A: Environment Details

The following table provides the account and configuration details for each environment tier in the governance platform. Actual account IDs are populated during Phase 2 deployment.

### Management Account

| Component | Value |
|-----------|-------|
| Account ID | `[aws.account_id.management]` |
| Primary Region | `ap-southeast-2` |
| Purpose | Control Tower root; AFT pipeline orchestration; org-level SCPs |
| Access Method | BreakGlass only (MFA + CISO approval + full audit logging) |
| Terraform Workspace | `cntso-management-aft` |

### Log Archive Account

| Component | Value |
|-----------|-------|
| Account ID | `[aws.account_id.log_archive]` |
| Primary Region | `ap-southeast-2` |
| Purpose | Centralised CloudTrail and Config S3 WORM archive |
| S3 Bucket | `[storage.log_archive.bucket_name]` |
| Object Lock Mode | `COMPLIANCE` (12-month retention) |
| CRR Destination | `[storage.log_archive.crr_destination_bucket]` (ap-southeast-4) |

### Audit Account

| Component | Value |
|-----------|-------|
| Account ID | `[aws.account_id.audit]` |
| Primary Region | `ap-southeast-2` |
| Purpose | Security Hub org aggregator; GuardDuty org detector; Config aggregator |
| SIEM DLQ | `[integration.siem.dlq_name]` |
| CloudWatch Dashboard | `[monitoring.cloudwatch.dashboard_platform_ops]` |

### Security Account

| Component | Value |
|-----------|-------|
| Account ID | `[aws.account_id.security]` |
| Primary Region | `ap-southeast-2` |
| Purpose | IAM Identity Center; SAML 2.0 IdP connector |
| IdP Connector Count | 1 (on-premises enterprise directory) |
| CloudWatch Dashboard | `[monitoring.cloudwatch.dashboard_identity]` |

### Network Account

| Component | Value |
|-----------|-------|
| Account ID | `[aws.account_id.network]` |
| Primary Region | `ap-southeast-2` |
| Purpose | Transit Gateway; Network Firewall; Direct Connect termination |
| VPC CIDR | `[networking.vpc.cidr_network_account]` |
| TGW ID (Primary) | `[networking.transit_gateway.primary_id]` |
| TGW ID (DR) | `[networking.transit_gateway.dr_id]` |

## Appendix B: Configuration Reference

The following table provides a summary of key configuration parameters from `configuration.csv`. Full parameter reference is in the Configuration and Operations Guide (Deliverable #17).

| Parameter | Production Value | Notes |
|-----------|-----------------|-------|
| `solution.region.primary` | `ap-southeast-2` | Data sovereignty — Australian primary region |
| `solution.region.dr` | `ap-southeast-4` | Data sovereignty — Australian DR region |
| `aft.pipeline.max_concurrent_requests` | `5` | Load-tested in Phase 3 |
| `aft.pipeline.account_provisioning_timeout_minutes` | `60` | SOW success metric |
| `security.cloudtrail.log_retention_years` | `1` | ISO 27001 evidence retention |
| `security.credentials_rotation_days` | `90` | SIEM and ITSM credentials |
| `integration.siem.delivery_sla_minutes` | `5` | SOW success metric |
| `monitoring.config.evaluation_lag_seconds` | `60` | SOW success metric |
| `operations.dr.rto_hours` | `4` | SOW hard requirement |
| `operations.dr.rpo_hours` | `1` | SOW hard requirement |
| `operations.hypercare.duration_weeks` | `8` | Covers April 2026 regulatory review |
| `operations.hypercare.p1_response_hours` | `2` | Business hours AEST |
| `scp.region_lock.allowed_regions` | `ap-southeast-2, ap-southeast-4` | Data sovereignty — no non-AU regions |

## Appendix C: Deployment Scripts

The following scripts are the primary operational automation tools for the governance platform. All scripts are maintained in the Git repository under `scripts/`.

### deploy.sh — Full Platform Deployment

```bash
#!/bin/bash
# deploy.sh — Full governance platform deployment script
# Usage: ./scripts/deploy.sh <environment> <version> <itsm_change_id>
# Example: ./scripts/deploy.sh prod 1.0.0 CHG0012345
set -euo pipefail

ENVIRONMENT=${1:-nonprod}
VERSION=${2:-latest}
ITSM_CHANGE_ID=${3:-"REQUIRED"}

if [ "${ITSM_CHANGE_ID}" = "REQUIRED" ]; then
  echo "ERROR: ITSM Change ID is required. Usage: ./scripts/deploy.sh <env> <version> <change_id>"
  exit 1
fi

echo "=== Deploying AWS Cloud Governance Platform ==="
echo "Environment: ${ENVIRONMENT}"
echo "Version: ${VERSION}"
echo "ITSM Change: ${ITSM_CHANGE_ID}"

# Pre-deployment checks
./scripts/pre-deploy-check.sh "${ENVIRONMENT}" "${ITSM_CHANGE_ID}"

# Deploy in order: Network → Security → Compute → Monitoring
for LAYER in network security compute monitoring; do
  echo "--- Deploying layer: ${LAYER} ---"
  cd "infrastructure/${LAYER}"
  terraform init -backend-config="backend-${ENVIRONMENT}.tfvars"
  terraform plan -var-file="envs/${ENVIRONMENT}.tfvars" -out="${LAYER}.plan"
  terraform apply "${LAYER}.plan"
  terraform output -json > "../../outputs/${LAYER}-${ENVIRONMENT}-outputs.json"
  cd ../..
  echo "--- Layer ${LAYER} complete ---"
done

# Post-deployment validation
./scripts/post-deploy-validate.sh "${ENVIRONMENT}"
echo "=== Deployment complete for environment: ${ENVIRONMENT} ==="
```

### rollback.sh — SCP Emergency Rollback

```bash
#!/bin/bash
# rollback.sh — Emergency SCP rollback script (break-glass path)
# Usage: ./scripts/rollback.sh <production_ou_id> <scp_policy_id> <itsm_incident_id>
# REQUIRES: Break-glass credentials and CISO approval
set -euo pipefail

OU_ID=${1:-"REQUIRED"}
SCP_ID=${2:-"REQUIRED"}
ITSM_INCIDENT=${3:-"REQUIRED"}

echo "=== EMERGENCY SCP ROLLBACK INITIATED ==="
echo "OU: ${OU_ID} | SCP: ${SCP_ID} | ITSM Incident: ${ITSM_INCIDENT}"
echo "Operator: $(aws sts get-caller-identity --query Arn --output text)"
echo "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Detach console-access deny SCP from production OU
aws organizations detach-policy \
  --policy-id "${SCP_ID}" \
  --target-id "${OU_ID}"

echo "SCP detached. Production console access restored within ~5 minutes."

# Notify stakeholders via SNS
SNS_ARN=$(aws ssm get-parameter --name "/cntso/sns/alert_topic_arn" \
  --query 'Parameter.Value' --output text)
aws sns publish \
  --topic-arn "${SNS_ARN}" \
  --subject "CNTSO PLATFORM ROLLBACK — SCP Removed" \
  --message "ROLLBACK: SCP ${SCP_ID} detached from OU ${OU_ID} at $(date -u). Operator: $(aws sts get-caller-identity --query Arn --output text). ITSM Incident: ${ITSM_INCIDENT}. Notify CISO immediately."

echo "=== Rollback complete. Notify CISO. Update ITSM incident ${ITSM_INCIDENT}. ==="
```

## Appendix D: Troubleshooting Guide

The following reference covers the most common operational issues anticipated post-go-live, aligned to the P1/P2 alert definitions in the Monitoring section.

### Issue: AFT Pipeline Failure (P1)

**Symptoms:**
- CloudWatch alarm `cntso-aft-pipeline-failure-p1` fires
- SNS notification received by on-call engineer
- Account vending request not completed within 60-minute timeout

**Cause:** AFT CodePipeline stage failure — typically caused by Terraform plan error, ITSM API unreachable, or IAM role permissions issue.

**Resolution:**
```bash
# Step 1: Check CodePipeline execution status
aws codepipeline get-pipeline-execution \
  --pipeline-name aws-aft-account-provisioning-pipeline \
  --pipeline-execution-id $(aws codepipeline list-pipeline-executions \
    --pipeline-name aws-aft-account-provisioning-pipeline \
    --query 'pipelineExecutionSummaries[0].pipelineExecutionId' --output text) \
  --query 'pipelineExecution.{Status:status,Trigger:trigger}'

# Step 2: Review the failing stage logs in CloudWatch
aws logs tail /aws/codepipeline/aws-aft-account-provisioning-pipeline \
  --since 1h --follow

# Step 3: If ITSM connectivity issue, check ITSM Lambda logs
aws logs tail /aws/lambda/cntso-itsm-integration-prod \
  --since 1h

# Step 4: Retry the pipeline execution after resolving root cause
aws codepipeline retry-stage-execution \
  --pipeline-name aws-aft-account-provisioning-pipeline \
  --stage-name ITSM-Approval \
  --pipeline-execution-id EXECUTION_ID \
  --retry-mode FAILED_ACTIONS
```

**Prevention:** Ensure ITSM API credentials in Secrets Manager are not expired (90-day rotation schedule); confirm ITSM service availability before initiating large batches of account vending requests.

### Issue: SIEM Forwarding DLQ Depth > 0 (P1)

**Symptoms:**
- CloudWatch alarm `cntso-siem-dlq-depth-p1` fires
- SIEM not receiving Security Hub findings; potential evidence gap

**Cause:** SIEM API unavailable, authentication failure (expired Bearer token), or network connectivity issue between Lambda and SIEM endpoint.

**Resolution:**
```bash
# Step 1: Check DLQ message count and inspect a failed message
aws sqs get-queue-attributes \
  --queue-url https://sqs.ap-southeast-2.amazonaws.com/AUDIT_ACCOUNT_ID/cntso-siem-forward-dlq-prod \
  --attribute-names All

# Step 2: Inspect the Lambda error in CloudWatch
aws logs tail /aws/lambda/cntso-siem-forward-eventbridge \
  --since 30m

# Step 3: Test SIEM API reachability
aws lambda invoke \
  --function-name cntso-siem-forward-eventbridge \
  --payload '{"test_connectivity": true}' \
  connectivity-test.json
cat connectivity-test.json

# Step 4: If Bearer token expired, rotate the secret
aws secretsmanager rotate-secret \
  --secret-id cntso-siem-api-key-prod

# Step 5: Re-drive DLQ messages after resolving root cause
aws sqs receive-message \
  --queue-url https://sqs.ap-southeast-2.amazonaws.com/AUDIT_ACCOUNT_ID/cntso-siem-forward-dlq-prod \
  --max-number-of-messages 10 | \
  jq -r '.Messages[].Body' | \
  xargs -I {} aws lambda invoke \
    --function-name cntso-siem-forward-eventbridge \
    --payload {} /dev/null
```

### Issue: S3 CRR Replication Lag Exceeds 1 Hour (P1)

**Symptoms:**
- CloudWatch alarm `cntso-crr-replication-lag-p1` fires
- RPO of < 1 hour is at risk; audit evidence continuity in DR region may be degraded

**Cause:** S3 CRR configuration issue, IAM replication role permission error, or ap-southeast-4 S3 service disruption.

**Resolution:**
```bash
# Step 1: Check S3 replication metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/S3 \
  --metric-name ReplicationLatency \
  --dimensions Name=SourceBucket,Value=cntso-log-archive-cloudtrail-apse2 \
               Name=DestinationBucket,Value=cntso-log-archive-cloudtrail-apse4 \
               Name=RuleId,Value=cntso-crr-rule \
  --start-time $(date -u -d '2 hours ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Maximum

# Step 2: Check replication status on recent objects
aws s3api head-object \
  --bucket cntso-log-archive-cloudtrail-apse2 \
  --key AWSLogs/ACCOUNT_ID/CloudTrail/LATEST_LOG.gz \
  --query 'ReplicationStatus'
# Expected: COMPLETED or PENDING (FAILED indicates an issue)

# Step 3: Verify IAM replication role permissions
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::LOG_ARCHIVE_ACCOUNT_ID:role/cntso-s3-crr-role \
  --action-names s3:ReplicateObject s3:ReplicateDelete \
  --resource-arns arn:aws:s3:::cntso-log-archive-cloudtrail-apse4/*

# Escalate to Amatra L2 if replication failure persists > 30 minutes
```

### Issue: CloudTrail Log Delivery Gap (P1)

**Symptoms:**
- CloudWatch alarm `cntso-cloudtrail-delivery-gap-p1` fires
- No CloudTrail log file delivered to Log Archive S3 bucket for > 30 minutes

**Cause:** Org CloudTrail configuration issue, Log Archive S3 bucket policy change, or CloudTrail service disruption.

**Resolution:**
```bash
# Step 1: Verify org CloudTrail is enabled and delivering
aws cloudtrail get-trail-status \
  --name arn:aws:cloudtrail:ap-southeast-2:MANAGEMENT_ACCOUNT_ID:trail/cntso-org-trail \
  --query '{IsLogging:IsLogging,LatestDeliveryTime:LatestDeliveryTime,LatestDeliveryError:LatestDeliveryError}'

# Step 2: Check Log Archive bucket policy allows CloudTrail delivery
aws s3api get-bucket-policy \
  --bucket cntso-log-archive-cloudtrail-apse2 \
  --query 'Policy' | jq .

# Step 3: Re-enable logging if disabled (SCP should prevent this, but verify)
aws cloudtrail start-logging \
  --name arn:aws:cloudtrail:ap-southeast-2:MANAGEMENT_ACCOUNT_ID:trail/cntso-org-trail

# Escalate to Amatra L2 if delivery gap persists > 30 minutes
```

## Appendix E: Contact Information

### Project Team

| Role | Name | Email | Availability |
|------|------|-------|--------------|
| Amatra Project Manager | (Amatra PM) | delivery@amatra.com.au | Business hours AEST |
| Amatra Lead Solution Architect | (Amatra Arch) | delivery@amatra.com.au | Business hours AEST |
| Amatra Senior Security Engineer | (Amatra Sec Eng) | delivery@amatra.com.au | Business hours AEST |
| Contoso PM | Rachel Moore | (Contoso email) | Business hours AEST |
| Contoso Platform Lead | Priya Nair | (Contoso email) | Business hours AEST |
| Contoso CTO | James Wu | (Contoso email) | Milestone approvals |

### Escalation Contacts (Hypercare Period — Weeks 17–24)

| Level | Contact | Scope | Availability |
|-------|---------|-------|--------------|
| L2 — Amatra Hypercare | delivery@amatra.com.au | P1/P2 platform issues | Business hours AEST (09:00–17:00) |
| L3 — Amatra Architecture | delivery@amatra.com.au | Design changes; code defects | Business hours AEST; P1 via mobile |
| AWS Business Support | https://console.aws.amazon.com/support | AWS service incidents | 24x7 (< 1 hour P1 response) |

### Vendor Support

| Vendor | Support Portal | SLA |
|--------|----------------|-----|
| AWS | https://console.aws.amazon.com/support (Business) | < 1 hour production outage |
| HashiCorp (Terraform Cloud Plus) | https://support.hashicorp.com | Per Terraform Cloud Plus SLA |

## Appendix F: Glossary

Key terms used in this implementation guide are defined in the Detailed Design Document Appendix (Glossary). The following shortlist covers the most operationally relevant terms.

| Term | Definition |
|------|------------|
| AFT | Account Factory for Terraform — IaC-based account vending solution for AWS Control Tower |
| CRR | S3 Cross-Region Replication — continuous replication of log archive data to ap-southeast-4 |
| DLQ | Dead Letter Queue — SQS queue receiving Lambda invocations that failed after maximum retries |
| GuardDuty | AWS threat detection service using ML; org-level detector in Audit account |
| IAM Identity Center | AWS federated SSO service; connects on-premises IdP to AWS via SAML 2.0 |
| RTO / RPO | Recovery Time / Recovery Point Objectives; < 4 hours / < 1 hour for this platform |
| SCP | Service Control Policy — AWS Organizations policy overriding all account-level IAM policies |
| Security Hub | AWS compliance and findings aggregation service; ISO 27001 control mapping |
| WORM | Write Once Read Many — S3 Object Lock Compliance mode; 12-month immutable log retention |
