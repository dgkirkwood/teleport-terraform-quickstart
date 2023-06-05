data "aws_route53_zone" "teleportdemo" {
  name         = var.hosted_zone
}

resource "aws_route53_record" "validation" {
  zone_id = data.aws_route53_zone.teleportdemo.zone_id
  name    = tolist(aws_acm_certificate.updater.domain_validation_options).0.resource_record_name
  type    = tolist(aws_acm_certificate.updater.domain_validation_options).0.resource_record_type
  ttl     = "100"
  records = [tolist(aws_acm_certificate.updater.domain_validation_options).0.resource_record_value]
  allow_overwrite = true
}

resource "aws_route53_record" "updater" {
  zone_id = data.aws_route53_zone.teleportdemo.id
  name = var.cluster_fqdn
  type = "A"
}

resource "aws_acm_certificate" "updater" {
  domain_name = var.cluster_fqdn
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "updater" {
  certificate_arn = aws_acm_certificate.updater.arn
  validation_record_fqdns = [aws_route53_record.validation.fqdn]
}