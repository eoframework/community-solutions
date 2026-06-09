output "pipeline_name" {
  description = "Name of the AFT account vending CodePipeline"
  value       = aws_codepipeline.aft.name
}

output "pipeline_arn" {
  description = "ARN of the AFT account vending CodePipeline"
  value       = aws_codepipeline.aft.arn
}

output "lambda_role_arn" {
  description = "ARN of the AFT Lambda execution role"
  value       = aws_iam_role.aft_lambda.arn
}

output "log_group_name" {
  description = "CloudWatch Log Group name for AFT pipeline"
  value       = aws_cloudwatch_log_group.aft_pipeline.name
}
