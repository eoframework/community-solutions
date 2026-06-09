#------------------------------------------------------------------------------
# AWS API Gateway REST API - Tier 1 Provider Module
#------------------------------------------------------------------------------

resource "aws_api_gateway_rest_api" "this" {
  name        = var.api_name
  description = var.api_description

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# /v1 Resource
#------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "v1" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "v1"
}

#------------------------------------------------------------------------------
# /v1/classify Resource + POST Method
#------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "classify" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "classify"
}

resource "aws_api_gateway_method" "classify_post" {
  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = aws_api_gateway_resource.classify.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "classify_post" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.classify.id
  http_method             = aws_api_gateway_method.classify_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.classifier_invoke_arn
}

resource "aws_lambda_permission" "classify" {
  statement_id  = "AllowAPIGatewayClassify"
  action        = "lambda:InvokeFunction"
  function_name = var.classifier_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

#------------------------------------------------------------------------------
# /v1/recommend Resource + GET Method
#------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "recommend" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "recommend"
}

resource "aws_api_gateway_authorizer" "cognito" {
  name            = "${var.api_name}-cognito-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.this.id
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [var.cognito_user_pool_arn]
  identity_source = "method.request.header.Authorization"
}

resource "aws_api_gateway_method" "recommend_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.recommend.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id

  request_parameters = {
    "method.request.querystring.mood"  = true
    "method.request.querystring.limit" = false
  }
}

resource "aws_api_gateway_integration" "recommend_get" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.recommend.id
  http_method             = aws_api_gateway_method.recommend_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.recommender_invoke_arn
}

resource "aws_lambda_permission" "recommend" {
  statement_id  = "AllowAPIGatewayRecommend"
  action        = "lambda:InvokeFunction"
  function_name = var.recommender_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

#------------------------------------------------------------------------------
# Deployment + Stage
#------------------------------------------------------------------------------
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.classify.id,
      aws_api_gateway_resource.recommend.id,
      aws_api_gateway_method.classify_post.id,
      aws_api_gateway_method.recommend_get.id,
      aws_api_gateway_integration.classify_post.id,
      aws_api_gateway_integration.recommend_get.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.classify_post,
    aws_api_gateway_integration.recommend_get,
  ]
}

resource "aws_cloudwatch_log_group" "apigw_access" {
  name              = "/aws/apigateway/${var.api_name}-access-logs"
  retention_in_days = var.log_retention_days
  tags              = var.common_tags
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name

  xray_tracing_enabled = var.enable_xray

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw_access.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      caller         = "$context.identity.caller"
      user           = "$context.identity.user"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
      latency        = "$context.integrationLatency"
    })
  }

  tags = var.common_tags
}

resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = true
    logging_level          = "INFO"
    data_trace_enabled     = false
    throttling_burst_limit = var.burst_limit
    throttling_rate_limit  = var.rate_limit_rps
  }
}

#------------------------------------------------------------------------------
# API Key + Usage Plan
#------------------------------------------------------------------------------
resource "aws_api_gateway_api_key" "this" {
  name    = "${var.api_name}-key"
  enabled = true
  tags    = var.common_tags
}

resource "aws_api_gateway_usage_plan" "this" {
  name        = "${var.api_name}-usage-plan"
  description = "Usage plan for ${var.api_name}"

  api_stages {
    api_id = aws_api_gateway_rest_api.this.id
    stage  = aws_api_gateway_stage.this.stage_name
  }

  throttle_settings {
    rate_limit  = var.rate_limit_rps
    burst_limit = var.burst_limit
  }

  tags = var.common_tags
}

resource "aws_api_gateway_usage_plan_key" "this" {
  key_id        = aws_api_gateway_api_key.this.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this.id
}
