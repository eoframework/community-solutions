#!/usr/bin/env bash
# =============================================================================
# MedCore CDS Platform — State Backend Setup
# Creates S3 bucket + DynamoDB table for Terraform remote state.
# Usage: ./state-backend.sh <prod|test|dr>
# =============================================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

ENVIRONMENT="${1:-}"
if [ -z "$ENVIRONMENT" ]; then
  echo -e "${RED}Error: environment argument required (prod|test|dr)${NC}"
  echo "Usage: $0 <prod|test|dr>"
  exit 1
fi

# Region mapping
case "$ENVIRONMENT" in
  "prod"|"test") AWS_REGION="us-east-1" ;;
  "dr")          AWS_REGION="us-west-2" ;;
  *) echo -e "${RED}Unknown environment: $ENVIRONMENT${NC}"; exit 1 ;;
esac

SOLUTION_NAME="medcore-cds"
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
BUCKET_NAME="${SOLUTION_NAME}-${ENVIRONMENT}-tfstate-${AWS_ACCOUNT_ID}"
TABLE_NAME="${SOLUTION_NAME}-${ENVIRONMENT}-tfstate-lock"

echo -e "${BLUE}🏗️  Setting up Terraform backend for ${ENVIRONMENT} (${AWS_REGION})${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "  Bucket: ${BUCKET_NAME}"
echo -e "  Table:  ${TABLE_NAME}"
echo -e "  Region: ${AWS_REGION}"
echo ""

# Create S3 bucket
if aws s3api head-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" 2>/dev/null; then
  echo -e "${YELLOW}  ⚠ S3 bucket already exists: $BUCKET_NAME${NC}"
else
  echo -e "${GREEN}  Creating S3 bucket...${NC}"
  if [ "$AWS_REGION" = "us-east-1" ]; then
    aws s3api create-bucket \
      --bucket "$BUCKET_NAME" \
      --region "$AWS_REGION"
  else
    aws s3api create-bucket \
      --bucket "$BUCKET_NAME" \
      --region "$AWS_REGION" \
      --create-bucket-configuration LocationConstraint="$AWS_REGION"
  fi
fi

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

# Block public access
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# Enable server-side encryption
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration \
    '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

# Create DynamoDB table for state locking
if aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$AWS_REGION" 2>/dev/null; then
  echo -e "${YELLOW}  ⚠ DynamoDB table already exists: $TABLE_NAME${NC}"
else
  echo -e "${GREEN}  Creating DynamoDB lock table...${NC}"
  aws dynamodb create-table \
    --table-name "$TABLE_NAME" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$AWS_REGION"
fi

# Write backend.tfvars
BACKEND_FILE="$(dirname "$0")/../../environments/${ENVIRONMENT}/backend.tfvars"
cat > "$BACKEND_FILE" <<EOF
bucket         = "${BUCKET_NAME}"
key            = "medcore-cds/${ENVIRONMENT}/terraform.tfstate"
region         = "${AWS_REGION}"
dynamodb_table = "${TABLE_NAME}"
encrypt        = true
EOF

echo ""
echo -e "${GREEN}✅ Backend configured!${NC}"
echo -e "${CYAN}  Next: cd environments/${ENVIRONMENT} && terraform init -backend-config=backend.tfvars${NC}"
