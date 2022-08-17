variable "region" {
  description = "AWS region"
}

variable "clustername" {
  description = "Name of the EKS cluster as it will appear in Teleport"
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

