

data "aws_ami" "target" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name]
  }

  owners = [var.ami_owner]
}






resource "aws_instance" "target_node" {
  ami           = data.aws_ami.target.id
  instance_type = "t2.micro"
  subnet_id = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids = [ aws_security_group.rds.id ]
  key_name = var.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_rds.name
  user_data = <<EOF
#!/bin/bash
echo "Changing hostname..."
sudo hostnamectl set-hostname ${var.hostname}
sudo tee -a /etc/teleport.yaml <<'EOT'

db_service:
  enabled: "yes"
  resources:
  - labels:
      "*": "*"
  aws:
  - types: ["rds"]
    regions:
    - ${var.region}
    tags:
      "*": "*"
EOT
sudo systemctl restart teleport
EOF
  metadata_options {
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }

  tags = {
    Name = "target_node"
  }
}

