#------------------------------------------------------------------------------
# Tier 1: AWS CloudTrail — API-level audit with WORM retention
# Data events for S3 and DynamoDB; 365-day retention in WORM bucket
#------------------------------------------------------------------------------

resource "aws_cloudtrail" "main" {
  count                         = var.enabled ? 1 : 0
  name                          = "${var.name_prefix}-trail"
  s3_bucket_name                = var.cloudtrail_bucket
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_log_file_validation    = true
  kms_key_id                    = var.kms_key_arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }

  event_selector {
    read_write_type           = "All"
    include_management_events = false

    data_resource {
      type   = "AWS::DynamoDB::Table"
      values = ["arn:aws:dynamodb"]
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-trail"
  })
}
