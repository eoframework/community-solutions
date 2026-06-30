variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "multi_region_keys" {
  description = "Create multi-region KMS keys for cross-region replication"
  type        = bool
  default     = false
}

variable "enable_cloudtrail" {
  description = "Enable CloudTrail HIPAA audit logging"
  type        = bool
  default     = true
}

variable "enable_waf" {
  description = "Enable AWS WAF WebACL"
  type        = bool
  default     = true
}

variable "enable_guardduty" {
  description = "Enable Amazon GuardDuty"
  type        = bool
  default     = true
}

variable "enable_security_hub" {
  description = "Enable AWS Security Hub"
  type        = bool
  default     = true
}

variable "enable_macie" {
  description = "Enable Amazon Macie for PHI data classification"
  type        = bool
  default     = true
}

variable "enable_access_analyzer" {
  description = "Enable IAM Access Analyzer"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
