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
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = var.network_name
  }
}

// a private subnet with size /20
resource aws_subnet private {
  vpc_id = aws_vpc.network.id
  cidr_block = "10.10.0.0/20"
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.network_name}-us1e-private"
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


// a public subnet with size /20
resource aws_subnet public {
  vpc_id = aws_vpc.network.id
  cidr_block = "10.10.16.0/20"
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.network_name}-us1e-public"
  }
}

// associate the route table with the public subnet
resource aws_route_table_association public {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

