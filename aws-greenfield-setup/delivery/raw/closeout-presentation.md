---
presentation_title: Project Closeout
solution_name: AWS Multi-Account Landing Zone
presenter_name: Amatra Project Manager
presenter_email: pm@amatra.com
presenter_phone: TBD
presentation_date: "2025-04-30"
client_name: Anonymous — Insurance Vendor
client_logo: ../../assets/logos/client_logo.png
footer_logo_left: ../../assets/logos/consulting_company_logo.png
footer_logo_right: ../../assets/logos/eo-framework-logo-real.png
---

# AWS Multi-Account Landing Zone - Project Closeout

## Slide Deck Structure
**10 Slides - Fixed Format**

---

### Slide 1: Title Slide
**layout:** eo_title_slide

**Presentation Title:** Project Closeout
**Subtitle:** AWS Multi-Account Landing Zone Implementation Complete
**Presenter:** Amatra Project Manager | April 2025

---

### Slide 2: Executive Summary
**layout:** eo_bullet_points

**Project Successfully Delivered**

- **Project Duration:** 16 weeks (12-week build + 4-week hypercare), on schedule
- **Budget:** $316,542 net Year 1 delivered on budget
- **Go-Live Date:** Week 12 as planned; hypercare concluded Week 16
- **Guardrail Coverage:** 100% of accounts enrolled in Control Tower guardrails
- **Account Vending SLA:** <30 minutes via AFT — validated in 3 consecutive runs
- **Security Posture:** Zero critical Security Hub findings at go-live
- **IaC Coverage:** ≥95% Terraform — zero manual console changes in production
- **Regions Covered:** us-east-1 (primary) and us-east-2 (DR) both operational
- **Workload Accounts:** 2 accounts (1 Prod, 1 NonProd) vended and guardrail-enrolled
- **ROI Status:** Operational savings and governance value realised from day one

**SPEAKER NOTES:**

*Talking Points:*
- Open with confidence — every success metric committed in the SOW was achieved at go-live
- Highlight 100% guardrail enrolment: every AWS account created will automatically inherit security controls
- The <30-minute AFT vending SLA was validated three consecutive times confirming repeatability
- Zero critical Security Hub findings gives the client a clean compliance baseline entering production
- ≥95% IaC coverage means the entire landing zone can be rebuilt from code — key to long-term resilience

*Budget Context:*
- Year 1 net investment: $316,542 after $33,000 in AWS partner credits applied
- Professional services: $298,440 net (1,586 hours across 5 delivery phases + management overhead)
- Cloud infrastructure: $13,422 net Year 1 (gross $28,422 reduced by $15,000 AWS Activate/MAP credits)
- Steady-state run cost from Year 2: ~$33,102/year (infrastructure + support only)
- 3-year TCO: $382,746 — well below estimated $300K+ cost of unplanned re-architecture

*Timeline Context:*
- Project kicked off January 2025 per SOW document date
- All 7 milestones (M1 through M7) achieved on target dates with no slippage
- No change control orders were required throughout the engagement

---

### Slide 3: Solution Architecture
**layout:** eo_visual_content

**What We Built Together**

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

- **Governance & Identity**
  - Control Tower + Organizations (multi-region)
  - IAM Identity Center SSO (all accounts)
  - SCPs/RCPs (7-OU policy enforcement)
- **Networking**
  - Transit Gateway hub-spoke (both regions)
  - Network Firewall (north-south + east-west)
  - VPC IPAM + Site-to-Site VPN
- **Security & Automation**
  - Security Hub FSBP + GuardDuty (org-wide)
  - AFT account vending pipeline (<30 min)
  - CloudTrail Lake + Config rules (both regions)

**SPEAKER NOTES:**

*Talking Points:*
- Walk through the architecture from governance at the top down to automation at the bottom
- Three-layer structure maps directly to the three delivery phases
- Architecture is 100% aligned with the Solution Briefing and SOW — no scope was added

*Governance & Identity Layer:*
- Control Tower governs both us-east-1 and us-east-2 from a single management account
- 7-OU hierarchy: Root, Security, Infrastructure, Workloads-Prod, Workloads-NonProd, Sandbox, Suspended
- SCPs enforce hard boundaries: no root usage, region restriction, CloudTrail/Config lock, MFA required
- RCPs enforce data perimeter — data cannot leave the AWS Organisation boundary
- IAM Identity Center provides SSO with 5 permission sets across all accounts

*Networking Layer:*
- Two TGW instances (one per region) connected via inter-region peering
- All traffic flows through the Network Hub account for centralised inspection
- Network Firewall inspects north-south and east-west traffic in both regions
- VPC IPAM manages 10.0.0.0/8 supernet; /20 blocks delegated per spoke VPC automatically
- Site-to-Site VPN operational to on-premises; Direct Connect upgrade path documented

*Security & Automation Layer:*
- Security Hub aggregates FSBP findings from all accounts to the Audit account
- GuardDuty monitors VPC Flow Logs, CloudTrail events, and DNS logs org-wide
- AFT pipeline vends a fully guardrail-enrolled account in under 30 minutes
- CloudTrail Lake configured with 7-year retention and pre-built investigation queries
- Config recording active across all accounts in both regions with FSBP conformance packs

---

### Slide 4: Deliverables Inventory
**layout:** eo_table

**Complete Documentation & Automation Package**

<!-- TABLE_CONFIG: widths=[30, 45, 25] -->
| Deliverable | Purpose | Location |
|-------------|---------|----------|
| **Phase 1 Architecture Design Doc** | OU hierarchy, SCP/RCP, Identity Center design | `/delivery/detailed-design.docx` |
| **As-Built Architecture Document** | Final production configuration reference | `/delivery/as-built-architecture.docx` |
| **IaC Repository (Terraform + AFT)** | Full infrastructure code for all components | `/delivery/scripts/terraform/` |
| **CI/CD Pipeline** | Branch-protected IaC deployment pipeline | `/delivery/scripts/cicd/` |
| **Operational Runbooks (×6)** | Account vending, SCP changes, incident response | `/delivery/runbook.docx` |
| **Test Results Report** | SCP, vending, network, security, UAT evidence | `/delivery/test-plan.xlsx` |
| **Administrator Training Materials** | Recorded sessions for CT, AFT, Security Hub | `/delivery/training/` |
| **Optimization Recommendations** | Savings Plans, Direct Connect, TGW tuning | `/delivery/optimization-report.docx` |

**SPEAKER NOTES:**

*Talking Points:*
- All 27 deliverables defined in the SOW have been produced and formally accepted
- This slide highlights the 8 highest-value deliverables from the full 27-item list
- Every deliverable has been reviewed and accepted by the designated acceptance authority in the SOW

*Key Deliverable Highlights:*
- IaC Repository is the most strategic deliverable: entire landing zone can be rebuilt from code; client owns it outright
- 6 operational runbooks cover every routine task: AFT vending, SCP changes, Security Hub triage, Network Firewall updates, incident response, CloudTrail Lake queries
- AFT Pipeline is embedded in the IaC Repository and is the engine for all future account provisioning
- Optimization Recommendations Report includes: Savings Plans evaluation, TGW routing opportunities, Direct Connect business case, NIST/SOC 2/HIPAA onboarding path

---

### Slide 5: Quality & Performance
**layout:** eo_two_column

**Exceeding All Quality Targets**

- **Testing Metrics**
  - SCP Enforcement Tests: 100% pass rate
  - Account Vending Runs: 3/3 under 30 min
  - Security Hub FSBP Score: ≥80% at go-live
  - Critical Findings at Go-Live: 0
  - UAT Sign-Off: Obtained Week 12
- **Performance Metrics**
  - Account Vending SLA: <30 min (target <30 min)
  - IaC Coverage: ≥95% (target ≥95%)
  - Accounts Guardrail-Enrolled: 100% (target 100%)
  - Landing Zone RTO: <4 hrs (target <4 hrs)
  - Config Recording Active: Both regions, all accounts

**SPEAKER NOTES:**

*Talking Points:*
- Every measurable success metric defined in the SOW was met or exceeded at go-live
- Zero critical Security Hub findings is the headline security achievement
- Three consecutive AFT vending runs confirmed repeatability, not just a one-off pass
- ≥95% IaC coverage confirmed via Terraform drift detection — no manual console changes detected

*Testing Programme Detail:*
- Functional Validation: All Control Tower, OU, IAM Identity Center, AFT, CloudTrail, Config, and CloudWatch tests passed
- SCP Tests: Deny-root, out-of-region API calls, CloudTrail disable attempts, and MFA bypass all correctly denied
- RCP Data Perimeter Test: S3 write to external-Organisation bucket correctly denied
- IAM Access Analyser: Zero external-access findings in Production and Platform accounts
- Network Flow Tests: Spoke-to-spoke traffic routed through Firewall; VPN routing and centralised egress confirmed
- DR Tests: us-east-2 governance confirmed; IaC rebuild completed within 4-hour RTO

*SOW Success Metrics — All Achieved:*
- 100% accounts enrolled in Control Tower guardrails at go-live ✅
- Account provisioning <30 minutes via AFT (3 consecutive runs) ✅
- Zero critical Security Hub findings in production at launch ✅
- IaC coverage ≥95%; zero manual console changes ✅
- ≥2 workload accounts vended by end of Month 3 ✅
- AWS Config recording active in all accounts, both regions ✅
- CloudTrail org trail capturing all management events ✅
- SNS budget alerts active at 80% and 100% for all accounts ✅

---

### Slide 6: Benefits Realized
**layout:** eo_table

**Delivering Measurable Business Value**

<!-- TABLE_CONFIG: widths=[32, 22, 22, 24] -->
| Benefit Category | Target | Achieved | Impact |
|------------------|--------|----------|--------|
| **Account Provisioning Time** | <30 minutes | <30 minutes | Self-service for new workloads |
| **Guardrail Enrolment Coverage** | 100% at go-live | 100% at go-live | Every account secure from creation |
| **Security Findings at Go-Live** | 0 critical | 0 critical | Clean compliance baseline |
| **IaC Coverage** | ≥95% | ≥95% | Full rebuild capability retained |
| **Regions Governed** | 2 (us-east-1, us-east-2) | 2 regions operational | Multi-region resilience active |
| **Workload Accounts Vended** | ≥2 by Month 3 | 2 (1 Prod, 1 NonProd) | Workload onboarding unblocked |
| **Operational Handover** | Full runbooks + training | 6 runbooks + 6 KT sessions | Client team self-sufficient |
| **3-Year Cost Avoidance** | Avoid re-architecture | ~$300K+ avoided | Governed foundation from day one |

**SPEAKER NOTES:**

*Talking Points:*
- Every benefit target committed in the SOW was achieved at or before go-live
- Most strategic benefit: any team can have a fully governed AWS account in under 30 minutes
- 100% guardrail coverage means the cloud estate will never drift into non-compliance at the account level
- Zero critical findings gives the security team a clean slate rather than inheriting technical debt

*Financial Benefits Context:*
- SOW documented unplanned re-architecture cost at $300K+; this engagement prevents that future cost
- Steady-state run cost from Year 2 is ~$33K/year — highly cost-effective for an enterprise-scale platform
- AWS partner credits of $33K in Year 1 represent a 9.4% reduction in total Year 1 investment
- Cost governance: AWS Cost Explorer and per-account Budgets active from go-live
- Savings Plans evaluation documented in Optimization Recommendations Report for 3-month review

---

### Slide 7: Lessons Learned & Recommendations
**layout:** eo_two_column

**Insights for Continuous Improvement**

- **What Worked Well**
  - Foundation-first phasing reduced delivery risk
  - IaC-first approach enabled fast, repeatable deploys
  - AFT validated in sandbox before production apply
  - Weekly stakeholder check-ins maintained alignment
  - ADR sign-off gate prevented Phase 2 scope creep
- **Challenges Overcome**
  - Identity source confirmation delayed to Week 3
  - On-premises BGP unsupported; static routing used
  - ADR document feedback cycle took 6 business days
  - FSBP conformance pack tuning required extra iteration
  - VPN routing validated later than planned in Week 8
- **Recommendations**
  - Enable NIST 800-53 conformance pack in Security Hub
  - Evaluate Direct Connect to replace Site-to-Site VPN
  - Onboard additional workload accounts via AFT
  - Assess Savings Plans at 3-month post-go-live mark
  - Establish quarterly architecture and FinOps reviews
  - Expand tagging governance with AWS Tag Policies audit

**SPEAKER NOTES:**

*What Worked Well — Detail:*
- Foundation-first phasing (Control Tower → networking → security tooling) meant each phase built on a stable, validated base — no rework between phases
- IaC-first: all infrastructure in Terraform from day one; team could iterate quickly, roll back cleanly, and hand over a fully reproducible environment
- AFT sandbox validation: testing each AFT customisation in a Sandbox OU before production OUs caught 3 configuration issues before they reached production
- Weekly stakeholder check-ins: kept Client IT Owner and Security Lead aligned on technical decisions; no design disagreements became blockers
- ADR sign-off gate: the formal Architecture Design Review at Week 4 locked the design before Phase 2 began, preventing late-stage scope additions

*Challenges and Resolutions:*
- Identity source delay: Client did not confirm IAM Identity Center identity source until Week 3. Resolution: vendor pre-built both native and Okta connector configurations; native AWS SSO chosen with IdP migration path documented
- BGP capability gap: On-premises gateway did not support BGP; static routing configured as fallback per SOW Assumption 11. Added ~4 hours of engineering effort; no milestone impact
- ADR feedback cycle: Client IT Owner and Security Lead needed 6 business days to review the Phase 1 Architecture Design Document (SOW assumption is 5 days). No milestone impact as review was completed by Week 4 gate
- FSBP conformance pack tuning: Several Config rules required suppress-list configuration for known-acceptable deviations; tuning took an additional half-day in Week 10
- VPN routing validation: On-premises gateway configuration details arrived at Week 4 (Dependency D5 just-in-time); VPN routing was confirmed at the end of Week 8 milestone rather than mid-week as planned

*Recommendations — Prioritised Roadmap:*
- Priority 1 (Q2 2025): Enable NIST 800-53 conformance pack — low effort, high compliance value for insurance operations
- Priority 2 (Q2 2025): Savings Plans assessment at 3-month mark — model in Optimization Report projects 20–30% savings on compute
- Priority 3 (Q3 2025): Direct Connect evaluation — upgrade path documented in networking runbook; assess bandwidth needs and business case
- Priority 4 (Q3–Q4 2025): Onboard additional workload accounts via AFT — pipeline is live and team is trained
- Priority 5 (Ongoing): Quarterly architecture and FinOps reviews to track Security Hub score trends and cost optimisation
- Priority 6 (Q3 2025): Expand tag policy audit — AWS Organizations Tag Policies can generate compliance reports for mandatory tag adherence across all accounts

---

### Slide 8: Support Transition
**layout:** eo_two_column

**Ensuring Operational Continuity**

- **Hypercare (Weeks 13–16 — Now Complete)**
  - Dedicated vendor support team active
  - P1 response: 2-hour SLA (24×7)
  - P2 response: 4-hour SLA (business hours)
  - First live AFT workload vend supported
  - Hypercare Closeout Report delivered Week 16
- **Steady State (Week 17+)**
  - Client team confirmed fully self-sufficient
  - 6 runbooks cover all routine operations
  - 6 recorded KT sessions available on demand
  - AWS Business Support plan active ($4,200/yr)
  - Quarterly architecture review recommended
- **Escalation Contacts**
  - AWS Business Support (P1: <1-hour response 24×7)
  - Amatra Account Manager for new engagement scope
  - Amatra Managed Services for ongoing operations
  - AWS Partner Network support via Amatra portal
  - Break-glass process documented with Security Lead

**SPEAKER NOTES:**

*Hypercare Summary:*
- 4-week hypercare period (Weeks 13–16) is now complete as of this closeout presentation
- P1 SLA: 2-hour response 24×7 for landing zone governance failures or SCPs non-functional
- P2 SLA: 4-hour business hours response for AFT pipeline failure or Security Hub outage
- P3 SLA: 1 business day for non-critical component issues
- P4 SLA: 2 business days for documentation corrections and enhancement requests
- All hypercare issues resolved within SLA; no P1 incidents raised during the 4-week period
- First live workload account vend by the client team (unsupported) completed successfully in Week 14

*Support Transition Activities Completed:*
- All 6 operational runbooks reviewed with client IT and Security teams in Week 12 KT sessions
- All 6 recorded training sessions (3 Cloud Infrastructure + 3 Security Operations) delivered and accessible
- Break-glass access process confirmed and documented with client security team at handover
- AWS Budgets alerts active for all accounts; SNS routing confirmed to client email distribution list
- CloudWatch centralised dashboards demonstrated to Shared Services account operators

*Steady-State Operations Guidance:*
- Routine operations: all covered by 6 runbooks — no need to contact the vendor for AFT vending, SCP changes, Security Hub triage, firewall rule updates, incidents, or CloudTrail Lake queries
- AWS Business Support ($4,200/year): provides 24×7 Cloud Support Engineers and <1-hour P1 response for AWS service-level incidents
- Quarterly review recommendation: schedule 90-day post-go-live call with Amatra account manager to review Security Hub score trends, Config compliance posture, and Savings Plans opportunity
- Managed Services Agreement available from Amatra if ongoing managed operations are required (explicitly excluded from current SOW scope)

*Escalation Path Detail:*
- Level 1: Client IT team using runbooks for routine operations
- Level 2: AWS Business Support for platform-level incidents (24×7, <1-hour P1)
- Level 3: Amatra Account Manager for new scope requests or change control
- Level 4: Amatra Managed Services Agreement for ongoing operations beyond hypercare
- Break-glass: documented offline process agreed with client security team at handover

---

### Slide 9: Acknowledgments & Next Steps
**layout:** eo_bullet_points

**Partnership That Delivered Results**

- Executive Sponsor for leadership, ADR approval, and UAT sign-off
- Client IT Owner for technical availability and deliverable acceptance
- Client Security Lead for SCP and compliance design input
- Client Networking Lead for on-premises VPN configuration
- **This Week:** Formal closeout and final documentation handover
- **Next 30 Days:** 90-day check-in to review Security Hub score trends
- **Next Quarter:** Phase 2 planning — NIST 800-53, Direct Connect, Savings Plans

**SPEAKER NOTES:**

*Acknowledgments — Specific Contributions:*
- Executive Sponsor: approved the Architecture Design Review at Week 4 on schedule; personally participated in UAT Week 12 and provided go-live sign-off
- Client IT Owner: primary technical contact for the full 16-week engagement; accepted 14 of 27 deliverables; performed the first live AFT vend during UAT
- Client Security Lead: confirmed FSBP as go-live compliance framework at Week 2; reviewed and approved all SCP and RCP designs; completed all 3 Security Operations KT sessions
- Client Networking Lead: provided on-premises gateway configuration details at Week 4 (Dependency D5 met on time); confirmed VPN routing at Week 8 milestone

*Next Steps — Detail:*
- This Week: Final documentation package transferred; Hypercare Closeout Report (Deliverable 27) accepted; project formally closed
- 90-Day Check-in (~July 2025): 1-hour call to review Security Hub FSBP score trends, Config compliance posture, workload accounts vended since go-live, and Savings Plans assessment
- Phase 2 Planning (Q3 2025): Recommended scope includes NIST 800-53 conformance pack activation, Direct Connect procurement, Savings Plans commitment, and onboarding 3–5 additional workload accounts via AFT
- Confirm 90-day check-in date with Client IT Owner before leaving this meeting

---

### Slide 10: Thank You
**layout:** eo_thank_you

Questions & Discussion

**Your Project Team:**
- Project Manager: pm@amatra.com | TBD
- Solution Architect: architect@amatra.com | TBD
- Account Manager: am@amatra.com | TBD

**SPEAKER NOTES:**

*Talking Points:*
- Open the floor for questions and discussion — invite the client team to share their reflections
- Have the Test Results Report and SOW Investment Summary ready as backup for financial or technical deep-dives
- Offer to schedule a separate follow-up session with the security team for Security Hub triage or GuardDuty deep-dives
- Confirm the 90-day check-in date with the Client IT Owner before leaving this meeting
- End on a positive, forward-looking note: landing zone is live, team is trained, client is ready to scale their AWS estate securely and confidently
- Remind the client that the Amatra account manager is the primary contact for Phase 2 discussions, change control, or Managed Services Agreement queries
