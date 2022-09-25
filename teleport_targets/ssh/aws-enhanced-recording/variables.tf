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

variable "machines" {
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