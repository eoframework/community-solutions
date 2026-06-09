#------------------------------------------------------------------------------
# AWS DynamoDB Table - Tier 1 Provider Module
#------------------------------------------------------------------------------

resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key
  range_key    = var.range_key != "" ? var.range_key : null

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
      range_key       = try(global_secondary_index.value.range_key, null)
      projection_type = try(global_secondary_index.value.projection_type, "ALL")
    }
  }

  dynamic "ttl" {
    for_each = var.ttl_attribute != "" ? [var.ttl_attribute] : []
    content {
      attribute_name = ttl.value
      enabled        = true
    }
  }

  point_in_time_recovery {
    enabled = var.pitr_enabled
  }

  server_side_encryption {
    enabled = true
  }

  tags = var.common_tags
}
