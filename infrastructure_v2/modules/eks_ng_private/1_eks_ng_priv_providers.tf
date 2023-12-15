# terraform {
#   # required_version = "~> 1.6"             RAF: moved to development/main.tf
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }
# provider "aws" {
#   region  = var.aws_region
#   profile = var.aws_profile
#   default_tags {
#     tags = {
#       Environment     = "Test"
#       Service         = "Example"
#       HashiCorp-Learn = "aws-default-tags"
#       ManagedBy       = "eks-terraform"
#       Workspace       = terraform.workspace
#     }
#   }
# }