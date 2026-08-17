variable "log_groups" {
  description = "Map of CloudWatch Log Groups to create"
  type = map(object({
    name              = string
    retention_in_days = number
  }))
  default = {}
}

variable "kms_key_arn" {
  description = "KMS key ARN for log group encryption"
  type        = string
  default     = null
}

variable "dashboards" {
  description = "Map of CloudWatch dashboards to create"
  type = map(object({
    name = string
    body = string
  }))
  default = {}
}

variable "metric_alarms" {
  description = "Map of CloudWatch metric alarms to create"
  type = map(object({
    alarm_name          = string
    comparison_operator = string
    evaluation_periods  = number
    metric_name         = string
    namespace           = string
    period              = number
    statistic           = string
    threshold           = number
    alarm_description   = optional(string)
    alarm_actions       = optional(list(string), [])
    ok_actions          = optional(list(string), [])
    dimensions          = optional(map(string), {})
    treat_missing_data  = optional(string, "missing")
  }))
  default = {}
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
