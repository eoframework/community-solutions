#!/bin/bash
# EO Framework — Backend State Setup
# Creates S3 bucket + DynamoDB table for Terraform remote state
# Usage: ./state-backend.sh <env>
# Example: ./state-backend.sh prod

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

[[ $# -ne 1 ]] && { echo -e "${RED}Usage: $0 <env>${NC}"; exit 1; }

ENV="${1}"
REGION="${AWS_REGION:-us-west-2}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="eofw-tfstate-${ACCOUNT_ID}-${ENV}"
TABLE_NAME="eofw-tfstate-lock-${ENV}"

echo -e "${CYAN}🔧 EO Framework — Terraform Backend Setup (${ENV})${NC}"
echo -e "  Account:  ${ACCOUNT_ID}"
echo -e "  Region:   ${REGION}"
echo -e "  Bucket:   ${BUCKET_NAME}"
echo -e "  Table:    ${TABLE_NAME}"
echo ""

# Create S3 bucket
echo -e "${YELLOW}Creating S3 state bucket...${NC}"
if aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
  echo -e "${GREEN}  ✓ Bucket already exists${NC}"
else
  aws s3api create-bucket \
    --bucket "${BUCKET_NAME}" \
    --region "${REGION}" \
    --create-bucket-configuration LocationConstraint="${REGION}"

  aws s3api put-bucket-versioning \
    --bucket "${BUCKET_NAME}" \
    --versioning-configuration Status=Enabled

  aws s3api put-bucket-encryption \
    --bucket "${BUCKET_NAME}" \
    --server-side-encryption-configuration \
    '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

  aws s3api put-public-access-block \
    --bucket "${BUCKET_NAME}" \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

  echo -e "${GREEN}  ✓ S3 bucket created${NC}"
fi

# Create DynamoDB lock table
echo -e "${YELLOW}Creating DynamoDB lock table...${NC}"
if aws dynamodb describe-table --table-name "${TABLE_NAME}" --region "${REGION}" 2>/dev/null; then
  echo -e "${GREEN}  ✓ DynamoDB table already exists${NC}"
else
  aws dynamodb create-table \
    --table-name "${TABLE_NAME}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "${REGION}"

  echo -e "${GREEN}  ✓ DynamoDB table created${NC}"
fi

# Write backend.tfvars
BACKEND_FILE="$(dirname "$0")/../../terraform/environments/${ENV}/backend.tfvars"
cat > "${BACKEND_FILE}" <<EOF
bucket         = "${BUCKET_NAME}"
key            = "eofw/${ENV}/terraform.tfstate"
region         = "${REGION}"
dynamodb_table = "${TABLE_NAME}"
encrypt        = true
EOF

echo -e "${GREEN}✅ Backend config written to: ${BACKEND_FILE}${NC}"
echo -e "\nNext step:"
echo -e "  cd terraform/environments/${ENV}"
echo -e "  terraform init -backend-config=backend.tfvars"
