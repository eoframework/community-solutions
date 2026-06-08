variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "sagemaker_nlp_endpoint_name" {
  description = "SageMaker endpoint name for NLP classifier"
  type        = string
}

variable "sagemaker_nlp_instance_type" {
  description = "SageMaker instance type for NLP classifier endpoint"
  type        = string
  default     = "ml.t3.medium"
}

variable "sagemaker_audio_endpoint_name" {
  description = "SageMaker endpoint name for audio feature extractor"
  type        = string
}

variable "sagemaker_audio_instance_type" {
  description = "SageMaker instance type for audio feature extractor endpoint"
  type        = string
  default     = "ml.t3.medium"
}

variable "sagemaker_training_instance_type" {
  description = "SageMaker instance type for training jobs"
  type        = string
  default     = "ml.m5.xlarge"
}

variable "sagemaker_training_use_spot" {
  description = "Use Managed Spot Training for SageMaker training jobs"
  type        = bool
  default     = true
}

variable "sagemaker_min_instances" {
  description = "Minimum SageMaker endpoint instance count"
  type        = number
  default     = 1
}

variable "sagemaker_model_registry_name" {
  description = "SageMaker Model Registry package group name"
  type        = string
}

variable "sagemaker_max_versions_retained" {
  description = "Number of approved model versions to retain in the registry"
  type        = number
  default     = 3
}

variable "retraining_schedule_expression" {
  description = "EventBridge Scheduler cron expression for weekly retraining"
  type        = string
  default     = "cron(0 2 ? * MON *)"
}

variable "confidence_threshold" {
  description = "NLP classifier confidence threshold below which Bedrock fallback is used"
  type        = number
  default     = 0.75
}

variable "conditional_promotion" {
  description = "Promote new model only when accuracy exceeds previous version"
  type        = bool
  default     = true
}

variable "models_bucket_name" {
  description = "S3 bucket name for model artifacts"
  type        = string
}

variable "features_bucket_name" {
  description = "S3 bucket name for feature vectors"
  type        = string
}

variable "model_kms_key_arn" {
  description = "KMS key ARN for model artifact encryption"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for SageMaker security group"
  type        = string
}

variable "private_subnet_app_ids" {
  description = "Private application subnet IDs for SageMaker ENIs"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Application security group ID for inbound inference access"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
