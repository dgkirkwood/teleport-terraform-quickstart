output "bucket_domain" {
  value = aws_s3_bucket.teleport-auto-upgrade.bucket_regional_domain_name
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.tls.domain_name
}
