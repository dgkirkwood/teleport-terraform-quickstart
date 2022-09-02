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
  cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]

}

resource "aws_security_group_rule" "allow_tls" {
  type = "ingress"
  from_port = 443
  to_port = 443
  security_group_id = aws_security_group.serveraccess.id
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

}

resource "aws_security_group_rule" "allow_teleport_ssh" {
  type = "ingress"
  from_port = 3022
  to_port = 3022
  security_group_id = aws_security_group.serveraccess.id
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

}

resource "aws_security_group_rule" "allow_proxy_ssh" {
  type = "ingress"
  from_port = 3023
  to_port = 3023
  security_group_id = aws_security_group.serveraccess.id
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

}


resource "aws_security_group_rule" "allow_auth" {
  type = "ingress"
  from_port = 3025
  to_port = 3025
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