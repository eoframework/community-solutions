variable "stream_name" {
  description = "Kinesis Data Stream name"
  type        = string
}

variable "shard_count" {
  description = "Number of shards"
  type        = number
  default     = 10
}

variable "retention_hours" {
  description = "Data retention period in hours (24-168)"
  type        = number
  default     = 24
}

variable "kms_key_id" {
  description = "KMS key ID or ARN for stream encryption"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
