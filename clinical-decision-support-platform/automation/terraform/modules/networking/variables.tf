variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for CloudWatch Logs encryption (flow logs)"
  type        = string
  default     = null
}

variable "network" {
  description = "VPC and networking configuration"
  type = object({
    vpc_cidr             = string
    public_subnet_cidrs  = list(string)
    app_subnet_cidrs     = list(string)
    data_subnet_cidrs    = list(string)
    availability_zones   = list(string)
    nat_gateway_count    = optional(number, 2)
    enable_privatelink   = optional(bool, true)
    flow_log_retention_days = optional(number, 90)
  })
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
