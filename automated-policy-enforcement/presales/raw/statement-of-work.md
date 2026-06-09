---
document_title: Statement of Work
technology_provider: aws
project_name: AWS Cloud Governance Platform — Contoso Financial
client_name: Contoso Financial
client_contact: Priya Nair | Head of Platform Engineering
consulting_company: Amatra
consultant_contact: Solutions Delivery Lead | delivery@amatra.com.au
opportunity_no: OPP-2025-001
document_date: June 2025
version: 1.0
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Statement of Work (SOW) defines the scope, deliverables, roles, and commercial terms for the delivery of the **AWS Cloud Governance Platform** for Contoso Financial. This engagement will design, build, and validate a fully automated, policy-enforced cloud governance foundation on AWS — replacing manual provisioning and fragmented controls with a governed multi-account landing zone, infrastructure-as-code pipelines, and an audit-ready compliance posture aligned to ISO 27001 and Contoso Financial's internal security baseline.

Contoso Financial operates under national financial services compliance standards and is facing a hard regulatory review deadline in Q2 2026. The current environment is provisioned manually with shared administrative credentials and no automated policy enforcement, generating 3–4 compliance findings per quarter and significant audit remediation overhead. This engagement delivers the controls, automation, and evidence collection infrastructure required to achieve a clean regulatory review before the end of April 2026.

**Project Duration:** 4 months (16 weeks)

**Key Outcomes:**
- AWS Control Tower landing zone deployed with structured OU hierarchy across ap-southeast-2 (primary) and ap-southeast-4 (DR)
- Automated account vending pipeline (IaC) integrated with existing ITSM change-approval workflow
- Preventive (SCP) and detective (AWS Config) guardrails enforced across all accounts — no manual console access in production
- IAM Identity Center federation with on-premises enterprise directory — no shared credentials
- Centralised Security Hub, GuardDuty, and CloudTrail audit trail with 12-month log retention
- Existing SIEM and ticketing platform integrated for security alerting and change governance
- ISO 27001 compliance evidence package compiled and ready for regulatory submission
- 8-week hypercare support covering the regulatory review period

**Expected Benefits:**
- **80% reduction in audit remediation effort** — automated Config rules and auto-remediation eliminate manual findings before they reach auditors
- **Zero compliance findings** from the Q2 2026 regulatory review — evidence collected continuously from day one of Phase 2
- **Provisioning time reduced from days to under 4 hours** — account vending pipeline replaces manual processes
- **Eliminated credential-sharing risk** — IAM Identity Center federation enforces individual, role-based access with full audit trail
- **Full data sovereignty assurance** — all data and control-plane activity remains within Australia (ap-southeast-2 and ap-southeast-4)
- **Ongoing run cost of ~$34K/year** for cloud infrastructure, tooling, and support after Year 1 implementation credits

---

# Background & Objectives

Contoso Financial is an Australian retail bank with approximately 4,500 employees, operating across two data centres and an established but fragmented AWS cloud footprint. The organisation is regulated under national financial services compliance standards and has committed to achieving a clean ISO 27001 regulatory review by the end of April 2026.

## Current State

The platform engineering team — led by Priya Nair (Head of Platform Engineering) — currently manages all cloud environments manually. There is no automated provisioning pipeline, no policy-as-code guardrails, and no centralised compliance monitoring. Key challenges include:

- **Manual Provisioning:** Cloud environments are created manually by the platform team with shared administrative credentials, creating security exposure and inconsistency between environments.
- **No Policy Enforcement:** There are no Service Control Policies (SCPs) or AWS Config rules preventing non-compliant actions. Console access is unrestricted in production.
- **Recurring Compliance Findings:** The current state generates 3–4 compliance findings per quarter, each requiring manual investigation and remediation — a cycle that consumes significant platform team capacity.
- **No Centralised Audit Trail:** CloudTrail is not configured centrally across all accounts. There is no centralised log archive with tamper-evident retention, making it difficult to produce audit evidence on demand.
- **Fragmented Identity:** Authentication relies on an on-premises identity provider, but federation into AWS is incomplete. Individual identity accountability in the cloud is not consistently enforced.
- **No ITSM-Gated Change Process:** Changes to cloud infrastructure do not flow through the existing ITSM ticketing platform, meaning change approval governance is inconsistent and unauditable.

## Business Objectives

The following objectives define the strategic outcomes this engagement must deliver for Contoso Financial, each tied directly to the Q2 2026 regulatory deadline and the organisation's risk reduction mandate:

- **Eliminate Audit Risk:** Implement automated preventive and detective controls that prevent non-compliant configurations from persisting, reducing quarterly compliance findings to zero before the April 2026 deadline.
- **Automate Environment Provisioning:** Replace manual, credential-sharing provisioning with an IaC-based account vending machine that creates environments consistently and in alignment with the security baseline.
- **Enforce Zero-Trust Identity:** Federate the existing on-premises IdP with AWS IAM Identity Center to eliminate shared credentials and enforce individual, role-based access with full audit attribution.
- **Establish Continuous Compliance Evidence:** Configure Security Hub, Config, and CloudTrail to produce continuous, tamper-evident compliance evidence that can be presented to auditors without manual preparation.
- **Integrate with Existing Tooling:** Connect the new governance platform with Contoso Financial's existing SIEM and ITSM platforms to ensure security alerting and change approval workflows are seamlessly embedded in existing operations.
- **Ensure Data Sovereignty:** Guarantee all data, control-plane activity, and audit logs remain within Australian AWS regions (ap-southeast-2 and ap-southeast-4) at all times.

## Success Metrics

The following measurable criteria define successful delivery of this engagement. Each metric is directly traceable to a business objective and will be validated during Phase 3 testing and sign-off:

- Zero compliance findings from the Q2 2026 regulatory review (hard deadline: April 30, 2026)
- 80% reduction in audit remediation effort measured by platform team hours per audit cycle
- 100% of production accounts governed by SCPs with no manual console access permitted (break-glass procedure excepted)
- All new environment provisioning completed via IaC account vending pipeline with ITSM change-approval gate
- IAM Identity Center federation live with on-premises IdP; zero shared administrative credentials in AWS
- Security Hub findings forwarded to existing SIEM within 5 minutes of detection
- ISO 27001 compliance evidence package produced and validated before end of Phase 3 (Month 4)
- DR failover validated with RTO < 4 hours and RPO < 1 hour before regulatory review

---

# Scope of Work

This engagement delivers a comprehensive AWS Cloud Governance Platform for Contoso Financial, covering landing zone foundation, automated provisioning, policy-as-code guardrails, identity federation, and compliance evidence collection across two AWS regions. The following table defines the key parameters that bound the scope of this engagement.

## In Scope

The following services and deliverables are included in this SOW:

- AWS Control Tower landing zone deployment with structured OU hierarchy in ap-southeast-2 (primary)
- DR baseline mirror deployment in ap-southeast-4 with cross-region replication for Config, CloudTrail, and Security Hub
- IaC account vending pipeline (Account Factory for Terraform / AFT) with ITSM change-approval integration
- Preventive guardrails via Service Control Policies (SCPs): no console access in production, region lock, encryption enforcement
- Detective guardrails via AWS Config conformance packs aligned to ISO 27001 and internal security baseline
- Centralised Security Hub, GuardDuty, and CloudTrail configuration with 12-month tamper-evident S3 log archive
- IAM Identity Center federation with on-premises enterprise directory (1 IdP connector)
- SIEM integration: Security Hub findings and CloudTrail events forwarded to existing on-premises SIEM
- ITSM workflow integration: change-approval gating for account vending and guardrail changes via existing ticketing platform
- Onboarding of three existing production environments into the new account structure
- Network infrastructure: Transit Gateway, VPC topology, Direct Connect connectivity to on-premises data centres
- ISO 27001 compliance evidence package for regulatory submission
- Operational runbooks, architecture documentation, and knowledge transfer to platform team
- 8-week post-go-live hypercare support (covering the April 2026 regulatory review period)

### Scope Parameters

This engagement is sized based on the following parameters:

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | AWS Accounts (at go-live) | Management + Log Archive + Audit + Security + Network + 3 Workload (8 accounts) |
| Solution Scope | Managed Environments | 3 production environments + dev/test/staging sets |
| Solution Scope | Config Rules (Policy-as-Code) | ~80 rules (ISO 27001 conformance pack + internal baseline) |
| Solution Scope | AWS Regions | ap-southeast-2 (primary) + ap-southeast-4 (DR) |
| Integration | ITSM Integrations | 1 existing ticketing platform (change-approval workflow) |
| Integration | SIEM Integrations | 1 on-premises SIEM (Security Hub + CloudTrail forwarding) |
| Identity | IdP Federation Links | 1 on-premises IdP via IAM Identity Center |
| User Base | Platform Team Users | ~150 platform team + workload account owners |
| Data Volume | CloudTrail Log Volume | ~50–200 GB/month (Medium tier) |
| Data Volume | Security Hub Findings | ~1,000 findings/month |
| Technical Environment | Infrastructure-as-Code Coverage | All new accounts and guardrails via IaC; legacy on-prem workloads excluded |
| Security & Compliance | Compliance Frameworks | ISO 27001 + Contoso Financial internal security baseline |
| Performance | Platform Availability Target | 99.9% for platform services; RTO < 4h / RPO < 1h for DR |
| Support | AWS Support Plan | Business (production regulatory requirement) |

Table: Engagement Scope Parameters

*Note: Changes to these parameters may require scope adjustment and additional investment through the change control process.*

## Out of Scope

These items are not included in this engagement unless added via formal change control:

- Migration or remediation of the two legacy on-premises workloads (explicitly excluded)
- Application refactoring, re-platforming, or code changes to existing workloads
- Replacement of the on-premises identity provider (federation only; the IdP remains in place)
- Management of the existing on-premises SIEM or ITSM platform (integration only)
- AWS Managed Services or ongoing CloudOps after the 8-week hypercare period (available under a separate Managed Services Agreement)
- Procurement or negotiation of AWS Direct Connect circuits (assumed to be ordered by Contoso Financial)
- Security penetration testing or red-team exercises beyond guardrail validation
- Compliance frameworks other than ISO 27001 and the internal security baseline (e.g., PCI-DSS, SOC 2)
- Cost optimisation reviews or FinOps engagements beyond the optimisation recommendations deliverable

## Activities

### Phase 1 – Discovery & Design (Weeks 1–6)

Phase 1 establishes a shared understanding of the current environment and produces all architecture and design artefacts required to begin implementation. This phase is critical to protecting the April 2026 deadline — design decisions made here define the guardrail framework, OU hierarchy, and federation architecture used throughout the engagement. The CISO sign-off gate at the end of Week 4 is a hard dependency for Phase 2.

Key activities:
- Project kickoff with James Wu (CTO), Priya Nair (Head of Platform Engineering), and Rachel Moore (IT Delivery Manager)
- Structured stakeholder interviews with platform team and CISO; document requirements and security baseline expectations
- Current-state assessment of existing AWS footprint, account structure, shared credentials, and IAM policies
- AWS Control Tower / Organizations readiness assessment; SCP and IAM gap analysis
- ISO 27001 control mapping to AWS services; documentation of evidence requirements for Q2 2026 review
- On-premises IdP assessment; design of IAM Identity Center federation and attribute mapping
- ITSM and SIEM integration assessment; definition of change-approval workflow and alert-forwarding patterns
- Gap analysis and risk register; presentation of findings to James Wu and Priya Nair
- Detailed architecture design: OU hierarchy, account structure, guardrail framework, DR topology, network, identity, security monitoring
- Architecture documentation package for CISO review and sign-off

**Deliverable:** Discovery & Assessment Report + Architecture Design Document (CISO sign-off gate)

### Phase 2 – Build & Integrate (Weeks 7–12)

Phase 2 implements the full governance platform in ap-southeast-2, establishes the DR baseline in ap-southeast-4, and integrates with Contoso Financial's existing tooling. All workload onboarding occurs in this phase, with production changes gated through the ITSM change-approval workflow and approved by the CISO.

Key activities:
- Deploy AWS Control Tower in ap-southeast-2: management account, log archive, audit accounts, OU hierarchy
- Develop and deploy IaC account vending pipeline (AFT) with ITSM change-approval-gated provisioning
- Build reusable Terraform module library: VPC, IAM roles, logging, tagging, environment baseline
- Implement preventive SCPs: block console access in production, restrict disallowed services, enforce encryption at rest and in transit
- Deploy AWS Config conformance packs (ISO 27001) and custom Config rules for internal security baseline; configure auto-remediation
- Configure centralised Security Hub, GuardDuty, and CloudTrail with S3 log archive and log integrity validation
- Implement SIEM integration: forward Security Hub findings and CloudTrail events to existing SIEM
- Configure IAM Identity Center; federate with on-premises IdP; deploy permission sets and SSO application assignments
- Develop ITSM workflow integration: change-approval routing and notifications for account vending
- Deploy DR baseline in ap-southeast-4: mirrored Control Tower baseline, cross-region Config/CloudTrail/Security Hub replication
- Deploy Transit Gateway, VPC topology, and Direct Connect connectivity to on-premises data centres
- Onboard three existing production environments into new account structure (staged, with ITSM change windows)
- Implement CI/CD GitOps pipeline for IaC with automated policy compliance checks
- Configuration and operations guide documentation

**Deliverable:** Fully deployed governance platform + Configuration and Operations Guide

### Phase 3 – Testing, Validation & Handover (Weeks 13–16)

Phase 3 validates all controls against the ISO 27001 framework, conducts DR failover testing, executes UAT with the platform team and CISO, and hands over the platform to Contoso Financial's internal teams. The compliance evidence package produced in this phase is the primary input to the Q2 2026 regulatory review.

Key activities:
- Develop and execute test plan: account provisioning, guardrail enforcement, identity federation, SIEM integration, DR failover
- Validate preventive SCPs block prohibited actions; confirm detective Config rules fire and trigger auto-remediation
- Validate SSO login flows, permission set assignments, and break-glass access procedure
- Validate SIEM ingestion of Security Hub findings and CloudTrail events
- Execute ISO 27001 control checklist; produce and validate compliance evidence package for regulatory submission
- DR failover drill: validate RTO < 4 hours and RPO < 1 hour; document test results as regulatory evidence
- UAT with platform team and CISO; obtain sign-off on all controls before production cutover
- Operational runbook delivery: account vending, guardrail management, break-glass, DR failover
- Knowledge transfer sessions with platform team (IaC pipeline, Security Hub, IAM Identity Center operations)
- Administrator training: day-to-day operations, evidence collection, audit procedures
- Project closeout: retrospective, lessons learned, optimisation recommendations
- Commence 8-week hypercare support period

**Deliverable:** Test Results & Compliance Evidence Package + Operational Runbook Suite + Hypercare Support Commencement

---

# Deliverables & Timeline

This section defines all formal deliverables and major project milestones for the four-month engagement. Each deliverable has a defined type, target completion week, and acceptance authority. Acceptance requires written sign-off from the designated authority within five business days of delivery.

## Deliverables

All deliverables below are formally accepted in writing by the designated authority before the next project phase may commence. Deliverables are numbered sequentially for traceability in the ITSM change log and project status reports.

<!-- TABLE_CONFIG: widths=[5, 42, 12, 18, 23] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|-------------|------|----------|---------------|
| 1 | Project Kickoff Deck & RAID Log | Document | Week 1 | Rachel Moore |
| 2 | Current State Assessment Report | Document | Week 3 | Priya Nair |
| 3 | Cloud Readiness & Gap Analysis | Document | Week 4 | Priya Nair / CISO |
| 4 | ISO 27001 Control Mapping Matrix | Document | Week 4 | CISO |
| 5 | Architecture Design Document (with diagrams) | Document | Week 5 | CISO |
| 6 | IaC Module Library (Terraform) | System | Week 9 | Priya Nair |
| 7 | AWS Control Tower Landing Zone (ap-southeast-2) | System | Week 9 | Priya Nair |
| 8 | Account Vending Machine (AFT + ITSM integration) | System | Week 10 | Priya Nair |
| 9 | Preventive & Detective Guardrails (SCPs + Config) | System | Week 10 | CISO |
| 10 | IAM Identity Center Federation (on-prem IdP) | System | Week 11 | CISO |
| 11 | Centralised Security Hub, GuardDuty & CloudTrail | System | Week 11 | CISO |
| 12 | SIEM Integration (Security Hub → on-prem SIEM) | System | Week 11 | Priya Nair |
| 13 | DR Baseline (ap-southeast-4 + cross-region replication) | System | Week 12 | Priya Nair |
| 14 | Network Infrastructure (Transit Gateway + Direct Connect) | System | Week 12 | Priya Nair |
| 15 | Production Environment Onboarding (3 environments) | System | Week 12 | Priya Nair / CISO |
| 16 | CI/CD GitOps Pipeline for IaC | System | Week 12 | Priya Nair |
| 17 | Configuration and Operations Guide | Document | Week 12 | Priya Nair |
| 18 | Test Plan | Document | Week 13 | Rachel Moore |
| 19 | Test Results & Compliance Evidence Package | Document | Week 15 | CISO |
| 20 | DR Failover Test Report (RTO/RPO validated) | Document | Week 15 | CISO |
| 21 | Operational Runbook Suite | Document | Week 15 | Priya Nair |
| 22 | Knowledge Transfer Sessions (recorded + materials) | Training | Week 16 | Priya Nair |
| 23 | Administrator Training Sessions | Training | Week 16 | Priya Nair |
| 24 | Platform Optimisation Roadmap | Document | Week 16 | James Wu |
| 25 | Project Closeout Report | Document | Week 16 | Rachel Moore |

## Project Milestones

The milestones below mark the completion of major phases and critical decision gates. Each milestone must be formally acknowledged before the subsequent phase activities begin; any milestone delay is escalated immediately to Rachel Moore and James Wu for timeline impact assessment.

<!-- TABLE_CONFIG: widths=[20, 55, 25] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 – Kickoff Complete | Project team aligned; RAID log established; AWS account access confirmed | End of Week 1 |
| M2 – Discovery Sign-Off | Current state assessment and gap analysis accepted by Priya Nair and CISO | End of Week 4 |
| M3 – Architecture Approved | Architecture Design Document signed off by CISO; Phase 2 cleared to begin | End of Week 6 |
| M4 – Landing Zone Live | Control Tower deployed; OU hierarchy established; log archive and audit accounts active | End of Week 9 |
| M5 – Guardrails Enforced | SCPs and Config rules active; no console access enforced in production; ITSM workflow integrated | End of Week 10 |
| M6 – Identity Federated | IAM Identity Center live; on-premises IdP federated; shared credentials retired | End of Week 11 |
| M7 – Full Platform Live | All environments onboarded; DR baseline active; SIEM and ITSM integrations validated | End of Week 12 |
| M8 – UAT Sign-Off | CISO and platform team accept all controls; UAT sign-off obtained | End of Week 15 |
| M9 – Go-Live | Production governance platform fully operational; compliance evidence package delivered | End of Week 15 |
| M10 – Hypercare End | 8-week hypercare support period complete; platform fully handed to Contoso Financial | Week 24 (8 weeks post go-live) |

---

# Roles & Responsibilities

Clear role definition and accountability are essential to meeting the April 2026 regulatory deadline. This section defines responsibilities across Amatra's delivery team and Contoso Financial's internal stakeholders using a RACI matrix, and identifies the key personnel for each party.

## RACI Matrix

The table below assigns accountability for each major work stream and decision gate across the engagement. Every task row has exactly one Accountable (A) owner; Responsible (R) parties perform the work; Consulted (C) parties provide input; Informed (I) parties receive status updates.

<!-- TABLE_CONFIG: widths=[28, 9, 9, 9, 9, 9, 9, 9, 9] -->
| Task / Deliverable | Amatra PM | Amatra Arch | Amatra Eng | Amatra QA | Amatra Sec | Client PM | Client Tech | Client CISO |
|--------------------|-----------|-------------|------------|-----------|------------|-----------|-------------|-------------|
| Project Kickoff & Governance | A | C | I | I | I | R | C | I |
| Current State & Gap Assessment | C | A | R | I | R | I | C | C |
| Architecture Design & Sign-Off | I | A | C | I | R | I | C | R |
| IaC Module Library Development | I | C | A | C | C | I | R | I |
| Control Tower Deployment | I | A | R | C | C | I | C | I |
| Account Vending Machine (AFT) | I | C | A | C | I | I | R | I |
| SCP Guardrail Implementation | I | C | R | I | A | I | C | R |
| AWS Config Rules & Auto-Remediation | I | C | R | I | A | I | C | C |
| IAM Identity Center Federation | I | C | R | I | A | I | R | C |
| Centralised Security Monitoring (Hub/GD) | I | C | R | I | A | I | C | R |
| SIEM Integration | I | C | A | C | R | I | R | C |
| ITSM Workflow Integration | C | C | A | C | I | R | R | I |
| DR Region Deployment & Testing | I | A | R | C | C | I | C | I |
| Network Infrastructure (TGW/DC) | I | A | R | I | C | I | R | I |
| Production Environment Onboarding | C | C | A | C | C | R | R | R |
| Functional & Guardrail Testing | C | C | R | A | R | I | C | C |
| ISO 27001 Compliance Validation | I | C | C | R | A | I | C | R |
| UAT & CISO Sign-Off Gate | C | C | I | R | C | R | C | A |
| Knowledge Transfer & Training | C | C | R | I | C | R | A | I |
| Project Closeout & Handover | A | C | I | I | I | R | C | C |

**Legend:** R = Responsible | A = Accountable | C = Consulted | I = Informed

## Key Personnel

**Amatra Delivery Team:**
- **Project Manager (Amatra):** Overall delivery accountability; stakeholder reporting; risk and issue management; schedule and budget tracking across the 4-month engagement. Counterpart to Rachel Moore.
- **Lead Solution Architect:** Technical ownership across all phases; architecture design, CISO review sessions, and escalation point for all design decisions.
- **Senior Solutions Engineer (×2):** IaC module development; account vending machine; ITSM and SIEM integrations; CI/CD pipeline; production onboarding.
- **Cloud Engineer:** Control Tower deployment; DR region baseline; Transit Gateway and network infrastructure; Systems Manager no-console-access enforcement.
- **Senior Security Engineer:** SCP and Config guardrail design and implementation; IAM Identity Center federation; Security Hub and GuardDuty configuration; ISO 27001 control validation.
- **QA Engineer:** Test plan development; functional and compliance testing execution; test results documentation.
- **Technical Writer:** Architecture documentation; configuration guide; operational runbooks; test results package.

**Contoso Financial Team:**
- **James Wu (CTO):** Executive sponsor and budget owner; approves major scope changes; receives project status at key milestones.
- **Priya Nair (Head of Platform Engineering):** Technical lead and primary day-to-day contact; approves architecture deliverables; participates in knowledge transfer.
- **Rachel Moore (IT Delivery Manager):** Project management counterpart; coordinates client-side actions; approves cutover plans and runbook deliveries.
- **CISO (Name TBC):** Security sign-off authority; approves architecture design before Phase 2; accepts guardrail and compliance evidence deliverables.
- **On-Premises IdP Team:** Required for federation design workshop (Week 3) and federation configuration sessions (Week 11).
- **SIEM / ITSM Administrators:** Required to provide API credentials, endpoint documentation, and co-ordination for integration work.

---

# Architecture & Design

This section describes the technical architecture of the AWS Cloud Governance Platform, covering the landing zone foundation, component structure, network design, security controls, data architecture, operational approach, and tooling. The architecture is designed to meet Contoso Financial's data sovereignty requirements (all data in-country), ISO 27001 compliance obligations, and the no-manual-console-access mandate for production environments.

## Architecture Overview

The AWS Cloud Governance Platform is built on AWS Control Tower as the multi-account management foundation, with Account Factory for Terraform (AFT) providing automated, IaC-driven account vending. The architecture adopts a hub-and-spoke model: a centralised Network Account hosts Transit Gateway and AWS Network Firewall, through which all account-to-account and account-to-on-premises traffic flows. Governance, logging, and security monitoring are centralised in dedicated management accounts, with all data stored in ap-southeast-2 (primary) and replicated to ap-southeast-4 (DR) to maintain in-country data residency.

Policy enforcement operates at two layers. Preventive controls are implemented via Service Control Policies (SCPs) attached to Organizational Units — blocking console access in production, restricting services to approved AWS regions, and enforcing encryption. Detective controls are implemented via AWS Config conformance packs aligned to ISO 27001, with custom rules for Contoso Financial's internal security baseline and automated Lambda-based remediation for identified deviations. This dual-layer model ensures violations are either prevented before they occur or detected and remediated within minutes.

Identity is federated from the on-premises enterprise directory via AWS IAM Identity Center, eliminating shared credentials and enforcing individual, role-based access attribution across all accounts. All activity is captured in CloudTrail with log integrity validation, centralised to an immutable S3 log archive in the Log Archive account, and forwarded to the existing on-premises SIEM. The result is a continuously operating compliance evidence engine that eliminates the need for manual audit preparation.

![Figure 1: Solution Architecture Diagram](../../assets/diagrams/architecture-diagram.png)

**Figure 1: AWS Cloud Governance Platform Architecture** — Multi-account landing zone with Control Tower, AFT account vending, SCP/Config guardrails, IAM Identity Center federation, hub-and-spoke Transit Gateway network, centralised security monitoring, and dual-region (ap-southeast-2/ap-southeast-4) in-country deployment.

## Component Architecture

The platform is structured around a set of specialised AWS accounts within a defined Organizational Unit hierarchy under AWS Control Tower.

**Management Account:** Root of the AWS Organizations hierarchy. Hosts Control Tower, the AFT pipeline orchestration, and organisational SCPs. No workloads run in this account. Access is restricted to break-glass procedures only.

**Log Archive Account:** Centralised S3 bucket receiving CloudTrail management and data events, AWS Config history, and Security Hub finding exports from all accounts. S3 Object Lock (WORM mode) enforces 12-month tamper-evident retention. Cross-region replication to ap-southeast-4 provides DR coverage.

**Audit Account:** Hosts AWS Security Hub (aggregated across all accounts), GuardDuty (organisational detector), AWS Config aggregator, and Access Analyzer. Security Hub findings are forwarded to the existing on-premises SIEM via EventBridge and a Lambda integration function.

**Security Account:** Hosts IAM Identity Center (SSO portal), permission set assignments, and the SAML 2.0 federation connector to the on-premises enterprise directory.

**Network Account:** Hosts Transit Gateway, VPC attachments, AWS Network Firewall, and Route 53 Resolver rules. Direct Connect connections from both Contoso Financial data centres terminate in this account. All inter-account and on-premises traffic is routed through Network Firewall for inspection and logging.

**Workload Accounts (Vended via AFT):** Each environment (dev, test, staging, production tiers) is provisioned as a separate AWS account using the AFT pipeline. Each account is born with a standard baseline applied by AFT: tagging, VPC module, IAM roles, CloudTrail enablement, and Security Hub enrollment. Account vending requests are initiated via the ITSM ticketing platform and require ITSM change-approval before the AFT pipeline executes.

**DR Baseline (ap-southeast-4):** A mirrored Control Tower baseline is deployed in ap-southeast-4 for data sovereignty and disaster recovery. S3 cross-region replication, Config replication, and Security Hub cross-region aggregation ensure all audit artefacts and compliance posture data are continuously replicated in-country.

## Network Design

The network adopts a hub-and-spoke topology with the Network Account as the hub. AWS Transit Gateway in ap-southeast-2 connects all workload account VPCs, the security and audit account VPCs, and the on-premises data centres via AWS Direct Connect. A second Transit Gateway in ap-southeast-4 provides DR connectivity.

Two 1 Gbps Direct Connect hosted connections are provisioned — one to ap-southeast-2 (primary) and one to ap-southeast-4 (DR) — providing dedicated, private connectivity from Contoso Financial's data centres to AWS. A Site-to-Site VPN provides a resilient backup path for management and federation traffic. All traffic between accounts and between on-premises and AWS is routed through Network Firewall in the Network Account, providing east-west traffic inspection, intrusion detection, and egress filtering.

VPCs within workload accounts use non-overlapping RFC 1918 address space, allocated centrally to avoid conflicts as new accounts are vended. Route propagation through Transit Gateway is controlled via route tables, ensuring workload accounts cannot communicate peer-to-peer without transiting the Network Account. Internet-bound traffic from workload accounts is blocked by default; outbound access (for patch management via Systems Manager) routes through the Network Account's NAT Gateway.

## Security Design

The security architecture is structured around three layers of control: preventive, detective, and responsive.

**Preventive Controls:** Service Control Policies (SCPs) are the outermost guardrail layer, applied at the OU level via AWS Organizations. SCPs enforce no-console-access in production OUs (blocking IAM user creation and console sign-in), restrict all services to ap-southeast-2 and ap-southeast-4 (region lock), mandate encryption at rest for S3, RDS, and EBS, and deny disabling CloudTrail or Config. These controls cannot be overridden by any account-level IAM policy, including by account administrators.

**Detective Controls:** AWS Config conformance packs implementing ISO 27001 controls and Contoso Financial's internal security baseline monitor configuration compliance continuously across all accounts. Custom Config rules enforce additional controls specific to the internal baseline. GuardDuty provides threat intelligence-based anomaly detection across all accounts under an organisational detector. Security Hub aggregates findings from Config, GuardDuty, and Access Analyzer, providing a unified compliance and threat posture dashboard.

**Identity Security:** IAM Identity Center enforces federated, individual identity for all AWS access. Permission sets are role-based (Developer, Operator, SecurityViewer, BreakGlass) and follow least-privilege principles. MFA is enforced at the on-premises IdP level. A documented break-glass procedure allows emergency console access under strict conditions — access is time-limited, requires CISO approval, and is fully logged to the Log Archive account.

**Responsive Controls:** Auto-remediation Lambda functions are triggered by non-compliant Config rule findings for a defined set of low-risk remediations (e.g., enabling S3 versioning, enforcing encryption). Higher-severity findings generate Security Hub alerts forwarded to the SIEM, where existing incident response workflows are triggered.

## Data Architecture

All data generated and processed by the governance platform remains within Australia at all times, satisfying Contoso Financial's data sovereignty requirements.

**Control Plane Logs:** CloudTrail management and data events are written to the Log Archive account's centralised S3 bucket in ap-southeast-2. S3 Object Lock (Compliance mode, 12-month retention) ensures immutability. Cross-region replication to ap-southeast-4 provides a DR copy. All log files are encrypted using AWS-managed KMS keys.

**Compliance State:** AWS Config configuration snapshots and compliance history are stored in the Log Archive S3 bucket alongside CloudTrail logs. Config data is replicated to ap-southeast-4 via Config's cross-region aggregation feature.

**Security Findings:** Security Hub findings are stored within the Audit account and exported to S3 (Log Archive bucket) at regular intervals for long-term retention and regulatory evidence. Findings are also forwarded in near real-time to the existing SIEM for operational triage.

**Platform State:** Terraform state files for all IaC modules are stored in an S3 backend within the Management account with versioning and DynamoDB state locking. All state buckets are encrypted and access-controlled to the AFT pipeline IAM role.

**Data Classification:** The governance platform processes metadata (configuration state, access logs, findings) only — no application data or customer data flows through the governance accounts. All platform data is classified as Internal or Confidential (operational metadata), with no PII or sensitive financial data in scope for this engagement.

## Operational Design

**Observability:** Amazon CloudWatch aggregates platform service metrics (Lambda invocations, Config rule evaluations, EventBridge delivery, AFT pipeline execution) from the Management and Audit accounts. CloudWatch dashboards provide platform team visibility into provisioning pipeline health, guardrail compliance trends, and security finding volumes. Metric alarms alert on pipeline failures, Config rule evaluation errors, and elevated finding rates. All CloudWatch logs are retained for 90 days; structured log exports to S3 extend retention to 12 months.

**Backup and DR:** Platform state (Terraform state, DynamoDB workflow tables, S3 configuration buckets) is protected by AWS Backup with daily snapshots and a 30-day retention policy. The DR baseline in ap-southeast-4 provides a ready-to-activate replica of the governance platform. DR failover procedures are documented in the Operational Runbook Suite and validated with a failover drill during Phase 3.

**RTO / RPO:** The platform targets an RTO of < 4 hours and an RPO of < 1 hour for the governance platform itself. Continuous S3 cross-region replication (sub-minute lag for log data) and Config replication ensure RPO is met. RTO is validated via the Phase 3 DR failover test.

**Patch Management:** AWS Systems Manager Fleet Manager replaces console-based instance management. SSM Session Manager enforces no-direct-SSH/RDP access to any managed instances, satisfying the no-console-access mandate. Patch Manager is configured with a monthly patching baseline for all platform instances.

## Tooling Overview

The table below summarises the primary tools employed across all phases of the engagement, covering both the build toolchain used by the Amatra delivery team and the operational tooling that Contoso Financial's platform team will own and operate post-handover.

<!-- TABLE_CONFIG: widths=[30, 35, 35] -->
| Category | Primary Tools | Purpose |
|----------|---------------|---------|
| Landing Zone & Governance | AWS Control Tower, AWS Organizations | Multi-account structure, OU hierarchy, guardrail management |
| Infrastructure-as-Code | Terraform Cloud Plus (AFT), AWS CloudFormation | Account vending, environment provisioning, IaC pipeline |
| Policy-as-Code | AWS Config, SCPs, Terraform Sentinel | Preventive and detective guardrails, ISO 27001 conformance |
| Identity & Access | AWS IAM Identity Center, on-prem IdP (SAML 2.0) | Federated identity, SSO, permission sets, break-glass |
| Security Monitoring | AWS Security Hub, GuardDuty, Access Analyzer | Threat detection, compliance posture, findings aggregation |
| Audit & Logging | AWS CloudTrail, Amazon S3 (WORM), AWS Config | Immutable audit trail, compliance evidence collection |
| SIEM Integration | Amazon EventBridge, AWS Lambda | Security Hub → on-prem SIEM forwarding pipeline |
| ITSM Integration | AWS Service Catalog, Lambda, existing ticketing platform | Change-approval-gated account vending workflow |
| Network | AWS Transit Gateway, Network Firewall, Direct Connect | Hub-spoke routing, traffic inspection, private DC connectivity |
| Observability | Amazon CloudWatch, AWS Systems Manager | Platform health dashboards, alerting, patch management |
| Version Control & CI/CD | Git, Terraform Cloud (VCS-backed workspaces) | IaC pipeline, policy compliance checks, GitOps deployment |
| DR & Backup | AWS Backup, S3 Cross-Region Replication | Platform state protection, in-country DR replica |

---

# Security & Compliance

Security and compliance are first-order concerns for this engagement. Contoso Financial operates in a regulated financial services environment with an ISO 27001 obligation and an imminent regulatory review. Every architectural and implementation decision is made with the requirement to produce audit-ready, tamper-evident compliance evidence as a primary output.

## Identity & Access Management

All human access to AWS is federated through AWS IAM Identity Center (AWS SSO) using the existing on-premises enterprise directory as the authoritative identity provider. SAML 2.0 federation maps on-premises directory groups to IAM Identity Center groups, which are bound to permission sets. This eliminates AWS IAM users with long-lived credentials and shared passwords entirely.

Permission sets follow least-privilege principles and are scoped by role: Developers have read access to their own workload accounts; Platform Operators have write access to non-production accounts via IaC pipeline roles only; Security Viewers have read-only access to Security Hub and Config in the Audit account; and BreakGlass access is a time-limited emergency role requiring explicit CISO approval and generating immediate SIEM alerts upon use.

MFA is enforced at the on-premises IdP level for all users before SAML assertions are issued to AWS. No IAM users, access keys, or console passwords exist in any account except the Management account break-glass role. All AWS API calls made by automation are attributed to IAM roles assumed via the AFT pipeline, with session tagging providing full attribution in CloudTrail.

## Monitoring & Threat Detection

AWS Security Hub is configured as an organisational service with findings aggregated from all accounts into the Audit account. Security Hub standards enabled include: AWS Foundational Security Best Practices, CIS AWS Foundations Benchmark, and a custom standard implementing Contoso Financial's internal security baseline. All findings are scored and prioritised; findings of CRITICAL or HIGH severity trigger immediate EventBridge-based forwarding to the on-premises SIEM.

GuardDuty is enabled under an organisational detector in the Audit account, with automatic member enrollment for all new accounts created by AFT. GuardDuty detects threat patterns including compromised credentials, unusual API call patterns, cryptocurrency mining activity, and data exfiltration indicators. GuardDuty findings are ingested into Security Hub and treated consistently with Config compliance findings for SIEM forwarding and evidence purposes.

Amazon CloudWatch metric alarms alert the platform team to operationally significant events: Config rule evaluation failures, AFT pipeline errors, elevated Security Hub finding rates, and GuardDuty detector disruption. SNS notifications route alerts to the on-call platform engineer during business hours.

## Compliance & Auditing

The platform implements continuous compliance monitoring against ISO 27001 through AWS Config conformance packs. The conformance pack maps Config rules to ISO 27001 Annex A controls, producing a control-by-control compliance report that can be exported on demand for audit submission. Custom Config rules address Contoso Financial's internal security baseline controls that are not covered by the standard ISO 27001 conformance pack.

CloudTrail is enabled for management and data events across all accounts and all regions (with ap-southeast-2 and ap-southeast-4 as primary data destinations). CloudTrail log files are delivered to the Log Archive account's S3 bucket with S3 Object Lock (Compliance mode, 12-month retention), SHA-256 log file integrity validation, and SNS notification on delivery. This produces a tamper-evident audit trail that satisfies regulatory requirements for evidence immutability.

A compliance evidence package is compiled during Phase 3, comprising: Config conformance pack compliance reports, CloudTrail log completeness attestation, GuardDuty finding reports, Security Hub trend analysis, and DR test results. This package is structured for direct submission to the Q2 2026 regulatory review.

## Encryption & Key Management

All data at rest is encrypted using AWS KMS: S3 buckets (Log Archive, Terraform state, Config snapshots), DynamoDB tables (workflow state), and EBS volumes (platform instances). KMS key policies restrict decryption to authorised service roles only; no human identity has direct KMS key administrative access in production. Key rotation is enabled with an annual rotation schedule.

All data in transit uses TLS 1.2 or higher. Direct Connect connections use MACsec encryption for in-transit protection of management and federation traffic. S3 bucket policies enforce `aws:SecureTransport` conditions, rejecting any non-HTTPS requests. All HTTPS endpoints use certificates managed through AWS Certificate Manager.

## Governance

Policy governance is enforced through SCPs at the OU level, which override all account-level IAM policies. SCP changes require a change request raised in the ITSM platform, reviewed by the Security Engineer, and approved by the CISO before deployment via the AFT pipeline. No SCP can be modified via the AWS console in the Management account; all changes are IaC-driven and tracked in the Git repository.

A change freeze is enforced during the 14 days preceding the Q2 2026 regulatory review. During this period, only break-glass emergency changes are permitted, and all such changes trigger immediate CISO notification. The change freeze window is embedded in the ITSM change calendar and enforced via SCP conditions that deny AFT pipeline execution without an approved ITSM change record during the freeze period.

## Environments & Access

### Environment Strategy

The following table defines the purpose, access controls, and data classification for each environment tier in the governance platform:

<!-- TABLE_CONFIG: widths=[20, 28, 27, 25] -->
| Environment | Purpose | Access Control | Data |
|-------------|---------|----------------|------|
| Development | Developer sandbox; feature and IaC module development | Developer permission set (read/write own account only) | Synthetic / test data only |
| Non-Production (Test/Staging) | Integration testing, UAT, compliance pre-validation | Operator permission set; no production data; ITSM change required | Anonymised / synthetic data |
| Production | Live workloads; compliance evidence collection | No console access enforced by SCP; change via AFT pipeline + ITSM only | Production data; encrypted at rest and in transit |
| Audit / Security Accounts | Centralised security monitoring and log archive | SecurityViewer (read-only); no workloads permitted | Audit logs; Config snapshots; Security Hub findings |
| Management Account | Control Tower and AFT orchestration | BreakGlass only (MFA + CISO approval + full audit logging) | Platform state; IaC configuration |

### Access Policies

Production account access is gated entirely by SCPs — no IAM user or role in a production account can initiate a console session. All production changes are executed by the AFT pipeline using a scoped deployment role, following an approved ITSM change record. The break-glass procedure grants time-limited (4-hour maximum) administrative access to the Management account only, requires CISO approval via ITSM, generates a GuardDuty finding and immediate SIEM alert, and is fully logged to the Log Archive account.

Access reviews are conducted quarterly by the CISO: IAM Identity Center permission set assignments are reviewed against current role requirements, unused permission sets are revoked, and any dormant accounts are suspended. Access review results are documented and retained as compliance evidence.

---

# Testing & Validation

A comprehensive testing programme is executed in Phase 3 to validate that all platform controls meet the functional requirements, compliance obligations, and performance targets defined in this SOW. All testing is co-ordinated with Priya Nair's platform team and requires CISO sign-off before production go-live is approved.

## Functional Validation

Functional testing validates that all platform components operate as designed. Test cases are derived from the Architecture Design Document and cover:

- **Account Vending:** End-to-end provisioning of a new account via the AFT pipeline, including ITSM change-approval workflow, AFT execution, account baseline application, tagging compliance, and Security Hub enrollment. Success criteria: account provisioned within 60 minutes of ITSM approval with zero manual steps.
- **ITSM Integration:** Change request raised, approved, and consumed by AFT pipeline; rejection of requests without ITSM approval; notification routing to relevant approvers.
- **SIEM Integration:** Security Hub finding generated, forwarded via EventBridge and Lambda to SIEM, and correlated in SIEM within 5 minutes. CloudTrail event forwarding validated for a representative sample of API call types.
- **Identity Federation:** SSO login flows for all permission set roles; attribute mapping from on-premises directory groups to IAM Identity Center groups; session tag propagation to CloudTrail.

## Performance & Load Testing

The account vending pipeline is load-tested with concurrent provisioning requests to validate that no throttling or queuing occurs under expected peak load (5 concurrent account vending requests). Config rule evaluation performance is validated under simulated high finding rates to confirm Security Hub ingestion and SIEM forwarding pipelines are not throttled. CloudWatch metrics and Lambda concurrency utilisation are monitored throughout load testing.

## Security Testing

Guardrail enforcement testing validates the effectiveness of all preventive and detective controls:

- **SCP Validation:** Attempt to perform each SCP-blocked action from a production account (e.g., create IAM user, disable CloudTrail, launch resource in non-approved region). Each attempt must be denied with a clear `AccessDenied` exception and a corresponding CloudTrail event in the Log Archive.
- **Config Rule Validation:** Introduce a deliberate non-compliant configuration in a test account (e.g., unencrypted S3 bucket, public security group rule). Confirm Config rule fires within 60 seconds, finding appears in Security Hub, SIEM alert is generated, and auto-remediation triggers for applicable rules.
- **Break-Glass Procedure:** Execute break-glass access procedure end-to-end; confirm time-limited access grant, SIEM alert generation, and full CloudTrail logging of all actions taken during the break-glass session.
- **Vulnerability Assessment:** AWS Inspector scan of all platform instances and Lambda functions; Security Hub findings triaged and remediated before go-live sign-off.

## Disaster Recovery & Resilience Tests

A full DR failover drill is conducted during Phase 3 to validate the ap-southeast-4 baseline and confirm RTO/RPO targets are achievable:

- **DR Drill Procedure:** Simulate failure of the ap-southeast-2 primary region by switching Security Hub aggregation, Config aggregation, and CloudTrail delivery to ap-southeast-4. Confirm Log Archive bucket data is current (RPO < 1 hour from last replication). Activate DR region governance controls. Document time from drill start to fully operational DR governance platform (RTO target: < 4 hours).
- **S3 Replication Validation:** Confirm cross-region replication lag for the Log Archive bucket is within the RPO target under normal operating conditions (measured over a 24-hour period).
- **DR Test Report:** Documented results including actual RTO and RPO measurements, any issues encountered, and remediation actions. This report is included in the regulatory evidence package.

## User Acceptance Testing

UAT is conducted with Priya Nair's platform team during Weeks 14–15 of the engagement. The objective is to validate that the platform operates correctly from the perspective of its day-to-day operators and that all controls meet the CISO's security and compliance acceptance criteria before the production go-live decision is made.

Test scenarios cover representative day-to-day platform operations: requesting a new account via the ITSM portal, viewing compliance posture in Security Hub, reviewing CloudTrail audit logs, running a Config compliance report, and executing a simulated break-glass procedure. Each scenario is executed by a Contoso Financial platform engineer (not by the Amatra team), with Amatra providing facilitation and defect triage support only. UAT sign-off from both Priya Nair and the CISO is a hard gate for the M8 milestone and production go-live approval.

## Go-Live Readiness

Go-live is approved only when all of the following criteria are met:

- [ ] All functional test cases passed with no outstanding CRITICAL defects
- [ ] All SCP guardrails confirmed active on all production OUs
- [ ] IAM Identity Center federation live; zero shared credentials in production accounts
- [ ] Security Hub findings forwarded to SIEM and validated by SIEM team
- [ ] DR failover test completed with RTO and RPO within targets
- [ ] ISO 27001 compliance evidence package reviewed and accepted by CISO
- [ ] Operational runbooks delivered and accepted by Priya Nair
- [ ] CISO written sign-off obtained
- [ ] ITSM change record approved for production go-live

## Cutover Plan

Production go-live is executed across three production environments in staged cutover windows, each requiring a separate ITSM change record and CISO approval.

**Cutover Sequence:**

1. **Environment 1 Cutover (Week 15, Day 1):** Apply AFT baseline and guardrails to the first production environment during a pre-approved change window. Monitor for 2 hours post-cutover; validate no service interruption; confirm SCP enforcement active.
2. **Environment 2 Cutover (Week 15, Day 2):** Repeat process for the second production environment with identical monitoring protocol.
3. **Environment 3 Cutover (Week 15, Day 3):** Final production environment onboarded; full platform operational.
4. **Post-Cutover Validation (Week 15, Day 4–5):** Validate Security Hub enrollment for all three environments; confirm CloudTrail delivery to Log Archive; verify SIEM alert flow from all environments.

**Cutover Checklist (per environment):**
- [ ] ITSM change record approved and change window confirmed
- [ ] AFT pipeline executed; account baseline applied
- [ ] SCPs active; console access test (expect denial) confirmed
- [ ] IAM Identity Center permission sets assigned to platform team roles
- [ ] Security Hub enrollment confirmed; first finding visible in Audit account
- [ ] CloudTrail delivery confirmed to Log Archive bucket
- [ ] No service disruption reported by workload owners during 2-hour post-cutover monitoring

## Rollback Strategy

A rollback plan is documented for each production cutover. Rollback is triggered if any of the following conditions are met: (a) a workload-impacting service disruption is detected during the 2-hour post-cutover monitoring window; (b) a CRITICAL Security Hub finding is raised as a direct consequence of the cutover changes; or (c) the platform team lead (Priya Nair) or CISO calls a rollback.

**Rollback procedure:** The SCP deny for console access is removed via an emergency SCP change (break-glass procedure in Management account), restoring the pre-cutover access model within 30 minutes. AFT-applied baseline resources (IAM roles, Config rules) are not destructive to existing workloads and can be left in place during rollback without impact. The rollback is recorded in the ITSM platform and the production cutover is rescheduled for the following change window.

---

# Handover & Support

## Handover Artifacts

The following artefacts are delivered to Contoso Financial at the close of the engagement, transferring full operational ownership of the governance platform to the internal platform team:

- **Architecture Design Document:** Complete as-designed architecture diagrams, design decision log, and rationale for CISO and platform team reference
- **Configuration and Operations Guide:** Step-by-step reference for all platform configurations, including Control Tower settings, AFT pipeline variables, Config rule parameters, and IAM Identity Center configuration
- **Operational Runbook Suite:** Individual runbooks for account vending, guardrail management, break-glass procedure, SIEM alert triage, DR failover, and patch management
- **ISO 27001 Compliance Evidence Package:** Control mapping matrix, Config compliance reports, CloudTrail attestation, Security Hub trend report, DR test results — formatted for regulatory submission
- **IaC Module Library (Git repository):** All Terraform modules developed for this engagement, including AFT customisations, VPC modules, IAM role modules, and Config rule packs
- **CI/CD Pipeline Configuration:** GitOps pipeline configuration, including Terraform Cloud workspace settings, Sentinel policy definitions, and change-approval workflow configuration
- **Test Results Report:** All test cases, results, defects, and resolution evidence
- **Platform Optimisation Roadmap:** Recommendations for ongoing cost optimisation, guardrail enhancement, and compliance automation maturity
- **Project Closeout Report:** Engagement summary, lessons learned, and recommendations for future phases
- **Knowledge Transfer Session Recordings:** Recorded training sessions covering IaC pipeline, Security Hub operations, and IAM Identity Center administration

## Knowledge Transfer

Knowledge transfer is embedded across Phase 3 and structured to ensure Priya Nair's platform team can independently operate, maintain, and extend the governance platform after the engagement concludes.

**Session 1 – IaC Pipeline & Account Vending (4 hours):** Hands-on workshop covering AFT pipeline operation, Terraform workspace management, account vending request-to-provision flow, and ITSM integration. Participants: Platform Engineers.

**Session 2 – Guardrail Management (3 hours):** Walkthrough of SCP management, AWS Config rule library, auto-remediation function management, and the process for adding new guardrails via the IaC pipeline. Participants: Platform Engineers + CISO.

**Session 3 – Security Hub & Compliance Evidence (3 hours):** Hands-on training covering Security Hub dashboard navigation, finding triage, SIEM alert correlation, compliance report generation, and evidence package export. Participants: Platform Engineers + CISO.

**Session 4 – IAM Identity Center Operations (2 hours):** Walkthrough of permission set management, group-to-permission-set assignments, SSO application assignments, and the break-glass procedure. Participants: Platform Engineers + CISO.

All sessions are recorded and delivered to Contoso Financial along with slide decks and supporting documentation.

## Hypercare Support

An 8-week hypercare support period commences immediately upon production go-live. Hypercare is deliberately sized to cover the April 2026 regulatory review period, ensuring Amatra resources are available to assist with any audit queries, remediation actions, or platform tuning required during the critical review window.

**Duration:** 8 weeks (Weeks 17–24)
**Coverage:** Business hours (09:00–17:00 AEST), Monday to Friday
**Response Times:** P1 (platform outage or compliance-blocking issue) — 2-hour response; P2 (functional issue, non-blocking) — next business day response

**Scope includes:**
- Triage and resolution of platform defects identified post-go-live
- Guardrail tuning based on false-positive findings in production
- SIEM alert correlation refinement
- Assistance with regulatory review evidence queries
- Advisory support for new account vending requests

Out-of-scope items (new features, additional integrations) during hypercare are managed via change control.

**Hypercare End:** At the close of Week 24, Amatra will conduct a final handover call with Priya Nair and Rachel Moore, confirming the platform is stable, all hypercare items are resolved, and the platform team is self-sufficient.

## Managed Services Transition

Ongoing managed services are not included in this engagement. Refer to the separate Managed Services Agreement if Contoso Financial wishes to engage Amatra for ongoing CloudOps, guardrail management, or compliance monitoring services beyond the hypercare period.

## Assumptions

The following assumptions underpin the scope, timeline, and pricing of this engagement. Changes to any assumption may trigger a scope change under the Change Request process:

1. James Wu has executive budget authority and will provide a timely go/no-go decision to meet the April 2026 deadline.
2. Priya Nair is available as the primary technical contact for the duration of the engagement and can commit the equivalent of 25% of her time to the project.
3. The CISO (or a delegated security representative) is available for architecture sign-off by the end of Week 4 and for UAT sign-off by the end of Week 15.
4. Rachel Moore is available as Contoso Financial's project management counterpart for the duration of the engagement.
5. The on-premises IdP team is available for a federation design workshop during Week 3 and for federation configuration sessions during Week 11.
6. SIEM and ITSM administrators can provide API credentials, endpoint documentation, and technical co-ordination within two weeks of project kickoff.
7. Contoso Financial will procure and order AWS Direct Connect hosted connections for both ap-southeast-2 and ap-southeast-4 before the start of Phase 2. Lead times are the client's responsibility.
8. Read-only access to the existing AWS accounts and IAM reports will be provided to the Amatra team within five business days of kickoff.
9. ITSM change windows for the three production environment cutovers will be available in Week 15 of the engagement.
10. The two legacy on-premises workloads are genuinely out of scope and no AWS account management changes are required for them.
11. All new accounts and environments are greenfield; no data migration is required as part of this engagement.
12. Contoso Financial's procurement team will execute the AWS and Terraform Cloud contracts within 30 days of SOW execution.
13. The internal security baseline documentation is available for review during Week 1 of Discovery.
14. No application-level code changes to existing workloads are required as part of the production onboarding in Phase 2.
15. AWS MAP (Migration Acceleration Program) and AWS Partner Services Credits are confirmed by the AWS account team prior to engagement commencement.

## Dependencies

The following dependencies are critical-path items that, if delayed, will directly impact the project timeline and the April 2026 regulatory deadline. Each dependency is owned by either Amatra or Contoso Financial and has a hard delivery date tied to phase gates:

<!-- TABLE_CONFIG: widths=[5, 40, 20, 35] -->
| # | Dependency | Owner | Required By |
|---|-----------|-------|-------------|
| 1 | AWS Direct Connect circuits ordered and provisioned for ap-southeast-2 and ap-southeast-4 | Contoso Financial | Start of Phase 2 (Week 7) |
| 2 | CISO sign-off on Architecture Design Document | Contoso Financial CISO | End of Week 6 (Phase 2 gate) |
| 3 | On-premises IdP team availability for federation workshop and configuration | Contoso Financial | Week 3 (Discovery) and Week 11 (Development) |
| 4 | SIEM API credentials and endpoint documentation | Contoso Financial | Start of Week 9 (SIEM integration development) |
| 5 | ITSM API access and workflow documentation | Contoso Financial | Start of Week 8 (ITSM integration development) |
| 6 | AWS MAP and partner credits confirmed by AWS account team | Amatra / AWS | Before engagement kickoff |
| 7 | Existing AWS account read-only access for assessment | Contoso Financial | Week 1 |
| 8 | Internal security baseline documentation | Contoso Financial | Week 1 |
| 9 | ITSM change windows approved for production cutovers | Contoso Financial | Week 14 (2 weeks before planned cutover) |
| 10 | Terraform Cloud Plus licence procurement | Contoso Financial / Amatra | Before start of Phase 2 |

---

# Investment Summary

**Large Complexity Implementation:** This pricing reflects a large-complexity cloud governance engagement covering two AWS regions, three production environments, multiple system integrations (SIEM + ITSM), ISO 27001 compliance validation, and an 8-week hypercare period aligned to an immovable regulatory deadline. Figures below are reconciled against `infrastructure-costs.csv` (infrastructure 3-year totals) and `level-of-effort-estimate.csv` (professional services hours and rates). All figures are in Australian Dollars (AUD).

## Total Investment

The following table presents the full 3-year investment, combining Year 1 Professional Services (one-time implementation cost) with recurring annual cloud infrastructure, software licences, connectivity, and AWS support costs.

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[22, 13, 14, 13, 12, 12, 14] -->
| Cost Category | Year 1 List | Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------|------------|--------|--------|--------------|
| Professional Services | $434,900 | ($30,000) | $404,900 | $0 | $0 | $404,900 |
| Cloud Services | $9,956 | ($28,000) | ($18,044) | $9,956 | $9,956 | $1,868 |
| Software Licenses | $4,056 | ($1,200) | $2,856 | $4,056 | $4,056 | $10,968 |
| Connectivity | $5,718 | — | $5,718 | $5,718 | $5,718 | $17,154 |
| Support & Maintenance | $14,400 | — | $14,400 | $14,400 | $14,400 | $43,200 |
| **TOTAL INVESTMENT** | **$469,030** | **($59,200)** | **$409,830** | **$34,130** | **$34,130** | **$478,090** |
<!-- END COST_SUMMARY_TABLE -->

*Note: Cloud Services Year 1 Net is negative because the AWS MAP credit ($15,000), AWS Activate credit ($5,000), and Reserved Instance savings ($8,000) together exceed the Year 1 cloud infrastructure list price of $9,956. These credits apply in Year 1 only; Year 2 and Year 3 reflect the undiscounted annual run rate of $34,130/year.*

## Partner Credits

Contoso Financial benefits from **$59,200 in total Year 1 credits** applied across professional services and cloud infrastructure:

**Professional Services Credits ($30,000):**
- **AWS Partner Network (APN) Services Credit — $10,000:** Applied to solution architecture and governance implementation services through Amatra's Advanced Consulting Partner status.
- **AWS MAP (Migration Acceleration Program) — $15,000:** Professional services funding for enterprise landing zone and workload onboarding engagements. Eligibility confirmed with the AWS APAC account team; requires MAP enrolment via the AWS Partner Network.
- **Volume Implementation Discount — $5,000:** Strategic financial services engagement discount (approximately 2% of total professional services fees).

**Cloud Infrastructure Credits ($29,200):**
- **AWS MAP Infrastructure Credit — $15,000:** 20% of Year 1 cloud infrastructure costs under the MAP programme, applied to ap-southeast-2 services.
- **AWS Solutions Partner Consumption Credit — $5,000:** AWS Partner programme promotional credit for ap-southeast-2 services in Year 1.
- **Reserved Instance Savings — $8,000:** 1-year Reserved Instance commitment discount (approximately 30% on eligible compute); reflected in Year 1 unit pricing.
- **Terraform Partner Credit — $1,200:** HashiCorp partner programme credit for the first-year Terraform Cloud Plus subscription.

All credits are applied to actual AWS and vendor invoices — not marketing estimates. Amatra manages all credit enrolment paperwork on Contoso Financial's behalf.

## Cost Components

**Professional Services — $404,900 net (Year 1 only)**

Professional services encompass 2,241 hours across all phases, delivered by a team of Solution Architect, Solutions Engineers, Cloud Engineer, Security Engineer, QA Engineer, Technical Writer, and Project Manager. Rates range from $125/hour (Technical Writer) to $225/hour (Senior Solution Architect / Security Specialist). The 8-week hypercare support period is included in the professional services fee.

| Phase | Approximate Hours | Approximate Cost |
|-------|-------------------|-----------------|
| Discovery & Design | ~404 hours | ~$83,600 |
| Planning & Architecture | ~280 hours | ~$57,700 |
| Development & Build | ~828 hours | ~$166,100 |
| Testing & Validation | ~282 hours | ~$55,700 |
| Deployment & Hypercare | ~261 hours | ~$44,500 |
| Management Overhead (10% SA + 10% PM) | ~374 hours | ~$74,800 |
| **Gross Total** | **~2,241 hours** | **~$434,900** |
| Partner & Programme Credits | — | ($30,000) |
| **Net Professional Services** | — | **$404,900** |

**Cloud Infrastructure — ~$9,956/year list (~$1,868 net over 3 years after Year 1 credits)**

Annual infrastructure costs cover AWS Control Tower, Config, CloudTrail, Security Hub, GuardDuty, IAM Identity Center, Systems Manager, Service Catalog, CloudWatch, Lambda, DynamoDB, EventBridge, AWS Backup, and the DR region baseline (ap-southeast-4 Config and S3 replication). Full line-item detail is provided in `infrastructure-costs.csv`.

**Connectivity — $5,718/year**

Two AWS Direct Connect 1 Gbps hosted connections (ap-southeast-2 and ap-southeast-4 at $220/month each) plus a Site-to-Site VPN backup connection ($36.50/month). Direct Connect provides the private, secure connectivity required for on-premises IdP federation and management traffic.

**Software Licenses — $4,056/year (after Year 1 Terraform credit)**

Terraform Cloud Plus for 10 workspaces ($20/workspace/month) provides Sentinel policy-as-code, audit log features, and team-based access controls required for ISO 27001 compliance. Datadog APM ($23/host/month, 6 hosts) provides full-stack observability and SIEM integration feed.

**Support & Maintenance — $14,400/year**

AWS Business Support plan, required for production regulatory workloads. Provides < 1-hour response for production system-down issues, access to AWS Trusted Advisor (all checks), and access to the AWS APAC support team for compliance and architecture queries.

## Payment Terms

Professional services are invoiced on a milestone basis tied to delivery acceptance:

| Milestone | % of PS Fee | Invoice Amount |
|-----------|-------------|----------------|
| SOW Execution | 20% | ~$80,980 |
| Architecture Design Document Accepted (End of Week 6) | 25% | ~$101,225 |
| Platform Go-Live (End of Week 15) | 40% | ~$161,960 |
| Project Closeout / Hypercare End (Week 24) | 15% | ~$60,735 |
| **Total Professional Services** | **100%** | **~$404,900** |

Cloud infrastructure and software licence costs are invoiced monthly in arrears based on actual AWS and Terraform Cloud consumption, passed through at cost. AWS Business Support is invoiced monthly as a fixed fee.

## Invoicing & Expenses

Invoices are issued within 5 business days of milestone acceptance and are payable within 30 days of invoice date. Invoices are submitted to Contoso Financial's Procurement Lead.

Reasonable travel expenses (flights, accommodation, ground transport) incurred for on-site sessions at Contoso Financial's offices are reimbursable at cost, subject to prior written approval. Remote delivery is the default mode; on-site sessions are planned for: kickoff (Week 1), architecture sign-off workshop (Week 5), UAT sessions (Week 14), and knowledge transfer workshops (Week 16). Travel expenses are estimated at $3,000–$5,000 for the engagement and are not included in the investment figures above.

---

# Terms & Conditions

## General Terms

This Statement of Work is issued under, and subject to, the Master Services Agreement (MSA) executed between Amatra and Contoso Financial. In the event of any conflict between this SOW and the MSA, the MSA governs. This SOW, together with the MSA, constitutes the complete agreement between the parties for the services described herein.

## Scope Changes

Any change to the scope, timeline, or commercial terms of this engagement must be managed through a formal Change Request (CR) process. Either party may initiate a CR by submitting a written request to the project managers of both parties. Amatra will assess the CR and provide an impact analysis (scope, timeline, cost) within five business days. No change is effective until both parties have executed a written Change Order. Work outside the agreed scope performed without an executed Change Order is at Amatra's cost and risk.

## Intellectual Property

All deliverables produced specifically for Contoso Financial under this SOW — including architecture documents, IaC modules, runbooks, and compliance artefacts — become the property of Contoso Financial upon receipt of payment in full for the milestone to which they relate. Amatra retains ownership of all pre-existing methodologies, frameworks, toolkits, accelerators, and generic IaC patterns used in the delivery of services. Amatra is granted a licence to use Contoso Financial's name and the general nature of this engagement as a reference engagement, subject to confidentiality obligations and Contoso Financial's prior written approval.

## Service Levels

Amatra warrants that deliverables will conform to the acceptance criteria defined in this SOW. Any defect in a deliverable reported within 30 calendar days of acceptance will be remediated by Amatra at no additional cost. After the 30-day warranty period, defect remediation is subject to a separate support engagement or the Managed Services Agreement. Hypercare support SLAs are as defined in Section 9 (Handover & Support).

## Liability

Amatra's aggregate liability under this SOW is limited to the total professional services fees paid by Contoso Financial in the 12 months preceding the event giving rise to the claim. Neither party is liable for indirect, consequential, incidental, or punitive damages. These limitations do not apply to: (a) death or personal injury caused by negligence; (b) fraud or fraudulent misrepresentation; or (c) any liability that cannot be excluded by law. Amatra maintains professional indemnity insurance of $10M and public liability insurance of $20M.

## Confidentiality

Both parties acknowledge that in the course of this engagement they may receive Confidential Information of the other party. Each party agrees to hold the other's Confidential Information in confidence and not to disclose it to any third party without the other's prior written consent, except as required by law or regulation. This obligation survives termination of this SOW for a period of three years. Amatra's obligations in relation to Contoso Financial's data are further governed by the Data Processing Schedule appended to the MSA.

## Termination

Either party may terminate this SOW for cause upon 30 days' written notice if the other party materially breaches its obligations and fails to cure such breach within the notice period. Contoso Financial may terminate for convenience upon 30 days' written notice; in such case, Contoso Financial shall pay for all services delivered to the date of termination plus reasonable demobilisation costs. Amatra may suspend services if invoices are not paid within 60 days of the due date.

## Governing Law

This SOW is governed by the laws of New South Wales, Australia. Both parties submit to the exclusive jurisdiction of the courts of New South Wales for the resolution of any dispute arising under this SOW. Prior to commencing legal proceedings, the parties agree to attempt resolution through good-faith negotiation, followed by mediation if negotiation fails within 30 days.

---

# Sign-Off

By signing below, both parties agree to the scope, approach, commercial terms, and conditions outlined in this Statement of Work. This document, together with the Master Services Agreement, constitutes the binding agreement for the services described herein.

**Client Authorised Signatory — Contoso Financial:**

Name: __________________________
Title: __________________________
Signature: ______________________
Date: __________________________

**Client Executive Sponsor — Contoso Financial:**

Name: James Wu
Title: Chief Technology Officer
Signature: ______________________
Date: __________________________

**Service Provider Authorised Signatory — Amatra:**

Name: __________________________
Title: __________________________
Signature: ______________________
Date: __________________________

---

*This Statement of Work constitutes the complete agreement between the parties for the services described herein and supersedes all prior negotiations, representations, or agreements relating to the subject matter. This document is version 1.0 and is valid for 60 days from the document date. After 60 days, pricing and credits are subject to review.*
