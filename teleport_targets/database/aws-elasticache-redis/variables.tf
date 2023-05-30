variable "region" {
  description = "AWS region"
}


variable "ami_owner" {
  description = "The account ID of the owner of the AMI. Usually the account which you used to perform the Packer build."
}

variable "ami_name" {
  description = "The name of the AMI set in your Packer build. Note this must match exactly."
}

variable "key_name" {
  description = "The name of your SSH key on AWS"
}

variable "prefix" {
  description = "A prefix for unique naming on resources"
}

variable "hostname" {
  description = "The hostname of the Linux gateway node"
}

variable "dbname" {
  
}

