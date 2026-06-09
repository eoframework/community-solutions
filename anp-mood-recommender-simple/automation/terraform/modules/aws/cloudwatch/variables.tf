#------------------------------------------------------------------------------
# AWS CloudWatch - Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for alarm and topic names"
  type        = string
}

variable "classifier_function_name" {
  description = "Classifier Lambda function name"
  type        = string
}

variable "recommender_function_name" {
  description = "Recommender Lambda function name"
  type        = string
}

variable "autotagger_function_name" {
  description = "Auto-Tagger Lambda function name"
  type        = string
}

variable "autotagger_dlq_name" {
  description = "Auto-Tagger DLQ name"
  type        = string
}

variable "api_name" {
  description = "API Gateway REST API name"
  type        = string
}

variable "api_stage" {
  description = "API Gateway stage name"
  type        = string
  default     = "v1"
}

variable "catalog_table_name" {
  description = "DynamoDB catalog moods table name"
  type        = string
}

variable "lambda_error_threshold" {
  description = "Lambda error count threshold before alarm fires"
  type        = number
  default     = 1
}

variable "apigw_p95_latency_threshold_ms" {
  description = "API Gateway p95 latency threshold in milliseconds"
  type        = number
  default     = 2000
}

variable "apigw_5xx_threshold" {
  description = "API Gateway 5xx error count threshold"
  type        = number
  default     = 5
}

variable "dlq_depth_threshold" {
  description = "DLQ visible message count threshold"
  type        = number
  default     = 0
}

variable "dynamodb_throttle_threshold" {
  description = "DynamoDB throttle count threshold"
  type        = number
  default     = 0
}

variable "operations_dashboard_name" {
  description = "CloudWatch Operations dashboard name"
  type        = string
  default     = "ANP-Operations"
}

variable "cost_dashboard_name" {
  description = "CloudWatch Cost Tracking dashboard name"
  type        = string
  default     = "ANP-Cost-Tracking"
}

variable "common_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
