#!/usr/bin/env bash
# ANP Streaming AI - Smoke Test Script
# Executes representative API calls against the deployed environment.
# Usage: ./smoke-test.sh <prod|test|dr> <api-base-url> <api-key>

set -euo pipefail

ENVIRONMENT="${1:-prod}"
BASE_URL="${2}"
API_KEY="${3}"

if [ -z "${BASE_URL}" ] || [ -z "${API_KEY}" ]; then
  echo "Usage: $0 <environment> <api-base-url> <api-key>"
  echo "Example: $0 prod https://abc123.execute-api.us-east-1.amazonaws.com/v1 myapikey123"
  exit 1
fi

echo "🧪 ANP Streaming AI Smoke Tests — ${ENVIRONMENT}"
echo "   Base URL: ${BASE_URL}"
echo ""

PASS=0
FAIL=0

run_test() {
  local name="$1"
  local expected_status="$2"
  local actual_status="$3"

  if [ "${actual_status}" = "${expected_status}" ]; then
    echo "  ✅ ${name} → HTTP ${actual_status}"
    PASS=$((PASS + 1))
  else
    echo "  ❌ ${name} → Expected HTTP ${expected_status}, got HTTP ${actual_status}"
    FAIL=$((FAIL + 1))
  fi
}

# Test 1: POST /classify with valid API key
STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST "${BASE_URL}/classify" \
  -H "x-api-key: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"text": "Blessed is the one who trusts in the Lord", "content_type": "song"}' \
  --max-time 30)
run_test "POST /classify (valid)" "200" "${STATUS}"

# Test 2: POST /classify without API key → expect 403
STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST "${BASE_URL}/classify" \
  -H "Content-Type: application/json" \
  -d '{"text": "test"}' \
  --max-time 10)
run_test "POST /classify (no API key)" "403" "${STATUS}"

# Test 3: GET /recommend without JWT → expect 401
STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  -X GET "${BASE_URL}/recommend?mood=Peaceful" \
  --max-time 10)
run_test "GET /recommend (no JWT)" "401" "${STATUS}"

# Test 4: POST /classify empty body → expect 400 or 500
STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST "${BASE_URL}/classify" \
  -H "x-api-key: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{}' \
  --max-time 30)
run_test "POST /classify (empty body)" "400" "${STATUS}" || \
  run_test "POST /classify (empty body - Lambda error)" "500" "${STATUS}"

echo ""
echo "════════════════════════════════════════"
echo "Smoke Test Results: ${PASS} passed / ${FAIL} failed"
[ "${FAIL}" -eq 0 ] && echo "✅ All smoke tests passed!" || echo "⚠️  Some tests failed — review before go-live"
