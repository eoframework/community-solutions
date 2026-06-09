#------------------------------------------------------------------------------
# Tier 2: Storage — S3 log archive (WORM Object Lock) + Terraform state bucket
# Uses aws/s3 Tier 1 primitives; configures CRR for DR replication
#------------------------------------------------------------------------------

module "log_archive_bucket" {
  source = "../aws/s3"

  name_prefix           = var.name_prefix
  purpose               = "log-archive"
  kms_key_arn           = var.kms_key_arn
  versioning_enabled    = true
  object_lock_enabled   = true
  object_lock_mode      = var.log_archive_object_lock_mode
  object_lock_years     = var.log_retention_years
  force_destroy         = false
  replication_enabled   = true
  replication_region    = var.dr_region
  common_tags           = merge(var.common_tags, {
    DataClassification = "confidential"
    BackupPolicy       = "object-lock-${var.log_retention_years}y"
  })
}

module "crr_destination_bucket" {
  source = "../aws/s3"

  name_prefix           = "${var.name_prefix}-dr"
  purpose               = "log-archive-crr"
  kms_key_arn           = var.kms_key_arn
  versioning_enabled    = true
  object_lock_enabled   = true
  object_lock_mode      = var.log_archive_object_lock_mode
  object_lock_years     = var.log_retention_years
  force_destroy         = false
  replication_enabled   = false
  common_tags           = merge(var.common_tags, {
    DataClassification = "confidential"
    Purpose            = "crr-destination"
    BackupPolicy       = "object-lock-${var.log_retention_years}y"
  })
}

module "tf_state_bucket" {
  source = "../aws/s3"

  name_prefix           = var.name_prefix
  purpose               = "tf-state"
  kms_key_arn           = var.kms_key_arn
  versioning_enabled    = var.tf_state_versioning_enabled
  object_lock_enabled   = false
  force_destroy         = false
  replication_enabled   = false
  common_tags           = merge(var.common_tags, {
    DataClassification = "confidential"
    Purpose            = "terraform-state"
    BackupPolicy       = "daily-30d"
  })
}

#------------------------------------------------------------------------------
# S3 CRR IAM role — allows S3 to replicate log archive objects to DR bucket
#------------------------------------------------------------------------------
resource "aws_iam_role" "s3_crr" {
  name        = "${var.name_prefix}-s3-crr-role"
  description = "IAM role for S3 Cross-Region Replication from log archive to DR bucket"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-s3-crr-role"
    Purpose = "s3-crr"
  })
}

resource "aws_iam_role_policy" "s3_crr" {
  name = "${var.name_prefix}-s3-crr-policy"
  role = aws_iam_role.s3_crr.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SourceBucketRead"
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Resource = [module.log_archive_bucket.bucket_arn]
      },
      {
        Sid    = "SourceObjectRead"
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = ["${module.log_archive_bucket.bucket_arn}/*"]
      },
      {
        Sid    = "DestinationBucketWrite"
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Resource = ["${module.crr_destination_bucket.bucket_arn}/*"]
      },
      {
        Sid    = "KMSDecryptSource"
        Effect = "Allow"
        Action = ["kms:Decrypt"]
        Resource = [var.kms_key_arn]
      },
      {
        Sid    = "KMSEncryptDestination"
        Effect = "Allow"
        Action = ["kms:GenerateDataKey"]
        Resource = [var.kms_key_arn]
      }
    ]
  })
}
