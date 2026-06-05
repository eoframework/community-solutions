variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "execution_timeout_seconds" {
  description = "Step Functions state machine execution timeout"
  type        = number
  default     = 3600
}

variable "lambda_function_arns" {
  description = "Map of Lambda function names to ARNs"
  type        = map(string)
}

variable "table_solution_state_name" {
  description = "DynamoDB solution state table name"
  type        = string
}

variable "artifact_bucket_name" {
  description = "S3 artifact bucket name"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for CloudWatch Logs encryption"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
