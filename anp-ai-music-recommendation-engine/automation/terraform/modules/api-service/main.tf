#------------------------------------------------------------------------------
# Tier 2 — API Service: API Gateway REST API, Lambda Authorizer, Lambda
# functions for all five endpoints, IAM execution roles, and CloudWatch log groups
#------------------------------------------------------------------------------

#-- Lambda IAM Execution Role ------------------------------------------------

resource "aws_iam_role" "lambda_execution" {
  name = "${var.name_prefix}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-lambda-execution-role"
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_xray" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy" "lambda_services" {
  name = "${var.name_prefix}-lambda-services-policy"
  role = aws_iam_role.lambda_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan",
        ]
        Resource = [
          "arn:aws:dynamodb:*:*:table/${var.content_catalog_table_name}",
          "arn:aws:dynamodb:*:*:table/${var.user_profile_table_name}",
          "arn:aws:dynamodb:*:*:table/${var.interaction_events_table_name}",
          "arn:aws:dynamodb:*:*:table/${var.mood_taxonomy_table_name}",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
        ]
        Resource = [var.feedback_queue_arn]
      },
      {
        Effect   = "Allow"
        Action   = ["ssm:GetParameter"]
        Resource = "arn:aws:ssm:*:*:parameter/${var.cognito_user_pool_id_param}"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
        ]
        Resource = [
          var.catalog_kms_key_arn,
          var.user_data_kms_key_arn,
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "arn:aws:secretsmanager:*:*:secret:${var.name_prefix}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["bedrock:InvokeModel"]
        Resource = "arn:aws:bedrock:*::foundation-model/${var.bedrock_model_id}"
      },
    ]
  })
}

#-- CloudWatch Log Groups for Lambda functions --------------------------------

resource "aws_cloudwatch_log_group" "playlist_lambda" {
  name              = "/aws/lambda/${var.name_prefix}-playlist-generator"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-playlist-lambda-logs"
  })
}

resource "aws_cloudwatch_log_group" "enrichment_lambda" {
  name              = "/aws/lambda/${var.name_prefix}-catalog-enrichment"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-enrichment-lambda-logs"
  })
}

resource "aws_cloudwatch_log_group" "authorizer_lambda" {
  name              = "/aws/lambda/${var.name_prefix}-api-authorizer"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-authorizer-lambda-logs"
  })
}

resource "aws_cloudwatch_log_group" "feedback_lambda" {
  name              = "/aws/lambda/${var.name_prefix}-feedback-capture"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-feedback-lambda-logs"
  })
}

resource "aws_cloudwatch_log_group" "preference_lambda" {
  name              = "/aws/lambda/${var.name_prefix}-preference-update"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-preference-lambda-logs"
  })
}

resource "aws_cloudwatch_log_group" "api_access" {
  name              = "/aws/apigateway/${var.name_prefix}-api-access"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-api-access-logs"
  })
}

#-- Lambda Functions ---------------------------------------------------------

module "playlist_lambda" {
  source = "../aws/lambda"

  function_name  = "${var.name_prefix}-playlist-generator"
  handler        = "handler.handler"
  runtime        = "python3.12"
  architecture   = var.lambda_architecture
  memory_size    = var.lambda_playlist_memory_mb
  timeout        = var.lambda_playlist_timeout_seconds
  reserved_concurrent_executions = var.lambda_max_concurrency
  execution_role_arn = aws_iam_role.lambda_execution.arn
  log_group_name = aws_cloudwatch_log_group.playlist_lambda.name
  xray_tracing   = var.xray_tracing_enabled
  vpc_subnet_ids = var.private_subnet_app_ids
  vpc_security_group_ids = [var.app_security_group_id]
  environment_variables = {
    ENVIRONMENT              = var.environment
    LOG_LEVEL                = var.log_level
    PLAYLIST_COUNT_DEFAULT   = tostring(var.playlist_count_default)
    COLD_START_THRESHOLD     = tostring(var.cold_start_threshold)
    CONTENT_CATALOG_TABLE    = var.content_catalog_table_name
    USER_PROFILE_TABLE       = var.user_profile_table_name
    FEEDBACK_QUEUE_URL       = var.feedback_queue_url
    COGNITO_USER_POOL_PARAM  = var.cognito_user_pool_id_param
    BEDROCK_MODEL_ID         = var.bedrock_model_id
  }
  common_tags = var.common_tags
}

module "enrichment_lambda" {
  source = "../aws/lambda"

  function_name  = "${var.name_prefix}-catalog-enrichment"
  handler        = "handler.handler"
  runtime        = "python3.12"
  architecture   = var.lambda_architecture
  memory_size    = var.lambda_enrichment_memory_mb
  timeout        = var.lambda_enrichment_timeout_seconds
  reserved_concurrent_executions = var.lambda_max_concurrency
  execution_role_arn = aws_iam_role.lambda_execution.arn
  log_group_name = aws_cloudwatch_log_group.enrichment_lambda.name
  xray_tracing   = var.xray_tracing_enabled
  vpc_subnet_ids = var.private_subnet_app_ids
  vpc_security_group_ids = [var.app_security_group_id]
  environment_variables = {
    ENVIRONMENT           = var.environment
    LOG_LEVEL             = var.log_level
    CONTENT_CATALOG_TABLE = var.content_catalog_table_name
    FIREBASE_API_URL      = var.firebase_api_url
    FIREBASE_TIMEOUT_MS   = tostring(var.firebase_timeout_ms)
    BEDROCK_MODEL_ID      = var.bedrock_model_id
    BEDROCK_MAX_TOKENS    = tostring(var.bedrock_max_tokens)
  }
  common_tags = var.common_tags
}

module "authorizer_lambda" {
  source = "../aws/lambda"

  function_name  = "${var.name_prefix}-api-authorizer"
  handler        = "handler.handler"
  runtime        = "python3.12"
  architecture   = var.lambda_architecture
  memory_size    = var.lambda_authorizer_memory_mb
  timeout        = var.lambda_authorizer_timeout_seconds
  reserved_concurrent_executions = var.lambda_max_concurrency
  execution_role_arn = aws_iam_role.lambda_execution.arn
  log_group_name = aws_cloudwatch_log_group.authorizer_lambda.name
  xray_tracing   = var.xray_tracing_enabled
  vpc_subnet_ids = var.private_subnet_app_ids
  vpc_security_group_ids = [var.app_security_group_id]
  environment_variables = {
    ENVIRONMENT              = var.environment
    LOG_LEVEL                = var.log_level
    COGNITO_USER_POOL_PARAM  = var.cognito_user_pool_id_param
  }
  common_tags = var.common_tags
}

module "feedback_lambda" {
  source = "../aws/lambda"

  function_name  = "${var.name_prefix}-feedback-capture"
  handler        = "handler.handler"
  runtime        = "python3.12"
  architecture   = var.lambda_architecture
  memory_size    = var.lambda_feedback_memory_mb
  timeout        = 29
  reserved_concurrent_executions = var.lambda_max_concurrency
  execution_role_arn = aws_iam_role.lambda_execution.arn
  log_group_name = aws_cloudwatch_log_group.feedback_lambda.name
  xray_tracing   = var.xray_tracing_enabled
  vpc_subnet_ids = var.private_subnet_app_ids
  vpc_security_group_ids = [var.app_security_group_id]
  environment_variables = {
    ENVIRONMENT        = var.environment
    LOG_LEVEL          = var.log_level
    FEEDBACK_QUEUE_URL = var.feedback_queue_url
  }
  common_tags = var.common_tags
}

module "preference_lambda" {
  source = "../aws/lambda"

  function_name  = "${var.name_prefix}-preference-update"
  handler        = "handler.handler"
  runtime        = "python3.12"
  architecture   = var.lambda_architecture
  memory_size    = var.lambda_preference_update_memory_mb
  timeout        = 300
  reserved_concurrent_executions = var.lambda_max_concurrency
  execution_role_arn = aws_iam_role.lambda_execution.arn
  log_group_name = aws_cloudwatch_log_group.preference_lambda.name
  xray_tracing   = var.xray_tracing_enabled
  vpc_subnet_ids = var.private_subnet_app_ids
  vpc_security_group_ids = [var.app_security_group_id]
  environment_variables = {
    ENVIRONMENT           = var.environment
    LOG_LEVEL             = var.log_level
    USER_PROFILE_TABLE    = var.user_profile_table_name
    INTERACTION_TABLE     = var.interaction_events_table_name
  }
  common_tags = var.common_tags
}

#-- SQS to Lambda Event Source Mapping (Preference Update) -------------------

resource "aws_lambda_event_source_mapping" "sqs_preference_update" {
  event_source_arn = var.feedback_queue_arn
  function_name    = module.preference_lambda.function_arn
  batch_size       = 10
  enabled          = true
}

#-- API Gateway REST API ------------------------------------------------------

resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.name_prefix}-recommendation-api"
  description = "ANP Streaming AI Recommendation Engine REST API — ${var.environment}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-recommendation-api"
  })
}

# /api resource
resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "api"
}

# /api/v1 resource
resource "aws_api_gateway_resource" "v1" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = var.api_version
}

# Lambda authorizer
resource "aws_api_gateway_authorizer" "cognito" {
  name                             = "${var.name_prefix}-cognito-authorizer"
  rest_api_id                      = aws_api_gateway_rest_api.main.id
  authorizer_uri                   = module.authorizer_lambda.invoke_arn
  authorizer_credentials           = aws_iam_role.lambda_execution.arn
  type                             = "TOKEN"
  identity_source                  = "method.request.header.Authorization"
  authorizer_result_ttl_in_seconds = 300
}

# Lambda invoke permission for API GW authorizer
resource "aws_lambda_permission" "apigw_authorizer" {
  statement_id  = "AllowAPIGatewayInvokeAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = module.authorizer_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_playlist" {
  statement_id  = "AllowAPIGatewayInvokePlaylist"
  action        = "lambda:InvokeFunction"
  function_name = module.playlist_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_feedback" {
  statement_id  = "AllowAPIGatewayInvokeFeedback"
  action        = "lambda:InvokeFunction"
  function_name = module.feedback_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_enrichment" {
  statement_id  = "AllowAPIGatewayInvokeEnrichment"
  action        = "lambda:InvokeFunction"
  function_name = module.enrichment_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# /api/v1/playlists resource + POST method
resource "aws_api_gateway_resource" "playlists" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "playlists"
}

resource "aws_api_gateway_method" "playlists_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.playlists.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "playlists_post" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.playlists.id
  http_method             = aws_api_gateway_method.playlists_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.playlist_lambda.invoke_arn
  timeout_milliseconds    = var.apigw_integration_timeout_ms
}

# /api/v1/interactions resource + POST method
resource "aws_api_gateway_resource" "interactions" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "interactions"
}

resource "aws_api_gateway_method" "interactions_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.interactions.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "interactions_post" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.interactions.id
  http_method             = aws_api_gateway_method.interactions_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.feedback_lambda.invoke_arn
  timeout_milliseconds    = var.apigw_integration_timeout_ms
}

# /api/v1/content resource + /api/v1/content/classify
resource "aws_api_gateway_resource" "content" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "content"
}

resource "aws_api_gateway_resource" "classify" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.content.id
  path_part   = "classify"
}

resource "aws_api_gateway_method" "classify_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.classify.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "classify_post" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.classify.id
  http_method             = aws_api_gateway_method.classify_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.enrichment_lambda.invoke_arn
  timeout_milliseconds    = var.apigw_integration_timeout_ms
}

# /api/v1/health resource (API key auth — not JWT)
resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "health"
}

resource "aws_api_gateway_method" "health_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.health.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "health_get" {
  rest_api_id          = aws_api_gateway_rest_api.main.id
  resource_id          = aws_api_gateway_resource.health.id
  http_method          = aws_api_gateway_method.health_get.http_method
  type                 = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "health_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_get.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "health_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_get.http_method
  status_code = aws_api_gateway_method_response.health_200.status_code

  depends_on = [aws_api_gateway_integration.health_get]
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.playlists,
      aws_api_gateway_method.playlists_post,
      aws_api_gateway_integration.playlists_post,
      aws_api_gateway_resource.interactions,
      aws_api_gateway_method.interactions_post,
      aws_api_gateway_integration.interactions_post,
      aws_api_gateway_resource.classify,
      aws_api_gateway_method.classify_post,
      aws_api_gateway_integration.classify_post,
      aws_api_gateway_resource.health,
      aws_api_gateway_method.health_get,
      aws_api_gateway_integration.health_get,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.playlists_post,
    aws_api_gateway_integration.interactions_post,
    aws_api_gateway_integration.classify_post,
    aws_api_gateway_integration.health_get,
    aws_api_gateway_integration_response.health_200,
  ]
}

# API Gateway Stage with X-Ray and access logging
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.apigw_stage_name

  xray_tracing_enabled = var.xray_tracing_enabled

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_access.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-api-stage-${var.apigw_stage_name}"
  })
}

# API Gateway Usage Plan with throttling
resource "aws_api_gateway_usage_plan" "main" {
  name = "${var.name_prefix}-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.main.id
    stage  = aws_api_gateway_stage.main.stage_name
  }

  throttle_settings {
    rate_limit  = var.apigw_rate_limit_rps
    burst_limit = var.apigw_rate_limit_rps * 2
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-usage-plan"
  })
}
