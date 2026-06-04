variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "S3 artifacts bucket name"
  type        = string
}

variable "solutions_table_name" {
  description = "DynamoDB Solutions table name"
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
