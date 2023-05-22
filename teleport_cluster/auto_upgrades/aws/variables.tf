variable "region" {
  description = "The AWS region where your resources will be deployed"
}

variable "bucket-name" {
  description = "The name of the S3 bucket to create"
}

variable "hosted_zone" {
  description = "Your existing Route53 hosted zone"
}

variable "endpoint_name" {
  description = "The name for your endpoint, which will form the first portion of your URL"
}