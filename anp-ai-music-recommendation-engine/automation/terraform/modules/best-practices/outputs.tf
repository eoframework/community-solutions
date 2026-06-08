output "codepipeline_role_arn" {
  description = "IAM role ARN for CodePipeline"
  value       = aws_iam_role.codepipeline.arn
}

output "codebuild_role_arn" {
  description = "IAM role ARN for CodeBuild"
  value       = aws_iam_role.codebuild.arn
}

output "config_recorder_id" {
  description = "AWS Config recorder ID (null when Config is disabled)"
  value       = var.aws_config_enabled ? aws_config_configuration_recorder.main[0].id : null
}
