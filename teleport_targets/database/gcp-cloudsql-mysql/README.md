# Teleport Quick Start with Terraform
## Database Access to MySQL on GCP CloudSQL

This repository contains Terraform code to stand up MySQL targets on GCP, for the purposes of being accessed via Teleport. 

## Pre-requisites
Please note the following pre-requisites for using this repository:
- A working, accessible Teleport cluster. You will need your proxy address as an input to this code. 
- Network connectivity between these RDS instances and the mentioned Teleport proxy. The security groups in this repository allow all egress out of the created VPC. 
- An existing Packer build for the Teleport target Linux machine. Please see the targets/ssh/gcp-vm directory and follow the Packer instructions.
- The Terraform binary on your local machine, or on a machine where you can perform the automated builds. Tested using Terraform v1.2.4
- Google Cloud Platform credentials. Any of the accepted credential types for automated provisioning on GCP. Examples can be found [here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started).
- A GCP project with Compute APIs enabled.
- A GCP Service Account with Cloud SQL Admin permissions. Follow step 1 of the instructions [here](https://goteleport.com/docs/database-access/guides/mysql-cloudsql/#step-15-create-a-service-account-for-the-teleport-database-service). Take note of the service account name as it will be an input to your code. 

## How to use this repository

### Packer Build
As per the pre-requisites, please ensure you have an existing Packer build for your Teleport target. You can follow the Packer Build instructions [here](https://github.com/dgkirkwood/teleport-terraform-quickstart/tree/main/targets/ssh/gcp-vm) to acheive this. Please take note of the AMI Name and Owner as part of this process. 


### Terraform Build
Terraform is used to create a CloudSQL instance, as well as a Linux VM which will facilitate connectivity between your proxy and the database. You can take a look at the .tf files in this repository to understand what will be built. This is by no means a best-practice deployment, more one that will get you started quickly. 

1. Navigate to the `/targets/database/gcp-cloudsql-mysql` directory
2. Open the `variables.tf` file and inspect the required variables for this build.
3. Create a file named `terraform.tfvars` to satisfy the input variables. An example format for this file would be: 

```
   project_id = "my-project-3242134"
   region     = "australia-southeast1"
   prefix = "dk"
   host_name = "linux-host"
   join_token = "f5464657aec975d90234f9045685"
   environment = "prod"
   db_name = "my-db"
   ami_name = "my-built-ami"
   service_account_name = "my-sqladmin-serviceaccount"
```
**If you are unsure about setting any of these variables, please see the pre-requisites section above.**

4. In the same directory, run `terraform init` to ensure Terraform has the right plugins loaded
5. Run `terraform plan` to see the resources created by this code and ensure there are no input or syntax errors
6. Run `terraform apply` to create the target machines. 
7. On the completion of the Terraform run, your Linux box and database should register to your Teleport cluster automatically. If they do not, SSH to the linux box and investigate the logs of the Teleport service. 
8. Note that the CloudSQL instance has a public IP Address for the purposes of bootstrapping MySQL data such as databases, tables and permissions. As Teleport is connecting via a private IP address, this public IP can be removed for everyday use. 