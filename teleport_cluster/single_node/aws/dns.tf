data "aws_route53_zone" "teleportdemo" {
  name         = var.hosted_zone
}

resource "aws_route53_record" "proxy" {
  zone_id = data.aws_route53_zone.teleportdemo.zone_id
  name    = var.domain
  type    = "A"
  ttl     = "100"
  records = [aws_instance.proxy_node.public_ip]
}

resource "aws_route53_record" "wildcard" {
  zone_id = data.aws_route53_zone.teleportdemo.zone_id
  name    = "*.${var.domain}"
  type    = "A"
  ttl     = "100"
  records = [aws_instance.proxy_node.public_ip]
}

