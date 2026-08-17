variable "budget_name" {
  description = "Name of the AWS Budget"
  type        = string
}

variable "monthly_limit_usd" {
  description = "Monthly budget limit in USD"
  type        = number
}

variable "alert_thresholds" {
  description = "List of percentage thresholds for budget alerts"
  type        = list(number)
  default     = [80, 100]
}

variable "alert_emails" {
  description = "List of email addresses for budget alerts"
  type        = list(string)
  default     = []
}

variable "sns_topic_arns" {
  description = "List of SNS topic ARNs for budget alert delivery"
  type        = list(string)
  default     = []
}
