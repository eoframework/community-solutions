output "domain_id" {
  description = "OpenSearch domain identifier"
  value       = aws_opensearch_domain.main.domain_id
}

output "domain_name" {
  description = "OpenSearch domain name"
  value       = aws_opensearch_domain.main.domain_name
}

output "endpoint" {
  description = "OpenSearch domain VPC endpoint"
  value       = aws_opensearch_domain.main.endpoint
}

output "domain_arn" {
  description = "OpenSearch domain ARN"
  value       = aws_opensearch_domain.main.arn
}

output "security_group_id" {
  description = "Security group ID for the OpenSearch domain"
  value       = aws_security_group.opensearch.id
}
