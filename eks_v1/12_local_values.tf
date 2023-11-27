# Define Local Values in Terraform
locals {
  #===owners      = var.business_divsion
  #===environment = var.environment
  # name = "${var.customer}-${var.environment}"
  #name = "${local.owners}-${local.environment}"
  common_tags = {
    customer    = var.customer
    environment = var.environment
    managedBy   = "terraform"
    tag1        = "value1"
    tag2        = "value2"
  }
  # eks_cluster_name = "${var.customer}-${var.environment}"
}
