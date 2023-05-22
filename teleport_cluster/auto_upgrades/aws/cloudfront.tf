resource "aws_cloudfront_distribution" "tls" {
  origin {
    domain_name = aws_s3_bucket.teleport-auto-upgrade.bucket_regional_domain_name
    origin_id = "teleport-s3-origin"
  }
  enabled = true
  aliases = [ "${var.endpoint_name}.${var.hosted_zone}" ]
  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn = aws_acm_certificate.updater.arn
    ssl_support_method = "sni-only"
  }
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    viewer_protocol_policy = "https-only"
    target_origin_id = "teleport-s3-origin"
    #Caching optimised managed policy
    cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}