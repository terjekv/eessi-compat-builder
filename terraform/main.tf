provider "aws" {
  region = "eu-west-1"
}

data "aws_ami" "arm" {
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-8*arm64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["309956199498"] # RHEL
}

data "aws_ami" "x86_64" {
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-8*x86_64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["309956199498"] # RHEL
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.public_key_path)
}

data "http" "icanhazip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_instance" "compat-layer-builder-arm" {
  ami           = data.aws_ami.arm.id
  instance_type = var.image_arm_production
  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name = "deployer-key"
  monitoring = true

  tags = {
    Name = "eessi-compat-arm"
  }

  provisioner "file" {
    connection {
      host        = self.public_ip
      user        = var.ssh_user_name
      private_key = file(var.private_key_path)
    }

    source      = "remote.sh"
    destination = "/tmp/remote.sh"
  }

  provisioner "remote-exec" {
    connection {
      host        = self.public_ip
      user        = var.ssh_user_name
      private_key = file(var.private_key_path)
    }

    inline = [
      "chmod 755 /tmp/remote.sh",
      "/tmp/remote.sh",
    ]
  }
}


#resource "aws_instance" "compat-layer-builder-x86_64" {
#  ami           = data.aws_ami.x86_64.id
#  instance_type = "c5.4xlarge"
#  vpc_security_group_ids = [aws_security_group.instance.id]
#
#  tags = {
#    Name = "eessi-compat-x86_64"
#  }  
#}

resource "aws_security_group" "instance" {
  name = "eessi-security"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.icanhazip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = aws_instance.compat-layer-builder-arm.*.public_ip
}

output "public_dns" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = aws_instance.compat-layer-builder-arm.*.public_dns
}
