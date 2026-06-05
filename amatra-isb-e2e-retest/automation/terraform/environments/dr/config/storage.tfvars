#------------------------------------------------------------------------------
# Storage Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-05 19:11:53
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

storage = {
  # S3 bucket for all generated artifacts: raw MD/CSV + converted DOCX/PPTX/XLSX + Terraform bundles
  s3_artifact_bucket_name = "[s3-artifact-bucket-name]"  # TODO: Replace with actual value
  # S3 versioning on artifact bucket; retains previous object versions for 90 days
  s3_artifact_bucket_versioning = "Enabled"
  # S3 Glacier retention in days before expiry after transition from Standard storage
  s3_artifact_glacier_retention_days = 730
  # S3 key prefix for the Terraform IaC automation bundle (12th artifact type)
  s3_artifact_path_automation = "{solution_id}/automation/"
  # S3 key prefix for raw MD delivery artifacts per structured path hierarchy
  s3_artifact_path_raw_delivery = "{solution_id}/raw/delivery/"
  # S3 key prefix for raw MD/CSV presales artifacts per structured path hierarchy
  s3_artifact_path_raw_presales = "{solution_id}/raw/pre-sales/"
  # S3 Standard storage retention in days before lifecycle transition to S3 Glacier
  s3_artifact_standard_retention_days = 365
  # Dedicated S3 bucket for CloudTrail logs; Object Lock (WORM) enabled to prevent tampering
  s3_cloudtrail_bucket_name = "[s3-cloudtrail-bucket-name]"  # TODO: Replace with actual value
  # S3 bucket hosting EO Framework guidance files used by generation agents for artifact prompting
  s3_guidance_bucket_name = "[s3-guidance-bucket-name]"  # TODO: Replace with actual value
}
