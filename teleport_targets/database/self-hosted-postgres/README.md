# Teleport Quick Start with Terraform
## Database Access to Self-Hosted Postgres on EC2

This repository contains Terraform code to stand up a configured Postgres database on AWS EC2, for the purposes of being accessed via Teleport. 

## Pre-requisites
Please note the following pre-requisites for using this repository:
- A working, accessible Teleport cluster. You will need your proxy address as an input to this code. 
- An existing VPC and Subnet to run your Packer builds
- A Teleport EC2 join token. See how to configure this [here](https://goteleport.com/docs/management/join-services-to-your-cluster/aws-ec2/).
- The Terraform binary on your local machine, or on a machine where you can perform the automated builds. Tested using Terraform v1.2.4
- AWS Credentials. Any of the accepted credential types for automated provisioning on AWS. Examples can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

## How to use this repository

### Packer Build
Packer is used to create a custom AMI with the Teleport binary, and a configuration file which the binary will use to join your Teleport cluster. It will also install Postgres, configure the database to accept certificate-based authentication and bootstrap some data into the database. To see the steps contained within the Packer build, see the file `packer/aws-ec2-postgres-target.pkr.hcl`. Please note this is a generic build which you may want to customise with your own local users or additional binaries on the target machine.

To create your AMI execute the following steps. 

1. Ensure this repository is cloned to your local machine
2. Navigate to the `teleport_targets/database/self-hosted-postgres/packer` subdirectory
3. Open the `variables.pkr.hcl` file and inspect the required variables for this build. If you are unsure about satisfying these variables, please see the pre-requisites above. 
4. Create a file named `variables.auto.pkrvars.hcl` to satisfy the input variables. An example format for this file would be: 
```hcl
   ec2_token_name = "ec2-token"
   auth_address = "myproxy.address.com:443"
   ami_name = "myteleport-ssh-target"
   region = "ap-southeast-2"
   vpc_id = "vpc-321cvcx56a13"
   subnet_id = "subnet-0651312asdfd12"
   teleport_version = "13.0.1"
   postgres_user = "developer"
   database_name = "dev-db"
```
**Note that the Teleport version should match the version of your existing Teleport cluster**

5. Run `packer init .` to ensure Packer has the required plugins downloaded
6. Run `packer build .` to begin the image build

**Please note that image builds will occasionally fail due to connectivity or package repository errors. If you see a failed build, run the build command again. If you see continued errors please raise an issue on this repository.**

When the build is succesful you will see a message similar to the following: 
```
Build 'packer-teleport-proxy.amazon-ebs.ubuntu' finished after 8 minutes 34 seconds.
```

### Terraform Build
Terraform is used to build an EC2 instance using the AMI you created in Packer, as well as some supporting AWS constructs to facilitate connectivity. You can take a look at the .tf files in this repository to understand what will be built. This is by no means a best-practice deployment, more one that will get you started quickly. 

1. Navigate to the `teleport_targets/database/self-hosted-postgres` directory
2. Open the `variables.tf` file and inspect the required variables for this build.
3. Create a file named `terraform.tfvars` to satisfy the input variables. An example format for this file would be: 

```
   region = "ap-southeast-2"
   ami_owner = "13235462323"
   ami_name = "my-ssh-template"
   key_name = "my-ssh-key"
   machines = {
     target1 = {
       environment = "dev"
       hostname = "db-host"
     }
   }
```

1. In the same directory, run `terraform init` to ensure Terraform has the right plugins loaded
2. Run `terraform plan` to see the resources created by this code and ensure there are no input or syntax errors
3. Run `terraform apply` to create the target machines. 
4. On the completion of the Terraform run, you will see the public IP addresses of the linux machine. This AMI should register with your Teleport cluster automatically. If the machines do not join, you can SSH to the target and check the Teleport logs using `systemctl status teleport`. 
6. If the node is registering, the Postgres database should also register. Note that some RBAC work is required to allow an end user to connect to this database. Consider the role template below as a way of giving access to Postgres. 

```yaml
kind: "role"
version: "v6"
metadata:
  name: "postgres-access"
spec:
  options:
    max_session_ttl: "8h0m0s"
  allow:
    db_labels:
      env: dev
    db_names:
    - dev-db
    db_users:
    - developer
```
The values used for `db_labels`, `db_names` and `db_users` must match the values you set during the Packer build step above. Assign this role to your Teleport user and you will be able to access the database. 