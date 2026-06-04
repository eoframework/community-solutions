output "agent_image_project_name" {
  description = "CodeBuild agent image build project name"
  value       = aws_codebuild_project.agent_image.name
}

output "terraform_plan_project_name" {
  description = "CodeBuild Terraform plan gate project name"
  value       = aws_codebuild_project.terraform_plan.name
}

output "codebuild_role_arn" {
  description = "CodeBuild IAM execution role ARN"
  value       = aws_iam_role.codebuild.arn
}
