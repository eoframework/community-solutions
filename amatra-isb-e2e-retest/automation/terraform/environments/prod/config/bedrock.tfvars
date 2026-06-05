#------------------------------------------------------------------------------
# Bedrock Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-05 19:11:53
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

bedrock = {
  # AWS region where Bedrock AgentCore Runtime hosts the five Strands agents
  agentcore_runtime_region = "us-west-2"
  # Maximum acceptable Bedrock model spend per 12-artifact solution bundle per SOW success metric
  cost_per_solution_target_usd = "5.00"
  # Target Bedrock Sonnet 4.6 input token volume per month at PoC steady state (~50 solutions/month)
  input_tokens_monthly_sonnet = 3000000
  # Target Bedrock Sonnet 4.6 output token volume per month at PoC steady state
  output_tokens_monthly_sonnet = 1000000
  # Claude Sonnet 4.6 model ID used by Pre-Sales / Delivery / Code Generator agents for artifact generation
  primary_model_id = "anthropic.claude-sonnet-4-5"
  # Claude Haiku 4.5 model ID used by EO Validator agent for cost-efficient quality scoring
  validator_model_id = "anthropic.claude-haiku-4-5"
}
