#------------------------------------------------------------------------------
# Security Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-05 19:11:53
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

security = {
  # Enable CloudTrail Management Events logging all AWS API calls in us-west-2 account
  cloudtrail_management_events = true
  # CloudTrail log retention in days in dedicated S3 bucket with Object Lock
  cloudtrail_retention_days = 90
  # Enable CloudTrail S3 Data Events on artifact bucket for GetObject/PutObject audit trail
  cloudtrail_s3_data_events = false
  # JWT access token expiry in seconds (1 hour); CLI auto-refreshes using stored refresh token
  cognito_access_token_expiry_seconds = 3600
  # SECRET (Cognito User Pool App Client ID used by the CLI for PKCE-based authorization code flow): inject via Secrets Manager / SSM at deploy time
  cognito_app_client_id = "SET_VIA_SECRETS_MANAGER"
  # CTO approval gate required before provisioning production Cognito User Pool per SOW
  cognito_cto_signoff_required = false
  # Require MFA for Admin role in production; standard Cognito MFA setting
  cognito_mfa_enabled = false
  # Cognito refresh token validity in days per SOW Security & Compliance specification
  cognito_refresh_token_expiry_days = 30
  # SECRET (Cognito User Pool ID; referenced by API Gateway JWT authoriser and Lambda route handlers): inject via Secrets Manager / SSM at deploy time
  cognito_user_pool_id = "SET_VIA_SECRETS_MANAGER"
  # Amazon Cognito User Pool name providing JWT authentication for all 11 API routes and CLI
  cognito_user_pool_name = "eofw-dev-userpool"
  # Enable AWS GuardDuty for threat detection in us-west-2 account; findings routed to Security Hub
  guardduty_enabled = true
  # Enable IAM Access Analyzer to continuously validate no overly permissive Lambda execution roles exist
  iam_access_analyzer_enabled = true
  # KMS key rotation period in days applied to S3 CMK and Secrets Manager encryption keys
  kms_rotation_days = 90
  # SECRET (Customer-managed KMS key ARN for S3 artifact bucket SSE-KMS encryption at rest): inject via Secrets Manager / SSM at deploy time
  kms_s3_cmk_arn = "SET_VIA_SECRETS_MANAGER"
  # Enable AWS Security Hub aggregating GuardDuty / Config / Inspector findings for SOC 2 posture
  securityhub_enabled = true
  # Minimum TLS version enforced on API Gateway / Cognito / DynamoDB / S3 SDK endpoints
  tls_minimum_version = "TLS1.2"
}
