###############################################################################
# Tier 1 Provider Module — AWS API Gateway (REST)
# Creates a Regional REST API, Cognito authoriser, usage plan, and
# CloudWatch access logging.
###############################################################################

resource "aws_api_gateway_rest_api" "main" {
  name        = var.api_name
  description = var.api_description

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(var.common_tags, {
    Name = var.api_name
  })
}

resource "aws_api_gateway_authorizer" "cognito" {
  name                   = "${var.api_name}-cognito-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.main.id
  type                   = "COGNITO_USER_POOLS"
  identity_source        = "method.request.header.Authorization"
  provider_arns          = [var.cognito_user_pool_arn]
}

#--------------------------------------
# CloudWatch Log Group for access logs
#--------------------------------------
resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/apigateway/${var.api_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = var.common_tags
}

#--------------------------------------
# Account-level CloudWatch role for APIGW
#--------------------------------------
resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cw.arn
}

resource "aws_iam_role" "api_gateway_cw" {
  name = "${var.api_name}-apigw-cw-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "apigateway.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "api_gateway_cw" {
  role       = aws_iam_role.api_gateway_cw.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}
