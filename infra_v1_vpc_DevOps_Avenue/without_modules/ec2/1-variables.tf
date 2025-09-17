# 1-variables.tf -> [ec2]

variable "profile" {
  type    = string
  default = "operations-aws" # UPDATE-XX
}
variable "region" {
  type    = string
  default = "us-east-1" # "eu-west-1" # UPDATE-XX
}
variable "common_tags" {
  type = map(string)
  default = {
    Owner       = "Rafal"
    Environment = "Development"
    Component   = "EC2"
    GitLocator  = "Git-placeholder"
    ManagedBy   = "Terraform"
    State       = "S3-placeholder"
  }
  description = "Common tags to be applied to all resources"
}
variable "common_name" {
  type        = string
  default     = "eks-2015t2"
  description = "Common name for all resources"
}
