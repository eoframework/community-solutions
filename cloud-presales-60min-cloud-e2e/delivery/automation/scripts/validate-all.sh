#!/bin/bash
# Amatra Agentic Orchestration Platform
# Terraform Validate All Environments — used in CI/CD gate
# Usage: ./validate-all.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_ROOT="$SCRIPT_DIR/../terraform"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS=0
FAIL=0

validate_env() {
  local env="$1"
  local env_dir="$TF_ROOT/environments/$env"

  if [ ! -d "$env_dir" ]; then
    echo -e "${RED}❌ MISSING${NC}: environments/$env not found"
    FAIL=$((FAIL + 1))
    return
  fi

  echo -e "${CYAN}Validating environments/$env ...${NC}"
  cd "$env_dir"

  if terraform init -backend=false -input=false -no-color > /dev/null 2>&1; then
    if terraform validate -no-color > /dev/null 2>&1; then
      echo -e "${GREEN}✅ PASS${NC}: environments/$env"
      PASS=$((PASS + 1))
    else
      echo -e "${RED}❌ FAIL${NC}: environments/$env — terraform validate error:"
      terraform validate
      FAIL=$((FAIL + 1))
    fi
  else
    echo -e "${RED}❌ FAIL${NC}: environments/$env — terraform init error"
    FAIL=$((FAIL + 1))
  fi

  cd "$SCRIPT_DIR"
}

echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Amatra Terraform Validation — All Environments   ${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"

validate_env "prod"
validate_env "test"
validate_env "dr"

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}"

if [ "$FAIL" -gt 0 ]; then
  echo -e "${RED}❌ Validation FAILED${NC}"
  exit 1
else
  echo -e "${GREEN}✅ All environments validated successfully${NC}"
fi
