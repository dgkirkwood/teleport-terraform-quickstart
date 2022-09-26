data "aws_ami" "target" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name]
  }
  owners = [var.ami_owner]
}



resource "aws_instance" "target_nodes" {
  for_each = var.machines
  ami           = data.aws_ami.target.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.server.id
  vpc_security_group_ids = [ aws_security_group.serveraccess.id ]
  key_name = var.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_get_identity.name
  user_data = <<EOF
#!/bin/bash
echo "Changing hostname..."
sudo hostnamectl set-hostname ${each.value.hostname}
echo "Updating configuration to use IAM join..."
sudo sed -i 's/^    method: ec2/    method: iam/g' /etc/teleport.yaml
sudo sed -i 's/^    token_name: ec2-token/    token_name: ${var.token_name}/g' /etc/teleport.yaml  
sudo systemctl restart teleport
EOF
  metadata_options {
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }

  tags = {
    Name = "${each.value.hostname}"
    Env = "${each.value.environment}"
  }
}