resource "aws_s3_bucket" "teleport-auto-upgrade" {
  bucket = var.bucket-name
  #acl = "private"
  tags = {
    Name        = var.bucket-name
  }
}

resource "aws_s3_object" "version" {
  bucket = aws_s3_bucket.teleport-auto-upgrade.id
  key = "current/version"
  content = var.desired_version
}

resource "aws_s3_object" "critical" {
  bucket = aws_s3_bucket.teleport-auto-upgrade.id
  key = "current/critical"
  content = var.critical
}

resource "aws_s3_bucket_website_configuration" "teleport" {
  bucket = aws_s3_bucket.teleport-auto-upgrade.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "teleport" {
  bucket = aws_s3_bucket.teleport-auto-upgrade.id
  block_public_acls         = true
  block_public_policy       = true
  restrict_public_buckets   = true
  ignore_public_acls        = true
}


resource "aws_s3_bucket_policy" "web" {
  bucket = aws_s3_bucket.teleport-auto-upgrade.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": {
        "Sid": "AllowCloudFrontServicePrincipalReadOnly",
        "Effect": "Allow",
        "Principal": {
            "Service": "cloudfront.amazonaws.com"
        },
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::${var.bucket-name}/*",
        "Condition": {
            "StringEquals": {
                "AWS:SourceArn": "${aws_cloudfront_distribution.tls.arn}"
            }
        }
    }
}
POLICY
}
