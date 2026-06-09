#------------------------------------------------------------------------------
# Integration Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-09 01:56:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

integration = {
  # Amazon Bedrock runtime endpoint URL for InvokeModel API calls
  bedrock_endpoint_url = "https://bedrock-runtime.us-east-1.amazonaws.com"
  # Expected monthly Bedrock token consumption ceiling used for cost monitoring alert threshold
  bedrock_monthly_token_budget = 200000
  # Cognito JWT access token expiry in seconds
  cognito_jwt_expiry_seconds = 3600
  # Amazon Cognito User Pool ARN for API Gateway JWT authorizer configuration
  cognito_user_pool_arn = "[cognito-user-pool-arn]"  # TODO: Replace with actual value
  # Amazon Cognito User Pool ID for JWT issuance and GET /recommend authorization
  cognito_user_pool_id = "[cognito-user-pool-id]"  # TODO: Replace with actual value
  # S3 prefix where Firebase catalog export files are uploaded for DynamoDB seeding
  firebase_export_s3_prefix = "catalog/"
}
