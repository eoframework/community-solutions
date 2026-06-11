#!/usr/bin/env bash
# =============================================================================
# setup-backend.sh — Create S3 + DynamoDB Terraform state backend
# Usage: ./setup-backend.sh <environment> <region>
# =============================================================================
set -euo pipefail

ENVIRONMENT="${1:-}"
REGION="${2:-us-west-2}"

if [[ -z "${ENVIRONMENT}" ]]; then
  echo "Usage: $0 <environment> [region]"
  echo "  Environments: prod | test | dr"
  exit 1
fi

SOLUTION="amatra-intelligent-solution-builder"
STATE_BUCKET="amatra-terraform-state-${ENVIRONMENT}"
LOCK_TABLE="amatra-terraform-lock-${ENVIRONMENT}"

echo "Creating Terraform state backend for: ${ENVIRONMENT}"
echo "  Region:       ${REGION}"
echo "  State Bucket: ${STATE_BUCKET}"
echo "  Lock Table:   ${LOCK_TABLE}"
echo ""

# Create S3 bucket
if aws s3api head-bucket --bucket "${STATE_BUCKET}" --region "${REGION}" 2>/dev/null; then
  echo "✓ S3 bucket already exists: ${STATE_BUCKET}"
else
  aws s3api create-bucket \
    --bucket "${STATE_BUCKET}" \
    --region "${REGION}" \
    --create-bucket-configuration LocationConstraint="${REGION}" 2>/dev/null || \
  aws s3api create-bucket --bucket "${STATE_BUCKET}" --region "${REGION}"
  echo "✓ Created S3 bucket: ${STATE_BUCKET}"
fi

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket "${STATE_BUCKET}" \
  --versioning-configuration Status=Enabled
echo "✓ Enabled S3 versioning"

# Block public access
aws s3api put-public-access-block \
  --bucket "${STATE_BUCKET}" \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
echo "✓ Blocked public access"

# Enable server-side encryption
aws s3api put-bucket-encryption \
  --bucket "${STATE_BUCKET}" \
  --server-side-encryption-configuration '{
    "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
  }'
echo "✓ Enabled SSE-AES256"

# Create DynamoDB lock table
if aws dynamodb describe-table --table-name "${LOCK_TABLE}" --region "${REGION}" 2>/dev/null; then
  echo "✓ DynamoDB lock table already exists: ${LOCK_TABLE}"
else
  aws dynamodb create-table \
    --table-name "${LOCK_TABLE}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "${REGION}"
  echo "✓ Created DynamoDB lock table: ${LOCK_TABLE}"
fi

# Write backend.tfvars
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_ROOT="$(cd "${SCRIPT_DIR}/../terraform" && pwd)"
BACKEND_FILE="${TF_ROOT}/environments/${ENVIRONMENT}/backend.tfvars"

cat > "${BACKEND_FILE}" <<EOF
bucket         = "${STATE_BUCKET}"
key            = "env/${ENVIRONMENT}/terraform.tfstate"
region         = "${REGION}"
dynamodb_table = "${LOCK_TABLE}"
encrypt        = true
EOF

echo ""
echo "✓ Written backend config: ${BACKEND_FILE}"
echo ""
echo "Next: cd terraform/environments/${ENVIRONMENT} && terraform init -backend-config=backend.tfvars"
