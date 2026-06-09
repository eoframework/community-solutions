#!/usr/bin/env bash
#------------------------------------------------------------------------------
# AWS Cloud Governance Platform — Deployment Validation Script
# Validates all three environments (prod, test, dr) without a backend
# Usage: ./validate-all.sh
#------------------------------------------------------------------------------

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_ROOT="${SCRIPT_DIR}/../terraform"

echo -e "${BLUE}🔍 AWS Cloud Governance Platform — Terraform Validation${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

PASS=0
FAIL=0

validate_env() {
  local ENV="$1"
  local ENV_DIR="${TF_ROOT}/environments/${ENV}"

  echo -e "${YELLOW}Validating ${ENV} environment...${NC}"

  if [ ! -d "$ENV_DIR" ]; then
    echo -e "${RED}  ✗ Directory not found: ${ENV_DIR}${NC}"
    FAIL=$((FAIL + 1))
    return
  fi

  pushd "$ENV_DIR" > /dev/null

  # Check required files exist
  for FILE in main.tf variables.tf outputs.tf providers.tf; do
    if [ ! -f "$FILE" ]; then
      echo -e "${RED}  ✗ Missing required file: ${FILE}${NC}"
      FAIL=$((FAIL + 1))
      popd > /dev/null
      return
    fi
  done

  # Run terraform init (no backend) and validate
  if terraform init -backend=false -input=false -no-color 2>&1 | grep -q "Terraform initialized"; then
    echo -e "${GREEN}  ✓ terraform init passed${NC}"
  else
    terraform init -backend=false -input=false -no-color
    echo -e "${GREEN}  ✓ terraform init passed${NC}"
  fi

  if terraform validate -no-color 2>&1; then
    echo -e "${GREEN}  ✓ terraform validate passed${NC}"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}  ✗ terraform validate FAILED${NC}"
    FAIL=$((FAIL + 1))
  fi

  popd > /dev/null
  echo ""
}

validate_env "prod"
validate_env "test"
validate_env "dr"

echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Validation Summary:${NC}"
echo -e "  ${GREEN}Passed: ${PASS}${NC}"
echo -e "  ${RED}Failed: ${FAIL}${NC}"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo -e "${RED}❌ Validation FAILED — fix errors before deployment${NC}"
  exit 1
else
  echo -e "${GREEN}✅ All environments validated successfully${NC}"
fi
