#------------------------------------------------------------------------------
# AFT (Account Factory for Terraform) Module (Tier 2)
# Composes: aws/s3
# Manages: AFT pipeline infrastructure, Terraform state backend for AFT,
#          CodePipeline/CodeBuild configuration references
#------------------------------------------------------------------------------

# S3 bucket for AFT Terraform state (separate from landing zone state)
module "aft_state_bucket" {
  source = "../aws/s3"

  bucket_name        = var.aft_state_bucket_name
  versioning_enabled = true
  kms_key_arn        = var.kms_key_arn
  force_destroy      = false

  lifecycle_rules = [
    {
      id      = "version-retention"
      enabled = true
      prefix  = ""
      noncurrent_version_expiration_days = 90
    }
  ]

  common_tags = merge(var.common_tags, { Purpose = "AFTState" })
}

# DynamoDB table for AFT Terraform state locking
resource "aws_dynamodb_table" "aft_lock" {
  name         = var.aft_lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  tags = merge(var.common_tags, { Name = var.aft_lock_table_name, Purpose = "AFTStateLock" })
}

# SSM Parameters for AFT configuration (non-sensitive values)
resource "aws_ssm_parameter" "aft_terraform_version" {
  name  = "/aft/config/terraform-version"
  type  = "String"
  value = var.aft_terraform_version
  tags  = merge(var.common_tags, { Name = "aft-terraform-version" })
}

resource "aws_ssm_parameter" "aft_vending_sla" {
  name  = "/aft/config/vending-sla-minutes"
  type  = "String"
  value = tostring(var.aft_vending_sla_minutes)
  tags  = merge(var.common_tags, { Name = "aft-vending-sla-minutes" })
}

resource "aws_ssm_parameter" "aft_codebuild_compute" {
  name  = "/aft/config/codebuild-compute-type"
  type  = "String"
  value = var.aft_codebuild_compute_type
  tags  = merge(var.common_tags, { Name = "aft-codebuild-compute-type" })
}

resource "aws_ssm_parameter" "aft_max_concurrent_vending" {
  name  = "/aft/config/max-concurrent-vending"
  type  = "String"
  value = tostring(var.aft_max_concurrent_vending)
  tags  = merge(var.common_tags, { Name = "aft-max-concurrent-vending" })
}
