data "aws_ami" "windows-non-ad" {
  most_recent = true
  filter {
    name   = "name"
    values = [var.ami_name]
  }
  owners = [var.ami_owner]
}

resource "aws_instance" "windows-2019" {
  ami           = data.aws_ami.windows-non-ad.id
  instance_type = "t3.medium"
  key_name      = var.key_name
  subnet_id     = aws_subnet.server.id
  get_password_data = false
  vpc_security_group_ids = [
    aws_security_group.serveraccess.id
  ]
  tags = {
    Name = "windows-2019-target"
  }
}