variable "region" {
  description = "AWS region where the EKS cluster will be created"
  type        = string
  default     = "eu-west-1"
}
variable "aws_accout_id" {
  description = "AWS account ID where the EKS cluster will be created"
  type        = string
  default     = "863772705192"
}
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eksautomode"
}
variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
  default     = "1.31"
}
variable "profile" {
  description = "Version of the EKS cluster"
  type        = string
  default     = "dev"
}