#------------------------------------------------------------------------------
# Operations Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-09 01:56:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

operations = {
  # Target availability SLA percentage for the Production API endpoints
  availability_target_pct = "99.5"
  # Lambda function alias pointing to the active published version for blue-green deployments
  deployment_lambda_alias = "LIVE"
  # Lambda error rate percentage that triggers immediate rollback procedure during Production deployment
  deployment_rollback_trigger_error_pct = "10"
  # API Gateway p95 latency in milliseconds that triggers rollback during Production deployment
  deployment_rollback_trigger_latency_ms = 5000
  # Post-go-live hypercare support duration in weeks provided by nClouds
  hypercare_duration_weeks = 2
  # Prefix for CDK/CloudFormation stack names following the ANP<Component><Env>Stack convention
  iac_stack_prefix = "ANP"
  # Infrastructure as Code tool used for all AWS resource provisioning
  iac_tool = "cdk"
  # Recovery Point Objective in hours representing maximum acceptable data loss
  rpo_hours = 24
  # Recovery Time Objective in minutes for the Production environment
  rto_minutes = 60
  # P1 Production outage hypercare response time target in hours
  support_p1_response_hours = 4
  # P2 degraded functionality hypercare response time target in hours
  support_p2_response_hours = 8
  # Value for the CostCenter tag applied to all resources for engagement-level cost tracking
  tagging_cost_center = "OPP-2025-001"
  # Value for the ManagedBy tag indicating the IaC tool managing the resource
  tagging_managed_by = "cdk"
  # Value for the Project tag applied to all AWS resources for cost allocation and governance
  tagging_project = "ANPStreamingAI"
}
