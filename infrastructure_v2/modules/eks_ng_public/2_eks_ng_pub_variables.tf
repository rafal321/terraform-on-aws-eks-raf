variable "vpc_public_subnets" {
  description = "var.vpc_public_subnets"
  type        = list(any)
  default     = null
}
variable "eks_ng_public_name" {
  description = "var.eks_ng_public_name"
  type        = string
  default     = "raf"
}
variable "aws_region" {
  description = "var.aws_region"
  type        = string
  default     = "eu-west-1"
}
variable "aws_profile" {
  description = "var.profile"
  type        = string
  default     = "default"
}
variable "eks_cluster_id" {
  description = "var.eks_cluster_id"
  type        = string
  default     = null
}
