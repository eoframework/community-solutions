#------------------------------------------------------------------------------
# Ml Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-08 21:29:43
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

ml = {
  # Minimum classifier agreement percentage required on holdout evaluation
  classifier_accuracy_target_pct = 90
  # NLP classifier confidence below which Bedrock FM fallback is invoked
  classifier_confidence_threshold = "0.75"
  # Minimum number of approved emotion/mood labels in the taxonomy
  mood_taxonomy_min_labels = 10
  # Minimum user interactions before Personalize includes user in training
  personalize_min_interactions = 25
  # Promote new model only when accuracy exceeds previous version on holdout set
  retraining_conditional_promotion = true
  # EventBridge Scheduler cron for weekly SageMaker Pipelines retraining run
  retraining_schedule_expression = "cron(0 2 ? * MON *)"
  # Number of previous approved model versions to keep in SageMaker Registry
  sagemaker_max_versions_retained = 3
  # SageMaker Model Registry package group name for versioned model management
  sagemaker_model_registry_name = "anp-recommendation-model-registry"
}
