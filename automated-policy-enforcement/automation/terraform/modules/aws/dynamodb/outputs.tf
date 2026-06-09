output "aft_workflow_table_name" {
  description = "Name of the AFT workflow DynamoDB table"
  value       = aws_dynamodb_table.aft_workflow.name
}

output "aft_workflow_table_arn" {
  description = "ARN of the AFT workflow DynamoDB table"
  value       = aws_dynamodb_table.aft_workflow.arn
}

output "tf_state_lock_table_name" {
  description = "Name of the Terraform state lock DynamoDB table"
  value       = aws_dynamodb_table.tf_state_lock.name
}

output "tf_state_lock_table_arn" {
  description = "ARN of the Terraform state lock DynamoDB table"
  value       = aws_dynamodb_table.tf_state_lock.arn
}
