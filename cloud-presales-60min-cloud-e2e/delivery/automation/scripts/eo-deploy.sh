#!/bin/bash
# Production Environment - Terraform Deployment Script
# Discovers and loads all config/*.tfvars files automatically

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENT=$(basename "$SCRIPT_DIR")

echo -e "${BLUE}🚀 ${ENVIRONMENT^} Environment - Amatra Agentic Orchestration Platform${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"

build_var_files() {
    VAR_FILES=""
    if [ -d "config" ]; then
        for file in config/*.tfvars; do
            [ -f "$file" ] && VAR_FILES="$VAR_FILES -var-file=$file" \
              && echo -e "${GREEN}   ✓ $file${NC}"
        done
    fi
    echo ""
}

COMMAND="${1:-help}"
shift 2>/dev/null || true

case $COMMAND in
    "init")
        echo -e "${YELLOW}🔧 Initialising Terraform...${NC}"
        terraform init "$@"
        ;;
    "init-backend")
        echo -e "${YELLOW}🔧 Initialising with backend config...${NC}"
        terraform init -backend-config=backend.tfvars "$@"
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
    "help"|*)
        echo -e "${CYAN}Usage: $0 <init|init-backend|plan|apply|destroy|validate|fmt|output|state>${NC}"
        echo ""
        echo -e "  init           - Initialize without backend"
        echo -e "  init-backend   - Initialize with backend.tfvars"
        echo -e "  plan           - Plan with all config/*.tfvars"
        echo -e "  apply          - Apply with all config/*.tfvars"
        echo -e "  destroy        - Destroy with all config/*.tfvars"
        echo -e "  validate       - Validate configuration"
        echo -e "  fmt            - Format code"
        echo -e "  output         - Show outputs"
        echo -e "  state          - State management"
        exit 0
        ;;
esac

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Command completed successfully!${NC}"
