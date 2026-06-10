#------------------------------------------------------------------------------
# Tier 2 — Storage Module
# Composes: aws/s3 — artifacts, templates, and CloudTrail buckets
# SOC 2 C1 / GDPR data residency and WORM audit log layer
#------------------------------------------------------------------------------

# Artifacts bucket — stores all generated consulting artifacts
module "artifacts_bucket" {
  source = "../aws/s3"

  bucket_name        = var.artifacts_bucket_name
  kms_key_arn        = var.kms_s3_key_arn
  versioning_enabled = var.versioning_enabled
  force_destroy      = false
  common_tags        = merge(var.common_tags, {
    Purpose            = "GeneratedArtifacts"
    DataClassification = "confidential"
  })

  lifecycle_rules = [
    {
      id     = "glacier-transition"
      status = "Enabled"
      transitions = [{
        days          = var.artifacts_lifecycle_standard_days
        storage_class = "GLACIER"
      }]
    }
  ]
}

# Templates bucket — Bedrock prompt templates and legacy Word/Excel/PPT
module "templates_bucket" {
  source = "../aws/s3"

  bucket_name        = var.templates_bucket_name
  kms_key_arn        = var.kms_s3_key_arn
  versioning_enabled = true
  force_destroy      = false
  common_tags        = merge(var.common_tags, {
    Purpose            = "BedrockPromptTemplates"
    DataClassification = "internal"
  })
}

# CloudTrail audit log bucket — WORM Object Lock, 7-year retention
module "cloudtrail_bucket" {
  source = "../aws/s3"

  bucket_name        = var.cloudtrail_bucket_name
  kms_key_arn        = var.kms_s3_key_arn
  versioning_enabled = true
  force_destroy      = false
  enable_object_lock = true
  object_lock_mode   = "COMPLIANCE"
  object_lock_years  = var.cloudtrail_retention_years
  common_tags        = merge(var.common_tags, {
    Purpose            = "CloudTrailAuditLogs"
    DataClassification = "confidential"
    Compliance         = "SOC2-WORM"
  })
}

# Artifacts bucket policy — deny unencrypted PutObject requests
resource "aws_s3_bucket_policy" "artifacts_deny_unencrypted" {
  bucket = module.artifacts_bucket.bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyUnencryptedObjectUploads"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "${module.artifacts_bucket.bucket_arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "aws:kms"
          }
        }
      },
      {
        Sid       = "DenyNonTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [module.artifacts_bucket.bucket_arn, "${module.artifacts_bucket.bucket_arn}/*"]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })
}

# CloudTrail bucket policy — allow CloudTrail service to write logs
resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = module.cloudtrail_bucket.bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudTrailACLCheck"
        Effect = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action   = "s3:GetBucketAcl"
        Resource = module.cloudtrail_bucket.bucket_arn
      },
      {
        Sid    = "AllowCloudTrailWrite"
        Effect = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action   = "s3:PutObject"
        Resource = "${module.cloudtrail_bucket.bucket_arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
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
        Resource  = [module.cloudtrail_bucket.bucket_arn, "${module.cloudtrail_bucket.bucket_arn}/*"]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}
