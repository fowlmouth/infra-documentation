

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
  source = "./network"
  region = var.region
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

module public_instance {
  source = "./instance"
  ami_id = data.aws_ami.instance_ami.id
  instance_type = "t3.small"
  availability_zone = var.availability_zone
  subnet_id = module.network.public_subnet_id
  
}

