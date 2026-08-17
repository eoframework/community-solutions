variable "enabled" {
  description = "Enable GuardDuty detector"
  type        = bool
  default     = true
}

variable "detector_name" {
  description = "Friendly name tag for the detector"
  type        = string
  default     = "guardduty-detector"
}

variable "delegated_admin_account_id" {
  description = "AWS account ID for the GuardDuty delegated administrator. Null skips delegation."
  type        = string
  default     = null
}

variable "enable_s3_logs" {
  description = "Enable S3 data source in GuardDuty"
  type        = bool
  default     = true
}

variable "enable_kubernetes_logs" {
  description = "Enable Kubernetes audit logs data source"
  type        = bool
  default     = false
}

variable "enable_malware_protection" {
  description = "Enable malware protection for EBS volumes"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
