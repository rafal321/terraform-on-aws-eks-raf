# Terraform Block
terraform {
  #required_version = ">= 1.0" # which means any version equal & above 0.14 like 0.15, 0.16 etc and < 1.xx
  required_version = "~> 1.6"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = ">= 3.0"
      version = ">= 4.65"
    }
  }
  backend "s3" {
    bucket         = "raflinux"
    key            = "terraform-state/eks/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-eks"
    profile        = "raf"
  }
}
# Provider Block
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
