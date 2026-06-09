#------------------------------------------------------------------------------
# AWS Lambda Function - Variables
#------------------------------------------------------------------------------

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "handler" {
  description = "Lambda function handler (file.method)"
  type        = string
  default     = "handler.lambda_handler"
}

variable "runtime" {
  description = "Lambda runtime identifier"
  type        = string
  default     = "python3.12"
}

variable "memory_mb" {
  description = "Memory allocation in MB"
  type        = number
  default     = 512
}

variable "timeout_seconds" {
  description = "Function timeout in seconds"
  type        = number
  default     = 30
}

variable "deployment_package_path" {
  description = "Path to the Lambda deployment ZIP package (leave empty to use placeholder)"
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Map of environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "inline_policy_json" {
  description = "Inline IAM policy JSON to attach to the Lambda execution role"
  type        = string
  default     = ""
}

variable "enable_xray" {
  description = "Enable AWS X-Ray tracing"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 90
}

variable "common_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
