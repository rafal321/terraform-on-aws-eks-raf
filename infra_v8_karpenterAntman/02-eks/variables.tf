############################################
# Variables 
###########################################
variable "region" {
  description = "AWS region where the resources will be created"
  type        = string
}
variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}
variable "profile" {
  description = "AWS CLI profile to use"
  type        = string
}
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}