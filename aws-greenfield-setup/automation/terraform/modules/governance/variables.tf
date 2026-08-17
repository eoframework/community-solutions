variable "organizational_units" {
  description = "Map of Organizational Units to create"
  type = map(object({
    name      = string
    parent_id = string
  }))
  default = {}
}

variable "policies" {
  description = "Map of Organizations SCPs/RCPs to create"
  type = map(object({
    name        = string
    description = string
    content     = string
    type        = string
  }))
  default = {}
}

variable "policy_attachments" {
  description = "Map of policy-to-target attachments"
  type = map(object({
    policy_key = string
    target_id  = string
  }))
  default = {}
}

variable "sso_instance_arn" {
  description = "ARN of the IAM Identity Center instance"
  type        = string
}

variable "permission_sets" {
  description = "Map of IAM Identity Center permission sets"
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
