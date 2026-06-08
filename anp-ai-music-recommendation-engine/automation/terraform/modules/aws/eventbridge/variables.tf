variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "bus_name" {
  description = "EventBridge custom event bus name"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
