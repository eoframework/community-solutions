variable "name_prefix" {
  description = "Naming prefix for all KMS resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment (prod, test, dr)"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

variable "enable_s3_key" {
  description = "Create a dedicated KMS CMK for S3 encryption"
  type        = bool
  default     = true
}

variable "enable_dynamodb_key" {
  description = "Create a dedicated KMS CMK for DynamoDB encryption"
  type        = bool
  default     = true
}

variable "enable_cloudtrail_key" {
  description = "Create a dedicated KMS CMK for CloudTrail log encryption"
  type        = bool
  default     = true
}

variable "enable_secrets_key" {
  description = "Create a dedicated KMS CMK for Secrets Manager encryption"
  type        = bool
  default     = true
}

variable "s3_key_alias" {
  description = "KMS alias for the S3 CMK"
  type        = string
  default     = ""
}

variable "dynamodb_key_alias" {
  description = "KMS alias for the DynamoDB CMK"
  type        = string
  default     = ""
}

variable "cloudtrail_key_alias" {
  description = "KMS alias for the CloudTrail CMK"
  type        = string
  default     = ""
}

variable "secrets_key_alias" {
  description = "KMS alias for the Secrets Manager CMK"
  type        = string
  default     = ""
}
