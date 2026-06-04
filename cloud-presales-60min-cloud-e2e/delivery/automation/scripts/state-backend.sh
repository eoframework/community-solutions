#!/bin/bash
# State backend setup script for Amatra Agentic Orchestration Platform
# Creates S3 bucket and DynamoDB table for Terraform remote state
# Usage: ./state-backend.sh <environment>

set -e

ENVIRONMENT="${1:-prod}"
REGION="us-west-2"
STATE_BUCKET_SUFFIX="s3-tfstate"
LOCK_TABLE_SUFFIX="ddb-tfstate-lock"

echo "🔧 Setting up Terraform state backend for environment: ${ENVIRONMENT}"
echo "   Region: ${REGION}"

# Determine bucket and table names from environment
case $ENVIRONMENT in
  prod|dr)
    PREFIX="amatra-prod"
    ;;
  test|dev|staging)
    PREFIX="amatra-dev"
    ;;
  *)
    PREFIX="amatra-${ENVIRONMENT}"
    ;;
esac

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
STATE_BUCKET="${PREFIX}-${STATE_BUCKET_SUFFIX}-${ACCOUNT_ID}"
LOCK_TABLE="${PREFIX}-${LOCK_TABLE_SUFFIX}"

echo "   State bucket : ${STATE_BUCKET}"
echo "   Lock table   : ${LOCK_TABLE}"
echo ""

# Create S3 state bucket
echo "📦 Creating S3 state bucket..."
aws s3api create-bucket \
  --bucket "${STATE_BUCKET}" \
  --region "${REGION}" \
  --create-bucket-configuration LocationConstraint="${REGION}" 2>/dev/null || echo "   Bucket may already exist, continuing..."

aws s3api put-bucket-versioning \
  --bucket "${STATE_BUCKET}" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "${STATE_BUCKET}" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

aws s3api put-public-access-block \
  --bucket "${STATE_BUCKET}" \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "   ✓ S3 state bucket configured"

# Create DynamoDB lock table
echo "🔒 Creating DynamoDB lock table..."
aws dynamodb create-table \
  --table-name "${LOCK_TABLE}" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "${REGION}" 2>/dev/null || echo "   Table may already exist, continuing..."

echo "   ✓ DynamoDB lock table configured"

# Generate backend.tfvars
BACKEND_FILE="$(dirname "$0")/../../environments/${ENVIRONMENT}/backend.tfvars"
cat > "${BACKEND_FILE}" <<EOF
bucket         = "${STATE_BUCKET}"
key            = "amatra/${ENVIRONMENT}/terraform.tfstate"
region         = "${REGION}"
dynamodb_table = "${LOCK_TABLE}"
encrypt        = true
EOF

echo ""
echo "✅ Backend setup complete!"
echo "   backend.tfvars written to: ${BACKEND_FILE}"
echo ""
echo "Next step:"
echo "   cd environments/${ENVIRONMENT}"
echo "   terraform init -backend-config=backend.tfvars"
