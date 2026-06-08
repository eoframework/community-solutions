output "sagemaker_execution_role_arn" {
  description = "ARN of the SageMaker execution IAM role"
  value       = aws_iam_role.sagemaker_execution.arn
}

output "sagemaker_execution_role_name" {
  description = "Name of the SageMaker execution IAM role"
  value       = aws_iam_role.sagemaker_execution.name
}

output "model_registry_arn" {
  description = "SageMaker Model Registry package group ARN"
  value       = aws_sagemaker_model_package_group.main.arn
}

output "model_registry_name" {
  description = "SageMaker Model Registry package group name"
  value       = aws_sagemaker_model_package_group.main.model_package_group_name
}

output "sagemaker_security_group_id" {
  description = "Security group ID for SageMaker endpoint ENIs"
  value       = aws_security_group.sagemaker.id
}

output "retraining_schedule_name" {
  description = "EventBridge Scheduler schedule name for weekly retraining"
  value       = aws_scheduler_schedule.retraining.name
}
