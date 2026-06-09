#------------------------------------------------------------------------------
# Application Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-09 01:56:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

application = {
  # Full base URL for the API Gateway REST endpoint provided to FlutterFlow team
  api_base_url = "[prod-apigw-url]"  # TODO: Replace with actual value
  # API Gateway stage name included in all endpoint URLs
  api_stage = "v1"
  # API Gateway integration timeout in seconds before returning 504 to caller
  api_timeout_seconds = 30
  log_level = "info"  # Lambda function logging verbosity level
  # Comma-separated list of valid mood classification labels returned by Bedrock
  mood_labels = ["Joyful,Reflective,Peaceful,Uplifting,Worshipful,Hopeful"]
  # Application identifier used in CloudWatch log group names and structured logs
  name = "anp-streaming-ai"
  # Default playlist item count returned by GET /recommend when limit param is omitted
  recommend_default_limit = 10
  # Maximum playlist item count the GET /recommend endpoint will return
  recommend_max_limit = 50
  # Current application version applied to Lambda function tags and log context
  version = "1.0.0"
}
