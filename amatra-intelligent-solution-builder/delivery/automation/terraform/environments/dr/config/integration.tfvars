#------------------------------------------------------------------------------
# Integration Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-05 16:27:28
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

integration = {
  # Timeout for GitHub API commit calls in seconds
  github_commit_timeout_seconds = 30
  # Default branch for automated artifact commits
  github_default_branch = "main"
  # SECRET (GitHub Personal Access Token for automated artifact commits): inject via Secrets Manager / SSM at deploy time
  github_pat = "SET_VIA_SECRETS_MANAGER"
  # Public GitHub repository URL for artifact commit and versioning
  github_repository_url = "[github-repo-url]"  # TODO: Replace with actual value
}
