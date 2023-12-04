variable "bastion_subnet" { type = string }
variable "aws_region" { type = string }
variable "bastion_instance_type" { type = string }
variable "bastion_key_name" { type = string }
variable "bastion_iam_role" { type = string }
variable "bastion_tag_name" { type = string }
variable "bastion_vol_size" { type = number }
#======================================
# latest AMI
data "aws_ami" "amazon-linux-2" { # RAF : this one is newer!!!
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5*"]
  }
}
#==================================================
resource "aws_instance" "aws_instance" {
  ami                  = data.aws_ami.amazon-linux-2.id
  instance_type        = var.bastion_instance_type
  subnet_id            = var.bastion_subnet
  key_name             = var.bastion_key_name
  iam_instance_profile = var.bastion_iam_role
  tags = {
    Name = var.bastion_tag_name
    managed_by     = "terraform"
  }
    root_block_device {
    volume_size           = var.bastion_vol_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
    tags = {
      Name       = "${var.bastion_tag_name}-root"
      managed_by = "terraform"
    }
  }
}
output "bastion_instance_id" {
  value = aws_instance.aws_instance.id
}

