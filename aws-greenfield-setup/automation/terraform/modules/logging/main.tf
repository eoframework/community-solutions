#------------------------------------------------------------------------------
# Logging Module (Tier 2)
# Composes: aws/s3, aws/cloudtrail
# Manages: Log Archive S3 bucket, org CloudTrail trail, CloudTrail Lake
#------------------------------------------------------------------------------

module "log_archive_bucket" {
  source = "../aws/s3"

  bucket_name         = var.log_archive_bucket_name
  versioning_enabled  = true
  kms_key_arn         = var.kms_key_arn
  object_lock_enabled = var.object_lock_enabled
  object_lock_mode    = "COMPLIANCE"
  object_lock_days    = var.object_lock_retention_days

  lifecycle_rules = [
    {
      id      = "glacier-transition"
      enabled = true
      prefix  = ""
      transitions = [
        {
          days          = var.glacier_transition_days
          storage_class = "GLACIER_IR"
        }
      ]
    }
  ]

  bucket_policy = var.log_archive_bucket_policy
  common_tags   = merge(var.common_tags, { Purpose = "LogArchive" })
}

module "cloudtrail" {
  source = "../aws/cloudtrail"

  trail_name            = var.trail_name
  s3_bucket_name        = var.log_archive_bucket_name
  s3_key_prefix         = "cloudtrail"
  is_organization_trail = var.is_organization_trail
  kms_key_arn           = var.kms_key_arn
  enable_data_events    = var.enable_cloudtrail_data_events
  common_tags           = var.common_tags

  depends_on = [module.log_archive_bucket]
}

resource "aws_cloudtrail_event_data_store" "this" {
  count                          = var.enable_cloudtrail_lake ? 1 : 0
  name                           = "${var.name_prefix}-cloudtrail-lake"
  multi_region_enabled           = true
  organization_enabled           = var.is_organization_trail
  retention_period               = var.cloudtrail_lake_retention_days
  termination_protection_enabled = true
  tags                           = merge(var.common_tags, { Name = "${var.name_prefix}-cloudtrail-lake" })
}
