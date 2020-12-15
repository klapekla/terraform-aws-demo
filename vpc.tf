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
  count = local.az_count

  vpc_id            = aws_vpc.my_vpc.id
  availability_zone = local.az[count.index]
  cidr_block        = "192.168.${count.index + 1}0.0/24"

  tags = {
    Name    = "my_public_subnet_${count.index + 1}"
    Project = var.project_tag
  }
}

# Private Subnets
resource "aws_subnet" "my_private_subnets" {
  count = local.az_count

  vpc_id            = aws_vpc.my_vpc.id
  availability_zone = local.az[count.index]
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
    Name    = "my_igw"
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
    Name    = "my_public_route_table"
    Project = var.project_tag
  }
}

# Route Table Association
resource "aws_route_table_association" "my_public_route_table_subnet_association" {
  count = local.az_count

  subnet_id      = aws_subnet.my_public_subnets[count.index].id
  route_table_id = aws_route_table.my_public_route_table.id
}

# Elastic IP for NAT Gateways
resource "aws_eip" "my_eip_for_nat_gateway" {
  count = local.az_count

  vpc = true

  tags = {
    Name    = "my_eip_for_nat_gateway_${count.index + 1}"
    Project = var.project_tag
  }
}

# NAT Gateways
resource "aws_nat_gateway" "my_nat_gateway" {
  count = local.az_count

  allocation_id = aws_eip.my_eip_for_nat_gateway[count.index].id
  subnet_id     = aws_subnet.my_public_subnets[count.index].id

  tags = {
    Name    = "my_nat_gateway_${count.index + 1}"
    Project = var.project_tag
  }
}

# Root Table Route for routing Private Subnet Traffic to NAT
resource "aws_route" "my_nat_gateway_route" {
  count = local.az_count

  route_table_id         = aws_vpc.my_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my_nat_gateway[count.index].id
}

# Route Table missing subnets?