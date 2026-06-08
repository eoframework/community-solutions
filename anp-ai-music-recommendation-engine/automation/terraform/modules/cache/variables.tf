variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "port" {
  description = "Redis port"
  type        = number
  default     = 6379
}

variable "playlist_ttl_seconds" {
  description = "TTL for cached playlists in seconds"
  type        = number
  default     = 600
}

variable "session_ttl_seconds" {
  description = "TTL for cached session context in seconds"
  type        = number
  default     = 1800
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ElastiCache subnet group"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "app_security_group_id" {
  description = "Application tier security group ID allowed inbound to Redis"
  type        = string
}

variable "user_data_kms_key_arn" {
  description = "KMS key ARN for ElastiCache at-rest encryption"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
