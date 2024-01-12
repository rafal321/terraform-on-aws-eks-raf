terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}
provider "aws" {
  region  = "eu-west-1"
  profile = "dev"
}
################################################################################


################################################################################
### DB CREDENTIALS START
# -- cred [2] - ssm_parameter -------------
# {"username":"dbadmin","password":"dbpassword11"}
data "aws_ssm_parameter" "db_creds" {
  name = "rk_terraform_db_cred"
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-f792228e" # default vpc 172.31.0.0/16
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name   = "allow_tls"
    reason = "playground"
    # has = data.aws_ssm_parameter.db_creds.value
    val1 = local.db_creds_local.username
    val2 = local.db_creds_local.password
  }
}

locals {
  db_creds_local = jsondecode(data.aws_ssm_parameter.db_creds.insecure_value)
} # username = local.db_creds.username  |  password = local.db_creds.password


output "sg_out_1" {
  value = aws_security_group.allow_tls.tags
}

output "data1" {
  value = data.aws_ssm_parameter.db_creds.value
  sensitive = true
  # terraform output data1
}

output "data2" {
  value = local.db_creds_local.username
}
output "data3" {
  value = local.db_creds_local.password
}
### DB CREDENTIALS END
################################################################################




















#======================================================= rm -rf .terraform* && rm -rf terraform*
/*
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-f792228e" # default vpc 172.31.0.0/16

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name   = "allow_tls"
    reason = "playground"
  }
}
#===========================
variable "custom_ports" {
  description = "Custom ports to open"
  type        = map(any)
  default = { # this is a list or a map
    80   = ["0.0.0.0/0"]
    8081 = ["172.31.0.0/16"]
    8080 = ["172.31.0.0/16"]
  }
}
resource "aws_security_group" "web" {
  name   = "rk name"
  vpc_id = "vpc-f792228e"
  dynamic "ingress" {
    for_each = var.custom_ports
    content {
      from_port   = ingress.key
      to_port     = ingress.key
      protocol    = "tcp"
      cidr_blocks = ingress.value
    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
# output "A-1-sg2" { value = aws_security_group.web }

#======================================================= rm -rf .terraform* && rm -rf terraform*
variable "vpcs" {
  description = "Alist of VPCs"
  default = ["main","database","client", "production"]
}
output "vpcs" {
  value = "%{for vpc in var.vpcs}${vpc}, %{endfor}"
}
output "vpcs2" {
  value = var.vpcs
}
output "vpcs3" {
  value = var.vpcs[2]
}
#======================================================= rm -rf .terraform* && rm -rf terraform*
# aws ec2 describe-vpcs --profile dev| bat -l json
variable "enable_public" {
  default = false
}
resource "aws_subnet" "public" {
  count = var.enable_public ? 1 : 0
  vpc_id = "vpc-f792228e"
  cidr_block = "172.31.1.0/24"
  tags = {Name = "public-kr"}
}
resource "aws_subnet" "private" {
  count = var.enable_public ? 0 : 1
  vpc_id = "vpc-f792228e"
  cidr_block = "172.31.2.0/24"
  tags = {Name = "private-kr"}
}
output "subnet_id" {
  value = one(concat(
    aws_subnet.public[*].id,
    aws_subnet.private[*].id
  ))
}
*/
