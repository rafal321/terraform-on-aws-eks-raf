# ==== 2_vpc_variables.tf ====
# variable "aws_region" {
#   description = "var.aws_region"
#   type        = string
#   default     = "eu-west-1"
# }
variable "vpc_name" {
  description = "var.vpc_name"
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

variable "enable_nat_gateway" {
  description = "var.enable_nat_gateway"
  type        = string
  default     = "false"
}

variable "single_nat_gateway" {
  description = "var.single_nat_gateway"
  type        = string
  default     = "true"
}

# variable "aws_profile" {
#   description = "var.aws_profile"
#   type        = string
#   default     = "default"
# }
