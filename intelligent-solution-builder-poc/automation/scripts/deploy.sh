#!/usr/bin/env bash
# =============================================================================
# deploy.sh — Amatra Intelligent Solution Builder
# Terraform deployment wrapper for Linux/macOS
# Usage: ./deploy.sh <environment> <command> [extra terraform args]
# =============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_ROOT="$(cd "${SCRIPT_DIR}/../terraform" && pwd)"

ENVIRONMENT="${1:-}"
COMMAND="${2:-help}"
shift 2 2>/dev/null || true

usage() {
  echo -e "${CYAN}Usage: $0 <environment> <command> [extra args]${NC}"
  echo -e ""
  echo -e "  Environments: prod | test | dr"
  echo -e "  Commands:     init | plan | apply | destroy | validate | fmt | output | state"
  echo -e ""
  echo -e "  Examples:"
  echo -e "    $0 prod init"
  echo -e "    $0 prod plan"
  echo -e "    $0 prod apply"
  echo -e "    $0 test plan -target=module.networking"
  exit 1
}

[[ -z "${ENVIRONMENT}" ]] && usage

ENV_DIR="${TF_ROOT}/environments/${ENVIRONMENT}"
if [[ ! -d "${ENV_DIR}" ]]; then
  echo -e "${RED}ERROR: Environment directory not found: ${ENV_DIR}${NC}"
  exit 1
fi

cd "${ENV_DIR}"

build_var_files() {
  VAR_FILES=""
  if [[ -d "config" ]]; then
    for file in config/*.tfvars; do
      [[ -f "${file}" ]] && VAR_FILES="${VAR_FILES} -var-file=${file}" \
        && echo -e "${GREEN}   ✓ ${file}${NC}"
    done
  fi
}

BACKEND_CONFIG=""
[[ -f "backend.tfvars" ]] && BACKEND_CONFIG="-backend-config=backend.tfvars"

echo -e "${BLUE}🚀 Amatra ISB — ${ENVIRONMENT} Environment${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"

case "${COMMAND}" in
  "init")
    terraform init ${BACKEND_CONFIG} "$@"
    ;;
  "plan")
    echo -e "${YELLOW}📋 Loading configuration files:${NC}"
    build_var_files
    echo ""
    terraform plan ${VAR_FILES} "$@"
    ;;
  "apply")
    echo -e "${YELLOW}📋 Loading configuration files:${NC}"
    build_var_files
    echo ""
    terraform apply ${VAR_FILES} "$@"
    ;;
  "destroy")
    echo -e "${RED}⚠️  Destroying ${ENVIRONMENT} infrastructure — are you sure? (yes/no)${NC}"
    read -r CONFIRM
    if [[ "${CONFIRM}" != "yes" ]]; then
      echo "Aborted."
      exit 0
    fi
    build_var_files
    terraform destroy ${VAR_FILES} "$@"
    ;;
  "validate")
    terraform init -backend=false -reconfigure 2>/dev/null || terraform init -backend=false
    terraform validate "$@"
    ;;
  "fmt")
    terraform fmt -recursive "${TF_ROOT}" "$@"
    ;;
  "output")
    terraform output "$@"
    ;;
  "state")
    terraform state "$@"
    ;;
  "help"|*)
    usage
    ;;
esac

echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Command '${COMMAND}' completed for ${ENVIRONMENT}${NC}"
