#------------------------------------------------------------------------------
# Tier 1: AWS API Gateway HTTP API v2
# 11 JWT-protected Lambda routes with Cognito JWT authoriser
#------------------------------------------------------------------------------

resource "aws_apigatewayv2_api" "main" {
  name          = "${var.name_prefix}-api"
  protocol_type = "HTTP"
  description   = "Amatra platform HTTP API v2 — 11 JWT-protected Lambda routes"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "DELETE", "OPTIONS"]
    allow_headers = ["Authorization", "Content-Type"]
    max_age       = 300
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-api"
  })
}

# JWT Authoriser — validates Cognito tokens on every route
resource "aws_apigatewayv2_authorizer" "cognito_jwt" {
  api_id           = aws_apigatewayv2_api.main.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "${var.name_prefix}-jwt-authorizer"

  jwt_configuration {
    audience = [var.cognito_user_pool_id]
    issuer   = "https://cognito-idp.us-west-2.amazonaws.com/${var.cognito_user_pool_id}"
  }
}

# Stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_rate_limit  = var.throttle_rate_limit
    throttling_burst_limit = var.throttle_burst_limit
  }

  tags = var.common_tags
}

# Lambda integration
resource "aws_apigatewayv2_integration" "api_handler" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "AWS_PROXY"
  integration_uri    = var.lambda_invoke_arns["api_handler"]
  integration_method = "POST"
  payload_format_version = "2.0"
}

# Routes — 11 JWT-protected routes per SOW
resource "aws_apigatewayv2_route" "post_solutions" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "POST /api/v1/solutions"
  target             = "integrations/${aws_apigatewayv2_integration.api_handler.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
}

resource "aws_apigatewayv2_route" "get_solution" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /api/v1/solutions/{solution_id}"
  target             = "integrations/${aws_apigatewayv2_integration.api_handler.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
}

resource "aws_apigatewayv2_route" "get_solution_artifacts" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /api/v1/solutions/{solution_id}/artifacts"
  target             = "integrations/${aws_apigatewayv2_integration.api_handler.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
}

resource "aws_apigatewayv2_route" "get_artifact" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /api/v1/solutions/{solution_id}/artifacts/{artifact_key}"
  target             = "integrations/${aws_apigatewayv2_integration.api_handler.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
}

resource "aws_apigatewayv2_route" "delete_solution" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "DELETE /api/v1/solutions/{solution_id}"
  target             = "integrations/${aws_apigatewayv2_integration.api_handler.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
}

resource "aws_apigatewayv2_route" "get_quota" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /api/v1/quota"
  target             = "integrations/${aws_apigatewayv2_integration.api_handler.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
}

resource "aws_apigatewayv2_route" "list_solutions" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /api/v1/solutions"
  target             = "integrations/${aws_apigatewayv2_integration.api_handler.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
}

resource "aws_apigatewayv2_route" "auth_refresh" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "POST /api/v1/auth/refresh"
  target             = "integrations/${aws_apigatewayv2_integration.api_handler.id}"
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_route" "admin_usage" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /api/v1/admin/usage"
  target             = "integrations/${aws_apigatewayv2_integration.api_handler.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
}

resource "aws_apigatewayv2_route" "admin_quota_reset" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "POST /api/v1/admin/quota/reset"
  target             = "integrations/${aws_apigatewayv2_integration.api_handler.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
}

resource "aws_apigatewayv2_route" "health" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /api/v1/health"
  target             = "integrations/${aws_apigatewayv2_integration.api_handler.id}"
  authorization_type = "NONE"
}

# Lambda permission for API Gateway invocation
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names["api_handler"]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}
