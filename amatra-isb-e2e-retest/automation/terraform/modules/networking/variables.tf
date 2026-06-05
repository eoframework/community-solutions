variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "region" {
  description = "AWS deployment region"
  type        = string
}

variable "networking" {
  description = "Networking configuration object"
  type = object({
    vpc_cidr              = string
    public_subnet_cidrs   = list(string)
    private_subnet_cidrs  = list(string)
    database_subnet_cidrs = list(string)
    availability_zones    = list(string)
    nat_gateway_count     = number
    vpc_endpoint_s3                = bool
    vpc_endpoint_dynamodb          = bool
    vpc_endpoint_secrets_manager   = bool
    vpc_endpoint_bedrock_runtime   = bool
  })
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
