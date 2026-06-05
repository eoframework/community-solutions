#------------------------------------------------------------------------------
# AWS Cognito User Pool Module - Tier 1 Provider Primitive
# Creates Cognito User Pool with MFA, password policy, and app client
#------------------------------------------------------------------------------

resource "aws_cognito_user_pool" "main" {
  name = var.user_pool_name

  password_policy {
    minimum_length                   = 12
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  mfa_configuration = var.mfa_enabled ? "OPTIONAL" : "OFF"

  dynamic "software_token_mfa_configuration" {
    for_each = var.mfa_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  auto_verified_attributes = ["email"]

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    required                 = true
    mutable                  = false
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 5
      max_length = 254
    }
  }

  schema {
    name                     = "role"
    attribute_data_type      = "String"
    required                 = false
    mutable                  = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 1
      max_length = 50
    }
  }

  lambda_config {
    post_confirmation = var.post_confirmation_lambda_arn
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  tags = merge(var.common_tags, {
    Name = var.user_pool_name
  })
}

#------------------------------------------------------------------------------
# App Client for PKCE Authorization Code Flow (CLI)
#------------------------------------------------------------------------------
resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.user_pool_name}-client"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret                      = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  callback_urls                        = var.callback_urls
  logout_urls                          = var.logout_urls
  supported_identity_providers         = ["COGNITO"]

  access_token_validity  = var.access_token_expiry_seconds / 3600
  refresh_token_validity = var.refresh_token_expiry_days
  id_token_validity      = 1

  token_validity_units {
    access_token  = "hours"
    refresh_token = "days"
    id_token      = "hours"
  }

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  prevent_user_existence_errors = "ENABLED"
}
