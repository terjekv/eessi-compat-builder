resource "aws_instance" "compat-layer-builder-x86_64" {
  ami           = data.aws_ami.x86_64.id
  instance_type = var.instance_x86_64[var.mode]
  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name = "deployer-key"
  monitoring = true
  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "eessi-compat-x86_64"
  }

  provisioner "file" {
    connection {
      host        = self.public_ip
      user        = var.ssh["user"]
      private_key = file(var.keys["private"])
    }

    source      = "remote.sh"
    destination = "/tmp/remote.sh"
  }

  provisioner "remote-exec" {
    connection {
      host        = self.public_ip
      user        = var.ssh["user"]
      private_key = file(var.keys["private"])
    }

    inline = [
      "chmod 755 /tmp/remote.sh",
      "/tmp/remote.sh",
    ]
  }
}
