variable "function_name" {
  description = "Lambda function name"
  type        = string
}

variable "image_uri" {
  description = "ECR container image URI (account.dkr.ecr.region.amazonaws.com/repo:tag)"
  type        = string
}

variable "architecture" {
  description = "Lambda CPU architecture"
  type        = string
  default     = "arm64"
}

variable "memory_size" {
  description = "Lambda memory in MB"
  type        = number
  default     = 512
}

variable "timeout_seconds" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "reserved_concurrency" {
  description = "Reserved concurrency (-1 = unreserved)"
  type        = number
  default     = -1
}

variable "provisioned_concurrency" {
  description = "Provisioned concurrency (0 = disabled)"
  type        = number
  default     = 0
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "log_level" {
  description = "Logging verbosity (debug|info|warn|error)"
  type        = string
  default     = "info"
}

variable "app_version" {
  description = "Application version for health-check responses"
  type        = string
  default     = "1.0.0"
}

variable "environment_variables" {
  description = "Additional Lambda environment variables"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "VPC subnet IDs for Lambda execution"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "VPC security group IDs for Lambda execution"
  type        = list(string)
  default     = []
}

variable "enable_xray_tracing" {
  description = "Enable AWS X-Ray active tracing"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for CloudWatch Log Group encryption"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 365
}

variable "iam_policy_statements" {
  description = "Additional IAM policy statements for the Lambda execution role"
  type        = any
  default     = []
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
