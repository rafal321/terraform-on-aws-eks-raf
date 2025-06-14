# ==== vpc_main.tf ====
################################################################################
# VPC Module
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1.2"

  name                    = "${var.vpc_name}-vpc"
  cidr                    = "10.90.0.0/16"
  azs                     = ["${var.aws_region}a", "${var.aws_region}b"] #, "${var.aws_region}c"]
  public_subnets          = ["10.90.11.0/24", "10.90.12.0/24"]           #, "10.90.13.0/24"]
  private_subnets         = ["10.90.112.0/20", "10.90.128.0/20"]         #, "10.90.144.0/20"] #, "10.90.160.0/20", "10.90.176.0/20", "10.90.192.0/20"]
  database_subnets        = ["10.90.211.0/24", "10.90.212.0/24"]         #, "10.90.213.0/24"]
  intra_subnets           = ["10.90.221.0/24", "10.90.222.0/24"]         #, "10.90.223.0/24"]
  enable_nat_gateway      = true                                         # false - for quick deploy
  single_nat_gateway      = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true
  # enable_flow_log                                 = true
  # flow_log_cloudwatch_log_group_retention_in_days = 7
  # flow_log_max_aggregation_interval               = 60
  create_database_subnet_group = false
  public_subnet_tags           = { "kubernetes.io/role/elb" = "1" }
  private_subnet_tags          = { "kubernetes.io/role/internal-elb" = "1" }
  tags = {
    ManagedBy = "terraform"
    Tag10     = "value10"
    Customer  = "raf"
    Workspace = terraform.workspace
    Test1     = "${var.vpc_name}-vpc"
    Test2     = var.aws_region
    Section   = "infrastructure_v1"
  }
}
################################################################################
# VPC Endpoints Module
################################################################################
module "vpc_endpoints" {
  source                     = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  vpc_id                     = module.vpc.vpc_id
  create_security_group      = true
  security_group_name_prefix = "${var.vpc_name}-vpc-endpoint-sg-"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }
  # https://www.linkedin.com/pulse/mounting-aws-s3-buckets-ec2-instances-using-terraform-todd-bernson/
  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
      tags            = { Name = "${var.vpc_name}-vpc-s3-endpoint" }
    },
    dynamodb = {
      service         = "dynamodb"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
      policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
      tags            = { Name = "${var.vpc_name}-vpc-dynamodb-endpoint" }
    }
  }
}
################################################################################
# Supporting Resources
################################################################################
data "aws_iam_policy_document" "dynamodb_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["dynamodb:*"]
    resources = ["*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "aws:sourceVpc"
      values   = [module.vpc.vpc_id]
    }
  }
}

