#------------------------------------------------------------------------------
# Compute Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-30 01:10:29
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

compute = {
  # ECS cluster name for dashboard and API backend Fargate tasks
  ecs_cluster_name = "medcore-cds-prod-cluster"
  # Maximum ECS Fargate task count for auto-scaling ceiling
  ecs_scaling_max = 12
  # Minimum ECS Fargate task count across all AZs for dashboard and API tiers
  ecs_scaling_min = 4
  # CPU units allocated per ECS Fargate task (1024 = 1 vCPU)
  ecs_task_cpu = 2048
  # Memory in MB allocated per ECS Fargate task
  ecs_task_memory_mb = 4096
  # Memory in MB for alert routing Lambda (EventBridge to SNS and Epic CDS Hooks write-back)
  lambda_alert_router_memory_mb = 512
  # Memory in MB for Epic FHIR R4 connector Lambda function
  lambda_fhir_connector_memory_mb = 1024
  # Timeout in seconds for Epic FHIR R4 connector Lambda function
  lambda_fhir_connector_timeout_seconds = 30
  # Memory in MB for HL7 v2.3 Mirth Connect adapter Lambda function
  lambda_hl7_adapter_memory_mb = 1024
  # Timeout in seconds for HL7 v2.3 Mirth Connect adapter Lambda function
  lambda_hl7_adapter_timeout_seconds = 30
  # Memory in MB for inference orchestrator Lambda (retrieves features and invokes SageMaker endpoints)
  lambda_inference_orchestrator_memory_mb = 2048
  # SageMaker real-time inference endpoint instance type for rapid-response / early deterioration model (Phase 2)
  sagemaker_rapid_response_endpoint_instance_type = "ml.m5.xlarge"
  # Minimum instance count for rapid-response SageMaker endpoint
  sagemaker_rapid_response_endpoint_min_instances = 2
  # SageMaker real-time inference endpoint instance type for 30-day readmission model (Phase 2)
  sagemaker_readmission_endpoint_instance_type = "ml.m5.xlarge"
  # Minimum instance count for readmission SageMaker endpoint
  sagemaker_readmission_endpoint_min_instances = 2
  # SageMaker real-time inference endpoint instance type for sepsis risk model
  sagemaker_sepsis_endpoint_instance_type = "ml.m5.xlarge"
  # Maximum instance count for sepsis SageMaker endpoint auto-scaling policy
  sagemaker_sepsis_endpoint_max_instances = 6
  # Minimum instance count for sepsis SageMaker endpoint; ensures multi-AZ coverage
  sagemaker_sepsis_endpoint_min_instances = 2
  # SageMaker training job instance type for weekly model retraining pipelines
  sagemaker_training_instance_type = "ml.p3.2xlarge"
}
