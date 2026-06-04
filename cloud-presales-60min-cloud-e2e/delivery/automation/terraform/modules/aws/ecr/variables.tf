variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "repository_name" {
  description = "ECR repository name for agent container images"
  type        = string
}

variable "image_scan_on_push" {
  description = "Enable vulnerability scanning on image push"
  type        = bool
  default     = true
}

variable "image_tag_policy" {
  description = "Image tag mutability policy"
  type        = string
  default     = "immutable-digest"
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
