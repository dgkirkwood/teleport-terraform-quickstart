variable "domain" {
  description = "The domain name for the Teleport proxy"
}

variable "image_owner" {
  description = "The AWS account number where your packer image was built"
}

variable "image_name" {
  description = "The name of the image built using Packer"
}

variable "region" {
  description = "The desired AWS region"
}

variable "hosted_zone" {
  description = "The AWS Route53 hosted zone you would like to use for your DNS records."
}

variable "key" {
  description = "An existing SSH key for direct access to the Proxy via SSH"
}

variable "prefix" {
  description = "A few characters to ensure your resources are unique, for example 'dk'"
}