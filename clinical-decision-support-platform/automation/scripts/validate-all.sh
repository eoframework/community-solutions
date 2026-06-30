#!/usr/bin/env bash
# =============================================================================
# MedCore CDS Platform — Terraform Validation Script
# Validates all three environments (prod, test, dr) without a backend.
# Usage: ./validate-all.sh
# =============================================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_ROOT="$(dirname "$SCRIPT_DIR")/terraform"

PASS=0
FAIL=0

validate_env() {
  local env="$1"
  local env_dir="${TERRAFORM_ROOT}/environments/${env}"

  echo -e "${BLUE}Validating: ${env}${NC}"

  if [ ! -d "$env_dir" ]; then
    echo -e "  ${RED}✗ Directory not found: $env_dir${NC}"
    FAIL=$((FAIL + 1))
    return
  fi

  pushd "$env_dir" > /dev/null

  # Check required files
  for f in main.tf variables.tf outputs.tf providers.tf; do
    if [ -f "$f" ]; then
      echo -e "  ${GREEN}✓ $f${NC}"
    else
      echo -e "  ${RED}✗ Missing: $f${NC}"
      FAIL=$((FAIL + 1))
    fi
  done

  # terraform init + validate
  echo -e "  ${YELLOW}→ terraform init -backend=false${NC}"
  if terraform init -backend=false -no-color > /tmp/tf-init-${env}.log 2>&1; then
    echo -e "  ${GREEN}✓ init passed${NC}"
  else
    echo -e "  ${RED}✗ init failed (see /tmp/tf-init-${env}.log)${NC}"
    cat /tmp/tf-init-${env}.log
    FAIL=$((FAIL + 1))
    popd > /dev/null
    return
  fi

  echo -e "  ${YELLOW}→ terraform validate${NC}"
  if terraform validate -no-color > /tmp/tf-validate-${env}.log 2>&1; then
    echo -e "  ${GREEN}✓ validate passed${NC}"
    PASS=$((PASS + 1))
  else
    echo -e "  ${RED}✗ validate failed${NC}"
    cat /tmp/tf-validate-${env}.log
    FAIL=$((FAIL + 1))
  fi

  popd > /dev/null
  echo ""
}

echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}MedCore CDS Platform — Terraform Validation${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

for env in prod test dr; do
  validate_env "$env"
done

echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "Results: ${GREEN}${PASS} passed${NC} | ${RED}${FAIL} failed${NC}"

if [ "$FAIL" -gt 0 ]; then
  echo -e "${RED}❌ Validation FAILED${NC}"
  exit 1
else
  echo -e "${GREEN}✅ All validations PASSED${NC}"
fi
