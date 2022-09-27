data "aws_ami" "windows" {
  most_recent = true
  filter {
    name   = "name"
    values = [var.ami_name]
  }
  owners = [var.ami_owner]
}

resource "aws_instance" "windows" {
  ami           = data.aws_ami.windows.id
  instance_type = "t3.medium"
  key_name      = var.key_name
  subnet_id     = aws_subnet.server.id
  vpc_security_group_ids = [
    aws_security_group.serveraccess.id
  ]
  tags = {
    Name = "teleport-win-dc"
  }
}

data "aws_ami" "windows-2019" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base*"]
  }
}


resource "aws_instance" "windows-2019" {
  ami           = data.aws_ami.windows-2019.id
  instance_type = "t3.medium"
  key_name      = var.key_name
  subnet_id     = aws_subnet.server.id
  get_password_data = true
  vpc_security_group_ids = [
    aws_security_group.serveraccess.id
  ]
  user_data = templatefile("files/user_data.tpl", {windows_hostname = var.windows_hostname, active_directory_domain_name = var.active_directory_domain_name, admin_user = var.admin_user, admin_password = var.admin_password})
  tags = {
    Name = "windows-2019-target"
  }
  depends_on = [
    aws_instance.windows
  ]
}