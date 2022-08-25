# Teleport Quick Start with Terraform
## Database Access to MySQL on AWS RDS

This repository contains Terraform code to stand up RDS MySQL targets on AWS, for the purposes of being accessed via Teleport. 

## Pre-requisites
Please note the following pre-requisites for using this repository:
- A working, accessible Teleport cluster. You will need your proxy address as an input to this code. 
- Network connectivity between these RDS instances and the mentioned Teleport proxy. The security groups in this repository allow all egress out of the created VPC. 
- An existing Packer build for the Teleport target Linux machine. Please see the targets/ssh/aws-ec2join directory and follow the Packer instructions.
- The Terraform binary on your local machine, or on a machine where you can perform the automated builds. Tested using Terraform v1.2.4
- AWS Credentials. Any of the accepted credential types for automated provisioning on AWS. Examples can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

## How to use this repository

### Packer Build
As per the pre-requisites, please ensure you have an existing Packer build for your Teleport target. You can follow the Packer Build instructions [here](https://github.com/dgkirkwood/teleport-terraform-quickstart/tree/main/targets/ssh/aws-ec2join) to acheive this. Please take note of the AMI Name and Owner as part of this process. 


### Terraform Build
Terraform is used to build one or more RDS instances, as well as a Linux VM which will facilitate connectivity between your proxy and the databases. You can take a look at the .tf files in this repository to understand what will be built. This is by no means a best-practice deployment, more one that will get you started quickly. 

1. Navigate to the `/targets/database/aws-rds-mysql` directory
2. Open the `variables.tf` file and inspect the required variables for this build.
3. Create a file named `terraform.tfvars` to satisfy the input variables. An example format for this file would be: 

```
   region = "ap-southeast-2"
   db_password = "my-super-secure-password"
   db_admin = "admin"
   ami_owner = "13235462323"
   ami_name = "my-ssh-template"
   key_name = "my-ssh-key"
   dbs = {
           db1 = {
               dbname = "db1"
               environment = "dev"
           }
           db2 = {
               dbname = "db2"
               environment = "test"
           }
           db3 = {
               dbname = "db3"
               environment = "prod"
           }

       }
```
**Please note that the dbs variable requires one or more dbs to be configured with a name and environment for each. You can create as many RDS instances as you would like.**

4. In the same directory, run `terraform init` to ensure Terraform has the right plugins loaded
5. Run `terraform plan` to see the resources created by this code and ensure there are no input or syntax errors
6. Run `terraform apply` to create the target machines. 
7. On the completion of the Terraform run, you will see the public IP addresses of the linux machine, and the endpoints of your RDS instances. The Linux machine should register with your Proxy automatically, and then will automatically register the database instances. If the machines do not join, you can SSH to the target and check the Teleport logs using `systemctl status teleport`. 
8. Note that the security groups configured allow public ingress on port 3306 for the purposes of bootstrapping the MySQL configuration (Creation of initial users or sample data). This rule can be changed to allow internal connectivity only once this bootstrap is complete. 