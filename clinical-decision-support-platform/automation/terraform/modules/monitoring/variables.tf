variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for SNS topic encryption"
  type        = string
}

variable "audit_bucket_id" {
  description = "S3 audit bucket name for AWS Config delivery"
  type        = string
}

variable "monitoring" {
  description = "Monitoring configuration"
  type = object({
    dashboard_name               = string
    kinesis_stream_name          = string
    ecs_cluster_name             = string
    latency_alarm_threshold_ms   = optional(number, 3000)
    ecs_cpu_alarm_threshold_pct  = optional(number, 80)
    alb_5xx_alarm_threshold_pct  = optional(number, 5)
    enable_config                = optional(bool, true)
    pagerduty_endpoint           = optional(string, null)
    xray_enabled                 = optional(bool, true)
  })
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
