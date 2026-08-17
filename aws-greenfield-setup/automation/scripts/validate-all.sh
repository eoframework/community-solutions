#!/usr/bin/env bash
#------------------------------------------------------------------------------
# AWS Multi-Account Landing Zone — Validate All Environments
# Runs terraform validate for prod, test, and dr environments
# Usage: ./validate-all.sh
#------------------------------------------------------------------------------

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_ROOT="${SCRIPT_DIR}/../automation/terraform"

ENVS=("prod" "test" "dr")
PASS=0
FAIL=0

echo -e "${BLUE}🔍 Validating all Landing Zone Terraform environments${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"

for ENV in "${ENVS[@]}"; do
  ENV_DIR="${TF_ROOT}/environments/${ENV}"
  echo -e "${YELLOW}Validating: ${ENV}${NC}"
  cd "$ENV_DIR"
  terraform init -backend=false -input=false > /dev/null 2>&1
  if terraform validate; then
    echo -e "${GREEN}  ✅ ${ENV} — PASSED${NC}"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}  ❌ ${ENV} — FAILED${NC}"
    FAIL=$((FAIL + 1))
  fi
  cd - > /dev/null
done

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Passed: ${PASS}${NC} | ${RED}Failed: ${FAIL}${NC}"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
