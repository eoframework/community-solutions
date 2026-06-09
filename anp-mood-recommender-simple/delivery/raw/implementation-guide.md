---
document_title: Implementation Guide
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

## Project Overview

This Implementation Guide provides step-by-step procedures for deploying the ANP Streaming AI Mood & Recommendation API — a fully serverless AWS backend that introduces AI-powered mood/emotion classification and personalized playlist recommendations to ANP Streaming's existing faith-based music and podcast platform. The solution exposes two production REST API endpoints (`POST /classify` and `GET /recommend`) callable from the existing FlutterFlow mobile app without any frontend changes, together with an automated mood-tagging pipeline for new catalog uploads.

This guide is the primary operational reference for the nClouds delivery team and the ANP Streaming technical contact throughout all three implementation phases. It translates the commitments in SOW v1.0 (Opportunity OPP-2025-001) into executable, verified procedures. Every phase name, duration, and deliverable in this document aligns exactly with the SOW Deliverables & Timeline section.

## Implementation Scope

- **In Scope:**
  - AWS environment setup (IAM, API Gateway, Lambda, DynamoDB, S3, CloudWatch, Secrets Manager, Cognito) for Dev and Production in us-east-1
  - Amazon Bedrock on-demand foundation model integration for mood/emotion classification
  - `POST /classify` Lambda function and API Gateway endpoint
  - `GET /recommend` Lambda function and API Gateway endpoint
  - Auto-Tagging batch Lambda pipeline triggered on S3 catalog uploads
  - DynamoDB schema design and seed data load from Firebase catalog export
  - API key authentication, HTTPS enforcement, IAM least-privilege policies, and Secrets Manager configuration
  - CloudWatch dashboards, Lambda error alarms, and API Gateway latency alerting
  - Infrastructure as Code (AWS CDK/CloudFormation) for repeatable environment deployments
  - Developer-facing API reference documentation and operational runbook
  - Live knowledge transfer session (recorded) and two-week post-go-live hypercare support

- **Out of Scope:**
  - Firebase data migration, restructuring, or real-time Firebase-to-DynamoDB synchronization
  - Any changes to the FlutterFlow mobile frontend, UI components, or Firebase Authentication flows
  - Custom ML model training, fine-tuning, or hosting
  - Amazon Personalize or any dedicated collaborative-filtering recommendation service
  - A dedicated staging or QA environment (only Dev and Production are provisioned)
  - PCI-DSS, HIPAA, or SOC 2 compliance audit and certification
  - Ongoing managed services or 24x7 support beyond the 2-week hypercare period
  - Content delivery or CDN configuration for audio streaming

- **Dependencies:**
  - ANP Streaming AWS account with admin access granted to nClouds by Week 1 Day 1
  - Firebase catalog export (lyrics and transcripts) available for S3 upload by Week 2 Day 1
  - ANP designated technical contact available 4 hours/week throughout the engagement
  - Amazon Bedrock on-demand inference availability in us-east-1 confirmed in Week 1
  - FlutterFlow app HTTPS outbound REST API call capability confirmed before Week 5 UAT

## Timeline Overview

- **Project Duration:** 6 weeks
- **Go-Live Date:** End of Week 5
- **Hypercare End / Project Close:** End of Week 7 (2 weeks post-go-live)
- **Key Milestones:**
  - M1 — Kickoff Complete: Week 1
  - M2 — Architecture Signed Off and Dev Environment Live: Week 2
  - M3 — Classification Endpoint Live in Dev: Week 3
  - M4 — Recommendation Endpoint and Auto-Tagger Live in Dev: Week 4
  - M5 — Testing Complete: Week 5
  - M6 — Production Go-Live: Week 5
  - M7 — Hypercare End / Project Close: Week 6+

---

# Prerequisites

This section defines all items that must be complete before Phase 1 implementation activities begin. All checklist items are specific and actionable — do not proceed to Environment Setup until each item is verified.

## Technical Prerequisites

Complete these items before starting Phase 1:

### Cloud Infrastructure

- [ ] ANP Streaming AWS account created and active (account ID provided to nClouds)
- [ ] Administrator IAM access provisioned for nClouds engagement team (Jonas Bull + engineering team) with MFA enforced
- [ ] AWS root account secured with hardware MFA device; root credentials not used for day-to-day operations
- [ ] AWS Billing Alerts configured at $500/month threshold via CloudWatch billing alarms
- [ ] Resource quotas verified for us-east-1: Lambda concurrent executions >= 1,000; API Gateway requests >= 10,000/second
- [ ] Amazon Bedrock on-demand inference availability confirmed for Anthropic Claude 3 Haiku or Amazon Titan Text G1 in us-east-1

### Network Connectivity

- [ ] API Gateway regional endpoint type confirmed as appropriate (no Direct Connect or VPC private endpoint required)
- [ ] TLS 1.2+ outbound HTTPS confirmed as supported from the FlutterFlow mobile app environment
- [ ] No corporate proxy or firewall blocks outbound HTTPS to `*.execute-api.us-east-1.amazonaws.com` from the app

### Security Baseline

- [ ] Named IAM users created for nClouds engineering team with MFA enforced (not root; not shared accounts)
- [ ] AWS Secrets Manager enabled in us-east-1
- [ ] AWS CloudTrail enabled on the ANP Streaming AWS account (multi-region trail recommended)
- [ ] GitHub repository (or AWS CodeCommit) provisioned for Lambda source code and IaC codebase

### Development Tools

- [ ] AWS CLI v2 installed and configured on nClouds engineering workstations (`aws configure --profile anp-dev`)
- [ ] AWS CDK CLI installed (`npm install -g aws-cdk`; CDK version >= 2.x)
- [ ] Node.js 18+ and Python 3.12 installed on all engineering workstations
- [ ] Python `boto3` SDK version >= 1.34 available
- [ ] `pytest` and Postman/Newman installed for functional testing
- [ ] Artillery CLI installed for performance load testing (`npm install -g artillery`)

## Organizational Prerequisites

- [ ] ANP Streaming technical contact identified by name and made available 4 hours/week
- [ ] Lilly Goyah (CEO) confirmed as executive sponsor and available for milestone reviews within 3 business days
- [ ] AWS partner funding application submitted by nClouds (Opportunity OPP-2025-001)
- [ ] Change management process activated — all scope changes require written Change Order
- [ ] Communication plan activated — weekly status report from nClouds PM to Lilly Goyah and ANP technical contact

## Environmental Setup

### Development Environment

- [ ] ANP Streaming AWS account access granted to nClouds Dev team (us-east-1 region only)
- [ ] CDK bootstrap completed in the dev account/region: `cdk bootstrap aws://<account-id>/us-east-1`
- [ ] GitHub repo cloned and branch strategy agreed (`main` = production-ready; `develop` = dev integration)
- [ ] Dev AWS environment tag strategy confirmed: `Environment=dev`, `Project=ANPStreamingAI`

### Production Environment

- [ ] Production environment uses the same ANP Streaming AWS account with environment separation by resource naming and tags
- [ ] Production IAM access restricted: nClouds engineers have read-only CloudWatch access; IaC pipeline applies all changes
- [ ] Production go-live approval process confirmed: Jonas Bull + ANP technical contact + Lilly Goyah sign-off required

### Firebase Export Readiness

- [ ] Firebase catalog export format confirmed (CSV or JSON) with ANP team
- [ ] Minimum 200 catalog items with lyric/transcript text confirmed available for Week 2 export
- [ ] Firebase export delivery mechanism confirmed (direct S3 upload or file transfer to nClouds for processing)

---

# Environment Setup

This section covers phased environment provisioning and baseline configuration before core infrastructure deployment begins. Activities follow the three-phase structure defined in the SOW.

## Phase 1: Discovery and Design (Weeks 1-2)

### Objectives

- Conduct project kickoff and align all stakeholders on goals, timeline, and AWS funding eligibility
- Validate Firebase catalog text quality and confirm Bedrock model suitability for faith-based content
- Provision the Dev AWS environment baseline (IAM, S3, DynamoDB scaffolding, Lambda scaffold, API Gateway, Secrets Manager)
- Configure security baseline: IAM least-privilege, API key auth, HTTPS, Secrets Manager, CloudWatch log groups
- Finalize API schemas (`POST /classify` and `GET /recommend`) with ANP technical contact
- Produce the Discovery Summary Report (architecture decision record + confirmed scope) for Lilly Goyah sign-off

### Activities

The following table lists all Phase 1 activities with owner, duration, and dependencies:

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Project kickoff meeting with Lilly Goyah and nClouds team | Project Manager | 1 day | SOW signed |
| Firebase catalog structure review (titles, artists, lyrics, transcripts) | Solution Architect | 2 days | Kickoff |
| Functional requirements documentation and API schema agreement | Solution Architect | 2 days | Catalog review |
| AWS architecture design (Lambda, Bedrock, API GW, DynamoDB, S3) | Solution Architect | 3 days | Requirements |
| Bedrock model data quality assessment on faith-based content sample | ML/AI Engineer | 2 days | Architecture design |
| Risk assessment and mitigation documentation | Project Manager | 1 day | Architecture design |
| Dev AWS environment provisioning (IAM, S3, DynamoDB, Lambda, API GW, Secrets Manager) | Cloud Engineer | 3 days | Architecture design |
| Security baseline configuration (IAM policies, API key, HTTPS, CloudWatch logs) | Security Engineer | 2 days | Dev environment |
| Firebase catalog export to S3 (`anp-catalog/` prefix) | Cloud Engineer + ANP | 1 day | S3 bucket created |
| Discovery Summary Report drafting and client review | Solution Architect | 2 days | All Phase 1 activities |

### Detailed Procedures

#### 1.1 CDK Bootstrap and Dev Environment Initialization

All infrastructure is provisioned via AWS CDK (TypeScript). Before any stack deployment, bootstrap CDK in the target account and region:

```bash
# Set AWS CLI profile for the ANP account
export AWS_PROFILE=anp-dev
export AWS_DEFAULT_REGION=us-east-1

# Bootstrap CDK (one-time per account/region)
cdk bootstrap aws://$(aws sts get-caller-identity --query Account --output text)/us-east-1

# Verify bootstrap completion
aws cloudformation describe-stacks \
  --stack-name CDKToolkit \
  --query 'Stacks[0].StackStatus'
# Expected: "CREATE_COMPLETE" or "UPDATE_COMPLETE"
```

#### 1.2 IAM Roles and Security Baseline

The security baseline must be provisioned before any Lambda functions are deployed. Each Lambda execution role follows strict least-privilege scoping:

```bash
# Deploy the IAM and Secrets Manager baseline stack
cd infrastructure/stacks/security
cdk deploy ANPSecurityDevStack \
  --require-approval never \
  --tags Environment=dev \
  --tags Project=ANPStreamingAI \
  --tags Owner=nclouds \
  --tags CostCenter=OPP-2025-001 \
  --tags ManagedBy=cdk

# Verify IAM roles were created
aws iam list-roles \
  --query "Roles[?starts_with(RoleName, 'anp-')].[RoleName, CreateDate]" \
  --output table
```

Expected roles after deployment are listed in the following table:

| Role | Purpose |
|------|---------|
| `anp-classifier-lambda-role` | Classifier Lambda execution |
| `anp-recommender-lambda-role` | Recommender Lambda execution |
| `anp-autotagger-lambda-role` | Auto-Tagger Lambda execution |

#### 1.3 Secrets Manager Baseline

Before any Lambda function accesses secrets, seed placeholder values in Secrets Manager. These are replaced with actual credentials during Phase 2:

```bash
# Create placeholder for Firebase service account key
aws secretsmanager create-secret \
  --name "anp/dev/firebase-service-account" \
  --description "Firebase service account JSON key - ANP dev" \
  --secret-string '{"placeholder": "replace-before-phase-2"}' \
  --tags '[{"Key":"Project","Value":"ANPStreamingAI"},{"Key":"Environment","Value":"dev"}]'

# Create placeholder for API key (used by POST /classify)
aws secretsmanager create-secret \
  --name "anp/dev/api-key" \
  --description "API Gateway API key - ANP dev" \
  --secret-string '{"api_key": "placeholder-replace-before-testing"}' \
  --tags '[{"Key":"Project","Value":"ANPStreamingAI"},{"Key":"Environment","Value":"dev"}]'

# Verify secrets created
aws secretsmanager list-secrets \
  --query "SecretList[?starts_with(Name, 'anp/')].Name"
```

#### 1.4 S3 Catalog Bucket Creation

The S3 catalog bucket must exist before the Firebase export can be uploaded and before the Auto-Tagger Lambda is deployed:

```bash
# Get account ID for globally unique bucket name
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="anp-catalog-${ACCOUNT_ID}-dev"

# Create bucket with versioning and SSE-S3 encryption
aws s3api create-bucket --bucket $BUCKET_NAME --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled

# Verify configuration
aws s3api get-bucket-versioning --bucket $BUCKET_NAME
# Expected: {"Status": "Enabled"}

echo "Catalog bucket ready: s3://$BUCKET_NAME/catalog/"
```

#### 1.5 Firebase Catalog Export Upload

Once ANP Streaming provides the Firebase catalog export file, upload it to the S3 catalog prefix for processing:

```bash
# Upload Firebase export CSV to S3 catalog prefix
aws s3 cp firebase-catalog-export.csv \
  s3://${BUCKET_NAME}/catalog/seed/firebase-catalog-export.csv \
  --sse AES256

# Verify upload
aws s3 ls s3://${BUCKET_NAME}/catalog/seed/
```

### Deliverables

- [ ] CDK bootstrap complete in ANP Streaming account (us-east-1)
- [ ] Security baseline stack deployed (`ANPSecurityDevStack`)
- [ ] IAM execution roles for all three Lambda functions created
- [ ] Secrets Manager placeholders for Firebase service account and API key created
- [ ] S3 catalog bucket created with versioning and SSE-S3 encryption
- [ ] Firebase catalog export uploaded to `s3://anp-catalog-<account-id>-dev/catalog/seed/`
- [ ] Bedrock model selection confirmed (Phase 1 accuracy benchmark: >= 90% on sample content)
- [ ] API schemas for `POST /classify` and `GET /recommend` agreed with ANP technical contact
- [ ] Discovery Summary Report delivered to Lilly Goyah for sign-off (3-business-day review window)

### Success Criteria

- Dev AWS environment accessible to nClouds team via named IAM accounts with MFA
- All IAM execution roles exist with correct least-privilege policies (validated via IAM Policy Simulator)
- S3 bucket versioning enabled and Firebase catalog export accessible at the `catalog/` prefix
- Bedrock accuracy benchmark >= 90% on 50-100 labeled faith-based content samples
- API schemas documented and accepted by ANP technical contact

## Phase 2: Build and Integrate (Weeks 3-4)

### Objectives

- Implement the `POST /classify` Classifier Lambda with Bedrock integration
- Implement the `GET /recommend` Recommender Lambda with DynamoDB integration
- Implement the Auto-Tagging batch Lambda triggered on S3 catalog uploads
- Configure API Gateway routes, request validation, throttling, and API key/JWT authorization
- Configure CloudWatch dashboards, Lambda error alarms, and API Gateway latency alerts
- Finalize CloudFormation/CDK IaC templates for both Dev and Production environments

### Activities

The following table lists all Phase 2 activities with owner, duration, and dependencies:

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Bedrock prompt engineering and prototype for mood classification | ML/AI Engineer | 3 days | Phase 1 complete |
| Classifier Lambda implementation (`POST /classify`) | ML/AI Engineer | 4 days | Bedrock prototype |
| Recommender Lambda implementation (`GET /recommend`) | ML/AI Engineer | 4 days | DynamoDB tables created |
| Auto-Tagger Lambda implementation (S3 trigger + Bedrock + DynamoDB) | ML/AI Engineer | 3 days | Classifier Lambda |
| API Gateway configuration (routes, auth, throttling, usage plan) | Solutions Engineer | 3 days | Lambda functions deployed |
| DynamoDB schema provisioning and seed data load from Firebase export | Solutions Engineer | 2 days | S3 catalog export available |
| CloudWatch dashboards and alerting setup | Cloud Engineer | 2 days | API Gateway active |
| IaC finalization for Dev and Production stacks | Cloud Engineer | 2 days | All components deployed to Dev |

### Detailed Procedures

#### 2.1 DynamoDB Table Provisioning and Seed Data Load

Before Lambda functions are deployed, provision the DynamoDB tables via the CDK data stack:

```bash
# Deploy DynamoDB tables for dev environment
cd infrastructure/stacks/data
cdk deploy ANPDataDevStack \
  --require-approval never \
  --tags Environment=dev \
  --tags Project=ANPStreamingAI \
  --tags ManagedBy=cdk

# Verify tables exist
aws dynamodb list-tables --query "TableNames[?starts_with(@, 'anp-')]"
# Expected: ["anp-catalog-moods-dev", "anp-user-history-dev"]

# Verify GSI on catalog moods table
aws dynamodb describe-table \
  --table-name anp-catalog-moods-dev \
  --query "Table.GlobalSecondaryIndexes[*].IndexName"
# Expected: ["mood_label-index"]
```

After the Auto-Tagger Lambda is deployed (see 2.3), trigger the initial catalog seed by uploading Firebase lyric/transcript files to S3:

```bash
# Bulk-seed catalog files from Firebase export directory
cd /path/to/firebase-export-processed
for f in *.txt; do
  CONTENT_ID="${f%.txt}"
  aws s3 cp "$f" "s3://${BUCKET_NAME}/catalog/${CONTENT_ID}.txt" --sse AES256
done

# Monitor DynamoDB item count during seeding
aws dynamodb scan --table-name anp-catalog-moods-dev --select COUNT --query 'Count'
```

#### 2.2 Classifier Lambda Deployment

The Classifier Lambda (`anp-classifier-dev`) invokes Amazon Bedrock with lyric or transcript text and returns a mood label and confidence score:

```bash
# Navigate to Lambda source and build deployment package
cd lambda/classifier
pip install -r requirements.txt -t ./package/
cp classifier.py ./package/
cd package && zip -r ../classifier-deployment.zip . && cd ..

# Deploy via CDK
cdk deploy ANPComputeDevStack \
  --require-approval never \
  --tags Environment=dev \
  --tags Project=ANPStreamingAI \
  --tags ManagedBy=cdk

# Verify Lambda exists and has correct configuration
aws lambda get-function-configuration \
  --function-name anp-classifier-dev \
  --query '{Memory: MemorySize, Timeout: Timeout, Runtime: Runtime}'
# Expected: Memory=1024, Timeout=30, Runtime=python3.12
```

Validate the Classifier Lambda end-to-end with a test invocation using a sample lyric:

```bash
# Create test payload and invoke Lambda directly
cat > /tmp/classifier-test.json << 'PAYLOAD'
{"body": "{\"text\": \"Amazing grace how sweet the sound that saved a wretch like me\", \"content_type\": \"song\"}"}
PAYLOAD

aws lambda invoke \
  --function-name anp-classifier-dev \
  --payload file:///tmp/classifier-test.json \
  --cli-binary-format raw-in-base64-out \
  /tmp/classifier-response.json

cat /tmp/classifier-response.json
# Expected: {"statusCode": 200, "body": "{\"mood_label\": \"Hopeful\", \"confidence_score\": 0.92}"}
```

#### 2.3 Auto-Tagger Lambda Deployment

The Auto-Tagger Lambda (`anp-autotagger-dev`) is triggered by S3 `ObjectCreated` events on the `catalog/` prefix:

```bash
# Verify S3 event notification is configured correctly
aws s3api get-bucket-notification-configuration \
  --bucket $BUCKET_NAME \
  --query "LambdaFunctionConfigurations[*].{Events: Events, Prefix: Filter.Key.FilterRules}"

# Test Auto-Tagger by uploading a single catalog file
aws s3 cp test-lyric.txt s3://${BUCKET_NAME}/catalog/test-content-001.txt --sse AES256

# Wait 30 seconds and check DynamoDB for the tagged item
sleep 30
aws dynamodb get-item \
  --table-name anp-catalog-moods-dev \
  --key '{"content_id": {"S": "test-content-001"}}' \
  --query 'Item.{mood_label: mood_label.S, confidence: mood_confidence.N}'
# Expected: {"mood_label": "Peaceful", "confidence": "0.88"}
```

#### 2.4 Recommender Lambda and API Gateway Deployment

The Recommender Lambda (`anp-recommender-dev`) queries DynamoDB for user history and mood-matched catalog items:

```bash
# Verify Recommender Lambda configuration
aws lambda get-function-configuration \
  --function-name anp-recommender-dev \
  --query '{Memory: MemorySize, Timeout: Timeout, Runtime: Runtime}'
# Expected: Memory=512, Timeout=15, Runtime=python3.12

# Deploy API Gateway stack (routes, auth, throttling, usage plan)
cdk deploy ANPApiDevStack \
  --require-approval never \
  --tags Environment=dev \
  --tags Project=ANPStreamingAI \
  --tags ManagedBy=cdk

# Retrieve API Gateway base URL
API_URL=$(aws cloudformation describe-stacks \
  --stack-name ANPApiDevStack \
  --query "Stacks[0].Outputs[?OutputKey=='ApiBaseUrl'].OutputValue" \
  --output text)

echo "API Gateway Dev URL: $API_URL"
```

### Deliverables

- [ ] Both API endpoints (`POST /classify` and `GET /recommend`) operational in Dev environment
- [ ] Auto-Tagging pipeline running on test S3 uploads (DynamoDB updated within 60 seconds)
- [ ] CloudWatch monitoring active (dashboards `ANP-Operations` and `ANP-Cost-Tracking`)
- [ ] IaC templates deploy cleanly in a Production dry-run
- [ ] DynamoDB `anp-catalog-moods-dev` table seeded with catalog mood tags from Firebase export

### Success Criteria

- Both endpoints return HTTP 200 with correct schema for valid inputs
- Auto-Tagger writes mood tags to DynamoDB within 60 seconds of S3 upload
- CloudWatch alarms are in `OK` state in the Dev environment
- Production dry-run (`cdk synth`) completes without errors

## Phase 3: Validate and Hand Off (Weeks 5-6)

### Objectives

- Execute functional, integration, performance, and security testing against both Dev endpoints
- Validate Bedrock classification accuracy >= 90% against labeled faith-based content
- Deploy final Lambda functions, API Gateway, and DynamoDB to Production via IaC
- Produce API reference documentation and operational runbook
- Conduct live knowledge transfer session with ANP technical contact
- Commence 2-week post-go-live hypercare support

### Activities

The following table lists all Phase 3 activities with owner, duration, and dependencies:

| Activity | Owner | Duration | Dependencies |
|----------|-------|----------|--------------|
| Test plan execution — functional and integration testing | QA Engineer | 3 days | Phase 2 complete |
| Lambda Power Tuning and Artillery performance testing | ML/AI Engineer | 2 days | Dev endpoints stable |
| Security testing (IAM, API key, JWT, HTTPS) | Security Engineer | 2 days | Dev endpoints stable |
| Model accuracy validation (>= 90% on labeled sample) | ML/AI Engineer | 2 days | Classifier endpoint stable |
| Defect resolution for Phase 3 test findings | Solutions Engineer | 2 days | Testing complete |
| Production deployment via IaC | Solutions Engineer | 1 day | All tests passed |
| API reference documentation | Solution Architect | 2 days | Production endpoints confirmed |
| Operational runbook | Solutions Engineer | 2 days | CloudWatch monitoring validated |
| Knowledge transfer session with ANP technical contact | Solution Architect | 1 day | Runbook + API docs complete |
| Hypercare support period commencement | Support Engineer | 2 weeks | Production go-live |

### Deliverables

- [ ] Test Results Report delivered to Lilly Goyah
- [ ] Production deployment complete and live
- [ ] API documentation (SOW Deliverable #17) delivered and accepted
- [ ] Operational Runbook (SOW Deliverable #18) delivered and accepted
- [ ] Knowledge Transfer Session conducted and recording delivered
- [ ] Project Closeout Report delivered to Lilly Goyah
- [ ] 2-week hypercare period commenced

### Success Criteria

- >= 95% functional test cases pass
- p95 API latency <= 2 seconds at 50 concurrent users (both endpoints)
- 100% security test cases pass
- Bedrock accuracy >= 90% on labeled sample of 50+ faith-based catalog items
- Production API callable from FlutterFlow (confirmed via CloudWatch access logs)
- All handover artifacts accepted by ANP technical contact within 3-business-day review window

---

# Infrastructure Deployment

This section defines the complete infrastructure deployment procedures for the ANP Streaming AI Mood & Recommendation API. All infrastructure is provisioned via AWS CDK (TypeScript) — no manual console-based resource creation is permitted. The four subsections below cover the four infrastructure domains in the order they must be deployed: Networking, Security, Compute, and Monitoring.

## Networking

The ANP Streaming AI API uses AWS-managed networking exclusively. No customer-managed VPC, subnets, security groups, or NACLs are required because all solution components (Lambda, API Gateway, Bedrock, DynamoDB, S3, Cognito, Secrets Manager) are fully managed AWS services communicating over the AWS private backbone.

### Components

The table below lists all networking-related infrastructure components deployed for this solution:

| Component | Service | Environment | Purpose |
|-----------|---------|-------------|---------|
| API Gateway Regional Endpoint | Amazon API Gateway REST API | Dev + Prod | Public HTTPS entry point for FlutterFlow app; regional endpoint type in us-east-1 |
| API Gateway Stage `v1` | Amazon API Gateway Stage | Dev + Prod | Versioned stage for all endpoint routes; access logging enabled |
| API Gateway Usage Plan | Amazon API Gateway Usage Plan | Dev + Prod | Rate limit: 100 rps; Burst: 200; API key association |
| API Gateway API Key | Amazon API Gateway API Key | Dev + Prod | `POST /classify` authentication; stored in Secrets Manager |
| Lambda Managed VPC | AWS Lambda Service VPC (managed) | Dev + Prod | Lambda functions run in AWS-managed service VPC; no customer configuration required |
| AWS Shield Standard | AWS Shield Standard | Dev + Prod | Baseline DDoS protection included with all AWS accounts at no additional cost |

### Script Location

Infrastructure as Code for networking components is organized in the following repository structure:

```text
infrastructure/
  stacks/
    ANPApiStack.ts          # API Gateway REST API, stages, usage plans, API keys
    ANPComputeStack.ts      # Lambda function configuration (managed VPC, no customer config)
  config/
    networking.config.ts    # Rate limits, stage names, endpoint configuration
```

### Deployment Steps

The following commands deploy all networking infrastructure. Always deploy the Security stack first to ensure IAM roles are available for API Gateway Lambda integrations:

```bash
# Step 1: Set environment variables
export AWS_PROFILE=anp-prod   # or anp-dev for dev deployment
export ENVIRONMENT=prod        # or dev

# Step 2: Navigate to IaC root and install CDK dependencies
cd infrastructure
npm install

# Step 3: Synthesize CloudFormation templates (dry-run verification)
cdk synth ANPApi${ENVIRONMENT^}Stack

# Step 4: Deploy API Gateway stack
cdk deploy ANPApi${ENVIRONMENT^}Stack \
  --require-approval never \
  --outputs-file ./outputs/api-${ENVIRONMENT}-outputs.json \
  --tags Environment=${ENVIRONMENT} \
  --tags Project=ANPStreamingAI \
  --tags Owner=nclouds \
  --tags CostCenter=OPP-2025-001 \
  --tags ManagedBy=cdk

# Step 5: Retrieve API Gateway base URL from stack outputs
API_BASE_URL=$(aws cloudformation describe-stacks \
  --stack-name ANPApi${ENVIRONMENT^}Stack \
  --query "Stacks[0].Outputs[?OutputKey=='ApiBaseUrl'].OutputValue" \
  --output text)
echo "API Base URL: $API_BASE_URL"
```

### Validation

After deployment, validate the API Gateway networking configuration with the following checks:

```bash
# Verify API Gateway REST API exists
aws apigateway get-rest-apis \
  --query "items[?name=='anp-api-${ENVIRONMENT}'].{Id: id, Name: name}"

# Verify usage plan has correct throttle settings
aws apigateway get-usage-plans \
  --query "items[?name=='anp-usage-plan-${ENVIRONMENT}'].{Name: name, Rate: throttle.rateLimit, Burst: throttle.burstLimit}"
# Expected: Rate=100, Burst=200

# Verify HTTPS enforcement — HTTP requests must return 403
curl -s -o /dev/null -w "%{http_code}" \
  http://$(echo $API_BASE_URL | sed 's|https://||')/v1/classify
# Expected: 403

# Verify HTTPS endpoint is live (403 confirms it is reachable and auth is enforced)
curl -s -o /dev/null -w "%{http_code}" \
  -X POST "${API_BASE_URL}/v1/classify" \
  -H "Content-Type: application/json" \
  -d '{"text": "test"}'
# Expected: 403 (API key required)
```

### Success Criteria

- API Gateway REST API `anp-api-${ENVIRONMENT}` deployed and stage `v1` active
- Usage plan rate limit: 100 rps; burst limit: 200
- HTTPS endpoint returns HTTP 403 for unauthenticated requests — endpoint is live
- HTTP (non-HTTPS) requests return HTTP 403 — TLS enforcement confirmed
- API Gateway access logging enabled and writing to CloudWatch log group `/aws/apigateway/anp-api-access-logs`

### Rollback

To roll back the API Gateway networking configuration to the previous stack state, use the following procedure:

```bash
# Option 1: CloudFormation automatic rollback on failed stack update
# CloudFormation automatically reverts to previous state on failure — no action required

# Option 2: Manual rollback to a previous committed stack version
git checkout <previous-commit-sha> -- infrastructure/stacks/ANPApiStack.ts
cdk deploy ANPApi${ENVIRONMENT^}Stack --require-approval never

# Verify rollback complete
aws cloudformation describe-stacks \
  --stack-name ANPApi${ENVIRONMENT^}Stack \
  --query "Stacks[0].{Status: StackStatus, LastUpdated: LastUpdatedTime}"
# Expected: StackStatus contains "COMPLETE"
```

## Security

The security infrastructure implements defense-in-depth controls across IAM, secrets management, API authentication, encryption, and audit logging. All security resources are provisioned via the `ANPSecurityStack` CDK stack and must be deployed before any compute or application stacks.

### Components

The following security infrastructure components are deployed for this solution:

| Component | Service | Environment | Purpose |
|-----------|---------|-------------|---------|
| `anp-classifier-lambda-role` | AWS IAM Role | Dev + Prod | Least-privilege execution role: Bedrock InvokeModel, CloudWatch Logs, Secrets Manager only |
| `anp-recommender-lambda-role` | AWS IAM Role | Dev + Prod | Least-privilege execution role: DynamoDB read/write and CloudWatch Logs only |
| `anp-autotagger-lambda-role` | AWS IAM Role | Dev + Prod | Least-privilege execution role: S3 GetObject, Bedrock, DynamoDB write, CloudWatch Logs |
| `anp/dev/firebase-service-account` | AWS Secrets Manager Secret | Dev + Prod | Firebase service account JSON key; quarterly manual rotation |
| `anp/dev/api-key` | AWS Secrets Manager Secret | Dev + Prod | API Gateway API key for `POST /classify`; quarterly rotation |
| ANP Audit Trail | AWS CloudTrail Multi-Region Trail | Dev + Prod | Account-level API activity audit logging; 90-day S3 retention |
| `anp-users-prod` | Amazon Cognito User Pool | Dev + Prod | JWT issuance and validation for `GET /recommend` |
| API Gateway Request Validator | API Gateway Request Model | Dev + Prod | Input validation: rejects malformed requests before Lambda invocation |

### Script Location

Security infrastructure code is organized as follows:

```text
infrastructure/
  stacks/
    ANPSecurityStack.ts      # IAM roles, Secrets Manager secrets, CloudTrail, Cognito User Pool
    ANPApiStack.ts           # API Gateway API key, Cognito JWT authorizer (references Security stack)
  policies/
    classifier-policy.json   # IAM policy document for anp-classifier-lambda-role
    recommender-policy.json  # IAM policy document for anp-recommender-lambda-role
    autotagger-policy.json   # IAM policy document for anp-autotagger-lambda-role
```

### Deployment Steps

The Security stack must be deployed first in every environment before any other stack:

```bash
# Step 1: Deploy the security baseline stack
cdk deploy ANPSecurity${ENVIRONMENT^}Stack \
  --require-approval never \
  --outputs-file ./outputs/security-${ENVIRONMENT}-outputs.json \
  --tags Environment=${ENVIRONMENT} \
  --tags Project=ANPStreamingAI \
  --tags Owner=nclouds \
  --tags CostCenter=OPP-2025-001 \
  --tags ManagedBy=cdk

# Step 2a: Update Firebase service account key with real credential
aws secretsmanager put-secret-value \
  --secret-id "anp/${ENVIRONMENT}/firebase-service-account" \
  --secret-string file://firebase-service-account.json

# Step 2b: Generate and store a production API key
API_KEY=$(openssl rand -hex 32)
aws secretsmanager put-secret-value \
  --secret-id "anp/${ENVIRONMENT}/api-key" \
  --secret-string "{\"api_key\": \"${API_KEY}\"}"

echo "API key stored: anp/${ENVIRONMENT}/api-key"

# Step 3: Enable CloudTrail if not already active at account level
aws cloudtrail create-trail \
  --name "anp-audit-trail" \
  --s3-bucket-name "anp-cloudtrail-$(aws sts get-caller-identity --query Account --output text)" \
  --is-multi-region-trail \
  --include-global-service-events \
  --enable-log-file-validation

aws cloudtrail start-logging --name "anp-audit-trail"
```

The IAM policy for the Classifier Lambda role restricts access to Bedrock, CloudWatch Logs, and Secrets Manager only. The following JSON is for reference and validation — deployment is via CDK:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["bedrock:InvokeModel"],
      "Resource": "arn:aws:bedrock:us-east-1::foundation-model/*"
    },
    {
      "Effect": "Allow",
      "Action": ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
      "Resource": "arn:aws:logs:us-east-1:*:log-group:/aws/lambda/anp-classifier:*"
    },
    {
      "Effect": "Allow",
      "Action": ["secretsmanager:GetSecretValue"],
      "Resource": "arn:aws:secretsmanager:us-east-1:*:secret:anp/*/firebase-service-account*"
    }
  ]
}
```

### Validation

After security stack deployment, validate each control with the following checks:

```bash
# Verify all three IAM roles exist
for role in anp-classifier-lambda-role anp-recommender-lambda-role anp-autotagger-lambda-role; do
  aws iam get-role --role-name $role --query "Role.RoleName" --output text
  echo "  -> Role verified: $role"
done

# Validate Classifier role does NOT have DynamoDB or S3 permissions (least-privilege check)
aws iam simulate-principal-policy \
  --policy-source-arn $(aws iam get-role --role-name anp-classifier-lambda-role \
    --query "Role.Arn" --output text) \
  --action-names "dynamodb:GetItem" "s3:PutObject" \
  --query "EvaluationResults[*].{Action: EvalActionName, Decision: EvalDecision}"
# Expected: both actions return "implicitDeny"

# Verify CloudTrail is actively logging
aws cloudtrail get-trail-status \
  --name "anp-audit-trail" \
  --query "{IsLogging: IsLogging, LatestDelivery: LatestDeliveryTime}"
# Expected: IsLogging=true

# Verify Cognito User Pool exists
aws cognito-idp list-user-pools \
  --max-results 10 \
  --query "UserPools[?Name=='anp-users-${ENVIRONMENT}'].{Id: Id, Name: Name}"
```

### Success Criteria

- All three Lambda execution IAM roles deployed with least-privilege policies (no wildcard resource permissions)
- IAM Policy Simulator confirms Classifier Lambda cannot access DynamoDB or S3
- Firebase service account and API key secrets populated in Secrets Manager (real credentials, not placeholders)
- CloudTrail logging active (`IsLogging: true`) with 90-day S3 retention
- Cognito User Pool `anp-users-${ENVIRONMENT}` created and associated with API Gateway JWT authorizer
- API Gateway request model validation rejects requests with missing `text` field on `POST /classify`
- HTTPS-only enforcement confirmed: HTTP requests return HTTP 403

### Rollback

To roll back security infrastructure, use the following procedure:

```bash
# Roll back security stack to previous committed version
git checkout <previous-commit-sha> -- infrastructure/stacks/ANPSecurityStack.ts
cdk deploy ANPSecurity${ENVIRONMENT^}Stack --require-approval never

# IMPORTANT: Do NOT delete Secrets Manager secrets during rollback
# Secrets are preserved independently of CDK stacks to prevent accidental credential loss
# To restore a secret value after rollback: use aws secretsmanager put-secret-value

# Verify IAM roles are in expected state post-rollback
aws iam list-roles \
  --query "Roles[?starts_with(RoleName, 'anp-')].[RoleName]" \
  --output table
```

## Compute

The compute layer consists of three AWS Lambda functions (Classifier, Recommender, Auto-Tagger) deployed in Python 3.12 with `boto3`. Lambda provides serverless, pay-per-invocation compute with no server provisioning or capacity planning. All Lambda functions emit structured JSON logs to CloudWatch and are deployed with versioned aliases for zero-downtime rollback.

### Components

The following compute resources are deployed for this solution:

| Component | Service | Memory | Timeout | Environment | Purpose |
|-----------|---------|--------|---------|-------------|---------|
| `anp-classifier-prod` | AWS Lambda Python 3.12 | 1024 MB | 30s | Dev + Prod | `POST /classify` — Bedrock mood inference from lyric/transcript text |
| `anp-recommender-prod` | AWS Lambda Python 3.12 | 512 MB | 15s | Dev + Prod | `GET /recommend` — DynamoDB-based personalized playlist |
| `anp-autotagger-prod` | AWS Lambda Python 3.12 | 512 MB | 60s | Dev + Prod | S3-triggered batch mood tagging for new catalog uploads |
| `LIVE` Lambda Alias | Lambda Alias | — | — | Dev + Prod | Points to active published version; enables rapid rollback via alias update |
| `anp-autotagger-dlq-prod` | Amazon SQS Standard Queue | — | — | Dev + Prod | Dead-letter queue for failed Auto-Tagger S3 event processing (3 retry attempts) |

### Script Location

Lambda source code and compute IaC are organized in the following repository structure:

```text
lambda/
  classifier/
    classifier.py          # POST /classify handler: Bedrock InvokeModel + response parsing
    requirements.txt       # boto3>=1.34, aws-lambda-powertools
  recommender/
    recommender.py         # GET /recommend handler: DynamoDB Query + playlist ranking
    requirements.txt       # boto3>=1.34, aws-lambda-powertools
  autotagger/
    autotagger.py          # S3 event handler: S3 GetObject + Bedrock + DynamoDB PutItem
    requirements.txt       # boto3>=1.34, aws-lambda-powertools

infrastructure/
  stacks/
    ANPComputeStack.ts     # Lambda functions, aliases, S3 event notification, SQS DLQ
  config/
    compute.config.ts      # Memory, timeout, runtime, provisioned concurrency settings
```

### Deployment Steps

Deploy the compute stack after Security and Data stacks are confirmed operational:

```bash
# Step 1: Build Lambda deployment packages
cd lambda/classifier
pip install -r requirements.txt -t ./dist/ && cp classifier.py ./dist/
cd dist && zip -r ../../classifier-1.0.0.zip . && cd ../..

cd ../recommender
pip install -r requirements.txt -t ./dist/ && cp recommender.py ./dist/
cd dist && zip -r ../../recommender-1.0.0.zip . && cd ../..

cd ../autotagger
pip install -r requirements.txt -t ./dist/ && cp autotagger.py ./dist/
cd dist && zip -r ../../autotagger-1.0.0.zip . && cd ../..

# Step 2: Deploy compute stack via CDK
cd ../../infrastructure
cdk deploy ANPCompute${ENVIRONMENT^}Stack \
  --require-approval never \
  --outputs-file ./outputs/compute-${ENVIRONMENT}-outputs.json \
  --tags Environment=${ENVIRONMENT} \
  --tags Project=ANPStreamingAI \
  --tags Owner=nclouds \
  --tags CostCenter=OPP-2025-001 \
  --tags ManagedBy=cdk

# Step 3: Publish Lambda versions and update LIVE alias
for fn in anp-classifier-${ENVIRONMENT} anp-recommender-${ENVIRONMENT} anp-autotagger-${ENVIRONMENT}; do
  VER=$(aws lambda publish-version \
    --function-name $fn \
    --description "Release 1.0.0 - $(date +%Y-%m-%d)" \
    --query Version --output text)
  aws lambda update-alias --function-name $fn --name LIVE --function-version $VER
  echo "$fn: LIVE alias set to version $VER"
done
```

A complete Lambda function configuration example shows all required environment variables for the Classifier Lambda:

```yaml
# CDK stack snippet: Classifier Lambda configuration (rendered as CloudFormation properties)
FunctionName: anp-classifier-prod
Runtime: python3.12
MemorySize: 1024
Timeout: 30
Handler: classifier.handler
Environment:
  Variables:
    ENVIRONMENT: prod
    LOG_LEVEL: info
    MOOD_LABELS: "Joyful,Reflective,Peaceful,Uplifting,Worshipful,Hopeful"
    BEDROCK_MAX_TOKENS: "512"
    CATALOG_TABLE_NAME: anp-catalog-moods-prod
    HISTORY_TABLE_NAME: anp-user-history-prod
    MIN_CONFIDENCE_THRESHOLD: "0.5"
    FIREBASE_SECRET_ARN: arn:aws:secretsmanager:us-east-1:123456789012:secret:anp/prod/firebase-service-account
    POWERTOOLS_SERVICE_NAME: anp-classifier
    POWERTOOLS_LOG_LEVEL: INFO
```

### Validation

After compute stack deployment, validate each Lambda function end-to-end:

```bash
# Verify all Lambda functions exist and are in Active state
for fn in anp-classifier-${ENVIRONMENT} anp-recommender-${ENVIRONMENT} anp-autotagger-${ENVIRONMENT}; do
  STATE=$(aws lambda get-function --function-name $fn \
    --query "Configuration.State" --output text)
  echo "$fn: $STATE"
  # Expected: Active
done

# Validate Classifier Lambda invocation
aws lambda invoke \
  --function-name "anp-classifier-${ENVIRONMENT}:LIVE" \
  --payload '{"body": "{\"text\": \"Your grace is enough\", \"content_type\": \"song\"}"}' \
  --cli-binary-format raw-in-base64-out \
  /tmp/classify-response.json
cat /tmp/classify-response.json
# Expected: {"statusCode": 200, "body": "{\"mood_label\": \"Worshipful\", \"confidence_score\": 0.89}"}

# Verify LIVE alias points to a published version number (not $LATEST)
for fn in anp-classifier-${ENVIRONMENT} anp-recommender-${ENVIRONMENT} anp-autotagger-${ENVIRONMENT}; do
  ALIAS=$(aws lambda get-alias --function-name $fn --name LIVE \
    --query "FunctionVersion" --output text)
  echo "$fn LIVE alias -> version $ALIAS"
  # Expected: numeric version such as "1", not "$LATEST"
done

# Verify SQS DLQ exists for Auto-Tagger
aws sqs get-queue-url \
  --queue-name "anp-autotagger-dlq-${ENVIRONMENT}" \
  --query "QueueUrl"
```

### Success Criteria

- All three Lambda functions in `Active` state with correct memory, timeout, and runtime configuration
- Classifier Lambda returns valid `mood_label` and `confidence_score` for a test invocation
- Recommender Lambda returns a valid `playlist` array for a test user
- `LIVE` alias on all functions points to a published version number (not `$LATEST`)
- SQS DLQ `anp-autotagger-dlq-${ENVIRONMENT}` exists and is associated with the Auto-Tagger event source mapping
- No Lambda function has wildcard resource permissions in its execution role

### Rollback

To roll back a Lambda function to the previous stable version, use the following procedure:

```bash
# Identify the previous published version for Classifier Lambda
PREV_VERSION=$(aws lambda list-versions-by-function \
  --function-name anp-classifier-${ENVIRONMENT} \
  --query "sort_by(Versions, &LastModified)[-2].Version" \
  --output text)

echo "Rolling back anp-classifier-${ENVIRONMENT} to version $PREV_VERSION"

# Update LIVE alias to previous version (completes in under 2 minutes)
aws lambda update-alias \
  --function-name anp-classifier-${ENVIRONMENT} \
  --name LIVE \
  --function-version $PREV_VERSION

# Verify rollback successful
aws lambda get-alias \
  --function-name anp-classifier-${ENVIRONMENT} \
  --name LIVE \
  --query "FunctionVersion"
# Expected: $PREV_VERSION

# Repeat for Recommender and Auto-Tagger if those functions are also impacted
# Notify Jonas Bull to inform Lilly Goyah of rollback event immediately
```

## Monitoring

The monitoring infrastructure provides comprehensive observability across all layers of the solution through Amazon CloudWatch Logs, Metrics, Alarms, Dashboards, and AWS X-Ray distributed tracing. Monitoring is provisioned as code via the `ANPMonitoringStack` CDK stack and must be deployed after compute and API Gateway stacks are operational.

### Components

The following monitoring components are deployed for this solution:

| Component | Service | Environment | Purpose |
|-----------|---------|-------------|---------|
| `/aws/lambda/anp-classifier` | CloudWatch Log Group | Dev + Prod | Structured JSON logs from Classifier Lambda; 90-day retention prod, 30-day dev |
| `/aws/lambda/anp-recommender` | CloudWatch Log Group | Dev + Prod | Structured JSON logs from Recommender Lambda |
| `/aws/lambda/anp-autotagger` | CloudWatch Log Group | Dev + Prod | Structured JSON logs from Auto-Tagger Lambda |
| `/aws/apigateway/anp-api-access-logs` | CloudWatch Log Group | Dev + Prod | API Gateway access logs: IP, method, path, status code, latency |
| `ANP-Operations` | CloudWatch Dashboard | Dev + Prod | Invocation counts, error rates, p95 latency, DLQ depth |
| `ANP-Cost-Tracking` | CloudWatch Dashboard | Dev + Prod | Bedrock token consumption, DynamoDB CU, API Gateway request volume |
| `anp-classifier-error-rate-1pct-${env}` | CloudWatch Alarm | Dev + Prod | Triggers when Classifier Lambda error rate > 1% in 5-minute window |
| `anp-recommender-error-rate-1pct-${env}` | CloudWatch Alarm | Dev + Prod | Triggers when Recommender Lambda error rate > 1% in 5-minute window |
| `anp-apigw-p95-latency-2000ms-${env}` | CloudWatch Alarm | Dev + Prod | Triggers when API Gateway p95 latency > 2000ms in 5-minute window |
| `anp-apigw-5xx-count-${env}` | CloudWatch Alarm | Dev + Prod | Triggers when API Gateway 5xx count > 5 in 5-minute window |
| `anp-autotagger-dlq-depth-${env}` | CloudWatch Alarm | Dev + Prod | Triggers when Auto-Tagger SQS DLQ visible message count > 0 |
| `anp-dynamodb-throttle-${env}` | CloudWatch Alarm | Dev + Prod | Triggers when DynamoDB ThrottledRequests > 0 in 5-minute window |
| `anp-ops-alerts-${env}` | Amazon SNS Topic | Dev + Prod | Alarm notification delivery to ANP technical contact email |
| AWS X-Ray Tracing | AWS X-Ray | Dev + Prod | End-to-end request tracing: API GW -> Lambda -> Bedrock/DynamoDB |

### Script Location

Monitoring infrastructure code is organized as follows:

```text
infrastructure/
  stacks/
    ANPMonitoringStack.ts        # CloudWatch log groups, dashboards, alarms, SNS topic, X-Ray
  dashboards/
    operations-dashboard.json    # ANP-Operations dashboard JSON definition
    cost-dashboard.json          # ANP-Cost-Tracking dashboard JSON definition
  alarms/
    alarm-definitions.ts         # All CloudWatch alarm thresholds and configurations
```

### Deployment Steps

Deploy the monitoring stack after compute and API Gateway stacks are confirmed operational:

```bash
# Step 1: Deploy monitoring stack
cdk deploy ANPMonitoring${ENVIRONMENT^}Stack \
  --require-approval never \
  --outputs-file ./outputs/monitoring-${ENVIRONMENT}-outputs.json \
  --tags Environment=${ENVIRONMENT} \
  --tags Project=ANPStreamingAI \
  --tags Owner=nclouds \
  --tags CostCenter=OPP-2025-001 \
  --tags ManagedBy=cdk

# Step 2: Subscribe ANP technical contact email to SNS ops topic
SNS_TOPIC_ARN=$(aws cloudformation describe-stacks \
  --stack-name ANPMonitoring${ENVIRONMENT^}Stack \
  --query "Stacks[0].Outputs[?OutputKey=='OpsTopicArn'].OutputValue" \
  --output text)

aws sns subscribe \
  --topic-arn $SNS_TOPIC_ARN \
  --protocol email \
  --notification-endpoint "ops@anpstreaming.com"

echo "SNS subscription created — ANP technical contact must confirm the email invitation."

# Step 3: Enable X-Ray tracing on Lambda functions
for fn in anp-classifier-${ENVIRONMENT} anp-recommender-${ENVIRONMENT} anp-autotagger-${ENVIRONMENT}; do
  aws lambda update-function-configuration \
    --function-name $fn \
    --tracing-config Mode=Active
  echo "X-Ray enabled on $fn"
done

# Step 4: Enable X-Ray tracing on API Gateway stage v1
REST_API_ID=$(aws apigateway get-rest-apis \
  --query "items[?name=='anp-api-${ENVIRONMENT}'].id" --output text)
aws apigateway update-stage \
  --rest-api-id $REST_API_ID \
  --stage-name v1 \
  --patch-operations op=replace,path=/tracingEnabled,value=true
```

A sample CloudWatch alarm definition is shown below for reference. All alarms are deployed via CDK — this JSON illustrates the configuration for the Classifier Lambda error rate alarm:

```json
{
  "AlarmName": "anp-classifier-error-rate-1pct-prod",
  "AlarmDescription": "Classifier Lambda error rate exceeded 1% over 5-minute window",
  "MetricName": "Errors",
  "Namespace": "AWS/Lambda",
  "Dimensions": [{"Name": "FunctionName", "Value": "anp-classifier-prod"}],
  "Statistic": "Sum",
  "Period": 300,
  "EvaluationPeriods": 1,
  "Threshold": 1,
  "ComparisonOperator": "GreaterThanThreshold",
  "TreatMissingData": "notBreaching",
  "AlarmActions": ["arn:aws:sns:us-east-1:123456789012:anp-ops-alerts-prod"]
}
```

### Validation

After monitoring stack deployment, validate all monitoring components are active and functional:

```bash
# Verify CloudWatch log groups exist with correct retention periods
for lg in /aws/lambda/anp-classifier /aws/lambda/anp-recommender /aws/lambda/anp-autotagger; do
  RETENTION=$(aws logs describe-log-groups \
    --log-group-name-prefix "$lg" \
    --query "logGroups[0].retentionInDays" --output text)
  echo "$lg: retention = $RETENTION days"
  # Expected: 90 (prod) or 30 (dev)
done

# Verify all CloudWatch alarms are in OK or INSUFFICIENT_DATA state
aws cloudwatch describe-alarms \
  --alarm-name-prefix "anp-" \
  --query "MetricAlarms[*].{Name: AlarmName, State: StateValue}" \
  --output table
# Expected: All states are "OK" or "INSUFFICIENT_DATA"

# Verify ANP-Operations dashboard exists
aws cloudwatch get-dashboard \
  --dashboard-name "ANP-Operations" \
  --query "DashboardName"
# Expected: "ANP-Operations"

# Test alarm notification by temporarily triggering the DLQ depth alarm
aws cloudwatch set-alarm-state \
  --alarm-name "anp-autotagger-dlq-depth-${ENVIRONMENT}" \
  --state-value ALARM \
  --state-reason "Manual test of alarm notification pipeline"

# Confirm SNS email received by ANP technical contact, then reset to OK
aws cloudwatch set-alarm-state \
  --alarm-name "anp-autotagger-dlq-depth-${ENVIRONMENT}" \
  --state-value OK \
  --state-reason "Alarm test complete"
```

### Success Criteria

- All four Lambda and API Gateway CloudWatch log groups created with correct retention periods
- All seven CloudWatch alarms deployed and in `OK` or `INSUFFICIENT_DATA` state at baseline
- `ANP-Operations` and `ANP-Cost-Tracking` dashboards visible in the CloudWatch console
- SNS topic `anp-ops-alerts-${ENVIRONMENT}` created and email subscription confirmed by ANP technical contact
- Test alarm notification delivered to ANP technical contact email
- X-Ray tracing enabled on all Lambda functions and the API Gateway `v1` stage
- CloudTrail logging to S3 with 90-day retention confirmed active

### Rollback

To roll back monitoring infrastructure to the previous configuration, use the following procedure:

```bash
# Roll back monitoring stack to previous committed version
git checkout <previous-commit-sha> -- infrastructure/stacks/ANPMonitoringStack.ts
cdk deploy ANPMonitoring${ENVIRONMENT^}Stack --require-approval never

# SNS email subscriptions are preserved outside CDK to prevent resubscription disruption
# If SNS topic ARN changes after rollback, manually re-subscribe the ANP operations email:
aws sns subscribe \
  --topic-arn <new-sns-topic-arn> \
  --protocol email \
  --notification-endpoint "ops@anpstreaming.com"

# Verify no alarms are stuck in ALARM state after rollback
aws cloudwatch describe-alarms \
  --alarm-name-prefix "anp-" \
  --query "MetricAlarms[?StateValue=='ALARM'].AlarmName"
# Expected: empty array — no alarms in ALARM state
```

---

# Application Configuration

This section covers the application-layer configuration, service settings, and connection wiring that must be completed after infrastructure deployment. Configuration values derive from the `configuration.csv` parameter reference and must be applied consistently across Dev and Production environments.

## API Configuration

All API configuration is managed via AWS CDK environment variables injected into Lambda functions at deployment time. Sensitive values are retrieved from Secrets Manager at Lambda cold start — never stored in plaintext Lambda environment variables.

The following table documents all application configuration parameters and their values across environments:

| Parameter | Dev Value | Prod Value | Source |
|-----------|-----------|------------|--------|
| `ENVIRONMENT` | `dev` | `prod` | CDK deployment context |
| `LOG_LEVEL` | `debug` | `info` | CDK deployment context |
| `MOOD_LABELS` | `Joyful,Reflective,Peaceful,Uplifting,Worshipful,Hopeful` | Same | CDK env var |
| `BEDROCK_MAX_TOKENS` | `512` | `512` | CDK env var |
| `RECOMMEND_DEFAULT_LIMIT` | `10` | `10` | CDK env var |
| `RECOMMEND_MAX_LIMIT` | `50` | `50` | CDK env var |
| `API_TIMEOUT_SECONDS` | `30` | `30` | API GW integration timeout |
| `CATALOG_TABLE_NAME` | `anp-catalog-moods-dev` | `anp-catalog-moods-prod` | CDK env var |
| `HISTORY_TABLE_NAME` | `anp-user-history-dev` | `anp-user-history-prod` | CDK env var |
| `HISTORY_LOOKBACK` | `20` | `20` | CDK env var |
| `FIREBASE_SECRET_ARN` | `arn:aws:...:anp/dev/firebase-service-account` | `arn:aws:...:anp/prod/firebase-service-account` | CDK env var (ARN only) |
| `MIN_CONFIDENCE_THRESHOLD` | `0.5` | `0.5` | CDK env var |

## Bedrock Prompt Configuration

The Classifier Lambda uses a structured prompt template to invoke the Bedrock foundation model. The prompt instructs the model to return a JSON object with `mood_label` and `confidence_score`:

```python
# classifier.py — Bedrock prompt construction
PROMPT_TEMPLATE = """You are a mood classification assistant for a Christian music and podcast streaming service.
Analyze the following lyric or transcript text and classify it with one mood label from this exact list:
{mood_labels}

Text to classify:
<text>
{input_text}
</text>

Return ONLY a valid JSON object with no additional text:
{{"mood_label": "<one of the mood labels above>", "confidence_score": <float between 0.0 and 1.0>}}"""

def build_prompt(text: str, mood_labels: list) -> str:
    return PROMPT_TEMPLATE.format(
        mood_labels=", ".join(mood_labels),
        input_text=text[:4000]  # Truncate to stay within model context window
    )
```

## DynamoDB Connection Configuration

The DynamoDB connection is initialized once at Lambda cold start (module level) for connection reuse across warm invocations:

```python
# recommender.py — DynamoDB initialization and mood catalog query
import boto3
import os

# Initialize at module level for connection reuse across warm invocations
dynamodb = boto3.resource('dynamodb', region_name=os.environ.get('AWS_DEFAULT_REGION', 'us-east-1'))
catalog_table = dynamodb.Table(os.environ['CATALOG_TABLE_NAME'])
history_table = dynamodb.Table(os.environ['HISTORY_TABLE_NAME'])

def query_mood_catalog(mood_label: str, limit: int = 10) -> list:
    """Query catalog GSI for items matching the requested mood label."""
    response = catalog_table.query(
        IndexName='mood_label-index',
        KeyConditionExpression='mood_label = :ml',
        FilterExpression='mood_confidence >= :threshold',
        ExpressionAttributeValues={
            ':ml': mood_label,
            ':threshold': float(os.environ.get('MIN_CONFIDENCE_THRESHOLD', '0.5'))
        },
        ScanIndexForward=False,
        Limit=limit * 3
    )
    return response.get('Items', [])
```

## Environment Variable Verification

After each Lambda deployment, verify environment variables are correctly set:

```bash
# Verify Classifier Lambda environment configuration
aws lambda get-function-configuration \
  --function-name anp-classifier-${ENVIRONMENT} \
  --query "Environment.Variables" \
  --output table

# Confirm no raw API keys or Firebase credentials are present as plaintext env vars
aws lambda get-function-configuration \
  --function-name anp-classifier-${ENVIRONMENT} \
  --query "Environment.Variables.BEDROCK_MODEL_ID"
# Expected: null — BEDROCK_MODEL_ID must not appear as a plaintext environment variable
```

## Cognito JWT Configuration for FlutterFlow

The ANP FlutterFlow app must obtain a Cognito JWT to call the `GET /recommend` endpoint. Provide the following configuration values to the ANP FlutterFlow developer:

```yaml
# FlutterFlow API configuration — provide to ANP technical contact after Production deployment
cognito_config:
  user_pool_id: "<from CDK stack output: CognitoUserPoolId>"
  user_pool_client_id: "<from CDK stack output: CognitoAppClientId>"
  region: "us-east-1"
  jwt_header: "Authorization: Bearer <access_token>"
  token_expiry_seconds: 3600

api_config:
  base_url: "https://<api-id>.execute-api.us-east-1.amazonaws.com/v1"
  classify_endpoint: "POST /classify"
  recommend_endpoint: "GET /recommend"
  api_key_header: "x-api-key"
  content_type: "application/json"
```

---

# Integration Testing

This section covers end-to-end validation of all solution components, from FlutterFlow API calls through API Gateway to Lambda to DynamoDB and back. Integration testing is conducted in the Dev environment in Phase 3 (Week 5) before Production deployment is approved.

## Test Environment Setup

All integration testing is performed against the Dev environment using synthetic test users and a sample catalog of 50+ labeled faith-based items loaded during Phase 1 seeding:

```bash
# Verify test environment is ready before running integration tests
echo "=== Integration Test Environment Check ==="

API_URL=$(aws cloudformation describe-stacks \
  --stack-name ANPApiDevStack \
  --query "Stacks[0].Outputs[?OutputKey=='ApiBaseUrl'].OutputValue" \
  --output text)

# Check 1: API Gateway endpoint is reachable (403 confirms it is live)
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${API_URL}/v1/classify" \
  -H "x-api-key: invalid-key")
echo "API Gateway reachable: $STATUS (expected 403)"

# Check 2: DynamoDB has seed data
CATALOG_COUNT=$(aws dynamodb scan \
  --table-name anp-catalog-moods-dev --select COUNT --query Count)
echo "Catalog items seeded: $CATALOG_COUNT (expected >= 50)"

# Check 3: All Lambda functions in Active state
for fn in anp-classifier-dev anp-recommender-dev anp-autotagger-dev; do
  STATE=$(aws lambda get-function --function-name $fn \
    --query "Configuration.State" --output text)
  echo "$fn: $STATE"
done
```

## Functional Integration Tests

The following test cases validate each endpoint's end-to-end behavior through API Gateway. Execute using Postman/Newman:

```bash
# Run full functional test suite using Newman (Postman CLI)
newman run tests/anp-integration-tests.postman_collection.json \
  --environment tests/anp-dev.postman_environment.json \
  --reporters cli,json \
  --reporter-json-export /tmp/test-results.json
# Expected: POST /classify >= 95% pass; GET /recommend >= 95% pass; Auto-Tagger >= 95% pass
```

The following table defines the critical test cases covered by the test suite:

| Test ID | Endpoint | Input | Expected Result |
|---------|----------|-------|-----------------|
| TC-001 | POST /classify | Valid lyric text (song) | HTTP 200, mood_label in vocabulary, confidence 0-1 |
| TC-002 | POST /classify | Valid transcript text (podcast) | HTTP 200, confidence_score >= 0.5 |
| TC-003 | POST /classify | Empty text field | HTTP 400, error message |
| TC-004 | POST /classify | Missing x-api-key header | HTTP 403 |
| TC-005 | POST /classify | Invalid API key value | HTTP 403 |
| TC-006 | GET /recommend | Valid mood + Cognito JWT, user has history | HTTP 200, playlist array with >= 1 item |
| TC-007 | GET /recommend | Valid mood + Cognito JWT, new user (cold start) | HTTP 200, playlist array |
| TC-008 | GET /recommend | Missing Authorization header | HTTP 401 |
| TC-009 | GET /recommend | Expired Cognito JWT | HTTP 401 |
| TC-010 | GET /recommend | Unsupported mood label value | HTTP 400 |
| TC-011 | Auto-Tagger | Upload lyric file to S3 catalog prefix | DynamoDB item created within 60 seconds |
| TC-012 | POST /classify | HTTP (non-HTTPS) request | HTTP 403 |

## Performance Testing

Performance testing validates the p95 latency target of <= 2 seconds for both endpoints under 50 concurrent users. The following commands run the Artillery load test and check the result:

```bash
# Run Artillery load test against the Dev API
ANP_API_KEY="$(aws secretsmanager get-secret-value \
  --secret-id anp/dev/api-key --query SecretString --output text \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["api_key"])')" \
artillery run tests/performance-test.yml --output /tmp/perf-results.json

# Parse p95 result from Artillery JSON report
python3 -c "
import json
with open('/tmp/perf-results.json') as f:
    results = json.load(f)
p95 = results['aggregate']['latency']['p95']
status = 'PASS' if p95 <= 2000 else 'FAIL - exceeds 2000ms SLA'
print(f'p95 latency: {p95}ms -- {status}')
"
```

## Integration Test Acceptance Criteria

All of the following criteria must be met before Production deployment is approved:

- [ ] >= 95% of functional test cases pass (TC-001 through TC-012)
- [ ] p95 API latency <= 2,000ms at 50 concurrent users for both `/classify` and `/recommend`
- [ ] Auto-Tagger pipeline writes mood tags to DynamoDB within 60 seconds of S3 upload
- [ ] FlutterFlow integration confirmed: ANP technical contact makes successful API calls from a FlutterFlow test build
- [ ] Bedrock classification accuracy >= 90% validated on 50+ labeled faith-based content samples
- [ ] No data leakage: Classifier Lambda logs do not contain full lyric text in CloudWatch logs
- [ ] DLQ depth remains zero throughout load testing

---

# Security Validation

This section defines the security test cases and validation procedures that must all pass before Production deployment is approved. Security testing is conducted in the Dev environment in Phase 3 (Week 5) and is 100% pass-required — no partial acceptance.

## Security Test Cases

The following security test matrix covers all authentication, authorization, encryption, and IAM validation requirements from the SOW:

| Test ID | Category | Test Procedure | Pass Criteria |
|---------|----------|----------------|---------------|
| SEC-001 | API Key Auth | `POST /classify` without `x-api-key` header | HTTP 403, logged in API GW access logs |
| SEC-002 | API Key Auth | `POST /classify` with invalid API key | HTTP 403 |
| SEC-003 | JWT Auth | `GET /recommend` without Authorization header | HTTP 401 |
| SEC-004 | JWT Auth | `GET /recommend` with expired Cognito JWT | HTTP 401 |
| SEC-005 | JWT Auth | `GET /recommend` with JWT from wrong Cognito User Pool | HTTP 401 |
| SEC-006 | HTTPS Only | HTTP (non-TLS) request to API Gateway endpoint | HTTP 403 |
| SEC-007 | IAM Scope | Classifier Lambda role cannot invoke DynamoDB:GetItem | IAM Policy Simulator: `implicitDeny` |
| SEC-008 | IAM Scope | Recommender Lambda role cannot invoke Bedrock:InvokeModel | IAM Policy Simulator: `implicitDeny` |
| SEC-009 | IAM Scope | Auto-Tagger Lambda role cannot access non-catalog S3 prefix | `AccessDenied` on attempt |
| SEC-010 | Secrets | No secrets in Lambda env vars | `get-function-configuration` shows no plaintext secrets |
| SEC-011 | Secrets | Firebase service account key NOT present in CloudWatch logs | Log Insights query returns zero matches |
| SEC-012 | Encryption | S3 catalog bucket: all objects encrypted with SSE-S3 | `head-object` shows `ServerSideEncryption: AES256` |
| SEC-013 | Encryption | DynamoDB tables encrypted at rest | `DescribeTable` shows `SSEStatus: ENABLED` |
| SEC-014 | Audit | CloudTrail capturing Lambda invocations | CloudTrail event present for Lambda API calls |
| SEC-015 | Input Validation | `POST /classify` with malformed JSON body | HTTP 400 from API GW before Lambda invoked |

## IAM Scope Validation

Run the following IAM Policy Simulator commands to validate least-privilege enforcement:

```bash
# SEC-007: Verify Classifier Lambda CANNOT access DynamoDB
ACCT=$(aws sts get-caller-identity --query Account --output text)
aws iam simulate-principal-policy \
  --policy-source-arn "arn:aws:iam::${ACCT}:role/anp-classifier-lambda-role" \
  --action-names "dynamodb:GetItem" "dynamodb:PutItem" "s3:PutObject" \
  --query "EvaluationResults[*].{Action: EvalActionName, Decision: EvalDecision}"
# Expected: all decisions = "implicitDeny"

# SEC-008: Verify Recommender Lambda CANNOT invoke Bedrock
aws iam simulate-principal-policy \
  --policy-source-arn "arn:aws:iam::${ACCT}:role/anp-recommender-lambda-role" \
  --action-names "bedrock:InvokeModel" "s3:GetObject" \
  --query "EvaluationResults[*].{Action: EvalActionName, Decision: EvalDecision}"
# Expected: all decisions = "implicitDeny"
```

## Secrets Validation

The following commands verify that no credentials are exposed in Lambda environment variables or CloudWatch logs:

```bash
# SEC-010: Verify no plaintext secrets in Lambda environment variables
for fn in anp-classifier-dev anp-recommender-dev anp-autotagger-dev; do
  echo "=== $fn environment variables ==="
  aws lambda get-function-configuration \
    --function-name $fn \
    --query "Environment.Variables" \
    --output table
  # Confirm: no raw API keys, passwords, or Firebase credentials present
done

# SEC-011: Verify no credentials appear in CloudWatch logs via Log Insights
aws logs start-query \
  --log-group-name "/aws/lambda/anp-classifier" \
  --start-time $(date -d "-1 hour" +%s)000 \
  --end-time $(date +%s)000 \
  --query-string 'fields @message | filter @message like /(?i)(password|secret_key|client_secret)/'
# After query completes: expected zero log events matching the filter
```

## Encryption Validation

The following commands confirm all data at rest is encrypted as required by the SOW:

```bash
# SEC-012: Verify S3 bucket default encryption is AES256
BUCKET_NAME="anp-catalog-$(aws sts get-caller-identity --query Account --output text)-dev"
aws s3api get-bucket-encryption \
  --bucket $BUCKET_NAME \
  --query "ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm"
# Expected: "AES256"

# SEC-013: Verify DynamoDB table encryption at rest
aws dynamodb describe-table \
  --table-name anp-catalog-moods-dev \
  --query "Table.SSEDescription.Status"
# Expected: "ENABLED"
```

## Security Test Pass Gate

All 15 security test cases are required to pass (100%) before Production deployment proceeds. Document results in the Test Results Report (SOW Deliverable #15):

```bash
# Print security validation summary for inclusion in Test Results Report
echo "=== Security Validation Summary ==="
echo "Engagement: ANP Streaming AI Mood and Recommendation API"
echo "Environment: Dev"
echo "Total test cases: 15 | Required pass rate: 100%"
echo "Validator: nClouds Security Engineer"
echo "Results: record PASS or FAIL per SEC-001 through SEC-015"
echo "Sign-off required from Jonas Bull and ANP technical contact before Production deployment."
```

---

# Migration & Cutover

This section defines the data migration approach, Production cutover plan, go/no-go criteria, and rollback procedures. The cutover is designed for zero end-user downtime since the AWS API is a greenfield addition to ANP's backend — the FlutterFlow app continues to serve users from Firebase throughout the entire engagement.

## Migration Approach

The migration strategy is a **Greenfield Build** with a **One-Time Catalog Seed Migration**. No existing AWS infrastructure is being migrated. Firebase remains fully operational and unmodified throughout and after the engagement.

The catalog seed migration transfers lyric and transcript text from the Firebase catalog export to S3 and DynamoDB, enabling the Auto-Tagger pipeline to enrich the catalog with mood labels before Production go-live.

### Migration Timeline

The following table defines each migration phase, its data type, expected volume, duration, and validation approach:

| Phase | Data Type | Volume | Duration | Validation |
|-------|-----------|--------|----------|------------|
| Dev Seed (Week 2) | Firebase catalog lyric/transcript files | < 50 GB | 1-2 days | DynamoDB item count matches source; sample confidence >= 0.5 |
| Dev Mood Enrichment | Auto-Tagger batch processing all catalog uploads | All items | Parallel with Phase 2 | Spot-check 50 items in DynamoDB for valid mood labels |
| Production Seed (Week 5) | Same Firebase export reprocessed to Production tables | < 50 GB | 3-4 hours | Prod count matches dev count plus or minus 2%; accuracy >= 90% |

### Migration Procedures

The catalog seed migration runs in four steps: prepare the export files, upload to S3, monitor Auto-Tagger processing, then validate completion:

```bash
# Step 1: Parse Firebase CSV export and create individual text files per catalog item
python3 scripts/prepare-catalog-files.py \
  --input firebase-catalog-export.csv \
  --output-dir /tmp/catalog-files/ \
  --content-id-column content_id \
  --text-column lyric_text

# Step 2: Upload all catalog text files to S3 catalog prefix
aws s3 sync /tmp/catalog-files/ \
  s3://${BUCKET_NAME}/catalog/ \
  --sse AES256 --exclude "*.csv" --include "*.txt"

# Step 3: Monitor Auto-Tagger processing — DynamoDB item count should grow
watch -n 30 "aws dynamodb scan \
  --table-name anp-catalog-moods-${ENVIRONMENT} --select COUNT --query Count"

# Step 4: Validate migration completion
python3 scripts/validate-migration.py \
  --source-csv firebase-catalog-export.csv \
  --dynamodb-table anp-catalog-moods-${ENVIRONMENT} \
  --sample-size 20
# Expected: "Migration complete: X/Y items tagged; avg confidence: 0.87; PASS"
```

### Rollback Plan

**Rollback Triggers for Migration:**
- DynamoDB item count less than 90% of source export row count after 4 hours
- Average confidence score on 20-item sample below 0.5 (data quality failure)
- Auto-Tagger DLQ depth greater than 50 (systematic processing failure)

The following commands execute the migration rollback procedure:

```bash
# Pause Auto-Tagger by disabling S3 event notification temporarily
aws s3api put-bucket-notification-configuration \
  --bucket $BUCKET_NAME \
  --notification-configuration '{}'
echo "S3 event notification disabled — Auto-Tagger paused"

# Truncate Dev DynamoDB table for fresh retry (Dev environment only)
python3 scripts/truncate-dynamodb-table.py --table anp-catalog-moods-dev
echo "Dev catalog table truncated — ready for re-migration after root cause resolution"

# Investigate root cause in Auto-Tagger CloudWatch logs
aws logs filter-log-events \
  --log-group-name "/aws/lambda/anp-autotagger" \
  --filter-pattern "ERROR" \
  --start-time $(date -d "-4 hours" +%s)000

# Re-enable S3 event notification after root cause is resolved
cdk deploy ANPCompute${ENVIRONMENT^}Stack --require-approval never
echo "S3 event notification re-enabled — ready to retry migration"
```

## Production Cutover Plan

The Production cutover is a planned deployment window during ANP business hours in Week 5, after all Dev testing and validation is complete. The cutover achieves zero downtime for end users because the FlutterFlow app's Firebase backend remains fully operational until ANP explicitly updates the app configuration with the new AWS API endpoint details.

**Cutover Window:** End of Week 5, exact date/time agreed with ANP technical contact  
**Estimated Duration:** 2-3 hours  
**Team:** Jonas Bull (lead), Cloud/Solutions Engineer (deployment), ANP technical contact (smoke test confirmation)

### Pre-Cutover Checklist

All of the following items must be confirmed before initiating the Production deployment:

- [ ] All 15 security test cases passed (100% pass rate) in Dev environment
- [ ] >= 95% functional test cases pass in Dev environment
- [ ] p95 latency <= 2,000ms at 50 concurrent users confirmed in Dev performance test
- [ ] Bedrock accuracy >= 90% validated on labeled content sample
- [ ] Production IaC dry-run (`cdk synth`) completes without errors
- [ ] DynamoDB PITR enabled on both Dev tables
- [ ] CloudWatch alarms active and SNS email subscription confirmed in Dev
- [ ] API documentation reviewed and approved by ANP technical contact
- [ ] Operational runbook reviewed by Jonas Bull and ANP technical contact
- [ ] Production go-live approval received from Lilly Goyah (CEO)
- [ ] Firebase catalog export ready for Production seed
- [ ] ANP FlutterFlow developer standing by to update app configuration

### Cutover Execution Steps

The following script executes the Production cutover in sequence:

```bash
echo "[$(date)] Starting Production deployment — Operator: Jonas Bull"

# Step 1: Deploy all Production infrastructure stacks in dependency order
for STACK in ANPSecurityProdStack ANPDataProdStack ANPComputeProdStack ANPApiProdStack ANPMonitoringProdStack; do
  cdk deploy $STACK \
    --require-approval never \
    --tags Environment=prod \
    --tags Project=ANPStreamingAI \
    --tags Owner=anp-streaming \
    --tags CostCenter=OPP-2025-001 \
    --tags ManagedBy=cdk
  echo "[$(date)] $STACK deployed"
done

# Step 2: Seed Production DynamoDB with Firebase catalog
PROD_BUCKET="anp-catalog-$(aws sts get-caller-identity --query Account --output text)-prod"
aws s3 sync /tmp/catalog-files/ s3://${PROD_BUCKET}/catalog/ --sse AES256 --include "*.txt"
echo "[$(date)] Catalog seed upload complete"

# Step 3: Run Production smoke tests (5 representative API calls)
PROD_API_URL=$(aws cloudformation describe-stacks \
  --stack-name ANPApiProdStack \
  --query "Stacks[0].Outputs[?OutputKey=='ApiBaseUrl'].OutputValue" --output text)
PROD_API_KEY=$(aws secretsmanager get-secret-value \
  --secret-id anp/prod/api-key --query SecretString --output text \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['api_key'])")

for i in 1 2 3 4 5; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "${PROD_API_URL}/v1/classify" \
    -H "Content-Type: application/json" \
    -H "x-api-key: ${PROD_API_KEY}" \
    -d '{"text": "Amazing grace how sweet the sound", "content_type": "song"}')
  echo "Smoke test $i: HTTP $STATUS (expected 200)"
done

echo "[$(date)] Production go-live complete. Hypercare commences. Duration: 2 weeks."
```

## Go/No-Go Criteria

Production deployment proceeds only if ALL of the following conditions are met:

| Criterion | Required Value | Verification Method |
|-----------|---------------|---------------------|
| Functional test pass rate | >= 95% | Test Results Report |
| p95 API latency at 50 concurrent users | <= 2,000ms | Artillery load test output |
| Security test pass rate | 100% (15/15) | Security validation checklist |
| Bedrock accuracy on labeled sample | >= 90% | Accuracy validation report |
| CloudWatch alarms configured and SNS email confirmed | 100% | SNS subscription status |
| Production IaC dry-run (`cdk synth`) | No errors | CDK synth output |
| DynamoDB PITR enabled on both tables | True | DynamoDB console/API |
| Lilly Goyah executive go-live approval | Received | Email confirmation |

**Post-Go-Live Rollback Trigger:** If Lambda error rate exceeds 10% OR p95 latency exceeds 5,000ms sustained for 10 minutes in Production, initiate immediate rollback using the Lambda alias rollback procedure in the Compute subsection of Infrastructure Deployment. Jonas Bull notifies Lilly Goyah within 15 minutes of trigger. Root cause analysis delivered within 24 hours.

---

# Operational Handover

This section defines the documentation handover, support transition procedures, hypercare plan, and the checklist confirming ANP Streaming is ready for independent operation.

## Documentation Handover

All of the following artifacts are delivered to ANP Streaming's technical contact by the end of Week 6 (SOW Deliverables #17-#20):

- [ ] **Discovery Summary Report** (SOW Del. #4) — AWS architecture decision record, confirmed scope, risk register — delivered Week 2
- [ ] **AWS Architecture Design and Decision Record** (SOW Del. #3) — Detailed Design Document — delivered Week 3
- [ ] **Infrastructure as Code Codebase** (SOW Del. #13) — Full CDK/CloudFormation templates in GitHub repository with README
- [ ] **Lambda Source Code** (SOW Del. #8, #9, #10) — All three Lambda functions in GitHub with README
- [ ] **API Reference Documentation** (SOW Del. #17) — Developer-facing documentation: endpoint specs, auth, request/response schemas, error codes, FlutterFlow examples
- [ ] **Operational Runbook** (SOW Del. #18) — Step-by-step procedures for monitoring, alarm investigation, Lambda scaling, DynamoDB capacity adjustment, Secrets Manager rotation, and IaC re-deployment
- [ ] **Test Results Report** (SOW Del. #15) — Complete functional, integration, security, and UAT test execution results
- [ ] **Project Closeout Report** (SOW Del. #20) — Summary of delivered scope, deferred items, and recommended next steps

## Support Transition

### Support Model

The following support tier model applies from Production go-live through the 2-week hypercare period and defines the long-term steady-state support model thereafter:

| Tier | Responsibility | Response Time | Escalation Path |
|------|----------------|---------------|-----------------|
| L1 — ANP Self-Service | Operational runbook procedures, known issues, CloudWatch alarm response | Same business day | Escalate to L2 if runbook does not resolve |
| L2 — nClouds Hypercare (Weeks 6-7) | Bug fixes, defect resolution, integration query support | P1: 4 hours; P2: 8 hours; P3: 1 business day | Jonas Bull to nClouds engineering team |
| L3 — AWS Support | AWS service-level issues (Bedrock, Lambda, DynamoDB outages) | Per AWS support SLA | Opened by ANP against ANP AWS account |
| Steady-State (Post-Hypercare) | Full operational responsibility passes to ANP Streaming | Per ANP internal SLA | AWS Developer Support for AWS service issues |

### Contact Information

The following table lists all project team members and their contact information for the duration of the engagement and hypercare period:

| Role | Name | Email | Availability |
|------|------|-------|--------------|
| nClouds Engagement Lead (Hypercare) | Jonas Bull | jonas.bull@nclouds.com | Business hours Mon-Fri |
| ANP Executive Sponsor | Lilly Goyah | lilly.goyah@anpstreaming.com | Business hours |
| ANP Technical Contact | Designated by ANP pre-kickoff | Confirmed at project kickoff | Business hours |
| AWS Support | AWS Developer Support | console.aws.amazon.com/support | Per support plan |

## Hypercare Period

The hypercare support period follows Production go-live and is the final delivery obligation under the SOW:

- **Duration:** 2 weeks post-go-live (approximately Weeks 6-7 of the engagement)
- **Coverage:** Business hours, Monday-Friday, 9 AM-5 PM (ANP Streaming's local time zone)
- **Scope includes:** Bug fixes in delivered Lambda code or CDK infrastructure; integration questions from ANP FlutterFlow development team; CloudWatch alarm investigation; Bedrock prompt accuracy tuning
- **Scope excludes:** New feature development; Firebase infrastructure support; FlutterFlow frontend modifications; third-party AWS service outages; post-SOW scope changes
- **Response Times:** P1 (Production outage): 4-hour response; P2 (Degraded functionality): 8-hour response; P3 (Guidance/queries): 1 business day

## Transition to Steady-State Operations

The following phased transition model ensures ANP Streaming achieves full operational independence:

| Week | Operational Posture |
|------|---------------------|
| Week 5 (Go-Live) | nClouds-led — nClouds team monitors Production; ANP technical contact observing |
| Week 6 | Joint operations — ANP technical contact responds to alerts using runbook; nClouds on standby |
| Week 7 | ANP-led — ANP technical contact owns all operational responses; nClouds available for escalation |
| Week 8+ (Post-Hypercare) | ANP fully independent — AWS Developer Support for service issues; nClouds available for new work |

## Handover Checklist

The following items must be verified and accepted before the engagement is formally closed:

- [ ] All 20 SOW deliverables delivered and accepted within the 3-business-day review window
- [ ] GitHub repository with Lambda source code and CDK IaC codebase transferred to ANP Streaming ownership
- [ ] ANP Streaming named IAM administrator account (with MFA) created and credentials securely transferred
- [ ] All nClouds IAM users removed from the ANP Streaming AWS account
- [ ] Production API key and Cognito configuration distributed to ANP FlutterFlow team via secure channel
- [ ] ANP technical contact confirmed ability to log into AWS Console, view CloudWatch dashboards, and navigate the operational runbook independently
- [ ] CloudWatch alarm SNS email subscription confirmed and test alert received by ANP technical contact
- [ ] DynamoDB PITR enabled on both Production tables
- [ ] AWS Developer Support plan active on ANP Streaming AWS account
- [ ] Project Closeout Report signed by Lilly Goyah

---

# Training Program

This section defines the complete training program for all ANP Streaming user groups, ensuring all roles achieve competency with the AI Mood & Recommendation API before and during the go-live period. Training is delivered during Phase 3 (Weeks 5-6) in parallel with validation activities.

## Training Overview

### Objectives

The training program ensures that ANP Streaming's technical team can independently operate, troubleshoot, and evolve the AI Mood & Recommendation API after the 2-week hypercare period ends. Given the small team size (one designated technical contact plus CEO as business owner), the program is focused and practical, emphasizing runbook-driven self-sufficiency.

### Training Approach

- **Role-Based Delivery:** Content is tailored to the ANP technical contact (operator focus) and Lilly Goyah (business/executive focus)
- **Hands-On First:** All technical modules include live sandbox exercises using the Dev environment
- **Recorded for Reference:** The live knowledge transfer session (SOW Deliverable #19) is recorded and delivered as part of the handover package
- **Documentation-Anchored:** Each training module references a specific section of the operational runbook or API documentation for ongoing self-service

### Training Schedule

The following table lists all 10 training modules with their target audience, duration, format, and prerequisites:

| Module ID | Module Name | Target Audience | Duration | Format | Prerequisites |
|-----------|-------------|-----------------|----------|--------|---------------|
| TRN-001 | System Architecture Overview | Technical Contact + Lilly Goyah | 30 min | Recorded walkthrough | None |
| TRN-002 | AWS Console Navigation and CloudWatch Dashboards | ANP Technical Contact | 45 min | Hands-on lab (Dev) | TRN-001 |
| TRN-003 | API Reference and FlutterFlow Integration | ANP Technical Contact | 60 min | Document walkthrough + API testing | TRN-001 |
| TRN-004 | Live Knowledge Transfer Session (Recorded) | ANP Technical Contact | 2 hours | ILT (live, recorded) | TRN-001 through TRN-003 |
| TRN-005 | Alarm Response and Runbook Navigation | ANP Technical Contact | 45 min | Hands-on lab (Dev) | TRN-002 |
| TRN-006 | Secrets Manager and API Key Rotation | ANP Technical Contact | 30 min | Hands-on lab (Dev) | TRN-002 |
| TRN-007 | IaC Re-Deployment and Rollback Procedures | ANP Technical Contact | 60 min | Hands-on lab (Dev) | TRN-002 |
| TRN-008 | Executive Dashboard and Business Metrics Review | Lilly Goyah (CEO) | 30 min | Demo walkthrough | TRN-001 |
| TRN-009 | Bedrock Prompt Tuning for Accuracy Adjustment | ANP Technical Contact | 45 min | Guided walkthrough (Dev) | TRN-004 |
| TRN-010 | DynamoDB Maintenance and Data Lifecycle | ANP Technical Contact | 30 min | Document walkthrough | TRN-004 |

## Administrator Training

### TRN-001: System Architecture Overview (30 minutes, Recorded Walkthrough)

**Learning Objectives:**
- Describe the end-to-end flow from FlutterFlow API call through API Gateway, Lambda, and Bedrock to DynamoDB
- Identify the three Lambda functions (Classifier, Recommender, Auto-Tagger) and their roles
- Understand the two DynamoDB tables (`anp-catalog-moods`, `anp-user-history`) and their purpose
- Locate key AWS services in the AWS Console (Lambda, API Gateway, DynamoDB, S3, CloudWatch)

**Content Outline:**
1. Architecture diagram walkthrough — 10 minutes
2. AWS Console navigation tour — 15 minutes
3. Knowledge check — 5 minutes

**Materials Required:** Architecture diagram, AWS Console access, quick reference card

### TRN-002: AWS Console Navigation and CloudWatch Dashboards (45 minutes, Hands-On Lab)

**Learning Objectives:**
- Navigate to `ANP-Operations` and `ANP-Cost-Tracking` CloudWatch dashboards
- Interpret Lambda error rate and p95 latency metrics
- View and query Lambda CloudWatch log groups using Log Insights
- Understand the DLQ depth alarm and what it indicates

**Lab Exercises:**
- Exercise 1: Navigate to `ANP-Operations` dashboard and identify current p95 latency
- Exercise 2: Run a Log Insights query to find the last 10 successful classification calls
- Exercise 3: Verify the most recent SNS email notification was received

**Materials Required:** AWS Console access with CloudWatch permissions, sample Log Insights query from the runbook

### TRN-003: API Reference and FlutterFlow Integration (60 minutes, Document Walkthrough + API Testing)

**Learning Objectives:**
- Navigate the API Reference Documentation for both endpoints
- Construct valid `POST /classify` and `GET /recommend` API requests using cURL
- Interpret API error responses and map them to the runbook section
- Explain the Cognito JWT flow to the FlutterFlow development team

**Lab Exercises:**
- Exercise 1: Make a successful `POST /classify` call using cURL and capture the response
- Exercise 2: Intentionally trigger HTTP 400 by submitting an empty `text` field
- Exercise 3: Confirm the maximum `limit` parameter value by reading the API reference

**Materials Required:** API Reference Documentation (SOW Deliverable #17), cURL configured with Dev API key, Cognito test user credentials

## End User Training

### TRN-004: Live Knowledge Transfer Session (2 hours, ILT — Recorded)

This is the mandatory knowledge transfer session defined in SOW Deliverable #19. It is conducted live by Jonas Bull (Solution Architect) with the ANP technical contact, recorded in full, and delivered as part of the handover package.

**Learning Objectives:**
- Understand how the three Lambda functions interact with Bedrock, DynamoDB, S3, and API Gateway
- Monitor the system using CloudWatch dashboards and respond to alarms using the runbook
- Deploy infrastructure changes using CDK IaC templates from the GitHub repository
- Update the Bedrock prompt for mood classification if accuracy needs tuning
- Rotate API keys and Firebase credentials in Secrets Manager
- Navigate the operational runbook for all seven monitored alarm conditions

**Content Outline:**
1. Architecture walkthrough (live whiteboard) — 20 minutes
2. CloudWatch monitoring and alarm response — 30 minutes
3. Operational procedures (CDK deploy, Lambda rollback, API key rotation) — 30 minutes
4. Bedrock prompt tuning — 20 minutes
5. Q&A and runbook walkthrough — 20 minutes

**Assessment:** After the session, the ANP technical contact must demonstrate independently:
- [ ] Navigate to `ANP-Operations` dashboard
- [ ] Retrieve and interpret Lambda logs from CloudWatch Log Insights
- [ ] Follow the runbook alarm-response procedure for the Classifier error rate alarm
- [ ] Initiate a Lambda alias rollback in Dev

**Materials Required:** Operational Runbook (SOW Deliverable #18), AWS Console access to Dev and Production, GitHub repository access, recording software (Zoom or Google Meet)

### TRN-005: Alarm Response and Runbook Navigation (45 minutes, Hands-On Lab)

**Learning Objectives:**
- Respond to each of the seven configured CloudWatch alarm types using the operational runbook
- Use CloudWatch Log Insights to investigate Lambda errors
- Interpret DLQ depth alarms and re-process failed Auto-Tagger events
- Escalate issues to nClouds (during hypercare) or AWS Support appropriately

**Lab Exercises:**
- Exercise 1: Locate the runbook procedure for the Classifier Lambda error rate alarm
- Exercise 2: Run the CloudWatch Log Insights query from the runbook to find error events in Dev

**Materials Required:** Operational Runbook, AWS Console access to CloudWatch and SQS in Dev

### TRN-006: Secrets Manager and API Key Rotation (30 minutes, Hands-On Lab)

**Learning Objectives:**
- Rotate the API Gateway API key using the Secrets Manager update procedure
- Rotate the Firebase service account key manually using the runbook procedure
- Distribute the new API key to the FlutterFlow team via the approved secure channel
- Verify rotation was successful without disrupting active API calls

**Lab Exercises:**
- Exercise 1: Update the Dev API key secret value in Secrets Manager
- Exercise 2: Verify a Lambda warm-start picks up the updated secret value
- Exercise 3: Confirm the old API key is invalidated after rotation

**Materials Required:** Operational Runbook (Secrets Management section), AWS Console access to Secrets Manager in Dev

## Technical Staff Training

### TRN-007: IaC Re-Deployment and Rollback Procedures (60 minutes, Hands-On Lab)

**Learning Objectives:**
- Clone the CDK IaC repository and understand the stack structure
- Execute a full `cdk deploy` for the Dev environment
- Roll back a Lambda function using the alias update procedure
- Understand when to use `cdk deploy` versus Lambda alias rollback

**Lab Exercises:**
- Exercise 1: Run `cdk diff ANPComputeDevStack` to see what would change
- Exercise 2: Deploy a minor Lambda configuration change to Dev using `cdk deploy`
- Exercise 3: Roll back the Lambda `LIVE` alias to the previous published version

**Materials Required:** GitHub repository access, AWS CLI with Dev profile, Node.js and CDK CLI installed

### TRN-008: Executive Dashboard and Business Metrics Review (30 minutes, Demo Walkthrough)

This module is designed for Lilly Goyah (CEO) and focuses on business-level visibility into the AI API performance and cost.

**Learning Objectives:**
- Access the `ANP-Operations` CloudWatch dashboard to understand API usage trends
- Interpret daily API invocation counts as a proxy for feature adoption
- Review the `ANP-Cost-Tracking` dashboard for monthly infrastructure cost trends
- Understand the 2-week hypercare support model and escalation process

**Content Outline:**
1. Business metrics on `ANP-Operations` dashboard — 15 minutes
2. Cost tracking dashboard — 10 minutes
3. Hypercare and ongoing support summary — 5 minutes

**Materials Required:** AWS Console access (read-only CloudWatch for Lilly Goyah), `ANP-Cost-Tracking` dashboard screenshot

### TRN-009: Bedrock Prompt Tuning for Accuracy Adjustment (45 minutes, Guided Walkthrough)

**Learning Objectives:**
- Locate the Bedrock prompt template in the Lambda source code
- Test prompt changes in the Amazon Bedrock Playground without deploying code
- Measure accuracy change on a sample of labeled content before and after prompt adjustment
- Deploy an updated prompt via Lambda code update and CDK

**Lab Exercises:**
- Exercise 1: Test the current prompt in Bedrock Playground against 5 labeled lyric samples
- Exercise 2: Modify the prompt instruction text and compare accuracy on the same samples
- Exercise 3: Review the CDK deployment command to publish a Lambda with an updated prompt

**Materials Required:** Amazon Bedrock console access, labeled test content sample (10-20 items), Lambda source code repository access

### TRN-010: DynamoDB Maintenance and Data Lifecycle (30 minutes, Document Walkthrough)

**Learning Objectives:**
- Understand the 90-day TTL policy on `anp-user-history` records
- Initiate a DynamoDB PITR point-in-time restore from the operational runbook
- Monitor DynamoDB capacity metrics on the `ANP-Operations` dashboard
- Understand when to switch from pay-per-request to provisioned capacity mode

**Content Outline:**
1. DynamoDB table structure and TTL policy review — 10 minutes
2. PITR restore procedure walkthrough from runbook — 10 minutes
3. Capacity mode decision criteria and cost impact — 10 minutes

**Materials Required:** Operational Runbook (DynamoDB Maintenance section), AWS Console access to DynamoDB in Dev

## Training Materials

### Documentation Package Delivered to ANP Streaming

The following materials are included in the training and handover package:

- API Reference Documentation (developer-facing, 20-30 pages) — SOW Deliverable #17
- Operational Runbook (15-20 pages, covering all 7 alarm types and maintenance procedures) — SOW Deliverable #18
- Quick Reference Card: Lambda function names, table names, dashboard URLs, escalation contacts (1 page)
- Knowledge Transfer Session Recording (2-hour video) — SOW Deliverable #19
- Architecture Diagram from the Detailed Design Document
- GitHub Repository README covering CDK deployment and Lambda update procedures

### Training Environment

- Dev AWS environment is used for all hands-on lab exercises
- Dev environment uses synthetic test users and a sample catalog — not live user data
- Dev API endpoint and credentials provided to the ANP technical contact for training exercises
- Dev environment remains available for 30 days post-handover to support self-directed learning

## Training Effectiveness

### Assessment Approach

All competency assessments are practical (observed task completion) to reflect the operational nature of the role:

- **TRN-004 (Knowledge Transfer):** ANP technical contact completes a 4-item practical checklist at session end (observed by Jonas Bull)
- **TRN-007 (IaC Re-Deployment):** ANP technical contact executes a Dev re-deployment independently (observed by nClouds Cloud Engineer)
- **TRN-003 (API Integration):** ANP technical contact makes a successful API call from cURL without assistance

### Success Metrics

The following table defines success thresholds for the training program:

| Metric | Target |
|--------|--------|
| Training Completion Rate | 100% of all 10 modules completed before hypercare end |
| Knowledge Transfer Practical Checklist | 4/4 items demonstrated independently |
| IaC Re-Deployment Lab | Completed without nClouds assistance |
| Post-Training Self-Sufficiency | ANP technical contact resolves P3 issues independently during hypercare week 2 |
| ANP Technical Contact Satisfaction | >= 4.0/5.0 on post-training feedback form |

---

# Appendices

## Appendix A: Environment Details

### Development Environment

The following table lists all key resource identifiers for the Dev environment:

| Component | Value |
|-----------|-------|
| AWS Account ID | Provided by ANP Streaming at kickoff |
| Region | `us-east-1` |
| CDK Stack Prefix | `ANP*Dev*Stack` |
| Classifier Lambda | `anp-classifier-dev` |
| Recommender Lambda | `anp-recommender-dev` |
| Auto-Tagger Lambda | `anp-autotagger-dev` |
| Catalog DynamoDB Table | `anp-catalog-moods-dev` |
| User History DynamoDB Table | `anp-user-history-dev` |
| S3 Catalog Bucket | `anp-catalog-<account-id>-dev` |
| Cognito User Pool | `anp-users-dev` |
| API Gateway Name | `anp-api-dev` |
| CloudWatch Dashboard | `ANP-Operations` |
| Access Method | Named IAM user with MFA + AWS CLI profile `anp-dev` |

### Production Environment

The following table lists all key resource identifiers for the Production environment:

| Component | Value |
|-----------|-------|
| AWS Account ID | Same account as Dev; environment separated by resource name suffix |
| Region | `us-east-1` |
| CDK Stack Prefix | `ANP*Prod*Stack` |
| Classifier Lambda | `anp-classifier-prod` |
| Recommender Lambda | `anp-recommender-prod` |
| Auto-Tagger Lambda | `anp-autotagger-prod` |
| Catalog DynamoDB Table | `anp-catalog-moods-prod` |
| User History DynamoDB Table | `anp-user-history-prod` |
| S3 Catalog Bucket | `anp-catalog-<account-id>-prod` |
| Cognito User Pool | `anp-users-prod` |
| API Gateway Name | `anp-api-prod` |
| CloudWatch Dashboard | `ANP-Operations` |
| Access Method | Named IAM administrator account with MFA; IaC pipeline for all changes |

## Appendix B: Configuration Reference

The complete configuration parameter reference is maintained in `configuration.csv` in the delivery artifacts. Key parameters relevant to steady-state operations are summarized below:

| Parameter | Prod Value | Purpose |
|-----------|------------|---------|
| `compute.lambda.classifier.memory_mb` | 1024 | Classifier Lambda memory — affects CPU and cold-start latency |
| `compute.lambda.classifier.provisioned_concurrency` | 0 | Set above 0 if load testing shows p95 > 2,000ms from cold starts |
| `database.catalog_moods.min_confidence_threshold` | 0.5 | Minimum Bedrock confidence for recommendation inclusion |
| `database.user_history.ttl_days` | 90 | User history record automatic deletion period |
| `monitoring.alarm.classifier_error_rate_pct` | 1 | Classifier Lambda error rate alarm threshold (percent) |
| `monitoring.alarm.apigw_p95_latency_ms` | 2000 | API Gateway p95 latency alarm threshold (ms) |
| `operations.deployment.rollback_trigger_error_pct` | 10 | Production rollback trigger error rate percent |
| `operations.hypercare.duration_weeks` | 2 | Post-go-live hypercare support duration |
| `operations.rto_minutes` | 60 | Recovery Time Objective (minutes) |
| `operations.rpo_hours` | 24 | Recovery Point Objective (hours) |

## Appendix C: Deployment Scripts

### Full Environment Deployment Script

The following script deploys all five CDK stacks to a target environment in dependency order:

```bash
#!/bin/bash
# deploy-environment.sh — Deploys all ANP Streaming AI stacks to target environment
set -euo pipefail

ENVIRONMENT=${1:-dev}
AWS_PROFILE_NAME="anp-${ENVIRONMENT}"

echo "[$(date)] Starting ANP Streaming AI deployment to ${ENVIRONMENT}"
export AWS_PROFILE=$AWS_PROFILE_NAME

aws sts get-caller-identity --query "Account" --output text
echo "AWS credentials verified"

cd "$(dirname "$0")/../infrastructure"
npm ci

STACKS=(
  "ANPSecurity${ENVIRONMENT^}Stack"
  "ANPData${ENVIRONMENT^}Stack"
  "ANPCompute${ENVIRONMENT^}Stack"
  "ANPApi${ENVIRONMENT^}Stack"
  "ANPMonitoring${ENVIRONMENT^}Stack"
)

for STACK in "${STACKS[@]}"; do
  echo "[$(date)] Deploying $STACK..."
  cdk deploy "$STACK" \
    --require-approval never \
    --outputs-file "./outputs/${STACK}-outputs.json" \
    --tags Environment="${ENVIRONMENT}" \
    --tags Project=ANPStreamingAI \
    --tags CostCenter=OPP-2025-001 \
    --tags ManagedBy=cdk
  echo "[$(date)] $STACK complete"
done

echo "[$(date)] All stacks deployed successfully to ${ENVIRONMENT}"
```

### Lambda Rollback Script

The following script rolls back all Lambda functions to their previous published version:

```bash
#!/bin/bash
# rollback-lambda.sh — Rolls back all Lambda functions to the previous published version
set -euo pipefail

ENVIRONMENT=${1:-prod}
export AWS_PROFILE="anp-${ENVIRONMENT}"

FUNCTIONS=(
  "anp-classifier-${ENVIRONMENT}"
  "anp-recommender-${ENVIRONMENT}"
  "anp-autotagger-${ENVIRONMENT}"
)

echo "[$(date)] ROLLBACK initiated for environment: ${ENVIRONMENT}"

for FN in "${FUNCTIONS[@]}"; do
  CURRENT=$(aws lambda get-alias --function-name "$FN" \
    --name LIVE --query FunctionVersion --output text)
  PREV=$(aws lambda list-versions-by-function \
    --function-name "$FN" \
    --query "sort_by(Versions, &LastModified)[-2].Version" \
    --output text)

  if [ "$PREV" = "None" ] || [ -z "$PREV" ]; then
    echo "WARNING: $FN has no previous version — skipping"
    continue
  fi

  echo "$FN: rolling back from version $CURRENT to version $PREV"
  aws lambda update-alias --function-name "$FN" --name LIVE --function-version "$PREV"
  echo "$FN: rollback complete"
done

echo "[$(date)] Rollback complete. Notify Jonas Bull immediately."
echo "Root cause analysis required within 24 hours."
```

## Appendix D: Troubleshooting Guide

### Common Issue 1: Classifier Lambda Returns HTTP 500

**Symptoms:** `POST /classify` returns HTTP 500; CloudWatch alarm `anp-classifier-error-rate-1pct-prod` in ALARM state.

**Cause:** Bedrock `InvokeModel` call failure (ThrottlingException or ModelNotReadyException) or malformed Bedrock response parsing.

**Resolution:**

```bash
# Step 1: Check Lambda error logs in CloudWatch Log Insights
aws logs start-query \
  --log-group-name "/aws/lambda/anp-classifier" \
  --start-time $(date -d "-1 hour" +%s)000 \
  --end-time $(date +%s)000 \
  --query-string 'fields @timestamp, @message | filter level = "ERROR" | sort @timestamp desc | limit 20'

# Step 2: Check AWS Service Health Dashboard for Bedrock in us-east-1
# URL: https://health.aws.amazon.com/health/status

# Step 3: If ThrottlingException, enable provisioned concurrency
aws lambda put-provisioned-concurrency-config \
  --function-name anp-classifier-prod \
  --qualifier LIVE \
  --provisioned-concurrent-executions 2
```

**Prevention:** Configure exponential backoff retry in the Classifier Lambda for `ThrottlingException`. If throttling is sustained, evaluate Bedrock provisioned throughput.

### Common Issue 2: Auto-Tagger DLQ Depth Greater Than Zero

**Symptoms:** CloudWatch alarm `anp-autotagger-dlq-depth-prod` in ALARM state; new catalog uploads not appearing in DynamoDB.

**Cause:** Auto-Tagger Lambda failed to process one or more S3 events after 3 retries due to Bedrock throttling, malformed S3 object key, or Lambda timeout on large transcript files.

**Resolution:**

```bash
# Step 1: Inspect the failed S3 event message from the DLQ
DLQ_URL=$(aws sqs get-queue-url \
  --queue-name anp-autotagger-dlq-prod --query QueueUrl --output text)
aws sqs receive-message \
  --queue-url $DLQ_URL \
  --max-number-of-messages 1 \
  --query "Messages[0].Body"

# Step 2: Investigate Auto-Tagger logs for the failure cause
aws logs filter-log-events \
  --log-group-name "/aws/lambda/anp-autotagger" \
  --filter-pattern "ERROR" \
  --start-time $(date -d "-2 hours" +%s)000

# Step 3: Re-process the failed catalog file by re-uploading it to S3
aws s3 cp s3://anp-catalog-<account-id>-prod/catalog/<failed-content-id>.txt /tmp/reprocess.txt
aws s3 cp /tmp/reprocess.txt \
  s3://anp-catalog-<account-id>-prod/catalog/<failed-content-id>.txt \
  --sse AES256
```

**Prevention:** Keep catalog text files under 50 KB to avoid Lambda timeout during Bedrock inference.

### Common Issue 3: p95 Latency Exceeds 2,000ms

**Symptoms:** CloudWatch alarm `anp-apigw-p95-latency-2000ms-prod` in ALARM state; users reporting slow API responses.

**Cause:** Bedrock cold-start latency on the Classifier Lambda or Bedrock service degradation.

**Resolution:**

```bash
# Step 1: Check for Lambda cold-start events in CloudWatch Logs
aws logs start-query \
  --log-group-name "/aws/lambda/anp-classifier" \
  --start-time $(date -d "-30 minutes" +%s)000 \
  --end-time $(date +%s)000 \
  --query-string 'fields @timestamp, @initDuration, @duration | filter @initDuration > 0 | sort @timestamp desc | limit 10'

# Step 2: Enable provisioned concurrency if cold starts are frequent
aws lambda put-provisioned-concurrency-config \
  --function-name anp-classifier-prod \
  --qualifier LIVE \
  --provisioned-concurrent-executions 2
```

**Prevention:** Run Lambda Power Tuning quarterly to validate the 1024 MB memory allocation remains optimal.

## Appendix E: Contact Information

### Project Team

The following table lists all project team members and their contact details for the duration of the engagement:

| Role | Name | Email | Scope |
|------|------|-------|-------|
| Engagement Lead / Solution Architect | Jonas Bull | jonas.bull@nclouds.com | Overall technical and commercial accountability |
| ANP CEO / Executive Sponsor | Lilly Goyah | lilly.goyah@anpstreaming.com | Deliverable acceptance, go-live approval |
| ANP Technical Contact | Designated pre-kickoff by ANP | Confirmed at project kickoff | Day-to-day technical liaison and UAT |
| nClouds Project Manager | Assigned at kickoff | Confirmed at project kickoff | Project coordination, status reporting |

### Escalation Contacts During Hypercare (Weeks 6-7)

The following escalation contacts apply throughout the 2-week hypercare period:

| Priority Level | Contact | Response Time | Scope |
|---------------|---------|---------------|-------|
| P1 — Production Outage | Jonas Bull via email | 4 hours (business hours) | Full Production API outage |
| P2 — Degraded Functionality | nClouds Engineering Team | 8 hours (business hours) | Latency > 2x SLA; accuracy below threshold |
| P3 — Guidance and Queries | nClouds Support | 1 business day | Integration questions; runbook navigation |

### Vendor Support

The following vendor support resources are available post-hypercare:

| Vendor | Support Portal | SLA |
|--------|----------------|-----|
| AWS (ANP Streaming account) | console.aws.amazon.com/support | AWS Developer Support (~24-hour business response) |
| Amazon Bedrock | AWS Support (same portal) | Per AWS Developer Support SLA |
| nClouds (post-hypercare) | Contact Jonas Bull to initiate new SOW | Per future MSA terms |

## Appendix F: Naming Convention Quick Reference

All AWS resources follow the naming pattern `anp-<component>-<environment>`. The following table is a quick reference for operational use:

| Resource | Dev Name | Prod Name |
|----------|----------|-----------|
| Classifier Lambda | `anp-classifier-dev` | `anp-classifier-prod` |
| Recommender Lambda | `anp-recommender-dev` | `anp-recommender-prod` |
| Auto-Tagger Lambda | `anp-autotagger-dev` | `anp-autotagger-prod` |
| Catalog DynamoDB Table | `anp-catalog-moods-dev` | `anp-catalog-moods-prod` |
| User History DynamoDB Table | `anp-user-history-dev` | `anp-user-history-prod` |
| Catalog GSI | `mood_label-index` | `mood_label-index` |
| Auto-Tagger DLQ | `anp-autotagger-dlq-dev` | `anp-autotagger-dlq-prod` |
| API Gateway | `anp-api-dev` | `anp-api-prod` |
| S3 Catalog Bucket | `anp-catalog-<acct-id>-dev` | `anp-catalog-<acct-id>-prod` |
| Cognito User Pool | `anp-users-dev` | `anp-users-prod` |
| Operations Dashboard | `ANP-Operations` | `ANP-Operations` |
| Cost Dashboard | `ANP-Cost-Tracking` | `ANP-Cost-Tracking` |
| Ops SNS Topic | `anp-ops-alerts-dev` | `anp-ops-alerts-prod` |

---

*Document Version: 1.0 | Prepared by nClouds, Inc. | June 2025 | Opportunity: OPP-2025-001*
*This Implementation Guide is aligned to SOW v1.0 and Detailed Design Document v1.0 for the ANP Streaming AI Mood & Recommendation API engagement.*
