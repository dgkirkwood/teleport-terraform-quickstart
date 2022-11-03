variable "prefix" {
  description = "A prefix used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be provisioned"
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
  
}