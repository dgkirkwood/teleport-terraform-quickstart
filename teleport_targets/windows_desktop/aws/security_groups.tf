resource "aws_security_group" "serveraccess" {
  name = "allow_ssh"
  vpc_id = aws_vpc.server.id
}

resource "aws_security_group_rule" "allow_ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  security_group_id = aws_security_group.serveraccess.id
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  
}

resource "aws_security_group_rule" "self" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  self = true
  security_group_id = aws_security_group.serveraccess.id
}

resource "aws_security_group_rule" "allow_rdp" {
  type = "ingress"
  from_port = 3389
  to_port = 3389
  security_group_id = aws_security_group.serveraccess.id
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  
}

resource "aws_security_group_rule" "egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  security_group_id = aws_security_group.serveraccess.id
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}