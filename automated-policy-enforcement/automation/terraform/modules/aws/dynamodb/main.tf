#------------------------------------------------------------------------------
# Tier 1: AWS DynamoDB — AFT workflow state and Terraform state locking
# On-demand billing, PITR, KMS encryption — no idle capacity costs
#------------------------------------------------------------------------------

resource "aws_dynamodb_table" "aft_workflow" {
  name         = var.aft_table_name
  billing_mode = var.aft_billing_mode
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.aft_backup_enabled
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  tags = merge(var.common_tags, {
    Name    = var.aft_table_name
    Purpose = "aft-workflow-state"
    Backup  = tostring(var.aft_backup_enabled)
  })
}

resource "aws_dynamodb_table" "tf_state_lock" {
  name         = var.tf_lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  tags = merge(var.common_tags, {
    Name    = var.tf_lock_table_name
    Purpose = "terraform-state-lock"
  })
}
