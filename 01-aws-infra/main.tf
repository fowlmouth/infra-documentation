/*
  Set up a VPC with public and private subnets

  AWS describes this setup in a documentation guide
  https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html
*/

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider aws {
  region = var.region
}

// a VPC with size /16 cidr block
resource aws_vpc network {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.network_name
  }
}

// a private subnet with size /20
resource aws_subnet private {
  vpc_id = aws_vpc.network.id
  cidr_block = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.network_name}-us1e-private"
  }
}

// a public subnet with size /20
resource aws_subnet public {
  vpc_id = aws_vpc.network.id
  cidr_block = var.public_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.network_name}-us1e-public"
  }
}

// an internet gateway
resource aws_internet_gateway public_igw {
  vpc_id = aws_vpc.network.id

}

// route table for the public subnet
resource aws_route_table public {
  vpc_id = aws_vpc.network.id

}

// route for the internet gateway in the public subnet
resource aws_route public_internet {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.public_igw.id
}


// associate the route table with the public subnet
resource aws_route_table_association public {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

// elastic IP for the NAT gateway
resource aws_eip nat {
  vpc = true
}

// a NAT gateway for the private subnet
resource aws_nat_gateway private {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.private.id
}

// route table for private subnet
resource aws_route_table private {
  vpc_id = aws_vpc.network.id
}

// route for the NAT gateway
resource aws_route private_nat {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.private.id
}

// associate the route table with the private subnet
resource aws_route_table_association private {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

