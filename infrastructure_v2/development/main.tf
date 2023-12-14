terraform {
  required_version = "~> 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region  = "eu-west-1"
  profile = "dev"
  default_tags {
    tags = {
      Environment     = "Test"
      Service         = "Example"
      HashiCorp-Learn = "aws-default-tags"
      ManagedBy       = "terraform"
      Workspace       = terraform.workspace
    }
  }
}

# == VPC ============================
module "vpc" {
  source = "../modules/vpc/"
  # aws_region         = "eu-west-1"
  # aws_profile        = "dev"
  vpc_name           = "rkdev1"
  enable_nat_gateway = false
  single_nat_gateway = true
}
output "vpc_out" { value = module.vpc }
# Example module.vpc.vpc_aws_region

# == BASTION ========================
/*
module "bastion" {
  source                = "../modules/bastion/"
  bastion_subnet        = element(module.vpc.vpc_public_subnets, 0)
  aws_region            = module.vpc.vpc_aws_region
  bastion_instance_type = "t3a.micro"
  bastion_key_name      = "ops.devops.test.ec2-user" # "testKey"
  bastion_iam_role      = null
  bastion_tag_name      = "Bastion"
  bastion_vol_size      = 12
  bastion_vpc_vpc_id    = module.vpc.vpc_vpc_id
  bastion_cidr_blocks   = ["54.171.162.185/32"]
}
output "bastion_out" { value = module.bastion }
*/
# == EKS (resource) ========================
# module "eks" {
#   source             = "../modules/eks/"
#   eks_name           = "raf-eks-cluster"
#   cluster_version    = "1.28"
#   aws_region         = "eu-west-1"
#   aws_profile        = "dev"
#   vpc_public_subnets = module.vpc.vpc_public_subnets          # where eks ENIs are created
#   #cluster_service_ipv4_cidr= "172.20.0.0/16"
#   # cluster_endpoint_private_access= false   # was false
#   #cluster_endpoint_public_access= true   # was true
#   cluster_endpoint_public_access_cidrs = [
#     "185.122.134.73/32","3.254.50.156/32"
#     ] # ["0.0.0.0/0"]
# }
# output "eks_out" { value = module.eks }
# Example module.eks.eks_cluster_id

# == EKS Node Group Public/Private - SPOT (resource) =================
# module "eks_ng_public" {
#   source             = "../modules/eks_ng_public/"
#   eks_ng_public_name = "raf"
#   aws_region         = "eu-west-1"
#   aws_profile        = "dev"
#   vpc_public_subnets = module.vpc.vpc_public_subnets
#   eks_cluster_id     = module.eks.eks_cluster_id
#   ami_type           = "AL2_x86_64"
#   disk_size          = 15
#   instance_types     = ["t3.medium", "t2.medium", "t3a.medium"]
#   min_size           = 1
#   desired_size       = 1
#   max_size           = 8
# }
# output "eks_ng_public_out" { value = module.eks_ng_public }
#----------------------------------------------------------------------------
# module "eks_ng_private" {                                 # terraform destroy -target=module.eks_ng_private.aws_eks_node_group.eks_ng_private
#   source              = "../modules/eks_ng_private/"
#   eks_ng_private_name = "raf2"
#   aws_region          = "eu-west-1"
#   aws_profile         = "dev"
#   vpc_private_subnets = module.vpc.vpc_private_subnets
#   eks_cluster_id      = module.eks.eks_cluster_id
#   ami_type            = "AL2_x86_64"
#   disk_size           = 15
#   instance_types      = ["t3.medium", "t2.medium", "t3a.medium"]
#   min_size            = 1
#   desired_size        = 1
#   max_size            = 8
# }
# output "eks_ng_private_out" { value = module.eks_ng_private }
#----------------------------------------------------------------------------


# next 116. Step-01: Introduction to Terraform Remote State Storage and State Locking

# == EKS Node Group Private (resource) ========================