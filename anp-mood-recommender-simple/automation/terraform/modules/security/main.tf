#------------------------------------------------------------------------------
# Security Module (Tier 2) - IAM + CloudTrail + Secrets Manager references
# Calls: aws/s3 (CloudTrail bucket)
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# CloudTrail audit bucket
#------------------------------------------------------------------------------
module "cloudtrail_bucket" {
  source = "../aws/s3"

  bucket_name        = var.cloudtrail_bucket_name
  versioning_enabled = false
  sse_algorithm      = "AES256"
  common_tags        = var.common_tags
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = module.cloudtrail_bucket.bucket_id

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
        Resource = module.cloudtrail_bucket.bucket_arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${module.cloudtrail_bucket.bucket_arn}/AWSLogs/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })

  depends_on = [module.cloudtrail_bucket]
}

#------------------------------------------------------------------------------
# CloudTrail
#------------------------------------------------------------------------------
resource "aws_cloudtrail" "this" {
  count = var.enable_cloudtrail ? 1 : 0

  name                          = "${var.name_prefix}-trail"
  s3_bucket_name                = module.cloudtrail_bucket.bucket_id
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_log_file_validation    = true

  tags = var.common_tags

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}

#------------------------------------------------------------------------------
# Classifier Lambda IAM Policy
#------------------------------------------------------------------------------
resource "aws_iam_policy" "classifier" {
  name        = "${var.name_prefix}-classifier-policy"
  description = "Least-privilege policy for Classifier Lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BedrockInvokeModel"
        Effect = "Allow"
        Action = ["bedrock:InvokeModel"]
        Resource = [
          "arn:aws:bedrock:${var.aws_region}::foundation-model/*"
        ]
      },
      {
        Sid    = "SecretsManagerRead"
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue"]
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:*:secret:anp/${var.environment}/*"
        ]
      },
    ]
  })

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Recommender Lambda IAM Policy
#------------------------------------------------------------------------------
resource "aws_iam_policy" "recommender" {
  name        = "${var.name_prefix}-recommender-policy"
  description = "Least-privilege policy for Recommender Lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:Query",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
        ]
        Resource = [
          "arn:aws:dynamodb:${var.aws_region}:*:table/${var.catalog_table_name}",
          "arn:aws:dynamodb:${var.aws_region}:*:table/${var.catalog_table_name}/index/*",
          "arn:aws:dynamodb:${var.aws_region}:*:table/${var.user_history_table_name}",
          "arn:aws:dynamodb:${var.aws_region}:*:table/${var.user_history_table_name}/index/*",
        ]
      },
    ]
  })

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Auto-Tagger Lambda IAM Policy
#------------------------------------------------------------------------------
resource "aws_iam_policy" "autotagger" {
  name        = "${var.name_prefix}-autotagger-policy"
  description = "Least-privilege policy for Auto-Tagger Lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "S3GetObject"
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = ["arn:aws:s3:::${var.catalog_bucket_name}/${var.catalog_prefix}*"]
      },
      {
        Sid    = "BedrockInvokeModel"
        Effect = "Allow"
        Action = ["bedrock:InvokeModel"]
        Resource = [
          "arn:aws:bedrock:${var.aws_region}::foundation-model/*"
        ]
      },
      {
        Sid    = "DynamoDBWrite"
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
        ]
        Resource = [
          "arn:aws:dynamodb:${var.aws_region}:*:table/${var.catalog_table_name}",
        ]
      },
    ]
  })

  tags = var.common_tags
}
