# terraform {
#   # required_version = "~> 1.6"
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"     RAF: moved to development/main.tf
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