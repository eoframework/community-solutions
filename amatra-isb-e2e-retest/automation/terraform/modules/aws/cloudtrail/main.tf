#------------------------------------------------------------------------------
# AWS CloudTrail Module - Tier 1 Provider Primitive
# Creates CloudTrail trail with S3 bucket and CloudWatch Logs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# S3 Bucket for CloudTrail Logs (Object Lock / WORM)
#------------------------------------------------------------------------------
resource "aws_s3_bucket" "cloudtrail" {
  bucket        = var.cloudtrail_bucket_name
  force_destroy = false

  tags = merge(var.common_tags, {
    Name    = var.cloudtrail_bucket_name
    Purpose = "CloudTrailLogs"
  })
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket                  = aws_s3_bucket.cloudtrail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    id     = "cloudtrail-retention"
    status = "Enabled"
    filter {}
    expiration {
      days = var.retention_days
    }
  }

  depends_on = [aws_s3_bucket_versioning.cloudtrail]
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail.arn}/AWSLogs/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

#------------------------------------------------------------------------------
# CloudWatch Log Group for CloudTrail
#------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/eofw/cloudtrail"
  retention_in_days = var.cloudwatch_retention_days

  tags = var.common_tags
}

resource "aws_iam_role" "cloudtrail_cw" {
  name = "${var.name_prefix}-role-cloudtrail-cw"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "cloudtrail_cw" {
  name = "${var.name_prefix}-policy-cloudtrail-cw"
  role = aws_iam_role.cloudtrail_cw.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
    }]
  })
}

#------------------------------------------------------------------------------
# CloudTrail Trail
#------------------------------------------------------------------------------
resource "aws_cloudtrail" "main" {
  name                          = "${var.name_prefix}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_log_file_validation    = true
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_cw.arn

  dynamic "event_selector" {
    for_each = var.s3_data_events_bucket_arn != "" ? [1] : []
    content {
      read_write_type           = "All"
      include_management_events = true

      data_resource {
        type   = "AWS::S3::Object"
        values = ["${var.s3_data_events_bucket_arn}/"]
      }
    }
  }

  dynamic "event_selector" {
    for_each = var.s3_data_events_bucket_arn == "" ? [1] : []
    content {
      read_write_type           = "All"
      include_management_events = true
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-cloudtrail"
  })

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}
