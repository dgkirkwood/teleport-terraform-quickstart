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


variable "cluster_flavours" {
  type = map
}

variable "teleport_version" {
  description = "The Teleport agent version to install via Helm"
}