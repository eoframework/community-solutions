#!/bin/bash
# ANP Streaming AI Recommendation Engine — Deployment Script
# Usage: ./deploy.sh <environment> <command> [options]
# Example: ./deploy.sh prod plan
#          ./deploy.sh prod apply
#          ./deploy.sh test destroy

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/../automation/terraform"

usage() {
  echo -e "${CYAN}Usage: $0 <environment> <command> [options]${NC}"
  echo -e "${CYAN}Environments: prod | test | dr${NC}"
  echo -e "${CYAN}Commands:     init | plan | apply | destroy | validate | output${NC}"
  echo ""
  echo -e "${YELLOW}Examples:${NC}"
  echo "  $0 prod init"
  echo "  $0 prod plan"
  echo "  $0 prod apply"
  echo "  $0 test plan"
  echo "  $0 dr plan"
  exit 1
}

if [ $# -lt 2 ]; then
  usage
fi

ENVIRONMENT="$1"
COMMAND="$2"
shift 2

# Validate environment
case "${ENVIRONMENT}" in
  prod|test|dr) ;;
  *)
    echo -e "${RED}ERROR: Invalid environment '${ENVIRONMENT}'. Use: prod | test | dr${NC}"
    exit 1
    ;;
esac

ENV_DIR="${TERRAFORM_DIR}/environments/${ENVIRONMENT}"

if [ ! -d "${ENV_DIR}" ]; then
  echo -e "${RED}ERROR: Environment directory not found: ${ENV_DIR}${NC}"
  exit 1
fi

echo -e "${BLUE}==================================================================${NC}"
echo -e "${BLUE}  ANP Streaming AI Recommendation Engine — Terraform Deployment${NC}"
echo -e "${BLUE}  Environment: ${YELLOW}${ENVIRONMENT}${BLUE}  |  Command: ${YELLOW}${COMMAND}${NC}"
echo -e "${BLUE}==================================================================${NC}"
echo ""

cd "${ENV_DIR}"

# Collect all tfvars files
build_var_files() {
  VAR_FILES=""
  if [ -d "config" ]; then
    echo -e "${YELLOW}Loading configuration files:${NC}"
    for file in config/*.tfvars; do
      if [ -f "$file" ]; then
        VAR_FILES="${VAR_FILES} -var-file=${file}"
        echo -e "  ${GREEN}✓ ${file}${NC}"
      fi
    done
    echo ""
  else
    echo -e "${YELLOW}WARNING: config/ directory not found. Using defaults only.${NC}"
  fi
}

case "${COMMAND}" in
  "init")
    echo -e "${CYAN}Initializing Terraform backend...${NC}"
    if [ -f "backend.tfvars" ]; then
      terraform init -backend-config=backend.tfvars "$@"
    else
      echo -e "${YELLOW}No backend.tfvars found. Run setup/backend/state-backend.sh first.${NC}"
      echo -e "${YELLOW}Initializing without backend...${NC}"
      terraform init -backend=false "$@"
    fi
    ;;
  "plan")
    build_var_files
    echo -e "${CYAN}Planning Terraform changes...${NC}"
    terraform plan ${VAR_FILES} "$@"
    ;;
  "apply")
    build_var_files
    echo -e "${YELLOW}Applying Terraform changes to ${ENVIRONMENT} environment...${NC}"
    if [ "${ENVIRONMENT}" = "prod" ]; then
      echo -e "${RED}WARNING: You are about to modify PRODUCTION infrastructure.${NC}"
      read -p "Type 'yes' to confirm: " confirm
      if [ "${confirm}" != "yes" ]; then
        echo -e "${RED}Aborted.${NC}"
        exit 1
      fi
    fi
    terraform apply ${VAR_FILES} "$@"
    ;;
  "destroy")
    build_var_files
    echo -e "${RED}DESTROYING ${ENVIRONMENT} infrastructure...${NC}"
    read -p "Type 'destroy' to confirm: " confirm
    if [ "${confirm}" != "destroy" ]; then
      echo -e "${RED}Aborted.${NC}"
      exit 1
    fi
    terraform destroy ${VAR_FILES} "$@"
    ;;
  "validate")
    echo -e "${CYAN}Validating Terraform configuration...${NC}"
    terraform validate "$@"
    ;;
  "fmt")
    echo -e "${CYAN}Formatting Terraform files...${NC}"
    terraform fmt -recursive "$@"
    ;;
  "output")
    echo -e "${CYAN}Terraform outputs for ${ENVIRONMENT}:${NC}"
    terraform output "$@"
    ;;
  "state")
    terraform state "$@"
    ;;
  *)
    echo -e "${RED}Unknown command: ${COMMAND}${NC}"
    usage
    ;;
esac

echo ""
echo -e "${BLUE}==================================================================${NC}"
echo -e "${GREEN}✅ Command '${COMMAND}' completed successfully for ${ENVIRONMENT}!${NC}"
echo -e "${BLUE}==================================================================${NC}"
