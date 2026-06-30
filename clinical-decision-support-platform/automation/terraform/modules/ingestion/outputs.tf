output "kinesis_stream_arn" {
  description = "Kinesis stream ARN"
  value       = module.kinesis.stream_arn
}

output "kinesis_stream_name" {
  description = "Kinesis stream name"
  value       = module.kinesis.stream_name
}

output "kinesis_dlq_arn" {
  description = "Kinesis DLQ ARN"
  value       = module.kinesis.dlq_arn
}

output "msk_cluster_arn" {
  description = "MSK cluster ARN"
  value       = module.msk.cluster_arn
}

output "msk_bootstrap_brokers_tls" {
  description = "MSK TLS bootstrap brokers"
  value       = module.msk.bootstrap_brokers_tls
}

output "msk_security_group_id" {
  description = "MSK security group ID"
  value       = module.msk.security_group_id
}
