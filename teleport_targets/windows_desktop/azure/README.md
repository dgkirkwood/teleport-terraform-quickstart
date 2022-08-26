# Teleport Quick Start with Terraform
## Desktop Access to Windows Server 2016 on Azure

This repository contains Terraform code to stand up a Windows Domain Controller and domain member server, for the purposes of being accessed via Teleport. This code uses AzureRM Virtual Machine Extensions to create an AD Domain, and to join the client to that domain. This repo uses code from https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples.

## Pre-requisites
Please note the following pre-requisites for using this repository:
- A working, accessible Teleport cluster. You will need your proxy address as an input to this code. 
- A Packer build for a linux image for the RDP agent. You can follow the instructions [here](https://github.com/dgkirkwood/teleport-terraform-quickstart/tree/main/teleport_targets/ssh/azure-linux-vm#packer-build) to generate the VM image.
- A Teleport join token. You can generate this on your Teleport cluster using `tctl tokens add --type=node,windowsdesktop`
- The Terraform binary on your local machine, or on a machine where you can perform the automated builds. Tested using Terraform v1.2.4
- Azure credentials. Any of the accepted credential types for automated provisioning on Azure. Examples can be found [here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started).

## How to use this repository

### Terraform Build
Terraform is used to build two Windows servers (A domain controller and a domain-joined member) as well as a Linux server to facilitate connectivity back to your Teleport cluster. Note that this is not a recommended production build, more something to help you get started. 

1. Navigate to the `/targets/windows_desktop/azure` directory
2. Open the `variables.tf` file and inspect the required variables for this build.
3. Create a file named `terraform.tfvars` to satisfy the input variables. An example format for this file would be: 

```
prefix = "rdp_lab"
location = "australiaeast"
admin_username = "admin"
admin_password = "myWindowsPassword1234"
active_directory_domain_name = "mydomain.local"
active_directory_netbios_name = "mydomain"
dc_hostname = "dc01"
client_hostname = "client01"
image_name = "my-packer-image"
image_rg = "my-image-rg"
linux_hostname = "linux01"
join_token = "aae3458847587b879f9898ec980"
```

1. In the same directory, run `terraform init` to ensure Terraform has the right plugins loaded
2. Run `terraform plan` to see the resources created by this code and ensure there are no input or syntax errors
3. Run `terraform apply` to create the target machines. 
4. On the completion of your Terraform run, you will see a public IP address for your Windows client, as well as the Linux server. You can use native RDP to connect to the Windows client, from which you can RDP to the domain controller. 
5. At this point your domain is almost ready for Desktop Access configuration. The final step is to enable the AD Certificate Authority on your Domain Controller, using instructions [here](https://docs.microsoft.com/en-us/windows-server/networking/core-network-guide/cncg/server-certs/install-the-certification-authority).
6. Once your CA is installed, you can follow the instructions [here](https://goteleport.com/docs/desktop-access/getting-started/) to configure desktop access for Teleport. 