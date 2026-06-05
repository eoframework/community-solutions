#!/bin/bash
# ============================================================================
# Amatra Agentic Pre-Sales Platform — Deployment Helper Script
# Usage: ./deploy.sh <environment> <command> [extra terraform flags]
# Examples:
#   ./deploy.sh prod plan
#   ./deploy.sh test apply -auto-approve
#   ./deploy.sh dr validate
# ============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_ROOT="$(cd "${SCRIPT_DIR}/../automation/terraform" && pwd)"

usage() {
  echo -e "${CYAN}Usage: $0 <environment> <command> [extra terraform flags]${NC}"
  echo ""
  echo "  environment: prod | test | dr"
  echo "  command:     init | plan | apply | destroy | validate | fmt | output"
  echo ""
  echo "Examples:"
  echo "  $0 prod validate"
  echo "  $0 prod plan"
  echo "  $0 test apply -auto-approve"
  echo "  $0 dr output"
  exit 1
}

[[ $# -lt 2 ]] && usage

ENVIRONMENT="${1}"
COMMAND="${2}"
shift 2
EXTRA_ARGS=("$@")

# Validate environment
case "${ENVIRONMENT}" in
  prod|test|dr) ;;
  *) echo -e "${RED}ERROR: Invalid environment '${ENVIRONMENT}'. Must be prod, test, or dr.${NC}"; exit 1 ;;
esac

ENV_DIR="${TF_ROOT}/environments/${ENVIRONMENT}"

[[ ! -d "${ENV_DIR}" ]] && {
  echo -e "${RED}ERROR: Environment directory not found: ${ENV_DIR}${NC}"
  exit 1
}

cd "${ENV_DIR}"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Amatra Pre-Sales Platform — ${ENVIRONMENT^^} Environment${NC}"
echo -e "${CYAN}  Command: ${COMMAND}${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Build var-file arguments from config/*.tfvars
build_var_files() {
  local VAR_FILES=""
  if [[ -d "config" ]]; then
    for file in config/*.tfvars; do
      [[ -f "${file}" ]] && VAR_FILES="${VAR_FILES} -var-file=${file}" && \
        echo -e "${GREEN}  ✓ ${file}${NC}"
    done
  fi
  echo "${VAR_FILES}"
}

case "${COMMAND}" in
  init)
    echo -e "${YELLOW}🔧 Initialising Terraform (backend=false for validation)...${NC}"
    terraform init -backend=false "${EXTRA_ARGS[@]}"
    ;;
  validate)
    echo -e "${YELLOW}🔍 Validating Terraform configuration...${NC}"
    terraform init -backend=false -upgrade=false
    terraform validate "${EXTRA_ARGS[@]}"
    echo -e "${GREEN}✅ Validation passed for ${ENVIRONMENT}!${NC}"
    ;;
  plan)
    echo -e "${YELLOW}📋 Loading configuration files:${NC}"
    VAR_FILES="$(build_var_files)"
    echo ""
    echo -e "${YELLOW}📝 Running terraform plan...${NC}"
    # shellcheck disable=SC2086
    terraform plan ${VAR_FILES} "${EXTRA_ARGS[@]}"
    ;;
  apply)
    echo -e "${YELLOW}📋 Loading configuration files:${NC}"
    VAR_FILES="$(build_var_files)"
    echo ""
    echo -e "${YELLOW}🚀 Applying Terraform configuration...${NC}"
    # shellcheck disable=SC2086
    terraform apply ${VAR_FILES} "${EXTRA_ARGS[@]}"
    ;;
  destroy)
    echo -e "${RED}⚠️  WARNING: Destroying ${ENVIRONMENT} infrastructure...${NC}"
    echo -e "${RED}    This action is irreversible. Press Ctrl+C to cancel.${NC}"
    echo -e "${YELLOW}📋 Loading configuration files:${NC}"
    VAR_FILES="$(build_var_files)"
    echo ""
    # shellcheck disable=SC2086
    terraform destroy ${VAR_FILES} "${EXTRA_ARGS[@]}"
    ;;
  fmt)
    echo -e "${YELLOW}✍️  Formatting Terraform files...${NC}"
    terraform fmt "${EXTRA_ARGS[@]}"
    ;;
  output)
    echo -e "${YELLOW}📤 Fetching Terraform outputs...${NC}"
    terraform output "${EXTRA_ARGS[@]}"
    ;;
  state)
    terraform state "${EXTRA_ARGS[@]}"
    ;;
  *)
    echo -e "${RED}ERROR: Unknown command '${COMMAND}'${NC}"
    usage
    ;;
esac

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Command '${COMMAND}' completed for ${ENVIRONMENT}!${NC}"
