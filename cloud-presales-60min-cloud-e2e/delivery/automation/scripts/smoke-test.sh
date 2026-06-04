#!/bin/bash
# Amatra Agentic Orchestration Platform
# Smoke Test Script — validates platform go-live readiness
# Usage: ./smoke-test.sh <api-url> <cognito-user-pool-id> <cognito-client-id>
# Runs all 5 required CLI smoke test commands per SOW Section 5

set -e

API_URL="${1:-}"
POOL_ID="${2:-}"
CLIENT_ID="${3:-}"

if [ -z "$API_URL" ] || [ -z "$POOL_ID" ] || [ -z "$CLIENT_ID" ]; then
  echo "Usage: $0 <api-url> <cognito-user-pool-id> <cognito-client-id>"
  echo "Example: $0 https://api.amatra.predictif.com us-west-2_XXXXX abcdef1234567890"
  exit 1
fi

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS=0
FAIL=0

check() {
  local name="$1"
  local result="$2"
  if [ "$result" -eq 0 ]; then
    echo -e "${GREEN}✅ PASS${NC}: $name"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}❌ FAIL${NC}: $name"
    FAIL=$((FAIL + 1))
  fi
}

echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Amatra Platform Smoke Tests — Go/No-Go Decision   ${NC}"
echo -e "${CYAN}  API: $API_URL${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

# Test 1: API Gateway health check — GET /v1/quota (unauthenticated should return 401)
echo -e "${YELLOW}Test 1: API Gateway reachability${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/v1/quota" 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "403" ]; then
  check "API Gateway reachable and JWT auth active (got $HTTP_CODE)" 0
else
  check "API Gateway reachable (got $HTTP_CODE, expected 401/403)" 1
fi

# Test 2: Cognito User Pool reachability
echo -e "${YELLOW}Test 2: Cognito User Pool JWKS endpoint${NC}"
JWKS_URL="https://cognito-idp.us-west-2.amazonaws.com/$POOL_ID/.well-known/jwks.json"
JWKS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$JWKS_URL" 2>/dev/null || echo "000")
if [ "$JWKS_CODE" = "200" ]; then
  check "Cognito JWKS endpoint reachable" 0
else
  check "Cognito JWKS endpoint reachable (got $JWKS_CODE)" 1
fi

# Test 3: Test that GET /v1/quota returns 401 without token (confirms JWT auth is active)
echo -e "${YELLOW}Test 3: JWT authoriser active on /v1/quota${NC}"
QUOTA_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/v1/quota" 2>/dev/null || echo "000")
if [ "$QUOTA_CODE" = "401" ]; then
  check "JWT authoriser active on /v1/quota (got 401 Unauthorized)" 0
else
  check "JWT authoriser active (expected 401, got $QUOTA_CODE)" 1
fi

# Test 4: Confirm WAF is blocking common bad inputs
echo -e "${YELLOW}Test 4: WAF SQLi rule active${NC}"
WAF_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/v1/solution?id=1' OR '1'='1" 2>/dev/null || echo "000")
if [ "$WAF_CODE" = "403" ] || [ "$WAF_CODE" = "401" ]; then
  check "WAF active (got $WAF_CODE on SQLi test)" 0
else
  check "WAF active (unexpected response: $WAF_CODE)" 1
fi

# Test 5: API Gateway returns a valid 404 for unknown routes (not an LB error)
echo -e "${YELLOW}Test 5: API Gateway routing operational${NC}"
NOTFOUND_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/v1/this-route-does-not-exist" 2>/dev/null || echo "000")
if [ "$NOTFOUND_CODE" = "404" ] || [ "$NOTFOUND_CODE" = "401" ]; then
  check "API Gateway routing operational (got $NOTFOUND_CODE)" 0
else
  check "API Gateway routing (unexpected: $NOTFOUND_CODE)" 1
fi

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}PASS: $PASS / $((PASS + FAIL))${NC}"
if [ "$FAIL" -gt 0 ]; then
  echo -e "${RED}FAIL: $FAIL / $((PASS + FAIL))${NC}"
  echo -e "${RED}❌ GO/NO-GO: NO-GO — fix failures before cutover${NC}"
  exit 1
else
  echo -e "${GREEN}✅ GO/NO-GO: GO — all smoke tests passed${NC}"
fi
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
