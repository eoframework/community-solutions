#!/usr/bin/env bash
#------------------------------------------------------------------------------
# AWS Multi-Account Landing Zone — Deploy Script
# Orchestrates deployment across landing zone environments in the correct order
# Usage: ./deploy.sh <prod|test|dr> <plan|apply|destroy> [--auto-approve]
#------------------------------------------------------------------------------

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_ROOT="${SCRIPT_DIR}/../automation/terraform"

ENVIRONMENT="${1:-}"
COMMAND="${2:-plan}"
AUTO_APPROVE="${3:-}"

if [ -z "$ENVIRONMENT" ]; then
  echo -e "${RED}Error: environment required${NC}"
  echo "Usage: $0 <prod|test|dr> <plan|apply|destroy> [--auto-approve]"
  exit 1
fi

ENV_DIR="${TF_ROOT}/environments/${ENVIRONMENT}"
if [ ! -d "$ENV_DIR" ]; then
  echo -e "${RED}Error: environment directory not found: ${ENV_DIR}${NC}"
  exit 1
fi

echo -e "${BLUE}🚀 AWS Landing Zone — ${ENVIRONMENT^^} ${COMMAND^^}${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"

cd "$ENV_DIR"

# Build var files
VAR_FILES=""
if [ -d "config" ]; then
  for file in config/*.tfvars; do
    [ -f "$file" ] && VAR_FILES="$VAR_FILES -var-file=$file"
  done
fi

# Check for backend config
BACKEND_ARGS=""
[ -f "backend.tfvars" ] && BACKEND_ARGS="-backend-config=backend.tfvars"

case $COMMAND in
  "init")
    terraform init $BACKEND_ARGS
    ;;
  "plan")
    terraform init $BACKEND_ARGS -input=false
    terraform plan $VAR_FILES -out=tfplan
    echo -e "${GREEN}✅ Plan saved to tfplan${NC}"
    ;;
  "apply")
    if [ "$AUTO_APPROVE" = "--auto-approve" ]; then
      terraform init $BACKEND_ARGS -input=false
      terraform apply $VAR_FILES -auto-approve
    else
      terraform init $BACKEND_ARGS -input=false
      terraform apply $VAR_FILES
    fi
    ;;
  "destroy")
    echo -e "${RED}⚠️  DESTROY will remove all ${ENVIRONMENT} infrastructure!${NC}"
    terraform init $BACKEND_ARGS -input=false
    terraform destroy $VAR_FILES $AUTO_APPROVE
    ;;
  *)
    echo -e "${RED}Error: unknown command ${COMMAND}${NC}"
    echo "Supported: init, plan, apply, destroy"
    exit 1
    ;;
esac

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ ${COMMAND^^} completed for ${ENVIRONMENT}${NC}"
