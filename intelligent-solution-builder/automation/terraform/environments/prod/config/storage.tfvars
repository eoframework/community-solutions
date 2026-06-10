#------------------------------------------------------------------------------
# Storage Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-10 02:56:40
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

storage = {
  # S3 bucket name for all generated artifacts stored under structured key taxonomy
  s3_artifacts_bucket_name = "[amatra-isb-artifacts-prod-account-id]"  # TODO: Replace with actual value
  # Days before artifacts are transitioned from S3 Standard to S3 Glacier Flexible Retrieval
  s3_artifacts_lifecycle_standard_days = 180
  # S3 bucket name for immutable CloudTrail audit logs with Object Lock (WORM)
  s3_cloudtrail_bucket_name = "[amatra-isb-cloudtrail-logs-prod]"  # TODO: Replace with actual value
  # SECRET (KMS CMK alias used for SSE-KMS encryption on the artifacts bucket): inject via Secrets Manager / SSM at deploy time
  s3_encryption_key_alias = "SET_VIA_SECRETS_MANAGER"
  # S3 bucket name for Bedrock prompt templates and ingested legacy Word/Excel/PPT templates
  s3_templates_bucket_name = "[amatra-isb-templates-prod]"  # TODO: Replace with actual value
  # Enable S3 versioning on the artifacts bucket to protect against accidental deletion
  s3_versioning_enabled = true
}
