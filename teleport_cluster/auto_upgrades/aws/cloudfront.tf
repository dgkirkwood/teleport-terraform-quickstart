resource "aws_cloudfront_distribution" "tls" {
  origin {
    domain_name = aws_s3_bucket.teleport-auto-upgrade.bucket_regional_domain_name
    origin_id = "teleport-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.teleport.id
  }
  enabled = true
  aliases = [ "${var.endpoint_name}.${var.hosted_zone}" ]
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.updater.arn
    ssl_support_method = "sni-only"
  }
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    viewer_protocol_policy = "https-only"
    target_origin_id = "teleport-s3-origin"
    #Caching optimised managed policy
    cache_policy_id  = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_cloudfront_origin_access_control" "teleport" {
  name = "${var.endpoint_name}-teleport"
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}