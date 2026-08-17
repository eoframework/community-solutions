#!/usr/bin/env bash
#------------------------------------------------------------------------------
# AWS Landing Zone — Terraform State Backend Setup (Linux/Mac)
# Creates S3 bucket + DynamoDB table for Terraform remote state
# Usage: ./state-backend.sh <prod|test|dr>
#------------------------------------------------------------------------------

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

ENVIRONMENT="${1:-}"
if [ -z "$ENVIRONMENT" ]; then
  echo -e "${RED}Error: environment argument required (prod|test|dr)${NC}"
  echo "Usage: $0 <prod|test|dr>"
  exit 1
fi

SOLUTION_ABBR="ins"
AWS_REGION="us-east-1"
[ "$ENVIRONMENT" = "dr" ] && AWS_REGION="us-east-2"

# Derive bucket/table names from environment
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="${SOLUTION_ABBR}-tf-state-${ENVIRONMENT}-${ACCOUNT_ID}"
TABLE_NAME="${SOLUTION_ABBR}-tf-lock-${ENVIRONMENT}"
STATE_KEY="landing-zone/${ENVIRONMENT}/terraform.tfstate"

echo -e "${BLUE}🔧 Setting up Terraform state backend for ${ENVIRONMENT}${NC}"
echo -e "${CYAN}  Bucket  : ${BUCKET_NAME}${NC}"
echo -e "${CYAN}  Table   : ${TABLE_NAME}${NC}"
echo -e "${CYAN}  Region  : ${AWS_REGION}${NC}"
echo ""

# Create S3 bucket
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  echo -e "${YELLOW}⚠  S3 bucket ${BUCKET_NAME} already exists — skipping creation${NC}"
else
  echo -e "${BLUE}Creating S3 bucket...${NC}"
  if [ "$AWS_REGION" = "us-east-1" ]; then
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION"
  else
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" \
      --create-bucket-configuration LocationConstraint="$AWS_REGION"
  fi
  aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled
  aws s3api put-public-access-block --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
      BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
  aws s3api put-bucket-encryption --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration \
      '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
  echo -e "${GREEN}✅ S3 bucket created${NC}"
fi

# Create DynamoDB table
if aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$AWS_REGION" 2>/dev/null; then
  echo -e "${YELLOW}⚠  DynamoDB table ${TABLE_NAME} already exists — skipping creation${NC}"
else
  echo -e "${BLUE}Creating DynamoDB lock table...${NC}"
  aws dynamodb create-table \
    --table-name "$TABLE_NAME" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$AWS_REGION"
  aws dynamodb wait table-exists --table-name "$TABLE_NAME" --region "$AWS_REGION"
  echo -e "${GREEN}✅ DynamoDB table created${NC}"
fi

# Generate backend.tfvars
BACKEND_FILE="$(dirname "$0")/../../environments/${ENVIRONMENT}/backend.tfvars"
cat > "$BACKEND_FILE" <<EOF
bucket         = "${BUCKET_NAME}"
key            = "${STATE_KEY}"
region         = "${AWS_REGION}"
dynamodb_table = "${TABLE_NAME}"
encrypt        = true
EOF

echo -e "${GREEN}✅ backend.tfvars written to environments/${ENVIRONMENT}/backend.tfvars${NC}"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo -e "  cd environments/${ENVIRONMENT}"
echo -e "  terraform init -backend-config=backend.tfvars"
