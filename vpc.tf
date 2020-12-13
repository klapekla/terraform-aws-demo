# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name    = "my_vpc"
    Project = var.project_tag
  }
}

# Public Subnets
resource "aws_subnet" "my_public_subnets" {
  count = 3

  vpc_id            = aws_vpc.my_vpc.id
  availability_zone = var.az[count.index]
  cidr_block        = "192.168.${count.index + 1}0.0/24"

  tags = {
    Name    = "my_public_subnet_${count.index + 1}"
    Project = var.project_tag
  }
}

# Private Subnets
resource "aws_subnet" "my_private_subnets" {
  count = 3

  vpc_id            = aws_vpc.my_vpc.id
  availability_zone = var.az[count.index]
  cidr_block        = "192.168.${count.index + 1}1.0/24"

  tags = {
    Name    = "my_private_subnet_${count.index + 1}"
    Project = var.project_tag
  }
}

# Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
    Project = var.project_tag
  }
}

# Route Table for Internet Access
resource "aws_route_table" "my_public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "my_public_route_table"
    Project = var.project_tag
  }
}

# Route Table Association
resource "aws_route_table_association" "my_public_route_table_subnet_association" {
  count = 3

  subnet_id      = aws_subnet.my_public_subnets[count.index].id
  route_table_id = aws_route_table.my_public_route_table.id
}

# TODO: NAT Gateay - For Internet Connection for Private Subnets (https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html)