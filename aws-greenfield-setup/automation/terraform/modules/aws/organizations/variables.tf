variable "organizational_units" {
  description = "Map of Organizational Units to create"
  type = map(object({
    name      = string
    parent_id = string
  }))
  default = {}
}

variable "policies" {
  description = "Map of Organizations policies to create"
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

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
