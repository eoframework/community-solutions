---
presentation_title: Project Closeout
solution_name: AWS Cloud Governance Platform — Contoso Financial
presenter_name: Rachel Moore
presenter_email: delivery@amatra.com.au
presenter_phone: +61 2 9000 0000
presentation_date: 2026-05-01
client_name: Contoso Financial
client_logo: ../../assets/logos/client_logo.png
footer_logo_left: ../../assets/logos/consulting_company_logo.png
footer_logo_right: ../../assets/logos/eo-framework-logo-real.png
---

# AWS Cloud Governance Platform — Contoso Financial — Project Closeout

## Slide Deck Structure
**10 Slides - Fixed Format**

---

### Slide 1: Title Slide
**layout:** eo_title_slide

**Presentation Title:** Project Closeout
**Subtitle:** AWS Cloud Governance Platform — Contoso Financial Implementation Complete
**Presenter:** Rachel Moore | May 2026

---

### Slide 2: Executive Summary
**layout:** eo_bullet_points

**Project Successfully Delivered**

- **Project Duration:** 16 weeks (4 months), on schedule
- **Budget:** $404,900 net professional services, on budget
- **Go-Live Date:** End of Week 15 as planned
- **Quality:** Zero critical defects at production go-live
- **Guardrail Coverage:** 100% of production accounts under SCPs
- **Identity:** Shared credentials fully retired; IdP federation live
- **Audit Package:** ISO 27001 evidence package delivered to CISO
- **DR Validated:** RTO < 4h and RPO < 1h confirmed in drill
- **Hypercare:** 8-week period covers April 2026 regulatory review
- **ROI:** Audit remediation effort reduced by 80% — payback on track

**SPEAKER NOTES:**

*Talking Points:*
- Open with confidence — the platform was delivered on time, on budget, and to full scope.
- The April 2026 regulatory deadline was the defining constraint for every phase-gate decision, and we met it.
- Emphasise the zero-critical-defect go-live as proof of the quality embedded in the delivery process.

*Background Details:*
- Professional services: $434,900 list price less $30,000 in APN, MAP, and volume credits = $404,900 net. This matches the SOW Investment Summary exactly.
- Phased timeline: Phase 1 (Weeks 1–6 Discovery & Design), Phase 2 (Weeks 7–12 Build & Integrate), Phase 3 (Weeks 13–16 Testing & Handover).
- 8-week hypercare period (Weeks 17–24) was specifically sized to cover the regulatory review window — this was a deliberate presales commitment and it has been honoured.
- ISO 27001 evidence package compiled and accepted by CISO before go-live (Milestone M9).
- DR drill confirmed RTO 3h 20min and RPO 42min — both within SOW targets of < 4h and < 1h respectively.

*Presales Commitments Met:*
- 80% reduction in audit remediation effort — target set in SOW Success Metrics, validated post-go-live.
- Zero shared administrative credentials — IAM Identity Center federation replaced all shared-credential access.
- Account provisioning reduced from days to under 4 hours — AFT pipeline validated during functional testing.
- All data remains within Australia (ap-southeast-2 primary, ap-southeast-4 DR) — data sovereignty confirmed.

---

### Slide 3: Solution Architecture
**layout:** eo_visual_content

**What We Built Together**

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

- **Governance & Provisioning**
  - Control Tower + AFT account vending pipeline
  - SCPs enforcing no-console-access organisation-wide
  - ITSM change-approval gate on all vending requests
- **Security & Compliance**
  - Security Hub aggregating GuardDuty + Config findings
  - Centralised S3 log archive (12-month WORM retention)
  - ISO 27001 conformance pack with auto-remediation
- **Network & Identity**
  - Transit Gateway hub-spoke with Network Firewall
  - IAM Identity Center federation from on-prem IdP
  - Dual-region deployment: ap-southeast-2 + ap-southeast-4

**SPEAKER NOTES:**

*Talking Points:*
- Walk through the architecture top-to-bottom: governance layer, then security, then network and identity.
- Every component maps directly to a presales commitment in the Solution Briefing — no scope additions were made.
- The dual-region deployment (ap-southeast-2 primary, ap-southeast-4 DR) was a hard data sovereignty requirement and was delivered as designed.

*Technical Details:*
- Control Tower OU hierarchy: Management, Log Archive, Audit, Security, Network, and Workload OUs — exactly as designed in the Architecture Design Document (Deliverable #5).
- AFT pipeline uses Terraform Cloud Plus workspaces with Sentinel policy-as-code for pre-deployment compliance checks.
- ~80 AWS Config rules deployed: ISO 27001 conformance pack + custom rules for Contoso Financial's internal security baseline.
- Network Firewall in the Network Account inspects all east-west and north-south traffic; no direct peer-to-peer between workload accounts.
- IAM Identity Center: SAML 2.0 federation with on-prem IdP; four permission sets (Developer, Operator, SecurityViewer, BreakGlass); MFA enforced at IdP level.

*Cost Alignment:*
- Annual infrastructure run rate: ~$9,956/year list; effectively covered by AWS MAP and partner credits in Year 1.
- Year 2 and Year 3 recurring run cost is ~$34,130/year (cloud + connectivity + software + support) — as documented in the SOW Investment Summary.

*Presales Alignment:*
- Architecture is identical to the Solution Briefing (Slide 4) and the Architecture Design Document.
- Services deployed: AWS Control Tower, AFT (Terraform), AWS Config, SCPs, Security Hub, GuardDuty, IAM Identity Center, CloudTrail, S3 (WORM), Transit Gateway, Network Firewall, Direct Connect, EventBridge, Lambda, CloudWatch, Systems Manager.
- No services were added beyond the presales scope.

---

### Slide 4: Deliverables Inventory
**layout:** eo_table

**Complete Documentation & Automation Package**

<!-- TABLE_CONFIG: widths=[38, 37, 25] -->
| Deliverable | Purpose | Location |
|-------------|---------|----------|
| **Architecture Design Document** | OU hierarchy, guardrail framework, design decisions | `/delivery/detailed-design.md` |
| **IaC Module Library (Terraform)** | Reusable AFT modules, VPC, IAM, Config packs | `/delivery/scripts/terraform/` |
| **Configuration & Operations Guide** | Platform configuration reference and procedures | `/delivery/configuration.csv` |
| **Test Results & Compliance Evidence** | ISO 27001 control validation and DR test results | `/delivery/test-plan.csv` |
| **Operational Runbook Suite** | Account vending, break-glass, DR failover SOPs | `/delivery/runbook/` |
| **Knowledge Transfer Recordings** | Recorded sessions: AFT, Security Hub, IAM IdC | `/delivery/training/` |
| **Platform Optimisation Roadmap** | Cost optimisation and guardrail enhancement plan | `/delivery/optimisation-roadmap.md` |
| **Project Closeout Report** | Engagement summary and lessons learned | `/delivery/closeout-report.md` |

**SPEAKER NOTES:**

*Talking Points:*
- All 25 deliverables listed in the SOW Deliverables table have been completed and accepted.
- This slide highlights the eight most strategically significant deliverables for executive awareness.
- Every deliverable was accepted in writing by the designated authority before the next phase commenced — no phase-gate was bypassed.

*Deliverable Status (all 25 SOW deliverables):*
- Deliverables 1–5 (Phase 1): Project Kickoff Deck, Current State Assessment, Gap Analysis, ISO 27001 Control Mapping, Architecture Design — all accepted by Week 6.
- Deliverables 6–17 (Phase 2): IaC Module Library, Control Tower, AFT, SCPs/Config, IAM Identity Center, Security Hub/GuardDuty/CloudTrail, SIEM Integration, DR Baseline, Network Infrastructure, Environment Onboarding, CI/CD GitOps Pipeline, Config & Ops Guide — all accepted by Week 12.
- Deliverables 18–25 (Phase 3): Test Plan, Test Results/Evidence Package, DR Failover Report, Operational Runbooks, Knowledge Transfer, Administrator Training, Optimisation Roadmap, Project Closeout Report — all accepted by Week 16.

*Key Highlights:*
- IaC Module Library: 14 reusable Terraform modules committed to Git; Contoso Financial owns the repository post-handover.
- ISO 27001 compliance evidence package: formatted for direct regulatory submission; includes Config conformance reports, CloudTrail attestation, GuardDuty findings report, Security Hub trend analysis, DR test results.
- Knowledge Transfer: four sessions delivered (IaC/AFT, Guardrail Management, Security Hub/Compliance Evidence, IAM Identity Center Operations) — all recorded and delivered.

---

### Slide 5: Quality & Performance
**layout:** eo_two_column

**Exceeding All Quality Targets**

- **Testing Metrics**
  - Test cases executed: 100% of plan
  - Critical defects at go-live: 0
  - SCP denial tests: all passed (100%)
  - Config rule fire time: <60s (target: <60s)
  - SIEM forwarding latency: <3 min (target: <5 min)
- **Performance Metrics**
  - Platform availability: 99.9% (target: 99.9%)
  - Account provisioning time: <2h (target: <4h)
  - DR drill RTO: 3h 20min (target: <4h)
  - DR drill RPO: 42 min (target: <1h)
  - Security Hub → SIEM: <3 min (target: <5 min)

**SPEAKER NOTES:**

*Talking Points:*
- Quality was not an afterthought — it was embedded into the delivery process from Phase 1 through structured test planning.
- Every SOW success metric has been validated and met or exceeded.
- The CISO sign-off on all controls before go-live (Milestone M8) is the authoritative acceptance gate.

*Detailed Metrics:*
- SCP validation: 12 distinct prohibited actions tested across production OUs — all resulted in `AccessDenied` with corresponding CloudTrail entries in the Log Archive account.
- Config rule validation: deliberate non-compliant configurations introduced in a test account (unencrypted S3 bucket, open security group, disabled CloudTrail) — all detected within 45 seconds and remediated automatically for applicable rules.
- Break-glass procedure tested end-to-end: time-limited access granted in <10 minutes, SIEM alert generated, full CloudTrail log captured.
- Account provisioning load test: 5 concurrent AFT vending requests processed without throttling — all accounts provisioned and baseline-applied within 90 minutes.
- DR drill details: ap-southeast-2 primary simulated failure at 09:00 AEST; ap-southeast-4 DR governance platform fully operational by 12:20 AEST (3h 20min RTO). Log Archive replication lag measured at 42 minutes (RPO).
- Platform availability measured over a 30-day post-go-live observation window — zero platform outages recorded.

*SOW Success Metric Alignment:*
- Zero compliance findings from Q2 2026 regulatory review: on track — ISO 27001 evidence package accepted by CISO.
- 80% reduction in audit remediation effort: baseline 3–4 findings/quarter; post-go-live: zero findings in first cycle.
- 100% production accounts under SCPs with no manual console access: confirmed.
- All new provisioning via AFT pipeline with ITSM gate: confirmed — 3 production environments onboarded via AFT.
- IAM Identity Center live; zero shared credentials: confirmed — on-premises IdP federated; all IAM users retired.
- DR RTO < 4h and RPO < 1h: confirmed by drill results.

---

### Slide 6: Benefits Realized
**layout:** eo_table

**Delivering Measurable Business Value**

<!-- TABLE_CONFIG: widths=[32, 22, 22, 24] -->
| Benefit Category | Target | Achieved | Impact |
|------------------|--------|----------|--------|
| **Audit Remediation Effort** | 80% reduction | 80% reduction (0 findings) | Platform team capacity freed |
| **Account Provisioning Time** | < 4 hours | < 2 hours | Faster environment delivery |
| **Console Access in Production** | 0 manual sessions | 0 (SCP enforced) | Eliminated credential risk |
| **Compliance Findings/Quarter** | 0 (post go-live) | 0 (first cycle) | Clean regulatory review |
| **SIEM Alert Latency** | < 5 minutes | < 3 minutes | Faster incident response |
| **DR Recovery Time (RTO)** | < 4 hours | 3h 20min | Confirmed resilience |
| **Data Sovereignty Coverage** | 100% in-country | 100% (AU regions only) | Regulatory obligation met |
| **Shared Credentials Retired** | 100% | 100% (IdP federation live) | Zero credential-sharing risk |

**SPEAKER NOTES:**

*Talking Points:*
- Benefits are already being realised — the first post-go-live audit cycle produced zero findings.
- This is the core business case that drove the engagement: protect the April 2026 regulatory review.
- Every benefit row maps directly to a SOW Success Metric or Key Outcome.

*Detailed Impact:*
- Audit remediation effort: the platform team previously spent an estimated 15–20 hours per finding per quarter across 3–4 findings. At 80% reduction, this represents ~50–60 hours/quarter returned to strategic work.
- Account provisioning: the previous manual process took "days" (SOW Background). AFT pipeline provisions in under 2 hours — a reduction of at least 75–80% in calendar time, with zero manual steps.
- Compliance findings: the first post-go-live Config conformance run across all accounts produced zero non-compliant findings — all previously identified gaps were remediated during Phase 2.
- SIEM latency: measured end-to-end (Security Hub finding generated to SIEM correlation alert) at an average of 2 minutes 47 seconds across 50 test events.
- ROI timeline: SOW projected ongoing audit remediation avoidance of $420K+ per year (benchmark from success story, proportionally adjusted). Net Year 1 investment $409,830. Payback period approximately 12 months.
- Data sovereignty: region-lock SCP confirmed blocking all non-ap-southeast-2/4 API calls in production OUs — tested with 8 API calls to disallowed regions, all denied.

*Future Benefit Projections:*
- Year 2+ cloud run cost: ~$34,130/year — significant reduction from Year 1 as MAP and partner credits do not recur.
- Guardrail maturity: as the Config rule library is extended post-handover, compliance posture will continue to improve without additional implementation cost.
- Phase 2 opportunity (see Slide 7): expanding AFT coverage to developer sandbox accounts and implementing FinOps dashboards are the highest-priority near-term enhancements.

---

### Slide 7: Lessons Learned & Recommendations
**layout:** eo_two_column

**Insights for Continuous Improvement**

- **What Worked Well**
  - CISO sign-off gate before Phase 2 prevented rework
  - IaC-first approach accelerated all environment builds
  - Evidence collection automated from day one of Phase 2
  - AFT pipeline reduced onboarding time significantly
  - Phased cutover (3 environments over 3 days) de-risked go-live
- **Challenges Overcome**
  - Direct Connect lead time: mitigated with VPN fallback in Phase 2
  - On-prem IdP attribute mapping: resolved via additional workshop
- **Recommendations**
  - Extend AFT coverage to developer sandbox accounts
  - Implement FinOps dashboards (AWS Cost Explorer + budgets)
  - Add PCI-DSS conformance pack as next compliance framework
  - Schedule quarterly CISO-led compliance evidence reviews
  - Engage Amatra Managed Services for ongoing CloudOps

**SPEAKER NOTES:**

*What Worked Well — Details:*
- CISO sign-off gate (Milestone M3, end of Week 6): by requiring formal CISO acceptance of the architecture before Phase 2 began, we avoided mid-build design changes. This is a best practice for all regulated financial services engagements.
- IaC-first approach: using AFT and Terraform for all account and guardrail provisioning meant every environment was born compliant — there were no "catch-up" remediation tasks in Phase 3.
- Evidence collection from day one of Phase 2: Config conformance packs were deployed in the first week of Phase 2, meaning 6 weeks of continuous compliance data was available when the evidence package was compiled in Phase 3.
- Phased cutover: onboarding one production environment per day across 3 days (Week 15) allowed the team to validate each cutover fully before proceeding to the next. No rollbacks were required.

*Challenges Overcome — Details:*
- Direct Connect lead time: Contoso Financial ordered the ap-southeast-4 Direct Connect circuit 2 weeks later than the SOW dependency required (Dependency #1). Amatra stood up a Site-to-Site VPN as a fallback during Phase 2, enabling federation configuration and SIEM integration to proceed without delay. The Direct Connect circuit was provisioned before Phase 3 DR testing.
- On-prem IdP attribute mapping: the on-premises directory's group structure required a non-standard attribute mapping to IAM Identity Center groups. An additional 2-hour workshop with the IdP team (beyond the Week 11 session) was required to resolve. No timeline impact.

*Recommendations — Prioritised:*
1. **AFT expansion to dev sandboxes (Next 30 days):** Low effort, high consistency benefit — eliminates manual developer account setup.
2. **FinOps dashboards (Next 60 days):** AWS Cost Explorer tags are already applied; adding budget alerts and anomaly detection is a low-cost enhancement.
3. **PCI-DSS conformance pack (Next Quarter):** Contoso Financial's card payment workloads may benefit; a scoping exercise is recommended before commitment.
4. **Quarterly compliance evidence reviews (Ongoing):** Establish a rhythm of CISO-led reviews using the Security Hub dashboard and Config compliance reports — no additional tooling required.
5. **Managed Services (Next Quarter):** Refer to Amatra's Managed Services Agreement for ongoing CloudOps, guardrail management, and compliance monitoring post-hypercare.

---

### Slide 8: Support Transition
**layout:** eo_two_column

**Ensuring Operational Continuity**

- **Hypercare (Weeks 17–24)**
  - Dedicated Amatra delivery team on-call
  - 2-hour P1 response (compliance-blocking issues)
  - Next-business-day P2 response
  - Covers April 2026 regulatory review window
  - Guardrail tuning and SIEM alert refinement in scope
- **Transition to Self-Sufficiency**
  - Four knowledge transfer sessions completed
  - All sessions recorded and delivered to Priya Nair
  - Operational runbooks accepted by platform team
  - IaC Git repository transferred to Contoso Financial
- **Steady State (Post-Week 24)**
  - Platform team operates independently
  - Quarterly CISO-led compliance evidence reviews
  - Monthly CloudWatch dashboard reviews recommended
- **Escalation Contacts**
  - P1/P2: delivery@amatra.com.au | +61 2 9000 0000
  - Account Manager: accounts@amatra.com.au

**SPEAKER NOTES:**

*Hypercare Coverage Details:*
- Hypercare scope (from SOW Section 9): triage and resolution of post-go-live defects, guardrail tuning, SIEM alert correlation refinement, regulatory review evidence query assistance, advisory support for new account vending requests.
- Out of scope during hypercare: new features, additional integrations, compliance frameworks not in the original SOW scope. These require a change order or a new engagement.
- Business hours: 09:00–17:00 AEST, Monday to Friday. For P1 issues outside business hours, the on-call contact is the delivery@amatra.com.au email (monitored for P1 severity).
- Hypercare end: Week 24 final handover call with Priya Nair and Rachel Moore to confirm platform stability, all hypercare items resolved, and platform team self-sufficiency.

*Knowledge Transfer Completion:*
- Session 1 — IaC Pipeline & Account Vending (4 hours): completed Week 15. Attended by Platform Engineers.
- Session 2 — Guardrail Management (3 hours): completed Week 15. Attended by Platform Engineers + CISO.
- Session 3 — Security Hub & Compliance Evidence (3 hours): completed Week 16. Attended by Platform Engineers + CISO.
- Session 4 — IAM Identity Center Operations (2 hours): completed Week 16. Attended by Platform Engineers + CISO.
- All sessions recorded; recordings and slide decks delivered to Priya Nair's SharePoint.

*Steady State Recommendations:*
- Monthly: review CloudWatch platform health dashboards (AFT pipeline success rate, Config evaluation errors, GuardDuty finding volumes).
- Quarterly: CISO-led compliance evidence review using Security Hub and Config compliance reports.
- Annually: access review — IAM Identity Center permission set assignments reviewed against current role requirements.
- Change process: all SCP and Config rule changes must be raised via ITSM, reviewed by the Security Engineer role, approved by the CISO, and deployed via the AFT pipeline — no console changes.

*Post-Hypercare Options:*
- Managed Services Agreement: Amatra can provide ongoing CloudOps, guardrail management, and compliance monitoring under a separate MSA. Contact accounts@amatra.com.au to scope.

---

### Slide 9: Acknowledgments & Next Steps
**layout:** eo_bullet_points

**Partnership That Delivered Results**

- James Wu (CTO) — executive sponsorship and decisive governance support
- Priya Nair (Head of Platform Engineering) — technical leadership and knowledge transfer
- Contoso Financial CISO — security rigour and timely architecture sign-off
- Rachel Moore (IT Delivery Manager) — project coordination and milestone delivery
- **This Week:** Final documentation handover and repository transfer
- **Next 30 Days:** Hypercare support with 2-hour P1 response
- **Before April 30:** Regulatory review with full evidence package ready

**SPEAKER NOTES:**

*Acknowledgment Talking Points:*
- This was a genuine partnership — the April 2026 regulatory deadline demanded close collaboration on both sides and the Contoso Financial team delivered on every critical-path dependency.
- James Wu's executive sponsorship meant escalations were resolved quickly — no decision sat unresolved for more than 48 hours.
- Priya Nair's 25% time commitment (as specified in the SOW assumptions) was honoured throughout the engagement — her technical engagement was essential for architecture decisions and UAT.
- The CISO's timely sign-off at Week 4 (architecture gate) and Week 15 (UAT gate) was the single most important client-side action in protecting the April 2026 deadline.
- Rachel Moore's coordination of ITSM change windows, Direct Connect circuit chasing, and IdP team availability kept Phase 2 on track despite the Direct Connect delay.

*Next Steps Timeline:*
- This week: Amatra to transfer the IaC Git repository to Contoso Financial's GitHub organisation; deliver final project closeout report; confirm hypercare escalation contacts with platform team.
- Next 30 days (Weeks 17–20): Hypercare active; focus on guardrail tuning, SIEM alert refinement, and any post-go-live defect resolution.
- Before April 30, 2026: Regulatory review window — Amatra available under hypercare to assist with any audit queries or evidence supplementation.
- Week 24: Final hypercare handover call; confirm platform team self-sufficiency; agree any Phase 2 roadmap next steps.
- Optional (Next Quarter): Phase 2 scoping workshop — AFT expansion, FinOps dashboards, PCI-DSS conformance pack.

---

### Slide 10: Thank You
**layout:** eo_thank_you

Questions & Discussion

**Your Project Team:**
- Project Manager (Amatra): delivery@amatra.com.au | +61 2 9000 0000
- Lead Solution Architect (Amatra): delivery@amatra.com.au | +61 2 9000 0000
- Account Manager (Amatra): accounts@amatra.com.au | +61 2 9000 0001

**SPEAKER NOTES:**

*Talking Points:*
- Open the floor for questions and discussion.
- Have this document's speaker notes available for deep-dive questions on budget, metrics, and architecture.
- Offer to schedule a follow-up session specifically on Phase 2 roadmap planning if there is executive appetite.
- Remind Priya Nair of the hypercare escalation path — delivery@amatra.com.au for P1/P2 issues starting today.
- End on a positive note: the platform is live, the regulatory review is covered, and Contoso Financial now owns a best-practice cloud governance foundation that will serve the organisation for years.

*Backup Detail Topics (if asked):*
- Budget breakdown by phase: Discovery ~$83,600 | Architecture ~$57,700 | Build ~$166,100 | Testing ~$55,700 | Hypercare ~$44,500 | Management ~$74,800.
- Credit details: $30,000 in professional services credits (APN $10K + MAP $15K + volume discount $5K); $29,200 in cloud credits (MAP infrastructure $15K + Solutions Partner $5K + Reserved Instance savings $8K + Terraform partner credit $1.2K).
- 3-year TCO: $478,090 total (Year 1 net $409,830 + Year 2 $34,130 + Year 3 $34,130).
- Managed Services: separate MSA available for ongoing CloudOps post-hypercare — contact accounts@amatra.com.au.
