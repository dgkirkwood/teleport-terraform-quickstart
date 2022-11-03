

data "aws_ami" "proxy" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.image_name]
  }
  owners = [var.image_owner]
}





resource "aws_instance" "proxy_node" {
  ami           = data.aws_ami.proxy.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.server.id
  associate_public_ip_address = true
  vpc_security_group_ids = [ aws_security_group.serveraccess.id ]
  iam_instance_profile = aws_iam_instance_profile.ec2_describe.name
  key_name = var.key
  metadata_options {
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }

  tags = {
    Name = "proxy_node"
  }
}

