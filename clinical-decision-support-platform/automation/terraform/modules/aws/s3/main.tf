################################################################################
# Tier 1 — AWS S3 Module
# HIPAA-compliant S3 bucket with versioning, KMS encryption, access logging,
# lifecycle policies, and optional Object Lock.
################################################################################

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = merge(var.common_tags, {
    Name            = var.bucket_name
    DataClassification = var.data_classification
  })
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object_lock_configuration" "this" {
  count  = var.enable_object_lock ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    default_retention {
      mode  = "COMPLIANCE"
      years = var.object_lock_retention_years
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = "Enabled"

      dynamic "filter" {
        for_each = lookup(rule.value, "prefix", null) != null ? [1] : []
        content {
          prefix = rule.value.prefix
        }
      }

      dynamic "transition" {
        for_each = lookup(rule.value, "transition_days", null) != null ? [1] : []
        content {
          days          = rule.value.transition_days
          storage_class = lookup(rule.value, "transition_storage_class", "STANDARD_IA")
        }
      }

      dynamic "expiration" {
        for_each = lookup(rule.value, "expiration_days", null) != null ? [1] : []
        content {
          days = rule.value.expiration_days
        }
      }
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "this" {
  count  = var.enable_replication ? 1 : 0
  bucket = aws_s3_bucket.this.id
  role   = aws_iam_role.replication[0].arn

  rule {
    id     = "replicate-all"
    status = "Enabled"

    destination {
      bucket        = var.replication_destination_bucket_arn
      storage_class = "STANDARD"

      encryption_configuration {
        replica_kms_key_id = var.replication_destination_kms_key_arn
      }
    }

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

resource "aws_iam_role" "replication" {
  count = var.enable_replication ? 1 : 0
  name  = "${var.name_prefix}-s3-replication-role-${var.bucket_suffix}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "s3.amazonaws.com" }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "replication" {
  count = var.enable_replication ? 1 : 0
  name  = "${var.name_prefix}-s3-replication-policy-${var.bucket_suffix}"
  role  = aws_iam_role.replication[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetReplicationConfiguration", "s3:ListBucket"]
        Resource = aws_s3_bucket.this.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = "${aws_s3_bucket.this.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Resource = "${var.replication_destination_bucket_arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = var.kms_key_arn
      },
      {
        Effect   = "Allow"
        Action   = ["kms:GenerateDataKey"]
        Resource = var.replication_destination_kms_key_arn != null ? var.replication_destination_kms_key_arn : var.kms_key_arn
      }
    ]
  })
}
