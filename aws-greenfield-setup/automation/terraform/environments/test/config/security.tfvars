#------------------------------------------------------------------------------
# Security Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-08-17 00:33:59
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

iam_identity_center = {
  # Identity source type for IAM Identity Center; NATIVE or EXTERNAL_IDP
  identity_source = "NATIVE"
  # Identity Store ID associated with the IAM Identity Center instance
  identity_store_id = "[identity-store-id]"  # TODO: Replace with actual value
  # ARN of the IAM Identity Center instance used for all cross-account SSO
  instance_arn = "[sso-instance-arn]"  # TODO: Replace with actual value
  # Maximum session duration in hours for all IAM Identity Center permission sets
  session_duration_hours = 8
}

security = {
  # Maximum number of days before break-glass credentials must be rotated
  breakglass_rotation_days = 90
  # SECRET (Secrets Manager ARN for the sealed management-account root break-glass credentials): inject via Secrets Manager / SSM at deploy time
  breakglass_secret_arn = "SET_VIA_SECRETS_MANAGER"
  # Enable EBS encryption by default in all member accounts via Config rule
  ebs_encryption_by_default = true
  # SECRET (ARN of the customer-managed KMS key in us-east-1 for S3/CloudTrail/EBS encryption): inject via Secrets Manager / SSM at deploy time
  kms_key_arn_us_east_1 = "SET_VIA_SECRETS_MANAGER"
  # SECRET (ARN of the customer-managed KMS key in us-east-2 for DR region encryption): inject via Secrets Manager / SSM at deploy time
  kms_key_arn_us_east_2 = "SET_VIA_SECRETS_MANAGER"
  # Enable automatic annual rotation for all customer-managed KMS keys in both regions
  kms_key_rotation_enabled = true
  # Enforce MFA for all IAM Identity Center users via SCP deny on aws:MultiFactorAuthPresent=false
  mfa_enabled = true
  # Enable Resource Control Policy enforcing org-boundary data perimeter on all member accounts
  rcp_data_perimeter_enabled = false
  # Enforce S3 Block Public Access setting at the AWS account level across all member accounts
  s3_block_public_access = true
  # Enable SCP preventing disabling or modification of the CloudTrail organisation trail
  scp_cloudtrail_lock_enabled = true
  # Enable SCP preventing disabling of AWS Config recording across member accounts
  scp_config_lock_enabled = true
  # Enable SCP that denies all root account API actions across all member accounts
  scp_deny_root_enabled = true
  # Enable SCP restricting all API calls to us-east-1 and us-east-2 only
  scp_restrict_regions_enabled = true
  # Minimum TLS version enforced by S3 bucket policies and Network Firewall egress rules
  tls_minimum_version = "TLS1_2"
}
