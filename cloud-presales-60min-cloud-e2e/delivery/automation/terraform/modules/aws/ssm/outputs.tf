output "s3_artifacts_bucket_param_arn" {
  description = "SSM parameter ARN for S3 artifacts bucket name"
  value       = aws_ssm_parameter.s3_artifacts_bucket.arn
}

output "dynamodb_solutions_table_param_arn" {
  description = "SSM parameter ARN for DynamoDB solutions table name"
  value       = aws_ssm_parameter.dynamodb_solutions_table.arn
}
