variable "region" {
  description = "The AWS region where your servers will be deployed"
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

variable "proxy_address" {
  description = "The address of your Teleport proxy server"
}

variable "join_token" {
  description = "A token generated from your Teleport cluster to allow Tbot to join"
}

variable "target_machines" {
    type = map
    default = {
        target1 = {
            environment = "dev"
            hostname = "target1"
        }
        target2 = {
            environment = "test"
            hostname = "target2"
        }
    }
}

variable "control_hostname" {
  description = "The hostname for your Ansible control node as it will appear in Teleport"
}

variable "control_env" {
  description = "The environment for your Ansible control node as it will appear in Teleport"
}