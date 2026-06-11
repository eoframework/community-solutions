variable "name_prefix" {
  description = "Resource name prefix (solution-abbr + environment)"
  type        = string
}

variable "enable_waf" {
  description = "Deploy WAF Web ACL"
  type        = bool
  default     = true
}

variable "waf_rate_limit_per_5_min" {
  description = "WAF rate limit per source IP per 5-minute window"
  type        = number
  default     = 5000
}

variable "log_retention_days" {
  description = "Log retention days for WAF logs"
  type        = number
  default     = 365
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
