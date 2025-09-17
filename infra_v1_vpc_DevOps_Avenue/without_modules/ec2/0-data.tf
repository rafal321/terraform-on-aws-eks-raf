# 0-data.tf -> [ec2]

data "aws_caller_identity" "current" {}
output "ec2_aws_account_id" { value = data.aws_caller_identity.current.account_id }

data "terraform_remote_state" "vpc_data" {
  backend = "s3"
  config = {
    bucket  = "tsupplier-performance" # "raf-ojt-bucket" # UPDATE-XX
    key     = "terraform-state-vpc/terraform.tfstate"
    region  =  "us-east-1" #"eu-west-1" # UPDATE-XX
    profile = "operations-aws"
  }
}

# Example outputs to access VPC remote state values
# output "ec2_vpc_remote" { value = data.terraform_remote_state.vpc_data.outputs }
# output "ec2_vpc_public_subnet_ids_0" { value = data.terraform_remote_state.vpc_data.outputs.vpc_public_subnet_ids[0] }

# this is very common pattern to share data between different tf states (Putra)
# https://www.youtube.com/watch?v=nMVXs8VnrF4 (21:40)

# ===================================================

# vpc_available_azs = tolist([
#   "eu-west-1a",
#   "eu-west-1b",
#   "eu-west-1c",
# ])
# vpc_aws_account_id = "411929112137"
# vpc_common_name = "eks-1053t"
# vpc_database_subnet_ids = [
#   "subnet-0efb4e93a19a11856",
#   "subnet-0ed9aa0c225d40118",
# ]
# vpc_id = "vpc-0f88cc5afd957e764"
# vpc_private_subnet_ids = [
#   "subnet-079cd2a47b719918a",
#   "subnet-01fccc11d6c78a2da",
# ]
# vpc_public_subnet_ids = [
#   "subnet-0e69f006d936371dc",
#   "subnet-084002ceaf992c9ef",
# ]
# vpc_secondary_subnet_ids = [
#   "subnet-063e900a1b859b972",
#   "subnet-02a436eeb1e408b82",
# ]