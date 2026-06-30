################################################################################
# Tier 1 — AWS Kinesis Data Streams Module
################################################################################

resource "aws_kinesis_stream" "this" {
  name             = var.stream_name
  shard_count      = var.shard_count
  retention_period = var.retention_hours

  encryption_type = "KMS"
  kms_key_id      = var.kms_key_id

  shard_level_metrics = [
    "IncomingBytes",
    "IncomingRecords",
    "OutgoingBytes",
    "OutgoingRecords",
    "IteratorAgeMilliseconds",
    "ReadProvisionedThroughputExceeded",
    "WriteProvisionedThroughputExceeded"
  ]

  tags = merge(var.common_tags, {
    Name = var.stream_name
  })
}

# Dead Letter Queue for failed records
resource "aws_sqs_queue" "dlq" {
  name                       = "${var.stream_name}-dlq"
  message_retention_seconds  = 1209600 # 14 days
  kms_master_key_id          = var.kms_key_id
  visibility_timeout_seconds = 300

  tags = merge(var.common_tags, {
    Name = "${var.stream_name}-dlq"
  })
}
