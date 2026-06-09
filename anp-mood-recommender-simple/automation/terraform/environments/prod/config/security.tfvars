#------------------------------------------------------------------------------
# Security Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-09 01:56:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

security = {
  # SECRET (Secrets Manager ARN storing the API Gateway API key for POST /classify): inject via Secrets Manager / SSM at deploy time
  api_key_secret_arn = "SET_VIA_SECRETS_MANAGER"
  # Enable AWS CloudTrail for account-level API activity audit logging
  cloudtrail_enabled = true
  # CloudTrail log retention period in days stored in the audit S3 bucket
  cloudtrail_retention_days = 90
  # SECRET (Secrets Manager ARN storing the Firebase service account JSON key): inject via Secrets Manager / SSM at deploy time
  firebase_service_account_arn = "SET_VIA_SECRETS_MANAGER"
  # API Gateway rejects all HTTP requests and requires HTTPS (TLS 1.2+)
  https_only = true
  # Require MFA for all named IAM users with AWS Console access
  iam_mfa_required = true
  # Number of days between Secrets Manager secret rotation cycles
  secret_rotation_days = 90
  # Minimum TLS version enforced on the API Gateway endpoint
  tls_minimum_version = "TLSv1.2"
}
