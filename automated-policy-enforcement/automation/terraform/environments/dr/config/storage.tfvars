#------------------------------------------------------------------------------
# Storage Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-09 21:41:31
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

storage = {
  # S3 bucket name in Log Archive account for centralised CloudTrail and Config log storage
  log_archive_bucket_name = "[bucket-name]"  # TODO: Replace with actual value
  # Expected monthly CloudTrail log volume in GB used for S3 capacity planning
  log_archive_cloudtrail_log_volume_gb_monthly = 200
  # S3 bucket name in ap-southeast-4 as the cross-region replication destination for log archive data
  log_archive_crr_destination_bucket = "[bucket-name]"  # TODO: Replace with actual value
  # S3 Object Lock mode enforcing WORM retention on log archive bucket
  log_archive_object_lock_mode = "COMPLIANCE"
  # S3 bucket name in Management account for Terraform state files across all workspaces
  terraform_state_bucket_name = "[bucket-name]"  # TODO: Replace with actual value
  # Enable S3 versioning on Terraform state bucket to support state file rollback
  terraform_state_versioning_enabled = true
}
