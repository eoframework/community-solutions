variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "codepipeline_name" {
  description = "CodePipeline pipeline name"
  type        = string
}

variable "codebuild_compute_type" {
  description = "CodeBuild compute type"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "terraform_validate_gate" {
  description = "Enforce terraform validate in CodeBuild CI"
  type        = bool
  default     = true
}

variable "ecr_repository_url" {
  description = "ECR repository URL for Docker images"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ECR repository ARN"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for artifact encryption"
  type        = string
}

variable "artifact_bucket_name" {
  description = "S3 bucket name for pipeline artifacts"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
