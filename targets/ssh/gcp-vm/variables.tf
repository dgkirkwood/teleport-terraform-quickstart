variable "project_id" {
  description = "project id"
}
  
variable "region" {
  description = "region"
}

variable "prefix" {
  description = "prefix"
}

variable "jointoken" {
  description = "A token generated from your Teleport cluster to allow a VM join"
}

variable "ami_name" {
  description = "The family name of the AMI as as set in your Packer build"
}

variable "hostname" {
  description = "The hostname of the VM which will appear in Teleport"
}
