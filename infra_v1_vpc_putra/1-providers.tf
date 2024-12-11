# Create AWS VPC using Terraform: AWS EKS Kubernetes Tutorial - Part 1
# https://youtu.be/aRXg75S5DWA?si=9MHTY44BOYxo3zrs
# terraform block: only constant values, no variables
# Comments:
#Q:  Great vid but why not use the community modules?.Is there a specific reason to choose resources over modules?.
#A:  This playlist is for someone who wants to learn EKS. If you have a good understanding of EKS and how it works, you can use modules. However, I personally would create my own modules because I don't want to depend on other people's timelines. For example, the open-source eks module still uses the EKS auth configmap for adding new users.

terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.72"
    }
  }
  # backend "s3" {
  #   bucket         = "my_bucket"
  #   key            = "state/terraform.tfstate"
  #   dynamodb_table = "mycomponents_tf_lockid"
  # }
}
provider "aws" {
  profile = local.profile
}

# Datasource: AWS Caller Identity
data "aws_caller_identity" "current" {}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

# Contains how to work with tf.state
# https://www.youtube.com/playlist?list=PLiMWaCMwGJXmJdmfJjG3aK1IkU7oWvxIj
# An Introduction to Terraform
# How to manage Terraform State?
# How to Manage Secrets in Terraform?
# Terraform Tips & Tricks: loops, if-statements, and more
# How To Structure Terraform Project (3 Levels)