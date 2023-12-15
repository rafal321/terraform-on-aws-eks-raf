variable "vpc_private_subnets" {
  description = "var.vpc_private_subnets"
  type        = list(any)
  default     = null
}
variable "eks_ng_private_name" {
  description = "var.eks_ng_private_name"
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
variable "eks_cluster_id" {
  description = "var.eks_cluster_id"
  type        = string
  default     = null
}
variable "ami_type" {
  description = "var.eks_cluster_id"
  type        = string
  default     = "AL2_x86_64"
}
variable "disk_size" {
  description = "var.eks_cluster_id"
  type        = number
  default     = 15
}
variable "instance_types" {
  description = "var.eks_cluster_id"
  type        = list(any)
  default     = ["t3.medium", "t2.medium", "t3a.medium"]
}
variable "min_size" {
  description = "var.eks_cluster_id"
  type        = number
  default     = 1
}
variable "desired_size" {
  description = "var.eks_cluster_id"
  type        = number
  default     = 1
}
variable "max_size" {
  description = "var.eks_cluster_id"
  type        = number
  default     = 4
}

