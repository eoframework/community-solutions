---
document_title: Statement of Work
technology_provider: AWS
project_name: ANP Streaming AI Mood & Recommendation API
client_name: ANP Streaming
client_contact: Lilly Goyah | CEO | lilly.goyah@anpstreaming.com
consulting_company: nClouds, Inc.
consultant_contact: Jonas Bull | jonas.bull@nclouds.com
opportunity_no: OPP-2025-001
document_date: June 2025
version: 1.0
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Statement of Work (SOW) defines the scope, deliverables, roles, and terms for the design, build, and handover of an **AI Mood Classification and Recommendation API** on AWS for ANP Streaming. nClouds, Inc. will deliver a fully serverless REST API — callable from the existing FlutterFlow mobile app without any frontend changes — that classifies content by mood/emotion and returns personalized playlists based on a user's listening history. The engagement is expected to complete within **six weeks** and is structured to be fully offset by AWS partner funding.

**Project Duration:** 6 weeks

**Key Outcomes:**
- Two production-ready REST API endpoints: `POST /classify` (mood classification) and `GET /recommend` (personalized playlist)
- Automated mood/emotion tagging pipeline for new catalog uploads via Amazon Bedrock
- Serverless AWS infrastructure (Lambda, API Gateway, DynamoDB, S3, Bedrock) provisioned across Dev and Production environments
- Security baseline with IAM least-privilege, API key authentication, HTTPS enforcement, and CloudWatch observability
- Comprehensive API documentation, operational runbook, and knowledge transfer to ANP's technical contact

**Expected Benefits:**
- Personalized content discovery drives deeper listener engagement and longer session times
- Auto-tagging new uploads with mood labels eliminates manual curation effort
- Serverless architecture ensures near-zero idle cost — ANP pays only for actual API usage
- AWS partner credits of **$15,000** offset all professional services fees in Year 1
- Total 3-year infrastructure investment of approximately **$8,254** for a fully operational AI capability

---

# Background & Objectives

ANP Streaming is a faith-based Christian music and podcast streaming application, delivered today as a FlutterFlow mobile app backed by Firebase. The platform hosts a catalog of songs and podcasts with titles, artists, basic tags, and lyric or transcript text. There is currently no AI-driven personalization or automated content classification capability.

## Current State

ANP Streaming's existing platform serves a growing faith-based audience but lacks the intelligent discovery features that modern listeners expect. Key challenges include:

- **No Content Personalization:** The app surfaces content without regard for a user's mood, preferences, or recent listening history, resulting in a generic discovery experience.
- **Manual Content Tagging:** New uploads require manual mood and emotion tagging by the ANP team, creating a curation bottleneck as the catalog grows.
- **No AI Backend:** Firebase provides robust real-time database capabilities, but there is no AI or ML layer to power classification or recommendations.
- **Scalability Constraints:** As the catalog and user base grow, manual curation becomes increasingly unsustainable.
- **Limited Listener Engagement Signals:** Without personalized recommendations, there is limited ability to keep users engaged beyond their initial favorites.

## Business Objectives

The following objectives define the strategic outcomes ANP Streaming expects from this engagement, each tied to a measurable business result that the delivered solution must support.

- **Enable Mood-Based Content Discovery:** Deliver a recommendation engine that surfaces songs and podcasts matching a user's current mood and listening history, increasing engagement and time-in-app.
- **Automate Catalog Enrichment:** Implement an auto-tagging pipeline that classifies new uploads with mood/emotion labels on ingestion, eliminating manual curation effort.
- **Integrate Without Frontend Rework:** Expose AI capabilities through a documented REST API callable from the existing FlutterFlow app, avoiding costly and time-consuming mobile development work.
- **Establish a Scalable AI Platform:** Build on fully managed AWS services (Lambda, Bedrock, API Gateway) so the solution scales automatically as the user base grows.
- **Maximize AWS Funding:** Structure the engagement to qualify for AWS partner credits that offset 100% of professional services costs in Year 1.

## Success Metrics

The following specific, measurable criteria define what "done" looks like for this engagement and will be used as acceptance benchmarks throughout testing and handover.

- **Classification Accuracy:** ≥90% mood/emotion label accuracy validated against a representative sample of faith-based lyric and transcript content
- **API Latency:** ≤2 seconds p95 response time for both `/classify` and `/recommend` endpoints under normal load
- **Integration Compatibility:** REST API callable from FlutterFlow with zero changes to the existing mobile frontend
- **Environment Readiness:** Both Dev and Production AWS environments provisioned and operational by end of Week 2
- **Go-Live Timeline:** Full system live in Production within 6 weeks of engagement kickoff
- **AWS Funding:** AWS partner credits approved and applied before engagement invoicing
- **Documentation Completeness:** API reference, runbook, and architecture decision record delivered and accepted by ANP technical contact

---

# Scope of Work

This engagement will design, build, and hand over a serverless AWS AI backend for ANP Streaming, comprising two REST API endpoints — mood classification and personalized playlist recommendation — plus an automated mood-tagging pipeline for new content uploads. The following sections define what is and is not included.

## In Scope

The following services and deliverables are included in this SOW:

- AWS environment setup: IAM roles, API Gateway, Lambda functions, DynamoDB tables, S3 bucket, and CloudWatch monitoring for Dev and Production
- Amazon Bedrock integration for LLM-based mood/emotion classification from lyric and transcript text
- `POST /classify` endpoint: accepts song or podcast text, returns a mood/emotion label and confidence score
- `GET /recommend` endpoint: accepts a mood label and user ID, returns a personalized playlist drawn from the catalog and user listening history
- Automated batch Lambda pipeline to tag new catalog uploads with mood/emotion labels via Bedrock
- DynamoDB schema design and seed data load from the existing Firebase catalog metadata
- API key authentication, HTTPS enforcement, IAM least-privilege policies, and AWS Secrets Manager configuration
- CloudWatch dashboards, Lambda error alarms, and API Gateway latency alerting
- Infrastructure as Code (CloudFormation or AWS CDK) for repeatable environment deployments
- Developer-facing API reference documentation for the ANP app team
- Operational runbook covering monitoring, alarm response, and DynamoDB maintenance
- Live knowledge transfer session with ANP's designated technical point of contact
- Two-week hypercare support period post-go-live

### Scope Parameters

This engagement is sized as a **Small** engagement based on the following parameters:

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | API Endpoints | 2 REST endpoints (`/classify`, `/recommend`) |
| Solution Scope | AI/ML Services | Amazon Bedrock on-demand inference (1-2 foundation models) |
| Solution Scope | Auto-Tagging Pipeline | Batch Lambda triggered on new upload events |
| Integration | Source System | Firebase catalog (read-only export to S3) |
| Integration | Consumer | Existing FlutterFlow mobile app (no frontend changes) |
| User Base | Concurrent API Users | <100 simultaneous active users at launch |
| Data Volume | Catalog / Transcript Storage | <50 GB lyric and transcript text in S3 |
| Data Volume | Listening History Records | <50,000 DynamoDB records at launch |
| Data Volume | Inference Volume | ~500K API invocations/month |
| Technical Environment | Deployment Environments | Dev + Production (no dedicated staging) |
| Technical Environment | AWS Region | Single region (us-east-1) |
| Security & Compliance | Compliance Frameworks | Standard AWS security baseline; no HIPAA or PCI requirements |
| Performance | API Latency Target | ≤2 seconds p95 |

Table: Engagement Scope Parameters

*Note: Changes to these parameters — particularly inference volume, catalog size, or additional endpoints — may require scope adjustment and additional investment.*

## Out of Scope

These items are not in scope unless added via formal change control:

- Firebase data migration, restructuring, or real-time Firebase-to-DynamoDB synchronization
- Any changes to the FlutterFlow mobile frontend, UI components, or Firebase Authentication flows
- Custom ML model training, fine-tuning, or hosting (engagement uses Bedrock on-demand inference)
- Amazon Personalize or any dedicated collaborative-filtering recommendation service
- Third-party music licensing, rights management, or audio content ingestion
- A dedicated staging or QA environment (only Dev and Production are provisioned)
- PCI-DSS, HIPAA, or SOC 2 compliance audit and certification
- Ongoing managed services or 24×7 support beyond the 2-week hypercare period
- Content delivery or CDN configuration for audio streaming
- Mobile push notification or engagement marketing capabilities

## Activities

### Phase 1 — Discovery & Design (Weeks 1–2)

This phase establishes a shared understanding of ANP Streaming's existing catalog structure, confirms the technical architecture, and provisions the foundational AWS environment. All risks are surfaced and mitigated before any development begins.

Key activities:
- Project kickoff meeting with Lilly Goyah and nClouds team to align on goals, timeline, and AWS funding eligibility
- Review Firebase catalog structure: titles, artists, lyric text, and transcript text
- Document functional requirements and agree on input/output API schemas for both endpoints
- Design AWS architecture covering Lambda, Bedrock, API Gateway, DynamoDB, S3, CloudWatch, Secrets Manager, and Cognito
- Assess catalog text data quality and confirm Bedrock model suitability for faith-based content
- Identify and document project risks with mitigations
- Provision AWS account baseline: IAM roles, S3 bucket, DynamoDB tables, Lambda scaffolding for Dev environment
- Configure security baseline: IAM least-privilege, API key auth, HTTPS, Secrets Manager, and CloudWatch log groups
- Export Firebase catalog metadata to S3 for inference pipeline use

**Deliverable:** Discovery Summary Report (architecture decision record + confirmed scope) and provisioned Dev environment

### Phase 2 — Build & Integrate (Weeks 3–4)

This phase implements both AI endpoints and the auto-tagging pipeline, culminating in integrated, tested capabilities running in the Dev environment and ready for validation.

Key activities:
- Evaluate and prototype Amazon Bedrock foundation model for mood/emotion classification on faith-based content
- Implement `POST /classify` Lambda function: invoke Bedrock with lyric/transcript text, return mood label and confidence score
- Implement `GET /recommend` Lambda function: query DynamoDB for user history and catalog mood tags, return personalized playlist
- Implement auto-tagging batch Lambda triggered on new catalog upload events
- Configure API Gateway routes, request validation, throttling, and API key authorization
- Design and provision DynamoDB tables for catalog mood tags and user listening history; load seed data from Firebase export
- Configure CloudWatch dashboards, Lambda error alarms, and API Gateway latency alerts
- Finalize CloudFormation/CDK Infrastructure as Code templates for both Dev and Production

**Deliverable:** Both API endpoints operational in Dev environment, auto-tagging pipeline running, CloudWatch monitoring active

### Phase 3 — Validate & Hand Off (Weeks 5–6)

This phase validates the complete solution through structured testing, deploys to Production, and transfers operational ownership to ANP Streaming with full documentation and a live knowledge transfer session.

Key activities:
- Execute functional test plan against both endpoints using labeled faith-based lyric and transcript samples
- Run integration tests simulating FlutterFlow API calls through API Gateway to Lambda to DynamoDB and back
- Validate security controls: IAM policies, API key enforcement, HTTPS-only access, unauthorized request rejection
- Validate Bedrock mood-classification accuracy against representative content (target ≥90%)
- Resolve defects identified during functional and integration testing
- Deploy final Lambda functions, API Gateway configuration, and DynamoDB to Production via IaC
- Produce developer-facing API reference documentation (endpoint specs, auth, request/response examples)
- Create operational runbook (monitoring, alarm response, Lambda scaling, DynamoDB maintenance)
- Conduct live knowledge transfer session with ANP's technical contact
- Deliver 2-week post-go-live hypercare support for issue resolution and app team integration queries

**Deliverable:** Production deployment live, API documentation, runbook, knowledge transfer session completed

---

# Deliverables & Timeline

The following section defines all formal deliverables, their type, target delivery date, and acceptance authority. Each deliverable will be submitted for ANP Streaming's review, with a standard three-business-day review and acceptance window per the brief.

## Deliverables

The table below enumerates every formal deliverable produced during this engagement, spanning discovery documents, deployed AWS systems, test artifacts, and handover materials. All deliverables are reviewed and accepted by the indicated ANP Streaming authority within three business days of submission.

<!-- TABLE_CONFIG: widths=[5, 45, 12, 18, 20] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|-------------|------|----------|---------------|
| 1 | Project Kickoff Deck & Meeting Notes | Document | Week 1 | Lilly Goyah |
| 2 | Firebase Catalog Assessment Report | Document | Week 1 | Lilly Goyah |
| 3 | AWS Architecture Design & Decision Record | Document | Week 2 | Lilly Goyah |
| 4 | Discovery Summary Report (signed off) | Document | Week 2 | Lilly Goyah |
| 5 | Provisioned Dev AWS Environment | System | Week 2 | ANP Technical Contact |
| 6 | Security Baseline Configuration (IAM, Secrets, HTTPS) | System | Week 2 | ANP Technical Contact |
| 7 | Detailed Architecture Specification & API Schemas | Document | Week 3 | ANP Technical Contact |
| 8 | `POST /classify` Lambda + Bedrock Integration | System | Week 3 | ANP Technical Contact |
| 9 | `GET /recommend` Lambda + DynamoDB Integration | System | Week 4 | ANP Technical Contact |
| 10 | Auto-Tagging Batch Lambda Pipeline | System | Week 4 | ANP Technical Contact |
| 11 | API Gateway Configuration (routes, auth, throttling) | System | Week 4 | ANP Technical Contact |
| 12 | CloudWatch Dashboards & Alerting | System | Week 4 | ANP Technical Contact |
| 13 | Infrastructure as Code Templates (CDK/CloudFormation) | System | Week 4 | ANP Technical Contact |
| 14 | Test Plan & Test Cases (both endpoints) | Document | Week 5 | ANP Technical Contact |
| 15 | Test Results Report | Document | Week 5 | Lilly Goyah |
| 16 | Production Deployment (all services via IaC) | System | Week 5 | Lilly Goyah |
| 17 | Developer-Facing API Reference Documentation | Document | Week 6 | ANP Technical Contact |
| 18 | Operational Runbook | Document | Week 6 | ANP Technical Contact |
| 19 | Knowledge Transfer Session (recorded) | Training | Week 6 | ANP Technical Contact |
| 20 | Project Closeout Report | Document | Week 6 | Lilly Goyah |

## Project Milestones

The milestones below mark the completion of each major phase gate and critical decision point in the engagement. Each milestone is tied to one or more accepted deliverables and serves as the trigger for the corresponding invoice milestone payment.

<!-- TABLE_CONFIG: widths=[22, 58, 20] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 – Kickoff Complete | Project aligned, stakeholders confirmed, AWS account access granted | Week 1 |
| M2 – Architecture Signed Off | Discovery Summary Report accepted; AWS Dev environment live | Week 2 |
| M3 – Classification Endpoint Live | `POST /classify` operational in Dev with ≥90% accuracy validated | Week 3 |
| M4 – Recommendation Endpoint Live | `GET /recommend` and auto-tagging pipeline operational in Dev | Week 4 |
| M5 – Testing Complete | All functional, integration, and security tests passed; defects resolved | Week 5 |
| M6 – Go-Live | Production deployment complete; API accessible from FlutterFlow | Week 5 |
| M7 – Hypercare End / Project Close | 2-week hypercare complete; all handover artifacts delivered and accepted | Week 6+ |

---

# Roles & Responsibilities

This section defines the responsibilities of the nClouds and ANP Streaming teams across all engagement activities. Clear role definition ensures accountability, prevents gaps in coverage, and enables ANP to maintain operations independently after handover.

## RACI Matrix

The following RACI matrix covers the major task categories of this engagement. Each task has exactly one Accountable (A) party and one or more Responsible (R) parties; Consulted (C) and Informed (I) parties participate as appropriate.

<!-- TABLE_CONFIG: widths=[28, 10, 10, 10, 9, 11, 11, 11] -->
| Task / Role | nClouds PM | nClouds Arch | nClouds Eng | nClouds QA | Client CEO | Client IT Contact | AWS Partner |
|-------------|-----------|-------------|------------|-----------|-----------|------------------|-------------|
| Project Kickoff & Governance | A | C | I | I | C | I | I |
| Requirements & Architecture Design | C | A | C | I | C | R | I |
| AWS Environment Provisioning | I | C | A | I | I | R | I |
| Security Baseline Configuration | I | C | A | I | I | C | C |
| Mood Classification Endpoint Development | I | C | A | I | I | I | I |
| Recommendation Endpoint Development | I | C | A | I | I | I | I |
| Auto-Tagging Pipeline Development | I | C | A | I | I | I | I |
| API Gateway & Integration Configuration | I | C | A | I | I | C | I |
| Test Plan Development & Execution | C | I | C | A | I | R | I |
| Model Accuracy Validation | C | A | C | R | C | C | I |
| Production Deployment | A | C | R | I | I | C | I |
| API Documentation & Runbook | C | A | R | I | I | C | I |
| Knowledge Transfer & Handover | A | R | C | I | C | R | I |
| AWS Funding & Credits Application | A | I | I | I | C | I | R |
| Hypercare Support | A | C | R | I | I | R | I |

**Legend:** R = Responsible | A = Accountable | C = Consulted | I = Informed

## Key Personnel

**nClouds Delivery Team:**
- **Jonas Bull – Engagement Lead / Solutions Architect:** Overall technical and commercial accountability for the engagement; AWS architecture design, API specification, and documentation leadership
- **ML/AI Engineer (TBD):** Implementation of Bedrock-integrated Lambda functions for mood classification, recommendation, and auto-tagging pipeline
- **Cloud/Solutions Engineer (TBD):** AWS environment provisioning, API Gateway configuration, IaC templates, CloudWatch monitoring
- **Security Engineer (TBD):** IAM policy design, Secrets Manager configuration, security baseline validation and testing
- **QA Engineer (TBD):** Test plan development, functional testing, integration testing, and defect management
- **Project Manager (TBD):** Project coordination, milestone tracking, status reporting, and stakeholder communications

**ANP Streaming Client Team:**
- **Lilly Goyah – CEO / Executive Sponsor:** Executive decision-making, final acceptance of deliverables, AWS funding approval authority
- **ANP Technical Contact (TBD):** Day-to-day technical liaison; provides Firebase catalog access, reviews API schemas, participates in knowledge transfer and UAT

---

# Architecture & Design

This section describes the technical architecture of the ANP Streaming AI Mood & Recommendation API, including the key design decisions, component layout, network topology, security controls, data flows, and operational approach. The solution is built entirely on AWS managed serverless services, ensuring minimal operational overhead and cost efficiency at ANP Streaming's current scale.

## Architecture Overview

The ANP Streaming AI backend is designed as a fully serverless, event-driven AWS architecture. All compute is handled by AWS Lambda functions invoked through Amazon API Gateway, eliminating the need for any server provisioning or capacity planning. Amazon Bedrock provides on-demand foundation model inference for mood/emotion classification, avoiding the cost and complexity of managing custom ML infrastructure. Amazon DynamoDB stores the catalog mood-tag index and per-user listening history, providing single-digit-millisecond lookup performance for recommendation queries.

The architecture is intentionally minimal, aligning with ANP's small initial user base and limited operational team. Every service used is fully managed by AWS, meaning infrastructure patching, scaling, and availability are handled without ANP or nClouds intervention. The two-environment design (Dev and Production) enables safe iterative development while keeping costs low.

![Figure 1: Solution Architecture Diagram](../../assets/diagrams/architecture-diagram.png)

**Figure 1: ANP Streaming Serverless AI Architecture** — End-to-end flow from FlutterFlow API call through Amazon API Gateway, AWS Lambda, Amazon Bedrock, and Amazon DynamoDB, with supporting services for security, monitoring, and storage.

## Component Architecture

The solution comprises the following AWS components, each selected for its managed-service reliability and pay-per-use pricing model appropriate for ANP Streaming's launch-stage traffic volumes:

- **Amazon API Gateway (REST API):** The public-facing entry point for the FlutterFlow mobile app. Hosts two routes — `POST /classify` and `GET /recommend` — with API key authentication, request validation, per-key throttling (rate limit and burst limit), and usage plan enforcement. All traffic is HTTPS-only.
- **AWS Lambda – Classifier Function:** A Python or Node.js Lambda function invoked on `POST /classify`. Accepts a text payload (lyrics or podcast transcript), calls Amazon Bedrock with a prompt designed for faith-based mood/emotion classification, and returns a mood label (e.g., Joyful, Reflective, Peaceful, Uplifting) and a confidence score.
- **AWS Lambda – Recommender Function:** A Python or Node.js Lambda function invoked on `GET /recommend`. Accepts a mood label and user ID, queries DynamoDB for the user's recent listening history and mood-tagged catalog items, and returns an ordered playlist of matching content.
- **AWS Lambda – Auto-Tagger Function:** A batch Lambda triggered by S3 `ObjectCreated` events on the catalog prefix. For each new lyric or transcript file, it invokes Bedrock to classify mood, then writes the mood tag and confidence score to the DynamoDB catalog index.
- **Amazon Bedrock (On-Demand Inference):** Provides access to a foundation model (e.g., Anthropic Claude or Amazon Titan Text) for mood/emotion classification. The specific model is selected during Phase 1 prototyping based on accuracy benchmarks against ANP's faith-based content. No provisioned throughput is required at current inference volumes.
- **Amazon DynamoDB:** Two tables — `anp-catalog-moods` (partition key: `content_id`) storing mood labels and confidence scores for each catalog item, and `anp-user-history` (partition key: `user_id`, sort key: `played_at`) storing recent listening events per user. Pay-per-request billing mode keeps costs proportional to usage.
- **Amazon S3:** Object storage for lyric and transcript text files exported from Firebase. Organized under a `catalog/` prefix. S3 event notifications trigger the Auto-Tagger Lambda on new file uploads. Server-side encryption (SSE-S3) is enabled by default.
- **Amazon Cognito (User Pool):** Provides JWT-based user identity for the `GET /recommend` endpoint, validating that each request is associated with an authenticated ANP Streaming user. The FlutterFlow app passes the Cognito JWT in the Authorization header.
- **AWS Secrets Manager:** Stores all sensitive credentials — Firebase service account key, Bedrock endpoint configuration, and any third-party API keys — with quarterly rotation configured.
- **Amazon CloudWatch:** Centralized logging and monitoring. Lambda functions emit structured JSON logs to dedicated log groups. CloudWatch Metrics tracks invocation counts, error rates, and p95 latency. Alarms are configured for Lambda error rate >1% and API Gateway p95 latency >2 seconds.

## Network Design

The solution is deployed within a single AWS region (us-east-1). All Lambda functions run within the AWS managed Lambda service VPC by default; no customer-managed VPC is required for this engagement given the all-managed-service architecture. API Gateway endpoints are public HTTPS, secured at the application layer by API key authentication and Cognito JWT validation. There are no VPC peering connections, private endpoints, or dedicated network circuits. All traffic between the FlutterFlow app and API Gateway transits over the public internet using TLS 1.2 or higher. Internal AWS service-to-service communication (Lambda → Bedrock, Lambda → DynamoDB, Lambda → S3) traverses the AWS private network backbone and does not leave the AWS network boundary.

## Security Design

The security architecture follows the AWS Well-Architected Framework security pillar with a defense-in-depth approach appropriate for the engagement's risk profile:

- **Identity & Access Management:** Each Lambda function is assigned a dedicated IAM execution role with least-privilege permissions scoped to only the AWS services it must access (e.g., the Classifier Lambda role grants only `bedrock:InvokeModel` and `logs:CreateLogGroup`). No wildcard permissions are used.
- **API Authentication:** `POST /classify` is protected by API key authentication enforced at API Gateway. `GET /recommend` additionally validates a Cognito JWT to associate requests with authenticated users. Unauthenticated requests return HTTP 401/403 and are logged.
- **Secrets Management:** Firebase service account credentials and all sensitive configuration values are stored in AWS Secrets Manager and injected into Lambda functions at runtime via environment variable reference, never hardcoded.
- **Encryption in Transit:** All API traffic uses HTTPS (TLS 1.2+). API Gateway enforces HTTPS-only; HTTP requests are rejected.
- **Encryption at Rest:** S3 uses SSE-S3 server-side encryption for all catalog files. DynamoDB encryption at rest is enabled by default using AWS-managed keys.
- **Input Validation:** API Gateway request models validate payload structure and content type before Lambda invocation, preventing malformed requests from reaching compute.
- **Audit Logging:** CloudWatch Logs capture all Lambda invocations and API Gateway access logs. Log retention is set to 90 days.

## Data Architecture

Data flows through three logical tiers: ingestion, inference, and retrieval. Understanding these flows is essential for ANP Streaming's operational team to maintain data freshness and troubleshoot issues post-handover.

- **Ingestion:** ANP Streaming exports lyric and transcript text from Firebase to an S3 bucket (`anp-catalog/`) as part of the project onboarding. The Auto-Tagger Lambda processes each file on upload and writes mood tags to DynamoDB. User listening events from the FlutterFlow app are written to the `anp-user-history` DynamoDB table via the Recommender Lambda.
- **Inference:** The Classifier Lambda reads the text payload from the API request (not from S3 directly), constructs a Bedrock prompt, invokes the foundation model, parses the response, and returns the mood label. Catalog text is not re-fetched from S3 at inference time for on-demand classification requests.
- **Retrieval:** The Recommender Lambda performs a DynamoDB query to retrieve the user's last N listening events and a scan/query on the catalog mood index to find matching content. Results are ranked by recency of matching mood and returned as an ordered playlist.
- **Data Classification:** Catalog text (lyrics and transcripts) is classified as non-sensitive internal data. User listening history is classified as personally identifiable usage data and is scoped to authenticated users only.
- **Retention:** S3 catalog files are retained indefinitely (no lifecycle policy at launch). DynamoDB user history items are retained for 90 days via DynamoDB TTL. CloudWatch logs are retained for 90 days.
- **Backup:** DynamoDB point-in-time recovery (PITR) is enabled on both tables, providing a 35-day continuous backup window at no additional configuration overhead.

## Operational Design

The solution is designed for low-touch operations appropriate for ANP Streaming's small technical team. The following describes the observability, recovery, and cost-management approach that underpins steady-state operations after handover:

- **Monitoring:** CloudWatch dashboards provide at-a-glance visibility into API invocation counts, error rates, p95 latency, and Bedrock token consumption. Dashboards are documented in the operational runbook.
- **Alerting:** CloudWatch Alarms notify via SNS email for: Lambda error rate >1% (5-minute window), API Gateway p95 latency >2 seconds (5-minute window), and DynamoDB consumed read/write capacity approaching provisioned limits.
- **Backup & Recovery:** DynamoDB PITR enables point-in-time restoration. S3 versioning is enabled on the catalog bucket. Lambda function code is stored in S3 via IaC and can be redeployed in minutes.
- **RTO/RPO:** Target RTO of 1 hour and RPO of 24 hours for the Production environment. Serverless architecture provides built-in multi-AZ resilience within the AWS region.
- **Runbook Coverage:** The operational runbook delivered at project close covers: alarm investigation, Lambda cold-start tuning, DynamoDB capacity mode adjustment, Secrets Manager secret rotation, and IaC-based environment re-deployment.
- **Cost Management:** AWS Cost Explorer tags are applied to all resources with `Project=ANPStreamingAI` and `Environment=dev|prod` to enable granular cost tracking.

## Tooling Overview

The table below summarises the primary tools and services used across all delivery workstreams in this engagement, covering both the AWS platform services that form the solution and the engineering tools used to build and operate it.

<!-- TABLE_CONFIG: widths=[30, 35, 35] -->
| Category | Primary Tools | Purpose |
|----------|---------------|---------|
| Compute | AWS Lambda (Python 3.12) | Serverless function execution for all three API endpoints |
| AI / ML Inference | Amazon Bedrock (Anthropic Claude / Titan Text) | Foundation model mood/emotion classification |
| API Management | Amazon API Gateway (REST API) | Public API endpoint hosting, auth, throttling |
| Database | Amazon DynamoDB | Catalog mood-tag index and user listening history |
| Object Storage | Amazon S3 | Catalog lyric and transcript text file storage |
| Identity | Amazon Cognito | JWT-based user authentication for recommendation endpoint |
| Secrets | AWS Secrets Manager | Secure credential storage and rotation |
| Monitoring | Amazon CloudWatch (Logs, Metrics, Alarms) | Operational observability and alerting |
| Infrastructure as Code | AWS CDK (TypeScript) or CloudFormation | Repeatable environment provisioning |
| CI/CD | AWS CodePipeline + CodeBuild (optional) | Automated deployment pipeline for Lambda updates |
| Source Control | GitHub / AWS CodeCommit | Code versioning for Lambda functions and IaC |

---

# Security & Compliance

ANP Streaming operates in a standard commercial environment with no regulatory mandates (HIPAA, PCI-DSS, or SOC 2) identified at engagement commencement. The security architecture described in this section applies the AWS Well-Architected Framework security pillar controls appropriate for the engagement scope and ANP's risk profile.

## Identity & Access Management

All access to AWS resources is governed by IAM roles and policies following the principle of least privilege. Each Lambda function is assigned an execution role with permissions scoped to only the specific AWS API actions and resources it requires — no cross-function role sharing and no wildcard (`*`) resource permissions. Human access to the AWS account during the engagement is controlled via named IAM users (nClouds team) with MFA enforced. Root account access is disabled for day-to-day operations and secured with a hardware MFA device. Upon project handover, all nClouds IAM users are removed and ANP Streaming is provided with a named administrator IAM user protected by MFA. The FlutterFlow app accesses the API using API keys for the `/classify` endpoint and Cognito JWTs for the `/recommend` endpoint; no AWS credentials are exposed to the mobile client at any time.

## Monitoring & Threat Detection

Amazon CloudWatch is the primary monitoring and threat-detection layer for this engagement. Structured JSON logs are emitted by all Lambda functions and API Gateway, enabling query-based analysis via CloudWatch Log Insights. CloudWatch Alarms detect operational anomalies (high error rates, latency spikes) and notify via SNS email. AWS CloudTrail is enabled in the ANP AWS account to capture all API-level activity for audit and forensic purposes with a 90-day retention period in S3. For unauthorized API access attempts, API Gateway logs rejected requests (HTTP 401/403) to CloudWatch, enabling pattern analysis. If ANP Streaming's user base grows to require more sophisticated threat detection, migration to Amazon GuardDuty and AWS Security Hub is recommended as a future initiative.

## Compliance & Auditing

No specific compliance framework certification is required for this engagement. The architecture is designed to be compatible with future SOC 2 Type II assessment should ANP Streaming pursue certification. All infrastructure changes are applied via IaC (CDK/CloudFormation) with change sets reviewed before application, providing a traceable change history. CloudTrail captures all AWS console and API activity. Log retention for CloudWatch and CloudTrail is set to 90 days as a minimum; ANP Streaming may extend this to 365 days by updating the log group and S3 lifecycle policy, which is documented in the runbook.

## Encryption & Key Management

All data in transit is encrypted using TLS 1.2 or higher. API Gateway enforces HTTPS-only access; HTTP requests are rejected with a 403 response. All data at rest is encrypted: S3 uses SSE-S3 (AES-256) for catalog files, and DynamoDB uses AWS-managed KMS keys for table encryption at rest (enabled by default). Lambda environment variables containing configuration (non-secret) values are encrypted at rest using AWS-managed keys. Sensitive credentials (Firebase service account, any third-party API keys) are stored exclusively in AWS Secrets Manager and never embedded in Lambda environment variables or source code. Secrets Manager is configured for quarterly automatic rotation where supported by the credential type.

## Governance

All AWS infrastructure is provisioned and managed through IaC templates (CDK/CloudFormation), ensuring no manual "click-ops" configuration drift. Stack outputs are tagged with standardized project tags (`Project`, `Environment`, `Owner`) to support cost allocation and governance. Change management during the engagement follows a documented change request process: proposed changes are described in a change record, reviewed by Jonas Bull and ANP's technical contact, and applied to Dev before Production. Upon project handover, ANP Streaming is provided with the full IaC codebase and documentation to enable self-service infrastructure changes with version control discipline.

## Environments & Access

### Environment Strategy

<!-- TABLE_CONFIG: widths=[20, 28, 28, 24] -->
| Environment | Purpose | Access Control | Data |
|-------------|---------|----------------|------|
| Development | Feature development, integration testing, accuracy benchmarking | nClouds engineering team + ANP technical contact | Anonymized / synthetic catalog samples and test user histories |
| Production | Live API serving FlutterFlow app and real users | Restricted to ANP admin + nClouds lead (via named IAM) | Live catalog text and real user listening history |

### Access Policies

During the engagement, nClouds engineers have time-limited IAM access to the Dev environment and read-only access to Production monitoring dashboards. Production changes are applied exclusively via IaC pipelines, not direct console access. All nClouds IAM access is revoked at project closeout (end of Week 6). ANP Streaming retains a named IAM administrator account with MFA for ongoing management. No production data (user listening history) is accessed in the Dev environment at any time.

---

# Testing & Validation

A structured testing approach ensures both API endpoints meet the accuracy, performance, and security requirements agreed with ANP Streaming before Production deployment. Testing is conducted across Weeks 5–6, with defect resolution incorporated within the testing window before go-live.

## Functional Validation

Functional testing validates that both endpoints return correct outputs for well-formed inputs and handle edge cases gracefully. The nClouds QA engineer will execute a documented test plan covering:

- **`POST /classify` test cases:** Valid lyric text (multiple genres/moods), valid transcript text, empty payload, oversized payload, non-English content, and content with ambiguous mood signals. Expected outputs: correct mood label, confidence score ≥0 and ≤1, HTTP 200 for valid inputs, HTTP 400 for invalid payloads.
- **`GET /recommend` test cases:** Valid user ID with listening history, valid user ID with no history (cold start), unknown user ID, unsupported mood label, and missing mood parameter. Expected outputs: ordered playlist array, HTTP 200 for valid inputs, HTTP 400/404 for invalid inputs.
- **Auto-Tagger validation:** Upload test lyric and transcript files to S3 and verify DynamoDB catalog table is updated with correct mood tag and confidence score within 60 seconds.

Acceptance criteria: ≥95% of functional test cases pass before Production deployment is approved.

## Performance & Load Testing

Performance testing validates the p95 latency target of ≤2 seconds for both endpoints under representative load. Testing will be conducted using AWS Lambda Power Tuning and Artillery (or equivalent) simulating concurrent API requests:

- Baseline latency test: 10 concurrent users, 5-minute run
- Moderate load test: 50 concurrent users, 5-minute run
- Acceptance criterion: p95 latency ≤2 seconds at 50 concurrent users for both endpoints

Bedrock cold-start latency will be characterized in Dev and Lambda provisioned concurrency may be applied to the Production Classifier function if p95 latency targets are not met at standard concurrency.

## Security Testing

Security validation confirms the authentication and authorization controls operate correctly and that the API rejects unauthorized requests:

- **API key enforcement:** Requests to `/classify` without a valid API key must return HTTP 403
- **JWT validation:** Requests to `/recommend` with an expired, invalid, or missing JWT must return HTTP 401
- **HTTPS enforcement:** HTTP requests to the API Gateway endpoint must return HTTP 403 or redirect to HTTPS
- **IAM policy validation:** Confirm each Lambda execution role cannot access AWS services outside its permitted scope (tested via IAM Policy Simulator)
- **Secrets Manager:** Confirm no secrets are present in Lambda environment variables, CloudWatch logs, or IaC output templates

## Disaster Recovery & Resilience Tests

Given the serverless architecture, resilience tests focus on data recovery and service restoration:

- **DynamoDB PITR restore test:** Initiate a point-in-time restore of the `anp-catalog-moods` table to a test table and validate data integrity
- **Lambda re-deployment test:** Delete and redeploy all Lambda functions from IaC templates in Dev and confirm functionality is restored within 15 minutes
- **S3 versioning test:** Overwrite a catalog file and restore the previous version; confirm the Auto-Tagger re-processes correctly

## User Acceptance Testing

User acceptance testing involves ANP Streaming's technical contact executing representative API calls that simulate real FlutterFlow usage patterns, confirming the solution behaves correctly from the client's perspective before Production deployment is approved.

- Submit classification requests using 20 real catalog items and validate mood labels are reasonable for faith-based content
- Submit recommendation requests for 5 test users with varying listening histories and validate playlist relevance
- Confirm the API is callable from a FlutterFlow test environment using the production API key and Cognito token flow

ANP Streaming's technical contact signs off on UAT completion before Production deployment proceeds. Any accuracy concerns are escalated to Jonas Bull for Bedrock prompt refinement within the testing window.

## Go-Live Readiness

The following criteria must be satisfied before Production deployment is approved:

- [ ] All functional test cases pass (≥95% pass rate)
- [ ] p95 API latency ≤2 seconds at 50 concurrent users
- [ ] All security test cases pass (100% required)
- [ ] DynamoDB PITR enabled on both Production tables
- [ ] CloudWatch alarms configured and alarm-state tested in Dev
- [ ] API documentation reviewed and accepted by ANP technical contact
- [ ] Production IaC deployment completed successfully in a dry-run against Dev
- [ ] AWS funding credits confirmed and applied to the engagement
- [ ] ANP Streaming executive (Lilly Goyah) confirms go-live approval

## Cutover Plan

Production deployment follows a zero-downtime approach using IaC:

1. Deploy CloudFormation/CDK stack to Production environment (Lambda, API Gateway, DynamoDB, S3)
2. Execute smoke tests against Production API Gateway URL (5-10 representative API calls)
3. Confirm CloudWatch dashboards and alarms are active
4. Provide Production API key and API Gateway base URL to ANP technical contact
5. ANP technical contact updates FlutterFlow app configuration with Production API key and endpoint
6. Validate FlutterFlow app is calling Production API successfully (confirmed via CloudWatch access logs)
7. Jonas Bull confirms go-live with Lilly Goyah
8. Commence 2-week hypercare support period

Estimated cutover window: 2–3 hours. All steps are completed during ANP business hours.

## Rollback Strategy

If critical defects are identified during Production smoke tests or early hypercare:

- **Trigger:** >10% Lambda error rate or p95 latency >5 seconds persisting for 10 minutes in Production
- **Rollback procedure:** Deploy the previous stable Lambda function version via IaC (`cdk deploy --rollback`). API Gateway stage configuration is restored from the previous stack deployment. DynamoDB data is preserved (no schema changes on rollback).
- **Timeline:** Target rollback completion within 30 minutes of rollback trigger
- **Communication:** Jonas Bull notifies Lilly Goyah immediately upon rollback trigger; root cause analysis delivered within 24 hours

---

# Handover & Support

A structured handover ensures ANP Streaming can operate and evolve the AI backend independently after the engagement. Handover activities run in parallel with final testing during Weeks 5–6.

## Handover Artifacts

The following artifacts will be delivered to ANP Streaming at project close:

- **Discovery Summary Report** — AWS architecture decision record, confirmed scope, and risk register
- **Detailed Architecture Specification** — API endpoint schemas, Bedrock prompt design, DynamoDB table definitions
- **Infrastructure as Code (CDK/CloudFormation templates)** — Complete IaC codebase in a GitHub repository, enabling repeatable environment provisioning
- **Lambda Source Code** — All three Lambda functions (Classifier, Recommender, Auto-Tagger) in a GitHub repository with README
- **API Reference Documentation** — Developer-facing documentation covering both endpoints, authentication, request/response schemas, error codes, and example calls compatible with FlutterFlow
- **Operational Runbook** — Step-by-step procedures for monitoring, alarm investigation, Lambda scaling, DynamoDB capacity adjustment, Secrets Manager rotation, and environment re-deployment
- **Test Results Report** — Complete test execution results including functional, integration, security, and UAT sign-off
- **Project Closeout Report** — Summary of delivered scope, deferred items, and recommended next steps

## Knowledge Transfer

nClouds will conduct a single live knowledge transfer session (approximately 2 hours) with ANP Streaming's designated technical contact. The session will be recorded and the recording delivered as part of the handover package. Topics covered:

- Architecture walkthrough: how the three Lambda functions interact with Bedrock, DynamoDB, S3, and API Gateway
- How to monitor the system using CloudWatch dashboards and respond to alarms
- How to deploy infrastructure changes using the IaC templates
- How to update the Bedrock prompt for mood classification if accuracy needs tuning
- How to rotate API keys and Firebase credentials in Secrets Manager
- Common troubleshooting scenarios and runbook navigation

## Hypercare Support

nClouds will provide a **2-week hypercare support period** following Production go-live:

- **Duration:** 2 weeks post-go-live (approximately Weeks 6–7)
- **Coverage:** Business hours (9am–5pm client's local time zone), Monday–Friday
- **Scope:** Bug fixes and defects in delivered code, integration questions from the ANP FlutterFlow development team, CloudWatch alarm investigation and guidance, Bedrock classification accuracy tuning
- **Response Time:** P1 (Production outage) — 4-hour response; P2 (Degraded functionality) — 8-hour response; P3 (Queries and guidance) — 1 business day response
- **Exclusions:** New feature development, scope changes, Firebase infrastructure support, or FlutterFlow frontend modifications

## Managed Services Transition

Ongoing managed services are not included in this engagement. After the 2-week hypercare period, ANP Streaming assumes full operational responsibility for the Production environment. The operational runbook is designed to enable self-sufficient operation with AWS Developer Support. If ANP Streaming requires ongoing managed support, a separate Managed Services Agreement should be discussed with nClouds at the conclusion of the engagement.

## Assumptions

The following assumptions underpin the engagement scope, timeline, and pricing:

1. ANP Streaming will provide nClouds with admin-level AWS account access within 5 business days of engagement kickoff
2. ANP Streaming's Firebase catalog export (lyrics and transcript text) is available for S3 upload by the start of Week 2
3. The Firebase catalog contains at least 200 items with lyric or transcript text sufficient for Bedrock model evaluation
4. ANP Streaming will designate one technical point of contact available for up to 4 hours per week during the engagement
5. Lilly Goyah (CEO) is available for kickoff meeting, milestone reviews, and final sign-off within the agreed 3-business-day review window
6. The existing FlutterFlow app can make outbound HTTPS REST API calls to an external AWS API Gateway endpoint without code changes
7. AWS partner funding ($15,000 in credits) is approved prior to project invoicing; engagement timelines are not dependent on funding approval
8. No HIPAA, PCI-DSS, or other regulatory compliance certification is required as part of this engagement
9. The AWS account provided by ANP Streaming has no pre-existing conflicting resource naming conventions or service quotas that would block Lambda or API Gateway deployment
10. nClouds will not have access to live Production user data during development; test data is provided by ANP or synthetically generated
11. Amazon Bedrock on-demand inference is available in us-east-1 for the selected foundation model at engagement commencement
12. The FlutterFlow app team will implement the API integration on the ANP side; nClouds provides API documentation and integration support but does not modify the mobile frontend
13. Client review and acceptance of each deliverable will be completed within 3 business days of submission

## Dependencies

The following critical dependencies must be satisfied for the engagement to proceed on schedule. Each is owned by either ANP Streaming or nClouds and has a hard deadline tied to the phase it gates.

| Dependency | Owner | Required By |
|------------|-------|-------------|
| AWS account with admin access granted to nClouds | ANP Streaming | Week 1 Day 1 |
| Firebase catalog export (titles, artists, lyrics, transcripts) available for S3 upload | ANP Streaming | Week 2 Day 1 |
| ANP technical contact identified and available | ANP Streaming | Week 1 Day 1 |
| AWS partner funding application submitted and approved | nClouds | Before final invoicing |
| Amazon Bedrock model availability in us-east-1 confirmed | nClouds | Week 1 |
| FlutterFlow app HTTPS outbound API call capability confirmed | ANP Streaming | Week 5 (UAT) |

---

# Investment Summary

This engagement is scoped as a **Small** implementation, reflecting ANP Streaming's focused two-endpoint API requirement, serverless architecture, small initial user base, and 6-week delivery timeline. nClouds has structured the commercial model to leverage available AWS partner funding, reducing ANP Streaming's net Year 1 investment to infrastructure-only costs.

## Total Investment

The table below reconciles professional services (from the Level of Effort estimate) and infrastructure costs (from the Infrastructure Cost estimate) across a 3-year horizon. Infrastructure costs are sourced from the engagement's infrastructure-costs.csv model; professional services reflect the level-of-effort-estimate.csv total before and after AWS partner credit application.

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[28, 13, 15, 12, 10, 10, 12] -->
| Cost Category | Year 1 List | Year 1 Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|----------------|------------|--------|--------|--------------|
| Professional Services | $15,000 | ($15,000) | $0 | $0 | $0 | $0 |
| Cloud Infrastructure | $2,903 | ($1,500) | $1,403 | $2,903 | $2,903 | $7,210 |
| Software Licenses | $0 | $0 | $0 | $0 | $0 | $0 |
| Support & Maintenance | $348 | $0 | $348 | $348 | $348 | $1,044 |
| **TOTAL INVESTMENT** | **$18,251** | **($16,500)** | **$1,751** | **$3,251** | **$3,251** | **$8,254** |
<!-- END COST_SUMMARY_TABLE -->

*All figures in USD. Year 2 and Year 3 infrastructure costs assume similar usage volumes. Professional Services are a one-time Year 1 cost only.*

## Partner Credits

ANP Streaming benefits from two categories of AWS partner credits in Year 1:

**Professional Services Credits — $15,000:**
- **AWS Partner Services Credit ($10,000):** Applied to professional services under the AWS Partner Network (APN) program. nClouds is an AWS Advanced Consulting Partner delivering a qualified AI/ML workload, making this engagement eligible.
- **AWS Partner Funding Credit ($5,000):** Applied under the AWS Partner Funding (APF) program for qualified AI/ML build engagements. Subject to AWS funding approval prior to project start.

**Cloud Infrastructure Credits — $1,500:**
- **AWS Migration Acceleration Program (MAP) Credit ($1,500):** Applied to Year 1 cloud consumption. nClouds is an APN partner eligible to apply MAP funding for qualifying workloads.

**Total Year 1 Credits: $16,500** (90.4% reduction on Year 1 list price)

*Credits are applied at invoice time. nClouds manages the AWS funding application process on ANP Streaming's behalf. Professional services credits are subject to AWS funding program approval prior to engagement invoicing.*

## Cost Components

**Professional Services — $15,000 List / $0 Net (Year 1)**

The professional services estimate reflects approximately 296 base engineering hours plus 10% project management and technical leadership overhead across the three-phase engagement, delivered by nClouds' multi-disciplinary team. Resource blended rate reflects Solution Architect ($225/hr), ML/AI Engineer ($250/hr), Cloud/Solutions Engineer ($200/hr), Security Engineer ($200/hr), QA Engineer ($150/hr), Support Engineer ($150/hr), and Project Manager ($175/hr). The full $15,000 is offset by AWS partner credits in Year 1; no recurring professional services fees apply in Years 2 or 3.

**Cloud Infrastructure — $2,903/year (Year 1 List)**

The annual cloud cost breakdown across all AWS services used by this solution:

| Service | Annual Cost | Notes |
|---------|-------------|-------|
| Amazon Bedrock | $1,800 | ~200K tokens/month on-demand inference |
| Amazon API Gateway | $420 | ~500K requests/month |
| Amazon CloudWatch | $360 | Log ingestion, metrics, alarms |
| Amazon S3 | $138 | 500 GB catalog storage |
| Amazon Cognito | $120 | MAU-based pricing, small user base |
| AWS Secrets Manager | $60 | ~5 secrets, quarterly rotation |
| Amazon DynamoDB | $3 | Pay-per-request, low volume at launch |
| AWS Lambda | $2 | Pay-per-invocation, ~500K/month |
| **Total Annual** | **$2,903** | |

Year 1 net after $1,500 MAP credit: **$1,403**

**Support & Maintenance — $348/year**

AWS Developer Support plan covering technical guidance and case management during build and steady-state operation. Upgrade to AWS Business Support is recommended if Production SLA requirements tighten as ANP Streaming's user base grows.

## Payment Terms

Professional services fees are invoiced on a milestone basis:

| Milestone | Invoice % | Amount (List) | Due |
|-----------|-----------|--------------|-----|
| Engagement Kickoff (SOW signed) | 30% | $4,500 | Week 1 |
| Architecture Sign-Off & Dev Environment Live | 30% | $4,500 | End of Week 2 |
| Both Endpoints Live in Dev (M4) | 20% | $3,000 | End of Week 4 |
| Production Go-Live (M6) | 20% | $3,000 | End of Week 5 |
| **Total Professional Services** | **100%** | **$15,000** | |

AWS partner credits are applied to each invoice at the time of billing, reducing ANP Streaming's net payment to $0 for professional services (subject to credit approval). Infrastructure costs are billed directly by AWS to ANP Streaming's account on a monthly pay-as-you-go basis.

## Invoicing & Expenses

Invoices are issued in USD and payable within 30 days of invoice date. Late payments accrue interest at 1.5% per month. Travel and out-of-pocket expenses are not expected for this remote-first engagement; if any on-site travel is requested by ANP Streaming, it will be billed at cost with prior written approval. All reimbursable expenses require receipts and pre-approval from ANP Streaming's authorized signatory.

---

# Terms & Conditions

## General Terms

This Statement of Work is governed by and incorporated into the Master Services Agreement (MSA) between ANP Streaming and nClouds, Inc. In the event of any conflict between this SOW and the MSA, the MSA shall take precedence unless otherwise explicitly stated herein. Work will not commence until both parties have executed this SOW and the MSA (or an equivalent engagement letter).

## Scope Changes

Any change to the services, deliverables, timeline, or commercial terms described in this SOW must be made via a written Change Order signed by authorized representatives of both parties. Proposed changes will be evaluated by nClouds within 5 business days and may result in adjustments to cost, timeline, or resource allocation. Work on changes begins only after the Change Order is fully executed. Verbal agreements to changes are not binding.

## Intellectual Property

Upon receipt of final payment, ANP Streaming owns all custom code, configurations, and documentation produced specifically for this engagement (Lambda functions, IaC templates, API documentation, runbooks). nClouds retains ownership of its pre-existing methodologies, tools, accelerators, and frameworks used in delivery. ANP Streaming acknowledges that AWS services (Bedrock, Lambda, DynamoDB, etc.) are licensed under AWS's standard service terms and that nClouds does not transfer any AWS intellectual property rights.

## Service Levels

nClouds warrants that all deliverables will materially conform to the specifications agreed in this SOW for a period of **30 days** following Production go-live (the "Warranty Period"). During the Warranty Period, nClouds will remediate material defects at no additional charge. The Warranty Period does not cover issues arising from ANP Streaming's modifications to delivered code, changes in upstream dependencies (Firebase, FlutterFlow), or AWS service outages. This warranty is in addition to the 2-week hypercare support defined in Section 9.

## Liability

nClouds' total aggregate liability to ANP Streaming under this SOW shall not exceed the total professional services fees paid by ANP Streaming in the 3 months preceding the claim. Neither party shall be liable for indirect, consequential, punitive, or special damages. nClouds maintains professional indemnity and general liability insurance in amounts appropriate for engagements of this type; certificates of insurance are available upon request.

## Confidentiality

Both parties agree to maintain the confidentiality of the other party's proprietary information disclosed in connection with this engagement, consistent with the confidentiality provisions of the executed MSA (or, in the absence of an MSA, a mutual non-disclosure agreement signed by both parties prior to engagement commencement). Confidential information includes, but is not limited to, ANP Streaming's catalog data, user listening history, and business strategy, and nClouds' pricing, methodologies, and tooling. Confidentiality obligations survive termination of this SOW by 3 years.

## Termination

Either party may terminate this SOW with 10 business days' written notice. In the event of termination by ANP Streaming, ANP Streaming shall pay nClouds for all work completed and expenses incurred through the termination date, including any milestone payments earned. In the event of termination by nClouds for cause (including ANP Streaming's material breach or non-payment), all outstanding invoices become immediately due. AWS partner credits may be forfeited upon early termination at AWS's discretion; nClouds accepts no liability for forfeited credits arising from ANP Streaming's termination decision.

## Governing Law

This Statement of Work shall be governed by and construed in accordance with the laws of the State of California, USA, without regard to its conflict of law provisions. Any disputes arising under this SOW that cannot be resolved through good-faith negotiation shall be submitted to binding arbitration in San Francisco, California, under the rules of the American Arbitration Association.

---

# Sign-Off

By signing below, both parties confirm they have read and understood this Statement of Work and agree to the scope, deliverables, timeline, roles, investment, and terms described herein. This SOW becomes effective upon execution by both authorized signatories.

**Client Authorized Signatory — ANP Streaming:**

Name: __________________________
Title: __________________________
Signature: ______________________
Date: __________________________

**Service Provider Authorized Signatory — nClouds, Inc.:**

Name: __________________________
Title: __________________________
Signature: ______________________
Date: __________________________

---

*This Statement of Work, together with the Master Services Agreement, constitutes the complete and exclusive agreement between ANP Streaming and nClouds, Inc. with respect to the services described herein and supersedes all prior negotiations, representations, proposals, or agreements, whether written or oral, relating to the subject matter of this document.*

*Document Version: 1.0 | Prepared by nClouds, Inc. | June 2025 | Opportunity: OPP-2025-001*
