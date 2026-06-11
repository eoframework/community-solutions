variable "repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "image_tag_mutability" {
  description = "Image tag mutability: IMMUTABLE or MUTABLE"
  type        = string
  default     = "IMMUTABLE"
}

variable "kms_key_arn" {
  description = "KMS key ARN for repository encryption"
  type        = string
}

variable "force_delete" {
  description = "Allow repository deletion even if it contains images"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
