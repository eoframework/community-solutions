#------------------------------------------------------------------------------
# Tier 1: AWS SSM Parameter Store — Runtime configuration for Lambda functions
# Lambda functions read bucket/table names from SSM at init to avoid hard-coding
#------------------------------------------------------------------------------

resource "aws_ssm_parameter" "s3_artifacts_bucket" {
  name        = var.ssm_s3_artifacts_bucket_param
  type        = "String"
  value       = var.artifacts_bucket_name
  description = "S3 artifacts bucket name for Lambda runtime configuration"
  tags        = var.common_tags
}

resource "aws_ssm_parameter" "dynamodb_solutions_table" {
  name        = var.ssm_dynamodb_solutions_table_param
  type        = "String"
  value       = var.solutions_table_name
  description = "DynamoDB Solutions table name for Lambda runtime configuration"
  tags        = var.common_tags
}
