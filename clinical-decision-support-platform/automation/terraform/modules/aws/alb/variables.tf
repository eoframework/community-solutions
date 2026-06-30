variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "alb_name_suffix" {
  description = "Suffix for ALB name (e.g. dashboard, fhir-inbound)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs (public) for ALB placement"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener"
  type        = string
}

variable "target_port" {
  description = "Port the target group listens on"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Path for ALB target group health checks"
  type        = string
  default     = "/api/v1/health"
}

variable "internal" {
  description = "Create internal ALB (true) or internet-facing (false)"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on the ALB"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
