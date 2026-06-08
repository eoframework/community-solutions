#------------------------------------------------------------------------------
# Security Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-08 21:29:43
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

security = {
  # Enable AWS CloudTrail management-event trail with S3 Object Lock
  cloudtrail_enabled = true
  # Cognito User Pool App Client ID for FlutterFlow application
  cognito_client_id = "[cognito-app-client-id]"  # TODO: Replace with actual value
  # Require MFA for admin-role users in the Cognito User Pool
  cognito_mfa_enabled = true
  # Cognito JWT access token expiry in minutes
  cognito_token_expiry_minutes = 60
  # Amazon Cognito User Pool ID for API JWT authentication
  cognito_user_pool_id = "[cognito-user-pool-id]"  # TODO: Replace with actual value
  # SECRET (Secrets Manager ARN for Firebase REST API credentials): inject via Secrets Manager / SSM at deploy time
  firebase_credentials_secret_arn = "SET_VIA_SECRETS_MANAGER"
  # Enable Amazon GuardDuty for threat detection
  guardduty_enabled = true
  # Enable IAM Access Analyzer to detect overly permissive policies
  iam_access_analyzer_enabled = true
  # KMS CMK alias for catalog DynamoDB table and S3 raw-catalog bucket
  kms_catalog_cmk_alias = "alias/anp-prod-catalog"
  # KMS CMK alias for SageMaker model artifact S3 bucket encryption
  kms_model_artifacts_cmk_alias = "alias/anp-prod-model-artifacts"
  # Enable automatic annual key rotation for all KMS CMKs
  kms_rotation_enabled = true
  # KMS CMK alias for user-profile and interaction-events tables
  kms_user_data_cmk_alias = "alias/anp-prod-user-data"
  # CloudWatch Logs retention in days for Lambda and API access logs
  log_retention_days = 90
  # Automatic rotation cadence in days for all Secrets Manager secrets
  secrets_rotation_days = 90
  # Minimum TLS version on API Gateway and all inter-service calls
  tls_minimum_version = "TLSv1.2"
  # Enable AWS WAF v2 on API Gateway with Managed Rule Groups
  waf_enabled = true
}
