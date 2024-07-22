provider "aws" {
  region  = local.region
  profile = local.profile

}
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }
}
# Datasource: AWS Caller Identity
data "aws_caller_identity" "current" {}

output "aws_account_id" { value = data.aws_caller_identity.current.account_id }
