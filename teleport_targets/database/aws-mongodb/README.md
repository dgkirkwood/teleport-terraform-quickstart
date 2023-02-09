# Teleport Quick Start with Terraform
## MongoDB (Self-hosted) Access on AWS with Teleport

This repository contains Packer and Terraform code to stand up a self-hosted MongoDB instance on AWS for the purposes of being accessed by Teleport. 

## Pre-requisites
Please note the following pre-requisites for using this repository:
- A working, accessible Teleport cluster. You will need your proxy address as an input to this code. 
- Network connectivity between the infrastructure created in this repository, and the mentioned Teleport proxy. The security groups in this repository are very permissive and allow all egress out of the created VPC. 
- A Teleport EC2 Join Token name. Please see the instructions for setting up the EC2 Join method using Teleport [here](https://goteleport.com/docs/setup/guides/joining-nodes-aws-ec2/).
- A pre-existing AWS VPC and subnet for your Packer builds. Please note you will require the ID for both.
- The Packer and Terraform binaries on your local machine, or on a machine where you can perform the automated builds. Tested using Packer v1.8.2 and Terraform v1.2.4
- AWS Credentials. Any of the accepted credential types for automated provisioning on AWS. Examples can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

## How to use this repository

### Packer Build
Packer is used to create a custom AMI with the Teleport binary, and a configuration file which the binary will use to join your Teleport cluster. To see the steps contained within the Packer build, see the file `packer/aws-mongo-target.pkr.hcl`. Please note this is a generic build which you may want to customise with your own local users or additional binaries on the target machine. 

This build will download the latest version of Teleport by default. Please ensure compatibility between your Teleport cluster and the binary on the target. 

The build will also populate the MongoDB Database with two users and a single piece of data. Please note the users must match DB Users in your Teleport cluster. You may want to customise the data inserted for your environment. 

1. Clone this repository to your local machine 
2. Navigate to the `/teleport_targets/database/aws-mongodb/packer` subdirectory
3. Open the `variables.pkr.hcl` file and inspect the required variables for this build. If you are unsure about satisfying these variables, please see the pre-requisites above. 
4. Create database certificates in the `cert` dir. These certificates are uploaded and used as the allowed certs to connect with.

```bash
 tctl auth sign --format=mongodb --host=localhost --out=mongo --ttl=10190h
```

5. Create a file named `variables.auto.pkrvars.hcl` to satisfy the input variables. An example format for this file would be: 
   
   ```
   ec2_token_name = "ec2-token"
   auth_address = "mycluster.mydomain.com:443"
   ami_name = "mymongodb-teleport-ami"
   region = "ap-southeast-2"
   vpc_id = "vpc-04e78c4cc287db19c"
   subnet_id = "subnet-05062b931e314d650"
   db_name = "my-mongodb"
   user1 = "alice"
   user2 = "bob"
   environment = "dev"
    ```
6. Run `packer init .` to ensure Packer has the required plugins downloaded
7. Run `packer build .` to begin the image build

**Please note that image builds will occasionally fail due to connectivity or package repository errors. If you see a failed build, run the build command again. If you see continued errors please raise an issue on this repository.**

When the build is succesful you will see a message similar to the following: 
```
Build 'packer-teleport-proxy.amazon-ebs.ubuntu' finished after 8 minutes 34 seconds.
```


### Terraform Build
Terraform is used to create one or more target machines using the image from your Packer Build steps. You can take a look at the .tf files in this repository to understand what will be built. This is by no means a best-practice deployment, more one that will get you started quickly. Please note the Packer build must have completed succesfully before your Terraform build can begin.

1. Navigate to the `/teleport_targets/databases/aws-mongodb` directory
2. Open the `variables.tf` file and inspect the required variables for this build.
3. Create a file named `terraform.tfvars` to satisfy the input variables. An example format for this file would be: 

```
   region = "ap-southeast-2"
   ami_owner = "<Your Account ID>"
   ami_name = "mymongodb-teleport-ami"
   key_name = "my-key"
   hostname = "mongohost"
   environment = "dev"
```
**Please note the AMI name must match the name set during your Packer build. The AMI Owner will be the account number of the AWS account where you performed the Packer build.**

4. In the same directory, run `terraform init` to ensure Terraform has the right plugins loaded
5. Run `terraform plan` to see the resources created by this code and ensure there are no input or syntax errors
6. Run `terraform apply` to create the target machines. 
7. On the completion of the Terraform run, you will see the public IP addresses of the machines created. Your machines should also succesfully join your Teleport cluster automatically. If the machines do not join, you can SSH to the target and check the Teleport logs using `systemctl status teleport`. 


### Test Connection

Have a user that has `bob` and `alice` as available db users or create a local one

```bash
tctl users add \
  --roles=access \
  --db-users=\* \
  --db-names=\* \
  alice
```

Now you should be able to connect from CLI

```bash
tsh db connect --db-user=alice my-mongodb
```


