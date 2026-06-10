#!/bin/bash
# Amatra ISB — Terraform State Backend Setup
# Creates S3 bucket + DynamoDB table for remote state management
# Usage: ./state-backend.sh <prod|test|dr>
#
# PREREQUISITES:
#   - AWS CLI configured with appropriate credentials
#   - IAM permissions: s3:CreateBucket, s3:PutBucketVersioning,
#     s3:PutBucketEncryption, dynamodb:CreateTable

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

ENVIRONMENT="${1:-prod}"
REGION="${2:-us-west-2}"
SOLUTION_ABBR="isb"

if [[ ! "$ENVIRONMENT" =~ ^(prod|test|dr)$ ]]; then
    echo -e "${RED}❌ Invalid environment: $ENVIRONMENT. Must be prod, test, or dr${NC}"
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="amatra-${SOLUTION_ABBR}-tfstate-${ENVIRONMENT}-${ACCOUNT_ID}"
TABLE_NAME="amatra-${SOLUTION_ABBR}-tflock-${ENVIRONMENT}"

echo -e "${BLUE}🏗️  Setting up Terraform state backend${NC}"
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo -e "${CYAN}  Environment: ${ENVIRONMENT}${NC}"
echo -e "${CYAN}  Region:      ${REGION}${NC}"
echo -e "${CYAN}  Account:     ${ACCOUNT_ID}${NC}"
echo -e "${CYAN}  Bucket:      ${BUCKET_NAME}${NC}"
echo -e "${CYAN}  Table:       ${TABLE_NAME}${NC}"
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo ""

# Create S3 bucket for state
echo -e "${BLUE}Creating S3 state bucket...${NC}"
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo -e "${YELLOW}  ℹ️  Bucket already exists: $BUCKET_NAME${NC}"
else
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$REGION" \
        --create-bucket-configuration LocationConstraint="$REGION" \
        --output text > /dev/null
    echo -e "${GREEN}  ✓ Created bucket: $BUCKET_NAME${NC}"
fi

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled
echo -e "${GREEN}  ✓ Enabled versioning${NC}"

# Enable server-side encryption
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            },
            "BucketKeyEnabled": true
        }]
    }'
echo -e "${GREEN}  ✓ Enabled SSE-S3 encryption${NC}"

# Block public access
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
echo -e "${GREEN}  ✓ Blocked public access${NC}"

# Create DynamoDB lock table
echo ""
echo -e "${BLUE}Creating DynamoDB lock table...${NC}"
if aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$REGION" 2>/dev/null; then
    echo -e "${YELLOW}  ℹ️  Table already exists: $TABLE_NAME${NC}"
else
    aws dynamodb create-table \
        --table-name "$TABLE_NAME" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "$REGION" \
        --output text > /dev/null
    echo -e "${GREEN}  ✓ Created DynamoDB table: $TABLE_NAME${NC}"
fi

# Generate backend.tfvars
BACKEND_FILE="$(dirname "$0")/../../environments/${ENVIRONMENT}/backend.tfvars"
cat > "$BACKEND_FILE" <<EOF
bucket         = "${BUCKET_NAME}"
key            = "amatra-isb/${ENVIRONMENT}/terraform.tfstate"
region         = "${REGION}"
dynamodb_table = "${TABLE_NAME}"
encrypt        = true
EOF

echo ""
echo -e "${GREEN}✅ Backend setup complete!${NC}"
echo -e "${CYAN}Generated: ${BACKEND_FILE}${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  cd environments/${ENVIRONMENT}"
echo -e "  terraform init -backend-config=backend.tfvars"
