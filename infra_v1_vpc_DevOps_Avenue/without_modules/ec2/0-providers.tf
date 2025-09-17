# 0-providers.tf -> [ec2]

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket       = "tsupplier-performance" # "raf-ojt-bucket" # UPDATE-XX
    key          = "terraform-state-ec2/terraform.tfstate"
    region       = "us-east-1" # "eu-west-1"  # UPDATE-XX
    use_lockfile = true
    profile      = "operations-aws"  # UPDATE-XX
  }
}
provider "aws" {
  region  = var.region
  profile = var.profile
}


