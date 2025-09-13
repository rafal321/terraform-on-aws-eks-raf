# ==== providers.tf ======
terraform {
  required_version = "~> 1.13.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.13.0"
    }
  }
  #  backend "local" {}
  backend "s3" {
    bucket       = "raf-ojt-bucket"
    key          = "terraform-state-vpc/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true #S3 native locking
    profile      = "operations-aws"
  }
}
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}


