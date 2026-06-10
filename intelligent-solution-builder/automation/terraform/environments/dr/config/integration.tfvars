#------------------------------------------------------------------------------
# Integration Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-10 02:56:40
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

integration = {
  # Custom domain name for the API Gateway endpoint
  api_gateway_custom_domain = "[api-custom-domain]"  # TODO: Replace with actual value
  # API Gateway REST API ID for the platform endpoint
  api_gateway_rest_api_id = "[api-gateway-rest-api-id]"  # TODO: Replace with actual value
  api_gateway_stage_name = "prod"  # API Gateway deployment stage name
  # API Gateway stage-level burst throttle limit in requests per second
  api_gateway_throttle_burst_rps = 500
  # API Gateway stage-level steady-state throttle limit in requests per second
  api_gateway_throttle_steady_rps = 200
  # Amazon Bedrock model ID for Claude 3 Haiku used for lightweight artifact types
  bedrock_haiku_model_id = "anthropic.claude-3-haiku-20240307-v1:0"
  # Monthly Bedrock input token budget across all artifact generation jobs
  bedrock_max_input_tokens_monthly = 10000000
  # Monthly Bedrock output token budget across all artifact generation jobs
  bedrock_max_output_tokens_monthly = 5000000
  # Initial retry interval in seconds for Bedrock invocation failures in Step Functions
  bedrock_retry_interval_seconds = 30
  # Maximum Step Functions retry attempts on Bedrock ThrottlingException or ServiceUnavailableException
  bedrock_retry_max_attempts = 3
  # Amazon Bedrock model ID for Claude 3 Sonnet used for complex artifact types
  bedrock_sonnet_model_id = "anthropic.claude-3-sonnet-20240229-v1:0"
  # SECRET (Datadog API key for Lambda layer APM agent telemetry and cold-start profiling): inject via Secrets Manager / SSM at deploy time
  datadog_api_key = "SET_VIA_SECRETS_MANAGER"
  # SECRET (IAM Role ARN assumed by GitHub Actions via OIDC for CI/CD deployments): inject via Secrets Manager / SSM at deploy time
  github_actions_oidc_role_arn = "SET_VIA_SECRETS_MANAGER"
  # Prefix path for all Secrets Manager secrets following convention amatra/{env}/{service}/{secret-name}
  secrets_manager_secret_prefix = "amatra/prod"
  # SQS Dead Letter Queue name for failed job messages after max receive attempts
  sqs_dlq_name = "amatra-isb-job-dlq-prod"
  # SQS Standard Queue name for async generation job messages
  sqs_job_queue_name = "amatra-isb-job-queue-prod"
  # Maximum number of times a message is received before moving to the DLQ
  sqs_max_receive_count = 3
  # SQS message retention period in seconds (4 days)
  sqs_message_retention_seconds = 345600
  # SQS visibility timeout in seconds for job queue messages
  sqs_visibility_timeout_seconds = 300
  # Step Functions execution history retention period in days
  stepfunctions_execution_history_days = 90
  # ARN of the AWS Step Functions Standard Workflow for async generation orchestration
  stepfunctions_state_machine_arn = "[step-functions-state-machine-arn]"  # TODO: Replace with actual value
}
