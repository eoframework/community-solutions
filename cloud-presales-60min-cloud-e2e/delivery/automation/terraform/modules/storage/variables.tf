variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
}

variable "storage" {
  description = "Storage configuration object"
  type = object({
    artifacts_bucket_name               = string
    artifacts_versioning_enabled        = bool
    artifacts_intelligent_tiering_days  = number
    artifacts_prefix_raw                = string
    artifacts_prefix_converted          = string
    terraform_prefix                    = string
    guidance_bucket_name                = string
    ecr_repository_name                 = string
    ecr_image_scan_on_push              = bool
  })
}

variable "operations" {
  description = "Operations configuration (for retention policies)"
  type = object({
    terraform_state_bucket_name      = string
    terraform_state_lock_table_name  = string
    backup_dynamodb_pitr_recovery_window_days = number
    backup_s3_version_retention_days          = number
    lambda_reserved_concurrency_total         = number
    codebuild_agent_image_project_name        = string
    codebuild_terraform_plan_project_name     = string
    ssm_s3_artifacts_bucket_param             = string
    ssm_dynamodb_solutions_table_param        = string
  })
}
