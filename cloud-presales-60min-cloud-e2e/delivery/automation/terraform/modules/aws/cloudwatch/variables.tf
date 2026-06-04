variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "dashboard_platform_health" {
  description = "CloudWatch dashboard name for platform health"
  type        = string
}

variable "dashboard_throughput" {
  description = "CloudWatch dashboard name for solution throughput"
  type        = string
}

variable "dashboard_cost_telemetry" {
  description = "CloudWatch dashboard name for Bedrock cost telemetry"
  type        = string
}

variable "dashboard_quota_utilisation" {
  description = "CloudWatch dashboard name for quota utilisation"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
