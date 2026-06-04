variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "users_table_name" {
  description = "DynamoDB Users table name"
  type        = string
}

variable "solutions_table_name" {
  description = "DynamoDB Solutions table name"
  type        = string
}

variable "global_quota_table_name" {
  description = "DynamoDB GlobalQuota table name"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "S3 artifacts bucket name"
  type        = string
}

variable "guidance_bucket_name" {
  description = "S3 guidance bucket name"
  type        = string
}

variable "artifacts_prefix_raw" {
  description = "S3 prefix for raw artifacts"
  type        = string
  default     = "raw/"
}

variable "artifacts_prefix_converted" {
  description = "S3 prefix for converted artifacts"
  type        = string
  default     = "converted/"
}

variable "terraform_prefix" {
  description = "S3 prefix for Terraform bundles"
  type        = string
  default     = "terraform/"
}

variable "github_pat_secret_name" {
  description = "Secrets Manager secret name for GitHub PAT"
  type        = string
}

variable "bedrock_generation_model_id" {
  description = "Bedrock model ID for generation (Claude Sonnet)"
  type        = string
}

variable "bedrock_validation_model_id" {
  description = "Bedrock model ID for validation (Claude Haiku)"
  type        = string
}

variable "ssm_s3_artifacts_bucket_param" {
  description = "SSM parameter path for S3 artifacts bucket name"
  type        = string
}

variable "ssm_dynamodb_solutions_table_param" {
  description = "SSM parameter path for DynamoDB solutions table name"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
