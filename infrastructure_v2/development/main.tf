terraform {
  required_version = "~> 1.6"
}
provider "aws" {
  region  = "eu-west-1"
  profile = "raf"
}

# == VPC ============================
module "vpc" {
  source     = "../modules/vpc/"
  aws_region = "eu-west-1"
  vpc_name   = "rkdev1"
  # aws_profile = "raf"
}
output "vpc_out" { value = module.vpc }

# == BASTION ========================
module "bastion" {
  source                = "../modules/bastion/"
  bastion_subnet        = element(module.vpc.vpc_public_subnets, 0)
  aws_region            = module.vpc.vpc_aws_region
  bastion_instance_type = "t3a.micro"
  bastion_key_name      = "testKey"
  bastion_iam_role      = null
  bastion_tag_name      = "Bastion"
  bastion_vol_size      = 12
  bastion_vpc_vpc_id    = module.vpc.vpc_vpc_id
  bastion_cidr_blocks  = ["1.2.3.4/32"]
}
output "bastion_out" { value = module.bastion }

# == EKS ========================