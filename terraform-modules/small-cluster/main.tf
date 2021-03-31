

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

resource aws_key_pair key {
  key_name = "cluster-key"
  public_key = file(var.ssh_public_key_file)
}

module network {
  source = "../network"
  region = var.region
  availability_zone = var.availability_zone
  
}

data aws_ami instance_ami {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  owners = ["099720109477"] # Canonical
}

resource aws_security_group public {
  vpc_id = module.network.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource aws_security_group private {
  vpc_id = module.network.vpc_id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ module.network.vpc_cidr ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module public_instance {
  source = "../instance"
  ami_id = data.aws_ami.instance_ami.id
  instance_type = var.instance_type
  availability_zone = var.availability_zone
  instance_volume_size = 8
  key_name = aws_key_pair.key.id

  is_public = true
  subnet_id = module.network.public_subnet_id

  security_groups = [ aws_security_group.public.id ]
/*
  user_data = <<-EUD
#cloud-config
runcmd:
- curl -sSLf https://get.k0s.sh | sudo sh
- sudo k0s install controller --single
- sudo systemctl start k0scontroller
- sudo systemctl enable k0scontroller
EUD
*/
}

module private_instance {
  source = "../instance"
  ami_id = data.aws_ami.instance_ami.id
  instance_type = var.instance_type
  availability_zone = var.availability_zone
  instance_volume_size = 8
  key_name = aws_key_pair.key.id

  is_public = false
  subnet_id = module.network.private_subnet_id

  security_groups = [ aws_security_group.private.id ]
}

