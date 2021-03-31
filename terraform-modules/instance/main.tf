
// network interface
resource aws_network_interface inst {
  subnet_id = var.subnet_id

}

// an elastic IP address
resource aws_eip eip {
  count = var.is_public ? 1 : 0

}

// an EC2 instance
resource aws_instance inst {
  ami = var.ami_id
  instance_type = var.instance_type
  availability_zone = var.availability_zone
  associate_public_ip_address = var.is_public
  key_name = var.key_name
  user_data = var.user_data

  subnet_id = var.subnet_id
  vpc_security_group_ids = var.security_groups

  root_block_device {
    encrypted = true
    volume_size = var.instance_volume_size
  }
}

// associate the elastic IP
resource aws_eip_association eip {
  count = var.is_public ? 1 : 0
  instance_id = aws_instance.inst.id
  allocation_id = aws_eip.eip[0].id
}

