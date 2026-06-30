################################################################################
# Tier 2 — ML Platform Module
# SageMaker Feature Store, Endpoints, Pipelines configuration via SSM parameters.
# Actual SageMaker resources are provisioned by the CI/CD pipeline at deploy time;
# this module creates the supporting IAM roles, SSM parameters, and CloudWatch
# log groups needed by the ML inference layer.
################################################################################

# ---------------------------------------------------------------------------
# SageMaker Execution Role — used by all SageMaker resources
# ---------------------------------------------------------------------------
resource "aws_iam_role" "sagemaker_execution" {
  name = "${var.name_prefix}-sagemaker-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "sagemaker.amazonaws.com" }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "sagemaker_full" {
  role       = aws_iam_role.sagemaker_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_iam_role_policy" "sagemaker_s3" {
  name = "${var.name_prefix}-sagemaker-s3-policy"
  role = aws_iam_role.sagemaker_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket"
        ]
        Resource = [
          var.models_bucket_arn,
          "${var.models_bucket_arn}/*",
          var.datalake_bucket_arn,
          "${var.datalake_bucket_arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = [var.kms_s3_key_arn, var.kms_ebs_key_arn]
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# SageMaker Feature Store — CloudWatch log group
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "feature_store" {
  name              = "/aws/sagemaker/${var.name_prefix}/feature-store"
  retention_in_days = var.ml.cloudwatch_log_retention_days
  kms_key_id        = var.kms_ebs_key_arn

  tags = var.common_tags
}

# ---------------------------------------------------------------------------
# SSM Parameters — ML configuration (non-secret)
# ---------------------------------------------------------------------------
resource "aws_ssm_parameter" "sepsis_risk_threshold" {
  name  = "/medcore-cds/${var.environment}/ml/sepsis/risk_score_alert_threshold"
  type  = "String"
  value = tostring(var.ml.sepsis_risk_score_alert_threshold)
  description = "Sepsis risk score threshold above which alerts are generated"

  tags = var.common_tags
}

resource "aws_ssm_parameter" "feature_completeness_threshold" {
  name  = "/medcore-cds/${var.environment}/ml/feature_completeness_threshold"
  type  = "String"
  value = tostring(var.ml.feature_completeness_threshold)
  description = "Minimum feature completeness ratio for inference"

  tags = var.common_tags
}

resource "aws_ssm_parameter" "bedrock_prompt_version" {
  name  = "/medcore-cds/${var.environment}/ml/bedrock/prompt_template_version"
  type  = "String"
  value = var.ml.bedrock_prompt_template_version
  description = "Validated clinical narrative prompt template version for Bedrock"

  tags = var.common_tags
}

resource "aws_ssm_parameter" "bedrock_model_id" {
  name  = "/medcore-cds/${var.environment}/ml/bedrock/model_id"
  type  = "String"
  value = var.ml.bedrock_model_id
  description = "Amazon Bedrock Claude model ID for clinical narrative generation"

  tags = var.common_tags
}

resource "aws_ssm_parameter" "duplicate_suppression_ttl" {
  name  = "/medcore-cds/${var.environment}/ml/alert_duplicate_suppression_ttl_seconds"
  type  = "String"
  value = tostring(var.ml.duplicate_suppression_ttl_seconds)
  description = "Alert duplicate suppression TTL in seconds"

  tags = var.common_tags
}

# ---------------------------------------------------------------------------
# SageMaker Model Registry group
# ---------------------------------------------------------------------------
resource "aws_sagemaker_model_package_group" "this" {
  model_package_group_name        = var.ml.registry_name
  model_package_group_description = "MedCore CDS Platform — model registry for sepsis, readmission, and rapid-response models"

  tags = var.common_tags
}

# ---------------------------------------------------------------------------
# CloudWatch Log Groups for Lambda functions (ingestion pipeline)
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "fhir_connector" {
  name              = "/medcore-cds/${var.environment}/fhir-connector"
  retention_in_days = var.ml.cloudwatch_log_retention_days
  kms_key_id        = var.kms_ebs_key_arn

  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "hl7_adapter" {
  name              = "/medcore-cds/${var.environment}/hl7-adapter"
  retention_in_days = var.ml.cloudwatch_log_retention_days
  kms_key_id        = var.kms_ebs_key_arn

  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "inference_orchestrator" {
  name              = "/medcore-cds/${var.environment}/inference-orchestrator"
  retention_in_days = var.ml.cloudwatch_log_retention_days
  kms_key_id        = var.kms_ebs_key_arn

  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "alert_router" {
  name              = "/medcore-cds/${var.environment}/alert-router"
  retention_in_days = var.ml.cloudwatch_log_retention_days
  kms_key_id        = var.kms_ebs_key_arn

  tags = var.common_tags
}
