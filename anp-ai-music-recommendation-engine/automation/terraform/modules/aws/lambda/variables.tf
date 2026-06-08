variable "function_name" {
  description = "Lambda function name"
  type        = string
}

variable "handler" {
  description = "Lambda function handler (file.method)"
  type        = string
  default     = "handler.handler"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}

variable "architecture" {
  description = "Lambda CPU architecture (arm64 or x86_64)"
  type        = string
  default     = "arm64"
}

variable "memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 256
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "reserved_concurrent_executions" {
  description = "Reserved concurrent executions (-1 = unreserved)"
  type        = number
  default     = -1
}

variable "execution_role_arn" {
  description = "IAM execution role ARN for the Lambda function"
  type        = string
}

variable "log_group_name" {
  description = "Pre-created CloudWatch log group name (module creates its own)"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 90
}

variable "xray_tracing" {
  description = "Enable AWS X-Ray active tracing"
  type        = bool
  default     = true
}

variable "vpc_subnet_ids" {
  description = "VPC subnet IDs for Lambda ENI placement"
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "Security group IDs for Lambda VPC configuration"
  type        = list(string)
  default     = []
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
