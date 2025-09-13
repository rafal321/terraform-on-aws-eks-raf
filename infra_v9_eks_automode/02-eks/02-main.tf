terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.3.0"
}
provider "aws" {
  region              = var.region
  allowed_account_ids = [var.aws_accout_id]
  profile             = var.profile
}

################################################
# EKS Cluster
################################################
module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "20.36.0"
  cluster_name                   = var.eks_cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true
  cluster_addons = {
    eks-pod-identity-agent = {}
    #kube-proxy             = {}
    #vpc-cni                = {}
  }
  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets
  # subnet_ids = ["subnet-02fb6659a477dd3f9", "subnet-07fcd02390fc69bab", "subnet-07c9f171152e38d2e"]
  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

# this block enable automode for EKS cluster
  cluster_compute_config = {
    enabled    = true
    node_pools = ["system","general-purpose"] # ["general-purpose"]
  }
  # eks_managed_node_groups = {
  #   db-only = {
  #     # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
  #     ami_type       = "AL2023_x86_64_STANDARD"
  #     instance_types = ["t3.large", "t2.large", "r5.large", "m5.large", "c5.large"]
  #     min_size       = 2 # can be managed by cluster-autoscaler, these nodes are in autoscaling group
  #     max_size       = 3 # karpenter is no using autoscaling-group
  #     desired_size   = 2
  #     capacity_type  = "SPOT"
  #     taints = {
  #       # This Taint aims to keep just EKS Addons and Karpenter running on this MNG
  #       # The pods that do not tolerate this taint should run on nodes created by Karpenter
  #       addons = {
  #         key    = "db-only"
  #         value  = "true"
  #         effect = "NO_SCHEDULE"
  #       },
  #     }
  #   }
  # }
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
output "update_kubeconfig" { value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --profile ${var.profile}" }

#####
# kubectl api-resources | grep kar

# helm install metrics-server metrics-server/metrics-server --namespace kube-system --set "args={--kubelet-insecure-tls}"

###----
# values.yaml
# args:
#   - --kubelet-insecure-tls
# nodeSelector:
#   karpenter.sh/nodepool: system
# tolerations:
#   - key: CriticalAddonsOnly
#     operator: Exists
#   - key: your-key
#     operator: Equal
#     value: your-value
#     effect: NoSchedule

# helm install metrics-server metrics-server/metrics-server \
#   --namespace kube-system \
#   -f values.yaml
###----