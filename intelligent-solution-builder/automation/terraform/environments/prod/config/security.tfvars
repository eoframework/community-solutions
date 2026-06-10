#------------------------------------------------------------------------------
# Security Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-10 02:56:40
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

security = {
  # Enable AWS CloudTrail for all management events and S3 data events
  cloudtrail_enabled = true
  # Retention period in years for CloudTrail logs in the S3 audit bucket (Object Lock Compliance mode)
  cloudtrail_retention_years = 7
  # Cognito group name for platform administrators with usage-limit override capability
  cognito_admin_group_name = "AmAdmin"
  # Cognito group name for delivery consultants with access to all 7 artifact types
  cognito_delivery_group_name = "Delivery"
  # Cognito MFA enforcement level for PreSales and Delivery groups
  cognito_mfa_enforcement = "OPTIONAL"
  # Cognito group name for pre-sales consultants (Phase 1 artifact types only)
  cognito_presales_group_name = "PreSales"
  # Access token validity in minutes for Cognito-issued JWTs
  cognito_token_expiry_minutes = 15
  # SECRET (Cognito App Client ID used by API Gateway Cognito authoriser for JWT token validation): inject via Secrets Manager / SSM at deploy time
  cognito_user_pool_client_id = "SET_VIA_SECRETS_MANAGER"
  # SECRET (Amazon Cognito User Pool ID for all platform user authentication): inject via Secrets Manager / SSM at deploy time
  cognito_user_pool_id = "SET_VIA_SECRETS_MANAGER"
  # Enable AWS GuardDuty for continuous threat detection across the account
  guardduty_enabled = true
  # SECRET (KMS Customer Managed Key ID for CloudTrail log bucket encryption): inject via Secrets Manager / SSM at deploy time
  kms_cloudtrail_key_id = "SET_VIA_SECRETS_MANAGER"
  # SECRET (KMS Customer Managed Key ID for DynamoDB table encryption): inject via Secrets Manager / SSM at deploy time
  kms_dynamodb_key_id = "SET_VIA_SECRETS_MANAGER"
  # SECRET (KMS Customer Managed Key ID for S3 artifacts bucket encryption): inject via Secrets Manager / SSM at deploy time
  kms_s3_key_id = "SET_VIA_SECRETS_MANAGER"
  # SECRET (KMS Customer Managed Key ID for Secrets Manager secret encryption): inject via Secrets Manager / SSM at deploy time
  kms_secrets_manager_key_id = "SET_VIA_SECRETS_MANAGER"
  # Enforce S3 Block Public Access at the AWS account level
  s3_block_public_access = true
  # Enable AWS Security Hub to aggregate GuardDuty and Config findings
  securityhub_enabled = true
  # Inactive session timeout in minutes enforced by Cognito app client
  session_timeout_minutes = 30
  # WAF rate-based rule threshold: maximum requests per IP per 5-minute window
  waf_rate_limit_per_ip_per_5min = 2000
  # ARN of the AWS WAF WebACL attached to the API Gateway REST API stage
  waf_web_acl_arn = "[waf-web-acl-arn]"  # TODO: Replace with actual value
}
