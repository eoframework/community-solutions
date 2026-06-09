output "aft_pipeline_role_arn" {
  description = "ARN of the AFT pipeline execution IAM role"
  value       = aws_iam_role.aft_pipeline.arn
}

output "siem_api_key_secret_arn" {
  description = "ARN of the Secrets Manager secret for SIEM API key"
  value       = aws_secretsmanager_secret.siem_api_key.arn
}

output "itsm_oauth_secret_arn" {
  description = "ARN of the Secrets Manager secret for ITSM OAuth client secret"
  value       = aws_secretsmanager_secret.itsm_oauth_secret.arn
}

output "saml_signing_cert_secret_arn" {
  description = "ARN of the Secrets Manager secret for SAML signing certificate"
  value       = aws_secretsmanager_secret.saml_signing_cert.arn
}

output "siem_api_endpoint_secret_arn" {
  description = "ARN of the Secrets Manager secret for SIEM API endpoint"
  value       = aws_secretsmanager_secret.siem_api_endpoint.arn
}

output "itsm_api_endpoint_secret_arn" {
  description = "ARN of the Secrets Manager secret for ITSM API endpoint"
  value       = aws_secretsmanager_secret.itsm_api_endpoint.arn
}

output "itsm_oauth_client_id_secret_arn" {
  description = "ARN of the Secrets Manager secret for ITSM OAuth client ID"
  value       = aws_secretsmanager_secret.itsm_oauth_client_id.arn
}
