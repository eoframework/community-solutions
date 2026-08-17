output "aft_state_bucket_id" {
  description = "Name of the AFT Terraform state S3 bucket"
  value       = module.aft_state_bucket.bucket_id
}

output "aft_state_bucket_arn" {
  description = "ARN of the AFT Terraform state S3 bucket"
  value       = module.aft_state_bucket.bucket_arn
}

output "aft_lock_table_name" {
  description = "Name of the AFT DynamoDB state lock table"
  value       = aws_dynamodb_table.aft_lock.name
}

output "aft_lock_table_arn" {
  description = "ARN of the AFT DynamoDB state lock table"
  value       = aws_dynamodb_table.aft_lock.arn
}
