data "aws_route53_zone" "teleportdemo" {
  name         = "teleportdemo.com"
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



# resource "aws_route53_record" "proxy-cname" {
#   zone_id = data.aws_route53_zone.teleportdemo.zone_id
#   name    = "dkdemo.teleportdemo.com"
#   type    = "CNAME"
#   ttl     = "300"
#   records = [aws_instance.proxy_node.public_dns]
# }