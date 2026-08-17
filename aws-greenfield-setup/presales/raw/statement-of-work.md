---
document_title: Statement of Work
technology_provider: aws
project_name: AWS Multi-Account Landing Zone
client_name: Anonymous — Insurance Vendor
client_contact: TBD | TBD | TBD
consulting_company: Amatra
consultant_contact: TBD | TBD | TBD
opportunity_no: OPP-2024-001
document_date: January 2025
version: 1.0
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Statement of Work (SOW) defines the scope, deliverables, roles, and commercial terms for the design, implementation, and handover of a greenfield **AWS Multi-Account Landing Zone** for an insurance vendor operating in the United States. This engagement will deliver a production-ready, multi-region AWS foundation built on AWS Control Tower, enabling the client to onboard workloads with consistent security guardrails, automated account provisioning, and full infrastructure-as-code coverage from day one.

The landing zone will span two AWS regions — us-east-1 (primary) and us-east-2 (secondary/DR) — and will be underpinned by a seven-OU organisational hierarchy, hub-and-spoke networking via AWS Transit Gateway, and an Account Factory for Terraform (AFT) pipeline capable of vending new accounts in under 30 minutes. The engagement is structured over three months (12 weeks) across three sequential delivery phases: Foundation & Governance, Networking & Connectivity, and Security, Automation & Handover.

**Project Duration:** 3 months (12 weeks)

**Key Outcomes:**
- Fully operational AWS Control Tower deployment governing both us-east-1 and us-east-2
- Seven-OU hierarchy (Security, Infrastructure, Workloads-Prod, Workloads-NonProd, Sandbox, Suspended) designed to accommodate future business units and acquisitions
- Hub-and-spoke Transit Gateway network with centralised Network Firewall, NAT Gateway egress, VPC IPAM, and initial Site-to-Site VPN to on-premises
- AFT pipeline enabling self-service account vending with mandatory guardrail enrolment in under 30 minutes
- Security Hub (FSBP standard), GuardDuty, Config rules, and CloudTrail org trail operational in both regions
- At least two workload accounts (one Production, one Non-Production) vended and validated by go-live
- ≥95% infrastructure-as-code coverage; zero manual console changes in production at launch
- Full operational handover: runbooks, as-built documentation, administrator training, and 4-week hypercare support

**Expected Benefits:**
- **Security Posture:** Zero critical Security Hub findings in production at launch; all accounts protected by SCPs and guardrails from day one
- **Operational Efficiency:** Account provisioning reduced from weeks of manual effort to under 30 minutes via the AFT pipeline
- **Scalability:** OU structure and Terraform modules enable new business units and acquisitions to onboard without re-architecture
- **Cost Governance:** AWS Cost Explorer and per-account Budgets active from go-live; Savings Plans evaluation planned at the 3-month post-go-live review
- **Compliance Readiness:** AWS Foundational Security Best Practices (FSBP) enforced at launch; additional frameworks (NIST 800-53, SOC 2, HIPAA) confirmed and activated during Phase 1

---

# Background & Objectives

This engagement represents a net-new cloud adoption initiative. The client is an insurance vendor with no existing AWS accounts, cloud infrastructure, or cloud-native tooling. Recognising the strategic importance of cloud adoption, the client has committed to building a secure, scalable AWS foundation designed to support future workload development, migrations, and long-term growth — without incurring the costly re-architecture that frequently results from ad-hoc AWS adoption.

## Current State

The client is entering the AWS ecosystem from a fully on-premises starting point. The absence of any prior cloud footprint means there are no legacy accounts, misconfigured resources, or technical debt to remediate; however, it also means that all foundational capabilities — governance, identity, networking, security, and automation — must be built and validated from scratch. Key challenges that this engagement must address include:

- **No Cloud Governance:** Without a structured multi-account framework and Control Tower, individual teams risk creating isolated AWS accounts with inconsistent security configurations, producing a fragmented and ungovernable estate as the organisation scales.
- **Manual and Slow Account Provisioning:** Traditional account creation approaches require multi-week manual effort and human intervention for each new team or project, creating friction that impedes cloud adoption at scale.
- **Absence of Centralised Security Visibility:** With no AWS security tooling in place, the client currently has no mechanism for threat detection, compliance monitoring, or centralised audit logging. This gap must be closed before any workloads are deployed.
- **No Networking Foundation:** Hub-and-spoke connectivity, IP address management, and centralised egress controls do not yet exist. Without these, individual application teams would be forced to design and manage networking independently, leading to IP conflicts and uncontrolled traffic flows.
- **No Infrastructure-as-Code Practice:** There is no existing IaC tooling, repository structure, or CI/CD pipeline. All infrastructure automation capabilities must be established as part of this engagement.
- **Compliance Framework Unclear:** The applicable compliance framework(s) beyond AWS Foundational Security Best Practices have not yet been confirmed. This creates risk for regulated insurance operations and must be resolved during Phase 1 discovery.

## Business Objectives

The following strategic objectives define what this project must achieve and how success will be measured. Each objective is directly connected to the client's growth strategy and the business outcomes they need from their cloud foundation.

- **Establish a Governed, Multi-Account AWS Foundation:** Deploy AWS Control Tower with a seven-OU hierarchy that enforces consistent security guardrails, policy controls, and logging across every AWS account from the moment it is provisioned.
- **Eliminate Manual Account Provisioning:** Deliver an Account Factory for Terraform (AFT) pipeline that reduces new AWS account provisioning time to under 30 minutes, with no manual console intervention required.
- **Enable Multi-Region Resilience:** Govern both us-east-1 and us-east-2 under the same Control Tower landing zone, ensuring all security controls, logging, and compliance checks apply equally in both regions.
- **Build a Scalable Networking Foundation:** Deploy a hub-and-spoke Transit Gateway topology with centralised network inspection and egress, capable of supporting future workloads, additional VPCs, and Direct Connect upgrade without redesign.
- **Achieve Measurable Security Compliance at Launch:** Attain zero critical Security Hub findings in the production environment at go-live, with all accounts enrolled in the FSBP conformance standard.
- **Codify All Infrastructure as Code:** Achieve ≥95% IaC coverage using Terraform and AFT, with a CI/CD pipeline that enforces code review and automated deployment gates on all infrastructure changes.

## Success Metrics

The following measurable criteria define what a successful engagement outcome looks like. Each metric is specific, verifiable, and will be validated formally during the testing and UAT phases before go-live is confirmed.

- 100% of AWS accounts enrolled in Control Tower guardrails at go-live
- New AWS account provisioning time < 30 minutes via the AFT pipeline (validated by three consecutive test runs)
- Zero critical Security Hub findings in production accounts at launch
- IaC coverage ≥ 95% — no manual console changes in production at go-live (confirmed via drift detection)
- Landing zone fully operational with at least two workload accounts vended by end of Month 3
- AWS Config recording active in all accounts across both regions at go-live
- CloudTrail organisation trail capturing all management events in both regions at go-live
- SNS budget alerts active for all accounts at 80% and 100% spend thresholds

---

# Scope of Work

This engagement delivers a complete greenfield AWS Multi-Account Landing Zone for an insurance vendor across us-east-1 and us-east-2. The following scope definition establishes the boundaries of this Statement of Work, including all in-scope services and deliverables, explicit exclusions, and the phased activity plan that governs delivery across 12 weeks.

## In Scope

The following services and deliverables are included in this SOW:

- AWS Control Tower deployment with multi-region governance (us-east-1 and us-east-2)
- AWS Organizations configuration with a seven-OU hierarchy (Root, Security, Infrastructure, Workloads-Prod, Workloads-NonProd, Sandbox, Suspended)
- Service Control Policies (SCPs) and Resource Control Policies (RCPs) for governance and data perimeter enforcement
- AWS IAM Identity Center (SSO) configuration with permission sets and identity source integration
- Centralised logging infrastructure (Log Archive and Audit accounts) with CloudTrail organisation trail
- AWS Config deployment in both regions across all accounts with conformance packs aligned to FSBP
- Transit Gateway hub-and-spoke network topology in us-east-1 and us-east-2 with inter-region peering
- AWS Network Firewall for north-south and east-west traffic inspection in both regions
- VPC IPAM for centralised IP address management across all accounts and regions
- Hub VPCs with centralised NAT Gateway egress and Site-to-Site VPN to on-premises
- Spoke VPC Terraform modules with /20 address blocks per spoke
- Account Factory for Terraform (AFT) pipeline for automated account vending
- AWS Security Hub (FSBP standard) aggregated to Audit account across both regions
- Amazon GuardDuty enabled organisation-wide in both regions with delegated administrator
- CloudTrail Lake configuration for security investigation query capabilities
- Tagging policy enforcement via AWS Organizations with five mandatory tags
- AWS Cost Explorer and per-account AWS Budgets with 80% and 100% spend alerts
- Centralised CloudWatch monitoring dashboards in the Shared Services account with SNS alerting
- Terraform modules and CI/CD pipeline for infrastructure deployment and change management
- Operational runbooks, as-built documentation, administrator training, and 4-week hypercare support

### Scope Parameters

This engagement is sized as a **Medium** implementation based on the parameters below. The following table defines the key parameters that bound the scope of this engagement:

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | AWS Accounts | Greenfield — net-new; target 7–12 accounts at go-live |
| Solution Scope | Deployment Regions | 2 regions: us-east-1 (primary), us-east-2 (DR) |
| Solution Scope | OU Structure | 7-OU hierarchy (Root, Security, Infrastructure, Workloads-Prod, Workloads-NonProd, Sandbox, Suspended) |
| Solution Scope | Control Tower Guardrails | SCPs + RCPs (root deny, region restriction, MFA, CloudTrail lock, data perimeter) |
| Integration | On-Premises Connectivity | Site-to-Site VPN initial build (Direct Connect upgrade path documented) |
| Integration | Identity Source | IAM Identity Center (identity source to be confirmed at kick-off) |
| Integration | Monitoring Integrations | CloudWatch, Security Hub, SNS alerting (third-party SIEM: out of scope) |
| User Base | AWS Users | ≤50 users in IAM Identity Center (no-charge tier) |
| Data Volume | CloudTrail Events | ~100M events/month (organisation trail, both regions) |
| Data Volume | Log Storage | ~500 GB/month (S3 Log Archive; Glacier long-term retention) |
| Technical Environment | Networking Complexity | Hub-and-spoke TGW; Network Firewall; IPAM; /20 per spoke VPC |
| Technical Environment | IaC Coverage | ≥95% Terraform + AFT; CI/CD pipeline required |
| Security & Compliance | Frameworks | AWS FSBP (mandatory); NIST 800-53 / SOC 2 / HIPAA (to be confirmed in Phase 1) |
| Performance | Account Vending SLA | < 30 minutes via AFT pipeline (validated in testing phase) |

Table: Engagement Scope Parameters

*Note: Changes to these parameters — such as additional regions, higher event volumes, Direct Connect, third-party SIEM integration, or additional compliance frameworks — may require scope adjustment and additional investment via change control.*

## Out of Scope

The following items are explicitly excluded from this SOW unless added via a formal change control order:

- Application workload migration, deployment, or refactoring of any kind
- Direct Connect provisioning and physical circuit ordering (VPN is in scope; Direct Connect upgrade path is documented for future)
- Third-party SIEM integration (e.g., Splunk, Datadog, Elastic) — architecture to support future integration is in scope; the integration itself is not
- AWS GuardDuty or Security Hub integration with existing ticketing systems (ServiceNow, PagerDuty, etc.)
- Custom compliance frameworks beyond AWS FSBP (additional frameworks confirmed during Phase 1 are in scope; any framework confirmed after Phase 1 cutover requires change control)
- Existing on-premises infrastructure remediation, server patching, or network hardware configuration
- AWS WAF, Shield Advanced, or API Gateway configuration
- Data migration of any kind (database, file, object storage)
- IAM fine-grained permissions for individual application workloads (landing zone permission sets cover platform roles only)
- Multi-tenancy or cost showback implementation beyond basic AWS Cost Explorer and Budgets
- Managed services or ongoing operational support beyond the 4-week hypercare period

## Activities

### Phase 1 — Foundation & Governance (Weeks 1–4)

Phase 1 establishes the governance backbone of the landing zone. All subsequent phases depend on the Control Tower deployment, OU hierarchy, and centralised identity and logging capabilities delivered here. This phase ends with a validated, multi-region governance foundation and a signed Architecture Design Review sign-off from the client.

Key activities:
- Project kick-off meeting; confirm stakeholder RACI and engagement leads; document on-premises context
- Stakeholder interviews to confirm OU design requirements, compliance frameworks, IaC tooling, and IP address space
- Architecture design documentation: OU hierarchy, SCP/RCP policy set, IAM Identity Center design, monitoring architecture
- Deploy AWS Control Tower in us-east-1; enrol us-east-2 as a governed region; configure the landing zone manifest
- Implement the seven-OU hierarchy in AWS Organizations; configure tagging baseline and OU policies
- Deploy all SCPs (deny root, restrict to us-east-1/us-east-2, CloudTrail and Config lock, MFA) and RCP data perimeter controls
- Provision Log Archive and Audit/Security Tooling accounts; configure the CloudTrail organisation trail in both regions
- Configure AWS IAM Identity Center with initial permission sets; integrate identity source; validate SSO login flow
- Enable AWS Config recording in both regions across all accounts; configure delivery to Log Archive
- Deliver Phase 1 architecture documentation and conduct architecture design review with client team

**Deliverable:** Phase 1 Architecture Design Document and signed Architecture Design Review (ADR) sign-off

### Phase 2 — Networking & Connectivity (Weeks 5–8)

Phase 2 builds the network foundation that will carry all future workload traffic. The hub-and-spoke Transit Gateway topology, centralised egress, IP address management, and on-premises VPN are all delivered in this phase. This phase ends with validated end-to-end network connectivity and flow testing.

Key activities:
- Deploy AWS Transit Gateway in us-east-1 and us-east-2; configure inter-region TGW peering and route tables
- Build Network Hub VPCs in both regions; configure centralised NAT Gateway egress; attach to Transit Gateway
- Deploy AWS Network Firewall in Network Hub accounts (both regions); configure north-south and east-west inspection policies
- Configure VPC IPAM with 10.0.0.0/8 supernet; define regional address pools; delegate /20 blocks per spoke VPC
- Create Terraform spoke VPC modules; deploy sample Dev and Prod spoke VPCs; validate TGW routing
- Configure Site-to-Site VPN between Network Hub account and on-premises gateway (both regions); validate routing
- Validate network flows: spoke-to-spoke traffic through firewall, centralised egress paths, and VPN connectivity
- Document Direct Connect upgrade path as an architectural recommendation for post-go-live consideration

**Deliverable:** Validated network topology with tested spoke-to-spoke connectivity, centralised egress, and VPN operational

### Phase 3 — Security, Automation & Handover (Weeks 9–12)

Phase 3 completes the security posture, deploys the account vending automation, and transitions the platform to the client team. This phase delivers the AFT pipeline, all security tooling, and the full operational handover package.

Key activities:
- Enable AWS Security Hub in all accounts and both regions with FSBP standard; aggregate findings to Audit account
- Enable GuardDuty organisation-wide in both regions; configure delegated administrator in Audit account
- Deploy AWS Config rules and conformance packs aligned to FSBP; add additional framework packs as confirmed
- Configure CloudTrail Lake in Audit account; create event data stores and sample investigation queries
- Deploy and validate the AFT pipeline; create AFT account customisations for Prod, NonProd, and Sandbox OU paths
- Vend two workload accounts (one Production, one Non-Production) via AFT and validate complete guardrail enrolment
- Implement AWS Organizations tag policies; configure AWS Cost Explorer; set per-account Budgets alerts at 80% and 100%
- Configure centralised CloudWatch dashboards and SNS alerting in the Shared Services account
- Finalise CI/CD pipeline with branch protection and deployment gates for all IaC changes
- Execute full test plan: SCP enforcement tests, account vending validation, network flow testing, security posture review
- Conduct UAT with client team; obtain formal sign-off against success metrics
- Deliver all runbooks, as-built documentation, and operational handover artefacts
- Deliver administrator and security team training sessions; execute knowledge transfer
- Execute production go-live; commence 4-week hypercare support period

**Deliverable:** Fully operational landing zone with AFT pipeline, at least two vended workload accounts, all security tooling active, full documentation package, and 4-week hypercare support commenced

---

# Deliverables & Timeline

This section defines the complete set of project deliverables and key milestones across the 12-week engagement. Each deliverable is assigned a type, target due date, and an acceptance authority; all deliverables are subject to formal acceptance before the engagement can progress to subsequent phases or milestone payments are triggered.

## Deliverables

The table below lists all 27 deliverables in sequence, covering both interim artefacts (reports, design documents) and final system deliverables (deployed infrastructure, trained teams, runbooks).

<!-- TABLE_CONFIG: widths=[5, 45, 12, 18, 20] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|-------------|------|----------|---------------|
| 1 | Project Kickoff Pack (agenda, stakeholder RACI, risk register) | Document | Week 1 | Client PM / Executive Sponsor |
| 2 | Discovery Report (current state, OU design, SCP requirements, compliance framework confirmation) | Document | Week 2 | Client IT Owner |
| 3 | Phase 1 Architecture Design Document (OU hierarchy, SCP/RCP policy set, IAM Identity Center design, monitoring architecture) | Document | Week 3 | Client IT & Security Leads |
| 4 | AWS Control Tower Deployment (us-east-1 primary, us-east-2 governed, landing zone manifest) | System | Week 4 | Client IT Owner |
| 5 | OU Structure & SCP/RCP Implementation (7-OU hierarchy, all policy controls, tagging baseline) | System | Week 4 | Client Security Lead |
| 6 | IAM Identity Center Configuration (permission sets, identity source integration, validated SSO) | System | Week 4 | Client IT Owner |
| 7 | Centralised Logging (Log Archive + Audit accounts, CloudTrail org trail, Config recording — both regions) | System | Week 4 | Client Security Lead |
| 8 | Architecture Design Review Sign-Off | Document | Week 4 | Client Executive Sponsor |
| 9 | Transit Gateway Deployment (us-east-1 + us-east-2, inter-region peering, route tables) | System | Week 6 | Client IT Owner |
| 10 | AWS Network Firewall (both regions, north-south + east-west policies validated) | System | Week 7 | Client Security Lead |
| 11 | VPC IPAM Configuration (10.0.0.0/8 supernet, regional pools, /20 per spoke delegation) | System | Week 7 | Client IT Owner |
| 12 | Hub VPCs & NAT Gateway (both regions, centralised egress, TGW attached) | System | Week 7 | Client IT Owner |
| 13 | Spoke VPC Terraform Modules (sample Dev and Prod spokes, TGW routing validated) | System | Week 8 | Client IT Owner |
| 14 | Site-to-Site VPN (both regions, on-premises routing validated) | System | Week 8 | Client Networking Lead |
| 15 | Network Testing Report (spoke-to-spoke, egress, VPN) | Document | Week 8 | Client IT Owner |
| 16 | Security Hub & FSBP Conformance (all accounts, both regions, aggregated to Audit) | System | Week 10 | Client Security Lead |
| 17 | GuardDuty Deployment (org-wide, both regions, delegated administrator configured) | System | Week 10 | Client Security Lead |
| 18 | AFT Account Vending Pipeline (Prod, NonProd, Sandbox customisations; end-to-end pipeline validated) | System | Week 11 | Client IT Owner |
| 19 | Two Validated Workload Accounts (1 Production, 1 Non-Production; vended via AFT, guardrails confirmed) | System | Week 11 | Client Executive Sponsor |
| 20 | CI/CD Pipeline (branch protection, deployment gates, IaC standards document) | System | Week 11 | Client IT Owner |
| 21 | Test Results Report (all test types, success metrics achieved, UAT sign-off) | Document | Week 12 | Client Executive Sponsor |
| 22 | Operational Runbooks (account vending, SCP updates, Security Hub triage, networking changes, incident response) | Document | Week 12 | Client IT Owner |
| 23 | As-Built Architecture Document (final production configuration) | Document | Week 12 | Client IT & Security Leads |
| 24 | Administrator Training (recorded sessions — Control Tower, AFT, Security Hub, Config) | Training | Week 12 | Client IT Owner |
| 25 | Knowledge Transfer Sessions (security team — SCP management, GuardDuty, CloudTrail Lake queries) | Training | Week 12 | Client Security Lead |
| 26 | Optimization Recommendations Report (Savings Plans, TGW routing, Direct Connect evaluation) | Document | Week 16 | Client Executive Sponsor |
| 27 | Hypercare Support Closeout Report | Document | Week 16 | Client Executive Sponsor |

## Project Milestones

The milestones below mark the completion of major project phases and critical decision points. Each milestone is a go/no-go gate: the engagement does not proceed to the next phase until the milestone deliverables are formally accepted. Go-Live (M6) and Hypercare End (M7) are the two commercial milestone payment trigger points in addition to Project Initiation and Phase completions.

<!-- TABLE_CONFIG: widths=[20, 55, 25] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 — Kick-off Complete | Stakeholders identified; RACI confirmed; requirements baseline documented | Week 1 |
| M2 — Architecture Approved | Phase 1 Architecture Design Document signed off by client | Week 4 |
| M3 — Governance Foundation Live | Control Tower, OU hierarchy, SCPs, IAM Identity Center, and centralised logging operational in both regions | Week 4 |
| M4 — Network Foundation Live | TGW hub-spoke, Network Firewall, IPAM, NAT Gateway, and VPN all operational and validated | Week 8 |
| M5 — Security Automation Complete | Security Hub (FSBP), GuardDuty, Config rules, CloudTrail Lake, and AFT pipeline fully operational | Week 11 |
| M6 — Go-Live | Two workload accounts vended; all success metrics validated; UAT signed off; production go-live confirmed | Week 12 |
| M7 — Hypercare End | 4-week hypercare support period concluded; Optimization Recommendations Report delivered; project closed | Week 16 |

---

# Roles & Responsibilities

Successful delivery of the AWS Multi-Account Landing Zone requires clear accountability across both the vendor and client teams. The RACI matrix below governs all major task categories across the full engagement lifecycle, ensuring that every activity has a single accountable owner and that the right people are consulted or informed at each stage. The Key Personnel section defines the primary responsibilities of each named role. All stakeholder names will be confirmed during the kick-off session in Week 1 and this section updated accordingly.

## RACI Matrix

The following RACI matrix assigns Responsible (R), Accountable (A), Consulted (C), and Informed (I) designations for every major task category in the engagement. Each row carries exactly one Accountable party to ensure clear decision-making authority at every stage of delivery.

<!-- TABLE_CONFIG: widths=[28, 10, 11, 10, 9, 10, 9, 9, 9] -->
| Task / Activity | Vendor PM | Vendor Arch | Vendor Eng | Vendor QA | Client Exec | Client IT | Client Sec | Client SME |
|-----------------|-----------|-------------|------------|-----------|-------------|-----------|------------|------------|
| Project Kick-off & RACI Finalisation | A | C | I | I | C | R | C | C |
| Discovery & Requirements Gathering | C | A | R | I | I | C | C | R |
| Architecture Design & Documentation | I | A | R | C | I | C | C | C |
| Architecture Design Review Sign-Off | C | R | C | I | A | C | C | I |
| Control Tower Deployment | C | C | A/R | I | I | C | I | I |
| OU Structure & SCP/RCP Implementation | C | C | R | I | I | C | A | C |
| IAM Identity Center Configuration | C | C | R | I | I | A | C | C |
| Centralised Logging (CloudTrail, Config) | C | C | R | I | I | C | A | I |
| Transit Gateway & Networking Build | C | C | A/R | I | I | C | I | C |
| Network Firewall & IPAM Configuration | C | C | A/R | I | I | C | C | I |
| Site-to-Site VPN to On-Premises | C | C | R | I | I | A | I | C |
| AFT Pipeline Setup & Validation | C | C | A/R | R | I | C | I | I |
| Security Hub & GuardDuty Deployment | C | C | R | I | I | C | A | I |
| AWS Config Rules & Conformance Packs | C | C | R | C | I | C | A | I |
| CI/CD Pipeline Finalization | C | C | A/R | C | I | C | I | I |
| Test Plan Development | C | C | C | A/R | I | C | I | I |
| SCP & Guardrail Testing | I | C | R | C | I | C | A | I |
| Account Vending Validation | C | C | R | A | I | C | C | I |
| Network Flow Testing | I | C | R | A | I | C | I | I |
| Security Posture Validation | I | C | R | C | I | C | A | I |
| User Acceptance Testing | R | C | C | C | A | C | C | R |
| Go-Live Planning & Cutover | A | C | R | C | C | C | C | I |
| Runbook Development | C | C | R | I | I | C | C | A |
| Administrator & Security Training | C | C | R | I | I | A | C | C |
| Hypercare Support | R | C | A | I | I | C | C | I |
| Budget Monitoring & Cost Governance | A | I | I | I | C | R | I | C |
| Change Control Management | A | C | C | I | C | R | C | I |

**Legend:** R = Responsible (does the work) | A = Accountable (owns the outcome) | C = Consulted (input required) | I = Informed (kept up to date)

## Key Personnel

Both the vendor and client teams require named representatives across several functional roles to ensure the engagement proceeds without bottlenecks. The vendor team roles below will be staffed from Amatra's certified AWS delivery practice; client roles must be confirmed by the client Executive Sponsor at or before the kick-off session.

**Vendor Team:**
- **Solution Architect (TBD):** Leads the overall technical architecture, OU design, Control Tower configuration, and architecture documentation. Serves as the primary technical authority for the engagement.
- **Cloud Engineers × 2 (TBD):** Responsible for deploying and configuring AWS Control Tower, OU structure, centralised logging accounts, AWS Config, AFT pipeline, and all cloud infrastructure components.
- **Network Engineer (TBD):** Designs and implements the Transit Gateway hub-and-spoke topology, VPC IPAM, Network Firewall, hub VPCs, and Site-to-Site VPN connectivity.
- **Security Engineer (TBD):** Designs and implements SCPs, RCPs, IAM Identity Center, Security Hub, GuardDuty, and all compliance and threat detection controls.
- **Solutions Engineer (TBD):** Responsible for Terraform module development, AFT pipeline setup, CI/CD pipeline, spoke VPC templates, tagging enforcement, and monitoring configuration.
- **Project Manager (TBD):** Manages day-to-day engagement delivery, stakeholder communication, risk management, status reporting, and change control.
- **Technical Writer (TBD):** Produces architecture documentation, as-built documents, and all operational runbooks.
- **QA Engineer (TBD):** Develops the test plan and coordinates all testing activities including SCP enforcement tests, account vending validation, and security posture review.

**Client Team:**
- **Executive Sponsor:** Provides executive oversight, approves the Architecture Design Review, approves UAT sign-off, and authorises go-live. Must be confirmed at kick-off.
- **Cloud / Infrastructure Owner:** Primary client technical contact. Responsible for providing environment access, approving technical design decisions, and accepting technical deliverables.
- **Security Lead:** Confirms compliance framework requirements, reviews SCP and guardrail design, approves security-related deliverables, and validates security posture at go-live.
- **Networking Lead:** Confirms on-premises connectivity topology, provides on-premises gateway configuration details for VPN, and validates VPN routing.
- **FinOps / Finance Contact:** Approves tagging standards, reviews AWS Budgets configuration, and owns cost governance post-go-live.
- **Subject Matter Experts (SMEs):** Available for discovery interviews to provide input on OU design, compliance requirements, and workload classification.

---

# Architecture & Design

This section describes the technical architecture of the AWS Multi-Account Landing Zone, covering the high-level design philosophy, component structure, network topology, security controls, data handling, operational approach, and tooling ecosystem. The architecture has been designed as a production-grade, enterprise-scalable foundation that can serve as the client's primary cloud platform for the foreseeable future, and every design decision has been made to maximise security, automation, and long-term scalability.

## Architecture Overview

The AWS Multi-Account Landing Zone architecture follows AWS best practices for enterprise cloud governance, implementing a hub-and-spoke multi-account model governed by AWS Control Tower across two AWS regions. The design philosophy prioritises **security by default** (all accounts inherit guardrails at creation), **automation over manual effort** (all provisioning and change management via IaC and AFT), and **scale without redesign** (the OU structure and networking topology support future accounts, business units, and workloads without architectural changes).

The landing zone is organised into a seven-OU hierarchy under AWS Organizations. Dedicated Security and Infrastructure OUs house the shared platform accounts (Log Archive, Audit, Shared Services, and Network Hub), while a nested Workloads OU separates Production and Non-Production workload accounts at the policy level. A Sandbox OU provides a lower-guardrail experimentation space, and a Suspended OU holds decommissioned accounts pending closure. This structure allows Service Control Policies and Resource Control Policies to be applied at the OU level with appropriate inheritance, ensuring each account type receives the correct policy boundaries automatically.

The network foundation uses AWS Transit Gateway as the centralised routing backbone in both us-east-1 and us-east-2, with inter-region TGW peering providing connectivity between regions. All traffic — including internet egress, on-premises, and inter-VPC — flows through the Network Hub account, where AWS Network Firewall provides north-south and east-west packet inspection. VPC IPAM manages the 10.0.0.0/8 address space centrally, delegating /20 CIDR blocks to each spoke VPC to eliminate IP conflicts as the estate grows.

![Figure 1: AWS Multi-Account Landing Zone Architecture](../../assets/diagrams/architecture-diagram.png)

**Figure 1: AWS Multi-Account Landing Zone Architecture** — Full multi-region landing zone showing the OU hierarchy, Security and Infrastructure shared accounts, Transit Gateway hub-and-spoke networking, and Account Factory for Terraform automated provisioning pipeline.

## Component Architecture

The landing zone is built on six categories of AWS platform components, each serving a distinct function within the multi-account architecture.

**Governance & Control Plane:**
- **AWS Control Tower:** The governance orchestrator. Deploys the landing zone manifest, enrols OUs and accounts, manages guardrail inheritance, and provides the Control Tower dashboard for compliance visibility. Deployed in us-east-1 with us-east-2 as a governed home region.
- **AWS Organizations:** Hosts the organisational structure, OU hierarchy, and policy attachment point for SCPs and RCPs. All accounts in scope are members of the same Organisation.
- **Service Control Policies (SCPs):** Preventative guardrails applied at the OU level. Policies enforced: deny root account usage, restrict all API calls to us-east-1 and us-east-2 only, prevent disabling of CloudTrail and Config, and require MFA on console access.
- **Resource Control Policies (RCPs):** Data perimeter controls applied organisation-wide to prevent data exfiltration to external principals or accounts outside the Organisation boundary.

**Identity & Access:**
- **AWS IAM Identity Center (SSO):** Centralised identity management for all AWS accounts. Permission sets (Administrator, ReadOnly, SecurityAuditor, NetworkOperator, FinOps) are assigned to groups mapped to OU-specific accounts. Identity source (native AWS SSO directory or customer IdP) confirmed at kick-off.
- **Account Factory for Terraform (AFT):** The account vending engine. AFT is deployed as a CodePipeline-based pipeline in the Management account that accepts account requests as Terraform configuration, vends the account, enrols it in Control Tower, applies OU-specific customisations, and configures baseline security controls — all in under 30 minutes with zero manual steps.

**Shared Platform Accounts:**
- **Log Archive Account:** Dedicated S3 bucket with Object Lock for centralised storage of CloudTrail and Config logs from all accounts in both regions. Access restricted to Security and Audit roles only.
- **Audit / Security Tooling Account:** Aggregation point for Security Hub findings, GuardDuty threat intelligence, and CloudTrail Lake queries. Serves as the security operations centre (SOC) integration point for the client's future SIEM.
- **Shared Services Account:** Hosts the centralised CloudWatch monitoring dashboards, SNS alerting topic, and any shared tooling onboarded post-go-live.
- **Network Hub Account:** Contains all centralised networking resources: Transit Gateway (both regions), Network Firewall (both regions), NAT Gateways, VPC IPAM, and the VPN customer gateway configuration.

**Workload Accounts (vended via AFT):**
Each workload account follows a consistent baseline configuration applied by AFT customisations: CloudTrail inheritance from the organisation trail, Config recorder enabled, Security Hub and GuardDuty enrolment, spoke VPC with /20 CIDR from IPAM, TGW attachment to Network Hub, mandatory tags applied, and AWS Budgets alerts at 80% and 100% thresholds.

**Sandbox & Suspended Accounts:** Sandbox accounts receive a reduced SCP set (region restriction and root deny remain; production guardrails relaxed for experimentation). Suspended accounts are isolated with a deny-all SCP pending formal closure.

## Network Design

The network architecture implements a **hub-and-spoke topology** with the Network Hub account serving as the centralised routing, inspection, and egress point for all VPC traffic across the organisation.

**Transit Gateway Architecture:** Two separate Transit Gateway instances are deployed — one in us-east-1 and one in us-east-2 — connected via static inter-region TGW peering. Separate TGW route tables are maintained per traffic domain: Inspection Route Table (routes all traffic to Network Firewall before forwarding), Spoke Route Table, and On-Premises Route Table.

**VPC IPAM:** A single VPC IPAM pool is configured with the 10.0.0.0/8 supernet. Regional sub-pools are allocated for us-east-1 (10.0.0.0/10) and us-east-2 (10.64.0.0/10). Each spoke VPC request triggers an automatic /20 CIDR allocation from the appropriate regional pool, eliminating IP conflicts.

**Network Firewall:** AWS Network Firewall endpoints are deployed in the Network Hub VPC in both regions. Stateful rules govern north-south (internet egress) and east-west (spoke-to-spoke) traffic. A default deny stance applies; explicitly permitted flows are documented in the firewall policy. Centralised NAT Gateways (one per Availability Zone per region) provide internet egress for all spoke workloads through a single, monitored path.

**On-Premises Connectivity:** Site-to-Site VPN is established between the Network Hub account (both regions) and the on-premises gateway. BGP is used for dynamic route propagation where supported; static routing is configured as fallback. Direct Connect upgrade is documented as a post-go-live architectural recommendation.

**Spoke VPCs:** Each spoke VPC receives a /20 CIDR block with /24 subnets per Availability Zone for application, data, and private tiers. Spoke VPCs have no internet gateway; all traffic routes via TGW to the Network Hub. VPC Flow Logs are enabled on all spoke VPCs and delivered to the centralised Log Archive.

## Security Design

The security architecture is structured across four control layers — preventative, detective, responsive, and governance — each implemented using AWS-native services to minimise operational overhead and maximise integration.

**Preventative Controls:** SCPs enforce hard boundaries: no root account usage, no API calls outside us-east-1/us-east-2, no disabling of CloudTrail or Config, and MFA required for all console access. RCPs enforce a data perimeter that prevents any IAM principal from exfiltrating data to resources outside the Organisation boundary. Network Firewall stateful rules prevent unauthorised lateral connections or access to unapproved internet destinations. IAM Identity Center with least-privilege permission sets minimises blast radius for any compromised credential.

**Detective Controls:** Amazon GuardDuty analyses VPC Flow Logs, CloudTrail management events, and DNS logs for threat indicators across all accounts in both regions. AWS Security Hub aggregates compliance findings from all accounts to the Audit account with the FSBP standard enforced. AWS Config records all resource configuration changes and evaluates resources against conformance packs continuously. CloudTrail Lake provides a queryable, tamper-evident event data store for security investigations.

**Responsive Controls:** SNS alerting is configured for Security Hub high/critical findings and GuardDuty high-severity threats, routing to client email distribution lists. Operational runbooks for Security Hub finding triage, GuardDuty alert escalation, and SCP-deny investigation are delivered as part of the Handover package.

**Identity Security:** MFA enforced via SCP for all console access organisation-wide. IAM Identity Center session policies limit console session duration to 8 hours. Root account credentials are locked after initial use in each account; recovery procedures are documented in the runbooks.

## Data Architecture

All data within the landing zone scope is classified according to the five mandatory tags established in Phase 1, with the `DataClassification` tag (values: Public, Internal, Confidential, Restricted) applied to all resources at creation time via AFT customisations. This section describes how audit, log, and configuration data is stored, protected, and retained across the landing zone.

**Centralised Log Storage:** All CloudTrail management and data events from all accounts in both regions are delivered to the Log Archive S3 bucket. S3 Object Lock (compliance mode) is configured with a minimum 90-day retention period to prevent log tampering. Lifecycle policies transition logs to S3 Glacier Instant Retrieval after 90 days for cost-effective long-term retention. AWS Config snapshots and VPC Flow Logs are stored in the same Log Archive bucket under separate prefixes.

**CloudTrail Lake:** A CloudTrail Lake event data store is configured in the Audit account with a 7-year retention period, providing queryable and tamper-evident audit records for security investigations without requiring external log management tooling.

**Data Residency:** All data is stored exclusively in us-east-1 and us-east-2 in accordance with the client's US-only data residency requirement. The SCP restricting all API calls to these two regions enforces this at the control-plane level, making non-compliant data placement technically impossible.

**Workload Data:** Application and database workloads are not in scope for this engagement. Data architecture for individual workloads will be defined during future workload-specific engagements, with the data classification standards established here serving as the governance baseline.

## Operational Design

The operational design ensures that the landing zone can be monitored, maintained, and recovered with minimal manual effort. Observability, backup, disaster recovery, and change management capabilities are built in from day one.

**Monitoring & Observability:** Centralised CloudWatch dashboards in the Shared Services account provide organisation-wide visibility into Control Tower compliance status, Security Hub finding counts by severity, GuardDuty threat volume, CloudTrail API activity, and AWS Config compliance scores. CloudWatch Metric Alarms route critical operational alerts via SNS to client email. Log Insights queries are pre-built for common operational investigation patterns.

**Backup & Disaster Recovery:** The landing zone itself is managed as code via Terraform and AFT. In the event of a catastrophic failure, the entire landing zone can be redeployed from Terraform state and AFT templates. RTO for landing zone restoration: < 4 hours. RPO: last successful IaC commit. Log Archive S3 data is protected by Object Lock and cross-region replication (us-east-1 → us-east-2).

| Component | RTO | RPO |
|-----------|-----|-----|
| Landing Zone (IaC rebuild) | < 4 hours | Last IaC commit |
| Log Archive (S3 + CRR) | < 1 hour | < 15 minutes |
| IAM Identity Center SSO | < 2 hours (AWS SLA) | N/A (AWS-managed) |
| Network Firewall | < 30 minutes (multi-AZ) | N/A (stateless rules in IaC) |

**Change Management:** All infrastructure changes are made via the IaC CI/CD pipeline with mandatory peer review and automated Terraform plan validation before merge. SCP changes require dual-approval from the Vendor Solution Architect and Client Security Lead before deployment.

## Tooling Overview

The table below summarises the key tools used across the engagement for delivery, governance, and ongoing operations after handover.

<!-- TABLE_CONFIG: widths=[30, 35, 35] -->
| Category | Primary Tools | Purpose |
|----------|---------------|---------|
| Cloud Governance | AWS Control Tower, AWS Organizations | Multi-account governance, OU structure, guardrail enforcement |
| Identity & Access | AWS IAM Identity Center, IAM | Centralised SSO, permission sets, cross-account role management |
| Networking | AWS Transit Gateway, Network Firewall, VPC IPAM, NAT Gateway | Hub-and-spoke routing, centralised inspection, IP management, egress |
| Security — Preventative | Service Control Policies, Resource Control Policies | Organisational boundary enforcement and data perimeter |
| Security — Detective | Amazon GuardDuty, AWS Security Hub, AWS Config | Threat detection, CSPM, continuous compliance monitoring |
| Audit & Logging | AWS CloudTrail, CloudTrail Lake, Amazon S3 (Object Lock) | Immutable audit trail, security investigation, compliance archive |
| Monitoring | Amazon CloudWatch, Amazon SNS | Centralised metrics, dashboards, alerting |
| IaC & Automation | Terraform, Account Factory for Terraform (AFT) | Infrastructure as code, account vending automation |
| CI/CD | AWS CodePipeline, AWS CodeBuild (AFT) | AFT pipeline execution; additional CI/CD tooling TBD with client |
| FinOps | AWS Cost Explorer, AWS Budgets, AWS Cost Anomaly Detection | Cost visibility, per-account spend alerts, anomaly detection |

---

# Security & Compliance

Security is a foundational requirement for this engagement, not an afterthought. The landing zone is designed to enforce security controls at the organisational level, ensuring that every account created — now and in the future — inherits the same baseline security posture without requiring individual account configuration. The following subsections describe the full security and compliance architecture, supplementing the architecture-level controls described in Section 6.

## Identity & Access Management

AWS IAM Identity Center serves as the single identity plane for all AWS account access across the organisation. All human access to AWS accounts is routed through IAM Identity Center; direct IAM user creation in individual accounts is prohibited by SCP (except for break-glass emergency access accounts with credentials stored in AWS Secrets Manager).

Permission sets are defined at the landing zone level and mapped to the following roles: **PlatformAdministrator** (full access to platform accounts; restricted to vendor team and designated client IT leads during the engagement), **WorkloadAdministrator** (administrative access within a specific workload account, scoped by OU), **SecurityAuditor** (read-only access to all accounts and both regions for ongoing compliance monitoring), **NetworkOperator** (access scoped to networking resources in the Network Hub account), and **FinOps** (read access to cost and billing data across all accounts).

MFA is enforced for all IAM Identity Center users via an SCP that denies console access if MFA is not registered. Console session duration is capped at 8 hours. Privileged access reviews are recommended quarterly post-go-live.

## Monitoring & Threat Detection

Amazon GuardDuty is the primary threat detection service, enabled organisation-wide across both regions with the Security Audit account as the delegated administrator. GuardDuty analyses VPC Flow Logs for network anomalies, CloudTrail Management Events for API-level threats (root usage, privilege escalation, credential theft), DNS Logs for domain-based threat indicators, and optionally S3 Data Events for high-classification buckets.

GuardDuty findings are triaged and escalated according to the Security Hub finding triage runbook delivered in Phase 3. AWS Security Hub aggregates findings from GuardDuty, Config, and IAM Access Analyser into a single prioritised view in the Audit account. The FSBP standard is enforced from go-live, with custom insights and automated finding suppression rules configured for known-acceptable deviations documented during Phase 1 discovery.

## Compliance & Auditing

The primary compliance framework at go-live is the **AWS Foundational Security Best Practices (FSBP)** standard, enforced via Security Hub and backed by AWS Config rules covering 200+ controls across IAM, storage, network, logging, and monitoring domains. Additional compliance frameworks will be confirmed with the client security team during Phase 1 and may include NIST 800-53 Rev 5 (recommended for organisations with regulated insurance operations), SOC 2 (relevant for vendor assurance and customer audit obligations), and HIPAA (if the client processes PHI as part of insurance operations).

All CloudTrail management events are retained for 7 years in CloudTrail Lake (queryable) and in S3 (Object Lock, Glacier archive). This satisfies audit retention requirements for SOC 2, HIPAA, and most regulatory frameworks without additional tooling.

## Encryption & Key Management

All data at rest in AWS services within the landing zone is encrypted by default. S3 (Log Archive) uses SSE-S3 (AES-256) applied by default bucket policy; SSE-KMS is available for accounts requiring customer-managed key control. CloudTrail Lake is encrypted at rest using AWS-managed keys, with customer-managed KMS keys available as an optional enhancement. EBS volumes in shared accounts are encrypted by default enforced via Config rule. All data in transit is encrypted using TLS 1.2 minimum, enforced via S3 bucket policy (`aws:SecureTransport`) and Network Firewall rules.

AWS KMS is available in both regions. Key management governance (rotation schedules, key policies, alias naming standards) is documented in the as-built architecture document and in the Key Management runbook.

## Governance

Policy enforcement is implemented at multiple layers to ensure controls cannot be bypassed at any level of the account hierarchy. SCPs apply at the OU level via AWS Organizations and cannot be overridden by any account administrator. AWS Config continuously evaluates resource configurations and triggers alerts for non-compliant resources. Config Conformance Packs provide packaged rule sets mapped to each compliance framework, enabling compliance score tracking over time. Tag Policies via AWS Organizations enforce the five mandatory tags on all supported resources.

Terraform Sentinel or OPA policies validate all IaC changes against security and compliance rules before deployment, preventing non-compliant infrastructure from ever being applied to the environment. All infrastructure changes follow a formal change management process: pull request raised in the IaC repository, reviewed and approved by both the Vendor Solution Architect and the Client IT Owner, and applied via the CI/CD pipeline.

## Environments & Access

### Environment Strategy

The following table defines the purpose, access model, and data handling approach for each environment tier within the landing zone. These boundaries are enforced through OU-level SCPs and IAM Identity Center permission set assignments.

<!-- TABLE_CONFIG: widths=[20, 25, 25, 30] -->
| Environment | Purpose | Access Control | Data |
|-------------|---------|----------------|------|
| Development | Workload development and feature testing; lower guardrail SCP set within Workloads-NonProd OU | WorkloadAdministrator (developers); SecurityAuditor (security team) | Non-production synthetic data only; DataClassification = Internal |
| Non-Production (Test/Staging) | Integration testing and pre-production validation; inherits full FSBP compliance | WorkloadAdministrator (restricted); SecurityAuditor; approval required for any production-data access | Anonymised test data; DataClassification = Confidential |
| Production | Live workloads; maximum SCP enforcement; all Config rules active | WorkloadAdministrator (elevated approval required); SecurityAuditor; PlatformAdministrator (break-glass only) | Production data; DataClassification = Restricted or Confidential |
| Platform Shared (Log Archive, Audit, Shared Services, Network Hub) | Centralised platform functions; no direct workload hosting | PlatformAdministrator only; no WorkloadAdministrator access | Audit logs and monitoring data; DataClassification = Restricted |

### Access Policies

All account access is granted through IAM Identity Center permission sets only. No long-lived IAM user credentials are permitted in any account (enforced by SCP and Config rule). Production account access requires a ticketing approval flow to be configured post-go-live by the client security team using the documented IAM Identity Center access request pattern. Break-glass access credentials for the Management account root and each member account root are generated, sealed, and stored in a documented offline process agreed with the client security team at handover.

---

# Testing & Validation

A rigorous testing programme is applied across all landing zone components before go-live. Testing is conducted primarily in Weeks 10–12 of the engagement, following completion of development activities, and concludes with formal UAT sign-off by the client before the production go-live confirmation is issued. Each testing type below defines its scope, methodology, and the acceptance criteria that must be satisfied for the engagement to proceed to go-live.

## Functional Validation

Functional validation confirms that all deployed components behave as designed and meet the requirements defined in the Phase 1 Architecture Design Document. Tests are derived directly from the Architecture Design Document acceptance criteria and cover all major landing zone capabilities: Control Tower deployment status, OU hierarchy validation, IAM Identity Center cross-account access, AFT account vending end-to-end flow, CloudTrail and Config delivery to Log Archive, and CloudWatch dashboard population with SNS alert routing.

All functional test cases are documented in the Test Plan (Deliverable 21) with expected results and actual results recorded. The acceptance criterion for functional validation is that all test cases pass with no blockers outstanding at UAT entry.

## Performance & Load Testing

Performance testing for a landing zone engagement focuses on the account vending pipeline throughput and network data path performance rather than traditional application load testing. The following performance targets must be validated before go-live:

- **Account Vending Throughput:** The AFT pipeline must successfully vend a new account in < 30 minutes from request submission to fully enrolled and customised account. This is tested three times consecutively to confirm repeatability and satisfy the engagement's hard go-live success metric.
- **Network Firewall Throughput:** Baseline network throughput is measured through the Network Firewall in both regions using standard traffic simulation; results are documented for future capacity planning reference.
- **Transit Gateway Latency:** Inter-region latency between us-east-1 and us-east-2 is measured via TGW peering and documented as the baseline for future workload DR planning.

The acceptance criterion is that AFT account vending completes within 30 minutes across three consecutive test runs and network baseline metrics are documented.

## Security Testing

Security testing validates that all preventative and detective controls are operating correctly and that the security posture meets the zero critical findings target. This is the most critical testing category for a landing zone engagement, as failures here represent direct risk to the client's production environment.

The following security tests are executed in sequence: SCP enforcement testing (simulated policy-violating API calls to validate each deny statement — root account access, API calls outside allowed regions, CloudTrail disable attempt, MFA bypass); RCP data perimeter testing (attempt to write S3 objects to a bucket outside the Organisation boundary from a member account, which must be denied); IAM Access Analyser review (no external-access findings permitted in Production or Platform accounts); Security Hub FSBP compliance score (must reach ≥ 80% at go-live); and GuardDuty baseline alert routing confirmation.

The acceptance criteria are: all SCP deny tests pass; RCP data perimeter validated; zero critical FSBP findings in Production; Security Hub score ≥ 80%.

## Disaster Recovery & Resilience Tests

DR testing validates the us-east-2 secondary region governance posture and the Control Tower multi-region failover capability. These tests confirm that the secondary region provides genuine governance coverage and is not merely enrolled in name only.

Tests performed include: us-east-2 governance validation (API calls recorded in org CloudTrail; Config recording active; Security Hub findings aggregating from us-east-2 to Audit account); TGW inter-region failover test (traffic routed between regions via peering attachment, latency and throughput measured); and IaC rebuild validation (a non-production account is terminated and rebuilt from AFT pipeline and Terraform state, confirming < 4 hour RTO for component recovery).

The acceptance criterion is that us-east-2 governance is confirmed in all three test scenarios and the IaC rebuild is completed successfully within the 4-hour RTO target.

## User Acceptance Testing

User Acceptance Testing is conducted in Week 12 with designated client team members and represents the client's formal validation that the delivered landing zone meets the agreed success criteria before go-live is confirmed. UAT is structured as a facilitated session covering all major platform capabilities, with the client team performing operations rather than observing vendor demonstrations.

The UAT session covers: end-to-end account vending via AFT (live vend of a test account performed by the client IT Owner); IAM Identity Center SSO login and cross-account navigation by client team members; Security Hub dashboard review and finding triage workflow walkthrough; CloudWatch centralised monitoring dashboard review; and review of all operational runbooks for completeness and accuracy.

Outstanding issues identified during UAT are classified as P1 (go-live blocker — must be resolved before go-live confirmation), P2 (must be resolved within the hypercare period), or P3 (post-hypercare backlog). The acceptance criterion is that all P1 issues are resolved and the UAT sign-off document is signed by both the Client Executive Sponsor and Client IT Owner.

## Go-Live Readiness

Before production go-live is confirmed, the following go-live readiness checklist must be completed and signed off jointly by the Vendor Project Manager and Client IT Owner. Each item is a binary pass/fail gate.

- [ ] All P1 UAT issues resolved; UAT sign-off document signed
- [ ] All accounts enrolled in Control Tower guardrails (green status in CT dashboard)
- [ ] CloudTrail organisation trail delivering events in both regions
- [ ] Security Hub FSBP score ≥ 80% in all Production and Platform accounts
- [ ] Zero critical Security Hub findings in Production and Platform accounts
- [ ] GuardDuty enabled and alert routing confirmed in both regions
- [ ] AFT account vending pipeline validated (< 30 min; 3 consecutive runs)
- [ ] Two workload accounts (1 Prod, 1 NonProd) vended and guardrail-enrolled
- [ ] Rollback procedure documented and confirmed with client
- [ ] Client team trained and runbooks delivered
- [ ] Break-glass access process confirmed and documented with client security team
- [ ] AWS Budgets alerts active for all accounts (80% and 100% thresholds)

## Cutover Plan

The go-live for this engagement constitutes a controlled operational handover: the landing zone is already fully functional in AWS accounts, and go-live marks the formal transfer of operational ownership from the vendor team to the client team. The cutover sequence follows a structured timeline to ensure no disruption to the newly operational environment.

The cutover sequence is: T-7 days (final UAT sign-off obtained; go-live readiness checklist signed; go-live date confirmed in writing); T-3 days (final IaC pipeline health check; AFT pipeline confirmation; all runbooks reviewed with client); T-1 day (Security Hub baseline snapshot captured; CloudWatch dashboard screenshot for go-live baseline record; break-glass access process confirmed); Go-Live/T (formal transfer of PlatformAdministrator permission set management to client IT Owner; vendor delivery team transitions to hypercare support model); T+1 day (post-go-live check call; confirm no P1 issues; confirm SNS alerting active).

The acceptance criterion for cutover completion is the Client Executive Sponsor and Client IT Owner signing the Go-Live Confirmation document.

## Rollback Strategy

For this engagement, a traditional rollback to a pre-deployment state is not applicable as the engagement starts from a greenfield environment. Instead, the rollback strategy addresses specific component failure scenarios that could arise during and after deployment: Control Tower deployment failure (revert using CT landing zone repair workflow; re-run AFT customisations from IaC state; estimated recovery 2–4 hours); AFT pipeline failure (pipeline re-run from last known-good Terraform backend state; individual vending failures trigger automated AFT remediation); Network Firewall policy error (firewall policy rollback via IaC pipeline in < 30 minutes; temporary bypass documented in the Network Firewall runbook); SCP misconfiguration (previous policy version re-applied via CI/CD pipeline in < 15 minutes; SCP testing in non-production OU validates policies before production application).

All rollback triggers, contact escalation paths, and approval authorities are documented in the Incident Response runbook delivered as part of the handover package.

---

# Handover & Support

The handover phase ensures that the client team can independently operate, manage, and evolve the AWS Multi-Account Landing Zone after the vendor engagement concludes. All operational knowledge is transferred through a combination of structured documentation, live training sessions, and the 4-week hypercare support period. The goal is full client self-sufficiency — the ability to vend accounts, manage security findings, make network changes, and respond to incidents — by the end of hypercare.

## Handover Artifacts

The following artefacts are delivered to the client as part of the operational handover package, representing the complete set of knowledge and configuration documentation required for the client team to operate the landing zone independently:

- **As-Built Architecture Document:** Final production architecture diagrams and configuration specifications, updated to reflect any changes made during implementation and testing
- **Phase 1 Architecture Design Document:** Baseline design documentation preserved for historical reference and future architecture decisions
- **IaC Repository (Terraform + AFT):** Complete infrastructure code repository with all modules, account customisations, and pipeline configurations; transferred to client-managed Git repository at handover
- **Operational Runbooks (6 runbooks):** Account vending via AFT; SCP policy change process; Security Hub finding triage and escalation; Network Firewall policy update; Incident response; CloudTrail Lake investigation queries
- **Test Results Report:** Complete testing evidence including SCP enforcement tests, account vending validation, security posture results, and formal UAT sign-off
- **Administrator Training Materials:** Recorded training sessions and slide decks for Control Tower, IAM Identity Center, AFT, Security Hub, Config, and CloudWatch operations
- **Optimization Recommendations Report:** Post-go-live recommendations for Savings Plans, Transit Gateway routing optimisation, Direct Connect evaluation, and additional compliance framework onboarding

## Knowledge Transfer

Knowledge transfer is delivered as a structured programme in Week 12, comprising two targeted training tracks designed for the specific audiences who will operate the platform day-to-day.

**Cloud Infrastructure Track (Platform Administrator audience):**
- Session 1 (2 hours): AWS Control Tower operations — guardrail management, OU changes, account enrolment review
- Session 2 (2 hours): Account Factory for Terraform — submitting account requests, monitoring the AFT pipeline, customisation updates
- Session 3 (2 hours): Day-2 operations — Config rule management, CloudWatch dashboard navigation, Budgets and Cost Explorer

**Security Operations Track (Security Lead audience):**
- Session 1 (2 hours): Security Hub — finding triage, suppression rules, compliance score interpretation, escalation workflow
- Session 2 (2 hours): GuardDuty — threat categorisation, finding investigation, alert routing, integration roadmap
- Session 3 (2 hours): CloudTrail Lake — running investigation queries, alert-based queries, audit evidence extraction

All sessions are recorded and delivered as part of the training materials handover package. A Q&A walkthrough of all runbooks is included in the final knowledge transfer session.

## Hypercare Support

Following go-live, the vendor team provides **4 weeks of hypercare support** (Weeks 13–16) to ensure a smooth operational transition and assist with early workload onboarding. Hypercare is designed to give the client team confidence to operate independently by providing a safety net during the critical first month of operations.

**Coverage:** Business hours (Monday–Friday, 9 AM–5 PM local client time); P1 incidents escalated to 24-hour on-call support with a 2-hour response SLA.

**Scope of Hypercare:** Triage and resolution of issues arising from the deployed landing zone components; support for the first live workload account vending via AFT; guidance on Security Hub finding triage and GuardDuty alert investigation; minor configuration adjustments (SCP updates, permission set changes, firewall rule additions) within the original scope; and assistance with on-premises VPN routing issues post-go-live.

**Out of Hypercare Scope:** New feature development or scope additions (handled via change control); application workload support; and third-party tooling support (Terraform Cloud, identity provider, SIEM).

**Hypercare SLAs:**

| Priority | Definition | Response Time | Resolution Target |
|----------|-----------|--------------|------------------|
| P1 — Critical | Landing zone governance failure; production accounts unenrolled; SCPs non-functional | 2 hours (24×7) | 8 hours |
| P2 — High | AFT pipeline failure; Security Hub/GuardDuty outage; significant compliance regression | 4 hours (business hours) | 24 hours |
| P3 — Medium | Non-critical component issues; minor configuration discrepancies | 1 business day | 5 business days |
| P4 — Low | Documentation corrections; enhancement requests | 2 business days | Hypercare backlog |

## Managed Services Transition

Ongoing managed services are not included in this engagement. The landing zone is designed for full client self-management after hypercare, supported by the delivered runbooks and training materials. If the client requires ongoing managed services for the landing zone, Security Operations (SOC), or FinOps, refer to a separate Managed Services Agreement available from Amatra.

## Assumptions

The following assumptions underpin the project plan and cost estimates. Each assumption represents a dependency on client inputs or conditions that, if not met, may require scope and timeline adjustment via change control:

1. The client will designate a Cloud/Infrastructure Owner, Security Lead, Networking Lead, Executive Sponsor, and FinOps contact before or at the Week 1 kick-off session.
2. The client will provide the vendor team with necessary AWS root access or management account access to deploy Control Tower at the start of Phase 1.
3. On-premises connectivity details (gateway IP, ASN, routing protocol capability) are confirmed and the on-premises gateway is accessible before Phase 2 begins.
4. The identity source for IAM Identity Center (native AWS directory vs existing IdP such as Azure AD or Okta) is confirmed before the end of Phase 1.
5. The applicable compliance frameworks beyond FSBP are confirmed by the client security lead before the end of Week 2 (Discovery Report gate).
6. The client's preferred CI/CD tooling for the IaC pipeline is confirmed before Phase 2 development begins; if no preference is stated, AWS CodePipeline/CodeBuild will be used.
7. The client will provide feedback on all design documents within 5 business days of delivery.
8. The client team will participate in UAT sessions during Week 12 and is available to provide formal sign-off within 3 business days of UAT completion.
9. A sandbox or test AWS account is available for SCP and AFT validation testing before changes are applied to Production OUs.
10. No existing AWS accounts, organisations, or resources require migration, consolidation, or remediation.
11. On-premises hardware supports BGP or static routing compatible with AWS Site-to-Site VPN; Direct Connect is not required for go-live.
12. The client will manage the registration and administration of the Terraform Cloud Team tier account; the vendor will configure the workspaces as part of the engagement.
13. AWS partner programme eligibility for MAP and AWS Activate credits will be confirmed by the vendor account team before billing; credits are not guaranteed but are highly probable for a greenfield engagement of this type.
14. All client stakeholders have the authority and availability to approve deliverables within the timeline specified in the Deliverables & Timeline section.
15. The client will have no data classification requirements that prohibit logging of management events to the centralised Log Archive account.

## Dependencies

The table below lists the critical dependencies that must be satisfied for the engagement to proceed on schedule. Each dependency is assigned an owner and a required-by date; unresolved dependencies after their required-by date will be raised as risks and may trigger timeline adjustment.

| # | Dependency | Owner | Required By |
|---|-----------|-------|-------------|
| D1 | Management account root credentials provided to vendor team | Client IT Owner | Week 1 |
| D2 | Stakeholder RACI roles confirmed and named | Client Executive Sponsor | Week 1 |
| D3 | Compliance framework requirements confirmed (NIST / SOC 2 / HIPAA) | Client Security Lead | Week 2 |
| D4 | Identity source for IAM Identity Center confirmed | Client IT Owner | Week 3 |
| D5 | On-premises gateway details confirmed (IP, ASN, routing protocol) | Client Networking Lead | Week 4 |
| D6 | CI/CD tooling preference confirmed | Client IT Owner | Week 4 |
| D7 | Architecture Design Document approved (Phase 1 gate) | Client Executive Sponsor | Week 4 |
| D8 | On-premises gateway accessible and correctly configured for VPN | Client Networking Lead | Week 6 |
| D9 | Client UAT team available for Week 12 UAT sessions | Client Executive Sponsor | Week 12 |
| D10 | AWS MAP and Activate credit eligibility confirmed with AWS account team | Vendor Account Manager | Week 2 |

---

# Investment Summary

This section presents the total investment for the AWS Multi-Account Landing Zone engagement. Cost figures are sourced directly from the `infrastructure-costs.csv` and `level-of-effort-estimate.csv` artefacts, which form part of this SOW package, ensuring full reconciliation between the investment summary and the underlying cost models. All figures are presented in USD.

**Medium Implementation:** This pricing reflects a medium-complexity multi-account landing zone engagement, based on a greenfield AWS deployment spanning 2 regions, 7–12 accounts, hub-and-spoke networking with Network Firewall, and a full Terraform + AFT IaC automation pipeline. Level of effort is calculated at 1,586 hours total across five delivery phases plus 10% management overhead.

## Total Investment

The table below summarises the full 3-year investment across all cost categories, showing Year 1 list price, applicable credits, Year 1 net investment, and steady-state run costs for Years 2 and 3. Professional services are a one-time Year 1 cost; infrastructure and support costs recur annually.

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[28, 12, 14, 12, 10, 10, 14] -->
| Cost Category | Year 1 List | Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------|------------|--------|--------|--------------|
| Professional Services | $316,440 | ($18,000) | $298,440 | $0 | $0 | $298,440 |
| Cloud Infrastructure | $28,422 | ($15,000) | $13,422 | $28,422 | $28,422 | $70,266 |
| Software Licenses | $480 | $0 | $480 | $480 | $480 | $1,440 |
| Support & Maintenance | $4,200 | $0 | $4,200 | $4,200 | $4,200 | $12,600 |
| **TOTAL INVESTMENT** | **$349,542** | **($33,000)** | **$316,542** | **$33,102** | **$33,102** | **$382,746** |
<!-- END COST_SUMMARY_TABLE -->

## Partner Credits

A total of **$33,000 in credits** are applied in Year 1, providing a material reduction in the first-year investment. These credits are sourced from Amatra's AWS partner programmes and are applied directly to the client's charges — they are real reductions in billing, not promotional discounts.

**Professional Services Credits ($18,000 total):**
- **AWS Partner Network (APN) Advanced Tier Credit — $10,000:** Applied to professional services for solution architecture, Control Tower design, and implementation on this greenfield engagement. Available through Amatra's APN Advanced Consulting Partner status.
- **AWS Migration Acceleration Program (MAP) Assess/Mobilize Credit — $5,000:** Applicable to greenfield landing zone deployments under the MAP programme. Subject to confirmation with the AWS account team (Dependency D10).
- **Implementation Volume Discount — $3,000:** Volume discount on professional services for this strategic greenfield engagement. Applicable when total billable hours exceed 600; this engagement at 1,586 hours qualifies.

**Infrastructure Credits ($15,000 total):**
- **AWS Activate Founders Credit — $5,000:** Available to net-new AWS customers with no prior AWS accounts, applied to AWS service charges in Year 1.
- **AWS MAP Infrastructure Credit — $10,000:** AWS Migration Acceleration Program credit applicable for greenfield landing zone engagements, applied directly to AWS service bills.

*All credits apply in Year 1 only. Years 2 and 3 reflect the full run-rate infrastructure cost. Credit availability is subject to standard AWS partner programme terms and confirmation with the AWS account team.*

## Cost Components

**Professional Services — $316,440 gross / $298,440 net (Year 1, one-time):**

The professional services estimate is based on 1,586 actual hours calculated from base task hours with phase-specific effort multipliers (Discovery: 1.0×, Planning: 1.2×, Development: 1.3×, Testing: 1.0×, Deployment: 1.0×) plus 10% management overhead for Technical Leadership and Project Management. The phase-by-phase breakdown from the Level of Effort estimate is as follows:

| Phase | Hours | Cost |
|-------|-------|------|
| Discovery | 120.0 hrs | $26,800 |
| Planning | 240.0 hrs | $50,160 |
| Development | 634.4 hrs | $129,480 |
| Testing | 144.0 hrs | $28,200 |
| Deployment | 184.0 hrs | $29,000 |
| Management (Tech Leadership + PM) | 264.0 hrs | $52,800 |
| **Total** | **1,586.4 hrs** | **$316,440** |

Blended professional services rates range from $125/hr (Technical Writer, Trainer) to $250/hr (Solution Architect). AWS-certified architect rate ($250/hr) applies to all Solution Architect tasks.

**Cloud Infrastructure — $28,422/year gross / $13,422 net Year 1:**

The infrastructure run-rate is sourced from the itemised infrastructure-costs.csv. The largest cost drivers are AWS Network Firewall ($9,480/year for both regions), Transit Gateway ($5,256/year for two gateways), AWS Business Support ($4,200/year), and AWS Config ($3,240/year). The 3-year infrastructure total is **$70,266** (from infrastructure-costs.csv Summary: Cloud Services 3-Year Total). Infrastructure costs are consistent across all three years; actual costs will scale modestly as additional workload accounts are onboarded and traffic volumes increase.

**Software Licenses — $480/year ($1,440 over 3 years):**

HashiCorp Terraform Cloud Team tier (5 users, $40/month) provides the IaC platform for AFT and workload Terraform execution. This cost is consistent across all three years.

**Support & Maintenance — $4,200/year ($12,600 over 3 years):**

AWS Business Support plan, estimated at a minimum of $350/month from infrastructure-costs.csv. This scales as a percentage of monthly AWS charges as the estate grows and provides 24×7 Cloud Support Engineers, <1-hour P1 response time, and access to the full AWS Trusted Advisor check suite.

## Payment Terms

Professional services are invoiced on a milestone basis tied to the project delivery schedule. The payment schedule is structured to align client payments with value delivered at each major project milestone.

| Payment Milestone | Amount | Trigger |
|------------------|--------|---------|
| Project Initiation (25%) | $74,610 | Contract signature |
| Phase 1 Complete (25%) | $74,610 | Architecture Design Review sign-off (Week 4) |
| Phase 2 Complete (25%) | $74,610 | Network Testing Report accepted (Week 8) |
| Go-Live & Hypercare End (25%) | $74,610 | UAT sign-off and Hypercare Closeout Report delivered (Week 16) |
| **Total Professional Services** | **$298,440** | |

*Note: Payment amounts reflect net figures after credits are applied. AWS infrastructure invoices are billed directly by AWS to the client's registered payment method on a monthly basis.*

## Invoicing & Expenses

Invoices are issued in USD within 5 business days of each milestone acceptance event. Payment terms are Net-30 from invoice date. Reimbursable expenses (travel, accommodation for on-site sessions) will be invoiced at cost with prior client approval. For a greenfield remote engagement, no travel is anticipated unless the client specifically requests on-site delivery sessions. Total reimbursable expenses will not exceed 5% of the professional services engagement value without written client approval in advance.

---

# Terms & Conditions

This Statement of Work is governed by, and incorporated into, the Master Services Agreement (MSA) executed between the client and Amatra. In the event of any conflict between this SOW and the MSA, the MSA terms shall prevail unless this SOW explicitly states otherwise in writing.

## General Terms

This SOW constitutes the full definition of services, deliverables, and commercial terms for the AWS Multi-Account Landing Zone engagement. This SOW becomes effective on the date of signature by both authorised parties and remains in effect until all deliverables are accepted and the hypercare period concludes, or until the SOW is terminated per the terms below. All work performed under this SOW shall be subject to the terms and conditions of the MSA, including but not limited to confidentiality, intellectual property, insurance, and dispute resolution provisions.

## Scope Changes

Any request to add, remove, or materially change the scope of services defined in this SOW must be submitted as a formal Change Request (CR). Change Requests must include a description of the proposed change, the impact on timeline, resources, and cost, and any updated scope parameters. Change Requests require written approval from the Client Executive Sponsor and the Amatra Project Manager before any work on the changed scope commences. Verbal agreements do not constitute approved scope changes. Work performed under an approved Change Request will be invoiced at the rates defined in the LOE estimate or as separately agreed in the CR.

## Intellectual Property

**Client Deliverables:** All project deliverables produced specifically for the client under this SOW — including architecture documents, runbooks, as-built documentation, and client-specific Terraform configurations — are the intellectual property of the client upon full payment of all invoices.

**Vendor Methodologies & Tooling:** Amatra retains all intellectual property rights in its pre-existing methodologies, frameworks, accelerators, reusable Terraform modules, and EO Framework tooling that may be incorporated into deliverables. The client is granted a perpetual, non-exclusive, royalty-free licence to use any such vendor components incorporated into the delivered artefacts for the client's own internal operations.

**Open-Source Components:** Certain components (e.g., AFT, Terraform providers) are open-source and subject to their respective licences (Apache 2.0, MPL 2.0). The client is responsible for ensuring ongoing compliance with open-source licence terms in production use.

## Service Levels

**Warranty Period:** Amatra warrants that all delivered components will function as described in the as-built documentation for a period of **60 days** following the go-live date. Warranty remediation is provided at no additional cost for defects attributable to the vendor delivery team.

**Hypercare SLAs** are defined in Section 9 (Handover & Support). Post-hypercare support, if required, is subject to a separate Managed Services Agreement.

## Liability

Each party's total aggregate liability to the other party under this SOW shall not exceed the total professional services fees paid under this SOW ($298,440 net). Neither party shall be liable for indirect, consequential, special, or punitive damages arising from the performance or non-performance of this SOW, except in cases of fraud, gross negligence, or wilful misconduct. Amatra's liability excludes any damages resulting from client-side changes made without vendor involvement, AWS service outages, or AWS service changes that affect the delivered configuration.

## Confidentiality

All information exchanged under this engagement, including client architecture details, financial information, security configurations, and business strategies, is treated as Confidential Information per the terms of the executed Non-Disclosure Agreement or the confidentiality provisions of the MSA. Both parties agree to maintain confidentiality for a period of 3 years following the conclusion of this SOW.

## Termination

Either party may terminate this SOW with 30 days written notice. In the event of termination by the client, the client agrees to pay for all work performed up to the notice date at the applicable rates, plus any non-cancellable commitments incurred by the vendor. In the event of termination for cause (material breach not remedied within 15 days of written notice), the non-breaching party may terminate immediately. Deliverables completed and accepted prior to termination transfer to the client upon payment of all outstanding invoices.

## Governing Law

This Statement of Work shall be governed by and construed in accordance with the laws of the State of Delaware, United States, without regard to its conflict of law provisions. Any disputes arising from this SOW that cannot be resolved through good-faith negotiation shall be submitted to binding arbitration in accordance with the rules of the American Arbitration Association.

---

# Sign-Off

This Statement of Work, together with the Master Services Agreement, constitutes the complete and binding agreement between the parties for the services described herein. By signing below, both parties confirm that they have read, understood, and agree to the scope, deliverables, roles, commercial terms, and conditions set out in this document. No work shall commence under this SOW until both parties have executed this signature page.

**Client Authorised Signatory:**

Name: __________________________
Title: __________________________
Organisation: __________________________
Signature: ______________________
Date: __________________________

---

**Service Provider Authorised Signatory (Amatra):**

Name: __________________________
Title: __________________________
Organisation: Amatra
Signature: ______________________
Date: __________________________

---

*This Statement of Work constitutes the complete agreement between the parties for the professional services described herein and supersedes all prior negotiations, representations, or agreements relating to the subject matter. No modification to this SOW shall be effective unless made in writing and signed by authorised representatives of both parties.*

*Document Reference: OPP-2024-001 | Version 1.0 | January 2025*
*Prepared using the Amatra EO Framework — Pre-Sales Artifact Generator*
