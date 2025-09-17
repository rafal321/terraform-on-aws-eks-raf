variable "profile" {
  type    = string
  default = "operations-aws" # UPDATE-XX
}
variable "region" {
  type    = string
  default = "us-east-1" # "eu-west-1" # UPDATE-XX
}
variable "cidr_block" {
  type    = string
  default = "10.11.0.0/16"
}
variable "common_tags" {
  type = map(string)
  default = {
    Owner       = "Rafal"
    Environment = "Development"
    Component   = "VPC"
    GitLocator  = "Git-placeholder"
    ManagedBy   = "Terraform"
    State       = "S3-placeholder"
  }
  description = "Common tags to be applied to all resources"
}
variable "common_name" {
  type        = string
  default     = "eks-2016t"
  description = "Common name for all resources"
}
variable "az_count" {
  type        = number
  default     = 4
  description = "Number of availability zones to use"
}

output "vpc_common_name" { value = var.common_name }
# export AWS_PROFILE="my_default_profile_name"