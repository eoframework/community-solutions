variable "name_prefix" {
  description = "Naming prefix for orchestration resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

variable "state_machine_name" {
  description = "Step Functions state machine name"
  type        = string
}

variable "sonnet_invoker_arn" {
  description = "Lambda ARN for Bedrock Sonnet invoker"
  type        = string
}

variable "haiku_invoker_arn" {
  description = "Lambda ARN for Bedrock Haiku invoker"
  type        = string
}

variable "artifact_processor_arn" {
  description = "Lambda ARN for artifact processor / QA scorer"
  type        = string
}

variable "prompt_assembly_arn" {
  description = "Lambda ARN for prompt assembly / orchestrator start"
  type        = string
}

variable "solution_state_table_name" {
  description = "DynamoDB solution state table name"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for log encryption"
  type        = string
}

variable "retry_max_attempts" {
  description = "Maximum Bedrock retry attempts on throttling"
  type        = number
  default     = 3
}

variable "retry_interval_seconds" {
  description = "Initial retry interval in seconds"
  type        = number
  default     = 30
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 30
}
