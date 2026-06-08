#------------------------------------------------------------------------------
# Storage Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-08 21:29:43
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

storage = {
  # S3 bucket for CloudTrail event logs with Object Lock enabled
  s3_cloudtrail_bucket = "[anp-prod-cloudtrail]"  # TODO: Replace with actual value
  # S3 bucket for computed audio feature vectors at the features prefix
  s3_features_bucket = "[anp-prod-features]"  # TODO: Replace with actual value
  # Days before S3 objects transition to S3 Glacier storage class
  s3_lifecycle_glacier_days = 365
  # Days before S3 objects transition to S3-Infrequent Access storage class
  s3_lifecycle_ia_days = 90
  # S3 bucket for SageMaker training artifacts and versioned model packages
  s3_models_bucket = "[anp-prod-models]"  # TODO: Replace with actual value
  # S3 bucket for source audio files stored at the raw-catalog prefix
  s3_raw_catalog_bucket = "[anp-prod-raw-catalog]"  # TODO: Replace with actual value
  # S3 bucket for lyric and podcast transcript text files
  s3_transcripts_bucket = "[anp-prod-transcripts]"  # TODO: Replace with actual value
  # Enable S3 versioning on all buckets to protect against accidental deletion
  s3_versioning_enabled = true
}
