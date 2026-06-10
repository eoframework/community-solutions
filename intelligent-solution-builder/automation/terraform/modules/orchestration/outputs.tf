output "state_machine_arn" {
  description = "Step Functions state machine ARN"
  value       = aws_sfn_state_machine.generation_workflow.arn
}

output "state_machine_name" {
  description = "Step Functions state machine name"
  value       = aws_sfn_state_machine.generation_workflow.name
}

output "sfn_role_arn" {
  description = "IAM role ARN for Step Functions execution"
  value       = aws_iam_role.sfn.arn
}

output "log_group_name" {
  description = "CloudWatch log group name for Step Functions"
  value       = aws_cloudwatch_log_group.sfn.name
}
