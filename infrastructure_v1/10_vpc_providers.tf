# ==== providers.tf ======
terraform {
  required_version = "~> 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  #  backend "local" {}
  backend "s3" {
    bucket = "raflinux"
    key    = "terraform-state/vpc/terraform.tfstate"
    region = "eu-west-1"
    dynamodb_table = "raf-vpc-terraform-state"
    profile = "raf"
  }
}
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

