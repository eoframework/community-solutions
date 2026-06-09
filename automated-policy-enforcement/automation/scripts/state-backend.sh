#!/usr/bin/env bash
#------------------------------------------------------------------------------
# AWS Cloud Governance Platform — State Backend Setup Script
# Creates S3 bucket + DynamoDB table for Terraform remote state management
# Usage: ./state-backend.sh <prod|test|dr>
#------------------------------------------------------------------------------

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

ENVIRONMENT="${1:-prod}"

if [[ ! "$ENVIRONMENT" =~ ^(prod|test|dr)$ ]]; then
  echo -e "${RED}Error: environment must be prod, test, or dr${NC}"
  echo -e "${CYAN}Usage: $0 <prod|test|dr>${NC}"
  exit 1
fi

echo -e "${BLUE}🏗️  Setting up Terraform backend for ${ENVIRONMENT} environment${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

# Read region from environment config
REGION_MAP_prod="ap-southeast-2"
REGION_MAP_test="ap-southeast-2"
REGION_MAP_dr="ap-southeast-4"

REGION_VAR="REGION_MAP_${ENVIRONMENT}"
REGION="${!REGION_VAR}"

# Derive resource names from solution name
SOLUTION_NAME="aws-governance-platform"
STATE_BUCKET="${SOLUTION_NAME}-tfstate-${ENVIRONMENT}"
LOCK_TABLE="${SOLUTION_NAME}-tflock-${ENVIRONMENT}"

echo -e "${YELLOW}Environment : ${ENVIRONMENT}${NC}"
echo -e "${YELLOW}Region      : ${REGION}${NC}"
echo -e "${YELLOW}S3 Bucket   : ${STATE_BUCKET}${NC}"
echo -e "${YELLOW}DynamoDB    : ${LOCK_TABLE}${NC}"
echo ""

#------------------------------------------------------------------------------
# Create S3 state bucket
#------------------------------------------------------------------------------
echo -e "${BLUE}Creating S3 state bucket...${NC}"
aws s3api create-bucket \
  --bucket "$STATE_BUCKET" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION" \
  2>/dev/null || echo -e "${YELLOW}  Bucket already exists, continuing...${NC}"

aws s3api put-bucket-versioning \
  --bucket "$STATE_BUCKET" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "$STATE_BUCKET" \
  --server-side-encryption-configuration '{
    "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "aws:kms"}, "BucketKeyEnabled": true}]
  }'

aws s3api put-public-access-block \
  --bucket "$STATE_BUCKET" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo -e "${GREEN}  ✓ S3 state bucket configured${NC}"

#------------------------------------------------------------------------------
# Create DynamoDB lock table
#------------------------------------------------------------------------------
echo -e "${BLUE}Creating DynamoDB lock table...${NC}"
aws dynamodb create-table \
  --table-name "$LOCK_TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION" \
  2>/dev/null || echo -e "${YELLOW}  Table already exists, continuing...${NC}"

echo -e "${GREEN}  ✓ DynamoDB lock table configured${NC}"

#------------------------------------------------------------------------------
# Generate backend.tfvars
#------------------------------------------------------------------------------
BACKEND_FILE="../../environments/${ENVIRONMENT}/backend.tfvars"
mkdir -p "$(dirname "$BACKEND_FILE")"

cat > "$BACKEND_FILE" <<EOF
bucket         = "${STATE_BUCKET}"
key            = "terraform.tfstate"
region         = "${REGION}"
dynamodb_table = "${LOCK_TABLE}"
encrypt        = true
EOF

echo -e "${GREEN}  ✓ Generated ${BACKEND_FILE}${NC}"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Backend setup complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  cd ../../environments/${ENVIRONMENT}"
echo -e "  terraform init -backend-config=backend.tfvars"
