#------------------------------------------------------------------------------
# Tier 1: AWS API Gateway HTTP API v2 — Eleven JWT-protected Lambda routes
#------------------------------------------------------------------------------

resource "aws_apigatewayv2_api" "main" {
  name          = "${var.name_prefix}-apigw-http-api"
  protocol_type = "HTTP"
  description   = "Amatra Agentic Orchestration Platform HTTP API v2"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["Authorization", "Content-Type"]
    max_age       = 300
  }

  tags = var.common_tags
}

# JWT Authoriser — validates Cognito RS256 tokens on every request
resource "aws_apigatewayv2_authorizer" "cognito_jwt" {
  api_id           = aws_apigatewayv2_api.main.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "${var.name_prefix}-jwt-authoriser"

  jwt_configuration {
    audience = []
    issuer   = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${var.cognito_user_pool_id}"
  }
}

data "aws_region" "current" {}

# CloudWatch log group for API Gateway access logs
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/amatra/${var.stage_name}/api-gateway-access-logs"
  retention_in_days = var.log_retention_days
  tags              = var.common_tags
}

# API Gateway stage
resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = var.stage_name
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = var.throttle_burst_limit
    throttling_rate_limit  = var.throttle_rate_limit
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      sourceIp       = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      protocol       = "$context.protocol"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      responseLength = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Lambda integrations
#------------------------------------------------------------------------------
resource "aws_apigatewayv2_integration" "solution_create" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.solution_create_function_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "status" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.status_function_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "artifact_fetch" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.artifact_fetch_function_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "admin_usage" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.admin_usage_function_arn
  payload_format_version = "2.0"
}

#------------------------------------------------------------------------------
# API Routes — all JWT-protected per SOW design
#------------------------------------------------------------------------------
resource "aws_apigatewayv2_route" "post_solution" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "POST /v1/solution"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
  target             = "integrations/${aws_apigatewayv2_integration.solution_create.id}"
}

resource "aws_apigatewayv2_route" "get_solution" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /v1/solution/{solutionId}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
  target             = "integrations/${aws_apigatewayv2_integration.status.id}"
}

resource "aws_apigatewayv2_route" "get_solution_artifacts" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /v1/solution/{solutionId}/artifacts"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
  target             = "integrations/${aws_apigatewayv2_integration.artifact_fetch.id}"
}

resource "aws_apigatewayv2_route" "delete_solution" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "DELETE /v1/solution/{solutionId}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
  target             = "integrations/${aws_apigatewayv2_integration.solution_create.id}"
}

resource "aws_apigatewayv2_route" "get_solutions" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /v1/solutions"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
  target             = "integrations/${aws_apigatewayv2_integration.status.id}"
}

resource "aws_apigatewayv2_route" "get_user_profile" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /v1/user/profile"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
  target             = "integrations/${aws_apigatewayv2_integration.status.id}"
}

resource "aws_apigatewayv2_route" "put_user_profile" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "PUT /v1/user/profile"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
  target             = "integrations/${aws_apigatewayv2_integration.solution_create.id}"
}

resource "aws_apigatewayv2_route" "get_quota" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /v1/quota"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
  target             = "integrations/${aws_apigatewayv2_integration.status.id}"
}

resource "aws_apigatewayv2_route" "post_auth_refresh" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "POST /v1/auth/refresh"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
  target             = "integrations/${aws_apigatewayv2_integration.solution_create.id}"
}

resource "aws_apigatewayv2_route" "get_admin_usage" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /v1/admin/usage"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
  target             = "integrations/${aws_apigatewayv2_integration.admin_usage.id}"
}

resource "aws_apigatewayv2_route" "post_admin_quota_reset" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "POST /v1/admin/quota/reset"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
  target             = "integrations/${aws_apigatewayv2_integration.admin_usage.id}"
}

#------------------------------------------------------------------------------
# Lambda permissions for API Gateway
#------------------------------------------------------------------------------
resource "aws_lambda_permission" "solution_create" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.solution_create_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "status" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.status_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "artifact_fetch" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.artifact_fetch_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "admin_usage" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.admin_usage_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}
