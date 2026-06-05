#------------------------------------------------------------------------------
# Storage Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-05 16:27:28
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

storage = {
  # S3 bucket name for raw and converted artifact storage
  s3_bucket_name = "[s3-artifact-bucket-name]"  # TODO: Replace with actual value
  # S3 bucket name for CloudTrail logs with Object Lock (WORM)
  s3_cloudtrail_bucket = "[s3-cloudtrail-bucket-name]"  # TODO: Replace with actual value
  # Enforce HTTPS-only access via S3 bucket policy
  s3_enforce_ssl = true
  # Days after which non-current S3 object versions move to Glacier
  s3_glacier_transition_days = 30
  # Enable S3 object versioning on the artifact bucket
  s3_versioning_enabled = true
}
