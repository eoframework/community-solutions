variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "models_bucket_arn" {
  description = "ARN of the SageMaker model artefacts S3 bucket"
  type        = string
}

variable "datalake_bucket_arn" {
  description = "ARN of the data lake S3 bucket"
  type        = string
}

variable "kms_s3_key_arn" {
  description = "KMS key ARN for S3 data lake encryption"
  type        = string
}

variable "kms_ebs_key_arn" {
  description = "KMS key ARN for EBS / CloudWatch Logs encryption"
  type        = string
}

variable "ml" {
  description = "ML Platform configuration"
  type = object({
    registry_name                       = string
    bedrock_model_id                    = string
    bedrock_prompt_template_version     = optional(string, "v1.0")
    sepsis_risk_score_alert_threshold   = optional(number, 0.7)
    feature_completeness_threshold      = optional(number, 0.8)
    duplicate_suppression_ttl_seconds   = optional(number, 1800)
    cloudwatch_log_retention_days       = optional(number, 90)
  })
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
