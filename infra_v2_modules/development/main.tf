terraform {
  required_version = "~> 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
  backend "s3" {
    bucket         = "705192-terraform.state"
    key            = "terraform-state/infrastructure-v2/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "infrastructure_v2_db"
    profile        = "dev"
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "dev"
  default_tags {
    tags = {
      Environment     = "Test2222"
      Service         = "Example"
      HashiCorp-Learn = "aws-default-tags"
      ManagedBy       = "terraform"
      Workspace       = terraform.workspace
    }
  }
}

##############################################################################
# #### VPC (module) ##########################################################
module "vpc" {
  source = "../modules/vpc/"
  #E aws_region         = "eu-west-1"
  #E aws_profile        = "dev"
  vpc_name           = "rkdev1"
  enable_nat_gateway = true
  single_nat_gateway = true
}
output "vpc_out" { value = module.vpc } # Example module.vpc.vpc_aws_region
#################################################################################
###### BASTION (resource) #######################################################
/*
module "bastion" {
  source                = "../modules/bastion/"
  bastion_subnet        = element(module.vpc.vpc_public_subnets, 0)
  aws_region            = module.vpc.vpc_aws_region
  bastion_instance_type = "t3a.micro"
  bastion_key_name      = "ops.devops.test.ec2-user"         # "testKey"
  bastion_iam_profile   = "OJT_EC2ControllerInstanceProfile" # null
  bastion_tag_name      = "Bastion"
  bastion_vol_size    = 12
  bastion_vpc_vpc_id  = module.vpc.vpc_vpc_id
  bastion_cidr_blocks = ["54.171.162.185/32"]
}
output "bastion_out" { value = module.bastion }
*/
########################################################################################
###### EKS (resource) ##################################################################
#/*
module "eks" {
  source          = "../modules/eks/"
  eks_name        = "raf-eks-cl"
  cluster_version = "1.28"
  enable_ebs_eks_addon = true
  # aws_region      = module.vpc.vpc_aws_region # need for helm only e4_lbc...
  # vpc_id          = module.vpc.vpc_vpc_id     # need for helm only e4_lbc...
  # aws_profile        = "dev"
  vpc_public_subnets = module.vpc.vpc_public_subnets # where eks ENIs are created 
  # cluster_service_ipv4_cidr= "172.20.0.0/16"
  # cluster_endpoint_private_access= false   # was false
  # cluster_endpoint_public_access= true   # was true
  cluster_endpoint_public_access_cidrs = [
    "0.0.0.0/0"
    # "109.255.232.193/32","185.122.134.73/32","3.254.50.156/32" RAF: NodeCreationFailure: Instances failed to join the kubernetes cluster >> ensure that either the cluster's private endpoint access is enabled, or that you have correctly configured CIDR blocks for public endpoint access.
  ]
}
output "eks_out" { value = module.eks }
#*/
# Example: module.eks.eks_cluster_id
# Example: value = data.terraform_remote_state.eks.outputs.eks_out.eks_cluster_id  -> /home/ec2-user/terraform-on-aws-eks/13-EKS-IRSA/rk2-02-eks-irsa-demo-terraform-manifests/c2-remote-state-datasource.tf
########################################################################################
###### EKS Node Group Public - SPOT (resource) #########################################
#/*
module "eks_ng_public" {
  source             = "../modules/eks_ng_public/"
  eks_ng_public_name = "raf-1"
  #aws_region         = "eu-west-1"
  #aws_profile        = "dev"
  vpc_public_subnets = module.vpc.vpc_public_subnets
  eks_cluster_id     = module.eks.eks_cluster_id
  ami_type           = "AL2_x86_64" #"BOTTLEROCKET_x86_64"  # "AL2_x86_64"
  disk_size          = 25
  instance_types     = ["t3.medium", "t2.medium", "t3a.medium"]
  min_size           = 2
  desired_size       = 2
  max_size           = 8
}
output "eks_ng_public_out" { value = module.eks_ng_public }
#*/
########################################################################################
###### EKS Node Group Private - SPOT (resource) ########################################
/*
module "eks_ng_private" {
  source              = "../modules/eks_ng_private/"
  eks_ng_private_name = "raf-21"
  # aws_region          = "eu-west-1"
  # aws_profile         = "dev"
  vpc_private_subnets = module.vpc.vpc_private_subnets
  eks_cluster_id      = module.eks.eks_cluster_id
  ami_type            = "BOTTLEROCKET_x86_64" # "AL2_x86_64" # "BOTTLEROCKET_x86_64"
  disk_size           = 25
  instance_types      = ["t3a.medium", "t3.medium", "t2.medium"]
  min_size            = 2
  desired_size        = 2 # managed by autoscaling
  max_size            = 10
}
output "eks_ng_private_out" { value = module.eks_ng_private }
*/
########################################################################################
###### RDS for MySQL  (resource) #######################################################
/*
module "rds_for_mysql" {
  source                         = "../modules/rds_for_mysql/"
  rds_for_mysql_name             = "raf-rds2"
  instance_class                 = "db.t4g.medium" # "db.t3.medium"
  replica_db_enable              = 0
  vpc_database_subnet_group_name = module.vpc.vpc_database_subnet_group_name
  vpc_vpc_id                     = module.vpc.vpc_vpc_id
  vpc_vpc_cidr_block             = module.vpc.vpc_vpc_cidr_block
  kms_key_id                     = null # "arn:aws:kms:eu-west-1:863772705192:key/mrk-92b9f6b3d690460bbcb6d3c2951f39b7"
  storage_encrypted              = false
}
output "rds_for_mysql_out" { value = module.rds_for_mysql }
*/
########################################################################################
###### Whatever next goes here  ########################################################


########################
/*
> ~/.kube/config &&
aws eks --region eu-west-1 update-kubeconfig --name raf-eks-cluster --profile dev

# FOR EC2
kubectl -n kube-system get configmap aws-auth -o yaml | y
kubectl edit -n kube-system configmap/aws-auth

  mapUsers: |
    - userarn: arn:aws:iam::863772705192:role/OJT_EC2ControllerInstanceRole
      username: whatever
      groups:
        - system:masters
######################## 
----------------------------------------------------
I  ] NEXT: aws-eks-kubernetes-masterclass
107. Step-01: Introduction to ALB Ingress External DNS Install
08-06-Deploy-ExternalDNS-on-EKS
 - - - - - - - - - - - - - - - - - - - - - - - - - -
II ] NEXT: terraform-on-aws-eks
    Section 26. AWS Load Balancer Controller Install using Terraform Helm Provider 
    ... HELM stuff ...
----------------------------------------------------

resource "aws_instance" "rkec2" {
ami = ...  
instance_type (
  terraform.workspace == "default" ? "t3.small" : "t3.micro"
)
}


dbadmin  dbpassword11

*/
