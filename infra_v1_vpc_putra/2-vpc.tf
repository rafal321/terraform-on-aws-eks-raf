
# https://mxtoolbox.com/subnetcalculator.aspx
# https://www.calculator.net/ip-subnet-calculator.html
# https://dev.to/suzuki0430/implementing-s3-gateway-vpc-endpoints-with-terraform-1ph1

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${local.customer}-${local.env}-vpc"
  }
}
# ######################################################################
# GATEWAYS
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${local.customer}-${local.env}-igw"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${local.customer}-${local.env}-nat-ip"
  }
}
resource "aws_nat_gateway" "nat" {

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_zone1.id
  tags = {
    Name = "${local.customer}-${local.env}-nat-${local.zone1}"
  }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${local.region}.s3"
  route_table_ids   = [aws_route_table.private.id, aws_route_table.public.id]
  vpc_endpoint_type = "Gateway"
  policy            = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*",
      "Principal": "*"
    }
  ]
}
POLICY
  tags              = { Name = "${local.customer}-${local.env}-s3-gateway" }
}
resource "aws_vpc_endpoint" "dynamodb_gateway" {
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.${local.region}.dynamodb"
  route_table_ids = [aws_route_table.private.id, aws_route_table.public.id]
  policy          = <<POLICY
    {
    "Version": "2008-10-17",
    "Statement": [
        {
        "Action": "*",
        "Effect": "Allow",
        "Resource": "*",
        "Principal": "*"
        }
      ]
    }
    POLICY
  tags            = { Name = "${local.customer}-${local.env}-dynamodb-gateway" }
}

# ######################################################################
# ROUTE TABLES
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "${local.customer}-${local.env}-rt-private" }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${local.customer}-${local.env}-rt-public" }
}
resource "aws_route_table_association" "public_zone1" {
  subnet_id      = aws_subnet.public_zone1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_zone2" {
  subnet_id      = aws_subnet.public_zone2.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private_zone1" {
  subnet_id      = aws_subnet.private_zone1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private_zone2" {
  subnet_id      = aws_subnet.private_zone2.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "database_zone1" {
  subnet_id      = aws_subnet.database_zone1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "database_zone2" {
  subnet_id      = aws_subnet.database_zone2.id
  route_table_id = aws_route_table.private.id
}

# ######################################################################
# PUBLIC
resource "aws_subnet" "public_zone1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.11.0/24" # IPs:256 Range: 10.0.11.0 - 10.0.11.255
  availability_zone       = local.zone1
  map_public_ip_on_launch = true
  tags = {
    Name                     = "${local.customer}-${local.env}-public-${local.zone1}"
    "kubernetes.io/role/elb" = "1"
    Tier                     = "Public"
    "kubernetes.io/cluster/${local.ekscluster}" = "owned"  #(need it If we intend to have more than one cluster)
  }
}
resource "aws_subnet" "public_zone2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.12.0/24" # IPs:256 Range: 10.0.12.0 - 10.0.12.255
  availability_zone       = local.zone2
  map_public_ip_on_launch = true
  tags = {
    Name                     = "${local.customer}-${local.env}-public-${local.zone2}"
    "kubernetes.io/role/elb" = "1"
    Tier                     = "Public"
    "kubernetes.io/cluster/${local.ekscluster}" = "owned" # (need it If we intend to have more than one cluster)
  }
}
# PRIVATE
resource "aws_subnet" "private_zone1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.112.0/20" # IPs:4096 Range: 10.0.96.0 - 10.0.111.255
  availability_zone = local.zone1
  tags = {
    Name                              = "${local.customer}-${local.env}-private-${local.zone1}"
    Tier                              = "Private"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${local.ekscluster}" = "owned"  #(need it If we intend to have more than one cluster)
  }
}
resource "aws_subnet" "private_zone2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.128.0/20" # IPs:4096 Range: 10.0.128.0 - 10.0.143.255
  availability_zone = local.zone2
  tags = {
    Name                              = "${local.customer}-${local.env}-private-${local.zone2}"
    Tier                              = "Private"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${local.ekscluster}" = "owned"  #(need it If we intend to have more than one cluster)
  }
}
# DATABASE
resource "aws_subnet" "database_zone1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = local.zone1
  tags = {
    Name = "${local.customer}-${local.env}-database-${local.zone1}"
    Tier = "Database"
  }
}
resource "aws_subnet" "database_zone2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = local.zone2
  tags = {
    Name = "${local.customer}-${local.env}-database-${local.zone2}"
    Tier = "Database"
  }
}

resource "aws_db_subnet_group" "sub_group" {
  name       = "${local.customer}-${local.env}-sub.group"
  subnet_ids = [aws_subnet.database_zone1.id, aws_subnet.database_zone2.id]

  tags = {
    Name = "${local.customer}-${local.env}-sub.group"
    Tier = "Database"
  }
}

# ######################################################################
# OUTPUTS
output "aws_vpc_name" {
  value = aws_vpc.main.tags_all["Name"]
}
output "subnet_private" {
  value = ["${aws_subnet.private_zone1.id}", "${aws_subnet.private_zone2.id}"]
}
output "subnet_public" {
  value = ["${aws_subnet.public_zone1.id}", "${aws_subnet.public_zone2.id}"]
}
output "subnet_database" {
  value = ["${aws_subnet.database_zone2.id}", "${aws_subnet.database_zone2.id}"]
}
output "db_sub_group_name" {
  value = aws_db_subnet_group.sub_group.name
}
