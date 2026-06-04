variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "github_pat_secret_name" {
  description = "Secrets Manager secret name for the GitHub PAT"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
