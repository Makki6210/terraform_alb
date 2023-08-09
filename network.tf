locals {
  vpc_cidr = "172.16.0.0/16"
  vpc_name = "tf-vpc-1"
  public_subnet = [
    {
        cidr  = "172.16.1.0/24"
        az    = "ap-northeast-1a"
        name  = "tf-public-subnet-1"
    },
    {
        cidr  = "172.16.3.0/24"
        az    = "ap-northeast-1c"
        name  = "tf-public-subnet-2"
    }
  ]
  private_subnet = [
    {
        cidr  = "172.16.2.0/24"
        az    = "ap-northeast-1a"
        name  = "tf-private-subnet-1"
    },
    {
        cidr  = "172.16.4.0/24"
        az    = "ap-northeast-1c"
        name  = "tf-private-subnet-2"
    }
  ]
}

# ---------------------------
# VPC
# ---------------------------
resource "aws_vpc" "my_vpc" {
  cidr_block = local.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${local.vpc_name}"
  }
}

# ---------------------------
# Subnet
# ---------------------------
resource "aws_subnet" "my_pub_subnet" {
  for_each          = { for i in local.public_subnet : i.az => i }
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name = "${each.value.name}"
  }
}
resource "aws_subnet" "my_pri_subnet" {
  for_each          = { for i in local.private_subnet : i.az => i }
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name = "${each.value.name}"
  }
}

# ---------------------------
# Internet Gateway
# ---------------------------
resource "aws_internet_gateway" "my_igw" {
  vpc_id            = aws_vpc.my_vpc.id
  tags = {
    Name = "tf-igw"
  }
}

# ---------------------------
# Route table
# ---------------------------
resource "aws_route_table" "my_pub_rt" {
  vpc_id            = aws_vpc.my_vpc.id
  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "tf-public-rt"
  }
}

resource "aws_route_table_association" "my_pub_subnet" {
  for_each       = aws_subnet.my_pub_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.my_pub_rt.id
}

resource "aws_route_table" "my_pri_rt" {
  vpc_id            = aws_vpc.my_vpc.id
  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "tf-private-rt"
  }
}

resource "aws_route_table_association" "my_pri_subnet" {
  for_each       = aws_subnet.my_pri_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.my_pri_rt.id
}