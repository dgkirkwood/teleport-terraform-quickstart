variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "admin_username" {
  description = "Username for the Administrator account"
}

variable "admin_password" {
  description = "Password for the Administrator account"
}

variable "active_directory_domain_name" {
  description = "the domain name for Active Directory, for example `consoto.local`"
}
  
variable "active_directory_netbios_name" {
  description = "the netbios name for Active Directory, for example `CONSOTO`"
}

variable "dc_hostname" {
  description = "The hostname of the Domain Controller, for example `dc01`"
}

variable "client_hostname" {
  description = "The hostname of the client, for example `client01`"
}

variable "image_name" {
  description = "The name of the Packer image you have built for the Teleport service."
}

variable "image_rg" {
  description = "The resource group where your Packer image was built."
}

variable "linux_hostname" {
  description = "The hostname of your linux box as it will appear in Teleport"
}

variable "join_token" {
  description = "A join token from your Teleport cluster to allow the Linux node to connect"
}