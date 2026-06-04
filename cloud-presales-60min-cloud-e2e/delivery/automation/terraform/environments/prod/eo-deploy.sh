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
  else
    echo -e "${YELLOW}⚠️  No config/ directory found — running without tfvars${NC}"
  fi
}

COMMAND="${1:-help}"
shift 2>/dev/null || true

case $COMMAND in
  "init")
    echo -e "${BLUE}🔧 Initializing Terraform...${NC}"
    if [ -f "$SCRIPT_DIR/backend.tfvars" ]; then
      terraform init -backend-config="$SCRIPT_DIR/backend.tfvars" "$@"
    else
      echo -e "${YELLOW}⚠️  No backend.tfvars found — run setup/backend/state-backend.sh first${NC}"
      terraform init -backend=false "$@"
    fi
    ;;
  "plan")
    build_var_files
    echo -e "${BLUE}📋 Running terraform plan...${NC}"
    # shellcheck disable=SC2086
    terraform plan $VAR_FILES "$@"
    ;;
  "apply")
    build_var_files
    echo -e "${BLUE}🚀 Running terraform apply...${NC}"
    # shellcheck disable=SC2086
    terraform apply $VAR_FILES "$@"
    ;;
  "destroy")
    build_var_files
    echo -e "${RED}⚠️  Destroying $ENVIRONMENT infrastructure...${NC}"
    read -rp "Type 'yes' to confirm destruction of $ENVIRONMENT: " confirm
    if [ "$confirm" = "yes" ]; then
      # shellcheck disable=SC2086
      terraform destroy $VAR_FILES "$@"
    else
      echo -e "${YELLOW}Destruction cancelled.${NC}"
      exit 0
    fi
    ;;
  "validate")
    echo -e "${BLUE}✅ Validating Terraform configuration...${NC}"
    terraform init -backend=false
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
    echo -e "${CYAN}Usage: $0 <command> [terraform options]${NC}"
    echo ""
    echo -e "${CYAN}Commands:${NC}"
    echo -e "  ${GREEN}init${NC}      Initialize Terraform (uses backend.tfvars if present)"
    echo -e "  ${GREEN}plan${NC}      Plan changes (loads all config/*.tfvars)"
    echo -e "  ${GREEN}apply${NC}     Apply changes (loads all config/*.tfvars)"
    echo -e "  ${GREEN}destroy${NC}   Destroy infrastructure (with confirmation)"
    echo -e "  ${GREEN}validate${NC}  Validate configuration syntax"
    echo -e "  ${GREEN}fmt${NC}       Format Terraform files"
    echo -e "  ${GREEN}output${NC}    Show Terraform outputs"
    echo -e "  ${GREEN}state${NC}     Manage Terraform state"
    exit 0
    ;;
esac

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Command '$COMMAND' completed successfully!${NC}"
