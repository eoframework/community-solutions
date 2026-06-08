---
document_title: Statement of Work
technology_provider: aws
project_name: ANP Streaming AI Recommendation Engine
client_name: ANP Streaming
client_contact: KISHAN | CEO | lilly@anpstreaming.com
consulting_company: nClouds, Inc.
consultant_contact: Jonas Bull | Solutions Architect | jonas@nclouds.com
opportunity_no: OPP-2026-001
document_date: March 19, 2026
version: 1.0
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Statement of Work (SOW) defines the scope, deliverables, roles, timelines, and commercial terms for the design and delivery of an AI-powered recommendation and content-intelligence service for ANP Streaming by nClouds, Inc. This engagement will deliver a fully documented, API-accessible ML backend on Amazon Web Services (AWS), decoupled from the existing FlutterFlow mobile frontend, enabling ANP Streaming to offer personalized, emotion-based faith music discovery at scale. The solution is funded 100% on professional services through AWS Partner Funding, resulting in a net professional-services cost of $0.00 to ANP Streaming.

ANP Streaming is a faith-based music and podcasting platform serving the global Christian community — a market of over 2.4 billion people significantly underserved by Western-centric streaming services. This engagement builds the AI "brain" of the platform from scratch: a content-intelligence pipeline that classifies music and podcast content by emotion, mood, and thematic attributes; a preference-learning recommendation engine that personalizes playlists based on user mood input and listening history; and a secured REST API layer that integrates seamlessly with the existing FlutterFlow application without requiring any frontend changes.

**Project Duration:** Approximately 3 months (Effective Date: March 19, 2026)

**Key Outcomes:**
- Emotion and mood classification pipeline deployed on AWS, enriching all catalog entries at ingest time
- Preference-learning recommendation model trained and serving personalized playlists via API
- Mood-to-content matching algorithm bridging emotional state discovery with faith-based content
- Authenticated, documented REST API exposing all AI capabilities to the FlutterFlow application
- Tiered AWS cost projections across 100, 10,000, and 100,000 MAU scenarios for investor conversations
- Full operational runbooks, data schemas, API contracts, and two knowledge-transfer sessions delivered

**Expected Benefits:**
- Deliver a differentiated, emotion-based discovery experience that competitors cannot replicate with genre tagging alone
- Scale recommendation personalization from 100 to 100,000+ monthly active users without proportional headcount growth
- Reduce manual content-tagging effort to under 60 seconds per upload through automated classification at ingest
- Build a continuously improving preference engine that grows smarter as user interaction data accumulates
- Provide investor-ready cost modeling to support accelerator and funding conversations
- Achieve net-zero professional services cost through $25,000 in AWS Partner Funding applied at kickoff

---

# Background & Objectives

ANP Streaming is an early-stage, faith-based music and podcast streaming platform with a vision to serve the global Christian community — an audience exceeding 2.4 billion people that is poorly served by contemporary, Western worship-focused streaming services. The platform is currently delivered through a FlutterFlow mobile application backed by Firebase, with an existing catalog of music tracks and podcast episodes carrying basic metadata (titles, artists, existing tags, and lyric or transcript files where available). While ANP has a foundational mood-tagging schema in Firebase, there is no AI/ML backend today, and content discovery relies on manual genre tagging and static browsing patterns.

## Current State

ANP Streaming currently operates without any machine-learning-driven personalization or automated content classification. The following challenges summarize the key pain points that this engagement is designed to address:

- **Absence of AI/ML Infrastructure:** There is no recommendation engine, no content-intelligence pipeline, and no automated tagging or classification system. All content metadata is manually curated, which does not scale as the catalog grows.
- **Limited Discovery Experience:** Users cannot search or explore content by emotional state or worship preference. Discovery is constrained to static genre tags, which fails to capture the nuanced emotional and spiritual dimensions of faith-based music.
- **No Personalization:** Playlist generation is either manual or absent. Users receive no personalized recommendations based on listening history, mood input, or preference patterns, leading to generic experiences that limit engagement and retention.
- **Frontend-Backend Coupling Risk:** The platform is built entirely on Firebase and FlutterFlow. Any future platform migration or backend enhancement risks disrupting the frontend if the AI layer is tightly coupled to the current stack.
- **No Investor-Ready Cost Modeling:** ANP is engaged in accelerator and investor conversations but lacks quantitative AWS cost projections at different scale points (100, 10K, 100K MAU), which are critical for validating the business model.
- **Cold-Start Challenge:** New catalog entries and new users both face a cold-start problem — without historical interaction data, it is difficult to classify content accurately or generate meaningful personalized playlists from day one.

## Business Objectives

The following strategic objectives define the outcomes this project must achieve. Each objective is grounded in a specific business or technical gap identified in the current state assessment above.

- **Build a Decoupled AI Backend:** Design and deploy a standalone AI/ML service on AWS that is platform-agnostic, API-accessible, and survives future frontend migrations — ensuring the intelligence layer is a long-lived business asset, not a FlutterFlow dependency.
- **Automate Content Classification:** Enable automatic emotion, mood, and thematic classification of all music and podcast catalog entries at upload time using lyric, transcript, and audio analysis — dramatically reducing manual tagging effort and improving metadata quality.
- **Deliver Personalized Recommendations:** Generate personalized playlists from user mood inputs and listening history via an API-accessible recommendation engine, creating a compelling, differentiated discovery experience for ANP's global audience.
- **Enable Emotion-Based Discovery:** Build a mood-to-content matching capability that correlates emotional state with multi-attribute content vectors, enabling discovery that bridges mental wellbeing and personal faith in a way no genre tag can replicate.
- **Establish a Continuous Improvement Loop:** Implement a preference-learning pipeline with a model retraining cycle that grows smarter as user interaction data accumulates, ensuring recommendation quality improves over time.
- **Support Investor & Accelerator Narratives:** Produce tiered AWS cost projections across 100, 10,000, and 100,000 MAU growth scenarios to equip the ANP Streaming team with credible, data-driven cost modeling for fundraising conversations.

## Success Metrics

The following measurable criteria define success for this engagement. Each metric is specific and testable, and will be validated during Phase 5 Testing & Validation before engagement close.

- Catalog emotion/mood classification pipeline processes all existing catalog entries and new uploads at ingest time within the engagement period
- Content classifier achieves ≥90% agreement with human-labeled test set on emotion and mood attributes
- Playlist generation API responds within ≤2 seconds under simulated 100 MAU load
- Preference-learning model produces recommendations with measurable improvement after first retraining cycle
- All five REST API endpoints are functional, documented, and respond correctly to FlutterFlow-simulated call patterns
- Mood taxonomy defines ≥10 distinct emotion/mood labels with annotation guidelines and worship-style coverage
- Tiered cost model delivered covering all three MAU growth scenarios (100, 10K, 100K) in Phase 1
- Two knowledge-transfer sessions conducted with ANP technical team, confirmed by session attendance records
- Full deliverable package (architecture diagrams, data schemas, API contracts, runbooks) accepted by ANP within the engagement window

---

# Scope of Work

This engagement delivers a comprehensive AI/ML recommendation and content-intelligence backend for ANP Streaming on AWS. The following section defines what is in scope, what is explicitly excluded, and how the work is structured across five sequential phases.

## In Scope

The following services and deliverables are included in this SOW:

- AWS architecture design for the complete AI/ML recommendation and content-intelligence system
- Emotion, mood, and thematic classification pipeline for lyrics and podcast transcripts using Amazon Comprehend and SageMaker
- Audio-feature extraction pipeline for sonic characteristic analysis (valence, energy, worship style) beyond text-derived tags
- Catalog metadata-enrichment service triggered at artist and podcast upload time
- User preference-learning model using collaborative-filtering and content-based hybrid approaches on Amazon SageMaker
- Mood-to-content matching algorithm correlating emotional state with multi-attribute catalog content vectors
- Playlist-generation service incorporating preference weighting, session context, and feedback signals
- Automated model retraining pipeline using SageMaker Pipelines
- Secured REST API layer exposing five endpoints: user profile/session, content classification, playlist generation, and listening-history/feedback capture
- AWS Cognito-based authentication (JWT tokens) for API access from the existing FlutterFlow application
- Data schema definitions for user preference vectors, content metadata, and mood taxonomy
- Tiered AWS cost projections at 100, 10,000, and 100,000 MAU scenarios
- Operational runbooks, API contract documentation, and architecture documentation
- Two formal knowledge-transfer sessions for the ANP technical team
- Dev and Staging environment provisioning (production deployment deferred per client direction)

### Scope Parameters

This engagement is sized and priced based on the following parameters. Changes to these parameters may require scope adjustment and additional investment.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | Monthly Active Users (initial) | Starting from 0; cost modeled at 100, 10K, 100K MAU |
| Solution Scope | AI/ML Models Delivered | 5 components: NLP classifier, audio analyzer, preference model, mood-matcher, playlist generator |
| Content Catalog | Catalog Entries at Engagement Start | Existing Firebase-backed catalog with titles, metadata, lyric/transcript files where available |
| Integration | Downstream API Consumers | 1 — FlutterFlow mobile application (no frontend modification required) |
| Data Sources | Input Data Types | Lyric text files, podcast transcript files, Firebase catalog metadata |
| User Base | User Roles | 3 roles: listener, artist/uploader, admin |
| Data Volume | Audio Feature Storage | Up to 100 GB (S3 feature vectors and processed audio at small scale) |
| Technical Environment | AWS Environments | 2 environments: Dev and Staging (production deployment out of scope) |
| Technical Environment | Deployment Model | Serverless-first: Lambda, Step Functions, API Gateway, SageMaker endpoints |
| Security & Compliance | Authentication | Amazon Cognito user pool with JWT tokens; IAM roles and KMS encryption |
| Performance | Playlist API Response Time | ≤2 seconds under 100 MAU simulated load |
| Knowledge Transfer | Sessions Included | 2 formal knowledge-transfer sessions + full operational runbook package |

*Note: Changes to these parameters may require scope adjustment and additional investment.*

## Out of Scope

These items are not included in this engagement unless added via formal change control:

- Firebase data migration execution (catalog data is read via API, not migrated to AWS)
- Mobile frontend development or modifications to the FlutterFlow application
- Artist self-service upload portal or content management user interface
- Social features, journaling features, or community engagement functionality
- Production environment deployment and go-live cutover (deferred to a future phase)
- Listening-history storage and detailed interaction analytics (deferred to a later phase)
- Ongoing managed services, infrastructure management, or post-engagement support beyond hypercare
- Third-party data integrations (e.g., Spotify catalog, Apple Music, or external music databases)
- Custom hardware procurement or on-premises infrastructure
- Legal, privacy, or regulatory compliance advisory services (e.g., GDPR, CCPA formal audit)
- AWS account procurement or billing arrangement with Amazon (customer provides dedicated account)

## Activities

### Phase 1 – Discovery & Architecture Planning (Weeks 1–4)

Phase 1 establishes the strategic and technical foundation for the entire engagement. It begins with a formal requirements workshop, proceeds through AWS architecture design and data schema definition, and concludes with a tiered cost model covering all three MAU growth scenarios. The customer must provide a dedicated AWS account with admin credentials and make subject-matter experts available during this phase.

Key activities:
- Project kickoff meeting: stakeholder alignment, delivery cadence, and communication plan
- Requirements workshop with Lilly Goyah and SMEs covering mood taxonomy, content classification goals, recommendation requirements, and API contract objectives
- Current-state assessment of existing Firebase catalog schema, FlutterFlow call patterns, and lyric/transcript coverage
- AWS multi-service architecture design: SageMaker, Lambda, API Gateway, S3, DynamoDB, EventBridge, Cognito, Step Functions
- User preference vector schema, content metadata schema, and mood taxonomy (emotion, mood, worship-style labels and annotation guidelines)
- Tiered AWS cost modeling at 100, 10,000, and 100,000 MAU for investor and accelerator conversations
- Risk assessment covering data sparsity, cold-start risk, and AWS funding approval dependency
- Phase 1 documentation package for customer review and sign-off

**Deliverable:** Phase 1 Architecture and Design Package — AWS architecture diagrams, data schemas, mood taxonomy, tiered cost model, and risk register

### Phase 2 – Content Intelligence Development (Weeks 3–7)

Phase 2 builds the content-intelligence backbone: the pipeline that classifies every piece of music and podcast content by emotion, mood, and theme. It also performs audio-level analysis to extract sonic characteristics beyond what text analysis alone can provide, and deploys the catalog-enrichment service that applies these classifications at artist upload time.

Key activities:
- Finalize emotion, mood, and worship-style label set and annotation guidelines
- Build lyric and podcast transcript ingestion pipeline for NLP pre-processing
- Train and deploy NLP emotion/mood/theme classifier on Amazon SageMaker (fine-tuned base model)
- Build audio-feature extraction pipeline for valence, energy, and worship-style sonic analysis
- Develop catalog-enrichment Lambda triggered at artist/podcast upload time to write classification outputs to content metadata
- Expose internal classification endpoint for end-to-end pipeline testing
- Unit and integration testing of all Phase 2 components

**Deliverable:** Content Intelligence Pipeline — deployed NLP classifier, audio analysis pipeline, catalog enrichment service, and internal classification endpoint

### Phase 3 – Recommendation Engine Development (Weeks 6–10)

Phase 3 builds the personalization core: the preference-learning model, the mood-to-content matching algorithm, and the playlist generation service that ANP users will experience directly. This is the highest-complexity phase of the engagement, introducing cold-start handling for new users and a retraining pipeline that enables continuous improvement.

Key activities:
- Implement DynamoDB schema for user preference vectors and ingestion paths for mood inputs, genre selections, and interaction events
- Build and train collaborative-filtering/content-based hybrid preference-learning model on Amazon SageMaker
- Develop mood-to-content matching algorithm correlating emotional state with multi-attribute content vectors from Phase 2
- Build playlist-generation Lambda service incorporating preference weighting, session context, and feedback signals
- Implement SageMaker Pipelines-based model retraining pipeline for scheduled continuous improvement
- Cold-start strategy design for new users with no listening history
- Unit and integration testing of all Phase 3 components

**Deliverable:** Recommendation Engine — deployed preference-learning model, mood-to-content matcher, playlist generation service, and automated retraining pipeline

### Phase 4 – API Service Layer Development (Weeks 9–12)

Phase 4 exposes all AI capabilities built in Phases 2 and 3 through a secured, documented REST API that the FlutterFlow mobile application can call without any frontend modification. This phase also implements security hardening and the feedback-capture endpoint that feeds the preference-learning loop.

Key activities:
- Define and document all REST API contracts: user profile/session, content classification, playlist generation, and feedback capture endpoints
- Provision Amazon API Gateway, Lambda authorizers, IAM roles, and WAF rules for the secured public-facing API layer
- Implement authenticated user profile and session management endpoint with Amazon Cognito/JWT integration
- Expose secured content-classification endpoint callable at artist upload time
- Implement playlist-generation endpoint accepting mood and user context, returning an ordered track/podcast list
- Build feedback-capture endpoint (play/skip/like/dislike) feeding the preference-learning loop via EventBridge and SQS
- API security hardening: throttling, request validation, AWS Secrets Manager integration, and security review

**Deliverable:** API Service Layer — five documented REST API endpoints deployed with authentication, security controls, and API contract documentation

### Phase 5 – Integration & Handover (Weeks 11–13)

Phase 5 validates the complete end-to-end system against real FlutterFlow call patterns, produces all operational documentation, and formally transfers knowledge to the ANP technical team. This phase confirms the solution operates as a standalone, independently operable AWS service.

Key activities:
- End-to-end validation of the full pipeline: content upload → classification → catalog enrichment → mood input → playlist generation → feedback capture
- Validate all API endpoints against FlutterFlow-simulated call patterns with no frontend modification required
- Develop comprehensive operational runbooks covering all services: deployment, scaling, retraining, and incident response
- Conduct Knowledge Transfer Session 1: architecture overview, pipeline operations, and retraining procedure for the ANP engineering team
- Conduct Knowledge Transfer Session 2: API operations, security runbook, monitoring, and incident-response walkthrough
- Compile and deliver final deliverable package: architecture diagrams, data schemas, API contracts, and operational runbooks
- Project closeout: retrospective, lessons learned, AWS funding reconciliation, and final invoice preparation

**Deliverable:** Complete Handover Package — validated end-to-end system, operational runbooks, knowledge-transfer sessions, and final documentation package

---

# Deliverables & Timeline

This section enumerates all formal deliverables produced during the engagement, defines acceptance responsibilities, and summarizes the project milestone schedule. All customer reviews of deliverables are expected within three working days of delivery; delays in review may shift downstream milestone dates.

## Deliverables

The table below lists all 27 formal deliverables, their type, target delivery week, and the ANP stakeholder responsible for acceptance sign-off.

<!-- TABLE_CONFIG: widths=[5, 42, 12, 18, 23] -->
| # | Deliverable | Type | Due (Week) | Acceptance By |
|---|-------------|------|------------|---------------|
| 1 | Project Kickoff Meeting Minutes and Delivery Plan | Document | Week 1 | Lilly Goyah (CEO) |
| 2 | Requirements Workshop Summary and Decisions Log | Document | Week 2 | Lilly Goyah (CEO) |
| 3 | Current-State Assessment Report (Firebase/FlutterFlow) | Document | Week 2 | ANP Technical Lead |
| 4 | AWS Architecture Design — Diagrams and Decision Record | Document | Week 3 | ANP Technical Lead |
| 5 | Mood Taxonomy Definition — Emotion/Mood/Worship-Style Label Set with Annotation Guidelines | Document | Week 3 | Lilly Goyah (CEO) |
| 6 | Data Schema Package — User Preference Vectors, Content Metadata, Mood Taxonomy | Document | Week 4 | ANP Technical Lead |
| 7 | Tiered AWS Cost Model — 100 / 10K / 100K MAU Projections | Document | Week 4 | Lilly Goyah (CEO) |
| 8 | Risk Register | Document | Week 4 | Lilly Goyah (CEO) |
| 9 | Phase 1 Documentation Package (Deliverables 4–8 bundled) | Document | Week 4 | Lilly Goyah (CEO) |
| 10 | Lyric & Transcript Ingestion Pipeline (deployed, Dev environment) | System | Week 6 | ANP Technical Lead |
| 11 | NLP Emotion/Mood/Theme Classifier (deployed on SageMaker endpoint) | System | Week 7 | ANP Technical Lead |
| 12 | Audio Feature Extraction Pipeline (deployed, Dev environment) | System | Week 7 | ANP Technical Lead |
| 13 | Catalog Enrichment Service (deployed, triggered at upload time) | System | Week 8 | ANP Technical Lead |
| 14 | Internal Classification Endpoint (tested end-to-end) | System | Week 8 | ANP Technical Lead |
| 15 | User Preference Vector DynamoDB Schema and Ingestion Path | System | Week 9 | ANP Technical Lead |
| 16 | Preference-Learning Model (deployed on SageMaker endpoint) | System | Week 10 | ANP Technical Lead |
| 17 | Mood-to-Content Matching Algorithm (deployed) | System | Week 10 | ANP Technical Lead |
| 18 | Playlist Generation Service (Lambda, deployed) | System | Week 11 | ANP Technical Lead |
| 19 | Automated Model Retraining Pipeline (SageMaker Pipelines, deployed) | System | Week 11 | ANP Technical Lead |
| 20 | REST API Documentation — All Five Endpoint Contracts | Document | Week 11 | ANP Technical Lead |
| 21 | API Service Layer — API Gateway, Cognito Auth, Five Endpoints (deployed) | System | Week 12 | ANP Technical Lead |
| 22 | Performance & Load Test Report (100 / 10K MAU scenarios) | Document | Week 13 | Lilly Goyah (CEO) |
| 23 | End-to-End Validation Report (full pipeline + FlutterFlow call pattern test) | Document | Week 13 | Lilly Goyah (CEO) |
| 24 | Operational Runbooks — All Services (deployment, scaling, retraining, incident response) | Document | Week 13 | ANP Technical Lead |
| 25 | Knowledge Transfer Session 1 (Architecture, Pipelines, Retraining) | Training | Week 12 | Lilly Goyah (CEO) |
| 26 | Knowledge Transfer Session 2 (API Operations, Security, Monitoring, Incident Response) | Training | Week 13 | Lilly Goyah (CEO) |
| 27 | Final Deliverable Package (all documents, runbooks, schemas, API contracts compiled) | Document | Week 13 | Lilly Goyah (CEO) |

## Project Milestones

The milestones below mark the completion of each major project phase and critical decision points. All milestone dates are relative to the project effective date of March 19, 2026.

<!-- TABLE_CONFIG: widths=[22, 55, 23] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 — Project Kickoff | Project kickoff meeting completed; stakeholder alignment confirmed; AWS account access granted to nClouds | Week 1 |
| M2 — Architecture Approved | Phase 1 Documentation Package delivered, reviewed, and formally accepted by ANP | Week 4 |
| M3 — Content Intelligence Live | Content classification pipeline and catalog enrichment service deployed and tested in Dev | Week 8 |
| M4 — Recommendation Engine Live | Preference-learning model, mood-to-content matcher, and playlist generation service deployed and tested | Week 11 |
| M5 — API Layer Live | All five REST API endpoints deployed, secured, documented, and validated | Week 12 |
| M6 — End-to-End Validated | Full pipeline validated against FlutterFlow call patterns; performance test report accepted | Week 13 |
| M7 — Handover Complete | Both knowledge-transfer sessions conducted; final deliverable package accepted; project closed | Week 13 |

---

# Roles & Responsibilities

This engagement requires active participation from both the nClouds delivery team and ANP Streaming stakeholders throughout all five phases. Clear role definition and accountability assignment are essential to maintaining delivery velocity, resolving decisions quickly, and ensuring all deliverables meet acceptance criteria on schedule.

## RACI Matrix

The RACI matrix below defines accountability for every major task and activity in the engagement. Each row represents a distinct task or decision category; each column represents a role. Every task carries exactly one Accountable (A) party and one or more Responsible (R) parties.

<!-- TABLE_CONFIG: widths=[28, 10, 11, 10, 9, 11, 11, 10] -->
| Task / Activity | nClouds PM | nClouds Arch | nClouds Eng | nClouds QA | ANP CEO | ANP Tech Lead | ANP SME |
|----------------|------------|--------------|-------------|------------|---------|---------------|---------|
| Project Kickoff & Stakeholder Alignment | A/R | C | I | I | C | C | I |
| Requirements Workshop Facilitation | A | R | C | I | C | C | R |
| AWS Architecture Design & Review | I | A/R | C | I | I | C | I |
| Mood Taxonomy & Data Schema Definition | C | A | R | I | C | C | R |
| Tiered AWS Cost Modeling | C | A | R | I | C | I | I |
| Content Intelligence Pipeline Development | I | C | A/R | C | I | I | I |
| Audio Analysis Pipeline Development | I | C | A/R | C | I | I | I |
| Catalog Enrichment Service Development | I | C | A/R | C | I | I | I |
| Preference-Learning Model Development | I | A | R | C | I | I | I |
| Mood-to-Content Matching Algorithm | I | A | R | C | I | I | I |
| Playlist Generation Service Development | I | C | A/R | C | I | I | I |
| Model Retraining Pipeline Development | I | C | A/R | C | I | I | I |
| API Design & Contract Documentation | I | A/R | C | I | I | C | I |
| API Gateway, Auth & Security Implementation | I | C | A/R | C | I | C | I |
| REST API Endpoint Development | I | C | A/R | C | I | I | I |
| Functional & Integration Testing | C | C | C | A/R | I | C | I |
| Performance & Load Testing | C | C | C | A/R | I | C | I |
| End-to-End Validation | C | C | A/R | R | I | C | I |
| Operational Runbook Development | C | C | A/R | C | I | C | I |
| Knowledge Transfer Sessions | C | A/R | R | I | C | R | R |
| Deliverable Review & Acceptance | I | I | I | I | A | R | C |
| AWS Funding Portal Submission | A/R | C | I | I | C | I | I |
| Project Closeout & Invoice | A/R | I | I | I | C | I | I |

**Legend:** R = Responsible | A = Accountable | C = Consulted | I = Informed

## Key Personnel

**nClouds Delivery Team:**
- **Jonas Bull — Solution Architect / Pre-Sales Lead:** Primary technical author, responsible for overall architecture design, Phase 1 documentation package, and technical oversight across all phases
- **Solutions Engineers (2 FTE):** Responsible for pipeline development, API service layer implementation, and system integration across Phases 2–5
- **ML/AI Engineers (1–2 FTE):** Responsible for NLP classifier training, audio analysis pipeline, preference-learning model, and retraining pipeline
- **QA Engineer:** Responsible for functional, integration, performance, and end-to-end validation testing in Phase 5
- **Technical Writer:** Responsible for operational runbooks, API contract documentation, and final deliverable package compilation
- **Project Manager:** Responsible for schedule management, status reporting, stakeholder communication, and AWS funding coordination
- **Andrew Brewer — SVP of Sales (Commercial Sponsor):** Commercial oversight and escalation point for contract and funding matters

**ANP Streaming Client Team:**
- **Lilly Goyah — CEO (Executive Sponsor):** Primary decision authority for scope versus budget trade-offs; formal deliverable acceptance signatory; must attend requirements workshop, mid-point review, and final readout
- **ANP Technical Lead (Application/Workload Owner):** Primary technical point of contact for Firebase schema, FlutterFlow call patterns, and catalog data; must be available for all technical discovery sessions
- **Infrastructure Architect (Client SME):** Must be available for AWS account provisioning review and architecture design sessions
- **Network Architect (Client SME):** Must be available for API integration and connectivity review
- **Security Architect (Client SME):** Must be available for security design review and access-control decisions

---

# Architecture & Design

The ANP Streaming AI Recommendation Engine is designed as a fully serverless, platform-agnostic AWS-native service that exposes all AI capabilities through a secured REST API. This architecture philosophy ensures the intelligence layer survives any future frontend migration, operates independently of Firebase, and scales elastically from 100 to 100,000+ monthly active users without provisioned infrastructure changes at the lower tiers. The design prioritizes decoupling — the FlutterFlow application connects to the AI backend through API Gateway and never directly touches any ML model, pipeline, or data store.

The solution is built across five logical capability domains: Content Intelligence (classification pipeline), Catalog Enrichment (ingest-time metadata writing), Recommendation Engine (preference learning and playlist generation), API Service Layer (secure REST endpoints), and Operational Control Plane (monitoring, logging, retraining orchestration). These domains are orchestrated through AWS Step Functions and Amazon EventBridge, ensuring each capability can be independently developed, tested, and updated without cascading changes.

## Architecture Overview

The architecture diagram below illustrates the complete end-to-end data and control flow — from content upload and classification through preference learning and playlist generation to the secured API consumed by ANP's FlutterFlow application. The design is organized into clearly bounded service clusters that map directly to the five delivery phases.

![Figure 1: Solution Architecture Diagram](../../assets/diagrams/architecture-diagram.png)

**Figure 1: ANP Streaming AI Recommendation Engine — AWS Architecture** — End-to-end data flow from content ingestion and classification through preference-learning and playlist generation to the secured REST API consumed by the FlutterFlow mobile application.

## Component Architecture

The solution is composed of five primary service groups, each encapsulating a distinct AI/ML or data-processing capability.

**Content Intelligence Services:** Amazon Comprehend provides managed NLP inference for emotion and mood classification from lyric and transcript text. Amazon Transcribe handles audio-to-text transcription for podcast episodes where transcripts are not available. A custom SageMaker endpoint hosts the fine-tuned NLP classifier trained on ANP's labeled dataset, producing emotion, mood, and thematic attribute scores for each catalog entry. A second SageMaker endpoint handles audio feature extraction, computing valence, energy, and worship-style vectors from audio files stored in S3.

**Catalog Enrichment Service:** An AWS Lambda function triggered via Amazon EventBridge at artist and podcast upload time orchestrates the enrichment flow: it routes content to the text and audio classification endpoints, aggregates the classification outputs, and writes the enriched metadata back to the content catalog in Amazon DynamoDB. AWS Step Functions manages the multi-step enrichment workflow, ensuring reliable execution with retry logic and error handling.

**Recommendation Engine:** Amazon Personalize serves as the primary recommendation service, ingesting user preference vectors and interaction events to train and serve collaborative-filtering models. A custom SageMaker endpoint hosts the mood-to-content matching algorithm that correlates mood-state inputs with multi-attribute content vectors. The playlist generation Lambda assembles the final ordered playlist by combining Personalize output with mood-matching scores, session context (time of day, recently played), and explicit feedback signals (skip, like, dislike). SageMaker Pipelines orchestrates the weekly retraining cycle, pulling fresh interaction data from DynamoDB and retraining both the Personalize models and the mood matcher.

**API Service Layer:** Amazon API Gateway exposes the five public REST endpoints with request validation, rate throttling, and WAF protection. Amazon Cognito provides the user pool, JWT token issuance, and token validation for all authenticated calls from FlutterFlow. AWS Lambda functions handle individual endpoint business logic. AWS Secrets Manager stores Firebase credentials, API keys, and database connection strings. Amazon SQS queues feedback-capture events before they enter the preference-learning loop via EventBridge, ensuring no feedback data is lost under load.

**Data and Storage Layer:** Amazon DynamoDB holds user preference vectors, session context, mood taxonomy reference data, and content metadata (catalog items with enriched attribute scores). Amazon S3 stores raw audio files, lyric and transcript text, audio feature vectors, model training datasets, and SageMaker model artifacts. Amazon OpenSearch Service provides semantic and emotion-based search over the enriched catalog for the playlist generation and discovery use cases. Amazon ElastiCache (Redis) caches recently generated playlists and session state to reduce API latency.

## Network Design

The solution operates entirely within a single AWS region (us-east-1) using a VPC with private subnets for all SageMaker endpoint instances, OpenSearch nodes, and ElastiCache clusters. Lambda functions execute within the VPC via VPC-attached ENIs where they access private resources, and outside the VPC for direct DynamoDB and S3 API calls using VPC Gateway Endpoints to keep traffic off the public internet. Amazon API Gateway is deployed as a regional REST API; all inbound traffic arrives over HTTPS (TLS 1.2+). AWS WAF is attached to API Gateway to inspect requests before they reach Lambda authorizers. SageMaker inference endpoints are not exposed to the public internet — they are invoked only by internal Lambda functions via the AWS private network. All AWS-to-Firebase communication occurs over HTTPS to the Firebase REST API; no site-to-site VPN or Direct Connect is required for this engagement.

## Security Design

Authentication and authorization are enforced at the API Gateway layer using Amazon Cognito JWT tokens. All FlutterFlow requests must present a valid Cognito access token; Lambda authorizers validate the token before routing the request to the backend. IAM roles follow least-privilege principles: each Lambda function is assigned a dedicated execution role with only the permissions required for its specific task — no wildcard permissions on any AWS service.

Data in transit is encrypted using TLS 1.2 or higher for all API, S3, and DynamoDB communications. Data at rest is encrypted using AWS KMS-managed keys for S3 buckets, DynamoDB tables, and SageMaker model artifacts. AWS Secrets Manager stores all credentials and rotates them on a 90-day schedule. AWS WAF rules protect the API Gateway endpoint against SQL injection, XSS, and known malicious IP ranges via AWS Managed Rule Groups. Amazon CloudTrail records all API calls for auditability. Amazon GuardDuty monitors the AWS account for anomalous behavior and threat signals. Security controls are deployed into the customer's dedicated AWS account, coordinated with the existing or newly established security AWS account per the customer's account structure.

## Data Architecture

**Content Metadata Store:** Amazon DynamoDB holds the enriched content catalog. Each item record contains the original Firebase-sourced metadata fields (title, artist, tags) plus the AI-generated enrichment attributes (emotion score vector, mood label, thematic tags, audio feature vector components). DynamoDB on-demand capacity mode handles unpredictable ingest-time write bursts without manual provisioning.

**User Data Store:** A separate DynamoDB table holds user preference vectors. Each user record stores the latest preference state (weighted genre and mood preferences), interaction event counts, and the last-updated timestamp. This schema is designed for forward compatibility with the full listening-history analytics planned for a later engagement phase.

**Object Storage:** Amazon S3 organizes data across four prefixes: `/raw-catalog/` for source audio files; `/transcripts/` for lyric and podcast transcript text; `/features/` for computed audio feature vectors; and `/models/` for SageMaker training artifacts and model packages. S3 lifecycle policies transition objects to S3-IA after 90 days and S3 Glacier after 365 days to manage storage costs.

**Mood Taxonomy Reference Data:** The mood taxonomy label set and annotation guidelines are stored as a versioned JSON document in S3 and also loaded into a DynamoDB reference table consumed by both the classification pipeline and the mood-to-content matcher. This ensures all components reference the same canonical label set.

**Data Retention and Protection:** User preference vectors are retained indefinitely as a business asset. Raw audio files are retained as the source of truth for reprocessing. CloudWatch logs are retained for 90 days. DynamoDB Point-in-Time Recovery (PITR) is enabled on all tables providing up to 35 days of continuous backup. S3 versioning is enabled on all buckets to protect against accidental deletion. SageMaker model artifacts are versioned through the SageMaker Model Registry.

## Operational Design

**Observability:** Amazon CloudWatch provides centralized logging, custom metrics, dashboards, and alarms for all pipeline components, API endpoints, SageMaker endpoints, and Step Functions state machines. Custom metrics track classification throughput, playlist generation latency, recommendation model inference time, and feedback capture queue depth. CloudWatch Alarms trigger SNS notifications to the ANP technical team for endpoint errors, latency breaches, and retraining pipeline failures. API Gateway latency alarm threshold is set at 3 seconds (target ≤2 seconds); SageMaker endpoint error rate alarm threshold is 5%.

**Disaster Recovery:** The primary recovery objective is data protection rather than multi-region failover. RTO target is 4 hours for full service restoration from a DynamoDB PITR restore. RPO target is 1 hour, supported by DynamoDB PITR and S3 versioning. SageMaker model artifacts are versioned in the Model Registry, enabling rollback to a previous model version within minutes if a retraining cycle produces a degraded model.

**Retraining Operations:** The SageMaker Pipelines retraining workflow runs on a weekly schedule (configurable). It pulls fresh interaction data from DynamoDB, preprocesses and splits training data, retrains the preference-learning model, evaluates against a holdout set, and conditionally promotes the new model to the production endpoint if evaluation thresholds are met. Retraining execution history and model evaluation metrics are captured in CloudWatch and the SageMaker Experiment Tracker.

## Tooling Overview

The table below summarizes the primary AWS and supporting tools used across all phases of the engagement, organized by functional category.

<!-- TABLE_CONFIG: widths=[30, 35, 35] -->
| Category | Primary Tools | Purpose |
|----------|---------------|---------|
| ML Model Training & Serving | Amazon SageMaker, SageMaker Pipelines | NLP classifier, audio analyzer, preference model training and real-time inference endpoints |
| Foundation Model Inference | Amazon Bedrock (Titan / Anthropic Claude) | Lyric and transcript emotion enrichment via on-demand FM token inference |
| NLP & Text Analysis | Amazon Comprehend | Managed NLP for entity, sentiment, and key-phrase extraction from lyric and transcript text |
| Recommendation | Amazon Personalize | Collaborative-filtering preference model, user segmentation, and personalized ranking |
| Content Search & Discovery | Amazon OpenSearch Service | Semantic and emotion-attribute-based catalog search for playlist and discovery queries |
| API & Integration | Amazon API Gateway, AWS Lambda | REST API layer: routing, authorizers, WAF, throttling, and endpoint business logic |
| Authentication | Amazon Cognito | User pool, JWT token issuance and validation, mobile app authentication |
| Event Orchestration | AWS Step Functions, Amazon EventBridge, Amazon SQS | Multi-step pipeline orchestration, event routing, and feedback capture queue |
| Data Storage | Amazon DynamoDB, Amazon S3 | Content catalog, user preference vectors, model artifacts, raw audio, and transcript storage |
| Caching | Amazon ElastiCache (Redis) | Session state and playlist response caching to reduce API latency |
| Secrets & Config | AWS Secrets Manager | Firebase credentials, API keys, and database connection string management with rotation |
| Container Registry | Amazon ECR | Lambda container images and SageMaker custom inference container storage |
| Monitoring & Observability | Amazon CloudWatch, AWS CloudTrail, Amazon GuardDuty | Logs, metrics, dashboards, alarms, API audit trail, and threat detection |
| IaC & Deployment | AWS CDK / CloudFormation | Infrastructure-as-code for reproducible Dev and Staging environment provisioning |
| CI/CD | AWS CodePipeline, AWS CodeBuild | Automated deployment pipeline for Lambda functions, model updates, and infrastructure changes |

---

# Security & Compliance

Security is designed into every layer of the ANP Streaming AI Recommendation Engine, from API authentication and identity management through data encryption and operational governance. This section defines the security architecture that will be implemented during the engagement, aligned to the AWS Well-Architected Framework Security Pillar.

## Identity & Access Management

Amazon Cognito serves as the identity provider for the ANP Streaming platform. A dedicated Cognito User Pool manages listener, artist/uploader, and admin roles with distinct permission scopes. All API calls from the FlutterFlow application must present a valid Cognito access token (JWT); expired or invalid tokens are rejected at the API Gateway Lambda authorizer before any backend code executes.

AWS IAM follows least-privilege principles throughout. Every Lambda function, SageMaker endpoint, and Step Functions state machine is assigned a dedicated IAM execution role with permissions scoped to the exact AWS services and resources that component requires. No wildcard resource policies are used on production resources. IAM Access Analyzer is enabled on the AWS account to detect overly permissive policies. Admin access to the AWS account is restricted to named IAM users or federated SSO roles with MFA enforcement. All root account credentials are secured, and root account usage is disabled for day-to-day operations.

## Monitoring & Threat Detection

Amazon CloudWatch provides comprehensive operational visibility: all Lambda invocation logs, SageMaker endpoint inference logs, API Gateway access logs, and Step Functions execution history are streamed to CloudWatch Logs. Custom CloudWatch Metrics track security-relevant signals including failed authentication attempts, API throttle events, and anomalous inference request volumes.

AWS CloudTrail is enabled with a management-event trail logging all API calls made to AWS services within the account, stored in an S3 bucket with Object Lock enabled to prevent log tampering. Amazon GuardDuty continuously monitors CloudTrail logs, VPC Flow Logs, and DNS query logs for threat intelligence signals, compromised credentials, and anomalous access patterns. GuardDuty findings are routed to a CloudWatch Events rule that triggers an SNS alert to the ANP security team. AWS Security Hub aggregates findings from GuardDuty, AWS Config, and IAM Access Analyzer into a single security posture dashboard.

## Compliance & Auditing

This engagement is designed and delivered to AWS Well-Architected Framework Security Pillar standards. While no formal compliance certification (e.g., SOC 2, HIPAA, PCI-DSS) is in scope for this engagement, the architecture implements foundational controls that support future compliance certification. AWS Config is enabled with managed Config Rules covering: MFA on root account, encryption enabled on all S3 buckets, CloudTrail enabled, no unrestricted security group rules, and DynamoDB backup enabled. Config rule compliance status is reviewed at the mid-point and final project reviews. All API calls and data-access events are logged to CloudTrail, providing an immutable audit trail for future compliance review.

## Encryption & Key Management

Data in transit is encrypted using TLS 1.2 or higher for all communications between the FlutterFlow application and API Gateway, between Lambda functions and DynamoDB/S3, and between SageMaker endpoints and orchestration services. AWS Certificate Manager manages the TLS certificate for the API Gateway custom domain. Data at rest is encrypted using AWS KMS Customer Managed Keys (CMKs) for S3 buckets containing audio files, transcripts, and model artifacts; DynamoDB tables containing user preference vectors and catalog metadata; and SageMaker model packages. Key rotation is enabled on all CMKs with a 12-month rotation schedule. AWS Secrets Manager stores Firebase credentials, third-party API keys, and database connection strings with automatic rotation enabled on a 90-day cycle. No credentials are stored in environment variables, code repositories, or Lambda function configurations.

## Governance

All infrastructure changes are implemented through AWS CDK/CloudFormation templates committed to a version-controlled repository, reviewed through a pull-request process, and applied through a CI/CD pipeline — no manual console-based infrastructure changes are permitted in Staging or Production environments. AWS Config Rules provide detective controls with automated compliance checking. A formal change-management process is established during the engagement; all scope changes to this SOW follow the change-request procedure defined in the Terms & Conditions section. Access reviews are conducted at project milestones to ensure least-privilege is maintained as new components are added. The delivered operational runbooks include a quarterly access-review procedure for the ANP team to execute post-engagement.

## Environments & Access

### Environment Strategy

The following table defines the purpose, access controls, and data classification for each environment provisioned during this engagement.

<!-- TABLE_CONFIG: widths=[18, 27, 27, 28] -->
| Environment | Purpose | Access Control | Data |
|-------------|---------|----------------|------|
| Development | Active development, unit testing, model experimentation, pipeline iteration | nClouds engineers (full access); ANP Technical Lead (read access) | Synthetic data and sample catalog subset only; no production user data |
| Staging | Integration testing, performance testing, UAT, end-to-end validation | nClouds engineers (full access); ANP Technical Lead (full access); ANP CEO (read access for deliverable review) | Anonymized/masked copy of catalog data; no real user PII |
| Production | Live service delivery to FlutterFlow application (out of scope for this engagement) | ANP Technical Lead and security team only; nClouds access by mutual agreement only | Production catalog and user preference data; full encryption and access controls enforced |

### Access Policies

nClouds engineers are granted access to the Dev and Staging environments within the customer-provided AWS account via named IAM users or federated access, with MFA enforced on all accounts. Access is time-bounded to the engagement period; all nClouds IAM users and access keys are deprovisioned at project closeout. The ANP Technical Lead is the designated AWS account administrator post-engagement and is responsible for access revocation and ongoing IAM hygiene. Production environment access is controlled exclusively by the ANP team; nClouds receives no standing access to production resources.

---

# Testing & Validation

Testing is conducted across all five phases of the engagement, with formal test reporting delivered at the end of Phase 5. The testing strategy covers functional correctness, model accuracy, API performance, security validation, and end-to-end integration — ensuring every component meets its acceptance criteria before the engagement closes. All test results are documented in formal reports that form part of the Final Deliverable Package (Deliverable 27).

## Functional Validation

Functional testing validates that each pipeline component and API endpoint behaves as specified in the Phase 1 architecture documentation and API contract definitions. Test cases are written for each Lambda function, SageMaker endpoint, Step Functions workflow, and API endpoint, covering happy-path scenarios, boundary conditions, error handling and retry logic, and edge cases (empty mood input, cold-start user, catalog item with missing transcript). Each test case documents the input, expected output, and pass/fail criterion. A minimum of 80% code coverage is targeted for all Lambda function business logic. Functional test results are documented in a test report delivered with Phase 5.

## Performance & Load Testing

Performance testing validates that the API service layer meets the ≤2-second playlist generation response time target under simulated load. AWS Artillery or Locust is used to simulate concurrent API requests at 100 MAU and 10,000 MAU load profiles. Test scenarios include single playlist generation requests, concurrent playlist requests (10 simultaneous), catalog enrichment throughput (items/minute), and feedback capture endpoint throughput. Latency percentiles (p50, p95, p99) and error rates are recorded for each scenario. SageMaker endpoint auto-scaling policies are validated by confirming that endpoint scaling triggers correctly under load. Performance test results are included in the End-to-End Validation Report (Deliverable 22).

## Security Testing

Security validation is conducted at the API Service Layer level and covers: authentication bypass attempts (invalid JWT, expired JWT, missing Authorization header), API rate throttling enforcement, WAF rule triggering on known malicious payloads (SQL injection, XSS), IAM permission boundary testing (confirming Lambda functions cannot access resources outside their policy), and Secrets Manager access validation (confirming no credentials are exposed in logs or response bodies). AWS Security Hub findings are reviewed and remediated before Phase 5 handover. A final security configuration review is conducted against the AWS Well-Architected Security Pillar checklist and documented in the Phase 5 deliverable package.

## Disaster Recovery & Resilience Tests

The following DR and resilience tests are conducted in the Staging environment to validate operational runbook procedures before handover:

- **DynamoDB PITR Restore Test:** Restore a DynamoDB table from a point-in-time backup and validate data integrity against a known-good snapshot. Target: restore completes within 1 hour.
- **SageMaker Endpoint Model Rollback Test:** Roll back a SageMaker endpoint to the previous model version and confirm inference responses return to pre-rollback quality. Target: rollback completes within 10 minutes.
- **SQS Feedback Queue Backlog Recovery:** Simulate a 1-hour queue processing outage and confirm that queued feedback events are fully processed after service restoration without data loss.
- **Lambda Function Failure Retry Test:** Simulate a Lambda function failure in the catalog enrichment pipeline and confirm Step Functions retry logic recovers without duplicate catalog writes.

All DR test results are documented in the Operational Runbooks (Deliverable 24).

## User Acceptance Testing

UAT is conducted by the ANP Technical Lead and optionally Lilly Goyah in the Staging environment during Phase 5. UAT validates the solution from the perspective of the ANP team as the primary operators and consumers of the delivered system. UAT scenarios include:

- Uploading a sample audio file and transcript through the classification endpoint and verifying the returned emotion/mood attributes match expectations against the agreed taxonomy
- Submitting a mood input through the playlist generation endpoint and validating the returned track list matches the mood profile
- Verifying the FlutterFlow application successfully authenticates via Cognito and receives a valid playlist response without any frontend code changes
- Confirming the feedback capture endpoint correctly records a play and skip event and that the events appear in the DynamoDB preference-learning ingestion path

UAT acceptance is documented in a sign-off record signed by the ANP Technical Lead, which forms part of the Final Deliverable Package (Deliverable 27). Three working days are allocated for ANP to complete UAT after Staging is made available for testing.

## Go-Live Readiness

The following readiness checklist must be satisfied before the engagement is formally closed and before any production deployment is undertaken by the ANP team:

- [ ] All functional test cases pass in Staging environment
- [ ] Performance test confirms ≤2s playlist generation latency at 100 MAU load
- [ ] Security configuration review complete with no critical or high findings outstanding
- [ ] DynamoDB PITR and SageMaker model rollback tests passed
- [ ] All five REST API endpoints validated against FlutterFlow call patterns
- [ ] Operational runbooks reviewed and accepted by ANP Technical Lead
- [ ] Both knowledge-transfer sessions completed and attendance confirmed
- [ ] Final Deliverable Package compiled and accepted by Lilly Goyah
- [ ] AWS Cognito user pool configured for production user volumes
- [ ] All nClouds IAM access scoped and documented for post-engagement handover

## Cutover Plan

Production deployment is explicitly out of scope for this engagement. The following cutover plan is provided as a reference for the ANP team to execute independently after engagement close: (1) Create a production AWS environment using the CDK/CloudFormation templates delivered by nClouds; (2) Run the catalog enrichment pipeline against the full production Firebase catalog; (3) Provision Cognito user pool for production user volumes; (4) Deploy SageMaker endpoints in production with the model artifacts from Staging; (5) Update API Gateway stage variables to point to production resources; (6) Update the FlutterFlow application API base URL to the production endpoint; (7) Conduct a smoke test of all five endpoints from the FlutterFlow application; (8) Enable CloudWatch alarms and GuardDuty in the production environment; (9) Confirm operational runbooks are accessible to the ANP on-call team.

## Rollback Strategy

If a production deployment produces unexpected degradation, the ANP team can execute the following rollback steps: (1) Roll back SageMaker inference endpoints to the previous model version using the SageMaker Model Registry; (2) Repoint API Gateway to the previous Lambda function versions using Lambda Aliases; (3) If DynamoDB schema changes are involved, restore from PITR to the pre-deployment checkpoint; (4) Revert the FlutterFlow application API base URL to the Staging endpoint as a temporary continuity measure. Target rollback duration: under 30 minutes for Lambda/model rollbacks; under 2 hours for a full DynamoDB restore.

---

# Handover & Support

A successful handover ensures that the ANP Streaming team can operate, monitor, maintain, and evolve the delivered AI/ML system independently after the engagement closes. This section defines the artifacts, knowledge transfer activities, and support structure that enable that independence.

## Handover Artifacts

The following artifacts will be delivered to ANP Streaming at engagement close, compiled into the Final Deliverable Package (Deliverable 27):

- AWS architecture diagrams (high-level overview and detailed service-level diagrams)
- Data schema documentation: user preference vector schema, content metadata schema, mood taxonomy (label set and annotation guidelines)
- API contract documentation for all five REST endpoints (OpenAPI/Swagger format)
- Model documentation: training data requirements, hyperparameter configurations, evaluation metrics, and retraining schedule
- Operational runbooks for all services: deployment, scaling, model retraining, incident response, and access management
- Infrastructure-as-code (AWS CDK/CloudFormation) templates for all environments
- CI/CD pipeline configuration for Lambda, model, and infrastructure deployment
- AWS account configuration documentation: IAM policies, Cognito user pool settings, WAF rules, CloudWatch alarms
- Tiered AWS cost model spreadsheet (100 / 10K / 100K MAU projections)
- Project retrospective and lessons-learned document

## Knowledge Transfer

Two formal knowledge-transfer sessions are included in this engagement to ensure the ANP team is fully equipped to operate the delivered system independently.

**Knowledge Transfer Session 1 — Architecture, Pipelines & Retraining (Week 12):** This session covers the end-to-end architecture overview, the content intelligence pipeline (how new catalog items are classified at ingest), the recommendation engine (how preference models are trained and served), and the model retraining procedure (how to trigger a manual retraining cycle and evaluate the new model). Target audience: ANP engineering and technical operations team. Duration: 2–3 hours. Format: screen-share walkthrough with live demonstration in the Staging environment.

**Knowledge Transfer Session 2 — API Operations, Security, Monitoring & Incident Response (Week 13):** This session covers day-to-day API operations (how to monitor endpoint health, scale capacity, and update API configurations), security runbook walkthrough (IAM access review, Cognito user management, Secrets Manager rotation), CloudWatch dashboard and alarm interpretation, and incident-response scenarios drawn from the operational runbooks. Target audience: ANP technical lead, infrastructure owner, and security responsible. Duration: 2–3 hours. Format: screen-share walkthrough with live scenario walkthroughs.

## Hypercare Support

nClouds provides a 2-week hypercare support period following the delivery of the Final Deliverable Package (Deliverable 27) and formal engagement close. Hypercare support covers:

- **Coverage:** Business hours (9:00 AM – 5:00 PM ET, Monday–Friday)
- **Response Time:** 4-hour initial response for functional issues; next-business-day response for operational questions
- **Scope:** Bug fixes and configuration corrections for issues directly traceable to deliverables produced during the engagement; guidance on operational procedures covered in the runbooks; assistance with minor configuration adjustments
- **Out of Scope during Hypercare:** New feature development, scope changes, production deployment support, or issues caused by changes made by the ANP team post-handover
- **Channel:** Dedicated Slack channel or email thread; video call by appointment for complex issues

## Managed Services Transition

Ongoing managed services are not included in this engagement. Refer to a separate Managed Services Agreement with nClouds if ongoing operational support, proactive monitoring, or infrastructure management is required after the hypercare period concludes.

## Assumptions

The following assumptions underpin the scope, timeline, and pricing defined in this SOW. nClouds reserves the right to raise a change request if any assumption is found to be materially incorrect during delivery.

1. ANP Streaming provides a dedicated AWS account with admin-level credentials to nClouds within 3 business days of the effective date.
2. Lilly Goyah (CEO) is available for the requirements workshop, mid-point review, and final readout as scheduled.
3. ANP makes application/workload owner, infrastructure architect, network architect, and security architect SMEs available for discovery sessions within the first two weeks.
4. ANP provides representative lyric and transcript file samples (minimum 50 tracks/episodes) in Week 1 to enable early taxonomy and classifier design work.
5. ANP provides access to the Firebase catalog API and shares the existing mood-tagging schema before the requirements workshop.
6. The AWS Partner Funding Portal (APFP) application is approved before nClouds begins billable work; if approval is delayed, project start date shifts accordingly.
7. Customer reviews and accepts each deliverable within 3 business days of delivery; delays in review may shift downstream milestone dates.
8. Off-hours work (outside 9 AM – 6 PM PT, Monday–Friday) requires mutual written agreement with at least 48 hours' notice.
9. Production deployment is out of scope; nClouds delivers a production-ready solution in Staging, and the ANP team executes production promotion.
10. Firebase data migration execution is out of scope; catalog data is accessed via Firebase REST API during the engagement.
11. The solution is deployed in a single AWS region (us-east-1) unless mutually agreed otherwise in writing.
12. No specific regulatory compliance certification (SOC 2, HIPAA, PCI-DSS) is required for this engagement phase.
13. ANP's existing security AWS account (or a new dedicated security account) is available for Security Hub and GuardDuty integration.
14. No third-party music data sources, external licensing databases, or paid annotation services are required for model training.
15. The model training dataset is sufficient for initial classifier training; nClouds will flag data-sparsity risk early if the sample set is insufficient.

## Dependencies

The following dependencies are critical to delivery on schedule. Delays in any dependency may result in a corresponding shift to the project timeline.

| Dependency | Owner | Required By |
|------------|-------|-------------|
| AWS Partner Funding Portal (APFP) approval confirmed | nClouds (submission) / AWS (approval) | Before project kickoff |
| Dedicated AWS account with admin credentials provided | ANP Streaming | Week 1, Day 1 |
| Firebase catalog API access and mood-tagging schema shared | ANP Streaming | Week 1 |
| Lyric and transcript sample files (≥50 items) provided | ANP Streaming | Week 1 |
| SME availability for requirements workshop (CEO + technical team) | ANP Streaming | Week 1–2 |
| Phase 1 deliverable review and sign-off by ANP | ANP Streaming | Within 3 business days of delivery |
| Mid-point stakeholder review (CEO + technical lead) | ANP Streaming | Week 6–7 |
| UAT participation in Staging environment | ANP Streaming | Week 12–13 |
| Both KT session attendees confirmed and available | ANP Streaming | Weeks 12–13 |
| AWS account security controls (existing security account or new) available | ANP Streaming | Week 2 |

---

# Investment Summary

This engagement is funded through the AWS Partner Funding Portal (APFP), with $25,000 in AWS Partner Funding fully covering the professional-services fee. ANP Streaming's net cost for professional services is $0.00. The customer is separately responsible for all AWS infrastructure consumption charges incurred by the delivered solution. The following figures are drawn directly from the infrastructure-costs.csv and level-of-effort-estimate.csv supporting documents and represent the authoritative financial basis for this engagement.

**Medium-Complexity AI/ML Implementation:** This pricing reflects a medium-complexity, multi-model AI/ML recommendation and content-intelligence platform built from scratch — encompassing five interacting ML components (NLP classifier, audio analyzer, preference-learning model, mood-to-content matcher, and playlist generator) delivered across five sequential phases over approximately three months.

## Total Investment

The table below presents the complete 3-year investment view across all cost categories, reconciling professional services (from level-of-effort-estimate.csv) and infrastructure costs (from infrastructure-costs.csv 3-Year Summary). Infrastructure figures reflect the 100 MAU (small) scenario; the Phase 1 tiered cost model will provide 10K and 100K MAU projections.

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[28, 13, 14, 13, 11, 11, 13] -->
| Cost Category | Year 1 List | Year 1 Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|----------------|------------|--------|--------|--------------|
| Professional Services | $25,000 | ($25,000) | $0 | $0 | $0 | $0 |
| Cloud Infrastructure | $2,563 | ($2,500) | $63 | $2,563 | $2,890 | $5,516 |
| Software Licenses | $0 | $0 | $0 | $0 | $0 | $0 |
| Support & Maintenance | $1,200 | $0 | $1,200 | $1,200 | $1,200 | $3,600 |
| **TOTAL INVESTMENT** | **$28,763** | **($27,500)** | **$1,263** | **$3,763** | **$4,090** | **$9,116** |
<!-- END COST_SUMMARY_TABLE -->

*Infrastructure costs reflect the 100 MAU (small) scenario. AWS cost projections at 10,000 MAU (~$14,400/year estimated) and 100,000 MAU (~$54,000/year estimated) are delivered as a separate tiered cost model in Phase 1 (Deliverable 7).*

## Partner Credits

**AWS Partner Funding (APFP) — $25,000:** nClouds is an AWS Advanced Consulting Partner and has applied for $25,000 in AWS Partner Funding to cover 100% of the professional-services fee for this engagement. This credit is applied at project kickoff invoice and results in a net professional-services cost of $0.00 to ANP Streaming. nClouds does not begin billable work until AWS funding approval is confirmed through the AWS Partner Funding Portal. nClouds manages the entire APFP application process on behalf of the engagement.

**AWS Activate Founders Credit — $2,500:** ANP Streaming, as an early-stage startup, is eligible for AWS Activate Founders credits applicable to Year 1 cloud service consumption. This credit reduces Year 1 infrastructure charges from $2,563 to approximately $63. The credit is applied directly to the ANP Streaming AWS account by AWS upon Activate enrollment.

**Total Credits Applied: $27,500** (Year 1 only; credits do not carry forward to Year 2 or Year 3).

## Cost Components

**Professional Services — $25,000 (gross) / $0 net:** The professional-services fee covers 620+ hours of delivery across seven resource types: Solution Architect, ML/AI Engineer, Solutions Engineer, QA Engineer, Technical Writer, Project Manager, and Security Engineer. The fee is fully offset by AWS Partner Funding. A detailed level-of-effort estimate is maintained in `level-of-effort-estimate.csv` and is available for client review on request. Key cost drivers are the ML/AI Engineer hours for model development (Phases 2 and 3, with effort multipliers of 1.2 and 1.3 respectively) and the Solution Architect hours for architecture design and knowledge-transfer delivery.

**Cloud Infrastructure — $2,563/year (100 MAU scenario):** AWS infrastructure costs at the 100 MAU scale tier include: Amazon Bedrock on-demand token inference ($600/yr), Amazon SageMaker endpoint ($480/yr), Amazon DynamoDB on-demand ($300/yr), Amazon CloudWatch ($360/yr), Amazon OpenSearch Service ($300/yr), Amazon S3 ($138/yr), SageMaker training jobs ($55/yr), Amazon ECR ($120/yr), Amazon API Gateway and Lambda ($120/yr), AWS Step Functions ($60/yr), Amazon Cognito ($6/yr), and AWS Secrets Manager ($24/yr). Year 3 reflects approximately 10–20% usage growth at the 100 MAU tier, consistent with the infrastructure-costs.csv projections.

**Support & Maintenance — $1,200/year:** AWS Business Support Plan providing 24×7 technical support, 1-hour critical-case response time, and full Trusted Advisor check access across all AWS services in the account. This tier is recommended for all production workloads and is carried at a flat $1,200/year across the 3-year model.

## Payment Terms

The following payment schedule applies all professional-services invoices against the AWS Partner Funding credit, resulting in $0 net payment at each milestone.

- **Kickoff Invoice (50% — $12,500 gross / $0 net):** Invoiced at project kickoff; fully offset by the first drawdown of the AWS Partner Funding credit applied simultaneously.
- **Milestone Invoice M4 (30% — $7,500 gross / $0 net):** Invoiced upon completion and ANP acceptance of M4 (Recommendation Engine Live); offset by the second APFP credit drawdown.
- **Final Invoice (20% — $5,000 gross / $0 net):** Invoiced upon formal project close and ANP acceptance of the Final Deliverable Package; offset by the final APFP credit drawdown.
- **Net Terms:** All invoices are Net-10 from invoice date; payment is due within 30 days of invoice per the brief.
- **AWS Infrastructure Charges:** Billed directly to the ANP Streaming AWS account by AWS on a monthly consumption basis; nClouds has no visibility into or liability for AWS infrastructure consumption charges after the engagement commences.

## Invoicing & Expenses

Invoices are issued in USD to the billing contact designated by ANP Streaming at kickoff. No travel is anticipated for this engagement; all sessions are conducted remotely via video conference. If in-person sessions are mutually agreed, reasonable travel expenses are reimbursed at cost with receipts, subject to prior written approval from ANP Streaming. AWS infrastructure consumption during the engagement (Dev and Staging environments) is charged to the ANP Streaming AWS account; nClouds does not mark up AWS consumption charges.

---

# Terms & Conditions

This Statement of Work is subject to the Master Services Agreement (MSA) between nClouds, Inc. and ANP Streaming. In the event of any conflict between this SOW and the MSA, the MSA shall govern except where this SOW expressly overrides a specific provision. All services described herein are professional services delivered on a fixed-fee basis.

## General Terms

This SOW is incorporated by reference into the Master Services Agreement executed between nClouds, Inc. and ANP Streaming. The effective date of this SOW is March 19, 2026. Work commences upon confirmation of AWS Partner Funding approval. All terms related to service-level warranties, indemnification, and dispute resolution are governed by the MSA unless expressly addressed in this SOW.

## Scope Changes

Any modification to the scope defined in this SOW — including additions to deliverables, changes to architectural components, expansion of the AI/ML model count, or changes to the timeline — requires a formal Change Request (CR) process: (1) Either party may initiate a CR by submitting a written description of the proposed change; (2) nClouds provides a written impact assessment within 5 business days covering additional effort, cost, and timeline implications; (3) The change is effective only upon written approval from both Lilly Goyah (ANP) and the nClouds commercial sponsor; (4) Changes that increase the professional-services fee require a SOW amendment — the AWS Partner Funding credit covers only the fees defined in this SOW. Emergency changes required to prevent project failure may be initiated verbally and documented within 48 hours.

## Intellectual Property

Upon receipt of final payment, all project deliverables produced under this SOW — including architecture documentation, data schemas, API contracts, operational runbooks, infrastructure-as-code templates, and trained ML models — are assigned to ANP Streaming as work-for-hire. nClouds retains ownership of its pre-existing methodologies, frameworks, accelerators, and tooling used to deliver the engagement. ANP Streaming receives a perpetual, royalty-free license to use nClouds-originated components embedded in the delivered solution. Open-source components are subject to their respective licenses. AWS services remain subject to the AWS Customer Agreement.

## Service Levels

nClouds warrants that all deliverables will materially conform to the specifications defined in this SOW for a period of 30 days following formal acceptance. During this warranty period, nClouds will remediate at no charge any defect traceable to a deliverable produced under this SOW. The warranty does not cover defects resulting from: changes made by ANP Streaming or third parties after acceptance; use of deliverables outside the intended architecture scope; or external service changes (e.g., AWS service API changes, Firebase API changes). After the warranty and hypercare periods, support is available under a separate agreement.

## Liability

Each party's aggregate liability under this SOW is limited to the total fees paid or payable under this SOW in the twelve (12) months preceding the claim. Neither party is liable for indirect, incidental, consequential, special, or punitive damages regardless of whether such damages were foreseeable. This limitation does not apply to breaches of confidentiality, gross negligence or willful misconduct, or indemnification obligations. nClouds maintains commercial general liability ($1M per occurrence / $2M aggregate), professional liability / errors & omissions ($1M), and cyber liability insurance ($1M) coverage throughout the engagement.

## Confidentiality

Both parties agree to protect the other's confidential information using the same standard of care applied to their own confidential information (no less than reasonable care). Confidential information includes: ANP Streaming's catalog data, user data, business plans, investor materials, and technical systems; and nClouds' methodologies, pricing, and proprietary tools. Confidentiality obligations survive termination of this SOW for a period of three (3) years. Obligations do not apply to information that is publicly available without breach, was independently developed, was received from a third party without restriction, or is required to be disclosed by law with reasonable prior notice where permitted.

## Termination

Either party may terminate this SOW for convenience with thirty (30) days' written notice. Upon termination, ANP Streaming is responsible for all fees for work completed through the termination date, plus reasonable wind-down costs incurred within the 30-day notice period. nClouds will deliver all completed work products to ANP Streaming within 10 business days of termination. Either party may terminate immediately for material breach if the breaching party fails to cure the breach within fifteen (15) business days of written notice. AWS Partner Funding credit reconciliation upon termination is handled per AWS Partner Funding Program terms.

## Governing Law

This SOW is governed by the laws of the State of California, without regard to its conflict-of-law principles. Any disputes that cannot be resolved through good-faith negotiation within 30 days shall be submitted to binding arbitration under the rules of the American Arbitration Association, with proceedings conducted in San Francisco, California. Notwithstanding the foregoing, either party may seek emergency injunctive relief in a court of competent jurisdiction.

---

# Sign-Off

By signing below, both parties agree to the scope, deliverables, technical approach, commercial terms, and all other provisions outlined in this Statement of Work. This SOW, together with the Master Services Agreement, constitutes the complete agreement between the parties for the services described herein and supersedes all prior negotiations, representations, or agreements relating to the subject matter.

**Client Authorized Signatory:**

Name: __________________________
Title: __________________________
Signature: ______________________
Date: __________________________

Organization: ANP Streaming

---

**Service Provider Authorized Signatory:**

Name: __________________________
Title: __________________________
Signature: ______________________
Date: __________________________

Organization: nClouds, Inc.

---

*This Statement of Work is effective as of March 19, 2026 and was fully executed on May 11, 2026. This document constitutes the complete agreement between the parties for the services described herein and supersedes all prior negotiations, representations, or agreements relating to this subject matter. Any modification to this SOW must be made in writing and signed by authorized representatives of both parties.*
