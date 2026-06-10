output "cloudtrail_id" {
  description = "CloudTrail trail ID"
  value       = var.enable_cloudtrail ? aws_cloudtrail.this[0].id : null
}

output "cloudtrail_arn" {
  description = "CloudTrail trail ARN"
  value       = var.enable_cloudtrail ? aws_cloudtrail.this[0].arn : null
}

output "cognito_export_lambda_arn" {
  description = "Cognito export Lambda ARN"
  value       = aws_lambda_function.cognito_export.arn
}

output "cognito_export_schedule" {
  description = "Cognito export EventBridge schedule"
  value       = aws_cloudwatch_event_rule.cognito_export.schedule_expression
}
