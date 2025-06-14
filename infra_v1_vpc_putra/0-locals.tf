# for testing locals is fine othervise variables are preferred
# 2024-10-20
locals {
  customer         = "terr"
  env              = "lol"
  region           = "eu-west-1"
  profile          = "lab"
  ekscluster       = "empty"
  cidr_vpc         = "10.0.0.0/16"
  cidr_block_pub1  = "10.0.11.0/24"  # IPs:256 Range:
  cidr_block_pub2  = "10.0.12.0/24"  # IPs:256 Range:
  cidr_block_priv1 = "10.0.112.0/20" # IPs:4096 Range:
  cidr_block_priv2 = "10.0.128.0/20" # IPs:4096 Range:
  cidr_block_db1   = "10.0.21.0/24"
  cidr_block_db2   = "10.0.22.0/24"
}

