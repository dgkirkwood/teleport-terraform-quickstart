# Teleport Auto-Upgrade Endpoint

**Please note this code and it's documentation is a work in progress.**

This code will create an endpoint for Teleport auto-upgrades, as described [here](https://goteleport.com/docs/management/operations/self-hosted-automatic-agent-updates/?scope=enterprise).

Starting with AWS, The endpoint is hosted on S3, via CloudFront for TLS with an ACM certificate. 

To test the AWS code, create a `terraform.tfvars` file with the following content
```
region = "us-west-2"
bucket-name = "your-unique-bucket-name"
hosted_zone = "example-route53-zone.com"
endpoint_name = "your-endpoint-name"
```
Where `hosted_zone` is an existing Route53 hosted zone.

Google examples and more to come!

