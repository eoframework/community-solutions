#------------------------------------------------------------------------------
# AWS DynamoDB Module - Tier 1 Provider Primitive
# Creates a DynamoDB table with optional PITR, TTL, and GSIs
#------------------------------------------------------------------------------

resource "aws_dynamodb_table" "main" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key
  range_key    = var.range_key != "" ? var.range_key : null

  point_in_time_recovery {
    enabled = var.pitr_enabled
  }

  dynamic "ttl" {
    for_each = var.ttl_attribute != "" ? [1] : []
    content {
      attribute_name = var.ttl_attribute
      enabled        = true
    }
  }

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      range_key       = lookup(global_secondary_index.value, "range_key", null)
      projection_type = global_secondary_index.value.projection_type
    }
  }

  deletion_protection_enabled = var.deletion_protection_enabled

  tags = merge(var.common_tags, {
    Name = var.table_name
  })
}
