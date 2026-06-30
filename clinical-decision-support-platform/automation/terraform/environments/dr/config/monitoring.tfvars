#------------------------------------------------------------------------------
# Monitoring Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-30 01:10:29
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  # SNS topic ARN for CloudWatch operational alarms routing to PagerDuty on-call rotation
  cloudwatch_alarm_sns_topic = "[alarm-sns-topic-arn]"  # TODO: Replace with actual value
  # ALB 5xx error rate percentage threshold for Critical platform unavailability alarm
  cloudwatch_alb_5xx_alarm_threshold_pct = 5
  # CloudWatch operational dashboard name for the CDS Platform
  cloudwatch_dashboard_name = "medcore-cds-prod-health"
  # ECS Fargate task CPU utilization alarm threshold percentage triggering High alert
  cloudwatch_ecs_cpu_alarm_threshold_pct = 80
  # SageMaker endpoint P95 latency alarm threshold in milliseconds triggering Critical alert
  cloudwatch_latency_alarm_threshold_ms = 3000
  # Enable Datadog APM distributed tracing on ECS Fargate tasks and SageMaker endpoints
  datadog_apm_enabled = true
  # Number of hosts covered by Datadog APM subscription (ECS tasks + SageMaker instances)
  datadog_host_count = 20
  # Datadog site endpoint for APM agent configuration on ECS tasks and SageMaker hosts
  datadog_site = "datadoghq.com"
  # SECRET (PagerDuty routing key for SNS-to-PagerDuty on-call escalation): inject via Secrets Manager / SSM at deploy time
  pagerduty_integration_key = "SET_VIA_SECRETS_MANAGER"
  # Amazon QuickSight dashboard name for clinical outcomes and model performance monitoring
  quicksight_dashboard_name = "medcore-cds-outcomes"
  # Enable AWS X-Ray distributed tracing for end-to-end inference path latency visibility
  xray_enabled = true
}
