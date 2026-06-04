#------------------------------------------------------------------------------
# Tier 1: AWS DynamoDB — Users, Solutions, and GlobalQuota tables
#------------------------------------------------------------------------------

# Users table — user profiles and per-user monthly quota counters
resource "aws_dynamodb_table" "users" {
  name         = var.users_table_name
  billing_mode = var.billing_mode
  hash_key     = "userId"

  attribute {
    name = "userId"
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.pitr_enabled
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(var.common_tags, { Name = var.users_table_name, TableType = "users" })
}

# Solutions table — solution generation metadata, status, artifact locations
resource "aws_dynamodb_table" "solutions" {
  name         = var.solutions_table_name
  billing_mode = var.billing_mode
  hash_key     = "solutionId"
  range_key    = "userId"

  attribute {
    name = "solutionId"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "createdAt"
    type = "S"
  }

  # GSI for CLI solution list — userId + createdAt
  global_secondary_index {
    name            = "userId-createdAt-index"
    hash_key        = "userId"
    range_key       = "createdAt"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = var.pitr_enabled
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(var.common_tags, { Name = var.solutions_table_name, TableType = "solutions" })
}

# GlobalQuota table — atomic monthly solution counter
resource "aws_dynamodb_table" "global_quota" {
  name         = var.global_quota_table_name
  billing_mode = var.billing_mode
  hash_key     = "month"

  attribute {
    name = "month"
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.pitr_enabled
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(var.common_tags, { Name = var.global_quota_table_name, TableType = "global-quota" })
}
