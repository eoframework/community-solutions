variable "function_name" {
  description = "Lambda function name"
  type        = string
}

variable "handler" {
  description = "Lambda handler (module.function)"
  type        = string
  default     = "handler.lambda_handler"
}

variable "runtime" {
  description = "Lambda runtime identifier"
  type        = string
  default     = "python3.12"
}

variable "memory_size" {
  description = "Lambda memory allocation in MB"
  type        = number
  default     = 512
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "alias_name" {
  description = "Lambda function alias name for blue-green deployment"
  type        = string
  default     = "live"
}

variable "provisioned_concurrency" {
  description = "Provisioned concurrency units (0 = disabled)"
  type        = number
  default     = 0
}

variable "reserved_concurrency" {
  description = "Reserved concurrency units (-1 = unreserved)"
  type        = number
  default     = -1
}

variable "environment_variables" {
  description = "Lambda environment variables (no secrets — use SSM/Secrets Manager paths)"
  type        = map(string)
  default     = {}
}

variable "additional_policy_statements" {
  description = "Additional IAM policy statements for the Lambda execution role"
  type        = any
  default     = []
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 30
}

variable "kms_key_arn" {
  description = "KMS key ARN for CloudWatch log group encryption"
  type        = string
  default     = null
}

variable "enable_xray" {
  description = "Enable AWS X-Ray active tracing"
  type        = bool
  default     = false
}

variable "filename" {
  description = "Path to the Lambda deployment package (placeholder for CI/CD)"
  type        = string
  default     = null
}

variable "source_code_hash" {
  description = "Base64-encoded SHA256 hash of the deployment package"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
