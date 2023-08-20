# Teleport Quick Start with Terraform
## Desktop Access to Windows Server 2019 on AWS

This repository contains Terraform and Packer code to stand up a Windows Domain Controller and domain member server, for the purposes of being accessed via Teleport. Packer is used to build an Active Directory Domain Controller with certificate services for Secure LDAP. Terraform is used to deploy the AD server, a domain member and a linux box for facilitating connectivity back to Teleport. 

## Pre-requisites
Please note the following pre-requisites for using this repository:
- A working, accessible Teleport cluster. You will need your proxy address as an input to this code. 
- An existing AWS VPC and Subnet for your Packer build. You will need the ID of both as an input to the Packer code below. 
- A sandbox domain name and host name for your domain controller. This domain and hostname can by anything you like as long as they conform to the standards required by Active Directory. 
- A Teleport join token. You can generate this on your Teleport cluster using `tctl tokens add --type=node,windowsdesktop`
- A Packer build for your Linux instance. Packer code is located [here](https://github.com/dgkirkwood/teleport-terraform-quickstart/tree/main/teleport_targets/ssh/aws-ec2join), run through the Packer build instructions and then return to this guide.
- The Packer and Terraform binaries on your local machine, or on a machine where you can perform the automated builds. Tested using Packer v1.8.2 and Terraform v1.2.4
- AWS Credentials. Any of the accepted credential types for automated provisioning on AWS. Examples can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

## How to use this repository

### Packer Build
Packer is used to create a custom AMI with an installed and configured Active Directory Domain Controller. Please note this is not a best practices deployment, more one to quickly get you started. 

1. Clone this repository to your local machine 
2. Navigate to the `/teleport_targets/windows_desktop/aws/packer` subdirectory
3. Open the `variables.pkr.hcl` file and inspect the required variables for this build. If you are unsure about satisfying these variables, please see the pre-requisites above. 
4. Create a file named `variables.auto.pkrvars.hcl` to satisfy the input variables. An example format for this file would be: 
   
   ```
   ami_name = "my-dc-ami"
   region = "ap-southeast-2"
   vpc_id = "vpc-04e78c4cc247da19a"
   subnet_id = "subnet-05060b931f314d650"
   hostname = "dc01"
   active_directory_domain_name = "mydomain.local"
   active_directory_netbios_name = "MYDOMAIN"
   virtual_machine_fqdn = "dc01.mydomain.local"
   admin_password = "my5uper5trongP4ssw0rd"
    ```
5. Run `packer init .` to ensure Packer has the required plugins downloaded
6. Run `packer build .` to begin the image build

### Terraform Build
Terraform is used to build two Windows servers (A domain controller and a domain-joined member) as well as a Linux server to facilitate connectivity back to your Teleport cluster. Note that this is not a recommended production build, more something to help you get started. 

1. Navigate to the `/teleport_targets/windows_desktop/aws` directory
2. Open the `variables.tf` file and inspect the required variables for this build.
3. Create a file named `terraform.tfvars` to satisfy the input variables. An example format for this file would be: 

   ```
   key_name = "dk-rsa"
   admin_password = "my5uper5trongP4ssw0rd"
   active_directory_domain_name = "mydomain.local"
   active_directory_netbios_name = "mydomain"
   ami_name = "my-dc-ami"
   ami_owner = "<AWS Account Number>"
   linux_ami_name = "my-minux-ami"
   linux_hostname = "teleport01"
   environment = "dev"
   windows_hostname = "domainmember01"
   admin_user = "mydomain\\Administrator"
   join_token = "ae45309728b9234ec0834d032b9b9b5c"
   ```

4. In the same directory, run `terraform init` to ensure Terraform has the right plugins loaded
5. Run `terraform plan` to see the resources created by this code and ensure there are no input or syntax errors
6. Run `terraform apply` to create the target machines. 
7. On the completion of your run, you will see public IP addresses for your Domain Controller, your Windows domain member and your Linux instance. You will be able to RDP to the Windows instances and SSH to the Linux instance. 
8. You can connect to the Domain Controller using ther admin_user and the domain password that you set in the Packer build. On the Domain Controller, simply follow the steps [here](https://goteleport.com/docs/desktop-access/getting-started/#step-17-create-a-restrictive-service-account) to prepare the DC for Teleport. 
9. You can connect to the windows Domain member using the user Administrator, and a password which will also be output at the end of the Terraform run. You will need to reboot this machine and join it to the domain for it to be accessible through Teleport. 
10. The linux machine should have all of its configuration ready to go. If your Windows setup takes a long time, the Teleport service on this linux box may need a restart. If so simply SSH to the box using the key you specified in the Terraform deploy, and then run `sudo systemctl restart teleport`. 
