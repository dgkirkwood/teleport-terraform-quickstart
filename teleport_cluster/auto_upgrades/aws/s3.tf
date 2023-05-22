resource "aws_s3_bucket" "teleport-auto-upgrade" {
  bucket = var.bucket-name

  tags = {
    Name        = var.bucket-name
  }
}

resource "aws_s3_object" "version" {
  bucket = aws_s3_bucket.teleport-auto-upgrade.id
  key = "current/version"
  content = "13.0.3"
}

resource "aws_s3_object" "critical" {
  bucket = aws_s3_bucket.teleport-auto-upgrade.id
  key = "current/critical"
  content = "no"
}

resource "aws_s3_bucket_website_configuration" "teleport" {
  bucket = aws_s3_bucket.teleport-auto-upgrade.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "http_test" {
  bucket = aws_s3_bucket.teleport-auto-upgrade.id
  block_public_policy = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.teleport-auto-upgrade.id
  depends_on = [ aws_cloudfront_distribution.tls ]
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.teleport-auto-upgrade.id}/*"
            ]
        }
    ]
}
POLICY  
}