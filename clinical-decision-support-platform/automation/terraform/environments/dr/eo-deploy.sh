#!/usr/bin/env bash
# MedCore CDS Platform — DR Environment Deployment Wrapper

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENT="$(basename "$SCRIPT_DIR")"

echo -e "${BLUE}🚀 MedCore CDS Platform — DR Environment (us-west-2 passive standby)${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

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

case "$COMMAND" in
  "init")
    [ -f "backend.tfvars" ] && terraform init -backend-config=backend.tfvars "$@" || terraform init "$@" ;;
  "plan")
    echo -e "${YELLOW}📋 Loading configuration files:${NC}"; build_var_files; terraform plan $VAR_FILES "$@" ;;
  "apply")
    echo -e "${YELLOW}📋 Loading configuration files:${NC}"; build_var_files; terraform apply $VAR_FILES "$@" ;;
  "destroy")
    echo -e "${RED}⚠️  Destroying DR environment — ensure prod is healthy first${NC}"; build_var_files; terraform destroy $VAR_FILES "$@" ;;
  "validate") terraform validate "$@" ;;
  "fmt")      terraform fmt -recursive "$@" ;;
  "output")   terraform output "$@" ;;
  "state")    terraform state "$@" ;;
  *)          echo "Usage: $0 <init|plan|apply|destroy|validate|fmt|output|state>"; exit 1 ;;
esac

echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Done!${NC}"
