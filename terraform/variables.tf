variable "private_key_path" {
  default = "~/.ssh/id_rsa.terraform"
}

variable "public_key_path" {
  default = "~/.ssh/id_rsa.terraform.pub"
}

variable "core_tcp_ports" {
  default = 22
}

variable "ssh_user_name" {
    default = "ec2-user"
}

variable "image_arm_testing" {
    default = "t4g.micro"
}

variable "image_arm_production" {
    default = "c6g.4xlarge"
}

