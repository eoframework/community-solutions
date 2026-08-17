#------------------------------------------------------------------------------
# Monitoring Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-08-17 00:33:59
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

logging = {
  # Retention period in years for CloudTrail Lake event data store (queryable audit trail)
  cloudtrail_lake_retention_years = 7
  # S3 bucket name in the Log Archive account for CloudTrail log delivery
  cloudtrail_log_bucket_name = "[log-archive-cloudtrail-bucket]"  # TODO: Replace with actual value
  # S3 Object Lock compliance-mode minimum retention period in days; prevents log deletion
  cloudtrail_object_lock_retention_days = 90
  # Days to retain CloudTrail logs in S3 Standard storage before lifecycle transition to Glacier
  cloudtrail_s3_retention_days_standard = 90
  # Name of the CloudTrail organisation trail; naming follows ins-org-trail-{region-short} convention
  cloudtrail_trail_name = "ins-org-trail-use2"
  # Enable the AWS Foundational Security Best Practices conformance pack in all accounts
  config_conformance_pack_fsbp = true
  # Enable the NIST 800-53 Rev 5 conformance pack if confirmed by Client Security Lead
  config_conformance_pack_nist = true
  # S3 bucket name in Log Archive account for AWS Config snapshot and history delivery
  config_delivery_bucket_name = "[log-archive-config-bucket]"  # TODO: Replace with actual value
  # Enable AWS Config recording in all accounts and both regions
  config_recording_enabled = true
}

monitoring = {
  # CloudWatch dashboard name for the FinOps dashboard in Shared Services account
  cloudwatch_dashboard_name_finops = "ins-finops"
  # CloudWatch dashboard name for the Landing Zone Operations dashboard in Shared Services account
  cloudwatch_dashboard_name_ops = "ins-landing-zone-ops"
  # CloudWatch dashboard name for the Security Posture dashboard in Shared Services account
  cloudwatch_dashboard_name_security = "ins-security-posture"
  # Retention period in days for CloudWatch Log Groups created across the landing zone
  cloudwatch_log_retention_days = 90
  # GuardDuty finding severity threshold above which an SNS HIGH alert is triggered
  guardduty_alert_severity_threshold = "7.0"
  # AWS account ID of the GuardDuty delegated administrator (Audit account)
  guardduty_delegated_admin_account_id = "[audit-account-id]"  # TODO: Replace with actual value
  # Enable Amazon GuardDuty organisation-wide in both regions with delegated administrator
  guardduty_enabled = true
  # AWS account ID of the Security Hub delegated administrator (Audit account)
  securityhub_delegated_admin_account_id = "[audit-account-id]"  # TODO: Replace with actual value
  # Enable AWS Security Hub in all accounts and both regions with FSBP standard
  securityhub_enabled = true
  # Minimum Security Hub FSBP compliance score percentage required at go-live
  securityhub_fsbp_score_target = 80
  # Email address for SNS alert delivery; confirmed with client operations team at kick-off
  sns_alert_email_endpoint = "[ops-alert-email]"  # TODO: Replace with actual value
  # SNS topic ARN for CRITICAL (P1) alerts — CT drift and FSBP critical findings
  sns_topic_arn_critical = "[sns-topic-arn-critical]"  # TODO: Replace with actual value
  # SNS topic ARN for HIGH (P2) alerts — AFT pipeline failures and GuardDuty threats
  sns_topic_arn_high = "[sns-topic-arn-high]"  # TODO: Replace with actual value
  # SNS topic ARN for MEDIUM (P3) alerts — Config drift and budget threshold notifications
  sns_topic_arn_medium = "[sns-topic-arn-medium]"  # TODO: Replace with actual value
}
