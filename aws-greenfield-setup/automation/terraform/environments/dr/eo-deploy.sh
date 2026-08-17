#!/usr/bin/env bash
#------------------------------------------------------------------------------
# AWS Multi-Account Landing Zone — DR Deployment Script (Linux/Mac)
#------------------------------------------------------------------------------

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENT=$(basename "$SCRIPT_DIR")

echo -e "${BLUE}🚀 ${ENVIRONMENT^^} Environment — AWS Landing Zone Terraform Wrapper${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"

build_var_files() {
  VAR_FILES=""
  if [ -d "config" ]; then
    echo -e "${YELLOW}📋 Loading configuration files:${NC}"
    for file in config/*.tfvars; do
      [ -f "$file" ] && VAR_FILES="$VAR_FILES -var-file=$file" && echo -e "   ${GREEN}✓ $file${NC}"
    done
    echo ""
  fi
}

COMMAND="${1:-help}"; shift 2>/dev/null || true

case $COMMAND in
  "init")
    [ -f "backend.tfvars" ] && terraform init -backend-config=backend.tfvars "$@" || terraform init -backend=false "$@" ;;
  "plan")    build_var_files; terraform plan $VAR_FILES "$@" ;;
  "apply")   build_var_files; terraform apply $VAR_FILES "$@" ;;
  "destroy") build_var_files; terraform destroy $VAR_FILES "$@" ;;
  "validate") terraform validate "$@" ;;
  "fmt")     terraform fmt -recursive "$@" ;;
  "output")  terraform output "$@" ;;
  "state")   terraform state "$@" ;;
  *) echo -e "${CYAN}Usage: $0 <init|plan|apply|destroy|validate|fmt|output|state>${NC}"; exit 0 ;;
esac

echo -e "${GREEN}✅ Command '${COMMAND}' completed successfully!${NC}"
