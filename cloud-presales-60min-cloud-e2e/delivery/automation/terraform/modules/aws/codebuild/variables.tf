variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "agent_image_project_name" {
  description = "CodeBuild project name for agent Docker image build pipeline"
  type        = string
}

variable "terraform_plan_project_name" {
  description = "CodeBuild project name for Terraform plan gate"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL for pushing agent images"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "S3 artifacts bucket name for CodeBuild cache"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
