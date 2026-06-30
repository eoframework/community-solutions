---
presentation_title: Project Closeout
solution_name: MedCore Clinical Decision Support Platform
presenter_name: Engagement Director, Amatra
presenter_email: engagement@amatra.io
presenter_phone: "+1 (800) 555-0200"
presentation_date: "2027-09-30"
client_name: MedCore Health Systems
client_logo: ../../assets/logos/client_logo.png
footer_logo_left: ../../assets/logos/consulting_company_logo.png
footer_logo_right: ../../assets/logos/eo-framework-logo-real.png
---

# MedCore Clinical Decision Support Platform — Project Closeout

## Slide Deck Structure
**10 Slides — Fixed Format**

---

### Slide 1: Title Slide
**layout:** eo_title_slide

**Presentation Title:** Project Closeout
**Subtitle:** MedCore Clinical Decision Support Platform — Implementation Complete
**Presenter:** Engagement Director, Amatra | September 30, 2027

**SPEAKER NOTES:**

*Opening Remarks:*
- Welcome MedCore's executive team — CMO, CIO, CISO, and Clinical Informatics Lead
- Today we formally close the 14-month AWS AI/ML Clinical Decision Support engagement (OPP-2026-0047)
- The platform is live across all 18 MedCore hospitals and 60+ outpatient clinics as of Q3 2027
- We will cover: what was delivered, quality achieved, benefits realized, lessons learned, and what comes next
- Tone: celebrate a successful delivery, be transparent about challenges, set up Phase 2 discussion

---

### Slide 2: Executive Summary
**layout:** eo_bullet_points

**Platform Delivered on Time, on Budget, Across All 18 Hospitals**

- **Project Duration:** 14 months (May 2026 – June 2027), on schedule
- **Budget:** $1,117,432 net Year 1 investment, on budget
- **Phase 1 Go-Live:** 2026-10-31 — sepsis model live before Joint Commission audit
- **Phase 2 Deployment:** 2027-02-28 — readmission and rapid-response models live
- **Enterprise GA:** 2027-06-30 — all 18 hospitals and 60+ clinics active
- **Sepsis Model Accuracy:** AUROC 0.87 (target ≥ 0.85), Clinical Informatics Lead signed off
- **Inference Latency:** < 2.4 seconds P95 (target < 3 seconds) at full 18-hospital load
- **Platform Availability:** 99.96% since Phase 1 go-live (target 99.95%)
- **Clinical Adoption:** 78% active dashboard logins within 90 days per facility (target ≥ 75%)
- **Zero Critical Security Findings:** CISO signed off at each phase go-live gate

**SPEAKER NOTES:**

*Talking Points:*
- Lead with the headline: delivered on time, on budget, hitting every contractual SLA
- Phase 1 hard deadline (2026-10-31) was met — Joint Commission audit proceeded with live sepsis model in production
- Budget: SOW net Year 1 commitment was $1,117,432; final invoice matched within rounding of milestone payments
- AUROC 0.87 exceeds the ≥ 0.85 contractual threshold — validated on MedCore's held-out clinical dataset by the Clinical Informatics Lead
- 99.96% availability was achieved across the hypercare period, marginally exceeding the 99.95% SLA
- 78% adoption exceeded the 75% target within 90 days, validating the train-the-trainer investment

*Budget Breakdown (for Q&A):*
- Professional Services: $885,600 net (4,415 hours, on-estimate)
- Cloud Infrastructure: $195,280 net Year 1 (after $38K in credits); $233,280 Year 2 forecast
- Software Licenses: $5,520 net Year 1 (Datadog + Snyk, net of partner credits)
- Connectivity: $9,432 (Direct Connect + site-to-site VPN, as planned)
- AWS Business Support: $21,600 (as planned)
- Total $82,900 in partner credits applied as committed: MAP, HealthLake Launch, Reserved Instance, APN, Healthcare Competency, volume discount, Datadog, and Training credits

*Timeline Notes:*
- No schedule extensions were required across the 14-month program
- The most significant schedule risk was the Joint Commission hard deadline — mitigated by Phase 1-first sequencing
- Phase 3 enterprise rollout completed one week ahead of the 2027-06-30 target

---

### Slide 3: Solution Architecture
**layout:** eo_visual_content

**What We Built Together**

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

- **Ingestion & Storage**
  - Kinesis + MSK real-time HL7/FHIR pipeline
  - HealthLake FHIR R4 HIPAA PHI datastore
  - SageMaker Feature Store (online + offline)
- **AI/ML & Alerting**
  - 3 SageMaker models: sepsis, readmission, rapid-response
  - Bedrock (Claude) plain-language alert narratives
  - EventBridge + SNS role-based alert routing
- **Security & Compliance**
  - KMS CMK encryption; CloudTrail 7-year audit log
  - Cognito + Azure AD SAML 2.0 SSO with RBAC
  - GuardDuty, Config, Security Hub continuous posture

**SPEAKER NOTES:**

*Architecture Walk-Through (bottom to top):*
- Ingestion Layer: Epic FHIR R4 subscriptions and Mirth Connect HL7 v2.3 feeds enter via 1 Gbps Direct Connect into 10 Kinesis shards and a 3-broker MSK cluster. Dead-letter queues handle malformed messages. This is the most complex integration of the program — the EHR Integration Lead was critical to Epic FHIR API provisioning.
- Storage Layer: HealthLake is the HIPAA-eligible system of record for all patient FHIR data. SageMaker Feature Store online groups serve sub-3-second feature vectors to inference endpoints; offline groups support weekly model retraining. ElastiCache Redis provides the patient context cache. RDS Aurora PostgreSQL (Multi-AZ) stores alert history and risk score time-series.
- ML Inference Layer: Four SageMaker real-time endpoints (sepsis, readmission, rapid-response, ensemble). SHAP explainability is computed inline for every alert. Model Registry governs version promotion. SageMaker Pipelines runs weekly retraining from offline feature groups.
- LLM Narrative Layer: Bedrock (Claude) converts structured alert payloads (risk score, SHAP factors, patient context) into bedside-readable plain-language narratives. Prompt templates developed and validated by Clinical Informatics Lead. All Bedrock invocations are logged for quality monitoring.
- Alert/Application Layer: Lambda handles Epic FHIR write-back (CDS Hooks). React/Amplify clinical dashboard with mobile-responsive bedside view. Cognito enforces SAML 2.0 federation to Azure AD — no separate credentials for clinical staff.
- Observability: CloudWatch + X-Ray + Datadog APM cover the full inference path with P95 latency alarms and PagerDuty escalation.

*Presales Alignment Confirmation:*
- All services exactly match the Solution Briefing and SOW architecture specification — no scope additions
- Multi-region: us-east-1 primary, us-west-2 passive DR with Route 53 health-check failover (tested in staging)
- Architecture diagram is the canonical as-built diagram from the pre-sales Solution Briefing

---

### Slide 4: Deliverables Inventory
**layout:** eo_table

**Complete Documentation, Systems & Training Package**

<!-- TABLE_CONFIG: widths=[32, 43, 25] -->
| Deliverable | Purpose | Location |
|-------------|---------|----------|
| **Architecture & Design Docs (HLD/LLD)** | As-built architecture and component specifications | `/delivery/detailed-design.md` |
| **IaC Repository (Terraform/CDK)** | All 4-environment provisioning modules | `/delivery/scripts/terraform/` |
| **Implementation & Configuration Guide** | Step-by-step deployment and config procedures | `/delivery/implementation-guide.md` |
| **Test Plan & Results Report** | Test cases, model validation, security sign-off | `/delivery/test-plan.csv` |
| **ML Model Cards (×3)** | Sepsis, readmission, rapid-response model docs | `/delivery/model-cards/` |
| **Operational Runbooks** | Pipeline, inference, alert-system SOPs | `/delivery/runbooks/` |
| **SOC 2 Type II Evidence Package** | CloudTrail, Config, access-control evidence | `/delivery/compliance/` |
| **Clinical Train-the-Trainer Materials** | Dashboard training for all 18 facility champions | `/delivery/training/` |

**SPEAKER NOTES:**

*Deliverable Acceptance Status:*
- All 31 SOW deliverables formally accepted by the named acceptance authorities (CMO, CIO, CISO, Clinical Informatics Lead, EHR Integration Lead)
- HLD/LLD: accepted at M2 (Week 7) by CIO and Solution Architect
- IaC Repository: accepted at M3 (Week 10) — all 4 environments (Dev, QA, Staging, Production) provisioned via Terraform/CDK with zero manual console changes in production
- Test Plan & Results: accepted at M7 (Week 36) — full functional, integration, performance, model accuracy, security, and UAT results included
- ML Model Cards: one card per model documenting training data, AUROC/sensitivity/specificity, known limitations, retraining schedule, and bias assessment
- SOC 2 Evidence Package: includes CloudTrail export, Config snapshots, KMS key inventory, IAM role catalogue — handed to CISO for SOC 2 Type II audit engagement
- Train-the-Trainer materials: delivered to 18 facility Clinical Champions in a 2-day facilitated session; each champion then trained their facility cohort locally

*Repository Access:*
- IaC repository transferred to MedCore's version-controlled repository (GitHub / AWS CodeCommit) per SOW Section 9 handover commitments
- All MedCore-owned IP (custom models, FHIR connectors, dashboard source code, IaC) is work-for-hire — ownership transferred to MedCore upon final payment per SOW IP clause

---

### Slide 5: Quality & Performance
**layout:** eo_two_column

**Exceeding All Clinical and Technical Quality Targets**

- **Model Accuracy**
  - Sepsis AUROC: 0.87 (target ≥ 0.85)
  - Readmission AUROC: 0.83 (target ≥ 0.80)
  - Rapid-Response AUROC: 0.86 (target ≥ 0.82)
  - SHAP explainability: 100% alert coverage
  - LLM narratives: ≥ 5 clinical reviewers signed off
- **Platform Performance**
  - Inference latency P95: 2.4 s (target < 3 s)
  - Platform availability: 99.96% (target 99.95%)
  - False-positive rate: reduced 43% (target 40%)
  - Zero Critical defects at each phase go-live
  - Multi-region failover RTO: 3.2 hrs (target ≤ 4 hrs)

**SPEAKER NOTES:**

*Testing Methodology Summary:*
- Functional: all ingestion pipeline, Feature Store, inference endpoint, and dashboard test cases passed; automated and version-controlled in CI/CD
- Performance: AWS Distributed Load Testing + Locust simulated full 18-hospital load (2,500+ concurrent inpatients, 10M+ Kinesis events/month). P95 latency of 2.4 seconds at peak was 20% below the 3-second SLA target, with Kinesis shard headroom of 35% at peak
- Security: HIPAA security controls checklist signed off by CISO; KMS CMK encryption validated across all PHI stores; CloudTrail PHI access audit validated end-to-end. External pen test completed — all Critical and High findings remediated and re-tested before CISO go-live clearance
- Model accuracy: Sepsis AUROC 0.87 tested on held-out clinical dataset signed off by Clinical Informatics Lead (SOW gate). Readmission and rapid-response models exceeded their respective target AUROCs
- False-positive reduction of 43% surpassed the 40% SOW target — directly validated by nursing staff feedback during Phase 1 UAT at the pilot facility
- Multi-region failover: Route 53 DNS failover test completed in staging — actual failover to us-west-2 took 3.2 hours, within the 4-hour RTO SLA. RPO validated at 11 minutes (within the 15-minute target)
- LLM narratives: 5 nurses and 3 hospitalists participated in narrative quality review — all narratives rated "clinically useful" or "very useful"; no alerts blocked for narrative quality
- SOC 2 Type II readiness evidence package delivered to CISO; AWS Config rules validated > 30 HIPAA controls continuously

---

### Slide 6: Benefits Realized
**layout:** eo_table

**Delivering Measurable Clinical and Operational Value**

<!-- TABLE_CONFIG: widths=[32, 18, 18, 32] -->
| Benefit Category | Target | Achieved | Impact |
|------------------|--------|----------|--------|
| **Sepsis Mortality Reduction** | −15% (12 months) | −12% at 6 months | On track; 12-month measurement pending |
| **30-Day Readmission Rate** | −20% (18 months) | −9% at 6 months | Phase 2 models deployed; trend positive |
| **False-Positive Alert Rate** | −40% vs. baseline | −43% validated | Nursing alert fatigue measurably reduced |
| **End-to-End Inference Latency** | < 3 s end-to-end | 2.4 s P95 | 20% better than SLA; bedside experience strong |
| **Platform Availability** | 99.95% uptime | 99.96% actual | Exceeds SLA across all post-go-live phases |
| **Clinical Staff Adoption** | ≥ 75% per facility | 78% at 90 days | Train-the-trainer model proven effective |
| **Alert Explainability** | 100% SHAP coverage | 100% coverage | Clinicians act on alerts without chart review |

**SPEAKER NOTES:**

*Clinical Outcome Context:*
- Sepsis mortality: −12% at the 6-month measurement point is tracking ahead of the historical curve from comparable implementations. The 15% target has an explicit 12-month measurement window from go-live; MedCore's Quality & Safety team will complete the 12-month assessment by Q3 2028. Reference: similar regional health system implementation achieved 18% reduction by month 6 (Solution Briefing success story).
- Readmission rate: −9% at 6 months is early data; readmission benefits typically compound as the model accumulates production feedback. Phase 2 models (readmission + rapid-response) were deployed 2027-02-28 — we are still within the 18-month measurement window (target date Q4 2028).
- False-positive reduction of 43% directly confirmed by nursing staff in UAT and production. The Joint Commission (November 2026) was briefed on this metric as evidence of clinical alert system improvement.
- Adoption: 78% active dashboard logins within 90 days per facility exceeded the 75% SOW target. Lowest-performing facility reached 71% — a focused re-engagement plan was executed with the facility Clinical Champion to close the gap. Monthly adoption trend is positive across all facilities.
- Explainability: SHAP values delivered with every single alert (0 exceptions). Bedrock narrative quality assessment confirmed all narratives are parseable within the 3-second window. No adverse clinical events attributed to AI model outputs during hypercare.

*ROI Trajectory:*
- Year 1 net investment: $1,117,432. Every 1% additional readmission reduction across MedCore's 18-hospital network is estimated to avoid approximately $2.4M in avoidable re-admission costs annually (based on MedCore's average readmission cost profile). At projected 20% reduction, annual avoidable cost savings exceed $48M — consistent with the comparable national health insurer case study referenced in the Solution Briefing.

---

### Slide 7: Lessons Learned & Recommendations
**layout:** eo_two_column

**Insights for Continuous Improvement**

- **What Worked Well**
  - Phase 1-first sequencing met Joint Commission deadline
  - Train-the-trainer model exceeded adoption target
  - IaC-only production changes eliminated drift
  - Blue/green deployment enabled zero-downtime go-lives
  - SHAP + Bedrock narratives accelerated clinical trust
- **Challenges Overcome**
  - Epic FHIR API access delayed 3 weeks; mitigated by parallel synthetic data testing
  - Direct Connect provisioning lead time compressed Phase 2 start; resolved via VPN bridging
- **Recommendations**
  - Add Phase 2: 4th model (medication reconciliation)
  - Expand QuickSight dashboards to facility executives
  - Implement SageMaker Model Monitor auto-retraining
  - Establish quarterly clinical AI governance reviews
  - Evaluate Bedrock prompt optimisation for specialties

**SPEAKER NOTES:**

*What Worked Well — Detail:*
- Phase 1-first sequencing: the decision to prioritize sepsis + ingestion pipeline for 2026-10-31 was the right call. It gave the Clinical Informatics Lead a live production model to validate risk thresholds before Phase 2 models were trained, improving model design quality. It also gave nursing staff 4 months of adoption experience before Phase 2 dashboard features were added.
- Train-the-trainer: investing in 2-day facilitated sessions for Clinical Champions at each facility paid dividends. Facilities where the Clinical Champion was a senior charge nurse had the highest adoption rates. Recommended for all future multi-facility healthcare AI rollouts.
- IaC-only mandate: zero manual console changes in production (enforced via SCP). This eliminated configuration drift and made the rollback procedure a single CodePipeline execution. Estimated to have saved 40+ hours of incident investigation compared to prior Amatra engagements without this constraint.
- Blue/green deployment: SageMaker endpoint blue/green with 48-hour shadow mode before clinical activation removed all rollback risk from Phase 1 and Phase 2 go-live days.
- SHAP + Bedrock: the combination of SHAP contributing factors and a plain-language Bedrock narrative in the same alert card was consistently cited by nurses in UAT feedback as the reason they trusted the AI alert rather than ignoring it. This design decision was the primary driver of exceeding the 75% adoption target.

*Challenges — Root Causes and Lessons:*
- Epic FHIR API: MedCore's EHR team required an internal Epic governance review before granting FHIR API credentials — this was not surfaced during pre-sales discovery. Lesson: future SOWs should include an explicit assumption and dependency on Epic FHIR API sandbox access within 2 weeks of kickoff (this SOW did include it, but the client-side approval path was longer than anticipated). Mitigation: parallel synthetic data test harness in Dev environment allowed ML model feature engineering to proceed unblocked.
- Direct Connect: provisioning lead time was 6 weeks vs. the 4-week assumption. Lesson: add Direct Connect lead time to the risk register at kickoff and initiate the order at contract execution, not at project kickoff. Mitigation: site-to-site VPN was activated as the interim connectivity path, allowing Phase 2 data pipeline testing to proceed on schedule.

*Recommendations — Priority and Estimated Effort:*
- 4th model (medication reconciliation): natural extension of the existing Feature Store and Bedrock narrative layer. Estimated 8–10 weeks of ML engineering effort. Recommend scoping in Q1 2028 planning.
- Executive QuickSight dashboards: facility-level CMO/CNO view of sepsis mortality trend, readmission rates, and model performance. Estimated 3–4 weeks of analytics engineering. High ROI for executive engagement.
- SageMaker Model Monitor auto-retraining: currently weekly retraining is manually triggered. Automating this via Model Monitor drift thresholds would reduce model staleness risk. Estimated 2 weeks of MLOps engineering.
- Quarterly clinical AI governance: recommend a standing quarterly review between MedCore CMO, Clinical Informatics Lead, and Amatra account team to review model performance, alert quality, and roadmap prioritization.
- Bedrock prompt optimization for specialties: current prompts are generalized for all clinical roles. Specialty-specific prompts (e.g., ICU, oncology, cardiology) could improve narrative clinical relevance. Recommended for Q2 2028 sprint.

---

### Slide 8: Support Transition
**layout:** eo_two_column

**Ensuring Operational Continuity Post-Hypercare**

- **Hypercare (Weeks 1–8 post-GA)**
  - Dedicated Senior Support Engineer on MedCore account
  - 1-hour Critical response SLA (patient safety events)
  - 4-hour High response SLA (alert delivery degraded)
  - Daily monitoring review with MedCore IT Operations
  - Hypercare ends: Q3 2027 + 8 weeks
- **Steady State (Day 57+)**
  - MedCore IT Operations owns platform with full runbooks
  - Monthly model performance review (QuickSight)
  - Quarterly Amatra business review available
  - Optional Managed Services Agreement for 24/7 coverage
- **Escalation Contacts**
  - L1 Support: support@amatra.io | +1 (800) 555-0200
  - L2 Escalation: engagement@amatra.io (Engagement Director)

**SPEAKER NOTES:**

*Hypercare Coverage Details:*
- Extended business hours: Monday–Friday 7am–10pm ET with on-call paging for Critical incidents outside hours
- Critical (P1): patient safety impact or platform unavailability — 1-hour response, 4-hour resolution target
- High (P2): alert delivery degraded, model latency elevated above 3 seconds — 4-hour response, next-business-day resolution
- Medium/Low (P3/P4): 2-business-day response
- Scope: defect resolution for issues originating from the delivered solution, configuration assistance, model performance monitoring
- Out of scope for hypercare: new features, additional models, facility additions — these require a separate work order

*What's Excluded from Hypercare (important for CIO/CISO):*
- Epic EHR changes, Azure AD tenant changes, Mirth Connect platform upgrades
- AWS service outages (covered by AWS Business Support — MedCore holds Business Support subscription)
- Any changes driven by MedCore infrastructure modifications post-go-live

*Transition to Steady State:*
- At hypercare end, MedCore IT Operations holds full runbooks for: ingestion pipeline failure, SageMaker endpoint latency breach, Bedrock quota exhaustion, Direct Connect failover, and model rollback
- All recorded knowledge transfer sessions delivered; technical track (4 half-day sessions) completed with MedCore IT and data engineering team
- Amatra Engagement Director recommends scheduling an MSA conversation before hypercare ends if MedCore wants 24/7 managed coverage post-transition

*Managed Services Agreement (optional):*
- 24/7 monitoring and incident response
- Monthly model retraining oversight
- Quarterly model performance reviews
- AWS cost optimisation recommendations
- Security patching for ECS container images
- Contact engagement@amatra.io for MSA scope and pricing

---

### Slide 9: Acknowledgments & Next Steps
**layout:** eo_bullet_points

**A Genuine Partnership — Thank You, MedCore**

- CMO and CIO for executive sponsorship and go-live approvals
- Clinical Informatics Lead for model validation and UAT leadership
- CISO for HIPAA compliance diligence and security gate sign-offs
- EHR Integration Lead for Epic FHIR API and Mirth coordination
- **This Week:** Final documentation and IaC repository handover
- **Next 30 Days:** Hypercare active — daily monitoring reviews with IT Ops
- **Q1 2028:** Recommend Phase 2 planning workshop (4th model, exec dashboards)

**SPEAKER NOTES:**

*Recognition Details:*
- CMO: executive sponsorship was decisive. The November 2026 Joint Commission deadline created intense schedule pressure — CMO's clear prioritization of the sepsis pilot enabled the right resourcing decisions early.
- CIO: technical ownership of the AWS environment, account vending, and budget governance. The IaC-only production mandate was championed by the CIO — it paid dividends throughout the program.
- Clinical Informatics Lead: approximately 8–10 hours per week of engagement during ML model development and UAT — far beyond the minimum 8 hours/week assumption. Model accuracy and clinical narrative quality are directly attributable to this level of clinical engagement.
- CISO: HIPAA BAA execution and security gate sign-offs at each phase were thorough and timely. The CISO's insistence on full HIPAA controls validation before any PHI entered production set the right security tone for the engagement.
- EHR Integration Lead: Epic FHIR API credentials and Mirth Connect adapter coordination were the most technically complex client-side dependency. The EHR Integration Lead's direct engagement with the Epic governance team unblocked the 3-week credential delay.

*Next Steps Timeline:*
- This week: final IaC repository committed to MedCore GitHub; all 31 SOW deliverables formally handed over; final invoice submitted (Milestone M9 — Hypercare End)
- Next 30 days: hypercare active (extended hours + on-call). Daily morning monitoring review call between Amatra Senior Support Engineer and MedCore IT Operations. Any outstanding items from hypercare logged and resolved.
- Q1 2028: recommend a Phase 2 planning workshop to scope the 4th model (medication reconciliation), executive QuickSight dashboards, and automated Model Monitor retraining. Amatra account team will prepare a proposal for review at the quarterly business review.

---

### Slide 10: Thank You
**layout:** eo_thank_you

Questions & Discussion

**Your Amatra Project Team:**
- Engagement Director / PM: engagement@amatra.io | +1 (800) 555-0200
- Lead Solutions Architect: solutions@amatra.io | +1 (800) 555-0201
- ML/AI Engineering Lead: ml@amatra.io | +1 (800) 555-0202

**SPEAKER NOTES:**

*Closing Remarks:*
- Open the floor for questions and discussion — allow ample time for executive Q&A
- Key backup topics to have ready:
  - Budget actuals breakdown (see Slide 2 speaker notes for full breakdown)
  - 12-month clinical outcome measurement timeline (Slide 6 speaker notes)
  - MSA / managed services proposal if CIO raises it (Slide 8 speaker notes)
  - Phase 2 scope and rough order of magnitude (Slide 7 speaker notes)
- End on a positive note: this is one of the most clinically impactful healthcare AI programs delivered in the MedCore region — the work matters beyond the technology
- Offer to schedule 1:1 follow-ups with CMO (clinical outcomes), CIO (technical roadmap), and CISO (compliance posture) if they prefer focused sessions
- Remind attendees that hypercare remains active — Amatra is still a phone call away for the next 8 weeks
