#!/bin/bash
# EO Framework — Terraform Validate All Environments
# Runs terraform init -backend=false && terraform validate for prod, test, and dr
# Usage: ./validate-all.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_ROOT="${SCRIPT_DIR}/../terraform"
ENVS=("prod" "test" "dr")
PASS_COUNT=0
FAIL_COUNT=0

echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  EO Framework — Terraform Validate All Environments ${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"

for env in "${ENVS[@]}"; do
  ENV_DIR="${TF_ROOT}/environments/${env}"
  echo -e "\n${YELLOW}▶ Validating environment: ${env}${NC}"

  if [[ ! -d "${ENV_DIR}" ]]; then
    echo -e "${RED}  ✗ Directory not found: ${ENV_DIR}${NC}"
    ((FAIL_COUNT++))
    continue
  fi

  cd "${ENV_DIR}"

  if terraform init -backend=false -input=false -no-color > /tmp/tf_init_${env}.log 2>&1; then
    echo -e "${GREEN}  ✓ init -backend=false${NC}"
  else
    echo -e "${RED}  ✗ init failed:${NC}"
    cat /tmp/tf_init_${env}.log
    ((FAIL_COUNT++))
    continue
  fi

  if terraform validate -no-color > /tmp/tf_validate_${env}.log 2>&1; then
    echo -e "${GREEN}  ✓ validate passed${NC}"
    ((PASS_COUNT++))
  else
    echo -e "${RED}  ✗ validate failed:${NC}"
    cat /tmp/tf_validate_${env}.log
    ((FAIL_COUNT++))
  fi
done

echo -e "\n${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "Results: ${GREEN}${PASS_COUNT} passed${NC} | ${RED}${FAIL_COUNT} failed${NC}"

if [[ ${FAIL_COUNT} -gt 0 ]]; then
  echo -e "${RED}❌ Validation FAILED${NC}"
  exit 1
else
  echo -e "${GREEN}✅ All environments validated successfully!${NC}"
  exit 0
fi
