---
document_title: Implementation Guide
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

## Project Overview

This Implementation Guide provides the authoritative step-by-step procedures for deploying the ANP Streaming AI Recommendation Engine — a fully serverless, API-first, AWS-native AI/ML platform delivering emotion-based music and podcast discovery to ANP Streaming's global faith community audience. The guide translates all commitments made in the Statement of Work (SOW) dated March 19, 2026 into executable procedures that the nClouds delivery team and ANP Streaming's technical team can follow from project kickoff through operational handover.

The ANP Streaming AI Recommendation Engine is a greenfield build consisting of five interacting ML capability domains: a Content Intelligence pipeline (NLP and audio classification), a Catalog Enrichment service (ingest-time metadata writing), a Recommendation Engine (preference learning and playlist generation), an API Service Layer (five secured REST endpoints for the FlutterFlow mobile application), and an Operational Control Plane (CloudWatch monitoring, automated retraining, and incident response). The entire platform is deployed into Dev and Staging AWS environments within a 13-week engagement window.

## Implementation Scope

- **In Scope:**
  - AWS architecture design and infrastructure provisioning for Dev and Staging environments in us-east-1
  - NLP emotion/mood/theme classifier and audio feature extraction pipeline (Amazon SageMaker, Amazon Comprehend, Amazon Bedrock)
  - Catalog enrichment service triggered at artist upload time (Lambda, Step Functions, EventBridge)
  - Amazon Personalize preference-learning model and mood-to-content matching algorithm
  - Playlist generation service (Lambda) with session context and feedback-signal integration
  - Automated model retraining pipeline (SageMaker Pipelines)
  - REST API Service Layer: five endpoints secured via Amazon Cognito JWT and AWS WAF
  - Data architecture: DynamoDB tables, S3 buckets, OpenSearch catalog index, ElastiCache session caching
  - Operational runbooks, CloudWatch dashboards, alarms, and two knowledge-transfer sessions

- **Out of Scope:**
  - Firebase data migration execution (catalog data accessed via Firebase REST API)
  - Mobile frontend development or any modification to the FlutterFlow application
  - Production environment deployment and go-live cutover (deferred to a future phase)
  - Ongoing managed services or post-hypercare operational support
  - Third-party data integrations (Spotify, Apple Music, or external music databases)
  - Formal compliance certifications (SOC 2, HIPAA, PCI-DSS)

- **Dependencies:**
  - ANP Streaming provides a dedicated AWS account with admin credentials to nClouds within 3 business days of the effective date
  - AWS Partner Funding Portal (APFP) approval of $25,000 confirmed before billable work commences
  - ANP provides representative lyric/transcript samples (minimum 50 items) in Week 1
  - Firebase catalog REST API access and mood-tagging schema shared before the requirements workshop
  - ANP CEO (Lilly Goyah) available for deliverable reviews within 3 business days of delivery

## Timeline Overview

- **Project Duration:** 13 weeks (Effective Date: March 19, 2026)
- **Go-Live Date:** End of Week 13 (Final Deliverable Package acceptance); production deployment by ANP team post-engagement
- **Key Milestones:**
  - M1 — Project Kickoff: Week 1
  - M2 — Architecture Approved (Phase 1 Complete): Week 4
  - M3 — Content Intelligence Live: Week 8
  - M4 — Recommendation Engine Live: Week 11
  - M5 — API Layer Live: Week 12
  - M6 — End-to-End Validated: Week 13
  - M7 — Handover Complete: Week 13

---

# Prerequisites

## Technical Prerequisites

Complete all items in this section before starting Phase 1 activities. Items marked with `[ ]` are mandatory gates; the project kickoff meeting will verify completion status.

### Cloud Infrastructure

- [ ] ANP Streaming dedicated AWS account created with Account ID confirmed and shared with nClouds project manager
- [ ] AWS administrator access provisioned for nClouds delivery team via named IAM users or federated SSO roles with MFA enforcement
- [ ] AWS Activate Founders enrollment submitted to apply the $2,500 infrastructure credit to Year 1 consumption
- [ ] AWS Business Support Plan activated on the ANP Streaming account ($100/month)
- [ ] Resource quotas verified in us-east-1 for SageMaker instances (ml.t3.medium × 2, ml.m5.xlarge × 1), ElastiCache nodes, and OpenSearch nodes
- [ ] AWS CDK Toolkit bootstrapped in the target account: `cdk bootstrap aws://[account-id]/us-east-1`
- [ ] AWS CodePipeline source repository connected (Git repository with admin access granted to CodeBuild service role)
- [ ] Billing alerts configured at $500/month threshold via CloudWatch Billing Alarm

### Network Connectivity

- [ ] VPC CIDR block `10.10.0.0/16` available (no overlapping CIDR in existing account)
- [ ] Internet Gateway and NAT Gateway quota confirmed (1 EIP available per AZ)
- [ ] VPC Gateway Endpoint quotas available for S3 and DynamoDB in us-east-1
- [ ] VPC Interface Endpoint quotas available for SageMaker Runtime, Secrets Manager, SQS, and Step Functions

### Security Baseline

- [ ] Root account MFA enabled and root credentials secured per AWS best practices
- [ ] AWS CloudTrail management-event trail manually enabled in us-east-1 as a pre-CDK baseline (CDK will take over management)
- [ ] Amazon GuardDuty activated in the ANP Streaming account
- [ ] AWS Config enabled with basic managed rules (CDK will deploy full rule set)
- [ ] AWS IAM Access Analyzer enabled in us-east-1

### Development Tools

- [ ] AWS CLI v2 installed and configured on nClouds engineer workstations with profile `anp-delivery`
- [ ] AWS CDK v2 (Python) installed: `npm install -g aws-cdk` and `pip install aws-cdk-lib constructs`
- [ ] Python 3.11 installed (Lambda runtime and CDK application language)
- [ ] Docker installed for building Lambda container images and SageMaker custom containers
- [ ] Git repository initialized with branch strategy (main, develop, feature/*)
- [ ] Postman workspace created for API contract validation
- [ ] AWS Artillery or Locust installed for load testing

## Organizational Prerequisites

- [ ] Project team assigned and available per the RACI matrix in the SOW
- [ ] nClouds project manager confirmed (Jonas Bull — Solution Architect / Pre-Sales Lead)
- [ ] ANP CEO (Lilly Goyah) confirmed as executive sponsor and primary deliverable acceptance signatory
- [ ] ANP Technical Lead confirmed as application/workload owner and AWS account administrator post-engagement
- [ ] Budget approved: $25,000 professional services (net $0 after APFP credit) + AWS infrastructure consumption charges
- [ ] AWS Partner Funding Portal (APFP) application submitted and approval confirmed
- [ ] Communication plan activated: weekly status reports, Slack channel `#anp-ai-delivery` established, sprint cadence agreed
- [ ] Change management process documented: formal Change Request process per SOW Section 8 activated

## Environmental Setup

### Development Environment

- [ ] ANP Streaming AWS account (dedicated) confirmed with Admin access
- [ ] Dev environment CDK context file `cdk.context.json` created with `solution.environment=dev`
- [ ] Developer IAM users provisioned for nClouds engineers with MFA enforced
- [ ] CodePipeline source repository connected to `develop` branch for Dev environment
- [ ] CloudWatch log groups pre-created with 30-day retention for Dev (CDK will enforce)

### Staging Environment

- [ ] Staging environment CDK context file created with `solution.environment=staging`
- [ ] Staging deployment wired to `main` branch via CodePipeline promotion gate
- [ ] Staging mirrors Dev architecture exactly (same CDK stack, different parameter values)
- [ ] ANP Technical Lead granted full Staging access; ANP CEO granted read access for deliverable review
- [ ] Anonymized/masked catalog sample prepared for Staging (no real user PII in non-production environments)

### Firebase Integration Prerequisites

- [ ] Firebase project credentials (service account JSON) created and ready for Secrets Manager ingestion
- [ ] Firebase REST API base URL confirmed: `https://anp-streaming-default-rtdb.firebaseio.com`
- [ ] Firebase catalog schema documented by ANP Technical Lead and shared with nClouds before the requirements workshop
- [ ] Minimum 50 representative lyric/transcript file samples exported from Firebase and delivered to nClouds in Week 1

---

# Environment Setup

## Phase 1: Discovery & Architecture Planning (Weeks 1–4)

### Objectives

- Conduct project kickoff, requirements workshop, and current-state assessment of Firebase/FlutterFlow
- Design complete AWS architecture, define mood taxonomy (≥ 10 labels), and produce data schema package
- Deliver investor-ready tiered AWS cost model (100, 10K, 100K MAU) and risk register
- Provision Dev and Staging AWS environments as CDK-managed infrastructure stacks

### Activities

The table below lists all Phase 1 activities, owners, durations, and dependencies.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Project kickoff meeting: stakeholder alignment and delivery cadence | nClouds PM | 1 day | AWS account access confirmed |
| APFP funding confirmation and onboarding | nClouds PM | 2 days | SOW signature |
| Requirements workshop: mood taxonomy, classification goals, API contract objectives | nClouds Arch + ANP CEO/Tech Lead | 2 days | Firebase schema shared |
| Current-state assessment: Firebase catalog schema, FlutterFlow call patterns | nClouds Eng + ANP Tech Lead | 3 days | Firebase REST API access |
| AWS multi-service architecture design | nClouds Arch | 3 days | Requirements workshop complete |
| Mood taxonomy definition (≥ 10 emotion/mood/worship-style labels) | nClouds Arch + ANP CEO | 2 days | Requirements workshop |
| Data schema package: user preference vectors, content metadata, mood taxonomy | nClouds Arch + Eng | 2 days | Architecture design |
| Tiered AWS cost model (100 / 10K / 100K MAU) | nClouds Arch + PM | 1 day | Architecture design |
| Risk register creation | nClouds PM + Arch | 1 day | Requirements workshop |
| Dev + Staging environment CDK provisioning | nClouds Eng | 3 days | Architecture approved |

### Detailed Procedures

#### 1.1 Environment Provisioning — Dev Environment

The following procedure provisions the Dev AWS environment using the CDK infrastructure stack.

```bash
# Clone the delivery repository
git clone https://github.com/anp-streaming/ai-recommendation-engine.git
cd ai-recommendation-engine

# Install CDK Python dependencies
pip install -r requirements.txt

# Configure AWS CLI profile
aws configure --profile anp-delivery
# AWS Access Key ID: [nClouds engineer IAM user key]
# AWS Secret Access Key: [nClouds engineer IAM user secret]
# Default region: us-east-1

# Bootstrap CDK in the ANP AWS account (run once per account/region)
cdk bootstrap aws://[account-id]/us-east-1 --profile anp-delivery

# Navigate to infrastructure directory
cd infrastructure/environments/dev

# Synthesize and review CDK stack before deploy
cdk synth --context environment=dev --profile anp-delivery

# Deploy Dev environment (VPC, security groups, KMS, DynamoDB, S3, EventBridge)
cdk deploy AnpDevFoundationStack --context environment=dev \
  --profile anp-delivery \
  --require-approval never

# Deploy Dev compute stack (SageMaker endpoints, Lambda functions, API Gateway)
cdk deploy AnpDevComputeStack --context environment=dev \
  --profile anp-delivery \
  --require-approval never

# Capture stack outputs for downstream configuration
aws cloudformation describe-stacks \
  --stack-name AnpDevFoundationStack \
  --query 'Stacks[0].Outputs' \
  --profile anp-delivery \
  --output json > outputs/dev-foundation-outputs.json

echo "Dev environment provisioned successfully."
```

**Expected Output:**

```
✅  AnpDevFoundationStack

Outputs:
AnpDevFoundationStack.VpcId = vpc-0abc123def456789
AnpDevFoundationStack.PrivateSubnetAppAz1 = subnet-0111aaabbbccc
AnpDevFoundationStack.ContentCatalogTableName = anp-dev-content-catalog
AnpDevFoundationStack.UserProfileTableName = anp-dev-user-profiles
AnpDevFoundationStack.FeedbackQueueUrl = https://sqs.us-east-1.amazonaws.com/123456789/anp-dev-feedback-capture

Stack ARN: arn:aws:cloudformation:us-east-1:123456789:stack/AnpDevFoundationStack/...
```

#### 1.2 Firebase Credentials Ingestion into Secrets Manager

Before any Lambda function can read the Firebase REST API, the Firebase service account credentials must be stored in AWS Secrets Manager.

```bash
# Create Firebase credentials secret (replace with actual service account JSON content)
aws secretsmanager create-secret \
  --name anp-dev-firebase-credentials \
  --description "Firebase service account credentials for ANP Streaming catalog read access" \
  --secret-string file://config/firebase-service-account-dev.json \
  --kms-key-id alias/anp-dev-catalog \
  --profile anp-delivery \
  --region us-east-1

# Verify secret creation
aws secretsmanager describe-secret \
  --secret-id anp-dev-firebase-credentials \
  --profile anp-delivery \
  --query '{Name:Name,ARN:ARN,RotationEnabled:RotationEnabled}'
```

#### 1.3 Mood Taxonomy Initial Load

The Phase 1 taxonomy definition must be loaded into the `anp-dev-mood-taxonomy` DynamoDB table before classifier training commences.

```python
# scripts/load_mood_taxonomy.py
import boto3
import json

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('anp-dev-mood-taxonomy')

taxonomy_labels = [
    {"label_id": "EMO-001", "label_name": "Peaceful", "category": "emotion",
     "description": "Content evoking calm, stillness, and inner peace",
     "annotation_guidelines": "Select when lyrics emphasize rest, quiet, and divine presence"},
    {"label_id": "EMO-002", "label_name": "Joyful", "category": "emotion",
     "description": "Content evoking celebration, gladness, and gratitude",
     "annotation_guidelines": "Select when lyrics express praise, thanksgiving, or celebration"},
    {"label_id": "EMO-003", "label_name": "Hopeful", "category": "emotion",
     "description": "Content conveying trust in future outcomes and perseverance",
     "annotation_guidelines": "Select for forward-looking lyric themes of promise and redemption"},
    {"label_id": "EMO-004", "label_name": "Sorrowful", "category": "emotion",
     "description": "Content expressing grief, lament, or longing",
     "annotation_guidelines": "Select for lament psalms and honest expressions of pain"},
    {"label_id": "EMO-005", "label_name": "Reverent", "category": "emotion",
     "description": "Content marked by deep awe, holy fear, and reverence before the divine",
     "annotation_guidelines": "Select for solemn worship and awe-based lyric themes"},
    {"label_id": "MOO-001", "label_name": "Contemplative", "category": "mood",
     "description": "Meditative, introspective, and reflective listening mood",
     "annotation_guidelines": "Slower tempo; lyric depth over energy"},
    {"label_id": "MOO-002", "label_name": "Uplifting", "category": "mood",
     "description": "Energising, motivating mood for active engagement",
     "annotation_guidelines": "Higher energy; celebratory lyric themes"},
    {"label_id": "MOO-003", "label_name": "Comforting", "category": "mood",
     "description": "Soothing, reassuring mood for times of difficulty",
     "annotation_guidelines": "Gentle tempo; themes of God's presence in suffering"},
    {"label_id": "WOR-001", "label_name": "Contemporary Worship", "category": "worship_style",
     "description": "Modern worship production style with electronic/band instrumentation",
     "annotation_guidelines": "Post-2000 production; recognizable contemporary worship structure"},
    {"label_id": "WOR-002", "label_name": "Traditional Hymn", "category": "worship_style",
     "description": "Classic hymn structure with traditional instrumentation",
     "annotation_guidelines": "Pre-1980 compositional style or direct hymn arrangements"},
    {"label_id": "WOR-003", "label_name": "Gospel", "category": "worship_style",
     "description": "African-American gospel tradition with call-and-response patterns",
     "annotation_guidelines": "Gospel choir arrangements, bluesy progressions, responsive lyrics"},
]

with table.batch_writer() as batch:
    for label in taxonomy_labels:
        label['version'] = '1.0'
        batch.put_item(Item=label)

print(f"Loaded {len(taxonomy_labels)} taxonomy labels into anp-dev-mood-taxonomy")
```

```bash
# Execute taxonomy load
python scripts/load_mood_taxonomy.py

# Verify: scan the table and confirm item count
aws dynamodb scan \
  --table-name anp-dev-mood-taxonomy \
  --select COUNT \
  --profile anp-delivery \
  --output text
# Expected: Count: 11
```

### Deliverables

- [ ] Dev environment fully provisioned (all CDK stacks deployed successfully)
- [ ] Staging environment fully provisioned
- [ ] Firebase credentials stored in Secrets Manager for both environments
- [ ] Mood taxonomy loaded into DynamoDB reference table (≥ 10 labels, CEO-approved)
- [ ] Phase 1 Architecture and Design Package (SOW Deliverable 9) accepted by Lilly Goyah
- [ ] CI/CD pipeline deploying to Dev on `develop` branch commits

### Success Criteria

- All CDK stacks deploy with zero CloudFormation errors
- VPC subnets, security groups, and VPC Gateway Endpoints validate via `aws ec2 describe-vpcs`
- DynamoDB tables exist with PITR enabled and KMS encryption configured
- S3 buckets exist with versioning enabled and lifecycle policies attached
- Taxonomy table contains ≥ 10 approved labels
- AWS Trusted Advisor and Security Hub show no critical findings post-provisioning

---

## Phase 2: Content Intelligence Development (Weeks 3–8)

### Objectives

- Build and deploy NLP emotion/mood/theme classifier on SageMaker
- Build audio feature extraction pipeline for valence, energy, and worship-style analysis
- Deploy catalog enrichment service triggered at artist upload time
- Validate classifier accuracy ≥ 90% on holdout test set

### Activities

The table below summarises all Phase 2 activities, owners, durations, and dependencies.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Finalize emotion/mood label set and annotation guidelines | nClouds Arch + ANP CEO | 1 day | Taxonomy from Phase 1 |
| Lyric/transcript NLP pre-processing pipeline (Comprehend + tokenization) | nClouds ML Eng | 3 days | Sample files from ANP |
| Fine-tune and deploy NLP emotion/mood/theme classifier on SageMaker | nClouds ML Eng | 5 days | NLP pipeline |
| Audio feature extraction pipeline (SageMaker audio endpoint) | nClouds ML Eng | 4 days | S3 raw-catalog bucket |
| Catalog enrichment Lambda + Step Functions orchestration | nClouds Eng | 3 days | Both classifier endpoints |
| EventBridge trigger and catalog enrichment integration | nClouds Eng | 2 days | Enrichment Lambda |
| Pilot classification run (10% catalog sample for accuracy validation) | nClouds QA | 2 days | Enrichment service |
| Full bulk enrichment run (full existing Firebase catalog) | nClouds Eng | 2 days | Accuracy validated |
| Unit and integration testing of all Phase 2 components | nClouds QA | 3 days | All Phase 2 components |

### Detailed Procedures

#### 2.1 SageMaker NLP Classifier Deployment

The following procedure deploys the fine-tuned NLP classifier to the Dev SageMaker endpoint.

```bash
# Upload training data to S3 (lyric/transcript annotated samples)
aws s3 sync data/training/nlp/ \
  s3://[anp-dev-models]/training/nlp/ \
  --profile anp-delivery

# Submit SageMaker training job
aws sagemaker create-training-job \
  --training-job-name anp-dev-nlp-classifier-$(date +%Y%m%d%H%M) \
  --algorithm-specification TrainingInputMode=File,TrainingImage=[ecr-nlp-container-uri] \
  --role-arn arn:aws:iam::[account-id]:role/anp-dev-sagemaker-training-role \
  --input-data-config '[{"ChannelName":"training","DataSource":{"S3DataSource":{"S3Uri":"s3://[anp-dev-models]/training/nlp/","S3DataType":"S3Prefix"}}}]' \
  --output-data-config S3OutputPath=s3://[anp-dev-models]/output/nlp/ \
  --resource-config InstanceType=ml.m5.xlarge,InstanceCount=1,VolumeSizeInGB=30 \
  --stopping-condition MaxRuntimeInSeconds=3600 \
  --enable-managed-spot-training \
  --checkpoint-config S3Uri=s3://[anp-dev-models]/checkpoints/nlp/ \
  --profile anp-delivery

# Wait for training job completion
aws sagemaker wait training-job-completed-or-stopped \
  --training-job-name [training-job-name] \
  --profile anp-delivery

# Deploy the trained model to SageMaker endpoint
aws sagemaker create-endpoint-config \
  --endpoint-config-name anp-dev-nlp-classifier-config-v1 \
  --production-variants '[{"VariantName":"primary","ModelName":"anp-dev-nlp-classifier-v1","InstanceType":"ml.t3.medium","InitialInstanceCount":1}]' \
  --profile anp-delivery

aws sagemaker create-endpoint \
  --endpoint-name anp-dev-nlp-classifier-endpoint \
  --endpoint-config-name anp-dev-nlp-classifier-config-v1 \
  --profile anp-delivery

# Wait for endpoint to be in service
aws sagemaker wait endpoint-in-service \
  --endpoint-name anp-dev-nlp-classifier-endpoint \
  --profile anp-delivery

echo "NLP Classifier endpoint is InService."
```

#### 2.2 Catalog Enrichment Validation (Pilot Run)

The following script samples enriched catalog items and prints classification results for human accuracy review.

```python
# scripts/validate_enrichment_pilot.py
import boto3
import json
import random

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('anp-dev-content-catalog')

# Sample 10% of enriched catalog items
response = table.scan(Limit=50, FilterExpression='attribute_exists(emotion_scores)')
enriched_items = response['Items']

for item in random.sample(enriched_items, min(20, len(enriched_items))):
    classifier_label = max(item['emotion_scores'], key=item['emotion_scores'].get)
    print(f"Item: {item['title']} | Classifier: {classifier_label} | Confidence: {max(item['emotion_scores'].values()):.2f}")

print(f"\nPilot enrichment validated: {len(enriched_items)} items enriched in pilot batch.")
print("Proceed to full bulk run if accuracy >= 90% on holdout set.")
```

### Deliverables

- [ ] NLP Emotion/Mood/Theme Classifier deployed on SageMaker endpoint (Dev) — SOW Deliverable 11
- [ ] Audio Feature Extraction Pipeline deployed — SOW Deliverable 12
- [ ] Catalog Enrichment Service deployed and triggered at upload time — SOW Deliverable 13
- [ ] Internal Classification Endpoint tested end-to-end — SOW Deliverable 14
- [ ] Classifier accuracy ≥ 90% validated on holdout test set

### Success Criteria

- NLP classifier endpoint is `InService` and returns JSON emotion score vector within 2 seconds
- Audio feature extractor returns valence, energy, and worship-style vectors for a sample audio file
- Catalog enrichment Step Functions executes end-to-end in < 60 seconds per catalog item
- Pilot accuracy on 10% holdout sample ≥ 90% before bulk enrichment commences

---

## Phase 3: Recommendation Engine Development (Weeks 6–11)

### Objectives

- Deploy Amazon Personalize dataset group, campaign, and event tracker
- Build and deploy mood-to-content matching algorithm (SageMaker endpoint)
- Build playlist generation Lambda with session context and feedback signal integration
- Deploy SageMaker Pipelines weekly retraining workflow

### Activities

The table below summarises all Phase 3 activities, owners, durations, and dependencies.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| DynamoDB user preference vector schema and ingestion paths | nClouds Eng | 2 days | Phase 2 content catalog complete |
| Amazon Personalize dataset group, schema, and dataset creation | nClouds ML Eng | 2 days | DynamoDB interaction events table |
| Personalize campaign training and deployment | nClouds ML Eng | 3 days | Dataset group created |
| Mood-to-content matching algorithm (SageMaker endpoint) | nClouds ML Eng | 4 days | Content catalog with emotion_scores |
| Playlist generation Lambda service | nClouds Eng | 3 days | Personalize campaign + mood matcher |
| SageMaker Pipelines retraining workflow | nClouds ML Eng | 2 days | Personalize + preference model |
| Cold-start fallback strategy implementation | nClouds Eng | 1 day | Mood-to-content matcher |
| Unit and integration testing of all Phase 3 components | nClouds QA | 3 days | All Phase 3 components |

### Detailed Procedures

#### 3.1 Amazon Personalize Setup

The following script creates the Personalize dataset group and interactions schema for the preference-learning model.

```python
# scripts/setup_personalize.py
import boto3

personalize = boto3.client('personalize', region_name='us-east-1')

# Create dataset group
response = personalize.create_dataset_group(
    name='anp-dev-recommendation-dataset-group',
    tags=[
        {'tagKey': 'Environment', 'tagValue': 'dev'},
        {'tagKey': 'Application', 'tagValue': 'anp-recommendation-engine'},
    ]
)
dataset_group_arn = response['datasetGroupArn']
print(f"Dataset Group ARN: {dataset_group_arn}")

# Create interactions schema
interactions_schema = {
    "type": "record",
    "name": "Interactions",
    "namespace": "com.amazonaws.personalize.schema",
    "fields": [
        {"name": "USER_ID", "type": "string"},
        {"name": "ITEM_ID", "type": "string"},
        {"name": "TIMESTAMP", "type": "long"},
        {"name": "EVENT_TYPE", "type": "string"},
        {"name": "EVENT_VALUE", "type": ["null", "float"], "default": None}
    ],
    "version": "1.0"
}

schema_response = personalize.create_schema(
    name='anp-dev-interactions-schema',
    schema=str(interactions_schema)
)
print(f"Schema ARN: {schema_response['schemaArn']}")
```

```bash
# After Personalize training completes, store campaign ARN in Parameter Store
aws ssm put-parameter \
  --name /anp/dev/personalize/campaign_arn \
  --value "[personalize-campaign-arn]" \
  --type SecureString \
  --profile anp-delivery
```

#### 3.2 Playlist Generation Lambda — Local Test

The following commands test the playlist generation Lambda locally using SAM CLI before deploying to AWS.

```bash
# Test playlist generation Lambda locally using SAM CLI
cd functions/playlist-generator

# Invoke with a test event
sam local invoke PlaylistGeneratorFunction \
  --event events/test-playlist-request.json \
  --env-vars env.json \
  --docker-network anp-dev-local

# Expected response structure:
# {
#   "statusCode": 200,
#   "body": {
#     "playlist_id": "pl-...",
#     "tracks": [...],
#     "generated_at": "...",
#     "source": "personalize"
#   }
# }
```

### Deliverables

- [ ] User Preference Vector DynamoDB Schema and ingestion paths — SOW Deliverable 15
- [ ] Preference-Learning Model deployed on SageMaker / Personalize — SOW Deliverable 16
- [ ] Mood-to-Content Matching Algorithm deployed — SOW Deliverable 17
- [ ] Playlist Generation Service deployed — SOW Deliverable 18
- [ ] Automated Model Retraining Pipeline (SageMaker Pipelines) — SOW Deliverable 19

### Success Criteria

- Personalize campaign returns ranked recommendation list for a test user with ≥ 5 interactions
- Cold-start fallback returns a mood-matched playlist for a new user with zero interaction history
- Playlist generation Lambda responds within ≤ 2 seconds for a cached request and ≤ 5 seconds on cache miss (load-test target: ≤ 2s p95 under 100 MAU)
- Retraining pipeline executes end-to-end in Staging without errors

---

## Phase 4: API Service Layer Development (Weeks 9–12)

### Objectives

- Deploy API Gateway, Lambda authorizers, Cognito User Pool, and WAF rules
- Implement all five REST API endpoints with authentication and security hardening
- Deliver complete OpenAPI/Swagger contract documentation

### Activities

The table below summarises all Phase 4 activities, owners, durations, and dependencies.

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| REST API contract documentation (OpenAPI/Swagger) | nClouds Arch + Eng | 2 days | Phase 3 complete |
| API Gateway configuration + Lambda authorizer | nClouds Eng | 2 days | Cognito User Pool |
| Cognito User Pool and user role provisioning | nClouds Eng | 1 day | Security design |
| AWS WAF v2 rules (CRS, Known Bad Inputs, IP Reputation) | nClouds Eng | 1 day | API Gateway deployed |
| Five endpoint Lambda implementations | nClouds Eng | 5 days | All backend services |
| Feedback-capture SQS + EventBridge integration | nClouds Eng | 2 days | Preference Update Lambda |
| Secrets Manager integration for Firebase credentials | nClouds Eng | 1 day | All Lambdas |
| API security hardening review | nClouds Eng + QA | 2 days | All endpoints deployed |

### Detailed Procedures

#### 4.1 Cognito User Pool Creation

The following commands create the Cognito User Pool and configure groups for the three ANP Streaming user roles.

```bash
# Create Cognito User Pool for ANP Streaming
aws cognito-idp create-user-pool \
  --pool-name anp-dev-user-pool \
  --policies '{"PasswordPolicy":{"MinimumLength":8,"RequireUppercase":true,"RequireLowercase":true,"RequireNumbers":true,"RequireSymbols":false}}' \
  --mfa-configuration OPTIONAL \
  --user-pool-tags Environment=dev,Application=anp-recommendation-engine \
  --profile anp-delivery \
  --region us-east-1

# Create App Client for FlutterFlow
aws cognito-idp create-user-pool-client \
  --user-pool-id [user-pool-id] \
  --client-name anp-flutterflow-client \
  --no-generate-secret \
  --explicit-auth-flows ALLOW_USER_SRP_AUTH ALLOW_REFRESH_TOKEN_AUTH \
  --access-token-validity 60 \
  --token-validity-units '{"AccessToken":"minutes","RefreshToken":"days"}' \
  --refresh-token-validity 30 \
  --profile anp-delivery

# Create user groups for each role
for group in listener artist admin; do
  aws cognito-idp create-group \
    --user-pool-id [user-pool-id] \
    --group-name $group \
    --description "ANP Streaming ${group} role" \
    --profile anp-delivery
done
```

#### 4.2 API Gateway WAF Association

The following commands create the WAF WebACL with the three required managed rule groups and associate it with the API Gateway stage.

```bash
# Create WAF WebACL with managed rule groups
aws wafv2 create-web-acl \
  --name anp-dev-api-waf \
  --scope REGIONAL \
  --default-action Allow={} \
  --rules '[
    {"Name":"AWSManagedRulesCoreRuleSet","Priority":1,"OverrideAction":{"None":{}},"Statement":{"ManagedRuleGroupStatement":{"VendorName":"AWS","Name":"AWSManagedRulesCoreRuleSet"}},"VisibilityConfig":{"SampledRequestsEnabled":true,"CloudWatchMetricsEnabled":true,"MetricName":"CoreRuleSet"}},
    {"Name":"AWSManagedRulesKnownBadInputsRuleSet","Priority":2,"OverrideAction":{"None":{}},"Statement":{"ManagedRuleGroupStatement":{"VendorName":"AWS","Name":"AWSManagedRulesKnownBadInputsRuleSet"}},"VisibilityConfig":{"SampledRequestsEnabled":true,"CloudWatchMetricsEnabled":true,"MetricName":"KnownBadInputs"}},
    {"Name":"AWSManagedRulesAmazonIpReputationList","Priority":3,"OverrideAction":{"None":{}},"Statement":{"ManagedRuleGroupStatement":{"VendorName":"AWS","Name":"AWSManagedRulesAmazonIpReputationList"}},"VisibilityConfig":{"SampledRequestsEnabled":true,"CloudWatchMetricsEnabled":true,"MetricName":"IpReputation"}}
  ]' \
  --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=true,MetricName=anp-dev-waf \
  --region us-east-1 \
  --profile anp-delivery

# Associate WAF with API Gateway stage
aws wafv2 associate-web-acl \
  --web-acl-arn [waf-arn] \
  --resource-arn arn:aws:apigateway:us-east-1::/restapis/[api-id]/stages/dev \
  --region us-east-1 \
  --profile anp-delivery
```

### Deliverables

- [ ] REST API Documentation — All Five Endpoint Contracts (SOW Deliverable 20)
- [ ] API Service Layer deployed with all five endpoints — SOW Deliverable 21

### Success Criteria

- All five endpoints return expected responses to Postman collection tests
- Authentication bypass (invalid JWT, expired JWT, missing header) returns HTTP 401
- WAF blocks SQL injection test payload (`' OR 1=1--`) with HTTP 403
- API rate throttling enforces 100 rps limit (test with burst of 150 rps)
- No HIGH or CRITICAL Security Hub findings after deployment

---

# Infrastructure Deployment

The infrastructure is deployed in four logical layers — Networking, Security, Compute, and Monitoring — each provisioned as a separate CDK stack to allow independent updates and rollback. All four layers must be deployed successfully before application-level configuration begins. The deployment follows the CDK stack dependency chain: Networking → Security → Compute → Monitoring.

## Networking

The Networking layer establishes the VPC, subnets, NAT Gateways, VPC Gateway Endpoints, and VPC Interface Endpoints that underpin all private communication within the platform.

### Components

The following table lists all networking components provisioned in this layer.

| Component | Resource Type | Configuration | Environment |
|-----------|--------------|---------------|-------------|
| ANP VPC | AWS VPC | CIDR 10.10.0.0/16, DNS resolution enabled | Dev + Staging |
| Public Subnet AZ1 | AWS Subnet | 10.10.1.0/24, us-east-1a | Dev + Staging |
| Public Subnet AZ2 | AWS Subnet | 10.10.2.0/24, us-east-1b | Dev + Staging |
| Private App Subnet AZ1 | AWS Subnet | 10.10.11.0/24, us-east-1a | Dev + Staging |
| Private App Subnet AZ2 | AWS Subnet | 10.10.12.0/24, us-east-1b | Dev + Staging |
| Private Data Subnet AZ1 | AWS Subnet | 10.10.21.0/24, us-east-1a | Dev + Staging |
| Private Data Subnet AZ2 | AWS Subnet | 10.10.22.0/24, us-east-1b | Dev + Staging |
| NAT Gateway | AWS NAT GW | 1 instance in Public Subnet AZ1 | Dev + Staging |
| Internet Gateway | AWS IGW | Attached to VPC | Dev + Staging |
| VPC GW Endpoint — S3 | Gateway Endpoint | Route tables: private app + data subnets | Dev + Staging |
| VPC GW Endpoint — DynamoDB | Gateway Endpoint | Route tables: private app + data subnets | Dev + Staging |
| VPC Interface Endpoint — SageMaker Runtime | Interface Endpoint | Private App subnets | Dev + Staging |
| VPC Interface Endpoint — Secrets Manager | Interface Endpoint | Private App subnets | Dev + Staging |
| VPC Interface Endpoint — SQS | Interface Endpoint | Private App subnets | Dev + Staging |
| VPC Interface Endpoint — Step Functions | Interface Endpoint | Private App subnets | Dev + Staging |

### Script Location

All networking CDK constructs are defined in `infrastructure/stacks/anp_networking_stack.py`. The CDK context configuration file is `infrastructure/cdk.json`. Environment-specific values are in `infrastructure/config/dev.yaml` and `infrastructure/config/staging.yaml`.

### Deployment Steps

The following steps deploy the Networking stack to the target environment.

```bash
# Step 1: Validate the CDK networking stack synthesis
cd infrastructure
cdk synth AnpNetworkingStack --context environment=dev --profile anp-delivery

# Step 2: Review the synthesized CloudFormation template
cat cdk.out/AnpNetworkingStack.template.json | python -m json.tool | grep -i "cidr\|subnet\|endpoint"

# Step 3: Deploy the Networking stack
cdk deploy AnpNetworkingStack \
  --context environment=dev \
  --profile anp-delivery \
  --require-approval never \
  --outputs-file outputs/dev-networking-outputs.json

# Step 4: Verify VPC creation
VPC_ID=$(cat outputs/dev-networking-outputs.json | python -c "import sys,json; d=json.load(sys.stdin); print(d['AnpNetworkingStack']['VpcId'])")
aws ec2 describe-vpcs --vpc-ids $VPC_ID --profile anp-delivery

# Step 5: Verify VPC Gateway Endpoints
aws ec2 describe-vpc-endpoints \
  --filters Name=vpc-id,Values=$VPC_ID \
  --query 'VpcEndpoints[].{Type:VpcEndpointType,Service:ServiceName,State:State}' \
  --profile anp-delivery
```

### Validation

Execute the following checks to confirm the Networking stack is functioning correctly.

```bash
# Validate subnet routing (private subnets should route to NAT GW, not IGW)
aws ec2 describe-route-tables \
  --filters Name=vpc-id,Values=$VPC_ID \
  --query 'RouteTables[?!Associations[0].Main].{SubnetId:Associations[0].SubnetId,Routes:Routes[*].{Destination:DestinationCidrBlock,Target:GatewayId}}' \
  --profile anp-delivery

# Validate VPC Gateway Endpoints are available
aws ec2 describe-vpc-endpoints \
  --filters Name=vpc-id,Values=$VPC_ID Name=state,Values=available \
  --query 'VpcEndpoints[].ServiceName' \
  --profile anp-delivery
# Expected output: com.amazonaws.us-east-1.s3 and com.amazonaws.us-east-1.dynamodb
```

### Success Criteria

- VPC with CIDR 10.10.0.0/16 exists and is in `available` state
- All 6 subnets (2 public, 2 private app, 2 private data) are in `available` state
- VPC Gateway Endpoints for S3 and DynamoDB are in `available` state
- VPC Interface Endpoints for SageMaker Runtime, Secrets Manager, SQS, and Step Functions are in `available` state
- Private subnets route outbound internet traffic through the NAT Gateway (not IGW)
- NAT Gateway is in `available` state with an Elastic IP allocated

### Rollback

If the Networking stack deployment fails or produces incorrect routing, use the following commands to revert.

```bash
# Rollback to previous successful CloudFormation state
aws cloudformation cancel-update-stack \
  --stack-name AnpNetworkingStack \
  --profile anp-delivery

# If stack is in ROLLBACK_COMPLETE or DELETE_FAILED, force destroy and redeploy
cdk destroy AnpNetworkingStack \
  --context environment=dev \
  --profile anp-delivery \
  --force

# Re-deploy from scratch after resolving the issue
cdk deploy AnpNetworkingStack \
  --context environment=dev \
  --profile anp-delivery
```

---

## Security

The Security layer deploys KMS Customer Managed Keys, IAM roles, Cognito User Pool, AWS WAF WebACL, AWS Secrets Manager secrets (placeholders), CloudTrail trail, GuardDuty detector, IAM Access Analyzer, and AWS Config with managed rules.

### Components

The following table lists all security components provisioned in this layer.

| Component | Resource Type | Configuration | Environment |
|-----------|--------------|---------------|-------------|
| KMS CMK — Catalog | AWS KMS Key | Annual rotation, alias: anp-{env}-catalog | Dev + Staging |
| KMS CMK — User Data | AWS KMS Key | Annual rotation, alias: anp-{env}-user-data | Dev + Staging |
| KMS CMK — Model Artifacts | AWS KMS Key | Annual rotation, alias: anp-{env}-model-artifacts | Dev + Staging |
| Cognito User Pool | Amazon Cognito | Listener, artist, admin groups; JWT 60-min expiry | Dev + Staging |
| Cognito App Client | Cognito App Client | FlutterFlow integration; no client secret | Dev + Staging |
| WAF WebACL | AWS WAF v2 | CRS + KnownBadInputs + IPReputation rules | Dev + Staging |
| IAM Role — Playlist Lambda | AWS IAM Role | Scoped to DynamoDB, Personalize, ElastiCache, SageMaker | Dev + Staging |
| IAM Role — Enrichment Lambda | AWS IAM Role | Scoped to SageMaker, S3, DynamoDB, Secrets Manager | Dev + Staging |
| IAM Role — Authorizer Lambda | AWS IAM Role | Scoped to Cognito User Pool GetUser | Dev + Staging |
| IAM Role — Feedback Lambda | AWS IAM Role | Scoped to SQS SendMessage only | Dev + Staging |
| IAM Role — SageMaker Training | AWS IAM Role | Scoped to S3 models bucket, ECR, CloudWatch | Dev + Staging |
| CloudTrail Trail | AWS CloudTrail | Management events + S3 data events; Object Lock | Dev + Staging |
| GuardDuty Detector | Amazon GuardDuty | HIGH/CRITICAL findings → SNS | Dev + Staging |
| IAM Access Analyzer | AWS IAM Access Analyzer | Account scope | Dev + Staging |
| AWS Config | AWS Config | Managed rules: encryption, MFA, CloudTrail, backups | Dev + Staging |
| Secrets Manager — Firebase Creds | AWS Secrets Manager | 90-day rotation; KMS encrypted | Dev + Staging |

### Script Location

Security CDK constructs are in `infrastructure/stacks/anp_security_stack.py`. IAM policy documents are in `infrastructure/iam_policies/`. KMS key policies are inline in the CDK stack. WAF rule definitions are in `infrastructure/waf/waf_rules.py`.

### Deployment Steps

The following steps deploy the Security stack, which depends on the Networking stack outputs.

```bash
# Step 1: Confirm Networking stack outputs are available
cat outputs/dev-networking-outputs.json | python -m json.tool

# Step 2: Synthesize the Security stack
cdk synth AnpSecurityStack \
  --context environment=dev \
  --profile anp-delivery

# Step 3: Deploy the Security stack
cdk deploy AnpSecurityStack \
  --context environment=dev \
  --profile anp-delivery \
  --require-approval never \
  --outputs-file outputs/dev-security-outputs.json

# Step 4: Store KMS CMK IDs in Parameter Store for reference by other stacks
CATALOG_CMK=$(cat outputs/dev-security-outputs.json | python -c "import sys,json; d=json.load(sys.stdin); print(d['AnpSecurityStack']['CatalogCmkId'])")
aws ssm put-parameter \
  --name /anp/dev/kms/catalog_cmk_id \
  --value $CATALOG_CMK \
  --type String \
  --profile anp-delivery

# Step 5: Load Firebase credentials into Secrets Manager
aws secretsmanager put-secret-value \
  --secret-id anp-dev-firebase-credentials \
  --secret-string file://config/firebase-service-account-dev.json \
  --profile anp-delivery
```

### Validation

Run the following commands to confirm all security resources are correctly deployed and active.

```bash
# Verify KMS keys exist and rotation is enabled
for alias in anp-dev-catalog anp-dev-user-data anp-dev-model-artifacts; do
  KEY_ID=$(aws kms describe-key --key-id alias/$alias --query 'KeyMetadata.KeyId' --output text --profile anp-delivery)
  ROTATION=$(aws kms get-key-rotation-status --key-id $KEY_ID --query 'KeyRotationEnabled' --output text --profile anp-delivery)
  echo "$alias: KeyId=$KEY_ID RotationEnabled=$ROTATION"
done

# Verify Cognito User Pool groups exist
aws cognito-idp list-groups \
  --user-pool-id [user-pool-id] \
  --query 'Groups[].GroupName' \
  --profile anp-delivery
# Expected: ["admin", "artist", "listener"]

# Verify CloudTrail is logging
aws cloudtrail get-trail-status \
  --name anp-dev-cloudtrail \
  --query '{IsLogging:IsLogging,LatestDeliveryTime:LatestDeliveryTime}' \
  --profile anp-delivery

# Verify GuardDuty is enabled
aws guardduty list-detectors \
  --query 'DetectorIds' \
  --profile anp-delivery
```

### Success Criteria

- All three KMS CMKs are in `ENABLED` state with `KeyRotationEnabled=true`
- Cognito User Pool contains groups: `listener`, `artist`, `admin`
- WAF WebACL is associated with the API Gateway stage
- CloudTrail is actively logging (IsLogging=true)
- GuardDuty detector exists and is in `ENABLED` state
- AWS Config is recording with the following managed rules active: `encrypted-volumes`, `cloudtrail-enabled`, `dynamodb-pitr-enabled`, `s3-bucket-server-side-encryption-enabled`
- IAM Access Analyzer reports zero active findings

### Rollback

If the Security stack must be reverted, use the following procedure. Note the KMS key deletion warning before proceeding with a destructive rollback.

```bash
# Rollback the Security stack to the previous version
aws cloudformation cancel-update-stack \
  --stack-name AnpSecurityStack \
  --profile anp-delivery

# For a complete re-deploy, destroy and redeploy
cdk destroy AnpSecurityStack \
  --context environment=dev \
  --profile anp-delivery \
  --force

# WARNING: Destroying this stack schedules KMS keys for 7-day deletion.
# Ensure all encrypted data backups are accessible before executing a destructive rollback.
```

---

## Compute

The Compute layer deploys all compute resources: SageMaker endpoints (NLP classifier and audio feature extractor), Lambda functions (playlist generator, catalog enrichment, authorizer, feedback capture, preference update), API Gateway REST API, Amazon Personalize campaign, OpenSearch Service cluster, and ElastiCache Redis cluster.

### Components

The following table lists all compute components provisioned in this layer.

| Component | Resource Type | Specification | Environment |
|-----------|--------------|---------------|-------------|
| SageMaker NLP Classifier Endpoint | SageMaker Endpoint | ml.t3.medium, auto-scaling 1–3 instances | Dev + Staging |
| SageMaker Audio Extractor Endpoint | SageMaker Endpoint | ml.t3.medium, auto-scaling 1–3 instances | Dev + Staging |
| Lambda — Playlist Generator | AWS Lambda | arm64, 1,024 MB, 29s timeout | Dev + Staging |
| Lambda — Catalog Enrichment | AWS Lambda | arm64, 512 MB, 300s timeout | Dev + Staging |
| Lambda — API Authorizer | AWS Lambda | arm64, 256 MB, 5s timeout | Dev + Staging |
| Lambda — Feedback Capture | AWS Lambda | arm64, 256 MB, 29s timeout | Dev + Staging |
| Lambda — Preference Update | AWS Lambda | arm64, 512 MB, 300s timeout | Dev + Staging |
| API Gateway REST API | API GW Regional | /api/v1/ prefix; 5 endpoints; usage plan 100 rps | Dev + Staging |
| Amazon Personalize Campaign | Personalize | Hybrid collaborative-filtering + content-based | Dev + Staging |
| OpenSearch Service | OpenSearch | t3.small.search, 20 GB EBS, single-node | Dev + Staging |
| ElastiCache Redis | ElastiCache | cache.t3.micro, at-rest encryption enabled | Dev + Staging |
| Step Functions — Enrichment SM | Step Functions | Standard workflow; retry 3× with backoff | Dev + Staging |
| SQS — Feedback Queue | Amazon SQS | Standard; 4-day retention; max receive 3 | Dev + Staging |
| SQS — Feedback DLQ | Amazon SQS | Standard; 14-day retention | Dev + Staging |
| EventBridge — Catalog Bus | EventBridge | Custom bus: anp-{env}-catalog | Dev + Staging |
| EventBridge — Retraining Schedule | EventBridge Scheduler | cron(0 2 ? * MON *) | Dev + Staging |
| AWS CodePipeline | CodePipeline | Source → Build → Deploy to Dev/Staging | Dev + Staging |

### Script Location

Compute CDK constructs are split across the following source files:
- `infrastructure/stacks/anp_compute_stack.py` — Lambda, API Gateway, SQS, EventBridge, Step Functions
- `infrastructure/stacks/anp_ml_stack.py` — SageMaker endpoints, Personalize, OpenSearch, ElastiCache
- Lambda function source code: `functions/playlist-generator/`, `functions/catalog-enrichment/`, `functions/api-authorizer/`, `functions/feedback-capture/`, `functions/preference-update/`
- SageMaker training scripts: `ml/nlp-classifier/train.py`, `ml/audio-extractor/train.py`
- Step Functions workflow definition: `infrastructure/step_functions/enrichment_workflow.json`

### Deployment Steps

The following steps deploy the Compute stack, which depends on both the Networking and Security stack outputs.

```bash
# Step 1: Build Lambda container images and push to ECR
aws ecr get-login-password --region us-east-1 --profile anp-delivery | \
  docker login --username AWS --password-stdin [account-id].dkr.ecr.us-east-1.amazonaws.com

for function in playlist-generator catalog-enrichment api-authorizer feedback-capture preference-update; do
  echo "Building $function..."
  docker build -t anp-dev-$function:latest functions/$function/
  docker tag anp-dev-$function:latest [account-id].dkr.ecr.us-east-1.amazonaws.com/anp-dev-$function:latest
  docker push [account-id].dkr.ecr.us-east-1.amazonaws.com/anp-dev-$function:latest
  echo "$function image pushed."
done

# Step 2: Deploy the ML infrastructure stack (OpenSearch, ElastiCache, Personalize)
cdk deploy AnpMlStack \
  --context environment=dev \
  --profile anp-delivery \
  --require-approval never \
  --outputs-file outputs/dev-ml-outputs.json

# Step 3: Deploy the Compute stack (Lambda, API GW, SQS, EventBridge, Step Functions)
cdk deploy AnpComputeStack \
  --context environment=dev \
  --profile anp-delivery \
  --require-approval never \
  --outputs-file outputs/dev-compute-outputs.json

# Step 4: Retrieve API Gateway endpoint URL
API_URL=$(cat outputs/dev-compute-outputs.json | python -c "import sys,json; d=json.load(sys.stdin); print(d['AnpComputeStack']['ApiGatewayUrl'])")
echo "API Gateway URL: $API_URL"

# Step 5: Run health check against the deployed API
curl -X GET "$API_URL/api/v1/health" \
  -H "x-api-key: [internal-api-key]" \
  -w "\nHTTP Status: %{http_code}\n"
# Expected: HTTP Status: 200
```

### Validation

Run the following validation suite to confirm all compute resources are healthy before proceeding to application configuration.

```bash
# Validate Lambda functions are deployed and healthy
for function in playlist-generator catalog-enrichment api-authorizer feedback-capture preference-update; do
  STATE=$(aws lambda get-function \
    --function-name anp-dev-$function \
    --query 'Configuration.State' \
    --output text \
    --profile anp-delivery)
  echo "anp-dev-$function: State=$STATE"
done
# Expected: All functions report State=Active

# Validate SageMaker endpoints are InService
for endpoint in anp-dev-nlp-classifier-endpoint anp-dev-audio-extractor-endpoint; do
  STATUS=$(aws sagemaker describe-endpoint \
    --endpoint-name $endpoint \
    --query 'EndpointStatus' \
    --output text \
    --profile anp-delivery)
  echo "$endpoint: Status=$STATUS"
done
# Expected: Both endpoints report Status=InService

# Validate SQS queues exist
aws sqs list-queues \
  --queue-name-prefix anp-dev \
  --query 'QueueUrls' \
  --profile anp-delivery

# Test end-to-end playlist generation (requires a valid Cognito JWT)
TOKEN=$(aws cognito-idp initiate-auth \
  --auth-flow USER_PASSWORD_AUTH \
  --auth-parameters USERNAME=[test-user],PASSWORD=[test-password] \
  --client-id [cognito-client-id] \
  --query 'AuthenticationResult.AccessToken' \
  --output text \
  --profile anp-delivery)

curl -X POST "$API_URL/api/v1/playlists" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"user_id":"test-user","mood_input":"peaceful","count":10}' \
  -w "\nHTTP Status: %{http_code}\n"
```

### Success Criteria

- All five Lambda functions are in `Active` state
- Both SageMaker endpoints are `InService`
- OpenSearch domain is `Active` with green cluster health
- ElastiCache node is in `available` state
- API Gateway health endpoint returns HTTP 200
- Playlist generation endpoint returns a JSON array of tracks within ≤ 5 seconds (cache miss)
- SQS feedback queue and DLQ exist and are accessible

### Rollback

If a Compute stack deployment must be reverted, use the following procedure to restore Lambda functions, SageMaker endpoints, or the full CDK stack.

```bash
# Rollback individual Lambda functions to previous version via alias
aws lambda update-alias \
  --function-name anp-dev-playlist-generator \
  --name live \
  --function-version [previous-version-number] \
  --profile anp-delivery
# Repeat for each function that needs rollback

# Rollback SageMaker endpoint to previous model version
aws sagemaker update-endpoint \
  --endpoint-name anp-dev-nlp-classifier-endpoint \
  --endpoint-config-name anp-dev-nlp-classifier-config-[previous-version] \
  --profile anp-delivery

# Rollback CDK Compute stack changes via CloudFormation
aws cloudformation cancel-update-stack \
  --stack-name AnpComputeStack \
  --profile anp-delivery
```

---

## Monitoring

The Monitoring layer deploys CloudWatch dashboards, alarms, SNS notification topics, X-Ray tracing configuration, CloudWatch Synthetics canaries, and the SageMaker Pipelines retraining workflow. This layer is deployed last because it references resources created by the Compute layer.

### Components

The following table lists all monitoring components provisioned in this layer.

| Component | Resource Type | Configuration | Environment |
|-----------|--------------|---------------|-------------|
| SNS Alert Topic | Amazon SNS | Email subscription for ANP Technical Lead | Dev + Staging |
| CW Alarm — Playlist API Latency | CloudWatch Alarm | API GW p95 > 3,000 ms for 15 min → SNS | Dev + Staging |
| CW Alarm — API Gateway 5xx Rate | CloudWatch Alarm | 5xx rate > 1% for 5 min → SNS | Dev + Staging |
| CW Alarm — SageMaker Error Rate | CloudWatch Alarm | ModelError > 5% for 5 min → SNS | Dev + Staging |
| CW Alarm — Feedback DLQ Depth | CloudWatch Alarm | DLQ message count > 10 → SNS | Dev + Staging |
| CW Alarm — DynamoDB Throttles | CloudWatch Alarm | ThrottledRequests > 0 for 5 min → SNS | Dev + Staging |
| CW Alarm — SageMaker Endpoint Down | CloudWatch Alarm | Endpoint not InService for 2 min → SNS | Dev + Staging |
| CW Alarm — GuardDuty High Finding | CloudWatch Alarm | GuardDuty finding severity ≥ HIGH → SNS | Dev + Staging |
| CW Alarm — Retraining Pipeline Fail | CloudWatch Alarm | SageMaker Pipelines execution Failed → SNS | Dev + Staging |
| CW Dashboard — API Health | CloudWatch Dashboard | p50/p95/p99 latency, 4xx/5xx rates | Dev + Staging |
| CW Dashboard — ML Pipeline | CloudWatch Dashboard | SageMaker invocations, classification throughput | Dev + Staging |
| CW Dashboard — Business Metrics | CloudWatch Dashboard | Playlist volume, feedback rate, MAU proxy | Dev + Staging |
| X-Ray Tracing | AWS X-Ray | Active tracing on all Lambda + API GW | Dev + Staging |
| CW Synthetics Canary | CloudWatch Synthetics | Health endpoint ping every 5 minutes | Dev + Staging |
| SageMaker Pipelines — Retraining | SageMaker Pipelines | Weekly schedule cron(0 2 ? * MON *) | Staging |
| Log Retention Policy | CloudWatch Logs | 30 days (Dev), 90 days (Staging/Prod) | Dev + Staging |

### Script Location

Monitoring CDK constructs are in `infrastructure/stacks/anp_monitoring_stack.py`. CloudWatch dashboard JSON definitions are in `infrastructure/dashboards/`. The SageMaker Pipelines retraining pipeline definition is in `ml/retraining-pipeline/pipeline.py`. Canary scripts are in `infrastructure/canaries/health_check.js`.

### Deployment Steps

The following steps deploy the Monitoring stack as the final infrastructure layer.

```bash
# Step 1: Create SNS topic and subscribe ANP Technical Lead email
SNS_ARN=$(aws sns create-topic \
  --name anp-dev-operational-alerts \
  --tags Key=Environment,Value=dev Key=Application,Value=anp-recommendation-engine \
  --query 'TopicArn' \
  --output text \
  --profile anp-delivery)

aws sns subscribe \
  --topic-arn $SNS_ARN \
  --protocol email \
  --notification-endpoint [anp-technical-lead-email] \
  --profile anp-delivery

echo "SNS subscription confirmation email sent to ANP Technical Lead."
echo "ACTION REQUIRED: ANP Technical Lead must confirm the email subscription."

# Step 2: Deploy the Monitoring CDK stack
cdk deploy AnpMonitoringStack \
  --context environment=dev \
  --profile anp-delivery \
  --require-approval never \
  --outputs-file outputs/dev-monitoring-outputs.json

# Step 3: Verify CloudWatch dashboards are created
aws cloudwatch list-dashboards \
  --dashboard-name-prefix anp-dev \
  --query 'DashboardEntries[].DashboardName' \
  --profile anp-delivery
# Expected: ["anp-dev-api-health", "anp-dev-ml-pipeline", "anp-dev-business-metrics"]

# Step 4: Register the SageMaker Pipelines retraining workflow (Staging only)
python ml/retraining-pipeline/pipeline.py \
  --environment staging \
  --role-arn arn:aws:iam::[account-id]:role/anp-staging-sagemaker-pipeline-role \
  --pipeline-name anp-staging-retraining-pipeline

# Step 5: Trigger a test alarm to validate SNS fan-out
aws cloudwatch set-alarm-state \
  --alarm-name anp-dev-playlist-api-latency \
  --state-value ALARM \
  --state-reason "TEST: Validating SNS fan-out" \
  --profile anp-delivery

# Reset alarm after validation
aws cloudwatch set-alarm-state \
  --alarm-name anp-dev-playlist-api-latency \
  --state-value OK \
  --state-reason "TEST: Reset after validation" \
  --profile anp-delivery
```

### Validation

Run the following checks to confirm the Monitoring stack is fully operational before beginning application-level testing.

```bash
# Verify all alarms are in OK state (no genuine conditions present)
aws cloudwatch describe-alarms \
  --alarm-name-prefix anp-dev \
  --query 'MetricAlarms[].{Name:AlarmName,State:StateValue}' \
  --profile anp-delivery

# Verify X-Ray tracing is enabled on Lambda functions
aws lambda get-function-configuration \
  --function-name anp-dev-playlist-generator \
  --query 'TracingConfig.Mode' \
  --output text \
  --profile anp-delivery
# Expected: Active

# Verify Synthetics canary is running
aws synthetics describe-canaries \
  --query 'Canaries[?Name==`anp-dev-health-canary`].{Name:Name,Status:Status.State}' \
  --profile anp-delivery
# Expected: Status.State = RUNNING

# Verify retraining pipeline is registered (Staging)
aws sagemaker list-pipelines \
  --pipeline-name-prefix anp-staging-retraining \
  --query 'PipelineSummaries[].{Name:PipelineName,Status:PipelineStatus}' \
  --profile anp-delivery
```

### Success Criteria

- All 8 CloudWatch Alarms are created and in `OK` state
- All 3 CloudWatch Dashboards are visible in the AWS console with widgets populated
- SNS subscription is confirmed by ANP Technical Lead (email confirmation received)
- X-Ray tracing is `Active` on all five Lambda functions
- CloudWatch Synthetics canary is in `RUNNING` state and last run result is `PASSED`
- SageMaker Pipelines retraining workflow is registered in Staging environment
- Log groups for all Lambda functions have correct retention policies applied

### Rollback

If the Monitoring stack must be reverted or alarms need to be manually restored, use the following commands.

```bash
# Rollback monitoring stack changes
aws cloudformation cancel-update-stack \
  --stack-name AnpMonitoringStack \
  --profile anp-delivery

# Manually re-create a specific alarm after a failed stack update
aws cloudwatch put-metric-alarm \
  --alarm-name anp-dev-playlist-api-latency \
  --metric-name Latency \
  --namespace AWS/ApiGateway \
  --statistic p95 \
  --period 60 \
  --evaluation-periods 15 \
  --threshold 3000 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions [sns-topic-arn] \
  --profile anp-delivery
```

---

# Application Configuration

Once all infrastructure layers are deployed and validated, the application configuration layer wires up service connections, seeds reference data, configures Cognito user roles, and establishes the end-to-end data flow from catalog enrichment through playlist generation.

## Service Connection Configuration

All service connection parameters are managed through AWS Systems Manager Parameter Store (non-sensitive) and AWS Secrets Manager (sensitive credentials). No configuration values are stored in Lambda environment variables or source code.

The table below lists the key application configuration parameters and their target Parameter Store paths.

| Parameter | SSM Path | Value Source | Security Level |
|-----------|----------|--------------|----------------|
| Cognito User Pool ID | `/anp/{env}/cognito/user_pool_id` | CDK stack output | Confidential |
| Cognito App Client ID | `/anp/{env}/cognito/client_id` | CDK stack output | Confidential |
| Personalize Campaign ARN | `/anp/{env}/personalize/campaign_arn` | Post-training | Confidential |
| Personalize Event Tracker ID | `/anp/{env}/personalize/event_tracker_id` | Post-training | Confidential |
| SQS Feedback Queue URL | `/anp/{env}/sqs/feedback_queue_url` | CDK stack output | Confidential |
| OpenSearch Endpoint | `/anp/{env}/opensearch/endpoint` | CDK stack output | Confidential |
| ElastiCache Endpoint | `/anp/{env}/cache/host` | CDK stack output | Confidential |
| Mood Classifier Confidence Threshold | `/anp/{env}/ml/classifier_confidence_threshold` | Static: 0.75 | Public |
| Retraining Schedule Expression | `/anp/{env}/ml/retraining_schedule` | Static: cron(0 2 ? * MON *) | Public |

```bash
# Load all stack outputs into Parameter Store (run after all CDK stacks are deployed)
python scripts/load_parameters_from_outputs.py \
  --environment dev \
  --outputs-dir outputs/ \
  --profile anp-delivery

# Verify a key parameter
aws ssm get-parameter \
  --name /anp/dev/cognito/user_pool_id \
  --query 'Parameter.Value' \
  --output text \
  --profile anp-delivery
```

## Application Settings

The following YAML configuration defines the core application settings, consumed by Lambda functions at cold-start via the Parameter Store provider.

```yaml
# config/application-dev.yaml
application:
  name: anp-streaming-ai
  version: "1.0.0"
  environment: dev
  api_version: v1
  api_rate_limit_rps: 50
  playlist_count_default: 20
  cold_start_threshold: 5

logging:
  level: debug
  format: json

ml:
  classifier_confidence_threshold: 0.75
  classifier_accuracy_target_pct: 90
  mood_taxonomy_min_labels: 10
  retraining_schedule: "cron(0 2 ? * MON *)"
  conditional_promotion: true
  personalize_min_interactions: 10

cache:
  playlist_ttl_seconds: 600
  session_ttl_seconds: 1800
  enabled: true

operations:
  rto_hours: 4
  rpo_hours: 1
  lambda_max_concurrency: 50
  sagemaker_min_instances: 1
  sagemaker_scale_threshold_pct: 70
```

## IAM Role Validation

Before processing any live traffic, verify that all Lambda execution roles follow least-privilege principles. The following check confirms no wildcard resource policies exist.

```bash
# Audit Lambda execution role policies for wildcard resources
for function in playlist-generator catalog-enrichment api-authorizer feedback-capture preference-update; do
  ROLE=$(aws lambda get-function-configuration \
    --function-name anp-dev-$function \
    --query 'Role' \
    --output text \
    --profile anp-delivery)
  echo "Function: anp-dev-$function | Role: $ROLE"
  aws iam list-role-policies --role-name $(basename $ROLE) --profile anp-delivery
done
```

## Data Protection Verification

Run the following checks to confirm KMS encryption is active on all data stores before any production data is written.

```bash
# Confirm KMS encryption is active on all DynamoDB tables
for table in anp-dev-content-catalog anp-dev-user-profiles anp-dev-interaction-events anp-dev-mood-taxonomy; do
  SSE=$(aws dynamodb describe-table \
    --table-name $table \
    --query 'Table.SSEDescription.Status' \
    --output text \
    --profile anp-delivery)
  echo "$table: Encryption=$SSE"
done
# Expected: All tables report ENABLED

# Confirm S3 bucket encryption with KMS CMK
for bucket in [anp-dev-raw-catalog] [anp-dev-transcripts] [anp-dev-features] [anp-dev-models]; do
  ENC=$(aws s3api get-bucket-encryption \
    --bucket $bucket \
    --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' \
    --output text \
    --profile anp-delivery)
  echo "$bucket: Encryption=$ENC"
done
# Expected: All buckets report aws:kms
```

## Security Controls Checklist

- [ ] All Lambda IAM roles verified against least-privilege — no `Resource: "*"` on production resources
- [ ] KMS CMK encryption enabled on all DynamoDB tables (status: ENABLED)
- [ ] KMS CMK encryption enabled on all S3 buckets (algorithm: aws:kms)
- [ ] KMS CMK annual rotation enabled (`KeyRotationEnabled=true`)
- [ ] TLS 1.2 minimum enforced on API Gateway security policy
- [ ] All Secrets Manager secrets created with KMS encryption and 90-day rotation configured
- [ ] No credentials in Lambda environment variables, source code, or CloudFormation parameter files
- [ ] VPC endpoints confirmed active (S3, DynamoDB, SageMaker Runtime, Secrets Manager, SQS, Step Functions)
- [ ] Security group rules verified: SageMaker endpoint SG allows inbound only from Lambda SG

---

# Integration Testing

This section covers end-to-end integration validation between the ANP Streaming AI Recommendation Engine components and the FlutterFlow mobile application. All integration tests are executed in the Staging environment before final handover.

## Integration Test Strategy

Integration testing validates that all five ML capability domains interact correctly and that the secured REST API responds correctly to FlutterFlow-simulated call patterns. The strategy follows three test levels aligned to Phase 5 of the SOW.

**Level 1 — Component Integration Tests:** Validate data flows between pairs of adjacent services (e.g., Enrichment Lambda → DynamoDB catalog write, Playlist Lambda → Personalize → mood matcher).

**Level 2 — API Contract Tests:** Validate all five REST endpoints against the OpenAPI contract using Postman collection runs.

**Level 3 — End-to-End FlutterFlow Simulation:** Validate the full pipeline from FlutterFlow call pattern simulation through classification, recommendation, and feedback capture.

## Test Environment Setup

Before executing integration tests, confirm the Staging environment is fully deployed and seeded with test data.

```bash
# Seed Staging environment with test catalog items (20 representative tracks/podcasts)
python scripts/seed_test_catalog.py \
  --environment staging \
  --sample-count 20 \
  --profile anp-delivery

# Create test user accounts in Cognito (listener, artist, admin roles)
python scripts/create_test_users.py \
  --environment staging \
  --profile anp-delivery

# Verify enrichment pipeline runs end-to-end on seeded items
python scripts/trigger_bulk_enrichment.py \
  --environment staging \
  --profile anp-delivery

# Confirm all 20 catalog items have emotion_scores in DynamoDB
aws dynamodb scan \
  --table-name anp-staging-content-catalog \
  --filter-expression "attribute_exists(emotion_scores)" \
  --select COUNT \
  --profile anp-delivery
# Expected: Count: 20
```

## API Contract Test Execution

All five API endpoints are validated using the Postman collection. The following test cases cover happy path, authentication failure, and error handling scenarios.

```bash
# Run Postman collection against Staging API
newman run postman/ANP-Streaming-API-Tests.postman_collection.json \
  --environment postman/staging.postman_environment.json \
  --reporters cli,junit \
  --reporter-junit-export results/api-test-results.xml

# Expected output summary:
# ┌─────────────────────────┬───────────────────┬────────────────────┐
# │                         │          executed │             failed │
# ├─────────────────────────┼───────────────────┼────────────────────┤
# │              iterations │                 1 │                  0 │
# │                requests │                22 │                  0 │
# │            test-scripts │                44 │                  0 │
# │      prerequest-scripts │                22 │                  0 │
# │              assertions │                66 │                  0 │
# └─────────────────────────┴───────────────────┴────────────────────┘
```

## Performance and Load Testing

The following load test configuration simulates 100 MAU concurrent traffic against the playlist generation endpoint to validate the ≤ 2-second p95 latency target.

```bash
# Load test: 100 MAU simulation — playlist generation endpoint
cat > load-test/100mau-playlist-test.yml << 'EOF'
config:
  target: "https://[staging-api-url]"
  phases:
    - duration: 60
      arrivalRate: 2
      name: Warm up
    - duration: 300
      arrivalRate: 10
      name: 100 MAU sustained load
  defaults:
    headers:
      Authorization: "Bearer {{ $processEnvironment.ANP_TEST_TOKEN }}"
      Content-Type: "application/json"
scenarios:
  - name: "Generate playlist"
    flow:
      - post:
          url: "/api/v1/playlists"
          json:
            user_id: "{{ $randomString() }}"
            mood_input: "peaceful"
            count: 20
          expect:
            - statusCode: 200
            - contentType: "application/json"
EOF

artillery run load-test/100mau-playlist-test.yml \
  --output results/load-test-100mau.json

artillery report results/load-test-100mau.json \
  --output results/load-test-100mau-report.html

echo "Review load test report: results/load-test-100mau-report.html"
echo "Target: p95 latency <= 2000ms; error rate < 1%"
```

## End-to-End Validation Checklist

- [ ] Content upload → EventBridge trigger → Step Functions enrichment → DynamoDB write completes end-to-end in < 60 seconds
- [ ] FlutterFlow Cognito authentication flow returns a valid JWT (no frontend code changes required)
- [ ] `POST /api/v1/playlists` returns 20 ordered tracks for a known user with mood input `peaceful` in ≤ 2 seconds (p95 under 100 MAU load)
- [ ] `POST /api/v1/interactions` records a play event and the event appears in the DynamoDB interaction-events table
- [ ] Cold-start user (0 interactions) receives a mood-matched playlist from the mood-to-content matcher fallback
- [ ] Invalid JWT returns HTTP 401 before any Lambda function is invoked (confirmed via CloudWatch Logs)
- [ ] SQL injection payload in request body is blocked by WAF with HTTP 403
- [ ] Feedback DLQ is empty after 60 minutes of interaction event testing
- [ ] End-to-End Validation Report (SOW Deliverable 23) compiled and accepted by Lilly Goyah

---

# Security Validation

Security validation is conducted against the complete Staging deployment before handover. All findings must be remediated to zero HIGH/CRITICAL items before the engagement closes.

## Security Quality Gates

### Phase 2 Quality Gate (Content Intelligence)

- [ ] No CRITICAL or HIGH findings in AWS Security Hub after Phase 2 deployment
- [ ] NLP classifier IAM role verified — only permitted to invoke its own SageMaker endpoint
- [ ] S3 buckets (raw-catalog, transcripts) confirmed encrypted with KMS CMK and versioning enabled
- [ ] Enrichment Lambda does not log Firebase credentials or any secret values (CloudWatch Logs audit)

### Phase 3 Quality Gate (Recommendation Engine)

- [ ] Personalize IAM role restricted to own dataset group — cannot access other AWS services
- [ ] DynamoDB user-profiles table PITR confirmed enabled
- [ ] ElastiCache at-rest encryption active; no plaintext session data visible in cache key scans
- [ ] Retraining pipeline role cannot access user PII DynamoDB tables (IAM condition key validation)

### Phase 4 Quality Gate (API Service Layer)

- [ ] Authentication bypass tests pass: invalid JWT → 401, expired JWT → 401, missing header → 401
- [ ] WAF blocks SQL injection (`' OR 1=1--`), XSS (`<script>alert(1)</script>`), and known bad IP patterns
- [ ] API throttling confirmed: burst of 150 rps against 100 rps limit results in HTTP 429 for excess requests
- [ ] Secrets Manager access validated: Lambda retrieves Firebase credentials at runtime; no credentials visible in CloudWatch Logs or Lambda environment variables
- [ ] All API responses include security headers: `Strict-Transport-Security`, `X-Content-Type-Options`, `X-Frame-Options`

### Phase 5 Quality Gate (Integration & Handover)

- [ ] Security Hub scan at engagement close: zero CRITICAL findings, zero HIGH findings
- [ ] AWS Config rule compliance: all managed rules report COMPLIANT
- [ ] IAM Access Analyzer: zero active findings
- [ ] CloudTrail confirms all API calls are logged (no gaps > 1 minute in trail delivery)
- [ ] GuardDuty findings reviewed: zero unresolved HIGH or CRITICAL findings
- [ ] AWS Well-Architected Security Pillar review checklist completed (SEC 01–SEC 07 documented)

## Security Validation Commands

Run the following AWS CLI commands to produce a point-in-time security posture report across Security Hub, AWS Config, and IAM Access Analyzer.

```bash
# Run AWS Security Hub security standard findings report
aws securityhub get-findings \
  --filters '{"SeverityLabel":[{"Value":"CRITICAL","Comparison":"EQUALS"},{"Value":"HIGH","Comparison":"EQUALS"}],"WorkflowStatus":[{"Value":"NEW","Comparison":"EQUALS"}]}' \
  --query 'Findings[].{Title:Title,Severity:Severity.Label,Resource:Resources[0].Id}' \
  --profile anp-delivery
# Target: Empty array (zero CRITICAL or HIGH findings)

# Confirm AWS Config compliance for key rules
aws configservice describe-compliance-by-config-rule \
  --config-rule-names dynamodb-pitr-enabled s3-bucket-server-side-encryption-enabled cloudtrail-enabled \
  --query 'ComplianceByConfigRules[].{Rule:ConfigRuleName,Compliance:Compliance.ComplianceType}' \
  --profile anp-delivery
# Expected: All rules report COMPLIANT

# Validate IAM Access Analyzer findings
aws accessanalyzer list-findings \
  --analyzer-arn [analyzer-arn] \
  --filter '{"status":{"eq":["ACTIVE"]}}' \
  --query 'findings[].{Id:id,ResourceType:resourceType,Condition:condition}' \
  --profile anp-delivery
# Target: Empty array (zero active findings)
```

## Disaster Recovery Testing

The following DR tests are conducted in the Staging environment during Phase 5 to validate the 4-hour RTO and 1-hour RPO targets before handover.

```bash
# DR Test 1: DynamoDB PITR Restore
BEFORE_COUNT=$(aws dynamodb scan \
  --table-name anp-staging-content-catalog \
  --select COUNT \
  --query 'Count' \
  --output text \
  --profile anp-delivery)

RESTORE_TIME=$(date -u -v-30M '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date -u -d '30 minutes ago' '+%Y-%m-%dT%H:%M:%SZ')

aws dynamodb restore-table-to-point-in-time \
  --source-table-name anp-staging-content-catalog \
  --target-table-name anp-staging-content-catalog-restore-test \
  --restore-date-time $RESTORE_TIME \
  --profile anp-delivery

echo "PITR restore initiated. Target: completes within 1 hour. RTO target: 4 hours."

# DR Test 2: SageMaker Model Rollback (< 10 minutes target)
aws sagemaker update-endpoint \
  --endpoint-name anp-staging-nlp-classifier-endpoint \
  --endpoint-config-name anp-staging-nlp-classifier-config-v0 \
  --profile anp-delivery

aws sagemaker wait endpoint-in-service \
  --endpoint-name anp-staging-nlp-classifier-endpoint \
  --profile anp-delivery

echo "Model rollback complete. Validate inference quality with holdout set."
```

---

# Migration & Cutover

## Migration Approach

Production deployment is **explicitly out of scope** for this engagement per the SOW. The following cutover plan is provided as a reference for the ANP Streaming team to execute independently after engagement close and final deliverable acceptance. The approach is phased production promotion using the CDK pipeline delivering from Staging artifacts.

**Type:** Phased production promotion (greenfield; no existing production traffic on the AI backend)

**Rationale:** Since this is a greenfield build with zero existing users on the new AWS AI backend, there is no user-facing downtime risk during promotion. The phased approach allows progressive validation at each step before the FlutterFlow application is pointed to the production endpoint.

## Pre-Cutover Checklist

Complete all items before executing the production promotion steps.

- [ ] All functional test cases pass in Staging environment (Phase 5 validation complete)
- [ ] Performance test confirms ≤ 2s playlist generation latency at 100 MAU load (p95)
- [ ] Security Hub scan: zero CRITICAL/HIGH findings in Staging
- [ ] DynamoDB PITR restore test passed in Staging (< 1 hour completion confirmed)
- [ ] SageMaker model rollback test passed (< 10 minutes confirmed)
- [ ] All five REST API endpoints validated against FlutterFlow-simulated call patterns
- [ ] Operational runbooks reviewed and accepted by ANP Technical Lead
- [ ] Both knowledge-transfer sessions completed and attendance records confirmed
- [ ] Final Deliverable Package (SOW Deliverable 27) compiled and accepted by Lilly Goyah
- [ ] AWS Cognito User Pool configured for production user volumes
- [ ] All nClouds IAM access deprovisioning plan documented and scheduled for engagement close

## Cutover Window

- **Estimated Duration:** 1-day execution window for initial production promotion
- **Recommended Window:** Low-traffic period (e.g., Monday 02:00–06:00 UTC)
- **Participants Required:** ANP Technical Lead (execution), ANP Infrastructure Architect (validation), nClouds SA on standby (hypercare channel)

## Production Promotion Steps

The following steps are for the ANP team to execute post-engagement using the delivered CDK templates.

```bash
# Step 1: Create production environment from CDK templates delivered by nClouds
cdk deploy --all \
  --context environment=prod \
  --profile anp-production \
  --require-approval broadening

# Step 2: Run catalog enrichment pipeline against the full production Firebase catalog
python scripts/trigger_bulk_enrichment.py \
  --environment prod \
  --profile anp-production

# Step 3: Deploy SageMaker endpoints with Staging model artifacts
aws sagemaker update-endpoint \
  --endpoint-name anp-prod-nlp-classifier-endpoint \
  --endpoint-config-name anp-prod-nlp-classifier-config-v1 \
  --profile anp-production

# Step 4: Update API Gateway stage variables to production resources
# Step 5: Update FlutterFlow API base URL to production API Gateway endpoint
# Step 6: Conduct smoke test of all five endpoints from FlutterFlow
# Step 7: Enable CloudWatch alarms and confirm SNS fan-out
# Step 8: Confirm GuardDuty has no active findings in production

echo "Production promotion complete. Monitor CloudWatch dashboards for 1 hour."
```

## Go/No-Go Criteria

All five criteria below must be satisfied before traffic is permanently routed to the production endpoint. The table captures the pass condition and provides a sign-off status field for the go/no-go meeting.

| Criterion | Pass Condition | Status |
|-----------|---------------|--------|
| All five API endpoints return expected HTTP 200 | Postman smoke test passes | ☐ |
| Playlist generation latency ≤ 2s p95 | Artillery load test at 100 MAU confirms | ☐ |
| CloudWatch alarms all in OK state | No alarms triggered in first 30 minutes | ☐ |
| GuardDuty shows no HIGH/CRITICAL findings | Security Hub scan clean | ☐ |
| SageMaker endpoints both InService | AWS console confirmation | ☐ |

## Rollback Plan

**Rollback Triggers:**
- Any API endpoint returning HTTP 5xx rate > 5% sustained for 5 minutes
- Playlist generation latency p95 > 5 seconds sustained for 5 minutes
- GuardDuty HIGH or CRITICAL finding in the first 2 hours of production operation
- SageMaker endpoint entering non-InService state

**Rollback Procedure:**

```bash
# Step 1: Repoint FlutterFlow API base URL back to Staging endpoint (immediate user continuity)

# Step 2: Roll back Lambda function aliases to previous stable versions
for function in playlist-generator catalog-enrichment api-authorizer feedback-capture preference-update; do
  aws lambda update-alias \
    --function-name anp-prod-$function \
    --name live \
    --function-version [previous-stable-version] \
    --profile anp-production
done

# Step 3: Roll back SageMaker endpoints to previous model version
aws sagemaker update-endpoint \
  --endpoint-name anp-prod-nlp-classifier-endpoint \
  --endpoint-config-name anp-prod-nlp-classifier-config-[previous-version] \
  --profile anp-production

# Step 4: If DynamoDB schema changes are involved, restore from PITR
aws dynamodb restore-table-to-point-in-time \
  --source-table-name anp-prod-content-catalog \
  --target-table-name anp-prod-content-catalog-restored \
  --restore-date-time [pre-deployment-timestamp] \
  --profile anp-production

echo "Rollback complete. Target: < 30 minutes for Lambda/model rollbacks, < 2 hours for full DynamoDB PITR restore."
```

---

# Operational Handover

## Documentation Handover

The following documentation is delivered to ANP Streaming as part of the Final Deliverable Package (SOW Deliverable 27) at engagement close. All items must be accepted by Lilly Goyah (CEO) and the ANP Technical Lead within 3 business days of delivery.

- [ ] AWS Architecture Diagrams — high-level overview and detailed service-level diagrams (SOW Deliverable 4)
- [ ] Data Schema Package — user preference vector schema, content metadata schema, mood taxonomy (SOW Deliverable 6)
- [ ] API Contract Documentation — all five REST endpoints in OpenAPI/Swagger format (SOW Deliverable 20)
- [ ] Model Documentation — training data requirements, hyperparameter configurations, evaluation metrics, retraining schedule
- [ ] Operational Runbooks — all services: deployment, scaling, model retraining, incident response, access management (SOW Deliverable 24)
- [ ] Infrastructure-as-Code (AWS CDK/CloudFormation) templates for Dev and Staging environments
- [ ] CI/CD Pipeline Configuration for Lambda, model, and infrastructure deployments
- [ ] AWS Account Configuration Documentation — IAM policies, Cognito user pool settings, WAF rules, CloudWatch alarms
- [ ] Tiered AWS Cost Model Spreadsheet (100 / 10K / 100K MAU projections) — SOW Deliverable 7
- [ ] Performance and Load Test Report (SOW Deliverable 22)
- [ ] End-to-End Validation Report (SOW Deliverable 23)
- [ ] Project Retrospective and Lessons-Learned Document

## Support Transition

### Support Model

The following support tiers define the post-engagement operational support model for the ANP Streaming AI Recommendation Engine.

| Tier | Responsibility | Response Time | Escalation |
|------|----------------|---------------|------------|
| L1 — ANP Technical Lead | Initial triage using operational runbooks; known-issue resolution; CloudWatch dashboard monitoring | < 1 hour (business hours) | To L2 after 2 hours unresolved |
| L2 — ANP Infrastructure / Security Architect | Technical troubleshooting; IAM/network/encryption issues; DynamoDB and S3 operational issues | < 4 hours | To nClouds hypercare after 8 hours during hypercare period |
| L3 — nClouds Hypercare (2-week window) | Bug fixes and configuration corrections traceable to delivered artifacts; guidance on operational procedures | 4-hour initial response for functional issues; next-business-day for operational questions | To AWS Support (Business Plan) for platform issues |
| L4 — AWS Support (Business Plan) | AWS service issues; platform SLAs; infrastructure support | 1 hour critical, 4 hours high | AWS escalation path |

### Escalation Contacts

The table below lists all escalation contacts and their availability during the post-engagement period.

| Level | Contact | Availability | Channel |
|-------|---------|--------------|---------|
| Primary | ANP Technical Lead | Business hours | Slack `#anp-ai-delivery` |
| Secondary | Jonas Bull — nClouds SA (Hypercare) | Business hours ET (hypercare period only) | Dedicated Slack channel or email |
| Emergency | Andrew Brewer — nClouds SVP Sales | Business hours | Email / Phone |
| AWS Support | AWS Business Support Portal | 24×7 for critical | console.aws.amazon.com/support |

## Hypercare Period

**Duration:** 2 weeks following acceptance of the Final Deliverable Package (SOW Deliverable 27)

**Coverage:** Business hours, Monday–Friday, 09:00–17:00 ET

**Scope (Included):**
- Bug fixes and configuration corrections for issues directly traceable to deliverables produced during the engagement
- Guidance on operational procedures covered in the runbooks
- Assistance with minor configuration adjustments
- Explanation of architecture decisions documented in the Detailed Design Document

**Scope (Excluded during Hypercare):**
- New feature development or scope changes
- Production deployment support (production deployment is the ANP team's responsibility)
- Issues caused by changes made by the ANP team post-handover
- Ongoing managed services or infrastructure management

## Handover Checklist

- [ ] All 27 SOW deliverables delivered and formally accepted
- [ ] Training completed for all user groups (all modules in the Training Program below)
- [ ] ANP Technical Lead trained on all operational runbooks (dry-run sessions completed)
- [ ] Monitoring dashboards reviewed with ANP Technical Lead and operations team
- [ ] All CloudWatch alarms tested end-to-end via SNS fan-out to ANP Technical Lead email
- [ ] Emergency contacts documented and distributed to ANP team
- [ ] All nClouds IAM users and access keys deprovisioned at project closeout
- [ ] ANP Technical Lead designated as AWS account administrator post-engagement
- [ ] AWS Activate enrollment confirmed and credits applied to ANP account
- [ ] APFP funding reconciliation completed; final invoice issued and credited to $0 net
- [ ] Project retrospective meeting conducted; lessons-learned document delivered

---

# Training Program

## Training Overview

The ANP Streaming AI Recommendation Engine training program ensures that all ANP Streaming user groups — administrators, end users (listeners), artists/uploaders, and the IT/technical team — achieve full operational competency before the engagement closes. Training is role-based, sequenced with implementation phases, and documented for ongoing onboarding of new team members.

### Objectives

The training program is designed to achieve the following outcomes:
- ANP Technical Lead and infrastructure team can independently operate, monitor, and maintain all deployed AWS services using the delivered runbooks
- ANP engineering team can manage the model retraining pipeline, evaluate new model versions, and execute rollbacks
- ANP's operational team understands all CloudWatch dashboards, alarm responses, and incident escalation procedures
- Artist/uploader users understand how to use the content classification endpoint and interpret enrichment results
- End user (listener) testers understand the mood input workflow and feedback capture mechanism
- An internal ANP trainer is qualified to deliver end user training independently post-engagement

### Training Approach

- **Phased Delivery:** Training is delivered in alignment with implementation phases — operational training at Phase 4/5; end user training at Phase 5
- **Role-Based:** All content is tailored to each audience's specific responsibilities and system access level
- **Hands-On Focus:** Technical training uses live Staging environment walkthroughs; no simulated screenshots
- **Knowledge Transfer Integration:** The two formal Knowledge Transfer sessions (SOW Deliverables 25 and 26) serve as the capstone technical training events

## Training Schedule

The table below defines all training modules, their target audience, duration, delivery format, and prerequisites.

| Module ID | Module Name | Target Audience | Duration | Format | Prerequisites |
|-----------|-------------|-----------------|----------|--------|---------------|
| TRN-001 | ANP AI Platform Architecture Overview | Administrators, Tech Lead | 2 hours | ILT (remote) | AWS account access |
| TRN-002 | AWS Console Navigation and Resource Management | Administrators, Tech Lead | 2 hours | Hands-On Lab | TRN-001 |
| TRN-003 | CDK/CloudFormation Infrastructure Operations | Tech Lead, DevOps | 3 hours | Hands-On Lab | TRN-002 |
| TRN-004 | CloudWatch Dashboards and Alarm Response | Tech Lead, Operations | 2 hours | Hands-On Lab | TRN-001 |
| TRN-005 | SageMaker Model Management and Retraining | Tech Lead, ML Eng | 3 hours | Hands-On Lab | TRN-003 |
| TRN-006 | API Operations and Cognito User Management | Tech Lead, DevOps | 2 hours | ILT (remote) | TRN-002 |
| TRN-007 | Security Runbook: IAM, KMS, WAF, and Secrets Manager | Tech Lead, Security Owner | 2 hours | Hands-On Lab | TRN-003 |
| TRN-008 | Incident Response and Disaster Recovery Procedures | Tech Lead, On-Call | 2 hours | Workshop | TRN-004, TRN-005 |
| TRN-009 | Artist/Uploader: Content Classification Endpoint Usage | Artists, Content Team | 1 hour | VILT | None |
| TRN-010 | End User Training: Mood Input, Playlists, and Feedback | Listeners, QA Testers | 1 hour | VILT | None |
| TRN-011 | Train-the-Trainer: Internal ANP Training Delivery | Designated ANP Trainer | 2 hours | Workshop | All prior modules |

## Administrator Training

### TRN-001: ANP AI Platform Architecture Overview (2 hours, ILT)

**Learning Objectives:**
- Describe all five ML capability domains and their interactions within the ANP AI backend
- Navigate the AWS console and identify all deployed resources across Networking, Security, Compute, and Monitoring layers
- Explain the end-to-end data flows: Content Enrichment Path and Playlist Generation Path
- Identify key integration points with Firebase and the FlutterFlow application

**Content Outline:**
1. Architecture overview walkthrough (45 min) — five capability domains, CDK stack dependencies, resource naming conventions
2. AWS console navigation drill (45 min) — guided walkthrough of Lambda, SageMaker, DynamoDB, CloudWatch, and API Gateway consoles
3. Data flow explanation (20 min) — enrichment path and playlist path traced live in Staging
4. Q&A and knowledge check (10 min)

**Materials Required:**
- Detailed Design Document (delivered as SOW Deliverable 4)
- Architecture diagrams (high-level and service-level)
- AWS console access to Staging environment

### TRN-002: AWS Console Navigation and Resource Management (2 hours, Hands-On Lab)

**Learning Objectives:**
- Locate all deployed Lambda functions, SageMaker endpoints, DynamoDB tables, and S3 buckets in the Staging environment
- Review CloudWatch log groups for Lambda functions and interpret structured log entries
- Navigate API Gateway to review endpoint configurations and usage plans
- Access SQS queue metrics and identify DLQ depth

**Content Outline:**
1. Lambda function management (30 min) — function list, configuration, test invocation, log tail
2. SageMaker endpoint review (30 min) — endpoint status, invocation metrics, model version in use
3. DynamoDB table operations (30 min) — table scan, item inspection, PITR status
4. S3 bucket review and lifecycle policies (15 min)
5. SQS queue metrics and DLQ inspection (15 min)

**Lab Exercises:**
- Exercise 1: Locate and invoke the Playlist Generator Lambda with a test event
- Exercise 2: Retrieve the last 20 log entries from the Catalog Enrichment Lambda log group
- Exercise 3: Verify PITR is enabled on all four DynamoDB tables
- Exercise 4: Check SQS DLQ message count and confirm it is zero

**Materials Required:**
- Lab guide with step-by-step console navigation instructions
- Staging environment access for all participants
- Reference card: resource naming conventions (from Detailed Design Appendix)

### TRN-003: CDK/CloudFormation Infrastructure Operations (3 hours, Hands-On Lab)

**Learning Objectives:**
- Understand the CDK stack dependency chain (Networking → Security → Compute → Monitoring)
- Execute a `cdk diff` to compare deployed infrastructure against the current CDK definition
- Perform a controlled CDK stack update for a Lambda function configuration change
- Execute a CloudFormation stack rollback procedure

**Content Outline:**
1. CDK project structure walkthrough (30 min) — stack files, context files, config files
2. CDK synth and diff walkthroughs (30 min) — understanding synthesized CloudFormation before deploying
3. Controlled update lab (60 min) — modifying a Lambda memory parameter and deploying via CDK
4. Rollback procedure lab (45 min) — CloudFormation rollback and Lambda alias rollback
5. CodePipeline deployment review (15 min) — understanding automated pipeline stages

**Lab Exercises:**
- Exercise 1: Run `cdk synth` for Staging environment and review output
- Exercise 2: Update Playlist Lambda memory from 1024 MB to 1536 MB in dev.yaml and deploy via CDK
- Exercise 3: Roll back the Lambda to the previous version using Lambda Alias
- Exercise 4: Trigger a CodePipeline deployment and observe the pipeline stages

### TRN-004: CloudWatch Dashboards and Alarm Response (2 hours, Hands-On Lab)

**Learning Objectives:**
- Navigate all three CloudWatch dashboards (API Health, ML Pipeline, Business Metrics)
- Interpret p50/p95/p99 latency metrics and identify latency regression patterns
- Respond to a simulated CloudWatch alarm notification
- Use CloudWatch Logs Insights to investigate a Lambda function error

**Content Outline:**
1. Dashboard tour (30 min) — API Health, ML Pipeline, and Business Metrics dashboards explained
2. Alarm configuration review (30 min) — all 8 defined alarms, thresholds, and SNS routing
3. Simulated alarm response lab (30 min) — responding to a test HIGH alarm notification
4. CloudWatch Logs Insights query lab (30 min) — diagnosing a simulated Lambda error

**Lab Exercises:**
- Exercise 1: Identify a latency spike in the API Health dashboard and locate the root-cause Lambda log
- Exercise 2: Run a Logs Insights query to find all errors in the Playlist Generator log group in the last 24 hours
- Exercise 3: Respond to a simulated DLQ alarm notification using the operational runbook procedure

### TRN-005: SageMaker Model Management and Retraining (3 hours, Hands-On Lab)

**Learning Objectives:**
- Review SageMaker Model Registry for available model versions and their approval status
- Trigger a manual SageMaker Pipelines retraining execution
- Evaluate a new model version against the holdout set using the provided evaluation script
- Execute a model rollback to a previous approved version within 10 minutes

**Content Outline:**
1. SageMaker Model Registry walkthrough (30 min) — approved versions, evaluation metrics, deployment history
2. Retraining pipeline overview (30 min) — pipeline steps, conditional promotion logic, CloudWatch execution logs
3. Manual retraining trigger lab (45 min) — triggering a manual pipeline run and monitoring execution
4. Model evaluation and promotion lab (30 min) — reviewing holdout metrics and approving a model version
5. Model rollback drill (45 min) — rolling back to the previous approved model version in < 10 minutes

**Lab Exercises:**
- Exercise 1: Locate the current production model version in SageMaker Model Registry
- Exercise 2: Trigger a manual retraining pipeline execution and monitor its progress
- Exercise 3: Execute the model rollback runbook procedure from start to endpoint-in-service confirmation

### TRN-006: API Operations and Cognito User Management (2 hours, ILT)

**Learning Objectives:**
- Review API Gateway endpoint configurations, usage plans, and WAF associations
- Create a new Cognito user and assign them to the `artist` role group
- Rotate API keys and update Secrets Manager with the new key
- Interpret API Gateway access logs for request tracing

**Content Outline:**
1. API Gateway console review (30 min) — stages, endpoints, usage plans, WAF association
2. Cognito User Pool management (45 min) — creating users, managing groups, MFA configuration, audit logs
3. Secrets Manager rotation walkthrough (30 min) — manual rotation trigger, verification, Lambda behavior post-rotation
4. API access log interpretation (15 min) — reading structured access log entries in CloudWatch

### TRN-007: Security Runbook — IAM, KMS, WAF, and Secrets Manager (2 hours, Hands-On Lab)

**Learning Objectives:**
- Conduct a quarterly IAM access review using IAM Access Analyzer
- Verify KMS key rotation status and manually trigger a key rotation
- Review WAF WebACL logs for blocked requests in the last 24 hours
- Rotate a Secrets Manager secret and verify Lambda function behavior post-rotation

**Content Outline:**
1. IAM access review procedure (30 min) — using IAM Access Analyzer and reviewing Lambda execution role permissions
2. KMS key management (30 min) — rotation status, policy review, and manual rotation trigger
3. WAF log analysis (30 min) — using CloudWatch Logs Insights to identify WAF-blocked requests
4. Secrets Manager rotation lab (30 min) — manual rotation and post-rotation Lambda invocation test

## End User Training

### TRN-009: Artist/Uploader — Content Classification Endpoint Usage (1 hour, VILT)

**Learning Objectives:**
- Submit a catalog item to the `/api/v1/content/classify` endpoint using the provided API client or Postman
- Interpret the returned emotion, mood, and thematic attribute scores
- Understand the expected classification latency (asynchronous via Step Functions)
- Access the enriched catalog record in the DynamoDB console (read-only) to verify classification results

**Content Outline:**
1. Classification endpoint overview (15 min) — request format, response format, Step Functions execution ARN
2. Hands-on classification submission (30 min) — submit a sample lyric file and poll for enrichment results
3. Interpreting emotion scores (10 min) — how to map scores to the mood taxonomy labels
4. Q&A and support resources (5 min)

**Materials Required:**
- Postman collection with `POST /api/v1/content/classify` pre-configured
- Sample lyric text file for the lab exercise
- Staging environment access with `artist` role Cognito credentials

### TRN-010: End User Training — Mood Input, Playlists, and Feedback (1 hour, VILT)

Listener-role and QA tester training covers the core end user experience of the ANP Streaming AI Recommendation Engine through the FlutterFlow application and direct API interaction.

**Learning Objectives:**
- Authenticate via Cognito and obtain a valid JWT for API access
- Submit a mood input to the `/api/v1/playlists` endpoint and receive a personalized playlist
- Submit a play/skip/like/dislike feedback event to the `/api/v1/interactions` endpoint
- Understand how feedback signals improve future playlist personalization
- Access support channels and escalate issues appropriately

**Content Outline:**
1. Authentication and session setup (10 min) — Cognito login flow from FlutterFlow and direct API access
2. Playlist generation walkthrough (20 min) — submitting mood inputs, interpreting the returned track list
3. Feedback submission lab (15 min) — recording play, skip, like, and dislike events via the feedback endpoint
4. Personalization feedback loop explanation (10 min) — how interaction events improve future recommendations
5. Support resources and FAQ (5 min)

**Materials Required:**
- FlutterFlow application access pointing to Staging API endpoint
- Postman collection for direct API testing (QA testers)
- Staging Cognito `listener` role credentials
- Quick Reference Card: mood taxonomy labels and their expected playlist character

## IT Support Training

### TRN-008: Incident Response and Disaster Recovery Procedures (2 hours, Workshop)

**Learning Objectives:**
- Execute the full incident response runbook for a SageMaker endpoint failure scenario
- Complete a DynamoDB PITR table restore and validate data integrity within the 4-hour RTO target
- Roll back a Lambda function to a previous version within the 30-minute rollback window
- Document and escalate an unresolved incident per the support tier model

**Content Outline:**
1. Incident classification and response framework (20 min) — severity levels, response times, escalation paths
2. SageMaker endpoint failure scenario drill (30 min) — end-to-end runbook execution from alarm to endpoint-in-service
3. DynamoDB PITR restore drill (40 min) — full restore procedure and data integrity validation
4. Lambda rollback drill (20 min) — alias-based rollback procedure
5. Documentation and escalation practice (10 min)

**Lab Exercises:**
- Exercise 1: Execute the SageMaker Endpoint Failure runbook from CloudWatch alarm to resolution (< 30 minutes target)
- Exercise 2: Restore a DynamoDB table from PITR to 60 minutes ago and validate item count matches pre-restore baseline

## Train-the-Trainer

### TRN-011: Train-the-Trainer Workshop (2 hours, Workshop)

**Learning Objectives:**
- Deliver TRN-009 (Artist/Uploader) and TRN-010 (End User) training modules independently
- Set up the Staging sandbox environment for new user training sessions
- Handle common questions from artists and listeners during training delivery
- Assess learner competency and escalate unresolved training gaps

**Content Outline:**
1. Facilitator guide walkthrough for TRN-009 and TRN-010 (30 min)
2. Sandbox environment reset procedure (20 min) — ensuring clean state for each new cohort
3. Common question handling practice (30 min) — role-play with simulated attendee questions
4. Competency assessment procedures (20 min) — knowledge check facilitation and escalation
5. Training materials package review (20 min) — all materials confirmed accessible

## Training Materials

### Documentation Provided

All training materials are delivered as part of the Final Deliverable Package (SOW Deliverable 27):

- Administrator Guide (PDF, delivered with Operational Runbooks — SOW Deliverable 24)
- API Operations Quick Reference (PDF, 8 pages)
- End User Quick Reference Card — Mood Input and Feedback Guide (PDF, 2 pages, per role)
- Artist/Uploader Quick Reference Card — Classification Endpoint Guide (PDF, 2 pages)
- Postman Collection: Full API contract test suite (JSON)
- Video recordings of both KT sessions (screen recordings via video conference platform)
- Lab exercise workbooks for TRN-003, TRN-005, TRN-007, TRN-008 (PDF)

### Training Environment

- **Sandbox:** Staging environment is used for all hands-on training; maintained in a clean, operational state throughout the engagement
- **Access Duration:** Staging environment access for ANP team provisioned from Week 10 through the end of the 2-week hypercare period
- **Data:** Staging uses a 20-item anonymized catalog sample (no real user PII); sufficient for all classification and playlist demonstrations

## Training Effectiveness

### Assessment Approach

- **Knowledge Checks:** Brief verbal or written quiz at the end of each technical module (TRN-001 through TRN-008); passing benchmark is 80% correct on 5 questions
- **Practical Assessment:** Completion of assigned lab exercises with demonstrated proficiency observed by nClouds facilitator
- **KT Session Confirmation:** Attendance records for both formal KT sessions signed by ANP Technical Lead and Lilly Goyah (CEO) — required for SOW milestone M7 closure

### Success Metrics

The table below defines the measurable success targets for the training program.

| Metric | Target |
|--------|--------|
| Training Completion Rate | 100% of named technical stakeholders (ANP Tech Lead, Infra Architect, Security Owner) |
| Knowledge Check Pass Rate | ≥ 80% correct on all module knowledge checks |
| Lab Exercise Completion Rate | 100% of required lab exercises completed in Staging |
| KT Session Attendance | Both sessions attended by all named attendees (per SOW Deliverables 25 & 26) |
| Post-Training Confidence Survey | ≥ 4.0/5.0 self-reported confidence in operational procedures |
| Operational Independence | ANP Tech Lead executes first post-training retraining trigger independently |

---

# Appendices

## Appendix A: Environment Details

### Development Environment

The following table lists the key configuration values for the Dev environment provisioned during this engagement.

| Component | Value |
|-----------|-------|
| AWS Account ID | [aws-account-id] |
| Region | us-east-1 |
| VPC CIDR | 10.10.0.0/16 |
| VPC ID | Provisioned by CDK — see `outputs/dev-foundation-outputs.json` |
| API Gateway URL | Provisioned by CDK — see `outputs/dev-compute-outputs.json` |
| Cognito User Pool ID | Provisioned by CDK — see `outputs/dev-security-outputs.json` |
| Content Catalog Table | anp-dev-content-catalog |
| User Profile Table | anp-dev-user-profiles |
| Interaction Events Table | anp-dev-interaction-events |
| Mood Taxonomy Table | anp-dev-mood-taxonomy |
| NLP Classifier Endpoint | anp-dev-nlp-classifier-endpoint |
| Audio Extractor Endpoint | anp-dev-audio-extractor-endpoint |
| Feedback Queue | anp-dev-feedback-capture |
| Access Method | Named IAM users with MFA (nClouds: full access; ANP Tech Lead: read access) |
| Log Retention | 30 days |

### Staging Environment

The following table lists the key configuration values for the Staging environment.

| Component | Value |
|-----------|-------|
| AWS Account ID | [aws-account-id] (same dedicated account, different CDK context) |
| Region | us-east-1 |
| VPC CIDR | 10.10.0.0/16 |
| Content Catalog Table | anp-staging-content-catalog |
| User Profile Table | anp-staging-user-profiles |
| NLP Classifier Endpoint | anp-staging-nlp-classifier-endpoint |
| API Gateway URL | Provisioned by CDK — see `outputs/staging-compute-outputs.json` |
| Access Method | nClouds: full access; ANP Tech Lead: full access; ANP CEO: read access |
| Log Retention | 90 days |
| Notes | Mirrors Dev architecture; used for UAT, performance testing, and KT sessions |

## Appendix B: Configuration Reference

Key configuration parameters are managed in `infrastructure/config/dev.yaml` and `infrastructure/config/staging.yaml`, and enforced at deploy time by the CDK application. The authoritative parameter list is in `configuration.csv` in this delivery package. The table below lists selected critical parameters.

| Parameter | Dev Value | Staging Value | Notes |
|-----------|-----------|---------------|-------|
| `application.api_rate_limit_rps` | 50 | 100 | Increase at 10K MAU tier |
| `compute.lambda.playlist.memory_mb` | 1024 | 1024 | Critical for ≤ 2s API SLA |
| `ml.classifier.confidence_threshold` | 0.75 | 0.75 | Bedrock fallback below this |
| `ml.retraining.schedule_expression` | `cron(0 2 ? * MON *)` | `cron(0 2 ? * MON *)` | Configurable per runbook |
| `security.kms.rotation_enabled` | true | true | Do not disable |
| `database.pitr_enabled` | true | true | Required for RPO target |
| `cache.playlist_ttl_seconds` | 600 | 600 | 10-minute cache |
| `operations.rto_hours` | 4 | 4 | DynamoDB PITR restore target |
| `operations.rpo_hours` | 1 | 1 | PITR continuous backup |

## Appendix C: Deployment Scripts

### deploy.sh — Full Stack Deployment

The following script deploys all ANP Recommendation Engine CDK stacks to a target environment in dependency order.

```bash
#!/bin/bash
# deploy.sh — Deploy all ANP Recommendation Engine CDK stacks to target environment
# Usage: ./deploy.sh [dev|staging] [aws-profile]

set -e

ENVIRONMENT=${1:-dev}
PROFILE=${2:-anp-delivery}

echo "====================================================="
echo "ANP AI Recommendation Engine — Deployment Script"
echo "Environment: $ENVIRONMENT | Profile: $PROFILE"
echo "====================================================="

aws sts get-caller-identity --profile $PROFILE || { echo "ERROR: AWS credentials not configured"; exit 1; }

cd infrastructure

STACKS=("AnpNetworkingStack" "AnpSecurityStack" "AnpMlStack" "AnpComputeStack" "AnpMonitoringStack")

for stack in "${STACKS[@]}"; do
  echo "Deploying $stack..."
  cdk deploy $stack \
    --context environment=$ENVIRONMENT \
    --profile $PROFILE \
    --require-approval never \
    --outputs-file outputs/${ENVIRONMENT}-${stack,,}-outputs.json
  echo "$stack deployed successfully."
done

API_URL=$(cat outputs/${ENVIRONMENT}-anpcomputestack-outputs.json | python -c "import sys,json; d=json.load(sys.stdin); print(list(d.values())[0].get('ApiGatewayUrl','not-found'))")
curl -s -o /dev/null -w "Health endpoint HTTP status: %{http_code}\n" \
  "$API_URL/api/v1/health" \
  -H "x-api-key: [internal-api-key]"

echo "Deployment complete for $ENVIRONMENT environment."
```

### rollback.sh — Stack Rollback

The following script rolls back a named CDK stack to its previous CloudFormation state.

```bash
#!/bin/bash
# rollback.sh — Rollback ANP deployment to previous CloudFormation state
# Usage: ./rollback.sh [dev|staging] [stack-name] [aws-profile]

set -e

ENVIRONMENT=${1:-dev}
STACK=${2:-AnpComputeStack}
PROFILE=${3:-anp-delivery}

echo "Rolling back $STACK in $ENVIRONMENT environment..."

aws cloudformation cancel-update-stack \
  --stack-name $STACK \
  --profile $PROFILE 2>/dev/null || echo "No update in progress."

aws cloudformation wait stack-rollback-complete \
  --stack-name $STACK \
  --profile $PROFILE

echo "Rollback complete for $STACK."
# For Lambda alias rollback:
# aws lambda update-alias --function-name [fn] --name live --function-version [prev-version]
# For SageMaker model rollback:
# aws sagemaker update-endpoint --endpoint-name [ep] --endpoint-config-name [prev-config]
```

## Appendix D: Troubleshooting Guide

This guide covers the 8 most common operational issues and their resolutions, sourced from the Detailed Design Document risk register and Phase 5 DR test results.

### Issue 1: Playlist API Latency Exceeds 2 Seconds

**Symptoms:**
- CloudWatch alarm `anp-{env}-playlist-api-latency` enters ALARM state
- p95 latency > 3,000 ms in API Health dashboard

**Cause:** ElastiCache cache miss storm, Personalize campaign TPS saturation, or SageMaker endpoint cold start.

**Resolution:**

```bash
# Check ElastiCache cache hit ratio
aws cloudwatch get-metric-statistics \
  --namespace AWS/ElastiCache \
  --metric-name CacheHitRate \
  --start-time $(date -u -v-1H '+%Y-%m-%dT%H:%M:%SZ') \
  --end-time $(date -u '+%Y-%m-%dT%H:%M:%SZ') \
  --period 300 --statistics Average \
  --profile anp-delivery
# If CacheHitRate < 0.80: investigate unusually high unique user load

# Check SageMaker endpoint utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/SageMaker \
  --metric-name InvocationsPerInstance \
  --dimensions Name=EndpointName,Value=anp-dev-nlp-classifier-endpoint \
  --start-time $(date -u -v-30M '+%Y-%m-%dT%H:%M:%SZ') \
  --end-time $(date -u '+%Y-%m-%dT%H:%M:%SZ') \
  --period 60 --statistics Average \
  --profile anp-delivery
```

**Prevention:** Ensure ElastiCache cache is enabled (`cache.enabled=true`). Verify SageMaker auto-scaling policy is active with `sagemaker_scale_threshold_pct=70`.

### Issue 2: SageMaker Endpoint Not InService

**Symptoms:**
- CloudWatch alarm `anp-{env}-sagemaker-endpoint-down` triggers
- Endpoint status is not `InService`

**Cause:** Endpoint instance failure, model container crash, or resource quota exhaustion.

**Resolution:**

```bash
# Check endpoint failure reason
aws sagemaker describe-endpoint \
  --endpoint-name anp-dev-nlp-classifier-endpoint \
  --query '{Status:EndpointStatus,FailureReason:FailureReason}' \
  --profile anp-delivery

# Restart endpoint by re-applying current config
CURRENT_CONFIG=$(aws sagemaker describe-endpoint \
  --endpoint-name anp-dev-nlp-classifier-endpoint \
  --query 'EndpointConfigName' --output text --profile anp-delivery)

aws sagemaker update-endpoint \
  --endpoint-name anp-dev-nlp-classifier-endpoint \
  --endpoint-config-name $CURRENT_CONFIG \
  --profile anp-delivery

aws sagemaker wait endpoint-in-service \
  --endpoint-name anp-dev-nlp-classifier-endpoint \
  --profile anp-delivery
```

### Issue 3: SQS Feedback DLQ Message Count Elevated

**Symptoms:**
- CloudWatch alarm `anp-{env}-feedback-dlq-depth` triggers (DLQ count > 10)
- Feedback events not reflected in DynamoDB user preference updates

**Cause:** Preference Update Lambda throwing exceptions; possible DynamoDB throttling or schema validation error.

**Resolution:**

```bash
# Inspect a DLQ message to identify the error
aws sqs receive-message \
  --queue-url [anp-dev-feedback-dlq-url] \
  --max-number-of-messages 1 \
  --profile anp-delivery

# Check Preference Update Lambda error logs
aws logs filter-log-events \
  --log-group-name /aws/lambda/anp-dev-preference-update \
  --filter-pattern "ERROR" \
  --start-time $(date -u -v-1H '+%s000') \
  --profile anp-delivery

# After fixing the Lambda, redrive DLQ messages to main queue
aws sqs start-message-move-task \
  --source-arn [anp-dev-feedback-dlq-arn] \
  --destination-arn [anp-dev-feedback-queue-arn] \
  --profile anp-delivery
```

### Issue 4: Retraining Pipeline Produces Degraded Model

**Symptoms:**
- New model version fails conditional promotion check in SageMaker Model Registry

**Cause:** Insufficient interaction data volume or training data quality issue.

**Resolution:**

```bash
# Review pipeline execution details
aws sagemaker list-pipeline-executions \
  --pipeline-name anp-staging-retraining-pipeline \
  --sort-by CreationTime \
  --sort-order Descending \
  --max-results 1 \
  --profile anp-delivery

# The conditional_promotion=true setting prevents automatic degraded model deployment.
# Current production model is unchanged; investigate data quality before next retraining run.
echo "Conditional promotion blocked degraded model. Current production model is unchanged."
```

### Issue 5: CloudTrail Log Delivery Gap

**Symptoms:**
- CloudTrail S3 bucket shows no new objects for > 15 minutes

**Resolution:**

```bash
# Check CloudTrail status and restart if needed
aws cloudtrail get-trail-status \
  --name anp-dev-cloudtrail \
  --query '{IsLogging:IsLogging,LatestDeliveryError:LatestDeliveryError}' \
  --profile anp-delivery

aws cloudtrail start-logging \
  --name anp-dev-cloudtrail \
  --profile anp-delivery
```

### Issue 6: Cognito JWT Validation Failures at Scale

**Symptoms:**
- High volume of HTTP 401 responses in API Gateway access logs
- Lambda Authorizer DurationInMillis spiking

**Cause:** Cognito public key cache miss during Lambda Authorizer cold start.

**Resolution:**

```bash
# Check Lambda Authorizer error logs
aws logs filter-log-events \
  --log-group-name /aws/lambda/anp-dev-api-authorizer \
  --filter-pattern "TokenExpiredError OR InvalidSignatureError" \
  --start-time $(date -u -v-30M '+%s000') \
  --profile anp-delivery

# Mitigation: Increase JWT access token expiry to 120 minutes
aws cognito-idp update-user-pool-client \
  --user-pool-id [user-pool-id] \
  --client-id [client-id] \
  --access-token-validity 120 \
  --token-validity-units '{"AccessToken":"minutes"}' \
  --profile anp-delivery
```

### Issue 7: DynamoDB ThrottledRequests Alarm

**Symptoms:**
- `ThrottledRequests > 0` sustained for 5+ minutes

**Cause:** Unusual burst in on-demand capacity; DynamoDB auto-scaling requires up to 5 minutes to adapt.

**Resolution:**

```bash
# Identify which table is throttling
aws cloudwatch get-metric-statistics \
  --namespace AWS/DynamoDB \
  --metric-name ThrottledRequests \
  --dimensions Name=TableName,Value=anp-dev-content-catalog \
  --start-time $(date -u -v-30M '+%Y-%m-%dT%H:%M:%SZ') \
  --end-time $(date -u '+%Y-%m-%dT%H:%M:%SZ') \
  --period 60 --statistics Sum \
  --profile anp-delivery
# DynamoDB on-demand auto-scales within 5-10 minutes; monitor and allow time to resolve.
```

### Issue 8: Firebase REST API Timeout in Enrichment Lambda

**Symptoms:**
- Step Functions enrichment executions timing out at the Firebase read step
- Lambda logs show `ConnectionTimeout` or `ReadTimeout` errors

**Resolution:**

```bash
# Test Firebase connectivity from within the VPC via Lambda test invocation
aws lambda invoke \
  --function-name anp-dev-catalog-enrichment \
  --payload '{"action":"health_check_firebase"}' \
  --profile anp-delivery \
  response.json
cat response.json
# Step Functions retry policy (IntervalSeconds: 2, MaxAttempts: 3) will auto-retry.
# After 3 failures the Catch state writes a partial enrichment (NLP/audio only).
```

## Appendix E: Contact Information

### Project Team

The following table lists all key project team members and their contact details.

| Role | Name | Email | Organization |
|------|------|-------|--------------|
| Project Manager | nClouds PM | pm@nclouds.com | nClouds, Inc. |
| Solution Architect / Tech Lead | Jonas Bull | jonas@nclouds.com | nClouds, Inc. |
| Commercial Sponsor | Andrew Brewer | andrew@nclouds.com | nClouds, Inc. |
| Executive Sponsor | Lilly Goyah (CEO) | lilly@anpstreaming.com | ANP Streaming |
| Application/Workload Owner | ANP Technical Lead | [anp-tech-lead@anpstreaming.com] | ANP Streaming |

### Escalation Contacts

| Level | Contact | Availability | Purpose |
|-------|---------|--------------|---------|
| Primary (Hypercare) | Jonas Bull — nClouds SA | Business hours ET | Bug fixes and operational guidance during hypercare |
| Secondary (Commercial) | Andrew Brewer — nClouds SVP Sales | Business hours PT | Contract and scope escalation |
| Emergency | nClouds Support Channel | Dedicated Slack / email | Critical incidents during hypercare window |

### Vendor Support

| Vendor | Support Portal | SLA |
|--------|----------------|-----|
| AWS (Business Support) | console.aws.amazon.com/support | 1-hour critical, 4-hour high |
| AWS Partner Network (APFP) | partnercentral.awspartner.com | nClouds manages APFP portal |

## Appendix F: AWS Well-Architected Security Pillar Validation Checklist

The following checklist documents the SEC 01–SEC 07 validation status at engagement close and must be signed off by the ANP Technical Lead before the engagement is formally closed.

| Pillar Requirement | Implementation | Status |
|-------------------|----------------|--------|
| SEC 01: Strong Identity Foundation | Cognito User Pool with JWT; IAM least-privilege; MFA on admin accounts; IAM Access Analyzer enabled | ☐ Validated |
| SEC 02: Enable Traceability | CloudTrail management-event trail with S3 Object Lock; CloudWatch Logs for all Lambda, API GW, and SageMaker | ☐ Validated |
| SEC 03: Apply Security at All Layers | WAF at API Gateway; security groups for VPC resources; KMS encryption at rest; TLS 1.2+ in transit | ☐ Validated |
| SEC 04: Automate Security Best Practices | AWS Config managed rules; CDK/CloudFormation IaC; automated Secrets Manager rotation (90-day) | ☐ Validated |
| SEC 05: Protect Data in Transit and at Rest | KMS CMK encryption on all DynamoDB tables and S3 buckets; TLS 1.2+ for all API and service communications | ☐ Validated |
| SEC 06: Keep People Away from Data | No direct developer access to DynamoDB production tables; all data access through IAM-scoped Lambda roles | ☐ Validated |
| SEC 07: Prepare for Security Events | GuardDuty threat detection; Security Hub aggregated findings; SNS alerting; documented security incident runbook | ☐ Validated |

*This checklist is completed during the Phase 5 security validation review and submitted as part of the Final Deliverable Package (SOW Deliverable 27).*
