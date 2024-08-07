variable "aws_region" {
  description = "var.aws_region"
  type        = string
  default     = "eu-west-1"
}
variable "aws_profile" {
  description = "var.aws_profile"
  type        = string
  default     = "lab"
}
#--------------------------------------------------------
# EKS Cluster Input Variables
variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
  default     = "ekslab01"
}
variable "vpc_public_subnets" {
  description = "var.vpc_public_subnets"
  type        = list(any)
  default     = ["subnet-0e325118b5eed09ea", "subnet-04a4b5654d58a32e1"] # PUBLIC
}

variable "vpc_private_subnets" {
  description = "var.vpc_private_subnets"
  type        = list(any)
  default     = ["subnet-0d5470217e38223f0", "subnet-0ea99efb622eec153"] # PRIVATE
}

variable "cluster_service_ipv4_cidr" {
  description = "service ipv4 cidr for the kubernetes cluster"
  type        = string
  default     = "172.20.0.0/16"
  # default     = null
  # Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks [...]
}

variable "cluster_version" {
  description = "Kubernetes minor version to use for the EKS cluster (for example 1.21)"
  type        = string
  default     = "1.28" # null # 1.28
}
variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = false # this is default
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true`."
  type        = bool
  default     = true # this is default
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
#--------------------------------------------------------
# cluster addons  -->list all addons:     aws eks list-addons --cluster XXX
variable "enable_ebs_eks_addon" {
  description = "If set to true, enable ebs_eks_addon"
  type        = bool
  default     = false
}
variable "lbc_image_repo" {
  description = "https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html"
  type        = string
  default     = "602401143452.dkr.ecr.eu-west-1.amazonaws.com/amazon/aws-load-balancer-controller"
}

#--------------------------------------------------------
# EKS Node Group Variables
## Placeholder space you can create if required
variable "ami_type" {
  description = "var.eks_cluster_id"
  type        = string
  default     = "BOTTLEROCKET_x86_64" # "AL2_x86_64"
}
variable "disk_size" {
  description = "var.eks_cluster_id"
  type        = number
  default     = 20
}
variable "instance_types" {
  description = "var.eks_cluster_id"
  type        = list(any)
  default     = ["t3a.medium", "t3.medium", "t2.medium"]
}
variable "min_size" {
  description = "var.eks_cluster_id"
  type        = number
  default     = 2
}
variable "desired_size" {
  description = "var.eks_cluster_id"
  type        = number
  default     = 2
}
variable "max_size" {
  description = "var.eks_cluster_id"
  type        = number
  default     = 8
}

