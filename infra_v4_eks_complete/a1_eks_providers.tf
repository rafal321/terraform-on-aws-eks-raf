# ==== providers.tf ======
terraform {
  required_version = "~> 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = { # for installing LBC contlorer, ebs csi driver
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    http = { # for downloading IAM policy, any stuff from github
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    kubernetes = { # for installing ingressclass
      source  = "hashicorp/kubernetes"
      version = "~> 2.26"
    }
  }

  #  backend "local" {}
  backend "s3" {
    bucket         = "705192-terraform.state"
    key            = "terraform-state/infra_v4_eks_complete/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "infra_v4_eks_complete"
    profile        = "dev"
  }
}
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
