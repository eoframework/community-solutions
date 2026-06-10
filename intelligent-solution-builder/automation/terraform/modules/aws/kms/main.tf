#------------------------------------------------------------------------------
# Tier 1 — AWS KMS Customer Managed Keys
# Provisions four dedicated CMKs: S3, DynamoDB, CloudTrail, Secrets Manager
#------------------------------------------------------------------------------

resource "aws_kms_key" "s3" {
  count = var.enable_s3_key ? 1 : 0

  description             = "KMS CMK for S3 artifact bucket encryption — ${var.name_prefix}"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  multi_region            = false

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccountPermissions"
        Effect = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-s3-key"
    Purpose = "S3ArtifactEncryption"
  })
}

resource "aws_kms_alias" "s3" {
  count         = var.enable_s3_key ? 1 : 0
  name          = var.s3_key_alias
  target_key_id = aws_kms_key.s3[0].key_id
}

resource "aws_kms_key" "dynamodb" {
  count = var.enable_dynamodb_key ? 1 : 0

  description             = "KMS CMK for DynamoDB table encryption — ${var.name_prefix}"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  multi_region            = false

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccountPermissions"
        Effect = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-dynamodb-key"
    Purpose = "DynamoDBEncryption"
  })
}

resource "aws_kms_alias" "dynamodb" {
  count         = var.enable_dynamodb_key ? 1 : 0
  name          = var.dynamodb_key_alias
  target_key_id = aws_kms_key.dynamodb[0].key_id
}

resource "aws_kms_key" "cloudtrail" {
  count = var.enable_cloudtrail_key ? 1 : 0

  description             = "KMS CMK for CloudTrail log encryption — ${var.name_prefix}"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  multi_region            = false

  # Root user explicitly allowed; no deny on root per SOC 2 WORM requirement
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccountPermissions"
        Effect = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudTrailEncrypt"
        Effect = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action   = ["kms:GenerateDataKey*", "kms:Describe*"]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-cloudtrail-key"
    Purpose = "CloudTrailEncryption"
  })
}

resource "aws_kms_alias" "cloudtrail" {
  count         = var.enable_cloudtrail_key ? 1 : 0
  name          = var.cloudtrail_key_alias
  target_key_id = aws_kms_key.cloudtrail[0].key_id
}

resource "aws_kms_key" "secrets" {
  count = var.enable_secrets_key ? 1 : 0

  description             = "KMS CMK for Secrets Manager encryption — ${var.name_prefix}"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  multi_region            = false

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccountPermissions"
        Effect = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-secrets-key"
    Purpose = "SecretsManagerEncryption"
  })
}

resource "aws_kms_alias" "secrets" {
  count         = var.enable_secrets_key ? 1 : 0
  name          = var.secrets_key_alias
  target_key_id = aws_kms_key.secrets[0].key_id
}

data "aws_caller_identity" "current" {}
