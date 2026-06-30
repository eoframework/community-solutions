variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "service_name" {
  description = "ECS service name suffix"
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

variable "subnet_ids" {
  description = "Private application subnet IDs for Fargate tasks"
  type        = list(string)
}

variable "alb_security_group_ids" {
  description = "ALB security group IDs allowed to reach ECS tasks"
  type        = list(string)
  default     = []
}

variable "target_group_arn" {
  description = "ALB target group ARN to register ECS service"
  type        = string
  default     = null
}

variable "container_image" {
  description = "Docker image URI for the container"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8080
}

variable "task_cpu" {
  description = "CPU units for the Fargate task"
  type        = number
  default     = 2048
}

variable "task_memory_mb" {
  description = "Memory in MB for the Fargate task"
  type        = number
  default     = 4096
}

variable "min_capacity" {
  description = "Minimum ECS task count"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum ECS task count"
  type        = number
  default     = 12
}

variable "kms_key_arn" {
  description = "KMS key ARN for CloudWatch Logs encryption"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 90
}

variable "secrets_arns" {
  description = "List of Secrets Manager / SSM ARNs the task execution role may read"
  type        = list(string)
  default     = ["arn:aws:secretsmanager:*:*:secret:medcore-cds-*"]
}

variable "environment_variables" {
  description = "Environment variables for the container (non-secret)"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
