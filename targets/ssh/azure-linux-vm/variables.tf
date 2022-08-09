variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}
  
variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "image_name" {
  description = "The name of the Packer image which should be used for the build."
}

variable "image_rg" {
  description = "The resource group in which your Packer image resides."
}

variable "hostname" {
  description = "The hostname of the target machine."
}

variable "jointoken" {
  description = "A token generated from your Teleport server which will be used to join the target machine to the Teleport cluster."
}