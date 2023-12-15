
variable "vpc_public_subnets" {
  description = "var.vpc_public_subnets"
  type        = list(any)
  default     = null
}
variable "eks_name" {
  description = "var.eks_name"
  type        = string
  default     = "raf"
}
# variable "aws_region" {
#   description = "var.aws_region"
#   type        = string
#   default     = "eu-west-1"
# }
# variable "aws_profile" {
#   description = "var.profile"
#   type        = string
#   default     = "default"
# }
variable "cluster_service_ipv4_cidr" {
  description = "service ipv4 cidr for the kubernetes cluster"
  type        = string
  #default     = null
  default = "172.20.0.0/16"
  # # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
}
variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = false
}
variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true`."
  type        = bool
  default     = true
}
variable "cluster_version" {
  description = "Kubernetes minor version to use for the EKS cluster (for example 1.21)"
  type        = string
  #default     = null
  default = "1.28"
}
variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
  #  default     = ["10.30.0.0/16", "109.255.232.193/32"]
}
# Define Local Values in Terraform
# locals {
#   common_tags = {
#     commonTag = "commonValue"
#   }
# }