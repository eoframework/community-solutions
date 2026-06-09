variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS CMK for Lambda env encryption and SQS"
  type        = string
}

variable "lambda_memory_mb" {
  description = "Memory allocation in MB for the SIEM forwarding Lambda"
  type        = number
  default     = 1024
}

variable "lambda_timeout_seconds" {
  description = "Timeout in seconds for the SIEM forwarding Lambda"
  type        = number
  default     = 30
}

variable "reserved_concurrency" {
  description = "Reserved concurrency for the SIEM forwarding Lambda"
  type        = number
  default     = 10
}

variable "finding_severity_threshold" {
  description = "Minimum Security Hub finding severity to forward to SIEM"
  type        = string
  default     = "HIGH"
  validation {
    condition     = contains(["CRITICAL", "HIGH", "MEDIUM", "LOW", "INFORMATIONAL"], var.finding_severity_threshold)
    error_message = "finding_severity_threshold must be one of CRITICAL, HIGH, MEDIUM, LOW, INFORMATIONAL."
  }
}

variable "dlq_name" {
  description = "SQS dead-letter queue name for failed SIEM forwarding invocations"
  type        = string
}

variable "dlq_alarm_threshold" {
  description = "DLQ message count threshold above which a P1 alarm fires"
  type        = number
  default     = 0
}

variable "delivery_sla_minutes" {
  description = "Maximum end-to-end latency from Security Hub finding to SIEM ingestion in minutes"
  type        = number
  default     = 5
}

variable "log_level" {
  description = "Logging verbosity level for the Lambda function"
  type        = string
  default     = "info"
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention in days for SIEM Lambda log group"
  type        = number
  default     = 90
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
