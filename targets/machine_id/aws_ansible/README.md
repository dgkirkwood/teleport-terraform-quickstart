# Teleport Quick Start with Terraform
## Ansible SSH with Teleport Machine ID

This repository contains the code to stand up an Ansible control node and two target nodes, using Teleport [Machine ID](https://goteleport.com/docs/machine-id/introduction/) to facilitate secure SSH access for Ansible. This code was built referring to the [Machine ID for Ansible guide](https://goteleport.com/docs/machine-id/guides/ansible/).

## Pre-requisites
Please note the following pre-requisites for using this repository:
- A working, accessible Teleport cluster. You will need your proxy address as an input to this code. 
- Network connectivity between these EC2 instances and the mentioned Teleport proxy. The security groups in this repository allow all egress out of the created VPC. 
- EC2 Join configured for your Teleport cluster. See instructions [here](https://goteleport.com/docs/setup/guides/joining-nodes-aws-ec2/)
- A Machine ID join token. This will be created on your Auth cluster using a command such as `tctl bots add ansible --roles=access --logins=ubuntu`
- An existing Packer build for the Teleport target Linux machine. Please see the `targets/ssh/aws-ec2join` directory and follow the Packer instructions.
- The Terraform binary on your local machine, or on a machine where you can perform the automated builds. Tested using Terraform v1.2.4
- AWS Credentials. Any of the accepted credential types for automated provisioning on AWS. Examples can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

## How to use this repository

### Terraform Build
Terraform is used to create one or more target machines using the image from your Packer Build steps. You can take a look at the .tf files in this repository to understand what will be built. This is by no means a best-practice deployment, more one that will get you started quickly. Please note the Packer build must have completed succesfully before your Terraform build can begin.

1. Navigate to the `/targets/machine_id/aws_ansible` directory
2. Open the `variables.tf` file and inspect the required variables for this build.
3. Create a file named `terraform.tfvars` to satisfy the input variables. An example format for this file would be: 

```
   region = "ap-southeast-2"
   ami_owner = "111111111111"
   ami_name = "myteleport-ssh-target"
   key_name = "mykey"
   proxy_address = "myproxy.mydomain.com"
   join_token = "65d7719e2e03850abedf3be3017abc3f"
   control_hostname = "ansible-control-node"
   control_env = "dev"
   target_machines = {
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
**Please note the machines variable requires two target machines for this example. You can configure more or less target machines but you will need to alter the Terraform config for the Ansible targets.**

4. In the same directory, run `terraform init` to ensure Terraform has the right plugins loaded
5. Run `terraform plan` to see the resources created by this code and ensure there are no input or syntax errors
6. Run `terraform apply` to create the target machines. 
7. On the completion of the Terraform run, you will see the public IP addresses of the machines created. Your machines should also succesfully join your Teleport cluster automatically. 

### Testing Machine ID
To test Machine ID, you will log in to the control node and run an Ansible playbook. The playbook will use Teleport for connectivity, and short-lived, automatically rotated certificates for authentication. 

1. Log in to your Teleport proxy. 
2. Run `tsh ls` to ensure the three nodes have joined your cluster and are visible to your user.
3. Log in to the control node using Teleport: `tsh ssh ubuntu@<control-node-hostname>` 
4. Investigate the following on the control node:
   - Teleport is running as a systemd service, facilitating SSH access to this node and the EC2-based auto join for your cluster. Use `sudo systemctl status teleport` to see more.
   - Machine ID is running as a separate systemd service, using the Ansible bot token generated as part of the pre-requisites. Use `sudo systemctl status machine-id` to see more.
   - A folder at `/home/ubuntu/ansible` contains your ansible configuration.
5. Change directory to the Ansible folder using `cd /home/ubuntu/ansible`
6. Run the Ansible playbook using `sudo ansible-playbook playbook.yaml`
7. You should see the playbook run succesfully. By default it will not have any meaningful output, but if you look at your Teleport logs you will notice all Ansible communication was via Teleport. You can also take a look at `/home/ubuntu/ansible/ansible.cfg` to see how Ansible is referring to the Machine ID SSH config rather than the system default. 