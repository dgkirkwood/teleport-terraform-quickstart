data "aws_ami" "target" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name]
  }
  owners = [var.ami_owner]
}



resource "aws_instance" "target_nodes" {
  ami           = data.aws_ami.target.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.server.id
  vpc_security_group_ids = [ aws_security_group.serveraccess.id ]
  key_name = var.key_name
  user_data = <<EOF
#!/bin/bash
echo "Changing hostname..."
sudo hostnamectl set-hostname ${var.hostname}
sleep 20
sudo systemctl restart teleport
EOF
  metadata_options {
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }

  tags = {
    Name = "${var.hostname}"
    Env = "${var.environment}"
  }
}