#!/bin/bash
# Amatra Agentic Orchestration Platform
# Backend State Setup — creates S3 bucket + DynamoDB lock table for Terraform state
# Usage: ./state-backend.sh <prod|test|dr>

set -e

ENVIRONMENT="${1:-prod}"
REGION="us-west-2"

echo "🔧 Setting up Terraform remote state backend for: $ENVIRONMENT"
echo "   Region: $REGION"

# Read config to get state bucket/table names
# These values come from configuration.csv via the orchestrator
# For manual setup, provide values directly:
STATE_BUCKET="amatra-${ENVIRONMENT}-s3-tfstate-$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo 'ACCOUNT_ID')"
LOCK_TABLE="amatra-${ENVIRONMENT}-ddb-tfstate-lock"

echo "   State bucket: $STATE_BUCKET"
echo "   Lock table: $LOCK_TABLE"

# Create S3 bucket for state storage
if ! aws s3api head-bucket --bucket "$STATE_BUCKET" --region "$REGION" 2>/dev/null; then
  echo "📦 Creating S3 state bucket..."
  aws s3api create-bucket \
    --bucket "$STATE_BUCKET" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"

  aws s3api put-bucket-versioning \
    --bucket "$STATE_BUCKET" \
    --versioning-configuration Status=Enabled

  aws s3api put-bucket-encryption \
    --bucket "$STATE_BUCKET" \
    --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

  aws s3api put-public-access-block \
    --bucket "$STATE_BUCKET" \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

  echo "✅ State bucket created: $STATE_BUCKET"
else
  echo "✅ State bucket already exists: $STATE_BUCKET"
fi

# Create DynamoDB table for state locking
if ! aws dynamodb describe-table --table-name "$LOCK_TABLE" --region "$REGION" 2>/dev/null; then
  echo "🔒 Creating DynamoDB lock table..."
  aws dynamodb create-table \
    --table-name "$LOCK_TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$REGION"

  aws dynamodb wait table-exists \
    --table-name "$LOCK_TABLE" \
    --region "$REGION"

  echo "✅ Lock table created: $LOCK_TABLE"
else
  echo "✅ Lock table already exists: $LOCK_TABLE"
fi

# Generate backend.tfvars
BACKEND_FILE="../../environments/${ENVIRONMENT}/backend.tfvars"
cat > "$BACKEND_FILE" <<EOF
bucket         = "$STATE_BUCKET"
key            = "amatra/${ENVIRONMENT}/terraform.tfstate"
region         = "$REGION"
dynamodb_table = "$LOCK_TABLE"
encrypt        = true
EOF

echo ""
echo "✅ Backend setup complete!"
echo "   backend.tfvars written to: $BACKEND_FILE"
echo ""
echo "Next: cd environments/${ENVIRONMENT} && terraform init -backend-config=backend.tfvars"
