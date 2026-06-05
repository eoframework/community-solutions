variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "image_retention_count" {
  description = "Number of most-recent tagged images to retain"
  type        = number
  default     = 3
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
