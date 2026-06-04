#------------------------------------------------------------------------------
# Tier 1: AWS S3 Buckets — Artifacts, guidance, and CloudTrail log storage
#------------------------------------------------------------------------------

# Artifacts bucket — raw source, converted documents, Terraform bundles
resource "aws_s3_bucket" "artifacts" {
  bucket        = var.artifacts_bucket_name
  force_destroy = false
  tags          = merge(var.common_tags, { Name = var.artifacts_bucket_name, Purpose = "artifact-storage" })
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = var.artifacts_versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    id     = "intelligent-tiering-transition"
    status = "Enabled"

    transition {
      days          = var.artifacts_intelligent_tiering_days
      storage_class = "INTELLIGENT_TIERING"
    }

    filter {
      prefix = ""
    }
  }

  rule {
    id     = "noncurrent-version-expiry"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.s3_version_retention_days
    }

    filter {
      prefix = ""
    }
  }
}

# Guidance bucket — EO Framework guidance files loaded by agents as prompt context
resource "aws_s3_bucket" "guidance" {
  bucket        = var.guidance_bucket_name
  force_destroy = false
  tags          = merge(var.common_tags, { Name = var.guidance_bucket_name, Purpose = "guidance-storage" })
}

resource "aws_s3_bucket_versioning" "guidance" {
  bucket = aws_s3_bucket.guidance.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "guidance" {
  bucket = aws_s3_bucket.guidance.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "guidance" {
  bucket                  = aws_s3_bucket.guidance.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudTrail log bucket — tamper-resistant audit log storage
resource "aws_s3_bucket" "cloudtrail" {
  bucket        = var.cloudtrail_bucket_name
  force_destroy = false
  tags          = merge(var.common_tags, { Name = var.cloudtrail_bucket_name, Purpose = "cloudtrail-logs" })
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
