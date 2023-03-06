data "aws_ami" "target" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.linux_ami_name]
  }
  owners = [var.ami_owner]
}



resource "aws_instance" "target_nodes" {
  ami           = data.aws_ami.target.id
  instance_type = "t3.medium"
  subnet_id = aws_subnet.server.id
  vpc_security_group_ids = [ aws_security_group.serveraccess.id ]
  key_name = var.key_name
  user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname ${var.linux_hostname}
sudo tee -a /etc/teleport.yaml <<'EOT'

windows_desktop_service:
  enabled: yes
  non_ad_hosts:
    - ${aws_instance.windows-2019.private_ip}
EOT
sudo systemctl restart teleport
EOF
  metadata_options {
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }

  tags = {
    Name = "${var.linux_hostname}"
    Env = "${var.environment}"
  }
}