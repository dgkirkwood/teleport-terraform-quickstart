variable "ec2_token_name" {
    type = string
    default = "ec2-token"
}

variable "auth_address" {
    type = string
}

variable "ami_name" {
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

variable "teleport_version" {
    type = string
}

variable "mariadb_user" {
    type = string
}

variable "database_name" {
    type = string
}