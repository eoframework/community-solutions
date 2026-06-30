variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "Private application subnet IDs for ECS tasks"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ACM certificate ARN for ALB HTTPS listeners"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for CloudWatch Logs encryption"
  type        = string
}

variable "secrets_arns" {
  description = "Secrets Manager ARNs the ECS task execution role may access"
  type        = list(string)
  default     = ["arn:aws:secretsmanager:*:*:secret:medcore-cds-*"]
}

variable "compute" {
  description = "Compute configuration parameters"
  type = object({
    ecs_cluster_name          = string
    ecs_task_cpu              = optional(number, 2048)
    ecs_task_memory_mb        = optional(number, 4096)
    ecs_scaling_min           = optional(number, 4)
    ecs_scaling_max           = optional(number, 12)
    app_port                  = optional(number, 8080)
    log_level                 = optional(string, "info")
    log_retention_days        = optional(number, 90)
    enable_deletion_protection = optional(bool, true)
    dashboard_container_image = optional(string, "public.ecr.aws/amazonlinux/amazonlinux:latest")
    api_container_image       = optional(string, "public.ecr.aws/amazonlinux/amazonlinux:latest")
  })
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
