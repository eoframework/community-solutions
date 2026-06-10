#!/bin/bash
# Amatra ISB — Production Environment Terraform Deployment Script
# Discovers and loads all config/*.tfvars files automatically
# Usage: ./eo-deploy.sh <init|plan|apply|destroy|validate|fmt|output>

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENT=$(basename "$SCRIPT_DIR")

echo -e "${BLUE}🚀 Amatra ISB — ${ENVIRONMENT^} Environment Deployment${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Solution:     Amatra Intelligent Solution Builder${NC}"
echo -e "${CYAN}  Environment:  ${ENVIRONMENT}${NC}"
echo -e "${CYAN}  Region:       us-west-2${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""

build_var_files() {
    VAR_FILES=""
    if [ -d "config" ]; then
        echo -e "${YELLOW}📋 Loading configuration files:${NC}"
        for file in config/*.tfvars; do
            if [ -f "$file" ]; then
                VAR_FILES="$VAR_FILES -var-file=$file"
                echo -e "${GREEN}   ✓ $file${NC}"
            fi
        done
        echo ""
    fi
}

COMMAND="${1:-help}"
shift 2>/dev/null || true

case $COMMAND in
    "init")
        echo -e "${BLUE}🔧 Initializing Terraform backend...${NC}"
        if [ -f "backend.tfvars" ]; then
            terraform init -backend-config=backend.tfvars "$@"
        else
            echo -e "${YELLOW}⚠️  No backend.tfvars found. Run setup/backend/state-backend.sh first.${NC}"
            terraform init -backend=false "$@"
        fi
        ;;
    "plan")
        build_var_files
        echo -e "${BLUE}📐 Planning infrastructure changes...${NC}"
        terraform plan $VAR_FILES "$@"
        ;;
    "apply")
        build_var_files
        echo -e "${BLUE}🏗️  Applying infrastructure changes...${NC}"
        if [ "$ENVIRONMENT" = "prod" ]; then
            echo -e "${RED}⚠️  Production deployment — manual approval required!${NC}"
            read -p "Type 'yes' to confirm production deployment: " confirm
            if [ "$confirm" != "yes" ]; then
                echo -e "${RED}❌ Deployment cancelled${NC}"
                exit 1
            fi
        fi
        terraform apply $VAR_FILES "$@"
        ;;
    "destroy")
        build_var_files
        echo -e "${RED}🔥 DESTROYING ${ENVIRONMENT} infrastructure...${NC}"
        echo -e "${RED}⚠️  This action is irreversible!${NC}"
        terraform destroy $VAR_FILES "$@"
        ;;
    "validate")
        echo -e "${BLUE}✅ Validating Terraform configuration...${NC}"
        terraform validate "$@"
        ;;
    "fmt")
        echo -e "${BLUE}🎨 Formatting Terraform files...${NC}"
        terraform fmt "$@"
        ;;
    "output")
        terraform output "$@"
        ;;
    "state")
        terraform state "$@"
        ;;
    "help"|*)
        echo -e "${CYAN}Usage: $0 <command> [options]${NC}"
        echo ""
        echo -e "${CYAN}Commands:${NC}"
        echo -e "  ${GREEN}init${NC}      Initialize Terraform backend"
        echo -e "  ${GREEN}plan${NC}      Plan infrastructure changes"
        echo -e "  ${GREEN}apply${NC}     Apply infrastructure changes"
        echo -e "  ${GREEN}destroy${NC}   Destroy infrastructure"
        echo -e "  ${GREEN}validate${NC}  Validate Terraform configuration"
        echo -e "  ${GREEN}fmt${NC}       Format Terraform files"
        echo -e "  ${GREEN}output${NC}    Show Terraform outputs"
        echo -e "  ${GREEN}state${NC}     Manage Terraform state"
        echo ""
        echo -e "${YELLOW}Quick Start:${NC}"
        echo -e "  1. cd setup/backend && ./state-backend.sh ${ENVIRONMENT}"
        echo -e "  2. ./eo-deploy.sh init"
        echo -e "  3. ./eo-deploy.sh plan"
        echo -e "  4. ./eo-deploy.sh apply"
        exit 0
        ;;
esac

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Command completed successfully!${NC}"
