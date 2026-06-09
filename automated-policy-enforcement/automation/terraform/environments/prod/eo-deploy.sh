#!/usr/bin/env bash
#------------------------------------------------------------------------------
# AWS Cloud Governance Platform — Production Deployment Wrapper
# Usage: ./eo-deploy.sh <init|plan|apply|destroy|validate|fmt|output|state>
#------------------------------------------------------------------------------

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENT=$(basename "$SCRIPT_DIR")

echo -e "${BLUE}🚀 ${ENVIRONMENT^^} Environment — AWS Cloud Governance Platform${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

build_var_files() {
  VAR_FILES=""
  if [ -d "config" ]; then
    for file in config/*.tfvars; do
      [ -f "$file" ] && VAR_FILES="$VAR_FILES -var-file=$file" && echo -e "${GREEN}   ✓ $file${NC}"
    done
  fi
  echo ""
}

COMMAND="${1:-help}"
shift 2>/dev/null || true

case $COMMAND in
  "init")
    echo -e "${YELLOW}⚙️  Initialising Terraform backend...${NC}"
    terraform init "$@"
    ;;
  "plan")
    echo -e "${YELLOW}📋 Loading configuration files:${NC}"
    build_var_files
    terraform plan $VAR_FILES "$@"
    ;;
  "apply")
    echo -e "${YELLOW}📋 Loading configuration files:${NC}"
    build_var_files
    terraform apply $VAR_FILES "$@"
    ;;
  "destroy")
    echo -e "${RED}⚠️  Destroying ${ENVIRONMENT} infrastructure...${NC}"
    echo -e "${RED}   This will destroy the governance platform. Confirm carefully.${NC}"
    build_var_files
    terraform destroy $VAR_FILES "$@"
    ;;
  "validate")
    terraform validate "$@"
    ;;
  "fmt")
    terraform fmt "$@"
    ;;
  "output")
    terraform output "$@"
    ;;
  "state")
    terraform state "$@"
    ;;
  *)
    echo -e "${CYAN}Usage: $0 <init|plan|apply|destroy|validate|fmt|output|state>${NC}"
    echo -e "${CYAN}  init      — initialise backend (requires backend.tfvars)${NC}"
    echo -e "${CYAN}  plan      — plan changes with all config/*.tfvars files${NC}"
    echo -e "${CYAN}  apply     — apply changes with all config/*.tfvars files${NC}"
    echo -e "${CYAN}  destroy   — destroy infrastructure (use with extreme caution)${NC}"
    echo -e "${CYAN}  validate  — validate Terraform configuration${NC}"
    echo -e "${CYAN}  fmt       — format Terraform files${NC}"
    exit 1
    ;;
esac

echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Command completed successfully!${NC}"
