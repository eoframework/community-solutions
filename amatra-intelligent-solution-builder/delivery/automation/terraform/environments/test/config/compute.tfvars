#------------------------------------------------------------------------------
# Compute Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-05 16:27:28
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

compute = {
  # Number of most-recent tagged ECR image versions retained
  ecr_image_retention_count = 3
  # ECR repository name for AgentCore agent Docker images
  ecr_repository_name = "amatra-agentcore"
  # Default Lambda function memory allocation in MB
  lambda_memory_mb = 512
  # Reserved Lambda concurrency units for platform functions
  lambda_reserved_concurrency = 10
  # Default Lambda function timeout in seconds
  lambda_timeout_seconds = 900
  # Step Functions state machine execution timeout in seconds
  stepfunctions_execution_timeout_seconds = 3600
}
