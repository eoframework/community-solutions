#!/usr/bin/env bash
# ANP Streaming AI - State Backend Setup
# Creates S3 bucket + DynamoDB lock table for Terraform remote state.
# Usage: ./state-backend.sh <prod|test|dr>

set -euo pipefail

ENVIRONMENT="${1:-prod}"
SOLUTION="anp-streaming-ai"
REGION="${2:-us-east-1}"

BUCKET_NAME="${SOLUTION}-tfstate-${ENVIRONMENT}"
DYNAMODB_TABLE="${SOLUTION}-tfstate-lock-${ENVIRONMENT}"

echo "🔧 Creating Terraform state backend for environment: ${ENVIRONMENT}"
echo "   Region:       ${REGION}"
echo "   S3 Bucket:    ${BUCKET_NAME}"
echo "   DynamoDB:     ${DYNAMODB_TABLE}"
echo ""

# Create S3 bucket
aws s3api create-bucket \
  --bucket "${BUCKET_NAME}" \
  --region "${REGION}" \
  $([ "${REGION}" != "us-east-1" ] && echo "--create-bucket-configuration LocationConstraint=${REGION}" || echo "") \
  2>/dev/null || echo "Bucket already exists"

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket "${BUCKET_NAME}" \
  --versioning-configuration Status=Enabled

# Enable server-side encryption
aws s3api put-bucket-encryption \
  --bucket "${BUCKET_NAME}" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Block public access
aws s3api put-public-access-block \
  --bucket "${BUCKET_NAME}" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Create DynamoDB lock table
aws dynamodb create-table \
  --table-name "${DYNAMODB_TABLE}" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "${REGION}" \
  2>/dev/null || echo "DynamoDB table already exists"

# Write backend.tfvars
BACKEND_FILE="$(dirname "$0")/../../environments/${ENVIRONMENT}/backend.tfvars"
cat > "${BACKEND_FILE}" <<EOF
bucket         = "${BUCKET_NAME}"
key            = "${SOLUTION}/${ENVIRONMENT}/terraform.tfstate"
region         = "${REGION}"
dynamodb_table = "${DYNAMODB_TABLE}"
encrypt        = true
EOF

echo ""
echo "✅ Backend created. To initialise:"
echo "   cd environments/${ENVIRONMENT}"
echo "   terraform init -backend-config=backend.tfvars"
