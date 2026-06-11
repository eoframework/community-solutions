variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "dashboard_name" {
  description = "CloudWatch dashboard name"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID for SNS topic encryption"
  type        = string
  default     = "alias/aws/sns"
}

variable "api_name" {
  description = "API Gateway name for dashboard metrics"
  type        = string
  default     = ""
}

variable "step_functions_arn" {
  description = "Step Functions state machine ARN for dashboard metrics"
  type        = string
  default     = ""
}

variable "generation_queue_name" {
  description = "SQS generation queue name for dashboard"
  type        = string
  default     = ""
}

variable "dlq_name" {
  description = "SQS dead-letter queue name for dashboard"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
