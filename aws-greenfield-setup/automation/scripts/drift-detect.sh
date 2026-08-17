#!/usr/bin/env bash
#------------------------------------------------------------------------------
# AWS Multi-Account Landing Zone — Drift Detection Script
# Compares current Terraform state against live AWS resources
# Usage: ./drift-detect.sh <prod|test|dr>
#------------------------------------------------------------------------------

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_ROOT="${SCRIPT_DIR}/../automation/terraform"

ENVIRONMENT="${1:-prod}"
ENV_DIR="${TF_ROOT}/environments/${ENVIRONMENT}"

if [ ! -d "$ENV_DIR" ]; then
  echo -e "${RED}Error: environment directory not found: ${ENV_DIR}${NC}"
  exit 1
fi

echo -e "${BLUE}🔍 Running drift detection for ${ENVIRONMENT}${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}This requires live AWS credentials and an initialised backend.${NC}"
echo ""

cd "$ENV_DIR"

# Build var files
VAR_FILES=""
if [ -d "config" ]; then
  for file in config/*.tfvars; do
    [ -f "$file" ] && VAR_FILES="$VAR_FILES -var-file=$file"
  done
fi

# Run a plan with -refresh-only flag to detect drift
if terraform plan $VAR_FILES -refresh-only -detailed-exitcode 2>&1; then
  echo -e "${GREEN}✅ No drift detected — infrastructure matches Terraform state${NC}"
else
  EXIT_CODE=$?
  if [ $EXIT_CODE -eq 2 ]; then
    echo -e "${YELLOW}⚠️  Drift detected — review the plan output above${NC}"
    echo -e "${YELLOW}   Run 'terraform apply -refresh-only' to update state${NC}"
  else
    echo -e "${RED}❌ Error during drift detection (exit code: ${EXIT_CODE})${NC}"
    exit 1
  fi
fi

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
