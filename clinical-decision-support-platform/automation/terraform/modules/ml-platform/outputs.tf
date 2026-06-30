output "sagemaker_execution_role_arn" {
  description = "SageMaker execution IAM role ARN"
  value       = aws_iam_role.sagemaker_execution.arn
}

output "sagemaker_execution_role_name" {
  description = "SageMaker execution IAM role name"
  value       = aws_iam_role.sagemaker_execution.name
}

output "model_registry_name" {
  description = "SageMaker Model Registry package group name"
  value       = aws_sagemaker_model_package_group.this.model_package_group_name
}

output "feature_store_log_group" {
  description = "Feature Store CloudWatch log group name"
  value       = aws_cloudwatch_log_group.feature_store.name
}

output "ssm_sepsis_threshold_name" {
  description = "SSM parameter name for sepsis risk threshold"
  value       = aws_ssm_parameter.sepsis_risk_threshold.name
}

output "ssm_bedrock_model_id_name" {
  description = "SSM parameter name for Bedrock model ID"
  value       = aws_ssm_parameter.bedrock_model_id.name
}
