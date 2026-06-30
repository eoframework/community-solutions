#------------------------------------------------------------------------------
# Security Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-30 01:10:29
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

security = {
  # Audit log retention period in years for CloudTrail PHI access events per HIPAA minimum
  audit_log_retention_years = 7
  # ARN of the organization-level CloudTrail trail for PHI audit logging
  cloudtrail_trail_arn = "[cloudtrail-trail-arn]"  # TODO: Replace with actual value
  # CloudWatch Logs retention period in days for application and infrastructure logs
  cloudwatch_log_retention_days = 90
  # Cognito App Client ID for the clinical dashboard SPA OAuth 2.0 flow
  cognito_client_id = "[cognito-app-client-id]"  # TODO: Replace with actual value
  # Amazon Cognito User Pool ID for SAML 2.0 federation and RBAC enforcement
  cognito_user_pool_id = "[cognito-user-pool-id]"  # TODO: Replace with actual value
  # Enable AWS Config with HIPAA rule set for continuous compliance monitoring
  config_enabled = true
  # Enable Amazon GuardDuty threat detection across the Clinical Applications OU
  guardduty_enabled = true
  # Enable IAM Access Analyzer to detect overly permissive resource policies
  iam_access_analyzer_enabled = true
  # SECRET (KMS CMK ARN for encrypting RDS Aurora PostgreSQL data at rest): inject via Secrets Manager / SSM at deploy time
  kms_aurora_key_id = "SET_VIA_SECRETS_MANAGER"
  # SECRET (KMS CMK ARN for encrypting EBS volumes attached to MSK brokers and SageMaker instances): inject via Secrets Manager / SSM at deploy time
  kms_ebs_key_id = "SET_VIA_SECRETS_MANAGER"
  # SECRET (KMS CMK ARN for encrypting ElastiCache Redis at rest): inject via Secrets Manager / SSM at deploy time
  kms_elasticache_key_id = "SET_VIA_SECRETS_MANAGER"
  # SECRET (KMS CMK ARN for encrypting Amazon HealthLake PHI FHIR datastore): inject via Secrets Manager / SSM at deploy time
  kms_healthlake_key_id = "SET_VIA_SECRETS_MANAGER"
  # Enable automatic annual rotation for all KMS Customer Managed Keys
  kms_key_rotation_enabled = true
  # SECRET (KMS CMK ARN for encrypting S3 CloudTrail audit log delivery bucket): inject via Secrets Manager / SSM at deploy time
  kms_s3_audit_key_id = "SET_VIA_SECRETS_MANAGER"
  # SECRET (KMS CMK ARN for encrypting S3 data lake buckets (HL7 event archive and ML artefacts)): inject via Secrets Manager / SSM at deploy time
  kms_s3_datalake_key_id = "SET_VIA_SECRETS_MANAGER"
  # Enable Amazon Macie for automated PHI data classification in S3 buckets
  macie_enabled = true
  # Require multi-factor authentication; enforced at Azure AD layer per MedCore policy
  mfa_enabled = true
  # Azure Active Directory SAML 2.0 IdP metadata endpoint URL for Cognito federation
  saml_azure_ad_metadata_url = "[azure-ad-saml-metadata-url]"  # TODO: Replace with actual value
  # SECRET (ARN of the Secrets Manager secret storing Aurora PostgreSQL credentials): inject via Secrets Manager / SSM at deploy time
  secrets_manager_aurora_secret_arn = "SET_VIA_SECRETS_MANAGER"
  # SECRET (ARN of the Secrets Manager secret storing Datadog APM API key): inject via Secrets Manager / SSM at deploy time
  secrets_manager_datadog_api_key_arn = "SET_VIA_SECRETS_MANAGER"
  # SECRET (ARN of the Secrets Manager secret storing Epic FHIR R4 SMART on FHIR OAuth 2.0 client credentials): inject via Secrets Manager / SSM at deploy time
  secrets_manager_epic_oauth_secret_arn = "SET_VIA_SECRETS_MANAGER"
  # SECRET (ARN of the Secrets Manager secret storing Mirth Connect integration API key): inject via Secrets Manager / SSM at deploy time
  secrets_manager_mirth_api_key_arn = "SET_VIA_SECRETS_MANAGER"
  # Enable AWS Security Hub for aggregated compliance and security findings
  security_hub_enabled = true
  # Minimum TLS version enforced on all ALB listeners and API Gateway endpoints
  tls_minimum_version = "TLSv1.2"
  # Enable AWS WAF on all ALBs and API Gateway endpoints
  waf_enabled = true
}
