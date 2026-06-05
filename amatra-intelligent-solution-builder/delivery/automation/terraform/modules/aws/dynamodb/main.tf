#------------------------------------------------------------------------------
# Tier 1: AWS DynamoDB — Three tables for user profiles, solution state, quota
# On-demand billing mode for atomic quota enforcement without throttling
#------------------------------------------------------------------------------

# User Profiles table — Cognito sub as PK, quota counters, monthly reset
resource "aws_dynamodb_table" "user_profiles" {
  name         = var.table_user_profiles
  billing_mode = var.billing_mode
  hash_key     = "user_id"
  range_key    = "record_type"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "record_type"
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.pitr_enabled
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(var.common_tags, {
    Name = var.table_user_profiles
  })
}

# Solution State table — per-solution execution state, artifact status, retry counts
resource "aws_dynamodb_table" "solution_state" {
  name         = var.table_solution_state
  billing_mode = var.billing_mode
  hash_key     = "solution_id"
  range_key    = "record_type"

  attribute {
    name = "solution_id"
    type = "S"
  }

  attribute {
    name = "record_type"
    type = "S"
  }

  # TTL for 90-day (prod) archival per SOW data architecture
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  point_in_time_recovery {
    enabled = var.pitr_enabled
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(var.common_tags, {
    Name = var.table_solution_state
  })
}

# Global Quota table — single-record atomic counter for 1000/month hard cap
resource "aws_dynamodb_table" "quota_global" {
  name         = var.table_quota_global
  billing_mode = var.billing_mode
  hash_key     = "quota_key"
  range_key    = "record_type"

  attribute {
    name = "quota_key"
    type = "S"
  }

  attribute {
    name = "record_type"
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.pitr_enabled
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(var.common_tags, {
    Name = var.table_quota_global
  })
}
