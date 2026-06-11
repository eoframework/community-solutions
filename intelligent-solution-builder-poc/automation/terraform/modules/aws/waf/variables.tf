variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "rate_limit_requests_per_5_min" {
  description = "WAF rate limit per source IP per 5 minutes (AWS WAF uses 5-min windows)"
  type        = number
  default     = 5000
}

variable "log_retention_days" {
  description = "WAF log group retention days"
  type        = number
  default     = 365
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
