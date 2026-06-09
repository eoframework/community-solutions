#!/usr/bin/env bash
# ANP Streaming AI - Terraform Deployment Wrapper (Linux/Mac) — Test Environment
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENT=$(basename "$SCRIPT_DIR")

echo -e "${BLUE}🚀 ANP Streaming AI — ${ENVIRONMENT^} Environment Terraform Wrapper${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"

build_var_files() {
  VAR_FILES=""
  if [ -d "${SCRIPT_DIR}/config" ]; then
    for file in "${SCRIPT_DIR}"/config/*.tfvars; do
      [ -f "$file" ] && VAR_FILES="$VAR_FILES -var-file=$file" && echo -e "${GREEN}   ✓ $file${NC}"
    done
  fi
  echo ""
}

COMMAND="${1:-help}"; shift 2>/dev/null || true

case $COMMAND in
  "init")    terraform init "$@" ;;
  "plan")    echo -e "${YELLOW}📋 Loading configuration files:${NC}"; build_var_files; terraform plan $VAR_FILES "$@" ;;
  "apply")   echo -e "${YELLOW}📋 Loading configuration files:${NC}"; build_var_files; terraform apply $VAR_FILES "$@" ;;
  "destroy") echo -e "${RED}⚠️  Destroying ${ENVIRONMENT} infrastructure...${NC}"; build_var_files; terraform destroy $VAR_FILES "$@" ;;
  "validate") terraform validate "$@" ;;
  "fmt")     terraform fmt "$@" ;;
  "output")  terraform output "$@" ;;
  "state")   terraform state "$@" ;;
  *)         echo -e "${CYAN}Usage: $0 <init|plan|apply|destroy|validate|fmt|output|state>${NC}"; exit 1 ;;
esac

echo -e "${GREEN}✅ Done!${NC}"
