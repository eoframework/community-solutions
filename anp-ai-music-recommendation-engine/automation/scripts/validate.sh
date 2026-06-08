#!/bin/bash
# ANP Streaming AI Recommendation Engine — Terraform Validation Script
# Runs terraform init -backend=false && terraform validate for all environments
# Usage: ./validate.sh [environment]  (or omit to validate all)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/../automation/terraform"

ENVIRONMENTS=("prod" "test" "dr")
TARGET_ENV="${1:-all}"

PASS=0
FAIL=0
FAILED_ENVS=()

validate_env() {
  local env="$1"
  local env_dir="${TERRAFORM_DIR}/environments/${env}"

  echo -e "${CYAN}──────────────────────────────────────────${NC}"
  echo -e "${CYAN}Validating environment: ${YELLOW}${env}${NC}"
  echo -e "${CYAN}──────────────────────────────────────────${NC}"

  if [ ! -d "${env_dir}" ]; then
    echo -e "${RED}ERROR: Directory not found: ${env_dir}${NC}"
    FAIL=$((FAIL + 1))
    FAILED_ENVS+=("${env}")
    return 1
  fi

  cd "${env_dir}"

  echo -e "  ${YELLOW}→ terraform init -backend=false${NC}"
  if terraform init -backend=false -upgrade=false 2>&1; then
    echo -e "  ${GREEN}✓ init passed${NC}"
  else
    echo -e "  ${RED}✗ init FAILED${NC}"
    FAIL=$((FAIL + 1))
    FAILED_ENVS+=("${env}")
    return 1
  fi

  echo -e "  ${YELLOW}→ terraform validate${NC}"
  if terraform validate 2>&1; then
    echo -e "  ${GREEN}✓ validate passed${NC}"
    PASS=$((PASS + 1))
  else
    echo -e "  ${RED}✗ validate FAILED${NC}"
    FAIL=$((FAIL + 1))
    FAILED_ENVS+=("${env}")
    return 1
  fi
}

echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}  ANP Streaming — Terraform Validation Runner${NC}"
echo -e "${CYAN}================================================${NC}"
echo ""

if [ "${TARGET_ENV}" = "all" ]; then
  for env in "${ENVIRONMENTS[@]}"; do
    validate_env "${env}" || true
  done
else
  validate_env "${TARGET_ENV}"
fi

echo ""
echo -e "${CYAN}================================================${NC}"
echo -e "${GREEN}  Passed: ${PASS}${NC}"
if [ "${FAIL}" -gt 0 ]; then
  echo -e "${RED}  Failed: ${FAIL} (${FAILED_ENVS[*]})${NC}"
  echo -e "${CYAN}================================================${NC}"
  exit 1
else
  echo -e "${GREEN}  Failed: 0${NC}"
  echo -e "${CYAN}================================================${NC}"
  echo -e "${GREEN}✅ All validations passed!${NC}"
fi
