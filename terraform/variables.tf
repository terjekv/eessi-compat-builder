variable "aws_region" {
  default = "eu-west-1"
}

variable "mode" {
  type = string

  validation {
    condition = var.mode == "test" || var.mode == "prod"
    error_message = "Set TF_VAR_mode to either 'test' or 'prod'."
  }
}

variable "ssh" {
  type = map

  default = {
    port = 22
    user = "ec2-user"
  }
}

variable "keys" {
  type = map

  default = {
    private = "~/.ssh/id_rsa.terraform"
    public  = "~/.ssh/id_rsa.terraform.pub"
  }
}

variable "instance_arm" {
  type = map

  default = {
    test = "t4g.micro"
    prod = "c6g.4xlarge"
  }
}

variable "instance_x86_64" {
  type = map

  default = {
    test = "t2.micro"
    prod = "c5.4xlarge"
  }
}