#!/usr/bin/env python3
"""
Amatra ISB — Terraform Validation Script
Runs terraform init + validate across all environments.

Usage:
    python validate.py
    python validate.py --env prod
    python validate.py --fix-fmt
"""

import subprocess
import sys
import os
import argparse
from pathlib import Path

RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
BLUE = "\033[0;34m"
CYAN = "\033[0;36m"
NC = "\033[0m"


def run_cmd(cmd: list[str], cwd: str) -> tuple[int, str, str]:
    """Run a shell command, return (returncode, stdout, stderr)."""
    result = subprocess.run(
        cmd, cwd=cwd, capture_output=True, text=True
    )
    return result.returncode, result.stdout, result.stderr


def validate_environment(env_dir: Path) -> bool:
    """Run terraform init + validate for one environment directory."""
    env_name = env_dir.name
    print(f"{BLUE}─── Validating {env_name} ───{NC}")

    # terraform init (no backend)
    rc, stdout, stderr = run_cmd(
        ["terraform", "init", "-backend=false", "-no-color"], str(env_dir)
    )
    if rc != 0:
        print(f"{RED}  ✗ terraform init failed:{NC}\n{stderr}")
        return False
    print(f"{GREEN}  ✓ terraform init passed{NC}")

    # terraform validate
    rc, stdout, stderr = run_cmd(
        ["terraform", "validate", "-no-color"], str(env_dir)
    )
    if rc != 0:
        print(f"{RED}  ✗ terraform validate failed:{NC}\n{stdout}\n{stderr}")
        return False
    print(f"{GREEN}  ✓ terraform validate passed{NC}")

    return True


def check_no_tfvars(terraform_root: Path) -> bool:
    """Ensure no .tfvars files exist (orchestrator generates these)."""
    tfvars_files = list(terraform_root.rglob("*.tfvars"))
    if tfvars_files:
        print(f"{RED}  ✗ Found .tfvars files (should not exist in repo):{NC}")
        for f in tfvars_files:
            print(f"    {f}")
        return False
    print(f"{GREEN}  ✓ No .tfvars files found (correct){NC}")
    return True


def check_no_hardcoded_secrets(terraform_root: Path) -> list[str]:
    """Scan for hardcoded secrets patterns."""
    issues = []
    secret_patterns = [
        "aws_access_key_id",
        "aws_secret_access_key",
        "AKIA",
        "password =",
        "token =",
        "secret =",
    ]

    for tf_file in terraform_root.rglob("*.tf"):
        content = tf_file.read_text()
        for pattern in secret_patterns:
            if pattern in content.lower():
                # Ignore variable declarations and descriptions
                for line in content.splitlines():
                    if pattern in line.lower() and not any(
                        x in line for x in ["variable", "description", "#", "//"]
                    ):
                        issues.append(f"{tf_file}: potential secret pattern '{pattern}'")
    return issues


def main():
    parser = argparse.ArgumentParser(description="Validate Amatra ISB Terraform")
    parser.add_argument("--env", choices=["prod", "test", "dr"], help="Validate single environment")
    parser.add_argument("--fix-fmt", action="store_true", help="Auto-format Terraform files")
    args = parser.parse_args()

    # Locate terraform root
    script_dir = Path(__file__).parent.parent
    terraform_root = script_dir / "automation" / "terraform"

    if not terraform_root.exists():
        # Try relative from CWD
        terraform_root = Path.cwd()

    print(f"{CYAN}{'═' * 55}{NC}")
    print(f"{BLUE}  Amatra ISB — Terraform Validation{NC}")
    print(f"{CYAN}{'═' * 55}{NC}")
    print(f"  Root: {terraform_root}")
    print(f"{CYAN}{'═' * 55}{NC}")
    print()

    all_passed = True

    # Check no .tfvars
    print(f"{BLUE}Checking for .tfvars files...{NC}")
    if not check_no_tfvars(terraform_root):
        all_passed = False
    print()

    # Check no hardcoded secrets
    print(f"{BLUE}Scanning for hardcoded secrets...{NC}")
    issues = check_no_hardcoded_secrets(terraform_root)
    if issues:
        print(f"{YELLOW}  ⚠ Potential issues found:{NC}")
        for issue in issues:
            print(f"    {YELLOW}{issue}{NC}")
    else:
        print(f"{GREEN}  ✓ No hardcoded secrets detected{NC}")
    print()

    # Validate environments
    envs_dir = terraform_root / "environments"
    if args.env:
        env_dirs = [envs_dir / args.env]
    else:
        env_dirs = sorted(envs_dir.iterdir()) if envs_dir.exists() else []

    for env_dir in env_dirs:
        if env_dir.is_dir():
            if not validate_environment(env_dir):
                all_passed = False
            print()

    print(f"{CYAN}{'═' * 55}{NC}")
    if all_passed:
        print(f"{GREEN}✅ All validations passed!{NC}")
        sys.exit(0)
    else:
        print(f"{RED}❌ Validation failed — see errors above{NC}")
        sys.exit(1)


if __name__ == "__main__":
    main()
