---
presentation_title: Project Closeout
solution_name: Amatra Agentic Pre-Sales Platform on AWS
presenter_name: Marcus Patel
presenter_email: engagement@amatra.io
presenter_phone: "+1 (800) 555-0190"
presentation_date: 2026-04-30
client_name: PREDICTif Solutions
client_logo: ../../assets/logos/client_logo.png
footer_logo_left: ../../assets/logos/consulting_company_logo.png
footer_logo_right: ../../assets/logos/eo-framework-logo-real.png
---

# Amatra Agentic Pre-Sales Platform on AWS — Project Closeout

## Slide Deck Structure
**10 Slides — Fixed Format**

---

### Slide 1: Title Slide
**layout:** eo_title_slide

**Presentation Title:** Project Closeout
**Subtitle:** Amatra Agentic Pre-Sales Platform on AWS — Implementation Complete
**Presenter:** Marcus Patel | 2026-04-30

---

### Slide 2: Executive Summary
**layout:** eo_bullet_points

**Project Successfully Delivered**

- **Duration:** 12 weeks (Q1–Q2 2026), on schedule
- **Go-Live:** End of April 2026 — executive demo delivered
- **Budget:** $287,800 net Year 1, within approved envelope
- **Effort Reduction:** 90% per-engagement — 10 hrs to <1 hr
- **Latency:** P95 end-to-end generation under 60 minutes
- **Quality:** Zero critical defects at go-live
- **Token Spend:** Per-solution Bedrock cost at or below $5
- **Quota Governance:** Zero overruns; atomic enforcement live
- **Throughput:** 200 solutions/month steady-state confirmed
- **ROI:** 12-month payback on track via time savings

**SPEAKER NOTES:**

*Talking Points:*
- Lead with confidence: delivered on time, on budget, on scope.
- The 90% effort reduction is the headline — 9 hours saved per engagement across 120 consultants.
- Zero critical defects reflects the rigorous three-phase testing strategy across all 12 artifact types.
- P95 latency under 60 minutes was validated in load testing at 200 solutions/month throughput.
- The executive demo for Sarah Lin (CRO) was the hard deadline — delivered on time as committed.

*Background Details:*
- Budget: $250K PS list; $30K PS credits applied; $220K net PS. Year 1 cloud $88,920 list with $30K infrastructure credits netting $58,920. Total Year 1 net = $287,800 vs. $350K–$500K approved envelope.
- Timeline: 12 weeks as scoped in SOW; no change requests required; April 2026 deadline met.
- ROI model: 120 consultants × 10 solutions/month × 9 hours saved × $150/hour blended rate = ~$1.62M/year recaptured.
- Quota: DynamoDB conditional writes tested at peak concurrency; zero race conditions observed.

---

### Slide 3: Solution Architecture
**layout:** eo_visual_content

**What We Built Together**

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

- **Orchestration & API Layer**
  - API Gateway HTTP API v2 (11 routes)
  - Step Functions multi-agent state machine
  - Cognito User Pool, 30-day refresh tokens
- **AI Generation & Validation**
  - Claude Sonnet 4.6 for artifact generation
  - Claude Haiku 4.5 for cost validation
  - Up to 3 automated retries per artifact
- **Data, Storage & Delivery**
  - S3 artifacts; DynamoDB quota enforcement
  - Secrets Manager GitHub PAT auto-rotation
  - Automated commit to public GitHub repo

**SPEAKER NOTES:**

*Talking Points:*
- Walk through the architecture top-down: API edge → orchestration → agents → data layer.
- Cognito JWT authoriser is the single gate for all 11 Lambda routes; no unauthenticated request reaches an agent.
- Step Functions provides a durable audit trail of every agent invocation, retry, and state transition.
- eof-tools (~30 Python modules) baked into the AgentCore Docker image, producing DOCX, PPTX, and XLSX in the same container.

*Technical Details:*
- VPC: purpose-built us-west-2 VPC with private subnets; NAT Gateway for GitHub egress; VPC endpoints for Bedrock, DynamoDB, S3, ECR, Secrets Manager, and CloudWatch Logs.
- Five Bedrock AgentCore agents: Input Validator, Pre-Sales Generator, Delivery Generator, Code Generator, EO Validator.
- DynamoDB on-demand, three tables: user_profiles, solution_state, quota_global.
- All architecture matches Solution Briefing specification exactly; no scope additions beyond presales commitment.

*Presales Alignment:*
- Services deployed match SOW in-scope list exactly: Cognito, API GW, Lambda, Step Functions, AgentCore, Bedrock, DynamoDB, S3, ECR, Secrets Manager, CloudWatch, VPC, GuardDuty, CloudTrail, CodePipeline/CodeBuild, Terraform IaC.
- No out-of-scope services were added.

---

### Slide 4: Deliverables Inventory
**layout:** eo_table

**Complete Documentation & Automation Package**

<!-- TABLE_CONFIG: widths=[35, 40, 25] -->
| Deliverable | Purpose | Location |
|-------------|---------|----------|
| **Architecture Design Document** | Agent-graph topology, ADRs, OpenAPI spec | `/delivery/detailed-design.docx` |
| **Terraform IaC Full Platform** | Full infra provisioning (terraform validate ✓) | `/delivery/scripts/terraform/` |
| **pip-installable CLI (14 subcommands)** | Consultant self-service generation | `pip install amatra-cli` (PyPI) |
| **Test Results Report** | UAT sign-off, security, CloudWatch baseline | `/delivery/test-plan.xlsx` |
| **Operational Runbooks** | Agent failure, quota reset, PAT rotation, DR | `/delivery/runbook.docx` |
| **As-Built Documentation Package** | API reference, deployment guide | `/delivery/implementation-guide.docx` |
| **Knowledge Transfer Materials** | Engineering deep-dive + pre-sales training | `/delivery/training/` |
| **Optimisation & Phase 2 Roadmap** | Cost tuning and Phase 2 scope | `/delivery/project-plan.xlsx` |

**SPEAKER NOTES:**

*Talking Points:*
- All 32 SOW deliverables have been completed and formally accepted.
- This slide surfaces the eight most strategically significant deliverables; the full register is in the project plan.
- Terraform IaC (terraform validate passing in CI) means the entire platform can be rebuilt in under 4 hours from IaC alone.
- Knowledge transfer: 4-hour engineering deep-dive (recorded to S3) and 2-hour pre-sales workflow training for 120 consultants.

*Deliverable Details:*
- Architecture Design Document (SOW #3): agent-graph topology, OpenAPI spec for all 11 routes, all ADRs.
- Test Results Report (SOW #26): unit (>80% coverage), integration (12 artifact types), load (200 solutions/month), security (OWASP API Top 10), UAT sign-off from Marcus Patel, Daniel Park, and CTO.
- Runbooks (SOW #27): five scenarios — agent timeout, quota throttle, GitHub PAT expiry, Bedrock disruption, Cognito outage.
- Phase 2 Roadmap (SOW #32): delivered at Week 20 hypercare conclusion.

---

### Slide 5: Quality & Performance
**layout:** eo_two_column

**Exceeding All Quality Targets**

- **Testing Metrics**
  - Unit coverage: 82% (target: >80%) ✓
  - All 12 artifact types pass end-to-end ✓
  - Critical defects at go-live: 0 ✓
  - UAT signed: Patel, Park, CTO ✓
  - OWASP API Top 10: all 11 routes clear ✓
- **Performance Metrics**
  - P95 latency: <60 min (target: <60 min) ✓
  - P50 latency: ~28 min (target: <30 min) ✓
  - Token spend: ≤$5/solution (target: ≤$5) ✓
  - Throughput: 200 solutions/month confirmed ✓
  - Quota enforcement: 0 race conditions ✓

**SPEAKER NOTES:**

*Talking Points:*
- Quality was embedded from Phase 1 — security and quota controls were production-grade before a single agent was written.
- The 0-critical-defects result at go-live is a direct outcome of the three-phase test strategy: unit, integration, and formal UAT.
- All 12 artifact types passing end-to-end (DOCX, PPTX, XLSX via eof-tools) was milestone M4 gate criteria.
- P95 <60 minutes was validated in load test at 200 solutions/month throughput — exactly as specified in SOW success metrics.

*Detailed Metrics:*
- Unit tests: pytest-cov at 82% coverage across all Lambda handlers, agent implementations, quota enforcement, and GitHub integration module.
- Integration tests: every artifact type (5 presales + 6 delivery + 1 Terraform IaC bundle) exercised end-to-end through all 5 agents.
- Security: IAM least-privilege validated; Cognito JWT tamper/expiry test confirmed; no wildcard resource policies in production.
- Load test: DynamoDB atomic conditional writes under concurrent load — zero throttle events; on-demand scaling handled peak burst cleanly.
- All SOW SLA targets green: P95 <60 min ✓; token spend ≤$5 ✓; zero quota overruns ✓; 90% effort reduction ✓.

---

### Slide 6: Benefits Realized
**layout:** eo_table

**Delivering Measurable Business Value**

<!-- TABLE_CONFIG: widths=[30, 20, 20, 30] -->
| Benefit Category | Target | Achieved | Impact |
|------------------|--------|----------|--------|
| **Per-Engagement Effort** | 90% reduction | 90% reduction | 10 hrs → <1 hr per engagement |
| **End-to-End Latency (P95)** | <60 min | <60 min | Same-hour delivery standard |
| **Token Cost per Solution** | ≤$5 | ≤$5 | Predictable, budgetable spend |
| **Quota Overruns** | Zero | Zero | Full governance from day 1 |
| **Artifact Types Automated** | 12 types | 12 types | No manual artifact production |
| **Monthly Throughput** | 200 solutions | 200 solutions | Pipeline capacity unlocked |
| **Annual Consultant Time Saved** | $1.62M | On track | 120 consultants × 9 hrs × $150/hr |
| **ROI Payback Period** | 12 months | 12 months projected | Within approved business case |

**SPEAKER NOTES:**

*Talking Points:*
- Every target metric from the SOW success criteria has been met or exceeded at go-live.
- The $1.62M annual consultant time savings is the headline ROI figure.
- 12-month payback calculated against the $287,800 net Year 1 investment (PS net + Year 1 cloud net).
- Parallel pipeline throughput means the sales organisation can now run multiple engagements concurrently — previously blocked by single-threaded manual generation.

*Detailed Impact:*
- Time savings: 6–10 hours manual baseline vs. <30 minutes human review post-platform. Net saving: ~9 hours/engagement.
- Cost per solution: $5 Bedrock token spend + ~$0.50 infrastructure at 200 solutions/month = $5.50 total vs. ~$1,500 senior-consultant equivalent.
- 3-year ROI: $565,315 total cost vs. ~$4.86M conservative 3-year consultant savings. Net 3-year benefit: ~$4.3M.
- Pipeline growth: removing the manual bottleneck enables scaling to 1,000+ solutions/month without architectural changes.

---

### Slide 7: Lessons Learned & Recommendations
**layout:** eo_two_column

**Insights for Continuous Improvement**

- **What Worked Well**
  - Week 1 AgentCore spike de-risked early
  - IaC-first approach enabled clean rollback
  - Atomic DynamoDB quota prevented overruns
  - Haiku 4.5 cut validation cost by ~5×
  - Three-phase tests: zero go-live defects
- **Challenges Overcome**
  - eof-tools SME days needed; budget 3 next time
  - Bedrock quota pre-approval: start in Week 1
- **Recommendations**
  - Launch Phase 2: multi-region + analytics
  - Add GUI portal for non-CLI consultants
  - Scale to 1,000+ solutions/month
  - Tune Haiku prompts to reduce cost further
  - Quarterly architecture review cadence

**SPEAKER NOTES:**

*Talking Points:*
- The Week 1 AgentCore spike was the single most important risk-mitigation action — confirmed a new AWS service was viable before any production code was committed.
- IaC-first (Terraform from Day 1) meant the Phase 3 production deployment was a zero-drama `terraform apply` rather than a manual configuration exercise.
- Atomic DynamoDB conditional writes were designed in Phase 1 and stress-tested in Phase 3 — zero quota overruns observed across all load test runs.

*Detailed Lessons:*
- eof-tools integration: SME was available for 2 full days as agreed; recommend budgeting 3 days for Phase 2 if new converter types are added.
- Bedrock quota: Sonnet 4.6 + Haiku 4.5 quota request should be raised in Week 1 of any future agentic engagement (AWS lead time: 1–2 weeks).
- Haiku 4.5 cost advantage: ~$0.40/solution validation cost vs. ~$2.00 if Sonnet 4.6 were used — the Haiku-for-validation pattern is reusable across all future Bedrock projects.

*Recommendations Roadmap:*
- Phase 2 (estimated 8–10 weeks): multi-region active-passive (us-east-1 DR), advanced analytics dashboard, additional artifact types, CRM integration stub.
- GUI portal: ~6–8 weeks; unlocks adoption by non-CLI consultants and accelerates path to 1,000+ solutions/month.
- Quarterly reviews: schedule with Marcus Patel and Daniel Park to assess Bedrock model upgrades, cost optimisation, and quota headroom.

---

### Slide 8: Support Transition
**layout:** eo_two_column

**Ensuring Operational Continuity**

- **Hypercare Period (Weeks 13–20)**
  - Business hours + P1 24×7 coverage active
  - P1 response ≤1 hr; P2 ≤4 business hrs
  - Daily CloudWatch alarm monitoring
  - Vendor break-glass IAM; expires Week 20
  - Escalation: marcus.patel@predictif.com
  - Vendor escalation: engagement@amatra.io
- **Post-Hypercare Steady State**
  - Full platform ownership: PREDICTif ops
  - Monthly CloudWatch performance reviews
  - Quarterly business reviews with Sarah Lin
  - Phase 2 Roadmap delivered at Week 20
  - Managed Services Agreement for ongoing SLA
  - Formal access request for any vendor re-entry

**SPEAKER NOTES:**

*Talking Points:*
- The 8-week hypercare window (SOW Weeks 13–20) covers the ramp-up to 200 solutions/month steady state — the period of highest operational risk.
- Vendor break-glass IAM access is time-limited and auto-expires at Week 20; after that, all vendor access requires a formal access request process.
- P1 24×7 coverage means a Bedrock outage or Cognito User Pool failure receives a vendor response within 1 hour regardless of time of day.

*Support Details:*
- Severity definitions: P1 = platform down or data loss risk; P2 = major functionality impaired; P3 = non-critical question or minor cosmetic issue.
- Hypercare scope includes: Bedrock quota monitoring, agent failure triage, validation retry rate investigation, CloudWatch alarm response, quota counter adjustment, GitHub PAT rotation support, and minor bug fixes.
- Out of scope during hypercare: new features, additional artifact types, multi-region, Cognito User Pool changes beyond bug fixes.
- After Week 20: refer to separate Managed Services Agreement for SLA-backed ongoing operations and proactive cost optimisation.

---

### Slide 9: Acknowledgments & Next Steps
**layout:** eo_bullet_points

**Partnership That Delivered Results**

- Sarah Lin (CRO) — executive sponsorship and go-live sign-off
- Marcus Patel — technical leadership and deliverable acceptance
- Daniel Park — delivery operations and runbook sign-off
- **This Week:** Final documentation package handover complete
- **Next 30 Days:** Hypercare support with daily monitoring
- **Next Quarter:** Phase 2 planning workshop scheduled
- **Ongoing:** Monthly and quarterly business reviews

**SPEAKER NOTES:**

*Talking Points:*
- Success was a genuine joint effort — PREDICTif stakeholders met every SOW commitment on schedule.
- Marcus Patel's 4+ hours/week availability throughout all 12 weeks was instrumental in rapid deliverable acceptance.
- The CTO's Week 3 Cognito sign-off unblocked Phase 1 completion on schedule — worth acknowledging publicly.
- Daniel Park's runbook acceptance in Week 12 completed the operational handover cleanly.

*Follow-up Actions:*
- Documentation handover: all 32 SOW deliverables formally accepted; handover checklist signed by Marcus Patel.
- Hypercare standup: daily CloudWatch review call for first 2 weeks (Weeks 13–14), then weekly through Week 20.
- Phase 2 planning: workshop with Sarah Lin, Marcus Patel, and Daniel Park; Phase 2 Roadmap (SOW #32) is the input document.
- Procurement: notify if projected Year 2 AWS spend ($121,122) approaches the existing spend envelope; coordinate Year 2 Bedrock credit applications.

---

### Slide 10: Thank You
**layout:** eo_thank_you

Questions & Discussion

**Your Project Team:**
- Engagement Lead: engagement@amatra.io | +1 (800) 555-0190
- Technical Lead (Client): marcus.patel@predictif.com
- Executive Sponsor: Sarah Lin (CRO), PREDICTif Solutions

**SPEAKER NOTES:**

*Talking Points:*
- Open the floor for questions and discussion — executives frequently ask about Phase 2 scope, ongoing support costs, and the multi-region roadmap.
- Have the Benefits Realized table (Slide 6) ready to revisit if Sarah Lin wants to discuss ROI methodology in detail.
- Offer to schedule a dedicated Phase 2 scoping session — this closeout is the natural transition point into the next engagement.
- End on a positive note: the platform is live, the demo was delivered, and PREDICTif's 120 consultants now have a self-service generation capability that did not exist 12 weeks ago.
- Key backup data points for Q&A: net Year 1 investment = $287,800; annual consultant savings = ~$1.62M; ROI payback = ~12 months; 3-year net benefit = ~$4.3M.
