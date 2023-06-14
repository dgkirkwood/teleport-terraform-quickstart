output "cluster-url" {
  value = "https://${aws_route53_record.proxy.fqdn}"
}