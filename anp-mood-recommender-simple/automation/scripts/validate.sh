#!/usr/bin/env bash
# ANP Streaming AI - Validation Script
# Runs terraform validate for all three environments without needing tfvars.
# Usage: ./validate.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_BASE="${SCRIPT_DIR}/../terraform/environments"

PASSED=0
FAILED=0

for ENV in prod test dr; do
  TF_DIR="${TF_BASE}/${ENV}"
  echo "────────────────────────────────────────"
  echo "🔍 Validating: ${ENV}"
  cd "${TF_DIR}"
  terraform init -backend=false -upgrade=false -input=false > /dev/null 2>&1
  if terraform validate; then
    echo "✅ ${ENV}: PASSED"
    PASSED=$((PASSED + 1))
  else
    echo "❌ ${ENV}: FAILED"
    FAILED=$((FAILED + 1))
  fi
done

echo "════════════════════════════════════════"
echo "Results: ${PASSED} passed / ${FAILED} failed"
[ "${FAILED}" -eq 0 ] && echo "✅ All environments valid!" || exit 1
