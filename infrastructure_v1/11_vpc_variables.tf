# ==== vpc_variables.tf ====
variable "aws_region" {
  description = "aws_region"
  type        = string
  default     = "eu-west-1"
}
variable "vpc_name" {
  description = "vpc_name"
  type        = string
  default     = "raf"
}
