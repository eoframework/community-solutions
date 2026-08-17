---
document_title: Detailed Design Document
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

This Detailed Design Document provides the authoritative technical blueprint for the implementation of an AWS Multi-Account Landing Zone for an insurance vendor operating in the United States. It translates the commitments and scope defined in the Statement of Work (SOW) into implementation-ready design specifications, covering governance architecture, network topology, security controls, data management, integration patterns, infrastructure operations, and the phased delivery approach required to bring the landing zone to production within the agreed 12-week engagement timeline.

The landing zone is a greenfield, enterprise-grade cloud foundation spanning two AWS regions — us-east-1 (primary) and us-east-2 (secondary/DR) — governed by AWS Control Tower. It is organised under a seven-OU hierarchy managed through AWS Organizations, underpinned by a hub-and-spoke Transit Gateway network with centralised AWS Network Firewall inspection, and automated through an Account Factory for Terraform (AFT) pipeline capable of provisioning fully guardrail-enrolled AWS accounts in under 30 minutes. Every design decision documented here traces directly to a pre-sales commitment in the SOW or the Solution Briefing.

Upon successful completion of this engagement, the client will operate a production-grade, IaC-governed AWS platform with ≥95% Terraform coverage, zero critical Security Hub findings at go-live, and the operational capability to onboard new business units and workloads without re-architecture. The document is structured across ten sections following the EO Framework standard and is intended to guide the Amatra delivery team, inform client technical stakeholders, and serve as the baseline for all as-built documentation produced during the engagement.

## Purpose

This document defines the end-to-end technical design for the AWS Multi-Account Landing Zone engagement. It is the primary reference for the Amatra engineering team during phases 1–3 of delivery and is the authoritative source for architecture decisions, component specifications, security controls, and operational procedures. The client IT Owner, Security Lead, and Networking Lead should use this document to validate design decisions and prepare their teams for UAT and operational handover.

## Scope

**In-scope:**

- AWS Control Tower deployment and multi-region governance (us-east-1 and us-east-2)
- AWS Organizations seven-OU hierarchy (Root, Security, Infrastructure, Workloads-Prod, Workloads-NonProd, Sandbox, Suspended)
- Service Control Policies (SCPs) and Resource Control Policies (RCPs) for governance and data perimeter enforcement
- AWS IAM Identity Center (SSO) with permission sets and identity source integration
- Centralised logging infrastructure: Log Archive and Audit accounts, CloudTrail organisation trail, AWS Config recording in both regions
- Transit Gateway hub-and-spoke network topology with inter-region peering, AWS Network Firewall, VPC IPAM, and centralised NAT Gateway egress
- Site-to-Site VPN to on-premises (both regions)
- Spoke VPC Terraform modules with /20 CIDR blocks from IPAM
- Account Factory for Terraform (AFT) pipeline for automated, guardrail-enrolled account vending
- AWS Security Hub (FSBP standard), Amazon GuardDuty, AWS Config, and CloudTrail Lake
- AWS Cost Explorer, per-account AWS Budgets, and centralised CloudWatch monitoring dashboards
- Operational runbooks, as-built documentation, administrator training, and 4-week hypercare support

**Out-of-scope:**

- Application workload migration, deployment, or refactoring
- AWS Direct Connect provisioning (VPN in scope; Direct Connect upgrade path documented only)
- Third-party SIEM integration (e.g., Splunk, Datadog, Elastic)
- GuardDuty or Security Hub integration with existing ticketing systems (ServiceNow, PagerDuty)
- Custom compliance frameworks beyond AWS FSBP (additional frameworks confirmed in Phase 1 are in scope)
- On-premises infrastructure remediation, server patching, or network hardware configuration
- AWS WAF, Shield Advanced, or API Gateway configuration
- Data migration of any kind (database, file, object storage)
- Managed services or ongoing operational support beyond the 4-week hypercare period

## Assumptions & Constraints

- The client has no existing AWS accounts, cloud infrastructure, or cloud-native tooling; this is a pure greenfield engagement.
- The client will designate and make available a Cloud/Infrastructure Owner, Security Lead, Networking Lead, Executive Sponsor, and FinOps contact before or at the Week 1 kick-off.
- Management account root credentials will be provided to the vendor team at the start of Phase 1.
- On-premises connectivity details (gateway IP, ASN, routing protocol) will be confirmed before Phase 2 networking deployment.
- The identity source for IAM Identity Center (native directory vs existing IdP such as Azure AD or Okta) will be confirmed before the end of Phase 1.
- Applicable compliance frameworks beyond FSBP will be confirmed by the Client Security Lead before the end of Week 2.
- The preferred CI/CD tooling for the IaC pipeline will be confirmed before Phase 2; AWS CodePipeline/CodeBuild will be used by default.
- ≥95% IaC coverage is achievable; all production infrastructure will be managed exclusively via Terraform and AFT from go-live.
- The 10.0.0.0/8 supernet does not overlap with existing on-premises or partner network address ranges.
- The client's preferred Terraform edition is HashiCorp Terraform Cloud Team tier (5 users); licensing constraints must be confirmed before Phase 3 AFT pipeline development begins.
- AWS Business Support is the minimum support tier; this will be active from the first billing cycle.

## References

- Statement of Work (SOW) — AWS Multi-Account Landing Zone, OPP-2024-001, Version 1.0, January 2025
- Solution Briefing — AWS Multi-Account Landing Zone
- AWS Control Tower User Guide
- AWS Well-Architected Framework — Security Pillar
- AWS Foundational Security Best Practices (FSBP) Standard
- Account Factory for Terraform (AFT) GitHub Repository
- Infrastructure Costs Model — infrastructure-costs.csv
- Level of Effort Estimate — level-of-effort-estimate.csv

---

# Business Context

The client is an insurance vendor operating in the United States that is embarking on a strategic cloud adoption initiative from a fully on-premises starting point. The absence of any prior AWS footprint means all cloud governance, identity, networking, security, and automation capabilities must be built from scratch and validated before any workloads can be onboarded. The architecture and phasing decisions documented throughout this design are grounded in these business realities: security must be non-negotiable from the first account provisioned, automation must replace manual processes at every layer, and the foundation must be designed to grow without requiring re-architecture as the organisation scales.

## Business Drivers

- **Security Posture from Day One:** The client operates in the regulated insurance sector where security incidents carry both regulatory and reputational consequences. The landing zone must enforce guardrails across every account at the moment of creation; no account may exist outside the governance boundary even transiently.
- **Elimination of Manual Account Provisioning:** Traditional, ticket-based AWS account provisioning can take multiple weeks of manual effort. The AFT pipeline reduces this to under 30 minutes of automated, guardrail-enrolled provisioning, removing a key bottleneck to cloud adoption velocity.
- **Multi-Region Resilience:** Insurance operations require platform resilience. Governing both us-east-1 and us-east-2 under the same Control Tower landing zone ensures that all security controls, logging, and compliance checks apply equally in the primary and DR regions, supporting the client's disaster recovery objectives.
- **Compliance Readiness:** The client's compliance obligations include AWS Foundational Security Best Practices (FSBP) at a minimum, with NIST 800-53 Rev 5, SOC 2 Type II, and HIPAA likely applicable to insurance operations processing PII and potentially PHI. The landing zone is designed to support all these frameworks with additive conformance pack activation.
- **Scalable Foundation for Growth:** OU structure, IPAM address space planning, and Terraform modules are designed to accommodate future business units, acquisitions, and workload accounts without architectural redesign.

## Workload Criticality & SLA Expectations

The landing zone itself constitutes shared platform infrastructure for all future workloads. Its availability and performance directly impact the client's ability to onboard and operate workloads. The following SLA targets govern the platform shared services and have been established in alignment with SOW success metrics.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Metric | Target | Measurement Method | Priority |
|--------|--------|--------------------|----------|
| Landing Zone Availability | 99.9% (AWS-managed services) | CloudWatch uptime metrics for Control Tower management plane | Critical |
| Account Vending Time (AFT Pipeline) | < 30 minutes | AFT pipeline execution logs; 3 consecutive validated runs required at go-live | Critical |
| Security Hub FSBP Compliance Score | ≥ 80% at go-live | Security Hub compliance score in Audit account dashboard | Critical |
| CloudTrail Log Delivery Latency | < 15 minutes to S3 Log Archive | CloudWatch metric on CloudTrail log delivery | High |
| Network Firewall Failover (Multi-AZ) | < 30 minutes | Network Firewall AZ failover test at go-live validation | High |
| Landing Zone IaC Rebuild RTO | < 4 hours | Validated during DR test in Phase 3 | High |
| Log Archive S3 RPO | < 15 minutes | S3 Cross-Region Replication lag metrics | High |
| IAM Identity Center SSO Availability | < 2 hours RTO | AWS Service Health Dashboard (AWS-managed SLA) | Medium |

## Compliance & Regulatory Factors

The client operates as an insurance vendor in the United States, subject to the following compliance considerations, all of which inform specific design decisions in this document.

- **AWS Foundational Security Best Practices (FSBP):** Mandatory at go-live. Enforced via Security Hub with 200+ controls across IAM, storage, network, logging, and monitoring domains. Zero critical findings required in Production and Platform accounts at go-live.
- **NIST 800-53 Rev 5:** Recommended as the primary framework for regulated insurance operations. AWS Config conformance pack available for activation during Phase 1 or via change control post-go-live.
- **SOC 2 Type II:** Relevant for vendor assurance and customer audit obligations. CloudTrail Lake 7-year retention and S3 Object Lock compliance mode satisfy SOC 2 audit evidence requirements without additional tooling.
- **HIPAA:** Applicable if the client processes Protected Health Information (PHI) as part of insurance operations. AWS Business Associate Agreement (BAA) must be executed with AWS if PHI will be stored or processed. HIPAA conformance pack will be activated during Phase 1 if confirmed in scope.
- **US Data Residency:** All data must remain in us-east-1 and us-east-2 exclusively. The SCP restricting all API calls to these two regions enforces this at the control-plane level, making non-compliant data placement technically impossible.

## Success Criteria

The following criteria define a successful engagement outcome and will be formally verified during UAT before go-live confirmation.

- 100% of AWS accounts enrolled in Control Tower guardrails at go-live (zero non-enrolled accounts)
- AFT pipeline vends a new account in < 30 minutes across three consecutive validation runs
- Zero critical Security Hub FSBP findings in all Production and Platform accounts at go-live
- IaC coverage ≥ 95% — confirmed via Terraform drift detection; no manual console changes in production
- Landing zone fully operational with at least two workload accounts (1 Production, 1 Non-Production) vended and validated by end of Month 3
- AWS Config recording active in all accounts across both regions at go-live
- CloudTrail organisation trail capturing all management events in both regions at go-live
- SNS budget alerts active for all accounts at 80% and 100% spend thresholds
- Client team able to independently perform account vending, Security Hub triage, and standard operational tasks as demonstrated in UAT

---

# Current-State Assessment

This engagement is a pure greenfield implementation. The client is entering the AWS ecosystem with no existing AWS accounts, cloud infrastructure, cloud-native tooling, or established cloud governance processes. There is no legacy environment to assess, migrate, or remediate; every landing zone component will be built and validated from scratch during the three-phase engagement.

## Application Landscape

No application workloads are in scope for this engagement. All existing client applications are hosted on-premises and are explicitly excluded from this SOW. Future workload migration, modernisation, and cloud-native development projects will be governed by the landing zone delivered here, but are not part of this design.

## Infrastructure Inventory

The client's on-premises environment is relevant to this engagement only for the purposes of designing the Site-to-Site VPN connectivity. The following represents the known connectivity context at the time of SOW signing; precise on-premises gateway details (IP address, ASN, routing protocol capability) will be confirmed during Phase 1 discovery.

<!-- TABLE_CONFIG: widths=[20, 15, 35, 30] -->
| Component | Quantity | Specifications | Notes |
|-----------|----------|----------------|-------|
| On-Premises Data Centre | TBD | Physical facility hosting current applications and network edge | Location and topology confirmed at kick-off |
| On-Premises VPN Gateway | TBD | Customer gateway device for S2S VPN (brand/model TBD) | Must support BGP or static routing; confirmed at kick-off (Dependency D5) |
| Existing Identity Provider | TBD | Potential AD, Okta, or Azure AD for IAM Identity Center federation | IdP selection confirmed by end of Phase 1 (Dependency D4) |
| Existing AWS Accounts | 0 | No existing accounts; pure greenfield | Confirmed in SOW |

## Dependencies & Integration Points

The following on-premises dependencies must be resolved before or during Phase 2 to ensure network connectivity design can be completed on schedule.

- On-premises VPN gateway IP address, ASN, and BGP/static routing capability (required by Dependency D5, Week 4)
- On-premises IP address ranges in use across all data centres and partner networks (required for VPC IPAM planning)
- Identity provider details for IAM Identity Center federation (SAML 2.0/SCIM protocol, user/group structure) (required by Dependency D4, Week 3)
- Compliance framework confirmation (NIST 800-53/SOC 2/HIPAA applicability) (required by Dependency D3, Week 2)

## Network Topology

The current state network consists entirely of on-premises infrastructure. There is no existing cloud network to document. The on-premises network edge device will serve as the Customer Gateway for the AWS Site-to-Site VPN connections established in Phase 2. IP address ranges used on-premises will be confirmed during Phase 1 discovery and used to design the non-overlapping 10.0.0.0/8 IPAM supernet allocation.

## Security Posture

There are no existing AWS security controls, cloud logging, or cloud compliance monitoring capabilities. All security architecture described in Section 5 of this document will be built from scratch. The absence of legacy configuration means no remediation overhead; however, it also means the client has no current visibility into cloud threats or compliance posture until the landing zone is operational.

## Performance Baseline

There is no existing cloud performance baseline to document. Performance targets established in this design (account vending SLA < 30 minutes, Network Firewall multi-AZ failover < 30 minutes, CloudTrail log delivery < 15 minutes) represent the target-state commitments against which go-live will be validated.

## Gap Analysis

The following table maps the current state against the required target state, identifying the capability gaps this engagement closes.

<!-- TABLE_CONFIG: widths=[33, 34, 33] -->
| Current State | Gap | Target State |
|---------------|-----|--------------|
| No AWS accounts or cloud governance | No multi-account framework, OU hierarchy, or policy enforcement | AWS Control Tower with 7-OU hierarchy, SCPs, and RCPs governing all accounts |
| Manual account provisioning (weeks) | No automation pipeline; each account requires manual setup | AFT pipeline vending accounts in < 30 minutes with full guardrail enrolment |
| No centralised cloud security visibility | No threat detection, compliance monitoring, or audit logging in cloud | GuardDuty org-wide, Security Hub FSBP, CloudTrail Lake, and Config across both regions |
| No cloud network foundation | No VPC architecture, routing, IP management, or on-premises connectivity | TGW hub-and-spoke, Network Firewall, IPAM, NAT Gateway, and S2S VPN |
| No IaC practice or CI/CD pipeline | All changes would be manual; no repeatability or drift detection | Terraform + AFT pipeline with ≥95% IaC coverage and CI/CD gates |
| No identity federation for cloud access | No SSO; accounts would have independent IAM users | IAM Identity Center with centralised SSO, permission sets, and MFA enforcement |
| No compliance framework in cloud | No FSBP, NIST, SOC 2, or HIPAA controls active in cloud | Security Hub FSBP + Config conformance packs enforced from account creation |

---

# Solution Architecture

The target-state architecture implements an enterprise-grade AWS Multi-Account Landing Zone built on AWS Control Tower, designed to serve as the client's primary cloud governance platform for the foreseeable future. The architecture follows a hub-and-spoke model with three foundational design tenets: **security by default** (every account inherits guardrails at the moment of creation with no manual steps required), **automation over manual operation** (all provisioning, change management, and compliance monitoring performed via IaC and managed services), and **scale without redesign** (the OU structure, networking topology, and IPAM address space are designed to accommodate additional accounts, business units, and regions without architectural changes).

The landing zone is organised into a seven-OU hierarchy under AWS Organizations, with dedicated Security and Infrastructure OUs hosting the shared platform accounts. A nested Workloads hierarchy separates Production and Non-Production accounts at the SCP policy boundary. The Sandbox OU provides a controlled experimentation environment with relaxed (but not absent) guardrails, and the Suspended OU provides a safe holding area for decommissioned accounts. AWS Control Tower governs both us-east-1 (primary) and us-east-2 (secondary/DR), applying identical guardrails, logging configuration, and compliance checks in both regions through the AFT customisation framework.

The network foundation is built on AWS Transit Gateway as the centralised routing backbone in both regions, with inter-region TGW peering providing seamless connectivity. All traffic — internet egress, on-premises, and VPC-to-VPC — flows through the Network Hub account where AWS Network Firewall provides stateful north-south and east-west packet inspection. VPC IPAM manages the 10.0.0.0/8 supernet and automatically allocates /20 CIDR blocks to each new spoke VPC, eliminating IP conflicts as the estate grows. The Account Factory for Terraform pipeline delivers each new workload account pre-configured with a spoke VPC, TGW attachment, security tooling enrolment, mandatory tags, and budget alerts, all without manual intervention.

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

*Figure 1: AWS Multi-Account Landing Zone — Full multi-region architecture showing the OU hierarchy, Security and Infrastructure shared accounts, Transit Gateway hub-and-spoke networking, and Account Factory for Terraform automated provisioning pipeline.*

## Architecture Principles

The following principles govern every design decision in this document and must be maintained through all future changes to the landing zone.

- **Security by Default:** Every AWS account inherits a defined security baseline — SCPs, Config recording, CloudTrail, GuardDuty enrolment, Security Hub enrolment, and mandatory tags — at the moment of provisioning via AFT. No account may exist outside these controls, even transiently. This principle directly satisfies the client's insurance-sector compliance obligations.
- **Automation Over Manual Operation:** All infrastructure is managed via Terraform and AFT. No manual console changes are permitted in Production or Platform accounts after go-live (enforced by drift detection). Manual intervention is reserved exclusively for break-glass scenarios documented in the Incident Response runbook.
- **Least Privilege by Design:** IAM Identity Center permission sets grant the minimum access required for each operational role. No long-lived IAM user credentials are permitted in any account. Privileged access is scoped to specific OUs and accounts, not granted organisation-wide.
- **Defence in Depth:** Security controls are implemented at multiple independent layers — SCPs at the organizational boundary, Network Firewall at the network layer, GuardDuty at the detection layer, and Config conformance packs at the resource configuration layer — so that failure of any single control does not create an undetected risk.
- **Scale Without Redesign:** The seven-OU hierarchy, 10.0.0.0/8 IPAM supernet, and Transit Gateway route table design are sized to support 100+ accounts and additional AWS regions without structural changes. New business units receive a dedicated OU; new regions require only Control Tower region enrolment and IPAM sub-pool allocation.
- **Immutable Audit Trail:** All management events are captured in an organisation-wide CloudTrail trail and replicated to a CloudTrail Lake event data store in the Audit account. S3 Object Lock (compliance mode) prevents log deletion or modification. This principle satisfies evidence retention requirements for SOC 2, HIPAA, and NIST 800-53.
- **Cost Governance from Day One:** Per-account AWS Budgets alerts at 80% and 100% thresholds are applied to every account via AFT customisation. AWS Cost Explorer and Cost Anomaly Detection are active from go-live, ensuring finance stakeholders have visibility from the first billing cycle.

## Architecture Patterns

The solution applies the following established AWS architecture patterns, each selected to directly address the client's requirements.

- **Primary Pattern:** Multi-Account Hub-and-Spoke — AWS Organizations with Control Tower governs a hierarchical account structure; the Network Hub account serves as the centralised connectivity and inspection point for all spoke accounts.
- **Networking Pattern:** Centralised Inspection — All VPC traffic (north-south and east-west) is routed through the Network Hub account's AWS Network Firewall before forwarding, providing a single policy enforcement point for the entire organisation.
- **Provisioning Pattern:** GitOps Account Vending — Account Factory for Terraform accepts account requests as Terraform configuration files committed to version control, triggering an automated CodePipeline execution that vends, enrols, and customises the new account without human intervention.
- **Deployment Pattern:** IaC-Only with CI/CD Gates — All infrastructure changes are applied through the Terraform CI/CD pipeline with mandatory peer review and automated `terraform plan` validation. No direct console changes are permitted in Production.
- **Logging Pattern:** Centralised Log Archive with Object Lock — All audit logs (CloudTrail, Config, VPC Flow Logs) are delivered to a dedicated Log Archive account with S3 Object Lock in compliance mode, providing tamper-evident, immutable log storage independent of workload accounts.
- **Security Pattern:** Preventative + Detective Layering — SCPs and RCPs provide hard preventative boundaries at the organisational level; GuardDuty, Security Hub, and Config provide continuous detective monitoring across all accounts and regions.

## Component Design

The landing zone is composed of six logical component tiers, each with distinct responsibilities and lifecycle management. The table below defines all components, their technology choices, dependencies, and scaling characteristics.

<!-- TABLE_CONFIG: widths=[18, 25, 22, 18, 17] -->
| Component | Purpose | Technology | Dependencies | Scaling |
|-----------|---------|------------|--------------|---------|
| Control Tower | Landing zone orchestrator; guardrail enforcement; account enrolment | AWS Control Tower | AWS Organizations, IAM Identity Center | Single deployment per Organisation; scales to 1000+ accounts |
| AWS Organizations | OU hierarchy management; SCP/RCP policy attachment; consolidated billing | AWS Organizations | Management Account | Flat; scales linearly with account count |
| IAM Identity Center | Centralised SSO; permission set management; cross-account access | AWS IAM Identity Center | Identity source (TBD); Management Account | Scales to thousands of users; Group sync via SCIM |
| Account Factory for Terraform | Automated account vending; guardrail enrolment; OU-specific customisation | AFT (CodePipeline + CodeBuild + Terraform) | Control Tower, Terraform Cloud, VCS | Pipeline scales to parallel account vending; concurrency configurable |
| Log Archive Account | Centralised, tamper-evident storage for all org audit logs | S3 (Object Lock), S3 Glacier Instant | CloudTrail, Config, VPC Flow Logs | Auto-scales; lifecycle to Glacier after 90 days |
| Audit / Security Tooling Account | Aggregation point for Security Hub findings, GuardDuty threats, CloudTrail Lake queries | Security Hub, GuardDuty (delegated admin), CloudTrail Lake | All member accounts | Aggregates findings from all accounts; scales with account count |
| Shared Services Account | Centralised CloudWatch dashboards, SNS alerting; future shared tooling platform | CloudWatch, SNS | All accounts (cross-account metrics) | CloudWatch dashboards scale by widget count; SNS scales with subscribers |
| Network Hub Account | Hub-and-spoke routing backbone; centralised inspection and egress | Transit Gateway, Network Firewall, NAT Gateway, VPC IPAM | All spoke VPCs, On-premises gateway | TGW scales to 5000 attachments; Firewall scales with throughput |
| Spoke VPC (per workload account) | Workload network isolation with /20 CIDR block and TGW attachment | Amazon VPC, TGW Attachment | Network Hub Account, VPC IPAM | One per workload account; /20 supports 4096 hosts |
| CI/CD Pipeline | IaC change management; branch protection; automated plan validation | AWS CodePipeline, CodeBuild, Terraform Cloud | VCS (GitHub/GitLab/CodeCommit TBD), Terraform state | Pipeline scales with parallel jobs; state per workspace |

## Technology Stack

The technology stack is specified here in full, as committed in the SOW. Each layer reflects an explicit architecture decision aligned to the client's requirements.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Layer | Technology | Rationale |
|-------|------------|-----------|
| Governance | AWS Control Tower + AWS Organizations | Native AWS multi-account governance; integrates natively with all other AWS services; no third-party tooling required |
| Identity & Access | AWS IAM Identity Center (SSO) | Centralised identity for all accounts; supports external IdP federation; permission sets enforce least privilege; MFA enforcement via SCP |
| Compute (Platform) | AWS CodePipeline, AWS CodeBuild (AFT) | Serverless CI/CD for AFT pipeline; no infrastructure to manage; scales on demand |
| Networking | AWS Transit Gateway, AWS Network Firewall, VPC IPAM, NAT Gateway | AWS-native hub-and-spoke; TGW provides centralised routing; Network Firewall enables stateful inspection; IPAM eliminates IP conflicts |
| Security — Preventative | Service Control Policies, Resource Control Policies | Organisation-level policy enforcement that cannot be overridden by any member account administrator |
| Security — Detective | Amazon GuardDuty, AWS Security Hub, AWS Config | Managed threat detection and CSPM with minimal operational overhead; aggregates across all accounts via delegated administrator pattern |
| Audit & Logging | AWS CloudTrail (org trail), CloudTrail Lake, Amazon S3 with Object Lock | Immutable, queryable, long-term audit record; satisfies SOC 2 / HIPAA / NIST 800-53 evidence retention requirements |
| Monitoring | Amazon CloudWatch, Amazon SNS | Centralised metrics and alerting; cross-account dashboards in Shared Services account; SNS for email alerting |
| Infrastructure as Code | Terraform (HashiCorp Cloud Team Tier), Account Factory for Terraform | Industry-standard IaC; AFT is AWS's native account vending solution built on Terraform; ≥95% coverage target |
| FinOps | AWS Cost Explorer, AWS Budgets, AWS Cost Anomaly Detection | Native AWS cost governance; per-account budget alerts active from go-live; no additional tooling required |

---

# Security & Compliance

The security architecture for the AWS Multi-Account Landing Zone is built on a defence-in-depth model that enforces controls at the organisational, network, and resource configuration layers simultaneously. For a regulated insurance vendor, security cannot be optional or applied retroactively — the design ensures that every account created, today and in the future, inherits a hardened security baseline the moment it is provisioned. All security controls described below are in scope per the SOW and are aligned to the AWS Foundational Security Best Practices (FSBP) standard enforced at go-live.

## Identity & Access Management

AWS IAM Identity Center is the single identity plane for all human access to AWS accounts across the organisation. No direct IAM user creation is permitted in any member account (enforced by SCP), eliminating the risk of persistent credentials and reducing the attack surface for credential theft.

- **Authentication:** AWS IAM Identity Center with identity source to be confirmed at kick-off (native AWS SSO directory or customer IdP via SAML 2.0/SCIM — see Dependency D4). All users must authenticate to the identity source before accessing any AWS account.
- **Authorization:** Role-based access control (RBAC) via IAM Identity Center permission sets. Permission sets are mapped to AWS accounts via IAM Identity Center assignment; each permission set generates a scoped IAM role in the target account.
- **MFA:** Enforced for all IAM Identity Center users via SCP. The SCP denies console access if the `aws:MultiFactorAuthPresent` condition evaluates to false, ensuring MFA cannot be bypassed even if the identity source permits it.
- **Service Accounts:** Application workload service accounts are out of scope for this engagement. Platform pipeline execution uses IAM roles (CodePipeline, CodeBuild) with scoped permissions and no long-lived credentials.

### Role Definitions

The following permission sets are defined at the landing zone level and provisioned across appropriate accounts and OUs via IAM Identity Center assignments.

<!-- TABLE_CONFIG: widths=[22, 40, 38] -->
| Role | Permissions | Scope |
|------|-------------|-------|
| PlatformAdministrator | Full AdministratorAccess in Platform accounts (Log Archive, Audit, Shared Services, Network Hub, Management) | Security, Infrastructure, and Management OUs only; no workload account access |
| WorkloadAdministrator | Full AdministratorAccess within a specific workload account | Single workload account; scoped by assignment in IAM Identity Center |
| SecurityAuditor | ReadOnlyAccess + SecurityAudit managed policy | All accounts in both regions; read-only compliance and investigation access |
| NetworkOperator | Network-specific managed policies (TGW, VPC, Network Firewall, IPAM) | Network Hub account only |
| FinOps | Billing, Cost Explorer, Budgets read access | All accounts; no infrastructure modification permissions |

## Secrets Management

Secrets and sensitive credentials used by the landing zone platform are managed through the following approach, ensuring no credentials are stored in code or configuration files.

- **AWS Secrets Manager** is used to store break-glass root account credentials for the Management account and each member account. Access to these secrets is restricted to the PlatformAdministrator permission set and protected by a resource-based policy requiring MFA.
- **Rotation Policy:** Break-glass credentials are rotated immediately after use and on a 90-day schedule. Rotation events are logged in CloudTrail and generate an SNS alert.
- **AFT Pipeline Credentials:** The AFT CodePipeline execution role uses IAM role assumption with scoped permissions; no static credentials are stored in the pipeline. Terraform Cloud workspace tokens are stored in AWS Secrets Manager and injected at pipeline runtime.
- **Access Logging:** All access to Secrets Manager secrets is logged in CloudTrail and monitored by GuardDuty for anomalous access patterns.

## Network Security

The network security architecture is implemented at multiple layers, from the Transit Gateway route tables through the Network Firewall stateful engine to the VPC security group model in each spoke account.

- **Segmentation:** Each workload account receives an isolated VPC with no internet gateway. All traffic routes via the TGW Inspection Route Table through the Network Hub's Network Firewall before reaching any destination. VPCs cannot communicate directly; all inter-VPC traffic traverses the firewall.
- **Firewall Rules:** AWS Network Firewall implements a default-deny stance with explicit allow rules for permitted flows. North-south rules govern outbound internet egress through the NAT Gateway; east-west rules govern permitted spoke-to-spoke communication paths. All rules are managed as Terraform code in the IaC repository.
- **WAF / DDoS Protection:** AWS WAF and Shield Advanced are out of scope for this engagement per the SOW. Network Firewall provides application-layer inspection for egress traffic; inbound application protection is a workload-specific design concern for future engagements.
- **VPN Security:** The Site-to-Site VPN to on-premises uses IKEv2 with AES-256 encryption and SHA-256 integrity. BGP authentication (MD5) is configured where the on-premises gateway supports it. VPN endpoint redundancy is provided by two AWS VPN tunnels per connection per region.

## Data Protection

All data within the landing zone (audit logs, configuration data, and control-plane metadata) is protected at rest and in transit using AWS-native encryption services.

- **Encryption at Rest:** S3 Log Archive uses SSE-S3 (AES-256) applied by default bucket policy. SSE-KMS with customer-managed keys is available as an optional upgrade for accounts requiring key custody audit trails. CloudTrail Lake event data stores are encrypted using AWS-managed KMS keys. EBS volumes in shared accounts are encrypted by default, enforced via AWS Config rule `ec2-ebs-encryption-by-default`.
- **Encryption in Transit:** TLS 1.2 minimum is enforced for all API calls and data transfers. S3 bucket policies include the `aws:SecureTransport` condition denying all non-TLS requests. Network Firewall rules block cleartext HTTP egress for platform services.
- **Key Management:** AWS KMS is deployed in both us-east-1 and us-east-2. Key management governance (rotation schedules, key policies, alias naming standards) is documented in the as-built architecture document and the Key Management runbook. Annual automatic key rotation is enabled for all customer-managed KMS keys.
- **Data Masking:** Non-production data handling is governed by the `DataClassification` tag applied by AFT customisations. Non-production accounts receive a tag value of `Internal` or `Confidential`; production accounts with Restricted data require workload-specific masking policies implemented in future workload engagements.

## Compliance Mappings

The following table maps the compliance frameworks applicable to this engagement to their specific implementation within the landing zone design.

<!-- TABLE_CONFIG: widths=[20, 35, 45] -->
| Framework | Requirement | Implementation |
|-----------|-------------|----------------|
| AWS FSBP | Multi-region CloudTrail enabled | CloudTrail organisation trail active in us-east-1 and us-east-2; verified in all member accounts via AFT |
| AWS FSBP | S3 bucket public access blocked | S3 Block Public Access enabled on all accounts via SCP and Config rule `s3-account-level-public-access-blocks` |
| AWS FSBP | Root account hardware MFA | Root MFA enforcement via SCP (`deny-root-access`); break-glass root credentials sealed per runbook |
| AWS FSBP | Security Hub enabled | Security Hub enabled in all accounts via AFT customisation; findings aggregated to Audit account |
| AWS FSBP | GuardDuty enabled | GuardDuty organisation-wide with delegated administrator in Audit account; active in both regions |
| AWS FSBP | EBS encryption by default | Config rule `ec2-ebs-encryption-by-default` applied via conformance pack |
| NIST 800-53 | AC-2 Account Management | IAM Identity Center permission sets with quarterly access review recommendation; no direct IAM users permitted |
| NIST 800-53 | AU-2 Audit Events | CloudTrail captures all management and data events organisation-wide; CloudTrail Lake with 7-year retention |
| NIST 800-53 | SC-7 Boundary Protection | Network Firewall enforces north-south and east-west boundary; TGW route tables enforce traffic inspection |
| SOC 2 | CC6.1 Logical Access Security | IAM Identity Center with MFA; permission sets scoped to minimum required access; quarterly review recommended |
| SOC 2 | CC7.2 System Monitoring | GuardDuty + Security Hub + CloudWatch dashboards provide continuous monitoring; SNS alerting for critical findings |
| HIPAA | §164.312(b) Audit Controls | CloudTrail org trail + CloudTrail Lake provide tamper-evident audit records with 7-year retention |
| HIPAA | §164.312(a)(2)(iv) Encryption | SSE-S3/KMS at rest; TLS 1.2+ in transit enforced by S3 bucket policy and Network Firewall rules |

## Audit Logging & SIEM Integration

The landing zone audit logging architecture is designed to satisfy regulatory evidence retention requirements while providing operational investigation capability.

- **What is Logged:** All management-plane API calls across all accounts and regions (CloudTrail management events); AWS Config resource configuration change events; VPC Flow Logs from all spoke VPCs and hub VPCs; Network Firewall alert logs; GuardDuty findings; Security Hub findings.
- **Retention Policy:** CloudTrail logs in S3 are retained for 90 days in S3 Standard, then transitioned to S3 Glacier Instant Retrieval via lifecycle policy. CloudTrail Lake event data stores retain queryable events for 7 years. VPC Flow Logs are retained for 90 days in S3 Standard, then Glacier.
- **SIEM Integration:** Third-party SIEM integration (Splunk, Datadog, Elastic) is explicitly out of scope for this engagement per the SOW. The Audit account is architected as the future SOC integration point: Security Hub findings are available via Security Hub API, and CloudTrail Lake supports direct SQL-style queries. The architecture document includes a future-state SIEM integration pattern for use in a subsequent engagement.

---

# Data Architecture

The data architecture for the AWS Multi-Account Landing Zone governs how platform operational data — audit logs, configuration state, threat findings, and cost metrics — is collected, stored, protected, and made available for investigation and compliance reporting. Application and workload data is explicitly out of scope for this engagement; the data model and governance principles established here are designed to serve as the baseline standards that future workload data architectures must adhere to.

## Data Model

### Conceptual Model

The landing zone manages four distinct data domains, each with different characteristics, consumers, and retention requirements. Understanding these domains ensures that storage architecture, access controls, and lifecycle policies are appropriately differentiated.

- **Audit & Compliance Data:** CloudTrail management events, AWS Config snapshots, and conformance pack evaluation results. Consumed by the Security Auditor role and future external auditors. Requires tamper-evident immutability and long-term retention.
- **Threat Intelligence Data:** GuardDuty findings, Security Hub findings, and IAM Access Analyser reports. Consumed by the Security Operations team for incident investigation and triage. Requires real-time availability and structured queryability.
- **Operational Monitoring Data:** CloudWatch metrics, logs, and dashboards. Consumed by the Platform Administrator for day-to-day operations. Requires near-real-time visibility with 90-day retention.
- **FinOps Data:** AWS Cost Explorer data, Budgets alert state, and Cost Anomaly Detection events. Consumed by FinOps contacts for cost governance. Managed entirely within AWS native FinOps services.

### Logical Model

The following entities represent the key data objects managed within the landing zone scope.

<!-- TABLE_CONFIG: widths=[22, 28, 28, 22] -->
| Entity | Key Attributes | Relationships | Volume |
|--------|----------------|---------------|--------|
| CloudTrail Event | eventTime, eventSource, eventName, userIdentity, sourceIPAddress, requestParameters, responseElements | Associated with an AWS Account; stored in Log Archive S3 and CloudTrail Lake | ~100M events/month organisation-wide |
| Config Configuration Item | resourceType, resourceId, configurationItemStatus, configuration, tags, accountId, awsRegion | Associated with an AWS Resource; delivered to Log Archive S3 | ~10M items/month across 10 accounts |
| GuardDuty Finding | findingId, type, severity, region, accountId, resource, service.action | Aggregated in Audit account Security Hub; archived to S3 via EventBridge | ~1,000–10,000 findings/month initially |
| Security Hub Finding | findingId, productArn, complianceStatus, severity, workflowState, accountId | Aggregated in Audit account; source includes GuardDuty, Config, Access Analyser | ~50,000–100,000 finding checks/month |
| VPC Flow Log Record | version, accountId, interfaceId, srcaddr, dstaddr, srcport, dstport, protocol, packets, bytes, action | Associated with a VPC ENI; delivered to Log Archive S3 | ~50 GB/month at baseline |
| AFT Account Request | accountName, accountEmail, ouName, tags, customisations | Triggers AFT CodePipeline execution; results in a vended Control Tower account | 1–5 new accounts/month post-go-live |

## Data Flow Design

Data flows within the landing zone follow a consistent collect-centralise-retain-query pattern, with the Log Archive and Audit accounts serving as the permanent data repositories.

1. **Collection:** CloudTrail captures management events from all accounts and regions via the organisation trail. AWS Config records resource configuration changes and delivers snapshots. VPC Flow Logs are enabled on all VPCs and delivered to the Log Archive bucket via VPC Flow Logs service configuration.
2. **Centralisation:** All CloudTrail logs, Config snapshots, and VPC Flow Logs are delivered to S3 buckets in the Log Archive account under account-specific prefixes. GuardDuty and Security Hub findings are aggregated to the Audit account via the delegated administrator and administrator account relationship.
3. **Immutability:** The Log Archive S3 bucket has S3 Object Lock enabled in compliance mode with a 90-day minimum retention period. No user or role — including the Log Archive account administrator — can delete or modify locked objects within the retention period.
4. **Long-Term Retention:** S3 lifecycle policies transition log data from S3 Standard to S3 Glacier Instant Retrieval after 90 days, maintaining cost-effective long-term storage while keeping data retrievable for audit purposes. CloudTrail Lake provides the queryable long-term event data store with 7-year retention.
5. **Query & Investigation:** Security investigations use CloudTrail Lake SQL queries in the Audit account for management event analysis. GuardDuty and Security Hub findings are queried via the AWS Console or API. Operational metrics are queried via CloudWatch Dashboards in the Shared Services account.

## Data Migration Strategy

This is a greenfield deployment with no existing data to migrate. The data architecture is established from scratch in Phase 1 with the Log Archive and Audit accounts, and data begins accumulating from the moment CloudTrail and Config are enabled in Week 4. There is no data migration scope in this engagement.

## Data Governance

The landing zone establishes the data governance baseline that all future workload data architectures must inherit.

- **Classification:** The `DataClassification` tag (values: Public, Internal, Confidential, Restricted) is applied to all supported AWS resources via AFT customisation at account creation. Platform accounts (Log Archive, Audit, Network Hub) carry a `DataClassification = Restricted` tag. Workload account classification is set per OU: Workloads-Prod defaults to `Confidential`; Workloads-NonProd defaults to `Internal`; Sandbox defaults to `Internal`.
- **Retention:** CloudTrail Lake 7 years (queryable); S3 CloudTrail/Config logs 90 days Standard + Glacier thereafter; VPC Flow Logs 90 days; GuardDuty findings 90 days (in GuardDuty service), available in Security Hub/S3 export for longer periods.
- **Quality:** CloudTrail logs are validated for completeness via CloudTrail log file validation (SHA-256 hash files). Config recording gaps are monitored via CloudWatch alarms on the `AWS/Config` namespace. Missing log delivery alerts are configured for the Log Archive bucket.
- **Access:** Log Archive S3 bucket access is restricted to the SecurityAuditor and PlatformAdministrator roles via bucket policy. No workload account administrator can access the Log Archive bucket. CloudTrail Lake query access is restricted to the Audit account SecurityAuditor and PlatformAdministrator permission sets.

---

# Integration Design

The landing zone integration architecture defines how the platform connects to on-premises infrastructure, how services within the AWS organisation communicate, and the API and event patterns used by the Account Factory for Terraform automation pipeline. All integrations described below are in scope per the SOW; the third-party SIEM integration architecture (out of scope for implementation) is documented as a future-state reference.

## External System Integrations

The following external integrations are in scope for this engagement. Each is designed for the specific connectivity characteristics and error handling requirements of that system.

<!-- TABLE_CONFIG: widths=[18, 15, 15, 13, 24, 15] -->
| System | Type | Protocol | Format | Error Handling | SLA |
|--------|------|----------|--------|----------------|-----|
| On-Premises Gateway (VPN) | Always-on tunnel | IPSec/IKEv2 + BGP | IP routing (BGP updates) | Dual-tunnel redundancy per region; automatic failover to backup tunnel; BGP reconverges within 30 seconds | 99.9% AWS-managed SLA |
| Identity Provider (IAM Identity Center) | Real-time federation | SAML 2.0 + SCIM (if external IdP) | SAML assertions, SCIM JSON | Automatic reconnection; IAM Identity Center falls back to local directory if IdP is unreachable | AWS-managed SLA |
| Terraform Cloud (AFT backend) | Triggered (per pipeline run) | HTTPS API | JSON (Terraform API) | CodePipeline retry on transient failure; AFT pipeline alerts on permanent failure via SNS | HashiCorp SLA; AFT pipeline SNS alert on failure |
| VCS / Code Repository (TBD) | Triggered (webhook on commit) | HTTPS webhook | JSON (VCS event payload) | CodePipeline requeues on webhook failure; branch protection prevents merge without pipeline pass | VCS provider SLA |
| CloudWatch SNS Alerting | Event-driven | AWS SNS → Email/HTTPS | JSON (CloudWatch alarm payload) | SNS delivery retries; dead-letter queue for failed HTTP endpoint deliveries | AWS SNS 99.9% delivery SLA |

## API Design

The landing zone does not expose custom application APIs. Platform automation uses AWS service APIs through IAM roles and the following interaction patterns.

- **Style:** AWS SDK REST APIs; Terraform AWS Provider for IaC interactions; AFT uses Terraform and AWS SDKs internally.
- **Versioning:** All AWS API versions are pinned in Terraform provider version constraints (e.g., `required_providers { aws = "~> 5.0" }`) to prevent unintended API version changes.
- **Authentication:** All API calls use IAM roles via STS AssumeRole with short-lived credentials (1-hour session tokens). CodePipeline and CodeBuild execution roles are scoped to the minimum permissions required for their specific pipeline stage.
- **Rate Limiting:** AFT pipeline execution is sequenced to avoid hitting AWS API throttling limits during concurrent account vending. Terraform parallelism settings are configured at a safe default (parallelism = 10) and can be tuned if parallel account vending is needed.

### API Endpoints (AFT Account Request Interface)

The AFT pipeline accepts account requests by committing Terraform configuration to the AFT account request repository. The following defines the interface contract for submitting and monitoring account requests.

<!-- TABLE_CONFIG: widths=[18, 32, 18, 32] -->
| Method | Resource / Action | Auth | Description |
|--------|------------------|------|-------------|
| Git Push | AFT account request repository (main branch) | VCS commit with valid credentials; branch protection enforced | Triggers AFT CodePipeline execution for new account vending |
| GET | AWS Console → CodePipeline → AFT pipeline | IAM Identity Center PlatformAdministrator | Monitor AFT pipeline execution status and stage progress |
| GET | AWS Console → Control Tower → Accounts | IAM Identity Center PlatformAdministrator | Validate newly vended account enrolment status in Control Tower |
| Query | CloudTrail Lake SQL | IAM Identity Center SecurityAuditor | Investigate API activity for a vended account post-provisioning |

## Authentication & SSO Flows

Identity federation and cross-account authentication follow the AWS-recommended patterns for IAM Identity Center deployments.

- **Human Access (SSO):** Users authenticate at the IAM Identity Center access portal using their identity source credentials and MFA. Upon successful authentication, the portal presents the accounts and permission sets assigned to the user's groups. The user selects an account/role combination; IAM Identity Center vends a short-lived session (maximum 8 hours) via STS AssumeRoleWithSAML.
- **Token Management:** IAM Identity Center manages token issuance and session lifecycle. Session duration is set to 8 hours for all permission sets (configurable per set). No persistent tokens or API keys are issued to human users.
- **Service-to-Service Auth:** Pipeline execution uses IAM roles assumed via CodePipeline/CodeBuild trust policies. Cross-account operations (e.g., AFT deploying into member accounts) use IAM role chaining: the AFT management account role assumes a pre-provisioned `AWSAFTExecution` role in each target account, scoped to the permissions required for AFT customisation.
- **Identity Source Confirmation:** The specific identity source (native AWS SSO directory vs external IdP) is confirmed by Dependency D4 (Week 3). If an external IdP is used, SCIM provisioning will be configured for automated user and group synchronisation.

## Messaging & Event Patterns

The landing zone uses AWS-native event-driven patterns for operational alerting, compliance notifications, and pipeline triggering.

- **Queue Service:** Amazon SQS is used internally by the AFT CodePipeline for inter-stage communication and is managed by the AFT framework. No custom SQS queues are required for the landing zone platform.
- **Event Bus:** Amazon EventBridge is used to route GuardDuty findings and Security Hub findings to SNS topics for alerting. EventBridge rules in the Audit account route high-severity findings (GuardDuty severity ≥ 7, Security Hub `CRITICAL`) to the SNS alerting topic.
- **Dead Letter Queue:** The SNS topic for Security Hub/GuardDuty critical alerts includes an SQS DLQ for failed delivery attempts to HTTP/S endpoints. DLQ messages trigger a CloudWatch alarm to alert the operations team of missed notifications.
- **Retry Policy:** EventBridge delivery retries follow the AWS default exponential backoff policy (up to 24 hours, 185 retries). AFT pipeline transient failures trigger automatic CodePipeline retry with a maximum of 3 retries before alerting.

---

# Infrastructure & Operations

The infrastructure design translates the architecture described in Section 4 into specific, deployable configurations across all AWS accounts and regions. This section defines the complete network address plan, compute specifications for platform components, high availability design, disaster recovery configuration, monitoring and alerting architecture, and the 3-year cost model sourced from the pre-sales infrastructure cost analysis.

## Infrastructure Deployment

The landing zone infrastructure is organised across four categories of accounts: Management (AWS Control Tower management account), Platform Shared Accounts (Log Archive, Audit, Shared Services, Network Hub), Workload Accounts (vended via AFT), and Sandbox/Suspended Accounts. All infrastructure in Management and Platform Shared Accounts is deployed via Terraform and is managed through the central IaC CI/CD pipeline. Workload account baseline infrastructure is deployed via AFT customisations.

## Network Design

The 10.0.0.0/8 supernet is managed by VPC IPAM and divided into regional sub-pools to prevent IP address conflicts as the estate grows. The Network Hub VPC in each region hosts the Transit Gateway attachments, Network Firewall endpoints, NAT Gateways, and the VPN Customer Gateway attachment.

- **VPC IPAM Supernet:** 10.0.0.0/8 (all regions; managed by IPAM in Network Hub account)
- **us-east-1 Regional Pool:** 10.0.0.0/10 (10.0.0.0 – 10.63.255.255; supports up to 256 /20 spoke VPCs)
- **us-east-2 Regional Pool:** 10.64.0.0/10 (10.64.0.0 – 10.127.255.255; supports up to 256 /20 spoke VPCs)
- **Network Hub VPC (us-east-1):** 10.128.0.0/20 — Public subnets: 10.128.0.0/24 (AZ-a), 10.128.1.0/24 (AZ-b); Firewall subnets: 10.128.4.0/24 (AZ-a), 10.128.5.0/24 (AZ-b); TGW attachment subnets: 10.128.8.0/28 (AZ-a), 10.128.8.16/28 (AZ-b)
- **Network Hub VPC (us-east-2):** 10.192.0.0/20 — Same subnet layout as us-east-1 hub, offset within the us-east-2 regional pool
- **Spoke VPCs:** Each workload account receives a /20 CIDR automatically allocated from the regional IPAM pool at provisioning time. Spoke subnets: Application tier /24 per AZ, Data tier /24 per AZ, Private tier /24 per AZ. No internet gateway; all routing via TGW attachment.

## Compute Sizing

The landing zone platform services are serverless or fully managed with no user-provisioned compute. The following table documents the exception cases where compute resources are explicitly sized.

<!-- TABLE_CONFIG: widths=[28, 20, 10, 12, 10, 20] -->
| Component | Instance Type | vCPU | Memory | Count | Notes |
|-----------|---------------|------|--------|-------|-------|
| AFT CodeBuild (account vending) | BUILD_GENERAL1_SMALL | 2 | 3 GB | On-demand | Scales to 0 when no pipeline running |
| AFT CodeBuild (customisation) | BUILD_GENERAL1_SMALL | 2 | 3 GB | On-demand | One per vended account; parallel up to concurrency limit |
| Network Firewall endpoints (us-east-1) | Managed (Firewall endpoints) | N/A | N/A | 2 (1 per AZ) | AWS-managed; scales automatically with throughput |
| Network Firewall endpoints (us-east-2) | Managed (Firewall endpoints) | N/A | N/A | 2 (1 per AZ) | AWS-managed; scales automatically with throughput |
| NAT Gateway (us-east-1) | Managed | N/A | N/A | 2 (1 per AZ) | AWS-managed; up to 45 Gbps per NAT Gateway |
| NAT Gateway (us-east-2) | Managed | N/A | N/A | 2 (1 per AZ) | AWS-managed; mirrors us-east-1 for DR symmetry |

## High Availability Design

All landing zone components are deployed for high availability using AWS-native multi-AZ and multi-region capabilities.

- **Multi-AZ Design:** Network Firewall endpoints and NAT Gateways are deployed across two Availability Zones in each region. Transit Gateway is inherently multi-AZ within each region. IAM Identity Center, Control Tower management plane, and GuardDuty are AWS-managed with multi-AZ availability built in.
- **Multi-Region Design:** AWS Control Tower governs both us-east-1 and us-east-2 simultaneously. Security Hub, GuardDuty, CloudTrail, and Config are all active in both regions. Transit Gateway inter-region peering provides an active-standby connectivity path between regions.
- **Failover Strategy:** For the landing zone platform itself, failover is passive: in the event of an us-east-1 management plane outage, the landing zone's governance posture (SCPs, guardrails, IAM Identity Center permission sets) remains enforced because AWS Control Tower guardrails are SCPs applied at the Organizations level and do not require the Control Tower management plane to be operational to enforce.
- **Health Checks:** CloudWatch alarms monitor Control Tower drift status, Security Hub compliance score, GuardDuty finding volume, and AFT pipeline last-run status. Anomalies trigger SNS alerts to the operations team.

## Disaster Recovery

The landing zone is designed as infrastructure-as-code from the ground up, making the recovery model IaC-native: the entire environment can be re-provisioned from Terraform state and AFT configuration in the event of a catastrophic failure.

- **RPO:** Last successful IaC commit (Terraform state + AFT templates). Log Archive S3 has a < 15-minute RPO via S3 Cross-Region Replication to us-east-2.
- **RTO:** < 4 hours for full landing zone rebuild from Terraform state. < 1 hour for Log Archive restoration from CRR replica. < 30 minutes for Network Firewall policy re-application from IaC.
- **Backup Strategy:** Terraform state files are stored in S3 with versioning enabled and a 90-day version retention policy. DynamoDB state lock table has Point-in-Time Recovery (PITR) enabled. AFT configuration repository is mirrored to a client-managed VCS repository at handover.
- **DR Site:** us-east-2 serves as the secondary region. Control Tower governs both regions identically. In the event of us-east-1 unavailability, workloads with DR requirements can failover to us-east-2 where the governance posture is identical.

<!-- TABLE_CONFIG: widths=[35, 15, 15, 35] -->
| Component | RTO | RPO | Recovery Method |
|-----------|-----|-----|-----------------|
| Landing Zone (IaC rebuild) | < 4 hours | Last IaC commit | Terraform apply from state + AFT re-run |
| Log Archive (S3 + CRR) | < 1 hour | < 15 minutes | Promote us-east-2 CRR replica to primary |
| IAM Identity Center SSO | < 2 hours | N/A | AWS-managed; multi-region SLA |
| Network Firewall (multi-AZ) | < 30 minutes | N/A | Automatic AZ failover via TGW re-routing |
| GuardDuty / Security Hub | < 1 hour | N/A | AWS-managed; re-enable via AFT customisation |
| AFT Pipeline | < 2 hours | Last pipeline state | Re-run from last known-good Terraform backend |

## Monitoring & Alerting

The centralised monitoring architecture is hosted in the Shared Services account and aggregates metrics and logs from all member accounts via cross-account CloudWatch sharing policies. The monitoring stack is deployed via Terraform in Phase 3.

- **Infrastructure Monitoring:** CloudWatch monitors Transit Gateway attachment counts, NAT Gateway byte-throughput, Network Firewall packet drop rates, S3 Log Archive write latency, and Config recording delivery success.
- **Application Monitoring:** Platform pipeline health (AFT pipeline last-run success/failure, CodeBuild duration, CodePipeline execution status) is monitored via CloudWatch Events and custom metrics.
- **Business KPIs:** Security Hub FSBP compliance score (target ≥ 80%), GuardDuty finding count by severity, active account count, and AWS Budget alert status are tracked as business-level KPIs on the CloudWatch management dashboard.
- **Alerting:** SNS topics are configured for three severity tiers: CRITICAL (P1 landing zone governance failure), HIGH (P2 AFT pipeline failure, Security Hub critical finding, GuardDuty high-severity threat), and MEDIUM (P3 non-critical component issues, Config compliance drift).

### Alert Definitions

The following alerts are defined and deployed via Terraform in the Shared Services account as part of Phase 3 delivery.

<!-- TABLE_CONFIG: widths=[28, 25, 15, 32] -->
| Alert | Condition | Severity | Response |
|-------|-----------|----------|----------|
| Control Tower Drift Detected | Control Tower dashboard shows non-compliant OU/account status | CRITICAL | Investigate via CT console; re-enrol affected account via AFT |
| Security Hub Critical Finding | Security Hub finding with `Severity.Label = CRITICAL` in any account | CRITICAL | Follow Security Hub finding triage runbook within 2 hours |
| GuardDuty High-Severity Threat | GuardDuty finding severity ≥ 7.0 in any account/region | HIGH | Follow GuardDuty alert investigation runbook; escalate to Client Security Lead |
| AFT Pipeline Failure | CodePipeline execution status = FAILED for AFT pipeline | HIGH | Review CodeBuild logs; retry from last known-good state; escalate to Amatra hypercare if unresolved |
| CloudTrail Log Delivery Gap | CloudWatch metric `CloudTrailEventsSentToCloudWatch` = 0 for > 15 min | HIGH | Investigate CloudTrail trail configuration; verify S3 bucket policy |
| Config Recording Stopped | AWS Config recorder status = stopped in any account | HIGH | Re-enable Config recorder via AFT customisation re-run |
| Budget Threshold Reached | AWS Budgets alert at 80% or 100% spend threshold for any account | MEDIUM | Review Cost Explorer for anomalous spend; notify FinOps contact |
| Network Firewall Drop Rate Spike | Network Firewall `DroppedPackets` metric increases > 200% over 5-minute baseline | MEDIUM | Review Firewall rule logs; investigate traffic source |
| VPN Tunnel Down | CloudWatch VPN metric `TunnelState` = 0 for both tunnels in any region | HIGH | Follow VPN troubleshooting runbook; engage on-premises networking team |

## Logging & Observability

The observability stack provides three tiers of visibility — infrastructure metrics, audit events, and application traces — aligned to the operational needs of the landing zone.

- **Log Aggregation:** CloudWatch Logs Insights is pre-configured with saved queries for common operational investigation patterns (AFT pipeline failures, SCP deny events, GuardDuty finding spikes, Control Tower drift events). Log groups from all accounts are centralised in the Shared Services account using cross-account log delivery.
- **Tracing:** AWS X-Ray is not in scope for the landing zone platform (no custom application workloads). AFT pipeline execution tracing is provided by CodePipeline execution history and CodeBuild build logs.
- **Dashboards:** Three CloudWatch dashboards are delivered in Phase 3: (1) **Landing Zone Operations Dashboard** — Control Tower compliance, account count, AFT pipeline health, and VPN status; (2) **Security Posture Dashboard** — Security Hub FSBP score, GuardDuty finding volume by severity, IAM Access Analyser findings, and Config compliance score; (3) **FinOps Dashboard** — Organisation-wide cost trend, top 5 accounts by spend, Budget alert status, and Cost Anomaly Detection events.

## Cost Model

The following cost model is sourced directly from the infrastructure-costs.csv pre-sales artifact. Infrastructure costs are consistent across Years 2 and 3 at the baseline scale (10 accounts, ~100M CloudTrail events/month, ~500 GB/month log storage). Costs will scale modestly as additional workload accounts are onboarded and traffic volumes increase post-go-live.

<!-- TABLE_CONFIG: widths=[28, 18, 18, 16, 20] -->
| Category | Monthly (Baseline) | Annual (Year 1 Gross) | Year 1 Net (with Credits) | 3-Year Total |
|----------|--------------------|-----------------------|---------------------------|--------------|
| AWS Network Firewall (both regions) | $790 | $9,480 | $9,480 | $28,440 |
| AWS Transit Gateway (both regions) | $438 | $5,256 | $5,256 | $15,768 |
| Amazon CloudWatch (metrics + logs) | $180 | $2,160 | $2,160 | $6,480 |
| AWS CloudTrail (org trail + Lake) | $200 | $2,400 | $2,400 | $7,200 |
| AWS Config (rules across accounts) | $270 | $3,240 | $3,240 | $9,720 |
| Amazon GuardDuty (both regions) | $150 | $1,800 | $1,800 | $5,400 |
| AWS Security Hub (all accounts) | $100 | $1,200 | $1,200 | $3,600 |
| NAT Gateway (both regions) | $70 | $840 | $840 | $2,520 |
| AFT CodePipeline + CodeBuild | $75 | $900 | $900 | $2,700 |
| Amazon S3 (Log Archive + lifecycle) | $14 | $162 | $162 | $486 |
| Other (IPAM, VPC, Budgets, Cost Explorer) | $80 | $984 | $984 | $2,952 |
| **Cloud Infrastructure Subtotal** | **$2,367** | **$28,422** | **$13,422** (after $15,000 credits) | **$70,266** |
| Terraform Cloud (Team tier) | $40 | $480 | $480 | $1,440 |
| AWS Business Support | $350 | $4,200 | $4,200 | $12,600 |
| **Total Infrastructure + Support** | **$2,757** | **$33,102** | **$18,102** | **$84,306** |

*Credits: $15,000 in AWS Activate Founders Credit ($5,000) and AWS MAP Infrastructure Credit ($10,000) applied in Year 1 only to AWS service charges.*

---

# Implementation Approach

The implementation follows a foundation-first, phased delivery model across 12 weeks. Each phase delivers a validated, independently valuable capability before the next phase begins, reducing risk and enabling early progress visibility for the client. The phasing is non-negotiable from a dependency perspective: Control Tower governance must be established (Phase 1) before networking (Phase 2) can be configured, and networking must be in place before security automation and AFT account vending (Phase 3) can be validated end-to-end.

## Migration/Deployment Strategy

This is a greenfield implementation with no migration component. The deployment strategy is characterised by the following parameters.

- **Approach:** Greenfield build — all components are new; no legacy remediation or migration required.
- **Pattern:** Sequential phase deployment with formal sign-off gates between phases. Within each phase, individual components are deployed iteratively (day-by-day) with daily validation checkpoints.
- **Validation:** Each deployed component is validated against the acceptance criteria defined in the Phase Architecture Design Document before the next component is deployed. Failures block progression and are resolved before continuing.
- **Rollback:** Individual component rollback procedures are documented in the Incident Response runbook. Phase-level rollback is achievable via Terraform destroy/re-apply from the last known-good state. A full phase rollback has never been required in comparable greenfield landing zone engagements, but procedures are documented as a precaution.

## Sequencing & Wave Planning

The 12-week engagement is structured across three sequential phases, each with its own activities, deliverables, and exit criteria that gate progression to the subsequent phase.

<!-- TABLE_CONFIG: widths=[8, 28, 15, 49] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 — Foundation & Governance | Kick-off; discovery; OU design; Control Tower deployment; SCP/RCP policy set; IAM Identity Center; Log Archive and Audit accounts; CloudTrail org trail; Config recording; Phase 1 architecture design document | Weeks 1–4 | Architecture Design Review signed off by Client Executive Sponsor; Control Tower operational in both regions; all SCPs and RCPs deployed; IAM Identity Center SSO validated |
| 2 — Networking & Connectivity | Transit Gateway (both regions, inter-region peering); Network Firewall; VPC IPAM; Hub VPCs; NAT Gateway; Spoke VPC Terraform modules; Site-to-Site VPN (both regions); network flow testing | Weeks 5–8 | Spoke-to-spoke traffic validated through Network Firewall; centralised egress path operational; VPN to on-premises routing confirmed; Network Testing Report accepted |
| 3 — Security, Automation & Handover | Security Hub FSBP; GuardDuty org-wide; Config conformance packs; CloudTrail Lake; AFT pipeline and account customisations; two workload accounts vended; CI/CD pipeline; CloudWatch dashboards; tagging policies; Budgets; UAT; runbooks; training; go-live | Weeks 9–12 | All success metrics validated; zero critical FSBP findings; AFT vending < 30 min (3 runs); two accounts enrolled; UAT signed off; PlatformAdministrator handed to client |
| 4 — Hypercare Support | Triage of post-go-live issues; support for first live AFT vending; Security Hub finding guidance; minor configuration adjustments within original scope; Optimisation Recommendations Report | Weeks 13–16 | Hypercare Closeout Report delivered; all P1/P2 issues resolved; Optimisation Recommendations delivered |

## Tooling & Automation

The following tools are used across the engagement for infrastructure deployment, change management, testing, and documentation. All tooling decisions are aligned to the SOW scope.

<!-- TABLE_CONFIG: widths=[25, 25, 50] -->
| Category | Tool | Purpose |
|----------|------|---------|
| Infrastructure as Code | HashiCorp Terraform (Cloud Team tier) | All AWS resources across all accounts and regions; state stored in Terraform Cloud workspaces |
| Account Vending | Account Factory for Terraform (AFT) | Automated account provisioning, Control Tower enrolment, and OU-specific customisations |
| CI/CD Pipeline | AWS CodePipeline + CodeBuild (AFT-native) | AFT account vending pipeline execution; change validation before plan application |
| IaC Repository / CI/CD (Platform changes) | TBD (GitHub / GitLab / CodeCommit) — confirmed at kick-off | Platform Terraform module hosting; branch protection; peer review gates; deployment pipeline triggering |
| Governance | AWS Control Tower | Landing zone management; guardrail enforcement; account enrolment status |
| Policy Management | Service Control Policies via AWS Organizations | Preventative governance enforced at the OU and account level |
| Security Testing | AWS IAM Policy Simulator, custom SCP test scripts | SCP enforcement validation; deny test execution in non-production OU before policy rollout |
| Monitoring | Amazon CloudWatch + AWS SNS | Centralised dashboards; alerting pipeline; operational metrics |
| Documentation | Amatra EO Framework (Markdown + draw.io) | Architecture documentation; as-built docs; runbooks in version-controlled Markdown |

## Cutover Approach

The go-live for this engagement is an operational handover — the landing zone is fully functional in AWS before go-live day, and cutover marks the formal transfer of PlatformAdministrator ownership from the Amatra delivery team to the client team.

- **Type:** Phased handover with parallel support (hypercare model).
- **Duration:** Go-live day (Week 12) transitions ownership; 4-week hypercare (Weeks 13–16) provides a safety net during initial client operations.
- **Validation:** All success metrics must be validated before go-live confirmation. UAT sign-off is the formal gate.
- **Decision Point:** The Go-Live Readiness Checklist (12-item checklist in the SOW) must be signed off jointly by the Vendor Project Manager and Client IT Owner before go-live day. Incomplete checklist items are automatic go/no-go blockers.

## Downtime Expectations

This is a greenfield build; there is no existing production system to disrupt and no planned downtime window required.

- **Planned Downtime:** Zero — the landing zone is built in a net-new environment with no workloads impacted during construction.
- **VPN Cutover:** The Site-to-Site VPN is established to a new AWS endpoint; the on-premises gateway will be configured to bring up both tunnels. Initial VPN establishment may cause a brief interruption to on-premises-to-cloud routing during the BGP convergence period (typically < 30 seconds). This is acceptable as there are no workloads in the cloud during Phase 2.
- **Unplanned Downtime:** MTTR targets are defined per component in the DR table above (< 30 minutes for Network Firewall AZ failover; < 4 hours for full IaC rebuild).
- **Mitigation:** Multi-AZ design for all network components and IaC-native recovery for governance components minimises unplanned downtime risk.

## Rollback Strategy

Given the greenfield nature of the engagement, rollback scenarios are component-level rather than full environment rollback.

- **Infrastructure Rollback:** Each Terraform workspace maintains state history and supports `terraform destroy` or targeted resource replacement. All pipeline deployments are gated on successful `terraform plan` review, preventing broken configurations from being applied.
- **SCP Rollback:** SCP changes are tested in a non-production OU (Sandbox) before being promoted to Production OUs. Previous SCP versions are maintained in the IaC repository and can be re-applied via the CI/CD pipeline in < 15 minutes following peer approval.
- **AFT Pipeline Rollback:** The AFT pipeline maintains Terraform state per account. A failed account vending attempt can be re-run from the last clean state. Partially provisioned accounts are identified by the AFT monitoring runbook and either completed or decommissioned.
- **Network Firewall Policy Rollback:** Firewall policies are versioned in the IaC repository. A policy rollback is a standard Terraform apply of the previous policy version, executable in < 30 minutes following the change management process.
- **Maximum Rollback Window:** All component rollbacks are designed to complete within 4 hours. This aligns to the RTO commitment for full landing zone restoration.

---

# Appendices

The following appendices provide supporting reference material for the AWS Multi-Account Landing Zone Detailed Design. These materials supplement the main sections and are intended for use during implementation, testing, and ongoing operations.

## Architecture Diagrams

The following diagrams support the solution design. The primary architecture diagram is embedded in Section 4.

- **Solution Architecture Diagram** — Full multi-region landing zone showing OU hierarchy, shared platform accounts, TGW hub-and-spoke networking, and AFT pipeline (included in Section 4 — Solution Architecture)
- **Network Topology Diagram** — Detailed Transit Gateway route table design, Network Firewall placement, IPAM pool hierarchy, and spoke VPC attachment model (to be produced as part of Phase 2 architecture documentation deliverable)
- **Data Flow Diagram** — CloudTrail, Config, GuardDuty, and VPC Flow Log delivery paths to Log Archive and Audit accounts (to be produced as part of Phase 1 architecture documentation deliverable)
- **Security Architecture Diagram** — IAM Identity Center permission set assignments, SCP inheritance hierarchy, and GuardDuty/Security Hub aggregation topology (to be produced as part of Phase 1 architecture documentation deliverable)

## Naming Conventions

All AWS resources created during this engagement follow the naming convention standard defined below. Consistent naming enables resource identification, supports cost allocation queries, and simplifies operational investigation.

<!-- TABLE_CONFIG: widths=[28, 38, 34] -->
| Resource Type | Pattern | Example |
|---------------|---------|---------|
| AWS Account | `{client-short}-{ou-type}-{env}-{sequence}` | `ins-workload-prod-001` |
| VPC | `{account-id-short}-{region-short}-{purpose}-vpc` | `ins-prod-001-use1-workload-vpc` |
| Subnet | `{vpc-name}-{tier}-{az}` | `ins-prod-001-use1-workload-vpc-app-a` |
| Transit Gateway | `{client-short}-{region-short}-tgw` | `ins-use1-tgw` |
| Network Firewall | `{client-short}-{region-short}-nfw` | `ins-use1-nfw` |
| IAM Identity Center Permission Set | `{Role}Access-{scope}` | `PlatformAdministratorAccess-shared`, `WorkloadAdministratorAccess-prod` |
| S3 Bucket (Log Archive) | `{client-short}-log-archive-{region-short}-{account-id}` | `ins-log-archive-use1-123456789012` |
| CloudTrail Trail | `{client-short}-org-trail-{region-short}` | `ins-org-trail-use1` |
| SCP | `{client-short}-scp-{policy-name}` | `ins-scp-deny-root`, `ins-scp-restrict-regions` |
| Terraform Workspace | `{client-short}-{account-purpose}-{region-short}` | `ins-network-hub-use1`, `ins-audit-use1` |
| AFT Account Request File | `{account-name}.tf` in account requests repo | `ins-workload-prod-001.tf` |
| CloudWatch Alarm | `{client-short}-{component}-{metric}-{threshold}` | `ins-aft-pipeline-failure-critical` |

## Tagging Standards

All AWS resources created by Terraform and AFT must carry the five mandatory tags defined below. Tag compliance is enforced at the organisation level via AWS Organizations Tag Policies and monitored by an AWS Config rule (`required-tags`).

<!-- TABLE_CONFIG: widths=[22, 10, 35, 33] -->
| Tag Key | Required | Valid Values | Example |
|---------|----------|--------------|---------|
| `Environment` | Yes | `development`, `non-production`, `production`, `platform`, `sandbox` | `production` |
| `Owner` | Yes | Team name or email (from IAM Identity Center group) | `cloud-platform-team` |
| `CostCenter` | Yes | Finance cost centre code (provided by client FinOps contact at kick-off) | `CC-CLOUD-001` |
| `Project` | Yes | Project name or code | `landing-zone-2025` |
| `DataClassification` | Yes | `public`, `internal`, `confidential`, `restricted` | `restricted` |

## Risk Register

The following risks were identified during pre-sales discovery and architecture design. Each risk is assigned a likelihood, impact, and mitigation strategy. Risks are reviewed at the start of each project phase and updated in the project status report.

<!-- TABLE_CONFIG: widths=[30, 12, 15, 43] -->
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Identity source for IAM Identity Center not confirmed before end of Phase 1, delaying SSO configuration | Medium | High | Dependency D4 is a formal project gate. If IdP is not confirmed by Week 3, native AWS SSO directory is deployed as default; IdP migration is scoped as a change request. |
| On-premises VPN gateway incompatible with AWS IKEv2 or does not support BGP routing | Low | High | Dependency D5 requires on-premises gateway details confirmed by Week 4. Static routing fallback is designed and documented; Direct Connect upgrade path removes the dependency entirely. |
| Compliance framework requirements (NIST/SOC 2/HIPAA) not confirmed by Week 2, requiring rework of conformance pack configuration | Medium | Medium | Dependency D3 is a formal gate. FSBP is deployed regardless; additional framework packs are additive and do not require rework of foundational components. Change control handles late confirmations. |
| AFT pipeline Terraform Cloud token or VCS webhook misconfiguration causes account vending failures in Phase 3 | Low | High | AFT is tested in a non-production (Sandbox OU) account vending run before any Production account vending is attempted. Rollback procedure documented in AFT runbook. |
| HashiCorp Terraform BSL licence restrictions conflict with client procurement policy, requiring pivot to OpenTofu | Low | High | Risk RISK-003 from discovery questionnaire. Licence preference confirmed by Dependency D6 (Week 4). If OpenTofu is required, AFT supports OpenTofu as an alternative Terraform runtime; no architectural change required. |
| Client key stakeholder unavailability during UAT (Week 12) delays go-live sign-off | Medium | Medium | UAT scheduling confirmed 3 weeks in advance per Assumption 8. If UAT is delayed, hypercare period absorbs the delay with no commercial impact; go-live date slides, not engagement scope. |
| 10.0.0.0/8 supernet overlaps with existing on-premises or partner network ranges | Low | Critical | On-premises IP ranges confirmed during Phase 1 discovery (pre-networking build). Alternative supernet (172.16.0.0/12) is available if required; IPAM reconfiguration is a Phase 2 activity before any spoke VPCs are provisioned. |
| AWS Control Tower version upgrade during engagement disrupts in-flight deployment | Low | Medium | Control Tower landing zone upgrades are pin-locked during active deployment. Upgrades are reviewed and applied only during scheduled maintenance windows post-go-live, following the Control Tower update runbook. |
| Client team does not have sufficient AWS familiarity to complete UAT independently | Medium | Medium | Two training tracks (Infrastructure and Security) are delivered in Week 12. Hypercare support is explicitly scoped to assist with first workload account vending and Security Hub triage during the initial operations period. |
| AWS service disruption in us-east-1 impacting Control Tower management plane during critical deployment activities | Very Low | High | Phase gate activities are scheduled to avoid known AWS maintenance windows. Phase 3 security and AFT deployment activities proceed independently of Control Tower management plane availability (SCPs and guardrails remain enforced). |

## Glossary

The following terms and abbreviations are used throughout this document.

<!-- TABLE_CONFIG: widths=[22, 78] -->
| Term | Definition |
|------|------------|
| AFT | Account Factory for Terraform — AWS's native account vending solution built on Terraform and CodePipeline |
| APN | AWS Partner Network — Amatra's partner programme that provides access to credits and technical resources |
| ASN | Autonomous System Number — a unique identifier used in BGP routing to identify a network |
| CIDR | Classless Inter-Domain Routing — IP address block notation (e.g., 10.0.0.0/16) |
| CRR | Cross-Region Replication — S3 feature that automatically replicates objects to a bucket in another region |
| CSPM | Cloud Security Posture Management — continuous monitoring of cloud resource configurations for compliance |
| CT | AWS Control Tower — AWS's managed service for setting up and governing a secure multi-account environment |
| EDP | Enterprise Discount Programme — AWS commercial programme for committed spend discounts |
| FSBP | AWS Foundational Security Best Practices — the AWS Security Hub standard covering 200+ security controls |
| GuardDuty | Amazon GuardDuty — AWS threat detection service analysing VPC Flow Logs, CloudTrail events, and DNS logs |
| HIPAA | Health Insurance Portability and Accountability Act — US federal regulation governing PHI protection |
| IaC | Infrastructure as Code — managing infrastructure through machine-readable configuration files (Terraform) |
| IAM | AWS Identity and Access Management — AWS service for managing access to AWS resources |
| IdP | Identity Provider — an external authentication service (e.g., Azure AD, Okta) federated with IAM Identity Center |
| IPAM | VPC IP Address Manager — AWS service for centralised IP address planning and allocation across accounts |
| MAP | AWS Migration Acceleration Program — AWS partner programme providing credits for cloud migrations |
| MTTR | Mean Time to Recovery — average time to restore service following an incident |
| NIST 800-53 | National Institute of Standards and Technology Special Publication 800-53 — US federal security control framework |
| OU | Organisational Unit — a container within AWS Organizations for grouping accounts with common policy requirements |
| PHI | Protected Health Information — health data protected under HIPAA |
| PII | Personally Identifiable Information — data that can identify an individual, subject to privacy regulations |
| RCP | Resource Control Policy — AWS Organizations policy that enforces data perimeter controls at the resource level |
| RPO | Recovery Point Objective — maximum acceptable data loss measured in time |
| RTO | Recovery Time Objective — maximum acceptable time to restore a service after failure |
| SAML | Security Assertion Markup Language — XML-based standard for SSO federation between identity providers and service providers |
| SCIM | System for Cross-domain Identity Management — protocol for automating user and group provisioning to cloud applications |
| SCP | Service Control Policy — AWS Organizations policy that sets maximum permission boundaries for member accounts |
| SIEM | Security Information and Event Management — platform for aggregating and correlating security event logs |
| SNS | Amazon Simple Notification Service — AWS managed publish-subscribe messaging service |
| SOC 2 | System and Organisation Controls 2 — auditing framework for service organisation security, availability, and confidentiality |
| SQS | Amazon Simple Queue Service — AWS managed message queuing service |
| SSO | Single Sign-On — authentication scheme allowing users to access multiple applications with one set of credentials |
| TGW | AWS Transit Gateway — hub-and-spoke network connectivity service for VPCs and on-premises networks |
| UAT | User Acceptance Testing — formal client-side validation of delivered capabilities against acceptance criteria |
| VCS | Version Control System — platform for source code management (e.g., GitHub, GitLab, CodeCommit) |
| VPC | Virtual Private Cloud — logically isolated AWS network environment |
| VPN | Virtual Private Network — encrypted tunnel connectivity between on-premises and AWS |
