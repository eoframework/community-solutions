#------------------------------------------------------------------------------
# Storage Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-09 01:56:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

storage = {
  # S3 bucket name for lyric and transcript text file storage
  catalog_bucket_name = "[anp-catalog-bucket-prod]"  # TODO: Replace with actual value
  # Server-side encryption algorithm applied to all catalog S3 objects
  catalog_encryption = "SSE-S3"
  # S3 key prefix for catalog lyric and transcript files
  catalog_prefix = "catalog/"
  # Maximum expected catalog storage volume in GB per SOW scope parameter
  catalog_size_limit_gb = 50
  # Enable S3 object versioning on the catalog bucket
  catalog_versioning_enabled = true
}
