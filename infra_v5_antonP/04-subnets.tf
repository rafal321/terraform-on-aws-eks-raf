resource "aws_subnet" "private_zone1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.112.0/20"
  availability_zone = local.zone1
  tags = {
    Name                              = "${local.env}-private-${local.zone1}"
    "kubernetes.io/role/internal-elb" = "1"
    #"kubernetes.io/cluster/my-cluster" = "owned"
  }
}

resource "aws_subnet" "private_zone2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.128.0/20"
  availability_zone = local.zone2
  tags = {
    Name                              = "${local.env}-private-${local.zone2}"
    "kubernetes.io/role/internal-elb" = "1"
    #"kubernetes.io/cluster/my-cluster" = "owned"
  }
}

resource "aws_subnet" "public_zone1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = local.zone1
  map_public_ip_on_launch = true
  tags = {
    Name                     = "${local.env}-public-${local.zone1}"
    "kubernetes.io/role/elb" = "1"
    #"kubernetes.io/cluster/my-cluster" = "owned"
  }
}

resource "aws_subnet" "public_zone2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.12.0/24"
  availability_zone       = local.zone2
  map_public_ip_on_launch = true
  tags = {
    Name                     = "${local.env}-public-${local.zone2}"
    "kubernetes.io/role/elb" = "1"
    #"kubernetes.io/cluster/my-cluster" = "owned"
  }
}
