variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "function_name_suffix" {
  description = "Suffix appended to function name (e.g. api-handler, github-push)"
  type        = string
}

variable "description" {
  description = "Lambda function description"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Deployment environment (dev, production, etc.)"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime identifier"
  type        = string
  default     = "python3.12"
}

variable "handler" {
  description = "Lambda handler (module.function)"
  type        = string
  default     = "handler.lambda_handler"
}

variable "package_type" {
  description = "Lambda deployment package type (Zip or Image)"
  type        = string
  default     = "Zip"

  validation {
    condition     = contains(["Zip", "Image"], var.package_type)
    error_message = "package_type must be Zip or Image."
  }
}

variable "image_uri" {
  description = "ECR image URI for container image Lambda functions"
  type        = string
  default     = ""
}

variable "memory_mb" {
  description = "Lambda memory in MB"
  type        = number
  default     = 256
}

variable "timeout_seconds" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "architecture" {
  description = "Lambda CPU architecture"
  type        = string
  default     = "arm64"

  validation {
    condition     = contains(["x86_64", "arm64"], var.architecture)
    error_message = "architecture must be x86_64 or arm64."
  }
}

variable "environment_variables" {
  description = "Lambda environment variables (no secrets)"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID for Lambda VPC attachment (empty string to skip VPC)"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Subnet IDs for Lambda VPC attachment"
  type        = list(string)
  default     = []
}

variable "xray_tracing_mode" {
  description = "X-Ray tracing mode"
  type        = string
  default     = "Active"

  validation {
    condition     = contains(["Active", "PassThrough"], var.xray_tracing_mode)
    error_message = "xray_tracing_mode must be Active or PassThrough."
  }
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 90
}

variable "policy_json" {
  description = "IAM policy JSON to attach to the Lambda execution role (empty string to skip)"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
