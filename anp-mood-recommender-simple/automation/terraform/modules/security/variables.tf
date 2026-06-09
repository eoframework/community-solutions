#------------------------------------------------------------------------------
# Security Module (Tier 2) - Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Name prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment (prod, test, dr)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cloudtrail_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}

variable "enable_cloudtrail" {
  description = "Enable AWS CloudTrail"
  type        = bool
  default     = true
}

variable "catalog_table_name" {
  description = "DynamoDB catalog moods table name"
  type        = string
}

variable "user_history_table_name" {
  description = "DynamoDB user history table name"
  type        = string
}

variable "catalog_bucket_name" {
  description = "S3 catalog bucket name"
  type        = string
}

variable "catalog_prefix" {
  description = "S3 catalog prefix"
  type        = string
  default     = "catalog/"
}

variable "common_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
