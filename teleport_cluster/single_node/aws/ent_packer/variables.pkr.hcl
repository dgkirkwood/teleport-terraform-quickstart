variable "cluster_name" {
    description = "The FQDN for your Teleport cluster, for example mycluster.teleportlabs.com"
    type = string
}

variable "ami_name" {
    description = "The resulting name of your AMI. Take note of this value for your Terraform builds."
    type = string
}

variable "region" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "subnet_id" {
    type = string
}

variable "email" {
    description = "The email address to use for Lets Encrypt certificates on this instance"
    type = string
}
