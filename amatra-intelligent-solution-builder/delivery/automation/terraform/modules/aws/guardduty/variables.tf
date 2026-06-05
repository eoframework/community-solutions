variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "enabled" {
  description = "Enable GuardDuty detector"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
