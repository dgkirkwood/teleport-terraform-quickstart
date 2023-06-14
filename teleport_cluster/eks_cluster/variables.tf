variable "region" {
  description = "AWS region"
}

variable "prefix" {
  description = "Prefix for all resources"
}

variable "cluster_fqdn" {
  description = "The FQDN of the cluster"
}

variable "hosted_zone" {
  description = "The Route53 hosted zone"
}


variable "teleport_version" {
  description = "The version of the Teleport cluster you would like to install"
}

variable "ingress_name" {
  description = "The name of the ingress controller"
}

variable "email_address" {
  description = "The email address used for Lets Encrypt certs"
}