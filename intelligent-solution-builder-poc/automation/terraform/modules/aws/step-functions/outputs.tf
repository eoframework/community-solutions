output "state_machine_arn" {
  description = "Step Functions state machine ARN"
  value       = aws_sfn_state_machine.main.arn
}

output "state_machine_name" {
  description = "Step Functions state machine name"
  value       = aws_sfn_state_machine.main.name
}

output "execution_role_arn" {
  description = "Step Functions IAM execution role ARN"
  value       = aws_iam_role.sfn.arn
}
