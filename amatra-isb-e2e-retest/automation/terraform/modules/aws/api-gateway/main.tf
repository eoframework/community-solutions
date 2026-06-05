#------------------------------------------------------------------------------
# AWS API Gateway HTTP API v2 Module - Tier 1 Provider Primitive
# Creates HTTP API with JWT Cognito authoriser, stage, and throttling
#------------------------------------------------------------------------------

resource "aws_apigatewayv2_api" "main" {
  name          = "${var.name_prefix}-apigw"
  protocol_type = "HTTP"
  description   = var.description

  cors_configuration {
    allow_headers = ["Content-Type", "Authorization", "X-Amz-Date", "X-Api-Key"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_origins = var.cors_allow_origins
    max_age       = 300
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-apigw"
  })
}

#------------------------------------------------------------------------------
# JWT Cognito Authoriser
#------------------------------------------------------------------------------
resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.main.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "${var.name_prefix}-auth-cognito"

  jwt_configuration {
    audience = [var.cognito_app_client_id]
    issuer   = "https://cognito-idp.${var.region}.amazonaws.com/${var.cognito_user_pool_id}"
  }
}

#------------------------------------------------------------------------------
# Default Stage with Throttling
#------------------------------------------------------------------------------
resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = var.throttle_burst_limit
    throttling_rate_limit  = var.throttle_rate_limit
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-apigw-stage"
  })
}
