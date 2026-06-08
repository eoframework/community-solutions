#------------------------------------------------------------------------------
# Tier 1 — AWS S3: Bucket with encryption, versioning, lifecycle, and
# public access blocking
#------------------------------------------------------------------------------

resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  tags = merge(var.common_tags, {
    Name = var.bucket_name
  })
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count  = (var.lifecycle_ia_days > 0 || var.lifecycle_glacier_days > 0) ? 1 : 0
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "tiered-storage"
    status = "Enabled"

    filter {}

    dynamic "transition" {
      for_each = var.lifecycle_ia_days > 0 ? [1] : []
      content {
        days          = var.lifecycle_ia_days
        storage_class = "STANDARD_IA"
      }
    }

    dynamic "transition" {
      for_each = var.lifecycle_glacier_days > 0 ? [1] : []
      content {
        days          = var.lifecycle_glacier_days
        storage_class = "GLACIER"
      }
    }
  }
}
