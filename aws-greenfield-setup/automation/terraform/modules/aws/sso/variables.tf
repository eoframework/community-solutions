variable "sso_instance_arn" {
  description = "ARN of the IAM Identity Center instance"
  type        = string
}

variable "permission_sets" {
  description = "Map of permission sets to create"
  type = map(object({
    name             = string
    description      = string
    session_duration = string
  }))
  default = {}
}

variable "managed_policy_attachments" {
  description = "Map of managed policy attachments to permission sets"
  type = map(object({
    permission_set_key = string
    managed_policy_arn = string
  }))
  default = {}
}

variable "inline_policies" {
  description = "Map of permission_set_key to inline policy JSON"
  type        = map(string)
  default     = {}
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
