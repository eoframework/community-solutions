---
document_title: Detailed Design Document
solution_name: ANP Streaming AI Mood & Recommendation API
document_version: "1.0"
author: Jonas Bull
last_updated: 2025-06-01
technology_provider: AWS
client_name: ANP Streaming
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Detailed Design Document (DDD) defines the technical architecture and implementation blueprint for the ANP Streaming AI Mood & Recommendation API, delivered by nClouds, Inc. on behalf of ANP Streaming. The solution is a fully serverless AWS backend that introduces AI-powered mood/emotion classification and personalized playlist recommendations to ANP Streaming's existing faith-based music and podcast platform, without requiring any changes to the FlutterFlow mobile frontend.

The design described in this document expands the Architecture & Design section of the Statement of Work (SOW) into implementation-ready technical detail. Every architecture component, security control, data flow, and SLA target traces directly to a commitment made in the SOW and Solution Briefing. The engagement is structured across three phases spanning six weeks, delivering two production REST API endpoints (`POST /classify` and `GET /recommend`), an automated mood-tagging pipeline, and a complete operational handover package to ANP Streaming.

This document is intended for the nClouds delivery team (Solutions Architect, ML/AI Engineer, Cloud Engineer, Security Engineer, QA Engineer), the ANP Streaming technical contact responsible for integration and UAT, and the ANP executive sponsor (Lilly Goyah). Readers should be familiar with AWS managed services, RESTful API design, and the scope commitments captured in SOW version 1.0 (Opportunity OPP-2025-001).

## Purpose

This document provides the authoritative technical specification for the ANP Streaming AI Mood & Recommendation API engagement. It defines component-level designs, configuration parameters, data schemas, security controls, infrastructure sizing, and implementation sequencing. It serves as the primary reference for the nClouds engineering team during Phases 2 and 3, and as a baseline for ANP Streaming's post-handover operational activities.

## Scope

**In-scope:**

- AWS environment setup in us-east-1 for Dev and Production (IAM, API Gateway, Lambda, DynamoDB, S3, CloudWatch, Secrets Manager, Cognito)
- Amazon Bedrock on-demand foundation model inference for mood/emotion classification of lyric and transcript text
- `POST /classify` REST endpoint: accepts song or podcast text, returns mood/emotion label and confidence score
- `GET /recommend` REST endpoint: accepts mood label and user ID, returns personalized playlist
- Automated batch Lambda pipeline to tag new catalog uploads with mood/emotion labels via Bedrock
- DynamoDB schema design and seed data load from Firebase catalog metadata export
- API key authentication, HTTPS enforcement, IAM least-privilege policies, and AWS Secrets Manager configuration
- CloudWatch dashboards, Lambda error alarms, and API Gateway latency alerting
- Infrastructure as Code (AWS CDK/CloudFormation) for repeatable environment deployments
- Developer-facing API reference documentation and operational runbook
- Live knowledge transfer session and two-week post-go-live hypercare support

**Out-of-scope:**

- Firebase data migration, restructuring, or real-time Firebase-to-DynamoDB synchronization
- Any changes to the FlutterFlow mobile frontend, UI components, or Firebase Authentication flows
- Custom ML model training, fine-tuning, or hosting (engagement uses Bedrock on-demand inference)
- Amazon Personalize or any dedicated collaborative-filtering recommendation service
- A dedicated staging or QA environment (only Dev and Production are provisioned)
- PCI-DSS, HIPAA, or SOC 2 compliance audit and certification
- Ongoing managed services or 24×7 support beyond the 2-week hypercare period
- Content delivery or CDN configuration for audio streaming

## Assumptions & Constraints

- ANP Streaming will provide nClouds with admin-level AWS account access within 5 business days of engagement kickoff.
- The Firebase catalog export (lyrics and transcript text) will be available for S3 upload by the start of Week 2, containing at least 200 items with sufficient lyric/transcript text for Bedrock model evaluation.
- ANP Streaming will designate one technical point of contact available for up to 4 hours per week during the engagement for API schema review, UAT, and knowledge transfer participation.
- Amazon Bedrock on-demand inference is available in us-east-1 for the selected foundation model at engagement commencement.
- The existing FlutterFlow app can make outbound HTTPS REST API calls to an external AWS API Gateway endpoint without any code changes to the mobile frontend.
- No HIPAA, PCI-DSS, or other regulatory compliance certification is required as part of this engagement.
- Concurrent user load at launch is expected to remain below 100 simultaneous active users; scope parameters may be revisited if usage grows significantly.
- nClouds will not have access to live Production user data during development; test data is provided by ANP Streaming or synthetically generated.
- AWS partner credits of $15,000 (professional services) and $1,500 (MAP infrastructure credit) are subject to AWS funding program approval prior to invoicing.

## References

- Statement of Work v1.0 — ANP Streaming AI Mood & Recommendation API (OPP-2025-001)
- Solution Briefing — ANP Streaming AI Mood & Recommendation API
- Infrastructure Costs Model — ANP Streaming (infrastructure-costs.csv)
- AWS Well-Architected Framework — Security Pillar, Operational Excellence Pillar
- Amazon Bedrock Developer Guide
- AWS CDK Developer Guide
- FlutterFlow REST API Integration Documentation

---

# Business Context

ANP Streaming is a faith-based Christian music and podcast streaming application served to its audience through a FlutterFlow mobile app backed by Firebase. The platform has grown to serve a dedicated community of faith-based listeners but currently lacks the intelligent content discovery and automated curation capabilities that modern streaming audiences expect. This technical design is motivated by a set of concrete business drivers that were documented during presales and confirmed with ANP Streaming's CEO, Lilly Goyah, in the SOW engagement.

## Business Drivers

- **Enable Mood-Based Content Discovery:** Listeners expect a personalized experience where the app surfaces songs and podcasts that match their current emotional or spiritual state. Delivering a recommendation API that factors in mood classification and listening history directly increases time-in-app and listener satisfaction metrics.
- **Automate Catalog Enrichment:** As the ANP Streaming catalog grows, manually tagging each upload with mood and emotion labels creates a curation bottleneck. The auto-tagging pipeline eliminates this bottleneck by classifying new content at upload time via Amazon Bedrock, enabling the catalog to scale without proportional growth in manual effort.
- **Integrate Without Frontend Rework:** ANP Streaming has an established FlutterFlow mobile frontend and a Firebase backend. A full platform rebuild would require months of work and significant investment. The REST API approach surfaces AI capabilities through a stable interface that the existing mobile app can call without any frontend modifications, protecting the existing investment.
- **Establish a Scalable AI Platform:** By building on fully managed AWS services (Lambda, Bedrock, API Gateway, DynamoDB), the solution scales automatically with user growth and content volume. ANP Streaming pays only for actual usage, keeping infrastructure costs proportional to audience size.
- **Maximize AWS Partner Funding:** The engagement is structured to leverage $15,000 in AWS partner credits that offset 100% of professional services fees in Year 1, reducing ANP Streaming's net investment to infrastructure-only costs ($1,403 Year 1 net after MAP credits).

## Workload Criticality & SLA Expectations

The API serves as the AI backbone for the FlutterFlow mobile app's discovery features. Availability and responsiveness directly impact the listener experience. The following SLA targets were agreed in the SOW and must be satisfied before Production go-live.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Metric | Target | Measurement | Priority |
|--------|--------|-------------|----------|
| Availability | 99.5% | CloudWatch uptime monitoring on API Gateway | High |
| API Response Time (p95) | ≤ 2 seconds | CloudWatch API Gateway latency metric | Critical |
| Mood Classification Accuracy | ≥ 90% | Labeled sample validation in Phase 3 | Critical |
| RTO | 1 hour | Lambda + IaC re-deployment test | High |
| RPO | 24 hours | DynamoDB PITR continuous backup | High |
| Auto-Tagging Latency | ≤ 60 seconds | S3 event trigger to DynamoDB write time | Medium |

## Compliance & Regulatory Factors

- No HIPAA, PCI-DSS, or SOC 2 compliance certification is required for this engagement. ANP Streaming operates in a standard commercial environment with no regulated data categories at launch.
- The architecture is designed to be compatible with a future SOC 2 Type II assessment if ANP Streaming chooses to pursue certification as the platform grows.
- User listening history is treated as personally identifiable usage data and is scoped exclusively to authenticated users via Cognito JWT validation. No user data is exposed in the Dev environment.
- All infrastructure is provisioned via IaC with tagged resources, supporting future compliance audit requirements.

## Success Criteria

- Both `POST /classify` and `GET /recommend` endpoints are live in Production within 6 weeks of engagement kickoff, callable from the FlutterFlow app with zero frontend changes.
- Bedrock mood/emotion classification accuracy is ≥ 90% validated against a representative sample of faith-based lyric and transcript content.
- p95 API response latency is ≤ 2 seconds for both endpoints at 50 concurrent users in performance testing.
- Dev and Production AWS environments are fully provisioned and operational by the end of Week 2.
- All security test cases pass (100% pass rate): API key enforcement, JWT validation, HTTPS-only access, and IAM scope validation.
- API reference documentation, operational runbook, and knowledge transfer session are delivered and accepted by ANP Streaming's technical contact by Week 6.
- AWS partner credits are approved and applied before engagement invoicing, resulting in $0 net professional services cost in Year 1.

---

# Current-State Assessment

ANP Streaming's existing platform is a Firebase-backed FlutterFlow mobile application serving a faith-based Christian music and podcast audience. The current state was assessed during the presales phase and confirmed with Lilly Goyah (CEO) and the ANP technical contact. This assessment documents the environment that the new AI backend will integrate with, the gaps it addresses, and the data assets that will seed the new system.

## Application Landscape

The ANP Streaming application is a single mobile application delivered via FlutterFlow, with Firebase providing real-time database, authentication, and content metadata storage. There is no existing AI or ML backend layer.

<!-- TABLE_CONFIG: widths=[25, 30, 25, 20] -->
| Application | Purpose | Technology | Status |
|-------------|---------|------------|--------|
| ANP Streaming Mobile App | Faith-based music and podcast streaming for end users | FlutterFlow (Flutter/Dart), iOS/Android | Retain — no frontend changes |
| Firebase Realtime Database / Firestore | Content catalog metadata, user authentication, listening history | Google Firebase | Retain — read-only export to S3 |
| Firebase Authentication | User identity and session management for mobile app | Firebase Auth (JWT) | Retain — Cognito supplements for API auth |

## Infrastructure Inventory

ANP Streaming's current infrastructure is entirely managed by Google Firebase and FlutterFlow's cloud hosting. There are no self-managed servers, virtual machines, or databases. The engagement provisions the new AWS infrastructure components described in Section 4.

<!-- TABLE_CONFIG: widths=[20, 15, 35, 30] -->
| Component | Quantity | Specifications | Notes |
|-----------|----------|----------------|-------|
| Firebase Realtime DB / Firestore | 1 | Managed Google Cloud NoSQL; catalog + user data | Source for catalog seed export to S3 |
| Firebase Authentication | 1 | Managed Google service; JWT-based user identity | App continues using Firebase Auth; Cognito added for API layer |
| FlutterFlow Hosting | 1 | FlutterFlow-managed mobile app build and deployment | No changes; app calls new AWS REST API endpoints |
| Firebase Storage | 1 | Object storage for audio content files | Out of scope; audio files are not processed in this engagement |

## Dependencies & Integration Points

- **Firebase Catalog Export:** ANP Streaming must export lyric and transcript text from Firebase to an S3 bucket (`anp-catalog/`) as a one-time CSV or flat-file dump by the start of Week 2. This is the seeding event for the DynamoDB mood-tag index.
- **FlutterFlow HTTPS Outbound Calls:** The existing FlutterFlow app must be able to make HTTPS REST API calls to an external Amazon API Gateway endpoint. This capability must be confirmed by ANP Streaming before UAT in Week 5.
- **Firebase Authentication JWTs:** The FlutterFlow app currently issues Firebase JWTs to authenticated users. The `GET /recommend` endpoint will validate Amazon Cognito JWTs, not Firebase JWTs. ANP's technical contact must configure the FlutterFlow app to obtain and pass a Cognito JWT for recommendation calls (documented in the API reference).

## Network Topology

The current ANP Streaming platform has no customer-managed network infrastructure. All traffic flows over the public internet between end-user mobile devices, FlutterFlow app hosting, and Firebase-managed cloud services. The new AWS architecture follows the same internet-facing, public-HTTPS model for API traffic — no VPN, Direct Connect, or private network integration is required.

## Security Posture

ANP Streaming's current security posture is defined by Firebase's managed security model (Firebase Authentication, Firebase Security Rules) and the FlutterFlow platform's hosting controls. There are no existing AWS IAM policies, encryption configurations, or centralized audit logging capabilities relevant to the new engagement. The new AWS backend introduces a defense-in-depth security baseline (detailed in Section 5) that ANP Streaming will own post-handover.

## Performance Baseline

- There is no existing AI or API backend to baseline. Performance targets are forward-looking SLAs agreed in the SOW.
- Firebase Realtime Database provides sub-100ms read latency for catalog queries under ANP Streaming's current load.
- The p95 latency target for the new AWS API is ≤ 2 seconds, which accounts for Bedrock inference time on the classification endpoint.

## Gap Analysis

The following table summarizes the capability gaps that this engagement addresses, mapping the current Firebase-only state to the target AWS AI-enabled state.

<!-- TABLE_CONFIG: widths=[33, 34, 33] -->
| Current State | Gap | Target State |
|---------------|-----|--------------|
| No content personalization; generic discovery experience | Lack of AI classification and user-history-aware recommendation | `GET /recommend` returns mood-matched, history-personalized playlists per user |
| Manual mood/emotion tagging by ANP team per upload | Manual process is a bottleneck; not scalable with catalog growth | Auto-Tagger Lambda classifies new uploads via Bedrock within 60 seconds of S3 upload |
| No AI/ML inference capability | No foundation model or inference layer exists in ANP's stack | Amazon Bedrock on-demand inference provides LLM-based mood classification from lyrics and transcripts |
| Firebase-only backend; no AWS services | No CloudWatch observability, IAM governance, or IaC deployment discipline | Full AWS operational model: CloudWatch dashboards, alarms, IaC-managed infrastructure |
| No structured security baseline for API access | API traffic is uncontrolled; no key management, audit logging, or secret rotation | API key auth, Cognito JWT validation, IAM least-privilege, Secrets Manager, CloudTrail audit logging |

---

# Solution Architecture

The ANP Streaming AI Mood & Recommendation API is designed as a fully serverless, event-driven AWS architecture deployed in a single region (us-east-1). All compute is handled by AWS Lambda functions invoked through Amazon API Gateway, eliminating any server provisioning, capacity planning, or operating system management overhead. Amazon Bedrock provides on-demand foundation model inference for mood/emotion classification, avoiding the cost and operational complexity of managing custom ML model infrastructure. Amazon DynamoDB stores the catalog mood-tag index and per-user listening history, delivering single-digit-millisecond query performance for recommendation requests.

The architecture is intentionally minimal and proportional to ANP Streaming's current scale — a small faith-based audience, a catalog of under 50 GB, and fewer than 100 simultaneous active users at launch. Every service used is fully managed by AWS, meaning infrastructure patching, scaling, and availability are AWS responsibilities. The two-environment design (Dev and Production) enables safe iterative development, accuracy validation, and integration testing before any code reaches the live user-facing system.

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

The diagram above illustrates the end-to-end flow from the FlutterFlow mobile app through Amazon API Gateway, through the Lambda function layer, to Amazon Bedrock inference, Amazon DynamoDB, and Amazon S3, with supporting services for security (IAM, Secrets Manager, Cognito) and observability (CloudWatch, CloudTrail).

## Architecture Principles

The following principles guided every design decision in this architecture and must be maintained by the ANP Streaming team during post-handover operations and future enhancements.

- **Serverless-First:** All compute is AWS Lambda; no EC2 instances, ECS clusters, or containers are provisioned. This minimizes ANP Streaming's operational burden and ensures the cost model remains pay-per-use, with near-zero idle cost during off-peak hours.
- **Least-Privilege Security by Design:** Every Lambda function, IAM user, and service-to-service interaction operates with the minimum set of AWS permissions required. Wildcard permissions and cross-function role sharing are explicitly prohibited. This principle is enforced at IaC template level, not just documented as a guideline.
- **Managed AI Inference, Not Custom Models:** Amazon Bedrock on-demand inference is used for mood/emotion classification rather than training, fine-tuning, or self-hosting a custom model. This trades marginal accuracy tuning capability for a dramatically reduced operational surface area — appropriate for ANP Streaming's team size and expertise.
- **Infrastructure as Code from Day One:** All AWS resources are provisioned exclusively via AWS CDK or CloudFormation templates stored in version control. No "click-ops" manual configuration is performed in the AWS Console for resources that are part of the solution stack. This enables repeatable deployments, traceable change history, and rapid environment recovery.
- **Observability by Default:** CloudWatch Logs, Metrics, and Alarms are configured for every Lambda function and API Gateway stage from initial provisioning. Structured JSON log formatting is enforced across all Lambda functions to enable CloudWatch Log Insights queries without parsing overhead.
- **Cost Proportionality:** All services are selected and configured in pay-per-use billing modes (Lambda invocations, DynamoDB on-demand, Bedrock on-demand, API Gateway per-request). No reserved capacity or provisioned throughput is introduced until load testing in Phase 3 demonstrates a clear cost benefit.

## Architecture Patterns

The following patterns define how the solution components interact and how the system handles load, failures, and data flow.

- **Primary Pattern:** Event-driven serverless API — API Gateway triggers synchronous Lambda invocations for classification and recommendation; S3 event notifications trigger asynchronous Lambda invocations for the auto-tagging pipeline.
- **AI Pattern:** Prompt-based LLM inference via Amazon Bedrock — Lambda constructs a structured prompt from lyric/transcript text, invokes the Bedrock model, and parses the structured JSON response. The Bedrock model and prompt template are selected in Phase 1 based on accuracy benchmarking against faith-based content.
- **Data Pattern:** Command-Query separation — the Auto-Tagger writes mood tags to DynamoDB on catalog ingestion; the Recommender Lambda reads (queries) from DynamoDB at API request time without triggering re-classification.
- **Integration Pattern:** REST API with API key and JWT authentication — the FlutterFlow mobile app calls API Gateway using an API key (for `/classify`) and a Cognito JWT (for `/recommend`), with no AWS credentials exposed on the mobile client.
- **Deployment Pattern:** IaC stack-based blue-green deployment — CloudFormation/CDK stacks are deployed atomically; Lambda function versions are published with aliases enabling rapid rollback to the previous stable version if issues arise post-deployment.

## Component Design

The solution comprises eight primary AWS components, each with a distinct responsibility boundary. The following table summarizes each component's purpose, the specific technology used, its dependencies, and its scaling behavior under increasing load.

<!-- TABLE_CONFIG: widths=[18, 25, 22, 18, 17] -->
| Component | Purpose | Technology | Dependencies | Scaling |
|-----------|---------|------------|--------------|---------|
| API Gateway (REST) | Public HTTPS entry point; routes, authenticates, and throttles API requests | Amazon API Gateway REST API, Usage Plan, API Key | Lambda (Classifier, Recommender), Cognito User Pool | Auto-scales with request volume; throttled by usage plan |
| Classifier Lambda | Invokes Bedrock with lyric/transcript text; returns mood label + confidence score | AWS Lambda Python 3.12, `boto3` Bedrock client | Amazon Bedrock, CloudWatch Logs, Secrets Manager | Concurrent executions up to Lambda account limit; provisioned concurrency optional for p95 tuning |
| Recommender Lambda | Queries DynamoDB for user history and catalog mood index; returns ordered playlist | AWS Lambda Python 3.12, `boto3` DynamoDB client | DynamoDB (`anp-catalog-moods`, `anp-user-history`), Cognito authorizer, CloudWatch Logs | Concurrent executions auto-scale with request volume |
| Auto-Tagger Lambda | Processes new S3 catalog uploads; invokes Bedrock and writes mood tags to DynamoDB | AWS Lambda Python 3.12, S3 event trigger, `boto3` | Amazon S3 (`anp-catalog/` prefix), Amazon Bedrock, DynamoDB (`anp-catalog-moods`), CloudWatch Logs | Event-driven; scales with S3 upload frequency |
| Amazon Bedrock | Foundation model inference for mood/emotion classification from text | Anthropic Claude 3 Haiku or Amazon Titan Text G1 (confirmed in Phase 1) | N/A (managed AWS service) | On-demand; scales automatically with invocations |
| Amazon DynamoDB | Catalog mood-tag index and per-user listening history storage | DynamoDB pay-per-request; two tables: `anp-catalog-moods`, `anp-user-history` | N/A (managed AWS service) | Auto-scales with read/write volume in on-demand mode |
| Amazon S3 | Lyric and transcript text file storage; event notification source for Auto-Tagger | S3 Standard, SSE-S3 encryption, versioning enabled | Lambda (Auto-Tagger via S3 event notification) | Unlimited object storage; no capacity planning required |
| Amazon Cognito | JWT-based user identity for `GET /recommend` endpoint | Cognito User Pool, API Gateway JWT authorizer | FlutterFlow app (token issuance), API Gateway (authorizer) | Managed; scales with MAU count automatically |

## Technology Stack

The following table captures the full technology stack across all architecture layers, with the specific AWS service selected for each layer and the rationale for that choice.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Layer | Technology | Rationale |
|-------|------------|-----------|
| API / Edge | Amazon API Gateway (REST API) | Fully managed; native API key auth, usage plans, request validation, throttling, and CloudWatch integration without additional tooling |
| Compute | AWS Lambda Python 3.12 | Serverless; pay-per-invocation; Python ecosystem has mature `boto3` SDK for Bedrock, DynamoDB, and S3; cold-start latency acceptable at ANP's traffic volumes |
| AI / ML Inference | Amazon Bedrock (on-demand) — Anthropic Claude 3 Haiku or Amazon Titan Text G1 | Managed LLM inference with no model hosting overhead; Claude 3 Haiku provides strong instruction-following for structured JSON output from mood classification prompts; model finalized in Phase 1 accuracy benchmarking |
| Database | Amazon DynamoDB (on-demand mode) | Single-digit-millisecond latency for key-value lookups; pay-per-request billing proportional to ANP's launch-scale traffic; no capacity planning required; built-in PITR backup |
| Object Storage | Amazon S3 (Standard) | Industry-standard object store; native S3 event notification triggers Auto-Tagger Lambda on new uploads; SSE-S3 encryption by default; versioning for catalog change history |
| Identity / Auth | Amazon Cognito User Pool + API Gateway Authorizer | Managed JWT issuance and validation; integrates natively with API Gateway as a JWT authorizer; avoids exposing AWS credentials to FlutterFlow mobile client |
| Secrets Management | AWS Secrets Manager | Centralized, encrypted credential storage with automatic rotation support; Lambda functions retrieve secrets at runtime via SDK — no hardcoded credentials |
| Monitoring | Amazon CloudWatch (Logs, Metrics, Alarms, Dashboards) | Native AWS monitoring; zero additional agent installation; structured JSON Lambda logs enable Log Insights queries; Alarms integrate with SNS for email notifications |
| Infrastructure as Code | AWS CDK (TypeScript) or CloudFormation | Repeatable, version-controlled environment provisioning; CDK preferred for type safety and construct reuse; CloudFormation as fallback if CDK dependency management is a concern |
| Audit / Compliance | AWS CloudTrail | Account-level API activity logging for forensic and governance purposes; S3-backed with 90-day retention |

---

# Security & Compliance

The security architecture for the ANP Streaming AI Mood & Recommendation API follows the AWS Well-Architected Framework Security Pillar with a defense-in-depth approach. While ANP Streaming has no current regulatory compliance mandates (no HIPAA, PCI-DSS, or SOC 2 requirements at launch), the architecture is designed to meet standard commercial security expectations and to be extensible toward a future SOC 2 Type II assessment. Every security control described in this section maps directly to a commitment in the SOW Security & Compliance section.

## Identity & Access Management

Access to all AWS resources is governed by IAM roles and policies with strict least-privilege enforcement. No cross-function role sharing, no wildcard resource permissions, and no hardcoded credentials in Lambda code or environment variables are permitted.

- **Authentication (Human):** Named IAM users for nClouds engineers during the engagement, with MFA enforced on all accounts. Root account access is disabled for day-to-day operations and secured with a hardware MFA device.
- **Authentication (Service):** Lambda functions authenticate to AWS services via their assigned IAM execution roles, using temporary credentials issued automatically by the Lambda service. No long-lived access keys are used for service-to-service communication.
- **Authorization (API):** `POST /classify` is protected by API key authentication enforced at the API Gateway usage plan level. `GET /recommend` additionally validates a Cognito JWT via an API Gateway JWT authorizer, binding each recommendation request to an authenticated ANP Streaming user.
- **MFA:** Required for all named IAM users with console access, including the ANP Streaming administrator account provided at handover.
- **Service Accounts:** Firebase service account credentials are stored exclusively in AWS Secrets Manager; they are never embedded in Lambda environment variables, IaC templates, or source code.

### Role Definitions

The following IAM execution roles are provisioned for the Lambda functions and for human access. Each role's permissions are constrained to the minimum API actions required for that function's operation.

<!-- TABLE_CONFIG: widths=[20, 40, 40] -->
| Role | Permissions | Scope |
|------|-------------|-------|
| `anp-classifier-lambda-role` | `bedrock:InvokeModel`, `logs:CreateLogGroup`, `logs:CreateLogStream`, `logs:PutLogEvents`, `secretsmanager:GetSecretValue` | Bedrock (specified model ARN), CloudWatch log group (`/aws/lambda/anp-classifier`), Secrets Manager (Firebase key secret ARN) |
| `anp-recommender-lambda-role` | `dynamodb:Query`, `dynamodb:GetItem`, `dynamodb:PutItem`, `logs:CreateLogGroup`, `logs:CreateLogStream`, `logs:PutLogEvents` | DynamoDB tables `anp-catalog-moods` and `anp-user-history` only; CloudWatch log group (`/aws/lambda/anp-recommender`) |
| `anp-autotagger-lambda-role` | `s3:GetObject`, `bedrock:InvokeModel`, `dynamodb:PutItem`, `dynamodb:UpdateItem`, `logs:CreateLogGroup`, `logs:CreateLogStream`, `logs:PutLogEvents` | S3 bucket (`anp-catalog/` prefix only), Bedrock (specified model ARN), DynamoDB table `anp-catalog-moods`, CloudWatch log group |
| `anp-admin-iam-user` | Full AWS account access with MFA required for console login | ANP Streaming administrator account; provided at handover; all nClouds IAM users removed at project close |
| `anp-nclouds-dev-role` (engagement only) | Read/Write Dev environment resources; read-only Production CloudWatch | Time-limited to engagement duration; revoked at project closeout (end of Week 6) |
| Auditor (future) | Read-only across all resources | Reserved for future SOC 2 audit access; not provisioned in this engagement |

## Secrets Management

All sensitive credentials are stored in AWS Secrets Manager and retrieved by Lambda functions at runtime via the AWS SDK. No secrets are present in Lambda environment variables, CloudFormation/CDK template outputs, CloudWatch logs, or source code repositories.

- **Secrets stored:** Firebase service account key (JSON), any third-party API keys introduced during the engagement, Bedrock endpoint configuration (if custom endpoint required).
- **Rotation policy:** Quarterly automatic rotation is configured where the credential type supports automated rotation. Firebase service account credentials require manual rotation; rotation procedure is documented in the operational runbook.
- **Access logging:** All `GetSecretValue` API calls are captured in AWS CloudTrail and can be queried via CloudWatch Log Insights.

## Network Security

The solution uses AWS managed networking with no customer-managed VPC required. The following controls define the network security posture.

- **Segmentation:** Lambda functions run in the AWS-managed Lambda service VPC. API Gateway endpoints are public HTTPS. No customer-managed VPC subnets, security groups, or NACLs are provisioned for this engagement (all services are fully managed).
- **TLS Enforcement:** API Gateway enforces HTTPS-only; HTTP requests are rejected with a 403 response. TLS 1.2 is the minimum supported protocol version.
- **WAF:** AWS WAF is not included in this engagement scope. If ANP Streaming's user base grows or unauthorized access patterns are detected post-launch, WAF integration is recommended as a future enhancement.
- **DDoS Protection:** AWS Shield Standard (included at no additional cost with all AWS accounts) provides baseline DDoS protection for API Gateway endpoints. AWS Shield Advanced is out of scope for this engagement.
- **Input Validation:** API Gateway request models validate payload structure and content type before Lambda invocation, rejecting malformed requests at the API layer without consuming Lambda invocations.

## Data Protection

All data at rest and in transit is encrypted using AWS-managed or AWS-default encryption controls. No custom key management infrastructure is introduced at this engagement scope.

- **Encryption at Rest:** S3 catalog bucket uses SSE-S3 (AES-256) server-side encryption, applied automatically to all objects. DynamoDB tables use AWS-managed KMS keys for encryption at rest (enabled by default on all new DynamoDB tables). Lambda environment variables containing non-secret configuration are encrypted at rest using AWS-managed keys.
- **Encryption in Transit:** All API traffic uses HTTPS (TLS 1.2+). All AWS service-to-service communication (Lambda → Bedrock, Lambda → DynamoDB, Lambda → S3) traverses the AWS private network backbone using TLS.
- **Key Management:** AWS-managed keys (SSE-S3, AWS-managed KMS) are used throughout. Customer-managed KMS CMKs are not introduced at this engagement scale, but the architecture can be upgraded to CMKs without design changes.
- **Data Masking:** User listening history data (personally identifiable usage data) is not present in the Dev environment. Dev environment uses anonymized or synthetic test data only.

## Compliance Mappings

ANP Streaming has no current compliance mandates. The following table documents the security controls implemented and their alignment to the AWS Well-Architected Framework Security Pillar for reference.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Framework | Requirement | Implementation |
|-----------|-------------|----------------|
| AWS Well-Architected (Security) | Identity and access management | IAM least-privilege roles per Lambda; MFA on all human accounts; no wildcard permissions |
| AWS Well-Architected (Security) | Detection and logging | CloudTrail API activity logging; CloudWatch structured JSON Lambda logs; 90-day retention |
| AWS Well-Architected (Security) | Infrastructure protection | API key + JWT auth on all endpoints; input validation at API Gateway; HTTPS-only enforcement |
| AWS Well-Architected (Security) | Data protection | AES-256 SSE-S3 for S3; AWS KMS for DynamoDB; TLS 1.2+ for all transit; Secrets Manager for credentials |
| AWS Well-Architected (Security) | Incident response | CloudWatch Alarms → SNS email for error rate and latency thresholds; IaC rollback capability; PITR for DynamoDB |
| Future SOC 2 Type II | CC6.1 Logical access | IAM role-based access; named accounts; MFA; access revoked at engagement close |
| Future SOC 2 Type II | CC7.2 Monitoring | CloudWatch Logs + Alarms; CloudTrail audit log; 90-day retention |

## Audit Logging & SIEM Integration

Comprehensive audit logging is implemented across all layers of the architecture to support operational investigation and future compliance requirements.

- **AWS CloudTrail:** Enabled on the ANP Streaming AWS account, capturing all AWS API-level activity (console, CLI, SDK) for all services. CloudTrail logs are stored in a dedicated S3 bucket with 90-day retention. CloudTrail log integrity validation is enabled.
- **Lambda Structured Logs:** All Lambda functions emit structured JSON logs to dedicated CloudWatch log groups (`/aws/lambda/anp-classifier`, `/aws/lambda/anp-recommender`, `/aws/lambda/anp-autotagger`). Log retention is set to 90 days. Logs include request ID, user ID (for recommender), mood label, confidence score, and latency for every invocation.
- **API Gateway Access Logs:** API Gateway stage-level access logging is enabled, capturing caller IP, HTTP method, path, response code, and latency for all requests, including rejected requests (HTTP 401/403).
- **SIEM Integration:** A dedicated SIEM integration is not included in this engagement scope. If ANP Streaming adopts a SIEM platform in the future, CloudWatch log groups can be exported to the SIEM via CloudWatch subscription filters or Amazon Kinesis Data Firehose. Migration to Amazon GuardDuty and AWS Security Hub is recommended if the user base grows and a more sophisticated threat detection capability is required.

---

# Data Architecture

The data architecture for the ANP Streaming AI Mood & Recommendation API is designed around three logical tiers: catalog ingestion and enrichment, user listening history capture, and personalized recommendation retrieval. All persistent data is stored in two purpose-built Amazon DynamoDB tables and one Amazon S3 bucket. Amazon Bedrock produces mood classification outputs that flow from Lambda functions into DynamoDB, forming the enriched catalog index that powers the recommendation engine.

## Data Model

### Conceptual Model

The data model centers on two core domains: **Content** (songs and podcast episodes with mood classifications) and **Users** (authenticated ANP Streaming listeners with listening history). A Content item is enriched with one or more Mood labels and confidence scores, produced by Bedrock inference during catalog ingestion. A User accumulates a listening history of Content items, each timestamped. The Recommendation engine joins these two domains at query time to return a mood-filtered, history-personalized playlist for a given user.

### Logical Model

The following table defines the key entities, their attributes, relationships, and expected data volumes based on SOW scope parameters.

<!-- TABLE_CONFIG: widths=[20, 25, 30, 25] -->
| Entity | Key Attributes | Relationships | Volume |
|--------|----------------|---------------|--------|
| CatalogItem | `content_id` (PK), `title`, `artist`, `content_type` (song/podcast), `lyric_s3_key`, `mood_label`, `mood_confidence`, `tagged_at` | Stored in `anp-catalog-moods` DynamoDB table; S3 object referenced by `lyric_s3_key` | < 50,000 items at launch |
| UserHistory | `user_id` (PK), `played_at` (SK), `content_id`, `mood_label_at_play`, `ttl` | Stored in `anp-user-history` DynamoDB table; links User to CatalogItem via `content_id` | < 50,000 records at launch; 90-day TTL |
| MoodLabel | `label` (enum: Joyful, Reflective, Peaceful, Uplifting, Worshipful, Hopeful), `confidence_score` (float 0–1) | Attribute of CatalogItem; used as filter key in recommendation queries | Fixed vocabulary; finalized in Phase 1 |
| LyricTranscriptFile | `s3_key`, `content_type`, `file_size_bytes`, `upload_timestamp` | Stored in S3 `anp-catalog/` prefix; triggers Auto-Tagger Lambda on creation | < 50 GB total at launch |

#### DynamoDB Table: `anp-catalog-moods`

The catalog mood-tag index is the core lookup table for the recommendation engine. It is populated by the Auto-Tagger Lambda on new catalog uploads and queried by the Recommender Lambda to find content matching a requested mood label.

- **Partition Key:** `content_id` (String) — unique identifier for each song or podcast episode
- **Attributes:** `title` (String), `artist` (String), `content_type` (String: `song` | `podcast`), `mood_label` (String), `mood_confidence` (Number), `tagged_at` (String ISO-8601), `lyric_s3_key` (String)
- **Global Secondary Index (GSI):** `mood_label-index` — Partition Key: `mood_label`, Sort Key: `tagged_at` — enables efficient query of all content items with a specific mood label, sorted by recency of tagging
- **Billing Mode:** Pay-per-request (on-demand)
- **Encryption:** AWS-managed KMS key (default)
- **PITR:** Enabled (35-day continuous backup)

#### DynamoDB Table: `anp-user-history`

The user listening history table records each user's content consumption events. The Recommender Lambda writes a new record each time a user calls the recommendation endpoint (or when the FlutterFlow app signals a play event), and queries recent records to personalize the playlist.

- **Partition Key:** `user_id` (String) — Cognito sub claim from authenticated JWT
- **Sort Key:** `played_at` (String ISO-8601) — enables time-ordered queries for recent history
- **Attributes:** `content_id` (String), `mood_label_at_play` (String), `ttl` (Number UNIX timestamp) — 90-day TTL set on item write
- **Billing Mode:** Pay-per-request (on-demand)
- **Encryption:** AWS-managed KMS key (default)
- **PITR:** Enabled (35-day continuous backup)

## Data Flow Design

Data flows through the system in three distinct paths: catalog enrichment (asynchronous), on-demand classification (synchronous), and personalized recommendation (synchronous). Each path is described below.

**Catalog Enrichment Flow (Auto-Tagger):**

1. **Ingestion:** ANP Streaming uploads a lyric or transcript text file to the S3 bucket (`anp-catalog/<content_id>.txt`). This can be a bulk export from Firebase during project onboarding or individual uploads as new content is added to the catalog.
2. **Trigger:** S3 `ObjectCreated` event notification triggers the Auto-Tagger Lambda function with the S3 object key as the event payload.
3. **Classification:** The Auto-Tagger Lambda retrieves the text file from S3 (`GetObject`), constructs a structured Bedrock prompt requesting mood classification with a JSON output schema, and invokes the Bedrock foundation model.
4. **Storage:** The Lambda parses the Bedrock response, extracts the `mood_label` and `confidence_score`, and writes a `PutItem` to the `anp-catalog-moods` DynamoDB table using the `content_id` derived from the S3 object key.
5. **Distribution:** The enriched catalog item is immediately available for recommendation queries.

**On-Demand Classification Flow (`POST /classify`):**

1. **Ingestion:** The FlutterFlow app (or any API consumer) sends a `POST /classify` request to API Gateway with an API key in the `x-api-key` header and a JSON body containing `text` (the lyric or transcript) and optional `content_type`.
2. **Validation:** API Gateway validates the API key against the usage plan and validates the request body against the defined request model. Invalid requests are rejected with HTTP 400 or 403.
3. **Processing:** The Classifier Lambda is invoked synchronously. It constructs a Bedrock prompt from the `text` field and invokes the foundation model. The prompt instructs the model to return a JSON object with `mood_label` (one of the defined enum values) and `confidence_score` (float 0–1).
4. **Storage:** No data is written to DynamoDB for on-demand classification requests. The classification result is returned directly to the API caller.
5. **Distribution:** API Gateway returns HTTP 200 with the classification result JSON to the FlutterFlow app.

**Personalized Recommendation Flow (`GET /recommend`):**

1. **Ingestion:** The FlutterFlow app sends a `GET /recommend?mood=Peaceful` request to API Gateway with a Cognito JWT in the `Authorization: Bearer <token>` header.
2. **Validation:** API Gateway validates the JWT using the Cognito JWT authorizer. The `user_id` (Cognito sub claim) is extracted from the validated token and passed to the Lambda as a request context variable. Invalid or expired tokens return HTTP 401.
3. **Processing:** The Recommender Lambda queries the `anp-user-history` table for the user's last 20 play events (most recent first), extracts recently played `content_id` values to exclude from recommendations, then queries the `anp-catalog-moods` GSI (`mood_label-index`) for catalog items matching the requested mood label. Results are filtered to exclude recently played items and ranked by `mood_confidence` descending.
4. **Storage:** If the FlutterFlow app signals a play event via the recommend endpoint, the Lambda writes a new record to `anp-user-history`. (The exact listening history write mechanism is confirmed during Phase 1 API schema finalization.)
5. **Distribution:** API Gateway returns HTTP 200 with an ordered playlist array (list of `content_id`, `title`, `artist`, `mood_label`, `mood_confidence` objects) to the FlutterFlow app.

## Data Migration Strategy

This engagement includes a one-time catalog seed migration from Firebase to DynamoDB and S3. There is no ongoing real-time synchronization between Firebase and AWS; synchronization strategy is out of scope per the SOW.

- **Approach:** One-time bulk export during Phase 1 (Week 2). ANP Streaming provides a Firebase catalog export (CSV or JSON) containing `content_id`, `title`, `artist`, `content_type`, and lyric/transcript text. nClouds processes this export to populate S3 and seed `anp-catalog-moods` via an initial Auto-Tagger batch run.
- **Validation:** After seeding, nClouds will verify that the item count in `anp-catalog-moods` matches the source export row count, and that a sample of 20 items has valid `mood_label` and `mood_confidence` values above the 0.5 threshold.
- **Rollback:** The seed migration writes only to S3 and DynamoDB tables in the Dev environment initially. If data quality issues are identified, the tables can be truncated and the migration re-run after data quality remediation by ANP Streaming.
- **Cutover:** A second migration run is performed against the Production DynamoDB tables during Phase 3 Week 5 Production deployment, after the Dev seed has been validated.

## Data Governance

Data governance policies ensure that catalog and user data is handled appropriately throughout its lifecycle in the AWS environment.

- **Classification:** Catalog text (lyrics and transcripts) is classified as non-sensitive internal data. User listening history (`anp-user-history` records containing `user_id` and `content_id`) is classified as personally identifiable usage data, scoped exclusively to authenticated users via Cognito JWT validation and encrypted at rest.
- **Retention:** S3 catalog files are retained indefinitely (no S3 lifecycle policy at launch; ANP Streaming can add lifecycle transitions to S3 Infrequent Access or Glacier as the catalog grows). DynamoDB `anp-user-history` items are automatically deleted after 90 days using DynamoDB TTL on the `ttl` attribute. CloudWatch logs are retained for 90 days via log group retention policies.
- **Quality:** The Auto-Tagger Lambda applies a minimum confidence threshold check: items with `mood_confidence < 0.5` are written to DynamoDB with a `low_confidence` flag and excluded from recommendation queries by default. The threshold is configurable via Secrets Manager parameter.
- **Access:** `anp-user-history` data is accessible only to the Recommender Lambda (via its IAM role) and the ANP Streaming administrator account. No user history data is present in the Dev environment; Dev uses synthetic test user data only.

---

# Integration Design

The ANP Streaming AI Mood & Recommendation API integrates with three external systems: the Firebase catalog (read-only, one-time export), the FlutterFlow mobile app (primary API consumer), and Amazon Bedrock (AI inference service). All integrations use standard HTTPS REST or AWS SDK protocols with no proprietary middleware or ESB. The integration design is intentionally minimal, reflecting the focused two-endpoint scope of the engagement.

## External System Integrations

The following table documents each integration point, its protocol, data format, error handling strategy, and SLA target.

<!-- TABLE_CONFIG: widths=[18, 15, 15, 15, 22, 15] -->
| System | Type | Protocol | Format | Error Handling | SLA |
|--------|------|----------|--------|----------------|-----|
| FlutterFlow Mobile App | Real-time (synchronous) | HTTPS REST | JSON | API Gateway 4xx/5xx responses; Lambda error alarms; retry guidance in API docs | ≤ 2s p95 |
| Firebase Catalog (seed) | Batch (one-time) | S3 file upload / CSV export | CSV / JSON flat file | Re-runnable migration script; validation checks on row count and sample mood quality | One-time, Week 2 |
| Amazon Bedrock | Real-time (synchronous, internal) | AWS SDK (`boto3`) over HTTPS | JSON (Bedrock `InvokeModel` API) | Lambda retry on transient Bedrock throttling (`ThrottlingException`); DLQ for Auto-Tagger batch errors | Inherited from Lambda p95 target |
| Amazon DynamoDB | Real-time (synchronous, internal) | AWS SDK (`boto3`) | DynamoDB item JSON | Lambda SDK retries with exponential backoff on `ProvisionedThroughputExceededException` (not expected in on-demand mode) | < 10ms read/write latency |
| AWS Secrets Manager | On Lambda cold start | AWS SDK (`boto3`) | JSON secret value | Lambda initialization failure logged; CloudWatch alarm on Lambda error rate | < 50ms retrieval |

## API Design

The public REST API exposed via Amazon API Gateway consists of two endpoints defined in the SOW scope. The API follows REST conventions with JSON request and response bodies, API key authentication, and structured error responses.

- **Style:** REST (JSON over HTTPS)
- **Versioning:** URL path versioning — `/v1/classify`, `/v1/recommend`. The API Gateway stage is named `v1`.
- **Authentication:** API key (`x-api-key` header) for `POST /classify`; Cognito JWT (`Authorization: Bearer <token>` header) for `GET /recommend`.
- **Rate Limiting:** API Gateway usage plan enforces a rate limit of 100 requests/second and a burst limit of 200 requests on the API key, appropriate for the < 100 concurrent user launch target.
- **Content Type:** `application/json` required for all requests and responses.
- **Error Format:** All error responses return `{"error": "<code>", "message": "<human-readable description>"}` with the appropriate HTTP status code.

### API Endpoints

The following endpoints are in scope for this engagement. Request and response schemas are defined in detail in the API Reference Documentation deliverable (SOW Deliverable #17).

<!-- TABLE_CONFIG: widths=[10, 35, 20, 35] -->
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | /v1/classify | API Key (`x-api-key`) | Accepts `{"text": "<lyric or transcript>", "content_type": "song|podcast"}`. Returns `{"mood_label": "<label>", "confidence_score": <float>, "content_type": "<type>"}`. |
| GET | /v1/recommend | Cognito JWT (Bearer) | Accepts query params `mood=<label>` (required) and `limit=<int>` (optional, default 10, max 50). Returns `{"playlist": [{"content_id": "<id>", "title": "<title>", "artist": "<artist>", "mood_label": "<label>", "mood_confidence": <float>}]}`. |

**HTTP Status Codes:**

- `200 OK` — Successful classification or recommendation response
- `400 Bad Request` — Missing or invalid request body/parameters (e.g., empty `text` field, unsupported `mood` value)
- `401 Unauthorized` — Missing or invalid Cognito JWT on `/recommend`
- `403 Forbidden` — Missing or invalid API key on `/classify`; HTTP (non-HTTPS) request
- `404 Not Found` — Requested user has no listening history and no catalog items match the mood (cold-start empty response handled as `200` with empty playlist array, not 404)
- `429 Too Many Requests` — API Gateway usage plan rate limit exceeded
- `500 Internal Server Error` — Unhandled Lambda exception; triggers CloudWatch alarm

## Authentication & SSO Flows

The API uses two complementary authentication mechanisms to distinguish between catalog classification requests (keyed access, usable by the app or external developers) and user-personalized recommendation requests (user-identity-bound access).

- **API Key Flow (`POST /classify`):** The FlutterFlow app (or any authorized API consumer) includes a static API key in the `x-api-key` request header. The API key is provisioned in the API Gateway usage plan and stored securely in Secrets Manager. The API key is rotated quarterly and distributed to authorized consumers via the operational runbook procedure. Keys are never embedded in mobile app source code; they are retrieved from a backend configuration store managed by ANP Streaming.
- **Cognito JWT Flow (`GET /recommend`):** The FlutterFlow app authenticates the user via the existing Firebase Auth flow (unmodified). Additionally, the app obtains a Cognito JWT from the ANP Streaming Cognito User Pool using the user's identity. The JWT is included in the `Authorization: Bearer <token>` header. API Gateway validates the JWT signature and expiry using the Cognito User Pool JWKS endpoint as the authorizer. The validated `sub` claim (user ID) is passed to the Recommender Lambda as a context variable, requiring no additional lookup. JWT expiry is 1 hour; the FlutterFlow app is responsible for token refresh using the Cognito refresh token flow.
- **Service-to-Service Auth (Lambda → AWS Services):** Lambda functions authenticate to Bedrock, DynamoDB, S3, and Secrets Manager using temporary AWS credentials issued via their IAM execution roles. No API keys or long-lived credentials are used for internal AWS service calls.

## Messaging & Event Patterns

The Auto-Tagger pipeline uses asynchronous event-driven messaging to decouple catalog ingestion from mood classification processing.

- **Queue Service:** An Amazon SQS dead-letter queue (DLQ) is configured for the Auto-Tagger Lambda's S3 event notification trigger. If the Auto-Tagger Lambda fails to process an S3 event after 3 attempts, the failed event message is routed to the DLQ. A CloudWatch Alarm monitors the DLQ `ApproximateNumberOfMessagesVisible` metric and alerts via SNS email if messages accumulate, indicating a systematic tagging failure.
- **Event Bus:** S3 event notifications (not EventBridge) are used for the Auto-Tagger trigger, providing a direct, low-latency event delivery mechanism without the overhead of an event bus for this simple one-to-one trigger pattern.
- **Dead Letter Queue:** `anp-autotagger-dlq` — SQS standard queue. DLQ messages include the original S3 event payload, enabling manual reprocessing of failed items via the operational runbook procedure.
- **Retry Policy:** The Auto-Tagger Lambda's event source mapping is configured with a maximum retry count of 3 and a bisect-on-error policy. Transient Bedrock throttling errors (`ThrottlingException`) are handled inside the Lambda with exponential backoff (initial delay 1s, max delay 30s, 3 retries).

---

# Infrastructure & Operations

The infrastructure for the ANP Streaming AI Mood & Recommendation API is entirely serverless and managed by AWS. There are no EC2 instances, ECS clusters, RDS databases, or self-managed networking components in this design. The operational model is designed for ANP Streaming's small technical team, emphasizing low-touch monitoring via CloudWatch dashboards and alert-driven response documented in the operational runbook.

## Network Design

The solution is deployed within a single AWS region (us-east-1). All Lambda functions run within the AWS-managed Lambda service VPC by default. No customer-managed VPC, subnets, security groups, or NACLs are required, as all services (API Gateway, Lambda, Bedrock, DynamoDB, S3, Cognito, Secrets Manager) are fully managed AWS services with private backbone connectivity.

- **API Gateway Endpoint Type:** Regional (not edge-optimized or private). Exposes a public HTTPS endpoint at `https://<api-id>.execute-api.us-east-1.amazonaws.com/v1/`.
- **Lambda Networking:** Functions run in the managed Lambda service network. No VPC association is required; Lambda accesses DynamoDB, Bedrock, S3, and Secrets Manager via the AWS private network backbone using service endpoints.
- **DNS:** Default API Gateway domain is used at launch. A custom domain (e.g., `api.anpstreaming.com`) can be mapped via API Gateway custom domain names and Route 53 as a future enhancement; this is out of scope for the current engagement.
- **Internet Transit:** All traffic between the FlutterFlow mobile app and API Gateway transits over the public internet using TLS 1.2+. AWS Shield Standard provides baseline DDoS protection.

## Compute Sizing

All compute is AWS Lambda with no fixed instance provisioning. The following table documents the initial configuration for each Lambda function, based on expected traffic volumes from the SOW scope parameters (< 100 concurrent users, ~ 500K invocations/month).

<!-- TABLE_CONFIG: widths=[25, 20, 20, 20, 15] -->
| Component | Instance Type | vCPU (proportional) | Memory | Timeout |
|-----------|---------------|---------------------|--------|---------|
| Classifier Lambda (`anp-classifier`) | Lambda (managed) | 1x (1024 MB proportional) | 1024 MB | 30 seconds |
| Recommender Lambda (`anp-recommender`) | Lambda (managed) | 0.5x (512 MB proportional) | 512 MB | 15 seconds |
| Auto-Tagger Lambda (`anp-autotagger`) | Lambda (managed) | 0.5x (512 MB proportional) | 512 MB | 60 seconds |

**Notes:** Lambda memory allocation determines CPU allocation proportionally. The Classifier Lambda is allocated 1024 MB to reduce p95 latency from Bedrock cold-start effects. Lambda Power Tuning will be run during Phase 3 performance testing to validate or adjust these allocations. Provisioned concurrency for the Classifier Lambda may be introduced if p95 latency exceeds 2 seconds under performance testing at standard cold-start frequency.

## High Availability Design

The serverless architecture provides built-in high availability through AWS-managed multi-AZ infrastructure. No explicit HA configuration is required from the customer.

- **Multi-AZ:** AWS Lambda, API Gateway, DynamoDB, S3, Cognito, and Secrets Manager are all multi-AZ services by default in us-east-1. A single AZ failure does not interrupt service for any of these components.
- **Amazon Bedrock Availability:** Bedrock on-demand inference is a regional service managed by AWS with built-in multi-AZ resilience. Bedrock service disruptions are outside the solution's control; the operational runbook documents the monitoring and response procedure.
- **Failover Strategy:** Because all services are managed and multi-AZ, there is no customer-managed failover process. CloudWatch Alarms notify ANP Streaming of error rate increases or latency spikes that may indicate upstream service degradation.
- **Health Checks:** API Gateway integrates with Lambda via proxy integration; Lambda function errors automatically surface as 5xx responses at the API layer, triggering CloudWatch Alarms on the configured error rate threshold.

## Disaster Recovery

The disaster recovery posture is designed for the agreed RTO of 1 hour and RPO of 24 hours specified in the SOW operational design.

- **RPO: 24 hours** — DynamoDB PITR provides a continuous 35-day backup window at 5-minute granularity, exceeding the 24-hour RPO. S3 versioning provides catalog file version history. The RPO target is met by default.
- **RTO: 1 hour** — Lambda function code and infrastructure configuration are stored in IaC templates (CDK/CloudFormation) in version control. A full re-deployment of all Lambda functions, API Gateway configuration, and DynamoDB tables from scratch using `cdk deploy` is expected to complete within 15–30 minutes in a test performed in Phase 3. The 1-hour RTO target is achievable.
- **Backup:** DynamoDB PITR is enabled on both `anp-catalog-moods` and `anp-user-history` tables from initial provisioning. S3 bucket versioning is enabled on `anp-catalog/`. Lambda source code is stored in a GitHub repository and as deployment artifacts in S3 via the IaC pipeline.
- **DR Site:** Single-region deployment (us-east-1). Cross-region DR is out of scope for this engagement. The serverless architecture's IaC-based re-deployment provides acceptable recovery times for ANP Streaming's current user base without the cost of active-active cross-region deployment.

## Monitoring & Alerting

CloudWatch provides comprehensive monitoring across all layers of the solution. The following operational metrics and alert conditions are monitored in both Dev and Production environments.

- **Infrastructure Metrics:** Lambda invocation count, duration (p95, p99, max), error count, throttle count; API Gateway request count, 4xx count, 5xx count, latency (p95); DynamoDB consumed read/write capacity, throttled requests; S3 request metrics for the `anp-catalog/` prefix.
- **Application Metrics:** Bedrock token consumption (via Lambda custom metric published to CloudWatch); mood label distribution (custom metric for observability of classification output quality); cold-start frequency (Lambda `Init Duration` in logs).
- **Business Metrics:** Daily API invocation count (classification + recommendation); unique user IDs in recommendation requests (proxy for DAU); Auto-Tagger catalog item count (tracks catalog enrichment progress).
- **Alerting Channel:** All CloudWatch Alarms notify an SNS topic (`anp-ops-alerts`) configured with the ANP Streaming technical contact's email address and optionally a Slack webhook (if provided by ANP Streaming at handover).

### Alert Definitions

The following alerts are configured from initial deployment and documented in the operational runbook with investigation procedures for each.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Alert | Condition | Severity | Response |
|-------|-----------|----------|----------|
| Lambda Error Rate — Classifier | Error count > 1% of invocations in 5-minute window | Critical | Investigate CloudWatch Logs for exception type; check Bedrock service health; roll back if systemic |
| Lambda Error Rate — Recommender | Error count > 1% of invocations in 5-minute window | Critical | Investigate CloudWatch Logs; check DynamoDB throttling metrics; escalate to nClouds if in hypercare |
| API Gateway p95 Latency | p95 latency > 2 seconds in 5-minute window | High | Check Lambda duration metrics; assess Bedrock cold-start frequency; consider provisioned concurrency |
| API Gateway 5xx Rate | 5xx error count > 5 in 5-minute window | Critical | Immediate investigation of Lambda logs; check AWS Service Health Dashboard |
| Auto-Tagger DLQ Depth | SQS `ApproximateNumberOfMessagesVisible` > 0 | Medium | Investigate failed S3 event records in DLQ; re-process via runbook procedure |
| DynamoDB Throttled Requests | ThrottledRequests metric > 0 in 5-minute window | Medium | Review DynamoDB capacity metrics; switch to provisioned capacity if sustained throttling occurs |
| Bedrock Token Budget | Custom metric: monthly Bedrock token consumption > 180,000 tokens | Medium | Review classification request volume; check for runaway Auto-Tagger batch; assess cost impact |

## Logging & Observability

The observability stack is built entirely on CloudWatch, with structured logging standards enforced across all Lambda functions.

- **Log Format:** All Lambda functions emit structured JSON logs using Python's standard `logging` module with a JSON formatter. Each log entry includes: `timestamp`, `request_id`, `function_name`, `level`, `message`, and context-specific fields (e.g., `mood_label`, `confidence_score`, `user_id` (hashed), `bedrock_model`, `latency_ms`).
- **Log Aggregation:** Three dedicated CloudWatch log groups: `/aws/lambda/anp-classifier`, `/aws/lambda/anp-recommender`, `/aws/lambda/anp-autotagger`. Log group retention is set to 90 days. API Gateway access logs are delivered to `/aws/apigateway/anp-api-access-logs`.
- **Tracing:** AWS X-Ray tracing is enabled on Lambda functions and API Gateway stages to provide end-to-end request tracing across API Gateway → Lambda → Bedrock/DynamoDB. X-Ray service maps are used during Phase 3 performance testing to identify latency contributors.
- **Dashboards:** Two CloudWatch dashboards are provisioned: `ANP-Operations` (production monitoring: invocation counts, error rates, p95 latency, DLQ depth) and `ANP-Cost-Tracking` (Bedrock token consumption, API Gateway request volume, DynamoDB capacity units consumed). Dashboard JSON definitions are included in the IaC codebase.

## Cost Model

The following cost model is derived from the infrastructure-costs.csv model validated during presales. All costs are annual, based on the SOW scope parameters (~ 500K API invocations/month, ~ 200K Bedrock tokens/month, < 50 GB S3 storage, < 50K DynamoDB records).

<!-- TABLE_CONFIG: widths=[30, 25, 25, 20] -->
| Category | Annual Estimate | Optimization | Potential Savings |
|----------|-----------------|--------------|-------------------|
| Amazon Bedrock (inference) | $1,800 | Prompt compression to reduce token count; cache repeated classification results in DynamoDB | 10–20% |
| Amazon API Gateway | $420 | Migrate to HTTP API (vs REST API) for `/classify` if advanced features not needed | 30–40% |
| Amazon CloudWatch | $360 | Reduce log verbosity in steady state; archive logs to S3 Glacier after 30 days | 20–30% |
| Amazon S3 | $138 | Add S3 Intelligent-Tiering after 6 months to reduce storage cost on infrequently accessed transcripts | 20–30% |
| Amazon Cognito | $120 | No optimization required at < 5,000 MAU; costs remain proportional to user growth | — |
| AWS Secrets Manager | $60 | No optimization required; 5 secrets at minimal cost | — |
| Amazon DynamoDB | $3 | No optimization at launch volume; switch to provisioned capacity if access patterns stabilize at higher volume | — |
| AWS Lambda | $2 | Already at minimum; pay-per-invocation | — |
| AWS Developer Support | $348 | Upgrade to Business Support ($100/month minimum) when production SLA requirements tighten | — |
| **Total Annual (Year 1 List)** | **$3,251** | **AWS MAP Credit: −$1,500** | **Year 1 Net: $1,751** |

---

# Implementation Approach

The implementation follows the three-phase delivery approach defined in the SOW, spanning six weeks from engagement kickoff to hypercare commencement. The approach is designed to front-load risk — confirming data quality, Bedrock model accuracy, and API schema in Phase 1 before any production code is written — and to provide ANP Streaming with demonstrable working capabilities at the end of each phase.

## Migration/Deployment Strategy

Because this is a greenfield AWS backend (ANP Streaming has no existing AWS infrastructure to migrate), the deployment strategy focuses on iterative build-and-validate across the Dev environment, followed by a production promotion via IaC.

- **Approach:** Greenfield build — no existing AWS infrastructure to migrate; no legacy system to decommission. Firebase remains operational throughout and is not modified.
- **Pattern:** IaC stack-based deployment with Lambda versioning and aliases. Each Lambda function is deployed with a new published version on each update; the `LIVE` alias is updated to point to the new version after smoke tests pass. The previous version remains deployed and the alias can be reverted in under 5 minutes.
- **Validation:** Functional testing, performance testing, and security testing in the Dev environment (Phase 3 Weeks 5–6) before Production deployment is approved. UAT sign-off by ANP Streaming's technical contact is required before the Production deployment milestone.
- **Rollback:** Lambda alias rollback (< 5 minutes) for application-layer issues; `cdk destroy` + `cdk deploy` from previous IaC stack version for infrastructure-layer issues. DynamoDB PITR for data recovery if a schema migration causes data integrity issues.

## Sequencing & Wave Planning

The engagement is divided into three phases, each with defined activities, duration, and exit criteria. Exit criteria must be satisfied before the next phase begins.

<!-- TABLE_CONFIG: widths=[10, 30, 20, 40] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 — Discovery & Design | Kickoff; Firebase catalog review; API schema finalization; Bedrock model selection; Dev environment provisioning (IAM, S3, DynamoDB, Lambda scaffold, API Gateway, Secrets Manager); security baseline; catalog seed export | Weeks 1–2 | Discovery Summary Report accepted by Lilly Goyah; Dev AWS environment operational; Firebase catalog in S3; Bedrock model selected and accuracy-benchmarked on sample data; API schemas agreed with ANP technical contact |
| 2 — Build & Integrate | Classifier Lambda (Bedrock integration); Recommender Lambda (DynamoDB integration); Auto-Tagger Lambda (S3 trigger + Bedrock + DynamoDB); API Gateway routes + auth + throttling; CloudWatch dashboards + alarms; IaC finalization; DynamoDB seed data load | Weeks 3–4 | Both API endpoints operational in Dev; Auto-Tagger pipeline running on sample S3 uploads; CloudWatch monitoring active; IaC templates deploy both Dev and Production cleanly in dry-run |
| 3 — Validate & Hand Off | Functional testing; performance testing (Lambda Power Tuning + Artillery); security testing; UAT with ANP technical contact; Production deployment via IaC; API documentation; operational runbook; knowledge transfer session; hypercare commencement | Weeks 5–6 | All functional tests pass (≥ 95%); p95 latency ≤ 2s at 50 concurrent users; all security tests pass (100%); Bedrock accuracy ≥ 90% on labeled sample; Production live and callable from FlutterFlow; all handover artifacts accepted; hypercare period commenced |

## Tooling & Automation

The following tools and services are used across the engagement's engineering workstreams, selected for their alignment with AWS-native practices and ANP Streaming's post-handover self-sufficiency requirements.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Tool | Purpose |
|----------|------|---------|
| Infrastructure as Code | AWS CDK (TypeScript) | Primary IaC tool for all AWS resource provisioning; constructs for Lambda, API Gateway, DynamoDB, S3, Cognito, Secrets Manager, CloudWatch |
| IaC Fallback | AWS CloudFormation | Used if CDK dependency environment is a constraint; CloudFormation templates generated from CDK `cdk synth` |
| Lambda Runtime | Python 3.12 + `boto3` | Lambda function runtime; `boto3` for AWS SDK calls to Bedrock, DynamoDB, S3, Secrets Manager |
| Bedrock Prompt Development | AWS Console + Bedrock Playground | Phase 1 prompt prototyping and accuracy benchmarking for mood classification |
| Performance Testing | AWS Lambda Power Tuning + Artillery | Lambda memory sizing optimization and API load testing for p95 latency validation |
| Source Control | GitHub (or AWS CodeCommit if GitHub is unavailable) | Lambda function source code and IaC codebase version control |
| CI/CD (optional) | AWS CodePipeline + CodeBuild | Optional automated deployment pipeline for Lambda function updates; documented in runbook for ANP self-service |
| Testing Framework | pytest (Python) + Postman/Newman | Functional test suite for Lambda unit tests; API endpoint integration tests |
| Security Testing | AWS IAM Policy Simulator + manual API tests | IAM role scope validation; API authentication and authorization test cases |
| Project Management | Linear / Jira (TBD by nClouds PM) | Task tracking, milestone management, and defect tracking during the engagement |

## Cutover Approach

The Production deployment follows a planned cutover process using IaC, timed to occur during ANP business hours in Week 5 after all Dev validation is complete.

- **Type:** Phased cutover — Deploy infrastructure first (DynamoDB, S3, Lambda functions, API Gateway), then run smoke tests, then provide API key and endpoint URL to ANP technical contact for FlutterFlow configuration.
- **Duration:** Estimated 2–3 hours for the full cutover process, including smoke tests and FlutterFlow API endpoint update.
- **Validation:** 10 representative API calls are executed against the Production API Gateway URL immediately after deployment (smoke test suite in Phase 3 test plan). CloudWatch dashboards and alarms are confirmed active before handing over the Production API key.
- **Decision Point:** Go/no-go confirmed by Jonas Bull and ANP technical contact after smoke tests pass. Lilly Goyah (CEO) provides final executive go-live approval per the SOW.

## Downtime Expectations

- **Planned Downtime:** Zero planned downtime for end users. The new API is a greenfield addition to the ANP Streaming backend; the FlutterFlow app is only updated to call the new endpoints after the Production API is live and validated. Firebase continues to serve the app throughout with no interruption.
- **Unplanned Downtime:** MTTR target of 1 hour, consistent with the RTO defined in the SOW. Lambda alias rollback (< 5 minutes) handles application-layer failures; IaC re-deployment (< 30 minutes) handles infrastructure-layer failures.
- **Mitigation:** CloudWatch Alarms provide early warning of error rate or latency degradation. Lambda function versioning enables rapid rollback. The operational runbook documents step-by-step investigation and recovery procedures for all monitored alert conditions.

## Rollback Strategy

A clear rollback procedure is defined for each layer of the solution, with a maximum rollback window of 30 minutes from trigger to recovery for application-layer issues.

- **Infrastructure Rollback:** If a CDK/CloudFormation stack deployment fails mid-update, CloudFormation automatically rolls back to the previous stable stack state. No manual intervention is required for infrastructure-layer rollback.
- **Application Rollback:** Lambda function `LIVE` alias is updated to point to the previous published version using `aws lambda update-alias`. This completes in under 2 minutes and requires no redeployment. API Gateway integration continues to point to the `LIVE` alias, making the rollback transparent to API consumers.
- **Database Rollback:** DynamoDB schema is not expected to change after Production deployment. If a data integrity issue is caused by a Lambda bug (e.g., incorrect mood label format), the affected records are corrected using a targeted Lambda batch correction script documented in the runbook. DynamoDB PITR is available as a last-resort data recovery option.
- **Rollback Trigger:** > 10% Lambda error rate or p95 latency > 5 seconds persisting for 10 minutes in Production. Jonas Bull notifies Lilly Goyah immediately; root cause analysis delivered within 24 hours.
- **Maximum Rollback Window:** 30 minutes from rollback trigger to restored service for application-layer issues; 60 minutes for infrastructure-layer issues requiring IaC re-deployment.

---

# Appendices

The appendices provide supporting reference material for the ANP Streaming AI Mood & Recommendation API detailed design. These materials are intended for use by the nClouds engineering team during implementation and by ANP Streaming's technical team during post-handover operations.

## Architecture Diagrams

The following diagrams support the architecture described in Section 4 and are referenced throughout this document.

- **Solution Architecture Diagram** — Included in Section 4 above (`../../assets/diagrams/architecture-diagram.png`); illustrates end-to-end component layout and data flows for all three Lambda functions, API Gateway, Bedrock, DynamoDB, S3, Cognito, CloudWatch, and Secrets Manager.
- **Data Flow Diagram** — Described in Section 6 (Data Architecture → Data Flow Design); illustrates the three data flow paths: Catalog Enrichment (Auto-Tagger), On-Demand Classification (`POST /classify`), and Personalized Recommendation (`GET /recommend`).
- **Security Architecture Diagram** — Described in Section 5 (Security & Compliance); illustrates IAM role boundaries, authentication flows (API key, Cognito JWT), and encryption controls across the solution.

## Naming Conventions

All AWS resource names follow the pattern `anp-<component>-<environment>` to ensure consistent identification across Dev and Production. The following table defines the naming standard for each resource type.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Resource Type | Pattern | Example |
|---------------|---------|---------|
| Lambda Function | `anp-<function>-<env>` | `anp-classifier-prod`, `anp-recommender-dev` |
| API Gateway REST API | `anp-api-<env>` | `anp-api-prod` |
| API Gateway Stage | `v1` | `v1` (both Dev and Production) |
| DynamoDB Table | `anp-<table>-<env>` | `anp-catalog-moods-prod`, `anp-user-history-dev` |
| DynamoDB GSI | `<attribute>-index` | `mood_label-index` |
| S3 Bucket | `anp-catalog-<account-id>-<env>` | `anp-catalog-123456789012-prod` |
| Cognito User Pool | `anp-users-<env>` | `anp-users-prod` |
| Secrets Manager Secret | `anp/<env>/<secret-name>` | `anp/prod/firebase-service-account` |
| CloudWatch Log Group | `/aws/lambda/anp-<function>` | `/aws/lambda/anp-classifier` |
| CloudWatch Dashboard | `ANP-<purpose>` | `ANP-Operations`, `ANP-Cost-Tracking` |
| CloudWatch Alarm | `anp-<metric>-<threshold>-<env>` | `anp-classifier-error-rate-1pct-prod` |
| SQS DLQ | `anp-<function>-dlq-<env>` | `anp-autotagger-dlq-prod` |
| IAM Role | `anp-<function>-lambda-role` | `anp-classifier-lambda-role` |
| CDK/CloudFormation Stack | `ANP<Component><Env>Stack` | `ANPApiProdStack`, `ANPDataDevStack` |

## Tagging Standards

All AWS resources provisioned by the IaC templates are tagged with the following mandatory tags to support cost allocation, governance, and future compliance audit requirements.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Tag | Required | Example Values |
|-----|----------|----------------|
| `Project` | Yes | `ANPStreamingAI` |
| `Environment` | Yes | `dev`, `prod` |
| `Owner` | Yes | `nclouds`, `anp-streaming` (post-handover) |
| `CostCenter` | Yes | `OPP-2025-001` |
| `ManagedBy` | Yes | `cdk`, `cloudformation` |
| `Version` | Recommended | `1.0`, `1.1` (IaC stack version) |

## Risk Register

The following risk register documents the key technical and operational risks identified during presales and design, with likelihood, impact, and mitigation strategy for each. These risks are monitored throughout the engagement by the nClouds Project Manager and reviewed at each phase gate.

<!-- TABLE_CONFIG: widths=[30, 15, 15, 40] -->
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Bedrock mood-classification accuracy falls below 90% on faith-based content | Medium | Critical | Phase 1 accuracy benchmarking on a 50–100 item labeled sample before Phase 2 build begins; Bedrock prompt engineering iteration in Phase 1; alternative foundation model evaluation if primary model underperforms |
| Firebase catalog export is delayed, incomplete, or missing lyric/transcript text | Medium | High | Dependency confirmed in SOW; ANP Streaming must deliver export by Week 2 Day 1; synthetic test data generated by nClouds if export is delayed to unblock Phase 2 development |
| API p95 latency exceeds 2 seconds due to Bedrock cold-start | Medium | High | Lambda Power Tuning in Phase 3 to optimize memory allocation; provisioned concurrency applied to Classifier Lambda if cold-start frequency is identified as the latency driver; prompt compression to reduce token count |
| AWS partner funding approval delayed, impacting invoicing timeline | Low | Medium | nClouds submits funding application in Week 1 in parallel with Phase 1 activities; engagement timeline is not gated on funding approval per SOW Assumption 7 |
| FlutterFlow app cannot make outbound HTTPS calls to external API Gateway endpoint | Low | Critical | Confirmed as ANP Streaming assumption in SOW; must be validated in Week 1; FlutterFlow's HTTP request widget supports external HTTPS REST APIs by design; escalation path to FlutterFlow support if not |
| DynamoDB GSI query performance degrades as catalog scales beyond launch volume | Low | Medium | GSI on `mood_label-index` is designed for efficient mood-filtered queries; if catalog exceeds 100K items, DynamoDB Accelerator (DAX) or DynamoDB export to S3 for analytical queries can be introduced as a future enhancement |
| Amazon Bedrock on-demand rate limits cause throttling at peak concurrent usage | Low | Medium | Bedrock on-demand is suitable for < 100 concurrent users; if throttling occurs, implement Bedrock provisioned throughput for the Production Classifier Lambda; document in runbook |
| ANP technical contact unavailability delays UAT sign-off and Production go-live | Medium | Medium | SOW stipulates 4 hours/week availability; UAT scheduled in advance in Week 5; if delayed, 1-week timeline buffer exists before the Week 6 hypercare end target |
| IaC stack deployment failure in Production during cutover | Low | High | IaC templates fully validated in Dev environment before Production deployment; CloudFormation automatic rollback on stack failure; 30-minute rollback window documented in cutover plan |
| Bedrock foundation model deprecated or unavailable in us-east-1 during engagement | Very Low | High | Model availability confirmed in Week 1 as a SOW assumption; if deprecated mid-engagement, migration to an alternative Bedrock model requires only a prompt and model ID update in the Classifier Lambda; no architectural change required |

## Glossary

The following glossary defines acronyms and technical terms used throughout this document for readers who may be less familiar with AWS managed service terminology.

<!-- TABLE_CONFIG: widths=[25, 75] -->
| Term | Definition |
|------|------------|
| API Gateway | Amazon API Gateway — AWS managed service for creating, publishing, and securing REST, HTTP, and WebSocket APIs |
| Bedrock | Amazon Bedrock — AWS managed service providing access to foundation models (LLMs) via API for text classification, generation, and summarization |
| CDK | AWS Cloud Development Kit — open-source framework for defining AWS infrastructure as code using TypeScript, Python, Java, or .NET |
| Cognito | Amazon Cognito — AWS managed service for user authentication, authorization, and identity management; issues JWTs for authenticated users |
| DAX | DynamoDB Accelerator — AWS managed in-memory cache for DynamoDB, providing microsecond read latency for high-throughput workloads |
| DLQ | Dead Letter Queue — SQS queue that receives messages that could not be processed after the configured number of retries |
| DynamoDB | Amazon DynamoDB — AWS managed NoSQL key-value and document database with single-digit-millisecond latency |
| DynamoDB PITR | DynamoDB Point-in-Time Recovery — continuous backup capability enabling table restoration to any second within the last 35 days |
| GSI | Global Secondary Index — secondary index on a DynamoDB table enabling queries on non-primary-key attributes |
| IAM | AWS Identity and Access Management — service for managing permissions and access control to AWS resources |
| IaC | Infrastructure as Code — practice of defining and provisioning infrastructure using version-controlled code files (CDK/CloudFormation templates) |
| JWT | JSON Web Token — compact, URL-safe means of representing authentication claims; issued by Cognito and validated by API Gateway |
| Lambda | AWS Lambda — serverless compute service that runs code in response to events without requiring server provisioning |
| LLM | Large Language Model — a foundation model trained on large text corpora, capable of natural language understanding and generation (e.g., Anthropic Claude, Amazon Titan Text) |
| MAU | Monthly Active Users — billing unit for Amazon Cognito User Pool pricing |
| MFA | Multi-Factor Authentication — authentication requiring a second verification factor beyond a password |
| PITR | See DynamoDB PITR |
| p95 | 95th percentile — the value below which 95% of observations fall; used as the API latency measurement standard in this engagement |
| RTO | Recovery Time Objective — the maximum acceptable time to restore service after a disruptive event |
| RPO | Recovery Point Objective — the maximum acceptable amount of data loss measured in time after a disruptive event |
| S3 | Amazon Simple Storage Service — AWS managed object storage service |
| Secrets Manager | AWS Secrets Manager — managed service for storing, rotating, and auditing access to secrets (API keys, database passwords, service account credentials) |
| SNS | Amazon Simple Notification Service — managed pub/sub messaging service used for CloudWatch alarm notifications |
| SOW | Statement of Work — contractual document defining engagement scope, deliverables, timeline, and commercial terms |
| SSE-S3 | Server-Side Encryption with S3-Managed Keys (AES-256) — default encryption for S3 objects |
| SQS | Amazon Simple Queue Service — managed message queuing service; used for the Auto-Tagger Lambda DLQ |
| TLS | Transport Layer Security — cryptographic protocol for securing network communications; TLS 1.2+ is required for all API traffic |
| TTL | DynamoDB Time to Live — attribute-based item expiration mechanism; used to automatically delete `anp-user-history` records after 90 days |
| UAT | User Acceptance Testing — structured testing performed by ANP Streaming's technical contact to validate that the delivered system meets functional and integration requirements |
| WAF | AWS Web Application Firewall — managed service for protecting web applications from common exploits; out of scope for this engagement |
| X-Ray | AWS X-Ray — distributed tracing service providing end-to-end request visibility across Lambda functions and API Gateway |
