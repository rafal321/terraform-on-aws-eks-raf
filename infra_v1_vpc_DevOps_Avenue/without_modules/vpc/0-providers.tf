terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket       = "tsupplier-performance" # "raf-ojt-bucket" # UPDATE-XX
    key          = "terraform-state-vpc/terraform.tfstate"
    region       = "us-east-1" # "eu-west-1"  # UPDATE-XX
    use_lockfile = true
  }
}
provider "aws" {
  region  = var.region
  profile = var.profile
}
