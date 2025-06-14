############################################
# Provider Configuration    -> To list, run: terraform providers
###########################################
provider "aws" {
  region              = var.region
  profile             = var.profile
  allowed_account_ids = [var.aws_account_id]
}

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.8"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--profile", var.profile]
    }
  }
}
provider "kubectl" {
  apply_retry_count      = 3
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--profile", var.profile]
  }
}

provider "aws" {
  region  = "us-east-1"
  alias   = "virginia"
  profile = var.profile
}



###############################################################################
# Data Sources
###############################################################################
data "aws_caller_identity" "current" {}

data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

############################################
# EKS Cluster
###########################################
module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "20.36.0" # Raf skip this version NEXT TIME- should deploy latest
  cluster_name                   = var.cluster_name
  cluster_version                = "1.31"
  cluster_endpoint_public_access = true
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }
  vpc_id                   = "vpc-00d014a4e0f6988f8"
  subnet_ids               = ["subnet-02fb6659a477dd3f9", "subnet-07fcd02390fc69bab", "subnet-07c9f171152e38d2e"] # private subnets
  control_plane_subnet_ids = ["subnet-02fb6659a477dd3f9", "subnet-07fcd02390fc69bab", "subnet-07c9f171152e38d2e"] # private subnets
  eks_managed_node_groups = {
    karpenter = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.large", "t2.large", "r5.large", "m5.large", "c5.large"]
      min_size       = 2
      max_size       = 4
      desired_size   = 2
      capacity_type  = "SPOT"
      taints = {
        # This Taint aims to keep just EKS Addons and Karpenter running on this MNG
        # The pods that do not tolerate this taint should run on nodes created by Karpenter
        addons = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        },
      }
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  node_security_group_tags = {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = var.cluster_name
  }
}
output "cluster_name" { value = module.eks.cluster_name }
output "node_iam_role_name" { value = module.karpenter.node_iam_role_name }
output "update_kubeconfig" { value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --profile ${var.profile}" }
############################################
# karpenter setup - aws
###########################################
module "karpenter" {
  source                          = "terraform-aws-modules/eks/aws//modules/karpenter" # latst version 20.36.0
  depends_on                      = [module.eks]
  cluster_name                    = module.eks.cluster_name
  enable_v1_permissions           = true
  enable_pod_identity             = true
  create_pod_identity_association = true

  # Attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
  # this module will create the karpenter controller and the karpenter node IAM role
  # will create node IAM role with the necessary permissions for karpenter to create instanc profiles and launch templates
  # will create sqs queue end event bridge rules for karpenter to utilize spot termination or capacity rebalancing etc...
}
# check version: kubectl get deployment -n kube-system karpenter -oyaml | grep image:

# output "zzzz" { value = module.karpenter }
output "karpenter_service_account" { value = module.karpenter.service_account }
output "karpenter_queue_name" { value = module.karpenter.queue_name }

############################################
# Karpenter setup - inside eks
###########################################
resource "helm_release" "karpenter" {
  namespace           = "kube-system"
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = "1.0.0" # "1.5.0"
  wait                = false

  values = [
    <<-EOT
    serviceAccount:
      name: ${module.karpenter.service_account}
    settings:
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    EOT
  ]
}
############################################
# Kubectl - node pool,class - ver 1.0.0
###########################################

# settings specific to aws
resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiSelectorTerms:
        - alias: bottlerocket@latest
      role: ${module.karpenter.node_iam_role_name}
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${module.eks.cluster_name}
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${module.eks.cluster_name}
      tags:
        karpenter.sh/discovery: ${module.eks.cluster_name}
  YAML

  depends_on = [helm_release.karpenter]
}

resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: default
    spec:
      template:
        spec:
          nodeClassRef:
            group: karpenter.k8s.aws
            kind: EC2NodeClass
            name: default
          requirements:
            - key: "karpenter.k8s.aws/instance-category"
              operator: In
              values: ["c", "m", "r"]
            - key: "karpenter.k8s.aws/instance-cpu"
              operator: In
              values: ["2", "4", "8"]
            - key: "karpenter.k8s.aws/instance-hypervisor"
              operator: In
              values: ["nitro"]
            - key: "karpenter.k8s.aws/instance-generation"
              operator: Gt
              values: ["2"]
      limits:
        cpu: 1000
      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 30s
  YAML

  depends_on = [kubectl_manifest.karpenter_node_class]
}



