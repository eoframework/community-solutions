#------------------------------------------------------------------------------
# Ml Platform Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-30 01:10:29
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

ml = {
  # Maximum token count for Bedrock clinical narrative generation responses
  bedrock_max_tokens = 256
  # Amazon Bedrock Claude model ID for clinical narrative generation
  bedrock_model_id = "anthropic.claude-3-haiku-20240307-v1:0"
  # Version identifier for the validated clinical narrative prompt template stored in SSM
  bedrock_prompt_template_version = "v1.0"
  # Timeout in milliseconds for Bedrock invocations within the 3-second end-to-end SLA budget
  bedrock_timeout_ms = 2000
  # Maximum number of simultaneously monitored active inpatient records at peak load
  concurrent_patients_max = 200
  # Minimum feature completeness ratio below which a record is flagged as low_confidence and suppressed
  feature_store_feature_completeness_threshold = "0.7"
  # SageMaker Feature Store offline feature group name for weekly model retraining workflow
  feature_store_offline_feature_group_name = "medcore-cds-patient-features-offline"
  # SageMaker Feature Store online feature group name for real-time inference feature retrieval
  feature_store_online_feature_group_name = "medcore-cds-patient-features-online"
  # End-to-end inference latency target in milliseconds from Kinesis ingestion to alert dispatch at P95
  inference_latency_target_ms = 3000
  # SageMaker endpoint invocation latency budget in milliseconds within the overall 3-second SLA
  inference_sagemaker_latency_budget_ms = 2000
  # Enable SHAP explainability computation inline with every SageMaker inference call
  inference_shap_enabled = true
  # Expected monthly inference request volume across all active inpatients at full utilization
  inference_volume_monthly = 500000
  # CloudWatch alarm threshold for Kinesis consumer dead-letter queue message depth
  kinesis_dlq_alarm_threshold = 0
  # Kinesis Data Streams data retention period in hours
  kinesis_retention_hours = 24
  # Number of Kinesis Data Streams shards for HL7 event ingestion pipeline
  kinesis_shard_count = 2
  # Kinesis Data Streams stream name for real-time HL7 FHIR and HL7 v2.3 event ingestion
  kinesis_stream_name = "medcore-cds-qa-events"
  # SageMaker Model Registry model package group name governing version promotion
  model_registry_name = "medcore-cds-model-registry"
  # Cron expression for weekly SageMaker Pipelines model retraining schedule
  model_retraining_schedule_cron = "cron(0 2 ? * SUN *)"
  # Minimum AUROC required for sepsis model to be promoted to production via Model Registry
  model_sepsis_auroc_threshold = "0.80"
  # Sepsis risk score value above which an alert is generated and routed to clinical staff
  model_sepsis_risk_score_alert_threshold = "0.6"
  # Number of Amazon MSK brokers distributed one per Availability Zone
  msk_broker_count = 1
  msk_broker_instance_type = "kafka.m5.large"  # Amazon MSK broker instance type
  # Amazon MSK Kafka cluster name for internal event bus between ingestion and Feature Store pipeline
  msk_cluster_name = "medcore-cds-qa-kafka"
  # Kafka topic partition key for MSK topics ensuring per-patient event ordering
  msk_topic_partition_key = "PatientID"
}
