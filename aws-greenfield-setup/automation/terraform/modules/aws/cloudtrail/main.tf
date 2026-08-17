#------------------------------------------------------------------------------
# AWS CloudTrail Tier-1 Module
# Organisation-wide CloudTrail trail
#------------------------------------------------------------------------------

resource "aws_cloudtrail" "this" {
  name                          = var.trail_name
  s3_bucket_name                = var.s3_bucket_name
  s3_key_prefix                 = var.s3_key_prefix
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = var.is_organization_trail
  enable_log_file_validation    = true
  cloud_watch_logs_group_arn    = var.cloudwatch_log_group_arn != null ? "${var.cloudwatch_log_group_arn}:*" : null
  cloud_watch_logs_role_arn     = var.cloudwatch_log_role_arn
  kms_key_id                    = var.kms_key_arn
  tags                          = merge(var.common_tags, { Name = var.trail_name })

  dynamic "event_selector" {
    for_each = var.enable_data_events ? [1] : []
    content {
      read_write_type           = "All"
      include_management_events = true
      data_resource {
        type   = "AWS::S3::Object"
        values = ["arn:aws:s3"]
      }
    }
  }
}
