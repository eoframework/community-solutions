variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "rate_limit_requests_per_ip_per_5_minutes" {
  description = "WAF rate limit per IP per 5-minute window (WAF minimum window)"
  type        = number
  default     = 500
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
