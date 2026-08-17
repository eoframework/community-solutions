#!/usr/bin/env bash
#------------------------------------------------------------------------------
# AWS Multi-Account Landing Zone — Deployment Script (Linux/Mac)
# Usage: ./eo-deploy.sh <init|plan|apply|destroy|validate|fmt|output|state> [args]
#------------------------------------------------------------------------------

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENT=$(basename "$SCRIPT_DIR")

echo -e "${BLUE}🚀 ${ENVIRONMENT^^} Environment — AWS Landing Zone Terraform Wrapper${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Environment : ${YELLOW}${ENVIRONMENT}${NC}"
echo -e "${CYAN}  Directory   : ${YELLOW}${SCRIPT_DIR}${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"

build_var_files() {
  VAR_FILES=""
  if [ -d "config" ]; then
    echo -e "${YELLOW}📋 Loading configuration files:${NC}"
    for file in config/*.tfvars; do
      if [ -f "$file" ]; then
        VAR_FILES="$VAR_FILES -var-file=$file"
        echo -e "   ${GREEN}✓ $file${NC}"
      fi
    done
    echo ""
  else
    echo -e "${YELLOW}⚠  No config/ directory found — tfvars must be provided manually${NC}"
  fi
}

COMMAND="${1:-help}"
shift 2>/dev/null || true

case $COMMAND in
  "init")
    echo -e "${BLUE}🔧 Initialising Terraform...${NC}"
    if [ -f "backend.tfvars" ]; then
      terraform init -backend-config=backend.tfvars "$@"
    else
      echo -e "${YELLOW}⚠  backend.tfvars not found — running init without backend config${NC}"
      echo -e "${YELLOW}   Run setup/backend/state-backend.sh ${ENVIRONMENT} to create the backend${NC}"
      terraform init -backend=false "$@"
    fi
    ;;
  "plan")
    build_var_files
    echo -e "${BLUE}📐 Planning Terraform changes...${NC}"
    terraform plan $VAR_FILES "$@"
    ;;
  "apply")
    build_var_files
    echo -e "${BLUE}🏗  Applying Terraform changes...${NC}"
    terraform apply $VAR_FILES "$@"
    ;;
  "destroy")
    build_var_files
    echo -e "${RED}⚠️  DESTROY: This will remove all ${ENVIRONMENT} infrastructure!${NC}"
    read -p "Type 'yes' to confirm: " CONFIRM
    if [ "$CONFIRM" = "yes" ]; then
      terraform destroy $VAR_FILES "$@"
    else
      echo -e "${YELLOW}Destroy cancelled.${NC}"
      exit 1
    fi
    ;;
  "validate")
    echo -e "${BLUE}✅ Validating Terraform configuration...${NC}"
    terraform validate "$@"
    ;;
  "fmt")
    echo -e "${BLUE}🎨 Formatting Terraform files...${NC}"
    terraform fmt -recursive "$@"
    ;;
  "output")
    terraform output "$@"
    ;;
  "state")
    terraform state "$@"
    ;;
  "help"|*)
    echo -e "${CYAN}Usage: $0 <command> [terraform-args]${NC}"
    echo ""
    echo -e "${CYAN}Commands:${NC}"
    echo -e "  ${GREEN}init${NC}      Initialise Terraform (uses backend.tfvars if present)"
    echo -e "  ${GREEN}plan${NC}      Plan infrastructure changes (auto-loads config/*.tfvars)"
    echo -e "  ${GREEN}apply${NC}     Apply infrastructure changes (auto-loads config/*.tfvars)"
    echo -e "  ${GREEN}destroy${NC}   Destroy infrastructure (requires confirmation)"
    echo -e "  ${GREEN}validate${NC}  Validate Terraform configuration"
    echo -e "  ${GREEN}fmt${NC}       Format Terraform files"
    echo -e "  ${GREEN}output${NC}    Display outputs"
    echo -e "  ${GREEN}state${NC}     Manage Terraform state"
    echo ""
    echo -e "${YELLOW}Setup:${NC}"
    echo -e "  1. Run: ../../setup/backend/state-backend.sh ${ENVIRONMENT}"
    echo -e "  2. Run: ./eo-deploy.sh init"
    echo -e "  3. Run: ./eo-deploy.sh plan"
    echo -e "  4. Run: ./eo-deploy.sh apply"
    exit 0
    ;;
esac

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Command '${COMMAND}' completed successfully!${NC}"
