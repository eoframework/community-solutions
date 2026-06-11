variable "state_machine_name" {
  description = "Step Functions state machine name"
  type        = string
}

variable "definition" {
  description = "Amazon States Language JSON definition"
  type        = string
}

variable "enable_xray_tracing" {
  description = "Enable AWS X-Ray tracing"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for CloudWatch log group encryption"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 365
}

variable "iam_policy_statements" {
  description = "Additional IAM policy statements for the Step Functions execution role"
  type        = any
  default     = []
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
