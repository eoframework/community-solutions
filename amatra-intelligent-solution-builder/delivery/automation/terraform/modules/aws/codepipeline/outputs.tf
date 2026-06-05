output "codepipeline_name" {
  description = "CodePipeline pipeline name"
  value       = aws_codepipeline.main.name
}

output "codepipeline_arn" {
  description = "CodePipeline pipeline ARN"
  value       = aws_codepipeline.main.arn
}

output "codebuild_project_name" {
  description = "CodeBuild project name"
  value       = aws_codebuild_project.main.name
}
