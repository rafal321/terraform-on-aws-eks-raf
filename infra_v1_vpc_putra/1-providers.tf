# https://youtu.be/aRXg75S5DWA?si=9MHTY44BOYxo3zrs
# terraform block: only constant values, no variables

terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.72"
    }
  }
  # backend "s3" {
  #   bucket         = "my_bucket"
  #   key            = "state/terraform.tfstate"
  #   dynamodb_table = "mycomponents_tf_lockid"
  # }
}
provider "aws" {
  profile = local.profile
}

# Datasource: AWS Caller Identity
data "aws_caller_identity" "current" {}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

