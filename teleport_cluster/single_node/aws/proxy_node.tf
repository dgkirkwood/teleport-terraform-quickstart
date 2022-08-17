

data "aws_ami" "proxy" {
  most_recent = true

  filter {
    name   = "name"
    values = ["dk-teleport-proxy"]
  }
  owners = ["165258854585"]
}





resource "aws_instance" "proxy_node" {
  ami           = data.aws_ami.proxy.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.server.id
  associate_public_ip_address = true
  vpc_security_group_ids = [ aws_security_group.serveraccess.id ]
  iam_instance_profile = aws_iam_instance_profile.ec2_describe.name
  key_name = "dk-rsa"
  metadata_options {
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }

  tags = {
    Name = "proxy_node"
  }
}

