#------------------------------------------------------------------------------
# Tier 2 — Cognito capability module
# Composes: aws/cognito, post-confirmation Lambda trigger
#------------------------------------------------------------------------------

# Post-confirmation Lambda trigger
module "lambda_post_confirmation" {
  source          = "../aws/lambda"
  function_name   = "${var.name_prefix}-lambda-post-confirmation"
  runtime         = var.compute.lambda_runtime
  memory_mb       = var.compute.post_confirmation_memory_mb
  timeout_seconds = var.compute.post_confirmation_timeout_seconds
  xray_tracing_enabled = var.monitoring.xray_tracing_enabled
  log_retention_days   = var.monitoring.log_retention_days
  environment_variables = {
    ENVIRONMENT          = var.environment
    LOG_LEVEL            = var.application.log_level
    USERS_TABLE_NAME     = var.security.cognito_user_pool_name
  }
  additional_policy_statements = [
    {
      Effect = "Allow"
      Action = ["dynamodb:PutItem", "dynamodb:UpdateItem"]
      Resource = [
        "arn:aws:dynamodb:*:*:table/*-ddb-users",
        "arn:aws:dynamodb:*:*:table/*-ddb-global-quota"
      ]
    }
  ]
  common_tags = var.common_tags
}

# Cognito IAM role for consultants group
resource "aws_iam_role" "cognito_consultants" {
  name = "${var.name_prefix}-cognito-role-consultants"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "cognito-identity.amazonaws.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
    }]
  })
  tags = var.common_tags
}

# Cognito IAM role for admins group
resource "aws_iam_role" "cognito_admins" {
  name = "${var.name_prefix}-cognito-role-admins"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "cognito-identity.amazonaws.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
    }]
  })
  tags = var.common_tags
}

module "cognito_user_pool" {
  source                       = "../aws/cognito"
  user_pool_name               = var.security.cognito_user_pool_name
  mfa_enabled                  = var.security.cognito_mfa_enabled
  access_token_validity_hours  = floor(var.security.cognito_access_token_expiry_seconds / 3600)
  refresh_token_validity_days  = var.security.cognito_refresh_token_expiry_days
  group_consultants            = var.security.cognito_group_consultants
  group_admins                 = var.security.cognito_group_admins
  post_confirmation_lambda_arn = module.lambda_post_confirmation.function_arn
  consultants_role_arn         = aws_iam_role.cognito_consultants.arn
  admins_role_arn              = aws_iam_role.cognito_admins.arn
  common_tags                  = var.common_tags
}

# Allow Cognito to invoke the post-confirmation Lambda
resource "aws_lambda_permission" "cognito_post_confirmation" {
  statement_id  = "AllowCognitoInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_post_confirmation.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = module.cognito_user_pool.user_pool_arn
}
