# ==== 1_eks_providers.tf ======
# terraform {                                      RAF: moved to development/main.tf
#   # required_version = "~> 1.6"
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
#backend "local" {}
# backend "s3" {
#   bucket         = "raflinux"
#   key            = "terraform-state/vpc/terraform.tfstate"
#   region         = "eu-west-1"
#   dynamodb_table = "raf-vpc-terraform-state"
#   profile        = "raf"
# }