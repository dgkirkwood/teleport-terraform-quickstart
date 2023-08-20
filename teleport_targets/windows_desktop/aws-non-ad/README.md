# Teleport Quick Start with Terraform
## Desktop Access to Windows Server 2019 on AWS

This repository contains Terraform and Packer code to stand up a Windows Server 2019 instance, for the purposes of being accessed via Teleport. Packer is used to build a Windows Server AMI, with the Teleport service and CA installed (See the documentation for this process [here](https://goteleport.com/docs/desktop-access/getting-started/)). Terraform is used to deploy the Windows server, and a linux box for facilitating connectivity back to Teleport. Please note this is an example of standalone, non-domain joined server access. For domain joined machines, please see [this example](https://github.com/dgkirkwood/teleport-terraform-quickstart/tree/main/teleport_targets/windows_desktop/aws).



## Pre-requisites
Please note the following pre-requisites for using this repository:
- A working, accessible Teleport cluster. You will need your proxy address as an input to this code. Note Teleport Enterprise v12 or higher is required.
- An authenticated Teleport session or access to your Auth server to be able to generate a file from your Teleport CA. See the Packer section for more.
- An existing AWS VPC and Subnet for your Packer build. You will need the ID of both as an input to the Packer code below. 
- EC2 join configured on your Teleport cluster, with the `WindowsDesktop` role included. See more on creating an EC2 join token [here](https://goteleport.com/docs/management/guides/joining-nodes-aws-ec2/).
- A Packer build for your Linux instance. Packer code is located [here](https://github.com/dgkirkwood/teleport-terraform-quickstart/tree/main/teleport_targets/ssh/aws-ec2join), run through the Packer build instructions and then return to this guide.
- The Packer and Terraform binaries on your local machine, or on a machine where you can perform the automated builds. Tested using Packer v1.8.4 and Terraform v1.3.5
- AWS Credentials. Any of the accepted credential types for automated provisioning on AWS. Examples can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

## How to use this repository

### Packer Build
Packer is used to build a Windows Server 2019 AMI with the required Teleport services installed. Please note this is not a best practices deployment, more one to quickly get you started. 

1. Clone this repository to your local machine 
2. Navigate to the `/teleport_targets/windows_desktop/aws-non-ad/packer` subdirectory
3. Open the `variables.pkr.hcl` file and inspect the required variables for this build. If you are unsure about satisfying these variables, please see the pre-requisites above. 
4. Create a file named `variables.auto.pkrvars.hcl` to satisfy the input variables. An example format for this file would be: 
   
   ```
   ami_name = "win-2019-non-ad"
   region = "ap-southeast-2"
   vpc_id = "<Your VPC ID>"
   subnet_id = "<Your Subnet ID>"
   hostname = "greenwood"
   admin_password = "Teleport1234"
    ```
5. Using an authenticated Teleport session, or using access to your Teleport auth server, export your Teleport CA to be used in the Packer build. Run `tctl auth export --type=windows > teleport.cer` and ensure `teleport.cer` is placed in the `/teleport_targets/windows_desktop/aws-non-ad/packer` directory.
6. Run `packer init .` to ensure Packer has the required plugins downloaded
7. Run `packer build .` to begin the image build

### Terraform Build
Terraform is used to build the Windows server as well as a Linux server to facilitate connectivity back to your Teleport cluster. Note that this is not a recommended production build, more something to help you get started. 

1. Navigate to the `/teleport_targets/windows_desktop/aws-non-ad` directory
2. Open the `variables.tf` file and inspect the required variables for this build.
3. Create a file named `terraform.tfvars` to satisfy the input variables. An example format for this file would be: 

   ```
   key_name = "my-ssh-key"
   ami_name = "win-2019-non-ad" #Must match Packer ami_name
   ami_owner = "<Your AWS Account number>"
   linux_ami_name = "dk-ssh-template"
   linux_hostname = "lindon"
   environment = "dev"
   ```

4. In the same directory, run `terraform init` to ensure Terraform has the right plugins loaded
5. Run `terraform plan` to see the resources created by this code and ensure there are no input or syntax errors
6. Run `terraform apply` to create the target machines. 
7. On the completion of the run, you will see the public IP addresses of the Linux box and the Windows server. These are for troubleshooting purposes only. Both services should join your Teleport cluster automatically. 
8. If the instances do not join your cluster, SSH to the linux box using the key specified in your Terraform run, and run `systemctl status teleport` to check the health of the Teleport Windows Desktop process. 
