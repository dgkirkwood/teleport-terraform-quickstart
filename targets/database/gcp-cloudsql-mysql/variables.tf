variable "project_id" {
  description = "project id"
}
  
variable "region" {
  description = "region"
}

variable "prefix" {
  description = "prefix"
}

variable "ami_name" {
  description = "The name of the AMI which was created as part of your Packer build."
}

variable "service_account_name" {
  description = "The name of the GCP service account which has CloudSQL Admin permissions"
}
  
variable "host_name" {
  description = "The hostname of the Google compute box which will host the database service connector"
}

variable "join_token" {
  description = "A token generated from your Teleport cluster to allow a VM join"
}

variable "db_name" {
  description = "The name of the database"
}

variable "environment" {
  description = "Desired environment tag for the database as it appears in Teleport"
}