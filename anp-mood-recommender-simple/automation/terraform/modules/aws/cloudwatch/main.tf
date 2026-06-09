#------------------------------------------------------------------------------
# AWS CloudWatch Alarms + SNS + Dashboard - Tier 1 Provider Module
#------------------------------------------------------------------------------

resource "aws_sns_topic" "ops" {
  name = "${var.name_prefix}-ops-alerts"
  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "classifier_errors" {
  alarm_name          = "${var.name_prefix}-classifier-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = var.lambda_error_threshold
  treat_missing_data  = "notBreaching"
  alarm_description   = "Classifier Lambda error count exceeded threshold"
  alarm_actions       = [aws_sns_topic.ops.arn]
  ok_actions          = [aws_sns_topic.ops.arn]

  dimensions = {
    FunctionName = var.classifier_function_name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "recommender_errors" {
  alarm_name          = "${var.name_prefix}-recommender-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = var.lambda_error_threshold
  treat_missing_data  = "notBreaching"
  alarm_description   = "Recommender Lambda error count exceeded threshold"
  alarm_actions       = [aws_sns_topic.ops.arn]
  ok_actions          = [aws_sns_topic.ops.arn]

  dimensions = {
    FunctionName = var.recommender_function_name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "autotagger_errors" {
  alarm_name          = "${var.name_prefix}-autotagger-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = var.lambda_error_threshold
  treat_missing_data  = "notBreaching"
  alarm_description   = "Auto-Tagger Lambda error count exceeded threshold"
  alarm_actions       = [aws_sns_topic.ops.arn]
  ok_actions          = [aws_sns_topic.ops.arn]

  dimensions = {
    FunctionName = var.autotagger_function_name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "apigw_p95_latency" {
  alarm_name          = "${var.name_prefix}-apigw-p95-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "IntegrationLatency"
  namespace           = "AWS/ApiGateway"
  period              = 300
  extended_statistic  = "p95"
  threshold           = var.apigw_p95_latency_threshold_ms
  treat_missing_data  = "notBreaching"
  alarm_description   = "API Gateway p95 latency exceeded ${var.apigw_p95_latency_threshold_ms}ms"
  alarm_actions       = [aws_sns_topic.ops.arn]
  ok_actions          = [aws_sns_topic.ops.arn]

  dimensions = {
    ApiName = var.api_name
    Stage   = var.api_stage
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "apigw_5xx" {
  alarm_name          = "${var.name_prefix}-apigw-5xx-count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = var.apigw_5xx_threshold
  treat_missing_data  = "notBreaching"
  alarm_description   = "API Gateway 5xx error count exceeded threshold"
  alarm_actions       = [aws_sns_topic.ops.arn]
  ok_actions          = [aws_sns_topic.ops.arn]

  dimensions = {
    ApiName = var.api_name
    Stage   = var.api_stage
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "autotagger_dlq_depth" {
  alarm_name          = "${var.name_prefix}-autotagger-dlq-depth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Sum"
  threshold           = var.dlq_depth_threshold
  treat_missing_data  = "notBreaching"
  alarm_description   = "Auto-Tagger DLQ has messages — investigate failed S3 events"
  alarm_actions       = [aws_sns_topic.ops.arn]
  ok_actions          = [aws_sns_topic.ops.arn]

  dimensions = {
    QueueName = var.autotagger_dlq_name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_throttles" {
  alarm_name          = "${var.name_prefix}-dynamodb-throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UserErrors"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = var.dynamodb_throttle_threshold
  treat_missing_data  = "notBreaching"
  alarm_description   = "DynamoDB throttled requests detected"
  alarm_actions       = [aws_sns_topic.ops.arn]
  ok_actions          = [aws_sns_topic.ops.arn]

  tags = var.common_tags
}

resource "aws_cloudwatch_dashboard" "operations" {
  dashboard_name = var.operations_dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "Lambda Invocations"
          period = 300
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", var.classifier_function_name],
            ["AWS/Lambda", "Invocations", "FunctionName", var.recommender_function_name],
            ["AWS/Lambda", "Invocations", "FunctionName", var.autotagger_function_name],
          ]
        }
      },
      {
        type = "metric"
        properties = {
          title  = "Lambda Errors"
          period = 300
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", var.classifier_function_name],
            ["AWS/Lambda", "Errors", "FunctionName", var.recommender_function_name],
            ["AWS/Lambda", "Errors", "FunctionName", var.autotagger_function_name],
          ]
        }
      },
      {
        type = "metric"
        properties = {
          title  = "API Gateway Latency p95"
          period = 300
          metrics = [
            ["AWS/ApiGateway", "IntegrationLatency", "ApiName", var.api_name, "Stage", var.api_stage, { stat = "p95" }],
          ]
        }
      },
      {
        type = "metric"
        properties = {
          title  = "API Gateway 5XX Errors"
          period = 300
          metrics = [
            ["AWS/ApiGateway", "5XXError", "ApiName", var.api_name, "Stage", var.api_stage],
          ]
        }
      },
    ]
  })
}

resource "aws_cloudwatch_dashboard" "cost" {
  dashboard_name = var.cost_dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "API Gateway Request Count"
          period = 86400
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiName", var.api_name, "Stage", var.api_stage],
          ]
        }
      },
      {
        type = "metric"
        properties = {
          title  = "DynamoDB Consumed Read/Write"
          period = 86400
          metrics = [
            ["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", var.catalog_table_name],
            ["AWS/DynamoDB", "ConsumedWriteCapacityUnits", "TableName", var.catalog_table_name],
          ]
        }
      },
    ]
  })
}
