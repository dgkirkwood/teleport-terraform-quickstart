# Teleport Quick Start with Terraform
## Single Node Teleport Proxy on AWS

This repository contains Packer and Terraform code to stand up a Teleport Proxy server on AWS, running on a single EC2 node. This code is not designed for a production deployment, but rather for testing and lab scenarios. Terraform code for a Teleport HA deployment on AWS can be found [here](https://github.com/gravitational/teleport/tree/master/examples/aws/terraform/ha-autoscale-cluster).

## Pre-requisites
Please note the following pre-requisites for using this repository:
- A Route 53 hosted zone on AWS. This terraform code will create Route 53 'A' records using this hosted zone. Please have a host name ready as an input for the Terraform code.
- A pre-existing AWS VPC and subnet for your Packer builds. Please note you will require the ID for both.
- The Packer and Terraform binaries on your local machine, or on a machine where you can perform the automated builds. Tested using Packer v1.8.2 and Terraform v1.2.4
- AWS Credentials. Any of the accepted credential types for automated provisioning on AWS. Examples can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

## How to use this repository

### Packer Build
Packer is used to create a custom AMI with the Teleport binary, and a configuration file which the will be used to bootstrap the Teleport cluster. You will see inside the `packer/` directory there is an option to build an OSS or Enterprise Teleport cluster. To build Enterprise, a license.pem file is required to be present in the `config_files/` directory. 

To see the steps contained within the Packer build, see the file `packer/<oss_packer or ent_packer>/*-aws-proxy.pkr.hcl`. Please note this is a generic build which you may want to customise with your own local users or additional binaries on the target machine. 
 

1. Clone this repository to your local machine 
2. Navigate to the `/teleport_cluster/single_node/aws/<oss or ent>_packer` subdirectory
3. Open the `variables.pkr.hcl` file and inspect the required variables for this build. If you are unsure about satisfying these variables, please see the pre-requisites above. 
4. Create a file named `variables.auto.pkrvars.hcl` to satisfy the input variables. An example format for this file would be: 
   
   ```
   cluster_name = "mycluster.fqdn.com"
   ami_name = "my-teleport-proxy"
   region = "ap-southeast-2"
   vpc_id = "vpc-id111111111"
   subnet_id = "subnet-id1111111111"
   email = "my.email@domain.com"
    ```
5. Run `packer init .` to ensure Packer has the required plugins downloaded
6. Run `packer build .` to begin the image build

**Please note that image builds will occasionally fail due to connectivity or package repository errors. If you see a failed build, run the build command again. If you see continued errors please raise an issue on this repository.**

When the build is succesful you will see a message similar to the following: 
```
Build 'packer-teleport-proxy.amazon-ebs.ubuntu' finished after 8 minutes 34 seconds.
```


### Terraform Build
Terraform is used to create the Proxy EC2 instance using the Packer build in the previous step. It will also create the supporting networking, IAM and DNS records for the proxy to function. You can take a look at the .tf files in this repository to understand what will be built. This is by no means a best-practice deployment, more one that will get you started quickly. Please note the Packer build must have completed succesfully before your Terraform build can begin.

1. Navigate to the `/teleport_cluster/single_node/aws` directory
2. Open the `variables.tf` file and inspect the required variables for this build.
3. Create a file named `terraform.tfvars` to satisfy the input variables. An example format for this file would be: 

```
   domain = "mycluster.fqdn.com"
   image_name = "my-teleport-proxy"
   image_owner = "165258854585"
   hosted_zone = "fqdn.com"
   region = "ap-southeast-2"
   key = "my-key"
```
**Please note that the domain must match your cluster name from the Packer build. Your image name must also match the Packer image build name. The image owner will be the account where your Packer build executed.**

4. In the same directory, run `terraform init` to ensure Terraform has the right plugins loaded
5. Run `terraform plan` to see the resources created by this code and ensure there are no input or syntax errors
6. Run `terraform apply` to create the Proxy. 
7. On the completion of the Terraform run, you will see the public IP address of your Teleport Proxy. You should also be able to access the Teleport UI by visiting your Proxy address (mycluster.fqdn.com). If the UI is not available, SSH into the box directly and inspect the Teleport service using `sudo systemctl status teleport`. 