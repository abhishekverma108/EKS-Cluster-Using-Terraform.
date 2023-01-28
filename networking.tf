provider "aws" {
    region ="ap-south-1"
}
resource "aws_vpc" "first_vpc" {
  cidr_block = "10.0.0.0/16"
  tags={
    Name="first_vpc"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id=aws_vpc.first_vpc.id
  tags={
    Name="igw"
  }
}
resource "aws_subnet" "private-subnet" {
  vpc_id = aws_vpc.first_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    "Name" = "private-subnet "
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}
resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.first_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    "Name" = "public-subnet "
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1    
  }
}
resource "aws_eip" "natgateway" {
  vpc = true
  tags={
    Name="natgateway"
    }
}
resource "aws_nat_gateway" "natgateway" {
  allocation_id = aws_eip.natgateway.id
  subnet_id = aws_subnet.public-subnet.id
  tags={
    Name="natgateway"
    }
}
resource "aws_route_table" "private-routing-rule" {
  vpc_id = aws_vpc.first_vpc.id

  route{
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.natgateway.id
    }
  tags = {
    Name = "private-routing-rule"
  }
}

resource "aws_route_table" "public-routing-rule" {
  vpc_id = aws_vpc.first_vpc.id

  route {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.igw.id
    }
  tags = {
    Name = "public-routing-rule"
  }
}
resource "aws_route_table_association" "private-ap-south-1b" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-routing-rule.id
}

resource "aws_route_table_association" "public-ap-south-1a" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-routing-rule.id
}
