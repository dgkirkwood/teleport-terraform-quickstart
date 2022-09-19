# Teleport Quick Start with Terraform
## SSH Access on AWS with Enhanced Recording

This repository contains Packer and Terraform code to stand up SSH targets on AWS, for the purposes of being accessed via Teleport. It includes configuration for Enhanced Session Recording using BPF as described [here](https://goteleport.com/docs/server-access/guides/bpf-session-recording/).

## Pre-requisites
Please note the following pre-requisites for using this repository:
- A working, accessible Teleport cluster. You will need your proxy address as an input to this code. 
- Network connectivity between these EC2 instances and the mentioned Teleport proxy. The security groups in this repository are very permissive and allow all egress out of the created VPC. 
- A Teleport EC2 Join Token name. Please see the instructions for setting up the EC2 Join method using Teleport [here](https://goteleport.com/docs/setup/guides/joining-nodes-aws-ec2/).
- An existing Packer build for the Teleport target Linux machine. Please see the targets/ssh/aws-ec2join directory and follow the Packer instructions.
- The Terraform binary on your local machine, or on a machine where you can perform the automated builds. Tested using Terraform v1.2.4
- AWS Credentials. Any of the accepted credential types for automated provisioning on AWS. Examples can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

## How to use this repository

### Terraform Build
Terraform is used to create one or more target machines using the image from your Packer Build steps. You can take a look at the .tf files in this repository to understand what will be built. This is by no means a best-practice deployment, more one that will get you started quickly. Please note the Packer build must have completed succesfully before your Terraform build can begin.

1. Navigate to the `/targets/ssh/enhanced-recording-aws` directory
2. Open the `variables.tf` file and inspect the required variables for this build.
3. Create a file named `terraform.tfvars` to satisfy the input variables. An example format for this file would be: 

```
   region = "ap-southeast-2"
   ami_owner = "111111111111"
   ami_name = "myteleport-ssh-target"
   key_name = "mykey"
   machines = {
    ssh-target-1 = {
        environment = "dev"
        hostname = "ssh-target-1"
    }
    ssh-target-2 = {
        environment = "test"
        hostname = "ssh-target-2"
    }
   }
```
**Please note that the machines variable requires one or more definitions of a hostname and environment. You can create as many targets as you would like.**

4. In the same directory, run `terraform init` to ensure Terraform has the right plugins loaded
5. Run `terraform plan` to see the resources created by this code and ensure there are no input or syntax errors
6. Run `terraform apply` to create the target machines. 
7. On the completion of the Terraform run, you will see the public IP addresses of the machines created. Your machines should also succesfully join your Teleport cluster automatically. If the machines do not join, you can SSH to the target and check the Teleport logs using `systemctl status teleport`. 