output "cloudfront_domain" {
  value = "${var.endpoint_name}.${var.hosted_zone}/current"
}
