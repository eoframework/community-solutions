variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "github_pat_secret_name" {
  description = "Secrets Manager secret name for GitHub PAT"
  type        = string
}

variable "cognito_secret_name" {
  description = "Secrets Manager secret name for Cognito App Client secret"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for secret encryption"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
