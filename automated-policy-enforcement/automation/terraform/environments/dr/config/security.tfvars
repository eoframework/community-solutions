#------------------------------------------------------------------------------
# Security Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-09 21:41:31
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

identity = {
  # Number of on-premises IdP connectors configured in IAM Identity Center (SOW: 1 IdP)
  sso_idp_connector_count = 1
  # Maximum session duration in minutes for the BreakGlass emergency access role
  sso_permission_set_breakglass_session_minutes = 240
  # IAM Identity Center permission set name for developer read-only access to own workload accounts
  sso_permission_set_developer = "Developer"
  # IAM Identity Center permission set name for operator read/write access to non-production accounts
  sso_permission_set_operator = "PlatformOperator"
  # IAM Identity Center permission set name for read-only Security Hub and Config access in Audit account
  sso_permission_set_security_viewer = "SecurityViewer"
  # SAML 2.0 metadata URL of the on-premises enterprise directory identity provider
  sso_saml_idp_metadata_url = "[idp-metadata-url]"  # TODO: Replace with actual value
  # SECRET (SAML 2.0 signing certificate PEM from the on-premises IdP pinned in IAM Identity Center): inject via Secrets Manager / SSM at deploy time
  sso_saml_signing_cert = "SET_VIA_SECRETS_MANAGER"
}

scp = {
  # Name of the SCP that blocks IAM user creation and console sign-in in production OU
  deny_console_access_policy_name = "cntso-deny-console-access-prod"
  # Name of the SCP mandating encryption at rest for S3 and EBS across all accounts
  encryption_enforce_policy_name = "cntso-enforce-encryption-org"
  # Comma-separated list of permitted AWS regions enforced by the region-lock SCP
  region_lock_allowed_regions = ["ap-southeast-2,ap-southeast-4"]
}

security = {
  # Frequency of CISO-led IAM Identity Center permission set assignment reviews
  access_review_frequency = "quarterly"
  # Enable SHA-256 CloudTrail log file integrity validation
  cloudtrail_log_integrity_enabled = true
  # CloudTrail log retention in years enforced via S3 Object Lock Compliance mode
  cloudtrail_log_retention_years = 1
  # SCP deny for IAM user creation and console sign-in enforced in production OU
  console_access_blocked_in_prod = true
  # Maximum age in days for integration API credentials before mandatory rotation
  credentials_rotation_days = 90
  # SECRET (KMS CMK ARN used to encrypt the AFT workflow DynamoDB table): inject via Secrets Manager / SSM at deploy time
  kms_aft_dynamodb_key_arn = "SET_VIA_SECRETS_MANAGER"
  # SECRET (KMS CMK ARN used to encrypt the Log Archive S3 bucket (CloudTrail and Config logs)): inject via Secrets Manager / SSM at deploy time
  kms_log_archive_key_arn = "SET_VIA_SECRETS_MANAGER"
  # Enable automatic annual KMS CMK rotation for all platform keys
  kms_rotation_enabled = true
  # SECRET (KMS CMK ARN used to encrypt the Terraform state S3 bucket): inject via Secrets Manager / SSM at deploy time
  kms_terraform_state_key_arn = "SET_VIA_SECRETS_MANAGER"
  # Require MFA enforced at on-premises IdP before SAML assertions issued to AWS
  mfa_enabled = true
  # Maximum IAM Identity Center SSO session duration in minutes for standard roles
  session_timeout_minutes = 60
}
