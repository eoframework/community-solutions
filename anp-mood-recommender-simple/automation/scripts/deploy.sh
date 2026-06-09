#!/usr/bin/env bash
# ANP Streaming AI - Deployment Helper Script
# Validates then deploys a specified environment.
# Usage: ./deploy.sh <prod|test|dr> [plan|apply|destroy]

set -euo pipefail

ENVIRONMENT="${1:-prod}"
ACTION="${2:-plan}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="${SCRIPT_DIR}/../terraform/environments/${ENVIRONMENT}"

echo "🚀 ANP Streaming AI — Deploying ${ENVIRONMENT} (${ACTION})"
echo ""

if [ ! -d "${TF_DIR}" ]; then
  echo "❌ Environment directory not found: ${TF_DIR}"
  exit 1
fi

cd "${TF_DIR}"

# Build var-file args
VAR_FILES=""
for f in config/*.tfvars; do
  [ -f "$f" ] && VAR_FILES="${VAR_FILES} -var-file=${f}"
done

case "${ACTION}" in
  "plan")
    terraform init -backend=false
    terraform validate
    echo "✅ Validation passed."
    terraform plan ${VAR_FILES}
    ;;
  "apply")
    terraform plan ${VAR_FILES} -out=tfplan
    terraform apply tfplan
    rm -f tfplan
    ;;
  "destroy")
    terraform destroy ${VAR_FILES}
    ;;
  *)
    echo "Usage: $0 <prod|test|dr> <plan|apply|destroy>"
    exit 1
    ;;
esac
