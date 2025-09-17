data "aws_availability_zones" "available" {
  state = "available"
}

# = vpc ========================================================================================
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    {
      Name = "${var.common_name}-vpc"
    },
    var.common_tags,
  )
}
# = PUBLIC ASSET ========================================================================================
resource "aws_subnet" "public_subnets" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = merge(
    {
      Name                     = "${var.common_name}-public-subnet-${count.index + 1}"
      "kubernetes.io/role/elb" = "1"
    },
    var.common_tags,
  )
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = merge(
    {
      Name = "${var.common_name}-igw"
    },
    var.common_tags,
  )
}
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = merge(
    {
      Name = "${var.common_name}-public-rt"
    },
    var.common_tags,
  )
}
resource "aws_route" "public_rt_route" { # RT to IGW
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
resource "aws_route_table_association" "public_rt_assoc" { # Subnet to RT
  count          = var.az_count
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}
# = SECONDARY CIDR BLOCK =================================================================================

resource "aws_vpc_ipv4_cidr_block_association" "secondary" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "100.64.0.0/16"
}
resource "aws_subnet" "secondary_subnets" {
  count             = var.az_count # 3
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = cidrsubnet("100.64.0.0/16", 3, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    {
      Name = "${var.common_name}-secondary-subnet-${count.index + 1}"
    },
    var.common_tags,
  )
  depends_on = [aws_vpc_ipv4_cidr_block_association.secondary]
}
resource "aws_route_table_association" "secondary_rt_assoc" { # Subnet SEC to RT
  count          = var.az_count
  subnet_id      = aws_subnet.secondary_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# = PRIVATE ASSET ========================================================================================
resource "aws_subnet" "private_subnets" {
  count             = var.az_count
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index + var.az_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    {
      Name                              = "${var.common_name}-private-subnet-${count.index + 1}"
      "kubernetes.io/role/internal-elb" = "1"
    },
    var.common_tags,
  )
}
resource "aws_subnet" "database_subnets" {
  count             = var.az_count
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index + var.az_count * 2)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    {
      Name = "${var.common_name}-database-subnet-${count.index + 1}"
    },
    var.common_tags,
  )
}

resource "aws_eip" "aws_eip_per_az" {
  count      = 1 # Single NAT
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
  tags = merge(
    {
      Name = "${var.common_name}-nat-eip-${count.index + 1}"
    },
    var.common_tags,
  )
}
resource "aws_nat_gateway" "nat_gw_per_az" {
  count         = 1                                      # Single NAT
  allocation_id = aws_eip.aws_eip_per_az[count.index].id # EIP to NAT GW
  subnet_id     = aws_subnet.public_subnets[count.index].id
  tags = merge(
    {
      Name = "${var.common_name}-nat-gw-${count.index + 1}"
    },
    var.common_tags,
  )
  depends_on = [aws_internet_gateway.igw]
}
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = merge(
    {
      Name = "${var.common_name}-private-rt"
    },
    var.common_tags,
  )
}
resource "aws_route" "private_rt_route" { # RT to NAT GW
  count                  = 1              # Single NAT
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw_per_az[count.index].id
  depends_on             = [aws_nat_gateway.nat_gw_per_az]
}
resource "aws_route_table_association" "private_rt_assoc" { # Subnet PR to RT
  count          = var.az_count
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "database_rt_assoc" { # Subnet DB to RT
  count          = var.az_count
  subnet_id      = aws_subnet.database_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.common_name}-db-subnet-group"
  subnet_ids = aws_subnet.database_subnets[*].id
  tags = merge(
    {
      Name = "${var.common_name}-db-subnet-group"
    },
    var.common_tags,
  )
}

# =========================================================================================
output "vpc_id" { value = aws_vpc.eks_vpc.id }
output "vpc_available_azs" { value = data.aws_availability_zones.available.names }
output "vpc_public_subnet_ids" { value = aws_subnet.public_subnets[*].id }
output "vpc_private_subnet_ids" { value = aws_subnet.private_subnets[*].id }
output "vpc_database_subnet_ids" { value = aws_subnet.database_subnets[*].id }
output "vpc_secondary_subnet_ids" { value = aws_subnet.secondary_subnets[*].id }
