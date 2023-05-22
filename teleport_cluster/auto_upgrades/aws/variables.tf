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

variable "desired_version" {
  description = "The version that you would like the auto-update service to upgrade to. Should match proxy / auth version."
}

variable "critical" {
  description = "A yes or no value for whether the current update is critical or not."
  validation {
    condition = can(regex("^(yes|no)$", var.critical))
    error_message = "Critical must be either yes or no"
  }
}