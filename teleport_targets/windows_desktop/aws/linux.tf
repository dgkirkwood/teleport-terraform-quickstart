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
  ldap:
    addr: "10.0.1.20:636"
    domain: ${var.active_directory_domain_name}
    username: 'svc-teleport'
    insecure_skip_verify: true
  discovery:
    base_dn: "*"
EOT
echo "Updating configuration to use token join..."
sudo sed -i 's/^    method: ec2/    method: token/g' /etc/teleport.yaml
sudo sed -i 's/^    token_name: ec2-token/    token_name: ${var.join_token}/g' /etc/teleport.yaml  
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