variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS CMK for Lambda env encryption"
  type        = string
}

variable "lambda_memory_mb" {
  description = "Memory allocation in MB for the Config remediation Lambda"
  type        = number
  default     = 512
}

variable "max_concurrency" {
  description = "Maximum concurrency for Config auto-remediation Lambda (blast radius control)"
  type        = number
  default     = 20
}

variable "log_level" {
  description = "Logging verbosity level for the Lambda function"
  type        = string
  default     = "info"
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 90
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
