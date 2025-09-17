# 4-ec2-instance.tf -> [ec2]

data "aws_ami" "ubuntu_24_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu publisher)
  filter {
    name   = "name"
    values = ["*ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# output "ubuntu_ami_id" {  value = data.aws_ami.ubuntu_24_04 }

# Use the AMI ID in your EC2 instance
resource "aws_instance" "example" {
  ami                  = data.aws_ami.ubuntu_24_04.id
  instance_type        = "t3.micro"
  subnet_id            = data.terraform_remote_state.vpc_data.outputs.vpc_public_subnet_ids[0]
  iam_instance_profile = "OJT_EC2ControllerInstanceProfile"
  user_data            = "user_data_10.sh"
  tags = {
    Name = "Ubuntu_24.04_Instance"
  }
  root_block_device {
    volume_size           = 15
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
    tags = {
      Name      = "Ubuntu_24.04_Instance-root"
      ManagedBy = "terraform"
    }
  }
}

