variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "cloudwatch_dashboard_api" {
  description = "CloudWatch dashboard name for API health"
  type        = string
}

variable "cloudwatch_dashboard_ml" {
  description = "CloudWatch dashboard name for ML pipeline metrics"
  type        = string
}

variable "cloudwatch_dashboard_business" {
  description = "CloudWatch dashboard name for business KPIs"
  type        = string
}

variable "alarm_playlist_latency_ms" {
  description = "API Gateway p95 latency threshold in ms"
  type        = number
  default     = 3000
}

variable "alarm_api_5xx_pct" {
  description = "API Gateway 5xx error rate percentage threshold"
  type        = number
  default     = 1
}

variable "alarm_sagemaker_error_pct" {
  description = "SageMaker ModelError percentage threshold"
  type        = number
  default     = 5
}

variable "alarm_dlq_message_count" {
  description = "SQS DLQ message count threshold"
  type        = number
  default     = 10
}

variable "xray_tracing_enabled" {
  description = "X-Ray tracing enabled flag (informational)"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 90
}

variable "canary_interval_minutes" {
  description = "CloudWatch Synthetics canary polling interval"
  type        = number
  default     = 5
}

variable "apigw_id" {
  description = "API Gateway REST API ID for dashboard metric dimensions"
  type        = string
}

variable "sagemaker_nlp_endpoint_name" {
  description = "SageMaker NLP endpoint name for alarm dimensions"
  type        = string
}

variable "sagemaker_audio_endpoint_name" {
  description = "SageMaker audio endpoint name for alarm dimensions"
  type        = string
}

variable "feedback_dlq_name" {
  description = "SQS DLQ name for alarm dimensions"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
