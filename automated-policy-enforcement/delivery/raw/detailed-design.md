---
document_title: Detailed Design Document
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

This Detailed Design Document provides the authoritative technical blueprint for the AWS Cloud Governance Platform engagement at Contoso Financial. It expands the Architecture & Design section of the Statement of Work (SOW) into implementation-ready specifications that guide the Amatra delivery team through all four months of the engagement and serve as the primary technical reference for Contoso Financial's platform engineers and CISO during and after delivery.

Contoso Financial is an Australian retail bank operating under national financial services compliance standards with a hard regulatory review deadline of 30 April 2026. The current cloud environment is characterised by manual provisioning, shared administrative credentials, no automated policy enforcement, and no centralised compliance evidence collection — generating 3–4 compliance findings per quarter. This engagement delivers a fully automated, policy-enforced AWS Cloud Governance Platform built on AWS Control Tower, Account Factory for Terraform (AFT), Service Control Policies, AWS Config, IAM Identity Center, Security Hub, GuardDuty, and CloudTrail — replacing the current ad-hoc posture with a continuously monitored, audit-ready governance foundation.

All platform components are deployed exclusively within Australian AWS regions (ap-southeast-2 as primary, ap-southeast-4 as DR), satisfying Contoso Financial's data sovereignty obligations. Every architectural decision documented in this design traces directly to a commitment made in the SOW and is aligned to the ISO 27001 control framework and Contoso Financial's internal security baseline. This document is version 1.0, aligned to SOW version 1.0, and is subject to the CISO sign-off gate at the end of Week 6 before Phase 2 implementation begins.

## Purpose

This document defines the complete technical design of the AWS Cloud Governance Platform, covering solution architecture, security and compliance controls, data architecture, integration patterns, infrastructure and operational design, and the phased implementation approach. It is the primary reference for Amatra's delivery team (Solution Architect, Solutions Engineers, Cloud Engineer, Security Engineer) and Contoso Financial's platform team (Priya Nair and team). The CISO and James Wu (CTO) should use this document to validate that the technical design meets their compliance and strategic objectives before Phase 2 build activities commence.

## Scope

**In-scope:**

- AWS Control Tower landing zone deployment with structured Organizational Unit (OU) hierarchy in ap-southeast-2 (primary)
- DR baseline mirror deployment in ap-southeast-4 with cross-region replication for Config, CloudTrail, and Security Hub
- Account Factory for Terraform (AFT) account vending pipeline with ITSM change-approval integration
- Service Control Policies (SCPs): no-console-access in production, region lock, encryption enforcement
- AWS Config conformance packs aligned to ISO 27001 and Contoso Financial's internal security baseline (~80 rules)
- Centralised Security Hub, GuardDuty, and CloudTrail with 12-month S3 WORM log archive
- IAM Identity Center federation with on-premises enterprise directory (1 IdP connector via SAML 2.0)
- SIEM integration: Security Hub findings and CloudTrail events forwarded to existing on-premises SIEM
- ITSM workflow integration: change-approval gating for account vending via existing ticketing platform
- Onboarding of three existing production environments into the new account structure
- Network infrastructure: Transit Gateway, VPC topology, Direct Connect connectivity to both on-premises data centres
- ISO 27001 compliance evidence package for regulatory submission
- Operational runbooks, architecture documentation, and knowledge transfer

**Out-of-scope:**

- Migration or remediation of the two legacy on-premises workloads
- Application refactoring, re-platforming, or code changes to existing workloads
- Replacement of the on-premises identity provider (federation only)
- Management of the existing on-premises SIEM or ITSM platform
- Security penetration testing or red-team exercises beyond guardrail validation
- Compliance frameworks beyond ISO 27001 and the internal security baseline (e.g., PCI-DSS, SOC 2)
- AWS Direct Connect circuit procurement (Contoso Financial's responsibility)

## Assumptions & Constraints

- The CISO or delegated security representative provides written architecture sign-off by end of Week 6; Phase 2 cannot commence without this approval.
- Contoso Financial will procure and order AWS Direct Connect hosted connections for both ap-southeast-2 and ap-southeast-4 before the start of Phase 2 (Week 7); lead times are the client's responsibility.
- The on-premises IdP team is available for a federation design workshop in Week 3 and federation configuration sessions in Week 11.
- SIEM and ITSM administrators provide API credentials, endpoint documentation, and technical co-ordination within two weeks of project kickoff.
- Read-only access to existing AWS accounts and IAM reports will be provided to the Amatra team within five business days of kickoff.
- Internal security baseline documentation is available for review during Week 1 of Discovery.
- All new accounts and environments are greenfield; no application data migration is required.
- AWS MAP (Migration Acceleration Program) and AWS Partner Services Credits are confirmed by the AWS account team prior to engagement commencement.
- All platform services and data must remain in Australian AWS regions (ap-southeast-2 and ap-southeast-4) at all times.
- Terraform Cloud Plus and Datadog APM licences are procured before the start of Phase 2.

## References

- Statement of Work (SOW) v1.0 — AWS Cloud Governance Platform, Contoso Financial, June 2025
- Solution Briefing — AWS Cloud Governance Platform, Contoso Financial
- AWS Control Tower User Guide (current)
- AWS Account Factory for Terraform (AFT) Developer Guide
- ISO/IEC 27001:2022 — Information Security Management Systems
- Contoso Financial Internal Security Baseline (provided in Week 1)
- AWS Config Conformance Pack: Operational Best Practices for ISO 27001
- AWS IAM Identity Center Administrator Guide

---

# Business Context

The AWS Cloud Governance Platform engagement is driven by a convergence of regulatory obligation, operational risk, and strategic cloud maturity goals at Contoso Financial. The organisation has a non-negotiable external deadline — a clean ISO 27001 regulatory review by 30 April 2026 — and the current manual, credential-sharing cloud environment is unable to produce the continuous, tamper-evident compliance evidence that auditors require. Every design decision in this document is anchored to the outcome of clearing that audit, while simultaneously establishing the governance foundation that will allow Contoso Financial to scale its cloud footprint safely and efficiently beyond the initial engagement.

## Business Drivers

- **Regulatory Deadline — April 2026:** Contoso Financial has committed to achieving a clean ISO 27001 regulatory review by 30 April 2026. The current environment generates 3–4 compliance findings per quarter, each requiring manual remediation. The governance platform must be operational and producing automated compliance evidence by the end of Phase 2 (Week 12), with the evidence package validated and ready for submission by the end of Phase 3 (Week 15).
- **Eliminate Shared Credential Risk:** Production environments are currently accessed via shared administrative credentials with no individual attribution in CloudTrail. IAM Identity Center federation with the on-premises enterprise directory eliminates this exposure, enforces individual role-based access, and provides a complete, attributed audit trail for all AWS API activity.
- **Automate Environment Provisioning:** Manual provisioning is slow (days to create a new environment), error-prone, and unauditable. The AFT account vending pipeline with ITSM change-approval integration will reduce provisioning time to under 4 hours, enforce a consistent security baseline on every new account from day one, and provide a fully auditable change record for every provisioning action.
- **Continuous Compliance Evidence:** The current posture requires manual audit preparation before every review cycle, consuming significant platform team capacity. The governance platform's continuous Config, Security Hub, and CloudTrail evidence collection eliminates this toil, producing an always-current compliance evidence package that can be exported on demand.
- **Data Sovereignty Assurance:** Contoso Financial's data sovereignty requirements mandate that all data, control-plane activity, and audit logs remain within Australia. The dual-region architecture (ap-southeast-2 primary, ap-southeast-4 DR) with in-country cross-region replication provides full data residency assurance.

## Workload Criticality & SLA Expectations

The governance platform itself is a critical production service; its availability directly affects Contoso Financial's ability to provision new environments, enforce compliance controls, and produce audit evidence. The following SLA targets govern the platform and are traced directly to the SOW Success Metrics.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Metric | Target | Measurement | Priority |
|--------|--------|-------------|----------|
| Platform Availability | 99.9% | CloudWatch uptime monitoring across ap-southeast-2 services | Critical |
| RTO (DR Failover) | < 4 hours | DR failover drill — measured in Phase 3 and documented as regulatory evidence | Critical |
| RPO (Data Loss) | < 1 hour | S3 cross-region replication lag measurement over 24-hour period | Critical |
| Security Finding → SIEM | ≤ 5 minutes | EventBridge delivery latency from Security Hub finding to SIEM ingestion | High |
| Account Vending Pipeline | < 60 minutes | End-to-end time from ITSM approval to account fully baselined | High |
| Config Rule Evaluation | ≤ 60 seconds | Time from resource configuration change to Config rule evaluation firing | High |
| Audit Log Delivery | ≤ 15 minutes | CloudTrail log file delivery latency to Log Archive S3 bucket | High |

## Compliance & Regulatory Factors

- **ISO 27001:2022:** The primary compliance framework for this engagement. AWS Config conformance packs map ~80 Config rules to ISO 27001 Annex A controls. The compliance evidence package produced in Phase 3 is structured for direct submission to the Q2 2026 regulatory review.
- **Contoso Financial Internal Security Baseline:** Custom Config rules and SCP conditions enforce controls specific to the organisation's internal baseline that are not covered by the standard ISO 27001 conformance pack. The baseline documentation is collected during Week 1 discovery.
- **Financial Services Regulatory Standards:** Contoso Financial operates under national financial services compliance obligations. The no-manual-console-access mandate, MFA enforcement, immutable log retention, and DR requirements are all direct responses to these obligations.
- **Data Sovereignty (Mandatory):** All data, metadata, and control-plane activity must remain within Australia at all times. The ap-southeast-2 and ap-southeast-4 region lock enforced via SCPs is a hard technical control, not a policy recommendation.

## Success Criteria

The following criteria, drawn directly from the SOW, define successful delivery and will be formally validated during Phase 3 testing before the CISO provides go-live sign-off:

- Zero compliance findings from the Q2 2026 regulatory review (hard deadline: 30 April 2026)
- 80% reduction in audit remediation effort measured by platform team hours per audit cycle
- 100% of production accounts governed by SCPs with no manual console access permitted (break-glass procedure excepted)
- All new environment provisioning completed via AFT account vending pipeline with ITSM change-approval gate; zero manual account creation
- IAM Identity Center federation live with on-premises IdP; zero shared administrative credentials in any AWS account
- Security Hub findings forwarded to existing SIEM within 5 minutes of detection
- ISO 27001 compliance evidence package produced, validated, and accepted by CISO before end of Phase 3
- DR failover drill validated with RTO < 4 hours and RPO < 1 hour before the regulatory review

---

# Current-State Assessment

Contoso Financial's current AWS environment reflects an organisation that adopted cloud services rapidly but without establishing governance foundations. The platform engineering team, led by Priya Nair, manages all cloud environments manually using shared administrative credentials, with no automated policy enforcement, no centralised compliance monitoring, and no ITSM-gated change process for cloud provisioning. This section documents the current state based on the Discovery activities in Phase 1 (Weeks 1–4) and the gap analysis that informs the target-state design.

## Application Landscape

The three production environments being onboarded into the governance platform are pre-existing workloads running on AWS. They are not being migrated or re-platformed as part of this engagement — the scope is to bring their AWS accounts under the governance framework with the AFT baseline and guardrails applied.

<!-- TABLE_CONFIG: widths=[25, 30, 25, 20] -->
| Application | Purpose | Technology | Onboarding Action |
|-------------|---------|------------|-------------------|
| Production Environment 1 | Workload — details confirmed in Week 1 discovery | AWS services (to be documented) | Onboard via AFT baseline + SCP enforcement |
| Production Environment 2 | Workload — details confirmed in Week 1 discovery | AWS services (to be documented) | Onboard via AFT baseline + SCP enforcement |
| Production Environment 3 | Workload — details confirmed in Week 1 discovery | AWS services (to be documented) | Onboard via AFT baseline + SCP enforcement |
| On-Premises Workload 1 | Legacy on-premises application | On-premises (excluded) | Out of scope — no AWS account changes |
| On-Premises Workload 2 | Legacy on-premises application | On-premises (excluded) | Out of scope — no AWS account changes |

## Infrastructure Inventory

The current AWS footprint comprises a small number of accounts created without a structured OU hierarchy, lacking centralised governance controls. The following is the known pre-engagement AWS estate, to be fully documented during Week 1–2 discovery.

<!-- TABLE_CONFIG: widths=[20, 15, 35, 30] -->
| Component | Quantity | Specifications | Notes |
|-----------|----------|----------------|-------|
| AWS Accounts (existing) | ~3–5 | Unstructured; no OU hierarchy | To be assessed in Week 1 |
| IAM Users (shared credentials) | Unknown | Long-lived access keys; shared admin credentials | All to be retired post-federation |
| CloudTrail | Not centralised | Per-account; no centralised archive | No log integrity validation in place |
| AWS Config | Not enabled | No conformance packs or custom rules | No compliance monitoring |
| Security Hub / GuardDuty | Not enabled | No organisational detector | No threat detection |
| IAM Identity Center | Not configured | No IdP federation | On-premises IdP not connected to AWS |
| Network (VPC) | Per-account VPCs | No Transit Gateway; no centralised routing | Direct internet egress per account |
| Patch Management | Manual / ad-hoc | No Systems Manager configuration | Console-based SSH/RDP access used |

## Dependencies & Integration Points

- **On-Premises Enterprise Directory (IdP):** The authoritative identity source for all Contoso Financial users. The IdP team must participate in the federation design workshop (Week 3) and configuration sessions (Week 11). The IdP remains in place; this engagement delivers federation only.
- **Existing On-Premises SIEM:** Security alerting destination for Security Hub findings and CloudTrail events. SIEM API credentials and endpoint documentation required by Week 9.
- **Existing ITSM Ticketing Platform:** Change-approval workflow source for account vending requests and guardrail change management. ITSM API access and workflow documentation required by Week 8.
- **AWS Direct Connect Circuits:** Physical connectivity from Contoso Financial's data centres to ap-southeast-2 and ap-southeast-4. Ordered and provisioned by Contoso Financial before Phase 2 commencement.

## Network Topology

The current network topology consists of isolated per-account VPCs with no centralised routing or traffic inspection. Internet egress is configured per-account without a centralised firewall. There is no Transit Gateway, and connectivity to on-premises data centres is achieved via per-account VPN connections (or in some cases, public endpoints), creating an inconsistent and unauditable network posture. The AWS Direct Connect circuits for both data centres are to be ordered by Contoso Financial prior to Phase 2.

## Security Posture

The current security posture is characterised by significant control gaps across all three layers of the defence-in-depth model. Key findings from the SOW current-state assessment are as follows:

- No Service Control Policies are in place; account administrators can perform any action, including disabling CloudTrail
- No restriction on console access in production; IAM users with long-lived access keys are in active use
- No MFA enforcement at the AWS level (on-premises IdP MFA is not propagated to AWS sessions)
- No centralised CloudTrail; per-account trails have no log integrity validation and no guaranteed retention
- No AWS Config, Security Hub, or GuardDuty; no continuous compliance monitoring or threat detection
- IAM Identity Center not configured; no federated identity or individual access attribution in CloudTrail

## Performance Baseline

- Current provisioning time: Days to weeks (manual, credential-sharing process)
- Compliance findings per quarter: 3–4 (manual remediation required)
- Audit preparation effort: Significant platform team hours per audit cycle (to be quantified in Week 1 discovery)
- CloudTrail coverage: Partial (not all accounts; no centralised archive)
- RTO/RPO: Undefined (no DR testing or documented procedure)

## Gap Analysis

The following gap analysis identifies the key differences between the current state and the target governance platform, directly informing the implementation scope.

<!-- TABLE_CONFIG: widths=[33, 34, 33] -->
| Current State | Gap | Target State |
|---------------|-----|--------------|
| No OU hierarchy; unstructured accounts | No Control Tower; no account governance | Control Tower landing zone with structured OU hierarchy and guardrail inheritance |
| Manual account provisioning (days) | No IaC pipeline; no ITSM gating | AFT account vending pipeline; ITSM change-approval; < 60 min provisioning |
| Shared IAM user credentials; no attribution | No IAM Identity Center; no IdP federation | IAM Identity Center federated to on-premises IdP; zero shared credentials |
| No SCPs; unrestricted console access | No preventive guardrails | SCPs block console access in prod, enforce region lock, mandate encryption |
| No AWS Config; no compliance monitoring | No detective guardrails | ~80 Config rules (ISO 27001 conformance pack + internal baseline); auto-remediation |
| No centralised CloudTrail; no log integrity | Fragmented audit trail; no tamper-evidence | Centralised S3 WORM archive; 12-month retention; SHA-256 log integrity validation |
| No Security Hub / GuardDuty | No aggregated threat and compliance posture | Organisational Security Hub + GuardDuty; findings forwarded to SIEM in ≤ 5 min |
| No SIEM integration | Security findings not in existing workflows | EventBridge + Lambda pipeline; CRITICAL/HIGH findings forwarded to on-premises SIEM |
| No ITSM change governance | Cloud changes bypass ITSM approval | ITSM change-approval gates all account vending and guardrail changes |
| Per-account VPCs; no centralised routing | No traffic inspection; inconsistent egress | Transit Gateway hub-spoke; Network Firewall; Direct Connect to both data centres |
| No DR design; no RTO/RPO targets | No DR capability validated | ap-southeast-4 DR baseline; RTO < 4 h; RPO < 1 h; validated in Phase 3 drill |

---

# Solution Architecture

The AWS Cloud Governance Platform establishes a comprehensively governed, multi-account AWS environment for Contoso Financial using AWS Control Tower as the management foundation. The architecture adopts a hub-and-spoke network topology with a dedicated Network Account hosting Transit Gateway and AWS Network Firewall, through which all inter-account and on-premises traffic flows. Governance, logging, and security monitoring are centralised in dedicated management accounts, with all data stored in ap-southeast-2 (primary) and replicated to ap-southeast-4 (DR) to provide continuous in-country data residency and disaster recovery capability.

Policy enforcement operates at two distinct layers. Preventive controls — implemented via Service Control Policies attached to Organizational Units — block prohibited actions before they can take effect: no console access in production accounts, service usage restricted to approved Australian AWS regions, and encryption mandated for all data-at-rest services. Detective controls — implemented via AWS Config conformance packs mapping to ISO 27001 Annex A controls, supplemented by custom rules for the Contoso Financial internal security baseline — continuously monitor configuration compliance, with automated Lambda-based remediation for defined low-risk deviations. This dual-layer model ensures violations are either prevented outright or detected and remediated within minutes, generating the continuous compliance evidence required for the April 2026 regulatory review.

The identity model eliminates shared credentials entirely. All human access to AWS is federated through IAM Identity Center, which authenticates users against the on-premises enterprise directory via SAML 2.0. Permission sets are role-scoped and follow least-privilege principles. All AWS API activity is attributed to individual federated identities in CloudTrail, providing the individual accountability chain demanded by both the ISO 27001 framework and Contoso Financial's internal security baseline.

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

**Figure 1: AWS Cloud Governance Platform Architecture** — Multi-account landing zone with AWS Control Tower, AFT account vending, SCP and Config guardrails, IAM Identity Center federation, hub-and-spoke Transit Gateway network, centralised Security Hub / GuardDuty / CloudTrail monitoring, and dual-region (ap-southeast-2 / ap-southeast-4) in-country deployment.

## Architecture Principles

The following design principles govern every component and configuration decision in this document. Each principle is derived from the business objectives and compliance requirements defined in the SOW.

- **Compliance by Default:** Every new AWS account is born compliant. AFT applies the full security baseline — tagging, VPC module, IAM roles, CloudTrail enablement, Security Hub enrollment, and Config rules — as part of account vending, before any workload is deployed. Compliance is not retrofitted; it is the starting state.
- **Prevention Over Detection:** Preventive SCPs are the first line of defence. If a control can be enforced at the SCP layer before an action occurs, it is. Detective Config rules are the second layer for configurations that cannot be prevented by SCPs. Auto-remediation is the third layer for low-risk deviations. This hierarchy minimises the window of non-compliance.
- **Zero Standing Privilege in Production:** No human identity has persistent console access to any production account. All production changes are executed by the AFT pipeline using scoped deployment roles, following an approved ITSM change record. Break-glass is the only exception, and it is time-limited, CISO-approved, and fully logged.
- **Evidence-First Design:** The architecture is designed to produce continuous, tamper-evident compliance evidence as a primary output — not an afterthought. CloudTrail with S3 Object Lock (Compliance mode), Config history snapshots, and Security Hub compliance reports collectively constitute the evidence engine that eliminates manual audit preparation.
- **In-Country Sovereignty:** All data, metadata, and control-plane activity resides in Australia at all times. The ap-southeast-2 and ap-southeast-4 region lock is a hard technical control enforced at the SCP level, not a voluntary configuration. No cross-border data transfer occurs at any layer.
- **Everything-as-Code:** All infrastructure, account baselines, guardrails, permission sets, and pipeline configurations are managed as code in Git-backed Terraform workspaces. No manual console configuration is permitted for any governance component. This ensures reproducibility, auditability, and the ability to demonstrate to auditors that the platform configuration matches the documented design.

## Architecture Patterns

- **Primary Pattern:** Multi-account hub-and-spoke (AWS Organizations with Control Tower + AFT)
- **Network Pattern:** Hub-and-spoke via Transit Gateway with centralised AWS Network Firewall for east-west and egress traffic inspection
- **Policy Pattern:** SCP-first preventive guardrails + Config conformance-pack detective guardrails + Lambda auto-remediation
- **Identity Pattern:** Federated identity via IAM Identity Center (SAML 2.0) with RBAC permission sets; zero standing privilege in production
- **Data Pattern:** Event-driven compliance evidence collection (Config → S3, CloudTrail → S3 WORM, Security Hub → EventBridge → Lambda → SIEM)
- **Deployment Pattern:** GitOps via Terraform Cloud VCS-backed workspaces; all changes through pull request with Sentinel policy check

## Component Design

The platform is structured around a defined set of specialised AWS accounts within an Organizational Unit hierarchy managed by AWS Control Tower. Each account has a single, well-defined responsibility and hosts only the services appropriate to that function. The following table describes every platform component, its purpose, the specific AWS technology stack, dependencies, and scaling characteristics.

<!-- TABLE_CONFIG: widths=[18, 25, 22, 18, 17] -->
| Component | Purpose | Technology | Dependencies | Scaling |
|-----------|---------|------------|--------------|---------|
| Management Account | Root of AWS Organizations hierarchy; hosts Control Tower, AFT pipeline orchestration, and org-level SCPs | AWS Control Tower, AWS Organizations, AFT (Terraform Cloud Plus), Amazon S3 (Terraform state), Amazon DynamoDB (AFT workflow) | AWS Direct Connect (management traffic), ITSM API | Single account; no horizontal scaling required |
| Log Archive Account | Centralised, tamper-evident storage for all CloudTrail, Config, and Security Hub log exports | Amazon S3 (Object Lock, WORM Compliance mode), S3 Cross-Region Replication, AWS KMS | All accounts (CloudTrail delivery), Audit account (Security Hub export) | S3 scales automatically; provisioned for 500 GB/month initial volume |
| Audit Account | Aggregated security posture; hosts Security Hub org aggregator, GuardDuty org detector, Config aggregator, Access Analyzer | AWS Security Hub, Amazon GuardDuty, AWS Config Aggregator, AWS Access Analyzer, Amazon EventBridge, AWS Lambda | Log Archive (finding exports), SIEM (EventBridge → Lambda forwarding pipeline) | Lambda concurrency auto-scales; Security Hub finding throughput ~1,000/month |
| Security Account | Identity federation hub; hosts IAM Identity Center SSO portal, permission sets, SAML connector | AWS IAM Identity Center, SAML 2.0 IdP connector, AWS SSO application assignments | On-premises enterprise directory (IdP), all workload accounts | Single org-level service; scales to 150 platform users + developers |
| Network Account | Centralised network hub; hosts Transit Gateway, VPC attachments, Network Firewall, Direct Connect termination, Route 53 Resolver | AWS Transit Gateway, AWS Network Firewall, AWS Direct Connect (1 Gbps × 2), AWS Site-to-Site VPN, Amazon Route 53 Resolver | All workload accounts (TGW attachments), on-premises data centres (Direct Connect) | Transit Gateway scales automatically; Network Firewall scales with throughput |
| Workload Accounts (×3 prod + dev/test/staging) | Environment-isolated accounts provisioned via AFT; each born with full security baseline | AFT-applied baseline: VPC module, IAM roles, CloudTrail, Config enrollment, Security Hub enrollment, tagging | Management Account (AFT pipeline), ITSM (change approval), Network Account (TGW attachment) | Additional accounts vended on demand via AFT; no manual scaling |
| AFT Pipeline | IaC-driven account vending; enforces baseline on every new account; integrates with ITSM change approval | Account Factory for Terraform (AFT), Terraform Cloud Plus (10 workspaces), AWS Service Catalog, AWS Lambda, Amazon DynamoDB | ITSM API (change approval gate), Git repository (IaC source of truth) | Handles 5+ concurrent vending requests; load-tested in Phase 3 |
| SIEM Forwarding Pipeline | Near-real-time forwarding of Security Hub CRITICAL/HIGH findings and CloudTrail events to on-premises SIEM | Amazon EventBridge (org event bus), AWS Lambda (transformation + delivery), on-premises SIEM API endpoint | Audit Account (Security Hub findings source), SIEM API credentials | Lambda auto-scales; validated for ≤ 5-minute end-to-end delivery latency |
| DR Baseline (ap-southeast-4) | Mirrored Control Tower baseline providing in-country DR capability; activated during failover | AWS Control Tower (DR region), S3 Cross-Region Replication, AWS Config (cross-region aggregation), Security Hub (cross-region aggregation) | Log Archive Account (replication destination), Audit Account (Config/SH aggregation source) | Passive standby; activated via documented runbook; RTO < 4 h validated in Phase 3 |
| CI/CD GitOps Pipeline | Infrastructure delivery pipeline enforcing policy compliance checks on all IaC changes before deployment | Git (VCS), Terraform Cloud (VCS-backed workspaces), Terraform Sentinel (policy-as-code), AWS CodePipeline (AFT orchestration) | Terraform Cloud Plus licence, Git repository, AFT pipeline | Scales with number of active workspaces (10 initial); no manual intervention required |

## Technology Stack

The technology stack below maps each architectural layer to the specific AWS managed service or third-party tool selected, with the rationale for each choice tied directly to the compliance and operational requirements of the engagement.

<!-- TABLE_CONFIG: widths=[22, 35, 43] -->
| Layer | Technology | Rationale |
|-------|------------|-----------|
| Landing Zone & Multi-Account | AWS Control Tower + AWS Organizations | Native AWS landing zone service; provides OU hierarchy, guardrail inheritance, account factory, and dashboard; eliminates custom orchestration for multi-account governance |
| Account Vending & IaC | Account Factory for Terraform (AFT) + Terraform Cloud Plus | AFT is the AWS-native IaC account vending solution for Control Tower; Terraform Cloud Plus provides Sentinel policy-as-code, audit logs, and team access controls required for ISO 27001 |
| Preventive Guardrails | AWS Service Control Policies (SCPs) | SCPs are the only AWS mechanism that overrides account-level IAM policies; essential for no-console-access and region lock enforcement that cannot be bypassed by account administrators |
| Detective Guardrails | AWS Config + ISO 27001 Conformance Pack + Custom Rules | Config provides continuous configuration compliance monitoring; the ISO 27001 conformance pack maps ~80 rules to Annex A controls; custom rules address the internal baseline |
| Auto-Remediation | AWS Lambda + AWS Systems Manager Automation | Lambda-based remediation triggered by Config non-compliant events; SSM Automation documents used for safe, auditable remediation of specific control deviations |
| Identity & Access | AWS IAM Identity Center + on-premises IdP (SAML 2.0) | IAM Identity Center is the AWS-native federated SSO service; SAML 2.0 federation with the existing on-premises directory eliminates AWS IAM users without replacing the IdP |
| Threat Detection | Amazon GuardDuty (Organisational Detector) | GuardDuty provides ML-based threat detection across all accounts under a single org detector; automatically enrolls new accounts vended by AFT; no per-account configuration overhead |
| Compliance Posture | AWS Security Hub (Organisational Aggregator) | Security Hub aggregates findings from Config, GuardDuty, and Access Analyzer across all accounts into a single compliance dashboard; maps findings to ISO 27001 controls |
| Audit Trail | AWS CloudTrail (Org Trail) + Amazon S3 (Object Lock) | Org-level CloudTrail trail captures all management and data events across all accounts; S3 Object Lock (Compliance mode) provides WORM immutability required for ISO 27001 evidence |
| Security Event Forwarding | Amazon EventBridge + AWS Lambda | EventBridge org event bus captures Security Hub finding events in near-real-time; Lambda transforms and forwards to SIEM API; achieves ≤ 5-minute delivery SLA |
| Network | AWS Transit Gateway + AWS Network Firewall + Direct Connect | TGW provides hub-spoke routing between all accounts and on-premises; Network Firewall provides east-west traffic inspection; Direct Connect provides private, secure DC connectivity |
| Observability | Amazon CloudWatch + AWS Systems Manager | CloudWatch aggregates platform metrics and logs; SSM Fleet Manager and Patch Manager replace console-based instance management; CloudWatch alarms alert on pipeline and compliance issues |
| IaC CI/CD | Terraform Cloud (VCS-backed) + Terraform Sentinel | VCS-backed workspaces enforce GitOps; Sentinel policy checks block non-compliant IaC changes before they are applied; all changes have a Git commit trail |
| DR & Backup | AWS Backup + S3 Cross-Region Replication | AWS Backup protects platform state (DynamoDB, S3 config buckets) with daily snapshots; S3 CRR provides continuous (sub-minute) replication of log archive data to ap-southeast-4 |

---

# Security & Compliance

The security architecture for the AWS Cloud Governance Platform is designed around three interlocking layers of control — preventive, detective, and responsive — aligned to ISO 27001 Annex A and Contoso Financial's internal security baseline. The CISO's sign-off gate at the end of Week 6 validates that these controls meet the organisation's security and regulatory requirements before any production implementation begins. Every control described in this section traces directly to a SOW commitment and will be formally validated during Phase 3 testing before go-live approval.

## Identity & Access Management

All human access to AWS is federated through AWS IAM Identity Center using the on-premises enterprise directory as the authoritative identity provider. SAML 2.0 federation maps on-premises directory groups to IAM Identity Center groups, which are bound to permission sets. This architecture eliminates AWS IAM users, long-lived access keys, and shared passwords across all AWS accounts. Individual attribution of every AWS API call to a named, federated user identity is enforced via CloudTrail session tagging.

- **Authentication:** SAML 2.0 federation from IAM Identity Center to the on-premises enterprise directory; all authentication decisions made by the on-premises IdP
- **MFA Enforcement:** MFA enforced at the on-premises IdP level before SAML assertions are issued to AWS; no AWS-level MFA bypass possible
- **Authorization:** Role-Based Access Control (RBAC) via IAM Identity Center permission sets; permission sets are scoped by role and follow least-privilege principles
- **Service Accounts:** All automation roles are IAM roles assumed by the AFT pipeline and Lambda functions; no IAM users or long-lived access keys exist in any account (break-glass excepted)
- **Session Tagging:** All IAM Identity Center sessions are tagged with the user's on-premises identity; tags propagate to CloudTrail, enabling full attribution of every API call

### Role Definitions

The following permission sets are deployed via IAM Identity Center and assigned to on-premises directory groups. Permission sets are defined as IaC in the AFT module library and managed exclusively through the GitOps pipeline.

<!-- TABLE_CONFIG: widths=[20, 42, 38] -->
| Role | Permissions | Scope |
|------|-------------|-------|
| Developer | Read access to own workload account resources; no IAM modifications; no production access | Dev/Test accounts (own team's only) |
| Platform Operator | Read/Write access to non-production accounts via IaC pipeline roles; read-only in production | Non-production accounts; read-only production |
| Security Viewer | Read-only access to Security Hub, Config, GuardDuty, and CloudTrail in Audit and Log Archive accounts | Audit Account, Log Archive Account |
| Platform Admin | Full access to Management Account and governance configuration via IaC pipeline; no direct console access in production | Management Account (IaC pipeline context only) |
| BreakGlass | Time-limited (4-hour maximum) emergency administrative access; requires CISO approval via ITSM; generates immediate SIEM alert | Management Account only; emergency use only |

## Secrets Management

Secrets management for the governance platform covers pipeline credentials, integration API keys, and service account tokens used by the AFT pipeline, Lambda functions, and ITSM/SIEM integrations.

- **AWS Secrets Manager** is the authoritative store for all platform secrets, including ITSM API credentials, SIEM endpoint credentials, and SAML signing certificates. Secrets are encrypted with AWS KMS customer-managed keys.
- **Rotation Policy:** All integration credentials are rotated every 90 days via Secrets Manager automatic rotation. Lambda rotation functions are deployed for credentials where the target system supports API-based rotation; otherwise, rotation is manual with a tracked ITSM task.
- **Access Logging:** All Secrets Manager `GetSecretValue` API calls are logged to CloudTrail in the Log Archive account. Access to platform secrets outside of the designated Lambda execution roles and AFT pipeline role generates a Security Hub custom finding and SIEM alert.
- **No Plaintext Secrets in Code:** Terraform configurations and Lambda code never contain plaintext secrets. All secret references use `aws_secretsmanager_secret_version` data sources or Secrets Manager ARN environment variables, validated by Terraform Sentinel policy checks on every pull request.

## Network Security

The network security design enforces strict traffic segmentation, centralised inspection, and defence-in-depth through multiple complementary controls.

- **Segmentation:** Hub-and-spoke topology via Transit Gateway; workload accounts cannot communicate peer-to-peer without transiting the Network Account. Route tables enforce explicit allow-lists; all other traffic is denied by default.
- **Firewall:** AWS Network Firewall deployed in the Network Account provides stateful deep-packet inspection for all east-west traffic between accounts and all on-premises traffic. Firewall rule groups enforce application-layer filtering and intrusion detection signatures.
- **Egress Control:** Internet-bound traffic from workload accounts is blocked by default via TGW route table configuration. Outbound access for patch management (Systems Manager) routes through the Network Account's NAT Gateway, passing through Network Firewall.
- **DDoS Protection:** AWS Shield Standard is active on all public-facing endpoints. AWS Shield Advanced is not in scope for the governance platform (which has no public-facing application endpoints), but is available as a future enhancement.
- **Direct Connect Security:** MACsec encryption is enabled on both 1 Gbps Direct Connect hosted connections, providing in-transit protection for all management and federation traffic traversing the dedicated circuits.
- **VPC Design:** All workload account VPCs use non-overlapping RFC 1918 address space, allocated centrally during account vending to prevent route conflicts. No workload account VPC has a direct internet gateway; all internet traffic routes through the Network Account.

## Data Protection

Data protection controls are applied uniformly across all storage services in the governance platform. No data protection exception is permitted in any environment tier.

- **Encryption at Rest:** All S3 buckets (Log Archive, Terraform state, Config snapshots, Security Hub exports), DynamoDB tables (AFT workflow state), and EBS volumes (platform instances) are encrypted using AWS KMS customer-managed keys (CMKs). SSE-KMS is enforced via S3 bucket policies that deny `s3:PutObject` requests without a KMS key specification.
- **Encryption in Transit:** TLS 1.2 or higher is enforced on all HTTPS endpoints. S3 bucket policies enforce `aws:SecureTransport` conditions, rejecting all non-HTTPS requests. API Gateway and Lambda function URLs require TLS. Direct Connect connections use MACsec.
- **Key Management:** AWS KMS CMKs are used for all platform encryption. Key policies restrict decryption to authorised service roles only; no human identity has direct KMS key administrative access in production. Annual key rotation is enabled via KMS automatic rotation.
- **Log Integrity:** CloudTrail log files are protected by SHA-256 digest files that validate log file integrity. S3 Object Lock (Compliance mode, 12-month retention) prevents deletion or modification of log files by any identity, including root. This provides the tamper-evident audit trail required for ISO 27001 evidence.
- **Data Masking:** All development and test accounts use synthetic data only. No production data or PII is permitted in non-production environments. AFT account vending applies a Data Classification tag to each account at provisioning time; SCPs enforce data handling controls based on this tag.

## Compliance Mappings

The following table maps the primary ISO 27001 Annex A control domains to their AWS implementation in the governance platform. The full control mapping matrix (Deliverable #4 — ISO 27001 Control Mapping Matrix) provides a rule-by-rule mapping of all ~80 Config rules to specific ISO 27001 controls and is delivered to the CISO at the end of Week 4.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Framework | Requirement | Implementation |
|-----------|-------------|----------------|
| ISO 27001 — A.5 (Information Security Policies) | Documented security policies enforced | SCPs enforce policies as hard technical controls at OU level; all policy changes managed via IaC with CISO approval |
| ISO 27001 — A.6 (Organisation of Information Security) | Roles and responsibilities defined | IAM Identity Center permission sets define and enforce role-based responsibilities; RACI documented in SOW |
| ISO 27001 — A.8 (Access Control) | Least-privilege access; no shared credentials | IAM Identity Center RBAC; zero IAM users; SAML 2.0 federation; MFA enforced at IdP; quarterly access reviews |
| ISO 27001 — A.12 (Operations Security) | Change management; audit logging | ITSM change-approval for all production changes; CloudTrail org trail with S3 WORM 12-month retention |
| ISO 27001 — A.13 (Communications Security) | Network segmentation; encryption in transit | TGW hub-spoke; Network Firewall east-west inspection; TLS 1.2+; MACsec on Direct Connect; region-lock SCP |
| ISO 27001 — A.14 (System Acquisition/Development) | Secure development; IaC | GitOps Terraform pipeline; Sentinel policy-as-code; no manual console configuration permitted |
| ISO 27001 — A.16 (Incident Management) | Security event detection and response | Security Hub + GuardDuty org-wide; SIEM forwarding ≤ 5 min; auto-remediation for defined deviations |
| ISO 27001 — A.17 (Business Continuity) | DR and RTO/RPO | ap-southeast-4 DR baseline; S3 CRR (sub-minute RPO); DR failover drill RTO < 4 h validated in Phase 3 |
| ISO 27001 — A.18 (Compliance) | Regulatory evidence collection | Config conformance packs; Security Hub compliance reports; CloudTrail completeness attestation |

## Audit Logging & SIEM Integration

The audit logging architecture produces a comprehensive, tamper-evident record of all control-plane activity across all accounts, meeting ISO 27001 A.12.4 (Logging and Monitoring) requirements.

- **CloudTrail:** An organisation-level CloudTrail trail is deployed in the Management account, capturing management events and S3 data events across all AWS accounts and both regions (ap-southeast-2 and ap-southeast-4). Log files are delivered to the Log Archive account's centralised S3 bucket within 15 minutes of the events occurring.
- **Log Retention:** S3 Object Lock (Compliance mode) enforces 12-month immutable retention on all CloudTrail and Config log files. No identity — including the AWS root account — can delete or modify log objects during the retention period.
- **Log Integrity Validation:** CloudTrail SHA-256 digest files are generated every hour. Digest file verification is performed automatically by the compliance evidence pipeline during Phase 3 validation and included in the regulatory evidence package.
- **SIEM Forwarding Pipeline:** An EventBridge rule on the Audit account's default event bus captures Security Hub finding events with SEVERITY of CRITICAL or HIGH. A Lambda function transforms the finding payload into the SIEM's ingestion format and delivers it to the SIEM API endpoint. The pipeline is configured for ≤ 5-minute end-to-end delivery and includes dead-letter queue (SQS DLQ) handling for retry on transient SIEM API failures.
- **CloudTrail SIEM Forwarding:** CloudTrail events for a defined set of sensitive API call types (e.g., `DeleteTrail`, `PutBucketPolicy`, `CreateUser`, `AssumeRoleWithSAML`) are forwarded to the SIEM via a second EventBridge rule and Lambda function, providing the SIEM team with real-time visibility into high-risk API activity.
- **Log Retention Policy:** CloudWatch Logs groups are retained for 90 days in-service; structured exports to S3 extend retention to 12 months, consistent with CloudTrail retention.

---

# Data Architecture

The data architecture of the AWS Cloud Governance Platform is designed around a single, overriding principle: all data generated by the platform is compliance-relevant metadata, and its integrity, immutability, and in-country residency are non-negotiable. No application data or customer PII flows through any governance account; the platform processes configuration state, access logs, compliance findings, and infrastructure metadata only. This simplifies the data architecture while imposing strict controls appropriate to the regulatory context.

## Data Model

### Conceptual Model

The governance platform's data model comprises five core data domains: audit trail data (CloudTrail events), compliance state data (AWS Config snapshots and rule evaluations), security finding data (Security Hub and GuardDuty findings), platform state data (Terraform state, AFT workflow state), and operational metric data (CloudWatch metrics and logs). These domains are logically separated by storage account and bucket, with distinct access controls, retention policies, and replication configurations applied to each.

### Logical Model

The following table defines the key data entities, their core attributes, storage location, and expected volume based on the SOW scope parameters.

<!-- TABLE_CONFIG: widths=[20, 25, 30, 25] -->
| Entity | Key Attributes | Storage / Relationships | Volume |
|--------|----------------|-------------------------|--------|
| CloudTrail Event | EventTime, EventName, UserIdentity (federated), SourceIPAddress, RequestParameters, ResponseElements, awsRegion | Log Archive S3 bucket (`/cloudtrail/`); referenced by Config evaluations and SIEM forwarding pipeline | ~50–200 GB/month (medium tier per scope parameters) |
| Config Configuration Item | ResourceId, ResourceType, ConfigurationStateId, configurationItemStatus, ConfigurationItemCaptureTime, relationships, complianceType | Log Archive S3 bucket (`/config/`); Config Aggregator in Audit account | ~1,000 Config rule evaluations/month across ~80 rules and 8 accounts |
| Security Hub Finding | FindingId, ProductArn, SeverityLabel, Title, Description, ResourceId, ComplianceStatus, UpdatedAt | Audit Account (Security Hub OCSF store); Log Archive S3 bucket (periodic export); SIEM (forwarded findings) | ~1,000 findings/month (per scope parameters) |
| GuardDuty Finding | FindingId, Severity, Type, AccountId, Region, Resource, Service (action, evidence), CreatedAt | Audit Account (GuardDuty findings store); aggregated into Security Hub; forwarded to SIEM for CRITICAL/HIGH | Low volume in steady state; burst during incident |
| Terraform State | ResourceType, ResourceId, AttributeValues, Dependencies, Outputs, WorkspaceId | Management Account S3 bucket (`/terraform-state/`); DynamoDB state lock table | ~10 workspaces; state files < 10 MB each |
| AFT Workflow State | AccountRequestId, AccountEmail, OUPath, BaselineStatus, ITSMChangeRef, timestamps | Management Account DynamoDB table (`aft-account-request`); backed up daily by AWS Backup | ~50–100 items (one per vended account) |
| CloudWatch Metric | Namespace, MetricName, Dimensions, Timestamp, Value, Unit | CloudWatch metric store (ap-southeast-2); exported to S3 for 12-month retention | ~100 GB/month of CloudWatch log data |

## Data Flow Design

The following describes the end-to-end flow of the three highest-volume and highest-criticality data streams in the governance platform.

**CloudTrail Audit Flow:**
1. **Generation:** Every API call across all AWS accounts and both regions generates a CloudTrail management event; S3 data events additionally captured for Log Archive bucket.
2. **Aggregation:** Org-level CloudTrail trail aggregates events from all accounts into a single trail delivery stream directed to the Log Archive account S3 bucket.
3. **Delivery:** CloudTrail delivers log files to the Log Archive S3 bucket within 15 minutes of the API calls occurring; SHA-256 digest files generated hourly.
4. **Storage:** S3 Object Lock (Compliance mode, 12-month retention) applied at bucket level; KMS SSE-KMS encryption applied to every object on write.
5. **Replication:** S3 Cross-Region Replication continuously replicates all log files to the DR bucket in ap-southeast-4 (sub-minute lag under normal conditions).
6. **SIEM Forwarding:** Selected high-risk API call types forwarded in near-real-time to SIEM via EventBridge rule and Lambda transformation function.

**Config Compliance Flow:**
1. **Detection:** AWS Config detects configuration changes across all accounts via continuous recording; periodic snapshots taken every 24 hours.
2. **Evaluation:** Config rules evaluate changed resources against the ISO 27001 conformance pack and internal baseline custom rules within 60 seconds of change detection.
3. **Finding Generation:** Non-compliant evaluations create Config findings, which are ingested into Security Hub as compliance findings with ISO 27001 control mappings applied.
4. **Auto-Remediation:** For defined low-risk deviations (e.g., unencrypted S3 bucket, disabled S3 versioning), a Lambda remediation function is triggered automatically; the remediation action is logged to CloudTrail.
5. **SIEM Escalation:** CRITICAL or HIGH findings that are not auto-remediated trigger SIEM alerts via the EventBridge forwarding pipeline within ≤ 5 minutes.
6. **Evidence Export:** Config compliance snapshots are exported to the Log Archive S3 bucket and included in the compliance evidence package assembled during Phase 3.

**Account Vending Flow:**
1. **Request:** Platform engineer raises an account vending request in the ITSM ticketing platform, providing account details, environment tier, owning team, and cost centre.
2. **Approval Gate:** ITSM workflow routes the request to the designated approver(s); AFT pipeline is blocked until an approved ITSM change record is received.
3. **Pipeline Execution:** Upon approval, the AFT pipeline (Terraform Cloud workspace) provisions the new AWS account within the designated OU via AWS Organizations API.
4. **Baseline Application:** AFT applies the account customisation framework: VPC module deployment, IAM role provisioning, CloudTrail enablement, Config enrollment, Security Hub enrollment, and mandatory resource tagging.
5. **SCP Inheritance:** The new account immediately inherits all SCPs from its parent OU — no additional configuration required; guardrails are active from account creation.
6. **Completion Notification:** AFT updates the ITSM change record with provisioning completion status; the requesting platform engineer receives notification; account is ready for workload deployment.

## Data Migration Strategy

This engagement does not involve application data migration. All governance platform data stores (CloudTrail log archive, Config snapshots, Terraform state) are created fresh during Phase 2. Historical CloudTrail logs from existing accounts prior to Control Tower onboarding are not migrated to the new Log Archive architecture; only forward-looking data collection is in scope. The compliance evidence window begins from the date of Phase 2 go-live.

## Data Governance

The governance platform's data governance model enforces strict controls appropriate to the sensitivity of compliance and audit metadata.

- **Classification:** All platform data is classified as either Internal (operational metrics, CloudWatch logs) or Confidential (CloudTrail events, Config snapshots, Security Hub findings, Terraform state). Data classification tags are applied at the S3 bucket level and enforced via bucket policy.
- **Retention:** CloudTrail and Config logs — 12 months (WORM); CloudWatch Logs — 90 days in-service, extended to 12 months via S3 export; Security Hub findings — retained in Security Hub for 90 days; S3 exports retained for 12 months; Terraform state — indefinite (versioned), with 30-day backup retention via AWS Backup.
- **Quality:** Config rule evaluations and CloudTrail log integrity are validated as part of the compliance evidence pipeline; any gaps in log delivery or evaluation failures generate a CloudWatch alarm and SIEM alert.
- **Access Control:** Log Archive S3 buckets grant write access only to the CloudTrail service principal and Config service principal; no human identity or workload role has write access. Read access is restricted to the Audit account's Security Hub aggregator role, Lambda compliance evidence pipeline role, and the CISO's Security Viewer permission set.

---

# Integration Design

The AWS Cloud Governance Platform integrates with two existing on-premises systems — the SIEM and the ITSM ticketing platform — and federates with the on-premises enterprise directory. These integrations are critical-path items for the engagement: the SIEM integration provides the operational alerting that Contoso Financial's security team depends on, the ITSM integration provides the change governance that satisfies the ISO 27001 change management control, and the IdP federation eliminates shared credentials. All integrations are designed to be unidirectional where possible (AWS pushes to on-premises) to minimise the attack surface of the connectivity.

## External System Integrations

The following table summarises all external system integrations in scope for the governance platform.

<!-- TABLE_CONFIG: widths=[18, 15, 15, 15, 22, 15] -->
| System | Type | Protocol | Format | Error Handling | SLA |
|--------|------|----------|--------|----------------|-----|
| On-Premises SIEM | Near-real-time event push | HTTPS REST (Lambda → SIEM API) | JSON (OCSF / SIEM-native format) | SQS DLQ; Lambda retry with exponential backoff; CloudWatch alarm on DLQ depth | ≤ 5 min finding-to-SIEM delivery |
| On-Premises ITSM | Request/Response (change approval gating) | HTTPS REST (AWS Service Catalog → Lambda → ITSM API) | JSON (ITSM-native ticket format) | Lambda retry on transient failures; AFT pipeline blocked until valid approval received; ITSM timeout → human escalation | ITSM approval polling ≤ 2 min interval |
| On-Premises IdP (SAML 2.0) | Authentication (IAM Identity Center ← IdP) | SAML 2.0 over HTTPS (Direct Connect + VPN) | SAML assertion (XML) | Failed SAML assertion → IAM Identity Center denies session; no fallback credential mode | IdP availability is a dependency; Direct Connect provides resilient path |
| AWS Direct Connect (ap-southeast-2) | Private network connectivity | 1 Gbps hosted connection + MACsec | L2 Ethernet (MACsec encrypted) | Site-to-Site VPN provides resilient backup path for management and federation traffic | Circuit SLA per AWS Direct Connect SLA |
| AWS Direct Connect (ap-southeast-4) | DR private network connectivity | 1 Gbps hosted connection + MACsec | L2 Ethernet (MACsec encrypted) | Site-to-Site VPN backup; DR circuit used during failover drill and regional failover | Circuit SLA per AWS Direct Connect SLA |

## API Design

The governance platform exposes no public-facing APIs. Integration with external systems is achieved through AWS-internal event-driven patterns (EventBridge) and outbound Lambda functions calling external system APIs. The API design for the two outbound integrations is as follows.

- **Style:** REST (outbound calls from Lambda to SIEM and ITSM APIs)
- **Versioning:** Lambda function code is versioned via Git tags; SIEM and ITSM API versions are pinned in Lambda environment variables and updated via controlled deployments
- **Authentication:** SIEM API — Bearer token stored in AWS Secrets Manager, rotated every 90 days. ITSM API — OAuth 2.0 client credentials stored in AWS Secrets Manager, rotated every 90 days.
- **Rate Limiting:** Lambda concurrency reserved at 10 for SIEM forwarding function; 5 for ITSM integration function. CloudWatch alarms alert on throttling events.
- **TLS:** All outbound Lambda calls enforce TLS 1.2 or higher; certificates validated against AWS trust store; certificate pinning not used (to allow for SIEM/ITSM certificate renewals without Lambda redeployment).

### API Endpoints (Outbound Lambda Calls)

The specific API endpoints for the SIEM and ITSM systems are collected during Week 1–2 discovery from the SIEM and ITSM administrators. The following describes the logical integration points; actual endpoint URLs are configured as Secrets Manager entries and Lambda environment variables during Phase 2 development.

<!-- TABLE_CONFIG: widths=[15, 30, 20, 35] -->
| Method | Logical Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | /siem/api/v{n}/events | Bearer token | Submit Security Hub finding or CloudTrail event to SIEM ingest API |
| GET | /itsm/api/v{n}/changes/{change_id} | OAuth 2.0 client credentials | Poll ITSM for change record approval status (AFT pipeline gate) |
| POST | /itsm/api/v{n}/changes/{change_id}/comments | OAuth 2.0 client credentials | Post AFT provisioning completion status back to ITSM change record |

## Authentication & SSO Flows

The identity federation architecture federates Contoso Financial's on-premises enterprise directory into AWS IAM Identity Center via SAML 2.0, providing unified SSO for all AWS console and CLI access.

- **SAML 2.0 Federation:** IAM Identity Center is configured as the SAML Service Provider (SP); the on-premises enterprise directory is the Identity Provider (IdP). SAML assertions are signed by the IdP's signing certificate (pinned in IAM Identity Center during Week 11 configuration).
- **Group Synchronisation:** On-premises directory groups are synchronised to IAM Identity Center groups using SCIM 2.0 (if supported by the on-premises IdP) or via periodic group membership exports. Group-to-permission-set assignments are managed as IaC in the AFT module library.
- **Token Management:** SAML assertions are short-lived (configurable, default 1 hour). AWS STS credentials issued to IAM Identity Center sessions have a maximum duration of 8 hours for Operator roles and 1 hour for BreakGlass. All STS credential creation events are logged to CloudTrail with the originating federated identity.
- **Service-to-Service Authentication:** AFT pipeline, Lambda functions, and Config auto-remediation functions authenticate exclusively via IAM roles with scoped policies. No IAM users or access keys exist for service-to-service calls. Cross-account role assumption follows the hub-and-spoke delegation model with explicit trust policies.
- **Break-Glass Authentication:** The break-glass IAM role in the Management account is the only IAM user/role not managed via IAM Identity Center. It is secured with hardware MFA, its access key is stored in physical escrow, and its use triggers an immediate GuardDuty finding and SIEM alert.

## Messaging & Event Patterns

The event-driven architecture underpins both the SIEM integration and the account vending pipeline. The following event patterns are implemented in the Audit account and Management account respectively.

- **Queue Service (SQS Dead Letter Queues):** SQS DLQs are configured for both the SIEM forwarding Lambda and the ITSM integration Lambda. Messages that fail after 3 retry attempts are moved to the DLQ; a CloudWatch alarm on DLQ depth (threshold: > 0 messages for > 5 minutes) alerts the platform team to integration failures.
- **Event Bus (EventBridge Org Event Bus):** The Audit account's EventBridge org event bus receives Security Hub finding change events from all member accounts. EventBridge rules filter on `detail.findings[*].Severity.Label` for CRITICAL and HIGH findings and route matching events to the SIEM forwarding Lambda.
- **Dead Letter Queue (DLQ) Handling:** Lambda DLQ messages include the full original event payload, the Lambda request ID, and the error message. A separate DLQ processing Lambda (triggered on a schedule) attempts re-delivery during SIEM maintenance windows; if re-delivery fails after 24 hours, a PagerDuty/ITSM alert is raised.
- **Retry Policy:** EventBridge-triggered Lambda invocations use the built-in EventBridge retry policy (2 retries with exponential backoff). Lambda function-level error handling additionally implements an application-level retry with 3 attempts and jitter before placing the message on the DLQ.

---

# Infrastructure & Operations

The infrastructure design for the AWS Cloud Governance Platform is built exclusively on AWS managed services deployed within Australian regions, eliminating the operational overhead of managing underlying compute infrastructure while providing the availability, scalability, and observability required for a compliance-critical production platform. All infrastructure is defined as code and deployed via the GitOps Terraform Cloud pipeline; no manual console configuration is permitted.

## Network Design

The network architecture adopts a hub-and-spoke topology with the Network Account as the centralised hub. All inter-account traffic and all on-premises connectivity transits through this hub, enabling centralised inspection, logging, and policy enforcement at a single choke point.

- **Transit Gateway (ap-southeast-2):** The primary Transit Gateway connects all workload account VPC attachments, the Network Account's inspection VPC, and the Direct Connect Gateway. Route tables enforce explicit allow-lists between account-to-account and account-to-on-premises routing; no default route propagation.
- **Transit Gateway (ap-southeast-4):** A DR Transit Gateway in ap-southeast-4 provides connectivity to the DR Direct Connect circuit and mirrors the primary region's route table configuration. Activated during DR failover drill and regional failover events.
- **VPC CIDR Allocation:** Centrally managed CIDR block allocation prevents address space conflicts as new accounts are vended. Workload account VPCs use /24 allocations from a master /16 RFC 1918 pool maintained in the AFT account customisation configuration. The Network Account's inspection VPC uses a dedicated /24 CIDR.
- **Public Subnets:** Network Account — NAT Gateway for outbound patch management traffic only; no workload public subnets permitted (SCP enforces no Internet Gateway creation in workload accounts).
- **Private Subnets:** All workload resources; Transit Gateway attachments; Systems Manager VPC endpoints.
- **Database Subnets:** Not applicable to the governance platform (no relational databases in scope; DynamoDB is a serverless service with no VPC placement requirement).
- **VPC Endpoints:** Interface VPC endpoints deployed in all workload accounts for S3, SSM, SSM Messages, EC2 Messages, KMS, Secrets Manager, Config, and CloudTrail — ensuring all service API calls remain on the AWS private network and never traverse the public internet.

## Compute Sizing

The governance platform is primarily serverless; the only compute instances are those managed by AWS Systems Manager for platform EC2 instances (if any are required for network appliances or bastion replacements). Lambda functions handle all automation. The following table covers the non-serverless compute components.

<!-- TABLE_CONFIG: widths=[25, 20, 20, 20, 15] -->
| Component | Instance Type | vCPU | Memory | Count |
|-----------|---------------|------|--------|-------|
| Network Firewall (managed) | AWS-managed (no instance selection) | N/A | N/A | 2 AZs (ap-southeast-2) |
| NAT Gateway (managed) | AWS-managed (no instance selection) | N/A | N/A | 1 per AZ (2 in ap-southeast-2) |
| AFT Pipeline Lambda Functions | AWS Lambda (serverless) | Up to 6 vCPU | 3,008 MB (account vending functions) | Auto-scaling; max concurrency 10 |
| SIEM Forwarding Lambda | AWS Lambda (serverless) | Up to 2 vCPU | 1,024 MB | Auto-scaling; reserved concurrency 10 |
| ITSM Integration Lambda | AWS Lambda (serverless) | Up to 2 vCPU | 512 MB | Auto-scaling; reserved concurrency 5 |
| Config Auto-Remediation Lambda | AWS Lambda (serverless) | Up to 2 vCPU | 512 MB | Auto-scaling; max concurrency 20 |
| Platform Instances (if required) | t3.medium (SSM-managed) | 2 | 4 GB | TBD in Phase 1 assessment; 0 if fully serverless |

## High Availability Design

The governance platform is deployed across two Availability Zones in ap-southeast-2 for all components that support multi-AZ configuration. Lambda, EventBridge, S3, DynamoDB, and other serverless services are inherently multi-AZ and require no additional configuration.

- **Transit Gateway:** Natively multi-AZ; attachments to each workload VPC are created in multiple AZs. Automatic failover between AZs is handled by the TGW service with no configuration required.
- **Network Firewall:** Deployed in two AZs (ap-southeast-2a and ap-southeast-2b) with separate Firewall Endpoints per AZ. TGW route tables distribute traffic across both endpoints; automatic failover if one endpoint becomes unavailable.
- **Direct Connect:** Two 1 Gbps hosted connections terminate in ap-southeast-2 and ap-southeast-4 respectively. Site-to-Site VPN provides an automatic failover path for management and federation traffic if the primary Direct Connect circuit becomes unavailable. BFD (Bidirectional Forwarding Detection) is enabled on both BGP sessions for sub-second failover detection.
- **Lambda & Serverless:** All Lambda functions are deployed in the AWS-managed multi-AZ execution environment. DynamoDB tables use on-demand capacity mode with point-in-time recovery enabled; no capacity planning required.
- **S3 Log Archive:** Amazon S3 provides 11-nines durability within ap-southeast-2 through automatic replication across ≥3 AZs. S3 Cross-Region Replication provides an additional copy in ap-southeast-4 within sub-minute lag.

## Disaster Recovery

The DR strategy for the governance platform provides an in-country warm-standby capability in ap-southeast-4 that can be activated to restore governance platform operations within the RTO target.

- **RPO:** < 1 hour — achieved through continuous S3 Cross-Region Replication (sub-minute lag for log data) and AWS Config cross-region aggregation.
- **RTO:** < 4 hours — the DR baseline in ap-southeast-4 (mirrored Control Tower, Config aggregation, Security Hub aggregation, replicated log archive) is pre-deployed and passively maintained. Activation requires executing the documented DR failover runbook, which is estimated at 2–3 hours based on the steps defined in Phase 3. Validated during the Phase 3 DR failover drill.
- **Backup Strategy:** AWS Backup is configured with a daily backup plan covering the AFT DynamoDB workflow table, Terraform state S3 bucket, and all configuration S3 buckets. Backup retention is 30 days. Backups are replicated to ap-southeast-4 by the same AWS Backup plan.
- **DR Site:** ap-southeast-4 (Sydney South) — within Australia, satisfying data sovereignty. The DR baseline includes a mirrored Control Tower registration, S3 Log Archive bucket (replication destination), Config aggregation, Security Hub cross-region aggregation, and a DR Transit Gateway with connections to the DR Direct Connect circuit.
- **DR Activation Criteria:** DR is activated when the primary region (ap-southeast-2) is unavailable or when a governance platform service-level degradation prevents compliance evidence collection for > 30 minutes. The DR failover decision is made by the Platform Admin and documented in the ITSM platform.

## Monitoring & Alerting

The observability design provides the platform team with complete visibility into platform health, guardrail compliance trends, pipeline performance, and security finding volumes. All monitoring is configured via CloudWatch with SNS-based alert routing to the on-call platform engineer.

- **Infrastructure:** Lambda function error rates, Lambda duration (p95), Lambda throttling events, DynamoDB consumed capacity, S3 replication lag (Log Archive → ap-southeast-4), EventBridge rule invocation failures, Direct Connect BGP state changes.
- **Application:** AFT pipeline execution success/failure rates, Config rule evaluation error rates, Security Hub finding ingestion rate, SIEM forwarding pipeline DLQ depth, ITSM integration approval polling latency.
- **Business KPIs:** Number of accounts provisioned per week (AFT pipeline throughput), number of non-compliant Config findings per account per day (compliance trend), number of CRITICAL/HIGH Security Hub findings forwarded to SIEM per day, DR replication lag (RPO trend).
- **Alerting:** CloudWatch metric alarms publish to an SNS topic that routes to the on-call platform engineer's email and (during Phase 3 onboarding) to the existing SIEM for correlation. All P1 alerts (platform outage or compliance evidence collection failure) have a 2-minute evaluation period; P2 alerts use a 5-minute evaluation period.

### Alert Definitions

The following alerts are pre-configured in CloudWatch as part of the Phase 2 deployment. All thresholds are reviewed and tuned during the Phase 3 UAT period based on observed operational baselines.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Alert | Condition | Severity | Response |
|-------|-----------|----------|----------|
| AFT Pipeline Failure | AFT CodePipeline state = FAILED | P1 | On-call platform engineer; investigate pipeline execution logs; raise ITSM incident |
| SIEM Forwarding DLQ Depth | SQS DLQ message count > 0 for > 5 minutes | P1 | Investigate SIEM API availability; check Lambda error logs; retry or escalate to SIEM team |
| Config Evaluation Error Rate | Config rule evaluation errors > 5% in 5-minute window | P2 | Review Config delivery channel health; check IAM role permissions; escalate to Amatra hypercare |
| Security Hub Ingest Gap | No Security Hub findings received for > 4 hours (abnormal for active environment) | P2 | Verify Security Hub delegated admin configuration; check EventBridge rule status |
| Log Archive Replication Lag | S3 CRR replication lag (ap-southeast-4) > 1 hour | P1 | Check S3 CRR configuration; validate IAM replication role; raise ITSM incident; RPO at risk |
| Direct Connect BGP State | BGP session state change (up→down) on either circuit | P1 | Check physical circuit; activate VPN backup path; notify network team; raise ITSM incident |
| BreakGlass Role Assumption | CloudTrail event `AssumeRole` for BreakGlass role | P1 (Immediate) | SIEM alert + SNS notification to CISO and Platform Admin; begin break-glass audit log review |
| CloudTrail Log Delivery Gap | No CloudTrail log file delivered to Log Archive S3 for > 30 minutes | P1 | Verify org CloudTrail configuration; check S3 bucket policy; RPO / evidence continuity at risk |
| GuardDuty Detector Disabled | GuardDuty `DeleteDetector` or `DisableOrganizationAdminAccount` CloudTrail event | P1 (Immediate) | SCP should prevent this; investigate if event occurs; SIEM alert; CISO notification |

## Logging & Observability

The platform's observability stack combines CloudWatch for real-time metrics and log aggregation, X-Ray for Lambda function tracing, and CloudTrail for the compliance audit trail.

- **Log Aggregation:** All Lambda function logs are written to CloudWatch Logs with structured JSON format. AFT pipeline logs are captured in AWS CodePipeline execution history and CloudWatch Logs. Network Firewall alert logs are written to CloudWatch Logs and exported to the Log Archive S3 bucket.
- **Distributed Tracing:** AWS X-Ray is enabled for the SIEM forwarding Lambda and ITSM integration Lambda functions, providing end-to-end latency tracing for the critical event delivery paths. X-Ray service maps are available in the CloudWatch console.
- **Dashboards:** Three CloudWatch dashboards are deployed as IaC: (1) Platform Operations Dashboard — AFT pipeline health, Config compliance trend, Security Hub finding volumes; (2) Identity & Access Dashboard — IAM Identity Center login events, permission set assignments, break-glass usage; (3) DR & Replication Dashboard — S3 CRR lag, Direct Connect BGP state, DR region Config aggregation health.
- **Log Exports to S3:** CloudWatch Logs export tasks are scheduled nightly to export all platform log groups to the Log Archive S3 bucket, extending in-service 90-day retention to 12 months for compliance purposes.

## Cost Model

The following cost model reflects the infrastructure costs documented in the SOW Investment Summary and `infrastructure-costs.csv`. All figures are in Australian Dollars (AUD) and represent the annual run rate post-implementation. Year 1 costs are net of applicable AWS MAP credits and partner credits as detailed in the SOW.

<!-- TABLE_CONFIG: widths=[30, 25, 25, 20] -->
| Category | Annual Estimate (List) | Optimisation Applied | Year 1 Net |
|----------|------------------------|----------------------|------------|
| Cloud Services (AWS) | $9,956 | AWS MAP Credit ($15K), Activate Credit ($5K), RI Savings ($8K) | ($18,044) credit balance |
| Software Licences (Terraform Cloud Plus + Datadog) | $4,056 | Terraform Partner Credit ($1,200) | $2,856 |
| Connectivity (Direct Connect ×2 + VPN) | $5,718 | No credits available | $5,718 |
| AWS Business Support | $14,400 | No credits available | $14,400 |
| **Annual Run Rate (Post-Year-1)** | **$34,130** | Credits expire after Year 1 | **$34,130** |

**Key cost optimisation decisions:**
- Serverless-first architecture (Lambda, DynamoDB on-demand, EventBridge) eliminates idle compute costs; cost scales with actual usage rather than provisioned capacity.
- AWS Config billing is per-rule-evaluation; the ~80-rule conformance pack at ~1,000 evaluations/month per account (8 accounts) produces a manageable Config bill (~$960/year).
- S3 Intelligent-Tiering is not applied to the Log Archive bucket; Object Lock (Compliance mode) is incompatible with Intelligent-Tiering. Standard storage at ~500 GB/month is the appropriate and compliant choice.
- DR region (ap-southeast-4) costs represent the largest single line item ($4,800/year); this cost is non-negotiable given data sovereignty and RTO requirements.

---

# Implementation Approach

The implementation of the AWS Cloud Governance Platform follows a structured three-phase approach over 16 weeks, designed to protect Contoso Financial's April 2026 regulatory deadline while managing the risks inherent in deploying governance controls to an environment with active production workloads. Each phase builds on the previous, with formal sign-off gates ensuring CISO and platform team acceptance before production controls are applied.

## Migration/Deployment Strategy

The governance platform is a greenfield implementation from a platform perspective (no existing Control Tower or AFT to migrate from), but the production environment onboarding in Phase 2 involves applying guardrails to accounts that host live workloads. The deployment strategy is designed to minimise production risk while meeting the April 2026 deadline.

- **Approach:** Foundation-first — governance infrastructure (Control Tower, AFT, guardrails, identity federation) is deployed and validated in isolation before any production workloads are onboarded. Production onboarding is staged across three separate ITSM change windows in Week 15.
- **Pattern:** Phased rollout with staged production onboarding (one environment per change window). No big-bang cutover for production.
- **Validation:** Each phase has formal exit criteria (defined below). Phase 2 exit requires full platform deployment and integration validation. Phase 3 exit requires CISO sign-off on all controls, successful DR drill, and UAT completion.
- **Rollback:** Defined rollback procedure for each production environment cutover. SCP console-access deny can be removed via break-glass within 30 minutes if a production-impacting issue is detected during the 2-hour post-cutover monitoring window.

## Sequencing & Wave Planning

The following table defines the implementation phases, activities, duration, and exit criteria. These phases map directly to the SOW deliverables and milestone schedule.

<!-- TABLE_CONFIG: widths=[8, 32, 15, 45] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 — Discovery & Design | Current-state assessment; AWS Control Tower / Organizations readiness; ISO 27001 control mapping; IdP, SIEM, ITSM integration assessment; gap analysis; full architecture design; CISO review package | Weeks 1–6 | Discovery & Assessment Report accepted by Priya Nair; Architecture Design Document signed off by CISO (M3 gate) |
| 2a — Landing Zone & Identity | AWS Control Tower deployment (ap-southeast-2); OU hierarchy; Log Archive, Audit, Security, Network, Management accounts; IAM Identity Center federation with on-premises IdP; permission sets deployed | Weeks 7–11 | Control Tower deployed (M4); IAM Identity Center federation live; zero shared credentials in new accounts (M6) |
| 2b — Guardrails & Integrations | SCP deployment across all OUs; Config conformance packs (ISO 27001 + internal baseline); auto-remediation Lambda functions; Security Hub + GuardDuty org configuration; SIEM integration; ITSM integration; AFT pipeline with ITSM change-approval; CI/CD GitOps pipeline | Weeks 8–12 | Guardrails enforced (M5); SIEM integration validated; ITSM workflow integrated; AFT pipeline operational |
| 2c — Network & DR | Transit Gateway (ap-southeast-2); Network Firewall; Direct Connect + VPN termination; DR baseline (ap-southeast-4); S3 CRR; Config and Security Hub cross-region; AWS Backup; production environment onboarding (3 environments via AFT) | Weeks 10–12 | Network infrastructure deployed; DR baseline active; all 3 production environments onboarded (M7) |
| 3 — Testing & Validation | Test plan execution: account vending, guardrail enforcement, identity federation, SIEM integration, DR failover drill, UAT with platform team; ISO 27001 evidence package compilation and CISO validation; runbook delivery; knowledge transfer; project closeout | Weeks 13–16 | All test cases passed; DR drill RTO/RPO met; CISO sign-off obtained (M8); platform go-live (M9); hypercare commenced |

## Tooling & Automation

Every category of platform work uses a defined tool, ensuring consistency, auditability, and the ability to reproduce the platform configuration from code.

<!-- TABLE_CONFIG: widths=[28, 32, 40] -->
| Category | Tool | Purpose |
|----------|------|---------|
| Landing Zone & Multi-Account | AWS Control Tower, AWS Organizations | OU hierarchy, guardrail inheritance, account structure management |
| Infrastructure as Code | Terraform (AFT), Terraform Cloud Plus (10 workspaces) | Account vending, VPC modules, IAM roles, all platform infrastructure |
| Policy as Code | Terraform Sentinel, AWS Config Conformance Packs, SCPs | IaC pull request policy checks; continuous compliance monitoring; preventive guardrails |
| Secret Management | AWS Secrets Manager | ITSM/SIEM API credentials, SAML signing certificates, break-glass credentials |
| CI/CD Pipeline | Terraform Cloud (VCS-backed workspaces), AWS CodePipeline (AFT) | GitOps IaC deployment pipeline; AFT account vending orchestration |
| Configuration Management | AWS Systems Manager (Fleet Manager, Patch Manager, Session Manager) | No-console-access enforcement; patch management; no-SSH/RDP access to platform instances |
| Monitoring & Alerting | Amazon CloudWatch (metrics, alarms, dashboards, logs), AWS X-Ray | Platform health monitoring; alert routing; distributed tracing for integration functions |
| Security Monitoring | AWS Security Hub, Amazon GuardDuty, AWS Access Analyzer | Compliance posture; threat detection; IAM policy analysis |
| Audit Logging | AWS CloudTrail (org trail), Amazon S3 (Object Lock) | Immutable audit trail; compliance evidence collection |
| SIEM Integration | Amazon EventBridge, AWS Lambda, Amazon SQS (DLQ) | Near-real-time Security Hub finding and CloudTrail event forwarding to on-premises SIEM |
| ITSM Integration | AWS Service Catalog, AWS Lambda, Amazon SQS | ITSM change-approval gating for account vending requests |
| Identity | AWS IAM Identity Center, on-premises IdP (SAML 2.0), SCIM | Federated SSO; permission sets; group synchronisation |
| DR & Backup | AWS Backup, S3 Cross-Region Replication | Platform state protection; in-country DR replica maintenance |
| Version Control | Git (VCS-backed Terraform Cloud workspaces) | Source of truth for all IaC; pull request workflow with Sentinel policy checks |

## Cutover Approach

Production go-live is executed as a staged cutover across three production environments in Week 15, with each environment onboarded in a separate ITSM-approved change window on consecutive days. This staged approach allows the platform team and CISO to validate each cutover before proceeding to the next.

- **Type:** Staged (one environment per day, Days 1–3 of Week 15)
- **Duration:** 2-hour post-cutover monitoring window per environment before proceeding to the next
- **Validation:** Per-environment validation checklist (SCPs active, Security Hub enrolled, CloudTrail delivering, SIEM alert validated, no workload service disruption detected in 2-hour window)
- **Decision Point:** Go/no-go for each successive environment is made by Priya Nair (Platform Lead) in consultation with the CISO after each 2-hour monitoring window. Any rollback or pause is communicated to James Wu within 30 minutes of the decision.

## Downtime Expectations

- **Planned Downtime:** Zero planned downtime for existing workloads during production onboarding. The AFT baseline application (IAM roles, Config enrollment, Security Hub enrollment, tagging) is non-destructive to existing workload resources. SCP enforcement (the only potentially breaking change) is applied at the OU level after workload validation confirms no legitimate console access patterns are in use.
- **Unplanned Downtime:** Governance platform MTTR target: < 2 hours (within hypercare period, with Amatra P1 response SLA of 2 hours). Post-hypercare, MTTR is dependent on the platform team's operational capability (knowledge transfer sessions are designed to achieve self-sufficiency).
- **Mitigation:** AFT baseline application is idempotent — if interrupted, the pipeline can be re-run without harm. SCP rollback (console-access deny removal) takes < 30 minutes via break-glass procedure, providing a fast recovery path if a workload issue is detected post-cutover.

## Rollback Strategy

A documented rollback plan is in place for every production cutover and for the overall governance platform if a critical issue is identified during Phase 3 testing.

- **SCP Rollback:** Remove the console-access deny SCP from the affected production OU via the break-glass procedure in the Management account. Time to restore pre-cutover access model: < 30 minutes. This is the primary rollback action for any production-impacting issue detected during the 2-hour monitoring window.
- **AFT Baseline Rollback:** AFT-applied resources (IAM roles, Config rules, Security Hub enrollment) are not destructive and can be left in place during rollback without impacting workloads. If removal is required, Terraform destroy is run against the baseline workspace for the affected account — estimated time: < 1 hour.
- **Infrastructure Rollback:** All Terraform-managed infrastructure has versioned state in S3 with state file history. Any infrastructure change can be reverted by running `terraform apply` against a prior state version — all state changes are tracked in the Git repository for full auditability.
- **Database Rollback:** DynamoDB AFT workflow table is protected by AWS Backup (daily snapshots, 30-day retention) and point-in-time recovery. If the workflow state table is corrupted, restore to the last clean point-in-time takes < 15 minutes.
- **Maximum Rollback Window:** Any rollback decision must be made within the 2-hour post-cutover monitoring window for each production environment. A rollback called after this window requires an ITSM change record and CISO approval.

---

# Appendices

This section provides supporting reference material for the AWS Cloud Governance Platform design, including architecture diagram references, naming and tagging standards, the risk register, and the project glossary. All tables and standards in this section are implemented as IaC in the Terraform module library and enforced via AFT account customisations and Sentinel policies.

## Architecture Diagrams

The following diagrams support the technical design documented in this document. The primary architecture diagram is embedded in Section 4 (Solution Architecture) and is the canonical reference for the component and network topology.

- **Solution Architecture Diagram** — Embedded in Section 4; see `../../assets/diagrams/architecture-diagram.png`. Full multi-account landing zone with Control Tower, AFT account vending, SCP/Config guardrails, IAM Identity Center federation, hub-and-spoke Transit Gateway network, centralised security monitoring, and dual-region deployment.
- **Network Topology Diagram** — Hub-and-spoke Transit Gateway topology showing VPC attachments for all accounts, Network Firewall placement, Direct Connect termination, and VPN backup path. Produced as Deliverable #5 (Architecture Design Document).
- **Data Flow Diagram** — End-to-end data flows for CloudTrail audit, Config compliance, SIEM forwarding, and account vending pipelines. Produced as Deliverable #5.
- **Security Architecture Diagram** — SCP inheritance hierarchy across OU structure; IAM Identity Center federation topology; permission set scope by account tier. Produced as Deliverable #5.
- **IAM Identity Center Federation Topology** — SAML 2.0 federation flow from on-premises IdP through IAM Identity Center to permission set assignment; group synchronisation via SCIM. Produced as Deliverable #10 documentation.

## Naming Conventions

All AWS resources provisioned by the AFT pipeline and Terraform modules follow the naming convention below. Naming conventions are enforced via Terraform Sentinel policies that reject any `terraform plan` that creates a resource with a non-compliant name. The convention is designed to provide immediate context on the resource's environment, account, and purpose from its name alone.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Resource Type | Pattern | Example |
|---------------|---------|---------|
| AWS Account | `{client-short}-{env}-{workload}` | `cntso-prod-payments` |
| S3 Bucket | `{client-short}-{account-type}-{purpose}-{region}` | `cntso-log-archive-cloudtrail-apse2` |
| IAM Role | `{purpose}-role-{account-type}` | `aft-pipeline-role-management` |
| Lambda Function | `{client-short}-{purpose}-{trigger}` | `cntso-siem-forward-eventbridge` |
| DynamoDB Table | `{client-short}-{purpose}-{env}` | `cntso-aft-workflow-prod` |
| KMS Key (alias) | `alias/{client-short}-{purpose}-{region}` | `alias/cntso-log-archive-apse2` |
| CloudWatch Log Group | `/aws/{service}/{client-short}/{purpose}` | `/aws/lambda/cntso/siem-forward` |
| Terraform Workspace | `{client-short}-{account-type}-{module}` | `cntso-management-aft` |
| SCP | `{client-short}-{control-type}-{scope}` | `cntso-deny-console-access-prod` |
| Config Conformance Pack | `{client-short}-{framework}-{scope}` | `cntso-iso27001-org` |
| Security Hub Standard | `{client-short}-{standard}-{version}` | `cntso-internal-baseline-v1` |
| Transit Gateway | `{client-short}-tgw-{region}` | `cntso-tgw-apse2` |
| VPC | `{client-short}-{account-type}-vpc-{region}` | `cntso-network-vpc-apse2` |

## Tagging Standards

Mandatory resource tags are applied to every AWS resource provisioned by the AFT pipeline and Terraform modules. Tagging compliance is enforced via a Config custom rule that marks any resource missing a mandatory tag as NON_COMPLIANT, triggering a Security Hub finding and optional auto-remediation. Tag values are validated against allowed lists where applicable (e.g., Environment must be one of `dev`, `test`, `staging`, `prod`, `platform`).

<!-- TABLE_CONFIG: widths=[25, 15, 60] -->
| Tag | Required | Example Values / Notes |
|-----|----------|------------------------|
| Environment | Yes | `dev`, `test`, `staging`, `prod`, `platform` — enforced against allowed list via Config rule |
| Application | Yes | `governance-platform`, `aft-pipeline`, `siem-integration`, `workload-{name}` |
| Owner | Yes | Team name or email alias (e.g., `platform-engineering`, `security-ops`) |
| CostCentre | Yes | Contoso Financial cost centre code (provided in AFT account request form) |
| DataClassification | Yes | `internal`, `confidential` — determines backup and access control policies |
| Compliance | Yes | `iso27001` for all platform resources; `internal-baseline` for custom-rule-governed resources |
| Project | Yes | `aws-governance-platform` for all resources in this engagement |
| ManagedBy | Yes | `terraform` — signals to operators that manual changes will be overwritten |
| BackupPolicy | Recommended | `daily-30d` (standard), `none` (ephemeral resources) |
| CreatedDate | Recommended | ISO 8601 date (applied by AFT pipeline at account creation) |

## Risk Register

The following risk register identifies the key risks to the successful delivery of the governance platform, their likelihood, impact, and mitigation approach. Risks are managed via the project RAID log (Deliverable #1) and reviewed at each milestone gate with Rachel Moore and James Wu.

<!-- TABLE_CONFIG: widths=[28, 14, 14, 44] -->
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| CISO sign-off delayed beyond Week 6 — Phase 2 cannot commence without architecture approval | Medium | Critical | CISO review session scheduled in Week 5 with architecture package delivered by Week 5; architecture design workshops include CISO security representative from Week 1 to surface issues early |
| AWS Direct Connect circuits not provisioned by start of Phase 2 (Week 7) — network hub-spoke deployment blocked | Medium | High | Amatra to follow up with Contoso Financial procurement weekly from Week 1; interim Site-to-Site VPN path used for management and federation traffic until Direct Connect is available; circuit provisioning is a Phase 2 gate dependency |
| On-premises IdP team unavailable for federation workshop (Week 3) or configuration sessions (Week 11) | Medium | High | Federation workshop rescheduled within the same week if unavoidable conflict arises; IdP team availability confirmed in advance as a RAID log dependency item; SAML 2.0 federation design can be completed by Amatra without IdP team if SAML metadata document is provided |
| SCP enforcement causes unintended workload disruption during production onboarding | Low | Critical | All SCPs tested in non-production accounts for minimum 2 weeks before production application; staged cutover (one environment per day) with 2-hour monitoring window and 30-minute rollback capability; pre-onboarding IAM activity review identifies any console-access patterns that must be migrated before SCP enforcement |
| SIEM API integration complexity underestimated — SIEM vendor API undocumented or rate-limited | Medium | Medium | SIEM API assessment conducted in Week 2 with SIEM administrator; fallback pattern is S3-based log delivery (SIEM consumes from S3) if REST API integration proves infeasible; S3 delivery adds latency but does not compromise compliance evidence continuity |
| April 2026 regulatory deadline missed due to project delay | Low | Critical | 16-week timeline includes 0 float on the Phase 1–Phase 2 gate; any delay in Phase 1 (Discovery) is escalated immediately to Rachel Moore and James Wu; the compliance evidence collection period begins in Phase 2 (Week 7), giving 6 months of continuous evidence before the April deadline |
| Terraform Cloud Plus licence procurement delayed — AFT pipeline blocked | Low | High | Licence procurement initiated at SOW execution (Week 0); Terraform Cloud Plus is available on-demand via HashiCorp website; Amatra manages procurement on Contoso Financial's behalf under the engagement; free tier is sufficient for initial Phase 1 design work |
| AWS MAP credits not approved in time for Phase 2 billing — cost impact in Year 1 | Low | Medium | MAP enrolment initiated by Amatra with the AWS APAC account team at SOW execution; MAP approval timeline is typically 2–3 weeks; credits are applied retroactively to the billing account if approved during Phase 2 |
| Config auto-remediation inadvertently modifies production workload resources | Low | High | Auto-remediation Lambda functions are scoped to governance platform resources only (not workload resources) via IAM role policies; Config rule auto-remediation is disabled for production accounts during initial Phase 2 deployment and enabled only after 2-week observation period with no false positives |
| Break-glass procedure abused or accessed without CISO approval | Very Low | Critical | Break-glass access key stored in physical escrow with dual-person control; use generates immediate GuardDuty finding and SIEM alert; CloudTrail captures all actions during break-glass session; access key rotated after every use; quarterly break-glass procedure review conducted by CISO |

## Glossary

The following terms and acronyms are used throughout this document. Definitions are aligned to AWS documentation and the ISO 27001:2022 standard.

<!-- TABLE_CONFIG: widths=[22, 78] -->
| Term | Definition |
|------|------------|
| AFT | Account Factory for Terraform — the AWS-native IaC-based account vending solution for AWS Control Tower, providing automated account provisioning with customisation hooks |
| API | Application Programming Interface — a defined interface for software-to-software communication |
| CISO | Chief Information Security Officer — Contoso Financial's security governance authority for this engagement |
| CMK | Customer Managed Key — an AWS KMS key created and managed by the customer (as opposed to AWS-managed keys) |
| Config | AWS Config — an AWS service that provides continuous monitoring and recording of AWS resource configurations and their compliance against defined rules |
| Control Tower | AWS Control Tower — the AWS landing zone and multi-account management service; provides OU structure, guardrails, and Account Factory |
| CRR | Cross-Region Replication — the Amazon S3 capability that automatically replicates objects from a source bucket in one AWS region to a destination bucket in another region |
| DLQ | Dead Letter Queue — an Amazon SQS queue that receives messages that could not be successfully processed by a consumer after the maximum number of retries |
| DR | Disaster Recovery — the capability to restore normal operations after a disruptive event, governed by RTO and RPO targets |
| EventBridge | Amazon EventBridge — a serverless event bus service that enables event-driven architectures by routing events from AWS services to target resources |
| GuardDuty | Amazon GuardDuty — an AWS threat detection service that uses machine learning and threat intelligence to identify malicious activity across AWS accounts |
| IAM | Identity and Access Management — the AWS service that controls who (identity) can do what (access) on which AWS resources |
| IAM Identity Center | AWS IAM Identity Center (formerly AWS SSO) — the AWS service that provides centralised identity federation, SSO, and permission set management across multiple AWS accounts |
| IdP | Identity Provider — the on-premises enterprise directory (LDAP/AD) that is the authoritative identity source for Contoso Financial users |
| ISO 27001 | ISO/IEC 27001:2022 — the international standard for Information Security Management Systems (ISMS); the primary compliance framework for this engagement |
| ITSM | IT Service Management — the on-premises ticketing and change management platform used by Contoso Financial for change-approval workflow |
| KMS | AWS Key Management Service — the AWS managed service for creating and managing cryptographic keys used for data encryption |
| Lambda | AWS Lambda — a serverless compute service that runs code in response to events without requiring server management |
| MACsec | IEEE 802.1AE Media Access Control Security — a Layer 2 encryption standard used on AWS Direct Connect connections to protect data in transit |
| MFA | Multi-Factor Authentication — a security control requiring users to present two or more verification factors before gaining access |
| OU | Organizational Unit — a logical container within AWS Organizations used to group accounts and apply SCPs through inheritance |
| PII | Personally Identifiable Information — data that can be used to identify an individual; no PII is in scope for the governance platform data architecture |
| RPO | Recovery Point Objective — the maximum acceptable data loss measured in time; set at < 1 hour for this engagement |
| RTO | Recovery Time Objective — the maximum acceptable time to restore a system to operational state after a failure; set at < 4 hours for this engagement |
| SAML 2.0 | Security Assertion Markup Language 2.0 — an XML-based open standard for exchanging authentication and authorisation data between an identity provider and a service provider |
| SCIM | System for Cross-domain Identity Management — an open standard protocol for automating the exchange of user identity information between identity providers and service providers |
| SCP | Service Control Policy — an AWS Organizations policy that specifies the maximum permissions for accounts in an OU; overrides all account-level IAM policies |
| Security Hub | AWS Security Hub — an AWS service that aggregates, organises, and prioritises security findings from multiple AWS security services and third-party products |
| SIEM | Security Information and Event Management — the on-premises system used by Contoso Financial for security event correlation, alerting, and incident management |
| SOW | Statement of Work — the contractual document defining the scope, deliverables, timeline, and commercial terms for this engagement |
| SQS | Amazon Simple Queue Service — a fully managed message queuing service used for decoupling and buffering between components |
| SSO | Single Sign-On — the capability for users to authenticate once and access multiple applications without re-entering credentials |
| TGW | Transit Gateway — AWS Transit Gateway, a network transit hub connecting VPCs and on-premises networks through a centralised routing architecture |
| TLS | Transport Layer Security — a cryptographic protocol providing encrypted communications over a network; TLS 1.2 or higher required for all platform communications |
| VPC | Virtual Private Cloud — a logically isolated network within the AWS cloud in which AWS resources are launched |
| WORM | Write Once Read Many — a data storage model in which data, once written, cannot be modified or deleted; implemented via Amazon S3 Object Lock (Compliance mode) in this platform |
