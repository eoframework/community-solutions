#------------------------------------------------------------------------------
# Processing Module (Tier 2) - Three Lambda Functions (Classifier, Recommender, Auto-Tagger)
# + SQS DLQ
# Calls: aws/lambda, aws/sqs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Auto-Tagger Dead Letter Queue
#------------------------------------------------------------------------------
module "autotagger_dlq" {
  source = "../aws/sqs"

  queue_name                 = var.autotagger_dlq_name
  message_retention_seconds  = 1209600 # 14 days
  visibility_timeout_seconds = 30
  common_tags                = var.common_tags
}

#------------------------------------------------------------------------------
# Classifier Lambda
#------------------------------------------------------------------------------
module "classifier" {
  source = "../aws/lambda"

  function_name   = var.classifier_function_name
  handler         = "handler.lambda_handler"
  runtime         = var.lambda_runtime
  memory_mb       = var.classifier_memory_mb
  timeout_seconds = var.classifier_timeout_seconds
  enable_xray     = var.enable_xray

  log_retention_days = var.log_retention_days

  environment_variables = {
    ENVIRONMENT            = var.environment
    LOG_LEVEL              = var.log_level
    BEDROCK_MODEL_ID_PARAM = "/anp/${var.environment}/bedrock-model-id"
    MOOD_LABELS            = var.mood_labels
    BEDROCK_MAX_TOKENS     = tostring(var.bedrock_max_tokens)
    AWS_REGION_NAME        = var.aws_region
  }

  inline_policy_json = var.classifier_policy_json
  common_tags        = var.common_tags
}

resource "aws_iam_role_policy_attachment" "classifier" {
  count      = var.classifier_policy_arn != "" ? 1 : 0
  role       = module.classifier.role_name
  policy_arn = var.classifier_policy_arn
}

#------------------------------------------------------------------------------
# Recommender Lambda
#------------------------------------------------------------------------------
module "recommender" {
  source = "../aws/lambda"

  function_name   = var.recommender_function_name
  handler         = "handler.lambda_handler"
  runtime         = var.lambda_runtime
  memory_mb       = var.recommender_memory_mb
  timeout_seconds = var.recommender_timeout_seconds
  enable_xray     = var.enable_xray

  log_retention_days = var.log_retention_days

  environment_variables = {
    ENVIRONMENT             = var.environment
    LOG_LEVEL               = var.log_level
    CATALOG_TABLE_NAME      = var.catalog_table_name
    USER_HISTORY_TABLE_NAME = var.user_history_table_name
    CATALOG_GSI_NAME        = var.catalog_gsi_name
    HISTORY_LOOKBACK        = tostring(var.history_lookback)
    DEFAULT_LIMIT           = tostring(var.recommend_default_limit)
    MAX_LIMIT               = tostring(var.recommend_max_limit)
  }

  inline_policy_json = var.recommender_policy_json
  common_tags        = var.common_tags
}

resource "aws_iam_role_policy_attachment" "recommender" {
  count      = var.recommender_policy_arn != "" ? 1 : 0
  role       = module.recommender.role_name
  policy_arn = var.recommender_policy_arn
}

#------------------------------------------------------------------------------
# Auto-Tagger Lambda
#------------------------------------------------------------------------------
module "autotagger" {
  source = "../aws/lambda"

  function_name   = var.autotagger_function_name
  handler         = "handler.lambda_handler"
  runtime         = var.lambda_runtime
  memory_mb       = var.autotagger_memory_mb
  timeout_seconds = var.autotagger_timeout_seconds
  enable_xray     = var.enable_xray

  log_retention_days = var.log_retention_days

  environment_variables = {
    ENVIRONMENT            = var.environment
    LOG_LEVEL              = var.log_level
    CATALOG_TABLE_NAME     = var.catalog_table_name
    BEDROCK_MODEL_ID_PARAM = "/anp/${var.environment}/bedrock-model-id"
    MOOD_LABELS            = var.mood_labels
    MAX_RETRIES            = tostring(var.autotagger_max_retries)
    DLQ_URL                = module.autotagger_dlq.queue_url
    MIN_CONFIDENCE         = var.min_confidence_threshold
  }

  inline_policy_json = var.autotagger_policy_json
  common_tags        = var.common_tags
}

resource "aws_iam_role_policy_attachment" "autotagger" {
  count      = var.autotagger_policy_arn != "" ? 1 : 0
  role       = module.autotagger.role_name
  policy_arn = var.autotagger_policy_arn
}
