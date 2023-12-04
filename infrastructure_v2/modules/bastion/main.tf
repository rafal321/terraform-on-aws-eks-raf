variable "bastion_subnet" { type = string }
variable "aws_region" { type = string }
variable "bastion_instance_type" { type = string }
variable "bastion_key_name" { type = string }
variable "bastion_iam_role" { type = string }
variable "bastion_tag_name" { type = string }
variable "bastion_vol_size" { type = number }
variable "bastion_vpc_vpc_id" {type = string}
variable "bastion_cidr_blocks" {type = list} 
#======================================
# --- latest AMI ---
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
# --- bastion EC2 ----
resource "aws_instance" "aws_instance" {
  ami                  = data.aws_ami.amazon-linux-2.id
  instance_type        = var.bastion_instance_type
  subnet_id            = var.bastion_subnet
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
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
#================================================
# --- bastion SG ----
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.bastion_vpc_vpc_id
  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.bastion_cidr_blocks
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.bastion_tag_name}-sg"
    managed_by = "terraform"
  }
}
# ===========================================
# --- outputs -----
output "bastion_instance_id" {
  value = aws_instance.aws_instance.id
}
output "bastion_ssh_security_group__ids" {
  value = aws_instance.aws_instance.vpc_security_group_ids
}