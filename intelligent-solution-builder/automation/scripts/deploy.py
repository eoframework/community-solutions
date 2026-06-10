#!/usr/bin/env python3
"""
Amatra ISB — Deploy Script
Wraps terraform plan/apply with environment-specific safety checks.

Usage:
    python deploy.py --env prod --action plan
    python deploy.py --env test --action apply
    python deploy.py --env dr --action plan
"""

import subprocess
import sys
import os
import argparse
from pathlib import Path


def run_terraform(env: str, action: str, auto_approve: bool = False) -> int:
    """Run terraform command for the specified environment."""
    terraform_root = Path(__file__).parent.parent / "automation" / "terraform"
    env_dir = terraform_root / "environments" / env

    if not env_dir.exists():
        print(f"ERROR: Environment directory not found: {env_dir}")
        return 1

    # Build var-file arguments from config/*.tfvars
    config_dir = env_dir / "config"
    var_files = []
    if config_dir.exists():
        for tfvars in sorted(config_dir.glob("*.tfvars")):
            var_files.append(f"-var-file={tfvars}")

    cmd = ["terraform", action] + var_files
    if auto_approve and action in ["apply", "destroy"]:
        cmd.append("-auto-approve")

    print(f"Running: {' '.join(cmd)}")
    print(f"Working directory: {env_dir}")
    print()

    result = subprocess.run(cmd, cwd=str(env_dir))
    return result.returncode


def main():
    parser = argparse.ArgumentParser(description="Deploy Amatra ISB infrastructure")
    parser.add_argument("--env", required=True, choices=["prod", "test", "dr"])
    parser.add_argument(
        "--action",
        required=True,
        choices=["init", "plan", "apply", "destroy", "validate", "output"],
    )
    parser.add_argument(
        "--auto-approve",
        action="store_true",
        help="Skip confirmation prompt (use with caution for prod)",
    )
    args = parser.parse_args()

    # Production guard
    if args.env == "prod" and args.action in ["apply", "destroy"]:
        if not args.auto_approve:
            print(f"WARNING: You are about to {args.action} PRODUCTION infrastructure!")
            confirm = input("Type 'yes' to confirm: ")
            if confirm.strip().lower() != "yes":
                print("Deployment cancelled.")
                sys.exit(1)

    rc = run_terraform(args.env, args.action, args.auto_approve)
    sys.exit(rc)


if __name__ == "__main__":
    main()
