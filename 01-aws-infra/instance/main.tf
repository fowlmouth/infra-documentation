
// network interface
resource aws_network_interface inst {
  subnet_id = var.subnet_id

}

// an EC2 instance
resource aws_instance inst {
  ami = var.ami_id
  instance_type = var.instance_type
  availability_zone = var.availability_zone

  network_interface {
    network_interface_id = aws_network_interface.inst.id
    device_index = 0
  }
}

