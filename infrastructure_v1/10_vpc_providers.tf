# ==== providers.tf ======
terraform {
  #required_version = "~> 0.14" # which means any version equal & above 0.14 like 0.15, 0.16 etc and < 1.xx
  required_version = "~> 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  /*  
  backend "s3" {
    bucket = "ojt.backups.test.opsdevops"
    key    = "a-raf-terraform-state/raf-vpc/terraform.tfstate"
    region = "eu-west-1"

    # For State Locking
    dynamodb_table = "terraform-raf-vpc"
  }
  */
  backend "local" {}

}

provider "aws" {
  region  = "eu-west-1"
  profile = "raf"
}

