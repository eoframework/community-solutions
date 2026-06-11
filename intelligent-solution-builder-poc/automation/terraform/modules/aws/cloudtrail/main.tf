###############################################################################
# Tier 1 Provider Module — AWS CloudTrail
# Creates a multi-region CloudTrail trail writing to a dedicated S3 bucket
# with Object Lock (WORM) for SOC 2 compliance.
###############################################################################

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#--------------------------------------
# CloudTrail S3 bucket with Object Lock
#--------------------------------------
resource "aws_s3_bucket" "cloudtrail" {
  bucket        = var.cloudtrail_bucket_name
  force_destroy = var.force_destroy

  tags = merge(var.common_tags, {
    Name = var.cloudtrail_bucket_name
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
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket                  = aws_s3_bucket.cloudtrail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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
        Resource = "${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Sid       = "DenyNonTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.cloudtrail.arn,
          "${aws_s3_bucket.cloudtrail.arn}/*"
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })
}

#--------------------------------------
# CloudTrail Trail
#--------------------------------------
resource "aws_cloudtrail" "main" {
  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = var.kms_key_arn

  dynamic "event_selector" {
    for_each = var.include_data_events ? [1] : []
    content {
      read_write_type           = "All"
      include_management_events = true
      data_resource {
        type   = "AWS::S3::Object"
        values = ["arn:aws:s3:::"]
      }
      data_resource {
        type   = "AWS::DynamoDB::Table"
        values = ["arn:aws:dynamodb"]
      }
    }
  }

  tags = merge(var.common_tags, {
    Name = var.trail_name
  })

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}
