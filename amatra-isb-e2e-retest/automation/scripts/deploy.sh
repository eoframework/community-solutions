#!/bin/bash
# EO Framework — Deployment Helper Script
# Usage: ./deploy.sh <env> <command> [terraform-args...]
# Example: ./deploy.sh prod plan
#          ./deploy.sh test apply -auto-approve
#          ./deploy.sh dr validate

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_ROOT="${SCRIPT_DIR}/../terraform"

usage() {
  echo -e "${CYAN}Usage: $0 <env> <command> [terraform-args...]${NC}"
  echo -e "  env:     prod | test | dr"
  echo -e "  command: init | plan | apply | destroy | validate | fmt | output"
  exit 1
}

[[ $# -lt 2 ]] && usage

ENV="${1}"
COMMAND="${2}"
shift 2

valid_envs=("prod" "test" "dr")
if [[ ! " ${valid_envs[*]} " =~ " ${ENV} " ]]; then
  echo -e "${RED}Invalid environment: ${ENV}${NC}"
  usage
fi

ENV_DIR="${TF_ROOT}/environments/${ENV}"
if [[ ! -d "${ENV_DIR}" ]]; then
  echo -e "${RED}Environment directory not found: ${ENV_DIR}${NC}"
  exit 1
fi

echo -e "${BLUE}🚀 EO Framework — ${ENV} Environment${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"

cd "${ENV_DIR}"

build_var_files() {
  local var_files=""
  if [[ -d "config" ]]; then
    for f in config/*.tfvars; do
      [[ -f "$f" ]] && var_files="${var_files} -var-file=${f}"
    done
  fi
  echo "${var_files}"
}

case "${COMMAND}" in
  "init")
    echo -e "${YELLOW}⚙️  Initializing Terraform (no backend)...${NC}"
    terraform init -backend=false "$@"
    ;;
  "init-remote")
    echo -e "${YELLOW}⚙️  Initializing with remote backend...${NC}"
    if [[ -f "backend.tfvars" ]]; then
      terraform init -backend-config=backend.tfvars "$@"
    else
      echo -e "${RED}backend.tfvars not found. Run setup/backend/state-backend.sh ${ENV} first.${NC}"
      exit 1
    fi
    ;;
  "validate")
    echo -e "${YELLOW}✅ Validating configuration...${NC}"
    terraform init -backend=false -input=false
    terraform validate "$@"
    ;;
  "fmt")
    echo -e "${YELLOW}🎨 Formatting Terraform files...${NC}"
    terraform fmt -recursive "${TF_ROOT}" "$@"
    ;;
  "plan")
    VAR_FILES=$(build_var_files)
    echo -e "${YELLOW}📋 Planning deployment (${ENV})...${NC}"
    # shellcheck disable=SC2086
    terraform plan ${VAR_FILES} "$@"
    ;;
  "apply")
    VAR_FILES=$(build_var_files)
    echo -e "${YELLOW}🚢 Applying deployment (${ENV})...${NC}"
    # shellcheck disable=SC2086
    terraform apply ${VAR_FILES} "$@"
    ;;
  "destroy")
    VAR_FILES=$(build_var_files)
    echo -e "${RED}⚠️  DESTROYING ${ENV} infrastructure...${NC}"
    read -r -p "Are you sure? Type YES to confirm: " CONFIRM
    [[ "${CONFIRM}" == "YES" ]] || { echo "Aborted."; exit 1; }
    # shellcheck disable=SC2086
    terraform destroy ${VAR_FILES} "$@"
    ;;
  "output")
    terraform output "$@"
    ;;
  *)
    echo -e "${RED}Unknown command: ${COMMAND}${NC}"
    usage
    ;;
esac

echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ ${COMMAND} completed successfully!${NC}"
