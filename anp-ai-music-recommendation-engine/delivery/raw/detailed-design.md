---
document_title: Detailed Design Document
solution_name: ANP Streaming AI Recommendation Engine
document_version: "1.0"
author: Jonas Bull
last_updated: 2026-03-19
technology_provider: aws
client_name: ANP Streaming
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Detailed Design Document provides the complete technical blueprint for the ANP Streaming AI Recommendation Engine, an AWS-native, serverless AI/ML platform that delivers emotion-based music and podcast discovery to the global Christian streaming community. Authored by nClouds, Inc. as the primary delivery partner, this document translates the commitments made in the Statement of Work (SOW) dated March 19, 2026 into implementation-ready specifications covering architecture, security, data design, integration, infrastructure, and delivery sequencing.

The ANP Streaming AI Recommendation Engine is a greenfield build consisting of five interacting ML capability domains: a Content Intelligence pipeline that classifies every catalog item by emotion, mood, and thematic attributes; a Catalog Enrichment service that applies classifications at artist upload time; a Recommendation Engine that learns listener preferences and generates personalized playlists; an API Service Layer that exposes all capabilities through a secured REST interface consumed by the existing FlutterFlow mobile application; and an Operational Control Plane providing monitoring, alerting, and automated model retraining. The entire platform is delivered into Dev and Staging AWS environments within a 13-week engagement window, with production deployment deferred to a subsequent phase per client direction.

This document is the authoritative technical reference for nClouds delivery engineers, ANP Streaming's Technical Lead, and all project stakeholders. Every design decision herein traces directly to a commitment in the SOW or a parameter defined in the Solution Briefing. No services, regions, or capabilities have been added beyond what was sold. The platform is designed to scale elastically from 100 to 100,000+ monthly active users (MAU) without architectural changes, supporting ANP Streaming's investor and accelerator narrative with tiered cost projections across all three MAU growth scenarios.

## Purpose

This document defines the implementation-ready technical design for the ANP Streaming AI Recommendation Engine. It serves as the primary reference for nClouds delivery engineers during Phases 2–5 of the engagement, the acceptance baseline against which ANP Streaming's Technical Lead validates all system deliverables, and the foundation for the operational runbooks and knowledge-transfer sessions delivered at engagement close. Readers should be familiar with AWS core services, serverless architecture patterns, and basic ML concepts. Non-technical stakeholders should focus on Sections 1–3, Section 9, and the Executive Summary.

## Scope

The following items define what is covered by this document and what lies outside its boundaries.

**In-scope:**

- Complete AWS architecture design for all five ML capability domains
- Content Intelligence pipeline: lyric/transcript NLP classifier, audio feature extraction pipeline, and catalog enrichment service
- Recommendation Engine: preference-learning model, mood-to-content matching algorithm, playlist generation service, and automated SageMaker Pipelines retraining workflow
- API Service Layer: five secured REST endpoints exposed through Amazon API Gateway with Amazon Cognito authentication
- Security architecture: IAM, KMS encryption, WAF, Secrets Manager, GuardDuty, and CloudTrail
- Data architecture: DynamoDB schema design, S3 storage organization, OpenSearch catalog index, and ElastiCache session caching
- Integration design: FlutterFlow-to-API Gateway REST integration and Firebase catalog API read access
- Infrastructure design for Dev and Staging environments in us-east-1
- Monitoring, alerting, observability, and disaster recovery design
- Implementation phasing, wave planning, and rollback strategy

**Out-of-scope:**

- Firebase data migration execution (catalog data is read via Firebase REST API, not migrated to AWS)
- Mobile frontend development or any modification to the FlutterFlow application
- Production environment deployment and go-live cutover (deferred to a future engagement)
- Listening-history storage and detailed interaction analytics (deferred to a later phase)
- Ongoing managed services or post-hypercare operational support
- Third-party data integrations (Spotify, Apple Music, or external music databases)
- Formal compliance certifications (SOC 2, HIPAA, PCI-DSS)

## Assumptions & Constraints

- ANP Streaming provides a dedicated AWS account with admin-level credentials to nClouds within 3 business days of the effective date (March 19, 2026).
- Representative lyric and transcript file samples (minimum 50 tracks/episodes) are provided in Week 1 to enable early classifier design and taxonomy validation.
- ANP provides read access to the Firebase catalog REST API and shares the existing mood-tagging schema before the requirements workshop.
- The solution is deployed in a single AWS region (us-east-1) unless mutually agreed otherwise in writing.
- All infrastructure is serverless-first; no EC2 provisioned instances are used outside of SageMaker managed inference and training instances.
- The mood taxonomy label set is collaboratively defined during Phase 1 and does not change after Phase 2 model training commences without a formal change request.
- The FlutterFlow application requires no frontend code modifications to consume the delivered REST API endpoints.
- AWS Partner Funding (APFP) approval of $25,000 is secured before billable work commences.
- No specific regulatory compliance certification is required for this engagement phase; AWS Well-Architected Security Pillar standards are the target framework.
- Cold-start handling for new users is addressed through content-based fallback recommendations from the mood-to-content matcher rather than collaborative filtering.

## References

- Statement of Work — ANP Streaming AI Recommendation Engine, nClouds, Inc., March 19, 2026
- Solution Briefing — ANP Streaming AI Recommendation Engine, Jonas Bull, nClouds, Inc.
- AWS Well-Architected Framework — Machine Learning Lens
- AWS Well-Architected Framework — Security Pillar
- Amazon SageMaker Developer Guide
- Amazon Personalize Developer Guide
- Infrastructure Costs Model — infrastructure-costs.csv (nClouds internal)
- Level-of-Effort Estimate — level-of-effort-estimate.csv (nClouds internal)

---

# Business Context

ANP Streaming is an early-stage, faith-based music and podcast streaming platform with a mission to serve the global Christian community — a market exceeding 2.4 billion people that is significantly underserved by contemporary, Western-centric streaming services. The platform currently operates through a FlutterFlow mobile application backed by Firebase, with a growing catalog of music tracks and podcast episodes. While a foundational mood-tagging schema exists in Firebase, there is no AI/ML backend today: content discovery relies entirely on manual genre tagging and static browsing patterns, and there is no personalization engine driving playlist generation or user engagement.

This engagement addresses that gap directly. By delivering a fully decoupled, API-accessible AI/ML backend on AWS, nClouds equips ANP Streaming with a technology asset that differentiates the platform, scales elastically with user growth, and supports the investor and accelerator narrative with quantified cost projections across three MAU growth scenarios.

## Business Drivers

The following strategic drivers directly shape the technical design decisions documented throughout this document.

- **Differentiated Discovery Experience:** ANP Streaming must offer emotion-based, mood-driven content discovery that competitors using genre tags alone cannot replicate. This drives the design of the NLP classifier, audio feature extraction pipeline, and mood-to-content matching algorithm — all of which operate on multi-attribute content vectors rather than simple genre metadata.
- **Decoupled AI Backend:** The AI intelligence layer must be a long-lived business asset independent of the FlutterFlow frontend. If ANP migrates to a different mobile framework in the future, the recommendation engine must survive that change. This drives the API-first design philosophy: all AI capabilities are exposed through versioned REST endpoints, and the FlutterFlow application has no direct dependency on any AWS ML service.
- **Elastic Scale from Day One:** ANP's user base is expected to grow from approximately 100 MAU at launch to 10,000 and eventually 100,000+ MAU. The architecture must accommodate this growth without provisioned-capacity changes at lower tiers. This drives the serverless-first design using Lambda, API Gateway, and DynamoDB on-demand capacity.
- **Continuous Improvement Loop:** Recommendation quality must improve as user interaction data accumulates. This drives the design of the SageMaker Pipelines retraining workflow and the feedback-capture endpoint that feeds preference signals back into the model.
- **Investor-Ready Cost Modeling:** ANP is engaged in accelerator and investor conversations and requires credible, data-driven AWS cost projections at 100, 10K, and 100K MAU growth scenarios. This drives the tiered cost model deliverable (Deliverable 7) produced in Phase 1.
- **Zero Net Professional-Services Cost:** The engagement is fully funded by $25,000 in AWS Partner Funding through the APFP program, resulting in a net professional-services cost of $0.00 to ANP Streaming. This drives the selection of AWS-native managed services (Comprehend, Personalize, Transcribe, Bedrock) that are eligible under the funding program and minimize custom infrastructure management overhead.

## Workload Criticality & SLA Expectations

The following table defines the performance and availability targets that the solution design must achieve. These targets are drawn directly from the SOW success metrics and scope parameters.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Metric | Target | Measurement | Priority |
|--------|--------|-------------|----------|
| Playlist API Response Time | ≤ 2 seconds | p95 latency under 100 MAU simulated load | Critical |
| Mood Classifier Accuracy | ≥ 90% agreement with human-labeled test set | Holdout set evaluation at Phase 2 close | Critical |
| Service Availability | 99.5% (Standard tier) | CloudWatch uptime monitoring on API Gateway | High |
| Catalog Enrichment Throughput | < 60 seconds per upload | Step Functions execution time per catalog item | High |
| RTO (Service Restoration) | 4 hours | DynamoDB PITR restore drill in Staging | Critical |
| RPO (Data Protection) | 1 hour | DynamoDB PITR continuous backup coverage | Critical |
| Model Retraining Cycle | Weekly (configurable) | SageMaker Pipelines schedule | Medium |
| API Error Rate | < 1% | CloudWatch API Gateway 5xx rate | High |

## Compliance & Regulatory Factors

The following compliance and regulatory considerations shape the security architecture and operational design for this engagement.

- **AWS Well-Architected Framework (Security Pillar):** The primary design standard for all security controls implemented in this engagement. All IAM policies, encryption configurations, logging, and monitoring are designed to meet Well-Architected Security Pillar requirements.
- **No Formal Certification Required:** SOC 2, HIPAA, PCI-DSS, and GDPR formal certification are explicitly out of scope for this engagement phase. However, the architecture implements foundational controls (KMS encryption, CloudTrail immutable logging, least-privilege IAM, Cognito authentication) that support future certification with minimal additional effort.
- **User Data Privacy:** User preference vectors stored in DynamoDB represent behavioral data. No personally identifiable information (PII) beyond a Cognito-issued user ID is stored in the preference vector schema, minimizing privacy risk and simplifying future compliance work.
- **Faith-Based Content Sensitivity:** Content classification outputs (emotion, mood, thematic attributes) are applied to faith-based music and podcast content. The mood taxonomy design must be reviewed and approved by ANP Streaming's CEO (Lilly Goyah) before classifier training commences to ensure cultural and theological appropriateness of the label set.

## Success Criteria

The following criteria define a successful engagement outcome. All criteria are validated during Phase 5 Testing & Validation before formal project close.

- Catalog emotion/mood classification pipeline processes all existing catalog entries and new uploads at ingest time within the engagement period.
- Content classifier achieves ≥ 90% agreement with human-labeled test set on emotion and mood attributes.
- Playlist generation API responds within ≤ 2 seconds under simulated 100 MAU load.
- Preference-learning model produces recommendations with measurable improvement after the first retraining cycle.
- All five REST API endpoints are functional, documented, and respond correctly to FlutterFlow-simulated call patterns.
- Mood taxonomy defines ≥ 10 distinct emotion/mood labels with annotation guidelines and worship-style coverage.
- Tiered cost model delivered covering all three MAU growth scenarios (100, 10K, 100K) in Phase 1.
- Two knowledge-transfer sessions conducted with the ANP technical team, confirmed by session attendance records.
- Full deliverable package (architecture diagrams, data schemas, API contracts, runbooks) accepted by ANP within the engagement window.

---

# Current-State Assessment

ANP Streaming is a greenfield AI/ML implementation in the sense that no AI, ML, or recommendation infrastructure exists today. However, the platform is not a blank slate: a functioning FlutterFlow mobile application is in production, a Firebase backend hosts an active catalog of music tracks and podcast episodes, and ANP's team has defined a preliminary mood-tagging schema. This section documents the existing environment that the AI backend will integrate with, the gaps that must be addressed, and the constraints the existing stack places on the design.

## Application Landscape

The following table describes the application components in ANP Streaming's current environment, their purpose, technology stack, and disposition in this engagement.

<!-- TABLE_CONFIG: widths=[25, 30, 25, 20] -->
| Application | Purpose | Technology | Disposition |
|-------------|---------|------------|-------------|
| FlutterFlow Mobile App | Primary user-facing interface for music and podcast streaming | FlutterFlow / Flutter / Dart | Integrate (no frontend changes) |
| Firebase Realtime Database | Catalog metadata, mood-tagging schema, user account data | Google Firebase (NoSQL) | Read via REST API (no migration) |
| Firebase Authentication | Current user identity management | Firebase Auth | Parallel (Cognito added for API auth) |
| Content Catalog | Music tracks and podcast episodes with manual metadata | Firebase-hosted JSON metadata, file storage | Enrich via AWS classification pipeline |

## Infrastructure Inventory

The following table summarizes the existing infrastructure components relevant to this engagement.

<!-- TABLE_CONFIG: widths=[20, 15, 35, 30] -->
| Component | Quantity | Specifications | Notes |
|-----------|----------|----------------|-------|
| Firebase Project | 1 | Google Firebase Spark/Blaze plan; real-time database + auth + storage | Read access required in Week 1 |
| FlutterFlow Application | 1 | FlutterFlow-hosted; multi-platform (iOS/Android) | No modifications in scope |
| Lyric/Transcript Files | Variable | Text files associated with catalog entries (coverage incomplete) | Available for NLP classifier training |
| AWS Account | 1 (new) | Dedicated ANP Streaming AWS account, us-east-1 | Customer provisions; admin access provided to nClouds |
| Mood Taxonomy Schema | 1 (draft) | Firebase-based emotion/mood tag fields; preliminary label set | Input to Phase 1 taxonomy design |

## Dependencies & Integration Points

The following dependencies and integration points must be addressed before or during the engagement.

- Firebase REST API access must be granted to nClouds in Week 1 to enable current-state assessment of catalog schema and FlutterFlow call patterns.
- Existing Firebase mood-tagging schema must be shared before the requirements workshop to ensure the new AWS-hosted mood taxonomy is aligned with and extends the existing tag structure.
- Lyric and transcript file samples (minimum 50 tracks/episodes) must be provided in Week 1 to enable classifier design and early taxonomy validation.
- FlutterFlow API call patterns (endpoint signatures, authentication headers, payload formats) must be documented by the ANP Technical Lead for use in Phase 4 API design and Phase 5 integration validation.
- No AWS infrastructure currently exists; the customer provides a new dedicated AWS account before project kickoff.

## Network Topology

ANP Streaming operates no on-premises infrastructure. The current environment is fully cloud-hosted: Firebase (Google Cloud) for the backend and FlutterFlow for the mobile application. The AI backend being built in this engagement runs in AWS us-east-1 and communicates with Firebase exclusively over HTTPS via the Firebase REST API — no VPN, Direct Connect, or site-to-site connectivity is required. The FlutterFlow application will communicate with the new API Gateway endpoint over HTTPS from the mobile device network.

## Security Posture

The current environment has minimal security instrumentation relevant to the AI backend. Firebase Authentication handles user identity for the mobile app. There is no API authentication layer for the backend services beyond Firebase's native auth. There are no IAM roles, KMS encryption, WAF rules, or CloudWatch monitoring in place. The new AWS environment will establish a complete security control set from scratch, including Cognito authentication, KMS encryption, WAF, CloudTrail, and GuardDuty, aligned to the AWS Well-Architected Security Pillar.

## Performance Baseline

The following baseline metrics characterize the current platform prior to AI backend deployment.

- Average playlist response time: N/A (no playlist generation exists today — static browsing only)
- Peak concurrent users: Estimated at < 100 MAU at engagement start
- Daily content uploads: Low volume at early stage; expected to grow as catalog expands
- Classification throughput: N/A (no automated classification exists today)
- API call volume: < 50,000 requests per month at the 100 MAU scale tier

## Gap Analysis

The following table maps the current state limitations to the target state capabilities delivered by this engagement.

<!-- TABLE_CONFIG: widths=[33, 34, 33] -->
| Current State | Gap | Target State |
|---------------|-----|--------------|
| No content classification; manual genre tagging only | No automated emotion/mood/thematic tagging | NLP + audio classification pipeline classifies all catalog items at ingest; emotion scores written to DynamoDB |
| No recommendation engine; static browsing only | No personalization of content discovery | Amazon Personalize preference-learning model delivers personalized playlists based on mood input and listening history |
| No mood-to-content matching | Mood input cannot drive discovery | Custom mood-to-content matcher correlates emotional state with multi-attribute content vectors |
| No playlist generation service | Playlists are manual or absent | Lambda-based playlist generation service returns ordered track/podcast lists in ≤ 2 seconds |
| No API layer for AI capabilities | FlutterFlow cannot consume AI services | Amazon API Gateway + Cognito expose 5 secured REST endpoints with no frontend changes required |
| Manual tagging takes hours per upload | Unsustainable as catalog grows | Automated enrichment at upload time reduces tagging effort to < 60 seconds per item |
| No model retraining capability | Recommendations cannot improve over time | SageMaker Pipelines weekly retraining cycle continuously improves model quality |
| No investor-ready cost modeling | Cannot quantify platform costs for fundraising | Tiered AWS cost model across 100, 10K, 100K MAU scenarios delivered in Phase 1 |

---

# Solution Architecture

The ANP Streaming AI Recommendation Engine is designed as a fully serverless, platform-agnostic, API-first AWS-native service. The architecture is organized into five logical capability domains — Content Intelligence, Catalog Enrichment, Recommendation Engine, API Service Layer, and Operational Control Plane — each of which is independently testable, deployable, and evolvable without cascading changes to the other domains. This decoupling is the architectural foundation that ensures the AI backend survives any future frontend migration and operates as a long-lived business asset for ANP Streaming.

The platform is built entirely on AWS managed and serverless services: AWS Lambda for compute, Amazon API Gateway for REST exposure, Amazon DynamoDB for low-latency data access, Amazon SageMaker for ML model training and inference, Amazon Personalize for collaborative-filtering recommendations, Amazon Comprehend for NLP classification, Amazon Bedrock for foundation model inference, Amazon OpenSearch Service for semantic catalog search, and Amazon ElastiCache (Redis) for session and playlist caching. This stack eliminates the need for provisioned server infrastructure at the 100–10,000 MAU scale range and scales predictably with usage volume, directly supporting ANP's investor cost narrative.

The entire solution is deployed in a single AWS region (us-east-1) across two environments — Dev and Staging — provisioned as code through AWS CDK/CloudFormation. All inter-service communication occurs within the AWS private network or over HTTPS; no data traverses the public internet except inbound API calls from FlutterFlow (HTTPS to API Gateway) and outbound Firebase REST API reads (HTTPS from Lambda).

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

*Figure 1: ANP Streaming AI Recommendation Engine — End-to-end AWS architecture showing the five capability domains, data flows from content ingestion through classification and preference learning to playlist generation, and the secured REST API consumed by the FlutterFlow mobile application.*

## Architecture Principles

The following design principles govern every architectural decision in this document and trace directly to the business drivers and SOW commitments established in Sections 1 and 2.

- **API-First Decoupling:** All AI capabilities are exposed exclusively through versioned REST endpoints. No ML model, pipeline, or data store is directly accessible by the FlutterFlow application. This ensures the intelligence layer is a platform-agnostic business asset that survives frontend migrations.
- **Serverless by Default:** Every compute component uses managed serverless infrastructure (Lambda, API Gateway, Step Functions, DynamoDB on-demand) unless a managed ML service (SageMaker, Personalize) requires an instance type. This eliminates capacity planning at the 100–10,000 MAU range and reduces operational overhead.
- **Security by Design:** Authentication, authorization, encryption, and audit logging are built into every layer from day one — not added as afterthoughts. Cognito JWT authentication at API Gateway, KMS encryption at rest, TLS 1.2+ in transit, and CloudTrail immutable logging are non-negotiable baseline controls.
- **Continuous Improvement by Architecture:** The preference-learning model is not a static artifact; it improves as user interaction data accumulates. The SageMaker Pipelines retraining workflow is built into the architecture from the start, not bolted on later. Feedback signals captured from the API feed directly into the retraining loop.
- **Observability as a First-Class Concern:** Every Lambda function, SageMaker endpoint, Step Functions execution, and API Gateway call emits structured logs, custom metrics, and traces to CloudWatch. Dashboards and alarms are delivered as part of the operational handover, not as post-engagement additions.
- **Mood Taxonomy as a Shared Canonical Reference:** The emotion/mood/theme label set defined in Phase 1 is the single source of truth consumed by every component in the platform — the NLP classifier, the audio analyzer, the mood-to-content matcher, the DynamoDB reference table, and the API schema. Divergence in label definitions across components is architecturally prohibited.

## Architecture Patterns

The following patterns describe the high-level design approaches applied across the platform.

- **Primary Pattern:** Event-driven serverless microservices — each capability domain is composed of independent Lambda functions and managed services triggered by events (EventBridge, SQS, Step Functions) rather than synchronous direct calls between components.
- **Data Pattern:** Command Query Responsibility Segregation (CQRS) at the catalog layer — catalog enrichment writes (classification outputs) are separated from catalog reads (playlist and search queries), enabling independent scaling of write-heavy ingest and read-heavy serving paths.
- **Integration Pattern:** REST API Gateway with Cognito JWT authorization — FlutterFlow consumes all AI capabilities through a single API Gateway regional endpoint; all business logic is encapsulated in Lambda authorizers and endpoint-specific Lambda handlers.
- **Deployment Pattern:** Blue-green model deployments via SageMaker Model Registry — new model versions are promoted to the production endpoint only after evaluation against a holdout set; the previous version is retained as an immediate rollback target.
- **Retraining Pattern:** Scheduled pipeline with conditional promotion — SageMaker Pipelines runs on a weekly schedule, retrains the preference-learning model, evaluates accuracy metrics against a threshold, and promotes the new model only if evaluation criteria are met.

## Component Design

The following table describes the primary components of the ANP Streaming AI Recommendation Engine, their responsibilities, technology choices, dependencies, and scaling behavior. Each component maps to one or more SOW deliverables.

<!-- TABLE_CONFIG: widths=[18, 25, 22, 18, 17] -->
| Component | Purpose | Technology | Dependencies | Scaling |
|-----------|---------|------------|--------------|---------|
| NLP Emotion/Mood Classifier | Classify lyric and transcript text by emotion, mood, and thematic attributes | Amazon SageMaker endpoint (fine-tuned NLP model) + Amazon Comprehend | S3 (text input), DynamoDB (output write), Bedrock (FM inference) | SageMaker endpoint auto-scaling; Bedrock on-demand |
| Audio Feature Extractor | Compute valence, energy, and worship-style sonic vectors from audio files | Amazon SageMaker endpoint (custom audio model) + Lambda | S3 (audio input), DynamoDB (output write) | SageMaker endpoint auto-scaling |
| Catalog Enrichment Service | Orchestrate classification at artist upload time; write enriched metadata to catalog | AWS Lambda + AWS Step Functions + Amazon EventBridge | NLP Classifier, Audio Extractor, DynamoDB, S3 | Lambda auto-scaling; Step Functions standard workflows |
| Preference-Learning Model | Learn user content preferences from mood inputs, genre selections, and interaction events | Amazon Personalize (collaborative-filtering + content-based hybrid) | DynamoDB (user events), SageMaker Pipelines (retraining) | Personalize campaign auto-scaling |
| Mood-to-Content Matcher | Correlate user emotional state input with multi-attribute content vectors | Amazon SageMaker endpoint (custom matching model) | DynamoDB (content vectors), Personalize output | SageMaker endpoint auto-scaling |
| Playlist Generation Service | Assemble ordered playlist combining Personalize output, mood matching, session context, and feedback | AWS Lambda | Personalize, Mood Matcher, DynamoDB, ElastiCache | Lambda auto-scaling |
| Model Retraining Pipeline | Weekly automated retraining of preference model with conditional promotion | SageMaker Pipelines + SageMaker Model Registry | DynamoDB (interaction events), S3 (training data, model artifacts) | Managed by SageMaker Pipelines scheduler |
| API Gateway + Authorizer | Route and authenticate all FlutterFlow REST requests | Amazon API Gateway (regional REST) + Lambda Authorizer + AWS WAF | Cognito (token validation), Lambda handlers | API Gateway managed auto-scaling |
| Cognito User Pool | Issue and validate JWT tokens for API authentication | Amazon Cognito | FlutterFlow (token request), API Gateway (token validation) | Cognito managed scaling |
| Feedback Capture Service | Capture play/skip/like/dislike events and feed them into the preference-learning loop | AWS Lambda + Amazon SQS + Amazon EventBridge | DynamoDB (preference vector update), Personalize (event tracker) | Lambda + SQS auto-scaling |
| Content Catalog Store | Store enriched catalog metadata with emotion/mood/theme attribute scores | Amazon DynamoDB (on-demand) | Classification pipeline, Playlist service, OpenSearch sync | DynamoDB on-demand auto-scaling |
| Semantic Search Index | Enable emotion-attribute-based catalog search for playlist and discovery queries | Amazon OpenSearch Service (t3.small.search) | DynamoDB (catalog sync), Playlist Lambda | OpenSearch single-node (scale up at 10K MAU) |
| Session & Playlist Cache | Cache recently generated playlists and session state to reduce API latency | Amazon ElastiCache (Redis, cache.t3.micro) | Playlist Lambda, API Gateway | ElastiCache cluster scaling |

## Technology Stack

The following table defines the technology choice for each architectural layer, the specific AWS service selected, and the rationale rooted in the SOW scope and business requirements.

<!-- TABLE_CONFIG: widths=[20, 40, 40] -->
| Layer | Technology | Rationale |
|-------|------------|-----------|
| ML Training & Inference | Amazon SageMaker (ml.t3.medium endpoint, ml.m5.xlarge training) | Managed ML platform eliminating infrastructure setup; SageMaker Pipelines provides built-in retraining orchestration and Model Registry for versioned rollback |
| Foundation Model Inference | Amazon Bedrock (Amazon Titan / Anthropic Claude) | On-demand FM token pricing ($600/year at 100 MAU) with no provisioned capacity; supports lyric and transcript emotion enrichment without custom model pretraining |
| NLP Classification | Amazon Comprehend | Managed NLP service for entity, sentiment, and key-phrase extraction from lyric/transcript text; reduces custom model development effort for standard NLP tasks |
| Recommendation | Amazon Personalize | Purpose-built AWS collaborative-filtering service; native integration with DynamoDB event ingestion; eliminates custom recommender infrastructure |
| Semantic Search | Amazon OpenSearch Service (t3.small.search) | Enables emotion-attribute-based catalog search required for playlist diversity and discovery; t3.small sufficient for < 5,000 catalog entries |
| API Layer | Amazon API Gateway (regional REST) + AWS Lambda | Serverless REST API with built-in throttling, WAF integration, and Lambda authorizer support; zero standing compute cost at low request volumes |
| Authentication | Amazon Cognito | AWS-native user pool with JWT issuance; native API Gateway integration; supports listener, artist/uploader, and admin roles with distinct permission scopes |
| Event Orchestration | AWS Step Functions + Amazon EventBridge + Amazon SQS | Step Functions manages multi-step classification workflows with retry logic; EventBridge routes catalog upload events; SQS buffers feedback capture events |
| Data Store | Amazon DynamoDB (on-demand capacity) | Serverless NoSQL with predictable sub-millisecond read latency; on-demand mode eliminates capacity planning at variable ingest volumes |
| Object Storage | Amazon S3 | Durable object storage for audio files, transcripts, feature vectors, and model artifacts; lifecycle policies manage storage cost through IA and Glacier tiering |
| Caching | Amazon ElastiCache (Redis, cache.t3.micro) | Sub-millisecond playlist and session caching reduces SageMaker and DynamoDB read load on repeated requests; critical for ≤ 2-second API response target |
| Secrets Management | AWS Secrets Manager | Centralized credential storage with 90-day auto-rotation for Firebase credentials, API keys, and connection strings; no credentials in code or environment variables |
| Monitoring | Amazon CloudWatch + AWS CloudTrail + Amazon GuardDuty | CloudWatch provides logs, custom metrics, and alarms; CloudTrail provides immutable API audit trail; GuardDuty provides threat detection and anomaly alerting |
| IaC & Deployment | AWS CDK / CloudFormation | Infrastructure-as-code for reproducible Dev and Staging environment provisioning; all changes applied via CI/CD pipeline — no manual console changes in Staging |
| CI/CD | AWS CodePipeline + AWS CodeBuild | Automated deployment of Lambda functions, model updates, and infrastructure changes; supports controlled promotion from Dev to Staging |

---

# Security & Compliance

Security is designed into every layer of the ANP Streaming AI Recommendation Engine from the first line of infrastructure code. The security architecture is aligned to the AWS Well-Architected Framework Security Pillar and implements defense-in-depth across identity and access management, network security, data protection, threat detection, and governance. Every security control implemented during this engagement traces directly to a requirement in the SOW Security & Compliance section.

## Identity & Access Management

Amazon Cognito serves as the identity provider for the ANP Streaming platform, managing the user pool for all three defined roles — listener, artist/uploader, and admin — with distinct permission scopes enforced at the API Gateway layer. All API calls from the FlutterFlow application must present a valid Cognito JWT access token; expired, invalid, or missing tokens are rejected by the Lambda authorizer before any backend Lambda function is invoked.

AWS IAM follows strict least-privilege principles throughout. Every Lambda function, SageMaker endpoint, Step Functions state machine, and CodeBuild project is assigned a dedicated IAM execution role scoped to the exact AWS resources that component requires. No wildcard resource policies (`Resource: "*"`) are used on production or Staging resources. IAM Access Analyzer is enabled on the AWS account to detect and alert on overly permissive policies. Admin access to the AWS account is restricted to named IAM users or federated SSO roles with MFA enforcement enforced via an IAM policy condition. Root account credentials are secured and root account usage is disabled for all day-to-day operations.

### Role Definitions

The following table defines the application-level roles managed in the Cognito User Pool and their corresponding permission scopes across the API endpoints.

<!-- TABLE_CONFIG: widths=[20, 40, 40] -->
| Role | Permissions | Scope |
|------|-------------|-------|
| Listener | Read user profile/session; invoke playlist generation; submit feedback (play/skip/like/dislike) | Own user record only; read-only catalog access |
| Artist/Uploader | Invoke content classification endpoint; read own catalog item enrichment results | Own catalog items only; no access to other users' data |
| Admin | All listener and artist permissions; read aggregated model metrics; invoke manual retraining trigger | All resources in Dev and Staging environments |
| nClouds Engineer (Delivery) | Full access to Dev environment; full access to Staging environment during engagement period | Scoped to engagement period; deprovisioned at project closeout |
| ANP Technical Lead | Full access to Staging post-delivery; read access to CloudWatch dashboards and logs | All non-production resources; no standing access to production |

## Secrets Management

All credentials, API keys, and connection strings are managed exclusively through AWS Secrets Manager — no secrets are stored in environment variables, Lambda function configurations, source code, or CloudFormation parameter files in plaintext.

- **Firebase REST API credentials** are stored as a Secrets Manager secret and referenced by the catalog enrichment Lambda at runtime.
- **Third-party API keys** (if any are required during the engagement) follow the same Secrets Manager pattern.
- **Secrets rotation** is configured on a 90-day automatic rotation schedule for all secrets where rotation is supported.
- **Access logging** for Secrets Manager calls is captured in CloudTrail, providing an immutable record of every credential access event.
- Lambda execution roles are granted `secretsmanager:GetSecretValue` permissions only to the specific secret ARNs required by each function — not to all secrets in the account.

## Network Security

The solution operates in a dedicated VPC in us-east-1 with a multi-layer network segmentation model that keeps ML inference endpoints, database clusters, and cache nodes off the public internet.

- **Segmentation:** Private subnets host all SageMaker endpoint ENIs, OpenSearch nodes, and ElastiCache clusters. Lambda functions that access private resources (OpenSearch, ElastiCache) are VPC-attached; Lambda functions that access DynamoDB and S3 exclusively use VPC Gateway Endpoints to keep traffic within the AWS network without traversing the public internet.
- **Firewall:** Security groups implement least-privilege ingress/egress rules. SageMaker endpoint security groups allow inbound traffic only from Lambda security groups. OpenSearch security group allows inbound only from Playlist Lambda security group. ElastiCache security group allows inbound only from Playlist Lambda and Authorizer Lambda security groups.
- **WAF:** AWS WAF v2 is attached to the API Gateway regional endpoint with AWS Managed Rule Groups enabled: Core Rule Set (CRS), Known Bad Inputs, and IP Reputation List. Rate-based rules enforce per-IP throttling to protect against credential stuffing and abuse.
- **DDoS Protection:** AWS Shield Standard (included at no additional cost) provides always-on DDoS protection for the API Gateway regional endpoint. AWS WAF rate-based rules provide application-layer burst protection.
- **TLS Termination:** All inbound traffic arrives over HTTPS with TLS 1.2 minimum enforced at the API Gateway level via a security policy. AWS Certificate Manager manages the TLS certificate for the API Gateway custom domain.

## Data Protection

The following encryption controls are implemented across all data stores and communication paths in the platform.

- **Encryption at Rest:** All S3 buckets (raw-catalog, transcripts, features, models) are encrypted with AWS KMS Customer Managed Keys (CMKs). All DynamoDB tables (content catalog, user preference vectors, mood taxonomy, session context) are encrypted with KMS CMKs. SageMaker model artifacts stored in S3 are covered by the same KMS CMK applied to the models bucket. ElastiCache at-rest encryption is enabled with KMS CMK.
- **Encryption in Transit:** TLS 1.2 or higher is enforced for all communications: FlutterFlow to API Gateway, Lambda to DynamoDB, Lambda to S3, Lambda to OpenSearch, Lambda to ElastiCache, Lambda to SageMaker endpoints, Lambda to Firebase REST API. AWS Certificate Manager manages all TLS certificates.
- **Key Management:** All KMS CMKs have automatic annual key rotation enabled (12-month rotation schedule). A dedicated CMK is used per data classification tier — catalog data CMK, user data CMK, model artifact CMK — enabling independent key rotation and access auditing.
- **Data Masking:** In Dev and Staging environments, only synthetic data and anonymized catalog subsets are used. No real user PII is present in non-production environments. Catalog item content (lyrics, transcripts) is masked to a representative subset for testing purposes.

## Compliance Mappings

The following table maps the key compliance controls implemented in this engagement to their AWS Well-Architected Security Pillar requirements and implementation mechanisms.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Framework | Requirement | Implementation |
|-----------|-------------|----------------|
| AWS Well-Architected (Security) | SEC 01: Implement strong identity foundation | Cognito User Pool with JWT; IAM least-privilege; MFA on admin accounts; IAM Access Analyzer |
| AWS Well-Architected (Security) | SEC 02: Enable traceability | CloudTrail management events trail with S3 Object Lock; CloudWatch Logs for all Lambda and API Gateway access logs |
| AWS Well-Architected (Security) | SEC 03: Apply security at all layers | WAF at API Gateway; security groups for VPC resources; KMS encryption at rest; TLS 1.2+ in transit |
| AWS Well-Architected (Security) | SEC 04: Automate security best practices | AWS Config managed rules; CDK/CloudFormation IaC preventing manual console changes; automated Secrets Manager rotation |
| AWS Well-Architected (Security) | SEC 05: Protect data in transit and at rest | KMS CMK encryption for all data stores; TLS 1.2+ for all communications; ACM-managed certificates |
| AWS Well-Architected (Security) | SEC 06: Keep people away from data | No direct developer access to DynamoDB production tables; all data access through IAM-scoped Lambda roles; no standing production access for nClouds |
| AWS Well-Architected (Security) | SEC 07: Prepare for security events | GuardDuty threat detection; Security Hub aggregated findings; SNS alerting on GuardDuty high/critical findings; documented security incident runbook |

## Audit Logging & SIEM Integration

The following logging and audit controls are implemented to provide a complete, tamper-resistant audit trail for all activities within the AWS account.

- **CloudTrail:** A management-event trail is enabled across all AWS services in the account, with events delivered to a dedicated S3 bucket with Object Lock (WORM) enabled to prevent log tampering. CloudTrail data events are enabled for all S3 buckets and DynamoDB tables containing user data and model artifacts.
- **CloudWatch Logs:** All Lambda function logs, API Gateway access logs, Step Functions execution histories, and SageMaker endpoint invocation logs are streamed to CloudWatch Logs with a 90-day retention period.
- **GuardDuty Findings:** GuardDuty findings at HIGH and CRITICAL severity are routed via CloudWatch Events to an SNS topic that delivers alerts to the ANP security team. A Lambda function processes GuardDuty findings and creates tickets in the ANP incident-management channel.
- **Security Hub:** AWS Security Hub aggregates findings from GuardDuty, AWS Config, and IAM Access Analyzer into a unified security posture dashboard, reviewed by the ANP Technical Lead at monthly operational reviews.
- **SIEM Integration:** Full SIEM integration is out of scope for this engagement. CloudWatch Logs and CloudTrail S3 delivery provide the log sources that a future SIEM integration can consume via a Kinesis Data Firehose or S3-based ingestion pipeline.

---

# Data Architecture

The data architecture for the ANP Streaming AI Recommendation Engine is designed to support three distinct access patterns simultaneously: high-throughput write ingestion at catalog enrichment time, sub-millisecond read access for real-time playlist generation, and batch access for model retraining. These competing requirements are addressed through purpose-built data stores — DynamoDB for operational record access, S3 for bulk object and model artifact storage, OpenSearch for semantic search, and ElastiCache for low-latency read caching — rather than a single general-purpose database.

## Data Model

### Conceptual Model

The data model is organized around four core data domains: **Content** (music tracks and podcast episodes with enriched AI attributes), **Users** (listener preference vectors and session context), **Mood Taxonomy** (canonical emotion/mood/theme label set shared across all pipeline components), and **Interactions** (feedback events that feed the preference-learning loop). Content and Users are the primary operational domains; Mood Taxonomy is a reference domain; Interactions is an append-only event domain.

### Logical Model

The following table defines the primary entities, their key attributes, relationships, and expected data volumes at the 100 MAU scale tier.

<!-- TABLE_CONFIG: widths=[20, 30, 25, 25] -->
| Entity | Key Attributes | Relationships | Volume |
|--------|----------------|---------------|--------|
| ContentItem | `item_id` (PK), `title`, `artist`, `content_type` (music/podcast), `emotion_scores` (map), `mood_label`, `thematic_tags[]`, `audio_features` (map), `firebase_id`, `enriched_at` | HasMany: InteractionEvents; References: MoodTaxonomyLabel | < 5,000 items at engagement start; grows with uploads |
| UserProfile | `user_id` (PK), `cognito_sub`, `preference_vector` (map), `mood_history[]`, `genre_weights` (map), `last_updated`, `interaction_count` | HasMany: InteractionEvents; References: ContentItem | Grows with MAU; ~100 records at 100 MAU |
| InteractionEvent | `event_id` (PK), `user_id` (SK), `item_id`, `event_type` (play/skip/like/dislike), `timestamp`, `session_id`, `mood_context` | BelongsTo: UserProfile, ContentItem | High append volume; primary retraining input |
| MoodTaxonomyLabel | `label_id` (PK), `label_name`, `category` (emotion/mood/worship_style), `description`, `annotation_guidelines`, `version` | Referenced by: ContentItem, UserProfile | Stable reference data; ≥ 10 labels defined in Phase 1 |
| SessionContext | `session_id` (PK), `user_id`, `current_mood`, `time_of_day`, `recently_played[]`, `active_playlist_id`, `ttl` | BelongsTo: UserProfile | Ephemeral; cached in ElastiCache with TTL |
| GeneratedPlaylist | `playlist_id` (PK), `user_id`, `mood_input`, `tracks[]`, `generated_at`, `source` (personalize/mood_match/cold_start), `ttl` | BelongsTo: UserProfile | Ephemeral; cached in ElastiCache with TTL |

## Data Flow Design

Data flows through the ANP Streaming AI Recommendation Engine across two primary paths: the **Content Enrichment Path** (triggered at artist upload time) and the **Playlist Generation Path** (triggered by FlutterFlow API calls). A third background path handles **Model Retraining** on a weekly schedule.

The Content Enrichment Path operates as follows:
1. **Ingest:** Artist uploads a new track or podcast to Firebase. EventBridge rule detects the upload event and triggers the Catalog Enrichment Lambda.
2. **Orchestration:** The Enrichment Lambda initiates a Step Functions execution that branches into two parallel classification sub-workflows — the NLP/Text Classification workflow and the Audio Feature Extraction workflow.
3. **Text Classification:** The NLP workflow reads the lyric or transcript file from S3 (or fetches it via Firebase REST API), submits it to Amazon Comprehend for entity/sentiment extraction, and passes the enriched text to the SageMaker NLP classifier endpoint for emotion, mood, and thematic attribute scoring. Amazon Bedrock (Titan/Claude) is invoked for nuanced lyric interpretation where NLP classifier confidence is below threshold.
4. **Audio Analysis:** The Audio workflow reads the audio file from S3, passes it through the SageMaker audio feature extraction endpoint, and returns valence, energy, and worship-style vectors.
5. **Store:** Both classification outputs are aggregated by the Step Functions workflow and written to the ContentItem record in DynamoDB. The DynamoDB Streams trigger an OpenSearch sync Lambda that updates the content search index.
6. **Validation:** The enriched record is available for playlist generation immediately after DynamoDB write completes (sub-second latency for subsequent reads).

The Playlist Generation Path operates as follows:
1. **API Request:** FlutterFlow sends an authenticated POST to `/api/v1/playlists` with a Cognito JWT and a request body containing `user_id` and `mood_input`.
2. **Authorization:** API Gateway Lambda authorizer validates the JWT against the Cognito User Pool. Invalid tokens are rejected with HTTP 401 before any backend code runs.
3. **Cache Check:** The Playlist Lambda checks ElastiCache for a cached playlist matching the user_id + mood_input key. If a cache hit is found and the playlist is < 10 minutes old, it is returned immediately.
4. **Preference Lookup:** On cache miss, the Lambda reads the UserProfile from DynamoDB to retrieve the current preference vector and recent listening history.
5. **Recommendation:** The Lambda invokes Amazon Personalize to generate a ranked candidate list based on the user preference vector and historical interactions.
6. **Mood Filtering:** The ranked candidate list is passed to the Mood-to-Content Matcher SageMaker endpoint, which re-ranks candidates based on cosine similarity between the `mood_input` vector and each candidate's `emotion_scores`.
7. **Assembly:** The Playlist Lambda assembles the final ordered track/podcast list incorporating session context (time of day, recently played exclusions) and returns it to API Gateway.
8. **Cache Write:** The generated playlist is written to ElastiCache with a 10-minute TTL before the response is returned to the client.
9. **Response:** API Gateway returns the playlist JSON to FlutterFlow with a target p95 latency of ≤ 2 seconds.

## Data Migration Strategy

This is a greenfield AI backend implementation; there is no data migration in the traditional sense. However, initial catalog enrichment constitutes a bulk data processing operation equivalent to a migration.

- **Approach:** Phased bulk enrichment — the full existing Firebase catalog is processed through the Classification pipeline in a controlled batch run during Phase 2 (Weeks 5–7), before the preference-learning model is trained, ensuring all catalog items have enrichment attributes before the recommendation engine goes live.
- **Validation:** A random 10% sample of enriched catalog items is reviewed against a human-labeled holdout set to validate that the NLP classifier achieves the ≥ 90% accuracy target before bulk enrichment of the full catalog is executed.
- **Rollback:** If bulk enrichment produces classification outputs that fail accuracy validation, the Step Functions batch execution is halted. DynamoDB Point-in-Time Recovery (PITR) ensures the pre-enrichment catalog state can be restored to any second within the previous 35 days.
- **Cutover:** New catalog items are enriched at ingest time via the EventBridge trigger from the moment the Catalog Enrichment Service is deployed (Week 7–8 per the SOW schedule).

## Data Governance

The following governance policies apply to all data stored and processed within the ANP Streaming AI Recommendation Engine.

- **Classification:** Data is classified into three tiers — Reference (Mood Taxonomy: low sensitivity, immutable once approved), Catalog (ContentItem enrichment data: medium sensitivity, business asset), and User (UserProfile, InteractionEvents, SessionContext: high sensitivity, subject to user privacy protections).
- **Retention:** User preference vectors are retained indefinitely as a core business asset. InteractionEvents are retained for 2 years to support long-term retraining data accumulation. Raw audio files are retained indefinitely as the source of truth for reprocessing. CloudWatch logs are retained for 90 days. ElastiCache session and playlist entries expire via TTL (10 minutes for playlists, 30 minutes for session context).
- **Quality:** Catalog enrichment quality is validated against the mood taxonomy accuracy threshold (≥ 90% classifier agreement) at Phase 2 close. Ongoing quality is monitored through CloudWatch custom metrics tracking classifier confidence score distributions; alerts fire when average confidence drops below 0.75.
- **Access:** Data access follows the IAM least-privilege model defined in Section 5. User preference vector records are accessible only to the Lambda function serving the requesting user's own session — cross-user data access is prohibited by the DynamoDB IAM condition keys applied to the UserProfile table execution roles.

---

# Integration Design

The ANP Streaming AI Recommendation Engine is designed with a single primary integration point: the REST API consumed by the FlutterFlow mobile application. This API-first integration philosophy ensures the AI backend is completely decoupled from the frontend — FlutterFlow consumes AI capabilities as a downstream API consumer and has no direct dependency on any AWS ML service, data store, or pipeline component. A secondary integration with the Firebase REST API provides read-only access to the existing catalog schema during the engagement period.

## External System Integrations

The following table describes all external system integrations in scope for this engagement.

<!-- TABLE_CONFIG: widths=[18, 15, 15, 15, 22, 15] -->
| System | Type | Protocol | Format | Error Handling | SLA |
|--------|------|----------|--------|----------------|-----|
| FlutterFlow Mobile App | Real-time | HTTPS/REST | JSON | API Gateway 4xx/5xx responses; Lambda retry on transient errors | ≤ 2 seconds p95 |
| Firebase REST API | Batch/On-demand | HTTPS/REST | JSON | Lambda retry with exponential backoff (3 attempts); Step Functions error handling | Best-effort (not on critical path) |
| Amazon Bedrock | Real-time | AWS SDK | JSON | Lambda retry on throttle; Step Functions fallback to Comprehend-only path | AWS-managed SLA |
| Amazon Personalize | Real-time | AWS SDK | JSON | Lambda retry on throttle; cold-start fallback to mood-only matching | AWS-managed SLA |
| Amazon Comprehend | Batch/Real-time | AWS SDK | JSON | Step Functions retry with jitter; DLQ for failed classification events | AWS-managed SLA |

## API Design

The API Service Layer exposes five REST endpoints through Amazon API Gateway (regional deployment, us-east-1). All endpoints use the `/api/v1/` URL prefix for versioning. All requests must include a valid Cognito JWT Bearer token in the `Authorization` header. All response bodies are JSON. Request and response schemas are formally documented in the API contract documentation (SOW Deliverable 20 — OpenAPI/Swagger format).

- **Style:** REST (JSON)
- **Versioning:** URL path prefix (`/api/v1/`) — new breaking versions increment to `/api/v2/` without deprecating v1
- **Authentication:** Cognito JWT Bearer token validated by a Lambda authorizer on every request
- **Rate Limiting:** API Gateway usage plan — 100 requests/second per API key at the 100 MAU tier; configurable per growth tier
- **Content-Type:** `application/json` for all request and response bodies
- **Error Format:** Standard HTTP status codes (400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 429 Too Many Requests, 500 Internal Server Error) with a JSON body: `{"error": "<code>", "message": "<detail>", "request_id": "<api-gateway-request-id>"}`

### API Endpoints

The following table defines the five REST API endpoints delivered in Phase 4 (SOW Deliverable 21). All endpoints require a valid Cognito JWT Bearer token unless indicated otherwise.

<!-- TABLE_CONFIG: widths=[10, 35, 20, 35] -->
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET / POST | `/api/v1/users/{user_id}/profile` | Bearer (Listener/Admin) | Retrieve or create user profile and session state. GET returns current preference vector and mood history; POST initializes a new user profile on first login. |
| POST | `/api/v1/content/classify` | Bearer (Artist/Admin) | Submit a catalog item (lyric text or transcript content + audio S3 key) for emotion/mood/theme classification. Returns enrichment attributes asynchronously via Step Functions execution ARN. |
| POST | `/api/v1/playlists` | Bearer (Listener) | Generate a personalized playlist. Request body: `{"user_id": "...", "mood_input": "...", "count": 20}`. Returns an ordered list of track/podcast item IDs with enrichment metadata. |
| POST | `/api/v1/interactions` | Bearer (Listener) | Capture a feedback event (play, skip, like, dislike). Request body: `{"user_id": "...", "item_id": "...", "event_type": "...", "session_id": "..."}`. Events are queued to SQS and processed asynchronously into the preference-learning loop. |
| GET | `/api/v1/health` | API Key (internal monitoring) | Health check endpoint returning HTTP 200 with service status for CloudWatch canary monitoring. Not exposed to FlutterFlow; used by operational monitoring only. |

## Authentication & SSO Flows

The following describes the authentication flows for the two consumer types that interact with the API Service Layer.

**FlutterFlow User Authentication Flow:** The FlutterFlow application uses Amazon Cognito's hosted UI or the Amplify SDK to authenticate users against the Cognito User Pool. Upon successful authentication, Cognito issues a short-lived JWT access token (default 1-hour expiry) and a refresh token (30-day expiry). The FlutterFlow application includes the JWT access token as a Bearer token in the `Authorization` header of all API Gateway requests. The Lambda authorizer validates the token signature against the Cognito User Pool's public keys, checks the `exp` claim for expiry, and verifies the `cognito:groups` claim to determine the caller's role. Expired tokens cause the authorizer to return HTTP 401; the FlutterFlow application handles token refresh silently using the refresh token.

**Service-to-Service Authentication:** All Lambda-to-AWS-service calls (Lambda to DynamoDB, Lambda to SageMaker, Lambda to Personalize, Lambda to S3) use IAM role-based authentication via the Lambda execution role. No service-to-service JWT or API key exchange is required within the AWS account. Lambda-to-Firebase calls use Firebase REST API credentials retrieved from Secrets Manager at runtime.

## Messaging & Event Patterns

The following event-driven patterns are used throughout the platform to decouple pipeline stages and ensure no data loss under load.

- **Catalog Upload Event (Amazon EventBridge):** When an artist uploads new catalog content, the Firebase-side application sends a notification (or a polling Lambda detects the new item via Firebase REST API), which triggers an EventBridge custom event on the `anp-streaming.catalog.upload` event bus. The Catalog Enrichment Lambda is the sole subscriber of this event pattern.
- **Feedback Capture Queue (Amazon SQS):** Feedback events captured by the `/api/v1/interactions` endpoint are written to an SQS standard queue before being processed by the Preference Update Lambda. SQS decouples the API response (fast acknowledgement) from the preference vector update (asynchronous, can tolerate seconds of delay). The SQS queue has a 4-day message retention period and a 1-minute visibility timeout. The DLQ captures messages that fail processing after 3 attempts.
- **Retraining Trigger (Amazon EventBridge Scheduler):** The SageMaker Pipelines retraining workflow is triggered on a weekly schedule via an EventBridge Scheduler rule targeting the SageMaker Pipelines execution API.
- **Dead Letter Queue (SQS DLQ):** Failed feedback-capture events are routed to a dedicated SQS DLQ. A CloudWatch alarm fires when the DLQ message count exceeds 10, triggering an SNS alert to the ANP operations team for investigation.
- **Retry Policy:** All Lambda functions that invoke downstream services implement exponential backoff with jitter: initial delay 100ms, multiplier 2x, max delay 5 seconds, max 3 retries. Step Functions state machines implement retries with `IntervalSeconds: 2`, `MaxAttempts: 3`, and `BackoffRate: 2` on all service integration states.

---

# Infrastructure & Operations

The ANP Streaming AI Recommendation Engine infrastructure is designed as a fully managed, serverless-first AWS deployment that eliminates provisioned server administration while providing the observability, availability, and disaster recovery characteristics required for a production-grade AI/ML platform. Two environments — Dev and Staging — are provisioned as identical infrastructure stacks in us-east-1 through AWS CDK/CloudFormation, ensuring that what is tested in Staging is exactly what will be deployed to production by the ANP team post-engagement.

## Network Design

The solution VPC is deployed in us-east-1 with the following subnet structure, designed to isolate ML inference endpoints, database clusters, and cache nodes from the public internet while maintaining Lambda function access to AWS managed services through VPC Gateway and Interface Endpoints.

- **VPC CIDR:** 10.10.0.0/16
- **Public Subnets:** 10.10.1.0/24 (us-east-1a), 10.10.2.0/24 (us-east-1b) — Used for NAT Gateway and VPC-internal ALB (if needed for future services); no ML or data components in public subnets
- **Private Subnets (Application):** 10.10.11.0/24 (us-east-1a), 10.10.12.0/24 (us-east-1b) — VPC-attached Lambda ENIs, SageMaker endpoint ENIs
- **Private Subnets (Data):** 10.10.21.0/24 (us-east-1a), 10.10.22.0/24 (us-east-1b) — OpenSearch Service nodes, ElastiCache Redis cluster nodes
- **VPC Gateway Endpoints:** S3 and DynamoDB Gateway Endpoints in private subnets — all Lambda-to-S3 and Lambda-to-DynamoDB traffic stays within the AWS network without traversing the public internet or NAT Gateway
- **VPC Interface Endpoints:** SageMaker Runtime, Secrets Manager, SQS, and Step Functions Interface Endpoints in private subnets — all internal AWS API calls use private endpoint connections

## Compute Sizing

The following table defines the compute sizing for all provisioned components in the Dev and Staging environments. Lambda functions have no pre-provisioned sizing; they scale automatically from 0 to the concurrency limit.

<!-- TABLE_CONFIG: widths=[25, 20, 20, 20, 15] -->
| Component | Instance Type | vCPU | Memory | Count |
|-----------|---------------|------|--------|-------|
| SageMaker NLP Classifier Endpoint | ml.t3.medium | 2 | 4 GB | 1 per env |
| SageMaker Audio Feature Extractor | ml.t3.medium | 2 | 4 GB | 1 per env |
| SageMaker Retraining Jobs | ml.m5.xlarge | 4 | 16 GB | On-demand (20 hrs/mo) |
| Amazon Personalize Campaign | Managed (TPS-based) | N/A | N/A | 1 per env |
| OpenSearch Service Node | t3.small.search | 2 | 2 GB | 1 (single-AZ dev/staging) |
| ElastiCache Redis Node | cache.t3.micro | 2 | 0.5 GB | 1 per env |
| Lambda — Catalog Enrichment | N/A (serverless) | N/A | 512 MB | Auto-scaling |
| Lambda — Playlist Generation | N/A (serverless) | N/A | 1,024 MB | Auto-scaling |
| Lambda — API Authorizer | N/A (serverless) | N/A | 256 MB | Auto-scaling |
| Lambda — Feedback Capture | N/A (serverless) | N/A | 256 MB | Auto-scaling |
| Lambda — Preference Update | N/A (serverless) | N/A | 512 MB | Auto-scaling |

## High Availability Design

The solution is designed for 99.5% availability at the 100 MAU scale tier, leveraging the inherent multi-AZ resilience of AWS managed services rather than custom HA configurations.

- **Lambda:** Automatically executes across multiple Availability Zones; no single-AZ failure can disrupt Lambda execution.
- **DynamoDB:** Multi-AZ by default for all standard DynamoDB tables; Point-in-Time Recovery (PITR) provides continuous backup.
- **API Gateway:** Regional deployment with built-in multi-AZ load balancing; no customer-managed HA configuration required.
- **Amazon Personalize:** Multi-AZ managed service; SLA maintained by AWS.
- **SageMaker Endpoints:** Single instance at 100 MAU tier. A CloudWatch alarm triggers SNS notification if the endpoint enters `InService: False` state; auto-scaling is configured with a minimum instance count of 1 and a scale-up trigger at 70% invocations per second utilization. At 10K MAU, scale to 2 instances minimum.
- **OpenSearch Service:** Single-node at small tier (dev/staging); upgrade to 2-node multi-AZ cluster recommended before production deployment at > 1,000 catalog items.
- **ElastiCache Redis:** Single node at small tier; playlist cache is non-critical (miss triggers regeneration from DynamoDB + Personalize). Upgrade to Redis Cluster with replica at production.
- **Failover Strategy:** SageMaker endpoint failures fail over to a degraded playlist mode: the Playlist Lambda returns a mood-matched playlist using only the DynamoDB emotion vector search (no Personalize scoring) within the 2-second SLA.

## Disaster Recovery

The disaster recovery design for the ANP Streaming AI Recommendation Engine prioritizes data protection and rapid service restoration over multi-region failover, consistent with the 99.5% availability target and the 100 MAU scale tier.

- **RPO:** 1 hour — supported by DynamoDB PITR continuous backup (recovery to any second within the previous 35 days) and S3 versioning (all object versions retained indefinitely unless deleted by lifecycle policy).
- **RTO:** 4 hours — full service restoration from a DynamoDB PITR restore. Tested in the Staging environment in Phase 5 per the SOW DR testing plan.
- **Backup Strategy:** DynamoDB PITR enabled on all tables (ContentItem, UserProfile, InteractionEvents, MoodTaxonomy). S3 versioning enabled on all buckets. SageMaker model artifacts versioned through the SageMaker Model Registry with the previous 3 model versions retained as rollback targets.
- **DR Site:** Single-region deployment; no cross-region DR for this engagement phase. Cross-region replication to us-west-2 is recommended as a future phase enhancement at the 10K+ MAU scale tier.
- **Model Rollback:** SageMaker endpoint model rollback to the previous approved version completes within 10 minutes via SageMaker Model Registry. This is the primary DR action for a degraded model deployment.

## Monitoring & Alerting

Comprehensive observability is built into the platform from day one. All CloudWatch dashboards, alarms, and SNS notification targets are provisioned through CDK/CloudFormation as part of the standard environment stack and are included in the operational runbook package delivered at engagement close.

- **Infrastructure Monitoring:** EC2/Lambda concurrency, DynamoDB consumed read/write capacity units, SageMaker endpoint invocations per second and error rate, ElastiCache cache hit ratio, OpenSearch cluster health and JVM memory pressure.
- **Application Monitoring:** API Gateway p50/p95/p99 latency and 4xx/5xx error rates, Lambda duration and error rates per function, Step Functions execution success/failure rates, SQS queue depth and approximate age of oldest message.
- **Business KPIs:** Catalog items enriched per day (tracks growth of classification pipeline throughput), playlist generation requests per hour (tracks user engagement growth), mood input distribution (tracks which emotional states drive usage), feedback event volume per day (tracks preference-learning data accumulation rate).
- **Alerting Integration:** All CloudWatch Alarms route to an SNS topic that fans out to email notifications to the ANP Technical Lead and an optional PagerDuty/Slack integration (webhook URL configured in Secrets Manager).

### Alert Definitions

The following table defines the critical CloudWatch Alarms deployed with the platform. All alarms use a 1-minute evaluation period with 2 consecutive data points required to trigger.

<!-- TABLE_CONFIG: widths=[28, 28, 18, 26] -->
| Alert | Condition | Severity | Response |
|-------|-----------|----------|----------|
| Playlist API High Latency | API Gateway p95 latency > 3,000ms (15 min sustained) | High | Check ElastiCache hit ratio; investigate SageMaker endpoint latency; check Personalize campaign TPS |
| SageMaker Endpoint Error Rate High | SageMaker `ModelError` > 5% over 5 minutes | Critical | Trigger model rollback to previous version; notify ANP Technical Lead |
| API Gateway 5xx Error Rate | 5xx error rate > 1% over 5 minutes | Critical | Check Lambda function errors in CloudWatch Logs; escalate to nClouds during hypercare |
| SQS Feedback DLQ Messages | DLQ message count > 10 | High | Investigate Lambda Preference Update function errors; replay DLQ messages after fix |
| DynamoDB Throttled Requests | ThrottledRequests > 0 for 5 consecutive minutes | High | DynamoDB on-demand should auto-scale; investigate burst pattern and consider capacity mode review |
| SageMaker Endpoint Not In Service | Endpoint status ≠ InService for > 2 minutes | Critical | Trigger endpoint restart via runbook; failover to degraded playlist mode |
| GuardDuty High/Critical Finding | GuardDuty finding severity ≥ HIGH | Critical | Notify ANP security team immediately; initiate security incident runbook |
| Retraining Pipeline Failure | SageMaker Pipelines execution status = Failed | Medium | Review pipeline execution logs; check training data quality; retry manually per runbook |

## Logging & Observability

The following observability stack provides structured log aggregation, distributed tracing, and operational dashboards for all platform components.

- **Log Aggregation:** All Lambda, Step Functions, SageMaker, and API Gateway logs flow to Amazon CloudWatch Logs, organized into log groups by service and environment (`/aws/lambda/anp-{env}-{function-name}`, `/aws/apigateway/anp-{env}-api-access`, `/aws/sagemaker/anp-{env}-{endpoint-name}`). Log group retention is set to 90 days.
- **Structured Logging:** All Lambda functions emit JSON-structured log events with standard fields: `timestamp`, `request_id`, `function_name`, `environment`, `user_id` (where applicable), `latency_ms`, `status_code`, and `error` (where applicable). This enables CloudWatch Logs Insights queries across all functions without log parsing.
- **Tracing:** AWS X-Ray active tracing is enabled on all Lambda functions and API Gateway stages. X-Ray service maps provide end-to-end latency visualization from FlutterFlow API request to DynamoDB read response, enabling rapid root-cause analysis of latency regressions.
- **Dashboards:** Three CloudWatch dashboards are provisioned with the platform: (1) **API Health Dashboard** — API Gateway latency, error rate, and request volume; (2) **ML Pipeline Dashboard** — SageMaker endpoint invocations, error rate, and classification throughput; (3) **Business Metrics Dashboard** — playlist generation volume, feedback event rate, and MAU growth proxy metrics.

## Cost Model

The following cost model is based on the infrastructure-costs.csv analysis for the 100 MAU (small) scale tier. This is the Year 1 baseline; Phase 1 Deliverable 7 provides the full 3-year tiered model across 100, 10K, and 100K MAU scenarios.

<!-- TABLE_CONFIG: widths=[30, 25, 25, 20] -->
| Category | Monthly Estimate | Optimization | Notes |
|----------|------------------|--------------|-------|
| Amazon Bedrock (FM Inference) | $50/month | On-demand token pricing; no provisioned throughput at 100 MAU | Primary cost driver at small scale; scales with catalog enrichment volume |
| Amazon SageMaker Endpoint | $40/month | ml.t3.medium; scale down to 0 instances on schedule during off-hours in Dev | Single endpoint instance sufficient for < 100 MAU inference volume |
| Amazon CloudWatch | $30/month | Tune log retention to 90 days; use structured logging to reduce log volume | Logs ingestion and custom metrics; dashboard and alarm costs included |
| Amazon DynamoDB | $25/month | On-demand mode; no reserved capacity at 100 MAU | Scales automatically; cost grows linearly with read/write volume |
| Amazon OpenSearch Service | $25/month | t3.small.search single node; disable for off-hours in Dev | Single-node sufficient for < 5,000 catalog items |
| Amazon S3 | $12/month | Lifecycle policies: IA after 90 days, Glacier after 365 days | 500 GB catalog + transcript + model artifact storage |
| SageMaker Training Jobs | $5/month | Spot instances for training to reduce cost by ~70% at larger data volumes | ~20 hours/month of ml.m5.xlarge training at $0.23/hr |
| Amazon ECR | $10/month | Lifecycle policy: retain latest 5 image versions | Container registry for Lambda images and SageMaker containers |
| API Gateway + Lambda | $10/month | Lambda ARM64 architecture reduces cost by ~20%; API Gateway caching at higher tiers | < 100K API calls/month at 100 MAU |
| AWS Step Functions | $5/month | Standard workflows; low state-transition volume at small scale | Catalog enrichment orchestration |
| Amazon Cognito | $0.50/month | First 50K MAU free tier applies | 100 MAU at $0.0055/MAU |
| AWS Secrets Manager | $2/month | ~5 secrets at $0.40/secret/month | Firebase credentials, API keys |
| **Total Cloud Services** | **~$214/month ($2,563/year)** | AWS Activate credit ($2,500) reduces Year 1 net to ~$63 | 100 MAU scenario |
| AWS Business Support | $100/month ($1,200/year) | Flat rate; required for production workloads | 24x7 support with 1-hour critical response |

---

# Implementation Approach

The implementation approach for the ANP Streaming AI Recommendation Engine follows a phased, sequential delivery model aligned directly to the five phases defined in the SOW. Each phase builds on the previous, progressing from architectural foundation through content intelligence, recommendation engine, API service layer, and finally integration validation and handover. This sequencing minimizes critical-path risk by delivering tangible, testable capability at each phase milestone before proceeding to the next.

## Migration/Deployment Strategy

The ANP Streaming AI Recommendation Engine is a greenfield build; there is no existing system to migrate. The deployment strategy is therefore focused on controlled incremental buildout with full IaC-driven environment management.

- **Approach:** Greenfield build with phased capability delivery — each phase delivers independently testable components that are validated before the next phase begins.
- **Pattern:** All infrastructure is managed through AWS CDK/CloudFormation with a CDK Pipeline (AWS CodePipeline) handling promotion from Dev to Staging. No manual console changes are permitted in Staging or beyond.
- **Validation:** Each phase concludes with a formal deliverable acceptance review with the ANP Technical Lead. No downstream phase commences until the upstream phase deliverable is accepted within 3 business days of delivery.
- **Rollback:** Infrastructure rollback uses CloudFormation stack rollback capability. Lambda function rollback uses Lambda Aliases pointing to the previous published version. SageMaker model rollback uses the SageMaker Model Registry previous approved version.

## Sequencing & Wave Planning

The following table defines the five delivery phases, their primary activities, duration, and exit criteria, aligned to the SOW milestone schedule.

<!-- TABLE_CONFIG: widths=[12, 35, 15, 38] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| Phase 1 | Project kickoff; requirements workshop; current-state assessment (Firebase/FlutterFlow); AWS architecture design; mood taxonomy definition (≥ 10 labels); data schema package; tiered cost model (100/10K/100K MAU); risk register | Weeks 1–4 | Phase 1 Documentation Package (Deliverable 9) accepted by ANP; AWS account credentials provided; mood taxonomy approved by Lilly Goyah |
| Phase 2 | Lyric/transcript NLP classifier training and SageMaker deployment; audio feature extraction pipeline; catalog enrichment Lambda and Step Functions workflow; EventBridge trigger; bulk enrichment of existing catalog; internal classification endpoint testing | Weeks 3–8 | Content Intelligence Pipeline (Deliverable 14) deployed and tested in Dev; ≥ 90% classifier accuracy validated against holdout set; catalog enrichment time < 60 seconds per item |
| Phase 3 | DynamoDB user preference vector schema and ingestion paths; Amazon Personalize dataset group and campaign training; mood-to-content matching algorithm; playlist generation Lambda; SageMaker Pipelines retraining workflow; cold-start fallback strategy | Weeks 6–11 | Recommendation Engine (Deliverable 19) deployed and tested in Dev; playlist generation returns ranked results; retraining pipeline executes successfully in Staging |
| Phase 4 | REST API contract documentation; API Gateway configuration; Lambda authorizers; Cognito user pool; WAF rules; five endpoint implementations; feedback capture (SQS + EventBridge); Secrets Manager integration; API security hardening | Weeks 9–12 | API Service Layer (Deliverable 21) deployed with all five endpoints functional, secured, and documented; no HIGH/CRITICAL security findings in Security Hub |
| Phase 5 | End-to-end validation against FlutterFlow call patterns; performance and load testing (100/10K MAU); DR testing (PITR restore, model rollback); operational runbooks; Knowledge Transfer Sessions 1 and 2; final deliverable package compilation; project closeout | Weeks 11–13 | All functional tests pass; ≤ 2s playlist latency at 100 MAU load confirmed; both KT sessions completed; Final Deliverable Package (Deliverable 27) accepted by Lilly Goyah |

## Tooling & Automation

The following table defines the primary tooling used across all phases of the engagement, organized by functional category and aligned to the SOW Tooling Overview.

<!-- TABLE_CONFIG: widths=[28, 32, 40] -->
| Category | Tool | Purpose |
|----------|------|---------|
| Infrastructure as Code | AWS CDK (Python) + AWS CloudFormation | All AWS resource provisioning for Dev and Staging environments; stack-level rollback capability |
| CI/CD Pipeline | AWS CodePipeline + AWS CodeBuild | Automated build, test, and deployment of Lambda functions, model updates, and CDK stack changes from source repository |
| ML Training & Serving | Amazon SageMaker + SageMaker Pipelines + SageMaker Model Registry | NLP classifier and audio model training; real-time inference endpoints; automated retraining orchestration; versioned model promotion |
| Foundation Model Inference | Amazon Bedrock (Titan/Claude) | On-demand lyric and transcript emotion enrichment where NLP classifier confidence is below threshold |
| NLP & Text Analysis | Amazon Comprehend | Entity, sentiment, and key-phrase extraction as pre-processing step for the SageMaker NLP classifier |
| Recommendation | Amazon Personalize | Collaborative-filtering preference model training, campaign hosting, and event tracker for interaction data ingestion |
| API Testing | Postman + AWS Artillery | API contract validation (Postman); performance and load testing at 100 MAU and 10K MAU profiles (Artillery) |
| Secret Management | AWS Secrets Manager | Firebase credentials, API keys, and connection strings with 90-day auto-rotation |
| Container Registry | Amazon ECR | Lambda container images and SageMaker custom inference container storage |
| Monitoring | Amazon CloudWatch + AWS X-Ray + AWS CloudTrail | Log aggregation, custom metrics, dashboards, alarms, distributed tracing, and immutable API audit trail |
| Source Control | Git (customer-provided repository) | Version control for all CDK infrastructure code, Lambda function code, and ML pipeline definitions |

## Cutover Approach

Production deployment is explicitly out of scope for this engagement. The following approach is provided for ANP Streaming's reference when executing production promotion post-engagement.

- **Type:** Phased production promotion using the CDK pipeline delivering from Staging artifacts
- **Duration:** Estimated 1-day execution window for initial production promotion
- **Validation:** Smoke test of all five API endpoints from FlutterFlow in the production environment before announcing general availability
- **Decision Point:** Go/no-go criteria — all five endpoints return expected responses, CloudWatch alarms are in OK state, GuardDuty shows no active findings, and SageMaker endpoints are InService

## Downtime Expectations

Since this is a greenfield deployment with no existing users on the new AWS API backend, there is no user-facing downtime risk during the engagement delivery period.

- **Planned Downtime:** Zero expected during the engagement (greenfield build; no production traffic on the new AI backend during delivery)
- **Unplanned Downtime:** MTTR target of 4 hours for a full DynamoDB restore scenario; < 30 minutes for Lambda or model rollback scenarios (per DR test targets in Phase 5)
- **Mitigation:** All SageMaker endpoint updates use blue-green deployment via SageMaker Model Registry promotion, eliminating cold-replacement downtime. Lambda Aliases enable instant traffic cutover to previous versions.

## Rollback Strategy

The following rollback procedures are tested in the Staging environment during Phase 5 and documented in the operational runbooks delivered at engagement close.

- **Infrastructure Rollback:** CloudFormation stack rollback to the previous successful deployment state. CDK pipeline rollback completed in < 15 minutes for Lambda and API Gateway configuration changes.
- **Application Rollback:** Lambda Aliases point to the current stable version. Rolling back to the previous Lambda version requires updating the Alias target — executable in < 5 minutes through the AWS console or CLI.
- **Model Rollback:** SageMaker Model Registry maintains the previous 3 approved model versions. Rolling back an endpoint to the previous model version requires updating the endpoint configuration to reference the previous model package — executable in < 10 minutes.
- **Database Rollback:** DynamoDB PITR restore to any second within the previous 35 days. Full table restore completes within 1 hour for the expected data volumes at 100 MAU. Partial item-level recovery is possible via DynamoDB Export to S3 + selective re-import for smaller rollback scenarios.
- **Maximum Rollback Window:** 30 minutes for Lambda/model rollbacks; 2 hours for a full DynamoDB PITR restore.

---

# Appendices

The appendices contain supporting reference material including architecture diagram inventory, naming conventions, tagging standards, risk register, and glossary. This material is referenced throughout the document and provides the operational standards that the ANP team uses post-engagement for all new infrastructure provisioning and incident management.

## Architecture Diagrams

The following diagrams are produced during Phase 1 and delivered as part of the Phase 1 Architecture and Design Package (SOW Deliverable 4). All diagrams are maintained in the project delivery repository.

- **Solution Architecture Diagram** — End-to-end AWS architecture showing all five capability domains and data flows (included in Section 4 of this document)
- **Network Topology Diagram** — VPC subnet layout, security group boundaries, VPC endpoint placement, and traffic flow annotations
- **Data Flow Diagram** — Detailed sequence diagrams for the Content Enrichment Path, Playlist Generation Path, and Model Retraining Path
- **Security Architecture Diagram** — Authentication and authorization flow from FlutterFlow through Cognito, API Gateway WAF, Lambda Authorizer, and backend services

## Naming Conventions

The following naming conventions are applied to all AWS resources provisioned during this engagement. Consistent naming enables rapid resource identification, environment filtering, and cost allocation through resource tags.

<!-- TABLE_CONFIG: widths=[25, 40, 35] -->
| Resource Type | Pattern | Example |
|---------------|---------|---------|
| Lambda Function | `anp-{env}-{function-name}` | `anp-staging-playlist-generator` |
| DynamoDB Table | `anp-{env}-{table-name}` | `anp-dev-content-catalog` |
| S3 Bucket | `anp-{account-id}-{env}-{purpose}` | `anp-123456789-staging-raw-catalog` |
| SageMaker Endpoint | `anp-{env}-{model-name}-endpoint` | `anp-staging-nlp-classifier-endpoint` |
| SageMaker Model | `anp-{env}-{model-name}-{version}` | `anp-staging-preference-model-v3` |
| API Gateway | `anp-{env}-recommendation-api` | `anp-staging-recommendation-api` |
| Cognito User Pool | `anp-{env}-user-pool` | `anp-staging-user-pool` |
| CloudWatch Log Group | `/aws/lambda/anp-{env}-{function-name}` | `/aws/lambda/anp-staging-playlist-generator` |
| SQS Queue | `anp-{env}-{queue-purpose}` | `anp-staging-feedback-capture` |
| IAM Role | `anp-{env}-{component}-role` | `anp-staging-playlist-lambda-role` |
| KMS CMK Alias | `alias/anp-{env}-{data-tier}` | `alias/anp-staging-user-data` |
| VPC | `anp-{env}-vpc` | `anp-staging-vpc` |

## Tagging Standards

All AWS resources provisioned during this engagement are tagged with the following required tags. Tags are enforced through an AWS Config Rule that alerts on untagged resources.

<!-- TABLE_CONFIG: widths=[25, 15, 60] -->
| Tag | Required | Example Values |
|-----|----------|----------------|
| Environment | Yes | `dev`, `staging`, `production` |
| Application | Yes | `anp-recommendation-engine` |
| Owner | Yes | `nclouds-delivery`, `anp-technical-lead` |
| CostCenter | Yes | `OPP-2026-001` |
| ManagedBy | Yes | `cdk`, `manual` (manual tags are flagged for review) |
| DataClassification | Yes (data resources) | `catalog`, `user-data`, `model-artifacts`, `reference` |
| Phase | Yes (during delivery) | `phase-1`, `phase-2`, `phase-3`, `phase-4`, `phase-5` |

## Risk Register

The following risk register identifies the key risks to the ANP Streaming AI Recommendation Engine engagement, their likelihood and impact ratings, and the mitigation strategies in place. This register is reviewed and updated at each phase milestone review.

<!-- TABLE_CONFIG: widths=[28, 12, 14, 46] -->
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| AWS Partner Funding (APFP) approval delayed, causing project start delay | Medium | High | nClouds submits APFP application immediately upon SOW execution; billable work does not commence until approval is confirmed; timeline shifts correspondingly if approval is delayed |
| Lyric/transcript sample coverage insufficient for classifier training (< 50 items or poor label quality) | Medium | Critical | ANP provides minimum 50 representative samples in Week 1; nClouds flags data-sparsity risk immediately if sample set is insufficient and proposes synthetic data augmentation or pre-trained model fine-tuning as fallback |
| NLP classifier accuracy below ≥ 90% target on holdout evaluation | Medium | High | Pilot classification on 10% catalog sample before full run; Bedrock FM inference serves as a fallback enrichment path for items where classifier confidence is below 0.75; if accuracy target cannot be met, mood taxonomy is refined collaboratively with ANP before full training |
| Firebase REST API access not available or catalog schema incompatible with assumed structure | Low | High | Firebase access required in Week 1; incompatible schema detected during current-state assessment (Week 2); Phase 1 architecture review accommodates schema adaptation before pipeline development commences |
| Personalize cold-start degrades recommendation quality for first 30 days (insufficient interaction events) | High | Medium | Mood-to-content matcher provides content-based fallback recommendations for users with < 10 interactions; explicit mood input at session start provides strong personalization signal even without interaction history; Personalize minimum interactions threshold documented in operational runbook |
| SageMaker endpoint latency causes playlist API to exceed 2-second SLA | Medium | High | ElastiCache playlist caching reduces SageMaker invocations on repeated requests; load testing in Phase 5 validates p95 latency before engagement close; ml.t3.medium instance upsized to ml.m5.large if latency target is at risk |
| Scope creep: ANP requests additional AI/ML models or API endpoints beyond the 5 defined in the SOW | Medium | Medium | Formal change-request process defined in SOW Terms & Conditions; all scope changes require written approval from both Lilly Goyah and nClouds commercial sponsor before work begins; AWS funding may not cover additional scope |
| Model retraining produces degraded model quality, affecting live recommendations | Low | High | SageMaker Model Registry conditional promotion — new model is promoted to the production endpoint only if evaluation metrics exceed the previous model version on the holdout set; rollback to previous model version executable in < 10 minutes |
| ANP Technical Lead unavailable for deliverable reviews, causing downstream delays | Medium | Medium | SOW mandates 3-business-day review cycle; delays are documented in project status report; nClouds project manager escalates to Lilly Goyah (CEO) if review delays risk downstream phase start dates |
| AWS service API changes (Bedrock, Personalize, Comprehend) post-deployment | Low | Medium | Infrastructure-as-code and Lambda function versioning provide rollback capability; operational runbooks include service API change monitoring procedure; nClouds hypercare support covers issues traceable to AWS service changes within the 2-week hypercare window |

## Glossary

The following table defines the key terms and acronyms used throughout this document.

<!-- TABLE_CONFIG: widths=[25, 75] -->
| Term | Definition |
|------|------------|
| MAU | Monthly Active Users — the number of unique registered users who actively engage with the ANP Streaming platform within a calendar month |
| NLP | Natural Language Processing — a branch of AI that enables computers to understand, interpret, and generate human language; used in this project for lyric and transcript emotion classification |
| SageMaker | Amazon SageMaker — AWS fully managed ML platform for model training, deployment, and monitoring |
| Personalize | Amazon Personalize — AWS purpose-built recommendation service using collaborative-filtering and content-based ML models |
| Comprehend | Amazon Comprehend — AWS managed NLP service for entity recognition, sentiment analysis, and key-phrase extraction |
| Bedrock | Amazon Bedrock — AWS fully managed foundation model inference service providing access to Titan, Anthropic Claude, and other large language models |
| JWT | JSON Web Token — a compact, URL-safe token format used for authentication and authorization; issued by Amazon Cognito and validated by the API Gateway Lambda authorizer |
| PITR | Point-in-Time Recovery — a DynamoDB feature providing continuous backup and restoration to any second within the previous 35 days |
| CDK | AWS Cloud Development Kit — an open-source software development framework for defining cloud infrastructure using familiar programming languages (Python used in this project) |
| IaC | Infrastructure as Code — the practice of managing cloud infrastructure through code and version control rather than manual console operations |
| DLQ | Dead Letter Queue — an Amazon SQS queue that receives messages that fail processing after the maximum number of retry attempts, enabling investigation and replay |
| APFP | AWS Partner Funding Portal — the AWS program through which nClouds applied for $25,000 in partner funding covering 100% of the professional-services fee for this engagement |
| Mood Taxonomy | The canonical emotion/mood/thematic label set (≥ 10 labels) defined in Phase 1 that is the shared reference consumed by all classification pipeline components and the recommendation engine |
| Cold Start | The challenge of generating meaningful personalized recommendations for a new user or catalog item with no historical interaction data; addressed through the mood-to-content matcher fallback strategy |
| FlutterFlow | The low-code mobile application development platform used by ANP Streaming to build and maintain their iOS/Android streaming application; requires no frontend code changes to consume the delivered API |
| VPC | Virtual Private Cloud — an isolated AWS network environment in which ML inference endpoints, database clusters, and cache nodes are deployed to prevent direct public-internet access |
| WAF | Web Application Firewall — AWS WAF v2 attached to the API Gateway endpoint to inspect incoming requests for SQL injection, XSS, and known malicious IP patterns |
| TLS | Transport Layer Security — cryptographic protocol enforced at TLS 1.2 minimum for all communications within and into the ANP Streaming AI Recommendation Engine |
| CMK | Customer Managed Key — an AWS KMS encryption key created and managed by the customer (ANP Streaming), providing independent key rotation and access auditing for each data classification tier |
| CQRS | Command Query Responsibility Segregation — an architectural pattern separating write operations (catalog enrichment) from read operations (playlist generation and search) to enable independent scaling |
| RTO | Recovery Time Objective — the maximum acceptable time to restore a service after a failure event; set at 4 hours for this engagement |
| RPO | Recovery Point Objective — the maximum acceptable data loss window measured in time; set at 1 hour for this engagement, supported by DynamoDB PITR |
