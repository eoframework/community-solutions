#------------------------------------------------------------------------------
# Operations Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-08 21:29:43
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

operations = {
  # Enable AWS Config with managed rules for compliance checking
  aws_config_enabled = true
  # AWS CodeBuild compute type for build and unit-test stages
  codebuild_compute_type = "BUILD_GENERAL1_SMALL"
  # AWS CodePipeline name for Lambda and infrastructure deployments
  codepipeline_name = "anp-dev-deployment-pipeline"
  # Maximum reserved concurrent Lambda executions per function
  lambda_max_concurrency = 50
  # Recovery Point Objective in hours representing maximum acceptable data loss
  rpo_hours = 1
  # Recovery Time Objective in hours for full service restoration
  rto_hours = 4
  # Minimum SageMaker endpoint instance count for NLP and audio endpoints
  sagemaker_min_instances = 1
  # Endpoint invocations-per-second utilization percentage triggering scale-out
  sagemaker_scale_threshold_pct = 70
  # Enable AWS Security Hub for aggregated GuardDuty and Config findings
  security_hub_enabled = false
  # AWS Support Plan tier for the ANP Streaming account
  support_plan = "developer"
  # Value for the Application resource tag applied to all AWS resources
  tagging_application = "anp-recommendation-engine"
  # Value for the CostCenter resource tag applied to all AWS resources
  tagging_cost_center = "OPP-2026-001"
  # Value for the Environment resource tag applied to all AWS resources
  tagging_environment = "dev"
}
