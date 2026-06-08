variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_config_enabled" {
  description = "Enable AWS Config for compliance monitoring"
  type        = bool
  default     = true
}

variable "security_hub_enabled" {
  description = "Enable AWS Security Hub"
  type        = bool
  default     = true
}

variable "codepipeline_name" {
  description = "AWS CodePipeline name for Lambda and infrastructure deployments"
  type        = string
}

variable "codebuild_compute_type" {
  description = "AWS CodeBuild compute type"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for compliance and operational notifications"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
