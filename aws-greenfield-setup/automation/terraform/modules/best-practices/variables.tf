variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "budgets_enabled" {
  description = "Enable AWS Budgets"
  type        = bool
  default     = true
}

variable "monthly_budget_usd" {
  description = "Monthly budget limit in USD"
  type        = number
  default     = 3000
}

variable "budget_alert_thresholds" {
  description = "Percentage thresholds for budget alerts"
  type        = list(number)
  default     = [80, 100]
}

variable "budget_alert_emails" {
  description = "Email addresses for budget alerts"
  type        = list(string)
  default     = []
}

variable "budget_sns_topic_arns" {
  description = "SNS topic ARNs for budget alert delivery"
  type        = list(string)
  default     = []
}

variable "cost_anomaly_detection_enabled" {
  description = "Enable AWS Cost Anomaly Detection"
  type        = bool
  default     = true
}

variable "anomaly_threshold_usd" {
  description = "Dollar threshold for Cost Anomaly Detection alerts"
  type        = number
  default     = 100
}

variable "sns_topic_arn_medium" {
  description = "SNS topic ARN for MEDIUM (P3) alerts"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
