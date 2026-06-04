#------------------------------------------------------------------------------
# Tier 1: AWS Secrets Manager — Platform secret definitions (no values stored)
# Secret VALUES are set by operations team; structure defined here for IAM scoping
#------------------------------------------------------------------------------

# GitHub PAT secret — retrieved by GitHub Integration Lambda at runtime
resource "aws_secretsmanager_secret" "github_pat" {
  name                    = var.github_pat_secret_name
  description             = "GitHub Personal Access Token for artifact commit pipeline. Value set by operations team — never committed to source control."
  recovery_window_in_days = 7
  tags                    = merge(var.common_tags, { SecretType = "github-pat" })
}
