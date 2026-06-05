#------------------------------------------------------------------------------
# Security Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-05 16:27:28
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

cognito = {
  access_token_ttl_hours = 1  # JWT access token expiry in hours
  # Cognito App Client ID for CLI and API authentication flows
  app_client_id = "[cognito-app-client-id]"  # TODO: Replace with actual value
  # SECRET (Cognito App Client secret for server-side auth flows): inject via Secrets Manager / SSM at deploy time
  app_client_secret = "SET_VIA_SECRETS_MANAGER"
  mfa_enabled = false  # MFA enforcement in Cognito User Pool
  # JWT refresh token TTL in days per SOW authentication spec
  token_refresh_ttl_days = 30
  # Cognito User Pool ID used by JWT authoriser
  user_pool_id = "[cognito-user-pool-id]"  # TODO: Replace with actual value
  # Cognito User Pool name for platform authentication
  user_pool_name = "amatra-prod-user-pool"
}

secrets = {
  # Secrets Manager secret name holding the Cognito App Client secret
  manager_cognito_secret_name = "amatra/prod/cognito-app-client-secret"
  # Secrets Manager secret name holding the GitHub PAT
  manager_github_pat_secret_name = "amatra/prod/github-pat"
}

security = {
  # Enable CloudTrail data events for S3 and DynamoDB
  cloudtrail_enabled = true
  # CloudTrail log retention in dedicated S3 bucket with Object Lock
  cloudtrail_retention_days = 365
  # Enable SSE-KMS encryption at rest for all data stores
  enable_encryption_at_rest = true
  # Enable AWS GuardDuty threat detection in the account
  guardduty_enabled = true
  # IAM permission boundary ARN applied to developer and CI/CD roles
  iam_permission_boundary_arn = "[iam-permission-boundary-arn]"  # TODO: Replace with actual value
  # SECRET (Customer-managed KMS key ID for SSE-KMS on S3 and CloudWatch Logs): inject via Secrets Manager / SSM at deploy time
  kms_key_id = "SET_VIA_SECRETS_MANAGER"
  # Minimum TLS version for all data in transit
  tls_minimum_version = "TLS1.2"
}
