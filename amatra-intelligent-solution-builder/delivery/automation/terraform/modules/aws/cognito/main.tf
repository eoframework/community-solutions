#------------------------------------------------------------------------------
# Tier 1: AWS Cognito — User Pool for JWT auth, quota init trigger
# 30-day refresh tokens, 1-hour access tokens per SOW
#------------------------------------------------------------------------------

resource "aws_cognito_user_pool" "main" {
  name = var.user_pool_name

  password_policy {
    minimum_length                   = 12
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
    string_attribute_constraints {
      min_length = 5
      max_length = 254
    }
  }

  mfa_configuration = var.mfa_configuration

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  user_pool_add_ons {
    advanced_security_mode = "AUDIT"
  }

  tags = merge(var.common_tags, {
    Name = var.user_pool_name
  })
}

resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.name_prefix}-app-client"
  user_pool_id = aws_cognito_user_pool.main.id

  access_token_validity  = var.access_token_validity
  refresh_token_validity = var.refresh_token_validity
  id_token_validity      = var.access_token_validity

  token_validity_units {
    access_token  = "hours"
    refresh_token = "days"
    id_token      = "hours"
  }

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  generate_secret = true

  prevent_user_existence_errors = "ENABLED"

  callback_urls = ["https://localhost"]
  logout_urls   = ["https://localhost"]
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.name_prefix}-auth"
  user_pool_id = aws_cognito_user_pool.main.id
}
