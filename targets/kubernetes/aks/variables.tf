variable "prefix" {
  description = "A prefix used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be provisioned"
}

variable "clustername" {
  description = "Name of the AKS cluster as it will appear in Teleport"
}

variable "proxy_address" {
  description = "The address of the proxy server"
}

variable "auth_token" {
  description = "The auth token generated from the Teleport server"
}

variable "label_environment" {
  description = "The environment of the cluster"
}
