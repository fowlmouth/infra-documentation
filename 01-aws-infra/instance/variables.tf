
variable ami_id {}
variable instance_type {}
variable availability_zone {}
variable subnet_id {}
variable instance_volume_size {}
variable is_public {
  type = bool // "bool"
  default = false
}
variable security_groups {
  type = list(string)
}
variable key_name {}

