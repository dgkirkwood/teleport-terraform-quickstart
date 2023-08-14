variable "prefix" {
  description = "A prefix used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be provisioned"
}

variable "teleport_version" {
  description = "Which version of Teleport to deploy"
}

variable "dns_zone" {
  description = "An existing DNS zone registered in Azure"
}

variable "email_address" {
  description = "The email address to use for Let's Encrypt certs"
}

variable "cluster_hostname" {
  description = "The hostname of your Teleport cluster. Will be combined with your hosted zone for the FQDN"
}

variable "dns_rg" {
  description = "The name of the resource group containing your DNS zone"
}
