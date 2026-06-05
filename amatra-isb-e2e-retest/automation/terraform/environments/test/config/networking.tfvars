#------------------------------------------------------------------------------
# Networking Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-05 19:11:53
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

networking = {
  # API Gateway HTTP API v2 regional endpoint base URL
  apigw_endpoint = "https://[apigw-id].execute-api.us-west-2.amazonaws.com"
  # API Gateway burst throttle limit in requests per second
  apigw_throttle_rps_burst = 100
  # NAT Gateways deployed in public subnets for Lambda outbound internet access
  nat_gateway_count = 1
  # Database subnet AZ1 reserved for future RDS/ElastiCache; DynamoDB accessed via VPC Endpoint
  subnet_db_az1_cidr = "10.0.20.0/24"
  # Database subnet AZ2 reserved for future RDS/ElastiCache
  subnet_db_az2_cidr = "10.0.21.0/24"
  # Private subnet AZ1 (us-west-2a) hosting all Lambda functions and agent orchestration
  subnet_private_az1_cidr = "10.0.10.0/24"
  # Private subnet AZ2 (us-west-2b) hosting all Lambda functions and agent orchestration
  subnet_private_az2_cidr = "10.0.11.0/24"
  # Public subnet AZ1 (us-west-2a) for NAT Gateway only; no Lambda compute in public subnets
  subnet_public_az1_cidr = "10.0.1.0/24"
  # Public subnet AZ2 (us-west-2b) for NAT Gateway only
  subnet_public_az2_cidr = "10.0.2.0/24"
  # VPC CIDR block for the us-west-2 platform footprint; isolated from us-east-1
  vpc_cidr = "10.0.0.0/16"
  # Enable Bedrock Runtime Interface VPC Endpoint to route agent invocations privately
  vpc_endpoint_bedrock_runtime = true
  # Enable DynamoDB Gateway VPC Endpoint to route Lambda-to-DynamoDB quota operations privately
  vpc_endpoint_dynamodb = true
  # Enable S3 Gateway VPC Endpoint to route Lambda-to-S3 traffic without public internet
  vpc_endpoint_s3 = true
  # Enable Secrets Manager Interface VPC Endpoint for PAT retrieval without public internet traversal
  vpc_endpoint_secrets_manager = true
}
