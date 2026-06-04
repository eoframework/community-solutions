#------------------------------------------------------------------------------
# Tier 1: AWS CloudTrail — Audit log for all management and data-plane API calls
#------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/amatra/${var.aws_region}/cloudtrail"
  retention_in_days = var.cloudtrail_log_retention_days
  tags              = var.common_tags
}

data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudtrail" {
  name               = "${var.name_prefix}-iam-role-cloudtrail"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
  tags               = var.common_tags
}

resource "aws_iam_role_policy" "cloudtrail_cw_logs" {
  name = "${var.name_prefix}-policy-cloudtrail-cw-logs"
  role = aws_iam_role.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
      }
    ]
  })
}

resource "aws_cloudtrail" "main" {
  name                          = "${var.name_prefix}-cloudtrail"
  s3_bucket_name                = var.cloudtrail_s3_bucket_name
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_log_file_validation    = true
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }

    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"]
    }
  }

  tags = var.common_tags
}
