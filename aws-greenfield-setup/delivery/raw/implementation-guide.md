---
document_title: Implementation Guide
solution_name: AWS Multi-Account Landing Zone
document_version: "1.0"
author: Amatra Solution Architect
last_updated: 2025-01-31
technology_provider: aws
client_name: Anonymous — Insurance Vendor
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

## Project Overview

This Implementation Guide provides the step-by-step deployment procedures, configuration specifications, and operational handover materials for the **AWS Multi-Account Landing Zone** engagement delivered by Amatra for an insurance vendor operating in the United States. The landing zone establishes a production-ready, multi-region AWS governance foundation built on AWS Control Tower, enabling the client to onboard workloads with consistent security guardrails, automated account provisioning, and full infrastructure-as-code coverage from day one.

This guide translates the Statement of Work (SOW) into executable procedures across three sequential delivery phases spanning 12 weeks (Weeks 1–12), followed by a 4-week hypercare period (Weeks 13–16).

## Implementation Scope

- **In Scope:**
  - AWS Control Tower deployment governing us-east-1 (primary) and us-east-2 (DR)
  - Seven-OU organisational hierarchy (Root, Security, Infrastructure, Workloads-Prod, Workloads-NonProd, Sandbox, Suspended)
  - Service Control Policies (SCPs) and Resource Control Policies (RCPs) for governance and data perimeter enforcement
  - AWS IAM Identity Center (SSO) with permission sets and identity source integration
  - Centralised logging infrastructure — Log Archive, Audit accounts, CloudTrail organisation trail
  - AWS Config deployment across all accounts in both regions with FSBP conformance packs
  - Transit Gateway hub-and-spoke topology in us-east-1 and us-east-2 with inter-region peering
  - AWS Network Firewall for north-south and east-west traffic inspection in both regions
  - VPC IPAM with 10.0.0.0/8 supernet and /20 per spoke VPC
  - Hub VPCs with centralised NAT Gateway egress and Site-to-Site VPN to on-premises
  - Spoke VPC Terraform modules
  - Account Factory for Terraform (AFT) pipeline for automated account vending
  - AWS Security Hub (FSBP standard) aggregated to Audit account across both regions
  - Amazon GuardDuty organisation-wide in both regions
  - CloudTrail Lake for security investigation queries
  - Tagging policy enforcement — five mandatory tags
  - AWS Cost Explorer and per-account AWS Budgets (80% and 100% spend alerts)
  - Centralised CloudWatch monitoring dashboards and SNS alerting
  - Terraform modules and CI/CD pipeline
  - Operational runbooks, as-built documentation, administrator training, and 4-week hypercare support

- **Out of Scope:**
  - Application workload migration, deployment, or refactoring
  - Direct Connect provisioning and physical circuit ordering
  - Third-party SIEM integration (Splunk, Datadog, Elastic)
  - GuardDuty or Security Hub integration with ticketing systems (ServiceNow, PagerDuty)
  - Custom compliance frameworks confirmed after Phase 1 cutover (require change control)
  - AWS WAF, Shield Advanced, or API Gateway configuration
  - Data migration of any kind
  - Managed services beyond the 4-week hypercare period

- **Dependencies:**
  - Management account root credentials provided to vendor team (Week 1)
  - Stakeholder RACI roles confirmed and named (Week 1)
  - Compliance framework requirements confirmed — NIST/SOC 2/HIPAA (Week 2)
  - Identity source for IAM Identity Center confirmed (Week 3)
  - On-premises gateway details confirmed (Week 4)
  - Architecture Design Document approved (Week 4 gate)
  - On-premises gateway accessible and correctly configured (Week 6)
  - Client UAT team available for Week 12 sessions

## Timeline Overview

- **Project Duration:** 12 weeks (plus 4-week hypercare)
- **Go-Live Date:** End of Week 12
- **Hypercare End:** End of Week 16
- **Key Milestones:**
  - M1 — Kick-off Complete: Week 1
  - M2 — Architecture Approved: Week 4
  - M3 — Governance Foundation Live: Week 4
  - M4 — Network Foundation Live: Week 8
  - M5 — Security Automation Complete: Week 11
  - M6 — Go-Live: Week 12
  - M7 — Hypercare End: Week 16

---

# Prerequisites

The following prerequisites must be completed before implementation begins. Each item is a hard dependency for the corresponding phase.

## Technical Prerequisites

Complete these items before the Phase 1 kick-off session:

### AWS Account & Access

- [ ] A new AWS Management account created with billing email confirmed
- [ ] Management account root MFA enabled and credentials secured offline
- [ ] Vendor team granted Management account access (AdministratorAccess) for Control Tower deployment
- [ ] AWS service quotas verified for us-east-1 and us-east-2 (Control Tower, TGW, Network Firewall, VPC IPAM)
- [ ] AWS Business Support plan activated on the Management account
- [ ] Billing alerts configured at $500 threshold on the Management account

### Network & Connectivity

- [ ] On-premises VPN gateway IP address confirmed and accessible
- [ ] On-premises ASN and routing protocol capability confirmed (BGP preferred; static fallback)
- [ ] IP address range 10.0.0.0/8 confirmed as available and non-conflicting with on-premises
- [ ] Firewall rules on the on-premises side permit IKEv2 on UDP 500 and 4500

### Identity & Compliance

- [ ] Identity source decision made: AWS SSO native directory or external IdP (Azure AD/Okta)
- [ ] If external IdP: SAML 2.0 metadata URL and attribute mapping confirmed
- [ ] Compliance frameworks confirmed with client security lead: AWS FSBP (mandatory) + NIST 800-53 / SOC 2 / HIPAA (as applicable)
- [ ] Five mandatory tag values confirmed: `Environment`, `Owner`, `CostCenter`, `Project`, `DataClassification`

### Development Tools

- [ ] Git repository created (client-managed) for IaC code handover
- [ ] Terraform Cloud Team tier account created (5 users, client-managed subscription)
- [ ] Terraform CLI >= 1.5.0 installed on vendor delivery workstations
- [ ] AWS CLI >= 2.13 installed and configured on vendor delivery workstations
- [ ] Python >= 3.11 installed (required for AFT customisation scripts)

## Organisational Prerequisites

- [ ] Project team assigned and availability confirmed for all 12 weeks
- [ ] Executive Sponsor confirmed and available for sign-off milestones at Weeks 1, 4, 8, 12
- [ ] Client IT Owner, Security Lead, Networking Lead, and FinOps contact named
- [ ] Budget approved: $316,542 net total Year 1 investment (including $33,000 in credits)
- [ ] Change management process activated; communication plan distributed to stakeholders
- [ ] AWS MAP and Activate credit eligibility confirmed with AWS account team (Dependency D10)

## Environmental Prerequisites

### Development / NonProd Workload Accounts

- [ ] Placeholder for first Dev account vending confirmed (will be provisioned via AFT in Week 11)
- [ ] Dev team member email addresses available for IAM Identity Center provisioning

### Staging / Pre-Production

- [ ] AFT customisation for NonProd OU path reviewed and approved by client IT Owner

### Production Environment

- [ ] Production OU SCP policy set reviewed and approved by client Security Lead
- [ ] Break-glass emergency access process agreed in principle with client security team
- [ ] On-call rotation and escalation contacts documented for hypercare period

---

# Environment Setup

This section covers the Phase 1 Foundation & Governance setup activities (Weeks 1–4), establishing the governance backbone, central identity, and logging infrastructure that all subsequent phases depend upon.

## Phase 1 — Foundation & Governance (Weeks 1–4)

### Objectives

- Deploy AWS Control Tower across us-east-1 (primary) and us-east-2 (governed)
- Implement the seven-OU hierarchy with SCPs and RCPs
- Configure IAM Identity Center with permission sets and identity source
- Provision Log Archive and Audit accounts with CloudTrail organisation trail
- Enable AWS Config recording in both regions across all accounts
- Obtain Architecture Design Review sign-off from Client Executive Sponsor

### Activities

The following table summarises the key activities, owners, and durations for Phase 1.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Project kick-off; confirm stakeholder RACI | Vendor PM | 1 day | None |
| Stakeholder interviews — OU design, compliance, IaC, IP space | Vendor Arch | 2 days | Kick-off |
| Architecture Design Document (OU, SCP/RCP, IdC, monitoring) | Vendor Arch | 3 days | Interviews |
| Deploy AWS Control Tower — us-east-1 primary | Vendor Eng × 2 | 2 days | Mgmt account access |
| Enrol us-east-2 as governed region | Vendor Eng × 2 | 1 day | CT deployment |
| Seven-OU hierarchy + tagging baseline + OU policies | Vendor Eng × 2 | 2 days | CT deployment |
| SCPs and RCPs implementation | Vendor Eng (Security) | 2 days | OU hierarchy |
| Provision Log Archive and Audit accounts | Vendor Eng × 2 | 1 day | OU hierarchy |
| CloudTrail organisation trail — both regions | Vendor Eng (Security) | 1 day | Log Archive |
| IAM Identity Center — permission sets + identity source | Vendor Eng × 2 | 2 days | OU hierarchy |
| AWS Config recording — both regions, all accounts | Vendor Eng (Security) | 1 day | Log Archive |
| Architecture Design Review session with client | Vendor Arch | 1 day | ADR document |

### Detailed Procedures

#### 1.1 AWS Control Tower Deployment

Before running any automation, ensure Management account access is configured in the AWS CLI profile.

```bash
# Verify Management account access
aws sts get-caller-identity --profile mgmt

# Expected output includes the management account ID:
# {
#   "UserId": "AIDAXXXXXXXXXX",
#   "Account": "111122223333",
#   "Arn": "arn:aws:iam::111122223333:root"
# }
```

Control Tower is deployed via the AWS Console (CT does not yet support full Terraform bootstrap for initial landing zone setup). Navigate to the Control Tower service console in us-east-1 and complete the landing zone setup wizard with the following parameters.

```yaml
# control-tower-landing-zone-manifest.yaml
# Reference values for the CT landing zone configuration
landing_zone:
  version: "3.3"
  home_region: us-east-1
  governed_regions:
    - us-east-1
    - us-east-2
  centralised_logging:
    enabled: true
    retention_days: 365
    log_archive_account: "log-archive@client.com"
  security_alerts:
    enabled: true
    audit_account: "audit@client.com"
  cloudtrail_config:
    enabled: true
    enable_log_file_validation: true
    enable_s3_data_events: false
```

#### 1.2 OU Hierarchy Bootstrap

After Control Tower is deployed, the OU hierarchy is extended using Terraform. The repository structure below should be used as the baseline.

```bash
# Clone the IaC repository
git clone https://github.com/<client-org>/landing-zone-iac.git
cd landing-zone-iac

# Initialise Terraform for the governance module
cd modules/governance/ou-hierarchy
terraform init -backend-config=../../backends/mgmt.tfvars

# Preview the OU structure
terraform plan -var-file=../../environments/mgmt.tfvars

# Apply — creates 7-OU hierarchy
terraform apply -var-file=../../environments/mgmt.tfvars -auto-approve
```

The expected OU structure after apply is as follows.

```
Root
├── Security
│   ├── Log Archive Account
│   └── Audit / Security Tooling Account
├── Infrastructure
│   ├── Shared Services Account
│   └── Network Hub Account
├── Workloads-Prod
├── Workloads-NonProd
├── Sandbox
└── Suspended
```

#### 1.3 SCP and RCP Deployment

SCPs are deployed via the `modules/governance/scp` Terraform module. All five mandatory SCPs and the data perimeter RCP are applied at OU level.

```bash
cd modules/governance/scp
terraform init -backend-config=../../backends/mgmt.tfvars
terraform plan -var-file=../../environments/mgmt.tfvars
terraform apply -var-file=../../environments/mgmt.tfvars -auto-approve
```

The SCP set includes the following policies.

```hcl
# modules/governance/scp/main.tf (excerpt)
resource "aws_organizations_policy" "deny_root_actions" {
  name    = "DenyRootAccountActions"
  type    = "SERVICE_CONTROL_POLICY"
  content = file("${path.module}/policies/deny-root-actions.json")
}

resource "aws_organizations_policy" "restrict_regions" {
  name    = "RestrictToAllowedRegions"
  type    = "SERVICE_CONTROL_POLICY"
  content = file("${path.module}/policies/restrict-regions.json")
}

resource "aws_organizations_policy" "deny_cloudtrail_disable" {
  name    = "DenyCloudTrailDisable"
  type    = "SERVICE_CONTROL_POLICY"
  content = file("${path.module}/policies/deny-cloudtrail-disable.json")
}

resource "aws_organizations_policy" "require_mfa" {
  name    = "RequireMFAForConsoleAccess"
  type    = "SERVICE_CONTROL_POLICY"
  content = file("${path.module}/policies/require-mfa.json")
}

resource "aws_organizations_policy" "data_perimeter_rcp" {
  name    = "DataPerimeterRCP"
  type    = "RESOURCE_CONTROL_POLICY"
  content = file("${path.module}/policies/data-perimeter-rcp.json")
}
```

#### 1.4 IAM Identity Center Configuration

IAM Identity Center is configured via Terraform after the identity source is confirmed at kick-off.

```bash
cd modules/identity/idc
terraform init -backend-config=../../backends/mgmt.tfvars
terraform plan -var-file=../../environments/mgmt.tfvars
terraform apply -var-file=../../environments/mgmt.tfvars -auto-approve
```

The permission sets provisioned are shown in the following configuration excerpt.

```hcl
# modules/identity/idc/permission_sets.tf (excerpt)
locals {
  permission_sets = {
    PlatformAdministrator = {
      managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      session_duration  = "PT8H"
    }
    SecurityAuditor = {
      managed_policies = ["arn:aws:iam::aws:policy/SecurityAudit"]
      session_duration  = "PT8H"
    }
    NetworkOperator = {
      managed_policies = ["arn:aws:iam::aws:policy/AmazonVPCFullAccess"]
      session_duration  = "PT8H"
    }
    WorkloadAdministrator = {
      managed_policies = ["arn:aws:iam::aws:policy/PowerUserAccess"]
      session_duration  = "PT4H"
    }
    FinOps = {
      managed_policies = ["arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess"]
      session_duration  = "PT8H"
    }
  }
}
```

### Deliverables

The following deliverables must be completed and accepted before Phase 2 begins.

- [ ] AWS Control Tower operational in us-east-1; us-east-2 enrolled as governed region
- [ ] Seven-OU hierarchy deployed and verified in AWS Organizations console
- [ ] All five SCPs and the data perimeter RCP applied and tested
- [ ] Log Archive and Audit accounts provisioned and in correct OUs
- [ ] CloudTrail organisation trail delivering events to Log Archive in both regions
- [ ] IAM Identity Center configured with all five permission sets; SSO login validated
- [ ] AWS Config recording active in both regions across all accounts
- [ ] Phase 1 Architecture Design Document delivered
- [ ] Architecture Design Review sign-off obtained from Client Executive Sponsor (M2/M3 gate)

### Success Criteria

- Control Tower dashboard shows all accounts in green compliance status
- CloudTrail validation: `aws cloudtrail get-trail-status --name org-trail` returns `IsLogging: true` in both regions
- SCP enforcement test: root account API call rejected with `AccessDenied` explicitly referencing the SCP
- IAM Identity Center SSO login validated by at least one client team member per permission set

---

# Infrastructure Deployment

This section covers the deployment of all infrastructure components for the AWS Multi-Account Landing Zone across Phases 1–3. The architecture is depicted in the figure below.

![Figure 1: AWS Multi-Account Landing Zone Architecture](../../assets/diagrams/architecture-diagram.png)

**Figure 1** shows the full multi-region landing zone including the OU hierarchy, Security and Infrastructure shared accounts, Transit Gateway hub-and-spoke networking, and the Account Factory for Terraform automated provisioning pipeline.

All infrastructure is deployed as Terraform code via the CI/CD pipeline. The four subsections below cover Networking, Security, Compute, and Monitoring components respectively.

## Networking

The networking layer implements a hub-and-spoke Transit Gateway topology with AWS Network Firewall, VPC IPAM, centralised NAT Gateway egress, and Site-to-Site VPN to on-premises. All networking infrastructure is deployed in both us-east-1 and us-east-2.

### Components

The table below lists all networking components deployed in this layer.

| Component | Region | Account | Specification | Purpose |
|-----------|--------|---------|---------------|---------|
| Transit Gateway (primary) | us-east-1 | Network Hub | ASN 64512; 3 route tables | Central routing backbone |
| Transit Gateway (secondary) | us-east-2 | Network Hub | ASN 64513; 3 route tables | DR routing backbone |
| TGW Inter-Region Peering | Both | Network Hub | Static routes | Cross-region traffic |
| Network Hub VPC (us-east-1) | us-east-1 | Network Hub | 10.0.0.0/22 | Centralised egress and inspection |
| Network Hub VPC (us-east-2) | us-east-2 | Network Hub | 10.64.0.0/22 | Centralised egress and inspection |
| AWS Network Firewall (primary) | us-east-1 | Network Hub | Multi-AZ; stateful + stateless | North-south and east-west inspection |
| AWS Network Firewall (secondary) | us-east-2 | Network Hub | Multi-AZ; stateful + stateless | North-south and east-west inspection |
| VPC IPAM | us-east-1 | Network Hub | 10.0.0.0/8 supernet | Centralised IP address management |
| IPAM Pool (us-east-1) | us-east-1 | Network Hub | 10.0.0.0/10 | Regional allocation pool |
| IPAM Pool (us-east-2) | us-east-2 | Network Hub | 10.64.0.0/10 | Regional allocation pool |
| NAT Gateways (us-east-1) | us-east-1 | Network Hub | 1 per AZ (3 AZs) | Centralised internet egress |
| NAT Gateways (us-east-2) | us-east-2 | Network Hub | 1 per AZ (2 AZs) | Centralised internet egress |
| Site-to-Site VPN (us-east-1) | us-east-1 | Network Hub | IKEv2; BGP preferred | On-premises connectivity |
| Site-to-Site VPN (us-east-2) | us-east-2 | Network Hub | IKEv2; BGP preferred | On-premises connectivity (DR) |
| Spoke VPC Module | Both | Workload accts | /20 per spoke from IPAM | Workload network isolation |

### Script Location

All networking Terraform modules are located under `modules/networking/` in the IaC repository.

```
landing-zone-iac/
├── modules/
│   └── networking/
│       ├── transit-gateway/    # TGW and route tables
│       ├── network-hub-vpc/    # Hub VPCs and NAT Gateways
│       ├── network-firewall/   # AWS Network Firewall policies
│       ├── vpc-ipam/           # IPAM supernet and pools
│       ├── vpn/                # Site-to-Site VPN resources
│       └── spoke-vpc/          # Reusable spoke VPC module
├── environments/
│   └── network-hub/
│       ├── us-east-1.tfvars
│       └── us-east-2.tfvars
└── backends/
    └── network-hub.tfvars
```

### Deployment Steps

Networking is deployed during Phase 2 (Weeks 5–8). The steps below must be executed in order.

```bash
# Step 1 — Deploy VPC IPAM (must be first; all VPCs depend on IPAM pools)
cd modules/networking/vpc-ipam
terraform init -backend-config=../../backends/network-hub.tfvars
terraform plan -var-file=../../environments/network-hub/us-east-1.tfvars
terraform apply -var-file=../../environments/network-hub/us-east-1.tfvars -auto-approve

# Step 2 — Deploy Transit Gateways (both regions)
cd ../transit-gateway
terraform init -backend-config=../../backends/network-hub.tfvars
terraform plan -var-file=../../environments/network-hub/us-east-1.tfvars
terraform apply -var-file=../../environments/network-hub/us-east-1.tfvars -auto-approve
# Repeat for us-east-2
terraform plan -var-file=../../environments/network-hub/us-east-2.tfvars
terraform apply -var-file=../../environments/network-hub/us-east-2.tfvars -auto-approve

# Step 3 — Deploy Hub VPCs and NAT Gateways
cd ../network-hub-vpc
terraform init -backend-config=../../backends/network-hub.tfvars
terraform apply -var-file=../../environments/network-hub/us-east-1.tfvars -auto-approve
terraform apply -var-file=../../environments/network-hub/us-east-2.tfvars -auto-approve

# Step 4 — Deploy Network Firewall (both regions)
cd ../network-firewall
terraform init -backend-config=../../backends/network-hub.tfvars
terraform apply -var-file=../../environments/network-hub/us-east-1.tfvars -auto-approve
terraform apply -var-file=../../environments/network-hub/us-east-2.tfvars -auto-approve

# Step 5 — Configure TGW inter-region peering
cd ../transit-gateway
# TGW peering is a two-step process: requester then accepter
terraform apply -var="create_peering_attachment=true" \
  -var-file=../../environments/network-hub/us-east-1.tfvars -auto-approve

# Step 6 — Deploy Site-to-Site VPN (both regions)
cd ../vpn
terraform init -backend-config=../../backends/network-hub.tfvars
terraform apply -var-file=../../environments/network-hub/us-east-1.tfvars -auto-approve
terraform apply -var-file=../../environments/network-hub/us-east-2.tfvars -auto-approve

# Step 7 — Deploy sample Spoke VPCs (Dev and Prod test accounts)
cd ../spoke-vpc
terraform init -backend-config=../../backends/network-hub.tfvars
terraform apply -var-file=../../environments/network-hub/spoke-dev.tfvars -auto-approve
terraform apply -var-file=../../environments/network-hub/spoke-prod.tfvars -auto-approve
```

### Validation

After each deployment step, run the following validation commands to confirm components are operational.

```bash
# Validate IPAM pools
aws ec2 describe-ipam-pools \
  --filters Name=state,Values=create-complete \
  --query 'IpamPools[*].{PoolId:IpamPoolId,Cidr:ProvisionedCidrs[0].Cidr,State:State}' \
  --region us-east-1

# Validate Transit Gateway state
aws ec2 describe-transit-gateways \
  --filters Name=state,Values=available \
  --query 'TransitGateways[*].{Id:TransitGatewayId,State:State,ASN:Options.AmazonSideAsn}' \
  --region us-east-1

# Validate Network Firewall
aws network-firewall describe-firewall \
  --firewall-name lz-network-firewall-us-east-1 \
  --region us-east-1 \
  --query 'FirewallStatus.Status'
# Expected: "READY"

# Validate VPN tunnels
aws ec2 describe-vpn-connections \
  --filters Name=state,Values=available \
  --query 'VpnConnections[*].{Id:VpnConnectionId,State:State,Tunnels:VgwTelemetry}' \
  --region us-east-1

# Validate TGW inter-region peering
aws ec2 describe-transit-gateway-peering-attachments \
  --filters Name=state,Values=available \
  --region us-east-1

# End-to-end flow test: spoke-to-spoke via firewall
# From a test EC2 instance in the Dev spoke VPC:
# ping <IP address in Prod spoke VPC>
# Expected: ICMP permitted per firewall stateful rules
```

### Success Criteria

- All IPAM pools in `create-complete` state; /20 allocations successful for both test spoke VPCs
- Both Transit Gateways in `available` state; inter-region peering attachment in `available` state
- Both Network Firewalls reporting `READY` status in both regions
- Both VPN connections show at least one tunnel in `UP` state with BGP session established
- Spoke-to-spoke ICMP passes through Network Firewall per east-west stateful rules
- Centralised NAT Gateway egress confirmed: traffic from spoke instances exits via Hub VPC EIPs
- All TGW route tables contain expected static and propagated routes
- Network Testing Report (Deliverable 15) completed and accepted by Client IT Owner by Week 8

### Rollback

The networking stack is fully managed by Terraform. If a deployment step fails or validation does not pass, execute the following rollback sequence.

```bash
# Rollback spoke VPCs first (dependency order)
cd modules/networking/spoke-vpc
terraform destroy -var-file=../../environments/network-hub/spoke-prod.tfvars -auto-approve
terraform destroy -var-file=../../environments/network-hub/spoke-dev.tfvars -auto-approve

# Rollback VPN
cd ../vpn
terraform destroy -var-file=../../environments/network-hub/us-east-2.tfvars -auto-approve
terraform destroy -var-file=../../environments/network-hub/us-east-1.tfvars -auto-approve

# Rollback Network Firewall
cd ../network-firewall
terraform destroy -var-file=../../environments/network-hub/us-east-2.tfvars -auto-approve
terraform destroy -var-file=../../environments/network-hub/us-east-1.tfvars -auto-approve

# Rollback Hub VPCs
cd ../network-hub-vpc
terraform destroy -var-file=../../environments/network-hub/us-east-2.tfvars -auto-approve
terraform destroy -var-file=../../environments/network-hub/us-east-1.tfvars -auto-approve

# Rollback Transit Gateways
cd ../transit-gateway
terraform destroy -var-file=../../environments/network-hub/us-east-2.tfvars -auto-approve
terraform destroy -var-file=../../environments/network-hub/us-east-1.tfvars -auto-approve

# IPAM destroyed last
cd ../vpc-ipam
terraform destroy -var-file=../../environments/network-hub/us-east-1.tfvars -auto-approve
```

For Network Firewall policy errors that cause traffic disruption, the previous policy version can be re-applied in under 30 minutes using the IaC pipeline without full stack teardown.

```bash
# Revert to previous firewall policy version
cd modules/networking/network-firewall
git checkout HEAD~1 -- policies/
terraform apply -var-file=../../environments/network-hub/us-east-1.tfvars -auto-approve
```

---

## Security

The security layer deploys all preventative and detective controls: SCPs, RCPs, Security Hub, Amazon GuardDuty, AWS Config, CloudTrail Lake, and the AFT account vending pipeline with mandatory guardrail enrolment. Security components are deployed across Phases 1 and 3.

### Components

The table below enumerates all security components deployed in this layer.

| Component | Region | Account | Specification | Purpose |
|-----------|--------|---------|---------------|---------|
| SCPs (5 policies) | Both | Management | Deny root, restrict regions, deny CT/Config disable, MFA | Preventative org-level guardrails |
| Data Perimeter RCP | Both | Management | Deny external-org S3 write | Data exfiltration prevention |
| AWS Security Hub | Both | All + Audit agg | FSBP standard; aggregated to Audit | CSPM and compliance scoring |
| Amazon GuardDuty | Both | All + Audit admin | Org-wide; VPC FL, CT, DNS analysers | Threat detection |
| AWS Config (Recorder) | Both | All accounts | All resource types; delivery to Log Archive | Configuration history |
| AWS Config Conformance Packs | Both | All accounts | FSBP; NIST 800-53 (if confirmed) | Compliance evaluation |
| CloudTrail Organisation Trail | Both | Management → Log Archive | All mgmt events; log file validation | Immutable audit trail |
| CloudTrail Lake (Event Data Store) | us-east-1 | Audit | 7-year retention | Security investigations |
| IAM Access Analyser | Both | All accounts | Zone of trust: Organisation | External access findings |
| Account Factory for Terraform (AFT) | us-east-1 | Management | CodePipeline-based | Automated account vending |
| Tagging Policies | Both | Management | 5 mandatory tags | Governance enforcement |
| AWS Budgets | Both | All accounts | 80% and 100% thresholds | Cost alert controls |

### Script Location

Security Terraform modules are located under `modules/security/` and `modules/aft/` in the IaC repository.

```
landing-zone-iac/
├── modules/
│   ├── security/
│   │   ├── security-hub/       # Security Hub enablement and aggregation
│   │   ├── guardduty/          # GuardDuty org-wide enablement
│   │   ├── config-rules/       # AWS Config rules and conformance packs
│   │   ├── cloudtrail-lake/    # CloudTrail Lake event data store
│   │   ├── iam-access-analyser/
│   │   └── budgets/            # Per-account Budget alerts
│   └── aft/
│       ├── pipeline/           # AFT CodePipeline resources
│       ├── customisations/     # OU-specific account customisations
│       └── account-requests/   # Sample account request templates
```

### Deployment Steps

Phase 3 security automation is deployed in Weeks 9–11. Execute steps in the order shown below.

```bash
# Step 1 — Enable Security Hub org-wide with FSBP (Phase 3, Week 9)
cd modules/security/security-hub
terraform init -backend-config=../../backends/audit.tfvars
terraform plan -var-file=../../environments/security/us-east-1.tfvars
terraform apply -var-file=../../environments/security/us-east-1.tfvars -auto-approve
# Repeat for us-east-2
terraform apply -var-file=../../environments/security/us-east-2.tfvars -auto-approve

# Step 2 — Enable GuardDuty org-wide (Phase 3, Week 9)
cd ../guardduty
terraform init -backend-config=../../backends/audit.tfvars
terraform apply -var-file=../../environments/security/us-east-1.tfvars -auto-approve
terraform apply -var-file=../../environments/security/us-east-2.tfvars -auto-approve

# Step 3 — Deploy Config rules and conformance packs (Phase 3, Week 10)
cd ../config-rules
terraform init -backend-config=../../backends/audit.tfvars
terraform apply -var-file=../../environments/security/us-east-1.tfvars -auto-approve
terraform apply -var-file=../../environments/security/us-east-2.tfvars -auto-approve

# Step 4 — Deploy CloudTrail Lake (Phase 3, Week 10)
cd ../cloudtrail-lake
terraform init -backend-config=../../backends/audit.tfvars
terraform apply -var-file=../../environments/security/us-east-1.tfvars -auto-approve

# Step 5 — Deploy AFT pipeline (Phase 3, Week 10–11)
cd ../../aft/pipeline
terraform init -backend-config=../../backends/mgmt.tfvars
terraform plan -var-file=../../environments/aft/aft.tfvars
terraform apply -var-file=../../environments/aft/aft.tfvars -auto-approve

# Step 6 — Deploy AFT customisations (Prod, NonProd, Sandbox paths)
cd ../customisations
terraform init -backend-config=../../backends/mgmt.tfvars
terraform apply -var-file=../../environments/aft/customisations.tfvars -auto-approve

# Step 7 — Vend first two workload accounts via AFT (Phase 3, Week 11)
# Submit account requests as Terraform code to the AFT pipeline
cd ../account-requests
# Edit account-request-prod.tf and account-request-nonprod.tf with client details
git add .
git commit -m "feat: vend Production-01 and NonProd-01 workload accounts"
git push origin main
# AFT CodePipeline triggers automatically; monitor in CodePipeline console

# Step 8 — Deploy per-account Budgets alerts
cd ../../security/budgets
terraform init -backend-config=../../backends/mgmt.tfvars
terraform apply -var-file=../../environments/security/budgets.tfvars -auto-approve
```

### Validation

After deploying each security component, run the following validation checks.

```bash
# Validate Security Hub is enabled and aggregating findings
aws securityhub describe-hub \
  --region us-east-1 \
  --profile audit
# Expected: HubArn present; AutoEnableControls: true

# Check FSBP compliance score
aws securityhub get-findings \
  --filters '{"ComplianceStatus":[{"Value":"FAILED","Comparison":"EQUALS"}]}' \
  --region us-east-1 \
  --profile audit \
  --query 'length(Findings)'
# Target: zero CRITICAL severity findings in Production accounts

# Validate GuardDuty is enabled org-wide
aws guardduty list-detectors --region us-east-1 --profile audit
aws guardduty get-master-account \
  --detector-id <detector-id> \
  --region us-east-1 \
  --profile audit

# Validate AWS Config recording
aws configservice describe-configuration-recorder-status \
  --region us-east-1 \
  --query 'ConfigurationRecordersStatus[0].recording'
# Expected: true

# Validate CloudTrail Lake event data store
aws cloudtrail describe-event-data-stores \
  --region us-east-1 \
  --profile audit \
  --query 'EventDataStores[0].Status'
# Expected: "ENABLED"

# Validate AFT account vending (after Step 7 above)
aws codecommit get-branch \
  --repository-name aws-aft-account-request \
  --branch-name main \
  --region us-east-1
aws codepipeline get-pipeline-state \
  --name aws-aft-main-pipeline \
  --region us-east-1 \
  --query 'stageStates[*].{Stage:stageName,Status:latestExecution.status}'

# SCP enforcement test — should return AccessDenied
aws cloudtrail stop-logging \
  --name org-trail \
  --region us-east-1 \
  --profile workload-admin 2>&1 | grep -i "accessdenied"
```

### Success Criteria

- Security Hub FSBP compliance score ≥ 80% across all Production and Platform accounts at go-live
- Zero critical Security Hub findings in Production and Platform accounts at go-live
- GuardDuty enabled in all accounts in both regions; delegated administrator confirmed in Audit account
- All five SCPs and the data perimeter RCP return `AccessDenied` on all simulated violation calls
- AFT pipeline successfully vends two workload accounts (1 Prod, 1 NonProd) in under 30 minutes each across three consecutive test runs
- Config recording active in all accounts in both regions; delivery to Log Archive confirmed
- CloudTrail Lake event data store in `ENABLED` state with sample queries returning results
- AWS Budgets alerts active at 80% and 100% thresholds for all accounts

### Rollback

Security controls are progressive — most are additive and do not require teardown on failure. The rollback procedures below address specific failure scenarios.

```bash
# SCP misconfiguration rollback — revert to previous policy version
cd modules/governance/scp
git checkout HEAD~1 -- policies/
terraform apply -var-file=../../environments/mgmt.tfvars -auto-approve
# Estimated recovery time: < 15 minutes

# AFT pipeline failure — re-run from last known-good state
aws codepipeline start-pipeline-execution \
  --name aws-aft-main-pipeline \
  --region us-east-1
# Monitor pipeline; check CloudWatch Logs for CodeBuild errors

# Security Hub accidental disable — re-enable via CLI
aws securityhub enable-security-hub \
  --enable-default-standards \
  --region us-east-1 \
  --profile audit

# GuardDuty member account not enrolled — re-enable
aws guardduty create-members \
  --detector-id <admin-detector-id> \
  --account-details '[{"AccountId":"<member-account-id>","Email":"<email>"}]' \
  --region us-east-1 \
  --profile audit
```

---

## Compute

The compute layer encompasses the Account Factory for Terraform (AFT) pipeline infrastructure, the CI/CD pipeline for all IaC changes, and the Shared Services compute resources (CloudWatch dashboards). Workload compute resources are deliberately out of scope for this landing zone engagement — the compute layer here refers to the platform-level automation and pipeline infrastructure.

### Components

The table below lists all compute and automation components deployed in this layer.

| Component | Region | Account | Specification | Purpose |
|-----------|--------|---------|---------------|---------|
| AFT CodePipeline | us-east-1 | Management | 5-stage pipeline | Account vending automation |
| AFT CodeBuild Projects | us-east-1 | Management | Terraform runner; Python 3.11 | IaC execution in pipeline |
| AFT DynamoDB State Table | us-east-1 | Management | On-demand; encrypted at rest | Account request state tracking |
| AFT S3 Artifacts Bucket | us-east-1 | Management | SSE-KMS; Object Lock | Pipeline artifact storage |
| IaC CI/CD Pipeline | us-east-1 | Shared Services | CodePipeline + CodeBuild | Infrastructure change management |
| Terraform Cloud Workspaces | us-east-1 | All | Team tier, 5 users | Remote state and plan execution |
| Lambda — AFT Customisations | us-east-1 | Management | Python 3.11; 512 MB | Per-OU post-provisioning steps |
| CloudWatch Log Groups | Both | All accounts | 365-day retention | Pipeline and automation logs |

### Script Location

Compute and CI/CD Terraform modules are located in the IaC repository as follows.

```
landing-zone-iac/
├── modules/
│   ├── aft/
│   │   ├── pipeline/           # AFT CodePipeline, CodeBuild, S3, DynamoDB
│   │   ├── customisations/     # Lambda customisation functions
│   │   └── account-requests/   # Account request Terraform templates
│   └── cicd/
│       ├── iac-pipeline/       # IaC CI/CD CodePipeline
│       ├── buildspecs/         # CodeBuild buildspec YAML files
│       └── branch-protection/  # Repository policy (branch protection rules)
```

### Deployment Steps

The AFT pipeline and CI/CD infrastructure are deployed in Phase 3 (Weeks 10–11). The steps below assume Security Hub and GuardDuty are already enabled (Security subsection above).

```bash
# Step 1 — Deploy AFT foundational resources
cd modules/aft/pipeline
terraform init -backend-config=../../backends/mgmt.tfvars
terraform plan -var-file=../../environments/aft/aft.tfvars
terraform apply -var-file=../../environments/aft/aft.tfvars -auto-approve

# Step 2 — Deploy AFT Lambda customisation functions
cd ../customisations
terraform init -backend-config=../../backends/mgmt.tfvars
terraform apply -var-file=../../environments/aft/customisations.tfvars -auto-approve

# Step 3 — Deploy IaC CI/CD pipeline
cd ../../cicd/iac-pipeline
terraform init -backend-config=../../backends/mgmt.tfvars
terraform plan -var-file=../../environments/cicd/cicd.tfvars
terraform apply -var-file=../../environments/cicd/cicd.tfvars -auto-approve

# Step 4 — Enable branch protection on the IaC repository
# (Applied via Git provider API — GitHub or CodeCommit depending on client preference)
cd ../branch-protection
terraform apply -var-file=../../environments/cicd/branch-protection.tfvars -auto-approve

# Step 5 — Run end-to-end AFT vending test (3 consecutive runs required for go-live sign-off)
cd ../../aft/account-requests
# First test vend (Sandbox account)
cp templates/sandbox-account-request.tf.example test-sandbox-01.tf
# Edit with test email and account name
git add test-sandbox-01.tf
git commit -m "test: vend Sandbox-Test-01 for AFT pipeline validation"
git push origin main
# Record start time; monitor CodePipeline console; record completion time
# Target: < 30 minutes from commit to fully enrolled account
```

The AFT buildspec for the account vending stage is shown below for reference.

```yaml
# modules/aft/pipeline/buildspecs/aft-account-provisioning.yml
version: 0.2
phases:
  install:
    runtime-versions:
      python: 3.11
    commands:
      - pip install -r requirements.txt
  pre_build:
    commands:
      - echo "Validating account request parameters..."
      - python scripts/validate_account_request.py
  build:
    commands:
      - echo "Vending account via Control Tower Account Factory..."
      - terraform init
      - terraform plan -out=aft.plan
      - terraform apply aft.plan
  post_build:
    commands:
      - echo "Applying AFT customisations..."
      - python scripts/apply_customisations.py
      - python scripts/validate_enrolment.py
```

### Validation

After deploying compute and CI/CD components, verify the following.

```bash
# Validate AFT pipeline is active
aws codepipeline get-pipeline-state \
  --name aws-aft-main-pipeline \
  --region us-east-1 \
  --query 'stageStates[*].{Stage:stageName,Status:latestExecution.status}'

# Validate AFT DynamoDB table
aws dynamodb describe-table \
  --table-name aft-request-metadata \
  --region us-east-1 \
  --query 'Table.TableStatus'
# Expected: "ACTIVE"

# Validate IaC CI/CD pipeline
aws codepipeline get-pipeline-state \
  --name lz-iac-pipeline \
  --region us-east-1 \
  --query 'stageStates[*].{Stage:stageName,Status:latestExecution.status}'

# Validate Lambda customisation functions
aws lambda list-functions \
  --region us-east-1 \
  --query 'Functions[?starts_with(FunctionName, `aft-`)].{Name:FunctionName,State:State}'

# Confirm AFT test account vend completed within SLA
# Check Control Tower dashboard for the new account:
aws controltower list-landing-zones --region us-east-1
# Verify new account appears in the target OU in Organizations:
aws organizations list-accounts-for-parent \
  --parent-id <sandbox-ou-id> \
  --query 'Accounts[*].{Id:Id,Name:Name,Status:Status}'
```

### Success Criteria

- AFT CodePipeline in `Succeeded` state for three consecutive test account vends
- All three test account vends complete in under 30 minutes (start-to-enrolled)
- Vended accounts enrolled in Control Tower guardrails (green status in CT dashboard)
- IaC CI/CD pipeline requires pull request approval before `terraform apply` stage proceeds
- Branch protection rules enforced on the `main` branch of the IaC repository
- Lambda customisation functions execute without errors for each OU path (Prod, NonProd, Sandbox)
- CI/CD Pipeline (Deliverable 20) accepted by Client IT Owner by Week 11

### Rollback

The following rollback procedures address AFT and CI/CD pipeline failure scenarios.

```bash
# AFT pipeline rollback — re-run failed vend from last known-good state
# 1. Identify the failed account request commit
git log --oneline modules/aft/account-requests/

# 2. Revert the bad request
git revert <commit-hash>
git push origin main

# 3. Manually clean up partially provisioned account if needed
aws organizations close-account --account-id <failed-account-id> --region us-east-1

# CI/CD pipeline rollback — revert last IaC change
cd landing-zone-iac
git revert HEAD
git push origin main
# Pipeline triggers automatically; terraform plan validates the revert
# Approve the plan in the pipeline approval stage
aws codepipeline put-approval-result \
  --pipeline-name lz-iac-pipeline \
  --stage-name Approve \
  --action-name ManualApproval \
  --result '{"summary":"Rollback approved","status":"Approved"}' \
  --token <approval-token> \
  --region us-east-1
```

---

## Monitoring

The monitoring layer deploys centralised CloudWatch dashboards, metric alarms, and SNS alerting in the Shared Services account, providing organisation-wide visibility into Control Tower compliance, Security Hub findings, GuardDuty threats, and landing zone operational health.

### Components

The table below lists all monitoring components deployed in this layer.

| Component | Region | Account | Specification | Purpose |
|-----------|--------|---------|---------------|---------|
| CloudWatch Dashboards | us-east-1 | Shared Services | 4 dashboards | Org-wide operational visibility |
| CloudWatch Metric Alarms | Both | Shared Services | 12 alarms; SNS notifications | Operational alerting |
| SNS Topics | Both | Shared Services | Email + HTTP endpoint | Alert distribution |
| CloudWatch Log Insights Queries | us-east-1 | Shared Services | 8 saved queries | Operational investigations |
| CloudWatch Cross-Account Observability | us-east-1 | Shared Services → All | Source/sink configuration | Multi-account metrics aggregation |
| Config Aggregator | us-east-1 | Audit | Organisation aggregator | Compliance score dashboard |
| Security Hub Insights | us-east-1 | Audit | 5 custom insights | Finding trend analysis |

### Script Location

Monitoring Terraform modules are located under `modules/monitoring/` in the IaC repository.

```
landing-zone-iac/
├── modules/
│   └── monitoring/
│       ├── cloudwatch-dashboards/  # Dashboard JSON definitions
│       ├── alarms/                 # CloudWatch metric alarms
│       ├── sns-topics/             # SNS topics and subscriptions
│       ├── log-insights-queries/   # Saved Log Insights query definitions
│       ├── cross-account-obs/      # CloudWatch cross-account observability
│       └── config-aggregator/      # AWS Config organisation aggregator
```

### Deployment Steps

Monitoring infrastructure is deployed during Phase 3 (Weeks 11–12), after compute and security layers are operational.

```bash
# Step 1 — Deploy SNS topics and subscriptions
cd modules/monitoring/sns-topics
terraform init -backend-config=../../backends/shared-services.tfvars
terraform plan -var-file=../../environments/monitoring/monitoring.tfvars
terraform apply -var-file=../../environments/monitoring/monitoring.tfvars -auto-approve

# Step 2 — Deploy CloudWatch cross-account observability (sink in Shared Services)
cd ../cross-account-obs
terraform init -backend-config=../../backends/shared-services.tfvars
terraform apply -var-file=../../environments/monitoring/monitoring.tfvars -auto-approve

# Step 3 — Deploy CloudWatch metric alarms
cd ../alarms
terraform init -backend-config=../../backends/shared-services.tfvars
terraform apply -var-file=../../environments/monitoring/monitoring.tfvars -auto-approve

# Step 4 — Deploy CloudWatch dashboards
cd ../cloudwatch-dashboards
terraform init -backend-config=../../backends/shared-services.tfvars
terraform apply -var-file=../../environments/monitoring/monitoring.tfvars -auto-approve

# Step 5 — Deploy Log Insights saved queries
cd ../log-insights-queries
terraform init -backend-config=../../backends/shared-services.tfvars
terraform apply -var-file=../../environments/monitoring/monitoring.tfvars -auto-approve

# Step 6 — Deploy AWS Config organisation aggregator (in Audit account)
cd ../config-aggregator
terraform init -backend-config=../../backends/audit.tfvars
terraform apply -var-file=../../environments/monitoring/monitoring.tfvars -auto-approve

# Step 7 — Test SNS alert delivery
aws sns publish \
  --topic-arn arn:aws:sns:us-east-1:<shared-services-account-id>:lz-critical-alerts \
  --message "Test alert from implementation guide validation" \
  --subject "LZ Monitoring Test" \
  --region us-east-1
```

The CloudWatch dashboard for landing zone operations is defined in the Terraform module. The following excerpt shows the key widget configuration.

```hcl
# modules/monitoring/cloudwatch-dashboards/main.tf (excerpt)
resource "aws_cloudwatch_dashboard" "lz_operations" {
  dashboard_name = "LandingZone-Operations"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "Security Hub Critical Findings"
          region = "us-east-1"
          metrics = [
            ["AWS/SecurityHub", "Findings.Critical", "AccountId", "ALL"]
          ]
          period = 300
          stat   = "Sum"
        }
      },
      {
        type = "metric"
        properties = {
          title  = "GuardDuty High Severity Findings"
          region = "us-east-1"
          metrics = [
            ["AWS/GuardDuty", "FindingCount", "Severity", "High"]
          ]
          period = 300
          stat   = "Sum"
        }
      },
      {
        type = "metric"
        properties = {
          title  = "CloudTrail API Error Rate"
          region = "us-east-1"
          metrics = [
            ["CloudTrailMetrics", "ErrorCount"]
          ]
          period = 300
          stat   = "Sum"
        }
      }
    ]
  })
}
```

### Validation

After deploying monitoring components, run the following validation commands.

```bash
# Validate SNS topic subscriptions confirmed
aws sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:us-east-1:<account-id>:lz-critical-alerts \
  --region us-east-1 \
  --query 'Subscriptions[*].{Protocol:Protocol,Endpoint:Endpoint,Status:SubscriptionArn}'

# Validate CloudWatch dashboards exist
aws cloudwatch list-dashboards \
  --dashboard-name-prefix LandingZone \
  --region us-east-1 \
  --query 'DashboardEntries[*].DashboardName'

# Validate CloudWatch alarms are in OK or INSUFFICIENT_DATA state
aws cloudwatch describe-alarms \
  --alarm-name-prefix lz- \
  --region us-east-1 \
  --query 'MetricAlarms[*].{Name:AlarmName,State:StateValue}'

# Validate Config aggregator is receiving data
aws configservice describe-configuration-aggregators \
  --region us-east-1 \
  --profile audit \
  --query 'ConfigurationAggregators[*].{Name:ConfigurationAggregatorName,Status:ConfigurationAggregatorArn}'

# Confirm cross-account observability (check a metric from a member account appears in Shared Services)
aws cloudwatch list-metrics \
  --namespace AWS/SecurityHub \
  --region us-east-1 \
  --profile shared-services \
  --query 'Metrics[0]'

# Trigger a test alarm manually and confirm SNS notification is received
aws cloudwatch set-alarm-state \
  --alarm-name lz-security-hub-critical-findings \
  --state-value ALARM \
  --state-reason "Validation test" \
  --region us-east-1
# Confirm email is received on the subscribed distribution list
```

### Success Criteria

- All four CloudWatch dashboards deployed and populated with metrics from all accounts
- All 12 CloudWatch metric alarms in `OK` or `INSUFFICIENT_DATA` state at go-live
- SNS test notification received on the client email distribution list within 60 seconds
- Config aggregator returning compliance data from all accounts and both regions
- CloudWatch cross-account observability confirmed: member account metrics visible in Shared Services
- Log Insights queries return results from the Log Archive log groups
- Monitoring and alerting demonstration accepted by Client IT Owner as part of UAT (Week 12)

### Rollback

Monitoring components are fully stateless and idempotent — they can be re-applied or rolled back without impact on the platform's operational state.

```bash
# Rollback specific dashboard to previous version
cd modules/monitoring/cloudwatch-dashboards
git checkout HEAD~1 -- templates/
terraform apply -var-file=../../environments/monitoring/monitoring.tfvars -auto-approve

# Disable a misconfigured alarm
aws cloudwatch disable-alarm-actions \
  --alarm-names lz-security-hub-critical-findings \
  --region us-east-1
# Investigate and fix the alarm configuration, then re-enable
aws cloudwatch enable-alarm-actions \
  --alarm-names lz-security-hub-critical-findings \
  --region us-east-1

# Full monitoring stack teardown (use only if complete re-deploy is required)
cd modules/monitoring
for module in config-aggregator log-insights-queries cloudwatch-dashboards alarms cross-account-obs sns-topics; do
  cd $module
  terraform destroy -var-file=../../../environments/monitoring/monitoring.tfvars -auto-approve
  cd ..
done
```

---

# Application Configuration

This section covers the application-layer configuration performed after infrastructure deployment — IAM Identity Center permission set assignments, AFT account customisation parameters, tagging policy enforcement, Cost Explorer and Budgets configuration, and the CI/CD pipeline governance settings. No traditional application workloads are in scope for this landing zone engagement.

## IAM Identity Center Permission Set Assignment

After IAM Identity Center is deployed (Phase 1), permission set assignments must be configured for the client team members. The following configuration is applied via Terraform.

```hcl
# modules/identity/idc/assignments.tf
resource "aws_ssoadmin_account_assignment" "platform_admin_assignments" {
  for_each = toset(var.platform_admin_user_ids)

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.platform_administrator.arn
  principal_id       = each.value
  principal_type     = "USER"
  target_id          = var.management_account_id
  target_type        = "AWS_ACCOUNT"
}
```

Run the following commands to apply and verify assignments.

```bash
# Apply permission set assignments
cd modules/identity/idc
terraform apply \
  -var="platform_admin_user_ids=[\"<user-id-1>\",\"<user-id-2>\"]" \
  -var-file=../../environments/mgmt.tfvars -auto-approve

# Verify assignment
aws sso-admin list-account-assignments \
  --instance-arn <sso-instance-arn> \
  --account-id <account-id> \
  --permission-set-arn <permission-set-arn> \
  --region us-east-1
```

## Tagging Policy Enforcement

The five mandatory tags are enforced via AWS Organizations Tag Policies. The policy is applied at the Root level to cover all accounts.

```json
{
  "tags": {
    "Environment": {
      "tag_key": { "@@assign": "Environment" },
      "tag_value": {
        "@@assign": ["Production", "NonProduction", "Development", "Sandbox", "Shared"]
      },
      "enforced_for": { "@@assign": ["ec2:instance", "rds:db", "s3:bucket", "lambda:function"] }
    },
    "Owner": {
      "tag_key": { "@@assign": "Owner" }
    },
    "CostCenter": {
      "tag_key": { "@@assign": "CostCenter" }
    },
    "Project": {
      "tag_key": { "@@assign": "Project" }
    },
    "DataClassification": {
      "tag_key": { "@@assign": "DataClassification" },
      "tag_value": {
        "@@assign": ["Public", "Internal", "Confidential", "Restricted"]
      }
    }
  }
}
```

## AWS Cost Explorer and Budgets Configuration

Per-account AWS Budgets are configured via the AFT customisation pipeline to ensure every vended account has spending controls active from the moment it is provisioned.

```hcl
# modules/security/budgets/main.tf
resource "aws_budgets_budget" "account_budget_80" {
  name         = "${var.account_name}-80pct-alert"
  budget_type  = "COST"
  limit_amount = var.monthly_budget_limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.budget_alert_emails
  }
}

resource "aws_budgets_budget" "account_budget_100" {
  name         = "${var.account_name}-100pct-alert"
  budget_type  = "COST"
  limit_amount = var.monthly_budget_limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.budget_alert_emails
  }
}
```

## Security Controls Validation Checklist

After completing all application configuration steps, validate the following items before proceeding to Integration Testing.

- [ ] IAM Identity Center SSO login validated for all five permission sets by a client team member
- [ ] Tag Policy applied at Root level; non-compliant resource creation returns error in test account
- [ ] AWS Budgets active on all provisioned accounts at 80% and 100% thresholds
- [ ] Cost Explorer enabled on Management account; linked accounts data visible
- [ ] CI/CD pipeline branch protection enforced — direct push to `main` branch rejected
- [ ] Terraform plan output reviewed and approved by Client IT Owner before any `apply` in Production OUs
- [ ] All secrets (break-glass credentials, VPN PSK) stored in AWS Secrets Manager with KMS encryption
- [ ] Drift detection confirmed: `terraform plan` returns no changes for all deployed stacks

---

# Integration Testing

This section defines the integration test procedures that validate end-to-end connectivity and correctness across all landing zone components before UAT and go-live. Tests are executed primarily in Weeks 10–12.

## Test Categories and Scope

The following table summarises all integration test categories, their scope, and the acceptance criteria that must be satisfied.

| Test Category | Components Tested | Acceptance Criteria | Week |
|---------------|-------------------|---------------------|------|
| SCP Enforcement | All 5 SCPs; RCP | All deny rules trigger `AccessDenied`; zero false positives | 10 |
| Account Vending | AFT pipeline | < 30 min; 3 consecutive passes; account enrolled in CT guardrails | 11 |
| Network Flow | TGW, Network Firewall, NAT GW, VPN | Spoke-to-spoke, north-south egress, and VPN routing all pass | 8 |
| Security Posture | Security Hub, GuardDuty, Config | FSBP score ≥ 80%; zero critical findings in Production | 11 |
| IAM Identity Center SSO | All permission sets; all accounts | All five permission sets grant expected access; MFA enforced | 10 |
| Monitoring & Alerting | CloudWatch, SNS | All alarms fire; SNS delivery confirmed | 11 |
| Logging Delivery | CloudTrail, Config | Log delivery to Log Archive confirmed in both regions | 10 |
| DR / Multi-Region | us-east-2 governance | Config, CloudTrail, Security Hub active and aggregating from us-east-2 | 11 |

## SCP Enforcement Test Procedures

The following tests simulate policy-violating API calls to confirm each SCP is operating correctly. All tests should be run from a test IAM role in a Workloads-NonProd account.

```bash
# Test 1: Deny root account usage
# (Simulated by attempting root-only API from a test role — expect AccessDenied from SCP)
aws iam create-virtual-mfa-device \
  --virtual-mfa-device-name test-root-mfa \
  --profile workload-test-role 2>&1
# Expected: "AccessDenied" with SCP reference in error

# Test 2: Deny API calls outside allowed regions
aws ec2 describe-instances --region ap-southeast-1 --profile workload-test-role 2>&1
# Expected: "AccessDenied" — region restriction SCP

# Test 3: Deny CloudTrail disable
aws cloudtrail stop-logging \
  --name org-trail \
  --profile workload-test-role 2>&1
# Expected: "AccessDenied" — CloudTrail protection SCP

# Test 4: RCP data perimeter test — write to external S3 bucket
aws s3 cp test.txt s3://<bucket-outside-organisation>/ \
  --profile workload-test-role 2>&1
# Expected: "AccessDenied" — RCP data perimeter

# Test 5: Confirm legitimate us-east-1 API call succeeds
aws ec2 describe-instances --region us-east-1 --profile workload-test-role
# Expected: Successful response (empty or with instances)
```

## Account Vending Validation

The following procedure validates the AFT pipeline meets the < 30-minute SLA across three consecutive test runs.

```python
# scripts/validate_aft_timing.py
import boto3
import time
import datetime

def validate_aft_vend(pipeline_name: str, region: str = "us-east-1") -> dict:
    """Validate AFT account vending completes within 30 minutes."""
    client = boto3.client("codepipeline", region_name=region)
    
    start_time = datetime.datetime.utcnow()
    print(f"AFT vend started at {start_time.isoformat()}")
    
    # Poll pipeline state every 30 seconds
    while True:
        response = client.get_pipeline_state(name=pipeline_name)
        stages = response["stageStates"]
        
        all_succeeded = all(
            s.get("latestExecution", {}).get("status") == "Succeeded"
            for s in stages
        )
        
        elapsed = (datetime.datetime.utcnow() - start_time).total_seconds() / 60
        
        if all_succeeded:
            print(f"AFT vend completed in {elapsed:.1f} minutes")
            return {"success": True, "duration_minutes": elapsed, "sla_met": elapsed < 30}
        
        if elapsed > 35:
            print(f"WARN: AFT vend exceeded 35-minute threshold")
            return {"success": False, "duration_minutes": elapsed, "sla_met": False}
        
        time.sleep(30)

# Run three consecutive validations
for run in range(1, 4):
    print(f"\n=== AFT Validation Run {run}/3 ===")
    result = validate_aft_vend("aws-aft-main-pipeline")
    print(f"Run {run}: {'PASS' if result['sla_met'] else 'FAIL'} — {result['duration_minutes']:.1f} min")
```

## Network Flow Test Procedures

After Phase 2 networking deployment, the following tests confirm spoke-to-spoke, egress, and VPN traffic flows correctly.

```bash
# Test 1: Spoke-to-spoke traffic via Network Firewall
# From an EC2 instance in Dev spoke VPC (10.1.0.0/20):
ping -c 4 10.2.0.10  # IP in Prod spoke VPC
# Expected: ICMP replies (permitted by east-west stateful rule)

# Test 2: Centralised NAT Gateway egress
# From an EC2 instance in Dev spoke VPC:
curl -s https://checkip.amazonaws.com
# Expected: One of the Hub VPC NAT Gateway EIPs

# Test 3: VPN routing — on-premises reachability
ping -c 4 192.168.1.1  # On-premises gateway IP
# Expected: ICMP replies

# Test 4: Confirm no direct internet gateway in spoke VPCs
aws ec2 describe-internet-gateways \
  --filters Name=attachment.vpc-id,Values=<dev-spoke-vpc-id> \
  --region us-east-1
# Expected: Empty result (no IGW attached)

# Test 5: TGW inter-region reachability
# From an EC2 instance in us-east-1 Dev spoke:
ping -c 4 10.64.1.10  # IP in us-east-2 spoke VPC
# Expected: ICMP replies via TGW peering
```

---

# Security Validation

This section documents the formal security validation procedures executed before go-live, covering SCP/RCP enforcement validation, IAM Access Analyser review, Security Hub FSBP compliance scoring, GuardDuty baseline, and the go-live security readiness checklist.

## Security Validation Procedures

All security validation is performed in Weeks 10–12 by the Vendor Security Engineer and Vendor QA Engineer, with results documented in the Test Results Report (Deliverable 21).

### IAM Access Analyser Review

IAM Access Analyser is deployed in all accounts and configured with the Organisation as the zone of trust. No external access findings are permitted in Production or Platform accounts at go-live.

```bash
# List all external access findings across org
aws accessanalyzer list-findings \
  --analyzer-arn arn:aws:access-analyzer:us-east-1:<account-id>:analyzer/lz-org-analyser \
  --filter '{"resourceType":{"eq":["AWS::S3::Bucket","AWS::IAM::Role"]}}' \
  --region us-east-1 \
  --query 'findings[?status==`ACTIVE`].{Resource:resource,Type:findingType,Principal:principal}'
# Expected: Zero ACTIVE findings in Production and Platform accounts
```

### Security Hub FSBP Compliance Score

The FSBP compliance score must reach ≥ 80% in all Production and Platform accounts before go-live.

```bash
# Get Security Hub compliance score by account
aws securityhub get-insight-results \
  --insight-arn arn:aws:securityhub:us-east-1::insight/aws/securityhub/6 \
  --region us-east-1 \
  --profile audit

# List all critical findings (must be zero in Production/Platform)
aws securityhub get-findings \
  --filters '{
    "SeverityLabel": [{"Value": "CRITICAL", "Comparison": "EQUALS"}],
    "RecordState": [{"Value": "ACTIVE", "Comparison": "EQUALS"}],
    "WorkflowStatus": [{"Value": "NEW", "Comparison": "EQUALS"}]
  }' \
  --region us-east-1 \
  --profile audit \
  --query 'Findings[*].{Id:Id,Title:Title,Resource:Resources[0].Id}'
```

### GuardDuty Baseline

GuardDuty threat detection must be confirmed active in all accounts before go-live.

```bash
# Confirm GuardDuty enabled in all member accounts
aws guardduty list-members \
  --detector-id <admin-detector-id> \
  --only-associated true \
  --region us-east-1 \
  --profile audit \
  --query 'Members[*].{AccountId:AccountId,Status:RelationshipStatus,UpdatedAt:UpdatedAt}'
# Expected: All accounts show "Enabled" status

# Simulate a GuardDuty finding (using GuardDuty sample findings feature)
aws guardduty create-sample-findings \
  --detector-id <detector-id> \
  --finding-types '["UnauthorizedAccess:IAMUser/MaliciousIPCaller"]' \
  --region us-east-1 \
  --profile audit
# Confirm finding appears in Security Hub within 5 minutes
```

## Quality Gates

Each phase of the engagement has a defined quality gate. All gate criteria must pass before the project advances to the next phase.

### Phase 1 Quality Gate (Week 4)

- [ ] Control Tower dashboard shows all enrolled accounts in green compliance status
- [ ] Seven-OU hierarchy deployed and verified with correct SCP inheritance
- [ ] All five SCP deny rules validated by simulated violation tests
- [ ] RCP data perimeter validated — external S3 write denied
- [ ] CloudTrail org trail delivering events in both regions
- [ ] IAM Identity Center SSO validated for all five permission sets
- [ ] Architecture Design Document approved and signed by Client Executive Sponsor

### Phase 2 Quality Gate (Week 8)

- [ ] Both Transit Gateways in `available` state; inter-region peering operational
- [ ] Both Network Firewalls in `READY` state; stateful rules validated
- [ ] VPN tunnels `UP` in both regions; BGP session established
- [ ] Spoke-to-spoke traffic flows through Network Firewall per east-west rules
- [ ] NAT Gateway egress confirmed via Hub VPC EIPs
- [ ] VPC IPAM allocating /20 blocks successfully for new spoke VPCs
- [ ] Network Testing Report (Deliverable 15) delivered and accepted

### Phase 3 Quality Gate (Week 11)

- [ ] Security Hub FSBP score ≥ 80% across all Production and Platform accounts
- [ ] Zero critical Security Hub findings in Production accounts
- [ ] GuardDuty enabled and alert routing confirmed in all accounts and both regions
- [ ] AFT pipeline vends accounts in < 30 minutes — three consecutive successful runs
- [ ] Two workload accounts (1 Prod, 1 NonProd) vended and guardrail-enrolled
- [ ] CI/CD pipeline enforces branch protection and dual-approval before production apply
- [ ] CloudTrail Lake event data store enabled with sample queries returning results

### Go-Live Quality Gate (Week 12)

- [ ] All P1 UAT issues resolved; UAT sign-off document signed by Executive Sponsor and IT Owner
- [ ] All accounts enrolled in Control Tower guardrails — green status
- [ ] Zero critical Security Hub findings in all Production and Platform accounts
- [ ] GuardDuty SNS alert routing tested end-to-end
- [ ] AWS Budgets alerts active for all accounts
- [ ] All operational runbooks delivered, reviewed, and dry-run completed
- [ ] Break-glass access process confirmed and documented with client security team
- [ ] Client team trained; training materials delivered
- [ ] Go-Live Confirmation document signed by Client Executive Sponsor and Client IT Owner

---

# Migration & Cutover

This section defines the cutover plan, go/no-go criteria, and rollback strategy for the go-live event at the end of Week 12. As this is a greenfield engagement, there is no data migration required; the cutover constitutes a formal transfer of operational ownership from the vendor team to the client team.

## Migration Approach

The go-live migration type is **Operational Handover** — the landing zone is already fully functional in AWS by the end of Week 11; go-live is the formal transfer of operational ownership. No data migration is required as the client is entering AWS from a fully on-premises starting point with no existing cloud footprint.

The migration plan therefore focuses on three activities: final validation and sign-off, the formal ownership transfer, and the commencement of the 4-week hypercare period.

## Cutover Plan

The cutover window is the final day of Week 12 and follows the structured timeline below.

| Time | Activity | Owner | Gate |
|------|----------|-------|------|
| T-7 days | Final UAT sign-off obtained; go-live readiness checklist signed | Vendor PM + Client IT Owner | UAT sign-off document |
| T-7 days | Go-live date confirmed in writing to all stakeholders | Vendor PM | Stakeholder confirmation email |
| T-3 days | Final IaC pipeline health check; AFT pipeline confirmation | Vendor Eng × 2 | All pipeline stages `Succeeded` |
| T-3 days | All runbooks reviewed with client team | Vendor Arch | Runbook acceptance |
| T-1 day | Security Hub baseline snapshot captured for go-live baseline | Vendor Security Eng | Snapshot S3 key recorded |
| T-1 day | CloudWatch dashboard screenshot for go-live baseline record | Vendor Eng | Screenshot archived |
| T-1 day | Break-glass access process confirmed with client security team | Vendor Arch + Client Security | Documented process signed |
| T (Go-Live) | Formal transfer of PlatformAdministrator permission set management to Client IT Owner | Vendor PM + Client IT Owner | Go-Live Confirmation signed |
| T (Go-Live) | Vendor delivery team transitions to hypercare support model | Vendor PM | Hypercare commencement email |
| T+1 day | Post-go-live check call | Vendor PM + Client IT Owner | No P1 issues outstanding |
| T+1 day | Confirm SNS alerting active and tested | Vendor Security Eng | Test notification confirmed |

### Go/No-Go Criteria

The following binary criteria must all pass for the go-live to proceed. Any `FAIL` result is a P1 blocker that must be resolved before the go-live window proceeds.

- [ ] **PASS/FAIL** — All P1 UAT issues resolved
- [ ] **PASS/FAIL** — All accounts enrolled in Control Tower guardrails (green status)
- [ ] **PASS/FAIL** — Zero critical Security Hub findings in Production and Platform accounts
- [ ] **PASS/FAIL** — AFT vending pipeline validated (< 30 min; 3 consecutive runs)
- [ ] **PASS/FAIL** — Two workload accounts vended and guardrail-enrolled
- [ ] **PASS/FAIL** — CloudTrail org trail delivering events in both regions
- [ ] **PASS/FAIL** — GuardDuty enabled and alert routing confirmed
- [ ] **PASS/FAIL** — AWS Budgets alerts active for all accounts
- [ ] **PASS/FAIL** — Client team trained; runbooks delivered and accepted
- [ ] **PASS/FAIL** — Break-glass access process confirmed with client security team

## Rollback Procedures

As this is a greenfield engagement, a traditional rollback to a pre-engagement state is not applicable. The rollback strategy addresses specific component failure scenarios during the hypercare period.

### Control Tower Deployment Failure Rollback

```bash
# Step 1: Identify failure in CT dashboard
aws controltower list-landing-zones --region us-east-1

# Step 2: Use CT landing zone repair workflow
# Navigate to CT console → Landing Zone → Repair

# Step 3: If repair fails, re-run AFT customisations from IaC state
cd modules/aft/pipeline
terraform refresh -var-file=../../environments/aft/aft.tfvars
terraform apply -var-file=../../environments/aft/aft.tfvars
# Estimated recovery time: 2–4 hours
```

### Network Firewall Policy Rollback

```bash
# Revert firewall policy to previous version (< 30 minutes)
cd modules/networking/network-firewall
git checkout HEAD~1 -- policies/
terraform apply -var-file=../../environments/network-hub/us-east-1.tfvars -auto-approve
terraform apply -var-file=../../environments/network-hub/us-east-2.tfvars -auto-approve
# Validate traffic flows immediately after apply
```

### SCP Misconfiguration Rollback

```bash
# Revert SCP to previous version (< 15 minutes)
cd modules/governance/scp
git log --oneline policies/ | head -5
git checkout <last-known-good-commit> -- policies/
terraform apply -var-file=../../environments/mgmt.tfvars -auto-approve
# Validate SCP deny tests still pass after revert
```

---

# Operational Handover

This section covers the full documentation handover, support transition, and hypercare plan for the 4-week period following go-live (Weeks 13–16).

## Documentation Handover

The following artefacts are delivered to the client as part of the operational handover package by end of Week 12.

- [ ] As-Built Architecture Document (Deliverable 23) — final production architecture diagrams and configuration specifications
- [ ] Phase 1 Architecture Design Document (Deliverable 3) — preserved for future architecture reference
- [ ] IaC Repository (Terraform + AFT) — transferred to client-managed Git repository
- [ ] Operational Runbook 1: Account Vending via AFT
- [ ] Operational Runbook 2: SCP Policy Change Process
- [ ] Operational Runbook 3: Security Hub Finding Triage and Escalation
- [ ] Operational Runbook 4: Network Firewall Policy Update
- [ ] Operational Runbook 5: Incident Response (with CloudTrail Lake investigation queries)
- [ ] Operational Runbook 6: CloudTrail Lake Security Investigation Queries
- [ ] Test Results Report (Deliverable 21) — all test types, UAT sign-off
- [ ] Administrator Training Materials (Deliverable 24) — recorded sessions and slide decks
- [ ] Optimisation Recommendations Report (Deliverable 26) — delivered Week 16

## Support Transition

### Support Model During Hypercare

The following support tier model is active from go-live through to end of Week 16.

| Tier | Responsibility | Coverage | Response Time | Escalation |
|------|----------------|----------|---------------|------------|
| L1 — Vendor Hypercare | Initial triage of landing zone issues; SCP/policy guidance; AFT pipeline support | Mon–Fri 09:00–17:00 (client time zone) | < 4 hours | To L2 after 4 hours |
| L2 — Vendor Senior Engineer | Technical troubleshooting; configuration adjustments within original scope | Mon–Fri 09:00–17:00 (client time zone) | < 8 hours | To L3 after 8 hours |
| L3 — Vendor Architect + AWS Support | Expert resolution; AWS-level escalation via Business Support | 24×7 for P1 | 2 hours (P1, 24×7) | To AWS Support if required |

### Hypercare Period

The hypercare period runs from go-live (start of Week 13) through to end of Week 16 — **4 weeks** as specified in the SOW.

**Coverage:** Business hours Monday–Friday; P1 incidents escalated to 24-hour on-call with 2-hour response SLA.

**In Scope for Hypercare:**
- Triage and resolution of issues arising from deployed landing zone components
- Support for the first live workload account vending via AFT
- Guidance on Security Hub finding triage and GuardDuty alert investigation
- Minor configuration adjustments (SCP updates, permission set changes, firewall rule additions) within original scope
- Assistance with on-premises VPN routing issues post-go-live

**Out of Scope for Hypercare:**
- New feature development or scope additions (require change control)
- Application workload support
- Third-party tooling support (Terraform Cloud, identity provider, SIEM)
- Any engagement scope item not included in the original SOW

### Hypercare SLAs

| Priority | Definition | Response Time | Resolution Target |
|----------|-----------|--------------|------------------|
| P1 — Critical | Landing zone governance failure; production accounts unenrolled; SCPs non-functional | 2 hours (24×7) | 8 hours |
| P2 — High | AFT pipeline failure; Security Hub/GuardDuty outage; significant compliance regression | 4 hours (business hours) | 24 hours |
| P3 — Medium | Non-critical component issues; minor configuration discrepancies | 1 business day | 5 business days |
| P4 — Low | Documentation corrections; enhancement requests | 2 business days | Hypercare backlog |

### Transition to Steady-State

- **Weeks 13–14:** Vendor-led triage with client team in observation/shadowing mode
- **Weeks 15–16:** Client-led with vendor on standby support; client team handles first-line triage independently
- **Week 17+:** Client-owned steady-state operations; vendor engagement concluded; Managed Services Agreement available separately from Amatra if ongoing support is required

## Handover Checklist

The following items must be completed before the hypercare period ends (Week 16).

- [ ] All six operational runbooks delivered, reviewed, and dry-run completed with client team
- [ ] IaC repository transferred to client-managed Git with all branches, tags, and commit history
- [ ] Terraform state files accessible from client-managed Terraform Cloud workspaces
- [ ] Training completed for all user groups (see Training Program section)
- [ ] Monitoring dashboards reviewed with client operations team
- [ ] Break-glass access credentials documented and stored securely (AWS Secrets Manager)
- [ ] Emergency contact list (vendor and AWS Support) documented and distributed
- [ ] Optimisation Recommendations Report (Deliverable 26) delivered
- [ ] Hypercare Support Closeout Report (Deliverable 27) signed by Client Executive Sponsor

---

# Training Program

This section defines the complete training programme delivered to the client team as part of the operational handover. All training sessions are delivered in Week 12 and recorded for on-demand reference.

## Training Overview

### Objectives

The training programme ensures that the client's platform administrators and security team achieve operational competency with the AWS Multi-Account Landing Zone before go-live, and establishes ongoing learning paths for new team members onboarded after the engagement.

### Training Approach

- **Role-Based Delivery:** Content is tailored to the specific responsibilities of each audience (Platform Administrators vs. Security Operations team)
- **Hands-On Focus:** All technical modules include live demonstrations and guided exercises in a dedicated training account
- **Recorded Sessions:** Every VILT and ILT session is screen-recorded and delivered as part of the training materials package
- **Two-Track Structure:** Cloud Infrastructure Track (Platform Administrator audience) and Security Operations Track (Security Lead audience)

## Training Schedule

The table below lists all 10 training modules, covering both delivery tracks and all user roles.

| Module ID | Module Name | Target Audience | Duration | Format | Prerequisites |
|-----------|-------------|-----------------|----------|--------|---------------|
| TRN-001 | Landing Zone Architecture Overview | All | 2 hours | ILT | None |
| TRN-002 | AWS Control Tower Operations | Platform Administrators | 2 hours | VILT + Demo | TRN-001 |
| TRN-003 | Account Factory for Terraform (AFT) | Platform Administrators | 2 hours | Hands-On Lab | TRN-002 |
| TRN-004 | Day-2 Operations: Config, CloudWatch, Budgets | Platform Administrators | 2 hours | VILT + Demo | TRN-002 |
| TRN-005 | IAM Identity Center Administration | Platform Administrators | 1.5 hours | Hands-On Lab | TRN-002 |
| TRN-006 | Security Hub Finding Triage | Security Team | 2 hours | VILT + Demo | TRN-001 |
| TRN-007 | GuardDuty Threat Investigation | Security Team | 2 hours | VILT + Demo | TRN-006 |
| TRN-008 | CloudTrail Lake Investigation Queries | Security Team | 2 hours | Hands-On Lab | TRN-001 |
| TRN-009 | SCP and RCP Policy Management | Security Team + Platform Admins | 1.5 hours | ILT | TRN-002 |
| TRN-010 | Runbook Walkthrough and Q&A | All | 2 hours | Workshop | All modules |

## Cloud Infrastructure Track — Platform Administrator Training

### TRN-001: Landing Zone Architecture Overview (2 hours, ILT)

This module is delivered to all attendees and provides the architectural foundation needed for all subsequent modules.

**Learning Objectives:**
- Describe the AWS Multi-Account Landing Zone architecture and component interactions
- Explain the seven-OU hierarchy and how policy inheritance works through the OU tree
- Identify all shared platform accounts (Log Archive, Audit, Shared Services, Network Hub) and their roles
- Explain the data flow from account provisioning through to log delivery and compliance monitoring

**Content Outline:**
1. Architecture walkthrough with Figure 1 diagram (30 min)
   - OU hierarchy and policy inheritance
   - Shared account roles and data flows
   - Network hub-and-spoke topology overview
2. Key AWS services in the landing zone (30 min)
   - Control Tower, Organizations, IAM Identity Center
   - Transit Gateway, Network Firewall, VPC IPAM
   - Security Hub, GuardDuty, Config, CloudTrail
3. IaC and automation overview (30 min)
   - Terraform repository structure
   - AFT pipeline overview
   - CI/CD pipeline and change management
4. Q&A and architecture quiz (30 min)

**Materials Required:**
- Presentation slides (Architecture Overview deck)
- Figure 1: Architecture diagram printed/shared
- Landing zone architecture summary card (1-page quick reference)

---

### TRN-002: AWS Control Tower Operations (2 hours, VILT + Demo)

**Learning Objectives:**
- Navigate the Control Tower dashboard and interpret compliance status
- Understand guardrail categories (mandatory, strongly recommended, elective) and their enforcement mechanisms
- Enrol a new OU in Control Tower guardrails
- Interpret and respond to Control Tower drift notifications

**Content Outline:**
1. Control Tower console navigation (30 min)
   - Dashboard overview; compliance status; account enrolment view
2. Guardrail management (30 min)
   - Mandatory vs. elective guardrails; SCP-backed vs. AWS Config-backed guardrails
3. OU changes and account enrolment (30 min)
   - Live demo: enrol a new OU; move an account between OUs
4. Drift detection and remediation (20 min)
   - Interpreting drift notifications; re-enrolling a drifted account
5. Q&A (10 min)

**Lab Exercises:**
- Exercise 1: Navigate to the Audit account in Control Tower and review compliance status
- Exercise 2: Identify which guardrails are applied to the Workloads-Prod OU
- Exercise 3: Simulate an account enrolment request in the training account

**Materials Required:**
- Control Tower console access (training account with PlatformAdministrator permission set)
- Control Tower Operations quick reference card

---

### TRN-003: Account Factory for Terraform (AFT) (2 hours, Hands-On Lab)

**Learning Objectives:**
- Submit an AFT account request by editing and committing a Terraform account request file
- Monitor the AFT CodePipeline execution and interpret build logs
- Apply OU-specific customisations and understand the customisation pipeline
- Troubleshoot common AFT pipeline failures using CloudWatch Logs

**Content Outline:**
1. AFT architecture recap (20 min)
   - CodePipeline stages; DynamoDB state; Lambda customisations
2. Submitting an account request (40 min)
   - Live walkthrough: edit account request template, commit, push, and observe pipeline
3. Monitoring pipeline execution (30 min)
   - CodePipeline console; CodeBuild logs; Control Tower account enrolment status
4. Troubleshooting common issues (20 min)
   - Pipeline stage failures; account request validation errors; customisation failures
5. Q&A (10 min)

**Lab Exercises:**
- Exercise 1: Complete and submit a Sandbox account request — measure time to enrolment
- Exercise 2: Review the AFT customisation Lambda logs for the test account vend
- Exercise 3: Identify and interpret a simulated AFT pipeline failure in CloudWatch Logs

**Materials Required:**
- AFT training account with CodePipeline access
- AFT account request template (pre-populated with training values)
- AFT Operations runbook

---

### TRN-004: Day-2 Operations — Config, CloudWatch, Budgets (2 hours, VILT + Demo)

**Learning Objectives:**
- Navigate the Config aggregator and interpret compliance scores by account and OU
- Navigate the centralised CloudWatch dashboards in the Shared Services account
- Create and interpret cost reports in Cost Explorer; review Budget alert configurations
- Respond to Config compliance notifications using the Security Hub finding triage runbook

**Content Outline:**
1. AWS Config compliance monitoring (40 min)
   - Config aggregator dashboard; conformance pack scores; non-compliant resource drill-down
2. CloudWatch operational dashboards (40 min)
   - Landing Zone Operations dashboard walkthrough; metric alarm review
3. Cost governance with Cost Explorer and Budgets (30 min)
   - Linked account cost breakdown; Budget alert review; tagging coverage report
4. Q&A (10 min)

**Materials Required:**
- Read-only access to Config aggregator (Audit account)
- ReadOnly access to Shared Services account CloudWatch dashboards
- FinOps permission set access for Cost Explorer demo

---

### TRN-005: IAM Identity Center Administration (1.5 hours, Hands-On Lab)

**Learning Objectives:**
- Create and manage user accounts and group memberships in IAM Identity Center
- Assign permission sets to groups for specific AWS accounts
- Manage API keys and service accounts
- Interpret and review the IAM Identity Center access activity logs

**Content Outline:**
1. Identity Center user and group management (30 min)
2. Permission set assignment to accounts and OUs (30 min)
3. API access key management (15 min)
4. Audit log review (15 min)

**Lab Exercises:**
- Exercise 1: Create a test user and assign them to the SecurityAuditor permission set in the Audit account
- Exercise 2: Review the IAM Identity Center sign-in logs in CloudTrail for a test user

**Materials Required:**
- PlatformAdministrator access to Identity Center console (training account)

---

## Security Operations Track

### TRN-006: Security Hub Finding Triage (2 hours, VILT + Demo)

**Learning Objectives:**
- Navigate the Security Hub aggregated findings view in the Audit account
- Interpret FSBP control pass/fail status and compliance scoring
- Apply the Security Hub Finding Triage runbook to a sample critical finding
- Configure finding suppression rules for known-acceptable deviations

**Content Outline:**
1. Security Hub console and finding views (30 min)
   - Summary dashboard; FSBP compliance score; finding severity breakdown
2. Triage runbook walkthrough (45 min)
   - Live walkthrough with sample critical finding: identify → investigate → remediate → verify
3. Suppression rules and custom insights (30 min)
4. Q&A (15 min)

**Lab Exercises:**
- Exercise 1: Triage a sample `IAM.1: MFA should be enabled for root account` finding
- Exercise 2: Create a suppression rule for a known-acceptable S3 bucket policy deviation

**Materials Required:**
- SecurityAuditor access to Audit account Security Hub
- Security Hub Finding Triage runbook (Deliverable 22, Runbook 3)

---

### TRN-007: GuardDuty Threat Investigation (2 hours, VILT + Demo)

**Learning Objectives:**
- Navigate the GuardDuty findings view and interpret finding severity and type
- Classify threat finding types (Reconnaissance, Backdoor, Trojan, etc.)
- Apply the Incident Response runbook to a GuardDuty high-severity finding
- Understand the alert routing path from GuardDuty to SNS to email

**Content Outline:**
1. GuardDuty findings overview (30 min)
   - Finding taxonomy; severity classification; evidence sources (VPC FL, CT events, DNS)
2. Incident response runbook walkthrough (45 min)
   - Live walkthrough with sample high-severity finding
3. Alert routing path and SNS configuration review (25 min)
4. GuardDuty integration roadmap: future SIEM integration (10 min)
5. Q&A (10 min)

**Lab Exercises:**
- Exercise 1: Investigate a sample `UnauthorizedAccess:IAMUser/MaliciousIPCaller` finding
- Exercise 2: Confirm the alert routing path from GuardDuty → Security Hub → SNS → email

**Materials Required:**
- SecurityAuditor access to GuardDuty (Audit account)
- Incident Response runbook (Deliverable 22, Runbook 5)
- Sample GuardDuty findings created by `create-sample-findings` (pre-populated in training account)

---

### TRN-008: CloudTrail Lake Investigation Queries (2 hours, Hands-On Lab)

**Learning Objectives:**
- Navigate the CloudTrail Lake console and query editor
- Write SQL queries to investigate API activity and security events
- Extract audit evidence for compliance reporting
- Use pre-built investigation query templates from the delivered runbook

**Content Outline:**
1. CloudTrail Lake architecture and data stores (20 min)
2. Writing investigation queries (50 min)
   - SQL syntax for CloudTrail Lake; field reference; common query patterns
3. Pre-built query template walkthrough (30 min)
   - Root account activity query; MFA disable attempts; cross-account calls
4. Audit evidence extraction for compliance reporting (10 min)
5. Q&A (10 min)

**Lab Exercises:**
- Exercise 1: Query all API calls made by the root account in the last 30 days
- Exercise 2: Identify all `StopLogging` API calls across all accounts in the last 90 days
- Exercise 3: Extract a 7-day audit evidence report for a specific workload account

**Materials Required:**
- SecurityAuditor access to CloudTrail Lake (Audit account)
- CloudTrail Lake Investigation Queries runbook (Deliverable 22, Runbook 6)
- Sample query templates pre-loaded in the training account

---

## End User Training

### TRN-009: SCP and RCP Policy Management (1.5 hours, ILT)

This module covers the process for proposing, reviewing, approving, and deploying SCP and RCP changes through the CI/CD pipeline, targeting both Security Team and Platform Administrator audiences.

**Learning Objectives:**
- Understand the SCP/RCP policy change process and approval requirements
- Identify the impact of an SCP change before deploying to Production OUs
- Test SCP changes in the Sandbox OU before promoting to Workloads-Prod
- Use the CI/CD pipeline for SCP deployment with dual-approval workflow

**Content Outline:**
1. SCP and RCP policy structure review (20 min)
   - Current policy set; OU inheritance model; deny vs. allow logic
2. Policy change process walkthrough (40 min)
   - Raise a pull request in the IaC repository for a simulated SCP change
   - Terraform plan review; impact analysis; dual-approval workflow
   - Deploy to Sandbox OU; validate; promote to Workloads-Prod
3. Testing SCP changes without production impact (20 min)
   - Sandbox OU testing pattern; simulated violation test procedure
4. Q&A (10 min)

**Lab Exercises:**
- Exercise 1: Raise a pull request for a simulated SCP modification (adding a new deny statement)
- Exercise 2: Review the Terraform plan output and confirm expected changes
- Exercise 3: Simulate the dual-approval workflow with the vendor team acting as approver 2

**Materials Required:**
- IaC repository access (branch write access for SCP module)
- SCP Policy Change Process runbook (Deliverable 22, Runbook 2)

---

### TRN-010: Runbook Walkthrough and Q&A Workshop (2 hours, Workshop)

This final module is delivered to all attendees and provides a structured walkthrough of all six operational runbooks, followed by open Q&A to ensure the client team is confident to operate independently.

**Learning Objectives:**
- Navigate each of the six operational runbooks confidently
- Identify the correct runbook and procedure for common operational scenarios
- Know when and how to escalate to vendor support during and after hypercare
- Understand the steady-state change management process post-handover

**Content Outline:**
1. Runbook walkthroughs — 10 minutes per runbook (60 min)
   - Runbook 1: Account Vending via AFT
   - Runbook 2: SCP Policy Change Process
   - Runbook 3: Security Hub Finding Triage
   - Runbook 4: Network Firewall Policy Update
   - Runbook 5: Incident Response
   - Runbook 6: CloudTrail Lake Investigation Queries
2. Scenario exercises — apply the correct runbook (30 min)
   - Scenario A: A new business unit needs an AWS account in under 30 minutes
   - Scenario B: A critical Security Hub finding is raised against a Production account
   - Scenario C: A Network Firewall rule is blocking legitimate workload traffic
3. Open Q&A and knowledge check (30 min)

**Materials Required:**
- All six printed/digital runbooks
- Scenario exercise cards (pre-prepared by Vendor Technical Writer)
- Hypercare contact card with escalation phone numbers and email addresses

---

## Training Materials

The following materials are delivered as part of the training package.

- Administrator Guide (PDF) — Control Tower, AFT, IAM Identity Center operations
- Security Operations Guide (PDF) — Security Hub, GuardDuty, CloudTrail Lake
- Quick Reference Cards (per role) — Platform Administrator; Security Operator
- Video recordings of all VILT and ILT sessions (MP4, hosted in client S3 bucket)
- Lab exercise workbooks (all 10 modules)
- All six operational runbooks (PDF and Markdown)
- Architecture Overview slide deck
- Knowledge check quiz questions (with answer key for facilitators)

## Training Effectiveness

The following metrics are tracked for all training modules to confirm competency before the hypercare period ends.

| Metric | Target |
|--------|--------|
| Training Completion Rate | 100% of assigned platform admins and security team members |
| Knowledge Check Pass Rate | ≥ 85% on first attempt per module |
| Post-Training Satisfaction | ≥ 4.0 / 5.0 average across all modules |
| Operational Competency | Client team resolves first P3 issue independently during hypercare |
| Time to Competency | Client team independently vends an account via AFT within 2 weeks of go-live |

---

# Appendices

## Appendix A: Environment Details

The following tables document the key environment parameters for all landing zone accounts. Account IDs are populated during Week 1 after account provisioning is complete.

### Management Account

| Component | Value |
|-----------|-------|
| Account Name | Management |
| AWS Account ID | `111122223333` (placeholder — confirm at kick-off) |
| Primary Region | us-east-1 |
| DR Region | us-east-2 |
| Access Method | IAM Identity Center — PlatformAdministrator permission set |
| Purpose | Control Tower home; Organizations root; AFT pipeline; CI/CD pipeline |

### Log Archive Account

| Component | Value |
|-----------|-------|
| Account Name | Log Archive |
| OU | Security |
| Primary Region | us-east-1 |
| Access Method | IAM Identity Center — SecurityAuditor (read-only) |
| Data Stored | CloudTrail org trail logs; Config snapshots; VPC Flow Logs |
| Retention | 90 days S3 Standard → S3 Glacier Instant Retrieval; 7 years total |

### Audit / Security Tooling Account

| Component | Value |
|-----------|-------|
| Account Name | Audit |
| OU | Security |
| Primary Region | us-east-1 |
| Access Method | IAM Identity Center — SecurityAuditor; PlatformAdministrator (break-glass) |
| Functions | Security Hub aggregation; GuardDuty delegated admin; CloudTrail Lake; IAM Access Analyser |

### Network Hub Account

| Component | Value |
|-----------|-------|
| Account Name | Network Hub |
| OU | Infrastructure |
| Regions | us-east-1 and us-east-2 |
| Access Method | IAM Identity Center — NetworkOperator; PlatformAdministrator (break-glass) |
| Functions | Transit Gateway; Network Firewall; VPC IPAM; NAT Gateway; Site-to-Site VPN |

### Shared Services Account

| Component | Value |
|-----------|-------|
| Account Name | Shared Services |
| OU | Infrastructure |
| Primary Region | us-east-1 |
| Access Method | IAM Identity Center — PlatformAdministrator |
| Functions | Centralised CloudWatch dashboards; SNS alerting; cross-account observability sink |

## Appendix B: Configuration Reference

The following table documents the key configuration parameters for the landing zone. These parameters are also maintained in `environments/` `.tfvars` files in the IaC repository.

| Parameter | Value | Module |
|-----------|-------|--------|
| Primary Region | `us-east-1` | All modules |
| DR Region | `us-east-2` | All modules |
| IPAM Supernet | `10.0.0.0/8` | `networking/vpc-ipam` |
| us-east-1 IPAM Pool | `10.0.0.0/10` | `networking/vpc-ipam` |
| us-east-2 IPAM Pool | `10.64.0.0/10` | `networking/vpc-ipam` |
| Spoke VPC Size | `/20` per spoke | `networking/spoke-vpc` |
| Network Hub VPC (us-east-1) | `10.0.0.0/22` | `networking/network-hub-vpc` |
| Network Hub VPC (us-east-2) | `10.64.0.0/22` | `networking/network-hub-vpc` |
| TGW Primary ASN | `64512` | `networking/transit-gateway` |
| TGW Secondary ASN | `64513` | `networking/transit-gateway` |
| CloudTrail Retention (S3) | `365 days Standard + Glacier archive` | `security/cloudtrail-lake` |
| CloudTrail Lake Retention | `7 years` | `security/cloudtrail-lake` |
| Log Archive Object Lock | `90 days minimum (Compliance mode)` | `security/cloudtrail-lake` |
| Budget Alert Threshold 1 | `80% Forecasted` | `security/budgets` |
| Budget Alert Threshold 2 | `100% Actual` | `security/budgets` |
| Control Tower Version | `3.3` | CT Console |
| AFT Pipeline Region | `us-east-1` | `aft/pipeline` |
| Terraform Version | `>= 1.5.0` | All modules |
| AWS Provider Version | `>= 5.0` | All modules |

## Appendix C: Deployment Scripts

### deploy-all.sh — Full Landing Zone Deployment Script

This script orchestrates the full multi-phase deployment in sequence.

```bash
#!/bin/bash
# deploy-all.sh — Full Landing Zone Deployment
# Usage: ./deploy-all.sh <environment> [--dry-run]
set -euo pipefail

ENVIRONMENT=${1:-staging}
DRY_RUN=${2:-""}
REPO_ROOT=$(git rev-parse --show-toplevel)

echo "======================================"
echo "AWS Landing Zone Full Deployment"
echo "Environment: $ENVIRONMENT"
echo "======================================"

# Phase check
function deploy_module() {
  local module_path="$1"
  local vars_file="$2"
  echo ""
  echo "--- Deploying: $module_path ---"
  cd "$REPO_ROOT/$module_path"
  terraform init -backend-config="$REPO_ROOT/backends/${ENVIRONMENT}.tfvars" -reconfigure
  terraform plan -var-file="$REPO_ROOT/environments/$vars_file" -out=tf.plan
  if [ "$DRY_RUN" != "--dry-run" ]; then
    terraform apply tf.plan
  else
    echo "[DRY-RUN] Skipping apply for $module_path"
  fi
}

# Phase 1: Governance
deploy_module "modules/governance/ou-hierarchy" "mgmt.tfvars"
deploy_module "modules/governance/scp" "mgmt.tfvars"
deploy_module "modules/identity/idc" "mgmt.tfvars"

# Phase 2: Networking
deploy_module "modules/networking/vpc-ipam" "network-hub/us-east-1.tfvars"
deploy_module "modules/networking/transit-gateway" "network-hub/us-east-1.tfvars"
deploy_module "modules/networking/transit-gateway" "network-hub/us-east-2.tfvars"
deploy_module "modules/networking/network-hub-vpc" "network-hub/us-east-1.tfvars"
deploy_module "modules/networking/network-hub-vpc" "network-hub/us-east-2.tfvars"
deploy_module "modules/networking/network-firewall" "network-hub/us-east-1.tfvars"
deploy_module "modules/networking/network-firewall" "network-hub/us-east-2.tfvars"
deploy_module "modules/networking/vpn" "network-hub/us-east-1.tfvars"
deploy_module "modules/networking/vpn" "network-hub/us-east-2.tfvars"

# Phase 3: Security and Automation
deploy_module "modules/security/security-hub" "security/us-east-1.tfvars"
deploy_module "modules/security/guardduty" "security/us-east-1.tfvars"
deploy_module "modules/security/config-rules" "security/us-east-1.tfvars"
deploy_module "modules/security/cloudtrail-lake" "security/us-east-1.tfvars"
deploy_module "modules/aft/pipeline" "aft/aft.tfvars"
deploy_module "modules/monitoring/sns-topics" "monitoring/monitoring.tfvars"
deploy_module "modules/monitoring/cloudwatch-dashboards" "monitoring/monitoring.tfvars"
deploy_module "modules/monitoring/alarms" "monitoring/monitoring.tfvars"

echo ""
echo "======================================"
echo "Deployment complete!"
echo "======================================"
```

### rollback.sh — Emergency Rollback Script

This script performs a controlled rollback of a specific module to the previous IaC commit.

```bash
#!/bin/bash
# rollback.sh — Emergency module rollback
# Usage: ./rollback.sh <module_path> <vars_file>
set -euo pipefail

MODULE_PATH=$1
VARS_FILE=$2
REPO_ROOT=$(git rev-parse --show-toplevel)

echo "Rolling back module: $MODULE_PATH"
echo "Using vars: $VARS_FILE"

# Stash current changes and checkout previous version
cd "$REPO_ROOT/$MODULE_PATH"
git stash
git checkout HEAD~1 -- .

# Apply previous version
terraform init -backend-config="$REPO_ROOT/backends/mgmt.tfvars" -reconfigure
terraform plan -var-file="$REPO_ROOT/environments/$VARS_FILE" -out=rollback.plan
echo "Review the rollback plan above carefully before proceeding."
read -p "Proceed with rollback? (yes/no): " confirm
if [ "$confirm" == "yes" ]; then
  terraform apply rollback.plan
  echo "Rollback complete."
else
  echo "Rollback cancelled."
  git stash pop
fi
```

## Appendix D: Troubleshooting Guide

The following table documents the most common issues encountered during and after landing zone deployment.

### Common Issues

#### Issue 1: Control Tower Deployment Fails at Account Enrolment Stage

**Symptoms:**
- Control Tower console shows account in `FAILED` enrolment status
- `aws controltower list-managed-accounts` shows `GOVERNANCE_FAILED`

**Cause:** Existing IAM roles from a previous CT deployment conflicting with new role creation, or service quota for CloudFormation StackSets exceeded.

**Resolution:**

```bash
# Check StackSet execution status
aws cloudformation describe-stack-instance \
  --stack-set-name AWSControlTowerBP-BASELINE-CLOUDWATCH \
  --stack-instance-account <account-id> \
  --stack-instance-region us-east-1

# Use Control Tower repair workflow if SCP-blocked
# CT Console → Landing Zone → Repair → Follow prompts
```

**Prevention:** Verify AWS service quotas for CloudFormation StackSet instances before CT deployment (recommended: ≥ 200 stack instances quota).

---

#### Issue 2: AFT Pipeline Times Out Before Account Enrolment Completes

**Symptoms:**
- CodeBuild stage `aft-account-provisioning` times out after 60 minutes
- Account appears in Organizations but is not enrolled in Control Tower

**Cause:** Control Tower account enrolment is asynchronous and can take 20–45 minutes; AFT pipeline timeout set too low.

**Resolution:**

```bash
# Check AFT pipeline timeout setting
aws codebuild batch-get-projects \
  --names aft-account-provisioning \
  --query 'projects[0].timeoutInMinutes'

# If timeout < 60, update via Terraform
# In modules/aft/pipeline/variables.tf, set:
# codebuild_timeout_minutes = 90
terraform apply -var="codebuild_timeout_minutes=90" \
  -var-file=../../environments/aft/aft.tfvars -auto-approve

# Re-trigger the failed vend
aws codepipeline start-pipeline-execution --name aws-aft-main-pipeline --region us-east-1
```

**Prevention:** Set AFT CodeBuild timeout to 90 minutes in the initial deployment.

---

#### Issue 3: Network Firewall Blocking Legitimate Spoke-to-Spoke Traffic

**Symptoms:**
- Ping or TCP connections between spoke VPCs time out
- Network Firewall flow logs show `BLOCKED` for the expected traffic

**Cause:** Missing or incorrect stateful rule in the east-west firewall policy.

**Resolution:**

```bash
# Check firewall policy stateful rules
aws network-firewall describe-firewall-policy \
  --firewall-policy-name lz-east-west-policy \
  --region us-east-1 \
  --query 'FirewallPolicy.StatefulRuleGroupReferences'

# Review flow logs for the blocked connection
aws logs filter-log-events \
  --log-group-name /aws/network-firewall/flow \
  --filter-pattern "[version, account_id, interface_id, srcaddr=10.*.*.*, dstaddr=10.*.*.*, srcport, dstport, protocol, packets, bytes, start, end, action=BLOCKED, log_status]" \
  --region us-east-1

# Add the missing permit rule and apply via IaC
cd modules/networking/network-firewall
# Edit policies/east-west-stateful-rules.json to add the required rule
git add policies/ && git commit -m "fix: permit spoke-to-spoke traffic for workload <name>"
git push origin main
# CI/CD pipeline applies automatically after approval
```

**Prevention:** Review and test all spoke-to-spoke traffic flows in the Dev environment before promoting firewall policies to Production.

---

#### Issue 4: Security Hub FSBP Score Below 80% at Go-Live

**Symptoms:**
- Security Hub summary shows compliance score < 80% in Production accounts
- Multiple FSBP controls showing `FAILED` status

**Cause:** Common causes include S3 buckets without default encryption, IAM users with console access (no MFA), or EBS volumes without encryption enabled.

**Resolution:**

```bash
# List top failing FSBP controls
aws securityhub get-findings \
  --filters '{
    "ComplianceStatus":[{"Value":"FAILED","Comparison":"EQUALS"}],
    "SeverityLabel":[{"Value":"HIGH","Comparison":"EQUALS"}]
  }' \
  --sort-criteria '[{"Field":"ComplianceStatus","SortOrder":"asc"}]' \
  --region us-east-1 \
  --profile audit \
  --query 'Findings[*].{Control:Types[0],Resource:Resources[0].Id}' \
  --max-results 20

# For S3 encryption failures — enforce via bucket policy
aws s3api put-bucket-encryption \
  --bucket <bucket-name> \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}' \
  --region us-east-1
```

**Prevention:** Run Security Hub compliance check in NonProd environment and remediate all HIGH/CRITICAL findings before deploying to Production.

## Appendix E: Contact Information

### Project Team

The following table lists the primary project contacts. Names and contact details are populated at the Week 1 kick-off session.

| Role | Name | Email | Availability |
|------|------|-------|--------------|
| Vendor Project Manager | TBD (confirmed at kick-off) | TBD | Business hours |
| Vendor Solution Architect | TBD (confirmed at kick-off) | TBD | Business hours |
| Vendor Cloud Engineer × 2 | TBD (confirmed at kick-off) | TBD | Business hours |
| Vendor Security Engineer | TBD (confirmed at kick-off) | TBD | Business hours |
| Vendor Network Engineer | TBD (confirmed at kick-off) | TBD | Business hours |
| Client Executive Sponsor | TBD (confirmed at kick-off) | TBD | Sign-off milestones |
| Client IT Owner | TBD (confirmed at kick-off) | TBD | Business hours |
| Client Security Lead | TBD (confirmed at kick-off) | TBD | Business hours |
| Client Networking Lead | TBD (confirmed at kick-off) | TBD | Business hours |

### Escalation Contacts

| Level | Contact | Scope | Availability |
|-------|---------|-------|--------------|
| Primary (P2–P4) | Vendor Project Manager | All non-critical issues | Business hours |
| Secondary (P1) | Vendor Solution Architect + Senior Engineer | Critical landing zone failures | 24×7 during hypercare |
| Tertiary | AWS Business Support (via Management account) | AWS service outages; quota issues | 24×7 (< 1 hour P1 SLA) |

### Vendor Support

| Vendor | Support Portal | SLA |
|--------|----------------|-----|
| AWS Business Support | https://console.aws.amazon.com/support | P1 < 1 hour; P2 < 4 hours |
| HashiCorp Terraform Cloud | https://support.hashicorp.com | Standard business hours |
| Amatra Hypercare (Weeks 13–16) | Via Vendor PM (email/Slack confirmed at kick-off) | Per hypercare SLA table |
