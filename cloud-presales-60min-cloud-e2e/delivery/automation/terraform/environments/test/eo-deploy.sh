#!/bin/bash
# Amatra Agentic Orchestration Platform
# Deployment wrapper script — Linux/Mac
# Usage: ./eo-deploy.sh <init|plan|apply|destroy|validate|fmt|output|state> [extra args]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENT=$(basename "$SCRIPT_DIR")

echo -e "${BLUE}🚀 Amatra — ${ENVIRONMENT^} Environment — Terraform Wrapper${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Region: us-west-2 | Opportunity: OPP-2026-001${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

build_var_files() {
  VAR_FILES=""
  if [ -d "$SCRIPT_DIR/config" ]; then
    echo -e "${YELLOW}📋 Loading configuration files:${NC}"
    for file in "$SCRIPT_DIR/config"/*.tfvars; do
      if [ -f "$file" ]; then
        VAR_FILES="$VAR_FILES -var-file=$file"
        echo -e "${GREEN}   ✓ $(basename "$file")${NC}"
      fi
    done
    echo ""
  fi
}

COMMAND="${1:-help}"
shift 2>/dev/null || true

case $COMMAND in
  "init")
    if [ -f "$SCRIPT_DIR/backend.tfvars" ]; then
      terraform init -backend-config="$SCRIPT_DIR/backend.tfvars" "$@"
    else
      terraform init -backend=false "$@"
    fi
    ;;
  "plan")
    build_var_files
    # shellcheck disable=SC2086
    terraform plan $VAR_FILES "$@"
    ;;
  "apply")
    build_var_files
    # shellcheck disable=SC2086
    terraform apply $VAR_FILES "$@"
    ;;
  "destroy")
    build_var_files
    echo -e "${RED}⚠️  Destroying $ENVIRONMENT infrastructure...${NC}"
    # shellcheck disable=SC2086
    terraform destroy $VAR_FILES "$@"
    ;;
  "validate")
    terraform init -backend=false
    terraform validate "$@"
    ;;
  "fmt")
    terraform fmt -recursive "$@"
    ;;
  "output")
    terraform output "$@"
    ;;
  "state")
    terraform state "$@"
    ;;
  *)
    echo -e "${CYAN}Usage: $0 <init|plan|apply|destroy|validate|fmt|output|state>${NC}"
    exit 1
    ;;
esac

echo -e "${GREEN}✅ Done!${NC}"
