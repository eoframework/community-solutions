#------------------------------------------------------------------------------
# Security Module (Tier 2) - Outputs
#------------------------------------------------------------------------------

output "cloudtrail_bucket_arn" {
  description = "CloudTrail S3 bucket ARN"
  value       = module.cloudtrail_bucket.bucket_arn
}

output "classifier_policy_arn" {
  description = "IAM policy ARN for Classifier Lambda"
  value       = aws_iam_policy.classifier.arn
}

output "recommender_policy_arn" {
  description = "IAM policy ARN for Recommender Lambda"
  value       = aws_iam_policy.recommender.arn
}

output "autotagger_policy_arn" {
  description = "IAM policy ARN for Auto-Tagger Lambda"
  value       = aws_iam_policy.autotagger.arn
}
