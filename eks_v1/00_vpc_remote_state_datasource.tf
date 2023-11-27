data "terraform_remote_state" "vpc_terraform_state" {
  backend = "s3"
  config = {
    bucket  = "raflinux"
    key     = "terraform-state/vpc/terraform.tfstate"
    region  = "eu-west-1"
    profile = "raf"
  }
}
