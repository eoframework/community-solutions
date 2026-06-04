#------------------------------------------------------------------------------
# Security Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-04 19:28:42
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

security = {
  # Enable AWS CloudTrail for all management and data-plane API calls in us-west-2
  cloudtrail_enabled = true
  # S3 bucket for CloudTrail log delivery with SSE and MFA delete enabled
  cloudtrail_s3_bucket_name = "amatra-dev-s3-cloudtrail-logs-[aws-account-id]"
  # Cognito JWT access token validity period in seconds (1 hour)
  cognito_access_token_expiry_seconds = 3600
  # Cognito User Pool App Client ID used by CLI for USER_PASSWORD_AUTH token exchange
  cognito_app_client_id = "[cognito-app-client-id]"  # TODO: Replace with actual value
  # SECRET (Cognito App Client secret used by CLI PKCE exchange; stored in Secrets Manager): inject via Secrets Manager / SSM at deploy time
  cognito_app_client_secret = "SET_VIA_SECRETS_MANAGER"
  # Cognito User Pool group name for platform administrators including Daniel Park's team
  cognito_group_admins = "admin"
  # Cognito User Pool group name for standard consultant users
  cognito_group_consultants = "consultants"
  # Whether Cognito TOTP MFA is enforced as mandatory for all users
  cognito_mfa_enabled = false
  # Cognito refresh token validity period in days as committed in SOW
  cognito_refresh_token_expiry_days = 30
  # Cognito User Pool ID (format: us-west-2_XXXXXXXXX) used by API Gateway JWT authoriser and CLI auth flow
  cognito_user_pool_id = "[cognito-user-pool-id]"  # TODO: Replace with actual value
  # Cognito User Pool name; CTO sign-off required on this configuration before Phase 1 production deployment
  cognito_user_pool_name = "amatra-dev-cognito-userpool"
  # Policy control — no Lambda execution role may use wildcard resource ARNs in IAM policies
  iam_wildcard_resource_arns_allowed = false
  # AWS Secrets Manager secret name for the GitHub Personal Access Token
  secrets_github_pat_secret_name = "amatra/dev/github/pat"
  # SECRET (GitHub Personal Access Token value stored exclusively in Secrets Manager; placeholder only): inject via Secrets Manager / SSM at deploy time
  secrets_github_pat_value = "SET_VIA_SECRETS_MANAGER"
  # Enable AWS Managed Rules Common Rule Set (SQLi + XSS + known bad inputs) on API Gateway WAF
  waf_managed_rules_enabled = true
  # AWS WAF IP-based rate limit in requests per IP per minute on the API Gateway stage
  waf_rate_limit_requests_per_ip_per_minute = 100
}
