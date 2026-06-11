#!/usr/bin/env bash
# =============================================================================
# validate.sh — Validate all Terraform environments (no backend required)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_ROOT="$(cd "${SCRIPT_DIR}/../terraform" && pwd)"

GREEN='\033[0;32m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'

PASS=0
FAIL=0

for env in prod test dr; do
  ENV_DIR="${TF_ROOT}/environments/${env}"
  echo -e "${CYAN}--- Validating: ${env} ---${NC}"

  pushd "${ENV_DIR}" >/dev/null
    terraform init -backend=false -reconfigure -input=false -no-color 2>&1 | tail -5
    if terraform validate -no-color; then
      echo -e "${GREEN}✅ ${env}: PASSED${NC}"
      PASS=$((PASS + 1))
    else
      echo -e "${RED}❌ ${env}: FAILED${NC}"
      FAIL=$((FAIL + 1))
    fi
  popd >/dev/null
  echo ""
done

echo -e "${CYAN}════════════════════════════════${NC}"
echo -e "${GREEN}Passed: ${PASS}${NC}  ${RED}Failed: ${FAIL}${NC}"

[[ "${FAIL}" -eq 0 ]] && exit 0 || exit 1
