#------------------------------------------------------------------------------
# Tier 1: AWS Cognito User Pool — Identity for platform users
#------------------------------------------------------------------------------

resource "aws_cognito_user_pool" "main" {
  name = var.user_pool_name

  # Password policy
  password_policy {
    minimum_length                   = 12
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  # MFA configuration
  mfa_configuration = var.mfa_configuration

  software_token_mfa_configuration {
    enabled = var.mfa_configuration != "OFF"
  }

  # Account recovery
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # Auto-verified attributes
  auto_verified_attributes = ["email"]

  # Schema attributes
  schema {
    name                     = "email"
    attribute_data_type      = "String"
    required                 = true
    mutable                  = true
    string_attribute_constraints {
      min_length = 3
      max_length = 254
    }
  }

  # Email configuration (use Cognito default SES)
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # User pool add-ons (advanced security disabled for initial PoC)
  user_pool_add_ons {
    advanced_security_mode = "OFF"
  }

  tags = var.common_tags
}

resource "aws_cognito_user_pool_client" "cli" {
  name         = "${var.name_prefix}-cognito-cli-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # Auth flows — USER_PASSWORD_AUTH for CLI
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]

  # Token validity
  access_token_validity  = ceil(var.access_token_validity / 3600)  # convert seconds to hours
  refresh_token_validity = var.refresh_token_validity_days
  id_token_validity      = ceil(var.access_token_validity / 3600)

  token_validity_units {
    access_token  = "hours"
    refresh_token = "days"
    id_token      = "hours"
  }

  generate_secret                      = true
  prevent_user_existence_errors        = "ENABLED"
  enable_token_revocation              = true
  allowed_oauth_flows_user_pool_client = false
}

# Consultant user group — access to /solution/* /artifact/* /user/profile
resource "aws_cognito_user_group" "consultants" {
  name         = var.group_consultants
  user_pool_id = aws_cognito_user_pool.main.id
  description  = "Standard consultant users with access to solution and artifact routes"
  precedence   = 10
}

# Admin user group — full platform access including /admin/* routes
resource "aws_cognito_user_group" "admins" {
  name         = var.group_admins
  user_pool_id = aws_cognito_user_pool.main.id
  description  = "Platform administrators with access to admin usage and quota reset routes"
  precedence   = 1
}

# Post-confirmation Lambda trigger permission
resource "aws_lambda_permission" "cognito_post_confirmation" {
  statement_id  = "AllowCognitoPostConfirmation"
  action        = "lambda:InvokeFunction"
  function_name = var.post_confirmation_lambda_arn
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.main.arn
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.name_prefix}-auth"
  user_pool_id = aws_cognito_user_pool.main.id
}
