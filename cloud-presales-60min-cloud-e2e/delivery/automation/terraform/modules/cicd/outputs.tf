output "codebuild_agent_image_project_name" {
  description = "CodeBuild agent image build project name"
  value       = aws_codebuild_project.agent_image.name
}

output "codebuild_agent_image_project_arn" {
  description = "CodeBuild agent image build project ARN"
  value       = aws_codebuild_project.agent_image.arn
}

output "codebuild_terraform_plan_project_name" {
  description = "CodeBuild Terraform plan gate project name"
  value       = aws_codebuild_project.terraform_plan.name
}

output "codebuild_terraform_plan_project_arn" {
  description = "CodeBuild Terraform plan gate project ARN"
  value       = aws_codebuild_project.terraform_plan.arn
}

output "codebuild_role_arn" {
  description = "CodeBuild IAM role ARN"
  value       = aws_iam_role.codebuild.arn
}
