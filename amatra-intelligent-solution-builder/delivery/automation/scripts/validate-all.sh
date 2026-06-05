#!/bin/bash
# ============================================================================
# Amatra Agentic Pre-Sales Platform — Terraform Validation Script
# Validates all three environments (prod, test, dr) without requiring backend
# Usage: ./validate-all.sh
# ============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_ROOT="$(cd "${SCRIPT_DIR}/../automation/terraform" && pwd)"

PASS=0
FAIL=0
FAILED_ENVS=()

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Amatra Pre-Sales Platform — Terraform Validate All Environments${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

for ENV in prod test dr; do
  ENV_DIR="${TF_ROOT}/environments/${ENV}"
  echo -e "${YELLOW}🔍 Validating environment: ${ENV}${NC}"

  if [[ ! -d "${ENV_DIR}" ]]; then
    echo -e "${RED}  ✗ Directory not found: ${ENV_DIR}${NC}"
    FAIL=$((FAIL + 1))
    FAILED_ENVS+=("${ENV}")
    continue
  fi

  cd "${ENV_DIR}"

  if terraform init -backend=false -upgrade=false -input=false 2>&1 | \
     grep -E "(error|Error)" > /dev/null 2>&1; then
    echo -e "${RED}  ✗ terraform init failed for ${ENV}${NC}"
    FAIL=$((FAIL + 1))
    FAILED_ENVS+=("${ENV}")
    continue
  fi

  if terraform validate 2>&1; then
    echo -e "${GREEN}  ✓ ${ENV} — PASSED${NC}"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}  ✗ ${ENV} — FAILED${NC}"
    FAIL=$((FAIL + 1))
    FAILED_ENVS+=("${ENV}")
  fi

  echo ""
done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Results: ${GREEN}${PASS} passed${NC} / ${RED}${FAIL} failed${NC}"

if [[ ${FAIL} -gt 0 ]]; then
  echo -e "${RED}Failed environments: ${FAILED_ENVS[*]}${NC}"
  exit 1
else
  echo -e "${GREEN}✅ All environments validated successfully!${NC}"
  exit 0
fi
