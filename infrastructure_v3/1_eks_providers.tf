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
    bucket         = "705192-terraform.state"
    key            = "terraform-state/infrastructure-v3/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "infrastructure_v3_db"
    profile        = "dev"
  }
}
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
